#include 'protheus.ch'
#include 'parmtype.ch'

user function vldemail()

local nCont := 1
local lRet   := .T.
local nResto := 0
Local cMens := ""
Local cEmail := ""

IF INCLUI .OR. ALTERA
	If Upper(FUNNAME( ))=="MATA030" .or. Upper(FUNNAME( ))=="MATA103"
	   cEmail := M->A1_EMAIL
	   cNome  := M->A1_NOME
	ELSEIF Upper(FUNNAME( ))=="MATA020" .OR. Upper(FUNNAME( ))=="SI001COM"							
	   cEmail := M->A2_EMAIL
	   cNome  := M->A2_NOME
	ELSEIF Upper(FUNNAME( ))=="MATA040"
	   cEmail := M->A3_EMAIL
	   cNome  := M->A3_NOME
	ELSEIF Upper(FUNNAME( ))=="MATA050"
	   cEmail := M->A4_EMAIL
	   cNome  := M->A4_NOME
	Endif

	cMens := "Todo E-mail tem que ter (@) e terminar com (.com) ou (.com.br)."+Chr(10)+Chr( 13)+" "
	cMens += +Chr(10)+Chr( 13)+"Exemplo:"+Chr(10)+Chr( 13)+"========"+Chr(10)+Chr( 13)
	cMens += +space(02)+"vendas@superfinishing.com.br"+Chr(10)+Chr( 13)+space( 02)+"fulano@email.com"
	cMens += +Chr(10)+Chr( 13)+" "+Chr(10)+Chr( 13)+"Foi digitado (("+alltrim(cEmail) +"))"

	If cEmail $ " {}()<>[]|\/&*$%?!^~`,;:= #"
		APMSGALERT(cMens,"Atencao !!! - E-mail invalido ...")
		lRet := .F. //.F.
	else
		if ( nResto := at( "@", cEmail )) > 0 .and. at( "@", right( cEmail, len( cEmail ) - nResto )) == 0
		     if ( nResto := at( ".", right( cEmail, len( cEmail ) - nResto ))) > 0
		        lRet := .T.
		     else
		        APMSGALERT(cMens,"Atencao !!! - E-mail invalido ...")
		        lRet := .F.
		    endif
		else
		     APMSGALERT(cMens,"Atencao !!! - E-mail invalido ...")
		     lRet := .F.
		endif
	endif

	IF lRet
		//Verifica se o e-mail pode ser Sirtec ou não
		IF "SIRTEC" $ UPPER(cNome).OR. "SINO E" $ UPPER(cNome) .OR. "SIRTECOM" $ UPPER(cNome)
			//Verifico se o email contém @sirtec.com.br
			IF "@sirtec.com.br" $ cEmail
				lRet := .t.
			ELSE
				APMSGALERT("E-mail informado não é @sirtec.com.br . ","Atencao !!! - Verificar E-mail ...")
				lRet := .t. //mas mesmo assim permite a inclusão
			ENDIF
		ELSE
			IF "@sirtec.com.br" $ cEmail
				APMSGALERT("E-mail informado não pode conter @sirtec.com.br . ","Atencao !!! - Verificar E-mail ...")
				lRet := .f.
			ELSE
				lRet := .t.
			ENDIF
		ENDIF
	ENDIF

Endif

return lRet