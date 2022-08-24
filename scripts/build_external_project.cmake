# This function is used to force a build on a dependant project at cmake configuration phase.
# credit: https://stackoverflow.com/a/23570741/320103

function (build_external_project target prefix isInterface isGitRepo gitTag url) #FOLLOWING ARGUMENTS are the CMAKE_ARGS of ExternalProject_Add

    set(trigger_build_dir ${EXTERNAL_LIBS_DIR}/force_${target})

    #mktemp dir in build tree
    file(MAKE_DIRECTORY ${trigger_build_dir} ${trigger_build_dir}/build)

    if(CUSTOM_CMAKE_SCT)
        file(READ ${CUSTOM_CMAKE_SCT_FILE} CUSTOM_CMAKE_SCT_CONTENT)
    endif()


    if(${isGitRepo})

        #generate false dependency project
        set(CMAKE_LIST_CONTENT "
        cmake_minimum_required(VERSION 3.22)
        project(ExternalProjectCustom)
        include(ExternalProject)
        ExternalProject_add(${target}
            PREFIX ${prefix}/${target}
            
            GIT_REPOSITORY ${url}
            GIT_TAG ${gitTag}

            GIT_PROGRESS TRUE

            SOURCE_SUBDIR ${CUSTOM_CMAKE_DIR}
            BUILD_ALWAYS 1
        ")

    else(${isGitRepo})
        
        #generate false dependency project
        set(CMAKE_LIST_CONTENT "
        cmake_minimum_required(VERSION 3.22)
        project(ExternalProjectCustom)
        include(ExternalProject)
        ExternalProject_add(${target}
            PREFIX ${prefix}/${target}
            URL ${url}
            SOURCE_SUBDIR ${CUSTOM_CMAKE_DIR}
            BUILD_ALWAYS 1
        ")

    endif(${isGitRepo})

    if(isInterface)
        set(CMAKE_LIST_CONTENT 
            "${CMAKE_LIST_CONTENT}
            BUILD_COMMAND \"\"
            INSTALL_COMMAND \"\"
            ")
    endif(isInterface)

    set(CMAKE_LIST_CONTENT 
            "${CMAKE_LIST_CONTENT}
            CMAKE_ARGS ${ARGN})")

    if(CUSTOM_CMAKE_SCT)
        set(CMAKE_LIST_CONTENT 
            "${CMAKE_LIST_CONTENT}
            ExternalProject_Add_Step(${target} CMakeFileInjection
              COMMAND           \"${CMAKE_COMMAND}\" -E copy ${CUSTOM_CMAKE_SCT_FILE} ${CUSTOM_CMAKE_SCT_DIR}/CMakeLists.txt
              DEPENDEES         download
              DEPENDERS         configure
            )")
    endif(CUSTOM_CMAKE_SCT)

    set(CMAKE_LIST_CONTENT 
            "${CMAKE_LIST_CONTENT}
        add_custom_target(trigger_${target})
        add_dependencies(trigger_${target} ${target})
    ")

    file(WRITE ${trigger_build_dir}/CMakeLists.txt "${CMAKE_LIST_CONTENT}")

    execute_process(COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR} ..
        WORKING_DIRECTORY ${trigger_build_dir}/build
        )

    execute_process(COMMAND ${CMAKE_COMMAND} --build . 
        --config ${CMAKE_BUILD_TYPE}
        WORKING_DIRECTORY ${trigger_build_dir}/build
        )

endfunction()