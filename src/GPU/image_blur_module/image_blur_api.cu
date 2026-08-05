#include "src/data_models/graphics.h"

#include "image_blur_api.h"

#include <cuda_runtime_api.h>
#include "image_blur_operator.h"




vector_picture blur_image(const vector_picture input_image, const mask mask_array[], const short mask_count, const vector_filter filter)
{
        // definition and allocation of variables on the GPU
        pixel *d_input_image_data;
        pixel *d_output_image_data; // output is initialized as a copy of the input, to be modified by the kernel
        pixel *d_partial_calculation_vector; // partial results append for filter application

        // cudaMalloc(&d_mask_data_array)
        cudaMalloc(&d_input_image_data, sizeof(pixel)*(input_image.width*input_image.height));
        cudaMalloc(&d_output_image_data, sizeof(pixel)*(input_image.width*input_image.height));
        cudaMalloc(&d_partial_calculation_vector, sizeof(pixel)*(input_image.width*input_image.height));
        cudaMemcpy(d_input_image_data, input_image.data, sizeof(pixel)*(input_image.width*input_image.height), cudaMemcpyHostToDevice);
        cudaMemcpy(d_output_image_data, input_image.data, sizeof(pixel)*(input_image.width*input_image.height), cudaMemcpyHostToDevice);
        // cudaMemcpy(d_partial_calculation_vector, input_image.data, sizeof(pixel)*(input_image.width*input_image.height), cudaMemcpyHostToDevice);

        // definition of variables on the CPU
        short block_size = 16;
        dim3 block(block_size, block_size);
        
        // creating a grid for each mask and starting a partial computation for each mask
        dim3* grid_array = new dim3[mask_count];
        for (size_t i = 0; i < mask_count; i++)
        {
            mask selected_mask = mask_array[i];
        
            // a grid is composed of multiple blocks with fixed dimension; in a way to fit the mask size and overall shape
            short grid_x = (selected_mask.width + block_size - 1) / block_size;
            short grid_y = (selected_mask.height + block_size - 1) / block_size;
            grid_array[i] = dim3(grid_x, grid_y);
        
            calculate_horizontal_convolution<<<grid_array[i], block>>>(d_partial_calculation_vector, d_input_image_data, 
                                                      input_image.width, input_image.height,
                                                      selected_mask, filter);
        }
        cudaDeviceSynchronize(); // synchronize calculations on d_partial_calculation_vector

        // completing the partial calculation
        for (size_t i = 0; i < mask_count; i++)
        {
            mask selected_mask = mask_array[i];
        
            calculate_vertical_convolution_and_write_results<<<grid_array[i], block>>>(
                d_output_image_data, d_partial_calculation_vector,
                input_image.width, input_image.height, selected_mask, filter);
        }

        // synchronize and copy the output image data from the GPU to the CPU
        cudaDeviceSynchronize(); //TODO: consider to remove this synchronization, 'cudaMemcpy' should do the synchronization implicitly

        pixel *h_output_image_data = (pixel *)malloc(sizeof(pixel)*(input_image.width*input_image.height));
        cudaMemcpy(h_output_image_data, d_output_image_data, sizeof(pixel)*(input_image.width*input_image.height), cudaMemcpyDeviceToHost);

        vector_picture image_to_return = {
            h_output_image_data,
            input_image.width,
            input_image.height
        };

        // free the allocated memory
        cudaFree(d_input_image_data);
        cudaFree(d_output_image_data);
        cudaFree(d_partial_calculation_vector);
        // free(h_output_image_data);  //TODO: free the output somewhere else, after the image is used, to avoid memory leak

        return image_to_return;
}