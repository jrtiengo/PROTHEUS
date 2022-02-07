#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

* EXSCTB04 - Relatório Margem de contrbiuição 

user function exsctb04()

	Private oReport
	PRIVATE ctitulo 		:= "Relatório de Margem de Contribuição "     
	Private cPerg	  		:= PADR("EXSCTB04", 10, " ")  //PADR("EXSCTB04", LEN(SX1->X1_GRUPO), " ")
	Private oped, odata        
	Private _nivel, _nome, _valor, _perc 
	ReportDef()
	oReport:PrintDialog()
Return    

Static Function ReportDef()
	oReport := TReport():New("EXSCTB04",	ctitulo,	cPerg, ;
			{|oReport| ReportPrint()},;
			"Este programa irá emitir o relatorio de Margem de Contribuição",,)
	oReport:setlandscape()    //SetLandscape() //setportrait
	oReport:SetTotalInLine(.F.)
    	
	oPed := TRSection():New(oreport, cTitulo,,,/*Campos do SX3*/,/*Campos do SIX*/,'')
	oPed:SetTotalInLine(.F.)
	      
	TRCell():New(oPed, "CC"	,				     ,	"",								,100,	/*lPixel*/,	{||})


	odata := TRSection():New(oreport, cTitulo,,,/*Campos do SX3*/,/*Campos do SIX*/,'')
	odata:SetTotalInLine(.F.)
	TRCell():New(odata, "ESPACOS"	,			     ,	"",										,	70,	/*lPixel*/,	{|| space(50)})
	TRCell():New(odata, "NOME"	,			     ,	"",											,	30,	/*lPixel*/,	{|| _nome})
	TRCell():New(odata, "VALOR",			     ,	"",	"@E 999,999,999.99"			     		,	12,	/*lPixel*/,	{|| _valor})
	TRCell():New(odata, "PERC",				     ,	""	,"@E 999.99" 							,	6,	/*lPixel*/,	{|| _perc})
		
	_validPerg()
	Pergunte(oReport:uParam,.F.)
Return()

Static Function ReportPrint()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis   										     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	beginsql alias "qzt"
		SELECT COUNT(*) NUMERO 
		FROM %table:SZT% SZT
		WHERE ZT_FILIAL = %xfilial:SZT% 
		AND SZT.%notdel% 
		AND ZT_DATAINI = %exp:dtos(mv_par01)% AND ZT_DATAFIM = %exp:dtos(mv_par02)%
	endsql 
	if  qzt->NUMERO == 0
		qzt->(dbclosearea()) 
		Alert ('Margem Nao calculada para o periodo !!!')
		return 
	else
		qzt->(dbclosearea())
	endif 
	
	oreport:ctitle := 'Margem de Contribuicao'
	oReport:SetTitle(oReport:Title() )

	oped:SetHeadersection()
	_ccini:= ''
	if  cempant == '01'
		_ccini := 'A0102'
	elseif cempant == '02' 
		_ccini := 'A0103'
	else
		_ccini := 'A0105' 
	endif
	aResult := TCSPEXEC("EXS0001", cempant,__cuserid,'EXSCTB04',cfilant,_ccini,'0')
	IF empty(aResult)
	   MsgInfo('Erro na execução da Stored Procedure EXS0001: '+ cempant + ' ' +;
	   __cuserid + ' EXSCTB04 ' +  TcSqlError())
		return()
	Endif

	_cquery := "SELECT * " 
	_cquery += "FROM CCTEMP"+cempant+__cuserid+"EXSCTB04 "
	_cquery += "ORDER BY CODIGO " 
	
	TCQuery _cquery alias qcc new 

	oReport:SetMeter(qcc->(RecCount()))		// Total de elementos da regua
	
	oped:init()
	odata:init()		                   
	While !oReport:Cancel() .And. !(qcc->(Eof()))
		
		beginsql alias "qzt"
			SELECT * 
			FROM %table:SZT% SZT, %table:SZR% SZR 
			WHERE ZT_FILIAL = %xfilial:SZT% 
			AND ZR_FILIAL = %xfilial:SZR% 
			AND SZT.%notdel%
			AND SZR.%notdel%
			AND ZT_CC = %exp:qcc->CODIGO%
			AND ZT_TIPO = ZR_CODIGO 
			AND ZT_DATAINI = %exp:dtos(mv_par01)%
			AND ZT_DATAFIM = %exp:dtos(mv_par02)%
			ORDER BY ZT_TIPO  
		endsql 
		_rl := 0 
		_MC := 0
		_limprl := .t.
		_rb := 0
		
		if !qzt->(eof())
			ctt->(dbsetorder(1)) 
			ctt->(dbseek(Xfilial("CTT")+qcc->CODIGO))
			_nivel := (qcc->nivel*3)
			_desc := padl(alltrim(ctt->ctt_custo),_nivel+len(alltrim(ctt->ctt_custo)),'.')+' '+alltrim(ctt->ctt_desc01) 
			oped:CELL('CC'):setvalue(_desc)
			oped:printline()
		endif	
	
	   
		while !qzt->(eof())
			if  qzt->ZT_TIPO == '1'
				_rl += qzt->ZT_VALOR
				_mc += qzt->ZT_VALOR
				_rb := qzt->ZT_VALOR   
			elseif qzt->ZT_TIPO == '2' 
				_rl -= qzt->ZT_VALOR 
				_mc -= qzt->ZT_VALOR 
			else
				_mc -= qzt->ZT_VALOR 
			endif 
			_nome := qzt->ZR_DESC
			_valor:= qzt->ZT_VALOR
			_perc := round(_valor/_rb*100,2) 
			odata:printline() 
			if  qzt->ZT_TIPO = '2' .and. _limprl
				_limprl := .F. 
				if  _rl > 0 
					_nome := "RECEITA LIQUIDA"
					_valor:= _rl
					_perc := round(_rl/_rb*100,2)
					odata:printline()
				endif 
			endif  
			qzt->(dbskip())
		enddo
		qzt->(dbclosearea())
		if  _rl > 0  
			_nome := "MARGEM DE CONTRIBUICAO"
			_valor:= _mc
			_perc := round(_mc/_rb*100,2)
			odata:printline()
		endif 
		qcc->(dbskip())
		oReport:IncMeter() 
		oreport:skipline()
	enddo 	
	oped:finish()         
	odata:finish()  
	qcc->(dbCloseArea())   
Return

Static Function _ValidPerg()
Local _aArea  := GetArea()
Local _aRegs  := {}
Local _aHelps := {}
Local _i      := 0
Local _j      := 0

_aRegs = {}
//             GRUPO  ORDEM PERGUNT                       PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID           VAR01       DEF01         DEFSPA1 DEFENG1 CNT01 VAR02 DEF02        DEFSPA2 DEFENG2 CNT02 VAR03 DEF03    DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3     GRPSXG
AADD (_aRegs, {cPerg, "01", "Data de            ?", "",    "",    "mv_ch1", "D", 08, 0,  0,     "G", "",             "mv_par01", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})
AADD (_aRegs, {cPerg, "02", "Data ate           ?", "",    "",    "mv_ch2", "D", 08, 0,  0,     "G", "",             "mv_par02", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})
//AADD (_aRegs, {cPerg, "03", "Local Arquivo      ?", "",    "",    "mv_ch3", "C", 99, 0,  0,     "G", "",             "mv_par03", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
//AADD (_aHelps, {"01", {"Informe a data inicial a ser consi-", "derado no filtro.                       ", "                                        "}})
//AADD (_aHelps, {"02", {"Informe a data final   a ser consi-", "derado no filtro.                       ", "                                        "}})
//AADD (_aHelps, {"03", {"Informe o caminho do local onde o ar-", "quivo será salvo.                       ", "                                        "}})

/*
DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
	If ! DbSeek (cPerg + _aRegs [_i, 2])
		RecLock("SX1", .T.)
	Else          
		RecLock("SX1", .F.)
	Endif
	For _j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs [_i, _j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (cPerg, .T.)
Do While !Eof() .And. x1_grupo == cPerg
	If Ascan(_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		Reclock("SX1", .F.)
		Dbdelete()
		Msunlock()
	Endif
	Dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len(_aHelps)
	PutSX1Help ("P." + alltrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next
*/

Restarea(_aArea)

Return()


