#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM117.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/06/2012                                                          *
// Objetivo..: Este programa tem a finalidade de retornar Verdadeiro ou Falso ve-  *
//             rificando a seguinte regra:                                         *
//             Caso tenha sido informada uma tabela de preço, programa verificara  *
//             se o produto em questão pertence a tabela de preço.Neste caso sera  *
//             retornado Falso, ou seja, o campo preço unitário não podera ser al- *
//             terado caso contrário, retorna verdadeiro  permitindo  a alteração  *
//             do campo preço unitário.                                            *
// Parâmetros: _Tipo = 1 - Indica Apontamento de Orçamentos                        *
//                     2 - Indica Apontamento de Ordem de Serviço                  *
//**********************************************************************************

User Function AUTOM117(_Tipo)

   Local cSql := ""

   // Se produto não informado etorna
   If Empty(Alltrim(aCols[n,2]))
      Return .T.
   Endif
      
   // Se tabela de preço não informada retorna
   If _Tipo == 1
      If M->AB3_EMISSA <= CTOD("02/07/2012")
         Return .T.
      Else   
         If Empty(Alltrim(M->AB3_TABELA))
           Return .F.
         Else
            Return .T.         
         Endif   
      Endif   
   Else
      If M->AB6_EMISSA <= CTOD("02/07/2012")
         Return .T.
      Else
         If Empty(Alltrim(M->AB6_TABELA))
            Return .F.
         Else
            Return .T.
         Endif
      Endif
   Endif      

   // Verifica se o produto pertense a uma tabela de preço
   If Select("T_PRECO") <>  0
      T_PRECO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT A.DA1_FILIAL,"
   cSql += "       A.DA1_CODTAB,"
   cSql += "       A.DA1_CODPRO,"
   cSql += "       A.DA1_PRCVEN,"
   cSql += "       A.DA1_ATIVO ,"
   cSql += "       B.DA0_DATDE ,"
   cSql += "       B.DA0_HORADE,"
   cSql += "       B.DA0_DATATE,"
   cSql += "       B.DA0_HORATE,"
   cSql += "       B.DA0_ATIVO  "    
   cSql += "  FROM " + RetSqlName("DA1") + " A, "
   cSql += "       " + RetSqlName("DA0") + " B  "  
   cSql += " WHERE A.DA1_FILIAL = '" + Alltrim(cFilAnt)    + "'"
   cSql += "   AND A.DA1_CODPRO = '" + Alltrim(aCols[n,2]) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''
   cSql += "   AND A.DA1_CODTAB = B.DA0_CODTAB 
   cSql += "   AND B.D_E_L_E_T_ = ''
   cSql += "   AND GETDATE() >= B.DA0_DATDE 
   cSql += "   AND GETDATE() <= B.DA0_DATATE
   cSql += "   AND A.DA1_ATIVO = 1
   cSql += "   AND B.DA0_ATIVO = 1

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRECO",.T.,.T.)

   If T_PRECO->( EOF() )
      Return .T.
   Else
      Return .F.
   Endif

Return .T.