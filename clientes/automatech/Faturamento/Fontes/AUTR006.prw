#INCLUDE "rwmake.ch"

#define I_1_8POLEG		(CHR(27)+CHR(48))		   		// 1/8 polegada
#define I_CONDENSADO	(CHR(15))						// Condensado

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAUTR006   บAutor  ณMauro JPC           บ Data ณ  22/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressใo de nota fiscal de servi็o.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AUTR006()

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
   Private wnrel		:= "AUTR006" // Coloque aqui o nome do arquivo usado para impressao em disco
   Private cperg		:= "AUTR006"+SPACE(3)

   Private cString := "SF2"

   U_AUTOM628("AUTR006")

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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  13/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

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
	  //<<<<<< DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
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
	  If nLin > 65 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 nLin := 20
	  Endif
	
	  @ 00,000 PSAY I_1_8POLEG+I_CONDENSADO
	  nLin := 10//19
	
	  @ nLin,088 PSAY Iif(cEstdCli="RS","5933","6933") //Natureza operacao/CFOP(somente para servico)
	
	  nLin := nLin + 3
	  @ nLin,088 PSAY SF2->F2_EMISSAO
	  @ nLin,113 PSAY SF2->F2_DOC
	
	  nLin := nLin + 3
	  @ nLin,013 PSAY cNomeCli
	  nLin := nLin+3
	  @ nLin,016 PSAY cEndeCli
	  nLin := nLin+3
	  @ nLin,016 PSAY cMuniCli
	  @ nLin,071 PSAY cEstdCli
	  nLin := nLin+1
	  @ nLin,076 PSAY cDescCond
	  nLin := nLin+2
	  @ nLin,018 PSAY cCNPJCli
	  @ nLin,062 PSAY cIncECli
	  nLin := nLin+3
	  @ nLin,023 PSAY cIncMCli
	
	  nLin := 35
	
 	  // Dados da NF
	  DbSelectArea("SD2")
	  DbSetOrder(3)
	  DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+cCodgCli+cLojaCli)

	  _Xpedido   := D2_PEDIDO
	  _Xfilial   := D2_FILIAL
      _Xvendedor := _Xvendedor + "'" + SF2->F2_VEND1 + "',"
      _Apedidos  := _Apedidos  + Alltrim(D2_PEDIDO)  + ", "

	  Do While !EOF() .And. SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE
		
	     If nLin > 54 //Caso produtos cheguem neste linha, inicia uma nova pagina
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 35
		Endif
		
		@ nLin,008 PSAY SD2->D2_UM
		@ nLin,023 PSAY SD2->D2_QUANT
		@ nLin,036 PSAY POSICIONE("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
		@ nLin,089 PSAY SD2->D2_PRCVEN PICTURE "@E 999,999,999.99"
		@ nLin,109 PSAY SD2->D2_TOTAL PICTURE "@E 999,999,999.99"

		nTotalNota := nTotalNota + SD2->D2_TOTAL
		nLin := nLin + 1 // Avanca a linha de impressao
		
		DbSelectArea("SD2")
		DbSkip()

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

// -----------------------------------
//	  cQuery := {}
//	  cQuery := " SELECT CAST( CAST(C5_MENNOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS OBSERVA"
//      cQuery += "   FROM "+ RETSQLNAME("SC5") +"  "
//	  cQuery += "  WHERE C5_NUM    = '" + _Xpedido + "'"
//	  cQuery += "    AND C5_FILIAL = '" + _Xfilial + "'"
//	  cQuery += "    AND D_E_L_E_T_ <> '*' "
//
// 	  cQuery := ChangeQuery(cQuery)
//	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSC5",.T.,.T.)
//	
//	  DbSelectArea("TSC5")
//	  cMensagem := Alltrim(TSC5->OBSERVA)
//	  DbSelectArea("TSC5")
//	  DbCloseArea()
// 
//      If Empty(Alltrim(cMensagem))
//         cMensagem := "PEDIDO NR. " + Alltrim(_Xpedido)
//      Endif
// ------------------------------------	

	  // Impressใo da mensagem da nota.
	  cQuery := {}
	  cQuery := " SELECT CAST( CAST(C5_MENNOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS OBSERVA,"
      cQuery += "       (SELECT DISTINCT SUBSTRING(C6_NUMORC,01,06)"
      cQuery += "          FROM " + RetSqlName("SC6")
      cQuery += "         WHERE C6_FILIAL  = C5_FILIAL" 
      cQuery += "           AND C6_NUM     = C5_NUM"
      cQuery += "           AND D_E_L_E_T_ = '') AS NUMEROOS"  
      cQuery += "   FROM " + RETSQLNAME("SC5")
	  cQuery += "  WHERE C5_NUM    = '" + Alltrim(_Xpedido) + "'"
	  cQuery += "    AND C5_FILIAL = '" + Alltrim(_Xfilial) + "'"
	  cQuery += "    AND D_E_L_E_T_ <> '*'"

 	  cQuery := ChangeQuery(cQuery)
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TSC5",.T.,.T.)
	
	  DbSelectArea("TSC5")
      cNumeroOs := Alltrim(TSC5->NUMEROOS)
	  cMensagem := Alltrim(TSC5->OBSERVA)
	  DbSelectArea("TSC5")
	  DbCloseArea()               
 
      If Empty(Alltrim(cMensagem))
         If Empty(Alltrim(cNumeroOS))
            cMensagem :=  "PEDIDO NR. " + Alltrim(_Xpedido)
         Else   
            cMensagem :=  "OS NR. " + Alltrim(cNumeroOS) + " - " + "PEDIDO NR. " + Alltrim(_Xpedido)
         Endif   
      Else
         If !Empty(Alltrim(cNumeroOS))
            cMensagem :=  "OS NR. " + Alltrim(cNumeroOS) + " - " + cMensagem
         Endif   
      Endif

	  If !Empty(cMensagem)
		 nLin := nLin + 1 // Avanca a linha de impressao
		 If nLin > 54 //Caso chegue neste linha, inicia uma nova pagina
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 35
		 Endif
		 @nLin,036 PSAY cMensagem
		 nLin := nLin + 1 // Avanca a linha de impressao
	  EndIf
	
	  // Impressใo da mensagem sobre as reten็๕es.
	  If Alltrim(cCNature) == "10111" //<<<<<< Caso a natureza tenha reten็ใo.
		 nLin := nLin + 1 // Avanca a linha de impressao
		 If nLin > 54 //Caso chegue neste linha, inicia uma nova pagina
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 35
		 Endif
		 nTotAbat := SF2->F2_VALCSLL + SF2->F2_VALCOFI + SF2->F2_VALPIS
		 @nLin,036 PSAY "Ret. PIS/COFINS/CSLL Valor: "
		 @nLin,109 PSAY nTotAbat  PICTURE "@E 999,999,999.99"
		 nLin := nLin + 1 // Avanca a linha de impressao
	  EndIf
	
	  // Impressใo dos totais da nota.
	  nLin := 56
	  @ nLin,020 PSAY nPerAliqISS PICTURE "@E 99.99"			// Imprime O VALOR DA ALIQUOTA DO ISSQN.
	  @ nLin,046 PSAY nTotAliqISS PICTURE "@E 999,999,999.99"	// Imprime O VALOR TOTAL DO ISSQN.
	
	  If Alltrim(cCNature) == "10111" //<<<<<< Caso a natureza tenha reten็ใo.
		 @ nLin,109 PSAY nTotalNota - ( nTotAbat ) PICTURE "@E 999,999,999.99"	// Imprime O VALOR TOTAL DA NOTA com abatimento dos impostos recolhidos.
	  Else
		 @ nLin,109 PSAY nTotalNota PICTURE "@E 999,999,999.99"	// Imprime O VALOR TOTAL DA NOTA.
	  EndIf
	
	  nLin := nLin + 7 // Avanca a linha de impressao
	  @ nLin,027 PSAY DAY(DATE())
	  _cMes := cMes(DATE())  // fun็ใo que retorna o m๊s em portugu๊s.
	  @ nLin,042 PSAY _cMes
	  @ nLin,057 PSAY Year(DATE())
	  @ nLin,113 PSAY SF2->F2_DOC
	
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
//       U_AUTOMR20(cEmail, Alltrim(T_AVISO->A3_EMAIL), "", "Aviso de Faturamento" )
         
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