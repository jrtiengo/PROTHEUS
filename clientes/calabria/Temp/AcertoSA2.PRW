#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AcertoSA2  � Autor � AP5 IDE            � Data �  29/02/12  ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP5 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AcertoA2()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
   
Processa( {|| fAcertoSA2() },"Acerto do Codigo Municipio - IBGE da Tabela SA2","Aguarde...." )
                        
Return

Static Function fAcertoSA2()

Local nRecSA2  := 0   
Local cMun     := Space(25)         
Local cEst     := Space(2)
Local cCodMun  := ""

dbSelectArea("CC2")
dbSetOrder(2)

dbSelectArea("SA2")
dbSetOrder(1)
ProcRegua(RecCount())
DBGOTOP()
Do While !EOF()
      
   IncProc()              
   
   If !Empty(A2_COD_MUN)
      dbSkip()
      Loop
   EndIf       
             
   nRecSA2 := RecNo() 
   cMun    := AllTrim(A2_MUN)
   cEst    := A2_EST
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
   
   dbSelectArea("SA2")
   dbGoTo(nRecSA2)
   RecLock("SA2",.F.)
     SA2->A2_COD_MUN := cCodMun
   MsUnLock()
   dbSkip()
EndDo

Return
