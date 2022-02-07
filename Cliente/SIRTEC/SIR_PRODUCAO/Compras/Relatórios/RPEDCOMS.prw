#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPedComS  � Autor �Leonel/Renato       � Data �  26/08/14   ���
�������������������������������������������������������������������������͹��
���Descricao � Rela��o de Pedidos de Compras por Per�odo                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIRTEC                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RPEDCOMS

Private cPerg := PAdR('RPCOMSIR',10)

Pergunte( cPerg, .F. )


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := "de acordo com os parametros informados pelo usuario."
Private cDesc3         := "Relacao de Pedidos de Compra"
Private titulo       := "Relacao de Pedidos de Compra por Per�odo"

//                   012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
//                   0         1         2         3         4         5         6         7         8         9        10        11        12        13
//                   XXX       XXXXXXXXXXxxxxxxxxxxXXXXXXXXXX 99     99/99/99   XXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXX   XXXXXXXX   999   99    9,999,999.99
Private Cabec1     := "Item    Produto       Desc.Produto              Qtde           Pre�o Unit�rio      Valor Total       Conta Contabil"
Private Cabec2     := ""
Private imprime      := .T.
Private aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 120
Private tamanho          := "M"
Private nomeprog         := "RPEDCOMS" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}

Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RPEDCOMS" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SC7"

dbSelectArea( 'SA2' )
dbSetOrder( 1 )


dbSelectArea("SC7")
dbSetOrder(1)


//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.T.)

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

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo)

Local nOrdem

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

cPedido := ' '
nTValor :=   0

dbGoTop()

dbSelectArea( 'SC7' )
dbSetOrder( 5 )   // Indice por Data

dbSeek(xFilial("SC7") +dtos(MV_PAR01), .T.)

While !EOF().and. SC7->C7_EMISSAO <= MV_PAR02

   //���������������������������������������������������������������������Ŀ
   //� Verifica o cancelamento pelo usuario...                             �
   //�����������������������������������������������������������������������

   If lAbortPrint
      @Prow()+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //���������������������������������������������������������������������Ŀ
   //� Impressao do cabecalho do relatorio. . .                            �
   //�����������������������������������������������������������������������

   If Prow() > 55 .or. m_pag == 1 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   Endif

   // Coloque aqui a logica da impressao do seu programa...
   // Utilize PSAY para saida na impressora. Por exemplo:

	dbSelectArea( 'SA2' )
	dbSetOrder( 1 )
	dbSeek(xFilial("SA2") +SC7->C7_FORNECE, .F.)


	dbSelectArea( 'SB1' )
	dbSetOrder( 1 )
	dbSeek(xFilial("SB1") +SC7->C7_PRODUTO, .F.)


	dbSelectArea( 'CT1' )
	dbSetOrder( 1 )
	dbSeek(xFilial("CT1") +SC7->C7_CONTA, .F.)


    If  cPedido <>  SC7->C7_NUM
		@ pRow()+1, 000 pSay 'PEDIDO N. ' + SC7->C7_NUM
		@ pRow()  , 020 pSay  SC7->C7_FORNECE + ' - ' + SA2->A2_NOME
		@ pRow()  , 080 pSay  'Emissao: '+ dtoc(SC7->C7_EMISSAO)
        cPedido := SC7->C7_NUM
    EndIF


	@ pRow()+1, 000 pSay SC7->C7_ITEM
	@ pRow()  , 007 pSay Alltrim(SC7->C7_PRODUTO) + ' - ' + SubStr(SB1->B1_DESC,1,20)
	@ pRow()  , 041 pSay Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))
	@ pRow()  , 063 pSay Transform(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))
	@ pRow()  , 080 pSay Transform(SC7->C7_TOTAL,PesqPict("SC7","C7_TOTAL"))
	@ pRow()  , 100 pSay AllTrim(SC7->C7_CONTA) + ' - ' +  SubStr(CT1->CT1_DESC01,1,20)
    nTValor :=  nTValor +  SC7->C7_TOTAL


	dbSelectArea( 'SC7' )
	dbSetOrder( 5 )   // Indice por Data
   dbSkip() // Avanca o ponteiro do registro no arquivo

    If  cPedido <>  SC7->C7_NUM
		@ pRow()+1, 071 pSay 'Total -> ' + Transform(nTValor,PesqPict("SC7","C7_TOTAL"))
        @ pRow()+1, 000 pSay Replicate("-",limite)
		nTValor :=   0
    EndIF

EndDo

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
