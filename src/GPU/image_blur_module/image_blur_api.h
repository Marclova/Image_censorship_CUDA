#include "src/data_models/graphics.h"
#include <vector>

vector_picture blur_image(const vector_picture input_image, const mask mask_array[], const short mask_count, const vector_filter filter);