#Include 'Protheus.ch'
#include 'parmtype.ch'

User Function F040FCR()
PRIVATE aArray := {}
PRIVATE nValorTitulo     := 0.00
PRIVATE nPerDirArena     := Getmv( "ES_PERCARE" )  //Percentual do direito de arena
PRIVATE cNatDirArena     := Getmv( "ES_NATAREN")
PRIVATE cNatAB           := Getmv( "ES_NATDIRA")
PRIVATE nValorTituloOrig := 0.00
PRIVATE lMsErroAuto := .F.
PRIVATE E1Area := GetArea()

dbSelectArea("SE1")
dbSetOrder(1)
IF dbSeek(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA+'AB-')
   Alert(' AB- EXISTENTE -PREFIXO+NUM+PARCELA. VERIFICAR')
   RestArea(E1Area)
ELSE   
   	RestArea(E1Area)

	IF (ALLTRIM(E1_NATUREZ) $ ALLTRIM(cNatDirArena)) .AND. (E1_TIPO <> 'AB-') .AND. E1_SALDO > 0 //Se a natureza do titulo original e igual ao parametro ES_NATARENA
	
		Reclock("SE1",.F.)	
		nValorTituloOrig:= E1_VALOR
		nValorTitulo := (nPerDirArena * nValorTituloOrig) / 100
	
		dbSelectArea("SED")
	    dbSetOrder(1)
	    dbSeek(xFilial("SED")+E1_NATUREZ)  
    
	
		IF E1_ORIGEM=='CNTA120'
	 	  dbSelectArea("SE1")
	      dbSetOrder(1)
	      dbSeek(xFilial("SE1")+E1_PREFIXO+E1_NUM+E1_PARCELA+"DP")
	    ENDIF  
	
		aArray := { { "E1_FILIAL" , xFilial("SE1"), NIL },;
	    { "E1_PREFIXO"  , E1_PREFIXO              , NIL },;
		{ "E1_NUM"      , E1_NUM                  , NIL },;
		{ "E1_PARCELA"  , E1_PARCELA              , NIL },;
		{ "E1_TIPO"     , "AB-"                   , NIL },;
		{ "E1_NATUREZ"  , SED->ED_NATAB           , NIL },;
		{ "E1_CLIENTE"  , E1_CLIENTE              , NIL },;
		{ "E1_LOJA"     , E1_LOJA                 , NIL },;
		{ "E1_EMISSAO"  , E1_EMISSAO              , NIL },;
		{ "E1_VENCTO"   , E1_VENCTO               , NIL },;
		{ "E1_VENCREA"  , E1_VENCREA              , NIL },;
		{ "E1_HIST"     , "AB- AUTOMATICO"        , NIL },;
		{ "E1_VALOR"    , nValorTitulo            , NIL },;
		{ "E1_CREDIT"   , E1_CREDIT               , NIL },;
		{ "E1_CTACTB"   , E1_CREDIT               , NIL },;
		{ "E1_CTARENA"  , E1_CTACTB               , NIL },;
		{ "E1_CCCTB"    , E1_CCCTB                , NIL }}

	
		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
		If lMsErroAuto
			MostraErro()
		Else
			Alert("Título AB- incluído com sucesso!")
		Endif	
		MsUnlock()	
	Endif
Endif	
Return
//FISA021
