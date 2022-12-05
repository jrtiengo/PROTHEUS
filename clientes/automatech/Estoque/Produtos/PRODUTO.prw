#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: NPRODUTO.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/10/2011                                                          *
// Objetivo..: Programa que grava a nova descrição do cadastro de produtos         *
//**********************************************************************************

// Função que define a Window
User Function NPRODUTO()

     Local nLidos
     Local nTamArq
     Local aCNPJ 
     Local nContar
     Local nAlen
     Local cSql 
     Local nReg
     Local cProduto  := space(30)
     Local nPosicao
     Local nPipe     := 1
     Local cLinha    := ""
     Local _Codigo   := ""
     Local _PartNum  := ""
     Local _Nome01   := ""
     Local _Nome02   := ""
     Local _Ativo    := ""
     Local aProdutos := {}

     Private xBuffer

     U_AUTOM628("PRODUTO")

     cBuffer   := 1
     aProdutos := {}
     nContar   := 0
     nAlen     := 0
     nReg      := 0
     cProduto  := ""
     nPosicao  := 1
     nPontoVir := 0
     
     // Abre o arquivoa ser lido
     nHandle := FOPEN("c:\automatech\fontes\produtos\produto.prn", FO_READWRITE + FO_SHARED)
     
     If FERROR() != 0
        MsgAlert("Erro ao abrir o arquivo especificado.")
        Return .T.
     Else
        MsgAlert("Arquivo foi aberto com sucesso.")     
     Endif
     
     // Lê o tamanho total do arquivo
 	 nLidos :=0
	 FSEEK(nHandle,0,0)
	 nTamArq:=FSEEK(nHandle,0,2)
	 FSEEK(nHandle,0,0)

     // Lê todos os Produtos
     xBuffer:=Space(nTamArq)
     FREAD(nHandle,@xBuffer,nTamArq)

     // Carrega o Array aProdutos
     cProduto  := ""
     nPosicao  := 1
     nAlen     := 0
     nPipe     := 1

     _Codigo   := ""
     _PartNum  := ""
     _Nome01   := ""
     _Nome02   := ""
     _Ativo    := ""

     For nContar = 1 to Len(xBuffer)

         If Substr(xBuffer, nContar, 1) == chr(13)
            Loop                                                
         Endif
            
         If Substr(xBuffer, nContar, 1) == chr(10)
            Loop
         Endif
     
         If Substr(xBuffer, nContar, 1) <> "|"

            Do Case
               Case nPipe == 1
                    _Codigo  := _Codigo  + Substr(xBuffer, nContar, 1)
               Case nPipe == 2
                    _PartNum := _PartNum + Substr(xBuffer, nContar, 1)
               Case nPipe == 3
                    _Ativo   := _Ativo   + Substr(xBuffer, nContar, 1)
               Case nPipe == 4
                    _Nome01  := _Nome01  + Substr(xBuffer, nContar, 1)
               Case nPipe == 5
                    _Nome02  := _Nome02  + Substr(xBuffer, nContar, 1)
            EndCase         

         Else

            nPipe := nPipe + 1
            
            If nPipe == 6
               aAdd( aprodutos, {Alltrim(_Codigo) ,;
                                 Alltrim(_PartNum),;
                                 Alltrim(_Ativo)  ,;
                                 Alltrim(_Nome01) ,;
                                 Alltrim(_Nome02) } )
               nPipe := 1

               _Codigo   := ""
               _PartNum  := ""
               _Nome01   := ""
               _Nome02   := ""
               _Ativo    := ""

            Endif

         Endif
         
     Next nContar
     
     // 01 - Código do Produto
     // 02 - Part Number
     // 03 - Indicação de Ativo / Inativo
     // 04 - Descrição do Produto
     // 05 - Descrição Auxiliar do Produto

     aAdd( aprodutos, {Alltrim(_Codigo) ,;
                       Alltrim(_PartNum),;
                       Alltrim(_Ativo)  ,;
                       Alltrim(_Nome01) ,;
                       Alltrim(_Nome02) } )

     // Atualiza o Cadastro de Produtos
     For nContar = 1 to Len(aProdutos)

         // Prepara a chave para pesquisa
         cProduto   := ""
         cDescricao := ""
         cAtivo     := ""

         cProduto   := "  " + Substr(Alltrim(aProdutos[nContar,1]),01,06) + space(24)
         cDescricao := Alltrim(aProdutos[nContar,4]) + Alltrim(aProdutos[nContar,5])
         cAtivo     := Alltrim(aProdutos[nContar,3])

         // Pesquisa o produto no cadastro de produtos
    	 DbSelectArea("SB1")
         DbSetOrder(1)
         If DbSeek( cProduto )  

/*
msgalert("Codigo do Produto: " + Alltrim(cProduto))
msgalert("Nome Antigo: " + Alltrim(sb1->b1_desc))
msgalert("Auxiliar Antigo: " + alltrim(sb1->b1_daux))
msgalert("Novo Nome: " + Substr(cDescricao,01,30))
msgalert("Auxilial Novo: " + Substr(cDescricao,31,40))
*/

            RecLock("SB1", .F.)
            SB1->B1_DESC := Substr(cDescricao,01,30)
            SB1->B1_DAUX := Substr(cDescricao,31)

            If Alltrim(cAtivo) == "X"
               SB1->B1_MSBLQL := "1"
            Endif
               
            MsUnLock()

         Endif   

     Next nContar

Return .T.