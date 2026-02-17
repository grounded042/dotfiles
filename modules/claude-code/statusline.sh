#!/bin/bash
# Claude Code status line

input=$(cat)

# Context window usage
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

ctx_now=$((input_tokens + output_tokens + cache_read + cache_create))
ctx_max=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Session totals
sess_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
sess_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
sess_total=$((sess_in + sess_out))

# Cost and model
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Format numbers
ctx_pct=$(( 100 * ctx_now / ctx_max ))
ctx_now_k=$((ctx_now / 1000))
ctx_max_k=$((ctx_max / 1000))
sess_k=$((sess_total / 1000))
cost_fmt=$(printf "%.2f" "$cost")

# Colors
G='\033[0;32m' Y='\033[0;33m' R='\033[0;31m' D='\033[0;90m' NC='\033[0m'
if [ "$ctx_pct" -lt 60 ]; then C=$G; elif [ "$ctx_pct" -lt 85 ]; then C=$Y; else C=$R; fi

echo -e "${model} ${D}|${NC} ${C}${ctx_now_k}k/${ctx_max_k}k ${D}(${NC}${ctx_pct}%${D})${NC} ${D}|${NC} ${sess_k}k ${D}|${NC} \$${cost_fmt}"
