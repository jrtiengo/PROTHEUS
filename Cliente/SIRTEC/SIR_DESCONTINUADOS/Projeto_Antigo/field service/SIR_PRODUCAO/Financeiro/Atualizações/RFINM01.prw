#include "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Arquivo   �RFINM01   �Autor  �Cosme da Silva Nunes   �Data  �02/02/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Arquivo com os programas de validacao do arquivo CNAB mod. 2���
���          �do Banco do Brasil                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Financeiro                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
/*/

/*/
�����������������������������������������������������������������������Ŀ
�Rdmake    �BB01      �Autor  �Cosme da Silva Nunes   �Data  �22/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri�ao �Zera o parametro com o numero sequencial do reg. no lote    �
�          �Esta rotina deve ser executada na chamada da rotina FINA420,�
�          �que eh disparada por esta. Substituir a chamada da rotina   �
�          �FINA420 em todos os menus para BB01.                        �
�������������������������������������������������������������������������
/*/
User Function BB01()
Private _cRegLt := "00000"
PutMV("MV_CNABRL",_cRegLt)
FINA420()
Return()  

User Function BB01NEW
Private cRet := "001"

	Putmv("MV_YCNAB  ",0)
	Putmv("MV_YCNABL ",1)
	
Return cRet 

User Function BB01SUM
Private cRet := "001"

	nTMP := GetMv("MV_YCNAB")
	nTMP ++
	
	Putmv("MV_YCNAB  ",nTMP)
	
Return cRet


User Function BB01LOTE

	nRet := nTMP := GetMv("MV_YCNABL")
	nTMP ++
	
	Putmv("MV_YCNABL ",nTMP)
	
Return nRet

/*/
�����������������������������������������������������������������������Ŀ
�Rdmake    �BB02      �Autor  �Cosme da Silva Nunes   �Data  �02/02/2004�
�����������������������������������������������������������������������Ĵ
�Descri�ao �Numero sequencial do registro no lote                       �
�������������������������������������������������������������������������
/*/
User Function BB02() 

_cRegLt := StrZero(Val(GetMV("MV_CNABRL"))+1,5)
PutMV("MV_CNABRL",_cRegLt)
Return(_cRegLt)

/*/
�����������������������������������������������������������������������Ŀ
�Rdmake    �BB03      �Autor  �Cosme da Silva Nunes   �Data  �31/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri�ao �Recebe digito verificador codigo de barras / linha digitavel�
�������������������������������������������������������������������������
/*/
User Function BB03()

SetPrvt("cDigVer")

If Len(Alltrim(SE2->E2_CODBAR)) == 44
	cDigVer := Substr(SE2->E2_CODBAR,5,1)
Else
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		cDigVer := Substr(SE2->E2_CODBAR,33,1)
	EndIf
EndIf	

Return(cDigVer)

/*/
�����������������������������������������������������������������������Ŀ
�Rdmake    �BB04      �Autor  �Cosme da Silva Nunes   �Data  �31/03/2004�
�����������������������������������������������������������������������Ĵ
�Descri�ao �Extrai campo livre codigo de barras / linha digitavel       �
�������������������������������������������������������������������������
/*/
User Function BB04()

SetPrvt("cCF")

If Len(Alltrim(SE2->E2_CODBAR)) == 44
	cCF := Substr(SE2->E2_CODBAR,20,25)
Else
	If Len(Alltrim(SE2->E2_CODBAR)) > 44
		cCF := Substr(SE2->E2_CODBAR,5,5)
		cCF += Substr(SE2->E2_CODBAR,11,10)
		cCF += Substr(SE2->E2_CODBAR,22,10)
	EndIf	
EndIf	

Return(cCF)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Arquivo   �CPFPrep   �Autor  �Cosme da Silva Nunes   �Data  �08/12/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Programa p/ criacao de interface p/ atualizacao do parametro���
���          �de usuario utilizado no CNAB pagamento tipo ordem de pagto  ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Financeiro                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
/*/
User Function CPFPrep()

Private oDlg 		:= Nil
Private cTitulo 	:= OemToAnsi("Inf. CPF prepostos - CNAB Ordem Pagto")
Private cLabel1 	:= OemToAnsi("CPF Preposto 1:")
Private cLabel2 	:= OemToAnsi("CPF Preposto 2:")
Private cCPFPrp1 	:= Space(11)
Private cCPFPrp2 	:= Space(11)
Private lT	 		:= .F.
cCPFPrp1 	:= If(Empty(GetMV("MV_CPFPRP1")),Space(11),GetMV("MV_CPFPRP1"))
cCPFPrp2 	:= If(Empty(GetMV("MV_CPFPRP2")),Space(11),GetMV("MV_CPFPRP2"))

//���������������������������������������������������������������������Ŀ
//� Criacao da Interface                                                �
//�����������������������������������������������������������������������
@ 088,178 To 390,478 Dialog oDlg Title cTitulo

	@ 15,15 Say cLabel1 Size 40,10
	@ 40,15 Say cLabel2 Size 40,10

	@ 15,60 Get cCPFPrp1 Picture "@R 999.999.999-99" Size 70,10 //Picture "@R 999.999.999-99" 
	@ 40,60 Get cCPFPrp2 Picture "@R 999.999.999-99" Size 70,10 //Picture "@R 999.999.999-99" 
	
	@ 127, 37 BmpButton Type 01 Action Eval( {||lT:=.T.,  oDlg:End() }	)
	@ 127, 85 BmpButton Type 02 Action Eval( {||oDlg:End() } 		  	)

Activate Dialog oDlg Centered

If lT
	PutMV("MV_CPFPRP1",cCPFPrp1)
	PutMV("MV_CPFPRP2",cCPFPrp2)
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CNABPG    �Autor  �Ricardo Nunes       � Data �  06/13/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao para ira retornar o codigo do tipo de pagamento do   ���
���          �Banco BankBoston de acordo com o manual do banco.           ���
�������������������������������������������������������������������������͹��
���Uso       �CNAB A PAGAR AP                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CNABPG(_cParam)

Local _cRet

If _cParam == "TP"
	_cRet := If(SA2->A2_BANCO=="479","CC ",If(EMPTY(SE2->E2_CODBAR),"DOC","COB"))			     
ElseIf _cParam == "CC"
	_cRet := If(SA2->A2_BANCO=="479","000",If(SE2->E2_MODSPB $("2,3"),"700","018"))
Endif

Return(_cRet)

