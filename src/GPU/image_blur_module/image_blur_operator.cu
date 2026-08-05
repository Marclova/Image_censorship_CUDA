#include "src/data_models/graphics.h"

#include "image_blur_operator.h"
#include <cuda.h>




__device__ short from_coordinates_to_index(short const x, short const y, short const matrix_width)
{
    return (y * matrix_width) + x;
}


__device__ short clamp_out_of_bounds(short const coordinate, short const border_value)
{
    if (coordinate >= border_value)
    {
        return border_value - 1;
    }
    else if (coordinate < 0)
    {
        return 0;
    }
    return coordinate;
}


__device__ bool is_operation_cancelled(short const mask_cord_x, short const mask_cord_y, 
                                       short const image_cord_x, short const image_cord_y, 
                                       short const image_width, short const image_height, mask const mask)
{

    // check out of bounds for the image
    if (image_cord_x >= image_width || image_cord_y >= image_height
        || image_cord_x < 0 || image_cord_y < 0)
    {
        return false;
    }
    // check out of bounds for the mask
    if (mask_cord_x >= mask.width || mask_cord_y >= mask.height
        || mask_cord_x < 0 || mask_cord_y < 0)
    {
	    return false;
    }
    //check if the pixel is selected for blurring
    if(from_coordinates_to_index(mask_cord_x, mask_cord_y, mask.width) >= mask.width * mask.height || !mask.selection_vector[from_coordinates_to_index(mask_cord_x, mask_cord_y, mask.width)])
    {
        return false;
    }
    return true;
}



    // Technical reminder:
        // - A grid is a 2D array of blocks (many blocks will work on a single grid)
        // - A block in this case is a 2D array of threads (many cores will work on a single block)
        // - A thread is a single core that will work on a single execution of the kernel function

    // Conceptual reminder:
        // - A grid corresponds to a mask
        // - A block corresponds to a partition of the area covered by the mask
        // - A thread corresponds to a pixel

// TODO: consider to use mask as raw data instead of passing it as a structure
__global__ void calculate_horizontal_convolution(pixel *partial_calculation_vector, pixel const *input_image, 
                                         short const image_width, short const image_height, 
                                         mask const mask, vector_filter const filter)
{
    // Matrix coordinates are used despite the use of vector types due to implementation requirements for the binomial blur algorithm. 

    // coordinates within the mask (not image coordinates)
    short mask_cord_x = blockIdx.x * blockDim.x + threadIdx.x;
    short mask_cord_y = blockIdx.y * blockDim.y + threadIdx.y;
    // short mask_index = from_coordinates_to_index(mask_cord_x, mask_cord_y, mask.width);
    // retrieve the corresponding coordinates in the image
    short image_cord_x = mask_cord_x + mask.corner_coordinates[0];
    short image_cord_y = mask_cord_y + mask.corner_coordinates[1];
    short image_index = from_coordinates_to_index(image_cord_x, image_cord_y, image_width);
    
    if (is_operation_cancelled(mask_cord_x, mask_cord_y, image_cord_x, image_cord_y, image_width, image_height, mask))
    {
        return;
    }

    // TODO: Optimize the iteration so that the coordinates conversion applies only once
    //calculate the partial results for a single pixel (other pixels in this mask will be calculated by other threads in the grid)
    short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
    for (size_t i = -filter_spread; i <= filter_spread; i++)
    {
        // not defining 'convolution_y' because this is a vertical convolution, so the y coordinate is not modified
        short convolution_x = clamp_out_of_bounds(image_cord_x + i, image_width);  // in the worst case scenario, the convolution will be the same for 'filter_spread+1' times, but trying to solve this with checks would worsen performance
        short convolution_index = from_coordinates_to_index(convolution_x, image_cord_y, image_width);
        short filter_coefficient = filter.coefficients[i + filter_spread];

        partial_calculation_vector[image_index].r += input_image[convolution_index].r * filter_coefficient;
        partial_calculation_vector[image_index].g += input_image[convolution_index].g * filter_coefficient;
        partial_calculation_vector[image_index].b += input_image[convolution_index].b * filter_coefficient;
    }
}


//TODO: consider to use mask as raw data instead of passing it as a structure
__global__ void calculate_vertical_convolution_and_write_results(
        pixel *output_image, pixel const *partial_calculation_vector,
        short const image_width, short const image_height, mask const mask, vector_filter const filter)
{
    // coordinates within the mask (not image coordinates)
    short mask_cord_x = blockIdx.x * blockDim.x + threadIdx.x;
    short mask_cord_y = blockIdx.y * blockDim.y + threadIdx.y;
    // retrieve the corresponding coordinates in the image
    short image_cord_x = mask_cord_x + mask.corner_coordinates[0];
    short image_cord_y = mask_cord_y + mask.corner_coordinates[1];
    short image_index = from_coordinates_to_index(image_cord_x, image_cord_y, image_width);

    if (is_operation_cancelled(mask_cord_x, mask_cord_y, image_cord_x, image_cord_y, image_width, image_height, mask))
    {
        return;
    }

    // TODO: Optimize the iteration so that the coordinates conversion applies only once
    //calculate the final blurred pixel value for the specific pixel (other pixels in this mask will be calculated by other threads in the grid)
    short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
    char r = 0;
    char g = 0;
    char b = 0;
    for (size_t i = -filter_spread; i <= filter_spread; i++)
    {
        // not defining 'convolution_x' because this is a horizontal convolution, so the x coordinate is not modified
        short convolution_y = clamp_out_of_bounds(image_cord_y + i, image_height);
        short convolution_index = from_coordinates_to_index(image_cord_x, convolution_y, image_width);
        short filter_coefficient = filter.coefficients[i + filter_spread];

        r += partial_calculation_vector[convolution_index].r * filter_coefficient;
        g += partial_calculation_vector[convolution_index].g * filter_coefficient;
        b += partial_calculation_vector[convolution_index].b * filter_coefficient;
    }
    r /= filter.divisor;
    g /= filter.divisor;
    b /= filter.divisor;
    output_image[image_index].r = r;
    output_image[image_index].g = g;
    output_image[image_index].b = b;
}