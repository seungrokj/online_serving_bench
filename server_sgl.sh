export DEBUG_HIP_BLOCK_SYN=1024 
export GPU_FORCE_BLIT_COPY_SIZE=64 
export SGLANG_ROCM_FUSED_DECODE_MLA=1 
export RCCL_MSCCL_ENABLE=0 
export CK_MOE=1 
hf_model=deepseek-ai/DeepSeek-V3
python3 -m sglang.launch_server \
	--model $hf_model \
	--trust-remote-code \
	--tp 8 \
	--mem-fraction-static 0.95 \
	--disable-radix-cache 
