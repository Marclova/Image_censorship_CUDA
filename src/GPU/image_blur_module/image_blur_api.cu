#include "src/data_models/graphics.h"
#include "src/data_models/kernel_data_models.h"

#include "image_blur_api.h"

#include <cuda_runtime_api.h>
#include "image_blur_operator.h"
#include <iostream>




struct Mask_array_info
{
    unsigned short max_width;
    unsigned short max_height;
    unsigned int overall_data_size; // it needs to be stored aside because it's not homogeneously distributed through the various masks.
    unsigned short mask_count;
};



/// @brief Private function that extract useful data from a mask array and puts them into a 'Mask_array_info' struct.
/// @param mask_array The array of masks to get the information from.
/// @param mask_count The number of masks in the provided array.
/// @return The output struct to put the extracted info into.
static Mask_array_info mask_array_info_extraction(const mask mask_array[], unsigned short mask_count)
{
    Mask_array_info array_info = {};
    for (size_t i = 0; i < mask_count; i++)
    {
        mask selected_mask = mask_array[i];

        array_info.max_width = max(array_info.max_width, selected_mask.width);

        array_info.max_height = max(array_info.max_height, selected_mask.height);

        array_info.overall_data_size += (selected_mask.width * selected_mask.height * sizeof(bool));
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
    unsigned int *append_offsets = (unsigned int *)malloc(sizeof(unsigned int)*(input_array_info.mask_count+1));
    append_offsets[0] = 0;
    Device_mask_metaData *append_metadata_array = (Device_mask_metaData *)malloc(sizeof(Device_mask_metaData)*input_array_info.mask_count);
    for (size_t i = 0; i < input_array_info.mask_count; i++)
    {
        // iterate each mask to allocate
        mask selected_mask = mask_array[i];

        // update the offsets
        unsigned int current_offset = append_offsets[i];
        unsigned int new_offset = append_offsets[i] + (selected_mask.width * selected_mask.height);
        append_offsets[i+1] = new_offset;

        // append the iterated mask data to the overall masks data array
        memcpy(append_mask_data + current_offset, 
               selected_mask.selection_vector, sizeof(bool)*(new_offset-current_offset));

        // save other information about the mask in the metadata array
        append_metadata_array[i] = {selected_mask.corner_coordinates[0], selected_mask.corner_coordinates[1], 
                             selected_mask.width, selected_mask.height};
    }
    bool *d_mask_data_array;
    unsigned int *d_offsets;
    Device_mask_metaData *d_mask_metadata_array;
    cudaMalloc(&d_mask_data_array, input_array_info.overall_data_size);
    cudaMalloc(&d_offsets, sizeof(unsigned int)*(input_array_info.mask_count+1));
    cudaMalloc(&d_mask_metadata_array, sizeof(Device_mask_metaData)*input_array_info.mask_count);

    cudaMemcpy(d_mask_data_array, append_mask_data, input_array_info.overall_data_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_offsets, append_offsets, sizeof(unsigned int)*(input_array_info.mask_count+1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_mask_metadata_array, append_metadata_array, sizeof(Device_mask_metaData)*input_array_info.mask_count, 
                cudaMemcpyHostToDevice);

    d_mask_collection_to_return.mask_count = input_array_info.mask_count;
    d_mask_collection_to_return.mask_data_array = d_mask_data_array;
    d_mask_collection_to_return.offsets = d_offsets;
    d_mask_collection_to_return.mask_metadata_array = d_mask_metadata_array;

    free(append_mask_data);
    free(append_offsets);
    free(append_metadata_array);

    return d_mask_collection_to_return;
}


// static void fix_masks_selection_area(const vector_picture input_image, mask mask_array[], unsigned short mask_count)
// {
//     // bool **append_selection_area = (bool **)malloc(input_image.width * sizeof(bool *));
//     // for (size_t i = 0; i < input_image.width; i++) {
//     //     append_selection_area[i] = (bool *)malloc(input_image.height * sizeof(bool));
//     // }

//     for (size_t i = 0; i < mask_count; i++)
//     {
//         mask& selected_mask = mask_array[i];

//         // out of border management
//         if ((selected_mask.corner_coordinates[0] + selected_mask.width) > input_image.width) // check out of border
//         {
//             selected_mask.width = (input_image.width) - selected_mask.corner_coordinates[0]; // maximum value set
//         }
//         if ((selected_mask.corner_coordinates[1] + selected_mask.height) > input_image.height) // check out of border
//         {
//             selected_mask.height = (input_image.height) - selected_mask.corner_coordinates[1]; // maximum value set
//         }

//         // // multiple selection management // T0D0: consider adding mask deletion and shrinking
//         // for (size_t mask_x = 0; mask_x < selected_mask.width; mask_x++)
//         // {
//         //     for (size_t mask_y = 0; mask_y < selected_mask.height; mask_y++)
//         //     {
//         //         unsigned int mask_index = mask_y*selected_mask.width+selected_mask.height;
//         //         if (!selected_mask.selection_vector[mask_index])
//         //         {
//         //             continue; // the pixel isw not selected
//         //         }
                
//         //         unsigned short image_x = mask_x + selected_mask.corner_coordinates[0];
//         //         unsigned short image_y = mask_y + selected_mask.corner_coordinates[1];
//         //         if (append_selection_area[image_x][image_y])  // remove selection from mask wherever the selection has already been performed.
//         //         {
//         //             selected_mask.selection_vector[mask_index] = false; // the image pixel has already been selected for blurring; removing selection from this mask
//         //         }
//         //         else
//         //         {
//         //             append_selection_area[image_x][image_y] = true; // flag this image pixel as selected for blurring
//         //         }
//         //     }
//         // }
//     }

//     // for (int x = 0; x < input_image.width; x++) {
//     // free(append_selection_area[x]);
//     // }
//     // free(append_selection_area);
// }



vector_picture blur_image(const vector_picture input_image, const mask mask_array[], unsigned short mask_count, 
                          const vector_filter filter)
{
    // definition of host variables
    unsigned int image_size = sizeof(pixel)*(input_image.width*input_image.height);
    Mask_array_info h_mask_array_info = mask_array_info_extraction(mask_array, mask_count);
    Device_mask_collection flattened_mask_data_collection = device_mask_collection_init_and_alloc(mask_array, h_mask_array_info);

    // definition of device variables
    pixel *d_input_image_data = {}; // 
    pixel *d_output_image_data = {}; // output is initialized as a copy of the input, to be modified by the kernel
    pixel *d_partial_calculation_vector = {}; // partial results append for filter application
    unsigned int *d_filter_coefficients = {};

    // allocation and initialization of all defined variables
    cudaMalloc(&d_input_image_data, image_size);
    cudaMalloc(&d_output_image_data, image_size);
    cudaMalloc(&d_partial_calculation_vector, image_size);
    cudaMalloc(&d_filter_coefficients, sizeof(unsigned int)*filter.size);

    cudaMemcpy(d_input_image_data, input_image.data, image_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_output_image_data, input_image.data, image_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_filter_coefficients, filter.coefficients, sizeof(unsigned int)*filter.size, cudaMemcpyHostToDevice);

    // proceeding to perform the kernel call
    unsigned short block_size = 16; // optimum block size (16*16=256)
    unsigned short grid_width = (h_mask_array_info.max_width + block_size-1) / block_size;
    unsigned short grid_height = (h_mask_array_info.max_height + block_size-1) / block_size;
    dim3 block(block_size, block_size);
    dim3 grid(grid_width, grid_height, mask_count); // creating a grid(max_x,max_y) for each mask

    calculate_horizontal_convolution<<<grid, block>>>(d_partial_calculation_vector, d_input_image_data, 
                                                      input_image.width, input_image.height, 
                                                      flattened_mask_data_collection, 
                                                      vector_filter({d_filter_coefficients, filter.size}));
    cudaDeviceSynchronize();
    calculate_vertical_convolution_and_write_results<<<grid, block>>>(d_output_image_data, d_partial_calculation_vector,
                                                                      input_image.width, input_image.height, 
                                                                      flattened_mask_data_collection, 
                                                                      vector_filter({d_filter_coefficients, filter.size}));
    cudaDeviceSynchronize(); //TODO: consider to remove this synchronization, 'cudaMemcpy' should do the synchronization implicitly

    pixel *h_output_image_data = (pixel *)malloc(image_size);
    cudaMemcpy(h_output_image_data, d_output_image_data, image_size, cudaMemcpyDeviceToHost);

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