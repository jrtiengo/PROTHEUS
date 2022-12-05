#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM127.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/07/2012                                                          *
// Objetivo..: Programa que efetiva a reserva de produtos pela solicitação de re-  *
//             serva de produtos por vendedor.                                     *
// Parâmetros: Sem parãmetros                                                      *
//**********************************************************************************

// Função que define a Window
User Function AUTOM127()

   Local cSql    := ""
   Local nContar := 0
   Local _JaTem  := .F.

   Private oDlg

   Private aBrowse := {}

   U_AUTOM628("AUTOM127")

   If Select("T_RESERVA") > 0
      T_RESERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZP_NUME  ,"
   cSql += "       A.ZZP_FILIAL,"
   cSql += "       A.ZZP_PEDI  ,"
   cSql += "       A.ZZP_VEND  ,"
   cSql += "       A.ZZP_CODI  ,"
   cSql += "       A.ZZP_ITEM  ,"
   cSql += "       A.ZZP_DESC  ,"
   cSql += "       A.ZZP_QTPV  ,"
   cSql += "       A.ZZP_QTRE  ,"
   cSql += "       A.ZZP_LOCA  ,"
   cSql += "       A.ZZP_DATA  ,"
   cSql += "       A.ZZP_HORA  ,"
   cSql += "       A.ZZP_DRES  ,"
   cSql += "       A.ZZP_USUA  ,"
   cSql += "       A.ZZP_HRES  ,"
   cSql += "       B.A3_NOME   ,"
   cSql += "       C.B1_LOCALIZ "
   cSql += "  FROM " + RetSqlName("ZZP") + " A, "
   cSql += "       " + RetSqlName("SA3") + " B, "
   cSql += "       " + RetSqlName("SB1") + " C  "   
   cSql += " WHERE A.ZZP_DRES = ''"
   cSql += "   AND A.ZZP_VEND = B.A3_COD"
   cSql += "   AND A.ZZP_CODI = C.B1_COD"
   cSql += " ORDER BY A.ZZP_FILIAL, B.A3_NOME, A.ZZP_DATA, A.ZZP_HORA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESERVA", .T., .T. )
   
   If T_RESERVA->( EOF() )
      aAdd( aBrowse, { '', '', '', '', '', '', '', '', '', '', '', '', '', '' } )
   Else
      T_RESERVA->( DbGoTop() )
      WHILE !T_RESERVA->( EOF() )

         // Verifica se Proposta Comercial já está contida no array aBrowse
         _JaTem := .F.
         For nContar = 1 to Len(aBrowse)
             If Alltrim(aBrowse[nContar,03]) == Alltrim(T_RESERVA->ZZP_PEDI)
                _JaTem := .T.
                Exit
             Endif
         Next nContar       

         If _JaTem
            T_RESERVA->( DbSkip() )
            Loop
         Endif

         // Carrega o array aBrowse
         aAdd( aBrowse, { T_RESERVA->ZZP_FILIAL        ,;
                          T_RESERVA->A3_NOME           ,;
                          T_RESERVA->ZZP_PEDI          ,;
                          SUBSTR(T_RESERVA->ZZP_DATA,07,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,05,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,01,04)               ,;
                          DATE() - CTOD(SUBSTR(T_RESERVA->ZZP_DATA,07,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,05,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,01,04)),;
                          T_RESERVA->ZZP_HORA          ,;
                          T_RESERVA->ZZP_CODI          ,;
                          T_RESERVA->ZZP_DESC          ,;
                          T_RESERVA->ZZP_VEND          ,;
                          T_RESERVA->ZZP_QTRE          ,;
                          T_RESERVA->ZZP_LOCA          ,;
                          T_RESERVA->B1_LOCALIZ        ,;
                          ""                           ,;
                          T_RESERVA->ZZP_NUME          ,;
                          T_RESERVA->ZZP_ITEM          })

          T_RESERVA->( DbSkip() )

      ENDDO

   Endif

   DEFINE MSDIALOG oDlg TITLE "Solicitações de Reservas de Produtos" FROM C(178),C(181) TO C(532),C(842) PIXEL

   @ C(160),C(248) Button "Reservar" Size C(037),C(012) PIXEL OF oDlg ACTION( EFETIVARES() )
   @ C(160),C(287) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 002 , 002, 420, 195,,{'FL', 'Vendedor', 'P.Comercial', 'Data', 'Dias', 'Hora', 'Codigo', 'Descrição Produtos','Solicitação' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;                                                  
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,14]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a tela de efetivação da reserva
Static Function EFETIVARES()

   Local lChumba    := .F.

   Private cVendedor  := aBrowse[oBrowse:nAt,09]
   Private cNvendedor := aBrowse[oBrowse:nAt,02]
   Private cProposta  := aBrowse[oBrowse:nAt,03]

   Private oGet1
   Private oGet2
   Private oGet3

   Private aLista     := {}

   Private oDlgS

   // Pesquisa os produtos da proposta comercial selecionada
   If Select("T_RESERVA") > 0
      T_RESERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZP_FILIAL,"
   cSql += "       A.ZZP_PEDI  ,"
   cSql += "       A.ZZP_VEND  ,"
   cSql += "       A.ZZP_CODI  ,"
   cSql += "       A.ZZP_ITEM  ,"
   cSql += "       A.ZZP_DESC  ,"
   cSql += "       A.ZZP_QTPV  ,"
   cSql += "       A.ZZP_QTRE  ,"
   cSql += "       A.ZZP_LOCA  ,"
   cSql += "       A.ZZP_DATA  ,"
   cSql += "       A.ZZP_HORA  ,"
   cSql += "       A.ZZP_DRES  ,"
   cSql += "       A.ZZP_USUA  ,"
   cSql += "       A.ZZP_HRES  ,"
   cSql += "       B.A3_NOME   ,"
   cSql += "       C.B1_LOCALIZ,"
   cSql += "       A.R_E_C_N_O_,"
   cSql += "       A.ZZP_NUME   "
   cSql += "  FROM " + RetSqlName("ZZP") + " A, "
   cSql += "       " + RetSqlName("SA3") + " B, "
   cSql += "       " + RetSqlName("SB1") + " C  "   
   cSql += " WHERE A.ZZP_DRES   = ''"
   cSql += "   AND A.ZZP_VEND   = B.A3_COD"
   cSql += "   AND A.ZZP_CODI   = C.B1_COD"
-- cSql += "   AND A.ZZP_FILIAL = '" + Alltrim(aBrowse[oBrowse:nAt,01]) + "'"
   cSql += "   AND A.ZZP_PEDI   = '" + Alltrim(aBrowse[oBrowse:nAt,03]) + "'"
   cSql += "   AND A.ZZP_VEND   = '" + Alltrim(aBrowse[oBrowse:nAt,09]) + "'"
   cSql += " ORDER BY A.ZZP_FILIAL, B.A3_NOME, A.ZZP_DATA, A.ZZP_HORA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESERVA", .T., .T. )

   If T_RESERVA->( EOF() )
      MsgAlert("Não existem produtos disponíveis para esta proposta comercial a serem efetivadas suas reservas.")
      Return .T.
   Else
      T_RESERVA->( DbGoTop() )
      WHILE !T_RESERVA->( EOF() )      
         
         // Carrega o array aBrowse
         aAdd( aLista, { T_RESERVA->ZZP_CODI  ,;                                                         // 01 - Código do Produto
                         Alltrim(T_RESERVA->ZZP_DESC) + Space(60 - Len(Alltrim(T_RESERVA->ZZP_DESC))) ,; // 02 - Descrição do Produto
                         T_RESERVA->ZZP_QTPV  ,;                                                         // 03 - Quantidade do Pedido de Venda
                         0                    ,;                                                         // 04 - Quantidade de Solicitação de Reserva
                         T_RESERVA->B1_LOCALIZ,;                                                         // 05 - Indica se é com localização de endereço
                         T_RESERVA->ZZP_LOCA  ,;                                                         // 06 - Local (Armazém)
                         ""                   ,;                                                         // 07 - ????
                         T_RESERVA->ZZP_VEND  ,;                                                         // 08 - Código do Vendedor
                         T_RESERVA->A3_NOME   ,;                                                         // 09 - Usuário que solicitou a Reserva
                         T_RESERVA->ZZP_FILIAL,;                                                         // 10 - Filial que solicitou a Reserva
                         T_RESERVA->ZZP_NUME  ,;                                                         // 11 - Código da Solicitação
                         T_RESERVA->ZZP_FILIAL,;                                                         // 12 - Filial da Reserva
                         T_RESERVA->ZZP_PEDI  ,;                                                         // 13 - Nº da Oportunidade de Venda
                         T_RESERVA->ZZP_ITEM  })                                                         // 14 - Nº do item na Proposta Comercial

         T_RESERVA->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgS TITLE "Solicitações de reservas de Produtos" FROM C(178),C(181) TO C(451),C(635) PIXEL

   @ C(003),C(190) Say "P.Comercial"                 Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(004),C(005) Say "Vendedor"                    Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(025),C(005) Say "Produtos a serem reservados" Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   
   @ C(013),C(005) MsGet oGet1 Var cVendedor  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS
   @ C(013),C(033) MsGet oGet2 Var cNvendedor When lChumba Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS
   @ C(013),C(190) MsGet oGet3 Var cProposta  When lChumba Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS

   @ C(120),C(005) Button "Confirma Qtd / Nº de Séries" Size C(085),C(012) PIXEL OF oDlgS ACTION( CONFRESERVA() )
   @ C(120),C(122) Button "Confirmar Reservas"          Size C(060),C(012) PIXEL OF oDlgS ACTION( GRAVARES() )
   @ C(120),C(184) Button "Voltar"                      Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgS:End() )

   // Desenha o Browse                   ->  ^
   oLista := TCBrowse():New( 045 , 005, 280, 100,,{'Código', 'Descrição dos Produtos', 'Qtd Sol.', 'Qtd Reserva' },{20,50,50,50},oDlgS,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oLista:SetArray(aLista) 
    
   // Monta a linha a ser exibida no Browse
   oLista:bLine := {||{ aLista[oLista:nAt,01],;
                        aLista[oLista:nAt,02],;
                        aLista[oLista:nAt,03],;
                        aLista[oLista:nAt,04]}}

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// Função que abre tela de confirmação de reserva de produtos
Static Function CONFRESERVA()

   If aLista[oLista:nAt,05] == "S"
      RE_COMSERIE()
   Else
      RE_SEMSERIE()
   Endif   

Return .T.

// Tela de Confirmação de reserva Sem nº de série
Static Function RE_SEMSERIE()

   Local lChumba   := .F.
   Local cCodigo   := aLista[oLista:nAt,01]
   Local cProduto  := aLista[oLista:nAt,02]
   Local cSolicita := aLista[oLista:nAt,03]
   Local cReserva  := aLista[oLista:nAt,04]
   Local cLocal    := aLista[oLista:nAt,06]
   Local ___Filial := aLista[oLista:nAt,12]

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4

   Private oDlgI

   DEFINE MSDIALOG oDlgI TITLE "Confirmação de Reserva de Produto" FROM C(178),C(181) TO C(339),C(567) PIXEL

   @ C(004),C(005) Say "Produto"                            Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(032),C(034) Say "Quantidade Solicitada para Reserva" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(045),C(034) Say "Quantidade Confirmada de Reserva"   Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   
   @ C(013),C(005) MsGet oGet1 Var cCodigo   When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
   @ C(013),C(033) MsGet oGet2 Var cProduto  When lChumba Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
   @ C(031),C(125) MsGet oGet3 Var cSolicita When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
   @ C(044),C(125) MsGet oGet4 Var cReserva               Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI

   @ C(062),C(056) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgI ACTION( SALVARE(cCodigo, cLocal, cSolicita, cReserva, ___Filial) )
   @ C(062),C(095) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgI ACTION( oDlgI:End() )

   ACTIVATE MSDIALOG oDlgI CENTERED 

Return(.T.)

// Função que grava no array aLista a quantidade confirmada da reserva
Static Function SALVARE(_Codigo, _Armazem, _Solicita, _Reserva, ___Filial)

   //Verifica se a quantidade de confirmação da reserva foi informada
   If _Reserva == 0
      MsgAlert("Quantidade de Reserva confirmada não informada.")
      Return .T.
   Endif
   
   // Verifica se a quantidade informada na confirmação da reserva é maior que a quantidade solicitada
   If _Reserva > _Solicita
      MsgAlert("Quantidade a ser reservada não pode ser maior que a quantidade solicitada.")
      Return .T.
   Endif

   // Verifica se existe saldos para a quantidade solicitada para reserva    
   dbSelectArea("SB2")
   dbSetOrder(1)
// MsSeek(xFilial("SB2") + _Codigo + _Armazem)
   MsSeek(___Filial + _Codigo + _Armazem)
   If SaldoSb2() < _Reserva
      MsgAlert("Não existe saldo disponível para esta quantidade de reserva.")
      Return .F.
   EndIf

   aLista[oLista:nAt,04] := _Reserva
   
   // Seta vetor para a browse                            
   oLista:SetArray(aLista) 
    
   // Monta a linha a ser exibina no Browse
   oLista:bLine := {||{ aLista[oLista:nAt,01],;
                        aLista[oLista:nAt,02],;
                        aLista[oLista:nAt,03],;
                        aLista[oLista:nAt,04]}}

   oDlgI:End()

   // Envia para a função que grava a reserva
// GravaRes()

Return .T.

// Tela de Confirmação de reserva Sem nº de série
Static Function RE_COMSERIE()

   Local lChumba    := .F.
   Local xSerie     := ""
   Local nContar    := 0
   Local nPosicao   := 0

   Private cProduto := Alltrim(aLista[oLista:nAt,01]) + " - " + Alltrim(aLista[oLista:nAt,02])
   Private cSerie	:= Space(20)
   
   Private oGet2
   Private oGet3

   Private oDlgC
   Private aSerie   := {}

   For nContar = 1 to Int(aLista[oLista:nAt,03])
       aAdd( aSerie, { nContar, "" } )
   Next nContar    

   // Verifica se já existe informação de nº de séries para o produto selecionado.
   // Caso já exista, captura os nº de séries para display.
   If !Empty(Alltrim(aLista[oLista:nAt,07]))

      For nContar = 1 to U_P_OCCURS(aLista[oLista:nAt,07], "|", 1)

          xSerie := U_P_CORTA(aLista[oLista:nAt,07], "|", nContar)
          
          // Localiza o próximo elemento vazio no array aLista para gravação do nº de série.
          For nPosicao = 1 to Int(aLista[oLista:nAt,03])
              If Empty(Alltrim(aSerie[nPosicao,02]))
                 aSerie[nPosicao,02] := xSerie
                 Exit
              Endif
          Next nPosicao       
          
      Next nContar    
      
   Endif

   DEFINE MSDIALOG oDlgC TITLE "Confirmação de Reserva de Produto" FROM C(178),C(181) TO C(620),C(510) PIXEL

   @ C(004),C(005) Say "Produto"     Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(028),C(026) Say "Nº de Série" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(013),C(005) MsGet oGet2 Var cProduto When lChumba Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(027),C(060) MsGet oGet3 Var cSerie                Size C(075),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC VALID( CARSERIE(cSerie) )

   @ C(204),C(005) Button "Limpa Nº de Séries" Size C(064),C(012) PIXEL OF oDlgC ACTION( LIMPASER() )
   @ C(204),C(082) Button "Confirma"           Size C(037),C(012) PIXEL OF oDlgC ACTION( SALVASE(aLista[oLista:nAt,01]) )
   @ C(204),C(121) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )

   // Desenha o Browse                   ->  ^
   oSerie := TCBrowse():New( 055 , 005, 200, 200,,{'Sq', 'Nº de Series' },{20,50,50,50},oDlgC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oSerie:SetArray(aSerie) 
    
   // Monta a linha a ser exibina no Browse
   oSerie:bLine := {||{ aSerie[oSerie:nAt,01], aSerie[oSerie:nAt,02]}}

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que limpa os nº de séries informados/scaneados
Static Function LIMPASER()

   Local nContar := 0
   Local nQtdSer := 0
                     
   // Verifica se exitem informações de nºs de séries no array
   For nContar = 1 to Len(aSerie)
       If !Empty(Alltrim(aSerie[nContar,02]))
          nQtdSer := nQtdSer + 1
          Exit
       Endif
   Next nContar
   
   If nQtdSer == 0
      Return .T.
   Endif
   
   If MsgYesNo("Deseja realmente limpar a leitura do(s) nº(s) de série(s)?")
      For nContar = 1 to Len(aSerie)
          aSerie[nContar,02] := ""
      Next nContar
   Endif
   
Return .T.   

// Função que atualiza o nº de série no array aserie
Static Function CARSERIE(_Serie)

   Local cSql    := ""
   Local nContar := 0
   Local _Jatem  := .F.   

   If Empty(Alltrim(_Serie))
      Return .T.
   Endif

   // Verifica se o nº de série já foi informado/lido
   _JaTem := .F.
   For nContar = 1 to Len(aSerie)
       If Alltrim(aSerie[nContar,02]) == Alltrim(_Serie)
          _JaTem := .T.
          Exit
       Endif
   Next nContar
   
   If _Jatem
      MsgAlert("Nº de Série já informado/lido.")
      Return .T.
   Endif
 
   // Verifica se o nº de série informado pertence ao produto a ser reservado
   If Select("T_ENDERECO") > 0
      T_ENDERECO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BF_PRODUTO,"
   cSql += "       BF_NUMSERI,"
   cSql += "       BF_LOCAL   "
   cSql += "  FROM " + RetSqlName("SBF")
   cSql += " WHERE BF_PRODUTO = '" + Alltrim(aLista[oLista:nAt,01]) + "'"
   cSql += "   AND BF_LOCAL   = '" + Alltrim(aLista[oLista:nAt,06]) + "'"
   cSql += "   AND BF_NUMSERI = '" + Alltrim(_Serie)                + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

   If T_ENDERECO->( EOF() )
      MsgAlert("Nº de Série informado inexistente ou não pertence a este produto.")
      Return .T.
   Endif

   // Verifica o primeiro nº de série vago para gravação
   For nContar  = 1 to Len(aSerie)
       If Empty(Alltrim(aSerie[nContar,02]))
          Exit
       Endif
   Next nContar
   
   aSerie[nContar,02] := _Serie
   
   // Seta vetor para a browse                            
   oSerie:SetArray(aSerie) 
    
   // Monta a linha a ser exibina no Browse
   oSerie:bLine := {||{ aSerie[oSerie:nAt,01], aSerie[oSerie:nAt,02]}}
   oSerie:Refresh()

   _Serie := Space(20)
   cSerie := Space(20)   

   oGet3:SetFocus()
   oGet3:refresh()
      
Return .T.

// Função que grava no array aLista a quantidade confirmada da reserva
Static Function SALVASE(_Codigo)

   Local nContar   := 0
   Local _TodosInf := .T.
   Local cTexto    := ""
   Local tReservas := 0

   // Verifica se todos os nºs de séries foram informados
   _TodosInf := .T.
   For nContar = 1 to Len(aSerie)
       If Empty(Alltrim(aSerie[nContar,02]))
          _TodosInf := .F.
          Exit
       Endif
       cTexto    := cTexto + Alltrim(aSerie[nContar,02]) + "|"
       TReservas := tReservas + 1
   Next nContar
   
   If !_TodosInf     
      MsgAlert("Atenção, falta a informação de nº(s) de série(s).")
      Return .T.
   Endif

   aLista[oLista:nAt,04] := tReservas
   aLista[oLista:nAt,07] := cTexto
   
   oDlgC:End()

   // Seta vetor para a browse                            
   oLista:SetArray(aLista) 
    
   // Monta a linha a ser exibina no Browse
   oLista:bLine := {||{ aLista[oLista:nAt,01],;
                        aLista[oLista:nAt,02],;
                        aLista[oLista:nAt,03],;
                        aLista[oLista:nAt,04]}}

   oLista:Refresh()

   // Envia para a função que grava a reserva
///   GravaRes()

Return .T.

// Função que grava os dados do array para a tabela SC0010
Static Function GRAVARES()

   Local nContar := 0
   Local nAbrir  := 0
   Local cTexto  := ""
   Local cEmail  := ""

   // Pesquisa o e-mail do vendedor para envio do e-mail
   If Select("T_EMAIL") > 0
      T_EMAIL->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT A3_EMAIL"
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_COD     = '" + Alltrim(aLista[01,08]) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMAIL", .T., .T. )
   
   cEmail := IIF(T_EMAIL->( EOF() ), "", T_EMAIL->A3_EMAIL)   

   // Elabora o texto a ser enviado no e-mail ao Vendedor
   cTexto := ""
   cTexto := "Prezado(a) " + Alltrim(aLista[01,09]) + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Conforme sua solicitação, informamos que foram efetuadas as reservas dos produtos de sua Oportunidade de Venda Nº " + Alltrim(aLista[01,13]) + "." + CHR(13) + CHR(10)
   cTexto += "Salientamos que o prazo de validade destas reservas é " + Dtoc(DATE() + 10) + "." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   cTexto += "Produtos Reservados:" + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   
   // Atualiza a Tabela SC0010 com os dados dos produtos com confirmação de reserva.
   For nContar = 1 to Len(aLista)

       // Se não existir confirmação de reserva, despreza
       If aLista[nContar,04] == 0
          Loop
       Endif

       // Se elemento 07 estiver vazio, indica gravação de reserva de produto sem nºs de séries
       If Empty(Alltrim(aLista[nContar,07]))
   
          // Envia para a função que registra a reserva
          If aLista[nContar,05] <> "S"

  	         xa430reserv({1                        ,; // 1 - Indica que a opção é de Inclusão
	                     "VD"                      ,; // Tipo de Registro. Passado Fixo VD - Vendedor
	                     aLista[nContar,08]        ,; // Código do Vendedor
	                     aLista[nContar,09]        ,; // Nome do Solicitante
	                     aLista[nContar,12] }      ,; // Filial que solicitou a reserva
   				         ""                        ,; // Código do lançamento (Se já existe, sistema pesquisa um nº ainda não utilizado
				         aLista[nContar,01]        ,; // Código do Produto
				         aLista[nContar,06]        ,; // Local (Armazém) do Produto
				         aLista[nContar,04]        ,; // Quantidade de solicitação de Reserva
  				      {  ""                        ,; // Nº Sub-Lote
				         ""                        ,; // Nº do  Lote
				         ""                        ,; // Endereço
				         "" }                      ,; // Nº de Série
				         {}                        ,;
				         {}                        ,;
				         0)
             cTexto += Alltrim(aLista[nContar,01]) + " - " + Alltrim(aLista[nContar,02]) + CHR(13) + CHR(10)

	      Endif		      
	   
	   Else
	     
          For nAbrir = 1 to U_P_OCCURS(aLista[nContar,07],"|",1)
   	          xa430reserv({1                                          ,; // 1 - Indica que a opção é de Inclusão
	                      "VD"                                        ,; // Tipo de Registro. Passado Fixo VD - Vendedor
	                      aLista[nContar,08]                          ,; // Código do Vendedor
	                      aLista[nContar,09]                          ,; // Nome do Solicitante
	                      aLista[nContar,12] }                        ,; // Filial que solicitou a reserva
   			   	          ""                                          ,; // Código do lançamento (Se já existe, sistema pesquisa um nº ainda não utilizado
			   	          aLista[nContar,01]                          ,; // Código do Produto
			   	          aLista[nContar,06]                          ,; // Local (Armazém) do Produto
				          aLista[nContar,04]                          ,; // Quantidade de solicitação de Reserva
  				       {  "      "                                    ,; // Nº Sub-Lote
				          "          "                                ,; // Nº do  Lote
				          "GENERICO       "                           ,; // Endereço
				          U_P_CORTA(aLista[nContar,07],"|", nAbrir) } ,; // Nº de Série
				          {}                                          ,;
				          {}                                          ,;
				          0)

             cTexto += Alltrim(aLista[nContar,01]) + " - " + Alltrim(aLista[nContar,02]) + " (Nº Série: " + Alltrim(U_P_CORTA(aLista[nContar,07],"|", nAbrir)) + ")" + CHR(13) + CHR(10)

		  Next nAbrir	          
		  
	   Endif	  
                                   
       // Atualiza o registro da tabela ZZP dando como reservado o registro da solicitação
       DbSelectArea("ZZP")
       DbSetOrder(2)
       If DbSeek(aLista[nContar,10] + aLista[nContar,11] + aLista[nContar,14])
          RecLock("ZZP",.F.)
          ZZP_DRES := DATE()
          ZZP_HRES := TIME()
          ZZP_USUA := cUserName
          MsUnLock()              
       Endif

   Next nContar       

   cTexto += chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Atenciosamente" + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Automatech Sistemas de Automação Ltda" + chr(13) + chr(10)
   cTexto += "Departamento de Estoque"
          
   // Envia e-mail ao vendedor informando que suas reservas foram efetivadas
   U_AUTOMR20(cTexto, cEmail, "", "Confirmação de Reserva de Produtos")

   oDlgs:End()

   aBrowse := {}

   // Recarrega o grid se solicitações de reservas
   If Select("T_RESERVA") > 0
      T_RESERVA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZP_FILIAL,"
   cSql += "       A.ZZP_PEDI  ,"
   cSql += "       A.ZZP_VEND  ,"
   cSql += "       A.ZZP_CODI  ,"
   cSql += "       A.ZZP_ITEM  ,"
   cSql += "       A.ZZP_DESC  ,"
   cSql += "       A.ZZP_QTPV  ,"
   cSql += "       A.ZZP_QTRE  ,"
   cSql += "       A.ZZP_LOCA  ,"
   cSql += "       A.ZZP_DATA  ,"
   cSql += "       A.ZZP_HORA  ,"
   cSql += "       A.ZZP_DRES  ,"
   cSql += "       A.ZZP_USUA  ,"
   cSql += "       A.ZZP_HRES  ,"
   cSql += "       A.ZZP_NUME  ,"
   cSql += "       B.A3_NOME   ,"
   cSql += "       C.B1_LOCALIZ "
   cSql += "  FROM " + RetSqlName("ZZP") + " A, "
   cSql += "       " + RetSqlName("SA3") + " B, "
   cSql += "       " + RetSqlName("SB1") + " C  "   
   cSql += " WHERE A.ZZP_DRES = ''"
   cSql += "   AND A.ZZP_VEND = B.A3_COD"
   cSql += "   AND A.ZZP_CODI = C.B1_COD"
   cSql += " ORDER BY A.ZZP_FILIAL, B.A3_NOME, A.ZZP_DATA, A.ZZP_HORA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESERVA", .T., .T. )
   
   If T_RESERVA->( EOF() )
      aAdd( aBrowse, { '', '', '', '', '', '', '', '', '', '', '', '', '', '' } )
   Else
      T_RESERVA->( DbGoTop() )
      WHILE !T_RESERVA->( EOF() )

         // Verifica se Proposta Comercial já está contida no array aBrowse
         _JaTem := .F.
         For nContar = 1 to Len(aBrowse)
             If Alltrim(aBrowse[nContar,03]) == Alltrim(T_RESERVA->ZZP_PEDI)
                _JaTem := .T.
                Exit
             Endif
         Next nContar       

         If _JaTem
            T_RESERVA->( DbSkip() )
            Loop
         Endif

         aAdd( aBrowse, { T_RESERVA->ZZP_FILIAL        ,;
                          T_RESERVA->A3_NOME           ,;
                          T_RESERVA->ZZP_PEDI          ,;
                          SUBSTR(T_RESERVA->ZZP_DATA,07,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,05,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,01,04)               ,;
                          DATE() - CTOD(SUBSTR(T_RESERVA->ZZP_DATA,07,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,05,02) + "/" + SUBSTR(T_RESERVA->ZZP_DATA,01,04)),;
                          T_RESERVA->ZZP_HORA          ,;
                          T_RESERVA->ZZP_CODI          ,;
                          T_RESERVA->ZZP_DESC          ,;
                          T_RESERVA->ZZP_VEND          ,;
                          T_RESERVA->ZZP_QTRE          ,;
                          T_RESERVA->ZZP_LOCA          ,;
                          T_RESERVA->B1_LOCALIZ        ,;
                          ""                           ,;
                          T_RESERVA->ZZP_NUME          ,;
                          T_RESERVA->ZZP_ITEM          })


          T_RESERVA->( DbSkip() )

      ENDDO

   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;                                                  
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,14]}}

Return .T.

// Função que grava a reserva dos produtos passados nos parâmetros
Static Function xa430Reserv(aOperacao,cNumero,cProduto,cLocal,nQuant,aLote,aHeader,aCols,nQuantElim)

   Local aArea 	   := GetArea()
   Local nCntFor   := 0
   Local cNumLote  := aLote[1]
   Local cLoteCtl  := aLote[2]
   Local cLocaliz  := aLote[3]
   Local cNumSer   := aLote[4]
   Local nOpcx	   := aOperacao[1]
   Local cTipoRes  := aOperacao[2]
   Local cDocRes   := aOperacao[3]
   Local cSolicit  := aOperacao[4]
   Local cFilRes   := aOperacao[5]
   Local lRetorna  := .F.
   Local lNovo     := .F.
   Local aSldLote  := {}
   Local nQtdLote  := 0
   Local cObs	   := If(Len(aOperacao)>=6,aOperacao[6]," ")

   If Empty(cNumero) .And. (nOpcx <> 3)
      cNumero := GetSx8Num("SC0","C0_NUM")
	  ConfirmSx8()
   Endif

   // Verifica se a reserva ja existe e estorna valores anteriores
   dbSelectArea("SC0")
   dbSetOrder(1)

// If ( MsSeek(xFilial("SC0")+cNumero+cProduto+cLocal) )
   If ( MsSeek(cFilRes + cNumero + cProduto + cLocal) )
	  GravaEmp(SC0->C0_PRODUTO,; //-- 1
	     	   SC0->C0_LOCAL,;   //-- 2
		       SC0->C0_QUANT,;   //-- 3
		       NIL,;             //-- 4
		       SC0->C0_LOTECTL,; //-- 5
		       SC0->C0_NUMLOTE,; //-- 6
		       SC0->C0_LOCALIZ,; //-- 7
		       SC0->C0_NUMSERI,; //-- 8 
		       Nil,;             //-- 9
		       Nil,;             //-- 10
		       SC0->C0_NUM,;     //-- 11
		       Nil,;             //-- 12
		       "SC0",;           //-- 13
		       Nil,;             //-- 14
		       Nil,;             //-- 15
		       Nil,;             //-- 16
		       .T.,;             //-- 17
		       .F.,;             //-- 18
		       .T.,;             //-- 19
		       .F.,;             //-- 20
		       Nil,;             //-- 21
		       !Empty(SC0->C0_LOTECTL+SC0->C0_NUMLOTE+SC0->C0_LOCALIZ+SC0->C0_NUMSERI)) //-- 22

    Else
	   lNovo := .T.
    EndIf

    If ( nOpcx != 3 )

   	   // Verifica se o Produto pode ser Reservado
   	   dbSelectArea("SB2")
	   dbSetOrder(1)
//     MsSeek(xFilial("SB2")+cProduto+cLocal)
       MsSeek(cFilRes + cProduto + cLocal)
	   If ( !RecLock("SB2") .Or. SaldoSb2() < nQuant )
		  lRetorna := .F.
	   Else
	      lRetorna := .T.
	   EndIf
	
	   If lRetorna
		  // Verifica os lotes
    	  aSldLote := GravaEmp(cProduto,; //-- 1
		        	           cLocal  ,; //-- 2
			                   nQuant  ,; //-- 3
			                   NIL     ,; //-- 4
			                   aLote[2],; //-- 5
			                   aLote[1],; //-- 6
			                   aLote[3],; //-- 7
			                   aLote[4],; //-- 8
			                   Nil     ,; //-- 9
			                   Nil     ,; //-- 10
			                   cNumero ,; //-- 11
			                   Nil     ,; //-- 12
			                   "SC0"   ,; //-- 13
			                   Nil     ,; //-- 14
			                   Nil     ,; //-- 15
			                   Nil     ,; //-- 16
		 	                   .F.     ,; //-- 17
			                   .F.     ,; //-- 18
			                   .T.     ,; //-- 19
			                   .F.     ,; //-- 20
			                   Nil     ,; //-- 21
			                   !Empty(aLote[2]+aLote[1]+aLote[3]+aLote[4])) //-- 22

		  For nCntFor := 1 To Len(aSldLote)
			  nQtdLote += aSldLote[nCntFor][5]
		  Next nCntFor

		  If ( nQtdLote != nQuant .And. (Rastro(cProduto) .Or. Localiza(cProduto)))
			 lRetorna := .F.
		  EndIf

		  If lRetorna
			 // Atualiza dados padroes
			 If !lNovo
				RecLock("SC0",.F.)
			 Else
				RecLock("SC0",.T.)
			 EndIf
//			 SC0->C0_FILIAL	 := xFilial("SC0")
 			 SC0->C0_FILIAL	 := cFilRes
			 SC0->C0_NUM     := cNumero
			 SC0->C0_PRODUTO := cProduto
			 SC0->C0_LOCAL   := cLocal
			 SC0->C0_QUANT	 := nQuant
			 SC0->C0_NUMLOTE := cNumLote
			 SC0->C0_LOTECTL := cLoteCtl
			 SC0->C0_LOCALIZ := cLocaliz
			 SC0->C0_NUMSERI := cNumSer
			 SC0->C0_TIPO    := cTipoRes
			 SC0->C0_DOCRES  := cDocRes
			 SC0->C0_SOLICIT := cSolicit
			 SC0->C0_FILRES  := cFilRes
			 SC0->C0_EMISSAO := dDataBase
			 SC0->C0_VALIDA  := dDataBase + 10
			 SC0->C0_QTDORIG := If(SC0->C0_QTDORIG==0,SC0->C0_QUANT,SC0->C0_QTDORIG)
			 If SC0->(FieldPos("C0_OBS")) > 0
				SC0->C0_OBS  := cObs
			 Endif

			 If ValType( nQuantElim ) == "N" .And. !Empty( SC0->( FieldPos( "C0_QTDELIM" ) ) )
				SC0->C0_QTDELIM := nQuantElim
			 EndIf 			

			// Atualiza dados do corpo
			If ( !Empty(aHeader) )
			   For nCntFor := 1 To Len(aHeader)
			   	   If aHeader[nCntFor,10] != "V"
				  	  FieldPut(FieldPos(aHeader[nCntFor,2]),aCols[nCntFor])
				   Endif
			   Next nCntFor
			EndIf
		 EndIf
 	 EndIf

	 Do Case
		Case !lNovo .And. !lRetorna
	
			 GravaEmp(SC0->C0_PRODUTO,; //-- 1
				      SC0->C0_LOCAL  ,; //-- 2
				      SC0->C0_QUANT  ,; //-- 3
				      NIL            ,; //-- 4
				      SC0->C0_LOTECTL,; //-- 5
				      SC0->C0_NUMLOTE,; //-- 6
				      SC0->C0_LOCALIZ,; //-- 7
				      SC0->C0_NUMSERI,; //-- 8
				      Nil            ,; //-- 9
				      Nil            ,; //-- 10
				      SC0->C0_NUM    ,; //-- 11
				      Nil            ,; //-- 12
				      "SC0"          ,; //-- 13
				      Nil            ,; //-- 14
				      Nil            ,; //-- 15
				      Nil            ,; //-- 16
				      .T.            ,; //-- 17
				      .F.            ,; //-- 18
				      .T.            ,; //-- 19
				      .F.            ,; //-- 20
				      Nil            ,; //-- 21
				      !Empty(SC0->C0_LOTECTL+SC0->C0_NUMLOTE+SC0->C0_LOCALIZ+SC0->C0_NUMSERI)) //-- 22

		Case lNovo .And. !lRetorna
		 	 aSldLote := GravaEmp(cProduto,; //-- 1
				                  cLocal  ,; //-- 2
				                  nQtdLote,; //-- 3
				                  NIL     ,; //-- 4
				                  aLote[2],; //-- 5
				                  aLote[1],; //-- 6
				                  aLote[3],; //-- 7
				                  aLote[4],; //-- 8
				                  Nil     ,; //-- 9
				                  Nil     ,; //-- 10
				                  cNumero ,; //-- 11
				                  Nil     ,; //-- 12
				                  "SC0"   ,; //-- 13
				                  Nil     ,; //-- 14
				                  Nil     ,; //-- 15
 				                  Nil     ,; //-- 16
				                  .T.     ,; //-- 17
				                  .F.     ,; //-- 18
				                  .T.     ,; //-- 19
				                  .F.     ,; //-- 20
				                  Nil     ,; //-- 21
				                  !Empty(aLote[2]+aLote[1]+aLote[3]+aLote[4])) //-- 22

  	 EndCase

  Else
  
	 lRetorna := .T.
	 If SC0->( Found() )
		RecLock("SC0")
		dbDelete()
		MsUnLock()
	EndIf 	

  EndIf

  // Retorna o Alias de Entrada
  RestArea(aArea)

Return(lRetorna)