#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca

 
User Function exemplo1() //U_exemplo1()

//    Local aaCampos  	:= {"PAR_CRIA",;
//                            "PAR_DINI",;
//                            "PAR_DFIM",;
//                            "PAR_EMPR",;
//                            "PAR_FILI",;
//                            "PAR_CLIE",;
//                            "PAR_LOJA",;
//                            "PAR_COND",;
//                            "PAR_TABE",;
//                            "PAR_TPOS",;
//                            "PAR_CSER"} // Variável contendo o campo editável no Grid

    Local aaCampos  	:= {}
    Local aBotoes	    := {}           // Variável onde será incluido o botão para a legenda
    
    Private oLista                      // Declarando o objeto do browser
    Private aCabecalho  := {}           // Variavel que montará o aHeader do grid
    Private aColsEx 	:= {}           // Variável que receberá os dados
 
    // Declarando os objetos de cores para usar na coluna de status do grid
    Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE")
    Private oAzul  	  := LoadBitmap( GetResources(), "BR_AZUL")
    Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
    Private oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
 
    DEFINE MSDIALOG oDlg TITLE "Parâmetros Importador OS SIRTEC" FROM 000, 000  TO 550, 1200  PIXEL

    // Chamar a função que cria a estrutura do aHeader
    CriaCabec()
 
    // Monta o browser com inclusão, remoção e atualização
//    oLista := MsNewGetDados():New( 053, 078, 415, 775, GD_INSERT+GD_DELETE+GD_UPDATE,;
//              "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)

    oLista := MsNewGetDados():New( 053, 078, 500, 900, GD_INSERT+GD_DELETE+GD_UPDATE,;
              "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)

 
    // Carregar os itens que irão compor o conteudo do grid
    Carregar()
 
    // Alinho o grid para ocupar todo o meu formulário
    oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 
    // Ao abrir a janela o cursor está posicionado no meu objeto
    oLista:oBrowse:SetFocus()
 
    // Crio o menu que irá aparece no botão Ações relacionadas
    aadd(aBotoes,{"NG_ICO_LEGENDA", {||Legenda()},"Legenda","Legenda"})
 
    EnchoiceBar(oDlg, {|| oDlg:End() }, {|| oDlg:End() },,aBotoes)
 
    ACTIVATE MSDIALOG oDlg CENTERED

Return
 
// Função que cria o Cabeçalho a ser visualizados no grid 
Static Function CriaCabec()
                                   
    // 01 - X3Titulo()
    // 02 - X3_CAMPO
    // 03 - X3_PICTURE
    // 04 - X3_TAMANHO
    // 05 - X3_DECIMAL
    // 06 - X3_VALID
    // 07 - X3_USADO
    // 08 - X3_TIPO
    // 09 - X3_F3
    // 10 - X3_CONTEXT
    // 11 - X3_CBOX
    // 12 - X3_RELACAO
    // 13 - X3_WHEN

    Aadd(aCabecalho, {"Contrato"       , "PAR_CONT", "@!", 15, 0, "", "", "C", ""   , "V", "", "", ""})
    Aadd(aCabecalho, {"Centro Serviço" , "PAR_CENT", "@!", 15, 0, "", "", "C", ""   , "V", "", "", ""})
    Aadd(aCabecalho, {"Tipo Serviço"   , "PAR_TSER", "@!",  5, 0, "", "", "C", ""   , "V", "", "", ""})
    Aadd(aCabecalho, {"Cria OS Mensal" , "PAR_CRIA", "@!",  1, 0, "", "", "C", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Dia Inicial"    , "PAR_DINI", "@!",  8, 0, "", "", "D", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Dia Final"      , "PAR_DFIM", "@!",  8, 0, "", "", "D", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Empresa"        , "PAR_EMPR", "@!",  2, 0, "", "", "C", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Filial"         , "PAR_FILI", "@!",  2, 0, "", "", "C", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Cliente"        , "PAR_CLIE", "@!",  6, 0, "", "", "C", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Loja Cli"       , "PAR_LOJA", "@!",  3, 0, "", "", "C", "SA1", "R", "", "", ""})
    Aadd(aCabecalho, {"Cond.Pgtº"      , "PAR_COND", "@!",  3, 0, "", "", "C", "SA1", "R", "", "", ""})
    Aadd(aCabecalho, {"Tabela Preço"   , "PAR_TABE", "@!",  3, 0, "", "", "C", "SA1", "R", "", "", ""})
    Aadd(aCabecalho, {"Tipo OS"        , "PAR_TPOS", "@!",  3, 0, "", "", "C", ""   , "R", "", "", ""})
    Aadd(aCabecalho, {"Codigo Serviço" , "PAR_CSER", "@!",  3, 0, "", "", "C", ""   , "R", "", "", ""})

Return                   

// Função que carrega o grid
Static Function Carregar()

    Local aProdutos := {}
 
    aadd(aProdutos,{"Contrato  1","Centro  1","Tipo  1", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  2","Centro  2","Tipo  2", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  3","Centro  3","Tipo  3", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  4","Centro  4","Tipo  4", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  5","Centro  5","Tipo  5", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  6","Centro  6","Tipo  6", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  7","Centro  7","Tipo  7", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  8","Centro  8","Tipo  8", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato  9","Centro  9","Tipo  9", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato 10","Centro 10","Tipo 10", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato 11","Centro 11","Tipo 11", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato 12","Centro 12","Tipo 12", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato 13","Centro 13","Tipo 13", "", "", "", "", "", "", "", "", "", "", "" })
    aadd(aProdutos,{"Contrato 14","Centro 14","Tipo 14", "", "", "", "", "", "", "", "", "", "", "" })

//    For i := 1 to len(aProdutos)
//        aadd(aColsEx,{aProdutos[i,01],;
//                      aProdutos[i,02],;
//                      aProdutos[i,03],;
//                      aProdutos[i,04],;
//                      aProdutos[i,05],;
//                      aProdutos[i,06],;
//                      aProdutos[i,07],;
//                      aProdutos[i,08],;
//                      aProdutos[i,09],;
//                      aProdutos[i,10],;
//                      aProdutos[i,11],;
//                      aProdutos[i,12],;
//                      aProdutos[i,13],;                                                  
//                      aProdutos[i,14]})
//    Next
                                     
    aadd(aColsEx,{"Contrato 14","Centro 14","Tipo 14", "", "", "", "", "", "", "", "", "", "", "" })
     
    //Setar array do aCols do Objeto.
    oLista:SetArray(aColsEx,.T.)
 
    //Atualizo as informações no grid
    oLista:Refresh()

Return                   

Static function Legenda()

    Local aLegenda := {}

    AADD(aLegenda,{"BR_AMARELO"     ,"   Tipo não definido" })
    AADD(aLegenda,{"BR_AZUL"    	,"   Tipo PC" })
    AADD(aLegenda,{"BR_VERDE"    	,"   Tipo UN" })
    AADD(aLegenda,{"BR_VERMELHO" 	,"   Tipo MT" })
 
    BrwLegenda("Legenda", "Legenda", aLegenda)

Return Nil