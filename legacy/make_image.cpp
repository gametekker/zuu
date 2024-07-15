#include <iostream>
#include <vector>
#include <complex>

// Function to create a linearly spaced vector
std::vector<double> linspace(double start, double end, int num) {
    std::vector<double> linspaced;
    double delta = (end - start) / (num - 1);

    for (int i = 0; i < num - 1; ++i) {
        linspaced.push_back(start + delta * i);
    }
    linspaced.push_back(end); // Ensure that end is included

    return linspaced;
}

// Function to create a 2D grid of complex numbers
std::vector<std::vector<std::complex<double>>> create_complex_grid(std::pair<double,double> xlim, std::pair<double,double> ylim, int resolution) {
    std::vector<double> real = linspace(xlim.first, xlim.second, resolution);
    std::vector<double> imag = linspace(ylim.first, ylim.second, resolution);

    std::vector<std::vector<std::complex<double>>> complex_grid(resolution, std::vector<std::complex<double>>(resolution));

    for (int i = 0; i < resolution; ++i) {
        for (int j = 0; j < resolution; ++j) {
            complex_grid[i][j] = std::complex<double>(real[i], imag[j]);
        }
    }

    return complex_grid;
}

// Function to apply a complex function to each element of the grid
std::vector<std::vector<std::complex<double>>> make_image(std::pair<double,double> xlim, std::pair<double,double> ylim, int res, std::complex<double> (*func)(const std::complex<double>&)) {
    auto inputs = create_complex_grid(xlim, ylim, res);
    std::vector<std::vector<std::complex<double>>> outputs(res, std::vector<std::complex<double>>(res));

    for (int i = 0; i < res; ++i) {
        for (int j = 0; j < res; ++j) {
            outputs[i][j] = func(inputs[i][j]);
        }
    }

    return outputs;
}
