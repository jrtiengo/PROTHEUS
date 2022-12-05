
#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM238.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 02/06/2014                                                          *
// Objetivo..: Programa que realiza a importação das Planilhas do Filed Service    *
//             Implantação do novo Field Service                                   *
//**********************************************************************************

User Function AUTOM238()

   Local lChumba    := .F.

   Private cCaminho := Space(250)
   Private nTipoImp := 0
   
   Private oGet1
   Private oRadioGrp1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Implantação novo - Gestão de Serviços" FROM C(178),C(181) TO C(331),C(558) PIXEL

   @ C(002),C(005) Say "Indique a tabela a ser importada" Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(005) Say "Caminho do arquivo a ser importado" Size C(086),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(010),C(008) Radio oRadioGrp1 Var nTipoImp Items "Importação Tabela AAI","Importação Tabela AA7","Importação Tabela AAC" 3D Size C(056),C(010) PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cCaminho Size C(164),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(045),C(170) Button "..."      Size C(012),C(009) PIXEL OF oDlg ACTION( arqgestao() )
   @ C(059),C(055) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPGESTAO() )
   @ C(059),C(093) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function ARQGESTAO()

   cCaminho := cGetFile('*.*', "Selecione o arquivo a ser importado",1,"",.F.,16,.F.)

Return .T. 

// Função que importa a planilha
Static Function IMPGESTAO()

   Local aFAQ      := {}
   Local cConteudo := ""
   Local _Linha    := ""
   Local nContar   := 0

   If nTipoImp == 0
      MsgAlert("Atenção! Tipo de arquivo a ser importado não indicado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado não informado.")
      Return(.T.)
   Endif
   
   If !File(Alltrim(cCaminho))
      MsgAlert("Arquivo a ser importado inexistente.")
      Return(.T.)
   Endif

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(cCaminho), 0)

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
          cConteudo := cConteudo + "|"
          _Linha    := ""
          aAdd( aFAQ,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   For nContar = 1 to Len(aFAQ)
   
       Do Case
          Case nTipoImp == 1 && Importaçáo do Arquivo AAI
               _Codigo     := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 1))),6)
               _Grupo      := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 2))),4)
               _Produto    := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 3))),6)
               _Item       := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 4))),2)
               _Ocorrencia := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 5))),6)
               _Solucao    := U_P_CORTA(aFAQ[nContar], "|", 6)

              //  Grava a Tabela
              aArea := GetArea()
              DbSelectArea("AAI")
              RecLock("AAI",.T.)
              AAI_CODFAQ := _Codigo
              AAI_GRUPO  := _Grupo
              AAI_ITEM   := _Item
              AAI_CODPRO := _Produto
              AAI_CODPRB := _Ocorrencia
              AAI_SOLUC  := _Solucao
              DbUnlock()
              
          Case nTipoImp == 2 && Importaçáo do Arquivo AA7
               _Produto    := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 1))),6)
               _Ocorrencia := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 2))),6)
               _TempoStd   := Substr(U_P_CORTA(aFAQ[nContar], "|", 3),01,05)
               _Habilidade := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 5))),6)
               _Nivel      := INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 6)))

               // Verifica se o código do produto + Ocorrência já estão inseridos na tabela.
               // Se já estiver, não registra.
               If Select("T_JATEM") > 0
                  T_JATEM->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT AA7_CODPRO,"
               cSql += "       AA7_CODPRB "
               cSql += "  FROM " + RetSqlName("AA7")
               cSql += " WHERE D_E_L_E_T_ = ''"
               cSql += "   AND AA7_CODPRO = '" + Alltrim(_Produto)    + "'"
               cSql += "   AND AA7_CODPRB = '" + Alltrim(_Ocorrencia) + "'"

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

               //  Grava a Tabela
               aArea := GetArea()
               DbSelectArea("AA7")

               If T_JATEM->( EOF() )
                  RecLock("AA7",.T.)
                  AA7_CODPRO := _Produto
                  AA7_CODPRB := _Ocorrencia
                  AA7_TMPSTD := _TempoStd
                  AA7_HABIL  := _Habilidade
                  AA7_NIVEL  := _Nivel
                  DbUnlock()
               Endif   
              
          // Importação do Arquivo AAC
          Case nTipoImp == 3
               _Produto    := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 1))),6)
               _Ocorrencia := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 2))),6)
               _Item       := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 4))),2)
               _Habilidade := Strzero(INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 5))),6)
               _Nivel      := INT(VAL(U_P_CORTA(aFAQ[nContar], "|", 6)))

               // Verifica se registro já está cadastrado. Se não tiver, inclui senão altera
               If Select("T_JATEM") > 0
                  T_JATEM->( dbCloseArea() )
               EndIf

               cSql := ""
               cSql := "SELECT AAC_CODPRO,"
               cSql += "       AAC_CODPRB,"
               cSql += "       AAC_ITEM  ,"
               cSql += "       AAC_HABIL ,"
               cSql += "       AAC_NIVEL  "
               cSql += "  FROM " + RetSqlName("AAC")
               cSql += " WHERE D_E_L_E_T_ = ''"
               cSql += "   AND AAC_CODPRO = '" + Alltrim(_Produto)    + "'"
               cSql += "   AND AAC_CODPRB = '" + Alltrim(_Ocorrencia) + "'"
               cSql += "   AND AAC_ITEM   = '" + Alltrim(_Item)       + "'"
               cSql += "   AND AAC_HABIL  = '" + Alltrim(_Habilidade) + "'"
               cSql += "   AND AAC_NIVEL  = '" + Alltrim(_Nivel)      + "'"

               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

               // Grava a Tabela
               aArea := GetArea()
               DbSelectArea("AAC")

               If T_JATEM->( EOF() )
                  RecLock("AAC",.T.)
                  AAC_FILIAL := "01"
                  AAC_CODPRO := _Produto
                  AAC_CODPRB := _Ocorrencia
                  AAC_ITEM   := _Item
                  AAC_HABIL  := _Habilidade
                  AAC_NIVEL  := _Nivel
  	   	          AAC_DESCRI := Posicione( "AAG", 1, xFilial("AAG") + _Ocorrencia, "AAG_DESCRI" )
                  DbUnlock()

                  RecLock("AAC",.T.)
                  AAC_FILIAL := "02"
                  AAC_CODPRO := _Produto
                  AAC_CODPRB := _Ocorrencia
                  AAC_ITEM   := _Item
                  AAC_HABIL  := _Habilidade
                  AAC_NIVEL  := _Nivel
  	   	          AAC_DESCRI := Posicione( "AAG", 1, xFilial("AAG") + _Ocorrencia, "AAG_DESCRI" )
                  DbUnlock()

                  RecLock("AAC",.T.)
                  AAC_FILIAL := "03"
                  AAC_CODPRO := _Produto
                  AAC_CODPRB := _Ocorrencia
                  AAC_ITEM   := _Item
                  AAC_HABIL  := _Habilidade
                  AAC_NIVEL  := _Nivel
  	   	          AAC_DESCRI := Posicione( "AAG", 1, xFilial("AAG") + _Ocorrencia, "AAG_DESCRI" )
                  DbUnlock()
                  
               Endif   
                  
       EndCase

   Next nContar

   MsgAlert("Importação efetuada com sucesso.")

   oDlg:End() 

Return .T.