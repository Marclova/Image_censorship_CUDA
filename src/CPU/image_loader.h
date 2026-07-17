#pragma once

#include "../data_models/graphics.h"

matrix_picture load_image(const char* filename);

void save_image(const matrix_picture& picture,
                const char* filename);

void destroy_image(matrix_picture& picture);