INTERFACE zif_genie_api
  PUBLIC .

  TYPES:
    BEGIN OF gty_string,
      line TYPE c LENGTH 1024,
    END OF gty_string .
  TYPES:
    gty_t_string TYPE STANDARD TABLE OF gty_string .
  TYPES:
    BEGIN OF gty_file_data,
      filename  TYPE string,
      mime_type TYPE string,
      filedata  TYPE string,
    END OF gty_file_data .
  TYPES:
    gty_t_file_data TYPE STANDARD TABLE OF gty_file_data .

  METHODS execute
    IMPORTING
      !iv_feature          TYPE ui_func
      !io_gui_control      TYPE REF TO cl_gui_control OPTIONAL
      !iv_line_from        TYPE i
      !iv_line_from_offset TYPE i
      !iv_line_to          TYPE i
      !iv_line_to_offset   TYPE i
      !it_source           TYPE sedi_source
      !is_trkey            TYPE trkey OPTIONAL
      !io_editor_handle    TYPE REF TO cl_wb_editor OPTIONAL .
ENDINTERFACE.
