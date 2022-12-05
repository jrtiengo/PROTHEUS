#INCLUDE "PROTHEUS.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM535.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 01/02/2017                                                          ##
// Objetivo..: Programa que grava peso, comprimento, altura e largura dos produtos ##
//             Suprimentos.                                                        ##
// ##################################################################################

User Function AUTOM535()

   Local cSql        := ""
   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local aProdutos   := {}
   Local nSepara     := 0
   Local j           := ""
   Local aDados      := {} 

   Private nPosi01   := 0
   Private nPosi02   := 0

   Private lVolta    := .F.
   Private aConsulta := {}
   Private aNaoFez   := {}

   private lMsErroAuto := .F. 

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT B1_COD ,"
   cSql += "       B1_PESC,"
   cSql += "	   B1_COMP,"
   cSql += "	   B1_ALTU,"
   cSql += "	   B1_LARG "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE LEN(LTRIM(RTRIM(B1_COD))) > 6"
   cSql += "   AND B1_PESC    = 0"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )

   	   DbSelectArea("SB1")
  	   DbSetOrder(1)
	   If DbSeek(xfilial("SB1") + T_PRODUTOS->B1_COD)

          RecLock("SB1",.F.)
          
          If Substr(T_PRODUTOS->B1_COD,10,01) == "2"
             SB1->B1_PESC    := 0.546
             SB1->B1_ALTU    := 10
             SB1->B1_LARG    := 8
             SB1->B1_COMP    := 8
          Endif
       
          If Substr(T_PRODUTOS->B1_COD,10,01) == "4"
             SB1->B1_PESC    := 1.400
             SB1->B1_ALTU    := 10
             SB1->B1_LARG    := 14
             SB1->B1_COMP    := 14
          Endif          

          MsUnLock()              

       Endif
       
       T_PRODUTOS->( DbSkip() )
       
    ENDDO

   MsgAlert("Inclusão de produtos realizada com sucesso.")

Return(.T.)