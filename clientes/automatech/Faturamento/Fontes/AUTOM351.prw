#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM351.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 15/06/2016                                                          *
// Objetivo..: Consulta Cadastro de Usuários Protheus                              *
//**********************************************************************************

User Function AUTOM351()

   U_AUTOM628("AUTOM351")

   MsgRun("Aguarde! Carregando dados de usuários ...", "Cadastro Usuários Protheus",{|| psqdadosusuarios()})

Return(.T.)

// Função que carrega e mostra os usuários
Static Function psqdadosusuarios()

   Local cMemo1	      := ""
   Local oMemo1

   Local lChumba      := .F.
   Local nContar      := 0

   Private cPswFile   := "SIGAPSS.SPF"
   Private aPreGrupos := AllGroups()
   Private aGrupos    := {}
   Private aBrowse    := {}
   Private aGeral     := {}

   Private aStatus    := {'A - Ativos', 'I - Inativos', 'T - Todos' }

   Private cComboBx1
   Private cComboBx3   

   Private cTAtivos    := 0
   Private cTInativos  := 0
   Private cTUsuarios  := 0
   Private cTAbasgeral := 0
   Private cTAbasSelec := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlg

   // Carrega o array aGrupos
   aGrupos := {}
   aAdd( aGrupos, "XXXXXX - Todos os Grupos")

   For nContar = 1 to Len(aPreGrupos)
       aAdd(aGrupos, Alltrim(aPreGrupos[nContar][1][1]) + " - " + aPreGrupos[nContar][1][2])
   Next nContar    

   // Envia para a função que carrega os usuários conforme grupo selecionado
   CargaUsuarios(0)

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Usuários Protheus" FROM C(178),C(181) TO C(618),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(139),C(026) PIXEL NOBORDER OF oDlg
   @ C(196),C(319) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(208),C(319) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Grupos de Usuários"    Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(185) Say "Status"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(005) Say "Usuários Ativos"       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(050) Say "Usuários Inativos"     Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(100) Say "Total Usuários"        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(195),C(184) Say "Total Geral Abas"      Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(196),C(332) Say "ATIVOS"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(208),C(332) Say "INATIVOS"              Size C(028),C(007) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aGrupos Size C(144),C(010) PIXEL OF oDlg
   @ C(046),C(154) ComboBox cComboBx3 Items aStatus Size C(057),C(010) PIXEL OF oDlg

   @ C(205),C(005) MsGet oGet1 Var cTAtivos    Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(205),C(050) MsGet oGet2 Var cTInativos  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(205),C(100) MsGet oGet3 Var cTUsuarios  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(205),C(184) MsGet oGet4 Var cTAbasgeral Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(043),C(247) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( carga2usuarios() )
   @ C(043),C(298) Button "Impressão" Size C(037),C(012) PIXEL OF oDlg ACTION( LISTAUSUARIO() )
   @ C(043),C(351) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Cria o Grid para visualização
   oBrowse := TCBrowse():New( 075 , 005, 490, 170,,{'LG'                   + Space(05) ,;
                                                    'Código'               + Space(06) ,;
                                                    'Login'                + Space(20) ,;
                                                    'Nome'                 + Space(40) ,;
                                                    'Grupo'                + Space(06) ,;
                                                    'Descrição dos Grupos' + Space(20) ,;
                                                    'E-mail'               + Space(50) ,;
                                                    'Nº Abas'              + Space(10)},;
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// Função que carrega o array aBrowse para display
Static Function cargausuarios(_TipoJanela)

   Local nContar     := 0
   Local nProcura    := 0
   Local xNome_Grupo := ""

   // Carrega informações dos usuários para visualização no grid
   aBrowse := {}

   For nContar = 1 to 1200

       cId := StrZero(nContar,6)

       PswOrder(1)

       If PswSeek(cId,.T.)

          aReturn := PswRet()

          // Pesquisa o nome do grupo para display
          xNome_Grupo := ""

          For nProcura = 1 to Len(aGrupos)

              If len(aReturn[1][10]) <> 0
                 If Substr(aGrupos[nProcura],01,06) == aReturn[1][10][1]
                    xNome_Grupo := Substr(aGrupos[nProcura],10)
                 Endif
              Else
                 If Substr(aGrupos[nProcura],01,06) == "000000"
                    xNome_Grupo := Substr(aGrupos[nProcura],10)
                 Endif
              Endif                 
              
          Next nProcura    

          // Inclui dados do usuário no array aUsuarios
          If aReturn[1][17] == .F.
             aAdd( aBrowse, { IIF(aReturn[1][17] = .T., "9", "1")                        ,; // 01 - Indica se usuário está ativo/inativo
                              aReturn[1][1]                                              ,; // 02 - Código do Usuário
                              aReturn[1][2]                                              ,; // 03 - Login do Usuário
                              aReturn[1][4]                                              ,; // 04 - Nome completo do usuário
                              IIF(len(aReturn[1][10]) <> 0, aReturn[1][10][1], "000000") ,; // 05 - Código do grupo
                              xNome_Grupo                                                ,; // 06 - Descrição do grupo do usuário
                              aReturn[1][14]                                             ,; // 07 - E-mail do usuário
                              aReturn[1][15]})                                              // 08 - Nº de acessos simultâneos
             // Totalizadores
             If aReturn[1][17] == .F.
                cTAtivos    := cTAtivos   + 1
             Else
                cTInativos  := cTInativos + 1
             Endif

             cTUsuarios  := cTUsuarios + 1

             cTAbasgeral := cTAbasgeral + aReturn[1][15]

             cTAbasSelec := cTAbasSelec + aReturn[1][15]

          Endif                              

          // Inclui dados do usuário no array aGeral
          aAdd( aGeral,  { IIF(aReturn[1][17] = .T., "9", "1")                        ,; // 01 - Indica se usuário está ativo/inativo
                           aReturn[1][1]                                              ,; // 02 - Código do Usuário
                           aReturn[1][2]                                              ,; // 03 - Login do Usuário
                           aReturn[1][4]                                              ,; // 04 - Nome completo do usuário
                           IIF(len(aReturn[1][10]) <> 0, aReturn[1][10][1], "000000") ,; // 05 - Código do grupo
                           xNome_Grupo                                                ,; // 06 - Descrição do grupo do usuário
                           aReturn[1][14]                                             ,; // 07 - E-mail do usuário
                           aReturn[1][15]})                                              // 08 - Nº de acessos simultâneos
       Endif

   Next nContar    

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "" })
   Endif

   If _TipoJanela == 0
      Return(.T.)
   Endif

   oBrowse:SetArray(aBrowse) 

   oBrowse:bHeaderClick := {|oObj,nCol| oBrowse:aArray := Ordenar(nCol,oBrowse:aArray),oBrowse:Refresh()}
      
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]}}

Return(.T.)

// Função que carrega o array aBrowse para display pelo botão pesquisar
Static Function carga2usuarios()

   Local nContar     := 0

   // Carrega informações dos usuários para visualização no grid
   aBrowse := {}

   cTAtivos    := 0
   cTInativos  := 0
   cTUsuarios  := 0
   cTAbasgeral := 0

   For nContar = 1 to Len(aGeral)

       // Pesquisa os usuários conforme o grupo selecionado
       If Substr(cComboBx1,01,06) == "XXXXXX"
       Else
          If Substr(cComboBx1,01,06) == aGeral[nContar,05]
          Else
             Loop
          Endif
       Endif

       // Pesquisa os usuários conforme o status selecionado
       If Substr(cComboBx3,01,01) == "T"
       Else
          If Substr(cComboBx3,01,01) == "A"
             If aGeral[nContar,01] == "9"
                Loop
             Endif
          Endif
          If Substr(cComboBx3,01,01) == "I"
             If aGeral[nContar,01] == "1"
                Loop
             Endif
          Endif
       Endif

       // Carrega o array aBrowse
       aAdd( aBrowse,  {aGeral[nContar,01]  ,; // 01 - Indica se usuário está ativo/inativo
                        aGeral[nContar,02]  ,; // 02 - Código do Usuário
                        aGeral[nContar,03]  ,; // 03 - Login do Usuário
                        aGeral[nContar,04]  ,; // 04 - Nome completo do usuário
                        aGeral[nContar,05]  ,; // 05 - Código do grupo
                        aGeral[nContar,06]  ,; // 06 - Descrição do grupo do usuário
                        aGeral[nContar,07]  ,; // 07 - E-mail do usuário
                        aGeral[nContar,08]})   // 08 - Nº de acessos simultâneos

       // Totalizadores
       If aGeral[nContar,01] == "1"
          cTAtivos    := cTAtivos   + 1
       Else
          cTInativos  := cTInativos + 1
       Endif

       cTUsuarios  := cTUsuarios + 1

       cTAbasgeral := cTAbasgeral + aGeral[nContar,08]
       cTAbasSelec := cTAbasSelec + aGeral[nContar,08]

   Next nContar

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "" })
   Endif

   // Refresh do grid aBrowse
   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]}}

Return(.T.)

// ***********************************************************************
// Função que gera o relatório de usuários com quebra por grupo de acesso*
// ***********************************************************************
Static Function LISTAUSUARIO()

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

   Private oPrint, oFont5, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21

   Private nLimvert   := 2000
   Private nPagina    := 0
   Private _nLin      := 0
   Private cEmail     := ""
   Private cReduzido  := ""
   Private aPaginas   := {}
   Private cErroEnvio := 0

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
   oPrint:SetLandScape()  // Para Paisagem
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

   // Ordena o Array para Impressão
// ASORT(aBrowse,,,{ | x,y | x[5] + x[3] < y[5] + y[3] } )
 
   If Len(aBrowse) == 0
      Msgalert("Não existem dados a serem listados.")
      Return .T.
   Endif

   cGrupo     := aBrowse[01,05]
   cNomeGrupo := aBrowse[01,06]

   nPagina  := 0
   _nLin    := 10
      
   ProcRegua( Len(aBrowse) )

   // Envia para a função que imprime o cabeçalho do relatório
   CABEUSUARIO(cGrupo, cNomeGrupo, nPagina)

   For nContar = 1 to Len(aBrowse)
   
      If Alltrim(aBrowse[nContar,5]) == Alltrim(cGrupo)

         oPrint:Say(_nLin, 0450, aBrowse[nContar,03]     , oFont5)  
         oPrint:Say(_nLin, 1100, aBrowse[nContar,04]     , oFont5)  
         oPrint:Say(_nLin, 2600, str(aBrowse[nContar,08]), oFont5)  

         If aBrowse[nContar,01] == "1"
            oPrint:Say(_nLin, 2900, "ATIVO", oFont5)  
         Else
            oPrint:Say(_nLin, 2900, "INATIVO", oFont5)  
         Endif

         SomaLinhaVen(40,cGrupo, cNomeGrupo)            

      Else

         cGrupo     := aBrowse[nContar,05]
         cNomeGrupo := aBrowse[nContar,06]

         SomaLinhaVen(50,cGrupo, cNomeGrupo)            
            
         oPrint:Say(_nLin, 1100, "GRUPO: " + Alltrim(cGrupo) + " - " + Alltrim(cNomeGrupo), oFont10b)  

         SomaLinhaVen(100,cGrupo, cNomeGrupo)            

         nContar := nContar - 1

      Endif

   Next nContar

   oPrint:EndPage() 
   oPrint:Preview()   
   
   MS_FLUSH()

Return .T.

// Imprime o cabeçalho do relatório de Faturamento por Vendedor
Static Function CABEUSUARIO(cGrupo, cNomeGrupo)

   oPrint:StartPage()

   nPagina := nPagina + 1

   _nLin   := 60
 
   oPrint:Line( _nLin, 0100, _nLin, 3350 )

   _nLin += 30

   oPrint:Say( _nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont09  )
   oPrint:Say( _nLin, 1400, "RELAÇÃO DE USUÁRIOS POR GRUPOS"       , oFont09  )
   oPrint:Say( _nLin, 3000, Dtoc(Date()) + " - " + time()          , oFont09  )

   _nLin += 50

   oPrint:Say( _nLin, 0100, "AUTOM144", oFont09  )
   oPrint:Say( _nLin, 3000, "Página: " + Strzero(nPagina,6), oFont09  )

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 20

   oPrint:Say( _nLin, 0450, "LOGIN"                 , oFont21)  
   oPrint:Say( _nLin, 1100, "DESCRICAO DOS USUÁRIOS", oFont21)  
   oPrint:Say( _nLin, 2670, "Nº ACESSOS"            , oFont21)  
   oPrint:Say( _nLin, 2900, "STATUS"                , oFont21)  

   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 3350 )
   _nLin += 50
   oPrint:Say( _nLin, 1100, "GRUPO: " + Alltrim(cGrupo) + " - " + Alltrim(cNomeGrupo), oFont10b)
   _nLin += 60

Return .T.

// Função que soma linhas para impressão
Static Function SomaLinhaVen(nLinhas,cGrupo, cNomeGrupo)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10
      oPrint:EndPage()
      CABEUSUARIO(cGrupo, cNomeGrupo)
   Endif
   
Return(.T.)

// Função que soma linhas para impressão
Static Function MOSTRADADOSUSR()

   Local cGrupo

   PswOrder(1)

   If PswSeek( '000009', .F. )   
      cGrupo := PswRet()[1][2] // Retorna nome do Grupo de Usuário
   EndIf
   
Return