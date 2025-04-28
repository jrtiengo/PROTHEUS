#Include "Totvs.ch"

/*
-----------------------------------------------------------------------------
| Programa  | MA410COR  | Autor | Call System           | Data | 29/05/2017 |
-----------------------------------------------------------------------------
| Desc.     | PE acionado para manutencao de cores das legendas.            |
-----------------------------------------------------------------------------
//WMS -> 1=AGUARDANDO CANCELAMENTO;2=CANCELAMENTO AUTORIZADO;3=CANCELAMENTO NEGADO                                                       
*/
User Function MA410COR()
Local aCores := {}

If cEmpAnt <> "03"
    SetKey(VK_F11, {||})
	aCores := {	{ "Empty(C5_LIBEROK).And.Empty(C5_NOTA)"                       ,'ENABLE'    , "" },;		// Pedido em Aberto
				{ "U_A410StatusMae(C5_NUM)"                                    ,"BR_PRETO"  , "" },;		// Pedido-Filho liberado para Expedição cujo PV-mãe não esteja.
				{ "u_A410PedPedente(C5_NUM)"                                   ,"BR_PINK"   , "" },;		// Pedido-Filho liberado para Expedição e pendente
				{ "!Empty(C5_LIBEROK) .And. C5_XLIBOK=='L'.And. Empty(C5_NOTA)",'BR_MARROM' , "" },;		// Pedido liberado para Expedição
				{ "!Empty(C5_LIBEROK) .And. C5_XLIBOK=='Z'.And. Empty(C5_NOTA)",'BR_LARANJA', "" },;		// Recepção/Expedição
				{ "!Empty(C5_LIBEROK) .And. C5_XLIBOK=='W'.And. Empty(C5_NOTA)",'BR_AZUL'   , "" },;		// Em Separação
				{ "(!Empty(C5_NOTA).Or.C5_XLIBOK=='E').And.C5_X_VALOR>0.00"    ,'DISABLE'   , "" },;		// Pedido Encerrado
				{ "Empty(C5_X_NOTA).And.C5_X_VALOR==0.00"                      ,'BR_CINZA'  , "" },;		// Pedido Encerrado por eliminação de residuo
				{ "!Empty(C5_LIBEROK) .And. Empty(C5_XLIBOK)",	'BR_AMARELO'   , ""              },; 		// Pedido Liberado
				{ "!Empty(C5_LIBEROK) .And. (!Empty(C5_XLIBOK) .And. !C5_XLIBOK $ 'W,Z,L' .And. Empty(C5_NOTA))",'BR_BRANCO', ""},;	// Pedido aguardando faturamento
				{ "C5_ZCANCW == '1'"										   ,'BR_PRETO_1'	,""	 },;	// 1=AGUARDANDO CANCELAMENTO
				{ "C5_ZCANCW == '2'"										   ,'BR_PRETO_2'	,""	 },;	// 2=CANCELAMENTO AUTORIZADO
				{ "C5_ZCANCW == '3'"										   ,'BR_PRETO_3'	,""	 }}     // 3=CANCELAMENTO NEGADO
Else
	If AllTrim( FunName() ) $ "MATA410;XMATA410"
		aCores := {	{ "U_A410Processo( C5_NUM )",					"BR_PINK", "" },;						// Em producao (Delim).
					{ "C5_STATPCP == '5' .And. Empty(C5_NOTA) .And. Empty(C5_XLIBOK)",	"PCOFXOK","" },;	// Producao Finalizada (Delim).
					{ "Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. C5_STATPCP<>'2'" ,	'ENABLE', "" },;	// Pedido em Aberto
					{ "U_A410StatusMae(C5_NUM)", 					"BR_PRETO", "" },;						// Pedido-Filho liberado para Expedição cujo PV-mãe não esteja.
					{ "!Empty(C5_LIBEROK) .and. C5_XLIBOK=='L'.And. Empty(C5_NOTA)",'BR_MARROM', ""},;		// Pedido liberado para Expedição
					{ "!Empty(C5_LIBEROK) .and. C5_XLIBOK=='Z'.And. Empty(C5_NOTA)",'BR_LARANJA', ""},;		// Recepção/Expedição
					{ "!Empty(C5_LIBEROK) .and. C5_XLIBOK=='W'.And. Empty(C5_NOTA)",'BR_AZUL', ""},;		// Em Separação
					{ "!Empty(C5_NOTA).Or.C5_XLIBOK=='E'",			'DISABLE', ""},;						// Pedido Encerrado
					{ "!Empty(C5_LIBEROK) .and. Empty(C5_XLIBOK) .And. C5_STATPCP <> '2'",	'BR_AMARELO', ""},; 	// Pedido Liberado
					{ "C5_STATPCP == '2' .And. Empty(C5_XLIBOK) ",  'BR_BRANCO', ""} }                      // Pedido Aguardando Producao
//					{ "!Empty(C5_LIBEROK) .and. (!Empty(C5_XLIBOK) .and. !C5_XLIBOK $ 'W,Z,L' .And. Empty(C5_NOTA))",'BR_BRANCO', ""} }	// Pedido aguardando faturamento
	Else
		aCores := {	{ "Empty(C5_LIBEROK).And.Empty(C5_NOTA)",		'ENABLE', "" },;						// Pedido em Aberto
					{ "U_A410StatusMae(C5_NUM)", 					"BR_PRETO", "" },;						// Pedido-Filho liberado para Expedição cujo PV-mãe não esteja.
					{ "!Empty(C5_LIBEROK) .and. C5_XLIBOK=='L'.And. Empty(C5_NOTA)",'BR_MARROM', ""},;		// Pedido liberado para Expedição
					{ "!Empty(C5_LIBEROK) .and. C5_XLIBOK=='Z'.And. Empty(C5_NOTA)",'BR_LARANJA', ""},;		// Recepção/Expedição
					{ "!Empty(C5_LIBEROK) .and. C5_XLIBOK=='W'.And. Empty(C5_NOTA)",'BR_AZUL', ""},;		// Em Separação
					{ "!Empty(C5_NOTA).Or.C5_XLIBOK=='E'",			'DISABLE', ""},;						// Pedido Encerrado
					{ "!Empty(C5_LIBEROK) .and. Empty(C5_XLIBOK)",	'BR_AMARELO', ""},; 					// Pedido Liberado
					{ "!Empty(C5_LIBEROK) .and. (!Empty(C5_XLIBOK) .and. !C5_XLIBOK $ 'W,Z,L' .And. Empty(C5_NOTA))",'BR_BRANCO', ""} }	// Pedido aguardando faturamento
	EndIf
EndIf


Return aCores

/*
-----------------------------------------------------------------------------
| Funcao    | A410StatusMae | Autor | Call System       | Data | 21/10/2016 |
-----------------------------------------------------------------------------
| Desc.     | Funcao para obter o status de faturamento do pedido mae       | 
-----------------------------------------------------------------------------
*/
User Function A410StatusMae( cNumero )
Local aArea		:= GetArea()
Local aAreaSC5	:= SC5->( GetArea() )
Local aAreaSC6	:= SC6->( GetArea() )
Local cAlias	:= GetNextAlias()
Local cQuery	:= ""
Local lRet 		:= .F.

// Foi feita a restricao na empresa pois a resposta do sistema era letna
// a cada PV posicionado pelos usuarios externo
If cEmpAnt == "01"
	DbSelectArea( "SC5" )
	SC5->( DbSetOrder( 1 ) )
	SC5->( DbSeek( xFilial( "SC5" ) + cNumero ) )
	If SC5->C5_AGLUTIN == "1" .And. !Empty( SC5->C5_LIBEROK ) .And. SC5->C5_XLIBOK == "L" .And. Empty( SC5->C5_NOTA )
		DbSelectArea( "SC6" )
		SC6->( DbSetOrder( 1 ) )
		If SC6->( DbSeek( xFilial( "SC6" ) + cNumero ) )
			cQuery := "SELECT C5_XCODBAR " 
			cQuery += "FROM " + RetSqlName( "SC5" ) + " SC5 "
			cQuery += "WHERE SC5.D_E_L_E_T_ = ' ' "
			cQuery += "AND C5_NUM = '" + SC6->C6_PVAGLUT + "' "
			DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlias, .T., .T. )
			
			// C5_XCODBAR vazio significa que o PV não está em nenhuma das etapas de responsabilidade da Expedição
			If (cAlias)->( !Eof() )
				lRet := Empty( (cAlias)->C5_XCODBAR )
			EndIf

			(cAlias)->( DbCloseArea() )
		EndIf
	EndIf
EndIf

RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aArea )
Return lRet

/*
-----------------------------------------------------------------------------
| Funcao    | A410PedPedente | Autor | Call System      | Data | 04/02/2019 |
-----------------------------------------------------------------------------
| Desc.     | Identifica algum pedido liberado para expedicao que esteja    | 
|           | pendente e que utiliza TES Futura (Processo de Aglutinacao)   | 
-----------------------------------------------------------------------------
*/
User Function A410PedPedente( cNumero )
Local aArea		:= GetArea()
Local aAreaSC5	:= SC5->( GetArea() )
Local aAreaSC6	:= SC6->( GetArea() )
Local lRet 		:= .F.

// Foi feita a restricao na empresa pois a resposta do sistema era letna
// a cada PV posicionado pelos usuarios externo
If cEmpAnt == "01"
	lRet := SC5->C5_AGLUTIN <> "1" .And. !Empty( SC5->C5_LIBEROK ) .And. SC5->C5_XLIBOK == "L" .And. Empty( SC5->C5_NOTA ) .And. u_UsaTesFutura( cNumero )
EndIf



RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aArea )
Return lRet
