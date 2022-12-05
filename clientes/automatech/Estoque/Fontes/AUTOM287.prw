#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM287.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/04/2015                                                          *
// Objetivo..: Programa de Importação de XML - Pré-Documento de Entrada            *
//**********************************************************************************

User Function AUTOM287()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private kDataIni := Ctod("01/01/" + Strzero(Year(Date()),4))
   Private kDataFim := Ctod("31/12/" + Strzero(Year(Date()),4))
   Private kFornece := Space(06)
   Private kLoja 	:= Space(03)
   Private kNomeFor := Space(60)
   Private kChave   := Space(25)
   Private kNota	:= Space(09)
   Private kSerie   := Space(03)
   Private aStatus  := {"0 - Todos os Status", "E - Documento Encerrado", "A - Aguardando Controladoria", "I - Documento com Inconsistência"}

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private cStatus

   Private oDlgK

   Private aDocumento := {}

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

   U_AUTOM628("AUTOM287")

   // Envia para o método que carrega o Grid aDocumento
   CargaaDocu(1)

   // Desenha a tela
   DEFINE MSDIALOG oDlgK TITLE "Pré-Lançamento Documento Entrada" FROM C(178),C(181) TO C(631),C(936) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgK
   @ C(193),C(005) Jpeg FILE "br_azul"        Size C(009),C(009) PIXEL NOBORDER OF oDlgK
   @ C(193),C(064) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlgK
   @ C(193),C(237) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlgK

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(369),C(001) PIXEL OF oDlgK
   @ C(205),C(005) GET oMemo2 Var cMemo2 MEMO Size C(369),C(001) PIXEL OF oDlgK
      
   @ C(023),C(310) Say "PRÉ-DOCUMENTO DE ENTRADA"                                     Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(037),C(005) Say "Dta Emissão Inicial"                                          Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(037),C(056) Say "Dta Emissão Final"                                            Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(037),C(108) Say "Fornecedor"                                                   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(059),C(005) Say "Chave Acesso"                                                 Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(059),C(164) Say "Nota Fiscal"                                                  Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(059),C(206) Say "Série"                                                        Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(059),C(228) Say "Status"                                                       Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(080),C(005) Say "Relação de Pré-Documentos de Entrada"                         Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(194),C(018) Say "Documento OK"                                                 Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(194),C(077) Say "Documento Importado OK - Aguardando Análise da Controladoria" Size C(157),C(008) COLOR CLR_BLACK PIXEL OF oDlgK
   @ C(194),C(251) Say "Documento com Inconsistência"                                 Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgK

   @ C(047),C(005) MsGet    oGet1   Var   kDataIni  Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(047),C(056) MsGet    oGet2   Var   kDataFim  Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(047),C(108) MsGet    oGet3   Var   kFornece  Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(047),C(139) MsGet    oGet4   Var   kLoja     Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(047),C(164) MsGet    oGet5   Var   kNomeFor  Size C(209),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK When lChumba
   @ C(067),C(005) MsGet    oGet6   Var   kChave    Size C(155),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(067),C(164) MsGet    oGet7   Var   kNota     Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(067),C(206) MsGet    oGet8   Var   kSerie    Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgK
   @ C(067),C(228) ComboBox cStatus Items aStatus   Size C(103),C(010)                              PIXEL OF oDlgK

   @ C(064),C(335) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlgK ACTION( CargaaDocu(2) )

   @ C(211),C(005) Button "Importar XML"             Size C(046),C(012) PIXEL OF oDlgK ACTION( ChmImpXML("I", "", "", "", "", "" ) )
   @ C(211),C(052) Button "Alterar Doc."             Size C(046),C(012) PIXEL OF oDlgK ACTION( ChmImpXML("A", aDocumento[oDocumento:nAt,02], aDocumento[oDocumento:nAt,03], aDocumento[oDocumento:nAt,05], aDocumento[oDocumento:nAt,06], aDocumento[oDocumento:nAt,01]) )
   @ C(211),C(100) Button "Visualizar Doc."          Size C(046),C(012) PIXEL OF oDlgK ACTION( ChmImpXML("V", aDocumento[oDocumento:nAt,02], aDocumento[oDocumento:nAt,03], aDocumento[oDocumento:nAt,05], aDocumento[oDocumento:nAt,06], aDocumento[oDocumento:nAt,01]) )
   @ C(211),C(147) Button "Excluir Doc."             Size C(046),C(012) PIXEL OF oDlgK ACTION( ChmImpXML("E", aDocumento[oDocumento:nAt,02], aDocumento[oDocumento:nAt,03], aDocumento[oDocumento:nAt,05], aDocumento[oDocumento:nAt,06], aDocumento[oDocumento:nAt,01]) )
// @ C(211),C(203) Button "Controladoria - Alterar"  Size C(063),C(012) PIXEL OF oDlgK ACTION( ChmImpXML("C", aDocumento[oDocumento:nAt,02], aDocumento[oDocumento:nAt,03], aDocumento[oDocumento:nAt,05], aDocumento[oDocumento:nAt,06], aDocumento[oDocumento:nAt,01]) )
   @ C(211),C(235) Button "Controladoria"            Size C(063),C(012) PIXEL OF oDlgK ACTION( ChmImpXML("X", aDocumento[oDocumento:nAt,02], aDocumento[oDocumento:nAt,03], aDocumento[oDocumento:nAt,05], aDocumento[oDocumento:nAt,06], aDocumento[oDocumento:nAt,01]) )
   @ C(211),C(335) Button "Voltar"                   Size C(037),C(012) PIXEL OF oDlgK ACTION( oDlgK:End() )

   // Define o browse para visualização
   oDocumento := TCBrowse():New( 115 , 005, 473, 127,,{''                           ,; // 01 - Legenda
                                                       'N.Fiscal'                   ,; // 02 - Nº da Nota Fiscal
                                                       'Série'                      ,; // 03 - Série da Nota Fiscal
                                                       'Emissão'                    ,; // 04 - Data de Emissão
                                                       'Fornecedor'                 ,; // 05 - Código do Fornecedor
                                                       'Loja'                       ,; // 06 - Loja do Fornecedor
                                                       'Descrição dos Fornecedores' ,; // 07 - Descrição dos Fornecedores
                                                       'Chave Acesso'              },; // 08 - Chave de Acesso a DANFE
                                                       {20,50,50,50},oDlgK,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   If Len(aDocumento) == 0
      aAdd( aDocumento, { "1", "", "", "", "", "", "", "" } )
   Endif   

   // Seta vetor para a browse                            
   oDocumento:SetArray(aDocumento) 
    
   // Monta a linha a ser exibina no Browse
   oDocumento:bLine := {||{ If(Alltrim(aDocumento[oDocumento:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aDocumento[oDocumento:nAt,02]               ,;
                            aDocumento[oDocumento:nAt,03]               ,;
                            aDocumento[oDocumento:nAt,04]               ,;                         
                            aDocumento[oDocumento:nAt,05]               ,;                         
                            aDocumento[oDocumento:nAt,06]               ,;                         
                            aDocumento[oDocumento:nAt,07]               ,;                         
                            aDocumento[oDocumento:nAt,08]               }}

   ACTIVATE MSDIALOG oDlgK CENTERED 

Return(.T.)

// Função que chama o programa de importação de XML
Static Function ChmImpXML(xOperacao, xNota, xSerie, xFornecedor, xLoja, xStatus)

   // Verifica Alteraçao de XML
   If xOperacao == "A"
      If xStatus == "5"
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Alteração não permitida para documentos já validados.")
         Return(.T.)
      Endif
   Endif

   // Verifica Exclusão de XML
   If xOperacao == "E"
      If xStatus == "5"
         MsgAlert("Atenção!" + chr(13) + chr(13) + "Exclusão não permitida para documentos já validados.")
         Return(.T.)
      Endif
   Endif

   // Chama o programa de importação do XML
   If xOperacao == "P" .Or. xOperacao == "I" .Or. xOperacao == "A" .Or. xOperacao == "V" .Or. xOperacao == "E" .Or. xOperacao == "C"
      If xOperacao == "C"
         U_AUTOM108("P", xOperacao, xNota, xSerie, xFornecedor, xLoja, "X" )
      Else
         U_AUTOM108("P", xOperacao, xNota, xSerie, xFornecedor, xLoja, " " )
      Endif
   Else
      U_AUTOM108("X", xOperacao, xNota, xSerie, xFornecedor, xLoja, " " )      
   Endif
   
   // Carrega os dados do grid
   CargaaDocu(2)

Return(.T.)

// Função que carrega o grid de documentos
Static Function CargaaDocu(__Porta)

   Local cSql := ""
   
   aDocumento := {}

   If __Porta == 1
   Else
      If Empty(kDataIni)
         MsgAlert("Data inicial para pesquisa não informada.")
      Endif
         
      If Empty(kDataFim)
         MsgAlert("Data final para pesquisa não informada.")
      Endif
   Endif

   // Pesquisa os dados conforme parÇametros
   If Select("T_DOCUMENTO") <>  0
      T_DOCUMENTO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT A.ZT8_FILIAL,"
   cSql += "       A.ZT8_ARQU  ,"
   cSql += "       A.ZT8_NOTA  ,"
   cSql += "       A.ZT8_SERI  ,"
   cSql += "       A.ZT8_EMIS  ,"
   cSql += "       A.ZT8_ESTA  ,"
   cSql += "       A.ZT8_ESPE  ,"
   cSql += "       A.ZT8_FORN  ,"
   cSql += "       A.ZT8_LOJA  ,"
   cSql += "       B.A2_NOME   ,"
   cSql += "       A.ZT8_USUA  ,"
   cSql += "       A.ZT8_DATA  ,"
   cSql += "       A.ZT8_HORA  ,"
   cSql += "       A.ZT8_BICM  ,"
   cSql += "       A.ZT8_VICM  ,"
   cSql += "       A.ZT8_BIST  ,"
   cSql += "       A.ZT8_VIST  ,"
   cSql += "       A.ZT8_VIPI  ,"
   cSql += "       A.ZT8_VPRO  ,"
   cSql += "       A.ZT8_FRET  ,"
   cSql += "       A.ZT8_SEGU  ,"
   cSql += "       A.ZT8_DESC  ,"
   cSql += "       A.ZT8_DESP  ,"
   cSql += "       A.ZT8_CHAV  ,"
   cSql += "       A.ZT8_STAT   "
   cSql += "     FROM " + RetSqlName("ZT8") + " A, "
   cSql += "          " + RetSqlName("SA2") + " B  "
   cSql += "    WHERE A.D_E_L_E_T_ = ''"
   cSql += "      AND A.ZT8_EMIS  >= CONVERT(DATETIME,'" + Dtoc(kDataIni) + "', 103)"
   cSql += "      AND A.ZT8_EMIS  <= CONVERT(DATETIME,'" + Dtoc(kDataFim) + "', 103)"
   cSql += "      AND A.ZT8_FORN   = B.A2_COD  "
   cSql += "      AND A.ZT8_LOJA   = B.A2_LOJA "

   // Filtra quando a tela já está aberta
   If __Porta == 2
      
      // Filtra pelo fornecedor informado
      If !Empty(Alltrim(kFornece))
         cSql += " AND A.ZT8_FORNE = '" + Alltrim(kFornece) + "'"
         cSql += " AND A.ZT8_LOJA  = '" + Alltrim(kLoja)    + "'"
      Endif
      
      // Filtra pela chave do documento de entrada
      If !Empty(Alltrim(kChave))   
         cSql += " AND A.ZT8_CHAV = '" + Alltrim(kChave) + "'"
      Endif
   
      // Filtra pela nota fiscal do fornecedor
      If !Empty(Alltrim(kNota))   
         cSql += " AND A.ZT8_NOTA = '" + Alltrim(kNota) + "'"
      Endif
   
      // Filtra pela série da nota fiscal
      If !Empty(Alltrim(kSerie))   
         cSql += " AND A.ZT8_SERI = '" + Alltrim(kSerie) + "'"
      Endif
      
      // Filtra pela série da nota fiscal
      If Substr(cStatus,01,01) == "0"
      Else
         cSql += " AND A.ZT8_STAT = '" + Substr(cStatus,01,01) + "'"
      Endif
   Endif

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DOCUMENTO",.T.,.T.)

   WHILE !T_DOCUMENTO->( EOF() )

      Do Case
         Case T_DOCUMENTO->ZT8_STAT == "A"
              _Status_ := "2"
         Case T_DOCUMENTO->ZT8_STAT == "E"
              _Status_ := "5"
         Case T_DOCUMENTO->ZT8_STAT == "I"
              _Status_ := "8"
      EndCase

      aAdd( aDocumento, { _Status_              ,;
                          T_DOCUMENTO->ZT8_NOTA ,;
                          T_DOCUMENTO->ZT8_SERI ,;
                          Substr(T_DOCUMENTO->ZT8_EMIS,07,02) + "/" + Substr(T_DOCUMENTO->ZT8_EMIS,05,02) + "/" + Substr(T_DOCUMENTO->ZT8_EMIS,01,04) ,;
                          T_DOCUMENTO->ZT8_FORN ,;
                          T_DOCUMENTO->ZT8_LOJA ,;
                          T_DOCUMENTO->A2_NOME  ,;
                          T_DOCUMENTO->ZT8_ARQU })                          
                          
      T_DOCUMENTO->( DbSkip() )
      
   ENDDO
                                
   If __Porta == 1
      Return(.T.)
   Endif

   // Seta vetor para a browse                            
   oDocumento:SetArray(aDocumento) 
    
   // Monta a linha a ser exibina no Browse
   oDocumento:bLine := {||{ If(Alltrim(aDocumento[oDocumento:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aDocumento[oDocumento:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aDocumento[oDocumento:nAt,02]               ,;
                            aDocumento[oDocumento:nAt,03]               ,;
                            aDocumento[oDocumento:nAt,04]               ,;                         
                            aDocumento[oDocumento:nAt,05]               ,;                         
                            aDocumento[oDocumento:nAt,06]               ,;                         
                            aDocumento[oDocumento:nAt,07]               ,;                         
                            aDocumento[oDocumento:nAt,08]               }}

Return(.T.)