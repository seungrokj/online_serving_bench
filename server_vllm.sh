export VLLM_MLA_DISABLE=0
export VLLM_USE_TRITON_FLASH_ATTN=1
export VLLM_USE_ROCM_FP8_FLASH_ATTN=0
export VLLM_FP8_PADDING=1
hf_model=deepseek-ai/DeepSeek-V3
vllm serve $hf_model \
            --tensor-parallel-size 8  \
            --gpu-memory-utilization 0.95 \
            --disable-log-requests \
            --trust-remote-code \
            --max-model-len 32768 \
	    --max-num-batched-tokens 32768 \
            --swap-space 16 \
            --num_scheduler-steps 1
