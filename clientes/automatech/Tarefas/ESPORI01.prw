#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPORI01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Responsável pela Tarefa       *
//**********************************************************************************

User Function ESPORI01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaBRW()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Responsavel das Tarefas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreOrigem( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreOrigem( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreOrigem( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Responsáveis',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWO()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_ORIGEM") > 0
      T_ORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZF_CODIGO, "
   cSql += "       ZZF_NOME    "
   cSql += "  FROM " + RetSqlName("ZZF")
   cSql += " WHERE ZZF_DELETE = ''"
   cSql += " ORDER BY ZZF_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORIGEM", .T., .T. )

   If T_ORIGEM->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_ORIGEM->( EOF() )
         aAdd( aBrowse, { T_ORIGEM->ZZF_CODIGO, T_ORIGEM->ZZF_NOME } )
         T_ORIGEM->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreOrigem( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ESPORI02("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPORI02("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ESPORI02("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaBRWO()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Origens',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.