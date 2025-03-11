*&---------------------------------------------------------------------*
*& Include          ZECA_GENIE_DEBUGGER
*&---------------------------------------------------------------------*
TRY.
    IF edit_ctrl->_is_event_sender( sender ) EQ abap_true.

      CLEAR: from_line,
             from_pos,
             to_line,
             to_pos.

      CALL METHOD edit_ctrl->get_selection_pos
        IMPORTING
          from_line = from_line
          from_pos  = from_pos
          to_line   = to_line
          to_pos    = to_pos
        EXCEPTIONS
          OTHERS    = 1.
      IF sy-subrc <>  0.
        RAISE EXCEPTION TYPE cx_tpda_edit_ctrl.
      ENDIF.

      IF from_pos > 0.
        from_pos = from_pos - 1.
      ENDIF.

      zcl_genie_api=>get_instance( )->execute(
          EXPORTING
            iv_feature          = CONV #( fcode )
            iv_line_from        = from_line
            iv_line_from_offset = from_pos
            iv_line_to          = to_line
            iv_line_to_offset   = to_pos
            it_source           = it_source ).
    ENDIF.

  CATCH cx_tpda_edit_ctrl INTO exc_edit_ctrl..
    CALL METHOD cl_tpda_services=>error_log
      EXPORTING
        p_ref = exc_edit_ctrl.
    MESSAGE s800(tpda) DISPLAY LIKE 'E'.

  CATCH cx_tpda_operation_failed INTO exc_op_failed.
    cl_tpda_services=>dynp_message( exc_op_failed ).

  CATCH cx_tpda_bp_internal_error INTO exc_bp_int_error.
    cl_tpda_services=>dynp_message( exc_bp_int_error ).
ENDTRY.
