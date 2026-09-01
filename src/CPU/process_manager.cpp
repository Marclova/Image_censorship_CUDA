#include <stdexcept>
#include <string>
#include <vector>

#include "process_manager.h"
#include <iostream>

#include "image_loader.h"

#include "../GPU/image_blur_module/image_blur_api.h"

#include "../data_models/vector_filter_constants.h"



vector_picture blur_image_process(const char* input_image_path, const char* output_image_path,
                                  const std::vector<mask> mask_vector, short filter_size)
{
    /*
        1) Loads image
    */
    std::cout << "1. Loading image\n";

    vector_picture input_image_vector = load_image(input_image_path);

    std::cout << "1. Image loaded\n";

    /*
        2) Filter selection
    */
    vector_filter filter;
    switch(filter_size)
    {
    case 9:
        filter = filter_9;
        break;
    case 13:
        filter = filter_13;
        break;
    case 21:
        filter = filter_21;
        break;
    default:
        throw std::invalid_argument(
                "Unsupported filter size: " + std::to_string(filter_size)
        );
    }

    std::cout << "2. Filter selected\n";
    
    // 3) Sending to GPU for blurring passing image, all masks, number of masks and filter
    std::cout << "3. Starting blur operation\n";

    vector_picture output_image_vector =
            blur_image(
                    input_image_vector,
                    const_cast<mask*>(mask_vector.data()),
                    mask_vector.size(),
                    filter
            );

    std::cout << "4. Blur operation completed\n";

    /*
        4) Saving image
    */save_image(
            output_image_vector,
            output_image_path
    );

    // 5) Memory cleanup
    free(input_image_vector.data);

    return output_image_vector;
}