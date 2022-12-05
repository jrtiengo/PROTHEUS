#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRG01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/03/2015                                                          *
// Objetivo..: Programa que cadastra programas do Protheus                         *
//**********************************************************************************

User Function ESPPRG01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Carrega o grid
   CarregaPRG()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Programas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbrePrograma( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbrePrograma( "A", aBrowse[ oBrowse:nAt, 01 ] ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbrePrograma( "E", aBrowse[ oBrowse:nAt, 01 ] ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código'                 ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Programas',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaPRG()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_PROGRAMAS") > 0
      T_PROGRAMAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT5_PROG, "
   cSql += "       ZT5_NOME  "
   cSql += "  FROM " + RetSqlName("ZT5")
   cSql += " WHERE ZT5_DELE = ''"
   cSql += " ORDER BY ZT5_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROGRAMAS", .T., .T. )

   If T_PROGRAMAS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_PROGRAMAS->( EOF() )
         aAdd( aBrowse, { T_PROGRAMAS->ZT5_PROG, T_PROGRAMAS->ZT5_NOME } )
         T_PROGRAMAS->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbrePrograma( _Tipo, _Programa, _Nome)

   If _Tipo == "I"
      U_ESPPRG02("I", Space(15) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPPRG02("A", _Programa) 
   Endif
      
   If _Tipo == "E"
      U_ESPPRG02("E", _Programa) 
   Endif

   aBrowse := {}

   CarregaPRG()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código'                 ,,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Programas',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   