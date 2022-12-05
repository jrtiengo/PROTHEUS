#Include "Rwmake.ch"
#Include "Topconn.ch"
#Include "AP5Mail.ch"
#Include "Protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM114.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/06/2012                                                          *
// Objetivo..: Este programa é chamado pelo ponto de entrada SIGATEC. O objetivo   *
//             deste, é verificar se existem orçamentos com Status A e se a data   *
//             do último envio do workflow é superior a 2 dias (48 horas).  Caso   *
//             for, reenvia o workflow ao Cliente.                                 *
// Parâmetros: Nº do Orçamento                                                     *
//**********************************************************************************

User Function AUTOM114(_Orcamento)

   Local aColsAB5   := {}
   Local cSql       := ""
   Local _cQry		:= "" 													//Variavel auxiliar para manipulacao da query. Seleciona dados do Cabecalho.
   Local _cQry2		:= ""													//Variavel auxiliar para manipulacao da query. Update email do Cliente.
   Local _cQry3		:= ""													//Variavel auxiliar para manipulacao da query. Le os Itens do Orcamento.
   Local _lRet		:= .F.												   	//Flag para controle de execcao. F = Fluxo Normal, T = Encerramento da rotina.
   Local _lServ		:= .F.				                                    //Flag para controle das variaveis de servico.
   Local _lProd		:= .F.													//Flag para controle das variaveis de produto.
   Local _lOk		:= .T.													//Flag para controle do preenchimento dos apontamentos.
   Local _aInfo		:= {}													//Variavel para armazenar as informacoes do usuario.
   Local cCepPict	:= PesqPict("SA1","A1_CEP")								//Variavel para auxiliar na exibicao da mascara do CEP
   Local cCGCPict	:= PesqPict("SA1","A1_CGC")                             //Variavel para auxiliar na exibicao da mascara

   // Variável que guarda a pasta onde será gravado o orçamento a ser enviado ao cliente
   Local xx_Pasta   := ""

   // Variaveis Auxiliares
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
   Local _cURL		 := GetMV("MV_WFURL")                                   //Variavel para armazenamento do parametro de URL do workflow.
   Local _cDesPro 	 := ""													//Variavel para armazenamento da descricao do produto
   Local _cUM	 	 := ""													//Variavel para armazenamento da Unidade de Medida.
   Local _cQuant  	 := ""													//Variavel para armazenamento da quantidade.
   Local _cVUnit  	 := ""													//Variavel para armazenamento do valor unitario.
   Local _cTotal	 := ""													//Variavel para armazenamento do valor total.
   Local _cCodPro 	 := ""													//Variavel para armazenamento do codigo do produto.
   Local _cEmailTec	 := ""													//Variavel para armazenamento do email do Tecnico Responsavel.
   Local _cEmailAdd  := GetMv("MV_WFUEMAI")									//Variavel para armazenamento do email recebido do parametro. 

   Private oProcess															//Variavel para controle do objeto de manipulacao do workflow.
   Private oHtml								   							//Variavel para controle do objeto de manipulacao do workflow. Manipulacao  do HTML.

   // Busca todos os dados do cabecalhO
   If Select("AB3TMP") <>  0
      AB3TMP->(DbCloseArea())
   EndIf

   _cQry := "SELECT AB3.AB3_NUMORC," 
   _cQry += "       AB3.AB3_CODCLI,"
   _cQry += "       AB3.AB3_LOJA  ," 
   _cQry += "       AB3.AB3_EMISSA,"
   _cQry += "       AB3.AB3_RLAUDO,"
   _cQry += "       AB3.AB3_LAUDO ," 
   _cQry += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), AB3_LAUDO)) AS LAUDO,"
   _cQry += "       AB3.AB3_ETIQUE," 
   _cQry += "       AB3.AB3_CONPAG," 
   _cQry += "       SA1.A1_COD    ," 
   _cQry += "       SA1.A1_LOJA   ,"
   _cQry += "       SA1.A1_NOME   ," 
   _cQry += "       SA1.A1_TEL    ," 
   _cQry += "       SA1.A1_END    ," 
   _cQry += "       SA1.A1_CEP    ," 
   _cQry += "       SA1.A1_FAX    ," 
   _cQry += "       SA1.A1_MUN    ," 
   _cQry += "       SA1.A1_EST    ," 
   _cQry += "       SU5.U5_EMAIL  ," 
   _cQry += "       SU5.U5_CODCONT," 
   _cQry += "       SU5.U5_CONTAT ,"
   _cQry += "       SA1.A1_CGC    ," 
   _cQry += "       SA1.A1_INSCR  ," 
   _cQry += "       SA1.A1_ENDENT ," 
   _cQry += "       SA1.A1_CEPE   ," 
   _cQry += "       SA1.A1_EMAIL  ," 
   _cQry += "       SA1.A1_TIPO   ," 
   _cQry += "       SA1.A1_VEND   ,"
   _cQry += "       SA1.A1_ENDCOB ," 
   _cQry += "       SA1.A1_CEPC   ," 
   _cQry += "       SA1.A1_MUNE   ," 
   _cQry += "       SA1.A1_ESTE   ," 
   _cQry += "       SA1.A1_MUNC   ," 
   _cQry += "       SA1.A1_ESTC   ," 
   _cQry += "       SA1.A1_BAIRRO  "
   _cQry += "  FROM "      + RetSqlName("AB3") + " AB3(NoLock) "
   _cQry += " Inner Join " + RetSqlName("SA1") + " SA1(NoLock) "
   _cQry += "    On (AB3.AB3_CODCLI = SA1.A1_COD) And (AB3.AB3_LOJA = SA1.A1_LOJA) "
   _cQry += " Inner Join " + RetSqlName("SU5") + " SU5(NoLock) "
   _cQry += "    On (AB3.AB3_CONTWF = SU5.U5_CODCONT) And"
   _cQry += "       (AB3.AB3_FILIAL = '" + xFilial("AB3") + "') "
   _cQry += " Where AB3.D_E_L_E_T_ <> '*' "
   _cQry += "   And SA1.D_E_L_E_T_ <> '*' "
   _cQry += "   And SU5.D_E_L_E_T_ <> '*' "
   _cQry += "   And AB3.AB3_NUMORC  = '" + Alltrim(_Orcamento) + "' "
   _cQry += "   And AB3.AB3_STATUS  = 'A'"
   
   _cQry := ChangeQuery(_cQry)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"AB3TMP",.T.,.T.)

   Count To nRecCount

   // Caso tenha Dados.
   If (nRecCount > 0)

      DbSelectArea("AB3TMP")
	  DbGoTop()
		
	  // Caso nao encontre um e-mail, retorna
 	  _cEmail := AB3TMP->U5_EMAIL

	  If (Empty(_cEmail))
	     Return .T.
	  Endif   

   EndIf
	
   // Se as informacoes de e-mail estiverem corretas.
   If (! _lRet)
   
	   // Inicia o Processo de Workflow
   	   cCodProcesso := "ORCAMENTO"

	   // Arquivo html template utilizado para montagem da aprovacao
  	   cHtmlModelo := "\workflow\htm\teca400.htm"
	
  	   // Assunto da mensagem
  	   cAssunto := "Orçamento"
	
	   // Registre o nome do usuario corrente que esta criando o processo:
 	   cUsuarioProtheus:= SubStr(cUsuario,7,15)
	
	   // Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	   oProcess := TWFProcess():New(cCodProcesso, cAssunto) 
	
	   // Crie uma tarefa.
	   oProcess:NewTask(cAssunto, cHtmlModelo) 
	
	   oHtml := oProcess:oHtml
	   Conout("(INICIO|ENVIA_ORCAMENTO)Processo: " + oProcess:fProcessID + " - Task: " + oProcess:fTaskID )

       // Armazena dados do usuario
 	   PswOrder(1)
	   If PswSeek(cUsuario,.T.)
	      _aInfo   := PswRet(1)
		  _cUser   := aInfo[1,2]
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
		   	 _cEmailTec := _cEmailAdd
 		  EndIf
		
		  _cLaudo	:= AB3TMP->LAUDO
		  _cCondPag	:= AB3TMP->AB3_CONPAG
		     
		  oHtml:ValByName("cNumeroCab", AB3TMP->AB3_ETIQUE) 							   //Numero do etiqueta/orc. p/ cabecalho
		  oHtml:ValByName("cNumero"   , AB3TMP->AB3_ETIQUE) 							   //Numero da etiqueta/orc.		
	      oHtml:ValByName("cNumOrc"   , AB3TMP->AB3_NUMORC)                                //Numero real do Orcamento

		  // Dados da Empresa Corrente
		  oHtml:ValByName("cNomEmp", SM0->M0_NOMECOM)									  //Nome da Empresa corrente
		  oHtml:ValByName("cEnd"   , SM0->M0_ENDCOB)									  //Endereco
		  oHtml:ValByName("cMun"   , SM0->M0_CIDCOB)									  //Municipio
		  oHtml:ValByName("cEst"   , SM0->M0_ESTCOB)									  //Estado
		  oHtml:ValByName("cTel"   , SM0->M0_TEL)										  //Telefone
		  oHtml:ValByName("cFax"   , SM0->M0_FAX)										  //Fax	
		  oHtml:ValByName("cCNPJ"  , Transform(SM0->M0_CGC,cCgcPict))					  //CNPJ
		  oHtml:ValByName("cIE"	   , Transform(SM0->M0_INSC,"@R 999.999.999.999"))		  //Inscricao Estadual
		
		  // Dados do Cliente
		  oHtml:ValByName("cNomCli"    , SubStr(AB3TMP->A1_NOME,1,40))					     //Razao Social do Cliente
		  oHtml:ValByName("cTelCli"    , AB3TMP->A1_TEL)								     //Telefone
		  oHtml:ValByName("cBairroCli" , AB3TMP->A1_BAIRRO)								     //Bairro
		  oHtml:ValByName("cMunCli"    , AB3TMP->A1_MUN)								     //Municipio
		  oHtml:ValByName("cCEPCli"    , Transform( AB3TMP->A1_CEP, "@R 99999-999" ))	     //Cep
		  oHtml:ValByName("cEndCli"    , AB3TMP->A1_END)								     //Endereco
		  oHtml:ValByName("cEstCli"    , AB3TMP->A1_EST)								     //Estado
		  oHtml:ValByName("cCNPJCli"   , Transform(AB3TMP->A1_CGC,cCgcPict))			     //CNPJ
		  oHtml:ValByName("cIECli"     , Transform(AB3TMP->A1_INSCR ,"@R 999.999.999.999"))  //Inscricao Estadual
				
		  // Le os Itens do Orcamento
		  If Select("AB4TMP") <>  0
  		   	 AB4TMP->(DbCloseArea())
		  EndIf
		
		  _cQry3 := "SELECT AB3.AB3_NUMORC,"
		  _cQry3 += "       AB3_ETIQUE    ," 
		  _cQry3 += "       AB4.AB4_ITEM  ," 
		  _cQry3 += "       AB4.AB4_CODPRO," 
		  _cQry3 += "       AB4.AB4_NUMSER,"
		  _cQry3 += "       AB4.AB4_MEMO  ," 
		  _cQry3 += "       AB5.AB5_CODPRO," 
		  _cQry3 += "       AB5.AB5_DESPRO," 
		  _cQry3 += "       AB5.AB5_QUANT ," 
		  _cQry3 += "       AB5.AB5_VUNIT ," 
		  _cQry3 += "       AB5.AB5_TOTAL ," 
		  _cQry3 += "       AB5.AB5_CODSER,"
		  _cQry3 += "       SB1.B1_IPI    ," 
		  _cQry3 += "       SB1.B1_DESC   ," 
		  _cQry3 += "       SB1.B1_UM      "
		  _cQry3 += "  FROM "      + RetSqlName("AB3") + " AB3(NoLock) "
		  _cQry3 += " Inner Join " + RetSqlName("AB4") + " AB4(NoLock) "
		  _cQry3 += "    On (AB4.AB4_NUMORC = AB3.AB3_NUMORC) "
		  _cQry3 += " Inner Join " + RetSqlName("AB5") + " AB5(NoLock) "
		  _cQry3 += "    On (AB5.AB5_NUMORC = AB4.AB4_NUMORC) "
		  _cQry3 += " Inner Join " + RetSqlName("SB1") + " SB1(NoLock) "
		  _cQry3 += "    On (SB1.B1_COD = AB4.AB4_CODPRO) "
		  _cQry3 += " Where AB3.D_E_L_E_T_ <> '*'" 
		  _cQry3 += "   ANd SB1.D_E_L_E_T_ <> '*'"
		  _cQry3 += "   ANd AB4.D_E_L_E_T_ <> '*'"
		  _cQry3 += "   ANd AB5.D_E_L_E_T_ <> '*'"
		  _cQry3 += "   And AB3.AB3_NUMORC  = '" + Alltrim(AB3TMP->AB3_NUMORC) + "'"
		  _cQry3 += "   And AB3.AB3_FILIAL  = '" + xFilial("AB3") + "' "
		  _cQry3 += "   And AB4.AB4_FILIAL  = '" + xFilial("AB4") + "' "
		  _cQry3 += "   And AB5.AB5_FILIAL  = '" + xFilial("AB5") + "' "
		  _cQry3 += "   And SB1.B1_FILIAL   = '" + xFilial("SB1") + "' "
		
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

			   MsUnlock()

               // Grava a indicação que foi enviado WorkFlow e data de Envio do WorkFlow ao Cliente
    	       DbSelectArea("AB3")
	           DbSetOrder(1)
	           If DbSeek(xFilial("AB3")+_Orcamento)
     		      RecLock("AB3",.F.)
                  AB3->AB3_FWORK := "X"
                  AB3->AB3_DWORK := dDataBase
   	              MsUnlock()
   	           Endif   

			EndIf
			  
			// Busca os Itens da tabela  AB5, que Contem os Precos e Pecas Utilizadas
            oHtml:ValByName("it.cDescMat"    , {})
			oHtml:ValByName("it.cQtdVen"     , {})
			oHtml:ValByName("it.cPrcVen"     , {})
			oHtml:ValByName("it.cValor"      , {})
			oHtml:ValByName("it.cMat"  		 , {})
			
			oHtml:ValByName("it2.cDescMat"   , {})
			oHtml:ValByName("it2.cQtdVen"    , {})
			oHtml:ValByName("it2.cPrcVen"    , {})
			oHtml:ValByName("it2.cValor"     , {})
			oHtml:ValByName("it2.cMat"       , {})
			
            // Carrega o Array aColsAb5
   		    If Select("T_APONTA") <>  0
  			   T_APONTA->(DbCloseArea())
  		    EndIf

            cSql := ""
            cSql := "SELECT AB5_SUBITE,"
            cSql += "       AB5_CODPRO,"
            cSql += "       AB5_DESPRO,"
            cSql += "       AB5_CODSER,"
            cSql += "       AB5_QUANT ,"
            cSql += "       AB5_VUNIT ,"
            cSql += "       AB5_TOTAL ,"
            cSql += "       AB5_PRCLIS "
            cSql += "  FROM " + RetSqlName("AB5")
            cSql += " WHERE AB5_FILIAL = '" + Alltrim(cFilAnt)    + "'"
            cSql += "   AND AB5_NUMORC = '" + Alltrim(_Orcamento) + "'"
            cSql += "  AND D_E_L_E_T_ = ''"  

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTA", .T., .T. )

            WHILE !T_APONTA->( EOF() )
               aAdd( aColsAB5, { T_APONTA->AB5_SUBITE,; // 01
                                 T_APONTA->AB5_CODPRO,; // 02
                                 T_APONTA->AB5_DESPRO,; // 03
                                 T_APONTA->AB5_CODSER,; // 04
                                 T_APONTA->AB5_QUANT ,; // 05
                                 T_APONTA->AB5_VUNIT ,; // 06
                                 T_APONTA->AB5_TOTAL ,; // 07
                                 T_APONTA->AB5_PRCLIS,; // 08
                                 "AB5"               ,; // 09
                                 0                   ,; // 10
                                 .F. } )                // 11
               T_APONTA->( DbSkip() )
            ENDDO

   		    For _iy := 1 to Len(acolsAB5)
				
				If (!acolsAB5[_iy,11])	

				   nPgto    := Posicione("AA5",1,xFilial("AA5")+acolsAB5[_iy,04],"AA5_PRCCLI")
				   cServico := Posicione("AA5",1,xFilial("AA5")+acolsAB5[_iy,04],"AA5_DESCRI")
                   cTipoPro := Posicione("SB1",1,xFilial("SB1")+acolsAB5[_iy,02],"B1_TIPO")
				   
				   _cDesPro := SubStr(acolsAB5[_iy,03],1,38)
				   _cUM 	 := Posicione("SB1",1,xFilial("SB1")+acolsAB5[_iy,02],"B1_UM")
				   _cQuant  := Transform(acolsAB5[_iy,05],"@E 999,999")
				   _cVUnit  := Transform(((acolsAB5[_iy,06] * nPgto)/100),"@E 999,999.99")
				   _cTotal	 := Transform(((acolsAB5[_iy,07] * nPgto)/100),"@E 9,999.99")
				   _cCodPro := acolsAB5[_iy,02]
							
					// Itens do Orcamento
					If (cTipoPro == "MO")	
						   
						Aadd(oHtml:ValByName("it.cDescMat")  , _cDesPro)
						Aadd(oHtml:ValByName("it.cUMServ")   , _cUM)
						Aadd(oHtml:ValByName("it.cQtdVen")   , _cQuant)
						Aadd(oHtml:ValByName("it.cPrcVen")   , _cVUnit)
						Aadd(oHtml:ValByName("it.cValor")    , _cTotal)
						Aadd(oHtml:ValByName("it.cMat")      , _cCodPro)
						
						_lServ := .T.
					 Else
						  
						Aadd(oHtml:ValByName("it2.cDescMat")  , _cDesPro)
						Aadd(oHtml:ValByName("it2.cUMServ")   , _cUM)
						Aadd(oHtml:ValByName("it2.cQtdVen")   , _cQuant)
						Aadd(oHtml:ValByName("it2.cPrcVen")   , _cVUnit)
						Aadd(oHtml:ValByName("it2.cValor")    , _cTotal)
						Aadd(oHtml:ValByName("it2.cMat")      , _cCodPro)
					       
						_lProd := .T.
					 EndIf
						
					// Soma os Totais
                    _nTotalPrc += ((acolsAB5[_iy,07] * nPgto)/100)

		         EndIf
			      
	        Next

 		 EndIf
		
		 // Totais do Orcamento
 		 oHtml:ValByName("cTotalPrc"  , Transform(_nTotalPrc,"@E 9,999,999.99"))
					
         If !(_lServ)
    	    Aadd(oHtml:ValByName("it.cDescMat")  , Space(2))
	        Aadd(oHtml:ValByName("it.cUMServ")   , Space(2))
	        Aadd(oHtml:ValByName("it.cQtdVen")   , Space(2))
	        Aadd(oHtml:ValByName("it.cPrcVen")   , Space(2))
	        Aadd(oHtml:ValByName("it.cValor")    , Space(2))
	        Aadd(oHtml:ValByName("it.cMat")      , Space(2))	
         EndIf
		
         If !(_lProd)
	        Aadd(oHtml:ValByName("it2.cDescMat")  , Space(2))
	        Aadd(oHtml:ValByName("it2.cUMServ")   , Space(2))
	        Aadd(oHtml:ValByName("it2.cQtdVen")   , Space(2))
	        Aadd(oHtml:ValByName("it2.cPrcVen")   , Space(2))
	        Aadd(oHtml:ValByName("it2.cValor")    , Space(2))
	        Aadd(oHtml:ValByName("it2.cMat")      , Space(2))	
         EndIf

         DbSelectArea("AB3TMP")
         DbSkip()
       EndDo

       // Verifica se o Orçamento possui informação de Apontamento
       If ((!_lProd) .And. (!_lServ))
	      _lOk := .F.
       EndIf 	 

       If (_lOk)
          //oProcess:oHtml := oHtml

          // PRIMEIRA ETAPA DO PROCESSO

          // Endereco do destinatario. Neste caso utiliza-se o diretorio htm   
          // devido a rotina utilizar o processo via link. Nesta primeira etapa
          // e salvo o html no diretorio \web\messenger\emp01\htm.             
          oProcess:cTo := "htm"

          // Nnome da funcao de retorno a ser executada quando a mensagem de
          // espostas retornarem ao Workflow                                
          oProcess:bReturn := "U_AUTA012WWW(1)"

          // Inicia o processo de gravacao do html no diretorio acima indicado,
          // armazenado na variavel cMailID que sera utilizada abaixo.         
          cMailID := oProcess:Start()

          // Repasse o texto do assunto criado para a propriedade especifica do processo.
          oProcess:cSubject := cAssunto

          // SEGUNDA ETAPA DO PROCESSO

          // Arquivo html template utilizado para montagem do html contendo o link (Enviado ao cliente)
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
          oProcess:cTo := _cEmail+";cristiano@automatech.com.br"

          // Insere nome do cliente da mensagem
          //oProcess:ohtml:ValByName("usuario",_cNomeCli)

          // Insere endeco (link) de acesso ao workflow do cliente.         
          // Baseado no id do processo html gerado anteriormente.           
          // Com isso o cliente sera direcionado via webservice ao diretorio
          // do Protheus, para aprovacao do orcamento.                      

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

          // Eh necessario efetuar esta troca de WFHTTPRE.APW para WFHTTPRE.APL,
          // devido ao fato da mudanca na versao do Protheus 11.                
          chave	     := "WFHTTPRET.APW"
          cHtmlTexto := WFLoadFile("\web\messenger\" + xx_Pasta + "\htm\" + cMailID + ".htm")
          cHtmlTexto := StrTran(cHtmlTexto,chave, "WFHTTPRET.APL") 
          WFSaveFile("\web\messenger\" + xx_Pasta + "\htm\" + cMailID + ".htm", cHtmlTexto)

          // Apos ter repassado todas as informacoes necessarias para o workflow,     
          // execute o metodo Start() para se gerado todo processo e enviar a mensagem
          // ao destinatário.                                                         
          oProcess:Start()

       EndIf   
 
   EndIf //Fim do IF lRet

   If Select("AB4TMP") <>  0
   	  AB4TMP->(DbCloseArea())
   EndIf

   If Select("AB3TMP") <>  0
   	  AB3TMP->(DbCloseArea())
   EndIf

Return() 	

// Retorno do workflow de Orcamento.

User Function AUTA012WWW(cOpc,oProcess)

   Local _cNumOrc := ""
   Local _cMen	  := ""

   Private cEmailUsu := ""
   Private cEmailAdm := ""

   _cEmailTec := oProcess:oHtml:RetByName("cEmailTec")
                        
   If oProcess:oHtml:RetByName("Aprovacao") == "S"
	
      _cNumOrc   := oProcess:oHtml:RetByName("cNumOrc")

      // Altera flag no orcamento. Indica que Orcamento foi aprovador pelo cliente
  	  DbSelectArea("AB3")
	  DbSetOrder(1)
	  If DbSeek(xFilial("AB3")+_cNumOrc)
	  
	     RecLock("AB3",.F.)
	     AB3->AB3_APROV := "S"
         AB3->AB3_COMC  := oProcess:oHtml:RetByName("Obs")
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
         AB3->AB3_COMC  := oProcess:oHtml:RetByName("Obs")
	     MsUnlock()
		
		 _cMen := "O Orçamento "+AB3->AB3_NUMORC+" do Cliente "+oProcess:oHtml:RetByName("cNomCli")+" foi rejeitado pelo motivo: "+Chr(13)+Chr(10)
		 _cMen += oProcess:oHtml:RetByName("Obs")
		 cEmailUsu := ""

		 //U_AUTA007(_cMen,_cEmailTec)
	     U_AUTOMR20(_cMen, _cEmailTec, "", "")

 	 EndIf
  
  EndIf

Return()