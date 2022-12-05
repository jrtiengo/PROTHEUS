#INCLUDE "rwmake.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcerB2B9  � Autor � AP5 IDE            � Data �  11/06/12  ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP5 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AcerB2B9()
   
Processa( {|| Acerto() },"Acertando Custo e Quantidade nas Tabelas SB2, SB9 pelo ArqPosEst de 31.12.2011 ou �ltimo Valor Unit�rio do SD1.","Aguarde...." )
                        
Return

Static Function Acerto()
     
Local dDataAnt := CToD("30/11/2011")
Local dDataFim := CToD("01/01/2012")
Local dDataAtu := dDataBase
Local cFilPRD  := "04"
// 0� Passo
// SB2PRODU - C�pia do Arquivo de Saldos.
//    Pegar Qtde Atual B2_QATU e gravar na Tabela SB2.
// SB2 - Arquivo de Saldo ajustado no Ambiente de Testes.
// 1� Passo
// SB2 - Posicionar no 1� registro
// ARQTMP - Arquivo temporario gerado a partir do relatorio Posicao de Estoque - Saldo para 31.12.2011 
//    Posicionar no Produto do SB2
//    Se n�o localizado
//       SB2 - zerar B2_QFIM E B2_VFIM1
// 2� Passo                                 
// SB9 - Posicionar no 1� registro - s�mente os registro do fechamento de 31.12.2011
// ARQTMP - Arquivo temporario gerado a partir do relatorio Posicao de Estoque - Saldo para 31.12.2011 
//    Posicionar no Produto do SB9
//    Se n�o localizado
//       SB9 - Posicionar no registro e zerar B9_QINI, B9_VINI1 e B9_CM1
//       SD3 - Fazer um lan�amento D3_TM para zerar a qtdade, conforme qtde do B9_QINI e B9_VINI1
// 3� Passo                                 
// ARQTMP - Posicionado no Primeiro Registro
// SD1 - Ultimo Valor Unit�rio - D1_VUNIT
// Buscar �ltima nota do Produto e pegar o Valor Unit�rio.
// Se Produto n�o Localizado na Nota, calcular custo pelos dados do relat�rio, (quantidade/valor em estoque), obs Valor Negativo.
// Se Valor Negativo no relat�rio, zerar o valor do custo, (?) ou fazer uma movimentacao valorizada (SD3) no valor negativo.
// SB2
// No campo B2_QFIM, ser� informada a qtde do Produto conforme relat�rio.
// No Campo B2_CM1, ser� informado o Custo --> D1_VUNIT da �ltima nota localizada deste Produto, ou o Custo apurado pelo relat�rio.
// No Campo B2_VFIM1 informar o resultado do Campo B2_CM1 * B2_QFIM
// Acertar tb o Valor Atual B2_VATU a partir do resultado do Campo B2_QATU * B2_CM1
// SB9
// Buscar registro do Fechamento conforme produto posicionado.
// B9_QINI == B2_QFIM e B9_VINI1 == B2_VFIM1 e B9_CM1 == B2_CM1

// PASSO 0 - Atualizando Saldo Atual conforme c�pia salva.
/*
cArq   := CriaTrab("",.F.)
dbUseArea(.t.,,"SB2_PROD","PRD")   
IndRegua("PRD",cArq,"B2_FILIAL+B2_COD",,,OemToAnsi("PASSO 0 - Selecionando registros...."))

dbSelectArea("SB2")
dbSetOrder(1) 

dbSelectArea("PRD")
dbSetOrder(1) 
ProcRegua(LASTREC())
dbSeek(cFilPRD)
Do While !EOF() .And. B2_FILIAL == cFilPRD 
   cCodPRD := B2_COD
   nQtdAtu := B2_QATU  
   nRecPRD := RecNo()
   
   IncProc("Acertando Qtd Atual do Produto ... "+AllTrim(cCodPRD)+" no SB2.")
   
   dbSelectArea("SB2")
   If dbSeek(cFilPRD+cCodPRD) 
      RecLock("SB2",.F.)
	     SB2->B2_QATU := nQtdAtu
      MsUnLock() 
   EndIf 
   
   dbSelectArea("PRD")
   dbGoTo(nRecPRD)
   dbSkip()
EndDo
*/
// PASSO 1 - ZERANDO REGISTRO DO SB2 CASO N�O LOCALIZADO NO ARQUIVO TEMPORARIO
cArq := CriaTrab("",.F.)
dbUseArea(.t.,,"ACERCUST","TMP")   
IndRegua("TMP",cArq,"COD_PROD",,,OemToAnsi("PASSO 1 - Selecionando registros...."))

dbSelectArea("TMP")
dbSetOrder(1) 
/*   
dbSelectArea("SB2")
dbSetOrder(1) 
ProcRegua(LASTREC())
dbSeek(cFilPRD)
Do While !EOF() .And. xFilial("SB2") == B2_FILIAL  

   cCod   := AllTrim(B2_COD)
   
   lSegue := TMP->(dbSeek(cCod))
   
   If !lSegue
      IncProc("Zerando o Produto ... "+AllTrim(cCod)+" no SB2.")
      RecLock("SB2",.F.)
	     SB2->B2_QFIM  := 0
	     SB2->B2_VFIM1 := 0                            
      MsUnLock() 
   Else
      IncProc("Produto "+AllTrim(cCod)+" localizado no SB2.")   
   EndIf
   dbSkip()
EndDo    
        
// PASSO 2 - ZERANDO REGISTRO DO SB9 CASO N�O LOCALIZADO NO ARQUIVO TEMPORARIO
dbSelectArea("SB9")
dbSetOrder(1) 
ProcRegua(LASTREC())
dbSeek(cFilPRD)
Do While !EOF() .And. xFilial("SB9") == B9_FILIAL
   cCod   := AllTrim(B9_COD)
   
   lSegue := TMP->(dbSeek(cCod))
   
   If !lSegue
      IncProc("Zerando o Produto ... "+cCod+" no SB9.")
      RecLock("SB9",.F.)
	     SB9->B9_QINI := 0
	     SB9->B9_VINI1:= 0                            
	     SB9->B9_CM1  := 0
      MsUnLock() 
   Else
      IncProc("Produto "+cCod+" localizado no SB9.")   
   EndIf
   dbSkip()  
EndDO   
*/
// PASSO 3 - ACERTANDO QTDE, VALOR E CUSTO (SB2 e SB9) CONFORME RELATORIO TERMPORARIO (SB2FEC11.DBF)
dbSelectArea("TMP")
ProcRegua(RecCount())
dbGoTop()
Do While !Eof()

   IncProc("Acertando o Custo do Produto ... "+AllTrim(COD_PROD)+" no SB2 e no SB9 pelo ValUnit do SD1.")   
   
   nRecTMP := RecNo()
   cLocPad := "01"    
   cCodProd:= COD_PROD+" "
   nQtdEstq:= QTD_PROD
   nValEstq:= VLR_PROD
   If nValEstq <= 0
      nVUnEstq:= 0
   Else 
      nVUnEstq:= ROUND(nValEstq / nQtdEstq,2) 
   EndIf       
   
   dbSelectArea("SD1")
   dbSetOrder(7)
   If !dbSeek(xFilial("SD1")+cCodProd+cLocPad+DToS(dDataFim)) 
      If dbSeek(xFilial("SD1")+cCodProd+cLocPad) 
         Do While D1_FILIAL == xFilial("SD1") .And. D1_COD+D1_LOCAL == cCodProd+cLocPad
            nVUnEstq := D1_VUNIT
            dbSkip()
         EndDo   
      EndIf
   Else   
      Do While D1_FILIAL == xFilial("SD1") .And. D1_COD+D1_LOCAL == cCodProd+cLocPad
         nVUnEstq := D1_VUNIT
         dbSkip()
      EndDo   
    EndIf  
   
   dbSelectArea("SB2")
   dbSetOrder(1) 
   If dbSeek(xFilial("SB2")+cCodProd+cLocPad) 
      RecLock("SB2",.F.)
	     SB2->B2_CM1   := nVUnEstq
	     SB2->B2_QFIM  := nQtdEstq
	     SB2->B2_VFIM1 := Round(nVUnEstq*nQtdEstq,2) 
	     SB2->B2_VATU1 := Round(SB2->B2_QATU*nVUnEstq,2) 
      MsUnLock()          
   EndIf

   dbSelectArea("SB9")
   dbSetOrder(1)
   If dbSeek(xFilial("SB9")+cCodProd+cLocPad+DToS(dDataAtu)) 
      RecLock("SB9",.F.)
		  SB9->B9_CM1   := SB2->B2_CM1 
		  SB9->B9_VINI1 := SB2->B2_VFIM1 
		  SB9->B9_QINI  := SB2->B2_QFIM 
      MsUnLock()
   EndIf              
   
   dbSelectArea("TMP")
   dbGoTo(nRecTMP)
   dbSkip()
EndDo   

Return .T.
