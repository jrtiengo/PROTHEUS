#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPLIB01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/02/2012                                                          *
// Objetivo..: Programa de Aprovação/Reprovação de Tarefas                         *
//**********************************************************************************

User Function ESPLIB01()

   Private oDlg
   Private aBrowse := {}
   Private oGetDados1
   Private lHoras  := .T.

   aBrowse := {}

   // Carrega os históricos para display
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL," + chr(13)
   cSql += "       A.ZZG_CODI  ," + chr(13)
   cSql += "       A.ZZG_SEQU  ," + chr(13)
   cSql += "       A.ZZG_PRIO  ," + chr(13)
   cSql += "       A.ZZG_TITU  ," + chr(13)
   cSql += "       A.ZZG_DATA  ," + chr(13)
   cSql += "       A.ZZG_HORA  ," + chr(13)
   cSql += "       A.ZZG_COMP  ," + chr(13)
   cSql += "       A.ZZG_USUA  ," + chr(13)
   cSql += "       A.ZZG_STAT  ," + chr(13)
   cSql += "       A.ZZG_DES1  ," + chr(13)
   cSql += "       A.ZZG_NOT1  ," + chr(13)
   cSql += "       A.ZZG_PREV  ," + chr(13)
   cSql += "       A.ZZG_TERM  ," + chr(13)
   cSql += "       A.ZZG_PROD  ," + chr(13)
   cSql += "       A.ZZG_SOL1  ," + chr(13)
   cSql += "       A.ZZG_DELE  ," + chr(13)
   cSql += "       A.ZZG_ORIG  ," + chr(13)
   cSql += "       A.ZZG_CHAM  ," + chr(13)
   cSql += "       A.ZZG_PROG  ," + chr(13)
   cSql += "       B.ZZD_NOME  ," + chr(13)
   cSql += "       C.ZZF_NOME  ," + chr(13)
   cSql += "       D.ZZB_NOME  ," + chr(13)
   cSql += "       A.ZZG_PROJ   " + chr(13) 
   cSql += "  FROM " + RetSqlName("ZZG") + " A, " + chr(13)
   cSql += "       " + RetSqlName("ZZD") + " B, " + chr(13)
   cSql += "       " + RetSqlName("ZZF") + " C, " + chr(13)
   cSql += "       " + RetSqlName("ZZB") + " D  "    + chr(13)
   cSql += " WHERE A.ZZG_DELE   = ''" + chr(13)
   cSql += "   AND A.ZZG_PRIO   = B.ZZD_CODIGO " + chr(13)
   cSql += "   AND A.ZZG_ORIG   = C.ZZF_CODIGO " + chr(13)
   cSql += "   AND A.ZZG_DELE   = ' '          " + chr(13)
   cSql += "   AND A.D_E_L_E_T_ = ''           " + chr(13)
   cSql += "   AND C.ZZF_DELETE = ''"            + chr(13)
   cSql += "   AND A.ZZG_COMP   = D.ZZB_CODIGO " + chr(13)
   cSql += "   AND D.ZZB_DELETE = ''"            + chr(13)
   cSql += "   AND A.ZZG_STAT   = '1' "          + chr(13)
   cSql += " ORDER BY A.ZZG_STAT, A.ZZG_CODI, A.ZZG_SEQU"   + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

   If T_TAREFA->( EOF() )
      aAdd( aBrowse, { '', '', '', '', '', '', '', '', '', ''} )
   Else
      WHILE !T_TAREFA->( EOF() )
         aAdd( aBrowse, { Alltrim(T_TAREFA->ZZG_CODI) + "." + Alltrim(T_TAREFA->ZZG_SEQU)  ,;
                          IIF(EMPTY(ALLTRIM(T_TAREFA->ZZG_PROJ)), "Normal", "Projetos"),;
                          T_TAREFA->ZZD_NOME,;
                          T_TAREFA->ZZG_TITU,;
                          Substr(T_TAREFA->ZZG_DATA,07,02) + "/" + Substr(T_TAREFA->ZZG_DATA,05,02) + "/" + Substr(T_TAREFA->ZZG_DATA,01,04) ,;
                          T_TAREFA->ZZG_HORA,;                           
                          T_TAREFA->ZZF_NOME,;
                          T_TAREFA->ZZB_NOME,;
                          T_TAREFA->ZZG_USUA,;
                          T_TAREFA->ZZG_PROJ,;                          
                          } )
         T_TAREFA->( DbSkip() )
      ENDDO
   Endif

   DEFINE MSDIALOG oDlg TITLE "Aprovação/Reprovação de Tarefas" FROM C(178),C(181) TO C(577),C(884) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlg
   
   @ C(182),C(005) Button "Visão Geral do Projeto"                               Size C(094),C(012) PIXEL OF oDlg ACTION( U_ESPARV01(aBrowse[oBrowse:nAt,10], lHoras) )
   @ C(185),C(105) CheckBox oCheckBox1 Var lHoras  Prompt "Visualizar com Horas" Size C(062),C(008) PIXEL OF oDlg   

   @ C(182),C(268) Button "Analisar" Size C(037),C(012) PIXEL OF oDlg ACTION( liberaTar( aBrowse[ oBrowse:nAt, 01], aBrowse[ oBrowse:nAt, 02] ) )
   @ C(182),C(310) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 040 , 005, 440, 187,,{'Código','Tipo','Prio','Título', 'Data','Hora','Origem','Componente/Tipo','Usuário','Projeto'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01] ,;
                         aBrowse[oBrowse:nAt,02] ,;
                         aBrowse[oBrowse:nAt,03] ,;
                         aBrowse[oBrowse:nAt,04] ,;
                         aBrowse[oBrowse:nAt,05] ,;
                         aBrowse[oBrowse:nAt,06] ,;
                         aBrowse[oBrowse:nAt,07] ,;
                         aBrowse[oBrowse:nAt,08] ,;
                         aBrowse[oBrowse:nAt,09] ,;
                         aBrowse[oBrowse:nAt,10] } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a tela de alteração do status da tarefa
Static Function LiberaTar( _Codigo, _Tipo)

   If _Tipo == "Normal"
      U_ESPTAR04(_Codigo)
   Else
      U_ESPTAR16(_Codigo)
   Endif      
   
   oDlg:End()
   U_ESPLIB01()   
   
Return .T.

// Função que troca a prioridade das tarefas
// Esta função foi utilizada uma única vez para trocar as prioridades das tarefas conforme solicitação do Sr. Gustavo Regal
Static Function trocapriori()
                             
   Local cSql := ""
   
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_PRIO "
   cSql += "  FROM " + RetSqlName("ZZG")
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

   If T_TAREFA->( EOF() )
      Return(.T.)
   Endif

   T_TAREFA->( DbGoTop() )

   WHILE !T_TAREFA->( EOF() )
    
      DbSelectArea("ZZG")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZG") + T_TAREFA->ZZG_CODI + T_TAREFA->ZZG_SEQUE)
         RecLock("ZZG",.F.)

         Do Case
            Case T_TAREFA->ZZG_PRIO == '000025'
                 ZZG_PRIO := '000001'
            Case T_TAREFA->ZZG_PRIO == '000001'
                 ZZG_PRIO := '000005'
            Case T_TAREFA->ZZG_PRIO == '000005'
                 ZZG_PRIO := '000010'
            Case T_TAREFA->ZZG_PRIO == '000010'
                 ZZG_PRIO := '000015'
            Case T_TAREFA->ZZG_PRIO == '000015'
                 ZZG_PRIO := '000020'
            Case T_TAREFA->ZZG_PRIO == '000020'
                 ZZG_PRIO := '000025'
         EndCase
                                                                                 
         MsUnLock()              
         
      Endif
      
      T_TAREFA->( DbSkip() )
      
   ENDDO

   MsgAlert("Prioridades alteradas com sucesso!")
   
Return(.T.)