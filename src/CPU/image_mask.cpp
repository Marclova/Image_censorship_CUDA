#include "image_mask.h"

mask create_mask(short width, short height)
{
    mask m;

    m.corner_coordinates[0] = 0;
    m.corner_coordinates[1] = 0;

    m.width = width;
    m.height = height;

    m.selection_matrix = new bool*[height];

    for(short y = 0; y < height; y++)
    {
        m.selection_matrix[y] = new bool[width];

        for(short x = 0; x < width; x++)
        {
            m.selection_matrix[y][x] = false;
        }
    }

    return m;
}
void set_mask_pixel(mask& m,
                    short x,
                    short y,
                    bool value)
{
    m.selection_matrix[y][x] = value;
}

bool get_mask_pixel(const mask& m,
                    short x,
                    short y)
{
    return m.selection_matrix[y][x];
}

void destroy_mask(mask& m)
{
    for(short y = 0; y < m.height; y++)
    {
        delete[] m.selection_matrix[y];
    }

    delete[] m.selection_matrix;
}