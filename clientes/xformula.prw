/*/{Protheus.doc} xFormula
//Rotina para execucao de funcoes dentro do Protheus (rotina de formulas descontinuada no Protheus)
@author Celso Rene
@since 12/04/2018
@version 1.0
@type function
/*/

User Function xFormula()
	
	//Declaracao de variaveis
	Local bError 
	Local cGet1Frm := PadR("Ex.: u_NomeFuncao() ", 30)
	Local oDlg1Frm := Nil
	Local oSay1Frm := Nil
	Local oGet1Frm := Nil
	Local oBtn1Frm := Nil
	Local oBtn2Frm := Nil
	
	//Recupera e/ou define um bloco de codigo para ser avaliado quando ocorrer um erro em tempo de execucao.
	bError := ErrorBlock( {|e| cError := e:Description } ) //, Break(e) } )
	
	//Inicia sequencia
	BEGIN SEQUENCE
	
		//Construcao da interface
		oDlg1Frm := MSDialog():New( 091, 232, 225, 574, "Formulas" ,,, .F.,,,,,, .T.,,, .T. )
		
		//Rotulo 
		oSay1Frm := TSay():New( 008 ,008 ,{ || "Informe a sua funcao aqui:" } ,oDlg1Frm ,,,.F. ,.F. ,.F. ,.T. ,CLR_BLACK ,CLR_WHITE ,084 ,008 )
		
		//Campo
		oGet1Frm := TGet():New( 020 ,008 ,{ | u | If( PCount() == 0 ,cGet1Frm ,cGet1Frm := u ) } ,oDlg1Frm ,150 ,008 ,'!@' ,,CLR_BLACK ,CLR_WHITE ,,,,.T. ,"" ,,,.F. ,.F. ,,.F. ,.F. ,"" ,"cGet1Frm" ,,)
		
		//Botoes
		oBtn1Frm := TButton():New( 045 ,010 ,"Executar" ,oDlg1Frm ,{ || &(cGet1Frm)    } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		oBtn2Frm := TButton():New( 045 ,125 ,"Sair"     ,oDlg1Frm ,{ || oDlg1Frm:End() } ,037 ,012 ,,,,.T. ,,"" ,,,,.F. )
		
		//Ativacao da interface
		oDlg1Frm:Activate( ,,,.T.)
	
	RECOVER
		
		//Recupera e apresenta o erro
		ErrorBlock( bError )
		MsgStop( cError )
		
	END SEQUENCE
	
Return()
