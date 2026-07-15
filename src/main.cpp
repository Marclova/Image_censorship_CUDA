#include <iostream>

#include "CPU/image_loader.h"
#include "CPU/image_mask.h"

int main()
{
    matrix_picture image = load_image("src/Images/gattinoProva.png");


    std::cout << "Image loaded successfully!" << std::endl;
    std::cout << "Width : " << image.width << std::endl;
    std::cout << "Height: " << image.height << std::endl;

    mask m = create_mask(5,5);


    set_mask_pixel(m,2,2,true);//qui dico che mi si deve convertire quel pixel in TRUE


    std::cout << get_mask_pixel(m,2,2) << std::endl;
    std::cout << get_mask_pixel(m,0,0) << std::endl;//questo pixel non è mai stato modificato quindi rimane così


    destroy_mask(m);



    // Libera la memoria quando non serve più
    delete[] image.data;

    return 0;
}