#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "ap5mail.ch"

#define ENTER Chr(13)+Chr(10)
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5


/*/{Protheus.doc} BACAB9
Rotina de Importa็ใo de Saldos Iniciais (SB9) customizada para Primo Tedesco, conforme regras especํficas
@type function
@version 
@author solutio
@since 08/07/2020
@return return_type, return_description
/*/
User Function BACAB9()
    Local x_cFilAnt := cFilAnt

    Private lAjusta := .T. // Executa altera็๕es
    Private cLOGERRO := ""
    Private lCabErro := .F. //jแ colocou cabe็alho do erro


    //------ tab temporaria
    Private oTempTable
    Private cLoadB1	:= GetNextAlias() //Alias Tabela Temporแria

//Private ENTER  := CHR(13)+ CHR(10)
    //B9_FILIAL;B9_COD;B9_LOCAL;B9_DATA;B9_QINI;B9_VINI1;B9_MCUSTD;B9_CM1

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


    //B9_FILIAL	B9_COD	B9_LOCAL	B9_QINI	B9_VINI1	B9_CM1

    PRIVATE Y_FILIAL    := 1 //B9_FILIAL
    PRIVATE Y_COD       := 2 //B9_COD
    PRIVATE Y_LOCAL     := 3 //B9_LOCAL
    PRIVATE Y_QINI      := 4 //B9_QINI
    PRIVATE Y_VINI1     := 5//B9_VINI1
    PRIVATE Y_CM1       := 6 //B9_CM1
    PRIVATE Y_MCUSTD    := 7 //B9_MCUSTD
    PRIVATE Y_DATA      := 8 //B9_DATA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


    Private oLeTxt
    Private nTamFile
    Private aDePara := {}
//Private aArquivo := {}

//Acumuladores


    //Private cTrab
    Private cDirDocs := MsDocPath() //"\dirdoc\co01\shared"
    Private cSPatch := "" //Patch do Servidor - Full
    Private cTPatch := "" //Patch do Terminal - Full
    Private cTSB1Patch := "" //Patch do Terminal - Full  arquivo SB1



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
    //AADD(aDePara,{'25752','30123'}) // De-para cancelado em 03/08/2020 por Jerri. Nใo deveria ter sido realizado
    //AADD(aDePara,{'25753','30125'}) // De-para cancelado em 03/08/2020 por Jerri. Nใo deveria ter sido realizado
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
    AADD(aDePara,{'27996','30181'}) //LAMINA LARGA P/ ESTILETE S06R                                                                       
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


    DbSelectArea("SB9") // sx2_unico :
    DBSetOrder(1) // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da tela de processamento.                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

    @ 200,1 TO 380,380 DIALOG oLeTxt TITLE OemToAnsi("Primo Tedesco - Importa็ใo Saldos Iniciais - SB9")
    @ 02,10 TO 080,190
    @ 10,018 Say " Este programa le o arquivo formato previamente definido (MILE)"
    @ 18,018 Say " conforme necessidades especํficas da Primo Tedesco para carga "
    @ 26,018 Say " do SB9. Clique em Parโmetros para carregar o Arquivo Refer๊ncia."

    @ 60,078 BMPBUTTON TYPE 01 ACTION OkLeTxt()
    @ 60,108 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)
    @ 60,138 BMPBUTTON TYPE 05 ACTION Arquivo()

    Activate Dialog oLeTxt Centered

    cFilAnt := x_cFilAnt

    If Select(cLoadB1) > 0
        //oTempTable:Delete()
        (cLoadB1)->(DBCloseArea())
    EndIf
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
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Abertura do arquivo texto                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู



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




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a regua de processamento                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
    If  Select(cLoadB1) <= 0
        Processa({|| LoadB1() },"Carregando Produtos...")
    Endif
    */

    Processa({|| CopyToServer()},"Copiando Arquivo para o Servidor...")

    IF MSGYESNO("Deseja Validar o Arquivo antes de processar?")
        Processa({|| VldArq(@lValidArq)},"Validando arquivo...")
        IF  !lValidArq
            cLOGERRO := "*** Processamento Cancelado - Inconsist๊ncias encontradas no arquivo ***" + ENTER + cLOGERRO
            GeraLog(cLOGERRO)
            cLOGERRO := ""

            IF !MSGYESNO("Foi identificado inconsist๊ncias, deseja Proceguir com a importa็ใo mesmo assim?")
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

Static Function LoadB1()
    Local   aTemp 	:= {}
    Local cChave
    Local aTamSx3

/*
 aLinha[X_COD]       := PadR( aLinha[X_COD], TamSX3("B1_COD")[01] )
        aLinha[X_TIPO]      := PadR( aLinha[X_TIPO], TamSX3("B1_TIPO")[01] )
        aLinha[X_UM]        := PadR( aLinha[X_UM], TamSX3("B1_UM")[01] )
        aLinha[X_GRUPO]     := PadR( aLinha[X_GRUPO], TamSX3("B1_GRUPO")[01] )
        aLinha[X_POSIPI]    := PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] )
        aLinha[X_LOCPAD]    := PadR( aLinha[X_LOCPAD], TamSX3("B1_LOCPAD")[01] )
        aLinha[X_CONTA]     := PadR( aLinha[X_CONTA], TamSX3("B1_CONTA")[01] )
        aLinha[X_ORIGEM]    := PadR( aLinha[X_ORIGEM], TamSX3("B1_ORIGEM")[01] )
*/
    aTamSx3 := TamSX3("B1_FILIAL" )
    AADD(aTemp,{ "B1_FILIAL"   , "C" ,04, 0 })
    aTamSx3 := TamSX3("B1_COD" )
    AADD(aTemp,{ "B1_COD"      , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_DESC" )
    AADD(aTemp,{ "B1_DESC"      , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_TIPO" )
    AADD(aTemp,{ "B1_TIPO"     , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_UM" )
    AADD(aTemp,{ "B1_UM"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_GRUPO" )
    AADD(aTemp,{ "B1_GRUPO"    , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_POSIPI" )
    AADD(aTemp,{ "B1_POSIPI"   , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_LOCPAD" )
    AADD(aTemp,{ "B1_LOCPAD"   , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_CONTA" )
    AADD(aTemp,{ "B1_CONTA"   , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
    aTamSx3 := TamSX3("B1_ORIGEM" )
    AADD(aTemp,{ "B1_ORIGEM"   , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

    //-------------------
    //Cria็ใo do objeto
    //-------------------
    //oTempTable := FWTemporaryTable():New( cAlias )

    oTempTable := FWTemporaryTable():New( cLoadB1, aTemp )
    oTempTable:AddIndex("01", {"B1_FILIAL","B1_COD"} )

    oTempTable := FWTemporaryTable():New( cLoadB1, aTemp )
    oTempTable:AddIndex("02", {"B1_FILIAL","B1_TIPO","B1_COD"} )


    //------------------
    //Cria็ใo da tabela
    //------------------
    oTempTable:Create()


    nHandle := FT_FUSE(cTSB1Patch)
    if nHandle = -1
        MSGAlert("Erro abertura arquivo")
        lValidArq := .F.
        return
    endif

    nTamFile := FT_FLastRec()
    ProcRegua(nTamFile)

    FT_FGOTOP()
    While !FT_FEOF()


        IncProc("Carregando SB1 ")

        cLinha := FT_FREADLN()


        aLinha:= StrTokArr( cLinha , ";" )
        //AJUSTA REGISTROS PARA LAYOUT
        RecLock(cLoadB1,.T.) // Cria Registro
        (cLoadB1)->B1_FILIAL    :=  "01"+ aLinha[X_FILIAL]  // PadR( "01"+ aLinha[X_FILIAL], TamSX3("B1_FILIAL")[01] )
        (cLoadB1)->B1_COD       := PadR( aLinha[X_COD], TamSX3("B1_COD")[01] )
        (cLoadB1)->B1_DESC      := PadR( aLinha[X_DESC], TamSX3("B1_DESC")[01] )
        (cLoadB1)->B1_TIPO      := PadR( aLinha[X_TIPO], TamSX3("B1_TIPO")[01] )
        (cLoadB1)->B1_UM        := PadR( aLinha[X_UM], TamSX3("B1_UM")[01] )
        (cLoadB1)->B1_GRUPO     := PadR( aLinha[X_GRUPO], TamSX3("B1_GRUPO")[01] )
        (cLoadB1)->B1_POSIPI    := PadR( aLinha[X_POSIPI], TamSX3("B1_POSIPI")[01] )
        (cLoadB1)->B1_LOCPAD    := PadR( aLinha[X_LOCPAD], TamSX3("B1_LOCPAD")[01] )
        (cLoadB1)->B1_CONTA     := PadR( aLinha[X_CONTA], TamSX3("B1_CONTA")[01] )
        (cLoadB1)->B1_ORIGEM    := PadR( aLinha[X_ORIGEM], TamSX3("B1_ORIGEM")[01] )
        MSUnLock()

//dbSetOrder(RetOrd("MULTA")) //MULTA
        FT_FSKIP()
    EndDo
    FT_FUSE()


Return


/*/{Protheus.doc} VldArq
Valida arquivo escolhido
@type function
@version 
@author solutio
@since 21/07/2020
@param lValidArq, logical, param_description
@return return_type, return_description
/*/
Static Function VldArq(lValidArq)

    Local nHandle

    Local lLinErro

//Variแveis da EStrutura da Tabela
    // Private aStru   := SB9->(DBSTRUCT())
    Private nPosCPO := 1
    Private aLinha  := {}
    Private nLinha  := 0
    Private cLinha  := ""


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
        lLinErro := .F.
        nLinha++
        IncProc("Analisando Linha " + STR(nLinha))

        cLinha := FT_FREADLN()

        aLinha:= StrTokArr( cLinha , ";" )

        /*
        //B9_FILIAL	B9_COD	B9_LOCAL	B9_QINI	B9_VINI1	B9_CM1

        PRIVATE Y_FILIAL    := 1 //B9_FILIAL
        PRIVATE Y_COD       := 2 //B9_COD
        PRIVATE Y_LOCAL     := 3 //B9_LOCAL
        PRIVATE Y_QINI      := 4 //B9_QINI
        PRIVATE Y_VINI1     := 5 //B9_VINI1
        PRIVATE Y_CM1       := 6 //B9_CM1

        PRIVATE Y_MCUSTD    := 7 //B9_MCUSTD
        PRIVATE Y_DATA      := 8 //B9_DATA

        */

        //de-para Canoas
        If aLinha[Y_FILIAL] == '02' .or. aLinha[Y_FILIAL] == '0102'
            nPos:=Ascan(aDePara, { |x| x[1] == AllTrim(aLinha[Y_COD]) })
            If nPos > 0
                aLinha[Y_COD] := PadR(aDePara[nPos][2], TamSX3("B9_COD")[01] )
            Endif
        Endif

        IF  SUBSTR(AllTrim(aLinha[Y_COD]),-4) == 'MIOL' // Se for produtos final miolo trunca
            aLinha[Y_COD] := SUBSTR(aLinha[Y_COD],1,11)
        ENDIF

        //AJUSTA REGISTROS PARA LAYOUT
        aLinha[Y_COD]      := PadR( aLinha[Y_COD], TamSX3("B9_COD")[01] )
        aLinha[Y_LOCAL]    := PadR( aLinha[Y_LOCAL], TamSX3("B9_LOCAL")[01] )
        aLinha[Y_QINI]     := Val(AllTrim(aLinha[Y_QINI]))
        aLinha[Y_VINI1]    := Val(AllTrim(aLinha[Y_VINI1]))
        aLinha[Y_CM1]      := IIF( aLinha[Y_QINI] == 0, 0 ,  aLinha[Y_VINI1]/aLinha[Y_QINI] )


        nTamFilial := LEN(aLinha[Y_FILIAL])
        IF nTamFilial == 2
            cFilAnt := "01" + aLinha[Y_FILIAL] // Altera a Filial do registro
        ELSE
            cFilAnt :=  aLinha[Y_FILIAL]
        ENDIF

        // Busca cadastro de produtos
        DBSelectArea("SB1")
        SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
        SB1->(DBGotop())
        lFound  := SB1->(MsSeek(  xFilial("SB1") + aLinha[Y_COD] ))

        //busca listagem importa็ใo produtos
        If !lFound
            
            cQuery :=  "SELECT * FROM SB1IMPORT WHERE B1_FILIAL = '" + aLinha[Y_FILIAL] + "' AND B1_COD = '" + aLinha[Y_COD] + "' AND D_E_L_E_T_ <> '*' "
            MPSysOpenQuery( cQuery, cLoadB1 )
            //DBSelectArea(cLoadB1)
            //DBSetOrder(1)
            cChave:= IIF(nTamFilial == 4, aLinha[Y_FILIAL], SUBSTR(aLinha[Y_FILIAL],3,2) ) + aLinha[Y_COD]
            //lFound  := (cLoadB1)->(MsSeek( cChave))
            //IF lFound
            IF !Empty((cLoadB1)->B1_COD)
                PROC_MOV(PD_INCLUIR) //desenvolver
                cLOGERRO += "==> Produto criado: Filial;Cod; " + aLinha[Y_FILIAL] + ";" + aLinha[Y_COD] + ENTER
            Endif
        // Busca cadastro de produtos ap๓s cria็ใo
            DBSelectArea("SB1")
            SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
            SB1->(DBGotop())
            lFound  := SB1->(MsSeek(  xFilial("SB1") + aLinha[Y_COD] ))


        Endif
        If !lFound
            lValidArq := .F.
            If !lCabErro
                cLOGERRO += "*** Erro Valida็ใo Arquivo " + cTPatch + " *** " + ENTER
                cLOGERRO += "----------------------------------------------------------------------- " + ENTER
                lCabErro := .T.
            Endif
            If !lLinErro
                cLOGERRO += "----------------------------------------------------------------------- " + ENTER
                cLOGERRO += "Linha: " + AllTrim(STR(nLinha)) + " - Registro: " + cLinha  + ENTER
                lLinErro := .T.
            Endif
            cLOGERRO += " Produto nใo localizado: " + aLinha[Y_COD] + ENTER
        Endif

        //LOCPAD
        dbSelectArea('NNR')
        dbSetOrder(1)

        lFound  := NNR->(MsSeek( xFilial('NNR')+PadR( aLinha[Y_LOCAL], TamSX3("B1_LOCPAD")[01] ) ))
        If !lFound
            lValidArq := .F.
            If !lCabErro
                cLOGERRO += "*** Erro Valida็ใo Arquivo " + cTPatch + " *** " + ENTER
                cLOGERRO += "----------------------------------------------------------------------- " + ENTER
                lCabErro := .T.
            Endif
            If !lLinErro
                cLOGERRO += "----------------------------------------------------------------------- " + ENTER
                cLOGERRO += "Linha: " + AllTrim(STR(nLinha)) + " - Registro: " + cLinha  + ENTER
                lLinErro := .T.
            Endif
            cLOGERRO += " Local Padrใo nใo localilzado: " + aLinha[Y_LOCAL] + ENTER
        Endif

        FT_FSKIP()
    EndDo
    FT_FUSE()

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
    IF !dbSeek(xFilial('SYD')+ PadR( (cLoadB1)->B1_POSIPI, TamSX3("B1_POSIPI")[01] ))
        aLinha[X_POSIPI] := "00000000" //Nใo classificado casa nใo encontre o NCM no cadastro SYD
    EndIf


    If nOper=PD_ALTERAR .OR. nOper==PD_INCLUIR
        //CำDIGO CADASTRADO COM ZEROS A ESQUERDA - TAMANHO 5 CODANT
        Aadd(aCabec,{'B1_COD'	    , (cLoadB1)->B1_COD		, Nil })
        //Aadd(aCabec,{'B1_COD'		, PadR( PADL(ALLTRIM(aLinha[X_COD]),5,'0'), TamSX3("B1_COD")[01] ) 		, Nil })
        Aadd(aCabec,{'B1_DESC'		, (cLoadB1)->B1_DESC	, Nil })
        Aadd(aCabec,{'B1_TIPO'		, (cLoadB1)->B1_TIPO	, Nil })
        Aadd(aCabec,{'B1_UM'		, (cLoadB1)->B1_UM		, Nil })
        Aadd(aCabec,{'B1_GRUPO'		, (cLoadB1)->B1_GRUPO	, Nil })
        Aadd(aCabec,{'B1_POSIPI'	, (cLoadB1)->B1_POSIPI	, Nil })
        Aadd(aCabec,{'B1_LOCPAD'	, (cLoadB1)->B1_LOCPAD	, Nil })
        Aadd(aCabec,{'B1_CONTA'		, (cLoadB1)->B1_CONTA	, Nil })
        Aadd(aCabec,{'B1_ORIGEM'	, (cLoadB1)->B1_ORIGEM	, Nil })
        //Aadd(aCabec,{'B1_CODANT'	, PadR( aLinha[X_COD], TamSX3("B1_COD")[01] ) 		, Nil })
    END



    lMsErroAuto := .f.

    //u_LogConsole("TEDA010", "vou processar opera็ใo "+Str(nOper,1))

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


/*/{Protheus.doc} RunCont
Funcao auxiliar chamada pela PROCESSA para adicionar registros
@type function
@version 
@author solutio
@since 09/07/2020
@return return_type, return_description
/*/
Static Function RunCont()
    Local nPos, cChave
    Local nTamFilial := 2
    //Local  nTamLin, cBuffer, nBtLidos
    //Local cQuery := ""

    Local lFound



//Variแveis da EStrutura da Tabela
    //Private aStru   := SB9->(DBSTRUCT())
    Private nPosCPO := 1
    Private aLinha  := {}
    Private nLinha  := 0
    Private cLinha  := ""

        /*
        //B9_FILIAL	B9_COD	B9_LOCAL	B9_QINI	B9_VINI1	B9_CM1

        PRIVATE Y_FILIAL    := 1 //B9_FILIAL
        PRIVATE Y_COD       := 2 //B9_COD
        PRIVATE Y_LOCAL     := 3 //B9_LOCAL
        PRIVATE Y_QINI      := 4 //B9_QINI
        PRIVATE Y_VINI1     := 5 //B9_VINI1
        PRIVATE Y_CM1       := 6 //B9_CM1

        PRIVATE Y_MCUSTD    := 7 //B9_MCUSTD
        PRIVATE Y_DATA      := 8 //B9_DATA

        */





// Leitura de Arquivo
//LeArquivo()
//Gera็ใo arquivo temporแrio
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

        IF ALLTRIM( aLinha[Y_COD]) == '27996'
            LDEBUG := .T.
        ENDIF

        //AJUSTA REGISTROS PARA LAYOUT
        aLinha[Y_COD]      := PadR( aLinha[Y_COD], TamSX3("B9_COD")[01] )
        aLinha[Y_LOCAL]    := PadR( aLinha[Y_LOCAL], TamSX3("B9_LOCAL")[01] )
        aLinha[Y_QINI]     := Val(AllTrim(aLinha[Y_QINI]))
        aLinha[Y_VINI1]    := Val(AllTrim(aLinha[Y_VINI1]))
        aLinha[Y_CM1]      := IIF( aLinha[Y_QINI] == 0, 0 ,  aLinha[Y_VINI1]/aLinha[Y_QINI] )

        nTamFilial := LEN(aLinha[Y_FILIAL])
        IF nTamFilial == 2
            cFilAnt := "01" + aLinha[Y_FILIAL] // Altera a Filial do registro
        ELSE
            cFilAnt :=  aLinha[Y_FILIAL]
        ENDIF

        //de-para Canoas
        If aLinha[Y_FILIAL] == '02' .or. aLinha[Y_FILIAL] == '0102'
            nPos:=Ascan(aDePara, { |x| x[1] == AllTrim(aLinha[Y_COD]) })
            If nPos > 0
                aLinha[Y_COD] := PadR(aDePara[nPos][2], TamSX3("B9_COD")[01] )
            Endif
        Endif

        IF  SUBSTR(AllTrim(aLinha[Y_COD]),-4) == 'MIOL' // Se for produtos final miolo trunca
            aLinha[Y_COD] := SUBSTR(aLinha[Y_COD],1,11)
        ENDIF

        //----------------

        //******** busca produto sb1 e cria se precisar 

// Busca cadastro de produtos
        DBSelectArea("SB1")
        SB1->(DBSetOrder(1)) //B1_FILIAL+B1_COD
        SB1->(DBGotop())
        lFound  := SB1->(MsSeek(  xFilial("SB1") + aLinha[Y_COD] ))

        //busca listagem importa็ใo produtos
        If !lFound
            cQuery :=  "SELECT * FROM SB1IMPORT WHERE B1_FILIAL = '" + aLinha[Y_FILIAL] + "' AND B1_COD = '" + aLinha[Y_COD] + "' AND D_E_L_E_T_ <> '*' "
            MPSysOpenQuery( cQuery, cLoadB1 )
            //DBSelectArea(cLoadB1)
            //DBSetOrder(1)
            //cChave:= IIF(nTamFilial == 2, aLinha[Y_FILIAL], SUBSTR(aLinha[Y_FILIAL],3,2) ) + aLinha[Y_COD]
            //lFound  := (cLoadB1)->(MsSeek( cChave))
            //IF lFound
            IF !Empty((cLoadB1)->B1_COD)
                //PROC_MOV(PD_INCLUIR) //desenvolver
            Endif
        Endif
        //********************

        DbSelectArea("SB9") // sx2_unico :
        DBSetOrder(1) // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)


        cChave := IIF(nTamFilial == 2, '01',"" ) + aLinha[Y_FILIAL] + aLinha[Y_COD] + aLinha[Y_LOCAL] +  '20191231'
        lFound := SB9->(MsSeek( cChave ))
        If !lFound
            cChave := IIF(nTamFilial == 2, '01',"" ) + aLinha[Y_FILIAL] + aLinha[Y_COD] + aLinha[Y_LOCAL] +  Space(8)
            lFound := SB9->(MsSeek( cChave ))
        Endif

        If lFound // existe na filial de destino
            If lAjusta
                RecLock("SB9",.F.)
                SB9->B9_DATA    := STOD("20191231")
                SB9->B9_QINI    := aLinha[Y_QINI]
                SB9->B9_VINI1   := aLinha[Y_VINI1]
                SB9->B9_CM1     := aLinha[Y_CM1]
                SB9->B9_MCUSTD  := '1'                
                MsUnLock()
            Endif
        ELSE
            //Cria Item
            If lAjusta
                RecLock("SB9",.T.)
                SB9->B9_FILIAL  := xFilial("SB9")
                SB9->B9_COD     := aLinha[Y_COD]
                SB9->B9_LOCAL   := aLinha[Y_LOCAL]
                SB9->B9_DATA    := STOD("20191231")
                SB9->B9_QINI    := aLinha[Y_QINI]
                SB9->B9_VINI1   := aLinha[Y_VINI1]
                SB9->B9_CM1     := aLinha[Y_CM1]
                SB9->B9_MCUSTD  := '1'                
                MsUnLock()
            Endif
        ENDIF

        FT_FSKIP()
    EndDo
    FT_FUSE()
//Executa Alteracoes

/*
//Verifica todos os cadastros de Produtos que nใo existem c๓digos de saldo inicial (mesmo que zerado)
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
                cFilAnt := '0101' //Ca็ador
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
                //verifica Jแ existe registro no destino
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
        cLOGERRO := "*** Processamento Realizado com Inconsist๊ncias encontradas  ***" + ENTER + cLOGERRO
        GeraLog(cLOGERRO)
        cLOGERRO := ""
    else
        MsgInfo("processo executado com sucesso ")
    Endif


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

/*
    WHILE !cEscolheuFile

        CTIPO := " "
        CTIPO += "Todos os arquivos   (*.*)    | *.*   | "
        cTSB1Patch:= CGETFILE( CTIPO , "Selecione Arquivo de SB1 referencia ",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
        cTSB1Patch  := LOWER(ALLTRIM(cTSB1Patch))


        If File(cTSB1Patch)
            cEscolheuFile := .T.
        ELSE
            IW_MsgBox("Nใo foi possํvel localizar o arquivo",OemToAnsi("Arquivo..."),"INFO" )

        ENDIF

    Enddo
    */

    cEscolheuFile := .F.

    WHILE !cEscolheuFile

        CTIPO := " "
        CTIPO += "Todos os arquivos   (*.*)    | *.*   | "
        cTPatch:= CGETFILE( CTIPO , "Selecione Arquivo de SB9 referencia ",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
        cTPatch  := LOWER(ALLTRIM(cTPatch))


        If File(cTPatch)
            cEscolheuFile := .T.
        ELSE
            IW_MsgBox("Nใo foi possํvel localizar o arquivo",OemToAnsi("Arquivo..."),"INFO" )

        ENDIF

    Enddo

Return

/*/
    ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
    ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
    ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
    ฑฑบFuno    ณCopyToServerบ Autor MarcioQuevedoBorgesบ Data ณ  03/07/11   บฑฑ
    ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
    ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  Copia arquivo para บฑฑ
    ฑฑบ          ณ o servidor e armazena os caminhos                          บฑฑ
    ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
    ฑฑบUso       ณ Programa principal                                         บฑฑ
    ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
    ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
    ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function CopyToServer()

// cDirDocs := MsDocPath() //\dirdoc\co01\shared
    //Local aArq := {}
    Local cDrive, cDir, cNome, cExt
    SplitPath( cTPatch, @cDrive, @cDir, @cNome, @cExt )  //busca dados do endere็o do arquivo

    cSPatch := cDirDocs +"\"+ cNome + cExt

    //Apaga arquivo no Servidor se jแ exsitir.
    IF FILE(cSPatch)
        FERASE(cSPatch)
    ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColoca o Ponteiro do Cursos do Mouse em estado de Espera	   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    CursorWait()
    CpyT2S(cTPatch, cDirDocs, .T. )
    CursorArrow()	  	// Libera o Cursor

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraLog   บAutor  ณMแrcio.Borges   บ Data ณ      05/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraLog( cLogTxt )
    *********************************************************************
    __cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

    Define FONT oFont NAME "Tahoma" Size 6,12
    Define MsDialog oDlgMemo Title "Consist๊ncia dos Dados" From 3,0 to 340,550 Pixel

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
