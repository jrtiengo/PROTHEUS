#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE IMP_SPOOL 2

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM109.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/05/2012                                                          *
// Objetivo..: Nº da Etiqueta                                                      * 
//**********************************************************************************

User Function AUTOM109()

    Local   lAutoPar   := .F.
    Local   ctexto     := ""

    Private Li         := 0
	Private _nLin      := 0
    Private nPosicao   := 0
    Private __nInicial := 1
    Private __nVezes   := 0
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
    
    // Jean Rehermann - Solutio IT - 02/06/2015 - Alterado para atender tarefa #9747 do portfólio
    Private __cNumOSIXB := PARAMIXB[1]
    __cNumOSIXB := Iif( __cNumOSIXB == Nil .Or. Empty( __cNumOSIXB ), Iif( !AB6->( Eof() ) .And. !Empty( AB6->AB6_NUMOS ), AB6->AB6_NUMOS, M->AB6_NUMOS ), __cNumOSIXB )

	If __cNumOSIXB == Nil .Or. Empty( __cNumOSIXB )
		MsgAlert("Não foi possível determinar a OS a ser impressa! Realizar impressão manual!")
		Return .T.
	EndIf
	    
    If Inclui == .T.
       If !MsgYesNo("Deseja Imprimir o Comprovante de Entrega do Equipamento ?")
          Return .T.
       EndIf
    Else
       Return .T.       
    Endif   
                       
	DbSelectArea('AB6')

    // Pesquisa os dados da Etiqueta passada no parâmetro
    If Select("SQL") > 0
   	   SQL->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT " + CHR(13)
    cSql += "       A.AB6_NUMOS ," + CHR(13)
    cSql += "       A.AB6_CODCLI," + CHR(13)
    cSql += "       A.AB6_LOJA  ," + CHR(13)
    cSql += "       B.A1_NOME   ," + CHR(13)
    cSql += "       C.AB7_CODPRO," + CHR(13)
    cSql += "       C.AB7_NUMSER," + CHR(13)
    cSql += "       C.AB7_MEMO1 ," + CHR(13)
//  cSql += "       ISNULL(CAST(CONVERT(VARBINARY(1000),AB6_MEMO8)AS VARCHAR(1000)), '') AS 'AB6_LAUDO', " + CHR(13)
//  cSql += "       A.AB6_MLAUDO  ," + CHR(13)
    cSql += "       D.B1_DESC    " + CHR(13)
    cSql += "  FROM " + RetSqlName("AB6") + " A, " + CHR(13)
    cSql += "       " + RetSqlName("SA1") + " B, " + CHR(13)
    cSql += "       " + RetSqlName("AB7") + " C, " + CHR(13)
    cSql += "       " + RetSqlName("SB1") + " D  " + CHR(13)
    cSql += " WHERE A.AB6_FILIAL   = '" + XFILIAL("AB6")    + "'" + CHR(13)

// Jean Rehermann - Solutio IT - 02/06/2015 - Alterado para atender tarefa #9747 do portfólio
//  cSql += "   AND A.AB6_NUMOS    = '" + M->AB6_NUMOS     + "'" + CHR(13)
    cSql += "   AND A.AB6_NUMOS    = '" + __cNumOSIXB     + "'" + CHR(13)

    cSql += "   AND A.R_E_C_D_E_L_ = ''"           + CHR(13)
    cSql += "   AND A.AB6_NUMOS    = C.AB7_NUMOS " + CHR(13)
    cSql += "   AND A.AB6_FILIAL   = C.AB7_FILIAL" + CHR(13)
    cSql += "   AND C.R_E_C_D_E_L_ = ''"           + CHR(13)
    cSql += "   AND A.AB6_CODCLI   = B.A1_COD "    + CHR(13)
    cSql += "   AND A.AB6_LOJA     = B.A1_LOJA"    + CHR(13)    
    cSql += "   AND C.AB7_CODPRO   = D.B1_COD "    + CHR(13)

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "SQL", .T., .T. )
 
    // Pesquisa o comentário a ser impresso
	/*
    If Select("T_COMENTARIO") > 0
   	   T_COMENTARIO->( dbCloseArea() )
    EndIf
   
    cSql := ""
    cSql := "SELECT YP_TEXTO"
    cSql += "  FROM " + RetSqlName("SYP")
    cSql += " WHERE YP_CHAVE = '" + Alltrim(SQL->AB6_MEMO) + "'"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMENTARIO", .T., .T. )
    */

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

    
    For nContar = 1 To 1

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
       oPrint:Say( _nLin, 0550, "NUM.OS "+ AllTrim(SQL->AB6_NUMOS) , oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
//       _nLin := _nLin + 10

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
//       MSBAR("CODE128",25,1.5,Alltrim(SQL->AB6_NUMOS),oPrint,.F.,,.T.,0.325,5.3,,,,.F.)
//       _nLin := _nLin + 150

//       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50
       
       oPrint:Say( _nLin, 0030, "COMPROVANTE RECEBIMENTO EQUIPAMENTO", oFont09b  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, "Recebemos de:", oFont09  )
       _nLin := _nLin + 50

       oPrint:Say( _nLin, 0010, Alltrim(SQL->A1_NOME), oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, "o equipamento abaixo discriminado:", oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, Alltrim(SQL->B1_DESC), oFont09  )
       _nLin := _nLin + 50       

       oPrint:Say( _nLin, 0010, "Nº de Série: " + Alltrim(SQL->AB7_NUMSER), oFont09  )
       _nLin := _nLin + 100       

       oPrint:Say( _nLin, 0010, "---------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0200, "COMENTÁRIOS/ACESSORIOS", oFont09b  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              

       // Imprime o comentario do Chamado Técnico
       If Select("T_ACESSORIOS") > 0
          T_ACESSORIOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT YP_TEXTO" 
       cSql += "  FROM " + RetSqlName("SYP")
       cSql += " WHERE YP_FILIAL  = ''"
       cSql += "   AND YP_CHAVE   = '" + Alltrim(SQL->AB7_MEMO1) + "'"
       cSql += "   AND YP_CAMPO   = 'AB7_MEMO1'
       cSql += "   AND YP_TEXTO  <> '\13\10'
       cSql += "   AND D_E_L_E_T_ = ''
       cSql += " ORDER BY YP_SEQ
 
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSORIOS", .T., .T. )

       cTexto := ""

       WHILE !T_ACESSORIOS->( EOF() )
      	  oPrint:Say( _nLin, 0010, StrTran(T_ACESSORIOS->YP_TEXTO, "\13\10", ""), oFont09  )                       
      	  _nLin := _nLin + 50   
          T_ACESSORIOS->( DbSkip() )
       ENDDO
          
       // Imprime a observação que será cobrado valor se ordem de serviço não aprovada
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0300, "OBSERVAÇÃO", oFont09b  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "Caso esta Ordem de Serviço venha a não ser aprova-", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "da, informamos que porderá ocorrer uma cobrança de", oFont09  )
       _nLin := _nLin + 50              

       If cFilAnt == "05"
          oPrint:Say( _nLin, 0010, "uma taxa de reprovação no valor de R$ 90,00 decor-", oFont09  )
       Else   
          oPrint:Say( _nLin, 0010, "uma taxa de reprovação no valor de R$ 75,00 decor-", oFont09  )
       Endif
       
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "rente do tempo de análise do técnico.             ", oFont09  )
       
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "----------------------------------------------------------------------------------", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, "Eu, em nome de", oFont09  )
       _nLin := _nLin + 50              
       oPrint:Say( _nLin, 0010, Alltrim(SQL->A1_NOME), oFont09  )
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
          Case cEmpAnt == "05"
               oPrint:Say( _nLin, 0010, "São Paulo, " + Dtoc(Date()), oFont09  )

               
       EndCase               
               
       _nLin := _nLin + 200              
       oPrint:Say( _nLin, 0010, "---------------------------------------     ----------------------------------", oFont09  )
       _nLin := _nLin + 50                     
       oPrint:Say( _nLin, 0010, "Assinatura do Cliente          CPF/RG", oFont09  )
       _nLin := _nLin + 100                     
       oPrint:Say( _nLin, 0010, "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ", oFont09  )
       
    Next nContar


	oPrint:Preview()

	DbCommitAll()
	MS_FLUSH()

Return()