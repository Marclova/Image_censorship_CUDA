#pragma once

struct Device_mask_metaData
{
    unsigned short x_cord;
    unsigned short y_cord;
    unsigned short width;
    unsigned short height;
};

struct Device_mask_collection
{
    bool *mask_data_array;
    Device_mask_metaData *mask_metadata_array;
    unsigned int *offsets;
    unsigned short mask_count;
};

// struct buffer_pixel
// {
//     short r;
//     short g;
//     short b;   
// };