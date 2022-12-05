#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#include "rwmake.ch"
#include "TbiConn.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "APWEBSRV.CH" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: AUTOM323.PRW                                                         *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho                                            *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 25/11/2014                                                           *
// Objetivo..: Programa que gera as Baixas e Estorno de Produtos atravez da leitura *
//             de arquivo TXT. Ver formato do arquivo em << Formato TXT >>          *
//***********************************************************************************

User Function AUTOM323()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local cMemo2	   := ""
   Local oMemo1
   Local oMemo2

   Private cPlanilha := Space(250)
   Private cCaminho  := Space(250)

   Private oGet1
   Private oGet2

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   Private oDlg

   Private aLista := {}
   Private oLista

   U_AUTOM628("AUTOM323")

   DEFINE MSDIALOG oDlg TITLE "Baixas e Estorno de Produtos" FROM C(178),C(181) TO C(616),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(381),C(001) PIXEL OF oDlg
   @ C(199),C(003) GET oMemo2 Var cMemo2 MEMO Size C(381),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Arquivo de produtos a ser utilizado"                     Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Produtos do arquivo carregado"                           Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(005) Say "Arquivo de LOG de Baixas e Estornos deverá ser salvo em" Size C(141),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) MsGet  oGet1 Var cPlanilha Size C(322),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(044),C(330) Button "..."               Size C(013),C(009)                              PIXEL OF oDlg ACTION( PESQPLANILHA() )
   @ C(041),C(347) Button "Carregar"          Size C(037),C(012)                              PIXEL OF oDlg ACTION( CARGAPLANILHA() )
   @ C(186),C(005) MsGet  oGet2 Var cCaminho  Size C(379),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(203),C(005) Button "Marca Todos"    Size C(051),C(012) PIXEL OF oDlg ACTION( MRCTODREG(1) )
   @ C(203),C(057) Button "Marca Baixar"   Size C(049),C(012) PIXEL OF oDlg ACTION( MRCTODREG(2) )
   @ C(203),C(107) Button "Marca Estornar" Size C(049),C(012) PIXEL OF oDlg ACTION( MRCTODREG(3) )
   @ C(203),C(157) Button "Desmarca Todos" Size C(051),C(012) PIXEL OF oDlg ACTION( MRCTODREG(4) )
   @ C(203),C(226) Button "Baixar"         Size C(050),C(012) PIXEL OF oDlg ACTION( AcaoBaixas() )
   @ C(203),C(277) Button "Estornar"       Size C(050),C(012) PIXEL OF oDlg ACTION( AcaoEstornar() )
   @ C(203),C(347) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { .F., "", "", "", "", "", "" } )

   // Lista com os produtos do pedido selecionado
   @ 085,006 LISTBOX oLista FIELDS HEADER "M", "Filial", "Descrição dos Cliente", "Produto", "Descrição dos Produtos", "Armazém", "Ação" PIXEL SIZE 488,135 OF oDlg ;
             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
           					    aLista[oLista:nAt,03],;
           					    aLista[oLista:nAt,04],;
          					    aLista[oLista:nAt,05],;
          					    aLista[oLista:nAt,06],;
          					    aLista[oLista:nAt,07]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQPLANILHA()

   cPlanilha := cGetFile('*.txt', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que carrega para a lista o conteúdo do arquivo indicado
Static Function CARGAPLANILHA()

   If Empty(Alltrim(cPlanilha))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Arquivo a ser utilizdo para carga não informado. Informe o arquivo a ser processado.")
      Return(.T.)
   Endif
   
   MsgRun("Favor Aguarde! Carregando dados do arquivo selecionado ...", "Selecionando Registros",{|| CRGPLANILHA() })      

Return(.T.)

// Função que carrega para a lista o conteúdo do arquivo indicado
Static Function CRGPLANILHA()

   Local aBrowse := {}
   Local nContar := 0

   // Abre o arquivo selecionado para pesquisa de dados
   nHandle := FOPEN(Alltrim(cPlanilha), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
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

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cAgravar := StrTran(cConteudo, chr(9), "|") + "|"
          aAdd(aBrowse, { cAgravar } )
          cConteudo := ""
       Endif
   Next nContar    

   // Alimenta a Lista aLista com o resultado capturado

   aLista := {}

   For nContar = 1 to Len(aBrowse)

       aAdd( aLista, { .F.                                   ,;
                       U_P_CORTA(aBrowse[nContar,1], "|", 1) ,;
                       U_P_CORTA(aBrowse[nContar,1], "|", 2) ,;
                       U_P_CORTA(aBrowse[nContar,1], "|", 3) ,;
                       U_P_CORTA(aBrowse[nContar,1], "|", 4) ,;
                       U_P_CORTA(aBrowse[nContar,1], "|", 7) ,;
                       U_P_CORTA(aBrowse[nContar,1], "|", 9) })
          
   Next nContar
   
   If Len(aLista) == 0
      MsgAlert("Não existem dados a serem visualizados para esta pesquisa. Verifique dados informados.")
      aAdd( aLista, { .F., "", "", "", "", "", "" } )   
   Endif

   oLista:SetArray( aLista )

   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
           					    aLista[oLista:nAt,02],;
           					    aLista[oLista:nAt,03],;
           					    aLista[oLista:nAt,04],;
          					    aLista[oLista:nAt,05],;
          					    aLista[oLista:nAt,06],;
          					    aLista[oLista:nAt,07]}}
   oLista:Refresh()
      
Return(.T.)

// Função que marca/desmarca os registros conforme botão acionado
Static Function MRCTODREG(_BotaoAcionado)

   Local nContar := 0

   For nContar = 1 to Len(aLista)
 
       Do Case
          Case _BotaoAcionado == 1
               aLista[nContar,01] :=  .T.
          Case _BotaoAcionado == 2
               If Upper(Alltrim(aLista[nContar,07])) == "BAIXAR"
                  aLista[nContar,01] :=  .T.
               Endif
          Case _BotaoAcionado == 3
               If Upper(Alltrim(aLista[nContar,07])) == "ESTORNAR"
                  aLista[nContar,01] :=  .T.
               Endif
          Case _BotaoAcionado == 4
               aLista[nContar,01] :=  .F.
       EndCase
   Next nContar                      
   
Return(.T.)

// Função que processa a ação ESTORNAR (Transfere de um armazém para outro) - Passo - 1
Static Function AcaoEstornar()

   MsgRun("Favor Aguarde! Realizando transferência entre armazéns ...", "Transferindo Produtos",{|| AEstornar() })      

   MsgAlert("Transferência entre armazéns realizada com sucesso." + chr(13) + chr(10) + "Verifique arquivo de log de estornos para observar possíveis divergências.")

Return(.T.)

// Função que processa a ação ESTORNAR (Transfere de um armazém para outro)
Static Function AEstornar()

   Local nContar       := 0
   Local lMarcado      := .F.
   Local cSql          := ""
   Local aAuto         := {}
   Local aItem         := {}
   Local _xDOCx        := ""
   Local cLote         := "   "
   Local dDataVl       := ""
   Local nQuant        := 1
   Local nOpcAuto      := 3 // Indica qual tipo de ação será tomada (Inclusão/Exclusão)
   Local cString       := ""

   PRIVATE lMsHelpAuto := .T.
   PRIVATE lMsErroAuto := .F.

   // Verifica se caminho para gravação do arquivo de log de baixa foi informado
   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo de LOG não informado.")
      Return(.T.)
   Endif

   // Verifica se houve marcação de pelo menos um registro para realizar a transferência entre armazéns
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro foi marcado para realizar a transferência entre armazéns.")
      Return(.T.)
   Endif
             
   // Verifica se houve marcação de pelo menos um registro de ação de Estornar
   lMarcado := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          If Upper(Alltrim(aLista[nContar,07])) == "ESTORNAR"
             lMarcado := .T.
             Exit
          Endif
       Endif
   Next nContar
      
   If lMarcado == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro de transferência de armazém foi marcado para processamento.")
      Return(.T.)
   Endif

   // Inicializa a variável que conterá o log da transferência
   cString := ""

   // Processa as transferências entre armazéns
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif

       _ChavePesqPro := "  " + Strzero(Int(val(Alltrim(aLista[nContar,04]))),6)
       cProduto      := Strzero(Int(val(Alltrim(aLista[nContar,04]))),6)

       If Upper(Alltrim(aLista[nContar,07])) == "ESTORNAR"
       Else
          cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " não é um registro de Estorno." + chr(13) + chr(10)
          Loop
       Endif

       // Captura dados do produto
       DbSelectArea("SB1")
       DbSetOrder(1)

       If dbSeek( _ChavePesqPro )
          cProd   := B1_COD
          cDescri := B1_DESC
          cUM     := B1_UM
          cLocal  := B1_LOCPAD
       Else
          cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " não localizado." + chr(13) + chr(10)
          Loop
       EndIf

       // Se produto for com localização (Nº de Série), despreza porque na planilha não existe o nº de série
       If B1_Localiz == "S"
          cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " tem controle de nº de série. Produto não transferido." + chr(13)  + chr(10)
          Loop
       Endif

       _UnidadeMed := Posicione("SB1", 1, _ChavePesqPro, "B1_UM")
       _xDOCx      := GetSxENum("SD3","D3_DOC",1)
       cLote       := "   "
       dDataVl     := CTOD("  /  /    ")
       nQuant      := 1
       nOpcAuto    := 3
            
       // Verifica se existe o armazém 01
       // DbSelectArea("SB2")
       // DbSetOrder(1)
       // IF !SB2->(DBSEEK( _ChavePesqPro + "01" ))
       //    CriaSB2( cProduto, "01")
       // ENDIF     

       // Verifica se existe o armazém do técnico
       // IF !SB2->(DBSEEK(xFilial("SB2") + Alltrim(cProduto) + Space(24) + aLista[nContar,06] ))      
       //    CriaSB2( cProduto, aLista[nContar,06])
       // ENDIF     

       // Realiza a transferência do armazém 01 para o armazém 98
       Begin Transaction

          // Cabecalho a Incluir
          aAuto := {}
          aItem := {}
          aadd(aAuto,{_xDOCx,dDataBase}) //Cabecalho

          // Dados do itema ser transferido
          aadd(aItem,cProd)              // 01 - D3_COD  
          aadd(aItem,cDescri)            // 02 - D3_DESCRI
          aadd(aItem,cUM)                // 03 - D3_UM
          aadd(aItem,aLista[nContar,06]) // 04 - D3_LOCAL DO TÉCNICO (LOCAL DE ORIGEM)
          aadd(aItem,"")                 // 05 - D3_LOCALIZ DE ORIGEM
          aadd(aItem,cProd)              // 06 - D3_COD
          aadd(aItem,cDescri)            // 07 - D3_DESCRI
          aadd(aItem,cUM)                // 08 - D3_UM
          aadd(aItem,"01")               // 09 - D3_LOCAL
          aadd(aItem,"")                 // 10 - D3_LOCALIZ
          aadd(aItem,"")                 // 11 - D3_NUMSERI
          aadd(aItem,cLote)              // 12 - D3_LOTECTL
          aadd(aItem,"")                 // 13 - D3_NUMLOTE
          aadd(aItem,dDataVl)            // 14 - D3_DTVALID
          aadd(aItem,0)                  // 15 - D3_POTENCI
          aadd(aItem,nQuant)             // 16 - D3_QUANT
          aadd(aItem,0)                  // 17 - D3_QTSEGUM
          aadd(aItem,"")                 // 18 - D3_ESTORNO
          aadd(aItem,"")                 // 19 - D3_NUMSEQ
          aadd(aItem,cLote)              // 20 - D3_LOTECTL
          aadd(aItem,dDataVl)            // 21 - D3_DTVALID
          aadd(aItem,"")                 // 22 - D3_ITEMGRD
          aadd(aAuto,aItem)
  
          MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

          If !lMsErroAuto
             cString += "[SOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " transferido com sucesso." + chr(13) + chr(10)
          Else
             cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " ocorreu erro no processo de transferência." + chr(13) + chr(10)
          EndIf

       End Transaction

   Next nContar
   
   // Salva o arquivo de log de Baixas
   If Substr(Alltrim(cCaminho), Len(Alltrim(cCaminho)), 01) <> "\"
      cCaminho := Alltrim(cCaminho) + "\"
   Else
      cCaminho := Alltrim(cCaminho)
   Endif

   nHdl := fCreate(cCaminho + "LOG_ESTORNO.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

Return(.T.)

// Função que processa a ação BAIXAS Passo - 1
Static Function AcaoBaixas()

   MsgRun("Favor Aguarde! Realizando baixas de produtos selecionados ...", "Baixando Produtos",{|| ABaixar() })      

   MsgAlert("Baixas realizadas com sucesso." + chr(13) + chr(10) + "Verifique arquivo de log de baixas para observar possíveis divergências.")

Return(.T.)

// Função que processa a ação BAIXAS - Passo - 2
Static Function ABaixar()

   Local nContar  := 0
   Local lMarcado := .F.
   Local cSql     := ""
   Local aAuto    := {}
   Local aItem    := {}
   Local _xDOCx   := ""
   Local cLote    := "   "
   Local dDataVl  := ""
   Local nQuant   := 1
   Local nOpcAuto := 3 // Indica qual tipo de ação será tomada (Inclusão/Exclusão)
   Local cString  := ""
   Local aCabS    := {}
   Local aItemS   := {}      

   PRIVATE lMsHelpAuto := .T.
   PRIVATE lMsErroAuto := .F.

   // Verifica se caminho para gravação do arquivo de log de baixa foi informado
   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo de LOG não informado.")
      Return(.T.)
   Endif

   // Verifica se houve marcação de pelo menos um registro para realizar a transferência entre armazéns
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro foi marcado para realizar o processo de Baixa.")
      Return(.T.)
   Endif
             
   // Verifica se houve marcação de pelo menos um registro de ação de Estornar
   lMarcado := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          If Upper(Alltrim(aLista[nContar,07])) == "BAIXAR"
             lMarcado := .T.
             Exit
          Endif
       Endif
   Next nContar
      
   If lMarcado == .F.
      Msgalert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro de baixa foi marcado para processamento.")
      Return(.T.)
   Endif

   // Inicializa a variável que conterá o log da transferência
   cString := ""

   // Cria o cabeçalho do documento de entrada dos produtos a serem baixados
   For nContar = 1 to Len(aLista)

       If aLista[nContar,1] == .F.
          Loop
       Endif

       _ChavePesqPro := "  " + Strzero(Int(val(Alltrim(aLista[nContar,04]))),6)
       _FilialLanca  := Strzero(Int(Val(aLista[nContar,02])),2)
       cProduto      := Strzero(Int(val(Alltrim(aLista[nContar,04]))),6)

       If Upper(Alltrim(aLista[nContar,07])) == "BAIXAR"
       Else
          cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " não é um registro de Baixa." + chr(13) + chr(10)
          Loop
       Endif

       aCabS    := {}
       aItemS   := {}      
       lEfetiva := .F.
       _xDOCx   := GetSxENum("SD3","D3_DOC",1)
   
       aCabS := {{"D3_DOC"    , _xDOCx , Nil},;
                 {"D3_TM"     , "600"  , Nil},;
                 {"D3_CC"     , ''     , Nil},;
                 {"D3_EMISSAO", Date() , Nil}}
                                                   
       // Verifica se existe saldos para a quantidade solicitada para reserva    
       dbSelectArea("SB2")
       dbSetOrder(1)
       MsSeek( _FilialLanca + Padr(cProduto,30) + aLista[nContar,06])

       If SaldoSb2() <= 0
          cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " não baixado por falta de saldo no armazém " + aLista[nContar,06] + chr(13) + chr(10)
          Loop
       Else
          aadd(aItemS,{{"D3_FILIAL", _FilialLanca      , NIL},;
                       {"D3_COD"   , cProduto          , NIL},;
                       {"D3_QUANT" , 1                 , NIL},;
                       {"D3_LOCAL" , aLista[nContar,06], NIL}})
       Endif

       // Atualiza os registros de Movimentação Interna 2
       Begin Transaction

          MSExecAuto({|x,y,z|MATA241(x,y,z)},aCabS,aItemS, 3)

          If !lMsErroAuto
             cString += "[SOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + " baixado com sucesso." + chr(13) + chr(10)
          Else
             cString += "[NOK] - Produto: " + cProduto + " - " + Alltrim(aLista[nContar,05]) + "não baixado por erro no envio do comando MSExecAuto." + chr(13) + chr(10)
          EndIf

       End Transaction

   Next nContar
  
   // Salva o arquivo de log de Baixas
   If Substr(Alltrim(cCaminho), Len(Alltrim(cCaminho)), 01) <> "\"
      cCaminho := Alltrim(cCaminho) + "\"
   Else
      cCaminho := Alltrim(cCaminho)
   Endif

   nHdl := fCreate(cCaminho + "LOG_BAIXAS.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

Return(.T.)