//{IX} ================================================================================
//{IX} 000035 = User Function BOLETO()
//{IX} 000352 = Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
//{IX} 000573 = Static Function BbMod10(cData) // Banco do Brasil
//{IX} 000593 = Static Function Mod10_041(cData)
//{IX} 000624 = Static Function Modulo10(cData)
//{IX} 000704 = Static Function Mod10Saf(cData)
//{IX} 000728 = Static Function Mod11_041(cData) //Modulo 11 com base 7
//{IX} 000770 = Static Function Mod11_9(cData) //Modulo 11 com base 9
//{IX} 000797 = Static Function ModSaf(cData) //Modulo 11 com base 7
//{IX} 000825 = Static Function Mod11CB(cData) // Modulo 11 com base 9
//{IX} 000848 = Static Function BBBARRADV(cCampo)
//{IX} 000877 = Static Function NNumDV(xCampo) //Calculo do Digito Verificador do Nosso Numero
//{IX} 000940 = Static Function BbBarraDb(B_Campo)
//{IX} 000963 = Static Function BbLdDv(cCampo)
//{IX} 000990 = Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)
//{IX} 001154 = Static Function EnvMail(cArq)
//{IX} 001213 = Static Function PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
//{IX} ================================================================================
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
///*/
//±± ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?±±
//±± Programa   BOLETO                                    Data  10/08/2012 ±±
//±± ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?±±
//±± Descricao  Impressao de Boletos Bancarios com Codigo de Barras        ±±
//±± ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?±±
///*/
//--------------------------------------------------
// Marcher - Chamado 27384
// Alteracao Impresão boleto Banco do Brasil
// Leef Tecnologia - Paulo Machado - 23/04/18
//--------------------------------------------------
User Function BOLETO()
   LOCAL   lPrimVez   := .T.
   LOCAL  aDadosEmp  := {}
   PRIVATE oPrint
   PRIVATE lGravaNn   := .F.
   PRIVATE lPrint     := .F.
   PRIVATE cPerg      := "BOLETO    "
   PRIVATE nPagNum    := 0
   PRIVATE nTaxaDia   := 0.33333 //GetMv("Mv_TxPer")
   PRIVATE nTaxaMul   := 3
   PRIVATE nVlAtraso  := 0
   PRIVATE xBanco     := ""
   PRIVATE xNumBanco  := ""
   PRIVATE xNomeBanco := ""
   PRIVATE xAgencia   := ""
   PRIVATE xConta     := ""
   PRIVATE xDvConta   := ""
   PRIVATE xCartCob   := ""
   PRIVATE xCodCedente:= ""
   PRIVATE yNumBanco  := ""
   PRIVATE yAgencia   := ""
   PRIVATE yConta     := ""
   PRIVATE xNossoNum  := ""
   PRIVATE yNossoNum  := ""
   PRIVATE _cNossoNum := ""
   PRIVATE xDvNossoNum:= ""
   PRIVATE xMsg1      := ""
   PRIVATE xMsg2      := ""
   PRIVATE cCartNnDvDv:= ""
   PRIVATE cCodCli    := ""
   PRIVATE xEmailTo   := ""
   Private cTabParc   := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   
   // - Verifica se Existem as Perguntas da Rotina, Se n? existirem serao criadas
   //     cGpo ,cOrd,cPergunt               ,  ,  ,cVa     ,cTp,nT,nD,nP,cGSC,cVal,cF3  ,cGrpSxg,cPyme,cVar01    ,cDef01        ,cDefSpa1,cDefEng1,cCnt01,cDef02        ,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)
   /*PutSx1(cPerg,"01","Da Data Vencimento ?" ,"","","mv_ch1","D",08,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR01",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"02","Até Data Vencimento ?","","","mv_ch2","D",08,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR02",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"03","Do Prefixo ?"         ,"","","mv_ch3","C",03,00,00,"G" ,""  ,"SE1",""     ,""   ,"MV_PAR03",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"04","Do Titulo ?"          ,"","","mv_ch4","C",09,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR04",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"05","Da Parcela ?"         ,"","","mv_ch5","C",01,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR05",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"06","Do Tipo ?"            ,"","","mv_ch6","C",03,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR06",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"07","Até o Prefixo ?"      ,"","","mv_ch7","C",03,00,00,"G" ,""  ,"SE1",""     ,""   ,"MV_PAR07",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"08","Até o Titulo ?"       ,"","","mv_ch8","C",09,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR08",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"09","Até a Parcela ?"      ,"","","mv_ch9","C",01,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR09",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"10","Até Tipo ?"           ,"","","mv_cha","C",03,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR10",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"11","Usar Banco ?"         ,"","","mv_chb","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR11","Cad Cliente" ,""      ,""      ,""    ,"Informado  " ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"12","Banco ?"              ,"","","mv_chc","C",03,00,00,"G" ,""  ,"SA6",""     ,""   ,"MV_PAR12",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"13","Agencia ?"            ,"","","mv_chd","C",05,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR14",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"14,"Conta ?"              ,"","","mv_che","C",05,00,00,"G" ,""  ,""   ,""     ,""   ,"MV_PAR14",""            ,""      ,""      ,""    ,""            ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"15","Vencimento ?"         ,"","","mv_chf","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR15","Do Titulo   ",""      ,""      ,""    ,"Apresentação",""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   PutSx1(cPerg,"16","Envia p/ E-mail?"     ,"","","mv_chg","N",01,00,00,"C" ,""  ,""   ,""     ,""   ,"MV_PAR16","Sim"         ,""      ,""      ,""    ,"Não"         ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""      ,""      ,""      ,"")
   */
   // - Di?ogo dos Parametros de impressao, for cancelado nao segue adiante a Rotina
   If !Pergunte("BOLETO    ",.T.)
      Return
   EndIf
   SM0->(DbSeek(cEmpAnt+cFilAnt))
   aDadosEmp  := { SM0->M0_NOMECOM,;           //[1]Nome da Empresa
   SM0->M0_ENDCOB,;           //[2]Endere? cobranca
   AllTrim(SM0->M0_BAIRCOB) + ", " + ;
   AllTrim(SM0->M0_CIDCOB)  + ", " + ;
   SM0->M0_ESTCOB,;         //[3]Complemento
   "CEP: " + Transform(SM0->M0_CEPCOB,"@R 99.999-999"),;  //[4]CEP
   "PABX/FAX: " + SM0->M0_TEL,;        //[5]Telefones
   Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),;    //[6]CNPJ
   "I.E.: " + Transform(SM0->M0_INSC,"@R 999/99999999999"),;  //[7]Insc Estadual
   SM0->M0_ENDENT,; //[8]  Endereco
   SM0->M0_CIDENT,; //[9]  Cidade
   SM0->M0_ESTENT}  //[10] Estado
   cQuery := "SELECT E1_TIPO, E1_VALOR, E1_PREFIXO, E1_NUM, E1_CLIENTE, E1_LOJA, E1_PARCELA, "
   cQuery +=       " E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_NUMBCO, E1_PORTADO, "
   cQuery +=       " E1_IRRF, E1_ISS, E1_INSS, E1_PIS, E1_COFINS, E1_CSLL "
   cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
   cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
   cQuery += "AND   E1_PREFIXO BETWEEN '" +      MV_PAR03  + "' "
   cQuery += "AND                      '" +      MV_PAR07  + "' "
   cQuery += "AND   E1_NUM     BETWEEN '" +      MV_PAR04  + "' "
   cQuery += "AND                      '" +      MV_PAR08  + "' "
   cQuery += "AND   E1_PARCELA BETWEEN '" +      MV_PAR05  + "' "
   cQuery += "AND                      '" +      MV_PAR09  + "' "
   cQuery += "AND   E1_TIPO    BETWEEN '" +      MV_PAR06  + "' "
   cQuery += "AND                      '" +      MV_PAR10  + "' "
   cQuery += "AND   E1_VENCREA BETWEEN '" + DtoS(MV_PAR01) + "' "
   cQuery += "AND                      '" + DtoS(MV_PAR02) + "' "
   cQuery += "AND   SE1.D_E_L_E_T_ = ' '  "
   cQuery += "ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_SE1",.T.,.T.)
   TCSetField("T_SE1","E1_EMISSAO","D",08,00)
   TCSetField("T_SE1","E1_VENCTO" ,"D",08,00)
   TCSetField("T_SE1","E1_VENCREA","D",08,00)
   TCSetField("T_SE1","E1_IRRF"   ,"N",14,02)
   TCSetField("T_SE1","E1_ISS"    ,"N",14,02)
   TCSetField("T_SE1","E1_INSS"   ,"N",14,02)
   TCSetField("T_SE1","E1_PIS"    ,"N",14,02)
   TCSetField("T_SE1","E1_COFINS" ,"N",14,02)
   TCSetField("T_SE1","E1_CSLL"   ,"N",14,02)
   TCSetField("T_SE1","E1_VALOR"  ,"N",14,02)
   DbSelectArea("T_SE1")
   //Count to nReg
   DbGoTop()
   Do While !EOF()

      If lPrimVez
         lPrimVez := .F.
         oPrint:=TMSPrinter():New( "Boleto Bancario" )
         oPrint:SetPortrait() // ou SetLandscape()
         oPrint:Setup()
      EndIf

      DbSelectArea("SA1")
      DbSetOrder(1)
      If !DbSeek(xFilial("SA1")+T_SE1->E1_CLIENTE+T_SE1->E1_LOJA)
         DbSelectArea("T_SE1")
         T_SE1->(DBSKIP())
         Loop
      EndIf
      aDatSacado := {}
      cCodCli    := AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA)
      If !Empty(SA1->A1_ENDCOB)
         aDatSacado :=  {AllTrim(SA1->A1_NOME),;                        // [1]Raz? Social
         AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;                  // [2]C?igo
         AllTrim(SA1->A1_ENDCOB )+" - "+AllTrim(SA1->A1_BAIRROC),;  // [3]Endere?
         AllTrim(SA1->A1_MUNC ),;                                  // [4]Cidade
         SA1->A1_ESTC,;                                            // [5]Estado
         SA1->A1_CEPC,;                                            // [6]CEP
         SA1->A1_CGC}                        // [7]CGC
      Else
         aDatSacado :=  {AllTrim(SA1->A1_NOME),;                     // [1]Raz? Social
         AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;               // [2]C?igo
         AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),;  // [3]Endere?
         AllTrim(SA1->A1_MUN ),;                                // [4]Cidade
         SA1->A1_EST,;                                          // [5]Estado
         SA1->A1_CEP,;                                          // [6]CEP
         SA1->A1_CGC}                     // [7]CGC
      EndIf
      If MV_PAR11 = 1
         If !Empty(SA1->A1_BCO1)
            DbSelectArea("SA6")
            DbSetOrder(1)
            If !DbSeek(xFilial("SA6")+SA1->A1_BCO1)
               DbSelectArea("T_SE1")
               T_SE1->(DBSKIP())
               Loop
            EndIf
         Else
            Alert("Cliente sem Banco de Cobranca Cadastrado !")
            DbSelectArea("T_SE1")
            DbCloseArea()
            Return
         EndIf
      Else
         If !Empty(MV_PAR12)
            DbSelectArea("SA6")
            DbSetOrder(1) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON 
            If !DbSeek(xFilial("SA6")+MV_PAR12+MV_PAR13+MV_PAR14)
               DbSelectArea("T_SE1")
               T_SE1->(DBSKIP())
               Loop
            EndIf
         Else
            Alert("Informe Banco de Cobranca !")
            DbSelectArea("T_SE1")
            DbCloseArea()
            Return
         EndIf
      EndIf
      xBanco     := SA6->A6_COD
      xEmailTo   := SA1->A1_EMAIL
      yNumBanco  := SA6->A6_COD
      yAgencia   := SA6->A6_AGENCIA
      yConta     := SA6->A6_NUMCON
      If xBanco == "341"
         xMsg1      := "ATE O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU"
         xMsg2      := "APOS O VENCIMENTO PAGUE SOMENTE NO ITAU"
      Else
         xMsg1      := "PAGAVEL EM QUALQUER BANCO ATE O VENCIMENTO"
         xMsg2      := "APOS O VENCIMENTO, SOMENTE NO " + xNomeBanco
      EndIf
      xMensg1    := "FAVOR EFETUAR O PAGAMENTO SOMENTE ATRAVES DESTA COBRANCA BANCARIA"
      xMensg2    := "PROTESTAR APOS 5 DIAS DO VENCIMENTO"
      If  xBanco = "001"
         xNomeBanco  := "BANCO DO BRASIL"   // 24/04/18 LEEF
         xNumBanco   := "0019"
         xCartCob    := "17"
         xCodCedente := "2763538"
         xAgencia    := "0883"
         xDVAgencia  := "4"
         xConta      := "4217"
         xDVConta    := "X"
      ElseIf xBanco = "041"
         xNomeBanco  := "BANRISUL"
         xNumBanco   := "0418"
         xCartCob    := "109"
         xCodCedente := ""
         xConta      := ""
         xDVConta    := ""
         xAgencia    := ""
         xDVAgencia  := ""
      ElseIf xBanco = "237"
         xNomeBanco  := "BRADESCO"
         xNumBanco   := "2372"
         xCartCob    := "09"
         xCodCedente := ""
         xConta      := ""
         xDVConta    := ""
         xAgencia    := ""
         xDVAgencia  := ""
      ElseIf xBanco = "341"
         xNomeBanco  := "BANCO ITAU SA"
         xNumBanco   := "3417"
         xCartCob    := "109"
         xCodCedente := "111123"
         xConta      := "11112"
         xDVConta    := "3"
         xAgencia    := "6616"
         xDVAgencia  := ""
      EndIf

      aDadosBanco  := { xNumBanco,;   // [1]Numero do Banco
      xNomeBanco,;  // [2]Nome do Banco
      xAgencia,;    // [3]Ag?cia
      xConta,;      // [4]Conta Corrente
      xDvConta,;    // [5]D?ito da conta corrente
      xCartCob,;    // [6]Codigo da Carteira
      xCodCedente } // [7]Codigo Cedente
      DbSelectArea("SEE")
      DbSetOrder(1)
      If   xBanco  = "341" .or. xBanco  = "001"
         If !DbSeek(xFilial("SEE")+yNumBanco+yAgencia+yConta+"001")
            Alert("Conta Cobranca Sem Parametros !")
            Set Century Off
            DbSelectArea("T_SE1")
            DbCloseArea()
            Return
         EndIf
         // Jean Rehermann -Solutio IT - 26/06/2018 - Alteração para compatibilizar a numeração bancária
         If xBanco  == "341"
	         nFaixaAtu := Right(AllTrim(SEE->EE_FAXATU),8)
	     Else
         	nFaixaAtu := AllTrim(SEE->EE_FAXATU)
         EndIf
         nFaixaIni :=     Val(SEE->EE_FAXINI)
         nFaixaFin :=     Val(SEE->EE_FAXFIM)
      EndIf
      // - Verifica se e reimpressao carrega o mesmo conteudo para o Nosso Numero
      lGravaNn := .T.
      DbSelectArea("T_SE1")
      If !Empty(T_SE1->E1_PARCELA)
         nPos := AT(T_SE1->E1_PARCELA,cTabParc)
         cParcela := StrZero(nPos,2)
      Else
         cParcela := "00"
      EndIf
      If   xBanco = "001"
         If  T_SE1->E1_PORTADO <> "001"
            xNossoNum := nFaixaAtu
            yNossoNum := _cNossoNum := xNossoNum
         Else
            xNossoNum := Left(T_SE1->E1_NUMBCO,11)
            yNossoNum := _cNossoNum := xNossoNum
            lGravaNn := .F.
         EndIf
      ElseIf  xBanco = "041"
         xNossoNum := _cNossoNum := StrZero(Val(T_SE1->E1_NUM),6) + cParcela
      ElseIf  xBanco = "237"
         xNossoNum := _cNossoNum := "000" + StrZero(Val(T_SE1->E1_NUM),6) + cParcela
      ElseIf  xBanco = "341"
         If  T_SE1->E1_PORTADO <> "341" // Primeira impressão para este banco
            xNossoNum := nFaixaAtu
            _cNossoNum := xNossoNum
         Else // Reimpressão de boleto
         
            // chamado 27441 - koliveira - 05/04/2018 : Inserida a função substring para a busca ndo nosso n?ero.
            //pois no caso do banco Itau s? usados apenas 8 digitos.
            //xNossoNum := Left(T_SE1->E1_NUMBCO, 8)
            
            // Jean Rehermann - Solutio IT - 26/06/2018 - Alteração para compatibilizar o nosso número bancário
            xNossoNum := Right(AllTrim(T_SE1->E1_NUMBCO),8)
            _cNossoNum := xNossoNum
            lGravaNn := .F.
         EndIf
      EndIf

      DbSelectArea("T_SE1")
      _nVlrAbat := T_SE1->E1_IRRF + T_SE1->E1_PIS + T_SE1->E1_COFINS + T_SE1->E1_CSLL
      //         Codigo Banco         Agencia C.Corrente     Digito C/C    Carteira
      CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],_cNossoNum,T_SE1->E1_VALOR-_nVlrAbat)
      aDadosTit    := { " " + AllTrim(T_SE1->E1_NUM) + " " + AllTrim(T_SE1->E1_PARCELA),;  // [1] Numero do titulo
      T_SE1->E1_EMISSAO                               ,;  // [2] Data da emiss? do t?ulo
      Date()                                    ,;  // [3] Data da emiss? do boleto
      T_SE1->E1_VENCREA        ,;  // [4] Data do vencimento
      T_SE1->E1_VALOR         ,;  // [5] Valor do t?ulo
      CB_RN_NN[3]          ,;  // [6] Nosso n?ero (Ver f?mula para calculo)
      T_SE1->E1_PREFIXO                               ,;  // [7] Prefixo da NF
      T_SE1->E1_TIPO                                 ,;  // [8] Tipo do Titulo
      T_SE1->E1_IRRF                              ,;  // [9] IRRF
      T_SE1->E1_ISS                               ,;  // [10] ISS
      T_SE1->E1_INSS                                  ,;  // [11] INSS
      T_SE1->E1_PIS                                   ,;  // [12] PIS
      T_SE1->E1_COFINS                                ,;  // [13] COFINS
      T_SE1->E1_CSLL                                ,;  // [14] CSLL
      _nVlrAbat }           // [15] Abatimentos
      nVlAtraso := ( ( ( aDadosTit[5] - aDadosTit[15] ) * nTaxaDia ) / 100 )
      nVlMulta  := ( ( ( aDadosTit[5] - aDadosTit[15] ) * nTaxaMul ) / 100 )
      aBolText  := {}
      aAdd( aBolText, " APOS VENCIMENTO COBRAR JUROS DE R$ " + AllTrim(Transform(nVlAtraso,"@E 9,999.99") ) + " AO DIA " )
      aAdd( aBolText, " APOS VENCIMENTO COBRAR MULTA DE R$ " + AllTrim(Transform(nVlMulta,"@E 9,999.99") ) )
      aAdd( aBolText, xMensg1 )
      aAdd( aBolText, xMensg2 )
      aAdd( aBolText, "" )
      aAdd( aBolText, "" )
      aAdd( aBolText, "" )
      aAdd( aBolText, "" )
      aAdd( aBolText, "" )
      //" VALOR DO DESCONTO/ABATIMENTO DE R$ " + AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),; //[1]   29/03/12 - Rodolpho Bandeira
      aBMP := {}
      Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
      DbSelectArea("T_SE1")
      lPrint := .T.
      T_SE1->(DBSKIP())
   EndDo
   DbSelectArea("T_SE1")
   DbCloseArea()
   If lPrint
      oPrint:Preview()     // Visualiza antes de imprimir
   EndIf
Return Nil
///*
//Impress? do boleto gr?ico com c?igo de barras
//*/
Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
   //Par?etros de TFont.New()
   //1.Nome da Fonte (Windows)
   //3.Tamanho em Pixels
   //5.Bold (T/F)
   Local oFont6  := TFont():New("Arial"      ,9,6 ,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont6b := TFont():New("Arial"      ,9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont8a := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont8c := TFont():New("Courier New",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont18c:= TFont():New("Courier New",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont10 := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont10N:= TFont():New("Arial"      ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont16 := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont16n:= TFont():New("Arial"      ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont24 := TFont():New("Arial"      ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFontW  := TFont():New("Wingdings"  ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   LOCAL i := 0
   LOCAL oBrush
   nPagNum++
   Set Century On
   oPrint:StartPage()   // Inicia uma nova p?ina
   nInd   := 0
   nLinha := 130
   For nInd := 1 To 3
      oPrint:Line (nLinha + 0000,0100,nLinha + 0000,2300)
      oPrint:Line (nLinha + 0000,0550,nLinha - 0070,0550)
      oPrint:Line (nLinha + 0000,0800,nLinha - 0070,0800)
      //oPrint:Say  (nLinha - 0066,0100,aDadosBanco[2],oFont16) // [2]Nome do Banco
      If     xBanco = "104"
         oPrint:SayBitmap(nLinha - 0085,0120,"104.bmp",340,80) // Logotipo do Banco
      ElseIf xBanco = "341"
         oPrint:SayBitmap(nLinha - 0085,0120,"341.bmp",310,80) // Logotipo do Banco
      ElseIf xBanco = "001"  // leef 24/04/18
         oPrint:SayBitmap(nLinha - 0085,0120,"001.bmp",310,80) // Logotipo do Banco
      Else
         oPrint:Say  (nLinha - 0066,0100,aDadosBanco[2],oFont16) // [2]Nome do Banco
      EndIf
      oPrint:Say  (nLinha - 0088,0567,Left(aDadosBanco[1],3)+"-"+Right(aDadosBanco[1],1),oFont24) // [1]Numero do Banco
      oPrint:Line (nLinha + 0100,0100,nLinha + 0100,2300)
      oPrint:Line (nLinha + 0200,0100,nLinha + 0200,2300)
      oPrint:Line (nLinha + 0270,0100,nLinha + 0270,2300)
      oPrint:Line (nLinha + 0340,0100,nLinha + 0340,2300)
      oPrint:Line (nLinha + 0200,0500,nLinha + 0340,0500)
      oPrint:Line (nLinha + 0270,0750,nLinha + 0340,0750)
      oPrint:Line (nLinha + 0200,1000,nLinha + 0340,1000)
      oPrint:Line (nLinha + 0200,1350,nLinha + 0270,1350)
      oPrint:Line (nLinha + 0200,1550,nLinha + 0340,1550)
      oPrint:Say  (nLinha + 0000,0100,"Local Pagamento"                                ,oFont8c)
      oPrint:Say  (nLinha + 0020,0400,xMsg1                                            ,oFont8a)
      oPrint:Say  (nLinha + 0060,0400,xMsg2                                            ,oFont8a)
      oPrint:Say  (nLinha + 0000,1910,"Vencimento"                                     ,oFont6)
      If MV_PAR15 = 1
         oPrint:Say  (nLinha + 0040,1890,PadL(DTOC(aDadosTit[4]),20)                  ,oFont8a)
      Else
         oPrint:Say  (nLinha + 0040,1890,PadL("Apresentação",20)                      ,oFont8a)
      EndIf
      oPrint:Say  (nLinha + 0100,0100,"Cedente"                                        ,oFont6)
      oPrint:Say  (nLinha + 0100,1355,"CNPJ"                                           ,oFont6)
      oPrint:Say  (nLinha + 0100,1910,"Agência/Código Cedente"                         ,oFont6)
      oPrint:Say  (nLinha + 0160,0100,"Endereço:"                                        ,oFont6)
      oPrint:Say  (nLinha + 0200,0100,"Data do Documento"                              ,oFont6)
      oPrint:Say  (nLinha + 0230,0100,DTOC(aDadosTit[2])                               ,oFont8a) // Emissao do Titulo (E1_EMISSAO)
      oPrint:Say  (nLinha + 0200,0505,"Nro.Documento"                                  ,oFont6)
      oPrint:Say  (nLinha + 0230,0605,aDadosTit[7]+aDadosTit[1]       ,oFont8a) //Prefixo +Numero+Parcela
      oPrint:Say  (nLinha + 0200,1005,"Espécie Doc."                                   ,oFont6)
      oPrint:Say  (nLinha + 0230,1050,"DM"                                             ,oFont8a) //Tipo do Titulo
      oPrint:Say  (nLinha + 0200,1355,"Aceite"                                         ,oFont6)
      oPrint:Say  (nLinha + 0230,1455,"N"                                              ,oFont8a)
      oPrint:Say  (nLinha + 0200,1555,"Data do Processamento"                          ,oFont6)
      oPrint:Say  (nLinha + 0230,1655,DTOC(aDadosTit[3])                               ,oFont8a) // Data impressao
      oPrint:Say  (nLinha + 0200,1910,"Nosso Número"                                   ,oFont6)
      If     xBanco = "001"
         oPrint:Say  (nLinha + 0230,1890,PadL(xNossoNum + "-" + xDvNossoNum,20),oFont8a)
         oPrint:Say  (nLinha + 0140,1890,PadL(xAgencia+"-"+xDvAgenciasiga+"/"+xConta+"-"+xDvConta,20),oFont8a)
         oPrint:Say  (nLinha + 0120,0100,aDadosEmp[1]              ,oFont8a) //Nome
         oPrint:Say  (nLinha + 0120,1380,aDadosEmp[6]              ,oFont8a) //CNPJ
      ElseIf xBanco = "041"
         oPrint:Say  (nLinha + 0140,0100,aDadosEmp[1]              ,oFont8a) //Nome
         oPrint:Say  (nLinha + 0140,1380,aDadosEmp[6]              ,oFont8a) //CNPJ
         oPrint:Say  (nLinha + 0140,1890,PadL(xAgencia+xDvAgencia+"/"+xCodCedente,20),oFont8a)
         oPrint:Say  (nLinha + 0230,1890,PadL(xNossoNum + "-" + xDvNossoNum,20),oFont8a)
      ElseIf xBanco = "237"
         oPrint:Say  (nLinha + 0230,1890,PadL(xCartCob + "/" + xNossoNum + "-" + xDvNossoNum,20),oFont8a)
         oPrint:Say  (nLinha + 0140,1890,PadL(xAgencia+"-"+xDvAgencia+"/"+xConta+"-"+xDvConta,20),oFont8a)
         oPrint:Say  (nLinha + 0140,0100,aDadosEmp[1]              ,oFont8a) //Nome
         oPrint:Say  (nLinha + 0140,1380,aDadosEmp[6]              ,oFont8a) //CNPJ
      ElseIf xBanco = "341"
         oPrint:Say  (nLinha + 0230,1890,PadL(xCartCob + "/" + xNossoNum + "-" + xDvNossoNum,20),oFont8a)
         oPrint:Say  (nLinha + 0140,1890,PadL(xAgencia+"-"+xdvAgencia+"/"+xConta+"-"+xDvConta,20),oFont8a)
         oPrint:Say  (nLinha + 0120,0100,aDadosEmp[1]              ,oFont6b) //Nome
         oPrint:Say  (nLinha + 0120,1380,aDadosEmp[6]              ,oFont6b) //CNPJ
         oPrint:Say  (nLinha + 0160,0200,RTRIM(aDadosEmp[8]) +SPACE(2)+ "-" +SPACE(2)+ RTRIM(aDadosEmp[9]) +SPACE(2)+ "-" +SPACE(2)+ aDadosEmp[10] ,oFont6b) // Endereco 21/03/12 - adicionado endereco para cumprimento da Lei 12039 - Rodolpho
      EndIf
      oPrint:Say  (nLinha + 0270,0100,"Uso do Banco"                                   ,oFont6)
      oPrint:Say  (nLinha + 0270,0505,"Carteira"                                       ,oFont6)
      oPrint:Say  (nLinha + 0300,0555,aDadosBanco[6]                                 ,oFont8a)
      oPrint:Say  (nLinha + 0270,0755,"Espécie"                                        ,oFont6)
      oPrint:Say  (nLinha + 0300,0805,"R$"                                             ,oFont8a)
      oPrint:Say  (nLinha + 0270,1005,"Quantidade"                                     ,oFont6)
      oPrint:Say  (nLinha + 0270,1555,"Valor"                                          ,oFont6)
      oPrint:Say  (nLinha + 0270,1910,"Valor do Documento"                           ,oFont6)
      oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),20),oFont8a)
      oPrint:Say  (nLinha + 0340,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont6)
      oPrint:Say  (nLinha + 0390,0100,aBolText[1]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0440,0100,aBolText[2]           ,oFont8a)
      oPrint:Say  (nLinha + 0490,0100,aBolText[3]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0540,0100,aBolText[4]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0590,0100,aBolText[5]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0490,1400,aBolText[6]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0540,1400,aBolText[7]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0590,1400,aBolText[8]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0640,0100,aBolText[9]                                      ,oFont8a)
      oPrint:Say  (nLinha + 0340,1910,"(-)Desconto/Abatimento"                         ,oFont6)
      If aDadosTit[15] > 0
         oPrint:Say  (nLinha + 0370,2010,Padl(AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),20),oFont8a)
         oPrint:Say  (nLinha + 0650,2010,Padl(AllTrim(Transform(aDadosTit[5] - aDadosTit[15],"@E 999,999,999.99")),20),oFont8a)
      Endif
      oPrint:Say  (nLinha + 0410,1910,"(-)Outras Deduções"                             ,oFont6)
      oPrint:Say  (nLinha + 0480,1910,"(+)Mora/Multa"                                  ,oFont6)
      oPrint:Say  (nLinha + 0550,1910,"(+)Outros Acréscimos"                           ,oFont6)
      oPrint:Say  (nLinha + 0620,1910,"(=)Valor Cobrado"                               ,oFont6)
      oPrint:Say  (nLinha + 0690,0100,"Sacado"                                         ,oFont6)
      oPrint:Say  (nLinha + 0700,0300,aDatSacado[1]+" ("+aDatSacado[2]+") - " + TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") ,oFont8a)
      oPrint:Say  (nLinha + 0735,0300,aDatSacado[3]                                    ,oFont8a)
      oPrint:Say  (nLinha + 0770,0300,Transform(aDatSacado[6],"@R 99.999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont8a) // CEP+Cidade+Estado
      oPrint:Say  (nLinha + 0818,0100,"Sacador/Avalista"                             ,oFont6)
      // oPrint:Say  (nLinha + 0850,1500,"Autenticação Mec?ica"                        ,oFont8a)
      oPrint:Line (nLinha + 0000,1900,nLinha + 0690,1900)
      oPrint:Line (nLinha + 0410,1900,nLinha + 0410,2300)
      oPrint:Line (nLinha + 0480,1900,nLinha + 0480,2300)
      oPrint:Line (nLinha + 0550,1900,nLinha + 0550,2300)
      oPrint:Line (nLinha + 0620,1900,nLinha + 0620,2300)
      oPrint:Line (nLinha + 0690,0100,nLinha + 0690,2300)
      oPrint:Line (nLinha + 0840,0100,nLinha + 0840,2300)
      If     nInd = 1
         oPrint:Say  (nLinha - 0070,2000,"Recibo do Sacado",oFont10)
         oPrint:Say  (nLinha + 0850,1500,"Autenticação Mecânica",oFont8a)
         nLinha += 1065
      ElseIf nInd = 2
         oPrint:Say  (nLinha - 0070,2030,"Ficha de Caixa",oFont10)
         oPrint:Say  (nLinha + 0850,1500,"Autenticação Mecânica",oFont8a)
         oPrint:Say  (nLinha - 0140,0100,"#",oFontW)
         For i := 100 to 2300 step 10
            oPrint:Line( nLinha - 0100, i, nLinha - 0100, i+5)
         Next i
         nLinha += 1065
      ElseIf nInd = 3
         oPrint:Say  (nLinha - 0140,0100,"#",oFontW)
         For i := 100 to 2300 step 10
            oPrint:Line( nLinha - 0100, i, nLinha - 0100, i+5)
         Next i
         oPrint:Say  (nLinha - 0066,0820,CB_RN_NN[2],oFont16n) // Linha Digitavel do Codigo de Barras
         oPrint:Say  (nLinha + 0850,1500,"Autenticação Mecânica - Ficha de Compensação",oFont8a)
         //    CODIGO DE BARRAS PARA CONFERENCIA
         //   oPrint:Say  (nLinha + 0460,0100,CB_RN_NN[2],oFont18C) // Linha Digitavel do Codigo de Barras
         //   oPrint:Say  (nLinha + 0510,0100,CB_RN_NN[1],oFont18C)
         //   oPrint:Say  (nLinha + 0560,0100,"12345678901234567890123456789012345678901234",oFont18C)
         //   oPrint:Say  (nLinha + 0610,0100,"         1         2         3         4    ",oFont18C)
      EndIf
      ///*
      //cTeste := CB_RN_NN[2]+Chr(13)+Chr(10)+CB_RN_NN[1]
      //Memowrite("teste.txt",cTeste)
      //*/
   Next
   ///*
   //oPrint:Say  (nLinha + 1090,0100,"#",oFontW)
   //For i := 100 to 2300 step 10
   //oPrint:Line( nLinha - 1130, i, nLinha - 1130, i+5)
   //Next i
   //*/
   //MSBAR3("INT25",12.8,0.5,CB_RN_NN[1],oPrint,.F.,,,,1.3,,,,.F.)
   //MSBAR3("INT25",13.3,0.5,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)  // p impressoras lexmark //Original!!!
   //MSBAR3("INT25",22.8,0.5,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)  // p impreessoras dif de lexmark         
   IF xBanco=='001'
      MSBAR3("INT25",20.4,0.8,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)  // p impressoras lexmark
   else   
      MSBAR3("INT25",26.4,0.8,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)  // p impressoras lexmark
   endif   
   ///*
   //oPrint:Say  (nLinha - 0140,0100,"#",oFontW)
   //For i := 100 to 2300 step 10
   //oPrint:Line( nLinha - 0100, i, nLinha - 0100, i+5)
   //Next i
   //*/
   If lGravaNn
      DbSelectArea("SE1")
      DbSetOrder(1)
      If DbSeek(xFilial("SE1") + T_SE1->E1_PREFIXO + T_SE1->E1_NUM + T_SE1->E1_PARCELA + T_SE1->E1_TIPO)
         RecLock("SE1",.F.)
         If   xBanco $ "001/341"
            SE1->E1_PORTADO := xBanco
            // Jean Rehermann - Solutio IT - 26/06/2018 - Alteraçao para compatibilizar o nosso número bancário
            If   xBanco == "341"
            	SE1->E1_NUMBCO  := "0"+ xNossoNum
            Else
	            SE1->E1_NUMBCO  := xNossoNum + xDvNossoNum
            EndIf
            MsUnLock()
            DbSelectArea("SEE")
            DbSetOrder(1)
            DbSeek(xFilial("SEE")+yNumBanco+yAgencia+yConta+"001")
            RecLock("SEE",.F.)
            yNossoNum := SOMA1(AllTrim(SEE->EE_FAXATU))
            SEE->EE_FAXATU := yNossoNum
            MsUnLock()
         ElseIf  xBanco = "041"
            SE1->E1_PORTADO := "041"
            SE1->E1_NUMBCO  := xNossoNum + xDvNossoNum
            MsUnLock()
         ElseIf  xBanco = "237"
            SE1->E1_PORTADO := "237"
            SE1->E1_NUMBCO  := xCartCob + xNossoNum + xDvNossoNum
            MsUnLock()
         EndIf
      EndIf
   EndIf
   oPrint:EndPage() // Finaliza a p?ina
   If MV_PAR16 = 1      
      If Iw_MsgBox("Enviar o Boleto: " + T_SE1->E1_PREFIXO + " " + T_SE1->E1_NUM + " " + T_SE1->E1_PARCELA + " " + T_SE1->E1_TIPO + Chr(13) + Chr(10) + ;
         "Para o e-mail: " + AllTrim(xEmailTo) + " ? ","Envio de Boleto por E-mail","YESNO")
         oPrint:SaveAllAsJpeg('\impgraf.jpg',640,900)
         cArq := '\impgraf.jpg_Pag' + AllTrim( Str( nPagNum ) ) + '.jpg'
         EnvMail(cArq)
      EndIf
   EndIf
Return Nil
///*/
//C?culo do m?ulo 10
///*/
Static Function BbMod10(cData) // Banco do Brasil
   nCont := 0
   nPeso := 9
   For i := Len(cData) To 1 Step -1
      nCont := nCont + (Val(SUBSTR(cData,i,1))) * nPeso
      nPeso := nPeso - 1
      If nPeso == 1
         nPeso := 9
      Endif
   Next
   Resto := ( nCont % 11 )
   If Resto < 10
      cDv := Str(Resto,1)
   Else
      cDv := "X"
   EndIf
Return(cDv)
///*
//-------------------------------------------------------------------------------------------
//*/
Static Function Mod10_041(cData)
   Local L,D,P
   L := Len(cdata)
   D := 0
   P := 2
   N := 0
   Do While L > 0
      N := (Val(SubStr(cData, L, 1)) * P)
      If N > 9
         D := D + (N - 9)
      Else
         D := D + N
      Endif
      If P = 2
         P := 1
      Elseif P = 1
         P := 2
      EndIf
      L := L - 1
   EndDo
   If D > 10
      D := Mod(D,10)
   EndIf
   D := 10 - D
   If D == 10
      D := 0
   EndIf
Return(D)
///*
//-------------------------------------------------------------------------------------------
//*/
Static Function Modulo10(cData)
   Local L,D,P := 0
   Local B     := .F.
   L := Len(cData)
   B := .T.
   D := 0
   do while L > 0
      P := Val(SubStr(cData, L, 1))
      If (B)
         P := P * 2
         If P > 9
            P := P - 9
         End
      End
      D := D + P
      L := L - 1
      B := !B
   EndDo
   D := 10 - (Mod(D,10))
   If D = 10
      D := 0
   End
   ///*LOCAL L, D, P, nInt := 0
   //L := Len(cdata)
   //D := 0
   //P := 2
   //N := 0
   //
   //Do While L > 0
   //N := (Val(SubStr(cData, L, 1)) * P)
   //If N > 9
   //D := D + (N - 9)
   //Else
   //D := D + N
   //Endif
   //If P = 2
   //P := 1
   //Elseif P = 1
   //P := 2
   //EndIf
   //L := L - 1
   //EndDo
   //D := Mod(D,10)
   //D := 10 - D
   //If D == 10
   //D:=0
   //Endif   */
Return(D)
///*
////nova
//Static Function Modulo10(cData)
//
//Local L,D,P := 0
//Local B     := .F.
//L := Len(cData)
//B := .T.
//D := 0
//do while L > 0
//P := Val(SubStr(cData, L, 1))
//If (B)
//P := P * 2
//If P > 9
//P := P - 9
//End
//End
//D := D + P
//L := L - 1
//B := !B
//EndDo
//
//D := 10 - (Mod(D,10))
//
//If D = 10
//D := 0
//End
//
//Return(D)*/
///*
//-------------------------------------------------------------------------------------------
//*/
Static Function Mod10Saf(cData)
   LOCAL L, D, P, nInt := 0
   L := Len(cdata)
   D := 0
   P := 2
   N := 0
   Do While L > 0
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If   P = 2
         P := 1
      Elseif  P = 1
         P := 2
      EndIf
      L := L - 1
   EndDo
   nResto := Mod(D,10)
   Dv := 10 - nResto
   If Dv = 10
      Dv := 0
   Endif
Return(Dv)
///*/
//C?culo do m?ulo 11
///*/
Static Function Mod11_041(cData) //Modulo 11 com base 7
   Local L, D, P := 0
   x := cData
   Do While .T.
      L := Len(cdata)
      D := 0
      P := 1
      DV:= " "
      nResto := 0
      Do While L > 0
         P := P + 1
         D := D + (Val(SubStr(cData, L, 1)) * P)
         If P = 7  //Volta para o inicio, ou seja comeca a multiplicar por 7,6,5...
            P := 1
         End
         L := L - 1
      EndDo
      If D > 11
         nResto := mod(D,11)  //Resto da Divisao
      Else
         nResto := D
      EndIf
      If   nResto = 0
         DV  := 0
         Exit
      ElseIf nResto = 1
         DV  := 0
         If Right(cData,1) = "9"
            cData = Left(cData,Len(cData)-1) + "0"
         Else
            cData = Left(cData,Len(cData)-1) + StrZero((Val(Right(cData,1))+1),1)
         EndIf
      Else
         DV  := (11 - nResto)
         Exit
      EndIf
   EndDo
   cRet := cData + AllTrim(Str(DV,1,0))
Return(cRet)
///*
//------------------------------------------------------------------------------------------
//*/
Static Function Mod11_9(cData) //Modulo 11 com base 9
   LOCAL L, D, P := 0
   L := Len(cdata)
   D := 0
   P := 1
   DV:= " "
   nResto := 0
   Do While L > 0
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 9  //Volta para o inicio, ou seja comeca a multiplicar por 9,8,7...
         P := 1
      End
      L := L - 1
   EndDo
   nResto := mod(D,11)  //Resto da Divisao
   If   nResto = 0
      DV := 1
   ElseIf nResto = 1
      DV := 0
   Else
      DV := (11 - nResto)
   EndIf
Return(DV)
///*
//------------------------------------------------------------------------------------------
//*/
Static Function ModSaf(cData) //Modulo 11 com base 7
   LOCAL L, D, P := 0
   L := Len(AllTrim(cdata))
   D := 0
   P := 1
   DV:= " "
   nResto := 0
   Do While L > 0
      P := P + 1
      D := D + (Val(SubStr(cData, L, 1)) * P)
      If P = 7  //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
         P := 1
      End
      L := L - 1
   End
   nResto := mod(D,11)  //Resto da Divisao
   If   nResto = 0
      DV := "0"
   ElseIf nResto = 1
      DV := "P"
   Else
      DV := (11 - nResto)
      DV := AllTrim(Str(DV))
   EndIf
Return(DV)
///*/
//Modulo 11 CB
///*/
Static Function Mod11CB(cData) // Modulo 11 com base 9
   LOCAL CBL, CBD, CBP := 0
   CBL := Len(cdata)
   CBD := 0
   CBP := 1
   Do While CBL > 0
      CBP := CBP + 1
      CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
      If CBP = 9
         CBP := 1
      End
      CBL := CBL - 1
   EndDo
   _nCBResto := mod(CBD,11)  //Resto da Divisao
   CBD := 11 - _nCBResto
   If (CBD == 0 .Or. CBD == 1 .Or. CBD == 10 .Or. CBD == 11)
      CBD := 1
   End
Return(CBD)
///*
//O c?culo padronizado do DAC ?o m?ulo 11, com peso de 2 a 9, utilizando o d?ito 1 (um) para os restos  0, 10 ou 1 (zero, dez ou um);
//Para o c?culo, considerar as posições de 1 a 4  e de 6 a 44, iniciando pela posição 44 .
//*/
Static Function BBBARRADV(cCampo)
   nCont := 0
   nPeso := 2
   For I := 43 To 1 Step -1
      nCont := nCont + ( Val( SubStr( cCampo,I,1 )) * nPeso )
      nPeso := nPeso + 1
      If nPeso >  9
         nPeso := 2
      EndIf
   Next
   Resto  := ( nCont % 11 )
   If Resto = 10 .Or. Resto = 1 .Or. Resto = 0
      cDvBarra := "1"
   Else
      Result   := ( 11 - Resto )
      cDvBarra := Str(Result,1)
   EndIf
   ///*
   //If Result == 10 .Or. Result == 11
   //cDvBarra := "1"
   //Else
   //cDvBarra := Str(Result,1)
   //EndIf
   //*/
Return(cDvBarra)
///*
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------
//*/
Static Function NNumDV(xCampo) //Calculo do Digito Verificador do Nosso Numero
   lPeso1  := .F.
   nCont   := 0
   cCampo  := xCampo
   For i := Len( cCampo ) To 1 Step -1
      If lPeso1
         nVal  := Val( SubStr( cCampo, i, 1 ) )
         nCont += nVal
      Else
         nVal  := Val( SubStr( cCampo, i, 1 ) ) * 2
         If nVal > 9
            nCont += ( nVal - 9 )
         Else
            nCont += nVal
         EndIf
      EndIf
      lPeso1 := !lPeso1
   Next
   If nCont < 10
      Resto := nCont
   Else
      Resto := ( nCont % 10 )
   EndIf
   If Resto == 0
      DV_NNUM := "0"
   Else
      Resto := 10 - Resto
      DV_NNUM := Str( Resto, 1 )
   EndIf
   // calcular o segundo digito verificador...
   // calculo atraves do modulo 11
   Do While .t.
      cCampo := xCampo + DV_NNUM
      nCont := 0
      nPeso := 2
      For i := Len( cCampo ) to 1 Step -1
         nCont += Val( SubStr( cCampo, i, 1 ) ) * nPeso
         nPeso ++
         If nPeso == 8
            nPeso := 2
         EndIf
      Next
      If nCont < 11
         Resto := nCont
      Else
         Resto := ( nCont % 11 )
      EndIf
      If Resto == 1
         If DV_NNUM  == "9"
            DV_NNUM := "0"
         Else
            DV_NNUM := Str ( Val( DV_NNUM ) + 1, 1 )
         EndIf
         Loop
      ElseIf Resto == 0
         DV_NNUM += "0"
      Else
         Resto := 11 - Resto
         DV_NNUM += Str( Resto, 1 )
      EndIf
      Exit
   EndDo
Return (DV_NNUM)
Static Function BbBarraDb(B_Campo)
   Local nCont := 0
   Local cPeso := 2
   Local Resto
   Local Result
   Local DV_BARRA
   // Banco do Brasil
   For i := 43 To 1 Step -1
      nCont := nCont + ( Val( SUBSTR( B_Campo,i,1 )) * cPeso )
      cPeso := cPeso + 1
      If cPeso >  9
         cPeso := 2
      Endif
   Next
   Resto  := ( nCont % 11 )
   Result := ( 11 - Resto )
   Do Case
      Case Result == 10 .or. Result == 11
         DV_BARRA := "1"
         OtherWise
         DV_BARRA := Str(M->Result,1)
   EndCase
Return(DV_BARRA)
Static Function BbLdDv(cCampo)
   // Banco do Brasil
   nCont  := 0
   Peso   := 2
   For i := Len(cCampo) to 1 Step -1
      If Peso == 3
         Peso := 1
      Endif
      If Val(SUBSTR(cCampo,i,1))*Peso >= 10
         nVal  := Val(SUBSTR(Pedaco,i,1)) * Peso
         nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
      Else
         nCont:=nCont+(Val(SUBSTR(Pedaco,i,1))* Peso)
      Endif
      Peso := Peso + 1
   Next
   Dezena  := Substr(Str(nCont,2),1,1)
   Resto   := ( (Val(Dezena)+1) * 10) - nCont
   If Resto   == 10
      cDigito := "0"
   Else
      cDigito := Str(Resto,1)
   EndIf
Return(cDigito)
///*/
//Retorna Linha Digitavel, Linha Codigo Barras e Nosso Numero
///*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)
   LOCAL bldocnufinal := AllTrim(_cNossoNum)
   LOCAL blvalorfinal := strzero(nValor*100,10)
   LOCAL dvnn         := 0
   LOCAL dvcb         := 0
   LOCAL dv           := 0
   LOCAL NN           := ''
   LOCAL RN           := ''
   LOCAL CB           := ''
   LOCAL s            := ''
   Local dDtBase    := ctod("07/10/1997")
   Local cFatorVencto := ""
   //Calculo do Fator de Vencimento do Titulo
   cFatorVencto := Str(T_SE1->E1_VENCREA - dDtBase,4)
   // - Montagem do Nosso Numero
   If   xBanco = "001"
      snn  := bldocnufinal     // Nosso Numero
      dvnn := BbMod10(snn)    // Digito verificador no Nosso Numero
      NN   := BlDocNuFinal + AllTrim(dvnn)
      xDvNossoNum := AllTrim(dvnn)
   ElseIf  xBanco = "041"
      snn  := bldocnufinal     // Nosso Numero
      dvnn := Mod10_041(snn)    // Digito verificador no Nosso Numero
      //  _dvnn := Mod11_041(snn+AllTrim(Str(dvnn,1,0)))    // Digito verificador no Nosso Numero
      NN   := Mod11_041(snn+AllTrim(Str(dvnn,1,0)))
      //  NN   := BlDocNuFinal + AllTrim(Str(dvnn)) + AllTrim(Str(_dvnn))
      //  xDvNossoNum := AllTrim(Str(dvnn)) + AllTrim(Str(_dvnn))
      xDvNossoNum := Right(NN,2)
   ElseIf  xBanco = "237"
      snn  := bldocnufinal     // Nosso Numero
      dvnn := ModSaf(cCarteira + snn)  // Digito verificador no Nosso Numero
      NN   := cCarteira + BlDocNuFinal + AllTrim(dvnn)
      xDvNossoNum := AllTrim(dvnn)
   ElseIf xBanco = "341"
      snn  := xAgencia + SubStr(xConta,1,5) + cCarteira + bldocnufinal     // Agencia + Conta + Carteira + Nosso Numero
      dvnn := modulo10(snn)    // Digito verificador no Nosso Numero
      NN   := cCarteira + BlDocNuFinal + AllTrim(Str(dvnn))
      xDvNossoNum := AllTrim(Str(dvnn))
   EndIf
   // - MONTAGEM DOS DADOS PARA O CODIGO DE BARRAS
   If   xBanco = "001" // Banco do Brasil
      //Compor a barra sem o Digito verificador
      // ajustado por Paulo Machado - Leef Tecnologia - 25/04/18
      scb :=  "001"    + /*01-03 banco*/;
      "9"              + /*04-04 moeda*/;
      cFatorVencto     + /*06-09 fator*/;
      blvalorfinal     + /*10-19 valor*/;
      "000000"         + /*20-25 zeros*/;
      xCodCedente      + /*26-32 ceden*/;
      left(bldocnufinal,10)+ /*33-42 nnume*/;
      xCartCob           /*43-44 cartei*/
      //Calculo do Digito do Codigo de Barras
      cDDV := BbBarraDv(scb)
      //Compor a barra com o Digito verificador
      CB   :=  "001"   + /*01-03 banco*/;
      "9"              + /*04-04 moeda*/;
      cDDV             + ;
      cFatorVencto     + /*06-09 fator*/;
      blvalorfinal     + /*10-19 valor*/;
      "000000"         + /*20-25 zeros*/;
      xCodCedente      + /*26-32 ceden*/;
      left(bldocnufinal,10)+ /*33-42 nnume*/;
      xCartCob           /*43-44 cartei*/
   ElseIf  xBanco = "041" // Banrisul
      cLivre:="21"                +;
      "670"               +;
      Left(xCodCedente,7) +;
      bldocnufinal        +;
      "041"
      nDvCl1 := Mod10_041(cLivre)
      cLivre := Mod11_041(cLivre+AllTrim(Str(nDvCl1)))
      //Compor a barra para calcular o DAC
      cb   := "041"               +;
      "9"                 +;
      cFatorVencto        +;
      blvalorfinal        +;
      cLivre
      //Calculo do Digito do Codigo de Barras
      cDDV := BbBarraDv(cb)
      //Compor a barra com o Digito verificador
      cb   := "041"               +;
      "9"                 +;
      cDDV                +;
      cFatorVencto        +;
      blvalorfinal        +;
      cLivre
   ElseIf  xBanco = "237" // Bradesco
      scb  := cBanco + "9" + cFatorVencto + blvalorfinal + cAgencia + cCarteira + _cNossoNum + "00" + cConta + "0"
      dvcb := mod11CB(scb) //digito verificador do codigo de barras
      CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
   ElseIf  xBanco = "341" // Itau
      scb  := cBanco + "9" + cFatorVencto + blvalorfinal + NN + cAgencia + cConta + cDacCC + "000"
      dvcb := mod11CB(scb) //digito verificador do codigo de barras
      CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)
   EndIf
   // - Montagem da Linha Digitavel
   If   xBanco = "001" // Banco do Brasil
      nDigito := ""
      Pedaco  := ""
      //Primeiro Campo
      //Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
      Pedaco  := Substr(CB,01,03) + Substr(CB,04,01) + Substr(CB,20,5)
      cDigito := BbLdDv(Pedaco)
      cCampo1 :=  Substr(CB,1,3) + Substr(CB,4,1) + Substr(CB,20,1) + "." +;
      Substr(CB,21,4) + cDigito + Space(2)
      //Segundo Campo
      Pedaco  := Substr(CB,25,10)
      nDigito := BbLdDv(Pedaco)
      cCampo2 := Substr(Pedaco,1,5) + "." + Substr(Pedaco,6,5) + cDigito + Space(2)
      //Terceiro Campo
      Pedaco  := Substr(CB,35,10)
      nDigito := BbLdDv(Pedaco)
      cCampo3 := Substr(Pedaco,1,5) + "." + Substr(Pedaco,6,5) + cDigito + Space(2)
      //Quarto Campo
      cCampo4 := cDDV + Space(2)
      //Quinto Campo
      cCampo5  := cFatorVencto + blvalorfinal
      RN := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5
   ElseIf  xBanco = "041" // Banrisul
      srn := xBanco + "921670"
      dv1:= AllTrim(Str(mod10_041(srn)))
      srn := Left(xCodCedente,7) + Left(xNossoNum,3)
      dv2 := AllTrim(Str(mod10_041(srn)))
      srn := Right(xNossoNum,5) + "041" + Right(cb,2)
      dv3 := AllTrim(Str(mod10_041(srn)))
      Campo1 := xBanco + "92.1670" + dv1
      Campo2 := Left(xCodCedente,5) + "." + SubStr(xCodCedente,6,2) + Left(xNossoNum,3) + dv2
      Campo3 := Right(xNossoNum,5) + "." + "041" + Right(cb,2) + dv3
      Campo4 := cDDV + "  " + cFatorVencto + StrZero((nValor * 100),10)
      RN := Campo1 + " " + Campo2 + " " + Campo3 + "  " + Campo4
   ElseIf  xBanco = "237" // Bradesco
      srn := cBanco + "9" + cAgencia + SubStr(cCarteira,1,1)
      dv := modulo10(srn)
      RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4) + AllTrim(Str(dv)) + ' '
      srn := SubStr(cCarteira,2,1) + SubsTr(bldocnuFinal,1,9) // posicao 6 a 15 do campo livre
      dv := modulo10(srn)
      RN := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5) + AllTrim(Str(dv)) + ' '
      srn := SubsTr(bldocnuFinal,10,2) + cConta + "0"         // posicao 16 a 25 do campo livre
      dv := modulo10(srn)
      RN := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '
      RN := RN + AllTrim(Str(dvcb)) + ' '
      RN := RN + cFatorVencto + StrZero((nValor * 100),10)
   ElseIf  xBanco = "341" // Itau
      srn := cBanco + "9" + cCarteira + SubsTr(BlDocNuFinal,1,2)
      dv := modulo10(srn)
      RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4) + AllTrim(Str(dv)) + ' '
      srn := SubsTr(bldocnuFinal,3) + (AllTrim(Str(DvNN))) + SubsTr(cAgencia,1,3) // posicao 6 a 15 do campo livre
      dv := modulo10(srn)
      RN := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,6) + AllTrim(Str(dv)) + ' '
      srn := SubsTr(cAgencia,4,1) + cConta + cDacCC + "000" // posicao 16 a 25 do campo livre
      dv := modulo10(srn)
      RN := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '
      RN := RN + AllTrim(Str(dvcb)) + ' '
      RN := RN + cFatorVencto + StrZero((nValor * 100),10)
   EndIf
Return({CB,RN,NN})
///*
//--------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------
//*/
///*
//Envia e-mail
//*/
Static Function EnvMail(cArq)
   Local cServer   := ALLTRIM(GETMV("MV_RELSERV"))
   Local cAccount  := ALLTRIM(GETMV("MV_RELACNT"))
   Local cPassword := ALLTRIM(GETMV("MV_RELPSW"))
   Local lAuth     := GETMV("MV_RELAUTH")
   Local cAssunto  := "Boleto Bancário - E-Partner"
   Local cMensagem := ""
   Local cEmailTo  := xEmailTo
   Local lResult   := .F.
   Local cError    := ""
   Local cEmailFrom:= ALLTRIM(GETMV("MV_RELACNT"))
   Local cCRLF     := Chr(13) + Chr(10)
   cMensagem := 'Envio de Boleto Bancário' + cCRLF
   cMensagem += '' + cCRLF
   cMensagem += '' + cCRLF
   cMensagem += 'Aviso Legal' + cCRLF
   cMensagem += '' + cCRLF
   cMensagem += '' + cCRLF
   cMensagem += 'Esta mensagem eletrônica pode conter informações privilegiadas e/ou confidenciais, ' + cCRLF
   cMensagem += 'portanto fica o seu receptor notificado de que qualquer disseminação, distribuição ou ' + cCRLF
   cMensagem += 'cópia não autorizada é estritamente proibida. Se você entende que recebeu esta mensagem ' + cCRLF
   cMensagem += 'indevidamente ou por engano, por favor informe este fato ao remetente e a apague de seu computador.' + cCRLF
   CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
   If lResult .And. lAuth
      lResult := MailAuth(cAccount,cPassword)
      If !lResult
         GET MAIL ERROR cError
         Conout("Erro de autenticacao "+cError)
         Return Nil
      Endif
   Else
      If !lResult
         GET MAIL ERROR cError
         Conout("Erro de conexao com servidor SMTP "+cError)
         Return Nil
      Endif
   EndIf
   aArqTxt := {}
   AADD(aArqTxt,cArq)
   If lResult
      SEND MAIL FROM cAccount;
      TO cEmailTo;
      SUBJECT cAssunto;
      BODY cMensagem;
      ATTACHMENT aArqTxt[1];
      RESULT lResult
      If !lResult
         GET MAIL ERROR cError
         Conout("Erro no envio do e-mail  " + cError)
      EndIf
      DISCONNECT SMTP SERVER
   Else
      Conout('Ocorreu um erro durante o envio do Email!')
   EndIf
   If File(cArq)
      Delete File (cArq)
   EndIf
Return(lResult)
//*********************************************************************
Static Function PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
   cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
   cF3, cGrpSxg,cPyme,;
   cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
   cDef02,cDefSpa2,cDefEng2,;
   cDef03,cDefSpa3,cDefEng3,;
   cDef04,cDefSpa4,cDefEng4,;
   cDef05,cDefSpa5,cDefEng5,;
   aHelpPor,aHelpEng,aHelpSpa,cHelp)
   
   /*LOCAL aArea := GetArea()
   Local cKey
   Local lPort := .f.
   Local lSpa  := .f.
   Local lIngl := .f.
   cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
   cPyme    := Iif( cPyme   == Nil, " ", cPyme  )
   cF3      := Iif( cF3   == NIl, " ", cF3  )
   cGrpSxg  := Iif( cGrpSxg == Nil, " ", cGrpSxg )
   cCnt01   := Iif( cCnt01  == Nil, "" , cCnt01  )
   cHelp  := Iif( cHelp  == Nil, "" , cHelp  )
   dbSelectArea( "SX1" )
   dbSetOrder( 1 )
   // Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
   // RFC - 15/03/2007
   cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
   If !( DbSeek( cGrupo + cOrdem ))
      cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
      cPerSpa := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
      cPerEng := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
      Reclock( "SX1" , .T. )
      Replace X1_GRUPO   With cGrupo
      Replace X1_ORDEM   With cOrdem
      Replace X1_PERGUNT With cPergunt
      Replace X1_PERSPA  With cPerSpa
      Replace X1_PERENG  With cPerEng
      Replace X1_VARIAVL With cVar
      Replace X1_TIPO    With cTipo
      Replace X1_TAMANHO With nTamanho
      Replace X1_DECIMAL With nDecimal
      Replace X1_PRESEL  With nPresel
      Replace X1_GSC     With cGSC
      Replace X1_VALID   With cValid
      Replace X1_VAR01   With cVar01
      Replace X1_F3      With cF3
      Replace X1_GRPSXG  With cGrpSxg
      If Fieldpos("X1_PYME") > 0
         If cPyme != Nil
            Replace X1_PYME With cPyme
         Endif
      Endif
      Replace X1_CNT01   With cCnt01
      If cGSC == "C"   // Mult Escolha
         Replace X1_DEF01   With cDef01
         Replace X1_DEFSPA1 With cDefSpa1
         Replace X1_DEFENG1 With cDefEng1
         Replace X1_DEF02   With cDef02
         Replace X1_DEFSPA2 With cDefSpa2
         Replace X1_DEFENG2 With cDefEng2
         Replace X1_DEF03   With cDef03
         Replace X1_DEFSPA3 With cDefSpa3
         Replace X1_DEFENG3 With cDefEng3
         Replace X1_DEF04   With cDef04
         Replace X1_DEFSPA4 With cDefSpa4
         Replace X1_DEFENG4 With cDefEng4
         Replace X1_DEF05   With cDef05
         Replace X1_DEFSPA5 With cDefSpa5
         Replace X1_DEFENG5 With cDefEng5
      Endif
      Replace X1_HELP  With cHelp
      PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
      MsUnlock()
   Else
      lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
      lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
      lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
      If lPort .Or. lSpa .Or. lIngl
         RecLock("SX1",.F.)
         If lPort
            SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
         EndIf
         If lSpa
            SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
         EndIf
         If lIngl
            SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
         EndIf
         SX1->(MsUnLock())
      EndIf
   Endif   */

   RestArea( aArea )
Return                                           
