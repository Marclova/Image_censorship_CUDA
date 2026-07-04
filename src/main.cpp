#include <iostream>

#include "CPU/image_loader.h"

int main()
{
    matrix_picture image = load_image("images/cat.jpg");

    std::cout << "Width : " << image.width << std::endl;
    std::cout << "Height: " << image.height << std::endl;

    // Libera la memoria quando non serve più
    delete[] image.data;

    return 0;
}