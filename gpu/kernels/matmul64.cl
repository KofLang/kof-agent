// OpenCL port de gpu/shaders/matmul64.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void matmul64(__global const long* restrict a, __global const long* restrict b, __global long* restrict c, int M, int N, int K) {
    int gx = get_global_id(0);
    int gy = get_global_id(1);
    if (gx >= N || gy >= M) { return; }
    long acc = 0;
    for (int k = 0; k < K; k++) {
        acc += a[gy * K + k] * b[k * N + gx];
    }
    c[gy * N + gx] = acc;
}
