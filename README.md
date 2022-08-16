# Better-CMake-Dependency
BCD is a set of CMake scripts that facilitate adding any third party library to your CMake project with one function call.

# Motivation
The vanilla CMake functions have limitations, at least to my needs, you're either forced to re-download the depedency with every clean command (unless you opt to using tools like ccache), re-build the external libraries along side your targets which prolongues your build time, or is included in your repo and bloating your tree.

## **_Goal_**

The main goal to acheive is to load all dependencies with the least amount of developer input so the latter can focus on developing.
The main requirements are:

* Load third party dependencies automatically during the configuration stage.
  * Your third party dependencies will be built and installed, ready to be linked and included in your project.
* Exclude third party dependencies from project targets.
* Have the freedom to clean build or delete cmake cache without affecting loaded dependencies.
* Adopt a simple plug n play solution that is environment agnostic.

### _Mechanism_
1. The root CMakeLists file will first include the **_SetupThirdParty.cmake_** file from the **_/third_party_** directory. 
-- Including a file in cmake will bring the child into the parent scope
2. **_SetupThirdParty.cmake_** will load the script that downloads the external dependency from GIT and attempt to build and install the latter sequentially. In other words, all dependencies will load at cmake's configuration stage so that packages are ready for use at build time. 
3. **_SetupThirdParty.cmake_** will find all cmake files in **_/thid_party_** that have a naming of **tpBuild\*\*.cmake** where each file will describe the steps needed to load the dependency.

# **How To Use**

Below are usage examples for different cases:

```cmake
# Adding OPENCV with optional variables
bcd_add(
	 opencv
     false
	 https://github.com/opencv/opencv/archive/refs/tags/4.5.4.zip
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
```

```cmake

# Adding GLM, an interface library (Header only library)
bcd_add( 
     glm 
	 true
	 https://github.com/g-truc/glm/releases/download/0.9.9.8/glm-0.9.9.8.zip
)

set(glm_DIR "${EXTERNAL_LIBS_DIR}/glm/cmake/glm")
find_package(glm REQUIRED)
```

<!-- Finally make  __find_package__ call so that the package is found globally throughout the project. -->

## **Useful References**
* [Correct way to use third-party libraries in cmake project](https://discourse.cmake.org/t/correct-way-to-use-third-party-libraries-in-cmake-project/1368)
* [CMake FetchContent vs. ExternalProject](https://www.scivision.dev/cmake-fetchcontent-vs-external-project/)
