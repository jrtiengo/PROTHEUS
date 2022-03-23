#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/{Protheus.doc} WFPC001  
//WorkFlow - disparado pedido de compra em atrado para a entrega.
@author Celso Rene 
@since 26/08/2016
@version 1.0
@type function
/*/
//u_WFPC001({"01"})
User Function WFPC001(aParam)

    Local oProcess
    Local oHtml
    Local _cQuery    := ""
    Local _lPrimeiro := .T.
    Default aParam := {"01","01"}

    Conout('WFPC001() /' + aParam[1] )
    WFPREPENV( aParam[1] , aParam[2])

    _cQuery := " SELECT  SC7.*, SB1.B1_DESC ,SA2.A2_NOME " + chr(13)
    _cQuery += " FROM " + RETSQLNAME("SC7") + " SC7 " + chr(13)
    _cQuery += " INNER JOIN " + RETSQLNAME("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' AND SB1.B1_COD = SC7.C7_PRODUTO "+ chr(13)
    _cQuery += " INNER JOIN " + RETSQLNAME("SA2") + " SA2 ON SA2.D_E_L_E_T_ = '' AND SA2.A2_COD + SA2.A2_LOJA = SC7.C7_FORNECE + SC7.C7_LOJA " + chr(13)
    _cQuery += " WHERE SC7.D_E_L_E_T_ = '' AND SC7.C7_DATPRF < '" + DtoS(Date()) + "' AND SC7.C7_RESIDUO = '' AND SC7.C7_APROV <> '' AND SC7.C7_CONAPRO = 'L' "+ chr(13)
    _cQuery += " AND SC7.C7_QUANT > SC7.C7_QUJE " + chr(13)  //AND SC7.C7_QTDACLA = 0 AND SC7.C7_QUJE = 0
    _cQuery += " ORDER BY SC7.C7_DATPRF , SC7.C7_NUM, SC7.C7_ITEM "

    If select("TMP") <> 0
        TMP->(dbclosearea())
    EndIf
    TcQuery _cQuery New Alias "TMP"

    TMP->(DbGoTop())

    //verificando se encontrou registros
    If (TMP->( EOF() ) )
        TMP->(DbCloseArea()) 
		Return()
	EndIf

    Do While !TMP->(Eof())

        //imprimindo uma vez o cabecalho
        If (_lPrimeiro == .T.)

            _lPrimeiro := .F.

            oProcess := TWFProcess():New( "000005", "WF - PEDIDOS DE COMPRA EM ATRASO DE ENTREGA" )
            oProcess:NewVersion(.T.)
            oProcess:NewTask( "WF - PEDIDOS DE COMPRA EM ATRASO DE ENTREGA", "\WORKFLOW\WFPC001.HTM" )
            oProcess:cTo := "compras@marcher.com.br" 
            oProcess:cCC := GetMV("ES_WFPC001") //contatos copia - ES_WFPC001 = "dmachado@marcher.com.br;glaucia@marcher.com.br"
            oProcess:NewVersion(.T.)
            oProcess:cSubject := "WF - PEDIDOS DE COMPRA EM ATRASO DE ENTREGA"
            oHtml   := oProcess:oHTML
            oHtml:ValByName( "DTREF"  	, dDataBase)

        Endif
 
        //listando os itens encontrados na query
        aAdd( (oHtml:ValByName( "IT.PC"    	 )) , TMP->C7_NUM											    )	// pedido de compra
        aAdd( (oHtml:ValByName( "IT.ITEM"    )) , TMP->C7_ITEM										        )	// item 
        aAdd( (oHtml:ValByName( "IT.PROD"    )) , TMP->C7_PRODUTO										    )	// produto
        aAdd( (oHtml:ValByName( "IT.DESCP"   )) , Alltrim(TMP->B1_DESC)   							        )	// descricao produto
        aAdd( (oHtml:ValByName( "IT.QTD"     )) , Transform(TMP->C7_QUANT - TMP->C7_QUJE,"@e 999,999.99")   )	// quantidade
        aAdd( (oHtml:ValByName( "IT.EMIS"    )) , DtoC(StoD((TMP->C7_EMISSAO)))								)	// emissao
        aAdd( (oHtml:ValByName( "IT.ENTREG"  )) , DtoC(StoD((TMP->C7_DATPRF)))							    ) 	// prev. entrega
        aAdd( (oHtml:ValByName( "IT.CODFOR"  )) , TMP->C7_FORNECE + " - " + TMP->C7_LOJA				    )	// cod. fornecedor + loja
        aAdd( (oHtml:ValByName( "IT.NOMFOR"  )) , Alltrim(TMP->A2_NOME)			                    	    )	// nome fornecedor

        TMP->(DbSkip())

    EndDo


    TMP->(DbCloseArea())

    oProcess:Start()


    Conout("WFPC001 - Enviou e-mail: aviso disparado: lista dos pedidos de compra em atrasos  - " + DtoC(dDataBase) + " - " + Time() )


Return()
