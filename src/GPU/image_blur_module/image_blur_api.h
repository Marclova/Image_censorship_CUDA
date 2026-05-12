#include "src/data_models/img_rep_structs.h"
#include <vector>

matrix_picture blur_image(const matrix_picture input_image, const mask mask_array[], const vector_filter filter);