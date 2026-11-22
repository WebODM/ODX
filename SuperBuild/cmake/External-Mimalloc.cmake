set(_proj_name mimalloc)
set(_SB_BINARY_DIR "${SB_BINARY_DIR}/${_proj_name}")

# Runs after every other project, so that every program is installed before it is patched
get_property(_mimalloc_depends DIRECTORY PROPERTY BUILDSYSTEM_TARGETS)

ExternalProject_Add(${_proj_name}
  DEPENDS           ${_mimalloc_depends}
  PREFIX            ${_SB_BINARY_DIR}
  TMP_DIR           ${_SB_BINARY_DIR}/tmp
  STAMP_DIR         ${_SB_BINARY_DIR}/stamp
  #--Download step--------------
  DOWNLOAD_DIR      ${SB_DOWNLOAD_DIR}
  URL               https://github.com/microsoft/mimalloc/releases/download/v3.7.0/mimalloc-v2.5.3-windows-x64.tar.gz
  URL_HASH          SHA256=1403953c3b9357ad21bc41d9aea4020ce37f47d260b3beb472a834d153ed75e7
  SOURCE_DIR        ${SB_SOURCE_DIR}/${_proj_name}
  UPDATE_COMMAND    ""
  CONFIGURE_COMMAND ""
  BUILD_IN_SOURCE 1
  BUILD_COMMAND     ""
  INSTALL_COMMAND   ${CMAKE_COMMAND} -DMIMALLOC_DIR=${SB_SOURCE_DIR}/${_proj_name} -DINSTALL_DIR=${SB_INSTALL_DIR}
                    -P ${CMAKE_CURRENT_LIST_DIR}/MimallocInject.cmake
  #--Output logging-------------
  LOG_DOWNLOAD      OFF
  LOG_CONFIGURE     OFF
  LOG_BUILD         OFF
)
