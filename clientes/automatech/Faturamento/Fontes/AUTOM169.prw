#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM169.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/04/2013                                                          *
// Objetivo..: Programa que mostra os totais da Proposta Comercial                 *
//**********************************************************************************

User Function AUTOM169()

   Local cSql    := ""
   Local lChumba := .F.
   Local nContar := 0
   Local aBrowse := {}

   Local _RBase_Cliente   := 0
   Local _RAliq_Cliente   := 0
   Local _RValor_Cliente  := 0
   Local _RBase_Emitente  := 0
   Local _RAliq_Emitente  := 0
   Local _RValor_Emitente := 0
   Local _DBase_Cliente   := 0
   Local _DAliq_Cliente   := 0
   Local _DValor_Cliente  := 0
   Local _DBase_Emitente  := 0
   Local _DAliq_Emitente  := 0
   Local _DValor_Emitente := 0

   Local _PRO_POSICAO := 0
   Local _TES_POSICAO := 0
   Local _TOT_POSICAO := 0
   Local _TOT_MOEDA   := 0

   Local _ICMBASED    := 0
   Local _ALIBASED    := 0
   Local _VALBASED    := 0
   Local _ICMRETID    := 0
   Local _ALIRETID    := 0
   Local _VALRETID    := 0
   Local _DIFICMSD    := 0
   Local _PROICMSR    := 0
   Local _TOTDIFER    := 0
   Local _PROICMSD    := 0
   Local _TOTDIFED    := 0

   Local cGet1	      := Space(25)
   Local cGet2	      := Space(25)
   Local cGet3	      := Space(25)
   Local cGet4	      := Space(25)
   Local cGet5	      := Space(25)
   Local cGet6	      := Space(25)

   Local cMemo1	      := ""

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oMemo1

   Local _DIFICMS     := 0

   Private oDlgP

   U_AUTOM628("AUTOM169")

   // Pesquisa o nº do Orçamento para pesquisa
   If Select("T_ORCAMENTO") > 0
       T_ORCAMENTO->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT CJ_FILIAL,"
   csql += "       CJ_NUM   ,"
   csql += "       CJ_MOEDA  "
   csql += "  FROM " + RetSqlName("SCJ") 
   csql += " WHERE CJ_NROPOR  = '" + Alltrim(M->AD1_NROPOR) + "'"
   cSql += "   AND CJ_FILIAL  = '" + Alltrim(cFilAnt)       + "'"
   csql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORCAMENTO", .T., .T. )

   If T_ORCAMENTO->( EOF() )
      Return .T.
   Endif

   // Captura o estado do cliente da proposta comercial
   If Select("T_ESTADO") > 0
      T_ESTADO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_EST    ,"
   cSql += "       A1_TIPO   ,"
   cSql += "       A1_GRPTRIB "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(M->AD1_CODCLI) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(M->AD1_LOJCLI) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTADO", .T., .T. )

   If T_ESTADO->( EOF() )
      Return(.T.)
   Endif
   
   // Calcula o valor dos produtos da oportunidade
   Select T_ORCAMENTO->( DbGoTop() )
   
   WHILE !T_ORCAMENTO->( EOF() )

      // Pesquisa os dados da proposta comercial para cálculo
      If Select("T_PROPOSTA") > 0
          T_PROPOSTA->( dbCloseArea() )
      EndIf

      csql := ""
      csql := "SELECT A.CK_FILIAL ,"
      csql += "       A.CK_PROPOST,"
      csql += "       A.CK_ITEM   ,"
      csql += "       A.CK_PRODUTO,"
      csql += "       A.CK_DESCRI ,"
      csql += "       A.CK_QTDVEN ,"
      csql += "       A.CK_PRCVEN ,"
      csql += "       A.CK_VALOR  ,"
      csql += "       A.CK_TES    ,"                            
      csql += "       B.B1_GRUPO  ,"
      csql += "       B.B1_DESC   ,"
      csql += "       B.B1_DAUX   ,"
      csql += "       B.B1_GRTRIB ,"
      csql += "       B.B1_ORIGEM  "
      csql += "  FROM " + RetSqlName("SCK") + " A, " 
      csql += "       " + RetSqlName("SB1") + " B  " 
      csql += " WHERE A.CK_NUM    = '" + Alltrim(T_ORCAMENTO->CJ_NUM)    + "'"
      csql += "   AND A.CK_FILIAL = '" + Alltrim(T_ORCAMENTO->CJ_FILIAL) + "'"
      csql += "   AND A.D_E_L_E_T_ = ''"
      csql += "   AND A.CK_PRODUTO = B.B1_COD"
      csql += " ORDER BY A.CK_ITEM"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

      If T_PROPOSTA->( EOF() )
         T_ORCAMENTO->( DbSkip() )
         Loop
      Endif

      T_PROPOSTA->( dbGoTop() )
   
      WHILE !T_PROPOSTA->( EOF() )

          // Verifica se o produto é de origem extrangeira
          If Alltrim(T_ESTADO->A1_EST) <> Alltrim(SM0->M0_ESTENT) .And. Alltrim(T_ESTADO->A1_TIPO)$GetMv("MV_TPSOLCF")
             
             // Verifica se o TES indicado no produto deve utilizar a excesão fiscal
             If Select("T_TES") > 0
                T_TES->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT F4_ICM    ,"
             cSql += "       F4_LFICM  ,"
             cSql += "       F4_COMPL  ,"
             cSql += "       F4_CONSUMO,"
             cSql += "       F4_INCSOL ,"
             cSql += "       F4_MKPSOL  "
             cSql += "  FROM " + RetSqlName("SF4")
             cSql += " WHERE F4_CODIGO  = '" + Alltrim(T_PROPOSTA->CK_TES) + "'"
             cSql += "   AND D_E_L_E_T_ = ''"
      
             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TES", .T., .T. )

             lCalcula := .T.

             // Verifica se os campos da Tabela SF4 - Cadastro de TES condizem com os dados para o cálculo

             // Calcula ICMS
             If T_TES->F4_ICM <> "S"
                lCalcula := .F.
             Endif
             
             // L. FISC. ICMS
             If T_TES->F4_LFICM <> "T"
                lCalcula := .F.
             Endif

             // Dif. de Alíquota
             If T_TES->F4_LFICM <> "T"
                lCalcula := .F.
             Endif

             // Agrega Solid.
             If T_TES->F4_INCSOL <> "S"
                lCalcula := .F.
             Endif
           
             // Marg, Solid.
             If T_TES->F4_MKPSOL <> "1"
                lCalcula := .F.
             Endif

             If lCalcula

                lAtualiza := .T.

                // Pesquisa a excesão fiscal para calculo do produto
                If Select("T_FISCAL") > 0
                   T_FISCAL->( dbCloseArea() )
                EndIf
       
                cSql := ""
                cSql := "SELECT F7_EST    ,"
                cSql += "       F7_TIPOCLI," 
                cSql += "       F7_ALIQINT,"
                cSql += "       F7_ALIQEXT,"
                cSql += "       F7_MARGEM ,"
                cSql += "       F7_ALIQDST "
                cSql += "  FROM " + RetSqlName("SF7")
                cSql += " WHERE F7_GRTRIB  = '" + Alltrim(T_PROPOSTA->B1_GRTRIB) + "'"
                cSql += "   AND F7_EST     = '" + Alltrim(T_ESTADO->A1_EST)      + "'"
                cSql += "   AND F7_TIPOCLI = '" + Alltrim(T_ESTADO->A1_TIPO)     + "'"
                cSql += "   AND F7_GRPCLI  = '" + Alltrim(T_ESTADO->A1_GRPTRIB)  + "'"
                cSql += "   AND D_E_L_E_T_ = ''"

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FISCAL", .T., .T. )

                If T_FISCAL->( EOF() )
                   lAtualiza := .F.
                Endif
       
                If lAtualiza

                   // Calcula o ICMS ST do produto lido
                   If T_ORCAMENTO->CJ_MOEDA == 1

                      // Calcula o ICMS Próprio (Do Cliente)
                      _RBase_Cliente := T_PROPOSTA->CK_VALOR

                      DO CASE
                         CASE T_PROPOSTA->B1_ORIGEM == "0"
                              _RAliq_Cliente := 17
                         CASE T_PROPOSTA->B1_ORIGEM == "1"
                              _RAliq_Cliente := 4
                         CASE T_PROPOSTA->B1_ORIGEM == "2"
                              _RAliq_Cliente := 4
                         CASE T_PROPOSTA->B1_ORIGEM == "4"
                              _RAliq_Cliente := 17
                         CASE T_PROPOSTA->B1_ORIGEM == "5"
                              _RAliq_Cliente := 4
                         CASE T_PROPOSTA->B1_ORIGEM == "7"
                              _RAliq_Cliente := 4
                         OTHERWISE
                              _RAliq_Cliente := 17                              
                      ENDCASE
             
                      _RValor_Cliente := (_RBase_Cliente * _RAliq_Cliente) / 100
                      
                      // Calcula o ICMS Próprio (Do Emitente)
                      _RBase_Emitente  := T_PROPOSTA->CK_VALOR
                      _RAliq_Emitente  := T_FISCAL->F7_ALIQINT
                      _RValor_Emitente := (_RBase_Emitente * _RAliq_Emitente) / 100
                      
                      _VALRETIR := _RValor_Emitente - _RValor_Cliente

                   Else
                      
                      // Calcula o ICMS Próprio (Do Cliente)
                      _DBase_Cliente := T_PROPOSTA->CK_VALOR

                      DO CASE
                         CASE T_PROPOSTA->B1_ORIGEM == "0"
                              _DAliq_Cliente := 17
                         CASE T_PROPOSTA->B1_ORIGEM == "1"
                              _DAliq_Cliente := 4
                         CASE T_PROPOSTA->B1_ORIGEM == "2"
                              _DAliq_Cliente := 4
                         CASE T_PROPOSTA->B1_ORIGEM == "4"
                              _DAliq_Cliente := 17
                         CASE T_PROPOSTA->B1_ORIGEM == "5"
                              _DAliq_Cliente := 4
                         CASE T_PROPOSTA->B1_ORIGEM == "7"
                              _DAliq_Cliente := 4
                         OTHERWISE
                              _DAliq_Cliente := 17                              
                      ENDCASE
             
                      _DValor_Cliente := (_DBase_Cliente * _DAliq_Cliente) / 100
                      
                      // Calcula o ICMS Próprio (Do Emitente)
                      _DBase_Emitente  := T_PROPOSTA->CK_VALOR
                      _DAliq_Emitente  := T_FISCAL->F7_ALIQINT
                      _DValor_Emitente := (_DBase_Emitente * _DAliq_Emitente) / 100

                      _VALRETID := _DValor_Emitente - _DBase_Cliente
                              
                   Endif
                     
                   _DIFICMS := IIF(T_ORCAMENTO->CJ_MOEDA == 1, _VALRETIR, _VALRETID)
                
                Else   

                   _DIFICMS := 0
                
                Endif
             
             Else
              
                _DIFICMS := 0
             
             Endif   
          
          Else
          
             _DIFICMS := 0
             
          Endif   
          
          // Carraga o array aBrowse com o resultado do cálculo
          aAdd( aBrowse, { T_PROPOSTA->CK_ITEM   ,;
                           T_PROPOSTA->CK_PRODUTO,;
                           T_PROPOSTA->CK_DESCRI ,;
                           T_PROPOSTA->CK_QTDVEN ,;
                           T_ORCAMENTO->CJ_MOEDA ,;
                           Transform(T_PROPOSTA->CK_PRCVEN, "@E 999,999.99")   ,;
                           Transform(T_PROPOSTA->CK_VALOR , "@E 999,999.99") ,;
                           Transform(_DIFICMS, "@E 999,999.99")              ,;
                           Transform((T_PROPOSTA->CK_VALOR + _DIFICMS), "@E 999,999.99") } )                        

          T_PROPOSTA->( DbSkip() )

      Enddo
      
      T_ORCAMENTO->( DbSkip() )
      
   Enddo      

   // Calcula os Totais da proposta Comercial
   _TOTDIFER := 0
   _TOTDIFED := 0
   _PROICMSR := 0
   _TOTDIFER := 0
   _PROICMSR := 0
   _PROICMSD := 0
   _TOTDIFED := 0
   _PROICMSD := 0

   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,5] == 1
          _PROICMSR := _PROICMSR + VAL(STRTRAN(STRTRAN(aBrowse[nContar,7],".",""),",","."))
          _TOTDIFER := _TOTDIFER + VAL(STRTRAN(STRTRAN(aBrowse[nContar,8],".",""),",","."))
       Else  
          _PROICMSD := _PROICMSD + VAL(STRTRAN(STRTRAN(aBrowse[nContar,7],".",""),",","."))
          _TOTDIFED := _TOTDIFED + VAL(STRTRAN(STRTRAN(aBrowse[nContar,8],".",""),",","."))
       Endif
   Next nContar    

   xRetiR := _TOTDIFER
   xRetiD := _TOTDIFED

   cGet1 := _PROICMSR
   cGet2 := _TOTDIFER
   cGet3 := _PROICMSR + _TOTDIFER

   cGet4 := _PROICMSD
   cGet5 := _TOTDIFED
   cGet6 := _PROICMSD + _TOTDIFED

   // Abre a janela dos totais da proposta comercial
   DEFINE MSDIALOG oDlgP TITLE "Totais da Proposta Comercial" FROM C(178),C(181) TO C(435),C(900) PIXEL

   @ C(094),C(005) Say "Valor Total dos Produtos em R$" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(094),C(143) Say "Valor Total dos Produtos US$"   Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(104),C(005) Say "Diferencial de Alíquota em R$"  Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(104),C(143) Say "Diferencial de Alíquota em US$" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(114),C(005) Say "Total em R$"                    Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(114),C(143) Say "Total em US$"                   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgP

   @ C(092),C(088) MsGet oGet1 Var cGet1 When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 99,999,999.99" PIXEL OF oDlgP
   @ C(103),C(088) MsGet oGet2 Var cGet2 When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 99,999,999.99" PIXEL OF oDlgP
   @ C(113),C(088) MsGet oGet3 Var cGet3 When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 99,999,999.99" PIXEL OF oDlgP
   @ C(092),C(228) MsGet oGet4 Var cGet4 When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 99,999,999.99" PIXEL OF oDlgP
   @ C(103),C(228) MsGet oGet5 Var cGet5 When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 99,999,999.99" PIXEL OF oDlgP
   @ C(113),C(228) MsGet oGet6 Var cGet6 When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture "@E 99,999,999.99" PIXEL OF oDlgP

   @ C(111),C(305) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   oBrowse := TCBrowse():New( 005 , 005, 450, 105,,{'Item', 'Codigo', 'Descrição dos Produtos', 'Qtd', 'Moeda', 'Unitário', 'Sub-Total' , 'Dif. ICMS', 'Total'},{20,50,50,50},oDlgP,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
      oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                            aBrowse[oBrowse:nAt,02],;
                            aBrowse[oBrowse:nAt,03],;
                            aBrowse[oBrowse:nAt,04],;
                            aBrowse[oBrowse:nAt,05],;
                            aBrowse[oBrowse:nAt,06],;
                            aBrowse[oBrowse:nAt,07],;
                            aBrowse[oBrowse:nAt,08],;
                            aBrowse[oBrowse:nAt,09]} }
   Endif   

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)