CLASS zcl_genie_enhancement DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES zif_genie_enhancement .

    ALIASES breakpoint
      FOR zif_genie_enhancement~breakpoint .
    ALIASES enhance_right_click
      FOR zif_genie_enhancement~enhance_right_click .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_instance) TYPE REF TO zif_genie_enhancement .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA go_instance TYPE REF TO zif_genie_enhancement .
    DATA:
      gt_genie_auth TYPE STANDARD TABLE OF zcac_genie_auth .

    METHODS get_calling_program
      RETURNING
        VALUE(rv_block) TYPE string .
ENDCLASS.



CLASS ZCL_GENIE_ENHANCEMENT IMPLEMENTATION.


  METHOD get_calling_program.

    DATA lt_callstack TYPE abap_callstack.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level = 4
      IMPORTING
        callstack = lt_callstack.

    TRY.
        DATA(lr_callstack) = REF #( lt_callstack[ 4 ] ).

        CASE lr_callstack->blocktype.
          WHEN 'FUNCTION'.
            rv_block = lr_callstack->blockname.
          WHEN 'METHOD'.
            rv_block = |{ lr_callstack->mainprogram }->{ lr_callstack->blockname }|.
          WHEN 'MODULE (PBO)'.
            rv_block = lr_callstack->mainprogram.
          WHEN 'MODULE (PAI)'.
            rv_block = lr_callstack->mainprogram.
          WHEN OTHERS.
            rv_block = lr_callstack->mainprogram.
        ENDCASE.
      CATCH cx_sy_itab_line_not_found.
        rv_block = 'Not found'.
    ENDTRY.

  ENDMETHOD.


  METHOD get_instance.

    IF NOT go_instance IS BOUND.
      go_instance = NEW zcl_genie_enhancement( ).
    ENDIF.

    ro_instance = go_instance.

  ENDMETHOD.


  METHOD zif_genie_enhancement~breakpoint.

    SELECT SINGLE low FROM tvarvc
      INTO @DATA(lfl_bp_enabled)
      WHERE name = 'GENIE_BREAKPOINT'
        AND low  = @sy-uname.
    IF sy-subrc = 0.
      BREAK-POINT.
    ENDIF.

  ENDMETHOD.


  METHOD zif_genie_enhancement~enhance_right_click.

    CONSTANTS: lc_evt_context_menu_9 TYPE i VALUE 9,
               lc_evt_context_menu_5 TYPE i VALUE 5.
    DATA: lt_function_to_hide TYPE ui_functions.

    breakpoint( ).

    SELECT SINGLE cccategory FROM t000
      INTO @DATA(lv_client_role)
      WHERE mandt = @sy-mandt.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Genie features are not relevant for the Production, and SAP systems.
    IF lv_client_role = 'P'
    OR lv_client_role = 'S'.
      RETURN.
    ENDIF.

    IF  sy-tcode <> 'SE24'
    AND sy-tcode <> 'SE37'
    AND sy-tcode <> 'SE38'
    AND sy-tcode <> 'SESSION_MANAGER'         " Debugger
    AND sy-tcode <> 'TPDA_CALL_EDITOR'.       " Module pool
      RETURN.
    ENDIF.

    DATA(lv_block) = get_calling_program( ).

    " Ensures that the menu option get added only on the editor
    IF ( sy-tcode = 'SE24'
      OR sy-tcode = 'SE37'
      OR sy-tcode = 'SE38' )
   AND ( lv_block <> zif_genie_enhancement=>gc_trigger-editor_context
     AND lv_block <> zif_genie_enhancement=>gc_trigger-gui_create_context ).
      RETURN.
    ENDIF.

    " To avoid adding the AI option in the toolbar options.
    IF lv_block = zif_genie_enhancement=>gc_trigger-toolbar_init
    OR lv_block = zif_genie_enhancement=>gc_trigger-toolbar_build.
      RETURN.
    ENDIF.

    IF sy-tcode = 'SESSION_MANAGER'.
      " Logic copied from standard class CL_GUI_CFW->DISPATCH_SYSTEM_EVENTS
      ASSIGN ('(SAPMSSYD)MY_UCOMM') TO FIELD-SYMBOL(<lv_ok_code>).
      IF sy-subrc = 0.
        IF <lv_ok_code>+0(4) = '%_GC'.
          REPLACE '%_GC' IN <lv_ok_code> WITH ''.
          CONDENSE <lv_ok_code>.
          SPLIT <lv_ok_code> AT ' ' INTO DATA(lv_f1) DATA(lv_f2) DATA(lv_f3).
        ENDIF.

        IF lv_f2 <> lc_evt_context_menu_9 AND lv_f2 <> lc_evt_context_menu_5.
          RETURN.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lv_block = zif_genie_enhancement=>gc_trigger-debugger_program.
      APPEND zif_genie_enhancement=>gc_feature-aut_assist TO lt_function_to_hide.
      APPEND zif_genie_enhancement=>gc_feature-code_assist TO lt_function_to_hide.
      APPEND zif_genie_enhancement=>gc_feature-code_review TO lt_function_to_hide.
    ENDIF.

    IF lv_client_role = 'T'
    AND lv_block <> zif_genie_enhancement=>gc_trigger-debugger_program.
      APPEND zif_genie_enhancement=>gc_feature-aut_assist TO lt_function_to_hide.
      APPEND zif_genie_enhancement=>gc_feature-code_assist TO lt_function_to_hide.
    ENDIF.

    CREATE OBJECT ro_menu_sub.
    cl_ctmenu=>load_gui_status(
      EXPORTING
        program = zif_genie_enhancement=>gc_program
        status  = zif_genie_enhancement=>gc_status
        disable = lt_function_to_hide
        menu    = ro_menu_sub
      EXCEPTIONS
        OTHERS  = 0 ).

    IF lt_function_to_hide IS NOT INITIAL.
      ro_menu_sub->hide_functions( fcodes = lt_function_to_hide ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
