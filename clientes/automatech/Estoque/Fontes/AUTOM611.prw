#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"                                                                               
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM611.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 11/08/2017                                                              ##
// Objetivo..: Programa que imprime etiquetas caixa                                    ##
// ######################################################################################

User Function AUTOM611()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private cNumOP   := Space(15)
   Private cNumPV   := Space(06)
   Private nQtdEtq  := 1
   Private cDetalhe := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo2

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   aLista := {}

   DEFINE FONT oFont Name "Courier New" Size 0, 14 BOLD

   Private oDlg

   U_AUTOM628("AUTOM611")

   DEFINE MSDIALOG oDlg TITLE "Etiqueta Caixa" FROM C(178),C(181) TO C(537),C(774) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(290),C(001) PIXEL OF oDlg

   @ C(032),C(005) Say "Nº OP"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(049) Say "Nº Ped.Venda"      Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Dados do Cliente"  Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(102),C(005) Say "Produtos da OP/PV" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(166),C(160) Say "Qtd Etq"           Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(042),C(005) MsGet oGet1  Var cNumOP        Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(042),C(049) MsGet oGet2  Var cNumPV        Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(165),C(181) MsGet oGet3  Var nQtdEtq       Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(064),C(005) GET   oMemo2 Var cDetalhe MEMO Size C(287),C(037) FONT oFont                   PIXEL OF oDlg When lChumba

   @ C(039),C(090) Button "Pesquisar"        Size C(037),C(012) PIXEL OF oDlg ACTION( PesqDadosOP() )                        
   @ C(163),C(005) Button "Marca Todos"      Size C(048),C(012) PIXEL OF oDlg ACTION( MMRRCCREG(1) )
   @ C(163),C(054) Button "Desmarca Todos"   Size C(048),C(012) PIXEL OF oDlg ACTION( MMRRCCREG(0) )
   @ C(163),C(106) Button "Alt. Qtd Produto" Size C(044),C(012) PIXEL OF oDlg ACTION( AltQtdPrd() )
   @ C(163),C(215) Button "Imprimir"         Size C(037),C(012) PIXEL OF oDlg ACTION( ImpEtqCaixa() )
   @ C(163),C(255) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "", "", "", 0 })

   @ 140,005 LISTBOX oLista FIELDS HEADER "M", "Produto", "Descrição dos Produtos", "Un", "Qtd Prd", "Qtd Etq" ;
             PIXEL SIZE 370,63 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),; // 01 - Marcação
                           aLista[oLista:nAt,02]         ,; // 02 - Código Produto
                           aLista[oLista:nAt,03]         ,; // 03 - Descrição dos Produtos
                           aLista[oLista:nAt,04]         ,; // 04 - Unidade de Medida
                           aLista[oLista:nAt,05]         }} // 05 - Quantidade do Produto

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)  

// ############################################
// Função que pesquisa dados conforme filtro ##
// ############################################
Static Function PesqDadosOP()

   Local cSql    := ""
   Local cString := ""

   If Empty(Alltrim(cNumOP)) .And. Empty(Alltrim(cNumPV))
      MsgAlert("Documento a ser pesquisado não informado.")
      Return(.T.)
   Endif

   aLista := {}

   If !Empty(Alltrim(cNumPV))
      
      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC6.C6_FILIAL ," + chr(13)
      cSql += "       SC6.C6_NUM    ," + chr(13)
	  cSql += "       SC6.C6_CLI    ," + chr(13)
	  cSql += "       SC6.C6_LOJA   ," + chr(13)
	  cSql += "       SA1.A1_NOME   ," + chr(13)
	  cSql += "       SA1.A1_END    ," + chr(13)
	  cSql += "       SA1.A1_BAIRRO ," + chr(13)
	  cSql += "       SA1.A1_CEP    ," + chr(13)
	  cSql += "       SA1.A1_MUN    ," + chr(13)
	  cSql += "       SA1.A1_EST    ," + chr(13)
	  cSql += "       SC6.C6_PRODUTO," + chr(13)
	  cSql += "       SC6.C6_ITEM   ," + chr(13)
      cSql += "       SC6.C6_QTDVEN ," + chr(13)
	  cSql += "       LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS NOME," + chr(13)
	  cSql += "       SB1.B1_UM     ," + chr(13)
	  cSql += "      (SC2.C2_NUM + '.' + SC2.C2_ITEM + '.' + SC2.C2_SEQUEN) AS OPRODUCAO " + chr(13)
      cSql += "  FROM " + RetSqlName("SC6") + " SC6, " + chr(13)
      cSql += "       " + RetSqlName("SA1") + " SA1, " + chr(13)
      cSql += "	      " + RetSqlName("SB1") + " SB1, " + chr(13)
      cSql += "       " + RetSqlName("SC2") + " SC2  " + chr(13)
      cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'" + chr(13)
      cSql += "   AND SC6.C6_NUM     = '" + Alltrim(cNumPV)  + "'" + chr(13)
      cSql += "   AND SC6.D_E_L_E_T_ = ''" + chr(13)
      cSql += "   AND SA1.A1_COD     = SC6.C6_CLI " + chr(13)
      cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA" + chr(13)
      cSql += "   AND SA1.D_E_L_E_T_ = ''         " + chr(13)
      cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO" + chr(13)
      cSql += "   AND SB1.D_E_L_E_T_ = ''" + chr(13)
      cSql += "   AND SC2.C2_FILIAL  = SC6.C6_FILIAL" + chr(13)
      cSql += "   AND SC2.C2_PEDIDO  = SC6.C6_NUM   " + chr(13)
      cSql += "   AND SC2.D_E_L_E_T_ = ''           " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      If T_CONSULTA->( EOF() )
         If Len(aLista) == 0
            aAdd( aLista, { .F., "", "", "", 0 })
         Endif
         MsgAlert("Não existem dados a serem visualizados para este Pedido de Venda.")
         cDetalhe := ""
         oMemo2:refresh() 
      Else
      
         cString := ""
         cString += "Cliente.: " + Alltrim(T_CONSULTA->C6_CLI) + "." + Alltrim(T_CONSULTA->C6_LOJA) + Chr(13) + chr(10) 
         cString += "Razão...: " + Alltrim(T_CONSULTA->A1_NOME)  + chr(13) + chr(10)
         cString += "Endereço: " + Alltrim(T_CONSULTA->A1_END)    + chr(13) + chr(10)
         cString += "Bairro..: " + Alltrim(T_CONSULTA->A1_BAIRRO) + chr(13) + chr(10)
         cString += "Cidade..: " + Alltrim(T_CONSULTA->A1_CEP) + " - " + Alltrim(T_CONSULTA->A1_MUN) + " / " + Alltrim(T_CONSULTA->A1_EST)      
         
         cDetalhe := cString
         oMemo2:refresh() 

         T_CONSULTA->( DbGoTop() )
         
         WHILE !T_CONSULTA->( EOF() )
            aAdd( aLista, { .F.                   ,; // 01
                            T_CONSULTA->C6_PRODUTO,; // 02
                            T_CONSULTA->NOME      ,; // 03
                            T_CONSULTA->B1_UM     ,; // 04
                            T_CONSULTA->C6_QTDVEN ,; // 05
                            T_CONSULTA->C6_NUM    ,; // 06
                            T_CONSULTA->OPRODUCAO ,; // 07
                            T_CONSULTA->A1_NOME   }) // 08
                            
            T_CONSULTA->( DbSkip() )
         ENDDO   
            
         If Len(aLista) == 0
            aAdd( aLista, { .F., "", "", "", 0 })
         Endif
            
         oLista:SetArray( aLista )

         oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),; // 01 - Marcação
                                 aLista[oLista:nAt,02]         ,; // 02 - Código Produto
                                 aLista[oLista:nAt,03]         ,; // 03 - Descrição dos Produtos
                                 aLista[oLista:nAt,04]         ,; // 04 - Unidade de Medida
                                 aLista[oLista:nAt,05]         }} // 05 - Quantidade de Produto

      Endif
      
   Endif

   If !Empty(Alltrim(cNumOP))

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SC2.C2_FILIAL ," + chr(13)
      cSql += "       SC2.C2_NUM    ," + chr(13)
	  cSql += "       SC2.C2_ITEM   ," + chr(13)
	  cSql += "       SC2.C2_SEQUEN ," + chr(13)
      cSql += "       SC5.C5_CLIENTE," + chr(13)
      cSql += "       SC5.C5_LOJACLI," + chr(13)
      cSql += "       SA1.A1_NOME   ," + chr(13)
      cSql += "       SA1.A1_END    ," + chr(13)
      cSql += "       SA1.A1_BAIRRO ," + chr(13)
      cSql += "       SA1.A1_CEP    ," + chr(13)
      cSql += "       SA1.A1_MUN    ," + chr(13)
      cSql += "       SA1.A1_EST    ," + chr(13)
      cSql += "       SC2.C2_PRODUTO," + chr(13)
      cSql += "       SC2.C2_QUANT  ," + chr(13)
      cSql += "       LTRIM(RTRIM(SB1.B1_DESC)) + ' ' + LTRIM(RTRIM(SB1.B1_DAUX)) AS NOME," + chr(13)
      cSql += "       SC2.C2_UM     ," + chr(13)
	  cSql += "       SC2.C2_PEDIDO ," + chr(13)
	  cSql += "      (SC2.C2_NUM + '.' + SC2.C2_ITEM + '.' + SC2.C2_SEQUEN) AS OPRODUCAO " + chr(13)
      cSql += "  FROM " + RetSqlName("SC2") + " SC2, " + chr(13)
      cSql += "       " + RetSqlName("SC5") + " SC5, "  + chr(13)
      cSql += "       " + RetSqlName("SA1") + " SA1, "  + chr(13)
      cSql += "       " + RetSqlName("SB1") + " SB1  "  + chr(13)
      cSql += " WHERE SC2.C2_FILIAL  = '" + Alltrim(cFilAnt) + "'" + chr(13)
      cSql += "   AND SC2.C2_NUM     = '" + Substr(cNumOP,01,06)  + "'" + chr(13)
      cSql += "   AND SC2.C2_ITEM    = '" + Substr(cNumOP,07,02)  + "'" + chr(13)
      cSql += "   AND SC2.C2_SEQUEN  = '" + Substr(cNumOP,09,03)  + "'" + chr(13)
      cSql += "   AND SC2.D_E_L_E_T_ = ''" + chr(13)
      cSql += "   AND SC5.C5_FILIAL  = SC2.C2_FILIAL " + chr(13)
      cSql += "   AND SC5.C5_NUM     = SC2.C2_PEDIDO " + chr(13)
      cSql += "   AND SC5.D_E_L_E_T_ = ''            " + chr(13)
      cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE" + chr(13)
      cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI" + chr(13)
      cSql += "   AND SA1.D_E_L_E_T_ = ''            " + chr(13)
      cSql += "   AND SB1.B1_COD     = SC2.C2_PRODUTO" + chr(13)
      cSql += "   AND SB1.D_E_L_E_T_ = ''            " + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      If T_CONSULTA->( EOF() )
         If Len(aLista) == 0
            aAdd( aLista, { .F., "", "", "", 0 })
         Endif
         MsgAlert("Não existem dados a serem visualizados para este Pedido de Venda.")
         cDetalhe := ""
         oMemo2:refresh() 
      Else
      
         cString := ""
         cString += "Cliente.: " + Alltrim(T_CONSULTA->C5_CLIENTE) + "." + Alltrim(T_CONSULTA->C5_LOJACLI) + Chr(13) + chr(10) 
         cString += "Razão...: " + Alltrim(T_CONSULTA->A1_NOME)    + chr(13) + chr(10)
         cString += "Endereço: " + Alltrim(T_CONSULTA->A1_END)     + chr(13) + chr(10)
         cString += "Bairro..: " + Alltrim(T_CONSULTA->A1_BAIRRO)  + chr(13) + chr(10)
         cString += "Cidade..: " + Alltrim(T_CONSULTA->A1_CEP) + " - " + Alltrim(T_CONSULTA->A1_MUN) + " / " + Alltrim(T_CONSULTA->A1_EST)      
         
         cDetalhe := cString
         oMemo2:refresh() 

         T_CONSULTA->( DbGoTop() )
         
         WHILE !T_CONSULTA->( EOF() )
            aAdd( aLista, { .F.                   ,;
                            T_CONSULTA->C2_PRODUTO,;
                            T_CONSULTA->NOME      ,;
                            T_CONSULTA->c2_UM     ,;
                            T_CONSULTA->C2_QUANT  ,;
                            T_CONSULTA->C2_PEDIDO ,;
                            T_CONSULTA->OPRODUCAO })
            T_CONSULTA->( DbSkip() )
         ENDDO   

         If Len(aLista) == 0
            aAdd( aLista, { .F., "", "", "", 0 })
         Endif
            
         oLista:SetArray( aLista )

         oLista:bLine := {||{Iif(aLista[oLista:nAt,01],oOk,oNo),; // 01 - Marcação
                                 aLista[oLista:nAt,02]         ,; // 02 - Código Produto
                                 aLista[oLista:nAt,03]         ,; // 03 - Descrição dos Produtos
                                 aLista[oLista:nAt,04]         ,; // 04 - Unidade de Medida
                                 aLista[oLista:nAt,06]         }} // 05 - Quantidade de Produto

      Endif
      
   Endif
   
Return(.T.)                 

// #########################################
// Função que marca/desmarca os registros ##
// #########################################
Static Function MMRRCCREG(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// ########################################################################
// Função que abre tela para alterar a quantidade do produto selecionado ##
// ########################################################################
Static Function AltQtdPrd()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private kProduto    := aLista[oLista:nAt,02]
   Private kDescricao  := aLista[oLista:nAt,03]
   Private kQuantidade := aLista[oLista:nAt,05]

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   DEFINE MSDIALOG oDlgAlt TITLE "Etiqueta Caixa" FROM C(178),C(181) TO C(335),C(614) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(022) PIXEL NOBORDER OF oDlgAlt

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(209),C(001) PIXEL OF oDlgAlt

   @ C(032),C(005) Say "Produto"        Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(055),C(005) Say "Qtd do Produto" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   
   @ C(042),C(005) MsGet oGet1 Var kProduto    Size C(059),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgAlt When lChumba
   @ C(042),C(068) MsGet oGet2 Var kDescricao  Size C(145),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgAlt When lChumba
   @ C(064),C(005) MsGet oGet3 Var kQuantidade Size C(059),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgAlt
   
   @ C(061),C(134) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgAlt ACTION( AltGrvPrd() )
   @ C(061),C(175) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgAlt ACTION( oDlgAlt:End() )

   ACTIVATE MSDIALOG oDlgAlt CENTERED 

Return(.T.)
                                               
// ############################################
// Função que altera a quantidade do produto ##
// ############################################
Static Function AltGrvPrd()

   If kQuantidade == 0
      MsgAlert("Necessário informar a quantidade do produto.")
      Return(.T.)
   Endif

   aLista[oLista:nAt,05] := kQuantidade
   
   oDlgAlt:End()
   
Return(.T.)

// ########################################
// Função que imprime as etiquetas caixa ##
// ########################################
Static Function ImpEtqCaixa()

   Local nContar    := 0
   Local nQMarcados := 0
   Local lMarcados  := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private aPortas   := {"COM1","COM2","COM3","COM4","COM5","COM6","LPT1","LPT2"}
   Private cPorta

   Private oDlgPrn
   
   // ######################################################################
   // Verifica se houve marcação de pelo menos um registro para impressão ##
   // ######################################################################
   lMarcados  := .F.   
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.                                                                
          lMarcados := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcados == .F.
      MsgAlert("Nenhum produto foi marcado para impressão. Verifique!")
      Return(.T.)
   Endif                


   // ##########################################################################
   // Verifica quantos registros foram marcados. possíveis até 3 por etiqueta ##
   // ##########################################################################
   nQMarcados  := 0
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nQmarcados := nQmarcados + 1
       Endif
   Next nContar
   
   If nQmarcados > 3
      MsgAlert("Atenção! somente permitido 3 produtos por etiqueta. Verifique!")
      Return(.T.)
   Endif                

   // ####################################################################
   // Verifica se a quantidade de etiqueta a ser impressa foi informada ##
   // ####################################################################
   If nQtdEtq == 0
      MsgAlert("Quantidade de etiquetas a serem impressas não informada. Verifique!")
      Return(.T.)
   Endif                

   // ###############################################################################
   // Verifica se a quantidade do produto foi informada para os produtos marcados  ##
   // ###############################################################################
   lMarcados := .F.   

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          If aLista[nContar,05] == 0
             lMarcados := .T.
             Exit
          Endif   
       Endif
   Next nContar
   
   If lMarcados == .T.
      MsgAlert("Atenção! Existem produtos sem a informação de quantidade dos produtos. Verifique!")
      Return(.T.)
   Endif                
   
   DEFINE MSDIALOG oDlgPrn TITLE "Emissão de Etiquetas de Produtos (PCP)" FROM C(178),C(181) TO C(342),C(480) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlgPrn

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(142),C(001) PIXEL OF oDlgPrn

   @ C(040),C(005) Say "Portas de Impressão" Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgPrn

   @ C(049),C(005) ComboBox cPorta Items aPortas Size C(141),C(010) PIXEL OF oDlgPrn

   @ C(065),C(037) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgPrn ACTION( ImpEtqCx() )
   @ C(065),C(075) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPrn ACTION( oDlgPrn:End() )

   ACTIVATE MSDIALOG oDlgPrn CENTERED 

Return(.T.)

// ##################################
// Função que imprime as etiquetas ##
// ##################################
Static Function ImpEtqCx()

   // ########################
   // Impressão da Etiqueta ##
   // ########################
   MSCBPRINTER("ZEBRA",cPorta)
   MSCBCHKSTATUS(.F.)
   MSCBBEGIN(2,6,) 

         // ###################################
         //Início da Programação da Etiqueta ##
         // ###################################
        MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da progrmação
        MSCBWRITE('H15'+chr(13))
        MSCBWRITE('D11'+chr(13))

         // #############################
         // Dados da Ordem de Produção ##
         // #############################
         MSCBWRITE("491100601970105" + aLista[01,07] + CHR(13))
         MSCBWRITE("421100002450075NUMERO DA OP:" + CHR(13))
         MSCBWRITE("1Y1100001360261TF3" + CHR(13))

         // ###########################
        // Dados do Pedido de Venda ##
        // ###########################
         MSCBWRITE("491100600280105" + aLista[01,06]  + CHR(13))
          MSCBWRITE("421100000380075NUMERO DO PEDIDO:" + CHR(13))

         k_Linha_Impressa := 1

         For nContar = 1 to Len(aLista)
         
                  If aLista[nContar,01] == .F.
                        Loop
                   Endif
                        
                  // ###############################
                  // Primeiro produto da etiqueta ##
                 // ###############################
                 If k_Linha_Impressa == 1
                       MSCBWRITE("421100000090128" + aLista[nContar,02]                                                                         + CHR(13))
                       MSCBWRITE("421100001130128" + Alltrim(aLista[nContar,03])                                                           + CHR(13))
                       MSCBWRITE("431100000100150UNIDADE:"                                                                                          + CHR(13))
                       MSCBWRITE("431100000760150" + Alltrim(aLista[nContar,04])                                                           + CHR(13))
                       MSCBWRITE("431100001290150QUANTIDADE:"                                                                                   + CHR(13))
                       MSCBWRITE("431100002200150" + Transform(aLista[nContar,05], "@E 9999999.99") + CHR(13))
                       k_Linha_Impessa := k_Linha_Impressa + 1
                       Loop
                  Endif
                  
                 // ##############################
                // Segundo produto da etiqueta ##
                // ##############################
                If k_Linha_Impressa == 2
                      MSCBWRITE("421100000110179" + aLista[nContar,02]                                                                           + CHR(13))
                      MSCBWRITE("421100001150179" + Alltrim(aLista[nContar,03])                                                             + CHR(13))
                      MSCBWRITE("431100000100201UNIDADE:"                                                                                            + CHR(13))
                      MSCBWRITE("431100000780201" + aLista[nContar,04]                                                                           + CHR(13))
                      MSCBWRITE("431100001290201QUANTIDADE:"                                                                                    + CHR(13))
                      MSCBWRITE("431100002190201" + Transform(aLista[nContar,05], "@E 9999999.99")  + CHR(13))
                       k_Linha_Impessa := k_Linha_Impressa + 1
                       Loop
                 Endif
                      
                // ###############################
                // Terceiro produto da etiqueta ##
                // ###############################
               If k_Linha_Impessa  == 3
                    MSCBWRITE("421100000120229" + aLista[nContar,02]                                                                           + CHR(13))
                    MSCBWRITE("421100001160229" + Alltrim(aLista[nContar,03])                                                             + CHR(13))
                    MSCBWRITE("431100000100251UNIDADE:"                                                                                            + CHR(13))
                    MSCBWRITE("431100000770251" + aLista[nContar,04]                                                                           + CHR(13))
                    MSCBWRITE("431100001280251QUANTIDADE:"                                                                                    + CHR(13))
                    MSCBWRITE("431100002210251" + Transform(aLista[nContar,05], "@E 9999999.99")  + CHR(13))
                    Exit
                    
              Endif
  
         Next nContar
         
         // #################################
         // Dados do Cabeçalho da Etiqueta ##
         // #################################
         MSCBWRITE("421100001730030CLIIENTE:"                         + CHR(13))
         MSCBWRITE("491100400120057" + Substr(aLista[01,08],01,35)     + CHR(13))
         MSCBWRITE("1X1100000070016b0093038700020002"    + CHR(13))
         MSCBWRITE("1X1100000070059l00020386"                         + CHR(13))
         MSCBWRITE("1X1100001670060l00490002"                         + CHR(13))

         // ######################
         // Finaliza a etiqueta ##
         // ######################
         MSCBWRITE("^01" + CHR(13))
         MSCBWRITE("Q"  + Strzero(nQtdEtq,4) + CHR(13))
         MSCBWRITE(chr(002)+"E"+ chr(13))
         MSCBEND()
         MSCBCLOSEPRINTER()

Return(.T.)

/*


                  MSCBWRITE(chr(002)+'L'+chr(13))           //inicio da progrmação
                  MSCBWRITE('H15'+chr(13))
                  MSCBWRITE('D11'+chr(13))

                   MSCBWRITE("491100601970105006270.01.001" + CHR(13))
                   MSCBWRITE("421100002450075NUMERO DA OP:" + CHR(13))
                   MSCBWRITE("1Y1100001360261TF3" + CHR(13))

                   MSCBWRITE("42110000009012802006909240000001" + CHR(13))
                   MSCBWRITE("421100000380075NUMERO DO PEDIDO:" + CHR(13))
                   MSCBWRITE("421100001130128ET 100X150X01 EP S2045/105 3. BRANCO" + CHR(13))
                   MSCBWRITE("431100000100150UNIDADE:" + CHR(13))
                   MSCBWRITE("431100000760150RL" + CHR(13))
                   MSCBWRITE("431100001290150QUANTIDADE:" + CHR(13))
                   MSCBWRITE("491100600280105009159-01" + CHR(13))
                   MSCBWRITE("4311000022001501000" + CHR(13))
                   MSCBWRITE("42110000011017902006909240000001" + CHR(13))
                   MSCBWRITE("421100001150179ET 100X150X01 EP S2045/105 3. BRANCO" + CHR(13))
                   MSCBWRITE("431100000100201UNIDADE:" + CHR(13))
                   MSCBWRITE("431100000780201RL" + CHR(13))
                   MSCBWRITE("431100001290201QUANTIDADE:" + CHR(13))
                   MSCBWRITE("4311000021902011000" + CHR(13))
                   MSCBWRITE("421100000120229007777" + CHR(13))
                   MSCBWRITE("421100001160229RIBBON APXFH 110X450" + CHR(13))
                   MSCBWRITE("431100000100251UNIDADE:" + CHR(13))
                   MSCBWRITE("431100000770251RL" + CHR(13))
                   MSCBWRITE("431100001280251QUANTIDADE:" + CHR(13))
                   MSCBWRITE("4311000022102511000" + CHR(13))
                   MSCBWRITE("421100001730030CLIIENTE:" + CHR(13))
                   MSCBWRITE("491100400120057LIT COMERCIO VAREJISTA DE ARTIGOS " + CHR(13))
                   MSCBWRITE("1X1100000070016b0093038700020002" + CHR(13))
                   MSCBWRITE("1X1100000070059l00020386" + CHR(13))
                   MSCBWRITE("1X1100001670060l00490002" + CHR(13))


                   MSCBWRITE("^01" + CHR(13))
                   MSCBWRITE("Q0001" + CHR(13))
                   MSCBWRITE(chr(002)+"E"+ chr(13))
                   MSCBEND()
                   MSCBCLOSEPRINTER()

*/