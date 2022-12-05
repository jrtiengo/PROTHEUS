#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM513.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 04/11/2016                                                               ##
// Objetivo..: Kardex Requisição de Peças - Assistência Técnica                         ##
// Parâmetros: Sem Parâmetros                                                           ##
// Retorno...: Sem retorno - Somente Consulta                                           ##
// #######################################################################################

User Function AUTOM513()

   MsgRun("Aguarde! Abrindo Kardez Requisição de Peças ...", "Programa: AUTOM513",{|| xAUTOM513() })

Return(.T.)

Static Function xAUTOM513()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local oMemo1
      
   Private aFilialPesq := U_AUTOM539(2, cEmpAnt)
   Private cInicial    := Ctod("  /  /    ")
   Private cFinal	   := Ctod("  /  /    ")
   Private cProduto	   := Space(30)
   Private cDescricao  := Space(60)

   Private cComboBx1
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private aBrowse  := {}

   // ######################
   // Declara as Legendas ##
   // ######################
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

   DEFINE MSDIALOG oDlg TITLE "Kardex Requisição de Peças" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(030) PIXEL NOBORDER OF oDlg
   @ C(212),C(005) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(080) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(040),C(005) Say "Filial"                        Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(082) Say "Data Inicial"                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(125) Say "Data Final"                    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(167) Say "Produtos"                      Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(005) Say "Kardex do Produto Selecionado" Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(018) Say "Requisições Abertas"           Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(093) Say "Requisições Encerradas"        Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(048),C(005) ComboBox cComboBx1 Items aFilialPesq Size C(072),C(010) PIXEL OF oDlg
   @ C(048),C(082) MsGet    oGet1     Var   cInicial    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(048),C(125) MsGet    oGet2     Var   cFinal      Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(048),C(167) MsGet    oGet3     Var   cProduto    Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( KardexProduto() )
   @ C(048),C(205) MsGet    oGet4     Var   cDescricao  Size C(248),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(047),C(460) Button "Kardex"        Size C(037),C(012) PIXEL OF oDlg ACTION( KardexRequisicao() )
   @ C(210),C(380) Button "Excel"         Size C(037),C(012) PIXEL OF oDlg ACTION( kExcel() )
   @ C(210),C(420) Button "Saldo Produto" Size C(037),C(012) PIXEL OF oDlg ACTION( kSaldoProd(cProduto) )
   @ C(210),C(460) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 090 , 005, 633, 175,,{'St'                        ,; // 01
                                                    'Nº OS'                     ,; // 02
                                                    'Emissão'                   ,; // 03
                                                    'Técnico'                   ,; // 04
                                                    'Nº Documento'              ,; // 05
                                                    'Usuário'                   ,; // 06
                                                    'Armazém'                   ,; // 07
                                                    'Nº Série'                  ,; // 08
                                                    'Quantidade'                ,; // 09
                                                    'Ped.Venda'                 ,; // 10
                                                    'N.Fiscal'                  ,; // 11
                                                    'Série'                     ,; // 12
                                                    'Ocorrência'                ,; // 13
                                                    'Descrição da Ocorrência' } ,; // 14
                                                    {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
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
                          aBrowse[oBrowse:nAt,08]               ,;                         
                          aBrowse[oBrowse:nAt,09]               ,;                         
                          aBrowse[oBrowse:nAt,10]               ,;                                                   
                          aBrowse[oBrowse:nAt,11]               ,;                                                   
                          aBrowse[oBrowse:nAt,12]               ,;                                                                             
                          aBrowse[oBrowse:nAt,13]               ,;                                                                             
                          aBrowse[oBrowse:nAt,14]               }}
      
   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################
// Função que abre a tela do F4 - Consulta de Saldos ##
// ####################################################
Static Function kSaldoProd(cProduto)

   If Empty(Alltrim(cProduto))
      MsgAlert("Produto não informado. Pesquisa não será realizada.")
      Return(.T.)
   Endif

   aArea := GetArea()

   // Posiciona no produto a ser pesquisado o seu saldo
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1") + cProduto)

   MaViewSB2(cProduto)

   RestArea( aArea )

Return .T.

// ########################################################
// Função que pesquisa a descição do produto selecionado ##
// ########################################################
Static Function KardexProduto()

   If Empty(Alltrim(cProduto))
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet3:refresh()
      oGet4:Refresh()
      Return(.T.)
   Endif
   
   cDescricao := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC" )) + " " + ;
                 Alltrim(Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DAUX" ))

   oGet4:Refresh()

Return(.T.)

// ########################################################################################################
// Função que realiza a pesquisa do kardex de requisição do produto informado para o armazém selecionado ##
// ########################################################################################################
Static Function KardexRequisicao()

   MsgRun("Favor Aguarde! Pesquisando dados ...", "Pesquisando dados ...",{|| xKardexRequisicao() })

Return(.T.)

// ########################################################################################################
// Função que realiza a pesquisa do kardex de requisição do produto informado para o armazém selecionado ##
// ########################################################################################################
Static Function xKardexRequisicao()

   Local cSql          := ""
   Local nSaldoInicial := 0

   // #########################################
   // Consistências das variáeis de pesquisa ##
   // #########################################
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Necessário selecionar a filial a ser pesquisada.")
      Return(.T.)
   Endif
   
   If Empty(cInicial)
      MsgAlert("Necessário informar data inicial para pesquisa.")
      Return(.T.)
   Endif
   
   If Empty(cFinal)
      MsgAlert("Necessário informar data final para pesquisa.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cProduto))
      MsgAlert("Necessário informar código do produto para pesquisa.")
      Return(.T.)
   Endif

   // ##############################################################   
   // Pesquisa as movimentações para o período/produto informados ##
   // ##############################################################    
   aBrowse  := {}

   // ##############################################################   
   // Pesquisa as movimentações para o período/produto informados ##
   // ##############################################################    
   If Select("T_REQUISICAO") > 0
      T_REQUISICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZZ.ZZZ_FILIAL,"
   cSql += "       ZZZ.ZZZ_NUMOS ,"
   cSql += "	   ZZZ.ZZZ_TECNIC,"
   cSql += "       AA1.AA1_NOMTEC,"
   cSql += "	   SUBSTRING(ZZZ.ZZZ_EMISSA,07,02) + '/' + SUBSTRING(ZZZ.ZZZ_EMISSA,05,02) + '/' + SUBSTRING(ZZZ.ZZZ_EMISSA,01,04) AS EMISSAO,"
   cSql += "	   ZZZ.ZZZ_PRODUT,"
   cSql += "	   ZZZ.ZZZ_LOCAL ,"
   cSql += "	   ZZZ.ZZZ_NUMSER,"
   cSql += "	   ZZZ.ZZZ_QUANT ,"
   cSql += "	   ZZZ.ZZZ_SALDO ,"
   cSql += "	   ZZZ.ZZZ_DOCSD3,"
   cSql += "	   ZZZ.ZZZ_STATUS,"
   cSql += "       ZZZ.ZZZ_NUMPV ,"
   cSql += "       ZZZ.ZZZ_NOTA  ,"
   cSql += "       ZZZ.ZZZ_SERIE ,"
   cSql += "  	   AB7.AB7_CODPRB,"
   cSql += "	   AAG.AAG_DESCRI "
   cSql += "  FROM " + RetSqlName("ZZZ") + " ZZZ, "
   cSql += "       " + RetSqlName("AA1") + " AA1, "
   cSql += "	   " + RetSqlName("AB7") + " AB7, "
   cSql += "	   " + RetSqlName("AAG") + " AAG  "
   cSql += " WHERE ZZZ.ZZZ_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND ZZZ.ZZZ_PRODUT  = '" + Alltrim(cProduto)       + "'"
   cSql += "   AND ZZZ.ZZZ_EMISSA >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"
   cSql += "   AND ZZZ.ZZZ_EMISSA <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"
   cSql += "   AND ZZZ.D_E_L_E_T_  = ''"
   cSql += "   AND AA1.AA1_CODTEC  = ZZZ.ZZZ_TECNIC"
   cSql += "   AND AA1.D_E_L_E_T_  = ''"
   cSql += "   AND AB7.AB7_FILIAL  = ZZZ.ZZZ_FILIAL"
   cSql += "   AND AB7.AB7_NUMOS   = ZZZ.ZZZ_NUMOS "
   cSql += "   AND AB7.D_E_L_E_T_  = ''            "
   cSql += "   AND AAG.AAG_CODPRB  = AB7.AB7_CODPRB"
   cSql += "   AND AAG.D_E_L_E_T_  = ''            "
   cSql += " ORDER BY ZZZ.ZZZ_FILIAL, ZZZ.ZZZ_EMISSA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REQUISICAO", .T., .T. )

   // ##################################################
   // Carrega as movimentações para o armazém/produto ##
   // ##################################################
   T_REQUISICAO->( DbGoTop() )

   WHILE !T_REQUISICAO->( EOF() )

      If Empty(Alltrim(T_REQUISICAO->ZZZ_DOCSD3))
    
         aAdd( aBrowse, { IIF(T_REQUISICAO->ZZZ_STATUS == "A", "9", "1") ,;
                              T_REQUISICAO->ZZZ_NUMOS  ,;
                              T_REQUISICAO->EMISSAO    ,;
                              T_REQUISICAO->AA1_NOMTEC ,;
                              T_REQUISICAO->ZZZ_DOCSD3 ,;
                              ""                       ,;
                              T_REQUISICAO->ZZZ_LOCAL  ,;
                              T_REQUISICAO->ZZZ_NUMSER ,;
                              Transform(T_REQUISICAO->ZZZ_QUANT, "@E 9999999999") ,;
                              T_REQUISICAO->ZZZ_NUMPV  ,;
                              T_REQUISICAO->ZZZ_NOTA   ,;                                                            
                              T_REQUISICAO->ZZZ_SERIE  ,;
                              T_REQUISICAO->AB7_CODPRB ,;
                              T_REQUISICAO->AAG_DESCRI })

        // ########################
        // Abre a linha do Saldo ##
        // ########################
        aAdd( aBrowse, { "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;                         
                         "" })

      Else
      
         // #########################
         // Abre o registro da ZZZ ##
         // #########################
         aAdd( aBrowse, { IIF(T_REQUISICAO->ZZZ_STATUS == "A", "9", "1") ,;
                              T_REQUISICAO->ZZZ_NUMOS  ,;
                              T_REQUISICAO->EMISSAO    ,;
                              T_REQUISICAO->AA1_NOMTEC ,;
                              T_REQUISICAO->ZZZ_DOCSD3 ,;
                              ""                       ,;
                              T_REQUISICAO->ZZZ_LOCAL  ,;
                              T_REQUISICAO->ZZZ_NUMSER ,;
                              Transform(T_REQUISICAO->ZZZ_QUANT, "@E 9999999999") ,;
                              T_REQUISICAO->ZZZ_NUMPV ,;
                              T_REQUISICAO->ZZZ_NOTA  ,;
                              T_REQUISICAO->ZZZ_SERIE ,;
                              T_REQUISICAO->AB7_CODPRB ,;
                              T_REQUISICAO->AAG_DESCRI })

         // ###########################################
         // Pesquisa o segundo armazém do lançamento ##
         // ###########################################
         If Select("T_LOCAL02") > 0
            T_LOCAL02->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql += "SELECT SUBSTRING(D3_EMISSAO,07,02) + '/' + SUBSTRING(D3_EMISSAO,05,02) + '/' + SUBSTRING(D3_EMISSAO,01,04) AS EMISSAO,"
         cSql += "       D3_USUARIO,"
         cSql += "       D3_LOCAL  ,"
         cSql += "       D3_QUANT   "
         cSql += "  FROM " + RetSqlName("SD3") 
         cSql += " WHERE D3_FILIAL  = '" + Alltrim(T_REQUISICAO->ZZZ_FILIAL) + "'"
         cSql += "   AND D3_COD     = '" + Alltrim(T_REQUISICAO->ZZZ_PRODUT) + "'"
         cSql += "   AND D3_TM      = '499'"
         cSql += "   AND D3_CF      = 'DE4'"
         cSql += "   AND D3_DOC     = '" + Alltrim(T_REQUISICAO->ZZZ_DOCSD3) + "'"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOCAL02", .T., .T. )

         // ##########################
         // Carrega o array aBrowse ##
         // ##########################
         aAdd( aBrowse, { ""                                     ,;
                          ""                                     ,;
                          T_LOCAL02->EMISSAO                     ,;
                          T_REQUISICAO->AA1_NOMTEC               ,;
                          T_REQUISICAO->ZZZ_DOCSD3               ,;
                          Alltrim(Upper(T_LOCAL02->D3_USUARIO))  ,;
                          T_LOCAL02->D3_LOCAL                    ,;
                          ""                                     ,;
                          Transform(T_LOCAL02->D3_QUANT,"@E 9999999999") ,;
                          "",;
                          "",;
                          "",;
                          "",;
                          "" })

        // ########################
        // Abre a linha do Saldo ##
        // ########################
        aAdd( aBrowse, { "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;                                                  
                         "" ,;                                                  
                         "" ,;                                                                           
                         "" })
      Endif                         

      T_REQUISICAO->( DbSkip() )
      
   ENDDO                           

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
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
                          aBrowse[oBrowse:nAt,08]               ,;                         
                          aBrowse[oBrowse:nAt,09]               ,;                         
                          aBrowse[oBrowse:nAt,10]               ,;                         
                          aBrowse[oBrowse:nAt,11]               ,;                                                   
                          aBrowse[oBrowse:nAt,12]               ,;                                                   
                          aBrowse[oBrowse:nAt,13]               ,;                                                   
                          aBrowse[oBrowse:nAt,14]               }}                         
                          

Return(.T.)

// ###################################################
// Função que gera em excel o resultado da pesquisa ##
// ###################################################
Static Function kExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   aAdd( aCabExcel, { "St"                     ,  "C",  01, 00 }) 
   aAdd( aCabExcel, { "Nº OS"                  ,  "C",  06, 00 }) 
   aAdd( aCabExcel, { "Emissão"                ,  "C",  10, 00 }) 
   aAdd( aCabExcel, { "Técnico"                ,  "C",  40, 00 }) 
   aAdd( aCabExcel, { "Nº Documento"           ,  "C",  09, 00 }) 
   aAdd( aCabExcel, { "Usuário"                ,  "C",  20, 00 }) 
   aAdd( aCabExcel, { "Armazém"                ,  "C",  02, 00 }) 
   aAdd( aCabExcel, { "Nº Série"               ,  "C",  20, 00 }) 
   aAdd( aCabExcel, { "Quantidade"             ,  "N",  10, 00 }) 
   aAdd( aCabExcel, { "Ped.Venda"              ,  "C",  06, 00 }) 
   aAdd( aCabExcel, { "N.Fiscal"               ,  "C",  09, 00 }) 
   aAdd( aCabExcel, { "Série"                  ,  "C",  20, 00 }) 
   aAdd( aCabExcel, { "Ocorrência"             ,  "C",  06, 00 }) 
   aAdd( aCabExcel, { "Descrição da Ocorrência",  "C",  40, 00 }) 

   cTitulo := ""
   cTitulo := "Empresa: "        + cEmpAnt            + " " + ;
              "Filial: "         + Alltrim(cComboBx1) + " " + ;
              "Data Inicial: "   + Dtoc(cInicial)     + " " + ;
              "Data Final: "     + Dtoc(cFinal)       + " " + ;
              "Produto: "        + Alltrim(cProduto)  + " - " + Alltrim(cDescricao)

   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando Resumo para Excel", {||DlgToExcel({{"GETDADOS",cTitulo, aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function kkSaidaExcel(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aBrowse)

       aAdd( aCols, {IIF(aBrowse[nContar,01] == "9", "ABERTA", "ENCERRADA") ,;
           			     aBrowse[nContar,02],;
           			     aBrowse[nContar,03],;
           			     aBrowse[nContar,04],;          					             					   
         	             aBrowse[nContar,05],;
         	             aBrowse[nContar,06],;
         	             aBrowse[nContar,07],;
         	             aBrowse[nContar,08],;
         	             aBrowse[nContar,09],;
         	             aBrowse[nContar,10],;
         	             aBrowse[nContar,11],;
         	             aBrowse[nContar,12],;
         	             aBrowse[nContar,13],;
         	             aBrowse[nContar,14],;
                         ""                })

   Next nContar

Return(.T.)