#INCLUDE "protheus.ch"                                 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BFPC004D  ³ Autor ³ Sande Ribeiro      º Data ³  10/10/10   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importa dados do Excel									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programa  ³GENERICO                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sande       ³15/07/11³      ³ Nao validar a conta principal como conta ³±±
±±³Ribeiro     ³        ³      ³ orcamentaria			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sande       ³18/08/11³      ³ Fazer o tratamento do campo operacao das ³±±
±±³Ribeiro     ³        ³      ³ planilhas orcamentarias	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sande       ³22/08/11³      ³ Alteracao da utilizacao da funcao strzero³±±
±±³Ribeiro     ³        ³      ³ 						                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BFPC004D
Local	_aArea		:= GetArea()
Local	_cArquivo	:=	Space(100)
Local	_lOk			:=	.f.
Local	_cErro		:=	""
Local	_cMascara	:=	Alltrim(GetMv("MV_XMASC"))
Local	_aNivCta		:=	{}                                               
Local	__i			:=	0
Private lEnd		:=	.f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a quantidade de caracteres em cada nivel da conta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nCar	:=	0
For __i := 1 to Len(_cMascara)
	_nCar	+=	Val(SubStr(_cMascara,__i,1))
	Aadd(_aNivCta,_nCar)
Next __i
Define Msdialog _oDlgNFe From 000,000 TO 100,500 Title OemToAnsi("Importar dados de Planilha do excel") of oMainWnd Pixel
@ 003,005 Say OemToAnsi("Arquivo") 	Size 040,030 Pixel
@ 003,060 Get _cArquivo  Picture "@!S100" Valid (_cArquivo:=cGetFile( "Arquivo NFe (*.csv) | *.csv", "Selecione a planilha de excel desejada"),.t.)  Size 150,010 Pixel
@ 030,170 Button OemToAnsi("Ok")  Size 036,016 Action (_lOk:=.t.,_oDlgNFe:End()) Pixel
Activate Dialog _oDlgNFe Centered  	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o usuario confirmar a importacao da planilha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _lOk           	
	Processa({||FUPCRUN(@_cErro,_cArquivo,_cMascara,_aNivCta)},"Verificando estrutura e Importando...","Aguarde, por favor...",@lEnd)
	If !Empty(_cErro)
		Alert(_cErro)
	Else
		Alert("IMPORTAÇÃO REALIZADA COM SUCESSO")
	Endif
Endif  
RestArea(_aArea)
Return nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FUPCRUN   ºAutor  ³Sande               º Data ³  05/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processa a Importacao do Arquivo                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³BFPC004D                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FUPCRUN(_cErro,_cArquivo,_cMascara,_aNivCta)
If !File(_cArquivo)
	Alert("Arquivo não existe")	
	_cErro	+=	"Arquivo não existe"	
	Return nil
Endif             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciono na memoria o arquivo para leitura³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nHandle	:=	FOpen(_cArquivo)	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico o Tamanho do arquivo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nTam		:=	FSeek(_nHandle,0,2)	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciono no Inicio do arquivo pois utilizei a Funcao FSeek³
//³para saber a quantidade de linhas do arquivo               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FSeek(_nHandle,0,0)	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Incremento a regua de processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua((_nTam/271))
FT_FUse(_cArquivo)
FT_FGotop()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o arquivo aberto e um arquivo de retorno de informacoes contabeis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
_nLin		:=	0
_lCabec	:=	.f.	
While (!FT_FEof()) 				
	IncProc("Importando Estrutura do Orçamento...")
	_nLin++
	_cLinha := Upper(Alltrim(FT_FREADLN()))
	_lLinValid	:=	.t.	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao houver informacao nenhuma desconsidera o registro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(Alltrim(_cLinha))
		FT_FSkip()
		Loop	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o cabelhaco do documento esta correto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !_lCabec
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura o cabecalho do arquivo para ver as posicioes dos campos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nPosPla	:=	At("PLANILHA"	,Upper(_cLinha))
		_nPosVer	:=	At("VERSAO"		,Upper(_cLinha))
		_nPosCta	:=	At("CONTA"		,Upper(_cLinha))
		_nPosNiv	:=	At("NIVEL"		,Upper(_cLinha))
		_nPosCus	:=	At("CCUSTO"		,Upper(_cLinha))
		_nPosIte	:=	At("ITEMC"		,Upper(_cLinha))
		_nPosCla	:=	At("CLASSE"		,Upper(_cLinha))
		_nPosCom	:=	At("COMPL"		,Upper(_cLinha))
		_nPosDin	:=	At("DATAINI"	,Upper(_cLinha))
		_nPosDfi	:=	At("DATAFIM"	,Upper(_cLinha))
		_nPosVlr	:=	At("VALOR"		,Upper(_cLinha))
		_nPosNom	:=	At("NOMECONTA"	,Upper(_cLinha))		
		_nPosOpe	:=	At("OPERACAO"	,Upper(_cLinha))		
		If _nPosPla==0 .Or. ;
			_nPosVer==0 .Or. ;
			_nPosCta==0 .Or. ;
			_nPosNiv==0 .Or. ;
			_nPosCus==0 .Or. ;
			_nPosIte==0 .Or. ;
			_nPosCta==0 .Or. ;
			_nPosCom==0 .Or. ;
			_nPosDin==0 .Or. ;
			_nPosDfi==0 .Or. ;
			_nPosVlr==0 .Or. ;
			_nPosNom==0 .Or. ;
			_nPosOpe==0
			Alert("Documento Invalido")
			_cErro	+=	"Documento Invalido"
			Exit
		Else
			_lCabec	:=	.t.	
		Endif		
		FT_FSkip()
		Loop
	Endif  
	_nPosFim	:=	(At(";",_cLinha)-1)
	_cPlanil	:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_ORCAME")[1]))+Space((TamSx3("AK2_ORCAME")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_ORCAME")[1]))))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_cVersao	:=	StrZero(Val(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_VERSAO")[1]))+Space((TamSx3("AK2_VERSAO")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_VERSAO")[1]))))),4)

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_cConta	:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK5_CODIGO")[1]))+Space((TamSx3("AK5_CODIGO")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK5_CODIGO")[1]))))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_nNivel	:=	Val(Alltrim(SubStr(_cLinha,1,_nPosFim)))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_cCusto	:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_CC")[1]))+Space((TamSx3("AK2_CC")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_CC")[1]))))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_cItemc	:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_ITCTB")[1]))+Space((TamSx3("AK2_ITCTB")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_ITCTB")[1]))))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sande         22/08/2011 13:34:12hrs      ³
	//³Solicitado por Flavio Souto                ³
	//³Devido utilizar apenas 2 posicoes da classe³
	//³de valor tratar apenas 2 casas             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cClasse	:=	SPACE(02)
	
//	_cClasse	:=	StrZero(Val(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_CLVLR")[1]))+Space((TamSx3("AK2_CLVLR")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_CLVLR")[1]))))),2)

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_cCompl	:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_DESCRI")[1]))+Space((TamSx3("AK2_DESCRI")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK2_DESCRI")[1]))))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_dDataIni:=	Ctod(SubStr(_cLinha,1,_nPosFim))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_dDataFim:=	Ctod(SubStr(_cLinha,1,_nPosFim))

      _cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	
	_nValor	:=	SubStr(_cLinha,1,_nPosFim)	
	
	While At(".",_nValor)>0
		_nValor	:=	StrTran(_nValor,".","")	
	EndDo		
	_nValor	:=	Val(StrTran(_nValor,",","."))

	_cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	(At(";",_cLinha)-1)			
	_cNomeCta:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK3_DESCRI")[1]))+Space((TamSx3("AK3_DESCRI")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AK3_DESCRI")[1]))))		

	_cLinha	:=	SubStr(_cLinha,_nPosFim+2,(Len(_cLinha)-_nPosFim))

	_nPosFim	:=	Len(Alltrim(_cLinha))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sande          22/08/2011 13:35:01hrs      ³
	//³Solicitado por Flavio Souto                ³
	//³Tratar a operacao sem alimentar zeros a es-³
	//³querda	`							             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	_cOperac:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AKF_CODIGO")[1]))+Space((TamSx3("AKF_CODIGO")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AKF_CODIGO")[1]))))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se a planilha a ser importada é igual a planilha posicionada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(Alltrim(_cPlanil)==Alltrim(AK1->AK1_CODIGO) .And. Alltrim(_cVersao)==Alltrim(AK1->AK1_VERSAO))
		Alert("Arquivo não pertence a esta planilha")
		_cErro	+=	"Arquivo não pertence a esta planilha"
		Exit		
   	Endif  			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sande          15/07/11 09:43:00hrs        ³
	//³Verificacao de Nescessidade                ³
	//³Nao verificar a conta principal como conta ³
	//³orcamentaria                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a conta contabil existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Alltrim(_cConta)<>Alltrim(_cPlanil)
		DbSelectArea("AK5")      
	      ak5->(DbSetOrder(1))
	      If !ak5->(DbSeek(xFilial("AK5")+_cConta))
			_cErro	+=	"Conta Orcamentaria "+_cConta+" na linha "+Alltrim(Str(_nLin))+" não esta cadastrada"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Centro de Custo existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
		DbSelectArea("CTT")      
      ctt->(DbSetOrder(1))
      If !ctt->(DbSeek(xFilial("CTT")+_cCusto))
			_cErro	+=	"Centro de Custo(Cultura) "+_cCusto+" na linha "+Alltrim(Str(_nLin))+" não esta cadastrado"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	        \
		Endif
	Endif

  
/*	DESABILITADO POR Sande Ribeiro  15/05/2012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Centro de Custo existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(_cItemc) .And. Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
		DbSelectArea("CTD")      
      ctd->(DbSetOrder(1))
      If !ctd->(DbSeek(xFilial("CTD")+_cItemc))
			_cErro	+=	"Item Contabil(Fornecedor) "+_cItemc+" na linha "+Alltrim(Str(_nLin))+" não esta cadastrado"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	
		Endif
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Centro de Custo existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Val(_cClasse)>0
		DbSelectArea("CTH")      
      	cth->(DbSetOrder(1))
      	If !cth->(DbSeek(xFilial("CTH")+_cClasse))
			_cErro	+=	"Classe de Valor(Aglomerado) "+_cClasse+" na linha "+Alltrim(Str(_nLin))+" não esta cadastrada"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	
		Endif 
	Else
		_cClasse	:=	Space(TamSx3("AK2_CLVLR")[1])
	Endif	                            
	
*/	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o nivel da conta esta correto³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. !(_nNivel>0)
		_cErro	+=	"Nivel da Conta na estrutura do orçamento "+Alltrim(Str(_nNivel))+" na linha "+Alltrim(Str(_nLin))+" é inválido"+Chr(13)+Chr(10)		
		_lLinValid	:=	.f.	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o periodo inicial do orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If  Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Empty(_dDataIni)
		_cErro	+=	"Periodo Inicial na estrutura do orçamento na linha "+Alltrim(Str(_nLin))+" é inválido"+Chr(13)+Chr(10)		
		_lLinValid	:=	.f.	
	Endif           

/*	DESABILITADO POR Sande Ribeiro  15/05/2012

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sande Ribeiro   18/07/2011 09:09:00hrs ³
	//³Solicitado por Cida Freitas			  ³
	//³Validar a Operacao						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	DbSelectArea("AKF")      
   akf->(DbSetOrder(1))
   If !akf->(DbSeek(xFilial("AKF")+_cOperac)) .And. Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Val(_cOperac)>0
		_cErro	+=	"Operação(Ano Safra) "+_cOperac+" na linha "+Alltrim(Str(_nLin))+" não esta cadastrada"+Chr(13)+Chr(10)
		_cOperac	:=	Space(TamSx3("AKF_CODIGO")[1])	
		_lLinValid	:=	.f.		
	Endif	
	
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica o periodo inicial do orcamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Empty(_dDataFim)
		_cErro	+=	"Periodo Final na estrutura do orçamento na linha "+Alltrim(Str(_nLin))+" é inválido"+Chr(13)+Chr(10)		
		_lLinValid	:=	.f.	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se alinha for valida faco a gravacao da estrutura do orcamento³
	//³e dos itens do orcamento                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If _lLinValid
      	DbSelectArea("AK3")
      	ak3->(DbSetOrder(1))
      	_lExist	:= !(ak3->(DbSeek(xFilial("AK3")+_cPlanil+_cVersao+_cConta)))			
      	If RecLock("AK3",_lExist)
      	 	Replace	ak3->ak3_filial	With	xFilial("AK3")	     
      	 	Replace	ak3->ak3_orcame	With	_cPlanil	     
      	 	Replace	ak3->ak3_versao	With	_cVersao	     
      	 	Replace	ak3->ak3_co			With	_cConta
      	 	Replace	ak3->ak3_pai		With	If(((Ascan(_aNivCta,Len(Alltrim(_cConta))))-1)>0,SubStr(_cConta,1,_aNivCta[((Ascan(_aNivCta,Len(Alltrim(_cConta))))-1)]),_cPlanil)	
      	 	Replace	ak3->ak3_tipo		With	If(Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)],"2","1")	
      	 	Replace	ak3->ak3_nivel		With	StrZero(_nNivel,3)
      	 	Replace	ak3->ak3_descri	With	_cNomeCta
         	MsUnLock("AK3")
         Endif      				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se a conta é analitica³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
			_cId	:=	"0000"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procuro o proximo ID dos itens do orcamento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	DbSelectArea("AK2")
      	ak2->(DbSetOrder(1))  
      	If ak2->(DbSeek(xFilial("AK2")+_cPlanil+_cVersao+_cConta))
      		While ak2->(!Eof()) .And. ak2->ak2_filial==xFilial("AK2") .And.;	
      											ak2->ak2_orcame==_cPlanil			.And.;
      											ak2->ak2_versao==_cVersao			.And.;
      											ak2->ak2_co==_cConta
      			If _cId<ak2->ak2_id .And. ((ak2->ak2_cc<>_cCusto).Or.(ak2->ak2_itctb<>_cItemc).Or.(ak2->ak2_clvlr<>_cClasse))
      				_cId	:=	ak2->ak2_id	    
      		   Endif
      			ak2->(Dbskip())
      		EndDo
      	Endif
      	_cId	:=	Soma1(_cId)      	      	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Sande Ribeiro   13/05/2011 10:26:00hrs                      ³
			//³Solicitado por Evanilze                                     ³
			//³Erro encontrado ao tratar a estrutura individual por cultura³
			//³este indice impede que a estrutura importada fique errada   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	DbSelectArea("AK2")
			ak2->(DbSetOrder(1))
      	_lExist	:= !(ak2->(DbSeek(xFilial("AK2")+_cPlanil+_cVersao+_cConta+Dtos(_dDataIni)+_cId)))
      	If RecLock("AK2",_lExist)
      	 	Replace	ak2->ak2_filial	    With	xFilial("AK2")
      	 	Replace ak2->ak2_id		With	_cId
      	 	Replace	ak2->ak2_orcame	    With	_cPlanil	     
      	 	Replace	ak2->ak2_versao	    With	_cVersao	     
      	 	Replace	ak2->ak2_co			With	_cConta
      	 	Replace	ak2->ak2_period	    With	_dDataIni
      	 	Replace	ak2->ak2_cc			With	_cCusto
      	 	Replace	ak2->ak2_itctb		With	_cItemc
      	 	Replace	ak2->ak2_clvlr		With	_cClasse
      	 	Replace	ak2->ak2_classe	    With	StrZero(1,6)
      	 	Replace	ak2->ak2_valor		With	_nValor
      	 	Replace	ak2->ak2_descri	    With	_cCompl
      	 	Replace	ak2->ak2_chave		With	Alltrim(Str(Val(sm0->m0_codigo)))
      	 	Replace	ak2->ak2_moeda		With	1 
      	 	Replace ak2->ak2_dataf		With	_dDataFim
      	 	Replace ak2->ak2_datai		With	_dDataIni
      	 	Replace ak2->ak2_oper		With	 StrZero(1,10) //_cOperac
         	MsUnLock("AK3")
         Endif
      	Endif
      Endif
	FT_FSkip()
EndDo
FT_FUse()
FClose(_nHandle)		