#include "src/data_models/graphics.h"
#include "src/GPU/kernel_data_models.h"

#include "image_blur_operator.h"
#include <cuda.h>
#include <stdio.h>
#include <assert.h>




static __device__ short from_coordinates_to_index(short const x, short const y, short const matrix_width, short matrix_height)
{
    assert(x >= 0 && x < matrix_width);
    assert(y >= 0 && y < matrix_height);
    
    return (y * matrix_width) + x;
}


// static __device__ bool* get_mask_data(Device_mask_collection const mask_collection, short const mask_index)
// {
//     short data_index_start = mask_collection.offsets[mask_index];
//     short data_index_length = (mask_collection.offsets[mask_index+1] - data_index_start) -1;
    
//     bool *array_to_return;
//     memcpy(&array_to_return, &mask_collection.mask_data_array[data_index_start], data_index_length * sizeof(bool));
//     return array_to_return;
// }


static __device__ short clamp_out_of_bounds(short const coordinate, short const border_value)
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


static __device__ bool shall_thread_operate(Device_mask_collection const mask_collection)
{
    // // check if the mask exists
    // if (blockIdx.z >= mask_collection.mask_count)
    // {
    //     return false;
    // }
    
    // check if the mask's covered area extends up to this block
    short mask_width = mask_collection.mask_metadata_array[blockIdx.z].width;
    short mask_height = mask_collection.mask_metadata_array[blockIdx.z].height;
    // if (blockIdx.x >= ((mask_width + blockDim.x - 1) / blockDim.x))
    // {
    //     return false;
    // }
    // if (blockIdx.y >= ((mask_height + blockDim.y - 1) / blockDim.y))
    // {
    //     return false;
    // }

    // Check if thread is within the mask's covered area
    if(blockIdx.x == (gridDim.x-1) &&                           // check if the block includes the edge of the area...
       threadIdx.x >= (mask_width - (gridDim.x-1)*blockDim.x))  // ... and if the specific thread exceeds the area.
    {
        return false;
    }
    if(blockIdx.y == (gridDim.y-1) &&                           // check if the block includes the edge of the area...
       threadIdx.y >= (mask_height - (gridDim.y-1)*blockDim.y))  // ... and if the specific thread exceeds the area.
    {
        return false;
    }

    return true;
}


static __device__ bool is_pixel_selected(// short const mask_cord_x, short const mask_cord_y, 
                                             // short const image_cord_x, short const image_cord_y, 
                                             short const image_index, short const mask_index, 
                                             short const image_width, short const image_height, 
                                             const Device_mask_collection mask_collection)
{
    // if (image_index >= (image_width*image_height) || 
    //     mask_index >= (mask_collection.mask_metadata_array[blockIdx.z].width*mask_collection.mask_metadata_array[blockIdx.z].height))
    // {
    //     return false;
    // }
    
    //check if the pixel is selected for blurring
    // printf("Mask pixel (%d) return: ", mask_index);
    // printf("%s\n", (mask_collection.mask_data_array[mask_collection.offsets[blockIdx.z]+mask_index] ? "true" : "false"));
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

// TODO: try to remove all usage of matrix coordinates and use vector coordinates instead (deleting the 'from_coordinates_to_index' function would be the best result)
__global__ void calculate_horizontal_convolution(pixel *partial_calculation_data_vector, pixel const *input_image_data, 
                                         short const image_width, short const image_height, 
                                         Device_mask_collection const mask_collection, vector_filter const filter)
{
    // if (threadIdx.x == 0 && threadIdx.y == 0)
    // {
    //     printf("Thread (%u,%u) has been executed!\n", threadIdx.x, threadIdx.y);
    // }

    if(!shall_thread_operate(mask_collection))
    {
        return;
    }

    // printf("Extracted selection data: ");
    // printf("[ %d, %d, %d, ... ]\n", mask_selection_vector[0], mask_selection_vector[1], mask_selection_vector[2]);

    Device_mask_metaData mask_metadata = mask_collection.mask_metadata_array[blockIdx.z];
    // Matrix coordinates are used despite the use of vector types due to implementation requirements for the binomial blur algorithm. 
    // coordinates within the mask (not image coordinates)
    short mask_cord_x = threadIdx.x + (blockIdx.x*blockDim.x);
    short mask_cord_y = threadIdx.y + (blockIdx.y*blockDim.y);
    short mask_index = from_coordinates_to_index(mask_cord_x, mask_cord_y, mask_metadata.width, mask_metadata.height);

    // retrieve the corresponding coordinates in the image
    short image_cord_x = mask_cord_x + mask_metadata.x_cord;
    short image_cord_y = mask_cord_y + mask_metadata.y_cord;
    short image_index = from_coordinates_to_index(image_cord_x, image_cord_y, image_width, image_height);

    // if (!is_pixel_selected(mask_cord_x, mask_cord_y, image_cord_x, image_cord_y, image_width, image_height, 
    //                            mask_metadata))
    if (!is_pixel_selected(image_index, mask_index, image_width, image_height, mask_collection))
    {
        return;
    }

    // printf("Thread (%u,%u) coordinates: image(%d,%d : %d), mask(%d,%d : %d)\n", threadIdx.x, threadIdx.y, image_cord_x, image_cord_y, image_index, mask_cord_x, mask_cord_y, mask_index);

    // TODO: Optimize the iteration so that the coordinates conversion applies only once
    //calculate the partial results for a single pixel (other pixels in this mask will be calculated by other threads in the grid)
    short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
    short r = 0;
    short g = 0;
    short b = 0;
    for (short i = -filter_spread; i <= filter_spread; i++)
    {
        // not defining 'convolution_y' because this is a vertical convolution, so the y coordinate is not modified
        short convolution_x = clamp_out_of_bounds(image_cord_x + i, image_width);  // in the worst case scenario, the convolution will be the same for 'filter_spread+1' times, but trying to solve this with checks would worsen performance
        short convolution_index = from_coordinates_to_index(convolution_x, image_cord_y, image_width, image_height);
        short filter_coefficient = filter.coefficients[i + filter_spread];

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
    // free(&mask_selection_vector);
}


//TODO: consider to use mask as raw data instead of passing it as a structure
__global__ void calculate_vertical_convolution_and_write_results(
        pixel *output_image_data, pixel const *partial_calculation_data_vector,
        short const image_width, short const image_height, 
        Device_mask_collection const mask_collection, vector_filter const filter)
{
    if(!shall_thread_operate(mask_collection))
    {
        return;
    }    

    Device_mask_metaData mask_metadata = mask_collection.mask_metadata_array[blockIdx.z];
    // Matrix coordinates are used despite the use of vector types due to implementation requirements for the binomial blur algorithm. 
    // coordinates within the mask (not image coordinates)
    short mask_cord_x = threadIdx.x + (blockIdx.x*blockDim.x);
    short mask_cord_y = threadIdx.y + (blockIdx.y*blockDim.y);
    short mask_index = from_coordinates_to_index(mask_cord_x, mask_cord_y, mask_metadata.width, mask_metadata.height);

    // retrieve the corresponding coordinates in the image
    short image_cord_x = mask_cord_x + mask_metadata.x_cord;
    short image_cord_y = mask_cord_y + mask_metadata.y_cord;
    short image_index = from_coordinates_to_index(image_cord_x, image_cord_y, image_width, image_height);

    // if (!is_pixel_selected(mask_cord_x, mask_cord_y, image_cord_x, image_cord_y, image_width, image_height, 
    //                            mask_metadata))
    if (!is_pixel_selected(image_index, mask_index, image_width, image_height, mask_collection))
    {
        return;
    }

    // TODO: Optimize the iteration so that the coordinates conversion applies only once
    //calculate the final blurred pixel value for the specific pixel (other pixels in this mask will be calculated by other threads in the grid)
    short filter_spread = (filter.size-1) / 2; // the number of pixels to consider around the center pixel
    short r = 0;
    short g = 0;
    short b = 0;
    for (short i = -filter_spread; i <= filter_spread; i++)
    {
        // not defining 'convolution_x' because this is a horizontal convolution, so the x coordinate is not modified
        short convolution_y = clamp_out_of_bounds(image_cord_y + i, image_height);
        short convolution_index = from_coordinates_to_index(image_cord_x, convolution_y, image_width, image_height);
        short filter_coefficient = filter.coefficients[i + filter_spread];

        r += partial_calculation_data_vector[convolution_index].r * filter_coefficient;
        g += partial_calculation_data_vector[convolution_index].g * filter_coefficient;
        b += partial_calculation_data_vector[convolution_index].b * filter_coefficient;

        // if(image_cord_x == 4 && image_cord_y == 4)
        // {
            // printf("pixel (%d,%d) has been convoluted.\n", image_cord_x, image_cord_y);
        // }
    }
    // After the division the values are supposed to be less than '256'
    r /= filter.divisor;
    g /= filter.divisor;
    b /= filter.divisor;
    output_image_data[image_index].r = (unsigned char)r;
    output_image_data[image_index].g = (unsigned char)g;
    output_image_data[image_index].b = (unsigned char)b;
}