#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM214.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 14/03/2014                                                          *
// Objetivo..: Programa de Manuten��o do Cadastro de Regras de Neg�cio             *
//**********************************************************************************

User Function AUTOM214()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg

   Private aBrowse := {}

   U_AUTOM628("AUTOM214")

   CarregaRegras()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Regras de Neg�cio" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreRegras( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreRegras( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreRegras( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('C�digo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descri��o das Regras de Neg�cio',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaRegras()

   aBrowse := {}

   // Carrega o Array com as regras de neg�cio para display
   If Select("T_REGRAS") > 0
      T_REGRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS5_CODI, "
   cSql += "       ZS5_TITU  "
   cSql += "  FROM " + RetSqlName("ZS5")
   cSql += " WHERE ZS5_DELE = ''"
   cSql += " ORDER BY ZS5_TITU  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REGRAS", .T., .T. )

   If T_REGRAS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_REGRAS->( EOF() )
         aAdd( aBrowse, { T_REGRAS->ZS5_CODI, T_REGRAS->ZS5_TITU } )
         T_REGRAS->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipula��o dos dados
Static Function _AbreRegras( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_AUTO214A("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_AUTO214A("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_AUTO214A("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaRegras()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('C�digo',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descri��o das Regras de Neg�cio',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return(.T.)