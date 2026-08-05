__global__ void calculate_horizontal_convolution(pixel *partial_calculation_matrix, pixel const *input_image, 
                                         short const image_width, short const image_height, 
                                         mask const mask, vector_filter const filter);

__global__ void calculate_vertical_convolution_and_write_results(
        pixel *output_image, pixel const *partial_calculation_matrix,
        short const image_width, short const image_height, mask const mask, vector_filter const filter);