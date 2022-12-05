#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRJ01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 26/09/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Projetos                      *
//**********************************************************************************

User Function ESPPRJ01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg				// Dialog Principal

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaBRWP()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Projetos" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreProjeto( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreProjeto( "A", aBrowse[ oBrowse:nAt, 01 ] ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreProjeto( "E", aBrowse[ oBrowse:nAt, 01 ] ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Apelido',,,{|| },{|| }) )      
   oBrowse:AddColumn( TCColumn():New('Cliente',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Loja',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Clientes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Projeto',,,{|| },{|| }) )      
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWP()

   aBrowse := {}

   // Carrega o Array com as Prioidades de Tarefas cadastradas
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZY_CODIGO, "
   cSql += "       A.ZZY_CLIENT, "
   cSql += "       A.ZZY_LOJA  , "
   cSql += "       A.ZZY_CHAVE , "
   cSql += "       B.A1_NOME   , "
   cSql += "       A.ZZY_TITULO  "
   cSql += "  FROM " + RetSqlName("ZZY") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.ZZY_DELETE = ''"
   cSql += "   AND A.ZZY_CLIENT = B.A1_COD  "
   cSql += "   AND A.ZZY_LOJA   = B.A1_LOJA "
   cSql += " ORDER BY A.ZZY_CHAVE "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_PROJETO->( EOF() )
         aAdd( aBrowse, { T_PROJETO->ZZY_CODIGO,;
                          T_PROJETO->ZZY_CHAVE ,;
                          T_PROJETO->ZZY_CLIENT,;
                          T_PROJETO->ZZY_LOJA  ,;
                          T_PROJETO->A1_NOME   ,;
                          T_PROJETO->ZZY_TITULO})
         T_PROJETO->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreProjeto( _Tipo, _Codigo)

   If _Tipo == "I"
      U_ESPPRJ02("I", Space(06) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPPRJ02("A", _Codigo) 
   Endif
      
   If _Tipo == "E"
      U_ESPPRJ02("E", _Codigo) 
   Endif

   aBrowse := {}

   CarregaBRW()
   
   oBrowse := TSBrowse():New(005,005,305,140,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Apelido',,,{|| },{|| }) )      
   oBrowse:AddColumn( TCColumn():New('Cliente',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Loja',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Descrição dos Clientes',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Projeto',,,{|| },{|| }) )      
   oBrowse:SetArray(aBrowse)

Return .T.   