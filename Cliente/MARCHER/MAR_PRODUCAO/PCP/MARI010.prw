#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDef.ch'
#INCLUDE 'Fileio.ch'

// Posições do array aEstrut
STATIC P_PROD      := 1
STATIC P_DESC_PROD := 2
STATIC P_COMP      := 3
STATIC P_QTDE      := 4
STATIC P_NIVEL     := 5
STATIC P_REVISAO   := 6
STATIC P_TIPO      := 7
STATIC P_UM        := 8
STATIC P_ARM_PAD   := 9
STATIC P_CTA_CONT  := 10
STATIC P_ITEM_CTA  := 11
STATIC P_COD_CLVL  := 12
STATIC P_NATUREZA  := 13
STATIC P_NCM       := 14
STATIC P_ORIGEM    := 15
STATIC P_GRP_TRIB  := 16 
STATIC P_GARANTIA  := 17
STATIC P_GRP_PROD  := 18 
STATIC P_TEM_DIF   := 19
STATIC P_OPERACAO  := 20

STATIC lPCPREVATU := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

/*/{Protheus.doc} MARI010
Rotina de importação do arquivo CSV com dados da Estrutura de Componentes
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
/*/
User Function MARI010()

    Local aSays		:= {}
    Local aButtons	:= {}
    Local nOpca		:= 0
    Local cArq      := ''
    
    Private nTipoEst  := 0
    Private cCadastro := OemToAnsi("Importação da Lista de Materiais")
    Private cTRT      := "   "
    Private aEstrut	  := {}
    Private oProcess


    aAdd(aSays,OemToAnsi('Este programa efetuará a leitura de um arquivo CSV do PDM e movimentará a Estrutura.') )
    aAdd(aSays,OemToAnsi('Layout do arquivo CSV:') )
    aAdd(aSays,OemToAnsi('1a Linha com o cabeçalho com 15 colunas sendo:') )
    aAdd(aSays,OemToAnsi('     Item; Codigo; Descricao; Qtd; Tipo; Unidade; Armazem Padrão; Cta Contábil; ') )
    aAdd(aSays,OemToAnsi('     Item Conta; Cod Cl. Valor; Natureza; NCM; Origem; Grupo Trib; Garantia; Grupo Produto') )
    aAdd(aSays,OemToAnsi('2a Linha com os dados do produto Pai') )
    aAdd(aSays,OemToAnsi('3a Linha em diante, com os dados da Estrutura/Componentes') )

    aAdd(aButtons, {  5,.T.,{|| M010Perg( @cArq ) } } )
    aAdd(aButtons, {  1,.T.,{|o| nOpca := 1, FechaBatch() }} )
    aAdd(aButtons, {  2,.T.,{|o| FechaBatch() }} )

    FormBatch( cCadastro, aSays, aButtons )

    If nOpca == 1
        If Empty( cArq ) .Or. nTipoEst <= 0
            MsgAlert( "Selecione um arquivo e informe o Tipo de estrutura desejada.", cCadastro )
        Else
            oProcess := MsNewProcess():New({|| ImportCSV( cArq ) }, cCadastro, "Processando...",.F.)
            oProcess:Activate()
        EndIf
    EndIf

Return


/*/{Protheus.doc} M010Perg
Perguntas para selecionar o arquivo e o Tipo de Estrutura que será criada/alterada
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
@param cArq, character, Caminho e Nome do arquivo
/*/
Static Function M010Perg( cArq )

    Local aParamBox := {}
    Local aRet      := {}

    aAdd(aParamBox,{6,"Selecione o arquivo:",Space(100),"","","",70,.T.,"Arquivos CSV |*.CSV", "c:\temp\"})
    aAdd(aParamBox,{3,"Tipo",2,{"Pré-estrutura","Estrutura"},50,"",.T.})

    ParamBox( aParamBox, cCadastro, @aRet,,,,,,,,.F.,.T. )

    If Len( aRet ) > 0
        cArq     := aRet[1]
        nTipoEst := aRet[2]
    EndIf

Return


/*/{Protheus.doc} ImportCSV
Rotina principal que fará a leitura do arquivos
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
@param cArq, character, Caminho e Nome do arquivo
/*/
Static Function ImportCSV( cArq )

    Local aRetSX5     := {}
    Local aNovoProd   := {}
    Local aItensArq   := {}
    Local aLog		  := {}
    Local aCab        := {}
    Local aItens      := {}
    Local aItem       := {}
    Local aExcluir    := {}
    Local dInicio     := dDataBase
    Local nAnosRevFim := SuperGetMv("ES_ANOSRFE",,30)
    Local dFim        := YearSum( dDataBase, nAnosRevFim )
    Local lEstAtual   := .F.
    Local lAchou      := .F.
    Local lTemFif     := .F.
    // Local lRevAut     := .F.
    Local cObserv     := "Importado em " +DToC( dInicio ) + " as " + Time()
    Local cLinha      := ""
    Local cProdPai    := ""
    Local cDescPrPai  := ""
    Local cRevisao	  := ""
    Local cProduto	  := ""
    Local cCompone	  := ""
    Local cNivel	  := ""
    Local cNivelPai	  := ""
    Local cBuffer     := ""
    Local cPref       := ""
    Local cRet        := ""
    Local cFilSB1	  := xFilial('SB1')
    Local cFilSBM	  := xFilial('SBM')
    Local cFilSAH	  := xFilial('SAH')
    Local cFilNNR	  := xFilial('NNR')
    Local cFilCT1     := xFilial('CT1')
    Local cFilCTD     := xFilial('CTD')
    Local cFilCTH     := xFilial('CTH')
    Local cFilSED     := xFilial('SED')
    Local cFilSYD     := xFilial('SYD')
    Local cFilSGG     := xFilial('SGG')
    Local cFilSG1     := xFilial('SG1')
    Local nPos        := 0
    Local nPosNivelPai:= 0
    Local nH          := 0
    Local nItem       := 0
    Local nLin        := 0
    Local cUltProd    := 0
    Local nQtde		  := 0
    Local nHandle     := 0
    Local nTamArq     := 0
    Local aTmBMGRUPO  := TamSX3("BM_GRUPO")
    Local aTmSYDTEC   := TamSX3("YD_TEC")
    Local aTmSEDCOD   := TamSX3("ED_CODIGO")
    Local aTmCTHCLVL  := TamSX3("CTH_CLVL")
    Local aTmCTDITEM  := TamSX3("CTD_ITEM")
    Local aTmCT1CONTA := TamSX3("CT1_CONTA")
    Local aTmNNRCOD   := TamSX3("NNR_CODIGO")
    Local aTmAHUNIMED := TamSX3("AH_UNIMED")

    Private aTmSB1COD := TamSX3("B1_COD")

    oProcess:IncRegua1( "Validando dados do arquivo " + cArq )
    
    dbSelectArea("SGG") // Pré-estrutura
    dbSetOrder(1)

    dbSelectArea("SG1") // Estrutura
    dbSetOrder(1)
    
    Begin Sequence

        nHandle := FOpen( cArq )

        If nHandle <= 0
            MsgAlert( "Não foi possível abrir o arquivo" )
            Break
        EndIf

        nTamArq := FSeek(nHandle,0,2)
        FSeek(nHandle,0,0)
	    FRead(nHandle,@cBuffer,nTamArq)
        cBuffer := cBuffer + CRLF
        FClose(nHandle)

        If Ft_FUse( cArq ) == -1
            MsgAlert( "Não foi possível abrir o arquivo" )
            Break
        EndIf
        
        ProcLogIni({},"MARI010")
        ProcLogAtu("INICIO")
        ProcLogAtu("MENSAGEM", "Etapa 1: Arquivo utilizado " + AllTrim(cArq), cBuffer )
        cBuffer := ''

        // retorna o número de linhas do arquivo
        oProcess:SetRegua1( FT_FLastRec() )
        
        // posiciona na primeira linha
        Ft_FGoTop()

        nLin := nLin + 1
        cLinha := StrTran( StrTran( StrTran( AllTrim( Ft_FReadLn() ), '"', '' ), "'", "" ), Chr(9), '' )
        aLinha := StrTokArr2(cLinha,";",.T.)
        
        If Len( aLinha ) <> 16
            // Retira o último ;
            If Right( cLinha, 1 ) == ';'
                cLinha := Left( cLinha, Len( cLinha ) - 1 )
                aLinha := StrTokArr2(cLinha,";",.T.)
            EndIf
        EndIf
        
        If Len( aLinha ) <> 16
            aAdd( aLog,  'Linha 1 - O CSV deve ter 16 colunas sendo: Nº Item; Codigo; Descricao; Qtd; Tipo; Unidade; Armazem Padrão; Cta Contábil; Item Conta; Cod Cl. Valor; Natureza; NCM; Origem; Grupo Trib; Garantia; Grupo Produto' )
        EndIf
        
        Ft_FSkip() // Pula para a Linha 2 com os dados do Produdo Pai

        cLinha   := StrTran( StrTran( StrTran( AllTrim( Ft_FReadLn() ), '"', '' ), "'", "" ), Chr(9), '' )
        aLinha   := StrTokArr2(cLinha,";",.T.)
        
        If .NOT. ( AllTrim( aLinha[ 1 ] ) == '0' .Or. Empty( aLinha[ 1 ] ) )
            aAdd( aLog, 'Linha 2- Deve estar vazia ou conter o valor 0 ( zero ) para que seja considerado como Produto Pai' )
        EndIf

        // Produto Pai fica com "0"
        If Empty( aLinha[ 1 ] )
            aLinha[ 1 ] := "0"
        EndIf

        cProdPai   := AllTrim( aLinha[ 2 ] )
        cDescPrPai := AllTrim( aLinha[ 3 ] )
        
        If Empty( cProdPai )
            aAdd( aLog, 'Código do Produto Pai deve ser informado' )
        EndIf
        
        If Empty( cDescPrPai )
            aAdd( aLog, 'Descrição do Produto Pai deve ser informado' )
        EndIf

        lAchou := .F.
        If nTipoEst == 1 // Pré-estrutura
            lAchou := SGG->( DbSeek( cFilSGG + PadR( cProdPai, TamSX3("GG_COD")[1] ) ) )
        Else // Estrutura
            lAchou := SG1->( DbSeek( cFilSG1 + PadR( cProdPai, TamSX3("G1_COD")[1] ) ) )
        EndIf

        // Carrega os dados para que depois possa fazer a comparação
        If lAchou
            lEstAtual := .T.
        Else
            // Se o material não existe, pode ser que seja novo
            If .NOT. SB1->( DbSeek( cFilSB1 + PadR( cProdPai, aTmSB1COD[1] ) ) )
                aAdd( aNovoProd, aLinha )
            Else // Não tem Estrutura mas tem Produto, então seta aqui para mostrar na tela os dados
                lEstAtual := .T.
            EndIf
        EndIf

        cLinha	:= ''

        dbSelectArea("SB1")
        dbSetOrder(1)

        dbSelectArea("SBM")
        dbSetOrder(1) // BM_FILIAL + BM_GRUPO

        dbSelectArea("SAH")
        dbSetOrder(1) // AH_FILIAL + AH_UNIMED

        dbSelectArea("NNR")
        dbSetOrder(1) // NNR_FILIAL + NNR_CODIGO

        dbSelectArea("CT1")
        dbSetOrder(1) // CT1_FILIAL + CT1_CONTA

        dbSelectArea("CTD")
        dbSetOrder(1) // CTD_FILIAL + CTD_ITEM

        dbSelectArea("CTH")
        dbSetOrder(1) // CTH_FILIAL + CTH_CLVL

        dbSelectArea("SED")
        dbSetOrder(1) // ED_FILIAL + ED_CODIGO
        
        dbSelectArea("SYD")
        dbSetOrder(1) // YD_FILIAL + YD_TEC
        
        While !Ft_FEof()

            nLin := nLin + 1
            lContinua := .T.

            oProcess:IncRegua1( "Lendo linha " + cValToChar( nLin ) )

            cLinha := StrTran( AllTrim( Ft_FReadLn() ), Chr(9), '' ) // Retira o TAB
            // cLinha := StrTran( StrTran( StrTran( AllTrim( Ft_FReadLn() ), '"', '' ), "'", "" ), Chr(9), '' )
            aLinha := StrTokArr(cLinha,";") // Essa função padrão retorna somente as celulas com conteúdo !

            If Len( aLinha ) <> 16
                // Retira o último ;
                If Right( cLinha, 1 ) == ';'
                    cLinha := Left( cLinha, Len( cLinha ) - 1 )
                    aLinha := StrTokArr2(cLinha,";",.T.)
                EndIf
            EndIf

            // testa todas as linhas para verificar algum erro de conteúdo de coluna com o delimitador
            If Len( aLinha ) <> 16
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' deve ter 16 colunas' )
                Ft_FSkip()
                Loop
            EndIf
            
            // Componente sem código
            If Empty( aLinha[ 2 ] )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' não tem Código de Componente' )
                lContinua := .F.
            EndIf

            // Valida a quantidade
            If Val( StrTran( StrTran( aLinha[ 4 ], '.', '' ), ',', '.' ) ) <= 0
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' com Quantidade menor ou igual a zero' )
                lContinua := .F.
            EndIf

            // Valida o Tipo
            If Empty( aLinha[ 5 ] )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' não tem o Tipo informado' )
                lContinua := .F.
            Else
                aRetSX5 := FWGetSX5( '02', PadR( AllTrim(aLinha[ 5 ]), 6 ) )
                If Len( aRetSX5 ) <= 0
                    aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Tipo ' + AllTrim( aLinha[ 5 ] ) + ' que não está cadastrado' )
                    lContinua := .F.
                EndIf
            EndIf

            // Valida a Unidade
            If .NOT. SAH->( DbSeek( cFilSAH + PadR( AllTrim( aLinha[ 6 ] ), aTmAHUNIMED[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Unidade ' + AllTrim( aLinha[ 6 ] ) + ' que não está cadastrado' )
                lContinua := .F.
            EndIf

            // Valida o Armazem Padrão
            If .NOT. NNR->( DbSeek( cFilNNR + PadR( AllTrim( aLinha[ 7 ] ), aTmNNRCOD[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Armazem ' + AllTrim( aLinha[ 7 ] ) + ' que não está cadastrado'  )
                lContinua := .F.
            EndIf
            
            // Valida a Cta Contábil
            If .NOT. CT1->( DbSeek( cFilCT1 + PadR( AllTrim( aLinha[ 8 ] ), aTmCT1CONTA[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Cta Contabil ' + AllTrim( aLinha[ 8 ] ) + ' que não está cadastrada' )
                lContinua := .F.
            EndIf
            
            // Valida o Item Conta
            If .NOT. CTD->( DbSeek( cFilCTD + PadR( AllTrim( aLinha[ 9 ] ), aTmCTDITEM[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Item Conta ' + AllTrim( aLinha[ 9 ] ) + ' que não está cadastrada' )
                lContinua := .F.
            EndIf
            
            // Valida Cod Cl. Valor
            If .NOT. CTH->( DbSeek( cFilCTH + PadR( AllTrim( aLinha[ 10 ] ), aTmCTHCLVL[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Cod Cl. Valor ' + AllTrim( aLinha[ 10 ] ) + ' que não está cadastrada' )
                lContinua := .F.
            EndIf
            
            // Valida Natureza
            If .NOT. SED->( DbSeek( cFilSED + PadR( AllTrim( aLinha[ 11 ] ), aTmSEDCOD[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Natureza ' + AllTrim( aLinha[ 11 ] ) + ' que não está cadastrada' )
                lContinua := .F.
            EndIf

            // Valida NCM
            If .NOT. SYD->( DbSeek( cFilSYD + PadR( AllTrim( aLinha[ 12 ] ), aTmSYDTEC[1] ) ) )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem NCM ' + AllTrim( aLinha[ 12 ] ) + ' que não está cadastrada' )
                lContinua := .F.
            EndIf

            // Valida Origem
            If Empty( aLinha[ 13 ] )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' não tem a Origem informada' )
                lContinua := .F.
            Else
                aRetSX5 := FWGetSX5( 'S0', PadR( AllTrim(aLinha[ 13 ]), 6 ) )
                If Len( aRetSX5 ) <= 0
                    aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Origem ' + AllTrim( aLinha[ 13 ] ) + ' que não está cadastrada' )
                    lContinua := .F.
                EndIf
            EndIf

            // Valida Grupo Trib
            If Empty( aLinha[ 14 ] )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' não tem o Grupo Trib informado' )
                lContinua := .F.
            Else
                aRetSX5 := FWGetSX5( '21', PadR( AllTrim(aLinha[ 14 ]), 6 ) )
                If Len( aRetSX5 ) <= 0
                    aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Grupo Trib ' + AllTrim( aLinha[ 14 ] ) + ' que não está cadastrado' )
                    lContinua := .F.
                EndIf
            EndIf

            // Valida Garantia
            cRet := Upper( Left( AllTrim( aLinha[ 15 ] ), 1 ) )
            If .NOT. (cRet $ "1/2/S/N")
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Garantia ' + AllTrim( aLinha[ 15 ] ) + ' que não está cadastrado' )
                lContinua := .F.
            EndIf

            // Valida Grupo Produto
            If Empty( aLinha[ 16 ] )
                aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' não tem o Grupo Produto informado' )
                lContinua := .F.
            Else
                If .NOT. SBM->( DbSeek( cFilSBM + PadR( AllTrim( aLinha[ 16 ] ), aTmBMGRUPO[1] ) ) )
                    aAdd( aLog, 'Linha ' + cValToChar( nLin ) + ' contem Grupo Produto ' + AllTrim( aLinha[ 16 ] ) + ' que não está cadastrado' )
                    lContinua := .F.
                EndIf
            EndIf

            // Passou por todas as validações então carrega no array
            If lContinua
                
                // Ajusta o conteúdo que será gravado no campo B1_GARANT
                aLinha[15] := IIF( cRet $ '1/S', '1', '2' )

                If .NOT. SB1->( DbSeek( cFilSB1 + PadR( AllTrim( aLinha[ 2 ] ), aTmSB1COD[1] ) ) )
                    aAdd( aNovoProd, aLinha )
                EndIf

                aAdd( aItensArq, aLinha )
            EndIf

            Ft_FSkip()
        EndDo
        
        Ft_FUse()

        If Len( aLog ) > 0
            cBuffer := ''
            aEval(aLog,{|x| cBuffer += x + CRLF })
            ProcLogAtu("MENSAGEM", "Etapa 2: Validação dos dados - ERRO", cBuffer )
            
            MsgAlert("Foram localizadas inconsistências no arquivo CSV, para mais detalhes favor olhar os LOG's", cCadastro )
            Break
        EndIf

        oProcess:SetRegua2(Len(aItensArq))
        cRevisao := ""

        If nTipoEst == 1 // Pré-estrutura - SGG
            cPref := "GG"
        Else // Estrutura - SG1
            cPref := "G1"
        EndIf

        For nItem := 1 to Len( aItensArq )

            oProcess:IncRegua2( "Montando... " + aItensArq[ nItem, 2 ] )
        
            // Produto Pai desconsidera
            If AllTrim( aItensArq[ nItem, 1 ] ) == "0"
                Loop // Desconsidera o Produto Pai na montagem da Estrutura
            EndIf
        
            cNivel	 := aItensArq[ nItem, 1 ]
            cCompone := AllTrim( aItensArq[ nItem, 2 ] )
            nQtde	 := Val( StrTran( StrTran( aItensArq[ nItem, 4 ], '.', '' ), ',', '.' ) )


            nPos := RAt( ".", cNivel ) // Procura o último ponto no nível
            cProduto  := ""
            cNivelPai := ""

            If nPos > 0

                cNivelPai := Left( AllTrim( aItensArq[ nItem, 1 ] ), nPos-1 )
                
                // Busca a posição do Nivel PAI
                nPos := aScan( aItensArq, {|x| AllTrim( x[1] ) == cNivelPai } )
                
                If nPos > 0
                    // Pega o Produto Pai conforme o nível
                    cProduto := AllTrim( aItensArq[ nPos, 2 ] )
                Else
                    // Não encontrou o nível Pai, então o Produto Pai será conforme o item zero do arquivo !
                    cProduto := AllTrim( cProdPai )
                EndIf
            
            Else // Só tem um nível então o Produto será o Produto Pai
                cProduto := AllTrim( cProdPai )
            EndIf

            /*
            Exemplo de arquivo CSV:

            Item	    Código	                Descricao
            0	        98989	                Produto PAI XYZ
            1	        03003071	            CJ. MONT. CAPUZ
            1.1	        03002147	            CJ. CAPUZ E ESTRUTURA INGRAIN 100
            1.1.1	    03002148	            CJ. SOL. CHASSI
            1.1.1.1	    03001611	            TUBO
            1.1.1.2	    03001158	            TUBO
            1.1.1.3	    03001614	            PERFIL ESQ.
            1.1.1.4	    03001615	            PERFIL DIR.
            1.1.1.5	    03001616	            CHAPA SUPERIOR
            1.1.1.6	    03001617	            CHAPA ESQ.
            1.1.1.7	    03001620	            REFORÇO
            1.1.1.8	    03001621	            PERFIL FRONTAL
            1.1.1.9	    08201022	            SUPORTE CENTRAL
            1.1.1.10	03001622	            SUPORTE LATERAL
            1.1.1.11	03001623	            CHAPA LATERAL
            1.1.1.12	03001625	            PERFIL LATERAL
            1.1.1.13	03001780	            REFORÇO
            1.1.1.14	03001631	            PASSA MANGUEIRA
            1.1.1.15	09001662	            APOIO MACACO ELEVAÇÃO
            1.1.1.16	03001766	            CHAPA REFORÇO
            1.1.1.17	0004700000607033	    PORCA SOLD. SEXT. M12 MA  DIN929
            1.1.1.18	03001779	            REFORÇO
            1.1.1.19	03001781	            FLANGE
            1.1.1.20	03001619	            PINO GUIA
            1.1.1.21	03001783	            CHAPA
            1.1.1.22	03001784	            REFORÇO
            1.1.1.23	03001869	            CHAPA
            1.1.1.24	03001870	            CHAPA
            1.1.2	    09001662	            APOIO MACACO ELEVAÇÃO
            1.1.3	    03002149	            CJ. SOL. CAPUZ
            1.1.3.1	    03001634	            CAPUZ
            1.1.3.2	    03001147	            TUBO CAPUZ
            1.1.3.3	    03001635	            TUBO REFORÇO
            1.1.3.4	    03001636	            CHAPA SUPORTE CARACOL
            1.1.3.4.1		
            1.1.3.5	    03001637	            CHAPA INCLINAÇÃO
            1.1.3.6	    03001227	            REFORÇO
            1.1.3.7	    03001638	            REFORÇO
            1.1.3.8	    02101099	            GANCHO
            1.1.3.9	    00180100207000300431	PARAF. SEXT. M6x20mm MA RT 8.8 ZB
            1.1.3.10	03001802	            TAMPA 1. 1/4"
            1.1.4	    03002150	            CJ. SOL. SUPORTE GUINCHO
            1.1.4.1	    03001639	            TUBO LATERAL
            1.1.4.2	    03001640	            TUBO SUPERIOR
            1.1.4.3	    03001641	            OLHAL FIXAÇÃO
            1.1.4.4	    03001631	            PASSA MANGUEIRA
            1.1.5	    03002146	            CJ. SOL. SUPORTE ESQ. MANIVELA
            1.1.5.1	    03001603	            SUPORTE ESQ.
            1.1.5.2	    03001604	            GUIA
            1.1.5.3	    03002151	            CJ. SOL. PINO
            1.1.5.3.1	03001642	            PINO 
            1.1.5.3.2	09001420	            GUIA LATERAL
            1.1.5.4     000411100080731	        PORCA AUTOTRAV. BAIXA M16 ZB
            1.1.6	    03002152	            CJ. SOL. SUPORTE DIR. MANIVELA
            1.1.6.1     03001643	            SUPORTE DIR.
            1.1.6.2     03001604	            GUIA
            1.1.6.3     03002151	            CJ. SOL. PINO
            1.1.6.3.1	03001642	            PINO 
            1.1.6.3.2	09001420	            GUIA LATERAL
            1.1.6.4	    000411100080731	        PORCA AUTOTRAV. BAIXA M16 ZB
            1.1.7	    03001644	            REFORÇO ESQ.
            1.1.8	    03001646	            REFORÇO
            1.1.9	    03001647	            SUPORTE BANDEJA
            1.1.10	    03001764	            MEIA-ARGOLA- 57 X 9
            1.2	        03001649	            LONA DE RETENÇÃO
            1.3	        06001061	            BARRA FIX. LONA RETENÇÃO
            1.4	        100034	                BORRACHA DE ACABAMENTO
            1.5	        100033	                VISOR
            1.6	        03003072	            CJ. MONT. PROTEÇÃO
            1.6.1	    03001259	            PROTEÇÃO
            1.6.1.1		
            1.6.2	    101244	                RELÉ GUINCHO
            1.6.3	    00031100021	            ARRUELA LISA M5 ZB
            1.6.4	    00181113000003300200	PARAF. AUTO BROCANTE CAB. PANELA Ø4,2x16mm
            1.7	        00031100031	            ARRUELA LISA M6 ZB
            1.8	        000411100030721	        PORCA AUTOTRAV. BAIXA M6 MA ZB
            1.9	        0028010703	            REBITE POP Ø 6.2 x 20mm
            2	        03003073	            CJ. MONT. TUBO/MOEGA
            2.1	        03003074	            CJ. MONT. CARACOL
            2.1.1	    03002153	            CJ. SOL. CANO MOEGA
            2.1.1.1	    03001650	            CAMISA
            2.1.1.2	    03001651	            FLANGE
            2.1.1.3	    03001652	            CHAPA FRONTAL
            2.1.1.4	    03001653	            FECHAMENTO CANO
            2.1.1.5	    03001654	            COMPLEMENTO
            2.1.1.6	    03001012	            TUBO DOBRADIÇA
            */
            

            If .NOT. Empty( cProduto )

                nH := aScan( aNovoProd, {|x| AllTrim(x[2]) == AllTrim(cCompone) } )

                // Se o componente está no array de Novos Produtos, então tem que marcar como .T. para
                // que seja feita a chamada das rotinas automáticas de inclusão da Pre-Estrutura ou Estrutura.
                lTemFif := nH > 0
                
                // Valida se o Componente está duplicado dentro da própria estrutura
                If .NOT. Empty( cNivelPai )
                    nPosNivelPai := aScan( aEstrut, {|x| x[P_NIVEL] == cNivelPai } )
                    If nPosNivelPai > 0
                        If aScan( aEstrut, {|x| x[P_PROD] == cProduto .And. x[P_COMP] == cCompone }, nPosNivelPai ) > 0
                            ProcLogAtu("ERRO", "Etapa 2: Validação dos dados - ERRO", "Componente " + cCompone + " ( nivel " + cNivel + " ) duplicado para o Produto Pai " + cProduto + " ( nivel " + cNivelPai + " )" )
                            
                            MsgAlert("Foram localizadas inconsistências no arquivo CSV, para mais detalhes favor olhar os LOG's", cCadastro )
                            Break
                        EndIf
                    EndIf
                EndIf

                // Carrega o array aEstrut
                AddAEstrut( cProduto,;
                            aItensArq[ nItem, 3 ] /*Descrição*/,;
                            cCompone,;
                            nQtde,;
                            cNivel,;
                            cRevisao,;
                            aItensArq[ nItem, 5 ] /*Tipo*/,;
                            aItensArq[ nItem, 6 ] /*UM*/,;
                            aItensArq[ nItem, 7 ] /*Armazem Padrão*/,;
                            aItensArq[ nItem, 8 ] /*Cta Contabil*/,;
                            aItensArq[ nItem, 9 ] /*Item Conta*/,;
                            aItensArq[ nItem, 10] /*Cod Cl. Valor*/,;
                            aItensArq[ nItem, 11] /*Natureza*/,;
                            aItensArq[ nItem, 12] /*NCM*/,;
                            aItensArq[ nItem, 13] /*Origem*/,;
                            aItensArq[ nItem, 14] /*Grupo Trib*/,;
                            aItensArq[ nItem, 15] /*Garantia*/,;
                            aItensArq[ nItem, 16] /*Grupo Produto*/,;
                            lTemFif,;
                            3/*nOperacao*/ )
                /*
                Posições do array aEstrut
                STATIC P_PROD      := 1
                STATIC P_DESC_PROD := 2
                STATIC P_COMP      := 3
                STATIC P_QTDE      := 4
                STATIC P_NIVEL     := 5
                STATIC P_REVISAO   := 6
                STATIC P_TIPO      := 7
                STATIC P_UM        := 8
                STATIC P_ARM_PAD   := 9
                STATIC P_CTA_CONT  := 10
                STATIC P_ITEM_CTA  := 11
                STATIC P_COD_CLVL  := 12
                STATIC P_NATUREZA  := 13
                STATIC P_NCM       := 14
                STATIC P_ORIGEM    := 15
                STATIC P_GRP_TRIB  := 16 
                STATIC P_GARANTIA  := 17
                STATIC P_GRP_PROD  := 18 
                STATIC P_TEM_DIF   := 19
                STATIC P_OPERACAO  := 20
                */            
            Else
                ProcLogAtu("ERRO", "Etapa 2: Validação dos dados - ERRO", "Componente " + cCompone + " sem Produto Pai do arquivo CSV lido" )
                MsgAlert("Foram localizadas inconsistências no arquivo CSV, para mais detalhes favor olhar os LOG's", cCadastro )
                Break
            EndIf
        Next nItem

        // Até aqui são validações no arquivo como conteúdo e estrutura.
        ProcLogAtu("MENSAGEM", "Etapa 2: Validação dos dados - OK " )

        // TESTE
        // ProcLogAtu("MENSAGEM", "Etapa 3: Final da validação" )
        // Break

        /*##################################################################################################################
        IMPORTANTE:
        A partir desse ponto o array aItensArq não deve ser mais utilizado !
        O array aEstrut contem todos os dados que estão no arquivo CSV e também toda a estrutura de "Produto x Componentes".
        ###################################################################################################################*/

        // Somente cria uma nova revisão se o usuário autorizar !
        If lEstAtual

            aDadosDif := CarregaDados( cProdPai, @aEstrut )
            nPos      := 0

            // Se pelo menos um Componente que tem diferença então sai do Loop para seguir
            For nH := 1 To Len( aEstrut )
                If aEstrut[nH, P_TEM_DIF]
                    nPos := nPos + 1
                    Exit
                EndIf
            Next

            // Quando um componente não está no arquivo, terá diferenças de tamanho dos arrays
            If Len( aDadosDif ) <> Len( aEstrut )
                nPos := nPos + 1
            EndIf

            // Se nenhumm componente teve diferenças, informa aqui e sai da rotina
            If nPos <= 0
                ProcLogAtu("MENSAGEM", "Etapa 3: Não existem diferenças de Materiais", cProdPai + " - " + cDescPrPai )
                Break
            EndIf

            If .NOT. MsgNoYes( 'Já existe ' +IIF(nTipoEst==1, 'Pré-estrutura', 'Estrutura')+ ' cadastrada para o produto ' +cProdPai+ ' no sistema, deseja realizar uma nova revisão ?', cCadastro )
                ProcLogAtu("MENSAGEM", "Etapa 3: Material já existe e usuário NÃO aprovou atualização", cProdPai + " - " + cDescPrPai )
                Break
            Else
                ProcLogAtu("MENSAGEM", "Etapa 3: Material já existe e usuário Aprovou atualização", cProdPai + " - " + cDescPrPai )
            EndIf

            // Se o usuário não confirmar a diferença nas estruturas, não irá fazer nada !!
            If .NOT. MostraEstrutuas( cProdPai, aDadosDif )
                ProcLogAtu("MENSAGEM", "Etapa 3: Usuário cancelou a importação na análise das diferenças", cProdPai + " - " + cDescPrPai )
                Break
            Else
                ProcLogAtu("MENSAGEM", "Etapa 3: Usuário aprovou a análise das diferenças", cProdPai + " - " + cDescPrPai )
            EndIf
        Else
            ProcLogAtu("MENSAGEM", "Etapa 3: Material será cadastrado", cProdPai + " - " + cDescPrPai )
        EndIf

        // Se tem algum produto NOVO, deverá fazer a inclusão aqui !        
        If Len( aNovoProd ) > 0
            
            cBuffer := ''

            // A rotina abaixo carrega o array aLog com os erros ou com os Produtos Incluídos.
            If .NOT. CriaProd( cArq, aNovoProd, @aLog )

                aEval(aLog,{|x| cBuffer += x + CRLF })
                ProcLogAtu("MENSAGEM", "Etapa 4: Criação de Produtos - ERRO", cBuffer )
                Break
            EndIf
            
            aEval(aLog,{|x| cBuffer += x + CRLF })
            ProcLogAtu("MENSAGEM", "Etapa 4: Criação de Produtos - OK", cBuffer )

        Else
            ProcLogAtu("MENSAGEM", "Etapa 4: Sem criação de novos Produtos" )
        EndIf
   
        oProcess:SetRegua2( Len( aEstrut ) )

        aCab		:= {}
        aItens		:= {}
        aItem		:= {}
        aExcluir    := {}
        cUltProd    := "XYZ"
        cRevisao    := ""

        // Ordena pelo Produto pai
        aEstrut := aSort( aEstrut,,,{ |x,y| x[P_PROD] < y[P_PROD] } )

        For nH := 1 To Len( aEstrut )

            oProcess:IncRegua2("Gravando... " + aEstrut[nH,P_COMP])

            // Exclusão
            If aEstrut[nH,P_OPERACAO] == 5
                
                // Busca o Produto Pai no array para somar a quantidade de componentes que devem ser excluídos
                nPos := aScan( aExcluir, {|x| x[1] == aEstrut[nH,P_PROD] } )
                If nPos <= 0
                    /*
                    Posições do array aExcluir
                    1 - Codigo do Produto Pai
                    2 - Quantidade de Componentes que devem ser excluídos
                    3 - Quantidade de Componentes existentes para o Produto pai
                    */
                    AADD( aExcluir,{ aEstrut[nH,P_PROD], 1, 1 } )
                Else
                    aExcluir[nPos,2]++
                    aExcluir[nPos,3]++
                EndIf
                // Exclusão não processa
                Loop
            EndIf
       
            If cUltProd <> aEstrut[nH,P_PROD]

                If !Empty( aItem )
                    GravaEstrut( aCab, aItem )
                EndIf
                cNivel	 := aEstrut[nH,P_NIVEL]

                aCab	 := {{ cPref+'_COD'		, PadR(aEstrut[nH,P_PROD],aTmSB1COD[1]) , NIL },;
                             { cPref+'_QUANT'	, 1					                    , NIL },;
                             { "ATUREVSB1"      , "S"                                   , NIL },; //Variável é utilizada para gerar nova revisão.
                             { "AUTREVPAI"      , cRevisao                              , NIL },; //Variável AUTREVPAI é utilizada para indicar qual a revisão do produto pai será considerada.
                             { "NIVALT"     	, "S"				                    , NIL }}
                
                aItens	 := {}
                aItem	 := {}
                cUltProd := aEstrut[nH,P_PROD]
            EndIf

            // Pega o TRT atual para Alteração e para Inclusão deverá pegar o proximo
            cTRT := GetTrt( aCab[ 1, 2 ], PadR(aEstrut[nH,P_COMP],aTmSB1COD[1]) )
            
            aAdd( aItens, { cPref+'_COD'	 , PadR(aEstrut[nH,P_PROD],aTmSB1COD[1]), NIL } )
            aAdd( aItens, { cPref+'_COMP'	 , PadR(aEstrut[nH,P_COMP],aTmSB1COD[1]), NIL } )
            aAdd( aItens, { cPref+'_TRT'	 , cTRT			                        , NIL } )
            aAdd( aItens, { cPref+'_QUANT'	 , aEstrut[nH,P_QTDE]                   , NIL } )
            aAdd( aItens, { cPref+'_INI'	 , dInicio    		                    , NIL } )
            aAdd( aItens, { cPref+'_FIM'	 , dFim                                 , NIL } )
            aAdd( aItens, { cPref+'_OBSERV'  , cObserv                              , NIL } )
            aAdd( aItens, { cPref+'_REVINI'  , cRevisao                             , NIL } )
            aAdd( aItens, { cPref+'_REVFIM'  , cRevisao                             , NIL } )

            AADD( aItem, aItens )
            aItens := {}


            nPos := aScan( aExcluir, {|x| x[1] == aEstrut[nH,P_PROD] } )
            If nPos <= 0
                /*
                Posições do array aExcluir
                1 - Codigo do Produto Pai
                2 - Quantidade de Componentes que devem ser excluídos
                3 - Quantidade de Componentes existentes para o Produto pai
                */
                AADD( aExcluir,{ aEstrut[nH,P_PROD], 0, 0 } )
                nPos := Len( aExcluir )
            EndIf

            If aEstrut[nH,P_OPERACAO] == 5
                aExcluir[nPos,2]++
            EndIf
            aExcluir[nPos,3]++

        Next nH

        If !Empty( aItem )
            GravaEstrut( aCab, aItem )
        EndIf

        For nH := 1 To Len( aExcluir )

            // Todos os Componentes devem ser excluídos.
            If aExcluir[nH,2] == aExcluir[nH,3]

                // Função padrão que cria uma nova Revisão e atualiza o cadastro do Produto.
                A200Revis( aExcluir[nH,1], .F./*lShow*/ )
            EndIf
        Next        

        oProcess:SetRegua2( Len( aNovoProd ) )

        // Jorge Alberto - Solutio - 19/08/2021 - Em reunião com Zago e Válter, foi solicitado que o produto permaneca desbloqueado.

        // Todos os novos produtos que foram incluídos Desbloqueados, deverão ser bloqueados agora
        // For nH := 1 To Len( aNovoProd )

        //     If SB1-> ( dbSeek( cFilSB1 + PadR( AllTrim( aNovoProd[ nH, 2] ), aTmSB1COD[1] ) ) )

        //         oProcess:IncRegua2("Bloqueando novo Produto " + aNovoProd[ nH, 2] )

        //         oModel := FwLoadModel("MATA010")
        //         oModel:SetOperation(MODEL_OPERATION_UPDATE)
        //         oModel:Activate()
        //         oModel:SetValue( "SB1MASTER", "B1_MSBLQL"  ,'1' ) // Produto Bloqueado !

        //         If oModel:VldData()
        //             oModel:CommitData()
        //         Else
        //             ProcLogAtu( "ERRO", "Etapa 4: Erro na operação de bloquear Produto " + AllTrim(aNovoProd[ nH, 2]), oModel:GetErrorMessage() )
        //         EndIf       

        //         oModel:DeActivate()
        //         oModel:Destroy()
        //         FreeObj( oModel )
        //         oModel := NIL
        //     EndIf
        // Next

    End Sequence

    ProcLogAtu("FIM")

Return


/*/{Protheus.doc} CriaProd
Cria o Produto no Protheus
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 04/08/2021
@param cArq, character, Nome do arquivo importado
@param aNovoProd, array, Dados dos Produtos
@return logical, .T. se todos os produtos foram importados, .F. se pelo menos UM produto teve erro
/*/
Static Function CriaProd( cArq, aNovoProd, aLog )

    Local lOk    := .T.
    Local nReg   := 0
    Local oModel := Nil
    Local aErro  := {}
    Local cErro  := ""
    Local cProd  := ""

    Private lMsErroAuto := .F.

    oProcess:SetRegua2( Len( aNovoProd ) )

    For nReg := 1 To Len( aNovoProd )

        oProcess:IncRegua2("Incluindo Produto " + aNovoProd[ nReg, 2] )
            
        If cProd <> aNovoProd[ nReg, 2]

            oModel := FwLoadModel("MATA010")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate()
            oModel:SetValue( "SB1MASTER", "B1_COD"     ,aNovoProd[ nReg, 2] )
            oModel:SetValue( "SB1MASTER", "B1_DESC"    ,aNovoProd[ nReg, 3] )
            oModel:SetValue( "SB1MASTER", "B1_ESPECIF" ,aNovoProd[ nReg, 3] )
            oModel:SetValue( "SB1MASTER", "B1_TIPO"    ,aNovoProd[ nReg, 5] )
            oModel:SetValue( "SB1MASTER", "B1_UM"      ,aNovoProd[ nReg, 6] )
            oModel:SetValue( "SB1MASTER", "B1_LOCPAD"  ,aNovoProd[ nReg, 7] )
            oModel:SetValue( "SB1MASTER", "B1_CONTA"   ,aNovoProd[ nReg, 8] )
            oModel:SetValue( "SB1MASTER", "B1_ITEMCC"  ,aNovoProd[ nReg, 9] )
            oModel:SetValue( "SB1MASTER", "B1_CLVL"    ,aNovoProd[ nReg,10] )
            oModel:SetValue( "SB1MASTER", "B1_NATUREZ" ,aNovoProd[ nReg,11] )
            oModel:SetValue( "SB1MASTER", "B1_POSIPI"  ,aNovoProd[ nReg,12] )
            oModel:SetValue( "SB1MASTER", "B1_ORIGEM"  ,aNovoProd[ nReg,13] )
            oModel:SetValue( "SB1MASTER", "B1_GRTRIB"  ,aNovoProd[ nReg,14] )
            oModel:SetValue( "SB1MASTER", "B1_GARANT"  ,aNovoProd[ nReg,15] )
            oModel:SetValue( "SB1MASTER", "B1_GRUPO"   ,aNovoProd[ nReg,16] )
            oModel:SetValue( "SB1MASTER", "B1_CODREV"  ,"001"               )
            oModel:SetValue( "SB1MASTER", "B1_MSBLQL"  ,"2"                 ) // Produto Desbloqueado

            If oModel:VldData()
                oModel:CommitData()
                aAdd( aLog, 'Produto ' + AllTrim(aNovoProd[ nReg, 2]) + ' incluído com sucesso !' )

                oModel:DeActivate()
                oModel:Destroy()
                FreeObj( oModel )
                
                // MVC da rotina de Complemento de Produto
                oModel := FwLoadModel("MATA180")
                oModel:SetOperation(MODEL_OPERATION_INSERT)
                oModel:Activate()
                oModel:SetValue("SB5MASTER","B5_COD"    ,aNovoProd[ nReg, 2] )
                oModel:SetValue("SB5MASTER","B5_CEME"   ,aNovoProd[ nReg, 3] )

                If oModel:VldData()
                    oModel:CommitData()
                    aAdd( aLog, 'Complemento do Produto incluído com sucesso ("SB5") !' )
                Else
                    aErro := oModel:GetErrorMessage()

                    cErro := aErro[MODEL_MSGERR_IDFORM]+": "+;
                            aErro[MODEL_MSGERR_IDFIELD]+": "+;
                            aErro[MODEL_MSGERR_IDFORMERR]+": "+;
                            aErro[MODEL_MSGERR_IDFIELDERR]+": "+;
                            aErro[MODEL_MSGERR_ID]+" "+;
                            aErro[MODEL_MSGERR_MESSAGE]+" / "+aErro[MODEL_MSGERR_SOLUCTION]

                    aAdd( aLog, 'Erro ao incluir complemento do Produto na SB5: ' + cErro )
                EndIf
            Else
                aErro := oModel:GetErrorMessage()

                cErro := aErro[MODEL_MSGERR_IDFORM]+": "+;
                        aErro[MODEL_MSGERR_IDFIELD]+": "+;
                        aErro[MODEL_MSGERR_IDFORMERR]+": "+;
                        aErro[MODEL_MSGERR_IDFIELDERR]+": "+;
                        aErro[MODEL_MSGERR_ID]+" "+;
                        aErro[MODEL_MSGERR_MESSAGE]+" / "+aErro[MODEL_MSGERR_SOLUCTION]

                aAdd( aLog, 'Erro na Inclusão do Produto ' + AllTrim(aNovoProd[ nReg, 2]) + ': ' + cErro )
                lOk := .F.
            EndIf       

            oModel:DeActivate()
            oModel:Destroy()
            FreeObj( oModel )
                    
            cProd := aNovoProd[ nReg, 2] 
        EndIf

    Next

Return( lOk )


/*/{Protheus.doc} MostraEstrutuas
Rotina que irá montar um browse com os Componentes gravados e o que está no CSV.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
@param cProd, character, Produto pai
@param aDados, array, Dados com as diferenças e com as igualdades
/*/
Static Function MostraEstrutuas( cProd, aDados )

    Local lOk       := .F.
    Local nOpcA     := 0
    Local cPictQtd  := X3Picture("G1_QUANT")
    Local oDlg
    Local oBrowse
    Local oSize     
    Local oCinza    := LoadBitmap(GetResources(),'BR_CINZA')
    Local oVerde    := LoadBitmap(GetResources(),'BR_VERDE')
    Local oAmarelo  := LoadBitmap(GetResources(),'BR_AMARELO')
    Local oVermelho := LoadBitmap(GetResources(),'BR_VERMELHO')
    Local oPink     := LoadBitmap(GetResources(),'BR_PINK')
    Local aBotoes   := {;
                        { "S4WB004N", { || BrwLeg() }, "&Legenda" , "Legenda"  };
                        }

    oSize := FwDefSize():New( .T. )
	oSize:AddObject( "GERAL", 100, 100, .T., .T. )
	oSize:Process()
    
    oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],IIF(nTipoEst==1, 'Pré-estrutura', 'Estrutura'),,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T./*lPixel*/,,,,.T./*lTransparent*/ )

    oBrowse := TCBrowse():New(  oSize:GetDimension("GERAL","LININI"),;
                                oSize:GetDimension("GERAL","COLINI"),;
                                oSize:GetDimension("GERAL","XSIZE"),;
                                oSize:GetDimension("GERAL","YSIZE"),,,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

    oBrowse:aHeaders  := {"","Item","Comp. ATUAL","Desc. ATUAL","Quant. ATUAL","Comp. NOVO","Desc. NOVO","Quant. NOVO" }
    oBrowse:setArray( aDados )
    oBrowse:bLine := {||{IIf( Empty(aDados[oBrowse:nAt,6]), oVermelho,;
                            IIF( Empty(aDados[oBrowse:nAt,3]), oVerde,;
                                IIF( aDados[oBrowse:nAt,4] <> aDados[oBrowse:nAt,7], oPink,;
                                    IIF( aDados[oBrowse:nAt,5] <> aDados[oBrowse:nAt,8], oAmarelo, oCinza ) ) ) ),;
                        aDados[oBrowse:nAt,2],;
                        aDados[oBrowse:nAt,3],;
                        aDados[oBrowse:nAt,4],;
                        Transform( aDados[oBrowse:nAt,5], cPictQtd ),;
                        aDados[oBrowse:nAt,6],;
                        aDados[oBrowse:nAt,7],;
                        Transform( aDados[oBrowse:nAt,8], cPictQtd ) } }

    oBrowse:nAt := 1
    //oBrowse:bLDblClick := {|| SelLine( oBrowse:nAt )}

    oDlg:Activate(,,,,EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End() },{||oDlg:End() },,aBotoes))

    If nOpcA == 1
        lOk := .T.
    EndIf

    FreeObj( oBrowse )
    FreeObj( oDlg )
    FreeObj( oSize )

Return( lOk )


/*/{Protheus.doc} BrwLeg
Legenda da rotina
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
/*/
Static Function BrwLeg()

	Local aLegenda := {}

	aAdd( aLegenda, { "BR_VERMELHO", "Componente não está no CSV e será excluído do Protheus" } )
	aAdd( aLegenda, { "BR_PINK"    , "Descrições diferentes entre os componentes" } )
	aAdd( aLegenda, { "BR_VERDE"   , "Componente está no CSV e criado no Protheus" } )
	aAdd( aLegenda, { "BR_AMARELO" , "Quantidades diferentes entre os componentes" } )
	aAdd( aLegenda, { "BR_CINZA"   , "Componentes sem diferenças" } )

	BrwLegenda("Legenda","Situação",aLegenda)
Return



/*/{Protheus.doc} CarregaDados
Rotina que fará a leitura dos dados da Pré-estrutura(SGG) ou Estrutrua(SG1)
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
@param cProd, character, Produto pai
@param aEstrut, array, Estrutura que está no CSV
@return array, Dados com as diferenças
/*/
Static Function CarregaDados( cProd, aEstrut )

    Local nEst      := 0
    Local nPosDados := 0
    Local cItem     := ""
    Local cComp     := ""
    Local cDesc     := ""
    Local aDados    := {}
    Local lCarrega  := .F.

    // Faz a explosão da Estrutura de cada Produto do CSV com o que está no Protheus
    I010Explode( @aDados, cProd, aEstrut )

    // Verifica os componentes no CSV que podem ser novos !!
    For nEst := 1 To Len( aEstrut )

        // Se está marcado como Exclusão, não precisa mais validar o restante
        If aEstrut[nEst,P_OPERACAO] == 5
            Loop
        EndIf

        lCarrega  := .F.

        If aScan( aDados, {|x| AllTrim(x[9]) == AllTrim(aEstrut[nEst,P_PROD]) .And. AllTrim(x[6]) == AllTrim(aEstrut[nEst,P_COMP]) } ) <= 0
            lCarrega  := .T.
        ElseIf aScan( aDados, {|x| AllTrim(x[6]) == AllTrim(aEstrut[nEst,P_COMP]) } ) <= 0
            lCarrega  := .T.
        ElseIf aScan( aDados, {|x| AllTrim(x[3]) == AllTrim(aEstrut[nEst,P_COMP]) } ) <= 0
            lCarrega  := .T.
        Endif
            
        // Não achou componente pois é NOVO
        If lCarrega
        
            cItem  := AllTrim( aEstrut[nEst,P_NIVEL] )
            cComp  := AllTrim( aEstrut[nEst,P_COMP] )
            cDesc  := AllTrim( aEstrut[nEst,P_DESC_PROD] )
            nQuant := aEstrut[nEst,P_QTDE]

            // Carrega o que está no CSV
            //              1   2      3   4   5  6      7      8       9
            AADD( aDados, { "", cItem, "", "", 0, cComp, cDesc, nQuant, "" } )

        EndIf
    Next

    // Ordena pelo Item
    aDados := aSort( aDados,,,{ |x,y| Val(x[2]) < Val(y[2]) } )

    // Processo os dados e marca os Componentes que tem diferenças conforme as regras das funções BrwLeg() e MostraEstrutuas()
    For nPosDados := 1 To Len( aDados )

        nEst := aScan( aEstrut, {|x| AllTrim(x[P_PROD]) == AllTrim(aDados[nPosDados,9]) .And. AllTrim(x[P_COMP]) == AllTrim(aDados[nPosDados,6]) } )

        // Se não achou o Produto Pai e Componente, vai procurar somente o Componente
        If nEst <= 0
            nEst := aScan( aEstrut, {|x| AllTrim(x[P_COMP]) == AllTrim(aDados[nPosDados,6]) } )
        EndIf

        If nEst > 0

            If aEstrut[nEst,P_TEM_DIF]
                Loop

            ElseIf Empty(aDados[nPosDados,3])
                aEstrut[nEst,P_TEM_DIF ] := .T.
                aEstrut[nEst,P_OPERACAO] := 3 // Inclusão
            
            ElseIf Empty(aDados[nPosDados,6])
                aEstrut[nEst,P_TEM_DIF ] := .T.
                aEstrut[nEst,P_OPERACAO] := 5 // Exclusão
            
            ElseIf aDados[nPosDados,4] <> aDados[nPosDados,7]
                aEstrut[nEst,P_TEM_DIF] := .T.
                aEstrut[nEst,P_OPERACAO] := 4 // Alteração
            
            ElseIf aDados[nPosDados,5] <> aDados[nPosDados,8]
                aEstrut[nEst,P_TEM_DIF ] := .T.
                aEstrut[nEst,P_OPERACAO] := 4 // Alteração
            EndIf
        EndIf
    Next


Return( aDados )



/*/{Protheus.doc} I010Explode
Rotina que explode a estrutura em sub níveis - CUIDADO POIS É RECURSIVA
@type function
@version  12.1.25
@author Jorge Alberto - Solutio
@since 11/08/2021
@param aDados, array, Dados que serão apresentados na tela
@param cProd, character, Produto pai
@param aEstrut, array, Dados que vem do arquivo CSV
/*/
Static Function I010Explode( aDados, cProd, aEstrut )

    Local nPos      := 0
    Local nQuant    := 0
    Local cRevisao  := ""
    Local cQuery    := ""
    Local cAlias    := ""
    Local cItem     := ""
    Local cComp     := ""
    Local cDesc     := ""
    Local aTamQtd   := TamSX3("G1_QUANT")
    Local lAchou    := .F.

    SB1-> ( dbSeek( xFilial("SB1") + PadR( AllTrim(cProd), aTmSB1COD[1] ) ) )
    // Regra e Função padrão !
    cRevisao := IIF( lPCPREVATU, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )

    If nTipoEst == 1 // Pré-estrutura
        cQuery += "SELECT DISTINCT GG_COMP PROD, B1_DESC DESCRI, GG_QUANT QUANT "
        cQuery += "FROM " + RetSqlName("SGG") + " SGG  "
        cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON ( SB1.B1_COD = SGG.GG_COMP AND SB1.D_E_L_E_T_ = ' ' ) "
        cQuery += "WHERE SGG.D_E_L_E_T_ = ' ' "
        cQuery += "AND GG_COD = '" + cProd + "' "
        cQuery += "AND GG_REVFIM = '" + cRevisao + "' "
        cQuery += "ORDER BY GG_COMP  "
    Else
        cQuery += "SELECT DISTINCT G1_COMP PROD, B1_DESC DESCRI, G1_QUANT QUANT "
        cQuery += "FROM " + RetSqlName("SG1") + " SG1  "
        cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON ( SB1.B1_COD = SG1.G1_COMP AND SB1.D_E_L_E_T_ = ' ' ) "
        cQuery += "WHERE SG1.D_E_L_E_T_ = ' ' "
        cQuery += "AND G1_COD = '" + cProd + "' "
        cQuery += "AND G1_REVFIM = '" + cRevisao + "' "
        cQuery += "ORDER BY G1_COMP  "
    EndIf

    cAlias := GetNextAlias()
    DbUseArea( .T., 'TOPCONN', TCGenQry(,,cQuery), cAlias, .F., .T. )
    TcSetField( cAlias, "QUANT", "N", aTamQtd[1], aTamQtd[2] )
    
    While (cAlias)->( .NOT. EOF() )

        nQuant := 0
        cItem  := ""
        cComp  := ""
        cDesc  := ""
        lAchou := .F.

        // Localiza o Componente e Produto Pai no array com os dados do arquivo CSV.
        nPos := aScan( aEstrut, {|x| AllTrim(x[P_COMP]) == AllTrim((cAlias)->PROD) .And. AllTrim(x[P_PROD]) == AllTrim(cProd) } )
        
        If nPos > 0
            cItem  := AllTrim(aEstrut[nPos,P_NIVEL])
            cComp  := AllTrim(aEstrut[nPos,P_COMP])
            cDesc  := AllTrim(aEstrut[nPos,P_DESC_PROD])
            nQuant := aEstrut[nPos,P_QTDE]
        Else

            // Posiciona no cadastro de Produto conforme o Componente
            SB1-> ( dbSeek( xFilial("SB1") + PadR( AllTrim((cAlias)->PROD), aTmSB1COD[1] ) ) )

            // Localiza somente o nível do Pai
            nPos := aScan( aEstrut, {|x|AllTrim(x[P_PROD]) == AllTrim(cProd) } )
            If nPos > 0
                cItem  := AllTrim(aEstrut[nPos,P_NIVEL])
            EndIf

            // Carrega o array aEstrut, indicando que o item deve ser excluído
            AddAEstrut( cProd,;
                        SB1->B1_DESC,;
                        (cAlias)->PROD,;
                        (cAlias)->QUANT,;
                        cItem,;
                        IIF( lPCPREVATU, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU ),;
                        SB1->B1_TIPO,;
                        SB1->B1_UM,;
                        SB1->B1_LOCPAD,;
                        SB1->B1_CONTA,;
                        SB1->B1_ITEMCC,;
                        SB1->B1_CLVL,;
                        SB1->B1_NATUREZ,;
                        SB1->B1_POSIPI,;
                        SB1->B1_ORIGEM,;
                        SB1->B1_GRTRIB,;
                        SB1->B1_GARANT,;
                        SB1->B1_GRUPO,;
                        .T. /*lTemDif*/,;
                        5 /*nOperacao*/ )
        EndIf

        // Carrega a ESTRUTURA ATUAL com o que está no CSV
        //              1   2      3                        4                             5               6      7      8       9
        AADD( aDados, { "", cItem, AllTrim((cAlias)->PROD), AllTrim( (cAlias)->DESCRI ), (cAlias)->QUANT, cComp, cDesc, nQuant, cProd } )

        If nTipoEst == 1 // Pré-estrutura
            lAchou := SGG->( DbSeek( xFilial("SGG") + PadR( AllTrim( (cAlias)->PROD ), aTmSB1COD[1] ) ) )
        Else // Estrutura
            lAchou := SG1->( DbSeek( xFilial("SG1") + PadR( AllTrim( (cAlias)->PROD ), aTmSB1COD[1] ) ) )
        EndIf

        If lAchou // Rotina recursiva - CUIDADO !!
            I010Explode( @aDados, AllTrim( (cAlias)->PROD ), aEstrut )
        EndIf
        

        (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->( DbCloseArea() )


Return


/*/{Protheus.doc} AddAEstrut
Carrega o array aEstrut
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
/*/
Static Function AddAEstrut( cProduto, cDesc, cComp, nQtde, cNivel, cRevisao, cTipo, cUM, cLocal, cCtaCont, cItemCta, cCodClVl, cNaturez, cNCM, cOrigem, cGrpTrib, cGarantia, cGrupo, lTemFif, nOper )

    Local lAchou := .F.

    If nOper == 0
        If nTipoEst == 1 // Pré-estrutura
            lAchou := SGG->( DbSeek( xFilial("SGG") + PadR( AllTrim( cProduto ), aTmSB1COD[1] ) + PadR( AllTrim( cComp ), aTmSB1COD[1] ) + cTRT ) )
        Else // Estrutura
            lAchou := SG1->( DbSeek( xFilial("SG1") + PadR( AllTrim( cProduto ), aTmSB1COD[1] ) + PadR( AllTrim( cComp ), aTmSB1COD[1] ) + cTRT ) )
        EndIf

        If lAchou
            nOper := 4 // Alteracao
        Else
            nOper := 3 // Inclusao
        EndIf
    EndIf
    /*
    STATIC P_PROD      := 1
    STATIC P_DESC_PROD := 2
    STATIC P_COMP      := 3
    STATIC P_QTDE      := 4
    STATIC P_NIVEL     := 5
    STATIC P_REVISAO   := 6
    STATIC P_TIPO      := 7
    STATIC P_UM        := 8
    STATIC P_ARM_PAD   := 9
    STATIC P_CTA_CONT  := 10
    STATIC P_ITEM_CTA  := 11
    STATIC P_COD_CLVL  := 12
    STATIC P_NATUREZA  := 13
    STATIC P_NCM       := 14
    STATIC P_ORIGEM    := 15
    STATIC P_GRP_TRIB  := 16 
    STATIC P_GARANTIA  := 17
    STATIC P_GRP_PROD  := 18 
    STATIC P_TEM_DIF   := 19
    STATIC P_OPERACAO  := 20
    */
    AADD( aEstrut, { cProduto, cDesc, cComp, nQtde, cNivel, cRevisao, cTipo, cUM, cLocal, cCtaCont, cItemCta, cCodClVl, cNaturez, cNCM, cOrigem, cGrpTrib, cGarantia, cGrupo, lTemFif, nOper } )

Return



/*/{Protheus.doc} GravaEstrut
Chamar as rotinas automáticas para gravar os dados
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 06/08/2021
/*/
Static Function GravaEstrut( aCab, aItens )

    Local cPatch     := ""
    Local cFile      := ""
    Local cBuffer    := ""
    Local cDetalhe   := ""
    Local cRevAtu    := ""
    Local cRevisao   := ""
    Local nHandle    := 0
    Local nTamArq    := 0
    Local nPos       := 0
    Local nItem      := 0
    Local nOpc       := 0

    Private lMsHelpAuto := .T.
    Private lMsErroAuto := .F.
    Private lAutoMacao  := .T. // Usado no PCPA135
    
    SB1-> ( dbSeek( xFilial("SB1") + PadR( AllTrim(aCab[ 1, 2 ]), aTmSB1COD[1] ) ) )
    cRevisao := Soma1( SB1->B1_REVATU )

    If nTipoEst == 1 // Pré-estrutura - SGG

        SGG->( dbSetOrder( 1 ) )

        If SGG->( dbSeek( xFilial( 'SGG' ) + PadR( aCab[ 1, 2 ], aTmSB1COD[1] ), .F. ) )
            nOpc := 4 // Alteração
        Else
            nOpc := 3 // Inclusão
        EndIf

        nPos := ASCAN( aCab, { |x| x[1] == 'AUTREVPAI' } )
        If nPos > 0
            aCab[nPos,2] := cRevisao
        EndIf

        nPos := ASCAN( aItens[1], { |x| x[1] == 'GG_REVINI' } )
        If nPos > 0
            For nItem := 1 To Len( aItens )
                aItens[nItem,nPos,2] := cRevisao
            Next
        EndIf
        
        nPos := ASCAN( aItens[1], { |x| x[1] == 'GG_REVFIM' } )
        If nPos > 0
            For nItem := 1 To Len( aItens )
                aItens[nItem,nPos,2] := cRevisao
            Next
        EndIf
        
        lMsErroAuto := .F.

        Pergunte('PCPA135', .F.)
        MSExecAuto( { |x,y,z| PCPA135( x, y, z) }, aCab, aItens, nOpc )
        
    Else // Estrutura - SG1

        SG1->( dbSetOrder( 1 ) )

        If SG1->( dbSeek( xFilial( 'SG1' ) + PadR( aCab[ 1, 2 ], aTmSB1COD[1] ), .F. ) )
            nOpc := 4 // Alteração
        Else
            nOpc := 3 // Inclusão
        EndIf

        nPos := ASCAN( aCab, { |x| x[1] == 'AUTREVPAI' } )
        If nPos > 0
            aCab[nPos,2] := cRevisao
        EndIf

        nPos := ASCAN( aItens[1], { |x| x[1] == 'G1_REVINI' } )
        If nPos > 0
            For nItem := 1 To Len( aItens )
                aItens[nItem,nPos,2] := cRevisao
            Next
        EndIf

        nPos := ASCAN( aItens[1], { |x| x[1] == 'G1_REVFIM' } )
        If nPos > 0
            For nItem := 1 To Len( aItens )
                aItens[nItem,nPos,2] := cRevisao
            Next
        EndIf

        lMsErroAuto := .F.

        Pergunte('PCPA200', .F.)
        MSExecAuto( { |x,y,z| PCPA200( x, y, z) }, aCab, aItens, nOpc )

    EndIf
        
    If lMsErroAuto
        
        cPatch  := AllTrim( GetTempPath() )
        cFile   := DtoS(dDataBase) + Replace( Time(),':','') + ".txt"
        // Gera o erro no arquivo
        MostraErro( cPatch, cFile )

        nHandle := FOpen( cPatch + cFile, FO_READWRITE + FO_SHARED )
        nTamArq := FSeek(nHandle,0,2)
        FSeek(nHandle,0,0)
        // Pega o conteúdo do arquivo e coloca na variável parar gravar no log
	    FRead(nHandle,@cBuffer,nTamArq)
        FClose(nHandle)

        fErase( cPatch + cFile )
        
        ProcLogAtu("MENSAGEM", "Etapa 5: Inclusão na " + IIF(nTipoEst == 1,"Pré-estrutura ","Estrutura " ) + AllTrim(aCab[ 1, 2 ]) + " - ERRO", cBuffer )
    Else

        SB1-> ( dbSeek( xFilial("SB1") + PadR( AllTrim(aCab[ 1, 2 ]), aTmSB1COD[1] ) ) )
        // Regra e Função padrão !
        cRevAtu := IIF( lPCPREVATU, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )
        
        cDetalhe := "Inclusão da revisão " + cRevAtu + " do material: " + AllTrim(aCab[ 1, 2 ])

        ProcLogAtu("MENSAGEM", "Etapa 5: Inclusão da revisão " +cRevAtu+ " na " + IIF(nTipoEst == 1,"Pré-estrutura ","Estrutura " ) + AllTrim(aCab[ 1, 2 ]) + " - OK", cDetalhe )

    EndIf

Return


/*/{Protheus.doc} GetTrt
Pega o próximo TRT
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 19/11/2021
@param cPai, character, Produto pai
@param cComp, character, Componente
@return character, próximo TRT
/*/
Static Function GetTrt( cPai, cComp )
	
	Local cProxTrt  := "001"
	Local cQuery    := ""
    Local cAliSG1   := GetNextAlias()

    cQuery := "SELECT MAX(G1_TRT) MAXTRT"
    cQuery +=  " FROM " + RetSqlName('SG1') + " SG1"
    cQuery += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
    cQuery +=   " AND SG1.G1_COD     = '" + cPai  + "'"
    cQuery +=   " AND SG1.G1_COMP    = '" + cComp + "'"
    cQuery +=   " AND SG1.D_E_L_E_T_ = ' '"
    cQuery := ChangeQuery(cQuery)

    dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliSG1,.F.,.T.)
    If !(cAliSG1)->(Eof())
        cProxTrt := Soma1( (cAliSG1)->MAXTRT )
    EndIf
    (cAliSG1)->(dbCloseArea())

Return( cProxTrt )
