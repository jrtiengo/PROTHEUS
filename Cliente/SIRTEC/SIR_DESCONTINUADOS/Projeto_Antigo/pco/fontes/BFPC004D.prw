#INCLUDE "protheus.ch"                                 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �BFPC004D  � Autor � Sande Ribeiro      � Data �  10/10/10   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Importa dados do Excel									  ���
�������������������������������������������������������������������������Ĵ��
���Programa  �GENERICO                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �      �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Sande       �15/07/11�      � Nao validar a conta principal como conta ���
���Ribeiro     �        �      � orcamentaria			                  ���
�������������������������������������������������������������������������Ĵ��
���Sande       �18/08/11�      � Fazer o tratamento do campo operacao das ���
���Ribeiro     �        �      � planilhas orcamentarias	              ���
�������������������������������������������������������������������������Ĵ��
���Sande       �22/08/11�      � Alteracao da utilizacao da funcao strzero���
���Ribeiro     �        �      � 						                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
//������������������������������������������������������������
//�Verifica a quantidade de caracteres em cada nivel da conta�
//������������������������������������������������������������
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
//�����������������������������������������������Ŀ
//�Se o usuario confirmar a importacao da planilha�
//�������������������������������������������������
If _lOk           	
	Processa({||FUPCRUN(@_cErro,_cArquivo,_cMascara,_aNivCta)},"Verificando estrutura e Importando...","Aguarde, por favor...",@lEnd)
	If !Empty(_cErro)
		Alert(_cErro)
	Else
		Alert("IMPORTA��O REALIZADA COM SUCESSO")
	Endif
Endif  
RestArea(_aArea)
Return nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FUPCRUN   �Autor  �Sande               � Data �  05/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processa a Importacao do Arquivo                            ���
�������������������������������������������������������������������������͹��
���Uso       �BFPC004D                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FUPCRUN(_cErro,_cArquivo,_cMascara,_aNivCta)
If !File(_cArquivo)
	Alert("Arquivo n�o existe")	
	_cErro	+=	"Arquivo n�o existe"	
	Return nil
Endif             
//���������������������������������������������
//�Posiciono na memoria o arquivo para leitura�
//���������������������������������������������
_nHandle	:=	FOpen(_cArquivo)	
//�����������������������������Ŀ
//�Verifico o Tamanho do arquivo�
//�������������������������������
_nTam		:=	FSeek(_nHandle,0,2)	
//�����������������������������������������������������������Ŀ
//�Posiciono no Inicio do arquivo pois utilizei a Funcao FSeek�
//�para saber a quantidade de linhas do arquivo               �
//�������������������������������������������������������������
FSeek(_nHandle,0,0)	
//�����������������������������������Ŀ
//�Incremento a regua de processamento�
//�������������������������������������
ProcRegua((_nTam/271))
FT_FUse(_cArquivo)
FT_FGotop()
//�����������������������������������������������������������������������������Ŀ
//�Verifica se o arquivo aberto e um arquivo de retorno de informacoes contabeis�
//�������������������������������������������������������������������������������	
_nLin		:=	0
_lCabec	:=	.f.	
While (!FT_FEof()) 				
	IncProc("Importando Estrutura do Or�amento...")
	_nLin++
	_cLinha := Upper(Alltrim(FT_FREADLN()))
	_lLinValid	:=	.t.	
	//��������������������������������������������������������Ŀ
	//�Se nao houver informacao nenhuma desconsidera o registro�
	//����������������������������������������������������������
	If Empty(Alltrim(_cLinha))
		FT_FSkip()
		Loop	
	Endif
	//�������������������������������������������������Ŀ
	//�Verifica se o cabelhaco do documento esta correto�
	//���������������������������������������������������
	If !_lCabec
		//���������������������������������������������������������������Ŀ
		//�Procura o cabecalho do arquivo para ver as posicioes dos campos�
		//�����������������������������������������������������������������
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
	//�������������������������������������������Ŀ
	//�Sande         22/08/2011 13:34:12hrs      �
	//�Solicitado por Flavio Souto                �
	//�Devido utilizar apenas 2 posicoes da classe�
	//�de valor tratar apenas 2 casas             �
	//���������������������������������������������
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
	//�������������������������������������������Ŀ
	//�Sande          22/08/2011 13:35:01hrs      �
	//�Solicitado por Flavio Souto                �
	//�Tratar a operacao sem alimentar zeros a es-�
	//�querda	`							             �
	//���������������������������������������������	
	_cOperac:=	Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AKF_CODIGO")[1]))+Space((TamSx3("AKF_CODIGO")[1])-Len(Alltrim(SubStr(SubStr(_cLinha,1,_nPosFim),1,TamSx3("AKF_CODIGO")[1]))))
	//�����������������������������������������������������������������������
	//�Verifico se a planilha a ser importada � igual a planilha posicionada�
	//�����������������������������������������������������������������������
	If !(Alltrim(_cPlanil)==Alltrim(AK1->AK1_CODIGO) .And. Alltrim(_cVersao)==Alltrim(AK1->AK1_VERSAO))
		Alert("Arquivo n�o pertence a esta planilha")
		_cErro	+=	"Arquivo n�o pertence a esta planilha"
		Exit		
   	Endif  			
	//�������������������������������������������Ŀ
	//�Sande          15/07/11 09:43:00hrs        �
	//�Verificacao de Nescessidade                �
	//�Nao verificar a conta principal como conta �
	//�orcamentaria                               �
	//���������������������������������������������
	//�����������������������������������Ŀ
	//�Verifica se a conta contabil existe�
	//�������������������������������������
	If Alltrim(_cConta)<>Alltrim(_cPlanil)
		DbSelectArea("AK5")      
	      ak5->(DbSetOrder(1))
	      If !ak5->(DbSeek(xFilial("AK5")+_cConta))
			_cErro	+=	"Conta Orcamentaria "+_cConta+" na linha "+Alltrim(Str(_nLin))+" n�o esta cadastrada"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	
		Endif
	Endif
	//������������������������������������Ŀ
	//�Verifica se o Centro de Custo existe�
	//��������������������������������������
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
		DbSelectArea("CTT")      
      ctt->(DbSetOrder(1))
      If !ctt->(DbSeek(xFilial("CTT")+_cCusto))
			_cErro	+=	"Centro de Custo(Cultura) "+_cCusto+" na linha "+Alltrim(Str(_nLin))+" n�o esta cadastrado"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	        \
		Endif
	Endif

  
/*	DESABILITADO POR Sande Ribeiro  15/05/2012

	//������������������������������������Ŀ
	//�Verifica se o Centro de Custo existe�
	//��������������������������������������
	If !Empty(_cItemc) .And. Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
		DbSelectArea("CTD")      
      ctd->(DbSetOrder(1))
      If !ctd->(DbSeek(xFilial("CTD")+_cItemc))
			_cErro	+=	"Item Contabil(Fornecedor) "+_cItemc+" na linha "+Alltrim(Str(_nLin))+" n�o esta cadastrado"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	
		Endif
	Endif	
	//������������������������������������Ŀ
	//�Verifica se o Centro de Custo existe�
	//��������������������������������������
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Val(_cClasse)>0
		DbSelectArea("CTH")      
      	cth->(DbSetOrder(1))
      	If !cth->(DbSeek(xFilial("CTH")+_cClasse))
			_cErro	+=	"Classe de Valor(Aglomerado) "+_cClasse+" na linha "+Alltrim(Str(_nLin))+" n�o esta cadastrada"+Chr(13)+Chr(10)
			_lLinValid	:=	.f.	
		Endif 
	Else
		_cClasse	:=	Space(TamSx3("AK2_CLVLR")[1])
	Endif	                            
	
*/	
	//�����������������������������������������Ŀ
	//�Verifica se o nivel da conta esta correto�
	//�������������������������������������������		
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. !(_nNivel>0)
		_cErro	+=	"Nivel da Conta na estrutura do or�amento "+Alltrim(Str(_nNivel))+" na linha "+Alltrim(Str(_nLin))+" � inv�lido"+Chr(13)+Chr(10)		
		_lLinValid	:=	.f.	
	Endif
	//����������������������������������������Ŀ
	//�Verifica o periodo inicial do orcamento �
	//������������������������������������������		
	If  Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Empty(_dDataIni)
		_cErro	+=	"Periodo Inicial na estrutura do or�amento na linha "+Alltrim(Str(_nLin))+" � inv�lido"+Chr(13)+Chr(10)		
		_lLinValid	:=	.f.	
	Endif           

/*	DESABILITADO POR Sande Ribeiro  15/05/2012

	//��������������������������������������Ŀ
	//�Sande Ribeiro   18/07/2011 09:09:00hrs �
	//�Solicitado por Cida Freitas			  �
	//�Validar a Operacao						  �
	//����������������������������������������		
	DbSelectArea("AKF")      
   akf->(DbSetOrder(1))
   If !akf->(DbSeek(xFilial("AKF")+_cOperac)) .And. Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Val(_cOperac)>0
		_cErro	+=	"Opera��o(Ano Safra) "+_cOperac+" na linha "+Alltrim(Str(_nLin))+" n�o esta cadastrada"+Chr(13)+Chr(10)
		_cOperac	:=	Space(TamSx3("AKF_CODIGO")[1])	
		_lLinValid	:=	.f.		
	Endif	
	
	*/
	
	//����������������������������������������Ŀ
	//�Verifica o periodo inicial do orcamento �
	//������������������������������������������		
	If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)] .And. Empty(_dDataFim)
		_cErro	+=	"Periodo Final na estrutura do or�amento na linha "+Alltrim(Str(_nLin))+" � inv�lido"+Chr(13)+Chr(10)		
		_lLinValid	:=	.f.	
	Endif
	//��������������������������������������������������������������Ŀ
	//�Se alinha for valida faco a gravacao da estrutura do orcamento�
	//�e dos itens do orcamento                                      �
	//����������������������������������������������������������������
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
		//���������������������������������
		//�Verifica se a conta � analitica�
		//���������������������������������
		If Len(Alltrim(_cConta))==_aNivCta[Len(_aNivCta)]
			_cId	:=	"0000"
			//���������������������������������������������
			//�Procuro o proximo ID dos itens do orcamento�
			//���������������������������������������������
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
			//������������������������������������������������������������Ŀ
			//�Sande Ribeiro   13/05/2011 10:26:00hrs                      �
			//�Solicitado por Evanilze                                     �
			//�Erro encontrado ao tratar a estrutura individual por cultura�
			//�este indice impede que a estrutura importada fique errada   �
			//��������������������������������������������������������������
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