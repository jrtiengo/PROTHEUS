//{IX} ================================================================================
//{IX} 000019 = user function mdta6954
//{IX} ================================================================================
///*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Funcao    ³ mdta6954 ³ Autor ³ Daniela Maria Uez     ³ Data ³04/08/2010³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descricao ³ PE executado na rotina funcionario x epi como última vali- ³±±
//±±³          ³ dação da alteração da linha do EPI                         ³±±
//±±³          ³                                                            ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Objetivo  ³                                                            ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
///*/
user function mdta6954
	//-------------------------------------------------------
	// Leef - Machado - Janeiro/2021 - chamado 51088
	Local nINDDEV:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_INDDEV"})
	local nFORNEC:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_FORNEC"})
	local nLOJA  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_LOJA"})
	Local nEPI   := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_CODEPI"})
	Local nNumCa := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMCAP"})
	Local nDTENTR:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_DTENTR"})
	Local nHRENTR:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_HRENTR"})
	Local nCodEpi:= aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_CODEPI"})
	Local cMat   := sra->RA_MAT
	Local _n     := n
	Local fn     := 1
	local filtnf := xFilial("TNF")
	local filSB1 := xFilial("SB1")
	local lRet   := .t.
	local mdtarea:=getarea()
	// compara o grid com o que ja está gravado

	if (!FWIsInCallStack("u_XM105PRO"))
		For fn:= 1 To Len(aCols)
			dbSelectArea("TNF")
			dbSetOrder(1) // filial+fornece+loja+codepi+numcap+mat+dtentr+hrentr
			ALVO:=filtnf+aCOLS[fn][nFORNEC]+aCOLS[fn][nLOJA]+aCOLS[fn][nEPI]+aCOLS[fn][nNumCa]+cMat+DtoS(aCOLS[fn][nDTENTR])+aCOLS[fn][nHRENTR]
			dbSeek(ALVO)
			//1=Epi devolvido;2=Epi em uso;3=Solicitacao ao Armazem
			if found()
				if     aCols[fn][nINDDEV]=='1'  // DEVOLVIDO
				elseif aCols[fn][nINDDEV]=='2'  // EM USO
					if tnf->TNF_INDDEV=='1'     // ja havia sido devolvido
						lRet:=.f.
						msgAlert(aCols[fn][nCodEpi]+"-"+posicione("SB1",1,filsb1+aCols[fn][nCodEpi],"B1_DESC"),;
							"Já Devolvido Não Pode voltar para Uso.")
						exit
					endif
				else
					lRet:=.f.
					msgAlert(aCols[fn][nCodEpi]+"-"+posicione("SB1",1,filsb1+aCols[fn][nCodEpi],"B1_DESC"),;
						"Status Invalido !")
					exit
				endif
			else
				alert("Não é permitida inclusão de novas linhas!","# Somente pelo módulo Estoque")
				lRet:=.f.
			endif
		Next
	else
      restarea(mdtarea)
      Return(.T.)
   endif
	
   n:= _n
	restarea(mdtarea)

	// o trecho comentado abaixo já estava comentado em 08/01/2021 - machado
	//-------------------------------------------------------
   /*
   Local _codVer := getMv("ML_VERBEPC")
   Local _codVerDev := getmv("ML_VERBDEV")
   Local _aMot  := {"Admissional", "Desgaste/Mau Uso", "Defeito", "Perda", "Roubo", "Demissional", "Outros"}
   Local _nDiasLim := getmv("ML_DIASLIM")
   Local _n:= n
   nEPI     := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_CODEPI"})
   nFORNEC  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_FORNEC"})
   nLOJA    := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_LOJA"})
   nDev  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_DEV"})
   nSeqD3   := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMSEQ"})
   //nMat   := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_MAT"})
   cMat   := RA_MAT
   nDTENTR := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_DTENTR"})
   nHRENTR  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_HRENTR"})
   nNumSer  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NSERIE"})
   nLocalT  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_LOCAL"})
   nNumCa   := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_NUMCAP"})
   nMotivo  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_MOTIVO"})
   nDTADEV  := aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "TNF_DTDEVO"})
   dbSelectArea("SRK")
   dbsetOrder(5)
   dbSeek(xFilial("SRK")+SRA->RA_MAT+_codVer)
	Do While !SRK->(EOF()) .AND. xFilial("SRK")+SRA->RA_MAT+_codVer == xFilial("SRK")+SRA->RA_MAT+SRK->RK_PD
      RecLock ("SRK",.F.)
      dbDelete()
      MsUnLock()
      SRK->(dbSkip())
	EndDo
	For n:= 1 To Len(aCols)
      dbSelectArea("TNF")
      dbSetOrder(1)
      dbSeek(xFilial("TNF")+aCOLS[n][nFORNEC]+aCOLS[n][nLOJA]+aCOLS[n][nEPI]+aCOLS[n][nNumCa]+cMat+DtoS(aCOLS[n][nDTENTR])+aCOLS[n][nHRENTR])
      // se informou devolução, tem que informar motivo
      //if !empty(aCOLS[n][nDTADEV])
      // if  empty(aCOLS[n][nMotivo])
      //  alert("Informe o motivo da Devolução!")
      //  return .f.
      // endif
      //if !empty(TNF->TNF_MOTIVO)
      // se informou devolução, tem que informar motivo
      // if aCOLS[n][nDev] == "1"
      //  alert("O status de produto devolvido não pode ser 'Em uso'!")
      //  aCOLS[n][nDev] := "2"
      //  return .f.
      // endif
      //endif
      //endif
		if ((aCOLS[n][nMotivo] $ "245" .and. aCOLS[n][nDev] $ "34") .or.;
         (aCOLS[n][nMotivo] $ "36"  .and. aCOLS[n][nDev] $ "4"))
         dbSelectArea("TN3")
         dbSetOrder(1)         // forn loja epi numcap
         dbSeek(xFilial("TN3") + aCOLS[n][nFORNEC] +aCOLS[n][nLOJA] +aCOLS[n][nEPI] + aCOLS[n][nNumCa])
         _numDias := TN3->TN3_DURABI
         //busco a durabilidade da SB1 conforme solicitacao o Renato
         _numDias := fbuscacpo("SB1", 1, xFilial("SB1")+aCOLS[n][nEPI], "B1_PRVALID")
         _nDias := 0
				IF !EMPTY(alltrim(aCOLS[n][nNumSer]))
            // verifica tempo de uso
            _cQuery := " SELECT TNF.TNF_DTDEVO, TNF.TNF_DTENTR " +;
            " FROM " + RetSqlName("TNF") + " TNF " +;
            " WHERE TNF.TNF_FILIAL = '" + xFilial("TNF") + "' AND " +;
            "   TNF.D_E_L_E_T_ = ' ' AND " +;
            "   TNF.TNF_FORNEC = '"  + aCOLS[n][nFORNEC] + "' AND " +;
            "  TNF.TNF_LOJA   = '"  + aCOLS[n][nLOJA]   + "' AND " +;
            "  TNF.TNF_CODEPI = '"  + aCOLS[n][nEPI]   + "' AND " +;
            "   TNF.TNF_NUMCAP = '"  + aCOLS[n][nNumCa]  + "' AND " +;
            "  TNF.TNF_NSERIE = '"   + aCOLS[n][nNumSer] + "' AND " +;
            "  TNF.TNF_NUMSEQ <> '" + aCOLS[n][nSeqD3]  + "' " +;
            " ORDER BY TNF.TNF_CODEPI, TNF.TNF_SERIE "
            _cQuery := changeQuery(_cQuery)
            dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "_TRBTNF", .T., .T.)
            dbSelectArea("_TRBTNF")
            dbgoTop()
				while !_TRBTNF->(EOF())
               _nDias += (iif(empty(_TRBTNF->TNF_DTDEVO), date(), stod(_TRBTNF->TNF_DTDEVO)) - stod(_TRBTNF->TNF_DTENTR))
               _TRBTNF->(DBsKIP())
				enddo
            _TRBTNF->(dbclosearea())
			endif
         _ndias += (aCOLS[n][nDTADEV] - aCOLS[n][nDTENTR]) + 1
         // se a durabilidade for maior do que o número de dias de uso do EPI
			if _numDias > _ndias
            // cálculo do valor a pagar
            dbSelectArea("SB1")
            dbSetOrder(1)
            dbSeek(xFilial("SB1")+aCOLS[n][nEPI])
            // descobre o valor do EPI por dia de vida útil
				if SB1->B1_UPRC > 0
               _nValDia := SB1->B1_UPRC/_numDias
               _nQtdDia := _numDias - _ndias
               _nValEPC := _nValDia*_nQtdDia  //valor total do EPI a ser descontado.
               // se o EPI não for devolvido cobra 50% a mais dos funcionários.
					if aCOLS[n][nDev] == "4"   .or. aCOLS[n][nDev] == "3"
                  _nValEPC := _nValEPC+(SB1->B1_UPRC*50/100)
                  //elseif TNF->TNF_DEV == "4" .and. aCOLS[n][nDev] == "3" //Ezequiel - 25/08/11
                  // _nValEPC := SB1->B1_UPRC*50/100  // se tinha perdido e devolveu depois, só ressarce os 50%
					endif
               //se o valor calculado for maior do que o valor do epc, o lancamento sera limitado ao valor do epc.
               _nValDesc := iif( _nValEPC > SB1->B1_UPRC, SB1->B1_UPRC,_nValEPC)
               dbSelectArea("SRA")
               dbSetOrder(1)
               //dbSeek(xFilial("SRA")+TNF->TNF_MAT)
               dbSeek(xFilial("SRA")+cMat)
					if day(date()) > 16
                  _dTvenc := STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE())+1,2)+"15")
					else
                  _dTvenc := STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE()),2)+"15")
					endif
               _cOBS := ""
               RecLock ("SRK",.T.)
               SRK->RK_FILIAL  := xFilial ("SRK")                  // filial
               SRK->RK_MAT   := SRA->RA_MAT      // Matricula
               SRK->RK_PD    := _codVer        // Codigo da Verba
               SRK->RK_CC      := SRA->RA_CC      // Codigo do CC
               SRK->RK_PARCELA := 1
               SRK->RK_VALORTO := round(_nValDesc,2)    // valor da verba
               SRK->RK_DTVENC  := _dTvenc
               SRK->RK_DTMOVI  := aCOLS[n][nDTADEV]
               //SRK->RK_DOCUMEN := "EC" + STRZERO(MONTH(aCOLS[n][nDTADEV])+1,2)+"15"
               SRK->RK_DOCUMEN := cValToChar(SRK->(Recno()))
               SRK->RK_OBS   := _cOBS + "REF. " + _aMot[val(aCOLS[n][nMotivo])] + " EPI " + SB1->B1_DESC
               MsUnLock()
               //estorno
					If acols[n][ndev]=="3".and.TNF->TNF_DEV=="4"
						If Date() - aCOLS[n][nDTADEV] < _nDiasLim
                     //alert("estorno..............")
                     round(SB1->B1_UPRC*0.5,2)
                     RecLock ("SRK",.T.)
                     SRK->RK_FILIAL  := xFilial ("SRK")                  // filial
                     SRK->RK_MAT   := SRA->RA_MAT      // Matricula
                     SRK->RK_PD    := _codVerDev        // Codigo da Verba
                     SRK->RK_CC      := SRA->RA_CC      // Codigo do CC
                     SRK->RK_PARCELA := 1
                     SRK->RK_VALORTO := round(SB1->B1_UPRC*0.5,2)    // valor da verba
                     SRK->RK_VALORPA := round(SB1->B1_UPRC*0.5,2)    // valor da verba
                     SRK->RK_REGRADS := 1
                     SRK->RK_DTVENC  := _dTvenc
                     SRK->RK_DTMOVI  := aCOLS[n][nDTADEV]
                     //SRK->RK_DOCUMEN := "EC" + STRZERO(MONTH(aCOLS[n][nDTADEV])+1,2)+"15"
                     SRK->RK_DOCUMEN := cValToChar(SRK->(Recno()))
                     SRK->RK_OBS   := _cOBS + "REF. " + _aMot[val(aCOLS[n][nMotivo])] + " EPI " + SB1->B1_DESC
                     MsUnLock()
						EndIf
					EndIf
				else
               alert("O EPI " + alltrim(aCOLS[n][nEPI])+;
               " - " + alltrim(SB1->B1_DESC) + " não possui valor da última compra cadastrado! "+;
               " Não serão incluídos descontos referentes à esse EPI na folha da equipe!",;
               "Valor não cadastrado!")
				endif
			endif
		endif
	Next n
   n:= _n
   */

return lRet
