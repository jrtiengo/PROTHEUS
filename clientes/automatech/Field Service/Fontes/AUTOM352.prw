#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//********************************************************************************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                                                                 *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Referencia: AUTOM352.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 22/06/2016                                                                                                                                *
// Objetivo..: Programa que atualiza tabele de preço do Sistema Protheus pela leitura de arquivo TXT                                                     *
//********************************************************************************************************************************************************

User Function AUTOM352()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cCaminho := Space(250)
   Private oGet1

   Private aTabelas := {}
   Private cComboBx1

   Private oDlg

   // Procedimento somente permitido para usuário Admin e Roger
   If __CuserId == "000000" .OR. __CuserId == "000002"
   Else
      MsgAlert("Procedimento não permitido para este usuário.")
      Return(.T.)
   Endif

   // Carrega o combo de tabelas de preços a serem atualizadas
   If Select("T_TABELAS") > 0
      T_TABELAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT DA0_CODTAB,"
   cSql += "       DA0_DESCRI "
   cSql += "  FROM " + RetSqlName("DA0")
   cSql += " WHERE DA0_ATIVO  = 1"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY DA0_CODTAB"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TABELAS", .T., .T. )

   If T_TABELAS->( EOF() )
      aAdd( aTabelas, "000 - Nenhuma tabela de preço cadastrada." )
   Else

      aAdd( aTabelas, "000 - Selecione a tabela a ser atualizada" )
   
      T_TABELAS->( DbGoTop() )
     
      WHILE !T_TABELAS->( EOF() )
         aAdd( aTabelas, T_TABELAS->DA0_CODTAB + " - " + Alltrim(T_TABELAS->DA0_DESCRI) )
         T_TABELAS->( DbSkip() )
      ENDDO
      
   Endif
         
   DEFINE MSDIALOG oDlg TITLE "Atualização tabela de preço por leitura de arquivo TXT" FROM C(178),C(181) TO C(462),C(808) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(306),C(001) PIXEL OF oDlg
   @ C(068),C(003) GET oMemo2 Var cMemo2 MEMO Size C(306),C(001) PIXEL OF oDlg
   
   @ C(038),C(005) Say "Informe abaixo o arquivo TXT a ser utilizado para atualização da tabela de preço."                                          Size C(193),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(047),C(005) Say "Atenção ao layout do arquivo para importação."                                                                              Size C(112),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Código - Descrição dos Produtos - Código Grupo - Descrção dos Grupo - Moeda - Novo Preço - Preço Anterior - Preço de Custo" Size C(303),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(074),C(005) Say "Arquivo"                                                                                                                    Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(005) Say "Tabela de Preço a ser atualizada"                                                                                           Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(084),C(005) MsGet oGet1 Var cCaminho          Size C(286),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(084),C(295) Button "..."                      Size C(012),C(009)                              PIXEL OF oDlg ACTION( PESQARQPRECO() )
   @ C(106),C(005) ComboBox cComboBx1 Items aTabelas Size C(303),C(010)                              PIXEL OF oDlg

   @ C(124),C(116) Button "Processar" Size C(037),C(012) PIXEL OF oDlg ACTION( AtuTabPreco() )
   @ C(124),C(158) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQARQPRECO()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que lê o arquivo informado e realiza a atualização dos vendedores
Static Function AtuTabPreco()

   MsgRun("Aguarde! Carregando informações do arquivo indicado ...", "Leitura dados arquivo de atualização de preço de produtos",{|| IIAtuTabPreco() })

Return(.T.)

// Função que lê o arquivo informado e realiza a atualização dos vendedores
Static Function IIAtuTabPreco()

   Local cConteudo := ""
   Local aLinhas   := {}

   Private aPrecos := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser utilizado para atualização da tabela de preço 001 não informado.")
      Return(.T.)
   Endif
   
   If Substr(cComboBx1,01,03) == "000"
      MsgAlert("Tabela de preço a ser atualizada não selecionada.")
      Return(.T.)
   Endif

   // Abre o arquivo informado do conhecimento de transporte para importação
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo " + Alltrim(__Arquivo))
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
          cConteudo := cConteudo + "|"
          cConteudo := StrTran(cConteudo, chr(9), "|")
          _Linha    := ""
          aAdd( aLinhas,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   // Realiza a gravação dos registros
   For nContar = 1 to Len(aLinhas)
           
       _Codigo  := U_P_CORTA(aLinhas[nContar], "|", 1)
       _Produto := U_P_CORTA(aLinhas[nContar], "|", 2)
       _Grupo   := U_P_CORTA(aLinhas[nContar], "|", 3)
       _NGrupo  := U_P_CORTA(aLinhas[nContar], "|", 4)
       _Moeda   := U_P_CORTA(aLinhas[nContar], "|", 5)
       _Novo    := U_P_CORTA(aLinhas[nContar], "|", 6)
       _Preco   := U_P_CORTA(aLinhas[nContar], "|", 7)
       _Custo   := U_P_CORTA(aLinhas[nContar], "|", 8)

       _Codigo  := Strzero(Int(Val(Strtran(_Codigo,'"', ''))),6)
       _Novo    := Val(Strtran(_Novo  ,',', '.'))
       _Preco   := Val(Strtran(_Preco ,',', '.'))
       _Custo   := Val(Strtran(_Custo ,',', '.'))

       aAdd( aPrecos, { .F., _Codigo, _Produto, _Grupo, _NGrupo, _Moeda, Str(_Novo,10,02), Str(_Preco,10,02), str(_Custo,10,02) } )

   Next nContar
  
   If Len(aPrecos) == 0
      MsgAlert("Não existem dados disponíveis para atualização.")
      Return(.T.)
   Endif   

   // Envia para a função que mostra os produto do arquivo selecionado
   AbreGridPrecos()

Return(.T.)

// Função que abre grid para visualizar os produtos antes da atualização
Static Function AbreGridPrecos()

   Local nContar := 0
   Local cMemo1	 := ""
   Local oMemo1

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgLista

   Private aLista := {}
   Private oLista

   // Carrega o array aLista com o conteúdo do array aPrecos
   For nContar = 1 to Len(aPrecos)
       aAdd( aLista, { aPrecos[nContar,01],;
                       aPrecos[nContar,02],;
                       aPrecos[nContar,03],;
                       aPrecos[nContar,04],;
                       aPrecos[nContar,05],;
                       aPrecos[nContar,06],;
                       aPrecos[nContar,07],;
                       aPrecos[nContar,08],;
                       aPrecos[nContar,09]})
   Next nContar
   
   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlgLista TITLE "Atualização tabela de preço por leitura de arquivo TXT" FROM C(178),C(181) TO C(610),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgLista

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlgLista

   @ C(035),C(005) Say "Produtos a serem atualizados"   Size C(073),C(008) COLOR CLR_BLACK PIXEL OF oDlgLista
   @ C(202),C(162) Say "Moeda [1] - Real   [2] - Dolar" Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlgLista

   @ C(200),C(005) Button "Marcar todos"    Size C(050),C(012) PIXEL OF oDlgLista ACTION( MarcaLinha(1) )
   @ C(200),C(058) Button "Desmarcar Todos" Size C(050),C(012) PIXEL OF oDlgLista ACTION( MarcaLinha(2) )
   @ C(200),C(312) Button "Atualizar"       Size C(037),C(012) PIXEL OF oDlgLista ACTION( AtualizaLista() )
   @ C(200),C(350) Button "Voltar"          Size C(037),C(012) PIXEL OF oDlgLista ACTION( oDlgLista:End() )
 
   @ 055,005 LISTBOX oLista FIELDS HEADER "M", "Código" ,"Descrição dos Produtos" + Space(95), "Moeda", "Preço de Lista" PIXEL SIZE 500,195 OF oDlgLista ;
                            ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )
   oLista:bLine := {||     {Iif(aLista[oLista:nAt,01],oOk,oNo),;
          					    aLista[oLista:nAt,02],;
          					    aLista[oLista:nAt,03],;
          					    aLista[oLista:nAt,06],;
         	        	        aLista[oLista:nAt,07]}}

   ACTIVATE MSDIALOG oDlgLista CENTERED 

Return(.T.)

// Função que marca/desmarca os registros a serem atualizados
Static Function MarcaLinha(_TipoBotao)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)
       aLista[nContar,01] := IIf(_TipoBotao == 1, .T., .F.)
   Next nContar
   
Return(.T.)

// Função que atualiza a lista selecionada
Static Function AtualizaLista()

   Local nContar  := 0
   Local lMarcado := .F.
   
   // Verifica se houve a indicação de pelo menos 1 produtoa ser atualizado
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Nenhum produto foi marcado para ser atualizado. Verifique!")
      Return(.T.)
   Endif
      
   // Realiaza a gravação dos novos preços de venda na tabela de preço selecionada
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .F.
          Loop
       Endif

       cSql := ""
       cSql := "UPDATE DA1010"
       cSql += "   SET"
       cSql += "   DA1_MOEDA  = " + Alltrim(Str(int(Val(aLista[nContar,06] )))) + ", "
       cSql += "   DA1_PRCVEN = " + Alltrim(str(val(aLista[nContar,07]),10,02))
       cSql += " WHERE DA1_CODTAB = '" + Alltrim(Substr(cComboBx1,01,03)) + "'"
       cSql += "   AND DA1_CODPRO = '" + Alltrim(aLista[nContar,02])      + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       lResult := TCSQLEXEC(cSql)
       If lResult < 0
          Return MsgStop("Erro na gravação do novo preço de venda de produto: " + TCSQLError())
       EndIf 

    Next nContar

    oDlgLista:End() 

    cCaminho := Space(250)
    oget1:Refresh()

    MsgAlert("Alteração de preços realizada com sucesso!")

Return(.T.)