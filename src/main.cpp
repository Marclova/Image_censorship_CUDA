#include <iostream>

#include "CPU/image_loader.h"
#include "CPU/image_mask.h"
#include "data_models/graphics.h"
#include "GPU/image_blur_module/image_blur_api.h"

int main() {
    matrix_picture image = load_image("images/cat.jpg");

    mask m = create_mask(50, 50);

    set_mask_pixel(m, 10, 10, true);

    set_mask_pixel(m, 11, 10, true);

    matrix_picture blurred = blur_image(image);
}