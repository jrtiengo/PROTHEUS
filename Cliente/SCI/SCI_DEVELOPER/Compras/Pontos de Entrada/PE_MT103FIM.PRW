#INCLUDE "protheus.ch"
#include "TOPCONN.CH" 

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | MT103fim | Autor: Paola |              | Data |07/05/2010  |||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | PE Este ponto de entrada pertence à rotina entrada de NFE  |||
||| 		  |	grava informacoes complementares digitados pelo usuario    |||
||| 		  |	na inclusao da NF de importacao.      					   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|  													       |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |											         		   |||
|||-----------+------------------------------------------------------------|||
|||  Uso      |                                                            |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador      | Data      | Motivo da Alteracao                     |||
|||-------------+--------+-------------------------------------------------|||
||| Samuel Schneider | 30/11/2018| Ajustes no envio do email               |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/

User Function MT103FIM() 

	Local 	aArea     := GetArea()
	Local 	aAreaSA2  := SA2->(GetArea())
	Local 	aAreaSE2  := SE2->(GetArea())
	Local 	aAreaSD1  := SD1->(GetArea())
	Local 	aAreaSF1  := SF1->(GetArea())
	
	If INCLUI .and. PARAMIXB[2] == 1     
		MsgRun("Permuta", "Processando Registro", {|| permuta()  } )				
		Return .T.
	EndIf
   
	RestArea(aAreaSA2)
	RestArea(aAreaSE2)
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return()
 

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    |  | Autor: 						    || Data |18/09/2018    |||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Função Pergunta se nota fiscal é realmente de permuta      |||
|||           | Para gerar atualização e envio de e-mail                   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|															   |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | 											 			   |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function Permuta()

	If SA2->A2_PERMUTA='1'
	
		nAviso := AVISO("Fornecedor Identificado com Permuta", "Esta Nota de Entrada, é de Permuta ?", { "SIM","NÃO"}, 2)
	
		If nAviso == 1

			Grava()
			GeraEmail()

		Endif
	
	EndIf

Return 

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | GeraEmail | Autor: Samuel Schneider || Data |18/09/2018    |||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Função gera consulta para envio de email     			   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|															   |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | 											 			   |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/

Static Function GeraEmail()

	Local cAliasTmp := GetNextAlias()
    Local cQuery    := ""  
    Local aItens    := {}
    Local cDoc      := SF1->F1_DOC
    Local cSerie    := SF1->F1_SERIE

    cQuery:=" SELECT SC7.C7_NUMSC,   "+CRLF
    cQuery+="        SC7.C7_NUM,     "+CRLF
    cQuery+="        SD1.D1_COD,     "+CRLF
    cQuery+="        SD1.D1_DOC,     "+CRLF
    cQuery+="        SD1.D1_SERIE ,  "+CRLF
    cQuery+="        SD1.D1_DTDIGIT, "+CRLF
    cQuery+="        SD1.D1_QUANT    "+CRLF
    cQuery+=" FROM "+RetSqlName("SD1")+" SD1 		  "+CRLF
    cQuery+=" INNER JOIN "+RetSqlName("SC7")+" SC7 ON "+CRLF
	cQuery+="       SC7.C7_FILIAL     = SD1.D1_FILIAL "+CRLF          
	cQuery+="       AND SC7.C7_ITEM   = SD1.D1_ITEMPC "+CRLF
	cQuery+="       AND SC7.C7_NUM    = SD1.D1_PEDIDO "+CRLF
	cQuery+="       AND SC7.D_E_L_E_T_ <> '*'         "+CRLF
	cQuery+=" WHERE 								  "+CRLF 
	cQuery+=" SD1.D1_FILIAL         ='"+ SF1->F1_FILIAL  +"' "+CRLF
	cQuery+=" AND SD1.D1_DOC        ='"+ SF1->F1_DOC     +"' "+CRLF
	cQuery+=" AND SD1.D1_SERIE      ='"+ SF1->F1_SERIE   +"' "+CRLF
	cQuery+=" AND SD1.D1_FORNECE    ='"+ SF1->F1_FORNECE +"' "+CRLF
	cQuery+=" AND SD1.D1_LOJA       ='"+ SF1->F1_LOJA    +"' "+CRLF
	cQuery+=" AND SD1.D_E_L_E_T_        <> '*'				     "+CRLF
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	
	While (cAliasTmp)->( !Eof() )

	aAdd(aItens,{(cAliasTmp)->C7_NUM,;
				(cAliasTmp)->D1_COD,;
				(cAliasTmp)->D1_DOC,;
				(cAliasTmp)->D1_SERIE,;
				(cAliasTmp)->D1_DTDIGIT,;
				(cAliasTmp)->D1_QUANT}) 			
					 
	(cAliasTmp)->(dbSkip())
			
	EndDo
					
	( cAliasTmp )->( dbCloseArea())
	
	If Len(aItens) > 0
		cEnvMail(cDoc,cSerie,aItens)
	EndIf
	

Return()

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | Grava | Autor: 				   	    || Data |18/09/2018    |||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Função atualiza tabela SE2 , campo E2_PORTADO com "PER"	   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|															   |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | 											 			   |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/

Static Function Grava()
    
	Local cQuery := ""
	Private cAliasTmp := GetNextAlias()
    
	cQuery := " SELECT COUNT(*) AS EXISTE,"
	cQuery += " R_E_C_N_O_ AS RECNO"
	cQuery += " FROM "+RetSQLName("SE2")
	cQuery += " WHERE E2_FILIAL  = '"+ xFilial("SE2")+"'"
	cQuery += "   AND E2_NUM     = '"+SF1->F1_DOC+"' "
	cQuery += "   AND E2_PREFIXO = '"+SF1->F1_SERIE+"'"
	cQuery += "   AND E2_TIPO    = '"+SF1->F1_ESPECIE+"'"
	cQuery += "   AND D_E_L_E_T_ <>'*'"
	cQuery += " GROUP BY R_E_C_N_O_"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )
					
	If ( cAliasTmp )->EXISTE > 0
	
		While ( cAliasTmp )->( !EOF() )
		
			dbSelectArea("SE2")
			SE2->( dbGoTo( ( cAliasTmp )->RECNO ) )
					
			RecLock("SE2",.F.)
				SE2->E2_BCOPAG:="PER"
			MsUnLock()
			
			( cAliasTmp )-> ( dbSkip() )
							
		EndDo

		MsgInfo("Dados gravados com sucesso!","Informação!")
					
	EndIf   
	   
	( cAliasTmp )->( dbCloseArea() ) 
	

Return ()

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | cEnvMail | Autor: 				   	|| Data |18/09/2018    |||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Monta corpo do email									   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|															   |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | 											 			   |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/

static function cEnvMail(cDoc,cSerie,aDados)

    Local cTo       := GetMv("ES_EMAILPE")
	Local cAccount  :=""
	Local cPassword :=""
	Local cFrom     :=""
	Local cMensagem :="" 
	Local a         := 0
	
	cMensagem := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
	cMensagem+= '<html> '
	cMensagem+= '<head> '
	cMensagem+= '<meta content="text/html; charset=utf-8" http-equiv="content-type"> '
	cMensagem+= '<title>Item Atendido pelo Documento '+cDoc+' Serie '+cSerie+'</title> '
	cMensagem+="<style>"
	cMensagem+="body {font-family: 'Calibri';"
	cMensagem+="    font-style: normal;"
	cMensagem+="    font-weight: 400;}"
	cMensagem+=""
	cMensagem+="table, td, th {"
	cMensagem+="    border: 1px solid #ddd;"
	cMensagem+="	text-align: center;"
	cMensagem+="}"
	cMensagem+=""
	cMensagem+="table {"
	cMensagem+="    border-collapse: collapse;"
	cMensagem+="    width: 100%;"
	cMensagem+="}"
	cMensagem+="th, td {"
	cMensagem+="    padding: 10px;"
	cMensagem+="    text-align: left;"
	cMensagem+="	border-bottom: 1px solid #ddd;"
	cMensagem+="}"
	cMensagem+="tr:nth-child(even) {background-color: #f2f2f2;}"
	cMensagem+="th {"
	cMensagem+="    background-color: #de1919;"
	cMensagem+="    color: white;"
	cMensagem+="}"
	cMensagem+="h2 {"
	cMensagem+="    display: block;"
	cMensagem+="    font-size: 1.2em;"
	cMensagem+="    margin-top: -1.17em;"
	cMensagem+="    margin-bottom: 1.83em;"
	cMensagem+="    margin-left: 0;"
	cMensagem+="    margin-right: 0;"
	cMensagem+="    font-weight: bold;"
	cMensagem+="}"
	cMensagem+="</style>"
	cMensagem+="</header>"
	cMensagem+="<body>"
	cMensagem+="<br>"
	cMensagem+="<h2>Prezado usuário(a), </h2>"
	cMensagem+="<br>"
	cMensagem+="<br>"
	cMensagem+="<h2>Sistema informa que foi lançada uma nota de Permuta,conforme dados abaixo:</h2>"
	cMensagem+="<table>"
	cMensagem+="<thead>"
	cMensagem+="<tr>"
	cMensagem+="	<th>Numero da Nota</th>"
	cMensagem+="	<th>Serie da Nota</th>"
	cMensagem+="	<th>Pedido de Compra</th>"
	cMensagem+="	<th>Produto</th>"
	cMensagem+="	<th>Quantidade</th>"
	cMensagem+="	<th>Data</th>"
	cMensagem+="</tr>" 
	cMensagem+="</thead>"
	cMensagem+="<tbody>"
	
	For a := 1 To Len(aDados)
	
		 cMensagem+="  <tr>"
	     cMensagem+=" <td>"+aDados[a,3]+"</td>"
		 cMensagem+=" <td>"+aDados[a,4]+"</td>"
         cMensagem+=" <td>"+aDados[a,1]+"</td>"
         cMensagem+=" <td>"+aDados[a,2]+"</td>"
         cMensagem+=" <td>"+Transform(aDados[a,6],PesqPict("SD1","D1_QUANT"))+"</td>"
         cMensagem+=" <td>"+DTOC(STOD(aDados[a,5]))+"</td>"
         cMensagem+="  </tr>" 
         
	Next a    
	
	cMensagem+="</tbody>"
	cMensagem+="</table>"
	cMensagem+="<br>"
	cMensagem+="<hr>"
	cMensagem+="<br>"
	cMensagem+="<p>E-mail gerado automaticamente pelo Protheus - Totvs</p>"
	cMensagem+= '<p>Processado em ' + DtoC( ddatabase ) + ' às ' + Time() + ' hs </p>'
	cMensagem+="</body>"
	cMensagem+="</html>"
	
	/*
		Envia email
		Funcao EnvMail, encontra-se no fonte SCIXFUN
	*/
	
	U_EnvMail(cAccount,cPassword,cFrom,cTo,"","Nota de Permuta",cMensagem,"")

Return

