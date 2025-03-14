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

CLASS zcl_genie_api DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES zif_genie_api .

    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_instance) TYPE REF TO zif_genie_api .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA go_instance TYPE REF TO zif_genie_api .
    DATA:
      gt_genie_auth TYPE STANDARD TABLE OF zcac_genie_auth .

    METHODS authorization_check
      IMPORTING
        !iv_feature         TYPE ui_func
      RETURNING
        VALUE(rs_user_auth) TYPE zcac_genie_auth .
    METHODS constructor .
    METHODS convert_string_to_base64
      IMPORTING
        !iv_content      TYPE string
      RETURNING
        VALUE(rv_output) TYPE string .
    METHODS convert_text_to_base64
      IMPORTING
        !it_content      TYPE any
      RETURNING
        VALUE(rv_output) TYPE string .
    METHODS is_package_whitelisted
      IMPORTING
        !is_trkey                      TYPE trkey
      RETURNING
        VALUE(rfl_package_whitelisted) TYPE flag .
    METHODS pre_process
      IMPORTING
        !iv_feature          TYPE ui_func
        !io_gui_control      TYPE REF TO cl_gui_control
        !iv_line_from        TYPE i
        !iv_line_from_offset TYPE i
        !iv_line_to          TYPE i
        !iv_line_to_offset   TYPE i
        !it_source           TYPE sedi_source
        !is_trkey            TYPE trkey
        !is_user_auth        TYPE zcac_genie_auth
        !io_editor_handle    TYPE REF TO cl_wb_editor
      EXPORTING
        !et_content          TYPE zif_genie_api=>gty_t_string
        !ev_prompt           TYPE string .
ENDCLASS.



CLASS ZCL_GENIE_API IMPLEMENTATION.


  METHOD authorization_check.

    CLEAR rs_user_auth.

    LOOP AT gt_genie_auth ASSIGNING FIELD-SYMBOL(<ls_auth>).
      AUTHORITY-CHECK OBJECT 'ZCA_GENIE'
        ID 'ZGN_TEAM'   FIELD <ls_auth>-team
        ID 'ZGN_FEATUR' FIELD iv_feature.
      IF sy-subrc = 0.
        rs_user_auth = <ls_auth>.
        EXIT.
      ENDIF.
    ENDLOOP.
    UNASSIGN <ls_auth>.

  ENDMETHOD.


  METHOD constructor.

    SELECT * FROM zcac_genie_auth INTO TABLE @gt_genie_auth.

  ENDMETHOD.


  METHOD convert_string_to_base64.

    rv_output = cl_http_utility=>encode_base64( EXPORTING unencoded = iv_content ).

  ENDMETHOD.


  METHOD convert_text_to_base64.

    DATA lv_xfile TYPE xstring.
    DATA lt_content TYPE zif_genie_api=>gty_t_string.

    lt_content = it_content.

    CALL FUNCTION 'SCMS_TEXT_TO_XSTRING'
      IMPORTING
        buffer   = lv_xfile
      TABLES
        text_tab = lt_content
      EXCEPTIONS
        failed   = 1
        OTHERS   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    " CL_BCS_CONVERT
    rv_output = cl_http_utility=>encode_x_base64( EXPORTING unencoded = lv_xfile ).

  ENDMETHOD.


  METHOD get_instance.

    IF NOT go_instance IS BOUND.
      go_instance = NEW zcl_genie_api( ).
    ENDIF.

    ro_instance = go_instance.

  ENDMETHOD.


  METHOD is_package_whitelisted.

    " Since there is no clarity from SAP if standard code can be passed to a GenAI model for explanability
    " hence, only custom packages should be whitelisted by the customers.

    CHECK is_trkey-devclass IS NOT INITIAL.

    SELECT * FROM zcac_genie_wlist
      INTO TABLE @DATA(lt_whitelisted_package).
    IF sy-subrc <> 0.
      CLEAR rfl_package_whitelisted.
      RETURN.
    ENDIF.

    IF line_exists( lt_whitelisted_package[ customer_package = '*' ] )
    OR line_exists( lt_whitelisted_package[ customer_package = is_trkey-devclass ] ).
      rfl_package_whitelisted = abap_true.
      RETURN.
    ENDIF.

    DELETE lt_whitelisted_package WHERE customer_package NS '*'.

    LOOP AT lt_whitelisted_package ASSIGNING FIELD-SYMBOL(<ls_package>).
      IF is_trkey-devclass CP <ls_package>-customer_package.
        rfl_package_whitelisted = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    UNASSIGN <ls_package>.

  ENDMETHOD.


  METHOD pre_process.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    SELECT feature,
           sequence,
           prompt
      FROM zcam_genie_prmpt
     WHERE feature = @iv_feature
       AND disable IS INITIAL
     INTO TABLE @DATA(lt_prompts).
    IF sy-subrc <> 0.
      " Prepackaged Prompt missing for the action. Please contact Google Support.
      MESSAGE i001.
    ENDIF.

    SORT lt_prompts BY sequence ASCENDING.
    LOOP AT lt_prompts INTO DATA(ls_prompt).
      ev_prompt = |{ ev_prompt } { ls_prompt-prompt }|.
      CLEAR ls_prompt.
    ENDLOOP.

    CASE iv_feature.

      WHEN zif_genie_enhancement=>gc_feature-code_explain.
        " Explain this!
        IF iv_line_from <> iv_line_to OR ( iv_line_to_offset - iv_line_from_offset ) > 1.
          LOOP AT it_source ASSIGNING FIELD-SYMBOL(<ls_source>) FROM iv_line_from TO iv_line_to.
            APPEND <ls_source> TO et_content.
          ENDLOOP.
        ELSE.
          et_content = it_source.
        ENDIF.

      WHEN zif_genie_enhancement=>gc_feature-code_review.
        " Code Review!
        IF iv_line_from <> iv_line_to OR ( iv_line_to_offset - iv_line_from_offset ) > 1.
          LOOP AT it_source ASSIGNING <ls_source> FROM iv_line_from TO iv_line_to.
            APPEND <ls_source> TO et_content.
          ENDLOOP.
        ELSE.
          et_content = it_source.
        ENDIF.

      WHEN zif_genie_enhancement=>gc_feature-code_assist.
        " Suggest Code!
        DATA(lv_prompt_backup) = ev_prompt.

        IF iv_line_from <> iv_line_to OR ( iv_line_to_offset - iv_line_from_offset ) > 1.
          LOOP AT it_source INTO DATA(ls_source) FROM iv_line_from TO iv_line_to.
            SHIFT ls_source LEFT DELETING LEADING space.
            IF ls_source IS INITIAL.
              CONTINUE.
            ENDIF.
            IF ls_source+0(1) = '*'
            OR ls_source+0(1) = '"'.
              CONCATENATE ev_prompt ls_source+1 ',' INTO ev_prompt SEPARATED BY space.
            ENDIF.
          ENDLOOP.
        ELSE.
          LOOP AT it_source INTO ls_source.
            SHIFT ls_source LEFT DELETING LEADING space.
            IF ls_source IS INITIAL.
              CONTINUE.
            ENDIF.
            IF ls_source+0(1) = '*'
            OR ls_source+0(1) = '"'.
              CONCATENATE ev_prompt ls_source+1 ',' INTO ev_prompt SEPARATED BY space.
            ELSEIF ls_source+0(3) = 'END'
                OR ls_source+0(3) = 'end'.
              " do nothing as this is the last statement in the code
*            ELSE.
*              ev_prompt = lv_prompt_backup.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF ev_prompt = lv_prompt_backup.
          " Please write the instruction as comment, select it then trigger AI action
          MESSAGE i002.
        ENDIF.

      WHEN zif_genie_enhancement=>gc_feature-aut_assist.
        " Suggest AUT!
        IF iv_line_from <> iv_line_to OR ( iv_line_to_offset - iv_line_from_offset ) > 1.
          LOOP AT it_source ASSIGNING <ls_source> FROM iv_line_from TO iv_line_to.
            APPEND <ls_source> TO et_content.
          ENDLOOP.
        ELSE.
          et_content = it_source.
        ENDIF.

      WHEN zif_genie_enhancement=>gc_feature-translate.
        " Translate!
        IF iv_line_from <> iv_line_to OR ( iv_line_to_offset - iv_line_from_offset ) > 1.
          LOOP AT it_source INTO ls_source FROM iv_line_from TO iv_line_to.
            SHIFT ls_source LEFT DELETING LEADING space.
            IF ls_source IS INITIAL.
              CONTINUE.
            ENDIF.
            IF ls_source+0(1) = '*'
            OR ls_source+0(1) = '"'.
              ls_source = ls_source+1.
              SHIFT ls_source LEFT DELETING LEADING space.
              APPEND ls_source TO et_content.
            ELSEIF ls_source CP '*.*"*'.
              SPLIT ls_source AT '"' INTO TABLE DATA(lt_text).
              DESCRIBE TABLE lt_text LINES DATA(lv_lines).
              IF lt_text[ lv_lines - 1 ] = '"'.
                APPEND lt_text[ lv_lines ] TO et_content.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ELSE.
          LOOP AT it_source INTO ls_source.
            SHIFT ls_source LEFT DELETING LEADING space.
            IF ls_source IS INITIAL.
              CONTINUE.
            ENDIF.
            IF ls_source+0(1) = '*'
            OR ls_source+0(1) = '"'.
              ls_source = ls_source+1.
              SHIFT ls_source LEFT DELETING LEADING space.
              APPEND ls_source TO et_content.
            ELSEIF ls_source CP '*.*"*'.
              SPLIT ls_source AT '"' INTO TABLE lt_text.
              DESCRIBE TABLE lt_text LINES lv_lines.
              IF lt_text[ lv_lines - 1 ] = '"'.
                APPEND lt_text[ lv_lines ] TO et_content.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.

        SELECT SINGLE sptxt FROM t002t
          INTO @DATA(lv_language)
          WHERE spras = @sy-langu
            AND sprsl = 'E'.

        IF lv_language IS INITIAL.
          lv_language = 'English'.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '<SYSTEM_LANG>' IN ev_prompt WITH lv_language.

      WHEN OTHERS.
        " TBD
    ENDCASE.

  ENDMETHOD.


  METHOD zif_genie_api~execute.

    DATA:
      lv_system_instructions  TYPE string,
      lt_file_data            TYPE zif_genie_api=>gty_t_file_data,
      lo_generative_model     TYPE REF TO zcl_genie_generative_model,
      lv_response             TYPE string,
      lv_msg                  TYPE string,
      lo_response             TYPE REF TO /goog/cl_model_response,
      lv_complete_source_code TYPE string,
      lv_selected_source_code TYPE string,
      ls_genie_usage          TYPE zcad_genie_usage,
      lv_html_start           TYPE string,
      lv_html_end             TYPE string.

    zcl_genie_enhancement=>get_instance( )->breakpoint( ).

    IF NOT is_package_whitelisted( is_trkey ).
      " Package is not whitelisted. Approval required before adding std package.
      MESSAGE i007.
      RETURN.
    ENDIF.

    DATA(ls_user_auth) = authorization_check( iv_feature ).
    IF ls_user_auth IS INITIAL.
      " Missing Genie Auth for the feature &1.
       MESSAGE i003 WITH iv_feature.
       RETURN.
    ENDIF.

    IF ls_user_auth-model_key IS INITIAL.
      " Maintain Model Key in the team &1
      MESSAGE i006 WITH ls_user_auth-team.
      RETURN.
    ENDIF.

    pre_process(
      EXPORTING
        iv_feature          = iv_feature
        io_gui_control      = io_gui_control
        iv_line_from        = iv_line_from
        iv_line_from_offset = iv_line_from_offset
        iv_line_to          = iv_line_to
        iv_line_to_offset   = iv_line_to_offset
        it_source           = it_source
        is_trkey            = is_trkey
        is_user_auth        = ls_user_auth
        io_editor_handle    = io_editor_handle
      IMPORTING
        et_content          = DATA(lt_content)
        ev_prompt           = DATA(lv_prompt) ).

    CLEAR lt_file_data.

    IF lv_prompt IS INITIAL.
      " Prepackaged Prompt missing for the action. Please contact Google Support.
      MESSAGE i001.
      RETURN.
    ENDIF.

    IF lv_prompt CS '<COMPLETE_SOURCE_CODE>'.
      lv_complete_source_code = convert_text_to_base64( it_source ).

      APPEND VALUE #( filename  = 'COMPLETE_SOURCE_CODE'
                      mime_type = 'text/plain'
                      filedata  = lv_complete_source_code ) TO lt_file_data.
    ELSE.
      lv_complete_source_code = convert_text_to_base64( it_source ).
    ENDIF.

    DATA(lv_complete_source_code_lines) = CONV string( lines( it_source ) ).

    IF lv_prompt CS '<SELECTED_CODE>'.
      lv_selected_source_code = convert_text_to_base64( lt_content ).
      DATA(lv_selected_source_code_lines) = CONV string( lines( lt_content ) ).

      APPEND VALUE #( filename  = 'SELECTED_CODE'
                      mime_type = 'text/plain'
                      filedata  = lv_selected_source_code ) TO lt_file_data.
    ENDIF.

    ls_genie_usage-team = ls_user_auth-team.
    ls_genie_usage-feature = iv_feature.
    GET TIME STAMP FIELD ls_genie_usage-execution_timestamp.

    IF ls_user_auth-disable_usage_logging IS INITIAL.
      DATA(lv_username_raw) = convert_string_to_base64( CONV #( sy-uname ) ).
      DATA(lv_prompt_raw) = convert_string_to_base64( lv_prompt ).
      CONCATENATE lv_username_raw
                  is_trkey-devclass
                  is_trkey-obj_type
                  is_trkey-obj_name
                  is_trkey-sub_type
                  is_trkey-sub_name
                  lv_prompt_raw
                  lv_complete_source_code
                  lv_complete_source_code_lines
                  lv_selected_source_code
                  lv_selected_source_code_lines
             INTO ls_genie_usage-raw_log SEPARATED BY '/'.

      CLEAR: lv_username_raw, lv_prompt_raw.
    ENDIF.

    TRY.
        IF lo_generative_model IS NOT BOUND.
          CREATE OBJECT lo_generative_model
            EXPORTING
              iv_model_key = ls_user_auth-model_key.
        ENDIF.

        lo_generative_model->clear_inline_data( ).

        LOOP AT lt_file_data ASSIGNING FIELD-SYMBOL(<ls_file_data>).
          lo_generative_model->set_inline_data( iv_mime_type = <ls_file_data>-mime_type
                                                iv_data      = <ls_file_data>-filedata ).

        ENDLOOP.

        lo_response = lo_generative_model->set_system_instructions( lv_system_instructions
                                        )->generate_content( lv_prompt ).
        lv_response = lo_response->get_text( ).

        IF iv_feature = zif_genie_enhancement=>gc_feature-code_assist
        OR iv_feature = zif_genie_enhancement=>gc_feature-aut_assist.

          lv_html_start = '<!DOCTYPE html><html><head><title>ABAP Unit Test generated by GenAI model</title></head><body><pre>'.
          lv_html_end = '</pre></body></html>'.

          REPLACE FIRST OCCURRENCE OF '```abap' IN lv_response WITH lv_html_start.
          REPLACE FIRST OCCURRENCE OF '```' IN lv_response WITH lv_html_end.

        ENDIF.

*        FIND FIRST OCCURRENCE OF '```html' IN lv_response offset lv_start.

        IF ls_user_auth-disable_usage_logging IS INITIAL.
          DATA(lv_response_raw) = convert_string_to_base64( lv_response ).
          CONCATENATE ls_genie_usage-raw_log
                      lv_response_raw
                 INTO ls_genie_usage-raw_log SEPARATED BY '/'.
        ENDIF.

        ls_genie_usage-status = 'S'.
        INSERT INTO zcad_genie_usage VALUES ls_genie_usage.

        IF lv_response IS NOT INITIAL.
          REPLACE '```html' IN lv_response WITH ''.
          REPLACE '```' IN lv_response WITH ''.
          REPLACE ALL OCCURRENCES OF '<h2>' IN lv_response WITH '<h3>'.
          REPLACE ALL OCCURRENCES OF '</h2>' IN lv_response WITH '</h3>'.
          REPLACE ALL OCCURRENCES OF '<h1>' IN lv_response WITH '<h2>'.
          REPLACE ALL OCCURRENCES OF '</h1>' IN lv_response WITH '</h2>'.

*          cl_demo_output=>display_html( cl_http_utility=>escape_html( unescaped = lv_response ) ).
          cl_demo_output=>display_html( lv_response ).

        ELSE.
          lv_msg = lo_response->get_finish_reason( ).
          CONCATENATE TEXT-006 lv_msg TEXT-007 TEXT-008 INTO lv_msg
            SEPARATED BY space.

          ls_genie_usage-message = lv_msg.
          ls_genie_usage-status = 'E'.
          INSERT INTO zcad_genie_usage VALUES ls_genie_usage.

          MESSAGE i000 WITH lv_msg.
          RETURN.

        ENDIF.
      CATCH /goog/cx_sdk INTO DATA(lo_cx_sdk).

        lv_msg = lo_cx_sdk->get_text( ).

        ls_genie_usage-message = lv_msg.
        ls_genie_usage-status = 'E'.
        INSERT INTO zcad_genie_usage VALUES ls_genie_usage.

*        cl_demo_output=>display( lv_msg ).
        MESSAGE i000 WITH lv_msg.
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
