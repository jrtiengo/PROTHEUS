#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
           
/*/{Protheus.doc} DEVTOOL2
	
	Retorna a lista de funcionalidades do DEVTOOLS
	
	Ponto de entrada onde lista pode ser modificado: DEVTOOL2
	
	@author  Fernando Alencar
	@version P11 e P10
	@since   15/09/2011
	@return  
	@obs     
	
/*/
User Function DEVTOOL2()

	Local aTools := {											;
		{"0.0.1","Atualização de dicionário"		,"DEVUPD"},	;
		{"0.0.2","Gerador de script"				,"DEVHEL01"},; //Helitom Silva 20-03-2012
		{"0.0.3","Processador de Comandos Advpl"    ,"DEVHEL02"};  //Helitom Silva 19-03-2012
	}

	If ExistBlock("DEVT0001")
		aTools := ExecBlock("DEVT0001",.F.,.F.,{aTools})
	EndIf
	
Return aTools