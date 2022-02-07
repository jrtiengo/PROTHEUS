#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
           
/*{Protheus.doc} DEVUPD
	
	Ferramenta de atualização do dicionário
	
	TODO verifica acesso exclusivo
	TODO - browse de opções (seleciona dicionários, opção recriar tabelas)
	browser para selecionar as empresas
	executar
	exibe log com opção de salvar
	
	@developer	Fernando Alencar
	@version 	P11 e P10
	@since   	20/11/2011
	@author  	Fernando Alencar - fernando.alencar@totvs.com.br
	@return  
	@obs     
	
*/
User Function DEVUPD()
	
	Local aEmpresas 	:= {}
	Local aData 		:= {}
	
	Private oLog := UPDLOG():CREATE("start")
	
	U_FCONECT('99', '01')
	
	aEmpresas 	:= U_DEVUPD0()
	aData		:= U_DEVUPD1(aEmpresas, "TSTUPD01")
	
Return Nil