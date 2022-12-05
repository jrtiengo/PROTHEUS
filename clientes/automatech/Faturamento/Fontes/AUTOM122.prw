#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM122.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 29/04/2012                                                          *
// Objetivo..: Programa que impota tabela de pre�o e carrega a tabela de Tabela de *
//             Pre�o do Sistema Protheus.                                          *
//**********************************************************************************

User Function AUTOM122()

   Local lChumba     := .F.

   Private aComboBx1 := {"�nico","Recorrente"}
   Private aComboBx2 := {"Sim","N�o"}
   Private aComboBx3 := {"01 - Porto Alegre","02 - Caxias do Sul","03 - Pelotas"}
   Private aComboBx4 := {"1 - Real (R$)","2 - Dolar (U$)"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4

   Private cCaminho	  := Space(100)
   Private cTabela 	  := Space(03)
   Private cDescricao := Space(30)
   Private cDataI  	  := Ctod("  /  /    ")
   Private cHoraI 	  := Space(05)
   Private cDataF	  := Ctod("  /  /    ")
   Private cHoraF	  := Space(05)
   Private cCondicao  := Space(03)
   Private cNomeCond  := Space(30)
   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet8

   Private oDlg

   U_AUTOM628("AUTOM122")

   DEFINE MSDIALOG oDlg TITLE "Importa��o Tabela de Pre�os" FROM C(178),C(181) TO C(531),C(660) PIXEL

   @ C(004),C(004) Say "Arquivo a ser importado" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(004) Say "Par�metros para inclus�o da Tabela de Pre�o" Size C(112),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(047),C(004) Say "C�digo"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(005) Say "Descri��o" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(033) Say "Data de"   Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(109) Say "Hora de"   Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(076),C(004) Say "Validade"  Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(088),C(033) Say "Data At�"  Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(088),C(109) Say "Hora At�"  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(004) Say "Cond.Pg"   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(115),C(004) Say "Tipo Hr"   Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(005) Say "Ativo"     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(129),C(082) Say "Moeda"     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(143),C(004) Say "Filial"    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(004) MsGet oGet1 Var cCaminho   When lChumba Size C(217),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(222) Button "..." Size C(011),C(009) PIXEL OF oDlg ACTION(BUSCATABV())
   @ C(047),C(033) MsGet oGet2 Var cTabela    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(060),C(033) MsGet oGet3 Var cDescricao Size C(137),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(074),C(061) MsGet oGet4 Var cDataI     Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(074),C(135) MsGet oGet5 Var cHoraI     Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(087),C(061) MsGet oGet6 Var cDataF     Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(087),C(135) MsGet oGet7 Var cHoraF     Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(100),C(033) MsGet oGet8 Var cCondicao  Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SE4") VALID(TRAZCOND(cCondicao))
   @ C(100),C(061) MsGet oGet9 Var cNomeCond  When lChumba Size C(109),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(114),C(033) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg
   @ C(127),C(033) ComboBox cComboBx2 Items aComboBx2 Size C(036),C(010) PIXEL OF oDlg
   @ C(127),C(104) ComboBox cComboBx4 Items aComboBx4 Size C(067),C(010) PIXEL OF oDlg
   @ C(141),C(033) ComboBox cComboBx3 Items aComboBx3 Size C(138),C(010) PIXEL OF oDlg

   @ C(158),C(083) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( ImpTabVend(cCaminho) )
   @ C(158),C(122) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que abre di�logo de pesquisa do arquivo a ser importado
Static Function BUSCATABV()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo a ser importado",1,"C:\",.F.,16,.F.)

Return .T. 

// Fun��o que pesquisa a condi��o de pagamento
Static Function TRAZCOND(_Condicao)

   Local cSql := ""
   
   If Empty(Alltrim(_Condicao))
      Return .T.
   Endif
   
   If Select("T_CONDICAO") > 0
   	  T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := "SELECT E4_CODIGO, "
   cSql += "       E4_DESCRI  "
   cSql += "  FROM " + RetSqlName("SE4")
   cSql += " WHERE E4_CODIGO = '" + Alltrim(_Condicao) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
   
   If T_CONDICAO->( EOF() )
      MsgAlert("N�o existem dados a serem visualizados.")
      cCondicao := Space(03)
      cNomeCond := Space(30)
   Else
      cCondicao := T_CONDICAO->E4_CODIGO
      cNomeCond := T_CONDICAO->E4_DESCRI
   Endif      

Return .T.

// Fun��o que le o arquivo especificado para importa��o
Static Function ImpTabVend( cCaminho )

   Local nContar   := 0
   Local nSepara   := 0
   Local npreco    := 0
   Local Linha     := ""
   Local cCodigo   := ""
   Local cPreco    := 0
   Local cPreco1   := 0
   Local aProdutos := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado n�o informado.")
      Return .T.
   Endif

   If !File(Alltrim(cCaminho))
      MsgAlert("Arquivo informado inexistente. Verifique !!")
      Return .T.
   Endif

   If Empty(Alltrim(cDescricao))
      MsgAlert("Neces�rio informar a descri��o da Tabela de Pre�o.")
      Return .T.
   Endif

   If Empty(Alltrim(cTabela))
      MsgAlert("C�digo da Tabela de Pre�o n�o informada.")
      Return .T.
   Endif
   
   If Empty(cDataI)
      MsgAlert("Data inicial de validade n�o informada.")
      Return .T.
   Endif
   
   If Empty(cHoraI)
      MsgAlert("Hora inicial de validade n�o informada.")
      Return .T.
   Endif
       
   If Empty(cDataF)
      MsgAlert("Data final de validade n�o informada.")
      Return .T.
   Endif
   
   If Empty(cHoraF)
      MsgAlert("Hora final de validade n�o informada.")
      Return .T.
   Endif

   // Abre o arquivo ser lido da Aprove e atualiza a coluna do Browse
   nHandle := FOPEN(Alltrim(cCaminho), FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo.")
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
 
   cLinha    := ""
   lPrimeiro := .T.

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cLInha := cLinha + Substr(xBuffer, nContar, 1)
                
       Else

         cLinha := StrTran(cLinha, Chr(9), "#")

         // Separa o c�digo do produto
         cCodigo := ""
         For nSepara = 1 to Len(cLinha)
             If Substr(cLinha,nSepara,1) <> "#"
                cCodigo := cCodigo + Substr(cLinha,nSepara,1)
             Else
                Exit
             Endif
         Next nSepara          
             
         // Separa o Pre�o de Venda do Produto
         cPreco := ""
         For nSepara = 1 to Len(cLinha)
             If Substr(cLinha,nSepara,2) <> "$U"
             Else
                cPreco := Substr(cLinha,nSepara)
                Exit
             Endif
         Next nSepara          
         
         cPreco1 := ""
         For nSepara = 1 to Len(cPreco)

             If Substr(cPreco,nSepara,1) == "$"
                Loop
             Endif

             If Substr(cPreco,nSepara,1) == "-"
                Loop
             Endif

             If Substr(cPreco,nSepara,1) == "#"
                Exit
             Endif

             If ISALPHA(Substr(cPreco,nSepara,1))
                Loop
             Endif
   
             cPreco1 := cPreco1 + Substr(cPreco,nSepara,1)

         Next nSepara

         // Inseri no array aProdutos os dados a serem utilizados na tabela de pre�o
         aAdd( aProdutos, { cCodigo, cPreco1 } )

         cLinha  := ""
         cCodigo := ""
         cPreco  := ""
         cPreco1 := ""
            
       Endif


   Next nContar    

   // Cria a Tabela de Pre�o
   DbSelectArea("DA0")
   RecLock("DA0",.T.)

   DA0_CODTAB := cTabela
   DA0_DESCRI := cDescricao
   DA0_DATDE  := cDataI
   DA0_HORADE := cHoraI
   DA0_DATATE := cDataF
   DA0_HORATE := cHoraF
   DA0_CONDPG := cCondicao

   If Alltrim(cComboBx1) == "�nico"
      DA0_TPHORA := "1"
   Else
      DA0_TPHORA := "2"      
   Endif
      
   If Alltrim(cComboBx2) == "Sim"
      DA0_ATIVO  := "1"          
   Else
      DA0_ATIVO  := "2"                
   Endif   

   DA0_FILIAL := ""

   // Inclui a Tabela de Pre�o
   For nContar = 1 to Len(aProdutos)
   
       DbSelectArea("DA1")
       RecLock("DA1",.T.)

       DA1_FILIAL := Substr(cComboBx3,01,02)
       DA1_ITEM   := STRZERO(nContar,4)
       DA1_CODTAB := ctabela
       DA1_CODPRO := strzero(int(val(aProdutos[nContar,01])),6)
       DA1_PRCVEN := VAL(STRTRAN(aProdutos[nContar,02] ,',','.'))
       DA1_VLRDES := 0
       DA1_PERDES := 0
       DA1_ATIVO  := "1"
       DA1_FRETE  := 0
       DA1_ESTADO := "RS"
       DA1_TPOPER := "4"
       DA1_QTDLOT := 999999.99
       DA1_INDLOT := "000000000999999.99"
       DA1_MOEDA  := INT(VAL(Substr(cComboBx4,01,01)))
       DA1_PRCMAX := 0
       
   Next nContar       

   MsgAlert("Tabela de Pre�o gerada com sucesso.")
   
   oDlg:End()
   
Return .T.