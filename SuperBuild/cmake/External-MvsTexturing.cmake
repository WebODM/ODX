set(_proj_name mvstexturing)
set(_SB_BINARY_DIR "${SB_BINARY_DIR}/${_proj_name}")

if (WIN32)
  # Link texrecon against mimalloc (will also need to make it the *first* import)
  set(_MIMALLOC_DEP mimalloc)
  set(_MIMALLOC_ARGS
    "-DCMAKE_EXE_LINKER_FLAGS=/LIBPATH:${SB_INSTALL_DIR}/lib mimalloc.dll.lib /INCLUDE:mi_version")
endif()

ExternalProject_Add(${_proj_name}
  DEPENDS           mve ${_MIMALLOC_DEP}
  PREFIX            ${_SB_BINARY_DIR}
  TMP_DIR           ${_SB_BINARY_DIR}/tmp
  STAMP_DIR         ${_SB_BINARY_DIR}/stamp
  #--Download step--------------
  DOWNLOAD_DIR      ${SB_DOWNLOAD_DIR}/${_proj_name}
  GIT_REPOSITORY    https://github.com/WebODM/mvs-texturing
  GIT_TAG           a56b5e7f95f0bb1dd1e1eb89ce5da202349c0e01
  #--Update/Patch step----------
  UPDATE_COMMAND    ""
  #--Configure step-------------
  SOURCE_DIR        ${SB_SOURCE_DIR}/${_proj_name}
  CMAKE_ARGS
    -DRESEARCH=OFF
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_INSTALL_PREFIX:PATH=${SB_INSTALL_DIR}
    ${WIN32_CMAKE_ARGS}
    ${_MIMALLOC_ARGS}
		${APPLE_CMAKE_ARGS}
  #--Build step-----------------
  BINARY_DIR        ${_SB_BINARY_DIR}
  #--Install step---------------
  INSTALL_DIR       ${SB_INSTALL_DIR}
  #--Output logging-------------
  LOG_DOWNLOAD      OFF
  LOG_CONFIGURE     OFF
  LOG_BUILD         OFF
)

if (WIN32)
  # make mimalloc the first import
  ExternalProject_Add_Step(${_proj_name} mimalloc_inject
    COMMAND           ${SB_SOURCE_DIR}/mimalloc/bin/minject.exe --inplace
                      ${SB_INSTALL_DIR}/bin/texrecon.exe
    DEPENDEES         install
    COMMENT           "Moving mimalloc to the front of texrecon.exe's imports"
  )
endif()