#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM147.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/01/2013                                                          *
// Objetivo..: Importação do Cadastro de Naturezas                                 *
//**********************************************************************************

User Function AUTOM147()

   Local lChumba     := .F.
   
   Private cCaminho  := Space(25)
   Private oCaminho

   Private oDlg

   Private nMeter1	 := 0
   Private oMeter1

   U_AUTOM628("AUTOM147")

   DEFINE MSDIALOG oDlg TITLE "Importação do Arquivo de Naturezas" FROM C(178),C(181) TO C(302),C(633) PIXEL

   @ C(005),C(005) Say "Arquivo a ser importado" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(209) Button "..."   Size C(012),C(010) PIXEL OF oDlg  ACTION(BUSCANAT())
   @ C(015),C(005) MsGet oCaminho Var cCaminho When lChumba Size C(203),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(005) METER oMeter1  VAR nMeter1               Size C(215),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(044),C(080) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPARQNAT( cCaminho ) )
   @ C(044),C(119) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do arquivo do TES a ser utilizado para importação
Static Function BUSCANAT()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Inventário",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que importa o invetário do TES
Static Function IMPARQNAT( _Caminho )

   Local lExiste   := .T.
   Local cConteudo := ""
   Local nContar   := 0
   Local nEndereco := 0
   Local cProduto  := ""
   Local cSerie    := ""
   Local nQuanti   := 0
   Local aNatureza := {}
   Local nSepara   := 0
   Local j         := ""

   Private lVolta    := .F.

   If Empty(Alltrim(_Caminho))
      MsgAlert("Arquivo de Naturezas a ser importado não informado.")
      Return .T.
   Endif

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(_Caminho), 0)

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
          
          cConteudo := cConteudo + "#"
          _Linha    := ""
          
          // Declara as variáveis para alimentar o array aNatureza
          For nSepara = 1 to U_P_OCCURS(cConteudo, "#", 1)
              _Linha := _Linha + Alltrim(U_P_CORTA(cConteudo, "#", nSepara)) + "|"
          Next nSepara              
          
          aAdd( aNatureza,  _Linha  )

          cConteudo := ""

          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    


   // Realiza a gravação dos registros
   For nContar = 1 to Len(aNatureza)
           
       _String := aNatureza[nContar]
   
       dbSelectArea("SED")
       RecLock("SED",.T.)

       ED_FILIAL   := ""
       ED_CODIGO   := Alltrim(U_P_CORTA(_String, "|", 1))
       ED_DESCRIC  := Alltrim(U_P_CORTA(_String, "|", 2))
       ED_CALCIRF  := "N"
       ED_CALCISS  := "N"
       ED_CALCINS  := "N"
       ED_CALCCSL  := "N"
       ED_CALCCOF  := "N"
       ED_CALCPIS  := "N"
       ED_DEPPIS   := "2"
       ED_DEDCOF   := "2"
       ED_BLOQ     := "2"
       ED_RINSSPA  := "2"

       MsUnLock()
       
   Next nContar        
   
   MsgAlert("Importação realizada com Sucesso.")

Return .T.