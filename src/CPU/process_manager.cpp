//
// Created by abiga on 17/07/2026.
//

#include "process_manager.h"


#include "image_loader.h"
#include "image_mask.h"

#include "../GPU/image_blur_module/image_blur_api.h"

#include "../data_models/vector_filter.h"



void blur_image_process(
        const char* input_image,
        const char* output_image,
        const mask mask_array[],
        short mask_count,
        short filter_size
)
{

    /*
        1) Carica immagine
    */

    matrix_picture image = load_image(input_image);



    /*
        2) Scelta filtro
    */

    vector_filter filter;


    switch(filter_size)
    {
    case 3:

        filter = filter_1x3;
        break;


    case 5:

        filter = filter_1x5;
        break;


    default:

        filter = filter_1x7;
        break;
    }



    /*
        3) Invio alla GPU

        Passiamo:
        - immagine
        - tutte le mask
        - numero mask
        - filtro
    */

    matrix_picture output =
            blur_image(
                    image,
                    mask_array,
                    mask_count,
                    filter
            );



    /*
        4) Salvataggio
    */

    save_image(
            output,
            output_image
    );



    /*
        5) Pulizia memoria
    */

    destroy_image(image);

    destroy_image(output);

}