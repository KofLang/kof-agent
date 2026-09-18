// OpenCL port de gpu/shaders/rope.comp (E3, specs/ENGINE_V2.md §3.2) — mesma aritmetica inteira, bit-exata.
static int powScaled(int x, int n) {
    int r = 1000;
    for (int k = 0; k < n; k++) { r = (r * x) / 1000; }
    return r;
}
static int sinMilli(int th) {
    int t3 = powScaled(th, 3) / 6;
    int t5 = powScaled(th, 5) / 120;
    int t7 = powScaled(th, 7) / 5040;
    return th - t3 + t5 - t7;
}
static int cosMilli(int th) {
    int t2 = powScaled(th, 2) / 2;
    int t4 = powScaled(th, 4) / 24;
    int t6 = powScaled(th, 6) / 720;
    return 1000 - t2 + t4 - t6;
}
__kernel void rope(__global int* restrict qk, __global const int* restrict freq, int S, int C, int row, int maxAngle) {
    if ((int)get_global_id(0) != row || row >= S) { return; }
    int hh = C / 2;
    for (int i = 0; i < hh; i++) {
        int th = row * freq[i];
        if (th > maxAngle) { th = maxAngle; }
        if (th < -maxAngle) { th = -maxAngle; }
        int cs = cosMilli(th);
        int sn = sinMilli(th);
        int a = qk[row * C + 2 * i];
        int b = qk[row * C + 2 * i + 1];
        qk[row * C + 2 * i] = (a * cs - b * sn) / 1000;
        qk[row * C + 2 * i + 1] = (a * sn + b * cs) / 1000;
    }
}
