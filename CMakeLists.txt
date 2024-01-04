cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Zuu VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# add the executable
add_executable(Zuu main.cpp)

# include directories
include_directories(${PROJECT_SOURCE_DIR})

# add the source files
target_sources(Zuu
    PRIVATE 
    LuminanceColormap.cpp 
    make_segments.cpp 
    make_image.cpp 
    produce_image.cpp
)

# if there are any libraries you need to link against, use:
target_link_libraries(Zuu PUBLIC png)
