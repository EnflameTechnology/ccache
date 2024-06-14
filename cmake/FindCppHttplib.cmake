mark_as_advanced(CPPHTTPLIB_INCLUDE_DIR)
mark_as_advanced(CPPHTTPLIB_LIBRARY)

if(DEP_CPPHTTPLIB STREQUAL "BUNDLED")
  message(STATUS "Using bundled CppHttplib as requested")
else()
  find_path(CPPHTTPLIB_INCLUDE_DIR httplib.h)
  if(CPPHTTPLIB_INCLUDE_DIR)
    file(READ "${CPPHTTPLIB_INCLUDE_DIR}/httplib.h" _httplib_h)
    string(REGEX MATCH "#define CPPHTTPLIB_VERSION \"([0-9]+).([0-9]+).*([0-9]+)\"" _ "${_httplib_h}")
    set(_cpphttplib_version_string "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}")
    if(NOT "${CMAKE_MATCH_0}" STREQUAL "" AND "${_cpphttplib_version_string}" VERSION_GREATER_EQUAL "${CppHttplib_FIND_VERSION}")
      # Some dists like Fedora package cpp-httplib as a single header while some
      # dists like Debian package it as a traditional library.
      find_library(CPPHTTPLIB_LIBRARY cpp-httplib)
      if(NOT CPPHTTPLIB_LIBRARY)
        find_library(CPPHTTPLIB_LIBRARY httplib)
      endif()

      if(CPPHTTPLIB_LIBRARY)
        message(STATUS "Using system CppHttplib (${CPPHTTPLIB_LIBRARY})")
        add_library(dep_cpphttplib UNKNOWN IMPORTED)
        set_target_properties(dep_cpphttplib PROPERTIES IMPORTED_LOCATION "${CPPHTTPLIB_LIBRARY}")
        set(_cpphttplib_origin "SYSTEM (${CPPHTTPLIB_LIBRARY})")
      else()
        message(STATUS "Using system CppHttplib (${CPPHTTPLIB_INCLUDE_DIR}/httplib.h)")
        add_library(dep_cpphttplib INTERFACE IMPORTED)
        set(_cpphttplib_origin "SYSTEM (${CPPHTTPLIB_INCLUDE_DIR}/httplib.h)")
      endif()
      set_target_properties(dep_cpphttplib PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${CPPHTTPLIB_INCLUDE_DIR}")
      register_dependency(CppHttplib "${_cpphttplib_origin}" "${_cpphttplib_version_string}")
    endif()
  endif()
  if(NOT TARGET dep_cpphttplib)
    message(STATUS "Using bundled CppHttplib since CppHttplib>=${CppHttplib_FIND_VERSION} was not found locally")
  endif()
endif()
