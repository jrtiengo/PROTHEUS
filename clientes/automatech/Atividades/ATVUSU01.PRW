#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVUSU01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Cadastro de Usuários do Controle de Atividades                      *
//**********************************************************************************

User Function ATVUSU01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   CarregaBRWD()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Desenvolvedores" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreUsuario( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreUsuario( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreUsuario( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ]  ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Usuário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Usuários',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('E-Mail',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Área',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWD()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZT_USUA , "
   cSql += "       A.ZZT_NOMS , "
   cSql += "       A.ZZT_EMAS , "
   cSql += "       A.ZZT_RESP , "
   cSql += "       A.ZZT_NOMR , "
   cSql += "       A.ZZT_EMAR , "
   cSql += "       A.ZZT_AREA , "
   cSql += "       B.ZZR_NOME   "
   cSql += "  FROM " + RetSqlName("ZZT") + " A, "
   cSql += "       " + RetSqlName("ZZR") + " B  "
   cSql += " WHERE A.ZZT_DELETE = ' '"
   cSql += "   AND A.ZZT_AREA   = B.ZZR_CODIGO  "
   cSql += "   AND B.ZZR_DELETE = ' '"
   cSql += " ORDER BY A.ZZT_NOMS "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_USUARIO->( EOF() )
         aAdd( aBrowse, { T_USUARIO->ZZT_USUA, T_USUARIO->ZZT_NOMS, T_USUARIO->ZZT_EMAS, T_USUARIO->ZZR_NOME } )
         T_USUARIO->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreUsuario( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ATVUSU02("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ATVUSU02("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ATVUSU02("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaBRWD()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Usuário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Usuários',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('E-Mail',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Área',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   