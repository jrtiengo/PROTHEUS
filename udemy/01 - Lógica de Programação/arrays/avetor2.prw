#include 'protheus.ch'
#include 'parmtype.ch'

user function AVETOR2()
	/**
		AADD() - Permite a inser��o de um item em um Array ja existente
		AINS() - Permite a inser��o de um elemento em qualquer posi��o do Array
		ACLONE() - Realiza a c�pia de um Array para outro
		ADEL() - Permite a exclus�o de um elemento do Array, tornando o ultimo valor NULL
		ASIZE() - Redefine a estrutura de um Array pr�-existente, adicionando ou removendo itens
		LEN() - Retorna a quantidade de elementos de um Array
	**/
    Local aVetor := {10,20,30}
    Local nCount

	// EXEMPLO AADD/LEN
	AaDd(aVetor, 40)
	Alert(Len(aVetor))
	
	//EXEMPLO AINS
	AIns(aVetor,2)
	aVetor[2] := 200
	Alert(aVetor[2])
	Alert(Len(aVetor))
	
	//EXEMPLO ACLONE
	aVetor2 := AClone(aVetor)
		for nCount := 1 To Len(aVetor2)
			Alert(aVetor2[nCount])
		
		Next nCount
	
	//EXEMPLO ADEL
	Adel(aVetor,2)
	Alert(aVetor[3])
	Alert(Len(aVetor))
	
	//EXEMPLO ASIZE
	Asize(aVetor,2)
	Alert(Len(aVetor))
	for nCount := 1 To Len(aVetor)
			Alert(aVetor[nCount])
		
		Next nCount
	
	
return
