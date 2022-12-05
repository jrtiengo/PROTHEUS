#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI60.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/12/2012                                                          *
// Objetivo..: Programa de filtro para visualização de atividades por usuários.    *
//**********************************************************************************

User Function ATVATI60()

   Local cSql        := ""
   Local aSupervisor := {}
   Local cSupervisor

   Private oDlg

   // Carrega o Adm do Supervisor
   If Select("T_SUPERVISOR") > 0
      T_SUPERVISOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZT_USUA"
   cSql += "  FROM " + RetSqlName("ZZT")
   cSql += " WHERE ZZT_DELETE = ''"
   cSql += "   AND ZZT_SUPE   = 'T'"
   cSql += " ORDER BY ZZT_USUA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SUPERVISOR", .T., .T. )

   WHILE !T_SUPERVISOR->( EOF() )   
      aAdd( aSupervisor, T_SUPERVISOR->ZZT_USUA )
      T_SUPERVISOR->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlgV TITLE "Pesquisa de Atividades" FROM C(178),C(181) TO C(279),C(480) PIXEL

   @ C(005),C(005) Say "Supervisor"     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgV

   @ C(014),C(005) ComboBox cSupervisor Items aSupervisor Size C(139),C(010) PIXEL OF oDlgV

   @ C(031),C(035) Button "Pesquisar"   Size C(037),C(012) PIXEL OF oDlgV ACTION( U_ATVATI15(cSupervisor) )
   @ C(031),C(073) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlgV ACTION( oDlgV:End() )

   ACTIVATE MSDIALOG oDlgV CENTERED 

Return(.T.)