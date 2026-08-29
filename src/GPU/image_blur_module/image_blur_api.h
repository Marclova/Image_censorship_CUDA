#include "src/data_models/graphics.h"
#include <vector>

vector_picture blur_image(const vector_picture input_image, mask mask_array[], const unsigned short mask_count, const vector_filter filter);