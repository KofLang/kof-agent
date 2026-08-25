# COMPUTE HAL (M11)
DeviceRec(name,kind,priority,available). Prioridade CUDA>ROCm>Vulkan>CPU.
Override via config `hal.backend`. Contratos Buffer/Kernel/Queue/Fence como
records de capacidade v1 (execução real de kernels aguarda FLT/SIMD upstream
— Q2). CPU backend REAL para operações inteiras sobre Int[] (copy/scale/dot).
Eventos: device.detected/backend.selected/fallback.cpu.
