#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: MT20FOPOS.PRW                                                       *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/12/2012                                                          *
// Objetivo..: Ponto de Entrada disparado após a gravação do cadastro de fornece-  *
//             dores. Tem por finalidade de Incluir/Alterar os dados do fornecedor *
//             dentro do cadastro de Clientes.                                     * 
//**********************************************************************************

User Function MT20FOPOS()

   Local cSql      := ""
   Local aRegistro := GetArea() // Guarda a posição inicial da tabela de fornecedores para posterior restauração
   Local _Operacao := ""
   Local _Codigo   := ""
   Local _Loja     := ""
   Local nProximo  := ""
   Local nVezes    := 0

   // Variáveis para a tela de complemento do cadastro de clientes
   Local lChumba   := .F.
   Local aTipo     := {"F=Cons.Final", "L=Produtor Rural", "R=Revendedor", "S=Solidario", "X=Exportação"}
   Local aGrupo    := {}
   Local cNatureza := Space(10)

   Local cTipo
   Local cGrupo
   Local oNatureza

   Private oDlgC
	
   U_AUTOM628("MT20FOPOS")

   // Se CNPJ/CPF estiver vazio, não realiza os testes da Função
   If Empty(SA2->A2_CGC)
      Return nil
   Endif

   // Descobre o tipo de operação que deverá ser realizada (Inclusão/Alteração)
   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf                           

   cSql := ""
   cSql := "SELECT A1_CGC "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_CGC = '" + Alltrim(SA2->A2_CGC) + "'"    
   cSql += "   AND D_E_L_E_T_ = ' ' "

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)
	
   If T_JAEXISTE->( EOF() )
      _Operacao := "I"
   Else
      _Operacao := "A"      
   Endif
      
   // Teste para CNPJ
   If Select("T_CLIENTE") > 0
      T_Cliente->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_NOME, "
   cSql += "       A1_CGC   "
   cSql += "  FROM " + RetSqlName("SA1")   

   If Len(Alltrim(SA2->A2_CGC)) == 14
      cSql += " WHERE Left(A1_CGC,8) = '" + Substr(SA2->A2_CGC,1,8) + "'"
   Else   
      cSql += " WHERE A1_CGC = '" + Alltrim(SA2->A2_CGC) + "'"
   Endif   

   cSql += "   AND D_E_L_E_T_ = ' '"
   cSql += " ORDER BY A1_COD, A1_LOJA DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CLIENTE",.T.,.T.)
	
   T_CLIENTE->( dbGoTop() )

   If !T_CLIENTE->( Eof() )

      _Codigo := T_CLIENTE->A1_COD
      _Loja   := STRZERO(INT(VAL(T_CLIENTE->A1_LOJA)) + 1 ,3)
	
   Else

      // Select que pesquisa o próximo código a ser utilizado para inclusão do novo cliente
      If Select("T_CODIGO") > 0
         T_Codigo->( dbCloseArea() )
      EndIf

      cSql := ""
      csql := "SELECT A1_COD"
      cSql += "  FROM " + RetSqlName("SA1") 
      cSql += " WHERE A1_COD < '999999' "
      cSql += "   AND D_E_L_E_T_ = ''   " 
      cSql += " ORDER BY CAST(A1_COD AS INT) DESC

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CODIGO",.T.,.T.)
          
      If T_CODIGO->( EOF() )
         _Codigo := "000001"
         _Loja   := "001"
      Else
         T_CODIGO->( DbGoTop() )
         _Codigo := STRZERO((INT(VAL(T_CODIGO->A1_COD)) + 1),6)
         _Loja   := "001"
      Endif
   
   Endif

   // Inclui o novo Fornecedor
   If _Operacao == "I"

      aGrupo := {}

      If Select("T_GRUPO") > 0
         T_Grupo->( dbCloseArea() )
      EndIf
      
      cSql := "SELECT X5_TABELA,"
      cSql += "       X5_CHAVE ,"
      cSql += "       X5_DESCRI "
      cSql += "  FROM " + RetSqlName("SX5")
      cSql += " WHERE X5_TABELA = '88'"
      cSql += " ORDER BY X5_CHAVE"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_GRUPO",.T.,.T.)

      WHILE !T_GRUPO->( EOF() )
         aAdd( aGrupo, Alltrim(T_GRUPO->X5_CHAVE) + " - " + Alltrim(T_GRUPO->X5_DESCRI) )
         T_GRUPO->( DbSkip() )
      ENDDO

      DEFINE MSDIALOG oDlgC TITLE "Cadastro de Clientes" FROM C(178),C(181) TO C(335),C(602) PIXEL

      @ C(005),C(005) Say "Atenção! O Fornecedor incluído será incluído também como Cliente. Para isso, favor " Size C(202),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      @ C(014),C(005) Say "informar os campos abaixo pertinentes somente ao Cadastro de Clientes."              Size C(188),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      @ C(029),C(005) Say "Tipo"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      @ C(052),C(005) Say "Natureza"          Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgC      
      @ C(052),C(051) Say "Grupo de Clientes" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      
      @ C(038),C(005) ComboBox cTipo  Items aTipo   Size C(200),C(010) PIXEL OF oDlgC
      @ C(061),C(005) MsGet oNatureza Var cNatureza Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("SED")
      @ C(061),C(051) ComboBox cGrupo Items aGrupo  Size C(110),C(010) PIXEL OF oDlgC

      @ C(059),C(167) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgC ACTION (oDlgC:END() ) 

      ACTIVATE MSDIALOG oDlgC CENTERED 

      DbSelectArea("SA1")
      RecLock("SA1",.T.)
      A1_COD     := _Codigo
      A1_LOJA    := _Loja   
      A1_CGC     := SA2->A2_CGC
      A1_NATUREZ := cNatureza
      A1_GRPTRIB := Substr(cGrupo,01,03)
      A1_RISCO   := "E"
      A1_TIPO    := Substr(cTipo,01,01)

      If Len(Alltrim(SA2->A2_CGC)) == 14
         A1_PESSOA := "J"
      Else
         A1_PESSOA := "F"      
      Endif

   Else
      DbSelectArea("SA1")
      DbSetOrder(3)
      DbSeek(xfilial("SA1") + SA2->A2_CGC )
      Reclock("SA1",.F.)
   Endif  
  
   A1_NOME    := SA2->A2_NOME
   A1_NREDUZ  := SA2->A2_NREDUZ  
   A1_END     := SA2->A2_END
   A1_BAIRRO  := SA2->A2_BAIRRO
   A1_EST     := SA2->A2_EST
   A1_COD_MUN := SA2->A2_COD_MUN
   A1_MUN     := SA2->A2_MUN
   A1_CEP     := SA2->A2_CEP

   If Len(Alltrim(SA2->A2_CGC)) == 14
      A1_PESSOA := "J"
   Else
      A1_PESSOA := "F"      
   Endif

   A1_DDD     := SA2->A2_DDD
   A1_TEL     := SA2->A2_TEL
   A1_DDI     := SA2->A2_DDI
   A1_INSCRM  := SA2->A2_INSCRM
   A1_PAIS    := SA2->A2_PAIS
   A1_HPAGE   := SA2->A2_HPAGE
   A1_TELEX   := SA2->A2_TELEX
   A1_CNAE    := SA2->A2_CNAE
   A1_COMPLEM := SA2->A2_COMPLEM
   A1_INSCR   := SA2->A2_INSCR
   A1_EMAIL   := SA2->A2_EMAIL
   A1_PFISICA := SA2->A2_PFISICA

   Msunlock()

   // Restaura a posição inicial da tabela de Clientes
   RestArea(aRegistro)
   
Return(.T.)