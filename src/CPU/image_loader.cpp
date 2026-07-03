#include "image_loader.h"

#include <iostream>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

matrix_picture load_image(const char* filename)
{
    Mat img = imread(filename);

    if(img.empty())
    {
        throw std::runtime_error("Error loading image");
    }

    matrix_picture picture;

    picture.width = img.cols;
    picture.height = img.rows;

    // Allocate rows
    picture.data = new pixel*[picture.height];

    // Allocate columns
    for(short y = 0; y < picture.height; y++)
    {
        picture.data[y] = new pixel[picture.width];
    }

    // Copy pixels
    for(short y = 0; y < picture.height; y++)
    {
        for(short x = 0; x < picture.width; x++)
        {
            Vec3b color = img.at<Vec3b>(y, x);

            picture.data[y][x].r = color[2];
            picture.data[y][x].g = color[1];
            picture.data[y][x].b = color[0];
        }
    }

    return picture;
}