#Include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 03/07/00
#INCLUDE "IMPFER.CH"

User Function STCIMPFER()        // incluido pelo assistente de conversao do AP5 IDE em 03/07/00

Local nCntCd	:= 0 
Local nConta	:= 0 
Local nDiaFeQueb 	:= 0 
//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

SetPrvt("CREPLIC77,CREPLIC22,CREPLIC30,CREPLIC33,CREPLIC35,CREPLIC40")
SetPrvt("N1PARC,NABONO,N13ABONO,CDESC,CLINHA,NLI")
SetPrvt("NVALAB13,NVALAB,NVAL13O,NVAL13A,NPEN13O,NVALNLIQ,CRET1")
SetPrvt("CRET2,CABONO,CEXT,APDV,APDD,PER_AQ_I")
SetPrvt("PER_AQ_F,PER_GO_I,PER_GO_F,NMAXIMO,NTVD,DET")
SetPrvt("NTVP")

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 03/07/00 ==> 	#DEFINE PSAY SAY

// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 03/07/00 ==> #INCLUDE "IMPFER.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � IMPFER   � Autor � R.H. - Aldo           � Data � 29.10.97 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Recibo de Ferias                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ImpFer(void)                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cristina    �02/06/98�xxxxxx� Conversao para outros idiomas.           ���
���Aldo        �24/02/99�      � Bug do Milenio.                          ���
���Aldo        �24/02/99�19699a� Impressao da Solic de 13a.Salario e Abono���
���            �        �      � Pecuniario antes de calcular as ferias.  ���
���Marina      �30/08/00�      � Retirada parte DOS.                      ���
���Natie       �01/11/00�------� Impressao Abono Pecuniario (s/calculo)   ���
���            �        �      � Ignora func. que nao tem Abono           ���
���Mauro       �12/01/01�------� Considerar o Tipo da Verba no SRV.       ���
���Emerson     �21/05/01�------� Ajustes p/ imprimir pensao da 1a parcela ���
���Emerson     �13/06/01�------� Ajustes na impressao de solicitacao de   ���
���            �        �      � abono antes de calcular ferias.		  ���
���Emerson     �23/10/01�------�Chamar funcao fDtBusFer()-Dt. Busca Ferias���
���Andreia     �05/08/02�------�Criacao dos campos RH_ABOPEC e RF_ABOPEC  ���
���            �        �------�para tratar de forma individual se o abono���
���            �        �------�sera pago antes ou depois do gozo das fe- ���
���            �        �------�rias.                                     ���
���Priscila    �08/05/03�061460�Chamada funcao DataValida p/ que a Data da���
���            �        �------�Solicitacao do Abono seja um dia util.    ���
���Natie       �22/06/07�128084�Ajuste na impressao da dt final de ferias ���
���            �        �------�qdo tem Licensa remunerada                ���
���Renata      �05/10/07�132067�Ajuste na impressao da dt final de ferias ���
���            �        �------�qdo tem Licensa remunerada.               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
cReplic77:= REPLICATE("-",77)
cReplic22:= REPLICATE("_",22)
cReplic30:= REPLICATE("_",30)
cReplic33:= REPLICATE("_",33)
cReplic35:= REPLICATE("_",35)
cReplic40:= REPLICATE("_",40)

//��������������������������������������������������������������Ŀ
//� Procura No Arquivo de Ferias o Periodo a Ser Listado         �
//����������������������������������������������������������������
If lAchou
	
	dDtBusFer := fDtBusFer() // Busca RH_DTRECIB ou RH_DTITENS
	//��������������������������������������������������������������Ŀ
	//� Se Funcionario tem  dias de Licensa remunerada, entao deve-se�
	//� imprimir somente o period de gozo das ferias (conf.vlr calcu-�
	//� lado.)                                                       �
	//����������������������������������������������������������������
	If SRH->( RH_DIALRE1 + RH_DIALREM) > 0 
		nDiaFeQueb := SRH->(RH_DFERIAS - Int(RH_DFERIAS) ) 
		DaAuxF 	   := SRH->RH_DATAFIM -( SRH->( RH_DIALRE1 + RH_DIALREM ) ) + If(nDiaFeQueb>0 , 1, 0 ) 
    EndIf
	//��������������������������������������������������������������Ŀ
	//� Solicitacao 1o Parcela 13o Salario                           �
	//����������������������������������������������������������������
	If nSol13 == 1
		n1Parc   := 0
		nAbono   := 0
		n13Abono := 0
		
		dbSelectArea( "SRR" )
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[022,1] )
			n1Parc := 1
		Endif
		If n1Parc > 0
			@ nLi+01,001 PSAY "*" + cReplic77 + "*"
			@ nLi+02,001 PSAY "|" + SPACE(18) + STR0001	+SPACE(17)+"|"	//" SOLICITACAO DA 1a PARCELA DO 13o SALARIO "
			@ nLi+03,001 PSAY "|" + SPACE(18) +" ======================================== "+SPACE(17)+"|"
			@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
			If dDtSt13 > SRA->RA_ADMISSA
				@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", "+SUBSTR(DTOC(dDTSt13),1,2)+STR0002+MesExtenso(MONTH(dDTSt13))+STR0002+STR(YEAR(dDTSt13),4)	//" de "###" de "
			Else
				@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", "+SUBSTR(DTOC(SRA->RA_ADMISSAO),1,2)+STR0002+MesExtenso(MONTH(SRA->RA_ADMISSAO))+STR0002+STR(YEAR(SRA->RA_ADMISSA),4)	//" de "###" de "
			Endif
		Endif
		
		If ( nAbono + n13Abono + n1Parc ) > 0
			@ nLi+05,079 PSAY "|"
			@ nLi+06,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+07,001 PSAY "|" + SPACE(07) + STR0003 +SPACE(69) + "|"	//"A"
			@ nLi+08,001 PSAY "|" + SPACE(07) + aInfo[3] + SPACE(30) + "|"
			@ nLi+09,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+10,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+11,001 PSAY "|" + SPACE(07) + STR0004 + SPACE(53) + "|"	//"Prezados Senhores"
			@ nLi+12,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+13,001 PSAY "|" + SPACE(77) + "|"
		Endif
		
		If n1Parc > 0
			@ nLi+14,001 PSAY "|" + SPACE(16) + STR0005 + SPACE(4) + "|"	//"Nos  termos da legislacao vigente, solicito  o  pagamento"
			@ nLi+15,001 PSAY "|" + SPACE(07) + STR0006							//"da  1a  Parcela  do 13o Salario por  ocasiao  do  gozo  de  minhas    |"
			@ nLi+16,001 PSAY "|" + SPACE(07) + STR0007 + SPACE(63) + "|"	//"ferias."
		Endif
		
		If ( nAbono + n13Abono + n1Parc ) > 0
			@ nLi+17,001 PSAY "|" + SPACE(16) + STR0008+SPACE(19)+"|"	//"Solicito apor o seu ciente na copia desta."
			@ nLi+18,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+19,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+20,001 PSAY "|" + SPACE(07) + SRA->RA_NOME+SPACE(02)+STR0009+SRA->RA_FILIAL+" "+SRA->RA_MAT+SPACE(16)+"|"	//"Registro No: "
			cDesc:=DESCcC(SRA->RA_CC,SRA->RA_FILIAL)
			cLinha:= "|" + SPACE(07) + STR0010 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(10)	//"CTPS = "
			cLInha:= cLinha + cDesc + Space(18)+"|"
			@ nLi+21,001 PSAY cLinha
			@ nLi+22,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+23,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+24,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+25,001 PSAY "|" + SPACE(07) + STR0011+SPACE(18)+STR0012+SPACE(17)+"|"	//"Atenciosamente"###"Ciente em ___/___/___"
			@ nLi+26,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+27,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+28,001 PSAY "|" + SPACE(07) + cReplic22+SPACE(10)+cReplic35+space(03)+"|"
			@ nLi+29,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+30,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+30
		Endif
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Solicitacao Abono Pecuniario                                 �
	//����������������������������������������������������������������
	If nSolAb == 1
		n1Parc   := 0
		nAbono   := 0
		n13Abono := 0
		
		dbSelectArea( "SRR" )
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[074,1] )
			nAbono := 1
		Endif
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodFol[079,1] )
			n13Abono := 1
		Endif
		
		If ( nAbono + n13Abono ) > 0
			@ nLi+01,001 PSAY "*" + cReplic77 + "*"
			@ nLi+02,001 PSAY "|" + SPACE(18) +STR0013+SPACE(17)+"|"	//"     SOLICITACAO DO ABONO DE FERIAS       "
			@ nLi+03,001 PSAY "|" + SPACE(18) +"     ==============================       "+SPACE(17)+"|"
		Endif
		
		If ( nAbono + n13Abono ) > 0
			@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
			dDtSolAb:= DataValida(SRH->RH_DBASEAT -20,.F.)
			@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", " +SUBSTR(DTOC(dDtSolAb),1,2)+STR0002+MesExtenso(MONTH(dDtSolAb))+STR0002+STR(YEAR(dDtSolAb),4)	//" de "###" de "
		Endif
		
		If ( nAbono + n13Abono + n1Parc ) > 0
			@ nLi+05,079 PSAY "|"
			@ nLi+06,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+07,001 PSAY "|" + SPACE(07) + STR0003 +SPACE(69) + "|"	//"A"
			@ nLi+08,001 PSAY "|" + SPACE(07) + aInfo[3] + SPACE(30) + "|"
			@ nLi+09,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+10,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+11,001 PSAY "|" + SPACE(07) + STR0014 + SPACE(53) + "|"	//"Prezados Senhores"
			@ nLi+12,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+13,001 PSAY "|" + SPACE(77) + "|"
		Endif
		
		If ( nAbono + n13Abono ) > 0
			@ nLi+14,001 PSAY "|" + SPACE(16) + STR0015 + SPACE(3) + "|"	//"Nos  termos da legislacao vigente, solicito  a  conversao "
			@ nLi+15,001 PSAY "|" + SPACE(07) + STR0016							//"de  1/3  (Hum Terco)  de  minhas  ferias   relativas  ao   periodo    |"
			@ nLi+16,001 PSAY "|" + SPACE(07) + STR0017 + PADR(DTOC(SRH->RH_DATABAS),10)+STR0018+PADR(DTOC(SRH->RH_DBASEAT),10)+STR0019+SPACE(12)+"|"	//"aquisitivo de "###" a "###" em abono pecuniario."
		Endif
		
		If ( nAbono + n13Abono + n1Parc ) > 0
			@ nLi+17,001 PSAY "|" + SPACE(16) + STR0020+SPACE(19)+"|"	//"Solicito apor o seu ciente na copia desta."
			@ nLi+18,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+19,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+20,001 PSAY "|" + SPACE(07) + SRA->RA_NOME+SPACE(02)+STR0021+SRA->RA_FILIAL+" "+SRA->RA_MAT+SPACE(16)+"|"	//"Registro No: "
			cDesc:='' //DESCcC(SRA->RA_CC,SRA->RA_FILIAL)
			cLinha:="|" + SPACE(07) + STR0022 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(10)+cDesc+Space(38)+"|"		//"CTPS = "
			@ nLi+21,001 PSAY cLinha
			@ nLi+22,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+23,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+24,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+25,001 PSAY "|" + SPACE(07) + STR0023+SPACE(18)+STR0024+SPACE(17)+"|"	//"Atenciosamente"###"Ciente em ___/___/___"
			@ nLi+26,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+27,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+28,001 PSAY "|" + SPACE(07) + cReplic22+SPACE(10)+cReplic35+SPACE(03)+"|"
			@ nLi+29,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+30,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+30
		Endif
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Aviso De Ferias                                              �
	//����������������������������������������������������������������
	If nAviso == 1
		If nLi > 35
			nLi := 1
		Endif
		
		@ nLi+01,001 PSAY "*" + cReplic77 + "*"
		@ nLi+02,001 PSAY "|" + SPACE(30) + STR0025	;@ nLi+02,079 PSAY "|"	//" AVISO DE FERIAS "
		@ nLi+03,001 PSAY "|" + SPACE(30) + Replicate("=",Len(STR0025)+1);@ nLi+03,079 PSAY "|"
		@ nLi+04,001 PSAY "|";@ nLi+04,079 PSAY "|"
		@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", "+SUBSTR(DTOC(SRH->RH_DTAVISO),1,2)+STR0002+MesExtenso(MONTH(SRH->RH_DTAVISO))+STR0002+STR(YEAR(SRH->RH_DTAVISO),4)	//" de "###" de "
		@ nLi+05,079 PSAY "|"
		@ nLi+06,001 PSAY "|"; @ nLi+06,079 PSAY "|"                                     
		
		If cPaisLoc <> "ARG"
			@ nLi+07,001 PSAY "|" + SPACE(07) + STR0026	; @ nLi+07,079 PSAY "|"	//"A(O) SR(A)"
		Else
			@ nLi+07,001 PSAY "|" + SPACE(07) + STR0115	; @ nLi+07,079 PSAY "|"	//"SR(A)"
		EndIf
		
		@ nLi+08,001 PSAY "|" + SPACE(77) + "|"
		@ nLi+09,001 PSAY "|" + SPACE(07) + Left(SRA->RA_NOME,30);@ nLi+09,079 PSAY "|"
		cDesc := '' //DescCc(SRA->RA_CC,SRA->RA_FILIAL)
		
		If cPaisLoc <> "ARG"
			cLinha:= "|" + SPACE(07) + STR0027 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(8)	//"CTPS = "###"DEPTO: "
		Else
			cLinha:= "|" + SPACE(07) + STR0116 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(8)	//"CTPS = "###"DEPTO: "
		EndIf
		
		cLInha:= cLinha+cDesc
		@ nLi+10,001 PSAY cLinha;@ nLi+10,079 PSAY "|"
		@ nLi+11,001 PSAY "|"; @ nLi+11,079 PSAY "|"
		@ nLi+12,001 PSAY "|"; @ nLi+12,079 PSAY "|"
		@ nLi+13,001 PSAY "|" + SPACE(16) + STR0029 ; @ nLi+13,079 PSAY "|"	//"Nos  termos da legislacao  vigente,  suas  ferias   serao"
		@ nLi+14,001 PSAY "|" + SPACE(07) + STR0030 ; @ nLi+14,079 PSAY "|"	//"concedidas conforme o demonstrativo abaixo:"
		@ nLi+15,001 PSAY "|" ; @ nLi+15,079 PSAY "|"
		@ nLi+16,001 PSAY "|    " + STR0031+SPACE(08)+STR0032+SPACE(06)+STR0033; @ nLi+16,079 PSAY "|"	//"Periodo Aquisitivo:"###"Periodo de Gozo:"###"Retorno ao Trabalho:"
		@ nLi+17,001 PSAY "|  " + PADR(DTOC(SRH->RH_DATABAS),10)+STR0034+PADR(DTOC(SRH->RH_DBASEAT),10)+SPACE(02)+PADR(DTOC(DAAUXI),10)+STR0034+PADR(DTOC(DAAUXF),10)+SPACE(8)+PADR(DTOC(DAAUXF+1),10); @ nLi+17,079 PSAY "|"	//" A "###" A "
		
		@ nLi+18,001 PSAY "|"; @ nLi+18,079 PSAY "|"
		
		If cPaisLoc <> "ARG"
			//@ nLi+19,001 PSAY "|" + SPACE(16) + STR0035; @ nLi+19,079 PSAY "|"	//"A remuneracao correspondente as ferias e, se for o  caso,"
			//@ nLi+20,001 PSAY "|" + SPACE(07) + STR0036							//"ao abono pecuniario e ao adiantamento da  gratificacao  de  natal,    |"
			//@ nLi+21,001 PSAY "|" + SPACE(07) + STR0037 +PADR(DTOC(SRH->RH_DTRECIB),10)+"."; @ nLi+21,079 PSAY "|"	//"encontra-se no  caixa  e  podera ser recebida  no  dia "
			@ nLi+19,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+20,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+21,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+22,001 PSAY "|" + SPACE(16) + STR0038 ; @ nLi+22,079 PSAY "|"	//"Solicitamos  apresentar  a  sua  carteira  de trabalho  e"
			@ nLi+23,001 PSAY "|" + SPACE(07) + STR0039	  //; @ nLi+23,079 PSAY "|"						//"previdencia social ao depto pessoal para as anotacoes necessarias.   
        Else
        	@ nLi+19,001 PSAY "|" + SPACE(16) + STR0117; @ nLi+19,079 PSAY "|"	
			@ nLi+20,001 PSAY "|" + SPACE(07) + STR0118							
			@ nLi+21,001 PSAY "|" + SPACE(07) + STR0119 +PADR(DTOC(SRH->RH_DTRECIB),10)+"."; @ nLi+21,079 PSAY "|"
			@ nLi+22,001 PSAY "|" + SPACE(16) + STR0120 ; @ nLi+22,079 PSAY "|"	
			@ nLi+23,001 PSAY "|" + SPACE(07) + STR0121	; @ nLi+23,079 PSAY "|"		
		EndIf	
        
		@ nLi+24,001 PSAY "|" ; @ nLi+24,079 PSAY "|"
		@ nLi+25,001 PSAY "|" ; @ nLi+25,079 PSAY "|"
		@ nLi+26,001 PSAY "|" ; @ nLi+26,079 PSAY "|"
		@ nLi+27,001 PSAY "|" + SPACE(02) + cReplic40+SPACE(01)+cReplic33+SPACE(01); @ nLi+27,079 PSAY "|"
		@ nLi+28,001 PSAY "|" + SPACE(02) + SubStr(aInfo[3]+Space(40),1,40)+SPACE(05)+Left(SRA->RA_NOME,30); @ nLi+28,079 PSAY "|"
		@ nLi+29,001 PSAY "|" ; @ nLi+29,079 PSAY "|"
		@ nLi+30,001 PSAY "*" + cReplic77 + "*"
		nLi:=nLi+30
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Recibo De Abono                                              �
	//����������������������������������������������������������������
	If nRecAb == 1
		nValab13 := 0.00
		nValAb   := 0.00
		nVal13o  := 0.00
		nVal13a  := 0.00
		nValnLiq := 0.00
		cRet1    := ''
		cRet2    := ''
		
		If nLi > 35
			nLi := 1
		Endif
		
		dbSelectArea( "SRR" )
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + cPdAb )
			nValAb := SRR->RR_VALOR
		Endif
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + cPd13Ab )
			nValAb13 := SRR->RR_VALOR
		Endif
		If ( nValAb + nValAb13 ) > 0
			@ nLi+01,001 PSAY "*" + cReplic77 + "*"
			@ nLi+02,001 PSAY "|" + SPACE(25) +STR0040+SPACE(24)+"|"			//" RECIBO DE ABONO DE FERIAS  "
			@ nLi+03,001 PSAY "|" + SPACE(25) +" =========================  "+SPACE(24)+"|"
		Endif
		
		If ( nValAb + nValAb13 + nVal13o ) > 0
			@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+05,001 PSAY "|" + SPACE(07) + Sra->RA_NOME+SPACE(40) + "|"
			cDesc:=""//DescCc(SRA->RA_CC,SRA->RA_FILIAL)
			cLinha:="|" + SPACE(07) + STR0041 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(8)+STR0042+cDesc+SPACE(13)+"|"	//"CTPS = "###"DEPTO: "
			@ nLi+06,001 PSAY cLinha
			@ nLi+07,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+08,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+09,001 PSAY "|" + SPACE(27) + STR0043 + SPACE(25) + "|"	//"D E M O N S T R A T I V O"
			@ nLi+10,001 PSAY "|" + SPACE(77) + "|"
		Endif
		
		If ( nValAb + nValAb13 ) > 0
			@ nLi+11,001 PSAY STR0044	//"|  Periodo de ferias em Abono Pecuniario      Periodo de gozo de ferias       |"
			
			If !empty(SRH->RH_ABOPEC)
				cAbono 	:= SRH->RH_ABOPEC
			Else
				cAbono	:= GetMv("MV_ABOPEC")                  //-- Define se o periodo do abono pecuniario ser� considerado antes ou depois do gozo de ferias 
				cAbono 	:= if(cAbono=="S","1","2")    		   //-- Abono antes
			EndIF
			If cAbono == "1"
				@ nLi+12,001 PSAY "|"+Space(7)+PADR(DtoC(SRH->RH_DATAINI-SRH->RH_DABONPEC),10)+STR0045+Dtoc(SRH->RH_DATAINI-1)                        +Space(15)+PADR(Dtoc(SRH->RH_DATAINI),10)+STR0045+PADR(DtoC(DaAuxF),10)+Space(7)+"|"	//"  a  "###"  a  "
			Else
				@ nLi+12,001 PSAY "|"+Space(7)+PADR(DtoC( DaAuxF + 1            ),10)+STR0045+PADR(Dtoc(DaAuxF+SRH->RH_DABONPEC),10)+Space(15)+PADR(Dtoc(SRH->RH_DATAINI),10)+STR0045+PADR(DtoC(DaAuxF),10)+Space(7)+"|"	//"  a  "###"  a  "
			Endif
			@ nLi+13,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+14,001 PSAY "|" + SPACE(07) + STR0046+STR(SRH->RH_DABONPE,3)+STR0047+TRANSFORM(nValAb,"@E 999,999,999.99")+SPACE(28)+"|"	//"Abono ("###") Dias :          "
			@ nLi+15,001 PSAY "|" + SPACE(07) + STR0048+TRANSFORM(nValAb13,"@E 999,999,999.99")+SPACE(28)+"|"											//"Acrescimo 1/3 :             "
			@ nLi+16,001 PSAY "|" + SPACE(07) + STR0049+TRANSFORM(nValAb13+nValab ,"@E 999,999,999.99")+SPACE(28)+"|"								//"Liquido :                   "
			nLi:=nLi+3
			nValnLiq := nValAb13+nValab
		Endif
		
		If ( nValAb + nValAb13 + nVal13o ) > 0
			@ nLi+14,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+15,001 PSAY "|" + SPACE(77) + "|"
			cExt := Extenso(nValnLiq,.F.,1)
			SepExt(cExt,13,70,@cRet1,@cRet2)
			@ nLi+16,001 PSAY "|" + SPACE(16) + STR0050 + aInfo[3]		//"Recebi de "
			@ nLi+16,079 PSAY '|'
			@ nLi+17,001 PSAY "|" +Space(07)+ STR0051+TRANSFORM(nValnLiq,"@E 999,999,999.99") + "  ("+cRet1+SPACE(9)+" |"	//" a importancia Liquida de  R$ "
			@ nLi+18,001 PSAY "|" +SPACE(08)+cRet2+".****)"
			@ nLi+18,079 PSAY "|"
			@ nLi+19,001 PSAY "|" + SPACE(07) + STR0052		//" conforme demonstrativo acima, referente ao abono pecuniario."
			@ nLi+19,079 PSAY "|"
			@ nLi+20,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+21,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+22,001 PSAY "| " + ALLTRIM(aInfo[5])+", "+STRZERO(DAY(SRH->RH_DTRECIB),2)+STR0053+MesExtenso(MONTH(SRH->RH_DTRECIB))+STR0053+STR(YEAR(SRH->RH_DTRECIB),4)	//" de "###" de "
			@ nLi+22,079 PSAY "|"
			@ nLi+23,001 PSAY "|" + SPACE(46)+cReplic30+" |"
			@ nLi+24,001 PSAY "|" + SPACE(46) + SRA->RA_NOME     +" |"
			@ nLi+25,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+26,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+26
		Endif
		
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Recibo De 13o Salario                                        �
	//����������������������������������������������������������������
	If nRec13 == 1
		nValab13 := 0.00
		nValAb   := 0.00
		nVal13o  := 0.00
		nPen13o  := 0.00
		nVal13a  := 0.00
		nValnLiq := 0.00
		cRet1    := ''
		cRet2    := ''
		
		If nLi > 35
			nLi := 1
		Endif
		
		dbSelectArea( "SRR" )
		If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + cPd13o )
			nVal13o := SRR->RR_VALOR
		Endif
		
		For nCntCd := 1 To Len(aCodBenef)
			If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + "F" + Dtos(dDtBusFer) + aCodBenef[nCntCd,1] )
				nPen13o += SRR->RR_VALOR
			EndIf
		Next nCntCd
		
		If nVal13o > 0
			@ nLi+01,001 PSAY "*" + cReplic77 + "*"
			@ nLi+02,001 PSAY "|" + SPACE(20) + STR0054+SPACE(19)+"|"	//" RECIBO DA 1a. PARCELA DO 13o SALARIO "
			@ nLi+03,001 PSAY "|" + SPACE(20) +" ==================================== "+SPACE(19)+"|"
		Endif
		
		If ( nValAb + nValAb13 + nVal13o ) > 0
			@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+05,001 PSAY "|" + SPACE(07) + Sra->RA_NOME+SPACE(40) + "|"
			cDesc:=""//DescCc(SRA->RA_CC,SRA->RA_FILIAL)
			cLinha:="|" + SPACE(07) + STR0056 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(8)+STR0057+cDesc+SPACE(13)+"|"	//"CTPS = "###"DEPTO: "
			@ nLi+06,001 PSAY cLinha
			@ nLi+07,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+08,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+09,001 PSAY "|" + SPACE(27) + STR0058 + SPACE(25) + "|"	//"D E M O N S T R A T I V O"
			@ nLi+10,001 PSAY "|" + SPACE(77) + "|"
		Endif
		
		If nVal13o > 0
			@ nLi+11,001 PSAY "|" + SPACE(07) + STR0059+TRANSFORM(nVal13o,"@E 999,999,999.99")+SPACE(28)+"|"	//"1a Parcela do 13o Salario : "
			@ nLi+12,001 PSAY "|" + SPACE(07) + STR0060+TRANSFORM(nVal13a,"@E 999,999,999.99")+SPACE(28)+"|"	//"Adiantamento :              "
			If nPen13o > 0
				@ nLi+13,001 PSAY "|" + SPACE(07) + STR0114+TRANSFORM(nPen13o,"@E 999,999,999.99")+SPACE(28)+"|"	//"Pensao :"
			EndIf
			@ nLi+If(nPen13o>0,14,13),001 PSAY "|" + SPACE(07) + STR0061+TRANSFORM(nVal13o-nVal13a-nPen13o,"@E 999,999,999.99")+SPACE(28)+"|"	//"Liquido :                   "
			nValnLiq := nVal13o-nVal13a-nPen13o
		Endif
		
		If ( nValAb + nValAb13 + nVal13o ) > 0
			If nPen13o == 0
				@ nLi+14,001 PSAY "|" + SPACE(77) + "|"
			EndIf
			@ nLi+15,001 PSAY "|" + SPACE(77) + "|"
			cExt := Extenso(nValnLiq,.F.,1)
			SepExt(cExt,13,70,@cRet1,@cRet2)
			@ nLi+16,001 PSAY "|" + SPACE(16) + STR0062 + aInfo[3]	//"Recebi de "
			@ nLi+16,079 PSAY '|'
			@ nLi+17,001 PSAY "|" +Space(07)+ STR0063+TRANSFORM(nValnLiq,"@E 999,999,999.99") + "  ("+cRet1+SPACE(9)+" |"		//" a importancia Liquida de  R$ "
			@ nLi+18,001 PSAY "|" +SPACE(08)+cRet2+".****)" 
			@ nLi+18,079 PSAY "|"
			@ nLi+19,001 PSAY "|" + SPACE(07) + STR0064	//" conforme demonstrativo acima, referente a 1a parcela do 13o salario."
			@ nLi+19,079 PSAY "|"
			@ nLi+20,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+21,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+22,001 PSAY "| " + ALLTRIM(aInfo[5])+", "+STRZERO(DAY(SRH->RH_DTRECIB),2)+STR0065+MesExtenso(MONTH(SRH->RH_DTRECIB))+STR0066+STR(YEAR(SRH->RH_DTRECIB),4)	//" de "###" de "
			@ nLi+22,079 PSAY "|"
			@ nLi+23,001 PSAY "|" + SPACE(46)+cReplic30+" |"
			@ nLi+24,001 PSAY "|" + SPACE(46) + SRA->RA_NOME     +" |"
			@ nLi+25,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+26,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+26
		Endif
	Endif
	
	//��������������������������������������������������������������Ŀ
	//� Recibo De Ferias                                             �
	//����������������������������������������������������������������
	If nRecib == 1
		
		aPdv  := {}
		aPdd  := {}
		cRet1 := ""
		cRet2 := ""
		nLi   := 1
		
		//��������������������������������������������������������������Ŀ
		//� Posiciona Arq. SRR Para Guardar na Matriz as Verbas De Ferias�
		//����������������������������������������������������������������
		dbSelectArea("SRR")
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "F" )
			While ! Eof() .And. SRA->RA_FIlIAL + SRA->RA_MAT + "F" == SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3
				//��������������������������������������������������������������Ŀ
				//� Verifica Verba For Abono Ou 13o Esta $ Na Variavel Nao Lista �
				//����������������������������������������������������������������
				If SRR->RR_PD #cPdAb .And. SRR->RR_PD # cPd13Ab .And. SRR->RR_PD # cPd13o .And. SRR->RR_PD # aCodFol[102,1] .And.;
					Ascan(aCodBenef, { |x| x[1] == SRR->RR_PD }) == 0
					If SRR->RR_DATA == dDtBusFer
						If PosSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
							Aadd(aPdv , { SRR->RR_PD , SRR->RR_VALOR })
						ElseIf PosSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
							Aadd(aPdd , { SRR->RR_PD , SRR->RR_VALOR })
						Endif
					Endif
				Endif
				dbSkip()
			Enddo
			
			PER_AQ_I := STRZERO(DAY(SRH->RH_DATABASE),2)+STR0067+MesExtenso(MONTH(SRH->RH_DATABAS))+STR0067+STR(YEAR(SRH->RH_DATABAS),4)	//" De "###" De "
			PER_AQ_F := STRZERO(DAY(SRH->RH_DBASEATE),2)+STR0067+MesExtenso(MONTH(SRH->RH_DBASEAT))+STR0067+STR(YEAR(SRH->RH_DBASEAT),4)	//" De "###" De "
			PER_GO_I := STR(DAY(DAAUXI),2)+STR0067+MesExtenso(MONTH(DAAUXI))+STR0067+STR(YEAR(DAAUXI),4)		//" De "###" De "
			PER_GO_F := STR(DAY(DAAUXF),2)+STR0067+MesExtenso(MONTH(DAAUXF))+STR0067+STR(YEAR(DAAUXF),4)		//" De "###" De "
			
			nLi:=nLi+1
			@ nLi,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+1
			@ nLi,001 PSAY "|"
			@ nLi,030 PSAY STR0068		//" RECIBO DE FERIAS "
			@ nLi,079 PSAY "|"
			nLi:=nLi+1
			@ nLi,001 PSAY "|"
			@ nLi,030 PSAY " ================ "
			@ nLi,079 PSAY "|"
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(77) + "|"
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(77) + "|"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0069+Left(SRA->RA_NOME,30)+SPACE(020)+'|'			//"| Nome do Empregado.......: "
			nLi:=nLi+1    
			
			If cPaisLoc <> "ARG"
				@ nLi,001 PSAY STR0070 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+;		//"| Carteira Trabalho.......: "
				SPACE(04)+STR0071+SRA->RA_FILIAL+" "+SRA->RA_MAT+Space(12)+ "|"	//"Registro: "
			Else
				@ nLi,001 PSAY "| " + STR0071+SRA->RA_FILIAL+" "+SRA->RA_MAT+Space(57)+ "|"	//"Registro: "
			EndIf
					
			nLi:=nLi+1
			@ nLi,001 PSAY STR0072+PER_AQ_I+STR0073+PER_AQ_F	//"| Periodo Aquisitivo......: "###" A "
			@ nLi,079 PSAY "|"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0074+PER_GO_I+STR0073+PER_GO_F	//"| Periodo Gozo das Ferias.: "###" A "
			@ nLi,079 PSAY "|"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0075 +TRANSFORM(SRH->RH_SALMES,"@E 999,999,999.99")+;			//"| Salario Mes ............: "
			SPACE(05)+STR0076+TRANSFORM(SRH->RH_SALDIA,"@E 9,999,999.99")+SPACE(02)+"|"	//"Valor Dia......: "
			nLi:=nLi+1
			@ nLi,001 PSAY STR0077 +TRANSFORM(SRH->RH_SALHRS,"@E 999,999,999.99")+;	//"| Salario Hora ...........: "
			Space(05)+STR0078 +Transform(SRH->RH_DFERIAS,"99.9")+Space(10)+"|"		//"Dias de Ferias.: "
			nLi:=nLi+1
			@ nLi,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0079	//"|          P R O V E N T O S           |           D E S C O N T O S          |"
			nLi:=nLi+1
			@ nLi,001 PSAY "|-----------------------------------------------------------------------------|"
			nLi:=nLi+1
			
			//��������������������������������������������������������������Ŀ
			//� Impressao das Verbas                                         �
			//����������������������������������������������������������������
			nMaximo := MAX(Len(aPDV),Len(aPdd))
			For nConta :=1 TO nMaximo
				If nConta > Len(aPdv)
					DET:= Space(37)+"| "
				Else
					cDesc:=Left(DescPd(aPdv[nConta,1],SRA->RA_FILIAL),15)
					DET:= aPdv[nConta,1]+" "+cDesc+"   "+Transform(aPdv[nConta,2],'@E 999,999,999.99')+" | "
				Endif
				If nConta > Len(aPdd)
					DET:=DET+Space(37)+"|"
				Else
					cDesc:=Left(DescPd(aPdd[nConta,1],SRA->RA_FILIAL),15)
					DET:= DET + aPdd[nConta,1]+" "+cDesc+"   "+Transform(aPdd[nConta,2],'@E 999,999,999.99')+" |"
				Endif
				@ nLi,1 PSAY '| '+Det
				nLi:=nLi+1
				
			Next
			
			nTvp := 0.00
			nTvd := 0.00
			AeVal(aPdv,{ |X| nTVP:= nTVP + X[2]})    // Acumula Valores
			AeVal(aPdd,{ |X| nTVD:= nTVD + X[2]})
			
			@ nLi,001 PSAY "|                                      |                                      |"
			nLi:=nLi+1
			@ nLi,001 PSAY  STR0080+Trans(nTvp,"@E 999,999,999.99")+" "+;	//"| Total Proventos......:"
			STR0081+Trans(nTvd,"@E 999,999,999.99")+" |"							//"| Total Descontos......:"
			//                "| L i q u i d o .." +Trans(nTvp-nTvd,"@E 999,999,999.99")+" | "
			nLi:=nLi+1
			@ nLi,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(02) + STR0082 + SubStr(aInfo[3]+Space(40),1,40) + Space(23) + " |"	//"Recebi da: "
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(02) + STR0083 + SubStr(aInfo[4]+Space(30),1,30)+STR0084+SubStr(aInfo[7]+Space(8),1,8)+Space(11)+"|"	//"Estabelecida a "###"   -  Cep: "
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(02) + STR0085 + SubStr(aInfo[5]+Space(25),1,25)+STR0086+aInfo[6] + Space(27)+"|"	//"Cidade: "###"   -     UF: "
			cExt   := EXTENSO(nTvp-nTvd,.F.,1)
			
			SepExt(cExt,52,77,@cRet1,@cRet2)
			
			nLi:=nLi+1
			@ nLi,001 PSAY STR0087 + SubStr(aInfo[5]+Space(20),1,20)+", "+StrZero(Day(SRH->RH_DTRECIB),2)+STR0088+SubStr(MesExtenso(Month(SRH->RH_DTRECIBO))+Space(9),1,9)+STR0089+STR(YEAR(SRH->RH_DTRECIBO),4)+STR0090	//"|  em "###"  de  "###"  de  "###" a importancia de      |"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0091 + TRANSFORM(nTvp-nTvd,"@E 999,999,999.99")+" ("+cRet1	//"|  R$ "
			If Len(cRet2) > 0
				@ nLi,79 PSAY "|"
			Else
				@ nLi,78 PSAY ")|"
			Endif
			
			If Len(cRet2) > 0
				nLi:=nLi+1
				@ nLi,001 PSAY "|  "+cRet2+".****)"
				@ nLi,79  PSAY "|"
			Endif
			
			nLi:=nLi+1
			@ nLi,001 PSAY STR0092		//"|  que me paga adiantadamente por motivo das minhas ferias regulamentares ,   |"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0093		//"|  ora  concedidas  que  vou  gozar de  acordo com a  descricao acima, tudo   |"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0094		//"|  conforme o aviso que recebi em tempo, ao qual dei meu ciente.              |"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0095		//"|  Para clareza e documento, firmo o presente recibo, dando a firma plena e   |"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0096		//"|  geral quitacao.                                                            |"
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(77) + "|"
			nLi:=nLi+1
			If nDtRec == 1
				@ nLi,001 PSAY "|  "+ALLTRIM(aInfo[5])+", "+StrZero(Day(SRH->RH_DTRECIB),2)+STR0097+MesExtenso(MONTH(SRH->RH_DTRECIB))+STR0097+STRZERO(YEAR(SRH->RH_DTRECIB),4)	//" de "###" de "
				@ nLi,79  PSAY "|"
			Else
				@ nLi,001 PSAY "|  "
				@ nLi,79  PSAY "|"
			Endif
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(77) + "|"
			nLi:=nLi+1
			@ nLi,001 PSAY STR0098	//"|                         Assinatura do Empregado:__________________________  |"
			nLi:=nLi+1
			@ nLi,001 PSAY "|" + SPACE(077) + "|"
			nLi:=nLi+1
			@ nLi,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+1
		Endif
		nLi := 1
	Endif
	
Else  //--> Impressao do Aviso de Ferias e/ou Sol.Abono e/ou Sol. 1.Parc. 13. sem ter calculado.
	If M->RH_DFERIAS > 0
		If nLi > 35
			nLi := 1
		Endif
	
		//��������������������������������������������������������������Ŀ
		//� Aviso de Ferias                                              �
		//����������������������������������������������������������������
		If nAviso == 1 // Imprimi Aviso de Ferias, caso parametro "Imprimi Aviso" esteja como Sim
			If nLi > 35
				nLi := 1
			Endif
			
			@ nLi+01,001 PSAY "*" + cReplic77 + "*"
			@ nLi+02,001 PSAY "|" + SPACE(30) + STR0099 + SPACE(30)+"|"	//" AVISO DE FERIAS "
			@ nLi+03,001 PSAY "|" + SPACE(30) +" =============== "+SPACE(30)+"|"
			@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", "+SUBSTR(DTOC(M->RH_DTAVISO),1,2)+STR0097+MesExtenso(MONTH(M->RH_DTAVISO))+STR0097+str(year(m->rh_dtaviso),4)	//" DE "###" DE "
			@ nLi+05,079 PSAY "|"
			@ nLi+06,001 PSAY "|" + SPACE(77)+ "|"
			@ nLi+07,001 PSAY "|" + SPACE(07)+ STR0100 +SPACE(60) + "|"	//"A(O) SR(A)"
			@ nLi+08,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+09,001 PSAY "|" + SPACE(07) + Left(SRA->RA_NOME,30) + Space(39) + " |"
			cDesc := DescCc(SRA->RA_CC,SRA->RA_FILIAL)
			cLinha:= "|" + SPACE(07) + STR0101 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(8)+STR0102	//"CTPS = "###"DEPTO: "
			cLinha:= cLinha+cDesc+SPACE(13)+"|"
			@ nLi+10,001 PSAY cLinha
			@ nLi+11,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+12,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+13,001 PSAY "|" + SPACE(16) + STR0103+SPACE(04)+"|"	//"Nos  termos da legislacao  vigente,  suas  ferias   serao"
			@ nLi+14,001 PSAY "|" + SPACE(07) + STR0104+SPACE(27)+"|"	//"concedidas conforme o demonstrativo abaixo:"
			@ nLi+15,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+16,001 PSAY "|" + SPACE(06) + STR0105+SPACE(07)+STR0106+SPACE(06)+STR0107+SPACE(03)+"|"	//"Periodo Aquisitivo:"###"Periodo de Gozo:"###"Retorno ao Trabalho:"
			@ nLi+17,001 PSAY "|" + SPACE(04) + PADR(DTOC(M->RH_DATABAS),10)+STR0108+PADR(DTOC(M->RH_DBASEAT),10)+SPACE(02)+PADR(DTOC(DAAUXI),10)+STR0108+PADR(DTOC(DAAUXF),10)+SPACE(6)+PADR(DTOC(DAAUXF+1),10)+SPACE(09)+"|"	//" A "###" A "
			
			@ nLi+18,001 PSAY "|" + SPACE(77) + "|"
//			@ nLi+19,001 PSAY "|" + SPACE(16) + STR0109 + SPACE(4) + "|"	//"A remuneracao correspondente as ferias e, se for o  caso,"
//			@ nLi+20,001 PSAY "|" + SPACE(07) + STR0110							//"ao abono pecuniario e ao adiantamento da  gratificacao  de  natal,    |"
//			@ nLi+21,001 PSAY "|" + SPACE(07) + STR0111 + PADR(DTOC(M->RH_DTRECIB),10)+"."+SPACE(4)+"|"	//"encontra-se no  caixa  e  podera ser recebida  no  dia "
			@ nLi+22,001 PSAY "|" + SPACE(16) + STR0112 + SPACE(4) + "|"	//"Solicitamos  apresentar  a  sua  carteira  de trabalho  e"
			@ nLi+23,001 PSAY "|" + SPACE(07) + STR0113							//"previdencia social ao depto pessoal para as anotacoes necessarias.    |"
			@ nLi+24,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+25,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+26,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+27,001 PSAY "|" + SPACE(02) + cReplic40+SPACE(01)+cReplic33+SPACE(01)+"|"
			@ nLi+28,001 PSAY "|" + SPACE(02) + SubStr(aInfo[3]+Space(40),1,40)+SPACE(05)+Left(SRA->RA_NOME,30)+"|"
			@ nLi+29,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+30,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+30
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Solicitacao 1o Parcela 13o Salario                           �
		//����������������������������������������������������������������
		If nSol13 == 1  // Imprimi Sol.1.Parc.13., caso parametro "Sol. 1.Parc.13.Sal" esteja como Sim
			If nLi > 35
				nLi := 1
			Endif
			@ nLi+01,001 PSAY "*" + cReplic77 + "*"
			@ nLi+02,001 PSAY "|" + SPACE(18) + STR0001	+SPACE(17)+"|"	//" SOLICITACAO DA 1a PARCELA DO 13o SALARIO "
			@ nLi+03,001 PSAY "|" + SPACE(18) +" ======================================== "+SPACE(17)+"|"
			@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
			If dDtSt13 > SRA->RA_ADMISSA
				@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", "+SUBSTR(DTOC(dDTSt13),1,2)+STR0002+MesExtenso(MONTH(dDTSt13))+STR0002+STR(YEAR(dDTSt13),4)	//" de "###" de "
			Else
				@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", "+SUBSTR(DTOC(SRA->RA_ADMISSAO),1,2)+STR0002+MesExtenso(MONTH(SRA->RA_ADMISSAO))+STR0002+STR(YEAR(SRA->RA_ADMISSA),4)	//" de "###" de "
			Endif
			
			@ nLi+05,079 PSAY "|"
			@ nLi+06,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+07,001 PSAY "|" + SPACE(07) + STR0003 +SPACE(69) + "|"	//"A"
			@ nLi+08,001 PSAY "|" + SPACE(07) + aInfo[3] + SPACE(30) + "|"
			@ nLi+09,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+10,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+11,001 PSAY "|" + SPACE(07) + STR0004 + SPACE(53) + "|"	//"Prezados Senhores"
			@ nLi+12,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+13,001 PSAY "|" + SPACE(77) + "|"
			
			@ nLi+14,001 PSAY "|" + SPACE(16) + STR0005 + SPACE(4) + "|"	//"Nos  termos da legislacao vigente, solicito  o  pagamento"
			@ nLi+15,001 PSAY "|" + SPACE(07) + STR0006							//"da  1a  Parcela  do 13o Salario por  ocasiao  do  gozo  de  minhas    |"
			@ nLi+16,001 PSAY "|" + SPACE(07) + STR0007 + SPACE(63) + "|"	//"ferias."
			
			@ nLi+17,001 PSAY "|" + SPACE(16) + STR0008+SPACE(19)+"|"	//"Solicito apor o seu ciente na copia desta."
			@ nLi+18,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+19,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+20,001 PSAY "|" + SPACE(07) + SRA->RA_NOME+SPACE(02)+STR0009+SRA->RA_FILIAL+" "+SRA->RA_MAT+SPACE(16)+"|"	//"Registro No: "
			cDesc:=DESCcC(SRA->RA_CC,SRA->RA_FILIAL)
			cLinha:= "|" + SPACE(07) + STR0010 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(10)	//"CTPS = "
			cLInha:= cLinha + cDesc + Space(18)+"|"
			@ nLi+21,001 PSAY cLinha
			@ nLi+22,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+23,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+24,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+25,001 PSAY "|" + SPACE(07) + STR0011+SPACE(18)+STR0012+SPACE(17)+"|"	//"Atenciosamente"###"Ciente em ___/___/___"
			@ nLi+26,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+27,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+28,001 PSAY "|" + SPACE(07) + cReplic22+SPACE(10)+cReplic35+space(03)+"|"
			@ nLi+29,001 PSAY "|" + SPACE(77) + "|"
			@ nLi+30,001 PSAY "*" + cReplic77 + "*"
			nLi:=nLi+30
			
		Endif
	
		//��������������������������������������������������������������Ŀ
		//� Solicitacao Abono Pecuniario                                 �
		//����������������������������������������������������������������
		If nSolAb == 1 // Imprimi Sol.Abono, caso parametro "Sol. Abono Pecun." esteja como Sim
		
			If  M->RF_TEMABPE == "S"  // Ignora funcionarios que nao tem Abono Pecuniario
				
				If nLi > 35
					nLi := 1
				Endif
				
				@ nLi+01,001 PSAY "*" + cReplic77 + "*"
				@ nLi+02,001 PSAY "|" + SPACE(18) +STR0013+SPACE(17)+"|"	//"     SOLICITACAO DO ABONO DE FERIAS       "
				@ nLi+03,001 PSAY "|" + SPACE(18) +"     ==============================       "+SPACE(17)+"|"
				
				@ nLi+04,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+05,001 PSAY "|" + SPACE(28+(20-LEN(ALLTRIM(aInfo[5]))))+ALLTRIM(aInfo[5])+", " +SUBSTR(DTOC(M->RH_DBASEAT-20),1,2)+STR0002+MesExtenso(MONTH(M->RH_DBASEAT-20))+STR0002+STR(YEAR(M->RH_DBASEAT-20),4)	//" de "###" de "
				
				@ nLi+05,079 PSAY "|"
				@ nLi+06,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+07,001 PSAY "|" + SPACE(07) + STR0003 +SPACE(69) + "|"	//"A"
				@ nLi+08,001 PSAY "|" + SPACE(07) + aInfo[3] + SPACE(30) + "|"
				@ nLi+09,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+10,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+11,001 PSAY "|" + SPACE(07) + STR0014 + SPACE(53) + "|"	//"Prezados Senhores"
				@ nLi+12,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+13,001 PSAY "|" + SPACE(77) + "|"
				
				@ nLi+14,001 PSAY "|" + SPACE(16) + STR0015 + SPACE(3) + "|"	//"Nos  termos da legislacao vigente, solicito  a  conversao "
				@ nLi+15,001 PSAY "|" + SPACE(07) + STR0016							//"de  1/3  (Hum Terco)  de  minhas  ferias   relativas  ao   periodo    |"
				@ nLi+16,001 PSAY "|" + SPACE(07) + STR0017 + PADR(DTOC(M->RH_DATABAS),10)+STR0018+PADR(DTOC(M->RH_DBASEAT),10)+STR0019+SPACE(12)+"|"	//"aquisitivo de "###" a "###" em abono pecuniario."
				
				@ nLi+17,001 PSAY "|" + SPACE(16) + STR0020+SPACE(19)+"|"	//"Solicito apor o seu ciente na copia desta."
				@ nLi+18,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+19,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+20,001 PSAY "|" + SPACE(07) + SRA->RA_NOME+SPACE(02)+STR0021+SRA->RA_FILIAL+" "+SRA->RA_MAT+SPACE(16)+"|"	//"Registro No: "
				//cDesc:=DESCcC(SRA->RA_CC,SRA->RA_FILIAL)
				cDesc := space(1)
				cLinha:="|" + SPACE(07) + STR0022 + SRA->RA_NUMCP+" - "+SRA->RA_SERCP+SPACE(10)+cDesc+Space(18)+"|"		//"CTPS = "
				@ nLi+21,001 PSAY cLinha
				@ nLi+22,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+23,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+24,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+25,001 PSAY "|" + SPACE(07) + STR0023+SPACE(18)+STR0024+SPACE(17)+"|"	//"Atenciosamente"###"Ciente em ___/___/___"
				@ nLi+26,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+27,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+28,001 PSAY "|" + SPACE(07) + cReplic22+SPACE(10)+cReplic35+SPACE(03)+"|"
				@ nLi+29,001 PSAY "|" + SPACE(77) + "|"
				@ nLi+30,001 PSAY "*" + cReplic77 + "*"
				nLi:=nLi+30
			Endif
		Endif
	Endif
Endif

Return(nil)
