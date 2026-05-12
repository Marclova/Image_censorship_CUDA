//This file defines the data structures used to represent images and other graphical representation elements.


// This structure defines the pixel structure used to represent a pixel in an image.
// Coordinates are managed separately, so this structure only contains the color information (RGB).
// Each color is represented as a char, but it's supposed to be assigned and managed as a numeric value (0-255)
struct pixel
{
    unsigned char r;
    unsigned char g;
    unsigned char b;   
};


// This structure represents an image as a matrix of pixels, along with its dimensions (width and height).
struct matrix_picture
{
    pixel** data;
    int width;
    int height;
};


// This structure defines the mask structure used to represent the selected pixels for censorship.
// The corner field represents the top-left corner of the mask, 
// and the selection_matrix is a boolean array that represents the relative positions of the selected pixels within the mask area.
struct mask
{
    int corner_coordinates[2];
    bool** selection_matrix;
};


// This structure defines the vector filter used for image processing operations like blurring.
// The coefficients field is a pointer to an array of short integers that represent the filter coefficients.
// The divisor field is used to normalize the filter output
struct vector_filter
{
    short* coefficients;
    short divisor;
};