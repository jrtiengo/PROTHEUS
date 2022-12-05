#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPCAL01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/06/2014                                                          *
// Objetivo..: Calendário de Previsão de Entrega de Tarefas                        *1
//**********************************************************************************

User Function ESPCAL01()
                      
   Local nContar := 0
   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cMes	 := Month(Date())
   Private cAno	 := Year(Date())

   Private oGet1
   Private oGet2

   Private Botao01 := ""
   Private Botao02 := ""
   Private Botao03 := ""
   Private Botao04 := ""   
   Private Botao05 := ""
   Private Botao06 := ""
   Private Botao07 := ""
   Private Botao08 := ""
   Private Botao09 := ""   
   Private Botao10 := ""
   Private Botao11 := ""
   Private Botao12 := ""
   Private Botao13 := ""
   Private Botao14 := ""   
   Private Botao15 := ""
   Private Botao16 := ""
   Private Botao17 := ""
   Private Botao18 := ""
   Private Botao19 := ""   
   Private Botao20 := ""
   Private Botao21 := ""
   Private Botao22 := ""
   Private Botao23 := ""
   Private Botao24 := ""   
   Private Botao25 := ""
   Private Botao26 := ""
   Private Botao27 := ""
   Private Botao28 := ""
   Private Botao29 := ""   
   Private Botao30 := ""
   Private Botao31 := ""
   Private Botao32 := ""
   Private Botao33 := ""
   Private Botao34 := ""   
   Private Botao35 := ""   
   Private Botao36 := ""   
   Private Botao37 := ""   
   Private Botao38 := ""   
   Private Botao39 := ""   
   Private Botao40 := ""   
   Private Botao41 := ""   
   Private Botao42 := ""                     
   
   Private oDlg

   // Carrega o Calendário com o mês/ano selecionado
   Carrega_Calendario(cMes, cAno, 1)

   DEFINE MSDIALOG oDlg TITLE "Calendário de Entrega de Tarefas" FROM C(178),C(181) TO C(558),C(690) PIXEL
 
   @ C(024),C(155) Say "CALENDÁRIO PREVISÃO DE ENTREGA DE TAREFAS" Size C(135),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"                      Size C(126),C(029)                 PIXEL NOBORDER OF oDlg
   @ C(040),C(005) Say "MÊS:"                                      Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(040),C(076) Say "ANO:"                                      Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(033),C(002) GET oMemo1 Var cMemo1 MEMO                      Size C(262),C(001) PIXEL OF oDlg
   @ C(052),C(002) GET oMemo2 Var cMemo2 MEMO                      Size C(262),C(001) PIXEL OF oDlg
   
   @ C(056),C(002) Button "DOMINGO" Size C(037),C(015) PIXEL OF oDlg
   @ C(056),C(038) Button "SEGUNDA" Size C(037),C(015) PIXEL OF oDlg
   @ C(056),C(074) Button "TERÇA"   Size C(037),C(015) PIXEL OF oDlg
   @ C(056),C(110) Button "QUARTA"  Size C(037),C(015) PIXEL OF oDlg
   @ C(056),C(146) Button "QUINTA"  Size C(037),C(015) PIXEL OF oDlg
   @ C(056),C(182) Button "SEXTA"   Size C(037),C(015) PIXEL OF oDlg
   @ C(056),C(217) Button "SÁBADO"  Size C(037),C(015) PIXEL OF oDlg

   @ C(037),C(020) Button "<<" Size C(015),C(012) PIXEL OF oDlg ACTION( remontacal(1) )
   @ C(037),C(055) Button ">>" Size C(015),C(012) PIXEL OF oDlg ACTION( remontacal(2) )
   @ C(037),C(092) Button "<<" Size C(015),C(012) PIXEL OF oDlg ACTION( remontacal(3) )
   @ C(037),C(134) Button ">>" Size C(015),C(012) PIXEL OF oDlg ACTION( remontacal(4) )

   @ C(038),C(038) MsGet oGet1  Var cMes       Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(038),C(110) MsGet oGet2  Var cAno       Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(071),C(002) Button botao01 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao01)), cMes, cAno))
   @ C(071),C(038) Button botao02 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao02)), cMes, cAno))
   @ C(071),C(074) Button botao03 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao03)), cMes, cAno))
   @ C(071),C(110) Button botao04 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao04)), cMes, cAno))
   @ C(071),C(146) Button botao05 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao05)), cMes, cAno))
   @ C(071),C(182) Button botao06 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao06)), cMes, cAno))
   @ C(071),C(217) Button botao07 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao07)), cMes, cAno))

   @ C(090),C(002) Button botao08 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao08)), cMes, cAno))
   @ C(090),C(038) Button botao09 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao09)), cMes, cAno))
   @ C(090),C(074) Button botao10 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao10)), cMes, cAno))
   @ C(090),C(110) Button botao11 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao11)), cMes, cAno))
   @ C(090),C(146) Button botao12 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao12)), cMes, cAno))
   @ C(090),C(182) Button botao13 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao13)), cMes, cAno))
   @ C(090),C(217) Button botao14 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao14)), cMes, cAno))

   @ C(109),C(002) Button botao15 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao15)), cMes, cAno))
   @ C(109),C(038) Button botao16 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao16)), cMes, cAno))
   @ C(109),C(074) Button botao17 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao17)), cMes, cAno))
   @ C(109),C(110) Button botao18 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao18)), cMes, cAno))
   @ C(109),C(146) Button botao19 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao19)), cMes, cAno))
   @ C(109),C(182) Button botao20 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao20)), cMes, cAno))
   @ C(109),C(217) Button botao21 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao21)), cMes, cAno))

   @ C(128),C(002) Button botao22 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao22)), cMes, cAno))
   @ C(128),C(038) Button botao23 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao23)), cMes, cAno))
   @ C(128),C(074) Button botao24 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao24)), cMes, cAno))
   @ C(128),C(110) Button botao25 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao25)), cMes, cAno))
   @ C(128),C(146) Button botao26 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao26)), cMes, cAno))
   @ C(128),C(182) Button botao27 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao27)), cMes, cAno))
   @ C(128),C(217) Button botao28 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao28)), cMes, cAno))

   @ C(147),C(002) Button botao29 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao29)), cMes, cAno))
   @ C(147),C(038) Button botao30 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao30)), cMes, cAno))
   @ C(147),C(074) Button botao31 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao31)), cMes, cAno))
   @ C(147),C(110) Button botao32 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao32)), cMes, cAno))
   @ C(147),C(146) Button botao33 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao33)), cMes, cAno))
   @ C(147),C(182) Button botao34 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao34)), cMes, cAno))
   @ C(147),C(217) Button botao35 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao35)), cMes, cAno))

   @ C(166),C(002) Button botao36 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao36)), cMes, cAno))
   @ C(166),C(038) Button botao37 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao37)), cMes, cAno))
   @ C(166),C(074) Button botao38 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao38)), cMes, cAno))
   @ C(166),C(110) Button botao39 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao39)), cMes, cAno))
   @ C(166),C(146) Button botao40 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao40)), cMes, cAno))
   @ C(166),C(182) Button botao41 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao41)), cMes, cAno))
   @ C(166),C(217) Button botao42 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao42)), cMes, cAno))

   @ C(037),C(206) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION (oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que remonta o calendário
Static Function remontacal(_Tipo)

   Local xMes := cMes
   Local xAno := cAno

   // Diminui mês
   If _Tipo == 1
      xMes := xMes - 1
      If xMes = 0
         xMes := 12
         xAno := cAno - 1
      Endif
   Endif
         
   // Aumenta mês
   If _Tipo == 2
      xMes := xMes + 1
      If xMes = 13
         xMes := 1
         xAno := xAno + 1
      Endif
   Endif

   // Diminui ano
   If _Tipo == 3
      xAno := xAno - 1
   Endif

   // Aumenta ano
   If _Tipo == 4
      xAno := xAno + 1
   Endif

   cMes := xMes
   cAno := xAno
   oGet1:Refresh()
   oGet2:Refresh()

   // Envia para a função que carrega o calendário conforme o mês/ano selecionados
   Carrega_calendario(xMes, xAno,2)

Return(.T.)

// Função que carrega o calendário com o mês/ano selecionado
Static Function Carrega_calendario(_Mes, _Ano, _Operacao)

   Local nContar     := 0
   Local _Dia        := 1
   Local PrimeiroDia := Ctod("  /  /    ")
   Local UltimoDia   := 0
   Local aQuantos    := {}
   Local xQuantidade := 0

   // Verifica qual o último dia de cada mês
   Do Case
      Case _Mes == 1
           PrimeiroDia := Ctod("01/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
           UltimoDia   := 31
      Case _Mes == 2
           UltimoDia := IIF(MOD(_Ano,4) == 0, 29, 28)
      Case _Mes == 3
           UltimoDia := 31
      Case _Mes == 4
           UltimoDia := 30
      Case _Mes == 5
           UltimoDia := 31
      Case _Mes == 6
           UltimoDia := 30
      Case _Mes == 7
           UltimoDia := 31
      Case _Mes == 8
           UltimoDia := 31
      Case _Mes == 9
           UltimoDia := 30
      Case _Mes == 10
           UltimoDia := 31
      Case _Mes == 11
           UltimoDia := 30
      Case _Mes == 12
           UltimoDia := 31
   EndCase           

   PrimeiroDia := Ctod("01/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))
   UltimodoMes := Ctod(Strzero(UltimoDia,2) + "/" + Strzero(_Mes,2) + "/" + Strzero(_Ano,4))

   // Verifica que dia da semana começou o mês/ano selecionado
   Do Case
      Case Dow(PrimeiroDia) == 1
           _Abertura := 1
      Case Dow(PrimeiroDia) == 2
           _Abertura := 2
      Case Dow(PrimeiroDia) == 3
           _Abertura := 3
      Case Dow(PrimeiroDia) == 4
           _Abertura := 4
      Case Dow(PrimeiroDia) == 5
           _Abertura := 5
      Case Dow(PrimeiroDia) == 6
           _Abertura := 6
      Case Dow(PrimeiroDia) == 7
           _Abertura := 7
   EndCase           
   
   // Limpa o coteúdo dos botões
   For nContar = 1 to 42
       j := Strzero(nContar,2)
       botao&j := ""
   Next nContar    

   // Pesquisa as quantidades por data das tarefas para display para o mês/ano selecionados
   If Select("T_QUANTOS") > 0
      T_QUANTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_PREV,"
   cSql += "       COUNT(*) AS QTD"
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_PREV >= '" + Alltrim(Dtoc(PrimeiroDia)) + "'"
   cSql += "   AND ZZG_PREV <= '" + Alltrim(Dtoc(UltimodoMes)) + "'"
   cSql += " GROUP BY ZZG_PREV"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QUANTOS", .T., .T. )

   If T_QUANTOS->( EOF() )
      aQuantos := {}
   Else
      T_QUANTOS->( DbGoTop() )
      WHILE !T_QUANTOS->( EOF() )
         aAdd( aQuantos, { T_QUANTOS->ZZG_PREV, T_QUANTOS->QTD } )
         T_QUANTOS->( DbSkip() )
      ENDDO
   Endif

   // Carrega o Calendário
   _Dia    := 1

   For nContar = _Abertura to 42

       // Pesquisa a quantidade de tarefas para a data montada       
       xQuantidade := 0
       For nDatas = 1 to Len(aQuantos)
           If Int(Val(Substr(aQuantos[nDatas,01],07,02))) == _Dia .And. ;
              Int(Val(Substr(aQuantos[nDatas,01],05,02))) == _Mes .And. ;
              Int(Val(Substr(aQuantos[nDatas,01],01,04))) == _Ano
              xQuantidade := aQuantos[nDatas,02]
              Exit
           Endif
       Next nDatas       

       j := Strzero(nContar,2)

       If xQuantidade == 0
          botao&j := Strzero(_Dia,2)
       Else
          botao&j := Strzero(_Dia,2) + "     (" + Alltrim(Str(xQuantidade)) + ")"
       Endif
          
       _Dia    := _Dia + 1
       If _Dia > UltimoDia
          Exit
       Endif
   Next nContar              

   If _Operacao == 1
      Return(.T.)
   Endif

   @ C(071),C(002) Button botao01 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao01)), _Mes, _Ano))
   @ C(071),C(038) Button botao02 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao02)), _Mes, _Ano))
   @ C(071),C(074) Button botao03 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao03)), _Mes, _Ano))
   @ C(071),C(110) Button botao04 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao04)), _Mes, _Ano))
   @ C(071),C(146) Button botao05 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao05)), _Mes, _Ano))
   @ C(071),C(182) Button botao06 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao06)), _Mes, _Ano))
   @ C(071),C(217) Button botao07 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao07)), _Mes, _Ano))

   @ C(090),C(002) Button botao08 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao08)), _Mes, _Ano))
   @ C(090),C(038) Button botao09 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao09)), _Mes, _Ano))
   @ C(090),C(074) Button botao10 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao10)), _Mes, _Ano))
   @ C(090),C(110) Button botao11 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao11)), _Mes, _Ano))
   @ C(090),C(146) Button botao12 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao12)), _Mes, _Ano))
   @ C(090),C(182) Button botao13 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao13)), _Mes, _Ano))
   @ C(090),C(217) Button botao14 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao14)), _Mes, _Ano))

   @ C(109),C(002) Button botao15 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao15)), _Mes, _Ano))
   @ C(109),C(038) Button botao16 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao16)), _Mes, _Ano))
   @ C(109),C(074) Button botao17 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao17)), _Mes, _Ano))
   @ C(109),C(110) Button botao18 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao18)), _Mes, _Ano))
   @ C(109),C(146) Button botao19 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao19)), _Mes, _Ano))
   @ C(109),C(182) Button botao20 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao20)), _Mes, _Ano))
   @ C(109),C(217) Button botao21 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao21)), _Mes, _Ano))

   @ C(128),C(002) Button botao22 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao22)), _Mes, _Ano))
   @ C(128),C(038) Button botao23 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao23)), _Mes, _Ano))
   @ C(128),C(074) Button botao24 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao24)), _Mes, _Ano))
   @ C(128),C(110) Button botao25 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao25)), _Mes, _Ano))
   @ C(128),C(146) Button botao26 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao26)), _Mes, _Ano))
   @ C(128),C(182) Button botao27 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao27)), _Mes, _Ano))
   @ C(128),C(217) Button botao28 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao28)), _Mes, _Ano))

   @ C(147),C(002) Button botao29 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao29)), _Mes, _Ano))
   @ C(147),C(038) Button botao30 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao30)), _Mes, _Ano))
   @ C(147),C(074) Button botao31 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao31)), _Mes, _Ano))
   @ C(147),C(110) Button botao32 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao32)), _Mes, _Ano))
   @ C(147),C(146) Button botao33 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao33)), _Mes, _Ano))
   @ C(147),C(182) Button botao34 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao34)), _Mes, _Ano))
   @ C(147),C(217) Button botao35 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao35)), _Mes, _Ano))

   @ C(166),C(002) Button botao36 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao36)), _Mes, _Ano))
   @ C(166),C(038) Button botao37 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao37)), _Mes, _Ano))
   @ C(166),C(074) Button botao38 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao38)), _Mes, _Ano))
   @ C(166),C(110) Button botao39 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao39)), _Mes, _Ano))
   @ C(166),C(146) Button botao40 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao40)), _Mes, _Ano))
   @ C(166),C(182) Button botao41 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao41)), _Mes, _Ano))
   @ C(166),C(217) Button botao42 Size C(037),C(020) PIXEL OF oDlg ACTION(U_ESPCAL02(INT(VAL(botao42)), _Mes, _Ano))

Return(.T.)