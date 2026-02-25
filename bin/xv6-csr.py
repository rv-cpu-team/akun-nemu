import re
from collections import Counter

def analyze_csr_usage_v2(file_path):
    # 匹配模式：地址: 十六进制 助记符 操作数
    # 分组 1: 指令名 (如 csrr, csrw)
    # 分组 2: 所有的操作数 (如 a1, mhartid)
    line_re = re.compile(r'\s+(csr[rwc][si]?)\s+([^#\n]+)')
    
    csr_counts = Counter()

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                match = line_re.search(line.lower())
                if match:
                    instr = match.group(1)
                    # 清理操作数，去除空格并按逗号分割
                    args = [arg.strip() for arg in match.group(2).split(',')]
                    
                    if not args:
                        continue

                    # 逻辑判定：
                    # csrr  rd, csr   -> CSR 是第二个参数 args[1]
                    # csrw  csr, rs   -> CSR 是第一个参数 args[0]
                    # csrrw rd, csr, rs -> CSR 是第二个参数 args[1]
                    # csrrs/csrrc rd, csr, rs -> CSR 是第二个参数 args[1]
                    
                    if instr == 'csrw' or instr == 'csrwi':
                        csr_reg = args[0]
                    else:
                        # 绝大多数情况下 (csrr, csrs, csrc, csrrw...) CSR 都在第二个位置
                        if len(args) >= 2:
                            csr_reg = args[1]
                        else:
                            csr_reg = args[0] # 兜底逻辑

                    csr_counts[csr_reg] += 1
                    
    except Exception as e:
        print(f"Error: {e}")
        return

    print(f"{'CSR Register':<15} | {'Access Count':<10}")
    print("-" * 30)
    for reg, count in csr_counts.most_common():
        print(f"{reg:<15} | {count:<10}")

if __name__ == "__main__":
    analyze_csr_usage_v2("xv6-kernel.s")