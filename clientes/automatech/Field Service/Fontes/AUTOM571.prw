#INCLUDE "protheus.ch"  
#INCLUDE "jpeg.ch"    

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM571.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 17/05/2017                                                            ## 
// Objetivo..: Programa que populça o grid da tela de Posição de Peças da OS.        ##
// ####################################################################################

User Function AUTOM571(kFilial, kServico, kCliente, kLoja)

   Local lChumba  := .F.
   Local cSql     := ""
   Local cServico := kservico
   Local cCliente := kCliente + "." + kLoja + " - " + POSICIONE("SA1",1,XFILIAL("SA1") + kCliente + kLoja,"A1_NOME")

   Local cMemo1	  := ""
   Local oMemo1

   Local oGet1
   Local oGet2

   Private aBrowse   := {}

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

   // ################################################################
   // Pesquisa requisição de peças para a os informada no parâmetro ##
   // ################################################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZZ_FILIAL    ,"
   cSql += "       ZZZ_NUMOS     ,"	
   cSql += "       ZZZ_TECNIC    ,"	
   cSql += "       AA1.AA1_NOMTEC,"  
   cSql += "       AA1.AA1_LOCAL ,"
   cSql += "       ZZZ_EMISSA    ,"	
   cSql += "       ZZZ_ITAB8     ,"
   cSql += "       ZZZ_ITEM	     ,"
   cSql += "       ZZZ_PRODUT    ,"	
   cSql += "       SB1.B1_DESC + SB1.B1_DAUX AS DESCRICAO,"
   cSql += "       ZZZ_LOCAL     ,"
   cSql += "       ZZZ_LOCALI    ,"
   cSql += "       ZZZ_NUMSER    ,"
   cSql += "       ZZZ_QUANT     ,"
   cSql += "       ZZZ_QTDORI    ,"
   cSql += "       ZZZ_SALDO     ,"
   cSql += "       ZZZ_STATUS    ,"
   cSql += "       ZZZ_DOCSD3    ,"
   cSql += "       ZZZ_NUMPV     ,"
   cSql += "       ZZZ_NUMFL     ,"
   cSql += "       ZZZ_NOTA	     ,"
   cSql += "       ZZZ_SERIE      "
   cSql += "  FROM " + RetSqlName("ZZZ") + " ZZZ, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("AA1") + " AA1  "
   cSql += "  WHERE ZZZ.ZZZ_FILIAL = '" + Alltrim(kFilial)  + "'"
   cSql += "    AND ZZZ.ZZZ_NUMOS  = '" + Alltrim(kServico) + "'"
   cSql += "    AND ZZZ.D_E_L_E_T_ = ''"
   cSql += "    AND SB1.B1_COD     = ZZZ.ZZZ_PRODUT"
   cSql += "    AND SB1.D_E_L_E_T_ = ''"
   cSql += "    AND AA1.AA1_CODTEC = ZZZ.ZZZ_TECNIC"
   cSql += "    AND AA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   T_CONSULTA->( DbGoTop() )

   WHILE !T_CONSULTA->( EOF() )

      Do Case
         Case T_CONSULTA->ZZZ_STATUS == "A"
              cLegenda := "1"
              kQuanti   := T_CONSULTA->ZZZ_QUANT
              kAtendido := 0
              kSaldo    := T_CONSULTA->ZZZ_SALDO
         Case T_CONSULTA->ZZZ_STATUS == "P"
              cLegenda := "3"
              kQuanti   := T_CONSULTA->ZZZ_QUANT
              kAtendido := T_CONSULTA->ZZZ_QUANT - T_CONSULTA->ZZZ_SALDO
              kSaldo    := T_CONSULTA->ZZZ_SALDO
         Case T_CONSULTA->ZZZ_STATUS == "E"
              cLegenda := "9"              
              kQuanti   := T_CONSULTA->ZZZ_QUANT
              kAtendido := T_CONSULTA->ZZZ_QUANT
              kSaldo    := 0
      EndCase
           
      aAdd( aBrowse, { cLegenda               ,;
                       T_CONSULTA->ZZZ_PRODUT ,;
                       T_CONSULTA->DESCRICAO  ,;
                       kQuanti                ,;
                       kAtendido              ,;
                       kSaldo                 ,;
                       T_CONSULTA->ZZZ_TECNIC ,;
                       T_CONSULTA->AA1_NOMTEC ,;
                       T_CONSULTA->AA1_LOCAL  })

      T_CONSULTA->( DbSkip() )

   ENDDO         

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "" })      
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Posicição de Atendimento de Requisições de Peças da OS" FROM C(178),C(181) TO C(541),C(814) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg
   @ C(168),C(005) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(168),C(067) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(168),C(171) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(309),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "OS Nº"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(047) Say "Cliente"                    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(018) Say "REQUISIÇÃO ABERTA"          Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(080) Say "REQ. ATENDIDA PARCIALMENTE" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(184) Say "REQUISIÇÃO ATENDIDA"        Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cServico Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(045),C(047) MsGet oGet2 Var cCliente Size C(265),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(166),C(275) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 078 , 006, 393, 130,,{'L'                      ,; // 01 
                                                    'Produto'                ,; // 02
                                                    'Descrição dos Produtos' ,; // 03
                                                    'Qtd Solicitada'         ,; // 04
                                                    'Qtd.Atendida'           ,; // 05
                                                    'Saldo'                  ,; // 06
                                                    'Técnico'                ,; // 07
                                                    'Nome dos Técnicos'      ,; // 08
                                                    'Armazém'               },; // 09
                                                    {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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
                         aBrowse[oBrowse:nAt,09]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)