#include "image_mask.h"
#include "ui.h"


mask create_mask(short absolute_x, short absolute_y, short width, short height)
{
    mask m;

    m.corner_coordinates[0] = absolute_x;
    m.corner_coordinates[1] = absolute_y;
    m.width = width;
    m.height = height;

    m.selection_vector = new bool[width * height];


    // TODO: Consider removing this initialization, since 'false' should be the default value for bools
    for(int i = 0; i < width * height; i++)
    {
        m.selection_vector[i] = false;
    }


    return m;
}



void destroy_mask(mask& m)
{
    delete[] m.selection_vector;

    m.selection_vector = nullptr;
}



void set_mask_pixel(mask& m, short x, short y, bool value)
{
    if (x < 0 || x >= m.width ||
       y < 0 || y >= m.height)
    {
        return;
    }

    int index = y * m.width + x;

    m.selection_vector[index] = value;
}



void set_mask_coordinates(mask& m, short new_x_coordinate, short new_y_coordinate)
{
    m.corner_coordinates[0] = new_x_coordinate;
    m.corner_coordinates[1] = new_y_coordinate;
}



bool get_mask_pixel(const mask& m, short x, short y)
{
    if (x < 0 || x >= m.width ||
        y < 0 || y >= m.height)
    {
        return false;
    }

    int index = y * m.width + x;

    return m.selection_vector[index];
}