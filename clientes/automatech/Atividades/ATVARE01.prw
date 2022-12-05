#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVARE01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Áreas                         *
//**********************************************************************************

User Function ATVARE01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaBRWD()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Áreas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreArea( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreArea( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreArea( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Áreas',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWD()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_AREAS") > 0
      T_AREAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZR_CODIGO, "
   cSql += "       ZZR_NOME    "
   cSql += "  FROM " + RetSqlName("ZZR")
   cSql += " WHERE ZZR_DELETE = ''"
   cSql += " ORDER BY ZZR_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREAS", .T., .T. )

   If T_AREAS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_AREAS->( EOF() )
         aAdd( aBrowse, { T_AREAS->ZZR_CODIGO, T_AREAS->ZZR_NOME } )
         T_AREAS->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreArea( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ATVARE02("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ATVARE02("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ATVARE02("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaBRWD()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição das Áreas',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   