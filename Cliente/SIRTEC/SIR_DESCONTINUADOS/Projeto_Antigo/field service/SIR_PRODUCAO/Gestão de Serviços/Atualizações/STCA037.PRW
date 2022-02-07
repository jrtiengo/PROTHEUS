#include "rwmake.ch"
#include "protheus.ch"

/*
--------------------------------------------------------------------------------------------------------------------------------------------------
Função: STCA037

Tipo: Função de usuário executada em P.E.

Descrição: Envio de mensagem de manutenção da OS

Data de criação: 24/01/2009

Uso: SIRTEC - Field Service

Parâmetros:

Retorno:
--------------------------------------------------------------------------------------------------------------------------------------------------
*/
User Function STCA037

Local aArea  	:= GetArea()									//Controle da area
Local _nAcao	:= PARAMIXB[1]            						//Opção acessada pelo usuario
Local cTexto    := ""											//Monta mensagem
Local MV_YMSFLD := Alltrim(GetMv("MV_YMSFLD"))       
Local aInfo     := {} 
Local cInfRem,cInfDes,cInfAst,cInfMen,cInfAne,cInfFor  

//Verifica opçao
If _nAcao == 1
	_cOpcao := 'Incluir'
ElseIf _nAcao == 2
	_cOpcao := 'Alterar'
ElseIf _nAcao == 3
	_cOpcao := 'Excluir'
Else
	_cOpcao := 'Outra'	
EndIf

//Compoe texto da mensagem
cTexto:='<TABLE WIDTH=100% height=40%>
cTexto+='	<TR>
cTexto+='		<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='			<FONT  SIZE="5" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='			REPAIR CENTER - Atendimento de OS<BR/>
cTexto+='			</FONT>
cTexto+='		</TH>
cTexto+='	</TR>
cTexto+='	<TR>
cTexto+='		<TD align="left" BGCOLOR="#FFFFFF">
cTexto+='			<FONT  SIZE="-3" COLOR="#201D84" FACE="verdana, arial, helvetica, times" >
cTexto+='			Você está recebendo uma mensagem da rotina de Atendimento de OS.
cTexto+='			</FONT>
cTexto+='		</TD>
cTexto+='	</TR>
cTexto+='</TABLE>
cTexto+='<P>
cTexto+='	<TABLE WIDTH=50%>
cTexto+='		<CAPTION ALIGN="left">
cTexto+='		<FONT SIZE="2" COLOR="#202664" FACE="verdana, arial, helvetica, times" >
cTexto+='		<B>
cTexto+='		Atendimento da OS:
cTexto+='		</B>
cTexto+='		</FONT>
cTexto+='		</CAPTION>
cTexto+='		<TR>
cTexto+='			<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='				<FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='				Ação
cTexto+='				</FONT>
cTexto+='			</TH>
cTexto+='			<TD ALIGN="left" BGCOLOR="#C0C0FF">
cTexto+='				<FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >
cTexto+='				' + _cOpcao
cTexto+='				</FONT>
cTexto+='			</TD>
cTexto+='		</TR>
cTexto+='		<TR>
cTexto+='			<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='				<FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='				Ordem de Servico <br> Sequencia
cTexto+='				</FONT>
cTexto+='			</TH>
cTexto+='			<TD ALIGN="left" BGCOLOR="#C0C0FF">
cTexto+='				<FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >
cTexto+='				' + M->AB9_NUMOS + ' <br> ' + M->AB9_SEQ
cTexto+='				</FONT>
cTexto+='			</TD>
cTexto+='		</TR>
cTexto+='		<TR>
cTexto+='			<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='				<FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='				Tecnico
cTexto+='				</FONT>
cTexto+='			</TH>
cTexto+='			<TD ALIGN="left" BGCOLOR="#C0C0FF">
cTexto+='				<FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >
cTexto+='				' + M->AB9_CODTEC
cTexto+='				</FONT>
cTexto+='			</TD>
cTexto+='		</TR>
cTexto+='		<TR>
cTexto+='			<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='				<FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='				Data
cTexto+='				</FONT>
cTexto+='			</TH>
cTexto+='			<TD ALIGN="left" BGCOLOR="#C0C0FF">
cTexto+='				<FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >
cTexto+='				' + dtoc(M->AB9_DTCHEG)
cTexto+='				</FONT>
cTexto+='			</TD>
cTexto+='		</TR>
cTexto+='		<TR>
cTexto+='			<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='				<FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='				Hora
cTexto+='				</FONT>
cTexto+='			</TH>
cTexto+='			<TD ALIGN="left" BGCOLOR="#C0C0FF">
cTexto+='				<FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >
cTexto+='				' + M->AB9_HRCHEG
cTexto+='				</FONT>
cTexto+='			</TD>
cTexto+='		</TR>			
cTexto+='		<TR>
cTexto+='			<TH ALIGN="left" BGCOLOR="#202664">
cTexto+='				<FONT  SIZE="2" COLOR="#FFFFFF" FACE="verdana, arial, helvetica, times" >
cTexto+='				Usuario
cTexto+='				</FONT>
cTexto+='			</TH>
cTexto+='			<TD ALIGN="left" BGCOLOR="#C0C0FF">
cTexto+='				<FONT  SIZE="2" COLOR="#000000" FACE="verdana, arial, helvetica, times" >
cTexto+='				' +Alltrim(cUserName)
cTexto+='				</FONT>
cTexto+='			</TD>
cTexto+='		</TR>
cTexto+='	</table>
cTexto+='</P>

//Dados da mensagem
cInfRem := ''
cInfDes := MV_YMSFLD
cInfAst := "Protheus11: Atendimento de OS"
cInfMen := cTexto
cInfAne := ''
cInfFor := 'S'

//Adiciona e-mail a ser enviado
AADD(aInfo,{cInfRem,cInfDes,cInfAst,cInfMen,cInfAne,cInfFor})

//Envia email
U_STCA031(aInfo,1)

RestArea(aArea)
Return