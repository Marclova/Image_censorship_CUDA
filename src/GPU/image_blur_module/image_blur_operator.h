#include "src/data_models/graphics.h"
#include "src/GPU/kernel_data_models.h"



__global__ void calculate_horizontal_convolution(pixel *partial_calculation_data_vector, pixel const *input_image_data, 
                                         short const image_width, short const image_height, 
                                         Device_mask_collection const mask_collection, vector_filter const filter);

__global__ void calculate_vertical_convolution_and_write_results(
        pixel *output_image_data, pixel const *partial_calculation_data_vector,
        short const image_width, short const image_height, 
        Device_mask_collection const mask_collection, vector_filter const filter);