#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM347.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/05/2016                                                          *
// Objetivo..: Programa que permite usuários a emitir danfe, nota fiscal de servi- *
//             ço eletrônica e boleto bancário.                                    *
//**********************************************************************************

User Function AUTOM347()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private aFilial	 := U_AUTOM539(2, cEmpAnt)  // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "CC- Curitiba", "AA - Atech"}
   Private cComboBx1
   Private cPedido   := Space(06)
   Private cMensagem := ""

   Private oGet1
   Private oMemo3

   Private oDlgDoc

   U_AUTOM628("AUTOM347")

   DEFINE MSDIALOG oDlgDoc TITLE "Emissão de Documentos" FROM C(178),C(181) TO C(539),C(559) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgDoc

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(180),C(001) PIXEL OF oDlgDoc

   @ C(040),C(005) Say "Este programa permite que você imprima documentos fiscais."           Size C(175),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc
   @ C(050),C(005) Say "Faça o uso deste com cautela já que se trata de documentos oficiais." Size C(165),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc

   @ C(064),C(005) Say "Filial"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc
   @ C(064),C(103) Say "Nº Ped.Venda" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgDoc

   @ C(073),C(005) ComboBox cComboBx1 Items aFilial Size C(094),C(010) PIXEL OF oDlgDoc
   @ C(073),C(103) MsGet    oGet1     Var   cPedido Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDoc
   @ C(070),C(146) Button "Pesquisar"               Size C(037),C(012) PIXEL OF oDlgDoc ACTION( PESQDOCU() )

   @ C(085),C(005) GET oMemo3 Var cMensagem MEMO Size C(179),C(047) PIXEL OF oDlgDoc When lChumba

   @ C(136),C(005) Button "DANFE"           Size C(088),C(020) PIXEL OF oDlgDoc ACTION( STSDANFE() )
   @ C(136),C(094) Button "R P S"           Size C(090),C(020) PIXEL OF oDlgDoc ACTION( GERARPS() )
   @ C(157),C(005) Button "Boleto Bancário" Size C(088),C(020) PIXEL OF oDlgDoc ACTION( BCOBOLETOS() )
   @ C(157),C(094) Button "Voltar"          Size C(090),C(020) PIXEL OF oDlgDoc ACTION( oDlgDOC:End() )
 
   ACTIVATE MSDIALOG oDlgDoc CENTERED 

Return(.T.)

// #######################################
// Função que imprime boletos bancários ##
// #######################################
Static Function BCOBOLETOS()

   // ##########################################################
   // Pesquisa o banco a ser utilizado para emissão do boleto ##
   // ##########################################################
   kTipo_Banco := U_AUTOM575()
      
   If kTipo_Banco == "0"
   Else
      Do Case
         Case kTipo_Banco == "1"
              U_SANTANDER(.F., "", "", "U")
         Case kTipo_Banco == "2"
              U_BOLITAU(.F., "", "", "U")
      EndCase
   Endif

Return(.T.)


/*
User Function AUTOM347()

   Local lChumba     := .F.

   Local cMemo1	     := ""
   Local oMemo1
   
   Private cMensagem := ""

   Private lPedido   := .T.
   Private lNota     := .T.
   
   Private aFilial	 := {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "CC- Curitiba", "AA - Atech"}
   Private cComboBx1

   Private cPedido 	 := Space(06)
   Private cNota	 := Space(09)
   Private cSerie    := Space(03)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oMemo2
 
   Private oDlgDOC

   DEFINE MSDIALOG oDlgDOC TITLE "Emissão de Documentos" FROM C(178),C(181) TO C(581),C(559) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgDOC

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(180),C(001) PIXEL OF oDlgDOC

   @ C(041),C(005) Say "Filial"             Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgDOC
   @ C(065),C(107) Say "Série"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgDOC
   @ C(066),C(005) Say "Nº Pedido de Venda" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgDOC
   @ C(066),C(061) Say "Nº N.Fiscal"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgDOC

   @ C(051),C(005) ComboBox cComboBx1 Items aFilial Size C(179),C(010) PIXEL OF oDlgDOC

   @ C(075),C(005) MsGet    oGet1     Var cPedido Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDOC When lPedido VALID( LimpaCampos(1) )
   @ C(075),C(061) MsGet    oGet2     Var cNota   Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDOC When lNota   VALID( LimpaCampos(2) )
   @ C(075),C(107) MsGet    oGet3     Var cSerie  Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDOC When lNota 

   @ C(072),C(147) Button "Pesquisa" Size C(037),C(012) PIXEL OF oDlgDOC ACTION( PESQDOCU() )

   @ C(090),C(005) GET oMemo2 Var cMensagem MEMO Size C(179),C(042) PIXEL OF oDlgDOC When lChumba

   @ C(134),C(005) Button "DANFE"                             Size C(179),C(015) PIXEL OF oDlgDOC ACTION( STSDANFE() )
   @ C(150),C(005) Button "Nota Fiscal de Serviço Eletrônica" Size C(179),C(015) PIXEL OF oDlgDOC ACTION( GERARPS() )
   @ C(166),C(005) Button "Boleto Bancário"                   Size C(179),C(015) PIXEL OF oDlgDOC ACTION( U_BOLITAU() )
   @ C(182),C(005) Button "Voltar"                            Size C(179),C(015) PIXEL OF oDlgDOC ACTION( oDlgDOC:End() )

   ACTIVATE MSDIALOG oDlgDOC CENTERED 

Return(.T.)

// Função habilita/desabilita os campos
Static Function LimpaCampos(_Campo)

   Do Case

      Case _Campo == 1

           If Empty(Alltrim(cPedido))

              cPedido   := Space(06)
              cMensagem := ""
              oGet1:Refresh()
              oMemo2:Refresh()
              lPedido := .T.
              lNota   := .T.

           Else

              lPedido := .T.
              lNota   := .F.
      
              cNota  := Space(09)
              cSerie := Space(03)

              oGet2:Refresh()
              oGet3:Refresh()

           Endif   
           
      Case _Campo == 2

           If Empty(Alltrim(cNota))

              cPedido := Space(06)
              cNota   := Space(09)
              cSerie  := Space(03)
              cMensagem := ""

              oGet1:Refresh()
              oGet2:Refresh()
              oGet3:Refresh()
              oMemo2:Refresh()

              lPedido := .T.
              lNota   := .T.

           Else

              lPedido := .F.
              lNota   := .T.
      
              cPedido := Space(06)
              oGet1:Refresh()
              
           Endif   
           
   EndCase

Return(.T.)

*/

// Função habilita/desabilita os campos
Static Function PESQDOCU()

   Local cSql := ""

   If Empty(Alltrim(cPedido))
      MsgAlert("Pedido a Ser pesquisado não informado.")
      Return(.T.)
   Endif

   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf
    
   cSql := "" 
   cSql += "SELECT SC6.C6_NUM   ,"       
   cSql += "       SC6.C6_CLI   ,"       
   cSql += "       SC6.C6_LOJA  ,"       
   cSql += "       CASE WHEN SC5.C5_TIPO =  'B' THEN (SELECT A2_NOME FROM SA2010 WHERE A2_COD = SC6.C6_CLI AND A2_LOJA = SC6.C6_LOJA AND D_E_L_E_T_ = '')"
   cSql += "            WHEN SC5.C5_TIPO <> 'B' THEN (SELECT A1_NOME FROM SA1010 WHERE A1_COD = SC6.C6_CLI AND A1_LOJA = SC6.C6_LOJA AND D_E_L_E_T_ = '')"
   cSql += "       END AS CLIENTE,"
   cSql += "	   SC6.C6_NOTA   ,"       
   cSql += "   	   SC6.C6_SERIE  ,"       
   cSql += "	   SC6.C6_DATFAT ,"
   cSql += "	   SC5.C5_TIPO    "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SC5") + " SC5  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"

//   Do Case
//      Case Substr(cComboBx1,01,02) == "01"
//           cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
//      Case Substr(cComboBx1,01,02) == "02"
//           cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
//      Case Substr(cComboBx1,01,02) == "03"
//           cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
//      Case Substr(cComboBx1,01,02) == "04"
//           cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
//      Otherwise              
//           cSql += " WHERE SC6.C6_FILIAL  = '01'"
//   EndCase

   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(cPedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += " GROUP BY SC6.C6_NUM , SC6.C6_CLI , SC6.C6_LOJA, SC6.C6_NOTA, SC6.C6_SERIE, SC6.C6_DATFAT, SC5.C5_TIPO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")
      Return(.T.)
   Endif
      
   cMensagem := ""
   cMensagem := cMensagem + "Pedido Nº "     + Alltrim(T_PEDIDO->C6_NUM)  + CHR(13)
   cMensagem := cMensagem + "Cliente: "      + Alltrim(T_PEDIDO->C6_CLI)  + "." + Alltrim(T_PEDIDO->C6_LOJA) + CHR(13)
   cMensagem := cMensagem + "Nome Cliente: " + Alltrim(T_PEDIDO->CLIENTE) + CHR(13)
   cMensagem := cMensagem + "Nota(s) Fiscal(is): " + chr(13)

   T_PEDIDO->( DbGoTop() )
      
   WHILE !T_PEDIDO->( EOF() )
      cMensagem := cMensagem + Alltrim(T_PEDIDO->C6_NOTA) + "/" + Alltrim(T_PEDIDO->C6_SERIE) + " - " + ;
                   Substr(T_PEDIDO->C6_DATFAT,07,02) + "/"   + ;
                   Substr(T_PEDIDO->C6_DATFAT,05,02) + "/"   + ;
                   Substr(T_PEDIDO->C6_DATFAT,01,04) + chr(13)
      T_PEDIDO->( DbSkip() )
   ENDDO
   
   oMemo3:Refresh()

Return(.T.)      

// Função habilita/desabilita os campos
Static Function STSDANFE()

   Local cFil := cFilAnt

// Private aFilBrw := {"SF2","F2_FILIAL=='" + cFil + "'.And.F2_SERIE=='" + SubStr( cFil, 2 ) +"'"}
  
   Private aFilBrw := {"SF2","F2_FILIAL=='" + cFil + "'.And.F2_SERIE=='" + SubStr( cFil, 2 ) +"'"}
   
//   Do Case
//      Case Substr(cComboBx1,01,02) == "01"
//           cFil := "01"
//      Case Substr(cComboBx1,01,02) == "02"
//           cFil := "02"
//      Case Substr(cComboBx1,01,02) == "03"
//           cFil := "03"
//      Case Substr(cComboBx1,01,02) == "04"
//           cFil := "04"
//      Otherwise              
//           cFil := "01"
//   EndCase

   // Chama a função de impressão da DANFE
   SPEDDANFE()
   
Return(.T.)

// Função gera o RPS
Static Function GERARPS()

   U_AMATR968()
   
Return(.T.)   
