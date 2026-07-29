//#include <cuda.h>
//#include "../data_models/graphics.h"


//
// __global__ void calculate_horizontal_convolution(pixel const *input_image, pixel *partial_calculation_matrix,
//                                          short const image_width, short const image_height,
//                                          mask const mask, vector_filter const filter)
// {
//     // coordinates within the mask (not image coordinates)
//     short x = blockIdx.x * blockDim.x + threadIdx.x;
//     short y = blockIdx.y * blockDim.y + threadIdx.y;
//     // retrieve the corresponding coordinates in the image
//     short image_x = x + mask.corner_coordinates[0];
//     short image_y = y + mask.corner_coordinates[1];
//     short image_index = from_coordinates_to_index(image_x, image_y, image_width);
//
//     if (is_operation_cancelled(x, y, image_x, image_y, image_width, image_height, mask))
//     {
//         return;
//     }
//
//     //calculate the partial results for the specific pixel (other pixels in this mask will be calculated by other threads in the grid)
//     short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
//     for (size_t i = -filter_spread; i <= filter_spread; i++)
//     {
//         // not defining 'convolution_y' because this is a vertical convolution, so the y coordinate is not modified
//         short convolution_x = clamp_out_of_bounds(image_x + i, image_width);
//         short convolution_index = from_coordinates_to_index(convolution_x, image_y, image_width);
//         short filter_coefficient = filter.coefficients[i + filter_spread];
//
//         partial_calculation_matrix[image_index].r += input_image[convolution_index].r * filter_coefficient;
//         partial_calculation_matrix[image_index].g += input_image[convolution_index].g * filter_coefficient;
//         partial_calculation_matrix[image_index].b += input_image[convolution_index].b * filter_coefficient;
//     }
// }


// __global__ void calculate_vertical_convolution_and_write_results(
//         pixel *output_image, pixel const *partial_calculation_matrix,
//         short const image_width, short const image_height, mask const mask, vector_filter const filter)
// {
//     // coordinates within the mask (not image coordinates)
//     short x = blockIdx.x * blockDim.x + threadIdx.x;
//     short y = blockIdx.y * blockDim.y + threadIdx.y;
//     // retrieve the corresponding coordinates in the image
//     short image_x = x + mask.corner_coordinates[0];
//     short image_y = y + mask.corner_coordinates[1];
//     short image_index = from_coordinates_to_index(image_x, image_y, image_width);
//
//     if (is_operation_cancelled(x, y, image_x, image_y, image_width, image_height, mask))
//     {
//         return;
//     }
//
//     //calculate the final blurred pixel value for the specific pixel (other pixels in this mask will be calculated by other threads in the grid)
//     short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
//     char r = 0;
//     char g = 0;
//     char b = 0;
//     for (size_t i = -filter_spread; i <= filter_spread; i++)
//     {
//         // not defining 'convolution_x' because this is a horizontal convolution, so the x coordinate is not modified
//         short convolution_y = clamp_out_of_bounds(image_y + i, image_height);
//         short convolution_index = from_coordinates_to_index(image_x, convolution_y, image_width);
//         short filter_coefficient = filter.coefficients[i + filter_spread];
//
//         r += partial_calculation_matrix[convolution_index].r * filter_coefficient;
//         g += partial_calculation_matrix[convolution_index].g * filter_coefficient;
//         b += partial_calculation_matrix[convolution_index].b * filter_coefficient;
//     }
//     r /= filter.divisor;
//     g /= filter.divisor;
//     b /= filter.divisor;
//     output_image[image_index].r = r;
//     output_image[image_index].g = g;
//     output_image[image_index].b = b;
// }
//
//
//
// __device__ short from_coordinates_to_index(short const x, short const y, short const matrix_width)
// {
//     return (y * matrix_width) + x;
// }
//
//
// __device__ short clamp_out_of_bounds(short const coordinate, short const max_value)
// {
//     if (coordinate >= max_value)
//     {
//         return max_value - 1;
//     }
//     else if (coordinate < 0)
//     {
//         return 0;
//     }
//     return coordinate;
// }


// __device__ bool is_operation_cancelled(short const x, short const y, short const image_x, short const image_y,
//                                        short const image_width, short const image_height, mask const mask)
// {
//     // check out of bounds for the image
//     if (image_x >= image_width || image_y >= image_height
//         || image_x < 0 || image_y < 0)
//     {
//         return false;
//     }
//     // check out of bounds for the mask
//     if (x >= mask.width || y >= mask.height
//         || x < 0 || y < 0)
//     {
// 	    return false;
//     }
    //check if the pixel is selected for blurring
//     if(!mask.selection_matrix[from_coordinates_to_index(x, y, mask.width)])
//     {
//         return false;
//     }
//     return true;
// }