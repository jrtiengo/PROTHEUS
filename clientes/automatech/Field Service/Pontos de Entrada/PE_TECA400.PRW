#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPE_TECA400บAutor  ณLucas Moresco       บ Data ณ  12/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ PE na gravacao do Orcamento                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAT400GRV  บAutor  ณLucas Moresco       บ Data ณ  12/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as informacoes de comentario do Orc. para a O.S    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function AT400GRV()

   Local _aAreaAB3 := AB3->(GetArea()) 
   Local _aAreaAB4 := AB4->(GetArea()) 
   Local _aAreaAB7 := AB7->(GetArea()) 
   Local _aAreaAB6 := AB6->(GetArea())
   Local _cItem    := ""
   Local _cMemo    := ""
   Local _cMemoAB7 := ""
   Local _cEtique  := ""
   Local _cNumOS   := "" 
   Local _Filial   := AB3->AB3_FILIAL
                           
   If FunName() == "TECA400"

      If INCLUI
	     MSMM(,78,,M->AB3_MEMO6,1,,,"AB3","AB3_MEMO5") 
      ElseIf ALTERA
	     MSMM(,78,,M->AB3_MEMO6,1,,,"AB3","AB3_MEMO5")
      EndIf
	 
      For _ix:= 1 to Len(acols)
     
	      _cItem := SubStr(AB4->AB4_NUMORC,1,6)+acols[_ix][1]
	  
	      DbSelectArea("AB4")
          DbSetOrder(1)
      
          If DbSeek(xFilial("AB4")+_cItem)
      	     _cMemo := (AB4->AB4_MEMO)
          EndIf
	
   	      DbSelectArea("AB7")
          DbSetOrder(3)
	
	      If DbSeek(xFilial("AB7")+_cItem)
		     _cMemoAB7:= MSMM(_cMemo)
		     MSMM(,TamSx3("AB7_MEMO2")[1],,_cMemoAB7,1,,,"AB7","AB7_MEMO")
		     _cNumOS := AB7->AB7_NUMOS
	      EndIf

      Next	
   
      DbSelectArea("AB3")
      DbSetOrder(1)
    
      If DbSeek(xFilial("AB3")+AB4->AB4_NUMORC)
 	     _cEtique := AB3->AB3_ETIQUE
 	    
         // Altera a flag para utilizacao da legenda.
		 If (AB3->AB3_STATUS == "E")
			RecLock("AB3",.F.)
		    AB3->AB3_APROV := "E"
			MsUnlock()
		 EndIf   
      EndIf
	
      If !Empty(Alltrim(_cNumOS))
 	     Dbselectarea("AB6")
	     DbSetOrder(1) 
	     If dbSeek (xFilial("AB6")+_cNumOS)
	 	    RecLock("AB6",.F.)
		    AB6->AB6_ETIQUE := _cEtique
//		    AB6->AB6_MEMO5	 := MSMM(,78,,M->AB3_MEMO6,1,,,"AB6","AB6_MEMO5")
//		    AB6->AB6_MEMO7	 := MSMM(,78,,M->AB3_LAUDO,1,,,"AB6","AB6_MEMO7")
            AB6->AB6_NFENT  := M->AB3_NFENT
            AB6->AB6_RLAUDO := M->AB3_RLAUDO
 		    MsUnlock()
	     EndIf     
	
	     Dbselectarea("AB9")
	     DbSetOrder(1) 
	     If dbSeek (xFilial("AB9")+_cNumOS)
//	 	    RecLock("AB9",.F.)
//		    AB9->AB9_MEMO1	:= MSMM(,78,,M->AB3_MEMO6,1,,,"AB6","AB6_MEMO5")
//		    AB9->AB9_MEMO3	:= MSMM(,78,,M->AB3_LAUDO,1,,,"AB6","AB6_MEMO7")
//		    AB9->AB9_MEMO5	:= MSMM(,78,,M->AB3_LAUDO,1,,,"AB6","AB6_MEMO7")
//		    MsUnlock()                           ฑ
	     EndIf	
	  Endif   

      If ((Altera) .And. (AB3->AB3_STATUS == "A") .And. (AB3->AB3_APROV <> "S"))

	     If (MsgYesNo("Deseja enviar o or็amento para o cliente?"))
	
	        // Programa responsavel pelo envio de email (Workflow)ณ
		    u_AUTA012()
	
  	     EndIf
      EndIf

      // Atualiza a tabela de log
      dbSelectArea("ZS1")
      RecLock("ZS1",.T.)
      ZS1_FILIAL := _FILIAL
      ZS1_TECN   := Alltrim(cUserName)
      ZS1_DATA   := DATE()
      ZS1_HORA   := TIME()
      ZS1_OPER   := IIF(INCLUI, "I", "A")
      ZS1_TIPO   := "O"
      ZS1_ETIQ   := AB3->AB3_ETIQUE
      ZS1_NUMOS  := AB3->AB3_NUMORC
      MsUnLock()

   EndIf		

   RestArea(_aAreaAB3) 
   RestArea(_aAreaAB6)	
   RestArea(_aAreaAB7)
   RestArea(_aAreaAB4)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAT400LGD  บAutor  ณLucas Moresco       บ Data ณ  01/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona Legenda (Orcamento Aprovador). Situacao ocorre    บฑฑ
ฑฑบ          ณ quando ocorre a resposta do workflow do cliente.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AT400LGD()

   Local aCores := PARAMIXB

   aAdd(aCores,{'BR_AZUL','Or็amento Aprovado'}) 
   aAdd(aCores,{'BR_AMARELO','Or็amento Reprovado'}) 

Return(aCores)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAT400COR  บAutor  ณLucas Moresco       บ Data ณ  01/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona o novo status ao Browse da visualizacao do orc.   บฑฑ
ฑฑบ          ณ Utilizado devido ao status da resposta do workflow.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Automatech                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AT400COR()

   Local aCores := PARAMIXB
   Local _ix	 := ""
                                               
   For _ix:= 1 to Len(aCores)
       If (aCores[_ix][2] == 'ENABLE')
	      aCores[_ix][1] := aCores[_ix][1]+' .And. AB3_APROV == "A" '
   	   ElseIf (aCores[_ix][2] == 'DISABLE')
		  aCores[_ix][1] := aCores[_ix][1]+' .And. AB3_APROV == "E" '
	   Endif	
   Next	

   Aadd(aCores,{" AB3_STATUS == 'A' .And. AB3_APROV == 'S' ", "BR_AZUL"})
   Aadd(aCores,{" AB3_STATUS == 'A' .And. AB3_APROV == 'N' ", "BR_AMARELO"})

Return(aCores)