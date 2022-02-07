#INCLUDE "NFEXAMP.ch"
#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99
//#IFNDEF WINDOWS
	#DEFINE PSAY SAY
//#ENDIF

User Function STCNF        // incluido pelo assistente de conversao do AP5 IDE em 19/11/99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("TAMANHO,LIMITE,TITULO,CDESC1,CDESC2,CDESC3")
SetPrvt("CNATUREZA,ARETURN,NOMEPROG,CPERG,NLASTKEY,LCONTINUA")
SetPrvt("NLIN,WNREL,NTAMNF,CSTRING,CPEDANT,NLININI")
SetPrvt("XNUM_NF,XSERIE,XEMISSAO,XTOT_FAT,XLOJA,XFRETE,XTOT_DES")
SetPrvt("XSEGURO,XBASE_ICMS,XBASE_IPI,XVALOR_ICMS,XICMS_RET,XVALOR_IPI")
SetPrvt("XVALOR_MERC,XNUM_DUPLIC,XCOND_PAG,XPBRUTO,XPLIQUI,XTIPO")
SetPrvt("XESPECIE,XVOLUME,CPEDATU,CITEMATU,XPED_VEND,XITEM_PED,XSERVISS")
SetPrvt("XNUM_NFDV,XPREF_DV,XICMS,XCOD_PRO,XQTD_PRO,XPRE_UNI")
SetPrvt("XPRE_TAB,XIPI,XVAL_IPI,XDESC,XVAL_DESC,XVAL_MERC")
SetPrvt("XTES,XCF,XICMSOL,XICM_PROD,XPESO_PRO,XPESO_UNIT")
SetPrvt("XDESCRICAO,XUNID_PRO,XCOD_TRIB,XMEN_TRIB,XCOD_FIS,XCLAS_FIS")
SetPrvt("XMEN_POS,XISS,XTIPO_PRO,XLUCRO,XCLFISCAL,XPESO_LIQ")
SetPrvt("I,NPELEM,_CLASFIS,NPTESTE,XPESO_LIQUID,XPED")
SetPrvt("XPESO_BRUTO,XP_LIQ_PED,XCLIENTE,XTIPO_CLI,XCOD_MENS,XMENSAGEM")
SetPrvt("XTPFRETE,XCONDPAG,XCOD_VEND,XDESC_NF,XDESC_PAG,XPED_CLI")
SetPrvt("XDESC_PRO,J,XCOD_CLI,XNOME_CLI,XEND_CLI,XBAIRRO")
SetPrvt("XCEP_CLI,XCOB_CLI,XREC_CLI,XMUN_CLI,XEST_CLI,XCGC_CLI")
SetPrvt("XINSC_CLI,XTRAN_CLI,XTEL_CLI,XFAX_CLI,XSUFRAMA,XCALCSUF")
SetPrvt("ZFRANCA,XVENDEDOR,XBSICMRET,XNOME_TRANSP,XEND_TRANSP,XMUN_TRANSP")
SetPrvt("XEST_TRANSP,XVIA_TRANSP,XCGC_TRANSP,XTEL_TRANSP,XPARC_DUP,XVENC_DUP")
SetPrvt("XVALOR_DUP,XDUPLICATAS,XNATUREZA,XFORNECE,XNFORI,XPEDIDO")
SetPrvt("XPESOPROD,XFAX,NOPC,CCOR,NTAMDET,XB_ICMS_SOL")
SetPrvt("XV_ICMS_SOL,NCONT,NCOL,NTAMOBS,NAJUSTE,BB") 
SetPrvt("xBASE_ISS,xVALOR_ISS,xTOT_SRV")
SetPrvt("xMSG01,xMSG02,xMSG03,xMSG04,xMSG05,xMSG06,xMSG07,xMSG08,xMSG09,xMSG10,xMSG11,xMSG12")
SetPrvt("xOBS01,xOBS02,xOBS03")

#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	#DEFINE PSAY SAY
#ENDIF

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦  Nfiscal ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Nota Fiscal de Entrada/Saida                               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico para Clientes Microsiga                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
//+--------------------------------------------------------------+
//¦ Define Variaveis Ambientais                                  ¦
//+--------------------------------------------------------------+
//+--------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros                         ¦
//¦ mv_par01             // Da Nota Fiscal                       ¦
//¦ mv_par02             // Ate a Nota Fiscal                    ¦ 
//¦ mv_par03             // Da Serie                             ¦ 
//¦ mv_par04             // Nota Fiscal de Entrada/Saida         ¦ 
//+--------------------------------------------------------------+
CbTxt:=""
CbCont:=""
nOrdem :=0
Alfa := 0
Z:=0
M:=0
tamanho		:= "G" 
limite		:= 220
titulo 		:= PADC(STR0001,74) //"Nota Fiscal - Nfiscal"
cDesc1 		:= PADC(STR0002,74) //"Este programa ira emitir a Nota Fiscal de Entrada/Saida"
cDesc2 		:= ""
cDesc3 		:= PADC(STR0003,74) //"da Nfiscal"
cNatureza	:= "" 
aReturn 	:= { STR0004, 1,STR0005, 1, 2, 1,"",1 } //"Especial"###"Administracao"
nomeprog	:= "nfiscal" 
cPerg		:= padr("NFSIGW", 10 , " ")  //padr("NFSIGW", LEN(SX1->X1_GRUPO), " ") 
nLastKey	:= 0 
lContinua 	:= .T.
nLin		:= 0
wnrel    	:= "siganf"

//+-----------------------------------------------------------+
//¦ Tamanho do Formulario de Nota Fiscal (em Linhas)          ¦
//+-----------------------------------------------------------+

nTamNf:=72     // Apenas Informativo 

//+-------------------------------------------------------------------------+
//¦ Verifica as perguntas selecionadas, busca o padrao da Nfiscal           ¦
//+-------------------------------------------------------------------------+

Pergunte(cPerg,.F.)               // Pergunta no SX1

cString:="SF2"

//+--------------------------------------------------------------+
//¦ Envia controle para a funcao SETPRINT                        ¦
//+--------------------------------------------------------------+

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

//+--------------------------------------------------------------+
//¦ Verifica Posicao do Formulario na Impressora                 ¦          
//+--------------------------------------------------------------+
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

VerImp()       

//+--------------------------------------------------------------+
//¦                                                              ¦
//¦ Inicio do Processamento da Nota Fiscal                       ¦
//¦                                                              ¦
//+--------------------------------------------------------------+
RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	RptStatus({|| Execute(RptDetail)})	
Return
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> 	Function RptDetail
Static Function RptDetail()

Local J
Local I

If mv_par04 == 2
   dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
   dbSetOrder(1)
   dbSeek(xFilial()+mv_par01+mv_par03,.t.)

   dbSelectArea("SD2")                // * Itens de Venda da Nota Fiscal
   dbSetOrder(3)
   dbSeek(xFilial()+mv_par01+mv_par03)
   cPedant := SD2->D2_PEDIDO
Else
   dbSelectArea("SF1")                // * Cabecalho da Nota Fiscal Entrada
   DbSetOrder(1)
   dbSeek(xFilial()+mv_par01+mv_par03,.t.)

   dbSelectArea("SD1")                // * Itens da Nota Fiscal de Entrada
   dbSetOrder(3)
Endif

//+-----------------------------------------------------------+
//¦ Inicializa  regua de impressao                            ¦
//+-----------------------------------------------------------+
SetRegua(Val(mv_par02)-Val(mv_par01))
If mv_par04 == 2
   dbSelectArea("SF2")
   While !eof() .and. SF2->F2_DOC    <= mv_par02 .and. lContinua

      If SF2->F2_SERIE #mv_par03    // Se a Serie do Arquivo for Diferente
         DbSkip()                    // do Parametro Informado !!!
         Loop
      Endif

	#IFNDEF WINDOWS
	      IF LastKey()==286
	         @ 00,01 PSAY STR0006 //"** CANCELADO PELO OPERADOR **"
	         lContinua := .F.
	         Exit
	      Endif
	#ELSE
	      IF lAbortPrint
	         @ 00,01 PSAY STR0006 //"** CANCELADO PELO OPERADOR **"
	         lContinua := .F.
	         Exit
	      Endif
	#ENDIF

      nLinIni:=nLin                         // Linha Inicial da Impressao


      //+--------------------------------------------------------------+
      //¦ Inicio de Levantamento dos Dados da Nota Fiscal              ¦
      //+--------------------------------------------------------------+

      // * Cabecalho da Nota Fiscal

      xNUM_NF     :=SF2->F2_DOC             // Numero
      xSERIE      :=SF2->F2_SERIE           // Serie
      xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
      xTOT_FAT    :=SF2->F2_VALFAT          // Valor Total da Fatura
      if xTOT_FAT == 0
         xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
      endif
      xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
      xFRETE      :=SF2->F2_FRETE           // Frete
      xSEGURO     :=SF2->F2_SEGURO          // Seguro
      xBASE_ICMS  :=SF2->F2_BASEICM         // Base   do ICMS
      xBASE_IPI   :=SF2->F2_BASEIPI         // Base   do IPI
      xVALOR_ICMS :=SF2->F2_VALICM          // Valor  do ICMS
      xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
      xVALOR_IPI  :=SF2->F2_VALIPI          // Valor  do IPI
      xVALOR_MERC := 0 //SF2->F2_VALMERC    // Valor  da Mercadoria
      xTOT_SRV    := 0                      // Valor  do Servico
      xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
      xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
      xPBRUTO     :=SF2->F2_PBRUTO          // Peso Bruto
      xPLIQUI     :=SF2->F2_PLIQUI          // Peso Liquido
      xTIPO       :=SF2->F2_TIPO            // Tipo do Cliente
      xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
      xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido
      xVALOR_ISS  :=SF2->F2_VALISS         // Volume 1 no Pedido
      xBASE_ISS   :=SF2->F2_BASEISS          // Volume 1 no Pedido
      xPER_ISS    :=Round(((SF2->F2_VALISS/SF2->F2_BASEISS)*100),2)
      XTOT_DES    := SF2->F2_DESCONT 
      
      dbSelectArea("SD2")                   // * Itens de Venda da N.F.
      dbSetOrder(3)
      dbSeek(xFilial()+xNUM_NF+xSERIE)

      cPedAtu := SD2->D2_PEDIDO
      cItemAtu := SD2->D2_ITEMPV

      xPED_VEND:={}                         // Numero do Pedido de Venda
      xITEM_PED:={}                         // Numero do Item do Pedido de Venda
      xNUM_NFDV:={}                         // nUMERO QUANDO HOUVER DEVOLUCAO
      xPREF_DV :={}                         // Serie  quando houver devolucao
      xICMS    :={}                         // Porcentagem do ICMS
      xCOD_PRO :={}                         // Codigo  do Produto
      xQTD_PRO :={}                         // Peso/Quantidade do Produto
      xPRE_UNI :={}                         // Preco Unitario de Venda
      xPRE_TAB :={}                         // Preco Unitario de Tabela
      xIPI     :={}                         // Porcentagem do IPI
      xVAL_IPI :={}                         // Valor do IPI
      xDESC    :={}                         // Desconto por Item
      xVAL_DESC:={}                         // Valor do Desconto
      xVAL_MERC:={}                         // Valor da Mercadoria
      xTES     :={}                         // TES
      xCF      :={}                         // Classificacao quanto natureza da Operacao
      xICMSOL  :={}                         // Base do ICMS Solidario
      xICM_PROD:={}                         // ICMS do Produto
      xSERVISS :={}                         // ICMS do Produto
      
	  SB1->(DbSetOrder(1))
      while !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
		 If SD2->D2_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
        	 DbSkip()                   // do Parametro Informado !!!
	         Loop
	 	 Endif
	     
	     //Posicona no produto
	     SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
	     
         AADD(xPED_VEND ,SD2->D2_PEDIDO)
         AADD(xITEM_PED ,SD2->D2_ITEMPV)
         AADD(xNUM_NFDV ,IIF(Empty(SD2->D2_NFORI),"",SD2->D2_NFORI))
         AADD(xPREF_DV  ,SD2->D2_SERIORI)
         AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
         AADD(xCOD_PRO  ,SD2->D2_COD)
         AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
         AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
         AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
         AADD(xIPI      ,IIF(Empty(SD2->D2_IPI),0,SD2->D2_IPI))
         AADD(xVAL_IPI  ,SD2->D2_VALIPI)
         AADD(xDESC     ,SD2->D2_DESC)
         AADD(xVAL_MERC ,IIF(SB1->B1_TIPO <> "MO" ,SD2->D2_TOTAL,0))
         AADD(xTES      ,SD2->D2_TES)
         AADD(xCF       ,SD2->D2_CF)
         AADD(xICM_PROD ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
         AADD(xSERVISS  ,SB1->B1_TIPO)
         
         //Valor de mercadorias
         xVALOR_MERC += IIF(SB1->B1_TIPO <> "MO",SD2->D2_TOTAL,0)
         
         xTOT_SRV    += IIF(SB1->B1_TIPO == "MO",SD2->D2_TOTAL+SD2->D2_DESCON,0) 
         dbskip()
      End

      dbSelectArea("SB1")                     // * Desc. Generica do Produto
      dbSetOrder(1)
      xPESO_PRO:={}                           // Peso Liquido
      xPESO_UNIT :={}                         // Peso Unitario do Produto
      xDESCRICAO :={}                         // Descricao do Produto
      xUNID_PRO:={}                           // Unidade do Produto
      xCOD_TRIB:={}                           // Codigo de Tributacao
      xMEN_TRIB:={}                           // Mensagens de Tributacao
      xCOD_FIS :={}                           // Cogigo Fiscal
      xCLAS_FIS:={}                           // Classificacao Fiscal
      xMEN_POS :={}                           // Mensagem da Posicao IPI
      xISS     :={}                           // Aliquota de ISS
      xTIPO_PRO:={}                           // Tipo do Produto
      xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
      xCLFISCAL   :={}
      xPESO_LIQ := 0
      I:=1

      For I:=1 to Len(xCOD_PRO)

          dbSeek(xFilial()+xCOD_PRO[I])
          AADD(xPESO_PRO ,SB1->B1_PESO * xQTD_PRO[I])
          xPESO_LIQ  := xPESO_LIQ + xPESO_PRO[I]
          AADD(xPESO_UNIT , SB1->B1_PESO)
          AADD(xUNID_PRO ,SB1->B1_UM)
          AADD(xDESCRICAO ,SB1->B1_DESC)
          AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
          If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
             AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
          Endif

          npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

          if npElem == 0
             AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
          endif

          npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

          DO CASE
             CASE npElem == 1
                _CLASFIS := "A"

             CASE npElem == 2
                _CLASFIS := "B"

             CASE npElem == 3
                _CLASFIS := "C"

             CASE npElem == 4
                _CLASFIS := "D"

             CASE npElem == 5
                _CLASFIS := "E"

             CASE npElem == 6
                _CLASFIS := "F"

           ENDCASE
           nPteste := Ascan(xCLFISCAL,_CLASFIS)
           If nPteste == 0
              AADD(xCLFISCAL,_CLASFIS)
           Endif

          AADD(xCOD_FIS ,_CLASFIS)
          If SB1->B1_ALIQISS > 0
             AADD(xISS ,SB1->B1_ALIQISS)
          Endif
          AADD(xTIPO_PRO ,SB1->B1_TIPO)
          AADD(xLUCRO    ,SB1->B1_PICMRET)


         //
         // Calculo do Peso Liquido da Nota Fiscal
         //

         xPESO_LIQUID:=0                                 // Peso Liquido da Nota Fiscal
         For j:=1 to Len(xPESO_PRO)
            xPESO_LIQUID:=xPESO_LIQUID+xPESO_PRO[j]
         Next j

      Next I

      dbSelectArea("SC5")                            // * Pedidos de Venda
      dbSetOrder(1)

      xPED        := {}
      xPESO_BRUTO := 0
      xP_LIQ_PED  := 0

      For I:=1 to Len(xPED_VEND)

         dbSeek(xFilial()+xPED_VEND[I])
         
         xMSG01 := IF(Empty(SC5->C5_YMSG01),'""',SC5->C5_YMSG01)
         xMSG02 := IF(Empty(SC5->C5_YMSG02),'""',SC5->C5_YMSG02)
         xMSG03 := IF(Empty(SC5->C5_YMSG03),'""',SC5->C5_YMSG03)
         xMSG04 := IF(Empty(SC5->C5_YMSG04),'""',SC5->C5_YMSG04)
         xMSG05 := IF(Empty(SC5->C5_YMSG05),'""',SC5->C5_YMSG05)
         xMSG06 := IF(Empty(SC5->C5_YMSG06),'""',SC5->C5_YMSG06)
         xMSG07 := IF(Empty(SC5->C5_YMSG07),'""',SC5->C5_YMSG07)
         xMSG08 := IF(Empty(SC5->C5_YMSG08),'""',SC5->C5_YMSG08)
         xMSG09 := IF(Empty(SC5->C5_YMSG09),'""',SC5->C5_YMSG09)
         xMSG10 := IF(Empty(SC5->C5_YMSG10),'""',SC5->C5_YMSG10)
         xMSG11 := IF(Empty(SC5->C5_YMSG11),'""',SC5->C5_YMSG11)
         xMSG12 := IF(Empty(SC5->C5_YMSG12),'""',SC5->C5_YMSG12)

         xOBS01 := Left(SC5->C5_YOBS01,65)
         xOBS02 := Left(SC5->C5_YOBS02,65)
         xOBS03 := Left(SC5->C5_YOBS03,65)
                                         
         If ASCAN(xPED,xPED_VEND[I])==0
            dbSeek(xFilial()+xPED_VEND[I])
            xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
            xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
            xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
            xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
            xTPFRETE    :=SC5->C5_TPFRETE            // Tipo de Entrega
            xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
            xPESO_BRUTO :=SC5->C5_PBRUTO             // Peso Bruto
            xP_LIQ_PED  :=xP_LIQ_PED + SC5->C5_PESOL // Peso Liquido
            xCOD_VEND:= {SC5->C5_VEND1,;             // Codigo do Vendedor 1
                         SC5->C5_VEND2,;             // Codigo do Vendedor 2
                         SC5->C5_VEND3,;             // Codigo do Vendedor 3
                         SC5->C5_VEND4,;             // Codigo do Vendedor 4
                         SC5->C5_VEND5}              // Codigo do Vendedor 5
            xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
                         SC5->C5_DESC2,;             // Desconto Global 2
                         SC5->C5_DESC3,;             // Desconto Global 3
                         SC5->C5_DESC4}              // Desconto Global 4
            AADD(xPED,xPED_VEND[I])
         Endif

         If xP_LIQ_PED >0
            xPESO_LIQ := xP_LIQ_PED
         Endif

      Next I

      //+---------------------------------------------+
      //¦ Pesquisa da Condicao de Pagto               ¦
      //+---------------------------------------------+

      dbSelectArea("SE4")                    // Condicao de Pagamento
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+xCONDPAG)
      xDESC_PAG := SE4->E4_DESCRI

      dbSelectArea("SC6")                    // * Itens de Pedido de Venda
      dbSetOrder(1)
      xPED_CLI :={}                          // Numero de Pedido
      xDESC_PRO:={}                          // Descricao aux do produto
      J:=Len(xPED_VEND)
      For I:=1 to J
         dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
         AADD(xPED_CLI ,SC6->C6_PEDCLI)
         AADD(xDESC_PRO,SC6->C6_DESCRI)
         AADD(xVAL_DESC,SC6->C6_VALDESC)
      Next j

      If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'

         dbSelectArea("SA1")                // * Cadastro de Clientes
         dbSetOrder(1)
         dbSeek(xFilial()+xCLIENTE+xLOJA)
         xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
         xNOME_CLI:=SA1->A1_NOME            // Nome
         xEND_CLI :=SA1->A1_END             // Endereco
         xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
         xCEP_CLI :=SA1->A1_CEP             // CEP
         xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
         xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
         xMUN_CLI :=SA1->A1_MUN             // Municipio
         xEST_CLI :=SA1->A1_EST             // Estado
         xCGC_CLI :=SA1->A1_CGC             // CGC
         xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
         xTEL_CLI :=SA1->A1_TEL             // Telefone
         xFAX_CLI :=SA1->A1_FAX             // Fax
         xSUFRAMA :=SA1->A1_SUFRAMA            // Codigo Suframa
         xCALCSUF :=SA1->A1_CALCSUF            // Calcula Suframa
         // Alteracao p/ Calculo de Suframa
         if !empty(xSUFRAMA) .and. xCALCSUF =="S"
            IF XTIPO == 'D' .OR. XTIPO == 'B'
               zFranca := .F.
            else
               zFranca := .T.
            endif
         Else
            zfranca:= .F.
         endif

      Else
         zFranca:=.F.
         dbSelectArea("SA2")                // * Cadastro de Fornecedores
         dbSetOrder(1)
         dbSeek(xFilial()+xCLIENTE+xLOJA)
         xCOD_CLI :=SA2->A2_COD             // Codigo do Fornecedor
         xNOME_CLI:=SA2->A2_NOME            // Nome Fornecedor
         xEND_CLI :=SA2->A2_END             // Endereco
         xBAIRRO  :=SA2->A2_BAIRRO          // Bairro
         xCEP_CLI :=SA2->A2_CEP             // CEP
         xCOB_CLI :=""                      // Endereco de Cobranca
         xREC_CLI :=""                      // Endereco de Entrega
         xMUN_CLI :=SA2->A2_MUN             // Municipio
         xEST_CLI :=SA2->A2_EST             // Estado
         xCGC_CLI :=SA2->A2_CGC             // CGC
         xINSC_CLI:=SA2->A2_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA2->A2_TRANSP          // Transportadora
         xTEL_CLI :=SA2->A2_TEL             // Telefone
         xFAX_CLI :=SA2->A2_FAX             // Fax
      Endif
      dbSelectArea("SA3")                   // * Cadastro de Vendedores
      dbSetOrder(1)
      xVENDEDOR:={}                         // Nome do Vendedor
      I:=1
      J:=Len(xCOD_VEND)
      For I:=1 to J
         dbSeek(xFilial()+xCOD_VEND[I])
         Aadd(xVENDEDOR,SA3->A3_NREDUZ)
      Next j

      If xICMS_RET >0                          // Apenas se ICMS Retido > 0
         dbSelectArea("SF3")                   // * Cadastro de Livros Fiscais
         dbSetOrder(4)
         dbSeek(xFilial()+SA1->A1_COD+SA1->A1_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
         If Found()
            xBSICMRET:=F3_VALOBSE
         Else
            xBSICMRET:=0
         Endif
      Else
         xBSICMRET:=0
      Endif
      dbSelectArea("SA4")                   // * Transportadoras
      dbSetOrder(1)
      dbSeek(xFilial()+SF2->F2_TRANSP)
      xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
      xEND_TRANSP  :=SA4->A4_END            // Endereco
      xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
      xEST_TRANSP  :=SA4->A4_EST            // Estado
      xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
      xCGC_TRANSP  :=SA4->A4_CGC            // CGC
      xTEL_TRANSP  :=SA4->A4_TEL            // Fone

      dbSelectArea("SE1")                   // * Contas a Receber
      dbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         If !("NF" $ SE1->E1_TIPO)
            dbSkip()
            Loop
         Endif
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         dbSkip()
      EndDo

      dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
      DbSetOrder(1)
      dbSeek(xFilial()+xTES[1])
      xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao


      Imprime()

      //+--------------------------------------------------------------+
      //¦ Termino da Impressao da Nota Fiscal                          ¦
      //+--------------------------------------------------------------+

      IncRegua()                    // Termometro de Impressao

      nLin:=0
      dbSelectArea("SF2")     
      dbSkip()                      // passa para a proxima Nota Fiscal

   EndDo
Else

   dbSelectArea("SF1")              // * Cabecalho da Nota Fiscal Entrada

   dbSeek(xFilial()+mv_par01+mv_par03,.t.)

   While !eof() .and. SF1->F1_DOC <= mv_par02 .and. SF1->F1_SERIE == mv_par03 .and. lContinua

      If SF1->F1_SERIE #mv_par03    // Se a Serie do Arquivo for Diferente
         DbSkip()                    // do Parametro Informado !!!
         Loop
      Endif
      //+-----------------------------------------------------------+
      //¦ Inicializa  regua de impressao                            ¦
      //+-----------------------------------------------------------+
	SetRegua(Val(mv_par02)-Val(mv_par01))

	#IFNDEF WINDOWS
	      IF LastKey()==286
	         @ 00,01 PSAY STR0006 //"** CANCELADO PELO OPERADOR **"
	         lContinua := .F.
	         Exit
	      Endif
	#ELSE
	      IF lAbortPrint
	         @ 00,01 PSAY STR0006 //"** CANCELADO PELO OPERADOR **"
	         lContinua := .F.
	         Exit
	      Endif
	#ENDIF

      nLinIni:=nLin                         // Linha Inicial da Impressao

      //+--------------------------------------------------------------+
      //¦ Inicio de Levantamento dos Dados da Nota Fiscal              ¦
      //+--------------------------------------------------------------+

      xNUM_NF     :=SF1->F1_DOC             // Numero
      xSERIE      :=SF1->F1_SERIE           // Serie
      xFORNECE    :=SF1->F1_FORNECE         // Cliente/Fornecedor
      xEMISSAO    :=SF1->F1_EMISSAO         // Data de Emissao
      xTOT_FAT    :=SF1->F1_VALBRUT         // Valor Bruto da Compra
      xLOJA       :=SF1->F1_LOJA            // Loja do Cliente
      xFRETE      :=SF1->F1_FRETE           // Frete
      xSEGURO     :=SF1->F1_DESPESA         // Despesa
      xBASE_ICMS  :=SF1->F1_BASEICM         // Base   do ICMS
      xBASE_IPI   :=SF1->F1_BASEIPI         // Base   do IPI
      xBSICMRET   :=SF1->F1_BRICMS          // Base do ICMS Retido
      xVALOR_ICMS :=SF1->F1_VALICM          // Valor  do ICMS
      xICMS_RET   :=SF1->F1_ICMSRET         // Valor  do ICMS Retido
      xVALOR_IPI  :=SF1->F1_VALIPI          // Valor  do IPI
      xVALOR_MERC :=SF1->F1_VALMERC         // Valor  da Mercadoria
      xNUM_DUPLIC :=SF1->F1_DUPL            // Numero da Duplicata
      xCOND_PAG   :=SF1->F1_COND            // Condicao de Pagamento
      xTIPO       :=SF1->F1_TIPO            // Tipo do Cliente
      xNFORI      :="" //SF1->F1_NFORI           // NF Original
      xPREF_DV    :="" //SF1->F1_SERIORI         // Serie Original

      dbSelectArea("SD1")                   // * Itens da N.F. de Compra
      dbSetOrder(1)
      dbSeek(xFilial()+xNUM_NF+xSERIE+xFORNECE+xLOJA)

      cPedAtu := SD1->D1_PEDIDO
      cItemAtu:= SD1->D1_ITEMPC

      xPEDIDO  :={}                         // Numero do Pedido de Compra
      xITEM_PED:={}                         // Numero do Item do Pedido de Compra
      xNUM_NFDV:={}                         // Numero quando houver devolucao
      xPREF_DV :={}                         // Serie  quando houver devolucao
      xICMS    :={}                         // Porcentagem do ICMS
      xCOD_PRO :={}                         // Codigo  do Produto
      xQTD_PRO :={}                         // Peso/Quantidade do Produto
      xPRE_UNI :={}                         // Preco Unitario de Compra
      xIPI     :={}                         // Porcentagem do IPI
      xPESOPROD:={}                         // Peso do Produto
      xVAL_IPI :={}                         // Valor do IPI
      xDESC    :={}                         // Desconto por Item
      xVAL_DESC:={}                         // Valor do Desconto
      xVAL_MERC:={}                         // Valor da Mercadoria
      xTES     :={}                         // TES
      xCF      :={}                         // Classificacao quanto natureza da Operacao
      xICMSOL  :={}                         // Base do ICMS Solidario
      xICM_PROD:={}                         // ICMS do Produto

      while !eof() .and. SD1->D1_DOC==xNUM_NF
         If SD1->D1_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
              DbSkip()                      // do Parametro Informado !!!
              Loop
         Endif

         AADD(xPEDIDO ,SD1->D1_PEDIDO)           // Ordem de Compra
         AADD(xITEM_PED ,SD1->D1_ITEMPC)         // Item da O.C.
         AADD(xNUM_NFDV ,IIF(Empty(SD1->D1_NFORI),"",SD1->D1_NFORI))
         AADD(xPREF_DV  ,SD1->D1_SERIORI)        // Serie Original
         AADD(xICMS     ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
         AADD(xCOD_PRO  ,SD1->D1_COD)            // Produto
         AADD(xQTD_PRO  ,SD1->D1_QUANT)          // Guarda as quant. da NF
         AADD(xPRE_UNI  ,SD1->D1_VUNIT)          // Valor Unitario
         AADD(xIPI      ,SD1->D1_IPI)            // % IPI
         AADD(xVAL_IPI  ,SD1->D1_VALIPI)         // Valor do IPI
         AADD(xPESOPROD ,SD1->D1_PESO)           // Peso do Produto
         AADD(xDESC     ,SD1->D1_DESC)           // % Desconto
         AADD(xVAL_MERC ,SD1->D1_TOTAL)          // Valor Total
         AADD(xTES      ,SD1->D1_TES)            // Tipo de Entrada/Saida
         AADD(xCF       ,SD1->D1_CF)             // Codigo Fiscal
         AADD(xICM_PROD ,IIf(Empty(SD1->D1_PICM),0,SD1->D1_PICM))
         dbskip()
      End

      dbSelectArea("SB1")                     // * Desc. Generica do Produto
      dbSetOrder(1)
      xUNID_PRO:={}                           // Unidade do Produto
      xDESC_PRO:={}                           // Descricao do Produto
      xMEN_POS :={}                           // Mensagem da Posicao IPI
      xDESCRICAO :={}                         // Descricao do Produto
      xCOD_TRIB:={}                           // Codigo de Tributacao
      xMEN_TRIB:={}                           // Mensagens de Tributacao
      xCOD_FIS :={}                           // Cogigo Fiscal
      xCLAS_FIS:={}                           // Classificacao Fiscal
      xISS     :={}                           // Aliquota de ISS
      xTIPO_PRO:={}                           // Tipo do Produto
      xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
      xCLFISCAL   :={}
      xSUFRAMA :=""
      xCALCSUF :=""

      I:=1
      For I:=1 to Len(xCOD_PRO)

         dbSeek(xFilial()+xCOD_PRO[I])
         dbSelectArea("SB1")

         AADD(xDESC_PRO ,SB1->B1_DESC)
         AADD(xUNID_PRO ,SB1->B1_UM)
         AADD(xCOD_TRIB ,SB1->B1_ORIGEM)
         If Ascan(xMEN_TRIB, SB1->B1_ORIGEM)==0
            AADD(xMEN_TRIB ,SB1->B1_ORIGEM)
         Endif
         AADD(xDESCRICAO ,SB1->B1_DESC)
         AADD(xMEN_POS  ,SB1->B1_POSIPI)
         If SB1->B1_ALIQISS > 0
            AADD(xISS,SB1->B1_ALIQISS)
         Endif
         AADD(xTIPO_PRO ,SB1->B1_TIPO)
         AADD(xLUCRO    ,SB1->B1_PICMRET)

         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

         if npElem == 0
            AADD(xCLAS_FIS  ,SB1->B1_POSIPI)
         endif
         npElem := ascan(xCLAS_FIS,SB1->B1_POSIPI)

         DO CASE
            CASE npElem == 1
               _CLASFIS := "A"

            CASE npElem == 2
               _CLASFIS := "B"

            CASE npElem == 3
               _CLASFIS := "C"

            CASE npElem == 4
               _CLASFIS := "D"

            CASE npElem == 5
               _CLASFIS := "E"

            CASE npElem == 6
               _CLASFIS := "F"

         EndCase
         nPteste := Ascan(xCLFISCAL,_CLASFIS)
         If nPteste == 0
            AADD(xCLFISCAL,_CLASFIS)
         Endif
         AADD(xCOD_FIS ,_CLASFIS)

      Next I

      //+---------------------------------------------+
      //¦ Pesquisa da Condicao de Pagto               ¦
      //+---------------------------------------------+

      dbSelectArea("SE4")                    // Condicao de Pagamento
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+xCOND_PAG)
      xDESC_PAG := SE4->E4_DESCRI

      If xTIPO == "D" .OR. xTIPO == "B"

         dbSelectArea("SA1")                // * Cadastro de Clientes
         dbSetOrder(1)
         dbSeek(xFilial()+xFORNECE)
         xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
         xNOME_CLI:=SA1->A1_NOME            // Nome
         xEND_CLI :=SA1->A1_END             // Endereco
         xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
         xCEP_CLI :=SA1->A1_CEP             // CEP
         xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
         xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
         xMUN_CLI :=SA1->A1_MUN             // Municipio
         xEST_CLI :=SA1->A1_EST             // Estado
         xCGC_CLI :=SA1->A1_CGC             // CGC
         xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
         xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
         xTEL_CLI :=SA1->A1_TEL             // Telefone
         xFAX_CLI :=SA1->A1_FAX             // Fax

      Else

         dbSelectArea("SA2")                // * Cadastro de Fornecedores
         dbSetOrder(1)
         dbSeek(xFilial()+xFORNECE+xLOJA)
         xCOD_CLI :=SA2->A2_COD                // Codigo do Cliente
         xNOME_CLI:=SA2->A2_NOME               // Nome
         xEND_CLI :=SA2->A2_END                // Endereco
         xBAIRRO  :=SA2->A2_BAIRRO             // Bairro
         xCEP_CLI :=SA2->A2_CEP                // CEP
         xCOB_CLI :=""                         // Endereco de Cobranca
         xREC_CLI :=""                         // Endereco de Entrega
         xMUN_CLI :=SA2->A2_MUN                // Municipio
         xEST_CLI :=SA2->A2_EST                // Estado
         xCGC_CLI :=SA2->A2_CGC                // CGC
         xINSC_CLI:=SA2->A2_INSCR              // Inscricao estadual
         xTRAN_CLI:=SA2->A2_TRANSP             // Transportadora
         xTEL_CLI :=SA2->A2_TEL                // Telefone
         xFAX     :=SA2->A2_FAX                // Fax

      EndIf

      dbSelectArea("SE1")                   // * Contas a Receber
      dbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         dbSkip()
      EndDo

      dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
      dbSetOrder(1)
      dbSeek(xFilial()+SD1->D1_TES)
      xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao

      xNOME_TRANSP :=" "           // Nome Transportadora
      xEND_TRANSP  :=" "           // Endereco
      xMUN_TRANSP  :=" "           // Municipio
      xEST_TRANSP  :=" "           // Estado
      xVIA_TRANSP  :=" "           // Via de Transporte
      xCGC_TRANSP  :=" "           // CGC
      xTEL_TRANSP  :=" "           // Fone
      xTPFRETE     :=" "           // Tipo de Frete
      xVOLUME      := 0            // Volume
      xESPECIE     :=" "           // Especie
      xPESO_LIQ    := 0            // Peso Liquido
      xPESO_BRUTO  := 0            // Peso Bruto
      xCOD_MENS    :=" "           // Codigo da Mensagem
      xMENSAGEM    :=" "           // Mensagem da Nota
      xPESO_LIQUID :=" "


      Imprime()

      //+--------------------------------------------------------------+
      //¦ Termino da Impressao da Nota Fiscal                          ¦
      //+--------------------------------------------------------------+

      IncRegua()                    // Termometro de Impressao

      nLin:=0
      dbSelectArea("SF1")           
      dbSkip()                     // e passa para a proxima Nota Fiscal

   EndDo
Endif
//+--------------------------------------------------------------+
//¦                                                              ¦
//¦                      FIM DA IMPRESSAO                        ¦
//¦                                                              ¦
//+--------------------------------------------------------------+

//+--------------------------------------------------------------+
//¦ Fechamento do Programa da Nota Fiscal                        ¦
//+--------------------------------------------------------------+

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SF1")
Retindex("SF1")
dbSelectArea("SD2")
Retindex("SD2")
dbSelectArea("SD1")
Retindex("SD1")
Set Device To Screen

If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

MS_FLUSH()
//+--------------------------------------------------------------+
//¦ Fim do Programa                                              ¦
//+--------------------------------------------------------------+

//+--------------------------------------------------------------+
//¦                                                              ¦
//¦                   FUNCOES ESPECIFICAS                        ¦
//¦                                                              ¦
//+--------------------------------------------------------------+

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ VERIMP   ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica posicionamento de papel na Impressora             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function VerImp
Static Function VerImp()

nLin:= 0                // Contador de Linhas
nLinIni:=0
If aReturn[5]==2

   nOpc       := 1
	#IFNDEF WINDOWS
	   cCor       := "B/BG"
	#ENDIF
   While .T.

      SetPrc(0,0)
      dbCommitAll()

      @ nLin ,000 PSAY " "
      @ nLin ,004 PSAY "*"
      @ nLin ,022 PSAY "."
		#IFNDEF WINDOWS
	      Set Device to Screen
	      DrawAdvWindow(STR0007,10,25,14,56) //" Formulario "
	      SetColor(cCor)
	      @ 12,27 Say STR0008 //"Formulario esta posicionado?"
	      nOpc:=Menuh({STR0009,STR0010,STR0011},14,26,"b/w,w+/n,r/w","SNC","",1) //"Sim"###"Nao"###"Cancela Impressao"
			Set Device to Print
		#ELSE
			IF MsgYesNo(STR0012) //"Fomulario esta posicionado ? "
				nOpc := 1
			ElseIF MsgYesNo(STR0013) //"Tenta Novamente ? "
				nOpc := 2
			Else
				nOpc := 3
			Endif
		#ENDIF

      Do Case
         Case nOpc==1
            lContinua:=.T.
            Exit
         Case nOpc==2
            Loop
         Case nOpc==3
            lContinua:=.F.
            Return
      EndCase
   End
Endif

Return

//+---------------------+
//¦ Fim da Funcao       ¦
//+---------------------+

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ IMPDET   ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao de Linhas de Detalhe da Nota Fiscal              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function IMPDET
Static Function IMPDET()

Local I:=1
Local J:=1

nTamDet :=GetMv("MV_NUMITEN") //10            // Tamanho da Area de Detalhe

xB_ICMS_SOL:=0          // Base  do ICMS Solidario
xV_ICMS_SOL:=0          // Valor do ICMS Solidario

For I:=1 to nTamDet

      If I<= Len(xCOD_PRO) .AND. XSERVISS[I] <> "MO"
          @ nLin, 001  PSAY xCOD_PRO[I]
          @ nLin, 019  PSAY xDESCRICAO[I]
          @ nLin, 085  PSAY xCOD_FIS[I]
          @ nLin, 086  PSAY xCOD_TRIB[I]
          @ nLin, 090  PSAY xUNID_PRO[I]
          @ nLin, 094  PSAY xQTD_PRO[I]               Picture"@E 9999.99"
          @ nLin, 101  PSAY xPRE_UNI[I]               Picture"@E 99,999,999.99"
          @ nLin, 116  PSAY xVAL_MERC[I]              Picture"@E 99,999,999.99"
          //@ nLin,   PSAY xIPI[I]                   Picture"99"
          @ nLin, 132  PSAY xICM_PROD[I]              Picture"99"
          //@ nLin,   PSAY xVAL_IPI[I]               Picture"@E 9,999,999.99"
          J:=J+1
      Endif
   nLin :=nLin+1

Next

Return

//+---------------------+
//¦ Fim da Funcao       ¦
//+---------------------+


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ CLASFIS  ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 16/11/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao de Array com as Classificacoes Fiscais           ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function CLASFIS
Static Function CLASFIS()

Local nLen := Len(xCLFISCAL)
Local nCont

@ nLin,006 PSAY STR0014 //"Classificacao Fiscal"
nLin := nLin + 1            

If nLen > 12
	nLen := 12
Endif

For nCont := 1 to nLen
   nCol := If(Mod(nCont,2) != 0, 06, 33)
   @ nLin, nCol   PSAY xCLFISCAL[nCont] + "-"
   @ nLin, nCol+ 05 PSAY Transform(xCLAS_FIS[nCont],"@r 99.99.99.99.99")
   nLin := nLin + If(Mod(nCont,2) != 0, 0, 1)
Next

Return


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ IMPMENP  ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao Mensagem Padrao da Nota Fiscal                   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function IMPMENP
Static Function IMPMENP()

nCol:= 05

If !Empty(xCOD_MENS)

   @ nLin, NCol PSAY FORMULA(xCOD_MENS)

Endif


Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ OBSSERV  ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao Mensagem de Servicos Prestados                   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function IMPMENP
Static Function OBSSERV()

//cObs := "1XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF2XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF3XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF4XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF5XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF6XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF7XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF8XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF9XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF0XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF1XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF2XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXF" //SC5->C5_YMSGSRV                                   

//Craia mensagem a partir das formulas
cObs01 := (&xMSG01)
cObs01 := Left(cObs01,95)

cObs02 := (&xMSG02)
cObs02 := Left(cObs02,95)

cObs03 := (&xMSG03)
cObs03 := Left(cObs03,95)

cObs04 := (&xMSG04)
cObs04 := Left(cObs04,95)
cObs04 := Iif(Empty(cObs04),'.',cObs04)

cObs05 := (&xMSG05)
cObs05 := Left(cObs05,95)

cObs06 := (&xMSG06)
cObs06 := Left(cObs06,95)

cObs07 := (&xMSG07)
cObs07 := Left(cObs07,95)

cObs08 := (&xMSG08)
cObs08 := Left(cObs08,95)

cObs09 := (&xMSG09)
cObs09 := Left(cObs09,95)

cObs10 := (&xMSG10)
cObs10 := Left(cObs10,95)

cObs11 := (&xMSG11)
cObs11 := Left(cObs11,95)

cObs12 := (&xMSG12)
cObs12 := Left(cObs12,95)


@ 37, 19 PSAY cObs01
@ 37, 116 PSAY xTOT_SRV   Picture"@E@Z 999,999,999.99"   // Valor do Servico 

@ 38, 19 PSAY cObs02
@ 39, 19 PSAY cObs03
@ 40, 19 PSAY cObs04
@ 40, 116 PSAY xTOT_DES   Picture"@E@Z 999,999,999.99"   // Valor do Servico 

@ 41, 19 PSAY cObs05
@ 42, 19 PSAY cObs06
@ 43, 19 PSAY cObs07
@ 44, 19 PSAY cObs08
@ 45, 19 PSAY cObs09
@ 46, 19 PSAY cObs10
@ 47, 19 PSAY cObs11
@ 48, 19 PSAY cObs12

/*/
@ 36, 19 PSAY Substr(cObs,1,95)
@ 37, 19 PSAY Substr(cObs,96,95)
@ 38, 19 PSAY Substr(cObs,191,95)
@ 39, 19 PSAY Substr(cObs,286,95)
@ 40, 19 PSAY Substr(cObs,381,95)
@ 41, 19 PSAY Substr(cObs,476,95)
@ 42, 19 PSAY Substr(cObs,571,95)
@ 43, 19 PSAY Substr(cObs,666,95)
@ 44, 19 PSAY Substr(cObs,761,95)
@ 45, 19 PSAY Substr(cObs,856,95)
@ 46, 19 PSAY Substr(cObs,951,95)
@ 47, 19 PSAY Substr(cObs,1046,95)
/*/
/*/
cXOBS := (SC5->C5_YSRVMSG)
cObs := (&cXOBS) 
cObs := Left(Alltrim(cObs),1140)
nObs := MlCount(cObs,95)
                        
For nS:=1 To nObs
	@ nLin, 19 PSAY MemoLine(cObs,95,nS)
	nLin++	
Next nS
/*/

Return

//+---------------------+
//¦ Fim da Funcao       ¦
//+---------------------+

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ MENSOBS  ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao Mensagem no Campo Observacao                     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function MENSOBS
Static Function MENSOBS()

nTamObs:=150
nCol:=05
@ nLin, nCol PSAY UPPER(SUBSTR(xMENSAGEM,1,nTamObs))
nlin:=nlin+1
@ nLin, nCol PSAY UPPER(SUBSTR(xMENSAGEM,151,nTamObs))
nlin:=nlin+1
@ nLin, nCol PSAY UPPER(SUBSTR(xMENSAGEM,301,nTamObs))
Return

//+---------------------+
//¦ Fim da Funcao       ¦
//+---------------------+

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ DUPLIC   ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao do Parcelamento das Duplicacatas                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Nfiscal                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function DUPLIC
Static Function DUPLIC()

Local BB

nCol := 1
nAjuste := 0
For BB:= 1 to Len(xVALOR_DUP)
   If xDUPLICATAS==.T. .and. BB<=Len(xVALOR_DUP)
      @ nLin, nCol + nAjuste      PSAY xNUM_DUPLIC + xPARC_DUP[BB]
      @ nLin, nCol + 14 + nAjuste PSAY xVENC_DUP[BB]
      @ nLin, nCol + 31 + nAjuste PSAY xVALOR_DUP[BB] Picture("@E 9,999,999.99")
      If BB == 3 .or. BB == 6
      	nLin++	
      	nAjuste := 0
      Else
	      nAjuste := nAjuste + 45
      Endif
   Endif
Next

Return

//+---------------------+
//¦ Fim da Funcao       ¦
//+---------------------+
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ LI       ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Pula 1 linha                                               ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Generico RDMAKE                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

//+---------------------+
//¦ Inicio da Funcao    ¦
//+---------------------+

//+---------------------+
//¦ Fim da Funcao       ¦
//+---------------------+


/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ IMPRIME  ¦ Autor ¦   Marcos Simidu       ¦ Data ¦ 20/12/95 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Imprime a Nota Fiscal de Entrada e de Saida                ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Generico RDMAKE                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 19/11/99 ==> Function Imprime
Static Function Imprime()
//+--------------------------------------------------------------+
//¦                                                              ¦
//¦              IMPRESSAO DA N.F. DA Nfiscal                    ¦
//¦                                                              ¦
//+--------------------------------------------------------------+

//+-------------------------------------+
//¦ Impressao do Cabecalho da N.F.      ¦
//+-------------------------------------+
@ 00, 000 PSAY CHR(27)+CHR(48)       //Salto de 1/8
@ 00, 001 PSAY Chr(15)               // Compressao de Impressao

//////////////////////
//TESTE DE IMPRESSAO//
//////////////////////

/*/
n1 := 1

//X -> LINHAS
//Y -> COLUNAS	
For x:=1 To 100
    
	If N1 == 10
		N1 := 1
	ENDIF	
	@X,000 PSAY ALLTRIM(STR(N1))+"XXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5XXXXXXXXX6XXXXXXXXX7XXXXXXXXX8XXXXXXXXX9XXXXXXXXX0"
	++N1	
Next x	
/*/

If mv_par04 == 1
   @ 01, 103 PSAY "X"
Else
   @ 01, 089 PSAY "X"
Endif

@ 02, 125 PSAY xNUM_NF               // Numero da Nota Fiscal

@ 06, 002 PSAY xNATUREZA               // Texto da Natureza de Operacao

If mv_par04 == 1
    @ 06, 054 PSAY xCF[1] Picture PESQPICT("SD1","D1_CF") // Codigo da Natureza de Operacao
Else
    @ 06, 054 PSAY xCF[1] Picture PESQPICT("SD2","D2_CF") // Codigo da Natureza de Operacao
EndIf


//+-------------------------------------+
//¦ Impressao dos Dados do Cliente      ¦
//+-------------------------------------+

@ 09, 002 PSAY xNOME_CLI              //Nome do Cliente

If !EMPTY(xCGC_CLI)                   // Se o C.G.C. do Cli/Forn nao for Vazio
   @ 09, 091 PSAY xCGC_CLI Picture"@R 99.999.999/9999-99"
Else
   @ 09, 091 PSAY " "                // Caso seja vazio
Endif

@ 09, 125 PSAY xEMISSAO              // Data da Emissao do Documento


@ 11, 002 PSAY xEND_CLI                                 // Endereco
@ 11, 076 PSAY xBAIRRO                                  // Bairro
@ 11, 105 PSAY xCEP_CLI Picture"@R 99999-999"           // CEP
@ 11, 125 PSAY " "                                      // Reservado  p/Data Saida/Entrada

@ 13, 002 PSAY xMUN_CLI                               // Municipio
@ 13, 056 PSAY xTEL_CLI                               // Telefone/FAX
@ 13, 083 PSAY xEST_CLI                               // U.F.
@ 13, 090 PSAY xINSC_CLI                              // Insc. Estadual
@ 13, 125 PSAY " "                                    // Reservado p/Hora da Saida

If mv_par04 == 2

   //+-------------------------------------+
   //¦ Impressao da Fatura/Duplicata       ¦
   //+-------------------------------------+

   nLin:=16
   BB:=1
   nCol :=1             //  duplicatas
   DUPLIC()

Endif

//+-------------------------------------+
//¦ Dados dos Produtos Vendidos         ¦
//+-------------------------------------+

nLin := 22
ImpDet()                 // Detalhe da NF


If mv_par04 == 2 .and. Empty(SC5->C5_YMSG01)

  nLin:=37
  MensObs()             // Imprime Mensagem de Observacao

  nLin:=40
  ImpMenp()             // Imprime Mensagem Padrao da Nota Fiscal

Endif


//+-------------------------------------+
//¦ Prestacao de Servicos Prestados     ¦
//+-------------------------------------+
If xTOT_SRV > 0

   //nLin := 36
   //Impmenp()

   //nLin :=44
   //MensObs()
    
	// Mensagem de Servico
	nLin := 37
	ObsServ()
	
  @ 50, 019  PSAY xBASE_ISS  Picture"@E@Z 999,999,999.99"   // Base do ISS
  @ 50, 041  PSAY xPER_ISS   Picture"@E@Z 99.99"   // Aliquota ISS
  @ 50, 052  PSAY xVALOR_ISS Picture"@E@Z 999,999,999.99"   // Valor ISS
  @ 50, 115  PSAY (xTOT_SRV-xTOT_DES)   Picture"@E@Z 999,999,999.99"   // Valor do Servico

Endif 

//+-------------------------------------+
//¦ Calculo dos Impostos                ¦
//+-------------------------------------+


@ 53, 001  PSAY xBASE_ICMS  Picture"@E@Z 999,999,999.99"  // Base do ICMS
@ 53, 032  PSAY xVALOR_ICMS Picture"@E@Z 999,999,999.99"  // Valor do ICMS
@ 53, 059  PSAY xBSICMRET   Picture"@E@Z 999,999,999.99"  // Base ICMS Ret.
@ 53, 086  PSAY xICMS_RET   Picture"@E@Z 999,999,999.99"  // Valor  ICMS Ret.
@ 53, 115  PSAY xVALOR_MERC Picture"@E 999,999,999.99"  // Valor Tot. Prod.

@ 55, 001  PSAY xFRETE      Picture"@E@Z 999,999,999.99"  // Valor do Frete
@ 55, 032  PSAY xSEGURO     Picture"@E@Z 999,999,999.99"  // Valor Seguro
@ 55, 059  PSAY xVALOR_IPI  Picture"@E@Z 999,999,999.99"  // Valor do IPI
@ 55, 115  PSAY (xVALOR_MERC+xTOT_SRV-xTOT_DES)    Picture"@E@Z 999,999,999.99"  // Valor Total NF
//@ 55, 115  PSAY xTOT_FAT    Picture"@E@Z 999,999,999.99"  // Valor Total NF


   //+------------------------------------+
   //¦ Impressao Dados da Transportadora  ¦
   //+------------------------------------+

@ 58, 001  PSAY xNOME_TRANSP                       // Nome da Transport.

If xTPFRETE=='C'                                   // Frete por conta do
   @ 58, 079 PSAY "1"                              // Emitente (1)
Else                                               //     ou
   @ 58, 079 PSAY "2"                              // Destinatario (2)
Endif

@ 58, 084 PSAY " "                                  // Res. p/Placa do Veiculo
@ 58, 059 PSAY " "                                  // Res. p/xEST_TRANSP                          // U.F.

If !EMPTY(xCGC_TRANSP)                              // Se C.G.C. Transportador nao for Vazio
   @ 58, 104 PSAY xCGC_TRANSP Picture"@R 99.999.999/9999-99"
Else
   @ 58, 104 PSAY " "                               // Caso seja vazio
Endif

@ 60, 004 PSAY xEND_TRANSP                          // Endereco Transp.
@ 60, 051 PSAY xMUN_TRANSP                          // Municipio
@ 60, 054 PSAY xEST_TRANSP                          // U.F.
@ 60, 070 PSAY " "                                  // Reservado p/Insc. Estad.


@ 62, 001 PSAY xVOLUME  Picture"@E@Z 999,999.99"             // Quant. Volumes
@ 62, 019 PSAY xESPECIE Picture"@!"                          // Especie
@ 62, 050 PSAY " "                                           // Res para Marca
@ 62, 070 PSAY " "                                           // Res para Numero
@ 62, 093 PSAY xPESO_BRUTO     Picture"@E@Z 999,999.99"      // Res para Peso Bruto
@ 62, 120 PSAY xPESO_LIQUID    Picture"@E@Z 999,999.99"      // Res para Peso Liquido

//If mv_par04 == 2
//   nLin := 65
//   Clasfis()               // Impressao de Classif. Fiscal
//Endif

If Len(xNUM_NFDV) > 0  .and. !Empty(xNUM_NFDV[1])
   @ 70, 010 PSAY STR0015 + "  " + xNUM_NFDV[1] + "  " + xPREF_DV[1] //"Nota Fiscal Original No."
Endif
If !Empty(xSuframa)
   @ 70, 060 PSAY STR0016+xSuframa //"SUFRAMA : "
EndIf

@ 72, 001 PSAY xOBS01 
@ 73, 001 PSAY xOBS02
@ 74, 001 PSAY xOBS03 

@ 81, 120 PSAY xNUM_NF                   // Numero da Nota Fiscal

@ 88, 000 PSAY ""
@ 88, 000 PSAY chr(18)                   // Descompressao de Impressao
@ 88, 000 PSAY CHR(27)+CHR(50)           // Retorna para 1/6 

SetPrc(0,0)                              // (Zera o Formulario)

Return .T.