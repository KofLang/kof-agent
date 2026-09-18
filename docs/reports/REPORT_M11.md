# Milestone 11 — Universal Compute HAL

Status:

* 🟡 Parcial — HAL v1 com CPU backend REAL (copy/scale/dot sobre Int[]) e
  seleção automática com override por config; CUDA/ROCm/Vulkan registrados
  como devices indisponíveis (contratos prontos; execução real aguarda
  FLT/SIMD upstream Q2 + bindings por backend).

## Resumo
halDetect/halSelect (prioridade, override `hal.backend`), kernels inteiros
CPU (halCopy/halScale/halDot) verdes no Native; eventos device/backend na
spec; zero-copy/pinned/unified documentados como evolução.

## Arquivos
agent/runtime/79_hal.kf · tests/hal_src/unit_hal.kf · tests/hal/*.kf (5 +
MANIFEST) · scripts/test_hal.sh · specs/COMPUTE_HAL.md · REPORT_M11.md

## APIs
halDetect/halSelect/halCopy/halScale/halDot · DeviceRec.

## Testes / Benchmarks
5/5 nativos. Bandwidth/MatMul-FP/Attention/KV: PENDENTES-FLT (Q2).
