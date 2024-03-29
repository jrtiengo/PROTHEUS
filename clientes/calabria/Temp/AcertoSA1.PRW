#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcertoSA1  � Autor � AP5 IDE            � Data �  29/02/12  ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP5 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AcertoA1()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
   
Processa( {|| fAcertoSA1() },"Acerto do Codigo Municipio - IBGE da Tabela SA1","Aguarde...." )
                        
Return

Static Function fAcertoSA1()

Local nRecSA1  := 0   
Local cMun     := Space(25)         
Local cEst     := Space(2)
Local cCodMun  := ""

dbSelectArea("CC2")
dbSetOrder(2)

dbSelectArea("SA1")
dbSetOrder(1)
ProcRegua(RecCount())
DBGOTOP()
Do While !EOF()
      
   IncProc()              
   
   If !Empty(A1_COD_MUN)
      dbSkip()
      Loop
   EndIf       
             
   nRecSA1 := RecNo() 
   cMun    := AllTrim(A1_MUN)
   cEst    := A1_EST
   cCodMun := ""
   
   dbSelectArea("CC2")
   If dbSeek(xFilial("CC2")+cMun)
	  If cEst <> CC2_EST
	     dbSkip()
	     Do While cMun == AllTrim(CC2_MUN) .And. !EOF()
	        If cEst == CC2_EST
	           cCodMun := CC2_CODMUN  
	           Exit
	        EndIf
	        dbSkip()
	     EndDo
	  Else
	     cCodMun := CC2_CODMUN 
	  EndIf
   EndIf
   
   dbSelectArea("SA1")
   dbGoTo(nRecSA1)
   RecLock("SA1",.F.)
     SA1->A1_COD_MUN := cCodMun
   MsUnLock()
   dbSkip()
EndDo

Return
