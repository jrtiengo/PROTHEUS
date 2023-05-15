#include "Totvs.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"

/*
+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA607   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | workflow de envio das nota bloqueada para avaliação do gestor             |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via PE SF1140I                                                  |
+-----------+---------------------------------------------------------------------------+
*/
User Function EVOA607(aemp)

	Local cMensagem :=""
	//Local cAccount	:=""
	//Local cPassword	:=""
	//Local cFrom		:=""
	Local cTitulo   :='Nota Pendente de Liberação do Gestor '
	Local cTo
	Local aArea     :=GetArea()
	Local cLiber    :=''
	//Local cToGesSub:=''

	If Select("SX2") <= 0
		RPCClearEnv()
		RPCSetEnv(aEmp[1],aEmp[2],"","","","")
		u_fMyAlert('Abrindo tabelas...')
	END
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN
	end


	//u_fMyAlert('entrei evoa607')

	dbSelectArea('SA2')
	dbSetOrder(1)
	dbseek(xfilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA)

	dbSelectArea('SD1')
	dbSetOrder(1)
	dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))

	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek(xfilial('SB1')+SD1->D1_COD)

	IF Empty(SA2->A2_GRPAPRO)
		cTo:=getmv('ES_WF60XTO')
		cTitulo:=alltrim(cTitulo)+'-(Grupo de Liberação Não Informado)'
	else

		cTo:=fQueMail(SA2->A2_COD,SA2->A2_LOJA)
		cLiber:=fQueLibera(SA2->A2_COD,SA2->A2_LOJA)

	END
	cCC:='' //manoel.mariante@gmail.com'
	aAttach:={}

	cMensagem := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
	cMensagem += '<html> '
	cMensagem += '<head> '
	cMensagem += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"> '
	cMensagem += '  <title> '+cTitulo+'</title> '
	cMensagem += '</head> '
	cMensagem += '<body> '
	cMensagem += '<hr>'
	cMensagem += '<img src="https://www.evora.com/images/logo@2x.png" > '
	cMensagem += '<br> '
	cMensagem += '<br> '
	cMensagem += '<hr>'
	cMensagem += '<FONT COLOR=BLACK SIZE="4"> '+cTitulo+' </FONT>'
	cMensagem += '<br> '

	if empty(cLiber)
		cMensagem += '<FONT COLOR=BLACK SIZE="3"> Liberador: NÃO INFORMADO NO GRUPO DE APROVAÇÃO</FONT>'
	else
		cMensagem += '<FONT COLOR=BLACK SIZE="3"> Liberador:'+ cLiber+'</FONT>'
	END

	nTotNota:=u_fQueTotal() //precisa estar em cima da SF1

	cMensagem += '<hr>'
	cMensagem += '<table> '
	cMensagem += '<TABLE BORDER=1 BORDERCOLOR=BLUE >'
	cMensagem += '<tr>'
	cMensagem += '<th ROWSPAN=2 WIDTH=300 BGCOLOR=RED><FONT COLOR=WHITE>Documento</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=400 BGCOLOR=RED><FONT COLOR=WHITE>Fornecedor</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=100 BGCOLOR=RED><FONT COLOR=WHITE>Emissão</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=150 BGCOLOR=RED><FONT COLOR=WHITE>Valor</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=150 BGCOLOR=RED><FONT COLOR=WHITE>Serviço</th>'
	cMensagem += '</tr>'
	cMensagem += '<tr>'
	cMensagem += '</tr>'
	cMensagem += '<tr>'
	cMensagem += '<td <FONT COLOR=BLACK> '+SF1->F1_DOC+'/'+SF1->F1_SERIE+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK>'+SA2->A2_NOME+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+dtoc(SF1->F1_EMISSAO)+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+TRANSFORM(nTotNota,"@E 9999,999,999.99")+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+alltrim(SB1->B1_DESC)+'</td>'
	cMensagem += '</tr>'
	cMensagem += '</table> '
	cMensagem += '<br> '
	cMensagem += '<hr>'
	cMensagem += 'E-mail gerado automaticamente pelo Protheus em '+dtoc(msdate())+' as '+left(time(),5)
	cMensagem += '<br> '

	MEMOWRIT('\logs\evoa607.HTM', cMensagem)

	//lOk:=u_SendMail(cAccount,cPassword,cFrom,cTo,"",cTitulo,cMensagem,"")

	lOk:=U_EnvMail(cTo, cCC, cTitulo, cMensagem, aAttach)

	RestArea(aArea)

Return lOk


//-------------------------------------------------------------------
Static Function fQueMail(cForn,cLoja)
//-------------------------------------------------------------------
	Local cQuery:='',cRet:=''
	Local aArea:=GetArea()

	cQuery+=" SELECT * "
	cQuery+=" FROM "+RetSqlTab("ZZ2,SA2")
	cQuery+=" WHERE "+RetSqlFil("ZZ2,SA2")
	cQuery+=" AND "+RetSqlDel("ZZ2,SA2")
	cQuery+=" AND ZZ2_GRUPO=A2_GRPAPRO "
	cQuery+=" AND A2_COD='"+cForn+"' "
	cQuery+=" AND A2_LOJA='"+cLoja+"' "
	cQuery+=" AND ZZ2_EMP='"+cEmpAnt+"' "

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRBZ", .t., .t.)
	dbSelectArea('TRBZ')
	While !eof()
		If !Empty(cRet)
			cRet+=';'
		End
		cRet+=UsrRetMail(TRBZ->ZZ2_USER)

		dbskip()
	End

	dbclosearea()
	RestArea(aArea)

Return cRet


//-------------------------------------------------------------------
Static Function fQueLibera(cForn,cLoja)
//-------------------------------------------------------------------
	Local cQuery:='',cRet:=''
	Local aArea:=GetArea()

	cQuery+=" SELECT * "
	cQuery+=" FROM "+RetSqlTab("ZZ2,SA2")
	cQuery+=" WHERE "+RetSqlFil("ZZ2,SA2")
	cQuery+=" AND "+RetSqlDel("ZZ2,SA2")
	cQuery+=" AND ZZ2_GRUPO=A2_GRPAPRO "
	cQuery+=" AND A2_COD='"+cForn+"' "
	cQuery+=" AND A2_LOJA='"+cLoja+"' "
	cQuery+=" AND ZZ2_TIPO='2' "
	cQuery+=" AND ZZ2_EMP='"+cEmpAnt+"' "

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRBZ", .t., .t.)
	dbSelectArea('TRBZ')
	If !eof()
		cRet:=TRBZ->ZZ2_NOMUSR
	end

	dbclosearea()
	RestArea(aArea)

Return cRet


//-------------------------------------------------------------------
User Function fQueTotal(cForn,cLoja)
//-------------------------------------------------------------------
	Local cQuery:='',nRet:=0
	Local aArea:=GetArea()

	cQuery+=" SELECT SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE-D1_VALDESC) TOTAL"
	cQuery+=" FROM "+RetSqlTab("SD1")
	cQuery+=" WHERE "+RetSqlFil("SD1")
	cQuery+=" AND "+RetSqlDel("SD1")
	cQuery+=" AND D1_DOC='"+SF1->F1_DOC+"' "
	cQuery+=" AND D1_SERIE='"+SF1->F1_SERIE+"' "
	cQuery+=" AND D1_FORNECE='"+SF1->F1_FORNECE+"' "
	cQuery+=" AND D1_LOJA='"+SF1->F1_LOJA+"' "

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRBZ", .t., .t.)
	dbSelectArea('TRBZ')
	nRet:=TRBZ->TOTAL

	dbclosearea()
	RestArea(aArea)

Return nRet

