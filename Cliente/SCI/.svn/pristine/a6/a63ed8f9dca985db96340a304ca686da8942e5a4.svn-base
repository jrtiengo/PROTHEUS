/*=================================================================================================
* Programa...: MT103IPC.PRW  -  (chamado pelo MATA103)
* Descricao..: Ponto de Entrada na confirmacao do PC pela teclas F5 e F6
* Obs........: grava a descricao do item da nota, baseado no pedido de compra 
* Autor......: Valdir Pereira  
* Data.......: Jan/2008
*--------------------------------------------------------------------------------------------------
*/

#Include "RwMake.Ch"
#Include "Protheus.Ch"

User Function MT103IPC()

Local nPosDescri := 0,i

For i:=1 to Len(aHeader)
	cCampo:=Alltrim(aHeader[i,2])
	If cCampo == "D1_DESCR"
		nPosDescri  := i
	Endif
Next

aCols[ParamIxb[1],nPosDescri] := ALLTRIM(SC7->C7_DESCRI)

Return (.t.)
