#include <stdexcept>
#include <string>
#include <vector>

#include "process_manager.h"
#include <iostream>

#include "image_loader.h"


#include "../GPU/image_blur_module/image_blur_api.h"

#include "../data_models/vector_filter_constants.h"



vector_picture blur_image_process(
        const char* input_image_path,
        const char* output_image_path,
        const std::vector<mask> mask_vector,
        short filter_size
)
{

    /*
        1) Carica immagine
    */
    std::cout << "1. Carico immagine\n";

    vector_picture input_image_vector = load_image(input_image_path);

    std::cout << "1. Immagine caricata\n";

    /*
        2) Scelta filtro
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

    vector_picture output_image_vector =
            blur_image(
                    input_image_vector,
                    mask_vector.data(),
                    mask_vector.size(),
                    filter
            );

    std::cout << "4. Dopo blur_image\n";

    /*
        4) Salvataggio
    */

        //rename filename.png into filename_modified.png
    // std::string output_image_path = std::string(input_image_path).substr(0, std::string(input_image_path).find_last_of(".")) + "_modified.png";

    save_image(
            output_image_vector,
            output_image_path
    );

    return output_image_vector;

    /*
        5) Pulizia memoria

        Cancellero dai commenti appena si sistemerà la parte blur_image()
    */
    // destroy_image(input_image_vector);

    // destroy_image(output); //l'output per il momento è uguale all'immagine originale quindi puntano alla stessa locazione di memoria
}