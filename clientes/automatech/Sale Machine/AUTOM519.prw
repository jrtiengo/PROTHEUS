#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM519.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 07/12/2016                                                              ##
// Objetivo..: Programa que gera registros na Tabela ZTP010 com os produtos que foram  ##
//             marcados na tabela SD1 e SD3.                                           ##
//             Sempre que houver um lançamento de uma nota fiscal de entrada ou um a-  ##
//             juste de estoque (Movimentações Internas 2) referente a entrada, o sis- ##
//             tema, no final da gravação destes processo, marcará os produtos que de- ##
//             verão sofrer rec[alculo do custo na tabela ZTP010.                      ##
//             IMPORTANTE:                                                             ##
//             Alterarções realizadas neste programa, devem ser replicadas para o pro- ##
//             grama AUTOM506  e vice e versa.                                         ##
// ######################################################################################
// Regra para geração do arquivo de log de cálculo                                     ##
// ----------------------------------------------------------------------------------- ##
// Nome do arquivo de log: 0_SALE_CUSTO.TXT                                            ##
// Onde: 0 -> Statsu do Cálculo conforme descrição abaixo:                             ##
//                                                                                     ##
//       0 = Processamento realizado com sucesso                                       ##
//       1 = Idica falta de parametrização geral do Sale Machine                       ##
//       2 = Filial da proposta comercial modelo não definida                          ## 
//       3 = Proposta comercial modelo não definida                                    ##
//       4 = Cliente modelo não definido para cálculo                                  ##
//       5 = Empresas/Filiais não definidas para cálculo                               ##
//       6 = Não foram encontrados produtos para cálculo                               ##
//       7 = Problema encontrado na abertura de registros por Estados                  ##
//       8 = Problema encontrado na pesquisa de TES dos produtos                       ##
//       9 = Problema encontrado no cálculo dos Custo + DIFAL dos produtos por UF      ##
//                                                                                     ##
// Na entrada da execução deste programa, primeiramente o programa verificará o Status ##
// do arquivo de log gravado no caminho especificado. Caso o status for um  dos status ##
// acima com exceção do status 0 e 6, o Sistema enviará um work flow para o  enderecço ##
// harald@automatech.com;br alertando de possíveis falhas nos cálculos deste programa. ##
// ######################################################################################

User Function AUTOM519()

   Local cSql           := ""
   Local kFilial        := ""
   Local kProposta      := ""
   Local kCliente       := ""
   Local kLojaCli       := ""
   Local kRevisao       := "01"
   Local nContar        := 0
   Local xTotalProposta := 0
   Local nTaxaD         := 0
   Local nFreteProposta := 0
   Local nTProduto      := 0
   Local nContar        := 0
   Local cString        := ""
   Local lPertence      := .F.
   Local nPertence      := 0

   Local aEstados       := {}
   Local aCabecalho     := {}
   Local aProdutos      := {}
   Local aCalcular      := {}

   Local cTxPIS         := GetMv("MV_TXPIS")
   Local cTxCofins      := GetMv("MV_TXCOFIN")

   // ##############################################################
   // Calcula o novo custo levando em consideração o PIS e COFINS ##
   // ##############################################################
   If (Select( "T_TABELA" ) != 0 )
      T_TABELA->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTP.ZTP_FILIAL,"	
   cSql += "       ZTP.ZTP_EMPR	 ,"
   cSql += "       ZTP.ZTP_PROD	 ,"
   cSql += "       ZTP.ZTP_NOME	 ,"
   cSql += "       ZTP.ZTP_PART	 ,"
   cSql += "       ZTP.ZTP_ESTA	 ,"
   cSql += "       ZTP.ZTP_CUS1	 ,"
   cSql += "       ZTP.ZTP_CUS2	 ,"
   cSql += "       ZTP.ZTP_DATA	 ,"
   cSql += "       ZTP.ZTP_HORA	 ,"
   cSql += "       ZTP.ZTP_USUA	 ,"
   cSql += "       ZTP.ZTP_PARA	 ,"
   cSql += "       ZTP.ZTP_DIFA1 ,"
   cSql += "       ZTP.ZTP_DIFA2 ,"
   cSql += "       ZTP.ZTP_TES1	 ,"
   cSql += "       ZTP.ZTP_TES2	 ,"
   cSql += "       ZTP.ZTP_PFIL	 ,"
   cSql += "       ZTP.ZTP_PROP	 ,"
   cSql += "       ZTP.ZTP_CLIE	 ,"
   cSql += "       ZTP.ZTP_CNPJ	 ,"
   cSql += "       ZTP.ZTP_LOJA	 ,"
   cSql += "       ZTP.ZTP_INSC	 ,"
   cSql += "       ZTP.ZTP_TRIB1 ,"
   cSql += "       ZTP.ZTP_TRIB2 ,"
   cSql += "       ZTP.ZTP_CONT1 ,"
   cSql += "       ZTP.ZTP_CONT2 ,"
   cSql += "       ZTP.ZTP_DETA1 ,"
   cSql += "       ZTP.ZTP_DETA2 ,"
   cSql += "       ZTP.ZTP_TOPE1 ,"
   cSql += "       ZTP.ZTP_TOPE2 ,"
   cSql += "       ZTP.ZTP_MUNI   "
   cSql += "  FROM " + RetSqlName("ZTP") + " ZTP, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE SB1.B1_COD     = ZTP.ZTP_PROD"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TABELA",.T.,.T.)

   T_TABELA->( DbGoTop() )
   
   WHILE !T_TABELA->( EOF() )

      // ######################################################
      // Atuaiza o % de Pis e Cofins e Cálcula o custo total ##
      // ######################################################
      dbSelectArea("ZTP")
      dbSetOrder(1)
      If dbSeek( T_TABELA->ZTP_EMPR + T_TABELA->ZTP_FILIAL + T_TABELA->ZTP_PROD + T_TABELA->ZTP_ESTA )
         RecLock("ZTP",.F.)
         ZTP->ZTP_PIS1  := cTxPis
         ZTP->ZTP_COF1  := cTxCofins
         ZTP->ZTP_PIS2  := cTxPis
         ZTP->ZTP_COF2  := cTxCofins

         // #####################################
         // Calcula o novo custo para ZTP_CUS1 ##
         // #####################################
         cCustoIni01 := 0
         cCustoTot01 := 0
         cCustoIni01 := ZTP->ZTP_CUS1 - ZTP->ZTP_DIFA1
         cCustoTot01 := ROUND(((cCustoIni01 / ( 1 - ( (cTxPIS / 100) + (cTxCofins / 100) ))) + ZTP->ZTP_DIFA1),2)

         // #####################################
         // Calcula o novo custo para ZTP_CUS2 ##
         // #####################################
         cCustoIni02 := 0
         cCustoTot02 := 0
         cCustoIni02 := ZTP->ZTP_CUS2 - ZTP->ZTP_DIFA2
         cCustoTot02 := ROUND(((cCustoIni02 / ( 1 - ( (cTxPIS / 100) + (cTxCofins / 100) ))) + ZTP->ZTP_DIFA2),2)

         ZTP->ZTP_CUS1 := cCustoTot01
         ZTP->ZTP_CUS2 := cCustoTot02

         MsUnLock()              

      Endif

      T_TABELA->( DbSkip() )
                  
   Enddo

Return(.T.)