import re
import json
from typing import TextIO

COSIM_PATH = 'cosim'

def get_log() -> TextIO:
    try:
        return open(f'{COSIM_PATH}/commits.log', 'r')
    except FileNotFoundError:
        print('Log file not found, simulate with spike first')

def create_jsonl() -> TextIO:
    try:
        return open(f'{COSIM_PATH}/spike.jsonl', 'w')
    except OSError:
        print('Could not create jsonl file')

def convert(log: TextIO, jsonl: TextIO):
    for line in log:
        ops = line.split()
        length = len(ops)
        instr = ops[4][1:11]
        pc = ops[3]
        if (int(pc, 16) <= 0x00010000): continue
        rd_addr = None
        rd_data = None
        mem_waddr = None
        mem_wdata = None
        mem_raddr = None
        mem_rdata = None
        csr_addr = None
        csr_data = None

        # Loop is inspired by try state function of 
        # https://opensecura.googlesource.com/sim/tbm/+/199a34e438c43c764bb86f32c65a2cfdb9a1ea09/gentrace-spike.py
        i = 5
        while i < len(ops):
            tok = ops[i]
            if (tok == 'mem'):
                if (i + 2 < len(ops) and ops[i + 2].startswith('0x')):
                    """Store"""
                    mem_waddr = ops[i + 1]
                    mem_wdata = ops[i + 2]
                    i += 3 #Jump out
                else:
                    """Load"""
                    mem_raddr = ops[i + 1]
                    mem_rdata = rd_data
                    i += 2 #Jump out
            elif (re.fullmatch(r'x[0-9]+', tok)):
                """Write to register"""
                rd_addr = int(tok[1:])
                rd_data = ops[i + 1]
                i += 2 #If normal reg_write jump out, if csr jump to write csr
            elif (re.match(r'c[0-9]+_', tok)):
                """Write to csr"""
                csr_addr = int(tok[1:tok.index('_')])
                csr_data = ops[i + 1]
                i += 2 #Jump out
            else:
                print(f'Unknown entry {tok} at pc {pc}')
                i += 1 #Print each wrong peace

        line = {"pc": pc, "instr": instr,
                "rd_addr": rd_addr, "rd_data": rd_data,
                "mem_waddr": mem_waddr, "mem_wdata": mem_wdata,
                "mem_raddr": mem_raddr, "mem_rdata": mem_rdata,
                "csr_addr": csr_addr, "csr_data": csr_data}
        
        jsonl.write(json.dumps(line) + '\n')


def main() -> None:
    jsonl = create_jsonl()
    log = get_log()

    convert(log, jsonl)

    log.close()
    jsonl.close()

if __name__ == "__main__":
    main()
    