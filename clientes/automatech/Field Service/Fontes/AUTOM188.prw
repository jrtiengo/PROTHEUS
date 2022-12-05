#INCLUDE "PROTHEUS.CH"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM188.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho                                            ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 21/08/2013                                                           ##
// Objetivo..: Tela de Log de Manipulação de Chamados Técnicos, Orçamentos e Ordens ##
//             de Serviços (Field Service)                                          ##
// ###################################################################################

User Function AUTOM188()

   Local cSql       := ""
   Local __Ano      := Year(Date())
   Local nContar    := 0

   Private aMes     := {"", "01","02","03","04","05","06","07","08","09","10","11","12"}
   Private aAno     := {"", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024", "2025"}
   Private aTecnico := {}                                                        
   Private aBrowse  := {}
   Private cNumero  := Space(06)

   Private cMes
   Private cAno
   Private oGet1
   Private cTecnico

   Private oDlg

   For nContar = 1 to 20
       aAdd( aAno, __Ano )
       __Ano += 1
   Next nContar    

   cMes := Strzero(Month(Date()),2)
   cAno := Strzero(Year(Date()),4)

   // ############################################################
   // Envia para a rotina que pesquisa log para o mês/ano atual ##
   // ############################################################
   PesqLog(0)
   
   // ###############################
   // Carrega o Combo dos Técnicos ##
   // ###############################
//   If Select("T_TECNICOS") > 0
//      T_TECNICOS->( dbCloseArea() )
//   EndIf
//
//   cSql := ""
//   cSql := "SELECT AA1_CODUSR,"
//   cSql += "       AA1_NOMTEC "
//   cSql += "  FROM " + RetSqlName("AA1")
//   cSql += " WHERE D_E_L_E_T_  = ''"
//   cSql += "   AND AA1_CODUSR <> ''"
//   cSql += " ORDER BY AA1_NOMTEC   "
//
//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICOS", .T., .T. )
//
//   T_TECNICOS->( DbGoTop() )
//   
//   aAdd( aTecnico, "000000 - Todos os Técnicos" )
//
//   WHILE !T_TECNICOS->( EOF() )
//      aAdd( aTecnico, T_TECNICOS->AA1_CODUSR + " - " + Alltrim(T_TECNICOS->AA1_NOMTEC) )
//      T_TECNICOS->( DbSkip() )
//   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Log Manutenção Chamados, Orçamentos e Ordens de Serviços" FROM C(178),C(181) TO C(563),C(793) PIXEL

   @ C(004),C(005) Jpeg FILE "simboloauto.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(005),C(040) Say "Mês/Ano" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(103) Say "Nº OS"   Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(011),C(263) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlg ACTION( PesqLog(1) )

   @ C(014),C(040) ComboBox cMes     Items aMes     Size C(023),C(010) PIXEL OF oDlg
   @ C(014),C(065) ComboBox cAno     Items aAno     Size C(031),C(010) PIXEL OF oDlg
   @ C(014),C(103) MsGet    oGet1    Var   cNumero  Size C(049),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

// @ C(014),C(068) ComboBox cTecnico Items aTecnico Size C(190),C(010) PIXEL OF oDlg

// @ C(175),C(005) Button "Relatório" Size C(037),C(012) PIXEL OF oDlg ACTION( RelatoLog() )
   @ C(175),C(263) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 035 , 005, 380, 185,,{'FL'         ,;
                                                    'Nº OS'      ,; 
                                                    'Usuário'    ,; 
                                                    'Data'       ,; 
                                                    'Hora'       ,; 
                                                    'Cadastro'   ,; 
                                                    'Operação'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   aAdd( aBrowse, { "", "", "", "", "", "", "" } )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #################################################
// Função que pesquisa o log para o mês/ano atual ##
// #################################################
Static Function PesqLog(kTipo)

   MsgRun("Aguarde! Pesquisando log de OS ...", "Log de OS",{|| xPesqLog(kTipo) })

Return(.T.)

// ###############################################################
// Função que realiza a pesquisa conforme parâmetros informados ##
// ###############################################################
Static Function xPesqLog(kTipo)

   Local cSql      := ""
   Local cCadastro := ""
   Local cOperacao := ""

   If kTipo == 0
   Else
      If Empty(Alltrim(cMes))
         MsgAlert("Necessário informar o mês a ser pesquisado.")
         Return .T.
      Endif
      
      If Empty(Alltrim(cAno))
         MsgAlert("Necessário informar o ano a ser pesquisado.")
         Return .T.
      Endif
   Endif

   aBrowse := {}

   If Select("T_LOGS") > 0
      T_LOGS->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZS1_FILIAL,"
   cSql += "       ZS1_TECN  ,"
   cSql += "       ZS1_DATA  ,"
   cSql += "       ZS1_HORA  ,"
   cSql += "       ZS1_OPER  ,"
   cSql += "       ZS1_TIPO  ,"
   cSql += "       ZS1_ETIQ  ,"
   cSql += "       ZS1_NUMOS  "
   cSql += " FROM " + RetSqlName("ZS1")
   cSql += "WHERE D_E_L_E_T_ = ''"
   cSql += "  AND SUBSTRING(ZS1_DATA,05,02) = '" + Alltrim(cMes) + "'"
   cSql += "  AND SUBSTRING(ZS1_DATA,01,04) = '" + Alltrim(cAno) + "'"
  
   If Empty(Alltrim(cNumero))
   Else
      cSql += "  AND ZS1_NUMOS = '" + Alltrim(cNumero) + "'"
   Endif   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOGS", .T., .T. )

   If T_LOGS->( EOF() )

      If kTipo == 0
         aAdd( aBrowse, { "", "", "", "", "", "", "" } )      
         Return(.T.)
      Else   
         MsgAlert("Não existem dados a serem vidualizados para este filtro.")
      Endif   

      aAdd( aBrowse, { "", "", "", "", "", "", "" } )

      oBrowse:SetArray(aBrowse) 

      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                            aBrowse[oBrowse:nAt,02],;
                            aBrowse[oBrowse:nAt,03],;
                            aBrowse[oBrowse:nAt,04],;
                            aBrowse[oBrowse:nAt,05],;
                            aBrowse[oBrowse:nAt,06],;
                            aBrowse[oBrowse:nAt,07]} }
      Return(.T.)
   Endif

   T_LOGS->( DbGoTop() )
   
   WHILE !T_LOGS->( EOF() )
   
      DO CASE
         CASE T_LOGS->ZS1_TIPO == "C"
              cCadastro := "CHAMADO TÉCNICO"
         CASE T_LOGS->ZS1_TIPO == "O"
              cCadastro := "ORÇAMENTO"
         CASE T_LOGS->ZS1_TIPO == "S"
              cCadastro := "ORDEM DE SERVIÇO"
      ENDCASE
                    
      DO CASE
         CASE T_LOGS->ZS1_OPER == "I"
              cOperacao := "INCLUSÃO"
         CASE T_LOGS->ZS1_OPER == "A"
              cOperacao := "ALTERAÇÃO"
      ENDCASE

      aAdd( aBrowse, { T_LOGS->ZS1_FILIAL, ;
                       T_LOGS->ZS1_NUMOS , ;
                       T_LOGS->ZS1_TECN  , ;
                       Substr(T_LOGS->ZS1_DATA,07,02) + "/" + Substr(T_LOGS->ZS1_DATA,05,02) + "/" + Substr(T_LOGS->ZS1_DATA,01,04) , ;
                       T_LOGS->ZS1_HORA  , ;
                       cCadastro         , ;
                       cOperacao } )
      
      T_LOGS->( DbSkip() )
      
   ENDDO                          
                       
   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "" } )
   Endif

   If kTipo == 0
      Return(.T.)
   Endif

   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07]} }
   
Return(.T.)

// ######################################################################
// Função que imprime o relatório de Log de Chamados, Orçamentos e OSs ##
// ######################################################################
Static Function RelatoLog()

   Local cSql          := ""

   Private cDesc1      := "Este programa tem como objetivo imprimir relatorio "
   Private cDesc2      := "de acordo com os parametros informados pelo usuario."
   Private cDesc3      := ""
   Private cPict       := ""
   Private titulo      := ""
   Private nLin        := 80
   Private nPagina     := 0
   
   Private Cabec1      := ""
   Private Cabec2      := ""
   Private imprime     := .T.
   Private aOrd        := {}

   Private lEnd        := .F.
   Private lAbortPrint := .F.
   Private CbTxt       := ""
   Private limite      := 80
   Private tamanho     := "P"
   Private nomeprog    := "AUTOM188"
   Private nTipo       := 18
   Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey    := 0
   Private cbtxt       := Space(10)
   Private cbcont      := 00
   Private CONTFL      := 01
   Private m_pag       := 01
   Private wnrel       := ""

   Private aMecanico     := {}
   Private cMecanico

   Private cInicial	   := Ctod("  /  /    ")
   Private cFinal 	   := Ctod("  /  /    ")

   Private oGet1
   Private oGet2

   Private oDlgRel

   Private cString     := "SA3"

   // Carrega o Combo dos Técnicos
   If Select("T_TECNICOS") > 0
      T_TECNICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODUSR,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND AA1_CODUSR <> ''"
   cSql += " ORDER BY AA1_NOMTEC   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICOS", .T., .T. )

   aAdd( aMecanico, "Todos os Técnicos" )

   WHILE !T_TECNICOS->( EOF() )
      aAdd( aMecanico, T_TECNICOS->AA1_CODUSR + " - " + Alltrim(T_TECNICOS->AA1_NOMTEC) )
      T_TECNICOS->( DbSkip() )
   ENDDO

   dbSelectArea("SA3")
   dbSetOrder(1)

   DEFINE MSDIALOG oDlgRel TITLE "Relação Log Chamado, Orçamento e OS" FROM C(178),C(181) TO C(316),C(473) PIXEL

   @ C(005),C(005) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgRel
   @ C(005),C(048) Say "Data Final"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgRel
   @ C(027),C(005) Say "Técnicos"     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgRel

   @ C(014),C(005) MsGet oGet1 Var cInicial Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRel
   @ C(014),C(048) MsGet oGet2 Var cFinal   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRel

   @ C(035),C(005) ComboBox cMecanico Items aMecanico Size C(132),C(010) PIXEL OF oDlgRel

   @ C(050),C(033) Button "O K"    Size C(037),C(012) PIXEL OF oDlgRel ACTION( RodaRelLog() )
   @ C(050),C(071) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgRel ACTION( oDlgRel:End() )

   ACTIVATE MSDIALOG oDlgRel CENTERED 

Return(.T.)

// Função que Abre o relatório
Static Function RodaRelLog()

   If Empty(cInicial)
      MsgAlert("Data inicial de inclusão não informada.")
      Return .T.
   Endif
      
   If Empty(cFinal)
      MsgAlert("Data final de inclusão não informada.")
      Return .T.
   Endif

   // Monta a interface padrao com o usuário
   wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

// Executa o Relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local cSql      := ""
   Local nOrdem
   Local __Usuario := ""
   Local __Status  := ""

   dbSelectArea(cString)
   dbSetOrder(1)

   // SETREGUA -> Indica quantos registros serao processados para a regua
   SetRegua(RecCount())

   If Select("T_LOGS") > 0
      T_LOGS->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZS1_FILIAL,"
   cSql += "       ZS1_TECN  ,"
   cSql += "       ZS1_DATA  ,"
   cSql += "       ZS1_HORA  ,"
   cSql += "       ZS1_OPER  ,"
   cSql += "       ZS1_TIPO  ,"
   cSql += "       ZS1_ETIQ  ,"
   cSql += "       ZS1_NUMOS ,"
   cSql += "       ZS1_USERID "
   cSql += "  FROM " + RetSqlName("ZS1")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND ZS1_DATA   >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)"
   cSql += "   AND ZS1_DATA   <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)"

   If Upper(Substr(cMecanico,01,05)) == "TODOS"
   Else
      cSql += "  AND ZS1_USERID = '" + Alltrim(Substr(cMecanico,01,06)) + "'"
   Endif

   cSql += " ORDER BY ZS1_DATA, ZS1_TECN"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LOGS", .T., .T. )

   T_LOGS->( DbGoTop() )

   __Data    := T_LOGS->ZS1_DATA
   __Tecnico := T_LOGS->ZS1_USERID
   __NomeTec := T_LOGS->ZS1_TECN

   While !T_LOGS->( EOF() )

      If ALLTRIM(UPPER(T_LOGS->ZS1_DATA)) == ALLTRIM(UPPER(__Data))
      
         If ALLTRIM(UPPER(T_LOGS->ZS1_USERID)) == ALLTRIM(UPPER(__Tecnico))

            If nLin > 55
               nPagina := nPagina + 1
               nLin    := 1
               @ nLin,001 PSAY "AUTOMATECH"
               @ nLin,024 PSAY "LOG POR TÉCNICO"
               @ nLin,061 PSAY dtoc(DATE()) + " - " + TIME()
               nLin := nLin + 1
               @ nLin,001 PSAY "AUTOM188.PRW"
               @ nLin,024 PSAY "PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal)
               @ nLin,061 PSAY "PÁGINA:"
               @ nLin,075 PSAY Strzero(nPagina,6)
               nLin = nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------"
               nLin := nLin + 1
               @ nLin,001 PSAY "FL  Nº NUM OS   Nº ETIQ.    HORA      CADASTRO              OPERAÇÃO"
               nLin := nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------"
               nLin := nLin + 2
               @ nLin,017 PSAY "DATA...: " + Substr(__Data,07,02) + "/" + Substr(__Data,05,02) + "/" + Substr(__Data,01,04)
               nLin = nLin + 1
               @ nLin,017 PSAY "TÉCNICO: " + Upper(__Tecnico) + " - " + Alltrim(Upper(__NomeTec))
               nLin = nLin + 2
            Endif   

            DO CASE
               CASE T_LOGS->ZS1_TIPO == "C"
                    cCadastro := "CHAMADO TÉCNICO"
               CASE T_LOGS->ZS1_TIPO == "O"
                    cCadastro := "ORÇAMENTO"
               CASE T_LOGS->ZS1_TIPO == "S"
                    cCadastro := "ORDEM DE SERVIÇO"
            ENDCASE
                    
            DO CASE
               CASE T_LOGS->ZS1_OPER == "I"
                    cOperacao := "INCLUSÃO"
               CASE T_LOGS->ZS1_OPER == "A"
                    cOperacao := "ALTERAÇÃO"
            ENDCASE

            @ nlin,001 psay T_LOGS->ZS1_FILIAL
            @ nlin,005 psay T_LOGS->ZS1_NUMOS
            @ nlin,017 psay T_LOGS->ZS1_ETIQ
            @ nlin,029 psay T_LOGS->ZS1_HORA
            @ nlin,039 psay cCadastro
            @ nlin,061 psay cOperacao
            
            nLin += 1

            T_LOGS->( DbSkip() )
            Loop
            
         Else
  
            __Tecnico := T_LOGS->ZS1_USERID
            __NomeTec := T_LOGS->ZS1_TECN
            
            nLin += 2
            @ nLin,017 PSAY "TÉCNICO: " + Upper(__Tecnico) + " - " + Alltrim(Upper(__NomeTec))
            nLin = nLin + 2

            Loop
            
         Endif
         
      Else
            
         __Data := T_LOGS->ZS1_DATA
            
         nLin += 2
         @ nLin,017 PSAY "DATA...: " + Substr(__Data,07,02) + "/" + Substr(__Data,05,02) + "/" + Substr(__Data,01,04)
         nLin = nLin + 2

         Loop
         
      Endif   
      
   ENDDO   

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao
   If aReturn[5]==1
      dbCommitAll()
      SET PRINTER TO
      OurSpool(wnrel)
   Endif

   MS_FLUSH()

   oDlg:End()

Return

/*
         1         2         3         4         5         6         7         8
12345678901234567890123456789012345678901234567890123456789012345678901234567890
AUTOMATECH             LOG POR TÉCNICO                       XX/XX/XXXX-XX:XX:XX
AUTOM188               PERÍODO: XX/XX/XXXX A XX/XX/XXXX      PAGINA:       XXXXX                  
--------------------------------------------------------------------------------
FL  Nº NUM OS   Nº ETIQ.    HORA      CADASTRO              OPERAÇÃO
--------------------------------------------------------------------------------

                DATA...: XX/XX/XXXX
                USUÁRIO: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

XX  XXXXXXXXXX  XXXXXXXXXX  XX:XX:XX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXX  XXXXXXXXXX  XX:XX:XX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXX  XXXXXXXXXX  XX:XX:XX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXX  XXXXXXXXXX  XX:XX:XX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXX  XXXXXXXXXX  XX:XX:XX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX
XX  XXXXXXXXXX  XXXXXXXXXX  XX:XX:XX  XXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX

*/