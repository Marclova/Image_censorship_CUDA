#pragma once

struct Device_mask_metaData
{
    short x_cord;
    short y_cord;
    short width;
    short height;
};

struct Device_mask_collection
{
    bool *mask_data_array;
    Device_mask_metaData *mask_metadata_array;
    short *offsets;
    short mask_count;
};

// struct buffer_pixel
// {
//     short r;
//     short g;
//     short b;   
// };