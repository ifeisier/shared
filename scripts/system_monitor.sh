#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 清屏
clear

# 显示标题
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    系统资源监控工具                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# 系统基本信息
echo -e "\n${GREEN}=== 系统信息 ===${NC}"
echo -e "日期时间: $(date)"
echo -e "主机名: $(hostname)"
echo -e "系统: $(cat /etc/*release 2>/dev/null | grep "PRETTY_NAME" | cut -d= -f2- | tr -d '"' || uname -s)"
echo -e "内核: $(uname -r)"
echo -e "运行时间: $(uptime | awk '{print $3,$4}' | sed 's/,//')"
if [ -f /proc/loadavg ]; then
    load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo -e "系统负载(1, 5, 15分钟平均值): $load_avg"
else
    echo "无法获取系统负载信息"
fi

# CPU信息
echo -e "\n${GREEN}=== CPU信息 ===${NC}"
cpu_cores=$(grep -c ^processor /proc/cpuinfo)
cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')

echo -e "型号: $cpu_model"
echo -e "核心: $cpu_cores"

cpu_info=$(top -bn1 | grep "Cpu(s)")
cpu_user=$(echo "$cpu_info" | awk '{print $2}')
cpu_system=$(echo "$cpu_info" | awk '{print $4}')
cpu_idle=$(echo "$cpu_info" | awk -F', *' '{print $4}' | cut -d' ' -f1)

if [[ -n "$cpu_user" && -n "$cpu_system" ]]; then
    cpu_usage=$(printf "%.1f" $(echo "$cpu_user + $cpu_system" | bc 2>/dev/null || echo "0"))

    if (( $(echo "$cpu_usage <= 70" | bc 2>/dev/null || echo "1") )); then
        echo -e "使用: ${GREEN}${cpu_usage}%${NC}(${cpu_user}% + ${cpu_system}%)"
    elif (( $(echo "$cpu_usage <= 90" | bc 2>/dev/null || echo "1") )); then
        echo -e "使用: ${YELLOW}${cpu_usage}%${NC}(${cpu_user}% + ${cpu_system}%)"
    else
        echo -e "使用: ${RED}${cpu_usage}%${NC}(${cpu_user}% + ${cpu_system}%)"
    fi

    echo -e "空闲: ${cpu_idle}%"
else
    echo -e "CPU总体使用率: 无法获取"
fi

# 内存信息
echo -e "\n${GREEN}=== 内存信息 ===${NC}"
# free -h | awk 'NR==1 {print "总计\t已用\t空闲\t共享\t缓存\t可用"}; NR==2 {print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}'
if [ -f /proc/meminfo ]; then
    mem_total=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
    mem_free=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
    mem_available=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
    mem_buffers=$(grep "Buffers" /proc/meminfo | awk '{print $2}')
    mem_cached=$(grep "^Cached" /proc/meminfo | awk '{print $2}')

    convert_size() {
        local size=$1
        if (( size < 1024 * 1024 )); then
            echo "$(awk -v size="$size" 'BEGIN {printf "%.2f MB", size/1024}')"
        else
            echo "$(awk -v size="$size" 'BEGIN {printf "%.2f GB", size/1024/1024}')"
        fi
    }

    mem_total_str=$(convert_size $mem_total)
    mem_free_str=$(convert_size $mem_free)
    mem_available_str=$(convert_size $mem_available)
    mem_buffers_str=$(convert_size $mem_buffers)
    mem_cached_str=$(convert_size $mem_cached)
    
    mem_used_kb=$((mem_total - mem_free - mem_buffers - mem_cached))
    mem_used_str=$(convert_size $mem_used_kb)
    
    if [ $mem_total -gt 0 ]; then
        mem_usage_percent=$((100 * mem_used_kb / mem_total))
    else
        mem_usage_percent=0
    fi
    
    echo -e "总内存: $mem_total_str"
    
    if [ $mem_usage_percent -lt 70 ]; then
        echo -e "已用内存: ${GREEN}$mem_used_str (${mem_usage_percent}%)${NC}"
    elif [ $mem_usage_percent -lt 90 ]; then
        echo -e "已用内存: ${YELLOW}$mem_used_str (${mem_usage_percent}%)${NC}"
    else
        echo -e "已用内存: ${RED}$mem_used_str (${mem_usage_percent}%)${NC}"
    fi
    
    echo -e "空闲内存: $mem_free_str"
    echo -e "缓冲内存: $mem_buffers_str"
    echo -e "缓存内存: $mem_cached_str"
    echo -e "可用内存: $mem_available_str"
else
    echo "无法获取内存信息"
fi

# 交换空间信息
echo -e "\n${GREEN}=== 交换空间信息 ===${NC}"
if [ -f /proc/meminfo ]; then
    swap_total=$(grep "SwapTotal" /proc/meminfo | awk '{print $2}')
    swap_free=$(grep "SwapFree" /proc/meminfo | awk '{print $2}')

    swap_total_str=$(convert_size $swap_total)
    swap_free_str=$(convert_size $swap_free)
    swap_used_kb=$((swap_total - swap_free))
    swap_used_str=$(convert_size $swap_used_kb)
    
    echo -e "总交换空间: $swap_total_str"
    
    if [ $swap_total -gt 0 ]; then
        swap_usage_percent=$((100 * swap_used_kb / swap_total))
        
        if [ $swap_usage_percent -lt 50 ]; then
            echo -e "已用交换空间: ${GREEN}$swap_used_str (${swap_usage_percent}%)${NC}"
        elif [ $swap_usage_percent -lt 80 ]; then
            echo -e "已用交换空间: ${YELLOW}$swap_used_str (${swap_usage_percent}%)${NC}"
        else
            echo -e "已用交换空间: ${RED}$swap_used_str (${swap_usage_percent}%)${NC}"
        fi
    else
        echo -e "已用交换空间: ${GREEN}0.00 GB (0%)${NC}"
    fi
    
    echo -e "空闲交换空间: $swap_free_str"
else
    echo "无法获取交换空间信息"
fi

# 显示占用CPU和内存最多的进程
echo -e "\n${GREEN}=== 占用CPU最多的5个进程 ===${NC}"
echo -e "PID\t%CPU\t%MEM\t命令"
ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "%s\t%.1f\t%.1f\t%s\n", $2, $3, $4, $11}' || echo "无法获取进程信息"

echo -e "\n${GREEN}=== 占用内存最多的5个进程 ===${NC}"
echo -e "PID\t%CPU\t%MEM\t命令"
ps aux --sort=-%mem 2>/dev/null | head -6 | tail -5 | awk '{printf "%s\t%.1f\t%.1f\t%s\n", $2, $3, $4, $11}' || echo "无法获取进程信息"

# Docker容器信息
echo -e "\n${GREEN}=== Docker容器信息 ===${NC}"
if ! command -v docker &>/dev/null; then
    echo "Docker 未安装"
else
    running_containers=$(docker ps -q)
    if [ -z "$running_containers" ]; then
        echo "没有正在运行的容器"
    else
        containers=$(docker ps --format '{{.ID}} {{.Names}}')

        printf "%-30s %-15s %-30s\n" "NAME" "CPU" "MEM"
        while IFS= read -r line; do
            container_id=$(echo $line | awk '{print $1}')
            container_name=$(echo $line | awk '{print $2}')

            cpu_usage=$(docker stats --no-stream --format "{{.CPUPerc}}" $container_id)
            memory_usage=$(docker stats --no-stream --format "{{.MemUsage}}" $container_id)

            printf "%-30s %-15s %-30s\n" "$container_name" "$cpu_usage" "$memory_usage"
        done <<<"$containers"
    fi
fi

# # 磁盘使用情况
# echo -e "\n${GREEN}=== 磁盘使用情况 ===${NC}"
# echo -e "文件系统\t容量\t已用\t可用\t使用率\t挂载点"
# df -h 2>/dev/null | grep -v "tmpfs\|udev" | grep -v "^Filesystem" | while read line; do
#     fs=$(echo $line | awk '{print $1}')
#     size=$(echo $line | awk '{print $2}')
#     used=$(echo $line | awk '{print $3}')
#     avail=$(echo $line | awk '{print $4}')
#     use_percent=$(echo $line | awk '{print $5}')
#     mounted=$(echo $line | awk '{print $6}')
    
#     # 提取使用率的数字部分
#     percent_num=$(echo $use_percent | sed 's/%//')
    
#     # 根据使用率显示不同颜色
#     if [ "$percent_num" -lt 70 ]; then
#         color=$GREEN
#     elif [ "$percent_num" -lt 90 ]; then
#         color=$YELLOW
#     else
#         color=$RED
#     fi
    
#     echo -e "$fs\t$size\t$used\t$avail\t${color}${use_percent}${NC}\t$mounted"
# done

echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                     监控完成 $(date +%H:%M:%S)                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
