#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM615.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 15/08/2017                                                          ##
// Objetivo..: Processo automático de envio de E-Mail de documentos a Clientes     ##
// ##################################################################################

User Function AUTOM615()

   Local cSql        := ""
   Local lJaExiste   := .F.
   Local nContar     := 0
   Local lTemBoleto  := .F.
   Local lTemDanfe   := .F.
   Local lTemXML     := .F. 

   Private lxDeuErro := .F.

   U_AUTOM628("AUTOM615")
   
   // ###########################################
   // Processa o envio dos e-mail aos clientes ##
   // ###########################################

// PREPARE ENVIRONMENT EMPRESA '01' FILIAL '06'

   // ###########################################################
   // Pesquisa as notas fiscais a serem enviados os documentos ##
   // ###########################################################
   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf
 
   cSql := ""
   cSql := "SELECT SF2.F2_FILIAL ," + CHR(13)
   cSql += "       SF2.F2_DOC    ," + CHR(13)
   cSql += "       SF2.F2_SERIE  ," + CHR(13)
   cSql += "       SF2.F2_EMISSAO," + CHR(13)
   cSql += "       SF2.F2_CLIENTE," + CHR(13)
   cSql += "       SF2.F2_LOJA   ," + CHR(13)
   cSql += "       SA1.A1_NOME   ," + CHR(13)
   cSql += "       SA1.A1_EMAIL  ," + CHR(13)
   cSql += "       SF2.F2_ZEEN   ," + CHR(13)
   cSql += "       SF2.F2_ZDEN   ," + CHR(13)
   cSql += "       SF2.F2_ZHEN   ," + CHR(13)
   cSql += "       SF2.F2_ZUEN   ," + CHR(13)
   cSql += "       SF2.F2_ZXML   ," + CHR(13)
   cSql += "       SF2.F2_ZDNF   ," + CHR(13)
   cSql += "       SF2.F2_ZBLT    " + CHR(13)
   cSql += "  FROM SF2010 SF2, "                                             + CHR(13)
   cSql += "       " + RetSqlName("SA1") + " SA1 "                           + CHR(13)
   cSql += " WHERE SF2.F2_FILIAL   = '06'"                                   + CHR(13)
   cSql += "   AND SF2.F2_ZEEN    <> '1'"                                    + CHR(13)
//   cSql += "   AND SF2.F2_EMISSAO >= '20170815'"                             + CHR(13)
   cSql += "   AND SF2.F2_EMISSAO  = '20170824'"                             + CHR(13)
   cSql += "   AND SF2.D_E_L_E_T_  = ''"                                     + CHR(13)
   cSql += "   AND SA1.A1_COD      = SF2.F2_CLIENTE"                         + CHR(13)
   cSql += "   AND SA1.A1_LOJA     = SF2.F2_LOJA   "                         + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_  = ''"                                     + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   If T_NOTAS->( EOF() )
//    RESET ENVIRONMENT
      Return(.T.)
   Endif

   T_NOTAS->( DbGoTop() )
       
   WHILE !T_NOTAS->( EOF() )
       
     // #########################################################
     // Função que gera a Danfe para a nota fiscal selecionada ##
     // #########################################################
     U_AUTOM651(cEmpAnt, T_NOTAS->F2_FILIAL, T_NOTAS->F2_DOC, T_NOTAS->F2_SERIE, T_NOTAS->F2_CLIENTE, T_NOTAS->F2_LOJA, 1)

      // ##################################################################################################
      // Verifica se o boleto da nota fiscal/série existe no diretótio  de envio de documento a clientes ##
      // ##################################################################################################
      If File("\XML_DANFE\BOLETO_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + ".PDF")
         cBoleto    := "\XML_DANFE\BOLETO_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + ".PDF"
         lTemBoleto := .T.
      Else
         cBoleto    := ""
         lTemBoleto := .F.             
      Endif
          
      // #################################################################################################
      // Verifica se a danfe da nota fiscal/série existe no diretótio  de envio de documento a clientes ##
      // #################################################################################################
      If File("\XML_DANFE\DANFE_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + ".PDF")
         cDanfe    := "\XML_DANFE\DANFE_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + ".PDF"
         lTemDanfe := .T.
      Else
         cDanfe    := ""
         lTemDanfe := .F.             
      Endif
          
      // ###############################################################################################
      // Verifica se o xml da nota fiscal/série existe no diretótio  de envio de documento a clientes ##
      // ###############################################################################################
      If File("\XML_DANFE\XML_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + ".XML")
         cXML    := "\XML_DANFE\XML_" + Alltrim(T_NOTAS->F2_DOC) + "_" + Alltrim(T_NOTAS->F2_SERIE) + ".XML"
         lTemXml := .T.
      Else
         cXML    := ""
         lTemXml := .F.             
      Endif

      // ##############################################
      // Se não encontrou nenhum documento, despreza ##
      // ##############################################
      If Empty(Alltrim(cBoleto) + Alltrim(cDanfe) + Alltrim(cXml))
         T_NOTAS->( DbSkip() )
         Loop
      Endif

      // ######################################## 
      // Elabora os dados para enviar o E-mail ##
      // ########################################
      cTitulo   := "NF de Venda Nº " + Alltrim(T_NOTAS->F2_DOC) + " Série " + Alltrim(T_NOTAS->F2_SERIE) + " do dia " + ;
                   Substr(T_NOTAS->F2_EMISSAO,07,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,05,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,01,04)
//      cDestina  := "agatendimento3@terca.com.br"
      cDestina  := "harald@automatech.com.br"
      cCco      := "naoresponda@comunicados.automatech.com.br"
      cMensagem := "Segue em anexo documentação referente a Nota Fiscal " + Alltrim(T_NOTAS->F2_DOC) + ;
                   " Série " + Alltrim(T_NOTAS->F2_SERIE) + " emitida em " + ;
                   Substr(T_NOTAS->F2_EMISSAO,07,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,05,02) + "/" + Substr(T_NOTAS->F2_EMISSAO,01,04)

      Do Case
         Case !Empty(Alltrim(cBoleto)) .And. !Empty(Alltrim(cDanfe)) .And. !Empty(Alltrim(cXml))
              cArquivos := cBoleto + ";" + cDanfe + ";" + cXml
         Case Empty(Alltrim(cBoleto))  .And. !Empty(Alltrim(cDanfe)) .And. !Empty(Alltrim(cXml))
              cArquivos := cDanfe + ";" + cXml
         Case Empty(Alltrim(cBoleto))  .And. Empty(Alltrim(cDanfe))  .And. !Empty(Alltrim(cXml))
              cArquivos := cXml
         Case !Empty(Alltrim(cBoleto)) .And. Empty(Alltrim(cDanfe))  .And. Empty(Alltrim(cXml))
              cArquivos := cBoleto
         Case Empty(Alltrim(cBoleto))  .And. !Empty(Alltrim(cDanfe)) .And. Empty(Alltrim(cXml))
              cArquivos := cDanfe
         Case !Empty(Alltrim(cBoleto)) .And. !Empty(Alltrim(cDanfe)) .And. Empty(Alltrim(cXml))
              cArquivos := cBoleto + ";" + cDanfe
         Case !Empty(Alltrim(cBoleto)) .And. Empty(Alltrim(cDanfe))  .And. !Empty(Alltrim(cXml))
              cArquivos := cBoleto + ";" + cXml
      EndCase        
                  
      // ###########################################
      // Envia para o programa que envia o E-mail ##
      // ###########################################
      lxDeuErro := .F.
      U_AUTOM613(cTitulo,cDestina,cCco,cMensagem, cArquivos) 

      If lxDeuErro == .T.
      Else

         // ######################################
         // Atualiza o cabeçalho da nota fiscal ##
         // ######################################
         cSql := ""
         cSql := "UPDATE SF2010"
         cSql += "   SET"
	     cSql += "   F2_ZEEN = '1',"
	     cSql += "   F2_ZDEN = '" + Strzero(year(Date()),4) + Strzero(month(Date()),2) + Strzero(day(Date()),2) + "', "
	     cSql += "   F2_ZHEN = '" + Time()             + "',"
	     cSql += "   F2_ZUEN = '" + Alltrim(cUserName) + "',"
	     cSql += "   F2_ZXML = '" + IIF(lTemBoleto == .T., "1", "0")    + "',"
	     cSql += "   F2_ZDNF = '" + IIF(lTemDanfe  == .T., "1", "0")    + "',"
	     cSql += "   F2_ZBLT = '" + IIF(lTemXml    == .T., "1", "0")    + "' "
         cSql += " WHERE F2_FILIAL  = '06'" 
         cSql += "   AND F2_DOC     = '" + Alltrim(T_NOTAS->F2_DOC)     + "'"
         cSql += "   AND F2_SERIE   = '" + Alltrim(T_NOTAS->F2_SERIE)   + "'"
         cSql += "   AND F2_CLIENTE = '" + Alltrim(T_NOTAS->F2_CLIENTE) + "'"
         cSql += "   AND F2_LOJA    = '" + Alltrim(T_NOTAS->F2_LOJA)    + "'"

//         lResult := TCSQLEXEC(cSql)
      
      Endif

      T_NOTAS->( DbSkip() )
          
   ENDDO

   // #####################
   // Resreta o ambiente ##
   // #####################
// RESET ENVIRONMENT

Return(.T.)



/*


Local lSavTTS
Local lSavLOG
// olhe nesta linha abaixo que eu determino via codigo o horario 
Local lExecuta     := iif(Left(Time(),5)>="02:30".And.Left(Time(),5)<="03:00",.T.,.F.) 
Local lAuto    := Select('SX2')==0
Private aSM0     := {}

Private aFiles := { "SA1","SA2","SA3","SA6","SAE","SD1","SD2","SD3","SD8","SC2","SM2","MAH","MAL","CTW","CTX","CV8",;
"CT1","CT2","CT3","CT4","CT5","CT6","CT7","CTC","CTT","CTK","CTI","SI1","SI2","SI3","SI5","SI6","SI7","STL","SAN",;
"SB1","SB2","SB3","SB9","SBD","SC7","SE4","SF1","SF2","SF3","SF4","SF5","SF7","SF8","SFC","SX5","CTU","CTV","CTY" }

cAmbiente := GetEnvServer() // "ENVTESTE2" // 

lExecuta     := iif( "TEST" $ cAmbiente ,.T.,lExecuta)

MsOpenDbf(.T.,"DBFCDX","SIGAMAT.EMP", "NEWSM0",.T.,.F.)
DbSetIndex("SIGAMAT.IND")
SET(_SET_DELETED, .T.)

If lExecuta
     DbSelectArea("NEWSM0")
     NEWSM0->( dbSetOrder(1) )
     NEWSM0->( dbGotop() )
     DO While ! NEWSM0->( Eof() )
          If NEWSM0->M0_CODFIL <> "01"
               NEWSM0->( dbSkip() )
               Loop
          Endif
        Aadd(aSM0,{ NEWSM0->M0_CODIGO,NEWSM0->M0_CODFIL })
          NEWSM0->( dbSkip() )
     EndDo
     If Select("NEWSM0") > 0
          dbSelectArea("NEWSM0")
          NEWSM0->(dbCloseArea())
     Endif
Endif

If     lAuto .And. lExecuta
     
     For nI := 1 To Len(aSM0)
          RpcClearEnv()
          RpcSetType(3)
          PREPARE ENVIRONMENT EMPRESA aSM0[nI][1] FILIAL aSM0[nI][2] USER "JOBS           " PASSWORD "xxxxxx" MODULO "CTB"
          SetModulo( "SIGACTB", "CTB" )
          SetHideInd(.T.)
          Sleep( 1000 )     // aguarda 1 segundos para que as jobs IPC subam.
          __cLogSiga := "NNNNNNN"
          ConOut('Incio   - Empresa: '+aSM0[nI][1]+' em '+Dtoc(Date())+' - '+Time())
          // aqui voce coloca a sua funcao
          U_JOBCTB190(aFiles)
          ConOut('Termino - Empresa: '+aSM0[nI][1]+' em '+Dtoc(Date())+' - '+Time())
          __cLogSiga := GetMv("MV_LOGSIGA")
          RpcClearEnv()
     Next nI
     
EndIf

Return

User Function JOBCTB190(_aFiles)
Local dDataIni     := ctod("01/01/95") // FirstDay(Date()) // Date()-5 //
Local dDataFim     := LastDay(Date()-1) // Date()+1 //
Local cSavecAcesso := cAcesso
Local nSize            := Len(cAcesso)
Local aButtons           := {}
Local cQuery       := ""
Local lSavTTS           := __TTSInUse // Salvo o Estado atual do MV_TTS
__TTSInUse                := .T. // Ativo o MV_TTS

// altero o a variavel cAcesso para o modo de Administrador
cAcesso := Left(cSavecAcesso,107)+"N"+Substr(cSavecAcesso,109,nSize-108)

For nX:=1 To Len(_aFiles)
     If Select(_aFiles[nX]) == 0
          ChkFile(_aFiles[nX])
     Endif
Next nX

SX1->( DbSetOrder(1) )
SX1->( dbSeek( "CTB190" + "01" ) ) // Reprocessa a partir ? por data ou ultimo fechamento ?
RecLock("SX1", .f.)
SX1->X1_PRESEL := 1
SX1->(MsUnLock())
SX1->(dbSkip())

RecLock("SX1", .f.)
SX1->X1_CNT01 := "'"+Dtoc(dDataIni)+"'" // Data Inicial ?
SX1->(MsUnLock())
SX1->(dbSkip())

RecLock("SX1", .f.)
SX1->X1_CNT01 := "'"+Dtoc(dDataFim)+"'" // Data Final ?
SX1->(MsUnLock())
SX1->(dbSkip())

RecLock("SX1", .f.)
SX1->X1_CNT01 := "" // Filial de ?
SX1->(MsUnLock())
SX1->(dbSkip())

RecLock("SX1", .f.)
SX1->X1_CNT01 := "zz" // Filial Ate ?
SX1->(MsUnLock())
SX1->(dbSkip())

//SX1->( dbSeek( "CTB190" + "06" ) )
RecLock("SX1", .f.)
SX1->X1_CNT01 := '1' // Tipo de Saldo ?
SX1->(MsUnLock())
SX1->(dbSkip())

RecLock("SX1", .f.)
SX1->X1_PRESEL := 2 // Moedas ?
SX1->(MsUnLock())
SX1->(dbSkip())

RecLock("SX1", .f.)
SX1->X1_CNT01 := "01" // Qual Moeda ?
SX1->(MsUnLock())

pergunte("CTB190",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("INICIO")
//ConOut('Reprocessando Saldo : 1 da Empresa: '+aSM0[nI][1]+' em '+Dtoc(Date())+' - '+Time())

ProcLogAtu("MENSAGEM","Inicio do Reprocessando Saldo : 1")
CTBA190(.F.,dDataIni,dDataFim," ","ZZ","1",.F.,"01")
ProcLogAtu("MENSAGEM","Fim do Reprocessando Saldo : 1")

SX1->( dbSeek( "CTB190" + "06" ) )
RecLock("SX1", .f.)
SX1->X1_CNT01 := '5' // Tipo de Saldo ?
SX1->(MsUnLock())
pergunte("CTB190",.F.)

//ConOut('Reprocessando Saldo : 5 da Empresa: '+aSM0[nI][1]+' em '+Dtoc(Date())+' - '+Time())

ProcLogAtu("MENSAGEM","Inicio do Reprocessando Saldo : 5")
CTBA190(.F.,dDataIni,dDataFim," ","ZZ","5",.F.,"01")
ProcLogAtu("MENSAGEM","Fim do Reprocessando Saldo : 5")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("FIM")

cQuery := "UPDATE "+RetSqlName("CV8") + " SET CV8_PROC = 'CTBA190        ' "     
cQuery += " WHERE CV8_FILIAL = '" + xFilial("CV8") + "' AND D_E_L_E_T_ <> '*' AND" 
cQuery += " CV8_USER = 'JOBS           ' "
TCSQLExec(cQuery)                                                

cAcesso    := cSavecAcesso // Restauro para o padrao do usuario
__TTSInUse := lSavTTS           // Restauro o Estado do MV_TTS

Return

*/