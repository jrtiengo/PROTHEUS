#include "protheus.ch"
#include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB103TEC ³ Autor ³ Felipe S. Raota             ³ Data ³ 21/09/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Integração Sirtec x FullSoft, importação Ordens de Serviço.       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB901TEC()

	Local cQuery  := ""
	Local lCont   := .T.
	Local cOrdens := ""
	Local _x := 0
	
	Private _nLPos := 0
	Private _cCodSup := ''
	Private _aItemAlt := {}

	Private aAux

	SZ0->(DbsetOrder(2))
	If SZ0->(DbSeek(xFilial("SZ0")+__cUserId)) .and. SZ0->Z0_MSBLQL <> '1'
		_cCodSup := SZ0->Z0_CODIGO
	Else
		MsgInfo("Rotina pode ser executada somente por usuários supervisores ativos.")
		Return
	Endif

	aAux := MarkCod(.F.)

	While .T.
		If xType("aAux") == "A" //If Type("aAux") == "A"
			EXIT
		Else
			aAux := MarkCod(.T.)
		Endif
	Enddo

	If len(aAux) == 0
	Return
	Endif

	For _x:=1 to len(aAux)
		cOrdens += aAux[_x]+"/"
	Next

	cOrdens := FormatIn(cOrdens,"/")

	cQuery := " SELECT OrdemServicoSync AS OrdemSync, Numero, Apr_numero, Endereco, CodCidadeSync, EquipamentoRef, Alimentador,
	cQuery += "        CodSituacaoOSSync, CodClienteSync, KmInicio, KMFim, CodUsuarioSync, CodVistoriadorSync, CodEquipeSync, Obs,
	cQuery += "        ObsCheklist, CodTipoOSSync, OrdemServicoProtheus as OrdemProth, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrChegada, 112) as DtChegada, CONVERT(VarChar(19), DtHrChegada, 108) as HrChegada, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrSaida, 112) as DtSaida, CONVERT(VarChar(19), DtHrSaida, 108) as HrSaida, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrInicioPonto, 112) as DtInicioPonto, CONVERT(VarChar(19), DtHrInicioPonto, 108) as HrInicioPonto, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrTerminaPonto, 112) as DtTerminaPonto, CONVERT(VarChar(19), DtHrTerminaPonto, 108) as HrTerminaPonto, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrInicioServ, 112) as DtInicioServico, CONVERT(VarChar(19), DtHrInicioServ, 108) as HrInicioServico, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrTerminoServ, 112) as DtTerminoServico, CONVERT(VarChar(19), DtHrTerminoServ, 108) as HrTerminoServico, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrSaidaBase, 112) as DtSaidaBase, CONVERT(VarChar(19), DtHrSaidaBase, 108) as HrSaidaBase, "
	cQuery += "  	    CONVERT(VarChar(10), DtHrChegadaBase, 112) as DtChegadaBase, CONVERT(VarChar(19), DtHrChegadaBase, 108) as HrChegadaBase, "
	cQuery += "			CodSupervisorSync as CodSup"
	cQuery += " FROM FULL_ORDEM "
	cQuery += " WHERE Importado = 0 AND OrdemServicoSync IN " + cOrdens
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'" 

	cQuery += " ORDER BY OrdemServicoSync "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "TRB")

	TCSetField ("TRB", "DtChegada", "D")
	TCSetField ("TRB", "DtSaida", "D")
	TCSetField ("TRB", "DtInicioPonto", "D")
	TCSetField ("TRB", "DtTerminaPonto", "D")
	TCSetField ("TRB", "DtVistoria", "D")
	TCSetField ("TRB", "DtRealida", "D")
	TCSetField ("TRB", "DtInicioServico", "D")
	TCSetField ("TRB", "DtTerminoServico", "D")
	TCSetField ("TRB", "DtSaidaBase", "D")
	TCSetField ("TRB", "DtChegadaBase", "D")

	dbSelectArea("ZZI")
	ZZI->(dbSetOrder(1))

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))

	dbSelectArea("Z10")

	Z10->(dbSetOrder(2))

	dbSelectArea("DA0")
	DA0->(dbSetOrder(1))

	dbSelectArea("DA1")
	DA1->(dbSetOrder(1))

	dbSelectArea("AAG")
	AAG->(dbSetOrder(2))

	dbSelectArea("ABC")
	ABC->(dbSetOrder(2))

	While TRB->(!EoF())
	
		BEGIN TRANSACTION
	
			If !ZZI->(MsSeek( xFilial("ZZI") + TRB->CodSituacaoOSSync ))
				Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Situação da OS não encontrada!")
				DisarmTransaction()
				lCont := .F.
			Endif
	
			If lCont
		
				Do Case
				Case ZZI->ZZI_TIPO == "1"
					lCont := _geraOrcam()
				Case ZZI->ZZI_TIPO == "2"
					lCont := _geraOS()
				OtherWise
					Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Tipo de situação inválida!")
					lCont := .F.
				EndCase
		
			Endif
	
			If lCont
				cQuery := " UPDATE FULL_ORDEM SET Importado = 1 "
				cQuery += " WHERE OrdemServicoSync = " + cValtoChar(TRB->OrdemSync)
				cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"
	
				TcSqlExec(cQuery)
	
				cQuery := " UPDATE FULL_ORDEMFOTO SET Importado = 1 "
				cQuery += " WHERE CodOrdemServicoSync = " + cValtoChar(TRB->OrdemSync)
				cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"
	
				TcSqlExec(cQuery)
			Endif
	
		END TRANSACTION
	
		TRB->(dbSkip())
	Enddo

	TRB->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _geraOrcam ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera Orçamento vinda da Integração.                               ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103TEC                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _geraOrcam(xOsProth)

	Local aCab   := {}
	Local aItem  := {}
	Local aItens := {}
	Local aDetalhe := {}
	Local aDetalhes := {}

	Local cCli  := ""
	Local cLoja := ""

	Local lVist := .T.
	Local lRet  := .T.

	Local cSeq	:= ""
	Local cCidade := ""

	Local cOsProth	:= IIF (xOsProth == nil,TRB->OrdemProth,xOsProth)
	Local lEfetOrc	:= .F.		// Define se Efetiva o Orçamento(Vistoria) na sua inclusão
	
	Local cGrPPR := ""
	
	Private lMsHelpAuto 	  := .F.
	Private lMsErroAuto 	  := .F.

/*
* Verifica se é vistoria ou apontamento
* Se QtdRealizada estiver preenchido, é apontamento, senão se QtdVistoriada preenchido, é vistoria
*/

	cQuery := " SELECT AB9.AB9_CODTEC, MAX(AB9.AB9_SEQ) as AB9_SEQ "
	cQuery += " FROM " + RetSqlName("AB9") + " AB9 "
	cQuery += " WHERE AB9.AB9_NUMOS = '"+Alltrim(cOsProth) +"01' "
	cQuery += "   AND AB9.AB9_CODTEC = '"+Alltrim(TRB->CodEquipeSync)+"' "
	cQuery += "   AND " + RetSqlCond("AB9")
	cQuery += " GROUP BY AB9.AB9_CODTEC "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "SEQ")

	cSeq := Soma1(SEQ->AB9_SEQ)

	SEQ->(DbCloseArea())

	cQuery := " SELECT * "
	cQuery += " FROM FULL_ORDEMITEM "
	cQuery += " WHERE OrdemServicoSync = "+Alltrim(Str(TRB->OrdemSync))+" "
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "ITEM")

	If ITEM->(!EoF())
	
		While !ITEM->(EoF())
		
			aItens := {}
		
			cCli   := ""
			cLoja  := ""
			lVist  := .T.
			lRet   := .T.
		
			If ITEM->QtdRealizada > 0
				lVist := .F.
			Else
				If ITEM->QtdVistoriada > 0
					lVist := .T.
				Else
					Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Quantidade do item inválida!")
					lRet := .F.
					EXIT
				Endif
			Endif
		
			ITEM->(dbSkip())
		Enddo

	Else
	// Tratamento para apontamento só de horários.
		lVist := .F.
	Endif

	If lRet
	
		cCli  := Left(TRB->CodClienteSync,6)
		cLoja := Right(TRB->CodClienteSync,2)
	
		If SA1->(MsSeek( xFilial("SA1") + cCli + cLoja ))
			If Empty(SA1->A1_COND)
				Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Condição de pagamento inválida!")
				lRet := .F.
			Endif
		Else
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Cliente não encontrado!")
			lRet := .F.
		Endif
	
		If !Z10->(MsSeek( xFilial("Z10") + TRB->CodTipoOSSync ))
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + "Tipo de OS não encontrada!")
			lRet := .F.
		Endif
	
		_cOcorr  := ""
		_cPriori := ""
	
		AAG->(dbSetOrder(2))
	
		If AAG->(MsSeek( xFilial("AAG") + TRB->CodTipoOSSync ))
			_cOcorr  := AAG->AAG_CODPRB
			_cPriori := AAG->AAG_PRIORI
		Else
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Ocorrência não encontrada!")
			lRet := .F.
		Endif
	
		AAG->(dbSetOrder(1))
	Endif

	If lRet
	
	// Primeiro filtrar ZZL, tudo que tem para o tipo de OS
	// Depois com essas tabelas, ir na ZZJ e verificar qual tabela está alocada para o cliente.
	
		cQuery := " SELECT TOP 1 ZZJ.ZZJ_TABELA, DA0.DA0_YVUSS "
		cQuery += " FROM "+RetSqlName("ZZL")+" ZZL INNER JOIN "+RetSqlName("ZZJ")+" ZZJ ON ZZL.ZZL_TABELA = ZZJ.ZZJ_TABELA "
		cQuery += " 										 INNER JOIN "+RetSqlName("DA0")+" DA0 ON ZZL.ZZL_TABELA = DA0.DA0_CODTAB "
		cQuery += " WHERE ZZL_TIPOOS LIKE '"+Alltrim(TRB->CodTipoOSSync)+"' "
		cQuery += "   AND ZZJ.ZZJ_CLIENT = '"+cCli+"' "
		cQuery += "   AND ZZJ.ZZJ_LOJA = '"+cLoja+"' "
		cQuery += "   AND " + RetSqlCond("ZZL")
		cQuery += "   AND " + RetSqlCond("ZZJ")
	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "TAB")
	
		If TAB->(!EoF())
			_cTab := TAB->ZZJ_TABELA
			_nUssPre := TAB->DA0_YVUSS
		Else
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Vinculo com Tabela de Preço inválida!")
			lRet := .F.
		Endif
	
		TAB->(dbCloseArea())
	Endif

	If lRet
		dbSelectArea("CC2")
		CC2->(dbSetOrder(1))
	
		If MsSeek(xFilial("CC2") + SM0->M0_ESTCOB + TRB->CodCidadeSync )
			cCidade := CC2->CC2_MUN
		Else
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Cidade ("+TRB->CodCidadeSync+") não encontrada!")
			lRet := .F.
		Endif
	
	Endif

	If lRet
	
		If lVist
		
			dbSelectArea("AA3")
			AA3->(dbSetOrder(1))
		
			If !AA3->(MsSeek( xFilial("AA3") + cCli + cLoja + "REDE ELETRICA  " + Alltrim(TRB->Numero) ))
			
				RecLock("AA3", .T.)
				AA3->AA3_FILIAL  := xFilial("AA3")
				AA3->AA3_CODCLI  := cCli
				AA3->AA3_LOJA    := cLoja
				AA3->AA3_CODPRO  := "REDE ELETRICA  "
				AA3->AA3_NUMSER  := TRB->Numero
				MsUnLock()
			
			Endif
		
			_cNumOrc := GetSXENum("AB3", "AB3_NUMORC")
		//ConfirmSx8()
		/*
		cQuery := " SELECT COALESCE(MAX(AB3.AB3_NUMORC),'000000') + 1 as AB3_NUMORC "
		cQuery += " FROM " + RetSqlName("AB3") + " AB3 "
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "SEQB3")
		
		_cNumOrc := StrZero(SEQB3->AB3_NUMORC,6)
		
		SEQB3->(dbCloseArea())
		*/
		
		//MsgInfo("Orçamento")
		//Alert(_cNumOrc)
		
		//Geração de Orçamentos - Vistoria 
			aADD(aCab,{"AB3_NUMORC", _cNumOrc,})
			aADD(aCab,{"AB3_NROBRA", TRB->Numero,})
			aADD(aCab,{"AB3_YEND",   TRB->Endereco,})
			aADD(aCab,{"AB3_EQREF",  TRB->EquipamentoRef,})
			aADD(aCab,{"AB3_YEST",   SM0->M0_ESTCOB,})
			aADD(aCab,{"AB3_SCIDAD", TRB->CodCidadeSync,})
			aADD(aCab,{"AB3_YMUNI",  cCidade,})
			aADD(aCab,{"AB3_CODCLI", cCli,".T."})
			aADD(aCab,{"AB3_LOJA",   cLoja,})
			aADD(aCab,{"AB3_EMISSA", dDataBase,})
			aADD(aCab,{"AB3_CONPAG", SA1->A1_COND,})
			aADD(aCab,{"AB3_YDESCC", SA1->A1_NOME,})
			aADD(aCab,{"AB3_PRIORI", _cPriori,})
			aADD(aCab,{"AB3_TPOS",   TRB->CodTipoOSSync,})
			aADD(aCab,{"AB3_USSPRE", _nUssPre,})
			aADD(aCab,{"AB3_TABELA", _cTab,})
			aADD(aCab,{"AB3_SVISTO", TRB->CodVistoriadorSync,})
		
			aADD(aItem,{"AB4_ITEM",   "01",})
			aADD(aItem,{"AB4_TIPO",   IIF(lEfetOrc,"2","1"),})		// 1 Orçamento | 2 OS
			aADD(aItem,{"AB4_CODPRO", "REDE ELETRICA  ",})
			aADD(aItem,{"AB4_NUMSER", TRB->Numero,})
			aADD(aItem,{"AB4_CODPRB", _cOcorr,})
		
			aADD(aItens,aItem)
			aItem:= {}
		
			lMsHelpAuto := .F.
			lMsErroAuto := .F.
		
			RegToMemory("AB3")
		
			ITEM->(dbGoTop())
		
			_cItem  := "01"
		
			While ITEM->(!EoF())
			
				_nValUnit := 0
				_cCodSrv  := ""
			
				DA1->(dbSetOrder(1))
			
				If DA1->(MsSeek( xFilial("DA1") + _cTab + Alltrim(ITEM->ItemSync) ))
					_nValUnit := DA1->DA1_PRCVEN //* _nUssPre
					_cCodSrv  := DA1->DA1_YSRV
				Else
					Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Produto não encontrado na tabela de Preço!")
					lRet := .F.
					EXIT
				Endif
			
				aadd(aDetalhe,{"AB5_ITEM",   "01",})
				aadd(aDetalhe,{"AB5_SUBITE", _cItem,})
				aadd(aDetalhe,{"AB5_CODPRO", ITEM->ItemSync,})
				aadd(aDetalhe,{"AB5_CODSER", _cCodSrv,})
				aadd(aDetalhe,{"AB5_QUANT",  ITEM->QtdVistoriada,})
				aadd(aDetalhe,{"AB5_VUNIT",  _nValUnit,})
				aadd(aDetalhe,{"AB5_TOTAL",  U_STCA020B(_nValUnit,ITEM->QtdVistoriada),})
			
				_cItem := Soma1(_cItem)
			
				aADD(aDetalhes,aDetalhe)
				aDetalhe:= {}
			
				ITEM->(dbSkip())
			Enddo
		
			ITEM->(dbCloseArea())
		
			If lRet
			
				TECA400(,U_OrdAuto(aCab),aItens,aDetalhes,3)
			
				If lMsErroAuto
					MsgInfo("Erro na inclusão do Orçamento da Obra " + TRB->Numero + ". Verifique a tela a seguir.")
					MostraErro()
					DisarmTransaction()
					lRet := .F.
				Else
				//MsgInfo("Inclusão de orçamento efetuada com sucesso!")
				
					_ImpCheck(_cNumOrc, "", "V", TRB->OrdemSync)
				
					If lEfetOrc
						cQuery := " SELECT COALESCE(MAX(AB6.AB6_NUMOS),'') as AB6_NUMOS "
						cQuery += " FROM " + RetSqlName("AB6") + " AB6 "
						cQuery += " WHERE " + RetSqlCond("AB6")
					
						dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "OS")
					
						If OS->(!EoF())
							TcSQLExec("UPDATE "+RetSqlName("AB8") + " SET D_E_L_E_T_ = '*' WHERE AB8_FILIAL = '"+xFilial("AB8")+"' AND AB8_NUMOS = '"+OS->AB6_NUMOS+"' AND AB8_ITEM = '01' ")
						Endif
					
						OS->(dbCloseArea())
					endif
				
				// Copia a Tabela AB5 para a ZZP
					cQuery := "INSERT INTO " + RetSqlName("ZZP")
					cQuery += "			(ZZP_NUMORC, ZZP_ITEM, ZZP_SUBITE, ZZP_CODPRO, ZZP_DESPRO, ZZP_CODSER, ZZP_QUANT, ZZP_VUNIT, ZZP_TOTAL, ZZP_PRCLIS, ZZP_FILIAL, ZZP_YTABPE, D_E_L_E_T_, R_E_C_N_O_) "
					cQuery += " SELECT 	 AB5_NUMORC, AB5_ITEM, AB5_SUBITE, AB5_CODPRO, AB5_DESPRO, AB5_CODSER, AB5_QUANT, AB5_VUNIT, AB5_TOTAL, AB5_PRCLIS, AB5_FILIAL, AB5_YTABPR, D_E_L_E_T_, R_E_C_N_O_  "
					cQuery += " FROM " + RetSqlName("AB5")
					cQuery += " WHERE AB5_NUMORC = '"+_cNumOrc+"'"
					cQuery += "  AND D_E_L_E_T_ <> '*' "
				
					IF TcSQLExec(cQuery) < 0
						MsgStop("Copia a Tabela AB5 para a ZZP - TCSQLError() " + TCSQLError())
					endif
				
				// Deleta a AB5 para nao executar nada no padrao.
					cQuery := "UPDATE " + RetSqlName("AB5")
					cQuery += " SET D_E_L_E_T_ = '*' "
					cQuery += " WHERE AB5_NUMORC = '"+_cNumOrc+"'"
					cQuery += " AND D_E_L_E_T_ <> '*' "
				
					IF TcSQLExec(cQuery) < 0
						MsgStop("Deleta a AB5 - TCSQLError() " + TCSQLError())
					endif
				
				Endif
			
			Endif
		
		Else
		
			dbSelectArea("AA3")
			AA3->(dbSetOrder(1))
		
			If !AA3->(MsSeek( xFilial("AA3") + cCli + cLoja + "REDE ELETRICA  " + Alltrim(TRB->Numero) ))
			
				RecLock("AA3", .T.)
				AA3->AA3_FILIAL  := xFilial("AA3")
				AA3->AA3_CODCLI  := cCli
				AA3->AA3_LOJA    := cLoja
				AA3->AA3_CODPRO  := "REDE ELETRICA  "
				AA3->AA3_NUMSER  := TRB->Numero
				MsUnLock()
			
			Endif
		
		// Antes de gerar OS preciso ver se os itens estão corretos!!!
		// Modificação efetuada por Felipe S. Raota - TCX111 - 04/07/13
		
			ITEM->(dbGoTop())
		
			While ITEM->(!EoF())
			
				_nValUnit := 0
				_cCodSrv  := ""
			
				DA1->(dbSetOrder(1))
			
				If !DA1->(MsSeek( xFilial("DA1") + _cTab + ITEM->ItemSync ))
					Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Produto não encontrado na tabela de Preço! OS não será gerada")
					lRet := .F.
					EXIT
				Endif
			
				ITEM->(dbSkip())
			Enddo
		
			If lRet
			
			//Apontamento das OS's
				aADD(aCab,{"AB9_NUMOS",  Alltrim(cOsProth) + "01"					,nil})
				aADD(aCab,{"AB9_SEQ",    cSeq										,nil})
				aADD(aCab,{"AB9_CODTEC", TRB->CodEquipeSync							,nil})
				aADD(aCab,{"AB9_APRNR",  TRB->Apr_numero   							,nil})
			
			// Grava equipe que gerou a OS
				If cSeq == "01"
					aADD(aCab,{"AB9_YEQUIP",  TRB->CodEquipeSync					,nil})
				Endif
			
			// Data/Hora Chegada
				aADD(aCab,{"AB9_DTCHEG", TRB->DtChegada								,nil})
				aADD(aCab,{"AB9_HRCHEG", Left(TRB->HrChegada,5)						,nil})
				aADD(aCab,{"AB9_DTSAID", TRB->DtSaida								,nil})
				aADD(aCab,{"AB9_HRSAID", Left(TRB->HrSaida,5)						,nil})
			
			// Data/Hora Chegada/Saida Base
				aADD(aCab,{"AB9_DTCHEB", TRB->DtChegadaBase						    ,nil})
				aADD(aCab,{"AB9_HRCHEB", Left(TRB->HrChegadaBase,5)					,nil})
				aADD(aCab,{"AB9_DTSAIB", TRB->DtSaidaBase							,nil})
				aADD(aCab,{"AB9_HRSAIB", Left(TRB->HrSaidaBase,5)					,nil})
			
			// Data/Hora do Inicio do Serviço
				aADD(aCab,{"AB9_DTINI",  TRB->DtInicioServico						,nil})
				aADD(aCab,{"AB9_HRINI",  Left(TRB->HrInicioServico,5)		 	    ,nil})
				aADD(aCab,{"AB9_DTFIM",  TRB->DtTerminoServico				 	    ,nil})
				aADD(aCab,{"AB9_HRFIM",  Left(TRB->HrTerminoServico,5)				,nil})
			
			// Hora do Intervalo
				If Left(TRB->HrInicioPonto,5) != '00:00'
					aADD(aCab,{"AB9_YIINT",  Left(TRB->HrInicioPonto,5)				,nil})
				Endif
				If Left(TRB->HrTerminaPonto,5) != '00:00'
					aADD(aCab,{"AB9_YFINT",  Left(TRB->HrTerminaPonto,5)			,nil})
				Endif
			
				aADD(aCab,{"AB9_KMINI",  TRB->KmInicio		 	   					,nil})
				aADD(aCab,{"AB9_KMFIM",  TRB->KMFim										,nil})
			
				aADD(aCab,{"AB9_STPGER", "2"										,nil}) // Mobile
			
				aADD(aCab,{"AB9_CODPRB", _cOcorr											,nil})
				aADD(aCab,{"AB9_NROBRA", TRB->Numero									,nil})
				aADD(aCab,{"AB9_SITSRV", ZZI->ZZI_CODIGO								,nil})
				aADD(aCab,{"AB9_MEMO2",  Alltrim(TRB->Obs)							,nil})
			
				aItem:= {}
				aADD(aItens,aItem)
			
				lMsHelpAuto := .F.
				lMsErroAuto := .F.
			
				aCab := aClone(u_OrdAuto(aCab))
			
				INCLUI := .T.
				RegToMemory("AB9", .T.)
			
				M->AB9_DTINI  := TRB->DtInicioServico
				M->AB9_HRINI  := Left(TRB->HrInicioServico,5)
				M->AB9_DTFIM  := TRB->DtTerminoServico
				M->AB9_HRFIM  := Left(TRB->HrTerminoServico,5)
			
				M->AB9_DTCHEG := TRB->DtChegada
				M->AB9_HRCHEG := Left(TRB->HrChegada,5)
				M->AB9_DTSAID := TRB->DtSaida
				M->AB9_HRSAID := Left(TRB->HrSaida,5)
			
				M->AB9_DTCHEB := TRB->DtChegadaBase
				M->AB9_HRCHEB := Left(TRB->HrChegadaBase,5)
				M->AB9_DTSAIB := TRB->DtSaidaBase
				M->AB9_HRSAIB := Left(TRB->HrSaidaBase,5)
			
				If Left(TRB->HrInicioPonto,5) != '00:00'
					M->AB9_YIINT  := Left(TRB->HrInicioPonto,5)
				Endif
				If Left(TRB->HrTerminaPonto,5) != '00:00'
					M->AB9_YFINT  := Left(TRB->HrTerminaPonto,5)
				Endif
			
				M->AB9_KMINI  := TRB->KmInicio
				M->AB9_KMFIM  := TRB->KMFim
				M->AB9_APRNR  := TRB->Apr_numero
				M->AB9_STPGER := "2"
			
				TECA460(aCab,aItens,3)
			
				If lMsErroAuto
					MsgInfo("Erro no Apontamento da Obra " + TRB->Numero + ". Verifique a tela a seguir.")
					MostraErro()
					DisarmTransaction()
					lRet := .F.
				Else
					
					_ImpCheck(Alltrim(cOsProth)+"01", cSeq, "A", TRB->OrdemSync)
					
					// ** OBSERVAÇÕES **
					// - A tabela AB8 é o espelho da ABC tendo ABC_SUBOS = AB8_SUBITE, se tiverem diferentes, irá duplicar a AB8
					// - O campo ABC_SUBOS, é um sequencial para todos registros de mesmo ABC_NUMOS
					// - Sempre que eu incluir aqui, crio um novo ABC_SEQ e somo os ABC_ITEM
					// - AB8_ITEM = ABC_SEQ o.O
					
					ITEM->(dbGoTop())
					
					cQuery := " SELECT COALESCE(MAX(ABC.ABC_SUBOS),'00') as ABC_SUBOS "
					cQuery += " FROM " + RetSqlName("ABC") + " ABC "
					cQuery += " WHERE ABC.ABC_NUMOS = '"+Alltrim(cOsProth) + "01"+"' "
					cQuery += "   AND " + RetSqlCond("ABC") 
					
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "SUB")
					
					_cSubOs := Soma1(SUB->ABC_SUBOS)
					
					SUB->(DbCloseArea())
					
					/*
					// Busco o maior ABC_SEQ, pois é um novo apontamento
					cQuery := " SELECT COALESCE(MAX(ABC.ABC_SEQ),'00') as ABC_SEQ "
					cQuery += " FROM " + RetSqlName("ABC") + " ABC "
					cQuery += " WHERE ABC.ABC_NUMOS = '"+Alltrim(cOsProth) + "01"+"' "
					cQuery += "   AND ABC.ABC_SEQ = '"+_cSubOs+"' "
					cQuery += "   AND " + RetSqlCond("ABC")
					
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "SEQ")
					
					_cItem := Soma1(SEQ->ABC_ITEM)
					*/
					
					_cItem := "01" // Deixei fixo, pois sempre vai gerar um novo sequencial
					
					SEQ->(DbCloseArea())
				
					While ITEM->(!EoF())
					
						_nValUnit := 0
						_cCodSrv  := ""
					
						DA1->(dbSetOrder(1))
					
						If DA1->(MsSeek( xFilial("DA1") + _cTab + ITEM->ItemSync ))
							_nValUnit := DA1->DA1_PRCVEN
							_cCodSrv  := DA1->DA1_YSRV
						Else
							Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Produto não encontrado na tabela de Preço!")
							lRet := .F.
							EXIT
						Endif
					
						SB1->(DbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1") + ITEM->ItemSync))
					
						DBSelectArea("ABC") 
						
						RecLock("ABC", .T.)
							ABC->ABC_FILIAL  := xFilial("ABC")
							ABC->ABC_NUMOS   := Alltrim(cOsProth) + "01"
							ABC->ABC_SUBOS   := _cSubOs
							ABC->ABC_CODTEC  := TRB->CodEquipeSync
							ABC->ABC_SEQ     := cSeq
							ABC->ABC_ITEM    := _cItem
							ABC->ABC_CODPRO  := ITEM->ItemSync
							ABC->ABC_DESCRI  := SB1->B1_DESC
							ABC->ABC_QUANT   := ITEM->QtdRealizada
							ABC->ABC_VLUNIT  := _nValUnit
							ABC->ABC_VALOR   := U_STCA020B(_nValUnit,ITEM->QtdRealizada)
							ABC->ABC_CODSER  := _cCodSrv
							ABC->ABC_YTABPR  := _cTab
						MsUnLock()
					
					/*
					AB8->(dbSetOrder(5))
					//If !AB8->(MsSeek( xFilial("AB8") + PADR(Alltrim(cOsProth),TamSx3('AB8_NUMOS')[1]) + "01" + PADR(Alltrim(ITEM->ItemSync),TamSx3('AB8_CODPRO')[1]) ))
					
						cQuery := " SELECT COALESCE(MAX(AB8.AB8_SUBITE),'00') as AB8_SUBITE "
						cQuery += " FROM " + RetSqlName("AB8") + " AB8 "
						cQuery += " WHERE AB8.AB8_NUMOS = '"+Alltrim(cOsProth)+"' "
						cQuery += "   AND AB8.AB8_ITEM = '01' "
						cQuery += "   AND AB8.AB8_FILIAL = '"+xFilial("AB8")+"' "
						//cQuery += "   AND " + RetSqlCond("AB8")
						
						dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "SEQB8") 
						
						_cSubIteB8  := Soma1(SEQB8->AB8_SUBITE)
						
						SEQB8->(DbCloseArea())
						*/
					
						DBSelectArea("AB8")
						
						RecLock("AB8", .T.)
						AB8->AB8_FILIAL := xFilial("AB8")
						AB8->AB8_NUMOS  := Alltrim(cOsProth)
						//AB8->AB8_ITEM   := "01"
						AB8->AB8_ITEM   := cSeq
						AB8->AB8_SUBITE := ABC->ABC_SUBOS
						AB8->AB8_CODPRO := ITEM->ItemSync
						AB8->AB8_DESPRO := SB1->B1_DESC
						AB8->AB8_CODSER := _cCodSrv
						AB8->AB8_QUANT	:= ITEM->QtdRealizada
						AB8->AB8_VUNIT	:= _nValUnit
						AB8->AB8_TOTAL	:= U_STCA020B(_nValUnit,ITEM->QtdRealizada)
						AB8->AB8_ENTREG := dDataBase
						AB8->AB8_PRCLIS := _nValUnit
						AB8->AB8_CODCLI := cCli
						AB8->AB8_LOJA   := cLoja
						AB8->AB8_CODPRD := "REDE ELETRICA  "
						AB8->AB8_NUMSER := TRB->Numero
						AB8->AB8_TIPO   := "3"
						AB8->AB8_LOCAL  := "01"
						MsUnLock()
						
						//_cSubIteB8  := Soma1(_cSubIteB8)
					
					//Endif
					
						_cSubOs := Soma1(_cSubOs)
						_cItem := Soma1(_cItem)
						
						ITEM->(dbSkip())
					Enddo
				
				// Modifico campo AB6_SREENV
				
					dbSelectArea("AB6")
					AB6->(dbSetOrder(1))
				
					If AB6->(MsSeek( xFilial("AB6") + Alltrim(cOsProth) ))
						RecLock("AB6", .F.)
						AB6->AB6_SREENV := "N"
						MsUnLock()
					Endif
				
					U_FB903TEC(TRB->OrdemSync, Left(cOsProth,6))
					
					ITEM->(dbCloseArea())
					
					// Efetua vinculo entre OS x Técnicos
					cQuery := " SELECT * "
					cQuery += " FROM FULL_ORDEMINTEGRANTE LEFT JOIN "+RetSqlName("ZZ4")+" ZZ4 ON ZZ4.ZZ4_CODTEC = CodIntegranteSync "
					cQuery += " WHERE CodOrdemServicoSync = '"+Alltrim(Str(TRB->OrdemSync))+"' "
					cQuery += "   AND ZZ4.D_E_L_E_T_ = ' ' "
					cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"
				
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "TEC")
				
					dbSelectArea("ZZ5")
					
					While !TEC->(EoF())
						
						cGrPPR := _GetZZ4(M->AB9_CODTEC)
						
						RecLock("ZZ5",.T.)
						ZZ5->ZZ5_FILIAL	:= xFilial("ZZ5")
						ZZ5->ZZ5_NUMOS 	:= Alltrim(cOsProth) + "01"
						ZZ5->ZZ5_EQUIPE	:= TRB->CodEquipeSync
						ZZ5->ZZ5_SEQ   	:= cSeq
						ZZ5->ZZ5_DTCHEG := dDataBase
						ZZ5->ZZ5_CODTEC	:= TEC->CodIntegranteSync
						ZZ5->ZZ5_ENCARR	:= IIF(TEC->ZZ4_ENCARE == '2', 'S', ' ')
						ZZ5->ZZ5_CODGRP	:= TEC->ZZ4_GRPPR
						ZZ5->(MsUnlock())
					
						TEC->(dbSkip())
					Enddo
				
					TEC->(dbCloseArea())
				
				Endif
			
			Endif
			
		Endif
	
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _geraOs    ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera Ordem de Serviço vinda da Integração.                        ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103TEC                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _geraOS()

	Local aCab   := {}
	Local aItem  := {}
	Local aItens := {}
	Local aApont := {}
	Local aAponts := {}

	Local cCli  := ""
	Local cLoja := ""

	Local lVist := .T.
	Local lRet  := .T.

	Local cSeq	:= ""

	Private lMsHelpAuto 	  := .F.
	Private lMsErroAuto 	  := .F.

	cCli  := Left(TRB->CodClienteSync,6)
	cLoja := Right(TRB->CodClienteSync,2)

	If SA1->(MsSeek( xFilial("SA1") + cCli + cLoja ))
		If Empty(SA1->A1_COND)
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Condição de pagamento inválida!")
			lRet := .F.
		Endif
	Else
		Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Cliente não encontrado!")
		lRet := .F.
	Endif

	If !Z10->(MsSeek( xFilial("Z10") + TRB->CodTipoOSSync ))
		Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + "Tipo de OS não encontrada!")
		lRet := .F.
	Endif

	_cOcorr  := ""
	_cPriori := ""

	AAG->(dbSetOrder(2))

	If AAG->(MsSeek( xFilial("AAG") + TRB->CodTipoOSSync ))
		_cOcorr  := AAG->AAG_CODPRB
		_cPriori := AAG->AAG_PRIORI
	Else
		Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Ocorrência não encontrada!")
		lRet := .F.
	Endif

	AAG->(dbSetOrder(1))

	If lRet
	
	// Primeiro filtrar ZZL, tudo que tem para o tipo de OS
	// Depois com essas tabelas, ir na ZZJ e verificar qual tabela está alocada para o cliente.
	
		cQuery := " SELECT TOP 1 ZZJ.ZZJ_TABELA, DA0.DA0_YVUSS "
		cQuery += " FROM "+RetSqlName("ZZL")+" ZZL INNER JOIN "+RetSqlName("ZZJ")+" ZZJ ON ZZL.ZZL_TABELA = ZZJ.ZZJ_TABELA "
		cQuery += " 										 INNER JOIN "+RetSqlName("DA0")+" DA0 ON ZZL.ZZL_TABELA = DA0.DA0_CODTAB "
		cQuery += " WHERE ZZL_TIPOOS LIKE '"+Alltrim(TRB->CodTipoOSSync)+"' "
		cQuery += "   AND ZZJ.ZZJ_CLIENT = '"+cCli+"' "
		cQuery += "   AND ZZJ.ZZJ_LOJA = '"+cLoja+"' "
		cQuery += "   AND " + RetSqlCond("ZZL")
		cQuery += "   AND " + RetSqlCond("ZZJ")
	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "TAB")
	
		If TAB->(!EoF())
			_cTab := TAB->ZZJ_TABELA
			_nUssPre := TAB->DA0_YVUSS
		Else
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Vinculo com Tabela de Preço inválida!")
			lRet := .F.
		Endif
	
		TAB->(dbCloseArea())
	Endif

	IF lRet
		dbSelectArea("CC2")
		CC2->(dbSetOrder(1))
	
		If MsSeek(xFilial("CC2") + SM0->M0_ESTCOB + TRB->CodCidadeSync )
			cCidade := CC2->CC2_MUN
		Else
			Alert("Erro ao importar cód: " + Alltrim(TRB->Numero) + ". Cidade ("+TRB->CodCidadeSync+") não encontrada!")
			lRet := .F.
		Endif
	
	Endif

	If lRet
	
	//Geração de Ordem de Serviço - Emergencial
	
		dbSelectArea("AA3")
		AA3->(dbSetOrder(1))
	
		If !AA3->(MsSeek( xFilial("AA3") + cCli + cLoja + "REDE ELETRICA  " + Alltrim(TRB->Numero) ))
		
			RecLock("AA3", .T.)
			AA3->AA3_FILIAL  := xFilial("AA3")
			AA3->AA3_CODCLI  := cCli
			AA3->AA3_LOJA    := cLoja
			AA3->AA3_CODPRO  := "REDE ELETRICA  "
			AA3->AA3_NUMSER  := TRB->Numero
			MsUnLock()
		
		Endif
		
	// Verifico se já não existe OS para a Obra, para não ter duplicidade.
		cQuery := " SELECT TOP 1 AB6_NUMOS "
		cQuery += " FROM "+RetSqlName("AB6")+" AB6 "
		cQuery += " WHERE AB6.AB6_NROBRA = '"+Alltrim(TRB->Numero)+"' "
		cQuery += "   AND AB6.D_E_L_E_T_ = ' ' "
	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "BUSC")
	
		If BUSC->(!EoF())
			_cNumOS := BUSC->AB6_NUMOS
			_lExistOs := .T.
		Else
			_lExistOs := .F.
		Endif
	
		BUSC->(dbCloseArea())
	
		If !_lExistOs
		
		//_cNumOS := GetSxeNum("AB6","AB6_NUMOS")
		//ConfirmSX8()
		
		//cQuery := " SELECT COALESCE(MAX(AB6.AB6_NUMOS),'000000') + 1 as AB6_NUMOS "
		//cQuery += " FROM " + RetSqlName("AB6") + " AB6 "
		
		//dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "SEQB6")
		
		//_cNumOS := StrZero(SEQB6->AB6_NUMOS,6)
		
		//MsgInfo("OS")
		//Alert(_cNumOS)
		
		//ConfirmSX8()
		
		//SEQB6->(dbCloseArea())
		
		//aADD(aCab,{"AB6_NUMOS", _cNumOS ,})
			aADD(aCab,{"AB6_NROBRA", TRB->Numero,})
			aADD(aCab,{"AB6_YEND",   TRB->Endereco,})
			aADD(aCab,{"AB6_EQREF",  TRB->EquipamentoRef,})
			aADD(aCab,{"AB6_YEST",   SM0->M0_ESTCOB,})
			aADD(aCab,{"AB6_SCIDAD", TRB->CodCidadeSync,})
			aADD(aCab,{"AB6_YMUNI",  cCidade,})
			aADD(aCab,{"AB6_CODCLI", cCli,})
			aADD(aCab,{"AB6_LOJA",   cLoja,})
			aADD(aCab,{"AB6_EMISSA", dDataBase,})
			aADD(aCab,{"AB6_CONPAG", SA1->A1_COND,})
			aADD(aCab,{"AB6_YDESCR", SA1->A1_NOME,})
			aADD(aCab,{"AB6_PRIORI", _cPriori,})
			aADD(aCab,{"AB6_TPOS",   TRB->CodTipoOSSync,})
			aADD(aCab,{"AB6_USSPRE", _nUssPre,})
			aADD(aCab,{"AB6_TABELA", _cTab,})
			aADD(aCab,{"AB6_ATEND" , cUserName,})
			aADD(aCab,{"AB6_HORA"  , Time(),})
			aADD(aCab,{"AB6_STPGER", "2",}) // Mobile
			If !Empty(TRB->CodSup)
				aADD(aCab,{"AB6_SCODSU", padr(TRB->CodSup,6),".T."}) // Supervisor
			Endif
		
			aADD(aItem,{"AB7_ITEM",   "01",} )
			aADD(aItem,{"AB7_TIPO",   "1",})
			aADD(aItem,{"AB7_CODPRO", "REDE ELETRICA  ",})
			aADD(aItem,{"AB7_NUMSER", TRB->Numero,})
			aADD(aItem,{"AB7_CODPRB", _cOcorr,})
		
			aADD(aItens,U_OrdAuto(aItem))
			aItem:= {}
		
			lMsHelpAuto := .F.
			lMsErroAuto := .F.
		
			aAponts := {}
		
			_cNumOS := ""
		
			If lRet
			
				TECA450(,U_OrdAuto(aCab),aItens,aAponts,3, @_cNumOs)
			
				//Alert(_cNumOS)
			
				If lMsErroAuto
					MsgInfo("Erro na inclusão da Ordem de Serviço da Obra " + TRB->Numero + ". Verifique a tela a seguir.")
					MostraErro()
					DisarmTransaction()
				//RollBackSX8()
					lRet := .F.
				Else
				//ConfirmSX8()
				//MsgInfo("Inclusão de Ordem de Serviço efetuada com sucesso!")
				
					lRet := _geraOrcam(_cNumOS)
				
				Endif
			
			Endif
		
		Else
			lRet := _geraOrcam(_cNumOS)
		Endif
	
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MarkCod    ³ Autor ³ Felipe S. Raota            ³ Data ³ 25/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Marca os itens para integração.                                   ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901TEC                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MarkCod(lAlt)

	Local oOk     := LoadBitmap(GetResources(), "LBOK")
	Local oNo     := LoadBitmap(GetResources(), "LBNO")
	Local oQual
	Local oDlg
	Local cAlias  := Alias()
	Local nX	     := 0
	Local cVar    := "  "
	Local nOpca   := 0
	Local aOrdem  := {}
	Local aAux    := {}
	Local cCad    := "Seleção de Atendimentos para Importação"
	Local lCont   := .T.
	Local cQuery  := ""
	Local lRunDblClick := .T.
	Local nOpc := 0
	Local _x := 0

	Local lVistor := .T.

	Local lAltOs := .F.

	If !lAlt

		Private cPerg := Padr("FB901TEC", 10 , " ") //Padr("FB901TEC", LEN(SX1->X1_GRUPO), " ")
	
		_ValidPerg()
	
		If !Pergunte(cPerg,.T.)
		Return {}
		EndIf

	Endif

	cQuery := " SELECT OrdemServicoSync as OrdemSync, Numero, CodClienteSync, CodUsuarioSync, CodTipoOSSync, CodEquipeSync, CodVistoriadorSync, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrChegada, 112) as DtChegada, CONVERT(VarChar(19), DtHrChegada, 108) as HrChegada, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrSaida, 112) as DtSaida, CONVERT(VarChar(19), DtHrSaida, 108) as HrSaida, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrInicioPonto, 112) as DtInicioPonto, CONVERT(VarChar(19), DtHrInicioPonto, 108) as HrInicioPonto, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrTerminaPonto, 112) as DtTerminaPonto, CONVERT(VarChar(19), DtHrTerminaPonto, 108) as HrTerminaPonto, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrInicioServ, 112) as DtInicioServico, CONVERT(VarChar(19), DtHrInicioServ, 108) as HrInicioServico, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrTerminoServ, 112) as DtTerminoServico, CONVERT(VarChar(19), DtHrTerminoServ, 108) as HrTerminoServico, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrSaidaBase, 112) as DtSaidaBase, CONVERT(VarChar(19), DtHrSaidaBase, 108) as HrSaidaBase, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrChegadaBase, 112) as DtChegadaBase, CONVERT(VarChar(19), DtHrChegadaBase, 108) as HrChegadaBase, "
	cQuery += "		   CodSupervisorSync as CodSup"
	cQuery += " FROM FULL_ORDEM "
	If MV_PAR01 == 5
		cQuery += " WHERE Importado = 1 "
	Else
		cQuery += " WHERE Importado = 0 "
	Endif
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"
	cQuery += " ORDER BY OrdemServicoSync "

	TcQuery cQuery new alias ORD

	TCSetField ("ORD", "DtChegada", "D")
	TCSetField ("ORD", "DtSaida", "D")
	TCSetField ("ORD", "DtInicioPonto", "D")
	TCSetField ("ORD", "DtTerminaPonto", "D")
	TCSetField ("ORD", "DtVistoria", "D")
	TCSetField ("ORD", "DtRealida", "D")
	TCSetField ("ORD", "DtInicioServico", "D")
	TCSetField ("ORD", "DtTerminoServico", "D")
	TCSetField ("ORD", "DtSaidaBase", "D")
	TCSetField ("ORD", "DtChegadaBase", "D")

	While !ORD->(EoF())
	
	//Verificar se é vistoria
	
		cQuery := " SELECT * "
		cQuery += " FROM FULL_ORDEMITEM "
		cQuery += " WHERE OrdemServicoSync = "+Alltrim(Str(ORD->OrdemSync))+" "
		cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"
	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "VIST")
	
		While VIST->(!EoF())
		
			lVistor  := .T.
		
			If VIST->QtdRealizada > 0
				lVistor := .F. //Apontamento
			Else
				If VIST->QtdVistoriada > 0
					lVistor := .T. // Vistoria
				Else
					EXIT
				Endif
			Endif
		
			VIST->(dbSkip())
		Enddo
	
		VIST->(dbCloseArea())
	
		If lVistor
			cTipo := "Vistoria"
		Else
	
		// Verifico se já não existe OS para a Obra, para não ter duplicidade.
			cQuery := " SELECT TOP 1 AB6_NUMOS "
			cQuery += " FROM "+RetSqlName("AB6")+" AB6 "
			cQuery += " WHERE AB6.AB6_NROBRA = '"+Alltrim(ORD->Numero)+"' "
			cQuery += "   AND AB6.D_E_L_E_T_ = ' ' "
		
			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), "BUSC")
		
			If BUSC->(!EoF())
				_lExistOs := .T.
			Else
				_lExistOs := .F.
			Endif
		
			BUSC->(dbCloseArea())
		
			If _lExistOs
				cTipo := "Apontamento"
			Else
				cTipo := "Ordem de Serviço"
			Endif
		Endif
	
		dbSelectArea("SA1")
	
		_cNome := fBuscaCpo("SA1", 1, xFilial("SA1") + Alltrim(ORD->CodClienteSync), "A1_NOME")
	
		If MV_PAR01 == 1
			cTipoPar := "Vistoria"
		ElseIf MV_PAR01 == 2
			cTipoPar := "Apontamento"
		ElseIf MV_PAR01 == 3
			cTipoPar := "Ordem de Serviço"
		Endif
	
		If MV_PAR01 <> 4 .AND. MV_PAR01 <> 5
		// Tipo de importação
			If cTipo <> cTipoPar
				ORD->(dbSkip())
				LOOP
			Endif
		Endif
	
	//Nome cliente
		If _cNome < MV_PAR02 .OR. _cNome > MV_PAR03
			ORD->(dbSkip())
			LOOP
		Endif
	
	//Código de importação
		If ORD->OrdemSync < MV_PAR04 .OR. ORD->OrdemSync > MV_PAR05
			ORD->(dbSkip())
			LOOP
		Endif
	
	//Numero da obra
		If Alltrim(ORD->Numero) < MV_PAR06 .OR. Alltrim(ORD->Numero) > MV_PAR07
			ORD->(dbSkip())
			LOOP
		Endif
	
	//Cliente + Loja
		If Alltrim(ORD->CodClienteSync) < MV_PAR08+MV_PAR09 .OR. Alltrim(ORD->CodClienteSync) > MV_PAR10+MV_PAR11
			ORD->(dbSkip())
			LOOP
		Endif
	
	//Técnico
		If Alltrim(ORD->CodUsuarioSync) < MV_PAR12 .OR. Alltrim(ORD->CodUsuarioSync) > MV_PAR13
			ORD->(dbSkip())
			LOOP
		Endif
	
	//Data de Chegada
		If ORD->DtChegada < MV_PAR14 .OR. ORD->DtChegada > MV_PAR15
			ORD->(dbSkip())
			LOOP
		Endif
		
		ZZ4->(DbSetOrder(1))
		If ZZ4->(DbSeek(xFilial("ZZ4")+Alltrim(ORD->CodEquipeSync)))
			If !Empty(ZZ4->ZZ4_CODSUP) .and. ZZ4->ZZ4_CODSUP <> _cCodSup
				ORD->(dbSkip())
				LOOP
			Endif
		Else
			ORD->(dbSkip())
			LOOP
		Endif
		
	
		AADD( aOrdem, { .F. , cTipo, ORD->OrdemSync, Alltrim(ORD->Numero), Alltrim(ORD->CodClienteSync), Alltrim(_cNome), Alltrim(ORD->CodEquipeSync), Alltrim(ORD->CodUsuarioSync),;
			Alltrim(ORD->CodVistoriadorSync), Alltrim(ORD->CodTipoOSSync), ORD->DtChegada, Alltrim(ORD->HrChegada),	ORD->DtSaida, Alltrim(ORD->HrSaida), ORD->DtInicioPonto, ;
			Alltrim(ORD->HrInicioPonto), ORD->DtTerminaPonto, Alltrim(ORD->HrTerminaPonto), ORD->DtInicioServico, Alltrim(ORD->HrInicioServico), ORD->DtTerminoServico, ;
			Alltrim(ORD->HrTerminoServico), ORD->DtSaidaBase, Alltrim(ORD->HrSaidaBase), ORD->DtChegadaBase, Alltrim(ORD->HrChegadaBase), alltrim(ORD->CodSup)})
	
		ORD->(dbSkip())
	Enddo

	If Len(aOrdem) > 0
	
		DEFINE MSDIALOG oDlg TITLE cCad From 5,0 To 31,93 OF oMainWnd
	
		@0.4, 0.3 TO 13.7, 41.1 LABEL cCad OF oDlg
	
		@1.0, .7 LISTBOX oQual VAR cVar Fields HEADER "", OemToAnsi("Tipo"), OemToAnsi("Cód"), OemToAnsi("Nr. Obra"), OemToAnsi("Cliente"), OemToAnsi("Nome"), OemToAnsi("Equipe"), OemToAnsi("Técnico"), OemToAnsi("Vistoriador"), OemToAnsi("Tipo OS"), OemToAnsi("Dt. Chegada"), OemToAnsi("Hr. Chegada"),;
			OemToAnsi("Dt. Saida"), OemToAnsi("Hr. Saída"), OemToAnsi("Dt. Ini. Ponto"), OemToAnsi("Hr. Ini. Ponto"), OemToAnsi("Dt. Term. Ponto"), OemToAnsi("Hr. Term. Ponto"), OemToAnsi("Dt. Ini. Serviço"), OemToAnsi("Hr. Ini. Serviço"),;
			OemToAnsi("Dt. Fim Serviço"), OemToAnsi("Hr. Fim Serviço"), OemToAnsi("Dt. Saída Base"), OemToAnsi("Hr. Saída Base"), OemToAnsi("Dt. Chegada Base"), OemToAnsi("Hr. Chegada Base"), OemToAnsi("Supervisor");
			SIZE 320,175 ON DBLCLICK (aOrdem := Troca(oQual:nAt, aOrdem), oQual:Refresh()) //NOSCROLL
		oQual:SetArray(aOrdem)
		oQual:bLine := { || { if( aOrdem[oQual:nAt, 1], oOk, oNo), aOrdem[oQual:nAt, 2], aOrdem[oQual:nAt, 3], aOrdem[oQual:nAt, 4], aOrdem[oQual:nAt, 5], aOrdem[oQual:nAt, 6], aOrdem[oQual:nAt, 7], aOrdem[oQual:nAt, 8],;
			aOrdem[oQual:nAt, 9], aOrdem[oQual:nAt, 10], aOrdem[oQual:nAt, 11], aOrdem[oQual:nAt, 12], aOrdem[oQual:nAt, 13], aOrdem[oQual:nAt, 14], aOrdem[oQual:nAt, 15], aOrdem[oQual:nAt, 16], aOrdem[oQual:nAt, 17],;
			aOrdem[oQual:nAt, 18], aOrdem[oQual:nAt, 19], aOrdem[oQual:nAt, 20], aOrdem[oQual:nAt, 21], aOrdem[oQual:nAt, 22], aOrdem[oQual:nAt, 23], aOrdem[oQual:nAt, 24], aOrdem[oQual:nAt, 25], aOrdem[oQual:nAt, 26], aOrdem[oQual:nAt, 27]  } }
		oQual:bHeaderClick := { |oObj,nCol| If( lRunDblClick .And. nCol==1, aEval( aOrdem, { |e| e[1] := !e[1] } ), Nil ), lRunDblClick := !lRunDblClick, oQual:Refresh() }
	
		If _nLPos <> 0
			oQual:nAt := _nLPos
		Endif
	
		If MV_PAR01 <> 5
			oButton := tButton():New( 11.0, 330,'Todos os Itens',oDlg,{ || IIF( MsgYesNo("Deseja importar todos os itens?") , (nOpc := 1, oDlg:End()), )   },38,11,,,,.T. )
			oButton := tButton():New( 23.0, 330,'      OK      ',oDlg,{ || nOpc := 2, oDlg:End() },38,11,,,,.T. )
			oButton := tButton():New( 38.0, 330,'   Alterar    ',oDlg,{ || ( lAltOs := _altOs(aOrdem[oQual:nAt, 3], oQual:nAt), _nLPos:=oQual:nAt,  oDlg:End()) },38,11,,,,.T. )
			oButton := tButton():New( 50.0, 330,'   Excluir    ',oDlg,{ || ( lAltOs := _excOs(aOrdem[oQual:nAt, 3]), oDlg:End()) },38,11,,,,.T. )
		Else
			oButton := tButton():New( 23.0, 330,' Mudar Status ',oDlg,{ || nOpc := 3, oDlg:End() },38,11,,,,.T. )
		Endif
	
		oButton := tButton():New( 62.0, 330,'  Visualizar  ',oDlg,{ || _visualOs(aOrdem[oQual:nAt, 3]) },38,11,,,,.T. )
		oButton := tButton():New( 74.0, 330,'   Cancelar   ',oDlg,{ || nOpc := 0, oDlg:End() },38,11,,,,.T. )
	
		ACTIVATE MSDIALOG oDlg
	
		If lAltOs
			ORD->(dbCloseArea())
		Return .F.
		Else
			_nLPos := 0
		Endif
	
		If nOpc == 1
			For nX := 1 To Len(aOrdem)
				aOrdem[nX,1] := .T.
				If aOrdem[nX,1]
					aADD( aAux, Alltrim(Str(aOrdem[nX,3])) )
				Endif
			Next nX
		
			If Len(aAux) == 0
				MsgAlert ("Selecione um ou mais atendimentos.")
			Else
			Return aAux
			Endif
		EndIf
	
		If nOpc == 2
			For nX := 1 To Len(aOrdem)
				If aOrdem[nX,1]
					aadd( aAux, Alltrim(Str(aOrdem[nX,3])) )
				Endif
			Next nX
		
			If Len(aAux) == 0
				MsgAlert ("Selecione um ou mais atendimentos.")
			Else
			Return aAux
			Endif
		EndIf
	
		If nOpc == 3
	
			aAux := {}
		
			For nX := 1 To Len(aOrdem)
				If aOrdem[nX,1]
					aadd( aAux, Alltrim(Str(aOrdem[nX,3])) )
				Endif
			Next nX
		
			If Len(aAux) == 0
				MsgAlert ("Selecione um ou mais atendimentos.")
			Else
			
				For _x:=1 to len(aAux)
					TcSqlExec("UPDATE FULL_ORDEM SET Importado = 0 WHERE OrdemServicoSync = " + cValtoChar(aAux[_x]) + " AND Empresa = '"+SM0->M0_CODIGO+"'")
				Next
			
			Endif
		EndIf
	
	Else
		Alert("Nenhum atendimento para importar.")
	Endif

	ORD->(dbCloseArea())

	DbSelectArea(cAlias)

Return{}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _altOs   ³ Autor ³ Felipe S. Raota       ³ Data ³ 26/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteração dos dados Importados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MARKCOD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _altOs(nCodOs, nLin)

	cQuery := " SELECT OrdemServicoSync as OrdemSync, Numero, CodClienteSync, CodUsuarioSync, CodTipoOSSync, CodEquipeSync,
	cQuery += "  	   CONVERT(VarChar(10), DtHrChegada, 112) as DtChegada, CONVERT(VarChar(19), DtHrChegada, 108) as HrChegada, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrSaida, 112) as DtSaida, CONVERT(VarChar(19), DtHrSaida, 108) as HrSaida, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrInicioPonto, 112) as DtInicioPonto, CONVERT(VarChar(19), DtHrInicioPonto, 108) as HrInicioPonto, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrTerminaPonto, 112) as DtTerminaPonto, CONVERT(VarChar(19), DtHrTerminaPonto, 108) as HrTerminaPonto, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrInicioServ, 112) as DtInicioServico, CONVERT(VarChar(19), DtHrInicioServ, 108) as HrInicioServico, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrTerminoServ, 112) as DtTerminoServico, CONVERT(VarChar(19), DtHrTerminoServ, 108) as HrTerminoServico, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrSaidaBase, 112) as DtSaidaBase, CONVERT(VarChar(19), DtHrSaidaBase, 108) as HrSaidaBase, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrChegadaBase, 112) as DtChegadaBase, CONVERT(VarChar(19), DtHrChegadaBase, 108) as HrChegadaBase, "
	cQuery += "		   CodSupervisorSync as CodSup"	
	cQuery += " FROM FULL_ORDEM "
	cQuery += " WHERE OrdemServicoSync = " + Alltrim(Str(nCodOs))
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"

	TcQuery cQuery new alias ALT

	TCSetField ("ALT", "DtSaida", 			"D")
	TCSetField ("ALT", "DtInicioPonto", 	"D")
	TCSetField ("ALT", "DtTerminaPonto", 	"D")
	TCSetField ("ALT", "DtInicioServico", 	"D")
	TCSetField ("ALT", "DtTerminoServico", "D")
	TCSetField ("ALT", "DtSaidaBase", 		"D")
	TCSetField ("ALT", "DtChegadaBase", 	"D")
	TCSetField ("ALT", "DtChegada", 			"D")

	If ALT->(!EoF())
	
		dbSelectArea("ZZO")
	
		dbSelectArea("Z10")
		Z10->(dbSetOrder(2))
	
		If !Z10->(MsSeek( xFilial("Z10") + Alltrim(ALT->CodTipoOSSync) ))
			Alert("Erro ao importar cód: " + Alltrim(ALT->Numero) + " Tipo de OS não encontrada!")
		Return
		Endif
	
		RecLock("ZZO", .T.)
		ZZO->ZZO_FILIAL  := xFilial("ZZO")
		ZZO->ZZO_CODSYNC := nCodOs
		ZZO->ZZO_NUMERO  := ALT->Numero
		ZZO->ZZO_TPOS    := Z10->Z10_COD
		ZZO->ZZO_DESCTP  := Z10->Z10_DESC
		
		ZZO->ZZO_CLIENT  := Left(ALT->CodClienteSync,6)
		ZZO->ZZO_LOJA    := SubStr(ALT->CodClienteSync,7,2)
		
		ZZO->ZZO_DTSAID  := ALT->DtSaida
		ZZO->ZZO_HRSAID  := Transform(Alltrim(ALT->HrSaida),"@R 99:99:99")
		
		ZZO->ZZO_DTINIP  := ALT->DtInicioPonto
		ZZO->ZZO_HRINIP  := Transform(Alltrim(ALT->HrInicioPonto),"@R 99:99:99")
		
		ZZO->ZZO_DTFIMP  := ALT->DtTerminaPonto
		ZZO->ZZO_HRFIMP  := Transform(Alltrim(ALT->HrTerminaPonto),"@R 99:99:99")
		
		ZZO->ZZO_DTINIS  := ALT->DtInicioServico
		ZZO->ZZO_HRINIS  := Transform(Alltrim(ALT->HrInicioServico),"@R 99:99:99")
		
		ZZO->ZZO_DTFIMS  := ALT->DtTerminoServico
		ZZO->ZZO_HRFIMS  := Transform(Alltrim(ALT->HrTerminoServico),"@R 99:99:99")
		
		ZZO->ZZO_DTSAIB  := ALT->DtSaidaBase
		ZZO->ZZO_HRSAIB  := Transform(Alltrim(ALT->HrSaidaBase),"@R 99:99:99")
		
		ZZO->ZZO_DTCHEB  := ALT->DtChegadaBase
		ZZO->ZZO_HRCHEB  := Transform(Alltrim(ALT->HrChegadaBase),"@R 99:99:99")
		
		ZZO->ZZO_DTCHEG  := ALT->DtChegada
		ZZO->ZZO_HRCHEG  := Transform(Alltrim(ALT->HrChegada),"@R 99:99:99")
		
		ZZO->ZZO_CODSUP := ALT->CodSup
		
		MsUnLock()
	
		cCadastro := "Alteração de OS's"
	
		AxAltera("ZZO", ZZO->(RecNo()), 3)
	
		_cQry := " UPDATE FULL_ORDEM "
		_cQry += " SET CodTipoOSSync = '" + ZZO->ZZO_DESCTP + "'"
		_cQry += "   , Numero = '"+ZZO->ZZO_NUMERO+"' "
		_cQry += "   , CodClienteSync = '"+ZZO->ZZO_CLIENT+ZZO->ZZO_LOJA+"' "
		_cQry += "   , DtHrSaida = '" + Alltrim(Str(Year(ZZO->ZZO_DTSAID))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTSAID))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTSAID))) + " " + Transform(Alltrim(ZZO->ZZO_HRSAID),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrInicioPonto = '" + Alltrim(Str(Year(ZZO->ZZO_DTINIP))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTINIP))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTINIP))) + " " + Transform(Alltrim(ZZO->ZZO_HRINIP),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrTerminaPonto = '" + Alltrim(Str(Year(ZZO->ZZO_DTFIMP))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTFIMP))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTFIMP))) + " " + Transform(Alltrim(ZZO->ZZO_HRFIMP),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrInicioServ = '" + Alltrim(Str(Year(ZZO->ZZO_DTINIS))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTINIS))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTINIS))) + " " + Transform(Alltrim(ZZO->ZZO_HRINIS),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrTerminoServ = '" + Alltrim(Str(Year(ZZO->ZZO_DTFIMS))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTFIMS))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTFIMS))) + " " + Transform(Alltrim(ZZO->ZZO_HRFIMS),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrSaidaBase = '" + Alltrim(Str(Year(ZZO->ZZO_DTSAIB))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTSAIB))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTSAIB))) + " " + Transform(Alltrim(ZZO->ZZO_HRSAIB),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrChegadaBase = '" + Alltrim(Str(Year(ZZO->ZZO_DTCHEB))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTCHEB))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTCHEB))) + " " + Transform(Alltrim(ZZO->ZZO_HRCHEB),"@R 99:99:99") + ".000'"
		_cQry += "   , DtHrChegada = '" + Alltrim(Str(Year(ZZO->ZZO_DTCHEG))) + "-" + Alltrim(Str(Month(ZZO->ZZO_DTCHEG))) + "-" + Alltrim(Str(Day(ZZO->ZZO_DTCHEG))) + " " + Transform(Alltrim(ZZO->ZZO_HRCHEG),"@R 99:99:99") + ".000'"
		_cQry += "	 , CodSupervisorSync = '"+ZZO->ZZO_CODSUP+"' "
		_cQry += " WHERE OrdemServicoSync = " + Alltrim(Str(nCodOs))
		_cQry += " AND Empresa = '"+SM0->M0_CODIGO+"'"
	
		TcSQLExec(_cQry)
	
		If ZZO->(MsSeek( xFilial("ZZO") + Alltrim(Str(nCodOs)) ))
		
			While ZZO->(!EoF()) .AND. ZZO->ZZO_CODSYNC == nCodOs
		
				RecLock("ZZO", .F.)
				dbDelete()
				MsUnLock()
			
				ZZO->(dbSkip())
			Enddo
	
		Endif
	
		TcSQLExec("DELETE FROM "+RetSqlName("ZZO")+" WHERE D_E_L_E_T_ = '*' ")
	
		ALT->(dbCloseArea())

	Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _altOs   ³ Autor ³ Felipe S. Raota       ³ Data ³ 26/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteração dos dados Importados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MARKCOD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _excOs(nCodOs)

	If MsgYesNo("Deseja realmente excluir?")

		_cQry := " UPDATE FULL_ORDEM "
		_cQry += " SET Importado = 1"
		_cQry += " WHERE OrdemServicoSync = " + Alltrim(Str(nCodOs))
		_cQry += " AND Empresa = '"+SM0->M0_CODIGO+"'"
	
		TcSQLExec(_cQry)

	Endif

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TROCA    ³ Autor ³ Felipe S. Raota       ³ Data ³ 17.09.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de troca                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MARKCOD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Troca(nIt, aArray)

	aArray[nIt, 1]:= !aArray[nIt, 1]

Return(aArray)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _VisualOS  Autor ³ Felipe S. Raota       ³ Data ³ 03.10.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza OS selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901TEC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _VisualOS(cCod)

	Local oQual
	Local oDlg
	Local cAlias  := Alias()
	Local nX	     := 0
	Local cVar    := "  "
	Local nOpca   := 0
	Local aItem  := {}
	Local aAux    := {}
	Local cCad    := "Itens da Ordem de Serviço"
	Local lCont   := .T.
	Local cQuery  := ""
	Local nOpc := 0

	cQuery := " SELECT OrdemServicoItemSync as CodItemSync, ItemSync, QtdVistoriada, QtdRealizada,
	cQuery += "  	   CONVERT(VarChar(10), DtHrVistoria, 112) as DtVistoria, CONVERT(VarChar(19), DtHrVistoria, 108) as HrVistoria, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrRealida, 112) as DtRealida, CONVERT(VarChar(19), DtHrRealida, 108) as HrRealida "
	cQuery += " FROM FULL_ORDEMITEM "
	cQuery += " WHERE OrdemServicoSync = "+Alltrim(Str(cCod))+" "
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"

	TcQuery cQuery new alias ITEM

	TCSetField ("ITEM", "DtVistoria", "D")
	TCSetField ("ITEM", "DtRealida", "D")

	While !ITEM->(EoF())
		_cDesc := fBuscaCpo("SB1", 1, xFilial("SB1") + Alltrim(ITEM->ItemSync), "B1_DESC")
		AADD( aItem, { ITEM->CodItemSync, Alltrim(ITEM->ItemSync), Alltrim(_cDesc), ITEM->QtdVistoriada, ITEM->QtdRealizada, ITEM->DtVistoria, Alltrim(ITEM->HrVistoria),;
			ITEM->DtRealida, Alltrim(ITEM->HrRealida)})
		ITEM->(dbSkip())
	Enddo

	ITEM->(dbCloseArea())

	If Len(aItem) > 0
	
		DEFINE MSDIALOG oDlg TITLE cCad From 5,0 To 33,93 OF oMainWnd
	
		@0.4, 0.3 TO 14.8, 41.1 LABEL cCad OF oDlg
	
		@1.0, .7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi("Cód. Item"), OemToAnsi("Produto"), OemToAnsi("Descrição"), OemToAnsi("Qtd. Vistoriada"), OemToAnsi("Qtd. Realizada"), OemToAnsi("Dt. Vistoria"),;
			OemToAnsi("Hr. Vistoria"), OemToAnsi("Dt. Realizada"), OemToAnsi("Hr. Realizada") SIZE 320,190 ON DBLCLICK (_AltQtd(cCod,aItem,@oQual), oQual:Refresh()) //NOSCROLL
		oQual:SetArray(aItem)
		oQual:bLine := { || { aItem[oQual:nAt, 1], aItem[oQual:nAt, 2], aItem[oQual:nAt, 3], aItem[oQual:nAt, 4], aItem[oQual:nAt, 5], aItem[oQual:nAt, 6],;
			aItem[oQual:nAt, 7], aItem[oQual:nAt, 8], aItem[oQual:nAt, 9] } }
	
		oButton:=tButton():New( 10.9,332,'    Fechar    ',oDlg,{ || oDlg:End() },35,11,,,,.T. )
	
		ACTIVATE MSDIALOG oDlg
	
	Else
		Alert("Nenhum item encontrado.")
	Endif

Return

Static Function _AltQtd(cCod,aItem,oQual)
Local nLin := oQual:nAt
Local nQtd := aItem[nLin,5]
Local oDlg := NIL
Local oGet := NIL
Local cQuery := ''
Local _cDesc := ''

DEFINE MSDIALOG oDlg TITLE "Altera Qtd. Realizada" From 5,0 To 100,228 PIXEL OF oMainWnd
@ 005,010 Say "Quantidade"  Size 053,008 PIXEL OF oDlg
@ 005,065 MsGet oGet Var nQTd   Size 050,009 PICTURE "@E 999,999.99"  PIXEL OF oDlg
@ 020,065 Button "Ok"  Size 040,016 PIXEL OF oDlg Action (oDlg:End())
ACTIVATE MSDIALOG oDlg centered

cQuery := " UPDATE FULL_ORDEMITEM SET QtdRealizada = "+cvaltochar(nQtd)
cQuery += " WHERE OrdemServicoSync = "+Alltrim(Str(cCod))
cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"
cQuery += " AND OrdemServicoItemSync = "+cvaltochar(aItem[nLin,1])

If TcSqlExec(cQuery) < 0
	MsgInfo("Problemas na atualização do item."+Chr(13)+Chr(10)+TcSqlError())
Else
	cQuery := " SELECT OrdemServicoItemSync as CodItemSync, ItemSync, QtdVistoriada, QtdRealizada,
	cQuery += "  	   CONVERT(VarChar(10), DtHrVistoria, 112) as DtVistoria, CONVERT(VarChar(19), DtHrVistoria, 108) as HrVistoria, "
	cQuery += "  	   CONVERT(VarChar(10), DtHrRealida, 112) as DtRealida, CONVERT(VarChar(19), DtHrRealida, 108) as HrRealida "
	cQuery += " FROM FULL_ORDEMITEM "
	cQuery += " WHERE OrdemServicoSync = "+Alltrim(Str(cCod))+" "
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"

	TcQuery cQuery new alias ITEM

	TCSetField ("ITEM", "DtVistoria", "D")
	TCSetField ("ITEM", "DtRealida", "D")
	aItem := {}
	
	While !ITEM->(EoF())
		_cDesc := fBuscaCpo("SB1", 1, xFilial("SB1") + Alltrim(ITEM->ItemSync), "B1_DESC")
		AADD( aItem, { ITEM->CodItemSync, Alltrim(ITEM->ItemSync), Alltrim(_cDesc), ITEM->QtdVistoriada, ITEM->QtdRealizada, ITEM->DtVistoria,;
			 Alltrim(ITEM->HrVistoria),ITEM->DtRealida, Alltrim(ITEM->HrRealida)})
		ITEM->(dbSkip())
	Enddo
	IF len(aItem) > 0
		oQual:SetArray(aItem)
		oQual:bLine := { || { aItem[oQual:nAt, 1], aItem[oQual:nAt, 2], aItem[oQual:nAt, 3], aItem[oQual:nAt, 4], aItem[oQual:nAt, 5], aItem[oQual:nAt, 6],;
			aItem[oQual:nAt, 7], aItem[oQual:nAt, 8], aItem[oQual:nAt, 9] } }
	Endif

	ITEM->(dbCloseArea())
Endif 


Return aItem

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ _ImpCheck  Autor ³ Felipe S. Raota       ³ Data ³ 03.10.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importação dos itens selecionados do CheckList.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB901TEC                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ImpCheck(cCod, cSeq, cTipo, nCodSync)

	cQuery := " SELECT * "
	cQuery += " FROM FULL_ORDEMCHECKLIST "
	cQuery += " WHERE CodOrdemServicoSync = " + Alltrim(Str(nCodSync))
	cQuery += " AND Empresa = '"+SM0->M0_CODIGO+"'"

	TcQuery cQuery new alias CHK

	dbSelectArea("ZZN")

	While CHK->(!EoF())
	
		RecLock("ZZN", .T.)
		ZZN->ZZN_CODOS  := cCod
		ZZN->ZZN_SEQ    := cSeq
		ZZN->ZZN_ITEMCH := Right(Alltrim(CHK->CodChecklistSync),2)
		ZZN->ZZN_TIPO   := cTipo
		MsUnLock()
	
		CHK->(dbSkip())
	Enddo

	CHK->(dbCloseArea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetZZ4    ³ Autor ³ Felipe S. Raota              Data ³ 19/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca o Grupo PPR pela Equipe na tabela ZZ4.                      ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ |STCA014                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetZZ4(cEqp)

Local aArea := GetArea()
Local cGrp := ""

dbSelectArea("ZZ4")
ZZ4->(dbSetOrder(1))

If ZZ4->(MsSeek( xFilial("ZZ4") + cEqp ))
	cGrp := ZZ4->ZZ4_GRPPR
Endif

restArea(aArea)

Return cGrp

Static Function _ValidPerg()

	Local _aArea  := GetArea()
	Local _aRegs  := {}
	Local _aHelps := {}
	Local _i      := 0
	Local _j      := 0

// Definicao dos parametros a serem solicitados para o relatorio
	_aRegs := {} // Get/Choose

//            Grupo/Ordem/Pergunta                 /Perspa/Pereng/Variável/Tipo/Tamanho/Dec/Presel/GSC/Valid/Var01     /Def01/       Defspa1/Defeng1/Cnt01/Var02/Def02/           Defspa2/Defeng2/Cnt02/Var03/Def03/  Defspa3/Defeng3/Cnt03/Var04/Def04/Defspa4/Defeng4/Cnt4/Var05/Def05/Defspa5/Defeng5/Cnt05/F3/GRPSXG
	aAdd(_aRegs, {cPerg,"01","Tipo                ?",  "",    "",    "MV_CH1","C", 01,     0,  0,     "C","",   "MV_PAR01","Vistoria",   "",     "",     "",   "",   "Apontamento",   "",     "",     "",   "",   "O.S.", "",	   "",     "",   "",   "Ambos",  "",     "",     "",  "",   "Já Importados",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"02","Nome de             ?",  "",    "",    "MV_CH2","C", 40,     0,  0,     "G","",   "MV_PAR02","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "SA1N2",   ""})
	aAdd(_aRegs, {cPerg,"03","Nome até            ?",  "",    "",    "MV_CH3","C", 40,     0,  0,     "G","",   "MV_PAR03","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "SA1N2",   ""})
	aAdd(_aRegs, {cPerg,"04","Cód. Importação de  ?",  "",    "",    "MV_CH4","N", 06,     0,  0,     "G","",   "MV_PAR04","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"05","Cód. Importação até ?",  "",    "",    "MV_CH5","N", 06,     0,  0,     "G","",   "MV_PAR05","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"06","Nr. Obra de         ?",  "",    "",    "MV_CH6","C", 30,     0,  0,     "G","",   "MV_PAR06","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"07","Nr. Obra até        ?",  "",    "",    "MV_CH7","C", 30,     0,  0,     "G","",   "MV_PAR07","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"08","Cliente de          ?",  "",    "",    "MV_CH8","C", 06,     0,  0,     "G","",   "MV_PAR08","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "SA1",   	""})
	aAdd(_aRegs, {cPerg,"09","Loja de             ?",  "",    "",    "MV_CH9","C", 02,     0,  0,     "G","",   "MV_PAR09","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"10","Cliente até         ?",  "",    "",    "MV_CHA","C", 06,     0,  0,     "G","",   "MV_PAR10","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "SA1",   	""})
	aAdd(_aRegs, {cPerg,"11","Loja até            ?",  "",    "",    "MV_CHB","C", 02,     0,  0,     "G","",   "MV_PAR11","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"12","Técnico de          ?",  "",    "",    "MV_CHC","C", 06,     0,  0,     "G","",   "MV_PAR12","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"13","Técnico até         ?",  "",    "",    "MV_CHD","C", 06,     0,  0,     "G","",   "MV_PAR13","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"14","Data chegada de     ?",  "",    "",    "MV_CHE","D", 08,     0,  0,     "G","",   "MV_PAR14","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"15","Data chegada até    ?",  "",    "",    "MV_CHF","D", 08,     0,  0,     "G","",   "MV_PAR15","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "",   		""})
	aAdd(_aRegs, {cPerg,"16","Equipe de           ?",  "",    "",    "MV_CHG","C", 06,     0,  0,     "G","",   "MV_PAR16","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "AA1ZZ4",  ""})
	aAdd(_aRegs, {cPerg,"17","Equipe até          ?",  "",    "",    "MV_CHH","C", 06,     0,  0,     "G","",   "MV_PAR17","",           "",     "",     "",   "",   "",              "",     "",     "",   "",   "",     "",     "",     "",   "",   "",       "",     "",     "",  "",   "",   "",     "",     "",   "AA1ZZ4",  ""})

//aAdd(_aRegs, {cPerg,"10","Endereço?  ",              "",    "",    "MV_CHA","C", 15,     0,  0,     "G","",   "MV_PAR10","",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "",   "",   "",     "",     "",   "SBE",""})

// Definicao de textos de help dos parametros (versao 7.10 em diante): um array para cada linha.
	_aHelps := {}

//            Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890

/*
	dbSelectArea("SX1")
	dbSetOrder(1)

	For _i := 1 to len(_aRegs)
		If !dbSeek(cPerg + _aRegs[_i, 2])  // _i = ocorrencia do array  2 = segundo campo dentro daquela ocorrencia, no caso, a "ordem"
			RecLock("SX1", .T.) // lock na tab para INSERT de registro (.T.)
		Else
			RecLock("SX1", .F.) // lock na tab para UPDATE de registro (.F.)
		Endif
	
		For _j := 1 to FCount() // fcount()=nro. de campos dos regs. desta tabela (sx1)
		// Campos CNT nao sao gravados para preservar conteudo anterior.
			If _j <= len(_aRegs[_i]) .and. left(fieldname(_j), 6) != "X1_CNT" .and. fieldname(_j) != "X1_PRESEL"
				FieldPut(_j, _aRegs[_i, _j])
			Endif
		Next
	
		MsUnlock()   // libera lock
	Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
	dbSeek(cPerg, .T.)
	While !EOF() .and. x1_grupo == cPerg
		If aScan(_aRegs, {|_aVal| _aVal[2] == sx1->x1_ordem}) == 0
			RecLock("SX1", .F.)
			dbDelete()
			MsUnlock()
		Endif
		dbSkip()
	Enddo

// Gera helps das perguntas
	For _i := 1 to Len(_aHelps)
		PutSX1Help("P." + cPerg + _aHelps[_i, 1] + ".", _aHelps[_i, 2], {}, {})
	Next
	*/

	RestArea(_aArea)

Return


//Verificando tipo = funcionalidade Type nao funciona em Loop
Static Function xTipe(_cVal)

Local _lRet := .F.

If Type(_cVal) == "A"
	_lRet := .T.
EndIf


Return(_lRet)
