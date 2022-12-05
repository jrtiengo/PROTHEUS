#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: FT600LOK.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/10/2012                                                          *
// Objetivo..: Ponto de Entrada disparado na seleção do botão Confirmar da Propos- *
//             ta Comercial e sempre que houver informação de produtos.            *
//**********************************************************************************

User Function FT600LOK()
                                                     
   U_AUTOM628("FT600LOK")

   // Envia para a função que carrega a variável pública __TotPropo com o valor total da Proposta Comercial
   CAR_TOTPROPO()
   
   // Envia para a função que consiste o % de Comissão do produto
   CAR_COMISSAO()

   U_AUTOM162("PC", "C")

   // ################################################################################
   // Envia para a função que calcula a margem do produto informado                 ##
   // U_QTGPROP()                                                                   ##    
   // Rotina não mais será executada conforme orientação do Sr. Roger em 03/01/2017 ##
   // ################################################################################

Return (.T.)

// Função que carrega o valor total da proposta comercial para a variável pública __TotPropo
Static Function CAR_TOTPROPO()

   Local nPosicao := 0
   Local nContar  := 0
   Local nTotal   := 0
   
   // Pesquisa o valor total da proposta comercial
   For nPosicao = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosicao,02]) == "ADZ_TOTAL"
          Exit
       Endif
   Next nPosicao

   __TotPropo := 0

   For nContar = 1 to Len(aCols)
       __TotPropo := __TotPropo + aCols[nContar,nPosicao]
   Next nContar

Return .T.       

// Função que consiste o % de comissão do produto
Static Function CAR_COMISSAO()

   Local cSql          := ""
   Local cComissao     := 0
   Local cBaseComi     := 0
   Local nContar       := 0
   Local nposItem      := 0
   Local nPosProdu     := 0
   Local nPosNome      := 0
   Local nPosComis     := 0
   Local _dar_mensagem := .F.
   Local xArea         := ""   
   Local aCamposAD1    := {}
   Local nContar       := 0


   Private cOpcao      := ""

   Private oComissao

   Private aComissao   := {}

   // Cria variáveis de memória do registro da oportunidade
   If TYPE("M->AD1_VEND") == "U"
      RegToMemory("AD1", (cOpcao=="INCLUIR"))

//      // Inicializa as variáveis
//      xArea := GetArea("AD1")
//      DbSelectArea("AD1")
//      DbSetOrder(1)
//      If DbSeek(xFilial("AD1") + cOportunidade)
//         M->AD1_FILIAL := AD1->AD1_FILIAL 
//         M->AD1_NROPOR := AD1->AD1_NROPOR 
//         M->AD1_REVISA := AD1->AD1_REVISA 
//         M->AD1_DESCRI := AD1->AD1_DESCRI 
//         M->AD1_DTINI  := AD1->AD1_DTINI 
//         M->AD1_DTFIM  := AD1->AD1_DTFIM 
//         M->AD1_VEND   := AD1->AD1_VEND 
//         M->AD1_DATA   := AD1->AD1_DATA 
//         M->AD1_PROSPE := AD1->AD1_PROSPE 
//         M->AD1_LOJPRO := AD1->AD1_LOJPRO 
//         M->AD1_HORA   := AD1->AD1_HORA 
//         M->AD1_CODCLI := AD1->AD1_CODCLI 
//         M->AD1_LOJCLI := AD1->AD1_LOJCLI 
//         M->AD1_MOEDA  := AD1->AD1_MOEDA 
//         M->AD1_PROVEN := AD1->AD1_PROVEN 
//         M->AD1_STAGE  := AD1->AD1_STAGE 
//         M->AD1_PRIOR  := AD1->AD1_PRIOR 
//         M->AD1_STATUS := AD1->AD1_STATUS 
//         M->AD1_USER   := AD1->AD1_USER 
//         M->AD1_VERBA  := AD1->AD1_VERBA 
//         M->AD1_FCS    := AD1->AD1_FCS 
//         M->AD1_FCI    := AD1->AD1_FCI 
//         M->AD1_NUMORC := AD1->AD1_NUMORC 
//         M->AD1_CODMEM := AD1->AD1_CODMEM 
//         M->AD1_MODO   := AD1->AD1_MODO 
//         M->AD1_COMUNI := AD1->AD1_COMUNI 
//         M->AD1_CODTMK := AD1->AD1_CODTMK 
//         M->AD1_CANAL  := AD1->AD1_CANAL 
//         M->AD1_ENCERR := AD1->AD1_ENCERR 
//         M->AD1_TABELA := AD1->AD1_TABELA 
//         M->AD1_DTPFIM := AD1->AD1_DTPFIM 
//         M->AD1_MEMENC := AD1->AD1_MEMENC 
//         M->AD1_PROPOS := AD1->AD1_PROPOS 
//         M->AD1_FEELIN := AD1->AD1_FEELIN 
//         M->AD1_COMIS1 := AD1->AD1_COMIS1 
//         M->AD1_VEND2  := AD1->AD1_VEND2 
//         M->AD1_COMIS2 := AD1->AD1_COMIS2 
//         M->AD1_FRETE  := AD1->AD1_FRETE 
//         M->AD1_OC     := AD1->AD1_OC 
//      Endif
//      RestArea(xArea)
   Endif

   // Pesquisa o tipo de Vendedor
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD  , "
   cSql += "       A3_TIPOV  "
   cSql += "  FROM " + RetSqlName("SA3")

   If TYPE("M->AD1_VEND") == "U"
      cSql += " WHERE A3_COD = '" + Alltrim(cVendedor1) + "'"
   Else
      cSql += " WHERE A3_COD = '" + Alltrim(M->AD1_VEND) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
   
   If T_VENDEDOR->( EOF() )
      Return 0
   Endif
   
   // Pesquisa parametrizador Automatech para capturar o % de comissão para os Gerentes de Venda
   If Select("T_PARAMETRO") > 0
      T_PARAMETRO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_COMIS FROM " + RetSqlName("ZZ4010")
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETRO", .T., .T. )

   If T_PARAMETRO->( EOF() )
      cBaseComi := 0
   Else
      cBaseComi := T_PARAMETRO->ZZ4_COMIS
   Endif      

   // Pesquisa a posição do campo produtoo valor total da proposta comercial
   For nPosItem = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosItem,02]) == "ADZ_ITEM"
          Exit
       Endif
   Next nPosItem

   For nPosProdu = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosProdu,02]) == "ADZ_PRODUT"
          Exit
       Endif
   Next nPosProdu

   For nPosNome = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosNome,02]) == "ADZ_DESCRI"
          Exit
       Endif
   Next nPosNome

   For nPosComis = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosComis,02]) == "ADZ_COMIS1"
          Exit
       Endif
   Next nPosComis

   // Consiste a comissão
   For nContar = 1 to Len(aCols)

       // Pesquisa o Grupo do Produto
       If Select("T_GRUPO") > 0
          T_GRUPO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A.B1_GRUPO, "
       cSql += "       B.BM_GRUPO, "
       cSql += "       B.BM_COMIS  "
       cSql += "  FROM " + RetSqlName("SB1") + " A, " 
       cSql += "       " + RetSqlName("SBM") + " B  "
       cSql += " WHERE A.B1_GRUPO   = B.BM_GRUPO"
       cSql += "   AND A.B1_COD     = '" + Alltrim(aCols[nContar,nPosProdu]) + "'"
       cSql += "   AND A.D_E_L_E_T_ = ''"
       cSql += "   AND B.D_E_L_E_T_ = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )
   
       If !T_GRUPO->( EOF() )
          cComissao := T_GRUPO->BM_COMIS
       Endif   

       // Verifica se existe exceção de comissão para o produto   
       If Select("T_COMISSAO") > 0
          T_COMISSAO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZ5_GRUPO , "
       cSql += "       ZZ5_PRODUT, "
       cSql += "       ZZ5_COMIS   "
       cSql += "  FROM " + RetSqlName("ZZ5")
       cSql += " WHERE ZZ5_GRUPO  = '" + Alltrim(T_GRUPO->B1_GRUPO)        + "'"
       cSql += "   AND ZZ5_PRODUT = '" + Alltrim(aCols[nContar,nPosProdu]) + "'"
       cSql += "   AND ZZ5_DELETE = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

       If !T_COMISSAO->( EOF() )
          If T_VENDEDOR->A3_TIPOV == "1"
             cComissao := T_COMISSAO->ZZ5_COMIS
          Else
             If cBaseComi == 0
                cComissao := T_COMISSAO->ZZ5_COMIS         
             Else
                cComissao := Round(((T_COMISSAO->ZZ5_COMIS * cBaseComi) / 100),2)
             Endif   
          Endif
       Else
          If T_VENDEDOR->A3_TIPOV == "1"
             cComissao := T_GRUPO->BM_COMIS
          Else
             If cBaseComi == 0      
                cComissao := T_GRUPO->BM_COMIS      
             Else
                cComissao := Round(((T_GRUPO->BM_COMIS * cBaseComi) / 100),2)
              Endif
          Endif   
       Endif

       If aCols[nContar,nPosComis] > cComissao
          aAdd( aComissao, { aCols[nContar,nPosItem] ,;
                             aCols[nContar,nPosProdu],;
                             aCols[nContar,nPosNome] ,;
                             Str(aCols[nContar,nPosComis],06,02),;
                             Str(cComissao,06,02) } )
          _dar_mensagem := .T.
       Endif
       
   Next nContar    

   // #####################################################################
   // No dia 29/12/2016, o Sr. Roger solicitou a retirada desta mensagem ##
   // #####################################################################
//   If _dar_mensagem 
//
//      DEFINE MSDIALOG oComissao TITLE "Consistência % Comissão" FROM C(178),C(181) TO C(465),C(833) PIXEL
//
//      @ C(005),C(005) Say "Atenção ! Foi verificado que existem produtos com divergência da informação do % de comissão da Proposta Comercial." Size C(285),C(008) COLOR CLR_BLACK PIXEL OF oComissao
//      @ C(014),C(005) Say "Serão atualizados os percentuais de comissão automaticamente conforme demonstrativo abaixo."                         Size C(236),C(008) COLOR CLR_BLACK PIXEL OF oComissao
//
//      @ C(128),C(283) Button "Continuar ..." Size C(037),C(012) PIXEL OF oComissao ACTION( SaiComis(nPosItem, nPosProdu, nPosComis) )
//
//      oBrowse := TCBrowse():New( 025 , 005, 400, 135,,{'Item', 'Código', 'Descrição dos Produtos', 'Comissão Informada', 'Comissão Parametrizada'},{20,50,50,50},oComissao,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
//   
//      // Seta vetor para a browse                            
//      oBrowse:SetArray(aComissao) 
//    
//      // Monta a linha a ser exibina no Browse
//      oBrowse:bLine := {||{ aComissao[oBrowse:nAt,01],;
//                            aComissao[oBrowse:nAt,02],;
//                            aComissao[oBrowse:nAt,03],;
//                            aComissao[oBrowse:nAt,04],;
//                            aComissao[oBrowse:nAt,05],;
//                          } }
//
//      ACTIVATE MSDIALOG oComissao CENTERED 
//
//   Endif   
   
Return(.T.)

// Função que sai da tela de informação de comissões
Static Function SAICOMIS( _PosItem, _PosCodi, _PosComi)

   Local _Contar  := 0
   Local _Corrige := 0
   
   For _Contar = 1 to Len(aComissao)
   
       For _Corrige = 1 to Len(aCols)
       
           If aCols[_Corrige,_PosItem] == aComissao[_Contar,01] .And. aCols[_Corrige,_PosCodi] == aComissao[_Contar,02]
              aCols[_Corrige,_PosComi] := VAL(aComissao[_Contar,05])
              Exit
           Endif
           
       Next _Corrige
       
   Next _Contar
   
   oComissao:End()
   
Return(.T.)