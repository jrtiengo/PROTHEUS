#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPEMA01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 08/11/2013                                                          *
// Objetivo..: Programa que envia e-mail informativo para o Gestor de projetos das *
//             Tarefas que estão com Status de Liberador par4a Produção.           *
//**********************************************************************************

User Function ESPEMA01()

   Local cSql        := ""
   Local lChumba     := .F.
   Local cRegistros  := 0
   Local nContar     := 0

   Local oRegistros 
   
   Private oOk      := LoadBitmap( GetResources(), "LBOK" )
   Private oNo      := LoadBitmap( GetResources(), "LBNO" )
   Private aTarefas := {}
   Private oTarefas
   Private oDlgX

   // Pesquisa os produtos da lista de preço selecionada      
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.ZZG_FILIAL,"
   cSql += "       A.ZZG_CODI  ,"
   cSql += "       A.ZZG_SEQU  ,"
   cSql += "       A.ZZG_TITU  ,"
   cSql += "       A.ZZG_USUA  ,"
   cSql += "       A.ZZG_DATA  ,"
   cSql += "       A.ZZG_HORA  ,"
   cSql += "       A.ZZG_STAT  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS SOLICITACAO," 
   cSql += "       A.ZZG_DES1  ,"
   cSql += "       A.ZZG_PRIO  ,"
   cSql += "       A.ZZG_NOT1  ,"
   cSql += "       A.ZZG_PREV  ,"
   cSql += "       A.ZZG_TERM  ,"
   cSql += "       A.ZZG_PROD  ,"
   cSql += "       A.ZZG_SOL1  ,"
   cSql += "       A.ZZG_DELE  ,"
   cSql += "       A.ZZG_ORIG  ,"
   cSql += "       A.ZZG_CHAM  ,"
   cSql += "       A.ZZG_COMP  ,"
   cSql += "       A.ZZG_PROG  ,"
   cSql += "       A.ZZG_PROJ  ,"
   cSql += "       B.ZZD_NOME  ,"
   cSql += "       C.ZZF_NOME  ,"
   cSql += "       D.ZZB_NOME   "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZD") + " B, " 
   cSql += "       " + RetSqlName("ZZF") + " C, "
   cSql += "       " + RetSqlName("ZZB") + " D  "
   cSql += " WHERE A.ZZG_DELE  = ''"
   cSql += "   AND A.ZZG_STAT = '8'"
   cSql += "   AND A.ZZG_ORIG = '000001'"
   cSql += "   AND (A.ZZG_PROG <> '000009' AND A.ZZG_PROD <> '000008')"
   cSql += "   AND A.ZZG_PRIO = B.ZZD_CODIGO "
   cSql += "   AND A.ZZG_ORIG = C.ZZF_CODIGO "
   cSql += "   AND A.ZZG_COMP = D.ZZB_CODIGO "
   cSql += " ORDER BY A.ZZG_PRIO, A.ZZG_DATA, A.ZZG_PREV "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   T_TAREFAS->( DbGoTop() )

   nContar := 0

   WHILE !T_TAREFAS->( EOF() )

      aAdd( aTarefas, { .T.                             ,;
                         ALLTRIM(T_TAREFAS->ZZG_CODI) + "." + ALLTRIM(T_TAREFAS->ZZG_SEQU) ,;
                         T_TAREFAS->ZZG_TITU            ,;
                         Substr(T_TAREFAS->ZZG_DATA,07,02) + "/" + Substr(T_TAREFAS->ZZG_DATA,05,02) + "/" + Substr(T_TAREFAS->ZZG_DATA,01,04) ,;
                         ALLTRIM(T_TAREFAS->ZZG_HORA)   ,;
                         ALLTRIM(T_TAREFAS->ZZG_USUA)   ,;
                         ALLTRIM(T_TAREFAS->SOLICITACAO)})
      nContar += 1

      T_TAREFAS->( DbSkip() )
      
   ENDDO

   cRegistros := nContar

   If Len(aTarefas) == 0
      aAdd( aTarefas, { .F., "", "", "", "", "" } )
   Endif

   DEFINE MSDIALOG oDlgX TITLE "Enivi de E-Mail de Tarefas Liberadas para Produção" FROM C(178),C(181) TO C(618),C(908) PIXEL

   @ C(004),C(005) Jpeg FILE "logoautoma.bmp" Size C(075),C(051) PIXEL NOBORDER OF oDlgX

   @ C(025),C(187) Say "Relação de tarefas liberadas para produção para envio de e-mail ao Gestor de Tarefas"  Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(205),C(150) Say "Total de Registros"                                                                    Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

   @ C(204),C(190) MsGet oRegistros Var cRegistros When lChumba Size C(020),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgX

   @ C(203),C(005) Button "Marca Todos"    Size C(055),C(012) PIXEL OF oDlgX ACTION( MtTodos(1)  )
   @ C(203),C(062) Button "Desmarca Todos" Size C(055),C(012) PIXEL OF oDlgX ACTION( MtTodos(2)  )
   @ C(203),C(280) Button "EnviaR E-mail"  Size C(037),C(012) PIXEL OF oDlgX ACTION( PedeEmail() ) 
   @ C(203),C(319) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

   // Cria Componentes Padroes do Sistema
   @ 40,05 LISTBOX oTarefas FIELDS HEADER "", "Código", "Título das Tarefas" ,"Data", "Hora", "Solicitamte" PIXEL SIZE 460,215 OF oDlgX ;
                            ON dblClick(aTarefas[oTarefas:nAt,1] := !aTarefas[oTarefas:nAt,1],oTarefas:Refresh())     
   oTarefas:SetArray( aTarefas )

   oTarefas:bLine := {||     {Iif(aTarefas[oTarefas:nAt,01],oOk,oNo),;
             					  aTarefas[oTarefas:nAt,02],;
         	        	          aTarefas[oTarefas:nAt,03],;
         	        	          aTarefas[oTarefas:nAt,04],;
         	        	          aTarefas[oTarefas:nAt,05],;
         	        	          aTarefas[oTarefas:nAt,06]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função que marca ou desmarca os registros pesquisados
Static Function MtTodos(_Tipo)

   Local nContar := 0

   For nContar = 1 to Len(aTarefas)
       aTarefas[nContar,1] := IIF(_Tipo == 1, .T., .F.)
   Next nContar       
 
   oTarefas:Refresh()
   
Return(.T.)         

// Função que abre janela de solicitação dos e-mail a ser enviados
Static Function PedeEmail()

   Local cEmail := Space(254)
   Local oGet1

   Private oDlgS

   DEFINE MSDIALOG oDlgS TITLE "Envio de E-mail para o Gestor das Tarefas" FROM C(178),C(181) TO C(272),C(710) PIXEL
  
   @ C(005),C(005) Say "Enviar e-mail para" Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(014),C(005) MsGet oGet1 Var cEmail   Size C(251),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS

   @ C(028),C(092) Button "Enviar" Size C(037),C(012) PIXEL OF oDlgS ACTION( MandaEmail(cEmail) )
   @ C(028),C(131) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgS:End() )

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// Função que abre envia os dados para o e-mail indicado
Static Function MandaEmail(cEmail)

   Local csql    := ""
   Local cTexto  := ""
   Local nContar := 0
   
   cTexto := ""
   cTexto := "Segue abaixo relação de tarefas de Status 8 - Liberado Para Produção para o seu conhecimento." + chr(13) + chr(10) + chr(13) + chr(10)

   cTexto += "*** E-mail enviado automaticamente pelo Sistema de Controle de Tarefas ***" + chr(13) + chr(10) + chr(13) + chr(10)

   // Monta as tarefas a serem enviadas no e-mail
   For nContar = 1 to Len(aTarefas)
   
       If aTarefas[nContar,01] == .F.
          Loop
       Endif
          
       cTexto += "Tarefa Nº..: "    + Alltrim(aTarefas[nContar,02])        + chr(13) + chr(10)
       cTexto += "Título........: " + Alltrim(aTarefas[nContar,03])        + chr(13) + chr(10)
       cTexto += "Abertura...: "    + aTarefas[nContar,04]                 + chr(13) + chr(10)
       cTexto += "Hora..........: " + aTarefas[nContar,05]                 + chr(13) + chr(10)
       cTexto += "Solicitante: "    + Alltrim(Upper(aTarefas[nContar,06])) + chr(13) + chr(10)
       cTexto += "Solicitação: "    + Alltrim(aTarefas[nContar,07])        + chr(13) + chr(10) + chr(13) + chr(10)
       
   Next nContar    

   cTexto += "Att."                                  + chr(13) + chr(10) + chr(13) + chr(10)
   cTexto += "Automatech Sistemas de Automação Ltda" + chr(13) + chr(10)
   cTexto += "Sistema de Controle de Tarefas"        + chr(13) + chr(10)

   // Envia e-mail
   U_AUTOMR20(cTexto , Alltrim(cEmail), "", "Relação de Tarefas Liberasdas para Produção" )

   oDlgS:End()

Return(.T.)