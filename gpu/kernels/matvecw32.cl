// OpenCL port de gpu/shaders/matvecw32.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void matvecw32(__global const int* restrict w, __global const long* restrict x, __global long* restrict y, int m, int k, long divv) {
    int row = get_group_id(0);
    int tid = get_local_id(0);
    __local long red[64];
    if (row >= m) { return; }
    int off = row * k;
    long part = 0;
    for (int c = tid; c < k; c += 64) {
        part += (long)w[off + c] * x[c];
    }
    red[tid] = part;
    barrier(CLK_LOCAL_MEM_FENCE);
    for (int s = 32; s > 0; s >>= 1) {
        if (tid < s) { red[tid] += red[tid + s]; }
        barrier(CLK_LOCAL_MEM_FENCE);
    }
    if (tid == 0) { y[row] = red[0] / divv; }
}
