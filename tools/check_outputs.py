#!/usr/bin/env python3
import numpy as np, re
W, H = 1920, 1080
N = W*H

def load_mem(path):
    import re
    hex2 = re.compile(r'^[0-9A-Fa-f]{2}$')
    vals = []
    with open(path, 'r') as f:
        for line in f:
            s = line.strip()
            if not s: continue
            if not hex2.match(s): continue
            vals.append(int(s, 16))
    return np.array(vals, dtype=np.uint8)

gold_sobel = load_mem('sim/sobel_golden.mem')
gold_fdiff = load_mem('sim/fdiff_golden.mem')
rtl_sobel  = load_mem('sim/sobel_out.mem')
rtl_fdiff  = load_mem('sim/fdiff_out.mem')

def report(gold, rtl, name):
    total = min(len(gold), len(rtl), N)
    if total == 0:
        print(f'{name}: No data to compare.')
        return
    eq = (gold[:total] == rtl[:total])
    rate = float(eq.sum())/total*100.0
    print(f'{name}: match={rate:.4f}%  compared={total} pixels')
    if rate < 100.0:
        idx = np.where(~eq)[0][:10]
        for i in idx:
            y = i // W; x = i % W
            print(f'  mismatch at (x={x}, y={y}): gold={int(gold[i])}, rtl={int(rtl[i])}')

report(gold_sobel, rtl_sobel, 'SOBEL_BIN')
report(gold_fdiff, rtl_fdiff, 'FRAME_DIFF')
