#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO4     � Autor � AP6 IDE            � Data �  19/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CALAPCP()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cCadastro := "Producao Gr�fica"
//���������������������������������������������������������������������Ŀ
//� Array (tambem deve ser aRotina sempre) com as definicoes das opcoes �
//� que apareceram disponiveis para o usuario. Segue o padrao:          �
//� aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      �
//�              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      �
//�              . . .                                                  �
//�              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      �
//� Onde: <DESCRICAO> - Descricao da opcao do menu                      �
//�       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  �
//�                     duplas e pode ser uma das funcoes pre-definidas �
//�                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA �
//�                     e AXDELETA) ou a chamada de um EXECBLOCK.       �
//�                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-�
//�                     clarar uma variavel chamada CDELFUNC contendo   �
//�                     uma expressao logica que define se o usuario po-�
//�                     dera ou nao excluir o registro, por exemplo:    �
//�                     cDelFunc := 'ExecBlock("TESTE")'  ou            �
//�                     cDelFunc := ".T."                               �
//�                     Note que ao se utilizar chamada de EXECBLOCKs,  �
//�                     as aspas simples devem estar SEMPRE por fora da �
//�                     sintaxe.                                        �
//�       <TIPO>      - Identifica o tipo de rotina que sera executada. �
//�                     Por exemplo, 1 identifica que sera uma rotina de�
//�                     pesquisa, portando alteracoes nao podem ser efe-�
//�                     tuadas. 3 indica que a rotina e de inclusao, por�
//�                     tanto, a rotina sera chamada continuamente ao   �
//�                     final do processamento, ate o pressionamento de �
//�                     <ESC>. Geralmente ao se usar uma chamada de     �
//�                     EXECBLOCK, usa-se o tipo 4, de alteracao.       �
//�����������������������������������������������������������������������

//���������������������������������������������������������������������Ŀ
//� aRotina padrao. Utilizando a declaracao a seguir, a execucao da     �
//� MBROWSE sera identica a da AXCADASTRO:                              �
//�                                                                     �
//� cDelFunc  := ".T."                                                  �
//� aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               �
//�                { "Visualizar"   ,"AxVisual" , 0, 2},;               �
//�                { "Incluir"      ,"AxInclui" , 0, 3},;               �
//�                { "Alterar"      ,"AxAltera" , 0, 4},;               �
//�                { "Excluir"      ,"AxDeleta" , 0, 5} }               �
//�                                                                     �
//�����������������������������������������������������������������������


//���������������������������������������������������������������������Ŀ
//� Monta um aRotina proprio                                            �
//�����������������������������������������������������������������������

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","u_SHWOS()",0,2} ,;
             {"Incluir","u_insOS()",0,3} ,;
             {"Alterar","u_UPDOS()",0,4} ,;
             {"Excluir","u_DELOS()",0,5} }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SZD"

dbSelectArea("SZD")
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Executa a funcao MBROWSE. Sintaxe:                                  �
//�                                                                     �
//� mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              �
//� Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   �
//�                        exibido. Para seguir o padrao da AXCADASTRO  �
//�                        use sempre 6,1,22,75 (o que nao impede de    �
//�                        criar o browse no lugar desejado da tela).   �
//�                        Obs.: Na versao Windows, o browse sera exibi-�
//�                        do sempre na janela ativa. Caso nenhuma este-�
//�                        ja ativa no momento, o browse sera exibido na�
//�                        janela do proprio SIGAADV.                   �
//� Alias                - Alias do arquivo a ser "Browseado".          �
//� aCampos              - Array multidimensional com os campos a serem �
//�                        exibidos no browse. Se nao informado, os cam-�
//�                        pos serao obtidos do dicionario de dados.    �
//�                        E util para o uso com arquivos de trabalho.  �
//�                        Segue o padrao:                              �
//�                        aCampos := { {<CAMPO>,<DESCRICAO>},;         �
//�                                     {<CAMPO>,<DESCRICAO>},;         �
//�                                     . . .                           �
//�                                     {<CAMPO>,<DESCRICAO>} }         �
//�                        Como por exemplo:                            �
//�                        aCampos := { {"TRB_DATA","Data  "},;         �
//�                                     {"TRB_COD" ,"Codigo"} }         �
//� cCampo               - Nome de um campo (entre aspas) que sera usado�
//�                        como "flag". Se o campo estiver vazio, o re- �
//�                        gistro ficara de uma cor no browse, senao fi-�
//�                        cara de outra cor.                           �
//�����������������������������������������������������������������������

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return


User Function ShwOs()
    ShowOS(2)
Return

User Function InsOs()
    ShowOS(3)
Return

User Function UpdOs()
    ShowOS(4)
Return

User Function DelOs()
    ShowOS(5)
Return

Static Function ShowOS(nOpcX)

//��������������������������������������������������������������Ŀ
//� Opcoes de acesso para a Modelo 3                             �
//����������������������������������������������������������������
IF nOpcX == 2
	cOpcao:="VISUALIZAR"
ELSEIF nOpcx == 3	
	cOpcao:="INCLUIR"
ELSEIF nOpcX == 4	
	cOpcao:="ALTERAR"
ELSEIF nOpcX == 5	
	cOpcao:="EXCLUIR"
ENDIF	
Do Case
	Case cOpcao=="INCLUIR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="ALTERAR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="EXCLUIR"; nOpcE:=3 ; nOpcG:=3
	Case cOpcao=="VISUALIZAR"; nOpcE:=2 ; nOpcG:=2
EndCase         

//��������������������������������������������������������������Ŀ
//� Cria variaveis M->????? da Enchoice                          �
//����������������������������������������������������������������
RegToMemory("SZD",(cOpcao=="INCLUIR"))
//��������������������������������������������������������������Ŀ
//� Cria aHeader e aCols da GetDados                             �
//����������������������������������������������������������������
nUsado:=0

dbSelectArea("SX3")
dbSeek("SZD")
aZDHead:={}
While !Eof().And.(x3_arquivo=="SZD")

	If X3USO(x3_usado).And.cNivel>=x3_nivel
        Aadd(aZDHead,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	         x3_tamanho, x3_decimal,"AllwaysTrue()",;
    	     x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
    dbSkip()
End


dbSelectArea("SX3")
dbSeek("SZE")
aHeader:={}
While !Eof().And.(x3_arquivo=="SZE")
	If Alltrim(x3_campo)=="ZE_OS"
		dbSkip()
		Loop
	Endif
	If X3USO(x3_usado).And.cNivel>=x3_nivel
    	nUsado:=nUsado+1
        Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
	         x3_tamanho, x3_decimal,"AllwaysTrue()",;
    	     x3_usado, x3_tipo, x3_arquivo, x3_context } )
	Endif
    dbSkip()
End

If cOpcao=="INCLUIR"
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F.
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	dbSelectArea("SZE")
	dbSetOrder(1)
	dbSeek(xFilial()+SZD->ZD_NUM)
	While !eof().and.ZE_NUM == M->ZD_NUM
		AADD(aCols,Array(nUsado+1))
		For _ni:=1 to nUsado
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next 
		aCols[Len(aCols),nUsado+1]:=.F.
		dbSkip()
	End
Endif
If Len(aCols)>0
	//��������������������������������������������������������������Ŀ
	//� Executa a Modelo 3                                           �
	//����������������������������������������������������������������
	cTitulo:="Apontamento de Produ��o"
	cAliasEnchoice:="SZD"
	cAliasGetD:="SZE"
	cLinOk:="U_LinOk()"
	cTudOk:="U_TudOk()"
	cFieldOk:="U_CriaItem()"
	//aCpoEnchoice:={"C5_CLIENTE"}

	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
	//��������������������������������������������������������������Ŀ
	//� Executar processamento                                       �
	//����������������������������������������������������������������
	If _lRet                                    
	   
	   If nOpcx == 3        
	      begin transaction 
			  DBSelectArea("SZD")
			  DBSetOrder(1)
			  RecLock("SZD",.T.)
			  SZD->ZD_FILIAL := xFilial()
			  For nx := 1 to Len(aZDHead)
			      &("SZD->"+aZDhead[nx,2]) := &("M->"+aZDhead[nx,2])
			  Next 		    
			  msUnlock()
			  
			  DBSelectArea("SZE")
			  DBSetOrder(1)
	
			  
			  For naCols := 1 to Len(aCols)
			      RecLock("SZE",.T.)              
				  SZE->ZE_FILIAL := xFilial()
				  SZE->ZE_OS := SZD->ZD_NOS
				  SZE->ZE_NUM:= SZD->ZD_NUM
				  For nx := 1 to Len(aHeader)
				      if aheader[nx,2] != "ZE_NUM"
				         &("SZE->"+aheader[nx,2]) := aCols[naCols,nx]
				      endif  
				  Next 		    
				  msUnlock()    
			  next
			  ConfirmSX8()
		  end transaction   
		elseif nOpcx == 4
			  DBSelectArea("SZD")
			  DBSetOrder(1)
			  RecLock("SZD",.f.)
			  SZD->ZD_FILIAL := xFilial()
			  For nx := 1 to Len(aZDHead)
			      &("SZD->"+aZDhead[nx,2]) := &("M->"+aZDhead[nx,2])
			  Next 		    
			  msUnlock()
			  
			  DBSelectArea("SZE")
			  DBSetOrder(1)
			  
			  For naCols := 1 to Len(aCols)
			      IF DBSeek(xFilial()+ SZD->ZD_NUM + aCols[naCols,1])
				      RecLock("SZE",.f.)              
				  ELSE    
				      RecLock("SZE",.t.)              
					  SZE->ZE_FILIAL := xFilial()
					  SZE->ZE_OS := SZD->ZD_NOS
					  SZE->ZE_NUM:= SZD->ZD_NUM
				  ENDIF    
				  if aCols[naCols,nUsado+1] == .t.
				     DBDelete()
				     msUnlock()
				  else   
					  For nx := 1 to Len(aHeader)
					      if aheader[nx,2] != "ZE_NUM"
						      &("SZE->"+aheader[nx,2]) := aCols[naCols,nx]
						  endif    
					  Next 		    
				  endif	  
			  next
			  msUnlock()    
		elseif nOpcx == 5
		    Begin transaction 
		     For nx := 1 to Len(aCols)
				  DBSelectArea("SZE")
				  DBSetOrder(1)
				  IF DBSeek(xFilial()+ SZD->ZD_NUM + aCols[nx,1])
				     RecLock("SZE",.F.)
				     DBDelete()
				     MsUnlock()
				  ENDIF
			 Next	     
			 RecLock("SZD",.F.)
			 dbdelete()
			 msUnlock()       
			end transaction 
		endif
	Endif
Endif

User Function CriaItem()

aCols[n,1] := Strzero(n,2)
return .t.


User Function LinOk()

lResult := .t.
if Left(aCols[n,2],2) > "23" .or. Left(aCols[n,3],2) > "23" .or. substr(aCols[n,2],4,2) > "59" .or. substr(aCols[n,3],4,2) > "59" .or. empty(substr(aCols[n,3],4,2))
   Aviso("Formato Invalido","Campo Hora Inicio/Hora Final contem formato invalido.",{"Ok"})
   lResult := .f.
elseif empty(aCols[n,2]) .or. empty(aCols[n,3])
   lResult := .f.
endif
      
Return lResult

User Function TudOk()

lResult := .t.

For i1 := 1 to Len(aCols)
	if Left(aCols[n,2],2) > "23" .or. Left(aCols[n,3],2) > "23" .or. substr(aCols[n,2],4,2) > "59" .or. substr(aCols[n,3],4,2) > "59" .or. empty(substr(aCols[n,3],4,2))
	   Aviso("Formato Invalido","Campo Hora Inicio/Hora Final contem formato invalido.",{"Ok"})
	   lResult := .f.  
	   exit
	elseif empty(aCols[n,2]) .or. empty(aCols[n,3])
	   lResult := .f.
	endif
next      
Return lResult