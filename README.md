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

## **How to add a dependency**
You can check existing dependencies for inspiration. Mainly, you're expected to create a new file inside the **_/third_party_** directory with the name of **tpBuild**_YOUR_LIB_NAME_**.cmake**. Then load the dependency by utilizing the __build_external_project__ function and passing all build arguments you may need. Finally do a __find_package__ so that the package is found globally throughout the project.

## **Useful References**
* [Correct way to use third-party libraries in cmake project](https://discourse.cmake.org/t/correct-way-to-use-third-party-libraries-in-cmake-project/1368)
* [CMake FetchContent vs. ExternalProject](https://www.scivision.dev/cmake-fetchcontent-vs-external-project/)
