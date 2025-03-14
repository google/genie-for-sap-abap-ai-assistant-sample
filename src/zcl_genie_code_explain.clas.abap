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

CLASS zcl_genie_code_explain DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sedi_context_menu_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENIE_CODE_EXPLAIN IMPLEMENTATION.


  METHOD if_sedi_context_menu_extension~execute_function.

* This class is maintained in table TSE_CTXT_MENU.
    zcl_genie_api=>get_instance( )->execute(
      EXPORTING
        iv_feature          = zif_genie_enhancement=>gc_feature-code_explain
        io_gui_control      = i_gui_control
        iv_line_from        = i_line_from
        iv_line_from_offset = i_line_from_offset
        iv_line_to          = i_line_to
        iv_line_to_offset   = i_line_to_offset
        it_source           = i_source
        is_trkey            = i_trkey
        io_editor_handle    = i_editor_handle ).

  ENDMETHOD.


  METHOD if_sedi_context_menu_extension~keep_focus.
    r_value = abap_true.
  ENDMETHOD.
ENDCLASS.
