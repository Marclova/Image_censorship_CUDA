//
// Created by abiga on 17/07/2026.
//

#ifndef PARALLEL_PROCESS_MANAGER_H
#define PARALLEL_PROCESS_MANAGER_H

#endif //PARALLEL_PROCESS_MANAGER_H
#pragma once

#include "../data_models/graphics.h"


// Gestisce il processo completo di blur:
// carica immagine -> applica blur -> salva risultato.
void blur_image_process(
        const char* input_image,
        const char* output_image,
        const mask mask_array[],
 //       short mask_count,
        short filter_size
);