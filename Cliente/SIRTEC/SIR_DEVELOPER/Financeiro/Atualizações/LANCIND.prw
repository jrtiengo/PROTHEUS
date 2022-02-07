#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LANCIND   � Autor � AP6 IDE            � Data �  12/12/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function LANCIND


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Lan�amentos Individuais"
Local cPict          := ""
Local titulo         := "Lan�amentos Individuais"
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "LANCAMENTOS INDIVIDUAIS" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := padr("ZZ6PER", 10 , " ")   //padr("ZZ6PER", LEN(SX1->X1_GRUPO), " ") 
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "LANCIND" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "ZZ6"

Private cCodDe := ""
Private cCodAte := "" 

Private nValor := 0

dbSelectArea("ZZ6")
dbSetOrder(1)


pergunte(cPerg,.F.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  12/12/07   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

cCodDe   := MV_PAR01
cCodAte  := MV_PAR02
dDataDe  := MV_PAR03
dDataAte := MV_PAR04

dbSelectArea(cString)
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

//���������������������������������������������������������������������Ŀ
//� Posicionamento do primeiro registro e loop principal. Pode-se criar �
//� a logica da seguinte maneira: Posiciona-se na filial corrente e pro �
//� cessa enquanto a filial do registro for a filial corrente. Por exem �
//� plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    �
//�                                                                     �
//� dbSeek(xFilial())                                                   �
//� While !EOF() .And. xFilial() == A1_FILIAL                           �
//�����������������������������������������������������������������������

//���������������������������������������������������������������������Ŀ
//� O tratamento dos parametros deve ser feito dentro da logica do seu  �
//� relatorio. Geralmente a chave principal e a filial (isto vale prin- �
//� cipalmente se o arquivo for um arquivo padrao). Posiciona-se o pri- �
//� meiro registro pela filial + pela chave secundaria (codigo por exem �
//� plo), e processa enquanto estes valores estiverem dentro dos parame �
//� tros definidos. Suponha por exemplo o uso de dois parametros:       �
//� mv_par01 -> Indica o codigo inicial a processar                     �
//� mv_par02 -> Indica o codigo final a processar                       �
//�                                                                     �
//� dbSeek(xFilial()+mv_par01,.T.) // Posiciona no 1o.reg. satisfatorio �
//� While !EOF() .And. xFilial() == A1_FILIAL .And. A1_COD <= mv_par02  �
//�                                                                     �
//� Assim o processamento ocorrera enquanto o codigo do registro posicio�
//� nado for menor ou igual ao parametro mv_par02, que indica o codigo  �
//� limite para o processamento. Caso existam outros parametros a serem �
//� checados, isto deve ser feito dentro da estrutura de la�o (WHILE):  �
//�                                                                     �
//� mv_par01 -> Indica o codigo inicial a processar                     �
//� mv_par02 -> Indica o codigo final a processar                       �
//� mv_par03 -> Considera qual estado?                                  �
//�                                                                     �
//� dbSeek(xFilial()+mv_par01,.T.) // Posiciona no 1o.reg. satisfatorio �
//� While !EOF() .And. xFilial() == A1_FILIAL .And. A1_COD <= mv_par02  �
//�                                                                     �
//�     If A1_EST <> mv_par03                                           �
//�         dbSkip()                                                    �
//�         Loop                                                        �
//�     Endif                                                           �
//�����������������������������������������������������������������������

dbSeek(xFilial("ZZ6")+cCodDe)
While !EOF() .and. ZZ6->ZZ6_NUM >= cCodDe .and. ZZ6->ZZ6_NUM >= cCodAte   

	If ZZ6->ZZ6_DATA < dDataDe .or. ZZ6->ZZ6_DATA > dDataAte
		
		ZZ6->(DbSkip())
		Loop
	EndIf 

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      //Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      SetPrc(0,0)
      nLin := 8
   Endif

   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:
   // @nLin,00 PSAY SA1->A1_COD

   nLin := nLin + 1 // Avanca a linha de impressao
   
   @004,009 PSAY "+" + replicate("-",56) + "+"
   
   @005,009 PSAY "|"
   @005,066 PSAY "|"
   
   @006,009 PSAY "|"
   @006,066 PSAY "|"
   
   @007,009 PSAY "|"
   @007,066 PSAY "|"
   
   @008,009 PSAY "|'
   @008,019 PSAY "Recibo de Lancamento Individual"
   @008,066 PSAY "|"
   
   @009,009 PSAY "|"
   @009,066 PSAY "|"
   
   @010,009 PSAY "|"
   @010,026 PSAY "Numero: "
   @010,036 PSAY ZZ6->ZZ6_NUM
   @010,066 PSAY "|"
   
   @011,009 PSAY "|"
   @011,066 PSAY "|"
   
   @012,009 PSAY "|"
   @012,066 PSAY "|"

   @013,009 PSAY "|"
   @013,011 PSAY "Data: "
   @013,018 PSAY ZZ6->ZZ6_DATA
   @013,066 PSAY "|"
   
   @014,009 PSAY "|"
   @014,011 PSAY "Valor: R$ "
   @014,022 PSAY ZZ6->ZZ6_VALOR Picture"@E 999,999.99"
   @014,066 PSAY "|"
   
   @015,009 PSAY "|"
   @015,011 PSAY "Observacoes: "
   @015,066 PSAY "|"
   
   @016,009 PSAY "|"
   @016,011 PSAY Substr(ZZ6->ZZ6_OBS,1,50)
   @016,066 PSAY "|"
   
   @017,009 PSAY "|"
   @017,011 PSAY Substr(ZZ6->ZZ6_OBS,51,50)
   @017,066 PSAY "|"
   
   @018,009 PSAY "|"
   @018,011 PSAY Substr(ZZ6->ZZ6_OBS,101,50)
   @018,066 PSAY "|"
   
   @019,009 PSAY "|"
   @019,066 PSAY "|"
   
   @020,009 PSAY "|"
   @020,066 PSAY "|"
   
   @021,009 PSAY "|"
   @021,066 PSAY "|"
   
   @022,009 PSAY "|"
   @022,018 PSAY replicate("_",40)
   @022,066 PSAY "|"
   
   @023,009 PSAY "|"
   @023,030 PSAY ZZ6->ZZ6_NOME
   @023,066 PSAY "|"
   
   @024,009 PSAY "|"
   @024,066 PSAY "|"
   
   @025,009 PSAY "|"
   @025,066 PSAY "|"
   
   @026,009 PSAY "+" + replicate("-",56) + "+"
    
        nValor += ZZ6->ZZ6_VALOR        //soma o valor do campo
    
   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo
 @ 0,0 psay nValor PICTURE"@E 99.999999"

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return
