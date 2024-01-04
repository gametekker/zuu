import numpy as np

def max_complex_value(arr):
    # Calculate the absolute values (magnitudes) of the complex numbers
    magnitudes = np.sqrt(np.real(arr) ** 2 + np.imag(arr) ** 2)

    return np.max(magnitudes)

def make_segments(outputs: np.ndarray, segments: tuple):
    class radDist:
        def __init__(self, intervalsx: tuple, intervalsy: tuple, x_bins: int, y_bins: int):
            self.x_bins = x_bins
            self.y_bins = y_bins
            self.x_interval_size = (intervalsx[1] - intervalsx[0]) / x_bins
            self.y_interval_size = (intervalsy[1] - intervalsy[0]) / y_bins

        def __call__(self, x, y):
            x_index = int((x - (-np.pi)) // self.x_interval_size)  # Adjust for negative start of interval
            y_index = int(y // self.y_interval_size)

            # Ensure indices are within bounds
            x_index = min(x_index, self.x_bins - 1)
            y_index = min(y_index, self.y_bins - 1)

            return x_index, y_index

    largest = max_complex_value(outputs)

    n_angles, n_distances = segments

    table = radDist((-np.pi, np.pi), (0, largest), n_angles, n_distances)

    print(outputs.shape)
    skeleton = np.zeros(shape=(*outputs.shape, 2))
    # define boundaries
    for i, j in np.ndindex(outputs.shape):
        phase = np.angle(outputs[i, j])
        r = np.sqrt(np.real(outputs[i, j]) ** 2 + np.imag(outputs[i, j]) ** 2)

        x1, x2 = table(phase, r)

        skeleton[i, j, :] = (x1, x2)

    return skeleton
