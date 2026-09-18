// OpenCL port de gpu/shaders/softmax_causal.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
static int termMul(int prev, int zm, int n) {
    int q = (prev * zm) / 1000;
    return q / n;
}
static int expApproxSc(int zm) {
    if (zm > 7000) { zm = 7000; }
    if (zm < -7000) { zm = -7000; }
    int sum = 1000;
    int term = 1000;
    for (int n = 1; n <= 8; n++) {
        int t = termMul(term, zm, n);
        if (t == 0 && zm != 0) { break; }
        sum += t;
    }
    return sum;
}
__kernel void softmax_causal(__global const int* restrict x, __global int* restrict y, int S, int row) {
    if ((int)get_global_id(0) != row || row >= S) { return; }
    int maxv = -2147483647;
    for (int j = 0; j < S; j++) {
        int v = (j > row) ? -2147483647 : x[row * S + j];
        if (v > maxv) { maxv = v; }
    }
    int denom = 0;
    for (int j = 0; j < S; j++) {
        int v = (j > row) ? -2147483647 : x[row * S + j];
        denom += expApproxSc(v - maxv);
    }
    if (denom <= 0) { denom = 1; }
    for (int j = 0; j < S; j++) {
        int v = (j > row) ? -2147483647 : x[row * S + j];
        int e = expApproxSc(v - maxv);
        y[row * S + j] = (e / denom) * 1000 + (e % denom) * 1000 / denom;
    }
}
