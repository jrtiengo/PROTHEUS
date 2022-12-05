#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTF006.PRW                                                         *
// Par�metros: Nenhum                                                              *
// Tipo......: Gatilho                                                             *
// Campo.....: A2_CGC                                                              *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 27/06/2011                                                          *
// Objetivo..: Trazer o pr�ximo c�digo/Loja de cliente para inclus�o de novos ca-  *
//             dastros pela verifica��o do CNPJ/CPF informado na tela de manuten-  *
//             ��o de Cientes.                                                     *
//             Caso a leitura do CGC/CPF total j� existir na tabela  de clientes,  *
//             sistema n�o deve permitir a inclus�o deste.                         *
//**********************************************************************************

User Function AUTOM687()

	Local cSql      := ""
    Local aRegistro := GetArea() // Guarda a posi��o inicial da tabela de clientes para posterior restauro
    Local cCodForne := ""
    Local cLoja     := ""

    U_AUTOM628("AUTG007")	
    
    // Se n�o for inclus�o, retorna
    If !Inclui
       Return nil
    Endif    
    
    // Se CNPJ/CPF estiver vazio, n�o realiza os testes da Fun��o
    If Empty(M->A2_CGC)
       Return nil
    Endif

    // Verifica se o CNPJ/CPF informado j� existe no cadastro de clientes
    // Caso j� exista, n�o permite que o cliente seja cadastrado com o CNPJ/CPF informado.
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

       MsgAlert("Aten��o!" + chr(13) + chr(13) + "Fornecedor j� cadastrado para este CNPJ/CPF." + chr(13) + chr(13) + "Inclus�o n�o permitida. Verifique!")

       M->A2_COD  := Space(6)
       M->A2_LOJA := Space(3)
       M->A2_CGC  := SPACE(14)

       cCodForne  := Space(06)
       cLoja      := Space(03)

       // Restaura a posi��o inicial da tabela de Clientes
       RestArea(aRegistro)

   	   If Select("T_JAEXISTE") > 0
	      T_JAEXISTE->( dbCloseArea() )
	   EndIf

       Return cCodForne
       
    Endif

    // Teste para CNPJ
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
       
          cCodForne  := T_CLIENTE->A2_COD
          cLoja      := STRZERO(INT(VAL(T_CLIENTE->A2_LOJA)) + 1 ,3) 
	
	   Else

          M->A2_COD := NOVOCODF()[1]
          cLoja     := NOVOCODF()[2]

          cCodForne := M->A2_COD
          M->A2_LOJA := cLoja

	   EndIf

   	   If Select("T_CLIENTE") > 0
	      T_Cliente->( dbCloseArea() )
	   EndIf
	   
	Else

       M->A2_COD := NOVOCODF()[1]
       cLoja     := NOVOCODF()[2]

       cCodForne := M->A2_COD
	
	Endif   
	
    // Restaura a posi��o inicial da tabela de Clientes
    RestArea(aRegistro)

Return cCodForne

Static Function NOVOCODF()

   Local cCod  := ""
   Local cLoja := ""

   // Select que pesquisa o pr�ximo c�digo a ser utilizado para inclus�o do novo cliente
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

