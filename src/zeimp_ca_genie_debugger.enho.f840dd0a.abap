"Name: \TY:CL_TPDA_TOOL_EDITOR_AB4\ME:HANDLE_CONTEXT_MENU_SELECTED\SE:BEGIN\EI
ENHANCEMENT 0 ZEIMP_CA_GENIE_DEBUGGER.
************************************************************************************************************************
* Copyright 2024 Google LLC                                                                                            *
* ABAP SDK for Google Cloud is made available as "Software" under the agreement governing your use of                  *
* Google Cloud Platform including the Service Specific Terms available at                                              *
*                                                                                                                      *
* https://cloud.google.com/terms/service-terms                                                                         *
*                                                                                                                      *
* Without limiting the generality of the above terms, you may not modify or distribute ABAP SDK for Google Cloud       *
* without express written permission from Google.                                                                      *
************************************************************************************************************************

IF fcode CP 'G_*'.

  INCLUDE zeca_genie_debugger IF FOUND.

  " No need to run the standard code for G_* fcode
  " as all of the standard code will get skipped based on checks
  RETURN.

ENDIF.

ENDENHANCEMENT.
