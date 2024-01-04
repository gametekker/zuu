#include <vector>
#include <complex>

/**
 * @file make_segments.hpp
 * @brief For divvying the outputs up into their respective phase and magnitude lots
 */

/**
 * @brief Segments the outputs of a complex function into bins based on their phase and magnitude.
 * 
 * @param outputs 2D vector of complex numbers representing the function outputs.
 * @param segments Pair indicating the number of bins for phase and magnitude.
 * @return std::vector<std::vector<std::pair<int, int>>> 2D vector with each element holding the bin indices for phase and magnitude.
 */
std::vector<std::vector<std::pair<int, int>>> make_segments(const std::vector<std::vector<std::complex<double>>>& outputs, std::pair<int, int> segments);