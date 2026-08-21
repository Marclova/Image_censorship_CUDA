#include "src/data_models/graphics.h"
#include "src/GPU/kernel_data_models.h"

#include "image_blur_operator.h"
#include <cuda.h>
#include <stdio.h>
#include <assert.h>




static __device__ unsigned int from_coordinates_to_index(unsigned short const x, unsigned short const y, 
                                                         unsigned short const matrix_width, unsigned short matrix_height)
{
    assert(x < matrix_width);
    assert(y < matrix_height);
    
    return (y * matrix_width) + x;
}


static __device__ unsigned short clamp_out_of_bounds(unsigned short const coordinate, unsigned short const border_value)
{
    if (coordinate >= border_value)
    {
        return border_value - 1;
    }
    return coordinate;
}


static __device__ bool shall_thread_operate(Device_mask_collection const mask_collection)
{
    // check if the mask's covered area extends up to this block
    if (mask_collection.mask_metadata_array[blockIdx.z].width <= threadIdx.x+(blockIdx.x*blockDim.x))
    {
        // printf("Thread rejected: block [%d,%d,%d], thread [%d,%d,%d]\n", blockIdx.x, blockIdx.y, blockIdx.z, threadIdx.x, threadIdx.y, threadIdx.z);
        return false;
    }
    if (mask_collection.mask_metadata_array[blockIdx.z].height <= threadIdx.y+(blockIdx.y*blockDim.y))
    {
        return false;
    }
    return true;
}


static __device__ bool is_pixel_selected(unsigned int const mask_index, const Device_mask_collection mask_collection)
{    
    return mask_collection.mask_data_array[mask_collection.offsets[blockIdx.z]+mask_index];
}



    // Technical reminder:
        // - A grid has three coordinates but it's actually a 2D array of blocks (x,y) + the mask ID (z) 
        //      (many blocks will work on a single grid)
        // - A block in this case is a 2D array of threads (many cores will work on a single block)
        // - A thread is a single core that will work on a single execution of the kernel function

    // Conceptual reminder:
        // - A grid corresponds to a set of masks (the blockIdx.z represents the mask ID)
        // - A block corresponds to a partition of the area covered by the mask
        // - A thread corresponds to a pixel


__global__ void calculate_horizontal_convolution(pixel *partial_calculation_data_vector, pixel const *input_image_data, 
                                                 unsigned short const image_width, unsigned short const image_height, 
                                                 Device_mask_collection const mask_collection, vector_filter const filter)
{
    if(!shall_thread_operate(mask_collection))
    {
        return;
    }

    Device_mask_metaData mask_metadata = mask_collection.mask_metadata_array[blockIdx.z];
    // Matrix coordinates are used despite the use of vector types due to implementation requirements for the binomial blur algorithm. 
    // coordinates within the mask (not image coordinates)
    unsigned short mask_cord_x = threadIdx.x + (blockIdx.x*blockDim.x);
    unsigned short mask_cord_y = threadIdx.y + (blockIdx.y*blockDim.y);
    unsigned int mask_index = from_coordinates_to_index(mask_cord_x, mask_cord_y, mask_metadata.width, mask_metadata.height);

    // retrieve the corresponding coordinates in the image
    unsigned short image_cord_x = mask_cord_x + mask_metadata.x_cord;
    unsigned short image_cord_y = mask_cord_y + mask_metadata.y_cord;
    unsigned int image_index = from_coordinates_to_index(image_cord_x, image_cord_y, image_width, image_height);

    if (!is_pixel_selected(mask_index, mask_collection))
    {
        return;
    }

    //calculate the partial results for a single pixel (other pixels in this mask will be calculated by other threads in the grid)
    short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
    unsigned short r = 0;
    unsigned short g = 0;
    unsigned short b = 0;
    for (short i = -filter_spread; i <= filter_spread; i++)
    {
        // not defining 'convolution_y' because this is a vertical convolution, so the y coordinate is not modified
        unsigned short convolution_x = clamp_out_of_bounds(image_cord_x + i, image_width);  // in the worst case scenario, the convolution will be the same for 'filter_spread+1' times, but trying to solve this with checks would worsen performance
        unsigned int convolution_index = from_coordinates_to_index(convolution_x, image_cord_y, image_width, image_height);
        unsigned short filter_coefficient = filter.coefficients[i + filter_spread];

        r += input_image_data[convolution_index].r * filter_coefficient;
        g += input_image_data[convolution_index].g * filter_coefficient;
        b += input_image_data[convolution_index].b * filter_coefficient;
    }
    // After the division the values are supposed to be less than '256'
    r /= filter.divisor;
    g /= filter.divisor;
    b /= filter.divisor;
    partial_calculation_data_vector[image_index].r += (unsigned char)r;
    partial_calculation_data_vector[image_index].g += (unsigned char)g;
    partial_calculation_data_vector[image_index].b += (unsigned char)b;
}


__global__ void calculate_vertical_convolution_and_write_results(pixel *output_image_data, pixel const *partial_calculation_data_vector,
                                                                 unsigned short const image_width, unsigned short const image_height, 
                                                                 Device_mask_collection const mask_collection, vector_filter const filter)
{
    if(!shall_thread_operate(mask_collection))
    {
        return;
    }    

    Device_mask_metaData mask_metadata = mask_collection.mask_metadata_array[blockIdx.z];
    // Matrix coordinates are used despite the use of vector types due to implementation requirements for the binomial blur algorithm. 
    // coordinates within the mask (not image coordinates)
    unsigned short mask_cord_x = threadIdx.x + (blockIdx.x*blockDim.x);
    unsigned short mask_cord_y = threadIdx.y + (blockIdx.y*blockDim.y);
    unsigned int mask_index = from_coordinates_to_index(mask_cord_x, mask_cord_y, mask_metadata.width, mask_metadata.height);

    // retrieve the corresponding coordinates in the image
    unsigned short image_cord_x = mask_cord_x + mask_metadata.x_cord;
    unsigned short image_cord_y = mask_cord_y + mask_metadata.y_cord;
    unsigned int image_index = from_coordinates_to_index(image_cord_x, image_cord_y, image_width, image_height);

    if (!is_pixel_selected(mask_index, mask_collection))
    {
        return;
    }

    //calculate the final blurred pixel value for the specific pixel (other pixels in this mask will be calculated by other threads in the grid)
    short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
    unsigned short r = 0;
    unsigned short g = 0;
    unsigned short b = 0;
    for (short i = -filter_spread; i <= filter_spread; i++)
    {
        // not defining 'convolution_x' because this is a horizontal convolution, so the x coordinate is not modified
        unsigned short convolution_y = clamp_out_of_bounds(image_cord_y + i, image_height);
        unsigned int convolution_index = from_coordinates_to_index(image_cord_x, convolution_y, image_width, image_height);
        unsigned short filter_coefficient = filter.coefficients[i + filter_spread];

        r += partial_calculation_data_vector[convolution_index].r * filter_coefficient;
        g += partial_calculation_data_vector[convolution_index].g * filter_coefficient;
        b += partial_calculation_data_vector[convolution_index].b * filter_coefficient;
    }
    // After the division the values are supposed to be less than '256'
    r /= filter.divisor;
    g /= filter.divisor;
    b /= filter.divisor;
    output_image_data[image_index].r = (unsigned char)r;
    output_image_data[image_index].g = (unsigned char)g;
    output_image_data[image_index].b = (unsigned char)b;
}