#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRO01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Status                        *
//**********************************************************************************

User Function ESPPRO01(_Tarefa, _NomeTar)

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private wTarefa
   Private wNomeTa
   Private oDlgp
   Private cTipo    := ""
   Private aPBrowse := {}

   wTarefa  := _Tarefa
   wNomeTa  := _NomeTar
   aPBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_PROCESSO") > 0
      T_PROCESSO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZM_TARE, "
   cSql += "       ZZM_PROG, "
   cSql += "       ZZM_TIPO, "
   cSql += "       ZZM_NOME  "
   cSql += "  FROM " + RetSqlName("ZZM")
   cSql += " WHERE ZZM_DELE = ''"
   cSql += "   AND ZZM_TARE = '" + Alltrim(wTarefa) + "'"
   cSql += " ORDER BY ZZM_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROCESSO", .T., .T. )

   If T_PROCESSO->( EOF() )
      aPBrowse := {}
      aAdd( aPBrowse, { '', '' } )
   Else
      cTipo := ""
      WHILE !T_PROCESSO->( EOF() )
         Do Case
            Case T_PROCESSO->ZZM_TIPO == "F"
                 cTipo := "Fonte"
            Case T_PROCESSO->ZZM_TIPO == "G"
                 cTipo := "Gatilho"
            Case T_PROCESSO->ZZM_TIPO == "P"
                 cTipo := "Ponto de Entrada"
            Case T_PROCESSO->ZZM_TIPO == "T"
                 cTipo := "Tabela"
            Case T_PROCESSO->ZZM_TIPO == "C"
                 cTipo := "Campo"
            Case T_PROCESSO->ZZM_TIPO == "I"
                 cTipo := "Índice"
         EndCase
                          
         aAdd( aPBrowse, { T_PROCESSO->ZZM_PROG, cTipo } )

         T_PROCESSO->( DbSkip() )

      ENDDO

   Endif

   DEFINE MSDIALOG oDlgp TITLE "Processos da Tarefa" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlgp ACTION( _AbreRotina( "I", "", wTarefa, wNomeTa ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgp ACTION( _AbreRotina( "A", aPBrowse[ oPBrowse:nAt, 01 ], wTarefa, wNomeTa ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlgp ACTION( _AbreRotina( "E", aPBrowse[ oPBrowse:nAt, 01 ], wTarefa, wNomeTa ) )

   @ C(117),C(205) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgp ACTION( oDlgp:end() )

   // Cria objeto grid
   oPBrowse := TCBrowse():New( 005 , 005, 305, 140,,{'Componente','Tipo'},{20,50,50,50},oDlgp,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oPBrowse:SetArray(aPBrowse) 
    
   oPBrowse:bLine := {||{ aPBrowse[oPBrowse:nAt,01], aPBrowse[oPBrowse:nAt,02] } }

   ACTIVATE MSDIALOG oDlgp CENTERED 

Return(.T.)

// Chama o programa de manipulação dos dados
Static Function _AbreRotina( _Tipo, _Programa, _Codigo, _Nome)

   If _Tipo == "I"
      U_ESPPRO02("I", Space(20), _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "A"
      U_ESPPRO02("A", _Programa, _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ESPPRO02("E", _Programa, _Codigo, _Nome ) 
   Endif

   aPBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_PROCESSO") > 0
      T_PROCESSO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZM_TARE, "
   cSql += "       ZZM_PROG, "
   cSql += "       ZZM_TIPO, "
   cSql += "       ZZM_NOME  "
   cSql += "  FROM " + RetSqlName("ZZM")
   cSql += " WHERE ZZM_DELE = ''"
   cSql += "   AND ZZM_TARE = '" + Alltrim(wTarefa) + "'"
   cSql += " ORDER BY ZZM_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROCESSO", .T., .T. )

   If T_PROCESSO->( EOF() )
      aPBrowse := {}
      aAdd( aPBrowse, { '', '', '' } )
   Else
      cTipo := ""
      WHILE !T_PROCESSO->( EOF() )
         Do Case
            Case T_PROCESSO->ZZM_TIPO == "F"
                 cTipo := "Fonte"
            Case T_PROCESSO->ZZM_TIPO == "G"
                 cTipo := "Gatilho"
            Case T_PROCESSO->ZZM_TIPO == "P"
                 cTipo := "Ponto de Entrada"
            Case T_PROCESSO->ZZM_TIPO == "T"
                 cTipo := "Tabela"
            Case T_PROCESSO->ZZM_TIPO == "C"
                 cTipo := "Campo"
            Case T_PROCESSO->ZZM_TIPO == "I"
                 cTipo := "Índice"
         EndCase
                          
         aAdd( aPBrowse, { T_PROCESSO->ZZM_PROG, cTipo } )

         T_PROCESSO->( DbSkip() )

      ENDDO

   Endif

   // Seta vetor para a browse                            
   oPBrowse:SetArray(aPBrowse) 
    
   oPBrowse:bLine := {||{ aPBrowse[oPBrowse:nAt,01], aPBrowse[oPBrowse:nAt,02] } }

Return .T.   