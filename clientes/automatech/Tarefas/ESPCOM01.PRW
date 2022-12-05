#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPCOM01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 04/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Componentes                   *
//**********************************************************************************

User Function ESPCOM01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaBRW()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Componentes/Tipo de Tarefas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreCompo( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreCompo( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreCompo( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Componentes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Projeto',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRW()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_COMPONE") > 0
      T_COMPONE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZB_CODIGO, "
   cSql += "       ZZB_NOME  , "
   cSql += "       ZZB_TIPO    "
   cSql += "  FROM " + RetSqlName("ZZB")
   cSql += " WHERE ZZB_DELETE = ''"
   cSql += " ORDER BY ZZB_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPONE", .T., .T. )

   If T_COMPONE->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_COMPONE->( EOF() )
         aAdd( aBrowse, { T_COMPONE->ZZB_CODIGO, T_COMPONE->ZZB_NOME, IIF(EMPTY(ALLTRIM(T_COMPONE->ZZB_TIPO)), "N", T_COMPONE->ZZB_TIPO) } )
         T_COMPONE->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreCompo( _Tipo, _Codigo, _Nome, _Projeto)

   If _Tipo == "I"
      U_ESPCOM02("I", Space(06), Space(40), "N" ) 
   Endif
      
   If _Tipo == "A"
      U_ESPCOM02("A", _Codigo, _Nome, _Projeto ) 
   Endif
      
   If _Tipo == "E"
      U_ESPCOM02("E", _Codigo, _Nome, _Projeto ) 
   Endif

   aBrowse := {}

   CarregaBRW()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Componentes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Projeto',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   