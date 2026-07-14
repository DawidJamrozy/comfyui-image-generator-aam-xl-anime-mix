# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG HF_TOKEN=""
ARG CIVITAI_API_KEY=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-impact-pack@8.28.3 --mode remote || (echo "WARN: comfyui-impact-pack@8.28.3 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-impact-pack --mode remote)
RUN comfy node install --exit-on-fail was-ns@3.0.1 || (echo "WARN: was-ns@3.0.1 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail was-ns)
RUN comfy node install --exit-on-fail comfyui-impact-subpack@1.3.5 || (echo "WARN: comfyui-impact-subpack@1.3.5 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui-impact-subpack)
RUN comfy node install --exit-on-fail comfyui_controlnet_aux@1.1.5 || (echo "WARN: comfyui_controlnet_aux@1.1.5 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail comfyui_controlnet_aux)
RUN comfy node install --exit-on-fail rgthree-comfy@1.0.2605082257 || (echo "WARN: rgthree-comfy@1.0.2605082257 unavailable in registry, falling back to latest" >&2 && comfy node install --exit-on-fail rgthree-comfy)

# download models into comfyui
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov8s.pt' --relative-path models/ultralytics --filename 'bbox/hand_yolov8s.pt' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/8x_NMKD-Superscale_150000_G.pth' --relative-path models/upscale_models --filename '8x_NMKD-Superscale_150000_G.pth' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="60 300 900 1800 3600" && for i in 1 2 3 4 5; do CIVITAI_API_KEY=$CIVITAI_API_KEY comfy model download --url 'https://civitai.com/api/download/models/303526?fileId=239564' --relative-path models/checkpoints --filename 'AAM_XL_Anime_Mix.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
RUN BACKOFFS="10 20 30 60 90" && for i in 1 2 3 4 5; do HF_TOKEN=$HF_TOKEN comfy model download --url 'https://huggingface.co/DawidJamrozy92/sleepcitychar/resolve/main/sleepcitychar_sdxl_v1-step00002000.safetensors' --relative-path models/loras --filename 'sleepcitychar_sdxl_v1-step00002000.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done
