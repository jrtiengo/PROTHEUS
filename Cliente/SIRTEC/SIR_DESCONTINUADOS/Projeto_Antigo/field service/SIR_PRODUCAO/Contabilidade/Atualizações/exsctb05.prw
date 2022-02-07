#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

User Function exsctb05()
Local oBrowse
NEW MODEL ;
TYPE 1 ;
DESCRIPTION "Perc Deducao Receita" ;
BROWSE oBrowse ;
SOURCE "exsctb05" ;
MODELID "ECTB05M" ;
PrimaryKey({'ZU_FILIAL','ZU_CC','ZU_DATA'}) ;
MASTER "SZU" 
Return

