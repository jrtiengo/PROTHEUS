#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} MARA090A
Realizar a aglutinação de OP.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 11/01/2022
@param aLista, array, Lista com as OP's filtradas conforme fonte MARA090.prw
/*/
User Function MARA090A( aLista )

	Local aStru     := {}
	Local aTam      := {}
    Local oTempTable

    Private cAliAglut := ""
    Private cMarca    := ""

    If Empty( aLista )
        Return
    EndIf

    // Ordena por C2_TPOP + C2_PRODUTO + C2_ROTEIRO + C2_REVISAO
    // Assim ficará fácil de comparar os registros para aglutinar
    aLista := aSort(aLista,,, { |x, y| x[31]+x[08]+x[33]+x[32] < y[31]+y[08]+y[33]+y[32] })

    cAliAglut := GetNextAlias()
    cMarca    := GetMark()
    
	AADD(aStru,{ "MARK"   		,"C",02		,0})
	aTam:=TamSX3("D4_OP")
	AADD(aStru,{ "NUMOP"  		,"C",aTam[1],0})
	AADD(aStru,{ "OPNOVA"  		,"C",06     ,0})
	aTam:=TamSX3("B1_COD")
	AADD(aStru,{ "PRODUTO"		,"C",aTam[1],0})
	AADD(aStru,{ "PRODPAI"		,"C",aTam[1],0})
	aTam:=TamSX3("B1_DESC")
	AADD(aStru,{ "DESCRICAO"	,"C",aTam[1],0})
	aTam:=TamSX3("C2_QUANT")
	AADD(aStru,{ "AGLUTINA"		,"N",06     ,0})
	AADD(aStru,{ "QUANT"  		,"N",aTam[1],aTam[2]})
	AADD(aStru,{ "INICIO" 		,"D",08		,0})
	AADD(aStru,{ "ENTREGA"		,"D",08		,0})
	AADD(aStru,{ "ORDEM"  		,"N",04		,0})
	AADD(aStru,{ "GERADO" 		,"C",01		,0})
	AADD(aStru,{ "ROTEIRO" 		,"C",02		,0})
	aTam:=TamSX3("C2_OPC")
	AADD(aStru,{ "OPCIONAL"		,"C",aTam[1],0})
	aTam:=TamSX3("C2_TPOP")
	AADD(aStru,{ "TPOP"			,"C",aTam[1],0})
	AADD(aStru,{ "REFGRD"		,"C",01     ,0})
	aTam:=TamSX3("C2_REVISAO")
	AADD(aStru,{ "REVISAO"		,"C",aTam[1],0})
	AADD(aStru,{ "ERRO"         ,"C",200    ,0})

	oTempTable := FWTemporaryTable():New( cAliAglut, aStru )
	oTempTable:AddIndex("01", {"NUMOP"   } )
	oTempTable:AddIndex("02", {"AGLUTINA"} )
	oTempTable:Create() 
	
	Processa({|| MR090Agl( aLista ) }, "Aguarde !", "Verificando as OP's apresentadas..." )

	MR090Brw()

	oTempTable:Delete()

Return


/*/{Protheus.doc} MR090Agl
Processa o array validando as OP's e então carrega as OP's em uma tabela temporária.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 11/01/2022
@param aLista, array, Lista com as OP's filtradas
/*/
Static Function MR090Agl( aLista )

    Local nItem     := 0
    Local nItAglut  := 0
    Local nAglutina := 1
    Local nProxOP   := 0
    Local nTotReg   := Len( aLista )
    Local cTpOp     := ""
    Local cProduto  := ""
    Local cRoteiro  := ""
    Local cRevisao  := ""
    Local cOPAtu    := ""
    Local cFilSC2   := FWFilial("SC2")

    /*
    // Posições do array aLista:
        // 01 - Marcação
        // 02 - Nº do Pedido de Venda
        // 03 - Nº da Ordem de Produção
        // 04 - CNPJ/CPF do Cliente
        // 05 - Nome do Cliente
        // 06 - Quantidade da Ordem de Produção
        // 07 - Quantidade da Ordem de Produção
        // 08 - Código do Produto a ser produzido
        // 09 - Nome do Produto
        // 10 - Nº da Nota Fiscal
        // 11 - Data do Faturamento
        // 12 - Código da Transportadora
        // 13 - Nome da Transportadora
        // 14 - Nome da Cidade do Cliente
        // 15 - Estado da Cidade do Cliente
        // 16 - Código do Vendedor
        // 17 - Nome do Vendedor
        // 18 - Data Inicial de Entrega
        // 19 - Data Final de Entrega
        // 20 - Data de Emissão da Ordem de Produção
        // 21 - Quantidade do Pedido de Venda
        // 22 - Código do Produto da Ficha Técnica
        // 23 - Nome do Produto da Ficha Técnica
        // 24 - Quantidade a ser utilizada na produção
        // 25 - Código do Cliente
        // 26 - Loja do Cliente
        // 27 - Mensagem
        // 28 - Recurso
        // 29 - Status da OP // U=Suspensa;S=Sacramentada;N=Normal	[ T_PRODUCAO->C2_STATUS ]
        // 30 - Saldo a entregar da OP
        // 31-  Tipo da OP - P=Prevista ou F=Firme 	[ T_PRODUCAO->C2_TPOP ]
        // 32 - Revisão da OP
        // 33 - Código do Roteiro da OP
        // 34 - Saldo a entregar 	
        // 35 - Flag OP HAPTA A PRODUZIR(COM ESTOQUE) \ FALTA MATERIAL
    */

    ProcRegua( nTotReg )

    For nItem := 1 To nTotReg

        cTpOp    := aLista[ nItem, 31 ]
        cProduto := aLista[ nItem, 08 ]
        cRoteiro := aLista[ nItem, 33 ]
        cRevisao := aLista[ nItem, 32 ]
        cOPAtu   := ""

         // C2_FILIAL + C2_TPOP + C2_PRODUTO + C2_ROTEIRO + C2_REVISAO
        cOPAtu  := cFilSC2 + cTpOp + cProduto + cRoteiro + cRevisao

        IncProc( "Comparando OP " + aLista[ nItem, 03 ] )

        // Pega o próximo ou o último item do array
        nProxOP := Min( nItem+1, nTotReg)

        // Processa do registro atual até o fim do que tem no array
        For nItAglut := nProxOP To nTotReg

            // Só pega o que for igual
            If cOPAtu == cFilSC2 + aLista[ nItAglut, 31 ] + aLista[ nItAglut, 08 ] + aLista[ nItAglut, 33 ] + aLista[ nItAglut, 32 ]

                // Valida os dados e carrega o item na tabela temporária
                ValidCarregaOP( nItem, nAglutina )
                ValidCarregaOP( nItAglut, nAglutina )
            EndIf

        Next nItAglut
        // Soma um para incrementar um Sequencial
        nAglutina++

    Next nItem

Return


/*/{Protheus.doc} ValidCarregaOP
Validar os dados e carregar na tabela temporária
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 17/01/2022
@param nReg, numeric, Registro do array
@param nAglutina, numeric, Sequencial da Aglutinação
/*/
Static Function ValidCarregaOP( nReg, nAglutina )

    Local cMsg      := ""
    Local cFilSD3   := FWFilial("SD3")
    Local cFilSH6   := FWFilial("SH6")
    Local cFilSC2   := FWFilial("SC2")

    dbSelectArea("SC2")
	dbSetOrder(1) // C2_FILIAL + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD

    dbSelectArea("SD3")
	dbSetOrder(1) // D3_FILIAL + D3_OP + D3_COD + D3_LOCAL

    dbSelectArea("SH6")
	dbSetOrder(1) // H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN

    dbSelectArea(cAliAglut)
	dbSetOrder(1) // NUMOP

    // OP já foi carregada na tabela temporária, então retorna
    DbSelectArea( cAliAglut )
    If Dbseek( aLista[ nReg, 03 ] )
        Return
    EndIf

    If .NOT. SC2->( dbSeek( cFilSC2 + aLista[ nReg, 03 ] ) )
        cMsg := "OP não localizada no cadastro."
    Else

        If .NOT. Empty( SC2->C2_DATRF )
            cMsg += "OP foi encerrada em " + DtoC( SC2->C2_DATRF )
        EndIf

        If SC2->C2_QUJE > 0
            cMsg += "OP foi atendida com a Quantidade parcial ou total de " + cValToChar( SC2->C2_QUJE )
        EndIf

        If SC2->C2_PERDA > 0
            cMsg += "OP teve Perda com a Quantidade de " + cValToChar( SC2->C2_PERDA )
        EndIf

    EndIf

    If Empty( cMsg )
        // D3_FILIAL + D3_OP + D3_COD + D3_LOCAL
        If SD3->( dbSeek( cFilSD3 + aLista[ nReg, 03 ] ) )
        
            While SD3->( .NOT. EOF() ) .And. SD3->D3_FILIAL + SD3->D3_OP == cFilSD3 + aLista[ nReg, 03 ]
                
                If SD3->D3_ESTORNO <> "S"
                    cMsg := "OP com movimentação interna sem Estorno."
                    Exit 
                EndIf

                SD3->( DbSkip() )
            EndDo
        EndIf
    EndIf

    If Empty( cMsg )
        // H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN
        If SH6->( dbSeek( cFilSH6 + aLista[ nReg, 03 ] ) )
            cMsg := "OP com Apontamento"	
        EndIf
    EndIf

    // Carrega na tabela temporária todas as OP's ( com ou sem erro ), para que o usuário possa selecionar o que ele quer Aglutinar.
    dbSelectArea( cAliAglut )
    RecLock( (cAliAglut), .T. )
        Replace MARK      With IIF( Empty( cMsg ), cMarca, "  " )
        Replace AGLUTINA  With nAglutina
        Replace NUMOP     With aLista[ nReg, 03 ]
        Replace PRODUTO   With aLista[ nReg, 08 ]
        Replace DESCRICAO With aLista[ nReg, 09 ]
        Replace QUANT     With aLista[ nReg, 06 ]
        Replace INICIO    With aLista[ nReg, 18 ]
        Replace ENTREGA   With aLista[ nReg, 19 ]
        Replace ORDEM     With nReg
        Replace ROTEIRO   With aLista[ nReg, 33 ]
        Replace TPOP      With aLista[ nReg, 31 ]
        Replace REVISAO   With aLista[ nReg, 32 ]
        Replace ERRO	  With cMsg
    MsUnlock()
    
Return


/*/{Protheus.doc} MR090Brw
Mostra um browse com as OP's, sendo que a última coluna tem a informação se a OP pode ou não ser selecionada.
Caso o usuário marque as OP's e clique em "Gravar", então serão geradas as OP's aglutinadas.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 11/01/2022
/*/
Static Function MR090Brw()

    Local aCol      := {}
    Local aColumns  := {}
    Local nContFlds := 0
    Local oMark

    // Array aCol contendo o objeto FWBrwColumn ou um array com a seguinte estrutura:
    // [n][01] Título da coluna
    // [n][02] Code-Block de carga dos dados
    // [n][03] Tipo de dados
    // [n][04] Máscara
    // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
    // [n][06] Tamanho
    // [n][07] Decimal
    // [n][08] Parâmetro reservado
    // [n][09] Parâmetro reservado
    // [n][10] Indica se exibe imagem
    // [n][11] Code-Block de execução do duplo clique
    // [n][12] Parâmetro reservado
    // [n][13] Code-Block de execução do clique no header
    // [n][14] Indica se a coluna está deletada
    // [n][15] Indica se a coluna será exibida nos detalhes do Browse
    // [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)

    aCol :={{"NUMOP"    , "OP Atual"        , "C",  14, ""                      },;
            {"PRODUTO"  , "Produto"         , "C",  15, ""                      },;
            {"DESCRICAO", "Descrição"       , "C",  30, ""                      },;
            {"QUANT"    , "Quantidade"      , "N",  18, "@E 999,999,999,999.99" },;
            {"ENTREGA"  , "Entrega Prevista", "D",  10, ""                      },;
            {"ERRO"     , "Msg. Erro"       , "C", 300, ""                      },;
            {"AGLUTINA" , "Aglutinador"     , "C",  06, ""                      } }
    
    For nContFlds := 1 To Len( aCol )
 
        AAdd( aColumns, FWBrwColumn():New() )

        aColumns[Len(aColumns)]:SetData( &("{ || " + (cAliAglut)->(aCol[nContFlds][1]) + " }") )
        aColumns[Len(aColumns)]:SetTitle( aCol[nContFlds][2] )
        aColumns[Len(aColumns)]:SetType( aCol[nContFlds][3] )
        aColumns[Len(aColumns)]:SetSize( aCol[nContFlds][4] )
        aColumns[Len(aColumns)]:SetPicture( aCol[nContFlds][5] )
    Next
    
    dbSelectArea( cAliAglut )

    oMark := FWMarkBrowse():New()
    oMark:SetAlias( cAliAglut )
    oMark:SetColumns( aColumns )
    oMark:SetTemporary(.T.)
    oMark:SetDescription( "Seleção de OP's para Aglutinação" )
    oMark:SetFieldMark( "MARK" )
    oMark:SetMark( cMarca )
    oMark:SetValid({|| ValOPMarca() })
    oMark:SetIgnoreARotina(.T.)
    oMark:DisableReport()
    oMark:AddButton("Confirmar",{|| Processa({|| A090Make()}, "Aglutinar OP's", "Aglutinando OPs Selecionadas...", .F. ), Self:End() },,1,0)
    oMark:AddButton("Cancelar",{||Self:End()},,1,0)
    oMark:Activate()

    FreeObj(oMark)
   
Return


/*/{Protheus.doc} ValOPMarca
Valida se pode ou não marcar a OP para que seja aglutinada
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 13/01/2022
@param oMark, object, Marcação usada na tela
/*/
Static Function ValOPMarca()

    Local lOk := .T.

    If .NOT. Empty( (cAliAglut)->ERRO )
        lOk := .F.
        MsgAlert((cAliAglut)->ERRO, "Aglutinação de OP's")
    EndIf

Return( lOk )


/*/{Protheus.doc} A090Make
Realiza a aglutinação das OP's selecionadas
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 13/01/2022
/*/
Static Function A090Make()

    Local nRecno     := 0
    Local nX         := 0
    Local nTotReg    := 0
    Local nAglutina  := 0
    Local aRecnoC6   := {}
    Local cSeekC6    := ""
    Local cMsg       := ""
    Local cProxOP    := ""
    LoCal cItem      := "01"
    LoCal cSequen    := "001"
    LoCal cItemGrd   := "   "
    Local cFilSB1    := FWFilial("SB1")
    Local cFilSC1    := FWFilial("SC1")
    Local cFilSC2    := FWFilial("SC2")
    Local cFilSC6    := FWFilial("SC6")
    Local cFilSD3    := FWFilial("SD3")
    Local cFilSD4    := FWFilial("SD4")
    Local cFilSH8    := FWFilial("SH8")
    Local cUsrAlut   := RetCodUsr()
    Local cFunName   := FunName()
    Local cLocProc   := GetMvNNR('MV_LOCPROC','99')
    Local lOPIPROC   := SuperGetMv("MV_OPIPROC",.F.,.T.)

    If .NOT. MsgNoYes( "Confirma a aglutinação das OP's selecionadas ? ", "Aglutinação de OP's" )
        Return
    EndIf

    ProcLogIni({},"MARA090", "Aglutinação OP")
    
    ProcLogAtu("INICIO")

    DbSelectArea("SB1")
    DbSetOrder(1)

    DbSelectArea("SC2")
    DbSetOrder(1)

    DbSelectArea( cAliAglut )
    DbSetOrder( 2 ) // Ordena pelo campo AGLUTINA
    Count To nTotReg
    DbGoTop()

    ProcRegua( nTotReg )

    // Loop para preencher com a NOVA numeração de OP's
    While (cAliAglut)->( .NOT. EOF() )

        IncProc( "Aglutinando OP " + (cAliAglut)->NUMOP )

        nAglutina := (cAliAglut)->AGLUTINA

        While nAglutina == (cAliAglut)->AGLUTINA

            If (cAliAglut)->MARK == cMarca

                // pega a próxima numeração de OP
                If Empty( cProxOP )
                    cProxOP := GetNumSc2(.T.)

                    While SC2->( DbSeek( cFilSC2 + cProxOP ) )
                        ConfirmSX8()
                    EndDo
                EndIf
                dbSelectArea( cAliAglut )
                RecLock( cAliAglut, .F. )
                    (cAliAglut)->OPNOVA := cProxOP
                MsUnlock()

            EndIf

            dbSelectArea( cAliAglut )
            DbSkip()
        EndDo
        // Limpo para que pegue o proximo nr de OP
        cProxOP := ""
    EndDo

    dbSelectArea( cAliAglut )
    DbSetOrder( 2 ) // Ordena pelo campo AGLUTINA
    DbGoTop()

    ProcRegua( nTotReg )

    While (cAliAglut)->( .NOT. EOF() )

        IncProc( "Incluindo nova OP " + (cAliAglut)->OPNOVA )

        nAglutina := (cAliAglut)->AGLUTINA

        While nAglutina == (cAliAglut)->AGLUTINA
            
            If (cAliAglut)->MARK == cMarca
            
                Begin Transaction

                    cMsg := "OP " + AllTrim((cAliAglut)->NUMOP) + " aglutinada para OP " + (cAliAglut)->OPNOVA + CRLF
                    cMsg += "Realizado em " + DtoC(DATE()) + " as " + Time() + CRLF
                    cMsg += "Usuario " + cUsrAlut

                    ProcLogAtu("MENSAGEM", "OP " + AllTrim((cAliAglut)->NUMOP) + " aglutinada para OP " + (cAliAglut)->OPNOVA, cMsg )

                    SB1->( DbSeek( cFilSB1 + (cAliAglut)->PRODUTO) )
                    
                    dbSelectArea("SC2")
                    If dbSeek( cFilSC2 + (cAliAglut)->OPNOVA )
                        ProcLogAtu("MENSAGEM", "OP " + (cAliAglut)->OPNOVA + " atualizada ", "OP " + (cAliAglut)->OPNOVA + " atualizada com mais a quantidade de " + cValToChar( (cAliAglut)->QUANT ) )
                        RecLock("SC2",.F.)
                    Else
                        ProcLogAtu("MENSAGEM", "OP incluida " + (cAliAglut)->OPNOVA, "OP incluida " + (cAliAglut)->OPNOVA + " com a quantidade de " + cValToChar( (cAliAglut)->QUANT ) )
                        If lOPIPROC
                            cLocalOP := If(SB1->B1_APROPRI=="I",cLocProc,RetFldProd(SB1->B1_COD,"B1_LOCPAD"))
                        Else
                            cLocalOP := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
                        EndIf
                        RecLock("SC2",.T.)
                            SC2->C2_FILIAL   := cFilSC2
                            SC2->C2_NUM 	 := (cAliAglut)->OPNOVA
                            SC2->C2_ITEM     := cItem
                            SC2->C2_SEQUEN   := cSequen
                            SC2->C2_ITEMGRD  := cItemGrd
                            SC2->C2_PRODUTO  := (cAliAglut)->PRODUTO
                            SC2->C2_EMISSAO  := dDataBase
                            SC2->C2_LOCAL    := cLocalOP
                            SC2->C2_CC  	 := SB1->B1_CC
                            SC2->C2_UM  	 := SB1->B1_UM
                            SC2->C2_PRIOR    := "500"
                            SC2->C2_DATPRI   := (cAliAglut)->INICIO
                            SC2->C2_DATPRF   := (cAliAglut)->ENTREGA
                            SC2->C2_AGLUT    := "S"
                            SC2->C2_SEGUM    := SB1->B1_SEGUM
                            SC2->C2_ROTEIRO  := (cAliAglut)->ROTEIRO
                            SC2->C2_TPOP     := (cAliAglut)->TPOP
                            SC2->C2_REVISAO  := (cAliAglut)->REVISAO
                            SC2->C2_STATUS   := "N"
                            SC2->C2_OPTERCE  := "2"
                            SC2->C2_ENSENAI  := "N"
                            SC2->C2_TPPR     := "I"
                            SC2->C2_OBS      := "Incluido aut. via Aglutinacao"
                            SC2->C2_BATCH    := "S"
                            SC2->C2_BATUSR   := cUsrAlut
                            SC2->C2_BATROT   := cFunName
                    EndIf

                    SC2->C2_QUANT    := SC2->C2_QUANT   + (cAliAglut)->QUANT
                    SC2->C2_QTSEGUM  := SC2->C2_QTSEGUM + ConvUm( (cAliAglut)->PRODUTO, (cAliAglut)->QUANT, 0, 2 )
                    // Grava sempre a MAIOR data
                    SC2->C2_DATPRI   := IIF( (cAliAglut)->INICIO  > SC2->C2_DATPRI, (cAliAglut)->INICIO , SC2->C2_DATPRI )
                    SC2->C2_DATPRF   := IIF( (cAliAglut)->ENTREGA > SC2->C2_DATPRF, (cAliAglut)->ENTREGA, SC2->C2_DATPRF )
                    MsUnlock()

                    cMsg := ""
                    dbSelectArea("SC1")
                    dbSetOrder(4)
                    If dbSeek(cFilSC1+(cAliAglut)->NUMOP)
                        cMsg += "Alteração da OP na SC "
                        While !Eof() .And. cFilSC1+(cAliAglut)->NUMOP == C1_FILIAL+C1_OP
                            dbSkip()
                            If cFilSC1+(cAliAglut)->NUMOP == C1_FILIAL+C1_OP
                                nRecno:=Recno()
                                dbSkip(-1)
                                RecLock("SC1",.F.)
                                Replace C1_OP With (cAliAglut)->OPNOVA + cItem + cSequen + cItemGrd
                                MsUnlock()
                                dbGoto(nRecno)
                            Else
                                dbSkip(-1)
                                RecLock("SC1",.F.)
                                Replace C1_OP With (cAliAglut)->OPNOVA + cItem + cSequen + cItemGrd
                                MsUnlock()
                            EndIf

                            cMsg += SC1->C1_NUM + ", "
                        EndDo
                        cMsg := Left( cMsg, Len( cMsg )-2 ) // retira a virgula e espaco no final
                        ProcLogAtu("MENSAGEM", "SC da " + (cAliAglut)->NUMOP, cMsg )
                    EndIf
                    dbSetOrder(1)

                    cMsg := ""
                    aRecnoC6 := {}
                    dbSelectArea('SC6')
                    dbSetOrder( 7 ) // C6_FILIAL + C6_NUMOP + C6_ITEMOP
                    cSeekC6 := cFilSC6 + Left((cAliAglut)->NUMOP, Len(SC6->C6_NUMOP + SC6->C6_ITEMOP)) + (cAliAglut)->PRODUTO
                    If dbSeek( cSeekC6, .F.)
                        cMsg += "Alteração da OP no PV / Item "
                        Do While !Eof() .And. C6_FILIAL + C6_NUMOP + C6_ITEMOP + C6_PRODUTO == cSeekC6
                            aAdd(aRecnoC6, Recno())
                            cMsg += SC6->C6_NUM + " / " + SC6->C6_ITEM + ", "
                            dbSkip()
                        EndDo
                        cMsg := Left( cMsg, Len( cMsg )-2 ) // retira a virgula e espaco no final
                        ProcLogAtu("MENSAGEM", "PV da " + (cAliAglut)->NUMOP, cMsg )
                    EndIf

                    For nX := 1 to Len(aRecnoC6)
                        dbSelectArea('SC6')
                        dbGoto(aRecnoC6[nX])
                        RecLock('SC6', .F.)
                            Replace C6_NUMOP  With (cAliAglut)->OPNOVA
                        MsUnlock()
                    Next

                    cMsg := ""
                    dbSelectArea('SD3')
                    dbSetOrder(1)
                    cSeekSD3 := cFilSD3 + (cAliAglut)->NUMOP
                    If dbSeek( cSeekSD3 )
                        cMsg += "Alteração da OP " +(cAliAglut)->NUMOP+" no Movimento Interno ( DOC ) "
                        Do While !Eof() .And. cSeekSD3 == D3_FILIAL + D3_OP
                            If Empty(D3_ESTORNO)
                                cMsg += SD3->D3_DOC + ", "
                                RecLock('SD3', .F.)
                                    Replace D3_OP With (cAliAglut)->OPNOVA + cItem + cSequen + cItemGrd
                                MsUnlock()
                            EndIf
                            dbSkip()
                        EndDo
                        cMsg := Left( cMsg, Len( cMsg )-2 ) // retira a virgula e espaco no final
                        ProcLogAtu("MENSAGEM", "Movimento Interno da " + (cAliAglut)->NUMOP, cMsg )
                    EndIf

                    cMsg := ""
                    dbSelectArea("SD4")
                    dbSetOrder(4) // D4_FILIAL + D4_OPORIG + D4_LOTECTL + D4_NUMLOTE
                    If dbSeek( cFilSD4 + (cAliAglut)->NUMOP)
                        cMsg += "Alteração da OP ORIGEM " +(cAliAglut)->NUMOP+" nos Empenhos " + CRLF
                        Do While !Eof() .And. cFilSD4+(cAliAglut)->NUMOP == D4_FILIAL+D4_OPORIG
                            cMsg += SD4->D4_COD + ", "
                            Reclock("SD4",.F.)
                                Replace D4_OPORIG With (cAliAglut)->OPNOVA + cItem + cSequen + cItemGrd
                                //-- Evita chave duplicada (A Chave Unica no SD4 eh D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_ORDEM+D4_OPORIG)
                                Replace D4_ORDEM  With StrZero((cAliAglut)->ORDEM, Len(D4_ORDEM))
                            MsUnlock()
                            dbSkip()
                        EndDo
                        cMsg := Left( cMsg, Len( cMsg )-2 ) // retira a virgula e espaco no final
                        ProcLogAtu("MENSAGEM", "Empenhos da " + (cAliAglut)->NUMOP, cMsg )
                    EndIf
                    
                    cMsg := ""
                    dbSelectArea("SD4")
                    dbSetOrder(2) // D4_FILIAL + D4_OP + D4_COD + D4_LOCAL
                    If dbSeek( cFilSD4 + (cAliAglut)->NUMOP)
                        cMsg += "Alteração da OP " + AllTrim((cAliAglut)->NUMOP) +" dos Empenhos " + CRLF
                        While !Eof() .And. SD4->D4_FILIAL+SD4->D4_OP == cFilSD4+(cAliAglut)->NUMOP
                            nRecSD4  := RecNo()
                            nQuantD4 := SD4->D4_QUANT
                            cProduto := SD4->D4_COD
                            cLOCAL   := SD4->D4_LOCAL
                            cTRT     := SD4->D4_TRT
                            cLote 	 := SD4->D4_NUMLOTE
                            cLoteCtl := SD4->D4_LOTECTL
                            dDtValid := SD4->D4_DTVALID
                            cOpOrig  :=	SD4->D4_OPORIG
                            cRotAglut  := SD4->D4_ROTEIRO
                            cOperAglut := SD4->D4_OPERAC
                            cProdAglut := SD4->D4_PRODUTO
                            dbSetOrder(1)
                            If dbSeek(cFilSD4+cProduto+(cAliAglut)->OPNOVA + cItem + cSequen + cItemGrd+cTRT+cLoteCtl+cLote)
                                cMsg += "Alteração da Quantidade do Produto " + SD4->D4_COD + " da OP " + (cAliAglut)->OPNOVA + CRLF
                                RecLock("SD4",.F.)
                                Replace D4_QUANT    With D4_QUANT + nQuantD4
                                Replace D4_QTDEORI  With D4_QUANT
                                Replace D4_QTSEGUM  With ConvUm(cProduto,D4_QUANT,0,2)
                            Else
                                cMsg += "Inclusão do Produto " + cProduto + " da OP " + (cAliAglut)->OPNOVA + CRLF
                                RecLock("SD4",.T.)
                                Replace D4_FILIAL 	With cFilSD4
                                Replace D4_OP     	With (cAliAglut)->OPNOVA + cItem + cSequen + cItemGrd
                                Replace D4_COD    	With cProduto
                                Replace D4_DATA     With (cAliAglut)->ENTREGA
                                Replace D4_LOCAL    With cLOCAL
                                Replace D4_QUANT  	With nQuantD4
                                Replace D4_QTDEORI  With nQuantD4
                                Replace D4_TRT      With cTRT
                                Replace D4_NUMLOTE	With cLote
                                Replace D4_LOTECTL  With cLoteCtl
                                Replace D4_DTVALID	With dDtValid
                                Replace D4_QTSEGUM  With ConvUm(cProduto,nQuantD4,0,2)
                                Replace D4_OPORIG	With cOpOrig
                                Replace D4_ROTEIRO  With cRotAglut
                                Replace D4_OPERAC   With cOperAglut
                                Replace D4_PRODUTO  With cProdAglut
                            EndIf
                            MsUnlock()
                            //dbSetOrder(2)
                            dbGoto(nRecSD4) // Posiciona no Empenho da OP antiga
                
                            cMsg += "Exclusão do Produto " + SD4->D4_COD + " da OP " + SD4->D4_OP + CRLF
                            RecLock("SD4",.F.,.T.)
                            dbDelete()
                            MsUnlock()
                            dbSkip()
                        EndDo
                        
                        ProcLogAtu("MENSAGEM", "Empenhos da " + (cAliAglut)->NUMOP, cMsg )
                    EndIf

                    cMsg := ""
                    dbSelectArea("SH8")
                    dbSetOrder(1)
                    If dbSeek(cFilSH8+(cAliAglut)->NUMOP)
                        cMsg += "Exclusão das Operações Alocadas( SH8 ) " + CRLF
                        While SH8->( .NOT. EOF() ) .And. H8_FILIAL + H8_OP == cFilSH8+(cAliAglut)->NUMOP
                            RecLock("SH8",.F.,.T.)
                                dbDelete()
                            MsUnlock()
                            SH8->( DbSkip())
                            cMsg += "Operacao " + SH8->H8_OPER + " realizada em " + DtoC( SH8->H8_DTINI ) + CRLF
                        EndDo
                        ProcLogAtu("MENSAGEM", "Operações Alocadas da " + (cAliAglut)->NUMOP, cMsg )
                    EndIf

                    cMsg := ""                
                    dbSelectArea("SC2")
                    dbSetOrder(1)
                    If dbSeek(cFilSC2+(cAliAglut)->NUMOP)
                        RecLock("SC2",.F.,.T.)   
                        dbDelete()
                        ProcLogAtu("MENSAGEM", "Exclusão da OP " + AllTrim((cAliAglut)->NUMOP) + " realizada com sucesso ", "Exclusão da OP" + AllTrim((cAliAglut)->NUMOP) + " realizada com sucesso" )
                    Else
                        ProcLogAtu("ERRO", "OP " + AllTrim((cAliAglut)->NUMOP) + " não foi excluída", "OP " + AllTrim((cAliAglut)->NUMOP) + " não foi excluída" )
                    EndIf

                End Transaction

            EndIf
        
            dbSelectArea( cAliAglut )
            DbSkip()
        EndDo // While nAglutina == (cAliAglut)->AGLUTINA
    
    EndDo // While (cAliAglut)->( .NOT. EOF() )

    ProcLogAtu("FIM")

    MsgInfo( "Finalizada a Aglutinação de OP's " )

Return
