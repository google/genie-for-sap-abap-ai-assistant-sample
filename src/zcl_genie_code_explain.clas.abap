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
