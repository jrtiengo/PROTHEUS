#include "rwmake.ch"        
#include "topconn.ch"
#include "protheus.ch"
#include "fileio.ch"
#INCLUDE "jpeg.ch" 
//#include "inkey.ch"
                             
// ###################################################################################                           
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                 ##
// -------------------------------------------------------------------------------- ##
// Cliente...: IBASA - IMPORTADORA BAGÉ                                             ##  
// Referencia: SOLTENDER.PRW                                                        ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: ( ) Programa  (X) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 11/09/2019                                                           ##
// Objetivo..: Gatilho disparado no código do produto na inclusão da SA que tem por ##
//             por objetivo de verificar se o produto tem controle de localização.  ##
//             Se tiver controle de localização, pesquisa na tabela SBF o endereço  ##
//             com maior saldo. Em caso de saldo zerado, não traz nenhum endereço.  ##
// ###################################################################################

User Function SOLTENDER(kProduto, kLocal)

   Local cSql     := ""
   Local cRetorno := ""
                
   // Retorna endereço em branco se código não informado
   If Empty(Alltrim(kProduto))
      Return(cRetorno)
   Endif

   // Verifica se produto passado no parâmetro tem controle de localização
   If Posicione("SB1",1,xFilial("SB1") + kProduto, "B1_LOCALIZ") <> "S"
      Return(cRetorno)
   Endif
   
   // Pesquisa na tabela SBF o endereço de maior saldo para o produto passado no parâmetro
   If Select("T_ENDEREBF") > 0
      T_ENDEREBF->( dbCloseArea() )
   EndIf

   cSql:= ""
   cSql := "SELECT TOP(1) BF_PRODUTO,"
   cSql += "              BF_LOCAL  ,"
   cSql += "              BF_LOCALIZ,"               
   cSql += "              BF_QUANT   "
   cSql += "  FROM " + RetSqlName("SBF")
   cSql += " WHERE BF_PRODUTO = '" + Alltrim(kProduto) + "'"
   cSql += "   AND BF_LOCAL   = '" + Alltrim(kLocal)   + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY BF_QUANT DESC"                                                                                     
  
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDEREBF", .T., .T. )
   
   If T_ENDEREBF->( EOF() )
      T_ENDEREBF->( dbCloseArea() )
      Return(cRetorno)
   Endif
   
   If T_ENDEREBF->BF_QUANT == 0
      T_ENDEREBF->( dbCloseArea() )
      Return(cRetorno)
   Else
      cRetorno := T_ENDEREBF->BF_LOCALIZ
      T_ENDEREBF->( dbCloseArea() )
   Endif
   
Return(cRetorno)
