#include 'protheus.ch'

/*/{Protheus.doc} MA650EMP
//TODO passa por todas as ops intermediáriars e por ultimo cria a OP PAI.
@author solutio02
@since 30/09/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MA650EMP  

If Type("aOPEMP") == 'U' //OP´s Empenhadas
		//Cria variável publica no contexto do MATA650
		_SetNamedPrvt("aOPEMP",{},"MATA650")
Endif

If Type("aOPEMP") <> 'U'
	IF SC2->C2_SEQUEN == '001'
		AADD(aOPEMP,SC2->C2_NUM )
	ENDIF
Endif	
Return Nil
