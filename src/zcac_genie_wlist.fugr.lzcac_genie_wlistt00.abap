*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCAC_GENIE_WLIST................................*
DATA:  BEGIN OF STATUS_ZCAC_GENIE_WLIST              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCAC_GENIE_WLIST              .
CONTROLS: TCTRL_ZCAC_GENIE_WLIST
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCAC_GENIE_WLIST              .
TABLES: ZCAC_GENIE_WLIST               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
