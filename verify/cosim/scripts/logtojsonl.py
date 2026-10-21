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
        handler1 = ops[5] if length > 5 else None
        handler2 = ops[6] if length > 6 else None
        handler3 = ops[7] if length > 7 else None
        handler4 = ops[8] if length > 8 else None

        if (handler1 == 'mem'):
            """Store"""
            mem_waddr = handler2
            mem_wdata = handler3
        elif (handler3 == 'mem'):
            """Load"""
            mem_raddr = handler4
            mem_rdata = handler2
        elif (handler3 is not None and re.match('c[0-9]{3}', handler3)):
            """Read from csr"""
            rd_addr = int(handler1[1:])
            rd_data = handler2
        elif (handler1 is not None and re.match('c[0-9]{3}', handler1)):
            """Write to csr"""
            csr_addr = int(handler1[1:3])
            csr_data = handler2
        else:
            rd_addr = int(handler1[1:]) if handler1 is not None else None
            rd_data = handler2
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
    