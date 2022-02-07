#include "rwmake.ch"        
/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA007     | Microsiga Vitória | Data | 25.08.2008 |
+----------+------------+-------------------+------+------------+
|Descrição |Rotina para limpeza dos flgs contabeis              |
|          |												                |
+----------+----------------------------------------------------+
|Sintaxe   |Validação de usuário                                |
+----------+----------------------------------------------------+
|Parametros|                                                    |
+----------+----------------------------------------------------+
|Retorno   |logico                                              |
+----------+----------------------------------------------------+
|Uso       |Contabil - Sirtec                                   |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/      
User Function Stca007()        

SetPrvt("CONTEM,IND,I,CINDICE,CARQUIVO")

cPerg := Padr("STCA07", 10 , " ")  //Padr("STCA07", LEN(SX1->X1_GRUPO), " ") 
//ValPerg()

If !Pergunte(cperg,.T.)
	Return
EndIf

Processa({|| RptDetail()})
Return

Static Function RptDetail()


Contem := ""

If Mv_Par03 == 1 .or. Mv_Par03 == 5

dbSelectArea("SE1")
   Set Filter To
   cIndice  := "DtoS(SE1->E1_EMIS1)"
   cArquivo := CriaTrab(,.F.)
   IndRegua("SE1",cArquivo,cIndice,,,"Selecionando registros...")
   DbSeek(Dtos(Mv_Par01),.T.)

   ProcRegua(LastRec())

   Do While .not. eof()

      IncProc("SE1 " + Dtoc(E1_EMIS1))

      If SE1->E1_EMIS1 > Mv_Par02
         Exit
      Endif

      If RecLock("SE1",.F.) .AND. E1_FILIAL = Mv_Par04 .AND. ALLTRIM(E1_ORIGEM)="FINA040"
         SE1->E1_LA := " "
         MsUnlock()
         DbCommitAll()
      Endif

      DbSkip()
   Enddo
Endif

If Mv_Par03 == 2 .or. Mv_Par03 == 5

   dbSelectArea("SE2")
   Set Filter To
   cIndice  := "DtoS(SE2->E2_EMIS1)"
   cArquivo := CriaTrab(,.F.)
   IndRegua("SE2",cArquivo,cIndice,,,"Selecionando registros...")
   DbSeek(Dtos(Mv_Par01),.T.)

   ProcRegua(LastRec())

   Do While .not. eof()

      IncProc("SE2 " + Dtoc(E2_EMIS1))

      If SE2->E2_EMIS1 > Mv_Par02
         Exit
      Endif

      If RecLock("SE2",.F.) .AND. E2_FILIAL = Mv_Par04 .AND. ALLTRIM(E2_ORIGEM)="FINA050"
         SE2->E2_LA := " "
         MsUnlock()
         DbCommitAll()
      Endif

      DbSkip()
   Enddo
Endif   


If Mv_Par03 == 1 .or. Mv_Par03 == 2 .or. Mv_Par03 == 5 
   DbSelectArea("SE5")

   ProcRegua(LastRec())
   Ind := {1,6}

   For i := 1 to 2
      DbSetOrder(Ind[i])
      DbSeek(xFilial("SE5") + Dtos(Mv_Par01),.T.)

      Do While .not. eof()

         If Ind[i] == 1
            If SE5->E5_Data <= Mv_Par02
               IncProc("SE5 Pela Data " + Dtoc(SE5->E5_Data))
            Else
               Exit
            Endif
         Else
            If SE5->E5_Dtdispo <= Mv_Par02
               IncProc("SE5 Pela Digitacao " + Dtoc(SE5->E5_Dtdispo))
            Else
               Exit
            Endif
         Endif

         If RecLock("SE5",.F.) .AND. SE5->E5_LA<>"N" .AND. SE5->E5_FILIAL = Mv_Par04 
            SE5->E5_La := " "
            MsUnlock()
            DbCommitAll()
         Endif

         DbSkip()
      Enddo
   Next
Endif

If Mv_Par03 == 3 .or. Mv_Par03 == 5
dbSelectArea("SF2")
   Set Filter To
   cIndice  := "DtoS(SF2->F2_EMISSAO)"
   cArquivo := CriaTrab(,.F.)
   IndRegua("SF2",cArquivo,cIndice,,,"Selecionando registros...")
   DbSeek(Dtos(Mv_Par01),.T.)

   ProcRegua(LastRec())

   Do While .not. eof()

      IncProc("SF2 " + Dtoc(F2_EMISSAO))

      If SF2->F2_EMISSAO > Mv_Par02
         Exit
      Endif

      If RecLock("SF2",.F.) .AND. SF2->F2_FILIAL = Mv_Par04
         SF2->F2_DtLanc := Ctod("  /  /  ")
         MsUnlock()
         DbCommitAll()
      Endif

      DbSkip()
   Enddo
Endif

If Mv_Par03 == 4 .or. Mv_Par03 == 5
   dbSelectArea("SF1")
   Set Filter To
   cIndice  := "DtoS(SF1->F1_DTDIGIT)"
   cArquivo := CriaTrab(,.F.)
   IndRegua("SF1",cArquivo,cIndice,,,"Selecionando registros...")
   DbSeek(Dtos(Mv_Par01),.T.)

   ProcRegua(LastRec())

   Do While .not. eof()

      IncProc("SF1 " + Dtoc(F1_DTDIGIT))

      If SF1->F1_DtDigit > Mv_Par02
         Exit
      Endif

      If RecLock("SF1",.F.) .AND. SF1->F1_FILIAL = Mv_Par04
         SF1->F1_DtLanc := Ctod("  /  /  ")
         MsUnlock()
         DbCommitAll()
      Endif

      DbSkip()
   Enddo
Endif

If Mv_Par03 == 5
   dbSelectArea("SEF")
   Set Filter To
   cIndice  := "DtoS(SEF->EF_DATA)"
   cArquivo := CriaTrab(,.F.)
   IndRegua("SEF",cArquivo,cIndice,,,"Selecionando registros...")
   DbSeek(Dtos(Mv_Par01),.T.)

   ProcRegua(LastRec())

   Do While .not. eof()

      IncProc("SEF " + Dtoc(EF_DATA))

      If SEF->EF_DATA > Mv_Par02
         Exit
      Endif

      If RecLock("SEF",.F.) .AND. SEF->EF_FILIAL = Mv_Par04 .AND. SEF->EF_IMPRESS="S"
         SEF->EF_LA := " "
         MsUnlock()
         DbCommitAll()
      Endif

      DbSkip()
   Enddo
Endif

Return             

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao:  FUNCAO VALPERG()                                            ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function ValPerg()

aRegs :={}
cPerg := PADR(cPerg,10) //PADR(cPerg,len(SX1->X1_GRUPO))
aAdd(aRegs,{cPerg,"01","Data de            ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data Ate           ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Modulos            ?","","","mv_ch2","N",1,0,0,"C","","mv_par03","Receber","","","","","Pagar","","","","","Faturamento","","","","","Compras","","","","","Todos","","","","",""})
aAdd(aRegs,{cPerg,"04","Filial             ?","","","mv_ch2","C",2,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","SMO"})

/*
dbSelectArea("SX1")
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
*/

Return   


