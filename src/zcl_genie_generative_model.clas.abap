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

CLASS zcl_genie_generative_model DEFINITION
  PUBLIC
  INHERITING FROM /goog/cl_generative_model
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS generate_content
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GENIE_GENERATIVE_MODEL IMPLEMENTATION.


  METHOD generate_content.

    DATA:
      lv_p_projects_id   TYPE string,
      lv_p_locations_id  TYPE string,
      lv_p_publishers_id TYPE string,
      lv_p_models_id     TYPE string,
      ls_input           TYPE /goog/cl_aiplatform_v1=>ty_726,
      ls_output          TYPE /goog/cl_aiplatform_v1=>ty_727,
      lv_ret_code        TYPE i,
      lv_err_text        TYPE string,
      ls_err_resp        TYPE /goog/err_resp,
      ls_part            TYPE /goog/cl_aiplatform_v1=>ty_740,
      ls_content         TYPE /goog/cl_aiplatform_v1=>ty_695,
      ls_raw             TYPE string,
      ls_tool            TYPE /goog/cl_aiplatform_v1=>ty_755.

    CLEAR:
          ls_input.

    lv_p_projects_id   = go_aiplatform_client->gv_project_id.
    lv_p_locations_id  = gs_ai_config-locations_id.
    lv_p_publishers_id = gs_ai_config-publishers_id.
    lv_p_models_id     = gs_ai_config-model_id.

    ls_content-role = 'user'.

    ls_part-text = iv_prompt_text.
    APPEND ls_part TO ls_content-parts.
    CLEAR ls_part.

    IF gt_parts IS NOT INITIAL.
      APPEND LINES OF gt_parts TO ls_content-parts.

    ENDIF.

    APPEND ls_content TO ls_input-contents.
    CLEAR ls_content.

    IF gs_content_function_call IS NOT INITIAL.
      APPEND gs_content_function_call TO ls_input-contents.

    ENDIF.

    IF gs_content_function_response IS NOT INITIAL.
      APPEND gs_content_function_response TO ls_input-contents.

    ENDIF.

    IF gv_system_instruction IS NOT INITIAL.
      ls_input-system_instruction-role = 'system'.
      ls_part-text = gv_system_instruction.
      APPEND ls_part TO ls_input-system_instruction-parts.
      CLEAR ls_part.

    ENDIF.

    IF gv_retrieval_datastore IS NOT INITIAL.
      ls_tool-retrieval-vertex_ai_search-datastore = gv_retrieval_datastore.

    ENDIF.

    IF gt_function_declaration IS NOT INITIAL.
      ls_tool-function_declarations = gt_function_declaration.

    ENDIF.

    IF ls_tool IS NOT INITIAL.
      APPEND ls_tool TO ls_input-tools.
      CLEAR ls_tool.

    ENDIF.

    IF gs_tool_config IS NOT INITIAL.
      ls_input-tool_config = gs_tool_config.

    ENDIF.

    IF gv_response_mime_type IS NOT INITIAL.
      ls_input-generation_config-response_mime_type = gv_response_mime_type.

    ENDIF.

    ls_input-generation_config-temperature = gs_ai_config-temperature.
    ls_input-generation_config-top_p = gs_ai_config-top_p.

    IF gs_ai_config-top_k IS NOT INITIAL.
      ls_input-generation_config-top_k = gs_ai_config-top_k.

    ENDIF.

    ls_input-generation_config-max_output_tokens = gs_ai_config-max_output_tokens.

    IF gs_ai_config-presence_penalty IS NOT INITIAL.
      ls_input-generation_config-presence_penalty  = gs_ai_config-presence_penalty.

    ENDIF.

    IF gs_ai_config-frequency_penalty IS NOT INITIAL.
      ls_input-generation_config-frequency_penalty = gs_ai_config-frequency_penalty.

    ENDIF.

    IF gt_safety_settings IS NOT INITIAL.
      ls_input-safety_settings = gt_safety_settings.

    ENDIF.

    go_aiplatform_client->set_useragent_suffix(
      iv_useragent_suffix  = /goog/cl_vertex_ai_sdk_utility=>get_useragent_suffix(
        iv_module_identifier = 'G01' ) ).   " Genie Version 01

    CALL METHOD go_aiplatform_client->generate_content_models
      EXPORTING
        iv_p_projects_id   = lv_p_projects_id
        iv_p_locations_id  = lv_p_locations_id
        iv_p_publishers_id = lv_p_publishers_id
        iv_p_models_id     = lv_p_models_id
        is_input           = ls_input
      IMPORTING
        es_raw             = ls_raw
        es_output          = ls_output
        ev_ret_code        = lv_ret_code
        ev_err_text        = lv_err_text
        es_err_resp        = ls_err_resp.
    IF go_aiplatform_client->is_success( lv_ret_code ) = abap_true.
      IF gv_auto_invoke_sap_function = abap_true.
        gv_auto_invoke_sap_function = abap_false.
        CLEAR:
              gv_function_name,
              gt_function_parameters.
        CALL METHOD get_function_call
          EXPORTING
            is_content             = ls_output
          IMPORTING
            ev_function_name       = gv_function_name
            et_function_parameters = gt_function_parameters.
        IF gv_function_name IS NOT INITIAL.
          CALL METHOD invoke_sap_function
            EXPORTING
              iv_prompt_text         = iv_prompt_text
              iv_function_name       = gv_function_name
              it_function_parameters = gt_function_parameters
            IMPORTING
              es_content_response    = ls_output.

        ENDIF.
        CREATE OBJECT ro_model_response
          EXPORTING
            is_content_response    = ls_output
            iv_function_name       = gv_function_name
            it_function_parameters = gt_function_parameters.
      ELSE.
        CREATE OBJECT ro_model_response
          EXPORTING
            is_content_response = ls_output.

      ENDIF.
    ELSE.
      CALL METHOD /goog/cl_vertex_ai_sdk_utility=>raise_error
        EXPORTING
          iv_ret_code = lv_ret_code
          iv_err_text = lv_err_text.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
