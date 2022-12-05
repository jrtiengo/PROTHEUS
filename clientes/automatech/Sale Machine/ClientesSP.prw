#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ClientesSP.PRW                                                      *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 29/12/2016                                                          *
// Objetivo..: Importação cadastro de clientes de São Paulo/SP                     *
//**********************************************************************************
User Function ClientesSP()

   Local cCaminho := "d:\carteira_d.txt"

   Local cSql        := ""
   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local aAjuste     := {}
   Local nSepara     := 0
   Local j           := ""

   Private nPosi01   := 0
   Private nPosi02   := 0

   Private lVolta    := .F.
   Private aConsulta := {}
   Private aNaoFez   := {}
   Private aJatem    := {}

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)

   xBuffer := StrTran(xBuffer, chr(9), "|")
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          _Linha    := ""
          aAdd( aAjuste,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // ####################
   // Grava os clientes ##
   // ####################
   For nContar = 1 to Len(aAjuste)

       cCNPJ     := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 1))
       cData     := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 2))
       cVendedor := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 3))
       cRazao    := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 4))                 
       cTelefone := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 5))
       cEmail    := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 6))
       cContato  := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 7))
       cEmailCon := Alltrim(U_P_CORTA(aAjuste[nContar], "|", 8))
       cDDD      := Alltrim(Strtran(U_P_CORTA(CTELEFONE,")",1),"(",""))
       cFone     := Alltrim(U_P_CORTA(CTELEFONE,")",2))

       // ################################
       // Inclui os contatos do cliente ##
       // ################################
       
       // ####################################################
       // Pesquisa o código e loja do cliente pelo cnpj/cpf ##
       // ####################################################
       If Select("T_CLIENTE") > 0
          T_CLIENTE->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A1_COD, "
       cSql += "       A1_LOJA "
       cSql += "  FROM " + RetSqlName("SA1")
       cSql += " WHERE A1_CGC     = '" + Alltrim(cCNPJ) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

       If T_CLIENTE->( EOF() )
          Loop
       Endif
       
       cEntidade := T_CLIENTE->A1_COD + T_CLIENTE->A1_LOJA
       
       // #######################################################
       // Pesquisa o próximo código de contato a ser utilizado ##
       // #######################################################
       Cod_Contato := NEWNUMCONT()

       DbSelectArea("SU5")
       RecLock("SU5",.T.)
       U5_FILIAL  := ""
       U5_CODCONT := Cod_Contato
       U5_CONTAT  := cContato
       U5_DDD     := cDDD
       U5_FONE    := cFone
       U5_FCOM1   := cFone
       U5_EMAIL   := cEmailCon
       U5_NIVEL   := "08"
       U5_ATIVO   := "1"
       U5_STATUS  := "2"
       U5_TIPO    := "3"
       Msunlock()

       // Cadastra o Vínculo Contato X Cliente
       DbSelectArea("AC8")
       RecLock("AC8",.T.)
       AC8_FILIAL  := ""
       AC8_FILENT := ""       
       AC8_ENTIDA := "SA1"
       AC8_CODENT := cEntidade
       AC8_CODCON := Cod_Contato
       Msunlock()
       
   Next nContar       

msgalert("terminou")

Return(.T.)


/*
       // ###########################################
       // Verifica se o cnpj já existe no cadastro ##
       // ###########################################
       If Select("T_JAEXISTE") > 0
          T_JAEXISTE->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A1_COD   , "
       cSql += "       A1_CGC   , "
       cSql += "       A1_NOME    "
       cSql += "  FROM " + RetSqlName("SA1")
       cSql += " WHERE A1_CGC = '" + Alltrim(cCNPJ) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

       If !T_JAEXISTE->( EOF() )

          aAdd(aJatem, cCNPJ + " - " + T_JAEXISTE->A1_NOME)

       Else

          // ###############################
          // Carrega o codigo do vendedor ##
          // ###############################
          Do Case
             Case Alltrim(Upper(cVendedor)) == "TEREZINHA SAMPAIO"
                  cCodVend := "000500"
             Case Alltrim(Upper(cVendedor)) == "ANA AMELIA"
                  cCodVend := "000494"
             Case Alltrim(Upper(cVendedor)) == "CARMEN CARVALHO"
                  cCodVend := "000497"
             Case Alltrim(Upper(cVendedor)) == "BEATRIZ FRANCO"
                  cCodVend := "000495"
             Case Alltrim(Upper(cVendedor)) == "BRUNO AVELINO"
                  cCodVend := "000496"
             Case Alltrim(Upper(cVendedor)) == "LUANA CARDOSO"
                  cCodVend := "000499"
             Case Alltrim(Upper(cVendedor)) == "JANAINA LIMA"
                  cCodVend := "000498"
             Otherwise
                  cCodVend := ""
          EndCase

          // ############################
          // Pesquisa o proximo codigo ##
          // ############################
          If Select("T_PROXIMO") > 0
             T_PROXIMO->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT TOP(1) A1_COD"
          cSql += "  FROM " + RetSqlName("SA1") 
          cSql += " WHERE D_E_L_E_T_ = ''"
          cSql +="  ORDER BY A1_COD DESC"
   
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

          cProximo := Strzero((INT(VAL(T_PROXIMO->A1_COD)) + 1),6)

          // ###################
          // Inclui o cliente ##
          // ###################
          DbSelectArea("SA1")
	      DbSetOrder(1)
 	      RecLock("SA1",.T.)
          SA1->A1_COD    := cProximo
          SA1->A1_LOJA   := "001"
          SA1->A1_NOME   := cRazao 
          SA1->A1_CGC    := cCNPJ     
          SA1->A1_EMAIL  := cEmail
          SA1->A1_DDD    := cDDD
          SA1->A1_TEL    := cFone                
          SA1->A1_ZVEND2 := cCodVend
	      MsUnlock()

       Endif

   cString := ""

   For nContar = 1 to Len(aJaTem)
       cString := cString + aJaTem[nContar] + chr(13) + chr(10) 
   Next nContar 

   nHdl := fCreate("d:\jatem_d.txt")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

*/

Return .T.