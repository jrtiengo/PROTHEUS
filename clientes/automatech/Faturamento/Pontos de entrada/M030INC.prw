#INCLUDE "PROTHEUS.CH"

// ################################################################################## 
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M030INC.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho (X) Ponto de Entrada                      ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 18/04/2012                                                          ##
// Objetivo..: Ponto de entrada disparado logo após a inclusão de novo cliente.    ##
//             Este tem a finalidade de incluir o cliente como fornecedor também.  ## 
// Alteração.: 03/01/2017 - Inclusão de cadastramento automático de contatos e a   ##
//             vinculação no cadastro de Contatos X Clientes.                      ##
// ##################################################################################

User Function M030INC()

   Local cSql      := ""
   Local aRegistro := GetArea() // Guarda a posição inicial da tabela de clientes para posterior restauro
   Local _Codigo   := ""
   Local _Loja     := ""
   Local nProximo  := ""
   Local nVezes    := 0

   // #############################################################
   // Variáevis da tela complementar do cadastro de fornecedores ##
   // #############################################################
   Local cNatureza := Space(10)
   Local cBanco	   := "01058"

   Local oNatureza
   Local oBanco

   U_AUTOM628("M030INC")
   
   // ################################
   // Se não for inclusão, retorna  ##
   // ################################
   If !Inclui
      Return nil
   Endif    
    
   // #############################################################
   // Se CNPJ/CPF estiver vazio, não realiza os testes da Função ##
   // #############################################################
   If Empty(SA1->A1_CGC)
      Return nil
   Endif

   // ############################################################################################
   // Envia para a função que cadastra o contato e o vincula ao cadastro de Contatos X Clientes ##
   // ############################################################################################
   Inc_Contato(SA1->A1_CGC)

   // ######################################################################################
   // Verifica se o CNPJ/CPF informado já existe no cadastro de clientes                  ##
   // Caso já exista, não permite que o cliente seja cadastrado com o CNPJ/CPF informado. ##
   // ######################################################################################
   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf                           

   cSql := ""
   cSql := "SELECT A2_CGC "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_CGC = '" + Alltrim(SA1->A1_CGC) + "'"    
   cSql += "   AND D_E_L_E_T_ = ' ' "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)
	
   T_JAEXISTE->( dbGoTop() )

   If !T_JAEXISTE->( Eof() )
      // ###################################################
      // Restaura a posição inicial da tabela de Clientes ##
      // ###################################################
      RestArea(aRegistro)
      If Select("T_JAEXISTE") > 0
         T_JAEXISTE->( dbCloseArea() )
      EndIf
      Return Nil
   Endif

   // ##################
   // Teste para CNPJ ##
   // ##################
   If Select("T_CLIENTE") > 0
      T_Cliente->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD , "
   cSql += "       A2_LOJA, "
   cSql += "       A2_NOME, "
   cSql += "       A2_CGC   "
   cSql += "  FROM " + RetSqlName("SA2")   

   If Len(Alltrim(SA1->A1_CGC)) == 14
      cSql += " WHERE Left(A2_CGC,8) = '" + Substr(SA1->A1_CGC,1,8) + "'"
   Else   
      cSql += " WHERE A2_CGC = '" + Alltrim(SA1->A1_CGC) + "'"
   Endif   

   cSql += "   AND D_E_L_E_T_ = ' '"
   cSql += " ORDER BY A2_COD, A2_LOJA DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CLIENTE",.T.,.T.)
	
   T_CLIENTE->( dbGoTop() )

   If !T_CLIENTE->( Eof() )

      _Codigo := T_CLIENTE->A2_COD
      _Loja   := STRZERO(INT(VAL(T_CLIENTE->A2_LOJA)) + 1 ,3)
	
   Else
                        
      // #####################################################################################
      // Select que pesquisa o próximo código a ser utilizado para inclusão do novo cliente ##
      // #####################################################################################
      If Select("T_CODIGO") > 0
         T_Codigo->( dbCloseArea() )
      EndIf

      cSql := ""
      csql := "SELECT A2_COD"
      cSql += "  FROM " + RetSqlName("SA2") 
      cSql += " WHERE A2_COD < '999999' "
      cSql += "   AND D_E_L_E_T_ = ''   " 
      cSql += " ORDER BY CAST(A2_COD AS INT) DESC

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CODIGO",.T.,.T.)
          
      If T_CODIGO->( EOF() )
         _Codigo := "000001"
         _Loja   := "001"
      Else
         T_CODIGO->( DbGoTop() )
         _Codigo := STRZERO((INT(VAL(T_CODIGO->A2_COD)) + 1),6)
         _Loja   := "001"
      Endif
   
   Endif

   // ################################################################################################################################################################
   // Abre a janela complementar para o cadastro de fornecedor                                                                                                      ##
   //   DEFINE MSDIALOG oDlgC TITLE "Cadastro de Fornecedores" FROM C(178),C(181) TO C(284),C(602) PIXEL                                                            ##
   //                                                                                                                                                               ##
   //   @ C(005),C(005) Say "Atenção! O Cliente incluído será incluído também como Fornecedor. Para isso, favor " Size C(202),C(008) COLOR CLR_BLACK PIXEL OF oDlgC ##
   //   @ C(014),C(005) Say "informar os campos abaixo pertinentes somente ao Cadastro de Fornecedores."          Size C(188),C(008) COLOR CLR_BLACK PIXEL OF oDlgC ##
   //   @ C(029),C(005) Say "Natureza"                                                                            Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgC ##
   //   @ C(029),C(092) Say "Pais BACEN"                                                                          Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgC ##
   //                                                                                                                                                               ##
   //   @ C(038),C(005) MsGet oNatureza Var cNatureza Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("SED")                                      ##
   //   @ C(038),C(092) MsGet oBanco    Var cBanco    Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("CCH")                                      ##
   //                                                                                                                                                               ##
   //   @ C(035),C(154) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )                                                                     ##
   //                                                                                                                                                               ##
   //   ACTIVATE MSDIALOG oDlgC CENTERED                                                                                                                            ##
   // ################################################################################################################################################################

   // ###########################
   // Inclui o novo Fornecedor ##
   // ###########################
   DbSelectArea("SA2")
   RecLock("SA2",.T.)
   A2_COD     := _Codigo
   A2_LOJA    := _Loja   
   A2_NOME    := SA1->A1_NOME
   A2_NREDUZ  := SA1->A1_NREDUZ  
   A2_END     := SA1->A1_END
   A2_BAIRRO  := SA1->A1_BAIRRO
   A2_EST     := SA1->A1_EST
   A2_COD_MUN := SA1->A1_COD_MUN
   A2_MUN     := SA1->A1_MUN
   A2_CEP     := SA1->A1_CEP

   If Len(Alltrim(SA1->A1_CGC)) == 14
      A2_TIPO := "J"
   Else
      A2_TIPO := "F"      
   Endif

   A2_CGC     := SA1->A1_CGC
   A2_DDD     := SA1->A1_DDD
   A2_TEL     := SA1->A1_TEL
   A2_INSCR   := SA1->A1_INSCR
   A2_EMAIL   := SA1->A1_EMAIL
   A2_DDI     := SA1->A1_DDI
   A2_INSCRM  := SA1->A1_INSCRM
   A2_PAIS    := SA1->A1_PAIS
   A2_TELEX   := SA1->A1_TELEX
   A2_PFISICA := SA1->A1_PFISICA
   A2_HPAGE   := SA1->A1_HPAGE
   A2_COMPLEM := SA1->A1_COMPLEM
   //A2_NATUREZ := cNatureza
   A2_CODPAIS := cBanco

   Msunlock()
   
   // ###################################################
   // Restaura a posição inicial da tabela de Clientes ##
   // ###################################################
   RestArea(aRegistro)

Return(.T.)

// #############################################################################
// Função que inclui o contato e o vincula ao cadastro de Contatos X Clientes ##
// #############################################################################
Static Function Inc_Contato(_CNPJ)

   Local cSql      := ""
   Local cEntidade := ""

   // ####################################################
   // Pesquisa o código e loja do cliente pelo cnpj/cpf ##
   // ####################################################
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD    , "
   cSql += "       A1_LOJA   , "
   cSql += "       A1_DDD    , "
   cSql += "       A1_TEL    , "
   cSql += "       A1_EMAIL  , "
   cSql += "       A1_NCONT    "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_CGC     = '" + Alltrim(_CNPJ) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
      Return(.T.)
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
   U5_CONTAT  := T_CLIENTE->A1_NCONT
   U5_DDD     := T_CLIENTE->A1_DDD
   U5_FONE    := T_CLIENTE->A1_TEL
   U5_FCOM1   := T_CLIENTE->A1_TEL
   U5_EMAIL   := T_CLIENTE->A1_EMAIL
   U5_NIVEL   := "08"
   U5_ATIVO   := "1"
   U5_STATUS  := "2"
   U5_TIPO    := "3"
   Msunlock()

   // #######################################
   // Cadastra o Vínculo Contato X Cliente ##
   // #######################################
   DbSelectArea("AC8")
   RecLock("AC8",.T.)
   AC8_FILIAL  := ""
   AC8_FILENT := ""       
   AC8_ENTIDA := "SA1"
   AC8_CODENT := cEntidade
   AC8_CODCON := Cod_Contato
   Msunlock()
   
Return(.T.)