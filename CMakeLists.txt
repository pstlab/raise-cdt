cmake_minimum_required(VERSION 3.21)
project(RAISE-CDT VERSION 0.2.0 LANGUAGES CXX)

include(CTest)
enable_testing()

set(COCO_NAME "RAISE-CDT" CACHE STRING "The CoCo Application Name" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "Build tests" FORCE)
set(BUILD_MONGODB ON CACHE BOOL "Build MongoDB connection" FORCE)
set(BUILD_FCM ON CACHE BOOL "Build Firebase Cloud Messaging" FORCE)
set(BUILD_MQTT ON CACHE BOOL "Build MQTT middleware" FORCE)
set(BUILD_LLM ON CACHE BOOL "Build CoCo LLM" FORCE)
set(BUILD_COCO_SERVER ON CACHE BOOL "Build the CoCo server" FORCE)
set(SERVER_PORT "8080" CACHE STRING "The CoCo Server Port" FORCE)
set(ENABLE_CORS ON CACHE BOOL "Enable CORS middleware" FORCE)
set(LOGGING_LEVEL "TRACE" CACHE STRING "Logging level (DEBUG, INFO, WARN, ERROR)" FORCE)

add_subdirectory(extern/coco)

set(RAISE_CDT_CONFIG_TYPES types/RAISE-Warning.json types/RAISE-User.json)
set(RAISE_CDT_CONFIG_RULES rules/raise.clp)
coco_config(RAISE_CDT "${RAISE_CDT_CONFIG_TYPES}" "${RAISE_CDT_CONFIG_RULES}")

add_executable(raise-cdt src/main.cpp src/raise_cdt.cpp src/raise_cdt_server.cpp src/raise_cdt_db.cpp src/raise_cdt_mqtt.cpp)
target_compile_features(raise-cdt PUBLIC cxx_std_17)
target_include_directories(raise-cdt PUBLIC "${RAISE_CDT_CONFIG_INCLUDE_DIR}" $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)
add_dependencies(raise-cdt CoCo RAISE_CDT)
target_link_libraries(raise-cdt PUBLIC CoCo)
setup_sanitizers(raise-cdt)

set(CPACK_PROJECT_NAME json)
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)