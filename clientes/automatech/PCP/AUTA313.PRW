#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"                                      

#INCLUDE "COLORS.CH"
#DEFINE  ENTER CHR(13)+CHR(10)

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTA313.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Cesar Mussi                                                         ##
// Data......: 26/06/2014                                                          ##
// Objetivo..: Cadastro de Metragem Linear pela combinacao de Tubete x             ##
// Parâmetros: Sem Parâmetros                                                      ##
// ##################################################################################

User Function AUTA313()

   // ##########################
   // Declaracao de Variaveis ##
   // ##########################

   Private cCadastro := "Cadastro de Metr.Linear p/Tubete x Classe MP"
   
   // #########################################################################################################
   // aRotina padrao. Utilizando a declaracao a seguir, a execucao da MBROWSE sera identica a da AXCADASTRO: ##                             
   //                                                                                                        ##
   // cDelFunc  := ".T."                                                                                     ##
   // aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;                                                  ##
   //                { "Visualizar"   ,"AxVisual" , 0, 2},;                                                  ##
   //                { "Incluir"      ,"AxInclui" , 0, 3},;                                                  ##
   //                { "Alterar"      ,"AxAltera" , 0, 4},;                                                  ##
   //                { "Excluir"      ,"AxDeleta" , 0, 5} }                                                  ##
   //                                                                                                        ##
   // #########################################################################################################

   // ###########################
   // Monta um aRotina proprio ##
   // ###########################
   Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
                        {"Visualizar","AxVisual",0,2} ,;
                        {"Incluir","AxInclui",0,3} ,;
                        {"Alterar","AxAltera",0,4} ,;
                        {"Excluir","AxDeleta",0,5} }

   // Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

   Private cString := "ZP1"

   dbSelectArea("ZP1")
   dbSetOrder(1)

   dbSelectArea(cString)
   mBrowse( 6,1,22,75,cString)

Return

// ################################################################
// Função que calcula a quantidade etiquetas por rolo e valida a ##
// quantidade de etiquetas digitadas no pedido de venda          ##
// ################################################################ 
User Function VldQtEtq(p1,p2,p3,p4)

   // #########################
   // p1 = Codigo do Produto ##
   // p2 = Quantidade do PV  ##
   // p3 = Local do Produto  ##
   // p4 = Cond Pagamento    ##
   // #########################
   Local _aArea   := GetArea()
   Local _cCod    := p1
   Local _cLocal  := ""
   Local _nqtdven := p2
   Local _aRet1   := {}
   Local oRadio
   Local nRadio   := 1
   Local _aItens  := {}
   Local oFont
   Local _Desc    := ""
   Local _lRet    := .t. 
   Local _cCondPg := p4
   Local _nQtdMin := 1	// Quantidade Minima de venda
   
   // Public __lQtdExata := .F.

   // ##########################################################################################################################
   // Somente irá abrir a tela de seleção de quantidades para grupos de usuários diferente de 000004, 000022, 000029 e 000035 ##
   // ##########################################################################################################################
   PswOrder(2)

   If PswSeek(cUserName,.F.)

      // ###################################
      // Obtém o resultado conforme vetor ##
      // ###################################
      _aRetUser := PswRet(1)

      // ########################################
      // Carrega o código do grupo do usuário  ##
      // ########################################
      If Len(_aRetUser[1][10]) <> 0
         If Len(_aRetUser[1][10]) == 0
            kGrupo := ""
         Else   
            kGrupo := _aRetUser[1][10][1]
         Endif    
      Else
         kGrupo := ""       
      Endif
   Else
      kGrupo := ""       
   Endif      

   // ###################################################################################################
   // Este teste foi colocado aqui porque o tamanho da condição no cadastro de gatilho é muito pequeno ##
   // ###################################################################################################
   If kGrupo$("000004#000022#000029#000035")
   Else

      // If (cEmpAnt == "01" .And. cFilAnt == "04") .Or. (cEmpAnt == "03" .And. cFilAnt == "01") .Or. (cEmpAnt == "01" .And. cFilAnt == "07")         

      If (LEFT(_cCod,2) == "02" .Or. LEFT(_cCod,2) == "03")

         SB1->(DbSeek(xFilial("SB1")+_cCod))

         _cUM 	 := SB1->B1_UM
         _cMp 	 := SB1->B1_MPCLAS
         _Desc	 := SB1->(B1_DESC+B1_DAUX)
         _cLocal := SB1->B1_LOCPAD

         IF _nqtdven = 0 .and. (Left(_cCod,2) == "02" .Or. Left(_cCod,2) == "03")
      	    _lRet := .F.
	        _nqtdven := 0
         ENDIF

         IF _lRet .and. EMPTY(_cMp) .and. (Left(_cCod,2) == "02" .Or. Left(_cCod,2) == "03")
   	        ALERT("Falta cadastrar Classe de MP no produto ! Avise o PCP, passando o codigo da etiqueta ! ")
   	        _lRet := .F.
   	        _nqtdven := 0
         ENDIF

         IF _lRet .and. _cUM <> "RL" .and. (Left(_cCod,2) == "02" .Or. Left(_cCod,2) == "03") .and. _cCondPg <> "099"
	
	        _aRet1   := U_CALCMETR(_cCod)

            // ###############################
	        // 1 = Metragem Linear por rolo ##
	        // 2 = Qtd Etoquetas por rolo   ##
	        // 3= Tubete                    ##
	        // ###############################
    
            _nQtdMin := _aRet1[2]	// Qtd Minima de venda é igual a qtd de etiq de 1 rolo
	            
	        IF _cUM == "MI"
	           _nQtdVen := _nQtdVen*1000
               _nQtdMin := _nQtdMin/1000	// Qtd Minima de venda é igual a qtd de etiq de 1 rolo
	        ENDIF

	        _nRolos    := _nQtdVen / _aRet1[2]
	        _nRolosMin := INT(_nQtdVen / _aRet1[2])
	        _nRolosMax := INT(_nQtdVen / _aRet1[2])+1
	
	        aAdd(_aItens, TRANSFORM(_nRolosMin *_aRet1[2],"@R 999,999")+" Etq / "+TRANSFORM(_nRolosMin,"@R 999,999")+ " RL ")
	        aAdd(_aItens, TRANSFORM(_nRolosMax *_aRet1[2],"@R 999,999")+" Etq / "+TRANSFORM(_nRolosMax,"@R 999,999")+ " RL ")
	
	        IF _nRolos <>  _nRolosMin
		
		       DEFINE FONT oFont     Name "Arial"    Size 0, -14 BOLD
		       DEFINE FONT oArial14  Name "Arial14"  Size 0, 14
		       DEFINE FONT oArial14b Name "Arial14b" Size 0, 14 BOLD
		       DEFINE FONT oArial16  Name "Arial16"  Size 0, 16
		       DEFINE FONT oArial18b Name "Arial18b" Size 0, 18 BOLD
		       DEFINE FONT oArial18  Name "Arial18"  Size 0, 18
		       DEFINE FONT oArial12  Name "Arial12"  Size 0, 12 
		       DEFINE FONT oFont2    Name "Arial14"  Size 0, 14 BOLD
		    
               // ##################### 
		       // Qtde com diferença ##
		       // #####################
		       DEFINE MSDIALOG oDlgEtiq TITLE "Quantidade Etiquetas x No.Tubetes" FROM 0,0 TO 20,70 FONT oArial14 OF oMainWnd COLOR CLR_WHITE, CLR_BLACK
		
		       DEFINE SBUTTON oBut1 FROM 110,130 TYPE 01 ENABLE OF oDlgEtiq PIXEL ACTION oDlgEtiq:End()
		       @ 05,05 Say "Produto       : ["+alltrim(_cCod)+"] "+_Desc                                             FONT oArial14  PIXEL OF ODlgEtiq COLOR CLR_HBLUE, CLR_WHITE
		       @ 15,05 Say "Classe de MP  : ["+_cMp          +"] "+TABELA("ZP",_cMp     ) 							 FONT oArial14  PIXEL OF ODlgEtiq COLOR CLR_HBLUE, CLR_WHITE
		       @ 25,05 Say "Tubete        : ["+ALLTRIM(_aRet1[3])+"] "+TABELA("ZQ",_aRet1[3]) 					     FONT oArial14  PIXEL OF ODlgEtiq COLOR CLR_HBLUE, CLR_WHITE
		                 
		       @ 38,05 Say "A quantidade de etiquetas pedida, "+Transform(_nQtdVen,"@R 999,999")+" Etiquetas, não"   FONT oArial18  PIXEL OF ODlgEtiq COLOR CLR_HRED, CLR_WHITE
		       @ 45,05 Say "confere com MULTIPLOS da Quantidade de Etiquetas por rolo"                               FONT oArial18  PIXEL OF ODlgEtiq COLOR CLR_HRED, CLR_WHITE
	   
		       @ 65,05 Say "Etiq p/Tubete : "+TRANSFORM(_aRet1[2],"@R 99,999") 								         FONT oArial18b PIXEL OF ODlgEtiq COLOR CLR_HBLUE, CLR_WHITE
		       @ 75,05 Say "Escolha uma das opções abaixo, de multiplos aptos a serem produzidos !"                  FONT oArial18b PIXEL OF ODlgEtiq COLOR CLR_HBLUE, CLR_WHITE
		
		       oRadio:= tRadMenu():New(85,60,_aItens,{|u|if(PCount()>0,nRadio:=u,nRadio)},oDlgEtiq,,,,,,,,100,20,,,,.T.)
		
		       ACTIVATE MSDIALOG oDlgEtiq CENTERED
		
   	        ELSE
		       // Qtd Fechou
	        ENDIF
		
	        _nqtdven := VAL(STRTRAN(_aItens[nradio],",",""))/IIF(_cUm=="MI",1000,1)	
	
	        //__lQtdExata := Iif(M->ADY_QEXAT <> "S",.F.,.T.)
	
	        If (! U_TemEstoque(_cCod,_cLocal,_nqtdven))
		       If ( _nqtdven < _nQtdMin ) //Quantidade Minima de Venda –  Etq
		          MsgAlert("Atenção, a quantidade mínima de venda para este produto é "+TRANSFORM(_nQtdMin,"@R 999,999.99")+" mil etiquetas")
			      _nqtdven := 0	
		       EndIf
	        EndIf
         ENDIF

         RestArea(_aArea)

      Endif
      
   Endif   

Return(_nqtdven)

// #####################################
// Função que calcula Metros Lineares ##
// #####################################
User Function CalcMetr(p1)
      
   // #####################################################################################################
   // Cálculo da Quantidade por Rolo (Tubete)                                                            ##
   // ((Metragem Linear em metros * 1000) / (h da Etiqueta + Espaçamento em mm ))*No.Colunas             ##
   // Arredondamento : ficou definido que o arredondamento será feito nas DEZENAS no numero, para baixo. ##
   // Calculo : substr(ALLTRIM(STR(nValor,14,0)),1,(Len(ALLTRIM(STR(nValor,14,0)))-1))+"0"*/             ##
   // #####################################################################################################
   Local _aArea    := GetArea()
   Local _aRet     := {}
   Local _cCodProd := p1
   Local _nMetros  := 0
   Local _cMpClas  := ""
   Local _cCodTub  := ""
   Local _cDiamTub := ""
   Local _nH       := 0
   Local _nL       := 0
   Local _nC       := 0
   Local _nEspEtq  := SuperGetMv("MV_ESPETQ",,3)       // Espaçamento entre etiquetas em mm
   Local _cEspMp   := SuperGetMv("MV_ESPMP",,"01")     // Classes de MP que possuem espaçamento entre etiquetas

   Local cSql := ""

   // ####################################################################
   // Buscar nas Caracteristicas o Tubete.. relacionar com a tabela ZQ. ##
   // ####################################################################
   _cDiamTub := U_BuscaCar(_cCodProd,"TUB")

   // ############################
   // Aqui o calculo da Sanfona ##
   // ############################

   // ##################################
   // Busca no SX5 o codigo do Tubete ##
   // ##################################
   DbSelectArea("SX5")
   DbSeek(xFilial("SX5")+"ZQ")
   Do While SX5->X5_FILIAL+SX5->X5_TABELA == (xFilial("SX5")+"ZQ")
	  If STRTRAN(ALLTRIM(_cDiamTub),".",",") $ STRTRAN(ALLTRIM(SX5->X5_DESCRI),".",",")
		 _cCodTub:= SX5->X5_CHAVE
		 Exit
	  ENDIF
	  SX5->(DbSkip())
   Enddo
                 
   // #############################################################
   // Verifica se o produto tem exceção a regra de calculo (SB5) ##
   // #############################################################
   DbSelectArea("SB5")
   DbSetOrder(1)
   DbSeek(xFilial("SB1")+_cCodProd)

   // ##############################################
   // TODO veriricar se campos posuem valor Lucas ##
   // ##############################################
   IF FOUND()
	
      aAdd(_aRet,SB5->B5_MLRL) 			// Metragem por tubete
	  aAdd(_aRet,SB5->B5_ETQRL)          // Quantidade de Etiquetas por tubete
	  aAdd(_aRet,_cCodTub)
	
   ELSE
	  
	  // ####################################### 
	  // Buscar no SB1 a Classe MP do Produto ##
	  // #######################################
  	  SB1->(DbSeek(xFilial("SB1")+_cCodProd))

	  IF SB1->(FOUND())

		 _cMpClas := SB1->B1_MPCLAS

		 IF _cMpClas $ ALLTRIM( _cEspMp )
		 
			// ########################################################################################################################
			// Se a Classe de MP do Produto estiver no parametro que identifica as Classes de MP que tem espaçamento entre etiquetas ##
			// ########################################################################################################################
			
		 Else
            
            If _cMpClas == "06"
    		   _nEspEtq  := 3     // não tem espaçamento entre etiquetas
    		Else   
 			   _nEspEtq  := 0     // não tem espaçamento entre etiquetas
 			Endif   

		Endif
		
        // ##################		
		// Pega a Metragem ##
		// ##################
		DbSelectArea("ZP1")
//		DbSeek(xFilial("ZP1")+left(_cCodTub,2)+_cMpClas)

//		DbSeek("04" + left(_cCodTub,2) + _cMpClas)
//
//      If cEmpAnt == "01" .And. cFilAnt == "04"
//         k_Filial := "04"    
//      Endif
//           
//      If cEmpAnt == "01" .And. cFilAnt == "07"
//         k_Filial := "07"    
//      Endif
//
//      If cEmpAnt == "03" .And. cFilAnt == "01"
//         k_Filial := "01"
//      Endif
//
//		DbSeek( k_Filial + left(_cCodTub,2) + _cMpClas)
//		IF FOUND()
//			_nMetros := ZP1->ZP1_METLIN
//		ENDIF
//		

        If Select("T_METRAGEM") > 0
           T_METRAGEM->( dbCloseArea() )
        EndIf

        cSql := ""
        cSql := "SELECT ZP1_METLIN"
        cSql += "  FROM " + RetSqlName("ZP1")
        cSql += " WHERE ZP1_FILIAL = '" + Alltrim(cFilAnt)          + "'"
        cSql += "   AND ZP1_TUBETE = '" + Alltrim(left(_cCodTub,2)) + "'"
        cSql += "   AND ZP1_MPCLAS = '" + Alltrim(_cMpClas)         + "'"
        cSql += "   AND D_E_L_E_T_ = ''"

        cSql := ChangeQuery( cSql )
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_METRAGEM", .T., .T. )

	    _nMetros := IIF(T_METRAGEM->( EOF() ), 0, T_METRAGEM->ZP1_METLIN)

        // ################################# 
		// Busca as dimensões da Etiqueta ##
		// #################################
		_aDim := U_BuscaDm(_cCodProd)
		_nL := _aDim[2]
		_nH := _aDim[3]
		_nC := _aDim[4]
	 Endif
	
 	 //	((Metragem Linear em metros * 1000) / (h da Etiqueta + Espaçamento em mm ))*No.Colunas
	 nValor := ((_nMetros * 1000) / (_nH + _nEspEtq )) * _nC                                     
	
     If Alltrim(_cMpClas) == "06"
   	    _QtdEtqTub := INT(VAL(Alltrim(Str(nValor))))
   	 Else
        _QtdEtqTub := VAL(substr(ALLTRIM(STR(nValor,14,0)),1,(Len(ALLTRIM(STR(nValor,14,0)))-1))+"0")
     Endif   
	
     // ############################################################################################
	 // ----- Ajuste em 21/10/2015                                                                ##
	 // baseada na OP 013119.02.001 , foi solicitado o RECALCULO da metragem linear por tubete.. .##
	 // Anderson / Reinaldo                                                                       ##
	 // ############################################################################################
     If Alltrim(_cMpClas) == "06"
   	    _nMetros := ROUND((_nMetros * _QtdEtqTub ) / INT(nValor),0)    
     Else
   	    _nMetros := NOROUND((_nMetros * _QtdEtqTub ) / INT(nValor),1)
   	 Endif   

	 aAdd(_aRet,_nMetros) 	 // Metragem por tubete
	 aAdd(_aRet,_QtdEtqTub)  // Quantidade de Etiquetas por tubete
	 aAdd(_aRet,_cCodTub)
	
  ENDIF

Return(_aRet)

// ########################################################################
// Função que decompoem a descrição da FACA em Altura, Largura e Colunas ##
// ########################################################################
User Function BuscaDm(p1)

   Local _cCodDm := p1
   Local _aRet   := {}

   // ###########################################
   // [1] Descricao da faca : 10x30x2-Circular ##
   // [2] Altura  Etiqueta : 10                ##
   // [3] Largura Etiqueta : 30                ##
   // [4] Colunas          : 2                 ##
   // [5] Mensagem         : -Circular         ##
   // ###########################################
   _cFacas := U_BuscaCar(_cCodDm,"FAC")
   aAdd(_aRet,_cFacas)

   // ###############
   // Busca Altura ##
   // ###############
   _nPos := AT("X",UPPER(_cFacas))
   _cH   := Substr(_cFacas,1,_nPos-1)
   _cfacas := Substr(_cFacas,_nPos+1,LEN(_cFacas)-_nPos)
   aAdd(_aRet,VAL(_cH))

   // ################
   // Busca Largura ##
   // ################
   _nPos   := AT("X",UPPER(_cFacas))
   _clargo := Substr(_cFacas,1,_nPos-1)
   _cfacas := Substr(_cFacas,_nPos+1,LEN(_cFacas)-_nPos)
   aAdd(_aRet,VAL(_cLargo))

   // ################
   // Busca Colunas ##
   // ################
   _cCol   := Substr(_cFacas,1,1)

   If _cCol == "0"
      _cCol := Substr(_cFacas,2,1)
   Endif   

   _cMsg   := Substr(_cFacas,2,LEN(_cFacas)-2)
   aAdd(_aRet,VAL(_cCol))
   aAdd(_aRet,_cMsg)

Return(_aRet)

// ########################################################################
// Função que busca a descricao da caracteristica indicada de um produto ##
// ########################################################################
User Function BuscaCar(p1,p2)

   Local _aArea   := GetArea()
   Local _cCod    := p1
   Local _cCar    := p2
   Local _cRet    := ""
   Local _nTam    := 0
   Local _BqIni   := 0
   Local _BqTam   := 0
   
   // ################################################################
   // Consideramos que as Familias sempre terão 2 digitos no inicio ##
   // ################################################################
   DbSelectArea("SBP")
   DbSetOrder(1)
   DbSeek(xFilial("SBP") + Left(_cCod,2))
   _nTam := 2

   DbSelectArea("SBQ")
   DbSetOrder(2)
   DbSeek(xFilial("SBP")+Left(_cCod,_nTam)+SPACE(LEN(BQ_BASE)-_nTam)+_cCar)
   _BqIni := SBQ->BQ_INICIO
   _BqTam := SBQ->BQ_TAMANHO
   _BqTip := SBQ->BQ_TIPDEF

   IF _BqTip == "1"
      DbSelectArea("SBS")
      DbSetOrder(1)
      DbSeek(xFilial("SBP")+Left(_cCod,_nTam)+SPACE(LEN(BS_BASE)-_nTam)+_cCar+SPACE(LEN(BS_ID)-LEN(ALLTRIM(_cCar)))+substr(_cCod,_BqIni,_BqTam))
      _cRet := SBS->BS_DESCPRD
   ELSEIF _BqTip == "2" //Conjuntos
      DbSelectArea("SBX")
      DbSetOrder(1)
      DbSeek(xFilial("SBX")+_cCar+SPACE(6-Len(_cCar))+substr(_cCod,_BqIni,_BqTam))
      _cRet := SBX->BX_DESCPR
   ENDIF

Return(_cRet)

// ################################
// Função que pesquisa o Pantone ##
// ################################
User Function PANTONE()

   Local cVldAlt := ".T."  // Permitir a Alteracao. 
   Local cVldExc := ".T."  // Permitir a Exclusao.  
   Local cTabela := 'ZP4'                  
   Local cNomTab := SX2->(DbGoTop(), DbSeek(cTabela, .F.), SX2->X2_NOME)

   DbSelectArea(cTabela)
   AxCadastro(cTabela,cNomTab,cVldExc, cVldAlt )

Return()
      
// ###############################
// Função que abre novas opções ##
// ###############################
User Function ESTAGIO()

   Local cTabela 		:= 	'ZP3'                  
   Local cNomTab 		:= 	SX2->(DbGoTop(), DbSeek(cTabela, .F.), SX2->X2_NOME)
   Private	cCadastro	:=	cNomTab
   Private	aRotina		:=	{}
   Private	aCores		:=	{}
   Private	aLegenda	:=	{}

   DbSelectArea('ZP3');DbSetorder(1);DbGoTop()

   Aadd( aRotina, { "Pesquisar"		, '',	0, 4 }) 
   Aadd( aRotina, { "Visualizar"		, 'ExecBlock("Mod2ZP3",.F.,.F.,{"VISUAL"})',0, 0 })
   Aadd( aRotina, { "Incluir"        	, 'ExecBlock("Mod2ZP3",.F.,.F.,{"INCLUI"})',0, 3 })
   Aadd( aRotina, { "Alterar" 	    	, 'ExecBlock("Mod2ZP3",.F.,.F.,{"ALTERA"})',0, 4 })
   Aadd( aRotina, { "Excluir"        	, 'ExecBlock("Mod2ZP3",.F.,.F.,{"EXCLUI"})',0, 6 })
 
   MBrowse( 06, 01,22,75,"ZP3",,,,,,)

Return()             

// ##########################
// Função eu monta a aCols ##
// ##########################
User Function Mod2ZP3()

   Local 	cOpcao 	:= 	ParamIxb[01]
   Local 	cTitulo := 	SX2->(DbGoTop(), DbSeek('ZP3', .F.), SX2->X2_NOME)

   Private aHeader	:=	{}
   Private aCols	:=	{}
   Private aC       :=  {}

   // #####################################
   // Variaveis do Cabecalho do Modelo 2 ##
   // #####################################
   // Private cProduto := ""
   // Private cDesc    := ""

   DbSelectArea('SX3');DbSetOrder(2);DbGoTop()
   DbSeek('ZP3_ESTAG'); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
   DbSeek('ZP3_PANTON'); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
   DbSeek('ZP3_ANILOX'); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
   DbSeek('ZP3_BORR'); 	    Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	
   DbSeek('ZP3_RECURS'); 	Aadd(aHeader,{ Trim(X3_TITULO),  X3_CAMPO	, X3_PICTURE, X3_TAMANHO, X3_DECIMAL, '', X3_USADO, X3_TIPO, X3_F3  })	

   // #################################
   // Montando aCols para a GetDados ##
   // #################################
   If cOpcao != 'INCLUI'

	  IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )
	     cQuery := ""
	     cQuery += "	SELECT	* "                                           + ENTER	
	     cQuery += "	FROM	" + RetSqlName('ZP3')+" AS ZP3 "              + ENTER
	     cQuery += "	WHERE	ZP3.ZP3_FILIAL	= 	'"+xFilial('ZP3')+"'	" + ENTER  				
	     cQuery += "	AND		ZP3.ZP3_COD		=	'"+ZP3->ZP3_COD+"'	  	" + ENTER
	     cQuery += "	AND		ZP3.D_E_L_E_T_ 	!= 	'*'	  		 			" + ENTER
	     cQuery += "	ORDER BY ZP3.ZP3_ESTAG 	"                             + ENTER
	
	  // MemoWrit(GetTempPath()+"MultFreteVenda.TXT", cQuery)            

	  MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'SQL',.F.,.F.)},'Aguarde...','Realizando Busca...' )

	  DbSelectArea('SQL');DbGoTop()
	  
	  Do While !Eof()
			
	 	 cProduto := SQL->ZP3_COD
		 cDesc 	 := Posicione('SB1',1,xFilial('SB1')+cProduto, 'B1_DESC')
			
		 Aadd(aCols, {SQL->ZP3_ESTAG, SQL->ZP3_PANTON, SQL->ZP3_ANILOX, SQL->ZP3_BORR,SQL->ZP3_RECURS, .F.})

		 DbSkip()

	  EndDo
   
   EndIf

   // #####################################
   // Variaveis do Cabecalho do Modelo 2 ##
   // #####################################
   Private cProduto := IIF(cOpcao!= 'INCLUI', cProduto , Space(TamSx3('ZP3_COD')[01]))
   Private cDesc    := IIF(cOpcao!= 'INCLUI', cDesc    , Space(TamSx3('B1_DESC')[01]))

   // ##############################################
   // Array com descricao dos campos do Cabecalho ##
   // ##############################################
   Aadd(aC,{"cProduto",{20,010},"Cod. Produto: ","@!","U_VldSB1(cProduto,cDesc)","SB1",}) 
   Aadd(aC,{"cDesc"   ,{20,250},"Descricao: ","@!",,,.t.}) 

   // +----------------------------------------------+
   // 	Variaveis do Rodape do Modelo 2
   // +----------------------------------------------+
   //  nLinGetD := 0 
   // +----------------------------------------------+
   // ¦ Array com descricao dos campos do Rodape        
   // +----------------------------------------------+
   aR:={}
   // Aadd(aR,{"nLinGetD" ,{120,10},"Linha na GetDados", "@E 999",,,.F.})

   // ###############################################
   // Array com coordenadas da GetDados no modelo2 ##
   // ###############################################
   aCGD:={54,5,118,315}

   // #####################################
   // Validacoes na GetDados da Modelo 2 ##
   // #####################################
   cLinhaOk := 'AllwaysTrue()' //"ExecBlock('Md2LinOk',.f.,.f.)"
   cTudoOk  := 'AllwaysTrue()' //"ExecBlock('Md2TudOk',.f.,.f.)"

   If cOpcao == "INCLUI"
      nOpcx := 3	//	INCLUI NOVOS 
   ElseIf cOpcao == "ALTERA"
	  //nOpcx := 6	//	ALTERA - NAO INCLUI NOVOS ITENS
	  nOpcx := 4	//	ALTERA - NAO INCLUI NOVOS ITENS
   Else
      nOpcx := 0	//	QQ OUTRO NUM. APENAS VISUALIZA
   EndIf 

   If Modelo2(cTitulo, aC, aR, aCGD, nOpcx, cLinhaOk, cTudoOk)

	  nPosEst  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'ZP3_ESTAG' })
	  nPosPan  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'ZP3_PANTON'})
	  nPosAni  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'ZP3_ANILOX'})
	  nPosBor  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'ZP3_BORR'	 })
	  nPosRec  :=	Ascan(aHeader,{|x| AllTrim(x[2]) == 'ZP3_RECURS'	 })
         
      // ####################################   
	  // VALIDACAO PARA INCLUSAO\ALTERACAO ##
	  // ####################################
   	  If cOpcao == "INCLUI"
			
		 For nX:=1 To Len(aCols)
		
			 If !aCols[nX][Len(aHeader)+1]
				RecLock('ZP3', .T.)
				ZP3->ZP3_FILIAL	:=	xFilial('ZP3')
				ZP3->ZP3_COD	:=	cProduto
				ZP3->ZP3_ESTAG	:=	aCols[nX][nPosEst]
				ZP3->ZP3_PANTON	:=	aCols[nX][nPosPan]
				ZP3->ZP3_ANILOX	:=	aCols[nX][nPosAni]
				ZP3->ZP3_BORR	:=	aCols[nX][nPosBor]
				ZP3->ZP3_RECURS	:=	aCols[nX][nPosRec]
			    MsUnLock()
		    EndIf
		
		Next				
		
	  ElseIf cOpcao == "ALTERA"
	
		For nX:=1 To Len(aCols)

			DbSelectArea('ZP3');DbSetOrder(1);DbGoTop()		//	ZP3_FILIAL+ZP3_COD+ZP3_ESTAG
			If DbSeek(xFilial('ZP3')+cProduto+aCols[nX][nPosEst], .F.)
           		
           	   If !aCols[nX][Len(aHeader)+1]

				  RecLock('ZP3', .F.)
				  ZP3->ZP3_FILIAL	:=	xFilial('ZP3')
				  ZP3->ZP3_COD	:=	cProduto
				  ZP3->ZP3_ESTAG	:=	aCols[nX][nPosEst]
				  ZP3->ZP3_PANTON	:=	aCols[nX][nPosPan]
				  ZP3->ZP3_ANILOX	:=	aCols[nX][nPosAni]
				  ZP3->ZP3_BORR	:=	aCols[nX][nPosBor]
				  ZP3->ZP3_RECURS	:=	aCols[nX][nPosRec]
				  MsUnLock()				
				
				Else          					
           			RecLock('ZP3', .F.)
             		DbDelete()
           	  		MsUnLock()
           	  	EndIf

			Else            
           		If !aCols[nX][Len(aHeader)+1]
					RecLock('ZP3', .T.)
					ZP3->ZP3_FILIAL	:=	xFilial('ZP3')
					ZP3->ZP3_COD	:=	cProduto
					ZP3->ZP3_ESTAG	:=	aCols[nX][nPosEst]
					ZP3->ZP3_PANTON	:=	aCols[nX][nPosPan]
					ZP3->ZP3_ANILOX	:=	aCols[nX][nPosAni]
					ZP3->ZP3_BORR	:=	aCols[nX][nPosBor]
					ZP3->ZP3_RECURS	:=	aCols[nX][nPosRec]
				    MsUnLock()
			    Endif
			EndIf
    
		Next
	
	
	ElseIf cOpcao == 'EXCLUI'

		// ###############
		// DELETA ITENS ##
		// ###############
		DbSelectArea('ZP3');DbSetOrder(1);DbGoTop()		//	ZP2_FILIAL+ZP2_COD+ZP2_ESTAG
		If DbSeek(xFilial('ZP3')+cProduto, .F.)
			Do While !Eof() .And. AllTrim(ZP3->ZP3_COD) == AllTrim(cProduto)
           		
           		RecLock('ZP3', .F.)
               		DbDelete()
           	  	MsUnLock()
           	 
           	 	DbSkip()
           	 EndDo
		EndIf

   	 EndIf

  EndIf

  IIF(Select("SQL") != 0, SQL->( DbCLoseArea() ), )

Return()                                                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VLDSB1  ºAutor  ³ Cesar Mussi         º Data ³  06/26/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida digitacao codigo do produto na ZP3                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VldSb1(cProduto,cDesc)
Local _aArea := GetArea()
Local _cProd := cProduto
Local _cDesc := cDesc
Local _cMsg  := ""
Local _lRet  := .t.

IF INCLUI
   DbSelectArea("ZP3")
   DbSeek(xFilial("ZP3")+_cProd)
   If Found()
	  _cMsg  := "Produto ja cadastrado! Escolha ALTERAR!"
   Endif
ENDIF

DbSelectArea("SB1")
DbSeek(xFilial("SB1")+_cProd)
If Found()
   IF SB1->B1_MSBLQL == "1"
      _cMsg  := "Produto Bloqueado para uso ! (B1_MSBLQL)"
   Else   
      cDesc := Posicione('SB1',1,xFilial('SB1')+_cProd, 'B1_DESC')
   ENDIF
Else
   _cMsg  := "Produto Não Existe no Cadastro ! ( SB1->EOF() ) "
Endif

IF !empty(_cMsg)
   MSGBOX(_cMsg,"Produto Invalido","STOP")
   _lRet  := .f.
ENDIF
RestArea(_aArea)
Return(_lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ImpProdSG2ºAutor  ³ Jeferson Arteiro  º Data ³  09/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automatech                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ImpProdSG2()
*******************************************************************************
Local I

IF !MsgYesNo("Confirma a importacao dos produtos ?") 
   RETURN(.T.)
ENDIF

DBSelectArea("SB1")
SET FILTER TO (SUBSTR(B1_COD,1,2) == "02" .Or. SUBSTR(B1_COD,1,2) == "03") .AND. LEN(ALLTRIM(B1_COD))==17
DBGOTOP()
ProcRegua(RecCount())
DO WHILE !EOF()      
   IncProc("Importando produto:" + ALLTRIM(SB1->B1_COD))
   FOR I:=1 TO 4            
       DBSelectArea("SG2")                   
       IF !DBSeek(xFilial("SG2") + SB1->B1_COD + "01" + STRZERO(I,2))
          Reclock("SG2",.T.)
          G2_FILIAL  := cFilAnt
          G2_CODIGO  := "01"
          G2_PRODUTO := SB1->B1_COD
          G2_OPERAC  := STRZERO(I,2)              
          cRecurso   := STRZERO(I,4) + "00" 
          G2_RECURSO := cRecurso 
          G2_DESCRI  := IIF(cRecurso=="000100","SEPARACAO",IIF(cRecurso=="000200","PRODUCAO",IIF(cRecurso=="000300","ACABAMENTO","EMBALAGEM")))
          G2_TEMPAD  := I
          MSUnlock()
       ENDIF
   NEXT I 
   DBSelectArea("SB1")
   DBSKIP()
ENDDO       
SET FILTER TO
ALERT("Importacao Encerrada")

Return()             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuCadProdºAutor  ³ Jeferson Arteiro  º Data ³  09/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automatech                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AtuCadProd()	

 Private cEOL     := CHR(13) + CHR(10)
 Private lBuffer  := 1000
 Private lFilePos := 1000
 Private lPos     := 0
 Private cLine    := ""

 IF !MsgYesNo("Processar a atualizacao dos produtos ?") 
    RETURN(.T.)
 ENDIF

 hFile := FOPEN("D:\Protheus\Protheus11\Protheus_data\codigos-producao.TXT", 32)
 lFilePos := FSEEK(hFile, 0, 0)              
 cBuffer := SPACE(lBuffer)                   
 lRead := FREAD(hFile, cBuffer, lBuffer)     
 lPos := AT(cEOL, cBuffer)                   

 WHILE !(lRead == 0)
     WHILE (lPos == 0)   
         lBuffer  += 1000
         cBuffer  := SPACE(lBuffer)
         lFilePos := FSEEK(hFile, lFilePos, 0)
         lRead    := FREAD(hFile, cBuffer, lBuffer)
         lPos     := AT(cEOL, cBuffer)
     ENDDO
     
     cLine := SUBSTR(cBuffer, 0, lPos)
     IF SUBSTR(cLine,72,13) == "CADASTRO  NULO"
        DBSELECTAREA("SB1")
        DBSETORDER(1)
        IF DBSEEK(xFilial("SB1") + SUBSTR(cLine,1,17))
           RECLOCK("SB1", .F.)                                                                                
           SB1->B1_MSBLQL := "1"
           MSUNLOCK()
        ENDIF
     ELSE
        IF SUBSTR(cLine,35,6) <> "PADRAO"
           nPos  := AT("/",SUBSTR(cLine,41,15))
           
           nETQRL :=VAL(SUBSTR(cLine,41,nPos-1))
           nMLRL  :=VAL(STRTRAN(SUBSTR(cLine,41+nPos,10),",","."))
           DBSELECTAREA("SB5")
           DBSETORDER(1)
           IF DBSEEK(xFilial("SB5") + SUBSTR(cLine,1,17))
              RECLOCK("SB5", .F.)
              SB5->B5_MLRL := nMLRL
              SB5->B5_ETQRL:= nETQRL
              MSUNLOCK()
           ELSE
              RECLOCK("SB5", .T.)
              SB5->B5_COD    := SUBSTR(cLine,1,17)
              SB5->B5_MLRL   := nMLRL
              SB5->B5_ETQRL  := nETQRL
              MSUNLOCK()               
           ENDIF          
        ELSE 
           DBSELECTAREA("SB1")
           DBSETORDER(1)
           IF DBSEEK(xFilial("SB1") + SUBSTR(cLine,1,17))
              RECLOCK("SB1", .F.)                                                                     
              SB1->B1_ROLO   := IIF(SUBSTR(cLine,26,2)=="M1","1",IIF(SUBSTR(cLine,26,2)=="M2","2",IIF(SUBSTR(cLine,26,2)=="M3","3","4")))
              SB1->B1_MPCLAS := IIF(SUBSTR(cLine,35,6) == "PADRAO","01","")              
              MSUNLOCK()
           ENDIF        
        ENDIF     
     ENDIF
     // LEITURA DA PROXIMA LINHA DO ARQUIVO
     cBuffer  := SPACE(lBuffer)                   // ALOCA BUFFER
     lFilePos += lPos + 1                        // POSICIONA ARQUIVO APÓS O ULTIMO EOL ENCONTRADO
     lFilePos := FSEEK(hFile, lFilePos, 0)       // POSICIONA PONTEIRO DO ARQUIVO
     lRead    := FREAD(hFile, cBuffer, lBuffer)     // LE OS CARACTERES DO ARQUIVO
     lPos     := AT(cEOL, cBuffer)                   // PROCURA O PRIMEIRO FINAL DE LINHA
 ENDDO                  
 ALERT("Atualizacao Encerrada")
 RETURN
 
 
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtuCadProdºAutor  ³ Jeferson Arteiro  º Data ³  12/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automatech                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function VerCadPantone(cProduto)
 
   Local lRet   := .T.
   Local cRet   := ""
   Local _aArea := GetArea()
   Local cSQL   := ""
                                                                                                        
   // ##################################################################################################                                                                                       
   // Este teste foi colocado aqui porque o espaço para a condição na tela do gatilho é muito pequeno ##
   // ##################################################################################################  
   // If (cEmpAnt == "01" .And. cFilAnt == "04") .Or. (cEmpAnt == "03" .And. cFilAnt == "01") .Or. (cEmpAnt == "01" .And. cFilAnt == "07")

   If (LEFT(_cCod,2) == "02" .Or. LEFT(_cCod,2) == "03")

      If Select("SQLTMP") > 0
         SQLTMP->( dbCloseArea() )
      EndIf

      If (Left(cProduto,2) == "02" .Or. Left(cProduto,2) == "03")
	     cSQL := "SELECT COUNT(*) CONTADOR FROM " + RetSqlName("ZP3")
	     cSQL += " WHERE ZP3_FILIAL ='" + xFilial("ZP3") + "'"
	     cSQL += "   AND ZP3_COD='" + cProduto + "'"
	     cSQL += "   AND D_E_L_E_T_ <> '*'
        
   	     DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSQL),'SQLTMP',.F.,.F.)
	     DBSelectArea("SQLTMP")

	     If SQLTMP->CONTADOR == 0
		    MsgInfo("Produto sem pantone cadastrado. Entre em contato com o responsável" + ENTER;
		            + "pelo cadastro de produtos para que seja incluída esta informação.","Aviso")
		    lRet := .F.
	     Endif
	
// 	     DBCloseArea("SQLTMP")
   
      Endif

      RestArea(_aArea)

      cRet:= Iif(lRet,cProduto,"")
      
   Endif

Return(cRet)

/*/{Protheus.doc} TemEstoque
Verifica a existencia de saldo em estoque, comparando o saldo do produto informado pela quantidade inserida na função (nQuant).
@author Lucas Moresco Solutio IT
@since 07/04/2015
/*/
User Function TemEstoque(cProduto,cLocal,nQuant)

   Local lRet    := .F.
   Local nQtdSld := 0
	
   DbSelectArea("SB2")
   DbSetOrder(1)
	
   If (DbSeek(xFilial("SB2")+cProduto+cLocal))
 	  nQtdSld := SaldoSB2()
   EndIf
	
   If (nQtdSld > nQuant)
	  lRet    := .T.
   EndIf
	
Return(lRet)	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | AxZZ8      ºAutor  ³Jeferson Arteiro    º Data ³ 07/03/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          |AxCadastro - Tabela ZZ8                                       º±±
±±º          |                                                              º±±
±±º          |                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP11 - Automatech                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*******************************************************************************
User Function AxZZ8()
*******************************************************************************

   Local cVldAlt := ".T."  // Permitir a Alteracao. 
   Local cVldExc := ".T."  // Permitir a Exclusao.  
   Local cTabela := 'ZZ8'
   Local cNomTab := SX2->(DbGoTop(), DbSeek(cTabela, .F.), SX2->X2_NOME)

   DbSelectArea(cTabela)
   AxCadastro(cTabela,cNomTab,cVldExc, cVldAlt )

Return()