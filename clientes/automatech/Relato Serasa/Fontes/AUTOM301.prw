#INCLUDE "PROTHEUS.CH"
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
// Referencia: AUTOM301.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/07/2015                                                          *
// Objetivo..: Programa de Manutenção do Layout de Retorno do Proeduto RELATO.     *
//**********************************************************************************

User Function AUTOM301()
                      
   Local cSql      := ""
   Local cMemo1	   := ""
   Local oMemo1

   Private aLayout := {}

   Private oDlg
   
   // Carrega o grid com os dados dos Layouts já cadastrados
   CrgLayout(0)

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Cadastro de Layout de Retorno de Comunicação Relato Serasa" FROM C(178),C(181) TO C(635),C(960) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlg

   @ C(212),C(005) Button "Inclui Layout"                  Size C(056),C(012) PIXEL OF oDlg ACTION( AbreIncLay("I", "", "", "", "") )
   @ C(212),C(062) Button "Altera Layout"                  Size C(056),C(012) PIXEL OF oDlg ACTION( AbreIncLay("A", aLayout[oLayout:nAt,01], aLayout[oLayout:nAt,02], aLayout[oLayout:nAt,03], aLayout[oLayout:nAt,04]) )
   @ C(212),C(119) Button "Exclui Layout"                  Size C(056),C(012) PIXEL OF oDlg ACTION( AbreIncLay("E", aLayout[oLayout:nAt,01], aLayout[oLayout:nAt,02], aLayout[oLayout:nAt,03], aLayout[oLayout:nAt,04]) )
   @ C(212),C(208) Button "Detalhes do Layout Selecionado" Size C(096),C(012) PIXEL OF oDlg ACTION( AbreManLay( aLayout[oLayout:nAt,01], aLayout[oLayout:nAt,02], aLayout[oLayout:nAt,03], aLayout[oLayout:nAt,04]) )
   @ C(212),C(347) Button "Voltar"                         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oLayout := TCBrowse():New( 058 , 005, 485, 207,,{'IDINF'   ,; // 01 - Identificação
                                                    'BCFIC'   ,; // 02 - Bloco
                                                    'TPINF'   ,; // 03 - Tipo de Informação
                                                    'Título'} ,; // 04 - Título
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oLayout:SetArray(aLayout) 
    
   oLayout:bLine := {||{ aLayout[oLayout:nAt,01],;
                         aLayout[oLayout:nAt,02],;
                         aLayout[oLayout:nAt,03],;
                         aLayout[oLayout:nAt,04]}}
      
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o grid para visualização
Static Function CrgLayout(__Tipo)

   Local cSql := ""

   aLayout    := {}

   // Carrega o grid com os layouts cadastrados
   If Select("T_LAYOUTS") > 0
      T_LAYOUTS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZPD_IDINF,"
   cSql += "       ZPD_BCFIC,"
   cSql += "       ZPD_TPINF,"
   cSql += "       ZPD_TITU  "
   cSql += "  FROM " + RetSqlName("ZPD")
   cSql += " WHERE ZPD_DELE  = ''"
   cSql += " ORDER BY ZPD_IDINF, ZPD_BCFIC, ZPD_TPINF"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LAYOUTS", .T., .T. )

   T_LAYOUTS->( DbGoTop() )
   
   WHILE !T_LAYOUTS->( EOF() )
      aAdd( aLayout, { T_LAYOUTS->ZPD_IDINF,;
                       T_LAYOUTS->ZPD_BCFIC,;
                       T_LAYOUTS->ZPD_TPINF,;
                       T_LAYOUTS->ZPD_TITU} )
      T_LAYOUTS->( DbSkip() )
   ENDDO

   If Len(aLayout) == 0
      aAdd( aLayout, { "", "", "", "" } )      
   Endif

   If __Tipo == 0
      Return(.T.)
   Endif   

   // Seta vetor para a browse                            
   oLayout:SetArray(aLayout) 
    
   oLayout:bLine := {||{ aLayout[oLayout:nAt,01],;
                         aLayout[oLayout:nAt,02],;
                         aLayout[oLayout:nAt,03],;
                         aLayout[oLayout:nAt,04]}}
Return(.T.)

// Função que abre janela de manutenção do layout de retorno do Relato Serasa
Static Function AbreManLay(__IDINF, __BCFIC, __TPINF, __TITULO)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private xIDINF  := Space(02)
   Private xNIDINF := Space(30)
   Private xBCFIC  := Space(02)
   Private xNBCFIC := Space(30)
   Private xTPINF  := Space(02)
   Private xNTPINF := Space(30)
   Private xTitulo := Space(100)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private lVoltar  := .F.

   Private aDetalhe := {}

   Private oDlgL

   If Select("T_LAYOUTS") > 0
      T_LAYOUTS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZPD_IDINF ,"
   cSql += "       ZPD_NIDINF,"
   cSql += "       ZPD_BCFIC ,"
   cSql += "       ZPD_NBCFIC,"
   cSql += "       ZPD_TPINF ,"
   cSql += "       ZPD_NTPINF,"
   cSql += "       ZPD_TITU   "
   cSql += "  FROM " + RetSqlName("ZPD")
   cSql += " WHERE ZPD_IDINF = '" + Alltrim(__IDINF) + "'"
   cSql += "   AND ZPD_BCFIC = '" + Alltrim(__BCFIC) + "'"
   cSql += "   AND ZPD_TPINF = '" + Alltrim(__TPINF) + "'"
   cSql += "   AND ZPD_DELE  = ''"
   cSql += " ORDER BY ZPD_IDINF, ZPD_BCFIC, ZPD_TPINF"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LAYOUTS", .T., .T. )
   
   xIDINF  := T_LAYOUTS->ZPD_IDINF
   xNIDINF := T_LAYOUTS->ZPD_NIDINF
   xBCFIC  := T_LAYOUTS->ZPD_BCFIC
   xNBCFIC := T_LAYOUTS->ZPD_NBCFIC
   xTPINF  := T_LAYOUTS->ZPD_TPINF
   xNTPINF := T_LAYOUTS->ZPD_NTPINF
   xTitulo := T_LAYOUTS->ZPD_TITU
   
   // Envia para a função que carrega o gri dos detalhes para visualização
   CrgDetalhe(0, __IDINF, __BCFIC, __TPINF )

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgL TITLE "Cadastro de Layout de Retorno de Comunicação Relato Serasa" FROM C(178),C(181) TO C(635),C(960) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgL

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlgL

   @ C(041),C(005) Say "Título"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(064),C(005) Say "Identificação do Bloco de Informações" Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(075),C(005) Say "IDINF"                                 Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(075),C(135) Say "BCFIC"                                 Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(075),C(265) Say "TPINF"                                 Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(098),C(005) Say "Ítens do Bloco"                        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(051),C(005) MsGet oGet7 Var xTitulo Size C(379),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(085),C(005) MsGet oGet1 Var xIDINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(085),C(023) MsGet oGet2 Var xNIDINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(085),C(135) MsGet oGet3 Var xBCFIC  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(085),C(154) MsGet oGet4 Var xNBCFIC Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(085),C(265) MsGet oGet5 Var xTPINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(085),C(284) MsGet oGet6 Var xNTPINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba

   @ C(212),C(005) Button "Inclui Item no Bloco" Size C(056),C(012) PIXEL OF oDlgL ACTION( AbreDetalhe("I", xIDINF, xBCFIC, xTPINF, "" ) )
   @ C(212),C(062) Button "Aletra Item no Bloco" Size C(056),C(012) PIXEL OF oDlgL ACTION( AbreDetalhe("A", xIDINF, xBCFIC, xTPINF, aDetalhe[oDetalhe:nAt,04] ) )
   @ C(212),C(119) Button "Exclui Item no Bloco" Size C(056),C(012) PIXEL OF oDlgL ACTION( AbreDetalhe("E", xIDINF, xBCFIC, xTPINF, aDetalhe[oDetalhe:nAt,04] ) )
   @ C(212),C(347) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   oDetalhe := TCBrowse():New( 135 , 005, 485, 132,,{'IDINF'                 ,; // 01 - Identificação
                                                     'BCFIC'                 ,; // 02 - Bloco
                                                     'TPINF'                 ,; // 03 - Tipo de Informação
                                                     'MNEMÔNICO'             ,; // 04 - Mnemônico
                                                     'Posição'               ,; // 05 - Posição na String
                                                     'Tamanho'               ,; // 06 - Tamanho
                                                     'Decimal'               ,; // 07 - Decimal
                                                     'Descrição do Retorno'  ,; // 08 - Descrição do Retorno
                                                     'Posição'               ,; // 09 - Posição de Leitura
                                                     'Visual.'               ,; // 10 - Indica se visualiza retorno ou não
                                                     'Ordenação'            },; // 11 - Ordenação
                                                     {20,50,50,50},oDlgL,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oDetalhe:SetArray(aDetalhe) 
    
   oDetalhe:bLine := {||{ aDetalhe[oDetalhe:nAt,01],;
                          aDetalhe[oDetalhe:nAt,02],;
                          aDetalhe[oDetalhe:nAt,03],;
                          aDetalhe[oDetalhe:nAt,04],;
                          aDetalhe[oDetalhe:nAt,05],;                          
                          aDetalhe[oDetalhe:nAt,06],;
                          aDetalhe[oDetalhe:nAt,07],;
                          aDetalhe[oDetalhe:nAt,08],;
                          aDetalhe[oDetalhe:nAt,09],;
                          aDetalhe[oDetalhe:nAt,10],;
                          aDetalhe[oDetalhe:nAt,11]}}

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Função que carrega o grid dos detalhes
Static Function CrgDetalhe(__Tipo, __IDINF, __BCFIC, __TPINF )

   Local cSql := ""

   aDetalhe   := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZPE_IDINF,"
   cSql += "       ZPE_BCFIC,"
   cSql += "       ZPE_TPINF,"
   cSql += "       ZPE_CODI ,"
   cSql += "       ZPE_TIPO ,"
   cSql += "       ZPE_TAMA ,"
   cSql += "       ZPE_DECI ,"
   cSql += "       ZPE_TITU ,"
   cSql += "       ZPE_DELE ,"
   cSql += "       ZPE_POSI ,"
   cSql += "       ZPE_VISU ,"
   cSql += "       ZPE_ORDE  "
   cSql += "  FROM " + RetSqlName("ZPE")
   cSql += " WHERE ZPE_IDINF = '" + Alltrim(__IDINF)  + "'"
   cSql += "   AND ZPE_BCFIC = '" + Alltrim(__BCFIC)  + "'"
   cSql += "   AND ZPE_TPINF = '" + Alltrim(__TPINF)  + "'"
   cSql += "   AND ZPE_DELE  = ''"
   cSql += " ORDER BY ZPE_ORDE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   WHILE !T_DETALHE->( EOF() )
   
      aAdd( aDetalhe, { T_DETALHE->ZPE_IDINF,;
                        T_DETALHE->ZPE_BCFIC,;
                        T_DETALHE->ZPE_TPINF,;
                        T_DETALHE->ZPE_CODI ,;
                        T_DETALHE->ZPE_TIPO ,;
                        T_DETALHE->ZPE_TAMA ,;
                        T_DETALHE->ZPE_DECI ,;
                        T_DETALHE->ZPE_TITU ,;
                        T_DETALHE->ZPE_POSI ,;
                        T_DETALHE->ZPE_VISU ,;
                        T_DETALHE->ZPE_ORDE })

      T_DETALHE->( DbSkip() )

   ENDDO   

   If Len(aDetalhe) == 0
      aAdd(aDetalhe, { "", "", "", "", "", "", "", "", "", "", "" } )
   Endif

   If __Tipo == 0
      Return(.T.)
   Endif   

   // Seta vetor para a browse                            
   oDetalhe:SetArray(aDetalhe) 
    
   oDetalhe:bLine := {||{ aDetalhe[oDetalhe:nAt,01],;
                          aDetalhe[oDetalhe:nAt,02],;
                          aDetalhe[oDetalhe:nAt,03],;
                          aDetalhe[oDetalhe:nAt,04],;
                          aDetalhe[oDetalhe:nAt,05],;                          
                          aDetalhe[oDetalhe:nAt,06],;
                          aDetalhe[oDetalhe:nAt,07],;
                          aDetalhe[oDetalhe:nAt,08],;
                          aDetalhe[oDetalhe:nAt,09],;
                          aDetalhe[oDetalhe:nAt,10],;                                                    
                          aDetalhe[oDetalhe:nAt,11]}}
Return(.T.)

// Função que abre janela de manutenção do detalhe do bloco de informações
Static Function AbreDetalhe(__Operacao, __IDINF, __BCFIC, __TPINF, __Mnemonico )

   Local lChumba := .F.
   Local lExclui := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private dCodigo   := Space(30)
   Private dTipo	 := Space(01)
   Private dTamanho  := 0
   Private dDecimal  := 0
   Private dTitulo   := Space(100)
   Private dPosicao  := 0
   Private dConteudo := ""
   Private dOrdem    := 0
   Private lVisual   := .F.
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet7
   Private oGet8
   Private oGet9
   Private oMemo3
   Private oVisual

   Private oDlgD

   If __Operacao == "I"
      lChumba := .T.
   Else
      lChumba := .F.
      If Select("T_DETALHE") > 0
         T_DETALHE->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZPE_IDINF,"
      cSql += "       ZPE_BCFIC,"
      cSql += "       ZPE_TPINF,"
      cSql += "       ZPE_CODI ,"
      cSql += "       ZPE_TIPO ,"
      cSql += "       ZPE_TAMA ,"
      cSql += "       ZPE_DECI ,"
      cSql += "       ZPE_TITU ,"
      cSql += "       ZPE_POSI ,"
      cSql += "       ZPE_CONT ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPE_CONT)) AS CONTEUDO, "
      cSql += "       ZPE_DELE ,"
      cSql += "       ZPE_VISU ,"
      cSql += "       ZPE_ORDE  "
      cSql += "  FROM " + RetSqlName("ZPE")
      cSql += " WHERE ZPE_IDINF = '" + Alltrim(__IDINF)     + "'"
      cSql += "   AND ZPE_BCFIC = '" + Alltrim(__BCFIC)     + "'"
      cSql += "   AND ZPE_TPINF = '" + Alltrim(__TPINF)     + "'"
      cSql += "   AND ZPE_CODI  = '" + Alltrim(__Mnemonico) + "'"
      cSql += "   AND ZPE_DELE  = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )
   
      If T_DETALHE->( EOF() )
         MsgAlert("Não existem dados a serem visualizados para esta operação. Verifique!")
         Return(.T.)
      Else
         dCodigo   := T_DETALHE->ZPE_CODI
         dTipo	   := T_DETALHE->ZPE_TIPO
         dTamanho  := T_DETALHE->ZPE_TAMA
         dDecimal  := T_DETALHE->ZPE_DECI
         dPosicao  := T_DETALHE->ZPE_POSI
         dConteudo := T_DETALHE->CONTEUDO
         dTitulo   := T_DETALHE->ZPE_TITU
         dOrdem    := T_DETALHE->ZPE_ORDE
         lVisual   := IIF(T_DETALHE->ZPE_VISU == "S", .T., .F.)
      Endif

   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgD TITLE "Cadastro de Layout de Retorno de Comunicação Relato Serasa" FROM C(178),C(181) TO C(544),C(662) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgD

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(233),C(001) PIXEL OF oDlgD
   @ C(161),C(002) GET oMemo2 Var cMemo2 MEMO Size C(233),C(001) PIXEL OF oDlgD

   @ C(041),C(005) Say "Mnemônico"                 Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(041),C(115) Say "Tipo"                      Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(041),C(144) Say "Tamanho"                   Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(041),C(177) Say "Decimal"                   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(041),C(208) Say "Pos.Inicial"               Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(064),C(115) Say "Ordenação de Visualização" Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(078),C(005) Say "Descrição do Retorno"      Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(100),C(005) Say "Substituir conteúdo por"   Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   
   If __Operacao == "E"
      @ C(051),C(005) MsGet    oGet7   Var dCodigo        Size C(099),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgD When lExclui
      @ C(051),C(115) MsGet    oGet1   Var dTipo          Size C(015),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgD When lExclui
      @ C(051),C(144) MsGet    oGet2   Var dTamanho       Size C(015),C(009) COLOR CLR_BLACK Picture "@E 999"  PIXEL OF oDlgD When lExclui
      @ C(051),C(177) MsGet    oGet3   Var dDecimal       Size C(015),C(009) COLOR CLR_BLACK Picture "@E 99"   PIXEL OF oDlgD When lExclui
      @ C(051),C(208) MsGet    oGet8   Var dPosicao       Size C(018),C(009) COLOR CLR_BLACK Picture "@E 9999" PIXEL OF oDlgD When lExclui
      @ C(065),C(005) CheckBox oVisual Var lVisual   Prompt "Parâmetro será visualizado" Size C(076),C(008)    PIXEL OF oDlgD When lExclui
      @ C(074),C(115) MsGet    oGet9   Var dOrdem         Size C(025),C(009) COLOR CLR_BLACK Picture "@E 9999" PIXEL OF oDlgD When lExclui
      @ C(088),C(005) MsGet    oGet4   Var dTitulo        Size C(228),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgD When lExclui
      @ C(109),C(005) GET      oMemo3  Var dConteudo MEMO Size C(228),C(048)                                   PIXEL OF oDlgD When lExclui
   Else
      @ C(051),C(005) MsGet    oGet7   Var dCodigo        Size C(099),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgD When lChumba
      @ C(051),C(115) MsGet    oGet1   Var dTipo          Size C(015),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgD
      @ C(051),C(144) MsGet    oGet2   Var dTamanho       Size C(015),C(009) COLOR CLR_BLACK Picture "@E 999"  PIXEL OF oDlgD
      @ C(051),C(177) MsGet    oGet3   Var dDecimal       Size C(015),C(009) COLOR CLR_BLACK Picture "@E 99"   PIXEL OF oDlgD
      @ C(051),C(208) MsGet    oGet8   Var dPosicao       Size C(018),C(009) COLOR CLR_BLACK Picture "@E 9999" PIXEL OF oDlgD
      @ C(065),C(005) CheckBox oVisual Var lVisual   Prompt "Parâmetro será visualizado" Size C(076),C(008)    PIXEL OF oDlgD
      @ C(074),C(115) MsGet    oGet9   Var dOrdem         Size C(025),C(009) COLOR CLR_BLACK Picture "@E 9999" PIXEL OF oDlgD
      @ C(088),C(005) MsGet    oGet4   Var dTitulo        Size C(228),C(009) COLOR CLR_BLACK Picture "@!"      PIXEL OF oDlgD
      @ C(109),C(005) GET      oMemo3  Var dConteudo MEMO Size C(228),C(048)                                   PIXEL OF oDlgD
   Endif   

   If __Operacao == "E"
      @ C(166),C(160) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgD ACTION( GrvDetalhe(__Operacao, __IDINF, __BCFIC, __TPINF, dCodigo, dTipo, dTamanho, dDecimal, dTitulo, dPosicao, dConteudo, lVisual, dOrdem) )
   Else
      @ C(166),C(160) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlgD ACTION( GrvDetalhe(__Operacao, __IDINF, __BCFIC, __TPINF, dCodigo, dTipo, dTamanho, dDecimal, dTitulo, dPosicao, dConteudo, lVisual, dOrdem) )      
   Endif

   @ C(166),C(198) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   ACTIVATE MSDIALOG oDlgD CENTERED 

Return(.T.)

// Função que grava o detalhe informado
Static Function GrvDetalhe(__Operacao, __IDINF, __BCFIC, __TPINF, _dCodigo, _dTipo, _dTamanho, _dDecimal, _dTitulo, _dPosicao, _dConteudo, _Visual, _dOrdem )

   Local cSql    := ""
   Local lResult := 0
   
   // Realiza a consistência dos dados entes da gravação
   If Empty(Alltrim(_dCodigo))
      MsgAlert("Mnemônico não informado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(_dTipo))
      MsgAlert("Tipo de Mnemônico não informado. Verifique!")
      Return(.T.)
   Endif

   If _dTamanho == 0
      MsgAlert("Tamanho do Mnemônico não informado. Verifique!")
      Return(.T.)
   Endif

   If _dPosicao == 0
      MsgAlert("Posição Inicial do Mnemônico não informado. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(_dTitulo))
      MsgAlert("Título do Retorno não informado. Verifique!")
      Return(.T.)
   Endif

   // Verifica se Layout já está cadastrado
   If __Operacao == "I"
      If Select("T_JAEXISTE") > 0
         T_JAEXISTE->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZPE_IDINF,"
      cSql += "       ZPE_BCFIC,"
      cSql += "       ZPE_TPINF,"
      cSql += "       ZPE_CODI ,"
      cSql += "       ZPE_TIPO ,"
      cSql += "       ZPE_TAMA ,"
      cSql += "       ZPE_DECI ,"
      cSql += "       ZPE_TITU ,"
      cSql += "       ZPE_DELE ,"
      cSql += "       ZPE_POSI  "
      cSql += "  FROM " + RetSqlName("ZPE")
      cSql += " WHERE ZPE_IDINF = '" + Alltrim(__IDINF)  + "'"
      cSql += "   AND ZPE_BCFIC = '" + Alltrim(__BCFIC)  + "'"
      cSql += "   AND ZPE_TPINF = '" + Alltrim(__TPINF)  + "'"
      cSql += "   AND ZPE_CODI  = '" + Alltrim(_dCodigo) + "'"
      cSql += "   AND ZPE_DELE  = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

      If !T_JAEXISTE->( EOF() )
         MsgAlert("Atenção! Detalhe do Layout já cadastrado. Verifique!")
         Return(.T.)
      Endif

      // Inclui os dados na tabela ZPD - Cabeçalho Layout Retorno do Relato Serasa
      dbSelectArea("ZPE")
      RecLock("ZPE",.T.)
      ZPE_FILIAL := ""
      ZPE_IDINF  := __IDINF
      ZPE_BCFIC  := __BCFIC
      ZPE_TPINF  := __TPINF
      ZPE_CODI   := _dCodigo
      ZPE_TIPO   := _dTipo
      ZPE_TAMA   := _dTamanho
      ZPE_DECI   := _dDecimal
      ZPE_TITU   := _dTitulo
      ZPE_DELE   := " "   
      ZPE_POSI   := _dPosicao
      ZPE_CONT   := _dConteudo
      ZPE_VISU   := IIF(_Visual == .T., "S", "N")
      ZPE_ORDE   := _dOrdem
      MsUnLock()
   Endif
   
   // Alteração
   If __Operacao == "A"

      dbSelectArea("ZPE")
      dbSetOrder(1)
      If dbSeek("  " + __IDINF + __BCFIC + __TPINF + _dCodigo)
         RecLock("ZPE",.F.)
         ZPE_TIPO := _dTipo
         ZPE_TAMA := _dTamanho
         ZPE_DECI := _dDecimal
         ZPE_POSI := _dPosicao
         ZPE_TITU := _dTitulo
         ZPE_CONT := _dConteudo
         ZPE_VISU := IIF(_Visual == .T., "S", "N")
         ZPE_ORDE := _dOrdem
         MsUnLock()
      Endif
      
   Endif
         
   // Exclusão
   If __Operacao == "E"

      dbSelectArea("ZPE")
      dbSetOrder(1)
      If dbSeek("  " + __IDINF + __BCFIC + __TPINF + _dCodigo)
         RecLock("ZPE",.F.)
         ZPE_DELE := "X"
         MsUnLock()
      Endif
      
   Endif   

   oDlgD:End()

   CrgDetalhe(1, __IDINF, __BCFIC, __TPINF )

Return(.T.)

// Função que abre janela de inclusão de layout de retorno do Relato Serasa
Static Function AbreIncLay(__Operacao, __IDINF, __BCFIC, __TPINF, __TITULO)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cIDINF	 := Space(02)
   Private cNIDINF	 := Space(30)
   Private cBCFIC	 := Space(02)
   Private cNBCFIC	 := Space(30)
   Private cTPINF	 := Space(02)
   Private cNTPINF	 := Space(30)
   Private cTitulo	 := Space(100)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlgI

   If __Operacao == "I"
   Else

      If Select("T_LAYOUT") > 0
         T_LAYOUT->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZPD_FILIAL,"
      cSql += "       ZPD_IDINF ,"
      cSql += "       ZPD_NIDINF,"
      cSql += "       ZPD_BCFIC ,"
      cSql += "       ZPD_NBCFIC,"
      cSql += "       ZPD_TPINF ,"
      cSql += "       ZPD_NTPINF,"
      cSql += "       ZPD_TITU  ,"
      cSql += "       ZPD_DELE   "
      cSql += "  FROM " + RetSqlName("ZPD")
      cSql += " WHERE ZPD_IDINF = '" + Alltrim(__IDINF) + "'"
      cSql += "   AND ZPD_BCFIC = '" + Alltrim(__BCFIC) + "'"
      cSql += "   AND ZPD_TPINF = '" + Alltrim(__TPINF) + "'"
      cSql += "   AND ZPD_DELE  = ' '"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LAYOUT", .T., .T. )

      If T_LAYOUT->( EOF() )
         MsgAlert("Layout não localizado. Verifique!")
         Return(.T.)
      Endif   

      cIDINF	 := T_LAYOUT->ZPD_IDINF
      cNIDINF	 := T_LAYOUT->ZPD_NIDINF
      cBCFIC	 := T_LAYOUT->ZPD_BCFIC
      cNBCFIC	 := T_LAYOUT->ZPD_NBCFIC
      cTPINF	 := T_LAYOUT->ZPD_TPINF
      cNTPINF	 := T_LAYOUT->ZPD_NTPINF
      cTitulo	 := T_LAYOUT->ZPD_TITU

   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgI TITLE "Cadastro de Layout de Retorno de Comunicação Relato Serasa" FROM C(178),C(181) TO C(433),C(960) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(126),C(030) PIXEL NOBORDER OF oDlgI

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlgI
   @ C(102),C(002) GET oMemo2 Var cMemo2 MEMO Size C(382),C(001) PIXEL OF oDlgI
   
   @ C(041),C(005) Say "Título"                                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(064),C(005) Say "Identificação do Bloco de Informações" Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(075),C(005) Say "IDINF"                                 Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(075),C(135) Say "BCFIC"                                 Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(075),C(265) Say "TPINF"                                 Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgI

   If __Operacao == "I"
      @ C(051),C(005) MsGet oGet7 Var cTitulo Size C(379),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
      @ C(085),C(005) MsGet oGet1 Var cIDINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
      @ C(085),C(023) MsGet oGet2 Var cNIDINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
      @ C(085),C(135) MsGet oGet3 Var cBCFIC  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
      @ C(085),C(154) MsGet oGet4 Var cNBCFIC Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
      @ C(085),C(265) MsGet oGet5 Var cTPINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
      @ C(085),C(284) MsGet oGet6 Var cNTPINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
   Else
      If __Operacao == "A"
         @ C(051),C(005) MsGet oGet7 Var cTitulo Size C(379),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
         @ C(085),C(005) MsGet oGet1 Var cIDINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(023) MsGet oGet2 Var cNIDINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
         @ C(085),C(135) MsGet oGet3 Var cBCFIC  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(154) MsGet oGet4 Var cNBCFIC Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI
         @ C(085),C(265) MsGet oGet5 Var cTPINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(284) MsGet oGet6 Var cNTPINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI             
      Else
         @ C(051),C(005) MsGet oGet7 Var cTitulo Size C(379),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(005) MsGet oGet1 Var cIDINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(023) MsGet oGet2 Var cNIDINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(135) MsGet oGet3 Var cBCFIC  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(154) MsGet oGet4 Var cNBCFIC Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(265) MsGet oGet5 Var cTPINF  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
         @ C(085),C(284) MsGet oGet6 Var cNTPINF Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
      Endif
   Endif               

   If __Operacao == "E"
      @ C(110),C(156) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgI ACTION( GrvIncLay( __Operacao, cTitulo, cIDINF ,cNIDINF, cBCFIC , cNBCFIC, cTPINF , cNTPINF ) )
   Else
      @ C(110),C(156) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlgI ACTION( GrvIncLay( __Operacao, cTitulo, cIDINF ,cNIDINF, cBCFIC , cNBCFIC, cTPINF , cNTPINF ) )
   Endif   

   @ C(110),C(196) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgI ACTION( oDlgI:End() )

   ACTIVATE MSDIALOG oDlgI CENTERED 
   
Return(.T.)

Static Function GrvIncLay(__Operacao, __Titulo, __IDINF ,__NIDINF, __BCFIC , __NBCFIC, __TPINF , __NTPINF)

   // Realiza a consistência dos dados entes da gravação
   If Empty(Alltrim(__Titulo))
      MsgAlert("Necessário informar Título. Verifique!")
      Return(.T.)
   Endif
         
   If Empty(Alltrim(__IDINF))
      MsgAlert("Necessário informar IDINF. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(__NIDINF))
      MsgAlert("Necessário informar a descrição do IDINF. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(__BCFIC))
      MsgAlert("Necessário informar BCFIC. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(__NBCFIC))
      MsgAlert("Necessário informar o título do BCFIC. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(__TPINF))
      MsgAlert("Necessário informar TPINF. Verifique!")
      Return(.T.)
   Endif

   If Empty(Alltrim(__NTPINF))
      MsgAlert("Necessário informar o título do TPINF. Verifique!")
      Return(.T.)
   Endif

   If __Operacao == "I"
      
      // Verifica se Layout já está cadastrado
      If Select("T_JAEXISTE") > 0
         T_JAEXISTE->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZPD_IDINF,"
      cSql += "       ZPD_BCFIC,"
      cSql += "       ZPD_TPINF "
      cSql += "  FROM " + RetSqlName("ZPD")
      cSql += " WHERE ZPD_IDINF = '" + Alltrim(__IDINF) + "'"
      cSql += "   AND ZPD_BCFIC = '" + Alltrim(__BCFIC) + "'"
      cSql += "   AND ZPD_TPINF = '" + Alltrim(__TPINF) + "'"
      cSql += "   AND ZPD_DELE  = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

      If !T_JAEXISTE->( EOF() )
         MsgAlert("Atenção! Layout já cadastrado. Verifique!")
         Return(.T.)
      Endif
   Endif

   // Inclui os dados na tabela ZPD - Cabeçalho Layout Retorno do Relato Serasa
   If __Operacao == "I"
      dbSelectArea("ZPD")
      RecLock("ZPD",.T.)
      ZPD_FILIAL := ""
      ZPD_IDINF  := __IDINF
      ZPD_NIDINF := __NIDINF
      ZPD_BCFIC  := __BCFIC
      ZPD_NBCFIC := __NBCFIC
      ZPD_TPINF  := __TPINF
      ZPD_NTPINF := __NTPINF
      ZPD_TITU   := __Titulo
      ZPD_DELE   := " "   
      MsUnLock()
   Endif
   
   // Alteração de Layout
   If __Operacao == "A"
      dbSelectArea("ZPD")
      dbSetOrder(1)
      If dbSeek("  " + __IDINF + __BCFIC + __TPINF)
         RecLock("ZPD",.F.)
         ZPD_NIDINF := __NIDINF
         ZPD_NBCFIC := __NBCFIC
         ZPD_NTPINF := __NTPINF
         ZPD_TITU   := __Titulo
         MsUnLock()
      Endif   
   Endif
   
   // Exclusão de Layout
   If __Operacao == "E"
      dbSelectArea("ZPD")
      dbSetOrder(1)
      If dbSeek("  " + __IDINF + __BCFIC + __TPINF)
         RecLock("ZPD",.F.)
         ZPD_DELE := "X"
         MsUnLock()
      Endif   
   Endif

   oDlgI:End()

   // Carrega o grid com os dados dos Layouts já cadastrados
   CrgLayout(1)

Return(.T.)