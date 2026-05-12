#include <iostream>
#include <vector>
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

//pixel
struct Pixel {
    float r;
    float g;
    float b;
};

//image

typedef vector<vector<Pixel>> Image;

//mask

struct Mask {

    pair<int,int> corner;

    vector<vector<bool>> selection_matrix;
};

//load image

Image loadImage(string filename) {

    Mat img = imread(filename);

    if(img.empty()) {
        cout << "Errore caricamento immagine" << endl;
        exit(1);
    }

    int m = img.rows;
    int n = img.cols;

    Image image(m, vector<Pixel>(n));

    for(int i = 0; i < m; i++) {

        for(int j = 0; j < n; j++) {

            Vec3b color = img.at<Vec3b>(i,j);

            image[i][j].r = color[2] / 255.0f;
            image[i][j].g = color[1] / 255.0f;
            image[i][j].b = color[0] / 255.0f;
        }
    }

    return image;
}

//create mask

Mask createMask() {

    Mask mask;

    mask.corner = {50,50};

    mask.selection_matrix = {

        {true, true, true},
        {true, false, true},
        {true, true, true}
    };

    return mask;
}

//apply mask

void applyMask(Image& image, Mask& mask) {

    int startX = mask.corner.first;
    int startY = mask.corner.second;

    for(int i = 0; i < mask.selection_matrix.size(); i++) {

        for(int j = 0; j < mask.selection_matrix[i].size(); j++) {

            if(mask.selection_matrix[i][j]) {

                int y = startY + i;
                int x = startX + j;

                image[y][x].r = 1.0f;
                image[y][x].g = 0.0f;
                image[y][x].b = 0.0f;
            }
        }
    }
}


int main() {

    // carica immagine
    Image image = loadImage("cat.jpg");

    // crea mask
    Mask mask = createMask();

    // applica mask
    applyMask(image, mask);

    cout << "Immagine caricata e mask applicata!" << endl;

    return 0;

}