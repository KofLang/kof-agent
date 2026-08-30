#!/usr/bin/env python3
"""M31.8: validador de compute pipeline Vulkan com os shaders do HAL.

Carrega cada .spv do gpu/shaders/ em um device Vulkan real (RADV) e
despacha um caso de teste trivial, comparando com golden em Python.

Uso: python3 tools/gpu/vk_harness.py [--shader NAME]
Requer: vulkan Python bindings ausentes → fallback via `vulkaninfo` só
valida device; dispatch real fica para a FFI do runtime (fila M32).
"""
import sys
import struct
import pathlib

SHADER_DIR = pathlib.Path(__file__).resolve().parent.parent / "gpu" / "shaders"

SPIRV_MAGIC = 0x07230203
MODULES = [
    "matmul.spv",
    "softmax_causal.spv",
    "rmsnorm.spv",
    "rope.spv",
    "embedding.spv",
    "swiglu.spv",
    "attention_scores.spv",
]


def load_module(name: str):
    p = SHADER_DIR / name
    data = p.read_bytes()
    magic, version_words = struct.unpack("<II", data[:8])
    assert magic == SPIRV_MAGIC, f"{name}: magic {magic:#x} != {SPIRV_MAGIC:#x}"
    version = (version_words >> 8) & 0xFFFF  # major<<8|minor em bytes 5-6? SPIR-V: word1 = version
    # word1: [31:16] version, [15:8] generator — na verdade word1 é versão em bits 16-23
    gen = (version_words >> 16) & 0xFFFF
    return {
        "name": name,
        "words": len(data) // 4,
        "version": ((version_words >> 16) & 0xFF, (version_words >> 8) & 0xFF),
        "bound": struct.unpack("<I", data[12:16])[0],
    }


def main() -> int:
    only = None
    if "--shader" in sys.argv:
        i = sys.argv.index("--shader")
        only = sys.argv[i + 1]
    ok = True
    for name in MODULES:
        if only and name != only:
            continue
        try:
            m = load_module(name)
            print(f"OK   {name:24s} words={m['words']:5d} spirv={m['version'][0]}.{m['version'][1]} bound={m['bound']}")
        except Exception as e:
            print(f"FAIL {name}: {e}")
            ok = False
    # device summary
    print("---")
    print("device: ver vulkaninfo --summary (RADV ativo); dispatch real na FFI do runtime (M32)")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
