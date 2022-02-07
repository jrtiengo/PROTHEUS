#Include 'Protheus.ch' //Informa a biblioteca
 
User Function exemplo2() //U_exemplo1()

    Local aaCampos  	:= {"CODIGO"} //Variável contendo o campo editável no Grid
    Local aBotoes	    := {}         //Variável onde será incluido o botão para a legenda

    Private oLista                    //Declarando o objeto do browser
    Private aCabecalho  := {}         //Variavel que montará o aHeader do grid
    Private aColsEx 	:= {}         //Variável que receberá os dados
 
    //Declarando os objetos de cores para usar na coluna de status do grid
    Private oVerde  	:= LoadBitmap( GetResources(), "BR_VERDE")
    Private oAzul  	    := LoadBitmap( GetResources(), "BR_AZUL")
    Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
    Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")
 
    DEFINE MSDIALOG oDlg TITLE "TITULO" FROM 000, 000  TO 300, 700  PIXEL
        //chamar a função que cria a estrutura do aHeader
        kCriaCabec()
 
        //Monta o browser com inclusão, remoção e atualização
        oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE,;
                  "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)
 
        //Carregar os itens que irão compor o conteudo do grid
        kCarregar()
 
        //Alinho o grid para ocupar todo o meu formulário
        oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 
        //Ao abrir a janela o cursor está posicionado no meu objeto
        oLista:oBrowse:SetFocus()
 
        //Crio o menu que irá aparece no botão Ações relacionadas
//        aadd(aBotoes,{"NG_ICO_LEGENDA", {||kLegenda()},"Legenda","Legenda"})
 
//        EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },,aBotoes)
 
    ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function kCriaCabec()

/*
    Aadd(aCabecalho, {;
                  "",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//
*/

    Aadd(aCabecalho, {;
                  "Item",;//X3Titulo()
                  "ITEM",;  //X3_CAMPO
                  "@!",;		//X3_PICTURE
                  5,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {;
                  "Tipo",;//X3Titulo()
                  "TIPO",;  //X3_CAMPO
                  "@!",;		//X3_PICTURE
                  5,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {;
                  "Codigo",;	//X3Titulo()
                  "CODIGO",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  10,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "SB1",;		//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
    Aadd(aCabecalho, {;
                  "Descricao",;	//X3Titulo()
                  "DESCRICAO",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  50,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
 
Return
                                            
Static Function kCarregar()
    Local aProdutos := {}
 
    aadd(aProdutos,{"000001","PRODUTO 1","UN"})
    aadd(aProdutos,{"000002","PRODUTO 2","UN"})
    aadd(aProdutos,{"000003","PRODUTO 3","PC"})
    aadd(aProdutos,{"000004","PRODUTO 4","MT"})
    aadd(aProdutos,{"000005","PRODUTO 5","PC"})
    aadd(aProdutos,{"000006","PRODUTO 6",""})
 
    For i := 1 to len(aProdutos)
 
        //aadd(aColsEx,{oVerde,StrZero(i,3),aProdutos[i,3],aProdutos[i,1],aProdutos[i,2],.F.})
        aadd(aColsEx,{oVerde,StrZero(i,3),aProdutos[i,3],aProdutos[i,1],aProdutos[i,2],.F.})

    Next
 
    //Setar array do aCols do Objeto.
    oLista:SetArray(aColsEx,.T.)
 
    //Atualizo as informações no grid
    oLista:Refresh()
    
Return
	
Static function kLegenda()
    Local aLegenda := {}
    AADD(aLegenda,{"BR_AMARELO"     ,"   Tipo não definido" })
    AADD(aLegenda,{"BR_AZUL"    	,"   Tipo PC" })
    AADD(aLegenda,{"BR_VERDE"    	,"   Tipo UN" })
    AADD(aLegenda,{"BR_VERMELHO" 	,"   Tipo MT" })
 
    BrwLegenda("Legenda", "Legenda", aLegenda)
Return Nil