#Include 'Protheus.ch'

User Function CN120ALT()
PRIVATE aArray := {}
PRIVATE aCab  := PARAMIXB[1] //Titulo Posicionado - [1][2]
PRIVATE cTipo := PARAMIXB[2]
    



/*IF (ALLTRIM(aCab[5][2])==ALLTRIM(cNatDirArena)) //Se a natureza do titulo original e igual ao parametro ES_NATARENA
	nValorTituloOrig:= aCab[12][2]
	nValorTitulo := (nPerDirArena * nValorTituloOrig) / 100 
   
    aArray := { { "E1_FILIAL"   , xFilial("SE1")        , NIL },;
    			{ "E1_PREFIXO"  , ALLTRIM(aCab[1][2])   , NIL },;
    	        { "E1_NUM"      , ALLTRIM(aCab[2][2])   , NIL },;
    	        { "E1_TIPO"     , "AB-"        , NIL },;
    			{ "E1_NATUREZ"  , ALLTRIM(cNatDirArena) , NIL },;
        	    { "E1_CLIENTE"  , ALLTRIM(aCab[6][2])   , NIL },;
            	{ "E1_LOJA"     , ALLTRIM(aCab[7][2])   , NIL },;
            	{ "E1_EMISSAO"  , aCab[9][2]   , NIL },;
            	{ "E1_VENCTO"   , aCab[10][2]   , NIL },;
            	{ "E1_VENCREA"  , aCab[11][2]  , NIL },;
            	{ "E1_VALOR"    , nValorTitulo , NIL } }
	MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
 
	If lMsErroAuto
    	MostraErro()
	Else
    	Alert("Título incluído com sucesso!")
	Endif
Endif*/
   
Return aCab