// This file defines the pre-calculated vector filter coefficients for image processing.
#include "src/data_models/graphics.h"



// vector_filter filter_1x3 = { 
//                                 new unsigned short[3]{1, 2, 1}, 
//                                 3,
//                                 4
//                             };

// vector_filter filter_1x5 = { 
//                                 new unsigned short[5]{1, 4, 6, 4, 1}, 
//                                 5,
//                                 16
//                             };

// vector_filter filter_1x7 = { 
//                                 new unsigned short[7]{1, 6, 15, 20, 15, 6, 1}, 
//                                 7,
//                                 64
//                             };

vector_filter filter_9 = {
                            new unsigned int[9]{1, 8, 28, 56, 70, 56, 28, 8, 1},
                            9,
                            256
                          };

vector_filter filter_13 = {
                            new unsigned int[13]{1, 12, 66, 220, 495, 792, 924, 792, 495, 220, 66, 12, 1},
                            13,
                            4096
                          };

vector_filter filter_21 = {
                            new unsigned int[21]{1, 20, 190, 1140, 4845, 15504, 38760, 77520, 125970, 167960, 184756, 167960, 125970, 77520, 38760, 15504, 4845, 1140, 190, 20, 1},
                            21,
                            1048576
                          };