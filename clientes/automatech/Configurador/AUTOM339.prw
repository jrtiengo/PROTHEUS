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
// Referencia: AUTOM339.PRW                                                                                                                              *
// Parâmetros: Nenhum                                                                                                                                    *
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                                                                                           *
// ----------------------------------------------------------------------------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                                                                                                   *
// Data......: 15/04/2016                                                                                                                                *
// Objetivo..: Programa que importa o cadastro do Boticário                                                                                              *
//********************************************************************************************************************************************************

User Function AUTOM339()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cCaminho := Space(250)
   Private oGet1

   Private oDlg

   // Procedimento somente permitido para usuário Admin e Roger
   If __CuserId == "000000" .OR. __CuserId == "000002"
   Else
      MsgAlert("Procedimento não permitido para este usuário.")
      Return(.T.)
   Endif

   // Desenha a tela para visualização
   DEFINE MSDIALOG oDlg TITLE "Inclusão Automática de Clientes" FROM C(178),C(181) TO C(433),C(671) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(030) PIXEL NOBORDER OF oDlg

   @ C(036),C(003) GET oMemo1 Var cMemo1 MEMO Size C(237),C(001) PIXEL OF oDlg
   @ C(080),C(003) GET oMemo2 Var cMemo2 MEMO Size C(237),C(001) PIXEL OF oDlg
   
   @ C(045),C(005) Say "Este procedimento realiza a inclusão automática de clientes através da leitura de sequencial (TXT)." Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(084),C(005) Say "Informe o arquivo a ser utilizado para importação"                                 Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(093),C(005) MsGet oGet1 Var cCaminho Size C(220),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(093),C(229) Button "..."             Size C(011),C(009)                              PIXEL OF oDlg ACTION( PESQARQCLIE() )

   @ C(110),C(084) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( AIncCliente() )
   @ C(110),C(123) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do XML a ser importado
Static Function PESQARQCLIE()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo a ser utilizado",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que inclui novos clientes pela leitura do TXT
Static Function AIncCliente()

  MsgRun("Favor Aguarde! Incluíndo novos Clientes ...", "Inclusão de Clientes",{|| BIncCliente() })

Return(.T.)

// Função que lê o arquivo informado e realiza a atualização dos vendedores
Static Function BIncCliente()

   Local cConteudo  := ""
   Local aLinhas    := {}
   Local aClientes  := {}
   Local aNumeracao := {}
   Local lJaEsta    := .F.
   Local nProcura   := 0
   Local lNovo      := .F.

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser utilizado para importação não informado.")
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
           
       _Codigo      := U_P_CORTA(aLinhas[nContar], "|",  1)
       _Nome        := U_P_CORTA(aLinhas[nContar], "|",  2)
       _CNPJ        := U_P_CORTA(aLinhas[nContar], "|",  3)
       _Inscricao   := U_P_CORTA(aLinhas[nContar], "|",  4)
       _Franquia    := U_P_CORTA(aLinhas[nContar], "|",  5)
       _Fantasia    := U_P_CORTA(aLinhas[nContar], "|",  6)
       _Endereco    := U_P_CORTA(aLinhas[nContar], "|",  7)
       _Numero      := U_P_CORTA(aLinhas[nContar], "|",  8)
       _Complemento := U_P_CORTA(aLinhas[nContar], "|",  9)
       _Bairro      := U_P_CORTA(aLinhas[nContar], "|", 10)
       _Cidade      := U_P_CORTA(aLinhas[nContar], "|", 11)
       _Estado      := U_P_CORTA(aLinhas[nContar], "|", 12)
       _CEP         := U_P_CORTA(aLinhas[nContar], "|", 13)
       _Rua3        := U_P_CORTA(aLinhas[nContar], "|", 14)
       _Tel01       := U_P_CORTA(aLinhas[nContar], "|", 15)
       _Tel02       := U_P_CORTA(aLinhas[nContar], "|", 16)
       _Fax         := U_P_CORTA(aLinhas[nContar], "|", 17)
       _Email       := U_P_CORTA(aLinhas[nContar], "|", 18)
       _PDV_Local   := U_P_CORTA(aLinhas[nContar], "|", 19)
       _PDV_Tipo    := U_P_CORTA(aLinhas[nContar], "|", 20)
       
       aAdd( aClientes, { _Codigo      ,; // 01
                          _Nome        ,; // 02
                          _CNPJ        ,; // 03
                          _Inscricao   ,; // 04
                          _Franquia    ,; // 05
                          _Fantasia    ,; // 06
                          _Endereco    ,; // 07
                          _Numero      ,; // 08
                          _Complemento ,; // 09
                          _Bairro      ,; // 10
                          _Cidade      ,; // 11
                          _Estado      ,; // 12
                          _CEP         ,; // 13
                          _Rua3        ,; // 14
                          _Tel01       ,; // 15
                          _Tel02       ,; // 16
                          _Fax         ,; // 17
                          _Email       ,; // 18
                          _PDV_Local   ,; // 19
                          _PDV_Tipo    ,; // 20
                          ""           ,; // 21
                          ""           ,; // 22
                          ""           ,; // 23
                          ""           }) // 24

   Next nContar

   // Prepara o próximo código de cliente disponível para inclusão
   If Select("T_PROXIMO") > 0
      T_PROXIMO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A1_COD ,"
   cSql += "       A1_LOJA,"
   cSql += "       A1_NOME,"
   cSql += "       A1_CGC  "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY A1_COD DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

   If T_PROXIMO->( EOF() )
      nProximoCod := "000001"
   Else
      nProximoCod := STRZERO((INT(VAL(T_PROXIMO->A1_COD)) + 1),6)
   Endif

   // Carrega o array aNumeracao
   For nContar = 1 to Len(aClientes)
   
       // Verifica se o raiz do CMPJ já está cadastrado.
       // Se está, captura o último código de loja para dar sequencia a numração das lojas.
       If Select("T_RAIZ") > 0
          T_RAIZ->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A1_COD ,"
       cSql += "       A1_LOJA,"
       cSql += "       A1_NOME,"
       cSql += "       A1_CGC  "
       cSql += "  FROM " + RetSqlName("SA1")
       cSql += " WHERE SUBSTRING(A1_CGC,1,8) = '" + Substr(Alltrim(aClientes[nContar,03]),1,8) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"     
       cSql += " ORDER BY A1_COD, A1_LOJA DESC"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RAIZ", .T., .T. )
       
       If T_RAIZ->( EOF() )
          cCodigo     := nProximoCod
          cLoja       := "001"
          lNovo       := .T.
       Else       
          cCodigo := T_RAIZ->A1_COD
          cLoja   := Strzero((INT(VAL(T_RAIZ->A1_LOJA)) + 1),3)
          lNovo       := .F.
       Endif
                 
       // Procura o raiz do cnpj pára gravação do código da loja para contra-partida de gravação.
       lJaEsta := .F.

       For nProcurar = 1 to Len(aNumeracao)

           If Substr(aNumeracao[nProcurar,01],01,08) == Substr(aClientes[nContar,03],01,08)
              lJaEsta := .T.
              Exit
           Endif
           
       Next nProcurar       
                     
       If lJaEsta == .F.

          If lNovo == .F.
          Else
             nProximoCod := STRZERO((INT(VAL(cCodigo)) + 1),6)
          Endif             

          aAdd( aNumeracao, { aClientes[nContar,03], cCodigo, cLoja, IIF(lNovo == .T., "N", "V") } )

       Endif
       
   Next nContra    
          
   // Acerta a codificação dos clientes do array aClientes
   For nContar = 1 to Len(aClientes)
   
       // Procura no array aNumeracao a codificação para o elemento posicionado
       For nProcurar = 1 to Len(aNumeracao)
        
           If Substr(aNumeracao[nProcurar,01],01,08) == Substr(aClientes[nContar,03],01,08)
  
              If aNumeracao[nProcurar,04] == "N"
              
                 // Atualiza o código e loja no array aClientes
                 aClientes[nContar,21] := aNumeracao[nProcurar,02]
                 aClientes[nContar,22] := aNumeracao[nProcurar,03]

                 // Adiciona um na loja do array aNumeração
                 aNumeracao[nProcurar,03] := Strzero((INT(VAL(aNumeracao[nProcurar,03])) + 1),3)
                 
              Else
              
                 // Verifica em primeiro lugar se o CNPJ inteiro é o cadastrtado no Sistema.
                 If Select("T_CADASTRO") > 0
                    T_CADASTRO->( dbCloseArea() )
                 EndIf
 
                 cSql := ""
                 cSql := "SELECT A1_COD ,"
                 cSql += "       A1_LOJA,"
                 cSql += "       A1_NOME,"
                 cSql += "       A1_CGC  "
                 cSql += "  FROM " + RetSqlName("SA1")
                 cSql += " WHERE A1_CGC     = '" + Alltrim(aClientes[nContar,03]) + "'"
                 cSql += "   AND D_E_L_E_T_ = ''"     

                 cSql := ChangeQuery( cSql )
                 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADASTRO", .T., .T. )

                 If T_CADASTRO->( EOF() )
                 
                    // Atualiza o código e loja no array aClientes
                    aClientes[nContar,21] := aNumeracao[nProcurar,02]
                    aClientes[nContar,22] := aNumeracao[nProcurar,03]

                    // Adiciona um na loja do array aNumeração
                    aNumeracao[nProcurar,03] := Strzero((INT(VAL(aNumeracao[nProcurar,03])) + 1),3)
                   
                 Else
                 
                    // Atualiza o código e loja no array aClientes
                    aClientes[nContar,21] := T_CADASTRO->A1_COD
                    aClientes[nContar,22] := T_CADASTRO->A1_LOJA
                    
                 Endif
                 
              Endif

           Endif
                 
       Next nProcurar
       
   Next nContar    

   // Inclui os clientes
   For nContar = 1 to Len(aClientes)
   
       // Verifica se o CNPJ inteiro já extá cadastrado. Se estiver, despreza-o
       If Select("T_CADASTRO") > 0
          T_CADASTRO->( dbCloseArea() )
       EndIf
 
       cSql := ""
       cSql := "SELECT A1_COD ,"
       cSql += "       A1_LOJA,"
       cSql += "       A1_NOME,"
       cSql += "       A1_CGC  "
       cSql += "  FROM " + RetSqlName("SA1")
       cSql += " WHERE A1_CGC     = '" + Alltrim(aClientes[nContar,03]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"     

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADASTRO", .T., .T. )

       If !T_CADASTRO->( EOF() )
          Loop
       Endif
       
       // Pesquisa o código e nome do município na Tabela CC2 - Código IBGE
       If Select("T_IBGE") > 0
          T_IBGE->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT CC2_CODMUN"
       cSql += "  FROM " + RetSqlName("CC2")
       cSql += " WHERE CC2_EST    = '" + Alltrim(aClientes[nContar,12]) + "'"
       cSql += "   AND CC2_MUN    = '" + Alltrim(aClientes[nContar,11]) + "'"
	   cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IBGE", .T., .T. )

       If T_IBGE->( EOF() )
          cMunicipio := ""
       Else
          cMunicipio := T_IBGE->CC2_CODMUN
       Endif

       // Inclui o cliente posicionado
       DbSelectArea("SA1")
       RecLock("SA1",.T.)
       A1_FILIAL  := ""
       A1_COD     := aClientes[nContar,21]
       A1_LOJA    := aClientes[nContar,22]
       A1_PESSOA  := "J"
       A1_NOME    := UPPER(Alltrim(aClientes[nContar,02]))
       A1_NREDUZ  := UPPER(Alltrim(aClientes[nContar,06]))
       A1_END     := UPPER(Alltrim(aClientes[nContar,07])) + ", " + UPPER(Alltrim(aClientes[nContar,08]))
       A1_TIPO    := "J"
       A1_EST     := UPPER(Alltrim(aClientes[nContar,12]))
       A1_COD_MUN := cMunicipio
       A1_MUN     := UPPER(Alltrim(aClientes[nContar,11]))
       A1_BAIRRO  := UPPER(Alltrim(aClientes[nContar,10]))
       A1_CEP     := Substr(aClientes[nContar,13],01,05) + Substr(aClientes[nContar,13],07,03)
       A1_DDD     := Substr(StrTran(aClientes[nContar,15], " ", ""),01,02)
       A1_TEL     := Substr(StrTran(aClientes[nContar,15], " ", ""),03)
       A1_CGC     := aClientes[nContar,03]
       A1_INSCR   := aClientes[nContar,04]
       A1_PAIS    := "105"
       A1_CODPAIS := "01058"
       A1_EMAIL   := aClientes[nContar,18]
       A1_NATUREZ := "10101"
       A1_GRPTRIB := IIF(UPPER(ALLTRIM(aClientes[nContar,04])) == "ISENTO", "003", "002")
       A1_RISCO   := "E"
       A1_CONTRIB := IIF(UPPER(ALLTRIM(aClientes[nContar,04])) == "ISENTO", "2", "1")       
       A1_VEND    := "000119"
       Msunlock()
          
   Next nContar    

   MsgAlert("Clientes incluídos com sucesso!")

Return(.T.)