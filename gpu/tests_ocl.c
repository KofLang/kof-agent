// tests_ocl.c — E3 (specs/ENGINE_V2.md §3.2): valida os 14 kernels .cl contra
// referencias C inteiras identicas (bit-exato), via cadeia dlopen de
// libOpenCL.so.1 (mesmo padrao do vkchain M32.3: cadeia C primeiro, integracao
// de compiler lane depois). rc=77 = SKIP honesto sem plataforma ICD.
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef void* cl_platform_id; typedef void* cl_device_id; typedef void* cl_context;
typedef void* cl_command_queue; typedef void* cl_mem; typedef void* cl_program;
typedef void* cl_kernel; typedef intptr_t cl_int; typedef uintptr_t cl_ulong; typedef cl_ulong cl_bitfield;
typedef uint32_t cl_uint; typedef size_t cl_addressing;
#define CL_SUCCESS 0
#define CL_MEM_READ_WRITE 1
#define CL_MEM_COPY_HOST_PTR 8
#define CL_MEM_HOST_READ_ONLY 32
#define CL_TRUE 1

static int (*p_clGetPlatformIDs)(cl_uint, cl_platform_id*, cl_uint*);
static int (*p_clGetDeviceIDs)(cl_platform_id, cl_bitfield, cl_uint, cl_device_id*, cl_uint*);
static cl_context (*p_clCreateContext)(const cl_uint*, cl_uint, const void*, void*, cl_int*);
static cl_command_queue (*p_clCreateCommandQueue)(cl_context, cl_device_id, cl_uint, cl_int*);
static cl_mem (*p_clCreateBuffer)(cl_context, cl_uint, size_t, void*, cl_int*);
static cl_program (*p_clCreateProgramWithSource)(cl_context, cl_uint, const char**, const size_t*, cl_int*);
static int (*p_clBuildProgram)(cl_program, cl_uint, const cl_device_id*, const char*, void*, void*);
static int (*p_clGetProgramBuildInfo)(cl_program, cl_device_id, cl_uint, size_t, void*, size_t*);
static cl_kernel (*p_clCreateKernel)(cl_program, const char*, cl_int*);
static int (*p_clSetKernelArg)(cl_kernel, cl_uint, size_t, const void*);
static int (*p_clEnqueueNDRangeKernel)(cl_command_queue, cl_kernel, cl_uint, const size_t*, const size_t*, const size_t*, cl_uint, const void*, void*);
static int (*p_clEnqueueReadBuffer)(cl_command_queue, cl_mem, cl_int, size_t, size_t, void*, cl_uint, const void*, void*);
static int (*p_clFinish)(cl_command_queue);

static cl_platform_id plat; static cl_device_id dev; static cl_context ctx; static cl_command_queue q;
static cl_program prog;
static int fails = 0, checks = 0;

static void* need(const char* n) { void* s = dlsym(RTLD_DEFAULT, n); if (!s) { fprintf(stderr, "missing symbol %s\n", n); exit(2); } return s; }
static void load(void) {
    if (!dlopen("libOpenCL.so.1", RTLD_NOW | RTLD_GLOBAL)) { fprintf(stderr, "no libOpenCL\n"); exit(2); }
    p_clGetPlatformIDs = need("clGetPlatformIDs"); p_clGetDeviceIDs = need("clGetDeviceIDs");
    p_clCreateContext = need("clCreateContext"); p_clCreateCommandQueue = need("clCreateCommandQueue");
    p_clCreateBuffer = need("clCreateBuffer"); p_clCreateProgramWithSource = need("clCreateProgramWithSource");
    p_clBuildProgram = need("clBuildProgram"); p_clGetProgramBuildInfo = need("clGetProgramBuildInfo");
    p_clCreateKernel = need("clCreateKernel"); p_clSetKernelArg = need("clSetKernelArg");
    p_clEnqueueNDRangeKernel = need("clEnqueueNDRangeKernel"); p_clEnqueueReadBuffer = need("clEnqueueReadBuffer");
    p_clFinish = need("clFinish");
}

static char* slurp(const char* p, size_t* n) {
    FILE* f = fopen(p, "r"); if (!f) { fprintf(stderr, "open %s\n", p); exit(2); }
    fseek(f, 0, SEEK_END); *n = ftell(f); fseek(f, 0, SEEK_SET);
    char* b = malloc(*n + 1); if (fread(b, 1, *n, f) != *n) { fprintf(stderr, "read %s\n", p); exit(2); } b[*n] = 0; fclose(f); return b;
}

#define NKERN 14
static const char* NAMES[NKERN] = { "matmul", "matmul64", "rmsnorm", "rope", "embedding",
    "swiglu", "attention_scores", "softmax_causal", "matvec32", "matvec64",
    "matvecw32", "matvecsim", "matvecsim64", "matvecsplit" };

static cl_mem buf(void* host, size_t bytes) {
    cl_int rc; cl_mem m = p_clCreateBuffer(ctx, CL_MEM_READ_WRITE | (host ? CL_MEM_COPY_HOST_PTR : 0), bytes, host, &rc);
    if (rc) { fprintf(stderr, "clCreateBuffer rc=%ld\n", (long)rc); exit(2); } return m;
}
static void readback(cl_mem m, void* dst, size_t bytes) {
    p_clEnqueueReadBuffer(q, m, CL_TRUE, 0, bytes, dst, 0, NULL, NULL); p_clFinish(q);
}

typedef struct { const char* name; cl_kernel k; } Kern;
static Kern kerns[NKERN];
static void run2(cl_kernel k, size_t gx, size_t gy, size_t lx, size_t ly) {
    size_t g[2] = { gx, gy }, l[2] = { lx, ly };
    cl_int rc = p_clEnqueueNDRangeKernel(q, k, 2, NULL, g, l, 0, NULL, NULL);
    if (rc) { fprintf(stderr, "ndrange rc=%d\n", (int)rc); exit(2); } p_clFinish(q);
}
static void run1(cl_kernel k, size_t gx, size_t lx) {
    size_t g[1] = { gx }, l[1] = { lx };
    cl_int rc = p_clEnqueueNDRangeKernel(q, k, 1, NULL, g, l, 0, NULL, NULL);
    if (rc) { fprintf(stderr, "ndrange rc=%d\n", (int)rc); exit(2); } p_clFinish(q);
}
static void chk(const char* what, long got, long want) {
    checks++;
    if (got != want) { fails++; printf("FAIL %-28s got=%ld want=%ld\n", what, got, want); }
}

// ─── referencias C (mesma aritmética inteira dos .cl) ───
static int ipowS(int x, int n) { int r = 1000; for (int k = 0; k < n; k++) r = (r * x) / 1000; return r; }
static int sinM(int th) { return th - ipowS(th, 3) / 6 + ipowS(th, 5) / 120 - ipowS(th, 7) / 5040; }
static int cosM(int th) { return 1000 - ipowS(th, 2) / 2 + ipowS(th, 4) / 24 - ipowS(th, 6) / 720; }
static int expA(int zm) { if (zm > 7000) zm = 7000; if (zm < -7000) zm = -7000; int t = 1000, s = 1000; for (int n = 1; n <= 8; n++) { t = (t * zm) / (1000 * n); s += t; if (t == 0) break; } return s; }
static int sigM(int x) { int e = expA(-x); return 1000000 / (1000 + (e > 1 ? e : 1)); }
static int expASc(int zm) { if (zm > 7000) zm = 7000; if (zm < -7000) zm = -7000; int term = 1000, sum = 1000; for (int n = 1; n <= 8; n++) { int t = ((term * zm) / 1000) / n; if (t == 0 && zm != 0) break; sum += t; } return sum; }
static long lrnd(long v, long divv) { return v / divv; }
static int lcgg = 12345; static int lcg(void) { lcgg = lcgg * 1103515245 + 12345; return lcgg < 0 ? -lcgg : lcgg % 2000000 - 1000000; }

static long simrecomp(long A, long B, long C, long D, int divId, long divv) {
    if (divId == 0) { long rem = (B % 1000000L) * 1000L + (C % 1000L) * 1000000L + D; return A + B / 1000000L + C / 1000L + rem / divv; }
    if (divId == 1) { long rem = (B % 1000L) * 1000000L + D; return A * 1000L + B / 1000L + C + rem / divv; }
    long rem = (A % 1000L) * 1000000000L + (B % 1000000000L) * 1000L + (C % 1000000L) * 1000000L + D;
    return A / 1000L + B / 1000000000L + C / 1000000L + rem / divv;
}

int main(void) {
    load();
    cl_uint n = 0;
    if (p_clGetPlatformIDs(1, &plat, &n) != CL_SUCCESS || n == 0) {
        printf("SKIP: 0 plataformas OpenCL — instale mesa-opencl-icd (RX 6600/Rusticl) e rode de novo\n");
        return 77;
    }
    p_clGetDeviceIDs(plat, 4 /*GPU*/ | 1|2, 1, &dev, &n);
    if (!n) { fprintf(stderr, "no devices\n"); return 2; }
    cl_int rc;
    ctx = p_clCreateContext(NULL, 1, &dev, NULL, &rc);
    q = p_clCreateCommandQueue(ctx, dev, 0, &rc);
    char* srcs[40]; size_t lens[40]; int cnt = 0;
    for (int i = 0; i < NKERN; i++) {
        char path[256]; snprintf(path, sizeof path, "gpu/kernels/%s.cl", NAMES[i]);
        srcs[cnt] = slurp(path, &lens[cnt]); cnt++;
    }
    prog = p_clCreateProgramWithSource(ctx, cnt, (const char**)srcs, lens, &rc);
    if (p_clBuildProgram(prog, 1, &dev, "-cl-std=CL2.0", NULL, NULL) != CL_SUCCESS) {
        size_t sz; p_clGetProgramBuildInfo(prog, dev, 4096 /*LOG*/, 0, NULL, &sz);
        char* log = malloc(sz + 1); p_clGetProgramBuildInfo(prog, dev, 4096, sz, log, NULL); log[sz] = 0;
        fprintf(stderr, "build fail:\n%s\n", log); return 1;
    }
    for (int i = 0; i < NKERN; i++) { kerns[i].k = p_clCreateKernel(prog, NAMES[i], &rc); kerns[i].name = NAMES[i]; if (!kerns[i].k) { fprintf(stderr, "kernel %s missing\n", NAMES[i]); return 1; } }
    printf("ocl: 14/14 kernels build+resolve\n");

    // matmul 2x2x2
    { int A[4] = { 1000, 2000, 3000, 4000 }, B[4] = { 5000, 6000, 7000, 8000 }, C[4];
      cl_mem a = buf(A, 16), b = buf(B, 16), c = buf(NULL, 16); int M = 2, N = 2, K = 2;
      cl_kernel k = kerns[0].k; p_clSetKernelArg(k, 0, sizeof a, &a); p_clSetKernelArg(k, 1, sizeof b, &b); p_clSetKernelArg(k, 2, sizeof c, &c);
      p_clSetKernelArg(k, 3, sizeof M, &M); p_clSetKernelArg(k, 4, sizeof N, &N); p_clSetKernelArg(k, 5, sizeof K, &K);
      run2(k, 2, 2, 1, 1); readback(c, C, 16);
      long w[4] = { 19000L, 22000L, 43000L, 50000L };
      for (int i = 0; i < 4; i++) chk("matmul", C[i], w[i]);
    }
    // matmul64 2x2x2 (valores nano-scale)
    { long A[4] = { 2000000, 3000000, -4000000, 5000000 }, B[4] = { 700000000000, -800000000000, 900000000000, 1000000000000 }, C[4];
      cl_mem a = buf(A, 32), b = buf(B, 32), c = buf(NULL, 32); int M = 2, N = 2, K = 2;
      cl_kernel k = kerns[1].k; p_clSetKernelArg(k, 0, sizeof a, &a); p_clSetKernelArg(k, 1, sizeof b, &b); p_clSetKernelArg(k, 2, sizeof c, &c);
      p_clSetKernelArg(k, 3, sizeof M, &M); p_clSetKernelArg(k, 4, sizeof N, &N); p_clSetKernelArg(k, 5, sizeof K, &K);
      run2(k, 2, 2, 1, 1); readback(c, C, 32);
      long w[4] = { 2000000L * 700000000000L + 3000000L * 900000000000L, 2000000L * -800000000000L + 3000000L * 1000000000000L,
                    -4000000L * 700000000000L + 5000000L * 900000000000L, -4000000L * -800000000000L + 5000000L * 1000000000000L };
      for (int i = 0; i < 4; i++) chk("matmul64", C[i], w[i]);
    }
    // rmsnorm 1x4
    { int x[4] = { 1000, 2000, -1500, 500 }, g[4] = { 1000, 1000, 1000, 1000 }, y[4];
      int ss = 0; for (int j = 0; j < 4; j++) ss += (x[j] * x[j]) / 1000;
      int mean = ss / 4, tgt = mean * 1000, guess = tgt / 2 > 1 ? tgt / 2 : 1;
      for (int it = 0; it < 24; it++) { int nx = (tgt / (guess > 1 ? guess : 1) + guess) / 2; if (nx >= guess) break; guess = nx; }
      int rms = guess > 1 ? guess : 1;
      cl_mem bx = buf(x, 16), bg = buf(g, 16), by = buf(NULL, 16); int S = 1, C = 4, row = 0, eps = 1;
      cl_kernel k = kerns[2].k; p_clSetKernelArg(k, 0, sizeof bx, &bx); p_clSetKernelArg(k, 1, sizeof bg, &bg); p_clSetKernelArg(k, 2, sizeof by, &by);
      p_clSetKernelArg(k, 3, sizeof S, &S); p_clSetKernelArg(k, 4, sizeof C, &C); p_clSetKernelArg(k, 5, sizeof row, &row); p_clSetKernelArg(k, 6, sizeof eps, &eps);
      run1(k, 1, 1); readback(by, y, 16);
      for (int j = 0; j < 4; j++) { int want = (x[j] * 1000 / rms) * g[j] / 1000; chk("rmsnorm", y[j], want); }
    }
    // rope 1x2
    { int qk[2] = { 1000, 500 }, fr[1] = { 500 }; int want0, want1;
      int th = 1 * 500; if (th > 3141) th = 3141;
      int cs = cosM(th), sn = sinM(th);
      want0 = (qk[0] * cs - qk[1] * sn) / 1000; want1 = (qk[0] * sn + qk[1] * cs) / 1000;
      cl_mem bq = buf(qk, 8), bf = buf(fr, 4); int S = 1, C = 2, row = 0, ma = 3141;
      cl_kernel k = kerns[3].k; p_clSetKernelArg(k, 0, sizeof bq, &bq); p_clSetKernelArg(k, 1, sizeof bf, &bf);
      p_clSetKernelArg(k, 2, sizeof S, &S); p_clSetKernelArg(k, 3, sizeof C, &C); p_clSetKernelArg(k, 4, sizeof row, &row); p_clSetKernelArg(k, 5, sizeof ma, &ma);
      run1(k, 1, 1); int out[2]; readback(bq, out, 8);
      chk("rope.0", out[0], want0); chk("rope.1", out[1], want1);
    }
    // embedding wrap
    { int tbl[12]; for (int i = 0; i < 12; i++) tbl[i] = i * 7; int emb[4];
      cl_mem bt = buf(tbl, 48), be = buf(NULL, 16); int V = 3, C = 4, tid = -1;
      cl_kernel k = kerns[4].k; p_clSetKernelArg(k, 0, sizeof bt, &bt); p_clSetKernelArg(k, 1, sizeof be, &be);
      p_clSetKernelArg(k, 2, sizeof V, &V); p_clSetKernelArg(k, 3, sizeof C, &C); p_clSetKernelArg(k, 4, sizeof tid, &tid);
      run1(k, 4, 4); readback(be, emb, 16);
      int row = -1 % 3; if (row < 0) row += 3;
      for (int j = 0; j < 4; j++) chk("embedding", emb[j], tbl[row * 4 + j]);
    }
    // swiglu 4 canais
    { int gate[4] = { 1000, -1000, 0, 500 }, up[4] = { 2000, 2000, 2000, 2000 }, y[4];
      cl_mem bg = buf(gate, 16), bu = buf(up, 16), by = buf(NULL, 16); int C = 4;
      cl_kernel k = kerns[5].k; p_clSetKernelArg(k, 0, sizeof bg, &bg); p_clSetKernelArg(k, 1, sizeof bu, &bu); p_clSetKernelArg(k, 2, sizeof by, &by); p_clSetKernelArg(k, 3, sizeof C, &C);
      run1(k, 4, 4); readback(by, y, 16);
      for (int j = 0; j < 4; j++) { int sig = sigM(gate[j]); chk("swiglu", y[j], (gate[j] * sig / 1000) * up[j] / 1000); }
    }
    // attention_scores causal 3x3
    { int q[6] = { 10, 20, 30, 40, 50, 60 }, kk[6] = { 1, 2, 3, 4, 5, 6 }, s[9];
      cl_mem bq = buf(q, 24), bk = buf(kk, 24), bs = buf(NULL, 36); int S = 3, D = 2, sc = 500, cz = 1;
      cl_kernel k = kerns[6].k; p_clSetKernelArg(k, 0, sizeof bq, &bq); p_clSetKernelArg(k, 1, sizeof bk, &bk); p_clSetKernelArg(k, 2, sizeof bs, &bs);
      p_clSetKernelArg(k, 3, sizeof S, &S); p_clSetKernelArg(k, 4, sizeof D, &D); p_clSetKernelArg(k, 5, sizeof sc, &sc); p_clSetKernelArg(k, 6, sizeof cz, &cz);
      run2(k, 3, 3, 1, 1); readback(bs, s, 36);
      for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) {
          long w;
          if (j > i) w = -2147483647L;
          else { w = (long)(q[i * 2] * kk[j * 2] + q[i * 2 + 1] * kk[j * 2 + 1]) * sc / 1000; }
          chk("attn", s[i * 3 + j], w);
      }
    }
    // softmax_causal 3x3
    { int xs[9] = { 1000, -500, 700, 200, 900, -100, 400, 300, 800 }, ys[9];
      cl_mem bx = buf(xs, 36), by = buf(NULL, 36); int S = 3;
      cl_kernel k = kerns[7].k; p_clSetKernelArg(k, 0, sizeof bx, &bx); p_clSetKernelArg(k, 1, sizeof by, &by); p_clSetKernelArg(k, 2, sizeof S, &S);
      for (int row = 0; row < 3; row++) { p_clSetKernelArg(k, 3, sizeof row, &row); run1(k, 64, 64); }
      readback(by, ys, 36);
      for (int row = 0; row < 3; row++) {
          int maxv = -2147483647;
          for (int j = 0; j < 3; j++) { int v = j > row ? -2147483647 : xs[row * 3 + j]; if (v > maxv) maxv = v; }
          int denom = 0;
          for (int j = 0; j < 3; j++) { int v = j > row ? -2147483647 : xs[row * 3 + j]; denom += expASc(v - maxv); }
          if (denom <= 0) denom = 1;
          for (int j = 0; j < 3; j++) { int v = j > row ? -2147483647 : xs[row * 3 + j]; int e = expASc(v - maxv);
              chk("softmax", ys[row * 3 + j], (e / denom) * 1000 + (e % denom) * 1000 / denom); }
      }
    }
    // matvec32 m=2 k=130 (strided reduce)
    { int w[260], x[130], y[2]; for (int i = 0; i < 260; i++) w[i] = lcg() / 4; for (int i = 0; i < 130; i++) x[i] = lcg() / 8;
      long exp0 = 0, exp1 = 0; for (int c = 0; c < 130; c++) { exp0 += (long)w[c] * x[c]; exp1 += (long)w[130 + c] * x[c]; }
      cl_mem bw = buf(w, 1040), bx = buf(x, 520), by = buf(NULL, 8); int m = 2, kdim = 130; long dv = 1000;
      cl_kernel kk = kerns[8].k; p_clSetKernelArg(kk, 0, sizeof bw, &bw); p_clSetKernelArg(kk, 1, sizeof bx, &bx); p_clSetKernelArg(kk, 2, sizeof by, &by);
      p_clSetKernelArg(kk, 3, sizeof m, &m); p_clSetKernelArg(kk, 4, sizeof kdim, &kdim); p_clSetKernelArg(kk, 5, sizeof dv, &dv);
      run1(kk, 2 * 64, 64); readback(by, y, 8);
      chk("matvec32.0", y[0], lrnd(exp0, 1000)); chk("matvec32.1", y[1], lrnd(exp1, 1000));
    }
    // matvec64 m=2 k=130
    { long w[260], x[130], y[2]; for (int i = 0; i < 260; i++) w[i] = lcg() * 1000L; for (int i = 0; i < 130; i++) x[i] = lcg() * 10L;
      long e0 = 0, e1 = 0; for (int c = 0; c < 130; c++) { e0 += w[c] * x[c]; e1 += w[130 + c] * x[c]; }
      cl_mem bw = buf(w, 2080), bx = buf(x, 1040), by = buf(NULL, 16); int m = 2, kdim = 130;
      cl_kernel kk = kerns[9].k; p_clSetKernelArg(kk, 0, sizeof bw, &bw); p_clSetKernelArg(kk, 1, sizeof bx, &bx); p_clSetKernelArg(kk, 2, sizeof by, &by);
      p_clSetKernelArg(kk, 3, sizeof m, &m); p_clSetKernelArg(kk, 4, sizeof kdim, &kdim);
      run1(kk, 2 * 64, 64); readback(by, y, 16);
      chk("matvec64.0", y[0], e0); chk("matvec64.1", y[1], e1);
    }
    // matvecw32 m=2 k=130 div 1e9
    { int w[260]; long x[130], y[2]; for (int i = 0; i < 260; i++) w[i] = lcg(); for (int i = 0; i < 130; i++) x[i] = lcg() * 100L;
      long e0 = 0, e1 = 0; for (int c = 0; c < 130; c++) { e0 += (long)w[c] * x[c]; e1 += (long)w[130 + c] * x[c]; }
      cl_mem bw = buf(w, 1040), bx = buf(x, 1040), by = buf(NULL, 16); int m = 2, kdim = 130; long dv = 1000000000L;
      cl_kernel kk = kerns[10].k; p_clSetKernelArg(kk, 0, sizeof bw, &bw); p_clSetKernelArg(kk, 1, sizeof bx, &bx); p_clSetKernelArg(kk, 2, sizeof by, &by);
      p_clSetKernelArg(kk, 3, sizeof m, &m); p_clSetKernelArg(kk, 4, sizeof kdim, &kdim); p_clSetKernelArg(kk, 5, sizeof dv, &dv);
      run1(kk, 2 * 64, 64); readback(by, y, 16);
      chk("matvecw32.0", y[0], lrnd(e0, dv)); chk("matvecw32.1", y[1], lrnd(e1, dv));
    }
    // matvecsim m=2 k=130, 3 divIds
    for (int divId = 0; divId < 3; divId++) {
        int w[260]; long x[130], y[2]; for (int i = 0; i < 260; i++) w[i] = lcg(); for (int i = 0; i < 130; i++) x[i] = lcg() * 1000L;
        long A = 0, B = 0, Cc = 0, D = 0, A1 = 0, B1 = 0, C1 = 0, D1 = 0;
        for (int i = 0; i < 130; i++) {
            long wv = w[i], xv = x[i]; long wh = wv / 1000, wl = wv % 1000, xh = xv / 1000000, xl = xv % 1000000;
            A += wh * xh; B += wh * xl; Cc += wl * xh; D += wl * xl;
            wv = w[130 + i]; wh = wv / 1000; wl = wv % 1000;
            A1 += wh * xh; B1 += wh * xl; C1 += wl * xh; D1 += wl * xl;
        }
        long dv = divId == 0 ? 1000000000L : (divId == 1 ? 1000000L : 1000000000000L);
        cl_mem bw = buf(w, 1040), bx = buf(x, 1040), by = buf(NULL, 16); int m = 2, kdim = 130, di = divId;
        cl_kernel kk = kerns[11].k; p_clSetKernelArg(kk, 0, sizeof bw, &bw); p_clSetKernelArg(kk, 1, sizeof bx, &bx); p_clSetKernelArg(kk, 2, sizeof by, &by);
        p_clSetKernelArg(kk, 3, sizeof m, &m); p_clSetKernelArg(kk, 4, sizeof kdim, &kdim); p_clSetKernelArg(kk, 5, sizeof di, &di); p_clSetKernelArg(kk, 6, sizeof dv, &dv);
        run1(kk, 2 * 64, 64); readback(by, y, 16);
        char nm[32]; snprintf(nm, sizeof nm, "matvecsim.d%d.0", divId); chk(nm, y[0], simrecomp(A, B, Cc, D, divId, dv));
        snprintf(nm, sizeof nm, "matvecsim.d%d.1", divId); chk(nm, y[1], simrecomp(A1, B1, C1, D1, divId, dv));
    }
    // matvecsim64 m=2 k=130 divId 2
    { long w[260], x[130], y[2]; for (int i = 0; i < 260; i++) w[i] = lcg() * 100L; for (int i = 0; i < 130; i++) x[i] = lcg() * 1000L;
      long A = 0, B = 0, Cc = 0, D = 0, A1 = 0, B1 = 0, C1 = 0, D1 = 0;
      for (int i = 0; i < 130; i++) {
          long wv = w[i], xv = x[i], wh = wv / 1000, wl = wv % 1000, xh = xv / 1000000, xl = xv % 1000000;
          A += wh * xh; B += wh * xl; Cc += wl * xh; D += wl * xl;
          wv = w[130 + i]; wh = wv / 1000; wl = wv % 1000;
          A1 += wh * xh; B1 += wh * xl; C1 += wl * xh; D1 += wl * xl;
      }
      long dv = 1000000000000L; int m = 2, kdim = 130, di = 2;
      cl_mem bw = buf(w, 2080), bx = buf(x, 1040), by = buf(NULL, 16);
      cl_kernel kk = kerns[12].k; p_clSetKernelArg(kk, 0, sizeof bw, &bw); p_clSetKernelArg(kk, 1, sizeof bx, &bx); p_clSetKernelArg(kk, 2, sizeof by, &by);
      p_clSetKernelArg(kk, 3, sizeof m, &m); p_clSetKernelArg(kk, 4, sizeof kdim, &kdim); p_clSetKernelArg(kk, 5, sizeof di, &di); p_clSetKernelArg(kk, 6, sizeof dv, &dv);
      run1(kk, 2 * 64, 64); readback(by, y, 16);
      chk("matvecsim64.0", y[0], simrecomp(A, B, Cc, D, 2, dv)); chk("matvecsim64.1", y[1], simrecomp(A1, B1, C1, D1, 2, dv));
    }
    // matvecsplit m=2 k=130 divId 0 (pre-split no host, como no warm)
    { int w[260]; long x[130]; int wh[260], wl[260], xh[130], xl[130]; long y[2];
      for (int i = 0; i < 260; i++) { w[i] = lcg(); } for (int i = 0; i < 130; i++) { x[i] = lcg() * 1000L; }
      long A = 0, B = 0, Cc = 0, D = 0, A1 = 0, B1 = 0, C1 = 0, D1 = 0;
      for (int i = 0; i < 260; i++) { wh[i] = (int)(w[i] / 1000); wl[i] = (int)(w[i] % 1000); }
      for (int i = 0; i < 130; i++) { xh[i] = (int)(x[i] / 1000000); xl[i] = (int)(x[i] % 1000000); }
      for (int i = 0; i < 130; i++) {
          A += (long)wh[i] * xh[i]; B += (long)wh[i] * xl[i]; Cc += (long)wl[i] * xh[i]; D += (long)wl[i] * xl[i];
          A1 += (long)wh[130 + i] * xh[i]; B1 += (long)wh[130 + i] * xl[i]; C1 += (long)wl[130 + i] * xh[i]; D1 += (long)wl[130 + i] * xl[i];
      }
      long dv = 1000000000L; int m = 2, kdim = 130, di = 0;
      cl_mem bwh = buf(wh, 1040), bwl = buf(wl, 1040), bxh = buf(xh, 520), bxl = buf(xl, 520), by = buf(NULL, 16);
      cl_kernel kk = kerns[13].k; p_clSetKernelArg(kk, 0, sizeof bwh, &bwh); p_clSetKernelArg(kk, 1, sizeof bwl, &bwl); p_clSetKernelArg(kk, 2, sizeof bxh, &bxh); p_clSetKernelArg(kk, 3, sizeof bxl, &bxl); p_clSetKernelArg(kk, 4, sizeof by, &by);
      p_clSetKernelArg(kk, 5, sizeof m, &m); p_clSetKernelArg(kk, 6, sizeof kdim, &kdim); p_clSetKernelArg(kk, 7, sizeof di, &di); p_clSetKernelArg(kk, 8, sizeof dv, &dv);
      run1(kk, 2 * 64, 64); readback(by, y, 16);
      chk("matvecsplit.0", y[0], simrecomp(A, B, Cc, D, 0, dv)); chk("matvecsplit.1", y[1], simrecomp(A1, B1, C1, D1, 0, dv));
    }
    printf("ocl checks: %d, falhas: %d\n", checks, fails);
    return fails ? 1 : 0;
}
