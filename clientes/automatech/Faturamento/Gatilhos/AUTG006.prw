#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTG006.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: Gatilho                                                             *
// Campo.....: A1_CGC                                                              *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/06/2011                                                          *
// Objetivo..: Trazer o próximo código/Loja de cliente para inclusão de novos ca-  *
//             dastros pela verificação do CNPJ/CPF informado na tela de manuten-  *
//             ção de Cientes.                                                     *
//             Caso a leitura do CGC/CPF total já existir na tabela  de clientes,  *
//             sistema não deve permitir a inclusão deste.                         *
//**********************************************************************************

User Function AUTG006()

	Local cSql      := ""
    Local aRegistro := GetArea() // Guarda a posição inicial da tabela de clientes para posterior restauro
    Local cLoja     := ""

    U_AUTOM628("AUTG006")
	
    // Se não for inclusão, retorna
    If !Inclui
       Return nil
    Endif    
    
    // Se CNPJ/CPF estiver vazio, não realiza os testes da Função
    If Empty(M->A1_CGC)
       Return nil
    Endif

    // Verifica se o CNPJ/CPF informado já existe no cadastro de clientes
    // Caso já exista, não permite que o cliente seja cadastrado com o CNPJ/CPF informado.
    cSql := ""
    cSql := "SELECT A1_CGC "
    cSql += "  FROM " + RetSqlName("SA1")
    cSql += " WHERE A1_CGC = '" + M->A1_CGC + "'"    
    cSql += "   AND D_E_L_E_T_ = ' ' "
    
    cSql := ChangeQuery( cSql )

    If Select("T_JAEXISTE") > 0
       T_JAEXISTE->( dbCloseArea() )
    EndIf                           
    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)
	
    T_JAEXISTE->( dbGoTop() )

    If !T_JAEXISTE->( Eof() )

       MsgAlert("Atenção!" + chr(13) + chr(13) + "Cliente já cadastrado para este CNPJ/CPF." + chr(13) + chr(13) + "Inclusão não permitida. Verifique!")

       M->A1_COD  := Space(6)
       M->A1_LOJA := Space(3)
       M->A1_CGC  := SPACE(14)

       cLoja := space(3)

       // Restaura a posição inicial da tabela de Clientes
       RestArea(aRegistro)

   	   If Select("T_JAEXISTE") > 0
	      T_JAEXISTE->( dbCloseArea() )
	   EndIf

       Return cLoja
       
    Endif

    // Teste para CNPJ
    If Len(M->A1_CGC) == 14
       cSql := ""
       cSql := "SELECT A1_COD , "
       cSql += "       A1_LOJA, "
       cSql += "       A1_NOME, "
       cSql += "       A1_CGC   "
       cSql += "  FROM " + RetSqlName("SA1")   
       cSql += " WHERE Left(A1_CGC,8) = '" + Substr(M->A1_CGC,1,8) + "'"
       cSql += "   AND D_E_L_E_T_ = ' '"
       cSql += " ORDER BY A1_COD, A1_LOJA DESC"

       cSql := ChangeQuery( cSql )

   	   If Select("T_CLIENTE") > 0
	      T_Cliente->( dbCloseArea() )
       EndIf

	   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CLIENTE",.T.,.T.)
	
	   T_CLIENTE->( dbGoTop() )

	   If !T_CLIENTE->( Eof() )

          M->A1_COD  := T_CLIENTE->A1_COD
          M->A1_LOJA := STRZERO(INT(VAL(T_CLIENTE->A1_LOJA)) + 1 ,3)
       
          cLoja := STRZERO(INT(VAL(T_CLIENTE->A1_LOJA)) + 1 ,3) 
	
	   Else

          M->A1_COD := NOVOCOD()[1]
          cLoja     := NOVOCOD()[2]

          M->A1_LOJA := cLoja

	   EndIf

   	   If Select("T_CLIENTE") > 0
	      T_Cliente->( dbCloseArea() )
	   EndIf
	   
	Else

       M->A1_COD := NOVOCOD()[1]
       cLoja     := NOVOCOD()[2]

       M->A1_LOJA := cLoja
	
	Endif   
	
    // Restaura a posição inicial da tabela de Clientes
    RestArea(aRegistro)

Return cLoja

Static Function NOVOCOD()

   Local cCod  := ""
   Local cLoja := ""

   // Select que pesquisa o próximo código a ser utilizado para inclusão do novo cliente
   cSql := ""
   cSql := "SELECT MAX(A1_COD) A1_COD "
   cSql += "  FROM "+ RetSqlName("SA1") 
   cSql += " WHERE A1_COD < '999999' "
   cSql += "   AND D_E_L_E_T_ = ' ' "

   cSql := ChangeQuery( cSql )

   If Select("T_CODIGO") > 0
      T_Codigo->( dbCloseArea() )
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CODIGO",.T.,.T.)

   cCod  := STRZERO(INT(VAL(T_CODIGO->A1_COD)) + 1,6)
   cLoja := "001"
   
	If Select("T_CODIGO") > 0
		T_Codigo->( dbCloseArea() )
	EndIf

Return {cCod, cLoja}

