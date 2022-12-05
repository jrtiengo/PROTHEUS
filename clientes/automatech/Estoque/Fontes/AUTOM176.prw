#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM176.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/05/2013                                                          *
// Objetivo..: Programa que gera movimentações internas para correção dos custos   *
//             médios dos produtos das Filiais (02 - Caxias, 03 - Pelotas e Filial *
//             04 - Suprimentos)                                                   *
//**********************************************************************************

User Function AUTOM176()
                      
   Local lChumba     := .F.

   Private aConsulta := {}

   Private aComboBx1 := U_AUTOM539(2, cEmpAnt) // {"02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos (Porto Alegre)"}
   Private cComboBx1
   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )
   Private OLIST

   Private nMeter1	 := 0
   Private oMeter1

   Private oDlg

   U_AUTOM628("AUTOM176")

   If cFilant == "01"
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Procedimento não permitido na Filial 01 - Poto Alegre." + chr(13) + "Logue-se na Filial desejada para executar o procedimento.")
      Return .T.
   Endif

//   Do Case
//      Case cFilAnt == "02"  
//           cComboBx1 := "02 - Caxias do Sul"
//      Case cFilAnt == "03"  
//           cComboBx1 := "03 - Pelotas"
//      Case cFilAnt == "04"  
//           cComboBx1 := "04 - Suprimentos (Porto Alegre)"
//   EndCase

   aAdd( aConsulta, { .F., "", "", "", "", 0, 0, 0, 0 })

   // Envia para a Sub-função que pesquisa os produtos da filial logada
   BuscaFilProd("E")

   DEFINE MSDIALOG oDlg TITLE "Correção de Custos de Filiais" FROM C(178),C(181) TO C(568),C(866) PIXEL

   @ C(005),C(005) Say "Filiais"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(180),C(104) METER oMeter1 VAR nMeter1 Size C(143),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(013),C(005) ComboBox cComboBx1 Items aComboBx1 When lChumba Size C(136),C(010) PIXEL OF oDlg
   
   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

// @ C(011),C(150) Button "Pesquisar"                   Size C(037),C(012) PIXEL OF oDlg ACTION( BuscaFilProd() )
   @ C(178),C(005) Button "Marca Todos"                 Size C(041),C(012) PIXEL OF oDlg ACTION( MrcTodos(1) )
   @ C(178),C(047) Button "Desmarca Todos"              Size C(053),C(012) PIXEL OF oDlg ACTION( MrcTodos(2) )
   @ C(178),C(252) Button "Efetivar Correção de Custos" Size C(084),C(012) PIXEL OF oDlg ACTION( EfetivaCusto() )
   @ C(011),C(299) Button "Voltar"                      Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   
   // Cria Componentes Padroes do Sistema
   @ 33,05 LISTBOX oList FIELDS HEADER "", "E", "Local", "Código" ,"Descrição dos Produtos", "Saldo", "C.Filial", "C.Matriz", "Dif. Custo" PIXEL SIZE 425,190 OF oDlg ;
           ON dblClick(aConsulta[oList:nAt,1] := !aConsulta[oList:nAt,1],oList:Refresh())     
   oList:SetArray( aConsulta )
   oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
          					   aConsulta[oList:nAt,02],;
         	        	       aConsulta[oList:nAt,03],;
         	        	       aConsulta[oList:nAt,04],;
         	        	       aConsulta[oList:nAt,05],;
         	        	       aConsulta[oList:nAt,06],;
         	        	       aConsulta[oList:nAt,07],;
         	        	       aConsulta[oList:nAt,08],;
         	        	       aConsulta[oList:nAt,09]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que marca / desmarca todos os registros
Static Function MrcTodos( _Tipo )

   Local nContar := 0

   For nContar = 1 to Len(aConsulta)                     
       If _Tipo == 1
          aConsulta[nContar][1] := .T.
       Else
          aConsulta[nContar][1] := .F.          
       Endif
   Next nContar

   oList:Refresh()
   
Return .T.   

// Função que pesquisa e abre o grid com as informações dos produtos da filial selecionada
Static Function BuscaFilProd( _Chamado )

   Local cSql      := ""
   Local nRegistro := 0

   aConsulta := {}
   
   // Pesquisa os produtos da filial selecionada
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.B2_LOCAL  ," 
   cSql += "       A.B2_COD    ,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_LOCALIZ,"
   cSql += "       A.B2_QATU   ,"
   cSql += "       A.B2_CM1    ,"
   cSql += "      (SELECT B2_CM1 "
   cSql += "         FROM " + RetSqlName("SB2")
   cSql += "        WHERE B2_FILIAL  = '01'" 
   cSql += "          AND D_E_L_E_T_ = ''  "
   cSql += "          AND B2_COD     = A.B2_COD"
   cSql += "          AND B2_LOCAL   = A.B2_LOCAL) AS MATRIZ"
   cSql += "  FROM " + RetSqlName("SB2") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.B2_FILIAL = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.B2_QATU <> 0   "
   cSql += "   AND A.B2_COD = B.B1_COD"
   cSql += " ORDER BY A.B2_COD"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para esta Filial.")
      aAdd( aConsulta, { .F., "", "", "", "", 0, 0, 0, 0 })

      oList:SetArray( aConsulta )
      oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
             					  aConsulta[oList:nAt,02],;
         	        	          aConsulta[oList:nAt,03],;
         	        	          aConsulta[oList:nAt,04],;
         	        	          aConsulta[oList:nAt,05],;
         	        	          aConsulta[oList:nAt,06],;
         	        	          aConsulta[oList:nAt,07],;
         	        	          aConsulta[oList:nAt,08],;
         	        	          aConsulta[oList:nAt,09]}}
      Return .T.
   Endif
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )

      nRegistro += 1

      If _Chamado == "E"
      Else
         oMeter1:Set(nRegistro)
      Endif

      If T_PRODUTOS->MATRIZ == 0
         T_PRODUTOS->( DbSkip() )         
         LOOP
      ENDIF
         
      If (T_PRODUTOS->B2_CM1 + T_PRODUTOS->MATRIZ) == 0
         T_PRODUTOS->( DbSkip() )         
         LOOP
      ENDIF

      If (T_PRODUTOS->B2_CM1 - T_PRODUTOS->MATRIZ) == 0
         T_PRODUTOS->( DbSkip() )         
         LOOP
      ENDIF

      aAdd( aConsulta, { .F.                        ,;
                         T_PRODUTOS->B1_LOCALIZ     ,;
                         T_PRODUTOS->B2_LOCAL       ,;
                         T_PRODUTOS->B2_COD         ,;
                         T_PRODUTOS->B1_DESC        ,;
                         T_PRODUTOS->B2_QATU        ,;
                         T_PRODUTOS->B2_CM1         ,;
                         T_PRODUTOS->MATRIZ         ,;
                         T_PRODUTOS->MATRIZ - T_PRODUTOS->B2_CM1 })
      T_PRODUTOS->( DbSkip() )

   ENDDO       
   
   If Len(aConsulta) == 0
      Return .T.
   Endif   

   If _Chamado == "E"
   Else
      oList:SetArray( aConsulta )
      oList:bLine := {||     {Iif(aConsulta[oList:nAt,01],oOk,oNo),;
             					  aConsulta[oList:nAt,02],;
         	        	          aConsulta[oList:nAt,03],;
         	        	          aConsulta[oList:nAt,04],;
         	        	          aConsulta[oList:nAt,05],;
         	        	          aConsulta[oList:nAt,06],;
         	        	          aConsulta[oList:nAt,07],;
         	        	          aConsulta[oList:nAt,08],;
         	        	          aConsulta[oList:nAt,09]}}
   Endif

Return .T.

// Efetiva as movimentações para correção dos custos dos produtos
Static Function EfetivaCusto()

   Local nContar   := 0
   Local nItem     := 0
   Local lExiste   := .F.
   Local nContar   := 0
   Local lEfetiva  := .F.
   Local cDocEntra := ""
   Local cDocSaida := ""
   Local nSeries   := 0
   Local nSaida    := 0
   
   Private aCab    := {}
   Private aItem   := {}      
   Private cNumDoc := ""
   Private _Filial := cFilAnt
   Private _Area   := GETAREA()

   If cFilant == "01"
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Procedimento não permitido na Filial 01 - Poto Alegre." + chr(13) + "Logue-se na Filial desejada para executar o procedimento.")
      Return .T.
   Endif

   // Verifica se houve pelo menos um registro marcado para atualização
   For nContar = 1 to Len(aConsulta)
       If aconsulta[nContar,1] == .T.
          lExiste := .T.
          Exit
       Endif
   Next nContar
   
   If lExiste == .F.
      MsgAlert("Nenhum regsitro foi marcado para ajuste do custo médio. Verifique!")
      Return .T.
   Endif

   // Pesquisa o próximo código para o registro dos lançamentos
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT D3_DOC"
   cSql += "  FROM " + RetSqlName("SD3") 
   cSql += " WHERE SUBSTRING(D3_DOC ,1,4) = 'ACT@'"
   cSql += "   AND D_E_L_E_T_ = ''"                
   cSql += " ORDER BY D3_DOC DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

   If T_PROXIMO->( EOF() )
      cDocEntra := "ACT@00001"
      cDocSaida := "ACT@00001"
   Else
      cDocEntra := "ACT@" + Strzero((INT(VAL(Substr(T_PROXIMO->D3_DOC,05,05))) + 1),5)
      cDocSaida := "ACT@" + Strzero((INT(VAL(Substr(T_PROXIMO->D3_DOC,05,05))) + 2),5)
   Endif

   // Gera os registros de Saídas zerando os saldos dos produtos
   aCab     := {}
   aItem    := {}      
   lEfetiva := .F.
   
   aCab := {{"D3_FILIAL" , Substr(cComboBx1,01,02), NIL},;
            {"D3_DOC"    , cDocSaida              , Nil},;
            {"D3_TM"     , '800'                  , Nil},;
            {"D3_CC"     , ''                     , Nil},;
            {"D3_EMISSAO", Date()                 , Nil}}
                                                   
   For nContar = 1 to Len(aConsulta)

       // Se não marcado, despreza
       If aConsulta[nContar,1] == .F.
          Loop
       Endif
          
       If aconsulta[nContar,2] == "N"
          aadd(aItem,{{"D3_FILIAL", Substr(cComboBx1,01,02), NIL},;
                      {"D3_COD"   , aConsulta[nContar,04]  , NIL},;
                      {"D3_QUANT" , aConsulta[nContar,06]  , NIL},;
                      {"D3_CUSTO1", (aConsulta[nContar,06] * aConsulta[nContar,07]), NIL},;
                      {"D3_LOCAL" , aConsulta[nContar,03]  , NIL}})
          lEfetiva := .T.
       Else
          // Pesquisa os nº de séries a serem utilizados
          If Select("T_SERIES") > 0
             T_SERIES->( dbCloseArea() )
          EndIf

          cSql := ""          
          cSql := "SELECT BF_FILIAL ,"
          cSql += "       BF_PRODUTO,"
          cSql += "       BF_LOCAL  ,"
          cSql += "       BF_LOCALIZ,"
          cSql += "       BF_NUMSERI "
          cSql += "  FROM " + RetSqlName("SBF")
          cSql += " WHERE BF_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
          cSql += "   AND D_E_L_E_T_ = ''" 
          cSql += "   AND BF_PRODUTO = '" + Alltrim(aConsulta[nContar,4]) + "'"
          cSql += "   AND BF_LOCAL   = '" + Alltrim(aConsulta[nContar,3]) + "'"
          cSql += "   AND BF_QUANT  <> 0"
          
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )
       
          If T_SERIES->( EOF() )
             MsgAlert("Produto: " + Alltrim(aConsulta[nContar,4]) + " - " + aConsulta[nContar,5] + " Não foi encontrado os nº de séries para o mesmo.")
             Loop
          Endif
             
          // Conta quantos registros foram capturados na pesquisa
          nSeries := 0
          T_SERIES->( DbGoTop() )
	          WHILE !T_SERIES->( EOF() )
             nSeries += 1
             T_SERIES->( DbSkip() )
          ENDDO

          If nSeries < aConsulta[nContar,6]
             MsgAlert("Produto: " + Alltrim(aConsulta[nContar,4]) + " - " + aConsulta[nContar,5] + " Quantidade de estoque diferente a quantidade de nºs de séries encontrados.")
             Loop
          Endif

          // Realiza a saída dos nºs de séries para zerar o estoque
          nSaida := 0
          T_SERIES->( DbGoTop() )
         
          WHILE !T_SERIES->( EOF() )
             nSaida += 1
             If nSaida > aConsulta[nContar,06]
                Exit
             Endif
             aadd(aItem,{{"D3_FILIAL" , Substr(cComboBx1,01,02), NIL},;
                         {"D3_COD"    , aConsulta[nContar,04]  , NIL},;
                         {"D3_QUANT"  , 1                      , NIL},;
                         {"D3_LOCAL"  , aConsulta[nContar,03]  , NIL},;
                         {"D3_CUSTO1" , aConsulta[nContar,07]  , NIL},;
                         {"D3_LOCALIZ", T_SERIES->BF_LOCALIZ   , NIL},;
                         {"D3_NUMSERI", T_SERIES->BF_NUMSERI   , NIL}})
             lEfetiva := .T.
             T_SERIES->( DbSkip() )
          ENDDO
       Endif
   Next nContar
    
   // Atualiza os registros de Movimentação Interna 2
   If lEfetiva   
      MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,aItem, 3)
   Endif   

   // Registra os registros de Entrada da quantidade selecionada
   lEfetiva := .F.
   aCab     := {}
   aItem    := {}      

   aCab := {{"D3_FILIAL", Substr(cComboBx1,01,02), NIL},;
            {"D3_DOC"    , cDocEntra             , Nil},;
            {"D3_TM"     , '400'                 , Nil},;
            {"D3_CC"     , ''                    , Nil},;
            {"D3_EMISSAO", Date()                , Nil}}
                                                   
   For nContar = 1 to Len(aConsulta)

       // Se não marcado, despreza
       If aConsulta[nContar,1] == .F.
          Loop
       Endif
          
       aadd(aItem,{{"D3_FILIAL", Substr(cComboBx1,01,02), NIL},;
                   {"D3_COD"   , aConsulta[nContar,04]  , NIL},;
                   {"D3_QUANT" , aConsulta[nContar,06]  , NIL},;
                   {"D3_LOCAL" , aConsulta[nContar,03]  , NIL},;
                   {"D3_CUSTO1", (aConsulta[nContar,06] * aConsulta[nContar,08]), NIL}})
       lEfetiva := .T.

   Next nContar
    
   // Atualiza os registros de Movimentação Interna 2
   If lEfetiva
      MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,aItem, 3)
   Endif   

   MsgAlert("Correção de Custos finalizada com sucesso.")

   BuscaFilProd("F")

Return .T.