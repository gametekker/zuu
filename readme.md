## Image: (please see video for real time example)
![Alt text](https://github.com/gametekker/zuu/blob/master/Screen%20Shot%202024-11-04%20at%206.21.49%20PM.png)

## See Video Demo:
https://youtu.be/H7H9GEahH9w

## Compilation:
`./compile.sh`

## Abstract:
Visualizes the function f(z)=c1 ^ z ^ c2i:
- c1, c2 are coefficients
- z is a complex number - a+bi
How the visualization works:
- the pixel location in the image corresponds to the input value z in the complex plane
- the pixel is colored as a function of the phase of the output of f(z) at that pixel
- the pixel is shaded as a function of the phase of the derivative of f(z) at that pixel

## Usage
`./start`

Move the screen around with `W`, `A`, `S`, `D`

Change the values of c1, c2: `Q`, `E`, `R`, `T`

Zoom in / out: `LSHIFT`, `RSHIFT`

## Technical Details
- contains optimized CUDA kernel functions for generating outputs of the complex function
- utilizes CUDA OpenGL interperobility to allow real time visualization
