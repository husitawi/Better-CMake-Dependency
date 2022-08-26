# Better-CMake-Dependency
BCD is a set of CMake scripts that facilitate adding any third party library to your CMake project with one function call. I will always encourage you to use and learn the functions provided by CMake, but if you're looking to quickly add a dependency and get your project building, keep reading.

# Motivation
The vanilla CMake functions have limitations, at least to my needs, you're either forced to: 

* Rre-download the depedency with every _clean build command_ (unless you opt to use tools like ccache).
* Re-build the external libraries along side your targets which prolongues your build time.
* Include the target source code in your repo and bloat your tree.

## **_Goal_**

The main goal to acheive is to load all dependencies with the least amount of developer input so the latter can focus on developing.
The main requirements are:

* Load third party dependencies automatically during the configuration stage.
  * Your dependencies will be built and installed, ready to be linked and included in your project.
* Exclude dependencies from project targets.
* Have the freedom to _clean build_ or _delete cmake cache_ without affecting loaded dependencies.
* Adopt a simple plug n play solution that is environment agnostic.

### _Mechanism_
1. **_setup.cmake_** will load the scripts that download the external dependency as a ZIP or from GIT and attempt to build and install the latter sequentially. In other words, all dependencies will load at cmake's configuration stage so that packages are ready for use at build time. 

# **How To Add This To Your CMake Project**

You can either clone this repo and add it to your project, or if you're a complete nooby, then follow along these few steps:
1. From the root CMakeLists.txt directory run:
```shell
git submodule add --name bcd https://github.com/husitawi/Better-CMake-Dependency external/bcd
```
2. Your root CMakeLists.txt can now look like this:

```cmake
cmake_minimum_required(VERSION 3.22.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(myProject VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_VERBOSE_MAKEFILE ON)

# ADD BETTER CMAKE DEPENDENCY
include(external/bcd/main.cmake)

## You can now use the BCD functions!
## ADD OPENSSL
bcd_add(
        OpenSSL # Dependency folder name
        false   # Is not an interface ("header only library")
        true    # Is a GIT repo
        d4634362820f874e1f1461c7f5d766b3ef968c67      # GIT commit hash (can also be name of branch)
        https://github.com/janbar/openssl-cmake.git   # GIT url
)
set(OPENSSL_ROOT_DIR "${EXTERNAL_LIBS_DIR}/OpenSSL" CACHE INTERNAL "Override default OPENSSL installation dir" FORCE)
find_package(OpenSSL REQUIRED )
## END OPENSSL
```

# **How To Use**

The original function signature takes 5 arguments that you can deduce from the examples below:

```cmake
function (bcd_add target isInterface isGitRepo gitTag url)
```

1. ***target***: represents the dependency's name 
2. ***isInterface***: allows you to indicate whether the depdendency is a header only library or not
3. ***isGitRepo***: specify if the URL to be provided is a GIT repo or a ZIP file
4. ***gitTag***: specify a GIT tag if it's GIT repo, leave empty if it's not
5. ***URL***: The GIT or ZIP's url

**BE AWARE THAT YOU ARE STILL REQUIRED TO INCLUDE THE HEADER DIRECTORIES AND LINK THE DEPENDENCIES TO YOUR TARGET**

## _Examples:_

```cmake
## ADD OPENSSL
bcd_add(
        OpenSSL # Dependency folder name
        false   # Is not an interface ("header only library")
        true    # Is a GIT repo
        d4634362820f874e1f1461c7f5d766b3ef968c67      # GIT commit hash (can also be name of branch)
        https://github.com/janbar/openssl-cmake.git   # GIT url
)
set(OPENSSL_ROOT_DIR "${EXTERNAL_LIBS_DIR}/OpenSSL" CACHE INTERNAL "Override default OPENSSL installation dir" FORCE)
find_package(OpenSSL REQUIRED )
## END OPENSSL
```

```cmake
## ADD BOOST
bcd_add(
        Boost   # Dependency folder name
        false   # Is not an interface ("header only library")
        true    # Is a GIT repo
        5e1bede2ed9be595bfd9455f2995942c7220256d      # GIT commit hash (can also be name of branch)
        https://github.com/boostorg/boost.git         # GIT url
)
set(BOOST_ROOT "${EXTERNAL_LIBS_DIR}/Boost" CACHE INTERNAL "Override default BOOST installation dir" FORCE)
set(Boost_NO_SYSTEM_PATHS TRUE CACHE INTERNAL "Disable system BOOST check" FORCE)
find_package(Boost REQUIRED )
## END BOOST
```

```cmake
## Add static OPENCV with optional variables
bcd_add(
        opencv   # Dependency folder name
        false    # Is not an interface ("header only library")
        false    # Is NOT a GIT repo, it's a ZIP to be downloaded
        ""       # No GIT tag to be provided
        https://github.com/opencv/opencv/archive/refs/tags/4.5.4.zip  # ZIP url

            # These are all extra parameters to be passed to the OPENCV build step
            -DBUILD_PROTOBUF=OFF
            -DBUILD_opencv_core=ON
            -DBUILD_opencv_highgui=ON
            -DBUILD_opencv_imgproc=ON
            -DBUILD_opencv_contrib=ON
            -DBUILD_opencv_imgcodecs=ON
            -DBUILD_opencv_features2d=ON
            -DBUILD_opencv_calib3d=ON
            -DBUILD_DOCS:BOOL=FALSE
            -DBUILD_EXAMPLES:BOOL=FALSE
            -DBUILD_TESTS:BOOL=FALSE
            -DBUILD_SHARED_LIBS:BOOL=TRUE
            -DBUILD_NEW_PYTHON_SUPPORT:BOOL=OFF
            -DBUILD_WITH_DEBUG_INFO=OFF
            -DWITH_CUDA:BOOL=FALSE
            -DWITH_FFMPEG:BOOL=FALSE
            -DWITH_MSMF:BOOL=FALSE
            -DWITH_IPP:BOOL=FALSE
            -DBUILD_PERF_TESTS:BOOL=FALSE
            -DBUILD_PNG:BOOL=ON
            -DBUILD_JPEG:BOOL=ON
            -DBUILD_WITH_STATIC_CRT:BOOL=OFF
            -DBUILD_WITH_ADE:BOOL=OFF
            -DWITH_QUIRC:BOOL=OFF
            -DBUILD_FAT_JAVA_LIB=OFF
            -DBUILD_LIST=core,imgproc,highgui,imgcodecs,features2d,calib3d
            -DBUILD_JPEG_TURBO_DISABLE:BOOL=ON
)

set(OpenCV_STATIC OFF)
find_package(OpenCV REQUIRED PATHS ${EXTERNAL_LIBS_DIR}/opencv NO_DEFAULT_PATH)    
## END OPENCV  
```

```cmake
## Add GLM, an interface library (Header only library)
bcd_add( 
        glm      # Dependency folder name
        true     # Is an interface! ("header only library")
        false    # Is NOT a GIT repo, it's a ZIP to be downloaded
        ""       # No GIT tag to be provided
        https://github.com/g-truc/glm/releases/download/0.9.9.8/glm-0.9.9.8.zip  # ZIP url
)

set(glm_DIR "${EXTERNAL_LIBS_DIR}/glm/cmake/glm")
find_package(glm REQUIRED)
## END GLM
```

## _More Complex Example_

Let's add a non CMake project by injecting a CMakeLists file:

```cmake
cmake_minimum_required(VERSION 3.22)

#...
#...

set(cmPath "${CMAKE_SOURCE_DIR}/.../libusb_cmake.cmake") # Path to your custom cmake file for libusb
cmake_path(ABSOLUTE_PATH cmPath BASE_DIRECTORY ${CMAKE_SOURCE_DIR} NORMALIZE OUTPUT_VARIABLE CUSTOM_CMAKE_SCT_FILE )

set(CUSTOM_CMAKE_DIR "libusb" CACHE INTERNAL "Custom cmake directory necessary for libusb project.")
set(CUSTOM_CMAKE_SCT true CACHE INTERNAL "Tell the build script that a custom cmake script is needed.")
set(CUSTOM_CMAKE_SCT_DIR "${EXTERNAL_LIBS_DIR}/external/libusb/src/libusb/libusb" CACHE INTERNAL "Set the custom script directory.")
set(CUSTOM_CMAKE_SCT_FILE ${CUSTOM_CMAKE_SCT_FILE} CACHE INTERNAL "Set the custom script content.")

bcd_add(
        libusb  # Dependency folder name
        false   # Is NOT an interface
        false   # Is NOT a GIT repo, it's a ZIP to be downloaded
        ""      # No GIT tag to be provided
        https://github.com/libusb/libusb/archive/refs/tags/v1.0.25.zip  # ZIP url
)

# IMPORTANT, clear variables not to affect next package
unset(CUSTOM_CMAKE_DIR CACHE)
unset(CUSTOM_CMAKE_SCT CACHE)
unset(CUSTOM_CMAKE_SCT_DIR CACHE)
unset(CUSTOM_CMAKE_SCT_FILE CACHE)
```

## **Useful References**
* [Correct way to use third-party libraries in cmake project](https://discourse.cmake.org/t/correct-way-to-use-third-party-libraries-in-cmake-project/1368)
* [CMake FetchContent vs. ExternalProject](https://www.scivision.dev/cmake-fetchcontent-vs-external-project/)
