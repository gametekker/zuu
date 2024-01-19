![Complex Powers](https://github.com/gametekker/zuu/blob/master/my_image.png "Example Image")
## Compilation
`cmake -S . -B build`
`cmake --build build`

## Example Usage

Please refer to `main.cpp`

This project includes a set of helper functions designed to generate images based on the outputs of complex functions. These helper functions can be considered as part of a simple API for image generation from complex function outputs. Here's how to use them:

### Create Outputs
Generate a 2D array of complex numbers using `make_image`. In this example, we generate outputs within specified ranges.

### Define a Color Map
A set of RGBA colors is defined. Each color represents a different phase bin.

### Segmentation
The `make_segments` function segments the outputs into bins based on their phase and magnitude, creating a 'skeleton' for the image.

### Produce the Image
Finally, `produce_image` takes the skeleton, color map, and bin dimensions to generate and save the final image, titled "my_image".

By following these steps, users can create visually appealing representations of complex mathematical functions.
