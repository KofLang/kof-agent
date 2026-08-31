#!/usr/bin/env bash
# gpu-env.sh — detecção universal de aceleração p/ o ecossistema Kof.
# Máquinas alvo: desktop dedicado (RADV/NVIDIA), híbridos (iGPU+dGPU),
# notebooks sem dGPU (iGPU + llvmpipe), VMs/PC fracos (llvmpipe/CPU puro).
#
# Uso: source scripts/gpu-env.sh
# Exporta: KOF_GPU_BACKEND (vulkan|opengl|cpu), KOF_GPU_NAME,
#          KOF_GPU_DISCRETE (1=dGPU), KOF_VK_ICD, KOF_LLVMPIPE (1=soft),
#          KOF_DATA (dados grandes), KOF_TRAIN_OUT, KOF_HF_HOME.
# NÃO sai com erro: sempre degrada gracefulmente (contrato do backendAutoSelect).

KOF_ROOT="${KOF_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Disco de dados: 1º que existir com >=20G livres (Downloads é disco separado
# no OptiPlex; em máquinas single-disk cai no $HOME/.kof-data)
KOF_DATA=""
for d in "$HOME/Downloads/kof-data" "$HOME/kof-data" "$HOME/.kof-data"; do
  [ -d "$d" ] || mkdir -p "$d" 2>/dev/null
  if [ -d "$d" ] && df --output=avail -BG "$d" 2>/dev/null | tail -1 | grep -qE '[2-9][0-9]G|[0-9]{3,}G'; then
    KOF_DATA="$d"; break
  fi
done
KOF_DATA="${KOF_DATA:-$HOME/.kof-data}"
mkdir -p "$KOF_DATA"/{models,training,build,opencode}
export KOF_DATA KOF_TRAIN_OUT="$KOF_DATA/training" KOF_HF_HOME="$KOF_DATA/hf"

# --- Vulkan: GPU real? ---
KOF_GPU_BACKEND="cpu"; KOF_GPU_NAME="cpu"; KOF_GPU_DISCRETE=0; KOF_LLVMPIPE=0
KOF_VK_ICD=""
if command -v vulkaninfo >/dev/null 2>&1; then
  _vksum="$(vulkaninfo --summary 2>/dev/null)"
  _vdev="$(printf '%s' "$_vksum" | grep -m1 'deviceName' | sed 's/.*= *//')"
  if [ -n "$_vdev" ]; then
    case "$_vdev" in
      *llvmpipe*|*lavapipe*|*SwiftShader*)
        KOF_LLVMPIPE=1; KOF_GPU_BACKEND="cpu"; KOF_GPU_NAME="llvmpipe (software)"
        # ICD de software explícito evita tentativa de dispatch em device morto
        for icd in /usr/share/vulkan/icd.d/lvp_icd.*.json; do [ -f "$icd" ] && KOF_VK_ICD="$icd"; done
        ;;
      *NVIDIA*)  KOF_GPU_BACKEND="vulkan"; KOF_GPU_NAME="$_vdev"; KOF_GPU_DISCRETE=1 ;;
      *AMD*|*RADV*|*Radeon*)
        KOF_GPU_BACKEND="vulkan"; KOF_GPU_NAME="$_vdev"
        # dGPU vs iGPU heurística: polaris/navi/vega/rx = discreta
        echo "$_vdev" | grep -qiE 'radeon rx|radeon pro|radeon (vii|v)|polaris|navi|vega|nacpi' && KOF_GPU_DISCRETE=1
        ;;
      *Intel*)   KOF_GPU_BACKEND="vulkan"; KOF_GPU_NAME="$_vdev" ;;
      *)         KOF_GPU_BACKEND="vulkan"; KOF_GPU_NAME="$_vdev" ;;
    esac
    # ICD do vendor detectado (ordem de preferência; ignora software/VM/irrelevante)
    case "$_vdev" in
      *NVIDIA*) _pref="nvidia_icd" ;;
      *Intel*)  _pref="intel_icd" ;;
      *AMD*|*RADV*|*Radeon*) _pref="radeon_icd" ;;
      *) _pref="" ;;
    esac
    for icd in /usr/share/vulkan/icd.d/*.json; do
      [ -f "$icd" ] || continue
      case "$icd" in *lvp*|*swift*|*asahi*|*gfxstream*|*virtio*|*nouveau_icd*) continue ;; esac
      if [ -n "$_pref" ] && [[ "$icd" == *"$_pref"* ]]; then KOF_VK_ICD="$icd"; break; fi
      KOF_VK_ICD="${KOF_VK_ICD:-$icd}"
    done
  fi
fi

# --- OpenGL fallback (compute via GL quando VK indisponível) ---
if [ "$KOF_GPU_BACKEND" = "cpu" ] && command -v glxinfo >/dev/null 2>&1; then
  _gl="$(glxinfo -B 2>/dev/null | grep -m1 'OpenGL renderer' | sed 's/.*: *//')"
  if [ -n "$_gl" ] && ! echo "$_gl" | grep -qi llvmpipe; then
    KOF_GPU_BACKEND="opengl"; KOF_GPU_NAME="$_gl"
  fi
fi

export KOF_GPU_BACKEND KOF_GPU_NAME KOF_GPU_DISCRETE KOF_LLVMPIPE KOF_VK_ICD

# --- Híbridos: NVIDIA PRIME / switcheroo (só afeta execução de binários GL) ---
if [ "$KOF_GPU_DISCRETE" = "1" ] && command -v switcherooctl >/dev/null 2>&1; then
  export KOF_LAUNCH_PREFIX="$(switcherooctl list 2>/dev/null | grep -qi nvidia && echo '')"
else
  export KOF_LAUNCH_PREFIX=""
fi

# --- Resumo ---
kof_gpu_report() {
  echo "backend=$KOF_GPU_BACKEND gpu=[$KOF_GPU_NAME] dGPU=$KOF_GPU_DISCRETE llvmpipe=$KOF_LLVMPIPE"
  echo "vk_icd=$KOF_VK_ICD"
  echo "data=$KOF_DATA (livre: $(df -h --output=avail "$KOF_DATA" | tail -1 | tr -d ' '))"
}
return 0 2>/dev/null || true
