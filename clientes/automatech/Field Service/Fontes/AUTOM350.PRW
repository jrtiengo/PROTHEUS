#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM350.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/06/2016                                                          *
// Objetivo..: Programa que envia e-mail de encerramento da Ordem de Serviço.      *
//             Este programa é disparado pelo ponto de entrada PE_TECA450          *
// Parâmetros: Filial da Ordem de Serviço                                          *
//             Nº da Ordem de Serviço                                              *
//**********************************************************************************

User Function AUTOM350(_Filial, _Ordem)

   Local aAliasAB6 := GetArea()
   Local cFilialOS := _Filial
   Local cNumOSAB6 := _Ordem
   Local aProduto  := {}

   // Posiciona a Ordem de Serviço
   DbSelectArea("AB6")
   DbSetOrder(1)
   DbGoTop()

   If DbSeek(xFilial("AB6") + cNumOSAB6)
 	  _Email    := AllTrim(Posicione('SU5',1,xFilial('SU5') + AB6->AB6_CONTWF,'U5_EMAIL'))
	  _cNomeCli := AllTrim(Posicione("SA1",1,xFilial("SA1") + AB6->AB6_CODCLI + AB6->AB6_LOJA,"A1_NOME"))
   EndIf
	
   If !Empty(_Email)
		
	  DbSelectArea('AB7')
	  DbSetOrder(1)
	  DbGoTop()
		 
	  If DbSeek(xFilial('AB7') + cNumOSAB6, .F.)
		 
		 Do While !Eof() .And. AB7->AB7_NUMOS == cNumOSAB6
				
		    cDescProd := AllTrim(Posicione('SB1',1,xFilial('SB1') + AB7->AB7_CODPRO,'B1_DESC'))
		    cDAux 	  := AllTrim(Posicione('SB1',1,xFilial('SB1') + AB7->AB7_CODPRO,'B1_DAUX'))
		    cDescProd := cDescProd + IIF(!Empty(cDAux), + cDAux, '')
				
		    Aadd(aProduto, { AllTrim(AB7->AB7_CODPRO), cDescProd, AB7->AB7_NUMSER } )
				
			DbSelectArea('AB7')
			DbSkip()

 		 EndDo

	  EndIf
		
	  // Cabeçalho do Email
	  cHtml	:= '<html>'
	  cHtml	+= '<head>'
	  cHtml	+= '<h3 align = Left><font size="3" color="#0000FF" face="Verdana"> FECHAMENTO ORDEM DE SERVIÇO</h3></font>'
	  cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">Informamos que foi encerrado a Ordem de Serviço nº ' + cNumOSAB6 + ' </h3></font>'
	  cHtml	+= '<h3 align = Left><font size="3" color="#000000" face="Verdana">para o(s) equipamento(s):</h3></font>'
	  cHtml	+= '</head>'
	  cHtml	+= '<br></br>'
		
	  // Cabeçalho do Grid
	  cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'
		
	  cHtml += '	<TR ALIGN=TOP>'
	  cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
	  cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>PRODUTO</P></font>'
	  cHtml += '		</TD>'
		
	  cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
	  cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DESCRIÇÃO</P></font>'
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
			
	  Next nX
		
	  cHtml	+= '</TABLE>'
	  cHtml	+= '<P STYLE="margin-bottom: 0cm"><BR></P>'
	  cHtml	+= '<b><font size="2" color=#FF0000 face="Verdana"> Att. </font></b>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<b><font size="2" color=#FF0000 face="Verdana"> Automatech Sistemas de Automação Ltda </font></b>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<b><font size="2" color=#FF0000 face="Verdana"> Fone: (51) - 3017-8300 </font></b>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<b><font size="2" color=#FF0000 face="Verdana"> www.automatech.com.br </font></b>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, não responda este e-mail </font></b>'
	  cHtml	+= '<br></br>'
 	  cHtml	+= '<br></br>'
 	  cHtml	+= '</head>'
 	  cHtml	+= '</html>'
		
	  // Envia o relatório via e-mail
	  MemoWrit(GetTempPath()+'EMAIL_PE_TECA460.html', cHtml)
	 
	  cErroEnvio := U_AUTOMR20(cHtml, Alltrim(_Email), "", "Aviso de Encerramento da Ordem de Serviço.")
		
      // Em caso de envio com sucesso, poderá aqui atualizar o que foi necessário
	  If Empty(cErroEnvio)
	  EndIf
		
   EndIf
	
Return(.T.)