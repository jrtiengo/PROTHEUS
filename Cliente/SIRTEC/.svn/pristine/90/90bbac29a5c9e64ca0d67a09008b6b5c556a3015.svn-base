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
// User Function SOLTENDER()

   Local cSql     := ""
   Local cRetorno := ""
   // Local kProduto := FWFldGet("CP_PRODUTO") // GDFieldGet("CP_PRODUTO")
   // Local kLocal   := FWFldGet("CP_LOCAL") // GDFieldGet("CP_LOCAL")
   Local aArea_   := GetArea()
   /*

   Alterações no programa, para não gerar erro de alias e de work area note in use.
   Mauro - Solutio. 24/01/2022.

   Regra original do gatilho.
   U_SOLTENDER(M->CP_PRODUTO, M->CP_LOCAL) 
   */
                
   // Retorna endereço em branco se código não informado
   If Empty(Alltrim(kProduto))
      GDFieldPut("CP_YLOCALI", "")
      RestArea(aArea_)
      Return(cRetorno)
   Endif

   // Verifica se produto passado no parâmetro tem controle de localização
   If Posicione("SB1",1,xFilial("SB1") + kProduto, "B1_LOCALIZ") <> "S"
      // GDFieldPut("CP_YLOCALI", "")
      RestArea(aArea_)
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
      // GDFieldPut("CP_YLOCALI", "")
      RestArea(aArea_)
      Return(cRetorno)
   Endif
   
   If T_ENDEREBF->BF_QUANT == 0
      T_ENDEREBF->( dbCloseArea() )
      // GDFieldPut("CP_YLOCALI", "")
      RestArea(aArea_)
      Return(cRetorno)
   Else
      // GDFieldPut("CP_YLOCALI", T_ENDEREBF->BF_LOCALIZ)
      cRetorno := T_ENDEREBF->BF_LOCALIZ
      T_ENDEREBF->( dbCloseArea() )
   Endif
   
   RestArea(aArea_)

Return(cRetorno)
