#Include 'Protheus.ch'
#include "topconn.ch"
#include "rwmake.ch"


User Function exsctb03()
Local cCadastro  := "Calcula Valores Margem Contribuicao"
Local aSays      := {}
Local aButtons   := {}
Local nOpca      := 0
Local lPerg      := .T.

AADD(aSays," ")
AADD(aSays,"  Este programa tem como objetivo calcular os valores da margem de contribuicao ")

cPerg   := Padr("EXSCTB03",10) //Padr("EXSCTB03",Len(SX1->X1_GRUPO))
_ValidPerg()          // Cria/Atualiza as perguntas e o help dos parametros
pergunte(cPerg,.F.)   

AADD(aButtons, { 1,.T.,{|| nOpca := If((lPerg), 1, 2 ), If( nOpca == 1, FechaBatch(), Nil ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T.) }} )

FormBatch( cCadastro, aSays, aButtons )
	
If nOpca == 1
   Processa({|| calcula() },"Calculando Margem... " )
endif
Return

static function calcula()
	if  ! cempant $ '01/02/04'
		Alert ('Margem de contribuicao prevista para as empresas 01, 02 e 04 !!!')
		return
	endif
	
	tcsqlexec("DELETE FROM SZT" + alltrim(cempant) + "0 WHERE ZT_DATAINI = '" +dtos(mv_par01)+ "' AND ZT_DATAFIM = '"+dtos(mv_par02)+"'")
	beginsql alias "qctt"
		SELECT * 
		FROM %table:CTT% CTT
		WHERE CTT_FILIAL = %xfilial:CTT% 
		AND CTT.%notdel%
		AND CTT_CLASSE ='2'
		AND CTT_BLOQ <> '1'
	endsql 
	procregua(qctt->(reccount()))
	while !qctt->(eof())
		//exit
		incproc("Carregando CC Analiticos")
		beginsql alias "qszs"
			SELECT * 
			FROM %table:SZS% SZS
			WHERE ZS_FILIAL = %xfilial:SZS% 
			AND SZS.%notdel%
		endsql
		while !qszs->(eof())
			_nvalor:= CTSMMOV(dtoc(mv_par01),dtoc(mv_par02),01,1,3,qszs->zs_ctaini,qszs->zs_ctafim,qctt->ctt_custo,qctt->ctt_custo,,,,)
			//_nvalor:= CTSMMOV('01/02/2016','01/02/2016',01,1,3,"3121103007","3121103007","A0102020101010101","A0102020101010101",,,,)
			if _nvalor <> 0 
				szt->(dbsetorder(1))
				if  szt->(dbseek(Xfilial("SZT")+DTOS(mv_par01)+dtos(mv_par02)+qszs->zs_codigo+qctt->ctt_custo))
					reclock("SZT",.F.)
					if left(qszs->zs_ctaini,1) == '1' 
					   szt->zt_valor+=(_nvalor)
					else
					   szt->zt_valor+=(_nvalor*-1)
					endif 
				else
					reclock("SZT",.T.) 
					szt->zt_filial := xfilial("SZT") 
					szt->zt_dataini := mv_par01
					szt->zt_datafim := mv_par02
					szt->zt_cc := qctt->ctt_custo
					szt->zt_tipo := qszs->zs_codigo
					if left(qszs->zs_ctaini,1) == '1' 
					   szt->zt_valor := (_nvalor)
					else
					   szt->zt_valor := (_nvalor*-1)
					endif 
				endif
				szt->(msunlock())
			endif
			qszs->(dbskip())
		enddo
		qszs->(dbclosearea())	
		qctt->(dbskip())
	enddo  
	qctt->(dbclosearea())
	beginsql alias "qrec"
		SELECT AA1_CC, SUM(ABC.ABC_VALOR/TOTOS.ABC_VALOR*PEDIDO.C6_VALOR) VALOR 
		FROM AA1010 AA1, ABC010 ABC,
			 (SELECT LEFT(C6_NUMOS,6) C6_NUMOS, SUM(C6_VALOR) C6_VALOR
			  FROM SC6010 SC6
			  WHERE C6_FILIAL = %xfilial:SC6%
			  AND SC6.%notdel%
			  AND C6_NUMOS <> ' '
			  AND C6_ENTREG BETWEEN %exp:dtos(mv_par01)% AND %exp:dtos(mv_par02)%
			  GROUP BY LEFT(C6_NUMOS,6)) AS PEDIDO, 
			 (SELECT LEFT(ABC_NUMOS,6) ABC_NUMOS, SUM(ABC_VALOR) ABC_VALOR
			  FROM ABC010 ABC
			  WHERE ABC_FILIAL = %xfilial:ABC%
			  AND ABC.%notdel%
			  GROUP BY LEFT(ABC_NUMOS,6)) AS TOTOS
		WHERE AA1_FILIAL = %xfilial:AA1%
		AND AA1.%notdel%
		AND ABC.ABC_FILIAL = %xfilial:ABC%
		AND ABC.%notdel%
		AND AA1.AA1_CODTEC = ABC.ABC_CODTEC
		AND LEFT(ABC.ABC_NUMOS,6) = TOTOS.ABC_NUMOS
		AND TOTOS.ABC_NUMOS = PEDIDO.C6_NUMOS  
		GROUP BY AA1_CC
	endsql
	while  ! qrec->(eof())
		incproc("Carregando Receitas")
		reclock("SZT",.T.) 
		szt->zt_filial := xfilial("SZT") 
		szt->zt_dataini := mv_par01
		szt->zt_datafim := mv_par02
		szt->zt_cc := qrec->aa1_cc
		szt->zt_tipo := '1'
		szt->zt_valor := qrec->valor
		szt->(msunlock())
		// deducao da receita
		beginsql alias "qded"
			SELECT * 
			FROM %table:SZU% SZU
			WHERE ZU_FILIAL = %xfilial:SZU% 
			AND SZU.%notdel%
			AND ZU_CC = %exp:qrec->aa1_cc%
			AND ZU_DATA = (SELECT MAX(ZU_DATA) 
						   FROM %table:SZU% SZU
						   WHERE ZU_FILIAL = %xfilial:SZU% 
						   AND SZU.%notdel%
						   AND ZU_CC = %exp:qrec->aa1_cc%) 
		endsql 
		if !qded->(eof())
			reclock("SZT",.T.) 
			szt->zt_filial := xfilial("SZT") 
			szt->zt_dataini := mv_par01
			szt->zt_datafim := mv_par02
			szt->zt_cc := qrec->aa1_cc
			szt->zt_tipo := '2'
			szt->zt_valor := round(qrec->valor * qded->zu_perc /100,2)
			szt->(msunlock())
		endif
		qded->(dbclosearea())
		qrec->(dbskip())
	enddo 
	qrec->(dbclosearea())
	
	_ccini:= ''
	if  cempant == '01'
		_ccini := 'A0102'
	elseif cempant == '02' 
		_ccini := 'A0103'
	else
		_ccini := 'A0105' 
	endif
	
	aResult := TCSPEXEC("EXS0001", cempant,__cuserid,'EXSCTB03',cfilant,_ccini,'0')
	IF empty(aResult)
	   MsgInfo('Erro na execução da Stored Procedure EXS0001: '+ cempant + ' ' +;
	   __cuserid + ' EXSCTB03 ' +  TcSqlError())
		return()
	Endif
	_cquery:= "SELECT ISNULL(MAX(NIVEL),0) NIVEL "   
    _cquery+= "FROM CCTEMP"+cempant+__cuserid+'EXSCTB03'
    TCQUERY _cquery alias qcc NEW

	_nnivel := qcc->NIVEL  
	//alert (_nnivel) 
	qcc->(dbclosearea())	

	if  _nnivel > 0 
		for i:=_nnivel to 1 step -1
			//alert (i) 
			_cquery := "SELECT PAI, ZT_TIPO, SUM(ZT_VALOR) VALOR " 
			_cquery += "FROM " + retsqlname("SZT") + " SZT, CCTEMP"+cempant+__cuserid+"EXSCTB03 "
			_cquery += "WHERE " + retsqlcond("SZT") + " " 
			_cquery += "AND NIVEL = '" + alltrim(str(i))+ "' "   
			_cquery += "AND CODIGO = ZT_CC " 
			_cquery += "AND ZT_DATAINI = '" + dtos(mv_par01) + "' " 
			_cquery += "AND ZT_DATAFIM = '" + dtos(mv_par02) + "' "  
			_cquery += "GROUP BY PAI, ZT_TIPO " 
			//memowrite("c:\temp\sql.sql",_cquery)
			//alert ('query')
			TCQUERY _cquery alias qcc NEW
			while !qcc->(eof())
				incproc("Carregando Arvore")
				reclock("SZT",.T.) 
				szt->zt_filial := xfilial("SZT") 
				szt->zt_dataini := mv_par01
				szt->zt_datafim := mv_par02
				szt->zt_cc := qcc->PAI
				szt->zt_tipo := qcc->ZT_TIPO
				szt->zt_valor := qcc->valor
				szt->(msunlock())
				qcc->(dbskip())
				//alert ('szt')
			enddo
			qcc->(dbclosearea())
		next
	endif   
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
Return

	
	