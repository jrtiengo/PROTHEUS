#include 'protheus.ch'
	
	
/*/{Protheus.doc} MTA105LIN
//Ponto de entrada: Valida os dados na linha da solicitação ao almoxarifado digitada
@author Celso Rene
@since 11/02/2019
@version 1.0
@type function
/*/
User Function MTA105LIN()
	
	Local _lRet		:= .T.
	Local _nProd	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_PRODUTO" })
  //Local _nCA		:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_XNUMCAP" })
	Local _nRot		:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_XROT"    })
	Local _nSEQFUNC	:= aScan(aHeader,{|x| Alltrim(x[2]) == "CP_SEQFUNC" })
	Local _nUnidade := aScan(aHeader,{|x| Alltrim(x[2]) == "CP_XUNID"   })
    Local _nMotivo  := aScan(aHeader,{|x| Alltrim(x[2]) == "CP_MOTI"    })

	// Guardando informacao rotina que gerou o registro
	aCols[n][_nRot] := "XMATA105"	
	
	dbSelectArea("SRA")
	dbSetOrder(1)
	dbSeek( xFilial("SRA") + aCols[n][_nSEQFUNC] )
	If (Found() .and. SRA->RA_SITFOLH <> "D") // Se o campo CP_SEQFUNC FOR UMA MATRICULA PRESENTE NA SRA 

/*
        // Verifica se o produto informado é um EPI
        // Se for, verifica se este já está cadastro na tabela TN3.
        // Se não tiver, obriga a informalção de C.A.
		dbSelectArea("TN3")
		//TN3->(DbOrderNickName("XTN3")) //TN3_FILIAL+TN3_CODEPI+TNF_NUMCAP
		dbSetOrder(3)
		dbSeek(xFilial("TN3") + aCols[n][_nProd] + aCols[n][_nCA])  
		If ( ! Found() )
			MsgAlert("Quando informado uma matricula, o Produto - E.P.I. e C.A. devem constar como EPI no sistema -  TN3!","# Produto EPI - C.A.!")
			_lRet	:= .F.	
		EndIf
		
		dbCloseArea("TN3")

*/		

	Else
	
		//SE não for uma matricula e o campo não for branco, precisa ser uma equipe
		If !Empty(aCols[n][_nSEQFUNC])
			
		   dbSelectArea("AA1")
		   dbSetOrder(1)
		   dbSeek(xFilial("AA1")+aCols[n][_nSEQFUNC])
		   
		   If ( ! Found() ) 
			  MsgAlert("Equipe não está cadastrada na tabela de Atendentes.","ATENÇÃO!")
			  _lRet	:= .F. 	
		   Else	                        
		      
		      //Prepara o código da Equipe pois na tabela ZZ4 o tamanho do campo é 6 dígitos
		      kEquipe := Alltrim(aCols[n][_nSEQFUNC]) + Space(06 - LEN(Alltrim(aCols[n][_nSEQFUNC])))
		      		      
		      dbSelectArea("ZZ4")
			  dbSetOrder(1)
     		  dbSeek(xFilial("ZZ4") + kEquipe)
			  
			  If ( ! Found() ) 
 			     MsgAlert("Equipe não está vinculada na tabela ZZ4 (Relaciona Técnico X Equipe).","ATENÇÃO!")
				 _lRet	:= .F. 			
			  Else	
	  		     // Verificar aqui se existe o cadastro de EPC para este produto.	
				 dbSelectArea("ZZD")
				 dbSetOrder(2)
				 dbSeek(xFilial("ZZD") + aCols[n][_nProd])
				 If (!Found())
					_lRet := MsgYesNo("O Produto nunca foi utilizado como EPC. Utilizar mesmo assim?","ATENÇÃO!")
				 EndIF
			  EndIf
				
			EndIf
			
		EndIf
					
	EndIf	  
	
	// Veririfca se a unidade da matrícula foi informada para a linha
	If Empty(Alltrim(aCols[n][_nUnidade]))
	   MsgAlert("Unidade da Matrícula não informada.", "ATENÇÃO!")
	   _lRet := .F.
	Endif
	
    // Verifica se motivo foi selecionado
    If Empty(Alltrim(aCols[n][_nMotivo]))
	   MsgAlert("Motivo não foi selecionado. Verifique!", "ATENÇÃO!")
	   _lRet := .F.
	Endif

Return(_lRet)
