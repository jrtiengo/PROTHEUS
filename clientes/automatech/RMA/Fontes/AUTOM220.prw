#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM220.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/03/2014                                                          *
// Objetivo..: Impressão Gráfica da R M A                                          *
// Parâmetros: Nº da RMA                                                           *
//             Ano da RMA                                                          * 
//**********************************************************************************

User Function AUTOM220(_RMA, _ANO)

    Local  csql        := ""

    Private xRMA       := _RMA
    Private xAno       := _ANO
	Private _nLin      := 0
    Private nPosicao   := 0
	Private oPrint
	Private cStrSql    := ""
	Private cConsulta  := ""
	Private nLastKey   := 0
	Private cLoja      := ""
	Private cTaxa      := 0
	Private cNome      := ""
	Private cNumJ      := ""
	Private cNropor	   := ""
	Private cRevisa    := ""
	Private cVend      := ""
	Private cProp      := ""
	Private lInicio    := .T.
	Private cNumPar    := ""
	Private cProp1     := ""
	Private cMoedaDia  := ""
	Private Totger     := ""
	Private cComple    := ""
	Private cData      := ""
	Private _aEntidade := {}
	Private _cProdNCM  := ""
	Private _cCondPag  := ""
	Private _cValidade := ""
	Private _aObserv   := {}
    Private cSql       := ""
    Private aDiferenca := {}
    Private nDifeReal  := 0
    Private nDifeDolar := 0
    Private nLimvert   := 3500
    Private cTexto     := ""
    Private cNota01    := ""
    Private cNota02    := ""
    Private cNota03    := ""
    Private cNota04    := ""
    Private cNota05    := ""
    Private cNota06    := ""
    Private cNota07    := ""
    Private cNota08    := ""
    Private cNota09    := ""
    Private cNota10    := ""                        
    Private cNota11    := ""
    Private cNota12    := ""
    Private cNota13    := ""
    Private cNota14    := ""
    Private cNota15    := ""
    Private cNota16    := ""
    Private cNota17    := ""
    Private cNota18    := ""
    Private cNota19    := ""
    Private cNota20    := ""                        
    Private cEmailVend := ""
    
    // Pesquisa os dados da RMA para impressão
    If Select("T_DADOS") > 0
       T_DADOS->( dbCloseArea() )
    EndIf
  
    cSql := ""
    cSql += "SELECT A.ZS4_NRMA,"
    cSql += "       A.ZS4_ANO ,"
    cSql += "       A.ZS4_STAT,"
    cSql += "       A.ZS4_ABER,"
    cSql += "       A.ZS4_HORA,"
    cSql += "       A.ZS4_CLIE,"
    cSql += "       A.ZS4_LOJA,"
    cSql += "       A.ZS4_TELE,"
    cSql += "       A.ZS4_EMAI,"
    cSql += "       A.ZS4_NFIL,"
    cSql += "       A.ZS4_NOTA,"
    cSql += "       A.ZS4_SERI,"
    cSql += "       A.ZS4_CRED,"
    cSql += "       A.ZS4_CREF,"
    cSql += "       A.ZS4_CREN,"
    cSql += "       A.ZS4_CRES,"
    cSql += "       B.A1_NOME ,"
    cSql += "       A.ZS4_VEND,"
    cSql += "       C.A3_NOME ,"
    cSql += "       C.A3_EMAIL,"
    cSql += "       A.ZS4_DLIB,"
    cSql += "       A.ZS4_HLIB,"
    cSql += "       A.ZS4_APRO,"
    cSql += "       A.ZS4_CONT,"
    cSql += "       A.ZS4_CHEK,"
    cSql += "       A.ZS4_ITEM,"
    cSql += "       A.ZS4_PROD,"
    cSql += "       A.ZS4_QUAN,"
    cSql += "       A.ZS4_UNIT,"
    cSql += "       A.ZS4_TOTA,"
    cSql += "       A.ZS4_CMOT,"
    cSql += "       A.ZS4_CMTA,"
    cSql += "       A.ZS4_VALI,"
    cSql += "       A.ZS4_CTIP,"
    cSql += "       F.ZS8_DESC,"
    cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
    cSql += "       D.U5_CONTAT,"
    cSql += "       E.B1_DESC  ,"
    cSql += "       E.B1_DAUX  ,"
    cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)) AS SERIES, "
    cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
    cSql += "  FROM " + RetSqlName("ZS4") + " A, "
    cSql += "       " + RetSqlName("SA1") + " B, "
    cSql += "       " + RetSqlName("SA3") + " C, "
    cSql += "       " + RetSqlName("SU5") + " D, "
    cSql += "       " + RetSqlName("SB1") + " E, "
    cSql += "       " + RetSqlName("ZS8") + " F  "
    cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
    cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
    cSql += "   AND A.ZS4_NRMA   = '" + Alltrim(_RMA) + "'"
    cSql += "   AND A.ZS4_ANO    = '" + Alltrim(_ANO) + "'"
    cSql += "   AND B.D_E_L_E_T_ = ''       "
    cSql += "   AND A.ZS4_VEND   = C.A3_COD "
    cSql += "   AND C.D_E_L_E_T_ = ''       "
    cSql += "   AND A.ZS4_CONT   = D.U5_CODCONT"
    cSql += "   AND D.D_E_L_E_T_ = ''       "
    cSql += "   AND A.ZS4_PROD   = E.B1_COD "
    cSql += "   AND E.D_E_L_E_T_ = ''       "
    cSql += "   AND A.ZS4_CTIP   = F.ZS8_CODI"
    cSql += "   AND F.ZS8_DELE   = ''"
    cSql += " ORDER BY A.ZS4_ITEM"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

    cEmailVend := T_DADOS->A3_EMAIL

    // Prepara para impressão
 	oPrint := TMSPrinter():New()

	oPrint:SetPaperSize(9)
	oPrint:SetPortrait()
	oPrint:StartPage()

//  oPrint:SaveAllAsJpeg("d:\relatorios\proposta",1180,1600,180)

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont09n  := TFont():New( "Arial",, 9,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont11   := TFont():New( "Arial",,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont12n  := TFont():New( "Arial",,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont25   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont25b  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

    // Inicio da impressão da RMA
    CABECARMA()

    // Tipo da RMA
    SomaLinha(020)   
    oPrint:Say( _nLin, 0110, "Tipo RMA: " + Alltrim(T_DADOS->ZS8_DESC), oFont12B  )    
    SomaLinha(100)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Dados do Cliente
    SomaLinha(30)   
    oPrint:Say( _nLin, 0110, "DADOS DO CLIENTE", oFont12B  )    
    SomaLinha(70)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(30)   
    oPrint:Say( _nLin, 0110, "Razão Social:", oFont10B  )    
    oPrint:Say( _nLin, 0350, Alltrim(T_DADOS->A1_NOME), oFont10B  )    
    SomaLinha(50)   
    oPrint:Say( _nLin, 0110, "Contato:", oFont10B  )    
    oPrint:Say( _nLin, 0350, Alltrim(T_DADOS->U5_CONTAT), oFont10B  )    
    SomaLinha(50)   
    oPrint:Say( _nLin, 0110, "Telefone:", oFont10B  )    
    oPrint:Say( _nLin, 0350, Alltrim(T_DADOS->ZS4_TELE), oFont10B  )    
    SomaLinha(50)   
    oPrint:Say( _nLin, 0110, "E-Mail:", oFont10B  )    
    oPrint:Say( _nLin, 0350, Alltrim(T_DADOS->ZS4_EMAI), oFont10B  )    
    SomaLinha(100)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Dados da Nota Fiscal de Venda
    SomaLinha(30)   
    oPrint:Say( _nLin, 0110, "DADOS NF DE VENDA: Nota Fiscal de Venda Nº " + Alltrim(T_DADOS->ZS4_NOTA) + " da Série " + Alltrim(T_DADOS->ZS4_SERI), oFont12B  )    
    SomaLinha(100)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Motivo da Devolução
    cNota01 := Substr(T_DADOS->MOTIVO,001,120)
    cNota02 := Substr(T_DADOS->MOTIVO,121,120)
    cNota03 := Substr(T_DADOS->MOTIVO,241,120)
    cNota04 := Substr(T_DADOS->MOTIVO,361,120)
    cNota05 := Substr(T_DADOS->MOTIVO,481,120)
    cNota06 := Substr(T_DADOS->MOTIVO,601,120)
    cNota07 := Substr(T_DADOS->MOTIVO,721,120)
    cNota08 := Substr(T_DADOS->MOTIVO,841,120)
    cNota09 := Substr(T_DADOS->MOTIVO,961,120)
    cNota10 := Substr(T_DADOS->MOTIVO,1081,120)                                
    cNota11 := Substr(T_DADOS->MOTIVO,1201,120)
    cNota12 := Substr(T_DADOS->MOTIVO,1321,120)
    cNota13 := Substr(T_DADOS->MOTIVO,1441,120)
    cNota14 := Substr(T_DADOS->MOTIVO,1561,120)
    cNota15 := Substr(T_DADOS->MOTIVO,1681,120)
    cNota16 := Substr(T_DADOS->MOTIVO,1801,120)
    cNota17 := Substr(T_DADOS->MOTIVO,1921,120)
    cNota18 := Substr(T_DADOS->MOTIVO,2041,120)
    cNota19 := Substr(T_DADOS->MOTIVO,2161,120)
    cNota20 := Substr(T_DADOS->MOTIVO,2281,120)                                

    SomaLinha(25)   
    oPrint:Say( _nLin, 0110, "MOTIVO DEVOLUÇÃO MERCADORIA(S)", oFont12B  )    
    SomaLinha(70)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(30)   

    lImprimiu := .F.
    
    For nContar = 1 to 20
        j := Strzero(nContar,02)
        If Empty(Alltrim(cNota&j))
           Loop
        Endif   
        lImprimiu := .T.
        oPrint:Say( _nLin, 0110, cNota&j, oFont10B  )    
        SomaLinha(50)   
    Next nContar

    If lImprimiu
       SomaLinha(50)   
    Else
       SomaLinha(70)   
    Endif
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Produtos a serem devolvidos
    SomaLinha(25)   
    oPrint:Say( _nLin, 0110, "PRODUTO(S) A SER(EM) DEVOLVIDO(S)", oFont12B  )    
    SomaLinha(70)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(30)   

    T_DADOS->( EOF() )

    _TCredito := T_DADOS->ZS4_CRED
    _Ncredito := T_DADOS->ZS4_CREN
    _Scredito := T_DADOS->ZS4_CRES
   
    WHILE !T_DADOS->( EOF() )

       If T_DADOS->ZS4_CHEK == "0"
          T_DADOS->( DbSkip() )         
          Loop
       Endif

       oPrint:Say( _nLin, 0110, "Produto: " + Alltrim(T_DADOS->B1_DESC) + " " + Alltrim(T_DADOS->B1_DAUX), oFont10B  )    
       SomaLinha(60)   
  
       If Empty(Alltrim(T_DADOS->SERIES))
       Else
          cTexto := ""
          For nContar = 1 to U_P_OCCURS(T_DADOS->SERIES, "|", 1)      
              cTexto += Alltrim(U_P_CORTA(T_DADOS->SERIES, "|", nContar)) + ","
          Next nContar
       Endif

       If Empty(Alltrim(cTexto))
       Else
          oPrint:Say( _nLin, 0110, "Nºs de Série(s): " + Alltrim(Substr(cTexto,01,Len(Alltrim(cTexto)) - 1)), oFont10B  )    
          SomaLinha(60)   
       Endif   
                
       T_DADOS->( DbSkip() )

    ENDDO   
    SomaLinha(40)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    // Informações Ref. ao Crédito
    SomaLinha(25)   
    Do Case
       Case _Tcredito == "01"
            oPrint:Say( _nLin, 0110, "INFORMAÇÕES REF. AO CRÉDITO:   Encontro com nota fiscal original", oFont10B  )    
       Case _Tcredito == "02"
            oPrint:Say( _nLin, 0110, "INFORMAÇÕES REF. AO CRÉDITO:   Encontro com nova nota fiscal", oFont10B  )    
       Case _Tcredito == "03"
            oPrint:Say( _nLin, 0110, "INFORMAÇÕES REF. AO CRÉDITO:   Encontro com outra NF (NF Nº " + _Ncredito + " SÉRIE: " + _Scredito + ")", oFont10B  )    
       Case _Tcredito == "04"
            oPrint:Say( _nLin, 0110, "INFORMAÇÕES REF. AO CRÉDITO:   Cliente ficou com crédito junto a Automatech", oFont10B  )    
       Case _Tcredito == "05"
            oPrint:Say( _nLin, 0110, "INFORMAÇÕES REF. AO CRÉDITO:   Cliente vai receber em espécie (Somente se for devolvido até 7 dias ou com autorização)", oFont10B  )    
    EndCase
    SomaLinha(100)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(30)   
    oPrint:Say( _nLin, 0110, "CONDIÇÕES GERAIS DE TROCA DA(S) MERCADORIA(S)", oFont12B  )    
    SomaLinha(70)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "1. Somente serão aceitas trocas de produtos em suas embalagens originais, com, todos os acessórios e sem uso.", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "2. O Produto deve estar em perfeitas condições de venda.Na eventual devolução de um produto fora deste estado (faltando algum", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "     acessório,com vestígios de uso, etc.), será cobrado do Cliente o valor devido para colocá-lo em condições de venda.", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "3. O prazo para abertura de RMA é de 10 dias, contados a partir da data do recebimento da mercadoria pelo Cliente.", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "4. Desde que a devolução não seja motivada por um equívoco da Automatech todos os fretes envolvidos correm por conta do Cliente.", oFont10  )    
    SomaLinha(100)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(30)   

    oPrint:Say( _nLin, 0110, "PROCEDIMENTO DE TROCA", oFont12B  )    
    SomaLinha(70)   
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "1. Encaminhar cópía da nota fiscal de devolução e XML para o e-mail nfe@automatech.com.br e para o e-mail do vendedor(a):" , oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "     " + Alltrim(cEmailVend), oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "     Deve conter na nota o nº da NF de Venda e da RMA. Em Caso de pessoa física ou Empresa que não possua inscrição estadual,", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "     não é necessária nota fiscal de devolução (a Automatech fará a nota fiscal de entrada).", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "2. Encaminhar o equipamento para a Automatech conforme instruções da área de estoque.", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "3. Após o equipamento ser recebido, este será inspecionado (estado geral, embalagem e acessórios) e se tudo estiver de acordo", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "     com as condições gerais de troca de mercadorias o valor do equipamento será creditado para aquisiçãode um novo produto.", oFont10  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, "     Será devolvido o valor da compra em dinhiero somente se o produto for devolvido em até 7 dias depois do faturamento.", oFont10  )    
    SomaLinha(100)   
    oPrint:Say( _nLin, 0110, "OBS: NÃO SERÁ REALIZADO A ENTRADA DA DEVOLUÇÃO SEM QUE A RMA TENHA SIDO APROVADA, VISTO QUE SERÁ", oFont10b  )    
    SomaLinha(60)   
    oPrint:Say( _nLin, 0110, " LEVADO EM CONSIDERAÇÃO TODAS AS CONDIÇÕES ACIMA.", oFont10b  )    
    SomaLinha(100)   
    oPrint:Say( _nLin, 0110, "Att.", oFont10  )    
    SomaLinha(100)   
    oPrint:Say( _nLin, 0110, "Automatech Sistemas de Automação Ltda", oFont10  )    
    SomaLinha(60)   

    SomaLinha(100)   

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    oPrint:Line( 060, 0100, _nLin, 0100 )
    oPrint:Line( 060, 2330, _nLin, 2330 )
        
	// oPrint:Setup()
	oPrint:Preview()

	DbCommitAll()
	MS_FLUSH()

Return(.T.)

// Imprime o cabeçalho da RMA
Static Function CABECARMA()

   oPrint:StartPage()

   _nLin := 0060

   oPrint:Line( _nLin, 0100, _nLin, 2330 )

   _nLin := _nLin + 50

   // Logotipo e identificação
   oPrint:SayBitmap( _nLin, 0151, "logoautoma.bmp", 0700, 0200 )

   // Dados da RMA e Vendedor
   dAprovada := Substr(T_DADOS->ZS4_DLIB,07,02) + "/" + Substr(T_DADOS->ZS4_DLIB,05,02) + "/" + Substr(T_DADOS->ZS4_DLIB,01,04)
   dValidade := Substr(T_DADOS->ZS4_VALI,07,02) + "/" + Substr(T_DADOS->ZS4_VALI,05,02) + "/" + Substr(T_DADOS->ZS4_VALI,01,04)

   oPrint:Say( _nLin, 1000, "RMA Nº " + xRMA + "/" + xANO, oFont20B  )    
   _nLin := _nLin + 100
   oPrint:Say( _nLin, 1000, "Aprovada: " + dAprovada + " - Validade: " + dValidade, oFont16B  )    
   _nLin := _nLin + 100
   oPrint:Say( _nLin, 0350, "www.automatech.com.br", oFont10  )
   oPrint:Say( _nLin, 1000, "Vendedor(a): " + Alltrim(T_DADOS->A3_NOME), oFont16B  )    
   _nLin := _nLin + 100
   oPrint:Line( _nLin, 0100, _nLin, 2330 )
   _nLin := _nLin + 35

Return(.T.)

// Função que soma linhas para impressão
Static Function SomaLinha(nLinhas)   
   _nLin := _nLin + nLinhas
   If _nLin > nLimVert - 10
      oPrint:Line( _nLin, 0100, _nLin, 2330 )
      oPrint:Line( 060, 0100, _nLin, 0100 )
      oPrint:Line( 060, 2330, _nLin, 2330 )
      oPrint:EndPage()
      CABECARMA()
   Endif

Return(.T.)