#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR87.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 06/03/2012                                                          *
// Objetivo..: Programa que realiza a importa��o do arquivo de invent�rio          *
//**********************************************************************************

//utiliza��o da fun��o DbTree
User Function AUTOMR87()

   Private aComboBx1 := {"  ", "01 - Porto Alegre", "02 - Caixas do Sul", "03 - Pelotas"}
   Private cComboBx1

   Private aComboBx2 := {}
   Private cComboBx2

   Private cCaminho   := Space(100)
   Private cDocumento := Space(10)
   Private cData	  := Ctod("  /  /    ")
   Private oGet1
   Private oGet2
   Private oGet3
   Private lChumba    := .F.
   Private aEndereco  := {}

   Private oDlg

   U_AUTOM628("AUTOMR87")

   // Carrega o combo dos endere�os
   If Select("T_ENDERECO") > 0
      T_ENDERECO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BE_LOCAL   ,"
   cSql += "       BE_LOCALIZ  "
   cSql += "  FROM " + RetSqlName("SBE")
   cSql += " WHERE BE_FILIAL    = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   cSql += " ORDER BY BE_LOCAL "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

   If T_ENDERECO->( EOF() )
      aAdd(aComboBx2, " " )
   Else
      aAdd(aComboBx2, "  " )
      T_ENDERECO->( DbGoTop() )
      WHILE !T_ENDERECO->( EOF() )
         aAdd(aComboBx2, T_ENDERECO->BE_LOCAL + " - " + T_ENDERECO->BE_LOCALIZ )
         T_ENDERECO->( DbSkip() )
      ENDDO
   ENDIF

   // Pesquisa o pr�ximo n� de documento para inclus�o
   If Select("T_NUMERO") > 0
      T_NUMERO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT MAX(CAST(B7_DOC AS int)) AS PROXIMO"
   cSql += "  FROM " + RetSqlName("SB7")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMERO", .T., .T. )

   If T_NUMERO->( EOF() )
      CDocumento := '1'
   Else   
      cDocumento := Alltrim(Str(T_NUMERO->PROXIMO + 1))
   Endif

   DEFINE MSDIALOG oDlg TITLE "Importa��o de Invent�rio" FROM C(178),C(181) TO C(320),C(582) PIXEL

   @ C(005),C(006) Say "Arquivo a ser Importado" Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(014),C(181) Button "..."                  Size C(012),C(009) PIXEL OF oDlg ACTION(BUSCAIMPOR())
   @ C(025),C(007) Say "Filial"                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(045),C(007) Say "Endere�o"                Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(062) Say "Data Invent�rio"         Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(007) Say "N� Documento"            Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(007) MsGet oGet1 Var cCaminho   When lChumba Size C(171),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(033),C(007) ComboBox cComboBx1 Items aComboBx1 Size C(187),C(010) PIXEL OF oDlg
// @ C(053),C(007) ComboBox cComboBx2 Items aComboBx2 Size C(187),C(010) PIXEL OF oDlg
   @ C(053),C(007) MsGet oGet2 Var cDocumento When lChumba Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(053),C(062) MsGet oGet3 Var cData      Size C(038),C(009) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg

   @ C(053),C(113) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION(IMPINVCOL( cCaminho, cComboBx1, cDocumento, cData, cComboBx2))
   @ C(053),C(155) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:END() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return .T.

// Fun��o que abre di�logo de pesquisa do arquivo de invet�rio a ser impotado
Static Function BUSCAIMPOR()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Invent�rio",1,"C:\",.F.,16,.F.)

Return .T. 

// Fun��o que importa o invet�rio do estoque
Static Function IMPINVCOL( _Caminho, _Filial, _Documento, _Data, _Endereco)

   Local lExiste     := .T.
   Local cConteudo   := ""
   Local nContar     := 0
   Local nEndereco   := 0
   Local cProduto    := ""
   Local cSerie      := ""
   Local nQuanti     := 0
   Local aInventario := {}

   Private lVolta    := .F.

   If Empty(Alltrim(_Caminho))
      MsgAlert("Arquivo de Inventario a ser importado n�o informado.")
      Return .T.
   Endif
   
   If Empty(Alltrim(_Filial))
      MsgAlert("Necess�rio informar Filial para importa��o.")
      Return .T.
   Endif
      
// If Empty(Alltrim(_Endereco))
//    MsgAlert("Endereco n�o selecionado.")
//    Return .T.
// Endif

   If Empty(Alltrim(_Documento))
      MsgAlert("N� Documento de Inventario n�o informado.")
      Return .T.
   Endif

   If Empty(_Data)
      MsgAlert("Data do Invent�rio n�o informada.")
      Return .T.
   Endif

   // Verifica se n� de documento j� utilizado para invet�rio
   If Select("T_EXISTE") > 0
      T_EXISTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B7_DOC "
   cSql += "  FROM " + RetSqlName("SB7")
   cSql += " WHERE B7_DOC     = '" + Alltrim(_Documento)            + "'"
   cSql += "   AND B7_FILIAL  = '" + Alltrim(Substr(_Filial,01,02)) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EXISTE", .T., .T. )
   
   If !T_EXISTE->( EOF() )
      MsgAlert("Documento informado j� utilizado. Verifique !")
      Return .T.
   Endif

   // Abre o arquivo de invent�rio especificado
   nHandle := FOPEN(Alltrim(_Caminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Invent�rio.")
      Return .T.
   Endif

   // L� o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // L� todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
                
       Else
                
          cProduto := Strzero(Int(Val(Substr(cConteudo,01,50))),6)
          cSerie   := Substr(cConteudo,051,50)
          nQuanti  := Int(Val(SubStr(cConteudo,101,10)))
          lAchou   := .F.

          aAdd( aInventario, { cProduto, cSerie, nQuanti } )

          cConteudo := ""
          cProduto  := ""
          cSerie    := ""
          nQuanti   := 0

          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    

   // Verifica se existem produtos a serem inclu�dos
   If Len(aInventariio) == 0
      MsgAlert("N�o existem dados a serem importados. Verifique o arquivo selecionado!")
      Return .T.
   Endif
      
   // Verifica se encontra o endere�o do produto/n�mero de s�rie lido.
   // Se n�o achar, carrega array aEndereco para posterior visualiza��o.
 
   aEndereco := {}

   For nContar = 1 to Len(aInventario)

       If Empty(Alltrim(aInventario[nContar,02]))
          Loop
       Endif   

       If Select("T_ENDERECO") > 0
          T_ENDERECO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT BF_FILIAL ,"
       cSql += "       BF_PRODUTO,"
       cSql += "       BF_NUMSERI  "
       cSql += "  FROM " + RetSqlName("SBF")
       cSql += " WHERE BF_FILIAL  = '" + Alltrim(Substr(_Filial,01,02))   + "'"
       cSql += "   AND BF_PRODUTO = '" + Alltrim(aInventario[nContar,01]) + "'"
       cSql += "   AND BF_NUMSERI = '" + Alltrim(aInventario[nContar,02]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

       If T_ENDERECO->( EOF() )

          If Select("T_PRODUTO") > 0
             T_PRODUTO->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT B1_DESC "
          cSql += "  FROM " + RetSqlName("SB1")
          cSql += " WHERE B1_COD = '" + Alltrim(aInventario[nContar,01]) + "'"
   
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

          aAdd( aEndereco, { Alltrim(aInventario[nContar,01]), Alltrim(T_PRODUTO->B1_DESC), Alltrim(aInventario[nContar,02]), '' } )
          
       Endif
       
   Next nContar       
          
   If Len(aEndereco) > 0

      // Envia para a rotina que abre a tela de corre��o dos Endere�os
      AbreEndereco(Alltrim(Substr(_Filial,01,02)))
  
      If lVolta
         Return .T.
      Endif

      // Verifica se existe endere�os n�o informados para proseguir
      lExiste := .T.
      For nContar = 1 to Len(aEndereco)
          If Empty(Alltrim(aEndereco[nContar,04]))
             lExiste := .F.
             Exit
          Endif
      Next nContar
      
      If lExiste == .F.
         MsgAlert("Processo de grava��o n�o ser� conclu�do pois existem podutos com controle por n� de s�rie que est�o sem a informa��o de endere�o.")
         Return .T.
      Endif

   Endif

   For nContar = 1 to Len(aInventario)

       x_Endereco := ""

       // Pesquisa o Endere�o do produto/n� de s�rie lido
       If Select("T_ENDERECO") > 0
          T_ENDERECO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT BF_FILIAL ,"
       cSql += "       BF_PRODUTO,"
       cSql += "       BF_NUMSERI,"
       cSql += "       BF_LOCALIZ "
       cSql += "  FROM " + RetSqlName("SBF")
       cSql += " WHERE BF_FILIAL  = '" + Alltrim(Substr(_Filial,01,02))   + "'"
       cSql += "   AND BF_PRODUTO = '" + Alltrim(aInventario[nContar,01]) + "'"
       cSql += "   AND BF_NUMSERI = '" + Alltrim(aInventario[nContar,02]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

       If T_ENDERECO->( EOF() )
          // Localiza o Endere�o a ser utilizado para o Invent�rio
          For nEndereco = 1 to Len(aEndereco)
              If Alltrim(aEndereco[nEndereco,01]) == Alltrim(aInventario[nContar,01]) .and. ;
                 Alltrim(aEndereco[nEndereco,03]) == Alltrim(aInventario[nContar,02])
                 x_Endereco := aEndereco[nEndereco,04]
                 Exit
              Endif
          Next nEndereco       
       Else
          If Empty(Alltrim(T_ENDERECO->BF_LOCALIZ))
             // Localiza o Endere�o a ser utilizado para o Invent�rio
             For nEndereco = 1 to Len(aEndereco)
                 If Alltrim(aEndereco[nEndereco,01]) == Alltrim(aInventario[nContar,01]) .and. ;
                    Alltrim(aEndereco[nEndereco,03]) == Alltrim(aInventario[nContar,02])
                    x_Endereco := aEndereco[nEndereco,04]
                    Exit
                 Endif
             Next nEndereco       
          Else   
             x_Endereco := T_ENDERECO->BF_LOCALIZ
          Endif   
       Endif

       // Grava registro na Tabela SB7010
       dbSelectArea("SB7")
       RecLock("SB7",.T.)
       B7_FILIAL  := Substr(_Filial,01,02)
       B7_COD     := aInventario[nContar,01]
       B7_LOCAL   := "01"
       B7_TIPO    := "PA"
       B7_DOC     := _Documento
       B7_QUANT   := aInventario[nContar,03]
       B7_DATA    := _Data
       B7_DTVALID := _Data
       B7_NUMSERI := aInventario[nContar,02]
       If Empty(Alltrim(aInventario[nContar,02]))
       Else
          B7_LOCALIZ := x_ENDERECO
       Endif   
       MsUnLock()

   Next nContar

   MsgAlert("Importa��o do Invent�rio terminada com sucesso.")
   
   oDlg:End()

Return .T.

// Fun��o que abre a janela de solicita��o de endere�o por porduto/n� de s�rie
Static Function ABREENDERECO(xFilial)

   Local nContar   := 0
   Local aProdutos := {}
   Local lExiste   := .F.
   Local aComboBx1 := {}
   Local aComboBx2 := {}
   Local cComboBx1
   Local cComboBx2

   Private oDlgx

   // Carrega o combo de produtos a partir no array aEndereco
   For nContar = 1 to Len(aEndereco)
       
       lExiste := .F.
       
       For nExiste = 1 to Len(aComboBx1)
           If Alltrim(SubStr(aComboBx1[nExiste],01,06)) = Alltrim(aEndereco[nContar,01])
              lExiste := .T.
              Exit
           Endif
       Next nExiste
       
       If lExiste == .F.
          aAdd(aComboBx1, aEndereco[nContar,01] + " - " + Alltrim(aEndereco[nContar,02]))
       Endif
       
   Next nContar

   // Carrega o combo dos endere�os
   If Select("T_ENDERECO") > 0
      T_ENDERECO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BE_LOCAL   ,"
   cSql += "       BE_LOCALIZ  "
   cSql += "  FROM " + RetSqlName("SBE")
   cSql += " WHERE BE_FILIAL    = '" + Alltrim(xFilial) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   cSql += " ORDER BY BE_LOCAL "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

   If T_ENDERECO->( EOF() )
      aAdd(aComboBx2, " " )
   Else
      aAdd(aComboBx2, "  " )
      T_ENDERECO->( DbGoTop() )
      WHILE !T_ENDERECO->( EOF() )
         aAdd(aComboBx2, T_ENDERECO->BE_LOCAL + " - " + T_ENDERECO->BE_LOCALIZ )
         T_ENDERECO->( DbSkip() )
      ENDDO
   ENDIF

   DEFINE MSDIALOG oDlgx TITLE "Produtos/N� de S�ries sem localiza��o de Endere�o" FROM C(178),C(181) TO C(564),C(833) PIXEL

   @ C(003),C(004) Say "N�o foram encontrados os endere�os dos produtos abaixo relacionados." Size C(174),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(162),C(005) Say "Produto"  Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(177),C(005) Say "Endere�o" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgx

   @ C(161),C(032) ComboBox cComboBx1 Items aComboBx1 Size C(227),C(010) PIXEL OF oDlgx
   @ C(176),C(032) ComboBox cComboBx2 Items aComboBx2 Size C(227),C(010) PIXEL OF oDlgx

   @ C(160),C(263) Button "Individual"       Size C(027),C(012) PIXEL OF oDlgx ACTION( ALTENDE(cComboBx1, cComboBx2, 1))
   @ C(160),C(291) Button "Todos"            Size C(030),C(012) PIXEL OF oDlgx ACTION( ALTENDE(cComboBx1, cComboBx2, 2))
   @ C(176),C(263) Button "Continuar"        Size C(027),C(012) PIXEL OF oDlgx ACTION( lVolta := .F., oDlgx:End() )
   @ C(176),C(291) Button "Cancelar"         Size C(030),C(012) PIXEL OF oDlgx ACTION( lVolta := .T., oDlgx:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 012 , 005, 405, 185,,{'C�digo', 'Descri��o dos produtos', 'N� S�rie', 'Endere�o' },{20,50,50,50},oDlgx,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aEndereco) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aEndereco[oBrowse:nAt,01],;
                         aEndereco[oBrowse:nAt,02],;
                         aEndereco[oBrowse:nAt,03],;
                         aEndereco[oBrowse:nAt,04]} }

   ACTIVATE MSDIALOG oDlgx CENTERED 

Return(.T.)

// Fun��o que abre a janela de solicita��o de endere�o por porduto/n� de s�rie
Static Function ALTENDE(xProduto, xEndereco, _Tipo)

   Local nContar := 0
   
   If Empty(Alltrim(xProduto))
      MsgAlert("Necess�rio informar que produto dever� ter seu endere�o alterado.")
      Return .T.
   Endif
       
   If Empty(Alltrim(xEndereco))
      MsgAlert("Necess�rio informar o endere�o a ser utilizado para altera��o.")
      Return .T.
   Endif

   For nContar = 1 to Len(aEndereco)
       If _Tipo == 1
          If Alltrim(aEndereco[nContar,01]) == SubStr(xProduto,01,06)
             aEndereco[nContar,04] := SubStr(xEndereco,06)
          Endif
       Else
          aEndereco[nContar,04] := SubStr(xEndereco,06)          
       Endif   
   Next nContar
          
   // Seta vetor para a browse                            
   oBrowse:SetArray(aEndereco) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aEndereco[oBrowse:nAt,01],;
                         aEndereco[oBrowse:nAt,02],;
                         aEndereco[oBrowse:nAt,03],;
                         aEndereco[oBrowse:nAt,04]} }

Return .T.