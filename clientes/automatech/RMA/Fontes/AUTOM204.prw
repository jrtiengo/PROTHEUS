#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM204.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/01/2014                                                          *
// Objetivo..: Programa que solicita a indicação da RMA no momento da devolução de *
//             RMA de produtos.                                                    *
//**********************************************************************************

User Function AUTOM204()

   Local cSql        := ""
   Local cMemo1	     := ""
   Local lEaprovador := .F.
   Local nContar     := 0
   Local oMemo1

   Private aBrowse   := {}
   Private aNumSerie := {}

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

   // Verifica se o TES utilizado na devolução pertence aos TES de retorno de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_NRMA1 , "
   cSql += "       ZZ4_NRMA2 , "
   cSql += "       ZZ4_NRMA3 , "
   cSql += "       ZZ4_NRMA4 , "
   cSql += "       ZZ4_NRMA5 , "
   cSql += "       ZZ4_NRMA6 , "
   cSql += "       ZZ4_NRMA7 , "
   cSql += "       ZZ4_NRMA8 , "
   cSql += "       ZZ4_NRMA9 , "
   cSql += "       ZZ4_NRMA10, "                        
   cSql += "       ZZ4_ERMA1 , "   
   cSql += "       ZZ4_ERMA2 , "   
   cSql += "       ZZ4_ERMA3 , "   
   cSql += "       ZZ4_ERMA4 , "   
   cSql += "       ZZ4_ERMA5 , "   
   cSql += "       ZZ4_EMAI6 , "   
   cSql += "       ZZ4_EMAI7 , "   
   cSql += "       ZZ4_EMAI8 , "   
   cSql += "       ZZ4_EMAI9 , "   
   cSql += "       ZZ4_EMAI10, "                           
   cSql += "       ZZ4_TRMA    "
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_TRMA))
      Return(.T.)
   Endif

   lEaprovador := .F.

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA1)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif
   
   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA2)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA3)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA4)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA5)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA6)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA7)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA8)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA9)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If UPPER(Alltrim(T_PARAMETROS->ZZ4_NRMA10)) == UPPER(Alltrim(CUSERNAME))
      lEaprovador := .T.
   Endif

   If lEaprovador == .F.       
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Você não é um Aprovador de RMA.")
      Return(.T.)
   Endif

   Private oDlg

   BscRMAAprova(1)

   DEFINE MSDIALOG oDlg TITLE "RMA - Return Merchandise Authorization" FROM C(178),C(181) TO C(581),C(967) PIXEL

   @ C(003),C(005) Jpeg FILE "logoautoma.bmp" Size C(125),C(027) PIXEL NOBORDER OF oDlg

   @ C(013),C(288) Say "R M A - Return Merchandise Authorization" Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(021),C(288) Say "Aprovação de RMA"                         Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(031),C(001) GET oMemo1 Var cMemo1 MEMO Size C(387),C(001) PIXEL OF oDlg

   @ C(186),C(003) Button "Fluxo/Legenda" Size C(069),C(012) PIXEL OF oDlg ACTION( ALegenda() )
   @ C(186),C(312) Button "Analisar"      Size C(037),C(012) PIXEL OF oDlg ACTION( AbreAprova(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(186),C(351) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 045 , 003, 495, 188,,{'Lg ', 'RMA', 'ANO', 'Data', 'Hora', 'Dias', 'Código', 'Loja', 'Clientes', 'Vendedor', 'Nome Vendedores'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "4", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oPink     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,08]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,09]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,10]            } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega os RMA a serem aprovados
Static Function BscRMAAprova(_Tipo)

   Local cSql := ""

   aBrowse    := {}

   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf

   cSql := "SELECT DISTINCT   "
   cSql += "       A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C  "
   cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND A.ZS4_STAT   = '1'" 
   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "
   cSql += " ORDER BY A.ZS4_NRMA, A.ZS4_ANO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      aAdd( aBrowse, { "1", "","","","","","","","","","","","","" })
   Else
   
      T_DADOS->( DbGoTop() )
      
      WHILE !T_DADOS->( EOF() )
      
         aAdd( aBrowse, { T_DADOS->ZS4_STAT,;
                          T_DADOS->ZS4_NRMA,;
                          T_DADOS->ZS4_ANO ,;
                          Substr(T_DADOS->ZS4_ABER,07,02) + "/" + Substr(T_DADOS->ZS4_ABER,05,02) + "/" + Substr(T_DADOS->ZS4_ABER,01,04) ,;
                          T_DADOS->ZS4_HORA,;
                          T_DADOS->ZS4_CLIE,;
                          T_DADOS->ZS4_LOJA,;
                          T_DADOS->A1_NOME ,;
                          T_DADOS->ZS4_VEND,;
                          T_DADOS->A3_NOME }) 

         T_DADOS->( DbSkip() )                 
      ENDDO
   Endif

   If _Tipo == 1
      Return(.T.)
   Endif

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "4", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oPink     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,08]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,09]            ,;                                                                                                    
                         aBrowse[oBrowse:nAt,10]            } }

   oBrowse:Refresh()

Return(.T.)

// Desenha a tela de Fluxo e Legenda
Static Function ALegenda()

   Local cMemo1	 := ""
   Local cMemo10 := ""
   Local cMemo11 := ""
   Local cMemo12 := ""
   Local cMemo13 := ""
   Local cMemo14 := ""
   Local cMemo15 := ""
   Local cMemo16 := ""
   Local cMemo17 := ""
   Local cMemo18 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := ""
   Local cMemo7	 := ""
   Local cMemo8	 := ""
   Local cMemo9	 := ""
   Local oMemo1
   Local oMemo10
   Local oMemo11
   Local oMemo12
   Local oMemo13
   Local oMemo14
   Local oMemo15
   Local oMemo16
   Local oMemo17
   Local oMemo18
   Local oMemo2
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6
   Local oMemo7
   Local oMemo8
   Local oMemo9

   Private oDlgL

   DEFINE MSDIALOG oDlgL TITLE "Fluxo/Legenda" FROM C(178),C(181) TO C(608),C(722) PIXEL

   @ C(008),C(079) Button "Abertura/Nova Aprovação"                      Size C(072),C(012) PIXEL OF oDlgL
   @ C(042),C(096) Button "Aprovação"                                    Size C(037),C(012) PIXEL OF oDlgL
   @ C(085),C(047) Button "Não Aprovado"                                 Size C(045),C(012) PIXEL OF oDlgL
   @ C(085),C(171) Button "Aprovado"                                     Size C(045),C(012) PIXEL OF oDlgL
   @ C(117),C(137) Button "Envia e-mail ao Cliente informando nº da RMA" Size C(115),C(012) PIXEL OF oDlgL
   @ C(124),C(021) Button "Revisão"                                      Size C(037),C(012) PIXEL OF oDlgL
   @ C(124),C(080) Button "Recusado"                                     Size C(037),C(012) PIXEL OF oDlgL
   @ C(149),C(171) Button "Doc Devolução"                                Size C(045),C(012) PIXEL OF oDlgL
   @ C(152),C(080) Button "Encerra"                                      Size C(037),C(012) PIXEL OF oDlgL
   @ C(173),C(171) Button "Final Processo"                               Size C(045),C(012) PIXEL OF oDlgL

   @ C(014),C(009) GET oMemo12 Var cMemo12 MEMO Size C(001),C(137) PIXEL OF oDlgL
   @ C(014),C(009) GET oMemo13 Var cMemo13 MEMO Size C(068),C(001) PIXEL OF oDlgL
   @ C(021),C(114) GET oMemo1  Var cMemo1  MEMO Size C(001),C(019) PIXEL OF oDlgL
   @ C(055),C(114) GET oMemo2  Var cMemo2  MEMO Size C(001),C(012) PIXEL OF oDlgL
   @ C(068),C(069) GET oMemo3  Var cMemo3  MEMO Size C(124),C(001) PIXEL OF oDlgL
   @ C(068),C(069) GET oMemo4  Var cMemo4  MEMO Size C(001),C(016) PIXEL OF oDlgL
   @ C(068),C(193) GET oMemo5  Var cMemo5  MEMO Size C(001),C(016) PIXEL OF oDlgL
   @ C(098),C(069) GET oMemo6  Var cMemo6  MEMO Size C(001),C(013) PIXEL OF oDlgL
   @ C(098),C(193) GET oMemo15 Var cMemo15 MEMO Size C(001),C(018) PIXEL OF oDlgL
   @ C(112),C(040) GET oMemo7  Var cMemo7  MEMO Size C(059),C(001) PIXEL OF oDlgL
   @ C(112),C(040) GET oMemo8  Var cMemo8  MEMO Size C(001),C(011) PIXEL OF oDlgL
   @ C(112),C(098) GET oMemo9  Var cMemo9  MEMO Size C(001),C(011) PIXEL OF oDlgL
   @ C(131),C(193) GET oMemo16 Var cMemo16 MEMO Size C(001),C(017) PIXEL OF oDlgL
   @ C(137),C(040) GET oMemo10 Var cMemo10 MEMO Size C(001),C(013) PIXEL OF oDlgL
   @ C(137),C(098) GET oMemo14 Var cMemo14 MEMO Size C(001),C(014) PIXEL OF oDlgL
   @ C(150),C(009) GET oMemo11 Var cMemo11 MEMO Size C(031),C(001) PIXEL OF oDlgL
   @ C(162),C(193) GET oMemo17 Var cMemo17 MEMO Size C(001),C(010) PIXEL OF oDlgL
   @ C(191),C(009) GET oMemo18 Var cMemo18 MEMO Size C(255),C(001) PIXEL OF oDlgL

   @ C(010),C(155) Jpeg FILE "br_amarelo"  Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(087),C(218) Jpeg FILE "br_verde"    Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(119),C(255) Jpeg FILE "br_laranja"  Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(126),C(061) Jpeg FILE "br_vermelho" Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(126),C(121) Jpeg FILE "br_preto"    Size C(008),C(008) PIXEL NOBORDER OF oDlgL
   @ C(175),C(218) Jpeg FILE "br_azul"     Size C(008),C(008) PIXEL NOBORDER OF oDlgL
      
   @ C(198),C(118) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Abre tela de manutenção da RMA
Static Function AbreAprova(_RMA, _ANO)

   Local lChumba     := .F.
   Local nContar     := 0
   Local lAbre       := .F.
   Local lAprova     := .F.

   Private lDados    := .F.
   Private aComboBx1 := U_AUTOM539(2, cEmpAnt) // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private aComboBx2 := {"  ", "01 - Encontrato com NF. Original", "02 - Encontro com NF. Nova", "03 - Encontro com outra NF. (Especificar)", "04 - Cliente ficou com crédito", "05 - Cliente vai receber em espécie (Somente se for devolvido até 7 dias ou com autuorização)"}
   Private aSituacao := {"1 - Abertura", "2 - Dados Incompletos", "3 - Autorizado", "4 - Recusado", "5 - Aguardando Doc Retorno", "6 - Encerrado"}

   Private aProvador := {__cUserID + " - " + Upper(Alltrim(CUSERNAME)) }

   Private cComboBx1
   Private cComboBx2
   Private cComboBx4
   Private cComboBx5   

   Private cDataP        := Date()
   Private cHoraP        := Time()

   Private cNRMA	     := Space(05)
   Private cARMA	     := Space(04)
   Private cAbertura     := Ctod("  /  /    ")
   Private cHora	     := Space(10)
   Private cVendedor     := Space(25)
   Private cCliente      := Space(06)
   Private cLoja	     := Space(03)
   Private cNota	     := Space(06)
   Private cSerie	     := Space(03)
   Private xFilial       := Space(02)
   Private nFilial	     := Space(30)
   Private yFilial	     := Space(02)
   Private yNota	     := Space(06)
   Private ySerie	     := Space(03)
   Private cConsideracao := ""

   Private cDCliente := Space(100)
   Private cTelefone := Space(20)
   Private cEmailCli := Space(100)
   Private cContato  := Space(06)
   Private cNomeCon  := Space(40)

   Private cDCliente := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11   
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15    
   Private oGet16    
   Private oGet17    
   Private oGet18    
   Private oGet19       
   Private oGet20       
   Private oGet21          

   Private oMemo2
   Private oMemo3
   Private oMemo4
   
   Private oDlg

   Private aProdutos := {}
   Private oProdutos

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   lAbre := .F.

   If Select("T_DADOS") > 0
      T_DADOS->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql += "SELECT A.ZS4_NRMA,"
   cSql += "       A.ZS4_ANO ,"
   cSql += "       A.ZS4_STAT,"
   cSql += "       A.ZS4_ABER,"
   cSql += "       A.ZS4_HORA,"
   cSql += "       A.ZS4_CLIE,"
   cSql += "       A.ZS4_LOJA,"
   cSql += "       A.ZS4_TELE,"
   cSql += "       A.ZS4_EMAI,"
   cSql += "       A.ZS4_NFIL,"
   cSql += "       A.ZS4_NOTA,"
   cSql += "       A.ZS4_SERI,"
   cSql += "       A.ZS4_CRED,"
   cSql += "       A.ZS4_CREF,"
   cSql += "       A.ZS4_CREN,"
   cSql += "       A.ZS4_CRES,"
   cSql += "       B.A1_NOME ,"
   cSql += "       A.ZS4_VEND,"
   cSql += "       C.A3_NOME ,"
   cSql += "       A.ZS4_DLIB,"
   cSql += "       A.ZS4_HLIB,"
   cSql += "       A.ZS4_APRO,"
   cSql += "       A.ZS4_CONT,"
   cSql += "       A.ZS4_CHEK,"
   cSql += "       A.ZS4_ITEM,"
   cSql += "       A.ZS4_PROD,"
   cSql += "       A.ZS4_QUAN,"
   cSql += "       A.ZS4_UNIT,"
   cSql += "       A.ZS4_TOTA,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
   cSql += "       D.U5_CONTAT,"
   cSql += "       E.B1_DESC  ,"
   cSql += "       E.B1_DAUX  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)) AS SERIES "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C, "
   cSql += "       " + RetSqlName("SU5") + " D, "
   cSql += "       " + RetSqlName("SB1") + " E  "
   cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND A.ZS4_NRMA   = '" + Alltrim(_RMA) + "'"
   cSql += "   AND A.ZS4_ANO    = '" + Alltrim(_ANO) + "'"
   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_CONT   = D.U5_CODCONT"
   cSql += "   AND D.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_PROD   = E.B1_COD "
   cSql += "   AND E.D_E_L_E_T_ = ''       "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   cNRMA	 := _RMA
   cARMA	 := _ANO
   cAbertura := Ctod(Substr(T_DADOS->ZS4_ABER,07,02) + '/' + Substr(T_DADOS->ZS4_ABER,05,02) + '/' + Substr(T_DADOS->ZS4_ABER,01,04))
   cHora	 := T_DADOS->ZS4_HORA
   cVendedor := T_DADOS->ZS4_VEND + " - " + Alltrim(T_DADOS->A3_NOME)
   cCliente  := T_DADOS->ZS4_CLIE 
   cLoja	 := T_DADOS->ZS4_LOJA
   cDCliente := T_DADOS->A1_NOME
   cTelefone := T_DADOS->ZS4_TELE
   cContato  := T_DADOS->ZS4_CONT
   cNomeCon  := T_DADOS->U5_CONTAT
   cEmailCli := T_DADOS->ZS4_EMAI
   xFilial   := T_DADOS->ZS4_NFIL
   cNota	 := T_DADOS->ZS4_NOTA
   cSerie	 := T_DADOS->ZS4_SERI
   yFilial	 := T_DADOS->ZS4_CREF
   yNota	 := T_DADOS->ZS4_CREN
   ySerie	 := T_DADOS->ZS4_CRES
   cMemo2    := T_DADOS->MOTIVO

   Do Case
      Case xFilial == "01"
           nFilial := "01 - Porto Alegre"   
      Case xFilial == "02"
           nFilial := "02 - Caxias do Sul"   
      Case xFilial == "03"
           nFilial := "03 - Pelotas"   
      Case xFilial == "04"
           nFilial := "04 - Suprimentos"   
   EndCase

   // Posiciona o tipo de crédito
   For nContar = 1 to Len(aComboBx2)
       If Substr(aComboBx2[nContar],01,02) == T_DADOS->ZS4_CRED
          cComboBx2 := aComboBx2[nContar]
          EXIT
       Endif
   Next nontar

   // Carrega os Produtos
   aProdutos := {}

   WHILE !T_DADOS->( EOF() )
      aAdd( aProdutos, { IIF(T_DADOS->ZS4_CHEK == "1", .T., .F.)                     ,;
                         T_DADOS->ZS4_ITEM                                           ,;
                         T_DADOS->ZS4_PROD                                           ,;
                         Alltrim(T_DADOS->B1_DESC) + ' ' + Alltrim(T_DADOS->B1_DAUX) ,;  
                         T_DADOS->ZS4_QUAN                                           ,;
                         T_DADOS->ZS4_UNIT                                           ,;
                         T_DADOS->ZS4_TOTA  })

      // Carrega o array dos números de speries
      For nContar = 1 to U_P_OCCURS(T_DADOS->SERIES,"|",1)
          aAdd( aNumSerie, { T_DADOS->ZS4_CLIE,;
                             T_DADOS->ZS4_LOJA,;
                             T_DADOS->ZS4_NFIL,;
                             T_DADOS->ZS4_NOTA,;
                             T_DADOS->ZS4_SERI,;
                             T_DADOS->ZS4_PROD,;
                             U_P_CORTA(T_DADOS->SERIES,"|", nContar) ,;
                             .T.              })

      Next nContar                       

      T_DADOS->( DbSkip() )

   ENDDO                           

   DEFINE MSDIALOG oDlg TITLE "RMA - Return Mersandise Authorized" FROM C(178),C(181) TO C(633),C(770) PIXEL

   @ C(005),C(005) Say "Nº RMA"                      Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(061) Say "Data Abertura"               Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(105) Say "Hora Abertura"               Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(148) Say "Vendedor"                    Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(224) Say "Status"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Cliente"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(225) Say "Telefone"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(005) Say "Contato"                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(140) Say "E-mail"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(005) Say "Filial"                      Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(114) Say "Nº N.Fiscal"                 Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(064),C(159) Say "Série"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(085),C(005) Say "Produtos da Nota Fiscal"     Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(132),C(005) Say "Motivo da Devolução"         Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(132),C(156) Say "Informações Ref. ao Crédito" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(156) Say "Filial"                      Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(174) Say "N.Fiscal"                    Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(210) Say "Série"                       Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(126) Say "Considerações"               Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(205),C(005) Say "Data"                        Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(215),C(005) Say "Hora"                        Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(192),C(005) Say "Aprovador"                   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1     Var   cNRMA       When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(031) MsGet    oGet2     Var   cARMA       When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(061) MsGet    oGet3     Var   cAbertura   When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(105) MsGet    oGet4     Var   cHora       When lChumba Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(148) MsGet    oGet5     Var   cVendedor   When lChumba Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(224) ComboBox cComboBx4 Items aSituacao   When lChumba Size C(064),C(010) PIXEL OF oDlg
   @ C(035),C(005) MsGet    oGet6     Var   cCliente    When lAbre   Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(035),C(033) MsGet    oGet7     Var   cLoja       When lAbre   Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(BSCCLIRMA(cCliente, cLoja))
   @ C(035),C(057) MsGet    oGet15    Var   cDCliente   When lChumba Size C(161),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(224) MsGet    oGet16    Var   cTelefone   When lChumba Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(053),C(005) MsGet    oGet18    Var   cContato    When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(053),C(033) Button "..."                         When lAbre   Size C(010),C(009) PIXEL OF oDlg ACTION( TRZCONTATO(cCliente, cLoja) )
   @ C(053),C(047) MsGet    oGet19    Var   cNomeCon    When lChumba Size C(087),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(053),C(140) MsGet    oGet17    Var   cEmailCli   When lAbre   Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(072),C(005) MsGet    oGet10    Var   xFilial     When lAbre   Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(BSCFILIAL(xFilial))
   @ C(072),C(022) MsGet    oGet11    Var   nFilial     When lChumba Size C(088),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(072),C(114) MsGet    oGet8     Var   cNota       When lAbre   Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(072),C(159) MsGet    oGet9     Var   cSerie      When lAbre   Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(069),C(183) Button   "Pesquisar"                 When lAbre   Size C(037),C(012) PIXEL OF oDlg ACTION( BSCNOTA1(xFilial, cNota, cSerie, cCliente, cLoja, 2))
   @ C(069),C(229) Button   "Pesq. NFs Cliente"         When lAbre   Size C(059),C(012) PIXEL OF oDlg ACTION( BSCNOTA2(cCliente, cLoja) )
   @ C(141),C(005) GET      oMemo2    Var   cMemo2 MEMO When lAbre   Size C(147),C(043) PIXEL OF oDlg
   @ C(141),C(156) ComboBox cComboBx2 Items aComboBx2   When lAbre   Size C(133),C(010) PIXEL OF oDlg VALID( LibCampo(cComboBx2) )
   @ C(164),C(156) MsGet    oGet12    Var   yFilial     When lDados  Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(164),C(174) MsGet    oGet13    Var   yNota       When lDados  Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(164),C(210) MsGet    oGet14    Var   ySerie      When lDados  Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(186),C(005) GET      oMemo3    Var   cMemo3 MEMO When lAbre   Size C(283),C(001) PIXEL OF oDlg

   @ C(118),C(255) Button "Nº Séries" Size C(034),C(012) PIXEL OF oDlg ACTION( BNSerie(aProdutos[oProdutos:nAt,01], cCliente, cLoja, xFilial, cNota, cSerie, aProdutos[oProdutos:nAt,03] ) )

   // Aprovação/Reprovação
   @ C(190),C(035) ComboBox cComboBx5 Items aProvador        Size C(086),C(010) PIXEL OF oDlg

   @ C(198),C(126) GET   oMemo4       Var cConsideracao MEMO Size C(121),C(026) PIXEL OF oDlg
   @ C(203),C(035) MsGet oGet20       Var cDataP             Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(215),C(035) MsGet oGet21       Var cHoraP             Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(189),C(251) Button "Aprova"  Size C(037),C(008) PIXEL OF oDlg ACTION( APRREPRMA("A", cNRMA, cARMA, aProvador[1], cDataP, cHoraP, cConsideracao) )
   @ C(198),C(251) Button "Revisar" Size C(037),C(008) PIXEL OF oDlg ACTION( APRREPRMA("V", cNRMA, cARMA, aProvador[1], cDataP, cHoraP, cConsideracao) )
   @ C(207),C(251) Button "Reprova" Size C(037),C(008) PIXEL OF oDlg ACTION( APRREPRMA("R", cNRMA, cARMA, aProvador[1], cDataP, cHoraP, cConsideracao) )
   @ C(216),C(251) Button "Retorna" Size C(037),C(008) PIXEL OF oDlg ACTION( oDlg:End() )

   // Cria Componentes Padroes do Sistema
   @ 117,05 LISTBOX oProdutos FIELDS HEADER "", "Item", "Código" ,"Descrição dos Produtos", "Qtd", "R$ Unitário", "R$ Total" PIXEL SIZE 315,048 OF oDlg ;
                            ON dblClick(aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1],oProdutos:Refresh())     
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             		    		   aProdutos[oProdutos:nAt,02],;
         	         	           aProdutos[oProdutos:nAt,03],;
         	         	           aProdutos[oProdutos:nAt,04],;
         	         	           aProdutos[oProdutos:nAt,05],;
         	         	           aProdutos[oProdutos:nAt,06],;         	         	                    	         	           
         	        	           aProdutos[oProdutos:nAt,07]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Aprova ou Reprova a RMA
Static Function APRREPRMA(__Tipo, __RMA, __Ano, __Aprovador, __DataLib, __HoraLib, __Observa)

   Local cSql     := ""
   Local cEmail   := ""
   Local nContar  := 0
   Local nProcura := 0
   Local nItens   := 0
   Local cString  := ""
   Local _nErro   := 0
   Local cTexto   := ""
   
   // Realiza a consistência dos dados antes da gravação
   If Empty(cDataP)
      MsgAlert(IIF(__Tipo == "A", "Data da Aprovação não informada.", "Data da Reprovação não informada."))
   Endif
            
   If Empty(cHoraP)
      MsgAlert(IIF(__Tipo == "A", "Hora da Aprovação não informada.", "Hora da Reprovação não informada."))
   Endif

   If MsgYesNo("Confirma a " + IIF(__Tipo == "A", "Aprovação da RMA?", "Reprovação da RMA?"))
   
      Do Case
         Case __Tipo == "A"
  	          __STATUS := "2"
         Case __Tipo == "V"
     	      __STATUS := "8"   	        
         Case __Tipo == "R"     	         
     	      __STATUS := "7"   	        
   	  EndCase

      // Deleta o registro para nova gravação
      cSql := ""
      cSql := "UPDATE " + RetSqlName("ZS4")
      cSql += "   SET "
  	  cSql += "   ZS4_STAT = '" + Alltrim(__Status)    + "', "
      cSql += "   ZS4_APRO = '" + Alltrim(__Aprovador) + "', "
      cSql += "   ZS4_DLIB = '"  + Strzero(year(__DataLib),4) + Strzero(month(__DataLib),2) + Strzero(day(__DataLib),2) + "', "
      cSql += "   ZS4_HLIB = '" + Alltrim(__HoraLib)   + "', "
      cSql += "   ZS4_CONS = '" + Alltrim(__Observa)   + "'  "
      cSql += " WHERE ZS4_NRMA = '" + Alltrim(cNRMA)   + "'"
      cSql += "   AND ZS4_ANO  = '" + Alltrim(cARMA)   + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
         Return(.T.)
      Endif


/*
  	  dbSelectArea("ZS4")
	  dbSetOrder(2)
	  If DbSeek(__RMA + __ANO)

         RecLock("ZS4",.F.)
     
         Do Case
            Case __Tipo == "A"
     	         ZS4_STAT := "2"
            Case __Tipo == "V"
     	         ZS4_STAT := "8"   	        
            Case __Tipo == "R"     	         
     	         ZS4_STAT := "7"   	        
   	     EndCase

         ZS4_APRO := __Aprovador
         ZS4_DLIB := __DataLib
         ZS4_HLIB := __HoraLib
         ZS4_CONS := __Observa

         MsUnLock()              
         
      Endif

*/

      oDlg:End()

      BscRMAAprova(2)

   Endif

   return(.T.)

   // Envia e-mail aos aprovadores de RMA
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZZ4_NRMA1 ,"
   cSql += "       ZZ4_NRMA2 ,"
   cSql += "       ZZ4_NRMA3 ,"
   cSql += "       ZZ4_NRMA4 ,"
   cSql += "       ZZ4_NRMA5 ,"                              
   cSql += "       ZZ4_NRMA6 ,"                              
   cSql += "       ZZ4_NRMA7 ,"                              
   cSql += "       ZZ4_NRMA8 ,"                              
   cSql += "       ZZ4_NRMA9 ,"                              
   cSql += "       ZZ4_NRMA10,"                                          
   cSql += "       ZZ4_ERMA1 ,"   
   cSql += "       ZZ4_ERMA2 ,"   
   cSql += "       ZZ4_ERMA3 ,"   
   cSql += "       ZZ4_ERMA4 ,"   
   cSql += "       ZZ4_ERMA5 ,"                                   
   cSql += "       ZZ4_EMAI6 ,"                                   
   cSql += "       ZZ4_EMAI7 ,"                                   
   cSql += "       ZZ4_EMAI8 ,"                                   
   cSql += "       ZZ4_EMAI9 ,"                                   
   cSql += "       ZZ4_EMAI10 "                                   
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   If T_PARAMETROS->( EOF() )
   Else

      cEmail := ""
 
      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA1))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA1 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA2))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA2 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA3))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA3 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA4))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA4 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA5))
         cEmail := cEmail + T_PARAMETROS->ZZ4_ERMA5 + ";"
      Endif
      
      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA6))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI6 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA7))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI7 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA8))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI8 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA9))
         cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI9 + ";"
      Endif

      If !Empty(Alltrim(T_PARAMETROS->ZZ4_NRMA10))
            cEmail := cEmail + T_PARAMETROS->ZZ4_EMAI10 + ";"
      Endif

      // Elimina a última vírgula
      cEmail := Substr(cEmail, 01, len(Alltrim(cEmail)) - 1)
      
   Endif
   
   If !Empty(Alltrim(cEmail))

      cTexto := ""
      cTexto := "Prezado(a) Aprovador(a) de RMA" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Existe uma RMA aguardando a sua aprovação." + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Dados da RMA" + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Nº RMA: " + cNRMA + "/" + cARMA + chr(13) + chr(10)
      cTexto += "Cliente: " + cCliente + "." + cLoja + " - " + Alltrim(cDCliente) + chr(13) + chr(10)
      cTexto += "Nota Fiscal: " + Alltrim(cNota) + chr(13) + chr(10)
      cTexto += "Série: " + Alltrim(cSerie) + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Motivo Devolução:" + chr(13) + chr(10)
      cTexto += Alltrim(cMemo2) + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "Att."  + chr(13) + chr(10) + chr(13) + chr(10)
      cTexto += "RMA - Return Merchandise Authorization"

      U_AUTOMR20(cTexto, Alltrim(cEmail), "", "Solicitação Aprovação de RMA" )   
   
   Endif

   oDlg:End() 

   PsqGridDados(2, Substr(cVendedor,01,06))
   
Return(.T.)

// Função que libera ou não os dados da nota fiscal de crédito
Static Function LibCampo(cComboBx2)

   If Substr(cComboBx2,01,02) == "03"
      lDados := .T.
   Else
      yFilial := Space(02)
      yNota	  := Space(06)
      ySerie  := Space(03)
      lDados := .F.
   Endif

Return(.T.)

// Função que valida e pesquisa o nome da filial informada
Static Function BSCFILIAL(_Filial)

   If Empty(Alltrim(_Filial))
      Return(.T.)
   Endif

   If _Filial <> "01" .And. ;
      _Filial <> "02" .And. ;
      _Filial <> "03" .And. ;
      _Filial <> "04"
      MsgAlert("Filial inválida")
      Return(.T.)
   Endif
   
   Do Case
      Case _Filial == "01"
           nFilial := "01 - Porto Alegre"   
      Case _Filial == "02"
           nFilial := "02 - Caxias do Sul"   
      Case _Filial == "03"
           nFilial := "03 - Pelotas"   
      Case _Filial == "04"
           nFilial := "04 - Suprimentos"   
   EndCase

   oGet11:Refresh()
   
Return(.T.)   

// Função que pesquisa o cliente selecionado
Static Function BSCCLIRMA(_Cliente, _Loja)

   Local cSql := ""

   cCliente  := Space(06)
   cLoja     := Space(03)
   cDCliente := ""
   cTelefone := ""
   cEmailCli := ""
   cContato  := Space(06)
   cNomeCon  := Space(30)
   cEmailCli := Space(100)

   If Empty(Alltrim(_Cliente))
      Return(.T.)
   Endif

   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME,"
   cSql += "       RTRIM(A1_END) + ' - ' + RTRIM(A1_BAIRRO) AS ENDERECO ,"
   cSql += "       RTRIM(A1_EST) + '/' + RTRIM(A1_MUN) + '-' + SUBSTRING(A1_CEP,01,02) + '.' + SUBSTRING(A1_CEP,03,03) + '-' + SUBSTRING(A1_CEP,06,03) AS CIDADE,"
   cSql += "       '(' + RTRIM(A1_DDD) + ') - ' + RTRIM(A1_TEL) AS TELEFONE,"
   cSql += "       A1_EMAIL"
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A1_COD     = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(_Loja)    + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
   
   If T_CLIENTE->( EOF() )
      cCliente  := Space(06)
      cLoja     := Space(03)
      cDCliente := ""
      cTelefone := ""
      cEmailCli := ""
      cContato  := Space(06)
      cNomeCon  := Space(30)
      cEmailCli := Space(100)
      Return(.T.)
   Endif

   cCliente  := T_CLIENTE->A1_COD
   cLoja     := T_CLIENTE->A1_LOJA
   cDCliente := Alltrim(T_CLIENTE->A1_NOME)
   cTelefone := Alltrim(T_CLIENTE->TELEFONE)
   cEmailCli := Alltrim(T_CLIENTE->A1_EMAIL)

Return(.T.)

// Função que pesquisa os contato do cliente informado
Static Function TRZCONTATO(_Cliente, _Loja)

   Local cSql := ""

   Private oOk      := LoadBitmap( GetResources(), "LBOK" )
   Private oNo      := LoadBitmap( GetResources(), "LBNO" )
   Private aContato := {}
   Private oContato
   
   Private oDlgC
   
   If Empty(Alltrim(_Cliente))
      MsgAlert("Necessário informar o cliente para pesquisa de contatos.") 
      Return .T.
   Endif
      
   // Carrega o Combo de Contatos
   If Select("T_CONTATO") > 0
      T_CONTATO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.AC8_FILIAL,"
   cSql += "       A.AC8_FILENT,"
   cSql += "       A.AC8_ENTIDA,"
   cSql += "       A.AC8_CODENT,"
   cSql += "       A.AC8_CODCON,"
   cSql += "       B.U5_CONTAT ,"
   cSql += "       B.U5_EMAIL  ,"
   cSql += "       B.U5_DDD    ,"
   cSql += "       B.U5_FONE    "
   cSql += "  FROM " + RetSqlName("AC8") + " A, "
   cSql += "       " + RetSqlName("SU5") + " B  "
   cSql += " WHERE A.AC8_CODENT = '" + alltrim(_Cliente) + Alltrim(_Loja) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.AC8_CODCON = B.U5_CODCONT"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )
   
   If T_CONTATO->( EOF() )
      aAdd( aContato, { .F.,"","","" } )
   Else
      WHILE !T_CONTATO->( EOF() )
         aAdd( aContato, { .F.                   ,;
                           T_CONTATO->AC8_CODCON ,;
                           T_CONTATO->U5_CONTAT  ,;
                           T_CONTATO->U5_EMAIL   })
         T_CONTATO->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgC TITLE "Consulta Contatos" FROM C(178),C(181) TO C(392),C(656) PIXEL

   @ C(005),C(005) Say "Contatos do Cliente informado" Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(091),C(195) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgC ACTION( FechaContato() )

   @ 020,005 LISTBOX oContato FIELDS HEADER "M", "Código", "Nome dos Contatos", "E-Mail" PIXEL SIZE 290,092 OF oDlgC ;
                            ON dblClick(aContato[oContato:nAt,1] := !aContato[oContato:nAt,1],oContato:Refresh())     
   oContato:SetArray( aContato )
   oContato:bLine := {||    {Iif(aContato[oContato:nAt,01],oOk,oNo),;
                                 aContato[oContato:nAt,02],;
           		    		     aContato[oContato:nAt,03],;
         	         	         aContato[oContato:nAt,04]}}

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que fecha a tela de consulta de contatos
Static Function FechaContato()

   Local nContar   := 0
   Local nMarcados := 0
   
   // Verifica se houve a marcação de mais do que um contato
   For nContar = 1 to Len(acontato)
       If aContato[nContar,01] == .T.
          nMarcados += 1
       Endif
   Next nContar
   
   If nMarcados > 1
      MsgAlert("Atenção!" + chr(13) + chr(10) + "Indique apenas um contato do cliente.")
      Return .T.
   Endif

   // Pesquisa o contato marcado
   For nContar = 1 to Len(acontato)
       If aContato[nContar,01] == .T.
          cContato  := aContato[nContar,02]
          cNomeCon  := aContato[nContar,03]
          cEmailCli := aContato[nContar,04]
          Exit
       Endif
   Next nContar

   oDlgC:End() 
   
   oGet18:Refresh()
   oGet19:Refresh()
   oGet17:Refresh()

Return(.T.)

// Função que pesquisa a nota fisdcal informada
Static Function BSCNOTA1(_Filial, _Nota, _Serie, _Cliente, _Loja, _Tipo)

   Local cSql := ""

   If Empty(Alltrim(xFilial))
      MsgAlert("Filial não informada para pesquisa.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Nota))
      MsgAlert("Nota Fiscal não informada para pesquisa.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_Serie))
      MsgAlert("Série não informada para pesquisa.")
      Return(.T.)
   Endif

   If Empty(Alltrim(_Cliente))
      MsgAlert("Cliente não informado para pesquisa.")
      Return(.T.)
   Endif

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT A.D2_ITEM,"
   cSql += "       A.D2_COD ,"
   cSql += "       RTRIM(B.B1_DESC) + ' ' + RTRIM(B.B1_DAUX) AS DESCRICAO,"
   cSql += "       A.D2_QUANT ,"
   cSql += "       A.D2_PRCVEN,"
   cSql += "       A.D2_TOTAL  "
   cSql += "  FROM " + RetSqlName("SD2") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(xFilial) + "'"
   cSql += "   AND A.D2_DOC     = '" + Alltrim(_Nota)   + "'"
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(_Serie)  + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.D2_COD     = B.B1_COD"
   cSql += "   AND B.D_E_L_E_T_ = ''"
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += " ORDER BY A.D2_ITEM "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   aProdutos := {}

   T_NOTA->( DbGoTop() )
   
   WHILE !T_NOTA->( EOF() )
      aAdd( aProdutos, { .F.              ,;
                         T_NOTA->D2_ITEM  ,;
                         T_NOTA->D2_COD   ,;
                         T_NOTA->DESCRICAO,;  
                         T_NOTA->D2_QUANT ,;
                         T_NOTA->D2_PRCVEN,;
                         T_NOTA->D2_TOTAL })
      T_NOTA->( DbSkip() )
   ENDDO                           

   If _Tipo == 1
      Return(.T.)
   Endif
                        
   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             		    		   aProdutos[oProdutos:nAt,02],;
         	         	           aProdutos[oProdutos:nAt,03],;
         	         	           aProdutos[oProdutos:nAt,04],;
         	         	           aProdutos[oProdutos:nAt,05],;
         	         	           aProdutos[oProdutos:nAt,06],;         	         	                    	         	           
         	        	           aProdutos[oProdutos:nAt,07]}}

Return(.T.)

// Função que pesquisa as notas fiscais do cliente informado
Static Function BSCNOTA2(_Cliente, _Loja)

   Local cGet1	 := Space(25)
   Local oGet1

   Private oDlgN

   Private aCabeca  := {}
   Private aDetalhe := {}

   Private oCabeca
   Private oDetalhe

   If Empty(Alltrim(_Cliente))
      MsgAlert("Necessário informar o Cliente para pesquisa.")
      Return(.T.)
   Endif

   aCabeca := {}

   aAdd( aDetalhe, { "","","","","","","" })

   If Select("T_NOTA") > 0
      T_NOTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT F2_FILIAL ,"
   cSql += "       SUBSTRING(F2_EMISSAO,07,02) + '/' + SUBSTRING(F2_EMISSAO,05,02) + '/' + SUBSTRING(F2_EMISSAO,01,04) AS EMISSAO,"
   cSql += "       F2_DOC    ,"
   cSql += "       F2_SERIE  ,"
   cSql += "       F2_VALBRUT "
   cSql += "  FROM " + RetSqlName("SF2")
   cSql += " WHERE F2_CLIENT  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND F2_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += "   AND F2_TIPO    = 'N'" 
   cSql += " ORDER BY F2_FILIAL, SUBSTRING(F2_EMISSAO,07,02) + '/' + SUBSTRING(F2_EMISSAO,05,02) + '/' + SUBSTRING(F2_EMISSAO,01,04)"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )

   If T_NOTA->( EOF() )
      aAdd( aCabeca , { "","","","","" } )
   Else

      T_NOTA->( DbGoTop() )
   
      WHILE !T_NOTA->( EOF() )
         aAdd( aCabeca, { T_NOTA->F2_FILIAL,;
                          T_NOTA->EMISSAO  ,;
                          T_NOTA->F2_DOC   ,;
                          T_NOTA->F2_SERIE ,;
                          T_NOTA->F2_VALBRUT})
         T_NOTA->( DbSkip() )
      ENDDO                            
   Endif

   // Carrega os produtos da primeira nota fiscal para display
   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_FILIAL ," + chr(13)
   cSql += "       A.D2_CLIENTE," + chr(13)
   cSql += "       A.D2_LOJA   ," + chr(13)
   cSql += "       A.D2_DOC    ," + chr(13)
   cSql += "       A.D2_SERIE  ," + chr(13)
   cSql += "       A.D2_ITEM   ," + chr(13)
   cSql += "       A.D2_COD    ," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       A.D2_UM     ," + chr(13)
   cSql += "       A.D2_QUANT  ," + chr(13)
   cSql += "       A.D2_PRCVEN ," + chr(13)
   cSql += "       A.D2_TOTAL   " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " B  " + chr(13)
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(aCabeca[1,1]) + "'" + chr(13)
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(_Cliente)     + "'" + chr(13)
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(_Loja)        + "'" + chr(13)
   cSql += "   AND A.D2_DOC     = '" + Alltrim(aCabeca[1,3]) + "'" + chr(13)
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(aCabeca[1,4]) + "'" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"       + chr(13)
   cSql += "   AND A.D2_COD     = B.B1_COD" + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"       + chr(13)
   cSql += " ORDER BY A.D2_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )
         aAdd( aDetalhe, { T_DETALHE->D2_ITEM  ,;
                           T_DETALHE->D2_COD   ,;
                           T_DETALHE->B1_DESC  ,;
                           T_DETALHE->D2_UM    ,;
                           T_DETALHE->D2_QUANT ,;
                           T_DETALHE->D2_PRCVEN,;
                           T_DETALHE->D2_TOTAL })
         T_DETALHE->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlgN TITLE "Notas Fiscais do Cliente" FROM C(178),C(181) TO C(499),C(569) PIXEL

   @ C(005),C(005) Say "Notas Fiscais do Cliente"            Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgN
   @ C(064),C(005) Say "Produtos da Nota Fiscal selecionada" Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlgN

   @ C(143),C(110) Button "Selecionar" Size C(037),C(012) PIXEL OF oDlgN ACTION( FechaPsq() )
   @ C(143),C(151) Button "Retornar"   Size C(037),C(012) PIXEL OF oDlgN ACTION( oDlgN:End() )

   @ 014,05 LISTBOX oCabeca FIELDS HEADER "Filial", "Emissao", "Nº N.Fiscal" ,"Série", "Valor Total" PIXEL SIZE 240,065 OF oDlgN ;
                            ON dblClick(aCabeca[oCabeca:nAt,1] := !aCabeca[oCabeca:nAt,1],oCabeca:Refresh())     
   oCabeca:SetArray( aCabeca )
   oCabeca:bLine := {||     {aCabeca[oCabeca:nAt,01],;
           		    		 aCabeca[oCabeca:nAt,02],;
         	         	     aCabeca[oCabeca:nAt,03],;
         	         	     aCabeca[oCabeca:nAt,04],;
         	         	     aCabeca[oCabeca:nAt,05]}}

   oCabeca:bLDblClick := {|| MSTPRODUTO(aCabeca[oCabeca:nAt,01], aCabeca[oCabeca:nAt,03], aCabeca[oCabeca:nAt,04], _Cliente, _Loja) } 

   @ 090,05 LISTBOX oDetalhe FIELDS HEADER "Item", "Código", "Descrição dos Produtos" ,"Und", "Qtd.", "Unitário", "Total" PIXEL SIZE 240,090 OF oDlgN ;
                            ON dblClick(aDetalhe[oDetalhe:nAt,1] := !aDetalhe[oDetalhe:nAt,1],oDetalhe:Refresh())     
   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||     {aDetalhe[oDetalhe:nAt,01],;
          		    		  aDetalhe[oDetalhe:nAt,02],;
          		    		  aDetalhe[oDetalhe:nAt,03],;
          		    		  aDetalhe[oDetalhe:nAt,04],;
          		    		  aDetalhe[oDetalhe:nAt,05],;
          		    		  aDetalhe[oDetalhe:nAt,06],;
          		    		  aDetalhe[oDetalhe:nAt,07]}}
   oDetalhe:Refresh()

   ACTIVATE MSDIALOG oDlgN CENTERED 

Return(.T.)                                                                                 

// Função que fecha a janela de pesquisa de notas fiscais do cliente informado
Static Function FechaPsq()

   xFilial := aCabeca[oCabeca:nAt,01]
   cNota   := aCabeca[oCabeca:nAt,03]
   cSerie  := aCabeca[oCabeca:nAt,04]
   
   oDlgN:End()   

   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()

   BSCFILIAL(xFilial)
   
   BSCNOTA1(xFilial, cNota, cSerie, cCliente, cLoja, 2)

Return(.T.)

// Função que pesquisa as notas fiscais do cliente informado
Static Function mstproduto(_Filial, _Nota, _Serie, _Cliente, _Loja, _Tipo)

   Local cSql 

   aDetalhe := {}

   If Select("T_DETALHE") > 0
      T_DETALHE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_FILIAL ," + chr(13)
   cSql += "       A.D2_CLIENTE," + chr(13)
   cSql += "       A.D2_LOJA   ," + chr(13)
   cSql += "       A.D2_DOC    ," + chr(13)
   cSql += "       A.D2_SERIE  ," + chr(13)
   cSql += "       A.D2_ITEM   ," + chr(13)
   cSql += "       A.D2_COD    ," + chr(13)
   cSql += "       B.B1_DESC   ," + chr(13)
   cSql += "       A.D2_UM     ," + chr(13)
   cSql += "       A.D2_QUANT  ," + chr(13)
   cSql += "       A.D2_PRCVEN ," + chr(13)
   cSql += "       A.D2_TOTAL   " + chr(13)
   cSql += "  FROM " + RetSqlName("SD2") + " A, " + chr(13)
   cSql += "       " + RetSqlName("SB1") + " B  " + chr(13)
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(_Filial)  + "'" + chr(13)
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(_Cliente) + "'" + chr(13)
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(_Loja)    + "'" + chr(13)
   cSql += "   AND A.D2_DOC     = '" + Alltrim(_Nota)    + "'" + chr(13)
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(_Serie)   + "'" + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''"       + chr(13)
   cSql += "   AND A.D2_COD     = B.B1_COD" + chr(13)
   cSql += "   AND B.D_E_L_E_T_ = ''"       + chr(13)
   cSql += " ORDER BY A.D2_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHE", .T., .T. )

   T_DETALHE->( DbGoTop() )
   
   If T_DETALHE->( EOF() )
      aAdd( aDetalhe, { "","","","","","","" })
   Else
      WHILE !T_DETALHE->( EOF() )
         aAdd( aDetalhe, { T_DETALHE->D2_ITEM  ,;
                           T_DETALHE->D2_COD   ,;
                           T_DETALHE->B1_DESC  ,;
                           T_DETALHE->D2_UM    ,;
                           T_DETALHE->D2_QUANT ,;
                           T_DETALHE->D2_PRCVEN,;
                           T_DETALHE->D2_TOTAL })
         T_DETALHE->( DbSkip() )
      ENDDO
   Endif

   oDetalhe:SetArray( aDetalhe )
   oDetalhe:bLine := {||     {aDetalhe[oDetalhe:nAt,01],;
          		    		  aDetalhe[oDetalhe:nAt,02],;
          		    		  aDetalhe[oDetalhe:nAt,03],;
          		    		  aDetalhe[oDetalhe:nAt,04],;
          		    		  aDetalhe[oDetalhe:nAt,05],;
          		    		  aDetalhe[oDetalhe:nAt,06],;
          		    		  aDetalhe[oDetalhe:nAt,07]}}
   oDetalhe:Refresh()
   
Return(.T.)

// Função que pesquisa os nºs de séries a serem devolvidos para o produto selecionado
Static Function BNSerie(_Marca, _Cliente, _Loja, _Filial, _Nota, _Serie, _Produto)

   Private oDlgS

   Private aSeries := {}
   Private oSeries
   Private oOk     := LoadBitmap( GetResources(), "LBOK" )
   Private oNo     := LoadBitmap( GetResources(), "LBNO" )

   If _Marca == .F.
      Return(.T.)
   Endif   

   If Select("T_SERIES") > 0
      T_SERIES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DB_NUMSERI"
   cSql += "  FROM " + RetSqlName("SDB")
   cSql += " WHERE DB_FILIAL  = '" + Alltrim(_Filial)  + "'"
   cSql += "   AND DB_PRODUTO = '" + Alltrim(_Produto) + "'"
   cSql += "   AND DB_DOC     = '" + Alltrim(_Nota)    + "'"
   cSql += "   AND DB_SERIE   = '" + Alltrim(_Serie)   + "'"
   cSql += "   AND DB_CLIFOR  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND DB_LOJA    = '" + Alltrim(_Loja)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''
   cSql += " ORDER BY DB_NUMSERI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

   If T_SERIES->( EOF() )
      aAdd( aSeries, { .F., "" } )
   Else
      T_SERIES->( DbGoTop() )
      WHILE !T_SERIES->( EOF() )
         aAdd( aSeries, { .F.                  ,;
                          T_SERIES->DB_NUMSERI ,;
                          _Cliente             ,;
                          _Loja                ,;
                          _Filial              ,;
                          _Nota                ,;
                          _Serie               ,;
                          _Produto             })
         T_SERIES->( DbSkip() )
      ENDDO
   Endif

   // Posiciona no array aNumSerie para marcar os nºs de séries que já foram marcados anteriormente
   For nContar = 1 to Len(aSeries)

       For nProcura = 1 to Len(aNumSerie)

           If aNumSerie[nProcura,01] == _Cliente .And. ;
              aNumSerie[nProcura,02] == _Loja    .And. ;
              aNumSerie[nProcura,03] == _Filial  .And. ;
              aNumSerie[nProcura,04] == _Nota    .And. ;
              aNumSerie[nProcura,05] == _Serie   .And. ;
              aNumSerie[nProcura,06] == _Produto .And. ;
              aNumSerie[nProcura,07] == aSeries[nContar,02]
              aSeries[nContar,01] := aNumSerie[nProcura,08] 
              Exit
           Endif

       Next nProcura
          
   Next nContar    

   DEFINE MSDIALOG oDlgS TITLE "Nºs de Séries" FROM C(178),C(181) TO C(534),C(450) PIXEL

   @ C(005),C(005) Say "Indique os nº de Séries a serem devolvidos" Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(162),C(091) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgS:End() )

   // Cria Componentes Padroes do Sistema
   @ 015,005 LISTBOX oSeries FIELDS HEADER "", "Nºs de Séries" PIXEL SIZE 160,188 OF oDlgS ;
                            ON dblClick(aSeries[oSeries:nAt,1] := !aSeries[oSeries:nAt,1],oSeries:Refresh())     
   oSeries:SetArray( aSeries )
   oSeries:bLine := {||     {Iif(aSeries[oSeries:nAt,01],oOk,oNo),;
       	        	             aSeries[oSeries:nAt,02]}}

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)