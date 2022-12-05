#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTF006.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: Gatilho                                                             ##
// Campo.....: A2_CGC                                                              ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 27/06/2011                                                          ##
// Objetivo..: Trazer o próximo código/Loja de cliente para inclusão de novos ca-  ##
//             dastros pela verificação do CNPJ/CPF informado na tela de manuten-  ##
//             ção de Cientes.                                                     ##
//             Caso a leitura do CGC/CPF total já existir na tabela  de clientes,  ##
//             sistema não deve permitir a inclusão deste.                         ##
// Parãmetros: 1 - Atualizará o código do fornecedor                               ##
//             2 - Atualizará a loja do fornecedor                                 ##
// ##################################################################################

User Function AUTG007(kCampo)

	Local cSql      := ""
    Local aRegistro := GetArea() // Guarda a posição inicial da tabela de clientes para posterior restauro
    Local cLoja     := ""

    U_AUTOM628("AUTG007")	
    
    // ###############################
    // Se não for inclusão, retorna ##
    // ###############################
    If !Inclui
       Return nil
    Endif    
    
    // #############################################################
    // Se CNPJ/CPF estiver vazio, não realiza os testes da Função ##
    // #############################################################
    If Empty(M->A2_CGC)
       Return nil
    Endif

    // ######################################################################################
    // Verifica se o CNPJ/CPF informado já existe no cadastro de clientes                  ##
    // Caso já exista, não permite que o cliente seja cadastrado com o CNPJ/CPF informado. ##
    // ######################################################################################
    cSql := ""
    cSql := "SELECT A2_CGC "
    cSql += "  FROM " + RetSqlName("SA2")
    cSql += " WHERE A2_CGC = '" + M->A2_CGC + "'"    
    cSql += "   AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery( cSql )

    If Select("T_JAEXISTE") > 0
       T_JAEXISTE->( dbCloseArea() )
    EndIf                           

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)
	
    T_JAEXISTE->( dbGoTop() )

    If !T_JAEXISTE->( Eof() )

       MsgAlert("Atenção!" + chr(13) + chr(13) + "Fornecedor já cadastrado para este CNPJ/CPF." + chr(13) + chr(13) + "Inclusão não permitida. Verifique!")

       M->A2_COD  := Space(6)
       M->A2_LOJA := Space(3)
       M->A2_CGC  := SPACE(14)

       cCodFor := Space(06)
       cLoja   := space(3)

       // ###################################################
       // Restaura a posição inicial da tabela de Clientes ##
       // ###################################################
       RestArea(aRegistro)

   	   If Select("T_JAEXISTE") > 0
	      T_JAEXISTE->( dbCloseArea() )
	   EndIf

       If kCampo == 1
          Return cCodFor
       Else
          Return cLoja
       Endif   
       
    Endif

    // ##################
    // Teste para CNPJ ##
    // ##################
    If Len(M->A2_CGC) == 14
       cSql := ""
       cSql := "SELECT A2_COD , "
       cSql += "       A2_LOJA, "
       cSql += "       A2_NOME, "
       cSql += "       A2_CGC   "
       cSql += "  FROM " + RetSqlName("SA2")   
       cSql += " WHERE Left(A2_CGC,8) = '" + Substr(M->A2_CGC,1,8) + "'"
       cSql += "   AND D_E_L_E_T_ = ' '"
       cSql += " ORDER BY A2_COD, A2_LOJA DESC"

       cSql := ChangeQuery( cSql )

   	   If Select("T_CLIENTE") > 0
	      T_Cliente->( dbCloseArea() )
       EndIf

	   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CLIENTE",.T.,.T.)
	
	   T_CLIENTE->( dbGoTop() )

	   If !T_CLIENTE->( Eof() )

          M->A2_COD  := T_CLIENTE->A2_COD
          M->A2_LOJA := STRZERO(INT(VAL(T_CLIENTE->A2_LOJA)) + 1 ,3)
       
          cCodFor := T_CLIENTE->A2_COD
          cLoja   := STRZERO(INT(VAL(T_CLIENTE->A2_LOJA)) + 1 ,3) 
	
	   Else

          cCodFor := NOVOCODF()[1]
          cLoja   := NOVOCODF()[2]

          M->A2_COD  := cCodFor
          M->A2_LOJA := cLoja

	   EndIf

   	   If Select("T_CLIENTE") > 0
	      T_Cliente->( dbCloseArea() )
	   EndIf
	   
	Else

       cCodFor := NOVOCODF()[1]
       cLoja   := NOVOCODF()[2]

       M->A2_COD  := cCodFor
       M->A2_LOJA := cLoja
	
	Endif   
	
    // ###################################################
    // Restaura a posição inicial da tabela de Clientes ##
    // ###################################################
    RestArea(aRegistro)

    GetDRefresh() 

    If kCampo == 1
       Return cCodFor
    Else   
       Return cLoja       
    Endif   

Return cLoja

// #####################################################
// Função que pesquisa o próximo código de fornecedor ##
// #####################################################
Static Function NOVOCODF()

   Local cCod  := ""
   Local cLoja := ""

   // #####################################################################################
   // Select que pesquisa o próximo código a ser utilizado para inclusão do novo cliente ##
   // #####################################################################################
   cSql := ""
   cSql := "SELECT MAX(A2_COD) A2_COD "
   cSql += "  FROM "+ RetSqlName("SA2") 
   cSql += " WHERE A2_COD < '999999' "
   cSql += "   AND D_E_L_E_T_ = ' ' "

   cSql := ChangeQuery( cSql )

   If Select("T_CODIGO") > 0
      T_Codigo->( dbCloseArea() )
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CODIGO",.T.,.T.)

   cCod  := STRZERO(INT(VAL(T_CODIGO->A2_COD)) + 1,6)
   cLoja := "001"
   
	If Select("T_CODIGO") > 0
		T_Codigo->( dbCloseArea() )
	EndIf

Return {cCod, cLoja}