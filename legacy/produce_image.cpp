#include <iostream>
#include <vector>
#include <array>
#include <png.h>
#include "LuminanceColormap.hpp"

void produce_image(const std::vector<std::vector<std::pair<int, int>>>& skeleton, 
                   const std::vector<std::array<double, 4>>& colors,
                   const std::pair<int,int> mapdim, 
                   const std::string& title) {

    LuminanceColormap cmap (colors,mapdim.second);
    
    int width = skeleton.size();
    int height = skeleton[0].size();
    int depth = 8; // Bit depth per channel

    FILE *fp = fopen((title.empty() ? "output.png" : (title + ".png")).c_str(), "wb");
    if(!fp) {
        std::cerr << "Error: Cannot open file for writing" << std::endl;
        return;
    }

    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
    if (!png_ptr) {
        std::cerr << "Error: Cannot create PNG write structure" << std::endl;
        fclose(fp);
        return;
    }

    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr) {
        std::cerr << "Error: Cannot create PNG info structure" << std::endl;
        png_destroy_write_struct(&png_ptr, nullptr);
        fclose(fp);
        return;
    }

    if (setjmp(png_jmpbuf(png_ptr))) {
        std::cerr << "Error during PNG creation" << std::endl;
        png_destroy_write_struct(&png_ptr, &info_ptr);
        fclose(fp);
        return;
    }

    png_init_io(png_ptr, fp);

    png_set_IHDR(png_ptr, info_ptr, width, height, depth, PNG_COLOR_TYPE_RGBA, PNG_INTERLACE_NONE,
                 PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);

    png_write_info(png_ptr, info_ptr);

    // Creating the image
    png_bytep row = (png_bytep)malloc(4 * width * sizeof(png_byte));
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            auto [x1, x2] = skeleton[x][y];
            auto color = cmap.getColor(x1,x2);
            row[x*4 + 0] = static_cast<png_byte>(color[0] * 255);
            row[x*4 + 1] = static_cast<png_byte>(color[1] * 255);
            row[x*4 + 2] = static_cast<png_byte>(color[2] * 255);
            row[x*4 + 3] = static_cast<png_byte>(color[3] * 255);
        }
        png_write_row(png_ptr, row);
    }

    png_write_end(png_ptr, nullptr);

    // Cleanup
    fclose(fp);
    png_free_data(png_ptr, info_ptr, PNG_FREE_ALL, -1);
    png_destroy_write_struct(&png_ptr, &info_ptr);
    free(row);
}