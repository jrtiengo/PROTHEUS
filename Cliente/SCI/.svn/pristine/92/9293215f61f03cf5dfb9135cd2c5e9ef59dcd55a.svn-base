#include 'rwmake.ch'
/*
Programa  SCIF100 Autor  Marcelo Tarasconi    Data  17/04/2020 
Descricao Rotina impressao de pacote           
*/

User Function SciF100()

Local aArea    := GetArea()
Local aAreaSF1 := SF1->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSB5 := SB5->(GetArea())
Local cModelo,lTipo,nPortIP,cServer,cEnv,cFila,lDrvWin,cPorta

Pergunte("SCIF100",.T.)

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


//Percorrer a NF posicionada para impressão de etiquetas de pacotes
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),.f.)

cChave := xFilial("SD1")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
While !EOF() .and. cChave == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

    dbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1")+SD1->D1_COD,.f.)
    If !Empty(SB1->B1_IMPPAC) // == '1' //.and. !Empty(SB1->B1_SEGUM) //1=Sim
        
        //Dividir Q pela SB5 
        dbSelectArea("SB5")
        dbSetOrder(1)
        If dbSeek(xFilial("SB5")+SD1->D1_COD,.f.)
            If !Empty(&("SB5->B5_EAN14"+SB1->B1_IMPPAC)) //Campo que guarda a unidade pacote

                nQtdPacote := &("SB5->B5_EAN14"+SB1->B1_IMPPAC)
                nQtdEtique := Int ( SD1->D1_QUANT / nQtdPacote )
                
                //Impressao Etiqueta Pacote
               	MSCBLOADGRF("SIGA.GRF")
                
                For i := 1 to nQtdEtique
                
                    MSCBBEGIN(1,6)
                    MSCBGRAFIC(1,3,"SIGA")
                    MSCBSAY(22,03,"CODIGO","N","A","012,008")
                    MSCBSAY(22,05, AllTrim(SB1->B1_COD) + " PACOTE " + Alltrim(Str(&("SB5->B5_EAN14"+SB1->B1_IMPPAC))) +" UNIDADES", "N", "0", "032,035")
                    MSCBSAY(22,10,"DESCRICAO","N","A","012,008")
                    MSCBSAY(22,12,SB1->B1_DESC,"N", "0", "020,030")
                    If !Empty(SD1->D1_LOTECTL)
                        MSCBSAY(22,15,"Lote "+SD1->D1_LOTECTL /*+'-'+cSLote*/, "N", "0", "020,030")
                    EndIf

                    cTipoBar := 'MB07' //128
                    If !Usacb0("01")
                        If Len(SD1->D1_COD) == 8
                            cTipoBar := 'MB03'
                        ElseIf Len(SD1->D1_COD) == 13
                            cTipoBar := 'MB04'
                        EndIf
                    EndIf

                    MSCBSAY(01,27,"CODBAR","N","A","012,008")
                    MSCBSAYBAR(15,22,SB1->B1_IMPPAC+SB1->B1_CODBAR,"N",cTipoBar,8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)

                    If !Empty(SD1->D1_LOTECTL)
                        MSCBSAY(01,40,"LOTE","N","A","012,008")
                        MSCBSAYBAR(15,35,SD1->D1_LOTECTL,"N",cTipoBar,8.36,.F.,.T.,.F.,,2,1,.F.,.F.,"1",.T.)
                        MSCBSAY(60,37,"DT VALID","N","A","012,008")
                        MSCBSAY(60,40,DTOC(SD1->D1_DTVALID),"N", "0", "020,030")
                    EndIf

                    MSCBInfoEti("Produto","50X100")
                    MSCBEnd()  
                
                Next i

                MSCBCLOSEPRINTER()


            EndIf
        EndIf
        



    Endif
    

SD1->(dbSkip())
End


RestArea(aAreaSB5)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aAreaSB1)
RestArea(aArea)

Return()