// OpenCL port de gpu/shaders/embedding.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void embedding(__global const int* restrict tbl, __global int* restrict emb, int V, int C, int tokenId) {
    int j = get_global_id(0);
    if (j >= C) { return; }
    int row = tokenId % max(V, 1);
    if (row < 0) { row += V; }
    emb[j] = tbl[row * C + j];
}
