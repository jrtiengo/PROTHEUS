#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPNEW01.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 16/04/2013                                                          *
// Objetivo..: Programa de manuten��o do Automatech News                           *
//**********************************************************************************

User Function ESPNEW01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaNews()

   DEFINE MSDIALOG oDlg TITLE "Cadastro Automatech News" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreNews( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreNews( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreNews( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('C�digo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descri��o dos Assuntos',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaNews()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_NEWS") > 0
      T_NEWS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ9_CODI, "
   cSql += "       ZZ9_NOME  "
   cSql += "  FROM " + RetSqlName("ZZ9")
   cSql += " WHERE ZZ9_DELE = ''"
   cSql += " ORDER BY ZZ9_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NEWS", .T., .T. )

   If T_NEWS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_NEWS->( EOF() )
         aAdd( aBrowse, { T_NEWS->ZZ9_CODI, T_NEWS->ZZ9_NOME } )
         T_NEWS->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipula��o dos dados
Static Function _AbreNews( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ESPNEW02("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPNEW02("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ESPNEW02("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaNEWS()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('C�digo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descri��o dos Desenvolvedores',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   