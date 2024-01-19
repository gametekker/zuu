![Complex Powers](https://github.com/gametekker/zuu/blob/master/my_image.png "Example Image")

## Compilation
`cmake -S . -B build`
`cmake --build build`

### Running

To run the example, after building and compiling, run the following

`./build/zuu`

## Overview

This project includes a set of helper functions designed to generate images based on the outputs of complex functions f(z).

- the pixel location in the image corresponds to the input value z in the complex plane
- the pixel is colored as a function of the output of f(z) at that pixel

## Example Usage

These helper functions can be considered as part of a simple API for image generation from complex function outputs. Here's how to use them:

### Create Outputs
Inside the example in `main.cpp`, we define the function to be plotted as f(z) = z * (c0)i * z ^ (c1)i where z is a complex number.
We generate a 2D array of complex numbers using `make_image`. In this example, we generate outputs of f(z) within specified ranges.

### Define a Color Map
A set of RGBA colors is defined. Each color represents a different phase bin.

### Segmentation
The `make_segments` function segments the outputs into bins based on their phase and magnitude, creating a 'skeleton' for the image.

### Produce the Image
Finally, `produce_image` takes the skeleton, color map, and bin dimensions to generate and save the final image, titled "my_image".

By following these steps, users can create visually appealing representations of complex mathematical functions.
