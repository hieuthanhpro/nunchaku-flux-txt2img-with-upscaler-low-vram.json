FROM runpod/worker-comfyui:5.5.1-base

# Debug env (có thể bỏ sau khi ổn)
RUN python -VV && pip -V && python -c "import torch; print('torch', torch.__version__)"

# Git cho custom nodes
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# 1) Cài nunchaku python wheel (BẮT BUỘC, khớp py312 + torch2.11)
RUN pip install --no-cache-dir \
  https://github.com/nunchaku-tech/nunchaku/releases/download/v1.2.0/nunchaku-1.2.0+torch2.11-cp312-cp312-linux_x86_64.whl

# 2) Cài ComfyUI-nunchaku đúng PATH ComfyUI đang chạy
RUN mkdir -p /comfyui/custom_nodes && \
    cd /comfyui/custom_nodes && \
    git clone https://github.com/nunchaku-tech/ComfyUI-nunchaku.git

# (optional) nếu repo có requirements thì cài
RUN if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI-nunchaku/requirements.txt ]; then \
      pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-nunchaku/requirements.txt ; \
    fi

# Các custom nodes khác
RUN comfy node install --exit-on-fail comfyui-easy-use@1.3.5 --mode remote
RUN comfy node install --exit-on-fail ComfyUI-TiledDiffusion

# ❌ BỎ dòng này để tránh cài chồng
# RUN comfy node install --exit-on-fail ComfyUI-nunchaku@1.2.0

# Models
RUN comfy model download --url https://huggingface.co/gemasai/4x_NMKD-Siax_200k/resolve/main/4x_NMKD-Siax_200k.pth --relative-path models/upscale_models --filename 4x_NMKD-Siax_200k.pth
RUN comfy model download --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors --relative-path models/vae --filename ae.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors --relative-path models/clip --filename clip_l.safetensors
RUN comfy model download --url https://huggingface.co/mit-han-lab/nunchaku-t5/resolve/main/awq-int4-flux.1-t5xxl.safetensors --relative-path models/text_encoders --filename awq-int4-flux.1-t5xxl.safetensors
RUN comfy model download --url https://huggingface.co/mit-han-lab/nunchaku-flux.1-dev/resolve/main/svdq-int4_r32-flux.1-dev.safetensors --relative-path models/diffusion_models --filename svdq-int4_r32-flux.1-dev.safetensors
