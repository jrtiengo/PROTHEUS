/*+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | F580ADDB  | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | PE que adiciona botões no browse dos titulos a serem liberados            |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado na rotina FINA580                                               |
+-----------+---------------------------------------------------------------------------+*/
USER FUNCTION F580ADDB()
   	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN aRotina
	end

    Aadd(aRotina,{ 'Conhecimento NF', "U_EVOA605()"   ,0,1,,.F.})
    Aadd(aRotina,{ 'Conhecimento Titulo', "U_F605BANCOSE2"   ,0,1,,.F.}) 
RETURN aRotina
