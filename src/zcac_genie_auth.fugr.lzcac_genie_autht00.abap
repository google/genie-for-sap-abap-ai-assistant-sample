*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCAC_GENIE_AUTH.................................*
DATA:  BEGIN OF STATUS_ZCAC_GENIE_AUTH               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCAC_GENIE_AUTH               .
CONTROLS: TCTRL_ZCAC_GENIE_AUTH
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCAC_GENIE_AUTH               .
TABLES: ZCAC_GENIE_AUTH                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
