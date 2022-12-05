#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUTA012   ºAutor  ³Lucas Moresco       º Data ³  25/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow para envio de orcamento ao cliente.               º±±
±±º          ³ Disparado apos a alteracao do orcamento,                   º±±
±±º          ³ se a funcao MsgYesNo() resultar em True.                   º±±
±±º          ³ Disparado no Ponto de Entrada PE_TECA400/AT400GRV          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus - Automatech                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AUTA012()

   // Variaveis Tecnicas
   Local 	_cQry		:= "" 													//Variavel auxiliar para manipulacao da query. Seleciona dados do Cabecalho.
   Local 	_cQry2		:= ""													//Variavel auxiliar para manipulacao da query. Update email do Cliente.
   Local 	_cQry3		:= ""													//Variavel auxiliar para manipulacao da query. Le os Itens do Orcamento.
   Local 	_lRet		:= .F.												   	//Flag para controle de execcao. F = Fluxo Normal, T = Encerramento da rotina.
   Local 	_lServ		:= .F.				                                    //Flag para controle das variaveis de servico.
   Local   _lProd		:= .F.													//Flag para controle das variaveis de produto.
   Local 	_lOk		:= .T.													//Flag para controle do preenchimento dos apontamentos.
   Local 	_aInfo		:= {}													//Variavel para armazenar as informacoes do usuario.
   Local 	cCepPict	:= PesqPict("SA1","A1_CEP")								//Variavel para auxiliar na exibicao da mascara do CEP
   Local 	cCGCPict	:= PesqPict("SA1","A1_CGC")                             //Variavel para auxiliar na exibicao da mascara
 
   // Variável que contém a pasta onde o arquivo do work flow será gravado
   Local   xx_Pasta    := ""

   // Variaveis Auxiliares
   Local _nTotalPrc  := 0													//Variavel para armazenar o total. Funcao: (AB5->AB5_TOTAL * nPgto)/100)
   Local _cCliMen	 := ""													//Variavel para armazenamento de mensagem ao usuario. Cliente XX nao cadastrado.
   Local _cUser		 := ""													//Variavel para armazenar o codigo do usuario.
   Local _cCodPro	 := ""													//Variavel para armazenar o codigo do produto.
   Local _cNomeCli	 := ""													//Variavel para armazenar o nome do cliente.	
   Local _cCliente	 := ""													//Variavel para armazenar o codigo do cliente.
   Local _cLojaCli	 := ""												    //Variavel para armazenar o loja do cliente.
   Local _cLaudo	 := ""													//Variavel para armazenamento do Memo Laudo.
   Local _cTecRespon := ""													//Variavel para armazenamento do Codigo do Tecnico Responsavel pelo Laudo.
   Local _cCondPag	 := ""													//Variavel para armazenamento da Condicao de Pagamento.
   Local _cEmail	 := Space(30) 											//Variavel para armazenamento do Email do cliente. 
   Local _cURL		 := GetMV("MV_WFURL")                                    //Variavel para armazenamento do parametro de URL do workflow.
   Local _cDesPro 	 := ""													//Variavel para armazenamento da descricao do produto
   Local _cUM	 	 := ""													//Variavel para armazenamento da Unidade de Medida.
   Local _cQuant  	 := ""													//Variavel para armazenamento da quantidade.
   Local _cVUnit  	 := ""													//Variavel para armazenamento do valor unitario.
   Local _cTotal	 := ""													//Variavel para armazenamento do valor total.
   Local _cSubVen    := ""                                                  //Variável para armazenamento do Sub-Total.
   Local _cDesVen    := ""                                                  //Variável para armazenamento do valor do desconto.
   Local _cCodPro 	 := ""													//Variavel para armazenamento do codigo do produto.
   Local _cEmailTec	 := ""													//Variavel para armazenamento do email do Tecnico Responsavel.
   Local _cEmailAdd  := GetMv("MV_WFUEMAI")									//Variavel para armazenamento do email recebido do parametro. 

   Private oProcess															//Variavel para controle do objeto de manipulacao do workflow.
   Private oHtml							   								//Variavel para controle do objeto de manipulacao do workflow. Manipulacao  do HTML.

   // Busca todos os dados do cabecalho
   If Select("AB3TMP") <>  0
      AB3TMP->(DbCloseArea())
   EndIf

   _cQry := "Select AB3.AB3_FILIAL, AB3.AB3_NUMORC, AB3.AB3_CODCLI, AB3.AB3_LOJA, AB3.AB3_EMISSA,AB3.AB3_RLAUDO,AB3.AB3_LAUDO, AB3.AB3_ETIQUE, AB3.AB3_CONPAG, AB3.AB3_MOEDA, SA1.A1_COD, SA1.A1_LOJA, "+chr(13)
   _cQry += "SA1.A1_NOME, SA1.A1_TEL, SA1.A1_END, SA1.A1_CEP, SA1.A1_FAX, SA1.A1_MUN, SA1.A1_EST, SU5.U5_EMAIL, SU5.U5_CODCONT, SU5.U5_CONTAT, "+chr(13)
   _cQry += "SA1.A1_CGC, SA1.A1_INSCR, SA1.A1_ENDENT, SA1.A1_CEPE, SA1.A1_EMAIL, SA1.A1_TIPO, SA1.A1_VEND, "+chr(13)
   _cQry += "SA1.A1_ENDCOB, SA1.A1_CEPC, SA1.A1_MUNE, SA1.A1_ESTE, SA1.A1_MUNC, SA1.A1_ESTC, SA1.A1_BAIRRO "+chr(13)
   _cQry += "From " +RetSqlName("AB3")+" AB3(NoLock) "+chr(13)
   _cQry += "Inner Join " +RetSqlName("SA1")+ " SA1(NoLock) "+chr(13)
   _cQry += "On (AB3.AB3_CODCLI = SA1.A1_COD) And (AB3.AB3_LOJA = SA1.A1_LOJA) "+chr(13)
   _cQry += "Inner Join " +RetSqlName("SU5")+ " SU5(NoLock) "+chr(13)
   _cQry += "On (AB3.AB3_CONTWF = SU5.U5_CODCONT) And"+chr(13)
   _cQry += "(AB3.AB3_FILIAL = '"+xFilial("AB3")+"') "
   _cQry += "Where AB3.D_E_L_E_T_ <> '*'  And SA1.D_E_L_E_T_ <> '*' And SU5.D_E_L_E_T_ <> '*' And AB3.AB3_NUMORC = '"+AB3->AB3_NUMORC+"' "+chr(13)
   _cQry += "And AB3.AB3_STATUS = 'A'"+chr(13)

   _cQry := ChangeQuery(_cQry)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"AB3TMP",.T.,.T.)

   Count To nRecCount

   // Caso tenha Dados.
   If (nRecCount > 0)
      DbSelectArea("AB3TMP")
	  DbGoTop()
		
	  // Caso nao encontre um e-mail
	  _cEmail := Alltrim(AB3TMP->U5_EMAIL)

	  If (Empty(_cEmail))

		 If MsgYesNo("O Contato "+AllTrim(AB3TMP->U5_CODCONT)+"-"+AllTrim(AB3TMP->U5_CONTAT)+" não tem um email cadastrado, deseja cadastrar agora?")

            _cEmail := Space(200)

		    @ 0,0 TO 150,300 DIALOG oDlg TITLE "Cadastro de Email do Contato"
		    @ 1,1 Say AllTrim (AB3TMP->U5_CODCONT) + " - " + AllTrim(AB3TMP->U5_CONTAT)
		    @ 2,1 Say "Contato sem Email cadastrado! Favor informar:"
		    @ 3,1 GET _cEmail PICTURE "@E" VALID .T. Size 120,10
		    @ 6,2 BUTTON "Confirmar" SIZE 35,10 ACTION Close(oDlg)			
		
		    ACTIVATE DIALOG oDlg CENTER	

		    // Grava o e-mail na na tabela de Cliente(SA1)
		    _cQry2 := "Update " +RetSqlName("SU5")+" Set U5_EMAIL = '"+AllTrim(_cEmail)+"' Where U5_CODCONT = '"+AB3TMP->U5_CODCONT+"' "
		    TcSqlExec(_cQry2)
		
		 EndIf

	  EndIf
	
	  // Caso nao tenha cadastrado e-mail, aborta a operacao
	  If Alltrim(_cEmail) == ""

	     _cCliMen  := AB3TMP->AB3_CODCLI +"-"+ AB3TMP->A1_NOME
	     MsgStop("Operação cancelada!")    
	     _cMen := "O Cliente "+_cCliMen+" não possui e-mail Cadastrado"
		
 	     // Envia e-mail informando que o cliente nao possui e-mail.
	     //U_AUTA007(_cMen,"")
         U_AUTOMR20(_cMen, "", "", "")	   
	     _lRet := .T.  

	  EndIf

//    // Pesquisa a situação da Etiqueta
//    If Select("T_FORMA") > 0
//      T_FORMA->( dbCloseArea() )
//    EndIf
//
//    cSql := ""
//    cSql := "SELECT A.AB3_FILIAL ,"
//    cSql += "       A.AB3_ETIQUE ,"
//    cSql += "       A.AB3_CODCLI ,"
//    cSql += "       A.AB3_LOJA   ,"
//    cSql += "       C.AB4_NUMORC ,"
//    cSql += "       C.AB4_CODPRO ,"
//    cSql += "       C.AB4_NUMSER ,"
//    cSql += "       C.AB4_CODPRB  "
//    cSql += "  FROM " + RetSqlName("AB3") + " A, "
//    cSql += "       " + RetSqlName("AB4") + " C  "
//    cSql += " WHERE A.AB3_ETIQUE = '" + Alltrim(AB3TMP->AB3_ETIQUE) + "'"
//    cSql += "   AND A.AB3_FILIAL = '" + Alltrim(AB3TMP->AB3_FILIAL) + "'"
//    cSql += "   AND A.AB3_NUMORC = C.AB4_NUMORC" 
//    cSql += "   AND A.D_E_L_E_T_ = ''"
//    cSql += "   AND C.AB4_FILIAL = '" + Alltrim(AB3TMP->AB3_FILIAL) + "'"
//
//    cSql := ChangeQuery( cSql )
//    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORMA", .T., .T. )
//
//    // Pesquisa a base instalada para carrega a data de garantia/contrato
//    If Select("T_BASE") > 0
//       T_BASE->( dbCloseArea() )
//    EndIf
//
//    cSql := ""
//    cSql := "SELECT AA3_FILIAL,"
//    cSql += "       AA3_CODCLI,"
//    cSql += "       AA3_LOJA  ,"
//    cSql += "       AA3_CODPRO,"
//    cSql += "       AA3_NUMSER,"
//    cSql += "       AA3_DTGAR ,"
//    cSql += "       AA3_CONTRT "
//    cSql += "  FROM " + RetSqlName("AA3")
//    cSql += " WHERE AA3_FILIAL = '" + Alltrim(AB3TMP->AB3_FILIAL)  + "'"
//    cSql += "   AND AA3_CODCLI = '" + Alltrim(AB3TMP->AB3_CODCLI)  + "'"
//    cSql += "   AND AA3_LOJA   = '" + Alltrim(AB3TMP->AB3_LOJA)    + "'"
//    cSql += "   AND AA3_CODPRO = '" + Alltrim(T_FORMA->AB4_CODPRO) + "'"
//    cSql += "   AND AA3_NUMSER = '" + Alltrim(T_FORMA->AB4_NUMSER) + "'"
//    cSql += "   AND D_E_L_E_T_ = ''"
//
//    cSql := ChangeQuery( cSql )
//    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BASE", .T., .T. )
//
//
//    If T_BASE->( EOF() )
//
//       __Situacao := "NORMAL"
//
//    Else
//
//       If Empty(Alltrim(T_Base->AA3_CONTRT))
//
//          If T_BASE->AA3_DTGAR >= DTOS(date())
//             __Situacao := "GARANTIA"
//          Else
//             __Situacao := "NORMAL"                
//          Endif                      
//
//       Else
//        
//          // Pesquisa a data de validade final do contrato para verificação da situação da Etiqueta
//          If Select("T_SITUACAO") > 0
//             T_SITUACAO->( dbCloseArea() )
//          EndIf
//
//          cSql := ""
//          cSql := "SELECT AAH_FILIAL,"
//          cSql += "       AAH_CONTRT,"
//          cSql += "       AAH_CODCLI,"
//          cSql += "       AAH_LOJA  ,"
//          cSql += "       AAH_FIMVLD "
//          cSql += "  FROM " + RetSqlName("AAH")
//          cSql += " WHERE AAH_FILIAL = '" + Alltrim(AB3TMP->AB3_FILIAL) + "'"
//          cSql += "   AND AAH_CONTRT = '" + Alltrim(T_Base->AA3_CONTRT) + "'"
//          cSql += "   AND AAH_CODCLI = '" + Alltrim(AB3TMP->AB3_CODCLI) + "'"
//          cSql += "   AND AAH_LOJA   = '" + Alltrim(AB3TMP->AB3_LOJA)   + "'"
//          cSql += "   AND D_E_L_E_T_ = ''
//
//          cSql := ChangeQuery( cSql )
//          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SITUACAO", .T., .T. )
//
//          If T_SITUACAO->( EOF() )
//             __Situacao := "NORMAL"                
//          Else
//             If DTOS(ctod(substr(T_SITUACAO->AAH_FIMVLD,07,02) + "/" + substr(T_SITUACAO->AAH_FIMVLD,05,02) + "/" + substr(T_SITUACAO->AAH_FIMVLD,01,04))) >= DTOS(date())
//                __Situacao := "CONTRATO"
//             Else
//                __Situacao := "NORMAL"                
//             Endif
//          Endif                        
//          
//       Endif
//          
//    Endif   

    // Pesquisa a situação da Etiqueta
    If Select("T_FORMA") > 0
       T_FORMA->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT A.AB3_FILIAL ,"
    cSql += "       A.AB3_ETIQUE ,"
    cSql += "       A.AB3_CODCLI ,"
    cSql += "       A.AB3_LOJA   ,"
    cSql += "       C.AB4_NUMORC ,"
    cSql += "       C.AB4_CODPRO ,"
    cSql += "       C.AB4_NUMSER ,"
    cSql += "       C.AB4_CODPRB ,"
    cSql += "       D.AAG_STAT    "
    cSql += "  FROM " + RetSqlName("AB3") + " A, "
    cSql += "       " + RetSqlName("AB4") + " C, "
    cSql += "       " + RetSqlName("AAG") + " D  "
    cSql += " WHERE A.AB3_ETIQUE = '" + Alltrim(AB3TMP->AB3_ETIQUE) + "'"
    cSql += "   AND A.AB3_FILIAL = '" + Alltrim(AB3TMP->AB3_FILIAL) + "'"
    cSql += "   AND A.AB3_NUMORC = C.AB4_NUMORC" 
    cSql += "   AND A.D_E_L_E_T_ = ''"
    cSql += "   AND C.AB4_FILIAL = '" + Alltrim(AB3TMP->AB3_FILIAL) + "'"
    cSql += "   AND C.AB4_CODPRB = D.AAG_CODPRB"
    cSql += "   AND D.D_E_L_E_T_ = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORMA", .T., .T. )

    Do Case
       Case T_FORMA->AAG_STAT == "N"
            __Situacao := "NORMAL"               
       Case T_FORMA->AAG_STAT == "G"
            __Situacao := "GARANTIA"               
       Case T_FORMA->AAG_STAT == "P"
            __Situacao := "GARANTIA PARCIAL"               
       OtherWise
            __Situacao := "NORMAL"                                
    EndCase

    // Se as informacoes de e-mail estiverem corretas.
    If (! _lRet)
   
       // Inicia o Processo de Workflow
   	   cCodProcesso := "ORCAMENTO"

	   // Arquivo html template utilizado para montagem da aprovacao
	   cHtmlModelo := "\workflow\htm\teca400.htm"

   	   // Assunto da mensagem
   	   cAssunto := "Orçamento"
	
 	   // Registre o nome do usuario corrente que esta criando o processo:
   	   cUsuarioProtheus:= SubStr(cUsuario,7,15)
	
 	   // Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
   	   oProcess := TWFProcess():New(cCodProcesso, cAssunto) 
	
  	   // Crie uma tarefa.
 	   oProcess:NewTask(cAssunto, cHtmlModelo) 
	
	   oHtml := oProcess:oHtml
	   Conout("(INICIO|ENVIA_ORCAMENTO)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )

       // Armazena dados do usuario
   	   PswOrder(1)
	   If PswSeek(SubStr(cUsuario,7,15),.T.)
		  _aInfo   := PswRet(1)
		  _cUser   := SubStr(cUsuario,7,15)		//aInfo[1,2]
	   EndIf
	
	   DbSelectArea("AB3TMP")
	   DbGoTop()
	   While !Eof()

	      _cCliMen    := AllTrim(AB3TMP->AB3_CODCLI +"-"+ AB3TMP->A1_NOME)
		  _cNomeCli   := AllTrim(AB3TMP->A1_NOME)
		  _cTecRespon := AB3TMP->AB3_RLAUDO
		
		  If (Empty(_cEmailAdd))
			 _cEmailTec := AllTrim(Posicione("AA1",1,xFilial("AA1")+_cTecRespon,"AA1_EMAIL"))
		  Else
			 _cEmailTec := Alltrim(_cEmailAdd)
		  EndIf
		
		  _cLaudo		:= AB3_LAUDO
		  _cCondPag	:= AB3TMP->AB3_CONPAG
		     
		  oHtml:ValByName("cNumeroCab", AB3TMP->AB3_ETIQUE) //Numero do etiqueta/orc. p/ cabecalho
		  oHtml:ValByName("cNumero"   , AB3TMP->AB3_ETIQUE) //Numero da etiqueta/orc.		
	      oHtml:ValByName("cNumOrc"   , AB3TMP->AB3_NUMORC) //Numero real do Orcamento
	      oHtml:ValByName("cGarantia" , __Situacao)         //Situação da Etiqueta

		  // Dados da Empresa Corrente
		  oHtml:ValByName("cNomEmp", SM0->M0_NOMECOM)									  // Nome da Empresa corrente
		  oHtml:ValByName("cEnd"   , SM0->M0_ENDCOB)									  // Endereco
		  oHtml:ValByName("cMun"   , SM0->M0_CIDCOB)									  // Municipio
		  oHtml:ValByName("cEst"   , SM0->M0_ESTCOB)									  // Estado
		  oHtml:ValByName("cTel"   , SM0->M0_TEL)										  // Telefone
		  oHtml:ValByName("cFax"   , SM0->M0_FAX)										  // Fax	
		  oHtml:ValByName("cCNPJ"  , Transform(SM0->M0_CGC,cCgcPict))					  // CNPJ
		  oHtml:ValByName("cIE"	   , Transform(SM0->M0_INSC,"@R 999.999.999.999"))		  // Inscricao Estadual
		
		  // Dados do Cliente
		  oHtml:ValByName("cNomCli"    , SubStr(AB3TMP->A1_NOME,1,40))					    // Razao Social do Cliente
		  oHtml:ValByName("cTelCli"    , AB3TMP->A1_TEL)								    // Telefone
		  oHtml:ValByName("cBairroCli" , AB3TMP->A1_BAIRRO)								    // Bairro
		  oHtml:ValByName("cMunCli"    , AB3TMP->A1_MUN)								    // Municipio
		  oHtml:ValByName("cCEPCli"    , Transform( AB3TMP->A1_CEP, "@R 99999-999" ))	    // Cep
		  oHtml:ValByName("cEndCli"    , AB3TMP->A1_END)								    // Endereco
		  oHtml:ValByName("cEstCli"    , AB3TMP->A1_EST)								    // Estado
		  oHtml:ValByName("cCNPJCli"   , Transform(AB3TMP->A1_CGC,cCgcPict))			    // CNPJ
		  oHtml:ValByName("cIECli"     , Transform(AB3TMP->A1_INSCR ,"@R 999.999.999.999")) // Inscricao Estadual
				
		  // Le os Itens do Orcamento
		  If Select("AB4TMP") <>  0
  			 AB4TMP->(DbCloseArea())
		  EndIf
		
		  _cQry3 := "Select AB3.AB3_NUMORC,AB3_ETIQUE, AB3.AB3_MOEDA, AB4.AB4_ITEM, AB4.AB4_CODPRO, AB4.AB4_NUMSER,AB4.AB4_MEMO, "+chr(13)
		  _cQry3 += "AB5.AB5_CODPRO, AB5.AB5_DESPRO, AB5.AB5_QUANT, AB5.AB5_VUNIT, AB5.AB5_TOTAL, AB5.AB5_CODSER, "+chr(13)
		  _cQry3 += "SB1.B1_IPI, SB1.B1_DESC, SB1.B1_UM "+chr(13)
		  _cQry3 += "From "+RetSqlName("AB3")+ " AB3(NoLock) "+chr(13)
		  _cQry3 += "Inner Join " +RetSqlName("AB4")+" AB4(NoLock) "+chr(13)
		  _cQry3 += "On (AB4.AB4_NUMORC = AB3.AB3_NUMORC) "+chr(13)
		  _cQry3 += "Inner Join " +RetSqlName("AB5")+" AB5(NoLock) "+chr(13) 
		  _cQry3 += "On (AB5.AB5_NUMORC = AB4.AB4_NUMORC) "+chr(13) 
		  _cQry3 += "Inner Join " +RetSqlName("SB1")+" SB1(NoLock) "+chr(13)
		  _cQry3 += "On (SB1.B1_COD = AB4.AB4_CODPRO) "+chr(13)
		  _cQry3 += "Where AB3.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND AB4.D_E_L_E_T_ <> '*' AND AB5.D_E_L_E_T_ <> '*' "+chr(13)
		  _cQry3 += "And AB3.AB3_NUMORC = '"+AB3TMP->AB3_NUMORC+"'"+chr(13)
		  _cQry3 += "And AB3.AB3_FILIAL = '"+xFilial("AB3")+"' "+chr(13)
		  _cQry3 += "And AB4.AB4_FILIAL = '"+xFilial("AB4")+"' "+chr(13)
		  _cQry3 += "And AB5.AB5_FILIAL = '"+xFilial("AB5")+"' "+chr(13)
		  _cQry3 += "And SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+chr(13)
		
		  _cQry3 := ChangeQuery(_cQry3)
		  DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry3),"AB4TMP",.T.,.T.)

		  Count To nRecCount

		  // Caso tenha Dados.
 		  If (nRecCount > 0)
			
		     DbSelectArea("AB4TMP")
			 DbGoTop()
									
			 // Grava um Item Diferenciado por Produto na tabela AB4
			 If (AB4TMP->AB4_CODPRO # _cCodPro)					
				
				// Itens do Orcamento
			   	oHtml:ValByName("cDesc"       , SubStr(AB4TMP->B1_DESC,1,38))
				oHtml:ValByName("cNser"       , AB4TMP->AB4_NUMSER)
				oHtml:ValByName("cMemoObs"    , MSMM(AB4TMP->AB4_MEMO))
				oHtml:ValByName("cLaudo"      , _cLaudo)
			   	oHtml:ValByName("cTecRespon"  , Posicione("AA1",1,xFilial("AA1")+_cTecRespon,"AA1_NOMTEC"))
			   	oHtml:ValByName("cCondPag"    , Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_DESCRI"))
			   	oHtml:ValByName("cEmailTec"   , _cEmailTec)
			   	oHtml:ValByName("cEmailParam" , _cEmailAdd)
			   		
		   		//oHtml:ValByName("cUMOrc"     , AB4TMP->B1_UM)
		   		//oHtml:ValByName("cQtdVen"    , Transform(1,"@E 999,999"))
		   		//oHtml:ValByName("codPro"     , AB4TMP->AB4_CODPRO)
				
			 EndIf
				
			 _cCodPro := AB4TMP->AB4_CODPRO

			 // Grava as informacoes de workflow na tabela AB4. Motivo: Possivel auditoria rapida
			 DbSelectArea("AB4")
			 DbSetOrder(1)
			 If DbSeek(xFilial("AB4")+AB3TMP->AB3_NUMORC+AB4TMP->AB4_ITEM)
				RecLock("AB4",.F.)
						
				If Empty(AB4->AB4_WFDT)
				   AB4->AB4_WFDT := dDataBase
				EndIf
						
				If Empty(AB4_WFEMAI)
				   If (cUsername == "Administrador")
					  AB4->AB4_WFEMAI := GetMV("MV_RELACNT")
				   Else
					  //AB4->AB4_WFEMAI := cEmailUsu
				   EndIf
				EndIf
					
				AB4->AB4_WFID := oProcess:fProcessID

                // Grava a indicação que foi enviado WorkFlow e data de Envio do WorkFlow ao Cliente
                AB3->AB3_FWORK := "X"
                AB3->AB3_DWORK := dDataBase

                If Empty(Alltrim(AB3->AB3_PWORK))
                   AB3->AB3_PWORK := dDataBase
                Endif   
				
				MsUnlock()
			 EndIf
			  
			 // Busca os Itens da tabela  AB5, que Contem os Precos e Pecas Utilizadas
             oHtml:ValByName("it.cDescMat"    , {})
			 oHtml:ValByName("it.cQtdVen"     , {})
			 oHtml:ValByName("it.cPrcVen"     , {})
			 oHtml:ValByName("it.cSubVen"     , {})
			 oHtml:ValByName("it.cDesVen"     , {})
			 oHtml:ValByName("it.cValor"      , {})
			 oHtml:ValByName("it.cMat"  	  , {})
			
			 oHtml:ValByName("it2.cDescMat"   , {})
			 oHtml:ValByName("it2.cQtdVen"    , {})
			 oHtml:ValByName("it2.cPrcVen"    , {})
			 oHtml:ValByName("it2.cSubVen"    , {})
			 oHtml:ValByName("it2.cDesVen"    , {})
			 oHtml:ValByName("it2.cValor"     , {})
			 oHtml:ValByName("it2.cMat"       , {})
			
          	 For _iy := 1 to Len(acolsAB5[1])                         
					
			     If (!acolsAB5[1][_iy][11])
						
					nPgto    := Posicione("AA5",1,xFilial("AA5")+acolsAB5[1][_iy][4],"AA5_PRCCLI") 	//	SERVICO
					cServico := Posicione("AA5",1,xFilial("AA5")+acolsAB5[1][_iy][4],"AA5_DESCRI")	//	SERVICO
                    cTipoPro := Posicione("SB1",1,xFilial("SB1")+acolsAB5[1][_iy][2],"B1_TIPO")		//	COD.PRODUTO
				   
				    _cDesPro := SubStr(acolsAB5[1][_iy][3],1,38)									//	DESC.PRODUTO
					_cUM 	 := Posicione("SB1",1,xFilial("SB1")+acolsAB5[1][_iy][2],"B1_UM")		//	COD.PRODUTO
					_cQuant  := Transform(acolsAB5[1][_iy][5],"@E 999,999")							//	QUANTIDADE

//					_cVUnit  := "R$ " + Transform(((acolsAB5[1][_iy][6] * nPgto)/100),"@E 999,999.99")
//					_cTotal	:= "R$ " + Transform(((acolsAB5[1][_iy][7] * nPgto)/100),"@E 9,999.99")

  					_cVUnit  := Transform(((acolsAB5[1][_iy][8] * nPgto)/100),"@E 999,999.99")		//	PRECO LISTA
                    _cSubVen := Transform((((acolsAB5[1][_iy][5] * acolsAB5[1][_iy][8]) * nPgto)/100),"@E 999,999.99")	//	QTD * PRECO LISTA
                    _cDesVen := Transform(((((acolsAB5[1][_iy][5] * acolsAB5[1][_iy][8]) - acolsAB5[1][_iy][7]) * nPgto)/100),"@E 999,999.99")	//	( (QTD * PRC.LISTA) - TOTAL ) 
  				    _cTotal	:= Transform(((acolsAB5[1][_iy][7] * nPgto)/100),"@E 9,999.99") // TOTAL

					_cCodPro := acolsAB5[1][_iy][2]
							
					// Itens do Orcamento
					If (cTipoPro == "MO")	
						   
					   Aadd(oHtml:ValByName("it.cDescMat")  , _cDesPro)
//					   Aadd(oHtml:ValByName("it.cUMServ")   , _cUM)
					   Aadd(oHtml:ValByName("it.cQtdVen")   , _cQuant)
					   Aadd(oHtml:ValByName("it.cPrcVen")   , _cVUnit)
					   Aadd(oHtml:ValByName("it.cSubVen")   , _cSubVen)
					   Aadd(oHtml:ValByName("it.cDesVen")   , _cDesVen)
					   Aadd(oHtml:ValByName("it.cValor")    , _cTotal)
					   Aadd(oHtml:ValByName("it.cMat")      , _cCodPro)
						
					   _lServ := .T.
					Else
						  
					   Aadd(oHtml:ValByName("it2.cDescMat")  , _cDesPro)
//					   Aadd(oHtml:ValByName("it2.cUMServ")   , _cUM)
					   Aadd(oHtml:ValByName("it2.cQtdVen")   , _cQuant)
					   Aadd(oHtml:ValByName("it2.cPrcVen")   , _cVUnit)
					   Aadd(oHtml:ValByName("it2.cSubVen")   , _cSubVen)
					   Aadd(oHtml:ValByName("it2.cDesVen")   , _cDesVen)
					   Aadd(oHtml:ValByName("it2.cValor")    , _cTotal)
					   Aadd(oHtml:ValByName("it2.cMat")      , _cCodPro)
					       
					   _lProd := .T.
					EndIf
						
					// Soma os Totais
                    _nTotalPrc += ((acolsAB5[1][_iy][7] * nPgto)/100)
		         EndIf
			      
		     Next
		  EndIf
		
		  // Totais do Orcamento
  	      oHtml:ValByName("cTotalPrc"  , "R$ " + Transform(_nTotalPrc,"@E 9,999,999.99"))
					
          If !(_lServ)
       	     Aadd(oHtml:ValByName("it.cDescMat")  , Space(2))
//	         Aadd(oHtml:ValByName("it.cUMServ")   , Space(2))
	         Aadd(oHtml:ValByName("it.cQtdVen")   , Space(2))
	         Aadd(oHtml:ValByName("it.cPrcVen")   , Space(2))
	         Aadd(oHtml:ValByName("it.cSubVen")   , Space(2))
	         Aadd(oHtml:ValByName("it.cDesVen")   , Space(2))	
	         Aadd(oHtml:ValByName("it.cValor")    , Space(2))
	         Aadd(oHtml:ValByName("it.cMat")      , Space(2))	
          EndIf
		
          If !(_lProd)
  	         Aadd(oHtml:ValByName("it2.cDescMat")  , Space(2))
//	         Aadd(oHtml:ValByName("it2.cUMServ")   , Space(2))
	         Aadd(oHtml:ValByName("it2.cQtdVen")   , Space(2))
	         Aadd(oHtml:ValByName("it2.cPrcVen")   , Space(2))
	         Aadd(oHtml:ValByName("it2.cSubVen")   , Space(2))
	         Aadd(oHtml:ValByName("it2.cDesVen")   , Space(2))	
	         Aadd(oHtml:ValByName("it2.cValor")    , Space(2))
	         Aadd(oHtml:ValByName("it2.cMat")      , Space(2))	
          EndIf

          DbSelectArea("AB3TMP")
          DbSkip()
       EndDo

       If ((!_lProd) .And. (!_lServ))
    	  MsgAlert("Orçamento sem apontamento, favor inseir os apontamentos.")
	      _lOk := .F.
       EndIf 	 

       If (_lOk)
          //oProcess:oHtml := oHtml

          // ***********************Primeira Etapa do processo***********************

          // ------------------------------------------------------------------ //
	      // Endereco do destinatario. Neste caso utiliza-se o diretorio htm    //
          // devido a rotina utilizar o processo via link. Nesta primeira etapa //
          // e salvo o html no diretorio \web\messenger\emp01\htm ou na pasta   //
          // \web\messenger\emp02\htm(Conforme a Empresa Logada)                //
          // ------------------------------------------------------------------ //
          oProcess:cTo := "htm"

          // Nnome da funcao de retorno a ser executada quando a mensagem de
          // espostas retornarem ao Workflow                                
          oProcess:bReturn := "U_AUTA012RET(1)"

          // Inicia o processo de gravacao do html no diretorio acima indicado,
          // armazenado na variavel cMailID que sera utilizada abaixo.         
          cMailID := oProcess:Start()

          // Repasse o texto do assunto criado para a propriedade especifica do processo.
          oProcess:cSubject := cAssunto

          // ***********************Segunda Etapa do processo*********************** 

          // Arquivo html template utilizado para montagem do html contendo o link (Enviado ao cliente)

          // Tarefa: #2790
          // Conforme a Empresa logada, seleciona o arquivo a ser enviado ao cliente
          Do Case 
             Case cEmpAnt == "01"
                  cHtmlModelo := "\workflow\wflink.htm"
             Case cEmpAnt == "02"
                  cHtmlModelo := "\workflow\wflinkTI.htm"
             Case cEmpAnt == "03"
                  cHtmlModelo := "\workflow\wflink.htm"
             Otherwise
                  cHtmlModelo := "\workflow\wflink.htm"           
          EndCase        

          // Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
          oProcess:= TWFProcess():New(cCodProcesso, cAssunto) 

          // Crie uma tarefa.
          oProcess:NewTask(cAssunto, cHtmlModelo) 

          Do Case 
             Case cEmpAnt == "01"
                  conout("(INICIO|WFLINK)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
             Case cEmpAnt == "02"
                  conout("(INICIO|WFLINKTI)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
             Case cEmpAnt == "03"
                  conout("(INICIO|WFLINK)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
             Otherwise
                  conout("(INICIO|WFLINK)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
          EndCase                   

          // Repasse o texto do assunto criado para a propriedade especifica do processo.
          oProcess:cSubject := cAssunto

          // Endereco eletronico do destinatario.
          If !Empty(_cEmail)
     	     oProcess:cTo := Alltrim(_cEmail)+";cristiano@automatech.com.br"
          EndIF

          // Insere nome do cliente da mensagem
          //oProcess:ohtml:ValByName("usuario",_cNomeCli)

          // --------------------------------------------------------------- //
          // Insere endeco (link) de acesso ao workflow do cliente.          //
          // Baseado no id do processo html gerado anteriormente.            //
          // Com isso o cliente sera direcionado via webservice ao diretorio //
          // do Protheus, para aprovacao do orcamento.                       //
          // --------------------------------------------------------------- //
          Do Case
             Case cEmpAnt == "01"
                  xx_Pasta := "emp01"
             Case cEmpAnt == "02"
                  xx_Pasta := "emp02"
             Case cEmpAnt == "03"
                  xx_Pasta := "emp03"
             Otherwise
                  xx_Pasta := "emp01"
          EndCase        

          oProcess:ohtml:ValByName("proc_link","http://" + _cURL + "/messenger/" + xx_Pasta + "/htm/" + cMailID + ".htm")
          oProcess:ohtml:ValByName("proc_link2","mailto:orcamento@automatech.com.br") 
          oProcess:ohtml:ValByName("proc_link3","www.automatech.com.br") 

                          // Complementa o link com numero do Orcamento
          //oProcess:ohtml:ValByName("referente"," o orçamento de número " + AllTrim(AB3TMP->AB3_NUMORC))

         // ------------------------------------------------------------------- //
         // Eh necessario efetuar esta troca de WFHTTPRE.APW para WFHTTPRE.APL, //
         // devido ao fato da mudanca na versao do Protheus 11.                 //
         // ------------------------------------------------------------------- //
         chave	    := "WFHTTPRET.APW"
         cHtmlTexto := WFLoadFile("\web\messenger\" + xx_Pasta + "\htm\" + cMailID + ".htm")
         cHtmlTexto := StrTran(cHtmlTexto,chave, "WFHTTPRET.APL") 
         WFSaveFile("\web\messenger\" + xx_Pasta + "\htm\" + cMailID + ".htm", cHtmlTexto)

         // ------------------------------------------------------------------------- //
         // Apos ter repassado todas as informacoes necessarias para o workflow,      //
         // execute o metodo Start() para se gerado todo processo e enviar a mensagem //
         // ao destinatário.                                                          //
         // ------------------------------------------------------------------------- //
         oProcess:Start()

      EndIf   
 
   EndIf //Fim do IF lRet

EndIf

If Select("AB4TMP") <>  0
	AB4TMP->(DbCloseArea())
EndIf

If Select("AB3TMP") <>  0
	AB3TMP->(DbCloseArea())
EndIf

Return() 	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUTA012RETºAutor  ³Lucas Moresco       º Data ³  01/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³	Retorno do workflow de Orcamento.						  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus - Automatech                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AUTA012RET(cOpc,oProcess)
   
   Local _cNumOrc := ""
   Local _cMen	  := ""

   Private cEmailUsu := ""
   Private cEmailAdm := ""

   _cEmailTec := oProcess:oHtml:RetByName("cEmailTec")
                        
   If oProcess:oHtml:RetByName("Aprovacao") == "S"

      _cNumOrc := oProcess:oHtml:RetByName("cNumOrc")

      // Altera flag no orcamento. Indica que Orcamento foi aprovador pelo cliente
  	  DbSelectArea("AB3")
	  DbSetOrder(1)
	  If DbSeek(xFilial("AB3")+_cNumOrc)
	  
	     RecLock("AB3",.F.)
	     AB3->AB3_APROV := "S"
         If Empty(Alltrim(AB3->AB3_SITUA))
            AB3->AB3_SITUA := "A"
         Endif   
         AB3->AB3_COMC  := Alltrim(oProcess:oHtml:RetByName("Obs"))
	     MsUnlock()
	
  	     // Envia email para o tecnico avisando que o orcamento foi aprovado
         _cMen := "O Orçamento "+AB3->AB3_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi aprovado. "
	     _cMen += oProcess:oHtml:RetByName("Obs")
	     cEmailUsu := ""
	     //U_AUTA007(_cMen,_cEmailTec)
         U_AUTOMR20(_cMen, _cEmailTec, "", "")	   
	
   	  EndIf
	
   Else

      // Envia email para o tecnico avisando que o orcamento foi rejeitado
	  _cNumOrc := oProcess:oHtml:RetByName("cNumOrc")

	  DbSelectArea("AB3")
	  DbSetOrder(1)
	  If DbSeek(xFilial("AB3")+_cNumOrc)
		
         // Altera flag no orcamento. Indica que Orcamento foi rejeitado pelo cliente
 		 RecLock("AB3",.F.)
	     AB3->AB3_APROV := "N"
         If Empty(Alltrim(AB3->AB3_SITUA))
            AB3->AB3_SITUA := "R"
         Endif   
         AB3->AB3_COMC  := Alltrim(oProcess:oHtml:RetByName("Obs"))
	     MsUnlock()
		
		 _cMen := "O Orçamento "+AB3->AB3_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi rejeitado pelo motivo: "+Chr(13)+Chr(10)
		 _cMen += oProcess:oHtml:RetByName("Obs")
		 cEmailUsu := ""

         // Envio de e-mail
		 //U_AUTA007(_cMen,Alltrim(_cEmailTec))
         U_AUTOMR20(_cMen, _cEmailTec, "", "")	   

 	 EndIf
  
  EndIf

Return()