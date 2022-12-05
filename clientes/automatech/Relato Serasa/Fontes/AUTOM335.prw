#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM335.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/03/2016                                                          *
// Objetivo..: Programa que gera o relatório de consulta do Relato.                *
// Parâmetros: x_Cliente -> Código do Cliente                                      *
//             x_Loja    -> Loja do Cliente                                        *
//             x_Serasa  -> Código de Consulta                                     * 
//             x_Data    -> Data da Consulta                                       *
//             x_Hora    -> Hora da Consulta                                       * 
//             x_Empresa -> Empresa a ser pesquisada                               *
//**********************************************************************************

User Function AUTOM335(x_Cliente, x_Loja, x_Serasa, x_Data, x_Hora, x_Empresa)

   Local cSql        := ""                         
   Local nContar     := 0

   Private cCliente  := x_Cliente
   Private cLoja     := x_Loja
   Private cCodigo   := x_Serasa
   Private cData     := x_Data
   Private cHora     := x_Hora
   Private cEmpresa  := x_Empresa
   
   Private oDlgVis

   Private aConsulta := {}
   Private aImprime  := {}
   
   // Pesquisa os dados para o Cliente, Loja e Código da consulta selecionada pelo uusário   
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""   
   cSql := "SELECT SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),02,02)  AS IDINF,"
   cSql += "       SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),04,02)  AS BCFIC,"
   cSql += "       SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),06,02)  AS TPINF,"
   cSql += "      (SELECT ZPD_TITU "
   
   Do Case
      Case cEmpresa == "01"
           cSql += "         FROM ZPD010"
      Case cEmpresa == "02"
           cSql += "         FROM ZPD020"
      Case cEmpresa == "03"
           cSql += "         FROM ZPD030"
   EndCase           
           
           
   cSql += "		   WHERE ZPD_IDINF  = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),02,02)"
   cSql += "	         AND ZPD_BCFIC  = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),04,02)"
   cSql += "		     AND ZPD_TPINF  = SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),06,02)"
   cSql += "		     AND D_E_L_E_T_ = '') AS TITULO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)) AS RETORNO"

   Do Case
      Case cEmpresa == "01"
           cSql += "  FROM ZPF010 ZPF "
      Case cEmpresa == "02"
           cSql += "  FROM ZPF020 ZPF "
      Case cEmpresa == "03"
           cSql += "  FROM ZPF030 ZPF "
   EndCase

   cSql += " WHERE ZPF.ZPF_CODI = '" + Alltrim(cCodigo)  + "'"
   cSql += "   AND ZPF.ZPF_CLIE = '" + Alltrim(cCliente) + "'"
   cSql += "   AND ZPF.ZPF_LOJA = '" + Alltrim(cLoja)    + "'"
   cSql += "   AND ZPF.ZPF_DELE = ''"
   cSql += "   AND SUBSTRING(CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPF.ZPF_RETO)),01,01) = 'L'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      aAdd(aConsulta, { T_CONSULTA->IDINF  ,; // 01 - Identificação ID
                        T_CONSULTA->BCFIC  ,; // 02 - Identificação BC
                        T_CONSULTA->TPINF  ,; // 03 - Identificação TP
                        T_CONSULTA->TITULO ,; // 04 - Título
                        0                  ,; // 05 - Indicador de Cabeçalho ou Detalhe
                        0                  ,; // 06 - Posição Inicial de pesquisa
                        0                  ,; // 07 - Tamanho da string a ser pesquisada
                        ""                 ,; // 08 - Conteúdo a ser substituído
                        ""                 ,; // 09 - String de retorno da pesquisa
                        ""                 ,; // 10 - Tipo de Campo
                        "N"                ,; // 11 - Indica se informação deve ser impressa ou não
                        T_CONSULTA->RETORNO,; // 12 - Stirng que contém o retorno do SERASA
                        ""                 ,; // 13 - Tipo de Campo
                        0})                   // 14 - Decimal do campo
                        
      // Pesquisa os detalhes da identificação
      If Select("T_DETALHES") > 0
         T_DETALHES->( dbCloseArea() )
      EndIf

      cSql := "SELECT ZPE_FILIAL,"
      cSql += "       ZPE_IDINF ,"
      cSql += "	      ZPE_BCFIC ,"
  	  cSql += "       ZPE_TPINF ,"
  	  cSql += "       ZPE_CODI  ,"
  	  cSql += "       ZPE_TIPO  ,"
  	  cSql += "       ZPE_TAMA  ,"
  	  cSql += "       ZPE_DECI  ,"
  	  cSql += "       ZPE_TITU  ,"
  	  cSql += "       ZPE_DELE  ,"
  	  cSql += "       ZPE_POSI  ,"
  	  cSql += "       ZPE_CONT  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZPE_CONT)) AS OPCOES,"
  	  cSql += "       ZPE_ORDE  ,"
  	  cSql += "       ZPE_VISU   "

      Do Case
         Case cEmpresa == "01"
              cSql += "  FROM ZPE010"
         Case cEmpresa == "02"
              cSql += "  FROM ZPE020"
         Case cEmpresa == "03"
              cSql += "  FROM ZPE030"
      EndCase              
              
      cSql += " WHERE ZPE_IDINF  = '" + Alltrim(T_CONSULTA->IDINF) + "'"
      cSql += "   AND ZPE_BCFIC  = '" + Alltrim(T_CONSULTA->BCFIC) + "'"
      cSql += "   AND ZPE_TPINF  = '" + Alltrim(T_CONSULTA->TPINF) + "'"
      cSql += "   AND ZPE_VISU  <> 'N'"
      cSql += "   AND ZPE_DELE   = '' "
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DETALHES", .T., .T. )

      T_DETALHES->( DbGoTop() )
      
      WHILE !T_DETALHES->( EOF() )

         // Prepara o Título a ser gravado
         If EMPTY(ALLTRIM(T_DETALHES->ZPE_TITU))
            _Titulo := "NAO CADASTRADO"
         Else
            _Titulo := ALLTRIM(T_DETALHES->ZPE_TITU)
         Endif

         // Prepara o conteúdo a ser gravado                 
         If T_DETALHES->ZPE_TIPO == "D"
            _Conteudo := Substr(SUBSTR(T_CONSULTA->RETORNO, T_DETALHES->ZPE_POSI, T_DETALHES->ZPE_TAMA),07,02) + "/" + ;
                         Substr(SUBSTR(T_CONSULTA->RETORNO, T_DETALHES->ZPE_POSI, T_DETALHES->ZPE_TAMA),05,02) + "/" + ;            
                         Substr(SUBSTR(T_CONSULTA->RETORNO, T_DETALHES->ZPE_POSI, T_DETALHES->ZPE_TAMA),01,04)
         Else
            _Conteudo := SUBSTR(T_CONSULTA->RETORNO, T_DETALHES->ZPE_POSI, T_DETALHES->ZPE_TAMA)            
         Endif         

         // Verifica o elemento 8. Se este estiver preenchido, substitui o retorno pelo conteúdo deste elemento
         If Empty(Alltrim(T_DETALHES->OPCOES))
         Else
            
            For nCompara = 1 to U_P_OCCURS(T_DETALHES->OPCOES, "|", 1)
            
                _Separa := U_P_CORTA(T_DETALHES->OPCOES, "|", nCompara) + "="

                If U_P_OCCURS(_Separa, "=", 1) == 0
                   Exit
                Endif
                
                If Alltrim(U_P_CORTA(_Separa,"=",1)) == Alltrim(_Conteudo)
                   _Conteudo := Alltrim(U_P_CORTA(_Separa,"=",2))
                   Exit
                Endif                                          
                
            Next nCompara
                          
         Endif

         // Carrega o array aConsulta com os dados a serem listados
         aAdd(aConsulta, { T_CONSULTA->IDINF           ,; // 01 - Identificação ID
                           T_CONSULTA->BCFIC           ,; // 02 - Identificação BC
                           T_CONSULTA->TPINF           ,; // 03 - Identificação TP
                           _Titulo                     ,; // 04 - Título
                           1                           ,; // 05 - Indicador de Cabeçalho ou Detalhe
                           T_DETALHES->ZPE_POSI        ,; // 06 - Posição Inicial de pesquisa
                           T_DETALHES->ZPE_TAMA        ,; // 07 - Tamanho da stringa ser pesquisada
                           ALLTRIM(T_DETALHES->OPCOES) ,; // 08 - Conteúdo a ser substituído
                           _Conteudo                   ,; // 09 - String de retorno da pesquisa
                           T_DETALHES->ZPE_TIPO        ,; // 10 - Tipo de Campo
                           "N"                         ,; // 11 - Indica se deve ser impresso ou não 
                           T_CONSULTA->RETORNO         ,; // 12 - Contém o retorn o do SERASA
                           T_DETALHES->ZPE_TIPO        ,; // 13 - Tipo de Campo
                           T_DETALHES->ZPE_DECI})         // 14 - Decimal do Campo

         T_DETALHES->( DbSkip() )
         
      Enddo

      T_CONSULTA->( DbSkip() )
      
   ENDDO
           
   If Len(aConsulta) == 0
      MsgAlert("Não existem dadois a serem visualizados para estes parâmetros.")
      Return(.T.)
   Endif
      
   // Carrega o array aImprime que verifica quais os indicadores da pesquisa poderão ser impressos
   For nContar = 1 to len(aConsulta)
       If aConsulta[nContar,05] == 0
          aAdd(aImprime, { aConsulta[nContar,01],;
                           aConsulta[nContar,02],;          
                           aConsulta[nContar,03],;          
                           " "})
       Endif
   Next nContar

   For nContar = 1 to Len(aImprime)

       lTemRegistro := .F.
   
       For nVerifica = 1 to Len(aConsulta)
       
           If aConsulta[nVerifica,01] == aImprime[nContar,01] .And. ;
              aConsulta[nVerifica,02] == aImprime[nContar,02] .And. ;
              aConsulta[nVerifica,03] == aImprime[nContar,03]
              If !Empty(Alltrim(aConsulta[nVerifica,09]))
                 lTemRegistro := .T.
                 Exit
              Endif
           Endif
           
       Next nVerifica
       
       For nGrava = 1 to Len(aConsulta)
       
           If aConsulta[nGrava,01] == aImprime[nContar,01] .And. ;
              aConsulta[nGrava,02] == aImprime[nContar,02] .And. ;
              aConsulta[nGrava,03] == aImprime[nContar,03]
              If lTemRegistro == .F.
                 aConsulta[nGrava,11] := "N"
              Else
                 aConsulta[nGrava,11] := "S"
              Endif
           Endif
           
       Next nGrava    
       
   Next nContar       

//   If UPPER(ALLTRIM(cUserName)) = "ADMINISTRADOR"
//
//      DEFINE MSDIALOG oDlgVis TITLE "Visualização" FROM C(178),C(181) TO C(304),C(435) PIXEL
//
//      @ C(005),C(005) Button "Relatório"           Size C(118),C(017) PIXEL OF oDlgVis ACTION(prn_res_relato())
//	  @ C(023),C(005) Button "Pesquisa Individual" Size C(118),C(017) PIXEL OF oDlgVis ACTION(MostraResultado())
//	  @ C(042),C(005) Button "Voltar"              Size C(118),C(017) PIXEL OF oDlgVis ACTION( oDlgVis:End() )
//
//      ACTIVATE MSDIALOG oDlgVis CENTERED 
//
//   Else

      // Envia para a função que imprime o relatório
      prn_res_relato()   
      
//   Endif
   
Return(.T.)                              
   
//// Função que gera o relatório da consulta dos dados do relato
//Static Function PRN_RES_RELATO()
//
//      MsgRun("Aguarde! Gerando Relatório ...", "Consulta Relato",{|| XPRN_RES_RELATO() })
//      
//Return(.T.)      

// Função que gera o relatório da consulta dos dados do relato
Static Function PRN_RES_RELATO()

   Local nOrdem
//   Local cEmpresa   := ""
//   Local cData      := ""
   Local nVende01, nVende02, nVende03, nVende04
   Local nClien01, nClien02, nClien03, nClien04
   Local nAcumu01, nAcumu02, nAcumu03, nAcumu04
   Local nproduto   := 0
   Local nServico   := 0
   Local aPesquisa  := {}
   Local aPaginas   := {}
   Local lPrimeira  := .T.

   Private nLimvert := 3300
   Private xPagina  := 1
   Private _nLin    := 0
   Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont21, oFont22B, oFont23B

   // Cria o objeto de impressao
   oPrint := TmsPrinter():New()
	
   // Orientação da página - Retrato
   oPrint:SetPortrait()
	
   // Tamanho da página na impressão (A4)
   oPrint:SetPaperSize(9)
	
   // Cria os objetos de fontes que serão utilizados na impressão do relatório
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont21   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
   oFont22B  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
   oFont23B  := TFont():New( "Courier New",,12,,.t.,,,,.f.,.f. )
         
   ProcRegua( Len(aPesquisa) )

   // Envia para a função que imprime o cabeçalho do relatório
   CABECALHOREL()

   xIdInf := aConsulta[01,01]
   xBcFic := aConsulta[01,02]
   xTpInf := aConsulta[01,03]

   For nContar = 1 to Len(aConsulta)

       If aConsulta[nContar,01] == xIdInf .And. aConsulta[nContar,02] == xBcFic .And. aConsulta[nContar,03] == xTpInf
       
          If aConsulta[nContar,11] == "N"
             Loop
          Endif

          If aConsulta[nContar,05] == 0

             If Upper(Alltrim(cUserName)) == "ADMINISTRADOR"
                oPrint:Say( _nLin, 0100,padc( aConsulta[nContar,01] + "." + aConsulta[nContar,02] + "." + aConsulta[nContar,03] + " - " + Alltrim(aConsulta[nContar,04]),80), oFont23B)   
             Else
                oPrint:Say( _nLin, 0100,padc(Alltrim(aConsulta[nContar,04]),80), oFont23B)   
             Endif                   

             SomaLinhaAna(50)
             oPrint:Line( _nLin, 0100, _nLin, 2400 )
             SomaLinhaAna(50)
          Else

             If Empty(Alltrim(aConsulta[nContar,09]))
             Else
                If Len(Alltrim(aConsulta[nContar,04])) <= 45
                   oPrint:Say( _nLin, 0100, Alltrim(aConsulta[nContar,04]) + Replicate(".", 45 - Len(Alltrim(aConsulta[nContar,04]))) + ":", oFont21)   
                Else                                         
                   oPrint:Say( _nLin, 0100, Substr(aConsulta[nContar,04],01,45) + ":", oFont21)                   
                Endif                
                
                If aConsulta[nContar,13] == "N"
                
                   If aConsulta[nContar,14] == 0
                      _Mascara := Replicate("9", aConsulta[nContar,07])
                   Else   
                      _Mascara := Replicate("9", aConsulta[nContar,07]) + "," + Replicate("9", aConsulta[nContar,14])                   
                   Endif   
      
                   oPrint:Say( _nLin, 1070, Alltrim(Transform(VAL(aConsulta[nContar,09]), _Mascara)), oFont22B)                   
                   
                Else
                
                   oPrint:Say( _nLin, 1070, Alltrim(aConsulta[nContar,09]), oFont22B)   
                   
                Endif

                SomaLinhaAna(50)
                
             Endif
                
          Endif
          
       Else

          If aConsulta[nContar,11] == "S"
             oPrint:Line( _nLin, 0100, _nLin, 2400 )
             SomaLinhaAna(40)   
          Endif

          xIdInf := aConsulta[nContar,01]
          xBcFic := aConsulta[nContar,02]
          xTpInf := aConsulta[nContar,03]
       
          nContar := nContar - 1
          
       Endif
       
   Next nContar       

   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 10

   _Rodape := "Impresso por: " + Alltrim(cUserName) + " no dia " + Dtoc(Date()) + " as " + Time() + "    Página: " + Strzero(xPagina,5)

   oPrint:Say( _nLin, 0100, PADR(_Rodape,140), oFont09b)

   oPrint:Preview()

Return(.T.)

// Imprime o cabeçalho do relatório de Faturamento por período Sintético
Static Function CABECALHOREL()

   oPrint:StartPage()

   _nLin   := 60

   _nLin += 30

   // Logotipo e identificação do pedido
   oPrint:SayBitmap( _nLin, 0100, "Nlogoautoma.bmp", 0700, 0200 )
   _nLin += 200
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 30
   oPrint:Say( _nLin, 0100,PADC("RELATÓRIO DE COMPORTAMENTO EM NEGÓCIOS - R E L A T O", 080), oFont23B)
   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 30

   // Imprime o Código e Loja do Cliente
   oPrint:Say( _nLin, 0100,"Código/Loja..:", oFont21)   
   oPrint:Say( _nLin, 0400,Alltrim(cCliente) + "." + Alltrim(cLoja), oFont23B)   
   _nLin += 40
   
   // Imprime o CNPJ do Cliente ou CPF
   _Documento := POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_CGC")

   If POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_PESSOA") == "F"
      _CNPJ := Substr(_Documento,01,03) + "." + ;
               Substr(_Documento,04,03) + "." + ;
               Substr(_Documento,07,03) + "-" + ;
               Substr(_Documento,10,02)
   Else
      _CNPJ := Substr(_Documento,01,02) + "." + ;
               Substr(_Documento,03,03) + "." + ;
               Substr(_Documento,06,03) + "/" + ;
               Substr(_Documento,09,04) + "-" + ;
               Substr(_Documento,13,02)
   Endif

   oPrint:Say( _nLin, 0100,"CNPJ/CPF.....:", oFont21)   
   oPrint:Say( _nLin, 0400,_CNPJ, oFont23B)   
   _nLin += 40

   // Imprime o nome do cliente
   oPrint:Say( _nLin, 0100,"Cliente......:", oFont21)   
   oPrint:Say( _nLin, 0400, POSICIONE("SA1",1,XFILIAL("SA1") + cCliente + cLoja,"A1_NOME"), oFont23B)   
   _nLin += 40

   oPrint:Say( _nLin, 0100,"Data Consulta:", oFont21)   
   oPrint:Say( _nLin, 0400,cData, oFont23B)   
   _nLin += 40
   oPrint:Say( _nLin, 0100,"Hora Consulta:", oFont21)   
   oPrint:Say( _nLin, 0400,cHora, oFont23B)   
   _nLin += 50
   oPrint:Line( _nLin, 0100, _nLin, 2400 )
   _nLin += 10

RETURN(.t.)

// Função que soma linhas para impressão
Static Function SomaLinhaAna(nLinhas)
   
   _nLin := _nLin + nLinhas

   If _nLin > nLimVert - 10

      oPrint:Line( _nLin, 0100, _nLin, 2400 )
      _nLin += 10

      _Rodape := "Impresso por: " + Alltrim(cUserName) + " no dia " + Dtoc(Date()) + " as " + Time() + "    Página: " + Strzero(xPagina,5)

      oPrint:Say( _nLin, 0100, PADR(_Rodape,140), oFont09b)

      xPagina := xPagina + 1

      oPrint:EndPage()
      CABECALHOREL()
   Endif
   
Return .T.      

// Função que pesquisa o resultado pela informação de posição inicial e tamanho.
// Função disponível somente para o Administrador
Static Function MostraResultado()

   Local lChumba    := .F.

   Private cIDINF	  := Space(02)
   Private cBCFIC	  := Space(02)
   Private cTPINF	  := Space(02)
   Private cPOSICAO   := 0
   Private cTAMANHO   := 0
   Private cRESULTADO := ""
   Private cCORTE     := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet5
   Private oGet6
   Private oMemo1
   Private oMemo2

   Private oDlgRes

   DEFINE MSDIALOG oDlgRes TITLE "Conteúdo retorno Relato" FROM C(178),C(181) TO C(509),C(967) PIXEL

   @ C(005),C(005) Say "IDINF"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgRes
   @ C(005),C(032) Say "BCFIC"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgRes
   @ C(005),C(060) Say "TPINF"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgRes
   @ C(027),C(005) Say "Retorno da Pesquisa" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgRes
   @ C(105),C(005) Say "Posição Inicial"     Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgRes
   @ C(105),C(049) Say "Tamanho"             Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgRes
 
   @ C(014),C(005) MsGet oGet1 Var cIDINF Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRes
   @ C(014),C(032) MsGet oGet2 Var cBCFIC Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRes
   @ C(014),C(060) MsGet oGet3 Var cTPINF Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgRes

   @ C(011),C(086) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlgRes ACTION( PsqConsulta() )
   @ C(011),C(130) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgRes ACTION( oDlgRes:End() )

   @ C(114),C(005) MsGet oGet5 Var cPOSICAO Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgRes
   @ C(114),C(049) MsGet oGet6 Var cTAMANHO Size C(027),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlgRes
   @ C(111),C(083) Button "Cortar"          Size C(037),C(012) PIXEL OF oDlgRes ACTION( SepResultado() )

   @ C(036),C(005) GET oMemo1 Var cRESULTADO MEMO Size C(383),C(064) PIXEL OF oDlgRes When lChumba
   @ C(127),C(005) GET oMemo2 Var cCORTE     MEMO Size C(383),C(033) PIXEL OF oDlgRes When lChumba

   ACTIVATE MSDIALOG oDlgRes CENTERED 

Return(.T.)

// Função que pesquisa se a informação está presente no array aConsulta
Static Function PsqConsulta()

   Local nContar := 0

   If Empty(Alltrim(cIDINF))
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cBCFIC))
      Return(.T.)
   Endif

   If Empty(Alltrim(cTPINF))
      Return(.T.)
   Endif

   cRESULTADO := ""
   
   For nContar = 1 to Len(aConsulta)
   
       If aConsulta[nContar,01] == cIDINF .And. aConsulta[nContar,02] == cBCFIC .And. aConsulta[nContar,03] == cTPINF
          If aConsulta[nContar,05] == 0
             cRESULTADO := aConsulta[nContar,12]
             Exit
          Endif
       Endif
          
   Next nContar
   
   oMemo1:Refresh()
   
Return(.T.)

// Função que separa da string o campo solicitado pela variável cPosicao e cTamanho
Static Function SepResultado()

   If cPosicao == 0
      Return(.T.)
   Endif
   
   If cTamanho == 0
      Return(.T.)
   Endif
   
   cCorte := ""
   cCorte := Substr(cResultado, cPosicao, cTamanho)
   oMemo2:Refresh()
   
Return(.T.)         
