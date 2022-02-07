#Include 'Protheus.ch'

#DEFINE	CR	Chr(13) + Chr(10)

/*{Protheus.doc} RUNUPDPE
	
@author Helitom Silva
@since 24/12/2013
@version 1.0		

@return ${Nil}, ${Nil}

@description Ponto de Entrada do programa U_RUNUPD e é usado para carregar o Combobox de 
             seleção dos Grupos dos compatibilizadores que deseja executar,
             retornando um Array unidimensional com o Grupo e Descrição.
             
             Caso e se PE nao existe será exibido um campo para informar o nome do Grupo de 
             compatibilizadores.

*/
User Function RUNUPDPE()
	
	Local aGrupos := {}
	
	//A cada item do Array de ser informado: {Grupo=Descrição do Grupo}
	//Grupo é a função que chama os compatibilizadores.
	//Exemplo: aGrupos := {'UPD001=Compatibilizadores do UPD001','UPD002=Compatibilizadores do UPD001','UPD002=Compatibilizadores do UPD001'}
	
	aGrupos := {'AFPUPD=Compatibilizadores Sirtec'}
	
Return aGrupos