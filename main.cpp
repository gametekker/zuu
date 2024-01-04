#include <vector>
#include <complex>
#include <array>
#include "produce_image.hpp"
#include "make_segments.hpp"
#include "make_image.hpp"

// Example function to use with make_image
std::complex<double> example_function(const std::complex<double>& z) {
    // Use std::pow with a complex exponent
    return std::cos(z * std::complex<double>(0.0, 1.0)) * std::pow(z, std::complex<double>(0.0, 3.0));
}

int main() {

    // Example usage
    std::vector<std::vector<std::complex<double>>> outputs = make_image({-2.0,2.0}, {-2.0,2.0}, 4000, example_function);

    // Define a simple colormap
    std::vector<std::array<double, 4>> colors = {
        {236.0/255, 244.0/255, 214.0/255, 100},   // Soft Green
        {154.0/255, 208.0/255, 194.0/255, 100},   // Aquamarine
        {45.0/255, 149.0/255, 150.0/255, 100},    // Teal
        {38.0/255, 80.0/255, 115.0/255, 100},     // Deep Sky Blue
        {34.0/255, 9.0/255, 44.0/255, 100},       // Dark Purple
        {135.0/255, 35.0/255, 65.0/255, 100},     // Crimson
        {190.0/255, 49.0/255, 68.0/255, 100},     // Raspberry
        {240.0/255, 89.0/255, 65.0/255, 100},     // Coral
        {7.0/255, 102.0/255, 173.0/255, 100},     // Cobalt Blue
        {41.0/255, 173.0/255, 178.0/255, 100}     // Turquoise
    };

    std::pair<int,int> output_bins = {colors.size(),1};

    std::vector<std::vector<std::pair<int, int>>> skeleton = make_segments(outputs, output_bins);

    produce_image(skeleton, colors, output_bins, "my_image");

    return 0;
}