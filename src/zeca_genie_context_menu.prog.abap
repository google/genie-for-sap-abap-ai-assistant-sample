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
*&---------------------------------------------------------------------*
*& Include          ZECA_GENIE_CONTEXT_MENU
*&---------------------------------------------------------------------*

DATA: lt_function TYPE ui_functions.
DATA: ls_entry TYPE sctx_entry.

IF NOT line_exists( entrytab[ text = zif_genie_enhancement=>gc_genie ] ) .
  DATA(lo_menu_sub) = zcl_genie_enhancement=>get_instance( )->enhance_right_click(
                        EXPORTING
                          it_entrytab = entrytab ).
  IF lo_menu_sub IS BOUND.
    ls_entry-type = sctx_c_type_submenu.
    ls_entry-menu = lo_menu_sub.
    ls_entry-text = zif_genie_enhancement=>gc_genie.

    SET HANDLER on_submenu_changed FOR lo_menu_sub.
    APPEND ls_entry TO entrytab.
    RAISE EVENT changed.

    CALL METHOD add_separator.
  ENDIF.

ENDIF.
