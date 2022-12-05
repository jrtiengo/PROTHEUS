#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPSTA03.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/01/2012                                                          *
// Objetivo..: Programa que mostra as cores da Legenda na Tela de Tarefas          *
//**********************************************************************************

User Function ESPSTA03()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oXVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oXVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oXAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oXAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oXPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oXLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oXCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oXBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oXPink     := LoadBitmap(GetResources(),'br_pink')
   Private oXCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oXEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlg

   Private aXBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   aXBrowse := {}

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
      aXBrowse := {}
   Else
      WHILE !T_STATUS->( EOF() )
         aAdd( aXBrowse, { T_STATUS->ZZC_LEGE, T_STATUS->ZZC_CODIGO, T_STATUS->ZZC_NOME } )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Legendas das Tarefas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(205) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   // Cria Browse
   If Len(aXBrowse) <> 0
      oXBrowse := TCBrowse():New( 005 , 005, 305, 140,,{'','Codigo','Descrição dos Status'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

      // Seta vetor para a browse                            
      oXBrowse:SetArray(aXBrowse) 
    
      // Monta a linha a ser exibina no Browse
      oXBrowse:bLine := {||{ If(aXBrowse[oXBrowse:nAt,01] == "1", oXBranco   ,;
                             If(aXBrowse[oXBrowse:nAt,01] == "2", oXVerde    ,;
                             If(aXBrowse[oXBrowse:nAt,01] == "3", oXPink     ,;                         
                             If(aXBrowse[oXBrowse:nAt,01] == "4", oXAmarelo  ,;                         
                             If(aXBrowse[oXBrowse:nAt,01] == "5", oXAzul     ,;                         
                             If(aXBrowse[oXBrowse:nAt,01] == "6", oXLaranja  ,;                         
                             If(aXBrowse[oXBrowse:nAt,01] == "7", oXPreto    ,;                         
                             If(aXBrowse[oXBrowse:nAt,01] == "8", oXVermelho ,;
                             If(aXBrowse[oXBrowse:nAt,01] == "X", oXCancel   ,;
                             If(aXBrowse[oXBrowse:nAt,01] == "9", oXEncerra, "")))))))))),;                         
                             aXBrowse[oXBrowse:nAt,02]            ,;
                             aXBrowse[oXBrowse:nAt,03]            } }
   Endif   

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)                    
