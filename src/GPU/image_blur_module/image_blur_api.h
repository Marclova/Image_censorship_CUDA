#pragma once

#include "../../data_models/graphics.h"

vector_picture blur_image(const vector_picture input_image, const mask mask_array[],short mask_number, const vector_filter filter);