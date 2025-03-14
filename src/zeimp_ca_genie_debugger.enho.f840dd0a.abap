"Name: \TY:CL_TPDA_TOOL_EDITOR_AB4\ME:HANDLE_CONTEXT_MENU_SELECTED\SE:BEGIN\EI
ENHANCEMENT 0 ZEIMP_CA_GENIE_DEBUGGER.
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
IF fcode CP 'G_*'.

  INCLUDE zeca_genie_debugger IF FOUND.

  " No need to run the standard code for G_* fcode
  " as all of the standard code will get skipped based on checks
  RETURN.

ENDIF.

ENDENHANCEMENT.
