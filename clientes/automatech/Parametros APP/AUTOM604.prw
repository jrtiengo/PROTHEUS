#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM604.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 25/11/2016                                                               ##
// Objetivo..: Controle de Distirbuição de OS por Técnico                               ##
// #######################################################################################
User Function AUTOM604()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local oMemo1
   
   Private aFiliais	    := {}
   Private aTecnico     := {}
   Private cOcorrencias := Space(100)
   Private cPosicao     := Space(100)   

   Private cComboBx1
   Private cComboBx2

   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4   

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aLista := {}
   Private oLista

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

   // #########################################################
   // Carrega as datas Iniciais e Finais com o período atual ##
   // #########################################################
   cDtaInicial := Ctod("01/" + Strzero(Month(Date()),2) + "/" + Strzero(Year(Date()),4))
   cDtaFinal   := LastDay(Date())

   // #################################   
   // Carrega o combobox das filiais ##
   // #################################
   aFiliais := U_AUTOM539(2, cEmpAnt)

//   Do Case
//      Case cEmpAnt == "01"
//           aFiliais := {"00 - Selecione", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
//      Case cEmpAnt == "02"
//           aFiliais := {"00 - Selecione", "01 - Curitiba"}
//      Case cEmpAnt == "03"
//           aFiliais := {"00 - Selecione", "01 - Porto Alegre"}
//   EndCase
              
   // ##################################
   // Carrega o combobox dos Técnicos ##
   // ##################################
   If Select("T_TECNICOS") > 0
      T_TECNICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND AA1_CODUSR <> ''"
   cSql += " ORDER BY AA1_NOMTEC   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICOS", .T., .T. )

   aAdd( aTecnico, "000000 - Todos o Técnico" )
   
   T_TECNICOS->( DbGoTop() )
   
   WHILE !T_TECNICOS->( EOF() )
      aAdd( aTecnico, T_TECNICOS->AA1_CODTEC + " - " + Alltrim(T_TECNICOS->AA1_NOMTEC) )
      T_TECNICOS->( DbSkip() )
   ENDDO

   // ############################################################################
   // Pesquisa campos para preenchimento das ocorrências e posições de pesquisa ##
   // ############################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTR_PESQ,"
   cSql += "       ZTR_OCOR,"
   cSql += "       ZTR_POSI "
   cSql += "  FROM " + RetSqlName("ZTR")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
   Else
      If Empty(Alltrim(T_PARAMETROS->ZTR_OCOR))
      Else
         cOcorrencias := T_PARAMETROS->ZTR_OCOR
      Endif
         
      If Empty(Alltrim(T_PARAMETROS->ZTR_POSI))
      Else
         cPosicao := T_PARAMETROS->ZTR_POSI
      Endif
   Endif

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlg TITLE "Distribuição de OSs para Técnicos - App Automatech AT" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg
   @ C(212),C(126) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(180) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(035),C(307) Say "Tecnicos"        Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(005) Say "Filial"          Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(065) Say "Dta Inicial"     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(107) Say "Dta Final"       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(150) Say "Ocorrências"     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(224) Say "Posição"         Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Relação de OSs"  Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(140) Say "OS A Distribuir" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(194) Say "OS Distribuidas" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) ComboBox cComboBx1 Items aFiliais     Size C(055),C(010)                              PIXEL OF oDlg
   @ C(045),C(065) MsGet    oGet1     Var   cDtaInicial  Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(045),C(107) MsGet    oGet2     Var   cDtaFinal    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(150) MsGet    oGet3     Var   cOcorrencias Size C(054),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(205) Button   "..."                        Size C(013),C(009)                              PIXEL OF oDlg ACTION( AbrOcorrencias() )
   @ C(046),C(224) MsGet    oGet4     Var   cPosicao     Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(046),C(286) Button   "..."                        Size C(013),C(009)                              PIXEL OF oDlg ACTION( AbrPosicao() )
   @ C(045),C(305) ComboBox cComboBx2 Items aTecnico     Size C(142),C(010)                              PIXEL OF oDlg

   @ C(043),C(448) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PsqOrdemServico() )

   @ C(210),C(005) Button "Marca Todos"    Size C(056),C(012) PIXEL OF oDlg ACTION( MDistribui(1) )
   @ C(210),C(064) Button "Desmarca Todos" Size C(056),C(012) PIXEL OF oDlg ACTION( MDistribui(2) )
   @ C(210),C(422) Button "Confirma"       Size C(037),C(012) PIXEL OF oDlg ACTION( MarcaOsApp() )
   @ C(210),C(461) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "" } )

   // Lista com os produtos do pedido selecionado
   @ 080,005 LISTBOX oList FIELDS HEADER "Mrc", "Leg", "Filial", "Nº OSs", "Dta Emissão", "Posição", "Técnico", "Descrição dos Técnicos", "Cliente", "Loja", "Descrição dos Clientes", "Bairro", "Cidade", "Estado" PIXEL SIZE 633,185 OF oDlg ;
             ON LEFT DBLCLICK ( TrocaCor()), ON RIGHT CLICK (TrocaCor())

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
                            If(aLista[oList:nAt,02] == "0", oBranco   ,;
                            If(aLista[oList:nAt,02] == "2", oVerde    ,;
                            If(aLista[oList:nAt,02] == "3", oCancel   ,;                         
                            If(aLista[oList:nAt,02] == "1", oAmarelo  ,;                         
                            If(aLista[oList:nAt,02] == "5", oAzul     ,;                         
                            If(aLista[oList:nAt,02] == "6", oLaranja  ,;                         
                            If(aLista[oList:nAt,02] == "7", oPreto    ,;                         
                            If(aLista[oList:nAt,02] == "8", oVermelho ,;
                            If(aLista[oList:nAt,02] == "9", oPink     ,;
                            If(aLista[oList:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;
          					   aLista[oList:nAt,07],;          					             					   
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13],;
         	        	       aLista[oList:nAt,14]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################
// Função que abre a janela de selecção das ocorrências ##
// #######################################################
Static Function AbrOcorrencias()

   Local cSql    := ""

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgOco

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aOcorrencias := {}
   Private oOcorrencias

   If Select("T_OCORRENCIAS") > 0
      T_OCORRENCIAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AAG_CODPRB,"
   cSql += "       AAG_DESCRI "
   cSql += "  FROM " + RetSqlName("AAG")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY AAG_DESCRI"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCORRENCIAS", .T., .T. )

   T_OCORRENCIAS->( DbGoTop() )
   
   aOcorrencias := {}

   WHILE !T_OCORRENCIAS->( EOF() )
      aAdd( aOcorrencias, { .F., T_OCORRENCIAS->AAG_CODPRB, T_OCORRENCIAS->AAG_DESCRI } )
      T_OCORRENCIAS->( DbSkip() )
   ENDDO   

   If Len(aOcorrencias) == 0
      aAdd( aOcorrencias, { .F., "", "" } )
   Endif

   DEFINE MSDIALOG oDlgOco TITLE "Ocorrências" FROM C(178),C(181) TO C(517),C(566) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgOco

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlgOco

   @ C(038),C(005) Say "Ocorrências" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgOco

   @ C(152),C(113) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgOco ACTION( FechaOcorrencias() )
   @ C(152),C(151) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgOco ACTION( cOcorrencias := "", oDlgOco:End() )

   @ 060,005 LISTBOX oOcorrencias FIELDS HEADER "", "Código", "Descrição das Ocorrências" PIXEL SIZE 233,130 OF oDlgOco ;
             ON dblClick(aOcorrencias[oOcorrencias:nAt,1] := !aOcorrencias[oOcorrencias:nAt,1],oOcorrencias:Refresh())     

   oOcorrencias:SetArray( aOcorrencias )

   oOcorrencias:bLine := {|| {Iif(aOcorrencias[oOcorrencias:nAt,01],oOk,oNo),;
         					      aOcorrencias[oOcorrencias:nAt,02],;
          					      aOcorrencias[oOcorrencias:nAt,03]}}

   ACTIVATE MSDIALOG oDlgOco CENTERED 

Return(.T.)

// ###########################################################
// Função que prepara a variável de ocorrências ára retorno ##
// ###########################################################
Static Function FechaOcorrencias()
                                
   Local nContar := 0
   Local cString := ""    
   
   For nContar := 1 to Len(aOcorrencias)
       If aOcorrencias[nContar,01] == .T.
          If Empty(Alltrim(cString))
          Else
             cString := cString + ","
          Endif 
          cString := cString + "'" + aOcorrencias[nContar,02] + "'"
       Endif
   Next nContar
   
   cOcorrencia := cString
   oGet3:Refresh()
   
   oDlgOco:End()    
   
Return(.T.)   

// ####################################################
// Função que abre a janela de selecção das posições ##
// ####################################################
Static Function AbrPosicao()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgPos

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private aPosicao := {}
   Private oPosicao

   DEFINE MSDIALOG oDlgPos TITLE "Posições" FROM C(178),C(181) TO C(517),C(566) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgPos

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlgPos

   @ C(038),C(005) Say "Posições" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgPos

   @ C(152),C(113) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgPos ACTION( FechaPosicao() )
   @ C(152),C(151) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgPos ACTION( oDlgPos:End() )

   aAdd( aPosicao, { .F., "F", "Fabricante Aguardando Orçamento" } )
   aAdd( aPosicao, { .F., "P", "Aguardando Peças" } )
   aAdd( aPosicao, { .F., "A", "Aguardando Aprovação" } )
   aAdd( aPosicao, { .F., "B", "Em Bancada" } )
   aAdd( aPosicao, { .F., "D", "Aguardando RMA" } )
   aAdd( aPosicao, { .F., "E", "Encerrada" } )
   aAdd( aPosicao, { .F., "M", "Aprovada" } )
   aAdd( aPosicao, { .F., "N", "Reprovada" } )
   aAdd( aPosicao, { .F., "C", "Aguardando NF" } )
   aAdd( aPosicao, { .F., "G", "Fabricante Aguardando Aprovação" } )
   aAdd( aPosicao, { .F., "H", "Aguardando Retorno Fabricante" } )
   aAdd( aPosicao, { .F., "I", "Entrada" } )
   aAdd( aPosicao, { .F., "S", "Atestado" } )

   @ 060,005 LISTBOX oPosicao FIELDS HEADER "", "Código", "Descrição das Posições" PIXEL SIZE 233,130 OF oDlgPos ;
             ON dblClick(aPosicao[oPosicao:nAt,1] := !aPosicao[oPosicao:nAt,1],oPosicao:Refresh())     

   oPosicao:SetArray( aPosicao )

   oPosicao:bLine := {|| {Iif(aPosicao[oPosicao:nAt,01],oOk,oNo),;
         					  aPosicao[oPosicao:nAt,02],;
        					  aPosicao[oPosicao:nAt,03]}}

   ACTIVATE MSDIALOG oDlgPos CENTERED 

Return(.T.)

// #########################################################
// Função que prepara a variável de posições para retorno ##
// #########################################################
Static Function FechaPosicao()
                                
   Local nContar := 0
   Local cString := ""    
   
   For nContar := 1 to Len(aPosicao)
       If aPosicao[nContar,01] == .T.
          If Empty(Alltrim(cString))
          Else
             cString := cString + ","
          Endif 
          cString := cString + "'" + aPosicao[nContar,02] + "'"
       Endif
   Next nContar
   
   cPosicao := cString
   oGet4:Refresh()
   
   oDlgPos:End()    
   
Return(.T.)   

// ################################################
// Função que pesquisa conforme filtro informado ##
// ################################################
Static Function PsqOrdemServico()

   MsgRun("Favor Aguarde! Pesquisando Ordens de Serviços ...", "Pesquisa de Ordens de Serviços",{|| xPsqOrdemServico() })

Return(.T.)

// ################################################
// Função que pesquisa conforme filtro informado ##
// ################################################
Static Function xPsqOrdemServico()

   Local cSql := ""

   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Filial não selecionada.")
      Return(.T.)
   Endif

   If cDtaInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial para pesquisa não informada.")
      Return(.T.)
   Endif
      
   If cDtaFinal == Ctod("  /  /    ")
      MsgAlert("Data final para pesquisa não informada.")
      Return(.T.)
   Endif

   aLista := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := "SELECT AB6.AB6_FILIAL,"
   cSql += "       AB6.AB6_NUMOS ,"
   cSql += "       AB6.AB6_ZAPP  ,"
   cSql += "       SUBSTRING(AB6.AB6_EMISSA,07,02) + '/' + SUBSTRING(AB6.AB6_EMISSA,05,02) + '/' + SUBSTRING(AB6.AB6_EMISSA,01,04) AS EMISSAO,"
   cSql += "       CASE                       "
   cSql += "         WHEN AB6.AB6_POSI = 'F' THEN 'Fabricante Aguardando Orcamento'"
   cSql += "         WHEN AB6.AB6_POSI = 'P' THEN 'Aguardando Pecas'               "
   cSql += "         WHEN AB6.AB6_POSI = 'A' THEN 'Aguardando Aprovacao'           "
   cSql += "         WHEN AB6.AB6_POSI = 'B' THEN 'Em Bancada'                     "
   cSql += "         WHEN AB6.AB6_POSI = 'D' THEN 'Aguardando RMA'                 "
   cSql += "         WHEN AB6.AB6_POSI = 'E' THEN 'Encerrado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'M' THEN 'Aprovacao'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'N' THEN 'Reprovado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'C' THEN 'Aguardando NF'                  "
   cSql += "         WHEN AB6.AB6_POSI = 'G' THEN 'Fabricante Aguardando Aprovacao'"
   cSql += "         WHEN AB6.AB6_POSI = 'H' THEN 'Aguardando Retirada Fabricante' "
   cSql += "         WHEN AB6.AB6_POSI = 'I' THEN 'Entrada'                        "
   cSql += "         WHEN AB6.AB6_POSI = 'S' THEN 'Atestado'                       "
   cSql += "       END  AS POSICAO,"
   cSql += "       AB6.AB6_RLAUDO ,"
   cSql += "       AA1.AA1_NOMTEC ,"
   cSql += "	   AB6.AB6_CODCLI ,"
   cSql += "	   AB6.AB6_LOJA   ,"
   cSql += "	   SA1.A1_NOME    ,"
   cSql += "	   SA1.A1_BAIRRO  ,"
   cSql += "	   SA1.A1_MUN     ,"
   cSql += "	   SA1.A1_EST      "
   cSql += "  FROM " + RetSqlName("AB6") + " AB6, "
   cSql += "       " + RetSqlName("AB7") + " AB7, "
   cSql += "       " + RetSqlName("SA1") + " SA1, "
   cSql += "	   " + RetSqlName("AA1") + " AA1  "
   cSql += "  WHERE AB6.AB6_FILIAL = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "    AND AB6.D_E_L_E_T_ = ''"
   cSql += "    AND SA1.A1_COD     = AB6.AB6_CODCLI"
   cSql += "    AND SA1.A1_LOJA    = AB6.AB6_LOJA  "
   cSql += "    AND SA1.D_E_L_E_T_ = ''            "
   cSql += "    AND AA1.AA1_CODTEC = AB6.AB6_RLAUDO"
   cSql += "    AND AA1.D_E_L_E_T_ = ''            "
   cSql += "    AND AB6.AB6_STATUS = 'A'           "
   cSql += "    AND AB7.AB7_FILIAL = AB6.AB6_FILIAL"
   cSql += "    AND AB7.AB7_NUMOS  = AB6.AB6_NUMOS "
   cSql += "    AND AB7.D_E_L_E_T_ = ''            "

   If Empty(Alltrim(cOcorrencias))
   Else
      cSql += " AND AB7.AB7_CODPRB IN (" + Alltrim(cOcorrencias) + ")"
   Endif   

   If Substr(cComboBx2,01,06) == "000000"
   Else   
      cSql += "    AND AB6.AB6_RLAUDO = '" + Substr(cComboBx2,01,06) + "'"
   Endif
   
   If Empty(Alltrim(cPosicao))
   Else
      cSql += " AND AB6.AB6_POSI IN (" + Alltrim(cPosicao) + ")"
   Endif   

   cSql += " ORDER BY AB6.AB6_RLAUDO, AB6.AB6_EMISSA, AB6.AB6_NUMOS"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )

   kTecnico := T_CONSULTA->AB6_RLAUDO

   WHILE !T_CONSULTA->( EOF() )
         
      If T_CONSULTA->AB6_RLAUDO == kTecnico

         cLegenda  := IIF(Alltrim(T_CONSULTA->AB6_ZAPP) == "X", "2", "8")
         cMarcacao := IIF(Alltrim(T_CONSULTA->AB6_ZAPP) == "X", .T., .F.)

         aAdd( aLista, { cMarcacao              ,;
                         cLegenda               ,;
                         T_CONSULTA->AB6_FILIAL ,;
                         T_CONSULTA->AB6_NUMOS  ,;
                         T_CONSULTA->EMISSAO    ,;
                         T_CONSULTA->POSICAO    ,;
                         T_CONSULTA->AB6_RLAUDO ,;
                         T_CONSULTA->AA1_NOMTEC ,;
                         T_CONSULTA->AB6_CODCLI ,;
                         T_CONSULTA->AB6_LOJA   ,;
                         T_CONSULTA->A1_NOME    ,;
                         T_CONSULTA->A1_BAIRRO  ,;
                         T_CONSULTA->A1_MUN     ,;
                         T_CONSULTA->A1_EST     })
      Else

         aAdd( aLista, { .F.,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" ,;
                         "" })

         kTecnico := T_CONSULTA->AB6_RLAUDO

         Loop

      Endif
                      
      T_CONSULTA->( DbSkip() )
      
   Enddo
                            
   If Len(aLista) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "", "", "", "", "" } )      
   Endif
      
   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
                            If(aLista[oList:nAt,02] == "0", oBranco   ,;
                            If(aLista[oList:nAt,02] == "2", oVerde    ,;
                            If(aLista[oList:nAt,02] == "3", oCancel   ,;                         
                            If(aLista[oList:nAt,02] == "1", oAmarelo  ,;                         
                            If(aLista[oList:nAt,02] == "5", oAzul     ,;                         
                            If(aLista[oList:nAt,02] == "6", oLaranja  ,;                         
                            If(aLista[oList:nAt,02] == "7", oPreto    ,;                         
                            If(aLista[oList:nAt,02] == "8", oVermelho ,;
                            If(aLista[oList:nAt,02] == "9", oPink     ,;
                            If(aLista[oList:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;
          					   aLista[oList:nAt,07],;          					             					   
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13],;
         	        	       aLista[oList:nAt,14]}}
         	        	       
   oList:Refresh()
   
Return(.T.)            	        	       

// #####################################################################
// Função que marca e desmarca as ordens de serviço para distribuição ##
// #####################################################################
Static Function MDistribui(_Botao)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)

       If Empty(Alltrim(aLista[nContar,03]))
          Loop
       Endif

       If aLista[nContar,01] == .F.
          aLista[nContar,01] := .T.
          aLista[nContar,02] := "2"
       Else
          aLista[nContar,01] := .F.
          aLista[nContar,02] := "8"
       Endif
   Next nContar       

   oList:Refresh()
   
Return(.T.)                

// ######################################################
// Função que troca de cor a legenda conforme marcação ##
// ######################################################
Static Function TrocaCor()

   If Empty(Alltrim(aLista[oList:nAt,03]))
      aLista[oList:nAt,01] := .F.
      aLista[oList:nAt,02] := ""
      Return(.T.)
   Endif

   If aLista[oList:nAt,01] == .F.
      aLista[oList:nAt,01] := .T.
      aLista[oList:nAt,02] := "2"
   Else
      aLista[oList:nAt,01] := .F.
      aLista[oList:nAt,02] := "8"
   Endif

   oList:Refresh()
   
Return(.T.)                

// ##################################################
// Função marca as os do técnico(s) selecionado(s) ##
// ##################################################
Static Function MarcaOsApp()

   Local nContar := 0

   For nContar = 1 to Len(aLista)

       DbSelectArea("AB6")
       DbSetOrder(1)
       If DbSeek(aLista[nContar,03] + aLista[nContar,04])
          RecLock("AB6",.F.)
          AB6_ZAPP := IIF(aLista[nContar,01] == .F., " ", "X")
          MsUnLock()
      Endif
      
   Next nContar
   
   aLista := {}
   aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "", "", "", "" } )

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
                            If(aLista[oList:nAt,02] == "0", oBranco   ,;
                            If(aLista[oList:nAt,02] == "2", oVerde    ,;
                            If(aLista[oList:nAt,02] == "3", oCancel   ,;                         
                            If(aLista[oList:nAt,02] == "1", oAmarelo  ,;                         
                            If(aLista[oList:nAt,02] == "5", oAzul     ,;                         
                            If(aLista[oList:nAt,02] == "6", oLaranja  ,;                         
                            If(aLista[oList:nAt,02] == "7", oPreto    ,;                         
                            If(aLista[oList:nAt,02] == "8", oVermelho ,;
                            If(aLista[oList:nAt,02] == "9", oPink     ,;
                            If(aLista[oList:nAt,02] == "4", oEncerra, "")))))))))),;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;
          					   aLista[oList:nAt,07],;          					             					   
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;
         	        	       aLista[oList:nAt,12],;
         	        	       aLista[oList:nAt,13],;
         	        	       aLista[oList:nAt,14]}}
      
   oList:Refresh()

//   cComboBx1    := "00 - Selecione"
//   cComboBx2    := "000000 - Todos o Técnico"
//   cDtaInicial  := Ctod("  /  /    ")
//   cDtaFinal    := Ctod("  /  /    ")
//   cOcorrencias := ""
//   cPosicao     := ""

Return(.T.)