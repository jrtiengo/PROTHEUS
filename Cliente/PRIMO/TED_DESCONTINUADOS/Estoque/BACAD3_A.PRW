#Include "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

#Define PD_INCLUIR 3


/*/{Protheus.doc} BACAD3_A
Canoas 
Compatibiliza saldo B2 x Saldo Infobox dos saldos Negativos do B2  importado de Texto, fazendo movimentação para chegar no movimento. 
@type function
@version 
@author solutio
@since 07/10/2020
@return return_type, return_description
/*/
User Function BACAD3_A()
    Local x_cFilAnt := cFilAnt

//Premissas: Produtos não controlam lote/Rastro
//Importa Arquivo Texto. 


//Campos arquivo de importção:
//EmpresaFilial;C¢digoReferencia;Referˆncia;PapelÆo;Medidia Internas;;Saldo Estoque;;;Qt. emProcesso;;;Qt. em Aberto;Qt.M¡nimaEstoque;Qtde. deReposi‡Æo;M2 Item;Kg Item;Pre‡o unit rio
//usasdo apenas o campo referência [pos 02] e o campmo Saldo Estoque [pos 7]


//Estrutura
//Código
//Filial
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


    Private oLeTxt
    Private nTamFile



    //Private cTrab
    Private cDirDocs := MsDocPath() //"\dirdoc\co01\shared"
    Private cSPatch := "" //Patch do Servidor - Full
    Private cTPatch := "" //Patch do Terminal - Full


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    @ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Primo Tedesco - Importação Saldos Infobox (SB2)")
    @ 02,10 TO 080,190
    @ 10,018 Say " Este programa le o arquivo formato previamente definido       "
    @ 18,018 Say " importanto os saldos do Infobox para o Saldo Atual do Protheus"
    @ 26,018 Say " Clique em Parâmetros para carregar o ARquivo                  "

    @ 60,078 BMPBUTTON TYPE 05 ACTION Arquivo()
    @ 60,108 BMPBUTTON TYPE 01 ACTION OkLeTxt()
    @ 60,138 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

    Activate Dialog oLeTxt Centered

    cFilAnt := x_cFilAnt


Return

/*/{Protheus.doc} Arquivo
Escolhe arquivo para carga
@type function
@version 
@author solutio
@since 09/07/2020
@return return_type, return_description
/*/
Static Function Arquivo()

    Local cEscolheuFile := .F.

    WHILE !cEscolheuFile

        CTIPO := " "
        CTIPO += "Todos os arquivos   (*.csv)    | *.csv   | "
        cTPatch:= CGETFILE( CTIPO , "Seleção da pasta de geração da Tabela ",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
        cTPatch  := LOWER(ALLTRIM(cTPatch))


        If File(cTPatch)
            cEscolheuFile := .T.
        ELSE
            IW_MsgBox("Não foi possível localizar o arquivo",OemToAnsi("Arquivo..."),"INFO" )

        ENDIF

    Enddo
Return

/*/{Protheus.doc} OkLeTxt
Funcao chamada pelo botao OK na tela inicial de processamento. Executa a leitura do arquivo texto. 
@type function
@version 
@author solutio
@since 08/07/2020
@return return_type, return_description
/*/
Static Function OkLeTxt
    Private lValidArq := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



    Private nHdl    := FT_FUSE(cTPatch)  //fOpen(cTPatch,68)

    Private cEOL    := "CHR(13)+CHR(10)"

    If Empty(cEOL)
        cEOL := CHR(13)+CHR(10)
    Else
        cEOL := Trim(cEOL)
        cEOL := &cEOL
    Endif

    If nHdl == -1
        MsgAlert("O arquivo de nome "+ cTPatch +" nao pode ser aberto! Verifique os parametros.","Atencao!")
        Return
    Endif




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



    Processa({|| RunCont() },"Lendo e Processando Arquivo...")

/*
    IF SELECT( '_TRB' ) <> 0
        _TRB->(DBCloseArea())
    ENDIF
    */

    Close(oLeTxt)

Return


Static Function RunCont()






    Local lFoundB2  := .F.
    Local nQTD_B2   := 0
    Local aItens    := {} //Itens para  Movimento
    Local _aitem    := {} //montagem dados  do movimento

    Private cLOGERRO := ""
//Variáveis da EStrutura da Tabela

    Private aLinha  := {}
    Private nLinha  := 0
    Private cLinha  := ""

    //Layout
    PRIVATE X_COD      := 1 //B1_COD
    PRIVATE X_LOCAL    := 2 //B1_DESC
    PRIVATE X_QTD      := 3 //B1_TIPO

    cFilAnt := '0102' //Sempre vai rodar este programa para Canoas

    DBSelectArea("SB1"); DBSetOrder(1)
    DBSelectArea("SB2"); DBSetOrder(1)

    FT_FUSE(cTPatch)  //FT_FUSE(cSPatch)

    nTamFile := FT_FLastRec()
    ProcRegua(nTamFile)

    FT_FGOTOP()
    While !FT_FEOF()


        nLinha++
        IncProc("Processando Linha " + STR(nLinha))

        cLinha := FT_FREADLN()

        aLinha        := StrTokArr( cLinha , ";" )

        //AJUSTA REGISTROS PARA LAYOUT
        aLinha[X_COD]       := PadR( aLinha[X_COD]  , TamSX3("B2_COD")[01] )
        aLinha[X_LOCAL]     := PadR( aLinha[X_LOCAL], TamSX3("B2_LOCAL")[01] )
        aLinha[X_QTD]     := VAL( aLinha[X_QTD] )

        //Busca Produto no SB1
        SB1->(DBSetOrder(1))
        SB1->(DBGotop())

        cChave :=   xFilial("SB1") + aLinha[X_COD]
        lFoundB1  := SB1->(MsSeek( cChave ))

        //Busca Produto no SB2
        SB2->(DBSetOrder(1))
        SB2->(DBGotop())

        cChave :=   xFilial("SB2") +  aLinha[X_COD] + aLinha[X_LOCAL]
        lFoundB2  := SB2->(MsSeek( cChave ))
        IF lFoundB1 .and. lFoundB2 .AND.  SB2->B2_QATU < aLinha[X_QTD]  // Só importa se localizar B2 e se B2 for menor do que Infobox
            nQTD_B2 := aLinha[X_QTD] - SB2->B2_QATU

            _aitem:={ {"D3_COD" ,SB1->B1_COD ,NIL};
                ,{"D3_UM" ,SB1->B1_UM ,NIL};
                ,{"D3_QUANT" ,nQTD_B2 ,NIL};
                ,{"D3_LOCAL" ,aLinha[X_LOCAL] ,NIL};
        /*,{"D3_LOTECTL" ,"22968/C" ,NIL}*/}
                aadd(aItens,_aitem)
        Else
            cLOGERRO += "Registro " + AllTrim(STR(nLinha)) + " ignorado: " + CRLF
            IF !lFoundB1
                cLOGERRO += "     não encontrado produto " + aLinha[X_COD] + CRLF
            ENDIF
            IF !lFoundB2
                cLOGERRO += "     não encontrado  saldo produto  " + aLinha[X_COD] + " Local " + aLinha[X_LOCAL] + CRLF
            ENDIF
            IF SB2->B2_QATU < aLinha[X_QTD]
                cLOGERRO += "     saldo no SB2 (" + AllTrim(STR(SB2->B2_QATU)) + " maior que infobox (" + AllTrim(STR( aLinha[X_QTD])) + ") para produto  " + aLinha[X_COD] + " Local " + aLinha[X_LOCAL] + CRLF
            ENDIF
        Endif


        FT_FSKIP()
    EndDo
    FT_FUSE()

    If !Empty(aItens)
        CriaMov(aItens)
    Endif

    If !Empty(cLOGERRO)
        cLOGERRO := "*** Processamento Realizado com Inconsistências encontradas  ***" + CRLF + cLOGERRO
        GeraLog(cLOGERRO)
        cLOGERRO := ""
    else
        MsgInfo("processo executado com sucesso ")
    Endif


Return


Static Function CriaMov(_atotitem)
    Local _aCab1 := {}
    //Local _aItem := {}
    //Local _atotitem:={}
    Local cCodigoTM:="444" //Devolução - Movimentos de ajuste de negativos (temporariamente)
    //Local cCodProd:="00001 "
    //Local cUnid:="CX "

    Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    Private lMsErroAuto := .f. //necessario a criacao

    //Private _acod:={"1","MP1"}
    //PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"

    _aCab1 := { {"D3_TM" ,cCodigoTM , NIL},;
        {"D3_EMISSAO" ,ddatabase, NIL}}
        /*
    _aItem:={ {"D3_COD" ,cCodProd ,NIL},;
        {"D3_UM" ,cUnid ,NIL},;
        {"D3_QUANT" ,11 ,NIL},;
        {"D3_LOCAL" ,"01" ,NIL},;
        {"D3_LOTECTL" ,"22968/C" ,NIL}}*/

    //aadd(_atotitem,_aitem)
    MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,PD_INCLUIR)

    If lMsErroAuto
        Mostraerro()
        DisarmTransaction()
        break

    EndIf

Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraLog   ºAutor  ³Márcio.Borges   º Data ³      05/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraLog( cLogTxt )
    *********************************************************************
    __cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

    Define FONT oFont NAME "Tahoma" Size 6,12
    Define MsDialog oDlgMemo Title "Consistência dos Dados" From 3,0 to 340,550 Pixel

    @ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
    oMemo:bRClicked := {||AllwaysTrue()}
    oMemo:oFont:=oFont
//Define SButton  From 153,205 Type 13 Action (cFile := cGetFile(cMask,""), Iif(cFile="",.T.,MemoWrite(cFile,cLogTxt)) ) Enable Of oDlgMemo Pixel
    Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
    Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

    Activate MsDialog oDlgMemo Center

Return()
    *********************************************************************
Static Function Mysend(cTxt)
    *********************************************************************
    Static oDlg
    Static oButton1
    Static oButton2
    Static oGet1
    Static cGet1 := Space(200)
    Static oSay

    DEFINE MSDIALOG oDlg TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

    @ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
    @ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

    @ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
    @ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return
    *********************************************************************
Static Function DISMAILX(cMail,cTxt)
    *********************************************************************

    CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

    If !lResult
        MsgBox('Erro no Envio')
        Return()
    EndIf

    cAccount := GETMV("MV_RELACNT")

    SEND MAIL FROM cAccount 	;
        TO      cMail	        	;
        SUBJECT FUNDESC()       	;//SUBJECT "Log Sx3 vs Banco" 	;
        BODY cTxt + CRLF + CRLF + FUNNAME() + " - " + FUNDESC()

    DISCONNECT SMTP SERVER

    MsgInfo("Email Enviado com Sucesso!")

Return()
