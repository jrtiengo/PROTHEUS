#include 'protheus.ch'
#Include "Tbiconn.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} xMDTA630
//Rotina de EPI x Funcionario
@author Celso Rene
@since 01/02/2019
@version 1.0
@type function
/*/
User Function xMDTA630()

	cmodulo := "MDT"
	modulo	:= 35
	nmodulo	:= 35

//EPI x Funcionario
	MDTA630()


	cmodulo := "EST"
	modulo	:= 4
	nmodulo	:= 4


Return()

/*/{Protheus.doc} xMDTA620
//Rotina de EPI x Fornecedor
@author Celso Rene
@since 01/02/2019
@version 1.0
@type function
/*/
User Function xMDTA620()

	cmodulo := "MDT"
	modulo	:= 35
	nmodulo	:= 35

//EPI x Fornecedor
	MDTA620()


	cmodulo := "EST"
	modulo	:= 4
	nmodulo	:= 4


Return()



/*/{Protheus.doc} xMDTA695
//EPI x Funcionario
@author Celso Rene
@since 01/02/2019
@version 1.0
@type function
/*/
User Function xMDTA695()


	cmodulo := "MDT"
	modulo	:= 35
	nmodulo	:= 35

//EPI x Fornecedor
	MDTA695()


	cmodulo := "EST"
	modulo	:= 4
	nmodulo	:= 4

Return()



/*/{Protheus.doc} CPXMAT
//Gatilho chamado na selecao da matricuka na tela de solicitacoes de S.A. 
//automatizar C.A. quando informado anteriormente em outro item.
@type function
@author Celso Rene
@since 21/03/2019
@version 1.0
/*/
User Function CPXMAT()

	Local _cRet		:= M->CP_SEQFUNC
	Local _nMat 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_SEQFUNC" })
	Local _nProd	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_PRODUTO" })
	Local _nCA		:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_XNUMCAP" })
	Local _x		:= 1
	
	//automatizando informacao C.A.
	If ( !Empty(M->CP_SEQFUNC) )
		For _x:= 1 to Len(aCols)
			If ( aCols[_x][_nProd] == aCols[n][_nProd] .and. !Empty(aCols[_x][_nMat])  )
				aCols[n][_nCA]:= aCols[_x][_nCA] 
				_x:= Len(aCols) + 1
			EndIf
		Next _x
	EndIf


Return(_cRet)

// Função que atende ao gatilho CP_SEQFUNC
// Objetivo deste gatilho é carregar o campo CP_CC com o Centro de Custo do Funcionário informado
User Function STCCCMAT()

   Local lRet     := .F.
   Local cRetorno := ""                    
   Local cMat     := GDFieldGet("CP_SEQFUNC")
   Local cMat_		:= ""
   Local aArea		:= GetArea()
// Local cMat     := M->CP_SEQFUNC
	
   // Pesquisa o Centro de Custo do Funcionário infromado
   If !Empty(cMat) 
   
		/* #30426 A rotina não trabalha apenas com funcionários. Ela também contém os EPIs. 
		Primeiro, deve-se validar se o código é de funcionário. Mauro - Solutio. 17/09/2021.
		*/

		cMat_ := Posicione("SRA",1,xFilial("SRA")+cMat,"RA_MAT")
		
		// #30426  Caso seja matrícula, procura na SRE. Mauro - Solutio. 17/09/2021.
		If cMat == cMat_

			cQuery := " SELECT RE_CCP "
			cQuery += " FROM SRE010 "
			cQuery += " WHERE RE_EMPP = '"+ cEmpAnt +"' "
			cQuery += " AND RE_FILIALP = '"+ cFilAnt +"' "
			cQuery += " AND RE_MATP = '"+ cMat +"' "
			// cQuery += " AND SUBSTRING(RE_DATA,1,6) = '"+ Substr(DTOS(da105data),1,6) +"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY RE_DATA "
			
			If Select("T_SRE") <>  0
				T_SRE->(DbCloseArea())
			EndIf

			TcQuery cQuery New Alias "T_SRE"
	
			DbSelectArea("T_SRE")

			// Alteração para considerar a data informada e os possíveis vários registros. Mauro - Solutio. 19/10/2021.
			Do While !EOF("T_SRE")
				If T_SRE->RE_DATA <= da105data
					cRetorno :=  T_SRE->RE_CCP
				EndIf
				T_SRE->(DbSkip())
			EndDo
			
			// Caso ainda esteja em branco, pega a do cadastro do funcionário. Mauro - Solutio. 19/10/2021.
			If Empty(Alltrim(cRetorno))
				cRetorno :=  Posicione("SRA",1,xFilial("SRA")+cMat,"RA_CC")
			EndIf
		
			T_SRE->(DbCloseArea())
			RestArea( aArea )
			Return(cRetorno)
			
		EndIf
		
      DbSelectArea("AA1")
	  DbSetOrder(1)
	  DbSeek(xFilial("AA1") + cMat )
	  
	  If Found() 
	  	 GDFieldPut("CP_CC", AA1->AA1_CC)
		 cRetorno := AA1->AA1_CC
	  Else
		 cRetorno := ""
		 MsgInfo("Atenção!"                                                        + Chr(13) + chr(10) + Chr(13) + Chr(10) + ;
		         "Não foi possível encontrar um Centro de Custo para este código." + chr(13) + chr(10) + chr(13) + chr(10) + ;
		         "Verifique!","Centro de Custo")
	  EndIf
   Else
      cRetorno := ""
   EndIf
	
Return(cRetorno)

// Função que atende ao gatilho CP_SEQFUNC
// Objetivo deste gatilho é carregar o nome da unidade onde o funcionário informado está lotado
User Function UNDSEQFUNC()

   Local cSql     := ""
   Local cRetorno := ""                    
   Local cMat     := GDFieldGet("CP_SEQFUNC")
   
   If !Empty(cMat) 

      If Select("T_CENTROCUSTO") > 0
         T_CENTROCUSTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT AA1.AA1_CODTEC,"
      cSql += "       AA1.AA1_CC    ,"
      cSql += "       CTT.CTT_MUNIC ,"
      cSql += "      (SELECT X5_CHAVE "
      cSql += "         FROM " + RetSqlName("SX5") 
      cSql += "        WHERE X5_TABELA = 'ZD'"
      cSql += "          AND X5_DESCRI = CTT.CTT_MUNIC"
      cSql += "          AND D_E_L_E_T_ = '') AS UNIDADE"
      cSql += "  FROM " + RetSqlName("AA1") + " AA1, "
      cSql += "       " + RetSqlName("CTT") + " CTT  "
      cSql += " WHERE AA1.AA1_CODTEC = '" + Alltrim(cMat) + "'"
      cSql += "   AND AA1.D_E_L_E_T_ = ''"
      cSql += "   AND CTT.CTT_CUSTO = AA1.AA1_CC"
      cSql += "   AND CTT.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CENTROCUSTO", .T., .T. )

      cRetorno := IIF(T_CENTROCUSTO->( EOF() ), Space(03), T_CENTROCUSTO->UNIDADE)

   Else      

      cRetorno := Space(03)
      
   Endif   

Return(cRetorno)

User Function STCCAPRD()

	Local cCARet    := ""
//	Local cProd     := GDFieldGet("CP_PRODUTO")
//	Local cProd     := SCP->CP_PRODUTO
	Local cProd     := M->CP_PRODUTO
	Local _cQuery   := ""
	Local cAliasQry	:= getNextAlias()

//    _cQuery2 := ""	
//	_cQuery2 := " SELECT TOP 1 SCP.CP_XNUMCAP"
//	_cQuery2 += "   FROM " + RetSqlName("SCP") + " SCP " + chr(13)
//	_cQuery2 += "  WHERE SCP.D_E_L_E_T_ = '' "
//	_cQuery2 += "    AND SCP.CP_FILIAL  = '" + xFilial("SCP") + "'"
//	_cQuery2 += "    AND SCP.CP_PRODUTO = '" + Alltrim(cProd) + "'"
//	_cQuery2 += " ORDER BY SCP.CP_EMISSAO DESC"
//		
//	_cQuery2 := ChangeQuery( _cQuery2 )	
//	dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery2 ), cAliasQry, .F., .T. )


   _cQuery2 := ""
   _cQuery2 := "SELECT TOP(1) TN3_NUMCAP"  
   _cQuery2 += "  FROM " + RetSqlName("TN3")
   _cQuery2 += " WHERE TN3_FILIAL  = '" + xFilial("TN3") + "'"
   _cQuery2 += "   AND TN3_CODEPI  = '" + Alltrim(cProd) + "'"
   _cQuery2 += "   AND TN3_DTVENC >= '" + Dtos(DATE())   + "'" 
   _cQuery2 += " ORDER BY TN3_DTVENC"
   
   _cQuery2 := ChangeQuery( _cQuery2 )	
   dbUseArea( .T., "TOPCONN", TcGenQry( , , _cQuery2 ), cAliasQry, .F., .T. )

   IF (cAliasQry)->(!EoF())
  	  cCARet := (cAliasQry)->TN3_NUMCAP
   EndiF
		
Return(cCARet)
