#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO4     º Autor ³ AP6 IDE            º Data ³  19/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CALAPCP()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro := "Producao Gráfica"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array (tambem deve ser aRotina sempre) com as definicoes das opcoes ³
//³ que apareceram disponiveis para o usuario. Segue o padrao:          ³
//³ aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
//³              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
//³              . . .                                                  ³
//³              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      ³
//³ Onde: <DESCRICAO> - Descricao da opcao do menu                      ³
//³       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  ³
//³                     duplas e pode ser uma das funcoes pre-definidas ³
//³                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA ³
//³                     e AXDELETA) ou a chamada de um EXECBLOCK.       ³
//³                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-³
//³                     clarar uma variavel chamada CDELFUNC contendo   ³
//³                     uma expressao logica que define se o usuario po-³
//³                     dera ou nao excluir o registro, por exemplo:    ³
//³                     cDelFunc := 'ExecBlock("TESTE")'  ou            ³
//³                     cDelFunc := ".T."                               ³
//³                     Note que ao se utilizar chamada de EXECBLOCKs,  ³
//³                     as aspas simples devem estar SEMPRE por fora da ³
//³                     sintaxe.                                        ³
//³       <TIPO>      - Identifica o tipo de rotina que sera executada. ³
//³                     Por exemplo, 1 identifica que sera uma rotina de³
//³                     pesquisa, portando alteracoes nao podem ser efe-³
//³                     tuadas. 3 indica que a rotina e de inclusao, por³
//³                     tanto, a rotina sera chamada continuamente ao   ³
//³                     final do processamento, ate o pressionamento de ³
//³                     <ESC>. Geralmente ao se usar uma chamada de     ³
//³                     EXECBLOCK, usa-se o tipo 4, de alteracao.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ³
//³ MBROWSE sera identica a da AXCADASTRO:                              ³
//³                                                                     ³
//³ cDelFunc  := ".T."                                                  ³
//³ aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ³
//³                { "Visualizar"   ,"AxVisual" , 0, 2},;               ³
//³                { "Incluir"      ,"AxInclui" , 0, 3},;               ³
//³                { "Alterar"      ,"AxAltera" , 0, 4},;               ³
//³                { "Excluir"      ,"AxDeleta" , 0, 5} }               ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta um aRotina proprio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             {"Visualizar","u_SHWOS()",0,2} ,;
             {"Incluir","u_insOS()",0,3} ,;
             {"Alterar","u_UPDOS()",0,4} ,;
             {"Excluir","u_DELOS()",0,5} }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SZD"

dbSelectArea("SZD")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a funcao MBROWSE. Sintaxe:                                  ³
//³                                                                     ³
//³ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ³
//³ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ³
//³                        exibido. Para seguir o padrao da AXCADASTRO  ³
//³                        use sempre 6,1,22,75 (o que nao impede de    ³
//³                        criar o browse no lugar desejado da tela).   ³
//³                        Obs.: Na versao Windows, o browse sera exibi-³
//³                        do sempre na janela ativa. Caso nenhuma este-³
//³                        ja ativa no momento, o browse sera exibido na³
//³                        janela do proprio SIGAADV.                   ³
//³ Alias                - Alias do arquivo a ser "Browseado".          ³
//³ aCampos              - Array multidimensional com os campos a serem ³
//³                        exibidos no browse. Se nao informado, os cam-³
//³                        pos serao obtidos do dicionario de dados.    ³
//³                        E util para o uso com arquivos de trabalho.  ³
//³                        Segue o padrao:                              ³
//³                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ³
//³                                     {<CAMPO>,<DESCRICAO>},;         ³
//³                                     . . .                           ³
//³                                     {<CAMPO>,<DESCRICAO>} }         ³
//³                        Como por exemplo:                            ³
//³                        aCampos := { {"TRB_DATA","Data  "},;         ³
//³                                     {"TRB_COD" ,"Codigo"} }         ³
//³ cCampo               - Nome de um campo (entre aspas) que sera usado³
//³                        como "flag". Se o campo estiver vazio, o re- ³
//³                        gistro ficara de uma cor no browse, senao fi-³
//³                        cara de outra cor.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("SZD",(cOpcao=="INCLUIR"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo:="Apontamento de Produção"
	cAliasEnchoice:="SZD"
	cAliasGetD:="SZE"
	cLinOk:="U_LinOk()"
	cTudOk:="U_TudOk()"
	cFieldOk:="U_CriaItem()"
	//aCpoEnchoice:={"C5_CLIENTE"}

	_lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executar processamento                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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