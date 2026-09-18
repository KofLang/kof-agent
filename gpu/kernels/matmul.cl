// OpenCL port de gpu/shaders/matmul.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void matmul(__global const int* restrict a, __global const int* restrict b, __global int* restrict c, int M, int N, int K) {
    int gx = get_global_id(0);
    int gy = get_global_id(1);
    if (gx >= N || gy >= M) { return; }
    int acc = 0;
    for (int k = 0; k < K; k++) {
        acc += a[gy * K + k] * b[k * N + gx];
    }
    c[gy * N + gx] = acc;
}
