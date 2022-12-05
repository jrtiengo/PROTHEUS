#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#INCLUDE "Protheus.ch"                                
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2
#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // M�ximo de produtos para a primeira p�gina
#DEFINE MAXITEMP2  049                                                // M�ximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // M�ximo de produtos para a p�gina 2 em diante quando a p�gina n�o possui informa��es complementares
#DEFINE MAXITEMP3  025                                                // M�ximo de produtos para a pagina 2 em diante (caso utilize a op��o de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   018                                                // M�xima de caracteres por linha de produtos/servi�os
#DEFINE MAXMENLIN  080                                                // M�ximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // M�ximo de dados adicionais por p�gina
#DEFINE MAXVALORC  008                                                // M�ximo de caracteres por linha de valores num�ricos

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � RPdfDanfe � Autor � Iranildo Cavalcante � Data � 25/04/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gerar e Enviar e-mail do PDF da Danfe da Nf-e              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico COGERH                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
/*/
User Function RPdfDanfe()

   Private oDanfe      
   Private nConsNeg := 0.4 // Constante para concertar o c�lculo retornado pelo GetTextWidth para fontes em negrito.
   Private nConsTex := 0.5 // Constante para concertar o c�lculo retornado pelo GetTextWidth.

   // Gera Log De Servico
//   ConOut("INICIO DO PROCESSAMENTO DE EMAILS DA DANFE :" + DtoC(Msdate()) + " Hora: " + Time())

   // Inicializa a environment para execucao do schedule
// PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO 'FATURAMENTO' FUNNAME 'RPDF' TABLES "SF2","SF3"

   dbSelectArea("SF3")
   DbSetOrder(6)
   DbSeek("01" + "081186   " + "1  ")

//   cIndexName	:= Criatrab(Nil,.F.)
//   cIndexKey	:= "F3_NFISCAL+F3_CLIEFOR"            
//   cFilter		:= "F3_FILIAL=='"+xFilial("SF3")+"' .And. "
//   cFilter		+= "F3_CODRSEF='100'                .And. F3_CHVNFE <>' '             .And."
//   cFilter		+= "F3_YDANFE<>'S' 					.And. F3_CFO >= '5000' "

//   IndRegua("SF3", cIndexName, cIndexKey,, cFilter, Nil)

//   dbSelectArea("SF3")
//   dbGoTop()

   oFont1 := TFont():New( "Courier New", , -18, .T.)

   While !EOF()     

      MV_PAR01 := SF3->F3_NFISCAL
	  MV_PAR02 := SF3->F3_NFISCAL
	  MV_PAR03 := '1  '
	  MV_PAR04 := 2
	  MV_PAR05 := 2
	
	  //���������������������������������������Ŀ
	  //� Posiciona o SA1 (Cliente)             �
	  //�����������������������������������������	
	  DbSelectArea("SA1")
	  DbSetOrder(1)
	  DbSeek(xFilial()+SF3->F3_CLIEFOR+SF3->F3_LOJA,.T.)
		
	  DbSelectArea("SF3")
    
	  if Alltrim(SA1->A1_EMAIL) <> "" // Se tiver cadastrado o e-mail do Cliente. 
		 If oDanfe == Nil
		    lPreview := .T.
		    oDanfe   := FWMSPrinter():New('Danfe_' + Alltrim(SF3->F3_NFISCAL),6,.F.,,.T.)
		    oDanfe:SetPortrait()
		    oDanfe:SetPaperSize(9)
		    oDanfe:SetMargin(60,60,60,60)
		    oDanfe:cPathPDF := "C:\DANFE\"       
		    oDanfe:SetViewPDF(.F.)
		 EndIf       
	
		 Private PixelX := oDanfe:nLogPixelX()
		 Private PixelY := oDanfe:nLogPixelY()
	
	     DanfePro1(@oDanfe,,"000001",,,.F.)
	
//		 If lPreview
			oDanfe:Preview()  //Visualiza antes de imprimir
//		 EndIf
		
	    // ---- Enviar e-mail do Danfe.pdf para o e-mail do Cliente 18/04/2012
//	    EnvDanfe(Alltrim(SA1->A1_EMAIL),Alltrim(SF3->F3_NFISCAL))
        
		FreeObj(oDanfe)
		oDanfe := Nil
		
     endif

// 	 Reclock("SF3",.F.)	
//	 SF3->F3_YDANFE := "S"
//	 MsUnlock()	

	 dbSkip()

  EndDo

  // Gera Log De Servico
//  ConOut("FIM DO PROCESSAMENTO DE EMAILS DA DANFE:" + DtoC(Msdate()) + " Hora: " + Time())

  // Finaliza environment
//  RESET ENVIRONMENT

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DanfeProc1 � Autor � Eduardo Riera         � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rdmake de exemplo para impress�o da DANFE no formato Retrato���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                    (OPC) ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function DanfePro1(oDanfe,lEnd,cIdEnt,cVal1,cVal2,lExistNfe)

Local aArea      := GetArea()
Local aAreaSF3   := {}
Local aNotas     := {}
Local aXML       := {}
Local aAutoriza  := {}
Local cNaoAut    := ""

Local cAliasSF3  := "SF3"
Local cWhere     := ""
Local cAviso     := ""
Local cErro      := ""
Local cAutoriza  := ""
Local cModalidade:= ""
Local cChaveSFT  := ""
Local cAliasSFT  := "SFT"
Local cCondicao	 := ""
Local cIndex	 := ""
Local cChave	 := ""

Local lQuery     := .F.

Local nX         := 0
Local nI		 := 0

Local oNfe
Local nLenNotas
Local lImpDir	 := GetNewPar("MV_IMPDIR",.F.)
Local nLenarray	 := 0
Local nCursor	 := 0
Local lBreak	 := .F.
Local aGrvSF3    := {}

//If Pergunte("NFSIGW",.T.)
	MV_PAR01 := AllTrim(MV_PAR01)
	If !lImpDir
		dbSelectArea("SF3")
		dbSetOrder(5)
		#IFDEF TOP
			If MV_PAR04==1
				cWhere := "%SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S'%"
			ElseIf MV_PAR04==2
				cWhere := "%SubString(SF3.F3_CFO,1,1) >= '5'%"
			EndIf
			cAliasSF3 := GetNextAlias()
			lQuery    := .T.
			
			If Empty(cWhere)
				
				BeginSql Alias cAliasSF3
					
					COLUMN F3_ENTRADA AS DATE
					COLUMN F3_DTCANC AS DATE
					
					SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND
					SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND
					SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND
					SF3.F3_DTCANC = %Exp:Space(8)% AND
					SF3.%notdel%
				EndSql
				
			Else
				BeginSql Alias cAliasSF3
					
					COLUMN F3_ENTRADA AS DATE
					COLUMN F3_DTCANC AS DATE
					
					SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND
					SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND
					SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND
					%Exp:cWhere% AND
					SF3.F3_DTCANC = %Exp:Space(8)% AND
					SF3.%notdel%
				EndSql
				
			EndIf
			
		#ELSE
			cIndex    		:= CriaTrab(NIL, .F.)
			cChave			:= IndexKey(6)
			cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			cCondicao 		+= 'SF3->F3_SERIE =="'+ MV_PAR03+'" .And. '
			cCondicao 		+= 'SF3->F3_NFISCAL >="'+ MV_PAR01+'" .And. '
			cCondicao		+= 'SF3->F3_NFISCAL <="'+ MV_PAR02+'" .And. '
			cCondicao		+= 'Empty(SF3->F3_DTCANC)'
			IndRegua(cAliasSF3, cIndex, cChave, , cCondicao)
			nIndex := RetIndex(cAliasSF3)
		            DBSetIndex(cIndex + OrdBagExt())
		            DBSetOrder(nIndex + 1)
			DBGoTop()
		#ENDIF
		If MV_PAR04==1
			cWhere := "SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL=='S'"
		Elseif MV_PAR04==2
			cWhere := "SubStr(F3_CFO,1,1) >= '5'"
		Else
			cWhere := ".T."
		EndIf
		
		While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
			(cAliasSF3)->F3_SERIE == MV_PAR03 .And.;
			(cAliasSF3)->F3_NFISCAL >= MV_PAR01 .And.;
			(cAliasSF3)->F3_NFISCAL <= MV_PAR02
			
			dbSelectArea(cAliasSF3)
			If  Empty((cAliasSF3)->F3_DTCANC) .And. &cWhere //.And. AModNot((cAliasSF3)->F3_ESPECIE)=="55"
				
				If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[4]+x[5]+x[6]+x[7]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA})==0
					
					aadd(aNotas,{})
					aadd(Atail(aNotas),.F.)
					aadd(Atail(aNotas),IIF((cAliasSF3)->F3_CFO<"5","E","S"))
					aadd(Atail(aNotas),(cAliasSF3)->F3_ENTRADA)
					aadd(Atail(aNotas),(cAliasSF3)->F3_SERIE)
					aadd(Atail(aNotas),(cAliasSF3)->F3_NFISCAL)
					aadd(Atail(aNotas),(cAliasSF3)->F3_CLIEFOR)
					aadd(Atail(aNotas),(cAliasSF3)->F3_LOJA)
					
				EndIf
			EndIf
			
			dbSelectArea(cAliasSF3)
			dbSkip()
			If lEnd
				Exit
			EndIf
			If (cAliasSF3)->(Eof())
				aAreaSF3 := (cAliasSF3)->(GetArea())
				aXml := GetXML(cIdEnt,aNotas,@cModalidade)
				nLenNotas := Len(aNotas)
				For nX := 1 To nLenNotas
					If !Empty(aXML[nX][2])
						If !Empty(aXml[nX])
							cAutoriza   := aXML[nX][1]
							cCodAutDPEC := aXML[nX][5]
						Else
							cAutoriza   := ""
							cCodAutDPEC := ""
						EndIf
						If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,3,4,5,6")
							If aNotas[nX][02]=="E"
								DBClearFilter()
								dbSelectArea("SF1")
								dbSetOrder(1)
								If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4,6"
									RecLock("SF1")
									If !SF1->F1_FIMP$"D"
										SF1->F1_FIMP := "S"
									EndIf
									If SF1->(FieldPos("F1_CHVNFE"))>0
										SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									EndIf
									MsUnlock()
								EndIf
							Else
								dbSelectArea("SF2")
								dbSetOrder(1)
								If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. cModalidade$"1,4,6"
									RecLock("SF2")
									If !SF2->F2_FIMP$"D"
										SF2->F2_FIMP := "S"
									EndIf
									If SF2->(FieldPos("F2_CHVNFE"))>0
										SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									EndIf
									MsUnlock()
								EndIf
							EndIf
							dbSelectArea("SFT")
							dbSetOrder(1)
							If SFT->(FieldPos("FT_CHVNFE"))>0
								cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05]+aNotas[nX][06]+aNotas[nX][07])
								If MsSeek(cChaveSFT)
									Do While !(cAliasSFT)->(Eof ()) .And.;
										cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
										RecLock("SFT")
										SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										MsUnLock()
										//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
										If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
											aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE})
										EndIf
										DbSkip()
									EndDo
								EndIf
							EndIf
							
							cAviso := ""
							cErro  := ""
							oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
							oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
							If Empty(cAviso) .And. Empty(cErro)
								ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7],aNotas[nX])
								lExistNfe := .T.
							EndIf
						Else
							cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF
						EndIf
					EndIf
					
				Next nX
				aNotas := {}
				
				RestArea(aAreaSF3)
			EndIf
		EndDo
		If !lQuery
			DBClearFilter()
			Ferase(cIndex+OrdBagExt())
		EndIf
		If !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas n�o foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf

	ElseIf  lImpDir
		//�����������������������������������������������������������Ŀ
		//�Tratamento para quando o parametro MV_IMPDIR esteja        �
		//�Habilitado, neste caso n�o ser� feita a impress�o conforme �
		//�Registros no SF3, e sim buscando XML diretamente do        �
		//�webService, e caso exista ser� impresso.                   �
		//�������������������������������������������������������������
		nLenarray := Val(MV_PAR02) - Val(Alltrim(MV_PAR01))
		nCursor   := Val(MV_PAR01)
		While  !lBreak  .And. nLenarray >= 0
			aNotas := {}
			For nx:=1 To 20
				aadd(aNotas,{})
				aAdd(Atail(aNotas),.F.)
				aadd(Atail(aNotas),IIF(MV_PAR04==1,"E","S"))
				aAdd(Atail(aNotas),"")
				aAdd(Atail(aNotas),MV_PAR03)
				aAdd(Atail(aNotas),Alltrim(StrZero(nCursor,Len(MV_PAR01))))
				aadd(Atail(aNotas),"")
				aadd(Atail(aNotas),"")
				If nCursor==Val(MV_PAR02)
					lBreak :=.T.
					nx:=20
				EndIF
				nCursor++
			Next nX
			aXml:={}
			aXml := GetXML(cIdEnt,aNotas,@cModalidade)
			nLenNotas := Len(aNotas)
			For nx :=1 To nLenNotas
				dbSelectArea("SFT")
				dbSetOrder(1)
				cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05])
				MsSeek(cChaveSFT)
				If !Empty(aXML[nX][2]) .And. Empty((cAliasSFT)->FT_DTCANC) //Realizada tal altera��o para que seja verificado antes da impress�o se a NF-e est� cancelada
					If !Empty(aXml[nX])
						cAutoriza   := aXML[nX][1]
						cCodAutDPEC := aXML[nX][5]
					Else
						cAutoriza   := ""
						cCodAutDPEC := ""
					EndIf
					cAviso := ""
					cErro  := ""
					oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
					oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
					If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,3,4,5,6")
						//------------------------------
						If aNotas[nX][02]=="E" .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
							dbSelectArea("SF1")
							dbSetOrder(1)
							If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4,6"
								Do While !Eof() .And. SF1->F1_DOC==aNotas[nX][05] .And. SF1->F1_SERIE==aNotas[nX][04]
									If SF1->F1_FORMUL=='S'
										RecLock("SF1")
										If !SF1->F1_FIMP$"D"
											SF1->F1_FIMP := "S"
										EndIf
										If SF1->(FieldPos("F1_CHVNFE"))>0
											SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										EndIf
										MsUnlock()
										DbSkip()
									EndIf
								EndDo
							EndIf
						ElseIf aNotas[nX][02]=="S" .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
							dbSelectArea("SF2")
							dbSetOrder(1)
							If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]) .And. cModalidade$"1,4,6"
								RecLock("SF2")
								If !SF2->F2_FIMP$"D"
									SF2->F2_FIMP := "S"
								EndIf
								If SF2->(FieldPos("F2_CHVNFE"))>0
									SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
								EndIf
								MsUnlock()
							EndIf
						EndIf
						dbSelectArea("SFT")
						dbSetOrder(1)
						If SFT->(FieldPos("FT_CHVNFE"))>0
							cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05])
							MsSeek(cChaveSFT)
							Do While !(cAliasSFT)->(Eof ()) .And.;
								cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL
								If (cAliasSFT)->FT_TIPOMOV $"S" .Or. ((cAliasSFT)->FT_TIPOMOV $"E" .And. (cAliasSFT)->FT_FORMUL=='S')
									//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
									If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
										aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE})
									EndIf
									RecLock("SFT")
									SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									MsUnLock()
									DbSkip()
								EndIf
								DbSkip()
							EndDo
						EndIf
						//-------------------------------
						If Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
							ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7],aNotas[nX])
							lExistNfe := .T.
						ElseIf Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
							ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7],aNotas[nX])
							lExistNfe := .T.
						EndIf
					Else
						cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF
					EndIf
				EndIf
			Next nx
		EndDo
		If !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas n�o foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf
    EndIf
//EndIf
If Len(aGrvSF3)>0 .And. SF3->(FieldPos("F3_CHVNFE"))>0
	For nI := 1 To Len(aGrvSF3)
		If SF3->(MsSeek(xFilial("SF3")+aGrvSF3[nI,1]+aGrvSF3[nI,2]+aGrvSF3[nI,3]+aGrvSF3[nI,4]+aGrvSF3[nI,5])) .And. Empty(SF3->F3_CHVNFE)
			RecLock("SF3")
			SF3->F3_CHVNFE := aGrvSF3[nI,6]
			MsUnLock()
		EndIf
	Next nI
EndIf
RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � ImpDet   � Autor � Eduardo Riera         � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Controle de Fluxo do Relatorio.                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                    (OPC) ���
���          �ExpC2: String com o XML da NFe                              ���
���          �ExpC3: Codigo de Autorizacao do fiscal                (OPC) ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpDet(oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12 
PRIVATE OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12  

PrtDanfe(@oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrtDanfe  � Autor �Eduardo Riera          � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do formulario DANFE grafico conforme laytout no   ���
���          �formato retrato                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtDanfe()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                          ���
���          �ExpO2: Objeto da NFe                                        ���
���          �ExpC3: Codigo de Autorizacao do fiscal                (OPC) ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrtDanfe(oDanfe,oNFE,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

Local aAuxCabec     := {} // Array que conter� as strings de cabe�alho das colunas de produtos/servi�os.
Local aTamanho      := {}
Local aTamCol       := {} // Array que conter� o tamanho das colunas dos produtos/servi�os.
Local aSitTrib      := {}
Local aSitSN		:= {}
Local aTransp       := {}
Local aDest         := {}
Local aHrEnt 		:= {}
Local aFaturas      := {}
Local aItens        := {}
Local aISSQN        := {}
Local aTotais       := {}
Local aAux          := {}
Local aUF           := {}
Local nHPage        := 0
Local nVPage        := 0
Local nPosV         := 0
Local nPosVOld      := 0
Local nPosH         := 0
Local nPosHOld      := 0
Local nAuxH         := 0
Local nAuxH2        := 0
Local nAuxV         := 0
Local nX            := 0
Local nY            := 0
Local nL            := 0
Local nJ            := 0
Local nW            := 0
Local nTamanho      := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nItem         := 0
Local nMensagem     := 0
Local nBaseICM      := 0
Local nValICM       := 0
Local nValIPI       := 0
Local nPICM         := 0
Local nPIPI         := 0
Local nFaturas      := 0
Local nVTotal       := 0
Local nQtd          := 0
Local nVUnit        := 0
Local nVolume	    := 0
Local cAux          := ""
Local cSitTrib      := ""
Local aMensagem     := {}
Local lPreview      := .F.
Local lFlag         := .T.
Local nLenFatura
Local nLenVol
Local nLenDet
Local nLenSit
Local nLenItens     := 0
Local nLenMensagens := 0
Local nLen          := 0
Local cUF		 	:= ""              
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lImpAnfav     := GetNewPar("MV_IMPANF",.F.)
Local lImpInfAd   	:= GetNewPar("MV_IMPADIC",.F.)
Local cMVCODREG		:= SuperGetMV("MV_CODREG", ," ")
Local cChaveCont 	:= ""
Local cLogo      	:= FisxLogo("1")
Local aEspVol       := {}
Local nColuna	    := 0
Local nLinSum	    := 0
Local aResFisco     := {} 
Local aEspecie      := {} 
Local cGuarda       := ""
Local nE		    := 0
Local cEsp		    := ""
Local nPag
Local nItensRes
Local lPagPar
Local nSoma
Local lMv_Logod     := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
Local cLogoD	    := ""
Local nZ		    := 0
Local aIndImp	    := {}
Local aIndAux	    := {}
Local lMv_ItDesc    := IIf( GetNewPar("MV_ITDESC","N")=="S", .T., .F. )
Local nMaxCod	    := 10
Local nMaxDes	    := MAXITEMC
Local aLote         := {}
Local lNFori2 	    := .T.
Local nLinhavers    := 0 
Local lFimpar	    := .T. 	                     
Local lCompleECF    := .F.
Local nMaxItemP2    := MAXITEM // Vari�vel utilizada para tratamento de quantos itens devem ser impressos na p�gina corrente

Default cDtHrRecCab := ""
Default dDtReceb    := CToD("")

Private oDPEC     := oNfeDPEC
Private oNF       := oNFe:_NFe
Private oEmitente := oNF:_InfNfe:_Emit
Private oIdent    := oNF:_InfNfe:_IDE
Private oDestino  := oNF:_InfNfe:_Dest
Private oTotal    := oNF:_InfNfe:_Total
Private oTransp   := oNF:_InfNfe:_Transp
Private oDet      := oNF:_InfNfe:_Det
Private oFatura   := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
Private oImposto
Private nPrivate  := 0
Private nPrivate2 := 0
Private nXAux	  := 0
Private aInfNf    := {}
Private lArt488MG := .F.
Private lArt274SP := .F. 

nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
//������������������������������������������������������������������������Ŀ
//�Carrega as variaveis de impressao                                       �
//��������������������������������������������������������������������������
aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")

aadd(aSitSN,"101")
aadd(aSitSN,"102")
aadd(aSitSN,"201")
aadd(aSitSN,"202")
aadd(aSitSN,"500")
aadd(aSitSN,"900")

//������������������������������������������������������������������������Ŀ
//�Quadro Destinatario                                                     �
//��������������������������������������������������������������������������
aDest := {NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte)+IIF(", SN"$NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte),"",", "+oDestino:_EnderDest:_NRO:Text + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))),;
NoChar(oDestino:_EnderDest:_XBairro:Text,lConverte),;
IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text),;//			oIdent:_DSaiEnt:Text,;
oDestino:_EnderDest:_XMun:Text,;
IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
oDestino:_EnderDest:_UF:Text,;
oDestino:_IE:Text,;
""}

If aNota[2] =="S" .and. !Empty(SF2->F2_DOC)
	aadd(aHrEnt,SF2->F2_HORA)
Elseif aNota[2] =="E" .and. SF1->F1_FORMUL=="S"
	aadd(aHrEnt,SF1->F1_HORA)
Else
	aadd(aHrEnt,"")
Endif
//������������������������������������������������������������������������Ŀ
//�Calculo do Imposto                                                      �
//��������������������������������������������������������������������������
aTotais := {"","","","","","","","","","",""}
aTotais[01] := Transform(Val(oTotal:_ICMSTOT:_vBC:TEXT),"@ze 9,999,999,999,999.99")
aTotais[02] := Transform(Val(oTotal:_ICMSTOT:_vICMS:TEXT),"@ze 9,999,999,999,999.99")
aTotais[03] := Transform(Val(oTotal:_ICMSTOT:_vBCST:TEXT),"@ze 9,999,999,999,999.99")
aTotais[04] := Transform(Val(oTotal:_ICMSTOT:_vST:TEXT),"@ze 9,999,999,999,999.99")
aTotais[05] := Transform(Val(oTotal:_ICMSTOT:_vProd:TEXT),"@ze 9,999,999,999,999.99")
aTotais[06] := Transform(Val(oTotal:_ICMSTOT:_vFrete:TEXT),"@ze 9,999,999,999,999.99")
aTotais[07] := Transform(Val(oTotal:_ICMSTOT:_vSeg:TEXT),"@ze 9,999,999,999,999.99")
aTotais[08] := Transform(Val(oTotal:_ICMSTOT:_vDesc:TEXT),"@ze 9,999,999,999,999.99")
aTotais[09] := Transform(Val(oTotal:_ICMSTOT:_vOutro:TEXT),"@ze 9,999,999,999,999.99")
If SF1->F1_TIPO <> "D"
	aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@ze 9,999,999,999,999.99")
Else
	aTotais[10] := ""
EndIf
aTotais[11] := 	Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@ze 9,999,999,999,999.99")
//������������������������������������������������������������������������Ŀ
//�Quadro Faturas                                                          �
//��������������������������������������������������������������������������
If nFaturas > 0
	For nX := 1 To 3
		aAux := {}
		For nY := 1 To Min(9, nFaturas)
			Do Case
				Case nX == 1
					If nFaturas > 1
						AAdd(aAux, AllTrim(oFatura:_Dup[nY]:_nDup:TEXT))
					Else
						AAdd(aAux, AllTrim(oFatura:_Dup:_nDup:TEXT))
					EndIf
				Case nX == 2
					If nFaturas > 1
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup[nY]:_dVenc:TEXT)))
					Else
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup:_dVenc:TEXT)))
					EndIf
				Case nX == 3
					If nFaturas > 1
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup[nY]:_vDup:TEXT), "@E 9,999,999,999,999.99")))
					Else
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup:_vDup:TEXT), "@E 9,999,999,999,999.99")))
					EndIf
			EndCase
		Next nY
		If nY <= 9
			For nY := 1 To 9
				AAdd(aAux, Space(20))
			Next nY
		EndIf
		AAdd(aFaturas, aAux)
	Next nX
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro transportadora                                                   �
//��������������������������������������������������������������������������
aTransp := {"","0","","","","","","","","","","","","","",""}

If Type("oTransp:_ModFrete")<>"U"
	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
EndIf
If Type("oTransp:_Transporta")<>"U"
	aTransp[01] := IIf(Type("oTransp:_Transporta:_xNome:TEXT")<>"U",NoChar(oTransp:_Transporta:_xNome:TEXT,lConverte),"")
	//	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
	If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99")
	EndIf
	aTransp[07] := IIf(Type("oTransp:_Transporta:_xEnder:TEXT")<>"U",NoChar(oTransp:_Transporta:_xEnder:TEXT,lConverte),"")
	aTransp[08] := IIf(Type("oTransp:_Transporta:_xMun:TEXT")<>"U",oTransp:_Transporta:_xMun:TEXT,"")
	aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT")<>"U",oTransp:_Transporta:_UF:TEXT,"")
	aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT")<>"U",oTransp:_Transporta:_IE:TEXT,"")
ElseIf Type("oTransp:_VEICTRANSP")<>"U"
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
EndIf
If Type("oTransp:_Vol")<>"U"
	If ValType(oTransp:_Vol) == "A"
		nX := nPrivate
		nLenVol := Len(oTransp:_Vol)
		For nX := 1 to nLenVol
			nXAux := nX
			nVolume += IIF(!Type("oTransp:_Vol[nXAux]:_QVOL:TEXT")=="U",Val(oTransp:_Vol[nXAux]:_QVOL:TEXT),0)
		Next nX
		aTransp[11]	:= AllTrim(str(nVolume))
		aTransp[12]	:= IIf(Type("oTransp:_Vol:_Esp")=="U","Diversos","")
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		If  Type("oTransp:_Vol[1]:_PesoB") <>"U"
			nPesoB := Val(oTransp:_Vol[1]:_PesoB:TEXT)
			aTransp[15] := AllTrim(str(nPesoB))
		EndIf
		If Type("oTransp:_Vol[1]:_PesoL") <>"U"
			nPesoL := Val(oTransp:_Vol[1]:_PesoL:TEXT)
			aTransp[16] := AllTrim(str(nPesoL))
		EndIf
	Else
		aTransp[11] := IIf(Type("oTransp:_Vol:_qVol:TEXT")<>"U",oTransp:_Vol:_qVol:TEXT,"")
		aTransp[12] := IIf(Type("oTransp:_Vol:_Esp")=="U","",oTransp:_Vol:_Esp:TEXT)
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT")<>"U",oTransp:_Vol:_PesoB:TEXT,"")
		aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT")<>"U",oTransp:_Vol:_PesoL:TEXT,"")
	EndIf
	aTransp[15] := strTRan(aTransp[15],".",",")
	aTransp[16] := strTRan(aTransp[16],".",",")
EndIf

//������������������������������������������������������������������������Ŀ
//�Volumes / Especie Nota de Saida                                         �
//��������������������������������������������������������������������������
If(MV_PAR04==2) .And. Empty(aTransp[12])	

	If (SF2->(FieldPos("F2_ESPECI1")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI1" )))  )) .Or.;
		(SF2->(FieldPos("F2_ESPECI2")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI2" )))  )) .Or.;
		(SF2->(FieldPos("F2_ESPECI3")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI3" )))  )) .Or.;
		(SF2->(FieldPos("F2_ESPECI4")) <>0 .And. !Empty( SF2->(FieldGet(FieldPos( "F2_ESPECI4" )))  ))
		
		aEspecie := {}
		aadd(aEspecie,SF2->F2_ESPECI1)
		aadd(aEspecie,SF2->F2_ESPECI2)
		aadd(aEspecie,SF2->F2_ESPECI3)
		aadd(aEspecie,SF2->F2_ESPECI4)
		
		cEsp := ""
		nx 	 := 0
		For nE := 1 To Len(aEspecie)
			If !Empty(aEspecie[nE])
				nx ++
				cEsp := aEspecie[nE]
			EndIf
		Next
		
		cGuarda := ""
		If nx > 1
			cGuarda := "Diversos"
		Else
			cGuarda := cEsp
		EndIf
		
		If !Empty(cGuarda)
			aadd(aEspVol,{cGuarda,Iif(SF2->F2_PLIQUI>0,str(SF2->F2_PLIQUI),""),Iif(SF2->F2_PBRUTO>0, str(SF2->F2_PBRUTO),"")})
		Else
			/*
			//������������������������������������������������������������������1
			//�Aqui seguindo a mesma regra da cria��o da TAG de Volumes no xml  �
			//� caso n�o esteja preenchida nenhuma das especies de Volume n�o se�
			//� envia as informa��es de volume.                   				�
			//������������������������������������������������������������������1
			*/
			aadd(aEspVol,{cGuarda,"",""})
		Endif
	Else
		aadd(aEspVol,{cGuarda,"",""})
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Especie Nota de Entrada                                                 �
//��������������������������������������������������������������������������
If(MV_PAR04==1) .And. Empty(aTransp[12])
	If (SF1->(FieldPos("F1_ESPECI1")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI1" )))  )) .Or.;
		(SF1->(FieldPos("F1_ESPECI2")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI2" )))  )) .Or.;
		(SF1->(FieldPos("F1_ESPECI3")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI3" )))  )) .Or.;
		(SF1->(FieldPos("F1_ESPECI4")) <>0 .And. !Empty( SF1->(FieldGet(FieldPos( "F1_ESPECI4" )))  ))
		
		aEspecie := {}
		aadd(aEspecie,SF1->F1_ESPECI1)
		aadd(aEspecie,SF1->F1_ESPECI2)
		aadd(aEspecie,SF1->F1_ESPECI3)
		aadd(aEspecie,SF1->F1_ESPECI4)
		
		cEsp := ""
		nx 	 := 0
		For nE := 1 To Len(aEspecie)
			If !Empty(aEspecie[nE])
				nx ++
				cEsp := aEspecie[nE]
			EndIf
		Next
		
		cGuarda := ""
		If nx > 1
			cGuarda := "Diversos"
		Else
			cGuarda := cEsp
		EndIf
		
		If  !Empty(cGuarda)
			aadd(aEspVol,{cGuarda,Iif(SF1->F1_PLIQUI>0,str(SF1->F1_PLIQUI),""),Iif(SF1->F1_PBRUTO>0, str(SF1->F1_PBRUTO),"")})
		Else
			/*
			//������������������������������������������������������������������1
			//�Aqui seguindo a mesma regra da cria��o da TAG de Volumes no xml  �
			//� caso n�o esteja preenchida nenhuma das especies de Volume n�o se�
			//� envia as informa��es de volume.                   				�
			//������������������������������������������������������������������1
			*/
			aadd(aEspVol,{cGuarda,"",""})
		Endif
	Else
		aadd(aEspVol,{cGuarda,"",""})
	EndIf
EndIf

//��-----����������Ŀ
//�Tipo do frete    �
//�������-----�������
dbSelectArea("SD2")
dbSetOrder(3)
MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SD2")+SD2->D2_TES)
dbSelectArea("SF3")
dbSetOrder(4)
MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)

lArt488MG := Iif(SF4->(FIELDPOS("F4_CRLEIT"))>0,Iif(SF4->F4_CRLEIT == "1",.T.,.F.),.F.)
lArt274SP := Iif(SF4->(FIELDPOS("F4_ART274"))>0,Iif(SF4->F4_ART274 $ "1S",.T.,.F.),.F.)

If Type("oTransp:_ModFrete") <> "U"
	cModFrete := oTransp:_ModFrete:TEXT
Else
	cModFrete := "1"
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro Dados do Produto / Servi�o                                       �
//��������������������������������������������������������������������������
nLenDet := Len(oDet)
If lMv_ItDesc
	For nX := 1 To nLenDet
		Aadd(aIndAux, {nX, SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,MAXITEMC)})
	Next
	
	aIndAux := aSort(aIndAux,,, { |x, y| x[2] < y[2] })
	
	For nX := 1 To nLenDet
		Aadd(aIndImp, aIndAux[nX][1] )
	Next
EndIf

For nZ := 1 To nLenDet
	If lMv_ItDesc
		nX := aIndImp[nZ]
	Else
		nX := nZ
	EndIf
	nPrivate := nX
    If lArt488MG .And. SuperGetMv("MV_ESTADO")$"MG"
        nVTotal  := 0
        nVUnit   := 0 
    Else
	    nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)//-Val(IIF(Type("oDet[nPrivate]:_Prod:_vDesc")=="U","",oDet[nX]:_Prod:_vDesc:TEXT))
	    nVUnit   := Val(oDet[nX]:_Prod:_vUnCom:TEXT)
	EndIf
	nQtd     := Val(oDet[nX]:_Prod:_qTrib:TEXT)
	nBaseICM := 0
	nValICM  := 0
	nValIPI  := 0
	nPICM    := 0
	nPIPI    := 0
	oImposto := oDet[nX]
	cSitTrib := ""
	If Type("oImposto:_Imposto")<>"U"
		If Type("oImposto:_Imposto:_ICMS")<>"U"
			nLenSit := Len(aSitTrib)
			For nY := 1 To nLenSit
				nPrivate2 := nY
				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
					If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT")<>"U"
						nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBC:TEXT"))
						nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
						nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_PICMS:TEXT"))
					EndIf
					cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_ORIG:TEXT")
					cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT")
				EndIf												
			Next nY			
		
			//Tratamento para o ICMS para optantes pelo Simples Nacional
			If Type("oEmitente:_CRT") <> "U" .And. oEmitente:_CRT:TEXT == "1"
				nLenSit := Len(aSitSN)
				For nY := 1 To nLenSit
					nPrivate2 := nY
					If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2])<>"U"
						If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_VBC:TEXT")<>"U"
							nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_VBC:TEXT"))
							nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_vICMS:TEXT"))
							nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_PICMS:TEXT"))                   
						EndIf
						cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_CSOSN:TEXT")				
					EndIf
				Next nY	
			EndIf
		
		EndIf
		If Type("oImposto:_Imposto:_IPI")<>"U"
			If Type("oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
				nValIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
			EndIf
			If Type("oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
				nPIPI   := Val(oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
			EndIf
		EndIf
	EndIf
	
	nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 50)
	
	// Tratamento para quebrar os digitos dos valores
	aAux := {}
	AADD(aAux, AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))))
	AADD(aAux, AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]))))
	AADD(aAux, AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))))
	AADD(aAux, AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))))
	AADD(aAux, AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))))
	AADD(aAux, AllTrim(TransForm(nValIPI,TM(nValIPI,TamSX3("D2_VALIPI")[1],TamSX3("D2_BASEIPI")[2]))))
	
	aadd(aItens,{;
		SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,nMaxCod),;
		SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,nMaxDes),;
		IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;
		cSitTrib,;
		oDet[nX]:_Prod:_CFOP:TEXT,;
		oDet[nX]:_Prod:_utrib:TEXT,;
		SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;
		SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;
		SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;
		SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;
		SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;
		SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;
		AllTrim(TransForm(nPICM,"@r 99.99%")),;
		AllTrim(TransForm(nPIPI,"@r 99.99%"));
	})
	
	cAuxItem := AllTrim(SubStr(oDet[nX]:_Prod:_cProd:TEXT,nMaxCod+1))
	cAux     := AllTrim(SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),(nMaxDes+1)))
	aAux[1]  := SubStr(aAux[1], PosQuebrVal(aAux[1]) + 1)
	aAux[2]  := SubStr(aAux[2], PosQuebrVal(aAux[2]) + 1)
	aAux[3]  := SubStr(aAux[3], PosQuebrVal(aAux[3]) + 1)
	aAux[4]  := SubStr(aAux[4], PosQuebrVal(aAux[4]) + 1)
	aAux[5]  := SubStr(aAux[5], PosQuebrVal(aAux[5]) + 1)
	aAux[6]  := SubStr(aAux[6], PosQuebrVal(aAux[6]) + 1)

    lPontilhado := .F.	
	While !Empty(cAux) .Or. !Empty(cAuxItem) .Or. !Empty(aAux[1]) .Or. !Empty(aAux[2]) .Or. !Empty(aAux[3]) .Or. !Empty(aAux[4]) .Or. !Empty(aAux[5]) .Or. !Empty(aAux[6])
		nMaxCod := MaxCod(cAuxItem, 50)
		
		aadd(aItens,{;
			SubStr(cAuxItem,1,nMaxCod),;
			SubStr(cAux,1,nMaxDes),;
			"",;
			"",;
			"",;
			"",;
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;
			"",;
			"";
		})
		
		// Popula as informa��es para as pr�ximas linhas adicionais
		cAux        := SubStr(cAux,(nMaxDes+1))
		cAuxItem    := SubStr(cAuxItem,nMaxCod+1)
		aAux[1]     := SubStr(aAux[1], PosQuebrVal(aAux[1]) + 1)
		aAux[2]     := SubStr(aAux[2], PosQuebrVal(aAux[2]) + 1)
		aAux[3]     := SubStr(aAux[3], PosQuebrVal(aAux[3]) + 1)
		aAux[4]     := SubStr(aAux[4], PosQuebrVal(aAux[4]) + 1)
		aAux[5]     := SubStr(aAux[5], PosQuebrVal(aAux[5]) + 1)
		aAux[6]     := SubStr(aAux[6], PosQuebrVal(aAux[6]) + 1)
		lPontilhado := .T.	
	EndDo
	
	If (Type("oNf:_infnfe:_det[nPrivate]:_Infadprod:TEXT") <> "U" .Or. Type("oNf:_infnfe:_det:_Infadprod:TEXT") <> "U") .And. ( lImpAnfav .Or. lImpInfAd )
		cAux := stripTags(AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1)), .T.)
		
		While !Empty(cAux)
			aadd(aItens,{;
				"",;
				SubStr(cAux,1,nMaxDes),;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"";
			})
			cAux := SubStr(cAux,(nMaxDes + 1))
	    	lPontilhado := .T.	
		EndDo
	EndIf
	If lPontilhado
		aadd(aItens,{;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-";
		})
	EndIf

Next nX
  

//������������������������������������������������������������������������Ŀ
//�Quadro ISSQN                                                            �
//��������������������������������������������������������������������������
aISSQN := {"","","",""}
If Type("oEmitente:_IM:TEXT")<>"U"
	aISSQN[1] := oEmitente:_IM:TEXT
EndIf
If Type("oTotal:_ISSQNtot")<>"U"
	aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@ze 999,999,999.99")
	aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@ze 999,999,999.99")
	aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@ze 999,999,999.99")
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro de informacoes complementares                                    �
//��������������������������������������������������������������������������
aMensagem := {}
If Type("oIdent:_tpAmb:TEXT")<>"U" .And. oIdent:_tpAmb:TEXT=="2"
	cAux := "DANFE emitida no ambiente de homologa��o - SEM VALOR FISCAL"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If Type("oNF:_InfNfe:_infAdic:_infAdFisco:TEXT")<>"U"
	cAux := oNF:_InfNfe:_infAdic:_infAdFisco:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT<>"4"
	cAux := "Protocolo: "+cCodAutSef
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT=="4" .AND. cModalidade $ "1"
	cAux := "Protocolo: "+cCodAutSef
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	cAux := "DANFE emitida anteriormente em conting�ncia DPEC"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If !Empty(cCodAutDPEC) .And. oIdent:_tpEmis:TEXT=="4"
	cAux := "N�mero de Registro DPEC: "+cCodAutDPEC
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If (Type("oIdent:_tpEmis:TEXT")<>"U" .And. !oIdent:_tpEmis:TEXT$"1,4")
	cAux := "DANFE emitida em conting�ncia"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (!Empty(cModalidade) .And. !cModalidade $ "1,4,5") .And. Empty(cCodAutSef)
	cAux := "DANFE emitida em conting�ncia devido a problemas t�cnicos - ser� necess�ria a substitui��o."
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (!Empty(cModalidade) .And. cModalidade $ "5" .And. oIdent:_tpEmis:TEXT=="4")
	cAux := "DANFE impresso em conting�ncia"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	cAux := "DPEC regularmento recebido pela Receita Federal do Brasil."
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (Type("oIdent:_tpEmis:TEXT")<>"U" .And. oIdent:_tpEmis:TEXT$"5")
	cAux := "DANFE emitida em conting�ncia FS-DA"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If Type("oNF:_InfNfe:_infAdic:_infCpl:TEXT")<>"U"
	cAux := stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .T.)
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf
If SF1->F1_TIPO == "D"
	If Type("oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT")<>"U"
		cAux := "Valor do Ipi : " + oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
EndIf

If lArt274SP .And. SuperGetMv("MV_ESTADO")$"SP"
	If Type("oNF:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT") <> "U"
		If oNF:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT <> "0"
			cAux := "Imposto recolhido por Substitui��o - Art 274 do RICMS"
			If oNF:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT == "SP"
				cAux += ": "
				aLote := RastroNFOr(SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA)
				For nX := 1 To Len(aLote)
					nBaseICM := aLote[nX][33]
					nValICM  := aLote[nX][38]
					cAux += Alltrim(aLote[nX][3]) + " - BCST: " + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D1_BRICMS")[1],TamSX3("D1_BRICMS")[2]))) + " e ICMSST: " + ;
									AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D1_ICMSRET")[1],TamSX3("D1_ICMSRET")[2]))) + "/ " 
				Next nX                      
			Endif
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo
		Endif
	Endif
Endif     

If MV_PAR04 == 2
	//impressao do valor das Informacoes do cupom fiscal referenciado
	If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
		If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
			aInfNf := oNF:_INFNFE:_IDE:_NFREF
		Else
			aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
		EndIf
	
		For Nx := 1 to Len(aInfNf)
			If Type("aInfNf["+Str(nX)+"]:_REFECF:TEXT")<>"U"
				
				//Buscar do SFT, pois no XML nao tem o numero da Serie do Cupom
				//Exemplo de conteudo do SFT->FT_OBSERV = "CF/SERIE:000014 /001 ECF:001"
				dbSelectArea("SFT")
				dbSetOrder(1)				
				MsSeek(xFilial("SF2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
				While !SFT->(Eof()) .And. xFilial("SF2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA == SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA
					If !Empty(SFT->FT_OBSERV) .And. "CF/SERIE" $ SFT->FT_OBSERV
						cAux := Alltrim(SFT->FT_OBSERV)
						Exit
					Else
						dbSkip()			    
					EndIf	                                                      			    
				EndDo    
				While !Empty(cAux)
					aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
					cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1) 
					lCompleECF := .T.
				EndDo
			EndIF
			If lCompleECF
				Exit
			EndIF	
		Next
		
	EndIf

	//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
	If !SF3->(Eof()) .And. SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE == SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
	    If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
			cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ " 
			cAux += Alltrim(Transform(SF3->F3_DS43080,"@ze 9,999,999,999,999.99")) + " ref.reducao de base de calculo"  
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo                                                                                                                                                               
	    EndIf
	EndIf    
ElseIf MV_PAR04 == 1
	//impressao do valor das Informacoes do cupom fiscal referenciado
	If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
		If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
			aInfNf := oNF:_INFNFE:_IDE:_NFREF
		Else
			aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
		EndIf
	
		For Nx := 1 to Len(aInfNf)
			If Type("aInfNf["+Str(nX)+"]:_REFECF:TEXT")<>"U"
				
				//Buscar do SFT, pois no XML nao tem o numero da Serie do Cupom
				//Exemplo de conteudo do SFT->FT_OBSERV = "CF/SERIE:000014 /001 ECF:001"
				dbSelectArea("SFT")
				dbSetOrder(1)				
				MsSeek(xFilial("SF1")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA,.T.)
				While !SFT->(Eof()) .And. xFilial("SF1")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA == SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA
					If !Empty(SFT->FT_OBSERV) .And. "CF/SERIE" $ SFT->FT_OBSERV					
						cAux := Alltrim(SFT->FT_OBSERV)
						Exit
					ElseIf !Empty(SFT->FT_OBSERV) .And. SFT->FT_TIPO="D" .And. Type("aInfNf["+Str(nX)+"]:_REFECF:_NECF:TEXT") <> "U"
						cAux := StrTran(Alltrim(SFT->FT_OBSERV),"N.F.","CF/SERIE") + " ECF:"+aInfNf[nX]:_REFECF:_NECF:TEXT
						Exit
					Else                                                      
					
						dbSkip()			    
					EndIf	                                                      			    
				EndDo    
				While !Empty(cAux)
					aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
					cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1) 
					lCompleECF := .T.
				EndDo
			EndIF
			If lCompleECF
				Exit
			EndIF	
		Next
		
	EndIf
	//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
	//Posiciono no SF3
	dbSelectArea("SF3")
	dbSetOrder(4)
	If MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE)	                                                                                                                                      		
		If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
			cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ " 
			cAux += Alltrim(Transform(SF3->F3_DS43080,"@ze 9,999,999,999,999.99")) + " ref.reducao de base de calculo"  
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo                                                                                                                                                               
	    EndIf                                                                                                                                  	
	EndIf
EndIF



For Nx := 1 to Len(aMensagem)
	NoChar(aMensagem[Nx],lConverte)
Next

If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
	If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
		aInfNf := oNF:_INFNFE:_IDE:_NFREF
	Else
		aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
	EndIf
	
	For nX := 1 to Len(aMensagem)
		If "ORIGINAL"$ Upper(aMensagem[nX])
			lNFori2 := .F.
		EndIf
	Next Nx
	
	cAux1 := ""
	cAux2 := ""
	For Nx := 1 to Len(aInfNf)
		If Type("aInfNf["+Str(nX)+"]:_REFNFE:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNFE:TEXT)$cAux1
			If !"CHAVE"$Upper(cAux1)
				cAux1 += "Chave de acesso da NF-E referenciada: "
			EndIf
			cAux1 += aInfNf[nx]:_REFNFE:TEXT+","
		ElseIf Type("aInfNf["+Str(nX)+"]:_REFNF:_NNF:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNF:_NNF:TEXT)$cAux2 .And. lNFori2
			If !"ORIGINAL"$Upper(cAux2)
				cAux2 += " Numero da nota original: "
			EndIf
			cAux2 += aInfNf[nx]:_REFNF:_NNF:TEXT+","
		EndIf
	Next
	
	cAux	:=	""
	If !Empty(cAux1)
		cAux1	:=	Left(cAux1,Len(cAux1)-1)
		cAux 	+= cAux1
	EndIf
	If !Empty(cAux2)
		cAux2	:=	Left(cAux2,Len(cAux2)-1)
		cAux 	+= 	Iif(!Empty(cAux),CRLF,"")+cAux2
	EndIf
	
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo

  	For Nx := 1 to Len(aMensagem)
   		NoChar(aMensagem[Nx],lConverte)
	Next

EndIf

//�Quadro "RESERVADO AO FISCO"                                             �
//��������������������������������������������������������������������������

aResFisco := {}
nBaseIcm  := 0

If GetNewPar("MV_BCREFIS",.F.) .And. SuperGetMv("MV_ESTADO")$"PR"
	If Val(&("oTotal:_ICMSTOT:_VBCST:TEXT")) <> 0
		cAux := "Substitui��o Tribut�ria: Art. 471, II e �1� do RICMS/PR: "
   		nLenDet := Len(oDet)
   		For nX := 1 To nLenDet
	   		oImposto := oDet[nX]
	   		If Type("oImposto:_Imposto")<>"U"
		 		If Type("oImposto:_Imposto:_ICMS")<>"U"
		 			nLenSit := Len(aSitTrib)
		 			For nY := 1 To nLenSit
		 				nPrivate2 := nY
		 				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
		 					If Type("oImposto:_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBCST:TEXT")<>"U"
		 		   				nBaseIcm := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBCST:TEXT"))
		 						cAux += oDet[nX]:_PROD:_CPROD:TEXT + ": BCICMS-ST R$" + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))) + " / "	
   		 	  				Endif
   		 	 			Endif
   					Next nY
   	   			Endif
   	 		Endif
   	   	Next nX
	Endif
	While !Empty(cAux)   
 		aadd(aResFisco,SubStr(cAux,1,60))
   		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, 59, MAXMENLIN) +2)
	EndDo	
Endif
       
//������������������������������������������������������������������������Ŀ
//�Calculo do numero de folhas                                             �
//��������������������������������������������������������������������������  
nFolhas	  := 1
nLenItens := Len(aItens) - MAXITEM // Todos os produtos/servi�os excluindo a primeira p�gina
nMsgCompl := Len(aMensagem) - MAXMSG // Todas as mensagens complementares excluindo a primeira p�gina
lFlag     := .T.
While lFlag
	// Caso existam produtos/servi�os e mensagens complementares a serem escritas
	If nLenItens > 0 .And. nMsgCompl > 0
		nFolhas++
		// Se estiver habilitado frente e verso e for uma p�gina impar
		If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
			nLenItens -= MAXITEMP3
		Else
			nLenItens -= MAXITEMP2
			nMsgCompl -= MAXMSG
		EndIf
	// Caso existam apenas mensagens complementares a serem escritas
	ElseIf nLenItens <= 0 .And. nMsgCompl > 0
		nFolhas++
		nMsgCompl := 0
	// Caso existam apenas produtos/servi�os a serem escritos
	ElseIf nLenItens > 0 .And. nMsgCompl <= 0
		nFolhas++
		// Se estiver habilitado frente e verso e for uma p�gina impar
		If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
			nLenItens -= MAXITEMP3
		Else
			nLenItens -= MAXITEMP2F
		EndIf
	// Se n�o tiver mais nada a ser escrito fecha a contagem
	Else
		lFlag := .F.
	EndIf
EndDo

//������������������������������������������������������������������������Ŀ
//�Inicializacao do objeto grafico                                         �
//��������������������������������������������������������������������������
If oDanfe == Nil
	lPreview := .T.
	oDanfe 	:= FWMSPrinter():New("DANFE", IMP_SPOOL)
	oDanfe:SetPortrait()
	oDanfe:Setup()
EndIf

//������������������������������������������������������������������������Ŀ
//�Inicializacao da pagina do objeto grafico                               �
//��������������������������������������������������������������������������
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//������������������������������������������������������������������������Ŀ
//�Definicao do Box - Recibo de entrega                                    �
//��������������������������������������������������������������������������

oDanfe:Box(000,000,010,501)
oDanfe:Say(006, 002, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
oDanfe:Box(009,000,037,101)
oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
oDanfe:Box(009,100,037,500)
oDanfe:Say(017, 102, "IDENTIFICA��O E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
oDanfe:Box(000,500,037,603)
oDanfe:Say(007, 542, "NF-e", oFont08N:oFont)
oDanfe:Say(017, 510, "N. "+StrZero(Val(oIdent:_NNf:Text),9), oFont08:oFont)
oDanfe:Say(027, 510, "S�RIE "+oIdent:_Serie:Text, oFont08:oFont)


//������������������������������������������������������������������������Ŀ
//�Quadro 1 IDENTIFICACAO DO EMITENTE                                      �
//��������������������������������������������������������������������������
oDanfe:Box(042,000,137,250)
oDanfe:Say(052,098, "Identifica��o do emitente",oFont12N:oFont)
nLinCalc	:=	065
cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
nForTo		:=	Len(cStrAux)/25
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
	nLinCalc+=10
Next nX

cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
nForTo		:=	Len(cStrAux)/32
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
	nLinCalc+=10
Next nX

If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
	cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(oEmitente:_EnderEmit:_xBairro:Text)
	If Type("oEmitente:_EnderEmit:_Cep")<>"U"
		cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
	EndIf
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
Else
	oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro 2                                                                �
//��������������������������������������������������������������������������

oDanfe:Box(042,248,137,351)
oDanfe:Say(055,275, "DANFE",oFont18N:oFont)
oDanfe:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
oDanfe:Say(075,258, "NOTA FISCAL ELETR�NICA",oFont07:oFont)
oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
oDanfe:Say(095,266, "1-SA�DA"  ,oFont08:oFont)
oDanfe:Box(078,315,095,325)
oDanfe:Say(089,318, oIdent:_TpNf:Text,oFont08N:oFont)
oDanfe:Say(110,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
oDanfe:Say(120,255,"S�RIE "+oIdent:_Serie:Text,oFont10N:oFont)
oDanfe:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

//������������������������������������������������������������������������Ŀ
//�Preenchimento do Array de UF                                            �
//��������������������������������������������������������������������������
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//������������������������������������������������������������������������Ŀ
//�Logotipo                                     �
//��������������������������������������������������������������������������
If lMv_Logod
	cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
	If !File(cLogoD)
		cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
		If !File(cLogoD)
			lMv_Logod := .F.
		EndIf
	EndIf
EndIf

If nfolha==1
	If lMv_Logod
		oDanfe:SayBitmap(042,000,cLogoD,095,096)
	Else
		oDanfe:SayBitmap(042,000,cLogo,095,096)
	EndIF
Endif

//������������������������������������������������������������������������Ŀ
//�Codigo de barra                                                         �
//��������������������������������������������������������������������������

oDanfe:Box(042,350,088,603)
oDanfe:Box(075,350,110,603)
oDanfe:Say(095,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
oDanfe:Box(105,350,137,603)

If nFolha == 1
	oDanfe:Say(085,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(072,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
EndIf

If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
	cDataEmi := Substr(oNF:_InfNfe:_IDE:_DEMI:Text,9,2)
	cTPEmis  := "4"
	cValIcm  := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
	cDataEmi := Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2)
	cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
	cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
EndIf
If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
	If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
		cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
		If cUf == "99"
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		EndIf
	ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
		cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
		cCNPJCPF := STRZERO(val(cCNPJCPF),14)
	Else
		cCNPJCPF := ""
	EndIf
	cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
	cChaveCont := cChaveCont+Modulo11(cChaveCont)
EndIf

If Empty(cCodAutDPEC)
	If Empty(cChaveCont)
		oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
Endif

If  !Empty(cCodAutDPEC)
	oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
	oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
Endif

// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
	If nFolha == 1
		If !Empty(cChaveCont)
			nFontSize := 28
			oDanfe:Code128C(135,370,cChaveCont, nFontSize )
		EndIf
	Else
		If !Empty(cChaveCont)
			nFontSize := 28
			oDanfe:Code128C(112,370,cChaveCont, nFontSize )
		EndIf
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro 4                                                                �
//��������������������������������������������������������������������������

oDanfe:Box(139,000,162,603)
oDanfe:Box(139,000,162,350)
oDanfe:Say(148,002,"NATUREZA DA OPERA��O",oFont08N:oFont)
oDanfe:Say(158,002,oIdent:_NATOP:TEXT,oFont08:oFont)


If !Empty(cCodAutDPEC)
	oDanfe:Say(148,350,"N�MERO DE REGISTRO DPEC",oFont08N:oFont)
Endif

If Empty(cCodAutDPEC) .And. (((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
	oDanfe:Say(148,352,"PROTOCOLO DE AUTORIZA��O DE USO",oFont08N:oFont)
Endif
If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
	oDanfe:Say(148,352,"DADOS DA NF-E",oFont08N:oFont)
Endif
oDanfe:Say(158,354,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
nFolha++


//������������������������������������������������������������������������Ŀ
//�Quadro 5                                                                �
//��������������������������������������������������������������������������
oDanfe:Box(164,000,187,603)
oDanfe:Box(164,000,187,200)
oDanfe:Box(164,200,187,400)
oDanfe:Box(164,400,187,603)
oDanfe:Say(172,002,"INSCRI��O ESTADUAL",oFont08N:oFont)
oDanfe:Say(180,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
oDanfe:Say(180,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
oDanfe:Say(172,405,"CNPJ",oFont08N:oFont)
oDanfe:Say(180,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
//������������������������������������������������������������������������Ŀ
//�Quadro destinat�rio/remetente                                           �
//��������������������������������������������������������������������������
Do Case
	Case Type("oDestino:_CNPJ")=="O"
		cAux := TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	Case Type("oDestino:_CPF")=="O"
		cAux := TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99")
	OtherWise
		cAux := Space(14)
EndCase


oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(197,000,217,450)
oDanfe:Say(205,002, "NOME/RAZ�O SOCIAL",oFont08N:oFont)
oDanfe:Say(215,002,NoChar(oDestino:_XNome:TEXT,lConverte),oFont08:oFont)
oDanfe:Box(197,280,217,500)
oDanfe:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(215,283,cAux,oFont08:oFont)

oDanfe:Box(217,000,237,500)
oDanfe:Box(217,000,237,260)
oDanfe:Say(224,002,"ENDERE�O",oFont08N:oFont)
oDanfe:Say(234,002,aDest[01],oFont08:oFont)
oDanfe:Box(217,230,237,380)
oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(234,232,aDest[02],oFont08:oFont)
oDanfe:Box(217,380,237,500)
oDanfe:Say(224,382,"CEP",oFont08N:oFont)
oDanfe:Say(234,382,aDest[03],oFont08:oFont)

oDanfe:Box(236,000,257,500)
oDanfe:Box(236,000,257,180)
oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(255,002,aDest[05],oFont08:oFont)
oDanfe:Box(236,150,257,256)
oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(255,152,aDest[06],oFont08:oFont)
oDanfe:Box(236,255,257,341)
oDanfe:Say(245,257,"UF",oFont08N:oFont)
oDanfe:Say(255,257,aDest[07],oFont08:oFont)
oDanfe:Box(236,340,257,500)
oDanfe:Say(245,342,"INSCRI��O ESTADUAL",oFont08N:oFont)
oDanfe:Say(255,342,aDest[08],oFont08:oFont)


oDanfe:Box(197,502,217,603)
oDanfe:Say(205,504,"DATA DE EMISS�O",oFont08N:oFont)
//oDanfe:Say(215,504,ConvDate(oIdent:_DEmi:TEXT),oFont08:oFont)
oDanfe:Box(217,502,237,603)
oDanfe:Say(224,504,"DATA ENTRADA/SA�DA",oFont08N:oFont)
oDanfe:Say(233,504,Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) ),oFont08:oFont)
oDanfe:Box(236,502,257,603)
oDanfe:Say(243,503,"HORA ENTRADA/SA�DA",oFont08N:oFont)
oDanfe:Say(252,503,aHrEnt[01],oFont08:oFont)
//������������������������������������������������������������������������Ŀ
//�Quadro fatura                                                           �
//��������������������������������������������������������������������������
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
For nX := 1 To Len(aFaturas)
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][4])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][5])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][6])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][7])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][8])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][9])
	If nY >= 9
		nY := 0
	EndIf
Next nX

oDanfe:Say(263,002,"FATURA",oFont08N:oFont)
oDanfe:Box(265,000,296,068)
oDanfe:Box(265,067,296,134)
oDanfe:Box(265,134,296,202)
oDanfe:Box(265,201,296,268)
oDanfe:Box(265,268,296,335)
oDanfe:Box(265,335,296,403)
oDanfe:Box(265,402,296,469)
oDanfe:Box(265,469,296,537)
oDanfe:Box(265,536,296,603)

nColuna := 002
If Len(aFaturas) >0
	For nY := 1 To 9
		oDanfe:Say(273,nColuna,aAux[1][nY][1],oFont08:oFont)
		oDanfe:Say(281,nColuna,aAux[1][nY][2],oFont08:oFont)
		oDanfe:Say(289,nColuna,aAux[1][nY][3],oFont08:oFont)
		nColuna:= nColuna+67
	Next nY
Endif
//������������������������������������������������������������������������Ŀ
//�Calculo do imposto                                                      �
//��������������������������������������������������������������������������
oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
oDanfe:Box(307,000,330,121)
oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
If cMVCODREG$"3"
	oDanfe:Say(326,002,aTotais[01],oFont08:oFont)
Endif
oDanfe:Box(307,120,330,200)
oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
If cMVCODREG$"3"
	oDanfe:Say(326,125,aTotais[02],oFont08:oFont)
Endif
oDanfe:Box(307,199,330,360)
oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUI��O",oFont08N:oFont)
oDanfe:Say(326,202,aTotais[03],oFont08:oFont)
oDanfe:Box(307,360,330,490)
oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUI��O",oFont08N:oFont)
oDanfe:Say(326,363,aTotais[04],oFont08:oFont)
oDanfe:Box(307,490,330,603)
oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
oDanfe:Say(327,491,aTotais[05],oFont08:oFont)


oDanfe:Box(330,000,353,110)
oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
oDanfe:Say(349,002,aTotais[06],oFont08:oFont)
oDanfe:Box(330,100,353,190)
oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
oDanfe:Say(349,102,aTotais[07],oFont08:oFont)
oDanfe:Box(330,190,353,290)
oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
oDanfe:Say(349,194,aTotais[08],oFont08:oFont)
oDanfe:Box(330,290,353,415)
oDanfe:Say(339,295,"OUTRAS DESPESAS ACESS�RIAS",oFont08N:oFont)
oDanfe:Say(349,295,aTotais[09],oFont08:oFont)
oDanfe:Box(330,414,353,500)
oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
oDanfe:Say(349,420,aTotais[10],oFont08:oFont)
oDanfe:Box(330,500,353,603)
oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
oDanfe:Say(349,506,aTotais[11],oFont08:oFont)
//������������������������������������������������������������������������Ŀ
//�Transportador/Volumes transportados                                     �
//��������������������������������������������������������������������������
oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
oDanfe:Box(363,000,386,603)
oDanfe:Say(372,002,"RAZ�O SOCIAL",oFont08N:oFont)
oDanfe:Say(382,002,aTransp[01],oFont08:oFont)
oDanfe:Box(363,245,386,315)
oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
If cModFrete =="0"
	oDanfe:Say(382,247,"0-EMITENTE",oFont08:oFont)
ElseIf cModFrete =="1"
	oDanfe:Say(382,247,"1-DEST/REM",oFont08:oFont)
ElseIf cModFrete =="2"
	oDanfe:Say(382,247,"2-TERCEIROS",oFont08:oFont)
ElseIf cModFrete =="9"
	oDanfe:Say(382,247,"9-SEM FRETE",oFont08:oFont)
Else
	oDanfe:Say(382,247,"",oFont08:oFont)
Endif
//oDanfe:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
oDanfe:Box(363,315,386,370)
oDanfe:Say(372,317,"C�DIGO ANTT",oFont08N:oFont)
oDanfe:Say(382,319,aTransp[03],oFont08:oFont)
oDanfe:Box(363,370,386,490)
oDanfe:Say(372,375,"PLACA DO VE�CULO",oFont08N:oFont)
oDanfe:Say(382,375,aTransp[04],oFont08:oFont)
oDanfe:Box(363,450,386,510)
oDanfe:Say(372,452,"UF",oFont08N:oFont)
oDanfe:Say(382,452,aTransp[05],oFont08:oFont)
oDanfe:Box(363,510,386,603)
oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(382,512,aTransp[06],oFont08:oFont)

oDanfe:Box(385,000,409,603)
oDanfe:Box(385,000,409,241)
oDanfe:Say(393,002,"ENDERE�O",oFont08N:oFont)
oDanfe:Say(404,002,aTransp[07],oFont08:oFont)
oDanfe:Box(385,240,409,341)
oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(404,242,aTransp[08],oFont08:oFont)
oDanfe:Box(385,340,409,440)
oDanfe:Say(393,342,"UF",oFont08N:oFont)
oDanfe:Say(404,342,aTransp[09],oFont08:oFont)
oDanfe:Box(385,440,409,603)
oDanfe:Say(393,442,"INSCRI��O ESTADUAL",oFont08N:oFont)
oDanfe:Say(404,442,aTransp[10],oFont08:oFont)


oDanfe:Box(408,000,432,603)
oDanfe:Box(408,000,432,101)
oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
oDanfe:Say(428,002,aTransp[11],oFont08:oFont)
oDanfe:Box(408,100,432,200)
oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
oDanfe:Say(428,102,Iif(!Empty(aTransp[12]),aTransp[12],Iif(Len(aEspVol)>0,aEspVol[1][1],"")),oFont08:oFont)
//oDanfe:Say(428,102,aEspVol[1][1],oFont08:oFont)
oDanfe:Box(408,200,432,301)
oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
oDanfe:Say(428,202,aTransp[13],oFont08:oFont)
oDanfe:Box(408,300,432,400)
oDanfe:Say(418,302,"NUMERA��O",oFont08N:oFont)
oDanfe:Say(428,302,aTransp[14],oFont08:oFont)
oDanfe:Box(408,400,432,501)
oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
oDanfe:Say(428,402,Iif(!Empty(aTransp[15]),aTransp[15],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][3])>0,Transform(Val(aEspVol[1][3]),"@E 999999.9999"),"")),oFont08:oFont)
//oDanfe:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
oDanfe:Box(408,500,432,603)
oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
oDanfe:Say(428,502,Iif(!Empty(aTransp[16]),aTransp[16],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][2])>0,Transform(Val(aEspVol[1][2]),"@E 999999.9999"),"")),oFont08:oFont)
//oDanfe:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

//������������������������������������������������������������������������Ŀ
//�Calculo do ISSQN                                                        �
//��������������������������������������������������������������������������

oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
oDanfe:Box(688,000,711,151)
oDanfe:Say(696,002,"INSCRI��O MUNICIPAL",oFont08N:oFont)
oDanfe:Say(706,002,aISSQN[1],oFont08:oFont)
oDanfe:Box(688,150,711,301)
oDanfe:Say(696,152,"VALOR TOTAL DOS SERVI�OS",oFont08N:oFont)
oDanfe:Say(706,152,aISSQN[2],oFont08:oFont)
oDanfe:Box(688,300,711,451)
oDanfe:Say(696,302,"BASE DE C�LCULO DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,302,aISSQN[3],oFont08:oFont)
oDanfe:Box(688,450,711,603)
oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,452,aISSQN[4],oFont08:oFont)

//������������������������������������������������������������������������Ŀ
//�Dados Adicionais                                                        �
//��������������������������������������������������������������������������
oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
oDanfe:Box(721,000,865,351)
oDanfe:Say(729,002,"INFORMA��ES COMPLEMENTARES",oFont08N:oFont)

nLenMensagens:= Len(aMensagem)
nLin:= 741
nMensagem := 0
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,002,aMensagem[nX],oFont08:oFont)
	nLin:= nLin+10
Next nX
nMensagem := nX

oDanfe:Box(721,350,865,603)
oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

nLenMensagens:= Len(aResFisco)
nLin:= 741
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,351,aResFisco[nX],oFont08:oFont)
	nLin:= nLin+10
Next

//������������������������������������������������������������������������Ŀ
//�Dados do produto ou servico                                             �
//��������������������������������������������������������������������������
aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])
	If nY >= 14
		nY := 0
	EndIf
Next nX
For nX := 1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	If nY >= 14
		nY := 0
	EndIf
	
Next nX

// Popula o array de cabe�alho das colunas de produtos/servi�os.
aAuxCabec := {;
	"COD. PROD",;
	"DESCRI��O DO PROD./SERV.",;
	"NCM/SH",;
	"CST",;
	"CFOP",;
	"UN",;
	"QUANT.",;
	"V.UNITARIO",;
	"V.TOTAL",;
	"BC.ICMS",;
	"V.ICMS",;
	"V.IPI",;
	"A.ICMS",;
	"A.IPI";
}

// Retorna o tamanho das colunas baseado em seu conteudo
aTamCol := RetTamCol(aAuxCabec, aAux, oDanfe, oFont08:oFont, oFont08N:oFont)

oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVI�O",oFont08N:oFont)
oDanfe:Box(442,000,678,603)
nAuxH := 0
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[1])
oDanfe:Say(450, nAuxH + 2, "COD. PROD",oFont08N:oFont)
nAuxH += aTamCol[1]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[2])
oDanfe:Say(450, nAuxH + 2, "DESCRI��O DO PROD./SERV.", oFont08N:oFont)
nAuxH += aTamCol[2]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[3])
oDanfe:Say(450, nAuxH + 2, "NCM/SH", oFont08N:oFont)
nAuxH += aTamCol[3]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[4])
oDanfe:Say(450, nAuxH + 2, "CST", oFont08N:oFont)
nAuxH += aTamCol[4]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[5])
oDanfe:Say(450, nAuxH + 2, "CFOP", oFont08N:oFont)
nAuxH += aTamCol[5]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[6])
oDanfe:Say(450, nAuxH + 2, "UN", oFont08N:oFont)
nAuxH += aTamCol[6]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[7])
oDanfe:Say(450, nAuxH + 2, "QUANT.", oFont08N:oFont)
nAuxH += aTamCol[7]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[8])
oDanfe:Say(450, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
nAuxH += aTamCol[8]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[9])
oDanfe:Say(450, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
nAuxH += aTamCol[9]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[10])
oDanfe:Say(450, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
nAuxH += aTamCol[10]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[11])
oDanfe:Say(450, nAuxH + 2, "V.ICMS", oFont08N:oFont)
nAuxH += aTamCol[11]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[12])
oDanfe:Say(450, nAuxH + 2, "V.IPI", oFont08N:oFont)
nAuxH += aTamCol[12]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[13])
oDanfe:Say(450, nAuxH + 2, "A.ICMS", oFont08N:oFont)
nAuxH += aTamCol[13]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[14])
oDanfe:Say(450, nAuxH + 2, "A.IPI", oFont08N:oFont)

If MV_PAR05=1 .And. nFolhas>1
	oDanfe:Say(875,497,"CONTINUA NO VERSO")
Endif

// INICIANDO INFORMA��ES PARA O CABE�ALHO DA PAGINA 2
nLinha	:= 460
nL	:= 0
lFlag	:= .T.

For nY := 1 To nLenItens
	nL++
	
	nLin:= 741
	nCont := 0
	
	If lflag
		If nL > nMaxItemP2
			oDanfe:EndPage()
			oDanfe:StartPage()
			If MV_PAR05 == 1
				nLinhavers := 42
			Else
				nLinhavers := 0
			EndIf		
			nLinha    	:=	181 + IIF(nFolha >=3 ,0, nLinhavers)
			
			oDanfe:Box(000+nLinhavers,000,095+nLinhavers,250)
			oDanfe:Say(010+nLinhavers,098, "Identifica��o do emitente",oFont12N:oFont)
			
			nLinCalc	:=	023 + nLinhavers
			cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
			nForTo		:=	Len(cStrAux)/25
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
				nLinCalc+=10
			Next nX
			
			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			
			If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
				cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				
				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
				If Type("oEmitente:_EnderEmit:_Cep")<>"U"
					cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
				EndIf
				nForTo		:=	Len(cStrAux)/32
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			Else
				oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			EndIf
			
			oDanfe:Box(000+nLinhavers,248,095+nLinhavers,351)
			oDanfe:Say(013+nLinhavers,255, "DANFE",oFont18N:oFont)
			oDanfe:Say(023+nLinhavers,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
			oDanfe:Say(033+nLinhavers,255, "NOTA FISCAL ELETR�NICA",oFont07:oFont)
			oDanfe:Say(043+nLinhavers,255, "0-ENTRADA",oFont08:oFont)
			oDanfe:Say(053+nLinhavers,255, "1-SA�DA"  ,oFont08:oFont)
			oDanfe:Box(037+nLinhavers,305,047+nLinhavers,315)
			oDanfe:Say(045+nLinhavers,307, oIdent:_TpNf:Text,oFont08N:oFont)
			oDanfe:Say(062+nLinhavers,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
			oDanfe:Say(072+nLinhavers,255,"S�RIE "+oIdent:_Serie:Text,oFont10N:oFont)
			oDanfe:Say(082+nLinhavers,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
			
			oDanfe:Box(000+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Box(000+nLinhavers,350,040+nLinhavers,603)
			oDanfe:Box(040+nLinhavers,350,062+nLinhavers,603)
			oDanfe:Box(063+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Say(058+nLinhavers,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
			
			oDanfe:Say(048+nLinhavers,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
			nFontSize := 28
			oDanfe:Code128C(036+nLinhavers,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
			
			If lMv_Logod
				oDanfe:SayBitmap(000+nLinhavers,000,cLogoD,095,096)
			Else
				oDanfe:SayBitmap(000+nLinhavers,000,cLogo,095,096)
			EndIf
			
			If Empty(cChaveCont)
				oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif
			
			If  !Empty(cCodAutDPEC)
				oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif
			
			
			If nFolha == 1
				If !Empty(cCodAutDPEC)
					nFontSize := 28
					oDanfe:Code128C(093+nLinhavers,370,cCodAutDPEC, nFontSize )
				Endif
			Endif
			
			// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
			If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
				If nFolha == 1
					If !Empty(cChaveCont)
						nFontSize := 28
						oDanfe:Code128C(093+nLinhavers,370,cChaveCont, nFontSize )
					EndIf
				Else
					If !Empty(cChaveCont)
						nFontSize := 28
						oDanfe:Code128C(093+nLinhavers,370,cChaveCont, nFontSize )
					EndIf
				EndIf
			EndIf
			
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,603)
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,300)
			oDanfe:Say(109+nLinhavers,002,"NATUREZA DA OPERA��O",oFont08N:oFont)
			oDanfe:Say(119+nLinhavers,002,oIdent:_NATOP:TEXT,oFont08:oFont)
			If(!Empty(cCodAutDPEC))
				oDanfe:Say(109+nLinhavers,300,"N�MERO DE REGISTRO DPEC",oFont08N:oFont)
			Endif
			If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
				oDanfe:Say(109+nLinhavers,302,"PROTOCOLO DE AUTORIZA��O DE USO",oFont08N:oFont)
			Endif
			If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
				oDanfe:Say(109+nLinhavers,300,"DADOS DA NF-E",oFont08N:oFont)
			Endif
			oDanfe:Say(119+nLinhavers,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
							
			nFolha++
			
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,603)
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,200)
			oDanfe:Box(126+nLinhavers,200,153+nLinhavers,400)
			oDanfe:Box(126+nLinhavers,400,153+nLinhavers,603)
			oDanfe:Say(135+nLinhavers,002,"INSCRI��O ESTADUAL",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
			oDanfe:Say(135+nLinhavers,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
			oDanfe:Say(135+nLinhavers,405,"CNPJ",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
			
			nLenMensagens:= Len(aMensagem)
			
			nColLim		:=	Iif(MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865)) + nLinhavers 
			oDanfe:Say(161+nLinhavers,002,"DADOS DO PRODUTO / SERVI�O",oFont08N:oFont)
			oDanfe:Box(163+nLinhavers,000,nColLim,603)
			
			nAuxH := 0
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[1])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "COD. PROD",oFont08N:oFont)
			nAuxH += aTamCol[1]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[2])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "DESCRI��O DO PROD./SERV.", oFont08N:oFont)
			nAuxH += aTamCol[2]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[3])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "NCM/SH", oFont08N:oFont)
			nAuxH += aTamCol[3]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[4])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "CST", oFont08N:oFont)
			nAuxH += aTamCol[4]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[5])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "CFOP", oFont08N:oFont)
			nAuxH += aTamCol[5]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[6])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "UN", oFont08N:oFont)
			nAuxH += aTamCol[6]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[7])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "QUANT.", oFont08N:oFont)
			nAuxH += aTamCol[7]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[8])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
			nAuxH += aTamCol[8]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[9])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
			nAuxH += aTamCol[9]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[10])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[10]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[11])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[11]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[12])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.IPI", oFont08N:oFont)
			nAuxH += aTamCol[12]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[13])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "A.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[13]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[14])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "A.IPI", oFont08N:oFont)
			
			// FINALIZANDO INFORMA��ES PARA O CABE�ALHO DA PAGINA 2
			nL	:= 1
			lFlag	:= .F.                                         		
			
			//Verifico se ainda existem Dados Adicionais a serem impressos
			IF MV_PAR05 <> 1 .And. nMensagem <= nLenMensagens
				//������������������������������������������������������������������������Ŀ
				//�Dados Adicionais                                                        �
				//��������������������������������������������������������������������������
				oDanfe:Say(719+nLinhavers,000,"DADOS ADICIONAIS",oFont08N:oFont)
				oDanfe:Box(721+nLinhavers,000,865+nLinhavers,351)
				oDanfe:Say(729+nLinhavers,002,"INFORMA��ES COMPLEMENTARES",oFont08N:oFont)				
				
				nLin:= 741
				nLenMensagens:= Len(aMensagem)
				--nMensagem
				For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
					oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
					nLin:= nLin+10
				Next nX
				nMensagem := nMensagem+nX
				
				oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
				
				// Seta o m�ximo de itens para o MAXITEMP2
				nMaxItemP2 := MAXITEMP2
			Else
				// Seta o m�ximo de itens para o MAXITEMP2F
				nMaxItemP2 := MAXITEMP2F
			EndIF
		Endif		
	Endif
	
	// INICIANDO INFORMA��ES PARA O CABE�ALHO DA PAGINA 3 E DIANTE	
	If	nL > Iif( (nfolha-1)%2==0 .And. MV_PAR05==1,MAXITEMP3,nMaxItemP2)
		oDanfe:EndPage()
		oDanfe:StartPage()
		nLenMensagens:= Len(aMensagem)							
		nColLim		:=	Iif(!(nfolha-1)%2==0 .And. MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865))
		lFimpar		:=  ((nfolha-1)%2==0)
		nLinha    	:=	181      
		If nfolha >= 3
			nLinhavers := 0
		EndIf
		oDanfe:Box(000,000,095,250)
		oDanfe:Say(010,098, "Identifica��o do emitente",oFont12N:oFont)
		nLinCalc	:=	023
		cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
		nForTo		:=	Len(cStrAux)/25
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		
		If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
			cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			
			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
			If Type("oEmitente:_EnderEmit:_Cep")<>"U"
				cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
			EndIf
			nForTo		:=	Len(cStrAux)/32
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
		Else
			oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
		EndIf
		
		oDanfe:Box(000,248,095,351)
		oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
		oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
		oDanfe:Say(033,255, "NOTA FISCAL ELETR�NICA",oFont07:oFont)
		oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
		oDanfe:Say(053,255, "1-SA�DA"  ,oFont08:oFont)
		oDanfe:Box(037,305,047,315)
		oDanfe:Say(045,307, oIdent:_TpNf:Text,oFont08N:oFont)
		oDanfe:Say(062,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
		oDanfe:Say(072,255,"S�RIE "+oIdent:_Serie:Text,oFont10N:oFont)
		oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
		
		oDanfe:Box(000,350,095,603)
		oDanfe:Box(000,350,040,603)
		oDanfe:Box(040,350,062,603)
		oDanfe:Box(063,350,095,603)
		oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
		
		oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
		nFontSize := 28
		oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
		
		If lMv_Logod
			oDanfe:SayBitmap(000,000,cLogoD,095,096)
		Else
			oDanfe:SayBitmap(000,000,cLogo,095,096)
		EndIf
		
		If Empty(cChaveCont)
			oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif
		
		If  !Empty(cCodAutDPEC)
			oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif
		
		
		If nFolha == 1
			If !Empty(cCodAutDPEC)
				nFontSize := 28
				oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
			Endif
		Endif
		
		// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
		If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
			If nFolha == 1
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			Else
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			EndIf
		EndIf
		
		oDanfe:Box(100,000,123,603)
		oDanfe:Box(100,000,123,300)
		oDanfe:Say(109,002,"NATUREZA DA OPERA��O",oFont08N:oFont)
		oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
		If(!Empty(cCodAutDPEC))
			oDanfe:Say(109,300,"N�MERO DE REGISTRO DPEC",oFont08N:oFont)
		Endif
		If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
			oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZA��O DE USO",oFont08N:oFont)
		Endif
		If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
			oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
		Endif
		oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
		nFolha++
		
		oDanfe:Box(126,000,153,603)
		oDanfe:Box(126,000,153,200)
		oDanfe:Box(126,200,153,400)
		oDanfe:Box(126,400,153,603)
		oDanfe:Say(135,002,"INSCRI��O ESTADUAL",oFont08N:oFont)
		oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
		oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
		oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
		
		oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVI�O",oFont08N:oFont)
		oDanfe:Box(163,000,nColLim,603)
		
		nAuxH := 0
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[1])
		oDanfe:Say(171, nAuxH + 2, "COD. PROD",oFont08N:oFont)
		nAuxH += aTamCol[1]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[2])
		oDanfe:Say(171, nAuxH + 2, "DESCRI��O DO PROD./SERV.", oFont08N:oFont)
		nAuxH += aTamCol[2]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[3])
		oDanfe:Say(171, nAuxH + 2, "NCM/SH", oFont08N:oFont)
		nAuxH += aTamCol[3]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[4])
		oDanfe:Say(171, nAuxH + 2, "CST", oFont08N:oFont)
		nAuxH += aTamCol[4]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[5])
		oDanfe:Say(171, nAuxH + 2, "CFOP", oFont08N:oFont)
		nAuxH += aTamCol[5]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[6])
		oDanfe:Say(171, nAuxH + 2, "UN", oFont08N:oFont)
		nAuxH += aTamCol[6]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[7])
		oDanfe:Say(171, nAuxH + 2, "QUANT.", oFont08N:oFont)
		nAuxH += aTamCol[7]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[8])
		oDanfe:Say(171, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
		nAuxH += aTamCol[8]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[9])
		oDanfe:Say(171, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
		nAuxH += aTamCol[9]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[10])
		oDanfe:Say(171, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[10]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[11])
		oDanfe:Say(171, nAuxH + 2, "V.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[11]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[12])
		oDanfe:Say(171, nAuxH + 2, "V.IPI", oFont08N:oFont)
		nAuxH += aTamCol[12]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[13])
		oDanfe:Say(171, nAuxH + 2, "A.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[13]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[14])
		oDanfe:Say(171, nAuxH + 2, "A.IPI", oFont08N:oFont)
		
		//Verifico se ainda existem Dados Adicionais a serem impressos
		nLenMensagens:= Len(aMensagem)			
		IF (MV_PAR05 <> 1 .Or. (MV_PAR05 == 1 .And. lFimpar )).And. nMensagem <= nLenMensagens
			//������������������������������������������������������������������������Ŀ
			//�Dados Adicionais                                                        �
			//��������������������������������������������������������������������������
			oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
			oDanfe:Box(721,000,865,351)
			oDanfe:Say(729,002,"INFORMA��ES COMPLEMENTARES",oFont08N:oFont)				
			
			nLin:= 741
			nLenMensagens:= Len(aMensagem)
			--nMensagem
			For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)				
				oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
				nLin:= nLin+10
			Next nX
			nMensagem := nMensagem+nX
			
			oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
			oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
			
			// Seta o m�ximo de itens para o MAXITEMP2
			nMaxItemP2 := MAXITEMP2
		Else
			// Seta o m�ximo de itens para o MAXITEMP2F
			nMaxItemP2 := MAXITEMP2F
		EndIF	
		If (!(nfolha-1)%2==0) .And. MV_PAR05==1
			If nY+69<nLenItens
				oDanfe:Say(875+nLinhavers,497,"CONTINUA NO VERSO")
			Endif
		End
		
		nL := 1
	EndIf
	
	nAuxH := 0
	
	If aAux[1][1][nY] == "-"
		oDanfe:Say(nLinha, nAuxH, Replicate("- ", 150), oFont08:oFont)
	Else
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][1][nY], oFont08:oFont )
		nAuxH += aTamCol[1]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][2][nY], oFont08:oFont) // DESCRICAO DO PRODUTO
		nAuxH += aTamCol[2]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][3][nY], oFont08:oFont) // NCM
		nAuxH += aTamCol[3]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][4][nY], oFont08:oFont) // CST
		nAuxH += aTamCol[4]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][5][nY], oFont08:oFont) // CFOP
		nAuxH += aTamCol[5]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][6][nY], oFont08:oFont) // UN
		nAuxH += aTamCol[6]
		// Workaround para falha no FWMSPrinter:GetTextWidth()
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[7] - 2) - RetTamTex(aAux[1][7][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[7] - 2) - RetTamTex(aAux[1][7][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][7][nY], oFont08:oFont) // QUANT
		nAuxH += aTamCol[7]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[8] - 2) - RetTamTex(aAux[1][8][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[8] - 2) - RetTamTex(aAux[1][8][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][8][nY], oFont08:oFont) // V UNITARIO
		nAuxH += aTamCol[8]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[9] - 2) - RetTamTex(aAux[1][9][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[9] - 2) - RetTamTex(aAux[1][9][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][9][nY], oFont08:oFont) // V. TOTAL
		nAuxH += aTamCol[9]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[10] - 2) - RetTamTex(aAux[1][10][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[10] - 2) - RetTamTex(aAux[1][10][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][10][nY], oFont08:oFont) // BC. ICMS
		nAuxH += aTamCol[10]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[11] - 2) - RetTamTex(aAux[1][11][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[11] - 2) - RetTamTex(aAux[1][11][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][11][nY], oFont08:oFont) // V. ICMS
		nAuxH += aTamCol[11]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[12] - 2) - RetTamTex(aAux[1][12][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[12] - 2) - RetTamTex(aAux[1][12][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][12][nY], oFont08:oFont) // V.IPI
		nAuxH += aTamCol[12]
		nAuxH2 := nAuxH + ((aTamCol[13] - 2) - RetTamTex(aAux[1][13][nY], oFont08:oFont, oDanfe)) + 2
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][13][nY], oFont08:oFont) // A.ICMS
		nAuxH += aTamCol[13]
		nAuxH2 := nAuxH + ((aTamCol[14] - 2) - RetTamTex(aAux[1][14][nY], oFont08:oFont, oDanfe)) + 2
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][14][nY], oFont08:oFont) // A.IPI
	EndIf
	
	nLinha :=nLinha + 10
Next nY

nLenMensagens := Len(aMensagem)
While nMensagem <= nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab, cLogoD)
EndDo

//������������������������������������������������������������������������Ŀ
//�Finaliza a Impress�o                                                    �
//��������������������������������������������������������������������������
If lPreview
	//	oDanfe:Preview()
EndIf

oDanfe:EndPage()


//������������������������������������������������������������������������������������������������Ŀ
//�Tratamento para nao imprimir DANFEs diferentes na mesma folha, uma na FRENTE e outra no VERSO.  |
//|   Isso quando a impressora estiver configurada para frente e verso                             �
//��������������������������������������������������������������������������������������������������
If MV_PAR05==1 .And. MV_PAR01 <> MV_PAR02 .And. (--nFolha)%2<>0
	oDanfe:StartPage()
	oDanfe:EndPage()
EndIf

Return(.T.)

/*
Private oNF        := oNFe:_NFe
Private oDPEC    :=oNfeDPEC
Default cCodAutSef := ""
Default cCodAutDPEC:= ""
Default cDtHrRecCab:= ""
Default dDtReceb   := CToD("")
*/
//������������������������������������������������������������������������Ŀ
//�Impressao do Complemento da NFe                                         �
//��������������������������������������������������������������������������
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab, cLogoD)
Local nX            := 0
Local nLinha        := 0
Local nLenMensagens := Len(aMensagem)
Local nItemOld	    := nItem
Local nMensagemOld  := nMensagem
Local nForMensagens := 0
Local lMensagens    := .F.
Local cLogo      	:= FisxLogo("1")
Local cChaveCont 	:= ""
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lMv_Logod := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )

If (nLenMensagens - (nMensagemOld - 1)) > 0
	lMensagens := .T.
	
EndIf

//�������������------------------------�����
//�Dados Adicionais segunda parte em diante�
//�������������------------------------�����
If lMensagens
	nLenMensagens := Len(aMensagem)
	nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1) - (nItem - nItemOld))
	oDanfe:EndPage()
	oDanfe:StartPage()
	nLinha    :=180
	oDanfe:Say(160,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oDanfe:Box(172,000,865,351)
	oDanfe:Say(170,002,"INFORMA��ES COMPLEMENTARES",oFont08N:oFont)
	oDanfe:Box(172,350,865,603)
	oDanfe:Say(170,352,"RESERVADO AO FISCO",oFont08N:oFont)
	
	oDanfe:Box(000,000,095,250)
	oDanfe:Say(010,098, "Identifica��o do emitente",oFont12N:oFont)
	nLinCalc	:=	023
	cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
	nForTo		:=	Len(cStrAux)/25
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
	nForTo		:=	Len(cStrAux)/32
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
		cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
		If Type("oEmitente:_EnderEmit:_Cep")<>"U"
			cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
		EndIf
		nForTo		:=	Len(cStrAux)/32
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*32)+1),32),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xBairro:Text+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf
	
	oDanfe:Box(000,248,095,351)
	oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
	oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDanfe:Say(033,255, "NOTA FISCAL ELETR�NICA",oFont07:oFont)
	oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
	oDanfe:Say(053,255, "1-SA�DA"  ,oFont08:oFont)
	oDanfe:Box(037,305,047,315)
	oDanfe:Say(045,307, oIdent:_TpNf:Text,oFont08N:oFont)
	oDanfe:Say(062,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
	oDanfe:Say(072,255,"S�RIE "+oIdent:_Serie:Text,oFont10N:oFont)
	oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
	
	oDanfe:Box(000,350,095,603)
	oDanfe:Box(000,350,040,603)
	oDanfe:Box(040,350,062,603)
	oDanfe:Box(063,350,095,603)
	oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
	
	oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
	
	If lMv_Logod
		oDanfe:SayBitmap(000,000,cLogoD,095,096)
	Else
		oDanfe:SayBitmap(000,000,cLogo,095,096)
	EndIf
	
	If Empty(cChaveCont)
		oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
	
	If  !Empty(cCodAutDPEC)
		oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
	
	
	If nFolha == 1
		If !Empty(cCodAutDPEC)
			nFontSize := 28
			oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
		Endif
	Endif
	
	// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
	If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
		If nFolha == 1
			If !Empty(cChaveCont)
				nFontSize := 28
				oDanfe:Code128C(093,370,cChaveCont, nFontSize )
			EndIf
		Else
			If !Empty(cChaveCont)
				nFontSize := 28
				oDanfe:Code128C(093,370,cChaveCont, nFontSize )
			EndIf
		EndIf
	EndIf
	
	oDanfe:Box(100,000,123,603)
	oDanfe:Box(100,000,123,300)
	oDanfe:Say(109,002,"NATUREZA DA OPERA��O",oFont08N:oFont)
	oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
	If(!Empty(cCodAutDPEC))
		oDanfe:Say(109,300,"N�MERO DE REGISTRO DPEC",oFont08N:oFont)
	Endif
	If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
		oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZA��O DE USO",oFont08N:oFont)
	Endif
	If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
		oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
	Endif
	oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
	nFolha++
	
	oDanfe:Box(126,000,153,603)
	oDanfe:Box(126,000,153,200)
	oDanfe:Box(126,200,153,400)
	oDanfe:Box(126,400,153,603)
	oDanfe:Say(135,002,"INSCRI��O ESTADUAL",oFont08N:oFont)
	oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
	oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
	oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
	oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
	
	For nX := nMensagem To nForMensagens
		oDanfe:Say(nlinha,002,aMensagem[nX],oFont08:oFont)
		nMensagem++
		nLinha:= nLinha+ 10
	Next nX
EndIf
//������������������������������������������������������������������������Ŀ
//�Finalizacao da pagina do objeto grafico                                 �
//��������������������������������������������������������������������������
oDanfe:EndPage()

Return(.T.)

Static Function GetXML(cIdEnt,aIdNFe,cModalidade)

Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local oWS
Local cRetorno   := ""
Local cProtocolo := ""
Local cRetDPEC   := ""
Local cProtDPEC  := ""
Local nX         := 0
Local nY         := 0
Local nL		 := 0
Local aRetorno   := {}
Local aResposta  := {}
Local aFalta     := {}
Local aExecute   := {}
Local nLenNFe
Local nLenWS
Local cDHRecbto  := ""
Local cDtHrRec   := ""
Local cDtHrRec1	 := ""
Local nDtHrRec1  := 0
Local lFlag      := .T.
Local dDtRecib	:=	CToD("")

Private oDHRecbto

If Empty(cModalidade)
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf
EndIf
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
nLenNFe := Len(aIdNFe)
For nX := 1 To nLenNFe
	aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","","",CToD("")})
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nX][4]+aIdNfe[nX][5]
Next nX
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
			cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto		:= XmlParser(cDHRecbto,"","","")
				cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
				nDtHrRec1		:= RAT("T",cDtHrRec)
				
				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
						RecLock("SF1")
						SF1->F1_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
			EndIf
			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib
				
				aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
		For nX := 1 To Len(aIdNfe)
			If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
				aadd(aFalta,aIdNfe[nX])
			EndIf
		Next nX
		If Len(aFalta)>0
			aExecute := GetXML(cIdEnt,aFalta,@cModalidade)
		Else
			aExecute := {}
		EndIf
		For nX := 1 To Len(aExecute)
			nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
			If nY == 0
				aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
			Else
				aRetorno[nY][01] := aExecute[nX][01]
				aRetorno[nY][02] := aExecute[nX][02]
			EndIf
		Next nX
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf

Return(aRetorno)

Static Function ConvDate(cData)

Local dData
cData  := StrTran(cData,"-","")
dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DANFE     �Autor  �Marcos Taranta      � Data �  10/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega uma posi��o (nTam) na string cString, e retorna o      ���
���          �caractere de espa�o anterior.                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posi��o (nTam) for maior que o tamanho da string, ou for um valor
* inv�lido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espa�o anterior a posi��o e retorna a posi��o
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
* Caso n�o encontre nenhum caractere de espa�o, � retornado 0.
*/
nRetorno := 0

Return nRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DANFE     �Autor  �Fabio Santana	     � Data �  04/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte caracteres espceiais						          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/
STATIC FUNCTION NoChar(cString,lConverte)

Default lConverte := .F.

If lConverte
	cString := (StrTran(cString,"&lt;","<"))
	cString := (StrTran(cString,"&gt;",">"))
	cString := (StrTran(cString,"&amp;","&"))
	cString := (StrTran(cString,"&quot;",'"'))
	cString := (StrTran(cString,"&#39;","'"))
EndIf

Return(cString)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DANFEIII  �Autor  �Microsiga           � Data �  12/17/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tratamento para o c�digo do item                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
STATIC FUNCTION MaxCod(cString,nTamanho)

//�������������������������������������������������������������Ŀ
//�Tratamento para saber quantos caracteres ir�o caber na linha �
//� visto que letras ocupam mais espa�o do que os n�meros.      �
//���������������������������������������������������������������

Local nMax	:= 0
Local nY   	:= 0
Default nTamanho := 45

For nMax := 1 to Len(cString)
	If IsAlpha(SubStr(cString,nMax,1)) .And. SubStr(cString,nMax,1) $ "MOQW"  // Caracteres que ocupam mais espa�o em pixels
		nY += 7
	Else
		nY += 5
	EndIf
	
	If nY > nTamanho   // � o m�ximo de espa�o para uma coluna
		nMax--
		Exit
	EndIf
Next

Return nMax

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamCol
Retorna um array do mesmo tamanho do array de entrada, contendo as
medidas dos maiores textos para c�lculo de colunas.

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  aCabec     Array contendo as strings de cabe�alho das colunas
        aValores   Array contendo os valores que ser�o populados nas
                   colunas.
        oDanfe   Objeto de impress�o instanciado para utilizar o m�todo
                   nativo de c�lculo de tamanho de texto.
        oFontCabec Objeto da fonte que ser� utilizada no cabe�alho.
        oFont      Objeto da fonte que ser� utilizada na impress�o.

@return aTamCol  Array contendo os tamanhos das colunas baseados nos
                 valores.
/*/
//-----------------------------------------------------------------------
Static Function RetTamCol(aCabec, aValores, oDanfe, oFontCabec, oFont)
	
	Local aTamCol    := {}
	Local nAux       := 0

	Local nX         := 0
	Local nY         := 0
	                          
	Local oFontSize	 := FWFontSize():new()
	
	For nX := 1 To Len(aCabec)
		
		AADD(aTamCol, {})
		//aTamCol[nX] := Round(oDanfe:GetTextWidth(aCabec[nX], oFontCabec) * nConsNeg + 4, 0)
		aTamCol[nX] := oFontSize:getTextWidth( alltrim(aCabec[nX]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
		
	Next nX
	
	For nX := 1 To Len(aValores[1])
		
		nAux := 0
		
		For nY := 1 To Len(aValores[1][nX])
			
			If (oDanfe:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex) > nAux
				//nAux := Round(oDanfe:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex + 4, 0)
				nAux := oFontSize:getTextWidth( Alltrim(aValores[1][nX][nY]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
			EndIf
			
		Next nY
		
		If aTamCol[nX] < nAux
			aTamCol[nX] := nAux
		EndIf
		
	Next nX
	
	// Checa se os campos completam a p�gina, sen�o joga o resto na coluna da
	//   descri��o de produtos/servi�os
	nAux := 0
	For nX := 1 To Len(aTamCol)
		
		nAux += aTamCol[nX]
		
	Next nX
	If nAux < 603
		aTamCol[2] += 603 - nAux
	EndIf                       
	If nAux > 603               
		aTamCol[2] -= nAux - 603 
	EndIf
	
Return aTamCol

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamTex
Retorna o tamanho em pixels de uma string. (Workaround para o GetTextWidth)

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  cTexto   Texto a ser medido.
        oFont    Objeto instanciado da fonte a ser utilizada.
        oDanfe Objeto de impress�o instanciado.

@return nTamanho Tamanho em pixels da string.
/*/
//-----------------------------------------------------------------------
Static Function RetTamTex(cTexto, oFont, oDanfe)
	
	Local nTamanho := 0
	Local oFontSize:= FWFontSize():new() 
	
	//nTamanho := oDanfe:GetTextWidth(cTexto, oFont)
	nTamanho := oFontSize:getTextWidth( cTexto, oFont:Name, oFont:nWidth, oFont:Bold, oFont:Italic )
	
  	nTamanho := Round(nTamanho, 0)
	
Return nTamanho

//-----------------------------------------------------------------------
/*/{Protheus.doc} PosQuebrVal
Retorna a posi��o onde um valor deve ser quebrado

@author Marcos Taranta
@since 27/05/2011
@version 1.0 

@param  cTexto Texto a ser medido.

@return nPos   Posi��o aonde o valor deve ser quebrado.
/*/
//-----------------------------------------------------------------------
Static Function PosQuebrVal(cTexto)
	
	Local nPos := 0
	
	If Empty(cTexto)
		Return 0
	EndIf
	
	If Len(cTexto) <= MAXVALORC
		Return Len(cTexto)
	EndIf
	
	If SubStr(cTexto, MAXVALORC, 1) $ ",."
		nPos := MAXVALORC - 2
	Else
		nPos := MAXVALORC
	EndIf
	
Return nPos



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � EnvDanfe() � Autor � Iranildo Cavalcante � Data �20/Abr/12 ���
�������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������Ĵ��                     
���Descricao �Enviar danfe por e-mail									  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico COGERH.                                         ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EnvDanfe(vMail,vNota)
/*
Private _cDirOri	:= Alltrim(SuperGetMV("CO_DIRORI",.F.,"C:\"))
Private _cDirDST	:= Alltrim(SuperGetMV("CO_DIRDST",.F.,"\DANFE\"))
*/
Private _cDirOri	:= Alltrim("C:\")
Private _cDirDST	:= Alltrim("\DANFE\")

Private _aFiles		:= Directory(_cDirOri + "*.PDF")
                                                  
If Len(_aFiles) > 0
	OkProc(vMail,vNota)
EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � OKPROC   �Autor  � Iranildo Cavalcante  � Data � 25/04/2012���
�����������������������ͼ���������������������������ͼ�������������������͹��
���Descricao � Funcao Secundaria de Processamento E-mail.                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function OkProc(vMail,vNota)

For i := 1 To Len(_aFiles)
	_cArquivo := Alltrim(_cDirOri) + Alltrim(_aFiles[i,1])
	_cArqBKP  := Alltrim(_cDirDST) + Alltrim(_aFiles[i,1])

	copy file (_cArquivo) to (_cArqBkp) // Copia Arquivo Importado Para Diretorio de BackUp   	

    if Alltrim(vMail) <> ""
  		cAssunto 	 := "Danfe Cogerh Nf-e.:" +vNota
  		
		cTexto := "<html>"
		cTexto += "<body>"
		cTexto += '<p align="center">'
		cTexto += '<b>'
		cTexto += '<font color="#000080" face="Arial" size="4">'
		cTexto += "Segue Danfe N� "+Alltrim(vNota)+"." 
		cTexto += '</font>'
		cTexto += '</b>'
		cTexto += '</p>'
		cTexto += '<hr>'

		cTexto += '<font face="Arial">'
		cTexto += '<h3 align="center" style="color: #ff0000;">>>>>>>>>>> ATENC�O <<<<<<<<<<</h3>'
		cTexto += '<h3 align="left">RECOMENDAC�O IMPORTANTE:</h3>'
		cTexto += '<p align="justify">Prezado Cliente, favor conferir atentamente seus <b>DADOS CADASTRAIS</b> impressos na Danfe da NF-e, que acabam de chegar. Por determinac�o da <b>SEFAZ - SECRETARIA DA FAZENDA</b>, ap�s 1 dias de sua emiss�o, a Danfe da NF-e <b>N�O PODER�O SEREM CANCELADAS</b>.</p>'
		cTexto += '<p align="justify">Caso identifique algum dado inconsistente, entre em contato imediatamente com nossa Gerencia Comercial atrav�s do telefone: (85)3218-7065.</p>'
	
		cTexto += '<p align="LEFT"><b>'
		cTexto += 'Caso queira responder a este e-mail, gentileza encaminhar para o endere�o:'
		cTexto += '<br>'
		cTexto += '<a href="mailto:gerencia.comercial@cogerh.com.br">gerencia.comercial@cogerh.com.br'
		cTexto += '</a></b></p>'
		cTexto += '<p align="LEFT">'
		cTexto += 'Cia. de Gest�o dos Recusros H�dricos do Estado do Cear� - COGERH'
		cTexto += '<br>'
		cTexto += 'R. Adualdo Batista, 1550. Parque Iracema - CEP 60.824-140'
		cTexto += '<br>'
		cTexto += 'Fortaleza-CE - PABX: (85) 3218-7020 FAX: (85)3218-7066'
		cTexto += '<br>'
		cTexto += '<a href="http://www.cogerh.com.br" target="COGERH">http://www.cogerh.com.br'
		cTexto += '</font></p>'
		cTexto += '</body>'
		cTexto += '</html>'
		
		cMailDestino := Alltrim(vMail) + ";microsiga@cogerh.com.br"
                                 
        // Colocar aqui a grava��o da danfe na pasta desejada

	  	U_envMail(cMailDestino,cAssunto,cTexto,_cArqBkp)	
   	endif

    // Deleta Arquivo da Area de Importacao
	If File(_cArqBkp) 
		Ferase(_cArquivo)
	EndIf
Next i	

Return Nil



/*
User Function EnvMail(cMailDestino,cAssunto,cTexto,cAnexos)

Local cAccount	:= GetMV("MV_RELACNT")//Conta de e-mail para enviar a msg
Local cPassword	:= GetMV("MV_RELPSW") //senha da conta definida acima
Local cServer	:= GetMV("MV_RELSERV")//IP do servidor de e-mail
Local cEmailde  := GetMV("MV_RELFROM")//Endereco de e_mail que vai enviar a msg o mesmo da conta

Local lMensagem	:= .T.
Local cRet 		:= .f.

cRet := TkSendMail(	cAccount,cPassword,cServer,cEmailde,cMailDestino,cAssunto,cTexto,cAnexos)

If cRet
	Aviso('E-Mail','E-Mail enviado com sucesso!',{"OK"},2,"Ok!",) 
Else
	Aviso('E-Mail','E-Mail N�O pode ser enviado!',{"OK"},2,"Favor Verificar.",) 
EndIf

Return()

*/
