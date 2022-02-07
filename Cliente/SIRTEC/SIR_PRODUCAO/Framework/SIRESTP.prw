#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'


User Function SIRESTP


Private _aBrw2    := {}
Private _aHeadCrt := {}
Private _aColsCrt := {}
Private _oOk      := LoadBitmap(GetResources(), "LBOK")
Private _oNo      := LoadBitmap(GetResources(), "LBNO")
Private _oFC08    := TFont():New('Courier New',,-12,.F.)
Private _cData    := dDataBase
Private _nLinha   := 0



SetPrvt("oDlg1","oGrp1","oGrp2","oSay1","oSay2","oCBox1","oGet1","oBtn1","oBrw1")

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

oDlg1       := MSDialog():New(092,232,592,1167,"Estatistica diaria totalizado por equipe",,,.F.,,,,,,.T.,,,.T. )
oDlg1:bInit := {||EnchoiceBar(oDlg1,{|| fMrcCorte()},{|| oDlg1:End()},.F.,{})}
oGrp1       := TGroup():New(016,004,230,466,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGrp2       := TGroup():New(029,011,063,455,"",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1       := TSay():New(032,015,{||"Setor:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2       := TSay():New(032,099,{||"Data:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBox1      := TComboBox():New( 043,015,,,072,010,oGrp2,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oGet1       := TGet():New(043,099,{|u| If(PCount()>0 ,_cData:=u,_cData)},oGrp2,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1       := TButton():New(041,167,"Procurar",oGrp2,{|| FSeaCort()},078,012,,,,.T.,,"",,,,.F. )

//Array com os campos da grade de dados
_aHeadCrt   := {"Linha","Equipe",OemToAnsi("Funcionario"),"Programadas","Executadas","Pendentes","Liberadas","Rejeitadas","Sobra","Data Programação"}

//Criacao do objeto ListBox
oBrCrt      := TCBrowse():New(078,011,445,150,,_aHeadCrt,_aColsCrt,oGrp1,,,,,{||},,_oFC08,,,,,.F.,,.T.,,.F.,,,)

Aadd(_aBrw2,{"","","",0,0,0,0,0,0,""})	

//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  _aBrw2[oBrCrt:nAt,01],_aBrw2[oBrCrt:nAt,02],;
							_aBrw2[oBrCrt:nAt,03],_aBrw2[oBrCrt:nAt,04],;
                            _aBrw2[oBrCrt:nAt,05],_aBrw2[oBrCrt:nAt,06],_aBrw2[oBrCrt:nAt,07],;
                            _aBrw2[oBrCrt:nAt,08],_aBrw2[oBrCrt:nAt,09],_aBrw2[oBrCrt:nAt,10]}}

oDlg1:Activate(,,,.T.)

Return

Static Function FSeaCort

Local _cQuery  := "" 
Local _cQryAux := ""
Local _cMunOr  := ""
Local _cAlias  := GetNextAlias()
Local _cAlAux  := GetNextAlias()
Local _aDados  := {}
Local _nEquipe := 0
Local _nExec   := 0
Local _nPenden := 0
Local _nLib    := 0
Local _nRej    := 0
Local _nSobra  := 0



_nLinha := 0

If Empty(_cData) 
	Return
EndIf 

If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 

_cQuery := " SELECT DISTINCT(ZZU_EQUIP),      " 
_cQuery += "        COUNT(ZZU_NOTA) AS QTDADE "
_cQuery += " FROM "+RetSqlName("ZZU") 
_cQuery += " WHERE  D_E_L_E_T_ != '*'    "
_cQuery += " AND    ZZU_DATPRG  = '"+Dtos(_cData)+"'"
_cQuery += " GROUP BY ZZU_EQUIP "  

TcQuery _cQuery New Alias _cAlias

//-> array contendo equipes e o total de notas programadas de acordo com a data
While !("_cAlias")->(Eof())
	
	aAdd(_aDados,{("_cAlias")->ZZU_EQUIP,("_cAlias")->ZZU_EQUIP,("_cAlias")->QTDADE,0,0,0,0,0})

	("_cAlias")->(DbSkip())
EndDo

For I := 1 to Len(_aDados)

	If Select("_cAlAux") > 0
		("_cAlAux")->(DbClosearea())
	EndIf 
	
	_cQryAux := " SELECT *      " 
	_cQryAux += " FROM "+RetSqlName("ZZW") 
	_cQryAux += " WHERE  D_E_L_E_T_ != '*'    "
	_cQryAux += " AND    ZZW_EQUIP  = '"+_aDados[I,1]+"'"
	_cQryAux += " AND 	ZZW_DATA = '"+Dtos(_cData)+"'"
	
	TcQuery _cQryAux New Alias _cAlAux
	
	While !("_cAlAux")->(Eof())
	
		Do Case
		
			Case ("_cAlAux")->ZZW_RETSTA == "E"
				_nExec++ 
			
			Case ("_cAlAux")->ZZW_RETSTA == "L"
				_nLib++
			
			Case ("_cAlAux")->ZZW_RETSTA == "R"
				_nRej++
			
			Case ("_cAlAux")->ZZW_RETSTA == "S"
				_nSobra++
		
		EndCase
	
		("_cAlAux")->(DbSkip())
	EndDo 	
	
	_nPenden     := _aDados[I,3] - _nExec - _nRej - _nSobra - _nLib 

	_aDados[I,4] := _nExec 
	_aDados[I,5] := _nPenden
	_aDados[I,6] := _nLib
	_aDados[I,7] := _nRej
	_aDados[I,8] := _nSobra	
	
	_nExec       := 0
	_nPenden     := 0
	_nLib        := 0
	_nRej        := 0
	_nSobra      := 0	
	
Next I
	
_aBrw2 := {}
	
//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  _aBrw2[oBrCrt:nAt,01],_aBrw2[oBrCrt:nAt,02],;
							_aBrw2[oBrCrt:nAt,03],_aBrw2[oBrCrt:nAt,04],;
                            _aBrw2[oBrCrt:nAt,05],_aBrw2[oBrCrt:nAt,06],_aBrw2[oBrCrt:nAt,07],;
                            _aBrw2[oBrCrt:nAt,08],_aBrw2[oBrCrt:nAt,09],_aBrw2[oBrCrt:nAt,10]}}

For _nX := 1 To Len(_aDados)
		
		_nLinha++
		
	    _cNome := Posicione("ZZ4",1,xFilial("ZZ4")+_aDados[_nX,1],"ZZ4_NOMETC")//Posicione("ZZS",1,xFilial("ZZS")+_aDados[_nX,1],"ZZS_RESP")
		
       //                 1         2             3            4            5           6            7          8         9       
       //_aHeadCrt := {"Linha","Funcionario","Programadas","Executadas","Pendentes","Liberadas","Rejeitadas","Sobra","Data Programação"}

		aAdd(_aBrw2,{_nLinha,;         //->1
					_aDados[_nX,1],;   //->2
		             AllTrim(_cNome),; //->3
		             _aDados[_nX,3],;  //->4
		             _aDados[_nX,4],;  //->5
		             _aDados[_nX,5],;  //->6
		             _aDados[_nX,6],;  //->7
		             _aDados[_nX,7],;  //->8
		             _aDados[_nX,8],;  //->9
		             _cData})          //->10
				
Next _nX					
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IGCO501C  ºAutor  ³Microsiga           º Data ³  02/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fMrcCorte()

Local _nLin     := oBrCrt:nAt
Local _aBrw1    := {}
Local _aHead    := {}
Local _aCols    := {}
Local _nLinEst  := 0
Local _cNomEqp  := ""
Local _cQryDet  := ""
Local _cPrazo   := ""
Local _cStatus  := ""
Local _cString  := ""
Local _cAlDet   := GetNextAlias()

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/                                                                          

_cCodEqp    := Posicione("ZZ4",1,xFilial("ZZ4")+_aBrw2[_nLin,2],"ZZ4_EQUIPE")//Posicione("ZZS",2,xFilial("ZZS")+_aBrw2[_nLin,2],"ZZS_CODIGO")

If Select("_cAlDet") > 0
	("_cAlDet")->(DbClosearea())
EndIf 

_cQryDet := " SELECT ZZU_NOTA,      "
_cQryDet += "        ZZU_MUN,       "
_cQryDet += "        ZZU_BAIRRO,    " 
_cQryDet += "        ZZU_VENC       " 
_cQryDet += " FROM "+RetSqlName("ZZU") 
_cQryDet += " WHERE  D_E_L_E_T_ != '*'    "
_cQryDet += " AND    ZZU_EQUIP   = '"+_cCodEqp+"'"
_cQryDet += " AND    ZZU_DATPRG  = '"+Dtos(_cData)+"'"

TcQuery _cQryDet New Alias _cAlDet

While !("_cAlDet")->(Eof())

	_nLinEst++
			
	If SToD(("_cAlDet")->ZZU_VENC) >= dDataBase
		_cPrazo := "No Prazo"
	Else
		_cPrazo := "Fora de Prazo"
	EndIf
	
	_cStatus := Posicione("ZZW",2,xFilial("ZZW")+("_cAlDet")->ZZU_NOTA,"ZZW_RETSTA") 
	
	Do Case
	
			Case _cStatus == "E"
				_cString := "Executada"	 
			
			Case _cStatus == "P"
				_cString := "Pendente"	
			
			Case _cStatus == "L"
				_cString := "Liberada"	
			
			Case _cStatus == "R"
				_cString := "Rejeitada"	
			
			Case _cStatus == "S"
				_cString := "Sobra"
			
			OtherWise
				_cString := "Programada"	
	
	EndCase

	aAdd(_aBrw1,;
			{_nLinEst,;             //->1
             ("_cAlDet")->ZZU_NOTA,;    //->2
             ("_cAlDet")->ZZU_MUN,;     //->3
             ("_cAlDet")->ZZU_BAIRRO,;  //->4
             Substr(("_cAlDet")->ZZU_VENC,7,2)+"/" + Substr(("_cAlDet")->ZZU_VENC,5,2) +"/"+Substr(("_cAlDet")->ZZU_VENC,1,4),;    //->5
             _cPrazo,;                  //->6
             "",;                       //->7
             "",;                       //->8
             _cString}) 

	("_cAlDet")->(DbSkip())
EndDo

oRotD       := MSDialog():New(092,232,592,1167,"Roteiro detalhado",,,.F.,,,,,,.T.,,,.T. )
oRotD:bInit := {||EnchoiceBar(oRotD,{|| oRotD:End()},{|| oRotD:End()},.F.,{})}
oGRotD      := TGroup():New(016,004,230,466,"",oRotD,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGRot2      := TGroup():New(029,011,063,455,"",oGRotD,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay3       := TSay():New(032,015,{||"Funcionario:"+_aBrw2[_nLin,2]},oGRot2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oSay4       := TSay():New(032,200,{||"Data:"+DToC(_cData)},oGRot2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)

//Array com os campos da grade de dados
_aHead := {"Linha","N°Nota","Municipio","Bairro","Data Limite","Prazo","Recebimento PDA","Hora Execução","Status"} 

//Criacao do objeto ListBox
oBrRotS    := TCBrowse():New(078,011,445,150,,_aHead,_aCols,oGRotD,,,,,{||},,_oFC08,,,,,.F.,,.T.,,.F.,,,)

//Seta o array da listbox
oBrRotS:SetArray(_aBrw1)  

//atualiza a grade de dados
oBrRotS:bLine      := {|| { _aBrw1[oBrRotS:nAt,01],;
							_aBrw1[oBrRotS:nAt,02],_aBrw1[oBrRotS:nAt,03],;
                            _aBrw1[oBrRotS:nAt,04],_aBrw1[oBrRotS:nAt,05],_aBrw1[oBrRotS:nAt,06],;
                            _aBrw1[oBrRotS:nAt,07],_aBrw1[oBrRotS:nAt,08],_aBrw1[oBrRotS:nAt,09]}}

oRotD:Activate(,,,.T.)

Return