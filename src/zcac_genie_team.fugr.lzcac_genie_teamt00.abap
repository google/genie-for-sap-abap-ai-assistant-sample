*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCAC_GENIE_TEAM.................................*
DATA:  BEGIN OF STATUS_ZCAC_GENIE_TEAM               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCAC_GENIE_TEAM               .
CONTROLS: TCTRL_ZCAC_GENIE_TEAM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCAC_GENIE_TEAM               .
TABLES: ZCAC_GENIE_TEAM                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
