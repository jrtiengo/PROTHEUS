#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM221.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/03/2014                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Tipos de RMA                  *
//**********************************************************************************

User Function AUTOM221()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg

   Private aBrowse := {}

   CarregaTIPOS()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Tipos de RMA" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreTipo( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreTipo( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreTipo( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Tipos de RMA',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaTIPOS()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_TIPO") > 0
      T_TIPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS8_CODI, "
   cSql += "       ZS8_DESC  "
   cSql += "  FROM " + RetSqlName("ZS8")
   cSql += " WHERE ZS8_DELE = ''"
   cSql += " ORDER BY ZS8_DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPO", .T., .T. )

   If T_TIPO->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_TIPO->( EOF() )
         aAdd( aBrowse, { T_TIPO->ZS8_CODI, T_TIPO->ZS8_DESC } )
         T_TIPO->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreTipo( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_AUTO221B("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_AUTO221B("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_AUTO221B("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaTIPO()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Tipos de RMA',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return(.T.)