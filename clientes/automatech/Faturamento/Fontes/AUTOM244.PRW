#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM244.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/08/2014                                                          *
// Objetivo..: Programa que realiza pessquisa de Entidades - Clientes, Fornecedor, *
//             Transportadora, Vendedor                                            *
//**********************************************************************************

User Function AUTOM244()

   Local cMemo1	      := ""
   Local oMemo1

   Private cString	  := Space(100)
   Private cCadastro  := ""
   Private cCampo     := ReadVar()
   Private cCodLoja   := ReadVar()

   Private aCampo  	  := {"01 - Nome", "02 - Código", "03 - CNPJ/CPF", "04 - Município"}
   Private aOperador  := {"01 - Igual", "02 - Iniciando", "03 - Contendo"}
   Private aOrdenacao := {"01 - Por Código", "02 - Por Nome", "03 - Por CNPJ/CPF", "04 - Município"}

   Private oGet1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private aBrowse := {}

   Private oDlg

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

   U_AUTOM628("AUTOM244")

   // Inicializa o conteúdo do combo
   cComboBx3 := "03 - Contendo"
   cComboBx4 := "02 - Por Nome"
   
   DEFINE MSDIALOG oDlg TITLE "Pesquisa Cadastro de Entidades" FROM C(178),C(181) TO C(602),C(909) PIXEL

   @ C(008),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(197),C(085) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(197),C(154) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(043),C(002) GET oMemo1 Var cMemo1 MEMO Size C(357),C(001) PIXEL OF oDlg
   
   @ C(006),C(138) Say "String a Pesquisar"   Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(138) Say "Ordenação Pesquisa"   Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(019),C(138) Say "Pesquisar pelo Campo" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(018),C(269) Say "Operação"             Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(097) Say "Sem pendências financeiras" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(198),C(166) Say "Com pendências financeiras" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(005),C(193) MsGet oGet1 Var cString  Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(003),C(323) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlg ACTION( xbuscaCli() )

   @ C(018),C(193) ComboBox cComboBx2 Items aCampo     Size C(071),C(010) PIXEL OF oDlg
   @ C(018),C(295) ComboBox cComboBx3 Items aOperador  Size C(065),C(010) PIXEL OF oDlg
   @ C(029),C(193) ComboBox cComboBx4 Items aOrdenacao Size C(168),C(010) PIXEL OF oDlg

   @ C(195),C(005) Button "Visualizar Cadastro" Size C(063),C(012) PIXEL OF oDlg ACTION( xCadCliente( aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(195),C(283) Button "Selecionar"          Size C(037),C(012) PIXEL OF oDlg ACTION( xSelCliente( aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) )
   @ C(195),C(322) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( xSelCliente( "", "", "") )

   aAdd( aBrowse, { "1", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 062 , 005, 456, 182,,{"LG", "Código", "Loja", "Descrição", "CNPJ/CPF", "Município", "UF"}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
      oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aBrowse[oBrowse:nAt,02]               ,;
                            aBrowse[oBrowse:nAt,03]               ,;
                            aBrowse[oBrowse:nAt,04]               ,;
                            aBrowse[oBrowse:nAt,05]               ,;
                            aBrowse[oBrowse:nAt,06]               }}

   Endif   

   ACTIVATE MSDIALOG oDlg CENTERED 

Return( aBrowse[oBrowse:nAt,02] + "." + aBrowse[oBrowse:nAt,03] + " - " + Alltrim(aBrowse[oBrowse:nAt,04]) )

// Função que fecha a janela pelo botão selecionar e transfere código e loja selecionados
Static Function xSelCliente(_Codigo, _Loja, _NomeCli)
   
   oDlg:End()

//   Return( _Codigo + "|" + _Loja + "|" + _NomeCli + "|")
//
//   // Posiciona no cliente selecionado
//   DbSelectArea("SA1")
//   DbSetOrder(1)
//   DbSeek(xFilial("SA1") + _Codigo + _Loja)
//   
//   &cCampo     := _Codigo
//   &cCodLoja   := _Loja
//   aCpoRet[1]  := _Codigo
//
//   oDlg:End()
   
Return( _Codigo + "." + _Loja + " - " + Alltrim(_NomeCli))

// Função que pesquisa o cliente informado
Static Function xbuscaCli()

   Local cSql   := ""

   aArea := GetArea()
   
   aBrowse := {}

   If Len(Alltrim(cString)) == 0
      aAdd( aBrowse, { '1', '', '', '', '', '', '' } )
      oBrowse:SetArray(aBrowse) 
      Return .T.
   Endif   

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.A1_COD ," + chr(13)
   cSql += "       A.A1_LOJA," + chr(13)
   cSql += "       A.A1_NOME," + chr(13)
   cSql += "       CASE WHEN LEN(A.A1_CGC) = 14  THEN SUBSTRING(A.A1_CGC,01,02) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,03,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,06,03) + '/' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,09,04) + '-' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,13,02)        " + chr(13)
   cSql += "            WHEN LEN(A.A1_CGC) <> 14 THEN SUBSTRING(A.A1_CGC,01,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,04,03) + '.' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,07,03) + '-' +" + chr(13)
   cSql += "                                          SUBSTRING(A.A1_CGC,10,02)        " + chr(13)
   cSql += "       END AS CGC," + chr(13)
   cSql += "       A.A1_MUN  ," + chr(13)
   cSql += "       A.A1_EST   " + chr(13)
   cSql += "  FROM " + RetSqlName("SA1") + " A " + chr(13)
   cSql += " WHERE A.D_E_L_E_T_ = ''"   + chr(13)

   Do Case

      // Nome
      Case Substr(cComboBx2,01,02) = "01"
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.A1_NOME = '" + Alltrim(cString) + "'" + CHR(13)
              // Iniciando
              Case Substr(cComboBx3,01,02) == "02" 
                   cSql += " AND A.A1_NOME LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.A1_NOME LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // Código
      Case Substr(cComboBx2,01,02) = "02"
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.A1_COD = '" + Alltrim(cString) + "'" + CHR(13)
              // Iniciando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND A.A1_COD  LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.A1_COD  LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // CNPJ/CPF
      Case Substr(cComboBx2,01,02) = "03"
           Do Case
              Case Substr(cComboBx3,01,02) == "01" // Igual
                   cSql += " AND A.A1_CGC = '" + Alltrim(cString) + "'" + CHR(13)
              Case Substr(cComboBx3,01,02) == "02" // Iniciando
                   cSql += " AND A.A1_CGC LIKE '" + Alltrim(cString) + "%'" + CHR(13)
              Case Substr(cComboBx3,01,02) == "03" // Contendo
                   cSql += " AND A.A1_CGC LIKE '%" + Alltrim(cString) + "%'" + CHR(13)
           EndCase                   

      // Município
      Case Substr(cComboBx2,01,02) = "04" 
           Do Case
              // Igual
              Case Substr(cComboBx3,01,02) == "01"
                   cSql += " AND A.B1_POSIPI = '" + Alltrim(cPesquisa) + "'" + CHR(13)
              // Inicando
              Case Substr(cComboBx3,01,02) == "02"
                   cSql += " AND A.B1_POSIPI LIKE '" + Alltrim(cPesquisa) + "%'" + CHR(13)
              // Contendo
              Case Substr(cComboBx3,01,02) == "03"
                   cSql += " AND A.B1_POSIPI LIKE '%" + Alltrim(cPesquisa) + "%'" + CHR(13)
           EndCase                   

   EndCase

   // Ordenação
   Do Case
      // Código
      Case Substr(cComboBx4,01,02) == "01"
           cSql += " ORDER BY A.A1_COD, A.A1_LOJA" + CHR(13)
      // Descrição
      Case Substr(cComboBx4,01,02) == "02" 
           cSql += " ORDER BY A.A1_NOME" + CHR(13)
      // Part Number
      Case Substr(cComboBx4,01,02) == "03" 
           cSql += " ORDER BY A.A1_CGC" + CHR(13)
      // NCM
      Case Substr(cComboBx4,01,02) == "04" 
           cSql += " ORDER BY A.A1_MUN" + CHR(13)
   EndCase                   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aBrowse, { '1', '', '', '', '', '', '' } )
   Else

      T_CLIENTE->( DbGoTop() )

      WHILE !T_CLIENTE->( EOF() )

         // Pesquisa possíveis parcelas em atraso
         If Select("T_PARCELAS") > 0
            T_PARCELAS->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT A.E1_CLIENTE ,"
         cSql += "       A.E1_LOJA    ,"
         cSql += "       A.E1_PREFIXO ,"
         cSql += "       A.E1_NUM     ,"
         cSql += "       A.E1_PARCELA ,"
         cSql += "       A.E1_EMISSAO ,"
         cSql += "       A.E1_VENCTO  ,"
         cSql += "       A.E1_BAIXA   ,"
         cSql += "       A.E1_VALOR   ,"
         cSql += "       A.E1_SALDO    "
         cSql += "  FROM " + RetSqlName("SE1") + " A "
         cSql += " WHERE A.D_E_L_E_T_ = ''"
         cSql += "   AND A.E1_SALDO  <> 0 "
         cSql += "   AND A.E1_CLIENTE = '" + Alltrim(T_CLIENTE->A1_COD)   + "'"
         cSql += "   AND A.E1_LOJA    = '" + Alltrim(T_CLIENTE->A1_LOJA)  + "'"
         cSql += "   AND A.E1_VENCTO < CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
         cSql += "   AND (A.E1_TIPO   <> 'RA' AND A.E1_TIPO <> 'NCC')"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )

         If T_PARCELAS->( EOF() )
            _Devedor := "2"
         Else
            _Devedor := "8"         
         Endif

         aAdd( aBrowse, { _Devedor                      ,;
                          T_CLIENTE->A1_COD             ,;
                          T_CLIENTE->A1_LOJA            ,;
                          T_CLIENTE->A1_NOME + Space(50),;
                          T_CLIENTE->CGC     + Space(10),;
                          T_CLIENTE->A1_MUN  + Space(30),;
                          T_CLIENTE->A1_EST             })

         T_CLIENTE->( DbSkip() )

      ENDDO

   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;
                         aBrowse[oBrowse:nAt,05]               ,;
                         aBrowse[oBrowse:nAt,06]               }}

   RestArea( aArea )

Return(.T.)

// Função que visualiza o cadastro do cliente selecionado
Static Function xCadCliente(_Codigo, _Loja)

   If Empty(Alltrim(_Codigo))
      MsgAlert("Necessário selecione um cliente para realizar esta operação.")
      Return(.T.)
   Endif

   aArea := GetArea()
   
   // Posiciona no cliente a ser pesquisado
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1") + _Codigo + _Loja)

   AxVisual("SA1", SA1->( Recno() ), 1)

   RestArea( aArea )

Return .T.
