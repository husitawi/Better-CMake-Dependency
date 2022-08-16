function (bcd_add target isInterface url)

    if(NOT EXISTS "${EXTERNAL_LIBS_DIR}/${DEPENDENCY_NAME}")
        build_external_project(
                ${target}
                ${EXTERNAL_LIBS_DIR}/external
                ${isInterface}
                ${url}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DCMAKE_INSTALL_PREFIX:PATH=${EXTERNAL_LIBS_DIR}/${target}
                -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
        )
    endif()

endfunction()