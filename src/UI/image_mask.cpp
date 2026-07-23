#include "image_mask.h"


mask create_mask(short width, short height)
{
    mask m;

    m.width = width;
    m.height = height;

    m.selection_matrix = new bool[width * height];


    for(int i = 0; i < width * height; i++)
    {
        m.selection_matrix[i] = false;
    }


    m.corner_coordinates[0] = 0;
    m.corner_coordinates[1] = 0;


    return m;
}



void destroy_mask(mask& m)
{
    delete[] m.selection_matrix;

    m.selection_matrix = nullptr;
}



void set_mask_pixel(mask& m, short x, short y, bool value)
{
    int index = y * m.width + x;

    m.selection_matrix[index] = value;
}



bool get_mask_pixel(const mask& m, short x, short y)
{
    int index = y * m.width + x;

    return m.selection_matrix[index];
}