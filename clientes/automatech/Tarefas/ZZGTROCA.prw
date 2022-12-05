#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ZZGTROCA.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/08/2012                                                          *
// Objetivo..: Programa que grava as observações da tabela syp para os campos memo *
// Parâmetros: Sem Parâmetros                                                      *
//**********************************************************************************

User Function ZZGTROCA()

   Local cSql       := ""
   Local cDescricao := ""
   Local cNota      := ""
   Local cSolicita  := ""

   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_DES2  ,"
   cSql += "       ZZG_NOT2  ,"
   cSql += "       ZZG_SOL2   "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

   T_TAREFA->( DbGoTop() )
   
   WHILE !T_TAREFA->( EOF() )
      
      // Pesquisa as observações do campo ZZG_DES2
      If Select("T_TEXTO") > 0
         T_TEXTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT YP_TEXTO"
      cSql += "  FROM " + RetSqlName("SYP")
      cSql += " WHERE YP_CHAVE   = '" + Alltrim(T_TAREFA->ZZG_DES2) + "'"
      cSql += "   AND D_E_L_E_T_ = ''" 

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEXTO", .T., .T. )

      cDescricao := ""
      
      WHILE !T_TEXTO->( EOF() )
         cDescricao := cDescricao + Alltrim(StrTran(T_TEXTO->YP_TEXTO, "\13\10", ""))
         T_TEXTO->( DbSkip() )
      ENDDO   

      // Pesquisa as observações do campo ZZG_NOT2
      If Select("T_TEXTO") > 0
         T_TEXTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT YP_TEXTO"
      cSql += "  FROM " + RetSqlName("SYP")
      cSql += " WHERE YP_CHAVE   = '" + Alltrim(T_TAREFA->ZZG_NOT2) + "'"
      cSql += "   AND D_E_L_E_T_ = ''" 

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEXTO", .T., .T. )

      cNota := ""
      
      WHILE !T_TEXTO->( EOF() )
         cNota := cNota + Alltrim(StrTran(T_TEXTO->YP_TEXTO, "\13\10", ""))
         T_TEXTO->( DbSkip() )
      ENDDO   

      // Pesquisa as observações do campo ZZG_SOL2
      If Select("T_TEXTO") > 0
         T_TEXTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT YP_TEXTO"
      cSql += "  FROM " + RetSqlName("SYP")
      cSql += " WHERE YP_CHAVE   = '" + Alltrim(T_TAREFA->ZZG_SOL2) + "'"
      cSql += "   AND D_E_L_E_T_ = ''" 

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TEXTO", .T., .T. )

      cSolicita := ""
      
      WHILE !T_TEXTO->( EOF() )
         cSolicita := cSolicita + Alltrim(StrTran(T_TEXTO->YP_TEXTO, "\13\10", ""))
         T_TEXTO->( DbSkip() )
      ENDDO   

      // Atualiza o conteúdo dos campos memo nos devido campos
      DbSelectArea("ZZG")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZG") + T_TAREFA->ZZG_CODI)
         RecLock("ZZG",.F.)
         ZZG_DES1 := cDescricao
         ZZG_NOT1 := cNota
         ZZG_SOL1 := cSolicita
      Endif
      
      T_TAREFA->( DbSkip() )
      
   ENDDO         
   
Return .t.