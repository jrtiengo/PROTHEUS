#INCLUDE "AP5MAIL.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE  ENTER CHR(13)+CHR(10)
                                                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUTOMWFOS ºAutor  ³Fabiano Pereira     º Data ³  30/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Workflow para envio de Ordem Servico ao cliente.           º±±
±±º          ³ Disparado apos a alteracao do orcamento,                   º±±
±±º          ³ se a funcao MsgYesNo() resultar em True.                   º±±
±±º          ³ Disparado no Ponto de Entrada T450PVOS/T450PVOS            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus - Automatech                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AUTOMWFOS()

   // Variaveis Tecnicas
   Local _cQry		:= "" 													// Variavel auxiliar para manipulacao da query. Seleciona dados do Cabecalho.
   Local _cQry2		:= ""													// Variavel auxiliar para manipulacao da query. Update email do Cliente.
   Local _cQry3		:= ""													// Variavel auxiliar para manipulacao da query. Le os Itens do Orcamento.
   Local _lRet		:= .F.												   	// Flag para controle de execcao. F = Fluxo Normal, T = Encerramento da rotina.
   Local _lServ		:= .F.				                                    // Flag para controle das variaveis de servico.
   Local _lProd		:= .F.													// Flag para controle das variaveis de produto.
   Local _lOk		:= .T.													// Flag para controle do preenchimento dos apontamentos.
   Local _aInfo		:= {}													// Variavel para armazenar as informacoes do usuario.
   Local cCepPict	:= PesqPict("SA1","A1_CEP")								// Variavel para auxiliar na exibicao da mascara do CEP
   Local cCGCPict	:= PesqPict("SA1","A1_CGC")                             // Variavel para auxiliar na exibicao da mascara

   // Variável que contém a pasta onde será gravado o orçamento a ser enviado ao cliente
   Local xx_Pasta   := ""

   // Variaveis Auxiliares
   Local _nTotalPrc  := 0													// Variavel para armazenar o total. Funcao: (AB5->AB5_TOTAL * nPgto)/100)
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
   Local _cSubVen    := ""                                                  // Variável para armazenamento do Sub-Total.
   Local _cDesVen    := ""                                                  // Variável para armazenamento do valor do desconto.
   Local _cCodPro 	 := ""													// Variavel para armazenamento do codigo do produto.
   Local _cEmailTec	 := ""													// Variavel para armazenamento do email do Tecnico Responsavel.
   Local _cEmailAdd  := GetMv("MV_WFUEMAI")									// Variavel para armazenamento do email recebido do parametro.
   Local _cStatus 	 := ""

   Private oProcess															//Variavel para controle do objeto de manipulacao do workflow.
   Private oHtml								   								//Variavel para controle do objeto de manipulacao do workflow. Manipulacao  do HTML.
   Private cAB6NumOS	:=	AB6->AB6_NUMOS

   // Busca todos os dados do cabecalho
   _cNomeCli 	:=	AllTrim(Posicione("SA1",1,xFilial("SA1")+AB6->AB6_CODCLI+AB6->AB6_LOJA,"A1_NOME"))
   _cEmail		:= 	AllTrim(Posicione('SU5',1,xFilial('SU5')+AB6->AB6_CONTWF,'U5_EMAIL'))

   // Inicia o Processo de Workflow
   cCodProcesso := "ORDEM_DE_SERVICO"

   // Arquivo html template utilizado para montagem da aprovacao
   cHtmlModelo := "\workflow\htm\teca450.htm"

   // Assunto da mensagem 
   cAssunto := "Ordem de Serviço: "+ M->AB6_NUMOS 

   // Registre o nome do usuario corrente que esta criando o processo:
   cUsuarioProtheus:= SubStr(cUsuario,7,15)

   // Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
   oProcess := TWFProcess():New(cCodProcesso, cAssunto)

   // Crie uma tarefa.
   oProcess:NewTask(cAssunto, cHtmlModelo)

   oHtml := oProcess:oHtml
   Conout("(INICIO|ENVIA_ORDEM_DE_SERVICO)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )

   //Armazena dados do usuario
   PswOrder(1)
   If PswSeek(SubStr(cUsuario,7,15),.T.)
      _aInfo   := PswRet(1)
	  _cUser   := SubStr(cUsuario,7,15)		//aInfo[1,2]
   EndIf

   DbSelectArea("AB7");DbSetOrder(1);DbGoTop()
   If DbSeek(xFilial('AB7')+cAB6NumOS, .F.)
	  // ABB - AGENDA TECNICOS
	  _cCodTec 	:= AllTrim(Posicione("ABB",3,xFilial("ABB")+AB7->AB7_NUMOS,"ABB_CODTEC"))	//	ABB_FILIAL+ABB_NUMOS
	  _cTecRespon := AllTrim(Posicione("AA1",1,xFilial("AA1")+_cCodTec,"AA1_EMAIL"))
	  // AA1 - TECNICOS
	  If Empty(_cEmailAdd)
	     _cEmailTec := AllTrim(Posicione("AA1",1,xFilial("AA1")+_cTecRespon,"AA1_EMAIL"))
	  Else
	   	 _cEmailTec := Alltrim(_cEmailAdd)
	  EndIf
	
 	  /*
	  ALERT('EMAILS')
	  _cTecRespon := _cEmail
	  _cEmailAdd := _cEmail
	  _cEmailTec := _cEmail
	  */
	
	  _cTipoSit	:=	AllTrim(Posicione("AAG",1,xFilial("AA1")+AB7->AB7_CODPRB,"AAG_STAT"))
	
	  Do Case
		 Case _cTipoSit == "N"
		  	  __Situacao := "NORMAL"
		 Case _cTipoSit == "G"
			  __Situacao := "GARANTIA"
		 Case _cTipoSit == "P"
			  __Situacao := "GARANTIA PARCIAL"
		 OtherWise
			  __Situacao := "NORMAL"
	  EndCase
	
	  oHtml:ValByName("cNumeroCab", AB7->AB7_NUMOS)	 							   	 // Numero do etiqueta/orc. p/ cabecalho
	  oHtml:ValByName("cNumero"   , AB7->AB7_NUMOS)	 							     // Numero Orcamento
	  oHtml:ValByName("cNumOrc"   , AB7->AB7_NUMOS)                	                 // Numero real do Orcamento
	  oHtml:ValByName("cGarantia" , __Situacao)                                      // Situação da Etiqueta
	
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
	  DbSelectArea("SA1");DbSetOrder(1);DbGoTop()
	  If DbSeek(xFilial('SA1')+AB7->AB7_CODCLI+AB7->AB7_LOJA, .F.)
		 oHtml:ValByName("cNomCli"    , SubStr(SA1->A1_NOME,1,40))					    // Razao Social do Cliente
		 oHtml:ValByName("cTelCli"    , SA1->A1_TEL)								    // Telefone
		 oHtml:ValByName("cBairroCli" , SA1->A1_BAIRRO)								    // Bairro
		 oHtml:ValByName("cMunCli"    , SA1->A1_MUN)								    // Municipio
		 oHtml:ValByName("cCEPCli"    , Transform( SA1->A1_CEP, "@R 99999-999" ))	    // Cep
		 oHtml:ValByName("cEndCli"    , SA1->A1_END)								    // Endereco
		 oHtml:ValByName("cEstCli"    , SA1->A1_EST)								    // Estado
		 oHtml:ValByName("cCNPJCli"   , Transform(SA1->A1_CGC,cCgcPict))			    // CNPJ
		 oHtml:ValByName("cIECli"     , Transform(SA1->A1_INSCR ,"@R 999.999.999.999")) // Inscricao Estadual
	  EndIf

 	  // DO WHILE NO AB7
  	  DbSelectArea("AB7")
	  Do While !Eof() .And. AB7->AB7_NUMOS == cAB6NumOS
		
		 cDescProd 	:= 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DESC'))
		 cDAux 		:= 	AllTrim(Posicione('SB1',1,xFilial('SB1')+AB7->AB7_CODPRO,'B1_DAUX'))
		 cDescProd 	:= 	cDescProd + IIF(!Empty(cDAux), +cDAux, '')
		
		 // Grava um Item Diferenciado por Produto na tabela AB7
 		 If AB7->AB7_CODPRO != _cCodPro
			
			_cMemoObs		:=	MSMM(AB7->AB7_MEMO1)
			_cMemoLaudo	    := 	AB6->AB6_MLAUDO //MSMM(AB6->AB6_MEMO7)
			
			oHtml:ValByName("cDesc"       , SubStr(cDescProd,1,38))
			oHtml:ValByName("cNser"       , AB7->AB7_NUMSER)
			oHtml:ValByName("cMemoObs"    , _cMemoObs	)
			oHtml:ValByName("cLaudo"      , _cMemoLaudo )
			oHtml:ValByName("cTecRespon"  , Posicione("AA1",1,xFilial("AA1")+_cCodTec,"AA1_NOMTEC"))
			oHtml:ValByName("cCondPag"    , Posicione("SE4",1,xFilial("SE4")+AB6->AB6_CONPAG,"E4_DESCRI"))
			oHtml:ValByName("cEmailTec"   , _cEmailTec)
			oHtml:ValByName("cEmailParam" , _cEmailAdd)
			
			
			//oHtml:ValByName("cUMOrc"     , AB4TMP->B1_UM)
			//oHtml:ValByName("cQtdVen"    , Transform(1,"@E 999,999"))
			//oHtml:ValByName("codPro"     , AB4TMP->AB4_CODPRO)
			
		 EndIf
		
		 _cCodPro := AB7->AB7_CODPRO
		
		 // Grava as informacoes de workflow na tabela AB7. Motivo: Possivel auditoria rapida
  		 If Empty(AB7->AB7_WFDT)
			AB7->AB7_WFDT := dDataBase
		 EndIf
		
		 If Empty(AB7->AB7_WFEMAI)
			If (cUsername == "Administrador")
			   AB7->AB7_WFEMAI := GetMV("MV_RELACNT")
			Else
			   //AB7->AB7_WFEMAI := cEmailUsu
			EndIf
		 EndIf
		
		 AB7->AB7_WFID := oProcess:fProcessID
		
		 // Grava a indicação que foi enviado WorkFlow e data de Envio do WorkFlow ao Cliente
		 If !Empty(AB6->AB6_FWORK)
			AB6->AB6_DWORK := Date()
		 EndIf
		
		 If Empty(AB6->AB6_FWORK)
			AB6->AB6_PWORK := Date()
			AB6->AB6_HWORK := Time()
		 Endif
		
		 AB6->AB6_FWORK := "X"

		 // Busca os Itens da tabela  AB5, que Contem os Precos e Pecas Utilizadas
		 oHtml:ValByName("it.cDescMat"    , {})
		 oHtml:ValByName("it.cQtdVen"     , {})
		 oHtml:ValByName("it.cPrcVen"     , {})
		 oHtml:ValByName("it.cSubVen"     , {})
		 oHtml:ValByName("it.cDesVen"     , {})
		 oHtml:ValByName("it.cValor"      , {})
		 oHtml:ValByName("it.cMat"  		 , {})
		
		 oHtml:ValByName("it2.cDescMat"   , {})
		 oHtml:ValByName("it2.cQtdVen"    , {})
		 oHtml:ValByName("it2.cPrcVen"    , {})
		 oHtml:ValByName("it2.cSubVen"    , {})
		 oHtml:ValByName("it2.cDesVen"    , {})
		 oHtml:ValByName("it2.cValor"     , {})
		 oHtml:ValByName("it2.cMat"       , {})
		
		 DbSelectArea("AB8");DbSetOrder(1);DbGoTop()	//	AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE
		 If DbSeek(xFilial('AB8')+ AB7->AB7_NUMOS, .F.)
		    Do While !Eof() .And. AB8->AB8_NUMOS == AB7->AB7_NUMOS
				
				
		 	   nPgto    := Posicione("AA5",1,xFilial("AA5")+AB8->AB8_CODSER,"AA5_PRCCLI")	// 	AA5 - SERVICO
			   cServico := Posicione("AA5",1,xFilial("AA5")+AB8->AB8_CODSER,"AA5_DESCRI")	//	AA5 - SERVICO
			   cTipoPro := Posicione("SB1",1,xFilial("SB1")+AB8->AB8_CODPRO,"B1_TIPO")
				
			   _cDesPro := AB8->AB8_DESPRO
			   _cUM 	 := Posicione("SB1",1,xFilial("SB1")+AB8->AB8_CODPRO,"B1_UM")
			   _cQuant  := Transform(AB8->AB8_QUANT,"@E 999,999")
				
			   //					    _cVUnit  := "R$ " + Transform(((acolsAB5[1][_iy][6] * nPgto)/100),"@E 999,999.99")
			   //					    _cTotal	:= "R$ " + Transform(((acolsAB5[1][_iy][7] * nPgto)/100),"@E 9,999.99")
				
			   _cVUnit  := Transform(((  AB8->AB8_PRCLIS * nPgto)/100),"@E 999,999.99")
			   _cSubVen := Transform(((( AB8->AB8_QUANT  * AB8->AB8_PRCLIS) * nPgto)/100),"@E 999,999.99")
			   _cDesVen := Transform(((((AB8->AB8_QUANT  * AB8->AB8_PRCLIS) - AB8->AB8_TOTAL) * nPgto)/100),"@E 999,999.99")
			   _cTotal	 := Transform(((  AB8->AB8_TOTAL  * nPgto)/100),"@E 9,999.99")
				
			   _cCodPro := AB8->AB8_CODPRO
				
			   // Itens do Orcamento
			   If (cTipoPro == "MO")
					
			 	  Aadd(oHtml:ValByName("it.cDescMat")  , _cDesPro)
				  //							Aadd(oHtml:ValByName("it.cUMServ")   , _cUM)
				  Aadd(oHtml:ValByName("it.cQtdVen")   , _cQuant)
				  Aadd(oHtml:ValByName("it.cPrcVen")   , _cVUnit)
				  Aadd(oHtml:ValByName("it.cSubVen")   , _cSubVen)
				  Aadd(oHtml:ValByName("it.cDesVen")   , _cDesVen)
				  Aadd(oHtml:ValByName("it.cValor")    , _cTotal)
				  Aadd(oHtml:ValByName("it.cMat")      , _cCodPro)
					
				  _lServ := .T.
 			   Else
					
			   	  Aadd(oHtml:ValByName("it2.cDescMat")  , _cDesPro)
				  //							Aadd(oHtml:ValByName("it2.cUMServ")   , _cUM)
				  Aadd(oHtml:ValByName("it2.cQtdVen")   , _cQuant)
				  Aadd(oHtml:ValByName("it2.cPrcVen")   , _cVUnit)
				  Aadd(oHtml:ValByName("it2.cSubVen")   , _cSubVen)
				  Aadd(oHtml:ValByName("it2.cDesVen")   , _cDesVen)
				  Aadd(oHtml:ValByName("it2.cValor")    , _cTotal)
				  Aadd(oHtml:ValByName("it2.cMat")      , _cCodPro)
					
				  _lProd := .T.
			   EndIf 
				
			   // Soma os Totais
			   _nTotalPrc += ((AB8->AB8_TOTAL * nPgto)/100)
				
			   DbSelectArea("AB8")
			   DbSkip()
		    EndDo
			
		 EndIf
		
		 DbSelectArea("AB7")
		 DbSkip()

	  EndDo
	
      // Totais do Orcamento
	  oHtml:ValByName("cTotalPrc"  , "R$ " + Transform(_nTotalPrc,"@E 9,999,999.99"))
	
	  If !(_lServ)
	    Aadd(oHtml:ValByName("it.cDescMat")  , Space(2))
	    //	Aadd(oHtml:ValByName("it.cUMServ")   , Space(2))
	    Aadd(oHtml:ValByName("it.cQtdVen")   , Space(2))
	    Aadd(oHtml:ValByName("it.cPrcVen")   , Space(2))
	    Aadd(oHtml:ValByName("it.cSubVen")   , Space(2))
	    Aadd(oHtml:ValByName("it.cDesVen")   , Space(2))
	    Aadd(oHtml:ValByName("it.cValor")    , Space(2))
	    Aadd(oHtml:ValByName("it.cMat")      , Space(2))
	 EndIf
	
	 If !(_lProd)
	    Aadd(oHtml:ValByName("it2.cDescMat")  , Space(2))
	    //	Aadd(oHtml:ValByName("it2.cUMServ")   , Space(2))
	    Aadd(oHtml:ValByName("it2.cQtdVen")   , Space(2))
	    Aadd(oHtml:ValByName("it2.cPrcVen")   , Space(2))
	    Aadd(oHtml:ValByName("it2.cSubVen")   , Space(2))
	    Aadd(oHtml:ValByName("it2.cDesVen")   , Space(2))
	    Aadd(oHtml:ValByName("it2.cValor")    , Space(2))
	    Aadd(oHtml:ValByName("it2.cMat")      , Space(2))
	 EndIf
	
   EndIf

   /*
    ESSA VALIDACAO COLOQUEI NO AT450GRV - PE_TECA450.PRW
   If ((!_lProd) .And. (!_lServ))
	  MsgAlert("Ordem de Serviço sem apontamento, favor inseir os apontamentos.")
	  _lOk := .F.
   EndIf
   */

   If (_lOk)
	  //oProcess:oHtml := oHtml

	  // ***********************Primeira Etapa do processo***********************
	
 	  // ------------------------------------------------------------------- //
	  // Endereco do destinatario. Neste caso utiliza-se o diretorio htm     //
	  // devido a rotina utilizar o processo via link. Nesta primeira etapa  //
	  // e salvo o html no diretorio \web\messenger\emp01\htm.               //
	  // ------------------------------------------------------------------- //
  	  oProcess:cTo := "htm"
	
 	  // --------------------------------------------------------------- //
	  // Nnome da funcao de retorno a ser executada quando a mensagem de //
	  // espostas retornarem ao Workflow                                 //
	  // --------------------------------------------------------------- //
	  oProcess:bReturn := "U_RETWFOS(1)"
	
	  // ------------------------------------------------------------------ //
	  // Inicia o processo de gravacao do html no diretorio acima indicado, //
	  // armazenado na variavel cMailID que sera utilizada abaixo.          //
	  // ------------------------------------------------------------------ //
	  cMailID := oProcess:Start()
	
   	  // Repasse o texto do assunto criado para a propriedade especifica do processo.
  	  oProcess:cSubject := cAssunto
	
	  // ***********************Segunda Etapa do processo***********************
	
	  // Arquivo html template utilizado para montagem do html contendo o link (Enviado ao cliente)³
      Do Case
         Case cEmpAnt == "01"
     	      cHtmlModelo := "\workflow\wflinkos.htm"
         Case cEmpAnt == "02"
     	      cHtmlModelo := "\workflow\wflinkosTI.htm"
         Case cEmpAnt == "03"
     	      cHtmlModelo := "\workflow\wflinkos.htm"
         Otherwise
     	      cHtmlModelo := "\workflow\wflinkos.htm"
      EndCase
	
  	  // Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
  	  oProcess:= TWFProcess():New(cCodProcesso, cAssunto)
	
 	  // Crie uma tarefa.
  	  oProcess:NewTask(cAssunto, cHtmlModelo)
	
	  Do Case
	     Case cEmpAnt == "01"
   	          conout("(INICIO|WFLINKOS)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
	     Case cEmpAnt == "02"
   	          conout("(INICIO|WFLINKOSTI)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
	     Case cEmpAnt == "03"
   	          conout("(INICIO|WFLINKOS)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
	     Otherwise
   	          conout("(INICIO|WFLINKOS)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )
      EndCase
	
	  // Repasse o texto do assunto criado para a propriedade especifica do processo.
  	  oProcess:cSubject := cAssunto
	
	  // Endereco eletronico do destinatario.
	  oProcess:cTo := Alltrim(_cEmail)+";cristiano@automatech.com.br"
	
      // Insere nome do cliente da mensagem
	  //oProcess:ohtml:ValByName("usuario",_cNomeCli)
	
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
	
	     // Complementa o link com numero do Orcamento
 	  // oProcess:ohtml:ValByName("referente"," o orçamento de número " + AllTrim(AB3TMP->AB3_NUMORC))
	
  	  // ------------------------------------------------------------------- //
  	  // Eh necessario efetuar esta troca de WFHTTPRE.APW para WFHTTPRE.APL, //
	  // devido ao fato da mudanca na versao do Protheus 11.                 //
	  // ------------------------------------------------------------------- //
	  chave	     := "WFHTTPRET.APW"
	  cHtmlTexto := WFLoadFile("\web\messenger\" + xx_Pasta + "\htm\" + cMailID + ".htm")
	  cHtmlTexto := StrTran(cHtmlTexto,chave, "WFHTTPRET.APL")                       	
	  WFSaveFile("\web\messenger\" + xx_Pasta + "\htm\" + cMailID + ".htm", cHtmlTexto)

   EndIf
	
   // ------------------------------------------------------------------------- //
   // Apos ter repassado todas as informacoes necessarias para o workflow,      //
   // execute o metodo Start() para se gerado todo processo e enviar a mensagem //
   // ao destinatário.                                                          //
   // ------------------------------------------------------------------------- //
	oProcess:Start()
	
//  EndIf

//EndIf

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

User Function RETWFOS(cOpc,oProcess)

   Local _cNumOrc    := ""
   Local _cMen	      := ""
   Local _cNomeCli   := ""
   
   Private cEmailUsu := ""
   Private cEmailAdm := ""

   _cEmailTec := oProcess:oHtml:RetByName("cEmailTec")
   _cNumOrc   := oProcess:oHtml:RetByName("cNumOrc")
	
   // Altera flag no orcamento. Indica que Orcamento foi aprovador pelo cliente
   DbSelectArea("AB6");DbSetOrder(1);DbGoTop()
   If DbSeek(xFilial("AB6")+_cNumOrc, .F.)
		
	  _cNomeCli := AllTrim(Posicione("SA1",1,xFilial("SA1")+AB6->AB6_CODCLI+AB6->AB6_LOJA,"A1_NOME"))
	  _cMen 	  := ''
	  cSituaOS  := ''
		
	  If oProcess:oHtml:RetByName("Aprovacao") == "S"
	 	 cSituaOS := 'S'
	  ElseIf oProcess:oHtml:RetByName("Aprovacao") == "N"
		 cSituaOS := 'N'
	  EndIf
		
      // Carrega o nome de quem Aprovou ou Reprovou o Orçamento
      cQueAprRep := oProcess:oHtml:RetByName("QuemAprovou")

      // Carrega se o Orçamento foi ou não Aprovado
	  cSituaOS := ConsultaReqPecas(_cNumOrc,cSituaOS)
		
	  RecLock("AB6",.F.)

	  AB6->AB6_APROV  := cSituaOS
//	  AB6->AB6_COMC   := Chr(13)+Chr(10)+AB6->AB6_COMC + Alltrim(oProcess:oHtml:RetByName("Obs"))+Chr(13)+Chr(10)+"Em "+DtoC(dDataBase)+ " As "+Time()+ " "+Chr(13)+Chr(10)+ "***********************************************************************************************************"+Chr(13)+Chr(10)

      If cSituaOS == "S"
         AB6->AB6_COMC := Chr(13) + chr(10)  + ;
                          AB6->AB6_COMC      + ;
                          "Ordem de Serviço " + Alltrim(cSituaOS)                                    + ;
                          " Aprovada por "    + Alltrim(cQueAprRep)                                  + ;
                          " em "              + DtoC(dDataBase)                                      + ;
                          " as "              + Time() + " " + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                          "Observações: "     + Alltrim(oProcess:oHtml:RetByName("Obs"))             + Chr(13) + Chr(10) + ;
                          "*******************************************************************"      + Chr(13) + Chr(10)
      Else
         AB6->AB6_COMC := Chr(13) + chr(10)  + ;
                          AB6->AB6_COMC      + ;
                          "Ordem de Serviço " + Alltrim(cSituaOS)                                    + ;
                          " Reprovada por "   + Alltrim(cQueAprRep)                                  + ;
                          " em "              + DtoC(dDataBase)                                      + ;
                          " as "              + Time() + " " + Chr(13) + Chr(10) + Chr(13) + Chr(10) + ;
                          "Observações: "     + Alltrim(oProcess:oHtml:RetByName("Obs"))             + Chr(13) + Chr(10) + ;
                          "*******************************************************************"      + Chr(13) + Chr(10)
      Endif

      AB6->AB6_NROC   := oProcess:oHtml:RetByName("NumeroOC")

	  AB6->AB6_ENVIOA := dDataBase

	  MsUnlock()
		
	  /*
	  If oProcess:oHtml:RetByName("Aprovacao") == "S"
	 	 _cMen := "A Ordem de Serviço "+AB6->AB6_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi aprovado. "
		 _cMen += oProcess:oHtml:RetByName("Obs")
			
 	  ElseIf oProcess:oHtml:RetByName("Aprovacao") == "R"
	 	 _cMen := "A Ordem de Serviço "+AB6->AB6_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi rejeitado pelo motivo: "+Chr(13)+Chr(10)
	  EndIf
	  */
	
	  cHtml	:= '<html>'
	  cHtml	+= '<head>'
		
	  cHtml	+= '<h3 align = Left><font size="3" color='+IIF(cSituaOS$'SP', "#0000FF", "FF0000")+' face="Verdana"> ORDEM DE SERVIÇO '+IIF(cSituaOS $'SP', 'APROVADA', 'REJEITADA')+'</h3></font>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">NUM.OS: '+AB6->AB6_NUMOS+'</h3></font>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">OBS: '+AB6->AB6_COMC+'</h3></font>'
	  cHtml	+= '<br></br>'                                                                                                 
	  cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">CLIENTE: '+_cNomeCli+'</h3></font>'
	  cHtml	+= '<br></br>'
	  cHtml	+= '<br></br>'
	  cHtml 	+= '</head>'
	  cHtml 	+= '</html>'
		
  	  // U_AUTA007(cHtml,_cEmailTec)
	  U_AUTOMR20(cHtml, _cEmailTec, "", "")

	EndIf

Return()

Static Function ConsultaReqPecas(cNumOrc,cSituaOS)

   Local cQry := ""
   Local cRet := ""

   Iif(Select("TMPZZZ")!=0, TMPZZZ->(DbCloseArea()),)

   cQry := "Select ZZZ_NUMOS From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
   cQry += "Where "+chr(13) 
   cQry += "ZZZ.ZZZ_NUMOS =  '"+cNumOrc+"' And "+chr(13)
   cQry += "ZZZ.ZZZ_SALDO <> 0 And "+chr(13)
   cQry += "ZZZ.D_E_L_E_T_ <> '*' "
   cQry := ChangeQuery(cQry)

   dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TMPZZZ", .T., .T. )

   DbSelectArea("TMPZZZ"); DbGoTop()

   // Se houver pendencia na req. se pecas, gera status (Aprovada - Aguardado peças) .	
   While ! Eof()
	
      If (cSituaOS <> "N")
		 cRet := "P"
	  EndIf
		
	  TMPZZZ->(DbSkip())
   EndDo

   If (Empty(cRet))
	  cRet:= cSituaOS
   EndIf
	
   Iif(Select("TMPZZZ")!=0, TMPZZZ->(DbCloseArea()),)
	
   Conout("RETORNO:"+cRet)
	
Return(cRet)