#include "image_loader.h"

#include <opencv2/opencv.hpp>
#include <stdexcept>

using namespace cv;
using namespace std;


/*
 * Carica un'immagine dal disco e la converte
 * nella struttura vector_picture.
 */
vector_picture load_image(const char* filename)
{
    Mat img = imread(filename);

    if(img.empty())
    {
        cout << "Error loading image!" << endl;
        exit(1);
    }

    vector_picture picture;

    picture.width = img.cols;
    picture.height = img.rows;

    // Alloca un array lineare di pixel
    picture.data = new pixel[picture.width * picture.height];

    // Copia tutti i pixel
    for(short y = 0; y < picture.height; y++)
    {
        for(short x = 0; x < picture.width; x++)
        {
            Vec3b color = img.at<Vec3b>(y, x);

            int index = y * picture.width + x;

            picture.data[index].r = color[2];
            picture.data[index].g = color[1];
            picture.data[index].b = color[0];
        }
    }

    return picture;
}


/*
 * Converte una vector_picture in un'immagine
 * e la salva sul disco.
 */
void save_image(const vector_picture& picture,
                const char* filename)
{
    Mat img(picture.height,
            picture.width,
            CV_8UC3);

    for(short y = 0; y < picture.height; y++)
    {
        for(short x = 0; x < picture.width; x++)
        {
            int index = y * picture.width + x;

            Vec3b color;

            color[0] = picture.data[index].b;
            color[1] = picture.data[index].g;
            color[2] = picture.data[index].r;

            img.at<Vec3b>(y, x) = color;
        }
    }

    imwrite(filename, img);
}


/*
 * Libera la memoria occupata
 * dall'immagine.
 */
void destroy_image(vector_picture& picture)
{
    delete[] picture.data;

    picture.data = nullptr;
    picture.width = 0;
    picture.height = 0;
}