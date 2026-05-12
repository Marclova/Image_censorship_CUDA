#include "src/data_models/img_rep_structs.h"
#include <vector>

matrix_picture blur_image(const matrix_picture input_image, const std::vector<mask> mask_collection, const vector_filter filter);