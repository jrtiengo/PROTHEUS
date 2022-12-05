#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM163.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/03/2013                                                          *
// Objetivo..: Programa que pesquisa a chave da NFe através da informação do nº da *
//             nota fiscal e nº de série.                                          *
//**********************************************************************************

User Function AUTOM163()

   Private lChumba    := .F.

   Private cNota	  := Space(10)
   Private cSerie	  := Space(03)
   Private cChave	  := Space(100)
   Private nTipo      := 0
   Private nPesquisar := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oRadioGrp1
   Private oRadioGrp2

   Private oDlg

   U_AUTOM628("AUTOM163")

   DEFINE MSDIALOG oDlg TITLE "Consulta Danfe pelo Site" FROM C(178),C(181) TO C(339),C(608) PIXEL

   @ C(005),C(005) Say "Nº Nota Fiscal"            Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(052) Say "Série"                     Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(005) Say "Chave NFe"                 Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(075) Say "Tipo Nota Fiscal"          Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Pesquisar em"              Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Pesquisar em"              Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1      Var cNota      When !lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(052) MsGet oGet3      Var cSerie     When !lChumba Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(078) Radio oRadioGrp1 Var nTipo      Items "Nota Fiscal de Entrada","Nota Fiscal de Saída" 3D When !lChumba Size C(055),C(010) PIXEL OF oDlg
   @ C(055),C(040) Radio oRadioGrp2 Var nPesquisar Items "Web Service","Browser"                         3D When !lChumba Size C(041),C(010) PIXEL OF oDlg
   
   @ C(003),C(160) Button "Pesquisar"     When !lChumba Size C(048),C(012) PIXEL OF oDlg ACTION( Pesq_Chave() )
   @ C(019),C(160) Button "Nova Pesquisa" When lChumba  Size C(048),C(012) PIXEL OF oDlg ACTION( Nova_Pesq() )
   @ C(035),C(160) Button "Voltar"                      Size C(048),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   @ C(039),C(005) MsGet oGet2 Var cChave When lChumba  Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a nova pesquisa
Static Function Nova_Pesq()
                         
   lChumba   := .F.
   cNota	 := Space(10)
   cSerie	 := Space(03)
   cChave	 := Space(100)
   nTipo     := 0

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oRadioGrp1:Refresh()
                  
   oDlg:Refresh()

Return .T.

// Função que pesquisa a chave da nota fiscal
Static Function Pesq_Chave()

   Local cSql      := ""
   Local xUrl      := ""
   Local nTimeOut  := 30
   Local aHeadOut  := {}
   Local cHeadRet  := ""
   Local sPostRet  := Nil
   Local cTime     := 0

   Private cChaveN := ""
   Private oGet2

   Private oDlgC

   If nTipo == 0
      MsgAlert("Necessário informar o tipo de nota fiscal a ser pesquisada.")
      Return .T.
   Endif

   If Select("T_CHAVE") > 0
      T_CHAVE->( dbCloseArea() )
   EndIf

   If nTipo == 1
      cSql := ""
      cSql := "SELECT F1_DOC  ,"
      cSql += "       F1_SERIE,"
      cSql += "       F1_CHVNFE"
      cSql += "  FROM " + RetSqlName("SF1")
      cSql += " WHERE F1_DOC     = '" + Alltrim(cNota)  + "'"
      cSql += "   AND F1_SERIE   = '" + Alltrim(cSerie) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"   
   Else
      cSql := ""
      cSql := "SELECT F2_DOC  ,"
      cSql += "       F2_SERIE,"
      cSql += "       F2_CHVNFE"
      cSql += "  FROM " + RetSqlName("SF2")
      cSql += " WHERE F2_DOC     = '" + Alltrim(cNota)  + "'"
      cSql += "   AND F2_SERIE   = '" + Alltrim(cSerie) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"   
   Endif
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CHAVE", .T., .T. )

   If T_CHAVE->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      cChave := Space(100)
      Return .T.   
   Endif
   
   If nTipo == 1
      cChave  := T_CHAVE->F1_CHVNFE
   Else
      cChave  := T_CHAVE->F2_CHVNFE
   Endif
            
   lChumba := .T.
           
   If Empty(Alltrim(cChave))
      MsgAlert("Chave de pesquisa da NFe está em branco. Pesquisa não será realizada.")
      Return .T.
   Endif

   cChaveN := cChave

   // Abre o Site para pesquisa
   If nPesquisar = 1
      winexec("C:\Program Files\Internet Explorer\IEXPLORE.EXE http://webdanfe.com.br/webdanfe/NfeCrawler/Crawl.aspx?errorMsg=Digite+os+caracteres+de+acordo+com+a+imagem!&chaveNfe=" + Alltrim(cChave) , 1)
   Else

      Private oDlgC
      
      DEFINE MSDIALOG oDlgC TITLE "Consulta Danfe pelo Site" FROM C(178),C(181) TO C(289),C(495) PIXEL

      @ C(005),C(005) Say "Copie a Chave da Nota Fiscal a ser pesquisada." Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      @ C(016),C(005) Say "Chave NFe"                                      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

      @ C(025),C(005) MsGet oGet2 Var cChaveN Size C(147),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC

      @ C(038),C(054) Button "Continuar" Size C(048),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )

      ACTIVATE MSDIALOG oDlgC CENTERED 

      winexec("C:\Program Files\Internet Explorer\IEXPLORE.EXE www.webdanfe.com.br", 1)

   Endif
               
Return .T.                                                                                                                                                                                                  
