#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

#define SW_HIDE             0 // Escondido
#define SW_SHOWNORMAL       1 // Normal
#define SW_NORMAL           1 // Normal
#define SW_SHOWMINIMIZED    2 // Minimizada
#define SW_SHOWMAXIMIZED    3 // Maximizada
#define SW_MAXIMIZE         3 // Maximizada
#define SW_SHOWNOACTIVATE   4 // Na Ativação
#define SW_SHOW             5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE         6 // Minimizada
#define SW_SHOWMINNOACTIVE  7 // Minimizada
#define SW_SHOWNA           8 // Esconde a barra de tarefas
#define SW_RESTORE          9 // Restaura a posição anterior
#define SW_SHOWDEFAULT      10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE    11// Força minimização independente da aplicação executada
#define SW_MAX              11// Maximizada

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM650.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 20/10/2017                                                          ##
// Objetivo..: Programa que permite usuário trocar o vencimento real de tírulos    ##
//             bem como incluir valor de Juros e Multa                             ##
// ##################################################################################

User Function AUTOM650()

   MsgRun("Aguarde! Abrindo  programa Alteração de Vencimento ...", "Programa: AUTOM650",{|| xAUTOM650() })

Return(.T.)

// #####################################
// Função que abre a tela do programa ##
// #####################################
Static Function xAUTOM650()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo3

   Private aStatus   := {"1 - Abertos", "2 - Baixados", "3 - Todos"}
   Private cComboBx1

   Private cInicial  := Ctod("  /  /    ")
   Private cFinal  	 := Ctod("  /  /    ")
   Private cCliente  := Space(06)
   Private cLoja	 := Space(03)
   Private cNome	 := Space(60)
   Private cTitulo	 := Space(09)
   Private cNota	 := Space(09)
   Private cPrefixo  := Space(03)
 
   Private aEmpresas := U_AUTOM539(1, "")
   Private aFiliais  := U_AUTOM539(2, cEmpAnt)
                        
   Private cComboBx2
   Private cComboBx3
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   Private oDlg

   Private aListBox1 := {}
   Private aListBox2 := {}
   Private oListBox1
   Private oListBox2

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

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private aBrowse   := {}
   Private oBrowse

   Private aLista    := {}
   Private oLista

   DEFINE MSDIALOG oDlg TITLE "Contas a Receber - Negociação de Vencimentos" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(211),C(266) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(307) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(193),C(002) GET oMemo3 Var cMemo3 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Venctº Inicial"                 Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(050) Say "Venctº Final"                   Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(095) Say "Cliente"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(271) Say "Título"                         Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(306) Say "NFiscal"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(340) Say "Ser/Pfx"                        Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(364) Say "Tipo"                           Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(115),C(005) Say "Títulos do Cliente selecionado" Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(278) Say "Em Aberto"                      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(320) Say "Baixados"                       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(147) Say "Empresas"                       Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(240) Say "Filiais"                        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(016),C(147) ComboBox cComboBx2 Items aEmpresas   Size C(088),C(010)                              PIXEL OF oDlg ON CHANGE ALTERACOMBO()
   @ C(016),C(240) ComboBox cComboBx3 Items aFiliais    Size C(096),C(010)                              PIXEL OF oDlg
   @ C(046),C(005) MsGet    oGet1     Var   cInicial    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(050) MsGet    oGet2     Var   cFinal      Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(095) MsGet    oGet3     Var   cCliente    Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(046),C(127) MsGet    oGet4     Var   cLoja       Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( cNome := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_NOME") )
   @ C(046),C(147) MsGet    oGet5     Var   cNome       Size C(118),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(271) MsGet    oGet6     Var   cTitulo     Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(306) MsGet    oGet7     Var   cNota       Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(340) MsGet    oGet8     Var   cPrefixo    Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(364) ComboBox cComboBx1 Items aStatus     Size C(036),C(010)                              PIXEL OF oDlg

   @ C(043),C(403) Button "Pesquisar"       Size C(040),C(012) PIXEL OF oDlg ACTION( PESSCRBOL() )
   @ C(210),C(005) Button "Marca Todos"     Size C(056),C(012) PIXEL OF oDlg ACTION( MrcRegParc(1) )
   @ C(210),C(065) Button "Desmarca Todos"  Size C(056),C(012) PIXEL OF oDlg ACTION( MrcRegParc(0) )
   @ C(210),C(140) Button "Vctº/Juro/Multa" Size C(055),C(012) PIXEL OF oDlg ACTION( AltVencJM() )
   @ C(210),C(200) Button "Gerar Boleto"    Size C(055),C(012) PIXEL OF oDlg ACTION( EnviaBolSant() )

   @ C(210),C(461) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 075 , 005, 633, 070,,{'Cliente'               ,;
                                                    'Loja'                  ,;
                                                    'Descrição dos Clientes' + Space(100),;
                                                    'Município'             ,;
                                                    'Estado'                ,;
                                                    'Telefone'              ,;
                                                    'CNPJ/CPF'              ,;
                                                    'Imprime Boleto' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;   
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;      
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;                         
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08]}}

   oBrowse:bLDblClick := {|| BuscaParcCli() } 
   
   aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   // Lista com os produtos do pedido selecionado
   @ 160,005 LISTBOX oLista FIELDS HEADER "Mrc"            ,; // 01
                                          "Leg"            ,; // 02
                                          "Título"         ,; // 03
                                          "Prefixo"        ,; // 04
                                          "Parcela"        ,; // 05
                                          "Tipo"           ,; // 06
                                          "Ped.Venda"      ,; // 07
                                          "Emissão"        ,; // 08
                                          "Vencimento"     ,; // 09
                                          "Vct Real"       ,; // 10
                                          "Baixa"          ,; // 11
                                          "Valor"          ,; // 12
                                          "Juros"          ,; // 13
                                          "Multa"          ,; // 14
                                          "Nosso Número"   ,; // 15
                                          "Nº Borderô"     ,; // 16
                                          "Data Borderô"   ,; // 17
                                          "Saldo a Receber" ; // 18
                                          PIXEL SIZE 633,105 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                             If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                             If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                             If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                             If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                             If(aLista[oLista:nAt,02] == "5", oAzul     ,;                         
                             If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                             If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                             If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                             If(aLista[oLista:nAt,02] == "9", oPink     ,;
                             If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oLista:nAt,03],;
          					   aLista[oLista:nAt,04],;
          					   aLista[oLista:nAt,05],;
          					   aLista[oLista:nAt,06],;
          					   aLista[oLista:nAt,07],;          					             					   
         	        	       aLista[oLista:nAt,08],;
         	        	       aLista[oLista:nAt,09],;
         	        	       aLista[oLista:nAt,10],;
         	        	       aLista[oLista:nAt,11],;
         	        	       aLista[oLista:nAt,12],;
         	        	       aLista[oLista:nAt,13],;
         	        	       aLista[oLista:nAt,14],;
         	        	       aLista[oLista:nAt,15],;
         	        	       aLista[oLista:nAt,16],;
         	        	       aLista[oLista:nAt,17],;         	        	                	        	                	        	       
         	        	       aLista[oLista:nAt,18]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx2,01,02) )
   @ C(016),C(240) ComboBox cComboBx3 Items aFiliais Size C(096),C(010) PIXEL OF oDlg

Return(.T.)

// ###########################################################
// Função que pesquisa dados conforme parâmetros informados ##
// ###########################################################
Static Function PESSCRBOL()

   MsgRun("Aguarde! Pesquisando Títulos SCR ...", "Negociação de Títulos",{|| xPESSCRBOL() })

Return(.T.)

// ###########################################################
// Função que pesquisa dados conforme parâmetros informados ##
// ###########################################################
Static Function xPESSCRBOL()

   Local cSql := ""
   
   If cInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial de vencimento não informada para pesquisa. Verifique!")
      Return(.T.)
   Endif

   If cFinal == Ctod("  /  /    ")
      MsgAlert("Data inicial de vencimento não informada para pesquisa. Verifique!")
      Return(.T.)
   Endif

   aBrowse := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SE1.E1_CLIENTE,"
   cSql += "       SE1.E1_LOJA   ,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "       SA1.A1_CGC    ,"
   cSql += "       SA1.A1_BOLET  ,"
   cSql += "       SA1.A1_MUN    ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_DDD    ,"
   cSql += "       SA1.A1_TEL     "
   cSql += "  FROM SE1" + Substr(cComboBx2,01,02) + "0 SE1, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SE1.E1_VENCREA >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"
   cSql += "   AND SE1.E1_VENCREA <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"
   cSql += "   AND SE1.E1_FILORIG  = '" + Substr(cComboBx3,01,02) + "'"

   If Empty(Alltrim(cCliente))
   Else
      cSql += "   AND SE1.E1_CLIENTE = '" + Alltrim(cCliente) + "'"
      cSql += "   AND SE1.E1_LOJA    = '" + Alltrim(cLoja)    + "'"
   Endif
      
   If Empty(Alltrim(cTitulo))
   Else
      cSql += "   AND SE1.E1_NUM = '" + Alltrim(cTitulo) + "'"
   Endif   

   If Empty(Alltrim(cNota))
   Else
      cSql += "   AND SE1.E1_NUM = '" + Alltrim(cNota) + "'"
   Endif   

   If Empty(Alltrim(cPrefixo))
   Else
      cSql += "   AND SE1.E1_PREFIXO = '" + Alltrim(cPrefixo) + "'"
   Endif   

   Do Case
      Case Substr(cComboBx1,01,01) == "1"
           cSql += " AND SE1.E1_SALDO <> 0"
         Case Substr(cComboBx1,01,01) == "2"
           cSql += " AND SE1.E1_SALDO = 0"
   EndCase

   cSql += "   AND SE1.D_E_L_E_T_  = ''            "
   cSql += "   AND SA1.A1_COD      = SE1.E1_CLIENTE"
   cSql += "   AND SA1.A1_LOJA     = SE1.E1_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_  = ''            "
   cSql += " GROUP BY SE1.E1_CLIENTE, SE1.E1_LOJA, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_BOLET, SA1.A1_MUN, SA1.A1_EST, SA1.A1_DDD, SA1.A1_TEL"
   cSql += " ORDER BY SA1.A1_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      ktelefone := "(" + Alltrim(T_CONSULTA->A1_DDD) + ") " + Alltrim(T_CONSULTA->A1_TEL)

      If Len(Alltrim(T_CONSULTA->A1_CGC)) == 14
         kCNPJ := Substr(T_CONSULTA->A1_CGC,01,02) + "." + ;
                  Substr(T_CONSULTA->A1_CGC,03,03) + "." + ;
                  Substr(T_CONSULTA->A1_CGC,06,03) + "/" + ;
                  Substr(T_CONSULTA->A1_CGC,09,04) + "." + ;
                  Substr(T_CONSULTA->A1_CGC,13,02)
      Else
         kCNPJ := Substr(T_CONSULTA->A1_CGC,01,03) + "." + ;
                  Substr(T_CONSULTA->A1_CGC,04,03) + "." + ;
                  Substr(T_CONSULTA->A1_CGC,07,03) + "-" + ;
                  Substr(T_CONSULTA->A1_CGC,10,02)
      Endif
   
      aAdd( aBrowse, { T_CONSULTA->E1_CLIENTE,;
                       T_CONSULTA->E1_LOJA   ,;
                       T_CONSULTA->A1_NOME   ,;
                       T_CONSULTA->A1_MUN    ,;
                       T_CONSULTA->A1_EST    ,;
                       kTelefone             ,;
                       kCNPJ                 ,;
                       T_CONSULTA->A1_BOLET  })
      
      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "" })
      MsgAlert("Não existem dados a serem visualizados para esta consulta.")
   Endif
      
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;   
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;      
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05],;   
                         aBrowse[oBrowse:nAt,06],;      
                         aBrowse[oBrowse:nAt,07],;      
                         aBrowse[oBrowse:nAt,08]}}

   // ###################################################################################################
   // Envia para a função que carrega o lista com as parcelas das notas fiscais do cliente selecionado ##
   // ###################################################################################################
   BuscaParcCli()
   
Return(.T.)
   
// ###########################################################
// Função que pesquisa dados conforme parâmetros informados ##
// ###########################################################
Static Function BuscaParcCli()

   Local cSql := ""

   aLista := {}
   
   If Select("T_PARCELAS") > 0
      T_PARCELAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SE1.E1_NUM    ,"
   cSql += "       SE1.E1_PREFIXO,"
   cSql += "	   SE1.E1_PARCELA,"
   cSql += "	   SE1.E1_TIPO   ,"
   cSql += "	   SE1.E1_PEDIDO ,"
   cSql += "	   SE1.E1_EMISSAO,"
   cSql += "	   SE1.E1_VENCTO ,"
   cSql += "	   SE1.E1_VENCREA,"
   cSql += "	   SE1.E1_BAIXA  ,"
   cSql += "	   SE1.E1_VALOR  ,"
   cSql += "	   SE1.E1_JUROS  ,"
   cSql += "	   SE1.E1_MULTA  ,"
   cSql += "	   SE1.E1_NUMBCO ,"
   cSql += "	   SE1.E1_NUMBOR ,"
   cSql += "	   SE1.E1_DATABOR,"
   cSql += "	   SE1.E1_SALDO   "
   cSql += "  FROM SE1" + Substr(cComboBx2,01,02) + "0 SE1 "

   If Empty(Alltrim(cCliente))
      cSql += " WHERE SE1.E1_CLIENTE = '" + Alltrim(aBrowse[oBrowse:nAt,01]) + "'"
      cSql += "   AND SE1.E1_LOJA    = '" + Alltrim(aBrowse[oBrowse:nAt,02]) + "'"
   Else
      cSql += " WHERE SE1.E1_CLIENTE = '" + Alltrim(cCliente) + "'"
      cSql += "   AND SE1.E1_LOJA    = '" + Alltrim(cLoja)    + "'"
   Endif      

   cSql += "   AND SE1.E1_FILORIG = '" + Substr(cComboBx3,01,02) + "'"
   cSql += "   AND SE1.D_E_L_E_T_ = ''"
   cSql += "   AND SE1.E1_VENCREA >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"
   cSql += "   AND SE1.E1_VENCREA <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"

   If Empty(Alltrim(cTitulo))
   Else
      cSql += " AND SE1.E1_NUM = '" + Alltrim(cTitulo) + "'"
   Endif
      
   If Empty(Alltrim(cNota))
   Else
      cSql += " AND SE1.E1_NUM = '" + Alltrim(cTitulo) + "'"
   Endif

   If Empty(Alltrim(cPrefixo))
   Else
      cSql += " AND SE1.E1_PREFIXO = '" + Alltrim(cPrefixo) + "'"
   Endif

   cSql += " ORDER BY SE1.E1_VENCREA, SE1.E1_NUM, SE1.E1_PREFIXO"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARCELAS", .T., .T. )
   
   T_PARCELAS->( DbGoTop() )
   
   WHILE !T_PARCELAS->( EOF() )

      Do Case
         Case Substr(cComboBx1,01,01) == "1"
              If T_PARCELAS->E1_SALDO == 0
                 T_PARCELAS->( DbSkip() )
                 LOOP
              Endif
         Case Substr(cComboBx1,01,01) == "2"
              If T_PARCELAS->E1_SALDO <> 0
                 T_PARCELAS->( DbSkip() )
                 LOOP
              Endif
      EndCase        

      kLegenda := IIF(T_PARCELAS->E1_SALDO == 0, "8", "2")
      kEmissao := Substr(T_PARCELAS->E1_EMISSAO,07,02) + "/" + Substr(T_PARCELAS->E1_EMISSAO,05,02) + "/" + Substr(T_PARCELAS->E1_EMISSAO,01,04)
      kVencto  := Substr(T_PARCELAS->E1_VENCTO ,07,02) + "/" + Substr(T_PARCELAS->E1_VENCTO ,05,02) + "/" + Substr(T_PARCELAS->E1_VENCTO ,01,04)
      kVenctor := Substr(T_PARCELAS->E1_VENCREA,07,02) + "/" + Substr(T_PARCELAS->E1_VENCREA,05,02) + "/" + Substr(T_PARCELAS->E1_VENCREA,01,04)
      kBaixa   := Substr(T_PARCELAS->E1_BAIXA  ,07,02) + "/" + Substr(T_PARCELAS->E1_BAIXA  ,05,02) + "/" + Substr(T_PARCELAS->E1_BAIXA  ,01,04)
      kBordero := Substr(T_PARCELAS->E1_DATABOR,07,02) + "/" + Substr(T_PARCELAS->E1_DATABOR,05,02) + "/" + Substr(T_PARCELAS->E1_DATABOR,01,04)
         
      aAdd( aLista, {.F.                   ,; // 01
                     kLegenda              ,; // 02
                     T_PARCELAS->E1_NUM    ,; // 03
                     T_PARCELAS->E1_PREFIXO,; // 04
                     T_PARCELAS->E1_PARCELA,; // 05
                     T_PARCELAS->E1_TIPO   ,; // 06
                     T_PARCELAS->E1_PEDIDO ,; // 07
                     kEmissao              ,; // 08
                     kVencto               ,; // 09
                     kVenctor              ,; // 10
                     kBaixa                ,; // 11
                     T_PARCELAS->E1_VALOR  ,; // 12
                     T_PARCELAS->E1_JUROS  ,; // 13
                     T_PARCELAS->E1_MULTA  ,; // 14
                     T_PARCELAS->E1_NUMBCO ,; // 15
                     T_PARCELAS->E1_NUMBOR ,; // 16
                     kBordero              ,; // 17
                     T_PARCELAS->E1_SALDO  }) // 18

      T_PARCELAS->( DbSkip() )                      
   
   ENDDO
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "2", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif   

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                             If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                             If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                             If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                             If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                             If(aLista[oLista:nAt,02] == "5", oAzul     ,;                                                                    
                             If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                             If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                             If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                             If(aLista[oLista:nAt,02] == "9", oPink     ,;
                             If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oLista:nAt,03],;
          					   aLista[oLista:nAt,04],;
          					   aLista[oLista:nAt,05],;
          					   aLista[oLista:nAt,06],;
          					   aLista[oLista:nAt,07],;          					             					   
         	        	       aLista[oLista:nAt,08],;
         	        	       aLista[oLista:nAt,09],;
         	        	       aLista[oLista:nAt,10],;
         	        	       aLista[oLista:nAt,11],;
         	        	       aLista[oLista:nAt,12],;
         	        	       aLista[oLista:nAt,13],;
         	        	       aLista[oLista:nAt,14],;
         	        	       aLista[oLista:nAt,15],;
         	        	       aLista[oLista:nAt,16],;
         	        	       aLista[oLista:nAt,17],;         	        	                	        	                	        	       
         	        	       aLista[oLista:nAt,18]}}

   oLista:Refresh()

Return(.T.)

// ###########################################
// Função que marca e desmarca os registros ##
// ###########################################
Static Function MrcRegParc(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)

// ####################################################################
// Função que altera vencimento, juros e multa do título selecionado ##
// ####################################################################
Static Function AltVencJM()

   Local lChumba := .F.
   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private kCliente := aBrowse[oBrowse:nAt,01] + "." + aBrowse[oBrowse:nAt,02] + " - " + aBrowse[oBrowse:nAt,03]
   Private kTitulo  := "Título: " + aLista[oLista:nAt,03] + "Prefixo: " + aLista[oLista:nAt,04] + " Parcela: " + aLista[oLista:nAt,05]
   Private kVencto  := aLista[oLista:nAt,09]
   Private kVenctoR	:= Ctod(aLista[oLista:nAt,10])
   Private kVenctoV	:= Ctod(aLista[oLista:nAt,10])
   Private kJuros	:= aLista[oLista:nAt,13]
   Private kMulta	:= aLista[oLista:nAt,14]
   Private xDias    := 0
   Private xTpDias  := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private oDlgV

   // ####################################################################################
   // Verifica se o usuário logado possui permissão de acesso a alteração de vencimento ##
   // ####################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_UVE1, ZZ4_UVE2 FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cUsua01 := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_UVE1)), Space(250), T_PARAMETROS->ZZ4_UVE1)
   cUsua02 := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_UVE2)), Space(250), T_PARAMETROS->ZZ4_UVE2)

//   cUsua01 := "ADMINISTRADOR|P|05|#"
//   cUsua02 := ""

   cUsua03 := Alltrim(cUsua01) + Alltrim(cUsua02)

   If U_P_OCCURS(cUsua03, UPPER(Alltrim(cUserName)), 1) == 0
      MsgAlert("Atenção!"                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Usuário sem permissão para alterar vencimento de parcelas." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Entre em contato com o seu Lider informando esta mensagem.")
      Return(.T.)               
   Endif

   // ###############################################################################################################################
   // Se usuário possui permissão de alterar vencimento, separa a quantidade de dias que ele pode alterar o vencimenbto da parcela ##
   // ###############################################################################################################################
   For nContar = 1 to U_P_OCCURS(cUsua03, "#", 1)
       
       xSepara := U_P_CORTA(cUsua03, "#", nContar)

       If U_P_OCCURS(xSepara, "|", 1) <> 3
          MsgAlert("Atenção!"                                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Parametrização de alteração de vencimento para este usuário inconsistente." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                   "Entre em contato com o seu Lider informando esta mensagem.")
          Return(.T.)               
       Endif   
       
       If Upper(Alltrim(U_P_CORTA(xSepara, "|", 1))) == Upper(Alltrim(cUserName))
          xTpData := U_P_CORTA(xSepara, "|", 2)
          xDias   := Int(Val(U_P_CORTA(xSepara, "|", 3)))
          Exit
       Endif
       
   Next nContar       

   If Empty(Alltrim(xTpData))
      MsgAlert("Atenção!"                                                                           + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Tipo de Antecipação/Postergação de vencimento não parametrizado para este usuário." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Entre em contato com o seu Lider informando esta mensagem.")
      Return(.T.)               
   Endif

   If xDias == 0
      MsgAlert("Atenção!"                                                                      + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Quantidade de dias permitidos para alteração de vencimento não parametrizado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Entre em contato com o seu Lider informando esta mensagem.")
      Return(.T.)               
   Endif

   If aLista[oLista:nAt,02] == "8"
      MsgAlert("Título já baixado. Alteração não permitida.")
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlgV TITLE "Alteração Vencimento/Juros/Multa" FROM C(178),C(181) TO C(420),C(585) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(022) PIXEL NOBORDER OF oDlgV

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(196),C(001) PIXEL OF oDlgV
   @ C(100),C(002) GET oMemo2 Var cMemo2 MEMO Size C(196),C(001) PIXEL OF oDlgV
   
   @ C(033),C(005) Say "Cliente"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(055),C(005) Say "Dados do Título" Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(077),C(005) Say "Vencimento"      Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(077),C(052) Say "Vencimento Real" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(077),C(111) Say "Juros"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   @ C(077),C(158) Say "Multa"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgV
   
   @ C(042),C(005) MsGet oGet1 Var kCliente Size C(193),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgV When lChumba
   @ C(064),C(005) MsGet oGet2 Var kTitulo  Size C(193),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgV When lChumba
   @ C(086),C(005) MsGet oGet3 Var kVencto  Size C(041),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgV When lChumba
   @ C(086),C(052) MsGet oGet4 Var kVenctoR Size C(041),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgV VALID( verdtvcto() )
   @ C(086),C(111) MsGet oGet5 Var kJuros   Size C(040),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV When lChumba
   @ C(086),C(158) MsGet oGet6 Var kMulta   Size C(040),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgV When lChumba

   @ C(105),C(062) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgV ACTION( GravaVencto() )
   @ C(105),C(101) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgV ACTION( oDlgV:End() )

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return(.T.)

// ###########################################################################################
// Função que valida a nova data de vencimento do título pelos parâmetros do usuário logado ##
// ###########################################################################################
Static Function verdtvcto()

   Local nPercorridos := 0
   
   // #####################################
   // Verifica Antecipação de Vencimento ##
   // #####################################
   If kVenctoR < kVenctoV

      If xTpData == "P"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Usuário sem permissão para antecipar vencimento de parcelas.")
         kVenctoR := kVenctoV
         Return(.T.)
      Else
         If (kVenctoV - kVenctoR) > xDias
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Permitido antecipar vencimento somente até " + Alltrim(Str(xDias,2)) + " dias." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique data informada!")
            kVenctoR := kVenctoV
            Return(.T.)
         Endif
      Endif
      
   Endif   
         
   // #####################################
   // Verifica Postergação de Vencimento ##
   // #####################################
   If kVenctoR > kVenctoV

      If xTpData == "A"
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Usuário sem permissão para postergar vencimento de parcelas.")
         kVenctoR := kVenctoV
         Return(.T.)
      Else
         If (kVenctoR - kVenctoV) > xDias
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Permitido postergar vencimento somente até " + Alltrim(Str(xDias,2)) + " dias." + chr(13) + chr(10) + chr(13) + chr(10) + "Verifique data informada!")
            kVenctoR := kVenctoV
            Return(.T.)
         Endif
      Endif
      
   Endif   

Return(.T.)      

// ###################################################
// Função que que grava dados do título selecionado ##
// ###################################################
Static Function GravaVencto()

   Local nContar := 0 
   // Manutenção 07/13/2018 referente a alteração de tamanho de campo EB_REFBAN
   Local aRefB := TamSX3("EB_REFBAN") 
   
   If kvenctoR == Ctod("  /  /    ")
      MsgAlert("Vencimento Real do tótulo não informado. Verifoque!")
      Return(.T.)
   Endif      

   kvencimento := Dtos(kVenctoR)
   
   // ##########################################################################
   // Se o título já tiver um borderô vinculado, inclui egistro na tabela FI2 ##
   // ##########################################################################
   If Empty(Alltrim(aLista[oLista:nAt,16]))

      BEGIN TRANSACTION  

         cSql := ""
         cSql := "UPDATE SE1" + Substr(cComboBx2,01,02) + "0"                     + CHR(13)
         cSql += "   SET "                                                        + CHR(13)
         cSql += "   E1_VENCREA     = '" + Alltrim(kVencimento) + "'"             + CHR(13)
         cSql += " WHERE E1_PREFIXO = '" + Alltrim(aLista[oLista:nAt,04])   + "'" + CHR(13)
         cSql += "   AND E1_NUM     = '" + Alltrim(aLista[oLista:nAt,03])   + "'" + CHR(13)
         cSql += "   AND E1_PARCELA = '" + Alltrim(aLista[oLista:nAt,05])   + "'" + CHR(13)
         cSql += "   AND E1_TIPO    = '" + Alltrim(aLista[oLista:nAt,06])   + "'" + CHR(13)
         cSql += "   AND E1_CLIENTE = '" + Alltrim(aBrowse[oBrowse:nAt,01]) + "'" + CHR(13)
         cSql += "   AND E1_LOJA    = '" + Alltrim(aBrowse[oBrowse:nAt,02]) + "'" + CHR(13)

         lResult := TCSQLEXEC(cSql)

         If lResult < 0
            Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
         EndIf 

       END TRANSACTION

   Else
      
      // ###############################################################################
      // Pesquisa o código da Ocorrência no parametrizador para pesqusiar a descrição ##
      // ###############################################################################
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf
   
      cSql := ""
      cSql := "SELECT ZZ4_BOCO FROM " + RetSqlName("ZZ4")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      cOcorrencia := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_BOCO)), Space(250), T_PARAMETROS->ZZ4_BOCO)

//    cOcorrencia := "033|V|06|#033|J|12|#033|M|14|#"

      If Empty(Alltrim(cOcorrencia))
         MsgAlert("Atenção!"                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Parâmetros para alteração de vencimento não parametrizado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Entre em contato com o seu Lider informando esta mensagem.")
         Return(.T.)               
      Endif

      If U_P_OCCURS(cOcorrencia, "033", 1) == 0
         MsgAlert("Atenção!"                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Parâmetros para alteração de vencimento não parametrizado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Entre em contato com o seu Lider informando esta mensagem.")
         Return(.T.)               
      Endif

      If U_P_OCCURS(cOcorrencia, "V", 1) == 0
         MsgAlert("Atenção!"                                                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Parâmetros para alteração de vencimento não parametrizado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Entre em contato com o seu Lider informando esta mensagem.")
         Return(.T.)               
      Endif

      // ##################################################
      // Pesquisa o código de ocorrência para Vencimento ##
      // ##################################################
      kBanco      := ""
      kOcorrencia := ""

      For nContar = 1 to U_P_OCCURS(cOcorrencia, "#", 1)
          xSepara := U_P_CORTA(cOcorrencia,"#",nContar)
          If U_P_CORTA(xSepara, "|", 2) == "V"
             kBanco      := U_P_CORTA(xSepara, "|", 1)
             kOcorrencia := U_P_CORTA(xSepara, "|", 3)
             Exit
          Endif
      Next nContar       
             
      // ###################################################
      // Pesquisa a descrição da Ocorrência para gravação ##
      // ###################################################
      If Select("T_OCORRENCIA") > 0
         T_OCORRENCIA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT EB_DESCRI"
      cSql += "  FROM SEB" + Substr(cComboBx2,01,02) + "0"
      cSql += " WHERE EB_FILIAL = '" + Alltrim(Substr(cComboBx3,01,02)) + "'"
      cSql += "   AND EB_BANCO  = '" + Alltrim(kBanco)      + "'"        
      //manutenção 7/13/2018 - adicionado PadR para comportar alterações de tamanho de campo na tabela
      cSql += "   AND EB_REFBAN = '" + PadR((Alltrim(kOcorrencia)),aRefB[1]) + "'"     // Alltrim(kOcorrencia) + "'"
      cSql += "   AND EB_TIPO   = 'E'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCORRENCIA", .T., .T. )

      If T_OCORRENCIA->( EOF() )
         MsgAlert("Atenção!"                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Ocorrência parametrizada não cadastrada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Entre em contato com o seu Lider informando esta mensagem.")
         Return(.T.)               
      Endif

      // ###################################
      // Realiza a gravação da tabela FI2 ##
      // ###################################
      BEGIN TRANSACTION  

         dbSelectArea("FI2")
	     RecLock("FI2",.T.)
         FI2->FI2_FILIAL := Substr(cComboBx3,01,02)
         // 7/13/2018 correção referente a variavel kOcorrencia, anteriormente sendo chamada por "kCorrencia"
         FI2->FI2_OCORR  := kOcorrencia // kCorrencia
         FI2->FI2_DESCOC := Alltrim(T_OCORRENCIA->EB_DESCRI)
         FI2->FI2_PREFIX := aLista[oLista:nAt,04]
         FI2->FI2_TITULO := aLista[oLista:nAt,03]
         FI2->FI2_PARCEL := aLista[oLista:nAt,05]
         FI2->FI2_TIPO	 := aLista[oLista:nAt,06]
         FI2->FI2_CODCLI :=	aBrowse[oBrowse:nAt,01]
         FI2->FI2_LOJCLI :=	aBrowse[oBrowse:nAt,02]
         FI2->FI2_GERADO :=	"2"
         FI2->FI2_NUMBOR :=	aLista[oLista:nAt,16]
         FI2->FI2_CARTEI :=	"1"       
         //7/13/2018 correção referente ao tipo de dados passados ao campo DTOCOR
         FI2->FI2_DTOCOR := Date() // Ctod(Date()) 
         //7/13/2018 correção referente ao tipo de caracter passado aos campos VALANT e VALNOV - adicionado cValToChar
         FI2->FI2_VALANT := cValToChar(kVenctoV) // kVenctoV
         FI2->FI2_VALNOV := cValToChar(kVenctoR) // kVenctoR
         FI2->FI2_CAMPO  := "E1_VENCREA"
         FI2->FI2_TIPCPO := "D"
   	     MsUnlock()

         // ####################################################################
         // Atualiza o registro do contas a receber com a alteração realizada ##
         // ####################################################################
         cSql := ""
         cSql := "UPDATE SE1" + Substr(cComboBx2,01,02) + "0"                     + CHR(13)
         cSql += "   SET "                                                        + CHR(13)
         cSql += "   E1_VENCREA     = '" + Alltrim(kVencimento) + "'"             + CHR(13)
         cSql += " WHERE E1_PREFIXO = '" + Alltrim(aLista[oLista:nAt,04])   + "'" + CHR(13)
         cSql += "   AND E1_NUM     = '" + Alltrim(aLista[oLista:nAt,03])   + "'" + CHR(13)
         cSql += "   AND E1_PARCELA = '" + Alltrim(aLista[oLista:nAt,05])   + "'" + CHR(13)
         cSql += "   AND E1_TIPO    = '" + Alltrim(aLista[oLista:nAt,06])   + "'" + CHR(13)
         cSql += "   AND E1_CLIENTE = '" + Alltrim(aBrowse[oBrowse:nAt,01]) + "'" + CHR(13)
         cSql += "   AND E1_LOJA    = '" + Alltrim(aBrowse[oBrowse:nAt,02]) + "'" + CHR(13)

         lResult := TCSQLEXEC(cSql)

         If lResult < 0
            Return MsgStop("Erro durante a alteração das parcelas: " + TCSQLError())
         EndIf 

       END TRANSACTION
      
   Endif   

   oDlgV:End() 



   // ##################
   // Atualiza a tela ##
   // ##################
   PESSCRBOL()
   
Return(.T.)

// #####################################################
// Função que envia para impressão do boleto bancário ##
// #####################################################
Static Function EnviaBolSant()                          

   MsgRun("Aguarde! Imprimindo Boleto Bancário ...", "Negociação de Títulos",{|| xEnviaBolSant() })

Return(.T.)

// #####################################################
// Função que envia para impressão do boleto bancário ##
// #####################################################
Static Function xEnviaBolSant()

   Local nContar  := 0
   Local lmarcado := .F.
   
   // #########################################################################################
   // Verifica se houve marcação de algum título para realiza a impressão do boleto bancário ##
   // #########################################################################################
   lMarcado := .F.

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Nenhum título foi indicado para impressão de boleto bancário. Verifique")
      Return(.T.)
   Endif
   
   // ############################
   // Imprime boletos bancários ##
   // ############################
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .T.

          If aLista[nContar,02] == "8"
             Loop
          Endif

          kParametros := aLista[nContar,03] + "|" + aLista[nContar,04] + "|" + aLista[nContar,05] + "|"
  
          U_SANTANDER(.T., aLista[nContar,03], aLista[nContar,04],, kParametros) 

       Endif

   Next nContar

Return(.T.)