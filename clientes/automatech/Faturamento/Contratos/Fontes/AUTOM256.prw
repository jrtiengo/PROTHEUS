#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM256.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/10/2014                                                          *
// Objetivo..: Programa que controla a emissão de recibos dos contratos de Locação.*
//**********************************************************************************

User Function AUTOM256()

   Local lChumba     := .F.

   Private aTipoC    := {}
   Private aBrowsex  := {}
   Private aFiliais  := {}
   Private aRecibos  := {"00 - Selecione", "01 - A Emitir","02 - Emitidos", "03 - Ambos"}
   Private cComboBx1
   Private cComboBx3
   Private cCliente	 := Space(06)
   Private cLoja	 := Space(03)
   Private cNomeCli  := Space(60)
   Private cContrato := Space(15)
   Private cCompete  := Space(10)
   Private cMemo1	 := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oMemo1

   // Declara as Legendas
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

   // Crarega o array de filiais conforme a empresa logada
   Do Case
      Case cEmpAnt == "01"
           aFiliais := { "00 - Selecione", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos" } 
      Case cEmpAnt == "02"
           aFiliais := { "00 - Selecione", "01 - Porto Alegre" } 
      Case cEmpAnt == "03"
           aFiliais := { "00 - Selecione", "01 - TI (Curitiba/PR)" }
   EndCase
 
   // Carrega o array aTipoM com os códigos dos tipo de movimentos parametrizados
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TPOA, ZZ4_TCUR, ZZ4_TATE  "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção! Não existe parametrizador para esta Empresa/Filial. Entre em contato com o Administrador do Sistema reportando esta mensagem.")
      Return(.T.)
   Endif
   
   // Carrega os tipo de contrato para o Grupo de Empresa 01
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TPOA, "|", 1)
       aAdd( aTipoC, { "01", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TPOA, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TPOA, "|", nContar), "#", 2) } )
   Next nContar

   // Carrega os tipo de contrato para o Grupo de Empresa 02
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TCUR, "|", 1)
       aAdd( aTipoC, { "02", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TCUR, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TCUR, "|", nContar), "#", 2) } )
   Next nContar

   // Carrega os tipo de contrato para o Grupo de Empresa 03
   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TATE, "|", 1)
       aAdd( aTipoC, { "03", U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TATE, "|", nContar), "#", 1), U_P_CORTA(U_P_CORTA(T_PARAMETROS->ZZ4_TATE, "|", nContar), "#", 2) } )
   Next nContar

   // Desenha e abre a tela do programa
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Contrato Locação" FROM C(178),C(181) TO C(594),C(864) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(027) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(333),C(001) PIXEL OF oDlg

   @ C(022),C(217) Say "Controle de emissão de Recibos para Contratos de Locação." Size C(185),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(005) Say "Filiais"                                                   Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(066) Say "Cliente"                                                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(259) Say "Nº Contrato"                                               Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Recibo de Pagamento"                                       Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "Parcelas dos Contratos selecionados"                       Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(194),C(132) Say "Documento A Emitir"                                        Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(194),C(199) Say "Documento Emitido"                                         Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(096) Say "Competência"                                               Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(194),C(119) Jpeg FILE "br_vermelho" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(194),C(186) Jpeg FILE "br_verde"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(044),C(005) ComboBox cComboBx1 Items aFiliais  Size C(054),C(010) PIXEL OF oDlg
   @ C(044),C(066) MsGet    oGet1     Var   cCliente  Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(044),C(096) MsGet    oGet2     Var   cLoja     Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( TrazNcli() )
   @ C(044),C(115) MsGet    oGet3     Var   cNomeCli  Size C(136),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(259) MsGet    oGet4     Var   cContrato Size C(077),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(067),C(096) MsGet    oGet5     Var   cCompete  Size C(061),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(064),C(259) Button "Pesquisar"                 Size C(037),C(012) PIXEL OF oDlg ACTION( PopulaGrid() )
   @ C(067),C(005) ComboBox cComboBx3 Items aRecibos  Size C(088),C(010) PIXEL OF oDlg

   @ C(191),C(005) Button "Emissão de Recibos" Size C(068),C(012) PIXEL OF oDlg ACTION( ImpRecBol() )
   @ C(191),C(299) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowsex := TCBrowse():New( 115 , 005, 423, 125,,{'R  ', 'Filial', 'Código', 'Loja', 'Descrição dos Clentes', 'Número', 'Nº Contrato', 'Parcelas', 'Competência', 'Valor Parcelas', 'Vencimentos', 'Revisa', 'Nº Recibo'} , {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowsex:SetArray(aBrowsex) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowsex) == 0
      aAdd( aBrowsex, { "7", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   oBrowsex:bLine := {||{ If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "7", oBranco  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "1", oVerde   ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "4", oPink    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "3", oAmarelo ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "2", oPreto   ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "9", oVermelho,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                          aBrowsex[oBrowsex:nAt,02]               ,;
                          aBrowsex[oBrowsex:nAt,03]               ,;                         
                          aBrowsex[oBrowsex:nAt,04]               ,;                         
                          aBrowsex[oBrowsex:nAt,05]               ,;                         
                          aBrowsex[oBrowsex:nAt,06]               ,;                         
                          aBrowsex[oBrowsex:nAt,07]               ,;                         
                          aBrowsex[oBrowsex:nAt,08]               ,;                         
                          aBrowsex[oBrowsex:nAt,09]               ,;                         
                          aBrowsex[oBrowsex:nAt,10]               ,;                                                                             
                          aBrowsex[oBrowsex:nAt,11]               ,;                                                                             
                          aBrowsex[oBrowsex:nAt,12]               ,;                                                                             
                          aBrowsex[oBrowsex:nAt,13]               }}
      
   oBrowsex:Refresh()

   oBrowsex:bHeaderClick := {|oObj,nCol| oBrowsex:aArray := Ordenar(nCol,oBrowsex:aArray),oBrowsex:Refresh()}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)

   If _nPosCol <> 1
      _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays
   Endif   

Return(_aOrdena)

// Função que pesquisa o nome do cliente se informado
Static Function TrazNcli()

   If Empty(Alltrim(cCliente))
      cCliente := Space(06)
      cLoja    := Space(03)
      cNomeCli := Space(60)
      oGet1:Refresh()
      oGet2:Refresh()
      oGet3:Refresh()            
      Return(.T.)
   Endif
   
   cNomeCli := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME")      

Return(.T.)

// Função que pesquisa os dados conforme filtro e popula o grid do programa
Static Function PopulaGrid()
   
   Local cSql      := "" 
   Local TContrato := ""
   Local nContar   := 0
   
   // Captura o código do tipo de contrato para pesquisa
   For nContar = 1 to Len(aTipoC)
       If Substr(cCombobx1,01,02) == "00"   
          If Alltrim(aTipoC[nContar,01]) == Alltrim(cEmpAnt)
             If aTipoC[nContar,02] == cFilAnt
                TContrato := aTipoC[nContar,03]
                Exit
             Endif
          Endif
       Else
          If Alltrim(aTipoC[nContar,01]) == Alltrim(cEmpAnt)
             If aTipoC[nContar,02] == Substr(cCombobx1,01,02)
                TContrato := aTipoC[nContar,03]
                Exit
             Endif
          Endif
       Endif
   Next nContar    

   If Empty(Alltrim(TContrato))
      MsgAlert("Atencao! Entre em contato com o administrador do sistema informando que o programa de emissao de recibos nao esta parametrizado corretamente.")
      Return(.T.)
   Endif

   // Pesquisa os cronogramas conforme filtro informado
   If Select("T_RECIBOS") > 0
      T_RECIBOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.CNF_FILIAL," + CHR(13)
   cSql += "       B.CN9_CLIENT," + CHR(13)
   cSql += "       B.CN9_LOJACL," + CHR(13)
   cSql += "       C.A1_NOME   ," + CHR(13)
   cSql += "       A.CNF_NUMERO," + CHR(13)
   cSql += "       A.CNF_CONTRA," + CHR(13)
   cSql += "       A.CNF_PARCEL," + CHR(13)
   cSql += "       A.CNF_REVISA," + CHR(13)
   cSql += "       A.CNF_COMPET," + CHR(13)
   cSql += "       A.CNF_VLPREV," + CHR(13)
   cSql += "       A.CNF_DTVENC," + CHR(13)
   cSql += "       A.CNF_ZRCB  ," + CHR(13)
   cSql += "       A.CNF_ZREC   " + CHR(13)
   cSql += "  FROM " + RetSqlName("CNF") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("CN9") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " C  " + CHR(13)
   cSql += " WHERE A.D_E_L_E_T_ = ''"           + CHR(13)
   cSql += "   AND B.CN9_FILIAL = A.CNF_FILIAL" + CHR(13)
   cSql += "   AND B.CN9_NUMERO = A.CNF_CONTRA" + CHR(13)
   cSql += "   AND C.A1_COD     = B.CN9_CLIENT" + CHR(13)
   cSql += "   AND C.A1_LOJA    = B.CN9_LOJACL" + CHR(13)
   cSql += "   AND B.CN9_TPCTO  = '" + Alltrim(TContrato) + "'"

   // Filtra pela Filial
   If Substr(cCombobx1,01,02) <> "00"
      cSql += "   AND A.CNF_FILIAL = '" + Alltrim(Substr(cCombobx1,01,02)) + "'" + CHR(13)
   Endif

   // Filtra pelo Contrato
   If !Empty(Alltrim(cContrato))
      cSql += "   AND A.CNF_CONTRA = '" + Alltrim(cContrato) + "'" + CHR(13)
   Endif   

   // Filtra pelo Cliente informado
   If !Empty(Alltrim(cCliente))
      cSql += "   AND C.A1_COD  = '" + Alltrim(cCliente) + "'" + CHR(13)
      cSql += "   AND C.A1_LOJA = '" + Alltrim(cLoja)    + "'" + CHR(13)
   Endif
 
   // Filtra pelos Recibos
   If Substr(cComboBx3,01,02) <> "00"
      Do Case
         Case Substr(cComboBx3,01,02) == "01"
              cSql += "   AND A.CNF_ZREC IN (' ', '1')" + CHR(13)
         Case Substr(cComboBx3,01,02) == "02"
              cSql += "   AND A.CNF_ZREC = '2'" + CHR(13)
      EndCase
   Endif

   // Filtra por Competência
   If !Empty(Alltrim(cCompete))
      cSql += "  AND A.CNF_COMPET = '" + Alltrim(cCompete) + "'" + CHR(13)
   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RECIBOS", .T., .T. )

   aBrowsex := {}
   
   T_RECIBOS->( EOF() )
   WHILE !T_RECIBOS->( EOF() )

      Do Case
         Case Empty(Alltrim(T_RECIBOS->CNF_ZREC))
              _LegRecibo := "9"
         Case T_RECIBOS->CNF_ZREC == "1"
              _LegRecibo := "9"
         Case T_RECIBOS->CNF_ZREC == "2"
              _LegRecibo := "1"        
      EndCase

      aAdd( aBrowsex, { _LegRecibo            ,;
                        T_RECIBOS->CNF_FILIAL ,;
                        T_RECIBOS->CN9_CLIENT ,;
                        T_RECIBOS->CN9_LOJACL ,;
                        T_RECIBOS->A1_NOME    ,;                                                
                        T_RECIBOS->CNF_NUMERO ,;
                        T_RECIBOS->CNF_CONTRA ,;
                        T_RECIBOS->CNF_PARCEL ,;
                        T_RECIBOS->CNF_COMPET ,;
                        T_RECIBOS->CNF_VLPREV ,;
                        T_RECIBOS->CNF_DTVENC ,;
                        T_RECIBOS->CNF_REVISA ,;
                        T_RECIBOS->CNF_ZRCB   })
                        
      T_RECIBOS->( DbSkip() )
      
   ENDDO                           
   
   // Seta vetor para a browse                            
   oBrowsex:SetArray(aBrowsex) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowsex) == 0
      aAdd( aBrowsex, { "7", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   oBrowsex:bLine := {||{ If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "7", oBranco  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "1", oVerde   ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "4", oPink    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "3", oAmarelo ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "5", oAzul    ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "6", oLaranja ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "2", oPreto   ,;                         
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "9", oVermelho,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "X", oCancel  ,;
                          If(Alltrim(aBrowsex[oBrowsex:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                          aBrowsex[oBrowsex:nAt,02]               ,;
                          aBrowsex[oBrowsex:nAt,03]               ,;                         
                          aBrowsex[oBrowsex:nAt,04]               ,;                         
                          aBrowsex[oBrowsex:nAt,05]               ,;                         
                          aBrowsex[oBrowsex:nAt,06]               ,;                         
                          aBrowsex[oBrowsex:nAt,07]               ,;                         
                          aBrowsex[oBrowsex:nAt,08]               ,;                         
                          aBrowsex[oBrowsex:nAt,09]               ,;                         
                          aBrowsex[oBrowsex:nAt,10]               ,;                                                                             
                          aBrowsex[oBrowsex:nAt,11]               ,;                                                                             
                          aBrowsex[oBrowsex:nAt,12]               ,;                                                                             
                          aBrowsex[oBrowsex:nAt,13]               }}
      
   oBrowsex:Refresh()

Return(.T.)

// Função que realiza a impressão de recibos dos cronogramas
Static Function ImpRecBol()

   Local nContar := 0
   Local cMemo1	 := ""
   Local oMemo1
   Local oOk      := LoadBitmap( GetResources(), "LBOK" )
   Local oNo      := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgImp

   Private aImprime := {}
   Private oImprime

   // Carrega o array aImprime com os registros disponíveis para impressão
   For nContar = 1 to Len(aBrowsex)
       aAdd(aImprime, { .F.                 ,;
                        aBrowsex[nContar,02],;
                        aBrowsex[nContar,03],;
                        aBrowsex[nContar,04],;
                        aBrowsex[nContar,05],;
                        aBrowsex[nContar,06],;
                        aBrowsex[nContar,07],;
                        aBrowsex[nContar,08],;
                        aBrowsex[nContar,09],;
                        aBrowsex[nContar,10],;
                        aBrowsex[nContar,11],;
                        aBrowsex[nContar,12],;
                        aBrowsex[nContar,13]})
   Next nContar   

   If Len(aImprime) == 0
      MsgAlert("Atenção! Não existem dados a serem utilizados para impressão. Verifique pesquisa.")   
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgImp TITLE "Impressão de Recibos" FROM C(178),C(181) TO C(594),C(864) PIXEL
 
   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(102),C(027) PIXEL NOBORDER OF oDlgImp

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(333),C(001) PIXEL OF oDlgImp
   
   @ C(022),C(152) Say "Controle de emissão de Recibos para Contratos de Locação."             Size C(185),C(008) COLOR CLR_BLACK PIXEL OF oDlgImp
   @ C(035),C(005) Say "Selecione os registros que serão utilizados para impressão de Recibos" Size C(182),C(008) COLOR CLR_BLACK PIXEL OF oDlgImp

   @ C(191),C(005) Button "Marcar Todos"    Size C(055),C(012) PIXEL OF oDlgImp ACTION( FQMTORPI(1) )
   @ C(191),C(061) Button "Desmarcar Todos" Size C(055),C(012) PIXEL OF oDlgImp ACTION( FQMTORPI(2) )
   @ C(191),C(166) Button "Imprimir Recibo" Size C(068),C(012) PIXEL OF oDlgImp ACTION( ImpRecibo() )
   @ C(191),C(299) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgImp ACTION( oDlgImp:End() )

   // ListBox com os filtros do vendedor selecionado - Tamanho Original - (185,077)
   @ 055,005 LISTBOX oImprime FIELDS HEADER '', 'Filial', 'Código', 'Loja', 'Descrição dos Clentes', 'Número', 'Nº Contrato', 'Parcelas', 'Competência', 'Valor Parcelas', 'Vencimentos', 'Revisa' PIXEL SIZE 425,185 OF oDlgImp ;
             ON dblClick(aImprime[oImprime:nAt,1] := !aImprime[oImprime:nAt,1],oImprime:Refresh())     
   oImprime:SetArray( aImprime )
   oImprime:bLine := {||     {Iif(aImprime[oImprime:nAt,01],oOk,oNo),;
           					      aImprime[oImprime:nAt,02],;
          	        	          aImprime[oImprime:nAt,03],;
          	        	          aImprime[oImprime:nAt,04],;
         	        	          aImprime[oImprime:nAt,05],;
         	        	          aImprime[oImprime:nAt,06],;
         	        	          aImprime[oImprime:nAt,07],;
         	        	          aImprime[oImprime:nAt,09],;
         	        	          aImprime[oImprime:nAt,08],;
         	        	          aImprime[oImprime:nAt,10],;
         	        	          aImprime[oImprime:nAt,11],;
         	        	          aImprime[oImprime:nAt,12],;
         	        	          aImprime[oImprime:nAt,13]}}

   ACTIVATE MSDIALOG oDlgImp CENTERED 

Return(.T.)

// Função que Marca/Desmarca os registros para impressão
Static Function FQMTORPI(_Botao)

   Local nContar := 0

   For nContar = 1 to Len(aImprime)
       If _Botao == 1
          aImprime[nContar,01] := .T.
       Else
          aImprime[nContar,01] := .F.              
       Endif
   Next nContar       

Return(.T.)

// Função que Imprime o recibo de quitação das parcelas do cronograma
Static Function ImpRecibo()

   Local cSql      := ""
   Local nContar   := 0
   Local nNumRec   := 0
   Local lMarcado  := .F.
   Local cExtenso  := ""
   Local cTexto    := ""
   Local cNomeMes  := ""
   Local nContar   := 0
   Local nLin      := 0
   Local aContrato := {}
   Local cPathDot  := ""   && "C:\AUTOMATECH\HARALD\LOCACAO2.DOT"

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
	
   // Orientação da página
   oPrint:SetPortrait()    // Para Retrato
	
   // Tamanho da página na impressão
   oPrint:SetPaperSize(9)   // A4
	
   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14   := TFont():New( "Arial",,14,,.f.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )


   // Verifica se houve marcação de pelo menos um registro para impressão
   lMarcado := .F.
   For nContar = 1 to Len(aImprime)
       If aImprime[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado
   Else
      MsgAlert("Atenção! Nenhum registro selecionado para impressão.")
      Return(.T.)
   Endif

   // Pesquisa o arquivo a ser utilizado para impressão do contrato de locação
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_RECI FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção! Entre em contato com o Administrador do Sistema informando que existe problema nos parâmetros do Sistema para impressão do recibo de contratos.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_RECI))
      MsgAlert("Atenção! Entre em contato com o Administrador do Sistema informando que existe problema nos parâmetros do Sistema para impressão do recibo de contratos.")
      Return(.T.)
   Endif
  
   If !File(Alltrim(T_PARAMETROS->ZZ4_RECI))
      MsgAlert("Atenção! Entre em contato com o Administrador do Sistema informando que existe problema nos parâmetros do Sistema para impressão do recibo de contratos.")
      Return(.T.)
   Endif

   // Imprime o recibo para os registros selecionados
   For nContar = 1 to Len(aImprime)

       If aImprime[nContar,01] == .F.
          Loop
       Endif

       // Pesquisa o próximo número de recinbo para gravação e impressão
       If aImprime[nContar,13] == 0
          If Select("T_NUMEROS") > 0
             T_NUMEROS->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT MAX(CNF_ZRCB) AS RECIBO "
          cSql += "  FROM " + RetSqlName("CNF")
          cSql += " WHERE D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMEROS", .T., .T. )

          If T_NUMEROS->( EOF() )
             nNumRec := 1
          Else
             nNumRec := T_NUMEROS->RECIBO + 1
          Endif
       Else
          nNumRec := aImprime[nContar,13]
       Endif

       oPrint:StartPage()

       nLin := 100
 
       // Imprime o Logotipo 
       oPrint:SayBitmap(nLin, 0800, "logoautoma.bmp", 0700, 0200 )
       nLin += 500

       // Imprime a identificação da Empresa logada
       oPrint:Say(nLin, 0100, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont14b) 
       nLin += 50
       oPrint:Say(nLin, 0100, AllTrim( SM0->M0_ENDENT ) + " " + AllTrim( SM0->M0_COMPENT ), oFont14b)
       nLin += 50
       oPrint:Say(nLin, 0100, Alltrim(SM0->M0_CIDENT) + "/" + Alltrim(SM0->M0_ESTENT ), oFont14b)
       nLin += 50
       oPrint:Say(nLin, 0100, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), oFont14b)
       nLin += 200
       oPrint:Say(nLin, 1600, "Recibo Nº " + Strzero(nNumRec,5), oFont14b)
       nLin += 200
       oPrint:Say(nLin, 0850, "Recibo de Locação", oFont14b)
       nLin += 200
       
       cCNPJCliente := Posicione("SA1", 1, xFilial("SA1") + aImprime[nContar,03] + aImprime[nContar,04], "A1_CGC")
       cCNPJCliente := Substr(cCNPJCliente,01,02) + "." + ;
                       Substr(cCNPJCliente,03,03) + "." + ;       
                       Substr(cCNPJCliente,06,03) + "/" + ;
                       Substr(cCNPJCliente,09,04) + "-" + ;
                       Substr(cCNPJCliente,13,02)

       cExtenso := PADR(Extenso(aImprime[nContar,10]),100,"")

       oPrint:Say(nLin, 0100, "Recebemos de " + Alltrim(aImprime[nContar,05]) + ", inscrita no CNPJ nº " + cCNPJCliente + " o valor de", oFont12)
       nLin += 50       
       oPrint:Say(nLin, 0100, "R$ " + Alltrim(Transform(aImprime[nContar,10], "@E 999,999,999.99")) + " - " + Alltrim(cExtenso), oFont12)
       nLin += 50
       oPrint:Say(nLin, 0100, "referente a parcela " + aImprime[nContar,09] + " com vencimento em " + ;
                              Substr(aImprime[nContar,11],07,02) + "/" + Substr(aImprime[nContar,11],05,02) + "/" + Substr(aImprime[nContar,11],01,04) + ;
                              " da locação definida no contrato de locação", oFont12) 
       nLin += 50                              
       oPrint:Say(nLin, 0100, "Nº " + aImprime[nContar,07] + " e firmada entre as partes.", oFont12)
       nLin += 50                              
       oPrint:Say(nLin, 0100, "A validade deste recibo está vinculada ao comprovante de depósito para uma das contas bancárias abaixo:", oFont12)

       nLin += 200
       oPrint:Say(nLin, 0100, "Caixa Econômica Federal", oFont12b)
       nLin += 50
       oPrint:Say(nLin, 0100, "Agência: 0446", oFont12b)
       nLin += 50
       oPrint:Say(nLin, 0100, "Conta: 2281-0", oFont12b)
       nLin += 200                                  
       oPrint:Say(nLin, 0100, "Banco Banrisul", oFont12b)
       nLin += 50
       oPrint:Say(nLin, 0100, "Agência: 0070", oFont12b)
       nLin += 50
       oPrint:Say(nLin, 0100, "Conta: 060422990-7", oFont12b)
       nLin += 200       
       oPrint:Say(nLin, 0100, "Banco Itaú", oFont12b)
       nLin += 50
       oPrint:Say(nLin, 0100, "Agência: 0296", oFont12b)
       nLin += 50
       oPrint:Say(nLin, 0100, "Conta: 89086-6", oFont12b)
       nLin += 250

       Do Case
          Case Month(Date()) = 1
               cNomeMes := "JANEIRO"
          Case Month(Date()) = 2
               cNomeMes := "FEVEREIRO"
          Case Month(Date()) = 3
               cNomeMes := "MARÇO"
          Case Month(Date()) = 4
               cNomeMes := "ABRIL"
          Case Month(Date()) = 5
               cNomeMes := "MAIO"
          Case Month(Date()) = 6
               cNomeMes := "JUNHO"
          Case Month(Date()) = 7
               cNomeMes := "JULHO"
          Case Month(Date()) = 8
               cNomeMes := "AGOSTO"
          Case Month(Date()) = 9
               cNomeMes := "SETEMBRO"
          Case Month(Date()) = 10
               cNomeMes := "OUTUBRO"
          Case Month(Date()) = 11
               cNomeMes := "NOVEMBRO"
          Case Month(Date()) = 12
               cNomeMes := "DEZEMBRO"
       EndCase                                                                                                       

       oPrint:Say(nLin, 0100, Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " DE " + Alltrim(cNomeMes) + " DE " + Strzero(Year(Date()),4), oFont12 )

       oPrint:EndPage()

       oPrint:Preview()
  
       MS_FLUSH()

       nLin := 0

       // Atualiza o campo de indicação de documento (Recibo) impresso
       DbSelectArea("CNF")
       DbSetOrder(3)
       If DbSeek( aImprime[nContar,02] + aImprime[nContar,07] + aImprime[nContar,12] + aImprime[nContar,06] + aImprime[nContar,08] )
          RecLock("CNF",.F.)
          CNF_ZRCB := nNumRec
          CNF_ZREC := "2"
          MsUnLock()              
       Endif

   Next nContar

   // Atualiza a tela do grid após impressão
   PopulaGrid()

Return(.T.)