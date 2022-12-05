#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR20.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 02/04/2015                                                          *
// Objetivo..: Programa que abre tela para informação das regras/especificações de *
//             tarefas.                                                            *
//**********************************************************************************

User Function ESPTAR20(__Tarefas, __Sequencia, __Titulo, __Solicitante)

   Local lChumba     := .F.

   Private cTarefa	   := Alltrim(__Tarefas) + "." + Alltrim(__Sequencia)
   Private cTitulo	   := Alltrim(__Titulo)
   Private cSolici	   := Alltrim(__Solicitante)
   Private cPrograma   := Space(25)
   Private cCriacao    := Space(25)
   Private cAutor 	   := Space(25)
   Private cMemo1	   := ""
   Private cMemo2	   := ""
   Private cParametros := ""
   Private cEspecifica := ""
   Private cAssunto	   := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4
   Private oMemo5

   Private aReuniao := {}

   Private oDlgR

   // Verifica se já existe registro de especificação para a tarefa selecionada
   If Select("T_REGRAS") > 0
      T_REGRAS->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT ZT6_FILIAL,"
   cSql += "       ZT6_TARE  ,"
   cSql += "       ZT6_SEQU  ,"
   cSql += "	   ZT6_PROG  ,"
   cSql += "	   ZT6_CRIA  ,"
   cSql += "	   ZT6_AUTO  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT6_PARA)) AS PARAMETROS,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT6_REGR)) AS REGRAS     "
   cSql += "  FROM " + RetSqlName("ZT6")
   cSql += " WHERE ZT6_TARE = '" + Alltrim(__Tarefas)   + "'"
   cSql += "   AND ZT6_SEQU = '" + Alltrim(__Sequencia) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REGRAS", .T., .T. )

   If T_REGRAS->( EOF() )
      cPrograma    := Space(25)
      cCriacao     := Ctod("  /  /    ")
      cAutor 	   := Space(30)
      cParametros  := ""
      cEspecifica  := ""
      cAssunto	   := ""    
   Else
      cPrograma    := T_REGRAS->ZT6_PROG
      cCriacao     := Ctod(Substr(T_REGRAS->ZT6_CRIA,07,02) + "/" + Substr(T_REGRAS->ZT6_CRIA,05,02) + "/" + Substr(T_REGRAS->ZT6_CRIA,01,04))
      cAutor 	   := T_REGRAS->ZT6_AUTO
      cParametros  := T_REGRAS->PARAMETROS
      cEspecifica  := T_REGRAS->REGRAS
      cAssunto	   := ""
   Endif

   // Envia para a função que carrega o grid das reuniões
   CargaReuniao(1, __Tarefas, __Sequencia)

   // Desenha a tela
   DEFINE MSDIALOG oDlgR TITLE "ESPECIFICAÇÃO DE PROGRAMA" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(088),C(005) Jpeg FILE "logoautomav.bmp" Size C(040),C(132) PIXEL NOBORDER OF oDlgR

   @ C(001),C(042) GET oMemo1 Var cMemo1 MEMO Size C(001),C(232) PIXEL OF oDlgR

   @ C(005),C(049) Say "Tarefa Nº"         Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(005),C(084) Say "Título da Tarefa"  Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(005),C(327) Say "Solicitante"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(005),C(390) Say "Registro Reuniões" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(092),C(390) Say "Assunto Abordado"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(035),C(049) Say "Nome Programa"     Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(035),C(159) Say "Data de Criação"   Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(035),C(244) Say "Autor"             Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(047),C(049) Say "Parâmetros"        Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(077),C(049) Say "Especificação"     Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgR

   @ C(015),C(049) MsGet oGet1  Var cTarefa          Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba
   @ C(015),C(084) MsGet oGet2  Var cTitulo          Size C(236),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba
   @ C(015),C(327) MsGet oGet3  Var cSolici          Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba
   @ C(028),C(049) GET   oMemo2 Var cMemo2 MEMO      Size C(339),C(001)                              PIXEL OF oDlgR
   @ C(034),C(091) MsGet oGet4  Var cPrograma        Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(034),C(200) MsGet oGet5  Var cCriacao         Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(034),C(261) MsGet oGet6  Var cAutor           Size C(126),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR
   @ C(057),C(049) GET   oMemo3 Var cParametros MEMO Size C(338),C(018)                              PIXEL OF oDlgR
   @ C(084),C(049) GET   oMemo4 Var cEspecifica MEMO Size C(338),C(120)                              PIXEL OF oDlgR
   @ C(100),C(390) GET   oMemo5 Var cAssunto    MEMO Size C(110),C(103)                              PIXEL OF oDlgR

   @ C(208),C(431) Button "Impressão"              Size C(030),C(012) PIXEL OF oDlgR
   @ C(208),C(470) Button "Voltar"                 Size C(030),C(012) PIXEL OF oDlgR ACTION( GrvEspecifica() )

   @ C(078),C(391) Button "Incluir"                 Size C(030),C(012) PIXEL OF oDlgR ACTION( ChamaRun("I", cTarefa, 0) )
   @ C(078),C(432) Button "Alterar"                 Size C(030),C(012) PIXEL OF oDlgR ACTION( ChamaRun("A", cTarefa, aReuniao[oReuniao:nAt,01]) )
   @ C(078),C(470) Button "Excluir"                 Size C(030),C(012) PIXEL OF oDlgR ACTION( ChamaRun("E", cTarefa, aReuniao[oReuniao:nAt,01]) )

   // Cria o grid de Controle de Reuniões
   oReuniao := TSBrowse():New(018,500,137,078,oDlgR,,1,,1)
   oReuniao:AddColumn( TCColumn():New('Código',,,{|| },{|| }) )
   oReuniao:AddColumn( TCColumn():New('Data'  ,,,{|| },{|| }) )
   oReuniao:AddColumn( TCColumn():New('Hora'  ,,,{|| },{|| }) )
   oReuniao:SetArray(aReuniao)

   oReuniao:bLDblClick := {|| MOSTRARUN(aReuniao[oReuniao:nAt,01], __Tarefas, __Sequencia) } 

   ACTIVATE MSDIALOG oDlgR CENTERED 

Return(.T.)

// Função que chama a tela de registro de assunto de reuniões
Static Function ChamaRun(__Operacao, _Tarefa, _Codigo)

   Do Case
      Case __Operacao == "I"
           U_ESPTAR21("I", _Tarefa, 0)      
      Case __Operacao == "A"
           U_ESPTAR21("A", _Tarefa, _Codigo)
      Case __Operacao == "E"                 
           U_ESPTAR21("E", _Tarefa, _Codigo)
   EndCase
   
   // Envia para a função que carrega o grid das reuniões
   CargaReuniao(2, Substr(_Tarefa,01,06), Substr(_Tarefa,08,02))

Return(.T.)   

// Função que mostra o assunto da reunião selecionada
Static Function MostraRun(__Reuniao, __Tarefa, __Sequencia)

   Local cSql := ""
   
   If Select("T_ASSUNTO") > 0
      T_ASSUNTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT7_ASSU)) AS ASSUNTO"
   cSql += "  FROM " + RetSqlName("ZT7")
   cSql += " WHERE ZT7_TARE  = '" + Alltrim(__Tarefa)    + "'"
   cSql += "   AND ZT7_SEQU  = '" + Alltrim(__Sequencia) + "'"
   cSql += "   AND ZT7_CODI  = '" + Alltrim(__Reuniao)   + "'"
   cSql += "   AND ZT7_DELE  = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ASSUNTO", .T., .T. )

   cAssunto := IIF(T_ASSUNTO->( EOF() ), "", T_ASSUNTO->ASSUNTO)
   oMemo5:Refresh()
   
Return(.T.)   

// Função que grava a especificação
Static Function GrvEspecifica()

   // Grava a regra na tabela de tarefas
   DbSelectArea("ZT6")
   DbSetOrder(1)
   If !DbSeek(xfilial("ZT6") + Substr(cTarefa,01,06) + Substr(cTarefa,08,02))
      RecLock("ZT6",.T.)
      ZT6_FILIAL := "  "
      ZT6_TARE   := Substr(cTarefa,01,06)
      ZT6_SEQU   := Substr(cTarefa,08,02)
      ZT6_PROG   := cPrograma
      ZT6_CRIA   := cCriacao
      ZT6_AUTO   := cAutor
      ZT6_PARA   := cParametros
      ZT6_REGR   := cEspecifica
      MsUnLock()              
   Else
      RecLock("ZT6",.F.)
      ZT6_PROG   := cPrograma
      ZT6_CRIA   := cCriacao
      ZT6_AUTO   := cAutor
      ZT6_PARA   := cParametros
      ZT6_REGR   := cEspecifica
      MsUnLock()              
   Endif

   oDlgR:End() 

Return(.T.)   

// Função que carrega o grid de reuniões
Static Function CargaReuniao(_PorOnde, __Tarefas, __Sequencia)

   Local cSql := ""
   
   If Select("T_REUNIAO") > 0
      T_REUNIAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZT7_FILIAL,"
   cSql += "       ZT7_TARE  ,"
   cSql += "       ZT7_SEQU  ,"
   cSql += "       ZT7_CODI  ,"
   cSql += "       ZT7_DATA  ,"
   cSql += "       ZT7_HORA  ,"
   cSql += "       ZT7_ENVO  ,"
   cSql += "       ZT7_ASSU  ,"
   cSql += "       ZT7_DELE   "
   cSql += "  FROM " + RetSqlName("ZT7")
   cSql += " WHERE ZT7_TARE  = '" + Alltrim(__Tarefas)   + "'"
   cSql += "   AND ZT7_SEQU  = '" + Alltrim(__Sequencia) + "'"
   cSql += "   AND ZT7_CODI <> ''"
   cSql += "   AND ZT7_DELE  = ''"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REUNIAO", .T., .T. )

   T_REUNIAO->( DbGoTop() )
   
   aReuniao := {}

   WHILE !T_REUNIAO->( EOF() )
      aAdd( aReuniao, { T_REUNIAO->ZT7_CODI,;
                        Substr(T_REUNIAO->ZT7_DATA,07,02) + "/" + Substr(T_REUNIAO->ZT7_DATA,05,02) + "/" + Substr(T_REUNIAO->ZT7_DATA,01,04) ,;
                        T_REUNIAO->ZT7_HORA})
      T_REUNIAO->( DbSkip() )
   ENDDO

   If _PorOnde == 1
      Return(.T.)
   Endif
                                    
   oReuniao:SetArray(aReuniao)
   oReuniao:Refresh()
   
Return(.T.)
   











/*

   Local cSql       := ""
   Local lChumba    := .F.
   Local cTarefaTar	:= __Tarefas
   Local cSequenTar := __Sequencia
   Local cTituloTar := __Titulo
   Local cMemo1	    := ""
   Local oMemo1
   Local oGet1
   Local oGet2
   Local oGet3
   
   Private cRegras  := ""
   Private oRegras

   Private oDlgR

   // Pesquisa a regra para a tarefa selecionada
   If Select("T_REGRAS") > 0
      T_REGRAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS REGRA"
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += "WHERE ZZG_CODI   = '" + Alltrim(cTarefaTar) + "'"
   cSql += "  AND ZZG_SEQU   = '" + Alltrim(cSequenTar) + "'"
   cSql += "  AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REGRAS", .T., .T. )

   cRegras := IIF(T_REGRAS->( EOF() ), "", T_REGRAS->REGRA)

   oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   DEFINE MSDIALOG oDlgR TITLE "Especificações da Tarefa" FROM C(178),C(181) TO C(634),C(939) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(030) PIXEL NOBORDER OF oDlgR

   @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(374),C(001) PIXEL OF oDlgR

   @ C(040),C(005) Say "Código"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(040),C(032) Say "Sq."                      Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(040),C(048) Say "Título da Tarefa"         Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(062),C(005) Say "Especificação da Tarefa"  Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgR

   @ C(050),C(005) MsGet oGet1   Var cTarefaTar   Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba
   @ C(050),C(032) MsGet oGet2   Var cSequenTar   Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba
   @ C(050),C(048) MsGet oGet3   Var cTituloTar   Size C(286),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgR When lChumba
   @ C(071),C(005) GET   oRegras Var cRegras MEMO Size C(371),C(153) Font oFont01                 PIXEL OF oDlgR

   @ C(047),C(338) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgR ACTION( OdlgR:End() )

   ACTIVATE MSDIALOG oDlgR CENTERED

   // Grava a regra na tabela de tarefas
   DbSelectArea("ZZG")
   DbSetOrder(1)
   If DbSeek(xfilial("ZZG") + cTarefaTar + cSequenTar)
      RecLock("ZZG",.F.)
      ZZG_SOL1 := cRegras
      MsUnLock()              
   Endif

Return(.T.)

*/