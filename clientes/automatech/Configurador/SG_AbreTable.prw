#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "INKEY.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |CP_AbreTableºAutor  ³Fabiano Pereira     º Data ³ 04/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          |AxCadastro - Informe o Alias da Tabela que o prw abre.        º±±
±±º          |Controle para Tabela SZZ - Usuario X Parametros.              º±±
±±º          |                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 - Novus                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***********************************************************************
User Function SG_AbreTable()
***********************************************************************
Local cVldAlt := ".T."  // Permitir a alteracao. //
Local cVldExc := ".T."  // Permitir a exclusao.  //
Local	cTabela := Space(03)

                    
oFont1     := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
oDlg1      := MSDialog():New( 091,232,248,559,"AxCadastro",,,.F.,,,,,,.T.,,oFont1,.T. )
oGrp1      := TGroup():New( 004,012,048,140,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 014,044,{||"Abrir Tabela"},oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oGet1      := TGet():New( 028,044,{|u| If(PCount()>0,cTabela:=u,cTabela)},oGrp1,060,008,'@!',{|| IIF( SX2->(DbSeek(cTabela,.F.)), cTabela, MsgAlert('Tabela ['+cTabela+'] não encontrada no SX2'))  },CLR_BLACK,CLR_WHITE,oFont1,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SX2PAD","",,)  
oSBtn1     := SButton():New( 052,056,1,{|| oDlg1:End() },oDlg1,,"", )	
oDlg1:Activate(,,,.T.)
 

If !Empty(cTabela)
	DbSelectArea(cTabela)
	AxCadastro(cTabela,"Abre Tabela",cVldAlt,cVldExc)
EndIf

Return