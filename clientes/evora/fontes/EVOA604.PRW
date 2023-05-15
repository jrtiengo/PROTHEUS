#include "Totvs.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#include 'topconn.ch'

/*+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA604   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | workflow de envio de titulos para a diretoria liberar os pagtos           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via job                                                         |
+-----------+---------------------------------------------------------------------------+*/
User Function EVOA604(aEmp)

	Local cMensagem :=""
	Local cTo		:="" 
	//Local cAccount	:=""
	//Local cPassword	:=""
	//Local cFrom		:=""
    Local cQuery    :=""
    Local cTitulo   :=""
    Local nSldTot   :=0
    Local nOriTot   :=0
	Local aAnexos	:={}
	DEFAULT aEmp	:={'01','01'}
	

	If Select("SX2") <= 0
        RPCClearEnv()
        RPCSetEnv(aEmp[1],aEmp[2],"","","","")
	End
	Private cPathBco:="\dirdoc\co"+alltrim(SM0->M0_CODIGO)+"\shared\"

		If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN 
	end


    cTo		    :=getmv('ES_WF604TO') 
	
    nDiaSem     :=Val(Alltrim(GETMV('ES_WF604DS')))
    nDiasAntes  :=GETMV('ES_WF604DA')
	IF nDiaSem==1
        cDesDia :='no Domingo'
	ELSEIF nDiaSem==2
        cDesDia :='na Segunda-Feira'
	ELSEIF nDiaSem==3
        cDesDia :='na Terça-Feira'
	ELSEIF nDiaSem==4
        cDesDia :='na Quarta-Feira'
	ELSEIF nDiaSem==5
        cDesDia :='na Quinta-Feira'
	ELSEIF nDiaSem==6
        cDesDia :='na Sexta-Feira'
	ELSEIF nDiaSem==7
        cDesDia :='no Sábado'
	End

    /*
    cTitulo :='Titulos Pendentes de Liberação Com Vencimento  '+cDesDia

    cQuery+=" SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_EMISSAO,E2_HIST,"
    cquery+=" E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_VENCREA,E2_EMISSAO,E2_VALOR,E2_SALDO "
    cQuery+=" FROM "+RETSQLNAME("SE2")+" SE2"
    cQuery+=" WHERE DATEPART(DW, cast(E2_VENCREA AS SMALLDATETIME )) = "+Alltrim(nDiaSem)
    cQuery+=" AND E2_DATALIB='' "
    cQuery+=" AND E2_SALDO<>0 "
    cQuery+=" AND '"+DTOS(dDataBase+nDiasAntes)+"' >= E2_VENCREA "
    cQuery+=" AND D_E_L_E_T_=''"
    cQuery+=" AND D_E_L_E_T_=''"
    */

dVctoAte	:=dDataBase+7
While DOW(dVctoAte) <> nDiaSem-1
	dVctoAte++
End

dDataPgto	:=dDataBase+1
While DOW(dDataPgto) <> nDiaSem
	dDataPgto++
End

cTitulo :='Titulos Pendentes de Liberacao Com Vencimento até '+dtoc(dVctoAte)+' com previsão de pagamento '+cDesDia+' dia '+dtoc(dDataPgto)

cQuery+=" SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_EMISSAO,E2_HIST,"
cquery+=" E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_VENCREA,E2_VALOR,E2_SALDO "
cQuery+=" FROM "+RETSQLNAME("SE2")+" SE2"
cQuery+=" WHERE "
cQuery+=" E2_VENCREA>='"+dtos(dDataBase-180)+"'"
cQuery+=" AND E2_VENCREA<='"+dtos(dVctoAte)+"'"
cQuery+=" AND E2_SALDO<>0 "
cQuery+=" AND E2_DATALIB='' "
cQuery+=" AND D_E_L_E_T_=''"
cQuery+=" ORDER BY "+SUPERGETMV("ES_604ORD",.F.,"E2_EMISSAO")

MEMOWRIT('\logs\evoa604.SQL', cQuery)

dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRB", .t., .t.)

dbSelectArea('TRB')

DBGOTOP()

cMensagem := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
cMensagem += '<html> '
cMensagem += '<head> '
cMensagem += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"> '
cMensagem += '  <title> '+cTitulo+'</title> '
cMensagem += '<style type="text/css">'
cMensagem += 't   { font-size: 14px ; font-weight: bold; color:WHITE;background-color:blue ; font-family: Calibri,Helvetica, Geneva, Arial,SunSans-Regular, sans-serif }'
cMensagem += 'c   { font-size: 12px ; background-color:white; font-family: Calibri,Helvetica, Geneva, Arial,SunSans-Regular, sans-serif }'
cMensagem += 'tit { font-size: 20px ;                         font-family: Calibri,Helvetica, Geneva, Arial,SunSans-Regular, sans-serif }'
cMensagem += '</style>'
cMensagem += '</head> '
cMensagem += '<body> '
cMensagem += '<hr>'
cMensagem += '<img src="https://www.evora.com/images/logo@2x.png" > '
cMensagem += '<br> '
cMensagem += '<br> '
cMensagem += '<hr>'
cMensagem += '<tit> '+cTitulo+' </tit>'
cMensagem += '<hr>'
cMensagem += '<tit> Empresa:'+SM0->M0_CODIGO+'-'+SM0->M0_NOME+'</tit>'
cMensagem += '<hr>'
cMensagem += '<TABLE BORDER=1 BORDERCOLOR=BLUE cellspacing="1">'
cMensagem += '<tr>'
cMensagem += '<th BGCOLOR=BLUE><t>Código</t> </th>'
cMensagem += '<th BGCOLOR=BLUE WIDTH=550><t>Nome Fornecedor</t></th>'
cMensagem += '<th BGCOLOR=BLUE WIDTH=250><t>Prf-Num-Parcela</t></th>'
cMensagem += '<th BGCOLOR=BLUE><t>Tipo </t></th>'
cMensagem += '<th BGCOLOR=BLUE><t>Emissão</t></th>'
cMensagem += '<th BGCOLOR=BLUE><t>Vencimento Real</t></th>'
cMensagem += '<th BGCOLOR=BLUE><t>Valor Original</t></th>'
cMensagem += '<th BGCOLOR=BLUE><t>Saldo</t></th>'
cMensagem += '<th BGCOLOR=BLUE WIDTH=450><t>Histórico</t></th>'
cMensagem += '<th BGCOLOR=BLUE WIDTH=450><t>Obs.do Gestor</t></th>'
cMensagem += '</tr>'

While !eof()

	cMensagem += '<tr>'
	cMensagem += '<td><c>'+TRB->E2_FORNECE+'/'+TRB->E2_LOJA+'</c></td>'
	cMensagem += '<td><c>'+TRB->E2_NOMFOR+'</c></td>'
	cMensagem += '<td><c>'+TRB->(E2_PREFIXO+'-'+E2_NUM+'/'+E2_PARCELA)+'</c></td>'
	cMensagem += '<td><c>'+TRB->(E2_TIPO)+'</c></td>'
	cMensagem += '<td ALIGN=MIDDLE><c>'+dtoc(stod(TRB->E2_EMISSAO))+'</c></td>'
	cMensagem += '<td ALIGN=MIDDLE><c>'+dtoc(stod(TRB->E2_VENCREA))+'</c></td>'
	cMensagem += '<td ALIGN=MIDDLE><c>'+TRANSFORM(TRB->E2_VALOR,"@E 9999,999,999.99")+'</c></td>'
	cMensagem += '<td ALIGN=MIDDLE><c>'+TRANSFORM(TRB->E2_SALDO,"@E 9999,999,999.99")+'</c></td>'
	cMensagem += '<td><c>'+TRB->E2_HIST+'</c></td>'

	nSldTot+=TRB->E2_SALDO
	nOriTot+=TRB->E2_VALOR
	cObsGest:=''

	dbSelectArea('SZ1')
	dbSetOrder(1)
	If dbSeek(xFilial("SZ1")+TRB->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA))
		cObsGest:=SZ1->Z1_OBS
	end
	cMensagem += '<td><c>'+cObsGest+'</c></td>'
	cMensagem += '</tr>'

		/*
		//anexa os arquivos que estão ligadas a NF desse titulo
		aRet:=fQueBanco()

		For nA:=1 to Len(aRet)
			Aadd(aAnexos,aRet[nA])
		Next
		*/

	dbSelectArea('TRB')

	dbskip()

End
cMensagem += '<tr>'
cMensagem += '<td BGCOLOR=BLUE><t>TOTAIS</t></td>'
cMensagem += '<td BGCOLOR=BLUE><c>  </c></td>'
cMensagem += '<td BGCOLOR=BLUE><c>  </c></td>'
cMensagem += '<td BGCOLOR=BLUE><c>   </c></td>'
cMensagem += '<td BGCOLOR=BLUE ALIGN=MIDDLE><c>  </c></td>'
cMensagem += '<td BGCOLOR=BLUE ALIGN=MIDDLE><c>    </c></td>'
cMensagem += '<td BGCOLOR=BLUE ALIGN=MIDDLE><t>'+TRANSFORM(nOriTot,"@E 9999,999,999.99")+'</t></td>'
cMensagem += '<td BGCOLOR=BLUE ALIGN=MIDDLE><t>'+TRANSFORM(nSldTot,"@E 9999,999,999.99")+'</t></td>'
cMensagem += '<td BGCOLOR=BLUE><c>   </c></td>'
cMensagem += '<td BGCOLOR=BLUE><c>   </c></td>'
cMensagem += '</tr>'

cMensagem += '</table> '
cMensagem += '<br> '
cMensagem += '<hr>'
cMensagem += 'E-mail gerado automaticamente pelo Protheus em '+dtoc(msdate())+' as '+left(time(),5)
cMensagem += '<br> '

MEMOWRIT('\logs\evoa604.HTM', cMensagem)
//if u_MySendMail(cTo,'','',cTitulo,cMensagem,aAnexos)
IF U_EnvMail(cTo, '', cTitulo, cMensagem, {})
	//if u_SendMail(cAccount,cPassword,cFrom,cTo,"",cTitulo,cMensagem,aAnexos)
	u_fMyAlert("E-mail enviado para "+cTo)
else
	u_fMyAlert("ERRO para enviar E-mail para "+cTo)
End

dbSelectArea('TRB')
DBCLOSEAREA(  )

Return

//-------------------------------------------------------------------------------------------------
Static Function fQueBanco()
//-------------------------------------------------------------------------------------------------
	lOCAL cQry	:=''
	Local aArea	:=GetArea()
	Local aArqs	:={}

	cQry+=" SELECT F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA, ACB_OBJETO "
	cQry+=" FROM "+RetSqlTab("SF1,ACB,AC9")
	cQry+=" WHERE "+RetSqlFil("SF1,ACB,AC9")
	cQry+=" AND "+RetSqlDel("SF1,ACB,AC9")
	cQry+=" AND F1_DUPL = '"+TRB->E2_NUM+"'"
	cQry+=" AND F1_PREFIXO = '"+TRB->E2_PREFIXO+"'"
	cQry+=" AND F1_FORNECE = '"+TRB->E2_FORNECE+"'"
	cQry+=" AND F1_LOJA = '"+TRB->E2_LOJA+"'"
	cQry+=" AND AC9_FILENT = F1_FILIAL "
	cQry+=" AND AC9_ENTIDA = 'SF1' "
	cQry+=" AND AC9_CODENT = F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA "
	cQry+=" AND ACB_CODOBJ = AC9_CODOBJ "
	cQry+=" AND ACB_FILIAL = AC9_FILIAL "

	cLog:=' TITULO: '+TRB->E2_NUM+chr(13)+chr(10)
	cLog+=cQry

	MEMOWRIT('\logs\anexos_'+alltrim(TRB->E2_NUM)+'.txt',cLog)

	TCQUERY cQry New Alias TRAB
	DbSelectArea("TRAB")

	While !eof()
		Aadd(aArqs,cPathBco+TRAB->ACB_OBJETO)
		u_fMyAlert('objeto:' +cPathBco+TRAB->ACB_OBJETO)
		dbskip()
	End

	dbclosearea()
	RestArea(aArea)

return aArqs


	/*
			ACB->ACB_FILIAL:=xFilial('ACB')
				ACB->ACB_CODOBJ:=GETSXENUM('ACB','ACB_CODOBJ')
				ACB->ACB_OBJETO:=cFilePDF
				ACB->ACB_DESCRI:='PDF da NFS-e lançada automaticamente em '+Dtoc(msdate())
				msunlock()
				confirmsx8()

				dbSelectArea('AC9')
				reclock('AC9',.t.)
				AC9->AC9_FILIAL:=xFilial('AC9')
				AC9->AC9_FILENT:=SM0->M0_CODFIL
				AC9->AC9_ENTIDA:='SF1'
				AC9->AC9_CODENT:=SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
				AC9->AC9_CODOBJ:=ACB->ACB_CODOBJ
				*/
