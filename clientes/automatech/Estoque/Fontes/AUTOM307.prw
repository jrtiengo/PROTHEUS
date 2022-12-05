#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM298.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/06/2015                                                          *
// Objetivo..: Programa que realiza a geração do arquivo de envio de informações   *
//             do Contas a Receber da Automatech ao SERASA.                        *
//**********************************************************************************

User Function AUTOM307()

   Private oDlgETL

   U_AUTOM628("AUTOM307")

   DEFINE MSDIALOG oDlgETL TITLE "Carga Campos de Tabelas" FROM C(178),C(181) TO C(332),C(430) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(117),C(026) PIXEL NOBORDER OF oDlgETL

   @ C(033),C(005) Button "Cadastro de Produtos"   Size C(115),C(012) PIXEL OF oDlgETL ACTION( CargaTela(1) )
   @ C(046),C(005) Button "Cadastro de Vendedores" Size C(115),C(012) PIXEL OF oDlgETL ACTION( CargaTela(2) )
   @ C(060),C(005) Button "Voltar"                 Size C(115),C(012) PIXEL OF oDlgETL ACTION( oDlgETL:End() )

   ACTIVATE MSDIALOG oDlgETL CENTERED 

Return(.T.)

// Função que abre tela de solicitação do caminho do arquivo a ser utilizdo
Static Function CargaTela(___Tipo)

   Local lChumba := .F.
   
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cArquivo := Space(150)
   Private oGet1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Carga de Campos de Tabelas" FROM C(178),C(181) TO C(351),C(591) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(005) GET oMemo1 Var cMemo1 MEMO Size C(194),C(001) PIXEL OF oDlg
   @ C(064),C(005) GET oMemo2 Var cMemo2 MEMO Size C(194),C(001) PIXEL OF oDlg
   
   @ C(041),C(005) Say "Arquivo de conteúdo a ser utilizado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(050),C(005) MsGet  oGet1 Var cArquivo Size C(183),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg  When lChumba
   @ C(050),C(189) Button "..."              Size C(012),C(009)                              PIXEL OF oDlg ACTION( PESQARQUIVO() )

   @ C(070),C(064) Button "Processar" Size C(037),C(012) PIXEL OF oDlg ACTION( CargaCampo(___Tipo) )
   @ C(070),C(102) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQARQUIVO()

   cArquivo := cGetFile('*.*', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que realiza a carga do conteúdo conforme parametrização
Static Function CargaCampo(___Tipo)

   Local aConteudo   := {}
   Local aBrowse     := {}
   Local nContar     := 0
   Local nInicializa := 0
   Local cConteudo   := ""

   If Empty(Alltrim(cArquivo))
      MsgAlert("Arquivo com o conteúdo a ser utilizado não informado.")
      Return(.T.)
   Endif
   
   // Carrega o arquivo de Conciliação informado
   nHandle := FOPEN(Alltrim(cArquivo), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo informado.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Registros
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   If ___Tipo == 1
      For nContar = 1 to Len(xBuffer)
          If Substr(xBuffer, nContar, 1) <> Chr(10)
             cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
          Else
             aAdd(aConteudo, { cConteudo + chr(9) } )
             cConteudo := ""
          Endif
      Next nContar    
   Else
      For nContar = 1 to Len(xBuffer)
          If Substr(xBuffer, nContar, 1) <> Chr(13)
             cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
          Else
             aAdd(aConteudo, { cConteudo + chr(9) } )
             cConteudo := ""
          Endif
      Next nContar    
   Endif      

   // Separa os campo para utilização
   If ___Tipo == 1

      cConteudo := ""
      For nContar = 1 to Len(aConteudo)
          nVezes := U_P_OCCURS(aConteudo[nContar,01], CHR(9), 1)
 
          For nInicializa = 1 to nVezes
              j := Strzero(nInicializa,2)
              _Campo&j := ""
          Next nInicializa    
 
          For nSepara = 1 to nVezes
              j := Strzero(nSepara,2)           
              _Campo&j := U_P_CORTA(aConteudo[nContar,01], CHR(9), nSepara)
          Next nSepara

          aAdd(aBrowse, { _Campo01,;
                          _Campo02,;
                          _Campo03,;
                          _Campo04,;
                          _Campo05,;
                          _Campo06,;
                          _Campo07,;
                          _Campo08,;
                          _Campo09,;
                          _Campo10,;
                          _Campo11,;
                          _Campo12,;
                          _Campo13,;
                          _Campo14,;
                          _Campo15,;
                          _Campo16,;
                          _Campo17,;
                          _Campo18,;
                          _Campo19})

      Next nContar    

      // Atualiza os Campos na tabela de produtos
      For nContar = 1 to Len(aBrowse)

          // Prepara o código para realizar a pesquisa
          nProduto := Alltrim(aBrowse[nContar,01])
       
          If Len(nProduto) < 10
             If Len(nProduto) < 6
                nProduto := Strzero(Int(Val(nproduto)),6)
             Endif
          Endif
       
          // Seleciona o cadastro do produto
      	  dbSelectArea("SB1")
	      dbSetOrder(1)
	
   	      If dbSeek( xFilial("SB1") + nProduto )
	         Reclock("SB1",.f.)
             SB1->B1_CHASSI := aBrowse[nContar,02]
	         SB1->B1_PESC   := INT(VAL(aBrowse[nContar,03]))
	         SB1->B1_COMP   := INT(VAL(aBrowse[nContar,04]))
	         SB1->B1_ALTU   := INT(VAL(aBrowse[nContar,05]))
	         SB1->B1_LARG   := INT(VAL(aBrowse[nContar,06]))
	         SB1->B1_WEB    := aBrowse[nContar,07]
	         SB1->B1_USUI   := aBrowse[nContar,08]
	         SB1->B1_DATAI  := Ctod(aBrowse[nContar,09])
	         SB1->B1_HORAI  := aBrowse[nContar,10]
	         SB1->B1_USUL   := aBrowse[nContar,11]
	         SB1->B1_DATAL  := Ctod(aBrowse[nContar,12])
	         SB1->B1_HORAL  := aBrowse[nContar,13]
	         SB1->B1_STLB   := aBrowse[nContar,14]
	         SB1->B1_BLQESP := aBrowse[nContar,15]
	         SB1->B1_ROLO   := aBrowse[nContar,16]
	         SB1->B1_MPCLAS := aBrowse[nContar,17]
	         SB1->B1_ZVIR   := aBrowse[nContar,18]
	         SB1->B1_ETQROT := aBrowse[nContar,19]
	         MsUnlock()
	      Endif

      Next nContar
      
   Else
   
      cConteudo := ""
      For nContar = 1 to Len(aConteudo)
          nVezes := U_P_OCCURS(aConteudo[nContar,01], CHR(9), 1)
 
          For nInicializa = 1 to nVezes
              j := Strzero(nInicializa,2)
              _Campo&j := ""
          Next nInicializa    
 
          For nSepara = 1 to nVezes
              j := Strzero(nSepara,2)           
              _Campo&j := U_P_CORTA(aConteudo[nContar,01], CHR(9), nSepara)
          Next nSepara

          aAdd(aBrowse, { _Campo01,;
                          _Campo02,;
                          _Campo03,;
                          _Campo04,;
                          _Campo05,;
                          _Campo06,;
                          _Campo07,;
                          _Campo08,;
                          _Campo09,;
                          _Campo10,;
                          _Campo11,;
                          _Campo12})

      Next nContar    

      // Atualiza os Campos na tabela de produtos
      For nContar = 1 to Len(aBrowse)

          // Prepara o código para realizar a pesquisa
          nVendedor := Strzero(Int(Val(Alltrim(aBrowse[nContar,01]))),6)
       
          // Seleciona o cadastro do produto
      	  dbSelectArea("SA3")
	      dbSetOrder(1)
	
   	      If dbSeek( xFilial("SA3") + nVendedor )

	         Reclock("SA3",.f.)
             SA3->A3_TSTAT  := aBrowse[nContar,02]
	         SA3->A3_PISCOF := aBrowse[nContar,03]
	         SA3->A3_TIPOV  := aBrowse[nContar,04]
	         SA3->A3_FATU   := aBrowse[nContar,05]
	         SA3->A3_RMA    := aBrowse[nContar,06]
	         SA3->A3_ARMA   := aBrowse[nContar,07]
	         SA3->A3_FILTRO := aBrowse[nContar,08]
	         SA3->A3_ASSI   := aBrowse[nContar,09]
	         SA3->A3_OUTR   := aBrowse[nContar,10]
	         SA3->A3_ZABRE  := INT(VAL(aBrowse[nContar,11]))
	         SA3->A3_ZTBI   := aBrowse[nContar,12]
	         MsUnlock()
	      Endif

      Next nContar
   
   Endif
      
   msgalert("Aletração realizada com sucesso.")

   oDlg:End()

Return(.T.)