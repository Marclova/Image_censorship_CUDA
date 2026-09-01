#pragma once

// This struct is used to store metadata about each mask, stripped down during the flattening process.
struct Device_mask_metaData
{
    unsigned short x_cord;
    unsigned short y_cord;
    unsigned short width;
    unsigned short height;
};

// This struct is used to pass the masks to the GPU in a single contiguous block of memory as a flattened structure.
struct Device_mask_collection
{
    bool *mask_data_array;
    Device_mask_metaData *mask_metadata_array;
    unsigned int *offsets;
    unsigned short mask_count;
};