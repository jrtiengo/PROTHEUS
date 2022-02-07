#Include 'Protheus.ch'
#Include 'RwMake.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB108TEC º Autor ³ Alisson R. Teles   º Data ³  26/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB108TEC()
Local cAliasTOs :="Z10"
Local cPrefixTOs:="Z10_"
Local nOrdTOs   :=2

Local cAliasCab :="AB6"
Local cPrefixCab:="AB6_"
Local nOrdCab   :=1

Local cAliasPic := "SZM"
Local cPrefixPic:= "ZM_"
Local nOrdPic   := 4


Local cTipoOS := ""
Local lRet    := .T.	

Local lErro:=.F.
Local cPicture:=""

(cAliasPic)->(DBGOTOP())

//CONVERTE TIPO DE OS DESCRIÇÃO PARA CODIGO
dbSelectArea(cAliasTOs)
dbsetOrder(nOrdTOs)

(cAliasTOs)->(MSSeek(xFilial(cAliasTOs) + M->&(cPrefixCab+"TPOS") ))
cTipoOS := (cAliasTOs)->&(cPrefixTOs+"COD")

//POSICIONA EM CADASTRO DE MASCARAS
dbSelectArea(cAliasPic)
dbsetOrder(nOrdPic)
IF(cAliasPic)->(MSSeek(xFilial(cAliasPic) + M->&(cPrefixCab+"CODCLI")  + cTipoOS))
	while (cAliasPic)->(!eof()) .AND. (cAliasPic)->&(cPrefixPic + "CODCLI") == M->&(cPrefixCab+"CODCLI") .AND. AllTrim((cAliasPic)->&(cPrefixPic + "COD"))==Alltrim(cTipoOs) 	
		//FUNÇÃO QUE VALIDA MASCARAS E RETORNA .T. SE MASCARA ESTA APTA
		lRet:=U_FB109TEC(M->&(cPrefixCab + "NROBRA"),@lErro,@cPicture)
		(cAliasPic)->(dbSkip())
		
		if lRet
			exit
		endif

		if !lRet .and. lErro  
			if (cAliasPic)->&(cPrefixPic + "CODCLI") != M->&(cPrefixCab+"CODCLI")
				Msginfo("Mascara inválida! Máscara sujerida: "+ cPicture)
				exit
			endif
		endif
	enddo
	
	if !lRet .and. !lErro
		msginfo("Mácara inválida!")
	endif
		
ENDIF
	
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB110TEC º Autor ³ Alisson R. Teles   º Data ³  26/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FB110TEC()
Local lRet := .T.
Local cAliasTOs :="Z10"
Local cPrefixTOs:="Z10_"
Local nOrdTOs   :=2

Local cAliasCab :="AA3"
Local cPrefixCab:="AA3_"
Local nOrdCab   :=1

Local cAliasPic := "SZM"
Local cPrefixPic:= "ZM_"
Local nOrdPic   := 4

Local cTipoOS := ""
Local lRet    := .T.	

Local lErro:=.F.
Local cPicture:=""

//CONVERTE TIPO DE OS DESCRIÇÃO PARA CODIGO
//dbSelectArea(cAliasTOs)
//dbsetOrder(nOrdTOs)

//(cAliasTOs)->(MSSeek(xFilial(cAliasTOs) + M->&(cPrefixTOs+"TPOS") ))
//cTipoOS := (cAliasTOs)->&(cPrefixTOs+"COD")
//POSICIONA EM CADASTRO DE MASCARAS
dbSelectArea(cAliasPic)
dbsetOrder(nOrdPic)

(cAliasPic)->(DBGOTOP())

if (cAliasPic)->(MSSeek(xFilial(cAliasPic) + M->&(cPrefixCab+"CODCLI") ))	
	while (cAliasPic)->(!eof())  .AND. (cAliasPic)->&(cPrefixPic + "CODCLI") == M->&(cPrefixCab+"CODCLI") //.AND. M->&(cPrefixCab+"COD") == cTipoOS
		//FUNÇÃO QUE VALIDA MASCARAS E RETORNA .T. SE MASCARA ESTA APTA
		lRet:=U_FB109TEC(M->&(cPrefixCab + "NUMSER"),@lErro,@cPicture)

		//SE ATENDER A UM TIPO JA É LIBERADO
		if lRet
			exit
		endif
		
		(cAliasPic)->(dbSkip())

		if !lRet .and. lErro 
				IF (cAliasPic)->&(cPrefixPic + "CODCLI") != M->&(cPrefixCab+"CODCLI") //.or. (cAliasPic)->(eof())
					Msginfo("Macara inválida! Máscara sujerida: "+ cPicture)
					exit
				ENDIF
		endif
	enddo
	
	if !lRet .and. !lErro
		msginfo("Mácara inválida!")
	endif
	
EndIf


Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB109TEC º Autor ³ Alisson R. Teles   º Data ³  26/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB109TEC(cObraTela,lMsg,cPicId)
Local cAliasPic := "SZM"
Local cPrefixPic:= "ZM_"
Local nOrdPic   := 4

Local cInitObra  := AllTrim((cAliasPic)->&(cPrefixPic + "INICIAL"))
Local nTamInit   := len(cInitObra)

Local cObraTela  := Alltrim(cObraTela)

//VALIDA CARACTER INICIAL
if UPPER(Substr(cObraTela,0,nTamInit)) == cInitObra
	cPicId:= AllTrim((cAliasPic)->&(cPrefixPic + "PICFULL"))

	//VALIDA TAMANHO DE CARACTER
	if len(cObraTela)==len(alltrim((cAliasPic)->&(cPrefixPic + "PICFULL")))

		//VALIDA FORMATO DA MASCARA		
		if !isPicture(cObraTela,alltrim((cAliasPic)->&(cPrefixPic + "PICFULL")))	
			lMsg :=.T.
			Return .F.	
		endif
	else
		lMsg :=.T.
		return .F.
	endif
else
	Return .F.
endif

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB111TEC º Autor ³ Alisson R. Teles   º Data ³  26/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function isPicture(cPicReceive,cPicIdeal)
Local lRet  :=.T.
Local aPicR :={}
Local aPicI :={}
Local nI := 0

		//separa os dois componentes em arrays para comparação
		for nI:= 1 to Len(cPicIdeal)
			aadd(aPicI,Substr(Upper(cPicIdeal),nI,1))
			aadd(aPicR,Substr(Upper(cPicReceive),nI,1))
		next
		//u_showarray(aPicI)
		//u_showarray(aPicR)
		
		for nI:= 1 to Len(cPicIdeal)
			//se LETRA no lugar de NUMERO
			if ASC(aPicI[nI]) == 48 .AND. (ASC(aPicR[nI])>57 .or. ASC(aPicR[nI])<48)
				//ALERT("NUMERO NAO CORRESPONDIDO")
				lRet :=.F.
				Exit	
			//se NUMERO no lugar de LETRA
			elseif ASC(aPicI[nI]) == 88 .AND. (ASC(aPicR[nI])> 90 .or. ASC(aPicR[nI])<65)
				//ALERT("LETRA NAO CORRESPONDIDO")
				lRet :=.F.
				Exit
		   //caracter especial nao correspondido
			elseif (ASC(aPicI[nI]) != 88 .AND. ASC(aPicI[nI]) != 48 ) .AND.( ASC(aPicI[nI]) != ASC(aPicR[nI]))
				//ALERT("ESPECIAL NAO CORRESPONDIDO")
				lRet :=.F.
				Exit
			endif
			
		next

Return lRet
