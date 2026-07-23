//
// Created by abiga on 02/07/2026.
//

#ifndef PARALLEL_IMAGE_MASK_H
#define PARALLEL_IMAGE_MASK_H

#endif //PARALLEL_IMAGE_MASK_H

#pragma once

#include "../data_models/graphics.h"

// Crea una maschera vuota
mask create_mask(short width, short height);

// Libera la memoria occupata dalla maschera
void destroy_mask(mask& m);

// Modifica un pixel della maschera
void set_mask_pixel(mask& m, short x, short y, bool value);

// Controlla se un pixel è selezionato
bool get_mask_pixel(const mask& m, short x, short y);