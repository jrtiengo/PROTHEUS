#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM211.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/04/2013                                                          *
// Objetivo..: Programa que realiza a importação do XML do Conhecimento de Trans-  *
//             porte para carregar o valor do Frete no documento de Entrada ou de  *
//             Saída.                                                              *
//**********************************************************************************

User Function AUTOM211()

   Local cSql         := ""
   Local lChumba      := .F.

   Local cMemo1	      := ""
   Local cMemo2	      := ""
   Local cMemo3	      := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private cArquivo   := Space(150)
   Private cTranspo   := Space(100)
   Private cRemetente := Space(100)
   Private cDestino   := Space(100)
   Private cValFrete  := 0
   Private nAcumulado := 0
   Private cSerie     := ""
   Private cNumero    := ""
   Private cModelo    := ""
   Private xChave     := Space(150)
   Private cCNPJT     := Space(14)
   Private cCodTransp := Space(06)
   Private cCGCFor    := Space(14)
   Private cCodFor    := Space(06)
   Private cLojFor    := Space(03)
   Private cCGCDest   := Space(14)
   Private cCodCli    := Space(06)
   Private cLojCli    := Space(03)
   Private cdataCTE   := Ctod("  /  /    ")
   Private lAbre      := .F.

   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8      
   Private oGet9      
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14   

   Private lEntrada := .F.
   Private lSaida   := .F.
   Private lFecha   := .F.  
   
   Private oCheckBox1
   Private oCheckBox2

   Private aListBox1 := {}
   Private oListBox1

   Private aNotas    := {}
   Private aFrete    := {}
   
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oDlg

   U_AUTOM628("AUTOM211")

   DEFINE MSDIALOG oDlg TITLE "Importação Conhecimento de Transporte" FROM C(178),C(181) TO C(631),C(609) PIXEL

   @ C(001),C(005) Say "Chave"                             Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Conhecimento de Transporte ref a:" Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Transportadora"                    Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Remetente"                         Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(005) Say "Destinatário"                      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(114),C(005) Say "Notas Fiscais do Conhecimento"     Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(165),C(005) Say "Valores do Frete"                  Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(203),C(005) Say "Valor Total do Conhecimento"       Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(136) Say "Série"                             Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(154) Say "Número"                            Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(189) Say "Modelo"                            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
   @ C(111),C(005) GET oMemo1 Var cMemo1 MEMO Size C(203),C(001) PIXEL OF oDlg
   @ C(047),C(005) GET oMemo2 Var cMemo2 MEMO Size C(203),C(001) PIXEL OF oDlg
   @ C(023),C(005) GET oMemo3 Var cMemo3 MEMO Size C(203),C(001) PIXEL OF oDlg

   @ C(035),C(005) CheckBox oCheckBox1 Var lEntrada   Prompt "Entrada" Size C(029),C(008) PIXEL OF oDlg When lChumba
   @ C(035),C(043) CheckBox oCheckBox2 Var lSaida     Prompt "Saída"   Size C(025),C(008) PIXEL OF oDlg When lChumba

   @ C(010),C(005) MsGet oGet9  Var xChave     Size C(203),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( BSCXML() )

   @ C(035),C(136) MsGet oGet6  Var cSerie     Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(035),C(154) MsGet oGet7  Var cNumero    Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(035),C(189) MsGet oGet8  Var cModelo    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(059),C(005) MsGet oGet10 Var cCodTransp Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(059),C(031) MsGet oGet2  Var cTranspo   Size C(177),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(079),C(005) MsGet oGet11 Var cCodFor    Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(079),C(031) MsGet oGet13 Var cLojFor    Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(079),C(049) MsGet oGet3  Var cRemetente Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(098),C(005) MsGet oGet12 Var cCodCli    Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(098),C(031) MsGet oGet14 Var cLojCli    Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(098),C(049) MsGet oGet4  Var cDestino   Size C(159),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(212),C(005) MsGet oGet5  Var cValFrete  Size C(056),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.99" PIXEL OF oDlg When lChumba

   @ C(209),C(082) Button "Legenda"  Size C(037),C(012) PIXEL OF oDlg ACTION( LEGXMLCT() )
   @ C(209),C(130) Button "Confirma" Size C(037),C(012) PIXEL OF oDlg ACTION( CMFXMLCT() ) When lAbre
   @ C(209),C(171) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Cria Grid para mostrar as notas fiscais que foram lidas
   aAdd( aNotas, { "1", "", "", "" })
   @ 155,005 LISTBOX oNotas FIELDS HEADER "LG", "Nota Fiscal", "Série", "Chave" PIXEL SIZE 260,055 OF oDlg ;
                            ON dblClick(aNotas[oNotas:nAt,1] := !aNotas[oNotas:nAt,1],oNotas:Refresh())     

   oNotas:SetArray( aNotas )
   oNotas:bLine := {||{ If(Alltrim(aNotas[oNotas:nAt,01]) == "1", oBranco  ,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "2", oVerde   ,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "3", oPink    ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "4", oAmarelo ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "5", oAzul    ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "6", oLaranja ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "7", oPreto   ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "8", oVermelho,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                        aNotas[oNotas:nAt,02]               ,;
                        aNotas[oNotas:nAt,03]               ,;
                        aNotas[oNotas:nAt,04]}}

   // Cria o List com os Valores do Frete do Conhecimento de Transporte
   aAdd( aFrete, { "","","","","","","","" })
   @ 221,005 LISTBOX oFrete FIELDS HEADER "Frete Peso", "Frete Valor", "Pedágio" ,"GRIS", "TRT", "Outros", "TAS", "TOTAL" PIXEL SIZE 259,033 OF oDlg ;
                            ON dblClick(aFrete[oFrete:nAt,1] := !aFrete[oFrete:nAt,1],oFrete:Refresh())     

   oFrete:SetArray( aFrete )
   oFrete:bLine := {||     {aFrete[oFrete:nAt,01],;
             		    	aFrete[oFrete:nAt,02],;
         	         	    aFrete[oFrete:nAt,03],;
         	         	    aFrete[oFrete:nAt,04],;
         	         	    aFrete[oFrete:nAt,05],;
         	         	    aFrete[oFrete:nAt,06],;
         	         	    aFrete[oFrete:nAt,07],;
         	        	    aFrete[oFrete:nAt,08]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que busca o XML pela chave informada
Static Function BSCXML()

   Local aFiles  := {}
   Local aSizes  := {}
   Local nX
   Local lExiste := .F.

// ADir("S:\ADMINISTRATIVO\NFE\XML\MAIO2014\*.*", aFiles, aSizes)
   ADir("S:\ADMINISTRATIVO\NFE\XML\ARQUIVOS_XML\*.*", aFiles, aSizes)

   // Exibe dados dos arquivos
   nCount  := Len( aFiles )
   lExiste := .F.
   For nX := 1 to nCount
       If U_P_OCCURS(Alltrim(aFiles[nX]), Alltrim(xChave), 1) <> 0
//        cArquivo := "S:\ADMINISTRATIVO\NFE\XML\MAIO2014\" + Alltrim(aFiles[nX])
          cArquivo := "S:\ADMINISTRATIVO\NFE\XML\ARQUIVOS_XML\" + Alltrim(aFiles[nX])
          lExiste  := .T.
          Exit
       Endif
   Next nX       

   If !lExiste 
      cArquivo := Space(150)
      oGet9:Refresh()
      MsgAlert("XML não localizado. Verifique!")
   Else
      IMPARQFRETE()
      oNotas:Refresh()
      oFrete:Refresh()
   Endif

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function ARQFRETE()

   cArquivo := cGetFile('*.xml', "Selecione o arquivo de Conhecimento de Transporte a ser importado",1,"",.F.,16,.F.)

Return .T. 

// Função que limpa os dados da tela para nova pesquisa/importação
Static Function LIMARQFRETE()

   cArquivo   := Space(150)
   cTranspo   := Space(100)
   cRemetente := Space(100)
   cDestino   := Space(100)
   cValFrete  := 0
   cSerie     := ""
   cNumero    := ""
   cModelo    := ""
   xChave     := Space(150)
   cCNPJT     := Space(14)
   cCodTransp := Space(06)
   cCGCFor    := Space(14)
   cCodFor    := Space(06)
   cLojFor    := Space(03)
   cCGCDest   := Space(14)
   cCodCli    := Space(06)
   cLojCli    := Space(03)
   cdataCTE   := Ctod("  /  /    ")

   oGet3:Refresh()
   oGet4:Refresh()
   oGet5:Refresh()
   oGet6:Refresh()
   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()
   oGet11:Refresh()
   oGet12:Refresh()
   oGet13:Refresh()
   oGet14:Refresh()

   lEntrada := .F.
   lSaida   := .F.
   lFecha   := .F.  
   
   oCheckBox1:Refresh()
   oCheckBox2:Refresh()

   aListBox1 := {}
   aNotas    := {}
   aFrete    := {}

   aAdd( aNotas, { "1", "", "", "", "" })

   oNotas:SetArray( aNotas )
   oNotas:bLine := {||{ If(Alltrim(aNotas[oNotas:nAt,01]) == "1", oBranco  ,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "2", oVerde   ,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "3", oPink    ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "4", oAmarelo ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "5", oAzul    ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "6", oLaranja ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "7", oPreto   ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "8", oVermelho,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                        aNotas[oNotas:nAt,02]               ,;
                        aNotas[oNotas:nAt,03]               ,;
                        aNotas[oNotas:nAt,04]}}

   // Cria o List com os Valores do Frete do Conhecimento de Transporte
   aAdd( aFrete, { "","","","","","","","" })

   oFrete:SetArray( aFrete )
   oFrete:bLine := {||     {aFrete[oFrete:nAt,01],;
             		    	aFrete[oFrete:nAt,02],;
         	         	    aFrete[oFrete:nAt,03],;
         	         	    aFrete[oFrete:nAt,04],;
         	         	    aFrete[oFrete:nAt,05],;
         	         	    aFrete[oFrete:nAt,06],;
         	         	    aFrete[oFrete:nAt,07],;
         	        	    aFrete[oFrete:nAt,08]}}

Return(.T.)         	        	    

// Função que abre a janela da legenda das notas fiscais
Static Function LEGXMLCT()

   Private oDlgx

   DEFINE MSDIALOG oDlgx TITLE "Novo Formulário" FROM C(178),C(181) TO C(297),C(541) PIXEL

   @ C(006),C(020) Say "Nota Fiscal de Entrada/Saída localizada na Base de Dados"     Size C(144),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(017),C(020) Say "Nota Fiscal de Entrada/Saída não localizada na Base de Dados" Size C(154),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(028),C(020) Say "CT-e já pago. Verifique Contas a Pagar."                      Size C(109),C(008) COLOR CLR_BLACK PIXEL OF oDlgx

   @ C(005),C(005) Jpeg FILE "br_verde"    Size C(009),C(010) PIXEL NOBORDER OF oDlgx
   @ C(016),C(005) Jpeg FILE "br_vermelho" Size C(009),C(010) PIXEL NOBORDER OF oDlgx
   @ C(027),C(005) Jpeg FILE "br_amarelo"  Size C(009),C(010) PIXEL NOBORDER OF oDlgx

   @ C(041),C(067) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgx ACTION( oDlgx:End() )

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Função que realiza a importação do conhecimento de transporte selecionado
Static Function IMPARQFRETE()

   Local nContar    := 0
   Local cAgravar   := ""
   Local cConteudo  := ""
   Local aBrowse    := {}
   Local nQuantos   := 0
   Local cLegenda   := ""
   Local nBruto     := 0
   Local cChave     := ""
   Local cSerie     := ""
   Local cNumero    := ""
   Local cModelo    := ""

   // Realiza a consistência dos dados antes da importação
   If Empty(Alltrim(cArquivo))
      Msgalert("Arquivo XML para importação inexistente.")
      REturn(.T.)
   Endif

   // Limpa o Array das notas fiscais importadas
   aNotas := {}
   aAdd( aNotas, { '1','','','', '' } )

   // Abre o arquivo informado do conhecimento de transporte para importação
   nHandle := FOPEN(Alltrim(cArquivo), FO_READWRITE + FO_SHARED)
     
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

       If Substr(xBuffer, nContar, 1) <> ">"
 
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
                
       Else

          cAgravar := ""

          For nLimpa = 1 to Len(cConteudo)
          
              If Substr(cConteudo, nLimpa, 2) == "</"
                 Exit
              Else   
                 cAgravar := cAgravar + Substr(cConteudo, nLimpa, 1)
              Endif

          Next nLimpa

          aAdd(aBrowse, { cAgravar } )

          cConteudo := ""

       Endif

   Next nContar    

   // Verifica se XML lido é um XML de Conhecimento de Transprote
   If Len(aBrowse) == 0
      MsgAlert("Atenção! Importação com problema. Processo abortado.")
      Return(.T.)
   Endif
      
   If Upper(Alltrim(aBrowse[3,1])) <> "<CTE"
      MsgAlert("Atenção! XML informado não é um XML de Conhecimento de Transporte. Verifique!")
      Return(.T.)
   Endif
   
   // Pesquisa a data do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,06) == '<dhEmi'
          nContar  := nContar + 1              
          cDataCTE := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        
   
   cdataCTE := Ctod(Substr(cDataCTE,09,02) + "/ " + Substr(cDataCTE,06,02) + "/ " + Substr(cDataCTE,01,04))

   // Pesquisa o nome da Transportadora
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<emit'
          nContar  := nContar + 2                  
          cCNPJT   := aBrowse[nContar,01]
          nContar  := nContar + 4                  
          cTranspo := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o código da transportadora
   If Select("T_TRANSPO") > 0
      T_TRANSPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A4_COD"
   cSql += "  FROM " + RetSqlName("SA4")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A4_CGC LIKE '" + Substr(cCNPJT,01,08) + "%'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPO", .T., .T. )

   If T_TRANSPO->( EOF() )
      cCodTransp := ""
   Else   
      cCodTransp := T_TRANSPO->A4_COD
   Endif   

   // Pesquisa a Chave do Conhecimento de Frete
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,11) == '<infCte Id='
          cChave := Substr(aBrowse[nContar,01],13,47)
          Exit
       Endif
   Next nContar        

   // Pesquisa a Série do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<serie'
          nContar := nContar + 1                   
          cSerie  := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa a Número do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<nCT'
          nContar := nContar + 1                   
          cNumero := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o Modelo do Conhecimento de Transporte
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<mod'
          nContar := nContar + 1                   
          cModelo := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o nome do Remetente
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<rem'  
          nContar    := nContar + 2
          cCGCFor    := aBrowse[nContar,01]
          nContar    := nContar + 4
          cRemetente := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o código do Fornecedor
   If Select("T_FORNECEDOR") > 0
      T_FORNECEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD ,"
   cSql += "       A2_LOJA "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A2_CGC = '" + Alltrim(cCGCFor) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FORNECEDOR", .T., .T. )

   If T_FORNECEDOR->( EOF() )
      cCodFor := Space(06)
      cLojFor := Space(03)
   Else   
      cCodFor := T_FORNECEDOR->A2_COD
      cLojFor := T_FORNECEDOR->A2_LOJA
   Endif   

   // Pesquisa o nome do Destinatário
   For nContar = 1 to Len(aBrowse)
       If Substr(aBrowse[nContar,01],01,07) == '<dest'
          nContar  := nContar + 2                   
          cCGCDest := aBrowse[nContar,01]
          nContar  := nContar + 4                   
          cDestino := aBrowse[nContar,01]
          Exit
       Endif
   Next nContar        

   // Pesquisa o código do Destinatário
   If Select("T_DESTINO") > 0
      T_DESTINO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += "   AND A1_CGC = '" + Alltrim(cCGCDest) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESTINO", .T., .T. )

   If T_DESTINO->( EOF() )
      cCodCli := Space(06)
      cLojCli := Space(03)
   Else   
      cCodCli := T_DESTINO->A1_COD
      cLojCli := T_DESTINO->A1_LOJA
   Endif   

   // Verifica o tipo de conhecimento. Se ref. a notas fiscais de entrada ou ref. a notas fiscais de saída
   If cCGCFor$("03385913000161#03385913000242#03385913000404#0338591300059512757071000112")

      lEntrada := .F.
      lSaida   := .T.

      Do Case
         Case cCGCFor == "03385913000161"
              __Filial := "01"
         Case cCGCFor == "03385913000242"
              __Filail := "02"
         Case cCGCFor == "03385913000404"
              __Filail := "03"
         Case cCGCFor == "03385913000595"
              __Filail := "04"
         Case cCGCFor == "12757071000112"
              __Filail := "01"
      EndCase
      
   Endif   
   
   If cCGCDest$("03385913000161#03385913000242#03385913000404#0338591300059512757071000112")

      lEntrada := .T.
      lSaida   := .F.

      Do Case
         Case cCGCFor == "03385913000161"
              __Filial := "01"
         Case cCGCFor == "03385913000242"
              __Filail := "02"
         Case cCGCFor == "03385913000404"
              __Filail := "03"
         Case cCGCFor == "03385913000595"
              __Filail := "04"
         Case cCGCFor == "12757071000112"
              __Filail := "01"
      EndCase

   Endif   

   // Pesquisa as notas fiscais do Conhecimento de Transporte
   aNotas     := {}
   nAcumulado := 0

   For nContar = 1 to Len(aBrowse)

       If Substr(aBrowse[nContar,01],01,07) == '<infNFe'

          nContar  := nContar + 2                   
          
          // Pesquisa a legenda da nota fiscal
          If Select("T_TABELA") > 0
             T_TABELA->( dbCloseArea() )
          EndIf

          If lEntrada == .T.
             cSql := ""                               
             cSql := "SELECT F1_FILIAL ,"
             cSql += "       F1_DOC    ,"
             cSql += "       F1_SERIE  ,"
             cSql += "       F1_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF1")
             cSql += " WHERE F1_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Else
             cSql := ""                               
             cSql := "SELECT F2_FILIAL ,"
             cSql += "       F2_DOC    ,"
             cSql += "       F2_SERIE  ,"
             cSql += "       F2_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF2")
             cSql += " WHERE F2_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Endif             

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELA", .T., .T. )
             
          If T_TABELA->( EOF() )
             cLegenda := "8"
             kFilial  := ""
          Else

             // Verifica se CT-e já foi pago. Se foi, recebe o Status 4 (Amarelo)
             T_TABELA->( dbGoTop() )

             If lEntrada
                KFilial := T_TABELA->F1_FILIAL
             Endif
                
             If lSaida
                KFilial := T_TABELA->F2_FILIAL
             Endif

             If Select("T_JAPAGO") > 0
                T_JAPAGO->( dbCloseArea() )
             EndIf

             cSql := ""              
             cSql := "SELECT ZS9_CFIS,"
             cSql += "       ZS9_FATU "
             cSql += "  FROM " + RetSqlName("ZS9")
             cSql += " WHERE ZS9_CFIS   = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
                
             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAPAGO", .T., .T. )

             If T_JAPAGO->( EOF() )
                cLegenda := "2"
             Else
                If Empty(Alltrim(T_JAPAGO->ZS9_FATU))
                   cLegenda := "2"
                Else
                   cLegenda := "4"                                                                               
                Endif
             Endif
             
          Endif

          // Pesquisa o Valor total da nota fiscal para cálculo da proporcionalidade do frete
          If Select("T_VLRBRUTO") > 0
             T_VLRBRUTO->( dbCloseArea() )
          EndIf

          If lEntrada == .T.
             cSql := ""                               
             cSql := "SELECT F1_FILIAL ,"
             cSql += "       F1_DOC    ,"
             cSql += "       F1_SERIE  ,"
             cSql += "       F1_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF1")
             cSql += " WHERE F1_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Else
             cSql := ""                               
             cSql := "SELECT F2_FILIAL ,"
             cSql += "       F2_DOC    ,"
             cSql += "       F2_SERIE  ,"
             cSql += "       F2_VALBRUT "
             cSql += "  FROM " + RetSqlName("SF2")
             cSql += " WHERE F2_CHVNFE = '" + Alltrim(aBrowse[nContar,01]) + "'"
             cSql += "   AND D_E_L_E_T_ = ''
          Endif             

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VLRBRUTO", .T., .T. )

          If T_VLRBRUTO->( EOF() )
             nBruto := 0
          Else
             nBruto := IIF(lEntrada == .T., T_VLRBRUTO->F1_VALBRUT, T_VLRBRUTO->F2_VALBRUT) 
          Endif

          nAcumulado := nAcumulado + nBruto

          // Carrega o Array aNotas
          aAdd( aNotas, { cLegenda                         ,; && 01 - Legenda
                          Substr(aBrowse[nContar,01],26,09),; && 02 - Nº da Nota Fiscal
                          Substr(aBrowse[nContar,01],23,03),; && 03 - Série da Nota Fiscal
                          aBrowse[nContar,01]              ,; && 04 - Chave
                          cLegenda                         ,; && 05 - Legenda
                          cChave                           ,; && 06 - Nº da Chave da Nta Fiscal
                          cSerie                           ,; && 07 - Série da Nota Fiscal
                          cNumero                          ,; && 08 - Nº do CT-e
                          cModelo                          ,; && 09 - Modelo do CT-e
                          kFilial                          ,; && 10 - Código da Filial da Nota Fiscal
                          nBruto                           ,; && 11 - Valor Bruto da Nota Fiscal
                          0                                }) && 12 - Total dos Documentos do CT-e
       Endif

   Next nContar        

   // Captura os valores do Frete
   aFrete := {}

   _Total_Frete := ""
   _Frete_Peso  := ""
   _Frete_Valor := ""                              
   _Pedagio     := ""
   _Gris        := ""
   _TRT         := ""
   _Outros      := ""
   _TAS         := ""

   // Captura dados do Frete lidos do Conhecimento de Frete
   For nContar = 1 to Len(aBrowse)

       // Captura o Valor Total do Frete
       If Substr(aBrowse[nContar,01],01,07) == '<vPrest'
          nContar      := nContar + 2                   
          _Total_Frete := aBrowse[nContar,01]
          Loop
       Endif
          
       // Captura o valor do Frete Peso
       If Upper(Alltrim(aBrowse[nContar,01])) == 'FRETE PESO'
          nContar := nContar + 2
          _Frete_Peso  := aBrowse[nContar,01]
          Loop
       Endif

       // Captura o valor do Frete Valor       
       If Upper(Alltrim(aBrowse[nContar,01])) == 'FRETE VALOR'          
          nContar      := nContar + 2
          _Frete_Valor := aBrowse[nContar,01]
          Loop
       Endif
       
       // Captura o valor do Pedágio
       If Upper(Alltrim(aBrowse[nContar,01])) == 'PEDAGIO'
          nContar      := nContar + 2
          _Pedagio    	 := aBrowse[nContar,01]
          Loop
       Endif
       
       // Captura o valor do GRIS
       If Upper(Alltrim(aBrowse[nContar,01])) == 'GRIS'
          nContar      := nContar + 2                   
          _Gris        := aBrowse[nContar,01]
          Loop
       Endif   

       // Captura o valor do TRT
       If Upper(Alltrim(aBrowse[nContar,01])) == 'TRT'
          nContar      := nContar + 2
          _TRT         := aBrowse[nContar,01]
          Loop
       Endif

       // Captura o valor do OUTROS
       If Upper(Alltrim(aBrowse[nContar,01])) == 'OUTROS'
          nContar      := nContar + 2
          _Outros      := aBrowse[nContar,01]
          Loop
       Endif

       // Captura o valor do TAS
       If Upper(Alltrim(aBrowse[nContar,01])) == 'TAS'
          nContar      := nContar + 2
          _TAS         := aBrowse[nContar,01]
          Loop
       Endif
          
       // Sai do laço de pesquisa
       If Alltrim(aBrowse[nContar,01]) == '</vPrest'
          Exit
       Endif   

   Next nContar        

   // Carrega a variável com o total do frete
   cValfrete := val(_Total_Frete)

   // Carrega array aFrete para display dos valores que compoem o valor total do frete
   aAdd( aFrete, { _Frete_Peso  ,;
                   _Frete_Valor ,;
                   _Pedagio     ,;
                   _Gris        ,;
                   _TRT         ,;
                   _Outros      ,;
                   _TAS         ,;
                   _Total_Frete })

   // Calcula o Valorte Proporcionalizado e atualia no array aNotas
   For nContar = 1 to Len(aNotas)
       aNotas[nContar,12] := Round(((cValFrete * Round((Round((aNotas[nContar,11] / nAcumulado),2) * 100),2)) / 100),2)
   Next nContar    

   // Variável lógica que controla os botões Nova Importação e Importação
   lFecha := .T.

   // Atualiza Notas Fiscais
   oNotas:SetArray( aNotas )
   oNotas:bLine := {||{ If(Alltrim(aNotas[oNotas:nAt,01]) == "1", oBranco  ,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "2", oVerde   ,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "3", oPink    ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "4", oAmarelo ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "5", oAzul    ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "6", oLaranja ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "7", oPreto   ,;                         
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "8", oVermelho,;
                        If(Alltrim(aNotas[oNotas:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                        aNotas[oNotas:nAt,02]               ,;
                        aNotas[oNotas:nAt,03]               ,;
                        aNotas[oNotas:nAt,04]}}

   // Atualiza Valores do Frete
   oFrete:SetArray( aFrete )
   oFrete:bLine := {||     {aFrete[oFrete:nAt,01],;
             		    	aFrete[oFrete:nAt,02],;
         	         	    aFrete[oFrete:nAt,03],;
         	         	    aFrete[oFrete:nAt,04],;
         	         	    aFrete[oFrete:nAt,05],;
         	         	    aFrete[oFrete:nAt,06],;
         	         	    aFrete[oFrete:nAt,07],;
         	        	    aFrete[oFrete:nAt,08]}}
   
   // Verifica se abre ou fecha o botão Confirmar
   If Select("T_ABRE") > 0
      T_ABRE->( dbCloseArea() )
   EndIf

   cSql := ""                               
   cSql := "SELECT ZS9_CHAV"
   cSql += "  FROM " + RetSqlName("ZS9")
   cSql += " WHERE ZS9_CHAV   = '" + Alltrim(xChave) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ABRE", .T., .T. )

   lAbre := IIF(T_ABRE->(EOF()), .T., .F.)

Return(.T.)

// Função que grava o valor do frete para as notas capturadas do arquivo XML
Static Function CMFXMLCT()

   Local cSql     := ""
   Local nContar  := 0
   Local _nErro   := 0
   Local tStatus  := "E"
   Local lPodeGrv := .T.
   Local aFreteN  := {}
   Local _nErro   := 0

   // Verifica se conhecimento já está gravado. 
   // Se não estiver, o inclui.
   // Se já estiver, deleta para nova gravação.
   If Select("T_JAEXISTE") > 0
      T_JAEXISTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS9_CHAV"
   cSql += "  FROM " + RetSqlName("ZS9")
   cSql += " WHERE ZS9_CHAV   = '" + Alltrim(xChave) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )

   If T_JAEXISTE->( EOF() )
      lJaGravado := .F.
   Else
      lJaGravado := .T.      
   Endif
      
   // Verifica o Status dos lançamentos se Aberto/Encerrado
   tStatus := "E"
   For nContar = 1 to Len(aNotas)
       If aNotas[nContar,01] <> "2"
          tStatus := "A"
          Exit
       Endif
   Next nContar       

   If tStatus <> "E"
      MsgAlert("CT-e não será gravado pois o mesmo possui inconsistências. Verifique!")
      Return(.T.)
   Endif

   // Grava os dados na tabela ZS9
   For nContar = 1 to Len(aNotas)

       // Atualiza a Tabela de CTE
       dbSelectArea("ZS9")
       RecLock("ZS9",.T.)
       ZS9_FILIAL := "  "

       If lEntrada
          ZS9_TIPO := "E"
       Endif
       
       If lSaida
          ZS9_TIPO := "S"
       Endif
          
       ZS9_DLEI   := Date()
       ZS9_HLEI   := Time()
       ZS9_ULEI   := cUserName
       ZS9_CHAV   := xChave
       ZS9_CTRA   := cCodTransp
       ZS9_SERI   := cSerie  
       ZS9_NUME   := cNumero 
       ZS9_MODE   := cModelo
       ZS9_CFOR   := cCodFor
       ZS9_LFOR   := cLojFor
       ZS9_CDES   := cCodCli
       ZS9_LDES   := cLojCli

       If lEntrada
          ZS9_NFIS   := ALLTRIM(STR(INT(VAL(aNotas[nContar,02]))))
          ZS9_SFIS   := ALLTRIM(STR(INT(VAL(aNotas[nContar,03]))))
       Else
          ZS9_NFIS   := Substr(aNotas[nContar,02],04,06)
          ZS9_SFIS   := ALLTRIM(STR(INT(VAL(aNotas[nContar,03]))))
       Endif

       ZS9_CFIS   := aNotas[nContar,04]
       ZS9_LEGE   := aNotas[nContar,01]
       ZS9_STAT   := tStatus
       ZS9_DATA   := cdataCTE
       ZS9_VFRE   := cValFrete
       ZS9_TNOT   := nAcumulado
       ZS9_FREN   := aNotas[nContar,12]
       ZS9_CGCR   := cCGCFor
       ZS9_CGCD   := cCgcDest
       ZS9_CGCT   := cCnpjt
       MsUnLock()

   Next nContar

   If tStatus == "A"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "A(s) nota(s) fiscal(is) deste CT-e estão inconsistentes. Verifique!")
      // Limpa tela para nova importação
      LIMARQFRETE()
      Return(.T.)
   Endif

   // Grava os dados
   For nContar = 1 to Len(aNotas)

       If lEntrada = .T.

          cSql := ""
          cSql := "UPDATE " + RetSqlName("SF1")
          cSql += "   SET"
          cSql += "   F1_SERF = '" + Alltrim(aNotas[nContar,07]) + "',"
          cSql += "   F1_NUMF = '" + Alltrim(aNotas[nContar,08]) + "',"
          cSql += "   F1_MODF = '" + Alltrim(aNotas[nContar,09]) + "',"
          cSql += "   F1_CHAF = '" + Alltrim(xChave)             + "',"
          cSql += "   F1_VALF =  " + Alltrim(str(aNotas[nContar,12],10,02))
          cSql += " WHERE F1_FILIAL = '" + Alltrim(aNotas[nContar,10]) + "'"
          cSql += "   AND F1_CHVNFE = '" + Alltrim(aNotas[nContar,04]) + "'"
             
          _nErro := TcSqlExec(cSql) 

          If TCSQLExec(cSql) < 0 
             alert(TCSQLERROR())
             Return(.T.)
          Endif

       Else

          cSql := ""
          cSql := "UPDATE " + RetSqlName("SF2")
          cSql += "   SET"
          cSql += "   F2_SERF = '" + Alltrim(aNotas[nContar,07]) + "',"
          cSql += "   F2_NUMF = '" + Alltrim(aNotas[nContar,08]) + "',"
          cSql += "   F2_MODF = '" + Alltrim(aNotas[nContar,09]) + "',"
          cSql += "   F2_CHAF = '" + Alltrim(xChave)             + "',"
          cSql += "   F2_VALF =  " + Alltrim(str(aNotas[nContar,12],10,02))
          cSql += " WHERE F2_FILIAL = '" + Alltrim(aNotas[nContar,10]) + "'"
          cSql += "   AND F2_CHVNFE = '" + Alltrim(aNotas[nContar,04]) + "'"
             
          _nErro := TcSqlExec(cSql) 

          If TCSQLExec(cSql) < 0 
             alert(TCSQLERROR())
             Return(.T.)
          Endif

       Endif   

       _nErro := TcSqlExec(cSql) 

       If TCSQLExec(cSql) < 0 
          alert(TCSQLERROR())
          Return(.T.)
       Endif

   Next nContar

   // Limpa tela para nova importação
   LIMARQFRETE()
       
Return(.T.)