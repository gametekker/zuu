#include <vector>
#include "LuminanceColormap.hpp"

/**
 * @file produce_image.hpp
 * @brief Function to generate an image from a 2D array of phase and magnitude indices.
 */

/**
 * @brief Generates an image based on the skeleton array and colors provided.
 * 
 * This function takes a 2D output array where each element represents a pair of phase bin index and magnitude bin index.
 * It uses these indices to map to specific colors and generate an image. The size of the colors array must be equal 
 * to the number of phase bins (mapdim.first). Each phase bin has a one-to-one correspondence with a color.
 * 
 * @param skeleton 2D vector of pairs representing phase bin index and magnitude bin index.
 * @param colors Vector of RGBA color arrays.
 * @param mapdim Pair representing dimensions of the phase and magnitude map.
 * @param title Optional title for the image.
 */
void produce_image(const std::vector<std::vector<std::pair<int, int>>>& skeleton, 
                   const std::vector<std::array<double, 4>>& colors,
                   const std::pair<int,int> mapdim,
                   const std::string& title = "");