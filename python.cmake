# Copyright (C) 2010 Florent Lamiraux, Thomas Moulard, JRL, CNRS/AIST.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

MACRO(FINDPYTHON)
INCLUDE(FindPythonLibs)
IF (NOT ${PYTHONLIBS_FOUND} STREQUAL TRUE)
   MESSAGE(FATAL_ERROR "Python has not been found.")
ENDIF (NOT ${PYTHONLIBS_FOUND} STREQUAL TRUE)

INCLUDE(FindPythonInterp)
IF (NOT ${PYTHONINTERP_FOUND} STREQUAL TRUE)
   MESSAGE(FATAL_ERROR "Python executable has not been found.")
ENDIF (NOT ${PYTHONINTERP_FOUND} STREQUAL TRUE)
ENDMACRO(FINDPYTHON)


#
# DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME LIBRARYNAME
# ---------------------------
#
# Add a python submodule to dynamic_graph
#
#  SUBMODULENAME : the name of the submodule (can be foo/bar),
#
#  LIBRARYNAME   : library to link the submodule with.
#
#  TARGETNAME    : name of the target: should be different for several
#                  calls to the macro.
#
#  NOTICE : Before calling this macro, set variable NEW_ENTITY_CLASS as
#           the list of new Entity types that you want to be bound.
#           Entity class name should match the name referencing the type
#           in the factory.
#
MACRO(DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME LIBRARYNAME TARGETNAME)
  FINDPYTHON()

  SET(PYTHON_MODULE dynamic_graph/${TARGETNAME})

  ADD_LIBRARY(${PYTHON_MODULE}
    MODULE
    ${CMAKE_SOURCE_DIR}/cmake/dynamic_graph/python-module-py.cc)

  SET_TARGET_PROPERTIES(${PYTHON_MODULE}
    PROPERTIES PREFIX "")

  TARGET_LINK_LIBRARIES(${PYTHON_MODULE} ${LIBRARYNAME})

  INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})

  #
  # Installation
  #

  EXEC_PROGRAM(${PYTHON_EXECUTABLE} ARGS "-c \"from distutils import sysconfig; print sysconfig.get_python_lib(0,0,prefix='')\""
    OUTPUT_VARIABLE PYTHON_SITELIB)

  SET(PYTHON_INSTALL_DIR ${PYTHON_SITELIB}/dynamic_graph/${SUBMODULENAME})

  INSTALL(TARGETS ${PYTHON_MODULE}
    DESTINATION
    ${PYTHON_INSTALL_DIR})

  SET(ENTITY_CLASS_LIST "")
  FOREACH (ENTITY ${NEW_ENTITY_CLASS})
    SET(ENTITY_CLASS_LIST "${ENTITY_CLASS_LIST}${ENTITY}('')\n")
  ENDFOREACH(ENTITY ${NEW_ENTITY_CLASS})

  CONFIGURE_FILE(
    ${CMAKE_SOURCE_DIR}/cmake/dynamic_graph/submodule/__init__.py.cmake
    ${CMAKE_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/__init__.py
    )

  INSTALL(
    FILES ${CMAKE_BINARY_DIR}/src/dynamic_graph/${SUBMODULENAME}/__init__.py
    DESTINATION ${PYTHON_INSTALL_DIR}
    )

ENDMACRO(DYNAMIC_GRAPH_PYTHON_MODULE SUBMODULENAME)
