#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "APWEBSRV.CH" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM108.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/04/2012                                                          *
// Objetivo..: Programa de importação de XML de Notas Fiscais de Entrada           *
// Parâmetros: _Ktipo - Indica a operação a ser realizada, sendo:                  *
//             P - Lançamento de Pré-Documento de Entrada                          *
//             N - Efetivação do Pré-Documento de Entrada                          *
//             xOperacao - Indica a operação I - Inclusão                          *
//                                           A - Alteração                         *
//                                           V - Visualização                      *
//                                           E - Exclusão - Inutilização           *
//             xNota       - Nº da Nota Fiscal                                     *
//             xSerie      - Série da Nota Fiscal                                  *
//             xFornecedor - Código do Fornecedor                                  *
//             xLoja       - Loja do Fornecedor                                    *
//             xControla   = Indica Chamado pela Controladoria                     *
//**********************************************************************************

User Function AUTOM108(_Ktipo, xOperacao, xNota, xSerie, xFornecedor, xLoja, xControla )

   Local lChumba      := .F.
   Local nContar      := 0
   Local aMes 	      := {"00-Todos", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"}
   Local aAno  	      := {}
   Local cMes
   Local cAno
   Local cMemo1	      := ""
   Local oMemo1
      
   Private lDeixaImp  := .F.
   Private cArquivo   := Space(250)
   Private oGet1
   
   Private cDisplay := ""
   Private oDisplay

   Private lTipoImp := 0
   
   // Declara as Legendas
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

   Private oDlgXML

   U_AUTOM628("AUTOM108")

   If xOperacao == "I"

      // ########################################################################
      // Envia para a função que pergunta o tipo de importação a ser realizada ##
      // ########################################################################
      lTipoImp := 0
      PEDETIPOIMP()

      If lTipoImp == 0
         Return(.T.)
      Endif

//    cArquivo := "41150482373077000171550020001318991015674554"
      cArquivo := Space(250)

      oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

      // Inicializa o array de Ano
      nAno := 2011
      For nContar = 1 to 50
          aAdd( aAno, Strzero(nAno,4) )
          nAno := nAno + 1
      Next nContar    

      cAno := Strzero(Year(Date()),4)

      DEFINE MSDIALOG oDlgXML TITLE "Importação XML - Documento de Entrada" FROM C(178),C(181) TO C(539),C(871) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgXML
      @ C(165),C(005) Jpeg FILE ""               Size C(009),C(009) PIXEL NOBORDER OF oDlgXML
      @ C(160),C(067) Jpeg FILE "br_vermelho"    Size C(009),C(009) PIXEL NOBORDER OF oDlgXML
      @ C(168),C(067) Jpeg FILE "br_verde"       Size C(009),C(009) PIXEL NOBORDER OF oDlgXML

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(335),C(001) PIXEL OF oDlgXML
  
      @ C(056),C(005) Say "Dados do XML"                               Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
      @ C(155),C(005) Say "Status do XML"                              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
      @ C(023),C(235) Say "IMPORTAÇÃO DE XML DE DOCUMENTOS DE ENTRADA" Size C(143),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
      @ C(159),C(080) Say "XML A SER IMPORTADO"                        Size C(066),C(008) COLOR CLR_RED   PIXEL OF oDlgXML
      @ C(169),C(080) Say "XML JÁ IMPORTADO"                           Size C(056),C(008) COLOR CLR_GREEN PIXEL OF oDlgXML
      @ C(034),C(005) Say "Mês"                                        Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
      @ C(034),C(039) Say "Ano"                                        Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
      @ C(034),C(077) Say "Chave NFe para pesquisa"                    Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgXML
 
      @ C(044),C(005) ComboBox cMes  Items aMes      Size C(031),C(010) PIXEL OF oDlgXML
      @ C(044),C(039) ComboBox cAno  Items aAno      Size C(035),C(010) PIXEL OF oDlgXML
      @ C(044),C(077) MsGet    oGet1 Var   cArquivo  Size C(247),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgXML
      @ C(041),C(328) Button   "..."                 Size C(012),C(012) PIXEL OF oDlgXML ACTION( BuscaArquivo(cMes, cAno, cArquivo) )

      @ C(065),C(005) GET oDisplay Var cDisplay MEMO Size C(335),C(087) PIXEL OF oDlgXML Font oFont01 When lChumba

      @ C(162),C(235) Button "Importar XML"          Size C(063),C(012) PIXEL OF oDlgXML ACTION( impxmlent(_Ktipo, cArquivo,xOperacao, xNota, xSerie, xFornecedor, xLoja, xControla ) ) When lDeixaImp
      @ C(162),C(303) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlgXML ACTION( oDlgXML:End() )

      ACTIVATE MSDIALOG oDlgXML CENTERED 
      
   Else

      impxmlent(_Ktipo, cArquivo, xOperacao, xNota, xSerie, xFornecedor, xLoja, xControla )

   Endif
   
Return(.T.)

// Função que verifica se o arquivo informado existe
Static Function BuscaArquivo(_Mes, _Ano, _Arquivo)

   Local cSql       := ""
   Local nContar    := 0
   Local nX         := 0
   Local cLocal     := "" && "S:\FINANCEIRO\NFE\XML\" + Alltrim(_Ano) + "\"
   Local nDocumento := IIF(Empty(Alltrim(_Arquivo)), "", Substr(_Arquivo,26,09))
   Local cXML       := ""
   Local aFiles     := {}
   Local aSizes     := {}
   Local cCaminho   := ""
   Local aBrowse    := {}
   Local cConteudo  := ""
   Local nVezes     := 0
   Local xChave     := _Arquivo

   // Se chave = branco, retorna
   If Empty(Alltrim(_Arquivo))
      Return(.T.)
   Endif

   // Verifica se a chave informada já está cadastrada no Sistema   
   If Select("T_JAEXISTE") <>  0
      T_JAEXISTE->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT F1_CHVNFE "
   cSql += "  FROM " + RetSqlName("SF1")
   cSql += " WHERE F1_CHVNFE  = '" + Alltrim(_arquivo) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

   If !T_JAEXISTE->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(13) + "Documento de entrada já cadastrado no Sistema." + chr(13) + "Utilize a opção de visualização.")
      Return(.T.)
   Endif

   // Calcula a quantidade de vezes para realizar o laço de pesquisa
   nVezes := IIF(Substr(_Mes,01,02) == "00", 12, 1)

   // Carrega os arquivos do diretório de XML's
   For nContar = 1 to nVezes

       If Substr(_Mes,01,02) == "00"
          Do Case
             Case nContar == 1
                  cPasta := "01-JANEIRO"
             Case nContar == 2
                  cPasta := "02-FEVEREIRO"
             Case nContar == 3
                  cPasta := "03-MARCO"
             Case nContar == 4
                  cPasta := "04-ABRIL"
             Case nContar == 5
                  cPasta := "05-MAIO"
             Case nContar == 6
                  cPasta := "06-JUNHO"
             Case nContar == 7
                  cPasta := "07-JULHO"
             Case nContar == 8
                  cPasta := "08-AGOSTO"
             Case nContar == 9
                  cPasta := "09-SETEMBRO"
             Case nContar == 10
                  cPasta := "10-OUTUBRO"
             Case nContar == 11
                  cPasta := "11-NOVEMBRO"
             Case nContar == 12
                  cPasta := "12-DEZEMBRO"
          EndCase
       Else
          Do Case
             Case _Mes == "01"
                  cPasta := "01-JANEIRO"
             Case _Mes == "02"
                  cPasta := "02-FEVEREIRO"
             Case _Mes == "03"
                  cPasta := "03-MARCO"
             Case _Mes == "04"
                  cPasta := "04-ABRIL"
             Case _Mes == "05"
                  cPasta := "05-MAIO"
             Case _Mes == "06"
                  cPasta := "06-JUNHO"
             Case _Mes == "07"
                  cPasta := "07-JULHO"
             Case _Mes == "08"
                  cPasta := "08-AGOSTO"
             Case _Mes == "09"
                  cPasta := "09-SETEMBRO"
             Case _Mes == "10"
                  cPasta := "10-OUTUBRO"
             Case _Mes == "11"
                  cPasta := "11-NOVEMBRO"
             Case _Mes == "12"
                  cPasta := "12-DEZEMBRO"
          EndCase
       Endif

       // Cria o array conteendo os arquivos XML para localização do arquivo informado
//       ADir(Alltrim(cLocal + cPasta + "\") + "*.*", aFiles, aSizes)
       cCaminho := "S:\Operacoes\Financeiro\NFE\XML\2018\"

       ADir(Alltrim(cCaminho) + "*.*", aFiles, aSizes)

       // Carrega o array aArquivos para display no List
       nRegua := 0
       nCount := Len( aFiles )
       cXML   := ""

       For nX := 1 to nCount
           If U_P_OCCURS(UPPER(aFiles[nX]), nDocumento, 1) <> 0
              cXML := aFiles[nX]
              Exit
           Endif
       Next nX              

       // Se cXML for vazio, continua o processamento
       If Len(Alltrim(cXML)) == 0
          Loop
       Else
          Exit
       Endif

   Next nContar

   If Empty(Alltrim(cXML))                                                      
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Chave do arquivo informado não localizado." + chr(13) + chr(10) + "Verifique!")
      Return(.T.)
   Endif
   
   // Cria o caminho de pesquisa
// cCaminho := "S:\FINANCEIRO\NFE\XML\" + Alltrim(_Ano) + "\" + Alltrim(cPasta) + "\" + Alltrim(cXML)
   cCaminho := Alltrim(cCaminho) + Alltrim(cXML)

   // Carrega a variável cArquivo para poder realizar a importação do arquivo xml
   cArquivo := cCaminho                                          
   oGet1:Refresh()
  
   // Abre o arquivo selecionado para pesquisa de dados
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
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
   
   // Prapara Variável para display dos dados para seem conferidos antes da Importação
   // --------------------------------------------------------------------------------
   cDisplay := ""

   // Pesquisa o CNPJ do Fornecedor para pesquisa
   For nContar = 1 to Len(aBrowse)
       
       If Alltrim(Upper(aBrowse[nContar,01])) <> "<CNPJ"
          Loop
       Else
          _CNPJ := aBrowse[nContar + 1,01]
          Exit
       Endif
       
   Next nContar
   
   // Pesquisa o Fornecedor no Banco do Protheus
   If Select("T_FORNECE") <>  0
      T_FORNECE->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD   ,"
   cSql += "       A2_LOJA  ,"
   cSql += "       A2_NOME  ,"
   cSql += "       A2_END   ,"
   cSql += "       A2_BAIRRO,"
   cSql += "       A2_EST   ,"
   cSql += "       A2_MUN   ,"
   cSql += "       A2_CEP    "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_CGC = '" + Alltrim(_CNPJ) + "'"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FORNECE",.T.,.T.)

   cFornece := T_FORNECE->A2_COD
   cLoja    := T_FORNECE->A2_LOJA

   cDisplay := cDisplay + "RAZÃO SOCIAL: " + Alltrim(T_FORNECE->A2_NOME)   + Chr(13) + CHR(10)
   cDisplay := cDisplay + "ENDEREÇO....: " + Alltrim(T_FORNECE->A2_END)    + Chr(13) + CHR(10)
   cDisplay := cDisplay + "BAIRRO......: " + Alltrim(T_FORNECE->A2_BAIRRO) + Chr(13) + CHR(10)
   cDisplay := cDisplay + "CEP.........: " + Substr(T_FORNECE->A2_CEP,01,02) + "." + Substr(T_FORNECE->A2_CEP,03,03) + "-" + Substr(T_FORNECE->A2_CEP,06,03) + Chr(13) + CHR(10)
   cDisplay := cDisplay + "MUNICÍPIO...: " + Alltrim(T_FORNECE->A2_MUN)    + Chr(13) + CHR(10)
   cDisplay := cDisplay + "ESTADO......: " + Alltrim(T_FORNECE->A2_EST)    + Chr(13) + CHR(10)
   cDisplay := cDisplay + "CNPJ........: " + Substr(_CNPJ,01,02) + "." + ;
                                             Substr(_CNPJ,03,03) + "." + ;
                                             Substr(_CNPJ,06,03) + "/" + ;
                                             Substr(_CNPJ,09,04) + "-" + ;
                                             Substr(_CNPJ,13,02) + Chr(13) + Chr(13) + CHR(10)

   // Pesquisa o nº da Nota Fiscal   
   For nContar = 1 to Len(aBrowse)
       If Alltrim(aBrowse[nContar,01]) <> "<nNF"
          Loop
       Else
          cNota := aBrowse[nContar + 1,01]
          Exit
       Endif
   Next nContar

   cDisplay := cDisplay + "NOTA FISCAL.: " + Alltrim(cNota) + Chr(13) + CHR(10)
   
   // Pesquisa o nº da Série da Nota Fiscal   
   For nContar = 1 to Len(aBrowse)
       If Alltrim(aBrowse[nContar,01]) <> "<serie"
          Loop
       Else
          cSerie := aBrowse[nContar + 1,01]
          Exit
       Endif
   Next nContar

   cDisplay := cDisplay + "SERIE.......: " + Alltrim(cSerie) + Chr(13) + CHR(10)

   // Verifica se documento já foi importado como pré-documento
   If Select("T_JAEXISTE") <>  0
      T_JAEXISTE->(DbCloseArea())
   EndIf
   
   cSql := "SELECT ZT8_NOTA,"
   cSql += "       ZT8_SERI,"
   cSql += "       ZT8_CHAV "
   cSql += "  FROM " + RetSqlName("ZT8")
   cSql += " WHERE ZT8_CHAV   = '" + Alltrim(xChave) + "'" 
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

   If !T_JAEXISTE->( EOF() )
      @ C(165),C(005) Jpeg FILE "br_verde"      Size C(009),C(009)                 PIXEL NOBORDER OF oDlgXML
      lDeixaImp := .F.
      Return .T.
   Else
      @ C(165),C(005) Jpeg FILE "br_vermelho"   Size C(009),C(009)                 PIXEL NOBORDER OF oDlgXML
      lDeixaImp := .T.
   Endif

Return(.T.)   

// Função que grava o produto do vínculo de produto x fornecedor
Static Function impxmlent(_Ktipo, _cCaminho, xOperacao, xNota, xSerie, xFornecedor, xLoja, xControla )

   Local lChumba      := .F.
   Local lEditar      := IIF(_Ktipo == "P", .F., .T.)
   Local nContar      := 0
   Local cMensagem    := ""

   Private lTudoOK    := .T.
   Private xBotaoSel  := 0

   Private aProdutos  := {}
   Private aFaturas   := {}

   Private cNota	  := Space(10)
   Private cSerie	  := Space(03)
   Private cMoeda     := 1
   Private cEmissao	  := Ctod("  /  /    ")
   Private cEspecie   := "SPED"
   Private cUFOrigem  := Space(02)
   Private cCaminho   := _cCaminho
   Private cFornece   := Space(06)
   Private cNfornece  := Space(60)
   Private cNProduto  := Space(60)
   Private cLoja	  := Space(03)
   Private cTexto     := ""
   Private _Danfe     := ""
   Private cCusto     := Space(100)
   Private aCustos    := {}

   Private nBaseICMS  := 0
   Private nVlrICMS   := 0
   Private nBICMST    := 0
   Private nVICMST    := 0
   Private nVlrIPI    := 0
   Private nTotPro    := 0

   Private nVlrFrete  := 0
   Private nVlrSeguro := 0
   Private nVlrDescon := 0
   Private nVlrOutras := 0
   Private nVlrTotal  := 0

   Private oGet1
   Private oGet2
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
   Private oGet15      
   Private oGet16      
   Private oGet17      
   Private oGet18      
   Private oGet19      

   Private oMemo1

   Private cCondicao := Space(03)
   Private cNatureza := Space(10)
   Private cNome_Con := Space(100)
   Private cNome_Nat := Space(100)

   Private oCondicao
   Private oNatureza
   Private oNome_Con
   Private oNome_Nat

   Private nTotal_Fat := 0

   Private oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   Private oDlg

   If xOperacao == "C"
      lEditar := .T.
   Endif

   // Em caso de Inclusão
   If xOperacao == "I"

      aAdd( aProdutos, { '','','','','','','',0,0,'','','','','','','','','','','','  ','' } )

      aFaturas := {}

      // Envia para a função que carrega os dados do XML informado
      ImpNFXml(cCaminho, 1)

      // ###########################################################################################
      // Verifica se existem produtos que não foram localizados pedidos de compras na importação. ##
      // Se existir pelo menos um produto sem pedido de compra, a importação não será finalizada. ##
      // ###########################################################################################
      cMensagem := ""
      For nContar = 1 to Len(aProdutos)

          If lTipoImp == 1
             If Len(aProdutos[nContar,15]) == 0
                cMensagem := cMensagem + "Produto: " + aProdutos[nContar,02] + " - " + aProdutos[nContar,03] + chr(13) + chr(10)
                cmensagem := cMensagem + "Pedido de Compra não localizado/selecionado para este produto."    + chr(13) + chr(10) + chr(13) + chr(10)
             Endif
          Else

             If Len(aProdutos[nContar,15]) == 0 
                
                If Empty(Alltrim(aProdutos[nContar,15]))
                Else
                   cMensagem := cMensagem + "Produto: " + aProdutos[nContar,02] + " - " + aProdutos[nContar,03] + chr(13) + chr(10)
                   cmensagem := cMensagem + "Não foi relacionado ao código de produto do Sistema."              + chr(13) + chr(10) + chr(13) + chr(10)
                Endif   
             Endif
             
          Endif
             
      Next nContar

      If !Empty(Alltrim(cMensagem))
         MsgAlert(cMensagem)
         Return(.T.)       
      Endif
      
   Else
   
      If Select("T_DADOSXML") <>  0
         T_DADOSXML->(DbCloseArea())
      EndIf

      cSql := "SELECT ZT8.ZT8_FILIAL,"
      cSql += "       ZT8.ZT8_ARQU  ,"
      cSql += "       ZT8.ZT8_NOTA  ,"
      cSql += "       ZT8.ZT8_SERI  ,"
      cSql += "       ZT8.ZT8_EMIS  ,"
      cSql += "       ZT8.ZT8_ESTA  ,"
      cSql += "       ZT8.ZT8_ESPE  ,"
      cSql += "       ZT8.ZT8_FORN  ,"
      cSql += "       ZT8.ZT8_LOJA  ,"
      cSql += "       ZT8.ZT8_USUA  ,"
      cSql += "       ZT8.ZT8_DATA  ,"
      cSql += "       ZT8.ZT8_HORA  ,"
      cSql += "       ZT8.ZT8_BICM  ,"
      cSql += "       ZT8.ZT8_VICM  ,"
      cSql += "       ZT8.ZT8_BIST  ,"
      cSql += "       ZT8.ZT8_VIST  ,"
      cSql += "       ZT8.ZT8_VIPI  ,"
      cSql += "       ZT8.ZT8_VPRO  ,"
      cSql += "       ZT8.ZT8_FRET  ,"
      cSql += "       ZT8.ZT8_SEGU  ,"
      cSql += "       ZT8.ZT8_DESC  ,"
      cSql += "       ZT8.ZT8_DESP  ,"
      cSql += "       ZT8.ZT8_TOTA  ,"
      cSql += "       ZT8.ZT8_STAT  ,"
      cSql += "       ZT8.ZT8_CHAV  ,"
      cSql += "       ZT8.ZT8_CUST  ,"
      cSql += "       ZT8.ZT8_COND  ,"
      cSql += "       ZT8.ZT8_NATU  ,"
      cSql += "       ZT8.ZT8_TIMP  ,"
      cSql += "       SA2.A2_NOME   ,"
      cSql += "       SA2.A2_END    ,"
      cSql += "       SA2.A2_BAIRRO ,"
      cSql += "       SA2.A2_CEP    ,"
      cSql += "       SA2.A2_MUN    ,"
      cSql += "       SA2.A2_EST    ,"
      cSql += "       SA2.A2_CGC     "
      cSql += "  FROM " + RetSqlName("ZT8") + " ZT8, "
      cSql += "       " + RetSqlName("SA2") + " SA2  "
      cSql += " WHERE ZT8.ZT8_NOTA = '" + Alltrim(xNota)       + "'"
      cSql += "   AND ZT8.ZT8_SERI = '" + Alltrim(xSerie)      + "'"
      cSql += "   AND ZT8.ZT8_FORN = '" + Alltrim(xFornecedor) + "'"
      cSql += "   AND ZT8.ZT8_LOJA = '" + Alltrim(xLoja)       + "'"
      cSql += "   AND ZT8.ZT8_FORN = SA2.A2_COD "
      cSql += "   AND ZT8.ZT8_LOJA = SA2.A2_LOJA"
      
      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DADOSXML",.T.,.T.)

      If T_DADOSXML->( EOF() )   
         MsgAlert("Não existem dados a serem visualizados para este documento.")
         Return(.T.)
      Endif
         
      _Danfe      := T_DADOSXML->ZT8_CHAV
      cCaminho    := T_DADOSXML->ZT8_ARQU
      cFornece    := T_DADOSXML->ZT8_FORN
      cLoja       := T_DADOSXML->ZT8_LOJA
      cNota       := T_DADOSXML->ZT8_NOTA
      cSerie      := T_DADOSXML->ZT8_SERI
      cEmissao    := Ctod(Substr(T_DADOSXML->ZT8_EMIS,07,02) + "/" + ;
                          Substr(T_DADOSXML->ZT8_EMIS,05,02) + "/" + ;
                          Substr(T_DADOSXML->ZT8_EMIS,01,04))
      cEspecie    := T_DADOSXML->ZT8_ESPE
      cUFOrigem   := T_DADOSXML->ZT8_ESTA
      nBaseICMS   := T_DADOSXML->ZT8_BICM
      nVlrICMS    := T_DADOSXML->ZT8_VICM
      nBICMST     := T_DADOSXML->ZT8_BIST
      nVICMST     := T_DADOSXML->ZT8_VIST
      nVlrIPI     := T_DADOSXML->ZT8_VIPI
      nTotPro     := T_DADOSXML->ZT8_VPRO
      nVlrFrete   := T_DADOSXML->ZT8_FRET
      nVlrSeguro  := T_DADOSXML->ZT8_SEGU
      nVlrDescon  := T_DADOSXML->ZT8_DESC
      nVlrOutras  := T_DADOSXML->ZT8_DESP
      nVlrTotal   := T_DADOSXML->ZT8_TOTA
      cCondicao   := T_DADOSXML->ZT8_COND
      cNatureza   := T_DADOSXML->ZT8_NATU
      lTipoImp    := T_DADOSXML->ZT8_TIMP

      cTexto      := cTexto + "RAZÃO SOCIAL: " + Alltrim(T_DADOSXML->A2_NOME)     + Chr(13) + chr(10)
      cTexto      := cTexto + "ENDEREÇO....: " + Alltrim(T_DADOSXML->A2_END)      + Chr(13) + chr(10)
      cTexto      := cTexto + "BAIRRO......: " + Alltrim(T_DADOSXML->A2_BAIRRO)   + Chr(13) + chr(10)
      cTexto      := cTexto + "CEP.........: " + Substr(T_DADOSXML->A2_CEP,01,02) + "." + Substr(T_DADOSXML->A2_CEP,03,03) + "-" + Substr(T_DADOSXML->A2_CEP,06,03) + Chr(13) + chr(10)
      cTexto      := cTexto + "MUNICÍPIO...: " + Alltrim(T_DADOSXML->A2_MUN)      + Chr(13) + chr(10)
      cTexto      := cTexto + "ESTADO......: " + Alltrim(T_DADOSXML->A2_EST)      + Chr(13) + chr(10)
      cTexto      := cTexto + "CNPJ........: " + Substr(T_DADOSXML->A2_CGC,01,02) + "." + ;
                                                 Substr(T_DADOSXML->A2_CGC,03,03) + "." + ;
                                                 Substr(T_DADOSXML->A2_CGC,06,03) + "/" + ;
                                                 Substr(T_DADOSXML->A2_CGC,09,04) + "-" + ;
                                                 Substr(T_DADOSXML->A2_CGC,13,02) + Chr(13) + Chr(10) + Chr(13) + chr(10)
      // Carrega o array aCusto
      aCustos := {}
      For nContar = 1 to U_P_OCCURS(T_DADOSXML->ZT8_CUST, "#", 1)
          __CentroC := U_P_CORTA(T_DADOSXML->ZT8_CUST, "#", nContar)
          aAdd( aCustos, { VAL(U_P_CORTA(__CentroC, "|", 1)) ,;
                               U_P_CORTA(__CentroC, "|", 2)  ,;
                               U_P_CORTA(__CentroC, "|", 3)  })
      Next nContar

      // Carrega o grid de produtos
      If Select("T_MATERIAL") <>  0
         T_MATERIAL->(DbCloseArea())
      EndIf

      cSql := "SELECT ZT9.ZT9_FILIAL,"
      cSql += "       ZT9.ZT9_ITEM  ,"
      cSql += "       ZT9.ZT9_CODI  ,"
      cSql += "       SB1.B1_DESC   ,"
      cSql += "       SB1.B1_UM     ,"
      cSql += "       SB1.B1_POSIPI ,"
      cSql += "       ZT9.ZT9_QUAN  ,"
      cSql += "       ZT9.ZT9_PREC  ,"
      cSql += "       ZT9.ZT9_TOTA  ,"
      cSql += "       ZT9.ZT9_BICM  ,"
      cSql += "       ZT9.ZT9_PICM  ,"
      cSql += "       ZT9.ZT9_VICM  ,"
      cSql += "       ZT9.ZT9_BIPI  ,"
      cSql += "       ZT9.ZT9_PIPI  ,"
      cSql += "       ZT9.ZT9_VIPI  ,"
      cSql += "       ZT9.ZT9_PCOM  ,"
      cSql += "       ZT9.ZT9_IPCO  ,"
      cSql += "       ZT9.ZT9_TES   ,"
      cSql += "       ZT9.ZT9_CFOP  ,"
      cSql += "       ZT9.ZT9_BIST  ,"
      cSql += "       ZT9.ZT9_PIST  ,"
      cSql += "       ZT9.ZT9_VIST  ,"
      cSql += "       ZT9.ZT9_LOCA  ,"
      cSql += "       ZT9.ZT9_NOTA  ,"
      cSql += "       ZT9.ZT9_SERI  ,"
      cSql += "       ZT9.ZT9_FORN  ," 
      cSql += "       ZT9.ZT9_LOJA  ,"
      cSql += "       ZT9.ZT9_TOPE   "
      cSql += "  FROM " + RetSqlName("ZT9") + " ZT9, " 
      cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE ZT9.ZT9_NOTA   = '" + Alltrim(xNota)       + "'"
      cSql += "   AND ZT9.ZT9_SERI   = '" + Alltrim(xSerie)      + "'"
      cSql += "   AND ZT9.ZT9_FORN   = '" + Alltrim(xFornecedor) + "'"
      cSql += "   AND ZT9.ZT9_LOJA   = '" + Alltrim(xLoja)       + "'"
      cSql += "   AND ZT9.ZT9_CODI   = SB1.B1_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"
 
      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAL",.T.,.T.)

      If T_MATERIAL->( EOF() )

         aAdd( aProdutos, { '','','','','','','',0,0,'','','','','','','','','','','','  ','' } )

         aFaturas := {}
         
      Else

         aProdutos := {}

         T_MATERIAL->( DbGoTop() )
         
         WHILE !T_MATERIAL->( EOF() )

            aAdd( aProdutos, { T_MATERIAL->ZT9_ITEM ,; // 01
                               T_MATERIAL->ZT9_CODI ,; // 02
                               T_MATERIAL->B1_DESC  ,; // 03
                               T_MATERIAL->B1_POSIPI,; // 04
                               T_MATERIAL->B1_UM    ,; // 05
                               T_MATERIAL->ZT9_QUAN ,; // 06
                               T_MATERIAL->ZT9_PREC ,; // 07
                               T_MATERIAL->ZT9_TOTA ,; // 08
                               T_MATERIAL->ZT9_BICM ,; // 09
                               T_MATERIAL->ZT9_PICM ,; // 10
                               T_MATERIAL->ZT9_VICM ,; // 11
                               T_MATERIAL->ZT9_BIPI ,; // 12
                               T_MATERIAL->ZT9_PIPI ,; // 13
                               T_MATERIAL->ZT9_VIPI ,; // 14
                               T_MATERIAL->ZT9_PCOM ,; // 15
                               T_MATERIAL->ZT9_IPCO ,; // 16
                               T_MATERIAL->ZT9_TES  ,; // 17
                               T_MATERIAL->ZT9_CFOP ,; // 18
                               T_MATERIAL->ZT9_BIST ,; // 19
                               T_MATERIAL->ZT9_PIST ,; // 20
                               T_MATERIAL->ZT9_VIST ,; // 21
                               T_MATERIAL->ZT9_TOPE ,; // 22   && ZT9_LOCA
                               ''                  } ) // 23

            T_MATERIAL->( DbSkip() )
            
         ENDDO
         
      Endif
   
      // Carrega o array aFaturas
      If Select("T_DUPLICATA") <>  0
         T_DUPLICATA->(DbCloseArea())
      EndIf

      cSql := ""
      cSql := "SELECT ZTA_FILIAL," 
      cSql += "       ZTA_NOTA  ,"
      cSql += "       ZTA_SERI  ,"
      cSql += "       ZTA_FORN  ,"
      cSql += "       ZTA_LOJA  ,"
      cSql += "       ZTA_CHAV  ,"
      cSql += "       ZTA_DUPL  ,"
      cSql += "       ZTA_VENC  ,"
      cSql += "       ZTA_VALOR  "
      cSql += "  FROM " + RetSqlName("ZTA")
      cSql += " WHERE ZTA_FILIAL = '" + Alltrim(cFilAnt)     + "'"
      cSql += "   AND ZTA_NOTA   = '" + Alltrim(xNota)       + "'"
      cSql += "   AND ZTA_SERI   = '" + Alltrim(xSerie)      + "'"
      cSql += "   AND ZTA_FORN   = '" + Alltrim(xFornecedor) + "'"
      cSql += "   AND ZTA_LOJA   = '" + Alltrim(xLoja)       + "'"

      cSql := ChangeQuery(cSql)
      DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DUPLICATA",.T.,.T.)

      If T_DUPLICATA->( EOF() )

         aAdd( aFaturas, { '','',0 } )

      Else

         aFaturas   := {}
         nParcelas  := 0
         nTotal_Fat := 0

         T_DUPLICATA->( DbGoTop() )
         
         WHILE !T_DUPLICATA->( EOF() )
            nParcelas  += 1
            nTotal_Fat := nTotal_Fat + T_DUPLICATA->ZTA_VALOR
            aAdd( aFaturas, { T_DUPLICATA->ZTA_DUPL                             ,;
                              Ctod(Substr(T_DUPLICATA->ZTA_VENC,07,02) + "/" +   ;
                                   Substr(T_DUPLICATA->ZTA_VENC,05,02) + "/" +   ;
                                   Substr(T_DUPLICATA->ZTA_VENC,01,04))         ,;
                              T_DUPLICATA->ZTA_VALOR }) 
            T_DUPLICATA->( DbSkip() )
         ENDDO

      Endif

   Endif

   // Desenha a tela
   DEFINE MSDIALOG oDlg TITLE "Importação de XML - NF Entrada" FROM C(178),C(181) TO C(600),C(967) PIXEL

   @ C(001),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(024) PIXEL NOBORDER OF oDlg

   @ C(003),C(125) Say "Arquivo XML"    Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Fornecedor"     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(309) Say "Nº N.Fiscal"    Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(353) Say "Data Emissão"   Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(309) Say "Série"          Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(331) Say "UF Org"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(049),C(353) Say "Espécie"        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(169),C(006) Say "Base ICMS"      Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(060) Say "Valor ICMS"     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(117) Say "Base ICMS ST"   Size C(041),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(170) Say "Valor ICMS ST"  Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(226) Say "Valor IPI"      Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(281) Say "Total Produtos" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(005) Say "Frete"          Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(061) Say "Valor Seguro"   Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(116) Say "Descontos"      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(171) Say "Outras Desp."   Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(282) Say "Total NF"       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   If xOperacao == "V" .Or. xOperacao == "E"
//    @ C(012),C(080) MsGet oGet6 Var cCaminho    Size C(224),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(012),C(125) MsGet oGet6 Var cCaminho    Size C(177),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba

      @ C(036),C(005) MsGet oGet7 Var cFornece    Size C(023),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(036),C(030) MsGet oGet8 Var cLoja       Size C(015),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(036),C(049) GET oMemo1  Var cTexto MEMO Size C(255),C(033) Font oFont01                            PIXEL OF oDlg When lChumba
      @ C(036),C(309) MsGet oGet1 Var cNota       Size C(039),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(058),C(309) MsGet oGet2 Var cSerie      Size C(017),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(036),C(353) MsGet oGet3 Var cEmissao    Size C(035),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(058),C(353) MsGet oGet4 Var cEspecie    Size C(035),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(058),C(331) MsGet oGet5 Var cUFOrigem   Size C(017),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
      @ C(177),C(005) MsGet oGet9  Var nBaseICMS  Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(177),C(060) MsGet oGet10 Var nVlrICMS   Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(177),C(116) MsGet oGet11 Var nBICMST    Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(177),C(171) MsGet oGet12 Var nVICMST    Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(177),C(226) MsGet oGet13 Var nVlrIPI    Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(177),C(282) MsGet oGet14 Var nTotPro    Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(196),C(005) MsGet oGet15 Var nVlrFrete  Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(196),C(060) MsGet oGet16 Var nVlrSeguro Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(196),C(116) MsGet oGet17 Var nVlrDescon Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(196),C(171) MsGet oGet18 Var nVlrOutras Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba
      @ C(196),C(282) MsGet oGet19 Var nVlrTotal  Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg When lChumba

      @ C(171),C(334) Button "Detalhe Produto" Size C(052),C(008) PIXEL OF oDlg ACTION ( ALTERAPROD(_Ktipo, xOperacao, xControla ) )                         
      @ C(181),C(334) Button "C.Pgtº/Natureza" Size C(052),C(008) PIXEL OF oDlg ACTION ( ABRECONDI() )                   When lEditar When lChumba
      @ C(026),C(251) Button "DANFE"           Size C(052),C(008) PIXEL OF oDlg ACTION ( MOSTRADANFE() )                              
      @ C(190),C(334) Button "Rateio C.Custo"  Size C(052),C(008) PIXEL OF oDlg ACTION ( ABRCCUSTO() )                   When lEditar When lChumba
      @ C(190),C(226) Button "Cálculo ICMS ST" Size C(047),C(008) PIXEL OF oDlg ACTION ( VarCalIST() )          When lChumba   &&       When lEditar When lChumba

      @ C(200),C(226) Button "2ª Moeda"        Size C(047),C(008) PIXEL OF oDlg ACTION ( VeSegMoeda() )                  When lEditar When lChumba
//    @ C(200),C(226) Button "2ª Moeda"        Size C(047),C(008) PIXEL OF oDlg ACTION ( PesqSefaz( _Danfe ) )

      If xOperacao == "V"
         @ C(201),C(334) Button "Salvar"          Size C(052),C(008) PIXEL OF oDlg ACTION ( SALVADANFE(_Ktipo, xOperacao, xControla) )              When lChumba
      Else
         @ C(201),C(334) Button "Excluir"         Size C(052),C(008) PIXEL OF oDlg ACTION ( SALVADANFE(_Ktipo, xOperacao, xControla) )
      Endif            

      @ C(010),C(309) Button "Importar"        Size C(037),C(012) PIXEL OF oDlg ACTION ( ImpNFXml(cCaminho, 2) )                      When lChumba
      @ C(010),C(351) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   Else

//    @ C(012),C(080) MsGet oGet6 Var cCaminho When lChumba Size C(224),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg
      @ C(012),C(125) MsGet oGet6 Var cCaminho When lChumba Size C(177),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg

      @ C(036),C(005) MsGet oGet7 Var cFornece    When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(030) MsGet oGet8 Var cLoja       When lChumba Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(049) GET oMemo1  Var cTexto MEMO When lChumba Size C(255),C(033) Font oFont01                 PIXEL OF oDlg
      @ C(036),C(309) MsGet oGet1 Var cNota       When lChumba Size C(039),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(058),C(309) MsGet oGet2 Var cSerie      When lChumba Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(036),C(353) MsGet oGet3 Var cEmissao    When lChumba Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(058),C(353) MsGet oGet4 Var cEspecie    When lChumba Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(058),C(331) MsGet oGet5 Var cUFOrigem   When lChumba Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
  
      @ C(177),C(005) MsGet oGet9  Var nBaseICMS  When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(177),C(060) MsGet oGet10 Var nVlrICMS   When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(177),C(116) MsGet oGet11 Var nBICMST    When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(177),C(171) MsGet oGet12 Var nVICMST    When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(177),C(226) MsGet oGet13 Var nVlrIPI    When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(177),C(282) MsGet oGet14 Var nTotPro    When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg

      @ C(196),C(005) MsGet oGet15 Var nVlrFrete  When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(196),C(060) MsGet oGet16 Var nVlrSeguro When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(196),C(116) MsGet oGet17 Var nVlrDescon When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(196),C(171) MsGet oGet18 Var nVlrOutras When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg
      @ C(196),C(282) MsGet oGet19 Var nVlrTotal  When lChumba Size C(047),C(009) COLOR CLR_BLACK Picture "@E 999,999.99" PIXEL OF oDlg

      @ C(171),C(334) Button "Detalhe Produto" Size C(052),C(008) PIXEL OF oDlg ACTION ( ALTERAPROD(_Ktipo, xOperacao, xControla) )
      @ C(181),C(334) Button "C.Pgtº/Natureza" Size C(052),C(008) PIXEL OF oDlg ACTION ( ABRECONDI() )   When lEditar
      @ C(026),C(251) Button "DANFE"           Size C(052),C(008) PIXEL OF oDlg ACTION ( MOSTRADANFE() )
      @ C(191),C(334) Button "Rateio C.Custo"  Size C(052),C(008) PIXEL OF oDlg ACTION ( ABRCCUSTO() )  When lChumba    && When lEditar
      @ C(190),C(226) Button "Cálculo ICMS ST" Size C(047),C(008) PIXEL OF oDlg ACTION ( VarCalIST() )   When lEditar

      @ C(200),C(226) Button "2ª Moeda"        Size C(047),C(008) PIXEL OF oDlg ACTION ( VeSegMoeda() ) When lEditar When lChumba
//    @ C(200),C(226) Button "2ª Moeda"        Size C(047),C(008) PIXEL OF oDlg ACTION ( PesqSefaz( _Danfe ) )

      @ C(201),C(334) Button "Salvar"          Size C(052),C(008) PIXEL OF oDlg ACTION ( SALVADANFE(_Ktipo, xOperacao, xControla) )
         
      @ C(010),C(309) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION ( ImpNFXml(cCaminho, 2) ) When lChumba
      @ C(010),C(351) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )
      
   Endif   

   // Desenha o Browse
   oBrowse := TCBrowse():New( 095 , 005, 488, 120,,{'Item'                  ,; // 01 - Sequencia do Produto
                                                    'Codigo'                ,; // 02 - Código do Produto
                                                    'Descrição dos Produtos',; // 03 - Descrição do Produto
                                                    'NCM'                   ,; // 04 - Nº do NCM do Produto
                                                    'Und'                   ,; // 05 - Unidade de Medida do Produto
                                                    'Qtd'                   ,; // 06 - Quantidade do Produto
                                                    'Unitário'              ,; // 07 - Preço Unitário
                                                    'Total'                 ,; // 08 - Valor Total do Produto
                                                    'Base ICMS'             ,; // 09 - Base do ICMS
                                                    '% ICMS'                ,; // 10 - % do ICMS
                                                    'Valor ICMS'            ,; // 11 - Valor do ICMS
                                                    'Base IPI'              ,; // 12 - Base do IPI
                                                    '% IPI'                 ,; // 13 - % do IPI
                                                    'Valor IPI'             ,; // 14 - Valor do IPI
                                                    'P.Compra'              ,; // 15 - Nº do Pedido de Compra
                                                    'Item PC'               ,; // 16 - Sequencia do Produto do Pedido de Compra
                                                    'T.Entrada'             ,; // 17 - Tipo de Entrada (TES)
                                                    'C.Fiscal'              ,; // 18 - Classificação Fiscal do Produto
                                                    'Base ICMS ST'          ,; // 19 - Base do ICMS Substituição
                                                    '% ICMS ST'             ,; // 20 - % ICMS Substituição
                                                    'Valor ICMS ST'         ,; // 21 - Valor do ICMS Substituição
                                                    'Tp.Operação'            ; // 22 - Tipo de Operação
                                                    },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aProdutos) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aProdutos[oBrowse:nAt,01],;
                         aProdutos[oBrowse:nAt,02],;
                         aProdutos[oBrowse:nAt,03],;
                         aProdutos[oBrowse:nAt,04],;
                         aProdutos[oBrowse:nAt,05],;
                         aProdutos[oBrowse:nAt,06],;
                         aProdutos[oBrowse:nAt,07],;
                         aProdutos[oBrowse:nAt,08],;
                         aProdutos[oBrowse:nAt,09],;
                         aProdutos[oBrowse:nAt,10],;
                         aProdutos[oBrowse:nAt,11],;
                         aProdutos[oBrowse:nAt,12],;
                         aProdutos[oBrowse:nAt,13],;
                         aProdutos[oBrowse:nAt,14],;
                         aProdutos[oBrowse:nAt,15],;
                         aProdutos[oBrowse:nAt,16],;
                         aProdutos[oBrowse:nAt,17],;
                         aProdutos[oBrowse:nAt,18],;
                         aProdutos[oBrowse:nAt,19],;
                         aProdutos[oBrowse:nAt,20],;
                         aProdutos[oBrowse:nAt,21],;
                         aProdutos[oBrowse:nAt,22]} }

   ACTIVATE MSDIALOG oDlg CENTERED 
                     
Return .T.

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQXML()

   cCaminho := cGetFile('*.xml', "Selecione o Arquivo a ser importado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que le o arquivo XML especificado para importação
Static Function ImpNFXml( cCaminho, _xPorta)

   Local nLaco      := 0
   Local nContar    := 0 
   Local nLimpa     := 0
   Local cConteudo  := ""
   Local cAgravar   := ""
   Local aBrowse    := {}
   Local nItem      := 0
   Local nPosicao   := 0
   Local _Produto   := ""
   Local _Descricao := ""
   Local _NCM       := ""
   Local _Unidade   := ""
   Local _Quanti    := ""
   Local _Unitario  := 0
   Local _Total     := 0
   Local _BICMS     := ""
   Local _AICMS     := ""
   Local _VICMS     := ""
   Local _BICMSST   := ""
   Local _AICMSST   := ""
   Local _VICMSST   := ""
   Local _BIPI      := ""
   Local _AIPI      := ""
   Local _VIPI      := ""
   Local _CNPJ      := ""
   Local cMensagem1 := ""
   Local cMensagem2 := ""
   Local lPrimeiro  := .F.
   Local nParcelas  := 0
   Local cMensagem  := ""

   Private cIncPro   := .F.
   Private cProInc   := ""
   Private xx_Codigo := ""

   aProdutos := {}

   If Empty(Alltrim(cCaminho))
      If _xPorta == 1
      Else
         MsgAlert("Arquivo a ser importado não informado.")
      Endif   
      aprodutos := {}
      aAdd( aProdutos, { '','','','','','','',0,0,'','','','','','','','','','','','  ','' } )
      Return .T.
   Endif
          
   If !File(Alltrim(cCaminho))
      If _xPorta == 1
      Else
         MsgAlert("Arquivo informado inexistente. Verifique !!")
      Endif   
      aprodutos := {}
      aAdd( aProdutos, { '','','','','','','',0,0,'','','','','','','','','','','','  ','' } )
      Return .T.
   Endif
          
   // Abre o arquivo ser lido da Aprove e atualiza a coluna do Browse
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
      aprodutos := {}
      aAdd( aProdutos, { '','','','','','','',0,0,'','','','','','','','','','','','  ', '' } )
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
   
   // #########################
   // Pesquisa o nº da DANFE ##
   // #########################
   For nContar = 1 to Len(aBrowse)
       
       If Substr(aBrowse[nContar,01],01,07) == '<infNFe'
                                                                            
          _Danfe := STRTRAN(STRTRAN(U_P_CORTA(strtran(abrowse[ncontar,01]," ", "|") + "|", "|",3),'"', ""),"Id=NFe", "")    
          
          If Alltrim(_Danfe) == "versao=2.00" .Or. ;
             Alltrim(_Danfe) == "versao=3.10"
             _Danfe := STRTRAN(STRTRAN(U_P_CORTA(strtran(abrowse[ncontar,01]," ", "|") + "|", "|",2),'"', ""),"Id=NFe", "")              
          Endif   
          
          Exit
             
       Endif
       
   Next nContar        

   // ##############################################
   // Pesquisa o CNPJ do Fornecedor para pesquisa ##
   // ##############################################
   For nContar = 1 to Len(aBrowse)
       
       If Alltrim(Upper(aBrowse[nContar,01])) <> "<CNPJ"
          Loop
       Else
          _CNPJ := aBrowse[nContar + 1,01]
          Exit
       Endif
       
   Next nContar
   
   // Pesquisa o Fornecedor no Banco do Protheus
   If Select("T_FORNECE") <>  0
      T_FORNECE->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD   ,"
   cSql += "       A2_LOJA  ,"
   cSql += "       A2_NOME  ,"
   cSql += "       A2_END   ,"
   cSql += "       A2_BAIRRO,"
   cSql += "       A2_EST   ,"
   cSql += "       A2_MUN   ,"
   cSql += "       A2_CEP    "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_CGC = '" + Alltrim(_CNPJ) + "'"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_FORNECE",.T.,.T.)

   cFornece  := T_FORNECE->A2_COD
   cLoja     := T_FORNECE->A2_LOJA
   cNfornece := T_FORNECE->A2_NOME

   cTexto   := ""
   cTexto   := cTexto + Alltrim(T_FORNECE->A2_NOME)   + CHR(13)
   cTexto   := cTexto + Alltrim(T_FORNECE->A2_END)    + CHR(13)
   ctexto   := cTexto + Alltrim(T_FORNECE->A2_BAIRRO) + CHR(13)   
   ctexto   := cTexto + Substr(T_FORNECE->A2_CEP,01,02) + "."   + ;
                        Substr(T_FORNECE->A2_CEP,03,03) + "-"   + ;
                        Substr(T_FORNECE->A2_CEP,06,03) + " - " + ;
                        Alltrim(T_FORNECE->A2_MUN) + "/"        + ;
                        Alltrim(T_FORNECE->A2_EST) + CHR(13)

   // ###############################
   // Pesquisa o nº da Nota Fiscal ##
   // ###############################  
   For nContar = 1 to Len(aBrowse)
       
       If Alltrim(aBrowse[nContar,01]) <> "<nNF"
          Loop
       Else
          cNota := aBrowse[nContar + 1,01]
          Exit
       Endif
       
   Next nContar
   
   // ########################################
   // Pesquisa o nº da Série da Nota Fiscal ##
   // ########################################  
   For nContar = 1 to Len(aBrowse)
       
       If Alltrim(aBrowse[nContar,01]) <> "<serie"
          Loop
       Else
          cSerie := aBrowse[nContar + 1,01]
          Exit
       Endif
       
   Next nContar

   // Pesquisa a Data de Emissão da da Nota Fiscal   
   For nContar = 1 to Len(aBrowse)
       
       If Alltrim(aBrowse[nContar,01]) <> "<dhEmi"
          Loop
       Else
          cEmissao := Ctod(Substr(aBrowse[nContar + 1,01],09,02) + "/" + Substr(aBrowse[nContar + 1,01],06,02) + "/" + Substr(aBrowse[nContar + 1,01],01,04))
          Exit
       Endif
       
   Next nContar

   // Verifica se nota fiscal já está cadastrada no sistema.
   If Select("T_JAEXISTE") <>  0
      T_JAEXISTE->(DbCloseArea())
   EndIf
   
   cSql := "SELECT F1_FILIAL ,"
   cSql += "       F1_DOC    ,"
   cSql += "       F1_SERIE  ,"
   cSql += "       F1_FORNECE,"
   cSql += "       F1_LOJA    "
   cSql += "  FROM " + RetSqlName("SF1")
   cSql += " WHERE F1_FILIAL    = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND F1_DOC       = '" + Alltrim(cNota)    + "'"
   cSql += "   AND F1_FORNECE   = '" + Alltrim(cFornece) + "'"
   cSql += "   AND F1_LOJA      = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

   If !T_JAEXISTE->( EOF() )

      If _xPorta == 1
      Else
         MsgAlert("Nota Fiscal deste XML já cadastrada no sistema." + CHR(13) + "Utilize a opção de consulta para visualização.")
      Endif

      // Limpa dados da tela para nova importação          
      aProdutos  := {}
      aFaturas   := {}

      aAdd( aProdutos, { '','','','','','','',0,0,'','','','','','','','','','','','  ','' } )
      aAdd( aFaturas , { '','',0 } )

      cNota	     := Space(10)
      cSerie	 := Space(03)
      cEmissao	 := Ctod("  /  /    ")
      cEspecie   := "SPED"
      cUFOrigem  := Space(02)
      cCaminho   := Space(150)
      cFornece   := Space(06)
      cLoja	     := Space(03)
      cNfornece  := Space(60)
      cnProduto  := Space(60)
      cTexto     := ""
      _Danfe     := ""

      nBaseICMS  := 0
      nVlrICMS   := 0
      nBICMST    := 0
      nVICMST    := 0
      nVlrIPI    := 0
      nTotPro    := 0

      nVlrFrete  := 0
      nVlrSeguro := 0
      nVlrDescon := 0
      nVlrOutras := 0
      nVlrTotal  := 0

      Return .T.
   Endif

   // Pesquisa o Estado de Origem
   For nContar = 1 to Len(aBrowse)

       If Alltrim(aBrowse[nContar,01]) <> "<UF"
          Loop
       Else
          cUFOrigem := aBrowse[nContar + 1,01]
          Exit
       Endif

   Next nContar

   // Pesquisa a Data de Emissão
   For nContar = 1 to Len(aBrowse)

       If Alltrim(aBrowse[nContar,01]) <> "<dEmi"
          Loop
       Else
          cEmissao := Ctod(Substr(aBrowse[nContar + 1,01],09,02) + "/" + ;
                           Substr(aBrowse[nContar + 1,01],06,02) + "/" + ;
                           Substr(aBrowse[nContar + 1,01],01,04))
          Exit
       Endif

   Next nContar

   // Captura os dados dos Produtos
   nPosicao := 0
   nItem    := 0

   For nContar = 1 to Len(aBrowse)

       If Alltrim(aBrowse[nContar,01]) == "<cProd"

          _Produto := aBrowse[nContar + 1,01]

       Endif

       If Alltrim(aBrowse[nContar,01]) == "<xProd"
          _Descricao := aBrowse[nContar + 1,01]

          // #####################################################################
          // Pesquisa o código do produto na tabela A5 (Produto X Fornecedores) ##
          // #####################################################################
          If Select("T_PRODUTO") <>  0
             T_PRODUTO->(DbCloseArea())
          EndIf
         
          cSql := ""
          cSql := "SELECT A.A5_FORNECE, "
          cSql += "       A.A5_LOJA   , "
          cSql += "       A.A5_PRODUTO, "  
          cSql += "       A.A5_NOMPROD, "
          cSql += "       A.A5_CODPRF , "
          cSql += "       B.B1_DESC   , "
          cSql += "       B.B1_DAUX     "
          cSql += "  FROM " + RetSqlName("SA5") + " A, "
          cSql += "       " + RetSqlName("SB1") + " B  "
          cSql += " WHERE A.A5_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
          cSql += "   AND A.A5_FORNECE = '" + Alltrim(cFornece) + "'"
          cSql += "   AND A.A5_LOJA    = '" + Alltrim(cLoja)    + "'"
          cSql += "   AND A.A5_CODPRF  = '" + Alltrim(_Produto) + "'"
          cSql += "   AND A.A5_PRODUTO = B.B1_COD"
          cSql += "   AND A.D_E_L_E_T_ = ''"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

          If T_PRODUTO->( EOF() )
             PROXFORNE( _produto, _Descricao)
          Else
             _Produto   := T_PRODUTO->A5_PRODUTO
             _Descricao := T_PRODUTO->A5_NOMPROD
          Endif   

       Endif

       If Alltrim(aBrowse[nContar,01]) == "<NCM"
          _NCM := aBrowse[nContar + 1,01]
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<uCom"
          _Unidade := aBrowse[nContar + 1,01]
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<qCom"
          _Quanti := aBrowse[nContar + 1,01]
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<vUnCom"
          _Unitario := val(aBrowse[nContar + 1,01])
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<vProd"
          _Total := Val(aBrowse[nContar + 1,01])
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<vICMS"
          _BICMS := aBrowse[nContar - 3,01]
          _AICMS := aBrowse[nContar - 1,01]
          _VICMS := aBrowse[nContar + 1,01]
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<vBCST"
          _BICMSST := aBrowse[nContar + 1,01]
          _AICMSST := aBrowse[nContar + 3,01]
          _VICMSST := aBrowse[nContar + 5,01]
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<vIPI"
          _BIPI := aBrowse[nContar - 3,01]
          _AIPI := aBrowse[nContar - 1,01]
          _VIPI := aBrowse[nContar + 1,01]
       Endif

       If Alltrim(aBrowse[nContar,01]) == "<ICMSTot"
          Exit
       Endif   

       If Substr(aBrowse[nContar,01],01,11) == "<det nItem="

          If nItem == 0
             nItem := nItem + 1
             Loop
          Else
             nItem := nItem + 1          
          Endif   

          // Pesquisa o código do produto na tabela A5 (Produto X Fornecedores)
          If Select("T_PRODUTO") <>  0
             T_PRODUTO->(DbCloseArea())
          EndIf
         
          cSql := ""
          cSql := "SELECT A.A5_FORNECE, "
          cSql += "       A.A5_LOJA   , "
          cSql += "       A.A5_PRODUTO, "
          cSql += "       A.A5_CODPRF , "
          cSql += "       B.B1_DESC   , "
          cSql += "       B.B1_DAUX     "
          cSql += "  FROM " + RetSqlName("SA5") + " A, "
          cSql += "       " + RetSqlName("SB1") + " B  "
          cSql += " WHERE A.A5_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
          cSql += "   AND A.A5_FORNECE = '" + Alltrim(cFornece) + "'"
          cSql += "   AND A.A5_LOJA    = '" + Alltrim(cLoja)    + "'"
          cSql += "   AND A.A5_CODPRF  = '" + Alltrim(_Produto) + "'"
          cSql += "   AND A.A5_PRODUTO = B.B1_COD"
          cSql += "   AND A.D_E_L_E_T_ = ''"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

          If T_PRODUTO->( EOF() )
             nPosicao += 1

//             aAdd( aProdutos, { Strzero(nPosicao,4)                    ,;
//                                _Produto                               ,;
//                                _Descricao                             ,;
//                                _NCM                                   ,;
//                                _Unidade                               ,;
//                                Padl(Str(Val(_Quanti),10,02),10," ")   ,;
//                                _Unitario ,;
//                                _Total    ,;
//                                Padl(Str(Val(_BICMS),10,02),10," ")    ,;
//                                Padl(Str(Val(_AICMS),06,02),10," ")    ,;
//                                Padl(Str(Val(_VICMS),10,02),10," ")    ,;
//                                Padl(Str(Val(_BIPI),10,02),10," ")     ,;
//                                Padl(Str(Val(_AIPI),06,02),10," ")     ,;
//                                Padl(Str(Val(_VIPI),10,02),10," ")     ,;
//                                ''                                     ,;
//                                ''                                     ,;
//                                ''                                     ,;
//                                ''                                     ,;
//                                Padl(Str(Val(_BICMSST),10,02),10," ")  ,;
//                                Padl(Str(Val(_AICMSST),06,02),10," ")  ,;
//                                Padl(Str(Val(_VICMSST),10,02),10," ")  ,;
//                                '*'                                    ,;
//                                ''} )

             aAdd( aProdutos, { Strzero(nPosicao,4) ,;
                                _Produto            ,;
                                _Descricao          ,;
                                _NCM                ,;
                                _Unidade            ,;
                                Val(_Quanti)        ,;
                                _Unitario           ,;
                                _Total              ,;
                                Val(_BICMS)         ,;
                                Val(_AICMS)         ,;
                                Val(_VICMS)         ,;
                                Val(_BIPI)          ,;
                                Val(_AIPI)          ,;
                                Val(_VIPI)          ,;
                                ''                  ,;
                                ''                  ,;
                                ''                  ,;
                                ''                  ,;
                                Val(_BICMSST)       ,;
                                Val(_AICMSST)       ,;
                                Val(_VICMSST)       ,;
                                '  '                ,;
                                '*'} )



          _BICMSST := ""
          _AICMSST := ""
          _VICMSST := ""

       Else
             nPosicao += 1

//             aAdd( aProdutos, { Strzero(nPosicao,4)                    ,; 
//                                T_PRODUTO->A5_PRODUTO                  ,;
//                                Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX),;
//                                _NCM                                   ,;
//                                _Unidade                               ,;
//                                Padl(Str(Val(_Quanti),10,02),10," ")   ,;
//                                _Unitario ,;
//                                _Total    ,;
//                                Padl(Str(Val(_BICMS),10,02),10," ")    ,;
//                                Padl(Str(Val(_AICMS),06,02),10," ")    ,;
//                                Padl(Str(Val(_VICMS),10,02),10," ")    ,;
//                                Padl(Str(Val(_BIPI),10,02),10," ")     ,;
//                                Padl(Str(Val(_AIPI),06,02),10," ")     ,;
//                                Padl(Str(Val(_VIPI),10,02),10," ")     ,;
//                                ""                                     ,;
//                                ''                                     ,;
//                                ''                                     ,;
//                                ''                                     ,;
//                                Padl(Str(Val(_BICMSST),10,02),10," ")  ,;
//                                Padl(Str(Val(_AICMSST),06,02),10," ")  ,;
//                                Padl(Str(Val(_VICMSST),10,02),10," ")  ,;
//                                ''                                     ,;
//                                ''} )


             aAdd( aProdutos, { Strzero(nPosicao,4)                    ,; 
                                T_PRODUTO->A5_PRODUTO                  ,;
                                Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX),;
                                _NCM                                   ,;
                                _Unidade                               ,;
                                Val(_Quanti)                           ,;
                                _Unitario                              ,;
                                _Total                                 ,;
                                Val(_BICMS)                            ,;
                                Val(_AICMS)                            ,;
                                Val(_VICMS)                            ,;
                                Val(_BIPI)                             ,;
                                Val(_AIPI)                             ,;
                                Val(_VIPI)                             ,;
                                ""                                     ,;
                                ''                                     ,;
                                ''                                     ,;
                                ''                                     ,;
                                Val(_BICMSST)                          ,;
                                Val(_AICMSST)                          ,;
                                Val(_VICMSST)                          ,;
                                '  '                                   ,;
                                ''} )

             _BICMSST := ""
             _AICMSST := ""
             _VICMSST := ""

          Endif          

       Endif
       
   Next nContar

   // Captura dados das Faturas da Nota Fiscal
   aFaturas   := {}
   nParcelas  := 0
   nTotal_Fat := 0
   For nContar = 1 to Len(aBrowse)
       If Alltrim(aBrowse[nContar,01]) == "<nDup"
          nParcelas += 1
          _Duplicata  := aBrowse[nContar + 1,01]
&&        _Duplicata  := Strzero(nParcelas,02)
          _Vencimento := Ctod(Substr(aBrowse[nContar + 3,01],09,02) + "/" + Substr(aBrowse[nContar + 3,01],06,02) + "/" + Substr(aBrowse[nContar + 3,01],01,04))
          _ValorDup   := aBrowse[nContar + 5,01]
          nTotal_Fat  := nTotal_Fat + val(aBrowse[nContar + 5,01])
          aAdd( aFaturas, { _Duplicata, _Vencimento, Val(_ValorDup) } )
       Endif
       
   Next nContar   

   // Grava dados do último produto do XML
   nItem := nItem + 1          

   // Pesquisa o código do poduto na tabela A5 (Produto X Fornecedores)
   If Select("T_PRODUTO") <>  0
      T_PRODUTO->(DbCloseArea())
   EndIf
         
   cSql := ""
   cSql := "SELECT A.A5_FORNECE, "
   cSql += "       A.A5_LOJA   , "
   cSql += "       A.A5_PRODUTO, "
   cSql += "       A.A5_CODPRF , "
   cSql += "       B.B1_DESC   , "
   cSql += "       B.B1_DAUX     "
   cSql += "  FROM " + RetSqlName("SA5") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B  "
   cSql += " WHERE A.A5_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND A.A5_FORNECE = '" + Alltrim(cFornece) + "'"
   cSql += "   AND A.A5_LOJA    = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND A.A5_CODPRF  = '" + Alltrim(_Produto) + "'"
   cSql += "   AND A.A5_PRODUTO = B.B1_COD"
   cSql += "   AND A.D_E_L_E_T_ = ''"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

//   If T_PRODUTO->( EOF() )
      nPosicao += 1

      aAdd( aProdutos, { Strzero(nPosicao,4)                    ,;
                         _Produto                               ,;
                         _Descricao                             ,;
                         _NCM                                   ,;
                         _Unidade                               ,;
                         Val(_Quanti),;
                         _Unitario ,;
                         _Total   ,;
                         Val(_BICMS),;
                         Val(_AICMS),;
                         Val(_VICMS),;
                         Val(_BIPI),;
                         Val(_AIPI),;
                         Val(_VIPI),;
                         ''                                     ,;
                         ''                                     ,;
                         ''                                     ,;
                         ''                                     ,;
                         Val(_BICMSST),;
                         Val(_AICMSST),;
                         Val(_VICMSST),;
                         '  '                                   ,;
                         '*'} )


//   Else
//      nPosicao += 1
//
//      aAdd( aProdutos, { Strzero(nPosicao,4)                    ,; 
//                         T_PRODUTO->A5_PRODUTO                  ,;
//                         Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX),;
//                         _NCM                                   ,;
//                         _Unidade                               ,;
//                         Val(_Quanti),;
//                         _Unitario ,;
//                         _Total    ,;
//                         Val(_BICMS),;
//                         Val(_AICMS),;
//                         Val(_VICMS),;
//                         Val(_BIPI) ,;
//                         Val(_AIPI) ,;
//                         Val(_VIPI) ,;
//                         ''                                     ,;
//                         ''                                     ,;
//                         ''                                     ,;
//                         ''                                     ,;
//                         Val(_BICMSST),;
//                         Val(_AICMSST),;
//                         Val(_VICMSST),;
//                         '*'                                    ,; //////////////////////////////////
//                         ''} )
//
//
//   Endif          

   If _xPorta == 1
   Else
   
      // Seta vetor para a browse                            
      oBrowse:SetArray(aProdutos) 

      // Monta a linha a ser exibina no Browse
      oBrowse:bLine := {||{ aProdutos[oBrowse:nAt,01],;
                            aProdutos[oBrowse:nAt,02],;
                            aProdutos[oBrowse:nAt,03],;
                            aProdutos[oBrowse:nAt,04],;
                            aProdutos[oBrowse:nAt,05],;
                            aProdutos[oBrowse:nAt,06],;
                            aProdutos[oBrowse:nAt,07],;
                            aProdutos[oBrowse:nAt,08],;
                            aProdutos[oBrowse:nAt,09],;
                            aProdutos[oBrowse:nAt,10],;
                            aProdutos[oBrowse:nAt,11],;
                            aProdutos[oBrowse:nAt,12],;
                            aProdutos[oBrowse:nAt,13],;
                            aProdutos[oBrowse:nAt,14],;
                            aProdutos[oBrowse:nAt,15],;
                            aProdutos[oBrowse:nAt,16],;
                            aProdutos[oBrowse:nAt,17],;
                            aProdutos[oBrowse:nAt,18],;
                            aProdutos[oBrowse:nAt,19],;
                            aProdutos[oBrowse:nAt,20],;
                            aProdutos[oBrowse:nAt,21],;
                            aProdutos[oBrowse:nAt,22]} }

      oBrowse:Refresh()
      
   Endif

   // ######################################################################################
   // Relaciona os produtos da nota fiscal com os códigos de produtos do Sistema Protheus ##
   // ######################################################################################
   Do Case

      // ############################################
      // Importação de Compras com Ordem de Compra ##
      // ############################################
      Case lTipoImp == 1

           For nContar = 1 to Len(aProdutos)

               If aProdutos[nContar,23] == "*"
                  cIncPro := .F.
                  cProInc := ""

                  // PROXFORNE(aProdutos[nContar,02], aProdutos[nContar,03])
                  // ######################################################################################################
                  // Envia para a função que pesquisa os pedidos de compra em aberto para o produto passado no parâmetro ##
                  // ######################################################################################################
                  xx_Codigo := ""
                  ABREPEDCOMPRA(aProdutos[nContar,02],aProdutos[nContar,03])

                  // ###############################################################################################################
                  // Se xx_codigo retornar vazio (|||), envia para a função que pesquisa todos os pedidos de compra do fornecedor ##
                  // ###############################################################################################################
                  If Empty(Alltrim(U_P_CORTA(xx_Codigo,"|", 1)))
    
                     // ###########################################################################
                     // Função que pesquisa todos os pedidos de compra do fornecedor selecionado ##
                     // ###########################################################################   
                     BUSCAPEDC()
             
                  Endif

               Endif

               // ##############################################################################################################
               // Carrega o código do produto, código do pedido de compra e o item do pedido de compra do produto posicionado ##
               // ##############################################################################################################
               aProdutos[nContar,02] := U_P_CORTA(xx_Codigo,"|", 1)
               aProdutos[nContar,15] := U_P_CORTA(xx_Codigo,"|", 2)
               aProdutos[nContar,16] := U_P_CORTA(xx_Codigo,"|", 3)
        
               If !Empty(Alltrim(U_P_CORTA(xx_Codigo,"|", 1)))

                  cProInc := U_P_CORTA(xx_Codigo,"|", 1)

                  If !Empty(Alltrim(cProInc))

                     If Select("T_NOVADESC") <>  0
                        T_NOVADESC->(DbCloseArea())
                     EndIf

                     cSql := ""
                     cSql := "SELECT B1_COD , "
                     cSql += "       B1_DESC, "
                     cSql += "       B1_DAUX  "
                     cSql += "  FROM " + RetSqlName("SB1")
                     cSql += " WHERE B1_COD = '" + Alltrim(cProInc) + "'"
                
                     cSql := ChangeQuery(cSql)
                     DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_NOVADESC",.T.,.T.)

                     aProdutos[nContar,02] := T_NOVADESC->B1_COD
                     aProdutos[nContar,03] := Alltrim(T_NOVADESC->B1_DESC) + " " + Alltrim(T_NOVADESC->B1_DAUX)
                     aProdutos[nContar,22] := ""

                     If _xPorta == 1
                     Else
                
                        // Seta vetor para a browse                            
                        oBrowse:SetArray(aProdutos) 

                        // Monta a linha a ser exibina no Browse
                        oBrowse:bLine := {||{ aProdutos[oBrowse:nAt,01],;
                                              aProdutos[oBrowse:nAt,02], aProdutos[oBrowse:nAt,03], aProdutos[oBrowse:nAt,04], aProdutos[oBrowse:nAt,05],;
                                              aProdutos[oBrowse:nAt,06], aProdutos[oBrowse:nAt,07], aProdutos[oBrowse:nAt,08], aProdutos[oBrowse:nAt,09],;
                                              aProdutos[oBrowse:nAt,10], aProdutos[oBrowse:nAt,11], aProdutos[oBrowse:nAt,12], aProdutos[oBrowse:nAt,13],;
                                              aProdutos[oBrowse:nAt,14], aProdutos[oBrowse:nAt,15], aProdutos[oBrowse:nAt,16], aProdutos[oBrowse:nAt,17],;
                                              aProdutos[oBrowse:nAt,18], aProdutos[oBrowse:nAt,19], aProdutos[oBrowse:nAt,20], aProdutos[oBrowse:nAt,21],;
                                              aProdutos[oBrowse:nAt,22]} }

                        oBrowse:Refresh()
                   
                     Endif

                  Endif
          
               Endif
          
           Next nContar

      // ################################
      // Importação de NFe de Despesas ##
      // ################################
      Case lTipoImp == 2

           RelProDespesas()

   EndCase





/*
   // Verifica se existem produtos que não foram localizados pedidos de compras na importação.
   // Se existir pelo menos um produto sem pedido de compra, a importação não será finalizada.
   cMensagem := ""
   For nContar = 1 to Len(aProdutos)
       If Alltrim(aProdutos[nContar,15]) == "X"
          cMensagem += "Produto: " + aProdutos[nContar,02] + " - " + aProdutos[nContar,03] + chr(13) + chr(10)
          cmensagem += "Pedido de Compra não localizado/selecionado para este produto."    + chr(13) + chr(10) + chr(13) + chr(10)
       Endif
   Next nContar

   If Empty(Alltrim(cMensagem))
      lTudoOK := .T.
   Else
      lTudoOK := .F.
      MsgAlert(cMensagem)
      Return(.T.)       
   Endif

*/

   // Captura os Totais da Nota Fiscal
   For nContar = 1 to Len(aBrowse)

       If Alltrim(aBrowse[nContar,01]) == "<ICMSTot"
          Exit
       Endif 
   Next nContar    
   
   For nLaco = nContar to Len(aBrowse)

       If aBrowse[nLaco,01] == "<transp"
          Exit
       Endif   
    
       If aBrowse[nLaco,01] == "<vBC"
          nBaseICMS  := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nBaseICMS  := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif   

	   If aBrowse[nLaco,01] == "<vICMS"   
          nVlrICMS   := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrICMS   := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif
          
	   If aBrowse[nLaco,01] == "<vBCST"   
          nBICMST    := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nBICMST    := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vST"             
          nVICMST    := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVICMST    := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vProd"             
          nTotPro    := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nTotPro    := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vIPI"             
          nVlrIPI    := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrIPI    := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vFrete"             
          nVlrFrete  := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrFrete  := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vSeg"             
          nVlrSeguro := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrSeguro := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vDesc"             
          nVlrDescon := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrDescon := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vOutro"             
          nVlrOutras := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrOutras := Str(Val(aBrowse[(nLaco + 1),01]),10,02)
       Endif

	   If aBrowse[nLaco,01] == "<vNF"             
          nVlrTotal  := Padl(Str(Val(aBrowse[(nLaco + 1),01]),10,02),30,"")
          nVlrTotal  := Str(val(aBrowse[(nLaco + 1),01]),10,02)
       Endif 

   Next nLaco

   If _xPorta == 1
   Else
      oDlg:refresh()
   Endif

   // Altera o tipo dos dados para display
   nBaseICMS  := Val(aBrowse[(nContar + 02),01])
   nVlrICMS   := Val(aBrowse[(nContar + 04),01])
   nBICMST    := Val(aBrowse[(nContar + 08),01])
   nVICMST    := Val(aBrowse[(nContar + 10),01])
   nTotPro    := Val(aBrowse[(nContar + 12),01])
   nVlrIPI    := Val(aBrowse[(nContar + 22),01])
   nVlrFrete  := Val(aBrowse[(nContar + 14),01])
   nVlrSeguro := Val(aBrowse[(nContar + 16),01])
   nVlrDescon := Val(aBrowse[(nContar + 18),01])
   nVlrOutras := Val(aBrowse[(nContar + 28),01])
   nVlrTotal  := Val(aBrowse[(nContar + 30),01])

//   nBaseICMS  := Val(aBrowse[(nContar + 02),01])
//   nVlrICMS   := Val(aBrowse[(nContar + 04),01])
//   nBICMST    := Val(aBrowse[(nContar + 06),01])
//   nVICMST    := Val(aBrowse[(nContar + 08),01])
//   nTotPro    := Val(aBrowse[(nContar + 10),01])
//   nVlrIPI    := Val(aBrowse[(nContar + 20),01])
//   nVlrFrete  := Val(aBrowse[(nContar + 12),01])
//   nVlrSeguro := Val(aBrowse[(nContar + 14),01])
//   nVlrDescon := Val(aBrowse[(nContar + 16),01])
//   nVlrOutras := Val(aBrowse[(nContar + 26),01])
//   nVlrTotal  := Val(aBrowse[(nContar + 28),01])

Return .T.

// Função que abre a tela de alteração do produto selecionado
Static Function ALTERAPROD(_Ktipo, xOperacao, xControla)

   Local lChumba   := .F.
   Local lFecha    := .F.
   Local nContar   := 0
   Local lTemTes   := .F.

   Local cTES1     := Space(03)
   Local oTES1

   Private cGet20  := "(" + Alltrim(aProdutos[oBrowse:nAt,01]) + ") - " + Alltrim(aProdutos[oBrowse:nAt,02]) + " - " + Alltrim(aProdutos[oBrowse:nAt,03])
   Private cGet21  := aProdutos[oBrowse:nAt,06]
   Private cGet22  := aProdutos[oBrowse:nAt,07]
   Private cGet23  := aProdutos[oBrowse:nAt,08]
   Private cGet24  := aProdutos[oBrowse:nAt,09]
   Private cGet25  := aProdutos[oBrowse:nAt,10]
   Private cGet26  := aProdutos[oBrowse:nAt,11]   
   Private cGet27  := aProdutos[oBrowse:nAt,12]   
   Private cGet28  := aProdutos[oBrowse:nAt,13]   
   Private cGet29  := aProdutos[oBrowse:nAt,14]
   Private cPedido := IIF(Empty(aProdutos[oBrowse:nAt,15]), Space(06), aProdutos[oBrowse:nAt,15])
   Private cItem   := IIF(Empty(aProdutos[oBrowse:nAt,16]), Space(04), aProdutos[oBrowse:nAt,16])
   Private cEntra  := IIF(Empty(aProdutos[oBrowse:nAt,17]), Space(03), aProdutos[oBrowse:nAt,17])
   Private cFisca  := IIF(Empty(aProdutos[oBrowse:nAt,18]), Space(05), aProdutos[oBrowse:nAt,18])

   Private cBICMS  := IIF(Empty(aProdutos[oBrowse:nAt,19]), 0        , aProdutos[oBrowse:nAt,19])
   Private cPICMS  := IIF(Empty(aProdutos[oBrowse:nAt,20]), 0        , aProdutos[oBrowse:nAt,20])
   Private cVICMS  := IIF(Empty(aProdutos[oBrowse:nAt,21]), 0        , aProdutos[oBrowse:nAt,21])
   Private cTpOper := IIF(Empty(aProdutos[oBrowse:nAt,22]), Space(02), aProdutos[oBrowse:nAt,22])

//   Private cBICMS  := IIF(Empty(aProdutos[oBrowse:nAt,19]), 0        , Val(aProdutos[oBrowse:nAt,19]))
//   Private cPICMS  := IIF(Empty(aProdutos[oBrowse:nAt,20]), 0        , Val(aProdutos[oBrowse:nAt,20]))
//   Private cVICMS  := IIF(Empty(aProdutos[oBrowse:nAt,21]), 0        , Val(aProdutos[oBrowse:nAt,21]))


   Private cOper   := "  "

   Private cMemo1  := ""
   Private cMemo2  := ""

   Private oGet20
   Private oGet21
   Private oGet22
   Private oGet23
   Private oGet24
   Private oGet25
   Private oGet26      
   Private oGet27      
   Private oGet28      
   Private oGet29         
   Private oGet30
   Private oGet31
   Private oGet32
   Private oGet33
   Private oGet34
   Private oGet35
   Private oGet36
   Private oGet37
   Private oGet38
   Private oMemo1
   Private oMemo2

   Private aComboBx1 := {}
   Private cComboBx1

   // Verifica se o campo cFiscal de todos os produtos está em branco.
   // Se estiver em branco, abre janela solicitando se usuário que indicar uma TES para todos os produtos.
   lTemTES := .F.
   
   For nContar = 1 to Len(aProdutos)
       If !Empty(Alltrim(aProdutos[oBrowse:nAt,17]))
          lTemTES := .T.
          Exit
       Endif
   Next nContar          

   If lTemTES == .F.   

      If Empty(Alltrim(xControla))
      Else

         Private oDlgTES

         DEFINE MSDIALOG oDlgTES TITLE "TES de Entrada" FROM C(178),C(181) TO C(285),C(526) PIXEL

         @ C(005),C(006) Say "Deseja selecionar uma TES para todos os produtos da Nota Fiscal?" Size C(164),C(008) COLOR CLR_BLACK PIXEL OF oDlgTES
         @ C(018),C(063) Say "TES" Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgTES

         @ C(017),C(080) MsGet oTES1 Var cTES1 Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTES F3("SF4")

         @ C(034),C(046) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgTES ACTION( CONFTES(cTES1) )
         @ C(034),C(084) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgTES ACTION( oDlgTES:End() )
      
         ACTIVATE MSDIALOG oDlgTES CENTERED 

      Endif   
      
   Endif   

   cEntra  := IIF(Empty(aProdutos[oBrowse:nAt,17]), Space(03), aProdutos[oBrowse:nAt,17])
   cFisca  := IIF(Empty(aProdutos[oBrowse:nAt,18]), Space(05), aProdutos[oBrowse:nAt,18])

   // Carrega o combo de Tipo de Operação
   If Select("T_OPERA") <>  0
      T_OPERA->(DbCloseArea())
   EndIf
   
   cSql := ""
   cSql := "SELECT X5_TABELA, "
   cSql += "       X5_CHAVE , "
   cSql += "       X5_DESCRI  "
   cSql += "  FROM " + RetSqlName("SX5") 
   cSql += " WHERE X5_TABELA  = 'DJ'"
   cSql += "   AND D_E_L_E_T_ = ''  "
   cSql += " ORDER BY X5_CHAVE"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_OPERA",.T.,.T.)

   T_OPERA->( DbGoTop() )
   WHILE !T_OPERA->( EOF() )
      aAdd( aComboBx1, T_OPERA->X5_CHAVE + " - " + T_OPERA->X5_DESCRI )
      T_OPERA->( DbSkip() )
   ENDDO

   Private oDlgAlt

   DEFINE MSDIALOG oDlgAlt TITLE "Alteração de Produto" FROM C(178),C(181) TO C(445),C(760) PIXEL

   @ C(001),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(023)                 PIXEL NOBORDER OF oDlgAlt
   @ C(003),C(144) Say "Produto"              Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(026),C(006) Say "Quant."               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(026),C(041) Say "Unitário"             Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(026),C(083) Say "Total"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(048),C(041) Say "Base ICMS"            Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(048),C(083) Say "% ICMS"               Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(048),C(125) Say "Total ICMS"           Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(048),C(166) Say "Base IPI"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(048),C(208) Say "% IPI"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(048),C(249) Say "Total IPI"            Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(081),C(006) Say "PC"                   Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(081),C(035) Say "Item PC"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(081),C(070) Say "T.OP"                 Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(081),C(102) Say "T.Entrada"            Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(081),C(134) Say "Cod.Fiscal"           Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(082),C(166) Say "B.ICMS ST"            Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(082),C(208) Say "% ICMS ST"            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(082),C(248) Say "Vlr ICMS ST"          Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt

   If xOperacao == "V"

      @ C(012),C(144) MsGet oGet20 Var cGet20       Size C(140),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lChumba
      @ C(036),C(005) MsGet oGet21 Var cGet21       Size C(030),C(009) COLOR CLR_BLACK Picture "@E 999,999.999" PIXEL OF oDlgAlt When lChumba
      @ C(036),C(041) MsGet oGet22 Var cGet22       Size C(035),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lChumba
      @ C(036),C(083) MsGet oGet23 Var cGet23       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(056),C(041) MsGet oGet24 Var cGet24       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(056),C(083) MsGet oGet25 Var cGet25       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(056),C(124) MsGet oGet26 Var cGet26       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(056),C(166) MsGet oGet27 Var cGet27       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(056),C(207) MsGet oGet28 Var cGet28       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(056),C(249) MsGet oGet29 Var cGet29       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt When lChumba
      @ C(072),C(005) GET   oMemo1 Var cMemo1  MEMO Size C(278),C(001)                                          PIXEL OF oDlgAlt When lChumba
      @ C(091),C(005) MsGet oGet30 Var cPedido      Size C(015),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lFecha When lChumba
      @ C(091),C(035) MsGet oGet31 Var cItem        Size C(015),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lFecha When lChumba
      @ C(091),C(070) MsGet oGet38 Var cTpOper      Size C(015),C(009) COLOR CLR_BLACK Picture "XX"             PIXEL OF oDlgAlt When lFecha When lChumba

      @ C(091),C(102) MsGet oGet32 Var cEntra       Size C(018),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt VALID(TRAZCF(cEntra)) F3("SF4") When IIF(_Ktipo == "P", .F., .T.) When lChumba
      @ C(091),C(134) MsGet oGet33 Var cFisca       Size C(026),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lChumba

      @ C(092),C(166) MsGet oGet34 Var cBICMS       Size C(035),C(009) COLOR CLR_BLACK Picture "9999999.99"     PIXEL OF oDlgAlt When lChumba
      @ C(092),C(207) MsGet oGet35 Var cPICMS       Size C(035),C(009) COLOR CLR_BLACK Picture "999.99"         PIXEL OF oDlgAlt When lChumba
      @ C(092),C(249) MsGet oGet36 Var cVICMS       Size C(035),C(009) COLOR CLR_BLACK Picture "9999999.99"     PIXEL OF oDlgAlt When lChumba
      @ C(108),C(005) GET   oMemo2 Var cMemo2 MEMO  Size C(278),C(001)                                          PIXEL OF oDlgAlt When lChumba
//    @ C(114),C(005) Button "P.Compra"             Size C(037),C(012) PIXEL OF oDlgAlt ACTION( BUSCAPEDC()   ) When lChumba 
//    @ C(114),C(045) Button "Limpa PC"             Size C(037),C(012) PIXEL OF oDlgAlt ACTION( LIMPAPEDC()   ) When lChumba 

   Else

      @ C(012),C(144) MsGet oGet20 Var cGet20       Size C(140),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lFecha
      @ C(036),C(005) MsGet oGet21 Var cGet21       Size C(030),C(009) COLOR CLR_BLACK Picture "@E 999,999.999" PIXEL OF oDlgAlt
      @ C(036),C(041) MsGet oGet22 Var cGet22       Size C(035),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt
      @ C(036),C(083) MsGet oGet23 Var cGet23       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(056),C(041) MsGet oGet24 Var cGet24       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(056),C(083) MsGet oGet25 Var cGet25       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(056),C(124) MsGet oGet26 Var cGet26       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(056),C(166) MsGet oGet27 Var cGet27       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(056),C(207) MsGet oGet28 Var cGet28       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(056),C(249) MsGet oGet29 Var cGet29       Size C(035),C(009) COLOR CLR_BLACK Picture "@E 999,999.99"  PIXEL OF oDlgAlt
      @ C(072),C(005) GET   oMemo1 Var cMemo1  MEMO Size C(278),C(001)                                          PIXEL OF oDlgAlt
      @ C(091),C(005) MsGet oGet30 Var cPedido      Size C(015),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lFecha
      @ C(091),C(035) MsGet oGet31 Var cItem        Size C(015),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt When lFecha

      @ C(091),C(070) MsGet oGet38 Var cTpOper      Size C(015),C(009) COLOR CLR_BLACK Picture "XX"             PIXEL OF oDlgAlt F3("SX5","DJ") VALID(BscTESInt(cTpOper, aProdutos[oBrowse:nAt,02]))
      @ C(091),C(102) MsGet oGet32 Var cEntra       Size C(020),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt VALID(TRAZCF(cEntra)) F3("SF4") When IIF(_Ktipo == "P", .F., .T.)
      @ C(091),C(134) MsGet oGet33 Var cFisca       Size C(026),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgAlt

      @ C(092),C(166) MsGet oGet34 Var cBICMS       Size C(035),C(009) COLOR CLR_BLACK Picture "9999999.99"     PIXEL OF oDlgAlt
      @ C(092),C(207) MsGet oGet35 Var cPICMS       Size C(035),C(009) COLOR CLR_BLACK Picture "999.99"         PIXEL OF oDlgAlt
      @ C(092),C(249) MsGet oGet36 Var cVICMS       Size C(035),C(009) COLOR CLR_BLACK Picture "9999999.99"     PIXEL OF oDlgAlt
      @ C(108),C(005) GET   oMemo2 Var cMemo2 MEMO  Size C(278),C(001)                                          PIXEL OF oDlgAlt
//    @ C(114),C(005) Button "P.Compra"             Size C(037),C(012) PIXEL OF oDlgAlt ACTION( BUSCAPEDC()   ) 
//    @ C(114),C(045) Button "Limpa PC"             Size C(037),C(012) PIXEL OF oDlgAlt ACTION( LIMPAPEDC()   )

   Endif      

   @ C(114),C(247) Button "Voltar"         Size C(037),C(012) PIXEL OF oDlgAlt ACTION( oDlgAlt:End() )

   ACTIVATE MSDIALOG oDlgAlt CENTERED 

   aProdutos[oBrowse:nAt,15] := cPedido
   aProdutos[oBrowse:nAt,16] := cItem
   aProdutos[oBrowse:nAt,17] := cEntra
   aProdutos[oBrowse:nAt,18] := cFisca
// aProdutos[oBrowse:nAt,19] := Padl(Str(cBICMS,10,02),10," ")
// aProdutos[oBrowse:nAt,20] := Padl(Str(cPICMS,10,02),10," ")
// aProdutos[oBrowse:nAt,21] := Padl(Str(cVICMS,10,02),10," ")

   aProdutos[oBrowse:nAt,19] := cBICMS
   aProdutos[oBrowse:nAt,20] := cPICMS
   aProdutos[oBrowse:nAt,21] := cVICMS

   aProdutos[oBrowse:nAt,22] := cTpOper

   // Seta vetor para a browse                            
   oBrowse:SetArray(aProdutos) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aProdutos[oBrowse:nAt,01],;
                         aProdutos[oBrowse:nAt,02],;
                         aProdutos[oBrowse:nAt,03],;
                         aProdutos[oBrowse:nAt,04],;
                         aProdutos[oBrowse:nAt,05],;
                         aProdutos[oBrowse:nAt,06],;
                         aProdutos[oBrowse:nAt,07],;
                         aProdutos[oBrowse:nAt,08],;
                         aProdutos[oBrowse:nAt,09],;
                         aProdutos[oBrowse:nAt,10],;
                         aProdutos[oBrowse:nAt,11],;
                         aProdutos[oBrowse:nAt,12],;
                         aProdutos[oBrowse:nAt,13],;
                         aProdutos[oBrowse:nAt,14],;
                         aProdutos[oBrowse:nAt,15],;
                         aProdutos[oBrowse:nAt,16],;
                         aProdutos[oBrowse:nAt,17],;
                         aProdutos[oBrowse:nAt,18],;
                         aProdutos[oBrowse:nAt,19],;
                         aProdutos[oBrowse:nAt,20],;
                         aProdutos[oBrowse:nAt,21],;
                         aProdutos[oBrowse:nAt,22]} }

   oBrowse:Refresh()

Return(.T.)

// #####################################################################
// Função que pesquisa o TES através da informação do TES Inteligente ##
// #####################################################################
Static Function BscTESInt(kInteligente, kProduto)

   If Empty(Alltrim(kInteligente))
      Return(.T.)
   Endif

   // ######################################
   // Pesquisa o TES pela TES Inteligente ##
   // ######################################
   cEntra := MaTesInt(1,kInteligente, cFornece, cLoja, "F", kProduto)
   cFisca  := Posicione('SF4', 1, xFilial('SF4') + cEntra, 'F4_CF')

Return(.T.)      

// Função que grava a TES para todos os produtos conforme solicitação do usuário
Static Function CONFTES(_TES)

   Local nContar := 0

   If Empty(Alltrim(_TES))
      MsgAlert("Necessário informar uma TES para confirmação.")
      Return .T.
   Endif

   For nContar = 1 to Len(aProdutos)
       aProdutos[nContar,17] := _TES
       aProdutos[nContar,18] := Posicione('SF4', 1, xFilial('SF4') + _TES, 'F4_CF')
   Next nContar
   
   oDlgTES:End()
   
Return .T.       

// Função que limpa os campos Pedido, Item do Pedido e Local
Static Function LIMPAPEDC()

   cPedido := Space(06)
   cItem   := Space(04)
   
Return .T.   

// Função que pesquisa os Pedidos de Compra em aberto para o fornecedor/produto selecionados
Static Function BUSCAPEDC()

   Local lChumba := .F.
   Local cSql    := ""

   Local xxFornecedor := Alltrim(cFornece) + "." + Alltrim(cLoja) + " - " + Alltrim(Posicione('SA2', 1, xFilial('SA2') + cFornece + cLoja, 'A2_NOME'))
   Local oGet1

   Local cMemo1	 := ""
   Local oMemo1

   Private oOk   := LoadBitmap( GetResources(), "LBOK" )
   Private oNo   := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgCPC

   Private aCompras := {}
   Private oCompras

   Private aLista := {}
   Private oLista

   // Pesquisa os pedidos de compra em aberto para o fornecedor/loja
   If Select("T_SALDOS") <>  0
      T_SALDOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT C7_NUM    ,"
   cSql += "       SUBSTRING(C7_EMISSAO,07,02) + '/' + SUBSTRING(C7_EMISSAO,05,02) + '/' + SUBSTRING(C7_EMISSAO,01,04) AS EMISSAO "
   cSql += "  FROM " + RetSqlName("SC7")
   cSql += " WHERE C7_FILIAL    = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND C7_FORNECE   = '" + Alltrim(cFornece) + "'"
   cSql += "   AND C7_LOJA      = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND C7_QUANT    <> C7_QUJE"
   cSql += "   AND C7_RESIDUO  <> 'S'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   cSql += " GROUP BY C7_NUM, C7_EMISSAO"
   cSql += " ORDER BY C7_NUM"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDOS",.T.,.T.)

   T_SALDOS->( DbGoTop() )
   
   WHILE !T_SALDOS->( EOF() )
      aAdd(aCompras, { T_SALDOS->C7_NUM, T_SALDOS->EMISSAO })
      T_SALDOS->( DbSkip() )
   ENDDO   

   If Len(aCompras) == 0
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Pedido(s) de compra não localizado(s).")
      Return(.T.)
   Endif

   // Envia para a rotina que carrega os produtos do pedido de compra
   Carga_Produtos_Pedido(1, aCompras[01,01])
   
   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgCPC TITLE "Pedidos de Compra" FROM C(178),C(181) TO C(485),C(888) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(374),C(001) PIXEL OF oDlgCPC

   @ C(035),C(005) Say "Fornecedor"                      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgCPC
   @ C(056),C(005) Say "Pedidos de Compra do Fornecedor" Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlgCPC

   @ C(044),C(005) MsGet oGet1 Var xxFornecedor Size C(205),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCPC

   @ C(136),C(277) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgCPC ACTION( VOLTAPC() )
   @ C(136),C(316) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgCPC ACTION( oDlgCPC:End() )

   // Desenha o Browse
   oCompras := TCBrowse():New( 080 , 005, 090, 090,,{'Nº P.Compra', 'Data Emissão'},{20,50,50,50},oDlgCPC,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oCompras:SetArray(aCompras) 
    
   // Monta a linha a ser exibina no Browse
   oCompras:bLine := {||{ aCompras[oCompras:nAt,01], aCompras[oCompras:nAt,02]} }

   oCompras:bLDblClick := {|| Carga_Produtos_Pedido(2, aCompras[oCompras:nAt,01])} 

   // Lista com os produtos do pedido selecionado
   @ 080,100 LISTBOX oList FIELDS HEADER "", "P.Compra", "Part Number", "Item", "Produto", "Local", "Qtd Solic.", "Qtd Ent.", "Saldos", "Emissao", "Moeda", "Unitário" PIXEL SIZE 350,090 OF oDlgCPC ;
             ON dblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())     

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
          					   aLista[oList:nAt,02],;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;          					             					   
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;         	        	       
         	        	       aLista[oList:nAt,12]}}

   ACTIVATE MSDIALOG oDlgCPC CENTERED 

Return .T.

// Função que pesquisa os produtos do pedido de compra selecionado
Static Function Carga_Produtos_Pedido(__Abertura, __Pedido)

   Local cSql := ""

   If Empty(Alltrim(__Pedido))
      Return(.T.)
   Endif

   aLista := {}

   // Pesquisa os pedidos de compra em aberto para o fornecedor/loja
   If Select("T_SALDOS") <>  0
      T_SALDOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT C7_FILIAL ,"
   cSql += "       C7_FORNECE,"
   cSql += "       C7_LOJA   ,"
   cSql += "       C7_NUM    ,"
   cSql += "       C7_EMISSAO,"
   cSql += "       C7_MOEDA  ,"
   cSql += "       C7_PRODUTO,"
   cSql += "       C7_PARTNUM,"
   cSql += "       C7_ITEM   ,"
   cSql += "       C7_LOCAL  ,"
   cSql += "       C7_QUANT  ,"
   cSql += "       C7_PRECO  ,"
   cSql += "       C7_QUJE   ,"
   cSql += "       C7_RESIDUO,"
   cSql += "      (C7_QUANT - C7_QUJE) AS SALDO"
   cSql += "  FROM " + RetSqlName("SC7")
   cSql += " WHERE C7_FILIAL    = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND C7_FORNECE   = '" + Alltrim(cFornece) + "'"
   cSql += "   AND C7_LOJA      = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND C7_NUM       = '" + Alltrim(__Pedido) + "'"
   cSql += "   AND C7_QUANT    <> C7_QUJE"
   cSql += "   AND C7_RESIDUO  <> 'S'"
   cSql += "   AND R_E_C_D_E_L_ = ''"
   cSql += " ORDER BY C7_NUM"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SALDOS",.T.,.T.)

   If T_SALDOS->( EOF() )
      aLista := {}
      aAdd( aLista, { .F., '', '', '', '', '', '', '', '', '' } )
   Else   
      T_SALDOS->( DbGoTop() )
      WHILE !T_SALDOS->( EOF() )
         AADD(aLista, {.F.                                       ,;
                       T_SALDOS->C7_NUM                          ,;
                       T_SALDOS->C7_PARTNUM                      ,;
                       T_SALDOS->C7_ITEM                         ,;
                       T_SALDOS->C7_PRODUTO                      ,;
                       T_SALDOS->C7_LOCAL                        ,;
                       T_SALDOS->C7_QUANT                        ,;
                       T_SALDOS->C7_QUJE                         ,;
                       T_SALDOS->SALDO                           ,;
                       Substr(T_SALDOS->C7_EMISSAO,07,02) + "/" + ;
                       Substr(T_SALDOS->C7_EMISSAO,05,02) + "/" + ;
                       Substr(T_SALDOS->C7_EMISSAO,01,04)        ,;
                       Strzero(T_SALDOS->C7_MOEDA,02)            ,;
                       Str(T_SALDOS->C7_PRECO,10,02)             })
         T_SALDOS->( DbSkip() )
      Enddo                            
   Endif   

   If __Abertura == 1
      Return(.T.)
   Endif

   oList:SetArray( aLista )

   oList:bLine := {||     {Iif(aLista[oList:nAt,01],oOk,oNo),;
          					   aLista[oList:nAt,02],;
          					   aLista[oList:nAt,03],;
          					   aLista[oList:nAt,04],;
          					   aLista[oList:nAt,05],;
          					   aLista[oList:nAt,06],;          					             					   
         	        	       aLista[oList:nAt,07],;
         	        	       aLista[oList:nAt,08],;
         	        	       aLista[oList:nAt,09],;
         	        	       aLista[oList:nAt,10],;
         	        	       aLista[oList:nAt,11],;         	        	       
         	        	       aLista[oList:nAt,12]}}

   oList:Refresh()

Return(.T.)

// Função que Retorna o pedido de compra selecionado no grid
Static Function VOLTAPC()

   Local nContar  := 0
   Local cMarcado := 0

   xx_codigo := "|||"
   
   For nContar = 1 to Len(aLista)
      If aLista[nContar,01] == .T.  
         cMarcado := cMarcado + 1
      Endif
   Next nContar
   
   If cMarcado == 0
      MsgAlert("Nenhum Pedido de Compra foi marcado.")
      Return .T.
   Endif
         
   If cMarcado > 1
      MsgAlert("Somente é permitido marcar um produto do pedido de compra.")
      Return .T.
   Endif
         
   For nContar = 1 to Len(aLista)
      If aLista[nContar,01] == .T.  
         xx_Codigo := aLista[nContar,5] + "|" + aLista[nContar,2] + "|" + aLista[nContar,4] + "|"
         Exit
      Endif
   Next nContar

   oDlgCPC:End()
   
Return .T.

// Função que traz a classificação fiscal pelo codigo do Tipo de Entrada
Static Function TRAZCF(_Tipo)

   Local cSql := ""

   If Empty(_Tipo)
      Return .T.
   Endif
      
   If Select("T_TIPO") <>  0
      T_TIPO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT F4_CODIGO, "
   cSql += "       F4_CF      "
   cSql += "  FROM " + RetSqlName("SF4")
   cSql += " WHERE F4_CODIGO = '" + Alltrim(_Tipo) + "'"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TIPO",.T.,.T.)

   If T_TIPO->( EOF() )
      Return .T.
   Endif
   
   cFisca := T_TIPO->F4_CF
   
Return .T.

// Função que abre a tela das duplicatas da nota fiscal
Static Function ABREDUPLI()

   Private oDlgDup

   DEFINE MSDIALOG oDlgDup TITLE "Duplicatas" FROM C(178),C(181) TO C(418),C(430) PIXEL

   @ C(101),C(040) Button "Alterar" Size C(040),C(012) PIXEL OF oDlgDup ACTION( ALTERADUP() )
   @ C(101),C(082) Button "Voltar"  Size C(040),C(012) PIXEL OF oDlgDup ACTION( oDlgDup:End() )

   // Desenha o Browse
   oFatura := TCBrowse():New( 005 , 005, 150, 120,,{'Duplicata', 'Vencimento', 'Valor' },{20,50,50,50},oDlgDup,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oFatura:SetArray(aFaturas) 
    
   // Monta a linha a ser exibina no Browse
   oFatura:bLine := {||{ aFaturas[oFatura:nAt,01],;
                         aFaturas[oFatura:nAt,02],;
                         aFaturas[oFatura:nAt,03]} }

   ACTIVATE MSDIALOG oDlgDup CENTERED 

Return(.T.)

// Função que altera dados da duplicata selecionada
Static Function ALTERADUP()

   Local cDuplicata  := IIF(Empty(aFaturas[oFatura:nAt,01]), Space(20)         , aFaturas[oFatura:nAt,01])
   Local cVencimento := IIF(Empty(aFaturas[oFatura:nAt,02]), Ctod("  /  /    "), aFaturas[oFatura:nAt,02])
   Local cValor      := IIF(aFaturas[oFatura:nAt,03] == 0, 0                   , aFaturas[oFatura:nAt,03])

   Local oGet1
   Local oGet2
   Local oGet3

   Private oDlgAlt

   DEFINE MSDIALOG oDlgAlt TITLE "Duplicatas" FROM C(178),C(181) TO C(275),C(487) PIXEL

   @ C(005),C(004) Say "Duplicata"  Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(005),C(062) Say "Vencimento" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt
   @ C(005),C(108) Say "Valor"      Size C(017),C(008) COLOR CLR_BLACK PIXEL OF oDlgAlt

   @ C(015),C(004) MsGet oGet1 Var cDuplicata  Size C(052),C(009) COLOR CLR_BLACK Picture "@!"         PIXEL OF oDlgAlt
   @ C(015),C(062) MsGet oGet2 Var cVencimento Size C(040),C(009) COLOR CLR_BLACK Picture "@!"         PIXEL OF oDlgAlt
   @ C(015),C(108) MsGet oGet3 Var cValor      Size C(041),C(009) COLOR CLR_BLACK Picture "9999999.99" PIXEL OF oDlgAlt

   @ C(031),C(109) Button "Voltar" Size C(040),C(012) PIXEL OF oDlgAlt ACTION ( oDlgAlt:End() )

   ACTIVATE MSDIALOG oDlgAlt CENTERED 

   aFaturas[oFatura:nAt,01] := cDuplicata
   aFaturas[oFatura:nAt,02] := cVencimento
   aFaturas[oFatura:nAt,03] := cValor

   // Seta vetor para a browse                            
   oFatura:SetArray(aFaturas) 
    
   // Monta a linha a ser exibina no Browse
   oFatura:bLine := {||{ aFaturas[oFatura:nAt,01],;
                         aFaturas[oFatura:nAt,02],;
                         aFaturas[oFatura:nAt,03]} }

Return(.T.)

// Função que abre a tela da solicitação da condição de pagamento e natureza
Static Function ABRECONDI()

   Local lFechado    := .F.

   If Empty(Alltrim(cNota)) 
      Return .T.
   Endif

   Private oDlgx

   BUSCACONDI(cCondicao)
   BUSCANATUR(cNatureza)

   DEFINE MSDIALOG oDlgx TITLE "Condição de Pagamento/Natureza" FROM C(178),C(181) TO C(473),C(543) PIXEL

   @ C(005),C(005) Say "Condição de Pagamento"     Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(026),C(005) Say "Desdobramento dos Títulos" Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
   @ C(108),C(005) Say "Natureza"                  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgx

   @ C(015),C(005) MsGet oCondicao Var cCondicao F3("SE4")               Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx VALID(BUSCACONDI(cCondicao))
   @ C(015),C(033) MsGet oNome_Con Var cNome_Con           When lFechado Size C(143),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx
   @ C(117),C(005) MsGet oNatureza Var cNatureza F3("SED")               Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx VALID(BUSCANATUR(cNatureza))
   @ C(117),C(033) MsGet oNome_Nat Var cNome_Nat           When lFechado Size C(143),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgx

   @ C(096),C(139) Button "Alterar" Size C(037),C(012) PIXEL OF oDlgx ACTION( ALTERADUP() ) 
   @ C(131),C(139) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlgx ACTION( SAIR_CONDICAO() )

   // Desenha o Browse
   oFatura := TCBrowse():New( 040 , 005, 220, 080,,{'Duplicata', 'Vencimento', 'Valor' },{20,50,50,50},oDlgx,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oFatura:SetArray(aFaturas) 
    
   // Monta a linha a ser exibina no Browse
   oFatura:bLine := {||{ aFaturas[oFatura:nAt,01],;
                         aFaturas[oFatura:nAt,02],;
                         aFaturas[oFatura:nAt,03]} }

   ACTIVATE MSDIALOG oDlgx CENTERED 
   
Return .T.   

// Função que verifica se pode ser fechada a tela de condição de pagamento
Static Function SAIR_CONDICAO()

   Local nContar    := 0
   Local nVerificar := 0
   
   For nContar = 1 to Len(aFaturas)
       nVerificar := nVerificar + aFaturas[nContar,03]
   Next nContar    

// If nTotal_fat <> nVerificar
   If nVlrTotal <> nVerificar
      If lTipoImp == 1
         msgalert("Atenção! Desdobramento de Faturas está inconsistente. Verifique!")
         Return .T.
      Else
         oDlgx:End()      
      Endif   
   Else   	
      oDlgx:End()
   Endif   
   
Return .T.   

// Função que abre a tela da solicitação da condição de pagamento e natureza
Static Function BUSCACONDI(_Condicao)

   Local cSql := ""
   
   If Empty(Alltrim(_Condicao))
      cNome_Con := ""
      Return .T.
   Endif
  
   If Select("T_CONDICAO") <>  0
      T_CONDICAO->(DbCloseArea())
   EndIf

   cSql := ""     
   cSql := "SELECT E4_CODIGO,"
   cSql += "       E4_DESCRI "
   cSql += "  FROM " + RetSqlName("SE4")
   cSql += " WHERE E4_CODIGO    = '" + Alltrim(_Condicao) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CONDICAO",.T.,.T.)

   If T_CONDICAO->( EOF() )
      cNome_Con := ""
      Return .T.
   Endif

   cNome_Con := T_CONDICAO->E4_DESCRI

Return .T.         

// Função que abre a tela da solicitação da condição de pagamento e natureza
Static Function BUSCANATUR(_Natureza)

   Local cSql := ""
   
   If Empty(Alltrim(_Natureza))
      cNome_Nat := ""
      Return .T.
   Endif
  
   If Select("T_NATUREZA") <>  0
      T_NATUREZA->(DbCloseArea())
   EndIf

   cSql := ""     
   cSql := "SELECT ED_CODIGO ,"
   cSql += "       ED_DESCRIC "
   cSql += "  FROM " + RetSqlName("SED")
   cSql += " WHERE ED_CODIGO    = '" + Alltrim(_Natureza) + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_NATUREZA",.T.,.T.)

   If T_NATUREZA->( EOF() )
      cNome_Nat := ""
      Return .T.
   Endif

   cNome_Nat := T_NATUREZA->ED_DESCRIC

Return .T.         

// Função que mostra a chave de acesso da DANFE
Static Function MOSTRADANFE()

   Local cGet1	:= _Danfe
   Local oGet1
   Local lFecha := .F.   

   Private oDlgDanfe

   DEFINE MSDIALOG oDlgDanfe TITLE "DANFE" FROM C(178),C(181) TO C(273),C(513) PIXEL

   @ C(004),C(004) Say "Chave de Acesso" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgDanfe

   @ C(014),C(004) MsGet oGet1 Var cGet1 When lFecha Size C(158),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDanfe

   @ C(029),C(124) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDanfe ACTION (oDlgDanfe:End() )
 
   ACTIVATE MSDIALOG oDlgDanfe CENTERED 

Return(.T.)

// ###########################################################################
// Função que salva os dados da DANFE nas tabelas da nota fiscal de entrada ##
// ###########################################################################
Static Function SALVADANFE(_Ktipo, xOperacao, xControla)

   Local nContar       := 0
   Local vBIcmsST      := 0
   Local vVIcmsST      := 0
   Local nDuplicatas   := 0
   Local nContar       := 0
   Local _nErro        := 0
   Local lResult

   Private aCabec      := {}
   Private aItens      := {}
   Private lMsErroAuto := .F.  
   Private lMsHelpAuto := .F.

   PRIVATE aRotina := {{"Pesquisar"   , "AxPesqui"   , 0, 1},;
              		   {"Visualizar"  , "A103NFiscal", 0, 2},; 
		               {"Incluir"     , "A103NFiscal", 0, 3},; 
   		               { "Classificar", "A103NFiscal", 0, 4},; 
		               {"Retornar"    , "A103Devol"  , 0, 3},; 
		               {"Excluir"     , "A103NFiscal", 3, 5},; 
		               {"Imprimir"    , "A103Impri"  , 0, 4},; 
		               {"Legenda"     , "A103Legenda", 0, 2} } 

   If Empty(Alltrim(cFornece))
      Return .T.
   Endif   

   // #########################################################################
   // Se operação == E - Excluir, elimina os lançamentos da tabela ZT8 e ZT9 ##
   // #########################################################################
   If xOperacao == "E"

      If MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Deseja realmente excluir os dados deste XML?")

         // Elimina lançamento na tabela ZT8 para receber nova inclusão
         cSql := ""
         cSql := "DELETE "
         cSql += "  FROM " + RetSqlName("ZT8")
         cSql += " WHERE ZT8_FILIAL = '" + Alltrim(cFilAnt)  + "'"
         cSql += "   AND ZT8_NOTA   = '" + Alltrim(cNota)    + "'"
         cSql += "   AND ZT8_SERI   = '" + Alltrim(cSerie)   + "'"
         cSql += "   AND ZT8_FORN   = '" + Alltrim(cFornece) + "'"
         cSql += "   AND ZT8_LOJA   = '" + Alltrim(cLoja)    + "'"

         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
         Endif

         // Elimina lançamento na tabela ZT9 para receber nova inclusão
         cSql := ""
         cSql := "DELETE "
         cSql += "  FROM " + RetSqlName("ZT9")
         cSql += " WHERE ZT9_FILIAL = '" + Alltrim(cFilAnt)  + "'"
         cSql += "   AND ZT9_NOTA   = '" + Alltrim(cNota)    + "'"
         cSql += "   AND ZT9_SERI   = '" + Alltrim(cSerie)   + "'"
         cSql += "   AND ZT9_FORN   = '" + Alltrim(cFornece) + "'"
         cSql += "   AND ZT9_LOJA   = '" + Alltrim(cLoja)    + "'"

         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
         Endif

         oDlg:END()

         If xOperacao == "I"
            oDlgXML:END()
         Endif   
         
         Return(.T.)
         
      Else
      
         Return(.T.)
      
      Endif
         
   Endif

   // ####################################################################################################
   // Verifica se existe algum produto que não esteja cadastrado na tebela A5 (Produtos X Fornecedores) ##
   // ####################################################################################################
   cMensagem1 := ""
   cMensagem1 := cMensagem1 + "Atenção!!" + chr(13) + chr(13)
   cMensagem1 := cMensagem1 + "O(s) Produto(s) abaixo relacionado(s), não estão cadastrados na tabela de Produtos X Fornecedores. Importação não será realizada." + chr(13) + chr(13)

   cMensagem2 := ""

   For nContar = 1 to Len(aProdutos)

       If aProdutos[nContar,22] == "*"
          cMensagem2 := cMensagem2 + aProdutos[nContar,02] + " - " + Alltrim(aProdutos[nContar,03]) + chr(13)
       Endif

   Next nContar

   If !Empty(cMensagem2)
      MsgAlert(cMensagem1 + cMensagem2)
      Return .T.
   Endif

   // #############################################
   // Grava os dados conforme o parâmetro _Ktipo ##
   // #############################################
   If _Ktipo == "P"

      // Elimina lançamento na tabela ZT8 - Cabeçalho da Nota Fiscal, para receber nova inclusão
      cSql := ""
      cSql := "DELETE "
      cSql += "  FROM " + RetSqlName("ZT8")
      cSql += " WHERE ZT8_FILIAL = '" + Alltrim(cFilAnt)  + "'"
      cSql += "   AND ZT8_NOTA   = '" + Alltrim(cNota)    + "'"
      cSql += "   AND ZT8_SERI   = '" + Alltrim(cSerie)   + "'"
      cSql += "   AND ZT8_FORN   = '" + Alltrim(cFornece) + "'"
      cSql += "   AND ZT8_LOJA   = '" + Alltrim(cLoja)    + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
      Endif

      // Elimina lançamento na tabela ZT9 - Produtos da Nota Fiscal, para receber nova inclusão
      cSql := ""
      cSql := "DELETE "
      cSql += "  FROM " + RetSqlName("ZT9")
      cSql += " WHERE ZT9_FILIAL = '" + Alltrim(cFilAnt)  + "'"
      cSql += "   AND ZT9_NOTA   = '" + Alltrim(cNota)    + "'"
      cSql += "   AND ZT9_SERI   = '" + Alltrim(cSerie)   + "'"
      cSql += "   AND ZT9_FORN   = '" + Alltrim(cFornece) + "'"
      cSql += "   AND ZT9_LOJA   = '" + Alltrim(cLoja)    + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
      Endif

      // Elimina lançamento na tabela ZTA - Duplicatas da nota fiscal, para receber nova inclusão
      cSql := ""
      cSql := "DELETE "
      cSql += "  FROM " + RetSqlName("ZTA")
      cSql += " WHERE ZTA_FILIAL = '" + Alltrim(cFilAnt)  + "'"
      cSql += "   AND ZTA_NOTA   = '" + Alltrim(cNota)    + "'"
      cSql += "   AND ZTA_SERI   = '" + Alltrim(cSerie)   + "'"
      cSql += "   AND ZTA_FORN   = '" + Alltrim(cFornece) + "'"
      cSql += "   AND ZTA_LOJA   = '" + Alltrim(cLoja)    + "'"

      _nErro := TcSqlExec(cSql) 

      If TCSQLExec(cSql) < 0 
         alert(TCSQLERROR())
      Endif

      // Prepara o variável com centros de custos para gravação
      cCusto := ""
      For nContar = 1 to Len(aCustos)
          cCusto := cCusto + Str(aCustos[nContar,01],06,02) + "|" + aCustos[nContar,02] + "|" + Alltrim(aCustos[nContar,03]) + "|#"
      Next nContar    

      // Grava dados do cabeçalho do documento fiscal na tabela ZT8010
      dbSelectArea("ZT8")
      RecLock("ZT8",.T.)
      ZT8_FILIAL := cFilAnt
      ZT8_ARQU   := cCaminho
      ZT8_CHAV   := _Danfe
      ZT8_NOTA   := cNota
      ZT8_SERI   := cSerie
      ZT8_EMIS   := cEmissao
      ZT8_ESTA   := cUFOrigem
      ZT8_ESPE   := cEspecie
      ZT8_FORN   := cFornece
      ZT8_LOJA   := cLoja
      ZT8_USUA   := Alltrim(cUserName)
      ZT8_DATA   := Date()
      ZT8_HORA   := Time()
      ZT8_BICM   := nBaseICMS
      ZT8_VICM   := nVlrICMS
      ZT8_BIST   := nBicmSt
      ZT8_VIST   := nVicmSt
      ZT8_VIPI   := nVlrIPI
      ZT8_VPRO   := nTotPro
      ZT8_FRET   := nVlrFrete
      ZT8_SEGU   := nVlrSeguro
      ZT8_DESC   := nVlrDescon
      ZT8_DESP   := nVlrOutras
      ZT8_TOTA   := nVlrTotal
      ZT8_STAT   := "A"
      ZT8_CUST   := cCusto
      ZT8_COND   := cCondicao
      ZT8_NATU   := cNatureza
      ZT8_TIMP   := lTipoImp
      MsUnLock()

      // Grava os dados dos produtos do documento de entrada
      For nContar = 1 to Len(aProdutos)				

          dbSelectArea("ZT9")
          RecLock("ZT9",.T.)
          ZT9_FILIAL := cFilAnt
          ZT9_ITEM   := aProdutos[nContar,01]
          ZT9_CODI   := aProdutos[nContar,02]
          ZT9_QUAN   := aProdutos[nContar,06]
          ZT9_PREC   := aProdutos[nContar,07]
          ZT9_TOTA   := aProdutos[nContar,08]
          ZT9_BICM   := aProdutos[nContar,09]
          ZT9_PICM   := aProdutos[nContar,10]
          ZT9_VICM   := aProdutos[nContar,11]
          ZT9_BIPI   := aProdutos[nContar,12]
          ZT9_PIPI   := aProdutos[nContar,13]
          ZT9_VIPI   := aProdutos[nContar,14]
          ZT9_PCOM   := aProdutos[nContar,15]
          ZT9_IPCO   := aProdutos[nContar,16]
          ZT9_TES    := aProdutos[nContar,17]
          ZT9_CFOP   := aProdutos[nContar,18]
          ZT9_BIST   := aProdutos[nContar,19]
          ZT9_PIST   := aProdutos[nContar,20]
          ZT9_VIST   := aProdutos[nContar,21]
          ZT9_LOCA   := aProdutos[nContar,22]
          ZT9_NOTA   := cNota
          ZT9_SERI   := cSerie
          ZT9_FORN   := cFornece
          ZT9_LOJA   := cLoja
          MsUnLock()
      Next nContar    

      // Grava as duplicatas na tabela ZTA
      For nContar = 1 to Len(aFaturas)

          If Empty(Alltrim(aFaturas[nContar,01]))
             Loop
          Endif   

          dbSelectArea("ZTA")
          RecLock("ZTA",.T.)
          ZTA_FILIAL := cFilAnt
          ZTA_NOTA   := cNota
          ZTA_SERI   := cSerie
          ZTA_FORN   := cFornece
          ZTA_LOJA   := cLoja
          ZTA_CHAV   := _Danfe
          ZTA_DUPL   := aFaturas[nContar,01]
          ZTA_VENC   := aFaturas[nContar,02]
          ZTA_VALOR  := aFaturas[nContar,03]
          MsUnLock()

     Next nContar  

     oDlg:END()

     If xOperacao == "I"
        oDlgXML:END()
     Endif   

   Else

      // ############################################################
      // Verifica se todos os produtos possuem a informação de TES ##
      // ############################################################
      nTes := 0
      For nContar = 1 to Len(aProdutos)
          If !Empty(aProdutos[nContar,17])
             nTes := nTes + 1
          Endif
      Next nContar

      If ntes <> Len(aProdutos)
         MsgAlert("Existem produtos sem a informação da TES. Verifique!!")
         Return .T.
      Endif

      // ###########################################################################
      // Se houver ICMS Substituição, verifica se este foi informado nos produtos ##
      // ###########################################################################
      If nBICMST <> 0
  
         vBIcmsST := 0
         vVIcmsST := 0

         For nContar = 1 to Len(aProdutos)
             vBIcmsST := vBIcmsST + aProdutos[nContar,19]
             vVIcmsST := vVIcmsST + aProdutos[nContar,21]
         Next nContar
      
         If vBIcmsST == 0
            MsgAlert("Base de ICMS Substituição não informado nos produtos. Verifique!!")
            Return .T.
         Endif
             
         If vVIcmsST == 0
            MsgAlert("Valor de ICMS Substituição não informado nos produtos. Verifique!!")
            Return .T.
         Endif

         If nBICMST <> vBIcmsST
            MsgAlert("Valor da Base de ICMS Substituição dos produtos não confere com o total da soma da Base do ICMS Substituição dos produtos. Verifique!!")
            Return .T.
         Endif

         If nVICMST <> vVIcmsST
            MsgAlert("Valor do ICMS Substituição dos produtos não confere com o total do ICMS Substituição da Nota Fiscal. Verifique!!")
            Return .T.
         Endif

      Endif

      // #################################################
      // Verifica a informação da condição de pagamento ##
      // #################################################
      If lTipoImp == 1
         If Empty(Alltrim(cCondicao))
            MsgAlert("Condição de Pagamento não informada. Verifique!!")
            Return .T.
         Endif
      Endif   

      // Verifica se o total das duplicatas fecha com o valor total da nota fiscal
      nDuplicatas := 0
      For nContar = 1 to Len(aFaturas)
          nDuplicatas := nDuplicatas + aFaturas[nContar,03]
      Next nContar    
   
      If nVlrTotal <> nDuplicatas
//       MsgAlert("Valor total das duplicatas não confere com o valor total da Nota Fiscal. Verifique!!")
//       Return .T.
      Endif

      // Carrega o array aCabec
	  aAdd( aCabec, {"F1_TIPO"   , "N"                         , Nil, Nil } )
	  aAdd( aCabec, {"F1_FORMUL" , "N"                         , Nil, Nil } )
	  aAdd( aCabec, {"F1_FILIAL" , cFilAnt                     , Nil, Nil } )
	  aAdd( aCabec, {"F1_DOC"    , Alltrim(Str(Val(cNota),9))  , Nil, Nil } )
	  aAdd( aCabec, {"F1_SERIE"  , Alltrim(Str(Val(cSerie),3)) , Nil, Nil } )
	  aAdd( aCabec, {"F1_ESPECIE", "SPED"                      , Nil, Nil } )
	  aAdd( aCabec, {"F1_EMISSAO", cEmissao                    , Nil, Nil } )
	  aAdd( aCabec, {"F1_DTDIGIT", dDataBase                   , Nil, Nil } )
	  aAdd( aCabec, {"F1_FORNECE", cFornece                    , Nil, Nil } )
	  aAdd( aCabec, {"F1_LOJA"   , cLoja                       , Nil, Nil } )
      aAdd( aCabec, {"F1_CHVNFE" , _Danfe                      , Nil, Nil } )
	  aAdd( aCabec, {"F1_EST"    , cUfOrigem                   , Nil, Nil } )
	  aAdd( aCabec, {"F1_MOEDA"  , cMoeda                      , Nil, Nil } )
  
      If Empty(Alltrim(cCondicao))	 
      Else
   	     aAdd( aCabec, {"F1_COND"   , cCondicao                   , Nil, Nil } )
   	  Endif

      // Carrega o Array de Produtos
	  For nContar := 1 To Len(aProdutos)
	
          xEmissao   := Substr(Dtoc(cEmissao) ,07,04) + Substr(Dtoc(cEmissao) ,04,02) + Substr(Dtoc(cEmissao) ,01,02)
          xDigitacao := Substr(Dtoc(Date()),07,04) + Substr(Dtoc(Date()),04,02) + Substr(Dtoc(Date()),01,02)
          xLocal     := Posicione('SB1', 1, xFilial('SB1') + aProdutos[nContar,2], 'B1_LOCPAD')
          xUnidade   := Posicione('SB1', 1, xFilial('SB1') + aProdutos[nContar,2], 'B1_UM')
          xTipoProd  := Posicione('SB1', 1, xFilial('SB1') + aProdutos[nContar,2], 'B1_TIPO')        

	      aLinha := {} 
		     
		  aAdd( aLinha, { "D1_FILIAL" , cFilAnt                    , Nil, Nil } )
		  aAdd( aLinha, { "D1_ITEM"   , Strzero(nContar,4)         , Nil, Nil } )
		  aAdd( aLinha, { "D1_COD"    , aProdutos[nContar,02]      , Nil, Nil } )
		  aAdd( aLinha, { "D1_UN"     , xUnidade                   , Nil, Nil } )
		  aAdd( aLinha, { "D1_TP"     , xTipoProd                  , Nil, Nil } )		
		  aAdd( aLinha, { "D1_QUANT"  , aProdutos[nContar,06]      , Nil, Nil } )
    	  aAdd( aLinha, { "D1_VUNIT"  , aProdutos[nContar,07]      , Nil, Nil } )
		  aAdd( aLinha, { "D1_TOTAL"  , aProdutos[nContar,08]      , Nil, Nil } )
          aAdd( aLinha, { "D1_TES"    , aProdutos[nContar,17]      , Nil, Nil } )
          aAdd( aLinha, { "D1_CF"     , aProdutos[nContar,18]      , Nil, Nil } )
		  aAdd( aLinha, { "D1_IPI"    , aProdutos[nContar,13]      , Nil, Nil } )

          // #######################################################################################################################################
          // Se nota fiscal for importação de nota fiscal com ordem de compra, envia nº do pedido de compra e posição do item no pedido de compra ##
          // #######################################################################################################################################
          If lTipoImp == 1
   		     aAdd( aLinha, { "D1_PEDIDO" , aProdutos[nContar,15]   , Nil, Nil } )
		     aAdd( aLinha, { "D1_ITEMPC" , aProdutos[nContar,16]   , Nil, Nil } )
		  Endif

		  aAdd( aLinha, { "D1_EMISSAO", xEmissao                   , Nil, Nil } )
		  aAdd( aLinha, { "D1_DTDIGIT", xDigitacao                 , Nil, Nil } )
		  aAdd( aLinha, { "D1_RATEIO" , "1"                        , Nil, Nil } )
		  aAdd( aLinha, { "D1_DOC"    , Alltrim(Str(Val(cNota),9)) , Nil, Nil } )
		  aAdd( aLinha, { "D1_SERIE"  , Alltrim(Str(Val(cSerie),3)), Nil, Nil } )
		  aAdd( aLinha, { "D1_FORNECE", cFornece                   , Nil, Nil } )
		  aAdd( aLinha, { "D1_LOJA"   , cLoja                      , Nil, Nil } )												
			
	      aAdd( aItens, aLinha )

	   Next

       // Executa rotina padrão do Protheus para inclusão da Nota Fiscal
       // MsgRun( "Aguarde gerando Nota de Entrada...",, { || MSExecAuto( { | x, y, z | MATA103(  x, y, z ) }, aCabec, aItens, 3) } )
       MsgRun( "Aguarde gerando Nota de Entrada...",, { || MSExecAuto( { | w, x, y, z | MATA103( w, x, y, z ) }, aCabec, aItens, 3, .T. ) } )

       If lMsErroAuto
	      MostraErro()
	      MsgAlert("Erro na inclusão dos dados do XML.")
	      Return .T.
	   Else

          // Verifica se o documento foi incluído. Se foi, altera o status da tabela ZT8010
          If Select("T_INCLUIU") <>  0
             T_INCLUIU->(DbCloseArea())
          EndIf

          cSql := ""
          cSql := "SELECT F1_FILIAL ,"
          cSql += "       F1_DOC    ,"
          cSql += "	      F1_SERIE  ,"
	      cSql += "       F1_FORNECE,"
	      cSql += "       F1_LOJA    "
          cSql += "  FROM " + RetSqlName("SF1")
          cSql += " WHERE F1_FILIAL              = '" + Alltrim(cFilAnt) + "'"
          cSql += "   AND LTRIM(RTRIM(F1_DOC))   = '" + Alltrim(cNota)   + "'"
          cSql += "   AND LTRIM(RTRIM(F1_SERIE)) = '" + Alltrim(cSerie)  + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_INCLUIU",.T.,.T.)

          If T_INCLUIU->( EOF() )
          Else
             // Altera o status do documento importado
             cSql := ""
             cSql := "UPDATE " + RetSqlName("ZT8")
             cSql += "   SET "
             cSql += "   ZT8_STAT = 'E'"
             cSql += " WHERE ZT8_CHAV = '" + Alltrim(_Danfe) + "'"

             lResult := TCSQLEXEC(cSql)
      
             If lResult < 0
                Return MsgStop("Erro ao gravar o Status da Documento: " + TCSQLError())
             EndIf 
          Endif
          
          // MsgAlert("XML importado com sucesso.")
      	  // Chama o programa da pré-nota
          // A103NFiscal("SF1",,4)

       EndIf




// ------------------------------------------------------
// MINHA ROTINA
// ------------------------------------------------------

/*

      // ---------------------------------- //
      // Rotina que grava a pré-nota do xml //
      // ---------------------------------- //

   	  // Cria o Array do cabeçalho da nota fiscal de entrada
  	  aAdd( aCabec, { "F1_TIPO"   , "N"      , Nil, Nil } )
	  aAdd( aCabec, { "F1_FORMUL" , "N"      , Nil, Nil } )
	  aAdd( aCabec, { "F1_DOC"    , cNota    , Nil, Nil } )
	  aAdd( aCabec, { "F1_CHVNFE" , _Danfe   , Nil, Nil } )
	  aAdd( aCabec, { "F1_SERIE"  , cSerie   , Nil, Nil } )
	  aAdd( aCabec, { "F1_EMISSAO", cEmissao , Nil, Nil } )
	  aAdd( aCabec, { "F1_FORNECE", cFornece , Nil, Nil } )
	  aAdd( aCabec, { "F1_LOJA"   , cLoja    , Nil, Nil } )
	  aAdd( aCabec, { "F1_ESPECIE", "SPED  " , Nil, Nil } )
	  aAdd( aCabec, { "F1_COND"   , cCondicao, Nil, Nil } )
	  aAdd( aCabec, { "F1_DESPESA", 0        , Nil, Nil } )
	  aAdd( aCabec, { "F1_DESCONT", 0        , Nil, Nil } )
	  aAdd( aCabec, { "F1_SEGURO" , 0        , Nil, Nil } )
	  aAdd( aCabec, { "F1_FRETE"  , nVlrFrete, Nil, Nil } )

      // Cria o array dos ítens da nota fiscal de entrada
      For nContar = 1 to Len(aProdutos)
		
           xEmissao   := Substr(Dtoc(cEmissao) ,07,04) + Substr(Dtoc(cEmissao) ,04,02) + Substr(Dtoc(cEmissao) ,01,02)
           xDigitacao := Substr(Dtoc(Date()),07,04) + Substr(Dtoc(Date()),04,02) + Substr(Dtoc(Date()),01,02)
           xLocal     := Posicione('SB1', 1, xFilial('SB1') + aProdutos[nContar,2], 'B1_LOCPAD')
		
           // Elabora o array dos produtos da nota fiscal
           aAdd(aItens, {{'D1_COD'    , aProdutos[nContar,02] 	   ,NIL}  ,;
   		                 {'D1_QUANT'  , aProdutos[nContar,06]      ,NIL}  ,;
   		                 {'D1_VUNIT'  , aProdutos[nContar,07]      ,NIL}  ,;
     		             {'D1_TOTAL'  , aProdutos[nContar,08]      ,NIL}  ,;
  		                 {'D1_TES'    , aProdutos[nContar,17]      ,NIL}  ,;
                         {'D1_IPI'    , aProdutos[nContar,13]      ,NIL}  ,;
                         {'D1_RATEIO' , "1"                        ,NIL}  ,;
      				     {'D1_PEDIDO' , aProdutos[nContar,15]      ,NIL}  ,;
   				         {'D1_ITEMPC' , aProdutos[nContar,16]      ,NIL}  ,;
   				         {'D1_LOCAL'  , xLocal                     ,NIL}})  

      Next nContar
	
      // Grava os dados da Pré-nota de entrada
      // MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, 3)

	  MsgRun( "Aguarde gerando Nota de Entrada...",, { || MSExecAuto( { | w, x, y, z | MATA103( w, x, y, z ) }, aCabec, aItens, 3, .T. ) } )
	
      If lMsErroAuto
		  MostraErro()
		  MsgAlert("Erro na inclusão dos dados do XML.")
		  Return .T.
	  Else

         // Altera o status do documento importado

         cSql := ""
         cSql := "UPDATE " + RetSqlName("ZT8")
         cSql += "   SET "
         cSql += "   ZT8_STAT = 'E'"
         cSql += " WHERE ZT8_CHAV = '" + Alltrim(_Danfe) + "'"

         lResult := TCSQLEXEC(cSql)
      
         If lResult < 0
            Return MsgStop("Erro ao gravar o Status da Documento: " + TCSQLError())
         EndIf 
          
         // MsgAlert("XML importado com sucesso.")
   	     // Chama o programa da pré-nota
         // A103NFiscal("SF1",,4)

      EndIf

*/



      oDlg:END()

   Endif

  

Return .T.

// Função que abre a janela para usuário selecionar o pedido de compra a ser utilizado na importação
Static Function ABREPEDCOMPRA(__PartNumber, __NomeProduto)

   Local cSql       := ""
   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1
   Local nContar    := 0
   Local xx_Produto := __NomeProduto

   Local aPesquisar := {}

   Private wFornecedor  := cFornece
   Private wLoja        := cLoja
   Private wNomeForne   := Posicione('SA1', 1, xFilial('SA1') + wFornecedor + wLoja, 'A1_NOME')
   Private wPartNumber  := __PartNumber
   Private wNomeProduto := __NomeProduto

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5   

   Private oDlgPC

   Private aProdutosPC := {}
   Private oProdutosPC

   Private oOk := LoadBitmap( GetResources(), "LBOK" )
   Private oNo := LoadBitmap( GetResources(), "LBNO" )

   // Se partNumber estiver em branco, retorna
   If Empty(Alltrim(__PartNumber))
      xx_Codigo := "|||"
      Return(.T.)
   Endif

   // Carrega o array aPesquisar com os possíveis códigos a serem pesquisados pelo part number do produto
   // Isso é necessário pois existem fornecedores que informam o part number no código do produto e outro na descrição do produto
   aPesquisar := {}
   
   aAdd( aPesquisar, Alltrim(wPartNumber) )
   
   xx_Produto := StrTran(wNomeProduto, " ", "|") + "|"
   
   For nContar = 1 to U_P_OCCURS(xx_Produto,"|", 1)
   
       aAdd( aPesquisar, U_P_CORTA(xx_Produto, "|", nContar) )
       
   Next nContar    

   // Pesquisa os produtos do pedido selecionado
   For nContar = 1 to Len(aPesquisar)

       If Select("T_PCOMPRAS") <>  0
          T_PCOMPRAS->(DbCloseArea())
       EndIf

       cSql := ""
       cSql := "SELECT C7_FILIAL ,"
       cSql += "       C7_NUM    ,"
       cSql += "	   SUBSTRING(C7_EMISSAO,07,02) + '/' + SUBSTRING(C7_EMISSAO,05,02) + '/' + SUBSTRING(C7_EMISSAO,01,04) AS EMISSAO,"
       cSql += "	   C7_FORNECE,"
       cSql += "	   C7_LOJA   ,"
       cSql += "	   C7_QUANT  ,"
       cSql += "	   C7_QUJE   ,"
       cSql += "	  (C7_QUANT - C7_QUJE) AS SALDO,"
       cSql += "	   C7_RESIDUO,"
       cSql += "	   C7_PARTNUM,"
       cSql += "	   C7_PRODUTO,"
       cSql += "       C7_ITEM   ,"
       cSql += "	   C7_DESCRI ,"
       cSql += "       C7_UM      "
       cSql += "  FROM " + RetSqlName("SC7")
       cSql += " WHERE C7_FILIAL   = '" + Alltrim(cFilAnt) + "'"
       cSql += "   AND C7_QUANT   <> C7_QUJE"
       cSql += "   AND D_E_L_E_T_  = ''"
       cSql += "   AND C7_FORNECE  = '" + Alltrim(wFornecedor) + "'"
       cSql += "   AND C7_LOJA     = '" + Alltrim(wLoja)       + "'"
       cSql += "   AND C7_PARTNUM  = '" + Alltrim(aPesquisar[nContar]) + "'"
       cSql += "   AND C7_RESIDUO <> 'S'

       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PCOMPRAS",.T.,.T.)

       T_PCOMPRAS->( DbGoTop() )
   
       If T_PCOMPRAS->( EOF() )
          Loop
       Endif   
          
       WHILE !T_PCOMPRAS->( EOF() )
   
          aAdd( aProdutosPC, { .F.                   ,;
                              T_PCOMPRAS->C7_NUM    ,;
                              T_PCOMPRAS->C7_PARTNUM,;
                              T_PCOMPRAS->C7_ITEM   ,;
                              T_PCOMPRAS->C7_PRODUTO,;
                              T_PCOMPRAS->C7_DESCRI ,;
                              T_PCOMPRAS->C7_UM     ,;
                              T_PCOMPRAS->C7_QUANT  ,;
                              T_PCOMPRAS->C7_QUJE   ,;
                              T_PCOMPRAS->SALDO } )

         T_PCOMPRAS->( DbSkip() )
      
      Enddo
      
   Next nContar
                                 
   If Len(aProdutosPC) == 0
      aAdd( aProdutosPC, { .F., "", "", "", "", "", "", "", "", "" } )
      xx_Codigo := "|||"
      Return(.T.)
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgPC TITLE "Pedidos de Compras" FROM C(178),C(181) TO C(562),C(831) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlgPC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(318),C(001) PIXEL OF oDlgPC
   
   @ C(022),C(223) Say "Pedidos de Compra em Aberto para o Fornecedor" Size C(118),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(036),C(005) Say "Fornecedor"                                    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(059),C(005) Say "Produto"                                       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   @ C(083),C(005) Say "Pedidos de Compra em Aberto"                   Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgPC
   
   @ C(045),C(005) MsGet oGet1 Var wFornecedor  Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC When lChumba
   @ C(045),C(034) MsGet oGet2 Var wLoja        Size C(018),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC When lChumba
   @ C(045),C(055) MsGet oGet3 Var wNomeForne   Size C(265),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC When lChumba
   @ C(068),C(005) MsGet oGet4 Var wPartNumber  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC When lChumba
   @ C(068),C(069) MsGet oGet5 Var wNomeProduto Size C(251),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPC When lChumba

   @ C(176),C(244) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgPC ACTION( FechaJanPC(1, aProdutosPC) )
   @ C(176),C(283) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgPC ACTION( FechaJanPC(2, aProdutosPC) )

   // Cria a Lista de documento9s a serem esolhidos
   @ 115,005 LISTBOX oProdutosPC FIELDS HEADER "M", "Nº Pedido", "Part Number", "Item", "Código", "Descrição dos Produtos", "Und", "Qtd Sol.", "Qtd Aten.", "Saldo"  PIXEL SIZE 403,105 OF oDlgPC ;                           
             ON dblClick(aProdutosPC[oProdutosPC:nAt,1] := !aProdutosPC[oProdutosPC:nAt,1],oProdutosPC:Refresh())     

   oProdutosPC:SetArray( aProdutosPC )

   oProdutosPC:bLine := {||  {Iif(aProdutosPC[oProdutosPC:nAt,01],oOk,oNo),;
            		              aProdutosPC[oProdutosPC:nAt,02],;
         	         	          aProdutosPC[oProdutosPC:nAt,03],;
         	         	          aProdutosPC[oProdutosPC:nAt,04],;
         	         	          aProdutosPC[oProdutosPC:nAt,05],;
         	         	          aProdutosPC[oProdutosPC:nAt,06],;         	         	                    	         	           
         	         	          aProdutosPC[oProdutosPC:nAt,07],;
         	         	          aProdutosPC[oProdutosPC:nAt,08],;
         	         	          aProdutosPC[oProdutosPC:nAt,09],;
         	         	          aProdutosPC[oProdutosPC:nAt,10]}}

   ACTIVATE MSDIALOG oDlgPC CENTERED 

Return(.T.)

// Função que prepara o retorno da função carrega produtos do pedido de compra
Static Function FechaJanPC(__Botao, aProdutosPC)

   Local nContar     := 0
   Local nMarcados   := 0
   Local xRetorno    := ""
   Local lPrimeiro   := .T.
   Local lDiferentes := .F.
   Local __Produto   := ""

   // Realiza consistência em caso de seleção do botão Confirmar
   If __Botao == 1

      // Verifica se houve marcação de pelo menos um produto do array aProdutosPC
      nMarcados := 0
      For nContar = 1 to Len(aProdutosPC)
          If aProdutosPC[nContar,01] == .T.
             nMarcados := nMarcados + 1
          Endif
      Next nContar
   
      If nMarcados == 0
         MsgAlert("Atenção! Nenhum produto foi selecionado. Verifique")
         Return(.T.)
      Endif
   
      If nMarcados > 1
         MsgAlert("Atenção! Somente permitido a marcação de um produto. Verifique!")
         Return(.T.)
      Endif

//      // Se foi marcado mais do que um produto de pedido de compra, verifica se as caractrísticas são iguais
//      lPrimeiro   := .T.
//      lDiferentes := .F.
//      __Produto   := ""
//      For nContar = 1 to Len(aProdutosPC)
//          If aProdutosPC[nContar,01] == .T.
//             If lPrimeiro == .T.
//                __Produto := aProdutosPC[nContar,02]
//                lPrimeiro := .F.
//             Else
//                If Alltrim(aProdutosPC[nContar,02]) <> Alltrim(__Produto)
//                   lDiferentes := .T.
//                   Exit
//                Endif
//             Endif
//          Endif
//      Next nContar
//      
//      If lDiferentes == .T.
//         MsgAlert("Atenção! Produtos selecionados possuem características difeentes entre si. Verifique!")
//         Return(.T.)
//      Endif
      
      // Captura os valores para retorno
      xRetorno := ""
      For nContar = 1 to Len(aProdutosPC)
          If aProdutosPC[nContar,01] == .T.
             xRetorno := aProdutosPC[nContar,05] + "|" + ;
                         aProdutosPC[nContar,02] + "|" + ;
                         aProdutosPC[nContar,04] + "|"
             Exit
          Endif
      Next nContar
      
   Else

      xRetorno := "|||"
   
   Endif

   xx_Codigo := xRetorno 

   oDlgPC:End() 
      
Return(.T.)

// Função que abre a janela de cadastramento do produto x fornecedor
Static Function PROXFORNE( v_codigo, v_descricao)

   Local lChumba   := .F.

   Private cCodFor := v_codigo
   Private cNomFor := v_descricao
   Private cCodPro := Space(25)
   Private cNomPro := Space(25)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgFP

   DEFINE MSDIALOG oDlgFP TITLE "Vínculo Produto X Fornecedor" FROM C(178),C(181) TO C(446),C(690) PIXEL

   @ C(005),C(006) Say "Atenção !! O produto abaixo relacionado não está cadastrado na tabela de Produtos X Fornecedores." Size C(247),C(008) COLOR CLR_BLACK PIXEL OF oDlgFP
   @ C(018),C(006) Say "Codigo do Produto do Fornecedor"    Size C(083),C(008) COLOR CLR_BLACK PIXEL OF oDlgFP
   @ C(041),C(006) Say "Descrição do Produto do Fornecedor" Size C(093),C(008) COLOR CLR_BLACK PIXEL OF oDlgFP
   @ C(066),C(006) Say "Nosso Código do Produto"            Size C(065),C(008) COLOR CLR_BLACK PIXEL OF oDlgFP
   @ C(089),C(006) Say "Descrição Nosso Produto"            Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgFP
   
   @ C(028),C(006) MsGet oGet1 Var cCodFor When lChumba Size C(094),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFP
   @ C(050),C(006) MsGet oGet2 Var cNomFor When lChumba Size C(238),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFP
   @ C(076),C(006) MsGet oGet3 Var cCodPro              Size C(094),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFP F3('SB1') VALID(BPROXFORNE(cCodPro))
   @ C(098),C(006) MsGet oGet4 Var cNomPro When lChumba Size C(238),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgFP 

   @ C(115),C(085) Button "Confirma" Size C(037),C(012) PIXEL OF oDlgFP ACTION( GPROXFORNE() )
   @ C(115),C(124) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgFP ACTION( oDlgFP:End() )

   ACTIVATE MSDIALOG oDlgFP CENTERED 

Return(.T.)

// Função que pesquisa o produto informado na tela de produtos x fornecedores
Static Function BPROXFORNE(v_produto)

   Local cSql := ""
   
   If Empty(Alltrim(v_produto))
      cNomPro := ""
      Return .T.
   Endif

   If Select("T_MATERIAL") <>  0
      T_MATERIAL->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT B1_DESC,"
   cSql += "       B1_DAUX "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD = '" + Alltrim(v_produto) + "'"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAL",.T.,.T.)
   
   If T_MATERIAL->( EOF() )
      cNomPro := ""
   Else
      cNomPro := Alltrim(T_MATERIAL->B1_DESC) + " " + Alltrim(T_MATERIAL->B1_DAUX)
   Endif
   
Return .T.

// Função que grava o produto do vínculo de produto x fornecedor
Static Function GPROXFORNE()

   Local aRotAuto    := {}
   Local lMsErroAuto := .F.  

   If Empty(Alltrim(cCodPro))
      MsgAlert("Nosso código de produto não informado.")
      Return .T.
   Endif

   // Verifica se o código informado já está cadastrado para o fornecedor
   If Select("T_JAEXISTE") <>  0
      T_JAEXISTE->(DbCloseArea())
   EndIf

   cSql := "SELECT A5_FILIAL ,"
   cSql += "       A5_FORNECE,"
   cSql += "       A5_LOJA   ,"
   cSql += "       A5_PRODUTO "
   cSql += "  FROM " + RetSqlName("SA5")
   cSql += " WHERE A5_FILIAL    = '" + Alltrim(cFilAnt)  + "'"
   cSql += "   AND A5_FORNECE   = '" + Alltrim(cFornece) + "'"
   cSql += "   AND A5_LOJA      = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND A5_PRODUTO   = '" + Alltrim(cCodPro)  + "'"
   cSql += "   AND R_E_C_D_E_L_ = ''"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_JAEXISTE",.T.,.T.)

   IF !T_JAEXISTE->( EOF() )
      MsgAlert("Produto informado já cadastrado para este Fornecedor.")
      Return .T.
   Endif

   // Carrega o array para execusão do MSExecAuto
   aRotAuto := { {'A5_FILIAL' , cFilAnt  , Nil},;
                 {'A5_FORNECE', cFornece , Nil},;
                 {'A5_LOJA'   , cLoja    , Nil},;
                 {'A5_NOMEFOR', cNfornece, Nil},;
                 {'A5_PRODUTO', cCodPro  , Nil},;
                 {'A5_NOMPROD', cNomPro  , Nil},;
                 {'A5_CODPRF' , cCodFor  , Nil}}

   // Grava os dados da Pré-nota de entrada
   MSExecAuto({|x,y| MATA060(x,y)}, aRotAuto, 3)     

   If lMsErroAuto
      MostraErro()
      MsgAlert("Erro na inclusão do Produto em Produtos X Fornecedores.")
      cIncPro := .F.
      cProInc := ""
      Return .T.
   Else
      cIncPro := .T.
      cProInc := cCodPro
   EndIf

   oDlgFP:End()
   
Return .T.

// Função que abre a janela de informação do centro de custo
Static Function ABRCCUSTO()

   Local lChumba    := .F.
   Local cMemo1	    := ""
   Local oMemo1

   Private cPerc1   := 0
   Private cPerc2   := 0
   Private cPerc3   := 0
   Private cPerc4   := 0
   Private cPerc5   := 0

   Private cCusto1  := Space(09)
   Private cCusto2  := Space(09)
   Private cCusto3  := Space(09)
   Private cCusto4  := Space(09)
   Private cCusto5  := Space(09)

   Private cDescri1 := Space(60)
   Private cDescri2 := Space(60)
   Private cDescri3 := Space(60)
   Private cDescri4 := Space(60)
   Private cDescri5 := Space(60)

   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9

   Private oDlgC

   // Carrega do array aCustos os valores a serem visualizados na tela de Rateio por Centros de Custo
   For nContar = 1 to Len(aCustos)
       j := Strzero(nContar,1)     
       cPerc&j   := aCustos[nContar,01]
       cCusto&j  := aCustos[nContar,02]
       cDescri&j := aCustos[nContar,03]
   Next nContar

   // Desenha a tela de Rateio por Centros de Custo
   DEFINE MSDIALOG oDlgC TITLE "Informação Centro de Custo" FROM C(178),C(181) TO C(444),C(665) PIXEL


   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(235),C(001) PIXEL OF oDlgC

   @ C(039),C(005) Say "Perc."   Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(039),C(032) Say "C.Custo" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(049),C(005) MsGet oGet1  Var cPerc1   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(049),C(033) MsGet oGet2  Var cCusto1  Size C(010),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto1, 1))
   @ C(049),C(067) MsGet oGet3  Var cDescri1 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(062),C(005) MsGet oGet4  Var cPerc2   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(062),C(033) MsGet oGet8  Var cCusto2  Size C(020),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto2, 2))
   @ C(062),C(067) MsGet oGet12 Var cDescri2 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(075),C(005) MsGet oGet5  Var cPerc3   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(075),C(033) MsGet oGet9  Var cCusto3  Size C(020),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto3, 3))
   @ C(075),C(067) MsGet oGet13 Var cDescri3 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(088),C(005) MsGet oGet6  Var cPerc4   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(088),C(033) MsGet oGet10 Var cCusto4  Size C(020),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto4, 4))
   @ C(088),C(067) MsGet oGet14 Var cDescri4 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba
   @ C(101),C(005) MsGet oGet7  Var cPerc5   Size C(022),C(009) COLOR CLR_BLACK Picture "@E 999.99" PIXEL OF oDlgC
   @ C(101),C(033) MsGet oGet11 Var cCusto5  Size C(020),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC F3("CTT") VALID(TRZCTT(cCusto5, 5))
   @ C(101),C(067) MsGet oGet15 Var cDescri5 Size C(169),C(009) COLOR CLR_BLACK Picture "@!"        PIXEL OF oDlgC When lChumba

   @ C(115),C(160) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgC ACTION( ConfRateio() )
   @ C(115),C(199) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgC ACTION( ODlgC:End() )

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que pesquisa o centro de custo informado
Static Function TRZCTT(_Codigo, _Tipo)

   Local cSql := ""

   If Empty(Alltrim(_Codigo))
      Return(.T.)
   Endif
      
   If Select("T_CUSTO") > 0
      T_CUSTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CTT_CUSTO,"
   cSql += "       CTT_DESC01"
   cSql += "  FROM " + RetSqlName("CTT")
   cSql += " WHERE CTT_BLOQ  <> '1'"
   cSql += "   AND D_E_L_E_T_ = '' "
   cSql += "   AND CTT_CUSTO  = '" + Alltrim(_Codigo) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSTO", .T., .T. )

   If T_CUSTO->( EOF() )
      MsgAlert("Centro de Custo informado não cadastrado.")
      Return(.T.)
   Endif
   
   Do Case
      Case _Tipo == 1
           cDescri1 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 2
           cDescri2 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 3
           cDescri3 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 4
           cDescri4 := T_CUSTO->CTT_DESC01   
      Case _Tipo == 5
           cDescri5 := T_CUSTO->CTT_DESC01   
   EndCase
   
Return(.T.)

// Função que confere os centro de custos informados
Static Function ConfRateio()

   If (cPerc1 + cPerc2 + cPerc3 + cPerc4 + cPerc5) == 0
      MsgAlert("Nenhum rateio foi informado. Verifique!")
      Return(.T.)
   Endif

   If (cPerc1 + cPerc2 + cPerc3 + cPerc4 + cPerc5) <> 100
      MsgAlert("Percentual de rateio por centro de custo inconsistente. Verifique!")
      Return(.T.)
   Endif
      
   If cPerc1 <> 0
      If Empty(Alltrim(cCusto1))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif
         
   If cPerc2 <> 0
      If Empty(Alltrim(cCusto2))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If cPerc3 <> 0
      If Empty(Alltrim(cCusto3))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If cPerc4 <> 0
      If Empty(Alltrim(cCusto4))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If cPerc5 <> 0
      If Empty(Alltrim(cCusto5))
         MsgAlert("Atenção! Existem Rateios sem informação de centro de custo. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto1))
      If cPerc1 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif
      
   If !Empty(Alltrim(cCusto2))
      If cPerc2 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto3))
      If cPerc3 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto4))
      If cPerc4 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   If !Empty(Alltrim(cCusto5))
      If cPerc5 == 0
         MsgAlert("Atenção! Existem Centros de Custo sem informação de % de rateio. Verifique")
         Return(.T.)
      Endif
   Endif

   aCustos := {}
   
   aAdd( aCustos, { cPerc1, cCusto1, cDescri1 } )
   aAdd( aCustos, { cPerc2, cCusto2, cDescri2 } )
   aAdd( aCustos, { cPerc3, cCusto3, cDescri3 } )
   aAdd( aCustos, { cPerc4, cCusto4, cDescri4 } )
   aAdd( aCustos, { cPerc5, cCusto5, cDescri5 } )            

   oDLgc:End()

Return(.T.)

// Função que abre tela de visualização das variáveis de cálculo do ICMS ST dos produtos na nota fiscal
Static Function VarCalIST()

   Local cMemo1	      := ""
   Local oMemo1
   Local nICMSST      := 0

   Private aMaterial  := {}   
   Private cVariaveis := ""
   Private oVariaveis

   Private oFont01 := TFont():New( "Courier New",,18,,.f.,,,,.f.,.f. )

   // Declara as Legendas
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

   Private oDlgST
 
   // Carrega o array aMaterial
   For nContar = 1 to Len(aProdutos)

       // Calcula o valor do ICMS ST para carregar no array aMaterial
       If Select("T_CALCULO") <>  0
          T_CALCULO->(DbCloseArea())
       EndIf

       cSql := ""
       cSql := "SELECT SF7.F7_TIPOCLI,"
       cSql += "       SF7.F7_GRTRIB ,"
       cSql += "       SF7.F7_EST    ,"
       cSql += "       SF7.F7_GRPCLI ,"
  	   cSql += "       SF7.F7_MARGEM ,"
  	   cSql += "       SF7.F7_ALIQINT,"
       cSql += "       SF7.F7_ALIQDST,"
  	   cSql += "       SB1.B1_GRTRIB ,"
  	   cSql += "       SA2.A2_GRPTRIB "
       cSql += "  FROM " + RetSqlName("SF7") + " SF7, "
       cSql += "       " + RetSqlName("SB1") + " SB1, "
  	   cSql += "       " + RetSqlName("SA2") + " SA2  "
       cSql += " WHERE SF7.D_E_L_E_T_ = ''"
       cSql += "   AND SB1.B1_COD     = '" + Alltrim(aProdutos[nContar,02]) + "'"
       cSql += "   AND SB1.D_E_L_E_T_ = ''"
       cSql += "   AND SA2.A2_COD     = '" + Alltrim(cFornece) + "'"
       cSql += "   AND SA2.A2_LOJA    = '" + Alltrim(cLoja)    + "'"
       cSql += "   AND SA2.D_E_L_E_T_ = ''"   
       cSql += "   AND SF7.F7_GRTRIB  = SB1.B1_GRTRIB"
       cSql += "   AND SF7.F7_TIPOCLI = '*' "
       cSql += "   AND SF7.F7_EST     = '**'"
       cSql += "   AND SF7.F7_ALIQINT = '" + Alltrim(Str(aProdutos[nContar,10])) + "'"
       cSql += "   AND SF7.F7_GRPCLI  = SA2.A2_GRPTRIB"
   
       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CALCULO",.T.,.T.)

       If T_CALCULO->( EOF() )
          nICMSST := 0
       Else
          nBase01 := aProdutos[nContar,08] + aProdutos[nContar,14]
          nBase02 := (nBase01 * T_CALCULO->F7_MARGEM) / 100
          nBase03 := nBase02 + nBase01
          nBase04 := (nBase03 * T_CALCULO->F7_ALIQDST) / 100
          nICMSST := Round(nBase04 - aProdutos[nContar,11],2)
       Endif
       
       // Carrega o array aMaterial
       aAdd( aMaterial, { '1'                   ,; // 01
                          aProdutos[nContar,02] ,; // 02
                          aProdutos[nContar,03] ,; // 03            
                          aProdutos[nContar,21] ,; // 04               
                          nICMSST               ,; // 05
                          aProdutos[nContar,08] ,; // 06
                          aProdutos[nContar,14] ,; // 07
                          T_CALCULO->F7_MARGEM  ,; // 08
                          T_CALCULO->F7_ALIQDST ,; // 09
                          aProdutos[nContar,11] }) // 10
   Next nContar                          

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgST TITLE "Conferência Valor ICMS ST" FROM C(178),C(181) TO C(626),C(774) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(146),C(026) PIXEL NOBORDER OF oDlgST

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(292),C(001) PIXEL OF oDlgST

   @ C(036),C(005) Say "Produtos da Nota Fiscal"                                Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgST
   @ C(115),C(005) Say "Variáveis de cálculo do ICMS ST do produto selecionado" Size C(138),C(008) COLOR CLR_BLACK PIXEL OF oDlgST

   @ C(124),C(005) GET oVariaveis Var cVariaveis MEMO Size C(287),C(080) PIXEL OF oDlgST Font oFont01 

   @ C(208),C(255) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgST ACTION( oDlgST:End() )

   oMaterial := TCBrowse():New( 055 , 005, 368, 088,,{''                                   ,; // 01 - Legenda do Produto
                                                      'Codigo'                             ,; // 02 - Código do Produto
                                                      'Descrição dos Produtos' + Space(90) ,; // 03 - Descrição dos produtos
                                                      'ICMS ST'                            ,; // 04 - ICMS ST dos Produtos
                                                      'ST Calculado'}                      ,; // 05 - ICMS ST Calculado dos Produtos
                                                      {20,50,50,50},oDlgST,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oMaterial:SetArray(aMaterial) 

   oMaterial:bLine := {||{ If(Alltrim(aMaterial[oMaterial:nAt,01]) == "1", oBranco  ,;
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "2", oVerde   ,;
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "3", oPink    ,;                         
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "4", oAmarelo ,;                         
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "5", oAzul    ,;                         
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "6", oLaranja ,;                         
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "7", oPreto   ,;                         
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "8", oVermelho,;
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "X", oCancel  ,;
                           If(Alltrim(aMaterial[oMaterial:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                           aMaterial[oMaterial:nAt,02]               ,;
                           aMaterial[oMaterial:nAt,03]               ,;
                           aMaterial[oMaterial:nAt,04]               ,;                         
                           aMaterial[oMaterial:nAt,05]               }}
      
   oMaterial:bLDblClick := {|| MOSTRAST(aMaterial[oMaterial:nAt,02],;
                                        aMaterial[oMaterial:nAt,03],;
                                        aMaterial[oMaterial:nAt,06],;
                                        aMaterial[oMaterial:nAt,07],;
                                        aMaterial[oMaterial:nAt,08],;
                                        aMaterial[oMaterial:nAt,09],;
                                        aMaterial[oMaterial:nAt,10],;
                                        aMaterial[oMaterial:nAt,05]) } 

   ACTIVATE MSDIALOG oDlgST CENTERED 

Return(.T.)

// Função que carrega as variáveis de cálculo do ICMS ST dos produtos
Static Function MostraST(__Codigo, __Descricao, _ValorPro, _ValorIPI, _MVAPerct, _Aliquota, _IcmsPro, _ICMSST)

   Local cTexto := ""
   
   cTexto := ""
   cTexto += "DADOS DO PRODUTO"                                                                   + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)
   cTexto += "Código do Produto......: " + Alltrim(__Codigo)                                      + chr(13)
   cTexto += "Descrição do Produto...: " + Alltrim(__Descricao)                                   + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)
   cTexto += "VARIÁVEIS PARA CÁLCULO DO ICMS ST"                                                  + chr(13)   
   cTexto += Replicate("-",88)                                                                    + chr(13)
   cTexto += "Valor Total do Produto.: " + Str(_ValorPro,10,02)                                   + chr(13)
   cTexto += "Valor Total do IPI.....: " + Str(_ValorIPI,10,02)                                   + chr(13)
   cTexto += "% M V A ...............: " + Str(_MVAPerct,06,02) + " %"                            + chr(13)
   cTexto += "% ICMS Destino ........: " + Str(_Aliquota,06,02) + " %"                            + chr(13)
   cTexto += "Valor ICMS do Produto..: " + Str(_IcmsPro,10,02)                                    + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)   
   cTexto += "FÓRMULA"                                                                            + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)   
   cTexto += "nBase01 = Valor do Produto + Valor do IPI"                                          + chr(13)
   cTexto += "nBase02 = (nBase01 * % MVA) / 100"                                                  + chr(13)
   cTexto += "nBase03 = nBase02 + nBase01"                                                        + chr(13)
   cTexto += "nBase04 = (nBase03 * % Aliquota ICMS Destino) / 100"                                + chr(13)
   cTexto += "nICMSST = nBase04 - Valor do ICMS do Produto"                                       + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)   
   cTexto += "CÁLCULO"                                                                            + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)   
   cTexto += "nBase01 = " + Alltrim(Str(_ValorPro,10,02)) + " + " + Alltrim(Str(_ValorIPI,10,02)) + chr(13)
   cTexto += "nBase02 = (nBase01 * " + Alltrim(Str(_MVAPerct,06,02)) + ") / 100"                  + chr(13)
   cTexto += "nBase03 = nBase02 + nBase01"                                                        + chr(13)
   cTexto += "nBase04 = (nBase03 * " + Alltrim(Str(_Aliquota,06,02)) + ") / 100"                  + chr(13)
   cTexto += "nICMSST = nBase04 - " + Alltrim(Str(_IcmsPro,10,02))                                + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)   
   cTexto += "VALOR DO ICMS ST"                                                                   + chr(13)
   cTexto += Replicate("-",88)                                                                    + chr(13)   
   cTexto += "Valor ICMS ST R$ " + Alltrim(Str(Round(_Icmsst,2),10,02))                           + chr(13)

   cVariaveis := cTexto
   oVariaveis:Refresh()

Return(.T.)

// Função que mostra valores da 2ª Moeda
Static Function VeSegMoeda()

   Local cMemo1	 := ""
   Local oMemo1
   Local nContar := 0

   Private aDolar := {}

   Private oDlgDolar

   aDolar := {}

   // Carrega o array aDolar com os dados dos produtos da nota fiscal
   For nContar = 1 to Len(aProdutos)

       // Se produto não estiver associado a um pedido de compra, despreza
       If Empty(Alltrim(aProdutos[nContar,15]))
          Loop
       Endif

       // Data de emissão do pedido de compra
       _Emissao    := U_P_CORTA(aProdutos[nContar,15], "|", 2)

       // Pesquisa a taxa do Dolar pela data de emissão do pedido de compra
       If Select("T_TAXA1") <>  0
          T_TAXA1->(DbCloseArea())
       EndIf

       cSql := ""
       cSql := "SELECT M2_MOEDA2"
       cSql += "  FROM " + RetSqlName("SM2")
       cSql += " WHERE M2_DATA    = '" + Substr(_Emissao,07,04) + Substr(_Emissao,04,02) + Substr(_Emissao,01,02) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TAXA1",.T.,.T.)

       // Pesquisa a taxa do Dolar pela data de emissão da nota fiscal
       If Select("T_TAXA2") <>  0
          T_TAXA2->(DbCloseArea())
       EndIf

       cSql := ""
       cSql := "SELECT M2_MOEDA2"
       cSql += "  FROM " + RetSqlName("SM2")
       cSql += " WHERE M2_DATA    = '" + Substr(Dtoc(cEmissao),07,04) + Substr(Dtoc(cEmissao),04,02) + Substr(Dtoc(cEmissao),01,02) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
   
       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TAXA2",.T.,.T.)
 
       // Captura o Pedido de Compra
       _PCompra    := U_P_CORTA(aProdutos[nContar,15], "|", 1)

       // Captura o Código da Moeda
       _Moeda      := U_P_CORTA(aProdutos[nContar,15], "|", 3)

       // Captura o Preço Unitário do Produto do pedido de compra
       _UnitarioUS := Val(U_P_CORTA(aProdutos[nContar,15], "|", 4))
       
       // Prepara o valor em R$ para gravação
       _TReal    := IIF(Int(Val(Substr(aProdutos[nContar,15],23,02))) == 1, aProdutos[nContar,08], Round((_UnitarioUS * T_TAXA1->M2_MOEDA2),2) )         

       // Carrega o array aDolar com os dados a serem visualizados
       aAdd( aDolar, { aProdutos[nContar,01]                         ,; // 01
                       aProdutos[nContar,02]                         ,; // 02
                       aProdutos[nContar,03]                         ,; // 03
                       _PCompra                                      ,; // 04
                       _Emissao                                      ,; // 05
                       _Moeda                                        ,; // 06
                       T_TAXA1->M2_MOEDA2                            ,; // 07
                       _UnitarioUS                                   ,; // 08
                       _TReal                                        ,; // 09
                       aProdutos[nContar,08]                         ,; // 10
                       T_TAXA2->M2_MOEDA2                            ,; // 11
                      (T_TAXA1->M2_MOEDA2 - T_TAXA2->M2_MOEDA2)      ,; // 12
                      (_TReal - aProdutos[nContar,08])})                // 13

   Next nContar

   If Len(aDolar) == 0
      aAdd( aDolar, { "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif
   
   // Desenha a tela para visualização dos dados
   DEFINE MSDIALOG oDlgDolar TITLE "Consistência Valor U$" FROM C(178),C(181) TO C(530),C(917) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgDolar

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(361),C(001) PIXEL OF oDlgDolar

   @ C(023),C(297) Say "CONSISTÊNCIA VALOR 2ª MOEDA" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgDolar
   @ C(034),C(005) Say "Produtos da Nota Fiscal"     Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgDolar

   @ C(159),C(327) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDolar ACTION( oDlgDolar:End() )

   // Desenha o Browse
   oDolar := TCBrowse():New( 056 , 005, 460, 143,,{'Item'                    ,; // 01 - Item
                                                   'Código'                  ,; // 02 - Código do Produto
                                                   'Descrição dos Produtos'  ,; // 03 - Descrição dos Produtos
                                                   'Ped.Compra'              ,; // 04 - Nº Pedido de Compra
                                                   'Data'                    ,; // 05 - Nº do NCM do Produto
                                                   'Moeda'                   ,; // 06 - Unidade de Medida do Produto
                                                   'Taxa U$'                 ,; // 07 - Quantidade do Produto
                                                   'Valor Unit. U$ PC'       ,; // 08 - Preço Unitário
                                                   'Valor Unit. R$ PC'       ,; // 09 - Valor Total do Produto
                                                   'Valor Unit. R$ NF'       ,; // 10 - Base do ICMS
                                                   'Taxa U$ NF'              ,; // 11 - % do ICMS
                                                   'Dif. U$'                 ,; // 12 - Valor do ICMS
                                                   'Dif. R$'                  ; // 13 - Base do IPI
                                                    },{20,50,50,50},oDlgDolar,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oDolar:SetArray(aDolar) 
    
   // Monta a linha a ser exibina no Browse
   oDolar:bLine := {||{ aDolar[oDolar:nAt,01],;
                        aDolar[oDolar:nAt,02],;
                        aDolar[oDolar:nAt,03],;
                        aDolar[oDolar:nAt,04],;
                        aDolar[oDolar:nAt,05],;
                        aDolar[oDolar:nAt,06],;
                        aDolar[oDolar:nAt,07],;
                        aDolar[oDolar:nAt,08],;
                        aDolar[oDolar:nAt,09],;
                        aDolar[oDolar:nAt,10],;
                        aDolar[oDolar:nAt,11],;
                        aDolar[oDolar:nAt,12],;
                        aDolar[oDolar:nAt,13]}}

   ACTIVATE MSDIALOG oDlgDolar CENTERED 

Return(.T.)


          /*

          // Pesquisa o grupo do produto e o tipo de produto para gravação
          If Select("T_MATERIAL") <>  0
             T_MATERIAL->(DbCloseArea())
          EndIf

          cSql := ""
          cSql := "SELECT B1_GRUPO,"
          cSql += "       B1_TIPO  "
          cSql += "  FROM " + RetSqlName("SB1")
          cSql += " WHERE B1_COD = '" + Alltrim(aProdutos[nContar,2]) + "'"
   
          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_MATERIAL",.T.,.T.)


          aAdd(aItens, {{'D1_COD'    , aProdutos[nContar,2] 	   ,NIL},;   // 01
                       {'D1_FILIAL' , '01' 	   ,NIL},;   // 01
                       {'D1_NUMSEQ' , '114032' 	   ,NIL},;   // 01
                       {'D1_CLASFIS' , '010' 	   ,NIL},;   // 01                     
                       {'D1_RATEIO' , '2' 	   ,NIL},;   // 01                     
                       {'D1_ITEM'   , aProdutos[nContar,1] 	   ,NIL},;   // 01
	    	           {'D1_UM'	  , aProdutos[nContar,5]	   ,NIL},;   // 02
		               {'D1_QUANT'  , Val(aProdutos[nContar,6])  ,NIL},;   // 03
		               {'D1_VUNIT'  , aProdutos[nContar,7]       ,NIL},;   // 04
    		           {'D1_TOTAL'  , aProdutos[ nContar,8]      ,NIL},;   // 05
                       {'D1_VALICM' , Val(aProdutos[nContar,11]) ,NIL},;   // 06
                       {'D1_ICMSRET', Val(aProdutos[nContar,21]) ,NIL},;   // 07
                       {'D1_TES'    , '200'      ,NIL},;   // 13   -005
                       {'D1_CF'     , '2403'      ,NIL},;   // 14
	    	           {'D1_DOC'    , cNota                      ,Nil},;   // 18
	    	           {'D1_EMISSAO', '20121113'                   ,Nil},;   // 19
	    	           {'D1_DTDIGIT', '20121119'                  ,Nil},;   // 20
	    	           {'D1_TIPO'   , 'N'                        ,Nil},;   // 21
	    	           {'D1_SERIE'  , cSerie                     ,Nil},;   // 22
	    	           {'D1_FORNECE', cFornece                   ,Nil},;   // 23
	    	           {'D1_LOJA'   , cLoja                      ,Nil},;   // 24
                       {'D1_BRICMS' , Val(aProdutos[nContar,19]) ,NIL},;   // 08
                       {'D1_BASEICM', Val(aProdutos[nContar,09]) ,NIL},;   // 09
                       {'D1_BASEIPI', Val(aProdutos[nContar,12]) ,NIL},;   // 10
                       {'D1_VALIPI' , Val(aProdutos[nContar,14]) ,NIL},;   // 12
                       {'D1_IPI'    , Val(aProdutos[nContar,13]) ,NIL},;   // 15
                       {'D1_PICM'   , Val(aProdutos[nContar,10]) ,NIL},;   // 16
	    	           {'D1_LOCAL'  , Posicione('SB1', 1, xFilial('SB1') + aProdutos[nContar,2], 'B1_LOCPAD'),NIL},; // 17
	    	           {'D1_GRUPO'  , T_MATERIAL->B1_GRUPO       ,Nil},;   // 27
	    	           {'D1_TP'     , T_MATERIAL->B1_TIPO        ,Nil}})   // 28 


  //	    	       {'D1_EMISSAO', cEmissao                   ,Nil},;   // 19
  //    	           {'D1_DTDIGIT', dDataBase                  ,Nil},;   // 20

  //                   {'D1_ALIQSOL', 0                          ,NIL},;   // 11
  //                   {'D1_TES'    , aProdutos[nContar,17]      ,NIL},;   // 13
  //                   {'D1_CF'     , aProdutos[nContar,18]      ,NIL},;   // 14

                     */


/*




Tipo da Nota        - F1_TIPO      := B
Form. Prop.          - F1_FORMUL    := N
Numero               - F1_DOC       := 014056
Serie               - F1_SERIE     := 1
DT Emissao           - F1_EMISSAO   := 04/05/2012
Fornecedor           - F1_FORNECE   := 003070
Loja                 - F1_LOJA      := 01
Cond. Pagto          - F1_COND      := 001
Espec.Docum.        - F1_ESPECIE   := NF
--------------------------------------------------------------------------------
Tabela SD1 04/05/2012 14:59:20
Erro no Item   1
--------------------------------------------------------------------------------
Item NF              - D1_ITEM      := 0001
Filial               - D1_FILIAL    := 02
Produto              - D1_COD       := 14069002       
Unidade              - D1_UM        := CJ
Quantidade           - D1_QUANT     := 15
Vlr.Unitario        - D1_VUNIT     := 25
Vlr.Total            - D1_TOTAL     := 375
Armazem              - D1_LOCAL     := 01
Tipo Entrada        - D1_TES       := 023
Desc.Item            - D1_DESC      := 0
Desconto             - D1_VALDESC   := 0
Forn/Cliente        - D1_FORNECE   := 003070
Loja                 - D1_LOJA      := 01
Documento            - D1_DOC       := 014056
Serie               - D1_SERIE     := 1
Grupo               - D1_GRUPO     := 123 
Tipo Docto.          - D1_TIPO      := B
Tipo Produto        - D1_TP        := PA
Docto. Orig.        - D1_NFORI     := 013358   
Serie Orig.          - D1_SERIORI   := 1 
Data da NF O        - D1_DATORI    := 05/04/2012
It.Doc Orig.        - D1_ITEMORI   := 01
Item Conta           - D1_ITEMCTA   :=          
Erro --> Inconsistencia na Linha de Itens

*/





// Função que pesquisa o XML no Sefaz
Static Function PesqSefaz( cChaveNFe )


   Private lErrSef
   Private cMensagem := ""

   lErrSef := ConsNFeChave( cChaveNFe, "000001", .F., @cMensagem )

   If !lErrSef // Se não houve problema 
      MsgAlert("Nota OK")
   Else
      MsgAlert(cMensagem)
   EndIf
   
Return(.T.)

// Efetua a consulta do xml na Sefaz
Static Function ConsNFeChave( cChaveNFe, cIdEnt, lWeb, cMensagem )

	Local cURL      := PadR( GetNewPar("MV_SPEDURL","http://"), 250 )
	Local lErro     := .F.
	Local oWS

	If ValType( lWeb ) == 'U'
		lWeb := .F.
	EndIf
	
	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	ows:cCHVNFE	   := cChaveNFe
	oWs:_URL       := AllTrim( cURL )+"/NFeSBRA.apw"
	
	If oWs:ConsultaChaveNFE()
	
		cMensagem := ""
		
		If !Empty( oWs:oWSCONSULTACHAVENFERESULT:cVERSAO )
			cMensagem += "Versão da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf
		cMensagem += "Ambiente: "+ IIf( oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE == 1, "Produção", "Homologação" ) + CRLF
		cMensagem += "Cod.Ret.NFe: "+ oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE + CRLF
		cMensagem += "Msg.Ret.NFe: "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE + CRLF
		If !Empty( oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO )
			cMensagem += "Protocolo: "+ oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO + CRLF
		EndIf
		cMensagem += "Chave Consultada: "+ cChaveNFe + CRLF
		
		//QUANDO NAO ESTIVER OK NAO IMPORTA, CODIGO DIFERENTE DE 100
		If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE != "100"
			lErro := .T.
		EndIf
	
		If !lWeb
			Aviso( "Consulta NF", cMensagem, {"Ok"}, 3 )
		Else
			Return( { lErro, cMensagem } )
		EndIf
	
	Else
		Aviso( "SPED", IIf( Empty( GetWscError( 3 ) ), GetWscError( 1 ), GetWscError( 3 ) ), {"Ok"}, 3 )
		lErro := .T.
	EndIf

Return( lErro )

// ###########################################################
// Função que solicita o tipo de importação a ser utilizada ##
// ###########################################################
Static Function PEDETIPOIMP()

   Local cMemo1	    := ""
   Local cMemo2	    := ""
   Local nRadioGrp1	:= 0
   Local oMemo1
   Local oMemo2
   Local oRadioGrp1

   Private oDlgTI

   lTipoImp := 0

   DEFINE MSDIALOG oDlgTI TITLE "Importação XML's" FROM C(178),C(181) TO C(406),C(479) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(140),C(026) PIXEL NOBORDER OF oDlgTI

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(143),C(001) PIXEL OF oDlgTI
   @ C(092),C(002) GET oMemo2 Var cMemo2 MEMO Size C(143),C(001) PIXEL OF oDlgTI
   
   @ C(036),C(005) TO C(090),C(144) LABEL "Informe o tipo de importação de XML a ser utilizado" PIXEL OF oDlgTI
   @ C(040),C(008) Radio oRadioGrp1 Var nRadioGrp1 Items "Compras com OC","Despesas","Remessas","Devoluções" 3D Size C(090),C(050) PIXEL OF oDlgTI

   @ C(097),C(035) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgTI ACTION( lTipoImp := nRadioGrp1, oDlgTI:End() )
   @ C(097),C(073) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgTI ACTION( lTipoImp := 0         , oDlgTI:End() )

   ACTIVATE MSDIALOG oDlgTI CENTERED 

Return(.T.)

// ###########################################################################################
// Função que realiza o relacionamento dos produtos da NFe com produtos do Sistema Protheus ##
// ###########################################################################################
Static Function RelProDespesas()

   Local cMemo1	 := ""
   Local oMemo1

   Local nContar := 0

   Private oDlgRel

   Private aRelacao := {}           
   Private oRelacao

   // ###########################
   // Carrega o array aRelacao ##
   // ###########################
   For nContar = 1 to Len(aProdutos)
   
       // #################################################################################
       // Verifica se o produto já está cadastrado na tebela Produtos X Fornecedor (SA5) ##
       // #################################################################################
       If Select("T_PRODFORNECE") <>  0
          T_PRODFORNECE->(DbCloseArea())
       EndIf

       cSql := ""                                                                                           
       cSql := "SELECT A5_FILIAL ,"
       cSql += "       A5_FORNECE,"
   	   cSql += "       A5_LOJA   ,"
	   cSql += "       A5_NOMEFOR,"
	   cSql += "       A5_PRODUTO,"
	   cSql += "       A5_NOMPROD,"
	   cSql += "       A5_CODPRF  "
       cSql += "  FROM " + RetSqlName("SA5")
       cSql += " WHERE A5_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
       cSql += "   AND A5_FORNECE = '" + Alltrim(cFornece) + "'"
       cSql += "   AND A5_LOJA    = '" + Alltrim(cLoja)    + "'"
       cSql += "   AND A5_CODPRF  = '" + Alltrim(aProdutos[nContar,02]) + "'"
 
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery(cSql)
       DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODFORNECE",.T.,.T.)

       If T_PRODFORNECE->( EOF() )

          If Select("T_SEGUNDO") <>  0
             T_SEGUNDO->(DbCloseArea())
          EndIf

          cSql := ""                                                                                           
          cSql := "SELECT A5_FILIAL ,"
          cSql += "       A5_FORNECE,"
    	  cSql += "       A5_LOJA   ,"
  	      cSql += "       A5_NOMEFOR,"
  	      cSql += "       A5_PRODUTO,"
  	      cSql += "       A5_NOMPROD,"
  	      cSql += "       A5_CODPRF  "
          cSql += "  FROM " + RetSqlName("SA5")
          cSql += " WHERE A5_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
          cSql += "   AND A5_FORNECE = '" + Alltrim(cFornece) + "'"
          cSql += "   AND A5_LOJA    = '" + Alltrim(cLoja)    + "'"
          cSql += "   AND A5_PRODUTO = '" + Alltrim(aProdutos[nContar,02]) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"

          cSql := ChangeQuery(cSql)
          DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEGUNDO",.T.,.T.)
          
          If T_SEGUNDO->( EOF() )

             aAdd( aRelacao, { aProdutos[nContar,01] ,;
                               aProdutos[nContar,02] ,;
                               aProdutos[nContar,03] ,;
                               ""                    ,;
                               ""                    })
          Else

             aProdutos[nContar,02] := T_SEGUNDO->A5_PRODUTO
             aProdutos[nCOntar,03] := T_SEGUNDO->A5_NOMPROD
             aProdutos[nContar,15] := ""
             aProdutos[nContar,16] := ""          
             aProdutos[nContar,22] := ""          
             
          Endif
             
       Else
       
          aProdutos[nContar,02] := T_PRODFORNECE->A5_PRODUTO
          aProdutos[nCOntar,03] := T_PRODFORNECE->A5_NOMPROD
          aProdutos[nContar,15] := ""
          aProdutos[nContar,16] := ""          
          aProdutos[nContar,22] := ""          

       Endif

   Next nContar                         

   If Len(aRelacao) == 0
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlgRel TITLE "Relacionamento de Produtos" FROM C(178),C(181) TO C(491),C(895) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.Bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgRel

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO  Size C(350),C(001) PIXEL          OF oDlgRel

   @ C(037),C(005) Say    "Relacionamento de códigos de produtos da NF-e com produtos do Sistema Protheus" Size C(202),C(008) COLOR CLR_BLACK PIXEL OF oDlgRel

   @ C(140),C(005) Button "Relacionar" Size C(037),C(012) PIXEL OF oDlgRel ACTION( ProdXfornecedor(aRelacao[oRelacao:nAt,01], aRelacao[oRelacao:nAt,02], aRelacao[oRelacao:nAt,03], aRelacao[oRelacao:nAt,04],aRelacao[oRelacao:nAt,05]) )
   @ C(140),C(315) Button "Confirmar"  Size C(037),C(012) PIXEL OF oDlgRel ACTION( GrvCadProFon() )

   // ###########################################
   // Lista com os produtos da NFe selecionado ##
   // ###########################################
   @ 060,005 LISTBOX oRelacao FIELDS HEADER "Seq.", "Código", "Descrição Produto NF", "Código Protheus", "Descrição produto Protheus" PIXEL SIZE 443,115 OF oDlgRel ;
             ON dblClick(aRelacao[oRelacao:nAt,1] := !aRelacao[oRelacao:nAt,1],oRelacao:Refresh())     

   oRelacao:SetArray( aRelacao )

   oRelacao:bLine := {|| {aRelacao[oRelacao:nAt,01],;
          				  aRelacao[oRelacao:nAt,02],;
          				  aRelacao[oRelacao:nAt,03],;
          				  aRelacao[oRelacao:nAt,04],;
          				  aRelacao[oRelacao:nAt,05]}}

   ACTIVATE MSDIALOG oDlgRel CENTERED 

Return(.T.)

// ####################################################################
// Função que abre a tela de relacionamento de produto X fornecedore ##
// ####################################################################
Static Function ProdXfornecedor( _Sequencia, _CodFor, _NomFor, _CodSis, _NomSis)

   Local lChumba      := .F.
   Local cSql         := ""

   Local cMemo1	      := ""
   Local cMemo2	      := ""

   Local oMemo1
   Local oMemo2

   Local xGrupoPsq    := ""

   Private aParaCombo := {}
   Private cComboBx1

   Private cCodFor    := _CodFor
   Private cNomFor    := _NomFor
   Private cCodSis    := IIF(Empty(Alltrim(_CodSis)), Space(06), _CodSis)
   Private cNomSis    := _NomSis

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgPXF

   // #################################################
   // Pesquisa os parãmetros para carga dos produtos ##
   // #################################################
   If Select("T_PARAMETROS") <>  0
      T_PARAMETROS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_XOC1,"
   cSql += "       ZZ4_XOC2,"
   cSql += "       ZZ4_XOC3,"
   cSql += "       ZZ4_XOC4,"
   cSql += " 	   ZZ4_XGR1,"
   cSql += "	   ZZ4_XGR2,"
   cSql += "	   ZZ4_XGR3,"
   cSql += "	   ZZ4_XGR4 "
   cSql += "  FROM " + RetSqlName("ZZ4")
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARAMETROS",.T.,.T.)

   // ################################################################
   // Carrega o combo de produtos conforme tipo de entrada indicada ##
   // ################################################################
   If Select("T_PARACOMBO") <>  0
      T_PARACOMBO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD,"
   cSql += "       LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO"
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_MSBLQL <> '1'"
   cSql += "   AND D_E_L_E_T_ = '' "

   Do Case
      Case lTipoImp = 2
           cSql += " AND B1_GRUPO IN (" + Alltrim(T_PARAMETROS->ZZ4_XGR2) + ")"
           xGrupoPsq := Alltrim(T_PARAMETROS->ZZ4_XGR2)
      Case lTipoImp = 3
           cSql += " AND B1_GRUPO IN (" + Alltrim(T_PARAMETROS->ZZ4_XGR3) + ")"
           xGrupoPsq := Alltrim(T_PARAMETROS->ZZ4_XGR3)
      Case lTipoImp = 4
           cSql += " AND B1_GRUPO IN (" + Alltrim(T_PARAMETROS->ZZ4_XGR4) + ")"
           xGrupoPsq := Alltrim(T_PARAMETROS->ZZ4_XGR4)
   EndCase

   cSql += " ORDER BY LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX))"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PARACOMBO",.T.,.T.)
   
   If T_PARACOMBO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados." + chr(13) + chr(10) + "Verifique parametrizador de Importação de XML.")
      Return(.T.)
   Endif
   
   T_PARACOMBO->( DbGoTop() )
   
   aAdd( aParaCombo, ""  )

   WHILE !T_PARACOMBO->( EOF() )
      aAdd( aParaCombo, Alltrim(T_PARACOMBO->B1_COD) + " - " + Alltrim(T_PARACOMBO->DESCRICAO) )
      T_PARACOMBO->( DbSkip() )
   ENDDO   

   // ###################################
   // Desenha a tela para visualização ##
   // ###################################
   DEFINE MSDIALOG oDlgPXF TITLE "Produtos X Fornecedores" FROM C(178),C(181) TO C(457),C(633) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgPXF

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(217),C(001) PIXEL OF oDlgPXF
   @ C(117),C(005) GET oMemo2 Var cMemo2 MEMO Size C(217),C(001) PIXEL OF oDlgPXF

   @ C(037),C(005) Say "Relacione abaixo o código do Sistema com o código do Fornecedor" Size C(162),C(008) COLOR CLR_BLACK PIXEL OF oDlgPXF
   @ C(049),C(005) Say "Produto Fornecedor"                                              Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgPXF
   @ C(071),C(005) Say "Produtos Protheus"                                               Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgPXF
   @ C(093),C(005) Say "Produto Protheus"                                                Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgPXF
      
   @ C(058),C(005) MsGet    oGet1     Var   cCodFor    Size C(047),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPXF When lChumba
   @ C(058),C(058) MsGet    oGet2     Var   cNomFor    Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPXF When lChumba
   @ C(080),C(004) ComboBox cComboBx1 Items aParaCombo Size C(217),C(010)                              PIXEL OF oDlgPXF ON CHANGE CapCpdNomPro(cComboBx1)
   @ C(103),C(005) MsGet    oGet3     Var   cCodSis    Size C(047),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPXF VALID( BscNomProd(cCodSis, xGrupoPsq) )
   @ C(103),C(058) MsGet    oGet4     Var   cNomSis    Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPXF When lChumba

   @ C(122),C(142) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgPXF ACTION( CfmProdFor(_Sequencia, cCodSis, cNomSis) )
   @ C(122),C(184) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgPXF ACTION( oDlgPXF:End() )

   ACTIVATE MSDIALOG oDlgPXF CENTERED 

Return(.T.)

// ######################################################################################
// Função que carrega o código e nome do produto conforme seleção do combo de produtos ##
// ######################################################################################
Static Function CapCpdNomPro(cComboBx1)

   If Empty(Alltrim(cComboBx1))
      cCodSis   := Space(06)
      cNomSis   := Space(60)
      cComboBx1 := ""
      oGet3:Refresh()
      oGet4:Refresh()      
   Else
      xKProduto := Alltrim(cComboBx1) + "-"
      cCodSis   := U_P_CORTA(xKProduto, "-",1)
      cNomSis   := U_P_CORTA(xKProduto, "-",2)
      cComboBx1 := ""
      oGet3:Refresh()
      oGet4:Refresh()      
   Endif
   
Return(.T.)

// #####################################################
// Função que pesquisa o produto informado (Digitado) ##
// #####################################################
Static Function BscNomProd(_CodKproduto, _GruposPsq)

   Local cSql := ""

   If Empty(Alltrim(_CodKproduto))
      cCodSis := Space(06)
      cNomSis := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      Return(.T.)
   Endif
      
   If Select("T_CADASTRO") <>  0
      T_CADASTRO->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD,"
   cSql += "       LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO,"
   cSql += "       B1_GRUPO
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_MSBLQL <> '1'"
   cSql += "   AND D_E_L_E_T_ = ''" 
   cSql += "   AND B1_COD     = '" + Alltrim(_CodKproduto) + "'"
   
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CADASTRO",.T.,.T.)

   If T_CADASTRO->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para este código.")
      Return(.T.)
   Endif

   If U_P_OCCURS(_GruposPsq, T_CADASTRO->B1_GRUPO, 1) == 0
      MsgAlert("Grupo do produto inválido para este tio de importação." + chr(13) + chr(10) + "Solicite verificação do parametrizador Automatech.")
      Return(.T.)
   Endif
   
   cCodSis := T_CADASTRO->B1_COD
   cNomSis := T_CADASTRO->DESCRICAO
   oGet3:Refresh()
   oGet4:Refresh()

Return(.T.)

// ###########################################
// Função que grava o produto na tabela SA5 ##
// ###########################################
Static Function CfmProdFor(_Sequencia, cCodSis, cNomSis)

   Local nContar := 0

   For nContar = 1 to Len(aRelacao)
       If Alltrim(aRelacao[nContar,01]) == Alltrim(_Sequencia)
          aRelacao[nContar,04] := cCodSis
          aRelacao[nContar,05] := cNomSis
          Exit
       Endif
   Next nContar    

   oDlgPXF:End()

   oRelacao:SetArray( aRelacao )

   oRelacao:bLine := {|| {aRelacao[oRelacao:nAt,01],;
          				  aRelacao[oRelacao:nAt,02],;
          				  aRelacao[oRelacao:nAt,03],;
          				  aRelacao[oRelacao:nAt,04],;
          				  aRelacao[oRelacao:nAt,05]}}
          				  
   oRelacao:Refresh()          				  

Return(.T.)

// #######################################################################
// Atualiza a tabela Produtos X Fornecedores e encerra o relacionamento ##
// #######################################################################
Static Function GrvCadProFon()

   Local nContar   := 0
   Local nLocaliza := 0
   
   If lTipoImp == 1
   Else

      // ###################################################
      // Localiza e atualiza o produto no array aProdutos ##
      // ###################################################
      For nContar = 1 to Len(aRelacao)
   
          If Empty(Alltrim(aRelacao[nContar,04]))
             Loop
          Endif

          For nLocaliza = 1 to Len(aProdutos)
              If Alltrim(aProdutos[nLocaliza,01]) == Alltrim(aRelacao[nContar,01])
                 aProdutos[nLocaliza,02] := aRelacao[nContar,04]
                 aProdutos[nLocaliza,03] := aRelacao[nContar,05]
                 aProdutos[nLocaliza,15] := ""
                 aProdutos[nLocaliza,16] := ""              
                 aProdutos[nLocaliza,22] := ""              
                 Exit
              Endif

          Next nLozaliza       
       
      Next nContar    

      oDlgRel:End()
      Return(.T.)

   Endif   

   For nContar = 1 to Len(aRelacao)
   
       If Empty(Alltrim(aRelacao[nContar,04]))
          Loop
       Endif
       
       // ##################################################
       // Grava na tabela SA5 o produto para o fornecedor ##
       // ##################################################
       dbSelectArea("SA5")
       RecLock("SA5",.T.)
       SA5->A5_FILIAL  := cFilAnt
       SA5->A5_FORNECE := cFornece
	   SA5->A5_LOJA    := cLoja
	   SA5->A5_NOMEFOR := cNfornece
	   SA5->A5_PRODUTO := aRelacao[nContar,04]
	   SA5->A5_NOMPROD := aRelacao[nContar,05]
	   SA5->A5_CODPRF  := aRelacao[nContar,02]
       MsUnLock()

       // ###################################################
       // Localiza e atualiza o produto no array aProdutos ##
       // ###################################################
       For nLocaliza = 1 to Len(aProdutos)
           If Alltrim(aProdutos[nLocaliza,01]) == Alltrim(aRelacao[nContar,01])
              aProdutos[nLocaliza,02] := aRelacao[nContar,04]
              aProdutos[nLocaliza,03] := aRelacao[nContar,05]
              aProdutos[nLocaliza,15] := ""
              aProdutos[nLocaliza,16] := ""              
              aProdutos[nLocaliza,22] := ""              
              Exit
           Endif
       Next nLozaliza       
       
   Next nContar    

   oDlgRel:End()

Return(.T.)