#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"                                             
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"            

// ####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: LMEDIMPCTE.PRW                                                        ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ## 
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 21/10/2019                                                            ##
// Objetivo..: Programa que realiza a importação de CTEs do SimFrete                 ##
//             Para o perfeito funcionamento deste programa, variáveis de ambiente   ##
//             LEF ... devem estar devidamente parametrizadas.                       ##
//             Para a parametrização das variáveis, deve ser utilizado o programa    ##
//             LMEDPARCTE (Disponibilizar este programa em menu).                    ## 
// #################################################################################### 

User Function SOLTLEDIC()

   Local cAliasX3 := GetNextAlias()

   OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,cAliasX3,"SX3",Nil,.F.)
   
   lOpen := Select(cAliasX3) > 0
		
   If lOpen

  	  dbSelectArea(cAliasX3)

	  (cAliasX3)->(dbSetOrder(1))
	  (cAliasX3)->(dbSeek("SZ5"))

	  While ( !(cAliasX3)->(Eof()) .And. (cAliasX3)->X3_ARQUIVO == "SZ5" )
	     If ( X3USO((cAliasX3)->X3_USADO)      .And. ;
	          cNivel >= (cAliasX3)->X3_NIVEL ) .and. ;
	          (!Alltrim((cAliasX3)->X3_CAMPO) $ "Z5_COD/Z5_VEND/Z5_DIA/Z5_HORA/Z5_DATA/Z5_NROSEM" )
  			nUsado++
			Aadd(aHeader,{ TRIM(X3Titulo())          ,;
			               TRIM((cAliasX3)->X3_CAMPO),;
			              (cAliasX3)->X3_PICTURE     ,;
				          (cAliasX3)->X3_TAMANHO     ,;
				          (cAliasX3)->X3_DECIMAL     ,;
				          (cAliasX3)->X3_VALID       ,;
				          (cAliasX3)->X3_USADO       ,;
				          (cAliasX3)->X3_TIPO        ,;
				          (cAliasX3)->X3_F3          ,;
				          (cAliasX3)->X3_CONTEXT } )
		 EndIf
		 (cAliasX3)->(dbSkip())
	  EndDo
	
	  (cAliasX3)->(DBCloseArea())
	
   Endif
		
   For x:=1 to Len(aHeader)
   	   cCampo := aHeader[x][2]
	   If GetSx3Cache( cCampo , "X3_CONTEXT" ) == "V" 
		  Aadd( aVirtual , AllTrim(cCampo) )
	   Endif    
	   aCols[1,x] := CriaVar(AllTrim(cCampo))	
   Next x

   aCols[1,Len(aHeader)+1] := .F.
   
Return(.T.)