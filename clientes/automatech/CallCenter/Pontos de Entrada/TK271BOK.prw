#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: TK271BOK.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 09/11/2012                                                          *
// Objetivo..: Ponto de entrada disparado antes da grava��o do Atendimento do      *
//             Call Center.                                                        *
//             O objetivo � verificar se o Atendimento de Call Center j� possui um *
//             Pedido de Venda associado. Se tiver, n�o  permite  usu�rio realizar *
//             altera��es no Atendimento.                                          *
// Par�metros: Sem Par�metros                                                      *
//**********************************************************************************

User Function TK271BOK()

   Local cSql := ""

   If UPPER(Alltrim(Substr( FUNNAME(), 1, 7 ))) <> "TMKA271"
      Return .T.
   Endif

   If Select("T_VERIFICA") <>  0
      T_VERIFICA->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT UA_NUMSC5"
   cSql += "  FROM " + RetSqlName("SUA")
   cSql += " WHERE UA_FILIAL  = '" + Alltrim(xfilial("SUA")) + "'"
   cSql += "   AND UA_NUM     = '" + Alltrim(M->UA_NUM)      + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_VERIFICA",.T.,.T.)

   If !T_VERIFICA->( EOF() )
      
      If !Empty(Alltrim(T_VERIFICA->UA_NUMSC5))
         MsgAlert("Aten��o!" + chr(13) + chr(10) + chr(13) + chr(10) + "Atendimento j� possui Pedido de Venda gerado (PV N� " + Alltrim(T_VERIFICA->UA_NUMSC5) + ")." + chr(13) + chr(10) + chr(13) + chr(10)+ "Altera��o n�o ser� efetivada.")
         Return(.F.)
      Endif
      
   Endif
   
   // Consiste COmiss�es
// CC_COMISSAO()

   // Verifica se o cliente informado no atendimento possui pend�ncias financeiras na sa�da do atendimento
   U_AUTOM156(M->UA_CLIENTE, M->UA_LOJA, 2)
   
Return(.T.)

// Fun��o que consiste o % de comiss�o do produto no Pedido de Venda
Static Function CC_COMISSAO()

   Local cSql          := ""
   Local cComissao     := 0
   Local cBaseComi     := 0
   Local nContar       := 0
   Local nposItem      := 0
   Local nPosProdu     := 0
   Local nPosNome      := 0
   Local nPosComis     := 0
   Local _dar_mensagem := .F.
   Local lPrimeiro     := .T.

   Private oComissao

   Private aComissao   := {}

   If Empty(Alltrim(M->UA_VEND))
      Return(.T.)
   Endif

   // Pesquisa o tipo de Vendedor
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD  , "
   cSql += "       A3_TIPOV  "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_COD = '" + Alltrim(M->UA_VEND) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
   
   If T_VENDEDOR->( EOF() )
      Return(.T.)
   Endif
   
   // Pesquisa parametrizador Automatech para capturar o % de comiss�o para os Gerentes de Venda
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

   // Pesquisa a posi��o do campo produtoo valor total da proposta comercial
   For nPosItem = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosItem,02]) == "UB_PRODUTO"
          Exit
       Endif
   Next nPosItem

   // Consiste a comiss�o
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
       cSql += "   AND A.B1_COD     = '" + Alltrim(aCols[nContar,nPosItem]) + "'"
       cSql += "   AND A.D_E_L_E_T_ = ''"
       cSql += "   AND B.D_E_L_E_T_ = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )
   
       If !T_GRUPO->( EOF() )
          cComissao := T_GRUPO->BM_COMIS
       Endif   

       // Verifica se existe exce��o de comiss�o para o produto   
       If Select("T_COMISSAO") > 0
          T_COMISSAO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZ5_GRUPO , "
       cSql += "       ZZ5_PRODUT, "
       cSql += "       ZZ5_COMIS   "
       cSql += "  FROM " + RetSqlName("ZZ5")
       cSql += " WHERE ZZ5_GRUPO  = '" + Alltrim(T_GRUPO->B1_GRUPO)       + "'"
       cSql += "   AND ZZ5_PRODUT = '" + Alltrim(aCols[nContar,nPosItem]) + "'"
       cSql += "   AND ZZ5_DELETE = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

       If !T_COMISSAO->( EOF() )
          cComissao := T_COMISSAO->COMIS
       Endif
       
       If lPrimeiro   
          cCPrimeira := cComissao
          lPrimeira  := .F.
       Endif
       
       If cComissao <> cCPrimeira
          MsgAlert("Aten��o! % de comiss�o padr�o � diferente entre os produtos. Verifique!")
          Return(.F.)
       Endif
       
   Next nContar       
          
   // Verifica se o % de comiss�o informado est� dentro da regra de comiss�es
   If cComissao == 0
      Return(.T.)
   Endif
      
   If T_VENDEDOR->A3_TIPOV == "1" // Excutivo de Vendas
   Else
      If cBaseComi == 0
      Else
         cComissao := Round(((cComissao * cBaseComi) / 100),1)
      Endif   
   Endif

   If M->UA_COMIS <> 0
   
      If M->UA_COMIS <= cComissao
         Return(.T.)
      Else
         If M->UA_COMIS > cComissao
            MsgAlert("Aten��o!"                                                  + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Comiss�o informada est� fora da Regra de Comissionamento." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "% de comiss�o ser� ajustado automaticamnete para "         + str(cComissao,06,02))            
            M->UA_COMIS := cComissao
            Return(.T.)
         Endif
      Endif

   Endif
   
Return(.T.)