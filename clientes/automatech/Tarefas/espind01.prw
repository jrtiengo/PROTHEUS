#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPIND01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/06/2013                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Usuários                      *
//**********************************************************************************

User Function ESPIND01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg

   Private aBrowse := {}

   Private oGetDados1

   CarregaBRWP()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Usuários" FROM C(178),C(181) TO C(447),C(670) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreProjeto( "I", Space(06), Space(40) ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreProjeto( "A", aBrowse[ oBrowse:nAt, 01 ] ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreProjeto( "E", aBrowse[ oBrowse:nAt, 01 ] ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TSBrowse():New(040,005,305,105,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Usuários',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('E-Mail',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWP()

   aBrowse := {}

   // Carrega o Array com as Prioidades de Tarefas cadastradas
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZA_CODI, "
   cSql += "       A.ZZA_NOME, "
   cSql += "       A.ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA") + " A "
   cSql += " WHERE A.D_E_L_E_T_ = ''"
   cSql += " ORDER BY A.ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   If T_USUARIOS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_USUARIOS->( EOF() )
         aAdd( aBrowse, { T_USUARIOS->ZZA_CODI,;
                          T_USUARIOS->ZZA_NOME,;
                          T_USUARIOS->ZZA_EMAI})
         T_USUARIOS->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreProjeto( _Tipo, _Codigo)

   If _Tipo == "I"
      U_ESPIND02("I", Space(06) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPIND02("A", _Codigo) 
   Endif
      
   If _Tipo == "E"
      U_ESPIND02("E", _Codigo) 
   Endif

   aBrowse := {}

   CarregaBRW()
   
   oBrowse := TSBrowse():New(040,005,305,105,oDlg,,1,,1)
   oBrowse:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('Usuário',,,{|| },{|| }) )
   oBrowse:AddColumn( TCColumn():New('E-Mail',,,{|| },{|| }) )
   oBrowse:SetArray(aBrowse)

Return .T.   