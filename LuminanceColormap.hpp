#include <iostream>
#include <vector>
#include <array>

/**
 * @file LuminanceColormap.hpp
 * @brief Class for mapping a phase plot index to RGBA color.
 */

/**
 * @class LuminanceColormap
 * @brief Class to map phase plot index to RGBA color.
 *
 * This class generates a colormap with different shades for each given color, and provides functionality
 * to retrieve specific colors and shades based on index values.
 */
class LuminanceColormap {
public:
    /**
    * @brief Constructs a LuminanceColormap object.
    * 
    * @param colors A vector of RGBA color arrays.
    * @param shades_for_each_color Number of shades to generate for each color.
    */
    LuminanceColormap(const std::vector<std::array<double, 4>>& colors, int shades_for_each_color = 16);

    void generateColormap(const std::vector<std::array<double, 4>>& colors);

    /**
     * @brief Retrieves a specific color and shade from the colormap.
     * 
     * @param colorIdx Index of the color.
     * @param shadeIdx Index of the shade for the specified color.
     * @return std::array<double, 4> The RGBA color.
     */
    std::array<double, 4> getColor(int colorIdx, int shadeIdx) const;

    /**
     * @brief Gets the dimensions of the colormap.
     * 
     * @return std::pair<int, int> A pair containing the number of colors and shades.
     */
    std::pair<int, int> getShape() const;

private:
    int shades_for_each_color;
    std::vector<std::vector<std::array<double, 4>>> colormap;
};