/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F080MTBX       ºAutor  ³Luciano Souza - TRSE42   29/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                        ±±
±±º                                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
#INCLUDE "TOTVS.CH"

User Function F080MTBX()
Local lRetorno    := .T.
Local aArea       := GetArea()
Local aAreaSE2    := SE2->(GetArea())

Local aParametros := PARAMIXB
Local cAliasSE2   := GetNextAlias()
Local nTimer      := 15000 // GetMv( "MV_MSGTIME" ) 

	// MV_SCITPBX
	If rTrim( cMotBX ) == "DACAO"  .or.  rTrim( cMotBX ) == "ESTORNO"

		lFilhosBaixados := Fa050Filho( .T. )
		
		cChaveSE2 := rTrim( SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA )
/*
		        SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_CODRET, SE2.E2_TITPAI, SE2.E2_AGLIMP, SE2.E2_NUMTIT, 
		        SE2.E2_BAIXA, SE2.E2_SALDO, SE2.E2_STATUS, SE2.R_E_C_N_O_
		        ORDER BY %Order:SE2%
*/
		BeginSql alias cAliasSE2		    
		    SELECT
		        COUNT( SE2.R_E_C_N_O_) QTDREGISTRO
		    FROM
		        %table:SE2% SE2
		    WHERE
		        1 = 1
		        AND SE2.E2_FILIAL = %xfilial:SE2% 
		        AND %Exp:cChaveSE2% = rTrim( SE2.E2_TITPAI ) 
		        AND SE2.E2_TIPO = 'TX ' AND SE2.E2_CODRET = '1708'
		        AND SE2.E2_BAIXA <> '        ' 
		        AND SE2.%notDel% 
		EndSql
		
		lTemTXBaixado := ( (cAliasSE2)->QTDREGISTRO > 0 )
		
		/*
		(cAliasSE2)->(dbSelectArea( cAliasSE2 ))
		(cAliasSE2)->(dbGoTop())
		Do While !(cAliasSE2)->(Eof())
			If !Empty( (cAliasSE2)->E2_BAIXA )
			 	lTemTXBaixado := .T.
			EndIf
		    (cAliasSE2)->(DbSkip())
		EndDo
		*/
		
		
		If  lTemTXBaixado  .and.  ;
		    Aviso( "Deseja Conitnuar ?", ;
		            CRLF + CRLF + "Temos titulos de imposto de IR já baixados para esse titulo principal! ", ;
		            {"Sim","Nao"}, ;
		            2, ;
		            "", ;
		            , ;
		            , ;
		            .F., ;
		            nTimer, ;
		            2 ) == 2
			//Alert( "Escolheu NAO")
			lRetorno := .F.
		//Else
			//lRetorno := .T.
			//Alert( "Escolheu SIM" )
		EndIf
		
		// Alert( /*"MV_SCIMSGBX"*/ "Existem " + cMotBX )
	
		(cAliasSE2)->( dbCloseArea() )	
		
	EndIf

// E2_AGLIMP
// E2_TITPAI
// E2_NUMTIT

RestArea( aArea )
RestArea( aAreaSE2 )
Return lRetorno



