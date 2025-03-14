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

*&---------------------------------------------------------------------*
*& Report ZR_GENIE_CONTEXT_MENU
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_genie_context_menu.

* This program contains a PF-status being used in GenAI Powered SAP ABAP Editor.

PARAMETERS: p_gsetup RADIOBUTTON GROUP g1,
            p_gdel   RADIOBUTTON GROUP g1.

START-OF-SELECTION.

  DATA: lt_ctxt_menu TYPE STANDARD TABLE OF tse_ctxt_menu.

  SELECT SINGLE cccategory FROM t000
    INTO @DATA(lv_client_role)
    WHERE mandt = @sy-mandt.
  IF sy-subrc <> 0.
    " Could not determine system client category.
    MESSAGE i012(zca_genie_msg) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  " Genie features are not relevant for the Production, and SAP systems.
  IF lv_client_role = 'P'
  OR lv_client_role = 'S'.
    " This tool should not be used in Production or SAP Reference systems.
    MESSAGE i013(zca_genie_msg) DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  IF p_gsetup IS NOT INITIAL.

    APPEND VALUE #( fcode = zif_genie_enhancement=>gc_feature-code_explain
                    class = 'ZCL_GENIE_CODE_EXPLAIN' ) TO lt_ctxt_menu.
    APPEND VALUE #( fcode = zif_genie_enhancement=>gc_feature-code_review
                    class = 'ZCL_GENIE_CODE_REVIEW' ) TO lt_ctxt_menu.
    APPEND VALUE #( fcode = zif_genie_enhancement=>gc_feature-code_assist
                    class = 'ZCL_GENIE_CODE_ASSIST' ) TO lt_ctxt_menu.
    APPEND VALUE #( fcode = zif_genie_enhancement=>gc_feature-aut_assist
                    class = 'ZCL_GENIE_AUT_ASSIST' ) TO lt_ctxt_menu.
    APPEND VALUE #( fcode = zif_genie_enhancement=>gc_feature-translate
                    class = 'ZCL_GENIE_TRANSLATE' ) TO lt_ctxt_menu.

    MODIFY tse_ctxt_menu FROM TABLE lt_ctxt_menu.
    IF sy-subrc = 0.
      " Genie Context Setup Successful!
      MESSAGE i008(zca_genie_msg) DISPLAY LIKE 'S'.
    ELSE.
      " Genie Context Setup failed. Please contact Google ABAP SDK Team!
      MESSAGE i009(zca_genie_msg) DISPLAY LIKE 'E'.
    ENDIF.

  ELSEIF p_gdel IS NOT INITIAL.

    DELETE FROM tse_ctxt_menu WHERE class LIKE 'ZCL_GENIE%'.
    IF sy-subrc = 0.
      " Genie Context Setup Deleted!
      MESSAGE i010(zca_genie_msg) DISPLAY LIKE 'S'.
    ELSE.
      " Genie Context Setup Deletion failed. Please contact Google ABAP SDK Team!
      MESSAGE i011(zca_genie_msg) DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.
