// #include "../data_models/graphics.h"
//#include "../GPU/image_blur_module/image_blur_api.h"
//#include "../GPU/image_blur_module/image_blur_operator.cu"



// vector_picture blur_image(const vector_picture input_image, const mask mask_array[], const vector_filter filter)
// {
//         // definition and allocation of variables on the GPU
//         pixel *d_input_image_data;
//         pixel *d_output_image_data; // output is initialized as a copy of the input, to be modified by the kernel
//         pixel *d_partial_calculation_matrix; // partial results append for filter application
//
//         cudaMalloc(&d_input_image_data, sizeof(pixel)*input_image.width*input_image.height);
//         cudaMalloc(&d_output_image_data, sizeof(pixel)*input_image.width*input_image.height);
//         cudaMalloc(&d_partial_calculation_matrix, sizeof(pixel)*input_image.width*input_image.height);
//         cudaMemcpy(d_input_image_data, input_image.data, sizeof(pixel)*input_image.width*input_image.height, cudaMemcpyHostToDevice);
//         cudaMemcpy(d_output_image_data, input_image.data, sizeof(pixel)*input_image.width*input_image.height, cudaMemcpyHostToDevice);
//         cudaMemcpy(d_partial_calculation_matrix, input_image.data, sizeof(pixel)*input_image.width*input_image.height, cudaMemcpyHostToDevice);
//
//         // definition of variables on the CPU
//         short block_size = 16;
//         short mask_count = sizeof(mask_array) / sizeof(mask_array[0]);
//         dim3 block(block_size, block_size);
//         dim3* grid_array = new dim3[mask_count];
        //
        // // creating a grid for each mask and starting a partial computation for each mask
        // for (size_t i = 0; i < mask_count; i++)
        // {
        //     mask selected_mask = mask_array[i];
        //
        //     // a grid is composed of multiple blocks with fixed dimension; in a way to fit the mask size and overall shape
        //     short grid_x = ceil(selected_mask.width / block_size);
        //     short grid_y = ceil(selected_mask.height / block_size);
        //     grid_array[i] = dim3(grid_x, grid_y);
        //
        //     calculate_horizontal_convolution<<<grid_array[i], block>>>(d_input_image_data, d_partial_calculation_matrix,
        //                                               input_image.width, input_image.height,
        //                                               selected_mask, filter);
        // }
        // cudaDeviceSynchronize(); // synchronize calculations on d_partial_calculation_matrix before applying the filter
        // for (size_t i = 0; i < mask_count; i++)
        // {
        //     mask selected_mask = mask_array[i];
        //
        //     calculate_vertical_convolution_and_write_results<<<grid_array[i], block>>>(
        //         d_output_image_data, d_partial_calculation_matrix,
        //         input_image.width, input_image.height, selected_mask, filter);
        // }

//         // synchronize and copy the output image data from the GPU to the CPU
//         cudaDeviceSynchronize(); //TODO: consider to remove this synchronization, 'cudaMemcpy' should do the synchronization implicitly
//         pixel *h_output_image_data = (pixel *)malloc(sizeof(pixel)*input_image.width*input_image.height);
//         cudaMemcpy(h_output_image_data, d_output_image_data, sizeof(pixel)*input_image.width*input_image.height, cudaMemcpyDeviceToHost);
//
//         vector_picture image_to_return = {
//             h_output_image_data,
//             input_image.width,
//             input_image.height
//         };
//
//         // free the allocated memory
//         cudaFree(d_input_image_data);
//         cudaFree(d_output_image_data);
//         cudaFree(h_output_image_data);
//
//         return image_to_return;
// }