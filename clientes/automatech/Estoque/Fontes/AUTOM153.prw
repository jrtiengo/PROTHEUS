#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM153.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/02/2013                                                          *
// Objetivo..: Pesquisa de Produtos para o Projetos                                *
//**********************************************************************************

User Function AUTOM153()

   Private cPedido := Space(06)
   Private cNota   := Space(06)
   Private cSerie  := Space(20)

   Private oGet1
   Private oGet2
   Private oGet3

   Private aBrowse := {}

   U_AUTOM628("AUTOM153")

   aAdd(aBrowse, {'','','','','','',''})

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Consulta Produtos - Projetos" FROM C(178),C(181) TO C(387),C(754) PIXEL

   @ C(005),C(005) Say "Nº P.Venda"  Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(051) Say "Nº N.Fiscal" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(096) Say "Nº de Série" Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1 Var cPedido Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(051) MsGet oGet2 Var cNota   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(096) MsGet oGet3 Var cSerie  Size C(090),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(011),C(192) Button "Pesquisar" Size C(043),C(012) PIXEL OF oDlg ACTION( PesqProj(cPedido, cNota, cSerie) )
   @ C(011),C(238) Button "Voltar"    Size C(043),C(012) PIXEL OF oDlg ACTION( Odlg:End() )

   oBrowse := TCBrowse():New( 040 , 006, 355, 090,,{'FL','Nº PV', 'N.Fiscal', 'Série', 'Qtd', 'Descrição dos Produtos', 'Código'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;                         
                         aBrowse[oBrowse:nAt,05],;                         
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa os produtos conforme o parâmetro informado
Static Function PESQPROJ(_Pedido, _Nota, _Serie)

   Local cSql := ""
   
   If Empty(Alltrim(_Pedido) + Alltrim(_Nota) + Alltrim(_Serie))
      MsgAlert("Necessário informar Nº do Pedido, Nº Nota Fiscal ou Nº de Série a ser pesquisado.")
      Return .T.
   Endif
           
   aBrowse := {}

   If !Empty(Alltrim(_Pedido))
      _Nota  := ""
      _Serie := ""
   Endif
      
   If !Empty(Alltrim(_Nota))
      _Pedido := ""
      _Serie  := ""
   Endif

   If !Empty(Alltrim(_Serie))
      _Pedido := ""
      _Nota   := ""
   Endif

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()

   // Pesquisa pelo nº do Pedido de Venda
   If !Empty(_Pedido)
   
      If Select("T_PEDIDOX") > 0
         T_PEDIDOX->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT C6_FILIAL ,"
      cSql += "       C6_NOTA   ,"
      cSql += "       C6_SERIE  ,"
      cSql += "       C6_QTDVEN ,"
      cSql += "       C6_DESCRI ,"
      cSql += "       C6_PRODUTO,"
      cSql += "       C6_NUM     "
      cSql += "  FROM " + RetSqlName("SC6")
      cSql += " WHERE C6_NUM     = '" + Alltrim(_Pedido) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOX", .T., .T. )
      
      T_PEDIDOX->( DbGoTop() )
      
      WHILE !T_PEDIDOX->( Eof() )

         _xFilial := T_PEDIDOX->C6_FILIAL
         _xPedido := T_PEDIDOX->C6_NUM
         _xNota   := T_PEDIDOX->C6_NOTA
         _xSerie  := T_PEDIDOX->C6_SERIE
         _xQuanti := T_PEDIDOX->C6_QTDVEN
         _xNome   := T_PEDIDOX->C6_DESCRI
         _xCodigo := T_PEDIDOX->C6_PRODUTO

         aAdd( aBrowse, { _xFilial, _xPedido, _xNota, _xSerie, _xQuanti, _xNome, _xCodigo} )

         T_PEDIDOX->( DbSkip() )

      ENDDO

   Endif
      
   // Pesquisa pelo nº da Nota Fiscal
   If !Empty(_Nota)
   
      If Select("T_PEDIDOX") > 0
         T_PEDIDOX->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT C6_FILIAL ,"
      cSql += "       C6_NOTA   ,"
      cSql += "       C6_SERIE  ,"
      cSql += "       C6_QTDVEN ,"
      cSql += "       C6_DESCRI ,"
      cSql += "       C6_PRODUTO,"
      cSql += "       C6_NUM     "	
      cSql += "  FROM " + RetSqlName("SC6")
      cSql += " WHERE C6_NOTA    = '" + Alltrim(_Nota) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOX", .T., .T. )
      
      T_PEDIDOX->( DbGoTop() )
      
      WHILE !T_PEDIDOX->( Eof() )

         _xFilial := T_PEDIDOX->C6_FILIAL
         _xPedido := T_PEDIDOX->C6_NUM
         _xNota   := T_PEDIDOX->C6_NOTA
         _xSerie  := T_PEDIDOX->C6_SERIE
         _xQuanti := T_PEDIDOX->C6_QTDVEN
         _xNome   := T_PEDIDOX->C6_DESCRI
         _xCodigo := T_PEDIDOX->C6_PRODUTO

         aAdd( aBrowse, { _xFilial, _xPedido, _xNota, _xSerie, _xQuanti, _xNome, _xCodigo} )

         T_PEDIDOX->( DbSkip() )

      ENDDO

   Endif

   // Pesquisa pelo nº de Série
   If !Empty(_Serie)
   
      If Select("T_PEDIDOX") > 0
         T_PEDIDOX->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.DB_NUMSERI, "
      cSql += "       A.DB_DATA   , "
      cSql += "       A.DB_DOC    , "
      cSql += "       A.DB_SERIE  , "
      cSql += "       A.DB_CLIFOR , "
      cSql += "       A.DB_LOJA   , "
      cSql += "       A.DB_TIPO   , "
      cSql += "       A.DB_PRODUTO, "
      cSql += "       B.B1_DESC   , "
      cSql += "       B.B1_DAUX   , "
      cSql += "       A.DB_ORIGEM , "
      cSql += "       C.C6_FILIAL , "
      cSql += "       C.C6_NOTA   , "
      cSql += "       C.C6_SERIE  , "
      cSql += "       C.C6_QTDVEN , "
      cSql += "       C.C6_DESCRI , "
      cSql += "       C.C6_PRODUTO, "
      cSql += "       C.C6_NUM     	"
      cSql += "  FROM " + RetSqlName("SDB") + " A, "
      cSql += "       " + RetSqlName("SB1") + " B, "
      cSql += "       " + RetSqlName("SC6") + " C  "
      cSql += " WHERE DB_NUMSERI LIKE '%" + Alltrim(_Serie) + "%'"
      cSql += "   AND A.DB_PRODUTO = B.B1_COD   "
      cSql += "   AND A.DB_ORIGEM  = 'SC6'      "
      cSql += "   AND A.D_E_L_E_T_ = ''         "
      cSql += "   AND A.DB_DOC     = C.C6_NOTA  "
      cSql += "   AND A.DB_FILIAL  = C.C6_FILIAL"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOX", .T., .T. )

      T_PEDIDOX->( DbGoTop() )
      
      WHILE !T_PEDIDOX->( Eof() )

         _xFilial := T_PEDIDOX->C6_FILIAL
         _xPedido := T_PEDIDOX->C6_NUM
         _xNota   := T_PEDIDOX->C6_NOTA
         _xSerie  := T_PEDIDOX->C6_SERIE
         _xQuanti := T_PEDIDOX->C6_QTDVEN
         _xNome   := T_PEDIDOX->C6_DESCRI
         _xCodigo := T_PEDIDOX->C6_PRODUTO

         aAdd( aBrowse, { _xFilial, _xPedido, _xNota, _xSerie, _xQuanti, _xNome, _xCodigo} )

         T_PEDIDOX->( DbSkip() )

      ENDDO

   Endif

   If Len(aBrowse) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd(aBrowse, {'','','','','','',''})
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                            aBrowse[oBrowse:nAt,02],;
                            aBrowse[oBrowse:nAt,03],;
                            aBrowse[oBrowse:nAt,04],;                         
                            aBrowse[oBrowse:nAt,05],;                         
                            aBrowse[oBrowse:nAt,06],;                         
                            aBrowse[oBrowse:nAt,07]} }
   Endif   

Return(.T.)