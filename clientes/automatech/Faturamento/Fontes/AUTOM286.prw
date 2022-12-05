#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM286.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 02/04/2015                                                          *
// Objetivo..: Programa que atualiza o passado com os dados de Vendedores, Tipo de *
//             Clientes, Forma de pagamento e grupo de produtos. Estes campos  são *
//             utilizados no BI.                                                   *
//**********************************************************************************

User Function AUTOM286()

   Local lChumba      := .F.

   Private oDlg
   Private cTRegistro := 0
   Private cTProcessa := 0

   Private oGet1
   Private oGet2

   U_AUTOM628("AUTOM286")
   
   DEFINE MSDIALOG oDlg TITLE "Dados BI" FROM C(178),C(181) TO C(330),C(416) PIXEL

   @ C(050),C(005) Say "Total Registros"       Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(062),C(005) Say "Registros Processados" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(049),C(062) MsGet oGet1 Var cTRegistro  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(061),C(062) MsGet oGet2 Var cTProcessa  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(005),C(005) Button "Atualiza a Tabela F2 - NF de Venda"       Size C(108),C(012) PIXEL OF oDlg ACTION( AtuNFiscal() )
   @ C(018),C(005) Button "Atualiza a Tabela D2 - Produtos NF Venda" Size C(108),C(012) PIXEL OF oDlg ACTION( AtuProdutos() )
   @ C(032),C(005) Button "Voltar"                                   Size C(108),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que atualiza o passado ref. cabeçalho de notas fiscais
Static Function AtuNFiscal()

   Local cSql        := ""
   Local nRegua      := 0
   Local nRegistros  := 0
   Local nProcessado := 0
   
   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT SF2.F2_FILIAL ,"                 + chr(13)
   cSql += "       SF2.F2_DOC    ,"                 + chr(13)
   cSql += "	   SF2.F2_SERIE  ,"                 + chr(13)
   cSql += "	   SF2.F2_CLIENTE,"                 + chr(13)
   cSql += " 	   SF2.F2_LOJA   ,"                 + chr(13)
   cSql += "       SF2.F2_FORMUL ,"                 + chr(13)
   cSql += "       SF2.F2_TIPO   ,"                 + chr(13)
   cSql += "	   SA1.A1_PESSOA ,"                 + chr(13)
   cSql += "	   SA3.A3_ZTBI   ,"                 + chr(13)
   cSql += "	   SF2.F2_ZTVD   ,"                 + chr(13)
   cSql += "	   SF2.F2_ZTCL    "                 + chr(13)
   cSql += "  FROM " + RetSqlName("SF2") + " SF2, " + chr(13)
   cSql += "       " + RetSqlName("SA1") + " SA1, " + chr(13)
   cSql += "	   " + RetSqlName("SA3") + " SA3  " + chr(13)
   cSql += " WHERE SF2.D_E_L_E_T_ = ''"             + chr(13)
   cSql += "   AND SA1.A1_COD     = SF2.F2_CLIENTE" + chr(13)
   cSql += "   AND SA1.A1_LOJA    = SF2.F2_LOJA   " + chr(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''            " + chr(13)
   cSql += "   AND SA3.A3_COD     = SF2.F2_VEND1  " + chr(13)
   cSql += "   AND SA3.D_E_L_E_T_ = ''            " + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   Count To nRegistros

   cTRegistro := nRegistros
   oget1:Refresh()

   nRegua := 0

   T_NOTAS->( DbGoTop() )
  
   WHILE !T_NOTAS->( EOF() )
  
      nRegua := nRegua + 1
      cTProcessa := nRegua
      oGet2:Refresh()

      // Pesquisa e atualiza os dados do cabeçalho de nota fiscal de Saída (Vendas)
      DbSelectArea("SF2")
      DbSetOrder(1)
      If DbSeek(T_NOTAS->F2_FILIAL + T_NOTAS->F2_DOC + T_NOTAS->F2_SERIE + T_NOTAS->F2_CLIENTE + T_NOTAS->F2_LOJA + T_NOTAS->F2_FORMUL + T_NOTAS->F2_TIPO)
         RecLock("SF2",.F.)
         F2_ZTVD := T_NOTAS->A3_ZTBI
         F2_ZTCL := T_NOTAS->A1_PESSOA
         MsUnLock()              
      Endif
      
      T_NOTAS->( DbSkip() )
      
   ENDDO

   MsgAlert("Atualização tabela de Notas Fiscais realizada com sucesso.")
    
Return(.T.)

// Função que atualiza o passado ref. a tabela de produtos
Static Function AtuProdutos()

   Local cSql        := ""
   Local nRegua      := 0
   Local nRegistros  := 0
   Local nProcessado := 0

   // Pesquisa os produtos para atualização dos campos de dados do BI
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT SD2.D2_FILIAL ,"                   + chr(13)
   cSql += "       SD2.D2_DOC    ,"                   + chr(13)
   cSql += "       SD2.D2_SERIE  ,"                   + chr(13)
   cSql += "       SD2.D2_FORMUL ,"                   + chr(13)
   cSql += "       SD2.D2_TIPO   ,"                   + chr(13)
   cSql += " 	   SD2.D2_CLIENTE,"                   + chr(13)
   cSql += " 	   SD2.D2_LOJA   ,"                   + chr(13)
   cSql += " 	   SD2.D2_PEDIDO ,"                   + chr(13)
   cSql += " 	  (SELECT SE4.E4_FORMA"               + chr(13)
   cSql += "         FROM " + RetSqlName("SF2") + " SF2, " + chr(13)
   cSql	+= "	          " + RetSqlName("SE4") + " SE4  " + chr(13)
   cSql += "        WHERE SF2.F2_FILIAL  = SD2.D2_FILIAL " + chr(13)
   cSql += "          AND SF2.F2_DOC     = SD2.D2_DOC    " + chr(13)
   cSql	+= "	      AND SF2.F2_SERIE   = SD2.D2_SERIE  " + chr(13)
   cSql	+= "	      AND SF2.F2_CLIENTE = SD2.D2_CLIENTE" + chr(13)
   cSql	+= "	      AND SF2.F2_LOJA    = SD2.D2_LOJA   " + chr(13)
   cSql	+= "	      AND SF2.D_E_L_E_T_ = ''            " + chr(13)
   cSql	+= "	      AND SE4.E4_CODIGO  = SF2.F2_COND   " + chr(13)
   cSql	+= "	      AND SE4.D_E_L_E_T_ = '') AS FORMA, " + chr(13)
   cSql += " 	   SD2.D2_COD    ,"                   + chr(13)
   cSql += "       SD2.D2_ITEM   ,"                   + chr(13)
   cSql += " 	   SB1.B1_GRUPO  ,"                   + chr(13)
   cSql += " 	   SBM.BM_ZPBI   ,"                   + chr(13)
   cSql += "       SD2.D2_ZTGP    "                   + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " SD2, "   + chr(13)
   cSql += "       " + RetSqlName("SB1") + " SB1, "   + chr(13)
   cSql += "       " + RetSqlName("SBM") + " SBM  "   + chr(13)
   cSql += " WHERE SD2.D_E_L_E_T_ = ''          "     + chr(13)
   cSql += "   AND SB1.B1_COD     = SD2.D2_COD  "     + chr(13)
   cSql += "   AND SB1.D_E_L_E_T_ = ''          "     + chr(13)
   cSql += "   AND SBM.BM_GRUPO   = SB1.B1_GRUPO"     + chr(13)
   cSql += "   AND SBM.D_E_L_E_T_ = ''          "     + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
   
//   Count To nRegistros

//   cTRegistro := nRegistros
//   oget1:Refresh()

   nRegua := 0

   T_PRODUTOS->( DbGoTop() )
  
   WHILE !T_PRODUTOS->( EOF() )
  
//      nRegua := nRegua + 1
//      cTProcessa := nRegua
//      oGet2:Refresh()

      // Atualiza o campo F2_ZFPG - Forma de Pagamento da Transação de Venda
      DbSelectArea("SF2")
      DbSetOrder(1)
      If DbSeek(T_PRODUTOS->D2_FILIAL + T_PRODUTOS->D2_DOC + T_PRODUTOS->D2_SERIE + T_PRODUTOS->D2_CLIENTE + T_PRODUTOS->D2_LOJA + T_PRODUTOS->D2_FORMUL + T_PRODUTOS->D2_TIPO)
         RecLock("SF2",.F.)
         If Alltrim(T_PRODUTOS->FORMA) == "BOL"
            F2_ZFPG := "1"
         Else
            F2_ZFPG := "2"
         Endif
         MsUnLock()              
      Endif

      // Atualiza o campo D2_ZTGP - Tipo Grupo de Produtos
//      DbSelectArea("SD2")
//      DbSetOrder(3)
//      If DbSeek(T_PRODUTOS->D2_FILIAL + T_PRODUTOS->D2_DOC + T_PRODUTOS->D2_SERIE + T_PRODUTOS->D2_CLIENTE + T_PRODUTOS->D2_LOJA + T_PRODUTOS->D2_COD + T_PRODUTOS->D2_ITEM)
//         RecLock("SD2",.F.)
//         D2_ZTGP := T_PRODUTOS->BM_ZPBI
//         MsUnLock()              
//      Endif

      T_PRODUTOS->( DbSkip() )
      
   ENDDO   
      
   MsgAlert("Atualização tabela de Produtos realizada com sucesso.")

Return(.T.)