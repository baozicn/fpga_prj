#!/usr/bin/env python3
import numpy as np, os
W, H = 1920, 1080

def save_mem_hex(path, arr):
    with open(path, 'w') as f:
        for v in arr.flatten():
            f.write(f"{v:02X}\n")

def save_pgm(path, img):
    with open(path, 'wb') as f:
        f.write(f"P5\n{W} {H}\n255\n".encode())
        f.write(img.astype(np.uint8).tobytes())

def synth_frames():
    y = np.linspace(0, 255, H, dtype=np.float32)[:, None]
    x = np.linspace(0, 255, W, dtype=np.float32)[None, :]
    base = 0.5 * x + 0.5 * y
    img0 = base.copy()
    h0, w0 = H//3, W//3
    r0y, r0x = H//2 - h0//2, W//2 - w0//2
    img0[r0y:r0y+h0, r0x:r0x+w0] = np.clip(img0[r0y:r0y+h0, r0x:r0x+w0] + 60, 0, 255)
    img1 = base.copy()
    r1y, r1x = r0y + H//60, r0x + W//60
    img1[r1y:r1y+h0, r1x:r1x+w0] = np.clip(img1[r1y:r1y+h0, r1x:r1x+w0] + 60, 0, 255)
    return img0.astype(np.uint8), img1.astype(np.uint8)

def sobel_3x3_8u(img):
    kx = np.array([[-1,0,1],[-2,0,2],[-1,0,1]], dtype=np.int16)
    ky = np.array([[-1,-2,-1],[0,0,0],[1,2,1]], dtype=np.int16)
    pad = np.pad(img.astype(np.int16), ((1,1),(1,1)), mode='constant', constant_values=0)
    gx = (
        kx[0,0]*pad[0:H,0:W] + kx[0,1]*pad[0:H,1:W+1] + kx[0,2]*pad[0:H,2:W+2] +
        kx[1,0]*pad[1:H+1,0:W] + kx[1,1]*pad[1:H+1,1:W+1] + kx[1,2]*pad[1:H+1,2:W+2] +
        kx[2,0]*pad[2:H+2,0:W] + kx[2,1]*pad[2:H+2,1:W+1] + kx[2,2]*pad[2:H+2,2:W+2]
    )
    gy = (
        ky[0,0]*pad[0:H,0:W] + ky[0,1]*pad[0:H,1:W+1] + ky[0,2]*pad[0:H,2:W+2] +
        ky[1,0]*pad[1:H+1,0:W] + ky[1,1]*pad[1:H+1,1:W+1] + ky[1,2]*pad[1:H+1,2:W+2] +
        ky[2,0]*pad[2:H+2,0:W] + ky[2,1]*pad[2:H+2,1:W+1] + ky[2,2]*pad[2:H+2,2:W+2]
    )
    g = (np.abs(gx) + np.abs(gy)) >> 3
    g = np.clip(g, 0, 255).astype(np.uint8)
    return g

def main():
    os.makedirs('images', exist_ok=True)
    os.makedirs('sim', exist_ok=True)
    f0, f1 = synth_frames()
    save_pgm('images/frame0.pgm', f0)
    save_pgm('images/frame1.pgm', f1)
    save_mem_hex('sim/frame0.mem', f0)
    save_mem_hex('sim/frame1.mem', f1)

    sobel_grad = sobel_3x3_8u(f0)
    save_pgm('images/sobel_grad.pgm', sobel_grad)
    sobel_bin = (sobel_grad > 80).astype(np.uint8) * 255
    save_pgm('images/sobel_golden.pgm', sobel_bin)
    save_mem_hex('sim/sobel_golden.mem', sobel_bin)

    fdiff = np.abs(f1.astype(np.int16) - f0.astype(np.int16)).astype(np.uint8)
    fdiff_mask = (fdiff > 25).astype(np.uint8) * 255
    save_pgm('images/fdiff_golden.pgm', fdiff_mask)
    save_mem_hex('sim/fdiff_golden.mem', fdiff_mask)
    print('Generated goldens: sim/*.mem, images/*.pgm')

if __name__ == '__main__':
    main()
