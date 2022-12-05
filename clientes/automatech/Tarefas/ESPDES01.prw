#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPDES01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Desenvolvedores               *
//**********************************************************************************

User Function ESPDES01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaBRWD()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Desenvolvedores" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreDesenve( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreDesenve( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreDesenve( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Desenvolvedores',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWD()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   If T_DESENVE->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_DESENVE->( EOF() )
         aAdd( aBrowse, { T_DESENVE->ZZE_CODIGO, T_DESENVE->ZZE_NOME } )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreDesenve( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ESPDES02("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPDES02("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ESPDES02("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaBRWD()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Desenvolvedores',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   