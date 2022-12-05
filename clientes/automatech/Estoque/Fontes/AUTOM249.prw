#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM249.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/08/2014                                                          *
// Objetivo..: Ateração data de garantia de produtos                               *
//**********************************************************************************

User Function AUTOM249()

   Local lChumba     := .F.

   Private cCaminho1 := Space(100)
   Private cCaminho2 := Space(100)

   Private oGet1
   Private oGet2
   
   Private oDlg

   U_AUTOM628("AUTOM249")

   DEFINE MSDIALOG oDlg TITLE "Alteração Garantia de Produtos" FROM C(178),C(181) TO C(312),C(662) PIXEL

   @ C(005),C(005) Say "Arquivo de garantia a ser importado"          Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Arquivo de Grupo de Produtos a ser importado" Size C(112),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(005) MsGet oGet1 Var cCaminho1 Size C(215),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(035),C(005) MsGet oGet2 Var cCaminho2 Size C(215),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(014),C(221) Button "..." Size C(013),C(010) PIXEL OF oDlg ACTION( ARQGARANTIA(1) )
   @ C(035),C(221) Button "..." Size C(013),C(010) PIXEL OF oDlg ACTION( ARQGARANTIA(2) )

   @ C(050),C(005) Button "Garantia"  Size C(037),C(012) PIXEL OF oDlg ACTION( AltGarPro() )
   @ C(050),C(157) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( AltGarantia() )
   @ C(050),C(196) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que altera a garantia do produto através do cadastro de grupos de produtos
Static Function AltGarPro()

   Local cSql       := "" 
   Local __Garantia := ""

   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_FILIAL, " + chr(13)
   cSql += "       B1_COD   , " + chr(13)
   cSql += "       B1_DESC  , " + chr(13)
   cSql += "       B1_GARANT, " + chr(13)
   cSql += "       B1_GRUPO   " + chr(13)
   cSql += "  FROM " + RetSqlName("SB1") + chr(13)
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY B1_COD" + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
   
      DbSelectArea("SBM")
      DbSetorder(1)
      If DbSeek(xfilial("SBM") + T_PRODUTOS->B1_GRUPO)
         __Garantia := SBM->BM_GARANT
      Else
         __Garantia := ""
      Endif
         
      // Altera a garantia no cadastro de produtos
      DbSelectArea("SB1")
      DbSetorder(1)
      If DbSeek(xfilial("SB1") + T_PRODUTOS->B1_COD)
         RecLock("SB1",.F.)
         B1_GARANT := __Garantia
         MsUnLock()           
      Endif   

      T_PRODUTOS->( DbSkip() )
      
   ENDDO

   MsgAlert("Grupos do cadastro de produtos atualizado com sucesso.")

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function ARQGARANTIA(_Tipo)

   If _Tipo == 1
      cCaminho1 := cGetFile('*.*', "Selecione o arquivo a ser importado",1,"",.F.,16,.F.)
   Else
      cCaminho2 := cGetFile('*.*', "Selecione o arquivo a ser importado",1,"",.F.,16,.F.)      
   Endif
   
Return .T. 

// Função que altera a garantia dos produtos conforme regra
Static Function AltGarantia()

   Local cSql      := ""
   Local nRegua    := 0
   Local __Filial  := ""
   Local __Codigo  := ""
   Local aProdutos := {}
   Local nContar   := 0
   Local aGarantia := {}
   Local aSepara   := {}
   Local cConteudo := ""
   Local _Linha    := ""
   Local nContar   := 0

   If Empty(Alltrim(cCaminho1))
      MsgAlert("Arquivo de Garantia a ser importado não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cCaminho2))
      MsgAlert("Arquivo de Grupos de Produtos a ser importado não informado.")
      Return(.T.)
   Endif

   If !File(Alltrim(cCaminho1))
      MsgAlert("Arquivo de Garantia a ser importado inexistente.")
      Return(.T.)
   Endif

   If !File(Alltrim(cCaminho2))
      MsgAlert("Arquivo de Grupo de Produtos a ser importado inexistente.")
      Return(.T.)
   Endif

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cCaminho1), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          _Linha    := ""
          aAdd( aSepara,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Carrega o array de Garantia
   For nContar = 1 to Len(aSepara)
   
       _Codigo   := Strzero(INT(VAL(U_P_CORTA(aSepara[nContar], "|", 1))),6) + Space(24)
       _Garantia := Strzero(INT(VAL(U_P_CORTA(aSepara[nContar], "|", 2))),4)

       aAdd( aGarantia, { _Codigo, _Garantia } )

   Next nContar

   // Atualiza a garantia no cadastro de produtos
   For nContar = 1 to Len(aGarantia)
   
       // Altera a garantia no cadastro de produtos
       DbSelectArea("SB1")
       DbSetorder(1)
       If DbSeek(xfilial("SB1") + aGarantia[nContar,01])
          RecLock("SB1",.F.)
          If Int(val(aGarantia[nContar,02])) == 0
             B1_GARANT := ""
          Else   
             B1_GARANT := Alltrim(Str(Int(val(aGarantia[nContar,02]))))
          Endif
          MsUnLock()           
       Endif   
       
   Next nContar    
            
   // ----------------------------------------- //
   // Atualiza o cadastro de grupos de produtos //
   // ----------------------------------------- //

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cCaminho2), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   aSepara   := {}
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          _Linha    := ""
          aAdd( aSepara,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Carrega o array de Garantia
   For nContar = 1 to Len(aSepara)
   
       _Codigo   := Strzero(INT(VAL(U_P_CORTA(aSepara[nContar], "|", 1))),4)
       _Garantia := Strzero(INT(VAL(U_P_CORTA(aSepara[nContar], "|", 2))),4)

       aAdd( aGarantia, { _Codigo, _Garantia } )

   Next nContar

   // Atualiza a garantia no cadastro de produtos
   For nContar = 1 to Len(aGarantia)
   
       // Altera a garantia no cadastro de produtos
       DbSelectArea("SBM")
       DbSetorder(1)
       If DbSeek(xfilial("SBM") + aGarantia[nContar,01])
          RecLock("SBM",.F.)
          If Int(val(aGarantia[nContar,02])) == 0
             BM_GARANT := ""
          Else   
             BM_GARANT := Alltrim(Str(Int(val(aGarantia[nContar,02]))))
          Endif
          MsUnLock()           
       Endif   
       
   Next nContar    

   // Altera garantia dos produtos DIFERENTES das descrições abaixo
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_FILIAL, " + chr(13)
   cSql += "       B1_COD   , " + chr(13)
   cSql += "       B1_DESC  , " + chr(13)
   cSql += "       B1_GARANT, " + chr(13)
   cSql += "       B1_GRUPO   " + chr(13)
   cSql += "  FROM " + RetSqlName("SB1") + chr(13)
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY B1_COD" + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )

   lAltera := .t.

   WHILE !T_PRODUTOS->( EOF() ) 

      lAltera := .t.

      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "AP", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "BALAN", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "CAR", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "COL", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "COMPU", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "ESTAB", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "GAV", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP TT", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP TD", 1) <> 0
         lAltera := .F.
      ENDIF

      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP PT TT", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP PT TD", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP FIS", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP JTC", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP JTT", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP NFIS", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP CHEQ", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "IMP CARTAO", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT CCD", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT LAS", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT IMA", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT LAS BT", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT IMA BT", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT DOC MAN", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT DOC SAUT", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "LEIT RFID", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "MONITOR", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "MTERM", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "NOBRK", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "PINPAD", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "RADIO", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "SERV IMP", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "SWITCH", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "SCANNER", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "TAB", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "TEC", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "TEC PROG", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "TERM CONS", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "TERM PESQ", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If U_P_OCCURS(ALLTRIM(T_PRODUTOS->B1_DESC), "WS", 1) <> 0
         lAltera := .F.
      ENDIF
         
      If lAltera := .T.
         DbSelectArea("SB1")
         DbSetorder(1)
 		 If DbSeek(xfilial("SB1") + T_PRODUTOS->B1_COD )
            RecLock("SB1",.F.)
            B1_GARANT := "90"
            MsUnLock()           
         Endif
      Endif

 	  T_PRODUTOS->( DbSkip() )
      
   ENDDO



/*
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_FILIAL, " + chr(13)
   cSql += "       B1_COD   , " + chr(13)
   cSql += "      (B1_DESC + B1_DAUX) AS DESCRICAO, " + chr(13)
   cSql += "       B1_GARANT, " + chr(13)
   cSql += "       B1_GRUPO   " + chr(13)
   cSql += "  FROM " + RetSqlName("SB1") + chr(13)
   cSql += " WHERE (RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%AP%'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%BALAN%'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%CAR'"  + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%COL'"  + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%COMPU'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%ESTAB'"  + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%GAV'"  + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP TT'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP TD'"  + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP PT TT' " + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP PT TD'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP FIS'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP JTC'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP JTT'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP NFIS'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP CHEQ'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%IMP CARTAO'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT CCD'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT LAS'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT IMA'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT LAS BT'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT IMA BT'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT DOC MAN'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE '%LEIT DOC SAUT'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'LEIT RFID'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'MONITOR'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'MTERM'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'NOBRK'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'PINPAD'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'RADIO'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'SERV IMP'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'SWITCH'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'SCANNER'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'TAB'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'TEC'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'TEC PROG'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'TERM CONS'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'TERM PESQ'" + chr(13)
   cSql += "    OR  RTRIM(LTRIM(B1_DESC)) + ' ' + RTRIM(LTRIM(B1_DAUX)) NOT LIKE 'WS')" + chr(13)
   cSql += "   AND D_E_L_E_T_ = '' " + chr(13)
   cSql += " ORDER BY B1_COD" + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
 
   If T_PRODUTOS->( EOF() )
      Return(.T.)
   Endif
   
   // Carrega o Array aProdutos
   T_PRODUTOS->( DbGoTop() )
   
   WHILE !T_PRODUTOS->( EOF() )
      aAdd( aProdutos, { T_PRODUTOS->B1_FILIAL, T_PRODUTOS->B1_COD } )
      T_PRODUTOS->( DbSkip() )
   ENDDO

   For nContar = 1 to Len(aProdutos)      

      // Altera a garantia no cadastro de produtos
      DbSelectArea("SB1")
      DbSetorder(1)
      If DbSeek(aProdutos[nContar,01] + aProdutos[nContar,02])
         RecLock("SB1",.F.)
         B1_GARANT := "90"
         MsUnLock()           
      Endif   
            
      // Altera a garantia no cadastro de grupos de produtos
      DbSelectArea("SBM")
      DbSetorder(1)
      If DbSeek(aProdutos[nContar,01] + aProdutos[nContar,02])
         RecLock("SBM",.F.)
         BM_GARANT := "90"
         MsUnLock()           
      Endif   

   Next nContar
*/

   MsgAlert("Alteração realizada com sucesso.")
   
Return(.T.)