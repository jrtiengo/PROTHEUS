#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#Include "RESTFUL.CH"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � POST     �Autor  �Sosys Business Insight� Data �  NOV/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para excluir Orderm de Produ��o (Tabela SC2)        ���
�������������������������������������������������������������������������͹��
���Uso       � Automatech - OP_EXCLUIR                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
 
WSRESTFUL OP_EXCLUIR DESCRIPTION "Exclus�o de OP's."

	WSDATA C2_OP 	AS STRING // N�mero da Ordem de Produ��o + Item + Sequ�ncia. - 00000101001
	WSDATA EMPRESA  AS STRING // Empresa. - 01
	WSDATA FILIAL   AS STRING // Filliall. - 01

	WSMETHOD GET DESCRIPTION "Excluir OP's"  WSSYNTAX "/EMPRESA=01&FILIAL=02&C2_OP=00000601001

	END WSRESTFUL

WSMETHOD GET WSRECEIVE EMPRESA,FILIAL,C2_OP WSSERVICE OP_EXCLUIR

	Local lOk		:= .T. // Retorno para o WS.
	Local aMata650	:= {}  // Array enviado para ExecAuto
	Local cErro 	:= {}
	Local cC2_OP	:= ""
	Local cEmpresa  := ""
	Local cCFilial	:= ""
			
	Private lMsErroAuto := .F.

	::SetContentType("application/json") // Define o tipo de retorno do metodo
	
	cEmpresa := ::EMPRESA
    cCFilial := ::FILIAL
    
    PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cCFilial // Prepara a empresa e filial
	
	cC2_OP 	  := ::C2_OP
    
    Conout("==================================================")
    Conout("==     Parametros recebidos pelo WS_EXCLUIR     ==")
    Conout("==================================================")
	ConOut ("Empresa.....: " + cEmpresa        )
	ConOut ("Filial......: " + cCFilial        )
	ConOut ("C2_OP.......: " + cC2_OP          )
	ConOut ("=================================================")
    
    DbSelectArea("SC2")
    SC2->(dbSetorder(1))
	
	Begin Transaction
		SC2->(DbSetOrder(1))//FILIAL + NUM + ITEM + SEQUEN
		SC2->(DbSeek(cCFilial+SubStr(cC2_OP,01,06)+SubStr(cC2_OP,07,02)+SubStr(cC2_OP,09,03)))	// Posiciona o registro a ser excluido		
		aMata650 := {{"C2_NUM",SubStr(cC2_OP,01,06),NIL}} 
		msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)
        
    End Transaction     
        If lMsErroAuto
        	cErro := Mostraerro("sosystools","Error WS_OP_EXCLUIR.txt")
        	ConOut(cErro)
        	::SetResponse( '{' )
        	::SetResponse( '"errorCode": "1",' )
        	::SetResponse( '"errorMessage": ' + "Erro ao excluir empenho: " + cC2_OP )	
        	::SetResponse( cErro )
        	::SetResponse('}')
        	ConOut ( "=========================================================================" )
        	ConOut ( "========                 FIM OP_EXCLUIR                          ========" )
        	ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
        	ConOut ( "========                  " + TIME() + "                               ========" )
        	ConOut ( "=========================================================================" )
        	DisarmTran()
            lOk := .T.
            SC2->(dbCloseArea())	 				
        Else
            ::SetResponse('{')
			::SetResponse('"errorCode": "0",' )
			::SetResponse('"errorMessage": ' + CHR(34) + "Ordem de Producao excluida com sucesso." + CHR(34))								
			::SetResponse('}')
			ConOut ( "=========================================================================" )
			ConOut ( "========                 FIM OP_EXCLUIR                          ========" )
			ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
			ConOut ( "========                  " + TIME() + "                               ========" )
			ConOut ( "=========================================================================" )
			SC2->(dbCloseArea())	
        EndIf
    RESET ENVIRONMENT
Return( lOk )//Caso n�o tenha o lOk ele retorna erro para o postman.