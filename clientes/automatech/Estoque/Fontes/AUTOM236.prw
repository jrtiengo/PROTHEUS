#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM236.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/05/2013                                                          *
// Objetivo..: Conciliação de Conhecimento de Transporte Eletrônico.               *
//**********************************************************************************

User Function AUTOM236()

   Local lChumba     := .F.
   Local cMemo1      := ""
   Local oMemo1 

   Private lAbre     := .T.
   Private cCodigo 	 := Space(06)
   Private cNome	 := Space(60)
   Private cInicial  := Ctod("  /  /    ")
   Private cFinal 	 := Ctod("  /  /    ")
   Private cFatura   := Space(10)
   Private cValor 	 := 0
   Private cFornece  := Space(06)
   Private cLojaFor  := Space(03)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6

   Private aConciliado := {}

   Private oDlg

   U_AUTOM628("AUTOM236")
   
   DEFINE MSDIALOG oDlg TITLE "Conciliação CT-e" FROM C(178),C(181) TO C(579),C(724) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(026) PIXEL NOBORDER OF oDlg

   @ C(031),C(005) GET oMemo1 Var cMemo1 MEMO Size C(260),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Transportadora"      Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Venctº Inicial"      Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(055) Say "Venctº Final"        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(106) Say "Nº Documento/Fatura" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(166) Say "Valor Cobrado"       Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(079),C(005) Say "Conciliações"        Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(045),C(005) MsGet oGet1 Var cCodigo  Size C(025),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg F3("SA4") VALID( psqnmtra(1) )
   @ C(045),C(033) MsGet oGet2 Var cNome    Size C(190),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg When lChumba
   @ C(066),C(005) MsGet oGet3 Var cInicial Size C(044),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg
   @ C(066),C(055) MsGet oGet4 Var cFinal   Size C(044),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg
   @ C(066),C(106) MsGet oGet5 Var cFatura  Size C(053),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg
   @ C(066),C(166) MsGet oGet6 Var cValor   Size C(058),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg

   @ C(050),C(228) Button "Pesquisar"  Size C(037),C(012) PIXEL OF oDlg ACTION( psqconcilia() ) When lAbre
   @ C(063),C(228) Button "Nova Pesq." Size C(037),C(012) PIXEL OF oDlg ACTION( LmpTelaConc() ) When !lAbre

   @ C(184),C(005) Button "Incluir"   Size C(037),C(012) PIXEL OF oDlg ACTION( AbreConciliacao("I") )
   @ C(184),C(046) Button "Consultar" Size C(037),C(012) PIXEL OF oDlg ACTION( AbreConciliacao("C") )
   @ C(184),C(087) Button "Excluir"   Size C(037),C(012) PIXEL OF oDlg ACTION( AbreConciliacao("E") )
   @ C(184),C(228) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aConciliado, { "", "", "", "", "", "", "" } )

   oConciliado := TCBrowse():New( 112 , 005, 335, 120,,{'Código', 'Descrição Transportadoras', 'Nº Doc/Fatura', 'Data', 'Vencimento', 'Valor', "Natureza"},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oConciliado:SetArray(aConciliado) 
    
   // Monta a linha a ser exibina no Browse
   oConciliado:bLine := {||{aConciliado[oConciliado:nAt,01],;
                            aConciliado[oConciliado:nAt,02],;
                            aConciliado[oConciliado:nAt,03],;
                            aConciliado[oConciliado:nAt,04],;
                            aConciliado[oConciliado:nAt,05],;
                            aConciliado[oConciliado:nAt,06],;
                            aConciliado[oConciliado:nAt,07]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que pesquisa a transportadra se informada
Static Function psqnmtra(__Tipo)

   Local cSql := ""
   
   // Pesquisa o CNPJ da Transportadora
   If Select("T_CGC") > 0
      T_CGC->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A4_CGC"
   cSql += "  FROM " + RetSqlName("SA4")

   If __Tipo == 1
      cSql += " WHERE A4_COD     = '" + Alltrim(cCodigo) + "'"
   Else
      cSql += " WHERE A4_COD     = '" + Alltrim(xCodigo) + "'"
   Endif
            
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CGC", .T., .T. )

   // Verifica se transportadora está cadastrada como fornecedor
   If Select("T_FRETE") > 0
      T_FRETE->( dbCloseArea() )
   EndIf

   cSql := ""                                                                
   cSql := "SELECT A2_COD ,"
   cSql += "       A2_LOJA "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_CGC     = '" + Alltrim(T_CGC->A4_CGC) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"                         
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FRETE", .T., .T. )

   If T_FRETE->( EOF() )
      MsgAlert("Transportadora não consta como fornecedor. Verifique Cadastro de fornecedores.")
      Return(.T.)
   Else
      cFornece := T_FRETE->A2_COD
      cLojaFor := T_FRETE->A2_LOJA
   Endif   

   If __Tipo == 1

      If Empty(Alltrim(cCodigo))
         Return(.T.)
      Endif
      
      cNome := Posicione( "SA4", 1, xFilial("SA4") + cCodigo, "A4_NOME" )   

      oGet1:Refresh()

   Else

      If Empty(Alltrim(xCodigo))
         Return(.T.)
      Endif
      
      xNome := Posicione( "SA4", 1, xFilial("SA4") + xCodigo, "A4_NOME" )   

      oGet1:Refresh()

   Endif      
   
Return(.T.)         

// Função que pesquisa as conciliações conforme filtro informado
Static Function psqconcilia()

   Local cSql  := ""

   aConciliado := {}

   // Pesquisa conforme filtro informado
   If Select("T_CONCILIAR") > 0
      T_CONCILIAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DISTINCT ZS9.ZS9_FATU,"
   cSql += "       ZS9.ZS9_CTRA,"
   cSql += "       SA4.A4_NOME ,"
   cSql += "       ZS9.ZS9_DDOC,"
   cSql += "       ZS9.ZS9_VENC,"
   cSql += "       ZS9.ZS9_VALO,"
   cSql += "       ZS9.ZS9_NATU "
   cSql += "  FROM " + RetSqlName("ZS9") + " ZS9, "
   cSql += "       " + RetSqlName("SA4") + " SA4  "
   cSql += " WHERE ZS9.D_E_L_E_T_ = ''"
   cSql += "   AND ZS9.ZS9_FATU  <> ''"
   
   If !Empty(Alltrim(cCodigo))
      cSql += " AND ZS9.ZS9_CTRA   = '" + Alltrim(cCodigo) + "'"
   Endif

   If !Empty(cInicial)
      cSql += " AND ZS9.ZS9_VENC >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103) AND ZS9.ZS9_VENC <= CONVERT(DATETIME,'" + Dtoc(cFinal) + "', 103)"
   Endif

   If !Empty(Alltrim(cFatura))
      cSql += " AND ZS9.ZS9_FATU = '" + Alltrim(cFatura) + "'"
   Endif
   
   If cValor <> 0   
      cSql += " AND ZS9.ZS9_VALO = '" + Alltrim(STR(cValor,10,02)) + "'"
   Endif

   cSql += "   AND ZS9.ZS9_CTRA   = SA4.A4_COD
   cSql += "   AND SA4.D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONCILIAR", .T., .T. )

   If T_CONCILIAR->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este filtro.")
      aAdd( aConciliado, { "", "", "", "", "", "", "" } )
   Else
      WHILE !T_CONCILIAR->( EOF() )
         aAdd( aConciliado, { T_CONCILIAR->ZS9_CTRA,;
                              T_CONCILIAR->A4_NOME ,;
                              T_CONCILIAR->ZS9_FATU,;
                              Substr(T_CONCILIAR->ZS9_DDOC,07,02) + "/" + Substr(T_CONCILIAR->ZS9_DDOC,05,02) + "/" + Substr(T_CONCILIAR->ZS9_DDOC,01,04) ,;
                              Substr(T_CONCILIAR->ZS9_VENC,07,02) + "/" + Substr(T_CONCILIAR->ZS9_VENC,05,02) + "/" + Substr(T_CONCILIAR->ZS9_VENC,01,04) ,;
                              T_CONCILIAR->ZS9_VALO,;
                              T_CONCILIAR->ZS9_NATU})
         T_CONCILIAR->( DbSkip() )
      ENDDO                              
   Endif   

   // Seta vetor para a browse                            
   oConciliado:SetArray(aConciliado) 
    
   // Monta a linha a ser exibina no Browse
   oConciliado:bLine := {||{aConciliado[oConciliado:nAt,01],;
                            aConciliado[oConciliado:nAt,02],;
                            aConciliado[oConciliado:nAt,03],;
                            aConciliado[oConciliado:nAt,04],;
                            aConciliado[oConciliado:nAt,05],;
                            aConciliado[oConciliado:nAt,06],;
                            aConciliado[oConciliado:nAt,07]}}

   lAbre := .F.

Return(.T.)

// Função que limpa a tela para nova pesquisa
Static Function LmpTelaConc()

   lAbre     := .T.
   cCodigo 	 := Space(06)
   cNome	 := Space(60)
   cInicial  := Ctod("  /  /    ")
   cFinal 	 := Ctod("  /  /    ")
   cFatura   := Space(10)
   cValor 	 := 0

   oGet1:Refresh()
   oGet2:Refresh()
   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()

   aConciliado := {}

   aAdd( aConciliado, { "", "", "", "", "", "", "" } )

   // Seta vetor para a browse                            
   oConciliado:SetArray(aConciliado) 
    
   // Monta a linha a ser exibina no Browse
   oConciliado:bLine := {||{aConciliado[oConciliado:nAt,01],;
                            aConciliado[oConciliado:nAt,02],;
                            aConciliado[oConciliado:nAt,03],;
                            aConciliado[oConciliado:nAt,04],;
                            aConciliado[oConciliado:nAt,05],;
                            aConciliado[oConciliado:nAt,06],;
                            aConciliado[oConciliado:nAt,07]}}

Return(.T.)

// Função que realiza inclusão de Conciliação
Static Function AbreConciliacao(kOperacao)

   Local lFecha      := .F.
   Local cSql        := ""
   Local nContar     := 0

   Private xCodigo   := Space(06)
   Private xNome     := Space(60)
   Private xData     := Ctod("  /  /    ")
   Private xFatura   := Space(10)
   Private xVencto   := Ctod("  /  /    ")
   Private xValor    := 0
   Private xSaldo    := 0
   Private xNatureza := Space(10)
   Private xNomeNatu := Space(60)

   Private aRateio   := {}
   Private lPrimeiro := .T.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9   

   Private oDlgX

   If kOperacao == "C" .Or. kOperacao == "E"
      xCodigo   := aConciliado[oConciliado:nAt,01]
      xNome     := aConciliado[oConciliado:nAt,02]
      xData     := aConciliado[oConciliado:nAt,04]
      xFatura   := aConciliado[oConciliado:nAt,03]
      xVencto   := aConciliado[oConciliado:nAt,05]
      xValor    := aConciliado[oConciliado:nAt,06]
      xNatureza := aConciliado[oConciliado:nAt,07]
      xSaldo    := 0

      If Empty(Alltrim(xCodigo))
         Return(.T.)
      Endif

      psqnatu()

      If Select("T_CENTRO") > 0
         T_CENTRO->( dbCloseArea() )
      EndIf

      cSql := "SELECT SEZ.EZ_PERC  ,"
      cSql += "       SEZ.EZ_VALOR ,"
      cSql += "       SEZ.EZ_CCUSTO,"
      cSql += "       CTT.CTT_DESC01"
      cSql += "  FROM " + RetSqlName("SEZ") + " SEZ, "
      cSql += "       " + RetSqlName("CTT") + " CTT  "
      cSql += " WHERE SEZ.EZ_PREFIXO = 'CTE'"
      cSql += "   AND SEZ.EZ_NUM     = '" + Alltrim(Substr(xFatura,01,09))  + "'"
      cSql += "   AND SEZ.EZ_TIPO    = 'FT'"
    //cSql += "   AND SEZ.EZ_CLIFOR  = '" + Alltrim(cFornece) + "'"
    //cSql += "   AND SEZ.EZ_LOJA    = '" + Alltrim(cLojaFor) + "'"
      cSql += "   AND SEZ.D_E_L_E_T_ = ''"
      cSql += "   AND SEZ.EZ_CCUSTO  = CTT.CTT_CUSTO"
      cSql += "   AND CTT.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CENTRO", .T., .T. )

      aRateio := {}

      If T_CENTRO->( EOF() )
         aAdd( aRateio, { "", "", "", "", "" } )      
      Else
         nContar := 1
         T_CENTRO->( DbGoTop() )
         WHILE !T_CENTRO->( EOF() )
            aAdd( aRateio, {T_CENTRO->EZ_PERC   ,;
                            T_CENTRO->EZ_VALOR  ,;
                            T_CENTRO->EZ_CCUSTO ,;
                            T_CENTRO->CTT_DESC01,;
                            Alltrim(Str(nContar))})
            nContar := nContar + 1
            T_CENTRO->( DbSkip() )
         ENDDO   
      Endif

   Endif

   // Desenha a tela de inclusão de de faturas
   DEFINE MSDIALOG oDlgX TITLE "Conciliação CT-e" FROM C(178),C(181) TO C(566),C(580) PIXEL

   @ C(001),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(025) PIXEL NOBORDER OF oDlgX

   @ C(026),C(005) Say "Transportadora"             Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(005) Say "Data Documento"             Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(052) Say "Nº Doc/Fatura"              Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(101) Say "Vencimento"                 Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(047),C(152) Say "Valor Cobrado"              Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(068),C(005) Say "Natureza"                   Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(089),C(005) Say "Rateio por Centro de Custo" Size C(066),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   @ C(163),C(114) Say "Saldo a Ratear"             Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
   
   If kOperacao == "I"
      @ C(035),C(005) MsGet oGet1 Var xCodigo   Size C(023),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX F3("SA4") VALID( psqnmtra(2) )
      @ C(035),C(032) MsGet oGet2 Var xNome     Size C(164),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(056),C(005) MsGet oGet3 Var xData     Size C(041),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX
      @ C(056),C(052) MsGet oGet4 Var xFatura   Size C(044),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX
      @ C(056),C(102) MsGet oGet5 Var xVencto   Size C(044),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX
      @ C(056),C(152) MsGet oGet6 Var xValor    Size C(044),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgX VALID( xSaldo := xValor )
      @ C(076),C(005) MsGet oGet8 Var xNatureza Size C(041),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX F3("SED") VALID( psqnatu() )
      @ C(076),C(052) MsGet oGet9 Var xNomeNatu Size C(144),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(163),C(152) MsGet oGet7 Var xSaldo    Size C(044),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgX When lFecha
   Else
      @ C(035),C(005) MsGet oGet1 Var xCodigo   Size C(023),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(035),C(032) MsGet oGet2 Var xNome     Size C(164),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(056),C(005) MsGet oGet3 Var xData     Size C(041),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(056),C(052) MsGet oGet4 Var xFatura   Size C(044),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(056),C(102) MsGet oGet5 Var xVencto   Size C(044),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(056),C(152) MsGet oGet6 Var xValor    Size C(044),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgX When lFecha
      @ C(076),C(005) MsGet oGet8 Var xNatureza Size C(041),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(076),C(052) MsGet oGet9 Var xNomeNatu Size C(144),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgX When lFecha
      @ C(163),C(152) MsGet oGet7 Var xSaldo    Size C(044),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgX When lFecha
   Endif     
 
   If kOperacao == "I"  
      @ C(176),C(005) Button "Inclui CC"  Size C(037),C(012) PIXEL OF oDlgX ACTION( VlrRateio( "I", 0, 0, Space(09), Space(40), "" ) )
      @ C(176),C(043) Button "Exclui CC"  Size C(037),C(012) PIXEL OF oDlgX ACTION( VlrRateio( "E", aRateio[oRateio:nAt,01], aRateio[oRateio:nAt,02], aRateio[oRateio:nAt,03], aRateio[oRateio:nAt,04], aRateio[oRateio:nAt,05] ) )
      @ C(176),C(082) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlgX When lFecha
      @ C(176),C(120) Button "Confirmar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( CTEConcilia(1) )
   Else
      // Consulta
      If kOperacao == "C"  
         @ C(176),C(005) Button "Inclui CC"  Size C(037),C(012) PIXEL OF oDlgX When lFecha
         @ C(176),C(043) Button "Exclui CC"  Size C(037),C(012) PIXEL OF oDlgX When lFecha
         @ C(176),C(082) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlgX ACTION( CTEConcilia(3) )
         @ C(176),C(120) Button "Confirmar"  Size C(037),C(012) PIXEL OF oDlgX When lFecha
      Endif
      
      // Exclusão
      If kOperacao == "E"  
         @ C(176),C(005) Button "Inclui CC"  Size C(037),C(012) PIXEL OF oDlgX When lFecha
         @ C(176),C(043) Button "Exclui CC"  Size C(037),C(012) PIXEL OF oDlgX When lFecha
         @ C(176),C(082) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlgX When lFecha
         @ C(176),C(120) Button "Confirmar"  Size C(037),C(012) PIXEL OF oDlgX ACTION( CTEExclui() )
      Endif         
   Endif      

   @ C(176),C(158) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgX ACTION( CTEConcilia(2) )

   If kOperacao == "I"
      aAdd( aRateio, { "", "", "", "", "" } )
   Endif   

   oRateio := TCBrowse():New( 125 , 005, 245, 080,,{'%', 'Valor', 'C.Custo', 'Descrição C.Custo', 'Posição'},{20,50,50,50},oDlgX,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oRateio:SetArray(aRateio) 
    
   // Monta a linha a ser exibina no Browse
   oRateio:bLine := {||{aRateio[oRateio:nAt,01],;
                        aRateio[oRateio:nAt,02],;
                        aRateio[oRateio:nAt,03],;
                        aRateio[oRateio:nAt,04],;
                        aRateio[oRateio:nAt,05]}}

   ACTIVATE MSDIALOG oDlgX CENTERED 

Return(.T.)

// Função de pesquisa a natureza informada ou pesquisada
Static Function psqnatu()

   If Empty(Alltrim(xNatureza))
      xNomeNatu := Space(60)
      oGet8:Refresh()
      oGet9:Refresh()
      Return(.T.)
   Endif
   
   xNomeNatu := Posicione( "SED", 1, xFilial("SED") + xNatureza, "ED_DESCRIC" )   

Return(.T.)

// Função de permite informar os valores de rateio por centro de custo
Static Function VlrRateio( _Operacao, kPercentual, kValor, kCentro, kNomeC, kPosicao )

   Local lChumbado  := .F.

   Private cParte   := kPercentual
   Private cVrateio := kValor
   Private cCcusto  := kCentro
   Private cNomeC   := kNomeC
   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgR

//   U_F050TMP1()

   // Gera consistência antes de incluir Centro de Custo
   If Empty(Alltrim(xCodigo))
      MsgAlert("Transportadora não informada.")
      Return(.T.)
   Endif

   If Empty(xData)
      MsgAlert("Data do documento não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(xFatura))
      MsgAlert("Nº do Doc/Fatura não informado.")
      Return(.T.)
   Endif

   If Empty(xVencto)
      MsgAlert("Data de vencimento não informada.")
      Return(.T.)
   Endif      

   If xValor == 0
      MsgAlert("Valor total a ser cobrado não informado.")
      Return(.T.)
   Endif      
 
   If Empty(Alltrim(xNatureza))
      MsgAlert("Natureza não informada.")
      Return(.T.)
   Endif      

   // Se for Exclusão, verifica se existe dados a serem visualizados
   If _Operacao == "E"
      If Empty(Alltrim(kCentro))
         Return(.T.)
      Endif
   Endif

   // Se for Inclusão, verifica se já está incluído
   If _Operacao == "I"

      If Select("T_VERIFICA") > 0
         T_VERIFICA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS9_CTRA,"
      cSql += "       ZS9_FATU "
      cSql += "  FROM " + RetSqlName("ZS9")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += "   AND ZS9_CTRA   = '" + Alltrim(xCodigo) + "'"
      cSql += "   AND ZS9_FATU   = '" + Alltrim(xFatura) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VERIFICA", .T., .T. )
      
      If !T_VERIFICA->( EOF() )
         MsgAlert("Atenção!" + chr(13) + chr(10) + "Documento já cadastrado para esta transportadora." + chr(13) + chr(10) + "Utilize a opção de consulta.")
         Return(.T.)
      Endif

   Endif   

   If lprimeiro 
      lPrimeiro := .F.
      aRateio   := {}
   Endif

   DEFINE MSDIALOG oDlgR TITLE "Rateio Centro de Custo" FROM C(178),C(181) TO C(272),C(658) PIXEL

   @ C(005),C(005) Say "%"       Size C(006),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(005),C(034) Say "Valor"   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgR
   @ C(005),C(090) Say "C.Custo" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgR

   @ C(014),C(005) MsGet oGet1 Var cParte   Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999.99"         PIXEL OF oDlgR When lChumbado
   @ C(014),C(034) MsGet oGet2 Var cVrateio Size C(050),C(009) COLOR CLR_BLACK Picture "@! 999,999,999.99" PIXEL OF oDlgR VALID( ClcRateio( cParte, cVrateio ) ) When IIF(_Operacao == "I", .T., .F.)
   @ C(014),C(090) MsGet oGet3 Var cCcusto  Size C(033),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgR F3("CTT") VALID( PsqCcusto( cCcusto) ) When IIF(_Operacao == "I", .T., .F.)
   @ C(014),C(138) MsGet oGet4 Var cNomeC   Size C(095),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgR When lChumbado

   @ C(030),C(080) Button IIF(_Operacao == "I", "Gravar", "Excluir") Size C(037),C(012) PIXEL OF oDlgR ACTION( CrgaRateio( _Operacao, cParte, cVrateio, cCcusto, cNomeC, 1, kPosicao ) )
   @ C(030),C(119) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgR ACTION( CrgaRateio( _Operacao, cParte, cVrateio, cCcusto, cNomeC, 0 ) )

   ACTIVATE MSDIALOG oDlgR CENTERED 

Return(.T.)

// Função de calcula o percentual ou valor do rateio
Static Function ClcRateio( cPercent, cVrateio )

   Local nCalculo := 0
   
   nCalculo := Round(((cVrateio * 100) / xValor),2)
   cParte   := nCalculo
   oGet1:Refresh()

Return(.T.)
   
// Função que pesquisa o centro de custo informado ou selecionado
Static Function PsqCcusto( cCcusto )

   If Empty(Alltrim(cCcusto))
      cNomeC := Space(40)
      Return(.T.)
   Endif
   
   DbSelectArea("CTT")
   DbSetOrder(1)
   If DbSeek(xfilial("CTT") + cCcusto )
      cNomeC := CTT->CTT_DESC01
   Else
      cNomeC := Space(40)
   Endif
   
Return(.T.)      

// Função de que carrega o array aRateio
Static Function CrgaRateio( _Operacao, _Parte, _Rateio, _Custo, _NomeC, _Saida, _Posicao)

   Local xx_custo := 0
   Local nContar  := 0   
   Local xCobrado := 0
   Local aTempo   := {}

   // Se _saída == 0, significa que deve fechar o formulário e retornar
   If _Saida == 0
      If Len(aRateio) == 0
         lPrimeiro := .T.
         aAdd( aRateio, { "", "", "", "", "" } )         
      Endif
      oDlgR:End()
      Return(.T.)
   Endif   

   // Elimina o registro do array
   If _Operacao == "E"
      For nContar = 1 to Len(aRateio)
          If Alltrim(str(nContar)) == _Posicao
             Loop
          Endif
          aAdd( aTempo, { aRateio[nContar,01], aRateio[nContar,02], aRateio[nContar,03], aRateio[nContar,04], aRateio[nContar,05] } )
      Next nContar

      aRateio  := {}      
      xx_Custo := 0

      For nContar = 1 to Len(aTempo)
          xx_Custo := xx_custo + aTempo[nContar,02]
          aAdd( aRateio, { aTempo[nContar,01], aTempo[nContar,02], aTempo[nContar,03], aTempo[nContar,04], Alltrim(str(Len(aRateio) + 1)) } )
      Next nContar

      oDlgR:End()

      // Seta vetor para a browse                            
      oRateio:SetArray(aRateio) 
    
      // Monta a linha a ser exibina no Browse
      oRateio:bLine := {||{aRateio[oRateio:nAt,01],;
                           aRateio[oRateio:nAt,02],;
                           aRateio[oRateio:nAt,03],;
                           aRateio[oRateio:nAt,04],;
                           aRateio[oRateio:nAt,05]}}

      // Atualiza o valor total do saldo a ser desdobrado por centro de custo
      xSaldo := xValor - xx_Custo
      oGet7:Refresh()

      Return(.T.)
      
   Endif

   // Verifica se o valor informado não ultrapassa ao valor a ser cobrado
   xCobrado := 0
   For nContar = 1 to Len(aRateio)
       xCobrado := xCobrado + aRateio[nContar,2]
   Next nContar
   
   If (xCobrado + cVrateio) > xValor
      MsgAlert("Atenção! Valor informado somado aos demais valores ultrapassa ao valor total a ser cobrado. Verifique!")
      Return(.T.)
   Endif

   If _Parte == 0 .And. _Rateio == 0 .And. Empty(Alltrim(_Custo))
      If Len(aRateio) == 0
         lPrimeiro := .T.
         aAdd( aRateio, { "", "", "", "", "" } )         
      Endif
      oDlgR:End()
      Return(.T.)
   Endif

   If Empty(Alltrim(_Custo))
      MsgAlert("Centro de Custo não informado. Verifique!")
      Return(.T.)
   Endif   
      
   Do Case
      Case _Operacao == "I"
           aAdd(aRateio, { _Parte, _Rateio, _Custo, _NomeC, Alltrim(str(Len(aRateio) + 1)) } )
      Case _Operacao == "E"


   EndCase

   oDlgR:End()

   // Seta vetor para a browse                            
   oRateio:SetArray(aRateio) 
    
   // Monta a linha a ser exibina no Browse
   oRateio:bLine := {||{aRateio[oRateio:nAt,01],;
                        aRateio[oRateio:nAt,02],;
                        aRateio[oRateio:nAt,03],;
                        aRateio[oRateio:nAt,04],;
                        aRateio[oRateio:nAt,05]}}

   // Calcula o Saldo a se rateado
   xx_Custo := 0
   For nContar = 1 to Len(aRateio)
       xx_Custo := xx_custo + aRateio[nContar,02]
   Next nContar
   
   xSaldo := xValor - xx_Custo
   oGet7:Refresh()

Return(.T.)   

// Função de manutenção da conciliação dos CT-e
Static Function CTEConcilia(__Tipo)

   Local lChumba     := .F.
   Local cMemo1      := ""
   Local oMemo1
   
   Private yCodigo   := xCodigo
   Private yNome     := xNome
   Private yFatura   := xFatura
   Private yData     := xData
   Private yVencto   := xVencto
   Private yValor    := xValor
   Private yNatureza := xNatureza
   Private yChave    := Space(250)
   Private yTqtd     := 0
   Private yTVlr     := 0

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9   

   Private oDlgC

   Private aLista := {}
   Private oLista

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   If __Tipo == 2
      oDlgX:End()
      Return(.T.)
   Endif   

   // Consiste os dados para inclusão
   If Empty(Alltrim(xCodigo))
      MsgAlert("Transportadora não informada. Verifique!")
      Return(.T.)
   Endif   
   
   If Empty(xData)
      MsgAlert("Data do Doc/Fatura não informada. Verifique!")
      Return(.T.)
   Endif   
   
   If Empty(Alltrim(xFatura))  
      MsgAlert("Nº do Doc/Fatura não informado. Verifique!")
      Return(.T.)
   Endif   

   If Empty(xVencto)
      MsgAlert("Vencimento não informada. Verifique!")
      Return(.T.)
   Endif   
   
   If xValor == 0
      MsgAlert("Valor a ser cobrado não informado. Verifique!")
      Return(.T.)
   Endif   

   If xSaldo <> 0
      MsgAlert("Atenção! Ainda existe saldo a ser rateado por centro de custo. Verifique!")
      Return(.T.)
   Endif   

   oDlgX:End()

   // Pesquisa os conhecimentos a serem utilizados na conciliação 
   aLista := {}

   If Select("T_CONCILIAR") > 0
      T_CONCILIAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS9.ZS9_LEGE,"
   cSql += "       ZS9.ZS9_CHAV,"
   cSql += "       ZS9.ZS9_NUME,"
   cSql += "       ZS9.ZS9_TIPO,"
   cSql += "       ZS9.ZS9_SERI,"
   cSql += "       ZS9.ZS9_MODE,"
   cSql += "       ZS9.ZS9_NFIS,"
   cSql += "       ZS9.ZS9_SFIS,"
   cSql += "       ZS9.ZS9_VFRE,"
   cSql += "       ZS9.ZS9_FREN,"
   cSql += "       ZS9.ZS9_CFIS "
   cSql += "  FROM " + RetSqlName("ZS9") + " ZS9 "

   If __Tipo == 1
      cSql += " WHERE ZS9.D_E_L_E_T_ = '' "      
      cSql += "   AND ZS9_CTRA       = '" + Alltrim(xCodigo) + "'"
      cSql += "   AND ZS9_FATU       = ''"
   Else
      cSql += " WHERE ZS9.D_E_L_E_T_ = '' "      
      cSql += "   AND ZS9_CTRA       = '" + Alltrim(xCodigo) + "'"
      cSql += "   AND ZS9_FATU       = '" + Alltrim(xFatura) + "'"
   Endif   
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONCILIAR", .T., .T. )
   
   If T_CONCILIAR->( EOF() )
      aLista := {}
      aAdd( aLista, { .F., "", "", "", "", "", "", "", "", "" } )
      If __Tipo == 1
         MsgAlert("Não existem CT-e disponíveis para esta transportadora.")
      Else
         MsgAlert("Não existem dados a serem visualizados para esta consulta.")
      Endif   
      Return(.T.)
   Endif
   
   T_CONCILIAR->( DbGoTop() )
   
   WHILE !T_CONCILIAR->( EOF() )

      aAdd( aLista, { IIF(__Tipo == 1, .F., .T.) ,;
                      T_CONCILIAR->ZS9_TIPO      ,;
                      T_CONCILIAR->ZS9_NUME      ,;
                      T_CONCILIAR->ZS9_SERI      ,;
                      T_CONCILIAR->ZS9_MODE      ,;
                      T_CONCILIAR->ZS9_NFIS      ,;
                      T_CONCILIAR->ZS9_SFIS      ,;                      
                      TRANSFORM(VAL(ALLTRIM(STR(T_CONCILIAR->ZS9_VFRE,10,02))), "999,999,999.99") ,;
                      TRANSFORM(VAL(ALLTRIM(STR(T_CONCILIAR->ZS9_FREN,10,02))), "999,999,999.99") ,;
                      T_CONCILIAR->ZS9_CHAV })

      T_CONCILIAR->( DbSkip() )

   ENDDO                             
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "","","","","","","","","" } )
   Endif

   // Tela de manutenção da elaboração de informação de fatura de CT-e
   DEFINE MSDIALOG oDlgC TITLE "Conciliação CT-e" FROM C(178),C(181) TO C(582),C(885) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(022) PIXEL NOBORDER OF oDlgC

   @ C(026),C(005) Say "Transportadora"                                 Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(026),C(178) Say "Nº Doc/Fatura"                                  Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(026),C(220) Say "Data Doc."                                      Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(026),C(262) Say "Vencimento"                                     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(026),C(303) Say "Valor Cobrado"                                  Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(047),C(005) Say "Marque os CT-e que pertencem a este Doc/Fatura" Size C(123),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(189),C(005) Say "Chave"                                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(172),C(176) Say "Quant. Marcados"                                Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(172),C(255) Say "Valor Total"                                    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(183),C(005) GET   oMemo1 Var cMemo1  MEMO Size C(341),C(001)                                             PIXEL OF oDlgC When lChumba

   If __Tipo == 1

      @ C(188),C(023) MsGet oGet7  Var yChave       Size C(128),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgC VALID( MarcaChave(yChave) )

   Else

      // Atualiza os totalizadores
      yTQtd := 0
      yTVlr := 0

      For nContar = 1 to Len(aLista)

          If aLista[nContar,01] == .T.
             yTQtd := yTQtd + 1
             yTVlr := yTVlr + Val(aLista[nContar,09])
          Endif

      Next nContar

   Endif
      
   @ C(035),C(005) MsGet oGet1  Var yCodigo      Size C(025),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgC When lChumba
   @ C(035),C(034) MsGet oGet2  Var yNome        Size C(140),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgC When lChumba
   @ C(035),C(178) MsGet oGet3  Var yFatura      Size C(038),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgC When lChumba
   @ C(035),C(220) MsGet oGet4  Var yData        Size C(038),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgC When lChumba
   @ C(035),C(262) MsGet oGet5  Var yVencto      Size C(038),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlgC When lChumba
   @ C(035),C(303) MsGet oGet6  Var yValor       Size C(042),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgC When lChumba

   @ C(171),C(221) MsGet oGet8  Var yTQtd        Size C(026),C(009) COLOR CLR_BLACK Picture "@E 99999"          PIXEL OF oDlgC When lChumba
   @ C(171),C(284) MsGet oGet9  Var yTVlr        Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlgC When lChumba

   If __Tipo == 1
      @ C(187),C(270) Button "Gravar"         Size C(037),C(012) PIXEL OF oDlgC ACTION( GrvMvto() )
   Else
      @ C(187),C(270) Button "Gravar"         Size C(037),C(012) PIXEL OF oDlgC When lChumba
   Endif
         
   @ C(187),C(309) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )

   @ 070,005 LISTBOX oLista FIELDS HEADER "M", "Tipo", "Conhecimento", "Série", "Modelo", "Nº NFiscal", "Série NF", "Frete Total", "Frete p/NF", "Nº Chave" PIXEL SIZE 435,145 OF oDlgC ;
                            ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
             		    	    aLista[oLista:nAt,02],;
         	         	        aLista[oLista:nAt,03],;
         	         	        aLista[oLista:nAt,04],;
         	         	        aLista[oLista:nAt,05],;
         	         	        aLista[oLista:nAt,06],;
         	         	        aLista[oLista:nAt,07],;         	         	        
         	         	        aLista[oLista:nAt,08],;         	         	        
         	         	        aLista[oLista:nAt,09],;         	         	        
         	         	        aLista[oLista:nAt,10]}}

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função de marca chave scaneada/digitada no campo yChave
Static Function MarcaChave(_yChave)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       If Alltrim(aLista[nContar,10]) == Alltrim(_yChave)
          aLista[nContar,01] := .T.
          Exit
       Endif
   Next nContar

   yChave:= Space(250)
   oGet7:Refresh()

   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
             		    	    aLista[oLista:nAt,02],;
         	         	        aLista[oLista:nAt,03],;
         	         	        aLista[oLista:nAt,04],;
         	         	        aLista[oLista:nAt,05],;
         	         	        aLista[oLista:nAt,06],;
         	         	        aLista[oLista:nAt,07],;         	         	        
         	         	        aLista[oLista:nAt,08],;         	         	        
         	         	        aLista[oLista:nAt,09],;         	         	        
         	         	        aLista[oLista:nAt,10]}}
   oLista:Refresh()

   // Atualiza os totalizadores
   yTQtd := 0
   yTVlr := 0

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          yTQtd := yTQtd + 1
          yTVlr := yTVlr + Val(aLista[nContar,09])
       Endif
   Next nContar

   oGet8:Refresh()
   oGet9:Refresh()

   oGet7:SetFocus()
   oGet7:Refresh()
   
Return(.T.)          

// Função de marca/desmarca os registros
Static Function MrcCte(__Marca)

   Local nContar := 0

   For nContar = 1 to Len(aLista)
       If __Marca == 1   
          aLista[nContar,01] := .T.
       Else
          aLista[nContar,01] := .F.          
       Endif
          
   Next nContar              

Return(.T.)      

// Função que grava os CT-e selecionados
Static Function GrvMvto()

   Local nContar   := 0
   Local lMarcado  := .F.
   Local nValorMrc := 0

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar          

   If !lMarcado
      MsgAlert("Atenção! Nenhum registro foi selecionado. Verifique!")
      Return(.T.)
   Endif
      
   // Somar os valores marcados
   nValorMrc := 0
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .F.
          Loop
       Endif
       nValorMrc := nValorMrc + val(aLista[nContar,09])
   Next nContar          

   If yValor <> nValorMrc
      If !MsgYesNo("Atenção!" + chr(13) + chr(10) + "Valor dos CT-e selecionados estão inconsistentes com o valor total informado a ser pago." + chr(13) + chr(10) + "Deseja confirmar assim mesmo?")
         Return(.T.)
      Endif   
   Endif

   // Atualiza os dados na Tabela ZS9 e cria o contas a pagar
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif

       // Atualiza a tabela ZS9 -> Tabela dos CT-e
       DbSelectArea("ZS9")
       DbSetOrder(1)
       If DbSeek(xfilial("ZS9") + aLista[nContar,10])
          RecLock("ZS9",.F.)
          ZS9_VENC := yVencto
          ZS9_DDOC := yData
          ZS9_FATU := yFatura
          ZS9_VALO := yValor
          ZS9_NATU := yNatureza
          ZS9_CFRE := cFornece
          ZS9_LFRE := cLojaFor
          MsUnLock()              
       Endif
       
   Next nContar    

   // Gera o contas a pagar
   DbSelectArea("SE2")
   RecLock("SE2",.T.)
   SE2->E2_FILIAL  := xFilial("SE2")
   SE2->E2_PREFIXO := "CTE"
   SE2->E2_NUM     := yFatura
   SE2->E2_TIPO    := "FT"
   SE2->E2_NATUREZ := "6700110"
   SE2->E2_FORNECE := cFornece
   SE2->E2_LOJA    := cLojaFor
   SE2->E2_NOMFOR  := Posicione( "SA2", 1, xFilial("SA2") + cFornece + cLojaFor, "A2_NOME" )   
   SE2->E2_EMISSAO := yData
   SE2->E2_EMIS1   := yData
   SE2->E2_VENCTO  := yVencto
   SE2->E2_VENCREA := yVencto
   SE2->E2_VENCORI := yVencto
   SE2->E2_VALOR   := yValor
   SE2->E2_SALDO   := yValor
   SE2->E2_RATEIO  := "N"
   SE2->E2_VLCRUZ  := yValor
   SE2->E2_FLUXO   := "S"
   SE2->E2_DESDOBR := "N"
   SE2->E2_MULTNAT := "1"
   SE2->E2_DIRF    := "2"
   SE2->E2_FRETISS := "1"
   SE2->E2_APLVLMN := "1"
   SE2->E2_MODSPB  := "1"
   SE2->E2_PROJPMS := "2"
   SE2->E2_MOEDA   := 1
   SE2->E2_FILORIG := cFilAnt
   DbUnlock()

   // ---------------------------------- //
   // Grava o rateio por centro de custo //
   // ---------------------------------- //                                        
   
   // Grava o cabeçalho do rateio por centro de custo
   DbSelectArea("SEV")
   RecLock("SEV",.T.)
   SEV->EV_PREFIXO	:= "CTE"
   SEV->EV_NUM	    := xFatura
   SEV->EV_CLIFOR	:= cFornece
   SEV->EV_LOJA	    := cLojaFor
   SEV->EV_TIPO	    := "FT"
   SEV->EV_VALOR	:= xValor
   SEV->EV_NATUREZ	:= xNatureza
   SEV->EV_RECPAG	:= "P"
   SEV->EV_PERC	    := 1
   SEV->EV_RATEICC	:= "1"
   DbUnlock()

   // Grava os rateios informados
   For nContar = 1 to Len(aRateio)

       DbSelectArea("SEZ")
       RecLock("SEZ",.T.)
       SEZ->EZ_FILIAL   := cFilAnt
       SEZ->EZ_PREFIXO	:= "CTE
       SEZ->EZ_NUM	    := xFatura
       SEZ->EZ_CLIFOR	:= cFornece
       SEZ->EZ_LOJA	    := cLojaFor
       SEZ->EZ_TIPO	    := "FT"
       SEZ->EZ_VALOR	:= aRateio[nContar,02]
       SEZ->EZ_NATUREZ	:= xNatureza
       SEZ->EZ_CCUSTO	:= aRateio[nContar,03]
       SEZ->EZ_RECPAG	:= "P"
       SEZ->EZ_PERC	    := aRateio[nContar,01]
       SEZ->EZ_IDENT    := "1"	
       DbUnlock()
   
   Next nContar

   oDlgC:End() 

Return(.T.)

// Exclui o lançamento selecionado caso não haja nenhum título pago
Static Function CTEexclui()

   Local cSql      := ""
   Local _nErro    := 0

   If Empty(Alltrim(xFatura))
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cFornece))
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cLojaFor))
      Return(.T.)
   Endif

   If !MsgYesNo("Confirma a exclusão do registro selecionao?")
      Return(.T.)
   Endif
   
   // Libera os registros de Conhecimento de Transportes do documento
   If Select("T_EXCLUIR") > 0
      T_EXCLUIR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS9_CFIS "
   cSql += "  FROM " + RetSqlName("ZS9")
   cSql += " WHERE ZS9_FATU   = '" + Alltrim(xFatura)   + "'"
   cSql += "   AND ZS9_NATU   = '" + Alltrim(xNatureza) + "'"
   cSql += "   AND ZS9_CFRE   = '" + Alltrim(cFornece)  + "'"
   cSql += "   AND ZS9_LFRE   = '" + Alltrim(cLojaFor)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"  

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXCLUIR", .T., .T. )

   If T_EXCLUIR->( EOF() )
      MsgAlert("Registros não localizados para exclusão. Entre em contato com o Administrador do Sistema.")
      Return(.T.)
   Endif

   // Verirfica se existe algum título já pago. Se existir, não permite a exclusão
   If Select("T_BAIXADO") > 0
      T_BAIXADO->( dbCloseArea() )
   EndIf

   cSql := "SELECT E2_FILIAL ,"
   cSql += "       E2_PREFIXO,"   
   cSql += "       E2_NUM    ,"
   cSql += "       E2_TIPO   ,"
   cSql += "       E2_FORNECE,"
   cSql += "       E2_LOJA    "
   cSql += "  FROM " + RetSqlName("SE2")
   cSql += " WHERE E2_PREFIXO = 'CTE'"
   cSql += "   AND E2_NUM     = '" + Alltrim(xFatura)  + "'"
   cSql += "   AND E2_FORNECE = '" + Alltrim(cFornece) + "'"
   cSql += "   AND E2_LOJA    = '" + Alltrim(cLojaFor) + "'"
   cSql += "   AND E2_TIPO    = 'FT'"
   cSql += "   AND E2_SALDO  <> 0"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BAIXADO", .T., .T. )

   If T_BAIXADO->( EOF() )
      MsgAlert("Atenção! Exclusão não permitida pois título já foi quitado.")
      Return(.T.)
   Endif
      
   // Exclui o contas a pagar
   cSql := ""
   cSql := "DELETE "
   cSql += "  FROM " + RetSqlName("SE2")
   cSql += " WHERE E2_FILIAL  = '" + Alltrim(xFilial("SE2")) + "'"
   cSql += "   AND E2_PREFIXO = 'CTE'"
   cSql += "   AND E2_NUM     = '" + Alltrim(xFatura) + "'"
   cSql += "   AND E2_PARCELA = '  '"
   cSql += "   AND E2_TIPO    = 'FT'" 
   cSql += "   AND E2_FORNECE = '" + Alltrim(cFornece) + "'"
   cSql += "   AND E2_LOJA    = '" + Alltrim(cLojaFor) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   // Exclui o cabeçalho do rateio por centro de custo
   cSql := ""
   cSql := "DELETE "
   cSql += "  FROM " + RetSqlName("SEV")
   cSql += " WHERE EV_PREFIXO = 'CTE'"
   cSql += "   AND EV_NUM     = '" + Alltrim(xFatura)   + "'"
   cSql += "   AND EV_PARCELA = '  '"
   cSql += "   AND EV_TIPO    = 'FT'"
   cSql += "   AND EV_CLIFOR  = '" + Alltrim(cFornece)  + "'"
   cSql += "   AND EV_LOJA    = '" + Alltrim(cLojaFor)  + "'"
   cSql += "   AND EV_NATUREZ = '" + Alltrim(xNatureza) + "'"

   _nErro := TcSqlExec(cSql) 

   If TCSQLExec(cSql) < 0 
      alert(TCSQLERROR())
      Return(.T.)
   Endif

   // Deleta os rateios por centro de custo (Detalhes)
	   For nContar = 1 to Len(aRateio)

       cSql := "DELETE "
       cSql += "  FROM " + RetSqlName("SEZ")
       cSql += " WHERE EZ_PREFIXO = 'CTE'"
       cSql += "   AND EZ_NUM     = '" + Alltrim(xFatura)   + "'"
       cSql += "   AND EZ_PARCELA = '  '"
       cSql += "   AND EZ_TIPO    = 'FT'"
       cSql += "   AND EZ_CLIFOR  = '" + Alltrim(cFornece)  + "'"
       cSql += "   AND EZ_LOJA    = '" + Alltrim(cLojaFor)  + "'"
       cSql += "   AND EZ_NATUREZ = '" + Alltrim(xNatureza) + "'"

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
          Return(.T.)
       Endif
   
   Next nContar

   // Libera os registros envolvidos
   T_EXCLUIR->( DbGoTop() )
   WHILE !T_EXCLUIR->( EOF() )
   
      // Atualiza a tabela ZS9 -> Tabela dos CT-e
      DbSelectArea("ZS9")
      DbSetOrder(2)
      If DbSeek(xfilial("ZS9") + T_EXCLUIR->ZS9_CFIS)
         RecLock("ZS9",.F.)
         ZS9_VENC := CTOD("  /  /    ")
         ZS9_DDOC := CTOD("  /  /    ")
         ZS9_FATU := ""
         ZS9_VALO := 0
         ZS9_NATU := ""
         ZS9_CFRE := ""
         ZS9_LFRE := ""
         MsUnLock()              
      Endif

      T_EXCLUIR->( DbSkip() )
      
   ENDDO      

   oDlg:End() 

Return(.T.)