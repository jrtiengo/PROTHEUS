#include "jpeg.ch"    
#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "TOTVS.CH"
#include "fileio.ch"
#include "TBICONN.ch" 

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: AUTOM503.PRW                                                          *
// Parâmetros: Nenhum                                                                *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                      *
// --------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 12/09/2016                                                            *
// Objetivo..: Programa que correge o código da loja das tabelas SCJ e SCK           *
//************************************************************************************

User Function AUTOM503()

   Local nLidos    := 0
   Local nTamArq   := 0
   Local nContar   := 0
   Local cConteudo := 0                     
   Local cCaminho  := "D:\PEDIDO_ATE.CSV"
   Local aBrowse   := {}

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + ";"
          aAdd( aBrowse,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    
           
   a := 1


Return(.T.)











// Função que corrige problemas do orçamento da proposta comercial
Static Function Suspenso_hhl()


   Local cSql    := ""
   Local nContar := 0
                                                                       
   If Select("T_PROPOSTA") <> 0
      T_PROPOSTA->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ADY_FILIAL,
   cSql += "       ADY_PROPOS,
   cSql += "       ADY_OPORTU,
   cSql += "       ADY_CODIGO,
   cSql += " 	   ADY_LOJA
   cSql += "  FROM " + RetSqlName("ADY")
   cSql += " WHERE D_E_L_E_T_ = ''"  

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

   T_PROPOSTA->( DbGoTop() )
   
   WHILE !T_PROPOSTA->( EOF() )
                           
      // Atualiza o código do cliente na tabela SCJ
      cSql := ""
      cSql := "UPDATE "
      cSql += "       " + RetSqlName("SCJ")
      cSql += "   SET "
      cSql += "       CJ_LOJA    = '" + Alltrim(T_PROPOSTA->ADY_LOJA)    + "', "
      cSql += "       CJ_LOJAENT = '" + Alltrim(T_PROPOSTA->ADY_LOJA)    + "'  "
      cSql += " WHERE CJ_FILIAL  = '" + Alltrim(T_PROPOSTA->ADY_FILIAL)  + "'"
      cSql += "   AND CJ_PROPOST = '" + Alltrim(T_PROPOSTA->ADY_PROPOST) + "'"
      cSql += "   AND CJ_NROPOR  = '" + Alltrim(T_PROPOSTA->ADY_OPORTU)  + "'"

      lResult := TCSQLEXEC(cSql)

      // Atualiza o código do cliente na tabela SCK
      cSql := ""
      cSql := "UPDATE "
      cSql += "       " + RetSqlName("SCK")
      cSql += "   SET CK_LOJA    = '" + Alltrim(T_PROPOSTA->ADY_LOJA)    + "'"
      cSql += " WHERE CK_FILIAL  = '" + Alltrim(T_PROPOSTA->ADY_FILIAL)  + "'"
      cSql += "   AND CK_PROPOST = '" + Alltrim(T_PROPOSTA->ADY_PROPOST) + "'"

      lResult := TCSQLEXEC(cSql)

      T_PROPOSTA->( DbSkip() )

   ENDDO

Return(.T.)