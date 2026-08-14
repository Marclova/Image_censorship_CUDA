// This file defines the pre-calculated vector filter coefficients for image processing.
#include "src/data_models/graphics.h"



vector_filter filter_1x3 = { 
                                new short[3]{1, 2, 1}, 
                                3,
                                4
                            };

vector_filter filter_1x5 = { 
                                new short[5]{1, 4, 6, 4, 1}, 
                                5,
                                16
                            };

vector_filter filter_1x7 = { 
                                new short[7]{1, 6, 15, 20, 15, 6, 1}, 
                                7,
                                64
                            };