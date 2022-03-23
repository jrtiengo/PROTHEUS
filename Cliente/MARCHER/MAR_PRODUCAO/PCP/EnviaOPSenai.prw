#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

// Posi��es do array aMyHeader e do objeto oBrwOper
STATIC P_OPERAC  := 1
STATIC P_HORAINI := 2
STATIC P_HORAFIM := 3
STATIC P_RECSKA  := 4
STATIC P_RECURSO := 5
STATIC P_DESCREC := 6
STATIC P_SALDOOP := 7


/*/{Protheus.doc} EnviaOPSenai
Usado para chamar a Procedure SP_SSPIMPORT que ir� incluir registro na tabela de integra��o SSPIMPORT.
Fun��o essa que � chamada dos PE: PE_MTA650I.prw e PE_MTA650A.prw
@type function
@author Jorge Alberto - Solutio
@since 25/05/2020
/*/
User Function EnviaOPSenai()

    Local oDlg
    Local aArea     := GetArea()
    Local aAreaSB1  := SB1->(GetArea())
    Local aOperac   := {}
    Local aMyHeader := {}
    Local nLin      := 0
    Local lConf     := .F.
    Local cAliAtu   := Alias()
    Local cQuery    := ""
    Local cHoraFim  := ""
        
    Private oBrwOper

    // Regras: Usu�rio marcou para Integrar, o Tipo da OP � Firme, com Hora Inicial informada.
    If( SC2->C2_ENSENAI == "S" .And. SC2->C2_TPOP == "F"  .And. !Empty( SC2->C2_HORAJI ) )

        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek( xFilial("SB1") + SC2->C2_PRODUTO )

        If Empty( SC2->C2_ROTEIRO )
            MsgInfo( "N�o foi informado o  Roteiro na OP, por isso n�o foi enviada para integra��o !" )
        Else
            DbSelectArea("SG2")
            DbSetOrder(1)
            If DbSeek( xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO )
                While SG2->( !EOF() ) .And. xFilial("SG2") + SC2->C2_PRODUTO + SC2->C2_ROTEIRO == SG2->G2_FILIAL + SG2->G2_PRODUTO + SG2->G2_CODIGO

                    cHoraFim := U_CalcHrF( .F. )
                    AADD( aOperac, { SG2->G2_OPERAC, SC2->C2_HORAJI, cHoraFim, SG2->G2_RECSKA, SG2->G2_RECURSO, SG2->G2_DESCRI, SC2->C2_QUANT-SC2->C2_QUJE, .F. } )
                    
                    SG2->( DbSkip() )
                EndDo
            
            EndIf

            If Len( aOperac ) <= 0
                MsgInfo( "N�o existe Roteiros cadastrados para o Produto !" )
            Else

                Aadd(aMyHeader, {'Opera��o'   , 'Operac' , ''     , 02                   , 00, ''               ,, 'C' })
                Aadd(aMyHeader, {'Hora In�cio', 'HoraIni', '99:99', 05                   , 00, 'U_CalcHrF(.T.)' ,, 'C' })
                Aadd(aMyHeader, {'Hora Final' , 'HoraFim', '99:99', 05                   , 00, ''               ,, 'C' })
                Aadd(aMyHeader, {'Recurso SKA', 'RecSKA' , ''     , 10                   , 00, 'ExistCPO("SH1")',, 'C', 'SH1' })
                Aadd(aMyHeader, {'Recurso'    , 'Recurso', ''     , 06                   , 00, ''               ,, 'C' })
                Aadd(aMyHeader, {'Descri��o'  , 'DescRec', ''     , 30                   , 00, ''               ,, 'C' })
                Aadd(aMyHeader, {'Saldo OP'   , 'SaldoOP', ''     , TamSx3("C2_QUANT")[1], 00, ''               ,, 'C' })

                // Mostra a tela tanto para na Inclus�o como na Altera��o da OP
                oDlg := MSDialog():New( 092,232, 366,694,"Informe os Recursos SKA da OP",,,.F.,,,,,,.T.,,,.T. )
                    oBrwOper := MsNewGetDados():New(036,008,125,230, GD_UPDATE,'U_VlLinOP()',,,{'RecSKA','HoraIni'},0,999,,,,oDlg,aMyHeader,aOperac )
                oDlg:Activate(,,,.T., EnchoiceBar(oDlg,{|| IIF( VlRecSKA(),( lConf := .T., oDlg:End() ), NIL ) }, {||oDlg:End() } ) )
                
            EndIf
        EndIf

        If lConf

            // Se j� foi integrado, desativa o que foi enviado
            If !Empty( SC2->C2_ICODIGO )

                cQuery := "UPDATE SSPIMPORT "
                cQuery += "SET ACAO = 3, STATUS = 0 "
                cQuery += "WHERE OP = '" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "' "
            
                If TCSqlExec( cQuery ) < 0
                    MSGALERT( "Erro na Atualiza��o dos dados na tabela intermedi�ria (SSPIMPORT)" + CRLF + "TCSQLError() " + TCSQLError(), "Integra��o Marcher x Senai" )
                Else
                    DbSelectArea("SC2")
                    RecLock( "SC2", .F. )
                        SC2->C2_ICODIGO := Space(10)
                        SC2->C2_IDATAEN := CtoD('')
                        SC2->C2_IHORAEN := Space(8)
                    MsUnLock()   
                EndIf

            Else

                // Atualiza a hora inicial e final da OP da primeira Opera��o
                RecLock( "SC2", .F. )
                    SC2->C2_HORAJI  := oBrwOper:aCols[ 1, P_HORAINI ]
                    SC2->C2_HORAJF  := oBrwOper:aCols[ 1, P_HORAFIM ]
                MsUnLock()

            EndIf

            // Tanto na Inclus�o como na Altera��o da OP, envia os dados
            For nLin := 1 To Len( oBrwOper:aCols )
                ExecSPImport( oBrwOper:aCols[ nLin, P_OPERAC ], AllTrim(oBrwOper:aCols[ nLin, P_DESCREC ]), oBrwOper:aCols[ nLin, P_RECSKA ], oBrwOper:aCols[ nLin, P_HORAINI ], oBrwOper:aCols[ nLin, P_HORAFIM] )
            Next

        EndIf
    EndIf

    RestArea( aArea )
    RestArea( aAreaSB1 )
    If !Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf

Return


/*/{Protheus.doc} CalcHrF
Fun��o que pega o tempo inicial e quantidade, para calcular a hora final.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 03/12/2021
@param lTela, logical, .T. se estiver na tela ou .F. para quando estiver carregando os dados.
/*/
User Function CalcHrF( lTela )

    Local cHora     := ""
    Local cMin      := ""
    Local c1        := ""
    Local cHoraJI   := ""
    Local nTmpTot   := 0
    Local nPosPonto := 0
    Local xRet

    If lTela
        cHoraJI   := &(ReadVar())
        nTmpTot   := oBrwOper:aCols[oBrwOper:nAt, P_SALDOOP ] * SB1->B1_TEMPO // SB1 do Produto da OP, n�o � do Componente.
    Else
        cHoraJI   := SC2->C2_HORAJI
        nTmpTot   := (SC2->C2_QUANT-SC2->C2_QUJE) * SB1->B1_TEMPO
    EndIf
    
    // Funcao padrao Min2Hrs() que transforma Minutos em Horas
    // Funcao padrao SomaHoras() que soma 2 horas diferentes
    c1 := SomaHoras( cHoraJI, Min2Hrs( nTmpTot ) )

    nPosPonto := At( ".", cValToChar( c1 ) )
	If nPosPonto > 0
		// Preencho com Zeros at� completar 2 caracteres
		cHora := PadL( SubStr( cValToChar( c1 ), 1, nPosPonto-1 ) , 2, "0" )
		cMin  := PadR( SubStr( cValToChar( c1 ), nPosPonto+1 ) , 2, "0" )
	Else
		// Se n�o tem o ponto � porque � hora inteira
		cHora := PadL( c1, 2, "0" )
		cMin  := "00"
	EndIf

    If cHora == "24"
        cHora := "00"
    ElseIf cHora >= "25"
        cHora := PadL( Val( cHora ) - 24, 2, "0" )
    EndIf

    If lTela
        oBrwOper:aCols[ oBrwOper:nAt, P_HORAFIM] := cHora + ":" + cMin
        xRet := .T.
    Else
        xRet := cHora + ":" + cMin
    EndIf

Return(xRet)



/*/{Protheus.doc} VlRecSKA
Valida se tem alguma linha sem Recurso SKA
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 24/08/2021
@return logical, Se todas as linhas est�o com a coluna "Recurso SKA" e "Hora In�cio" preenchidas
/*/
Static Function VlRecSKA()

    Local nLin := 1
    Local lOk  := .T.

    For nLin := 1 To Len( oBrwOper:aCols )

        If .NOT. U_VlLinOP( nLin )
            lOk := .F.
            Exit
        EndIf
    Next

Return(lOk)


/*/{Protheus.doc} VlLinOP
Validar a Linha da tela. Fun��o chamada na valida��o da Linha e tamb�m no bot�o Confirmar da tela.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 03/12/2021
@param nLin, numeric, Linha que est� sendo validada
@return logical, .T. se a linha estiver correta ou .F. caso contr�rio
/*/
User Function VlLinOP( nLin )
    Local lRet := .T.
    Default nLin := oBrwOper:nAt

    If Empty( oBrwOper:aCols[ nLin, P_RECSKA ] )
        MsgAlert("Recurso SKA deve ser informado")
        lRet := .F.
    ElseIf( Val( Left( oBrwOper:aCols[ nLin, P_HORAINI], 2 ) ) < 0 .Or. Val( Left( oBrwOper:aCols[ nLin, P_HORAINI], 2 ) ) > 23 .Or. Empty( Left( oBrwOper:aCols[ nLin, P_HORAINI], 2 ) ) )
        MsgAlert("Hora inicial deve ser informada corretamente")
        lRet := .F.
    ElseIf( Val( Right( oBrwOper:aCols[ nLin, P_HORAINI], 2 ) ) < 0 .Or. Val( Right( oBrwOper:aCols[ nLin, P_HORAINI], 2 ) ) > 59 .Or. Empty( Right( oBrwOper:aCols[ nLin, P_HORAINI], 2 ) ) )
        MsgAlert("Hora inicial deve ser informada corretamente")
        lRet := .F.
    ElseIf( Val( Left( oBrwOper:aCols[ nLin, P_HORAFIM], 2 ) ) < 0 .Or. Val( Left( oBrwOper:aCols[ nLin, P_HORAFIM], 2 ) ) > 23 .Or. Empty( Left( oBrwOper:aCols[ nLin, P_HORAFIM], 2 ) ) )
        MsgAlert("Hora final inv�lida, altere a Hora Inicial para que seja feito o c�lculo corretamente.")
        lRet := .F.
    ElseIf( Val( Right( oBrwOper:aCols[ nLin, P_HORAFIM], 2 ) ) < 0 .Or. Val( Right( oBrwOper:aCols[ nLin, P_HORAFIM], 2 ) ) > 59 .Or. Empty( Right( oBrwOper:aCols[ nLin, P_HORAFIM], 2 ) )  )
        MsgAlert("Hora final inv�lida, altere a Hora Inicial para que seja feito o c�lculo corretamente.")
        lRet := .F.
    EndIf

Return( lRet )



/*/{Protheus.doc} ExecSPImport
Executar a Stored Procedure SSP_IMPORT
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 24/08/2021
@param cOper, character, C�digo da Opera��o
@param cDescOper, character, Descri��o da Opera��o
@param cRecSKA, character, C�digo do Recurso SKA
@param cHoraIni, character, Hora inicial prevista
@param cHoraFim, character, Hora final prevista
/*/
Static Function ExecSPImport( cOper, cDescOper, cRecSKA, cHoraIni, cHoraFim )

    Local cQuery    := ""
    Local cAliReg   := ""

    Default cDescOper := ""

    cQuery := "EXECUTE [dbo].[SP_SSPIMPORT] "
    cQuery += "'" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "' "  // OP
    cQuery += ",'" + cOper + "' "                                       // OPER
    cQuery += ",'" + cDescOper + "' "                                   // DESCOPER
    cQuery += ",'" + SC2->C2_PRODUTO + "' "                             // CODPECA
    cQuery += ",'" + AllTrim(SB1->B1_DESC) + "' "                       // DESCPECA
    cQuery += ",'" + cRecSKA + "' "                                     // MAQ
    cQuery += ",' ' "                                                   // CENTROCUSTO
    cQuery += ",'" + DtoC(SC2->C2_DATPRI) + "' "                        // PLANDTINI
    cQuery += ",'" + cHoraIni + "' "                                    // PLANTMINI
    cQuery += ",'" + DtoC(SC2->C2_DATPRF) + "' "                        // PLANDTFIM
    cQuery += ",'" + cHoraFim + "' "                                    // PLANTMFIM
    cQuery += "," + cValToChar( SC2->C2_QUANT ) + " "                   // PLANQTY
    cQuery += ",1 "                                                     // CYCLEQTY
    cQuery += ",'" + cValToChar(SB1->B1_TEMPO) + "' "                   // PLANTMUNIT
    cQuery += ",0 "         		                                    // PLANTMSETUP
    cQuery += ",' ' "                                                   // MATPRIMA
    cQuery += ",' ' "                                                   // ESPESSURA
    cQuery += ",1 "                                                     // ACAO
    cQuery += ",0 "                                                     // STATUS
    cQuery += ",' ' "                                                   // NOVOID
    cQuery += ",' ' "                                                   // NOVODATAREG

    If TCSqlExec( cQuery ) < 0
        MSGALERT( "TCSQLError() " + TCSQLError(), "Integra��o Marcher x Senai" )
    Else

        If Empty( SC2->C2_ICODIGO )

            cAliReg := GetNextAlias()
            
            cQuery := "SELECT MAX(ID) AS ID FROM SSPIMPORT WHERE OP = '" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "' "
            DbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAliReg, .F., .T. )
            If (cAliReg)->( !EOF() )

                RecLock( "SC2", .F. )
                    SC2->C2_ICODIGO := cValToChar( (cAliReg)->ID )
                    SC2->C2_IDATAEN := Date()
                    SC2->C2_IHORAEN := Time()
                    SC2->C2_HORAJI  := cHoraIni
                    SC2->C2_HORAJF  := cHoraFim
                MsUnLock()
            Else
                MsgAlert( "OP inclu�da n�o foi localizada na tabela de integra��o", "Integra��o Marcher x Senai" )
            EndIf 
            (cAliReg)->( DbCloseArea() )
        EndIf
    EndIf

Return

