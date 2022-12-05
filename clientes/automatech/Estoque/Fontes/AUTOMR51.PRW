#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR51.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/04/2012                                                          *
// Objetivo..: Conferência de Inventário                                           *
//             Este programa tem por finalidade de listar através da informação da *
//             data de inventário, todos os saldos dos produtos da data comparando *
//             com as quantidades inventariadas.                                   *
//**********************************************************************************

User Function AUTOMR51()

   Local lChumba    := .F.

   Private aComboBx1  := {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas"}
   Private cComboBx1

   Private cCaminho   := Space(100)
   Private cData	  := Ctod("  /  /    ")
   Private cProduto   := Space(06)
   Private cDescricao := Space(100)

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   U_AUTOM628("AUTOMR51")

   DEFINE MSDIALOG oDlg TITLE "Conferencia de Inventário - AUTOMATECH" FROM C(178),C(181) TO C(361),C(694) PIXEL

   @ C(008),C(008) Say "Arquivo Saldos" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(008) Say "Data Inventário" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(009) Say "Filial" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(007),C(049) MsGet oGet1 Var cCaminho   When lChumba Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(007),C(234) Button "..." Size C(014),C(010) PIXEL OF oDlg ACTION( PESQCAM() )
   @ C(023),C(049) MsGet oGet2 Var cData      Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(038),C(049) MsGet oGet3 Var cProduto   Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( BNomeProd(cProduto) )
   @ C(038),C(085) MsGet oGet4 Var cDescricao When lChumba Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(054),C(048) ComboBox cComboBx1 Items aComboBx1 Size C(200),C(010) PIXEL OF oDlg

   @ C(071),C(169) Button "O K"    Size C(037),C(012) PIXEL OF oDlg ACTION( GeraConfeI( cCaminho, cData, cProduto, cComboBx1 ) )
   @ C(071),C(211) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do arquivo
Static Function PESQCAM()
   
   cCaminho := cGetFile('*.*', "Selecione o Arquivo de Produtos",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que pesquisa a descrição do produto informado
Static Function BNomeProd( cProduto )

   Local cSql := ""
   
   If Empty(cProduto)
      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf
      cDescricao := Space(60)
      Return .T.
   Endif   

   If Select("T_PRODUTO") > 0
   	  T_PRODUTO->( dbCloseArea() )
   EndIf

   cSql := "SELECT B1_DESC, "
   cSql += "       B1_DAUX  "
   cSql += "  FROM " + RetSqlName("SB1010")
   cSql += " WHERE B1_COD = '" + Alltrim(cProduto) + "'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )
	
    If !T_PRODUTO->( EOF() )
       cDescricao := Alltrim(T_PRODUTO->B1_DESC) + " " + Alltrim(T_PRODUTO->B1_DAUX)
    Else
       MsgAlert("Produto informado inexistente.")
       cDescricao := Space(60)
    Endif

    If Select("T_PRODUTO") > 0
   	   T_PRODUTO->( dbCloseArea() )
    EndIf

Return .T.

// Função que gera a pesquisa de conferência de inventário
Static Function GeraConfeI( cCaminho, cData, cProduto, cComboBx1 )

   Local cRegistro   := ""
   Local cSql        := ""
   Local nContar     := 0
   Local nProcura    := 0
   Local lExiste     := .F.
   Local lPrimeiro   := .T.

   Private aProdutos := {}

   If Empty(cCaminho)
      MsgAlert("Arquivo de Saldos na data do inventário não informado.")
      Return .T.
   Endif

   If Empty(cData)
      MsgAlert("Necessário informar data do inventário para pesquisa.")
      Return .T.
   Endif

   // Abre o arquivo de saldos na data do inventário
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

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cRegistro := ""

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cRegistro := cRegistro + Substr(xBuffer, nContar, 1)
                
       Else

          If lPrimeiro
             cCodigo := Substr(cRegistro,01,06)
             cQuanti := Substr(cRegistro,30,04)
             lPrimeiro := .F.
          Else
             cCodigo := Substr(cRegistro,02,06)
             cQuanti := Substr(cRegistro,31,04)
          Endif

          If !Empty(Alltrim(cProduto))
             If Alltrim(cCodigo) <> Alltrim(cProduto)
                cRegistro := ""

                If Substr(xBuffer, nContar, 1) == chr(10)
                   nContar += 1
                Endif   
                Loop
             Endif
          Endif

          // Carrega o array aProdutos.
          // Verifica primeiro se o poduto já existe. Se existe, acumula a quantidade
          lExiste := .F.
          For nProcura = 1 to Len(aProdutos)
              If Alltrim(aProdutos[nProcura,01]) == Alltrim(cCodigo)
                 lExiste := .T.
                 Exit
              Endif
          Next nProcura
          
          If lExiste
             aProdutos[nProcura,02] := Str(Int(val(aProdutos[nProcura,02])) + Int(Val(cQuanti)),04)
          Else

             // Pesquisa o nome do produto
             If Select("T_DESCRICAO") > 0
                T_DESCRICAO->( dbCloseArea() )
             EndIf

             cSql := ""
             cSql := "SELECT B1_DESC "
             cSql += "  FROM " + RetSqlName("SB1")
             cSql += " WHERE B1_COD = '" + Alltrim(cCodigo) + "'"
             
             cSql := ChangeQuery( cSql )
             dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESCRICAO", .T., .T. )

             aAdd( aProdutos, { cCodigo, cQuanti, "", T_DESCRICAO->B1_DESC } )
          Endif

          cRegistro := ""

          If Substr(xBuffer, nContar, 1) == chr(10)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    

   // Pesquisa o saldo na tabela B7 para os produtos lidos
   For nContar = 1 to Len(aProdutos)

       If Select("T_SALDOS") > 0
          T_SALDOS->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT SUM(B7_QUANT) AS SALDO "
       cSql += "  FROM " + RetSqlName("SB7") 
       cSql += " WHERE B7_FILIAL = '" + Alltrim(Substr(cComboBx1,01,02)) + "'"
       cSql += "   AND B7_DATA   = '" + Substr(Dtoc(cData),07,04) + Substr(Dtoc(cData),04,02) + Substr(Dtoc(cData),01,02) + "'"
       cSql += "   AND B7_COD    = '" + Alltrim(aProdutos[nContar,01])   + "'"
       cSql += " GROUP BY B7_COD"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDOS", .T., .T. )

       If T_SALDOS->( EOF() )
          cSaldo := Str(0,10)
       Else
          cSaldo := Str(T_SALDOS->SALDO,10)
       Endif
       
       aProdutos[nContar,03] := cSaldo
       
   Next nContar       

   LISTARELA()
      
Return .T.

Static Function LISTARELA()

   Local cDesc1  := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2  := "de acordo com os parametros informados pelo usuario."
   Local cDesc3  := ""
   Local cPict   := ""
   Local titulo  := ""
   Local nLin    := 80
   Local Cabec1  := ""
   Local Cabec2  := ""
   Local imprime := .T.
   Local aOrd    := {}

   Private lEnd        := .F.
   Private lAbortPrint := .F.
   Private CbTxt       := ""
   Private limite      := 80
   Private tamanho     := "P"
   Private nomeprog    := "AUTOMR51"
   Private nTipo       := 18
   Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey    := 0
   Private cbtxt       := Space(10)
   Private cbcont      := 00
   Private CONTFL      := 01
   Private m_pag       := 01
   Private wnrel       := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco

   Private cString     := "SB1"

   dbSelectArea("SB1")
   dbSetOrder(1)

   // Monta a interface padrao com o usuario
   wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return .T.

// Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local nOrdem
   Local nContar := 0
   Private nLin  := 60

   CabecaRel(nLin)
   
   For nContar = 1 to Len(aProdutos)

       If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
          nLin := 1
          CabecaRel(nLin)
          nLin := 8
       Endif

       @ nLin,001 PSAY aProdutos[nContar,01]
       @ nLin,008 PSAY aProdutos[nContar,04]
       @ nLin,049 PSAY Str(int(val(aProdutos[nContar,02])),10)
       @ nLin,060 PSAY Str(int(val(aProdutos[nContar,03])),10)
       @ nLin,071 PSAY Str(Int(val(aProdutos[nContar,03])) - Int(val(aProdutos[nContar,02])),10)

       nLin := nLin + 1

   Next nContar

   SET DEVICE TO SCREEN
   SET PRINTER TO
   OurSpool(wnrel)

   MS_FLUSH()

Return .T.

// Funcao que imprime o cabeçalho do relatório
Static Function CabecaRel(nLin)

   @ nLin,001 PSAY "--------------------------------------------------------------------------------"
   nLin := nLin + 1
   @ nLin,001 PSAY "AUTOMATECH                  CONFERÊNCIA DE INVENTÁRIO     " + Dtoc(Date()) + "  - " + TIME()
   nLin := nLin + 1
   @ nLin,001 PSAY "AUTOMR51                    FILIAL: " + Substr(cComboBx1,01,18) + "     INVENTARIO: " + Dtoc(cData)
   nLin := nLin + 1
   @ nLin,001 PSAY "--------------------------------------------------------------------------------"
   nLin := nLin + 1
   @ nLin,001 PSAY "CODIGO DESCRICAO DOS PRODUTOS                        SALDO INVENTARIO  DIFERENCA"
   nLin := nLin + 1
   @ nLin,001 PSAY "--------------------------------------------------------------------------------"
   nLin := nLin + 1
   
Return .T.