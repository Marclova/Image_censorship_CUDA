#include "image_loader.h"

#include <opencv2/opencv.hpp>
#include <stdexcept>

using namespace cv;


matrix_picture load_image(const char* filename)
{
    // Carica l'immagine dal disco
    Mat img = imread(filename, IMREAD_COLOR);

    if (img.empty())
    {
        throw std::runtime_error("Error loading image.");
    }

    matrix_picture picture;

    picture.width = static_cast<short>(img.cols);
    picture.height = static_cast<short>(img.rows);

    // Alloca un unico blocco di memoria per tutti i pixel
    picture.data = new pixel[picture.width * picture.height];

    // Copia i pixel da OpenCV alla struttura matrix_picture
    for (short y = 0; y < picture.height; y++)
    {
        for (short x = 0; x < picture.width; x++)
        {
            Vec3b color = img.at<Vec3b>(y, x);

            int index = y * picture.width + x;

            picture.data[index].r = color[2]; // Red
            picture.data[index].g = color[1]; // Green
            picture.data[index].b = color[0]; // Blue
        }
    }

    //TEST
   /** bool correct = true;

    for (int y = 0; y < picture.height; y++)
    {
        for (int x = 0; x < picture.width; x++)
        {
            int index = y * picture.width + x;

            cv::Vec3b original = img.at<cv::Vec3b>(y,x);

            if(picture.data[index].r != original[2] ||
               picture.data[index].g != original[1] ||
               picture.data[index].b != original[0])
            {
                std::cout << "Errore pixel: "
                          << x << "," << y << std::endl;

                correct = false;
                break;
            }
        }

        if (!correct)
            break;
    }


    if (correct)
        std::cout << "Tutti i pixel sono corretti!" << std::endl; **/

    return picture;



}