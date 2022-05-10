#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} ExecFunc
Executa uma chamada para a função informada sem precisar que a mesma esteja em menu.
@type function
@version 
@author Márcio Borges @marcioborgespro
@since 03/08/2011
@return return_type, return_description
/*/
User Function ExecFunc()


	Local cCodRec := Space(40)
	Local aRet     := {}
	Local aParamBox   := {}

	//Private lTransacao 	:= MSGYESNO("Deseja Ativar processamento com controle de transação ?")

	CursorWait()
	aAdd(aParamBox ,{1,"Função : ",cCodRec,"@!",'.T.',,'.T.',40,.F.})
	aAdd(aParamBox ,{3,"Executa",1,{"via '&'","via execblock"},50,"",.F.})
// Tipo 3 -> Radio
//           [2]-Descricao
//           [3]-Numerico contendo a opcao inicial do Radio
//           [4]-Array contendo as opcoes do Radio
//           [5]-Tamanho do Radio
//           [6]-Validacao
//           [7]-Flag .T./.F. Parametro Obrigatorio ?

	If ParamBox(aParamBox ,"Parametros ",aRet)

		If at("U_",MV_PAR01) > 0
			MV_PAR01 := SUBSTR(MV_PAR01, 1, AT("U_", MV_PAR01) + 2)
		EndIf
		If ExistBlock(MV_PAR01)
			RODA()
		Else
			MsgInfo("Função não encontrada",'Atenção')
		EndIf

	EndIf



Return()

/*/{Protheus.doc} RODA
Executa a função informada
@type function
@version 
@author solutio
@since 03/08/2020
@return return_type, return_description
/*/
Static Function RODA()
	Local aArea    := GetArea()

	Local cError   		:= ""
	Local bError   		:= ErrorBlock({|oError| cError := oError:Description})


	If (!Empty(MV_PAR01))

		If MV_PAR02 == 2
			&(Alltrim(MV_PAR01))
		Else

			//Begin Transaction

			//BEGIN SEQUENCE
			ExecBlock(Alltrim(MV_PAR01),.F.,.F.)
			//END SEQUENCE

			//End Transaction

			ErrorBlock(bError)

			If (!Empty(cError))
				MsgStop("Houve um erro na função digitada: " + CRLF + CRLF + cError, "Atenção")
			EndIf
		Endif
	EndIf


	RestArea(aArea)
Return (NIL)
