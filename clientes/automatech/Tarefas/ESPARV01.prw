#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPAARV01.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 03/10/2012                                                          *
// Objetivo..: Programa que gera o Tree View das Tarefas do projeto                *
//**********************************************************************************

User Function ESPARV01(cProjeto, lHoras)

   Local lChumba := .F.
   Local cGet1	 := Space(03)
   Local cGet2	 := Space(03)
   Local cGet3	 := Space(03)
   Local cGet4	 := Space(03)
   Local cGet5	 := Space(03)
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oMemo1
   Local oMemo2

   Local __Projeto  := ""
   Local __Cliente  := ""
   Local cSql       := ""
   Local nContar    := 0
   Local nPosicao   := 0

   Local H_Projeto  := 0
   Local H_Trabalha := 0

   Local nMeter1	:= 0
   Local oMeter1

   If Empty(Alltrim(cProjeto))
      MsgAlert("Visualização disponível somente para tarefas do Projeto.")
      Return .T.
   Endif

   // Pesquisa dados do Projeto para display
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT A.ZZY_CODIGO,"
   cSql += "       A.ZZY_TITULO,"
   cSql += "       A.ZZY_CLIENT,"
   cSql += "       A.ZZY_LOJA  ,"
   cSql += "       B.A1_NOME    "
   cSql += "  FROM " + RetSqlName("ZZY") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B  "
   cSql += " WHERE A.ZZY_DELETE = ' '"
   cSql += "   AND A.ZZY_CODIGO = '" + Alltrim(cProjeto) + "'"
   cSql += "   AND A.ZZY_CLIENT = B.A1_COD "
   cSql += "   AND A.ZZY_LOJA   = B.A1_LOJA"       

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return .T.
   Endif   
 
   __Projeto := "Projeto: " + Alltrim(T_PROJETO->ZZY_TITULO)
   __Cliente := "Cliente: " + Alltrim(T_PROJETO->A1_NOME)

   // Seleciona as tarefas do projeto para display
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_CODI,"
   cSql += "       ZZG_TITU,"
   cSql += "       ZZG_HTOT "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE = ''"   
   cSql += "   AND ZZG_PROJ = '" + Substr(cProjeto,01,06) + "'"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   DEFINE MSDIALOG oDlgT TITLE "Visão Geral de Projeto" FROM C(178),C(181) TO C(623),C(593) PIXEL

   @ C(178),C(009) Say "Total Hrs Projeto" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(178),C(055) Say "Hrs Trabalhadas"   Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(178),C(101) Say "Saldo"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(178),C(130) Say "% Realizado"       Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(178),C(166) Say "% A Realizar"      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   // Cria a Tree
   oTree := DbTree():New(3,2,205,265,oDlgT,,,.T.)

   // Cria a Linha do Projeto
   oTree:AddItem(__Projeto + Space(110 - Len(__Projeto)),"001", "FOLDER5" ,,,,1)

   // Cria a Linha do Nome do Cliente
   oTree:AddItem(__Cliente + Space(110 - Len(__Cliente)),"002", "FOLDER7",,,,2)	

   // Cria as linhas das tarefas do Projeto
   nContar := 3
   T_TAREFAS->( DbGoTop() )
   WHILE !T_TAREFAS->( EOF() )

      H_Projeto := H_Projeto + Val(T_TAREFAS->ZZG_HTOT)

      oTree:AddItem(Alltrim(T_TAREFAS->ZZG_TITU) + " - (" + Alltrim(T_TAREFAS->ZZG_HTOT) + " Hrs)", Strzero(nContar,3), "FOLDER6",,,,nContar)	      
      
      // Mostra as Horas da Tarefa selecionada
      If Select("T_HORAS") > 0
         T_HORAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZW_FILIAL, "
      cSql += "       ZZW_CODIGO, "
      cSql += "       ZZW_PROJ  , "
      cSql += "       ZZW_CLIENT, "
      cSql += "       ZZW_LOJA  , "
      cSql += "       ZZW_TARE  , "
      cSql += "       ZZW_DATA  , "
      cSql += "       ZZW_HORA  , "
      cSql += "       ZZW_USUA    "
      cSql += "  FROM " + RetSqlName("ZZW")
      cSql += " WHERE ZZW_PROJ = '" + Substr(cProjeto,01,06)       + "'"
      cSql += "   AND ZZW_TARE = '" + Alltrim(T_TAREFAS->ZZG_CODI) + "'"
      cSql += "   AND ZZW_DELE = ' '"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORAS", .T., .T. )

      If !T_HORAS->( EOF() )
         nPosicao := nContar
         T_HORAS->( DbGoTop() )
         WHILE !T_HORAS->( EOF() )
            H_Trabalha := H_Trabalha + Val(ZZW_HORA)
            If lHoras 
               oTree:AddItem(Space(9) + Substr(T_HORAS->ZZW_DATA,07,02) + "/"   + ;
                                        Substr(T_HORAS->ZZW_DATA,05,02) + "/"   + ;               
                                        Substr(T_HORAS->ZZW_DATA,01,04) + " - " + ;
                                        T_HORAS->ZZW_HORA + " Hsr" + " - " + T_HORAS->ZZW_USUA,Strzero(nPosicao,3), "" ,,,,nContar)	
            Endif                            
            T_HORAS->( DbSkip() )
         ENDDO
      Endif

      T_TAREFAS->( DbSkip() )
      
   ENDDO

   oTree:TreeSeek("001") // Retorna ao primeiro nível

   // Indica o término da contrução da Tree
   oTree:EndTree()

   cGet1 := Str(H_Projeto,5,1)
   cGet2 := Str(H_Trabalha,5,1)
   cGet3 := Str((H_Projeto - H_Trabalha),5,1)
   cGet4 := Str(Round(((H_Trabalha * 100) / H_Projeto),2),6,2)
   cGet5 := Str((100 - Round(((H_Trabalha * 100) / H_Projeto),2)),6,2)

   nMeter1 := Round(((H_Trabalha * 100) / H_Projeto),2)

   If nMeter1 > 100
      nMeter1 := 100
   Endif   

   @ C(174),C(001) GET oMemo1 Var cMemo1 MEMO Size C(202),C(001) PIXEL OF oDlgT
   @ C(188),C(009) MsGet oGet1 Var cGet1 Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(188),C(055) MsGet oGet2 Var cGet2 Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(188),C(101) MsGet oGet3 Var cGet3 Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(188),C(130) MsGet oGet4 Var cGet4 Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(188),C(166) MsGet oGet5 Var cGet5 Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT When lChumba
   @ C(201),C(000) GET oMemo2 Var cMemo2 MEMO Size C(202),C(001) PIXEL OF oDlgT

   @ C(164),C(002) Say "0 %"     Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(164),C(186) Say "100 %"   Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(165),C(013) METER oMeter1 VAR nMeter1 Size C(171),C(008) NOPERCENTAGE PIXEL OF oDlgT

   @ C(206),C(082) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   ACTIVATE DIALOG oDlgT CENTERED 

Return .T.