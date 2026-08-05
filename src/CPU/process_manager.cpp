#include <stdexcept>
#include <vector>

#include "process_manager.h"


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

    vector_picture input_image_vector = load_image(input_image_path);



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

    vector_picture output_image_vector =
            blur_image(
                    input_image_vector,
                    mask_vector.data(),
                    mask_vector.size(),
                    filter
            );



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
    */
    // destroy_image(input_image_vector);

    // destroy_image(output_image_vector);
}