//
// Created by abiga on 02/07/2026.
//

#ifndef PARALLEL_IMAGE_MASK_H
#define PARALLEL_IMAGE_MASK_H
#endif //PARALLEL_IMAGE_MASK_H

#pragma once

#include "../data_models/graphics.h"

// Create a new empty mask
mask create_mask(short absolute_x, short absolute_y, short width, short height);

// Free the memory occupied by the mask
void destroy_mask(mask& m);

// Modify a pixel of the mask
void set_mask_pixel(mask& m, short x, short y, bool value);

// Check if a pixel is selected
bool get_mask_pixel(const mask& m, short x, short y);