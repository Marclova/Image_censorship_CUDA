//
// Created by abiga on 17/07/2026.
//

#ifndef PARALLEL_PROCESS_MANAGER_H
#define PARALLEL_PROCESS_MANAGER_H

#endif //PARALLEL_PROCESS_MANAGER_H
#pragma once

#include "src/data_models/graphics.h"
#include <vector>


// Gestisce il processo completo di blur:
// carica immagine -> applica blur -> salva risultato.
vector_picture blur_image_process(
        const char* input_image_path,
        const char* output_image_path,
        const std::vector<mask> mask_vector,
        short filter_size
);