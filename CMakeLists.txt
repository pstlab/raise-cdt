cmake_minimum_required(VERSION 3.21)
project(RAISE-CDT VERSION 0.2.0 LANGUAGES CXX)

include(CTest)
enable_testing()

option(INTERACTIVE_TEST "Enable interactive test mode" OFF)

set(COCO_NAME "RAISE-CDT" CACHE STRING "The CoCo Application Name" FORCE)
set(BUILD_MONGODB ON CACHE BOOL "Build MongoDB connection" FORCE)
set(BUILD_COCO_SERVER ON CACHE BOOL "Build the CoCo server" FORCE)

add_executable(raise-cdt src/main.cpp src/raise_cdt.cpp src/raise_cdt_server.cpp src/raise_cdt_db.cpp)
target_compile_features(raise-cdt PUBLIC cxx_std_17)
target_include_directories(raise-cdt PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)
if(NOT TARGET CoCo)
    add_subdirectory(extern/coco)
endif()
add_dependencies(raise-cdt CoCo)
target_link_libraries(raise-cdt PUBLIC CoCo)
setup_sanitizers(raise-cdt)

if(INTERACTIVE_TEST)
    target_compile_definitions(raise-cdt PUBLIC INTERACTIVE_TEST)
endif()

set(CPACK_PROJECT_NAME json)
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)