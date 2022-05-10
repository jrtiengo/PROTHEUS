#INCLUDE "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SCIA010   ³ Autor ³ Manoel Mariante       ³ Data ³Ago/2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Respostas da Avaliação                                     ³±±
±±³			 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sport Club Internacional						              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function SCIA010
	Local aRet := {}
	Local aParamBox := {}
	Local aCombo := {}
	Local i := 0            
	Local aMvPar:={}
	lOCAL aGravar:={}
	Local aNaoGrav:={}
	Private cCadastro := "Respostas"
	
	//salva a posicao das perguntas antes de processar
	For nMv := 1 To 60
	   aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
	Next nMv
	//--------------------------

	cQuery := " SELECT SZ2.*,ISNULL(Z3_RESPLST,'1') Z3_RESPLST,RTRIM(LTRIM(CAST(CAST(Z3_RESPOST AS VARBINARY(8000)) AS VARCHAR(8000)))) Z3_RESPOST,ISNULL(Z3_VALOR,0) Z3_VALOR"
	cQuery += " FROM   "+RetSqlName("SZ2")+" SZ2"
	cQuery += " LEFT JOIN "+RetSqlName("SZ3")+" SZ3 ON"
	cQuery += " Z3_FILIAL='"+SF1->F1_FILIAL+"'"
	cQuery += " AND Z3_DOC='"+SF1->F1_DOC+"'"
	cQuery += " AND Z3_SERIE='"+SF1->F1_SERIE+"'"
	cQuery += " AND Z3_FORNECE='"+SF1->F1_FORNECE+"'"
	cQuery += " AND Z3_LOJA='"+SF1->F1_LOJA+"'"
	cQuery += " AND Z3_SEQUEN=Z2_SEQUEN"
	cQuery += " AND SZ3.D_E_L_E_T_=''"
	cQuery += " WHERE  Z2_ATIVO='1' "
	cQuery += " AND SZ2.D_E_L_E_T_ ='' "
	cQuery += " ORDER BY Z2_AREA"                 

	//MemoWrite("SCIA010.SQL",cQuery)
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
	
	DbSelectArea("TMP")
	cArea:=""
	
	While !Eof()                 
		IF !EMPTY(TMP->Z2_ESPECIE).AND.!Alltrim(SF1->F1_ESPECIE) $ TMP->Z2_ESPECIE
			dbSkip()
		End
		
		IF cArea<>TMP->Z2_AREA
			cArea:=TMP->Z2_AREA
			aAdd(aParamBox,{9," * * * "+alltrim(TMP->Z2_AREA)+" * * * ",150,9,.t.})
			Aadd(aGravar,{"XXX","XXX"})
			
		END
		
		Aadd(aGravar,{TMP->Z2_SEQUEN,TMP->Z2_TIPO})
		
		IF TMP->Z2_TIPO=="2" //NOTA
			aAdd(aParamBox,{1,TMP->Z2_PERGUNT,TMP->Z3_VALOR,"@E "+TMP->Z2_MASCNOT,"","","",20,.F.}) // Tipo numérico
	
		ELSEIF TMP->Z2_TIPO=="1" //DISSERTATIVO
	
			aAdd(aParamBox,{11,TMP->Z2_PERGUNT,ALLTRIM(TMP->Z3_RESPOST),".T.",".T.",.F.})
			
		ELSEIF TMP->Z2_TIPO=="3"               
		
			cAux:=ALLTRIM(TMP->Z2_LISTA)
			aCombo:={}
			While Len(cAux)>0
				nPos:=AT("=",cAux)
				cOpc:=Substr(cAux,1,nPos)
				cAux:=Substr(cAux,nPos+1,999)
				
				nPos:=AT(";",cAux)
				If nPos==0           
					cTex:=cAux
					cAux:=""
				Else
					cTex:=Substr(cAux,1,nPos-1)    
					cAux:=Substr(cAux,nPos+1,999)
				End
				Aadd(aCombo,cOpc+cTex)
			End                    
			aAdd(aParamBox,{2,TMP->Z2_PERGUNT,TMP->Z3_RESPLST,aCombo,50,"",.F.})
		END
	
		dbSelectArea("TMP")
		dbSkip()	
	END
	TMP->(DbCloseArea())
	
	//executa a tela de parametros
	If !ParamBox(aParamBox,"Avaliação de Fornecedores",@aRet)
		Return .t.
	End
	
	IF !MSGBOX("Confirma a Gravação da Avaliação?","Atenção","YESNO")
		Return .t.
	End

	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
	While SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SZ3->(Z3_FILIAL+Z3_DOC+Z3_SERIE+Z3_FORNECE+Z3_LOJA).AND.!EOF()
		Reclock("SZ3",.f.)
		dbDelete()        
		MsUnlock()
		dbSkip()
	End                      
	
	For nK:=1 To Len(aGravar)                                  
		IF aGravar[nK,1]="XXX"
			loop
		End               
		Reclock("SZ3",.t.)
		SZ3->Z3_FILIAL  :=xFilial("SZ3")
		SZ3->Z3_SEQUEN  :=aGravar[nK,1]
		SZ3->Z3_DOC     :=SF1->F1_DOC
		SZ3->Z3_SERIE   :=SF1->F1_SERIE
		SZ3->Z3_FORNECE :=SF1->F1_FORNECE
		SZ3->Z3_LOJA    :=SF1->F1_LOJA
		SZ3->Z3_TIPO    :=aGravar[nK,2]
		IF aGravar[nK,2]=="1"
			SZ3->Z3_RESPOST:=ALLTRIM(aRet[nK])
		ELSEIF aGravar[nK,2]=="2"
			SZ3->Z3_VALOR:=aRet[nK]
		ELSEIF aGravar[nK,2]=="3"
			SZ3->Z3_RESPLST:=aRet[nK]
		END
		msUnlock()
	Next		
	/*If ParamBox(aParamBox,"Teste Parâmetros...",@aRet)
	   For i:=1 To Len(aRet)
	      MsgInfo(aRet[i],"Opção escolhida")
	   Next 
	Endif*/

	//restaura situcao anterior dos parametros
	For nMv := 1 To Len( aMvPar )
	   &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv
	
Return

	//aAdd(aParamBox,{1,"Produto",Space(15),"","","SB1","",0,.F.}) // Tipo caractere

	//aAdd(aParamBox,{1,"Data"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	// Tipo 1 -> MsGet()
	//           [2]-Descricao
	//           [3]-String contendo o inicializador do campo
	//           [4]-String contendo a Picture do campo
	//           [5]-String contendo a validacao
	//           [6]-Consulta F3
	//           [7]-String contendo a validacao When
	//           [8]-Tamanho do MsGet
	//           [9]-Flag .T./.F. Parametro Obrigatorio ?
	
	
	// Tipo 2 -> Combo
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do combo
	//           [4]-Array contendo as opcoes do Combo
	//           [5]-Tamanho do Combo
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?
	// Cuidado, há um problema nesta opção quando selecionado a 1ª opção.

	//aAdd(aParamBox,{3,"Mostra deletados",1,{"Sim","Não"},50,"",.F.})
	// Tipo 3 -> Radio
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do Radio
	//           [4]-Array contendo as opcoes do Radio
	//           [5]-Tamanho do Radio
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?
	
	//aAdd(aParamBox,{4,"Marca todos ?",.F.,"Marque todos se necessário for.",90,"",.F.})
	// Tipo 4 -> Say + CheckBox
	//           [2]-Descricao
	//           [3]-Indicador Logico contendo o inicial do Check
	//           [4]-Texto do CheckBox
	//           [5]-Tamanho do Radio
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?
	
	//aAdd(aParamBox,{5,"Marca todos ?",.F.,50,"",.F.})
	// Tipo 5 -> Somente CheckBox
	//           [2]-Descricao
	//           [3]-Indicador Logico contendo o inicial do Check
	//           [4]-Tamanho do Radio
	//           [5]-Validacao
	//           [6]-Flag .T./.F. Parametro Obrigatorio ?
	
	//aAdd(aParamBox,{6,"Buscar arquivo",Space(50),"","","",50,.F.,"Todos os arquivos (*.*) |*.*"})
	// Tipo 6 -> File
	//           [2]-Descricao
	//           [3]-String contendo o inicializador do campo
	//           [4]-String contendo a Picture do campo
	//           [5]-String contendo a validacao
	//           [6]-String contendo a validacao When
	//           [7]-Tamanho do MsGet
	//           [8]-Flag .T./.F. Parametro Obrigatorio ?
	//           [9]-Texto contendo os tipos de arquivo, exemplo: "Arquivos .CSV |*.CSV"
	//           [10]-Diretorio inicial do cGetFile
	//           [11]-Número relativo a visualização, podendo ser por diretório ou por arquivo (0,1,2,4,8,16,32,64,128)
	
	//aAdd(aParamBox,{7,"Monte o filtro","SX5","X5_FILIAL==xFilial('SX5')"})
	// Tipo 7 -> Montagem de expressao de filtro
	//           [2]-Descricao
	//           [3]-Alias da tabela
	//           [4]-Filtro inicial
	
	//aAdd(aParamBox,{8,"Digite a senha",Space(15),"","","","",80,.F.})
	// Tipo 8 -> MsGet Password
	//           [2]-Descricao
	//           [3]-String contendo o inicializador do campo
	//           [4]-String contendo a Picture do campo
	//           [5]-String contendo a validacao
	//           [6]-Consulta F3
	//           [7]-String contendo a validacao When
	//           [8]-Tamanho do MsGet
	//           [9]-Flag .T./.F. Parametro Obrigatorio ?
	
	//aAdd(aParamBox,{9,"Texto aleatório, apenas demonstrativo.",150,7,.T.})
	// Tipo 9 -> Somente uma mensagem, formato de um título
	//           [2]-Texto descritivo
	//           [3]-Largura do texto
	//           [4]-Altura do texto
	//           [5]-Valor lógico sendo: .T. => fonte tipo VERDANA e .F. => fonte tipo ARIAL
	
	//aAdd(aParamBox,{10,"Cliente",Space(6),"SA1",40,"C",6,".T."})
	// Tipo 10 -> Range de busca
	//            [2] = Título
	//            [3] = Inicializador padrão
	//            [4] = Consulta F3
	//            [5] = Tamanho do GET
	//            [6] = Tipo do dado, somente (C=caractere e D=data)
	//            [7] = Tamanho do espaço
	//            [8] = Condição When
	
	// Tipo 11 -> MultiGet (Memo)
	//            [2] = Descrição
	//            [3] = Inicializador padrão
	//            [4] = Validação
	//            [5] = When
	//            [6] = Campo com preenchimento obrigatório .T.=Sim .F.=Não (incluir a validação na função ParamOk)

	
	// Parametros da função Parambox()
	// -------------------------------
	// 1 - < aParametros > - Vetor com as configurações
	// 2 - < cTitle >      - Título da janela
	// 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
	// 4 - < bOk >         - Code block para validar o botão Ok
	// 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
	// 6 - < lCentered >   - Centralizar a janela
	// 7 - < nPosX >       - Se não centralizar janela coordenada X para início
	// 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
	// 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
	//10 - < cLoad >       - Nome do perfil se caso for carregar
	//11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
	//12 - < lUserSave >   - Configuração por usuário
	
	// Caso alguns parâmetros para a função não seja passada será considerado DEFAULT as seguintes abaixo:
	// DEFAULT bOk   := {|| (.T.)}
	// DEFAULT aButtons := {}
	// DEFAULT lCentered := .T.
	// DEFAULT nPosX  := 0
	// DEFAULT nPosY  := 0
	// DEFAULT cLoad     := ProcName(1)
	// DEFAULT lCanSave := .T.
	// DEFAULT lUserSave := .F.
	/*****
*
* Se caso for utilizar a ParamBox() em um ponto de entrada, e 
* esta rotina utilizar a Pergunte(), cuidado, ambas funções atribuem valores
* as variáveis Public MV_PAR??, e isso pode conflitar os valores, 
* por este motivo deve-se savar o conteúdo destas variáveis da seguinte maneira:
* 
* For nMv := 1 To 40
*    aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
* Next nMv
*
* E depois poderá restaura-la da seguinte maneira:
*
* For nMv := 1 To Len( aMvPar )
*    &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
* Next nMv
*
* O limitador do For/Next é até 40 ou 60 porquê o Protheus têm no máximo
* 40 ou 60 perguntas dependendo da versão.
*
*/

Return .t.

