#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM146.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/12/2012                                                          *
// Objetivo..: Programa que atualiza o teleefone Comercial na tela de contatos de  *
//             clientes para elaboração da lista de cobrança.                      *
//             Acerta somente comntatos sem telefone comercial informado.          *
// Parãmetros: < Sem Parâmetros >                                                  *
//**********************************************************************************

User Function AUTOM146()

   Local lChumba     := .F.

   Private cSemTel   := ""

   Private lSemTelef := .F.
   Private lAtualiza := .F.

   Private oSemTel
   Private oSemTelef
   Private oAtualiza

   Private oDlg

   Private nMeter1	 := 0
   Private oMeter1

   U_AUTOM628("AUTOM146")

   DEFINE MSDIALOG oDlg TITLE "Telefone Contato de Clientes" FROM C(178),C(181) TO C(341),C(455) PIXEL

   @ C(021),C(039) Say "contatos sem a informação de telefone" Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(005),C(005) CheckBox oSemTelef Var lSemTelef Prompt "Verifica contatos sem a informação de Telefone" Size C(125),C(008) PIXEL OF oDlg

   @ C(019),C(015) MsGet oSemTel Var cSemTel When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(036),C(005) CheckBox oAtualiza Var lAtualiza Prompt "Atualizar telefone dos contatos" Size C(083),C(008) PIXEL OF oDlg

   @ C(049),C(015) METER oMeter1 VAR nMeter1 Size C(113),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(064),C(032) Button "Processar" Size C(037),C(012) PIXEL OF oDlg ACTION( DIS_PARA() )
   @ C(064),C(071) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa contatos sem telefone conforme indicação de pesquisa
Static Function Dis_para()

   Local nContar := 0

   If !lSemTelef .And. !lAtualiza 
      MsgAlert("Necessário indicar um tipo de pesquisa a ser realizada.")
      Return .T.
   Endif      

   If lSemTelef .And. lAtualiza 
      MsgAlert("Indique somente um tipo de pesquisa a ser realizada.")
      Return .T.
   Endif
   
   // Pesquisa quantos contatos estão sem a informação do telefone comercial em seu cadastro
   If lSemTelef

      If Select("T_QUANTOS") > 0
         T_QUANTOS->( dbCloseArea() )
      EndIf

      cSql := "SELECT COUNT(*) AS QTD "
      cSql += "  FROM " + RetSqlName("SU5") + " A "
      cSql += " WHERE A.U5_FCOM1   = '' "
      cSql += "   AND A.D_E_L_E_T_ = '' "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QUANTOS", .T., .T. )

      If T_QUANTOS->( EOF() )
         cSemTel := "0"
      Else
         cSemTel := Alltrim(Str(T_QUANTOS->QTD))
      Endif

      oSemTel:Refresh()
      
   Endif   

   // Atualiza o cadastro de telefonees do contatos dos clientes
   If lAtualiza

      If Select("T_ATUALIZA") > 0
         T_ATUALIZA->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.U5_FILIAL ,"
      cSql += "       A.U5_CODCONT,"
      cSql += "       A.U5_CONTAT ,"
      cSql += "       A.U5_FCOM1  ,"
      cSql += "       A.R_E_C_N_O_ AS NREGISTRO, "
      cSql += "       B.AGB_TELEFO "
      cSql += "  FROM " + RetSqlName("SU5") + " A, "
      cSql += "       " + RetSqlName("AGB") + " B  "
      cSql += " WHERE A.U5_FCOM1   = '' "
      cSql += "   AND A.D_E_L_E_T_ = '' "
      cSql += "   AND A.U5_CODCONT = B.AGB_CODENT"
      cSql += "   AND B.AGB_TIPO   = '1'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATUALIZA", .T., .T. )
   
      T_ATUALIZA->( DbGoTop() )
      
      WHILE !T_ATUALIZA->( EOF() )

         nContar += 1

         oMeter1:Refresh()
         oMeter1:Set(nContar)
         
         cSql := ""
         cSql := "UPDATE " + RetSqlName("SU5")
         cSql += "   SET "
         cSql += "         U5_FCOM1 = '" + Alltrim(T_ATUALIZA->AGB_TELEFO)     + "'"
         cSql += " WHERE R_E_C_N_O_ = '" + Alltrim(STR(T_ATUALIZA->nRegistro)) + "'"      

         lResult := TCSQLEXEC(cSql)

         If lResult < 0
            Return MsgStop("Erro durante a atualização do Cadastro de Contatos de Clientes: " + TCSQLError())
         EndIf

         T_ATUALIZA->( DbSkip() )
         
      ENDDO

      oMeter1:Refresh()
      oMeter1:Set(100)

      MsgAlert("Atualização executada com sucesso.")
      
      oDlg:End()
      
   Endif

Return(.T.)