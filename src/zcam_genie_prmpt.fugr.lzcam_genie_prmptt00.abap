*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCAM_GENIE_PRMPT................................*
DATA:  BEGIN OF STATUS_ZCAM_GENIE_PRMPT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCAM_GENIE_PRMPT              .
CONTROLS: TCTRL_ZCAM_GENIE_PRMPT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZCAM_GENIE_PRMPT              .
TABLES: ZCAM_GENIE_PRMPT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
