#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM242.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 24/07/2014                                                          *
// Objetivo..: Programa que importa datas de fechamento das Ordens de Serviços     *
//             para geração do Indicador de média de SLA.                          * 
//**********************************************************************************

User Function AUTOM242()

   Local lChumba    := .F.

   Private cCaminho := Space(250)
   Private cTreg    := 0
   Private cPreg    := 0
   Private nTipoImp := 0
   
   Private oGet1
   Private oGet2
   Private oGet3   
   Private oRadioGrp1

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Importação Data de Fechamento OS - SLA" FROM C(178),C(181) TO C(294),C(558) PIXEL

   @ C(003),C(005) Say "Arquivo a ser importado" Size C(057),C(008) COLOR CLR_BLACK              PIXEL OF oDlg
   @ C(027),C(005) Say "Total Registros"         Size C(038),C(008) COLOR CLR_BLACK              PIXEL OF oDlg
   @ C(027),C(075) Say "Total Processados"       Size C(046),C(008) COLOR CLR_BLACK              PIXEL OF oDlg

   @ C(013),C(005) MsGet oGet1 Var cCaminho      Size C(164),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(026),C(044) MsGet oGet2 Var cTreg         Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(026),C(123) MsGet oGet3 Var cPreg         Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(013),C(170) Button "..."                  Size C(012),C(009) PIXEL OF oDlg ACTION( xarqgestao() )
   @ C(040),C(055) Button "Importar"             Size C(037),C(012) PIXEL OF oDlg ACTION( xIMPGESTAO() )
   @ C(040),C(093) Button "Voltar"               Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que trás a descrição do produto selecionado
Static Function xARQGESTAO()

   cCaminho := cGetFile('*.*', "Selecione o arquivo a ser importado",1,"",.F.,16,.F.)

Return .T. 

// Função que importa a planilha
Static Function xIMPGESTAO()

   Local aConsulta := {}
   Local cConteudo := ""
   Local _Linha    := ""
   Local nContar   := 0
   Local _Filial   := ""
   Local _NumeOS   := ""
   Local _Emissao  := ""
   Local _HoraEmi  := ""
   Local _Fechada  := ""
   Local _HoraFec  := ""

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
          aAdd( aConsulta,  cConteudo )
          cConteudo := ""
          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
       Endif
   Next nContar    

   cTreg := Len(aConsulta)
   oGet2:Refresh()
/*
   For nContar = 1 to Len(aConsulta)
   
       cPreg := nContar
       oGet3:Refresh()

       // Separa os campos para gravação
       _Filial  := Strzero(INT(VAL(U_P_CORTA(aConsulta[nContar], "|", 1))),2)
       _NumeOS  := Strzero(INT(VAL(U_P_CORTA(aConsulta[nContar], "|", 2))),6)

       //_Emissao := Ctod(U_P_CORTA(aConsulta[nContar], "|", 3))
       //_HoraEmi := U_P_CORTA(aConsulta[nContar], "|", 4)

       _Fechada := Ctod(U_P_CORTA(aConsulta[nContar], "|", 5))
       _HoraFec := U_P_CORTA(aConsulta[nContar], "|", 6)

//       If _HoraFec <> "08:15"
//          Loop
//       Endif
          
       //  Atualiza a tabela AB6 com os dados da Fialial/Os selecionados
       aArea := GetArea()                                                                                   
       Comentado michel aoki
       DbSelectArea("AB6")
       RecLock("AB6",.F.)

       DbSelectArea("AB6")
       DbSetOrder(1)
       If DbSeek(_Filial + _NumeOS)
          RecLock("AB6",.F.)
          AB6_PWORK := _Fechada
          AB6_HWORK := _HoraFec
          MsUnLock()              
       Endif
 Next nContar
		*/
         
   MsgAlert("Importação efetuada com sucesso.")

   oDlg:End() 

Return .T.