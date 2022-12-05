#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE  ENTER CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � T450PVOS       � Autor�Fabiano Pereira� Data � 29/04/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     �O  ponto de entrada T450PVOS possibilita decidir se         ���
���          �gera pedido de vendas a partir de da inclus�o ou            ���
���          �altera��o de uma OS.                                    	  ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������ĺ��
���Observacao� AB6/AB7/AB8 ja gravado.                                    ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 11  -  AUTOMATHEC                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*****************************************************************************
User Function T450PVOS()
*****************************************************************************
Local aAlias :=	GetArea()

   U_AUTOM628("T450PVOS")

// Em caso de inclus�o, envia para programas de envio de email e impress�o de etiqueta do produto do atendimento t�cnico.
If Inclui .Or. Altera

	// Verifica se j� foi enviado e-mail informativo ao cliente da abertura do atendimento.
	// Se n�o, dispara o programa AUTOM102 que envia e-mail ao cliente.
	//If Empty(AllTrim(AB6->AB6_ENVIOA))
		// U_AUTOM102("I", AB6->AB6_ETIQUE, 'AB6', AB6->(Recno()) )
		// EmailOpenOS()
        // ExecBlock('AUTOMWFOS', .F., .F.)
	//EndIf
    
	If Inclui
	
       If FunName() == "TECA640"
       Else

          If Altera
    		 
    		 //	Print comprovante de entrega do equipamento.
   		     U_AUTOM109() 
			
		     // Envia para o programa que imprime etiqueta do poduto na abertura do chamado t�cnico.
//		     U_AUTOMR11()

		  Endif
		     
	   Endif	  
	
	EndIf	
	
EndIf

RestArea(aAlias)
Return()
*****************************************************************************
Static Function EmailOpenOS()
*****************************************************************************
Local aAliasAB6 := 	GetArea()
Local cNumOSAB6	:=	AB6->AB6_NUMOS
Local aProduto  := 	{}
Local nRecnoAB6 :=  AB6->(Recno())

If MsgYesNo("Deseja enviar e-mail ao cliente informando da abertura da Ordem de Servi�o ?")
   
	_cNomeCli := AllTrim(Posicione("SA1",1,xFilial("SA1")+AB6->AB6_CODCLI+AB6->AB6_LOJA,"A1_NOME"))
	_Email 	  := AllTrim(Posicione('SU5',1,xFilial('SU5')+AB6->AB6_CONTWF,'U5_EMAIL'))

	If !Empty(_Email)

	      DbSelectArea('AB7');DbSetOrder(1);DbGoTop()
	      If DbSeek(xFilial('AB7')+cNumOSAB6, .F.)
		      Do While !Eof() .And. AB7->AB7_NUMOS == cNumOSAB6
	                                                    
				  cDescProd := 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DESC'))
		          cDAux 	:= 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DAUX'))
		          cDescProd := 	cDescProd + IIF(!Empty(cDAux), +cDAux, '')
		          
			      Aadd(aProduto, { AllTrim(AB7->AB7_CODPRO), cDescProd, AB7->AB7_NUMSER } )
	
		      	DbSelectArea('AB7')
		      	DbSkip()
		      EndDo
          EndIf                  
		 
		
		//���������������������Ŀ
		//�   CABEC DO E-MAIL	�
		//�����������������������
		cHtml	:= '<html>'
		cHtml	+= '<head>'
		
		cHtml	+= '<h3 align = Left><font size="3" color="#0000FF" face="Verdana"> ABERTURA ORDEM DE SERVI�O</h3></font>'
		cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">Informamos que foi aberto a Ordem de Servi�o n� '+cNumOSAB6+' </h3></font>'
		cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">para o(s) equipamento(s):</h3></font>'
		cHtml	+= '</head>'

		cHtml	+= '<br></br>'
		
		
		//���������������������Ŀ
		//�   	CABEC GRID		�
		//�����������������������
		cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'
		
			cHtml += '	<TR ALIGN=TOP>'
			cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
			cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>PRODUTO</P></font>'
			cHtml += '		</TD>'	
			
			cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
			cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DESCRI��O</P></font>'
			cHtml += '		</TD>'	

			cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
			cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>NUM.SERIE</P></font>'
			cHtml += '		</TD>'	
			
			cHtml += '	</TR>'
			                       
			// Aadd(aProduto, { AllTrim(AB7->AB7_CODPRB) , AllTrim(AB7->AB7_DESCPR)+IIF(!Empty(cDAux), +cDAux, ''), AB7->AB7_NUMSER } )		
			For nX := 1 To Len(aProduto)

				cHtml += '<TR ALIGN=TOP>'		
				cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
				cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][01]+'</P></font>'
				cHtml += '		</TD>'

				cHtml += '		<TD ALIGN=LEFT bgcolor=#FFFFFF>'
				cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][02]+'</P></font>'
				cHtml += '		</TD>'

				cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
				cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> '+aProduto[nX][03]+'</P></font>'
				cHtml += '		</TD>'
				cHtml += '</TR>'
				
			Next			

			cHtml 	+= '</TABLE>'

	   		
	   		// PEGA O PRIMEIRO REGISTRO DA TABELA
			DbSelectArea('ZZ4');DbSetOrder(1);DbGoTop()
			nVal_Orcamento := ZZ4->ZZ4_PRECO
	
			cHtml 	+= '<P STYLE="margin-bottom: 0cm"><BR></P>'

			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> OBS.: Caso a Ordem de Servi�o enviado venha a n�o ser aprovado, informamos que podera </font></b>'
			cHtml	+= '<br></br>'
			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> ocorrer uma cobran�a de uma taxa de reprova��o no valor de R$ '+TransForm(nVal_Orcamento,"@E 999,999.99")+' decorrente do </font></b>'
			cHtml	+= '<br></br>'
			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> tempo de analise do t�cnico. </font></b>'
			cHtml	+= '<br></br>'
			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> Att. </font></b>'
			cHtml	+= '<br></br>'
			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> Automatech Sistemas de Automa��o Ltda </font></b>'
			cHtml	+= '<br></br>'
			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> Fone: (51) - 3017-8300 </font></b>'
			cHtml	+= '<br></br>'
			cHtml 	+= '<b><font size="2" color=#FF0000 face="Verdana"> www.automatech.com.br </font></b>'
			cHtml	+= '<br></br>'
			cHtml	+= '<br></br>'

			cHtml 	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, n�o responda este e-mail </font></b>'
			cHtml	+= '<br></br>'
			cHtml	+= '<br></br>'
			cHtml 	+= '</head>'
			cHtml 	+= '</html>'
		        
	      MemoWrit(GetTempPath()+'EMAIL_T450PVOS.html', cHtml)
         // Envia o relat�rio via e-mail
         cErroEnvio := U_AUTOMR20(cHtml, Alltrim(_Email), "", "Aviso de Abertura de Atendimento.")
		 If Empty(cErroEnvio)         
			DbSelectArea('AB6')         
			If nRecnoAB6 != AB6->(Recno())
				DbGoTo(nRecnoAB6)
			Endif

			If nRecnoAB6 == AB6->(Recno())
				RecLock("AB6", .F.)
					AB6->AB6_ENVIOA := Date()
				MsUnlock()
			EndIf
			
		 EndIf

	Else
		Msgalert("Cliente n�o possui e-mail cadastrado. Verifique!")
	EndIf
    

EndIf

Return(aAliasAB6)