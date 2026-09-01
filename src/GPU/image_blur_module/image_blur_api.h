#include "src/data_models/graphics.h"
#include <vector>

/// @brief Allocates the necessary memory on the GPU before calling the kernel to perform the image blurring.
/// @param input_image The input image to be blurred, passed as a vector_picture struct.
/// @param mask_array The array of masks to be applied to the input image, passed as an array of mask structs.
/// @param mask_count The number of masks in the provided mask_array.
/// @param filter The filter to be applied to the input image, passed as a vector_filter struct.
/// @return The blurred image as a vector_picture struct.
vector_picture blur_image(const vector_picture input_image, mask mask_array[], const unsigned short mask_count, const vector_filter filter);