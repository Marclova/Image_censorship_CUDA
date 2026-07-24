#pragma once

#include "../data_models/graphics.h"

vector_picture load_image(const char* filename);

void save_image(const vector_picture& picture,
                const char* filename);

void destroy_image(vector_picture& picture);