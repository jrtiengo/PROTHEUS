#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPSTA01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 04/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Status                        *
//**********************************************************************************

User Function ESPSTA01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')


   Private oDlg

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZC_CODIGO, "
   cSql += "       ZZC_NOME  , "
   cSql += "       ZZC_LEGE    "
   cSql += "  FROM " + RetSqlName("ZZC")
   cSql += " WHERE ZZC_DELETE = ''"
   cSql += " ORDER BY ZZC_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_STATUS->( EOF() )
         aAdd( aBrowse, { T_STATUS->ZZC_LEGE, T_STATUS->ZZC_CODIGO, T_STATUS->ZZC_NOME } )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Status de Tarefas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
//   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreStatus( "I", Space(06), Space(40) ) )
//   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreStatus( "A", aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ]  ) )
//   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbreStatus( "E", aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ]  ) )

   @ C(117),C(005) Button "Fluxo"  Size C(037),C(012) PIXEL OF oDlg ACTION( U_ESPSTA04() )
   @ C(117),C(205) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   // Cria Browse
   If Len(aBrowse) <> 0
      oBrowse := TCBrowse():New( 005 , 005, 305, 140,,{'','Codigo','Descrição dos Status'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

      // Seta vetor para a browse                            
      oBrowse:SetArray(aBrowse) 
    
      // Monta a linha a ser exibina no Browse
      oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "1", oBranco   ,;
                            If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                            If(aBrowse[oBrowse:nAt,01] == "3", oPink     ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "4", oAmarelo  ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                            If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                            If(aBrowse[oBrowse:nAt,01] == "0", oCancel   ,;
                            If(aBrowse[oBrowse:nAt,01] == "9", oEncerra, "")))))))))),;                         
                            aBrowse[oBrowse:nAt,02]            ,;
                            aBrowse[oBrowse:nAt,03]            } }
   Endif   

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWS()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZC_CODIGO, "
   cSql += "       ZZC_NOME  , "
   cSql += "       ZZC_LEGE    "
   cSql += "  FROM " + RetSqlName("ZZC")
   cSql += " WHERE ZZC_DELETE = ''"
   cSql += " ORDER BY ZZC_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   If T_STATUS->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_STATUS->( EOF() )
         aAdd( aBrowse, { T_STATUS->ZZC_LEGE, T_STATUS->ZZC_CODIGO, T_STATUS->ZZC_NOME } )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   // Cria Browse
//   oBrowse := TCBrowse():New( 005 , 005, 305, 140,,{'','Codigo','Descrição dos Status'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01] == "1", oBranco   ,;
                         If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                         If(aBrowse[oBrowse:nAt,01] == "3", oPink     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "4", oAmarelo  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                         If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                         If(aBrowse[oBrowse:nAt,01] == "9", oEncerra, ""))))))))),;                         
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            } }

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreStatus( _Tipo, _Codigo, _Nome)

   If _Tipo == "I"
      U_ESPSTA02("I", Space(06), Space(40) ) 
   Endif
      
   If _Tipo == "A"
      U_ESPSTA02("A", _Codigo, _Nome ) 
   Endif
      
   If _Tipo == "E"
      U_ESPSTA02("E", _Codigo, _Nome ) 
   Endif

   aBrowse := {}

   CarregaBRWS()

Return .T.   