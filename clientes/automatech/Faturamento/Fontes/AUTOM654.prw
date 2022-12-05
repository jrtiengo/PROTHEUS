#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM654.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 08/11/2017                                                          ##
// Objetivo..: Gera DANFE da Nota Fiscal em PDF e grava em diretório especificado. ## 
// Parâmetros: Nº Nota Fiscal                                                      ##
//             Série da Nota Fiscal                                                ##
//             lSaida - Indica se vai ter interação com o usuário                  ##
// ##################################################################################

User Function AUTOM654(kDocumento, kSerie, lSaida)

   Default lSaida := .T.

   Private lVideo := lSaida

   // #########################################################
   // Verifica se foi passado o nº do documento no parâmetro ##
   // #########################################################
   If Empty(Alltrim(kDocumento))
      Return(.T.)
   Endif   

   // #####################################################
   // Pesquisa a Nota Fiscal/Série passada por parâmetro ##
   // #####################################################
   If Select("T_GERADANFE") > 0
      T_GERADANFE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT F2_DOC,"
   cSql += "       F2_SERIE  , "
   cSql += "       F2_FILIAL , "
   cSql += "       F2_CLIENTE, "
   cSql += "       F2_LOJA   , "
   cSql += "       F2_EMISSAO, "
   cSql += "       F2_VALBRUT, "
   cSql += "       F2_HORA   , "
   cSql += "       NFE_ID    , "
   cSql += "       TIME_NFE  , "
   cSql += "       DATE_NFE  , "
   cSql += "       STATUS    , "
   cSql += "       STATUSMAIL, "
   cSql += "       SPED.EMAIL, "
   cSql += "       A1_EMAIL  , "
   cSql += "       CONVERT(varchar(8000),convert(binary(8000),XML_ERP)) as XML "
   cSql += "  FROM " + RetSqlName("SF2") + " AS SF2,"
   cSql += "       P11_TSS..SPED050 AS SPED, "
   cSql += "       " + RetSqlName("SC5") + " AS SC5,"
   cSql += "       " + RetSqlName("SA1") + " AS SA1 "
   cSql += "WHERE F2_CHVNFE        <> '' "  
   cSql += "  AND F2_TIPO           = 'N'"
   cSql += "  AND F2_SERIE + F2_DOC = NFE_ID"
   cSql += "  AND F2_FILIAL         = C5_FILIAL "
   cSql += "  AND F2_DOC            = C5_NOTA   "
   cSql += "  AND F2_SERIE          = C5_SERIE  "
   cSql += "  AND A1_COD            = F2_CLIENTE"
   cSql += "  AND A1_LOJA           = F2_LOJA   "
   cSql += "  AND STATUS            = 6  "
   cSql += "  AND NFE_PROT         <> '' "
   cSql += "  AND F2_DOC            = '" + Alltrim(kDocumento) + "'"
   cSql += "  AND F2_SERIE          = '" + Alltrim(kSerie)     + "'"
   cSql += "  AND F2_FILIAL         = '" + Alltrim(cFilAnt)    + "'"
   cSql += "  AND SF2.D_E_L_E_T_   <> '*'"
   cSql += "  AND SPED.D_E_L_E_T_  <> '*'"
   cSql += "  AND SC5.D_E_L_E_T_   <> '*'"
   cSql += "  AND SA1.D_E_L_E_T_   <> '*'"
   cSql += "  ORDER BY F2_EMISSAO DESC "
	
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERADANFE", .T., .T. )

   If T_GERADANFE->( EOF() )
      If lSaida == .T.
         MsgAlert("Não existem dados a serem visualizados para este documento.")
      Endif   
      Return(.T.)
   Endif

   // ##########################################################################
   // Envia para a função que gera da DANFE do documento passado no parâmetro ##
   // ##########################################################################
   GerPDF(T_GERADANFE->F2_DOC,T_GERADANFE->A1_EMAIL,T_GERADANFE->XML,'',T_GERADANFE->F2_FILIAL,T_GERADANFE->F2_SERIE)

Return(.T.)

// ##########################
// Função que gera a Danfe ##
// ##########################
Static Function GerPDF(_cNumNF,_cEmail,cXML,cEmaTransp,cFil,_cSerNF)

   Local _aAreaSX1 := SX1->(GetArea())

   If lVideo == .T.

      Pergunte("NFSIGW",.F.)

      xMV_PAR01 := MV_PAR01
      xMV_PAR02 := MV_PAR02
      xMV_PAR03 := MV_PAR03
      
   Else   

      xMV_PAR01 := _cNumNF
      xMV_PAR02 := _cNumNF
      xMV_PAR03 := _cSerNF
      
      MV_PAR01 := _cNumNF
      MV_PAR02 := _cNumNF
      MV_PAR03 := _cSerNF

   Endif   

   DbSelectArea("SX1")
   DbSetOrder(1)

   // ###########################
   // Altera valor do MV_PAR01 ##
   // ###########################
   If DbSeek("NFSIGW    " + "01")
      If RecLock("SX1",.F.)
         X1_CNT01 := _cNumNF
         MsUnLock()
      EndIf
   EndIf
   
   // ###########################
   // Altera valor do MV_PAR02 ##
   // ###########################
   If DbSeek("NFSIGW    " + "02")
      If RecLock("SX1",.F.)
         X1_CNT01 := _cNumNF
         MsUnLock()
      EndIf
   EndIf

   // ###########################
   // Altera valor do MV_PAR03 ##
   // ###########################
   If DbSeek("NFSIGW    " + "03")
      If RecLock("SX1",.F.)
         X1_CNT01 := _cSerNF
         MsUnLock()
      EndIf
   EndIf

   // ###########################
   // Altera valor do MV_PAR04 ##
   // ###########################
   If DbSeek("NFSIGW    " + "04")
      If RecLock("SX1",.F.)
         X1_PRESEL := 2
         MsUnLock()
      EndIf

      If lVideo == .T.                              
         Pergunte("NFSIGW",.F.)
      Endif   

   	  cFilePrint      := "DANFE_" + AllTrim(MV_PAR01) + "_" + AllTrim(MV_PAR01)
   	  lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
 	  oDanfe          := FWMSPrinter():New(cFilePrinte, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .F.)
 	  nFlags          := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
 	  oSetup          := FWPrintSetup():New(nFlags, "DANFE")
 	  __RelDir        := "\spool\"  

 	  __RelDir   := "C:\TEMP\"   
 	  _cEmail    := 'harald@automatech.com.br'     
 	  cEmaTransp := 'harald@automatech.com.br'     
 	  
 	  U_PrtNfeSef(StrZero(Val(cFil),6), MV_PAR01, MV_PAR01, oDanfe, oSetup, cFilePrint, .t., _cEmail, cXML, cEmaTransp, .f.)
	
   EndIf

   // Retorno Numeração Anterior

   DbSelectArea("SX1")
   DbSetOrder(1)

   //Altera valor do MV_PAR01
   If DbSeek("NFSIGW    "+"01")
      If RecLock("SX1",.F.)
         X1_CNT01 := xMV_PAR01
         MsUnLock()
      EndIf
   EndIf

   //Altera valor do MV_PAR02
   If DbSeek("NFSIGW    "+"02")
      If RecLock("SX1",.F.)
         X1_CNT01 := xMV_PAR02
         MsUnLock()
      EndIf
   EndIf

   //Altera valor do MV_PAR03
   If DbSeek("NFSIGW    "+"03")
      If RecLock("SX1",.F.)
         X1_CNT01 := xMV_PAR03
         MsUnLock()
      EndIf
   EndIf

// RestArea(_aAreaSX1)

Return


/*
SELECT DISTINCT F2_DOC,
       F2_SERIE  , 
       F2_CLIENTE, 
 	   F2_LOJA   , 
 	   F2_EMISSAO, 
 	   F2_VALBRUT, 
 	   F2_HORA   , 
	   NFE_ID    , 
	   TIME_NFE  , 
	   DATE_NFE  , 
	   STATUS    , 
	   STATUSMAIL, 
	   SPED.EMAIL, 
	   A1_EMAIL  , 
	   CONVERT(varchar(8000),convert(binary(8000),XML_ERP)) as XML 
  FROM SF2010 AS SF2,
       P11_TSS..SPED050 AS SPED, 
       SC5010 AS SC5,
	   SA1010 AS SA1 
 WHERE F2_CHVNFE        <> ''   
   AND F2_TIPO           = 'N'
   AND F2_SERIE + F2_DOC = NFE_ID
   AND F2_FILIAL         = C5_FILIAL 
   AND F2_DOC            = C5_NOTA   
   AND F2_SERIE          = C5_SERIE  
   AND A1_COD            = F2_CLIENTE
   AND A1_LOJA           = F2_LOJA   
   AND STATUS            = 6  
   AND NFE_PROT         <> '' 
   AND F2_DOC            = '086288'
   AND F2_SERIE          = '1'
   AND F2_FILIAL         = '01'
   AND SF2.D_E_L_E_T_   <> '*'
   AND SPED.D_E_L_E_T_  <> '*'
   AND SC5.D_E_L_E_T_   <> '*'
   AND SA1.D_E_L_E_T_   <> '*'
 ORDER BY F2_EMISSAO DESC 
*/