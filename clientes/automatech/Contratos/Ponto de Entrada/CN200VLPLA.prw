#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: CN200VLPLA.PRW                                                      *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/01/2013                                                          *
// Objetivo..: Ponto de Entrada disparado no momento da gravação das planilhas de  *
//             contratos (Módulo 69). São verificados os  seguintes  pontos neste  *
//             ponto de entrada.
//             
//             1º) Verifica se todos os produtos que são controlados por número de *
//                 série tem seus números de séries informados.                    *
//             2º) Verifica se o número de série informado pertence ao produto in- *
//                 formado.                                                        *
//             3º) Verifica se o número de série já está contido em uma  base ins- *
//                 talada. Se não estiver, não grava a planilha.                   * 
//**********************************************************************************

User Function CN200VLPLA()
                                   
   Local ExpO1    := paramixb[1] // Nome do objeto da tela (Browse)
   Local ExpA1    := paramixb[2]
   Local ExpA2    := paramixb[3]
   Local ExpN1    := paramixb[4]
   Local ExpL1    := paramixb[5] // .T./.F., indica se array tem conteúdo
   Local ExpL2    := .T.
   Local nContar  := 0
   Local cSql     := ""
   Local _Produto := ""
   Local _Serie   := "" 
   Local cOK      := .T.
   
   If ExpL1
   
      For nContar = 1 to Len(ExpO1:aCols)
      
          If ExpO1:aCols[nContar, (Len(ExpO1:aHeader) + 1)]
             Loop
          Endif   

          _Produto := ExpO1:aCols[nContar,2]
          _Serie   := ExpO1:aCols[nContar,5]
      
          // Verifica se o produto é controlado por nº de série.
          If Select("T_LOCALIZA") > 0
             T_LOCALIZA->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT B1_COD    ,"
          cSql += "       B1_DESC   ,"
          cSql += "       B1_LOCALIZ "
          cSql += "  FROM " + RetSqlName("SB1")
          cSql += " WHERE B1_COD     = '" + Alltrim(_Produto) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOCALIZA", .T., .T. )

          If T_LOCALIZA->B1_LOCALIZ <> "S"
//           MsgAlert("Produto [" + Alltrim(T_LOCALIZA->B1_COD) + " - " + Alltrim(T_LOCALIZA->B1_DESC) + "] informado não é controlado por nº de série. Informação desnecessária.")
//           cOK := .F.
             cOK := .T.
             Exit
          Endif

          If Empty(Alltrim(_Serie))
             MsgAlert("Produto [" + Alltrim(T_LOCALIZA->B1_COD) + " - " + Alltrim(T_LOCALIZA->B1_DESC) + "] controlado por nº de série. Necessário informar nº de série.")
             cOK := .F.
             Exit
          Endif

          // Verifica se o nº de série informado pertence ao produto informado
          If Select("T_PERTENCE") > 0
             T_PERTENCE->( dbCloseArea() )
          EndIf

          csql := ""
          cSql := "SELECT DB_NUMSERI"
          cSql += "  FROM " + RetSqlName("SDB") 
          cSql += " WHERE DB_PRODUTO = '" + Alltrim(_Produto) + "'"
          cSql += "   AND DB_NUMSERI = '" + Alltrim(_Serie)   + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PERTENCE", .T., .T. )

          If T_PERTENCE->( EOF() )
             MsgAlert("Nº de série [" + Alltrim(_Serie) + "] não pertence ao produto [" + Alltrim(T_LOCALIZA->B1_COD) + " - " + Alltrim(T_LOCALIZA->B1_DESC) + "]. Verifique!")
             cOK := .F.
             Exit
          Endif

          // Verifica se nº de série possui base instalada
          If Select("T_BASE") > 0
             T_BASE->( dbCloseArea() )
          EndIf

          cSql := "SELECT AA3_CODPRO,"
          cSql += "       AA3_CODCLI,"
          cSql += "       AA3_LOJA  ,"
          cSql += "       AA3_NUMSER "
          cSql += "  FROM " + RetSqlName("AA3")
          cSql += " WHERE AA3_CODPRO = '" + Alltrim(_Produto)      + "'"
          cSql += "   AND AA3_NUMSER = '" + Alltrim(_Serie)        + "'"
          cSql += "   AND AA3_CODCLI = '" + Alltrim(M->CNA_CLIENT) + "'"
          cSql += "   AND AA3_LOJA   = '" + Alltrim(M->CNA_LOJACL) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BASE", .T., .T. )

          If T_BASE->( EOF() )
             MsgAlert("Nº de série [" + Alltrim(_Serie) + "] inexistente na Base Instalada do Filed Service. Verifique!")
             cOK := .F.
             Exit
          Endif

      Next nContar

   Endif   

Return cOk