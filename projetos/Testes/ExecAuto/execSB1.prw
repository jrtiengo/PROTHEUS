#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

User Function execSB1()

	Local aVetor := {}
	private lMsErroAuto := .F.

//Abre Ambiente (não deve ser utilizado caso utilize interface ou seja chamado de uma outra rotina que já inicializou o ambiente)
	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"

//--- Exemplo: Inclusao --- //
	aVetor:= { {"B1_COD" ,"000000000000002" ,NIL},;
		{"B1_DESC" ,"TESTE" ,NIL},;
		{"B1_TIPO" ,"PA" ,Nil},;
		{"B1_UM" ,"UN" ,Nil},;
		{"B1_LOCPAD" ,"01" ,Nil}}

	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)

	If lMsErroAuto
		MostraErro()
	Else
		Alert("Ok")
	Endif

Return
