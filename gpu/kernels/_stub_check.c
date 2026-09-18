// Syntax-only harness p/ kernels OpenCL sem ICD instalado (gcc -x c).
// Macros de address space viram no-ops; builtins viram funcoes stub.
#define __kernel
#define __global
#define __local
static inline unsigned int get_global_id(int d){ (void)d; return 0; }
static inline unsigned int get_group_id(int d){ (void)d; return 0; }
static inline unsigned int get_local_id(int d){ (void)d; return 0; }
static inline void barrier(int f){ (void)f; }
static inline int max(int a,int b){ return a>b?a:b; }
#define CLK_LOCAL_MEM_FENCE 1
#include "matmul.cl"
#include "matmul64.cl"
#include "rmsnorm.cl"
#include "rope.cl"
#include "embedding.cl"
#include "swiglu.cl"
#include "attention_scores.cl"
#include "softmax_causal.cl"
#include "matvec32.cl"
#include "matvec64.cl"
#include "matvecw32.cl"
#include "matvecsim.cl"
#include "matvecsim64.cl"
#include "matvecsplit.cl"
int main(void) { return 0; }
