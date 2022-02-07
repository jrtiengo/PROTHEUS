#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"                                                                                                                       
#Include "tbiconn.ch"

                                                                                                      
/*/{Protheus.doc} RPICKSCP
//Rel Picklist - SCP - sol. ao armazem 
@author SOLUTIO
@since 28/01/2019
@version 1.0
@type function
/*/
User Function RPICKSCP()
	u_STCPRCRL(1, 0, "")
Return

/*/{Protheus.doc} RSEPPIC
//Rel Separação por Unidade - SCP - sol. ao armazem 
@author SOLUTIO
@since 28/01/2019
@version 1.0
@type function
/*/
User Function RSEPPIC()
	u_STCPRCRL(3, 0, "")
Return

/*/{Protheus.doc} RCOMPEPI
//Rel Comprovante - SCP - sol. ao armazem 
@author SOLUTIO
@since 28/01/2019
@version 1.0
@type function
Parâmetros: nOpc      = Indica o código do relatório a ser impresso
            kChamada  = Indica por onde o programa foi chamado sendo 0 -> Pelo Menu, 1 -> Pelo Processamento
            kProcesso = Indica o código do processo a ser impresso quando este foi chamado pelo Processamento
/*/
User Function RCOMPEPI(kChamada, kProcesso)
	u_STCPRCRL(2, kChamada, kProcesso)
Return

/*/{Protheus.doc} STCPRCRL
//Processa o relatório de acordo com a opção selecionada
@author SOLUTIO
@since 28/01/2019
@version 1.0
@type function
Parâmetros: nOpc      = Indica o código do relatório a ser impresso
            kChamada  = Indica por onde o programa foi chamado sendo 0 -> Pelo Menu, 1 -> Pelo Processamento
            kProcesso = Indica o código do processo a ser impresso quando este foi chamado pelo Processamento
/*/
User Function STCPRCRL(nOpc, kChamada, kProcesso)

	Private cDesc1  := "Solicitação ao Armazém"
	Private cDesc2  := ""
	Private cDesc3  := ""
	Private cPict   := ""
	Private imprime := .T.
	Private aOrd    := {}
	Private nLin    := 81

	//                      12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
	//                               1         2         3         4         5         6         7         8         9        10        11        12        13        14        1
	Private titulo      := "Solicitações ao Armazém - EPI/EPC"
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "M"
	Private nomeprog    := "RPICKSCP"
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private cPerg  		:= "RPICKSCP  "                                                                             
	Private cLogo       := "lgrl" + cEmpAnt + ".bmp"
	Private wnrel

    Do Case
       Case nOpc == 1
            cDesc1 := "Rel. PickList"
       Case nOpc == 2
            cDesc1 := "Reimp. Rel. Comprovantes"
       Case nOpc == 3
            cDesc1 := "Rel. Separ. Un. (Opcional)"
    EndCase            

	wnrel := SetPrint("SCP",NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)  &&1,.T.)

 	If aReturn[5] == 1 // OPCAO OK - SetPrint	
		SetDefault(aReturn,"SCP")         
		nTipo := If(aReturn[4]==1,15,18)

		If nLastKey == 27
			Return
		Endif

		RptStatus({|| RunReport(nOpc, kChamada, kProcesso) },Titulo)

	EndIf	

Return()

/*/{Protheus.doc} RunReport
//Relatorio de picklist
@author Celso Rene
@since 29/01/2019
@version 1.0
@type function
/*/
Static Function RunReport(nOpc, kChamada, kProcesso)

    Local cEntrega  := Space(10)
    Local cControle := Space(06)
    Local oGet1
    Local oGet2

    Local cMemo1	 := ""
    Local oMemo1

    Local cQuefazer  := 0

	Local _cQuery    := ""
	Local _cMatAnt	 := ""
	Local _lPMat	 := .T. 	
	Local nAuxLin
	Private	_cUnid	 := ""
	Private	_aUnids	 := {}

    Private oDlgControle

	Private dDtEmDe	 := Date()
	Private dDtEmAte := Date()
	Private Cabec1   := ""
	Private Cabec2   := ""
    Private nPagina  := 0  
	
	If nOpc == 2
	   _cUnid := "X"
	Else
   	   u_SelUnid()
		
	   For nUn := 1 to Len(_aUnids)
		   If _aUnids[nUn,1]
			  If(!Empty(_cUnid))
				_cUnid += "," 
			  EndIF			
			  _cUnid += "'"+ AllTrim(_aUnids[nUn, 2]) + "'"
		   EndIf
	   Next nUn
    Endif
	
	If !Empty(_cUnid)
		
		If nOpc = 1 //Escolhido menu de Relatório PickList

			Cabec1 := "PRODUTO            DESCRIÇÃO                               U.M.           QTD.  "
	
			_cQuery := " SELECT SCP.CP_PRODUTO,SCP.CP_UM , "
			_cQuery += " ISNULL(SUM(SCP.CP_QUANT),0) - ISNULL(SUM(SCP.CP_QUJE),0) AS SALDO " 
			_cQuery += " FROM " + RetSqlName("SCP") + " SCP " 
			_cQuery += " WHERE SCP.D_E_L_E_T_ = '' "
			_cQuery += " AND SCP.CP_XROT = 'XMATA105' "
			_cQuery += " AND SCP.CP_FILIAL = '" + xFilial("SCP") + "'"
			_cQuery += " AND SCP.CP_PREREQU = '' "
			_cQuery += " AND SCP.CP_STATSA <> 'B' "
			_cQuery += " AND SCP.CP_STATSA <> 'R' "
			_cQuery += " AND SCP.CP_QUANT > SCP.CP_QUJE " 
			_cQuery += " AND SCP.CP_XUNID IN (" + _cUnid + ")"
			_cQuery += " AND SCP.CP_EMISSAO BETWEEN '" + DtoS(dDtEmDe) + "' AND '" + DtoS(dDtEmAte) + "'" + chr(13)
			_cQuery += " GROUP BY SCP.CP_PRODUTO,SCP.CP_UM "   
			
			_cQuery := ChangeQuery( _cQuery )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery ), "TSCP", .F., .T. )
			
			dbGoTop()
			Count To nRegs
			SetRegua( nRegs )
			dbGoTop()
			
			While !TSCP->( Eof() ) 
		
				If nLin > 80 // Salto de Pagina. Neste caso o formulario tem 68 linhas...
					nLin++
					Cabec("Rel. Sol. Armazem - EPI: PRODUTOS",Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			
					nLin := 8
				Endif   
		
				@nLin,01  PSAY Alltrim(TSCP->CP_PRODUTO)
				@nLin,20  PSAY Left(Posicione("SB1",1,xfilial("SB1") + TSCP->CP_PRODUTO,"B1_DESC"),30)
				@nLin,60  PSAY TSCP->CP_UM
				@nLin,75  PSAY Transform(TSCP->SALDO,PesqPict("SCP","CP_QUANT",8))		
		
				nLin++
				IncRegua()
				
				TSCP->( dbSkip() )
		
			EndDo
		
			TSCP->(dbCloseArea())
		
		ElseIf nOpc = 2 // olhido Menu de Comprovante de Entrega 
			
            // Abre janela para solicitar o nº do controle a ser impresso/reimpresso
            If kChamada == 0

               DEFINE MSDIALOG oDlgControle TITLE "Reimpressão Comprovante de Entrega" FROM C(178),C(181) TO C(317),C(495) PIXEL

               @ C(002),C(005) Say "Para realizar reimpressão de Comprovante de Entrega, informe:" Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgControle
               @ C(015),C(033) Say "Nº Comprovante:"                                               Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgControle
               @ C(022),C(045) Say "OU"                                                            Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgControle
               @ C(030),C(033) Say "Nº Processo:"                                                  Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgControle

               @ C(044),C(005) GET oMemo1 Var cMemo1 MEMO Size C(148),C(001) PIXEL OF oDlgControle

               @ C(014),C(077) MsGet oGet1 Var cEntrega  Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgControle
               @ C(029),C(077) MsGet oGet2 Var cControle Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgControle
   
	           @ C(049),C(041) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgControle ACTION( cQuefazer := 1, oDlgControle:End() )
               @ C(049),C(080) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgControle ACTION( cQuefazer := 2, oDlgControle:End() )

               ACTIVATE MSDIALOG oDlgControle CENTERED 

               If cQuefazer == 2
                  set device to screen
  			      dbCommitAll()
			      SET PRINTER TO
    		      MS_FLUSH()	 	
                  Return(.T.)
               Endif
               
               If Empty(Alltrim(cControle)) .AND. Empty(Alltrim(cEntrega))
                  set device to screen
  			      dbCommitAll()
			      SET PRINTER TO
    		      MS_FLUSH()	 	
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nº do Controle ou Comprovante de Entrega a ser impresso não informado.")
                  Return(.T.)
               Endif

               If !Empty(Alltrim(cControle)) .AND. !Empty(Alltrim(cEntrega))
                  set device to screen
  			      dbCommitAll()
			      SET PRINTER TO
    		      MS_FLUSH()	 	
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Informe Nº do Controle OU Comprovante de Entrega para impressão.")
                  Return(.T.)
               Endif

            Else
            
               cControle := kProcesso
               
            Endif

			nLin:= 81
			
			_cQuery2 := ""
			_cQuery2 := "SELECT SCP.CP_SEQFUNC ,"                              + chr(13)
			_cQuery2 += "       SCP.CP_NUM    ,"                               + chr(13)
            _cQuery2 += "       SCP.CP_XNUMCAP,"                               + chr(13)
			_cQuery2 += "       SCP.CP_ITEM   ,"                               + chr(13)
			_cQuery2 += "       SCP.CP_PRODUTO,"                               + chr(13)
			_cQuery2 += "       SCP.CP_UM     ,"                               + chr(13)
			_cQuery2 += "       SCP.CP_EMISSAO,"                               + chr(13)
			_cQuery2 += "       SCP.CP_DATPRF ,"                               + chr(13) 
            _cQuery2 += "       SCP.CP_XUNID  ,"                               + chr(13)
            _cQuery2 += "       SCP.CP_NCON   ,"                               + chr(13)
            _cQuery2 += "       SCP.CP_SCOM   ,"                               + chr(13)
            _cQuery2 += "       SCP.CP_YNUMSR ,"                               + chr(13)
			_cQuery2 += "      (SELECT X5_DESCRI "                             + chr(13)
			_cQuery2 += "         FROM " + RetsqlName("SX5")                   + chr(13)
			_cQuery2 += "        WHERE X5_TABELA = 'ZD'"                       + chr(13)
			_cQuery2 += "          AND X5_CHAVE  = SCP.CP_XUNID"               + chr(13)
			_cQuery2 += "          AND D_E_L_E_T_ = '') AS NOME_UNIDADE,"      + chr(13)
			_cQuery2 += "       SCP.CP_QUANT - SCP.CP_QUJE AS SALDO "          + chr(13)
			_cQuery2 += "  FROM " + RetSqlName("SCP") + " SCP "                + chr(13)
			_cQuery2 += " WHERE SCP.D_E_L_E_T_ = '' "                          + chr(13)
			_cQuery2 += "   AND SCP.CP_XROT    = 'XMATA105' "                  + chr(13)
			_cQuery2 += "   AND SCP.CP_FILIAL  = '" + xFilial("SCP") + "'"     + chr(13)
		  //_cQuery2 += "   AND SCP.CP_PREREQU = '' "                          + chr(13)
			_cQuery2 += "   AND SCP.CP_STATSA <> 'B' "                         + chr(13)
			_cQuery2 += "   AND SCP.CP_STATSA <> 'R' "                         + chr(13)
			_cQuery2 += "   AND SCP.CP_QUANT   > SCP.CP_QUJE "                 + chr(13)

            If !Empty(Alltrim(cControle))
   			   _cQuery2 += "   AND SCP.CP_NCON    = '" + Alltrim(cControle) + "'" + chr(13) 
            Endif
            
            If !Empty(Alltrim(cEntrega))
   			   _cQuery2 += "   AND SCP.CP_SCOM    = '" + Alltrim(cEntrega)  + "'" + chr(13) 
            Endif

			_cQuery2 += "  ORDER BY SCP.CP_XUNID, SCP.CP_SEQFUNC,SCP.CP_PRODUTO "            + chr(13)
				
	  	  //_cQuery2 += "   AND SCP.CP_EMISSAO BETWEEN '" + DtoS(dDtEmDe) + "' AND '" + DtoS(dDtEmAte) + "'" + chr(13)

			_cQuery2 := ChangeQuery( _cQuery2 )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery2 ), "TSCP2", .F., .T. )
		
	        If TSCP2->( EOF() )
               set device to screen
  			   dbCommitAll()
			   SET PRINTER TO
    		   MS_FLUSH()	 	
	 		   TSCP2->(dbCloseArea())
	           MsgAlert("Atenção!"                                                      + chr(13) + chr(10) + chr(13) + chr(10) + ;
	                    "Não existem dados a serem impressos para este nº de Controle." + chr(13) + chr(10) + chr(13) + chr(10) + ;
	                    "Verifique!")
	           Return(.T.)
	        Endif            

			dbGoTop()
			Count To nRegs2
			SetRegua( nRegs2 )
			dbGoTop()
		
			If (!TSCP2->( Eof() ))
                _Unidade := TSCP2->CP_XUNID
				_cMatAnt := TSCP2->CP_SEQFUNC
			EndIf
		
	        //Cabec1      := ""//"MATR./EQUIPE  NOME                        PRODUTO      DESCRIÇÃO                   U.M.  QTD.         N. S.A.  ITEM  EMISSÃO "
			//              12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
			//                       1         2         3        4         5         6         7         8         9        10        11        12        13        14   
	
	        nLin           := 0
	        nPagina        := 0
			lPrimeiro      := .T.
            lCabecalhoEPI  := .T.			
            nTotalLinhaPg  := 50          
            lProdutoCabeca := ""

            // Imprime o cabeçalho do relatório
		    Cabec("Comprovante de Entrega Nº " + Alltrim(TSCP2->CP_SCOM),Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			

            // Imprime o cabeçalho do COmprovante de Entrega de EPI
            CabecalhoComprovante()

            // Imprime os dados dos comprovantes
            TSCP2-> (DbGoTop() )
            
            While !TSCP2->( Eof() )
                                                               
               // Imprime selecionando unidades
               If Alltrim(TSCP2->CP_XUNID) == Alltrim(_Unidade)
               
                  If Alltrim(TSCP2->CP_SEQFUNC) == Alltrim(_cMatAnt)   
               
                     // Imprime os dados do funcionário
                     If lPrimeiro == .T.
    
                        If Select("T_CONSULTA") > 0
                           T_CONSULTA->( dbCloseArea() )
                        EndIf
                   
                        cSqx := ""
                        cSqx := "SELECT SRA.RA_FILIAL,"
                        cSqx += "       SRA.RA_MAT   ,"
                        cSqx += "       SRA.RA_NOME  ,"
                        cSqx += "       SRA.RA_RG    ,"
                        cSqx += "       SRA.RA_CC    ,"
                        cSqx += "      (SELECT CTT_DESC01" 
//                      cSqx += "         FROM " + RetSqlNAme("CTT") 
                        cSqx += "         FROM CTT" + cEmpAnt + "0" 
                        cSqx += "        WHERE CTT_FILIAL = SRA.RA_FILIAL" 
                        cSqx += "          AND CTT_CUSTO  = SRA.RA_CC    " 
                        cSqx += "          AND D_E_L_E_T_ = '') AS CENTRO_CUSTO,"
                        cSqx += "      (SELECT RJ_DESC "
//                      cSqx += "         FROM " + RetSqlName("SRJ")
                        cSqx += "         FROM SRJ" + cEmpAnt + "0"
                        cSqx += "        WHERE RJ_FUNCAO  = SRA.RA_CODFUNC"
                        cSqx += "          AND D_E_L_E_T_ = '') AS NOME_FUNCAO," 
                        cSqx += "       SRA.RA_NASC   ,"
                        cSqx += "       SRA.RA_ADMISSA,"
                        cSqx += "       SRA.RA_CODFUNC"
//                      cSqx += "  FROM " + RetSqlName("SRA") + " SRA "
                        cSqx += "  FROM SRA" + cEmpAnt + "0" + " SRA "
                        cSqx += " WHERE SRA.RA_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
                        cSqx += "   AND SRA.RA_MAT     = '" + Alltrim(_cMatAnt) + "'"
                        cSqx += "   AND SRA.D_E_L_E_T_ = ''"
                            
                        cSqx := ChangeQuery( cSqx )
                        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSqx), "T_CONSULTA", .T., .T. )

                        If !T_CONSULTA->( EOF() )
                           lEPICABE       := .T.
                           lProdutoCabeca := "EPI"

                           @ nLin,001 psay "FUNCIONÁRIO.....: " + Alltrim(T_CONSULTA->RA_MAT) + " - " + Alltrim(T_CONSULTA->RA_NOME)
                           @ nlin,100 psay "RG......: "         + Alltrim(T_CONSULTA->RA_RG)

                           nLin++
                           nTotalLinhaPg--
            
                           @ nLin,001 psay "CENTRO DE CUSTO.: " + Alltrim(T_CONSULTA->RA_CC) + " - " + Alltrim(T_CONSULTA->CENTRO_CUSTO)
                           nLin++
                           nTotalLinhaPg--

                           @ nLin,001 psay "FUNÇÃO..........: " + Alltrim(T_CONSULTA->RA_CODFUNC) + " - " + Alltrim(T_CONSULTA->NOME_FUNCAO) 
                           nLin++    
                           
                           nTotalLinhaPg--

                           @ nLin,001 psay "NASCIMENTO......: " + Substr(T_CONSULTA->RA_NASC,07,02) + "/" + ;
                                                                  Substr(T_CONSULTA->RA_NASC,05,02) + "/" + ;
                                                                  Substr(T_CONSULTA->RA_NASC,01,04)
                           @ nLin,100 psay "ADMISSÃO: "         + Substr(T_CONSULTA->RA_ADMISSA,07,02) + "/" + ;
                                                                  Substr(T_CONSULTA->RA_ADMISSA,05,02) + "/" + ;
                                                                  Substr(T_CONSULTA->RA_ADMISSA,01,04)
                           nLin++    
                           
                           nTotalLinhaPg--

                           @ nLin,001 psay "IDADE...........: " + Alltrim(Str(Year(Date()) - INT(VAL(Substr(T_CONSULTA->RA_NASC,01,04))))) + " ANOS"

                        Else
                           lEPICABE := .F.

                           // Imprime dados do EPC - EUIPE/CENTRO DE CUSTO                        @ nLin,001 psay "EQUIPE..........: " &&&+ Alltrim(Str(Year(Date()) - INT(VAL(Substr(T_CONSULTA->RA_NASC,01,04))))) + " ANOS"
                           If Select("T_CONSULTA") > 0
                              T_CONSULTA->( dbCloseArea() )
                           EndIf

                           cSql := ""
                           cSql := "SELECT AA1.AA1_CODTEC,"
                           cSql += "       AA1_NOMTEC    ,"
                           cSql += "       AA1.AA1_CC    ,"
                           cSql += "       CTT.CTT_DESC01 "
                           cSql += "  FROM " + RetSqlName("AA1") + " AA1, "
                           cSql += "       " + RetSqlName("CTT") + " CTT  "
                           cSql += " WHERE AA1.AA1_CODTEC = '" + Alltrim(_cMatAnt) + "'"
                           cSql += "   AND AA1.D_E_L_E_T_ = ''"
                           cSql += "   AND CTT.CTT_CUSTO = AA1.AA1_CC"
                           cSql += "   AND CTT.D_E_L_E_T_ = ''"

                           cSql := ChangeQuery( cSql )
                           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

                           If !T_CONSULTA->( EOF() )      
                              lProdutoCabeca := "EPC"
                              @ nLin,001 psay "EQUIPE..........: " + Alltrim(T_CONSULTA->AA1_NOMTEC)
                              nLin++    
                              nTotalLinhaPg--
                              @ nLin,001 psay "CENTRO DE CUSTO.: " + Alltrim(T_CONSULTA->AA1_CC) + " - " + Alltrim(T_CONSULTA->CTT_DESC01)
                              nLin++    
                              nTotalLinhaPg--
                           Else
                              lProdutoCabeca := "CÓDIGO"
                           Endif   
                        Endif
                     
                        lPrimeiro := .F.

                     Endif
                     
                     // Imprime o cabeçalho dos EPI
                     If lCabecalhoEPI == .T.

                        If lEPICABE := .T.
                           nLin++
                           nLin++
                           nTotalLinhaPg--
                           nTotalLinhaPg--
                        Else            
                           nLin++
                           nTotalLinhaPg--
                        Endif

                        @ nLin,001 psay Replicate("-", 130)
                        nLin++
                        nTotalLinhaPg--

                        //          1         2         3         4         5         6         7         8         9       100       110       120       130     
                        // 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                        // ----------------------------------------------------------------------------------------------------------------------------------
                        // EPI               DESCRICAO DOS EPIs               NR. C.A.       DTA SEPAR.   DTA ENTREGA      QUANTIDADE   DEV   ASSINATURA
                        // ---------------------------------------------------------------------------------------------------------------------------------- 
                        // xxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   XXXXXXXXXXXX   xx/xx/xxxx   ___/___/______   9999999999   NÃO   _______________
                        // ----------------------------------------------------------------------------------------------------------------------------------

                        //          1         2         3         4         5         6         7         8         9       100       110       120       130     
                        // 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                        // ----------------------------------------------------------------------------------------------------------------------------------
                        // EPC               DESCRICAO DOS EPCs                              DTA SEPAR.   DTA ENTREGA      QUANTIDADE   DEV   ASSINATURA
                        // ---------------------------------------------------------------------------------------------------------------------------------- 
                        // XXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX/XX/XXXX   ___/___/______   9999999999   NÃO   _______________

                        If ALLTRIM(lProdutoCabeca) == "EPI"
                           @ nLin,001 PSAY lProdutoCabeca
                           @ nLin,019 PSAY "DESCRIÇÃO DOS EPIs"                    
                           @ nLin,052 PSAY "NR. C.A."    
                           @ nLin,067 PSAY "DTA SEPAR."                  
                           @ nLin,080 PSAY "DTA ENTREGA" 
                           @ nLin,097 PSAY "QUANTIDADE" 
                           @ nLin,110 PSAY "DEV"   
                           @ nLin,116 PSAY "ASSINATURA"
                        Else
                           @ nLin,001 PSAY lProdutoCabeca             
                           @ nLin,019 PSAY "DESCRIÇÃO DOS EPCs"                    
                           @ nLin,067 PSAY "DTA SEPAR."    
                           @ nLin,080 PSAY "DTA ENTREGA"  
                           @ nLin,097 PSAY "QUANTIDADE"   
                           @ nLin,110 PSAY "DEV" 
                           @ nLin,116 PSAY "ASSINATURA"
                        Endif   

                        nLin++
                        nTotalLinhaPg--

                        @ nLin,001 psay Replicate("-", 130)
                        nLin++
                        nTotalLinhaPg--

                        lCabecalhoEPI := .F.
                     Endif
    
                     // Imprime os Pordutos
                     If ALLTRIM(lProdutoCabeca) == "EPI"
                        @ nLin,001 psay Substr(TSCP2->CP_PRODUTO,01,06)
                        @ nLin,019 psay Substr(Posicione("SB1",1,xfilial("SB1") + TSCP2->CP_PRODUTO,"B1_DESC"),01,30)
                        @ nLin,052 psay TSCP2->CP_XNUMCAP
                        @ nLin,067 psay StoD(TSCP2->CP_EMISSAO)   
                        @ nLin,080 psay "___/___/______"

                        IF (TSCP2->SALDO - INT(TSCP2->SALDO)) == 0
                           @ nLin,097 psay ALLTRIM(STR(INT(TSCP2->SALDO)))
                        ELSE
                           @ nLin,097 psay ALLTRIM(STR(TSCP2->SALDO,06,02))
                        ENDIF
                        @ nLin,110 psay "NÃO"
                        @ nLin,116 psay "_______________"
                     Else
                        @ nLin,001 psay Substr(TSCP2->CP_PRODUTO,01,06)
                        @ nLin,019 psay Posicione("SB1",1,xfilial("SB1") + TSCP2->CP_PRODUTO,"B1_DESC")
                        @ nLin,068 psay StoD(TSCP2->CP_EMISSAO)   
                        @ nLin,081 psay "___/___/______"
                        
                        IF (TSCP2->SALDO - INT(TSCP2->SALDO)) == 0
                           @ nLin,098 psay ALLTRIM(STR(INT(TSCP2->SALDO)))
                        ELSE
                           @ nLin,098 psay ALLTRIM(STR(TSCP2->SALDO,06,02))
                        ENDIF        
                                        
                        @ nLin,111 psay "NÃO"
                        @ nLin,117 psay "_______________"
                     Endif                        

                     nLin++
                     nTotalLinhaPg--
                  
                  Else

                     // Imprime o Termo de responsabilidade
	 			     If !Empty(_cMatAnt)
                        nLin++
                        nTotalLinhaPg--

                        @ nLin,001 psay Replicate("-",130)

                        nLin++
                        nTotalLinhaPg--

                        @ nLin,050 psay "T E R M O   D E   R E S P O N S A B I L I D A D E"

                        nLin++
                        nTotalLinhaPg--

                        @ nLin,001 PSAY Replicate("-",130)

                        nLin++
                        nTotalLinhaPg--

					    dbSelectArea("SRA")
					    dbSetOrder(1)
					    dbSeek( xFilial("SRA") + _cMatAnt)
					    lEpi := Iif(Found(),.T.,.F. ) // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 

                        TermoComprovante(@nLin, lEpi)

                        //nLin := nLin + nTotalLinhaPg
                        nLin := nLin + 5

                        @ nLin,001 psay Replicate("-", 130)
                        nLin++; nLin++; nLin++
                        @ nLin,001 psay "Data......: _____ / _____ / __________"
                        nLin++; nLin++

//                        If ALLTRIM(lProdutoCabeca) == "EPI"
//                           @ nLin,001 psay "Assinatura: ________________________________________"
//                        Else
                           @ nLin,001 psay "Assinatura: ___________________________________   Responsável pela Entrega (Nome Legível): _______________________________________"
//                        Endif


				     Else

                        //nLin := nLin + nTotalLinhaPg
                        nLin := nLin + 5

                        @ nLin,001 psay Replicate("-", 130)
                        nLin++; nLin++; nLin++
                        @ nLin,001 psay "Data......: _____ / _____ / __________"
                        nLin++; nLin++

//                        If ALLTRIM(lProdutoCabeca) == "EPI"
//                           @ nLin,001 psay "Assinatura: ________________________________________"
//                        Else
                             @ nLin,001 psay "Assinatura: ___________________________________   Responsável pela Entrega (Nome Legível): _______________________________________"
//                        Endif
                        
                        //nLin++; nLin++
                        //@ 000,nLin psay Replicate("-", 218)
                     Endif
               
                     // Envia para a função que imprime o formulário de Devolução no verso do formulário
                     ImpTermoDevolucao()
                  
                     // Continua a impressão do próximo funcionário
                     _cMatAnt      := TSCP2->CP_SEQFUNC
                  
                     nLin          := 0
                     nPagina       := 0    
                     lPrimeiro     := .T. 
                     lCabecalhoEPI := .T.
                     nTotalLinhaPg := 50

                     // Imprime o cabeçalho do relatório
   		             Cabec("Comprovante de Entrega Nº " + Alltrim(TSCP2->CP_SCOM),Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			

                     // Imprime o complemnto do cabeçalho do relatório
                     CabecalhoComprovante()
                  
                     Loop
                                   
                  Endif
               
               Else
               
                  // Imprime o Termo de responsabilidade
	 			  If !Empty(_cMatAnt)
                     nLin++
                     nTotalLinhaPg--

                     @ nLin,001 psay Replicate("-",130)

                     nLin++
                     nTotalLinhaPg--

                     @ nLin,050 psay "T E R M O   D E   R E S P O N S A B I L I D A D E"

                     nLin++
                     nTotalLinhaPg--

                     @ nLin,001 PSAY Replicate("-",130)

                     nLin++
                     nTotalLinhaPg--

					 dbSelectArea("SRA")
					 dbSetOrder(1)
					 dbSeek( xFilial("SRA") + _cMatAnt)
 				     lEpi := Iif(Found(),.T.,.F. ) // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 

                     TermoComprovante(@nLin, lEpi)

                     //nLin := nLin + nTotalLinhaPg
                     nLin := nLin + 5

                     @ nLin,001 psay Replicate("-", 130)
                     nLin++; nLin++; nLin++
                     @ nLin,001 psay "Data......: _____ / _____ / __________"
                     nLin++; nLin++

//                     If ALLTRIM(lProdutoCabeca) == "EPI"
//                        @ nLin,001 psay "Assinatura: ___________________________________"
//                     Else
//                     Endif
                     
           	      Else

                     //nLin := nLin + nTotalLinhaPg
                     nLin := nLin + 5

                     @ nLin,001 psay Replicate("-", 130)
                     nLin++; nLin++; nLin++
                     @ nLin,001 psay "Data......: _____ / _____ / __________"
                     nLin++; nLin++

//                     If ALLTRIM(lProdutoCabeca) == "EPI"
//                        @ nLin,001 psay "Assinatura: ___________________________________"
//                     Else  
                          @ nLin,001 psay "Assinatura: ___________________________________   Responsável pela Entrega (Nome Legível): _______________________________________"
//                     Endif
                     
                     //nLin++; nLin++
                     //@ 000,nLin psay Replicate("-", 218)
                  Endif

                  // Envia para a função que imprime o formulário de Devolução no verso do formulário
                  ImpTermoDevolucao()

                  _Unidade := TSCP2->CP_XUNID
                  
                  nLin          := 0
                  nPagina       := 0    
                  lPrimeiro     := .T. 
                  lCabecalhoEPI := .T.
                  nTotalLinhaPg := 50

                  // Imprime o cabeçalho do relatório
                  Cabec("Comprovante de Entrega Nº " + Alltrim(TSCP2->CP_SCOM),Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			

                  // Imprime o cabeçalho do COmprovante de Entrega de EPI
                  CabecalhoComprovante()

                  Loop
                  
               Endif   
                  
               
               TSCP2->( DbSkip() )
               
            Enddo      

            // Imprime os dados para último funcionário
  		    If !Empty(_cMatAnt)

               nLin++
               nTotalLinhaPg--

               @ nLin,001 psay Replicate("-",130)

               nLin++
               nTotalLinhaPg--

               @ nLin,050 psay "T E R M O   D E   R E S P O N S A B I L I D A D E"

               nLin++
               nTotalLinhaPg--

               @ nLin,001 PSAY Replicate("-",130)

               nLin++
               nTotalLinhaPg--

			   dbSelectArea("SRA")
			   dbSetOrder(1)
			   dbSeek( xFilial("SRA") + _cMatAnt)
		  	   lEpi := Iif(Found(),.T.,.F. ) // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 

               // Imprime o termo de compromisso
               TermoComprovante(@nLin, lEpi)

               nLin := nLin + 5
 
               @ nLin,001 psay Replicate("-", 130)
               nLin++; nLin++; nLin++
               @ nLin,001 psay "DATA.......: ______/_______/___________"
               nLin++; nLin++

//               If ALLTRIM(lProdutoCabeca) == "EPI"
//                  @ nLin,001 psay "Assinatura: ___________________________________"
//               Else
                  @ nLin,001 psay "Assinatura: ___________________________________   Responsável pela Entrega (Nome Legível): _______________________________________"
//               Endif
               
               // Envia para a função que imprime o formulário de Devolução no verso do formulário
               ImpTermoDevolucao()
 
            Else
            
               nLin := nLin + 5

               @ nLin,001 psay Replicate("-", 130)
               nLin++; nLin++; nLin++
               @ nLin,001 psay "DATA.......: ______/_______/___________"
               nLin++; nLin++

//               If ALLTRIM(lProdutoCabeca) == "EPI"
//                  @ nLin,001 psay "Assinatura: ___________________________________"
//               Else
                  @ nLin,001 psay "Assinatura: ___________________________________   Responsável pela Entrega (Nome Legível): _______________________________________"
//               Endif
               
               // Envia para a função que imprime o formulário de Devolução no verso do formulário
               ImpTermoDevolucao()
            
            Endif

			TSCP2->(dbCloseArea())
		
        // Este é o relatório antigo, substituído pelo de cima
	ElseIf nOpc = 250  // escolhido Menu de Comprovante de Entrega 
			

            // Abre janela para solicitar o nº do controle a ser impresso/reimpresso
            If kChamada == 0
               DEFINE MSDIALOG oDlgControle TITLE "Reimpressão Comprovantes de Entrega" FROM C(178),C(181) TO C(271),C(485) PIXEL

               @ C(005),C(005) Say "Informe o nº do Processo a ser impresso" Size C(092),C(008) COLOR CLR_BLACK PIXEL OF oDlgControle
            
               @ C(020),C(005) GET oMemo1 Var cMemo1 MEMO Size C(142),C(001) PIXEL OF oDlgControle

               @ C(004),C(100) MsGet oGet1 Var cControle Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgControle
            
               @ C(025),C(038) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlgControle ACTION( cQuefazer := 1, oDlgControle:End() )
               @ C(025),C(077) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgControle ACTION( cQuefazer := 2, oDlgControle:End() )

               ACTIVATE MSDIALOG oDlgControle CENTERED 

               If cQuefazer == 2
                  set device to screen
  			      dbCommitAll()
			      SET PRINTER TO
    		      MS_FLUSH()	 	
                  Return(.T.)
               Endif
               
               If Empty(Alltrim(cControle))
                  set device to screen
  			      dbCommitAll()
			      SET PRINTER TO
    		      MS_FLUSH()	 	
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nº do Controle a ser impresso não informado.")
                  Return(.T.)
               Endif

            Else
            
               cControle := kProcesso
               
            Endif

			nLin:= 81
			
			_cQuery2 := ""
			_cQuery2 := "SELECT SCP.CP_SEQFUNC ,"                              + chr(13)
			_cQuery2 += "        SCP.CP_NUM    ,"                              + chr(13)
			_cQuery2 += "        SCP.CP_ITEM   ,"                              + chr(13)
			_cQuery2 += "        SCP.CP_PRODUTO,"                              + chr(13)
			_cQuery2 += "        SCP.CP_UM     ,"                              + chr(13)
			_cQuery2 += "        SCP.CP_EMISSAO,"                              + chr(13)
			_cQuery2 += "        SCP.CP_DATPRF ,"                              + chr(13) 
            _cQuery2 += "        SCP.CP_XUNID  ,"                              + chr(13)
			_cQuery2 += "       (SELECT X5_DESCRI "                            + chr(13)
			_cQuery2 += "          FROM " + RetsqlName("SX5")                  + chr(13)
			_cQuery2 += "         WHERE X5_TABELA = 'ZD'"                      + chr(13)
			_cQuery2 += "           AND X5_CHAVE  = SCP.CP_XUNID"              + chr(13)
			_cQuery2 += "           AND D_E_L_E_T_ = '') AS NOME_UNIDADE,"     + chr(13)
			_cQuery2 += "        SCP.CP_QUANT - SCP.CP_QUJE AS SALDO "         + chr(13)
			_cQuery2 += "  FROM " + RetSqlName("SCP") + " SCP "                + chr(13)
			_cQuery2 += " WHERE SCP.D_E_L_E_T_ = '' "                          + chr(13)
			_cQuery2 += "   AND SCP.CP_XROT    = 'XMATA105' "                  + chr(13)
			_cQuery2 += "   AND SCP.CP_FILIAL  = '" + xFilial("SCP") + "'"     + chr(13)
		  //_cQuery2 += "   AND SCP.CP_PREREQU = '' "                          + chr(13)
			_cQuery2 += "   AND SCP.CP_STATSA <> 'B' "                         + chr(13)
			_cQuery2 += "   AND SCP.CP_STATSA <> 'R' "                         + chr(13)
			_cQuery2 += "   AND SCP.CP_QUANT   > SCP.CP_QUJE "                 + chr(13)
			_cQuery2 += "   AND SCP.CP_NCON    = '" + Alltrim(cControle) + "'" + chr(13) 
			_cQuery2 += "  ORDER BY SCP.CP_XUNID, SCP.CP_SEQFUNC,SCP.CP_PRODUTO "            + chr(13)
				
	  	  //_cQuery2 += "   AND SCP.CP_EMISSAO BETWEEN '" + DtoS(dDtEmDe) + "' AND '" + DtoS(dDtEmAte) + "'" + chr(13)

			_cQuery2 := ChangeQuery( _cQuery2 )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery2 ), "TSCP2", .F., .T. )


/*
			nLin:= 81
			
			_cQuery2 := " SELECT SCP.CP_SEQFUNC , SCP.CP_NUM, "
			_cQuery2 += " SCP.CP_ITEM, SCP.CP_PRODUTO,SCP.CP_UM , "
			_cQuery2 += " SCP.CP_EMISSAO,SCP.CP_DATPRF , SCP.CP_QUANT - SCP.CP_QUJE AS SALDO " + chr(13)
			_cQuery2 += " FROM " + RetSqlName("SCP") + " SCP " + chr(13)
			_cQuery2 += " WHERE SCP.D_E_L_E_T_ = '' "
			_cQuery2 += " AND SCP.CP_XROT = 'XMATA105' "
			_cQuery2 += " AND SCP.CP_FILIAL = '" + xFilial("SCP") + "'"
			_cQuery2 += " AND SCP.CP_PREREQU = '' "
			_cQuery2 += " AND SCP.CP_STATSA <> 'B' "
			_cQuery2 += " AND SCP.CP_STATSA <> 'R' "
			_cQuery2 += " AND SCP.CP_QUANT > SCP.CP_QUJE " + chr(13)
			_cQuery2 += " AND SCP.CP_EMISSAO BETWEEN '" + DtoS(dDtEmDe) + "' AND '" + DtoS(dDtEmAte) + "'" + chr(13)
			_cQuery2 += " ORDER BY SCP.CP_SEQFUNC,SCP.CP_PRODUTO "
				
			_cQuery2 := ChangeQuery( _cQuery2 )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery2 ), "TSCP2", .F., .T. )
*/		
			dbGoTop()
			Count To nRegs2
			SetRegua( nRegs2 )
			dbGoTop()
		
			If (!TSCP2->( Eof() ))
				_cMatAnt := TSCP2->CP_SEQFUNC
			EndIf
		
			Cabec1      := ""//"MATR./EQUIPE  NOME                         PRODUTO      DESCRIÇÃO                   U.M.  QTD.         N. S.A.  ITEM  EMISSÃO "
			//              12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
			//                       1         2         3         4         5         6         7         8         9        10        11        12        13        14   
			
			While !TSCP2->( Eof() )
		
				If (_lPMat == .T. .or. _cMatAnt <> TSCP2->CP_SEQFUNC  ) //primeiro
					If (_lPMat == .F.)
						If !Empty(_cMatAnt)
							dbSelectArea("SRA")
							dbSetOrder(1)
							dbSeek( xFilial("SRA") + TSCP2->CP_SEQFUNC)
							lEpi := Iif(Found(),.T.,.F. ) // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 
							Termo(@nLin, lEpi )
						EndIf
					Else
						//@75,082 PSAY "------------------------------------------"
						//@76,082 PSAY Left(Posicione("SRA",1,xfilial("SRA") + _cMatAnt,"RA_NOME"),35)
						//@77,082 PSAY "Entrega(s) equipamento(s): "  + " _____/_____/________"  //+ DtoC(dDataBase)
						@68, 00 PSAY "|"+Replic("-", 130)+"|"
						@69, 00 PSAY "|"+Replic(" ", 130)+"|"
						@70, 00 PSAY PADR("|     Data: ____/____/____", 131)+"|"
						@71, 00 PSAY "|"+Replic(" ", 130)+"|"
						@72, 00 PSAY PADR("|     Assinatura: __________________________"+SPACE(40)+"RespEmpr: __________________________", 131)+"|"
						@73, 00 PSAY "|"+Replic(" ", 130)+"|"
						@74, 00 PSAY "|"+Replic("-", 130)+"|"
					EndIf 
					
					_lPMat := .F.
					nLin++
					Cabec("Rel. Sol. Armazem - EPI/EPC: Documento entrega de equipamentos",Cabec1,Cabec2,NomeProg,Tamanho,nTipo, , ,cLogo)			
					nLin	:= 1
					
					@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
					nLin++
					@nLin, 00 PSAY PADR("|Empresa...: "+PADR(SM0->M0_NOMECOM, 30)+SPACE(40)+"CGC..:"+PADR(SM0->M0_CGC, 14)+SPACE(7), 131)+"|"
					nLin++
					@nLin, 00 PSAY PADR("|Filial....: "+SM0->M0_CODFIL+" - "+SM0->M0_NOME, 131)+"|"
					nLin++
					@nLin, 00 PSAY PADR("|Endereco..: "+PADR(SM0->M0_ENDCOB, 30)+SPACE(40)+"Cidade:"+SM0->M0_CIDCOB+" - "+SM0->M0_ESTCOB, 131)+"|"
					nLin++
					@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
					nLin++
					
					nAuxLin := nLin
					nLin := 1
					
				EndIf
				
				If nLin > 67 // Salto de Pagina. Neste caso o formulario tem 68 linhas...
					nLin++
					Cabec("Rel. Sol. Armazem - EPI/EPC: Documento entrega de equipamentos",Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			
					nLin := nAuxLin
				Endif  
		
				@nLin,01  PSAY TSCP2->CP_SEQFUNC
				@nLin,12  PSAY Left(Posicione("AA1",1,xfilial("AA1") + TSCP2->CP_SEQFUNC,"AA1_NOMTEC"),25)
				@nLin,42  PSAY TSCP2->CP_PRODUTO
				@nLin,55  PSAY Left(Posicione("SB1",1,xfilial("SB1") + TSCP2->CP_PRODUTO,"B1_DESC"),25)
				@nLin,83  PSAY TSCP2->CP_UM 
				@nLin,88  PSAY Transform(TSCP2->SALDO,PesqPict("SCP","CP_QUANT",8)) 
				@nLin,102 PSAY TSCP2->CP_NUM 
				@nLin,111 PSAY TSCP2->CP_ITEM 
				@nLin,117 PSAY StoD(TSCP2->CP_EMISSAO) 
		
				_cMatAnt := TSCP2->CP_SEQFUNC
				nLin++
				IncRegua()
		
				TSCP2->( dbSkip() )
		
			EndDo
			
			If (_lPMat == .F.)
			
				If !Empty(_cMatAnt)
					dbSelectArea("SRA")
					dbSetOrder(1)
					dbSeek( xFilial("SRA") + TSCP2->CP_SEQFUNC)
					lEpi := Iif(Found(),.T.,.F. ) // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 
				
					Termo(@nLin, lEpi )
				EndIf
				
			EndIf
					
			TSCP2->(dbCloseArea())


		ElseIf nOpc = 3 // Escolhido menu de Relatório de Separação por Unidade
		 
			Cabec1 := " Nr.S.A.  Equipe/Func   Produto      Descricao                        Qtd      Unidade    DT Emissao     Solicitante     Obs"
	
			_cQuery := " SELECT SCP.CP_PRODUTO,"
			_cQuery += "        SCP.CP_SEQFUNC,"
			_cQuery += "        SCP.CP_NUM    ,"
			_cQuery += "        SCP.CP_DESCRI ,"
			_cQuery += " ISNULL(SUM(SCP.CP_QUANT),0) - ISNULL(SUM(SCP.CP_QUJE),0) AS SALDO, SCP.CP_XUNID, "
			_cQuery += "        SCP.CP_EMISSAO,"
			_cQuery += "        SCP.CP_OBS    ,"
			_cQuery += "        SCP.CP_SOLICIT " 
			_cQuery += "   FROM " + RetSqlName("SCP") + " SCP " 
			_cQuery += "  WHERE SCP.D_E_L_E_T_ = '' "
			_cQuery += "    AND SCP.CP_XROT    = 'XMATA105' "
			_cQuery += "    AND SCP.CP_FILIAL  = '" + xFilial("SCP") + "'"
			_cQuery += "    AND SCP.CP_PREREQU = '' "
			_cQuery += "    AND SCP.CP_STATSA <> 'B' "
			_cQuery += "    AND SCP.CP_STATSA <> 'R' "
			_cQuery += "    AND SCP.CP_QUANT   > SCP.CP_QUJE " 
			_cQuery += "    AND SCP.CP_XUNID IN (" + _cUnid + ")"
			_cQuery += "    AND SCP.CP_EMISSAO BETWEEN '" + DtoS(dDtEmDe) + "' AND '" + DtoS(dDtEmAte) + "'" + chr(13)
			_cQuery += " GROUP BY SCP.CP_XUNID,SCP.CP_SEQFUNC,SCP.CP_PRODUTO, SCP.CP_NUM,"
			_cQuery += "          SCP.CP_DESCRI, SCP.CP_EMISSAO, SCP.CP_OBS, SCP.CP_SOLICIT "   
            _cQuery += " ORDER BY SCP.CP_DESCRI"
			
			_cQuery := ChangeQuery( _cQuery )	
			dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery ), "TSCP", .F., .T. )
			
			dbGoTop()
			Count To nRegs
			SetRegua( nRegs )
			dbGoTop()
			
			While !TSCP->( Eof() ) 
			
				If nLin > 80 // Salto de Pagina. Neste caso o formulario tem 68 linhas...
					nLin++
					Cabec("Rel. Sol. Armazem - Relatório de Separação por Unidade",Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			
					nLin := 8
				Endif   
			
				@ nLin,01  PSAY Alltrim(TSCP->CP_NUM)		                        // Nr.S.A.
				
				If Empty(Alltrim(TSCP->CP_SEQFUNC))
				   @ nLin,11 PSAY Space(06)
				Else   
   				   @ nLin,11  PSAY Alltrim(TSCP->CP_SEQFUNC)	                        // Equipe/Func      
				Endif
				
				@ nLin,25  PSAY Alltrim(TSCP->CP_PRODUTO)	                        // Produto
				@ nLin,38  PSAY Alltrim(TSCP->CP_DESCRI)		                    // Descricao
				@ nLin,69  PSAY Transform(TSCP->SALDO,PesqPict("SCP","CP_QUANT",8)) // Qtd		
				@ nLin,80  PSAY Alltrim(TSCP->CP_XUNID)		                        // Unidade
				@ nLin,92  PSAY DtoC(StoD(TSCP->CP_EMISSAO))	                    // DT Emissao
				@ nLin,105 PSAY Alltrim(TSCP->CP_SOLICIT)	                        // Obs
				@ nLin,122 PSAY Alltrim(TSCP->CP_OBS)		                        // Solicitante
				
				nLin++
				IncRegua()
				
				TSCP->( dbSkip() )
		
			EndDo
		
			TSCP->(dbCloseArea())
			
		EndIf
		
		SET DEVICE TO SCREEN
	
		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif
	
		MS_FLUSH()	 	
	Else
		MsgInfo("Selecione uma unidade.")
	EndIf
			
	pergunte("MTA105",.F.)

Return()

/*/{Protheus.doc} VALIDPERG
Imprime o Termo de Devolução no verso do Comprovante de Entrega de Mercadorias
@author Harald Hans Löschenkohl
@since 24/07/2019
@version 1.0
@type function
/*/
Static Function ImpTermoDevolucao()

   Local nLin          := 0

   @ nLin, 001 PSAY "+---------------------------------------------------------------------------------------------------------------------------------+"
   nLin++
   @ nLin, 001 PSAY "|                                                     DOCUMENTO DE DEVOLUÇÃO INTERNA                                              |"
   nLin++
   @ nLin, 001 PSAY "+---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "| Dados do Colaborador                                                                                                            |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome do Colaborador: __________________________________ Matrícula: ____________ Assinatura do Colaborador: ____________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome do Colaborador: __________________________________ Matrícula: ____________ Assinatura do Colaborador: ____________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome do Colaborador: __________________________________ Matrícula: ____________ Assinatura do Colaborador: ____________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome do Colaborador: __________________________________ Matrícula: ____________ Assinatura do Colaborador: ____________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome do Colaborador: __________________________________ Matrícula: ____________ Assinatura do Colaborador: ____________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome do Colaborador: __________________________________ Matrícula: ____________ Assinatura do Colaborador: ____________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Declaro(amos)  que  estou(amos)  ciente que Equipamentos e/ou Ferramentas cuja derabilidade não atenda o prazo mínimo  de  vida |"
   nLin++
   @ nLin, 001 PSAY "| útil, seja por perda, dano ou mau uso, terão o valor correspondente descontados em folha de pagamento de salários.              |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "| Dados Unidade                                                                                                                   |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome de quem (recolheu/entregou) na unidade: ____________________________________________________________ Matrícula: __________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Assinatira: ___________________________________________________________  Data de Recebimento na unidade: _____/ _____ / _______ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "| Dados Almoxarifado                                                                                                              |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Nome de quem (recolheu/entregou) no Almoxarifado: _______________________________________________________ Matrícula: __________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Assinatira: ___________________________________________________________  Data de Recebimento na unidade: _____/ _____ / _______ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |                        SITUAÇÃO                      |"
   nLin++
   @ nLin, 001 PSAY "|  CÓDIGO   |     DESCRIÇÃO DOS PRODUTOS/FERRAMENTAS       |     QUANT.    |------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  Subst    | Fornec. |  Perda   |  Venc.   |  Demis.  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|-----------|----------------------------------------------|---------------|-----------|---------|----------|----------|----------|"
   nLin++
   @ nLin, 001 PSAY "|           |                                              |               |  (    )   |  (    ) |  (    )  |  (    )  |  (    )  |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "| Observações                                                                                                                     |"
   nLin++
   @ nLin, 001 PSAY "|---------------------------------------------------------------------------------------------------------------------------------|"
   nLin++
   @ nLin, 001 PSAY "| _______________________________________________________________________________________________________________________________ |"
   nLin++
   @ nLin, 001 PSAY "| _______________________________________________________________________________________________________________________________ |"
   nLin++
   @ nLin, 001 PSAY "| _______________________________________________________________________________________________________________________________ |"
   nLin++
   @ nLin, 001 PSAY "+---------------------------------------------------------------------------------------------------------------------------------+"
   nLin++
   @ nLin, 001 PSAY "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - D E S T A C A R - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
   nLin++
   @ nLin, 001 PSAY "+---------------------------------------------------------------------------------------------------------------------------------+"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Recebemos de _____________________________________________________ matrícula _____________, os materiais usuados registrados no |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| documento de Devolução interna número ___________________________.                                                              |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Quant. itens usados recebidos do colaborador: _____________________ Quant. itens novos entregues pela Empresa: ________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "| Data: ____ / ____ / __________                             Nome do Almoxarife: ________________________________________________ |"
   nLin++
   @ nLin, 001 PSAY "|                                                                                                                                 |"
   nLin++
   @ nLin, 001 PSAY "+---------------------------------------------------------------------------------------------------------------------------------+"
   nLin++

Return(.T.)

/*/{Protheus.doc} VALIDPERG
Cria perguntas SX1 para a rotina RPICKSCP
@author Celso Rene
@since 29/01/2019
@version 1.0
@type function
/*/
Static Function VALIDPERG()

	cAlias := Alias()

	aRegs  :={}

	DbSelectArea(cAlias)

Return()

/*/{Protheus.doc} Termo
Busca e imprime os termos de aceitação dos equipamentos (funções copiadas do prw FB602MDT)
@author Gregory
@since 29/01/2019
@version 1.0
@type function
/*/
Static Function Termo(nLin, lEpi)

   Local cTermo := fBuscaCpo("TMZ", 1, xFilial("TMZ")+Iif(lEpi,"000001","000002"), "TMZ_DESCRI")
   Local aTermo := _MSG(cTermo, 130)
   Local nX     := 0

   @ nLin, 00 PSAY "|"+Replic("-", 130)+"|"
   nLin++
   @ nLin, 00 PSAY PADR("|"+SPACE(52)+"TERMO DE RESPONSABILIDADE", 131)+"|"
   nLin++

   For nX:= 1 To Len(aTermo)

       If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		  Cabec("","","","","M",18)
		  nLin := 6
	   Endif

       @ nLin, 00 PSAY PADR("|"+aTermo[nX], 131)+"|"
	   nLin++
   Next nX
	
   @nLin, 00 PSAY "|"+Replic("-", 130)+"|"
   nLin++
   
   @nLin, 00 PSAY "|"+Replic(" ", 130)+"|"
   nLin++
   @nLin, 00 PSAY PADR("|     Data: ____/____/____", 131)+"|"
   nLin++
   @nLin, 00 PSAY "|"+Replic(" ", 130)+"|"
   nLin++
   @nLin, 00 PSAY PADR("|     Assinatura: __________________________"+SPACE(40)+"RespEmpr: __________________________", 131)+"|"
   nLin++
   @nLin, 00 PSAY "|"+Replic(" ", 130)+"|"
   nLin++
   @nLin, 00 PSAY "|"+Replic("-", 130)+"|"
Return

/*/{Protheus.doc} TermComprovante
Busca e imprime os termos de aceitação dos equipamentos (funções copiadas do prw FB602MDT)
@author Gregory
@since 29/01/2019
@version 1.0
@type function
/*/
Static Function TermoComprovante(nLin, lEpi)

   Local cTermo := fBuscaCpo("TMZ", 1, xFilial("TMZ")+Iif(lEpi,"000001","000002"), "TMZ_DESCRI")
// Local aTermo := _MSG(cTermo, 218)
   Local aTermo := _MSG(cTermo, 130)

   Local nX     := 0

   For nX:= 1 To Len(aTermo)

       If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		  nLin := 0
          
          // Imprime o cabeçalho do relatório
  	      Cabec("Comprovante de Entrega",Cabec1,Cabec2,nomeprog,Tamanho,nTipo, , ,cLogo)			
		  
          CabecalhoComprovante()		  
	   Endif

//     @ nLin, 000 PSAY PADR(aTermo[nX], 218)
       @ nLin, 001 PSAY PADR(aTermo[nX], 130)

	   nLin++

   Next nX
	
   @ nLin,001 psay Replicate("-", 130)
   
//   nLin := nLin + nTotalLinhaPg   
   
//   nLin := nLin + 5   

//   @ nLin,001 psay "Data......: _____ / _____ / __________"

//   nLin++; nLin++

//   @ nlin,001 psay "Assinatura: ________________________________________   Responsável pela Entrega (Nome Legível): ____________________________________________"

//   nLin++; nLin++

//   @ 000,nLin psay Replicate("-", 218)

Return

Static Function _MSG(_cObs, _nTam)
	Local _aMsg := {}
	Local _i    := 0

	_cObs := StrTran(_cObs, " ", ";")
	Do While At(";;", _cObs) != 0
		_cObs := StrTran(_cObs, ";;", ";")
	EndDo

	_aObs := {}
	Do While Len(_cObs) > 0
		If At(";", _cObs) != 0
			AADD(_aObs, SubStr(_cObs, 1, At(";", _cObs) -1))
			_cObs := Stuff(_cObs, 1, At(";", _cObs), "")
		Else
			AADD(_aObs, AllTrim(_cObs))
			_cObs := ""
		EndIf
	EndDo

	_cObs := ""
	For _i := 1 To Len(_aObs)
		if Len(_cObs + cValToChar(_aObs[_i])) > _nTam
			AADD(_aMsg, Padr(_cObs,_nTam))
			_cObs := _aObs[_i] + " "
		Else
			_cObs := _cObs + _aObs[_i] + " "
		EndIf
	Next _i

	If AllTrim(_cObs) != ""
		AADD(_aMsg, Padr(_cObs,_nTam))
	EndIf

Return _aMsg
	
// Função que imprime o cabeçalho do Comprovante de Entrega de EPIs
Static Function CabecalhoComprovante()

   nLin := 06
   nPagina++

//   @ nLin,001 psay "SIGA"
//   @ nLin,058 psay "COMPROVANTE DE ENTREGA DE EPI"
//   @ nLin,120 PSAY Dtoc(Date()) + " - " + TIME()
//   nLin++
//   @ nLin,001 psay "RPICKSCP.PRW"   
//   @ nLin,058 psay Alltrim(TSCP2->CP_XUNID) + " - " + Alltrim(TSCP2->NOME_UNIDADE)
//   @ nLin,120 psay "PÁGINA:         " + Strzero(nPagina,5)
//   nLin++
//   @ nLin,001 psay Replicate("-",140)                                           
//
//   nLin++; nLin++
//   @ nLin,001 psay "EMPRESA.........: " + Alltrim(SM0->M0_NOMECOM)
//   @ nLin,112 psay "CNPJ....: "         + Substr(SM0->M0_CGC,01,02) + "." + ;
//                                          Substr(SM0->M0_CGC,03,03) + "." + ;
//                                          Substr(SM0->M0_CGC,06,03) + "/" + ;
//                                          Substr(SM0->M0_CGC,09,04) + "-" + ;
//                                          Substr(SM0->M0_CGC,13,02)
//   nLin++
//   @ nLin,001 psay "ENDEREÇO........: " + Alltrim(SM0->M0_ENDENT)
//   @ nLin,112 psay "CIDADE..: "         + Alltrim(SM0->M0_CIDENT) + "/" + Alltrim(SM0->M0_ESTENT)
//   nLin++; nLin++
//   @ nLin,000 psay Replicate("-",140)
//   nLin++; nLin++
                                    
   @ nLin,001 psay "NÚMERO PROCESSO.: " + TSCP2->CP_NCON
   nLin := nLin + 1
   @ nLin,001 psay "NÚMERO DA SA....: " + TSCP2->CP_NUM
   nLin := nLin + 2
   @ nLin,001 psay Replicate("-",130)
   nLin := nLin + 2

   @ nLin,001 psay "EMPRESA.........: " + Alltrim(SM0->M0_NOMECOM)
   @ nLin,100 psay "CNPJ....: "         + Substr(SM0->M0_CGC,01,02) + "." + ;
                                         Substr(SM0->M0_CGC,03,03) + "." + ;
                                         Substr(SM0->M0_CGC,06,03) + "/" + ;
                                         Substr(SM0->M0_CGC,09,04) + "-" + ;
                                         Substr(SM0->M0_CGC,13,02)
         
   nLin := nLin + 1
   
   @ nLin,001 psay "ENDEREÇO........: " + Alltrim(SM0->M0_ENDENT)
   @ nLin,100 psay "CIDADE..: "         + Alltrim(SM0->M0_CIDENT) + "/" + Alltrim(SM0->M0_ESTENT)
     
   nLin := nLin + 2

   @ nLin,001 psay Replicate("-",130)

   nLin := nLin + 2

Return(.T.)


/*
         1         2         3         4         5         6         7         8         9       100       110       120       130       140
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
SIGA                                                     COMPROVANTE DE ENTREGA DE EPI                                 24/07/2019 - 13:54:53
RPICKSCP.PRW                                                                                                           PAGINA:         00001
-------------------------------------------------------------------------------------------------------------------------------------------- 

EMPRESA.........: SIRTEC SISTEMAS ELETRICOS LTDA.                                                              CNPJ....: 94.479.532/00001-05
ENDEREÇO........: MARTINHO LUTERO, 1344                                                                        CIDADE..: SÃO BORJA/RS

--------------------------------------------------------------------------------------------------------------------------------------------

FUNCIONÁRIO.....: MAICON FLORES VALAU                                                                          RG......: 9101621895
CENTRO DE CUSTO.: A0102020101020201 - URU LINHA MORTA P/ TAREFA               
FUNÇÃO..........: 000003 - ELETRECISTA RD 3 
NASCIMENTO......: 09/06/1988                                                                                   ADMISSÃO: 16/05/2011

         1         2         3         4         5         6         7         8         9       100       110       120       130       140
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
--------------------------------------------------------------------------------------------------------------------------------------------
IT PRODUTO    DESCRIÇÃO DOS PRODUTOS                                       UND QUANTIDADE Nr C.A. EMISSÃO    ASSINATURA
--------------------------------------------------------------------------------------------------------------------------------------------
06 000003     ALICATE. BOMMA DAGUA 12"-1KV                                 PC           2 099198  21/05/2019 _______________________________
06 000003     ALICATE. BOMMA DAGUA 12"-1KV                                 PC           2 099198  21/05/2019 _______________________________
--------------------------------------------------------------------------------------------------------------------------------------------
                                                  T E R M O  D E  R E S P O N S A B I L I D A D E
--------------------------------------------------------------------------------------------------------------------------------------------
Declaro para os devidos fins de acordo com a NR-1 item 1.8 alinea "b", subitem 1.8.1, e  NR-6  da  portaria  3.214/78, do MTE, que recebi os 
equipamentos de proteção individual - EPI's e as ferramentas discriminadas acima, sendo orientado para o uso correto dos mesmos  e  a impor-
tância destes equipamentos para a minha saúde e integridade física no desenvolver de minhas atividades laborais,estando ciente quanto ao seu
uso adequado, guardar e conservação, e que o uso incorreto, ou recusa em usá-los,constitue em ato faltoso conforme as normas e procedimentos
de segurança. Comprometo-me que quando vir a me desligr da Empresa devolver todos os equipamentos relacionados acima.Recebi orientação sobre
os riscos ambientais aos quais estarei exposto, bem como os metodos de neutralização, adotados pela Empresa - EPI's e EPC's.
--------------------------------------------------------------------------------------------------------------------------------------------


Data......: _____ / _____ / __________


Assinatura: ________________________________________   Responsável pela Entrega (Nome Legível): ____________________________________________
*/


/*
@ 01, 00 PSAY "         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150         160       170       180       190       200       210        " 
@ 02, 00 PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901232345678901234567890123456789012345678901234567890123456789012345678"
@ 03, 00 PSAY "SIGA-RPICKSCP.PRW                                                                             COMPROVANTE DE ENTREGA DE EPI                                                                            XX/XX/XXXX - XX:XX:XX"
@ 04, 00 PSAY "EMPRESA: SIRTEC FILIAL: SIRTEC                                                                                                                                                                         PÁGINA:         XXXXX"
@ 05, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

@ 07, 00 PSAY "EMPRESA.: SIRTEC SISTEMAS ELETRICOS LTDA                                                                                                            CNPJ..: XX.XXX.XXX/XXXX-XX"
@ 08, 00 PSAY "ENDEREÇO: NOME DA RUA COM O NUMERO DO ENDEREÇO                                                                                                      CIDADE: SÃO BORJA                                  ESTADO.: RS" 

@ 10, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

@ 12, 00 PSAY "FUNCIONÁRIO.....: NOME DO FUNCIONÁRIO A SER IMPRESSO                                                                                                RG.........: 1021449796"
@ 13, 00 PSAY "CENTRO DE CUSTO.: NOME DO CENTRO DE CUSTO A SER IMPRESSO"
@ 14, 00 PSAY "FUNÇÃO..........: NOME DA FUNÇÃO DO FUNCIONÁRIO"
@ 15, 00 PSAY "NASCIMENTO......: XX/XX/XXXX                                                                                                                        ADMISSÃO...: XX/XX/XXXX                            IDADE..: 56 ANOS"  

@ 17, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
@ 18, 00 PSAY "ITEM     CÓDIGO DOS PRODUTOS               DESCRIÇÃO DOS PRODUTOS                                           UND       QUANTIDADE     NR. DA C.A.    DTA EMISSÃO               
@ 19, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
@ XX, XX PSAY "         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200       210        
@ XX, XX PSAY "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
@ 21, 00 PSAY "XXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXX     XXXXXXXXXXXX     XXXXXXXXXX     XX/XX/XXXX     Assnatura: ______________________________________________"
@ 22, 00 PSAY "XXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXX     XXXXXXXXXXXX     XXXXXXXXXX     XX/XX/XXXX     Assnatura: ______________________________________________"
@ 23, 00 PSAY "XXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXX     XXXXXXXXXXXX     XXXXXXXXXX     XX/XX/XXXX     Assnatura: ______________________________________________"
@ 24, 00 PSAY "XXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXX     XXXXXXXXXXXX     XXXXXXXXXX     XX/XX/XXXX     Assnatura: ______________________________________________"
@ 25, 00 PSAY "XXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXX     XXXXXXXXXXXX     XXXXXXXXXX     XX/XX/XXXX     Assnatura: ______________________________________________"
@ 26, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
@ 27, 00 PSAY "                                                                                       T E R M O   D E   R E S P O N S A B I L I D A D E"
@ 28, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
@ 29, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 30, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 31, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 32, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 33, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 34, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 35, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 36, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 37, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 38, 00 PSAY "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
@ 39, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

@ 41, 00 PSAY "DATA.......: ______/_______/___________"

@ 43, 00 PSAY "Assinatura: ________________________________________________                                                                       Responsável pela Entrega (Nome Legível): ________________________________________________"

@ 45, 00 PSAY "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
*/	