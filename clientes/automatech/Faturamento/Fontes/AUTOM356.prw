#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM356.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 25/07/2016                                                          *
// Objetivo..: Porgrama que importa dados da tabeal de Natureza                    *
//**********************************************************************************

User Function AUTOM356()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local oMemo1
   
   Private cArquivo  := Space(250)
   Private oGet1

   Private aConsulta := {}

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Importação Cadastro de Naturezas" FROM C(178),C(181) TO C(336),C(655) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(231),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Arquivo CSV de naturezas a ser importado" Size C(143),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) MsGet oGet1 Var cArquivo Size C(213),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(047),C(221) Button "..."             Size C(011),C(009) PIXEL OF oDlg ACTION( BSCARQIMPO() )

   @ C(062),C(082) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPORTAARQ() )
   @ C(062),C(120) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do arquivo a ser importado
Static Function BSCARQIMPO()

   cArquivo := cGetFile('*.*', "Selecione o arquivo a ser importado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que importa o arquivo selecionado
Static Function IMPORTAARQ()
   MsgRun("Aguarde! Importando arquivo selecionado ...", "Importação de Arquivo CSV",{|| XIMPORTAARQ() })
Return(.T.)

// Função que importa o arquivo selecionado
Static Function XIMPORTAARQ()

   Local aImportado := {}
   Local cConteudo  := ""
   Local cString    := ""

   If Empty(Alltrim(cArquivo))
      MsgAlert("Arquivo a ser importado não selecionado.")
      Return .T.
   Endif

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cArquivo), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + ";"
          _Linha    := ""
          aAdd( aImportado,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Realiza a gravação dos registros
   nElementos := U_P_OCCURS(aImportado[1], ";", 1)

   cString := ""

   For nContar = 1 to Len(aImportado)

       For nAbreVar = 1 to nElementos
           j := Strzero(nAbreVar,5)
           cCnt&j := ""
       Next nAbreVar

       For nVezes = 1 to nElementos
           j := Strzero(nVezes,5)
           cCnt&j := U_P_CORTA(aImportado[nContar], ";", nVezes)
       Next nVezes       
        
       lPrimeiro := .T.
       cString   := ""

       For AbreArray = 1 to nElementos

           j := Strzero(AbreArray,5)

           If lPrimeiro == .T.        
              cString += "aAdd( aConsulta, { .T. ,"
              lPrimeiro := .F.                 
           Endif

           If AbreArray <> nElementos
              cString += "'" + cCnt&j + "'" + ","
           Else
              cString += "'" + cCnt&j + "'" + "})"
           Endif
           
       Next AbreArray          
       cResultado := &(cString) 

   Next nContar

   If Len(aConsulta) = 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não foi importado nenhum registro." + chr(13) + chr(10) + "Verifique Arquivo informado para importação.")
      Return .T.
   Endif

   // Atualiza a tabeal de naturezas conforme orientação do Paulo
   For nContar = 1 to Len(aConsulta)

       If Alltrim(aConsulta[nContar,02]) == ""
          Loop
       Endif

       If Alltrim(aConsulta[nContar,02]) == "SED"
          Loop
       Endif
          
       If Alltrim(Upper(aConsulta[nContar,02])) == "CODIGO"
          Loop
       Endif

   	   DbSelectArea("SED")
	   DbSetOrder(1)
	   If DbSeek(xFilial("SED") + aConsulta[nContar,02])

          RecLock("SED",.F.)

          // Conta Contábil
          ED_CONTA := aConsulta[nContar,15] 

          // Uso Natureza
          Do Case
             Case Alltrim(upper(aConsulta[nContar,29])) == "LIVRE"
                  ED_USO   := "0"
             Case Alltrim(upper(aConsulta[nContar,29])) == "CONTAS A RECEBER"
                  ED_USO   := "1"
             Case Alltrim(upper(aConsulta[nContar,29])) == "CONTAS A PAGAR"
                  ED_USO   := "2"
             Case Alltrim(upper(aConsulta[nContar,29])) == "3"
                  ED_USO   := "3"
             Otherwise
                  ED_USO   := "0"               
          EndCase
                            
          // Natureza Bloqueada
          Do Case
             Case Alltrim(upper(aConsulta[nContar,30])) == "BLOQUEADA"
                  ED_BLOQ  := "1"
             Case Alltrim(upper(aConsulta[nContar,30])) == "NÃO BLOQUEADA"
                  ED_BLOQ  := "2"
             Otherwise
                  ED_BLOQ  := "1"
          EndCase
                  
          // Tipo Natureza
          Do Case
             Case Alltrim(upper(aConsulta[nContar,37])) == "SINTETICO"
                  ED_TIPO  := "1"
             Case Alltrim(upper(aConsulta[nContar,37])) == "ANALITICO"
                  ED_TIPO  := "2"
          EndCase
                            
          // Condição Natureza
          Do Case
             Case Alltrim(upper(aConsulta[nContar,38])) == "RECEITA"
                  ED_COND  := "R"
             Case Alltrim(upper(aConsulta[nContar,38])) == "DESPESA"
                  ED_COND  := "D"
             Otherwise
                  ED_COND  := " "
          EndCase

          MsUnLock()

        Endif

   Next nContar

   Msgalert("Atualização realizada com sucesso.")
   
Return(.T.)