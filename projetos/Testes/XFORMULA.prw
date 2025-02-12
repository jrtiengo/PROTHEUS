#INCLUDE 'PROTHEUS.ch'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} xFormula
//Rotina para execucao de funcoes dentro do Protheus (rotina de formulas descontinuada no Protheus)
@author Celso Rene
@since 12/04/2018
@version 1.0
@type function
/*/

User Function xFormula()
	
	//Declaracao de variaveis
	Local oError	:= ErrorBlock({|e| MsgAlert("Mensagem de Erro: " + Chr(13)+Chr(10) + e:Description)})
	//Local cError	:= ""
	Local cGet1Frm	:= PadR("Ex.: u_NomeFuncao() ", 30)
	Local oDlg1Frm	:= Nil
	Local oSay1Frm	:= Nil
	Local oGet1Frm	:= Nil
	Local oBtn1Frm	:= Nil
	Local oBtn2Frm	:= Nil
	
	//Recupera e/ou define um bloco de codigo para ser avaliado quando ocorrer um erro em tempo de execucao.
	//oError := ErrorBlock( {|e| cError := e:Description } ) //, Break(e) } )
	
	//Inicia sequencia
	BEGIN SEQUENCE
	
		//Construcao da interface
		oDlg1Frm := MSDialog():New( 091, 232, 225, 574, "Formulas" ,,, .F.,,,,,, .T.,,, .T. )
		
		//Rotulo 
		oSay1Frm := TSay():New( 008 ,008 ,{ || "Informe a sua funcao aqui:" } ,oDlg1Frm ,,,.F. ,.F. ,.F. ,.T. ,CLR_BLACK ,CLR_WHITE ,084 ,008 )
		
		//Campo
		oGet1Frm := TGet():New( 020 ,008 ,{ | u | If( PCount() == 0 ,cGet1Frm ,cGet1Frm := u ) } ,oDlg1Frm ,150 ,008 ,'!@' ,,CLR_BLACK ,CLR_WHITE ,,,,.T. ,"" ,,,.F. ,.F. ,,.F. ,.F. ,"" ,"cGet1Frm" ,,)
		
		//Botoes
		//oBtn1Frm := TButton():New( 045 ,010 ,"Executar" ,oDlg1Frm ,{ || &("U_"+cGet1Frm)    } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		oBtn1Frm := TButton():New( 045 ,010 ,"Executar" ,oDlg1Frm ,{ || &(xFormulaA(cGet1Frm))    } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		oBtn2Frm := TButton():New( 045 ,125 ,"Sair"     ,oDlg1Frm ,{ || oDlg1Frm:End() } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		
		//Ativacao da interface
		oDlg1Frm:Activate( ,,,.T.)
	
	RECOVER
		
		//Recupera e apresenta o erro
		ErrorBlock( oError )
		//MsgStop( cError )
		
	END SEQUENCE
	
Return()


Static Function xFormulaA(_cGet)

	Local _cRet := ""

	If Upper(Substr(Alltrim(_cGet),1,2)) <> "U_"

		_cRet := "U_" + Alltrim(_cGet)

	Else

		_cRet := _cGet

	EndIf

	If Substr(Alltrim(_cRet),Len(Alltrim(_cRet)),1) <> ")"

		_cRet := Alltrim(_cRet) + "()"

	EndIf



Return(_cRet)

