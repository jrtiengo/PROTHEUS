#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM217.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/03/2014                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Motivos de RMA                *
//**********************************************************************************

User Function AUTOM217()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaMOTIVO()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Motivos de RMA" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreMotivo( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreMotivo( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreMotivo( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Motivos de RMA',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaMOTIVO()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_MOTIVO") > 0
      T_MOTIVO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS6_CODI, "
   cSql += "       ZS6_DESC  "
   cSql += "  FROM " + RetSqlName("ZS6")
   cSql += " WHERE ZS6_DELE = ''"
   cSql += " ORDER BY ZS6_DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

   If T_MOTIVO->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_MOTIVO->( EOF() )
         aAdd( aBrowse, { T_MOTIVO->ZS6_CODI, T_MOTIVO->ZS6_DESC } )
         T_MOTIVO->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreMotivo( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_AUTO217B("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_AUTO217B("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_AUTO217B("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaMOTIVO()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Motivos de RMA',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return(.T.)