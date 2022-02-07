#include 'protheus.ch'
#include 'parmtype.ch'

User Function MATA019()

Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
Local cMsg       := ''
//Local cClasse := ""
//Local nLinha     := 0
//Local nQtdLinhas := 0

If aParam <> NIL
      
    oObj       := aParam[1]
    cIdPonto   := aParam[2]
    cIdModel   := aParam[3]
    lIsGrid    := ( Len( aParam ) > 3 )
    /*
    If lIsGrid
          nQtdLinhas := oObj:GetQtdLine()
          nLinha     := oObj:nLine
    EndIf
    */
    If     cIdPonto == 'MODELPOS'
          cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
          cMsg += 'ID ' + cIdModel + CRLF
/*         
          If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                 Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
          EndIf
  */       
    ElseIf cIdPonto == 'FORMPOS'
 /*         cMsg := 'Chamada na validação total do formulário (FORMPOS).' + CRLF
          cMsg += 'ID ' + cIdModel + CRLF
         
          If cClasse == 'FWFORMGRID'
                 cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ;
                 '     linha(s).' + CRLF
                 cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
        ElseIf cClasse == 'FWFORMFIELD'
                 cMsg += 'É um FORMFIELD' + CRLF
          EndIf
         
          If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                 Help( ,, 'Help',, 'O FORMPOS retornou .F.', 1, 0 )
          EndIf
   */      
    ElseIf cIdPonto == 'FORMLINEPRE'
/*          If aParam[5] == 'DELETE'
                 cMsg := 'Chamada na pre validação da linha do formulário (FORMLINEPRE).' + CRLF
                 cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
                 cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) +;
                 ' linha(s).' + CRLF
                 cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
                 cMsg += 'ID ' + cIdModel + CRLF
                
                 If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
                        Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
                 EndIf
          EndIf
  */       
    ElseIf cIdPonto == 'FORMLINEPOS'
/*         cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' + CRLF
         cMsg += 'ID ' + cIdModel + CRLF
         cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ;
         ' linha(s).' + CRLF
         cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha     ) ) + CRLF
         
         If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
             Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
          EndIf
  */       
    ElseIf cIdPonto == 'MODELCOMMITTTS'
        /* ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )
         */
    ElseIf cIdPonto == 'MODELCOMMITNTTS'
         /*ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)
         */
          //ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
         
    ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
     /*    ApMsgInfo('Chamada apos a gravação da tabela do formulário (FORMCOMMITTTSPOS).' + CRLF + 'ID ' + cIdModel)
       */  
    ElseIf cIdPonto == 'MODELCANCEL'
 /*        cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
         
         If !( xRet := ApMsgYesNo( cMsg ) )
             Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
          EndIf
   */      
    ElseIf cIdPonto == 'BUTTONBAR'
//         ApMsgInfo('Adicionando Botao na Barra de Botoes (BUTTONBAR).' + CRLF + 'ID ' + cIdModel )
           xRet :=  {{"Gera Filiais", "", {||u_FillSbz()},""}}
//         xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este botao Salva' } }
    EndIf     
            
EndIf
Return xRet


USER FUNCTION FILLSBZ
   // -----------------------------------------------
   // Leef - Machado - 10/01/20
   // inclui dados de SB1 para SBZ para todas filiais
   // chamado do menu de MATA019
   // -----------------------------------------------
   local area019:=getarea()
   local naotem
   local cposb1
   local cposbz   
   local f
   local nlin
   local emptycols
   local filSB1:=xFilial("SB1")
   local aFils :={}
  //  LOCAL oView:=FWViewActive()
   if !empty(filSB1)
      msgAlert("Será Gerado Apenas Para Filial Corrente","Cadastro de Produtos Exclusivo")
   endif   
   oLFModel:=FWModelActive()
   oSBZ  :=oLFModel:GetModel("SBZDETAIL")
   
   // ALERT("aCOLS TEM "+STR(LEN(Osbz:aCols))+" LINHAS")
   
   //u_lfmostra(osbz:aCols)
   
   // campos SBZ que nao tem no SB1 ou que nao devem ser informados
   naotem:={"BZ_CTRWMS","BZ_DTINCLU","BZ_FCIPRV","BZ_HABDIF","BZ_LOCALI2"}  // campos que nao tem na sb1
   // inclui outros campos nao usados de SBZ
   dbselectarea("SX3")
   dbsetorder(1)  // ALIAS
   dbseek("SBZ")
   do while !eof() .and. sx3->x3_arquivo=="SBZ"
      If !X3Uso(SX3->X3_USADO) .or. cNivel < SX3->X3_NIVEL 
         aadd(naotem, alltrim(sx3->x3_campo))
      endif
      dbskip()
   enddo
   // posiciona o SM0
   dbselectarea("SM0")
   dbgotop()
   do while !eof()
      if alltrim(sm0->M0_CODIGO) = alltrim(cEmpAnt)
         if !empty(filSB1) .and. alltrim(sm0->m0_codfil)==cFilAnt
            aadd(aFils,alltrim(sm0->m0_codfil))
         else   
            aadd(aFils,alltrim(sm0->m0_codfil))
         endif
      endif
      dbskip()
   enddo
   // reposiciona o SM0
   dbselectarea("SM0")
   dbgotop()
   do while !eof()
      if alltrim(sm0->m0_codfil)==cFilAnt
         exit
      endif
      dbskip()
   enddo
   dbselectarea("SBZ")
   RestArea(area019)
   dbselectarea("SBZ")
   //## LIMPEZA DO GRID  - ACOLS - ASSIS - 21/01/2020    
   oSBZ:ClearData()
   // ### INICIO DA CARGA ACOLS   -  
   emptycols:=Osbz:aCols[1]
   for nlin:=1 to len(aFils)
    	cposb1:=SB1->B1_LOCPAD
  		oSBZ:AddLine()// somente acrescentará 1 se os dados obrigatórios forem preenchidos, nesse caso ZA2_AUTOR
    	oSBZ:SetValue("BZ_FILIAL", aFils[nLin])
    	oSBZ:SetValue("BZ_LOCPAD", cposb1)
    	for f:=2 to len(oSBZ:aHeader)-1  //nao funcionou, tente pegar direto do sm0 posicionado
    		cposbz:=oSBZ:Aheader[f][2]
    		if ascan(naotem,cposbz)==0
//    		    if alltrim(SUBSTR(cposbz,4,10))<>"DESC"
    		    	cposb1:=&("SB1->B1_"+alltrim(SUBSTR(cposbz,4,10)))
    				Osbz:aCols[nlin][f]:=cposb1
//    			endif
    		endif
    	next
    next
    oSBZ:SetLine( 1 )
    // oView:Refresh()
    restarea(area019)
    dbselectarea("SBZ")
RETURN


/*
Static FUNCTION LFMOSTRA(PVAR)
   local cvar       :=varinfo("VARINFO", pvar, 0 ,.f.)
   local oDlg1
   local oSay1
   local oMGet1
   local oBtn1
   oDlg1      := MSDialog():New( 092,232,600,803,"VARINFO",,,.F.,,,,,,.T.,,,.T. )
   oSay1      := TSay():New( 004,004,{||"oSay1"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,072,008)
   oMGet1     := TMultiGet():New( 020,004,{|u| If(PCount()>0,cvar:=u,cvar)},oDlg1,272,204,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
   oBtn1      := TButton():New( 228,116,"OK",oDlg1,{||oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
   oDlg1:Activate(,,,.T.)
RETURN .T.
*/
