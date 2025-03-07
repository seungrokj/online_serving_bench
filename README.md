# online_serving_bench

## SGL
### Launch sglang container
```bash
docker pull lmsysorg/sglang:v0.4.3.post2-rocm630

docker run -it --device=/dev/kfd --device=/dev/dri --group-add video --shm-size 16G --security-opt seccomp=unconfined --security-opt apparmor=unconfined --cap-add=SYS_PTRACE -v $(pwd):/workspace --env HUGGINGFACE_HUB_CACHE=/workspace --name sglang_test lmsysorg/sglang:v0.4.3.post2-rocm630

cd /workspace
```

### Launch sglang server
```bash
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
```

### Access from a client
```bash
./client.sh sglang
```

## vLLM
### Launch vllm container
```bash
docker pull rocm/vllm-dev:main

docker run -it --device=/dev/kfd --device=/dev/dri --group-add video --shm-size 16G --security-opt seccomp=unconfined --security-opt apparmor=unconfined --cap-add=SYS_PTRACE -v $(pwd):/workspace --env HUGGINGFACE_HUB_CACHE=/workspace --name vllm_test rocm/vllm-dev:main

cd /workspace
```

### Launch sglang server
```bash
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
```

### Access from a client
```bash
./client.sh vllm
```
