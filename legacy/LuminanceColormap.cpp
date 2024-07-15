#include <iostream>
#include <vector>
#include <array>
#include "LuminanceColormap.hpp"

LuminanceColormap::LuminanceColormap(const std::vector<std::array<double, 4>>& colors, int shades_for_each_color)
: shades_for_each_color(shades_for_each_color) {
    generateColormap(colors);
}

void LuminanceColormap::generateColormap(const std::vector<std::array<double, 4>>& colors) {
    for (const auto& color : colors) {
        std::vector<std::array<double, 4>> shades;
        for (int j = 0; j < shades_for_each_color; ++j) {
            double shade_factor = static_cast<double>(j) / shades_for_each_color;
            std::array<double, 4> shaded_color = {
                color[0] * (1 - shade_factor),
                color[1] * (1 - shade_factor),
                color[2] * (1 - shade_factor),
                1 // Alpha channel remains constant
            };
            shades.push_back(shaded_color);
        }
        colormap.push_back(shades);
    }
}

std::array<double, 4> LuminanceColormap::getColor(int colorIdx, int shadeIdx) const {
    return colormap[colorIdx][shadeIdx];
}

std::pair<int, int> LuminanceColormap::getShape() const {
    return {static_cast<int>(colormap.size()), shades_for_each_color};
}