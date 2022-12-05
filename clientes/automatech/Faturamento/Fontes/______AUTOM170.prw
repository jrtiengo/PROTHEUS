#INCLUDE "rwmake.ch"

#define I_1_8POLEG		(CHR(27)+CHR(48))		   		// 1/8 polegada
#define I_CONDENSADO	(CHR(15))						// Condensado

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAวรO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM170.PRW                                                        *
// Parโmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L๖schenkohl                                             *
// Data......: 15/04/2013                                                          *
// Objetivo..: Programa que imprime a Nota Fiscal de Servi็o                       *
// ------------------------------------------------------------------------------- *
//                     NOVO LAYOUT DE NOTA FISCAL DE SERVIวO                       *
//**********************************************************************************

User Function AUTOM170()

   // Declaracao de Variaveis
   Local cDesc1	 := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2	 := "de acordo com os parametros informados pelo usuario."
   Local cDesc3	 := "Emissใo NF Servico"
   Local cPict	 := ""
   Local titulo	 := "Emissใo NF Servico"
   Local nLin	 := 0
   Local _cMes   := ""

   Local Cabec1	 := ""
   Local Cabec2	 := ""
   Local imprime := .T.
   Local aOrd	 := {}

   Private lEnd			:= .F.
   Private lAbortPrint	:= .F.
   Private CbTxt		:= ""
   Private limite		:= 80
   Private tamanho		:= "P"
   Private nomeprog		:= "AUTR006"
   Private nTipo		:= 18
   Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey		:= 0
   Private cbtxt		:= Space(10)
   Private cbcont		:= 00
   Private CONTFL		:= 01
   Private m_pag		:= 01
   Private wnrel		:= "AUTR006"
   Private cperg		:= "AUTR006"+SPACE(3)

   Private cString := "SF2"

   dbSelectArea("SF2")
   dbSetOrder(1)

   ValidPerg()
   Pergunte(cPerg,.F.)

   wnrel := SetPrint(cString,NomeProg,cperg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
	  Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento.
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

// Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local cSql        := ""  // String para elabora็ใo de comandos SQL
   Local nOrdem
   Local cNomeCli	 := ""	// Nome
   Local cEndeCli	 := ""	// Endere็o
   Local cMuniCli	 := ""	// Cidade
   Local cEstdCli	 := ""	// Estado
   Local cCNPJCli	 := ""	// CGC
   Local cIncMCli	 := ""	// Inscri็ใo municipal
   Local cIncECli	 := ""	// Inscri็ใo estadual
   Local cCNature	 := ""	// Natureza do cliente
   Local nTotalNota	 := 0	// Valor tota da nota
   Local cDescCond	 := ""	// Descricao da condicao de pagamento
   Local NPerAliqISS := 0	// Aliquota do ISSQN
   Local nTotAliqISS := 0	// Valor do ISSQN
   Local cCCliente	 := ""	// Codigo do cliente
   Local cLCliente	 := ""	// Loja do cliente
   Local nTotAbat 	 := 0
   Local cMensagem	 := ""
   Local cMens01     := ""
   Local cMens02     := ""
   Local cMens03     := ""
   Local _Xpedido    := ""
   Local _Xfilial    := ""
   Local _Xvendedor  := ""
   Local _Apedidos   := ""
   Local cEmail      := ""

   dbSelectArea(cString)
   dbSetOrder(1)

   // SETREGUA -> Indica quantos registros serao processados para a regua
   SetRegua(RecCount())

   DbSelectArea("SF2")
   DbSetOrder(1)
   DbSeek(xFilial("SF2")+MV_PAR01)

   While !EOF() .And. SF2->F2_DOC >= MV_PAR01 .And. SF2->F2_DOC <= MV_PAR02

      If SF2->F2_SERIE <> MV_PAR03
	     DbSkip()
		 Loop
	  EndIf
	
	  cCCliente := SF2->F2_CLIENTE
	  cLCliente := SF2->F2_LOJA
	
  	  // Localiza os dados do cliente
	  DbSelectArea("SA1")
	  DbSetOrder(1)

	  // Pesquisa os dados do Cliente
  	  DbSeek(xFilial("SA1")+cCCliente+cLCliente)
	  cCodgCli := SA1->A1_COD
	  cLojaCli := SA1->A1_LOJA
	  cNomeCli := SA1->A1_NOME
	  cEndeCli := SA1->A1_END
	  cMuniCli := SA1->A1_MUN
	  cEstdCli := SA1->A1_EST
	  cCNPJCli := SA1->A1_CGC
	  cIncMCli := SA1->A1_INSCRM
	  cIncECli := SA1->A1_INSCR
	  cCNature := SA1->A1_NATUREZ
	  DbSelectArea("SA1")
	  DbCloseArea()
	
	  // Descri็ใo da condicao de pagamento
	  cDescCond := Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_DESCRI")
	
	  // ISSQN - Aliquota e valor
	  cQuery := {}
	  cQuery := " SELECT CD2_ALIQ, CD2_VLTRIB FROM "+ RETSQLNAME("CD2") +"  "
	  cQuery += " WHERE CD2_DOC  =	'" + SF2->F2_DOC		+"' "
	  cQuery += " AND CD2_SERIE  =	'" + SF2->F2_SERIE		+"' "
	  cQuery += " AND CD2_CODCLI =	'" + SF2->F2_CLIENTE	+"' "
	  cQuery += " AND CD2_LOJCLI =	'" + SF2->F2_LOJA		+"' "
	  cQuery += " AND CD2_IMP    =	'ISS' "

	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TCD2",.T.,.T.)

	  TCSetField("TCD2","CD2_ALIQ"	,"N",05,02)
	  TCSetField("TCD2","CD2_VLTRIB","N",15,02)
	
	  DbSelectArea("TCD2")
	  Do While !EOF()
		 nPerAliqISS := TCD2->CD2_ALIQ
		 nTotAliqISS += CD2_VLTRIB
		
		 DbSelectArea("TCD2")
		 DbSkip()
	  EndDo

	  DbSelectArea("TCD2")
	  DbCloseArea()

	  // Verifica o cancelamento pelo usuario
	  If lAbortPrint
 	   	 @ nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		 Exit
	  Endif
	
	  // Impressao do cabecalho do relatorio
	  // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
	  If nLin > 65 
		 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 nLin := 20
	  Endif
	
	  @ 00,000 PSAY I_1_8POLEG+I_CONDENSADO
	  nLin := 10 //19
	
      // Natureza operacao/CFOP(somente para servico)
	  @ nLin,088 PSAY Iif(cEstdCli="RS","5933","6933") 
	
	  nLin := nLin + 3
	  @ nLin,088 PSAY SF2->F2_EMISSAO
	  @ nLin,113 PSAY SF2->F2_DOC
	
	  nLin := nLin + 3
	  @ nLin,017 PSAY cNomeCli
	  nLin := nLin + 3
	  @ nLin,017 PSAY cEndeCli
	  nLin := nLin + 3
	  @ nLin,017 PSAY cMuniCli
	  @ nLin,070 PSAY cEstdCli
	  @ nLin,087 PSAY cDescCond
	  nLin := nLin + 3
	  @ nLin,017 PSAY cCNPJCli
	  @ nLin,064 PSAY cIncECli
	  nLin := nLin + 3
	  @ nLin,017 PSAY cIncMCli
	
	  nLin := 35
	
 	  // Dados da NF
//	  DbSelectArea("SD2")
//	  DbSetOrder(3)
//	  DbSeek(xFilial("SD2")+Alltrim(SF2->F2_DOC)+SF2->F2_SERIE+cCodgCli+cLojaCli)

//	  _Xpedido   := D2_PEDIDO
//	  _Xfilial   := D2_FILIAL
//    _Xvendedor := _Xvendedor + "'" + SF2->F2_VEND1 + "',"
//    _Apedidos  := _Apedidos  + Alltrim(D2_PEDIDO)  + ", "

      If Select("T_PRODUTO") > 0
        T_PRODUTO->( dbCloseArea() )
      EndIf

      cSql := "SELECT A.D2_FILIAL,"
      cSql += "       A.D2_PEDIDO,"
      cSql += "       A.D2_UM    ,"
      cSql += "       A.D2_QUANT ,"
      cSql += "       B.B1_DESC  ,"
      cSql += "       A.D2_PRCVEN,"
      cSql += "       A.D2_TOTAL  "
      cSql += "  FROM " + RetSqlName("SD2") + " A, "
      cSql += "       " + RetSqlName("SB1") + " B  "
      cSql += " WHERE A.D2_FILIAL  = '" + Alltrim(cFilAnt)       + "'"
      cSql += "   AND A.D2_DOC     = '" + Alltrim(SF2->F2_DOC)   + "'"
      cSql += "   AND A.D2_SERIE   = '" + Alltrim(SF2->F2_SERIE) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND B.B1_FILIAL  = ''"
      cSql += "   AND A.D2_COD     = B.B1_COD"
      cSql += "   AND B.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

	  _Xpedido   := T_PRODUTO->D2_PEDIDO
	  _Xfilial   := T_PRODUTO->D2_FILIAL
      _Xvendedor := _Xvendedor + "'" + SF2->F2_VEND1 + "',"
      _Apedidos  := _Apedidos  + Alltrim(T_PRODUTO->D2_PEDIDO)  + ", "


//    Do While !EOF() .And. SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE
	
	  WHILE !T_PRODUTO->( EOF() )
		
         // Caso produtos cheguem neste linha, inicia uma nova pagina
	     If nLin > 46 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 35
		Endif
		
//		@ nLin,006 PSAY SD2->D2_UM
//		@ nLin,020 PSAY SD2->D2_QUANT
//		@ nLin,033 PSAY POSICIONE("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
//		@ nLin,088 PSAY SD2->D2_PRCVEN PICTURE "@E 999,999,999.99"
//		@ nLin,107 PSAY SD2->D2_TOTAL  PICTURE "@E 999,999,999.99"

//		nTotalNota := nTotalNota + SD2->D2_TOTAL

		@ nLin,006 PSAY T_PRODUTO->D2_UM
		@ nLin,020 PSAY T_PRODUTO->D2_QUANT
		@ nLin,033 PSAY T_PRODUTO->B1_DESC
		@ nLin,088 PSAY T_PRODUTO->D2_PRCVEN PICTURE "@E 999,999,999.99"
		@ nLin,107 PSAY T_PRODUTO->D2_TOTAL  PICTURE "@E 999,999,999.99"

		nTotalNota := nTotalNota + T_PRODUTO->D2_TOTAL

        // Avanca a linha de impressao
		nLin := nLin + 1 
  
		T_PRODUTO->( DbSkip() )
				
//		DbSelectArea("SD2")
//		DbSkip()

	  EndDo
	
	  DbSelectArea("SD2")
      DbCloseArea()
	
	  // Impressใo da mensagem da nota.
      //	cQuery := {}
      //	cQuery := " SELECT C5_MENNOTA FROM "+ RETSQLNAME("SC5") +"  "
      //	cQuery += " WHERE C5_NOTA =		'"+ SF2->F2_DOC			+"' "
      //	cQuery += " AND C5_SERIE =		'"+ SF2->F2_SERIE		+"' "
      //	cQuery += " AND C5_CLIENTE =	'"+ SF2->F2_CLIENTE		+"' "
      //	cQuery += " AND C5_LOJACLI =	'"+ SF2->F2_LOJA		+"' "
      //	cQuery += " AND D_E_L_E_T_ <> '*' "

	  cQuery := {}
	  cQuery := " SELECT CAST( CAST(C5_MENNOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS OBSERVA"
      cQuery += "   FROM " + RETSQLNAME("SC5")
	  cQuery += "  WHERE C5_NUM    = '" + Alltrim(_Xpedido) + "'"
	  cQuery += "    AND C5_FILIAL = '" + Alltrim(_Xfilial) + "'"
	  cQuery += "    AND D_E_L_E_T_ <> '*'"

 	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSC5",.T.,.T.)
	
	  DbSelectArea("TSC5")
	  cMensagem := Alltrim(TSC5->OBSERVA)
	  DbSelectArea("TSC5")
	  DbCloseArea()               
 
      If Empty(Alltrim(cMensagem))
         cMensagem := "PEDIDO NR. " + Alltrim(_Xpedido)
      Endif
	
	  If !Empty(cMensagem)

         If Len(Alltrim(cMensagem)) < 300
            cMensagem := alltrim(cMensagem) + replicate(" ", 300 - len(alltrim(cmensagem)))
         Endif
         
         cMens01 := Substr(cMensagem,001,100)
         cMens02 := Substr(cmensagem,101,100)
         cMens03 := Substr(cMensagem,201,100)   
            
         // Avanca a linha de impressao
		 nLin := nLin + 1 
		 
         // Caso chegue neste linha, inicia uma nova pagina		 
		 If nLin > 46 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 35
		 Endif
		 @ nLin,012 PSAY cMens01
		 nLin := nLin + 1 
		 @ nLin,012 PSAY cMens02
		 nLin := nLin + 1 
		 @ nLin,012 PSAY cMens03
		 nLin := nLin + 1 

	  EndIf
	
	  // Impressใo da mensagem sobre as reten็๕es.
	  If Alltrim(cCNature) == "10111" //<<<<<< Caso a natureza tenha reten็ใo.
		 nLin := nLin + 1 // Avanca a linha de impressao
		 If nLin > 46 //Caso chegue neste linha, inicia uma nova pagina
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 35
		 Endif
		 nTotAbat := SF2->F2_VALCSLL + SF2->F2_VALCOFI + SF2->F2_VALPIS
		 @nLin,033 PSAY "Ret. PIS/COFINS/CSLL Valor: "
		 @nLin,107 PSAY nTotAbat  PICTURE "@E 999,999,999.99"
		 nLin := nLin + 1 // Avanca a linha de impressao
	  EndIf
	
      If Empty(Alltrim(cMensagem))
// 	     nLin := 48
   	     nLin := 46
   	  Else
// 	     nLin := 48
  	     nLin := 46
   	  Endif

	  // Imprime a informa็ใo do ISSQN, Percentual e Valor
      @ nLin,012 PSAY "ISSQN: " + Transform(nPerAliqISS,"@E 999.99") + " % - VALOR: " + Transform(nTotAliqISS, "@E 999,999,999.99")
      nLin := nLin + 2

	  // Impressใo dos totais da nota.
      @ nLin,107 PSAY nTotalNota  PICTURE "@E 999,999,999.99"	// Sub-Total da Nota Fiscal

      nLin := nLin + 4

//    @ nLin,080 PSAY "ISSQN"     PICTURE "@!"                  // Imprime a inscri็ใo ISSQN
//	  @ nLin,095 PSAY nPerAliqISS PICTURE "@E 99.99"			// Imprime O VALOR DA ALIQUOTA DO ISSQN.
//	  @ nLin,107 PSAY nTotAliqISS PICTURE "@E 999,999,999.99"	// Imprime O VALOR TOTAL DO ISSQN.

      nLin := nLin + 4

	  If Alltrim(cCNature) == "10111" //<<<<<< Caso a natureza tenha reten็ใo.
		 @ nLin,107 PSAY nTotalNota - ( nTotAbat ) PICTURE "@E 999,999,999.99"	// Imprime O VALOR TOTAL DA NOTA com abatimento dos impostos recolhidos.
	  Else
		 @ nLin,107 PSAY nTotalNota PICTURE "@E 999,999,999.99"	// Imprime O VALOR TOTAL DA NOTA.
	  EndIf
	
	  nLin := nLin + 7 // Avanca a linha de impressao
	  @ nLin,025 PSAY DAY(DATE())
	  _cMes := cMes(DATE())  // fun็ใo que retorna o m๊s em portugu๊s.
	  @ nLin,033 PSAY _cMes
	  @ nLin,054 PSAY Year(DATE())
	  @ nLin,110 PSAY SF2->F2_DOC
	
	  nLin := nLin+2
	
	  // Limpa as variแveis.
	  nTotAbat  := 0
	  cMensagem := ""
	
	  DbSelectArea("SF2")
	  dbSkip() // Avanca o ponteiro do registro no arquivo

   EndDo

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao
   If aReturn[5]==1
	  dbCommitAll()
	  SET PRINTER TO
	  OurSpool(wnrel)
   Endif

   MS_FLUSH()

   // Envia e-mail ao vendedor do pedido lhe informando do faturamento da Nota Fiscal de Servi็o
   If !Empty(Alltrim(_Xvendedor))
   
      // Elimina a ๚ltima vํrgula da viriแvel _Xvendedor
      _Xvendedor := Substr(_Xvendedor, 1, Len(Alltrim(_Xvendedor)) - 1)

      // Elimina a ๚ltima vํrgula da viriแvel _Apedido
      _Apedidos  := Substr(_Apedidos, 1, Len(Alltrim(_APedidos)) - 1)

      If Select("T_AVISO") > 0
         T_AVISO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A3_COD  ,"
      cSql += "       A3_NOME ,"
      cSql += "       A3_EMAIL "
      cSql += "  FROM " + RetSqlName("SA3")
      cSql += " WHERE A3_COD IN (" + Alltrim(_Xvendedor) + ")"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AVISO", .T., .T. )

      T_AVISO->( DbGoTop() )

      WHILE !T_AVISO->( EOF() )

         cEmail := ""
         cEmail := "Prezado(a) " + Alltrim(T_AVISO->A3_NOME) + Chr(13) + chr(10) + chr(13) + chr(10)
         cEmail += "Viemos lhe informar que foi impressa a nota fiscal de servi็o de nบ " + Alltrim(MV_PAR01) + Chr(13) + chr(10)
         cEmail += "conforme dados abaixo:" + Chr(13) + chr(10) + chr(13) + chr(10)
         cEmail += "Cliente: " + Alltrim(cNomeCli) + Chr(13) + chr(10)
         cEmail += "Pedido(s) de Venda: " + Alltrim(_Apedidos) + Chr(13) + chr(10) + Chr(13) + chr(10)
         cEmail += "Att." + Chr(13) + chr(10) + Chr(13) + chr(10)
         cEmail += "Automatech Sistema de Automa็ใo Ltda" + Chr(13) + chr(10)
         cEmail += "Departamento de Faturamento" + Chr(13) + chr(10)

         // Envia o e-mail
//         U_AUTOMR20(cEmail, Alltrim(T_AVISO->A3_EMAIL), "", "Aviso de Faturamento" )
         
         T_AVISO->( DbSkip() )
         
      ENDDO
      
   ENDIF

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณMauro JPC           บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao das perguntas.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function VALIDPERG()

   cAlias := Alias()
   aRegs  :={}
   
   AADD(aRegs,{cPerg,"01","NF de         ?","","","mv_ch1","C",09,0,0,"G","           ","mv_par01","    ","","","","","    ","","","","","","","","","","","","","","","","","","","SF2",""})
   AADD(aRegs,{cPerg,"02","NF ate        ?","","","mv_ch2","C",09,0,0,"G","           ","mv_par02","    ","","","","","    ","","","","","","","","","","","","","","","","","","","SF2",""})
   AADD(aRegs,{cPerg,"03","Serie         ?","","","mv_ch3","C",03,0,0,"G","           ","mv_par03","    ","","","","","    ","","","","","","","","","","","","","","","","","","","   ",""})

   DbSelectArea("SX1")
   DbSetOrder(1)
   
   For i:=1 to Len(aRegs)
	   If !DbSeek(cPerg+aRegs[i,2])
	      RecLock("SX1",.T.)
		  For j:=1 to FCount()
			  If j<=Len(aRegs[i])
				 FieldPut(j,aRegs[i,j])
			  Endif
		  Next
		  MsUnlock()
	   Endif
   Next

   DbSelectArea(cAlias)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcMes บAutor  ณRafael JPC             บ Data ณ  14/06/11     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o nome do m๊s em portugu๊s.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function cMes(cData)

   aMeses  :={}
   nNum := 13
   _cData := ""

   AADD(aMeses,"Janeiro")
   AADD(aMeses,"Fevereiro")
   AADD(aMeses,"Mar็o")
   AADD(aMeses,"Abril")
   AADD(aMeses,"Maio")
   AADD(aMeses,"Junho")
   AADD(aMeses,"Julho")
   AADD(aMeses,"Agosto")
   AADD(aMeses,"Setembro")
   AADD(aMeses,"Outubro")
   AADD(aMeses,"Novembro")
   AADD(aMeses,"Dezembro")
   AADD(aMeses,"FAIL")

   nNum := Month(cData)
   _cData := aMeses[nNum]

Return(_cData)