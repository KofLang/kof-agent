// OpenCL port de gpu/shaders/matvecsplit.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void matvecsplit(__global const int* restrict wh, __global const int* restrict wl, __global const int* restrict xh, __global const int* restrict xl, __global long* restrict y, int m, int k, int divId, long divv) {
    int row = get_group_id(0);
    int tid = get_local_id(0);
    __local long redA[64];
    __local long redB[64];
    __local long redC[64];
    __local long redD[64];
    if (row >= m) { return; }
    int off = row * k;
    long a = 0, b = 0, c = 0, d = 0;
    for (int i = tid; i < k; i += 64) {
        a += (long)wh[off + i] * (long)xh[i];
        b += (long)wh[off + i] * (long)xl[i];
        c += (long)wl[off + i] * (long)xh[i];
        d += (long)wl[off + i] * (long)xl[i];
    }
    redA[tid] = a; redB[tid] = b; redC[tid] = c; redD[tid] = d;
    barrier(CLK_LOCAL_MEM_FENCE);
    for (int s = 32; s > 0; s >>= 1) {
        if (tid < s) {
            redA[tid] += redA[tid + s];
            redB[tid] += redB[tid + s];
            redC[tid] += redC[tid + s];
            redD[tid] += redD[tid + s];
        }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (tid == 0) {
        long A = redA[0];
        long B = redB[0];
        long C = redC[0];
        long D = redD[0];
        long outv;
        if (divId == 0) {
            long remT = (B % 1000000L) * 1000L + (C % 1000L) * 1000000L + D;
            outv = A + B / 1000000L + C / 1000L + remT / divv;
        } else if (divId == 1) {
            long remT = (B % 1000L) * 1000000L + D;
            outv = A * 1000L + B / 1000L + C + remT / divv;
        } else {
            long remT = (A % 1000L) * 1000000000L + (B % 1000000000L) * 1000L + (C % 1000000L) * 1000000L + D;
            outv = A / 1000L + B / 1000000000L + C / 1000000L + remT / divv;
        }
        y[row] = outv;
    }
}
