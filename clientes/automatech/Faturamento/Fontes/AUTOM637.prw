#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                 ##
// ------------------------------------------------------------------------------------- ##
// Referencia: AUTOM637.PRW                                                              ##
// Parâmetros: Nenhum                                                                    ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                           ##
// ------------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                   ##
// Data......: 28/09/2017                                                                ##
// Objetivo..: Programa que realiza a Duplicação de Pedidos de Venda                     ##
// Parâmetros: kFilial, kPedido                                                          ##
// ########################################################################################

User Function AUTOM637(kFilial, kPedido)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private cPedido  := Space(06)
   Private cCliente := Space(60)
   Private oGet1
   Private oGet2

   Private oDlg

   // ##################################
   // Carrega dados para as variáveis ##
   // ##################################
   If Empty(Alltrim(kFilial))
      Return(.T.)
   Endif
      
   If Empty(Alltrim(kPedido))
      Return(.T.)
   Endif
      
   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( kFilial + kPedido )
      cPedido  := kPedido
      cCliente := SC5->C5_CLIENTE + "." + SC5->C5_LOJACLI + " - " + ;
                  Posicione( "SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_NOME" )
   Else
      MsgAlert("Pedido de Venda não localizado para duplicação.")
      Return(.T.)
   Endif   

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Duplicação de Pedido de Venda" FROM C(178),C(181) TO C(376),C(501) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(022) PIXEL OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(153),C(001) PIXEL OF oDlg
   @ C(077),C(002) GET oMemo2 Var cMemo2 MEMO Size C(153),C(001) PIXEL OF oDlg
   
   @ C(032),C(005) Say "Pedido de Venda a Ser Duplicado" Size C(082),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "Cliente"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(041),C(005) MsGet oGet1 Var cPedido  Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(063),C(005) MsGet oGet2 Var cCliente Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba  

   @ C(083),C(041) Button "Duplicar" Size C(037),C(012) PIXEL OF oDlg ACTION( DplNovoPedidoC(kFilial, kPedido) )
   @ C(083),C(080) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

/*

// #######################################
// Função que duplica o pedido de venda ##
// #######################################
User Function DplNovoPedidoC(kFilial, kPedido)

   // ################################
   // Posiciona no pedido de origem ##
   // ################################
   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( kFilial + kPedido )

      BEGIN TRANSACTION

         // ##########################################################
         // Pesquisa o próximo nº do pedido de venda a ser incluído ##
         // ##########################################################
         kNovoPedido := GetSxeNum( "SC5", "C5_NUM" )

         // ################################
         // Inclui o novo pedido de venda ##
         // ################################
         Reclock("SC5",.T.)
         C5_FILIAL   := SC5->C5_FILIAL	
         C5_NUM      := kNovoPedido
         C5_TIPO     := SC5->C5_TIPO	
         C5_CLIENTE  := SC5->C5_CLIENTE	
         C5_LOJACLI  := SC5->C5_LOJACLI	
         C5_LOJAENT  := SC5->C5_LOJAENT	
         C5_CLIENT   := SC5->C5_CLIENT	
         C5_FORMA    := SC5->C5_FORMA	
         C5_ADM      := SC5->C5_ADM	
         C5_TRANSP   := SC5->C5_TRANSP	
         C5_TSRV     := SC5->C5_TSRV	
         C5_TIPOCLI  := SC5->C5_TIPOCLI	
         C5_CONDPAG  := SC5->C5_CONDPAG	
         C5_TABELA   := SC5->C5_TABELA	
         C5_VEND1    := SC5->C5_VEND1	
         C5_COMIS1   := SC5->C5_COMIS1	
         C5_VEND2    := SC5->C5_VEND2	
         C5_COMIS2   := SC5->C5_COMIS2	
         C5_VEND3    := SC5->C5_VEND3	
         C5_COMIS3   := SC5->C5_COMIS3	
         C5_VEND4    := SC5->C5_VEND4	
         C5_COMIS4   := SC5->C5_COMIS4	
         C5_VEND5    := SC5->C5_VEND5	
         C5_COMIS5   := SC5->C5_COMIS5	
         C5_DESC1    := SC5->C5_DESC1	
         C5_DESC2    := SC5->C5_DESC2	
         C5_DESC3    := SC5->C5_DESC3	
         C5_DESC4    := SC5->C5_DESC4	
         C5_BANCO    := SC5->C5_BANCO	
         C5_DESCFI   := SC5->C5_DESCFI	
         C5_EMISSAO  := SC5->C5_EMISSAO	
         C5_COTACAO  := SC5->C5_COTACAO	
         C5_PARC1    := SC5->C5_PARC1	
         C5_DATA1    := SC5->C5_DATA1	
         C5_PARC2    := SC5->C5_PARC2	
         C5_DATA2    := SC5->C5_DATA2	
         C5_PARC3    := SC5->C5_PARC3	
         C5_DATA3    := SC5->C5_DATA3	
         C5_PARC4    := SC5->C5_PARC4	
         C5_DESPESA  := SC5->C5_DESPESA	
         C5_FRETAUT  := SC5->C5_FRETAUT	
         C5_REAJUST  := SC5->C5_REAJUST	
         C5_MOEDA    := SC5->C5_MOEDA	
         C5_DAT4     := SC5->C5_DATA4	
         C5_TPFRETE  := SC5->C5_TPFRETE	
         C5_FRETE    := SC5->C5_FRETE	
         C5_SEGURO   := SC5->C5_SEGURO	
         C5_PESOL    := SC5->C5_PESOL	
         C5_PBRUTO   := SC5->C5_PBRUTO	
         C5_REIMP    := SC5->C5_REIMP	
         C5_REDESP   := SC5->C5_REDESP	
         C5_VOLUME1  := SC5->C5_VOLUME1	
         C5_VOLUME2  := SC5->C5_VOLUME2	
         C5_VOLUME3  := SC5->C5_VOLUME3	
         C5_VOLUME4  := SC5->C5_VOLUME4	
         C5_ESPECI1  := SC5->C5_ESPECI1	
         C5_ESPECI2  := SC5->C5_ESPECI2	
         C5_ESPECI3  := SC5->C5_ESPECI3	
         C5_INCISS   := SC5->C5_INCISS	
         C5_LIBEROK  := SC5->C5_LIBEROK	
         C5_OK       := SC5->C5_OK	
         C5_NOTA     := SC5->C5_NOTA	
         C5_SERIE    := SC5->C5_SERIE	
         C5_ESPECI4  := SC5->C5_ESPECI4	
         C5_OS       := SC5->C5_OS	
         C5_ACRSFIN  := SC5->C5_ACRSFIN	
         C5_MENPAD   := SC5->C5_MENPAD	
         C5_KITREP   := SC5->C5_KITREP	
         C5_TXMOEDA  := SC5->C5_TXMOEDA	
         C5_TIPLIB   := SC5->C5_TIPLIB	
         C5_DESCONT  := SC5->C5_DESCONT	
         C5_PEDEXP   := SC5->C5_PEDEXP	
         C5_TPCARGA  := SC5->C5_TPCARGA	
         C5_DTLANC   := SC5->C5_DTLANC	
         C5_PDESCAB  := SC5->C5_PDESCAB	
         C5_BLQ      := SC5->C5_BLQ	
         C5_FORNISS  := SC5->C5_FORNISS	
         C5_CONTRA   := SC5->C5_CONTRA	
         C5_VLR_FRT  := SC5->C5_VLR_FRT	
         C5_MDCONTR  := SC5->C5_MDCONTR	
         C5_MDNUMED  := SC5->C5_MDNUMED	
         C5_GERAWMS  := SC5->C5_GERAWMS	
         C5_MDPLANI  := SC5->C5_MDPLANI	
         C5_ESTPRES  := SC5->C5_ESTPRES	
         C5_SOLFRE   := SC5->C5_SOLFRE	
         C5_FECENT   := SC5->C5_FECENT	
         C5_ORCRES   := SC5->C5_ORCRES	
         C5_SOLOPC   := SC5->C5_SOLOPC	
         C5_SUGENT   := SC5->C5_SUGENT	
         C5_RECISS   := SC5->C5_RECISS	
         C5_RECFAUT  := SC5->C5_RECFAUT	
         C5_NFSUBST  := SC5->C5_NFSUBST	
         C5_SERSUBS  := SC5->C5_SERSUBS	
         C5_JPCSEP   := SC5->C5_JPCSEP	
         C5_EXTERNO  := SC5->C5_EXTERNO	
         C5_FORNEXT  := SC5->C5_FORNEXT	
         C5_LOJAEXT  := SC5->C5_LOJAEXT	
         C5_OBSI     := SC5->C5_OBSI	
         C5_OBSNT    := SC5->C5_OBSNT	
         C5_VEICULO  := SC5->C5_VEICULO	
         C5_HORAEMB  := SC5->C5_HORAEMB	
         C5_CONHECI  := SC5->C5_CONHECI	
         C5_NFDISTR  := SC5->C5_NFDISTR	
         C5_PVEXTER  := SC5->C5_PVEXTER	
         C5_OBRA     := SC5->C5_OBRA	
         C5_PEDLOJA  := SC5->C5_PEDLOJA	
         C5_MUNPRES  := SC5->C5_MUNPRES	
         C5_DESCMUN  := SC5->C5_DESCMUN	
         C5_CNOT     := SC5->C5_CNOT	
         C5_TMEN     := SC5->C5_TMEN	
         C5_FCOR     := SC5->C5_FCOR	
         C5_CARTAO   := SC5->C5_CARTAO	
         C5_AUTORIZ  := SC5->C5_AUTORIZ	
         C5_TID      := SC5->C5_TID	
         C5_DOC      := SC5->C5_DOC	
         C5_DATCART  := SC5->C5_DATCART	
         C5_CODED    := SC5->C5_CODED	
         C5_NUMPR    := SC5->C5_NUMPR	
         C5_ORIGEM   := SC5->C5_ORIGEM	
         C5_NUMENT   := SC5->C5_NUMENT	
         C5_PREPEMB  := SC5->C5_PREPEMB	
         C5_MOEDTIT  := SC5->C5_MOEDTIT	
         C5_TXREF    := SC5->C5_TXREF	
         C5_DTTXREF  := SC5->C5_DTTXREF	
         C5_ZUSER    := SC5->C5_ZUSER	
         C5_NTEMPEN  := SC5->C5_NTEMPEN	
         C5_TIPOOBRA := SC5->C5_TIPOBRA	
         C5_INDPRES  := SC5->C5_INDPRES	
         C5_ZMSP     := SC5->C5_ZMSP	
         C5_NATUREZ  := SC5->C5_NATUREZ	
         C5_DTESERV  := SC5->C5_DTESERV	
         C5_MTMP     := SC5->C5_MTMP	
         C5_SDIS     := SC5->C5_SDIS	
         C5_DFEC     := SC5->C5_DFEC	
         C5_PSUP     := SC5->C5_PSUP	
         C5_ZPNUV    := SC5->C5_ZPNUV	
         C5_BAND     := SC5->C5_BAND	
         C5_PLIN     := SC5->C5_PLIN	
         C5_FLIN     := SC5->C5_FLIN	
         C5_ZCON     := SC5->C5_ZCON	
         C5_ZEMA     := SC5->C5_ZEMA	
         C5_ZTE1     := SC5->C5_ZTE1	
         C5_ZTE2     := SC5->C5_ZTE2	
         C5_ZIDC     := SC5->C5_ZIDC	
         C5_ZDD1     := SC5->C5_ZDD1	
         C5_ZDD2     := SC5->C5_ZDD2	
         C5_QEXAT    := SC5->C5_QEXAT	
         C5_ZEND     := SC5->C5_ZEND	
         C5_ZCOM     := SC5->C5_ZCOM	
         C5_ZBAI     := SC5->C5_ZBAI	
         C5_ZCID     := SC5->C5_ZCID	
         C5_ZCEP     := SC5->C5_ZCEP	
         C5_ZEST     := SC5->C5_ZEST	
         C5_ZPLV     := SC5->C5_ZPLV	
         C5_ZSER     := SC5->C5_ZSER	
         C5_ZLOC     := SC5->C5_ZLOC	
         C5_ZROD     := SC5->C5_ZROD	
         C5_ZTCX     := SC5->C5_ZTCX	
         C5_ZVALCRT  := SC5->C5_ZVALCRT
         MsUnlock()
   

             C6_FILIAL	:= SC6->C6_FILIAL
             C6_ITEM	:= SC6->C6_ITEM
             C6_PRODUTO	:= SC6->C6_PRODUTO
             C6_UM	    := SC6->C6_UM
             C6_QTDVEN	:= SC6->C6_QTDVEN
             C6_PRCVEN	:= SC6->C6_PRCVEN
             C6_VALOR	:= SC6->C6_VALOR
             C6_QTDLIB	:= SC6->C6_QTDLIB
             C6_QTDLIB2	:= SC6->C6_QTDLIB2
             C6_SEGUM	:= SC6->C6_SEGUM
             C6_TES	    := SC6->C6_TES
             C6_UNSVEN	:= SC6->C6_UNSVEN
             C6_LOCAL	:= SC6->C6_LOCAL
             C6_CF	    := SC6->C6_CF
             C6_QTDENT	:= SC6->C6_QTDENT
             C6_QTDENT2	:= SC6->C6_QTDENT2
             C6_CLI	    := SC6->C6_CLI
             C6_DESCONT	:= SC6->C6_DESCONT
             C6_VALDESC	:= SC6->C6_VALDESC
             C6_ENTREG	:= SC6->C6_ENTREG
             C6_LA	    := SC6->C6_LA
             C6_LOJA	:= SC6->C6_LOJA
             C6_NUM	    := knovoPedido
             C6_COMIS1	:= SC6->C6_COMIS1
             C6_COMIS2	:= SC6->C6_COMIS2
             C6_COMIS3	:= SC6->C6_COMIS3
             C6_COMIS4	:= SC6->C6_COMIS4
             C6_COMIS5	:= SC6->C6_COMIS5
             C6_DESCRI	:= SC6->C6_DESCRI
             C6_PRUNIT	:= SC6->C6_PRUNIT
             C6_BLOQUEI	:= SC6->C6_BLOQUEI
             C6_RESERVA	:= SC6->C6_RESERVA
             C6_OP	    := SC6->C6_OP
             C6_OK	    := SC6->C6_OK
             C6_IDENTB6	:= SC6->C6_IDENT6
             C6_BLQ	    := SC6->C6_BLQ
             C6_PICMRET	:= SC6->C6_PICMRET
             C6_CODISS	:= SC6->C6_CODISS
             C6_GRADE	:= SC6->C6_GRADE
             C6_ITEMGRD	:= SC6->C6_ITEMGRD
             C6_LOTECTL	:= SC6->C6_LOTECTL
             C6_NUMLOTE	:= SC6->C6_NUMLOTE
             C6_DTVALID	:= SC6->C6_DTVALID
             C6_CHASSI	:= SC6->C6_CHASSI
             C6_OPC	    := SC6->C6_OPC
             C6_LOCALIZ	:= SC6->C6_LOCALIZ
             C6_NUMSERI	:= SC6->C6_NUMSERI
             C6_CLASFIS	:= SC6->C6_CLASFIS
             C6_QTDRESE	:= SC6->C6_QTDRESE
             C6_CODFAB	:= SC6->C6_CODFAB
             C6_LOJAFA	:= SC6->C6_LOJAFA
             C6_ITEMCON	:= SC6->C6_ITEMCON
             C6_TPOP	:= SC6->C6_TPOP
             C6_REVISAO	:= SC6->C6_REVISAO
             C6_SERVIC	:= SC6->C6_SERVIC
             C6_ENDPAD	:= SC6->C6_ENDPAD
             C6_TPESTR	:= SC6->C6_TPESTR
             C6_CONTRT	:= SC6->C6_CONTRT
             C6_TPCONTR	:= SC6->C6_TPCONTR
             C6_ITCONTR	:= SC6->C6_ITCONTR
             C6_GEROUPV	:= SC6->C6_GEROUPV
             C6_PROJPMS	:= SC6->C6_PROJPMS
             C6_EDTPMS	:= SC6->C6_EDTPMS
             C6_TASKPMS	:= SC6->C6_TASKPMS
             C6_TRT	    := SC6->C6_TRT
             C6_QTDEMP	:= SC6->C6_QTDEMP
             C6_QTDEMP2	:= SC6->C6_QTDEMP2
             C6_PROJET	:= SC6->C6_PROJET
             C6_ITPROJ	:= SC6->C6_ITPROJ
             C6_POTENCI	:= SC6->C6_POTENCI
             C6_LICITA	:= SC6->C6_LICITA
             C6_REGWMS	:= SC6->C6_REGWMS
             C6_MOPC	:= SC6->C6_MOPC
             C6_NUMCP	:= SC6->C6_MUMCP
             C6_NUMSC	:= SC6->C6_MUMSC
             C6_ITEMSC	:= SC6->C6_ITEMSC
             C6_SUGENTR	:= SC6->C6_SUGENTR
             C6_ITEMED	:= SC6->C6_ITEMED
             C6_ABSCINS	:= SC6->C6_ABSCINSS
             C6_ABATISS	:= SC6->C6_ABATISS
             C6_ABATMAT	:= SC6->C6_ABATMAT
             C6_FUNRURA	:= SC6->C6_FUNRURA
             C6_FETAB	:= SC6->C6_FETAB
             C6_CODROM	:= SC6->C6_CODROM
             C6_PROGRAM	:= SC6->C6_PROGRAM
             C6_TURNO	:= SC6->C6_TURNO
             C6_PEDCOM	:= SC6->C6_PEDCOM
             C6_ITPC	:= SC6->C6_ITPC
             C6_FILPED	:= SC6->C6_FILPED
             C6_ABATINS	:= SC6->C6_ABATINS
             C6_CODLAN	:= SC6->C6_CODLAN
             C6_COMIAUT	:= SC6->C6_COMIAUT
             C6_QTGMRG	:= SC6->C6_QTGMRG
             C6_PARNUM	:= SC6->C6_PARNUM
             C6_MEDCC	:= SC6->C6_MEDCC
             C6_CUSMED	:= SC6->C6_CUSMED
             C6_TEMDOC	:= SC6->C6_TEMDOC
             C6_PRVCOMP	:= SC6->C6_PRVCOMP
             C6_LACRE	:= SC6->C6_LACRE
             C6_MARGEM	:= SC6->C6_MARGEM
             C6_ORDC	:= SC6->C6_ORDC
             C6_ORDA	:= SC6->C6_ORDA
             C6_DTADEV	:= SC6->C6_DTADEV
             C6_ICMSRET	:= SC6->C6_ICMSRET
             C6_VLIMPOR	:= SC6->C6_VLIMPOR
             C6_TNATREC	:= SC6->C6_TNATREC
             C6_CNATREC	:= SC6->C6_CNATREC
             C6_GRPNATR	:= SC6->C6_GRPNATR
             C6_DTFIMNT	:= SC6->C6_DTFIMNT
             C6_QTDORI	:= SC6->C6_QTDORI
             C6_BASVEIC	:= SC6->C6_BASVEIC
             C6_FCICOD	:= SC6->C6_FCICOD
             C6_NUMPCOM	:= SC6->C6_MUMPCOM
             C6_ITPCSTS	:= SC6->C6_ITPCSTS
             C6_SLDPCOM	:= SC6->C6_SLDPCOM
             C6_ZVOLUME	:= SC6->C6_ZVOLUME
             C6_SPCL	:= SC6->C6_SPCL
             C6_ORDS	:= SC6->C6_ORDS
             C6_ZBICRET	:= SC6->C6_ZBICRET
             C6_FORDED	:= SC6->C6_FORDED
             C6_LOJDED	:= SC6->C6_LOJDED
             C6_PVCOMOP	:= SC6->C6_PVCOMOP
             C6_VDMOST	:= SC6->C6_VDMOST
             C6_VDOBS	:= SC6->C6_VDOBS
             C6_HORENT	:= SC6->C6_
             C6_PMSID	:= SC6->C6_
             C6_SERDED	:= SC6->C6_
             C6_NFDED	:= SC6->C6_
             C6_VLNFD	:= SC6->C6_
             C6_PCDED	:= SC6->C6_
             C6_VLDED	:= SC6->C6_
             C6_TPDEDUZ	:= SC6->C6_
             C6_MOTDED	:= SC6->C6_
             C6_RATEIO	:= SC6->C6_
             C6_CODLPRE	:= SC6->C6_
             C6_ITLPRE	:= SC6->C6_
             C6_D1DOC	:= SC6->C6_
             C6_D1ITEM	:= SC6->C6_
             C6_D1SERIE	:= SC6->C6_
             C6_PEDVINC	:= SC6->C6_
             C6_REVPROD	:= SC6->C6_
             C6_CODINF	:= SC6->C6_
             C6_PRODFIN	:= SC6->C6_
             C6_DDIS	:= SC6->C6_
             C6_CDIS	:= SC6->C6_
             C6_ZGRA	:= SC6->C6_
             C6_TRATA	:= SC6->C6_
             C6_ZTPOP	:= SC6->C6_
             C6_ZTBL	:= SC6->C6_
             C6_ZRES	:= SC6->C6_
             C6_ZDOE    := SC6->C6_


         // ###############################################################
         // Confirma o número alocado através do último comando 6XENUM() ##
         // ###############################################################
         ConfirmSX8(.T.)



   END TRANSACTION















   // ###################################################################################
   // Abre o arquivo do dicionário de dados para capturar os campos do pedido de venda ##
   // ###################################################################################
   dbUseArea(.T., , "SX2" + Substring(cOrigem,01,02) + "0.DTC", "DBF_ORIGEM", .T., .F.)







/*

		_cNewNumPV := GetSxeNum( "SC5", "C5_NUM" )
        cPVDestino := _cNewNumPV

		For _nX := 1 To 5
			
			// [1] Código do Vendedor  [2] Percentual Original   [3] Novo Percentual
			aAdd( _aVend, { C5_ ("SC5->C5_VEND" + AllTrim( Str( _nX ) ) ), C5_ ("SC5->C5_COMIS" + AllTrim( Str( _nX ) ) ), 0 } )
			
			If !Empty( AllTrim( aTail( _aVend )[ 1 ] ) ) .And. aTail( _aVend )[ 2 ] == 0
				
				// Se o percentual no pedido estiver zerado para o vendedor, busco no cadastro deste vendedor.
				aTail( _aVend )[ 2 ] := Posicione( "SA3", 1, xFilial("SA3") + aTail( _aVend )[ 1 ], "A3_COMIS" )
			
			EndIf
	
		Next
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek( xFilial("SC6") + SC5->C5_NUM )
		
			While !SC6->( Eof() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + SC5->C5_NUM
				
				_aItem := {}
				_cProduto := IIf( Empty( _cProd ), SC6->C6_PRODUTO, _cProd )
	
				aAdd( _aItem, { "C6_FILIAL" , xFilial("SC6") , NIL } ) // Filial
				aAdd( _aItem, { "C6_NUM"    , _cNewNumPV     , NIL } ) // Número do Pedido
				aAdd( _aItem, { "C6_ITEM"   , SC6->C6_ITEM   , NIL } ) // Número do Item no Pedido
				aAdd( _aItem, { "C6_PRODUTO", _cProduto      , NIL } ) // Código do Produto
				aAdd( _aItem, { "C6_QTDVEN" , 1              , NIL } ) // Quantidade Vendida
				aAdd( _aItem, { "C6_PRCVEN" , SC6->C6_COMIAUT, NIL } ) // Preço Unitário Líquido
				aAdd( _aItem, { "C6_VALOR"  , SC6->C6_COMIAUT, NIL } ) // Valor Total do Item
				aAdd( _aItem, { "C6_ENTREG" , dDataBase      , NIL } ) // Data da Entrega
				aAdd( _aItem, { "C6_UM"     , SC6->C6_UM     , NIL } ) // Unidade de Medida Primária
				aAdd( _aItem, { "C6_TES"    , _cTes          , NIL } ) // Tipo de Entrada/Saida do Item
				aAdd( _aItem, { "C6_CLI"    , SC5->C5_FORNEXT, NIL } ) // Cliente
				aAdd( _aItem, { "C6_LOJA"   , SC5->C5_LOJAEXT, NIL } ) // Loja do Cliente
	
				_nTotCom += SC6->C6_COMIAUT  // Valor total da comissão da Automatech, ou seja, do pedido que será gerado.
				_nTotFat += SC6->C6_VALOR    // Valor total faturado contra o cliente, neste faturamento.
				
				aAdd( _aItens, _aItem )
				
				SC6->( dbSkip() )
			EndDo
		
		EndIf
		
		For _nX := 1 To 5
			If !Empty( AllTrim( _aVend[ _nX, 1 ] ) ) .And. _aVend[ _nX, 2 ] > 0
				// Calculando o valor de comissão devido, que é o percentual do vendedor sobre o total faturado.
				_ValComOrig :=  _nTotFat * (_aVend[ _nX, 2 ] / 100)
				// Calculando o novo percentual sobre a base deste pedido
				_nComis := ( _ValComOrig / _nTotCom ) * 100
				
				_aVend[ _nX, 3 ] := Round( _nComis, TamSX3("A3_COMIS")[ 2 ] )
			EndIf
		Next
		
		// Monta os dados para o cabeçalho do pedido
		aAdd( _aCabec, { "C5_FILIAL" , xFilial("SC5") , NIL } )
		aAdd( _aCabec, { "C5_NUM"    , _cNewNumPV     , NIL } )
		aAdd( _aCabec, { "C5_TIPO"   , "N"            , NIL } )
		aAdd( _aCabec, { "C5_CLIENTE", SC5->C5_FORNEXT, NIL } )
		aAdd( _aCabec, { "C5_LOJACLI", SC5->C5_LOJAEXT, NIL } )
		aAdd( _aCabec, { "C5_TIPOCLI", "F"            , NIL } )
		aAdd( _aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG, NIL } )
		aAdd( _aCabec, { "C5_VEND1"  , _aVend[ 1, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND2"  , _aVend[ 2, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND3"  , _aVend[ 3, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND4"  , _aVend[ 4, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND5"  , _aVend[ 5, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS1" , _aVend[ 1, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS2" , _aVend[ 2, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS3" , _aVend[ 3, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS4" , _aVend[ 4, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS5" , _aVend[ 5, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_EMISSAO", dDataBase      , NIL } )
		aAdd( _aCabec, { "C5_TIPLIB" , "2"            , NIL } )
		aAdd( _aCabec, { "C5_TPFRETE", "C"            , NIL } )
	
*/

