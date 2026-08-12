#pragma once

#include "../data_models/graphics.h"
#include <string>

vector_picture load_image(const char* filename);

std::string save_image(const vector_picture& picture,
                const char* filename);

void destroy_image(vector_picture& picture);