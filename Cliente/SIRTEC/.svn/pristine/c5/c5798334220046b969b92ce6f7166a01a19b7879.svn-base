#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
//*********************************************************
user function gpea060
   //Quando o modelo de dados possui vários componentes (por exemplo, vários FWFORMGRIDs), 
   //a 3th posição do vetor trará o ID deste componente
   Local aParam     := PARAMIXB
   Local xRet       := .T.
   Local oObj       := ''
   Local cIdPonto   := ''
   Local cIdModel   := ''
   //Local nLinha     := 0
   //Local nQtdLinhas := 0
   //Local cMsg       := ''
   //Local nlin
   Local cOper
   If aParam <> NIL
      oObj       := aParam[1]
      cIdPonto   := aParam[2]
      cIdModel   := aParam[3]
      cOper      := oObj:GetOperation()    //Armazena o tipo de operação que está sendo efetuada.    
      If cIdPonto == 'MODELPRE'
         //Antes da alteração de qualquer campo do modelo.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Requer um retorno lógico
         xRet:=.t. 
      elseIf cIdPonto == 'MODELPOS'
         //Na validação total do modelo.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Requer um retorno lógico
         xRet:=.t.      
      elseIf cIdPonto == 'FORMPRE'         
         //Antes da alteração de qualquer campo do formulário.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Requer um retorno lógico
         xRet:=.t.
      ElseIf cIdPonto == 'FORMPOS'
         //Na validação total do formulário.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         /*
			If     __CLASSNAME == 'FWFORMGRID'
         ElseIf __CLASSNAME == 'FWFORMFIELD'
         EndIf
         if cIdModel='CNBDETAIL'
            // grid de itens. percorre e avalia
            nQtdLinhas := oObj:GetQtdLine()
            nLinha     := oObj:nLine  // ou GetLine()        
            for nlin:=1 to nQtdLinhas
              oObj:GoLine(nLin)
              If oObj:GetValue("CNB_VLUNIT") >15
                 alert("maior que 15 na linha "+str(nlin))
              endif            
            next
            alert("saiu do grid")
         endif
         */
         //Retorno: Requer um retorno lógico  
         xRet:=.t.
      ElseIf cIdPonto == 'FORMLINEPRE'
         //Antes da alteração da linha do formulário FWFORMGRID.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //4     N        Número da Linha da FWFORMGRID
         //5     C        Ação da FWFORMGRID
         //6     C        Id do campo
         //nQtdLinhas := oObj:GetQtdLine()
         //nLinha     := oObj:nLine      
         //If aParam[5] == 'DELETE'   // ou cOper==5
         //   // tratamento
         //EndIf
         //Retorno: Requer um retorno lógico
         xRet:=.t.
      ElseIf cIdPonto == 'FORMLINEPOS'
         //Na validação total da linha do formulário FWFORMGRID.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //4     N        Número da Linha da FWFORMGRID
         //Retorno: Requer um retorno lógico
         //nQtdLinhas := oObj:GetQtdLine()
         //nLinha     := oObj:nLine
         xRet:=.t.      
      ElseIf cIdPonto == 'MODELCOMMITTTS'
         //Após a gravação total do modelo e dentro da transação.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Não espera retorno      
      ElseIf cIdPonto == 'MODELCOMMITNTTS'
         //Após a gravação total do modelo e fora da transação.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Não espera retorno      
      ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
         //Antes da gravação da tabela do formulário.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //4     L        Se .T. indica novo registro (Inclusão) se .F. registro já existente (Alteração / Exclusão)
         //Retorno: Não espera retorno      
      ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
         //Após a gravação da tabela do formulário.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //4     L        Se .T. indica novo registro (Inclusão) se .F. registro já existente (Alteração / Exclusão)
         //Retorno: Não espera retorno      
      ElseIf cIdPonto == 'MODELCANCEL'
         //No cancelamento do botão.
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Requer um retorno lógico
         xRet:=.t.
      ElseIf cIdPonto == 'BUTTONBAR'
         //Para a inclusão de botões na ControlBar.
         //Para criar os botões deve-se retornar um array bi-dimensional com a seguinte estrutura de cada item:
         //1     C        Titulo para o botão
         //2     C        Nome do Bitmap para exibição
         //3     B        CodeBlock a ser executado
         //4     C        ToolTip (Opcional)
         //Parâmetros Recebidos:
         //1     O        Objeto do formulário ou do modelo, conforme o caso
         //2     C        ID do local de execução do ponto de entrada
         //3     C        ID do formulário
         //Retorno: Requer um array de retorno com estrutura pré definida      
         xret:={}
         xRet:= {{'Conhecimento', 'BCO.CONH.', {||U_BCOGP060()},'BCOCP060'}}
      EndIf
   EndIf
Return xRet
//*********************************************************
user function BCOGP060
   // banco de conhecimento para Exames de Funcionarios
   // leef - machado - 24/03/21 - CH 52652
   Local nOpc     := GD_INSERT+GD_DELETE+GD_UPDATE
   local cQuery   := ""
   Local aNoFields:= {}
   Local area241  := getarea()
   Private noBrw2 := 0
   Private filsra :=xFilial("SRA")
   Private filac9 :=xFilial("AC9")
   Private filacb :=xFilial("ACB")
   Private filrc8 :=xFilial("RC8")
   Private aCols  := {}
   Private aHeader:= {}
   private crlf   :=chr(13)+chr(10)
   PRIVATE aExclui:= {}
   Private posdata
   Private postpex
   SetPrvt("oFont1","oDlg1","oGrp1","oSay1","oSay2","oSay3","oGrp2","oBrw2","oGrp3","oLBox1","oBtn3","oBtn4")
   SetPrvt("oBtn2")
   aAdd(aNoFields, 'RC8_MAT')
   aAdd(aNoFields, 'RC8_NOME')
   cQuery := "SELECT * FROM "+RetSqlName("RC8")+" RC8 WHERE RC8.RC8_FILIAL = '"+filRC8+"' AND RC8.RC8_MAT = '"+SRA->RA_MAT+"' AND RC8.D_E_L_E_T_ = ' '"
   FillGetDados( 4, "RC8", 2, filRC8+SRA->RA_MAT,  {|| RC8->RC8_FILIAL + RC8->RC8_MAT}, {|| .T.},aNoFields,,,cQuery)
   posdata:=aScan( aHeader, {|x| AllTrim(Upper(x[2])) == "RC8_DATA"})
   postpex:=aScan( aHeader, {|x| AllTrim(Upper(x[2])) == "RC8_TIPOEX"})
   oFont1     := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
   oDlg1      := MSDialog():New( 092,232,680,931,"Banco de Conhecimento Funcionario x Exames",,,.F.,,,,,,.T.,,,.T. )
   oGrp1      := TGroup():New( 004,004,044,340,"Funcionario",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
   oSay1      := TSay():New( 016,012,{||"Matricula...... : "+sra->ra_mat} ,oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,156,008)
   oSay2      := TSay():New( 024,012,{||"Nome........... : "+sra->ra_nome},oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,350,008)
   oSay3      := TSay():New( 032,012,{||"Centro de Custo : "+sra->ra_cc}  ,oGrp1,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,316,008)
   //------------------
   a:=180
   oGrp2      := TGroup():New( 048,004,a,340,"Exames",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
   oBrw2      := MsNewGetDados():New(056,008,180,336,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oGrp2,aHeader,aCols, {||AtuLBox1('RC8',FILRC8+SRA->RA_MAT+DTOS(acols[oBrw2:nAT][posdata])+acols[oBrw2:nAT][postpex])} )
   //------------------
   oGrp3      := TGroup():New( a+4,004,288,340,"Documentos",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
   oLBox1     := TListBox():New( a+12,008,,,a+128,056,  ,oGrp3,,CLR_BLACK,CLR_WHITE,.T.,,,,"",,,,,,, )
   oBtn3      := TButton():New( a+72,050,"Anexar"     ,oGrp3,;
   {||u_IncAnx(SRA->RA_FILIAL, FILRC8+SRA->RA_MAT+DTOS(acols[oBrw2:nAT][posdata])+acols[oBrw2:nAT][postpex], "RC8"),;
   AtuLBox1('RC8',FILRC8+SRA->RA_MAT+DTOS(acols[oBrw2:nAT][posdata])+acols[oBrw2:nAT][postpex])},;
   037,012,,,,.T.,,"",,,,.F. )
   oBtn4      := TButton():New( a+72,100,"Excluir"    ,oGrp3,{||delobj(oLbox1:nAT) },037,012,,,,.T.,,"",,,,.F. )
   oBtn5      := TButton():New( a+72,150,"Exportar"   ,oGrp3,{||saveas(oLbox1:nAT) },037,012,,,,.T.,,"",,,,.F. )
   oBtn6      := TButton():New( a+72,200,"Visualizar" ,oGrp3,{||viewobj(oLbox1:nAT) },037,012,,,,.T.,,"",,,,.F. )
   //--------------------
   //oBtn7      := TButton():New( a+92,100,"Bco de Conh",oDlg1,;
   //{||CALLMSDOC("RC8",1,FILRC8+SRA->RA_MAT+DTOS(acols[oBrw2:nAT][posdata])+acols[oBrw2:nAT][postpex])},;
   //037,012,,,,.T.,,"",,,,.F. )
   //--------------------
   oBtn8      := TButton():New( a+92,150,"Fecha"      ,oDlg1,{||oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
   oDlg1:Activate(,,,.T.)
   restarea(area241)
Return
//*************************************************
static function viewobj(pLin)  // visualiza arquivo
   local vwarea :=getarea()
   local aExclui:={}
   Default pLin:=0
   if plin<=0
      return
   Endif
   dbselectarea("ACB")
   dbsetorder(1)
   dbseek(filacb+left( oLBox1:aitems[plin],10) )
   RegToMemory( "ACB", .F., .F., .F.)
   //Ft340ExeObj()
   MsDocView( M->ACB_OBJETO, @aExclui, "" )
   restarea(vwarea)
return .t.
//*************************************************
STATIC FUNCTION saveas(pLin)  // exporta arquivo
   local vwarea:=getarea()
   dbselectarea("ACB")
   dbsetorder(1)
   dbseek(filacb+left( oLBox1:aitems[plin],10) )
   RegToMemory( "ACB", .F., .F., .F.)
   if Ft340SavAs()
      alert("Arquivo Exportado Com Sucesso.")
   Endif
   restarea(vwarea)
return .t.
//*************************************************
static function atulbox1(pEnt, pChv)  // atualiza listbox com arquivos anexados
   // leef - machado - 15/11/20
   local items:={}
   local lbxarea:=getarea()
   local qry
   qry:="SELECT AC9_CODOBJ, ACB_OBJETO "+CRLF
   qry+=" FROM "+RETSQLNAME("AC9")+" AC9 "+CRLF
   qry+=" INNER JOIN "+RETSQLNAME("ACB")+" ACB ON (AC9_FILIAL=ACB_FILIAL AND AC9_CODOBJ=ACB_CODOBJ AND ACB.D_E_L_E_T_=' ')"+CRLF
   qry+=" WHERE AC9_FILENT='"+filRC8+"' AND AC9_ENTIDA='"+pEnt+"'"+CRLF
   qry+=" AND AC9_CODENT='"+pChv+"'AND AC9.D_E_L_E_T_=' '"+CRLF
   //MEMOWRITE("C:\TEMP\CHAVE.TXT", QRY)
   TCQUERY Qry NEW ALIAS 'XAC9'
   dbgotop()
   do while !eof()
      aadd(items, xac9->ac9_codobj+" - "+alltrim(xac9->acb_objeto))
      dbskip()
   enddo
   dbselectarea("XAC9")
   dbclosearea()
   oLbox1:SetArray(ITEMS)
   restarea(lbxarea)
return .t.
//*************************************************
static function callmsdoc(palias, pOrdem, pchave)  // chama o bco conh padrao protheus
   // posiciona no primeiro registro antes de chamar o conhecimento.
   // leef - machado - 15/11/20
   local nrecno:=0
   local areabco:=getarea()
   dbselectarea(palias)
   dbsetorder(pOrdem)
   dbseek(pchave)
   nrecno:=recno()
   MsDocument(palias, nRecno,2)
   restarea(areabco)
return
//*************************************************
static function delobj(pLin)  // apaga o arquivo
   local vwarea  :=getarea()
   local aVinc   :={}
   local cVinc   :=""
   local vcodobj :=left( oLBox1:aitems[plin],10)
   local lexcluir:=.f.
   local destino := MsDocPath()
   local arquivo :=destino+"\"+alltrim(substr( oLBox1:aitems[plin],14,100))
   dbselectarea("ACB")
   dbsetorder(1)
   dbseek(filacb+left( oLBox1:aitems[plin],10) )
   //--------------------------------------
   if MsgNoYes( "Confirma exclusao ? Esta operação nao pode ser desfeita !", "Documento : "+ oLBox1:aitems[plin] )
      dbselectarea("AC9")
      dbsetorder(1)  // filial+codobj+entidade
      dbseek(filac9+vcodobj+"RC8")
      do while !eof() .and. vcodobj==ac9->ac9_codobj
         aadd(avinc, ac9->ac9_entida+ac9->ac9_filent+ac9->ac9_codent)
         cVinc:=cVinc+ac9->ac9_entida+" "+left(ac9->ac9_codent,30)+CRLF
         dbskip()
      enddo
      if len(avinc)==1
         lexcluir:=.t.
      else
         if MsgNoYes(cVinc, "Documento Com várias Associações - Confirma Exclusão ?")
            lexcluir:=.t.
         endif
      endif
      if lexcluir
         dbselectarea("AC9")
         dbsetorder(1)  // filial+codobj+entidade+filent+codent
         dbseek(filac9+vcodobj+"RC8")
         do while !eof() .and. vcodobj==ac9->ac9_codobj .and. filac9==ac9->ac9_filial .and. ac9->ac9_codobj==vcodobj
            reclock("AC9",.f.)
            dbdelete()
            msunlock()
            dbskip()
         enddo
         dbselectarea("ACB")
         dbsetorder(1)
         dbseek(filacb+vcodobj)
         if found()
            reclock("ACB",.f.)
            dbdelete()
            msunlock()
         endif
         nret:=ferase(arquivo)
         if empty(nret)
            alert("Documento Excluido Permanentemente")
         else
            alert("Erro na exclusão do arquivo, Avise TI")
         endif
      endif
   endif
   //--------------------------------------
   restarea(vwarea)
   AtuLBox1('RC8',FILRC8+SRA->RA_MAT+DTOS(acols[oBrw2:nAT][posdata])+acols[oBrw2:nAT][postpex])
return .t.
//*************************************************
user function incanx(pac9filent, pac9codent, pac9entida)   // inclui anexo no banco de conhecimento
   // leef - machado - 15/11/20
   Local anxarea :=getarea()
   Local cMascara:= "Todos os arquivos|*.*"
   Local cTitulo := "Incluir Anexo"
   Local nMascpad:= 0
   Local cDirini := "c:\"
   Local lSalvar := .F. /*.T. = Salva || .F. = Abre*/
   Local nOpcoes := GETF_LOCALHARD+GETF_NETWORKDRIVE
   Local lArvore := .F. /*.T. = apresenta o Arvore do servidor || .F. = nao apresenta*/
   Local origem  := ""
   local destino := MsDocPath()
   local filacb  :=xfilial("ACB")
   local filac9  :=xfilial("AC9")
   local cDrv, cPst, cArq, cExt
   Local cqry
   local jatem   :=""
   //
   origem := cGetFile( cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
   if !file(origem)
      return .t.
   endif
   SplitPath(origem, @cDrv, @cPst, @cArq, @cExt)
   //  VERIFICA SE ARQUIVO JA EXISTE
   dbselectarea("ACB")
   dbsetorder(2)  // filial+objeto
   dbseek(filacb+cArq+cExt)
   if found()
      Alert("Já existe arquivo no repositório com este nome. A associação será feita nele.")
      jatem:=acb->acb_codobj
   endif
   // VERIFICA SE ARQUIVO JA FOI ASSOCIADO AO REGISTRO ATUAL ANTERIORMENTE
   cqry:="SELECT ACB_CODOBJ FROM "+retsqlname("ACB")+" ACB"
   cqry+=" INNER JOIN "+retsqlname("AC9")+" AC9"
   cqry+=" ON (ACB_CODOBJ=ACB_CODOBJ AND AC9_FILIAL=ACB_FILIAL AND AC9_CODENT LIKE '"+pac9codent+"%' AND AC9.D_E_L_E_T_=' ' AND AC9_ENTIDA='"+'RC8'+"')"
   cqry+=" WHERE ACB_OBJETO='"+cArq+cExt+"'"
   cqry+=" AND ACB.D_E_L_E_T_=' '"
   TCQUERY cQry NEW ALIAS 'XACB'
   dbgotop()
   if !empty(xacb->acb_codobj)
      msgalert("Este arquivo ja se encontra associado a este registro "+pac9codent,cArq+cExt )
      dbselectarea("XACB")
      dbclosearea()
      restarea(anxarea)
      return .t.
   endif
   //
   dbselectarea("XACB")
   dbclosearea()
   IF EMPTY(JATEM)
      sucess:= CpyT2S(origem, destino)
      If (sucess)
         //Alert("Arquivo ''" + origem + "' copiado com sucesso para '" + destino + "'!")
         // associa ao pedido
         acbcodobj:=GetSxeNum("ACB","ACB_CODOBJ")
         ConfirmSX8()
         dbselectarea("ACB")
         reclock("ACB",.t.)
         acb->acb_filial:=filacb
         acb->acb_codobj:=acbcodobj
         acb->acb_objeto:=cArq+cExt
         acb->acb_descri:=cArq
         msunlock()
      Else
         Alert("Erro ao copiar o arquivo ''" + origem + "'!")
         acbcodobj:=""
      Endif
   Else
      acbcodobj:=JATEM
   Endif
   IF !EMPTY(acbcodobj)
      dbselectarea("AC9")
      reclock("AC9",.t.)
      ac9->ac9_filial:=filac9
      ac9->ac9_filent:=pac9filent
      ac9->ac9_entida:=pac9entida
      ac9->ac9_codent:=pac9codent
      ac9->ac9_codobj:=acbcodobj
      msunlock()
   Endif
   restarea(anxarea)
return
//*************************************************
