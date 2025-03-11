"Name: \TY:CL_TPDA_TOOL_EDITOR_AB4\ME:HANDLE_CONTEXT_MENU_SELECTED\SE:BEGIN\EI
ENHANCEMENT 0 ZEIMP_CA_GENIE_DEBUGGER.

IF fcode CP 'G_*'.

  INCLUDE zeca_genie_debugger IF FOUND.

  " No need to run the standard code for G_* fcode
  " as all of the standard code will get skipped based on checks
  RETURN.

ENDIF.

ENDENHANCEMENT.
