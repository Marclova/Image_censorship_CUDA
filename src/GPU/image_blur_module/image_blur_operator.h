#include "src/data_models/graphics.h"
#include "src/data_models/kernel_data_models.h"


/// @brief Calculates the horizontal convolution for the image blurring operation.
/// @param partial_calculation_data_vector Output vector that will store the partial results of the horizontal convolution for each pixel.
/// @param input_image_data The input image data to be blurred, passed as a read-only parameter to ensure absence of read-write conflicts.
/// @param image_width The width of the input image.
/// @param image_height The height of the input image.
/// @param mask_collection The collection of masks to be applied to the input image.
/// @param filter The filter to be applied to the input image.
__global__ void calculate_horizontal_convolution(pixel *partial_calculation_data_vector, pixel const *input_image_data, 
                                                 unsigned short const image_width, unsigned short const image_height, 
                                                 Device_mask_collection const mask_collection, vector_filter const filter);

/// @brief Calculates the vertical convolution and writes the results to the output image.
/// @param output_image_data The output image data where the blurred results will be stored.
/// @param partial_calculation_data_vector The vector containing the partial results of the horizontal convolution.
/// @param image_width The width of the input image.
/// @param image_height The height of the input image.
/// @param mask_collection The collection of masks to be applied to the input image.
/// @param filter The filter to be applied to the input image.
__global__ void calculate_vertical_convolution_and_write_results(pixel *output_image_data, pixel const *partial_calculation_data_vector,
                                                                 unsigned short const image_width, unsigned short const image_height, 
                                                                 Device_mask_collection const mask_collection, vector_filter const filter);