INTERFACE zif_genie_enhancement
  PUBLIC .

  CONSTANTS:
    BEGIN OF gc_feature,
      code_explain TYPE ui_func VALUE 'G_EXPLAIN',
      code_review  TYPE ui_func VALUE 'G_REVIEW',
      code_assist  TYPE ui_func VALUE 'G_CODE',
      aut_assist   TYPE ui_func VALUE 'G_AUT',
      translate    TYPE ui_func VALUE 'G_TRANS',
    END OF gc_feature .
  CONSTANTS gc_genie TYPE gui_text VALUE 'AI Assistant' ##NO_TEXT.
  CONSTANTS gc_program TYPE program VALUE 'ZR_GENIE_CONTEXT_MENU' ##NO_TEXT.
  CONSTANTS gc_status TYPE cua_status VALUE 'WB_CONTEXT_SUBMENU' ##NO_TEXT.
  CONSTANTS:
    BEGIN OF gc_trigger,
      abap_editor        TYPE char15 VALUE 'ABAP_EDITOR',
      debugger           TYPE char15 VALUE 'DEBUGGER',
      debugger_program   TYPE string VALUE 'CL_TPDA_TOOL_EDITOR_AB4=======CP->HANDLE_CONTEXT_MENU',
      toolbar_init       TYPE string VALUE 'CL_SALV_GUI_FUNCTION_BUILDER==CP->INIT_CONTEXT_MENU',
      toolbar_build      TYPE string VALUE 'CL_SALV_GUI_FUNCTION_BUILDER==CP->TOOLBAR_BUILD',
      editor_context     TYPE string VALUE 'CL_WB_EDITOR==================CP->ON_HANDLER_CONTEXT_MENU',
      gui_create_context TYPE string VALUE 'CL_SALV_GUI_FUNCTION_BUILDER==CP->CREATE_CONTEXT_MENU',
    END OF gc_trigger .

  METHODS breakpoint .
  METHODS enhance_right_click
    IMPORTING
      !it_entrytab       TYPE sctx_entrytab OPTIONAL
    RETURNING
      VALUE(ro_menu_sub) TYPE REF TO cl_ctmenu .
ENDINTERFACE.
