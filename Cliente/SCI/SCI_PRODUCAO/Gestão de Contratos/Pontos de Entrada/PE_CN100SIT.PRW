#INCLUDE 'PROTHEUS.CH'

#DEFINE DEF_SCANC '01' //Cancelado
#DEFINE DEF_SELAB '02' //Em Elaboração
#DEFINE DEF_SEMIT '03' //Emitido
#DEFINE DEF_SAPRO '04' //Em Aprovação
#DEFINE DEF_SVIGE '05' //Vigente
#DEFINE DEF_SPARA '06' //Paralisado
#DEFINE DEF_SSPAR '07' //Sol Fina.
#DEFINE DEF_SFINA '08' //Finalizado
#DEFINE DEF_SREVS '09' //Revisão
#DEFINE DEF_SREVD '10'//Revisado

User Function CN100SIT()
Local cAno     := VAL(SubStr( DtoS(     YearSum( ddatabase , 1 )       ), 1, 4 ))//adicinando mais um exercicio para determinar longo
Local cAtu := PARAMIXB[1]
Local cDst := PARAMIXB[2]

// Situação atual do contrato.
//If cAtu == DEF_SELAB
//	msgAlert ('Situacao alterada de Em Elaboracao')
//EndIf
// Nova situação do contrato;
If cDst == DEF_SVIGE
	
	cQuery:=" UPDATE "+RETSQLNAME("SE2")+" "
	cQuery+=" SET E2_NATUREZ =ED_NATCPLP "      
	cQuery += " FROM "+RetSqlName('SE2')+" SE2 "
	cQuery += "  INNER JOIN "+RETSQLNAME("SED")+" SED ON ( SE2.E2_NATUREZ=SED.ED_CODIGO) "
	cQuery += "  WHERE E2_FILIAL = '"+xFilial("SE2")+"' "
	cQuery += "  AND SE2.E2_PREFIXO='CTR'
	cQuery += "  AND SED.D_E_L_E_T_<>'*' "
	cQuery += "  AND SE2.D_E_L_E_T_<>'*' "
	cQuery += "  AND SE2.E2_TIPO='PR' "      
	cQuery += "  AND YEAR(SE2.E2_VENCTO)>'"+ALLTRIM(str(cAno))+"' "
	cQuery += "  AND SED.ED_NATCLP  ='C' "
	cQuery += "  AND SE2.E2_MDCONTR = '"+CN9->CN9_NUMERO+"' "
	cQuery += "  AND SE2.E2_MDREVIS = '"+CN9->CN9_REVISA+"' "
		
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	

	
	
	
	
	
	// Atualizar tabelas para a customizacao direito de imagem (Curto e longo Prazo)
	
	
	
	// Passando planilhas do cronograma contabil para o longo prazo
	cQuery := " UPDATE "+RetSqlName('CNW')
	cQuery += " SET CNW_FGEXER='',"
	cQuery += " CNW_FGLPCP='L' "
	cQuery += " FROM "+RetSqlName('CNW')+" CNW "
	cQuery += "	WHERE CNW.CNW_FGLPCP ='' "
	cQuery += "   AND YEAR(CNW_DTPREV)>'"+ALLTRIM(str(cAno))+"' "
	cQuery += "	  AND CNW.CNW_FGEXER ='' "
	cQuery += "   AND CNW.CNW_CONTRA = '"+CN9->CN9_NUMERO+"' "
	cQuery += "   AND CNW.CNW_REVISA = '"+CN9->CN9_REVISA+"' "
	cQuery += "	  AND CNW.D_E_L_E_T_ <>'*' "
	
	MEMOWRIT('TMPCNWUPDLONGO.txt', cQuery)
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
	// Passando planilhas do cronograma contabil para o curto prazo
	cQuery := " UPDATE "+RetSqlName('CNW')
	cQuery += " SET CNW_FGEXER='',"
	cQuery += " CNW_FGLPCP='C' "
	cQuery += " FROM "+RetSqlName('CNW')+" CNW "
	cQuery += "	WHERE "
	cQuery += "   YEAR(CNW_DTPREV)<='"+ALLTRIM(str(cAno))+"' "
	cQuery += "	  AND CNW.CNW_FGEXER ='' "
	cQuery += "   AND CNW.CNW_CONTRA = '"+CN9->CN9_NUMERO+"' "
	cQuery += "   AND CNW.CNW_REVISA = '"+CN9->CN9_REVISA+"' "
	cQuery += "	  AND CNW.D_E_L_E_T_ <>'*' "
	
	MEMOWRIT('TMPCNWUPDCURTO.txt', cQuery)
	
	nRet:=TcSqlExec(cQuery)
	If nRet<>0
		Alert(TCSQLERROR())
	Endif
	
EndIf

Return
