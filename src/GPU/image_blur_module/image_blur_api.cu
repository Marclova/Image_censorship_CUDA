#include "src/data_models/graphics.h"
#include "src/GPU/kernel_data_models.h"

#include "image_blur_api.h"

#include <cuda_runtime_api.h>
#include "image_blur_operator.h"
#include <iostream>




struct Mask_array_info
{
    short max_width;
    short max_height;
    short overall_data_size; // it needs to be stored aside because it's not homogeneously distributed through the various masks.
    short mask_count;
};



/// @brief Private function that extract useful data from a mask array and puts them into a 'Mask_array_info' struct.
/// @param mask_array The array of masks to get the information from.
/// @param mask_count The number of masks in the provided array.
/// @return The output struct to put the extracted info into.
static Mask_array_info mask_array_info_extraction(const mask mask_array[], const short mask_count)
{
    Mask_array_info array_info = {};
    // std::cout << "extracted info:" <<std::endl;
    for (size_t i = 0; i < mask_count; i++)
    {
        // std::cout << "     > mask " << i+1 << ":" << std::endl;
        mask selected_mask = mask_array[i];

        array_info.max_width = max(array_info.max_width, selected_mask.width);
        // std::cout << "      >> mask width: " << selected_mask.width << std::endl;
        // std::cout << "      >> max width: " << array_info.max_width << std::endl;

        array_info.max_height = max(array_info.max_height, selected_mask.height);
        // std::cout << "      >> mask height: " << selected_mask.height << std::endl;
        // std::cout << "      >> max height: " << array_info.max_height << std::endl;

        array_info.overall_data_size += (selected_mask.width * selected_mask.height * sizeof(bool));
        // std::cout << "      >> added data size: " << selected_mask.width << " * " << selected_mask.height << " * " << sizeof(bool) << 
        //                         " = " << selected_mask.width * selected_mask.height * sizeof(bool) << std::endl;
        // std::cout << "      >> overall data size: " << array_info.overall_data_size << std::endl;
    }
    array_info.mask_count = mask_count;
    return array_info;
}


/// @brief Private function that flattens the provided array of masks into a single array of continuous data, 
///         also defining the offsets (for data extraction) and metadata (for mask information) arrays.
/// @param mask_array The array of masks to be flattened and copied.
/// @param input_array_info Useful info about the provided array.
/// @return The collection of masks to copy the flattened data into 
///             (This data struct is meant to be used as "by-value parameter" for kernel calls).
static Device_mask_collection device_mask_collection_init_and_alloc(const mask mask_array[], const Mask_array_info input_array_info)
{
    Device_mask_collection d_mask_collection_to_return = {};

    bool *append_mask_data = (bool *)malloc(input_array_info.overall_data_size);
    short *append_offsets = (short *)malloc(sizeof(short)*(input_array_info.mask_count+1));
    append_offsets[0] = 0;
    Device_mask_metaData *append_metadata_array = (Device_mask_metaData *)malloc(sizeof(Device_mask_metaData)*input_array_info.mask_count);
    for (size_t i = 0; i < input_array_info.mask_count; i++)
    {
        // iterate each mask to allocate
        mask selected_mask = mask_array[i];

        // std::cout << "     > Mask selected" << std::endl;

        // update the offsets
        short current_offset = append_offsets[i];
        short new_offset = append_offsets[i] + (selected_mask.width * selected_mask.height);
        append_offsets[i+1] = new_offset;

        // std::cout << "     > Offsets updated" << std::endl;

        // append the iterated mask data to the overall masks data array
        memcpy(append_mask_data + current_offset, 
               selected_mask.selection_vector, sizeof(bool)*(new_offset-current_offset));

        // std::cout << "     > Mask data copied" << std::endl;

        // save other information about the mask in the metadata array
        append_metadata_array[i] = {selected_mask.corner_coordinates[0], selected_mask.corner_coordinates[1], 
                             selected_mask.width, selected_mask.height};

        // std::cout << "     > Metadata saved" << std::endl;
    }
    bool *d_mask_data_array;
    short *d_offsets;
    Device_mask_metaData *d_mask_metadata_array;
    cudaMalloc(&d_mask_data_array, input_array_info.overall_data_size);
    cudaMalloc(&d_offsets, sizeof(short)*(input_array_info.mask_count+1));
    cudaMalloc(&d_mask_metadata_array, sizeof(Device_mask_metaData)*input_array_info.mask_count);
    // std::cout << "     > Device mask collection allocated" << std::endl;
    cudaMemcpy(d_mask_data_array, append_mask_data, input_array_info.overall_data_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_offsets, append_offsets, sizeof(short)*(input_array_info.mask_count+1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_mask_metadata_array, append_metadata_array, sizeof(Device_mask_metaData)*input_array_info.mask_count, 
                cudaMemcpyHostToDevice);

    std::cout << "Debug info: Check allocated mask data (before link with host): " << std::endl;
    bool to_print[3];
    cudaMemcpy(to_print, d_mask_data_array, sizeof(bool)*3, cudaMemcpyDeviceToHost);
    std::cout << "     > mask data:[ " << to_print[0] << ", " << to_print[1] << ", " << to_print[2] << ", " "... ]" << std::endl;

    d_mask_collection_to_return.mask_count = input_array_info.mask_count;
    d_mask_collection_to_return.mask_data_array = d_mask_data_array;
    d_mask_collection_to_return.offsets = d_offsets;
    d_mask_collection_to_return.mask_metadata_array = d_mask_metadata_array;

    std::cout << "     > mask count on device mask collection (host-side check): "; std:: cout << d_mask_collection_to_return.mask_count; std::cout << std::endl;

    free(append_mask_data);
    free(append_offsets);
    free(append_metadata_array);

    return d_mask_collection_to_return;
}



vector_picture blur_image(const vector_picture input_image, const mask mask_array[], const short mask_count, const vector_filter filter)
{
    // definition of host variables
    short image_size = sizeof(pixel)*(input_image.width*input_image.height);
    Mask_array_info h_mask_array_info = mask_array_info_extraction(mask_array, mask_count);
    Device_mask_collection flattened_mask_data_collection = device_mask_collection_init_and_alloc(mask_array, h_mask_array_info);

    // std::cout << "Debug info: Check allocated mask data (after link with host): \n";
    // bool value_to_print[3];
    // cudaMemcpy(value_to_print, flattened_mask_data_collection.mask_data_array, sizeof(bool)*3, cudaMemcpyDeviceToHost);
    // std::cout << "     > device data (from device): " << "[ " << value_to_print[0] << ", " << value_to_print[1] << ", " << value_to_print[2] << ", " "... ]" << std::endl;
    // std::cout << "     > mask count on device mask collection (host-side check): "; std:: cout << flattened_mask_data_collection.mask_count; std::cout << std::endl;

    // std::cout << "Debug info: initialization checks:" << std::endl;
    // std::cout << "     > Given mask data: ";
    // std::cout << "[ " << mask_array[0].selection_vector[0] << ", " << mask_array[0].selection_vector[1]
    //             << ", " << mask_array[0].selection_vector[2] << " ...]" << std::endl;
    // std::cout << "     > initialized overall data size: " << h_mask_array_info.overall_data_size << std::endl;
    // std::cout << "     > initialized mask count: " << h_mask_array_info.mask_count << std::endl;
    // std::cout << "     > initialized max width: " << h_mask_array_info.max_width << std::endl;
    // std::cout << "     > initialized max height: " << h_mask_array_info.max_height << std::endl;

    // definition of device variables
    pixel *d_input_image_data = {}; // 
    pixel *d_output_image_data = {}; // output is initialized as a copy of the input, to be modified by the kernel
    pixel *d_partial_calculation_vector = {}; // partial results append for filter application
    short *d_filter_coefficients = {};

    std::cout << "Debug info: Allocation of device variables ..." << std::endl;

    // allocation and initialization of all defined variables
    cudaMalloc(&d_input_image_data, image_size);
    cudaMalloc(&d_output_image_data, image_size);
    cudaMalloc(&d_partial_calculation_vector, image_size);
    cudaMalloc(&d_filter_coefficients, sizeof(short)*filter.size);
    cudaMemcpy(d_input_image_data, input_image.data, image_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_output_image_data, input_image.data, image_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_filter_coefficients, filter.coefficients, sizeof(short)*filter.size, cudaMemcpyHostToDevice);
    
    // cudaMemcpy(d_partial_calculation_vector, input_image.data, image_size, cudaMemcpyHostToDevice);

    // proceeding to perform the kernel call
    short block_size = 16; // optimum block size (16*16=256)
    short grid_width = (h_mask_array_info.max_width + block_size-1) / block_size;
    short grid_height = (h_mask_array_info.max_height + block_size-1) / block_size;
    dim3 block(block_size, block_size);
    dim3 grid(grid_width, grid_height, mask_count); // creating a grid(max_x,max_y) for each mask
    // printf("\nBefore kernel call: %s\n", cudaGetErrorString(cudaGetLastError()));
    calculate_horizontal_convolution<<<grid, block>>>(d_partial_calculation_vector, d_input_image_data, 
                                                      input_image.width, input_image.height, 
                                                      flattened_mask_data_collection, 
                                                      vector_filter({d_filter_coefficients, filter.size, filter.divisor}));
    cudaDeviceSynchronize();  
    // printf("After kernel call: %s\n", cudaGetErrorString(cudaGetLastError()));
    
    calculate_vertical_convolution_and_write_results<<<grid, block>>>(d_output_image_data, d_partial_calculation_vector,
                                                                      input_image.width, input_image.height, 
                                                                      flattened_mask_data_collection, 
                                                                      vector_filter({d_filter_coefficients, filter.size, filter.divisor}));
    cudaDeviceSynchronize(); //TODO: consider to remove this synchronization, 'cudaMemcpy' should do the synchronization implicitly

    pixel *h_output_image_data = (pixel *)malloc(image_size);
    cudaMemcpy(h_output_image_data, d_output_image_data, image_size, cudaMemcpyDeviceToHost);

    // cudaMemcpy(h_output_image_data, d_partial_calculation_vector, sizeof(pixel)*(input_image.width*input_image.height), cudaMemcpyDeviceToHost);

    vector_picture image_to_return = {
        h_output_image_data,
        input_image.width,
        input_image.height
    };

    // free the allocated memory
    cudaFree(d_input_image_data);
    cudaFree(d_output_image_data);
    cudaFree(d_partial_calculation_vector);
    cudaFree(flattened_mask_data_collection.mask_data_array);
    cudaFree(flattened_mask_data_collection.offsets);
    cudaFree(flattened_mask_data_collection.mask_metadata_array);
    cudaFree(d_filter_coefficients);
    // free(h_output_image_data);  //TODO: free the output somewhere else, after the image is used, to avoid memory leak

    printf("Debug info: CUDA final error state = {%s}\n", cudaGetErrorString(cudaGetLastError()));
    return image_to_return;
}