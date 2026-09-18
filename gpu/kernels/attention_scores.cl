// OpenCL port de gpu/shaders/attention_scores.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void attention_scores(__global const int* restrict q, __global const int* restrict k, __global int* restrict s, int S, int D, int scale, int causal) {
    int j = get_global_id(0);
    int i = get_global_id(1);
    if (i >= S || j >= S) { return; }
    if (causal == 1 && j > i) {
        s[i * S + j] = -2147483647;
        return;
    }
    int acc = 0;
    for (int d = 0; d < D; d++) {
        acc += q[i * D + d] * k[j * D + d];
    }
    s[i * S + j] = acc * scale / 1000;
}
