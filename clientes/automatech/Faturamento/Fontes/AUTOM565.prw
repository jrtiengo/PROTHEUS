#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM565.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/10/2012                                                          ##
// Objetivo..: Consulta NFs não Transmitidas e Quebra de Sequencia de Numeração.   ##
// ################################################################################## 

User Function AUTOM565()

   Local cMemo1	   := ""
   Local oMemo1

   Private aEmpresas := U_AUTOM539(1, "")
   Private aFiliais	 := U_AUTOM539(2, cEmpAnt)

   Private cComboBx1
   Private cComboBx2

   Private dInicial  := Ctod("  /  /    ")
   Private dFinal    := Ctod("  /  /    ")
   Private cNota     := Space(10)
   Private cNaoTrans := ""
   Private cNaoLocal := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo2
   Private oMemo3
   
   Private oDlg

   U_AUTOM628("AUTOM565")

   DEFINE MSDIALOG oDlg TITLE "Conferência de Transmissão de Notas Fiscais e Numeração de Notas Fiscais" FROM C(178),C(181) TO C(595),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(385),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Empresa"                                                            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(080) Say "Filiail"                                                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(148) Say "Data Inicial"                                                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(190) Say "Data Final"                                                         Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(232) Say "Nº NFiscal"                                                         Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Relação de Notas Fiscais não transmitidas para os parâmetros acima" Size C(164),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(130),C(005) Say "Relação de Numerações de notas Fiscais não localizadas (Sequencia)" Size C(174),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) ComboBox cComboBx1 Items aEmpresas      Size C(072),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(044),C(080) ComboBox cComboBx2 Items aFiliais       Size C(065),C(010)                              PIXEL OF oDlg
   @ C(044),C(148) MsGet    oGet1     Var   dInicial       Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(190) MsGet    oGet2     Var   dFinal         Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(232) MsGet    oGet3     Var   cNota          Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(066),C(005) GET      oMemo2    Var   cNaoTrans MEMO Size C(383),C(062)                              PIXEL OF oDlg
   @ C(140),C(005) GET      oMemo3    Var   cNaoLocal MEMO Size C(383),C(048)                              PIXEL OF oDlg

   @ C(041),C(274) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( NFNaotransm() )

   @ C(192),C(351) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(044),C(080) ComboBox cComboBx2 Items aFiliais  Size C(065),C(010) PIXEL OF oDlg

Return(.T.)

// ###########################################################
// Função que pesquisa notas fiscais ainda não transmitidas ##
// ###########################################################
Static Function NFNaotransm()

   cNaoTrans := ""
   cNaoLocal := ""

   oMemo2:Refresh()
   oMemo3:Refresh()

   If Empty(dInicial)
      MsgAlert("Data inicial para pesquisa não informada.")
      Return(.T.)
   Endif
      
   If Empty(dFinal)
      MsgAlert("Data final para pesquisa não informada.")
      Return(.T.)
   Endif

   MsgRun("Favor Aguarde! Pesquisando dados conforme parâmetros ...", "Atenção!",{|| xNFNaotransm() })

Return(.T.)

// ###########################################################
// Função que pesquisa notas fiscais ainda não transmitidas ##
// ###########################################################
Static Function xNFNaotransm()

   Local cSql       := ""
   Local nContar    := 0
   Local nSequencia := 0
   Local lPrimeiro  := .T.
   Local cString    := ""

   Private aSeries  := {}
   Private oSeries
   
   // #############################################################
   // Limpa os campos memo que recebem o resultado das pesquisas ##
   // #############################################################
   cNaoTrans := ""
   cNaoLocal := ""

   // #############################################################################################
   // Envia para a função que carrega o array aSeries a ser utilizado na pesquisa dos resultados ##
   // #############################################################################################
   AbrSeries()   

   If Len(aSeries) == 0
      cNaoTrans := "Nenhuma série encontrada ou selecionada para realizar a pesquisa."
      cNaoLocal := "Nenhuma série encontrada ou selecionada para realizar a pesquisa."
      oMemo2:Refresh()
      oMemo3:Refresh()
      Return(.T.)
   Endif

   // ########################################
   // Prepara as séries a serem pesquisadas ##
   // ########################################
   cString := ""

   For nContar = 1 to Len(aSeries)
       If aSeries[nContar,01] == .T.      
          cString += "'" + Alltrim(aSeries[nContar,02]) + "',"
       Endif
   Next nContar
   
   If Empty(Alltrim(cString))
      cNaoTrans := "Nenhuma série encontrada ou selecionada para realizar a pesquisa."
      cNaoLocal := "Nenhuma série encontrada ou selecionada para realizar a pesquisa."
      oMemo2:Refresh()
      oMemo3:Refresh()
      Return(.T.)
   Endif
      
   // ###############################################
   // Elimina a última vírgula da variável cString ##
   // ###############################################
   cString := "(" + Substr(cString,01, Len(Alltrim(cString)) - 1) + ")"

   // ########################################
   // Pesquisa os dados conforme parâmetros ##
   // ########################################
   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT SF2.F2_FILIAL ,"
   cSql += "       SF2.F2_DOC    ,"
   cSql += "	   SF2.F2_SERIE  ,"
   cSql += "	   SF2.F2_CLIENTE,"
   cSql += "	   SF2.F2_LOJA   ,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "	   SF2.F2_EMISSAO,"
   cSql += "	   SF2.F2_VEND1  ," 
   cSql += "      (SELECT A3_NOME FROM SA3010 WHERE A3_COD = SF2.F2_VEND1 AND D_E_L_E_T_ = '') AS VENDEDOR"

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cSql += "  FROM SF2010 SF2,"
           cSql += "       SA1010 SA1 "
      Case Substr(cComboBx1,01,02) == "02"
           cSql += "  FROM SF2020 SF2,"
           cSql += "       SA1010 SA1 "
      Case Substr(cComboBx1,01,02) == "03"
           cSql += "  FROM SF2030 SF2,"
           cSql += "       SA1010 SA1 "
      Case Substr(cComboBx1,01,02) == "04"
           cSql += "  FROM SF2040 SF2,"
           cSql += "       SA1010 SA1 "
   EndCase           
           
   cSql += " WHERE SF2.F2_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
   cSql += "   AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
   cSql += "   AND SF2.F2_SERIE IN " + cString
   cSql += "   AND SF2.D_E_L_E_T_  = ''"
   cSql += "   AND (SF2.F2_CHVNFE   = '' AND SF2.F2_NFELETR = '') "
   cSql += "   AND SA1.A1_COD      = SF2.F2_CLIENTE"
   cSql += "   AND SA1.A1_LOJA     = SF2.F2_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_  = ''            "

   If Empty(Alltrim(cNota))
   Else
      cSql += " AND SF2.F2_DOC = '" + Alltrim(cNota) + "'"
   Endif    

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   T_NOTAS->( DbGoTop() )

   cNaoTrans := ""
   
   WHILE !T_NOTAS->( EOF() )
   
      cNaoTrans += "FILIAL: "           + T_NOTAS->F2_FILIAL  + " " + ;
                   "EMISSAO: "          + Substr(T_NOTAS->F2_EMISSAO,07,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,05,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,01,04) + " " + ;
                   "DOCUMENTO: "        + T_NOTAS->F2_DOC     + " " + ;
                   "SERIE: "            + T_NOTAS->F2_SERIE   + " " + ;
                   "CLIENTE: "          + Alltrim(T_NOTAS->F2_CLIENTE) + "." + Alltrim(T_NOTAS->F2_LOJA) + " " + ;
                   "NOME DO CLIENTE: "  + T_NOTAS->A1_NOME    + CHR(13) + CHR(10)
      
      T_NOTAS->( DbSkip() )
      
   ENDDO                     

   If Empty(Alltrim(cNaoTrans))
      cNaoTrans := "NÃO EXISTEM NOTAS FISCAIS A SEREM TRANSMITIDAS"
   Endif

   oMemo2:Refresh()

   // #################################################################################
   // Pesquisa as notas fiscais para verificação da quebra de sequencia de numeração ##
   // #################################################################################
   If Select("T_SEQUENCIA") > 0
      T_SEQUENCIA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SF2.F2_FILIAL ,"      
   cSql += "       SF2.F2_EMISSAO,"	   
   cSql += "       SF2.F2_DOC    ,"	   
   cSql += "       SF2.F2_SERIE   "	   

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cSql += "  FROM SF2010 SF2"
      Case Substr(cComboBx1,01,02) == "02"
           cSql += "  FROM SF2020 SF2"
      Case Substr(cComboBx1,01,02) == "03"
           cSql += "  FROM SF2030 SF2"
      Case Substr(cComboBx1,01,02) == "04"
           cSql += "  FROM SF2040 SF2"
   EndCase           

   cSql += " WHERE SF2.F2_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial)  + "', 103)"
   cSql += "   AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)    + "', 103)"
   cSql += "   AND SF2.D_E_L_E_T_  = ''   "
   cSql += " ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEQUENCIA", .T., .T. )

   // #######################
   // Verifica a numeração ##
   // #######################
   cNaoLocal := ""

   For nContar = 1 to Len(aSeries)

       lPrimeiro  := .T.
       nSequencia := 0
   
       T_SEQUENCIA->( DbGoTop() )
       
       WHILE !T_SEQUENCIA->( EOF() )
       
          If Alltrim(T_SEQUENCIA->F2_SERIE) == Alltrim(aSeries[nContar,02])

             If lPrimeiro == .T.
                nSequencia := T_SEQUENCIA->F2_DOC
                lPrimeiro  := .F.
             Else
                nSequencia := Strzero(INT(VAL(nSequencia)) + 1,06)
             Endif
             
             If Alltrim(T_SEQUENCIA->F2_DOC) == Alltrim(nSequencia)
             Else

                // #####################################################
                // Verifica se a nota fiscal foi cancelada (Excluída) ##
                // #####################################################
                If Select("T_CANCELADA") > 0
                   T_CANCELADA->( dbCloseArea() )
                EndIf

                cSql := ""
                cSql := "SELECT SF2.F2_FILIAL ,"
                cSql += "       SF2.F2_EMISSAO,"
	            cSql += "       SF2.F2_DOC    ,"
	            cSql += "       SF2.F2_SERIE   "

                Do Case
                   Case Substr(cComboBx1,01,02) == "01"
                        cSql += "  FROM SF2010 SF2"
                   Case Substr(cComboBx1,01,02) == "02"
                        cSql += "  FROM SF2020 SF2"
                   Case Substr(cComboBx1,01,02) == "03"
                        cSql += "  FROM SF2030 SF2"
                   Case Substr(cComboBx1,01,02) == "04"
                        cSql += "  FROM SF2040 SF2"
                EndCase           
         
                cSql += " WHERE SF2.F2_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
                cSql += "   AND SF2.F2_DOC      = '" + Alltrim(nSequencia)              + "'"
                cSql += "   AND SF2.F2_SERIE    = '" + Alltrim(aSeries[nContar,02])     + "'"
                cSql += "   AND SF2.D_E_L_E_T_ <> ''"
                
                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CANCELADA", .T., .T. )

                If T_CANCELADA->( EOF() )

                   // #########################################################
                   // Verifica se a nota fiscal é uma nota fiscal de entrada ##
                   // #########################################################
                   If Select("T_ENTRADA") > 0
                      T_ENTRADA->( dbCloseArea() )
                   EndIf

                   cSql := ""
                   cSql := "SELECT SF1.F1_FILIAL ,"
                   cSql += "       SF1.F1_EMISSAO,"
	               cSql += "       SF1.F1_DOC    ,"
	               cSql += "       SF1.F1_SERIE  ,"
	               cSql += "       SF1.F1_FORNECE,"
	               cSql += "       SF1.F1_LOJA   ,"
	               cSql += "       SA2.A2_NOME    "

                   Do Case
                      Case Substr(cComboBx1,01,02) == "01"
                           cSql += "  FROM SF1010 SF1,"
                           cSql += "       SA2010 SA2 " 
                      Case Substr(cComboBx1,01,02) == "02"
                           cSql += "  FROM SF1020 SF1,"
                           cSql += "       SA2010 SA2 " 
                      Case Substr(cComboBx1,01,02) == "03"
                           cSql += "  FROM SF1030 SF1,"
                           cSql += "       SA2010 SA2 " 
                      Case Substr(cComboBx1,01,02) == "04"
                           cSql += "  FROM SF1040 SF1,"
                           cSql += "       SA2010 SA2 " 
                   EndCase           
         
                   cSql += " WHERE SF1.F1_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
                   cSql += "   AND SF1.F1_DOC     = '" + Alltrim(nSequencia)              + "'"
                   cSql += "   AND SF1.F1_SERIE   = '" + Alltrim(aSeries[nContar,02])     + "'"
                   cSql += "   AND SF1.D_E_L_E_T_ = ''"
                   cSql += "   AND SA2.A2_COD     = SF1.F1_FORNECE"
                   cSql += "   AND SA2.A2_LOJA    = SF1.F1_LOJA   "
                   cSql += "   AND SA2.D_E_L_E_T_ = ''            "
                
                   cSql := ChangeQuery( cSql )
                   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENTRADA", .T., .T. )
                
                   If T_ENTRADA-> (EOF() )
                      cNaoLocal += "Nota Fiscal nº " + Alltrim(nSequencia) + "/" + aSeries[nContar,02] + " não localizada." + CHR(13) + CHR(10)
                   Else
                      cNaoLocal += "Nota Fiscal nº " + Alltrim(nSequencia) + "/" + aSeries[nContar,02] + " foi utilizado como Documento de Entrada." + CHR(13) + CHR(10)                   
                   Endif                   
                   
                Else

                   cNaoLocal += "Nota Fiscal nº " + Alltrim(nSequencia) + "/" + aSeries[nContar,02] + " está cancelada." + CHR(13) + CHR(10)                
                
                Endif                   
                   
                nSequencia := T_SEQUENCIA->F2_DOC

             Endif
             
          Endif
          
          T_SEQUENCIA->( DbSkip() )
          
       ENDDO
       
   Next nContar
    
   oMemo3:Refresh()               

Return(.T.)   

// ######################################################################
// Função que abre a janela depois da pesquisa para seleção das séries ##
// ######################################################################
Static Function AbrSeries()

   Local cSql       := ""

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgOco

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   aSeries := {}

   // ##################################################
   // Pesquisa as séries para popular o array aMarcas ##
   // ##################################################
   If Select("T_SERIES") > 0
      T_SERIES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SF2.F2_SERIE"

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cSql += "  FROM SF2010 SF2"
      Case Substr(cComboBx1,01,02) == "02"
           cSql += "  FROM SF2020 SF2"
      Case Substr(cComboBx1,01,02) == "03"
           cSql += "  FROM SF2030 SF2"
      Case Substr(cComboBx1,01,02) == "04"
           cSql += "  FROM SF2040 SF2"
   EndCase           

   cSql += " WHERE SF2.F2_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial)  + "', 103)"
   cSql += "   AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)    + "', 103)"
   cSql += "   AND SF2.D_E_L_E_T_  = ''   "
   cSql += " GROUP BY SF2.F2_SERIE        "
 
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERIES", .T., .T. )

   T_SERIES->( DbGoTop() )
   
   WHILE !T_SERIES->( EOF() )
      aAdd( aSeries, { .F., T_SERIES->F2_SERIE } )
      T_SERIES->( DbSkip() )
   ENDDO

   If Len(aSeries) == 0
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgOco TITLE "Séries Pesquisadas" FROM C(178),C(181) TO C(517),C(566) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgOco

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(185),C(001) PIXEL OF oDlgOco

   @ C(038),C(005) Say "Séries"      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgOco

   @ C(152),C(151) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgOco ACTION( oDlgOco:End() )

   @ 060,005 LISTBOX oSeries FIELDS HEADER "", "Séries" PIXEL SIZE 233,130 OF oDlgOco ;
             ON dblClick(aSeries[oSeries:nAt,1] := !aSeries[oSeries:nAt,1],oSeries:Refresh())     

   oSeries:SetArray( aSeries )

   oSeries:bLine := {|| {Iif(aSeries[oSeries:nAt,01],oOk,oNo),;
      					     aSeries[oSeries:nAt,02]}}

   ACTIVATE MSDIALOG oDlgOco CENTERED 

Return(.T.)