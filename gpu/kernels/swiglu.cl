// OpenCL port de gpu/shaders/swiglu.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
static int expApprox(int zm) {
    if (zm > 7000) { zm = 7000; }
    if (zm < -7000) { zm = -7000; }
    int term = 1000;
    int sum = 1000;
    for (int n = 1; n <= 8; n++) {
        term = (term * zm) / (1000 * n);
        sum += term;
        if (term == 0) { break; }
    }
    return sum;
}
static int sigmoidMilli(int x) {
    int e = expApprox(-x);
    return 1000000 / (1000 + max(e, 1));
}
__kernel void swiglu(__global const int* restrict gate, __global const int* restrict up, __global int* restrict y, int C) {
    int j = get_global_id(0);
    if (j >= C) { return; }
    int gv = gate[j];
    int sig = sigmoidMilli(gv);
    y[j] = (gv * sig / 1000) * up[j] / 1000;
}
