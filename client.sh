#!/bin/bash
# Usage: client.sh sglang
# Usage: client.sh vllm
backend=$1

CON="1 2 4 8 16 32 64 128"
ISL_OSL=("3200:800")
date=$(date +"%Y-%m-%d")
LOG="temp"
LOG_sum="benchmark_${backend}_${date}"

printf "%-15s" prompts                 2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" isl                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" osl                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" con                     2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" req_throughput          2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_e2e              2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_ttft             2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_tpot             2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" median_itl              2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" out_throughput          2>&1 | tee -a ${LOG_sum}.log
printf "%-15s" tot_throughput          2>&1 | tee -a ${LOG_sum}.log
printf "\n"                            2>&1 | tee -a ${LOG_sum}.log

for in_out in ${ISL_OSL[@]}
do
    isl=$(echo $in_out | awk -F':' '{ print $1 }')
    osl=$(echo $in_out | awk -F':' '{ print $2 }')
    for con in $CON; do
        if [ $con -lt 16 ]; then
            prompts=50
        else
            prompts=500
        fi

	if [ $backend == "sglang" ]; then
	    CMD="python3 -m sglang.bench_serving"
	elif [ $backend == "vllm" ]; then
	    CMD="python3 /app/vllm/benchmarks/benchmark_serving.py"
	else
	    echo "unsupported llm backend"
	fi


        echo "[RUNNING] prompts $prompts isl $isl osl $osl con $con"
	    $CMD \
            --backend $backend \
            --dataset-name random \
            --random-range-ratio 1 \
            --num-prompt $prompts \
            --random-input $isl \
            --random-output $osl \
            --max-concurrency $con \
            2>&1 | tee ${LOG}.log

        rTh=$(grep -E "Request throughput" ${LOG}.log)
        e2eLat=$(grep -E "Median E2E Latency" ${LOG}.log)
        ttftLat=$(grep -E "Median TTFT" ${LOG}.log)
        tpotLat=$(grep -E "Median TPOT" ${LOG}.log)
        itlLat=$(grep -E "Median ITL" ${LOG}.log)
        oTh=$(grep -E "Output token throughput" ${LOG}.log)
        tTh=$(grep -E "Total token throughput" ${LOG}.log)

        rTh_sp=(${rTh//:/ })
        e2eLat_sp=(${e2eLat//:/ })
        ttftLat_sp=(${ttftLat//:/ })
        tpotLat_sp=(${tpotLat//:/ })
        itlLat_sp=(${itlLat//:/ })
        oTh_sp=(${oTh//:/ })
        tTh_sp=(${tTh//:/ })

        rTh_val=${rTh_sp[3]}
        e2eLat_val=${e2eLat_sp[4]}
        ttftLat_val=${ttftLat_sp[3]}
        tpotLat_val=${tpotLat_sp[3]}
        itlLat_val=${itlLat_sp[3]}
        oTh_sp_val=${oTh_sp[4]}
        tTh_sp_val=${tTh_sp[4]}

        printf "%-15s" $prompts        2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $isl            2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $osl            2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $con            2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $rTh_val        2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $e2eLat_val     2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $ttftLat_val    2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $tpotLat_val    2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $itlLat_val     2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $oTh_sp_val     2>&1 | tee -a ${LOG_sum}.log
        printf "%-15s" $tTh_sp_val     2>&1 | tee -a ${LOG_sum}.log
        printf "\n"                    2>&1 | tee -a ${LOG_sum}.log
    done
done
