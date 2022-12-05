#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM233.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/05/2014                                                          *
// Objetivo..: Programa que valida o CFOP da Proposta Comercial, Call Center e do  *
//             Pedido de Venda.                                                    *
// Parâmetros: < __Chamado > - Indica se onde foi chamado o processo.              * 
//                             PV - Pedido de Venda                                *
//                             PC - Proposta Comercial                             *
//                             CC - Call Center                                    * 
//             < __Operaca^> - Tipo de Operação informada (Usado no retorno)       *
//**********************************************************************************

User Function AUTOM233( __Chamado, __Operacao )

   Local nPosicao  := 0
   Local __Cfop    := ""
   Local lCfop     := .F.
   Local cCFOP     := ""
   Local nVenda    := 0
   Local nRemessa  := 0
   Local sVenda    := ""
   Local sRemessa  := ""
   Local nRegistro := n
   Local __Tes     := 0
   Local __Ope     := 0

   U_AUTOM628("AUTOM233")

   // Consiste o CFOP conforme paràmetro passado
   // Tarefa 000804 - Solicitante: Tattiane - Controladoria
       
   // Pesquisa os Cfops para carregas as variáveis
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CFPV)) AS VENDA  ," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZ4_CFPR)) AS REMESSA "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      sVenda   := T_PARAMETROS->VENDA
      sRemessa := T_PARAMETROS->REMESSA
   Endif

   If Empty(Alltrim(sVenda) + Alltrim(sRemessa))
      Return __Operacao
   Endif
      
   // Localiza a posição do Campo C6_CF
   For nPosicao = 1 to Len(aHeader)
       Do Case
          Case __Chamado == "PV"       
               If Alltrim(aHeader[nPosicao,02]) == "C6_OPER"
                  __Ope := nPosicao
               Endif
               If Alltrim(aHeader[nPosicao,02]) == "C6_TES"
                  __Tes := nPosicao
               Endif
          Case __Chamado == "PC"       
               If Alltrim(aHeader[nPosicao,02]) == "ADZ_OPER"
                  __Ope := nPosicao
               Endif
               If Alltrim(aHeader[nPosicao,02]) == "ADZ_TES"
                  __Tes := nPosicao
               Endif
          Case __Chamado == "CC"       
               If Alltrim(aHeader[nPosicao,02]) == "UB_OPER"
                  __Ope := nPosicao
               Endif
               If Alltrim(aHeader[nPosicao,02]) == "UB_TES"
                  __Tes := nPosicao
               Endif
       EndCase        
   Next nPosicao

   lCfop    := .F.
   nVenda   := 0
   nRemessa := 0

   For nPosicao = 1 to Len(aCols)

       // Posiciona na Tabela de TES para capturar o CFOP para verificação
       cCFOP := Posicione("SF4", 1, xFilial("SF4") + aCols[nPosicao,__TES], "F4_CF")          

       If U_P_OCCURS(sVenda, Alltrim(cCFOP), 1) == 1
          nVenda := 1
          Loop
       Endif
 
       If U_P_OCCURS(sRemessa, Alltrim(cCFOP), 1) == 1
          nRemessa := 1
          Loop
       Endif

   Next nPosicao

   If nVenda == 0 .And. nRemessa == 0
      n := nRegistro
      aCols[n, __TES] := "   "
      Return "  "
   Endif
               
   If nVenda == 1 .And. nRemessa == 0
      n := nRegistro
      Return __Operacao
   Endif

   If nVenda == 0 .And. nRemessa == 1
      n := nRegistro
      Return __Operacao
   Endif

   If nVenda == 1 .And. nRemessa == 1
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Tipo de Operação não poderá ser utilizada em função de ter sido" + chr(13) + chr(10) + "informados ítens de venda juntamente com ítens de remessa." + chr(13) + chr(10) + "Qualquer dúvida entre em contato com a Controladoria.")
      n := nRegistro
      aCols[n, __TES] := "   "
      Return "  "
   Endif

Return __Operacao