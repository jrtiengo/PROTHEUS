#Include "XmlXFun.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"  
/*+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA606   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | monitor de integracao de importacao de xml da nfs-e                       |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via menu ou job                                                 |
+-----------+---------------------------------------------------------------------------+
*/
User Function EVOA606()
Local cFiltro:= ""

Local aCores:= {{'ZZ1->ZZ1_STATUS == "1"', 'br_verde'},;
                {'ZZ1->ZZ1_STATUS == "2"', 'br_vermelho'}}
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN 
	end


Private cCadastro:= "Log de Integracao do XML da NFS-e"

Private aRotina:= {{"Pesquisar" , "axPesqui", 0, 1},;
                   {"Visualizar", "axVisual", 0, 2},;
                   {"Legenda"   , "u_EVO606BRW", 0, 2}}                   

dbSelectArea("ZZ1")
dbSetOrder(1)

mBrowse(,,,,"ZZ1",,,,,,aCores,,,,,,,,cFiltro)
Return



//---------------------------------------------------------
User Function EVO606BRW()
//---------------------------------------------------------
BrwLegenda(cCadastro,"Status:",	{{"br_verde" ,"Processado"	},;
                                 {"br_vermelho"	 ,"Nao Processado"	}})

Return nil
