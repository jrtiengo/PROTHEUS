#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "ap5mail.ch"

#define ENTER Chr(13)+Chr(10)
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5


/*/{Protheus.doc} BACAB1
Rotina de Importação de Produto (SB1) customizada para Primo Tedesco, conforme regras específicas
@type function
@version 
@author solutio
@since 08/07/2020
@return return_type, return_description
/*/
User Function BACAB1()
    Local x_cFilAnt := cFilAnt

    Private lAjusta := .T. // Executa alterações
    Private  cLOGERRO := ""
//Private ENTER  := CHR(13)+ CHR(10)

    PRIVATE X_FILIAL    := 1 //B1_FILIAL
    PRIVATE X_COD       := 2 //B1_COD
    PRIVATE X_DESC      := 3 //B1_DESC
    PRIVATE X_TIPO      := 4 //B1_TIPO
    PRIVATE X_UM        := 5 //B1_UM
    PRIVATE X_LOCPAD    := 6 //B1_LOCPAD
    PRIVATE X_POSIPI    := 7 //B1_POSIPI
    PRIVATE X_GRUPO     := 8 //B1_GRUPO
    PRIVATE X_ORIGEM    := 9 //B1_ORIGEM
    PRIVATE X_CONTA     := 10 // B1_CONTA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


    Private oLeTxt
    Private nTamFile
//Private aArquivo := {}

//Acumuladores
/*
    Private X_TPREG := 1
    Private X_CLINHA:= 2
    Private X_LDEL  := 3


    Private X_PLDTA := 1
    Private X_PLCTA := 2
    Private X_PLDBT := 3
    Private X_PLCRT := 4
    */

    //Private cTrab
    Private cDirDocs := MsDocPath() //"\dirdoc\co01\shared"
    Private cSPatch := "" //Patch do Servidor - Full
    Private cTPatch := "" //Patch do Terminal - Full


    DbSelectArea("SB1") // sx2_unico : B1_FILIAL+B1_COD
    DBSetOrder(1)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento.                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    @ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Primo Tedesco - Importação Produto")
    @ 02,10 TO 080,190
    @ 10,018 Say " Este programa le o arquivo formato previamente definido (MILE)"
    @ 18,018 Say " conforme necessidades específicas da Primo Tedesco            "
    @ 26,018 Say " Clique em Parâmetros para carregar o ARquivo                  "

    @ 60,078 BMPBUTTON TYPE 01 ACTION OkLeTxt()
    @ 60,108 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
    @ 60,138 BMPBUTTON TYPE 05 ACTION Arquivo()

    Activate Dialog oLeTxt Centered

    cFilAnt := x_cFilAnt

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

    Processa({|| CopyToServer()},"Copiando Arquivo para o Servidor...")

    IF MSGYESNO("Deseja Validar o Aarquivo antes de processar?")
        Processa({|| VldArq(@lValidArq)},"Validando arquivo...")
        IF  !lValidArq
            cLOGERRO := "*** Processamento Cancelado - Inconsistências encontradas no arquivo ***" + ENTER + cLOGERRO
            GeraLog(cLOGERRO)
            cLOGERRO := ""

            IF !MSGYESNO("Foi identificado inconsistências, deseja Proceguir com a importação mesmo assim?")
                Return
            ENDIF
        Endif
    Endif

    Processa({|| RunCont() },"Lendo e Processando Arquivo...")

/*
    IF SELECT( '_TRB' ) <> 0
        _TRB->(DBCloseArea())
    ENDIF
    */

    Close(oLeTxt)

Return



Static Function VldArq(lValidArq)

    Local nHandle


//Variáveis da EStrutura da Tabela
    Private aStru   := SB1->(DBSTRUCT())
    Private nPosCPO := 1
    Private aLinha  := {}
    Private nLinha  := 0
    Private cLinha  := ""

    //Layout
    PRIVATE X_FILIAL    := 1 //B1_FILIAL
    PRIVATE X_COD       := 2 //B1_COD
    PRIVATE X_TIPO      := 4 //B1_TIPO
    PRIVATE X_UM        := 5 //B1_UM
    PRIVATE X_LOCPAD    := 6 //B1_LOCPAD
    PRIVATE X_POSIPI    := 7 //B1_POSIPI
    PRIVATE X_GRUPO     := 8 //B1_GRUPO
    PRIVATE X_ORIGEM    := 9 //B1_ORIGEM
    PRIVATE X_CONTA     := 10 // B1_CONTA




    nHandle := FT_FUSE(cSPatch)

    if nHandle = -1
        MSGAlert("Erro abertura arquivo")
        lValidArq := .F.
        return
    endif

    nTamFile := FT_FLastRec()
    ProcRegua(nTamFile)


    FT_FGOTOP()
    While !FT_FEOF()

        nLinha++
        IncProc("Analisando Linha " + STR(nLinha))

        cLinha := FT_FREADLN()

        aLinha:= StrTokArr( cLinha , ";" )
        //AJUSTA REGISTROS PARA LAYOUT
        aLinha[X_COD]       := PadR( aLinha[X_COD], TamSX3("B1_COD")[01] )
        aLinha[X_TIPO]      := PadR( aLinha[X_TIPO], TamSX3("B1_TIPO")[01] )
        aLinha[X_UM]        := PadR( aLinha[X_UM], TamSX3("B1_UM")[01] )
        aLinha[X_GRUPO]     := PadR( aLinha[X_GRUPO], TamSX3("B1_GRUPO")[01] )
        aLinha[X_POSIPI]    := PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] )
        aLinha[X_LOCPAD]    := PadR( aLinha[X_LOCPAD], TamSX3("B1_LOCPAD")[01] )
        aLinha[X_CONTA]     := PadR( aLinha[X_CONTA], TamSX3("B1_CONTA")[01] )
        aLinha[X_ORIGEM]    := PadR( aLinha[X_ORIGEM], TamSX3("B1_ORIGEM")[01] )


        nTamFilial := LEN(aLinha[X_FILIAL])
        IF nTamFilial == 2
            cFilAnt := "01" + aLinha[X_FILIAL] // Altera a Filial do registro
        ELSE
            cFilAnt :=  aLinha[X_FILIAL]
        ENDIF

        IF aLinha[X_TIPO] <> 'PA'

            //Busca Tipo - SX5 tab 02
            //aGetSX5 := FwGetSX5("02",aLinha[X_TIPO])
            aGetSX5 := FwGetSX5("02")
            IF  ASCAN(aGetSX5,{|x| AllTrim(x[3]) == AllTrim(aLinha[X_TIPO])} ) == 0 //Empty(aGetSX5)
                lValidArq := .F.
                cLOGERRO += "Erro Valid Arquivo: Linha " + AllTrim(STR(nLinha)) +  " Tipo não localilzado: " + aLinha[X_TIPO] + ENTER
            Endif

            //UM - TAb SAH

            dbSelectArea('SAH')
            dbSetOrder(1)
            IF !dbSeek(xFilial('SAH')+PadR( aLinha[X_UM], TamSX3("B1_UM")[01] ))
                lValidArq := .F.
                cLOGERRO += "Erro Valid Arquivo: Linha " + AllTrim(STR(nLinha)) +  " - Unidade de Medida não cadastrado: " + aLinha[X_UM] + ENTER
            EndIf

            //LOCPAD
            dbSelectArea('NNR')
            dbSetOrder(1)
            IF !dbSeek(xFilial('NNR')+PadR( aLinha[X_LOCPAD], TamSX3("B1_LOCPAD")[01] ))
                lValidArq := .F.
                cLOGERRO += "Erro Valid Arquivo: Linha " + AllTrim(STR(nLinha)) +  " - Local Padrão não cadastrado: " + aLinha[X_LOCPAD] + ENTER
            EndIf

            //POSIPI
            dbSelectArea('SYD')
            dbSetOrder(1)
            IF !dbSeek(xFilial('SYD')+PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] ))
                lValidArq := .F.
                cLOGERRO += "Erro Valid Arquivo: Linha " + AllTrim(STR(nLinha)) +  " - NCM não cadastrado: " + aLinha[X_POSIPI] + ENTER
            EndIf
            dbSelectArea('CT1')
            dbSetOrder(1)
            IF !dbSeek(xFilial('CT1')+PadR( aLinha[X_CONTA], TamSX3("B1_CONTA")[01] ))
                lValidArq := .F.
                cLOGERRO += "Erro Valid Arquivo: Linha " + AllTrim(STR(nLinha)) +  " - Conta Contábil não cadastrado: " + aLinha[X_CONTA] + ENTER
            EndIf

        ENDIF

        FT_FSKIP()
    EndDo
    FT_FUSE()

Return




/*/{Protheus.doc} RunCont
Funcao auxiliar chamada pela PROCESSA para adicionar registros
@type function
@version 
@author solutio
@since 09/07/2020
@return return_type, return_description
/*/
Static Function RunCont
    Local nPos, cChave
    Local nTamFilial := 2
    //Local  nTamLin, cBuffer, nBtLidos
    //Local cQuery := ""
    Local aDePara := {}
    Local lFoundB1, lFoundB5
    Local lAtualiz := .T. // atualiza descrições e dados dos pa´s existentes


//Variáveis da EStrutura da Tabela
    Private aStru   := SB1->(DBSTRUCT())
    Private nPosCPO := 1
    Private aLinha  := {}
    Private nLinha  := 0
    Private cLinha  := ""

    //Layout
    PRIVATE X_FILIAL    := 1 //B1_FILIAL
    PRIVATE X_COD       := 2 //B1_COD
    PRIVATE X_DESC      := 3 //B1_DESC
    PRIVATE X_TIPO      := 4 //B1_TIPO
    PRIVATE X_UM        := 5 //B1_UM
    PRIVATE X_LOCPAD    := 6 //B1_LOCPAD
    PRIVATE X_POSIPI    := 7 //B1_POSIPI
    PRIVATE X_GRUPO     := 8 //B1_GRUPO
    PRIVATE X_ORIGEM    := 9 //B1_ORIGEM
    PRIVATE X_CONTA     := 10 // B1_CONTA

    // Tratamento para DE-PARA
    AADD(aDePara,{'25784','15981'})
    AADD(aDePara,{'25794','1169'})
    AADD(aDePara,{'26379','1356'})
    AADD(aDePara,{'23121','30089'})
    AADD(aDePara,{'23423','30545'})
    AADD(aDePara,{'23439','7452'})
    AADD(aDePara,{'23463','7495'})
    AADD(aDePara,{'24196','30584'})
    AADD(aDePara,{'25748','30118'})
    AADD(aDePara,{'25750','30121'})
    AADD(aDePara,{'25751','30122'})
    //AADD(aDePara,{'25752','30123'}) // De-para cancelado em 03/08/2020 por Jerri. Não deveria ter sido realizado
    //AADD(aDePara,{'25753','30125'}) // De-para cancelado em 03/08/2020 por Jerri. Não deveria ter sido realizado
    AADD(aDePara,{'25755','30126'})
    AADD(aDePara,{'25756','30127'})
    AADD(aDePara,{'26666','30090'})
    AADD(aDePara,{'27367','30381'})
    AADD(aDePara,{'20160','34904'})
    AADD(aDePara,{'20161','34905'})
    AADD(aDePara,{'20277','34906'})
    AADD(aDePara,{'20423','34907'})
    AADD(aDePara,{'20670','34908'})
    AADD(aDePara,{'20712','34909'})
    AADD(aDePara,{'20792','34910'})
    AADD(aDePara,{'20911','34911'})
    AADD(aDePara,{'21283','34912'})
    AADD(aDePara,{'21567','34913'})
    AADD(aDePara,{'21647','34914'})
    AADD(aDePara,{'21677','34915'})
    AADD(aDePara,{'21886','30512'})
    AADD(aDePara,{'21987','34916'})
    AADD(aDePara,{'22258','30614'})
    AADD(aDePara,{'23239','34917'})
    AADD(aDePara,{'23839','34918'})
    AADD(aDePara,{'23989','34919'})
    AADD(aDePara,{'24022','34920'})
    AADD(aDePara,{'24502','34921'})
    AADD(aDePara,{'24862','34922'})
    AADD(aDePara,{'24863','34923'})
    AADD(aDePara,{'24939','34924'})
    AADD(aDePara,{'25633','30207'})
    AADD(aDePara,{'26005','34930'})
    AADD(aDePara,{'26021','34931'})
    AADD(aDePara,{'26143','300108'})
    AADD(aDePara,{'26144','34932'})
    AADD(aDePara,{'26794','30079'})
    AADD(aDePara,{'27022','4574'})
    AADD(aDePara,{'27479','34933'})
    AADD(aDePara,{'27532','30637'})
    AADD(aDePara,{'27643','1246'})
    AADD(aDePara,{'27687','34754'})
    AADD(aDePara,{'27933','5300'})
    AADD(aDePara,{'27964','30287'})
    AADD(aDePara,{'27996','30181'})
    AADD(aDePara,{'28019','34935'})
    AADD(aDePara,{'28051','7544'})
    AADD(aDePara,{'28105','30519'})
    AADD(aDePara,{'28122','26253'})
    AADD(aDePara,{'28123','34936'})
    AADD(aDePara,{'29000','30071'})
    AADD(aDePara,{'29006','34554'})
    AADD(aDePara,{'29178','34938'})
    AADD(aDePara,{'29732','30281'})
    AADD(aDePara,{'29743','30741'})
    AADD(aDePara,{'29763','26708'})
    AADD(aDePara,{'29826','34939'})
    AADD(aDePara,{'21266','34954'})
    AADD(aDePara,{'29954','30573'})
    AADD(aDePara,{'26208','30653'})
    AADD(aDePara,{'29693','30831'})
    AADD(aDePara,{'29312','30838'})



// Leitura de Arquivo
//LeArquivo()
//Geração arquivo temporário
    // GeraTemp()

    FT_FUSE(cSPatch)

    nTamFile := FT_FLastRec()
    ProcRegua(nTamFile)

    FT_FGOTOP()
    While !FT_FEOF()

        nLinha++
        IncProc("Processando Linha " + STR(nLinha))

        cLinha := FT_FREADLN()

        aLinha        := StrTokArr( cLinha , ";" )

        //AJUSTA REGISTROS PARA LAYOUT
        aLinha[X_COD]       := PadR( aLinha[X_COD], TamSX3("B1_COD")[01] )
        aLinha[X_DESC]      := PadR(UPPER(FwNoAccent(aLinha[X_DESC])), TamSX3("B1_DESC")[01] )
        aLinha[X_TIPO]      := PadR( aLinha[X_TIPO], TamSX3("B1_TIPO")[01] )
        aLinha[X_UM]        := PadR( aLinha[X_UM], TamSX3("B1_UM")[01] )
        aLinha[X_GRUPO]     := PadR( aLinha[X_GRUPO], TamSX3("B1_GRUPO")[01] )
        aLinha[X_POSIPI]    := PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] )
        aLinha[X_LOCPAD]    := PadR( aLinha[X_LOCPAD], TamSX3("B1_LOCPAD")[01] )
        aLinha[X_CONTA]     := PadR( aLinha[X_CONTA], TamSX3("B1_CONTA")[01] )
        aLinha[X_ORIGEM]    := PadR( aLinha[X_ORIGEM], TamSX3("B1_ORIGEM")[01] )

        nTamFilial := LEN(aLinha[X_FILIAL])
        IF nTamFilial == 2
            cFilAnt := "01" + aLinha[X_FILIAL] // Altera a Filial do registro
        ELSE
            cFilAnt :=  aLinha[X_FILIAL]
        ENDIF

        //de-para Canoas
        If aLinha[X_FILIAL] == '02'
            nPos:=Ascan(aDePara, { |x| x[1] == AllTrim(aLinha[X_COD]) })
            If nPos > 0
                aLinha[X_COD] := PadR(aDePara[nPos][2], TamSX3("B1_COD")[01] )
            Endif
        Endif

        //Busca Produto PA
        IF aLinha[X_TIPO] == 'PA'
            SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
            SB1->(DBGotop())

            IF ALLTRIM(aLinha[X_COD]) = '12155A' .OR. ALLTRIM(aLinha[X_COD]) == '204135'
                lachou := .t.
            ENDIF

            //--- Verifica se Pa já foi transferido para a filial destino
            cChave := IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL] + aLinha[X_COD]
            lFoundB1  := SB1->(MsSeek( cChave ))
            If !lFoundB1 .AND. len(AllTrim(aLinha[X_COD])) < 5
                cChave := IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL] + PadR( PADL(AllTrim(aLinha[X_COD]),5,"0") , TamSX3("B1_COD")[01] )
                lFoundB1 := SB1->(MsSeek(cChave )) // busca com 5 zeros a esquerda
            Endif

            If lFoundB1 // existe na filial de destino
                //
                iF lAtualiz
                    RecLock("SB1",.F.)
                    //IF SB1->B1_TIPO <> aLinha[X_TIPO]
                    //    SB1->B1_TIPO := aLinha[X_TIPO]
                    //ENDIF
                    //SB1->B1_FILIAL  := xFilial("SB1")
                    SB1->B1_UM      := aLinha[X_UM]
                    SB1->B1_DESC    := aLinha[X_DESC]
                    SB1->B1_LOCPAD  := aLinha[X_LOCPAD]
                    SB1->B1_POSIPI  := aLinha[X_POSIPI]
                    SB1->B1_GRUPO   := aLinha[X_GRUPO]
                    SB1->B1_ORIGEM  := aLinha[X_ORIGEM]
                    SB1->B1_CONTA   := aLinha[X_CONTA]
                    MsUnLock()
                else

                    FT_FSKIP()
                    loop
                ENDIF
            Endif
            //---------------------------
            // --- Busca na filial compartilhada e envia para a filial de destino

            SB1->(DBSetOrder(2)) //B1_FILIAL+B_TIPO + B1_COD
            SB1->(DBGotop())
            // If !lFoundB1
            lFoundB1 := SB1->(MsSeek( SPACE(TAMSX3("B1_FILIAL")[1]) + "PA" + aLinha[X_COD]  ))
            //Endif
            IF lFoundB1
                // Se encontrar  altera a filial para a de destino (somente para PA´s)
                // SE não encontrar não cadastra quando PA
                If lAjusta
                    RecLock("SB1",.F.)
                    //IF SB1->B1_TIPO <> aLinha[X_TIPO]
                    //    SB1->B1_TIPO := aLinha[X_TIPO]
                    //ENDIF
                    SB1->B1_FILIAL := xFilial("SB1")
                    MsUnLock()
                Endif
            ELSE
                // Se existir produto mesmo código mas não PA, efetua cópia para filial destino
                SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD
                SB1->(DBGotop())
                lFoundB1 := SB1->(MsSeek( SPACE(TAMSX3("B1_FILIAL")[1]) + aLinha[X_COD]  ))
                If lFoundB1
                    //Cria Produto PA faltante

                    CopySB1(SB1->(recno()), IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL], @cLOGERRO) //Copia o registro da Filial de Origem para a Filial de Destino, posiciona novo registro

                    If lAjusta
                        RecLock("SB1",.F.)
                        SB1->B1_TIPO    := aLinha[X_TIPO]
                        SB1->B1_UM      := aLinha[X_UM]
                        SB1->B1_DESC    := aLinha[X_DESC]
                        SB1->B1_LOCPAD  := aLinha[X_LOCPAD]
                        SB1->B1_POSIPI  := aLinha[X_POSIPI]
                        SB1->B1_GRUPO   := aLinha[X_GRUPO]
                        SB1->B1_ORIGEM  := aLinha[X_ORIGEM]
                        SB1->B1_CONTA   := aLinha[X_CONTA]
                        MsUnLock()
                    Endif
                    //Else
                    //Inclui PA´s que não existiam
                    //PROC_MOV(PD_INCLUIR) //comentado para não cadastrar itens novos, somente mover itens inexistentes
                    // não precisa alterar filial pois já está compartilhada a tabela ao processar
                Endif
            Endif
            //---------------------------

        ELSE
            SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
            SB1->(DBGotop())


            //--- Verifica se Pa já foi transferido para a filial destino
            // busca pelo codigo que veio
            cChave := IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL] + aLinha[X_COD]
            lFoundB1 := SB1->(MsSeek( cChave ))
            If !lFoundB1  .AND. len(AllTrim(aLinha[X_COD])) < 5 // busca com 5 zeros a esquerda se não encontrar pelo código original
                cChave := IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL] + PadR( PADL(AllTrim(aLinha[X_COD]),5,"0") , TamSX3("B1_COD")[01] )
                lFoundB1 :=  SB1->(MsSeek( cChave ))
            Endif

            If lFoundB1 // existe na filial de destino
                FT_FSKIP()
                loop
            Endif
            //---------------------------
            // --- Busca na filial compartilhada e envia para a filial de destino
            lFoundB1 :=  SB1->(MsSeek( SPACE(TAMSX3("B1_FILIAL")[1]) + aLinha[X_COD]  ))

            If !lFoundB1  // busca com 5 zeros a esquerda se não encontrar pelo código original
                lFoundB1 := SB1->(MsSeek( SPACE(TAMSX3("B1_FILIAL")[1]) +  PadR(PADL(AllTrim(aLinha[X_COD]),5,"0")  , TamSX3("B1_COD")[01] )  ))
            Endif


            If lFoundB1    // Leitura base de Dados (SB1) com Recno
                CopySB1(SB1->(recno()), IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL], @cLOGERRO) //Copia o registro da Filial de Origem para a Filial de Destino, posiciona novo registro

                If lAjusta
                    RecLock("SB1",.F.)
                    SB1->B1_UM      := aLinha[X_UM]
                    SB1->B1_DESC    := aLinha[X_DESC]
                    SB1->B1_LOCPAD  := aLinha[X_LOCPAD]
                    SB1->B1_POSIPI  := aLinha[X_POSIPI]
                    SB1->B1_GRUPO   := aLinha[X_GRUPO]
                    SB1->B1_ORIGEM  := aLinha[X_ORIGEM]
                    SB1->B1_CONTA   := aLinha[X_CONTA]
                    MsUnLock()
                Endif
            ELSE
                //Cria Produto
                PROC_MOV(PD_INCLUIR)
            ENDIF
            //Ordem 1: B1_FILIAL+B1_COD (único)
            //Ordem 2: B1_FILIAL+B1_TIPO+B1_COD


            //Ajuste registros (inclusão / Alteração / Exclusão )

            //Ajuste registros (inclusão / Alteração / Exclusão )
        ENDIF


        //Busca SB5
        DBselectArea("SB5")
        DBSetOrder(1) //b5_filial + b5_cod
        lFoundB5  := SB5->(MsSeek( IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL] + PadR(SB1->B1_COD, TamSX3("B5_COD")[01]) ) )
        If !lFoundB5
            lFoundB5  := SB5->(MsSeek( SPACE(TAMSX3("B5_FILIAL")[1]) + PadR(aLinha[X_COD], TamSX3("B5_COD")[01]) ) )
            If lFoundB5
                RecLock("SB5",.F.)
                SB5->B5_FILIAL := IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL]
                MsUnLock()
            Endif
        Endif
        FT_FSKIP()
    EndDo
    FT_FUSE()
//Executa Alteracoes

/* // comentado pois existem agora diversos produtos que foram para as filiais de acordo com a regra porém na prática a regra não atendeu todos os requesitos
//Após leitura do arquivo texto, joga registros de produtos novos para a filial de destino
    cQuery := "SELECT B1.R_E_C_N_O_ NREG,  B1.B1_FILIAL, B1.B1_COD, B1.B1_DESC  FROM " + RetSqlName("SB1") + " B1 WHERE "
    cQuery += "  B1_FILIAL = '" +  SPACE(TAMSX3("B1_FILIAL")[1]) + "' AND "
    cQuery += "  ISNUMERIC(B1_COD) = 1   AND SUBSTRING(B1_COD,1,5) LIKE '[0-9]%'  AND B1_COD BETWEEN '31871' AND '99999' AND D_E_L_E_T_ <> '*'  ORDER BY B1_COD "
    MPSysOpenQuery( cQuery, 'QRYTMP' )

    DbSelectArea('SB1')
    DBSetOrder(1)


    while QRYTMP->(!eof())
        DbSelectArea('SB1')
        DBSetOrder(1)
        SB1->(DBGOTOP())
        SB1->(DBGOTO(QRYTMP->NREG))
        If SB1->(RECNO()) == QRYTMP->NREG .and. ISNUMERIC(SB1->B1_COD)
            If  VAL(SB1->B1_COD) >= 31871 .and. VAL(SB1->B1_COD) < 34901
                cFilAnt := '0101' //Caçador
            ElseIF VAL(SB1->B1_COD) >=  34901 .AND. VAL(SB1->B1_COD) <= 99999
                cFilAnt := '0102' //Canoas
            Else
                QRYTMP->(dbskip())
                loop
            Endif

            //BUSCA NA FILIAL DE DESTINO
            lFoundB1 := SB1->(MsSeek( xFilial("SB1") +  QRYTMP->B1_COD  ))
            If lFoundB1 // existe na filial de destino
                iF lAtualiz
                    RecLock("SB1",.F.)
                    SB1->B1_DESC    := QRYTMP->B1_DESC
                    MsUnLock()
                else
                    QRYTMP->(dbskip())
                    loop
                ENDIF
            Else
                SB1->(DBGOTOP())
                SB1->(DBGOTO(QRYTMP->NREG))
            Endif

            If lAjusta
                RecLock("SB1",.F.)
                SB1->B1_FILIAL := xFilial("SB1")
                MsUnLock()

                //Busca SB5
                DBselectArea("SB5")
                DBSetOrder(1) //b5_filial + b5_cod
                //verifica Já existe registro no destino
                lFoundB5  := SB5->(MsSeek( IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL] + PadR(SB1->B1_COD, TamSX3("B5_COD")[01]) ) )
                If !lFoundB5
                    lFoundB5  := SB5->(MsSeek( SPACE(TAMSX3("B5_FILIAL")[1]) + PadR(SB1->B1_COD, TamSX3("B5_COD")[01]) ) )
                    If lFoundB5
                        RecLock("SB5",.F.)
                        SB5->B5_FILIAL := IIF(nTamFilial == 2, '01',"" ) + aLinha[X_FILIAL]
                        MsUnLock()
                    Endif
                Endif
            Endif

        Endif
        QRYTMP->(dbskip())
    Enddo

    If Select("QRYTMP") > 0
        DBCloseArea("QRYTMP")
    Endif

*/

    If !Empty(cLOGERRO)
        cLOGERRO := "*** Processamento Realizado com Inconsistências encontradas  ***" + ENTER + cLOGERRO
        GeraLog(cLOGERRO)
        cLOGERRO := ""
    else
        MsgInfo("processo executado com sucesso ")
    Endif


Return



Static Function PROC_MOV(nOper)
    Local aCabec:={}
    //Local aItens:={}

    Local cErro := ""
    Local aMsg  :={}
    //Local nX	 := 0
    Local lOk   :=.t.

    Private lMsErroAuto := .F.
    Private lAutoErrNoFile := .T.

//POSIPI
    dbSelectArea('SYD')
    dbSetOrder(1)
    IF !dbSeek(xFilial('SYD')+PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] ))
        aLinha[X_POSIPI] := "00000000" //Não classificado casa não encontre o NCM no cadastro SYD
    EndIf


    If nOper=PD_ALTERAR .OR. nOper==PD_INCLUIR
        //CÓDIGO CADASTRADO COM ZEROS A ESQUERDA - TAMANHO 5 CODANT
        Aadd(aCabec,{'B1_COD'	    , PadR( aLinha[X_COD], TamSX3("B1_COD")[01] ) 		, Nil })
        //Aadd(aCabec,{'B1_COD'		, PadR( PADL(ALLTRIM(aLinha[X_COD]),5,'0'), TamSX3("B1_COD")[01] ) 		, Nil })
        Aadd(aCabec,{'B1_DESC'		, PadR( aLinha[X_DESC], TamSX3("B1_DESC")[01] ) 		, Nil })
        Aadd(aCabec,{'B1_TIPO'		, PadR( aLinha[X_TIPO], TamSX3("B1_TIPO")[01] ) 		, Nil })
        Aadd(aCabec,{'B1_UM'		, PadR( aLinha[X_UM], TamSX3("B1_UM")[01] ) 			, Nil })
        Aadd(aCabec,{'B1_GRUPO'		, PadR( aLinha[X_GRUPO], TamSX3("B1_GRUPO")[01] ) 	, Nil })
        Aadd(aCabec,{'B1_POSIPI'	, PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] ) 	, Nil })
        Aadd(aCabec,{'B1_LOCPAD'	, PadR( aLinha[X_LOCPAD], TamSX3("B1_LOCPAD")[01] ) 	, Nil })
        Aadd(aCabec,{'B1_CONTA'		, PadR( aLinha[X_CONTA], TamSX3("B1_CONTA")[01] ) 	, Nil })
        Aadd(aCabec,{'B1_ORIGEM'	, PadR( aLinha[X_ORIGEM], TamSX3("B1_ORIGEM")[01] ) 	, Nil })
        //Aadd(aCabec,{'B1_CODANT'	, PadR( aLinha[X_COD], TamSX3("B1_COD")[01] ) 		, Nil })
    END



    lMsErroAuto := .f.

    //u_LogConsole("TEDA010", "vou processar operação "+Str(nOper,1))

    If lAjusta
        MSExecAuto( { |x,y| MatA010( x, y )}, aCabec, nOper )
    Endif

    If lMsErroAuto

        aMsg := GetAutoGRLog()
        aEval(aMsg,{|x| cErro += x })

        cLOGERRO += "Execauto MATA010 erro: " + cErro + ENTER
        //u_LogConsole("TEDA010", "problemas..."+cErro)
        lOk := .F.
    end

Return {lOk,cErro}

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
        CTIPO += "Todos os arquivos   (*.*)    | *.*   | "
        cTPatch:= CGETFILE( CTIPO , "Seleção da pasta de geração da Tabela ",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
        cTPatch  := LOWER(ALLTRIM(cTPatch))


        If File(cTPatch)
            cEscolheuFile := .T.
        ELSE
            IW_MsgBox("Não foi possível localizar o arquivo",OemToAnsi("Arquivo..."),"INFO" )

        ENDIF

    Enddo
Return

/*/
    ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
    ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
    ±±ºFun‡„o    ³CopyToServerº Autor MarcioQuevedoBorgesº Data ³  03/07/11   º±±
    ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
    ±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  Copia arquivo para º±±
    ±±º          ³ o servidor e armazena os caminhos                          º±±
    ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
    ±±ºUso       ³ Programa principal                                         º±±
    ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
    ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
    ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CopyToServer()

// cDirDocs := MsDocPath() //\dirdoc\co01\shared
    //Local aArq := {}
    Local cDrive, cDir, cNome, cExt
    SplitPath( cTPatch, @cDrive, @cDir, @cNome, @cExt )  //busca dados do endereço do arquivo

    cSPatch := cDirDocs +"\"+ cNome + cExt

    //Apaga arquivo no Servidor se já exsitir.
    IF FILE(cSPatch)
        FERASE(cSPatch)
    ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o Ponteiro do Cursos do Mouse em estado de Espera	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    CursorWait()
    CpyT2S(cTPatch, cDirDocs, .T. )
    CursorArrow()	  	// Libera o Cursor

Return


/*/{Protheus.doc} CopySB1
Copia registro para a filial de destino.
@type function
@version 
@author solutio
@since 09/07/2020
@param nRegB1, numeric, param_description
@param cFilDest, character, param_description
@param cLOGERRO, character, param_description
@return return_type, return_description
/*/
Static function CopySB1(nRegB1,cFilDest, cLOGERRO)

    Local nI
    Local aRegistro     := {}
    Local NIL := 0
    Local nPosFil := 0
    Local nPosCod := 0


    IF Empty(cFilDest)
        cLOGERRO += "Filial Destino não preenchida para inclusão no SB1: " + STR(nRegB1) + CRLF
        Return
    ENDIF



    DbSelectArea("SB1")
    DBSetOrder(1)

    SB1->(DBGoTOP())
    SB1->(DBGoto(nRegB1))
    IF SB1->(Recno()) == nRegB1

        //Armazena dados chave de busca

        FOR nI := 1  to LEN(aStru)
            DO CASE
            CASE  AllTrim(aStru[nI,nPosCPO]) == 'B1_FILIAL'
                nPosFil := nI
            CASE  AllTrim(aStru[nI,nPosCPO]) == 'B1_COD'
                nPosCod := nI

            ENDCASE
            AADD(aRegistro,&("SB1->"+ aStru[nI,nPosCPO]))
        NEXT nI


        //Busca registro na filial destino
        IF !SB1->(dbSeek( cFilDest + aRegistro[nPosCod] ))
            //Cadastra se não encontrar na filial destino
            If lAjusta
                RecLock("SB1",.T.)
                FOR nI := 1  to LEN(aStru)
                    IF AllTrim(aStru[nI,nPosCPO]) == 'B1_FILIAL'
                        SB1->B1_FILIAL = cFilDest
                    ELSE
                        &('SB1->' + AllTrim(aStru[nI,nPosCPO]) + ' :=  aRegistro[nI] ' )
                    ENDIF
                NEXT nI
                MsUnLock()
            Endif



        ENDIF
    ELSE
        cLOGERRO += "Registro não localizado no SB1: " + STR(nRegB1) + CRLF
    ENDIF


Return



/*/{Protheus.doc} ExtSTR
Extrai cadeia entre a string especificada,conforme incidencia inicial. 
@type function
@version 
@author solutio
@since 09/07/2020
@param cString, character, param_description
@param cCadeia, character, param_description
@param nPos, numeric, param_description
@return return_type, return_description
/*/
Static Function ExtSTR(cString,cCadeia,nPos)
    Local cReturn   := ""
    Local nPosIni   := 0
    Local nQtdBytes := 0
    Local X
    IF cString == Nil
        cString := ""
    ENDIF

    IF cCadeia == Nil
        cCadeia := ""
    ENDIF

    IF nPos == Nil
        nPos == 1
    ENDIF

    nPosIni := ATP(cString,cCadeia,nPos)
    nPosFim := ATP(cString,cCadeia,nPos+1)


    nQtdBytes := nPosFim - ( nPosIni + 1 )
    IF nPosFim > 0
        cReturn :=  SUBSTR(cCadeia,nPosIni+1,nQtdBytes)
    ELSE
        cReturn :=  SUBSTR(cCadeia,nPosIni+1)
    ENDIF
Return cReturn

/*/{Protheus.doc} ATP
Propósito Mostra o endereço de uma string dentro de uma cadeia de caracteres na ocorrência desejada.
@type function
@version 
@author solutio
@since 09/07/2020
@param cString, character, String a ser localizada
@param cCadeia, character, cadeia de caracter 
@param nOcorr, numeric, numero da ocorrência que se deseja a posição
@return return_type, Posição da String
/*/
Static Function  ATP(cString,cCadeia,nOcorr)

    Local X := 1
    Local nReturn := 0
    Local nPosTot := 0

    IF nOcorr == Nil
        nOcorr := 1
    ENDIF

    FOR X:= 1 TO nOcorr

        nPos := AT(cString,cCadeia)
        nPosTot += nPos
        IF nPos == 0
            EXIT
        ELSEIF X == nOcorr
            nReturn := nPosTot
        ELSE
            cCadeia := Substr(cCadeia,nPos+1)
        ENDIF

    Next X

Return nReturn



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
