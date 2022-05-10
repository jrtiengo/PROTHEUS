#include 'rwmake.ch'
/*
Programa  SCIF100 Autor  Marcelo Tarasconi    Data  17/04/2020 
Descricao Rotina impressao de pacote           
*/

User Function SCIF101()

Local aArea    := GetArea()
Local aAreaNNR := NNR->(GetArea())
Local aAreaSBE := SBE->(GetArea())
Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila,lDrvWin,cPorta

Pergunte("SCIF101",.T.)

If Empty(MV_PAR01)
	Return .f.
EndIf
If !CB5->(DbSeek(xFilial("CB5")+MV_PAR01))
	Return .f.
EndIf
cModelo :=Trim(CB5->CB5_MODELO)
If CB5->CB5_TIPO == '4'
	cPorta:= "IP"
Else
	IF CB5->CB5_PORTA $ "12345"
		cPorta  :='COM'+CB5->CB5_PORTA+':'+CB5->CB5_SETSER
	EndIf
	IF CB5->CB5_LPT $ "12345"
		cPorta  :='LPT'+CB5->CB5_LPT+':'
	EndIf
EndIf

lTipo   :=CB5->CB5_TIPO $ '12'
nPortIP :=Val(CB5->CB5_PORTIP)
cServer :=Trim(CB5->CB5_SERVER)
cEnv    :=Trim(CB5->CB5_ENV)
cFila   := NIL
If CB5->CB5_TIPO=="3"
	cFila := Alltrim(Tabela("J3",CB5->CB5_FILA,.F.))
EndIf
nBuffer := CB5->CB5_BUFFER
lDrvWin := (CB5->CB5_DRVWIN =="1")
MSCBPRINTER(cModelo,cPorta,/*nDensidade*/,/*nTam*/,lTipo,nPortIP,cServer,cEnv,nBuffer,cFila,lDrvWin,Trim(CB5->CB5_PATH))
MSCBCHKSTATUS(CB5->CB5_VERSTA =="1")

//Percorrer endereços para impressão etique endereço 
dbSelectArea("NNR")
dbSetOrder(1)
If dbSeek(xFilial("NNR")+MV_PAR02,.F.)

    dbSelectArea("SBE")
    dbSetOrder(1) //fILIAL + Local + Localiz
    If dbSeek(xFilial("SBE")+NNR->NNR_CODIGO+If(!Empty(MV_PAR03),MV_PAR03,""),.F.)
    
        cChave := xFilial("SBE")+NNR->NNR_CODIGO+MV_PAR04
        While !EOF() 

            If SBE->(BE_FILIAL+BE_LOCAL+BE_LOCALIZ) > cChave
                EXIT
            EndIf

            //Impressao Etiqueta Pacote
            MSCBLOADGRF("SIGA.GRF")
            
            MSCBBEGIN(1,6)
            MSCBGRAFIC(1,3,"SIGA")
            MSCBSAY(22,03,"ENDERECO","N","A", "020,020")  //"012,008")
            MSCBSAY(22,08, AllTrim(SBE->BE_LOCAL) + ' ' + AllTrim(SBE->BE_LOCALIZ), "N", "0", "080,080") //"032,035")

            //If !Empty(SBE->BE_DESCRIC)
            //    MSCBSAY(22,10,"DESCRICAO","N","A","012,008")
            //    MSCBSAY(22,12,SBE->BE_DESCRIC,"N", "0", "020,030")
            //EndIf

            cTipoBar := 'MB07' //128
            //If !Usacb0("01")
                //If Len(AllTrim(SBE->BE_LOCAL) + AllTrim(SBE->BE_LOCALIZ)) == 8
            //        cTipoBar := 'MB03'
                //ElseIf Len(AllTrim(SBE->BE_LOCAL) + AllTrim(SBE->BE_LOCALIZ)) == 13
                //    cTipoBar := 'MB04'
                //EndIf
            //EndIf

            //MSCBSAY(01,27,"ENDEREC","N","A","012,008")
            MSCBSAYBAR(20,24,AllTrim(SBE->BE_LOCAL) + AllTrim(SBE->BE_LOCALIZ),"N",cTipoBar,15.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)

            MSCBInfoEti("Produto","50X100")
            MSCBEnd()  
            
            MSCBCLOSEPRINTER()

        SBE->(dbSkip())
        End
    
    EndIf

EndIf

RestArea(aAreaSBE)
RestArea(aAreaNNR)
RestArea(aArea)
Return()