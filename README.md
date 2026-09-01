# Image_censorship_CUDA

University project for 'Parallel And Distributed Programming' exam.
This project implements a service able to, given an image, to select specific areas and apply a specific blur to the selection.

## UI Module
The UI module provides the user interface for image selection and interaction.
This module is structured to:
- Display the input image to the user
- Allow users to select specific areas on the image using drawing tools
- Enable users to choose blur filter parameters
- Preview and apply the blur operation
- Export the processed image with censored regions

After user interaction, this module passes the image data and mask selections to the Manager module for processing.

## Manager Module
The Manager module coordinates the overall workflow between UI and image processing.
This module is structured to:
- Receive image and mask data from the UI module
- Validate input parameters and data integrity
- Prepare data structures for GPU processing
- Invoke the Image Blur module with appropriate configurations
- Handle GPU memory allocation and deallocation
- Manage the return of processed results to the UI module

After coordinating the blur operations, this module returns the processed image back to the UI for display and export.


## Image Blur Module
Here the CUDA implementation is performed!
The blur module is structured to take in input:
- A **pixels grid** representing the image
- A **collection of masks** referring to specific pixels on witch to apply the blur operation.
- A **filter**, selected by the user through the interaction module described above (Only binomial algorithm is applied).

(Data structures are described in the 'Structures' section.)

After performing the blur operations, this module returns the results as a pixels grid.

### Kernel Resources management
For a detailed documentation of the GPU resources and process management consult the PDF document attached in the project root.


## Structures
The project works on the given **image** by converting it into a **pixel matrix** in order to make the data compatible with CUDA.

In order to save precious space on the GPU's **shared memories**, the **masks**'s data is represented as a **boolean matrix**.
This way, instead of managing copies of the original image or being confined on squared shapes, it is possible to "draw" the pattern of pixels that the shared memory has to retrieve from the global memory.

Vectors are 1-dimensional because the "separable kernel binomial algorithm is used".


### CPU/GPU structs

Used to contain data stored in every single pixel (transparency is not supported; transparent pixels will become fully opaque)
pixel (6B)
{
    unsigned char r;
    unsigned char g;
    unsigned char b;   
};

Used to represent an image content and dimensions
vector_picture (6B\*pixel+8B)
{
    pixel[] data;
    unsigned short width;
    unsigned short height;
};

Used to represent a region of the image; meant to be created when the user draws a selection area onto the input image.
mask (1B\*pixel+16B)
{
    unsigned short corner_coordinates[2];
    bool[] selection_vector;
    unsigned short width;
    unsigned short height;
};

Used to contain data about the used 1-dimensional filter used for the blurring operation.
vector_filter (8B\*size+4B)
{
    unsigned int[] coefficients;
    unsigned short size;
};

### GPU structs

Used to contain metadata associated to a specific mask (the flattened collection strips masks from their metadata)
struct Device_mask_metaData (32B)
{
    unsigned short x_cord;
    unsigned short y_cord;
    unsigned short width;
    unsigned short height;
};

Flattened collection obtained out of a mask array used to optimize CUDA operations
struct Device_mask_collection ( (Device_mask_metaData+mask[i].selection_vector+8B)\*mask_count+4B )
{
    bool *mask_data_array;
    Device_mask_metaData *mask_metadata_array;
    unsigned int *offsets;
    unsigned short mask_count;
};


## ⚙️ Project Configuration & Setup

**DISCLAIMER**
This section has been AI-generated using the PDF document attached to the project root as source.
The involved third party service for the text generation was Gemini (free).
The configuration section in the document has been mostly written by human hand.

Following there's the LLM's output:

The analyzed document outlines the environment configuration required to compile, link, and run the project. The build system supports both **C++** (CPU/UI modules) and **CUDA** (GPU acceleration).

---

### 🛠️ Overview of Development Environments

| Environment | Supported Modules | Purpose | Primary Compiler(s) |
| :--- | :--- | :--- | :--- |
| **VSCode** *(Reference)* | C++ (CPU & UI) + CUDA (GPU) | **Full build & execution** | MSVC (`cl.exe`) + NVCC (`nvcc.exe`) |
| **CLion** | C++ (CPU & UI) | Standalone C++ dev & testing | MSVC (`cl.exe`) via CMake & Ninja |

> 📌 **Note:** While CLion is configured for C++ development and standalone testing, **VSCode is the primary reference environment** as it supports the complete C++/CUDA pipeline.

---

### 🔵 1. VSCode Setup (Primary Environment)

VSCode orchestrates the build system through custom configuration files (`tasks.json`, `launch.json`, `c_cpp_properties.json`).

#### Prerequisites
1. **Compilers:** Install **MSVC** (via Visual Studio Build Tools) and **NVIDIA CUDA Toolkit**.
2. **OpenCV:** Download and extract OpenCV (compatible with v4.x and v2.x).

#### Configuration Steps
1. **Include Paths (`c_cpp_properties.json`):**  
   Add `opencv/build/include` (or `opencv/build/include/opencv4` for OpenCV 4) to `includePath`.
2. **Linking (`tasks.json`):**  
   Add the manual library reference to `opencv_world<version>.lib` in the Linker task.
3. **Task Architecture in `tasks.json`:**
   * **`Compile C++`**: Compiles `.cpp` source files using MSVC (`cl.exe`).
   * **`Compile CUDA`**: Compiles `.cu` source files using NVCC (`nvcc.exe`).
   * **`Setup Task`**: Creates output folders and copies necessary DLL files.
   * **`Linker Task`**: Links compiled object files with external libraries to generate the final executable.
   * **`Build Task`**: Pipeline coordinator for full compilation and linking.

---

#### 🔍 Troubleshooting Compiler Detection

Ensure both `cl` and `nvcc` commands are accessible in the integrated terminal:

<details>
<summary><b>MSVC (cl.exe) not recognized</b></summary>

1. Ensure the **C++ Build Tools** package is installed via *Visual Studio Installer*.
2. When prompted by VSCode on run/debug (`F5`), explicitly select the detected `cl` compiler.
</details>

<details>
<summary><b>NVCC (nvcc.exe) not recognized</b></summary>

1. Check that the environment variable `CUDA_PATH` points to your CUDA installation directory (e.g., `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.3`).
2. **Clear Cache:** Delete CMake cache inside VSCode.
3. **Drastic Cache Reset:**
   - Verify `nvcc` is recognized inside the *Developer Command Prompt for VS*.
   - Delete/rename `%APPDATA%\Code\User\workspaceStorage`.
   - Close VSCode and launch it **directly from the Developer Command Prompt** so environment variables are inherited.
</details>

---

### 🔴 2. CLion Setup (C++ Standalone)

CLion is used for isolated development and unit testing of C++ modules (UI & CPU).

- **IDE:** JetBrains CLion (v2026.1.1)
- **Compiler:** MSVC (`cl.exe` via Visual Studio Build Tools)
- **Build System:** CMake + Ninja
- **Package Manager:** `vcpkg` (used for locating and linking OpenCV)

---

### 📌 Versioning & Compatibility Matrix

Due to hardware constraints on the target development device, specific legacy versions were selected to maintain driver and GPU compatibility:

| Component | Selected Version | Notes / Reason |
| :--- | :--- | :--- |
| **NVIDIA Driver** | `511.69` | Maximum supported driver on test hardware |
| **CUDA Toolkit** | `11.3` | Downgraded from v13.0 to match driver `511.69` |
| **MSVC Toolset** | `v142` (`14.20.27508`) | Required for compatibility with CUDA 11.3 |
| **MSVC Compiler (`cl.exe`)** | `19.20.27508.1` | — |
| **OpenCV** | `4.x` (Recommended) / `2.x` | Code is backward-compatible with OpenCV 2 |