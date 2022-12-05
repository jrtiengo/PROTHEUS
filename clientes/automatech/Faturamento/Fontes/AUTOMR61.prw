#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR61.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 31/11/2011                                                          *
// Objetivo..: Programa que vincula Cliente X Contatos.                            *
//             Chamado pelo botão das Ações Relacionadas do Pedido de Venda.	   *
//**********************************************************************************

User Function AUTOMR61( _Cliente, _Loja)   
 
   // Variáveis Locais da Função
   Local cSql   := ""
   Local cMemo1 := ""
   Local oMemo1 

   Private oGet1        := Space(100)
   Private oGet2        := Space(006)
   Private aBrowse      := {} 
   Private lBotao       := .F.

   Private cNomeCliente := ""
   Private cNomeContato := ""

   Private cContato     := Space(006)

   U_AUTOM628("AUTOMR61")
   
   If Empty(_Cliente)
      Return .T.
   Endif
   
   If Empty(_Loja)
      Return .T.
   Endif
      
   cNomeCliente         := ""
   cNomeContato         := ""

   // Pesquisa o nome do cliente para display
   If Select("T_CLIENTES") > 0
      T_CLIENTES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_NOME "
   cSql += "  FROM " + RetSqlName("SA1010")
   cSql += " WHERE A1_COD  = '" + Alltrim(_Cliente) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(_Loja)    + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTES", .T., .T. )

   cNomeCliente := Alltrim(_Cliente) + "." + Alltrim(_Loja) + " - " + Alltrim(T_CLIENTES->A1_NOME)

   // Pesquisa os contatos do cliente para popular o Grid
   If Select("T_CONTATOS") > 0
      T_CONTATOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AC8_CODCON,"
   cSql += "       B.U5_CONTAT ,"
   cSql += "       A.AC8_ENTIDA "
   cSql += "  FROM " + RetSqlName("AC8010") + " A, "
   cSql += "       " + RetSqlName("SU5010") + " B  "
   cSql += " WHERE A.AC8_CODENT   = '" + Alltrim(_cliente) + Alltrim(_Loja) + "'"
   cSql += "   AND A.AC8_CODCON   = B.U5_CODCONT "
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
  
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )

   If !T_CONTATOS->( EOF() )
      WHILE !T_CONTATOS->( EOF() )
	     aAdd( aBrowse, { T_CONTATOS->AC8_CODCON,;
	                      T_CONTATOS->U5_CONTAT ,;
	                      T_CONTATOS->AC8_ENTIDA} )
         T_CONTATOS->( DbSkip() )
      ENDDO
   Endif

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" } )
   Endif

   // Desenha o Diálogo
   Private oDlg

   DEFINE FONT oFont Name "Arial" Size 0, -14 BOLD

   // Dsenha a janela do programa
   DEFINE MSDIALOG oDlg TITLE "Vínculo Cliente X Contatos" FROM C(178),C(181) TO C(563),C(557) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(181),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Cliente"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(005) Say "Contatos do Cliente" Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(152),C(005) Say "Contato"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cNomeCliente Size C(178),C(009) FONT oFont COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When .F.
   @ C(160),C(005) MsGet oGet2 Var cContato     Size C(036),C(009)            COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SU5") VALID( BuscaContato(cContato) )
   @ C(160),C(044) MsGet oGet3 Var cNomeContato Size C(138),C(009)            COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When .F.

   // Desenha o Browse do Diálogo
   oBrowse := TSBrowse():New(085,005,228,105,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Contatos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Entidade',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   @ C(176),C(036) Button "Vincular"    Size C(037),C(012) PIXEL OF oDlg ACTION( GRAVACONTATOS( cContato, _Cliente, _Loja, 1, aBrowse[oBrowse:nAt,03] ) )
   @ C(176),C(075) Button "Desvincular" Size C(037),C(012) PIXEL OF oDlg ACTION( GRAVACONTATOS( aBrowse[oBrowse:nAt,01], _Cliente, _Loja, 2, aBrowse[oBrowse:nAt,03] ) )
   @ C(176),C(114) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o nome do contato informado
Static Function BuscaContato( cContato )

   Local cSql      := ""
   
   If Empty(Alltrim(cContato))
      cNomeContato := ""
      Return .T.
   Endif

   If Select("T_CONTATOS") > 0
      T_CONTATOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT U5_CODCONT,"
   cSql += "       U5_CONTAT  "
   cSql += "  FROM " + RetSqlName("SU5010")
   cSql += " WHERE U5_CODCONT = '" + Alltrim(cContato) + "'"
  
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )
   
   If T_CONTATOS->( EOF() )
      MsgAlert("Contato informado não cadastrado.")
      cNomeContato := ""
      Return .T.
   Else
      cNomeContato := Alltrim(T_CONTATOS->U5_CONTAT)
   Endif
      
Return .T.

// Função que grava o contato informado
Static Function GravaContatos( cContato, _Cliente, _Loja, _Tipo, _Entidade )

   Local cSql   := ""
   Local _nErro := 0
      
   If Empty(Alltrim(cContato)) 
      MsgAlert("Contato não informado para gravação. Verifique !!")
      Return .T.
   Endif

   // Se tipo == 2 é Exclusão
   If _Tipo == 2

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente desvincular este contato do cliente?")

         cSql := ""
         cSql := "DELETE "
         cSql += "  FROM " + RetSqlName("AC8")
         cSql += " WHERE AC8_ENTIDA = '" + Alltrim(_Entidade) + "'"
         cSql += "   AND AC8_CODENT = '" + Alltrim(_Cliente)  + Alltrim(_Loja) + "'"
         cSql += "   AND AC8_CODCON = '" + Alltrim(cContato)  + "'"

         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
         Endif
         
      Else
      
         Return(.T.)
         
      Endif

   Endif

   // Verifica se o contato informado já está vinculado ao Cliente
   If _Tipo == 1
      If Select("T_CONTATOS") > 0
         T_CONTATOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT AC8_CODCON "
      cSql += "  FROM " + RetSqlName("AC8010")
      cSql += " WHERE AC8_CODENT   = '" + Alltrim(_cliente) + Alltrim(_Loja) + "'"
      cSql += "   AND AC8_CODCON   = '" + Alltrim(cContato) + "'"
      cSql += "   AND R_E_C_D_E_L_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )
   
      If !T_CONTATOS->( EOF() )
         MsgAlert("Contato informado para este Cliente já vinculado. Verifique !!")
         Return .T.
      Endif

      aBrowse := {}

      // Desenha o Browse do Diálogo
      oBrowse := TSBrowse():New(085,005,228,105,oDlg,,1,,1)
      oBrowse:AddColumn( TCColumn():New('Código'                ,,,{|| },{|| }) )
      oBrowse:AddColumn( TCColumn():New('Descrição dos Contatos',,,{|| },{|| }) )
      oBrowse:AddColumn( TCColumn():New('Entidade'              ,,,{|| },{|| }) )
      oBrowse:SetArray(aBrowse)

      // Grava o Contato
      DbSelectArea("AC8")
      DbAppend(.F.)
      AC8_ENTIDA := "SA1"
      AC8_CODENT := Alltrim(_Cliente) + Alltrim(_Loja)
      AC8_CODCON := Alltrim(cContato)
      DbUnlock()
   Endif   

   aBrowse := {}

   // Pesquisa os contatos do cliente para popular o Grid
   If Select("T_CONTATOS") > 0
      T_CONTATOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AC8_CODCON,"
   cSql += "       B.U5_CONTAT ,"
   cSql += "       A.AC8_ENTIDA "
   cSql += "  FROM " + RetSqlName("AC8010") + " A, "
   cSql += "       " + RetSqlName("SU5010") + " B  "
   cSql += " WHERE A.AC8_CODENT   = '" + Alltrim(_cliente) + Alltrim(_Loja) + "'"
   cSql += "   AND A.AC8_CODCON   = B.U5_CODCONT "
   cSql += "   AND A.R_E_C_D_E_L_ = ''"
  
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATOS", .T., .T. )

   If !T_CONTATOS->( EOF() )
      WHILE !T_CONTATOS->( EOF() )
	     aAdd( aBrowse, { T_CONTATOS->AC8_CODCON,;
	                      T_CONTATOS->U5_CONTAT ,;
	                      T_CONTATOS->AC8_ENTIDA} )
         T_CONTATOS->( DbSkip() )
      ENDDO
   Endif

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "" } )
   Endif

   // Desenha o Browse do Diálogo
   oBrowse := TSBrowse():New(085,005,228,105,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código'                ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Contatos',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Entidade'              ,,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   cContato     := Space(006)
   oGet2        := Space(006)
   cNomeContato := ""
   
Return(.T.)