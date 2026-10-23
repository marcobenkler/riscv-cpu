import sys
import json

COSIM_PATH = 'cosim'

def get_jsonl(kind: str):
    try:
        return open(f'{COSIM_PATH}/{kind}.jsonl', 'r')
    except FileNotFoundError:
        print(f'{kind}.jsonl file not found')
        sys.exit(1)

def get_dis():
    try:
        return open('build_cosim/cosim.dis', 'r')
    except FileNotFoundError:
        print('.dis file not found')
        sys.exit(1)

def get_rep():
    try:
        return open(f'{COSIM_PATH}/report.log', 'w')
    except OSError:
        print('Could not create report.log file')
        sys.exit(1)

def main():
    rtl = get_jsonl('rtl')
    spike = get_jsonl('spike')
    dis = get_dis()
    report = get_rep()

    spike_items = [json.loads(line) for line in spike if line.strip()]
    rtl_items   = [json.loads(line) for line in rtl   if line.strip()]

    for _, (s, r) in enumerate(zip(spike_items, rtl_items)):
        key = s.keys() & r.keys()
        for tag in key:
            if (s[tag] != r[tag]):
                pc = f'{int(s["pc"], 16):x}:'
                lines = dis.readlines()
                for i, line in enumerate(lines):
                    if line.strip().startswith(pc):
                        break
                res = lines[max(0, i - 50) : i + 12]
                res.insert(0, f'Error at pc: {pc}')
                print(res)
                report.writelines(res)
                sys.exit(1) #make knows if test worked 
                return
    
    spike.close()
    rtl.close()
    dis.close()
    report.close()

if __name__ == "__main__":
    main()