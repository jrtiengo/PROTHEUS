#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

// ----------------------------------------------------------------------------------------------------------*
// Fonte.....: AUTCOMPENTREGA.PW                                                                                   *
// Autor.....: Harald Hans Löschenkohl                                                                       *
// Data......: 08/05/2012                                                                                    *
// Descrição.: Impressão do comprovante de impressão de entrega de equipamento na técnica                    *
// Parâmetros: Nº da Etiqueta                                                                                * 
// ----------------------------------------------------------------------------------------------------------*

User Function AUTCOMPENTREGA(cNumOS)

    Local   lAutoPar   := .F.
    Local   ctexto     := ""

    Private Li         := 0
	Private _nLin      := 0
    Private nPosicao   := 0
	Private oPrint
	Private cPerg      :="AUTOM109"
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
    Private cNumOS     := _Etiqueta

    If !MsgYesNo("Deseja imprimir o comprovante de entrega de equipamento?")
	   Return .T.
    EndIf

    // Pesquisa os dados da Etiqueta passada no parâmetro
    If Select("T_CHAMADO") > 0
   	   T_CHAMADO->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A.AB6_CODCLI," + CHR(13)
    cSql += "       A.AB6_LOJA  ," + CHR(13)
    cSql += "       B.A1_NOME   ," + CHR(13)
    cSql += "       C.AB7_CODPRO," + CHR(13)
    cSql += "       C.AB7_NUMSER," + CHR(13)
    cSql += "       C.AB6_MEMO  ," + CHR(13)
    cSql += "       D.B1_DESC    " + CHR(13)
    cSql += "  FROM " + RetSqlName("AB6") + " A, " + CHR(13)
    cSql += "       " + RetSqlName("SA1") + " B, " + CHR(13)
    cSql += "       " + RetSqlName("AB7") + " C, " + CHR(13)
    cSql += "       " + RetSqlName("SB1") + " D  " + CHR(13)
    cSql += " WHERE A.AB6_FILIAL   = '" + Alltrim(cFilAnt)   + "'" + CHR(13)
    cSql += "   AND A.AB6_NUMOS    = '" + Alltrim(cNumOS) + "'" + CHR(13)
    cSql += "   AND A.R_E_C_D_E_L_ = ''"           + CHR(13)
    cSql += "   AND A.AB6_NUMOS    = C.AB7_NUMOS " + CHR(13)
    cSql += "   AND A.AB6_FILIAL   = C.AB7_FILIAL" + CHR(13)
    cSql += "   AND C.R_E_C_D_E_L_ = ''"           + CHR(13)
    cSql += "   AND A.AB6_CODCLI   = B.A1_COD "    + CHR(13)
    cSql += "   AND A.AB7_LOJA     = B.A1_LOJA"    + CHR(13)    
    cSql += "   AND C.AB7_CODPRO   = D.B1_COD "    + CHR(13)

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAMADO", .T., .T. )
 
    // Pesquisa o comentárioa ser impresso
    If Select("T_COMENTARIO") > 0
   	   T_COMENTARIO->( dbCloseArea() )
    EndIf
   
    cSql := ""
    cSql := "SELECT YP_TEXTO"
    cSql += "  FROM " + RetSqlName("SYP")
    cSql += " WHERE YP_CHAVE = '" + Alltrim(T_CHAMADO->AB6_MEMO) + "'"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )

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
	oFont50   := TFont():New( "FREE309",,12,,.t.,,,,.f.,.f. )

    _nLin := 0010

    For nContar = 1 to 1

        _nLin := _nLin + 10
	
        // Logotipo e identificação do pedido
        oPrint:SayBitmap( _nLin, 0010, "logoautoma.bmp", 0700, 0200 )

        _nLin := _nLin + 230

        If cEmpAnt == "01"
           oPrint:Say( _nLin, 0010, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09b  )
        Endif   

        If cEmpAnt == "02"
           oPrint:Say( _nLin, 0010, "TI AUTOMAÇÃO E SERVIÇOS LTDA", oFont09b  )
        Endif   

        _nLin := _nLin + 50

        // Grupo de Empresa 01 - Automatech
        If cEmpAnt == "01"
           Do Case
              Case cFilAnt == "01"
                   oPrint:Say( _nLin, 0010, "RUA DR. JOAO INÁCIO, 1110 - CEP: 90.230-181", oFont09b  )
                   _nLin := _nLin + 50
                   oPrint:Say( _nLin, 0010, "FONE: (51)-3017-8300 - PORTO ALEGRE - RS", oFont09b  )
                   _nLin := _nLin + 50
                   oPrint:Say( _nLin, 0010, "CNPJ: 03.385.913/0001-61   IE: 096/2777447", oFont09b  )
                   _nLin := _nLin + 50
              Case cFilAnt == "02"
                   oPrint:Say( _nLin, 0010, "RUA SÃO JOSÉ, 1767 - CEP: 95.030-270", oFont09b  )
                   _nLin := _nLin + 50
                   oPrint:Say( _nLin, 0010, "FONE: (54)-3227-2333 - CAXIAS DO SUL - RS", oFont09b  )
                   _nLin := _nLin + 50
                   oPrint:Say( _nLin, 0010, "CNPJ: 03.385.913/0002-42   IE: 029/0448913", oFont09b  )
                   _nLin := _nLin + 50
              Case cFilAnt == "03"
                   oPrint:Say( _nLin, 0010, "RUA GENERAL NETO, 618 - CEP: 96.015-280", oFont09b  )
                   _nLin := _nLin + 50
                   oPrint:Say( _nLin, 0010, "FONE: (53)-3026-2802 - PELOTAS - RS", oFont09b  )
                   _nLin := _nLin + 50
                   oPrint:Say( _nLin, 0010, "CNPJ: 03.385.913/0004-04   IE: 093/0410289", oFont09b  )
                   _nLin := _nLin + 50
           EndCase
        Endif
       
        // Grupo de Empresa 02 - TI Automação
        If cEmpAnt == "02"
           oPrint:Say( _nLin, 0010, "RUA TEN.FRANCISCO FERREIRA DE SOUZA, 1052", oFont09b  )
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0010, "FONE: (41)-3024-6675 - CURITIBA - RS", oFont09b  )
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0010, "CNPJ: 12.757.071/0001-12   IE: 9053742146", oFont09b  )
           _nLin := _nLin + 50
        Endif

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, Dtoc(Date()) + " - " + Time(), oFont09  )
       oPrint:Say( _nLin, 0550, "OS:  " + Alltrim(cNumOS) , oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 10

       // ---------------------------------------------------------------------
       // Parâmetros da Função MSBAR
       // 01 cTypeBar String com o tipo do codigo de barras          
       //                          "EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"     
       //                          "INT25","MAT25,"IND25","CODABAR","CODE3_9"    
       // 02 nRow     Numero da Linha em centimentros               
       // 03 nCol     Numero da coluna em centimentros              
       // 04 cCode    String com o conteudo do codigo              
       // 05 oPr      Obejcto Printer                                
       // 06 lcheck   Se calcula o digito de controle               
       // 07 Cor      Numero da Cor, utilize a "common.ch"       
       // 08 lHort    Se imprime na Horizontal                  
       // 09 nWidth   Numero do Tamanho da barra em centimetros     
       // 10 nHeigth  Numero da Altura da barra em milimetros      
       // 11 lBanner  Se imprime o linha em baixo do codigo        
       // 12 cFont    String com o tipo de fonte                
       // 13 cMode    String com o modo do codigo de barras CODE128
       // ---------------------------------------------------------------------

       // Imprimee o código de barras
       MSBAR("CODE128",25,1.5,AllTrim(cNumOS),oPrint,.F.,,.T.,0.325,5.3,,,,.F.)

       _nLin := _nLin + 150

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50
       
       oPrint:Say( _nLin, 0030, "COMPROVANTE RECEBIMENTO EQUIPAMENTO", oFont09b  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "Recebemos de:", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, Alltrim(T_CHAMADO->A1_NOME), oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, "o equipamento abaixo discriminado:", oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, Alltrim(T_CHAMADO->B1_DESC), oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, "Nº de Série: " + Alltrim(T_CHAMADO->AB7_NUMSER), oFont09  )
       _nLin := _nLin + 100       

       oPrint:Say( _nLin, 0010, "---------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0200, "COMENTÁRIOS/ACESSORIOS", oFont09b  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              

       // Imprime o comentario do Chamado Técnico
       cTexto := ""
       T_COMENTARIO->( DbGoTop() )
       WHILE !T_COMENTARIO->( EOF() )

          cTexto := ""
          cTexto := StrTran(StrTran(StrTran(T_COMENTARIO->YP_TEXTO, "\13\10", ""), CHR(10), ""), CHR(13), "")
          
          If Len(Alltrim(ctexto)) <= 37
             oPrint:Say( _nLin, 0010, Alltrim(cTexto), oFont09  )
          Else
             oPrint:Say( _nLin, 0010, Alltrim(Substr(cTexto,01,37)), oFont09  )          
             _nLin := _nLin + 50                           
             oPrint:Say( _nLin, 0010, Alltrim(Substr(cTexto,38))   , oFont09  )                       
          Endif             
          _nLin := _nLin + 50              
          T_COMENTARIO->( DbSkip() )
       ENDDO   

       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "Eu, em nome de", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, Alltrim(T_CHAMADO->A1_NOME), oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "declaro que entreguei o equipamento do nº de serie", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "acima  mencionado  para conserto, e concordo com", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "o descritivo constante neste Comprovante.", oFont09  )
       _nLin := _nLin + 150              

       Do Case
          Case cEmpAnt == "01"
               oPrint:Say( _nLin, 0010, "Porto Alegre, " + Dtoc(Date()), oFont09  )
          Case cEmpAnt == "02"
               oPrint:Say( _nLin, 0010, "Caxias do Sul, " + Dtoc(Date()), oFont09  )
          Case cEmpAnt == "03"
               oPrint:Say( _nLin, 0010, "Pelotas, " + Dtoc(Date()), oFont09  )
               
       EndCase               
               
       _nLin := _nLin + 200              
       oPrint:Say( _nLin, 0010, "---------------------------------------     ----------------------------------", oFont09  )
       _nLin := _nLin + 50                     
       oPrint:Say( _nLin, 0010, "Assinatura do Cliente          CPF/RG", oFont09  )
       _nLin := _nLin + 100                     
       oPrint:Say( _nLin, 0010, "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ", oFont09  )
       
    Next nContar



	// oPrint:Setup()
	oPrint:Preview()

	DbCommitAll()
	MS_FLUSH()

Return()

// Monta o cabeçalho da página
Static Function Cabecalho()

    _nLin := 0060

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 50
	
    // Logotipo e identificação do pedido
    oPrint:SayBitmap( _nLin, 0110, "logoautoma.bmp", 0700, 0200 )
    oPrint:Say( _nLin, 1000, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont12b  )
    _nLin := _nLin + 70
    oPrint:Say( _nLin, 1000, "Matriz:", oFont08  )    
    oPrint:Say( _nLin, 1100, "RUA JOÃO INÁCIO, 1110 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0001-61    Insc. Estadual: 096/27777447", oFont08  )    
    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA SÃO JOSÉ, 1767 - CEP: 95.020-270 - CAXIAS DO SUL - RS Fone: (54)32272333", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0002-42    Insc. Estadual: 029/0448913", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA GENERAL NETO, 618 - CEP: 96.015-250 - PELOTAS - RS Fone: (53)30262802", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 0110, "www.automatech.com.br", oFont10  )
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0004-04    Insc. Estadual: 093/0410289", oFont08  )    

    _nLin := _nLin + 50
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 20

    // Pesquisa Nº da Oprtunidade, Proposta Comercial e Data de Emissão para Impressão
    DbSelectArea("AD1")
	DbSetOrder(1)
	DbSeek( xFilial("AD1") + TMPO->ADY_OPORTU )
		
	cNropor := AD1->AD1_NROPOR
	cRevisa := AD1->AD1_REVISA
	cVend   := AD1->AD1_VEND
    oPrint:Say( _nLin, 0110, "Nº Oportunidade: " + cNropor + "/" + cRevisa, oFont12b)
		
	DbSelectArea("ADY")
	DbSetOrder(1)
	DbSeek( xFilial("ADY") + TMPO->ADZ_PROPOS )
		
	cProp1 := ADY_PROPOS
    oPrint:Say( _nLin, 0750, "Nº Proposta: " + cProp1, oFont12b)
    oPrint:Say( _nLin, 1275, "Emissão: "     + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)
    oPrint:Say( _nLin, 1800, "Validade: "    + DtoC( StoD( TMPO->ADY_VAL ) ) , oFont12b)


//    oPrint:Say( _nLin, 1000, "Nº Proposta: " + cProp1, oFont12b)
//    oPrint:Say( _nLin, 1750, "Emissão: " + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)

    _nLin := _nLin + 70
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    // Pesquisa dados complementares para impressão
	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT ADY_FILIAL, "
    cSql += "       ADY_PROPOS, "
    cSql += "       ADY_PARAQ , "
    cSql += "       ADY_ENTREG, "
    cSql += "       ADY_TPFRET  "
    cSql += "  FROM " + RetSqlName("ADY")
    cSql += " WHERE ADY_PROPOS = '" + Alltrim(cProp1) + "'"
    cSql += "   AND ADY_FILIAL = '" + Alltrim(cEnt)   + "'"

	cStrSql := ChangeQuery( cStrSql )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"T_DETALHES",.T.,.T.)

    If !Empty(Alltrim(T_DETALHES->ADY_PARAQ))
       oPrint:Say( _nLin, 0110, "A/C" , oFont10)
       oPrint:Say( _nLin, 0400, Alltrim(T_DETALHES->ADY_PARAQ), oFont10b )
       _nLin := _nLin + 50
    Endif

    oPrint:Say( _nLin, 0110, "Cliente:" , oFont10)
	oPrint:Say( _nLin, 0400, _cEntidade[ 1, 1 ] +" ["+ _cEntidade[ 1, 2 ] +"]", oFont10b )

    oPrint:Say( _nLin, 1500, "Telefone:", oFont10)
    oPrint:Say( _nLin, 1730, _cEntidade[ 1, 8 ], oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Endereço:", oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 3 ]), oFont10b)

    oPrint:Say( _nLin, 1500, "Cidade:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(_cEntidade[ 1, 6 ]) + " - " + AllTrim(_cEntidade[ 1, 5 ]), oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Bairro:"  , oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 4 ]), oFont10b)

    oPrint:Say( _nLin, 1500, "Estado:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(_cEntidade[ 1, 7 ]), oFont10b)

    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "E-mail:"  , oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 9 ]), oFont10b)

    _nLin := _nLin + 50
        
    oPrint:Say( _nLin, 0110, "CNPJ/CPF:", oFont10)

    If Len(AllTrim(_cEntidade[ 1, 10 ])) == 14
       oPrint:Say( _nLin, 0400, Substr(_cEntidade[ 1, 10 ],01,02) + "." + Substr(_cEntidade[ 1, 10 ],03,03) + "." + Substr(_cEntidade[ 1, 10 ],06,03) + "/" + Substr(_cEntidade[ 1, 10 ],09,04) + "-" + Substr(_cEntidade[ 1, 10 ],13,02), oFont10b)
    Else
       oPrint:Say( _nLin, 0400, Substr(_cEntidade[ 1, 10 ],01,03) + "." + Substr(_cEntidade[ 1, 10 ],04,03) + "." + Substr(_cEntidade[ 1, 10 ],07,03) + "-" + Substr(_cEntidade[ 1, 10 ],10,02), oFont10b)       
    Endif

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "I.E.:"    , oFont10)    
    oPrint:Say( _nLin, 0400, AllTrim( _cEntidade[ 1, 11 ] ), oFont10b)    

    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    oPrint:Say( _nLin - 20, 0110, "Conforme combinado, apresentamos abaixo a proposta para fornecimento de equipamentos e serviços:"    , oFont10b)        

    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 30    

    cNomeTranspo := ""

    oPrint:Say( _nLin,0110, "Vendedor:"       , oFont10)
    oPrint:Say (_nLin,0400, Upper( Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_NOME" ) ),oFont10b)
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Condição Pgtº:"  , oFont10)
    oPrint:Say (_nLin,0400, AllTrim( Posicione( "SE4", 1, xFilial("SE4") + _cCondPag, "E4_DESCRI" )),oFont10b)
    _nLin := _nLin + 50

    If !Empty(Alltrim(T_DETALHES->ADY_TPFRET))
       oPrint:Say( _nLin, 0110, "Frete:"  , oFont10)
       If Alltrim(T_DETALHES->ADY_TPFRET) == "C"
          oPrint:Say (_nLin,0400, "C I F",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "F"
          oPrint:Say (_nLin,0400, "F O B",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "T"
          oPrint:Say (_nLin,0400, "Por Conta de Terceirtos",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "S"
          oPrint:Say (_nLin,0400, "Sem Frete",oFont10b)
       Endif

       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete
       If T_DETALHES->ADY_FRETE <> 0
          oPrint:Say (_nLin,0700, "Valor Frete:",oFont10b)           
          oPrint:Say (_nLin,0900, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
       Endif

       _nLin := _nLin + 50
    Else

       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete
       If T_DETALHES->ADY_FRETE <> 0
          oPrint:Say (_nLin,0110, "Valor Frete:",oFont10b)           
          oPrint:Say (_nLin,0400, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
       Endif
    
    Endif

    If !Empty(Alltrim(T_DETALHES->ADY_ENTREG))
       oPrint:Say( _nLin, 0110, "Prazo Entrega:"  , oFont10)
       oPrint:Say (_nLin,0400, AllTrim(T_DETALHES->ADY_ENTREG),oFont10b)
       _nLin := _nLin + 50
    Endif   

	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50
    oPrint:Say(  _nLin - 20, 1000, "P R O D U T O S"  , oFont12b)
    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )

    nPosicao := _nLin

    _nLin := _nLin + 30

    // Cabeçalho dos Produtos
//	oPrint:Say ( _nLin - 20, 0120, "ITEM"      , oFont08 )
//	oPrint:Say ( _nLin - 20, 0235, "PRODUTO"   , oFont08 )

  	oPrint:Say ( _nLin - 20, 0120, "PRODUTO"   , oFont08 )
	oPrint:Say ( _nLin - 20, 0650, "DESCRICAO" , oFont08 )
	oPrint:Say ( _nLin - 20, 1225, "MOEDA"     , oFont08 )
	oPrint:Say ( _nLin - 20, 1358, "QUANTIDADE", oFont08 )
	oPrint:Say ( _nLin - 20, 1575, "UN"        , oFont08 )
	oPrint:Say ( _nLin - 20, 1675, "VLR. UNIT.", oFont08 )
	oPrint:Say ( _nLin - 20, 1880, "VLR. TOTAL", oFont08 )
	oPrint:Say ( _nLin - 20, 2090, "GARANTIA"  , oFont08 )

    _nLin := _nLin + 30
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

Return

// Cria as perguntas
Static Function GeraPerg( cPerg )

	PutSx1( cPerg, "01","OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"mv_ch1","C",6,0,0,"G","","AD1","","","mv_par01"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "02","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","mv_ch2","C",6,0,0,"G","","AD1","","","mv_par02"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "03","PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"mv_ch3","C",6,0,0,"G","","ADY","","","mv_par03"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "04","PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"mv_ch4","C",6,0,0,"G","","ADY","","","mv_par04"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "05","DATA INICIAL?"    ,"DATA INICIAL?"    ,"DATA INICIAL?"    ,"mv_ch5","D",8,0,2,"G","",""   ,"","","mv_par05"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "06","DATA FIM?"        ,"DATA FIM?"        ,"DATA FIM?"        ,"mv_ch6","D",8,0,2,"G","",""   ,"","","mv_par06"," ","","","","","","","","","","","","","","","")

Return()

// Retorna um array com as linhas de texto do campo memo
Static Function MemoObs( cTexto, nTam )

	Local aObserv := {}
	Local nPos := 1
	Local nLinhas := nResto := 0
	
	nLinhas := MlCount( cTexto, nTam )
	
	For nX := 1 To nLinhas
		aAdd( aObserv, MemoLine( cTexto, nTam, nX ) )
	Next

Return( aObserv )

// Imprime uma régua horizontal numerada de 100 em 100 e uma régua vertical numerada de 50 em 50
Static Function PrtRegua()

	For xxx = 100 to 2400 step 100
		oPrint:Line( 0010, xxx, 0030, xxx )
		oPrint:Say( 0010, xxx + 10, AllTrim( Str(xxx) ), oFont08 )
		If xxx > 2400
			Exit
		EndIf
	Next

	For xxx = 50 to 3600 step 50
		oPrint:Line( xxx, 0020, xxx, 0040 )
		oPrint:Say( xxx - 20, 0050, AllTrim( Str( xxx ) ), oFont08 )
		If xxx > 3600
			Exit
		EndIf
	Next

Return