//
// Created by abiga on 17/07/2026.
//

#include "process_manager.h"
#include <iostream>

#include "image_loader.h"


#include "../GPU/image_blur_module/image_blur_api.h"

#include "../data_models/vector_filter_constants.h"



std::string blur_image_process(
        const char* input_image,
        const mask mask_array[],
        short mask_number,
        short filter_size
)
{

    /*
        1) Carica immagine
    */
    std::cout << "1. Carico immagine\n";

    vector_picture image = load_image(input_image);

    std::cout << "1. Immagine caricata\n";

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

    std::cout << "2. Filtro scelto\n";

    /*
        3) Invio alla GPU

        Passiamo:
        - immagine
        - tutte le mask
        - numero mask
        - filtro
    */

    std::cout << "3. Prima di blur_image\n";

    vector_picture output =
            blur_image(
                    image,
                    mask_array,
                    mask_number,
                    filter
            );

    std::cout << "4. Dopo blur_image\n";

    /*
        4) Salvataggio
    */

    std::cout << "5. Prima di save_image\n";

    std::string output_filename = save_image(output, input_image);

    std::cout << "6. Dopo save_image\n";

    return output_filename;

    /*
        5) Pulizia memoria

        Cancellero dai commenti appena si sistemerà la parte blur_image()
    */
    destroy_image(image);

    destroy_image(output); //l'output per il momento è uguale all'immagine originale quindi puntano alla stessa locazione di memoria
}