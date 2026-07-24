#include <iostream>

#include "CPU/process_manager.h"
#include "data_models/graphics.h"
#include "CPU/image_loader.h"
#include "UI/image_mask.h"


int main()
{
    vector_picture image = load_image("src/Images/gattinoProva.png");


    //Salvare l'immagine che prima era una matrice
    //save_image(image, "src/images/cat_copy3.png");

    destroy_image(image);

    return 0;

    // mask m = create_mask(4,3);
    //
    // m.corner_coordinates[0] = 100;
    // m.corner_coordinates[1] = 200;
    //
    // set_mask_pixel(m,0,0,true);
    // set_mask_pixel(m,1,0,true);
    // set_mask_pixel(m,2,0,true);
    //
    // set_mask_pixel(m,1,1,true);
    //
    // set_mask_pixel(m,3,2,true);
    //
    // process_selected_pixels(image,m);
    //
    // destroy_mask(m);

 /**   std::cout << "Image loaded successfully!" << std::endl;
    std::cout << "Width : " << image.width << std::endl;
    std::cout << "Height: " << image.height << std::endl;

    mask m = create_mask(5,5);


    set_mask_pixel(m,2,2,true);//qui dico che mi si deve convertire quel pixel in TRUE


    std::cout << get_mask_pixel(m,2,2) << std::endl;
    std::cout << get_mask_pixel(m,0,0) << std::endl;//questo pixel non è mai stato modificato quindi rimane così


    destroy_mask(m);

**/


    // Libera la memoria quando non serve più
    delete[] image.data;

    return 0;
}