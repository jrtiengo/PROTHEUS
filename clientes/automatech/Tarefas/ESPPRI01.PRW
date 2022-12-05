#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRI01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Prioridades                   *
//**********************************************************************************

User Function ESPPRI01()

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}

   Private oDlg

   Private aBrowse := {}

   // Privates das NewGetDados
   Private oGetDados1

   CarregaBRWP()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Prioridades de Tarefas" FROM C(178),C(181) TO C(447),C(670) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(117),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbrePriori( "I", Space(06), Space(40), 0, "" ) )
   @ C(117),C(046) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbrePriori( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ], aBrowse[ oBrowse:nAt, 04 ] ) )
   @ C(117),C(087) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( _AbrePriori( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], aBrowse[ oBrowse:nAt, 03 ], aBrowse[ oBrowse:nAt, 04 ] ) )
   @ C(117),C(128) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:end() )

   oBrowse := TCBrowse():New( 005 , 005, 305, 140,,{'Codigo', 'Descrição das Prioridades', 'Ordem', 'Cor'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04]}}
      
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWP()

   aBrowse := {}

   // Carrega o Array com as Prioidades de Tarefas cadastradas
   If Select("T_PRIORI") > 0
      T_PRIORI->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZD_CODIGO, "
   cSql += "       ZZD_NOME  , "
   cSql += "       ZZD_ORDE  , "
   cSql += "       ZZD_COR     "
   cSql += "  FROM " + RetSqlName("ZZD")
   cSql += " WHERE ZZD_DELETE = ''"
   cSql += " ORDER BY ZZD_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORI", .T., .T. )

   If T_PRIORI->( EOF() )
      aBrowse := {}
   Else
      WHILE !T_PRIORI->( EOF() )

         Do Case
            Case Alltrim(T_PRIORI->ZZD_COR) == "1"
                 __Cor := "1 < Preto"
            Case Alltrim(T_PRIORI->ZZD_COR) == "2"
                 __Cor := "2 < Azul"
            Case Alltrim(T_PRIORI->ZZD_COR) == "3"
                 __Cor := "3 < Verde"
            Case Alltrim(T_PRIORI->ZZD_COR) == "4"
                 __Cor := "4 < Azul Claro"
            Case Alltrim(T_PRIORI->ZZD_COR) == "5"
                 __Cor := "5 < Vermelho"
            Case Alltrim(T_PRIORI->ZZD_COR) == "6"
                 __Cor := "6 < Magenta"
            Case Alltrim(T_PRIORI->ZZD_COR) == "7"
                 __Cor := "7 < Marrom"
            Case Alltrim(T_PRIORI->ZZD_COR) == "8"
                 __Cor := "8 < Cinza"
            Case Alltrim(T_PRIORI->ZZD_COR) == "A"
                 __Cor := "A > Cinza"
            Case Alltrim(T_PRIORI->ZZD_COR) == "B"
                 __Cor := "B > Azul"
            Case Alltrim(T_PRIORI->ZZD_COR) == "C"
                 __Cor := "C > Verde"
            Case Alltrim(T_PRIORI->ZZD_COR) == "D"
                 __Cor := "D > Azul Claro"           
            Case Alltrim(T_PRIORI->ZZD_COR) == "E"
                 __Cor := "E > Vermelho"
            Case Alltrim(T_PRIORI->ZZD_COR) == "F"
                 __Cor := "F > Magenta"
            Case Alltrim(T_PRIORI->ZZD_COR) == "G"
                 __Cor := "G > Amarelo"
            Case Alltrim(T_PRIORI->ZZD_COR) == "H"
                 __Cor := "H > Branco"
            Otherwise
                 __Cor := "H > Branco"
         EndCase                             

         aAdd( aBrowse, { T_PRIORI->ZZD_CODIGO, T_PRIORI->ZZD_NOME, T_PRIORI->ZZD_ORDE, __Cor} )
         T_PRIORI->( DbSkip() )
      ENDDO
   Endif

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbrePriori( _Tipo, _Codigo, _Nome, _Ordem, _Corx)

   If _Tipo == "I"
      U_ESPPRI02("I", Space(06), Space(40), 0, "" ) 
   Endif
      
   If _Tipo == "A"
      U_ESPPRI02("A", _Codigo, _Nome, _Ordem, Substr(_Corx,01,01) ) 
   Endif
      
   If _Tipo == "E"
      U_ESPPRI02("E", _Codigo, _Nome, _Ordem, Substr(_Corx,01,01) ) 
   Endif

   aBrowse := {}

   CarregaBRW()

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04]}}
   
Return .T.   