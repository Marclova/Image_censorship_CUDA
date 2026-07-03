#ifndef GRAPHICS_H
#define GRAPHICS_H

// =====================================================
// PIXEL
// =====================================================

struct pixel
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
};

// =====================================================
// MATRIX PICTURE
// =====================================================

struct matrix_picture
{
    pixel** data;

    short width;

    short height;
};

// =====================================================
// MASK
// =====================================================

struct mask
{
    short corner_coordinates[2];

    bool** selection_matrix;

    short width;

    short height;
};

// =====================================================
// VECTOR FILTER
// =====================================================

struct vector_filter
{
    short* coefficients;

    short size;

    short divisor;
};

#endif