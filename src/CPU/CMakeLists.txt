cmake_minimum_required(VERSION 3.30)

project(Parallel)

set(CMAKE_CXX_STANDARD 20)

set(OpenCV_DIR "C:/Users/abiga/Desktop/vcpkg/installed/x64-windows/share/opencv4")

find_package(OpenCV REQUIRED COMPONENTS core imgproc highgui)

add_executable(Parallel ../main.cpp)

target_link_libraries(Parallel ${OpenCV_LIBS})