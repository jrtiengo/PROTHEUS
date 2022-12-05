#INCLUDE "protheus.ch"
#Include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE_TMKVFIMºAutor  ³ Cesar Mussi        º Data ³  29/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TMKVFIM()

Local cSql      := ""
Local cArea     := alias()
Local _ParCom   := 0
Local _Status   := "01"
Local _aArea 	:= GetArea()
Local _aAreaSUB := GetArea("SUB")
Local _aAreaSF4 := GetArea("SF4")
Local _aAreaSB2 := GetArea("SB2")
Local _aAreaSC5 := GetArea("SC5")
Local _aAreaSC6 := GetArea("SC6")

If M->UA_OPER == "1" // faturamento - quer dizer que vai gerar SC5, SC6
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	Reclock("SC5",.f.)
	SC5->C5_VEND1   := M->UA_VEND
	SC5->C5_VEND2   := M->UA_VEND2
	//SC5->C5_VEND3 := M->UA_VEND3
	//SC5->C5_VEND4 := M->UA_VEND4
	//SC5->C5_VEND5 := M->UA_VEND5
	SC5->C5_COMIS1  := M->UA_COMIS
	SC5->C5_COMIS2  := M->UA_COMIS2
    SC5->C5_OBSI    := M->UA_OBS

    If Empty(M->UA_OC)
       SC5->C5_MENNOTA := "PEDIDO NR. " + ALLTRIM(SC5->C5_NUM)
    Else
       SC5->C5_MENNOTA := "PEDIDO NR. " + ALLTRIM(SC5->C5_NUM) + " OC Nr(s): " + ALLTRIM(M->UA_OC)
    Endif

	MsUnlock()
 
    // Pesquisa a condição de pagamento e verifica se é permitido impressão de Boleto Bancário no encerramento do Atendimento Call Center
    If Select("T_CONDICAO") > 0
       T_CONDICAO->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT E4_CODIGO,"
    cSql += "       E4_BVDA   "
    cSql += "  FROM " + RetSqlName("SE4")
    cSql += " WHERE E4_CODIGO  = '" + Alltrim(M->UA_CONDPG) + "'"
    cSql += "   AND E4_FILIAL  = ''"
    cSql += "   AND D_E_L_E_T_ = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
         
    If !T_CONDICAO->( EOF() )
       If T_CONDICAO->E4_BVDA == "S"
          BIMP_BOLETO(M->UA_CONDPG, M->UA_CLIENTE, M->UA_LOJA)
       Endif
    Endif

    // Pesquisa o parâmetro Automatech - % de bloqueio de comissão Quoting - Pedidos Call Center
    If Select("T_PARAMETROS") > 0
       T_PARAMETROS->( dbCloseArea() )
    EndIf
   
    cSql := ""
    cSql := "SELECT ZZ4_CCEN" 
    cSql += "  FROM " + RetSqlName("ZZ4")

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

    _ParCom := IIF(T_PARAMETROS->( EOF() ), 0, T_PARAMETROS->ZZ4_CCEN)
	
    // Posiciona os Ítens do Pedido de Venda
	DbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek( xFilial("SC6") + SC5->C5_NUM )

	cChave  := C6_FILIAL + C6_NUM
 
	Do While cChave == SC6->C6_FILIAL + SC6->C6_NUM

        _Status := "01"
	
		Reclock("SC6",.f.)
		    
	    // Grava os dados para o quoting tools
		SC6->C6_QTGMRG := Round( Posicione( "SUB", 3, SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM, "UB_QTGMRG" ), 2 )
		
		// Jean Rehermann - 27/02/2014 - Tarefa #8453
        If SC6->C6_TES $ SuperGetMv("MV_TESDOAC",,"") // Pedido referente a doação
			_Status := "02" // Bloqueia na margem
        Else
	        // Bloqueia Quoting se comissão estiver acima do parâmetro estabelecido
	        If _ParCom <> 0
	           If M->UA_COMIS > _ParCom
	              _Status := "02"
	           EndIf
	        EndIf   
        EndIf
        
        If _Status == "02"
			SC6->C6_BLQ := "S"
			aAreaAtual := GetArea()
			dbSelectArea("SC5")
			dbSetOrder(1)
//			DbSeek( xfilial("SC6") + cCodPed )
			DbSeek( xfilial("SC6") + SC6->C6_NUM )
			Reclock("SC5",.F.)
				SC5->C5_BLQ := "3"
			SC5->( Msunlock())
			RestArea( aAreaAtual )
        EndIf

        SC6->C6_STATUS := _Status // Aguardando liberação de margem
        U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, _Status, "PE_TMKVFIM") // Gravo o log de atualização de status na tabela ZZ0

		MsUnlock()

 	    DbSelectArea("SC6")
	    DbSkip()

	Enddo
    
Endif

// Jean Rehermann - 01-02-2012 - Grava o status 01 em cada item do pedido
// Estas linhas foram colocadas dentro do laço acima (13/11/2013 - Harald e Jean)
//_aAreaSC6 := SC6->( GetArea() )
//dbSelectArea("SC6")
//dbSetOrder(1)
//dbSeek( xFilial("SC6") + SC5->C5_NUM )
//
//While !SC6->( Eof() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM 
//	RecLock( "SC6", .F. )
//		C6_STATUS := "01"
//	MsUnLock()
//	SC6->( dbSkip() )
//End
//RestArea( _aAreaSC6 )
// Fim | Jean Rehermann - 01-02-2012

// Restaura o ambiente
RestArea(_aAreaSUB)
RestArea(_aAreaSF4)
RestArea(_aAreaSB2)
RestArea(_aAreaSC5)
RestArea(_aAreaSC6)
RestArea(_aArea)

Return

// Função que realiza a impressão dos boletos bancários
Static Function BIMP_BOLETO()

   Private cMemo1 := ""
   Private oMemo1

   Private oDlgBol

   DEFINE MSDIALOG oDlgBol TITLE "Emissão de Boleto Bancario" FROM C(178),C(181) TO C(315),C(634) PIXEL

   @ C(005),C(005) Say "Atenção!"                                                                                                   Size C(023),C(008) COLOR CLR_RED   PIXEL OF oDlgBol
   @ C(017),C(005) Say "A Condição de Pagamento utilizada neste Atendimento Call Center permite que seja emitido o Boleto Bancário" Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol
   @ C(026),C(005) Say "de cobrança para envio ao Cliente. Salve o(s) Boleto(s) em PDF e envie-os por e-mail ao Cliente."           Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol

   @ C(045),C(005) GET oMemo1 Var cMemo1 MEMO Size C(216),C(001) PIXEL OF oDlgBol

   @ C(051),C(005) Button "Gerar Boleto(s)"             Size C(077),C(012) PIXEL OF oDlgBol ACTION(U_AUTOM636(M->UA_FILIAL, M->UA_NUM, .T.))

   @ C(051),C(143) Button "Continuar s/Gerar Boleto(s)" Size C(077),C(012) PIXEL OF oDlgBol ACTION( oDlgBol:End() )

   ACTIVATE MSDIALOG oDlgBol CENTERED 
   
Return(.T.)