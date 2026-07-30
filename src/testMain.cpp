#include "CPU/image_loader.h"
#include "UI/image_mask.h"

#include "CPU/process_manager.h"
// #include <iostream>


int main()
{
    // std::cout << "hello world" << std::endl;

    // char* input_image = load_image("C:/Users/cocil/AppData/Roaming/repos/Image_censorship_CUDA/src/Images/gattinoProva.png");
    char* output_image = nullptr;

    mask mask_array[] = {create_mask(797, 823)};

    blur_image_process("${workspaceFolder}/src/Images/gattinoProva.png",
        output_image,
        mask_array,
        1);

    return 0;
}