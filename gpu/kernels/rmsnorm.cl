// OpenCL port de gpu/shaders/rmsnorm.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
__kernel void rmsnorm(__global const int* restrict x, __global const int* restrict g, __global int* restrict y, int S, int C, int row, int epsMilli) {
    if ((int)get_global_id(0) != row || row >= S) { return; }
    int ss = 0;
    for (int j = 0; j < C; j++) {
        int v = x[row * C + j];
        ss += (v * v) / 1000;
    }
    int meanSq = ss / max(C, 1);
    int target = meanSq * 1000;
    int guess = max(target / 2, 1);
    for (int it = 0; it < 24; it++) {
        int next = (target / max(guess, 1) + guess) / 2;
        if (next >= guess) { break; }
        guess = next;
    }
    int rms = max(guess, epsMilli);
    for (int j = 0; j < C; j++) {
        int v = x[row * C + j];
        y[row * C + j] = (v * 1000 / rms) * g[j] / 1000;
    }
}
