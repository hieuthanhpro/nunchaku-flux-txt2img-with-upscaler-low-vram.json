# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base
RUN python -VV
RUN pip -V
RUN python -c "import torch; print(torch.__version__)"
# RUN pip install --no-cache-dir \
#   https://github.com/nunchaku-tech/nunchaku/releases/download/v1.2.0/nunchaku-1.2.0+torch2.11-cp312-cp312-linux_x86_64.whl

  # install comfyui-nunchaku custom node (ĐÚNG PATH)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace/ComfyUI/custom_nodes && \
    cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/nunchaku-tech/ComfyUI-nunchaku.git
 
# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
RUN comfy node install --exit-on-fail comfyui-easy-use@1.3.5 --mode remote
RUN comfy node install --exit-on-fail ComfyUI-TiledDiffusion
RUN comfy node install --exit-on-fail ComfyUI-nunchaku@1.2.0
# Could not resolve unknown_registry node 'Label (rgthree)' - no aux_id provided, skipped
# Could not resolve unknown_registry node 'MarkdownNote' - no aux_id provided, skipped
# Could not resolve unknown_registry node 'Label (rgthree)' - no aux_id provided, skipped
# Could not resolve unknown_registry node 'Label (rgthree)' - no aux_id provided, skipped
# Could not resolve unknown_registry node 'Label (rgthree)' - no aux_id provided, skipped
# Could not resolve unknown_registry node 'MarkdownNote' - no aux_id provided, skipped
# Could not resolve unknown_registry node 'Fast Groups Muter (rgthree)' - no aux_id provided, skipped



# download models into comfyui
RUN comfy model download --url https://huggingface.co/gemasai/4x_NMKD-Siax_200k/resolve/main/4x_NMKD-Siax_200k.pth --relative-path models/upscale_models --filename 4x_NMKD-Siax_200k.pth
RUN comfy model download --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors --relative-path models/vae --filename ae.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors --relative-path models/clip --filename clip_l.safetensors
RUN comfy model download --url https://huggingface.co/mit-han-lab/nunchaku-t5/resolve/main/awq-int4-flux.1-t5xxl.safetensors --relative-path models/text_encoders --filename awq-int4-flux.1-t5xxl.safetensors
RUN comfy model download --url https://huggingface.co/mit-han-lab/nunchaku-flux.1-dev/resolve/main/svdq-int4_r32-flux.1-dev.safetensors --relative-path models/diffusion_models --filename svdq-int4_r32-flux.1-dev.safetensors

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
