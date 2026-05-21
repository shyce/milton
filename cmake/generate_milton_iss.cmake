# Regenerate Milton.iss from Milton.iss.in using src/milton_configuration.h.
# Usage: cmake -P cmake/generate_milton_iss.cmake

get_filename_component(MILTON_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(MILTON_VERSION_HEADER "${MILTON_SOURCE_DIR}/src/milton_configuration.h")

include("${MILTON_SOURCE_DIR}/cmake/MiltonVersion.cmake")
milton_read_version_from_header("${MILTON_VERSION_HEADER}")

configure_file(
    "${MILTON_SOURCE_DIR}/Milton.iss.in"
    "${MILTON_SOURCE_DIR}/Milton.iss"
    @ONLY)

message(STATUS "Generated ${MILTON_SOURCE_DIR}/Milton.iss (${MILTON_VERSION})")
