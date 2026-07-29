//TODO: Delete this file if this is not the branch "blur_image_optNconf"

#include "data_models/graphics.h"

#include "CPU/image_loader.h"
#include "UI/image_mask.h"

#include "CPU/process_manager.h"



#include <iostream>


int main()
{
    std::cout << "hello world" << std::endl;

    // char* input_image = load_image("C:/Users/cocil/AppData/Roaming/repos/Image_censorship_CUDA/src/Images/gattinoProva.png");

    // Create an empty mask array 
    mask mask_array[] = { mask() }; // Initialize with a default mask
    // assign the created mask to the first element of the array
    mask_array[0] = create_mask(797, 823);

    char* output_image = nullptr;

    blur_image_process(
        "C:/Users/cocil/AppData/Roaming/repos/Image_censorship_CUDA/src/Images/gattinoProva.png",
        output_image,
        mask_array,
        1,
        1);

    return 0;
}