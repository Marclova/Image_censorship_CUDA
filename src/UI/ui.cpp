//
// Created by abiga on 30/07/2026.
//
#include "ui.h"

#include <opencv2/opencv.hpp>

#define NOMINMAX
#include <windows.h>
#include <commdlg.h>

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>



#include "image_mask.h"
#include "../CPU/process_manager.h"

// private functions

/// @brief Private function to split a string into substrings chopping the separator. The separator characters are removed from the result.
/// @param string_to_split The string to split
/// @param separator The character splitting the string (occurrences of the separator are removed)
/// @return An vector of substrings
static std::vector<std::string> split_with_divider(const std::string string_to_split, const char separator)
{
    const char *char_array = string_to_split.c_str();
    std::vector<std::string> vector_to_return = {};
    std::string append_string = "";
    for (size_t i = 0; i < string_to_split.length(); i++)
    {
        char selected_char = char_array[i];
        if(selected_char == separator && append_string.length() > 0)  // insert substring into the vector, if there's something to insert
        {
            vector_to_return.push_back(append_string);
            append_string = "";
        }
        else  // or append character for later insertion
        {
            append_string.push_back(selected_char);
        }
    }
    return vector_to_return;
}



//variabili globali

static cv::Mat original_image;
static cv::Mat displayed_image;

static bool drawing = false;

static cv::Point start_point;
static cv::Point end_point;


 //Aprire il file PNG
std::string open_png_dialog()
{
    char filename[MAX_PATH] = "";

    OPENFILENAMEA ofn;

    ZeroMemory(&ofn, sizeof(ofn));

    ofn.lStructSize = sizeof(ofn);

    ofn.lpstrFile = filename;

    ofn.nMaxFile = MAX_PATH;

    ofn.lpstrFilter =
        "PNG Images (*.png)\0*.png\0";

    ofn.nFilterIndex = 1;

    ofn.Flags =
        OFN_PATHMUSTEXIST |
        OFN_FILEMUSTEXIST;

    if(GetOpenFileNameA(&ofn))
        return filename;

    return "";
}

//Creazione delle MASK
mask create_rectangle_mask()
{
    short x =
        static_cast<short>(std::min(start_point.x,end_point.x));

    short y =
        static_cast<short>(std::min(start_point.y,end_point.y));

    short width =
        static_cast<short>(std::abs(end_point.x-start_point.x));

    short height =
        static_cast<short>(std::abs(end_point.y-start_point.y));

    mask m = create_mask(x,y,width,height);

    // m.corner_coordinates[0]=x;
    // m.corner_coordinates[1]=y;

    //TODO: consider to put this pixel selection initialization directly into the 'create_mask' function
    for(short row=0;row<height;row++)
    {
        for(short col=0;col<width;col++)
        {
            set_mask_pixel(m,col,row,true);
        }
    }

    return m;
}

//Quando l'utente clicca, trascina o rilascia il mouse sopra la finestra dell'immagine, esegui questo codice.
//Un evento del mouse

void mouse_callback(
    int event,
    int x,
    int y,
    int,
    void*
)
{

    if(event==cv::EVENT_LBUTTONDOWN)
    {
        drawing=true;

        start_point=cv::Point(x,y);

        end_point=start_point;
    }

    else if(event==cv::EVENT_MOUSEMOVE && drawing)
    {

        end_point=cv::Point(x,y);

        displayed_image=original_image.clone();

        cv::rectangle(
            displayed_image,
            start_point,
            end_point,
            cv::Scalar(0,255,0),
            2
        );

        cv::imshow("Image",displayed_image);
    }

    else if(event==cv::EVENT_LBUTTONUP)
    {
        drawing=false;

        end_point=cv::Point(x,y);

        displayed_image=original_image.clone();

        cv::rectangle(
            displayed_image,
            start_point,
            end_point,
            cv::Scalar(0,255,0),
            2
        );

        cv::imshow("Image",displayed_image);
    }

}


void start_ui()
{


    // 1) Apertura immagine PNG

    std::string input_image_path = open_png_dialog();


    if(input_image_path.empty())
    {
        std::cout << "Nessuna immagine selezionata\n";
        return;
    }



    // 2) Caricamento immagine con OpenCV

    original_image = cv::imread(input_image_path);


    if(original_image.empty())
    {
        std::cout << "Errore caricamento immagine\n";
        return;
    }


    displayed_image = original_image.clone();
    cv::namedWindow("Image", cv::WINDOW_NORMAL);
    cv::resizeWindow("Image", 900, 600);

    cv::setMouseCallback("Image", mouse_callback);

    cv::imshow("Image", displayed_image);


    cv::waitKey(100);



    // 3) Numero di mask richieste dall'utente

    short mask_number;


    std::cout
        << "Quante mask vuoi creare? ";


    std::cin
        >> mask_number;



    while(mask_number <= 0)
    {
        std::cout
            << "Numero non valido. Inserisci ancora: ";

        std::cin
            >> mask_number;
    }




    // 4) Creazione delle mask

    std::vector<mask> masks;


    for(short i=0; i<mask_number; i++)
    {

        std::cout
            << "\nDisegna la mask "
            << i+1
            << "\n";


        std::cout
            << "Premi INVIO quando hai finito\n";


        // reset selezione precedente

        start_point=cv::Point(0,0);

        end_point=cv::Point(0,0);



        cv::imshow(
            "Image",
            original_image
        );


        /*
            Aspetta che l'utente disegni
            con il mouse

            qualsiasi tasto continua
        */

        cv::waitKey(0);



        mask new_mask =
            create_rectangle_mask();



        masks.push_back(new_mask);



        std::cout
            << "Mask creata: "
            << new_mask.width
            << " x "
            << new_mask.height
            << "\n";

    }





    // 5) Scelta filtro


    short filter_size;



    std::cout
        << "\nScegli filtro:\n";

    std::cout
        << "3 - leggero\n";

    std::cout
        << "5 - medio\n";

    std::cout
        << "7 - forte\n";


    std::cout
        << "Scelta: ";


    std::cin
        >> filter_size;



    while(filter_size!=3 &&
          filter_size!=5 &&
          filter_size!=7)
    {

        std::cout
            << "Inserisci 3, 5 oppure 7: ";


        std::cin
            >> filter_size;

    }

//chiudo la finestra image

    cv::destroyWindow("Image");

    // 6) Chiamata process_manager

    std::cout << "input path: " << input_image_path << std::endl;
    std::string output_image_path = split_with_divider(input_image_path, '.')[0] + "_blurred.png";  //modify name to avoid overwrite
    std::cout << "output path: " << output_image_path << std::endl;
    // std::string output_image_path = input_image_path;
    blur_image_process(
        input_image_path.c_str(), 
        output_image_path.c_str(), 
        masks, 
        filter_size
    );



    cv::Mat result = cv::imread(output_image_path);  //visualizza il risultato




    if(result.empty())
    {
        std::cout
            << "Errore apertura risultato\n";

        return;
    }



    cv::namedWindow("Result", cv::WINDOW_NORMAL);
    cv::resizeWindow("Result", 900, 600);
    cv::setMouseCallback("Result", mouse_callback);
    cv::imshow("Result", result);
    cv::waitKey(0);
    cv::destroyAllWindows();
}