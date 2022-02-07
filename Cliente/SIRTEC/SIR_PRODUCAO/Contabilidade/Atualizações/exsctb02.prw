#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function exsctb02()
Local oBrowse
NEW MODEL ;
TYPE 2 ;
DESCRIPTION "Contas por Tipo - Margem Contribuicao" ;
BROWSE oBrowse ;
SOURCE "exsctb02" ;
MODELID "ECTB02M" ;
PrimaryKey({'ZS_FILIAL','ZS_CODIGO','ZS_CTAINI'}) ;
MASTER "SZS" ;
HEADER { 'ZS_CODIGO', 'ZS_DESC'} ;
RELATION { { 'ZS_FILIAL', 'xFilial( "SZS" )' }, ;
{ 'ZS_CODIGO', 'ZS_CODIGO'}} ;    
UNIQUELINE { 'ZS_CTAINI' } ;
ORDERKEY SZS->(IndexKey( 1 ) ) 

Return NIL
