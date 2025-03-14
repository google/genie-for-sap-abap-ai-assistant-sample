**********************************************************************
*  Copyright 2024 Google LLC                                         *
*                                                                    *
*  Licensed under the Apache License, Version 2.0 (the "License");   *
*  you may not use this file except in compliance with the License.  *
*  You may obtain a copy of the License at                           *
*      https://www.apache.org/licenses/LICENSE-2.0                   *
*  Unless required by applicable law or agreed to in writing,        *
*  software distributed under the License is distributed on an       *
*  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,      *
*  either express or implied.                                        *
*  See the License for the specific language governing permissions   *
*  and limitations under the License.                                *
**********************************************************************

INTERFACE zif_genie_api
  PUBLIC .

  TYPES:
    BEGIN OF gty_string,
      line TYPE c LENGTH 1024,
    END OF gty_string .
  TYPES:
    gty_t_string TYPE STANDARD TABLE OF gty_string .
  TYPES:
    BEGIN OF gty_file_data,
      filename  TYPE string,
      mime_type TYPE string,
      filedata  TYPE string,
    END OF gty_file_data .
  TYPES:
    gty_t_file_data TYPE STANDARD TABLE OF gty_file_data .

  METHODS execute
    IMPORTING
      !iv_feature          TYPE ui_func
      !io_gui_control      TYPE REF TO cl_gui_control OPTIONAL
      !iv_line_from        TYPE i
      !iv_line_from_offset TYPE i
      !iv_line_to          TYPE i
      !iv_line_to_offset   TYPE i
      !it_source           TYPE sedi_source
      !is_trkey            TYPE trkey OPTIONAL
      !io_editor_handle    TYPE REF TO cl_wb_editor OPTIONAL .
ENDINTERFACE.
