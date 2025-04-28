#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWBrowse.ch'
#Include 'FWMVCDEF.CH'

#Define MB_OK              0
#Define MB_OKCANCEL        1
#Define MB_YESNO           4
#Define MB_ICONHAND        16
#Define MB_ICONQUESTION    32
#Define MB_ICONEXCLAMATION 48
#Define MB_ICONASTERISK    64

#Define IDOK			    1
#Define IDCANCEL		    2
#Define IDYES			    6
#Define IDNO			    7

#Define ENTER Chr(13) + Chr(10)
#Define cTitApp "Carga Base Campex"

//=======================================================================================================================================
//=======================================================================================================================================
// Autor: Marcio Martins Pereira - 25/01/2023
//   Uso: Login para execução
//=======================================================================================================================================
//=======================================================================================================================================

User Function MngExecuta()

    Local cUsuario   := Space(030)
    Local cPass      := Space(030)
    Local cEmpresa   := Space(004)
    Local cFilAtu    := Space(008)
    Local oLogin     := Nil
    Local oLyr01     := Nil
    Local oW1        := Nil
    Local oW2        := Nil
    Local oUsr       := Nil
    Local oPas       := Nil
    Local oEmp       := Nil
    Local oFil       := Nil
    Local oBtnOk     := Nil
    Local oBtnCn     := Nil
    Local lOk        := .F.
    Local lRpc       := .F.
    Private aScreenRes := GetScreenRes()
    Private oDlg       := Nil
    Private oOrigem
    Private cOrigem    := Space(100)
    Private cTempTbl := ""
    Private oFiltro
    Private cFiltro  := "*.*                 "
	Private lInverte := .F.
	Private cMark   := ""
	Private oMark//Cria um arquivo de Apoio
	Private aObjSub   	:= {}
	Private aPosSub    	:= {}
    Private oSay 
    Private cMensagem   := ""
    Private oMensagem 

    oLogin  := tDialog():New(0, 0, 400, 300, "Login", , , , , CLR_WHITE, CLR_GRAY, , , .T., , , , , , .F.)
    oLyr01  := FwLayer():New()
    oLyr01:Init(oLogin, .F.)
    oLyr01:addCollumn("C_1", 100)
    oLyr01:addWindow("C_1", "W1", "Usuário / Senha", 070, .F., .F.,/*BACTION*/,/*CIDLINE*/,/*BGOTFOCUS*/)
    oLyr01:addWindow("C_1", "W2", "Commandos", 030, .F., .F.,/*BACTION*/,/*CIDLINE*/,/*BGOTFOCUS*/)
    oW1     := oLyr01:GetWinPanel("C_1","W1")
    oW2     := oLyr01:GetWinPanel("C_1","W2")
    oUsr    := tGet():New(005, 005, {|U| If(pCount() > 0, cUsuario  := U, cUsuario)}, oW1, 150, 010,, /*{||}*/, CLR_BLACK,,,,,.T.,,,{||.T.},,,,,,, "cUsuario",,,, .T., .F.,, "Usuário", 1)
    oPas    := tGet():New(025, 005, {|U| If(pCount() > 0, cPass     := U, cPass)}   , oW1, 150, 010,, /*{||}*/, CLR_BLACK,,,,,.T.,,,{||.T.},,,,,.T.,, "cPass",,,, .T., .F.,, "Senha", 1)
    oEmp    := tGet():New(050, 005, {|U| If(pCount() > 0, cEmpresa  := U, cEmpresa)}, oW1, 050, 010,, /*{||}*/, CLR_BLACK,,,,,.T.,,,{||.T.},,,,,,, "cEmpresa",,,, .T., .F.,, "Empresa", 1)
    oFil    := tGet():New(075, 005, {|U| If(pCount() > 0, cFilAtu   := U, cFilAtu)} , oW1, 050, 010,, /*{||}*/, CLR_BLACK,,,,,.T.,,,{||.T.},,,,,,, "cFilAtu",,,, .T., .F.,, "Filial", 1)
    oBtnOk  := tButton():New(010, 010, "Ok"     , oW2, {|| lOk := .T., oLogin:End()}, 050, 010,,,, .T.)
    oBtnCn  := tButton():New(010, 060, "Cancel" , oW2, {|| lOk := .F., oLogin:End()}, 050, 010,,,, .T.)

    oLogin:Center(.T.)
    oLogin:Activate()

    If !lOk
        Aviso(cTitApp, "Cancelamento realizado pelo usuário!", {"Ok"}, 1)
    Else
        RpcClearEnv()
        RpcSetType(3)
        lRpc := RpcSetEnv(AllTrim(cEmpresa), AllTrim(cFilAtu),,,, GetEnvServer(), {"SA1"})
        If !lRpc
            Alert("Não Conectou!")
            Return
        EndIf
        MngProcessa()
        Aviso(cTitApp, "Concluído!", {"Ok"}, 1)
        RpcClearEnv()
    EndIf

Return

//=======================================================================================================================================
//=======================================================================================================================================
// Autor: Marcio Martins Pereira - 25/01/2023
//   Uso: Rotina que será executada
//=======================================================================================================================================
//=======================================================================================================================================

Static Function MngProcessa()

Private cTabela    := "TABFOLDER"
Private cTabDoc    := "TABDOC"

IF !Select (cTabela)
    u_EzTabFolder(cTabela)
Endif
IF !Select (cTabDoc)
    u_EzTabDoc(cTabDoc)
Endif




Return
