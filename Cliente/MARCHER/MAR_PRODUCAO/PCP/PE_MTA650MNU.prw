#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAB Chr(9)
#DEFINE CHIFEN Replicate("-", 45)

/*/{Protheus.doc} MTA650MNU
Função que irá incluir novas opções no menu da rotina de "Produção de OP".
@type User Function
@version 
@author Jorge Alberto - Solutio
@since 02/06/2020
@return array, Array com as novas opções
/*/
User Function MTA650MNU()

    AADD( aRotina, {'Reenvia OP Senai','U_MASendOPSenai()', 0, 7 } )

Return( aRotina )


/*/{Protheus.doc} MASendOPSenai
Função que irá montar uma tela com as OP's ainda não enviadas para a tabela de integração SKA ( Senai ).
@type User Function
@version 
@author Jorge Alberto - Solutio
@since 02/06/2020
@return NIL
/*/
User Function MASendOPSenai()

    Local aAreaSC2  := SC2->( GetArea() )
    Local aPosObj   := {}
    Local aSel      := {}
    Local aDados    := {}
    Local aHeadCols := { " ", "OP", "Item", "Sequencia", "Produto", "Descrição", "Tempo", "Emissão", "Saldo", "Recurso", "Hora Inicio", "Hora Fim" }
    Local aSize     := MsAdvSize()
    Local cDtCorte	:= AllTrim( SuperGetMV("ES_OP2SKA",,"20200401") )
    Local cAliAtu   := Alias()
    Local cTitAlert := "Integração Marcher x Senai"
    Local cQuery    := ""
    Local cAliReg   := GetNextAlias()
    Local lProc     := .F.
    Local nSel		:= 0
    Local oOK       := LoadBitmap( GetResources(), 'LBOK' )
	Local oNO       := LoadBitmap( GetResources(), 'LBNO' )
    Local oDlg
    Local oSize
    Local oBrowse

    cQuery += "SELECT IMP.OP, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_PRODUTO, SB1.B1_DESC, SB1.B1_TEMPO, SC2.C2_EMISSAO "
    cQuery +=      ", SC2.C2_QUANT-SC2.C2_QUJE AS SALDO, SC2.R_E_C_N_O_ AS RECSC2, SC2.C2_RECURSO, SC2.C2_HORAJI, SC2.C2_HORAJF "
    cQuery +=   "FROM " + RetSqlName("SC2") + " SC2 WITH (NOLOCK) "
    cQuery +=   "INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON ( SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' ) "
    cQuery +=   "LEFT OUTER JOIN SSPIMPORT IMP WITH (NOLOCK) ON ( SC2.C2_NUM = IMP.OP AND SC2.C2_PRODUTO = IMP.CODPECA ) "
    cQuery +=  "WHERE SC2.D_E_L_E_T_ = ' ' "
    cQuery +=    "AND SC2.C2_TPOP = 'F' "            // OP Firme
    cQuery +=    "AND SC2.C2_ICODIGO = ' ' "         // Sem o Codigo de Integração
    cQuery +=    "AND SC2.C2_QUJE < SC2.C2_QUANT "   // OP com Saldo
    cQuery +=    "AND SC2.C2_EMISSAO >= '" + cDtCorte + "' " // Data de corte
    cQuery +=    "AND IMP.OP IS NULL  "              // Somente retorna as OP's que não estão na tabela SSPIMPORT
    cQuery +=  "ORDER BY SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN "

    //MEMOWRIT( "c:\temp\MASendOPSenai.sql", cQuery )

    DbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAliReg, .F., .T. )
    TcSetField( (cAliReg), "C2_EMISSAO", "D", 8, 0 )

    If (cAliReg)->( EOF() )
        MSGINFO( "Não foram localizados registros para o reenvio", cTitAlert )
    Else

        Define MsDialog oDlg Title "SELECIONE AS OP's PARA ENVIO" From aSize[1],aSize[2] To aSize[1]+450,aSize[2]+1097 Pixel

        oSize := FwDefSize():New(.F.,,,oDlg)

        oSize:AddObject('GRID'  ,100,100,.T.,.T.)
        oSize:AddObject('FOOT'  ,100,20 ,.T.,.F.)

        oSize:aMargins 	:= { 3, 3, 3, 3 }
        oSize:Process()

        aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'XSIZE')-15,oSize:GetDimension('GRID'  , 'YSIZE')})
        aAdd(aPosObj,{oSize:GetDimension('FOOT'  , 'LININI'),oSize:GetDimension('FOOT'  , 'COLINI'),oSize:GetDimension('FOOT'  , 'LINEND'),oSize:GetDimension('FOOT'  , 'COLEND')})

        oBrowse := TCBrowse():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],,aHeadCols,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
        
        While (cAliReg)->( !EOF() )
            AADD( aDados, { .F., (cAliReg)->C2_NUM, (cAliReg)->C2_ITEM, (cAliReg)->C2_SEQUEN, (cAliReg)->C2_PRODUTO, AllTrim((cAliReg)->B1_DESC), (cAliReg)->B1_TEMPO, DtoC((cAliReg)->C2_EMISSAO), (cAliReg)->SALDO, (cAliReg)->C2_RECURSO, (cAliReg)->C2_HORAJI, (cAliReg)->C2_HORAJF, (cAliReg)->RECSC2 } )
            (cAliReg)->( DbSkip() )
        EndDo

        oBrowse:SetArray(aDados)
        oBrowse:bLine := {|| { IIF(aDados[oBrowse:nAT,1],oOK,oNO),aDados[oBrowse:nAT,2],aDados[oBrowse:nAT,3],aDados[oBrowse:nAT,4],aDados[oBrowse:nAT,5],aDados[oBrowse:nAT,6],aDados[oBrowse:nAT,7],aDados[oBrowse:nAT,8],aDados[oBrowse:nAT,9],aDados[oBrowse:nAT,10],aDados[oBrowse:nAT,11],aDados[oBrowse:nAT,12],aDados[oBrowse:nAT,13] } }
        oBrowse:bLDblClick := {|| MarcaOP( oBrowse, oBrowse:nAt ) }
        oBrowse:Refresh()

        //TButton():New(aPosObj[2][1],aPosObj[2][2]    ,"Inverte Sel.",oDlg,{|| aEval(@oBrowse:aArray,{|x| x[1] := !x[1]}),oBrowse:Refresh() },50,11,,,.F.,.T.,.F.,,.F.,,,.F.)
        TButton():New(aPosObj[2][1],aPosObj[2][2]+180,"Confirmar"   ,oDlg,{|| aSel := aClone(oBrowse:aArray), lProc := .T., oDlg:End() }    ,45,11,,,.F.,.T.,.F.,,.F.,,,.F.)
        TButton():New(aPosObj[2][1],aPosObj[2][2]+340,"Voltar"      ,oDlg,{|| oDlg:End() }                                                  ,40,11,,,.F.,.T.,.F.,,.F.,,,.F.)

        Activate MsDialog oDlg Centered

        If lProc
            
            For nSel := 1 To Len( aSel )

                //Se estiver marcado e com os campos de Recurso e Data Inicial informados !!
                If ( aSel[ nSel, 1 ] .And. !Empty( aSel[ nSel, 10 ] ) .And. !Empty( aSel[ nSel, 11 ] ))
                    
                    DbSelectArea("SC2")
                    DbGoTo( aSel[ nSel, 13 ] )
                    If SC2->C2_ENSENAI <> "S"
                        RecLock( "SC2", .F. )
                            SC2->C2_ENSENAI := "S"
                            SC2->C2_RECURSO := aSel[ nSel, 10 ]
                            SC2->C2_HORAJI  := aSel[ nSel, 11 ]
                            SC2->C2_HORAJF  := aSel[ nSel, 12 ]
                        MsUnLock()
                    EndIf

                    // Chama o PE_MTA650I.prw para o envio dos dados para a tabela SSPIMPORT
                    U_MTA650I()
                    
                EndIf

            Next
            
        EndIf

    EndIf

    (cAliReg)->( DbCloseArea() )

    If !Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf
    RestArea( aAreaSC2 )

Return


/*/{Protheus.doc} MarcaOP
Ao marcar a linha irá solicitar o Recurso e a Hora Inicial, com isso irá calcular a Hora Final.
@type function
@version 
@author Jorge Alberto - Solutio
@since 03/08/2020
@param oBrowse, object, Objeto do Browse
@param nLin, numeric, Linha marcada pelo usuário
/*/
Static Function MarcaOP( oBrowse, nLin )

    Local aParamBox := {}
    Local aRet := {}

    // Se já tem o Recurso e Hora informado, marca a linha
    If !Empty( oBrowse:aArray[ nLin, 10 ] ) .And. !Empty( oBrowse:aArray[ nLin, 11 ])
        oBrowse:aArray[ nLin, 01 ] := !oBrowse:aArray[ nLin, 1 ]

        // Se desmarcou então limpa os dados informados em tela.
        If !oBrowse:aArray[ nLin, 01 ]
            oBrowse:aArray[ nLin, 10 ] := Space(6) // Recurso
            oBrowse:aArray[ nLin, 11 ] := Space(5) // Hora Inicial
            oBrowse:aArray[ nLin, 12 ] := Space(5) // Hora Final
        EndIf
    Else
        aAdd(aParamBox,{1,"Recurso "     ,oBrowse:aArray[ nLin, 10 ],""     ,"","SH1","",0,.T.})
        aAdd(aParamBox,{1,"Hora Inicial ",oBrowse:aArray[ nLin, 11 ],"99:99","",""   ,"",0,.T.})
        
        If ParamBox( aParamBox, "Informações pra envio da OP", @aRet )

            If Empty( Posicione( "SH1", 1, FWxFilial("SH1")+aRet[1], "H1_CODIGO" ) )
                MsgAlert( "Recurso informado " + aRet[1] + " não foi localizado no Cadastro de Recursos" )
            ElseIf ( Len( AllTrim( aRet[2] ) ) <> 4 .And. Len( AllTrim( aRet[2] ) ) <> 5 )
                MsgAlert( "Formato da Hora inválido !")
            Else
                oBrowse:aArray[ nLin, 01 ] := !oBrowse:aArray[ nLin, 1 ]
                oBrowse:aArray[ nLin, 10 ] := aRet[1] // Recurso
                oBrowse:aArray[ nLin, 11 ] := aRet[2] // Hora Inicial
                oBrowse:aArray[ nLin, 12 ] := MchHoras( aRet[2]/*Hora Inicial*/, oBrowse:aArray[ nLin, 9 ]/*nQuant*/, oBrowse:aArray[ nLin, 7 ]/*nTempo*/ ) // Hora Final
            EndIf
        EndIf
    EndIf

Return

/*/{Protheus.doc} MchCalHr
Função chamada dos gatilhos dos campos: C2_HORAJI, C2_QUANT e C2_RESURSO.
Usada para calcular a Data e Hora final de produção da OP com limite diário conforme o turno informado no Recurso.
@type function
@author Jorge Alberto - Solutio
@since 23/10/2020
/*/
User Function MchCalHr()

    Local dDataFim      := M->C2_DATPRI
    Local aDtHrFim      := Array( 2 )
    Local lMudaData     := .T.
    Local nQtd          := 0
    Local nQuant        := M->C2_QUANT
    Local nTmpProd      := Posicione( "SB1", 1, xFilial("SB1") + M->C2_PRODUTO, "B1_TEMPO" )
    Local cHoraIni      := M->C2_HORAJI
    Local cTempoFinal   := cHoraIni
    Local cHoraLimite   := "17:30"
    Local cLog          := ""
    Local cArq          := ""
    Local cTurno        := ""

    Begin Sequence 

        If ( Empty( dDataFim ) .Or. nQuant <= 1 .Or. Empty( M->C2_RECURSO ) .Or. Empty( cHoraIni ) )
            Break
        EndIf
        
        aDtHrFim := MchHoras( cHoraIni, nQuant, nTmpProd )
        cTempoFinal := aDtHrFim[2]

        cTurno := Posicione( "SH1", 1, xFilial("SH1") + M->C2_RECURSO, "H1_TURNO" )

        If cTurno == "D" // Inicio as 07:30 e vai até as 17:30
            cHoraLimite := "17:30"

            If cHoraIni < "07:30"
                MsgAlert( "Hora inicial não pode ser inferior as 07:30" )
                Break
            EndIf

        ElseIf cTurno == "N" // Inicio as 22:30 e vai até as 07:30
            cHoraLimite := "07:30"

            If cHoraIni < "22:30"
                MsgAlert( "Hora inicial não pode ser inferior as 22:30" )
                Break
            EndIf
        Else
            cHoraLimite := "17:30"
            // Intervalo entre os turnos é das 17:30 até as 22:30 então nesse horário não pode informar inicio
            If cHoraIni > "17:30" .And. cHoraIni < "22:30"
                MsgAlert( "Intervalo entre os turnos não pode ser informado entre 17:30 e 22:30" )
                Break
            EndIf
        EndIf
        // Se a hora ultrapassou o limite de horas do dia, então calcula o Dia e Hora final correto
        If( ( cTempoFinal >= cHoraLimite .Or. M->C2_DATPRI <> aDtHrFim[1] ) .And. nQuant > 1 )

            cLog += "Tempo de " + cValToChar( nTmpProd ) + " minutos para a Produção do produto " + AllTrim( M->C2_PRODUTO) + CRLF
            cLog += "Turno de Trabalho " 
            
            If cTurno=="D"
                cLog += "Dia ( 07:30 -> " + cHoraLimite + " )" +CRLF
            
            ElseIf cTurno == "N"
                cLog += "Noite ( 22:30 -> " + cHoraLimite + " )" +CRLF
            
            Else
                cLog += "Noite e Dia  ( 22:30 -> " + cHoraLimite + " )" +CRLF
            EndIf

            cLog += "Hora de início informado " + cHoraIni +CRLF
            cLog += "Hora limite " + cHoraLimite +CRLF
            cLog += "Quantidade produzida " + cValToChar( nQuant ) +CRLF
            cLog += "Peça " + TAB + "Data " + TAB+TAB + "Hr Inicio " + TAB + "Hr Fim" + CRLF

            For nQtd := 1 To nQuant

                aDtHrFim := MchHoras( cHoraIni, 1 /*nQuant*/, nTmpProd )
                cTempoFinal := aDtHrFim[2]

                // Somo a Data Final quando ultrapassar o limite de horas do dia
                If cTurno == "D" // Inicio as 07:30 e vai até as 17:30
                    
                    If cTempoFinal > cHoraLimite 
                        dDataFim := dDataFim + 1
                        cHoraIni := "07:30" // M->C2_HORAJI
                        aDtHrFim := MchHoras( cHoraIni, 1 /*nQuant*/, nTmpProd )
                        cTempoFinal := aDtHrFim[2]
                        cLog += CHIFEN + CRLF
                    EndIf
                
                ElseIf cTurno == "N" // Inicio as 22:30 e vai até as 07:30
                    
                    If cTempoFinal >= M->C2_HORAJI .And. cTempoFinal <= "23:59"
                        // Dentro do mesmo dia
                    
                    ElseIf lMudaData .And. cTempoFinal >= "00:00" .And. cTempoFinal <= cHoraLimite
                        // Outro dia porém dentro do limite
                        dDataFim := dDataFim + 1
                        lMudaData := .F.
                        cLog += CHIFEN + CRLF

                    ElseIf cTempoFinal >= cHoraLimite
                        // Passou do horário limite do dia
                        cHoraIni := "22:30" // M->C2_HORAJI
                        aDtHrFim := MchHoras( cHoraIni, 1 /*nQuant*/, nTmpProd )
                        cTempoFinal := aDtHrFim[2]
                        lMudaData := .T.
                    EndIf

                Else // cTurno == "A"

                    // Ambos os turnos que inicia as 22:30 e vai até as 17:30
                    
                    If cTempoFinal >= M->C2_HORAJI .And. cTempoFinal <= "23:59" .And. cTempoFinal <= cHoraLimite
                        // Dentro do mesmo dia

                    ElseIf lMudaData .And. cTempoFinal >= "00:00" .And. cTempoFinal <= cHoraLimite
                        // Outro dia porém dentro do limite
                        dDataFim := dDataFim + 1
                        lMudaData := .F.
                        cLog += CHIFEN + CRLF

                    ElseIf cTempoFinal >= cHoraLimite
                        // Passou do horário limite do dia
                        cHoraIni := "22:30" // M->C2_HORAJI
                        aDtHrFim := MchHoras( cHoraIni, 1 /*nQuant*/, nTmpProd )
                        cTempoFinal := aDtHrFim[2]
                        lMudaData := .T.
                    EndIf

                EndIf

                cLog += AllTrim( PadL( cValToChar(nQtd), 3, "0" ) ) + TAB + DtoC( dDataFim ) + TAB + cHoraIni + TAB+TAB + cTempoFinal + CRLF
                cHoraIni := cTempoFinal

            Next

            If SuperGetMV("ES_LOGTMOP",,.T.)
                cArq := AllTrim( GetTempPath() ) + "OP_" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "_" + DtoS(dDataBase)+"_"+Replace(Time(),":","")+ ".txt"
                MemoWrit( cArq, cLog )
                ShellExecute ( "open", cArq, "/open", "", 1 )
            EndIf
        Else
            If cTurno == "N"
                //If ! (cTempoFinal >= cHoraIni .And. cTempoFinal <= "23:59")
                If cTempoFinal >= "00:00" .And. cTempoFinal <= cHoraLimite
                    dDataFim := dDataFim + 1
                EndIf
            EndIf
        EndIf

        M->C2_DATPRF := dDataFim

    End Sequence

Return( cTempoFinal )


/*/{Protheus.doc} MchHoras
Função que pega os tempos e quantidades e transforma em Horas.
@type function
@version 
@author Jorge Alberto - Solutio
@since 03/08/2020
@param cHoraJI, character, Conteúdo do campo C2_HORAJI ( campo padrão )
@param nQuant, numeric, Conteúdo do campo C2_QUANTO ( campo padrão )
@param nTempo, numeric, Conteúdo do campo B1_TEMPO ( campo customizado )
@return array, Array com o Dia e Hora final calculada.
/*/
Static Function MchHoras( cHoraJI, nQuant, nTempo )

    Local aDtHrFim := Array( 2 )
    Local dData := M->C2_DATPRI
    Local cHora := ""
    Local cMin := ""
    Local nTmpTot := nQuant * nTempo
    Local nPosPonto := 0
    Local c1 := ""

    If Empty( cHoraJI )
        Return( aDtHrFim )
    EndIf
    
    // Funcao padrao Min2Hrs() que transforma Minutos em Horas
    // Funcao padrao SomaHoras() que soma 2 horas diferentes
    c1 := SomaHoras( cHoraJI, Min2Hrs( nTmpTot ) )

    nPosPonto := At( ".", cValToChar( c1 ) )
	If nPosPonto > 0
		// Preencho com Zeros até completar 2 caracteres
		cHora := PadL( SubStr( cValToChar( c1 ), 1, nPosPonto-1 ) , 2, "0" )
		cMin  := PadR( SubStr( cValToChar( c1 ), nPosPonto+1 ) , 2, "0" )
	Else
		// Se não tem o ponto é porque é hora inteira
		cHora := PadL( c1, 2, "0" )
		cMin  := "00"
	EndIf

    If cHora == "24"
        cHora := "00"
        dData := dData + 1
    ElseIf cHora >= "25"
        cHora := PadL( Val( cHora ) - 24, 2, "0" )
        dData := dData + 1
    EndIf

	aDtHrFim[1] := dData
	aDtHrFim[2] := cHora + ":" + cMin

Return( aDtHrFim )
