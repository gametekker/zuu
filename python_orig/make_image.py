import numpy as np
def create_complex_grid(xlim, ylim, resolution):
    """
    Create a 2D numpy array of complex numbers.

    Parameters:
    xlim (tuple): The limits for the x-axis (real part), e.g., (-1, 1).
    ylim (tuple): The limits for the y-axis (imaginary part), e.g., (-1, 1).
    resolution (int): The number of points along each axis.

    Returns:
    numpy.ndarray: A 2D array of complex numbers.
    """
    # Create linearly spaced arrays for the real and imaginary parts
    real = np.linspace(xlim[0], xlim[1], resolution)
    imag = np.linspace(ylim[0], ylim[1], resolution)

    # Create a meshgrid, which forms a coordinate matrix from the real and imaginary parts
    real_grid, imag_grid = np.meshgrid(real, imag)

    # Combine the real and imaginary parts to form complex numbers
    complex_grid = real_grid + 1j * imag_grid

    return complex_grid

def make_image(xlim: tuple, ylim: tuple, res: int, func):

    inputs = create_complex_grid(xlim,ylim,res)
    outputs = np.zeros(inputs.shape, dtype=complex)

    #generate outputs
    for i,j in np.ndindex(outputs.shape):
        outputs[i,j] = func(inputs[i,j])

    return outputs
