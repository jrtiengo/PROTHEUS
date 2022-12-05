#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR85.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 28/02/2012                                                          *
// Objetivo..: Programa que lê o arquivo de inventário (TXT) e compara com a tabe- *
//             la SBF (Lote X Endereçamento)                                       *
//**********************************************************************************

User Function AUTOMR85()

   Private cGet1       := ""
   Private oGet1    
   Private aListBox1   := {}
   Private oListBox1
   Private NomeCam1    := "c:\automatech\fontes\inventario\inventario.txt"
   Private cCaminho    := ""
   Private lChumba     := .F.
   Private aBrowse     := {}
   Private oBrowse
   Private aInventario := {}
   Private aDiferenca  := {}
   Private cMemo1	   := ""
   Private cMemo2	   := ""
   Private oMemo1
   Private oMemo2

   Private cComboBx1 := ""
   Private aComboBx1 := {'  ', '01 - Porto Alegre', '02 - Caxias do Sul', '03 - Pelotas' }

   Private cComboBx2 := ""
   Private aComboBx2 := {'1 - Código', '2 - Descrição', '3 - Nº Série' }

   Private oDlg

   U_AUTOM628("AUTOMR85")

   DEFINE MSDIALOG oDlg TITLE "INVENTÁRIO DO ESTOQUE" FROM C(178),C(181) TO C(618),C(967) PIXEL

   oBrowse := TCBrowse():New( 040 , 005, 490, 150,,{'Codigo', 'Descrição', 'Nº Série', 'Qtd Teórica', 'Qtd Física', 'Diferença'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   aAdd( aBrowse, { '','','','','','' } )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;
                        } }
// oBrowse:bLDblClick := {|| ZOOMPRODUTO(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]) } 

   oBrowse:Refresh()

   @ C(002),C(187) Say "Filial"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(002),C(260) Say "Ordenação"                         Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(003),C(004) Say "Arquivo de Inventário"             Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(022),C(005) Say "Comparativo Teórico X Físico"      Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(153),C(005) Say "Leituras não localizadas no TOTVS" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(153),C(321) Say "Duplo Click - Zoom do Produto"     Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(011),C(004) MsGet NomeCam1 When lChumba Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(010),C(170) Button "..."          Size C(012),C(012) PIXEL OF oDlg ACTION( BUSCAINVE() )

   @ C(011),C(187) ComboBox cComboBx1 Items aComboBx1 Size C(071),C(010) PIXEL OF oDlg
   @ C(011),C(261) ComboBox cComboBx2 Items aComboBx2 Size C(055),C(010) PIXEL OF oDlg
   @ C(162),C(004) GET oMemo1 Var cMemo1 MEMO         Size C(384),C(054) PIXEL OF oDlg

   @ C(009),C(321) Button "Importar" Size C(032),C(012) PIXEL OF oDlg ACTION( IMPORTAINV( NomeCam1, cComboBx1) )
   @ C(009),C(355) Button "Voltar"   Size C(032),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do arquivo de invetário a ser utilizado ara importação
Static Function BUSCAINVE()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Inventário",1,"C:\",.F.,16,.F.)
   NomeCam1 := Upper(cCaminho)

Return .T. 

// Função que realiza a pesquisa e importação dos dados dos produtos
Static Function IMPORTAINV( _Caminho, _Filial )

   Local cSql      := ""
   Local cConteudo := ""
   Local cProduto  := ""
   Local cSerie    := ""
   Local nContar   := 0
   Local lAchou    := .F.
   
   aBrowse     := {}
   aInventario := {}

   If Empty(Alltrim(_Caminho))
      MsgAlert("Arquivo de Inventário a ser importado não informado.")
      Return .T.
   Endif
   
   If !File(Alltrim(_Caminho))
      MsgAlert("Arquivo informado para importação inexistente. Verifique !!")
      Return .T.
   Endif

   If Empty(Alltrim(_Filial))
      MsgAlert("Necessário indicar a Filial que pertence o inventário.")
      Return .T.
   Endif

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.BF_PRODUTO,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       A.BF_NUMSERI,"
   cSql += "       A.BF_QUANT   "
   cSql += "  FROM " + RetSqlName("SBF") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.BF_QUANT  <> 0 "
   cSql += "   AND A.BF_PRODUTO = B.B1_COD "
   cSql += "   AND A.BF_FILIAL  = '" + Alltrim(Substr(_Filial,01,02)) + "'"

   Do Case
      Case Substr(cComboBx2,1,1) == "1"
           cSql += " ORDER BY A.BF_PRODUTO "
      Case Substr(cComboBx2,1,1) == "2"
           cSql += " ORDER BY B.B1_DESC "
      Case Substr(cComboBx2,1,1) == "3"
           cSql += " ORDER BY A.BF_NUMSERI "
   EndCase        

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      aBrowse    := {}
      aDiferenca := {}
   Else
      T_PRODUTOS->( DbGoTop() )
      WHILE !T_PRODUTOS->( EOF() )
         aAdd( aBrowse, {Alltrim(T_PRODUTOS->BF_PRODUTO)                                        , ;
                         Alltrim(T_PRODUTOS->B1_DESC) + Alltrim(T_PRODUTOS->B1_DAUX) + Space(40), ;
                         T_PRODUTOS->BF_NUMSERI + space(30)                                     , ;
                         Str(T_PRODUTOS->BF_QUANT,10)                                           , ;
                         Str(0,10)                                                              , ;
                         Str(0,10) } )
         T_PRODUTOS->( DbSkip() )
      ENDDO
   Endif                              

   // Abre o arquivo ser lido da Aprove e atualiza a coluna do Browse
//   nHandle := FOPEN(Alltrim(_Caminho), FO_READWRITE + FO_SHARED)

   nHandle := FOPEN(Alltrim(_Caminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""
   cMemo1    := ""

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
                
       Else
                
          cProduto := Strzero(Int(Val(Substr(cConteudo,01,50))),6)
          cSerie   := Substr(cConteudo,51,45)
          lAchou   := .F.

          aAdd( aInventario, { cProduto, cSerie } )

          // Localiza o código lido no Array aBrowse
          For nLocaliza = 1 to Len(aBrowse)
              If Alltrim(aBrowse[nLocaliza,1]) == Alltrim(cProduto) .AND. Alltrim(aBrowse[nLocaliza,3]) == Alltrim(cSerie)
                 aBrowse[nLocaliza,5] := Str(1,10)
                 aBrowse[nLocaliza,6] := Str(int(val(aBrowse[nLocaliza,4])) - int(val(aBrowse[nLocaliza,5])),10)
                 lAchou := .T.
                 Exit   
              Endif   
          Next nLocaliza

          If !lAchou
             aAdd( aDiferenca, {Alltrim(cProduto), Alltrim(cSerie) } )
          Endif
          
          cConteudo := ""
          cProduto  := ""
          cSerie    := ""

          If Substr(xBuffer, nContar, 1) == chr(10)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    

   // Calcula a Coluna Diferença
   For nContar = 1 to Len(aBrowse)
       aBrowse[nContar,6] := Str(int(val(aBrowse[nContar,4])) - int(val(aBrowse[nContar,5])),10)       
   Next nContar    

   // Ordena o Array aDiferenca
   ASORT(aDiferenca,,,{ | x,y | x[1] + x[2] < y[1] + y[2] } )

   cMemo1 := ""

   For nContar = 1 to Len(aDiferenca)
       cMemo1 := cMemo1 + Alltrim(aDiferenca[nContar,1]) + " - " + Alltrim(aDiferenca[nContar,2]) + chr(13) + chr(10)   
   Next nContar

   cMemo1 := Alltrim(cMemo1)

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;
                        } }
   oBrowse:bLDblClick := {|| ZOOMPRODUTO(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]) } 
   
   oBrowse:Refresh()

Return .T.

// Função que visualiza somente o ítem selecionado
Static Function ZOOMPRODUTO( _Codigo, _Descricao )

   Local lChumba     := .F.
   Local cCodigo     := _Codigo
   Local cDescricao  := _Descricao
   Local cProtheus   := 0
   Local cInventario := 0
   Local cDiferenca  := 0
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Local aSerie     := {}
   Local oBrowse1
   Local nContar    := 0   
   Local nLocaliza  := 0
   Local cSerie01   := ""
   Local cSerie02   := ""
   Local lAchei     := .F.

   Private XoDlg

   // Carrega os nº de séries do produto selecionado
   aSerie    := {}
   aOutros   := {}
   cProtheus := 0
   lAche     := .F.

   For nContar = 1 to Len(aBrowse)
       If Alltrim(aBrowse[nContar,1]) <> Alltrim(_Codigo)
          Loop
       Endif
  
       cSerie01 := Alltrim(aBrowse[nContar,3])
       cSerie02 := ""
                                              
       // Pesquisa o nº de série do Inventário
       For nLocaliza = 1 to Len(aInventario)
           If Alltrim(aInventario[nLocaliza,1]) <> Alltrim(_Codigo)
              Loop
           Endif

           If Alltrim(aInventario[nLocaliza,2]) == Alltrim(cSerie01)
              cSerie02 := Alltrim(aInventario[nLocaliza,2])
              Exit
           Endif
       Next nLocaliza    

       aAdd( aSerie, { Alltrim(cSerie01), Alltrim(cSerie02) } )

       cProtheus := cProtheus + 1

   Next nContar

   // Adiciona os não encontrados
   For nContar = 1 to Len(aDiferenca)
       If Alltrim(aDiferenca[nContar,1]) == Alltrim(_Codigo)
          aAdd( aSerie, { '', aDiferenca[nContar,2] } )
       Endif
   Next nContar

   // Atualiza os contadores
   cProtheus   := 0
   cInventario := 0
   For nContar = 1 to Len(aSerie)
       If !Empty(Alltrim(aSerie[nContar,1]))
          cProtheus := cProtheus + 1
       Endif
       If !Empty(Alltrim(aSerie[nContar,2]))
          cInventario := cInventario + 1
       Endif                        
   Next nContar
   
   cDiferenca := cProtheus - cInventario       

   DEFINE MSDIALOG XoDlg TITLE "Análise Individual de Produto" FROM C(178),C(181) TO C(555),C(646) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(003),C(005) Say "Código"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF XoDlg
   @ C(149),C(006) Say "Total Protheus"   Size C(039),C(008) COLOR CLR_BLACK PIXEL OF XoDlg
   @ C(162),C(007) Say "Total Inventário" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF XoDlg
   @ C(174),C(008) Say "Diferença"        Size C(028),C(008) COLOR CLR_BLACK PIXEL OF XoDlg

   @ C(012),C(006) MsGet oGet1 Var cCodigo     When lChumba Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF XoDlg
   @ C(012),C(037) MsGet oGet2 Var cDescricao  When lChumba Size C(192),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF XoDlg

   @ C(148),C(047) MsGet oGet3 Var cProtheus   When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF XoDlg
   @ C(161),C(047) MsGet oGet4 Var cInventario When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF XoDlg
   @ C(174),C(047) MsGet oGet5 Var cDiferenca  When lChumba Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF XoDlg

   @ C(160),C(191) Button "Voltar" Size C(037),C(012) PIXEL OF XoDlg ACTION( XoDlg:End() )

   // Cria Browse
   oBrowse1 := TCBrowse():New( 30, 07, 285, 156,, {Padr('Nº Série Protheus',60),Padr('Nº Série Inventário',60) },{20,50,50,50},XoDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
   // Seta vetor para a browse
   oBrowse1:SetArray(aSerie) 
	
   // Monta a linha a ser exibida no Browse
   oBrowse1:bLine := {||{ aSerie[ oBrowse1:nAt, 01 ], aSerie[ oBrowse1:nAt, 02 ] } }

   ACTIVATE MSDIALOG XoDlg CENTERED 

Return(.T.)