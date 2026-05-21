# Image_censorship_CUDA

University project for 'Parallel And Distributed Programming' exam.
This project implements a service able to, given an image, to select specific areas and apply a specific blur to the selection.


## Manager Module
#TODO: write documentation


## Image Blur Module
Here the CUDA implementation is performed!
The blur module is structured to take in input:
- A *pixels grid* representing the image
- A *collection of masks* referring to specific pixels on witch to apply the blur operation.
- A *filter*, selected by the user through the interaction module described above (Only binomial algorithm is applied).

(Data structures are described in the 'Structures' section.)

After performing the blur operations, this module returns the results as a pixels grid.

### Kernel Resources management
//TODO: write documentation

#### Memory & Efficiency compromises
//TODO: write documentation

#### Global variables allocated into the GPU:
tot. = 16B \* pixel_in_image
- d_input_image_data:           6B/pixel
- d_output_image_data:          6B/pixel
- d_partial_calculation_matrix: 4B/pixel

#### kernel data layout (logical memory model):
calculate_horizontal_convolution: (tot. = 80B + (1B \* pixel_in_mask) + (4B \* vector_size))
{
    - pointers:                 12B
    - size-fixed parameters:    8B
    - mask:                     16B + 1B/pixel_in_mask
    - vector_filter:            8B + 4B/vector_size
    - other internal variables: 36B
}
calculate_vertical_convolution_and_write_results: (tot. = 86B + (1B \* pixel_in_mask) + (4B \* vector_size))
{
    - pointers:                 12B
    - size-fixed parameters:    8B
    - mask:                     16B + 1B/pixel_in_mask
    - vector_filter:            8B + 4B/vector_size
    - other internal variables: 42B
}


## Structures
The project works on the given *image* by converting it into a *pixel matrix* in order to make the data compatible with CUDA.

In order to save precious space on the GPU's *shared memories*, the *masks*'s data is represented as a *boolean matrix*.
This way, instead of managing copies of the original image or being confined on squared shapes, it is possible to "draw" the pattern of pixels that the shared memory has to retrieve from the global memory.

Vectors are 1-dimensional because the "separable kernel binomial algorithm is used".


Following there are the featured structures:

pixel (6B)
{
    unsigned char r;
    unsigned char g;
    unsigned char b;   
};

matrix_picture (6B/pixel+8B)
{
    pixel[][] data;
    short width;
    short height;
};

mask (1B/pixel+16B)
{
    short corner_coordinates[2];
    bool[][] selection_matrix;
    short width;
    short height;
};

vector_filter (4B/size+8B)
{
    short[] coefficients;
    short size;
    short divisor;
};