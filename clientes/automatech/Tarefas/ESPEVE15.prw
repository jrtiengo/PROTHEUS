#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEVE15.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/10/2012                                                          *
// Objetivo..: Acompanhamento de Horas por Usuário/Mês/Ano                         *
//**********************************************************************************

User Function ESPEVE15()

   Local cSql        := "" 
   Local nContar     := 0

   Private aUsuarios := {}
   Private aMeses 	 := {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'}
   Private aAnos  	 := {}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private aBrowse   := {}

   aAdd( aBrowse, { '','','','','','','' } )

   Private oDlg

   // Carrega o combo de usuários (Desenvolvedores)
   // ---------------------------------------------
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aUsuarios := {}
   T_DESENVE->( DbGoTop() )
   WHILE !T_DESENVE->( EOF() )
      aAdd( aUsuarios, T_DESENVE->ZZE_CODIGO + " - " + Alltrim(T_DESENVE->ZZE_NOME) )
      T_DESENVE->( DbSkip() )
   ENDDO

   // Carrega o Combo de Anos
   For nContar = 2012 to (year(Date()) + 5)
       aAdd( aAnos, Strzero(nContar,4) )
   Next nContar    

   DEFINE MSDIALOG oDlg TITLE "Acompanhamento de Apontamento de Horas" FROM C(178),C(181) TO C(623),C(920) PIXEL

   @ C(007),C(005) Say "Usuário" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(008),C(189) Say "Mês"     Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(008),C(233) Say "Ano"     Size C(011),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(006),C(028) ComboBox cComboBx1 Items aUsuarios Size C(149),C(010) PIXEL OF oDlg
   @ C(006),C(202) ComboBox cComboBx2 Items aMeses    Size C(025),C(010) PIXEL OF oDlg
   @ C(006),C(246) ComboBox cComboBx3 Items aAnos     Size C(031),C(010) PIXEL OF oDlg

   @ C(005),C(287) Button "Pesquisar"  Size C(037),C(012) PIXEL OF oDlg ACTION( PesqHoras() )
   @ C(005),C(326) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   @ C(207),C(327) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlg

   oBrowse := TCBrowse():New( 025 , 005, 460, 233,,{'Dia', 'Semana', 'Evento', 'TH', 'THP', 'THE', 'Saldo'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;                                                  
                       } }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa o acompanhamento de horas
Static Function PesqHoras()
    
   Local cSql    := ""
   Local cDias   := 0
   Local nContar := 0   
   Local cData   := Ctod("  /  /    ")
   Local cEvento := ""
   Local cSemana := ""

   aBrowse := {}
   
   If Alltrim(cComboBx2)$('01#03#05#07#08#10#12')
      cDias := 31
   Endif
      
   If Alltrim(cComboBx2)$('02')
      If Mod(INT(VAL(cComboBx3)),4) == 0
         cDias := 29
      Else
         cDias := 28
      Endif
   Endif

   If Alltrim(cComboBx2)$('04#06#09#11')
      cDias := 30
   Endif

   cData := Ctod("01/" + cComboBx2 + "/" + cComboBx3)

   For nContar = 1 to cDias

       Do Case
          Case Dow(cData) == 1
               cSemana := "Domingo"
          Case Dow(cData) == 2
               cSemana := "Segunda"
          Case Dow(cData) == 3
               cSemana := "Terça"
          Case Dow(cData) == 4
               cSemana := "Quarta"
          Case Dow(cData) == 5
               cSemana := "Quinta"
          Case Dow(cData) == 6
               cSemana := "Sexta"
          Case Dow(cData) == 7
               cSemana := "Sábado"
       EndCase               
       
       // Pesquisa Evento Fixo para a data
       If Select("T_FIXO") > 0
          T_FIXO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZS_CODIGO,"
       cSql += "       ZZS_NOME  ,"
       cSql += "       ZZS_DIA   ,"
       cSql += "       ZZS_MES    "
       cSql += "  FROM " + RetSqlName("ZZS")
       cSql += " WHERE ZZS_DELETE = ''"
       cSql += "   AND ZZS_TIPO   = 'X'"  
       cSql += "   AND ZZS_DIA    = '" + Strzero(Day(CdATA),2) + "'"
       cSql += "   AND ZZS_MES    = '" + Alltrim(cComboBx2)    + "'"
       
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FIXO", .T., .T. )

       cEvento := IIF(T_FIXO->( EOF() ), "", T_FIXO->ZZS_NOME)

       aAdd( aBrowse, { Strzero(nContar,02), cSemana, cEvento,'','','','' } )
       
       cData := cData + 1
       
   Next nContar       
    
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;                                                  
                       } }

Return .T.