import re
from collections import Counter

def analyze_csr_usage(file_path):
    pattern = re.compile(r"disassemble=\[(\w+)\s+[^,]+,\s+(\w+),")
    
    csr_stats = {}

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    instr, csr_name = match.groups()
                    
                    if csr_name not in csr_stats:
                        csr_stats[csr_name] = Counter()
                    
                    csr_stats[csr_name][instr] += 1
                    
        return csr_stats

    except FileNotFoundError:
        print("错误：找不到指定的 txt 文件。")
        return None

# 执行统计
file_name = 'npc-log-log.txt' # 请替换为你的文件名
results = analyze_csr_usage(file_name)

if results:
    print(f"{'CSR 寄存器':<15} | {'操作指令':<10} | {'出现次数':<8}")
    print("-" * 40)
    for csr, counts in results.items():
        for instr, count in counts.items():
            print(f"{csr:<15} | {instr:<10} | {count:<8}")