#INCLUDE "protheus.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "rwmake.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} SOL01CTR

Importador de contratos - SIGAGCT

@author Brito

@since 30/04/2025

/*/

User Function SOL01CTR()

    Local aArea     := FWGetArea()
    Local nAltu     := 150
    Local nLarg     := 300
    Local bImporta  := {|| GerCtr()}
    Local cTitulo   := "ROTINA DE IMPORTAÇÃO - CONTRATOS - SIGAGCT"
    Local oFont     := TFont():New("Arial",,015,,.F.,,,,,.F.,.F.)//Fontes
    Local oDlgAux
    Local oContainer
    Local oSay1

    Private aRetorno := {}
    Private aLogs    := {}

    RPCSetEnv('99', '01')
 
    oDlgAux := FWDialogModal():New()
    oDlgAux:SetEscClose(.T.)
    oDlgAux:SetTitle(cTitulo)
    oDlgAux:SetSize(nAltu, nLarg)
    oDlgAux:EnableFormBar(.T.)
    oDlgAux:CreateDialog()
    oDlgAux:CreateFormBar()
    oDlgAux:addCloseButton(Nil, "Sair")
    oDlgAux:AddButton("Importação", bImporta, "Importação", , .T., .F., .T., )

    oContainer := TPanel():New( ,,, oDlgAux:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    @ 010,005 SAY oSay1 PROMPT "Essa rotina tem como objetivo realizar a inclusão de contratos, com base em planilhas CSV (tabelas CNC/CN9/CNA/CNB/CNZ/CNF). " SIZE 280,180 FONT oFont COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL
    @ 030,005 SAY oSay1 PROMPT 'Clique no botão "Arquivo" para selcionar o local onde constam os arquivos com as informações dos contratos a serem criados.' SIZE 280,180 FONT oFont COLORS CLR_BLACK,CLR_WHITE OF oContainer HTML PIXEL
 
    oDlgAux:Activate()
 
    FWRestArea(aArea)

    RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return

/*/{Protheus.doc} GerCtr

Alimenta array com os dados dos contratos a serem gerados

@author Brito

@since 30/04/2025

/*/

Static Function GerCtr()

    Local aRet	  := {}
	Local aArea   := GetArea()
    //Local ny      := 0
    //Local lInclui := .T.
    Local aDados  := {}
    Local cTexto  := "Importação de Contratos"
    Local lEnd    := .T.
    
    Private aCNC  := {}
    Private aCN9  := {}
    Private aCNA  := {}
    Private aCNB  := {}
    Private aCNZ  := {}
    Private aCNF  := {}
    //CN9/CNC/CNA/CNB/CNN/CPD
    SaveInter()

    aDados := {}

    If ParamBox({	{6,"Selecione Arquivo",PadR("",150),"",,"", 90 ,.T.,"","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;
            cTexto,@aRet)

        
        If MsgYesNo( "Confirma seleção do arquivo?", "Confirma" )
            If ".csv" $ Alltrim(aRet[1])
                MsgRun("Lendo " + cTexto + " no arquivo csv...", cTexto, {|| SolDadCtr( lEnd, aRet[1]) })
            Else 
                FWAlertError("Permitido apenas arquivo em formato .csv", "Erro Arquivo")
                Return
            EndIf
        EndIf

    Else

        Return

    EndIf

    RestInter()

    Processa({|| SolGrvCtr()}, "Gerando Contratos...")

	RestArea(aArea)

Return 


/*/{Protheus.doc} SolGrvCtr

Realiza a gravação de contratos a partir dos dados CSV - SolGrvCtr

@author Brito

@since 30/04/2025

/*/

Static Function SolGrvCtr()

    Local cMsg       := ''
    Local cNumPlan   := ''
    Local lRet       := .T.
    Local nx         := 0
    Local nCN9       := 0
    Local nCNA       := 0
    Local nCNB       := 0
    Local nConta     := 0
    Local aErro      := {}
    Local nItem      := 0
    Local cContrato  := ""

    Local oModelCN9
    Local oModelCNC
    Local oModelCNA
    Local oModelCNB
    Local oModelCNF	
    Local oModel           

    Private lAutoErrNoFile := .T.  
    Private lMsErroAuto    := .F.
    
    For nCN9 := 1 To Len(aCN9)

        oModel  := FWLoadModel("CNTA300") //Carrega o modelo

        oModelCN9 := oModel:GetModel("CN9MASTER")
        oModelCNC := oModel:GetModel("CNCDETAIL")
        oModelCNA := oModel:GetModel("CNADETAIL")
        oModelCNB := oModel:GetModel("CNBDETAIL")
        oModelCNF := oModel:GetModel("CNFDETAIL")

        oModel:SetOperation(MODEL_OPERATION_INSERT) // Seta operação de inclusão
        
        oModel:Activate() // Ativa o Modelo
        //Cabeçalho Contrato
        cContrato := aCN9[nCN9][2]

        oModelCN9:SetValue( 'CN9_NUMERO'  , aCN9[nCN9][2]               )
        oModelCN9:SetValue( 'CN9_DTINIC'  , Ctod(aCN9[nCN9][3])         )
        oModelCN9:SetValue( 'CN9_DTASSI'  , Ctod(aCN9[nCN9][4])         )   
        oModelCN9:SetValue( 'CN9_UNVIGE'  , aCN9[nCN9][5]               )
        oModelCN9:SetValue( 'CN9_SITUAC'  , "03"                        )                                
        oModelCN9:SetValue( 'CN9_CONDPG'  , StrZero(Val(aCN9[nCN9][11]),TamSX3("CN9_CONDPG")[1]))
        oModelCN9:SetValue( 'CN9_VIGE'    , Val(aCN9[nCN9][6])          )
        oModelCN9:SetValue( 'CN9_TPCTO'   , StrZero(Val(aCN9[nCN9][14]),TamSX3("CN9_TPCTO")[1]))
        oModelCN9:SetValue( 'CN9_VLATU'   , Val(aCN9[nCN9][16])         ) 
        oModelCN9:SetValue( 'CN9_FLGCAU'  , "2"                         )

    //Planilhas do Contrato

        For nCNA := 1 to Len(aCNA)

            If Alltrim(aCNC[nCNA][2]) == Alltrim(cContrato)

                If nx > 1
                    oModelCNA:AddLine()
                    oModelCNC:AddLine()
                EndIf

                oModelCNC:SetValue('CNC_CODIGO', aCNC[nCNA][3])
                oModelCNC:SetValue('CNC_LOJA'  , StrZero(Val(aCNC[nCNA][4]), TamSX3("CNC_LOJA")[1]))

                cNumPlan := aCNA[nCNA][3] 

                oModelCNA:SetValue('CNA_NUMERO'  , StrZero(Val(aCNA[nCNA][3]),TamSX3("CNA_NUMERO")[1])  )
                oModelCNA:SetValue('CNA_FORNEC'  , oModel:GetValue('CNCDETAIL','CNC_CODIGO')            )   
                oModelCNA:SetValue('CNA_LJFORN'  , oModel:GetValue('CNCDETAIL','CNC_LOJA')              )  
                oModelCNA:SetValue('CNA_TIPPLA'  , StrZero(Val(aCNA[nCNA][12]),TamSX3("CNA_TIPPLA")[1]) )

                nItem := 0
                //Itens da Planilha do Contrato
                For nCNB := 1 to Len(aCNB)

                    If (Alltrim(cContrato) == Alltrim(aCNB[nCNB][1])).And. (Alltrim(aCNB[nCNB][2]) == Alltrim(cNumPlan))
                        If nCNB > 1

                            nItem ++

                            If nItem > 1
                                oModelCNB:AddLine()
                            EndiF

                            oModelCNB:SetValue('CNB_NUMERO'  , cNumPlan                             )
                            oModelCNB:SetValue('CNB_ITEM'    , StrZero(nItem, TamSX3("CNB_ITEM")[1]) )
                            oModelCNB:SetValue('CNB_PRODUT'  , aCNB[nCNB][5]                        )
                            oModelCNB:SetValue('CNB_QUANT'   , Val(aCNB[nCNB][8])                   )
                            oModelCNB:SetValue('CNB_VLUNIT'  , Val(aCNB[nCNB][12])                  )
                        EndIf
                    EndIf

                Next

            EndIf 
        Next

        oModelCNA:SetNoUpdateLine(.F.)
        oModelCNA:SetNoUpdateLine(.F.)

        //Validação e Gravação do Modelo

        If oModel:VldData()
            oModel:CommitData()
            cMsg := cContrato
            nConta ++
        Else
            aErro := oModel:GetErrorMessage()
            lRet := .F.
            cMsg := Alltrim(aErro[3]) + " - " + Alltrim(aErro[4]) + " - " + Alltrim(aErro[5]) + " - " + Alltrim(aErro[6]) 
            aAdd(aLogs,"Contrato: " + cContrato + " - " + cMsg)
        EndIf

        oModel:DeActivate()
            
    Next

    FWAlertSuccess("Contratos importados com sucesso. Total lidos: " + cValTochar(Len(aCN9)) + " Total Inclusos: " + cValTochar(nConta) , "SIGAGCT - Contratos")

    If Empty(aLogs)
        aAdd(aLogs,"Não houveram inconsistências na geração de contratos!")
    EndIf 

    GerMsgLog("Contratos não inclusos", 1, .F.,aLogs)

Return 

/*/{Protheus.doc} SolDadCtr

Importador de contratos - SolDadCtr

@author Brito

@since 30/04/2025

/*/

Static Function SolDadCtr(lEnd, cArq)
	
	Local cLinha  := ""
	Local nTot2   := 0
    Local lCNC    := .F.
    Local lCN9    := .F.
    Local lCNA    := .F.
    Local lCNB    := .F.
    Local lCNZ    := .F.
    Local lCNF    := .F.

	Private aErro     := {}
	Private HrIn      := Time()    
	Private HrFin
	Private aErros    := {}
 
	If !File(cArq)
		MsgStop("O arquivo "  + cArq + " não foi encontrado. A importação será cancelada!","ATENCAO")
		Return
	EndIf
 
	FT_FUSE(cArq)
	FT_FGOTOP()

	nTot2 := FT_FLASTREC()

	While !FT_FEOF()

        cLinha := FT_FREADLN()

        If SubStr(cLinha, 1,3) == "CNC" 
 
            If SubStr(cLinha, 1,6) != "Filial" .And. SubStr(cLinha, 1,3) != "CNC" 
                AADD(aCNC,Separa(cLinha,";",.T.))
            EndIf

            lCNC    := .T.

        ElseIf SubStr(cLinha, 1,3) == "CN9" 

            If SubStr(cLinha, 1,6) != "Filial" .And. SubStr(cLinha, 1,3) != "CN9" 
                AADD(aCN9,Separa(cLinha,";",.T.))
            EndIf

            lCNC    := .F.
            lCN9    := .T.

        ElseIf SubStr(cLinha, 1,3) == "CNA" 

            If SubStr(cLinha, 1,6) != "Filial" .And. SubStr(cLinha, 1,3) != "CNA" 
                AADD(aCNA,Separa(cLinha,";",.T.))
            EndIf

            lCN9    := .F.
            lCNA    := .T.

        ElseIf SubStr(cLinha, 1,3) == "CNB"  

            If SubStr(cLinha, 1,6) != "Filial" .And. SubStr(cLinha, 1,3) != "CNB" 
                AADD(aCNB,Separa(cLinha,";",.T.))
            EndIf

            lCNA    := .F.
            lCNB    := .T.

        Else
            
            If !Empty(cLinha) 
                If lCNC    
                    If SubStr(cLinha, 1,6) != "Filial"
                        AADD(aCNC,Separa(cLinha,";",.T.))
                    EndIf
                ElseIf lCN9 
                    If SubStr(cLinha, 1,6) != "Filial"
                        AADD(aCN9,Separa(cLinha,";",.T.))
                    EndIf
                ElseIf lCNA 
                    If SubStr(cLinha, 1,6) != "Filial"
                        AADD(aCNA,Separa(cLinha,";",.T.))
                    EndIf
                ElseIf lCNB 
                    If SubStr(cLinha, 1,6) != "Filial"
                        AADD(aCNB,Separa(cLinha,";",.T.))
                    EndIf
                ElseIf lCNZ 
                    If SubStr(cLinha, 1,6) != "Filial"
                        AADD(aCNZ,Separa(cLinha,";",.T.))
                    EndIf
                ElseIf lCNF 
                    If SubStr(cLinha, 1,6) != "Filial"
                        AADD(aCNF,Separa(cLinha,";",.T.))
                    EndIf
                EndIf
            EndIf

        EndIf

        FT_FSKIP()

	EndDo

Return 

/*/{Protheus.doc} GerMsgLog

Gera mensagem de log de importação

@author Brito
@since 09/07/2024

/*/

Static Function GerMsgLog(cTitulo, nTipo, lEdit, aLogs)

    Local aArea      := GetArea()
    Local lRetMens   := .F.
    Local oDlgMens
    Local oBtnOk 
    Local cTxtConf   := ""
    Local oBtnCnc 
    Local cTxtCancel := ""
    Local oBtnSlv
    Local oFntTxt    := TFont():New("Lucida Console",,-015,,.F.,,,,,.F.,.F.)
    Local oMsg   
    Local cMsg       := ""
    Local nx         := 0


    For nx := 1 To Len(aLogs)

        cMsg += "Erro: " + aLogs[nx] + CRLF + CRLF + CRLF 
        cMsg += "++++++++++++++++++++++++++++++++++++++++++++++++++++++++" + CRLF + CRLF + CRLF + CRLF + CRLF + CRLF

    Next
  
    //Definindo os textos dos botões
    If(nTipo == 1)
        cTxtConf:='&Ok'
    Else
        cTxtConf:='&Confirmar'
        cTxtCancel:='C&ancelar'
    EndIf

    //Criando a janela centralizada com os botões
    DEFINE MSDIALOG oDlgMens TITLE cTitulo FROM 000, 000  TO 300, 400 COLORS 0, 16777215 PIXEL
        //Get com o Log
        @ 002, 004 GET oMsg VAR cMsg OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
        If !lEdit
            oMsg:lReadOnly := .T.
        EndIf
            
        //Se for Tipo 1, cria somente o botão OK
        If (nTipo==1)
            @ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 019 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            
        //Senão, cria os botões OK e Cancelar
        ElseIf(nTipo==2)
            @ 127, 144 BUTTON oBtnOk  PROMPT cTxtConf   SIZE 051, 009 ACTION (lRetMens:=.T., oDlgMens:End()) OF oDlgMens PIXEL
            @ 137, 144 BUTTON oBtnCnc PROMPT cTxtCancel SIZE 051, 009 ACTION (lRetMens:=.F., oDlgMens:End()) OF oDlgMens PIXEL
        EndIf
            
        //Botão de Salvar em Txt
        @ 127, 004 BUTTON oBtnSlv PROMPT "&Salvar em .txt" SIZE 051, 019 ACTION (SalvaLog(cMsg, cTitulo)) OF oDlgMens PIXEL
    ACTIVATE MSDIALOG oDlgMens CENTERED

    RestArea(aArea)
 
Return lRetMens

/*/{Protheus.doc} SalvaLog

Salva log em disco com resultado de registros não importados

@author Brito
@since 02/05/2025

/*/

Static Function SalvaLog(cMsg, cTitulo)

    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local cQuebra  := CRLF + "+=======================================================================+" + CRLF
    Local lOk      := .T.
    Local cTexto   := ""
        
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)

    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
            
        //Montando a mensagem
        cTexto := "Função   - "+ FunName()       + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += "Mensagem - "+ cTitulo + cQuebra  + cMsg + cQuebra
            
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
            
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf

Return

/*/{Protheus.doc} fSetClog

Função para ler erro do excauto

@Project     Solfacil
@author      Brito
@since       02/05/2025

/*/

Static Function fSetClog()

	Local nW   := 0
	Local cRet := ""

	For nW := 1 To Len(aLogAuto)
		cRet += aLogAuto[nW] +CRLF
	Next nW

Return cRet
