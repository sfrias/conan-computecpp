# This file is based on CMake's CMake*Information.cmake
# Distributed under the OSI-approved BSD 3-Clause License.
# See https://cmake.org/licensing for details.

if(UNIX)
  set(CMAKE_SYCL_OUTPUT_EXTENSION .o)
else()
  set(CMAKE_SYCL_OUTPUT_EXTENSION .obj)
endif()
set(CMAKE_INCLUDE_FLAG_SYCL "-I")

# Load compiler-specific information.
if(CMAKE_SYCL_COMPILER_ID)
  include(${CMAKE_CURRENT_LIST_DIR}/${CMAKE_SYCL_COMPILER_ID}-SYCL.cmake)
endif()

set(CMAKE_EXECUTABLE_RPATH_LINK_SYCL_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_SYCL_FLAG})
set(CMAKE_EXECUTABLE_RUNTIME_SYCL_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_SYCL_FLAG})
set(CMAKE_EXECUTABLE_RUNTIME_SYCL_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_SYCL_FLAG_SEP})
set(CMAKE_EXE_EXPORTS_SYCL_FLAG ${CMAKE_EXE_EXPORTS_CXX_FLAG})
set(CMAKE_SHARED_LIBRARY_LINK_SYCL_WITH_RUNTIME_PATH ${CMAKE_SHARED_LIBRARY_LINK_CXX_WITH_RUNTIME_PATH})
set(CMAKE_SHARED_LIBRARY_RPATH_LINK_SYCL_FLAG ${CMAKE_SHARED_LIBRARY_RPATH_LINK_CXX_FLAG})
set(CMAKE_SHARED_LIBRARY_RUNTIME_SYCL_FLAG ${CMAKE_SHARED_LIBRARY_RUNTIME_CXX_FLAG})
set(CMAKE_SHARED_LIBRARY_RUNTIME_SYCL_FLAG_SEP ${CMAKE_SHARED_LIBRARY_RUNTIME_CXX_FLAG_SEP})
set(CMAKE_SHARED_LIBRARY_SONAME_SYCL_FLAG ${CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG})
set(CMAKE_SHARED_MODULE_CREATE_SYCL_FLAGS ${CMAKE_SHARED_LIBRARY_CREATE_SYCL_FLAGS})
set(CMAKE_SHARED_MODULE_SYCL_FLAGS ${CMAKE_SHARED_LIBRARY_SYCL_FLAGS})

set(CMAKE_SYCL_FLAGS_INIT "$ENV{SYCLFLAGS} ${CMAKE_SYCL_FLAGS_INIT}")
cmake_initialize_per_config_variable(CMAKE_SYCL_FLAGS "Flags used by the SYCL compiler")

if(CMAKE_SYCL_STANDARD_LIBRARIES_INIT)
  set(CMAKE_SYCL_STANDARD_LIBRARIES "${CMAKE_SYCL_STANDARD_LIBRARIES_INIT}"
    CACHE STRING "Libraries linked by default with all SYCL applications.")
  mark_as_advanced(CMAKE_SYCL_STANDARD_LIBRARIES)
endif()

include(CMakeCommonLanguageInclude)

foreach(library ${CMAKE_SYCL_SDK_LINK_LIBRARIES})
    get_filename_component(dir ${library} DIRECTORY)
    get_filename_component(lib ${library} NAME)
    string(APPEND __IMPLICT_LINKS " -L${dir}")
    string(APPEND __IMPLICT_LINKS " -l:${lib}")
endforeach()

foreach(include_dir ${CMAKE_SYCL_SDK_INCLUDE_DIRECTORIES})
    string(APPEND __IMPLICIT_INCLUDES " -isystem ${include_dir}")
endforeach()

set(CMAKE_SYCL_CREATE_SHARED_LIBRARY
    "<CMAKE_SYCL_COMPILER> <CMAKE_SHARED_LIBRARY_SYCL_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_SYCL_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>${__IMPLICT_LINKS}")

set(CMAKE_SYCL_CREATE_SHARED_MODULE ${CMAKE_SYCL_CREATE_SHARED_LIBRARY})
set(CMAKE_SYCL_ARCHIVE_CREATE ${CMAKE_CXX_ARCHIVE_CREATE})
set(CMAKE_SYCL_ARCHIVE_APPEND ${CMAKE_CXX_ARCHIVE_APPEND})
set(CMAKE_SYCL_ARCHIVE_FINISH ${CMAKE_CXX_ARCHIVE_FINISH})

foreach(target "ptx64 spir spir64 spirv spirv64")
    if(NOT CMAKE_SYCL_COMPILE_${target}_COMPILATION)
        set(CMAKE_SYCL_COMPILE_${target}_COMPILATION
          "<CMAKE_SYCL_COMPILER> <DEFINES> ${__IMPLICIT_INCLUDES} <INCLUDES> <FLAGS> -sycl-target ${target} <SOURCE> -o <OBJECT>")
    endif()
endforeach()
set(CMAKE_SYCL_COMPILE_OBJECT
  "<CMAKE_SYCL_COMPILER> <DEFINES> ${__IMPLICIT_INCLUDES} <INCLUDES> <FLAGS> -sycl-target spir64 -c <SOURCE> -o <OBJECT>")

if(CMAKE_GENERATOR STREQUAL "Ninja")
  set(CMAKE_SYCL_COMPILE_DEPENDENCY_DETECTION
    "<CMAKE_SYCL_COMPILER> <DEFINES> ${__IMPLICIT_INCLUDES} <INCLUDES> <FLAGS> -M <SOURCE> -MT <OBJECT> -o $DEP_FILE")
endif()

set(CMAKE_SYCL_LINK_EXECUTABLE
  "<CMAKE_SYCL_COMPILER> <CMAKE_SYCL_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES> ${__IMPLICT_LINKS}")

# Add implicit host link directories that contain device libraries
# to the device link line.

unset(_CMAKE_SYCL_EXTRA_DEVICE_LINK_FLAGS)
unset(__IMPLICT_DLINK_FLAGS)

set(CMAKE_SYCL_INFORMATION_LOADED 1)
