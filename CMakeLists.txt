cmake_minimum_required(VERSION 3.1)
project(Milton)

include(${CMAKE_CURRENT_LIST_DIR}/cmake/MiltonVersion.cmake)
milton_read_version_from_header(${CMAKE_CURRENT_LIST_DIR}/src/milton_configuration.h)
message(STATUS "Milton version: ${MILTON_VERSION}")

configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/Milton.iss.in
  ${CMAKE_CURRENT_LIST_DIR}/Milton.iss
  @ONLY)

if(APPLE AND NOT DEFINED CMAKE_OSX_ARCHITECTURES)
  set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "Build universal binaries by default")
endif()

if(APPLE)
  enable_language(OBJCXX)
  set(CMAKE_C_STANDARD 99)
  set(CMAKE_C_STANDARD_REQUIRED ON)
endif()

if(WIN32)
  set(DIRECTX 0)
endif()


add_executable(shadergen
  src/shadergen.cc
)

set(SDL3DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/SDL3-3.4.4)

FILE (GLOB ShaderSources src/*.glsl third_party/*.glsl)

add_executable(Milton WIN32 MACOSX_BUNDLE
  src/unity.cc
  src/shaders.gen.h
)

target_include_directories(Milton PRIVATE
  src
  third_party
  third_party/imgui
)

# Handle various switches, build types etc.

## Default build type to Release
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-DMILTON_DEBUG=1)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
  add_definitions(-DMILTON_DEBUG=0)
else()
  message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}. Supported build types: Release, Debug.")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "-g")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")

message(STATUS "Building ${CMAKE_BUILD_TYPE}")

if(UNIX)
  set(UnixCFlags
    -std=c++11
    -Wno-missing-braces
    -Wno-unused-function
    -Wno-unused-variable
    -Wno-unused-result
    -Wno-write-strings
    -Wno-c++11-compat-deprecated-writable-strings
    -Wno-null-dereference
    -Wno-format
    -fno-strict-aliasing
    -fno-omit-frame-pointer
    -Wno-extern-c-compat
    #-Werror
    )
  if (APPLE)
      set_source_files_properties(src/unity.cc PROPERTIES LANGUAGE OBJCXX)
  endif()

  target_compile_options(shadergen PRIVATE
    ${UnixCFlags})
  target_compile_options(Milton PRIVATE
    ${UnixCFlags})
endif()

set(MILTON_RUNTIME_ASSETS
  ${CMAKE_CURRENT_LIST_DIR}/third_party/Carlito.ttf
  ${CMAKE_CURRENT_LIST_DIR}/third_party/Carlito.LICENSE
)

if(WIN32)
  list(APPEND MILTON_RUNTIME_ASSETS ${CMAKE_CURRENT_LIST_DIR}/milton_icon.ico)
endif()

if(APPLE)
  set(MILTON_MACOS_ICON "${CMAKE_CURRENT_LIST_DIR}/milton_icon.icns")

  # Make bundled builds load runtime files from Contents/Resources.
  target_sources(Milton PRIVATE ${MILTON_RUNTIME_ASSETS} ${MILTON_MACOS_ICON})
  set_source_files_properties(${MILTON_RUNTIME_ASSETS} ${MILTON_MACOS_ICON} PROPERTIES
    MACOSX_PACKAGE_LOCATION Resources
  )

  set_target_properties(Milton PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME "Milton"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.serge-rgb.milton"
    MACOSX_BUNDLE_ICON_FILE milton_icon.icns
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${MILTON_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "${MILTON_VERSION}"
  )
endif()

set(SDL_SHARED OFF CACHE BOOL "Build SDL shared library" FORCE)
set(SDL_STATIC ON CACHE BOOL "Build SDL static library" FORCE)
set(SDL_TEST_LIBRARY OFF CACHE BOOL "Build SDL test library" FORCE)
add_subdirectory(${SDL3DIR})

if(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")

  find_package(OpenGL REQUIRED)
  find_package(GTK2 2.6 REQUIRED gtk)
  find_package(X11 REQUIRED)
  find_library(XINPUT_LIBRARY libXi.so)
  find_package(Threads REQUIRED)

  if(XINPUT_LIBRARY STREQUAL "XINPUT_LIBRARY-NOTFOUND")
      message(FATAL_ERROR "Could not find libXi.so")
  endif()

  if(NOT OPENGL_FOUND)
      message(FATAL_ERROR "Could not find OpenGl libraries")
  endif()

  if(NOT GTK2_FOUND)
    message(FATAL_ERROR "Could not find GTK2.8 libraries")
  endif()

  if(NOT X11_FOUND)
    message(FATAL_ERROR "Could not find X11 libraries")
  endif()

  target_include_directories(Milton PRIVATE
    ${GTK2_INCLUDE_DIRS}
    ${X11_INCLUDE_DIR}
    ${OPENGL_INCLUDE_DIR}
  )

  target_link_libraries(Milton
    ${GTK2_LIBRARIES}
    ${X11_LIBRARIES}
    ${OPENGL_LIBRARIES}
    ${XINPUT_LIBRARY}
    SDL3::SDL3
    ${CMAKE_THREAD_LIBS_INIT}
    ${CMAKE_DL_LIBS}
    )

else()
  target_link_libraries(Milton SDL3::SDL3)
endif()

if(APPLE)
  target_link_libraries(Milton
    "-framework OpenGL"
  )
endif()


if(WIN32 OR APPLE)
  target_include_directories(Milton PRIVATE
    ${SDL3DIR}/include
  )
endif()

add_custom_command(TARGET Milton POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
    ${MILTON_RUNTIME_ASSETS}
    $<TARGET_FILE_DIR:Milton>
)

add_dependencies(Milton shadergen)


add_custom_command(
  COMMAND $<TARGET_FILE:shadergen>
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  DEPENDS ${ShaderSources}
  OUTPUT src/shaders.gen.h
)
