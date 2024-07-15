#include <iostream>
#include <vector>
#include <complex>
#include <cmath>
#include <algorithm>

/**
 * @brief Calculates the maximum magnitude of complex numbers in a 2D vector.
 * 
 * @param arr A 2D vector containing elements of type std::complex<double>.
 * @return double The largest magnitude found.
 */
double max_complex_value(const std::vector<std::vector<std::complex<double>>>& arr) {

    double max_magnitude = 0.0;

    for (const auto& row : arr) {
        for (const auto& elem : row) {
            double magnitude = std::abs(elem);
            max_magnitude = std::max(max_magnitude, magnitude);
        }
    }

    return max_magnitude;
}

/**
* @class RadDist
* @brief Maps 2D real coordinates to their respective bin indices.
* 
* This class is used for mapping the phase and magnitude of complex numbers
* to their respective bin indices in a grid.
*/
class RadDist {
public:
    /**
     * @brief Constructs a new RadDist object.
     * 
     * @param intervalsx Interval of x-values (phase).
     * @param intervalsy Interval of y-values (magnitude).
     * @param x_bins Number of bins for phase.
     * @param y_bins Number of bins for magnitude.
     */
    RadDist(std::pair<double, double> intervalsx, std::pair<double, double> intervalsy, int x_bins, int y_bins)
    : x_bins(x_bins), y_bins(y_bins) {
        x_interval_size = (intervalsx.second - intervalsx.first) / x_bins;
        y_interval_size = (intervalsy.second - intervalsy.first) / y_bins;
    }

    /**
     * @brief Maps given x (phase) and y (magnitude) to bin indices.
     * 
     * @param x Phase value.
     * @param y Magnitude value.
     * @return std::pair<int, int> The bin indices for phase and magnitude.
     */
    std::pair<int, int> operator()(double x, double y) const {
        int x_index = int((x - (-M_PI)) / x_interval_size);  // Adjust for negative start of interval
        int y_index = int(y / y_interval_size);

        // Ensure indices are within bounds
        x_index = std::min(x_index, x_bins - 1);
        y_index = std::min(y_index, y_bins - 1);

        return {x_index, y_index};
    }

private:
    int x_bins, y_bins;
    double x_interval_size, y_interval_size;
};

std::vector<std::vector<std::pair<int, int>>> make_segments(const std::vector<std::vector<std::complex<double>>>& outputs, std::pair<int, int> segments) {
    double largest = max_complex_value(outputs);

    int n_angles = segments.first;
    int n_distances = segments.second;

    RadDist table({-M_PI, M_PI}, {0, largest}, n_angles, n_distances);

    std::vector<std::vector<std::pair<int, int>>> skeleton(outputs.size(), std::vector<std::pair<int, int>>(outputs[0].size()));

    // Define boundaries
    for (size_t i = 0; i < outputs.size(); ++i) {
        for (size_t j = 0; j < outputs[i].size(); ++j) {
            double phase = std::arg(outputs[i][j]);
            double r = std::abs(outputs[i][j]);

            auto [x1, x2] = table(phase, r);

            skeleton[i][j] = {x1, x2};
        }
    }

    return skeleton;
}
