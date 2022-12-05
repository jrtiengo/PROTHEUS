#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM226.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 31/03/2014                                                          *
// Objetivo..: Programa que atualiza o Financeiro com dados das RMA's              *
//**********************************************************************************

User Function AUTOM226()

   Local cSql        := ""
   Local lVendedor   := .F.

   Private aNumSerie := {}

   Private aVendedor := {}
   Private aStatus   := {"0 - Todos (Abertos/Encerrados)", "5 - RMA's Abertas", "4 - RMA's Encerradas"}
   Private cComboBx1
   Private cComboBx2
   Private cInicial	 := Ctod("01/01/" + Strzero(Year(Date()),4))
   Private cFinal	 := Date()
   Private cGet3	 := Space(25)
   Private cMemo1	 := ""
   Private cMemo2	 := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1
   Private oMemo2

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

   // Pesquisa a tabela de vendedores para popular o combo de vendedores
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT DISTINCT A.A3_COD ,"
   cSql += "       A.A3_NOME"
   cSql += "  FROM " + RetSqlName("SA3") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += "   AND A.A3_COD IN (SELECT DISTINCT CT_VEND FROM " + RetSqlName("SCT") + " WHERE CT_VEND = A.A3_COD)"
   cSql += "   AND A.A3_COD <> ''"

   If __Cuserid <> "000000"
      cSql += " AND A.A3_CODUSR = '" + Alltrim(__CUSERID) + "'"
   Endif

   cSql += " ORDER BY A.A3_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   aAdd( aVendedor, "000000 - Todos os Vendedores" )

   T_VENDEDOR->( DbGoTop() )
   WHILE !T_VENDEDOR->( EOF() )
      aAdd( aVendedor, T_VENDEDOR->A3_COD + " - " + Alltrim(T_VENDEDOR->A3_NOME) )
      T_VENDEDOR->( DbSkip() )
   ENDDO

   lVendedor := .T.

   PsqGridFinan(1, Substr(aVendedor[1],1,6), "0")

   DEFINE MSDIALOG oDlg TITLE "RMA - Return Merchandise Authorization" FROM C(178),C(181) TO C(633),C(967) PIXEL

   @ C(003),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlg

   @ C(022),C(288) Say "R M A - Return Merchandise Authorization" Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(003) Say "Data Inicial"                             Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(044) Say "Data Final"                               Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(083) Say "Vendedor"                                 Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(236) Say "Status"                                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(031),C(001) GET oMemo1 Var cMemo1 MEMO Size C(387),C(001) PIXEL OF oDlg
   @ C(057),C(001) GET oMemo2 Var cMemo2 MEMO Size C(387),C(001) PIXEL OF oDlg

   @ C(044),C(003) MsGet oGet1 Var cInicial Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(044) MsGet oGet2 Var cFinal   Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(083) ComboBox cComboBx1 Items aVendedor When lVendedor Size C(146),C(010) PIXEL OF oDlg
   @ C(044),C(236) ComboBox cComboBx2 Items aStatus                  Size C(110),C(010) PIXEL OF oDlg

   @ C(041),C(352) Button "Atualizar"  Size C(036),C(012) PIXEL OF oDlg ACTION( PsqGridFinan(0, Substr(aVendedor[1],1,6), Substr(cComboBx2,1,1) ) )
   @ C(212),C(003) Button "Encerrar"   Size C(037),C(012) PIXEL OF oDlg ACTION( EncerraRMA(aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,01] ) )
   @ C(212),C(044) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlg ACTION( AbreRMAMan("V", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,01]) )
   @ C(212),C(085) Button "Legenda"    Size C(037),C(012) PIXEL OF oDlg ACTION( LegendaRMA() )
   @ C(212),C(351) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 080 , 003, 495, 185,,{'Lg ', 'RMA', 'ANO', 'Data', 'Hora', 'Cliente', 'Loja', 'Descrição dos Clientes', 'Filial', 'Nota', 'Série', 'Informação ref. ao Crédito', 'Filial', 'Nota', 'Série', 'Vendedor', 'Descrição dos Vendedores'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))),;
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;
                         aBrowse[oBrowse:nAt,13]            ,;
                         aBrowse[oBrowse:nAt,14]            ,;
                         aBrowse[oBrowse:nAt,15]            ,;
                         aBrowse[oBrowse:nAt,16]            ,;
                         aBrowse[oBrowse:nAt,17]           } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Encerra a RMA selecionada
Static Function EncerraRMA(_RMA, _Ano, _Status)

   If _Status == "4"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "RMA já encerrada. Processo não permitido.")
      Return(.T.)
   Endif

   If MsgYesNo("Confirma o encerramento da RMA selecionada?")
		//Alterado Michel Aoki - 29/09/2014
       cSql := ""
       cSql := "UPDATE " + RetSqlName("ZS4") + CHR(13)
       cSql += "   SET " + CHR(13)
       cSql += "   ZS4_STAT  = '4' "+ CHR(13)
       cSql += " WHERE ZS4_FILIAL = '" + xFilial("ZS4")               + "'" + CHR(13)
       cSql += "   AND ZS4_NRMA   = '" +_RMA                          + "'" + CHR(13)
       cSql += "   AND ZS4_ANO    = '" + _ANO                         + "'" + CHR(13)
       cSql += "   AND D_E_L_E_T_ = ' '                                   " + CHR(13)

       lResult := TCSQLEXEC(cSql)
       If lResult < 0
          Return MsgStop("Erro durante o encerramento." + TCSQLError())
       EndIf 
/*
      dbSelectArea("ZS4")
	  dbSetOrder(1)
	  If dbSeek(xFilial("ZS4") + _RMA + _ANO)
         RecLock("ZS4",.F.)
         ZS4_STAT := '4'
         MsUnLock()              
      Endif
  */       
      PsqGridFinan(0, Substr(aVendedor[1],1,6), Substr(cComboBx2,1,1) )
      
   Endif

Return(.T.)

// Função que pesquisa os dados para carregar o grid
Static Function PsqGridFinan(_Tipo, _Vendedor, _Status)

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
   cSql += "       A.ZS4_NFIL,"
   cSql += "       A.ZS4_NOTA,"
   cSql += "       A.ZS4_SERI,"
   cSql += "       A.ZS4_APRO,"
   cSql += "       A.ZS4_CRED,"
   cSql += "       A.ZS4_CREF,"
   cSql += "       A.ZS4_CREN,"
   cSql += "       A.ZS4_CRES "
   cSql += "  FROM " + RetSqlName("ZS4") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("SA3") + " C  "
   cSql += " WHERE A.ZS4_CLIE   = B.A1_COD "
   cSql += "   AND A.ZS4_LOJA   = B.A1_LOJA"
   cSql += "   AND A.ZS4_ABER  >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)" 
   cSql += "   AND A.ZS4_ABER  <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"

   If _Tipo == 1
   Else   
      If Substr(cComboBx1,01,06)  <> "000000"
         cSql += "   AND A.ZS4_VEND   = '" + Alltrim(Substr(cComboBx1,01,06)) + "'"
      Endif
   Endif

   // Status
   If _Status == "0"
      cSql += "  AND A.ZS4_STAT IN ('5', '4')"
   Else
      cSql += "  AND A.ZS4_STAT = '" + Alltrim(_Status) + "'"   
   Endif

   cSql += "   AND B.D_E_L_E_T_ = ''       "
   cSql += "   AND A.ZS4_VEND   = C.A3_COD "
   cSql += "   AND C.D_E_L_E_T_ = ''       "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

   If T_DADOS->( EOF() )
      aAdd( aBrowse, { "1", "","","","","","","","","","","","","" })
   Else
   
      T_DADOS->( DbGoTop() )
      
      WHILE !T_DADOS->( EOF() )
      
         // Tipo de Crédito
         Do Case
            Case T_DADOS->ZS4_CRED == "01"
                 cNomeCredito := "01 - Encontro com NF original"
            Case T_DADOS->ZS4_CRED == "02"
                 cNomeCredito := "02 - Encontro com NF nova"
            Case T_DADOS->ZS4_CRED == "03"
                 cNomeCredito := "03 - Encontro com outra NF"
            Case T_DADOS->ZS4_CRED == "04"
                 cNomeCredito := "04 - Cliente ficou com crédito"
            Case T_DADOS->ZS4_CRED == "05"
                 cNomeCredito := "05 - Cliente vai receber em espécie"
         EndCase                 

         // Carrega o Array
         aAdd( aBrowse, { T_DADOS->ZS4_STAT,;
                          T_DADOS->ZS4_NRMA,;
                          T_DADOS->ZS4_ANO ,;
                          Substr(T_DADOS->ZS4_ABER,07,02) + "/" + Substr(T_DADOS->ZS4_ABER,05,02) + "/" + Substr(T_DADOS->ZS4_ABER,01,04) ,;
                          T_DADOS->ZS4_HORA,;
                          T_DADOS->ZS4_CLIE,;
                          T_DADOS->ZS4_LOJA,;
                          T_DADOS->A1_NOME ,;
                          T_DADOS->ZS4_NFIL,;
                          T_DADOS->ZS4_NOTA,;
                          T_DADOS->ZS4_SERI,;
                          cNomeCredito     ,;
                          T_DADOS->ZS4_CREF,;
                          T_DADOS->ZS4_CREN,;
                          T_DADOS->ZS4_CRES,;
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
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))),;                         
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;
                         aBrowse[oBrowse:nAt,13]            ,;
                         aBrowse[oBrowse:nAt,14]            ,;
                         aBrowse[oBrowse:nAt,15]            ,;
                         aBrowse[oBrowse:nAt,16]            ,;
                         aBrowse[oBrowse:nAt,17]           } }

Return(.T.)

// Abre tela de manutenção da RMA
Static Function AbreRMAMan(_Tipo, _RMA, _ANO, _STATUS)

   Local lChumba     := .F.
   Local nContar     := 0
   Local lAbre       := .F.
   Local lAprova     := .F.
   Local lContato    := .T.

   Private lDados    := .F.
   Private aComboBx1 := U_AUTOM539(2, cEmpant) // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private aComboBx2 := {"01 - Encontro com NF. Original", "02 - Encontro com NF. Nova", "03 - Encontro com outra NF. (Especificar)", "04 - Cliente ficou com crédito", "05 - Cliente vai receber em espécie (Somente se for devolvido até 7 dias ou com autuorização)"}
   Private aSituacao := {}
   Private aProvador := {}
   Private aMotivo   := {}
   Private aMotivoA  := {}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx4
   Private cComboBx5   
   Private cComboBx6   
   Private cComboBx7   

   Private cDataP        := Ctod("  /  /    ")
   Private cHoraP        := ""

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
   Private yTipo         := 0
   Private yTipoRMA      := Space(06)
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

   Private nTroca    := 0
   Private nCodTroca := Space(06)
   Private aTipoRma  := {}
   Private cHelpRma  := "" 
   Private oHelpRma

   // Carrega o ComboBox de Motivos da RMA
   If Select("T_MOTIVO") > 0
      T_MOTIVO->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZS6_CODI, "
   cSql += "       ZS6_DESC  "
   cSql += "  FROM " + RetSqlName("ZS6")
   cSql += " WHERE ZS6_DELE = ''"
   cSql += " ORDER BY ZS6_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

   If T_MOTIVO->( EOF() )
      MsgAlert("Atenção! Cadastro de Motivos de RMA está vazio. Cadastre primeiramente os motivos antes de continuar o cadastramento da RMA.")
      Return(.T.)
   Endif

   aAdd( aMotivo, "000000 - Selecione o Motivo da RMA" )
   
   T_MOTIVO->( DbGoTop() )
   WHILE !T_MOTIVO->( EOF() )
      aAdd(aMotivo,  T_MOTIVO->ZS6_CODI + " - " + T_MOTIVO->ZS6_DESC )   
      T_MOTIVO->( DbSkip() )
   ENDDO

   // Carrega o ComboBox de Motivos de Aprovação/Reprovação/Revisão
   If Select("T_MOTIVO") > 0
      T_MOTIVO->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZS7_CODI, "
   cSql += "       ZS7_DESC  "
   cSql += "  FROM " + RetSqlName("ZS7")
   cSql += " WHERE ZS7_DELE = ''"
   cSql += " ORDER BY ZS7_DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

   If T_MOTIVO->( EOF() )
      MsgAlert("Atenção! Cadastro de Motivos de Aprovação/Reprovação/Revisão de RMA está vazio. Cadastre primeiramente os motivos antes de continuar o cadastramento da RMA.")
      Return(.T.)
   Endif

   aAdd( aMotivoA, "000000 - Selecione o Motivo" )
   
   T_MOTIVO->( DbGoTop() )
   WHILE !T_MOTIVO->( EOF() )
      aAdd(aMotivoA,  T_MOTIVO->ZS7_CODI + " - " + T_MOTIVO->ZS7_DESC )   
      T_MOTIVO->( DbSkip() )
   ENDDO

   If _Tipo == "I"

      If Select("T_TIPORMA") > 0
         T_TIPORMA->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZS8_CODI,"
      cSql += "       ZS8_DESC,"
      cSql += "       ZS8_TIPO,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZS8_HELP)) AS OBSERVACAO"
      cSql += "  FROM " + RetSqlName("ZS8")
      cSql += " WHERE ZS8_DELE = ''"
      cSql += " ORDER BY ZS8_DESC"  

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPORMA", .T., .T. )

      If T_TIPORMA->( EOF() )
         MsgAlert("Atenção! Inclusão não permitida. O Cadastro de Tipos de RMA está vazio. Entre em contato com o Administrador do Sistema.")
         Return(.T.)
      Endif

      WHILE !T_TIPORMA->( EOF() )
         aAdd( aTipoRma, { T_TIPORMA->ZS8_CODI,;
                           T_TIPORMA->ZS8_DESC,;
                           T_TIPORMA->ZS8_TIPO,;
                           T_TIPORMA->OBSERVACAO})
         T_TIPORMA->( DbSkip() )
      ENDDO

      MSTHELPRMA( aTipoRma[01,04], 1 )  

      DEFINE MSDIALOG oDlgT TITLE "Tipo de Inclusão de RMA" FROM C(178),C(181) TO C(481),C(627) PIXEL

  	  @ C(005),C(005) Say "Informe o tipo de RMA que será incluída"                                         Size C(098),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
	  @ C(075),C(005) Say "Help do tipo de RMA selecionado (Duplo click sobre o tipo para visualizar Help)" Size C(190),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

      @ C(084),C(005) GET oHelpRma Var cHelpRma MEMO When lChumba Size C(211),C(048) PIXEL OF oDlgT

	  @ C(135),C(179) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgT ACTION( nTroca := aTipoRma[oTipoRma:nAt,03], nCodTroca := aTipoRma[oTipoRma:nAt,01], oDlgT:End() )

      oTipoRma := TCBrowse():New( 015 , 005, 275, 080,,{'Código', 'Descrição Tipos RMA'},{20,50,50,50},oDlgT,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

      // Seta vetor para a browse                            
      oTipoRma:SetArray(aTipoRma) 
    
      // Monta o grid com os tipos de RMA
      oTipoRma:bLine := {||{ aTipoRma[oTipoRma:nAt,01], aTipoRma[oTipoRma:nAt,02]} }

      oTipoRma:bLDblClick := {|| MSTHELPRMA(aTipoRma[oTipoRma:nAt,04],2) } 
      
      ACTIVATE MSDIALOG oDlgT CENTERED 

      yTipo    := INT(VAL(nTroca))

      If yTipo == 0
         yTipo := 1
      Endif
         
      yTipoRma := nCodTroca

   Else

      If _Status == "2"
         If _Tipo == "V"
         Else
            If _Tipo == "A"
               MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA já foi aprovada. Alteração não permitida." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
               Return(.T.)
            Endif
         Endif
      Endif

      If _Status == "3"
         If _Tipo == "V"
         Else
            If _Tipo == "A" .OR. _Tipo == "E"
               If _Tipo == "A"
                  MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA encerrada por data de validade expirada. Alteração não permitida." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
               Else
                  MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA encerrada por data de validade expirada. Exclusão não permitida." + chr(13) + chr(10) + "Utilize a opção Visualizar.")                  
               Endif
               Return(.T.)
            Endif
         Endif
      Endif

      If _Status == "7"
         If _Tipo == "V"
         Else
            MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA não pode ser alterada/excluída pois a mesma foi Recusada." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
            Return(.T.)
         Endif
      Endif

      If _Status == "5"
         If _Tipo == "V"
         Else
            MsgAlert("Atenção!" + chr(13) + chr(10) + "RMA não pode ser alterada/excluída pois já está encerrada." + chr(13) + chr(10) + "Utilize a opção Visualizar.")
            Return(.T.)
         Endif
      Endif

   Endif

   If _Tipo == "I"
      lAbre     := .T.
      lContato  := .T.
      
      cNRMA	    := Space(05)
      cARMA	    := Space(04)
      cAbertura := date()
      cHora	    := time()
      cVendedor := aVendedor[1]
      cCliente  := Space(06)
      cLoja	    := Space(03)
      cNota	    := Space(06)
      cSerie	:= Space(03)
      cDCliente := Space(100)
      cTelefone := Space(20)
      cEmailCli := Space(100)
      cContato  := Space(06)
      cNomeCon  := Space(40)
      yFilial	:= Space(02)
      yNota	    := Space(06)
      ySerie	:= Space(03)
      aAdd( aSituacao, "1 - Abertura" )
   Endif

   // Alteração
   If _Tipo == "A" .Or. _Tipo == "E" .Or. _Tipo == "V"

      Do Case
         Case _Tipo == "E"
              lAbre    := .F.
              lcontato := .F.
         Case _Tipo == "V"
              lAbre    := .F.
              lContato := .F.
         Case _Tipo == "A"
              lContato := .T.
              lAbre    := .F.
      EndCase

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
      cSql += "       A.ZS4_CMOT,"
      cSql += "       A.ZS4_CMTA,"
      cSql += "       A.ZS4_TIPO,"
      cSql += "       A.ZS4_CTIP,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_MOTI)) AS MOTIVO,"
      cSql += "       D.U5_CONTAT,"
      cSql += "       E.B1_DESC  ,"
      cSql += "       E.B1_DAUX  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)) AS SERIES, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
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
      cSql += " ORDER BY A.ZS4_ITEM"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DADOS", .T., .T. )

      cNRMA	    := _RMA
      cARMA	    := _ANO
      cAbertura := Ctod(Substr(T_DADOS->ZS4_ABER,07,02) + '/' + Substr(T_DADOS->ZS4_ABER,05,02) + '/' + Substr(T_DADOS->ZS4_ABER,01,04))
      cHora	    := T_DADOS->ZS4_HORA
      cVendedor := T_DADOS->ZS4_VEND + " - " + Alltrim(T_DADOS->A3_NOME)
      cCliente  := T_DADOS->ZS4_CLIE 
      cLoja	    := T_DADOS->ZS4_LOJA
      cDCliente := T_DADOS->A1_NOME
      cTelefone := T_DADOS->ZS4_TELE
      cContato  := T_DADOS->ZS4_CONT
      cNomeCon  := T_DADOS->U5_CONTAT
      cEmailCli := T_DADOS->ZS4_EMAI
      xFilial   := T_DADOS->ZS4_NFIL
      cNota	    := T_DADOS->ZS4_NOTA
      cSerie	:= T_DADOS->ZS4_SERI
      yFilial	:= T_DADOS->ZS4_CREF
      yNota	    := T_DADOS->ZS4_CREN
      ySerie	:= T_DADOS->ZS4_CRES
      cMemo2    := T_DADOS->MOTIVO
      yTipo     := T_DADOS->ZS4_TIPO
      yTipoRma  := T_DADOS->ZS4_CTIP
   
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

      If Empty(Alltrim(T_DADOS->ZS4_APRO))
         aAdd(aProvador, "" )
         cDataP        := Ctod("  /  /    ")
         cHoraP        := ""
         cConsideracao := ""
      Else
         aAdd(aProvador, T_DADOS->ZS4_APRO )         
         cDataP        := Substr(T_DADOS->ZS4_DLIB,07,02) + "/" + Substr(T_DADOS->ZS4_DLIB,05,02) + "/" + Substr(T_DADOS->ZS4_DLIB,01,04)
         cHoraP        := T_DADOS->ZS4_HLIB
         cConsideracao := T_DADOS->OBSERVACAO
      Endif

      Do Case
         Case T_DADOS->ZS4_STAT == "1"
              aAdd( aSituacao, "1 - Abertura" ) 
         Case T_DADOS->ZS4_STAT == "2"
              aAdd( aSituacao, "2 - Aprovado" ) 
         Case T_DADOS->ZS4_STAT == "3"
              aAdd( aSituacao, "3 - Cancelada" ) 
         Case T_DADOS->ZS4_STAT == "8"
              aAdd( aSituacao, "8 - Revisão" ) 
         Case T_DADOS->ZS4_STAT == "7"
              aAdd( aSituacao, "7 - Recusado" ) 
         Case T_DADOS->ZS4_STAT == "6"
              aAdd( aSituacao, "6 - Aguardando Doc Retorno" )
         Case T_DADOS->ZS4_STAT == "5"
              aAdd( aSituacao, "5 - Processo Finalizado" )
      EndCase

      // Posiciona o tipo de crédito
      For nContar = 1 to Len(aComboBx2)
          If Substr(aComboBx2[nContar],01,02) == T_DADOS->ZS4_CRED
             cComboBx2 := aComboBx2[nContar]
             EXIT
          Endif
      Next nontar

      // Posiciona o tipo de Motivo da RMA
      For nContar = 1 to Len(aMotivo)
          If Substr(aMotivo[nContar],01,06) == T_DADOS->ZS4_CMOT
             cComboBx6 := aMotivo[nContar]
             EXIT
          Endif
      Next nontar

      // Posiciona o tipo de Motivo da Aprovação/Reprovação/Revisão de RMA
      For nContar = 1 to Len(aMotivoA)
          If Substr(aMotivoA[nContar],01,06) == T_DADOS->ZS4_CMTA
             cComboBx7 := aMotivoA[nContar]
             EXIT
          Endif
      Next nontar

      // Carrega os Produtos
      aProdutos := {}
      aNumSerie := {}

      WHILE !T_DADOS->( EOF() )
         aAdd( aProdutos, { IIF(T_DADOS->ZS4_CHEK == "1", .T., .F.)                     ,;
                            T_DADOS->ZS4_ITEM                                           ,;
                            T_DADOS->ZS4_PROD                                           ,;
                            Alltrim(T_DADOS->B1_DESC) + ' ' + Alltrim(T_DADOS->B1_DAUX) ,;  
                            T_DADOS->ZS4_QUAN                                           ,;
                            T_DADOS->ZS4_UNIT                                           ,;
                            T_DADOS->ZS4_TOTA  })

         // Carrega o array dos números de séries
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

   Endif

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
   @ C(132),C(005) Say "Motivo da RMA"               Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(132),C(156) Say "Informações Ref. ao Crédito" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(005) Say "Detalhes do Motivo da RMA"   Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(156) Say "Filial"                      Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(174) Say "N.Fiscal"                    Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(210) Say "Série"                       Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(192),C(125) Say "Motivo"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(204),C(083) Say "Considerações"               Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(205),C(005) Say "Data"                        Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(215),C(005) Say "Hora"                        Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(192),C(005) Say "Aprovador"                   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1     Var   cNRMA       When lChumba  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(031) MsGet    oGet2     Var   cARMA       When lChumba  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(061) MsGet    oGet3     Var   cAbertura   When lChumba  Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(105) MsGet    oGet4     Var   cHora       When lChumba  Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(148) MsGet    oGet5     Var   cVendedor   When lChumba  Size C(070),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(224) ComboBox cComboBx4 Items aSituacao   When lChumba  Size C(064),C(010) PIXEL OF oDlg
   @ C(035),C(005) MsGet    oGet6     Var   cCliente    When lAbre    Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(035),C(033) MsGet    oGet7     Var   cLoja       When lAbre    Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(BSCCLIRMA(cCliente, cLoja))
   @ C(035),C(057) MsGet    oGet15    Var   cDCliente   When lChumba  Size C(161),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(224) MsGet    oGet16    Var   cTelefone   When lChumba  Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(053),C(005) MsGet    oGet18    Var   cContato    When lChumba  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(053),C(033) Button "..."                         When lContato Size C(010),C(009) PIXEL OF oDlg ACTION( TRZCONTATO(cCliente, cLoja) )
   @ C(053),C(047) MsGet    oGet19    Var   cNomeCon    When lChumba  Size C(087),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   If _Tipo == "A"
      @ C(053),C(140) MsGet    oGet17    Var   cEmailCli                 Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   Else
      @ C(053),C(140) MsGet    oGet17    Var   cEmailCli   When lAbre    Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   Endif      

   @ C(072),C(005) MsGet    oGet10    Var   xFilial     When lAbre    Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID(BSCFILIAL(xFilial))
   @ C(072),C(022) MsGet    oGet11    Var   nFilial     When lChumba  Size C(088),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(072),C(114) MsGet    oGet8     Var   cNota       When lAbre    Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(072),C(159) MsGet    oGet9     Var   cSerie      When lAbre    Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(070),C(181) Button   "Pesquisar"                 When lAbre    Size C(050),C(012) PIXEL OF oDlg ACTION( BSCNOTA1(xFilial, cNota, cSerie, cCliente, cLoja, 2))
   @ C(070),C(238) Button   "Pesq. NFs Cliente"         When lAbre    Size C(050),C(012) PIXEL OF oDlg ACTION( BSCNOTA2(cCliente, cLoja) )
   @ C(163),C(005) GET      oMemo2    Var   cMemo2 MEMO When lAbre    Size C(147),C(020) PIXEL OF oDlg
   @ C(141),C(005) ComboBox cComboBx6 Items aMotivo     When lAbre    Size C(147),C(010) PIXEL OF oDlg
   @ C(141),C(156) ComboBox cComboBx2 Items aComboBx2   When lContato Size C(133),C(010) PIXEL OF oDlg VALID( LibCampo(cComboBx2) )
   @ C(164),C(156) MsGet    oGet12    Var   yFilial     When lDados   Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(164),C(174) MsGet    oGet13    Var   yNota       When lDados   Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(164),C(210) MsGet    oGet14    Var   ySerie      When lDados   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(186),C(005) GET      oMemo3    Var   cMemo3 MEMO When lAbre    Size C(283),C(001) PIXEL OF oDlg

   @ C(104),C(255) Button "Quantidade" Size C(034),C(012) PIXEL OF oDlg ACTION( AlteQuant(aProdutos[oProdutos:nAt,02], aProdutos[oProdutos:nAt,03], aProdutos[oProdutos:nAt,04], aProdutos[oProdutos:nAt,05], aProdutos[oProdutos:nAt,06], aProdutos[oProdutos:nAt,07], aProdutos[oProdutos:nAt,01]) )
   @ C(118),C(255) Button "Nº Séries"  Size C(034),C(012) PIXEL OF oDlg ACTION( BscNrSerie(aProdutos[oProdutos:nAt,01], cCliente, cLoja, xFilial, cNota, cSerie, aProdutos[oProdutos:nAt,03] ) )

   Do Case
      Case _Tipo == "I"
           @ C(156),C(251) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaRMA(_Tipo) )
      Case _Tipo == "A"
           @ C(156),C(251) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaRMA(_Tipo) )
      Case _Tipo == "E"           
           @ C(156),C(251) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaRMA(_Tipo) )
   EndCase

   @ C(170),C(251) Button "Retornar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Aprovação/Reprovação
   @ C(190),C(035) ComboBox cComboBx5 Items aProvador   When lAprova Size C(086),C(010) PIXEL OF oDlg

   @ C(190),C(144) ComboBox cComboBx7 Items aMotivoA           When lAprova Size C(104),C(010) PIXEL OF oDlg
   @ C(203),C(124) GET      oMemo4    Var   cConsideracao MEMO When lAprova Size C(123),C(021) PIXEL OF oDlg
   @ C(203),C(035) MsGet    oGet20    Var   cDataP             When lAprova Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(215),C(035) MsGet    oGet21    Var   cHoraP             When lAprova Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(189),C(251) Button "Aprovar"                            When lAprova Size C(037),C(008) PIXEL OF oDlg
   @ C(198),C(251) Button "Revisar"                            When lAprova Size C(037),C(008) PIXEL OF oDlg
   @ C(207),C(251) Button "Reprovar"                           When lAprova Size C(037),C(008) PIXEL OF oDlg
   @ C(217),C(251) Button "Retornar"                           When lAprova Size C(037),C(008) PIXEL OF oDlg

   If _Tipo == "I"
      aAdd( aProdutos, { .F., "","","","","","" } )
   Endif

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

// Função que mostra o help do tipo de RMA selecionado
Static Function MSTHELPRMA(_Observacao, _Mostra)

   cHelpRma := _Observacao

   If _Mostra == 2
      oHelpRma:Refresh()
   Endif   

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
      aAdd( aProdutos, { IIF(yTipo == 1, .F., .T.) ,;
                         T_NOTA->D2_ITEM           ,;
                         T_NOTA->D2_COD            ,;
                         T_NOTA->DESCRICAO         ,;  
                         T_NOTA->D2_QUANT          ,;
                         T_NOTA->D2_PRCVEN         ,;
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
Static Function BscNrSerie(_Marca, _Cliente, _Loja, _Filial, _Nota, _Serie, _Produto)

   Private oDlgS

   Private aSeries := {}
   Private oSeries
   Private oOk     := LoadBitmap( GetResources(), "LBOK" )
   Private oNo     := LoadBitmap( GetResources(), "LBNO" )

   If _Marca == .F.
      MsgAlert("Atenção! Produto não foi marcado para ser utilizado na RMA.")
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

   @ C(162),C(005) Button "Marca Todos"    Size C(037),C(012) PIXEL OF oDlgS ACTION(MrcSerie(1))
   @ C(162),C(044) Button "Desmarca Todos" Size C(045),C(012) PIXEL OF oDlgS ACTION(MrcSerie(2))
   @ C(162),C(091) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgS ACTION( FechaNrSerie(_Cliente, _Loja, _Filial, _Nota, _Serie, _Produto) )

   // Cria Componentes Padroes do Sistema
   @ 015,005 LISTBOX oSeries FIELDS HEADER "", "Nºs de Séries" PIXEL SIZE 160,188 OF oDlgS ;
                            ON dblClick(aSeries[oSeries:nAt,1] := !aSeries[oSeries:nAt,1],oSeries:Refresh())     
   oSeries:SetArray( aSeries )
   oSeries:bLine := {||     {Iif(aSeries[oSeries:nAt,01],oOk,oNo),;
       	        	             aSeries[oSeries:nAt,02]}}

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// Função que marca e desmarca os nºs de séries
Static Function MrcSerie(_Tipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aSeries)
       aSeries[nContar,01] := IIF(_Tipo == 1, .T., .F.)
   Next nContar
   
Return(.T.)       

// Função que carrega o array aNumSerie e fecha a janela de nºs de séries
Static Function FechaNrSerie(_Cliente, _Loja, _Filial, _Nota, _Serie, _Produto)
   
   Local nContar  := 0
   Local bProcura := 0
   Local _NumeroS := ""

   Private aTransito := {}
   
   // Grava os nº de séries do array aNumSerie
   lExiste := .F.

   For nContar = 1 to Len(aSeries)

       For nProcura = 1 to Len(aNumSerie)

           If Alltrim(aNumSerie[nProcura,01]) == Alltrim(_Cliente)            .And. ;
              Alltrim(aNumSerie[nProcura,02]) == Alltrim(_Loja)               .And. ;
              Alltrim(aNumSerie[nProcura,03]) == Alltrim(_Filial)             .And. ;
              Alltrim(aNumSerie[nProcura,04]) == Alltrim(_Nota)               .And. ;
              Alltrim(aNumSerie[nProcura,05]) == Alltrim(_Serie)              .And. ;
              Alltrim(aNumSerie[nProcura,06]) == Alltrim(_Produto)            .And. ;
              Alltrim(aNumSerie[nProcura,07]) == Alltrim(aSeries[nContar,02])
              aNumSerie[nProcura,08]          := aSeries[nContar,01]
              lExiste := .T.
              Exit
           Endif

       Next nProcura
       
       If lExiste == .F.
          aAdd( aNumSerie, { _Cliente           ,;
                             _Loja              ,;
                             _Filial            ,;
                             _Nota              ,;
                             _Serie             ,;
                             _Produto           ,;
                             aSeries[nContar,02],;
                             aSeries[nContar,01]})
                             
       Endif

       lExiste := .F.
       
   Next nContar    

   oDlgS:End()
   
Return(.T.)

// Função que envoia o e-mail ao Cliente
Static Function MandaEmailCli(_RMA, _ANO, _Vendedor, _Status)

   Local cTexto    := ""
   Local _TCredito := ""
   Local _Ncredito := ""
   Local _Scredito := ""
   Local _nErro    := 0

   If _Status <> '2' .And. _Status <> '6' .And. _Status <> '5'
      MsgAlert("Impressão da RMA não permitida para este Status.")
      Return(.T.)
   Endif

   // Envia para o programa de emissão do formulário de RMA
   U_AUTOM220(_RMA, _ANO)
                         
   If Select("T_IMPRESSA") > 0
      T_IMPRESSA->( dbCloseArea() )
   EndIf
  
   cSql := ""
   cSql += "SELECT ZS4_IMPR"
   cSql += "  FROM " + RetSqlName("ZS4")
   cSql += " WHERE ZS4_NRMA   = '" + Alltrim(_RMA) + "'"
   cSql += "   AND ZS4_ANO    = '" + Alltrim(_ANO) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IMPRESSA", .T., .T. )

   If Alltrim(T_IMPRESSA->ZS4_IMPR) <> ''
      Return(.T.)
   Endif

   // Altera o Status da RMA
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZS4")
   cSql += "   SET "
   cSql += "   ZS4_STAT = '6',"
   cSql += "   ZS4_IMPR = 'X' "
   cSql += " WHERE ZS4_NRMA = '" + Alltrim(_RMA) + "'"
   cSql += "   AND ZS4_ANO  = '" + Alltrim(_ANO) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   PsqGridDados(0, Substr(_Vendedor,01,06), "0")

   RETURN(.T.)
   
   // Temporariamente suspenso o envio de e-mail

   If Empty(Alltrim(_RMA))
      Return(.T.)
   Endif
      
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
   cSql += "       ISNULL(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_NSER)), '') AS SERIES, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZS4_CONS)) AS OBSERVACAO "
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

   If T_DADOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Reutnr(.T.)
   Endif
   
   // Verifica o Status da RMA
   Do Case
      Case T_DADOS->ZS4_STAT == "1"
           MsgAlert("RMA aguardando aprovação. Envio de informação ao Cliente não autorizada.")
           Return(.T.)
      Case T_DADOS->ZS4_STAT == "8"
           MsgAlert("RMA aguardando revisão. Envio de informação ao Cliente não autorizada.")
           Return(.T.)
      Case T_DADOS->ZS4_STAT == "7"
           MsgAlert("RMA Recusada. Envio de informação ao Cliente não autorizada.")
           Return(.T.)

      Case T_DADOS->ZS4_STAT == "6"
 		   If MsgYesNo("Informação de dados da RMA já enviada ao Cliente. Deseja enviar os dados novamente?")
 		   Else
              Return(.T.)
           Endif
      Case T_DADOS->ZS4_STAT == "5"
           MsgAlert("RMA já encerrada. Envio de informação ao Cliente não autorizada.")
           Return(.T.)
   EndCase           

   If Empty(Alltrim(T_DADOS->ZS4_EMAI))
      MsgAlert("Email de contato do cliente para envio inexistente.")
      Return(.T.)
   Endif

   // Elabora o texto para envio do e-mail
   cTexto := ""
   cTexto := "Prezado Cliente:" + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "Viemos lhe informar os dados de sua RMA - Solicitação de Devolução de Mercadoria(s) adquirida(s) junto a Automatech Sistema de Automação Ltda." + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Salientamos que o nº desta solicitação deverá constar em sua Nota Fiscal de Devolução. A falta desta implicará no recebimento da(s) mercadoria(s)." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "RMA Nº..: " + Alltrim(_RMA) + "/" + Alltrim(_ANO) + chr(13) + chr(10)
   cTexto += "Data: " + Substr(T_DADOS->ZS4_ABER,07,02) + "/" + Substr(T_DADOS->ZS4_ABER,05,02) + "/" + Substr(T_DADOS->ZS4_ABER,01,04) + chr(13) + chr(10)
   cTexto += "Hora: " + T_DADOS->ZS4_HORA + chr(13) + chr(10)
   cTexto += "Vendedor: " + Alltrim(T_DADOS->A3_NOME) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "DADOS DO CLIENTE" + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Razão Social: " + Alltrim(A1_NOME) + chr(13) + chr(10)
   cTexto += "Contato: " + Alltrim(T_DADOS->U5_CONTAT) + chr(13) + chr(10)
   cTexto += "Telefone: " + Alltrim(T_DADOS->ZS4_TELE) + chr(13) + chr(10)
   cTexto += "E-Mail: " + Alltrim(T_DADOS->ZS4_EMAI) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "NOTA FISCAL DE VENDA Nº " + Alltrim(T_DADOS->ZS4_NOTA) + " - Série: " + Alltrim(T_DADOS->ZS4_SERI) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "MOTIVO DA DEVOLUÇÃO DA(S) MERCADORIA(S)" + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += Alltrim(T_DADOS->MOTIVO) + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "PRODUTOS A SEREM DEVOLVIDOS" + chr(13) + chr(10) + chr(13) + chr(10)

   T_DADOS->( EOF() )

   _TCredito := T_DADOS->ZS4_CRED
   _Ncredito := T_DADOS->ZS4_CREN
   _Scredito := T_DADOS->ZS4_CRES
   
   WHILE !T_DADOS->( EOF() )

      If T_DADOS->ZS4_CHEK == "0"
         T_DADOS->( DbSkip() )         
         Loop
      Endif

      cTexto += "Descrição do Produto: " + Alltrim(T_DADOS->B1_DESC) + " " + Alltrim(T_DADOS->B1_DAUX) + chr(13) + chr(10)
  
      If Empty(Alltrim(T_DADOS->SERIES))
      Else
         cTexto += "Nºs de Série(s): "
         For nContar = 1 to U_P_OCCURS(T_DADOS->SERIES, "|", 1)      
             cTexto += U_P_CORTA(T_DADOS->SERIES, "|", nContar) + ", "
         Next nContar
      Endif

      cTexto += chr(13) + chr(10) + chr(13) + chr(10)
         
      T_DADOS->( DbSkip() )

   ENDDO   

   Do Case
      Case _Tcredito == "01"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: ENCONTRO COM NOTA FISCAL ORIGINAL" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "02"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: ENCONTRO COM NOVA NOTA FISCAL" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "03"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: ENCONTRO COM OUTRA NF (NF Nº " + _Ncredito + " SÉRIE: " + _Scredito + ")" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "04"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: CLIENTE FICOU COM CRÉDITO JUNTO A AUTOMATECH" + chr(13) + chr(10) + chr(13) + chr(10)
      Case _Tcredito == "05"
           cTexto += "INFORMAÇÕES REF. AO CRÉDITO: CLIENTE VAI RECEBER EM ESPÉCIE" + chr(13) + chr(10) + chr(13) + chr(10)
   EndCase

   cTexto += "CONDIÇÕES GERAIS DE TROCA DA(S) MERCADORIA(S)" + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "1. Somente serão aceitas trocas de produtos em suas embalagens originais, com, todos os acessórios e sem uso." + chr(13) + chr(10)
   cTexto += "2. O Produto deve estar em perfeitas condições de venda. Na eventual devolução de um produto fora deste estado (faltando" + chr(13) + chr(10)
   cTexto += "algum acessório, com vestígios de uso, etc.), será cobrado do Cliente o valor devido para colocá-lo em condições de venda." + chr(13) + chr(10)
   cTexto += "3. O prazo para devolução de produtos para a Automatech Sistema de automação Ltda é de 10 dias, contados a partir da data" + chr(13) + chr(10)
   cTexto += "do recebimento da mercadoria pelo Cliente." + chr(13) + chr(10)
   cTexto += "4. Desde que a devolução não seja motivada por um equívoco da Automatech Sistemas de Automação Ltda todos os fretes envolvidos" + chr(13) + chr(10)
   cTexto += "correm por conta do Cliente." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "PROCEDIMENTO DE TROCA" + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "1. Encaminhar cópía da nota fiscal de devolução por e-mail para a área de estoque da Automatech Sistemas de Automação Ltda para" + chr(13) + chr(10)
   cTexto += "o endereço (estoque01@automatech.com.br). Deve conter na nota o nº da NF de Venda e da RMA. Em Caso de pessoa física ou Empresa" + chr(13) + chr(10)
   cTexto += "que não possua inscrição estadual, não é necessária nota fiscal de devolução. A Automatech fará a nota fiscal de entrada." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "2. Encaminhar o equipamento para a Automatech conforme instruções da área de estoque." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "3. Após o equipamento ser recebido, este será inspecionado (estado geral, embalagem e acessórios) e se tudo estiver de acordo" + chr(13) + chr(10)
   cTexto += "com as condições gerais de troca de mercadorias o valor do equipamento será creditado para aquisiçãode um novo produto." + chr(13) + chr(10)
   cTexto += "Será devolvido o valor da compra em dinhiero somente se o produto for devolvido em até 7 dias depois do faturamento." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "OBS: NÃO SERÁ REALIZADO A ENTRADA DA DEVOLUÇÃO SEM QUE A RMA TENHA SIDO APROVADA, VISTO QUE SERÁ LEVADO EM CONSIDERAÇÃO TODAS" + chr(13) + chr(10)
   cTexto += "AS EXIGÊNCIAS ACIMA." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "Att." + chr(13) + chr(10) + chr(13) + chr(10)
   
   cTexto += "Automatech Sistemas de Automação Ltda" + chr(13) + chr(10)
   cTexto += "Departamento de Estoque" + chr(13) + chr(10)

   U_AUTOMR20(cTexto, 'harald@automatech.com.br', "", "Informações de RMA" )

   // Altera o Status da RMA
   cSql := ""
   cSql := "UPDATE " + RetSqlName("ZS4")
   cSql += "   SET "
   cSql += "   ZS4_STAT = '6'"
   cSql += " WHERE ZS4_NRMA = '" + Alltrim(_RMA) + "'"
   cSql += "   AND ZS4_ANO  = '" + Alltrim(_ANO) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   PsqGridDados(0, Substr(_Vendedor,01,06), "0")
   
Return(.T.)

// Função que permite que a quantidade do produto selecionado seja alterada
Static Function AlteQuant(_Item, _Codigo , _Descricao, _Qtd, _Unitario, _Total, _Marca)

   Local lChumba       := .F.

   Private xProduto    := Alltrim(_Item) + "." + Alltrim(_Codigo) + Alltrim(_Descricao)
   Private xVerificar  := _Qtd
   Private xQuantidade := _Qtd
   Private xUnitario   := _Unitario
   Private xTotal      := _Total

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgQ

   If _Marca == .F.
      MsgAlert("Atenção! Produto não foi marcado para ter sua quantidade alterada.")
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlgQ TITLE "Alteração de Quantidade " FROM C(178),C(181) TO C(324),C(521) PIXEL

   @ C(005),C(005) Say "Produto"    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(026),C(005) Say "Quantidade" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(026),C(053) Say "Unitário"   Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ
   @ C(026),C(114) Say "Total"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgQ

   @ C(013),C(005) MsGet oGet1 Var xProduto    When lChumba Size C(159),C(009) COLOR CLR_BLACK Picture "@!"                  PIXEL OF oDlgQ
   @ C(036),C(005) MsGet oGet2 Var xQuantidade              Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999999.99"      PIXEL OF oDlgQ VALID(CALNPRECO(xQuantidade, xUnitario, _Item, _Codigo))
   @ C(036),C(053) MsGet oGet3 Var xUnitario   When lChumba Size C(043),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" PIXEL OF oDlgQ
   @ C(036),C(114) MsGet oGet4 Var xTotal      When lChumba Size C(049),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" PIXEL OF oDlgQ

   @ C(053),C(046) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgQ ACTION( CFMQTD(xProduto, xQuantidade, xUnitario, xTotal) )
   @ C(053),C(085) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgQ ACTION( oDlgQ:End() )

   ACTIVATE MSDIALOG oDlgQ CENTERED 

Return(.T.)

// Função que calcula o valor total
Static Function CALNPRECO(_xQuantidade, _xUnitario, _Item, _Codigo)

   Local cSql    := ""
   Local nSaldo  := 0

   xTotal := xQuantidade * xUnitario
   oGet4:Refresh()

   // Calcula o Saldo do Produto selecionado
   If Select("T_QTDORIGEM") > 0
      T_QTDORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.D2_ITEM  ,"
   cSql += "       A.D2_COD   ,"
   cSql += "       RTRIM(B.B1_DESC) + ' ' + RTRIM(B.B1_DAUX) AS DESCRICAO,"
   cSql += "       A.D2_QUANT ,"
   cSql += "       A.D2_PRCVEN,"
   cSql += "       A.D2_TOTAL  "
   cSql += "  FROM " + RetSqlName("SD2") + " A, " 
   cSql += "       " + RetSqlName("SB1") + " B  " 
   cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(xFilial) + "'"
   cSql += "   AND A.D2_DOC     = '" + Alltrim(cNota)   + "'"
   cSql += "   AND A.D2_SERIE   = '" + Alltrim(cSerie)  + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''
   cSql += "   AND A.D2_COD     = B.B1_COD
   cSql += "   AND B.D_E_L_E_T_ = ''
   cSql += "   AND A.D2_CLIENTE = '" + Alltrim(cCliente) + "'"
   cSql += "   AND A.D2_LOJA    = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND A.D2_COD     = '" + Alltrim(_Codigo)  + "'"
   cSql += "   AND A.D2_ITEM    = '" + Alltrim(_Item)    + "'"
   cSql += " ORDER BY A.D2_ITEM 
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QTDORIGEM", .T., .T. )
   
   If T_QTDORIGEM->( EOF() )
      MSGALERT("Erro na pesquisa da quantidade original so produto. Entre em contato com a área de desenvolvimento para análise.")
      Return(.T.)
   Endif

   nSaldo := T_QTDORIGEM->D2_QUANT      
   
   // Pesquisa as RMA's já efetivadas para o Produto/Item
   If Select("T_CONSUMO") > 0
      T_CONSUMO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZS4_QUAN"
   cSql += "  FROM " + RetSqlName("ZS4")
   cSql += " WHERE ZS4_CLIE   = '" + Alltrim(cCliente) + "'"
   cSql += "   AND ZS4_LOJA   = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND ZS4_NFIL   = '" + Alltrim(xFilial)  + "'"
   cSql += "   AND ZS4_NOTA   = '" + Alltrim(cNota)    + "'"
   cSql += "   AND ZS4_SERI   = '" + Alltrim(cSerie)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += "   AND ZS4_PROD   = '" + Alltrim(_Codigo)  + "'"
   cSql += "   AND ZS4_ITEM   = '" + Alltrim(_Item)    + "'"

   If cNRMA <> ""
      cSql += " AND ZS4_NRMA <> '" + Alltrim(cNRMA) + "'"
      cSql += " AND ZS4_ANO  <> '" + Alltrim(cARMA) + "'"
   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSUMO", .T., .T. )

   If T_CONSUMO->( EOF() )
      nSaldo := nSaldo - 0
   Else
      nSaldo := nSaldo - T_CONSUMO->ZS4_QUAN
   Endif
      
   If xQuantidade > nSaldo      
      MsgAlert("Atenção! Quantidade informada é maior que o saldo disponíovel do produto para utilização em RMA. Verifique!")
      oDlgQ:End()
      Return(.T.)                                                 
   Endif

   xTotal := nSaldo * xUnitario

   oGet4:Refresh() 
   
Return(.T.)

// Função que altera a quantidade do produto
Static Function CFMQTD(yProduto, yQuantidade, yUnitario, yTotal)

   aProdutos[oProdutos:nAt,05] := yQuantidade
   aProdutos[oProdutos:nAt,06] := yUnitario
   aProdutos[oProdutos:nAt,07] := yQuantidade * yUnitario

   oProdutos:SetArray( aProdutos )
   oProdutos:bLine := {||     {Iif(aProdutos[oProdutos:nAt,01],oOk,oNo),;
             		    		   aProdutos[oProdutos:nAt,02],;
         	         	           aProdutos[oProdutos:nAt,03],;
         	         	           aProdutos[oProdutos:nAt,04],;
         	         	           aProdutos[oProdutos:nAt,05],;
         	         	           aProdutos[oProdutos:nAt,06],;         	         	                    	         	           
         	        	           aProdutos[oProdutos:nAt,07]}}

   oDlgQ:End()

Return(.T.)

// Função que abre janela para visualizar as legendas da tela
Static Function LegendaRMA()

   Local cMemo1 := ""
   Local oMemo1

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

   Private oDlgLG

   DEFINE MSDIALOG oDlgLG TITLE "Legenda" FROM C(178),C(181) TO C(284),C(580) PIXEL

   @ C(004),C(005) Jpeg FILE "br_azul"   Size C(009),C(009) PIXEL NOBORDER OF oDlgLG
   @ C(017),C(005) Jpeg FILE "br_marrom" Size C(009),C(009) PIXEL NOBORDER OF oDlgLG

   @ C(006),C(019) Say "RMA em Aberto. Aguardando encerramento do processo pelo Financeiro" Size C(174),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG
   @ C(018),C(019) Say "RMA's encerradas pelo Financeiro"                                   Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oDlgLG

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(186),C(001) PIXEL OF oDlgLG

   @ C(036),C(153) Button "Retornar" Size C(037),C(012) PIXEL OF oDlgLG ACTION( oDlgLG:End() )

   ACTIVATE MSDIALOG oDlgLG CENTERED 

Return(.T.)