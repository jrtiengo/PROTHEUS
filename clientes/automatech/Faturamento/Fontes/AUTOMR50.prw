#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO2     � Autor � AP6 IDE            � Data �  23/11/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AUTOMR50

   Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
   Local cDesc2         := "de acordo com os parametros informados pelo usuario."
   Local cDesc3         := ""
   Local cPict          := ""
   Local titulo         := ""
   Local nLin           := 80
   Local cSql           := ""
   Local nContar        := 0
   Local Cabec1         := ""
   Local Cabec2         := ""
   Local imprime        := .T.
   Local aOrd           := {}

   Private lEnd         := .F.
   Private lAbortPrint  := .F.
   Private CbTxt        := ""
   Private limite       := 80
   Private tamanho      := "P"
   Private nomeprog     := "NOME" // Coloque aqui o nome do programa para impressao no cabecalho
   Private nTipo        := 18
   Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey     := 0
   Private cbtxt        := Space(10)
   Private cbcont       := 00
   Private CONTFL       := 01
   Private m_pag        := 01
   Private wnrel        := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco

   Private cString      := "SC5"

   Private aLista := {}

   U_AUTOM628("AUTOMR50")

   // Pesquisa as Propostas comerciais realizadas na Moeda 2
   If Select("T_PROPOSTA") > 0
      T_PROPOSTA->( dbCloseArea() )
   EndIf

   csql := ""
   csql := "SELECT ADZ_FILIAL, "
   csql += "       ADZ_PROPOS, "
   csql += "       ADZ_ORCAME  "
   csql += "  FROM " + RetSqlName("ADZ010")                
   csql += " WHERE ADZ_MOEDA = '2' "
   csql += " GROUP BY ADZ_FILIAL, ADZ_PROPOS, ADZ_ORCAME "
   csql += " ORDER BY ADZ_FILIAL, ADZ_PROPOS"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROPOSTA", .T., .T. )

   If T_PROPOSTA->( Eof() )
      MsgAlert("N�o existem dados a serem visualizados.")
      If Select("T_PROPOSTA") > 0
         T_PROPOSTA->( dbCloseArea() )
      EndIf
      Return .T.
   Endif

   T_PROPOSTA->( DbGoTop() )
   
   WHILE !T_PROPOSTA->( EOF() )

      // Pesquisa o n� do Pedido de Venda para a proposta lida
      If Select("T_PRODUTOS") > 0
         T_PRODUTOS->( dbCloseArea() )
      EndIf
      
      csql := ""
      csql := "SELECT C6_NUM   , "
      csql += "       C6_NUMORC  "
      csql += "  FROM " + RetSqlName("SC6010")                
      csql += " WHERE C6_NUMORC LIKE '" + Alltrim(T_PROPOSTA->ADZ_ORCAME) +"%'"
      csql += "   AND C6_FILIAL    = '" + Alltrim(T_PROPOSTA->ADZ_FILIAL) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )
      
      If T_PRODUTOS->( EOF() )
         T_PROPOSTA->( DbSkip() )         
         Loop
      Endif
      
      // Pesquisa a Moeda do Pedido de Venda Lido
      If Select("T_CABECALHO") > 0
         T_CABECALHO->( dbCloseArea() )
      EndIf
      
      csql := ""
      csql := "SELECT C5_NUM    , "
      csql += "       C5_MOEDA  , "
      csql += "       C5_EMISSAO  "
      csql += "  FROM " + RetSqlName("SC5010")                
      csql += " WHERE C5_NUM    = '" + Alltrim(T_PRODUTOS->C6_NUM)      + "'"
      csql += "   AND C5_FILIAL = '" + Alltrim(T_PROPOSTA->ADZ_FILIAL) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CABECALHO", .T., .T. )

      If T_CABECALHO->( EOF() )
         T_CABECALHO->( DbSkip() )         
         Loop
      Endif

      //Compara as moedas entra a Proposta Comercial e o Pedido de Venda
      If T_CABECALHO->C5_MOEDA == 2
      Else
         aAdd( aLista, { T_PROPOSTA->ADZ_FILIAL ,;
                         T_PROPOSTA->ADZ_PROPOS ,;
                         T_PROPOSTA->ADZ_ORCAME ,;
                         "2"                    ,;
                         T_CABECALHO->C5_NUM    ,;
                         T_CABECALHO->C5_MOEDA  ,;
                         T_CABECALHO->C5_EMISSAO } )
      Endif

      T_PROPOSTA->( DbSkip() )

Enddo

dbSelectArea("SC5")
dbSetOrder(1)


//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

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
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  23/11/11   ���
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
Local nContar := 0

dbSelectArea(cString)
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua( Len(aLista) )

@ nLin,001 psay "--------------------------------------------------"
nLin += 1
@ nLin,001 psay "FL  M  PROPOSTA  ORCAMRNTO PEDIDO   M   EMISSAO"
nLin += 1
@ nLin,001 psay "--------------------------------------------------"
nLin += 2

For nContar = 1 to Len(aLista)

    @ nLin,001 psay aLista[nContar,01] picture "!!"
    @ nLin,005 psay aLista[nContar,04] 
    @ nLin,008 psay aLista[nContar,02] picture "!!!!!!"
    @ nLin,018 psay aLista[nContar,03] picture "!!!!!!"
    @ nLin,028 psay aLista[nContar,05] picture "!!!!!!"
    @ nLin,037 psay aLista[nContar,06] 
    @ nLin,041 psay Substr(aLista[nContar,07],07,02) + "/" + Substr(aLista[nContar,07],05,02) + "/" + Substr(aLista[nContar,07],01,04)

    nLin += 1

Next nContar

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
