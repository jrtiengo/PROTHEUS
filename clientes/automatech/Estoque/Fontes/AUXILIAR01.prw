#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUXILIAR01.PRW                                                      *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 20/07/2011                                                          *
// Objetivo..: Programa que corrige c�digos de vendedores no cadastro de clientes. *
//**********************************************************************************

// Fun��o que define a Window
User Function AUXILIAR01()   
 
   // Vari�veis Locais da Fun��o
   Local oGet1

   // Vari�veis da Fun��o de Controle e GertArea/RestArea
   Local _aArea   		:= {}
   Local _aAlias  		:= {}

   // Vari�veis Private da Fun��o
   Private aComboBx1 := {"d:\automatech\vendedores\taciele.txt", "d:\automatech\vendedores\lidiane.txt", "d:\automatech\vendedores\denise.txt"}
   Private cComboBx1
   Private cVendedor := space(8)
   Private nVias     := 1
   Private nGet1	 := space(5)
      
   // Di�logo Principal
   Private oDlg

   // Vari�veis que definem a A��o do Formul�rio

   DEFINE MSDIALOG oDlg TITLE "Corre��o C�digo Vendedor Cadastro Clientes" FROM C(178),C(181) TO C(280),C(500) PIXEL

   // Solicita o nome do arquivo a ser utilizado
   @ C(011),C(005) Say "Arquivo:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(010),C(030) ComboBox cComboBx1 Items aComboBx1 Size C(110),C(010) PIXEL OF oDlg

   // Cpodigo do Vendedor
   @ C(024),C(005) Say "Vendedor:"  Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(023),C(029) MsGet oGet1 Var cVendedor Size C(020),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   DEFINE SBUTTON FROM C(30),C(112) TYPE  1 ENABLE OF oDlg ACTION( ConverteVD(cComboBx1, cVendedor))
   DEFINE SBUTTON FROM C(30),C(090) TYPE 20 ENABLE OF oDlg ACTION( odlg:end() )

   ACTIVATE MSDIALOG oDlg CENTERED  

Return(.T.)

// Fun��o que define a Window
Static Function ConverteVD( cArquivo, cVendedor )

     Local nLidos
     Local nTamArq
     Local aCNPJ 
     Local nContar
     Local nAlen
     Local cSql 
     Local nReg
     Local cCgc

     Private xBuffer

     cBuffer := 1
     aCNPJ   := {}
     nContar := 0
     nAlen   := 0
     nReg    := 0
     cCgc    := space(16)

     // Gera consist�ncia dos par�metros parassado para a fun��o
     If Empty(cArquivo)
        MsgAlert("Arquivo a ser utilizado na atualiza��o n�o informado.")
        Return .T.
     Endif
        
     If Empty(cVendedor)
        MsgAlert("C�digo do vendedor a ser atualizado n�o informado.")
        Return .T.
     Endif

     If !File(cArquivo)
        MsgAlert("Arquivo selecionado inexistente.")
        Return .T.
     Endif

     // Abre o arquivoa ser lido
//   nHandle := FOPEN("d:\automatech\vendedores\taciele.txt", FO_READWRITE + FO_SHARED)
     nHandle := FOPEN(cArquivo, FO_READWRITE + FO_SHARED)
     
     If FERROR() != 0
        MsgAlert("Erro ao abrir o arquivo especificado.")
        Return .T.
     Endif
     
     // L� o tamanho total do arquivo
 	 nLidos :=0
	 FSEEK(nHandle,0,0)
	 nTamArq:=FSEEK(nHandle,0,2)
	 FSEEK(nHandle,0,0)

     // L� todos os CNPJ/CPF
     xBuffer:=Space(nTamArq)
     FREAD(nHandle,@xBuffer,nTamArq)

     // Separa os CNPJ/CPF e adiciona-os no Array aCNPJ
     cCnpj := ""

     For nContar = 1 to Len(xBuffer)
     
         If Substr(xBuffer,nContar,1) == " "
     
            // Atualiza o Array aCNPJ
            If !Empty(Alltrim(cCNPJ))
               AADD( aCNPJ, { cCnpj } )
               nAlen += 1
            Endif
               
            cCnpj := ""
            Loop

         Endif
            
         If Substr(xBuffer,nContar,1) == "." .OR. Substr(xBuffer,nContar,1) == "/" .OR. Substr(xBuffer,nContar,1) == "-"
            Loop
         Endif

         If Substr(xBuffer,nContar,1)$"1#2#3#4#5#6#7#8#9#0"
            cCnpj := cCnpj + Substr(xBuffer,nContar,1)
         Endif   
   
     Next nContar
         
     FCLOSE(nHandle)

     // Atualiza o cadastro de clientes com o vendedor do cliente lido pelo CNPJ
     nReg := 0
     For nContar = 1 to nAlen

         cCgc := "  " + Alltrim(aCnpj[nContar,1])
         
         // Atualiza o campo A1_VEND
    	 DbSelectArea("SA1")
         DbSetOrder(3)
         If DbSeek( cCgc )    
            If INT(VAL(SA1->A1_VEND)) <> 0
               Loop
            Endif
            RecLock("SA1", .F.)
//          SA1->A1_VEND := '000028'
            SA1->A1_VEND := cVendedor
            MsUnLock()
            nReg := nReg + 1
         Endif   

     Next nContar

     MsgAlert("Atualiza��o efetuada com sucesso." + chr(13) + "Total de registros alterados: " + Alltrim(str(nReg,5)))
    
Return .T.