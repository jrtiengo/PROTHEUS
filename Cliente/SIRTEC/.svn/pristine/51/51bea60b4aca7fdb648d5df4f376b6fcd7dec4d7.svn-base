#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"
#Include "totvs.ch"

#define P_NUMSA 2
#define P_ITEMSA 3
#define P_PRODUTO 6
#define P_NOMEPRO 7 
#define P_CA 8	   
#define P_MATRICULA 4
#define P_ALMOX 11      
#define P_QTDSA 10
#define P_ENDE 18 
#define P_SERIE 19 

/*/{Protheus.doc} XM105PRO
//Processamento - S.A + Epi x Funcionarios
@author Celso Rene                                                           
@since 28/01/2019
@version 1.0
@type function
/*/
User Function XM105PRO()

	//Local 	_lRet 		 := .F.
	Local 	_aArea		 := GetArea()
	Local 	nUn			 := 1

    Local   lProcessados := .F.
		
	Private _aVetor		 := {}
	Private _lMark		 := .F.
	
	Private	_cUnid		 := ""
	Private	_aUnids		 := {}
	
	Private	dDtEmDe		 := Date()
	Private	dDtEmAte	 := Date()
	
	//pergunte("XMATA105",.F.)
	//_cUnid := 5PAR01
	u_SelUnid()
	
	For nUn := 1 to Len(_aUnids)
		If _aUnids[nUn,1]
			_cUnid += _aUnids[nUn, 2]+"|"
		EndIf
	Next nUn

    // Inclusão de pergunta se deseja visualizar as SA já processadas
    If MsgNoYes("Deseja visualizar também os registros já processados que não possuem Pedidos de Venda vinculados ainda?")
       lProcessados := .T.
    Else
       lProcessados := .F.
    Endif       

	dbSelectArea("SCP")
	SCP->(dbGoTop())
	//Gregory A. - Alteração para filtrar apenas UMA unidade 
	dbSetFilter( {|| CP_XUNID $ _cUnid .AND. CP_STATSA  <> 'B'        .AND. ;
	                                         CP_STATSA  <> 'R'        .AND. ;
	                                         CP_STATUS  <> 'E'        .AND. ;
	                                         CP_QUANT    > CP_QUJE    .AND. ;
	                                         CP_XROT     = 'XMATA105' .AND. ;
	                                         CP_EMISSAO >= dDtEmDe    .AND. ;
	                                         CP_EMISSAO <= dDtEmAte  }, "CP_XUNID $ _cUnid .AND. CP_STATSA <> 'B' .AND. CP_STATSA <> 'R' .AND. CP_STATUS <> 'E' .AND. CP_QUANT > CP_QUJE .AND. CP_XROT = 'XMATA105' .AND. CP_EMISSAO >= dDtEmDe  .AND. CP_EMISSAO <= dDtEmAte  "  )
	SCP->(dbGoTop())
	
	Do While ( !SCP->(EOF()) )

        If lProcessados == .F.
           If !Empty(Alltrim(SCP->CP_NCON))
     		  SCP->(dbSkip())
     		  Loop
     	   Endif	  
        Endif              

		_cmov := If (SCP->CP_XMOV == "1", "", If(SCP->CP_XMOV == "2", "EPI", "EPC"))

        // ================================================================================================================================ ##
        // No dia 20/08/2019, Vinícius da Sirtec informou que o nome do fucnionário não está sendo observado no grid de processamento.      ##
        // Verificando o banco na tabela SCP o código do funcionário está gravado na coluna CP_SEQFUN e não na coluna CP_XMAT.              ##
        // Falei com o Celso, e ele me informou que no início era usado a coluna CP_XMAT sendo possível de ser substituído pela coluna      ##
        // CP_SEQFUN. Foi comentado o comando acima onde podemos observar o enunciado e abaixo, o comando que foi substituído para atender  ##
        // a demanda do Cliente.                                                                                                            ##
        // ================================================================================================================================ ##       

//      __NomeMatricula := Left(Posicione("AA1",1,xFilial("AA1") + SCP->CP_SEQFUNC, "AA1_NOMTEC"),25)

        // Verifica se a matrícula está em férias.
        // Se estiver, coloca na frente do nome a inscrição (EM FÉRIAS)
        If Select("T_FERIAS") > 0
           T_FERIAS->( dbCloseArea() )
        EndIf

        cSql := ""
        cSql := "SELECT RA_SITFOLH"
        cSql += "  FROM " + RetSqlName("SRA")
        cSql += " WHERE RA_FILIAL  = '" + Alltrim(cFilAnt)         + "'"
        cSql += "   AND RA_MAT     = '" + Alltrim(SCP->CP_SEQFUNC) + "'"
        cSql += "   AND D_E_L_E_T_ = ''"
        	
        cSql := ChangeQuery( cSql )
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FERIAS", .T., .T. )

        If T_FERIAS->( EOF() )
           __NomeMatricula := Left(Posicione("AA1",1,xFilial("AA1") + SCP->CP_SEQFUNC, "AA1_NOMTEC"),25)
        Else
           If T_FERIAS->RA_SITFOLH == "F"
              __NomeMatricula := "(EM FÉRIAS) - " + Left(Posicione("AA1",1,xFilial("AA1") + SCP->CP_SEQFUNC, "AA1_NOMTEC"),25)
           Else
              __NomeMatricula := Left(Posicione("AA1",1,xFilial("AA1") + SCP->CP_SEQFUNC, "AA1_NOMTEC"),25)
           Endif
        Endif
                
		Aadd( _aVetor,{ .F.                                                                       ,; // 01
		                SCP->CP_NUM                                                               ,; // 02
						SCP->CP_ITEM                                                              ,; // 03
						SCP->CP_SEQFUNC                                                           ,; // 04
						__NomeMatricula,; // 05
						SCP->CP_PRODUTO                                                           ,; // 06
						SCP->CP_DESCRI                                                            ,; // 07
						SCP->CP_XNUMCAP                                                           ,; // 08
						SCP->CP_UM                                                                ,; // 09
						SCP->CP_QUANT                                                             ,; // 10
						SCP->CP_LOCAL                                                             ,; // 11
						SCP->CP_CC                                                                ,; // 12
						Left(SCP->CP_OBS,50)                                                      ,; // 13
						cValtoChar(SCP->CP_EMISSAO)                                               ,; // 14
						cValtoChar(SCP->CP_DATPRF)                                                ,; // 15
						_cmov                                                                     ,; // 16
						SCP->CP_XUNID                                                             ,; // 17
						SCP->CP_YLOCALI                                                           ,; // 18
						SCP->CP_YNUMSR                                                            }) // 19

		SCP->(dbSkip())

	EndDo

    // Ordena o array pela descrição do produto
    //    ASORT(_aVetor,,,{ | x,y | x[7],X[3] > y[7],Y[3] } )
    //    ASORT(_aVetor,,,{ | x,y | x[7],X[2],X[3] > y[7],Y[2],Y[3] } )
    ASORT(_aVetor,,,{ | x,y | x[7] > y[7] } )

	//chama funcao lista S.A.s para processamento
	If (Len(_aVetor) )
		TelaZNF()
	EndIf

	RestArea(_aArea)

	pergunte("MTA105",.F.)

Return()

/*/{Protheus.doc} SelUnid
//tela customizada selecao de unidades para busca das S.A.
@author  Gregory Araujo
@since 28/05/2019
@version 1.0
@type function
/*/
User Function SelUnid()
	
	//Local lMark	:= .F.
	//Local nI	:= 1
	Local _aSX5 := {}
	local _x
	
	Private oChk	:= Nil
	Private lChk	:= .F.
	Private oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oLbx	:= Nil
	Private oDlg
	Private oDtDe	:= Nil
	Private oDtAte	:= Nil
	
	Private oFont1	:= TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	
	//DEFAULT dDtEmDe := Date()
	//DEFAULT dDtEmAte:= Date()
	
	/*dbSelectArea("SX5")
	dbSetOrder(1)
	dbSeek(xFilial("SX5")+"ZD")
	If Found()
		While SX5->X5_TABELA == "ZD" .AND. SX5->(!EoF())
			aAdd(_aUnids, {.F., SX5->X5_CHAVE, SX5->X5_DESCRI} )
			SX5->(dbSkip())
		EndDo
	EndIf
	SX5->(DbCloseArea())*/
	//Função de retorno dos campos de uma tabela no SX5.
	_aSX5 := FWGetSX5( "ZD","","pt-br") 
	if (Len(_aSX5))
		For _x:= 1 to Len(_aSX5)
			aAdd(_aUnids, {.F., _aSX5[_x][3], _aSX5[_x][4] } )
		Next _x
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE "Listagem de Unidades para Seleção de S.A.(s) - EPI & EPC"  FROM 0,0 TO 530,900 PIXEL
	
	@ 014,010 LISTBOX oLbx VAR cVar FIELDS HEADER  "","Chave","Descri" ;
	SIZE 435,215 OF oDlg PIXEL ON dblClick(_aUnids[oLbx:nAt,1] := !_aUnids[oLbx:nAt,1],oLbx:Refresh())
	
	oLbx:SetArray( _aUnids )
	oLbx:bLine := {|| {Iif(_aUnids[oLbx:nAt,1],oOk,oNo),_aUnids[oLbx:nAt,2],_aUnids[oLbx:nAt,3] } }

	@ 234,010 CHECKBOX oChk VAR lChk PROMPT "Marca / Desmarca - Todos" SIZE 90,007 PIXEL OF oDlg ON CLICK( aEval( _aUnids, { |x| x[1] := lChk } ), oLbx:Refresh() )
	
	@ 234,123 SAY    "Emissão de:"  		           	OF oDlg PIXEL
   	@ 230,170 MSGET  oDtDe	VAR dDtEmDe SIZE 035,010	OF oDlg PIXEL 
   	@ 234,223 SAY    "Emissão Até:"  		           	OF oDlg PIXEL
   	@ 230,273 MSGET  oDtAte	VAR dDtEmAte SIZE 035,010	OF oDlg PIXEL 
	
	@ 247,080 Button "Ok" Size 045,014 PIXEL OF oDlg ACTION(oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED
		
Return()

/*/{Protheus.doc} xBaixaSA
//Proessamento SA - gerando pre requisicao e requisitando item SA.
@author Celso Rene
@since 11/02/2019
@version 1.0
@type function
/*/                       
Static Function xBaixaSA(_aSAsP)
 
   MsgRun("Aguarde! Processando SA(s) selecionada(s) ...", "Atendimento",{|| kxBaixaSA(_aSAsP) })   

Return(.T.)

Static Function kxBaixaSA(_aSAsP)

	Local 	_lMov		   := .F.
	Local 	_aISCP		   := {}
	Local	_aISD3		   := {}
	Local 	_nOpc		   := 1 //baixa
	Local	_lMatric	   := .F.
	Local nContar
	Local _x
    local nJaTem
	Local _nSaldoSBF 		:= 0

	Private _lTNF		   := .F. //executou com sucesso execauto da rotina MDTA685
	Private _lZZD		   := .F. //Vinculo de equipe com EPC
	Private _lPRD		   := .F. //Requisição de produto sem equipe nem matricula 
	
	Private aControle      := {}                                                   
    Private aEntregas      := {}
    Private aVoltaFer      := {}
	
	Public  _cChave		:= ""  // Chiapin
    Public  aHora       := {}
    
	cNGMDTES := Alltrim(GetMV("MV_NGMDTES"))

    aAdd( aHora, { Substr(Time(),01,02), Substr(Time(),04,02), Substr(Time(),01,02), Substr(Time(),04,02) } )
	             
    // ###################################################
    // Inicia o controle transacional do processo Macro ##
    // ###################################################
//  BEGIN TRANSACTION				

       // Verifica se os EPIS selecionados está gravados na tabela TNB
       // Se não estiverem, os grava antes de realizar o atendimento
       For nContar := 1 to Len(_aSAsP)
        
           // Despresa registro não selecionado
		   If (_aSAsP[nContar][1] == .F.)
		      Loop
		   Endif
	
		   // Pesquisa o código da função da matrícula do registro selecionado   
           If Select("T_CODFUNCAO") > 0
              T_CODFUNCAO->( dbCloseArea() )
           EndIf

           cSql := ""
           cSql := "SELECT RA_CODFUNC"
           cSql += "  FROM " + RetSqlName("SRA")
           cSql += " WHERE RA_FILIAL  = '" + Alltrim(cFilAnt)            + "'"
           cSql += "   AND RA_MAT     = '" + Alltrim(_aSAsP[nContar,04]) + "'"
           cSql += "   AND D_E_L_E_T_ = ''"
        	
           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CODFUNCAO", .T., .T. )

           If T_CODFUNCAO->( EOF() )
              Loop
           Endif
        
           IF Empty(Alltrim(T_CODFUNCAO->RA_CODFUNC))
              Loop
           Endif
        
           // Verifica se o EPI para o código da função da matrícula já está cadastra. Se não estiver, a inclui
		   Dbselectarea("TNB")
		   Dbsetorder(1)
		   If !Dbseek( xFilial( "TNB" ) + T_CODFUNCAO->RA_CODFUNC + _aSAsP[nContar,06])
		      RecLock("TNB", .T.)
		      TNB->TNB_FILIAL := xFilial( "TNB" )
		      TNB->TNB_CODFUN := T_CODFUNCAO->RA_CODFUNC
		      TNB->TNB_CODEPI := _aSAsP[nContar,06]
		      TNB->TNB_COMBO  := "1"
		      TNB->(MsUnLock())
           Endif

       Next nContar    

       // Pesquisa o próximo código de controle para gravação
       If Select("T_CONTROLE") > 0
          T_CONTROLE->( dbCloseArea() )
       EndIf
    
       cSql := ""
       cSql := "SELECT MAX(CP_NCON) + 1 AS PROXIMO_CONTROLE"
       cSql += "  FROM " + RetSqlName("SCP")
       cSql += " WHERE CP_FILIAL  = '" + Alltrim(cFilAnt) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTROLE", .T., .T. )

       cNrControle := Strzero(T_CONTROLE->PROXIMO_CONTROLE,6)

       aAdd( aControle, cNrControle )

	   For _x:= 1 to Len(_aSAsP)
	
	      // Considera somente os registros selecionados 
	  	  If (_aSAsP[_x][1] == .T.)

             // Envia para a função que grava o campo CP_XNUMCAP com o código da SA
			 grvCASCP(_aSAsP[_x])

			 //Posiciona-se no item da SA
			 dbSelectArea("SCP")
			 dbSetOrder(1)
			 dbSeek(xFilial("SCP") + _aSAsP[_x][2] + _aSAsP[_x][3] )
			
			 dbSelectArea("SB1")
			 dbSetOrder(1)
			 dbSeek(xFilial("SB1")+ SCP->CP_PRODUTO)

			 dbSelectArea("SB2")
			 dbSetOrder(2) //B2_FILIAL + B2_LOCAL + B2_COD
			 dbSeek(xFilial("SB2") + SCP->CP_LOCAL + SCP->CP_PRODUTO )

		     _nSaldoSBF := 0
			 if (SB1->B1_LOCALIZ == "S")					
			 	_nSaldoSBF := SaldoSBF( SCP->CP_LOCAL , SCP->CP_YLOCALI , SCP->CP_PRODUTO , Space(TamSX3("BF_NUMSERI")[1]) , Space(TamSX3("BF_LOTECTL")[1]) , Space(TamSX3("BF_NUMLOTE")[1]) )
		     else
			 	_nSaldoSBF := SaldoSb2()
		     endif		
			 If ( Found() .and. SaldoSb2() >= SCP->CP_QUANT .and. _nSaldoSBF >= SCP->CP_QUANT)
			
				//Begin Transaction
			
				If (SCP->CP_PREREQU <> "S" .and. SCP->CP_STATUS <> "E" .and. ; //Alltrim(GetMV("MV_NGMDTES")) == "S")
					cNGMDTES == "S") //.and. !Empty(SCP->CP_SEQFUNC) )
					//verificando se a SA ja foi pre requisitada

					//ATUALIZANDO EMPENHO SA - SB2
					dbSelectArea("SB2")
					RecLock("SB2", .F.)
					SB2->B2_QEMPSA := SB2->B2_QEMPSA + SCP->CP_QUANT
					SB2->(MsUnLock())
					//EndIf

					//PRE REQUISICAO - SA
					dbSelectArea("SCP")
					RecLock("SCP", .F.)
					SCP->CP_PREREQU := "S"
	  				SCP->CP_OK 		:= Getmark()
                    SCP->CP_NCON    := cNrControle
   					SCP->(MsUnLock())

					//PRE REQUISICAO - SA - GERNADO SCQ	
					dbSelectArea("SCQ")
					RecLock("SCQ", .T.)
					SCQ->CQ_FILIAL	:= xFilial("SCQ")
					SCQ->CQ_NUM		:= SCP->CP_NUM
					SCQ->CQ_NUMSQ	:= SCP->CP_ITEM
					SCQ->CQ_PRODUTO	:= SCP->CP_PRODUTO
					SCQ->CQ_UM		:= SCP->CP_UM
					SCQ->CQ_QUANT	:= SCP->CP_QUANT
					SCQ->CQ_LOCAL	:= SCP->CP_LOCAL
					SCQ->CQ_OBS		:= SCP->CP_OBS
					SCQ->CQ_DESCRI	:= SCP->CP_DESCRI
					SCQ->CQ_ITEM	:= SCP->CP_ITEM
					SCQ->CQ_CC		:= SCP->CP_CC
					SCQ->CQ_DATPRF	:= SCP->CP_DATPRF
					SCQ->CQ_QTDISP	:= SCP->CP_QUANT
					SCQ->(MsUnLock())

				 EndIf

				 dbSelectArea("SRA")
				 dbSetOrder(1)
				 dbSeek( xFilial("SRA") + SCP->CP_SEQFUNC )
				 If (Found() .and. SRA->RA_SITFOLH <> "D") // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA
					_lMatric := .T.
				 Else
					_lMatric := .F.
				 EndIf
				
				 //PREPARANDO DADOS CABEC E ITENS PARA O EXECAUTO	
				 _aISCP := { {"CP_NUM" 		, SCP->CP_NUM 	 ,Nil },;
				  			 {"CP_ITEM" 	, SCP->CP_ITEM 				 ,Nil },;
							 {"CP_PRODUTO"	, SCP->CP_PRODUTO			 ,Nil },;
							 {"CP_CC"		, SCP->CP_CC				 ,Nil },;
							 {"CP_QUANT" 	, SCP->CP_QUANT 			 ,Nil }}

				 _aISD3 := { {"D3_TM" 		, Iif(_lMatric, "510" , "511"),Nil },; // Tipo do Mov.
							 {"D3_COD" 		, SCP->CP_PRODUTO			 ,Nil },;
							 {"D3_LOCAL"	, SCP->CP_LOCAL 			 ,Nil },;
							 {"D3_DOC" 		, SCP->CP_NUM + SCP->CP_ITEM ,Nil },; // No.do Docto.
							 {"D3_NUMSA"	, SCP->CP_NUM 		 		 ,Nil },;
							 {"D3_ITEMSA"	, SCP->CP_ITEM 		 		 ,Nil },;
							 {"D3_SANUM"	, SCP->CP_NUM 		 		 ,Nil },;
							 {"D3_SAITE"	, SCP->CP_ITEM 		 		 ,Nil },;
							 {"D3_EMISSAO" 	, dDataBase 				 ,Nil }}
			
				 lMSHelpAuto := .F.
				 lMsErroAuto := .F.

    			 MsExecAuto({|w,x,y,z|mata185(w,x,y,z)},_aISCP    ,_aISD3    ,If(Empty(SCP->CP_SEQFUNC),_nOpc,6) )    
   
				 If (lMsErroAuto)
					_aSAsP[_x][1] := .F. //forcando para nao entrar no pedido - falha processo
					MostraErro()
				 Else
					If _lMatric
					   _lTNF:= xTNF() //epi
					Else        
					
                       aHora[01,01] := Substr(Time(),01,02)
                       aHora[01,02] := Substr(Time(),04,02)
                       aHora[01,03] := Substr(Time(),01,02)
                       aHora[01,04] := Substr(Time(),04,02)

					   dbSelectArea("AA1")
					   dbSetOrder(1)
					   dbSeek(xFilial("AA1")+SCP->CP_SEQFUNC)
					   If (Found() ) // Se o campo for uma Equipe 
						  _lZZD := xZZD()  //epc 
					   Else 
					      _lPRD := .T.
					   EndIf
					EndIf
				 EndIf
								
				 //executou execauto TNF - EPI
				 //If !(_lTNF == .T.)
				 If !(_lTNF .or. _lZZD .or. _lPRD)
				
					dbSelectArea("SCP")
					RecLock("SCP", .F.)
					SCP->CP_PREREQU := ""
					SCP->CP_OK 		:= ""
					SCP->CP_STATUS 	:= ""
					SCP->(MsUnLock())
					
					_aSAsP[_x][1] := .F. //forcando para nao entrar no pedido - falha processo
					
				 EndIf
				
			  Else
				 _aSAsP[_x][1] := .F. //forcando para nao entrar no pedido - falha processo
				 MsgAlert("Sem saldo para atender S.A. " + Alltrim(SCP->CP_NUM) + "-" + Alltrim(SCP->CP_ITEM) + " - Produto: " + Alltrim(SCP->CP_PRODUTO), "# Saldo !" )
			  EndIf

		   EndIf

	   Next _x
	                       
	   // Realiza a gravação do número do Controle de Entrega dos produtos por matrícula do que realemente foi processado.
       aEntregas := {}
    
       // Carrega o último código de Entrega para gravação das novas Entregas
       If Select("T_PROENTREGA") > 0
          T_PROENTREGA->( dbCloseArea() )
       EndIf
    
       cSql := ""
       cSql := "SELECT MAX(CP_SCOM) AS XENTREGACOM" 
       cSql += "  FROM " + RetSqlName("SCP")
       cSql += " WHERE D_E_L_E_T_ = ''"    
                                    
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROENTREGA", .T., .T. )

       If T_PROENTREGA->( EOF() )
          nEntregaCom := 1
       Else
          nEntregaCom := Int(val(T_PROENTREGA->XENTREGACOM))
       Endif     
  
       nNumAchado := 0
       nNumGravar := 0

       For nContar = 1 to Len(_aSAsP)
		
           // Se produto desmarcado, despreza
		   If _aSAsP[nContar][1] == .F.
		      Loop
		   Endif

           // Verifica se matrícula/SA já está contida no array aEntregas. Se não tem, o inclui
           lJaEsta := .F.
           For nJaTem := 1 to Len(aEntregas)
               If Alltrim(aEntregas[nJaTem,01]) == Alltrim(_aSAsP[nContar,04]) .And. ;
                  Alltrim(aEntregas[nJatem,02]) == Alltrim(_aSAsP[nContar,02])
                  nNumAchado := INT(VAL(aEntregas[nJatem,04]))
                  lJaEsta    := .T.
                  Exit
               Endif
           Next nJaTem
        
           // Se não encontrou
           If lJaEsta == .F.
              nEntregaCom := nEntregaCom + 1
              nNumGravar  := nEntregaCom
           Else
              nNumGravar  := nNumAchado
           Endif

           // Matrícula, SA, Item, Sequencial
           aAdd( aEntregas, { _aSAsP[nContar,04]     ,; // Matrícula do Funcionário
                              _aSAsP[nContar,02]     ,; // Nº da SA
                              _aSAsP[nContar,03]     ,; // Item
                              Strzero(nNumGravar,10) }) // Numeração
    
       Next nContar

       // Atualiza o Código de Entrega no campo CP_SCOM
       For nContar := 1 to Len(aEntregas)

          cSql := ""
          cSql := "UPDATE " + RetSqlName("SCP")
          cSql += "   SET CP_SCOM    = '" + Alltrim(aEntregas[nContar,4]) + "'"
          cSql += " WHERE CP_FILIAL  = '" + Alltrim(cFilAnt)              + "'"                        
          cSql += "   AND CP_NUM     = '" + Alltrim(aEntregas[nContar,2]) + "'" 
          cSql += "   AND CP_ITEM    = '" + Alltrim(aEntregas[nContar,3]) + "'"
          cSql += "   AND D_E_L_E_T_ = ' '"

          lResult := TCSqlExec(cSql)

          If lResult < 0        
             MsgAlert(TCSQLERROR())
          Endif           

       Next nContar

	   // Realiza a impressão dos comprovantes de entrega dos materiais
       If MsgYesNo("Deseja imprimir o Comprovante de Entrega do Processamento " + aControle[1] + " ?")
          U_RCOMPEPI(1, aControle[1]) 
       Endif   
	
	   // Gera Pedido de Venda conforme seleção de Processados
	   u_xPVSA(_aSAsP)
	   
//   END TRANSACTION
                 
Return(_lMov)

/*/{Protheus.doc} grvCASCP
//Atualização de dados de CA nos itens da SA (scp) 
@author  Celso Rene
@since 14/02/2019
@version 1.0
@type function/*/
Static Function grvCASCP(_aSA)
	
	dbSelectArea("SCP")
	dbSetOrder(1)
	If dbSeek(xFilial("SCP") + _aSA[2] + _aSA[3] )
	   RecLock("SCP", .F.)
	   SCP->CP_XNUMCAP := _aSA[8]
	   MsUnlock()
	EndIf
	
Return() 

/*/{Protheus.doc} TelaZNF
//tela customizada selecao de S.A.(s) a serem baixadas
@author  Celso Rene
@since 14/02/2019
@version 1.0
@type function
/*/
Static Function TelaZNF()

	Private oChk       	:= Nil
	Private _aCabec	   	:=	{}
	Private _aItens	   	:= {}
	Private _cQuery	   	:= ""

	Private lMark      	:= .F.
	Private lChk	   	:= .F.
	Private oOk        	:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
	Private oNo        	:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
	Private oLbx 		:= Nil
	Private oDlg

	Private oFont1      := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Private oComboBox1
	Private nComboBox1 	:= 1

	DEFINE MSDIALOG oDlg TITLE "Listagem S.A.(s) a serem pré requisitadas e baixadas - EPI"  FROM 0,0 TO 530,900 PIXEL

	@ 014,010 LISTBOX oLbx VAR cVar FIELDS HEADER  ""             ,; // 01
	                                               "Num"          ,; // 02
	                                               "Item"         ,; // 03
	                                               "Matricula"    ,; // 04
	                                               "Nome Func."   ,; // 05
	                                               "Produto"      ,; // 06
	                                               "Des. Produto" ,; // 07
	                                               "C.A."         ,; // 08
	                                               "U.M."         ,; // 09
	                                               "Qtd."         ,; // 10
	                                               "Local"        ,; // 11
	                                               "C. Custo"     ,; // 12
	                                               "Obs."         ,; // 13
	                                               "Data Emissão" ,; // 14
	                                               "Prev. Entrega",; // 15
	                                               "Mov."         ,; // 16
	                                               "Unidade"       ; // 17
		      SIZE 435,215 OF oDlg PIXEL ON dblClick(_aVetor[oLbx:nAt,1] := !_aVetor[oLbx:nAt,1],oLbx:Refresh())

	oLbx:SetArray( _aVetor )

	oLbx:bLine := {|| {Iif(_aVetor[oLbx:nAt,1],oOk,oNo)                                 ,; //
	                       _aVetor[oLbx:nAt,2]                                          ,; //
	                       _aVetor[oLbx:nAt,3]                                          ,; //
	                       _aVetor[oLbx:nAt,4]                                          ,; //
	                       _aVetor[oLbx:nAt,5]                                          ,; //
	                       _aVetor[oLbx:nAt,6]                                          ,; //
	                       _aVetor[oLbx:nAt,7]                                          ,; //
	                       _aVetor[oLbx:nAt,8]                                          ,; //
	                       _aVetor[oLbx:nAt,9]                                          ,; //
	                       Transform(_aVetor[oLbx:nAt,10],PesqPict("SCP","CP_QUANT",08)),; //
	                       _aVetor[oLbx:nAt,11]                                         ,; //
	                       _aVetor[oLbx:nAt,12]                                         ,; //
	                       _aVetor[oLbx:nAt,13]                                         ,; //
	                       cValtoChar(_aVetor[oLbx:nAt,14])                             ,; //
	                       cValtoChar(_aVetor[oLbx:nAt,15])                             ,; //
	                       _aVetor[oLbx:nAt,16]                                         ,; //
	                       _aVetor[oLbx:nAt,17]                                         }} //

	oLbx:bLDblClick := { |nRow,nCol,nFlags| EditCpo( oLbx, oLbx:ColPos) }
	
	//ON CLICK( aEval( _aVetor, { |x| x[1] := lChk } ), oLbx:Refresh() )

	@ 234,010 CHECKBOX oChk VAR lChk PROMPT "Marca / Desmarca - Todos" SIZE 90,007 PIXEL OF oDlg ON CLICK( MARCDESMARC(lChk) )
	@ 247,020 Button "Gerar Processo" Size 046,014 PIXEL OF oDlg ACTION( oDlg:End() , ;
		      Iif(MsgYesNo("Confirma C.A. do(s) item(ns) selecionado(s)?", "Confirmar C.A."),xBaixaSA(_aVetor),nil) )
	
	@ 247,080 Button "Sair" Size 045,014 PIXEL OF oDlg ACTION(oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return()		

// Função que marca/desmarca os produtos do Grid de processamento
Static Function MARCDESMARC(kTipo)

   Local nContar := 0
   Local cString := ""

   For nContar := 1 to Len(_aVetor)
       
       If kTipo == .F.
          _aVetor[nContar,01] := .F.
       Else
          // Posiciona o produto a ser validado
          dbSelectArea("SB2")
          dbSetOrder(2) //B2_FILIAL + B2_LOCAL + B2_COD
          dbSeek(xFilial("SB2") + _aVetor[nContar,11] + _aVetor[nContar,06] )
          If ( Found() .And. SaldoSb2() >= _aVetor[nContar,10] )
             _aVetor[nContar,01] := .T.
          Else
             _aVetor[nContar,01] := .F.
             cString := cString + Alltrim(_aVetor[nContar,06]) + " - " + Alltrim(_aVetor[nContar,07]) + Chr(13) + chr(10)
          Endif
       Endif

   Next nContart             

   oLbx:Refresh()
   
   If !Empty(Alltrim(cString))
      MsgAlert("Produtos sem saldo suficiente para serem atendidos:" + chr(13) + chr(10) + ;
               cString, "ATENÇÃO!")
   Endif

Return(.T.)

/*/{Protheus.doc} XTNF
//ExecAuto Funcionario x EPI
@author Celso Rene
@since 12/02/2019
@version 1.0
@type function
/*/
Static Function XTNF()

	Local _aFunc  		:= {}
	Local _aItem  		:= {}
	//Local _nOpcao 		:= 4
	Local _aAreaEPI		:= GetArea()
	//Local _aParam		:= {}
	//Local _cPrdEPI		:= SCP->CP_PRODUTO
	//Local _cMat			:= SCP->CP_SEQFUNC
	Local _cNumSA		:= SCP->CP_NUM + SCP->CP_ITEM

	Private lMSHelpAuto := .F. // para nao mostrar os erro na tela
	Private lMSErroAuto := .F. // inicializa como .F., volta .T. se houver erro

	cmodulo := "MDT"
	modulo	:= 35
	nmodulo	:= 35

	dbSelectArea("TN3")
	//dbSetOrder(2) //TN3_FILIAL+TN3_CODEPI
	//TN3->(DbOrderNickName("XTN3")) //TN3_FILIAL+TN3_CODEPI+TN3_NUMCAP
	dbSetOrder(3)
	dbSeek(xFilial("TN3") + SCP->CP_PRODUTO + SCP->CP_XNUMCAP)
	If Found()
	
		aAdd( _aFunc, {"RA_MAT", SCP->CP_SEQFUNC, Nil } )// Array com a chave, setando no funcionário a ser entregue o EPI.

        // Prepara a hora para gravação. Isso é necessário para não dar chave duplicada na gravação
        aHora[1,2] := Strzero(Int(Val(aHora[1,2])) + 1,2)

        If (Int(Val(aHora[1,2])) + 1) <= 60
           aHora[1,2] := Strzero(Int(Val(aHora[1,2])) + 1,2)
        Else
           aHora[1,1] := Strzero((Int(val(aHora[1,1])) + 1),2)
           aHora[1,2] := "00"
        Endif

        _cHora := aHora[1,1] + ":" + aHora[1,2]

  	    //Dados dos EPI a ser entregue ao funcionário
		aAdd( _aItem, {{"TNF_CODEPI", SCP->CP_PRODUTO , Nil },; // 01
    	 		       {"TNF_FORNEC", TN3->TN3_FORNEC , Nil },; // 02
			           {"TNF_LOJA"	, TN3->TN3_LOJA	  , Nil },; // 03
			           {"TNF_NUMCAP", TN3->TN3_NUMCAP , Nil },; // 04
			           {"TNF_MAT"	, SCP->CP_SEQFUNC , Nil },; // 05
			           {"TNF_QTDENT", SCP->CP_QUANT	  , Nil },; // 06                
			           {"TNF_LOCAL"	, SCP->CP_LOCAL	  , Nil },; // 07
			           {"TNF_ENDLOC", SCP->CP_YLOCALI , Nil },; // 08
			           {"TNF_NSERIE", SCP->CP_YNUMSR  , Nil },; // 09
			           {"TNF_NUMSA"	, SCP->CP_NUM	  , Nil },; // 10
			           {"TNF_ITEMSA", SCP->CP_ITEM	  , Nil },; // 11
			           {"TNF_DTENTR", dDataBase		  , Nil },; // 12
			           {"TNF_HRENTR", _cHora          , Nil }}) // 13

		//MsgAlert("TNF_CODEPI: " + SCP->CP_PRODUTO)
    	//MsgAlert("TNF_FORNEC: " + TN3->TN3_FORNEC)
		//MsgAlert("TNF_LOJA: "   + TN3->TN3_LOJA	 )
		//MsgAlert("TNF_NUMCAP: " + TN3->TN3_NUMCAP)
		//MsgAlert("TNF_MAT: "    + SCP->CP_SEQFUNC)
		//MsgAlert("TNF_QTDENT: " + str(SCP->CP_QUANT))
		//MsgAlert("TNF_LOCAL: "	+ SCP->CP_LOCAL	 )   
		//MsgAlert("TNF_ENDLOC: " + SCP->CP_YLOCALI)   
		//MsgAlert("TNF_NSERIE: " + SCP->CP_YNUMSR )      
		//MsgAlert("TNF_NUMSA: "	+ SCP->CP_NUM	 ) 
		//MsgAlert("TNF_ITEMSA: " + SCP->CP_ITEM	 ) 
		//MsgAlert("TNF_DTENTR: " + Dtoc(dDataBase)) 
		//MsgAlert("TNF_HRENTR: " + _cHora)

		If ( SCP->CP_STATUS == "E" ) //requisitada S.A. //SCP->CP_QUANT == SCP->CP_QUJE

			//dbSetOrder(1)
			//dbSeek(xFilial("TNF") + _aItem[2] + _aItem[3] + _aItem[1] + _aItem[4] + SCP->CP_SEQFUNC + DtoS(_aItem[12]) + _aItem[13] )
			//If (Found())
					
			//EndIf

			//dbSelectArea("TNF")        
			
            // Tratamento para processamento de matrícula em Férias

            kEstaEmFerias := .F.

            If Select("T_FUNCIONARIO") > 0
               T_FUNCIONARIO->( dbCloseArea() )
            EndIf
            
            cSql := ""
            cSql := "SELECT SRA.RA_FILIAL ,"
            cSql += "       SRA.RA_MAT    ,"
	        cSql += "       SRA.RA_SITFOLH,"
	        cSql += "       SRA.R_E_C_N_O_,"
            cSql += "      (SELECT TOP(1) SRH.R_E_C_N_O_   FROM " + RetSqlName("SRH") + " SRH WHERE SRH.D_E_L_E_T_ = '' AND SRH.RH_FILIAL = '" + xFilial("SRH") + "' AND SRH.RH_MAT = SRA.RA_MAT ORDER BY SRH.R_E_C_N_O_ DESC) AS REG_SRH," 
            cSql += "      (SELECT TOP(1) SRH2.R_E_C_D_E_L_ FROM " + RetSqlName("SRH") + " SRH2 WHERE SRH2.D_E_L_E_T_ = '' AND SRH2.RH_FILIAL = '" + xFilial("SRH") + "' AND SRH2.RH_MAT = SRA.RA_MAT ORDER BY SRH2.R_E_C_N_O_ DESC) AS DEL_SRH,"
         	cSql += "      (SELECT TOP(1) SR8.R_E_C_N_O_   FROM " + RetSqlName("SR8") + " SR8 WHERE SR8.D_E_L_E_T_ = '' AND SR8.R8_FILIAL = '" + xFilial("SR8") + "' AND SR8.R8_MAT = SRA.RA_MAT ORDER BY SR8.R_E_C_N_O_ DESC) AS REG_SR8," 
	        cSql += "      (SELECT TOP(1) SR82.R_E_C_D_E_L_ FROM " + RetSqlName("SR8") + " SR82 WHERE SR82.D_E_L_E_T_ = '' AND SR82.R8_FILIAL = '" + xFilial("SR8") + "' AND SR82.R8_MAT = SRA.RA_MAT ORDER BY SR82.R_E_C_N_O_ DESC) AS DEL_SR8 "  
            cSql += "  FROM " + RetSqlName("SRA") + " SRA "
            cSql += " WHERE SRA.RA_FILIAL  = '" + xFilial("SRA")        + "'"
            cSql += "   AND SRA.RA_MAT     = '" + Alltrim(SCP->CP_SEQFUNC) + "'"
            cSql += "   AND SRA.RA_SITFOLH = 'F'"
            cSql += "   AND SRA.D_E_L_E_T_ = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FUNCIONARIO", .T., .T. )

            If T_FUNCIONARIO->( EOF() )
            
               kEstaEmFerias := .F.
               
            Else   
            
               kEstaEmFerias := .T.

               // Limpa o campo RA_SIT_FOLH do funcionário para liberar a entrega dl EPI/EPC
               cSql := ""
               cSql := "UPDATE " + RetSqlName("SRA") 
               cSql += "   SET RA_SITFOLH = ''"
               cSql += " WHERE RA_FILIAL  = '" + xFilial("SRA") + "'"
               cSql += "   AND RA_MAT     = '" + Alltrim(T_FUNCIONARIO->RA_MAT)    + "'" 
               cSql += "   AND D_E_L_E_T_ = ''"

               lResult := TCSqlExec(cSql)

               If lResult < 0        
                  MsgAlert(TCSQLERROR())
               Endif           

               // Elimina o registro da tabela SRH
               cSql := ""
               cSql := "UPDATE " + RetSqlName("SRH") 
               cSql += "   SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = " + Alltrim(Str(T_FUNCIONARIO->REG_SRH))
               cSql += " WHERE RH_FILIAL   = '" + xFilial("SRH") + "'"
               cSql += "   AND RH_MAT      = '" + Alltrim(T_FUNCIONARIO->RA_MAT)    + "'" 
               cSql += "   AND R_E_C_N_O_  =  " + Alltrim(Str(T_FUNCIONARIO->REG_SRH))

               lResult := TCSqlExec(cSql)

               If lResult < 0        
                  MsgAlert(TCSQLERROR())
               Endif           
               
               // Elimina o registro da tabela SR8
               cSql := ""
               cSql := "UPDATE " + RetSqlName("SR8") 
               cSql += "   SET D_E_L_E_T_ = '*' , R_E_C_D_E_L_ = " + Alltrim(Str(T_FUNCIONARIO->REG_SR8))
               cSql += " WHERE R8_FILIAL   = '" + xFilial("SR8") + "'"
               cSql += "   AND R8_MAT      = '" + Alltrim(T_FUNCIONARIO->RA_MAT)    + "'" 
               cSql += "   AND R_E_C_N_O_  =  " + Alltrim(Str(T_FUNCIONARIO->REG_SR8))

               lResult := TCSqlExec(cSql)

               If lResult < 0        
                  MsgAlert(TCSQLERROR())
               Endif           

            Endif
            
            //nao funciona o execauto se nao incluir esse trecho...
			cAliasTLW := GetNextAlias()
			cArquivTLW := ""
			MDT695TLW( @cArquivTLW )

			dbSelectArea("SRA")
			dbSetOrder(1)
			dbSeek(xFilial("SRA") + _aItem[1][5][2] )

			dbSelectArea("SB2")
			dbSetOrder(1)
			dbSeek(xFilial("SB2") + _aItem[1][1][2] + _aItem[1][7][2] )

			dbSelectArea("SBF")
			dbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE                                                                                       
			dbSeek(xFilial("SBF") + _aItem[1][7][2] + _aItem[1][8][2] + _aItem[1][1][2] + _aItem[1][9][2]  )
			
			dbSelectArea("TNF")			
            // Executa o Execauto da rotina MDTA695
			MSExecAuto({|x,z,y,w| MDTA695(x,z,y,w)},, _aFunc, _aItem, 4 )

            // Retorna registros em cado de matrícula estar em férias
            If kEstaEmFerias == .T.
            
               // Retorna o registro da Matrícula para a situação em Férias
               cSql := ""
               cSql := "UPDATE " + RetSqlName("SRA") 
               cSql += "   SET RA_SITFOLH = 'F'"
               cSql += " WHERE RA_FILIAL  = '" + xFilial("SRA") + "'"
               cSql += "   AND RA_MAT     = '" + Alltrim(T_FUNCIONARIO->RA_MAT)    + "'" 
               cSql += "   AND D_E_L_E_T_ = ''"

               lResult := TCSqlExec(cSql)

               pmerro:=TCSQLERROR()

               If lResult < 0        
                  MsgAlert(TCSQLERROR())
               Endif           

               // Retorna o registro da tabela SRH
               cSql := ""
               cSql := "UPDATE " + RetSqlName("SRH") 
               cSql += "   SET D_E_L_E_T_ = '' , R_E_C_D_E_L_ = " + Alltrim(Str(0))
               cSql += " WHERE RH_FILIAL   = '" + xFilial("SRA") + "'"
               cSql += "   AND RH_MAT      = '" + Alltrim(T_FUNCIONARIO->RA_MAT)    + "'" 
               cSql += "   AND R_E_C_N_O_  =  " + Alltrim(Str(T_FUNCIONARIO->REG_SRH))

               lResult := TCSqlExec(cSql)

               If lResult < 0        
                  MsgAlert(TCSQLERROR())
               Endif           
               
               // Retorna o registro da tabela SR8
               cSql := ""
               cSql := "UPDATE " + RetSqlName("SR8") 
               cSql += "   SET D_E_L_E_T_ = '' , R_E_C_D_E_L_ = " + Alltrim(Str(0))
               cSql += " WHERE R8_FILIAL   = '" + xFilial("SR8") + "'"
               cSql += "   AND R8_MAT      = '" + Alltrim(T_FUNCIONARIO->RA_MAT)    + "'" 
               cSql += "   AND R_E_C_N_O_  =  " + Alltrim(Str(T_FUNCIONARIO->REG_SR8))

               lResult := TCSqlExec(cSql)

               If lResult < 0        
                  MsgAlert(TCSQLERROR())
               Endif           
            
            Endif

			If (lMSErroAuto)

				MostraErro()
				MsgAlert("Problema ao executar operação automática - Funcionário x EPI.","# Falha rotina automática MDTA695!")
			Else
                                        
	  			_aRea2 	 := GetArea()	
	  			_aReaTNF := TNF->(GetArea())
	  			dbSelectArea("TNF")
	  			dbSetOrder(6) //TNF_FILIAL+TNF_NUMSA+TNF_ITEMSA
	  			dbSeek(xFilial("TNF") + _cNumSA )
	  			If ( Found() ) 

				  	_aSD3 := {}

				  	if (Empty(TNF->TNF_NUMSEQ))
						_aSD3 := xTNFSD3(TNF->TNF_CODEPI , TNF->TNF_QTDENT, TNF->TNF_LOCAL, TNF->TNF_ENDLOC,TNF->TNF_NSERIE, SCP->CP_CC)
					endif
		
					_lTNF := .T.
					
					//data recibo entregue
					dbSelectArea("TNF")
					RecLock("TNF", .F.)
					TNF->TNF_DTRECI := dDataBase + 1
					if (Len(_aSD3) > 0 .and. Empty(TNF->TNF_NUMSEQ))
						TNF->TNF_NUMSEQ := _aSD3[1]
						TNF->TNF_CUSTO  := _aSD3[2]
					endif
					TNF->(MsUnLock())

					_aSD3 := {}

					//MsgInfo("Gerado registro Funcionário x EPI: " + _cMat + " - " + _cPrdEPI + " - S.A. + item:" + _cNumSA)
						
	   			Else			
//					_lTNF := .T.

					MsgAlert("Não foi possível vincular o Funcionário " + Alltrim(SCP->CP_SEQFUNC) + ;
					         " com o EPI "                              + Alltrim(SCP->CP_PRODUTO) + ;
					         " da SA/Item "                             + Alltrim(SCP->CP_NUM)     + ;
					         "/"                                        + Alltrim(SCP->CP_ITEM)    + ;
					         ". Verifique no Medicina e Segurança" ,"ATENÇÃO!") 
				EndIf     
				
	 			RestArea(_aRea2)
	 			RestArea(_aReaTNF)

			EndIf
                    
		Endif
	
	EndIf

	cmodulo := "EST"
	modulo	:= 04
	nmodulo	:= 04

	RestArea(_aAreaEPI)

Return(_lTNF)

/*/{Protheus.doc} XZZD
//Execucao manual de Equipe x EPC
@author Gregory Araujo
@since 11/04/2019
@version 1.0
@type function
/*/
Static Function XZZD()
	
	Local aRecno	:= {}
	Local aDesc		:= {}
	Local aEst		:= {}
	//Local aPerg		:= {}
	//Local aRet		:= {}
	Local aCombo	:= {}
	Local nX		:= 0
	Local nNumDias	:= 0
	Local nDescFun	:= 0
	Local nCount 	:= 0
	Local cAli		:= ""
	Local cQuery		:= ""
	
	Local _aAreaEPC	:= GetArea()
	//Local _aParam	:= {}
	Local _cPrdEPC	:= SCP->CP_PRODUTO
	Local _cEqp		:= SCP->CP_SEQFUNC
	//Local _cNumSA	:= SCP->CP_NUM + SCP->CP_ITEM
	Local _nQuant	:= SCP->CP_QUANT
	Local _cEtiq	:= Space(12) //(TamSX3("ZZD_ETIQ")[1]) 
	Local _nMotv	:= 0
	Local _lAtend	:= .T. 
	Local _dDtDevol	:= Date()
	Local _lDevol	:= .F.
	Local _cSeqD3
	Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
	Private lMSErroAuto := .F. // inicializa como .F., volta .T. se houver erro
	
	//Verificar nas tabelas ZZ4 E ZZD se ja existe o vinculo do produto em questáo com a equipe
	dbSelectArea("ZZ4")
	dbSetOrder(1)
	dbSeek(xFilial("ZZ4") + Alltrim(_cEqp) + Space(6 - Len(Alltrim(_cEqp))))
	If Found()
	
		dbSelectArea("ZZD")
		dbSetOrder(2)
		dbSeek(xFilial("ZZD") + _cPrdEPC)
		If Found()		

           // ------------------------------------------------------------------------------------------------------------------------------------------ //			
           // Perguntas foram eliminadas conforme orientação recebidas via skype no dia 18/09/2019, conforme abaixo:                                     //
           // 1) Pergunta no Processamento: "O Produto ... já está vinculado com a Equipe... Deseja realizar a devolução?" Isac, qual a resposta padrão? //
           //    RF: NÃO DEVE APARECER ESSA JANELA, QUANDO DO ATENDIMENTO. ESSA OPÇÃO DEVE SER UTILIZADA, QUANDO NECESSÁRIA NO MODULO MEDICINA           //
           //    Claudio: Harald, favor responder com "N" e eliminar a pergunta                                                                          //
           //                                                                                                                                            //
           // 2) Pergunta no Processamento: "Deseja realizar o Atendimento mesmo assim?" Isac, qual a resposta padrão?                                   //
           //    RF: NÃO NECESSITA APARECER ESSA MENSAGEM                                                                                                //
           //    Claudio: Harald, favor responder com "S" e eliminar a pergunta                                                                          //
           // ------------------------------------------------------------------------------------------------------------------------------------------ //
		   //If MsgYesNo("O Produto "+Alltrim(_cPrdEPC)+" já está vinculado com a equipe "+Alltrim(_cEqp)+". Deseja realizar a devolução?")
		   //		
		   //	//Pedir uma data para realizar a devolucao
		   //	aAdd( aPerg, { 1, "Data de Devoluçáo"	, _dDtDevol  , "@D", "",, ".T.", 08, .T. } )
		   //	If ParamBox( aPerg, "Devoluçáo", @aRet )				
		   //	   If Len( aRet ) >= 0
		   //	 	  _dDtDevol  := aRet[1]
		   //		  _lDevol	:= .T.
		   //	   EndIf				
		   //	EndIf
		   //		
		   //Else
		   //	If !MsgYesNo("Deseja realizar o atendimento do item mesmo assim?")
		   //		_lAtend := .F.
		   //	EndIf
		   //EndIf                
	
	       // Resposta da pergunta com S
		   _lAtend := .T.

		EndIf				

	EndIf
		
    // Realiza o atendimento
	If _lAtend
			
		If ( SCP->CP_STATUS == "E" ) //requisitada S.A. //SCP->CP_QUANT == SCP->CP_QUJE
			
			dbSelectArea("ZZ4")
			dbSetOrder(1)
			dbSeek(xFilial("ZZ4") + Alltrim(_cEqp) + Space(6 - Len(Alltrim(_cEqp))))
			If Found()
				
				BEGIN TRANSACTION				
					
					//se a data de devolucao nao estiver em branco e irá realizar devolução
					If !Empty(_dDtDevol) .and. _lDevol
					
						//aAdd(aCposZZD, {"ZZD_DTDEVO", _dDtDevol})
						//aAdd(aCposZZD, {"ZZD_INDDEV", "1"})
				
						//se no acols nao estiver em branco a data de devolucao e no registro estiver é porque ainda nao foi lancado o desconto
						//ou se devolveu apos
						dbSelectArea("ZZD")
						dbSetOrder(1)
						dbSeek(xFilial("ZZD") + _cEqp + _cPrdEPC)			
						While ZZD->ZZD_EQUIPE == _cEqp  .AND. ZZD->ZZD_CODEPC == _cPrdEPC .AND. ZZD->(!EoF())
						  	
						  	If ZZD->ZZD_INDDEV <> "1"
								
								//Realiza o tratamento para devolucao
								If Empty( ZZD->ZZD_DTDEVO )
									//gravo no vetor aDesc para fazer o desconto posteriormente
									AADD( aDesc, ZZD->(Recno()) )
								ElseIf ZZD->ZZD_DEV == '3' .AND. ZZD->ZZD_DEV == '4'
									//gravo no vetor aEst para fazer o estorno posteriormente
									If Date() - _dDtDevol < GetMv("ML_DIASLIM")
										AADD(aEst, ZZD->(Recno()))
									EndIf
									
								EndIf								
								
							EndIf
							
							ZZD->(dbSkip())
							
						EndDo
						
					EndIf // Data de devolucao preenchida.
					
					//Montagem das per 
					aAdd(aCombo, "1-Admissional")
					aAdd(aCombo, "2-Desgaste"	)
					aAdd(aCombo, "3-Defeito"	)
					aAdd(aCombo, "4-Perda"		)
					aAdd(aCombo, "5-Roubo"		)
					aAdd(aCombo, "6-Demissional")
					aAdd(aCombo, "7-Outros"		)
					
//					aAdd( aPerg, { 1, "Etiqueta",_cEtiq	   ,"","","","", 40,.F. })
//					aAdd( aPerg, { 2, "Motivo: "+ AllTrim(SCP->CP_OBS), 1, aCombo , 50,,.T.} )
				
//					If ParamBox( aPerg, "Equipe x EPC", @aRet )				
//						If Len( aRet ) >= 0
//							_cEtiq  := aRet[1]
//							_nMotv	:= aRet[2]
//						EndIf				
//					EndIf
					                       
					// Carrega os campos Etiqueta e Motivo para gravação
					_cEtiq  := Space(12)
					_nMotv	:= SCP->CP_MOTI


					Reclock("ZZD", .T.)
					ZZD_FILIAL	:= xFilial("ZZD")
					ZZD_ETIQ	:= _cEtiq 
					ZZD_CODEPC	:= _cPrdEPC
					ZZD_QTDENT	:= _nQuant
					ZZD_DTENTR	:= Date()
					ZZD_MOTIVO	:= cValToChar(_nMotv)
					ZZD_DEV		:= "1" // 1-Em Uso / 2-Aguard. devol. / 3-Devolvido / 4-Nao devolvido
					ZZD_SERIE	:= SCP->CP_YNUMSR
					ZZD_HRENTR	:= Left(Time(), 5)
					ZZD_DTRECI	:= Date()
					ZZD_INDDEV	:= "2" //DEVOLUCAO - 1 - SIM / 2 - NÁO
					ZZD_TIPODV	:= "2" //MOVIM ESTQ- 1 - SIM / 2 - NAO
					ZZD_LOCAL	:= SCP->CP_LOCAL
					ZZD_EQUIPE	:= _cEqp			  
					ZZD_ENDLOC  := SCP->CP_YLOCALI
					MSUnlock()
					AADD(aRecno, ZZD->(Recno()))
			
				
					//percoro todos os itens do browser para movimentar o estoque
					For nX:= 1 To Len(aRecno)
						dbSelectArea("ZZD")
						dbGoTo(aRecno[nX])
						If Empty(ZZD->ZZD_SEQD3)
							_cSeqD3 := Movimenta(ZZD->ZZD_CODEPC, "RE1", 1)
						ElseIf ZZD->ZZD_DEV == "3" .AND. ZZD->ZZD_INDDEV == "1" .AND. ZZD_TIPODV == "1"
							_cSeqD3 := Movimenta(ZZD->ZZD_CODEPC, "DE1", 2)
						EndIf
						If !Empty(_cSeqD3)
							RecLock("ZZD", .F.)
							ZZD->ZZD_TIPODV:= "2"
							ZZD->ZZD_SEQD3 := _cSeqD3
							MsUnlock()
						EndIf
					Next nX
				
					//verifico os itens que devo fazer o desconto em folha
					For nX:= 1 To Len(aDesc)
						dbSelectArea("ZZD")
						dbGoTo(aDesc[nX])
						//alert("Desconto")
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
						nDescFun:= 0
						If Found()
							//pego o numero de dias que o epc deveria durar
							dbSelectArea("SB1")
							dbSetOrder(1)
							dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
							If Found()
								nNumDias:= SB1->B1_PRVALID
								//verifico se o epc nao durou o esperado
								If nNumDias > ZZD->ZZD_DTDEVO-ZZD->ZZD_DTENTR
									nDescFun:= (SB1->B1_UPRC/nNumDias)*(nNumDias-(ZZD->ZZD_DTDEVO-ZZD->ZZD_DTENTR))
								EndIf
								//alert(nDescFun)
				
								//se o epc nao foi devolvido cobro mais 50% do valor
								If ZZD->ZZD_DEV == '4'
									nDescFun+= SB1->B1_UPRC*0.5
								EndIf
								//alert(nDescFun)
				
								//se o desconto der acima do valor do epc, cobro apenas o epc
								If nDescFun > SB1->B1_UPRC
									nDescFun:= SB1->B1_UPRC
								EndIf
								//alert(nDescFun)
								
								cQuery:= " SELECT * "
								cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4 "
								cQuery+= " WHERE ZZ4_EQUIPE = '" + Alltrim(cEquipe) + "' AND "
								cQuery+= "       ZZ4_CODSRA <> '' AND "
								cQuery+= "       "+RetSqlCond("ZZ4")
				
								cAli:= GetNextAlias()
								TCQuery ChangeQuery(cQuery) New Alias &(cAli)
								Count To nCount
								&(cAli)->(dbGoTop())
				
								Do While !&(cAli)->(EOF())
				
									dbSelectArea("SRA")
									dbSetOrder(1)
									dbSeek(xFilial("SRA")+&(cAli)->(ZZ4_CODSRA))
									If Found()
				
										RecLock ("SRK", .T.)
										SRK->RK_FILIAL	:= xFilial ("SRK")		// filial
										SRK->RK_MAT		:= SRA->RA_MAT				// Matricula
										SRK->RK_PD 		:= cVERBEPC //GetMv("ML_VERBEPC")	// Codigo da Verba
										SRK->RK_CC     	:= SRA->RA_CC				// Codigo do CC
										SRK->RK_PARCELA	:= 1
										SRK->RK_VALORTO	:= Round(nDescFun/nCount, 2)	// valor da verba
										SRK->RK_VALORPA	:= round(nDescFun/nCount, 2)				// valor da verba
										SRK->RK_REGRADS	:= 1
										SRK->RK_DTVENC	:= IIF(Day(Date()) > 16, STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE())+1,2)+"15"), STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE()),2)+"15"))
										SRK->RK_DTMOVI	:= ZZD->ZZD_DTDEVO
										SRK->RK_DOCUMEN	:= cValToChar(SRK->(Recno()))
										SRK->RK_OBS		:= "REF. " + IIF(ZZD->ZZD_MOTIVO == "1", "ADMISSIONAL", IIF(ZZD->ZZD_MOTIVO == "2", "DESGASTE", IIF(ZZD->ZZD_MOTIVO == "3", "DEFEITO", IIF(ZZD->ZZD_MOTIVO == "4", "PERDA", IIF(ZZD->ZZD_MOTIVO == "5", "ROUBO", IIF(ZZD->ZZD_MOTIVO == "6", "DEMISSIONAL", "OUTROS")))))) + " EPC " + SB1->B1_DESC
										MsUnLock()
									EndIf
				
									&(cAli)->(dbSkip())
								Enddo
							EndIf
				
							&(cAli)->(dbCloseArea())
				
						EndIf
				
					Next nX
				
					//verifico os itens que devo fazer o estorno na folha
					For nX:= 1 To Len(aEst)
						dbSelectArea("ZZD")
						dbGoTo(aEst[nX])
						//alert("Estorno")
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
						nDescFun:= 0
						If Found()
							//pego o numero de dias que o epc deveria durar
							dbSelectArea("SB1")
							dbSetOrder(1)
							dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
							If Found()
				
								cQuery:= " SELECT * "
								cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4 "
								cQuery+= " WHERE ZZ4_EQUIPE = '" + Alltrim(cEquipe) + "' AND "
								cQuery+= "       ZZ4_CODSRA <> '' AND "
								cQuery+= "       "+RetSqlCond("ZZ4")
				
								cAli:= GetNextAlias()
								TCQuery ChangeQuery(cQuery) New Alias &(cAli)
								Count To nCount
								&(cAli)->(dbGoTop())
				
								Do While !&(cAli)->(EOF())
				
									dbSelectArea("SRA")
									dbSetOrder(1)
									dbSeek(xFilial("SRA")+&(cAli)->(ZZ4_CODSRA))
									If Found()
				
										RecLock ("SRK", .T.)
										SRK->RK_FILIAL	:= xFilial ("SRK")		// filial
										SRK->RK_MAT		:= SRA->RA_MAT				// Matricula
										SRK->RK_PD 		:= cVERBDEV //GetMv("ML_VERBDEV")	// Codigo da Verba
										SRK->RK_CC     	:= SRA->RA_CC				// Codigo do CC
										SRK->RK_PARCELA	:= 1
										SRK->RK_VALORTO	:= SB1->B1_UPRC*0.5		// valor da verba
										SRK->RK_DTVENC	:= IIF(Day(Date()) > 16, STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE())+1,2)+"15"), STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE()),2)+"15"))
										SRK->RK_DTMOVI	:= ZZD->ZZD_DTDEVO
										SRK->RK_DOCUMEN	:= cValToChar(SRK->(Recno()))
										SRK->RK_OBS		:= "REF. " + IIF(ZZD->ZZD_MOTIVO == "1", "ADMISSIONAL", IIF(ZZD->ZZD_MOTIVO == "2", "DESGASTE", IIF(ZZD->ZZD_MOTIVO == "3", "DEFEITO", IIF(ZZD->ZZD_MOTIVO == "4", "PERDA", IIF(ZZD->ZZD_MOTIVO == "5", "ROUBO", IIF(ZZD->ZZD_MOTIVO == "6", "DEMISSIONAL", "OUTROS")))))) + " EPC " + SB1->B1_DESC
										MsUnLock()
									EndIf
				
									&(cAli)->(dbSkip())
								Enddo
							EndIf
				
							&(cAli)->(dbCloseArea())
				
						EndIf
				
					Next nX
				
				END TRANSACTION
				
			EndIf
				
		Endif
	
	EndIf
	
	RestArea(_aAreaEPC)
                                                     
Return(_lAtend)

/*/{Protheus.doc} xPVSA
//Rotina para criar peido de venda do tipo - B - SAs processadas - EPI
@type function
@author Celso Rene
@since 22/03/2019
@version 1.0
/*/
User Function xPVSA(_aSa)

	Local _aPVarea 		:= GetArea()
	Local _aCabPv  		:= Array(0)
	Local _aItemPv 		:= Array(0)
	Local aItensPv 		:= Array(0)
	Local _cItem   		:= StrZero(0,Len(SC6->C6_ITEM))
	//Local _cQuerSA 		:= ""
	Local _lRetPV  		:= .F.
	Local _lPrimeiro	:= .T.
	Local aUnidades     := {}            
    Local nContar       := 0
    Local nJaEsta       := 0
    Local lContido      := .F. 
	Local _z
		
	Private _oDlg
	Private _oButton1
	Private _oButton2
	Private _oGet1
	Private _cGet1 := Space(6)
	Private _oGet2
	Private _cGet2 := Space(2)
	Private _oGet3
	Private _cGet3 := Space(6)
	Private _oGet4
	Private _cGet4 := Space(6)
	Private _oGet5
	Private _cGet5 := "529" //Space(3)
	Private _oSay1
	Private _oSay2
	Private _oSay3
	Private _oSay4
	Private _oSay5
	Private _lRet := .F.
	
    // Carrega o array aUnidades com as unidades selecionadas para geração de pedido de venda por unidade
    For nContar = 1 to Len(_aSA)
		                                                   
		If _aSa[nContar,01] == .T.
		          
		   // Verifica se a unidade do elemento já está contida no array aUnidades
		   lContido := .F.
		   
		   For nJaEsta = 1 to Len(aUnidades)
               If Alltrim(aUnidades[nJaEsta]) == Alltrim(_aSa[nContar,17])
                  lContido := .T.
                  Exit
               Endif
           Next nJaEsta                                   
		   
           If lContido == .F.
              aAdd( aUnidades, _aSa[nContar,17] )
           Endif
           
        Endif

    Next nContar              

    // Abre os pedidos de venda por unidade selecionada
    For nContar = 1 to Len(aUnidades)
    
   	    pergunte("XMATA105",.F.)

	    _lPrimeiro := .T.
        _aCabPv    := {}
   		aItensPv   := {}
   		_aItemPv   := {}
        aAtualizar := {}
                                          
	    For _z:= 1 to Len(_aSa)

		    If Alltrim(_aSa[_z][17]) == Alltrim(aUnidades[nContar]) 
		    
   		       If (_aSa[_z][1] == .T. )
		
			      If (_lPrimeiro)
			
				     If !(TelaPV())
					    Return(.F.)
				     EndIf
			
				     // Efetua a montagem do pedido de venda

                     // Pesquisa o próximo número de acordo SXE e SXF
				     _C5NUM   := GetSxeNum("SC5","C5_NUM")
                     ConfirmSx8()
                             
                     // Carrega o endereço do fornecedor para a mensagem para nota fiscal
                     cMsgNota := ""                 
                     cMsgNota := Alltrim(Posicione("SA2",1,xfilial("SA2") + _cGet1 + _cGet2, "A2_END"))    + ",  " + ;
                                 Alltrim(Posicione("SA2",1,xfilial("SA2") + _cGet1 + _cGet2, "A2_NR_END")) + " - " + ;
                                 Alltrim(Posicione("SA2",1,xfilial("SA2") + _cGet1 + _cGet2, "A2_BAIRRO")) + " "   + ;
                                 Alltrim(Posicione("SA2",1,xfilial("SA2") + _cGet1 + _cGet2, "A2_CEP"))    + " - " + ;
                                 Alltrim(Posicione("SA2",1,xfilial("SA2") + _cGet1 + _cGet2, "A2_MUN"))    + " / " + ;
                                 Alltrim(Posicione("SA2",1,xfilial("SA2") + _cGet1 + _cGet2, "A2_EST"))

                     aAdd(_aCabPv,{ "C5_FILIAL" , xFilial("SC5"), Nil })
				     aAdd(_aCabPv,{ "C5_NUM"    , _C5NUM        , Nil })
				     aAdd(_aCabPv,{ "C5_TIPO"   , "B"           , Nil })
				     aAdd(_aCabPv,{ "C5_CLIENTE", _cGet1   	    , Nil }) // "001315"
				     aAdd(_aCabPv,{ "C5_LOJACLI", _cGet2  	    , Nil }) // "04"
				     aAdd(_aCabPv,{ "C5_CONDPAG", _cGet4        , Nil }) // "002" POSICIONE( "SA2", 1, xFilial("SA2") + "001315" + "04", "A2_COND" )
				     aAdd(_aCabPv,{ "C5_MENNOTA", cMsgNota      , Nil })
				     aAdd(_aCabPv,{ "C5_TPFRETE", "C"           , Nil })
				     aAdd(_aCabPv,{ "C5_TRANSP" , _cGet3        , Nil }) // "000002"
                     aAdd(_aCabPv,{ "C5_CLIENT" , _cGet1        , Nil }) // "001315"
                     aAdd(_aCabPv,{ "C5_LOJAENT", _cGet2        , Nil }) // "04"

				     _lPrimeiro := .F.
				
			      EndIf
						
   			      // Montagem dos itens do pedido de venda
			      _cItem := Soma1(_cItem,2)
		
			      dbSelectARea("SB1")
			      dbSetOrder(1)
			      dbSeek(xFilial("SB1") + _aSa[_z][6] )

			      nValorItem := (_aSa[_z][10] * SB1->B1_UPRC)
		
                  aAdd(_aItemPv, { "C6_FILIAL" , xFilial("SC5") , Nil })
			      aAdd(_aItemPv, { "C6_ITEM"   , _cItem         , Nil })
			      aAdd(_aItemPv, { "C6_PRODUTO", _aSa[_z][6]    , Nil })
			      aAdd(_aItemPv, { "C6_QTDVEN" , _aSa[_z][10]   , Nil })
			      aAdd(_aItemPv, { "C6_PRCVEN" , SB1->B1_UPRC   , Nil })
			      aAdd(_aItemPv, { "C6_TES"    , _cGet5         , Nil })
			      aAdd(_aItemPv, { "C6_CCUSTO" , _aSa[_z][12]   , Nil })
			      aAdd(_aItemPv, { "C6_CC"     , _aSa[_z][12]   , Nil })
			      
                  // Estes dois campos foram criados na tabela SC6 para realizar o vínculo com a tabela das SAs (SCP).
                  // No final do processo, atualiza a coluna CP_NUMPV da tabela de SAs se o processo deu certo.
                  // Os dois campos abaixo não possuem gatilhos nem pontos de entrada vinculados a eles.
			      aAdd(_aItemPv, { "C6_NUMSA"  , _aSa[_z][02]   , Nil })
			      aAdd(_aItemPv, { "C6_ITESA"  , _aSa[_z][03]   , Nil })

                  // Estes campos foram eliminados porque o execauto estava retornando erro ao ser gerado
                  // Analisado juntamente com Cesar
                  // aAdd(_aItemPv, { "C6_PRUNIT" , SB1->B1_UPRC   , Nil })
                  // aAdd(_aItemPv, { "C6_VALOR"  , nValorItem     , Nil })
                  // aAdd(_aItemPv, { "C6_LOCAL"  , _aSa[_z][11]   , Nil })
                  // aAdd(_aItemPv, { "C6_CLI"    , _cGet1         , Nil })
                  // aAdd(_aItemPv, { "C6_LOJA"   , _cGet2         , Nil })
                  // Add(_aItemPv, { "C6_TPOP"   , "F"            , Nil })
                  // aAdd(_aItemPv, { "C6_RATEIO" , "2"            , Nil })
                  // aAdd(_aItemPv, { "C6_INTROT" , "1"            , Nil })
                  // aAdd(_aItemPv, { "C6_TPPTOD" , "1"            , Nil })
                  // aAdd(_aItemPv, { "C6_DESCRI" , _aSa[_z][5]    , Nil })

   			      aAdd( aItensPv, AClone(_aItemPv) )

		       EndIf
		    
		    Endif
		
	    Next _z

   	    If Len(aItensPv) > 0

		   lAutoErrNoFile := .F.  // alteradpo para FALSE por machado 19/08/20 1405hs
		   lMsHelpAuto    := .T.
		   lMsErroAuto    := .F. // necessario a criacao, pois sera atualizado quando houver inconsistencia

		   MsgRun( "Aguarde...Incluindo o Pedido de Venda.", , { || MSExecAuto( { |x,y,z| Mata410( x,y,z ) }, _aCabPv, aItensPv, 3 )})

		   If lMsErroAuto
			  MostraErro()
			  RollBackSx8()
		   Else

			  ConfirmSx8()

              // Atualiza o nº do pedido de venda nos registros correspondente na tabela SCP
              If Select("T_ATUALIZA") > 0
                 T_ATUALIZA->( dbCloseArea() )
              EndIf

              cSql := ""
              cSql := "SELECT C6_FILIAL ,"
              cSql += "       C6_NUM    ,"
              cSql += "       C6_PRODUTO,"
              cSql += "       C6_NUMSA  ,"
              cSql += "       C6_ITESA   "
              cSql += "  FROM SC6" + cEmpAnt + "0"
              cSql += " WHERE C6_FILIAL  = '" + Alltrim(xFilial("SC5")) + "'"
              cSql += "   AND C6_NUM     = '" + Alltrim(_C5NUM)         + "'"
              cSql += "   AND D_E_L_E_T_ = ''"      
        	
              cSql := ChangeQuery( cSql )
              dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATUALIZA", .T., .T. )
                                                                      
              WHILE !T_ATUALIZA->( EOF() )

                 cSql := ""
                 cSql := "UPDATE " + RetSqlName("SCP")
                 cSql += "   SET CP_NUMPV   = '" + Alltrim(T_ATUALIZA->C6_NUM)     + "'"
                 cSql += " WHERE CP_FILIAL  = '" + Alltrim(cFilAnt)                + "'"
                 cSql += "   AND CP_PRODUTO = '" + Alltrim(T_ATUALIZA->C6_PRODUTO) + "'" 
                 cSql += "   AND CP_NUM     = '" + Alltrim(T_ATUALIZA->C6_NUMSA)   + "'"
                 cSql += "   AND CP_ITEM    = '" + Alltrim(T_ATUALIZA->C6_ITESA)   + "'"
                 cSql += "   AND D_E_L_E_T_ = ' '"

                 lResult := TCSqlExec(cSql)

                 If lResult < 0        
                    MsgAlert(TCSQLERROR())
                 Endif           
    		     
    		     T_ATUALIZA->( DbSkip() )
    		     
    		  ENDDO      

			  //MsgInfo("Pedido de venda gerado: " + SC5->C5_NUM + " - Conforme seleção S.A.s.","Gerado P.V.")

			  _lRetPV := .T.
			  If (MsgYesNo("Pedido de Venda gerado com o nº " + Alltrim(SC5->C5_NUM) + ". Deseja visualizar o pedido?","Gerado P.V."))
				 A410Visual( "SC5", SC5->(RecNo()), 2 )
			  EndIf

		   EndIf

   	    EndIf

    Next nContar        
	
	RestArea(_aPVarea)
			
Return(_lRetPV)

//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction                                    
Description                                                                                                                     
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  - Celso Rene                                              
@since 29/03/2019                                                   
/*/                                                             
//--------------------------------------------------------------
Static Function TelaPV()


   DEFINE MSDIALOG _oDlg TITLE "Dados para P.V." FROM 000, 000  TO 200, 280 COLORS 0, 16777215 PIXEL

   // Solicita o código do fornecedor
   @ 010, 004 SAY   _oSay1 PROMPT "Fornecedor" SIZE 030, 007 OF _oDlg COLORS 0, 16777215 PIXEL
   @ 010, 038 MSGET _oGet1 VAR _cGet1          SIZE 040, 010 OF _oDlg COLORS 0, 16777215 F3 "SA2" PIXEL VALID( xTrazCodLoja() )
   
   // Solicita o código da loja do fornecedor
   @ 010, 086 SAY   _oSay2 PROMPT "Loja" SIZE 016, 007 OF _oDlg COLORS 0, 16777215 PIXEL
   @ 010, 106 MSGET _oGet2 VAR _cGet2    SIZE 020, 010 OF _oDlg COLORS 0, 16777215 PIXEL
   
   // Solicita o código da transportadora
   @ 025, 004 SAY   _oSay3 PROMPT "Transportad." SIZE 030, 007 OF _oDlg COLORS 0, 16777215 PIXEL
   @ 025, 039 MSGET _oGet3 VAR _cGet3            SIZE 040, 010 OF _oDlg COLORS 0, 16777215 F3 "SA4" PIXEL

   // Solicita o código da condição de pagamento
   @ 043, 003 SAY   _oSay4 PROMPT "Cond. Pag." SIZE 030, 007 OF _oDlg COLORS 0, 16777215 PIXEL
   @ 043, 039 MSGET _oGet4 VAR _cGet4          SIZE 040, 010 OF _oDlg COLORS 0, 16777215 F3 "SE4" PIXEL VALID(ExistCpo("SE4"))

   // Solicita o TES
   @ 060, 005 SAY   _oSay5 PROMPT "Tes" SIZE 016, 007 OF _oDlg COLORS 0, 16777215 PIXEL
   @ 060, 039 MSGET _oGet5 VAR _cGet5   SIZE 020, 010 OF _oDlg COLORS 0, 16777215 F3 "SF4" VALID(_cGet5 > "500") PIXEL
    
   @ 083, 053 BUTTON _oButton1 PROMPT "OK"   SIZE 037, 012 OF _oDlg Action( ValidPV()) PIXEL
// @ 083, 098 BUTTON _oButton2 PROMPT "Sair" SIZE 037, 012 OF _oDlg Action(_oDlg:End()) PIXEL
  
   ACTIVATE MSDIALOG _oDlg Centered
   
Return(_lRet)

// Função que carrega o código da loja depois da digitação do código do fornecedor
Static Function xTrazCodLoja()

   Local cSql  := ""
   Local cCNPJ := ""

   If Select("T_IGUAIS") > 0
      T_IGUAIS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD ,"
   cSql += "       A2_LOJA,"
   cSql += "       A2_CGC  "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD = '" + Alltrim(_cGet1) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IGUAIS", .T., .T. )
  
   If T_IGUAIS->( EOF() )                  
      _cGet1 := Space(06) 
      _cGet2 := Space(02)
      Return(.T.)
   Endif
   
   If Len(T_IGUAIS->A2_CGC) <= 11
      _cGet2 := Space(02)
      Return(.T.)
   Endif
   
   cCNPJ := Substr(T_IGUAIS->A2_CGC,01,08)

   // Pesquisa a loja do fornecedor
   If Select("T_PEGALOJA") > 0
      T_PEGALOJA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A2_COD ,"
   cSql += "       A2_LOJA,"
   cSql += "       A2_CGC  "
   cSql += "  FROM " + RetSqlName("SA2")
   cSql += " WHERE A2_COD     = '" + Alltrim(_cGet1) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY A2_LOJA DESC"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEGALOJA", .T., .T. )

   If T_PEGALOJA->( EOF() )
      _cGet1 := Space(06) 
      _cGet2 := Space(02)
      Return(.T.)
   Endif
                                     
   Count To nRegistro
   T_PEGALOJA->( dbGoTop() )
   Count To nRegistro
   T_PEGALOJA->( dbGoTop() )
   
   _cGet2 := IIF(nRegistro == 1, T_PEGALOJA->A2_LOJA, Space(02) )
                                      
Return(.T.)            

/*/{Protheus.doc} ValidPV
//validadndo tela informacoes para geracoes do p.v.
@type function
@author Celso Rene
@since 29/03/2019
@version 1.0
@see (links_or_references)
/*/
Static Function ValidPV()

	_lRet:= .T.

	_oDlg:End()

Return(_lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Movimenta ³ Autor ³Ezequiel Pianegonda    ³ Data ³13/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Movimento de Requisicao e/ou Devolucao nos Arquivos de ³±±
±±³          ³ Movimentacao Interna (SD3).                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numero Sequencial gravado no SD3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProd = Codigo do Produto                                   ³±±
±±³          ³ cCod = Codigo da movimentação (DE1/RE1)                     ³±±
±±³          ³ nTpMov= 1. Requisicao/ 2. Devolucao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
static Function Movimenta(cProd, cCod, nTpMov)
	
	Local aArea	:= GetArea()
	Local cTpMov:= ""
	Local cSeqD3:= ""
	Local aAuto	:= {}
	Local cResp	:= cUserName
	Local cQuery:= ""
	Local cAli	:= GetNextAlias()
	Local cCC	:= ""

	Private lMSErroAuto:= .F.

	If nTpMov == 1
		cTpMov:= SuperGetMv("ML_SAIEPI", .F., "")
	Else
		cTpMov:= SuperGetMv("ML_ENTEPI", .F., "")
	EndIf

	If Empty(cTpMov)
		MsgStop("Não foi informado o tipo de movimentação do estoque. Confira os parâmetros ML_ENTEPI e ML_SAIEPI. Alteração de estoque não efetuada!")
		Return ""
	EndIf
	
	dbSelectArea("AA1")
	dbSetOrder(1)
	if MsSeek(xFilial("AA1")+ZZD->ZZD_EQUIPE)
		cCC := AA1->AA1_CC
	else
		MsgStop("Não foi encontrado o Centro de Custo da equipe("+Alltrim(ZZD->ZZD_EQUIPE)+"). Verificar no cadastro de Equipes(AA1). ")
		Return ""
	EndIf

	Dbselectarea("SRA")
	Dbsetorder(1)
	MsSeek(xfilial("SRA")+cResp)

	Dbselectarea("SB2")
	Dbsetorder(1)
	If !MsSeek(xfilial("SB2") + cProd + ZZD->ZZD_LOCAL)
		CriaSB2(cProd, ZZD->ZZD_LOCAL)
		// A FUNCAO ACIMA NAO LIBERA O REGISTRO
		MsUnlock("SB2")
	EndIf

	Dbselectarea("SBF")
	Dbsetorder(4)
	Dbseek(xfilial("SBF") + cProd + ZZD->ZZD_SERIE)
	
	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek(xFilial("SB1") + cProd)

    // Localizo o lote com saldo maior ou igual a quantidade a ser movimentada
	cQuery:= " SELECT * "
	cQuery+= "   FROM " + RetSqlName("SBF") + " SBF "
	cQuery+= "  WHERE BF_PRODUTO = '" + Alltrim(cProd)           + "'"
	cQuery+= "    AND BF_LOCAL   = '" + Alltrim(ZZD->ZZD_LOCAL)  + "'"
	cQuery+= "    AND BF_LOCALIZ = '" + Alltrim(ZZD->ZZD_ENDLOC) + "'"
	cQuery+= "    AND BF_NUMSERI = '" + Alltrim(ZZD->ZZD_SERIE)  + "'"
	cQuery+= "    AND " + RetSqlCond("SBF")

	TcQuery ChangeQuery(cQuery) new alias cAli

	dbselectarea("SB8")
	dbgoto(cAli->R_E_C_N_O_)
	cSeqD3:= ProxNum()
	aAuto:= {}
	AADD(aAuto, {"D3_FILIAL",	xFilial('SD3'),												NIL})
	AADD(aAuto, {"D3_TM",		cTpMov,														NIL})
	AADD(aAuto, {"D3_COD",		cProd,														NIL})
	AADD(aAuto, {"D3_UM",		SB1->B1_UM,													NIL})
	AADD(aAuto, {"D3_QUANT",	ZZD->ZZD_QTDENT,											NIL})
	AADD(aAuto, {"D3_CF",		cCod,														NIL})
	AADD(aAuto, {"D3_CONTA",	SB1->B1_CONTA,												NIL})
	AADD(aAuto, {"D3_LOCAL",	ZZD->ZZD_LOCAL,												NIL})
	AADD(aAuto, {"D3_EMISSAO",	ZZD->ZZD_DTENTR,											NIL})
	AADD(aAuto, {"D3_NUMSEQ",	cSeqD3,														NIL})
	AADD(aAuto, {"D3_SEGUM",	SB1->B1_SEGUM,												NIL})
	AADD(aAuto, {"D3_QTSEGUM",	ConvUm(cProd, 1, 0, 2),										NIL})
	AADD(aAuto, {"D3_GRUPO",	SB1->B1_GRUPO,												NIL})
	AADD(aAuto, {"D3_TIPO",		SB1->B1_TIPO,												NIL})
	AADD(aAuto, {"D3_CHAVE",	SubStr(cCod, 2, 1)+If(cCod == 'DE4', '9', '0'),				NIL})
	AADD(aAuto, {"D3_NUMSERI",	ZZD->ZZD_SERIE,												NIL})
	AADD(aAuto, {"D3_USUARIO",	Left(cUserName,20),											NIL})
	AADD(aAuto, {"D3_CC",		cCC,														NIL})
	AADD(aAuto, {"D3_LOCALIZ",	ZZD->ZZD_ENDLOC,											NIL})
	AADD(aAuto, {"D3_LOTECTL",	cAli->BF_LOTECTL,											NIL})
	cAli->(dbCloseArea())
	
	aAuto:= u_OrdAuto(aAuto)
	
	
	If Len(aAuto) > 0
		DbSelectArea("SD3")
		MSExecAuto({|x, y| mata240(x, y)}, aAuto, 3)
		If lMSErroAuto
			DisarmTransaction() // Adicionado por Felipe S. Raota - 23/05/14
			MsgAlert("Houve erro na movimentação de estoque. Verifique na tela seguinte.", procname ())
			MostraErro()
 		    DisarmTransactio()
		ElseIf nTpMov == 1
			//AADD(_aDados, ZZD->(RECNO()))
			//armazenava para gerar comprovantes da forma antiga. hoje será impresso pelo picklist
		EndIf 
	EndIf

	RestArea(aArea)
Return cSeqD3
                       
// Função disparada no checar do grid de Processar
Static Function EditCpo( oListBox, nColPos )

   Local cProd
   Local cCA
   Local cAlmo
   Local cQtdPro
   Local aDim  
   Local aCAs := {}
   Local bSetGet
   //Local bValid
   //Local bChange
   //Local bWhen := {|| .T. }
   Local oDlg
   Local oComboBox
   Local oGet

   //	MsgInfo( "Linha do grid: " + cValToChar( oListBox:nAT ) + ENTER +;
   //			 "Coluna do grid: " + cValToChar( nColPos ) )

   // Verifica se o produto selecionado possui saldo disponível para poder atener o produto
   cCodSA    := oListBox:aArray[oListBox:nAT, P_NUMSA]
   cProd     := oListBox:aArray[oListBox:nAT, P_PRODUTO]
   cItemPSA  := oListBox:aArray[oListBox:nAT, P_ITEMSA]
   cCA       := oListBox:aArray[oListBox:nAT, P_CA]
   cAlmo     := oListBox:aArray[oListBox:nAT, P_ALMOX]
   cQtdPro   := oListBox:aArray[oListBox:nAT, P_QTDSA]
   cEndereco := oListBox:aArray[oListBox:nAt, P_ENDE]
   cSerieLoc := oListBox:aArray[oListBox:nAt, P_SERIE]

   // Posiciona o produto a ser validado
   dbSelectArea("SB2")
   dbSetOrder(2) //B2_FILIAL + B2_LOCAL + B2_COD
   dbSeek(xFilial("SB2") + cAlmo + cProd )
   If ( Found() .And. SaldoSb2() >= cQtdPro )
   Else                  
      _aVetor[oLbx:nAt,1] := .F.
      MsgAlert("Produto não possui saldo suficiente para ser atendido. Verifique!", "ATENÇÃO")
      Return( Nil )
   Endif   	     	
 
   If nColPos = 1 //Coluna de seleção
      _aVetor[oLbx:nAt,1] := !_aVetor[oLbx:nAt,1]
   ElseIf nColPos = P_CA
	
      cProd   := oListBox:aArray[oListBox:nAT, P_PRODUTO]
      cCA     := oListBox:aArray[oListBox:nAT, P_CA]
      cAlmo   := oListBox:aArray[oListBox:nAT, P_ALMOX]
      cQtdPro := oListBox:aArray[oListBox:nAT, P_QTDSA]

      // Veririca se o produto selecionado possui saldo para atender a SA
      dbSelectArea("SB2")
	  dbSetOrder(2) //B2_FILIAL + B2_LOCAL + B2_COD
	  dbSeek(xFilial("SB2") + cAlmo + cProd )
	  If ( Found() .and. SaldoSb2() >= cQtdPro )
	  Else                  
   	     _aVetor[oLbx:nAt,1] := .F.
	     MsgAlert("Produto não possui saldo suficiente para ser atendido. Verifique!", "ATENÇÃO")
         Return( Nil )
      Endif   	     
	
      DbSelectArea("TN3")
      dbSetOrder(2)
      If dbSeek(xFilial("TN3") + cProd) 
	
         While TN3->( !EOF() ) .And. TN3->TN3_CODEPI == cProd
            If !Empty(TN3->TN3_NUMCAP)
			   AADD( aCAs, TN3->TN3_NUMCAP )
			EndIf
			TN3->( DbSkip() )
		 EndDo
										
	  Else
	 	 // Como não tem outros locais então deixa o que já foi carregado
		 AADD( aCAs, oListBox:aArray[oListBox:nAT, nColPos] )
	  EndIf
	
      // Quando o usuário selecionar uma opção do array, também irá limpar os campos: "Ender. Orig", "Lote", "Sub Lote" e "Número Série".
	  bSetGet := { |u| IF( PCount() == 0,;
				oListBox:aArray[oListBox:nAT][nColPos],;
	   		    oListBox:aArray[oListBox:nAT][nColPos] := u ) }
	  GetCellRect( @oListBox , @aDim ) //Obtenho as Coordenadas da Celula
	
	  // Crio um popup para o combo
	  DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 STYLE nOR( WS_VISIBLE , WS_POPUP ) PIXEL WINDOW oListBox:oWnd
	  oComboBox := TComboBox():New(0,0,bSetGet,aCAs,80,50,oDlg,NIL,NIL,{ || .T. },NIL,NIL,.T.,NIL,NIL,.T.,NIL,.F.,NIL,NIL,NIL,oListBox:aArray[oListBox:nAT][nColPos])
	  oComboBox:Move( -2 , -2 , ( ( aDim[ 4 ] - aDim[ 2 ] ) + 4 ) , ( ( aDim[ 3 ] - aDim[ 1 ] ) + 4 ) )
	  oDlg:Move( aDim[1] , aDim[2] , ( aDim[4]-aDim[2] ) , ( aDim[3]-aDim[1] ) )
	  @ 0, 0 BUTTON oBtn PROMPT "" SIZE 0,0 OF oDlg
	  oBtn:bGotFocus	:= { || oDlg:nLastKey := VK_RETURN, oDlg:End(0) }
	  ACTIVATE MSDIALOG oDlg
		
   EndIf
                       
   // Verifica se o produto informado é um EPI
   // Se for, verifica se este já está cadastro na tabela TN3.
   // Se não tiver, obriga a informalção de C.A.
   xMatricula := oListBox:aArray[oListBox:nAT, P_MATRICULA]
   xProduto   := oListBox:aArray[oListBox:nAT, P_PRODUTO]
   xNomeProd  := oListBox:aArray[oListBox:nAT, P_NOMEPRO]
   xNumeroCA  := oListBox:aArray[oListBox:nAT, P_CA]
   xxTitulo   := ""

//   // Verifica se EPI já está presente na tabela TNF pendente
//   // Se não tiver, dá mensagme dizendo que funcionário está em férias mas epi pode ser entregue
//   // Se tiver pendente,dá mensagem e diz que não vai poder ser feito pelo customizado só pelo padrão
//   If Select("T_LIBERACAO") > 0
//      T_LIBERACAO->( dbCloseArea() )
//   EndIf
//               
//   cSql := ""
//   cSql := "SELECT TNF_FILIAL,"
//   cSql += "       TNF_CODEPI,"
//   cSql += "       TNF_MAT   ,"
//   cSql += "       TNF_INDDEV,"
//   cSql += "       TNF_DTDEVO,"
//   cSql += "       R_E_C_N_O_ AS REGTNF"
//   cSql += "  FROM " + RetSqlName("TNF")
//   cSql += " WHERE TNF_FILIAL = '" + Alltrim(cFilAnt)    + "'"
//   cSql += "   AND TNF_MAT    = '" + Alltrim(xMatricula) + "'"
//   cSql += "   AND TNF_CODEPI = '" + Alltrim(xProduto)   + "'"
//   cSql += "   AND TNF_INDDEV = '2'"
//   cSql += "   AND D_E_L_E_T_ = '' "
//   cSql += " ORDER BY R_E_C_N_O_ DESC"
//               
//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LIBERACAO", .T., .T. )
//         
//   If !T_LIBERACAO->( EOF() )
//      If T_LIBERACAO->TNF_INDDEV == '2'  
//         MsgAlert("O EPI " + Alltrim(xProduto) + " - " + Alltrim(xNomeProd) + " que você deseja entregar nesta SA, possui registro(s) do mesmo EPI em aberto." + chr(13) + chr(10) + chr(13) + chr(10) + ;
//                  "Para que este EPI possa ser entregue, este deve ser processado pelo processo padrão.", "ATENÇÃO!")
//         oListBox:aArray[oListBox:nAT, 01] := .F.                                           
//         oListBox:Refresh()
//         Return( NIL )
//      Endif                                          
//   Endif

   dbSelectArea("SRA")
   dbSetOrder(1)
   If dbSeek( xFilial("SRA") + xMatricula )
// If (Found() .and. SRA->RA_SITFOLH <> "D") // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 
//   If Found()

      // Verifica se a matrícula está ativa
      If Empty(Alltrim(SRA->RA_SITFOLH))
         xxTitulo := ""
      Else
         Do Case
            Case Alltrim(SRA->RA_SITFOLH) == "D"
                 xxTitulo := "DEMITIDO(A)"
            Case Alltrim(SRA->RA_SITFOLH) == "F"
  //               xxTitulo := "FÉRIAS"
               xxTitulo := ""
            Otherwise
                 xxTitulo := ""
         EndCase

   // -------------------------------------------------------------------------------------------------------- //         
   // Este caso foi retirado porque:                                                                           //
   // Inicialmente o Cliente pediu para somente liberar se a situação da matrícula estivesse em branco.        //
   // No decorrer da utilização do Sistema, Cliente foi informando que matrículas em férias deveriam passar.   //
   // Depois, matrículas afastadas também.                                                                     //
   // Por fim, por orientação do Cliente, somente matriculas demitidas deverão ser trancadas.                  //
   // Dia 28/10/2019 - Conforme solicitação do Cliente, a Situação de Férias deve fazer novamente parte do     //
   //                  teste abaixo, ou seja, se a matríula estiver em férias, o Sistema não deve permitir que //
   //                  seja entregue o EPI/EPC.                                                                //
   // -------------------------------------------------------------------------------------------------------- //
   // ESTÁ COMENTADO POR UMAQUESTÕ DE HISTÓRICO                                                                //
   // -------------------------------------------------------------------------------------------------------- //
   //         Do Case                                                                                          //
   //            Case Alltrim(SRA->RA_SITFOLH) == "A"                                                          //
   //                 xxTitulo := "AFASTADO(A)"                                                                //
   //            Case Alltrim(SRA->RA_SITFOLH) == "F"                                                          //
   //                 xxTitulo := "FÉRIAS"                                                                     //
   //            Case Alltrim(SRA->RA_SITFOLH) == "D"                                                          //
   //                 xxTitulo := "DEMITIDO(A)"                                                                //
   //            Case Alltrim(SRA->RA_SITFOLH) == "T"                                                          //
   //                 xxTitulo := "TRANSFERIDO(A)"                                                             //
   //            Otherwise                                                                                     //
   //                 xxTitulo := ""                                                                           //
   //         EndCase                                                                                          //
   // -------------------------------------------------------------------------------------------------------- //

         If !Empty(Alltrim(xxTitulo))

            If Upper(Alltrim(xxTitulo)) == "FÉRIAS"
         
               // Verifica se EPI já está presente na tabela TNF pendente
               // Se não tiver, dá mensagme dizendo que funcionário está em férias mas epi pode ser entregue
               // Se tiver pendente,dá mensagem e diz que não vai poder ser feito pelo customizado só pelo padrão
               If Select("T_LIBERACAO") > 0
                   T_LIBERACAO->( dbCloseArea() )
               EndIf
               
               cSql := ""
               cSql := "SELECT TNF_FILIAL,"
               cSql += "       TNF_CODEPI,"
               cSql += "       TNF_MAT   ,"
               cSql += "       TNF_INDDEV,"
               cSql += "       TNF_DTDEVO,"
               cSql += "       R_E_C_N_O_ AS REGTNF"
               cSql += "  FROM " + RetSqlName("TNF")
               cSql += " WHERE TNF_FILIAL = '" + Alltrim(cFilAnt)    + "'"
               cSql += "   AND TNF_MAT    = '" + Alltrim(xMatricula) + "'"
               cSql += "   AND TNF_CODEPI = '" + Alltrim(xProduto)   + "'"
               cSql += "   AND TNF_INDDEV = '2'"
               cSql += "   AND D_E_L_E_T_ = '' "
               cSql += " ORDER BY R_E_C_N_O_ DESC"
               
               cSql := ChangeQuery( cSql )
               dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LIBERACAO", .T., .T. )
         
               If !T_LIBERACAO->( EOF() )
                  If T_LIBERACAO->TNF_INDDEV == '2'  
                     MsgAlert("A matrícula " + Alltrim(xMatricula) + " - " + Alltrim(SRA->RA_NOME) + " encontra-se na situação EM FÉIRAS."                                 + chr(13) + chr(10) + chr(13) + ;
                              "O EPI " + Alltrim(xProduto) + " - " + Alltrim(xNomeProd) + " que você deseja entregar nesta SA, possui registro(s) do mesmo EPI em aberto." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                              "Para que este EPI possa ser entregue, este deve ser processado pelo processo padrão.", "ATENÇÃO!")
                     oListBox:aArray[oListBox:nAT, 01] := .F.                                           
                     oListBox:Refresh()
                     Return( NIL )
                  Endif                                          
               Endif

            Else
               MsgAlert("Funcionário(a): " + Alltrim(SRA->RA_NOME)           + CHR(13) + CHR(10) + ;
                        "encontra-se na situação " + Alltrim(xxTitulo) + "." + CHR(13) + CHR(10) + ;
                        "Atendimento não permitido para esta situação.", "ATENÇÃO!")
               oListBox:aArray[oListBox:nAT, 01] := .F.                                           
               oListBox:Refresh()
               Return( NIL )
            Endif   
         Endif                              
      Endif 
        
      // Verificase se tem informação de nº da CA em caso de matrícula para atendimento de EPIs
      dbSelectArea("TN3")
      dbSetOrder(3) //TN3->(DbOrderNickName("XTN3")) //TN3_FILIAL+TN3_CODEPI+TNF_NUMCAP
      dbSeek(xFilial("TN3") + xProduto + xNumeroCA)  
      If ( ! Found() )
         MsgAlert("Quando informado uma matricula, o Produto - E.P.I. e C.A. devem constar como EPI no sistema -  TN3!","# Produto EPI - C.A.!")
         oListBox:aArray[oListBox:nAT, 01] := .F.
      EndIf


      dbCloseArea()

   Endif   

   // Verifica se o produto selecionado tem controle de locaização indicado em seu cadastro.
   // Se tiver indicado Localização = Sim, verifica se o produto possui informação do endereço.
   If Select("T_ENDERECO") > 0
      T_ENDERECO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B1_COD    ,"
   cSql += "       B1_DESC   ,"
   cSql += "       B1_LOCALIZ "
   cSql += "  FROM " + RetSqlName("SB1")
   cSql += " WHERE B1_COD = '" + Alltrim(cProd) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
        	
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ENDERECO", .T., .T. )

   If Alltrim(T_ENDERECO->B1_LOCALIZ) == "S"

      // Se endereço = branco, verifica na BF se existe saldo por endereço.
      // Se existir, caoptura o endereço com maior saldo, se não, deixa em branco
      If Empty(Alltrim(cEndereco))
         xxEndereco := U_SOLTENDER( cProd, cAlmo )   
         If Empty(Alltrim(xxEndereco))
            MsgAlert("Produto " + Alltrim(T_ENDERECO->B1_COD) + " - " + Alltrim(T_ENDERECO->B1_DESC) + " possui controle de localização porém, o endereço não foi informado na SA e nem foi encontrado nenhum endereço co saldo para esse produto. Produto não será atendido.", "ATENÇÃO!")
            oListBox:aArray[oListBox:nAT, 01] := .F.
         Else
         
            cEndereco := xxEndereco
            oListBox:aArray[oListBox:nAt, P_ENDE] := cEndereco            
         
            // Atualiza na tabela SCP o endereço encontrado
            cSql := ""
            cSql := "UPDATE " + RetSqlName("SCP")
            cSql += "   SET CP_YLOCALI = '" + Alltrim(cEndereco) + "'"
            cSql += " WHERE CP_FILIAL  = '" + Alltrim(cFilAnt)   + "'"                        
            cSql += "   AND CP_NUM     = '" + Alltrim(cCodSA)    + "'" 
            cSql += "   AND CP_ITEM    = '" + Alltrim(cItemPSA)  + "'"
            cSql += "   AND D_E_L_E_T_ = ' '"

            lResult := TCSqlExec(cSql)

            If lResult < 0        
               MsgAlert("Erro ao gravar o endereço do produto " + Alltrim(T_ENDERECO->B1_COD) + " - " + Alltrim(T_ENDERECO->B1_DESC) + ". Produto não será atendido.", "ATENÇÃO!")
               oListBox:aArray[oListBox:nAT, 01] := .F.
               //MsgAlert(TCSQLERROR())
            Endif           
         
         Endif
         
         //MsgAlert("Produto " + Alltrim(T_ENDERECO->B1_COD) + " - " + Alltrim(T_ENDERECO->B1_DESC) + " possui controle de localização porém, o endereço não foi informado na SA. Produto não será atendido.", "ATENÇÃO!")
         //oListBox:aArray[oListBox:nAT, 01] := .F.

      Else
         // Verifica se o endereço informado necessita de informação do número de série
         If Select("T_NUMEROSERIE") > 0
            T_NUMEROSERIE->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT SBF.BF_FILIAL ,"
         cSql += "       SBF.BF_PRODUTO,"
         cSql += "       SBF.BF_LOCAL  ,"
         cSql += "       SBF.BF_LOCALIZ,"
         cSql += "       SBF.BF_NUMSERI,"
         cSql += "       SBF.BF_QUANT   "
         cSql += "  FROM " + RetSqlName("SBF") + " SBF "
         cSql += " WHERE SBF.BF_FILIAL  = '" + Alltrim(cFilAnt)   + "'"
         cSql += "   AND SBF.BF_PRODUTO = '" + Alltrim(cProd)     + "'"
         cSql += "   AND SBF.BF_LOCALIZ = '" + Alltrim(cEndereco) + "'"
         cSql += "   AND SBF.BF_NUMSERI = '" + Alltrim(cSerieLoc) + "'"
         cSql += "   AND SBF.BF_QUANT  <> 0" 
         cSql += "   AND SBF.D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NUMEROSERIE", .T., .T. )

         If T_NUMEROSERIE->( EOF() )
            MsgAlert("Não existe saldo disponível para o nº de série do produto " + Alltrim(T_ENDERECO->B1_COD) + " - " + Alltrim(T_ENDERECO->B1_DESC) + ".Verifique Endereço/Nº de Série informado na SA.", "ATENÇÃO!")
            oListBox:aArray[oListBox:nAT, 01] := .F.
         Endif            
         
      EndIf

   Endif

   oListBox:Refresh()
	
Return( NIL )                           

/*
Mensagem EPI x FUNCAO (EPI por Função )               )
If lRet .And. Type( "lHist695" ) == "L" .And. !lHist695 .And. !l695Auto//Se não for histórico //Caso rotina automática, sempre entrega o EPI.

			Dbselectarea("TNB")
			Dbsetorder(1)
			If !Dbseek( xFilial( "TNB" ) + If( lSigaMdtps , cCliMdtps , "" ) + SRA->RA_CODFUNC + cCODEPI )
				cQryFil := GetNextAlias()
				BeginSQL Alias cQryFil
					SELECT TL0.TL0_EPIGEN,TL0.TL0_FORNEC,TL0.TL0_LOJA,TL0.TL0_EPIFIL FROM %table:TL0% TL0
						JOIN %table:TN3% TN3 ON	TN3.TN3_CODEPI	= TL0.TL0_EPIGEN AND
												TN3.TN3_FORNEC	= TL0.TL0_FORNEC AND
												TN3.TN3_LOJA	= TL0.TL0_LOJA AND
												TN3.%notDel%
						JOIN %table:TNB% TNB ON	TNB.TNB_CODFUN	= %exp:SRA->RA_CODFUNC% AND
												TNB.TNB_CODEPI	= TL0.TL0_EPIGEN AND
												TNB.%notDel%
						WHERE TL0.TL0_EPIFIL = %exp:cCODEPI% AND TL0.%notDel%
				EndSQL
				If ( cQryFil )->( EoF() )
					lRet := MsgYesNo( STR0041 , STR0020 ) //"EPI não consta no cadastro de EPI x Função, confirmar a entrega do EPI?"###"ATENÇÃO"
				Endif
				( cQryFil )->( dbCloseArea() )
			Endif
		Endif


SELECT * FROM TN3010 WHERE TN3_CODEPI = '000192' AND D_E_L_E_T_ = ''

tnb, checa ra_codfunc + codigo EPI
*/ 


/*/{Protheus.doc} xTNFSD3
//Gera movimentacao interna - sistema nao gera movimentacao estoque no execauto executado via modulo do estoque.
@author Celso Rene                                                           
@since 03/02/2021
@version 1.0
@type function
/*/
Static Function xTNFSD3(_xProd , _xQtd, _xLocal, _xLocaliz, _xSerie, _xCC)

Local _aRetSD3  := {}
Local aSd3		:= {}
lMsErroAuto 	:= .F.


dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") + _xProd)

dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2") + _xProd + _xLocal )

dbSelectArea("SBF")
dbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE                                                                                       
dbSeek(xFilial("SBF") + _xLocal + _xLocaliz + _xProd + _xSerie  )

dbSelectArea("SD3")


aadd(aSd3,{"D3_TM"		,'510'			,})
aadd(aSd3,{"D3_FILIAL"	,xFilial("SD3")	,})
aadd(aSd3,{"D3_COD"		,_xProd			,})
aadd(aSd3,{"D3_UM"		,SB1->B1_UM		,})
aadd(aSd3,{"D3_LOCAL"	,_xLocal		,})
aadd(aSd3,{"D3_QUANT"	,_xQtd			,})
aadd(aSd3,{"D3_LOCALIZ"	,_xLocaliz		,})
aadd(aSd3,{"D3_NUMSERI"	,_xSerie		,})
aadd(aSd3,{"D3_CC"		,_xCC			,})
aadd(aSd3,{"D3_EMISSAO"	,dDataBase		,})
MSExecAuto({|x,y| mata240(x,y)},aSd3,3)

if (!lMsErroAuto)
	_aRetSD3 := {SD3->D3_NUMSEQ,SD3->D3_CUSTO1}

	dbSelectArea("SD3")
	RecLock("SD3",.F.) 
	SD3->D3_TM 	:= "999"
	SD3->(MsUnlock())

	dbSelectArea("SDB")
	dbSetOrder(1) //DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM  
	dbSeek(xFilial("SDB") + SD3->D3_COD + SD3->D3_LOCAL + SD3->D3_NUMSEQ + SD3->D3_DOC)
	if (Found())
		RecLock("SDB",.F.)
		SDB->DB_TM 	:= "999"
		SDB->(MsUnlock())
	endif
endif


Return(_aRetSD3)
