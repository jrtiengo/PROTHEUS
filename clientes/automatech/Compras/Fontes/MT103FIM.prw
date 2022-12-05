#Include "Protheus.ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: MT103FIM.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/04/2012                                                          ##
// Objetivo..: Ponto de Entrada disparado após a gravação do documento de entrada. ##
//             barras no final da nota fiscal de entrada. Isso serve para o CNAB   ##
//             do Banco Itaú.                                                      ##
// ##################################################################################

User Function MT103FIM()

   Local cSql     := ""
   Local lChumba  := .F.
 
   Private xNota  := Space(25)
   Private xSerie := Space(25)
   Private xForne := Space(25)
   Private xLoja  := Space(25)
   Private xNome  := Space(25)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
  
   Private aBrowse := {}

   U_AUTOM628("MT103FIM")
    
   xNota  := cNfiscal
   xSerie := cSerie
   xForne := cA100For
   xLoja  := cLoja
  
   // ###################################
   // Se nota fiscal = branco, retorna ##
   // ###################################
   If Empty(Alltrim(xNota))
      Return .T.
   Endif    

   // ####################################################################
   // Realiza as consistências somente em caso de inclusão de documento ##
   // ####################################################################
   If Inclui == .F.
      Return(.T.)
   Endif   

   // ####################################################################################################################
   // Envia para a função que realiza o fechamento do Tickt FressDesk em caso de nota fiscal de retorno de demonstração ##
   // ####################################################################################################################
   FechTctDemo(xNota, xSerie, xForne, xLoja)

   // #####################################################################################################################
   // Envia para a função que envia o e-mail ao vendedor em caso de nota fiscal de devolução de demonstração (TES = 024) ##
   // #####################################################################################################################
   eMailDemo(xNota, xSerie, xForne, xLoja)
   
   // ################################################################################################
   // Envia para a função que envia o e-mail aos grupos parametrizados no Parametrizador Automatech ##
   // ################################################################################################
   eMailAviso(xNota, xSerie, xForne, xLoja)

   // ################################################################################################
   // Envia para a função que abre janela solicitando a marcação da RMA caso nota fiscal de retorno ##
   // ################################################################################################
   MarcaRMARet(xNota, xSerie, xForne, xLoja)

   // ###################################################################################
   // Função que marca os produto da nota fiscal para ser gerado cálculo para OpenCart ##
   // ###################################################################################
   //GeraOpenCart(xNota, xSerie, xForne, xLoja)

   // ##############################################################################################
   // Envia para a função que gera o cálculo do SalesMachine dos produtos do documento de entrada ##
   // ##############################################################################################
   CalcSalesMachine(xNota, xSerie, xForne, xLoja)

   // -------------------------------------------------------------- //
   // Função que solicita os códigos de barras dos boletos bancários //
   // -------------------------------------------------------------- //

   // -------------------------------------------------------------------------------------------------- //
   // 01/02/2016 - Por Harald Hans Löschenkohl                                                           //
   // NÃO ELIMINAR O PROCESSO ABAIXO. DEIXAR COMENTADO E FALAR COM HARALD ANTES DE FAZER QUALQUER COISA. //
   // Esta procedimento foi retirado temporariamente em função deste não estar sendo utilizado por hora. //
   // -------------------------------------------------------------------------------------------------- //

   /*
   // Pesquisa o nome do Fornecedor para display
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(xForne) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(xLoja)  + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   xNome  := T_CLIENTE->A1_NOME

   Private oDlg

   // Pesquisa as parcelas para display
   If Select("T_TITULO") > 0
      T_TITULO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E2_PARCELA,"
   cSql += "       E2_NUM    ,"
   cSql += "       E2_VENCTO ,"
   cSql += "       E2_VALOR  ,"
   cSql += "       E2_CODBAR ,"
   cSql += "       E2_TIPO   ,"
   cSql += "       E2_CBCO   ,"
   cSql += "       E2_CMOE   ,"
   cSql += "       E2_DVBA   ,"
   cSql += "       E2_FATO   ,"
   cSql += "       E2_CVAL   ,"
   cSql += "       E2_LIVRE  ,"
   cSql += "       E2_TLEI    "
   cSql += "  FROM " + RetSqlName("SE2")
   cSql += " WHERE E2_NUM    = '" + Alltrim(xNota)  + "'"
   cSql += "  AND E2_PREFIXO = '" + Alltrim(xSerie) + "'"
   cSql += "  AND E2_FORNECE = '" + Alltrim(xForne) + "'"
   cSql += "  AND E2_LOJA    = '" + Alltrim(xLoja)  + "'"
   cSql += "  AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TITULO", .T., .T. )

   If T_TITULO->( EOF() )
      Return .T.
   Endif

   Select("T_TITULO")
   T_TITULO->( DbGoTop() )
   DO WHILE !T_TITULO->( EOF() )
      dVencimento := Substr(T_TITULO->E2_VENCTO,07,02) + "/" + Substr(T_TITULO->E2_VENCTO,05,02) + "/" + Substr(T_TITULO->E2_VENCTO,01,04)
      aAdd( aBrowse, { T_TITULO->E2_PARCELA, ;
                       T_TITULO->E2_NUM    , ;
                       dVencimento         , ;
                       T_TITULO->E2_VALOR  , ;
                       T_TITULO->E2_CODBAR , ;
                       T_TITULO->E2_CBCO   , ;
                       T_TITULO->E2_CMOE   , ;
                       T_TITULO->E2_DVBA   , ;
                       T_TITULO->E2_FATO   , ;
                       T_TITULO->E2_CVAL   , ;
                       T_TITULO->E2_LIVRE  , ;
                       T_TITULO->E2_TIPO   , ;
                       T_TITULO->E2_TLEI   } )  
      T_TITULO->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Código de Barras dos Títulos" FROM C(178),C(181) TO C(451),C(821) PIXEL

   @ C(006),C(004) Say "Nota Fiscal"            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(048) Say "Série"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(073) Say "Fornecedor"             Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(003) Say "Títulos da Nota Fiscal" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(015),C(003) MsGet oGet1 Var xNota  When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(048) MsGet oGet2 Var xSerie When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(073) MsGet oGet3 Var xForne When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(100) MsGet oGet4 Var xLoja  When lChumba Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(121) MsGet oGet5 Var xNome  When lChumba Size C(195),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(120),C(168) Button "Informar Código Barras" Size C(070),C(012) PIXEL OF oDlg ACTION( ABRECODIGO() )
   @ C(120),C(240) Button "Confirmar"              Size C(037),C(012) PIXEL OF oDlg ACTION( GRAVATITULO() )
   @ C(120),C(279) Button "Voltar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 040 , 003, 400, 110,,{'Prc', 'Título', 'Vencimento', 'Valor', 'Codigo de Barras' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05],;
                         ""                     ,;
                         ""                     ,;                         
                         ""                     ,;
                         ""                     ,;
                         ""                     ,;
                         ""                     ,;
                         aBrowse[oBrowse:nAt,05],;
                         ""                     } }

   ACTIVATE MSDIALOG oDlg CENTERED 

   */

Return(.T.)

// Abre janela para informação do código de barras para a parcela selecionada
Static Function AbreCodigo()

   Local lChumbado := .F.

   Local aComboBx1 := {"Scaner","Manual"}
   Local cComboBx1

   Local cParcela    := aBrowse[oBrowse:nAt,01]
   Local cTitulo     := aBrowse[oBrowse:nAt,02]
   Local cVencimento := aBrowse[oBrowse:nAt,03]
   Local cValor      := aBrowse[oBrowse:nAt,04]
   Local cBarras     := aBrowse[oBrowse:nAt,05]

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Private oDlgx

   DEFINE MSDIALOG oDlgx TITLE "Informação Código de Barras" FROM C(178),C(181) TO C(389),C(540) PIXEL

   @ C(008),C(007) Say "Parcela"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(022),C(007) Say "Título"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(034),C(008) Say "Vencimento"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(047),C(008) Say "Valor"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(061),C(008) Say "Tipo Leitura"  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(074),C(007) Say "Código Barras" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
      
   @ C(007),C(043) MsGet oGet1 Var cParcela    when lChumbado Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(020),C(044) MsGet oGet2 Var cTitulo     when lChumbado Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(033),C(043) MsGet oGet3 Var cVencimento when lChumbado Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(046),C(043) MsGet oGet4 Var cValor      when lChumbado Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(059),C(043) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlgx
   @ C(073),C(044) MsGet oGet5 Var cBarras            Size C(129),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx

   @ C(088),C(049) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgx ACTION( GRAVABARRA(cParcela, cComboBx1, cBarras) )
   @ C(088),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgx ACTION( oDlgx:End() )

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Função que atualiza o codigo de barras no array aBrowse
Static Function GRAVABARRA(_Parcela, _Combo, _Barras)

   Local nContar     := 0
   Local _Banco      := ""
   Local _Moeda      := ""
   Local _DVBarras   := ""
   Local _Fator      := ""
   Local _ValTitulo  := ""
   Local _CampoLivre := ""

   // Prapara os Campos para Gravação

   If Alltrim(_Combo) == "Scaner"
      _Banco      := Substr(_Barras,01,03)
      _Moeda      := Substr(_Barras,04,01)
      _DVBarras   := Substr(_Barras,05,01)
      _Fator      := Substr(_Barras,06,04)
      _ValTitulo  := Substr(_Barras,10,10)
      _CampoLivre := Substr(_Barras,20,25)
   Else
      _Banco      := Substr(_Barras,01,03)
      _Moeda      := Substr(_Barras,04,01)
      _DVBarras   := Substr(_Barras,33,01)
      _Fator      := Substr(_Barras,34,04)
      _ValTitulo  := Substr(_Barras,38,10)
      _CampoLivre := Substr(_Barras,05,05) + Substr(_Barras,11,10) + Substr(_Barras,22,10)
   Endif

   For nContar = 1 to Len(aBrowse)
       If Alltrim(aBrowse[nContar,01]) == Alltrim(_Parcela)
          aBrowse[nContar,05] := _Barras
          aBrowse[nContar,06] := _Banco
          aBrowse[nContar,07] := _Moeda
          aBrowse[nContar,08] := _DVBarras
          aBrowse[nContar,09] := _Fator
          aBrowse[nContar,10] := _ValTitulo
          aBrowse[nContar,11] := _CampoLivre

          If Alltrim(_Combo) == "Scaner"
             aBrowse[nContar,13] := "S"
          Else
             aBrowse[nContar,13] := "M"             
          Endif   

          Exit
       Endif
   Next nContar
          
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05]} }

   oDlgx:End()

Return .T.

// Função que atualiza o codigo de barras no array aBrowse
Static Function GRAVATITULO()

   Local nContar := 0
   Local lResult
   Local cSql    := ""

   For nContar = 1 to Len(aBrowse)

       cSql := ""
       cSql := "UPDATE " + RetSqlName("SE2") + CHR(13)
       cSql += "   SET " + CHR(13)
       cSql += "   E2_CODBAR = '" + Alltrim(aBrowse[nContar,05]) + "', " + CHR(13)
       cSql += "   E2_CBCO   = '" + Alltrim(aBrowse[nContar,06]) + "', " + CHR(13)
       cSql += "   E2_CMOE   = '" + Alltrim(aBrowse[nContar,07]) + "', " + CHR(13)
       cSql += "   E2_DVBA   = '" + Alltrim(aBrowse[nContar,08]) + "', " + CHR(13)
       cSql += "   E2_FATO   = '" + Alltrim(aBrowse[nContar,09]) + "', " + CHR(13)
       cSql += "   E2_CVAL   = '" + Alltrim(aBrowse[nContar,10]) + "', " + CHR(13)
       cSql += "   E2_LIVRE  = '" + Alltrim(aBrowse[nContar,11]) + "', " + CHR(13)
       cSql += "   E2_TLEI   = '" + Alltrim(aBrowse[nContar,13]) + "'  " + CHR(13)
       cSql += " WHERE E2_PREFIXO = '" + Alltrim(xSerie)              + "'" + CHR(13)
       cSql += "   AND E2_NUM     = '" + Alltrim(aBrowse[nContar,02]) + "'" + CHR(13)
       cSql += "   AND E2_PARCELA = '" + Alltrim(aBrowse[nContar,01]) + "'" + CHR(13)
       cSql += "   AND E2_TIPO    = '" + Alltrim(aBrowse[nContar,12]) + "'" + CHR(13)
       cSql += "   AND E2_FORNECE = '" + Alltrim(xForne)              + "'" + CHR(13)
       cSql += "   AND E2_LOJA    = '" + Alltrim(xLoja)               + "'" + CHR(13)

       lResult := TCSQLEXEC(cSql)
       If lResult < 0
          Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
       EndIf 

   Next nContar

   oDlg:End()
   
Return .T.

// Função que envia e-mail para o vendedor em caso de nota fiscal de devolução de demonstração
Static Function eMailDemo(_Nota, _Serie, _Forne, _Loja)

   Local csql   := ""
   Local cTexto := ""
   Local cEmail := ""

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT A.D1_FILIAL ,"
   cSql += "       A.D1_TES    ,"
   cSql += "       A.D1_COD    ,"
   cSql += "       A.D1_QUANT  ,"
   cSql += "       A.D1_FORNECE,"
   cSql += "       A.D1_LOJA   ,"
   cSql += "       A.D1_DOC    ,"
   cSql += "       A.D1_SERIE  ,"
   cSql += "       A.D1_NFORI  ,"
   cSql += "       A.D1_SERIORI,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       C.A1_NOME   ,"
   cSql += "       D.F2_VEND1  ,"
   cSql += "       E.A3_NOME   ,"
   cSql += "       E.A3_EMAIL   "
   cSql += "  FROM " + RetSqlName("SD1") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B, "
   cSql += "       " + RetSqlName("SA1") + " C, "
   cSql += "       " + RetSqlName("SF2") + " D, "
   cSql += "       " + RetSqlName("SA3") + " E  "
   cSql += " WHERE A.D1_DOC     = '" + Alltrim(_Nota)  + "'"
   cSql += "   AND A.D1_SERIE   = '" + Alltrim(_serie) + "'"
   cSql += "   AND A.D1_TES     = '024'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.D1_COD     = B.B1_COD    "
   cSql += "   AND A.D1_FORNECE = C.A1_COD    "
   cSql += "   AND A.D1_LOJA    = C.A1_LOJA   "
   cSql += "   AND D.F2_DOC     = A.D1_NFORI  "
   cSql += "   AND D.F2_SERIE   = A.D1_SERIORI"
   cSql += "   AND D.F2_FILIAL  = A.D1_FILIAL "
   cSql += "   AND D.D_E_L_E_T_ = ''          "
   cSql += "   AND D.F2_VEND1   = E.A3_COD    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If T_NOTA->( EOF() )
      Return .T.
   Endif
   
   If Empty(Alltrim(T_NOTA->A3_EMAIL))
      Return .T.
   Endif

   cEmail := T_NOTA->A3_EMAIL
   
   cTexto := ""
   cTexto := cTexto + "Prezado(a) " + Alltrim(T_NOTA->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto := cTexto + "Informamos que o(s) produto(s) abaixo relacionado(s) que foram enviados ao cliente" + chr(13) + chr(10)
   cTexto := cTexto + Alltrim(T_NOTA->A1_NOME) + " na forma de Demonstração em seu nome," + chr(13) + chr(10) 
   cTexto := cTexto + "com a nota fiscal nº " + Alltrim(T_NOTA->D1_NFORI) + " Série: " + Alltrim(T_NOTA->D1_SERIORI) + " "
   cTexto := cTexto + "foram devolvidos com a Nota Fiscal Nº " + Alltrim(T_NOTA->D1_DOC) + " Série: " + Alltrim(T_NOTA->D1_SERIE) + "." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
   cTexto := cTexto + "Produto  -  Descrição dos Produtos" + chr(13) + chr(10)

   WHILE !T_NOTA->( EOF() )
      cTexto := cTexto + Alltrim(T_NOTA->D1_COD) + "   -    " + Alltrim(T_NOTA->B1_DESC) + " " + Alltrim(T_NOTA->B1_DAUX) + CHR(13) + CHR(10)
      T_NOTA->( DbSkip() )
   ENDDO   

   cTexto := cTexto + chr(13) + chr(10)
   cTexto := cTexto + "Att."  + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto := cTexto + "Departamento de Estoque"

   // Envia e-mail ao Aprovador
   U_AUTOMR20(cTexto , Alltrim(cEmail), "", "Devolução de Demonstração de Produtos" )

Return .T.

// Função que envia e-mail para os grupos parametrizador no Parametrizador Automatech
Static Function eMailAviso(_Nota, _Serie, _Forne, _Loja)

   Local csql   := ""
   Local cTexto := ""
   Local cEmail := ""

   If Inclui == .F.
      Return(.T.)
   Endif

   // Pesquisa o e-mail que deverá ser utilizado para envio do e-mail
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql += "SELECT ZZ4_GENT"
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
 
   If T_PARAMETROS->( EOF() )
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_GENT))
      Return(.T.)
   Endif

   // Psquisa os produtos da nota fiscal de entrada para relacionar no e-mail
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf
      
   cSql := "SELECT A.D1_FILIAL ,"
   cSql += "       A.D1_TES    ,"
   cSql += "       A.D1_COD    ,"
   cSql += "       A.D1_QUANT  ,"
   cSql += "       A.D1_FORNECE,"
   cSql += "       A.D1_LOJA   ,"
   cSql += "       A.D1_DOC    ,"
   cSql += "       A.D1_SERIE  ,"
   cSql += "       A.D1_NFORI  ,"
   cSql += "       A.D1_SERIORI,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       C.A2_NOME   "
   cSql += "  FROM " + RetSqlName("SD1") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B, " 
   cSql += "       " + RetSqlName("SA2") + " C  "
   cSql += " WHERE A.D1_DOC     = '" + Alltrim(_Nota)  + "'"
   cSql += "   AND A.D1_SERIE   = '" + Alltrim(_Serie) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.D1_COD     = B.B1_COD"
   cSql += "   AND A.D1_FORNECE = C.A2_COD"    
   cSql += "   AND A.D1_LOJA    = C.A2_LOJA"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   // Elabora o texto do e-mail   
   cTexto := ""
   cTexto := "Prezado(a) Usuário(a)" + chr(13) + chr(10) + chr(13) + chr(10)
   
   cTexto += "Informamos que a Nota Fiscal nº " + Alltrim(_Nota)       + ;
             " Série " + Alltrim(_Serie) + " do Fornecedor "           + ;
             Alltrim(_forne) + "." + Alltrim(_loja) + " - "            + ;
             Alltrim(T_PRODUTOS->A2_NOME) + ", foi dado entrada no Sistema no dia " + ;
             Dtoc(Date()) + "  dos seguintes produtos:" + chr(13) + chr(10) + chr(13) + chr(10)
   
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
      cTexto += Alltrim(T_PRODUTOS->D1_COD) + " - " + Alltrim(T_PRODUTOS->B1_DESC) + " " + Alltrim(T_PRODUTOS->B1_DAUX) + chr(13) + chr(10)
      T_PRODUTOS->( DbSkip() )
   ENDDO
   
   cTexto += chr(13) + chr(10)
   cTexto += "Att." + chr(13) + chr(10) + chr(13) + chr(10)
   
   cTexto += "Automatech Sistemas de Automação Ltda" + chr(13) + chr(10)
   cTexto += "Departamento Controladoria"            + chr(13) + chr(10)

   // Envia e-mail
   U_AUTOMR20(cTexto , Alltrim(T_PARAMETROS->ZZ4_GENT), "", "Aviso de Entrada de Mercadorias" )

Return .T.

// Função que abre janela de solicitação da marcação da RMA referente a nota fiscal de retorno.
Static Function MarcaRMARet(_Nota, _Serie, _Forne, _Loja)

   Local cSql    := ""
   Local nContar := ""
   Local cMemo1	 := ""
   Local oMemo1

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   Private aMaterial := {}

   Private oDlgRMA
   
   // Pesquisa o parâmetro TES devolução RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TRMA" 
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return(.T.)
   Endif

   // Pesquisa os dados da nota fiscal de entrada para verificação da abertura da tela de indicação de RMA
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf
  
   cSql := "SELECT D1_FILIAL,"
   cSql += "       D1_COD   ,"
   cSql += "       D1_ITEM  ,"
   cSql += "       D1_TES    "
   cSql += "  FROM " + RetSqlName("SD1")
   cSql += " WHERE D1_DOC     = '" + Alltrim(_Nota)  + "'"
   cSql += "   AND D1_SERIE   = '" + Alltrim(_Serie) + "'"
   cSql += "   AND D1_FORNECE = '" + Alltrim(_Forne) + "'"
   cSql += "   AND D1_LOJA    = '" + Alltrim(_Loja)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
   
   If T_PRODUTOS->( EOF() )
      Return(.T.)
   Endif

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )

      // Verifica se o TES pertence ao parâmetro Automatech
      If U_P_OCCURS(T_PARAMETROS->ZZ4_TRMA, T_PRODUTOS->D1_TES, 1) == 0
         T_PRODUTOS->( DbSkip() )
         Loop
      Endif

      If Select("T_DADOSRMA") > 0
         T_DADOSRMA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS4.ZS4_NRMA,"
      cSql += "       ZS4.ZS4_ANO ,"            
      csql += "       ZS4.ZS4_STAT,"
      csql += "       ZS4.ZS4_NOTA,"
      csql += "       ZS4.ZS4_SERI,"
      cSql += "       ZS4.ZS4_ABER,"
      cSql += "       ZS4.ZS4_HORA,"
      cSql += "       ZS4.ZS4_ITEM,"
      cSql += "       ZS4.ZS4_PROD,"
      cSql += "       SB1.B1_DESC AS DESCRICAO "
      cSql += "  FROM " + RetSqlName("ZS4") + " ZS4, "
      cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE ZS4.ZS4_CLIE   = '" + Alltrim(_Forne) + "'"
      cSql += "   AND ZS4.ZS4_LOJA   = '" + Alltrim(_Loja)  + "'"
//    cSql += "   AND ZS4.ZS4_ITEM   = '" + Alltrim(T_PRODUTOS->D1_ITEM) + "'"
      cSql += "   AND ZS4.ZS4_PROD   = '" + Alltrim(T_PRODUTOS->D1_COD)  + "'"
      cSql += "   AND ZS4.ZS4_NRET   = ''"
      cSql += "   AND ZS4.D_E_L_E_T_ = ''"
      cSql += "   AND ZS4.ZS4_PROD   = SB1.B1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOSRMA", .T., .T. )

      If T_DADOSRMA->( EOF() )
         T_PRODUTOS->( DbSkip() )                                  
         Loop
      Endif
      
      If T_DADOSRMA->ZS4_STAT < "6"
         T_PRODUTOS->( DbSkip() )                                  
         Loop
      Endif

      // Pesquisa o RMA para o produto lido   
      aAdd( aMaterial, { .F.                   ,;
                         T_DADOSRMA->ZS4_NRMA  ,;
                         T_DADOSRMA->ZS4_ANO   ,;
                         T_DADOSRMA->ZS4_NOTA  ,;
                         T_DADOSRMA->ZS4_SERI  ,;                         
                         T_DADOSRMA->ZS4_ITEM  ,;
                         T_DADOSRMA->ZS4_PROD  ,;
                         T_DADOSRMA->DESCRICAO })

      T_PRODUTOS->( DbSkip() )                         
      
   Enddo

   If Len(aMaterial) == 0
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgRMA TITLE "RMA - Return Merchandise Authorization" FROM C(178),C(181) TO C(471),C(767) PIXEL

   @ C(001),C(001) Jpeg FILE "logoautoma.bmp" Size C(125),C(027) PIXEL NOBORDER OF oDlgRMA
   @ C(022),C(189) Say "R M A - Return Merchandise Authorization" Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA
   @ C(034),C(005) Say "Marque o(s) produto(s) que faz(em) parte da devolução" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgRMA

   @ C(031),C(001) GET oMemo1 Var cMemo1 MEMO Size C(287),C(001) PIXEL OF oDlgRMA

   @ C(131),C(004) Button "Marca Todos"    Size C(050),C(012) PIXEL OF oDlgRMA ACTION(MRCRMARET(1))
   @ C(131),C(055) Button "Desmarca Todos" Size C(050),C(012) PIXEL OF oDlgRMA ACTION(MRCRMARET(2))
   @ C(131),C(251) Button "Confirmar"      Size C(037),C(012) PIXEL OF oDlgRMA ACTION(CFMRMARET( _Nota, _Serie, _Forne, _Loja ))

   // Cria Componentes Padroes do Sistema
   @ 055,005 LISTBOX oMaterial FIELDS HEADER "", "Nº RMA", "Ano" ,"Nº NFiscal", "Série", "Item", "Código", "Descrição dos Produtos" PIXEL SIZE 365,108 OF oDlgRMA ;
                               ON dblClick(aMaterial[oMaterial:nAt,1] := !aMaterial[oMaterial:nAt,1],oMaterial:Refresh())     
   oMaterial:SetArray( aMaterial )
   oMaterial:bLine := {||     {Iif(aMaterial[oMaterial:nAt,01],oOk,oNo),;
             		    		   aMaterial[oMaterial:nAt,02],;
         	         	           aMaterial[oMaterial:nAt,03],;
         	         	           aMaterial[oMaterial:nAt,04],;
         	         	           aMaterial[oMaterial:nAt,05],;         	         	           
         	         	           aMaterial[oMaterial:nAt,06],;
         	         	           aMaterial[oMaterial:nAt,07],;         	         	           
         	         	           aMaterial[oMaterial:nAt,08]}}

   ACTIVATE MSDIALOG oDlgRMA CENTERED 

Return(.T.)

// Função que marca e desmarca os ítens retornados da RMA
Static Function MrcRMARet(_Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aMaterial)
       If _Tipo == 1
          aMaterial[nContar,1] := .T.
       Else
          aMaterial[nContar,1] := .F.
       Endif
   Next nContar
   
Return(.T.)

// Função que realiza a confirmação da RMA
Static Function CFMRMARET( _Nota, _Serie, _Forne, _Loja )

   Local nContar    := 0
   Local _nErro     := 0
   Local lVerifica  := .F.
   Local lContinuar := .F.
   
   // Verifica se houve indicação de pelo meno um produto para baixa da RMA
   For nContar = 1 to Len(aMaterial)
       If aMaterial[nContar,1] == .T.
          lVerifica := .T.
          Exit
       Endif
   Next nContar
   
   If lVerifica == .F.

      lContinuar := .F.

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não foi indicado nenhum produto para baixa da RMA." + chr(13) + chr(10) + "Tem certeza que deseja continuar sem baixar nenhum produto da RMA?")
         lContinuar := .T.      
      Else
         lContinuar := .F.
         Return(.T.)      
      Endif
      
   Else
   
      lContinuar := .T.
         
   Endif

   // Grava o nº da nota fiscal de retorno no registro da RMA
   For nContar = 1 to Len(aMaterial)
       If aMaterial[nContar,1] == .F.
          Loop
       Endif
          
       cSql := ""
       cSql := "UPDATE " + RetSqlName("ZS4")
       cSql += "   SET "
       cSql += "   ZS4_NRET = '" + Alltrim(_Nota)     + "',"
       cSql += "   ZS4_SRET = '" + Alltrim(_Serie)    + "',"
       cSql += "   ZS4_STAT = '" + Alltrim("5")       + "',"
       cSql += "   ZS4_DLIB = '" + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "', "
       cSql += "   ZS4_HRET = '" + Alltrim(Time())    + "',"
       cSql += "   ZS4_URET = '" + Alltrim(__cUserID) + "'"
       cSql += " WHERE ZS4_NRMA = '" + aMaterial[nContar,2] + "'"
       cSql += "   AND ZS4_ANO  = '" + aMaterial[nContar,3] + "'"
       //cSql += "   AND ZS4_ITEM = '" + aMaterial[nContar,6] + "'"
       cSql += "   AND ZS4_PROD = '" + aMaterial[nContar,7] + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
          Return(.T.)
       Endif
       
   Next nContar    

   oDlgRMA:End()

Return(.T.)

// ###########################################
// Função que calcula o custo para OpenCart ##
// ###########################################
Static Function GeraOpenCart(_Nota, _Serie, _Forne, _Loja)

   Local csql   := ""
   Local cTexto := ""
   Local cEmail := ""

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT A.D1_FILIAL ,"
   cSql += "       A.D1_DOC    ,"
   cSql += "       A.D1_SERIE  ,"
   cSql += "       A.D1_FORNECE,"
   cSql += "       A.D1_LOJA   ,"
   cSql += "       A.D1_COD    ,"
   cSql += "       A.D1_ITEM    "
   cSql += "  FROM " + RetSqlName("SD1") + " A "
   cSql += " WHERE A.D1_DOC     = '" + Alltrim(_Nota)  + "'"
   cSql += "   AND A.D1_SERIE   = '" + Alltrim(_serie) + "'"
   cSql += "   AND A.D1_FORNECE = '" + Alltrim(_Forne) + "'"
   cSql += "   AND A.D1_LOJA    = '" + Alltrim(_Loja)  + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If T_NOTA->( EOF() )
      Return .T.
   Endif
   
   T_NOTA->( DbGoTop() )

   WHILE !T_NOTA->( EOF() )
   
   	  dbSelectArea("SD1")
	  dbSetOrder(1)
	  If dbSeek( T_NOTA->D1_FILIAL + T_NOTA->D1_DOC + T_NOTA->D1_SERIE + T_NOTA->D1_FORNECE + T_NOTA->D1_LOJA + T_NOTA->D1_COD + T_NOTA->D1_ITEM)
         RecLock("SD1",.F.)
         SD1->D1_OPEN := "1"
         MsUnLock()              
      Endif   
      
      T_NOTA->( DbSkip() )
      
   ENDDO
   
Return(.T.)

// #####################################################################################
// Função que gera o cálculo do SalesMachine para os produtos do documento de entrada ##
// #####################################################################################
Static Function CalcSalesMachine(xNota, xSerie, xForne, xLoja)

   MsgRun("Aguarde! Calculando S a l e s M a c h i n e ...", "SalesMachine",{|| xCalcSalesMachine(xNota, xSerie, xForne, xLoja) })

Return(.T.)

// #####################################################################################
// Função que gera o cálculo do SalesMachine para os produtos do documento de entrada ##
// #####################################################################################
Static Function xCalcSalesMachine(xNota, xSerie, xForne, xLoja)

   Local csql   := ""
   Local cTexto := ""
   Local cEmail := ""

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT A.D1_FILIAL ,"
   cSql += "       A.D1_DOC    ,"
   cSql += "       A.D1_SERIE  ,"
   cSql += "       A.D1_FORNECE,"
   cSql += "       A.D1_LOJA   ,"
   cSql += "       A.D1_COD    ,"
   cSql += "       A.D1_ITEM   ,"
   cSql += "       B.B1_GRUPO   "
   cSql += "  FROM " + RetSqlName("SD1") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.D1_DOC     = '" + Alltrim(xNota)  + "'"
   cSql += "   AND A.D1_SERIE   = '" + Alltrim(xserie) + "'"
   cSql += "   AND A.D1_FORNECE = '" + Alltrim(xForne) + "'"
   cSql += "   AND A.D1_LOJA    = '" + Alltrim(xLoja)  + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND B.B1_COD     = A.D1_COD"
   cSql += "   AND B.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If T_NOTA->( EOF() )
      Return .T.
   Endif
   
   T_NOTA->( DbGoTop() )

   WHILE !T_NOTA->( EOF() )
   
      If (T_NOTA->B1_GRUPO >= "0100" .AND. T_NOTA->B1_GRUPO <= "0399") .OR. (T_NOTA->B1_GRUPO == "0500")
         U_AUTOM525(T_NOTA->D1_COD, 0, "", 1)
      Endif
      
      T_NOTA->( DbSkip() )
      
   ENDDO
   
Return(.T.)

// ################################################################################################################################
// Função que envia ao FresDesk o fechamento do ticket em caso de retorno de nota fiscal de devolução de remessa de demonstração ##
// ################################################################################################################################
Static Function FechTctDemo(_Nota, _Serie, _Forne, _Loja)

   Local csql    := ""
   Local kTicket := ""
   Local cEmail  := ""

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf
      
   cSql := "SELECT A.D1_FILIAL ,"
   cSql += "       A.D1_TES    ,"
   cSql += "       A.D1_COD    ,"
   cSql += "       A.D1_QUANT  ,"
   cSql += "       A.D1_FORNECE,"
   cSql += "       A.D1_LOJA   ,"
   cSql += "       A.D1_DOC    ,"
   cSql += "       A.D1_SERIE  ,"
   cSql += "       A.D1_NFORI  ,"
   cSql += "       A.D1_SERIORI,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       C.A1_NOME   ,"
   cSql += "       D.F2_VEND1  ,"
   cSql += "       D.F2_ZTICK  ,"
   cSql += "       D.F2_CLIENTE,"
   cSql += "       D.F2_LOJA   ,"
   cSql += "       E.A3_NOME   ,"
   cSql += "       E.A3_EMAIL  ,"
   cSql += "	  (SELECT TOP(1) D2_PEDIDO 
   cSql	+= "        FROM SD2010
   cSql	+= "       WHERE D2_FILIAL  = A.D1_FILIAL  "
   cSql += "	     AND D2_DOC     = A.D1_NFORI   "
   cSql	+= "	     AND D2_SERIE   = A.D1_SERIORI "
   cSql	+= "	     AND D_E_L_E_T_ = '') AS PEDIDO"
   cSql += "  FROM " + RetSqlName("SD1") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B, " 
   cSql += "       " + RetSqlName("SA1") + " C, "
   cSql += "       " + RetSqlName("SF2") + " D, "
   cSql += "       " + RetSqlName("SA3") + " E  "
   cSql += " WHERE A.D1_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND A.D1_DOC     = '" + Alltrim(_Nota)   + "'"
   cSql += "   AND A.D1_SERIE   = '" + Alltrim(_serie)  + "'"
   cSql += "   AND A.D1_FORNECE = '" + Alltrim(_Forne)  + "'"
   cSql += "   AND A.D1_LOJA    = '" + Alltrim(_Loja)   + "'"
   cSql += "   AND A.D1_TES    IN ('235', '236', '238', '239', '267')"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.D1_COD     = B.B1_COD"
   cSql += "   AND A.D1_FORNECE = C.A1_COD"    
   cSql += "   AND A.D1_LOJA    = C.A1_LOJA"   
   cSql += "   AND D.F2_DOC     = A.D1_NFORI"  
   cSql += "   AND D.F2_SERIE   = A.D1_SERIORI"
   cSql += "   AND D.F2_FILIAL  = A.D1_FILIAL" 
   cSql += "   AND D.D_E_L_E_T_ = ''"
   cSql += "   AND D.F2_VEND1   = E.A3_COD"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If T_NOTA->( EOF() )
      Return .T.
   Endif
   
   If Empty(Alltrim(T_NOTA->A3_EMAIL))
      Return .T.
   Endif

   // #########################################
   // Captura o nº do ticket a ser encerrado ##
   // #########################################
   kTicket := ""

   T_NOTA->( DbGoTop() )
   
   WHILE !T_NOTA->( EOF() )
   
      If !Empty(Alltrim(T_NOTA->F2_ZTICK))
         kTicket := Alltrim(T_NOTA->F2_ZTICK)
         Exit
      Endif
      
      T_NOTA->( DbSkip() )
      
   ENDDO
   
   If Empty(Alltrim(kTicket))
      Return(.T.)
   Else
      U_AUTOM595( "F", T_NOTA->PEDIDO, T_NOTA->D1_FILIAL, T_NOTA->D1_NFORI, T_NOTA->D1_SERIORI, T_NOTA->F2_CLIENTE, T_NOTA->F2_LOJA, T_NOTA->F2_ZTICK)      
   Endif
    
Return(.T.)