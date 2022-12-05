#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FT600TOK.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/07/2012                                                          *
// Objetivo..: Ponto de entrada Ft600TOk existe na função A600TudoOk da rotina     *
//             FATA600 que faz a validação  do usuário na inclusão da Proposta     *
//             Comercial.                                                          *
//             CONSISTÊNCIAS NA GRAVAÇÃO DA PROPOSTA COMERCIAL                     *
// Parâmetros: Sem Parâmetros                                                      *
//**********************************************************************************

User Function FT600TOK()
                       
   Local cSql      := ""
   Local _aArea    := GetArea()
   Local lBloqueia := .F.

   Private aBrowse := {}
   Private oDlg

   U_AUTOM628("FT600TOK")

   // Envia para a função que calcula e mostra os valores totais da Proposta Comercial
// U_AUTOM169()
// TOTAL_DA_PROPOSTA()

   // Validação do Tipo e Valor do Frete
// CONS_FRETE()    

   // Envia para a função que calcula o valor do ICMS Retido da Proposta Comercial
// U_PMA410QTG("")

   // Em função da atualização da versão do Protheus realiza no dia 03/11/2014, o Sistema começou, aleatoriamente, a  retornar  um 
   // erro no momento da gravação da proposta comercial. Para corrirgir este problema, estávamos (Harald e Michel) realizando  uma
   // manutenção manual na tabela SCJ onde limpávamos o campo CJ_PROPOST. Com este procedimento o Sistema estava conseguindo gerar
   // a gravação da proposta comercial. Foi colocado neste fonte a limpeza deste campo quando a operação for = a Alteração de Pro-
   // posta Comercial.
   If Altera == .T.
       cSql := ""
       cSql := "UPDATE " + RetSqlName("SCJ") + CHR(13)
       cSql += "   SET " + CHR(13)
       cSql += "   CJ_PROPOST= '' "+ CHR(13)
       cSql += " WHERE CJ_FILIAL   = '" +cFilAnt                 + "'" + CHR(13)
       cSql += "   AND CJ_PROPOST  = '" + Alltrim(M->ADY_PROPOS) + "'" + CHR(13)

       lResult := TCSQLEXEC(cSql)

	 /* dbSelectArea("SCJ")
	  dbSetOrder(4)
	  If dbSeek( cFilAnt +  )
         RecLock("SCJ",.F.)   
         CJ_PROPOST := ""
         MsUnLock()         
      Endif
       */
   Endif

   // Verifica se existe algum produto que tenha no seu grupo a indicação de lacre
   If Select("T_LACRE") > 0
      T_LACRE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ADZ_FILIAL,"
   cSql += "       A.ADZ_PROPOS,"
   cSql += "       A.ADZ_PRODUT,"
   cSql += "       A.ADZ_ITEM  ,"
   cSql += "       A.ADZ_LACRE ,"
   cSql += "       B.B1_GRUPO  ,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       C.BM_LACRE   "
   cSql += "  FROM " + RetSqlName("ADZ") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B, "
   cSql += "       " + RetSqlName("SBM") + " C  "
   cSql += " WHERE A.ADZ_PROPOS = '" + Alltrim(M->ADY_PROPOS) + "'"
   cSql += "   AND A.ADZ_FILIAL = '" + Alltrim(cFilAnt)       + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''"
   cSql += "   AND A.ADZ_PRODUT = B.B1_COD"
   cSql += "   AND B.B1_GRUPO   = C.BM_GRUPO"   
   cSql += "   AND C.BM_LACRE   = 'S'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LACRE", .T., .T. )

   If T_LACRE->( EOF() )
      RestArea( _aArea )
      Return .T.
   Endif
      
   T_LACRE->( DbGoTop() )
   
   WHILE !T_LACRE->( EOF() )
      aAdd( aBrowse, { Alltrim(T_LACRE->ADZ_PRODUT), T_LACRE->ADZ_ITEM, Alltrim(T_LACRE->B1_DESC) + " " + T_LACRE->B1_DAUX, T_LACRE->ADZ_LACRE } )
      T_LACRE->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Indicação de Lacre Automatech" FROM C(178),C(181) TO C(405),C(683) PIXEL

   @ C(004),C(004) Say "Indique se o(s) produto(s) abaixo será(ão) lacrado(s) na Autmatech" Size C(159),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(096),C(167) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg
   @ C(096),C(209) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End(), RestArea( _aArea ) )

   // Desenha o Browse                    >    ^
   oBrowse := TCBrowse():New( 015 , 004, 310, 100,,{'Código', 'Item', 'Descrição dos Produtos', 'Lacre' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04]} }           
                                                              
   ACTIVATE MSDIALOG oDlg CENTERED 

   RestArea( _aArea )

Return(.T.)

// Função que consiste o Tipo e Valor do Frete da Proposta Comercial
Static Function CONS_FRETE()

   Local cSql := ""

   // --------------------------------------------------------------------------------------------------------------------- *
   // Regra para a Consistência                                                                                             *
   // -------------------------                                                                                             *
   // Indicação de Frete CIF somente se o valor da Proposta Comercial for > R$ 1.500,00                                     *
   // Se Cidade do Cliente = Porto Alegre, Frete >= 15,00 e CIF ou Frete = 0 e FOB                                          *
   // Se Cidade do Cliente <> Porto Alegre mas UF = RS, Frete >= 30,00 e CIF ou Frete = 0 e FOB                             *
   // Se Cidade do Cliente fora da UF RS e não for um dos estados da região Norte, Frete >= 45,00 e CIF ou Frete = 00 e FOB *
   // Se Estado for da região Norte, Frete >= 60,00 e CIF ou Frete = 0 e FOB                                                *
   // --------------------------------------------------------------------------------------------------------------------- *

   // Pesquisa os parâmetros de frete
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL," 
   cSql += "       ZZ4_CODI  ,"
   cSql += "       ZZ4_FTOT  ,"
   cSql += "       ZZ4_FNRS  ,"
   cSql += "       ZZ4_FFRS  ,"
   cSql += "       ZZ4_FNNO  ,"
   cSql += "       ZZ4_FRNO   "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return .T.
   Endif

   // Pesquisa dados do cliente para geração da consist~encia do Frete
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_EST , "
   cSql += "       A1_MUN   "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD     = '" + Alltrim(M->ADY_CODIGO) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(M->ADY_LOJA)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   // Regra geral.
   If __TotPropo > T_PARAMETROS->ZZ4_FTOT
      Return .T.
   Endif
      
   If Alltrim(M->ADY_TPFRET) == "F"
      Return .T.
   Endif

   If Alltrim(T_CLIENTE->A1_EST) == "RS"
      If Alltrim(T_CLIENTE->A1_MUN) == "PORTO ALEGRE"
         If Alltrim(M->ADY_TPFRET) == "C"
            If M->ADY_FRETE < T_PARAMETROS->ZZ4_FNRS
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FNRS,10,02)) + ". Valor será ajustado automaticamente.")
               M->ADY_FRETE  := T_PARAMETROS->ZZ4_FNRS
            Endif   
         Endif
      Else
         If Alltrim(M->ADY_TPFRET) == "C"
            If M->ADY_FRETE < T_PARAMETROS->ZZ4_FFRS
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FFRS,10,02)) + ". Valor será ajustado automaticamente.")
               M->ADY_FRETE  := T_PARAMETROS->ZZ4_FFRS
            Endif   
         Endif                    
      Endif
   Else
      If Alltrim(T_CLIENTE->A1_EST)$("RR#AM#AC#RO#PA#AP#TO")
         If Alltrim(M->ADY_TPFRET) == "C"
            If M->ADY_FRETE < T_PARAMETROS->ZZ4_FRNO
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FRNO,10,02)) + ". Valor será ajustado automaticamente.")
               M->ADY_FRETE  := T_PARAMETROS->ZZ4_FRNO
            Endif   
         Endif                    
      Else
         If Alltrim(M->ADY_TPFRET) == "C"
            If M->ADY_FRETE < T_PARAMETROS->ZZ4_FNNO
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FNNO,10,02)) + ". Valor será ajustado automaticamente.")
               M->ADY_FRETE  := T_PARAMETROS->ZZ4_FNNO
            Endif   
         Endif                    
      Endif
   Endif
         
Return .T.

// Função que calcula e mostra o valor total da proposta comercial ao clicar no botão Confirmar da Proposta Comercial
Static Function TOTAL_DA_PROPOSTA()

   Local cSql    := ""
   Local lChumba := .F.
   Local nContar := 0

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

   // Pesquisa os dados da proposta comercial ára cálculo
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

//   cSql := ""
//   cSql := "SELECT A.ADZ_FILIAL,"
//   cSql += "       A.ADZ_PROPOS,"
//   cSql += "       A.ADZ_ITEM  ,"
//   cSql += "       A.ADZ_PRODUT,"
//   cSql += "       A.ADZ_DESCRI,"
//   cSql += "       A.ADZ_QTDVEN,"
//   cSql += "       A.ADZ_MOEDA ,"
//   cSql += "       A.ADZ_PRCVEN,"
//   cSql += "       A.ADZ_TOTAL ,"
//   cSql += "       A.ADZ_TES   ,"                             
//   cSql += "       B.B1_GRUPO  ,"
//   cSql += "       B.B1_DESC   ,"
//   cSql += "       B.B1_DAUX   ,"
//   cSql += "       B.B1_GRTRIB ,"
//   cSql += "       B.B1_ORIGEM  "
//   cSql += "  FROM " + RetSqlName("ADZ") + " A, "
//   cSql += "       " + RetSqlName("SB1") + " B  "
//   cSql += " WHERE A.ADZ_PROPOS = '" + Alltrim(M->ADY_PROPOS) + "'"
//   cSql += "   AND A.ADZ_FILIAL = '" + Alltrim(cFilAnt)       + "'"
//   cSql += "   AND A.D_E_L_E_T_ = ''"
//   cSql += "   AND A.ADZ_PRODUT = B.B1_COD"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

   If T_PROPOSTA->( EOF() )
      Return(.T.)
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
   cSql += " WHERE A1_COD  = '" + Alltrim(M->ADY_CODIGO) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(M->ADY_LOJA)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ESTADO", .T., .T. )

   If T_ESTADO->( EOF() )
      Return(.T.)
   Endif
   
   // Verifica se o Estado da Empresa Logada é diferente do estado do cadastro de clientes
   If Alltrim(T_ESTADO->A1_EST) == Alltrim(SM0->M0_ESTENT)
      Return(.T.)
   Endif

   // Verifica se cliente é F = Consumidor Final
   If Alltrim(T_ESTADO->A1_TIPO) <> "F"
      Return(.T.)
   Endif

   // Calcula os valores para os produtos da proposta comercial                        
   T_PROPOSTA->( dbGoTop() )
   
   WHILE !T_PROPOSTA->( EOF() )

       // Verifica se o TES indicado no produto deve utilizar a excesão fiscal
       If Select("T_TES") > 0
          T_TES->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT F4_INCSOL, "
       cSql += "       F4_ICM     "
       cSql += "  FROM " + RetSqlName("SF4")
       cSql += " WHERE F4_CODIGO  = '" + Alltrim(T_PROPOSTA->CK_TES) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TES", .T., .T. )

       // Verifica o ICM Solidário
       If T_TES->F4_INCSOL <> "S"
          T_PROPOSTA->( DbSkip() )          
          Loop
       Endif

       // Verifica se TES permite calcular ICMS
       If T_TES->F4_ICM <> "S"
          T_PROPOSTA->( DbSkip() )
          Loop
       Endif

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
          T_PROPOSTA->( DbSkip() )
          Loop
       Endif
       
       // Calcula o ICMS ST do produto lido
       If T_ORCAMENTO->CJ_MOEDA == 1

          _ICMBASER := T_PROPOSTA->CK_VALOR

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIBASER := T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST
          Else
             _ALIBASER := T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT
          Endif

          _VALBASER := (_ICMBASER * _ALIBASER) / 100

          _ICMRETIR := T_PROPOSTA->CK_VALOR

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIRETIR := (T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST)
          Else
             _ALIRETIR := (T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT)
          Endif

          _VALRETIR := (_ICMRETIR * _ALIRETIR) / 100

          _PROICMSR := _PROICMSR + T_PROPOSTA->CK_VALOR
          _TOTDIFER := _TOTDIFER + _VALRETIR

       Else   

          _ICMBASED := T_PROPOSTA->CK_VALOR

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIBASED := T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST
          Else
             _ALIBASED := T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT
          Endif

          _VALBASED := (_ICMBASED * _ALIBASER) / 100

          _ICMRETID := T_PROPOSTA->CK_VALOR

          If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
             _ALIRETID := (T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST)
          Else
             _ALIRETID := (T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT)
          Endif

          _VALRETID := (_ICMRETIR * _ALIRETIR) / 100

          _PROICMSD := _PROICMSD + T_PROPOSTA->CK_VALOR
          _TOTDIFED := _TOTDIFED + _VALRETID

       Endif
   
       _DIFICMS := IIF(Alltrim(T_ORCAMENTO->CJ_MOEDA) == '1', _VALRETIR, _VALRETID)

       // Carraga o array aBrowse com o resultado do cálculo
       aAdd( aBrowse, { T_PROPOSTA->CK_FILIAL ,;
                        T_PROPOSTA->CK_ITEM   ,;
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

   xRetiR := _TOTDIFER
   xRetiD := _TOTDIFED

   cGet1 := _PROICMSR
   cGet2 := _TOTDIFER
   cGet3 := _PROICMSR + _TOTDIFER

   cGet4 := _PROICMSD
   cGet5 := _TOTDIFED
   cGet6 := _PROICMSD + _TOTDIFED

   If (xRetiR + xRetiD) == 0
      Return(.T.)
   Endif   

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

   @ C(111),C(305) Button "Continuar ..." Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   oBrowse := TCBrowse():New( 005 , 005, 450, 105,,{'Item', 'Codigo', 'Descrição dos Produtos', 'Qtd', 'Moeda', 'Unitário', 'Sub-Total' , 'Dif. ICMS', 'Total'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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
      oBrowse:bLDblClick := {|| MOSTRAEXE(aBrowse[oBrowse:nAt,02]) } 
   Endif   

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)