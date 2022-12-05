#INCLUDE "protheus.ch"
/*
Jean Rehermann | JPC - 25/05/2011 - Ponto de entrada AT300GRV
Ponto de entrada na efetivação/alteração do chamado para gravar o campo MEMO no orçamento

Neste ponto não me preocupo com o tratamento de mais de um item no chamado (AB2) ou orçamento (AB4) pois
conforme o ponto de entrada AT300LLK() (ver no projeto) ele garante que não será permitida a inclusão de
chamados com mais de um item.
*/

User Function AT300GRV()

   Local _aAreaAB1   := AB1->( GetArea() ) // Salvo a área atual do AB1 (área selecionada neste ponto)
   Local _aAreaAB4   := AB4->( GetArea() ) // Salvo a área atual do AB4 (vou posicionar para verificar se existe orçamento)
   Local _aAreaAB3   := AB3->( GetArea() )
   Local _cEtique    := ""
   Local _cContWF    := ""                                                             
   Local _cNFEntrada := ""
   Local _Tabela     := ""
   Local _Condicao   := ""

   Local cSql        := ""
   Local lChumba     := .F.
   Local cCliente	 := Space(80)
   Local cTabela	 := Space(03)

   Local oCliente
   Local oTabela
	
   // Seleciono a tabela de orçamentos
   dbSelectArea("AB4")
   dbSetOrder(2)

   // Se for ação de inclusão e existir orçamento para o chamado (AB1 posicionado)
   If dbSeek( xFilial("AB4") + AB1->AB1_NRCHAM )

      // Recupero o conteúdo do campo MEMO do atendimento (AB2 posicionado)
	  cMemoAB2 := MSMM(AB2->AB2_MEMO)

      // Gravo novo campo MEMO no SYP para a tabela do orçamento (AB4)
	  MSMM(,TamSx3("AB4_MEMO2")[1],,cMemoAB2,1,,,"AB4","AB4_MEMO")
    
   EndIf  	
	  
   _cEtique    := AB1->AB1_ETIQUE
   _cContWF    := AB1->AB1_CONTWF  
   _cNFEntrada := AB1->AB1_NFENT
   _Tabela     := AB1->AB1_TABELA
   _Desconto   := AB1->AB1_DESC
   _Condicao   := AB1->AB1_CONPAG

   DbSelectArea("AB4")
   DbSetOrder(2)
  
   Dbselectarea("AB3")
   DbSetOrder(1) 

   If dbSeek(xFilial("AB3")+AB4->AB4_NUMORC)
      RecLock("AB3",.F.)
	  AB3->AB3_ETIQUE := _cEtique
	  AB3->AB3_CONTWF := _cContWF
	  AB3->AB3_NFENT  := _cNFEntrada
      AB3->AB3_TABELA := _Tabela
      AB3->AB3_DESC1  := _Desconto
      AB3->AB3_CONPAG := _Condicao

      // Caso a condição de pagamento esteja vazia, pesquisa no parametrizador automatech a condição de pagamento padrão a ser utilizada
      If Empty(Alltrim(AB3->AB3_CONPAG))

         // Pesquisa os valores para display
         If Select("T_PARAMETROS") > 0
            T_PARAMETROS->( dbCloseArea() )
         EndIf
   
         cSql := ""
         cSql := "SELECT ZZ4_COND FROM " + RetSqlName("ZZ4")

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

         If !T_PARAMETROS->( EOF() )
            AB3->AB3_CONPAG := T_PARAMETROS->ZZ4_COND
         Endif
            
      Endif   

	  MsUnlock()

   EndIf
   
   // Verifica se cliente do chamado tem tabela de preço associada a ele.
   // Se não tiver, abre dialogo solicitando a tabela de preço e grava no cadastro do cliente.
   If Select("T_CLIENTE") > 0
   	  T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A1_COD   , "
   cSql += "       A1_LOJA  , "
   cSql += "       A1_NOME  , "
   cSql += "       A1_TABELA, "
   cSql += "       A1_DESC    "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD  = '" + Alltrim(AB1->AB1_CODCLI) + "'"
   cSql += "   AND A1_LOJA = '" + Alltrim(AB1->AB1_LOJA)   + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
   
   If Empty(Alltrim(T_CLIENTE->A1_TABELA))
      
      Private oDlgC

      cCliente := T_CLIENTE->A1_COD + "." + T_CLIENTE->A1_LOJA + " - " + Alltrim(T_CLIENTE->A1_NOME)
      cTabela  := Space(03)

      DEFINE MSDIALOG oDlgC TITLE "Tabela de Preço - Cliente" FROM C(178),C(181) TO C(307),C(662) PIXEL

      @ C(005),C(005) Say "Atenção! O Cliente do chamado técnico não possui Tabela de Preço associada ao seu cadastro." Size C(230),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      @ C(014),C(005) Say "Favor informar uma Tabela de Preço para o Cliente."                                          Size C(125),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      @ C(047),C(032) Say "Tabela de Preço"                                                                             Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
      
      @ C(026),C(005) MsGet oCliente Var cCliente When lChumba Size C(229),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
      @ C(046),C(076) MsGet oTabela  Var cTabela               Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC F3("DA0")

      @ C(045),C(160) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgC ACTION( Atu_Tabela( AB1->AB1_CODCLI, AB1->AB1_LOJA, cTabela) )
 
      ACTIVATE MSDIALOG oDlgC CENTERED 
      
   Endif   

   // Envia para o programa que verifica se o Cliente possui débitos junto a Automatech.
   // Mostra novamente a mensagem porque pelo F3 do Cliente o gatilho não é disparado.
   U_AUTOM121(1, AB1->AB1_CODCLI, AB1->AB1_LOJA)

   // Em caso de inclusão, envia para programas de envio de email e impressão de etiqueta do produto do atendimento técnico.
   If Inclui()
      U_AUTOMR11()
      // Verifica se já foi enviado e-mail informativo ao cliente da abertura do atendimento.
      // Se não, dispara o programa AUTOM102 que envia e-mail ao cliente.
      If Empty(Alltrim(AB1->AB1_ENVIOA))
         U_AUTOM102("I", AB1->AB1_ETIQUE)
      Endif   

      // Abre o pograma de impressão do Comprovante de Recebimento de Equipamento
      U_AUTOM109(M->AB1_ETIQUE)

      // Envia para o programa que imprime etiqueta do poduto na abertura do chamado técnico.
      U_AUTOMR11()

   Endif   
	
   // Restaurando as áreas salvas
   RestArea( _aAreaAB4 )
   RestArea( _aAreaAB3 )
   RestArea( _aAreaAB1 )

Return()

// Função que atualiza o código da tabela de preço para o cliente selecionado no chamado técnico.
Static Function Atu_Tabela(_Cliente, _Loja, _Tabela)

   If Empty(Alltrim(_Tabela))
      MsgAlert("Tabela de Preço não informada para o Cliente.")
      Return .T.
   Endif

   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xfilial("SA1") + _Cliente + _Loja )
   Reclock("SA1",.F.)
   	A1_TABELA := _Tabela
   Msunlock()
      
   oDlgC:End()
   
Return .T.