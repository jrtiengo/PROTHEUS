#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM143.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/11/2012                                                          *
// Objetivo..: Programa que atualiza o e-mail do fornecedor atrtavés da leitura do *
//             do e-mail do cliente.                                               *
//**********************************************************************************

User Function AUTOM143()

   Private oDlg

   Private nMeter1 := 0
   Private oMeter1

   U_AUTOM628("AUTOM143")

   DEFINE MSDIALOG oDlg TITLE "Atualiza campo e-mail de Fornecedores" FROM C(178),C(181) TO C(333),C(657) PIXEL

   @ C(005),C(005) Say "Este procedimento tem por objetivo de preencher o campo e-mail do Cadastro de Fornecedores" Size C(227),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(014),C(005) Say "com o e-mail constante no Cadastro de Clientes."                                            Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(005) Say "Somente serão atualizados os Fornecedores que estiverem com o campo e-mail em branco."      Size C(218),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(040),C(052) METER oMeter1 VAR nMeter1 Size C(124),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(058),C(084) Button "OK"     Size C(037),C(012) PIXEL OF oDlg ACTION( ATU_EMAIL())
   @ C(058),C(123) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return .T.

// Função que atualiza o e-mail do fornecedor
Static Function ATU_EMAIL()

   Local cSql   := ""
   Local nRegua := 0
   
   // Pesquisa os fornecedores com e-mail inconsistentes
   If Select("T_EMAIL") > 0
      T_EMAIL->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT A.A1_NOME   ,"                 + chr(13)
   cSql += "       A.A1_CGC    ,"                 + chr(13)
   cSql += "       B.A2_NOME   ,"                 + chr(13)
   cSql += "       B.A2_CGC    ,"                 + chr(13)
   cSql += "       A.A1_EMAIL  ,"                 + chr(13)
   cSql += "       B.A2_EMAIL  ,"                 + chr(13)
   cSql += "       B.A2_FILIAL ,"                 + chr(13)
   cSql += "       B.A2_COD    ,"                 + chr(13)
   cSql += "       B.A2_LOJA    "                 + chr(13)
   cSql += "  FROM " + RetSqlName("SA1") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SA2") + " B  " + chr(13)
   cSql += " WHERE A.A1_CGC = B.A2_CGC"           + chr(13)
   cSql += "   AND A.A1_EMAIL <> B.A2_EMAIL"      + chr(13)
   cSql += "   AND A.A1_EMAIL LIKE '%@%'"         + chr(13)
   cSql += "   AND A.A1_EMAIL <> '@'"             + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"             + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMAIL", .T., .T. )
   
   If T_EMAIL->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif

   // Atualiza os e-mail dos clientes para o cadastro de fornecedores
   WHILE !T_EMAIL->( EOF() )

      nRegua += 1
   
      oMeter1:Refresh()
      oMeter1:Set(nRegua)
      oMeter1:SetTotal(100)


      DbSelectArea("SA2")
      DbSetOrder(1)
      If DbSeek(xfilial("SA2") + Alltrim(T_EMAIL->A2_COD) + Alltrim(T_EMAIL->A2_LOJA))
         RecLock("SA2",.F.)
         A2_EMAIL := T_EMAIL->A1_EMAIL
         MsUnLock()              
      Endif
      
      T_EMAIL->( DbSkip() )
      
   ENDDO   

   MsgAlert("Atualização efetuada com sucesso!")
   
Return .T.