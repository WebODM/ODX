# Puts mimalloc next to the SuperBuild's programs and patches each one with minject,
# so it loads mimalloc in place of the C runtime's memory allocator.
# exiftool.exe is a 32-bit program and is left as is.
foreach(_dir "${INSTALL_DIR}/bin" "${INSTALL_DIR}/bin/OpenMVS")
  file(COPY "${MIMALLOC_DIR}/bin/mimalloc.dll" "${MIMALLOC_DIR}/bin/mimalloc-redirect.dll" DESTINATION "${_dir}")
  file(GLOB _exes "${_dir}/*.exe")
  foreach(_exe ${_exes})
    get_filename_component(_name "${_exe}" NAME)
    if (NOT _name STREQUAL "exiftool.exe")
      # minject often crashes when given relative paths: give it absolute ones
      file(TO_NATIVE_PATH "${_exe}" _exe_native)
      execute_process(COMMAND "${MIMALLOC_DIR}/bin/minject.exe" --force --inplace "${_exe_native}"
                      RESULT_VARIABLE _result OUTPUT_QUIET ERROR_QUIET)
      if (NOT _result EQUAL 0)
        message(FATAL_ERROR "minject failed on ${_exe}: ${_result}")
      endif()
    endif()
  endforeach()
endforeach()
