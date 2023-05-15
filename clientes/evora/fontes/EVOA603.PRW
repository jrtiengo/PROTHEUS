#include "Totvs.ch"
#Include "XmlXFun.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA603   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | workflow de envio de titulos para o financeiro                            |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via job                                                         |
+-----------+---------------------------------------------------------------------------+*/
User Function EVOA603(aemp)
	Local cMensagem :=""
	Local cTo		:="" 
	//Local cAccount	:=""
	//Local cPassword	:=""
	//Local cFrom		:=""
    Local cQuery    :=""
    Local cTitulo   :=""
    Local nSldTot   :=0
	Local cLibPag	:= !getmv('MV_CTLIPAG')

	If Select("SX2") <= 0
        RPCClearEnv()
        RPCSetEnv(aEmp[1],aEmp[2],"","","","")
	End

	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN 
	end


    cTo		:=getmv('ES_WF603TO') //'manoel.mariante@gmail.com;manoel.mariante@motasa.com.br'
    nDiaSem :=VAL(GETMV('ES_WF603DS'))
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

	dVctoAte	:=dDataBase+7
	While DOW(dVctoAte) <> nDiaSem-1
		dVctoAte++
	End

	dDataPgto	:=dDataBase+1
	While DOW(dDataPgto) <> nDiaSem
		dDataPgto++
	End

	cTitulo :='Titulos Com Vencimento até '+dtoc(dVctoAte)+' com previsão de pagamento '+cDesDia+' dia '+dtoc(dDataPgto)

    cQuery+=" SELECT E2_DATALIB,E2_DATACAN,E2_DATASUS, E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_VENCREA,E2_EMISSAO,E2_VALOR,E2_SALDO,E2_USUALIB,E2_DATALIB, E2_MOTBLQ , E2_STATLIB"
    cQuery+=" FROM "+RETSQLNAME("SE2")+" SE2"
    cQuery+=" WHERE "
	cQuery+=" E2_VENCREA>='"+dtos(dDataBase-180)+"'"
	cQuery+=" AND E2_VENCREA<='"+dtos(dVctoAte)+"'"
    cQuery+=" AND E2_SALDO<>0 "
    cQuery+=" AND D_E_L_E_T_=''"
	cQuery+=" ORDER BY "+SUPERGETMV("ES_603ORD",.F.,"E2_EMISSAO")

	MEMOWRIT('\logs\evoa603.SQL', cQuery)

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRB", .t., .t.)

	dbSelectArea('TRB')
	DBGOTOP()

	cMensagem := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
	cMensagem += '<html> '
	cMensagem += '<head> '
	cMensagem += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"> '
	cMensagem += '  <title> '+cTitulo+'</title> '
    cMensagem += '<style type="text/css">'
    cMensagem += 't   { font-size: 14px ; font-weight: bold; color:WHITE;background-color:GREEN ; font-family: Calibri,Helvetica, Geneva, Arial,SunSans-Regular, sans-serif }'
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
    cMensagem += '<tit>'+cTitulo+' </tit>'
	cMensagem += '<hr>'
    cMensagem += '<tit> Empresa:'+SM0->M0_CODIGO+'-'+SM0->M0_NOME+'</tit>'
	cMensagem += '<hr>'
	cMensagem += '<TABLE BORDER=1 BORDERCOLOR=BLUE >'
	cMensagem += '<tr>'
    cMensagem += '<th WIDTH=300 BGCOLOR=GREEN><t>Documento</t></th>'
	cMensagem += '<th WIDTH=400 BGCOLOR=GREEN><t>Fornecedor</t></th>'
    cMensagem += '<th WIDTH=100 BGCOLOR=GREEN><t>Vencimento</t></th>'
    cMensagem += '<th WIDTH=150 BGCOLOR=GREEN><t>Valor</t></th>'
    cMensagem += '<th WIDTH=100 BGCOLOR=GREEN><t>Autorizador</t></th>'
    cMensagem += '<th WIDTH=100 BGCOLOR=GREEN><t>Liberado</t></th>'
    cMensagem += '<th WIDTH=200 BGCOLOR=GREEN><t>Motivo (se "N")</t></th>'
    cMensagem += '<th WIDTH=400 BGCOLOR=GREEN><t>Obs Gestor</t></th>'
    
	cMensagem += '</tr>'                             	
	cMensagem += '<tr>'
	cMensagem += '</tr>'                          	

	While !eof()
		if cLibPag //!getmv('MV_CTLIPAG') - Solutio Tiengo - 13/04/2023
            cSitLib:='Liberado'
		else
                   
            cSitLib:='Pendente'

			IF !Empty(TRB->E2_DATALIB)
                cSitLib:='Liberado'
			End
			IF !Empty(TRB->E2_DATASUS)
                cSitLib:='Suspenso'
			End
			IF !Empty(TRB->E2_DATACAN)
                cSitLib:='Cancelado'
			End
		end
		cObsGest:=''
	    dbSelectArea('SZ1')
		dbSetOrder(1)
		If dbSeek(xFilial("SZ1")+TRB->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA))
            cObsGest:=SZ1->Z1_OBS
        end

		cMensagem += '<tr>'
		cMensagem += '<td><c>'+TRB->(E2_PREFIXO+'-'+E2_NUM+'/'+E2_PARCELA+' '+E2_TIPO)+'</c></td>'
        cMensagem += '<td><c>'+TRB->E2_NOMFOR+'</c></td>'
        cMensagem += '<td ALIGN=MIDDLE><c>'+dtoc(stod(TRB->E2_VENCREA))+'</c></td>'
        cMensagem += '<td ALIGN=MIDDLE><c>'+TRANSFORM(TRB->E2_SALDO,"@E 9999,999,999.99")+'</c></td>'
        cMensagem += '<td ALIGN=MIDDLE><c>'+TRB->E2_USUALIB+'</c></td>'
        cMensagem += '<td ALIGN=MIDDLE><c>'+cSitLib+'</c></td>'
        cMensagem += '<td><c>'+TRB->E2_MOTBLQ+'</c></td>'
        cMensagem += '<td><c>'+cObsGest+'</c></td>'
        cMensagem += '</tr>'
        nSldTot+=TRB->E2_SALDO
		
		dbSelectArea('TRB')
        dbskip()
		
	End

		cMensagem += '<tr>'
		cMensagem += '<td BGCOLOR=GREEN><t>TOTAIS</t></td>'
        cMensagem += '<td BGCOLOR=GREEN><t> </t></td>'
        cMensagem += '<td BGCOLOR=GREEN ALIGN=MIDDLE><t>  </t></td>'
        cMensagem += '<td BGCOLOR=GREEN ALIGN=MIDDLE><t>'+TRANSFORM(nSldTot,"@E 9999,999,999.99")+'</t></td>'
        cMensagem += '<td BGCOLOR=GREEN ALIGN=MIDDLE><t>   </t></td>'
        cMensagem += '<td BGCOLOR=GREEN ALIGN=MIDDLE><t>    </t></td>'
        cMensagem += '<td BGCOLOR=GREEN><t>    </t></td>'
        cMensagem += '</tr>'

	cMensagem += '</table> '
	cMensagem += '<br> '
	cMensagem += '<hr>'
	cMensagem += 'E-mail gerado automaticamente pelo Protheus em '+dtoc(msdate())+' as '+left(time(),5)
	cMensagem += '<br> '

	MEMOWRIT('\logs\evoa603.HTM', cMensagem)
	                                               
	//IF u_SendMail(cAccount,cPassword,cFrom,cTo,"",cTitulo,cMensagem,"")
	IF lOk:=U_EnvMail(cTo, '', cTitulo, cMensagem, {})
		u_fMyAlert("E-mail enviado para "+cTo)
	End
	dbSelectArea('TRB')
	DBCLOSEAREA(  )

Return


