#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'TOPCONN.CH'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �         � Autor �                       � Data �           ���
�������������������������������������������������������������������������Ĵ��
���Locacao   �                  �Contato �                                ���
�������������������������������������������������������������������������Ĵ��
���Descricao �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  �                                               ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �                                               ���
���              �  /  /  �                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function SIRWORKFL

Local   _aCbPesq  := {" ","Workflow Cleidiane","Workflow Marcia","Workflow ABF"}
Private _cCbPesq  := ""
Private _aColsCrt := {}
Private _oFC08    := TFont():New('Courier New',,-12,.F.) 
Private _aBrw2    := {}
Private _oOk      := LoadBitmap(GetResources(), "LBOK")
Private _oNo      := LoadBitmap(GetResources(), "LBNO")

/*
�������������������������������������������������������������������������ı�
�� Declara��o de Variaveis Private dos Objetos                            ��
�������������������������������������������������������������������������ı�
*/

SetPrvt("oDWFL","oGrp1","oGrp2","oCBox1","oBtn1")

/*
�������������������������������������������������������������������������ı�
�� Definicao do Dialog e todos os seus componentes.                       ��
�������������������������������������������������������������������������ı�
*/

oDWFL       := MSDialog():New(092,232,570,951,"WorkFlow",,,.F.,,,,,,.T.,,,.T.)
oDWFL:bInit := {||EnchoiceBar(oDWFL,{|| AtuFlag()},{|| oDWFL:End()},.F.,{})}
oGrp1       := TGroup():New(016,004,200,348,"",oDWFL,CLR_BLACK,CLR_WHITE,.T.,.F.)
oGrp2       := TGroup():New(024,008,052,344," Filtro ",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F.)
oCBox1      := TComboBox():New(035,012,{|u| If(PCount()>0,_cCbPesq:=u,_cCbPesq)},_aCbPesq,072,010,oGrp2,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,)
oBtn1       := TButton():New(033,089,"Procurar",oGrp2,{|| PesqWkfl()},095,012,,,,.T.,,"",,,,.F.)

//Array com os campos da grade de dados

_aHeadCrt := {" ","Nota","Obs","Digitador","Data"}

//Criacao do objeto ListBox
oBrCrt    := TCBrowse():New(065,008,320,75,,_aHeadCrt,_aColsCrt,oGrp2,,,,,{||},,_oFC08,,,,,.F.,,.T.,,.F.,,,)

Aadd(_aBrw2,{.F.,"","","",""})	

//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

oBrCrt:bLDblClick := {|| CarDados( oBrCrt:nAt )}

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  If(_aBrw2[oBrCrt:nAT,01],_oOk,_oNo),;
							_aBrw2[oBrCrt:nAt,02],_aBrw2[oBrCrt:nAt,03],;
                            _aBrw2[oBrCrt:nAt,04],_aBrw2[oBrCrt:nAt,05]}}

oDWFL:Activate(,,,.T.)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SIRWORKFL �Autor  �Microsiga           � Data �  07/28/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/    

Static Function PesqWkfl

Local _cQuery := ""
Local _cAlias := GetNextAlias()

If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 

_cQuery := " SELECT * "
_cQuery += " FROM "+RetSqlName("ZZW") 
_cQuery += " WHERE  D_E_L_E_T_ != '*' "
_cQuery += " AND    ZZW_SITUAC  = 'W' "
_cQuery += " AND    ZZW_STGRV   = '"+_cCbPesq+"' "
_cQuery += "ORDER BY R_E_C_N_O_"

TcQuery _cQuery New Alias _cAlias 

_aBrw2 := {}
	
//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  If(_aBrw2[oBrCrt:nAT,01],_oOk,_oNo),;
							_aBrw2[oBrCrt:nAt,02],_aBrw2[oBrCrt:nAt,03],;
                            _aBrw2[oBrCrt:nAt,04],_aBrw2[oBrCrt:nAt,05]}}
	
While !("_cAlias")->(Eof())

		aAdd(_aBrw2,{ .F.,;				
					  ("_cAlias")->ZZW_NOTA,;
					  _cObs := Posicione("ZZW",2,xFilial("ZZW")+("_cAlias")->ZZW_NOTA,"ZZW_OBSDIG"),;
				      ("_cAlias")->ZZW_USER,;
					  Substr(("_cAlias")->ZZW_DATA,7,2)+"/" + Substr(("_cAlias")->ZZW_DATA,5,2) +"/"+Substr(("_cAlias")->ZZW_DATA,1,4)+" - "  + ("_cAlias")->ZZW_HORA})
				
	("_cAlias")->(DbSkip())
EndDo			

Return 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CarDados  �Autor  �Microsiga           � Data �  02/19/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CarDados(_nLin)

_aBrw2[_nLin,01] := !(_aBrw2[_nLin,01])

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SIRWORKFL �Autor  �Microsiga           � Data �  07/28/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AtuFlag()

Private _cMltGet := ""

/*
�������������������������������������������������������������������������ı�
�� Declara��o de Variaveis Private dos Objetos                            ��
�������������������������������������������������������������������������ı�
*/

SetPrvt("oFlg","oGrp1","oMGet1")

/*
�������������������������������������������������������������������������ı�
�� Definicao do Dialog e todos os seus componentes.                       ��
�������������������������������������������������������������������������ı�
*/

oFlg       := MSDialog():New(092,232,351,692,"Atualiza WorkFlow",,,.F.,,,,,,.T.,,,.T. )
oFlg:bInit := {||EnchoiceBar(oFlg,{|| AtuZZW(),oFlg:End()},{|| oFlg:End()},.F.,{})}
oGrp1      := TGroup():New(016,004,116,216," Obs.: ",oFlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oMGet1     := TMultiGet():New(028,012,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrp1,196,080,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

oFlg:Activate(,,,.T.)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SIRWORKFL �Autor  �Microsiga           � Data �  07/28/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function AtuZZW

Local _cQuery := ""
Local _cAlias := GetNextAlias()

For i := 1 To Len(_aBrw2)
	
	If _aBrw2[i][1]
	
		DbSelectArea("ZZW")
		DbSetOrder(2)
		If DbSeek(xFilial("ZZW")+_aBrw2[i][2])
		
			If Reclock("ZZW",.F.)
			    
				ZZW_SITUAC := "L"
				ZZW_STGRV  := ""
				ZZW_OBSZZW := _cMltGet
				
				MsUnlock()
			
			EndIf
			
			MsgInfo("Registro atualizado com sucesso.","Aten��o")
		
		EndIf
		
	EndIf
	
Next i		


If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 

_cQuery := " SELECT * "
_cQuery += " FROM "+RetSqlName("ZZW") 
_cQuery += " WHERE  D_E_L_E_T_ != '*' "
_cQuery += " AND    ZZW_SITUAC  = 'W' "
_cQuery += " AND    ZZW_STGRV   = '"+_cCbPesq+"' "
_cQuery += "ORDER BY R_E_C_N_O_"

TcQuery _cQuery New Alias _cAlias 

_aBrw2 := {}
	
//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  If(_aBrw2[oBrCrt:nAT,01],_oOk,_oNo),;
							   _aBrw2[oBrCrt:nAt,02],_aBrw2[oBrCrt:nAt,03],;
                               _aBrw2[oBrCrt:nAt,04],_aBrw2[oBrCrt:nAt,05]}}
	
While !("_cAlias")->(Eof())

		aAdd(_aBrw2,{ .F.,;				
					  ("_cAlias")->ZZW_NOTA,;
					  _cObs := Posicione("ZZW",2,xFilial("ZZW")+("_cAlias")->ZZW_NOTA,"ZZW_OBSDIG"),;
				      ("_cAlias")->ZZW_USER,;
					  Substr(("_cAlias")->ZZW_DATA,7,2)+"/" + Substr(("_cAlias")->ZZW_DATA,5,2) +"/"+Substr(("_cAlias")->ZZW_DATA,1,4)+" - "  + ("_cAlias")->ZZW_HORA})
				
	("_cAlias")->(DbSkip())
EndDo			

Return 