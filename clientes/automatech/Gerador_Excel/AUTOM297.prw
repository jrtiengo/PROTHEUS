#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM297.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/06/2015                                                          *
// Objetivo..: 1 - Programa que compara o SB1 do Restore com o da Produção         *
//             2 - Programa que carrega os dados do txt para a tabela SB1          *
//**********************************************************************************

User Function AUTOM297()

   Local nContar   := 0
   Local nMostra   := 0
   Local cCaminho  := ""
   Local cConteudo := ""
   Local cGravar   := ""
   Local aBrowse   := {}                        
   Local aResumo   := {}
   Local lResult
   Local _nErro    := 0
   Local aSb1	   := {}   
   
   U_AUTOM628("AUTOM297")

   // Cria o caminho de pesquisa
   cCaminho := "D:\PRODUTOS2.TXT"

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
       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cAgravar := ""
          For nLimpa = 1 to Len(cConteudo)
              cAgravar := cAgravar + Substr(cConteudo, nLimpa, 1)
          Next nLimpa
          aAdd(aBrowse, { StrTran(cAgravar, chr(9), "|") + "|" } )
          cConteudo := ""
       Endif
   Next nContar    
   
   // Atualiza os dados na tabela SB1
   For nContar = 1 to Len(aBrowse)

       xB1_CODI   := Alltrim(U_P_CORTA(aBrowse[nContar,1], "|",  1))
       xB1_PESC   := VAL(U_P_CORTA(aBrowse[nContar,1], "|",  2))
       xB1_COMP   := VAL(U_P_CORTA(aBrowse[nContar,1], "|",  3))
       xB1_ALTU   := VAL(U_P_CORTA(aBrowse[nContar,1], "|",  4))
       xB1_LARG   := VAL(U_P_CORTA(aBrowse[nContar,1], "|",  5))
       xB1_WEB    := U_P_CORTA(aBrowse[nContar,1], "|",  6)
       xB1_USUI   := U_P_CORTA(aBrowse[nContar,1], "|",  7)
       xB1_DATAI  := Ctod(Substr(U_P_CORTA(aBrowse[nContar,1], "|",  8),07,02) + "/" + ;
                          Substr(U_P_CORTA(aBrowse[nContar,1], "|",  8),05,02) + "/" + ;
                          Substr(U_P_CORTA(aBrowse[nContar,1], "|",  8),01,04))
       xB1_HORAI  := U_P_CORTA(aBrowse[nContar,1], "|",  9)
       xB1_USUL   := U_P_CORTA(aBrowse[nContar,1], "|", 10)
       xB1_DATAL  := Ctod(Substr(U_P_CORTA(aBrowse[nContar,1], "|", 11),07,02) + "/" + ;
                          Substr(U_P_CORTA(aBrowse[nContar,1], "|", 11),05,02) + "/" + ;
                          Substr(U_P_CORTA(aBrowse[nContar,1], "|", 11),01,04))
       xB1_HORAL  := U_P_CORTA(aBrowse[nContar,1], "|", 12)
       xB1_STLB   := U_P_CORTA(aBrowse[nContar,1], "|", 13)
       xB1_BLQESP := U_P_CORTA(aBrowse[nContar,1], "|", 14)
       xB1_ROLO   := U_P_CORTA(aBrowse[nContar,1], "|", 15)
       xB1_MPCLAS := U_P_CORTA(aBrowse[nContar,1], "|", 16)
       xB1_ZVIR   := U_P_CORTA(aBrowse[nContar,1], "|", 17)
           
       aAdd( aResumo, {xB1_CODI   ,;
                       xB1_PESC   ,;
                       xB1_COMP   ,;
                       xB1_ALTU   ,;
                       xB1_LARG   ,;
                       xB1_WEB    ,;
                       xB1_USUI   ,;
                       xB1_DATAI  ,;
                       xB1_HORAI  ,;
                       xB1_USUL   ,;
                       xB1_DATAL  ,;
                       xB1_HORAL  ,;
                       xB1_STLB   ,;
                       xB1_BLQESP ,;
                       xB1_ROLO   ,;
                       xB1_MPCLAS ,;
                       xB1_ZVIR   })

   Next nContar

   For nContar = 1 to Len(aResumo)

       xCodigo := Alltrim(StrTran(StrTran(aResumo[nContar,1], CHR(13), ""), CHR(10), ""))

       If Len(xCodigo) < 6
          xCodigo := Strzero(INT(VAL(xcodigo)),6)
       Endif

       yCodigo := Alltrim(xCodigo) + Space(30 - Len(Alltrim(xCodigo)))

       // Atualiza o registro na tabela SB1           

	   aSb1 := GetArea("SB1")
	   DbSelectArea("SB1")
       DbSetOrder(1)
	   If DbSeek(xFilial("SB1") + yCodigo)
          RecLock("SB1",.F.)
          B1_PESC   := aResumo[nContar,02]
          B1_COMP   := aResumo[nContar,03]
          B1_ALTU   := aResumo[nContar,04]
          B1_LARG   := aResumo[nContar,05]
          B1_WEB    := aResumo[nContar,06]
          B1_USUI   := aResumo[nContar,07]
          B1_DATAI  := aResumo[nContar,08]
          B1_HORAI  := aResumo[nContar,09]
          B1_USUL   := aResumo[nContar,10]
          B1_DATAL  := aResumo[nContar,11]
          B1_HORAL  := aResumo[nContar,12]
          B1_STLB   := aResumo[nContar,13]
          B1_BLQESP := aResumo[nContar,14]
          B1_ROLO   := aResumo[nContar,15]
          B1_MPCLAS := aResumo[nContar,16]
          B1_ZVIR   := aResumo[nContar,17]
          MsUnLock()        
       Endif                            
	   RestArea(aSb1)       
       
  Next nContar     

  MsgAlert("Ateualização realizada com Sucesso.")

Return(.T.)
           























































/*

   Local aRestore  := {}
   Local aProducao := {}
   Local nContar   := 0
   Local nprocura  := 0

   // Carrega array aRestore
   aAdd( aRestore, "B1_FILIAL ") 
   aAdd( aRestore, "B1_COD    ") 
   aAdd( aRestore, "B1_PARNUM ") 
   aAdd( aRestore, "B1_CODITE ") 
   aAdd( aRestore, "B1_DESC   ") 
   aAdd( aRestore, "B1_TIPO   ") 
   aAdd( aRestore, "B1_UM     ") 
   aAdd( aRestore, "B1_LOCPAD ") 
   aAdd( aRestore, "B1_GRUPO  ") 
   aAdd( aRestore, "B1_GRTRIB ") 
   aAdd( aRestore, "B1_POSIPI ") 
   aAdd( aRestore, "B1_EX_NCM ") 
   aAdd( aRestore, "B1_EX_NBM ") 
   aAdd( aRestore, "B1_ORIGEM ") 
   aAdd( aRestore, "B1_PICM   ") 
   aAdd( aRestore, "B1_IPI    ") 
   aAdd( aRestore, "B1_ALIQISS") 
   aAdd( aRestore, "B1_CODISS ") 
   aAdd( aRestore, "B1_TE     ") 
   aAdd( aRestore, "B1_TS     ") 
   aAdd( aRestore, "B1_BITMAP ") 
   aAdd( aRestore, "B1_SEGUM  ") 
   aAdd( aRestore, "B1_PICMRET") 
   aAdd( aRestore, "B1_PICMENT") 
   aAdd( aRestore, "B1_IMPZFRC") 
   aAdd( aRestore, "B1_CONV   ") 
   aAdd( aRestore, "B1_TIPCONV") 
   aAdd( aRestore, "B1_ALTER  ") 
   aAdd( aRestore, "B1_QE     ") 
   aAdd( aRestore, "B1_PRV1   ") 
   aAdd( aRestore, "B1_EMIN   ") 
   aAdd( aRestore, "B1_CUSTD  ") 
   aAdd( aRestore, "B1_UCOM   ") 
   aAdd( aRestore, "B1_UCALSTD") 
   aAdd( aRestore, "B1_UPRC   ") 
   aAdd( aRestore, "B1_ESTFOR ") 
   aAdd( aRestore, "B1_MCUSTD ") 
   aAdd( aRestore, "B1_PESO   ") 
   aAdd( aRestore, "B1_ESTSEG ") 
   aAdd( aRestore, "B1_FORPRZ ") 
   aAdd( aRestore, "B1_PE     ") 
   aAdd( aRestore, "B1_TIPE   ") 
   aAdd( aRestore, "B1_LE     ") 
   aAdd( aRestore, "B1_LM     ") 
   aAdd( aRestore, "B1_CONTA  ") 
   aAdd( aRestore, "B1_TOLER  ") 
   aAdd( aRestore, "B1_CC     ") 
   aAdd( aRestore, "B1_ITEMCC ") 
   aAdd( aRestore, "B1_LOJPROC") 
   aAdd( aRestore, "B1_FAMILIA") 
   aAdd( aRestore, "B1_PROC   ") 
   aAdd( aRestore, "B1_QB     ") 
   aAdd( aRestore, "B1_APROPRI") 
   aAdd( aRestore, "B1_TIPODEC") 
   aAdd( aRestore, "B1_CLASFIS") 
   aAdd( aRestore, "B1_UREV   ") 
   aAdd( aRestore, "B1_DATREF ") 
   aAdd( aRestore, "B1_FANTASM") 
   aAdd( aRestore, "B1_RASTRO ") 
   aAdd( aRestore, "B1_FORAEST") 
   aAdd( aRestore, "B1_COMIS  ") 
   aAdd( aRestore, "B1_DTREFP1") 
   aAdd( aRestore, "B1_MONO   ") 
   aAdd( aRestore, "B1_PERINV ") 
   aAdd( aRestore, "B1_MRP    ") 
   aAdd( aRestore, "B1_PRVALID") 
   aAdd( aRestore, "B1_NOTAMIN") 
   aAdd( aRestore, "B1_CONINI ") 
   aAdd( aRestore, "B1_CONTSOC") 
   aAdd( aRestore, "B1_NUMCOP ") 
   aAdd( aRestore, "B1_CODBAR ") 
   aAdd( aRestore, "B1_GRADE  ") 
   aAdd( aRestore, "B1_FORMLOT") 
   aAdd( aRestore, "B1_FPCOD  ") 
   aAdd( aRestore, "B1_IRRF   ") 
   aAdd( aRestore, "B1_LOCALIZ") 
   aAdd( aRestore, "B1_DESC_P ") 
   aAdd( aRestore, "B1_CONTRAT") 
   aAdd( aRestore, "B1_DESC_I ") 
   aAdd( aRestore, "B1_DESC_GI") 
   aAdd( aRestore, "B1_OPERPAD") 
   aAdd( aRestore, "B1_VLREFUS") 
   aAdd( aRestore, "B1_ANUENTE") 
   aAdd( aRestore, "B1_OPC    ") 
   aAdd( aRestore, "B1_CODOBS ") 
   aAdd( aRestore, "B1_IMPORT ") 
   aAdd( aRestore, "B1_FABRIC ") 
   aAdd( aRestore, "B1_SITPROD") 
   aAdd( aRestore, "B1_MODELO ") 
   aAdd( aRestore, "B1_SETOR  ") 
   aAdd( aRestore, "B1_BALANCA") 
   aAdd( aRestore, "B1_PRODPAI") 
   aAdd( aRestore, "B1_TECLA  ") 
   aAdd( aRestore, "B1_TIPOCQ ") 
   aAdd( aRestore, "B1_DESPIMP") 
   aAdd( aRestore, "B1_SOLICIT") 
   aAdd( aRestore, "B1_AGREGCU") 
   aAdd( aRestore, "B1_QUADPRO") 
   aAdd( aRestore, "B1_GRUPCOM") 
   aAdd( aRestore, "B1_NUMCQPR") 
   aAdd( aRestore, "B1_CONTCQP") 
   aAdd( aRestore, "B1_REVATU ") 
   aAdd( aRestore, "B1_CODEMB ") 
   aAdd( aRestore, "B1_INSS   ") 
   aAdd( aRestore, "B1_ESPECIF") 
   aAdd( aRestore, "B1_NALNCCA") 
   aAdd( aRestore, "B1_MAT_PRI") 
   aAdd( aRestore, "B1_REDINSS") 
   aAdd( aRestore, "B1_NALSH  ") 
   aAdd( aRestore, "B1_REDIRRF") 
   aAdd( aRestore, "B1_ALADI  ") 
   aAdd( aRestore, "B1_TAB_IPI") 
   aAdd( aRestore, "B1_GRUDES ") 
   aAdd( aRestore, "B1_REDPIS ") 
   aAdd( aRestore, "B1_DATASUB") 
   aAdd( aRestore, "B1_REDCOF ") 
   aAdd( aRestore, "B1_PCSLL  ") 
   aAdd( aRestore, "B1_PCOFINS") 
   aAdd( aRestore, "B1_PPIS   ") 
   aAdd( aRestore, "B1_MTBF   ") 
   aAdd( aRestore, "B1_MTTR   ") 
   aAdd( aRestore, "B1_FLAGSUG") 
   aAdd( aRestore, "B1_CLASSVE") 
   aAdd( aRestore, "B1_MIDIA  ") 
   aAdd( aRestore, "B1_QTMIDIA") 
   aAdd( aRestore, "B1_VLR_IPI") 
   aAdd( aRestore, "B1_QTDSER ") 
   aAdd( aRestore, "B1_ENVOBR ") 
   aAdd( aRestore, "B1_SERIE  ") 
   aAdd( aRestore, "B1_FAIXAS ") 
   aAdd( aRestore, "B1_NROPAG ") 
   aAdd( aRestore, "B1_ISBN   ") 
   aAdd( aRestore, "B1_TITORIG") 
   aAdd( aRestore, "B1_LINGUA ") 
   aAdd( aRestore, "B1_EDICAO ") 
   aAdd( aRestore, "B1_OBSISBN") 
   aAdd( aRestore, "B1_CLVL   ") 
   aAdd( aRestore, "B1_ATIVO  ") 
   aAdd( aRestore, "B1_EMAX   ") 
   aAdd( aRestore, "B1_PESBRU ") 
   aAdd( aRestore, "B1_TIPCAR ") 
   aAdd( aRestore, "B1_FRACPER") 
   aAdd( aRestore, "B1_INT_ICM") 
   aAdd( aRestore, "B1_VLR_ICM") 
   aAdd( aRestore, "B1_VLRSELO") 
   aAdd( aRestore, "B1_CORPRI ") 
   aAdd( aRestore, "B1_CORSEC ") 
   aAdd( aRestore, "B1_NICONE ") 
   aAdd( aRestore, "B1_ATRIB1 ") 
   aAdd( aRestore, "B1_ATRIB2 ") 
   aAdd( aRestore, "B1_ATRIB3 ") 
   aAdd( aRestore, "B1_REGSEQ ") 
   aAdd( aRestore, "B1_CODNOR ") 
   aAdd( aRestore, "B1_CPOTENC") 
   aAdd( aRestore, "B1_POTENCI") 
   aAdd( aRestore, "B1_QTDACUM") 
   aAdd( aRestore, "B1_REQUIS ") 
   aAdd( aRestore, "B1_SELO   ") 
   aAdd( aRestore, "B1_LOTVEN ") 
   aAdd( aRestore, "B1_OK     ") 
   aAdd( aRestore, "B1_USAFEFO") 
   aAdd( aRestore, "B1_QTDINIC") 
   aAdd( aRestore, "B1_IAT    ") 
   aAdd( aRestore, "B1_IPPT   ") 
   aAdd( aRestore, "B1_CLASSE ") 
   aAdd( aRestore, "B1_ESCRIPI") 
   aAdd( aRestore, "B1_SITTRIB") 
   aAdd( aRestore, "B1_TALLA  ") 
   aAdd( aRestore, "B1_VALEPRE") 
   aAdd( aRestore, "B1_PRODSBP") 
   aAdd( aRestore, "B1_CCCUSTO") 
   aAdd( aRestore, "B1_MSBLQL ") 
   aAdd( aRestore, "B1_PMICNUT") 
   aAdd( aRestore, "B1_FUSTF  ") 
   aAdd( aRestore, "B1_PIS    ") 
   aAdd( aRestore, "B1_GDODIF ") 
   aAdd( aRestore, "B1_QBP    ") 
   aAdd( aRestore, "B1_GCCUSTO") 
   aAdd( aRestore, "B1_LOTESBP") 
   aAdd( aRestore, "B1_PMACNUT") 
   aAdd( aRestore, "B1_UVLRC  ") 
   aAdd( aRestore, "B1_CRICMS ") 
   aAdd( aRestore, "B1_CODPROC") 
   aAdd( aRestore, "B1_VLCIF  ") 
   aAdd( aRestore, "B1_PARCEI ") 
   aAdd( aRestore, "B1_UMOEC  ") 
   aAdd( aRestore, "B1_VLR_PIS") 
   aAdd( aRestore, "B1_CODQAD ") 
   aAdd( aRestore, "B1_TIPOBN ") 
   aAdd( aRestore, "B1_IVAAJU ") 
   aAdd( aRestore, "B1_CNAE   ") 
   aAdd( aRestore, "B1_PRFDSUL") 
   aAdd( aRestore, "B1_BASE2  ") 
   aAdd( aRestore, "B1_PAUTFET") 
   aAdd( aRestore, "B1_RETOPER") 
   aAdd( aRestore, "B1_BASE   ") 
   aAdd( aRestore, "B1_CSLL   ") 
   aAdd( aRestore, "B1_CALCFET") 
   aAdd( aRestore, "B1_VLR_COF") 
   aAdd( aRestore, "B1_REGRISS") 
   aAdd( aRestore, "B1_COLOR  ") 
   aAdd( aRestore, "B1_FRETISS") 
   aAdd( aRestore, "B1_FETHAB ") 
   aAdd( aRestore, "B1_CRDEST ") 
   aAdd( aRestore, "B1_ESTRORI") 
   aAdd( aRestore, "B1_DESBSE2") 
   aAdd( aRestore, "B1_TIPVEC ") 
   aAdd( aRestore, "B1_CODANT ") 
   aAdd( aRestore, "B1_COFINS ") 
   aAdd( aRestore, "B1_SELOEN ") 
   aAdd( aRestore, "B1_FECP   ") 
   aAdd( aRestore, "B1_ALFECOP") 
   aAdd( aRestore, "B1_ALFECST") 
   aAdd( aRestore, "B1_FECOP  ") 
   aAdd( aRestore, "B1_ALFUMAC") 
   aAdd( aRestore, "B1_PRODREC") 
   aAdd( aRestore, "B1_TRIBMUN") 
   aAdd( aRestore, "B1_VIGENC ") 
   aAdd( aRestore, "B1_CRDPRES") 
   aAdd( aRestore, "B1_PRDORI ") 
   aAdd( aRestore, "B1_REFBAS ") 
   aAdd( aRestore, "B1_TPPROD ") 
   aAdd( aRestore, "B1_TPREG  ") 
   aAdd( aRestore, "B1_VEREAN ") 
   aAdd( aRestore, "B1_RICM65 ") 
   aAdd( aRestore, "B1_CFEM   ") 
   aAdd( aRestore, "B1_CFEMS  ") 
   aAdd( aRestore, "B1_CFEMA  ") 
   aAdd( aRestore, "B1_GARANT ") 
   aAdd( aRestore, "B1_DTCORTE") 
   aAdd( aRestore, "B1_AFETHAB") 
   aAdd( aRestore, "B1_AFACS  ") 
   aAdd( aRestore, "B1_AFABOV ") 
   aAdd( aRestore, "B1_TFETHAB") 
   aAdd( aRestore, "B1_CODLAN ") 
   aAdd( aRestore, "B1_TNATREC") 
   aAdd( aRestore, "B1_CNATREC") 
   aAdd( aRestore, "B1_PR43080") 
   aAdd( aRestore, "B1_DAUX   ") 
   aAdd( aRestore, "B1_CRICMST") 
   aAdd( aRestore, "B1_GRPNATR") 
   aAdd( aRestore, "B1_DTFIMNT") 
   aAdd( aRestore, "B1_DCI    ") 
   aAdd( aRestore, "B1_DCRE   ") 
   aAdd( aRestore, "B1_DCR    ") 
   aAdd( aRestore, "B1_DCRII  ") 
   aAdd( aRestore, "B1_COEFDCR") 
   aAdd( aRestore, "B1_DIFCNAE") 
   aAdd( aRestore, "B1_PRINCMG") 
   aAdd( aRestore, "B1_REGESIM") 
   aAdd( aRestore, "B1_ALFECRN") 
   aAdd( aRestore, "B1_TPDP   ") 
   aAdd( aRestore, "B1_FECPBA ") 
   aAdd( aRestore, "B1_AJUDIF ") 
   aAdd( aRestore, "B1_RPRODEP") 
   aAdd( aRestore, "B1_ESPECIE") 
   aAdd( aRestore, "B1_RSATIVO") 
   aAdd( aRestore, "B1_MEPLES ") 
   aAdd( aRestore, "B1_IMPNCM ") 
   aAdd( aRestore, "B1_CHASSI ") 
   aAdd( aRestore, "B1_PESC   ") 
   aAdd( aRestore, "B1_COMP   ") 
   aAdd( aRestore, "B1_ALTU   ") 
   aAdd( aRestore, "B1_LARG   ") 
   aAdd( aRestore, "B1_WEB    ") 
   aAdd( aRestore, "B1_USUI   ") 
   aAdd( aRestore, "B1_DATAI  ") 
   aAdd( aRestore, "B1_HORAI  ") 
   aAdd( aRestore, "B1_USUL   ") 
   aAdd( aRestore, "B1_DATAL  ") 
   aAdd( aRestore, "B1_HORAL  ") 
   aAdd( aRestore, "B1_STLB   ") 
   aAdd( aRestore, "B1_BLQESP ") 
   aAdd( aRestore, "B1_ROLO   ") 
   aAdd( aRestore, "B1_MPCLAS ") 
   aAdd( aRestore, "B1_ZVIR   ")

   // Carrega o array aProducao   
   aAdd( aProducao, "B1_FILIAL ") 
   aAdd( aProducao, "B1_COD    ") 
   aAdd( aProducao, "B1_PARNUM ") 
   aAdd( aProducao, "B1_CODITE ") 
   aAdd( aProducao, "B1_DESC   ") 
   aAdd( aProducao, "B1_TIPO   ") 
   aAdd( aProducao, "B1_UM     ") 
   aAdd( aProducao, "B1_LOCPAD ") 
   aAdd( aProducao, "B1_GRUPO  ") 
   aAdd( aProducao, "B1_GRTRIB ") 
   aAdd( aProducao, "B1_POSIPI ") 
   aAdd( aProducao, "B1_EX_NCM ") 
   aAdd( aProducao, "B1_EX_NBM ") 
   aAdd( aProducao, "B1_ORIGEM ") 
   aAdd( aProducao, "B1_PICM   ") 
   aAdd( aProducao, "B1_IPI    ") 
   aAdd( aProducao, "B1_ALIQISS") 
   aAdd( aProducao, "B1_CODISS ") 
   aAdd( aProducao, "B1_TE     ") 
   aAdd( aProducao, "B1_TS     ") 
   aAdd( aProducao, "B1_BITMAP ") 
   aAdd( aProducao, "B1_SEGUM  ") 
   aAdd( aProducao, "B1_PICMRET") 
   aAdd( aProducao, "B1_PICMENT") 
   aAdd( aProducao, "B1_IMPZFRC") 
   aAdd( aProducao, "B1_CONV   ") 
   aAdd( aProducao, "B1_TIPCONV") 
   aAdd( aProducao, "B1_ALTER  ") 
   aAdd( aProducao, "B1_QE     ") 
   aAdd( aProducao, "B1_PRV1   ") 
   aAdd( aProducao, "B1_EMIN   ") 
   aAdd( aProducao, "B1_CUSTD  ") 
   aAdd( aProducao, "B1_UCOM   ") 
   aAdd( aProducao, "B1_UCALSTD") 
   aAdd( aProducao, "B1_UPRC   ") 
   aAdd( aProducao, "B1_ESTFOR ") 
   aAdd( aProducao, "B1_MCUSTD ") 
   aAdd( aProducao, "B1_PESO   ") 
   aAdd( aProducao, "B1_ESTSEG ") 
   aAdd( aProducao, "B1_FORPRZ ") 
   aAdd( aProducao, "B1_PE     ") 
   aAdd( aProducao, "B1_TIPE   ") 
   aAdd( aProducao, "B1_LE     ") 
   aAdd( aProducao, "B1_LM     ") 
   aAdd( aProducao, "B1_CONTA  ") 
   aAdd( aProducao, "B1_TOLER  ") 
   aAdd( aProducao, "B1_CC     ") 
   aAdd( aProducao, "B1_ITEMCC ") 
   aAdd( aProducao, "B1_LOJPROC") 
   aAdd( aProducao, "B1_FAMILIA") 
   aAdd( aProducao, "B1_PROC   ") 
   aAdd( aProducao, "B1_QB     ") 
   aAdd( aProducao, "B1_APROPRI") 
   aAdd( aProducao, "B1_TIPODEC") 
   aAdd( aProducao, "B1_CLASFIS") 
   aAdd( aProducao, "B1_UREV   ") 
   aAdd( aProducao, "B1_DATREF ") 
   aAdd( aProducao, "B1_FANTASM") 
   aAdd( aProducao, "B1_RASTRO ") 
   aAdd( aProducao, "B1_FORAEST") 
   aAdd( aProducao, "B1_COMIS  ") 
   aAdd( aProducao, "B1_DTREFP1") 
   aAdd( aProducao, "B1_MONO   ") 
   aAdd( aProducao, "B1_PERINV ") 
   aAdd( aProducao, "B1_MRP    ") 
   aAdd( aProducao, "B1_PRVALID") 
   aAdd( aProducao, "B1_NOTAMIN") 
   aAdd( aProducao, "B1_CONINI ") 
   aAdd( aProducao, "B1_CONTSOC") 
   aAdd( aProducao, "B1_NUMCOP ") 
   aAdd( aProducao, "B1_CODBAR ") 
   aAdd( aProducao, "B1_GRADE  ") 
   aAdd( aProducao, "B1_FORMLOT") 
   aAdd( aProducao, "B1_FPCOD  ") 
   aAdd( aProducao, "B1_IRRF   ") 
   aAdd( aProducao, "B1_LOCALIZ") 
   aAdd( aProducao, "B1_DESC_P ") 
   aAdd( aProducao, "B1_CONTRAT") 
   aAdd( aProducao, "B1_DESC_I ") 
   aAdd( aProducao, "B1_DESC_GI") 
   aAdd( aProducao, "B1_OPERPAD") 
   aAdd( aProducao, "B1_VLREFUS") 
   aAdd( aProducao, "B1_ANUENTE") 
   aAdd( aProducao, "B1_OPC    ") 
   aAdd( aProducao, "B1_CODOBS ") 
   aAdd( aProducao, "B1_IMPORT ") 
   aAdd( aProducao, "B1_FABRIC ") 
   aAdd( aProducao, "B1_SITPROD") 
   aAdd( aProducao, "B1_MODELO ") 
   aAdd( aProducao, "B1_SETOR  ") 
   aAdd( aProducao, "B1_BALANCA") 
   aAdd( aProducao, "B1_PRODPAI") 
   aAdd( aProducao, "B1_TECLA  ") 
   aAdd( aProducao, "B1_TIPOCQ ") 
   aAdd( aProducao, "B1_DESPIMP") 
   aAdd( aProducao, "B1_SOLICIT") 
   aAdd( aProducao, "B1_AGREGCU") 
   aAdd( aProducao, "B1_QUADPRO") 
   aAdd( aProducao, "B1_GRUPCOM") 
   aAdd( aProducao, "B1_NUMCQPR") 
   aAdd( aProducao, "B1_CONTCQP") 
   aAdd( aProducao, "B1_REVATU ") 
   aAdd( aProducao, "B1_CODEMB ") 
   aAdd( aProducao, "B1_INSS   ") 
   aAdd( aProducao, "B1_ESPECIF") 
   aAdd( aProducao, "B1_NALNCCA") 
   aAdd( aProducao, "B1_MAT_PRI") 
   aAdd( aProducao, "B1_REDINSS") 
   aAdd( aProducao, "B1_NALSH  ") 
   aAdd( aProducao, "B1_REDIRRF") 
   aAdd( aProducao, "B1_ALADI  ") 
   aAdd( aProducao, "B1_TAB_IPI") 
   aAdd( aProducao, "B1_GRUDES ") 
   aAdd( aProducao, "B1_REDPIS ") 
   aAdd( aProducao, "B1_DATASUB") 
   aAdd( aProducao, "B1_REDCOF ") 
   aAdd( aProducao, "B1_PCSLL  ") 
   aAdd( aProducao, "B1_PCOFINS") 
   aAdd( aProducao, "B1_PPIS   ") 
   aAdd( aProducao, "B1_MTBF   ") 
   aAdd( aProducao, "B1_MTTR   ") 
   aAdd( aProducao, "B1_FLAGSUG") 
   aAdd( aProducao, "B1_CLASSVE") 
   aAdd( aProducao, "B1_MIDIA  ") 
   aAdd( aProducao, "B1_QTMIDIA") 
   aAdd( aProducao, "B1_VLR_IPI") 
   aAdd( aProducao, "B1_QTDSER ") 
   aAdd( aProducao, "B1_ENVOBR ") 
   aAdd( aProducao, "B1_SERIE  ") 
   aAdd( aProducao, "B1_FAIXAS ") 
   aAdd( aProducao, "B1_NROPAG ") 
   aAdd( aProducao, "B1_ISBN   ") 
   aAdd( aProducao, "B1_TITORIG") 
   aAdd( aProducao, "B1_LINGUA ") 
   aAdd( aProducao, "B1_EDICAO ") 
   aAdd( aProducao, "B1_OBSISBN") 
   aAdd( aProducao, "B1_CLVL   ") 
   aAdd( aProducao, "B1_ATIVO  ") 
   aAdd( aProducao, "B1_EMAX   ") 
   aAdd( aProducao, "B1_PESBRU ") 
   aAdd( aProducao, "B1_TIPCAR ") 
   aAdd( aProducao, "B1_FRACPER") 
   aAdd( aProducao, "B1_INT_ICM") 
   aAdd( aProducao, "B1_VLR_ICM") 
   aAdd( aProducao, "B1_VLRSELO") 
   aAdd( aProducao, "B1_CORPRI ") 
   aAdd( aProducao, "B1_CORSEC ") 
   aAdd( aProducao, "B1_NICONE ") 
   aAdd( aProducao, "B1_ATRIB1 ") 
   aAdd( aProducao, "B1_ATRIB2 ") 
   aAdd( aProducao, "B1_ATRIB3 ") 
   aAdd( aProducao, "B1_REGSEQ ") 
   aAdd( aProducao, "B1_CODNOR ") 
   aAdd( aProducao, "B1_CPOTENC") 
   aAdd( aProducao, "B1_POTENCI") 
   aAdd( aProducao, "B1_QTDACUM") 
   aAdd( aProducao, "B1_REQUIS ") 
   aAdd( aProducao, "B1_SELO   ") 
   aAdd( aProducao, "B1_LOTVEN ") 
   aAdd( aProducao, "B1_OK     ") 
   aAdd( aProducao, "B1_USAFEFO") 
   aAdd( aProducao, "B1_QTDINIC") 
   aAdd( aProducao, "B1_IAT    ") 
   aAdd( aProducao, "B1_IPPT   ") 
   aAdd( aProducao, "B1_CLASSE ") 
   aAdd( aProducao, "B1_ESCRIPI") 
   aAdd( aProducao, "B1_SITTRIB") 
   aAdd( aProducao, "B1_TALLA  ") 
   aAdd( aProducao, "B1_VALEPRE") 
   aAdd( aProducao, "B1_PRODSBP") 
   aAdd( aProducao, "B1_CCCUSTO") 
   aAdd( aProducao, "B1_MSBLQL ") 
   aAdd( aProducao, "B1_PMICNUT") 
   aAdd( aProducao, "B1_FUSTF  ") 
   aAdd( aProducao, "B1_PIS    ") 
   aAdd( aProducao, "B1_GDODIF ") 
   aAdd( aProducao, "B1_QBP    ") 
   aAdd( aProducao, "B1_GCCUSTO") 
   aAdd( aProducao, "B1_LOTESBP") 
   aAdd( aProducao, "B1_PMACNUT") 
   aAdd( aProducao, "B1_UVLRC  ") 
   aAdd( aProducao, "B1_CRICMS ") 
   aAdd( aProducao, "B1_CODPROC") 
   aAdd( aProducao, "B1_VLCIF  ") 
   aAdd( aProducao, "B1_PARCEI ") 
   aAdd( aProducao, "B1_UMOEC  ") 
   aAdd( aProducao, "B1_VLR_PIS") 
   aAdd( aProducao, "B1_CODQAD ") 
   aAdd( aProducao, "B1_TIPOBN ") 
   aAdd( aProducao, "B1_IVAAJU ") 
   aAdd( aProducao, "B1_CNAE   ") 
   aAdd( aProducao, "B1_PRFDSUL") 
   aAdd( aProducao, "B1_BASE2  ") 
   aAdd( aProducao, "B1_PAUTFET") 
   aAdd( aProducao, "B1_RETOPER") 
   aAdd( aProducao, "B1_BASE   ") 
   aAdd( aProducao, "B1_CSLL   ") 
   aAdd( aProducao, "B1_CALCFET") 
   aAdd( aProducao, "B1_VLR_COF") 
   aAdd( aProducao, "B1_REGRISS") 
   aAdd( aProducao, "B1_COLOR  ") 
   aAdd( aProducao, "B1_FRETISS") 
   aAdd( aProducao, "B1_FETHAB ") 
   aAdd( aProducao, "B1_CRDEST ") 
   aAdd( aProducao, "B1_ESTRORI") 
   aAdd( aProducao, "B1_DESBSE2") 
   aAdd( aProducao, "B1_TIPVEC ") 
   aAdd( aProducao, "B1_CODANT ") 
   aAdd( aProducao, "B1_COFINS ") 
   aAdd( aProducao, "B1_SELOEN ") 
   aAdd( aProducao, "B1_FECP   ") 
   aAdd( aProducao, "B1_ALFECOP") 
   aAdd( aProducao, "B1_ALFECST") 
   aAdd( aProducao, "B1_FECOP  ") 
   aAdd( aProducao, "B1_ALFUMAC") 
   aAdd( aProducao, "B1_PRODREC") 
   aAdd( aProducao, "B1_TRIBMUN") 
   aAdd( aProducao, "B1_VIGENC ") 
   aAdd( aProducao, "B1_CRDPRES") 
   aAdd( aProducao, "B1_PRDORI ") 
   aAdd( aProducao, "B1_REFBAS ") 
   aAdd( aProducao, "B1_TPPROD ") 
   aAdd( aProducao, "B1_TPREG  ") 
   aAdd( aProducao, "B1_VEREAN ") 
   aAdd( aProducao, "B1_RICM65 ") 
   aAdd( aProducao, "B1_CFEM   ") 
   aAdd( aProducao, "B1_CFEMS  ") 
   aAdd( aProducao, "B1_CFEMA  ") 
   aAdd( aProducao, "B1_GARANT ") 
   aAdd( aProducao, "B1_DTCORTE") 
   aAdd( aProducao, "B1_AFETHAB") 
   aAdd( aProducao, "B1_AFACS  ") 
   aAdd( aProducao, "B1_AFABOV ") 
   aAdd( aProducao, "B1_TFETHAB") 
   aAdd( aProducao, "B1_CODLAN ") 
   aAdd( aProducao, "B1_TNATREC") 
   aAdd( aProducao, "B1_CNATREC") 
   aAdd( aProducao, "B1_PR43080") 
   aAdd( aProducao, "B1_DAUX   ") 
   aAdd( aProducao, "B1_CRICMST") 
   aAdd( aProducao, "B1_GRPNATR") 
   aAdd( aProducao, "B1_DTFIMNT") 
   aAdd( aProducao, "B1_DCI    ") 
   aAdd( aProducao, "B1_DCRE   ") 
   aAdd( aProducao, "B1_DCR    ") 
   aAdd( aProducao, "B1_DCRII  ") 
   aAdd( aProducao, "B1_COEFDCR") 
   aAdd( aProducao, "B1_DIFCNAE") 
   aAdd( aProducao, "B1_PRINCMG") 
   aAdd( aProducao, "B1_REGESIM") 
   aAdd( aProducao, "B1_ALFECRN") 
   aAdd( aProducao, "B1_TPDP   ") 
   aAdd( aProducao, "B1_FECPBA ") 
   aAdd( aProducao, "B1_AJUDIF ") 
   aAdd( aProducao, "B1_RPRODEP") 
   aAdd( aProducao, "B1_ESPECIE") 
   aAdd( aProducao, "B1_RSATIVO") 
   aAdd( aProducao, "B1_MEPLES ") 
   aAdd( aProducao, "B1_IMPNCM ") 
   aAdd( aProducao, "B1_CHASSI ") 

   // Compara o aRestore com o aProducao
   For nContar = 1 to Len(aRestore)
   
       lExiste := .F.

       For nProcura = 1 to Len(aProducao)
       
           If Alltrim(aProducao[nProcura]) == Alltrim(aRestore[nContar])
              lExiste := .T.
              Exit
           Endif
           
       Next nProcura
       
       If lExiste == .F.
          MsgAlert(aRestore[nContar])
       Endif
       
   Next nContar              
   
Return(.T.)

*/