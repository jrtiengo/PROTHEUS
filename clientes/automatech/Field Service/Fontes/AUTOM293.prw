#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM293.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 08/06/2015                                                          * 
// Objetivo..: Programa de Cadastro das Regras de TES para Servi�os                *
//**********************************************************************************

User Function AUTOM293()

   Local cSql      := ""
   
   Local cMemo1	   := ""
   Local oMemo1

   Private aBrowse := {}

   Private oDlg

   // Envia para a fun��o que carrega o array aBrowse
   CargaGridS(1)

   // Desenha a tela para visualiza��o
   DEFINE MSDIALOG oDlg TITLE "Cadastro Regras TES para Servi�os" FROM C(178),C(181) TO C(528),C(703) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(253),C(001) PIXEL OF oDlg

   @ C(159),C(104) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(IncSerRegra())
   @ C(159),C(142) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(ChamaTES("A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]))
   @ C(159),C(181) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(ExcluiGrp(aBrowse[ oBrowse:nAt, 01 ]))
   @ C(159),C(219) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TSBrowse():New(045,005,325,155,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Servi�o'               ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descri��o dos Servi�os',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que chama a tela de manuten��o das TES do servi�o
Static Function ChamaTES(_Operacao, _Servico, _Descricao)

   If Alltrim(_Servico) == ""
      Return(.T.)
   Endif

   U_AUTO293A(_Operacao, _Servico, _Descricao)

Return(.T.)

// Fun��o que permite incluir novo servi�o no cadastro de regras
Static Function IncSerRegra()

   Local cSql     := ""
   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local oMemo1
      
   Private kCodigo  := Space(06)
   Private kServico := Space(40)

   Private oGet1
   Private oGet2

   Private oDlgR

   DEFINE MSDIALOG oDlgR TITLE "Cadastro Regras TES para Servi�os" FROM C(178),C(181) TO C(329),C(590) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(138),C(026) PIXEL NOBORDER OF oDlgR

   @ C(032),C(005) GET oMemo1 Var cMemo1 MEMO Size C(195),C(001) PIXEL OF oDlgR

   @ C(036),C(005) Say "Servi�o" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var kCodigo  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR VALID(ChkServ()) F3("AA5")
   @ C(045),C(042) MsGet oGet2 Var kServico Size C(157),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba

   @ C(058),C(124) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgR
   @ C(058),C(162) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgR ACTION( oDlgR:End() )

   ACTIVATE MSDIALOG oDlgR CENTERED 

Return(.T.)

// Fun��o que pesquisa o servi�o informado/selecionado
Static Function ChkServ()

   If Alltrim(kCodigo) == ""
      kCodigo  := Space(06)
      kServico := Space(40)
      CargaGridS(2)
      Return(.T.)
   Endif

   // Pesquisa o servi�o informado/selecionado
   If Select("T_SERVICO") > 0
      T_SERVICO->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT AA5_CODSER,
   cSql += "       AA5_DESCRI
   cSql += "  FROM " + RetSqlName("AA5")
   cSql += " WHERE AA5_CODSER = '" + Alltrim(kCodigo) + "'"
   cSql += "   AND D_E_L_E_T_ = ''" 
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICO", .T., .T. )
   
   If T_SERVICO->( EOF() )
      MsgAlert("Servi�o inexistente.")
      kCodigo  := Space(06)
      kServico := Space(40)
      CargaGridS(2)
      Return(.T.)
   Else
      kServico := T_SERVICO->AA5_DESCRI
   Endif

   // Verifica se servi�o j� est� cadastrado na tabela de regras de TES para Servi�os
   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZP6_SERV"
   cSql += "  FROM " + RetSqlName("ZP6")
   cSql += " WHERE ZP6_SERV = '" + Alltrim(kCodigo) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

   If !T_JAEXISTE->( EOF() )
      MsgAlert("Servi�o j� cadastrado. Verifique!")
      kCodigo  := Space(06)
      kServico := Space(40)
      CargaGridS(2)
      Return(.T.)
   Endif

   // Inseri o servi�o
   aArea := GetArea()

   dbSelectArea("ZP6")
   RecLock("ZP6",.T.)
   ZP6_FILIAL := ""
   ZP6_SERV   := kCodigo
   ZP6_GRUP   := ""
   ZP6_TES    := ""
   MsUnLock()

   oDlgR:End()

   CargaGridS(2)
   
Return(.T.)

// Fun��o que carrega o grid dos servi�os
Static Function CargaGridS(__Tipo)

   Local cSql := ""

   aBrowse := {}

   // Carrega o grid com os servi�os j� parametrizados
   If Select("T_SERVICOS") > 0
      T_SERVICOS->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT ZP6.ZP6_SERV  ,"
   cSql += "       AA5.AA5_DESCRI "
   cSql += "  FROM " + RetSqlName("ZP6") + " ZP6, "
   cSql += "       " + RetSqlName("AA5") + " AA5  "
   cSql += " WHERE AA5_CODSER     = ZP6.ZP6_SERV"
   cSql += "   AND AA5.D_E_L_E_T_ = ''"
   cSql += " GROUP BY ZP6.ZP6_SERV, AA5.AA5_DESCRI"   
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICOS", .T., .T. )

   T_SERVICOS->( EOF() )
   
   WHILE !T_SERVICOS->( EOF() )
      aAdd(aBrowse, { T_SERVICOS->ZP6_SERV, T_SERVICOS->AA5_DESCRI } )
      T_SERVICOS->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "" } )
   Endif   

   If __Tipo == 1
      Return(.T.)
   Endif
      
   oBrowse:SetArray(aBrowse)
   
Return(.T.)   

// Fun��o que exclui os par�metros das TES por Grupo de Tributa��o
Static Function ExcluiGrp(__Servico)

   Local cSql   := ""
   Local _nErro := 0
   
   If Alltrim(__Servico) == ""
      Return(.T.)
   Endif
   
   If MsgYesNo("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "Confirma a exclus�o da parametriza��o das TES para este servi�o?")
   
      // Elimina todos os lan�amentos do grupo para receber novos valores
      cSql := ""
      cSql := "DELETE"
      cSql += "  FROM " + RetSqlName("ZP6")
      cSql += " WHERE ZP6_SERV = '" + Alltrim(__Servico) + "'"
    
      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif
      
      CargaGridS(2)
      
   Endif
   
Return(.T.)