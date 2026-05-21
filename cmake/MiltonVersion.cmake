# Read Milton's version from the single source of truth in src/milton_configuration.h.

function(milton_read_version_from_header version_header)
    if(NOT EXISTS "${version_header}")
        message(FATAL_ERROR "Missing Milton version header: ${version_header}")
    endif()

    file(READ "${version_header}" _header_text)

    string(REGEX MATCH "#define[ \t]+MILTON_MAJOR_VERSION[ \t]+([0-9]+)" _ "${_header_text}")
    if(NOT CMAKE_MATCH_1)
        message(FATAL_ERROR "Could not parse MILTON_MAJOR_VERSION from ${version_header}")
    endif()
    set(_major "${CMAKE_MATCH_1}")

    string(REGEX MATCH "#define[ \t]+MILTON_MINOR_VERSION[ \t]+([0-9]+)" _ "${_header_text}")
    if(NOT CMAKE_MATCH_1)
        message(FATAL_ERROR "Could not parse MILTON_MINOR_VERSION from ${version_header}")
    endif()
    set(_minor "${CMAKE_MATCH_1}")

    string(REGEX MATCH "#define[ \t]+MILTON_MICRO_VERSION[ \t]+([0-9]+)" _ "${_header_text}")
    if(NOT CMAKE_MATCH_1)
        message(FATAL_ERROR "Could not parse MILTON_MICRO_VERSION from ${version_header}")
    endif()
    set(_micro "${CMAKE_MATCH_1}")

    set(MILTON_MAJOR_VERSION "${_major}" PARENT_SCOPE)
    set(MILTON_MINOR_VERSION "${_minor}" PARENT_SCOPE)
    set(MILTON_MICRO_VERSION "${_micro}" PARENT_SCOPE)
    set(MILTON_VERSION "${_major}.${_minor}.${_micro}" PARENT_SCOPE)
endfunction()
