#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM102.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/04/2012                                                          *
// Objetivo..: Programa que envia email ao cliente informado que foi aberto ou     *
//             encerrado o atendimento da Ordem de Serviço                         *
// Parâmetro.: _Tipo     - Indica se I - Abertura senão E - Encerramento           *
//             _Etiqueta - Nº da Etiqueta a ser pesquisada                         *
//**********************************************************************************

User Function AUTOM102(_Tipo, _Etiqueta)

   // Variaveis Tecnicas
   Local cSql        := ""
   Local _cQry		 := "" 													// Variavel auxiliar para manipulacao da query. Seleciona dados do Cabecalho.
   Local _cQry2		 := ""													// Variavel auxiliar para manipulacao da query. Update email do Cliente.
   Local _cQry3		 := ""													// Variavel auxiliar para manipulacao da query. Le os Itens do Orcamento.
   Local _lRet		 := .F.												   	// Flag para controle de execcao. F = Fluxo Normal, T = Encerramento da rotina.
   Local _lServ		 := .F.				                                    // Flag para controle das variaveis de servico.
   Local _lProd		 := .F.													// Flag para controle das variaveis de produto.
   Local _lOk		 := .T.													// Flag para controle do preenchimento dos apontamentos.
   Local _aInfo		 := {}													// Variavel para armazenar as informacoes do usuario.
   Local cCepPict	 := PesqPict("SA1","A1_CEP")							// Variavel para auxiliar na exibicao da mascara do CEP
   Local cCGCPict	 := PesqPict("SA1","A1_CGC")                            // Variavel para auxiliar na exibicao da mascara

   // Variaveis Auxiliares
   Local _nTotalPrc	 := 0													// Variavel para armazenar o total. Funcao: (AB5->AB5_TOTAL * nPgto)/100)
   Local _cCliMen	 := ""													// Variavel para armazenamento de mensagem ao usuario. Cliente XX nao cadastrado.
   Local _cUser		 := ""													// Variavel para armazenar o codigo do usuario.
   Local _cCodPro	 := ""													// Variavel para armazenar o codigo do produto.
   Local _cNomeCli	 := ""													// Variavel para armazenar o nome do cliente.	
   Local _cCliente	 := ""													// Variavel para armazenar o codigo do cliente.
   Local _cLojaCli	 := ""												    // Variavel para armazenar o loja do cliente.
   Local _cLaudo	 := ""													// Variavel para armazenamento do Memo Laudo.
   Local _cTecRespon := ""													// Variavel para armazenamento do Codigo do Tecnico Responsavel pelo Laudo.
   Local _cCondPag	 := ""													// Variavel para armazenamento da Condicao de Pagamento.
   Local _cEmail	 := Space(30) 											// Variavel para armazenamento do Email do cliente. 
   Local _cURL		 := GetMV("MV_WFURL")                                   // Variavel para armazenamento do parametro de URL do workflow.
   Local _cDesPro 	 := ""													// Variavel para armazenamento da descricao do produto
   Local _cUM	 	 := ""													// Variavel para armazenamento da Unidade de Medida.
   Local _cQuant  	 := ""													// Variavel para armazenamento da quantidade.
   Local _cVUnit  	 := ""													// Variavel para armazenamento do valor unitario.
   Local _cTotal	 := ""													// Variavel para armazenamento do valor total.
   Local _cCodPro 	 := ""													// Variavel para armazenamento do codigo do produto.
   Local _cEmailTec	 := ""													// Variavel para armazenamento do email do Tecnico Responsavel.
   Local _cEmailAdd  := GetMv("MV_WFUEMAI")									// Variavel para armazenamento do email recebido do parametro. 
   Local cVal_Orcamento := 0

   Private oProcess														    // Variavel para controle do objeto de manipulacao do workflow.
   Private	oHtml								   							// Variavel para controle do objeto de manipulacao do workflow. Manipulacao  do HTML.


   // Pesquisa dados do chamado técnico para envio de e-mail
   If _Tipo == "I"

      If Select("T_ETIQUETA") > 0
         T_ETIQUETA->( dbCloseArea() )
      EndIf		
     
      cSql := "SELECT "
      cSql += "       A.AB1_FILIAL, "
      cSql += "       A.AB1_ETIQUE ,"
      cSql += "       A.AB1_NRCHAM ,"
      cSql += "       A.AB1_CODCLI ,"
      cSql += "       A.AB1_LOJA   ," 
      cSql += "       A.AB1_ENVIOA ,"
      cSql += "       A.AB1_CONTWF ,"
      cSql += "       B.A1_NOME    ,"
      cSql += "       B.A1_EMAIL   ,"
      cSql += "       C.AB2_NRCHAM ,"
      cSql += "       C.AB2_CODPRO ,"
      cSql += "       C.AB2_NUMSER ,"
      cSql += "       D.B1_DESC    ,"
      cSql += "       D.B1_DAUX    ,"
      cSql += "       C.AB2_NUMSER ,"
      cSql += "       E.AC8_CODCON ,"
      cSql += "       F.U5_CODCONT ,"
      cSql += "       F.U5_CONTAT  ,"
      cSql += "       F.U5_EMAIL    "
      cSql += "  FROM " + RetSqlName("AB1") + " A, "
      cSql += "       " + RetSqlName("SA1") + " B, "
      cSql += "       " + RetSqlName("AB2") + " C, "
      cSql += "       " + RetSqlName("SB1") + " D, "    
      cSql += "       " + RetSqlName("AC8") + " E, "
      cSql += "       " + RetSqlName("SU5") + " F  " 
      cSql += " WHERE A.AB1_FILIAL   = '" + Alltrim(cFilAnt)   + "'"
      cSql += "   AND A.AB1_ETIQUE   = '" + Alltrim(_Etiqueta) + "'"
      cSql += "   AND A.AB1_ENVIOA   = ''"
      cSql += "   AND A.R_E_C_D_E_L_ = ''"
      cSql += "   AND A.AB1_CODCLI   = B.A1_COD      "
      cSql += "   AND A.AB1_LOJA     = B.A1_LOJA     "   
      cSql += "   AND A.AB1_FILIAL   = C.AB2_FILIAL  "
      cSql += "   AND A.AB1_NRCHAM   = C.AB2_NRCHAM  "
      cSql += "   AND C.AB2_CODPRO   = D.B1_COD      "
      cSql += "   AND E.AC8_CODENT   = A.AB1_CODCLI + A.AB1_LOJA "
      cSql += "   AND E.AC8_CODCON   = A.AB1_CONTWF  "
      cSql += "   AND E.AC8_CODCON   = F.U5_CODCONT  "
      
      cSql := ChangeQuery( cSql )
      MemoWrit(GetTempPath()+'AUTOM102.TXT', cSql)
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ETIQUETA", .T., .T. )

      If T_ETIQUETA->( EOF() )
         Return .T.
      Endif

      _Email := AllTrim(T_ETIQUETA->U5_EMAIL)
      
      If Empty(_Email)
         Return .T.
      EndIf


   Else

      // Pesquisa os dados do cliente para envio de email
      If Select("T_CLIENTE") > 0
         T_CLIENTE->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB6_FILIAL,"
      cSql += "       A.AB6_ETIQUE,"
      cSql += "       A.AB6_CODCLI,"
      cSql += "       A.AB6_LOJA  ,"
      cSql += "       B.AB1_FILIAL,"
      cSql += "       B.AB1_CONTWF,"
      cSql += "       C.AC8_CODCON," 
      cSql += "       D.U5_CODCONT,"
      cSql += "       D.U5_CONTAT ,"
      cSql += "       D.U5_EMAIL  ,"
      cSql += "       E.A1_NOME    "
      cSql += "  FROM " + RetSqlName("AB6") + " A, "
      cSql += "       " + RetSqlName("AB1") + " B, "
      cSql += "       " + RetSqlName("AC8") + " C, "
      cSql += "       " + RetSqlName("SU5") + " D, "
      cSql += "       " + RetSqlName("SA1") + " E  "
      cSql += "  WHERE A.AB6_FILIAL = '" + Alltrim(cFilAnt)   + "'"
      cSql += "    AND A.AB6_ETIQUE = '" + Alltrim(_Etiqueta) + "'"
      cSql += "    AND B.AB1_FILIAL = A.AB6_FILIAL"
      cSql += "    AND B.AB1_ETIQUE = A.AB6_ETIQUE"
      cSql += "    AND C.AC8_CODENT = A.AB6_CODCLI + A.AB6_LOJA "
      cSql += "    AND C.AC8_CODCON = B.AB1_CONTWF"
      cSql += "    AND C.AC8_CODCON = D.U5_CODCONT"  
      cSql += "    AND A.AB6_CODCLI = E.A1_COD    "
      cSql += "    AND A.AB6_LOJA   = E.A1_LOJA   "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

      _Cliente := T_CLIENTE->A1_NOME
      _Email   := T_CLIENTE->U5_EMAIL
      
      If Empty(_Email)
         Return .T.
      Endif   

      // Pesquisa a descrição do produto do atendimento
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT B1_DESC, "
      cSql += "       B1_DAUX  "
      cSql += "  FROM " + RetSqlName("SB1") 
      cSql += " WHERE B1_COD = '" + Alltrim(AB7->AB7_CODPRO) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

      _Produto := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
      _Serie   := AB7->AB7_NUMSER

   Endif
      


   
   // Pergunta se deseja enviar e-mail da abertura
   If MsgYesNo("Deseja enviar e-mail ao cliente informando da " + IIF(_Tipo == "I", "abertura", "encerramento") + " do atendimento?")

      If _Tipo == "I"
         If Empty(AllTrim(T_ETIQUETA->A1_EMAIL))
            Msgalert("Cliente não possui e-mail cadastrado. Verifique!")
            Return .T.
         Endif
      Else
         If Empty(Alltrim(_Email))
            Msgalert("Cliente não possui e-mail cadastrado. Verifique!")
            Return .T.
         Endif
      Endif         

      
      
      If _Tipo == "I"

         // Pesquisa o valor de Orçamento Técnico
         If Select("T_PARAMETROS") > 0
            T_PARAMETROS->( dbCloseArea() )
         EndIf
   
         cSql := ""
         cSql := "SELECT ZZ4_PRECO" 
         cSql += "  FROM " + RetSqlName("ZZ4")

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

         If !T_PARAMETROS->( EOF() )
            cVal_Orcamento := T_PARAMETROS->ZZ4_PRECO
         Else
            cVal_Orcamento := 75
         Endif
			

		// Atualiza o campo AB1_ENVIOA indicando que foi enviado o e-mail de aviso de abertura de chamado técnico.
		Dbselectarea("AB1");DbSetOrder(1) 
		If dbSeek(xFilial("AB1")+T_ETIQUETA->AB1_NRCHAM)
			RecLock("AB1",.F.)
				AB1->AB1_ENVIOA := Date()
			MsUnlock()
		Endif

	
         cTexto := ""
         cTexto += "Prezado(a) "                + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += AllTrim(T_ETIQUETA->A1_NOME) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "Informamos que foi aberto o atendimento nº " + T_ETIQUETA->AB1_ETIQUE + " para o equipamento " + CHR(13) + CHR(10)
         cTexto += AllTrim(T_ETIQUETA->B1_DESC) + " " + AllTrim(T_ETIQUETA->B1_DAUX) + ", referente ao nº de série " + AllTrim(T_ETIQUETA->AB2_NUMSER) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "OBS.: Caso o orçamento enviado venha a não ser aprovado, informamos que podera" + CHR(13) + CHR(10)
         cTexto += "ocorrer uma cobrança de uma taxa de reprovação no valor de R$ " +  TransForm(cVal_Orcamento,"@E 999,999.99") + " decorrente do" + CHR(13) + CHR(10)
         cTexto += "tempo de analise do técnico." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "Att." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "Automatech Sistemas de Automação Ltda" + CHR(13) + CHR(10)
         cTexto += "Fone: (51) - 3017-8300"                + CHR(13) + CHR(10)
         cTexto += "www.automatech.com.br"

         // Envia o relatório via e-mail
         cErroEnvio := U_AUTOMR20(cTexto, Alltrim(_Email), "", "Aviso de Abertura de Atendimento.")

		
      Else

         // Atualiza o campo AB9_ENVIOA indicando que foi enviado o e-mail de aviso de encerramento de chamado técnico.
         Dbselectarea("AB9")
         DbSetOrder(6) 
         If dbSeek(xFilial("AB9")+AB9->AB9_ETIQUE)
            RecLock("AB9",.F.)
      	     AB9->AB9_ENVIOA := Date()
      	     MsUnlock()
         Endif

         cTexto := ""
         cTexto += "Prezado(a) "     + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += Alltrim(_Cliente) + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "Informamos que foi encerrado o atendimento nº "  + _Etiqueta + " para o equipamento " + CHR(13) + CHR(10)
         cTexto += Alltrim(_Produto) + ", referente ao nº de série " + Alltrim(_Serie)                    + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "Att." + CHR(13) + CHR(10) + CHR(13) + CHR(10)
         cTexto += "Automatech Sistemas de Automação Ltda" + CHR(13) + CHR(10)
         cTexto += "Fone: (51) - 3017-8300"                + CHR(13) + CHR(10)
         cTexto += "www.automatech.com.br"

         // Envia o relatório via e-mail
         cErroEnvio := U_AUTOMR20(cTexto, Alltrim(_Email), "", "Aviso de Encerramento de Atendimento.")

      Endif                             

   Endif   

Return .T.