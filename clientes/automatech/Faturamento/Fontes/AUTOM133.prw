#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM133.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/07/2012                                                          *
// Objetivo..: Relação de NF por Volumes Expedidos                                 * 
//**********************************************************************************

User Function AUTOM133()

   Private __Empresa := ""
   Private aComboBx1 := {}
   Private aComboBx2 := {"A - Analítico", "S - Sintético"}
   Private aComboBx3 := {"Sim", "Não"}
      
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3   

   Private cInicial  := Ctod("  /  /    ")
   Private cFinal	 := Ctod("  /  /    ")
   Private oGet1
   Private oGet2

   Private aVolumes  := {}

   U_AUTOM628("AUTOM133")

   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   __Empresa := SM0->M0_CODIGO
   aComboBx1 := U_AUTOM539(2, __Empresa)

//   Do Case
//      Case __Empresa == "01"
//           aComboBx1  := {"00 - CONSOLIDADO", "01 - PORTO ALEGRE", "02 - CAXIAS DO SUL", "03 - PELOTAS", "04 - SUPRIMENTOS"}
//      Case __Empresa == "02"
//           aComboBx1  := {"01 - TI CURITIBA"}
//      Case __Empresa == "03"
//           aComboBx1  := {"01 - ATECH"}
//   EndCase

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Relação de Notas Fiscais por Volumes Expedidos" FROM C(178),C(181) TO C(380),C(568) PIXEL

   @ C(004),C(005) Say "Data Emissão Inicial"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(005) Say "Data Emissão Final"    Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(005) Say "Filial"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(046),C(005) Say "Tipo de Visualização"  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Lista Volumes Zerados" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(065) MsGet oGet1 Var cInicial           Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(017),C(065) MsGet oGet2 Var cFinal             Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(065) ComboBox cComboBx1 Items aComboBx1 Size C(119),C(010) PIXEL OF oDlg
   @ C(044),C(065) ComboBox cComboBx2 Items aComboBx2 Size C(119),C(010) PIXEL OF oDlg
   @ C(058),C(065) ComboBox cComboBx3 Items aComboBx3 Size C(119),C(010) PIXEL OF oDlg

   @ C(080),C(065) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( GeraVolu() )
   @ C(080),C(103) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que gera a pesquisa conforme parâmetros informados
Static Function GERAVOLU()

   Local cSql           := ""
   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := "Vendas por Vendedor"
   Local cPict          := ""
   Local titulo         := "Vendas por Vendedor"
   Local nLin           := 80
   Local cSql           := ""
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 80
   Private tamanho      := "P"
   Private nomeprog     := "Relação de Títulos por Status"
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cPerg        := "VENDA"
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "Titulos-Status"
   Private cString      := "SC5"

   aConsulta := {}

   If Empty(cInicial)
      MsgAlert("Data inicial de pesquisa não informada.")
      Return .T.
   Endif
     
   If Empty(cFinal)
      MsgAlert("Data final de pesquisa não informada.")
      Return .T.
   Endif

   If cFinal < cInicial
      MsgAlert("Datas informadas são inválidas.")
      Return .T.
   Endif
   
   // Realiza as notas fiscais para o péríodo informado
   If Select("T_VOLUMES") > 0
   	  T_VOLUMES->( dbCloseArea() )
   EndIf
   
   If Substr(cComboBx2,01,01) == "A"
      cSql := ""
      cSql := "SELECT A.F2_FILIAL ,"
      cSql += "       A.F2_DOC    ,"
      cSql += "       A.F2_SERIE  ,"
      cSql += "       A.F2_EMISSAO,"
      cSql += "       A.F2_CLIENTE,"
      cSql += "       A.F2_LOJA   ,"
      cSql += "       B.A1_NOME   ,"
      cSql += "       A.F2_VOLUME1 "
      cSql += "  FROM " + RetSqlName("SF2") + " A, "
      cSql += "       " + RetSqlName("SA1") + " B  "
      cSql += " WHERE A.F2_EMISSAO >= '" + Dtos(cInicial) + "'"
      cSql += "   AND A.F2_EMISSAO <= '" + Dtos(cFinal)   + "'"
   
      Do Case
         Case Substr(cComboBx1,01,02) == "01"
              cSql += " AND A.F2_FILIAL = '01'"
         Case Substr(cComboBx1,01,02) == "02"
              cSql += " AND A.F2_FILIAL = '02'"
         Case Substr(cComboBx1,01,02) == "03"
              cSql += " AND A.F2_FILIAL = '03'"
      EndCase

      If Substr(cComboBx3,01,03) == "Não"
         cSql += "   AND A.F2_VOLUME1 <> 0 "   
      Endif   

      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND A.F2_CLIENTE = B.A1_COD "
      cSql += "   AND A.F2_LOJA    = B.A1_LOJA"
      cSql += "   AND B.D_E_L_E_T_ = ''       "
      cSql += " ORDER BY A.F2_FILIAL, A.F2_EMISSAO, A.F2_DOC"
      
   Else

      cSql := ""
      cSql := "SELECT F2_FILIAL ,               "
      cSql += "       F2_EMISSAO,               "
      cSql += "       SUM(F2_VOLUME1) AS VOLUMES"
      cSql += "  FROM " + RetSqlName("SF2")
      cSql += " WHERE F2_EMISSAO >= '" + Dtos(cInicial) + "'"
      cSql += "   AND F2_EMISSAO <= '" + Dtos(cFinal)   + "'"
      cSql += "   AND D_E_L_E_T_  = ''  " 

      Do Case
         Case Substr(cComboBx1,01,02) == "01"
              cSql += " AND F2_FILIAL = '01'"
         Case Substr(cComboBx1,01,02) == "02"
              cSql += " AND F2_FILIAL = '02'"
         Case Substr(cComboBx1,01,02) == "03"
              cSql += " AND F2_FILIAL = '03'"
      EndCase

      If Substr(cComboBx3,01,03) == "Não"
         cSql += "   AND F2_VOLUME1 <> 0 "   
      Endif   

      cSql += " GROUP BY F2_FILIAL, F2_EMISSAO"
      cSql += " ORDER BY F2_FILIAL, F2_EMISSAO"

   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VOLUMES", .T., .T. )

   If T_VOLUMES->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif
      
   aVolumes := {}

   // Carrega o array aConsulta com os dados a serem impressos
   If Substr(cComboBx2,01,01) == "A"
      T_VOLUMES->( DbGoTop() )
      WHILE !T_VOLUMES->( EOF() )
         aAdd( aVolumes, { T_VOLUMES->F2_FILIAL ,;
                           T_VOLUMES->F2_DOC    ,;
                           T_VOLUMES->F2_SERIE  ,;
                           T_VOLUMES->F2_EMISSAO,;
                           T_VOLUMES->F2_CLIENTE,;
                           T_VOLUMES->F2_LOJA   ,;
                           T_VOLUMES->A1_NOME   ,;
                           T_VOLUMES->F2_VOLUME1})
         T_VOLUMES->( DbSkip() )
      Enddo   
   Else
      T_VOLUMES->( DbGoTop() )
      WHILE !T_VOLUMES->( EOF() )
         aAdd( aVolumes, { T_VOLUMES->F2_FILIAL ,;
                           T_VOLUMES->F2_EMISSAO,;
                           T_VOLUMES->VOLUMES})
         T_VOLUMES->( DbSkip() )
      Enddo   
   Endif   
  
   // Envia para a função que imprime o relatório
   Processa( {|| GVOLUMEREL(Cabec1,Cabec2,"",nLin) }, "Aguarde...", "Gerando Relatório",.F.)

Return .T.

// Função que gera o relatório
Static Function GVOLUMEREL(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local cVendedor  := ""
   Local cCliente   := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local _Vendedor  := ""
   Local xContar    := 0
   Local nContar    := 0
   Local nOutrasDev := 0
   Local xVendedor  := ""
   Local xVendAnte  := ""
  
   Private __Filial := ""
   Private __Data   := ""

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 3000
   Private nPagina    := 0
   Private _nLin      := 0
   Private aPesquisa  := {}
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   Private aSintetico := {}
   Private nT_Geral   := 0

   Private nTotalD    := 0
   Private nTotalF    := 0
   Private nTotalP    := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetPortrait()   // Para Retrato
   oPrint:SetPaperSize(9) // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont5    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   // Ordena o Array aConsulta por Status
   // ASORT(aConsulta,,,{ | x,y | x[1] + x[4] < y[1] + y[4] } )

   // Início da impressão do relatório
   If Substr(cComboBx2,01,01) == "A"

      __Filial := aVolumes[01,01]
      __Data   := aVolumes[01,04]

      nPagina  := 0
      _nLin    := 10
      
      ProcRegua( RecCount() )

      // Envia para a função que imprime o cabeçalho do relatório
      CABECAVOL(__Filial, __Data, 1)

      For nContar = 1 to Len(aVolumes)
          
          If aVolumes[nContar,01] == __Filial

             If aVolumes[nContar,04] == __Data

                oPrint:Say(_nLin, 0100, aVolumes[nContar,02], oFont5)  
                oPrint:Say(_nLin, 0300, aVolumes[nContar,03], oFont5)  
                oPrint:Say(_nLin, 0450, Alltrim(aVolumes[nContar,05]) + "." + Alltrim(aVolumes[nContar,06]), oFont5)  
                oPrint:Say(_nLin, 0650, aVolumes[nContar,07], oFont5)  
                oPrint:Say(_nLin, 2080, STR(aVolumes[nContar,08],10), oFont5)  

                nTotalD := nTotalD + aVolumes[nContar,08]                
                nTotalF := nTotalF + aVolumes[nContar,08]                
                nTotalP := nTotalP + aVolumes[nContar,08]                
                            
                SomaLinhaVol(50,__Filial, __Data, 1)

                Loop

             Else
                               
                SomaLinhaVol(50,__Filial, __Data, 1)
                oPrint:Say(_nLin, 1700, "TOTAL DA DATA:", oFont10b)  
                oPrint:Say(_nLin, 2080, STR(nTotalD,10) , oFont10b)        
                SomaLinhaVol(100,__Filial, __Data, 1)

                nTotalD := 0
                __Data  := aVolumes[nContar,04]
              
                SomaLinhaVol(50,__Filial, __Data, 1)
                oPrint:Say(_nLin, 0950, "DATA..: " + Substr(__Data,07,02) + "/" + Substr(__Data,05,02) + "/" + Substr(__Data,01,04), oFont10b)        
                SomaLinhaVol(100,__Filial, __Data, 1)
               
                nContar := nContar - 1
                
                Loop
              
             Endif

          Else

             SomaLinhaVol(50,__Filial, __Data, 1)
             oPrint:Say(_nLin, 1700, "TOTAL DA DATA:", oFont10b)  
             oPrint:Say(_nLin, 2080, STR(nTotalD,10) , oFont10b)        
             SomaLinhaVol(100,__Filial, __Data, 1)

             SomaLinhaVol(50,__Filial, __Data, 1)
             oPrint:Say(_nLin, 1700, "TOTAL DA FILIAL:", oFont10b)  
             oPrint:Say(_nLin, 2080, STR(nTotalF,10)   , oFont10b)        
             SomaLinhaVol(100,__Filial, __Data, 1)

             nTotalD  := 0
             nTotalF  := 0
    
             __Filial := aVolumes[nContar,01]
            
             SomaLinhaVol(50,__Filial, __Data, 1)

             Do Case
                Case __Empresa == "01"
                     Do Case
                        Case __Filial == "01"
                             oPrint:Say(_nLin, 0950, "FILIAL: 01 - Porto Alegre" , oFont10b)  
                        Case __Filial == "02"
                             oPrint:Say(_nLin, 0950, "FILIAL: 02 - Caxias do Sul", oFont10b)  
                        Case __Filial == "03"
                             oPrint:Say(_nLin, 0950, "FILIAL: 04 - Pelotas"      , oFont10b)  
                     EndCase
                Case __Empresa == "02"
                     oPrint:Say(_nLin, 0950, "FILIAL: 01 - TI CURITIBA" , oFont10b)  
                Case __Empresa == "03"
                     oPrint:Say(_nLin, 0950, "FILIAL: 01 - ATECH" , oFont10b)  
             EndCase                   
  
             SomaLinhaVol(50,__Filial, __Data, 1)
             oPrint:Say(_nLin, 0950, "DATA..: " + Substr(__Data,07,02) + "/" + Substr(__Data,05,02) + "/" + Substr(__Data,01,04), oFont10b)        
             SomaLinhaVol(100,__Filial, __Data, 1)

             nContar := nContar - 1
              
             Loop

          Endif
        
      Next nContar    

      // Totalização da última Data
      SomaLinhaVol(50,__Filial, __Data, 1)
      oPrint:Say(_nLin, 1700, "TOTAL DA DATA:", oFont10b)  
      oPrint:Say(_nLin, 2080, STR(nTotalD,10) , oFont10b)        
      SomaLinhaVol(100,__Filial, __Data, 1)

      // Totalização da Filial
      SomaLinhaVol(50,__Filial, __Data, 1)
      oPrint:Say(_nLin, 1700, "TOTAL DA FILIAL:", oFont10b)  
      oPrint:Say(_nLin, 2080, STR(nTotalF,10)   , oFont10b)        
      SomaLinhaVol(100,__Filial, __Data, 1)
       
      // Totalização do Período
      SomaLinhaVol(50,__Filial, __Data, 1)
      oPrint:Say(_nLin, 1700, "TOTAL DO PERÍODO:", oFont10b)  
      oPrint:Say(_nLin, 2080, STR(nTotalP,10)    , oFont10b)        
      SomaLinhaVol(100,__Filial, __Data, 1)

   Else   

      __Filial := aVolumes[01,01]
      __Data   := aVolumes[01,02]

      nPagina  := 0
      _nLin    := 10
      
      ProcRegua( RecCount() )

      // Envia para a função que imprime o cabeçalho do relatório
      CABECAVOL(__Filial, __Data, 2)

      For nContar = 1 to Len(aVolumes)
          
          If aVolumes[nContar,01] == __Filial

             oPrint:Say(_nLin, 0950, Substr(aVolumes[nContar,02],07,02) + "/" + ;
                                     Substr(aVolumes[nContar,02],05,02) + "/" + ;
                                     Substr(aVolumes[nContar,02],01,04), oFont5)  
             oPrint:Say(_nLin, 1200, STR(aVolumes[nContar,03],10), oFont5)  

             nTotalF := nTotalF + aVolumes[nContar,03]                
             nTotalP := nTotalP + aVolumes[nContar,03]                
                            
             SomaLinhaVol(50,__Filial, __Data, 2)

             Loop

          Else
                               
             SomaLinhaVol(50,__Filial, __Data)
             oPrint:Say(_nLin, 0950, "TOTAL DA FILIAL:", oFont10b)  
             oPrint:Say(_nLin, 1200, STR(nTotalF,10)   , oFont10b)        
             SomaLinhaVol(100,__Filial, __Data)

             nTotalF  := 0
    
             __Filial := aVolumes[nContar,01]
            
             SomaLinhaVol(50,__Filial, __Data, 2)

             Do Case
                Case __Empresa == "01"
                     Do Case
                        Case __Filial == "01"
                             oPrint:Say(_nLin, 0950, "FILIAL: 01 - Porto Alegre" , oFont10b)  
                        Case __Filial == "02"
                             oPrint:Say(_nLin, 0950, "FILIAL: 02 - Caxias do Sul", oFont10b)  
                        Case __Filial == "03"
                             oPrint:Say(_nLin, 0950, "FILIAL: 04 - Pelotas"      , oFont10b)  
                     EndCase
                Case __Empresa == "02"
                     oPrint:Say(_nLin, 0950, "FILIAL: 01 - TI CURITIBA" , oFont10b)  
                Case __Empresa == "03"
                     oPrint:Say(_nLin, 0950, "FILIAL: 01 - ATECH" , oFont10b)  
             EndCase                     

             SomaLinhaVol(100,__Filial, __Data, 2)

             nContar := nContar - 1
              
             Loop

          Endif
        
      Next nContar    

      // Totalização da Filial
      SomaLinhaVol(50,__Filial, __Data, 2)
      oPrint:Say(_nLin, 0950, "TOTAL DA FILIAL:", oFont10b)  
      oPrint:Say(_nLin, 1200, STR(nTotalF,10)   , oFont10b)        
      SomaLinhaVol(100,__Filial, __Data, 2)
       
      // Totalização do Período
      SomaLinhaVol(50,__Filial, __Data, 2)
      oPrint:Say(_nLin, 0950, "TOTAL DO PERÍODO:", oFont10b)  
      oPrint:Say(_nLin, 1200, STR(nTotalP,10)    , oFont10b)        
      SomaLinhaVol(100,__Filial, __Data, 2)

   Endif

   If Select("T_VOLUMES") > 0
      T_VOLUMES->( dbCloseArea() )
   Endif

   oPrint:EndPage()
   
   MS_FLUSH()

   oPrint:Preview()

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABECAVOL(__Filial, __Data, __Tipo)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 2400 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"      , oFont21)

   If Substr(cComboBx2,01,01) == "A"
      oPrint:Say( _nLin, 0950, "RELAÇÃO DE VOLUMES FATURADOS - ANALÍTICO", oFont21)
   Else
      oPrint:Say( _nLin, 0950, "RELAÇÃO DE VOLUMES FATURADOS - SINTÉTICO", oFont21)
   Endif
               
   oPrint:Say( _nLin, 2100, Dtoc(Date()) + "-" + time()                  , oFont21)
   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM133.PRW", oFont21)
   oPrint:Say( _nLin, 0950, "PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal), oFont21)
   oPrint:Say( _nLin, 2100, "PAGINA: "    + Strzero(nPagina,5), oFont21)
   _nLin += 50

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 20
  
   If __Tipo == 1
      oPrint:Say( _nLin, 0100, "Nº NFiscal"             , oFont21)  
      oPrint:Say( _nLin, 0300, "Série"                  , oFont21)  
      oPrint:Say( _nLin, 0450, "Cliente"                , oFont21)  
      oPrint:Say( _nLin, 0650, "Descrição dos Clientes" , oFont21)  
      oPrint:Say( _nLin, 2100, "Volumes"                , oFont21)  
   Else
      oPrint:Say( _nLin, 0450, "Data"    , oFont21)  
      oPrint:Say( _nLin, 0650, "Volumes" , oFont21)  
   Endif

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 60

   Do Case
      Case __Empresa == "01"
           Do Case
              Case __Filial == "01"
                   oPrint:Say(_nLin, 0950, "FILIAL: 01 - Porto Alegre" , oFont10b)  
              Case __Filial == "02"
                   oPrint:Say(_nLin, 0950, "FILIAL: 02 - Caxias do Sul", oFont10b)  
              Case __Filial == "03"
                   oPrint:Say(_nLin, 0950, "FILIAL: 04 - Pelotas"      , oFont10b)  
           EndCase
      Case __Empresa == "02"
           oPrint:Say(_nLin, 0950, "FILIAL: 01 - TI CURITIBA" , oFont10b)  
      Case __Empresa == "03"
           oPrint:Say(_nLin, 0950, "FILIAL: 01 - ATECH" , oFont10b)  
   EndCase           

   _nLin += 50                                    
   
   If __Tipo == 1
      oPrint:Say(_nLin, 0950, "DATA..: " + Substr(__Data,07,02) + "/" + Substr(__Data,05,02) + "/" + Substr(__Data,01,04), oFont10b)        
      _nLin += 100
   Else
      _nLin += 50
   Endif   
   
Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaVol(nLinhas, __Filial, __Data, __Tipo)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABECAVOL(__Filial, __Data, __Tipo)
   Endif
   
Return .T.