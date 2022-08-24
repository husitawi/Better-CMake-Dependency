# ADD DEFAULT BUILD TYPE TO DEBUG
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
      "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif(NOT CMAKE_BUILD_TYPE)

# SET THIRD_PARTY_DEPS DIR GLOBALLY
set(tpPath "${CMAKE_SOURCE_DIR}/_deps/${CMAKE_BUILD_TYPE}")
cmake_path(ABSOLUTE_PATH tpPath BASE_DIRECTORY ${CMAKE_SOURCE_DIR} NORMALIZE OUTPUT_VARIABLE EXTERNAL_LIBS_DIR )
set(EXTERNAL_LIBS_DIR ${EXTERNAL_LIBS_DIR} CACHE INTERNAL "Directory for all third party packages.")

# INCLUDE BUILD SCRIPTs
set(TP_BUILD_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/build_external_project.cmake")
include(${TP_BUILD_SCRIPT})

set(BCD_ADD_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/bcd_add.cmake")
include(${BCD_ADD_SCRIPT})

set(BCD_AUTO_ADD_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/bcd_auto_add.cmake")
include(${BCD_AUTO_ADD_SCRIPT})
# END INCLUDE BUILD SCRIPTs

# AUTO CLEANUP AT THE END OF THE CONFIGURATION STAGE
function(cleanup)
  # CLEANUP
  message("-- [DEPS] Cleaning up dependencies folder.")
  file(GLOB BUILD_DIRS "${EXTERNAL_LIBS_DIR}/force_*")
  if(BUILD_DIRS) 
      file(REMOVE_RECURSE ${BUILD_DIRS}) 
  endif()

  if(EXISTS "${EXTERNAL_LIBS_DIR}/external")
      file(REMOVE_RECURSE "${EXTERNAL_LIBS_DIR}/external")
  endif()
  # END CLEANUP
endfunction()

cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL cleanup)