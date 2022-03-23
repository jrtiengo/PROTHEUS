//********************************************************************************************************
// Esta rotina transfere os componentes de uma OP do armazem padrão (B1_LOCAL) para o armazem indicado
// no campo cDestino da tela abaixo. O armazem cDestino deve existir no B2.
// Inicio 04/04/18 - Programador Paulo Machado - Leef Tecnologia Ltda.
// chamada do menu principal. opcionalmente do menu das Ordens de Produção (MATA650)
//********************************************************************************************************

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
User Function LF_TRANSF
   Local acores:={}  
   Private cDescProd  := Space(30)
   Private cDestino   := Space(2)
   Private cItemOp    := Space(2)
   Private cNumOp     := Space(6)
   Private cSeqOp     := Space(3)
   Private cOpSep     := Space(13)
   Private nQuant     := 0
   Private nSaldoDisp := 0
   Private errosaldo  :=.f.
   Private erroinib2  :=.f.
   Private b2fil      :=xFilial("SB2")
   Private b1fil      :=xFilial("SB1")
   Private d3fil      :=xFilial("SD3")
   Private d4fil      :=xFilial("SD4")    
   Private cItemAte   := Space(2)
   Private cItemDe    := Space(2)
   Private cOpAte     := Space(6)
   Private cOpDe      := Space(6)
   Private cSeqAte    := Space(3)
   Private cSeqDe     := Space(3)
   Private dDataAte   := CtoD(" ")
   Private dDataDe    := CtoD(" ")
   
   Private _cTRB	:= GetNextAlias() //Alias Tabela Temporária
   
   SetPrvt("oDlg1","oPanel1","oSay3","oSay4","oSay2","oSay1","oSay5","oSay6","oSay7","oGet4","oGet3","oGet1")
   SetPrvt("oGet5","oGet6","oGet7","oBtn3","oBrw1","oBtn1","oBtn2")      
   oDlg1      := MSDialog():New( 135,273,635,1280,"Transferência de Almoxarifado",,,.F.,,,,,,.T.,,,.T. ) // 1109
   oPanel1    := TPanel():New( 004,004,"",oDlg1,,.F.,.F.,,,336,032,.T.,.F. )
   oSay1      := TSay():New( 004,004,{||"Armaz.Destino:"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
   oSay2      := TSay():New( 004,108,{||"Num.Op.:"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)   
   oSay3      := TSay():New( 004,192,{||"Item"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   oSay4      := TSay():New( 004,252,{||"Sequencia"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   oSay5      := TSay():New( 016,004,{||"Produto:"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   oSay6      := TSay():New( 016,157,{||"Saldo a Transf.:"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008)
   oSay7      := TSay():New( 016,252,{||"Quantidade:"},oPanel1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   oGet1      := TGet():New( 004,045,{|u| If(PCount()>0,cDestino:=u,cDestino)},oPanel1,028,008,'',             ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"NNR","cDestino",,)     
   oGet2      := TGet():New( 004,144,{|u| If(PCount()>0,cNumOp:=u,cNumOp)},oPanel1,036,008,'',{||cargaop()}    ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC2","cNumOp",,)
   oGet3      := TGet():New( 004,212,{|u| If(PCount()>0,cItemOp:=u,cItemOp)},oPanel1,024,008,'',               ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cItemOp",,)
   oGet4      := TGet():New( 004,288,{|u| If(PCount()>0,cSeqOp:=u,cSeqOp)},oPanel1,040,008,'',                 ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cSeqOp",,)
   oGet5      := TGet():New( 016,045,{|u| If(PCount()>0,cDescProd:=u,cDescProd)},oPanel1,104,008,'',           ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cDescProd",,)
   oGet6      := TGet():New( 016,205,{|u| If(PCount()>0,nSaldoDisp:=u,nSaldoDisp)},oPanel1,028,008,'9999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nSaldoDisp",,)
   oGet7      := TGet():New( 016,288,{|u| If(PCount()>0,nQuant:=u,nQuant)},oPanel1,028,008,'9999.9999',{||poptbl()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQuant",,)
   oBtn1      := TButton():New( 004,356,"Transfere",oDlg1,{||transfere()},037,012,,,,.T.,,"",,,,.F. )
   oBtn2      := TButton():New( 024,356,"Relatorio",oDlg1,{||ImpOp()},037,012,,,,.T.,,"",,,,.F. )
   oBtn3      := TButton():New( 228,188,"Sai"      ,oDlg1,{||fecha()},037,012,,,,.T.,,"",,,,.F. )
   
   oTbl1()
   dbSelectArea(_cTRB)  //DbSelectArea("LfTMP")
   //Define as cores dos itens de legenda.
   aAdd(aCores,{&("_cTRB")+'->flagOk == "0"','BR_VERDE' })
   aAdd(aCores,{&("_cTRB")+"->flagOk == '2'","BR_VERMELHO"})
   oBrw1      := MsSelect():New( _cTRB,"","",{{"Produt","","Produto"    ,"@!"},;
                                           {"Descri","","Descricao Produto","@!"},;
                                           {"Origem","","Origem"     ,"@!"},;   
                                           {"Destin","","Destino"    ,"@!"},;   
                                           {"SldEst","","Sld Estoque","@E 9999.9999"},;
                                           {"SldEmp","","Sld Empenho","@E 9999.9999"},;
                                           {"QtdSep","","Separar"    ,"@E 9999.9999"}},.F.,,{040,004,224,500},,, oDlg1,,aCores)  // 415
   oDlg1:Activate(,,,.T.)
Return
//**************************************************************
Static Function Transfere
   if nQuant<=0
      return .f.
   endif   
   // valida operação e transfere os itens se ok
   if erroinib2
	   alert("Alguns itens devem ser inicializados primeiro (armazém)!")
		return .f.
	endif	
   if errosaldo
	   alert("Alguns itens não tem saldo suficiente !")
		return .f.
	endif	
	if !Iw_MSGBox("Confirma a transferência ?","ATENCAO","YESNO")
	   return .f.
	endif
	aAuto := {}
   cDocumento  := Criavar("D3_DOC")
	cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
	cDocumento	:= A261RetINV(cDocumento)
	Aadd( aAuto, {cDocumento, dDatabase} ) 
	//dbselectarea('LfTMP')
	//dbgotop()
   dbselectarea(_cTRB)
   (_cTRB)->(dbGoTop())

	do while !eof()    
	   if (_cTRB)->qtdsep<=0
	      dbskip()
	      loop
	   endif   
	   DBSELECTAREA("SB1")
      dbSeek(b1fil+(_cTRB)->Produt)
      aItem := {}
      //Origem
      aAdd(aItem,SB1->B1_COD)                 //D3_COD                 01
      aAdd(aItem,SB1->B1_DESC)                //D3_DESCRI              02
      aAdd(aItem,SB1->B1_UM)                  //D3_UM                  03
      aAdd(aItem,(_cTRB)->origem)               //D3_LOCAL               04
      aAdd(aItem,"")                          //D3_LOCALIZ             05
      //Destino
      aAdd(aItem,SB1->B1_COD)                 //D3_COD                 06
      aAdd(aItem,SB1->B1_DESC)                //D3_DESCRI              07
      aAdd(aItem,SB1->B1_UM)                  //D3_UM                  08
      aAdd(aItem,(_cTRB)->destin)               //D3_LOCAL               09
      aAdd(aItem,"")                          //D3_LOCALIZ             10
      //Origem
      aAdd(aItem,"")                          //D3_NUMSERI             11
      aAdd(aItem,"")                          //D3_LOTECTL             12
      aAdd(aItem,"")                          //D3_NUMLOTE             13
      aAdd(aItem,Ctod(""))                    //D3_DTVALID             14
      //B1_RASTRO
      aAdd(aItem,0)                           //D3_POTENCI             15
      aAdd(aItem,(_cTRB)->qtdsep)               //D3_QUANT               16
      aAdd(aItem,0)                           //D3_QTSEGUM             17
      aAdd(aItem,"")                          //D3_ESTORNO             18
      aAdd(aItem,"")                          //D3_NUMSEQ              19
      //Destino
      aAdd(aItem,"")                          //D3_LOTECTL             20
      aAdd(aItem,Ctod(""))                    //D3_DTVALID             21
      aAdd(aItem,"")                          //D3_ITEMGRD             22
      aAdd(aItem,cOpSep)                      //D3_OBSERVA             23
      
      aAdd(aAuto,aItem) 
      dbselectarea(_cTRB)
	  (_cTRB)->(dbskip())
   enddo
   // gera a transferencia de local
   lAutoErrNoFile := .F.
   lMsErroAuto    := .F.
   lMSHelpAuto    := .T. // se igua a .T. nao aparecem os Avisos
   // executa a transferencia de estoque
   MSExecAuto({|x,y| MATA261(x,y)}, aAuto, 3)
   If lMsErroAuto  
      mostraerro()
      cMsg := "Erro. Verifique a mensagem abaixo:" + CRLF
      aMsg := GetAutoGRLog()
      aEval(aMsg,{|x| cMsg += x + CRLF })   
      Aviso("Transferencia", cMsg, {"Ok"}, 3)
      oDlg1:End()
   Else
      cDocumento:=PegaDoc(aItem)  
      // Grava OPSEP em todos os registro de transferencia deste documento
      DBSELECTAREA("SD3")
      dbSetOrder(2)   // D3_FILIAL + D3_DOC ...
      dbSeek(d3fil+cDocumento) 
      if !found() .or. empty(cDocumento)
         alert("Houve falha na gravacao de D3_OPSEP, avise programador !")
      else
         While ! Eof() .and. d3fil+cDocumento == SD3->D3_FILIAL+SD3->D3_DOC
            RecLock("SD3", .f.) 
            SD3->D3_OPSEP := cOpSep
            MsUnLock() 
            dbSkip() 
         EndDo
      endif   
      cOpDe   :=sc2->c2_num
      cItemDe :=sc2->c2_item
      cSeqDe  :=sc2->c2_sequen       
      cOpAte  :=cOpDe
      cItemAte:=cItemDe
      cSeqAte :=cSeqDe
      dDataDe :=dDataBase
      dDataAte:=dDataDe
      OrdSep()
      cDescProd  := Space(30)
      cDestino   := Space(2)
      cItemOp    := Space(2)
      cNumOp     := Space(6)
      cSeqOp     := Space(3)
      cOpSep     := Space(13)
      nQuant     := 0  
      nSaldoDisp := 0
   	  errosaldo  :=.f.
	  erroinib2  :=.f.   
	  //dbselectarea("LfTMP")
     dbselectarea(_cTRB)
     ZAP
     (_cTRB)->(dbgotop())
	  oBrw1:oBrowse:Refresh(.t.)
   EndIf
return
//**************************************************************
Static Function CargaOp
   // valid do campo cNumOp. 
   if empty(cNumOp)
      alert("Informe o número da OP !")
	  return .f.
   endif  
   if sc2->c2_quje>=sc2->c2_quant
      alert("OP Já foi totalmente atendida !")
      return .f.
   endif  
   nQuant   := 0     
   cSeqOp   :=sc2->c2_sequen
   cItemOp  :=sc2->c2_item                                                  
   cOpSep   :=cNumOp+cItemOp+cSeqOp
   cDescProd:=posicione("SB1",1,xFilial("SB1")+sc2->c2_produto,"B1_DESC")  
   errosaldo:=.f.
   erroinib2:=.f.
   // tratamento para o caso da op ter sido apontada sem ter sido transferida.
   // então so posso transferir o D4_QUANT-SOMA(D3)/nsaldoop
   // exemplo: op de 4, apontei 2 sem transferir
   nsaldoop:=sc2->c2_quant-sc2->c2_quje
   // posiciono no primeiro item, por ele já sei o saldo real a transferir   
   // "teoricamente" itens são transferidos de acordo com a qtd de PA .
   dbselectarea("SD4")
   dbsetorder(2)  // filial+op+cod
   focod4:=xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+space(3)
   dbseek(focod4)
   do while !eof() .and. focod4==xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+space(3)
      // verifico transferidos
      nQtdJaSep :=jatransf()
      nSaldoDisp:=sd4->d4_quant-nQtdJaSep
      // quantos PA posso fazer com o que é possivel separar ?
      dbselectarea("SG1")
      dbsetorder(1) //  filial+cod+comp
      dbseek(xFilial("SG1")+sc2->c2_produto+sd4->d4_cod)
      if !found()
         // empenhado não presente na estrutura do PA deve ser componente de fantasma ou ter sido incluido manualmnte
         // nestes casos não posso utilizar como base para calculo. utilizo o proximo.
         dbselectarea("SD4")
         dbskip()
         loop
      endif
      exit
   enddo      
   nSaldoDisp:=nsaldoDisp/sg1->g1_quant
   //dbselectarea("LfTMP")
   dbselectarea(_cTRB)
   ZAP
   (_cTRB)->(dbgotop())
   oBrw1:oBrowse:Refresh(.t.)
return .t.
//**************************************************************
Static Function PopTbl
   Local DestOk:=.t.
   Local FilG1 :=xFilial("SG1")
   // popula tabela temporaria com os itens da OP e quantidades a serem transferidas.
   errosaldo  :=.f.
   erroinib2  :=.f.   
   if nQuant>nSaldoDisp                                        
	   return .f.
   endif
   //dbselectarea("LfTMP")
   dbselectarea(_cTRB)
   ZAP
 	(_cTRB)->(dbgotop())
	oBrw1:oBrowse:Refresh(.t.)
	dbselectarea("SB1")
	dbsetorder(1)  // filial+cod
	dbselectarea("SB2")
	dbsetorder(1)  // filial+cod+local
	dbselectarea("SD4")
	dbsetorder(2)  // filial+op+cod
	focod4:=xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+space(3)
	dbseek(focod4)
	if !found()
		alert("Empenhos não localizados !")
	endif	
	do while !eof() .and. focod4==sd4->d4_filial+sd4->d4_op
	   // verifica se item tem componentes
	   dbselectarea("SG1") 
	   dbselectarea(1) // filial+cod
	   IF SQL("SG1" , "G1_FILIAL+G1_COD" ,FILG1+SD4->D4_COD)  // =  DBSEEK(FILG1+SD4->D4_COD)
	      // item tem componentes, não deve ser transferido e sim produzido.
   	      dbselectarea("SD4")
	   	  dbskip()
	   	  loop
	   endif	
	   // verifica se tem saldo inicial no armazem de destino.
	   DestOk:=.t.
	   dbselectarea("SB2")
	   dbseek(b2fil+sd4->d4_cod+cDestino)
	   if !found()
	      alert('O item '+alltrim(sd4->d4_cod)+' não existe para o armazem '+cDestino)
	      erroinib2:=.t.
	      destok:=.f.
	   endif         
   	   // obtem transferencias já efetuadas
       nQtdJaSep := jatransf()
       // saldo empenhado e ainda não transferido
       nSldEmp := SD4->D4_QUANT - nQtdJaSep
       // quantidade para transferir
       nQtdSep:=nquant*(sd4->d4_qtdeori/sc2->c2_quant)
       // validacao se tem saldo disponivel no armazem de origem
	   dbselectarea("SB1")
	   dbseek(b1fil+sd4->d4_cod)
	   dbselectarea("SB2")
	   dbseek(b2fil+sd4->d4_cod+sb1->b1_locpad)
       saldob2:=SB2->B2_QATU-nQtdSep
       // popula tab temp com dados do que será transferido
	   
      //dbselectarea("LfTmp")
	   //reclock("LfTmp",.t.) 
      dbselectarea(_cTRB)
      (_cTRB)->(DBAppend())
	   (_cTRB)->flagok:=if(!destok .or. saldob2<0,'2','0')
	   (_cTRB)->produt:=sd4->d4_cod
	   (_cTRB)->descri:=sb1->b1_desc
	   (_cTRB)->origem:=sb1->b1_locpad
	   (_cTRB)->destin:=if(!destok,"??",cDestino)
	   (_cTRB)->sldest:=sb2->b2_qatu
	   (_cTRB)->sldemp:=nSldEmp
	   (_cTRB)->qtdsep:=nQtdSep
      (_cTRB)->(DBCommit())
      // msunlock()
	   if saldob2<0
	      errosaldo:=.t.
	   endif	       
	   dbselectarea("SD4")
	   dbskip()
   enddo
   //Lftmp->(dbgotop())
   (_cTRB)->(dbgotop())
   oBrw1:oBrowse:Refresh(.t.)
return .t.
//**************************************************************
Static Function oTbl1()
   // cria tabela temporaria
   Local aFds := {}
   Local cLfTmp
   Local tfArea:=1
   

   // area pode ter ficado aberta desde a ultima utilização, testa e fecha para recriar.
   //if SELECT("LfTMP")>0      
     // dbselectarea("LfTMP")
     // dbclosearea("LfTMP")
   //endif   

   Aadd( aFds , {"FlagOk" ,"C",001,000} )
   Aadd( aFds , {"Produt" ,"C",TAMSX3("B1_COD")[1],000} )
   Aadd( aFds , {"Descri" ,"C",040,000} )
   Aadd( aFds , {"Origem" ,"C",002,000} )                       
   Aadd( aFds , {"Destin" ,"C",002,000} )                       
   Aadd( aFds , {"SldEst" ,"N",011,004} )
   Aadd( aFds , {"SldEmp" ,"N",011,004} )
   Aadd( aFds , {"QtdSep" ,"N",011,004} )

   oTempTable := oTempTable := FWTemporaryTable():New( _cTRB, aFds  )
   oTempTable:AddIndex("01", {"Produt"} )	
   oTempTable:Create()

   //cLfTmp := CriaTrab( aFds, .T. )
   //Use (cLfTmp) Alias LfTMP New Exclusive

Return
//**************************************************************
static function fecha
   //dbselectarea("LfTMP")
   //dbclosearea("LfTMP")
   dbselectarea(_cTRB)
   dbCloseArea(_cTRB)
	oDlg1:End()
return .t.                                                      
//**************************************************************
static function jatransf
   local jt:=0
   BeginSql Alias 'SD3TMP'
      select Sum(D3_QUANT) AS QTDSD3
      from %Table:SD3% SD3
      where
      D3_FILIAL = %xFilial:SD3%
      and D3_LOCAL = %exp:cDESTINO%
      and D3_COD = %exp:SD4->D4_COD%
      and D3_OPSEP = %exp:cOpSep%
      and D3_ESTORNO <> %exp:"S"%
      and SD3.%notdel%
   EndSql
   jt:= SD3TMP->QTDSD3
   SD3TMP->(dbCloseArea())
return jt   
//**************************************************************    
Static Function ORDSEP
   // imprime a ordem/relatorio de separação
   // se pAuto==NIL indica que foi chamada do menu principal e que ponteiro está desposicionado
   // se pAuto==.t. indica que ponteiro em SC2 está posicionado.
	Local cDesc1         := "Imprime Ordem de Separação por Ordem de Produção,"
	Local cDesc2         := "por Data. Rotina Personalizada Leef/05/04/2018."
	Local cDesc3         := "Ordem de Separacao Para Producao"
	Local cPict          := ""
	Local titulo         := "Ordem de Separacao Para Producao"
	Local nLin           := 80
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "PR_TRANSF"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "RELSEPARA "
	Private aPerg        := {}
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "RELSEPARA"
	Private cString      := ""
	cOpSepDe  :=cOpDe+cItemDe+cSeqDe       
	cOpSepAte :=cOpAte+cItemAte+cSeqAte       
	
   dbselectarea("SC2")
	dbsetorder(1) // filial+num
	dbseek(xFilial("SC2")+cOpSep)
	
	dbselectarea("SB1")
	dbsetorder(1) // filial+cod
	dbseek(xFilial("SB1")+sc2->c2_produto)
	Cabec1:="Ordem de Produção : "+ if(cOpSepDe<>cOpSepAte,"Varias",cOpSepDe)+ " Produto: "+if(cOpSepDe<>cOpSepAte,"Varios",alltrim(sb1->b1_cod)+" - "+alltrim(sb1->b1_desc))
	Cabec2:="Data da Separação : "+ if(cOpSepDe<>cOpSepAte,"Varias",dtoc(dDataDe))
	
	wnrel := SetPrint(cString,NomeProg,'',@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
	   Return
	Endif
	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nOrdem
	local alfitem
	local lfpos
   cQuery:="SELECT D3_COD, D3_QUANT, D3_UM, D3_OPSEP, D3_EMISSAO, D3_EMISSAO, D3_DOC, B1_DESC, B1_UM"
   cQuery+=" FROM "+RetSQLNAmew("SD3")+" D3 INNER JOIN "+RetSqlName("SB1")+" B1 ON (D3_FILIAL=B1_FILIAL AND D3_COD=B1_COD AND B1.D_E_L_E_T_=' ')"
   cQuery+=" WHERE D3_FILIAL='"+xFilial("SD3")+"'"
   cQuery+=" AND D3_OPSEP>='"+cOpSepDe+"'"
   cQuery+=" AND D3_OPSEP<='"+cOpSepAte+"'"
   cQuery+=" AND D3_EMISSAO>='"+dtos(dDataDe)+"'"
   cQuery+=" AND D3_EMISSAO<='"+dtos(dDataAte)+"'"
   cQuery+=" AND D3_TM='999' AND D3.D_E_L_E_T_=' ' ORDER BY B1_DESC"
   cQuery:= ChangeQuery(cQuery)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"LFSEP",.T.,.T.)	
	SetRegua(RecCount())
	dbGoTop()
	aLfitem:={{lfsep->d3_opsep, lfsep->d3_doc, stod(lfsep->d3_emissao), lfsep->d3_cod, lfsep->b1_desc, lfsep->d3_quant, lfsep->b1_UM }}
	dbskip()
	While !EOF()
	   aadd(aLfitem,{lfsep->d3_opsep, lfsep->d3_doc, stod(lfsep->d3_emissao), lfsep->d3_cod, lfsep->b1_desc, lfsep->d3_quant, lfsep->b1_UM })
	   dbskip()
	enddo
	dbselectarea("LFSEP")
	dbclosearea("LFSEP")
	asort(aLfItem,,,{|x,y| x[2]>y[2] .and. x[5]>y[5]})
	for lfpos:=1 to len(alfitem)
	   If lAbortPrint
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	      Exit
	   Endif
	   If nLin > 55
	      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      nLin := 9
	      @nlin,000 psay "  OP                DOCUMENTO   DATA SEP   CODIGO                           DESCRICAO                        QUANTIDAD   UNI"
	      nlin:=nlin+1                                                                                  
	      @nlin,000 psay replicate("-",130)
	      nlin:=nlin+1
	   Endif            
   
//          1         2         3         4         5         6         7         8         9         0         1         2         3
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//  OP                DOCUMENTO   DATA SEP   CODIGO                           DESCRICAO                        QUANTIDAD   UNI 
//  123456789012345   123456789   88/88/88   123456789012345678901234567890   123456789012345678901234567890   9999.9999   UNI 
	   @nlin,002 psay left(alfitem[lfpos][1] ,15)
	   @nlin,020 psay left(alfitem[lfpos][2] ,09)
	   @nlin,032 psay alfitem[lfpos][3]
	   @nlin,043 psay left(alfitem[lfpos][4] ,30)
	   @nlin,076 psay left(alfitem[lfpos][5] ,30)
	   @nlin,109 psay      alfitem[lfpos][6] picture "@E 9999.9999"
 	   @nlin,121 psay left(alfitem[lfpos][7] ,03)
	   nlin:=nlin+1
	next
	SET DEVICE TO SCREEN
	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return
//**************************************************************
Static Function Limpatrab      
   cDescProd  := Space(30)
  	cDestino   := Space(2)
   cItemOp    := Space(2)
   cNumOp     := Space(6)
   cSeqOp     := Space(3)
   cOpSep     := Space(13)
   nQuant     := 0
   nSaldoDisp := 0
	errosaldo  :=.f.
	erroinib2  :=.f.   
return		
//**************************************************************  
Static Function ImpOp
   SetPrvt("oDlgImp","o2Say1","o2Say2","o2Say3","o2Say4","o2Say6","o2Say7","o2Say5","o2Say8","o2Get1","o2Get2","o2Get3")
   SetPrvt("o2Get5","o2Get7","o2Get8","o2Get9","o2Btn1","o2Btn2")
   oDlgImp    := MSDialog():New( 092,232,300,667,"Imprimir Ordem de Separação",,,.F.,,,,,,.T.,,,.T. )
   o2Say1      := TSay():New( 012,008,{||"Ordem De"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say2      := TSay():New( 012,125,{||"Ordem Até"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say3      := TSay():New( 052,008,{||"Data De"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say4      := TSay():New( 052,125,{||"Data Até"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say6      := TSay():New( 024,008,{||"Item"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say7      := TSay():New( 036,008,{||"Sequência"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say5      := TSay():New( 036,125,{||"Sequência"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Say8      := TSay():New( 024,125,{||"Item"},oDlgImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
   o2Get1      := TGet():New( 012,052,{|u| If(PCount()>0,cOpDe:=u,cOpDe)},oDlgImp,035,008,'',{||cgopde()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC2","cOpDe",,)
   o2Get2      := TGet():New( 012,161,{|u| If(PCount()>0,cOpAte:=u,cOpAte)},oDlgImp,035,008,'',{||cgopAte()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC2","cOpAte",,)
   o2Get3      := TGet():New( 052,052,{|u| If(PCount()>0,dDataDe:=u,dDataDe)},oDlgImp,035,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDataDe",,)
   o2Get4      := TGet():New( 052,160,{|u| If(PCount()>0,dDataAte:=u,dDataAte)},oDlgImp,035,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dDataAte",,)
   o2Get5      := TGet():New( 024,052,{|u| If(PCount()>0,cItemDe:=u,cItemDe)},oDlgImp,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cItemDe",,)
   o2Get6      := TGet():New( 036,052,{|u| If(PCount()>0,cSeqDe:=u,cSeqDe)},oDlgImp,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cSeqDe",,)
   o2Get7      := TGet():New( 024,161,{|u| If(PCount()>0,cItemAte:=u,cItemAte)},oDlgImp,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cItemAte",,)
   o2Get8      := TGet():New( 036,161,{|u| If(PCount()>0,cSeqAte:=u,cSeqAte)},oDlgImp,020,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cSeqAte",,)
   o2Btn1      := TButton():New( 072,052,"Imprime",oDlgImp,{||OrdSep()},037,012,,,,.T.,,"",,,,.F. )
   o2Btn2      := TButton():New( 072,128,"Sai",oDlgImp,{||oDlgImp:End()},037,012,,,,.T.,,"",,,,.F. )
   oDlgImp:Activate(,,,.T.)
Return	           
static function cgopde
   cItemde:=sc2->c2_item
   cSeqDe :=sc2->c2_sequen
return .t.    
static function cgopAte
   cItemAte:=sc2->c2_item
   cSeqAte :=sc2->c2_sequen
return .t.   
//**************************************************************  
static function pegadoc(pItem)
   local cquery                        
   local cDocum
   cQuery:="SELECT D3_DOC FROM SD3010 "
   cQuery+=" WHERE D3_COD='"+PITEM[01]+"'"
   cQuery+=" AND D3_LOCAL='"+PITEM[04]+"'"
   cQuery+=" AND D3_QUANT="+STRTRAN(ALLTRIM(STR(PITEM[16],14,4)),",",".")
   cQuery+=" AND D3_EMISSAO='"+DTOS(DDATABASE)+"'"
   cQuery+=" AND D3_TM='999'"
   cQuery+=" AND D3_ESTORNO<>'S'"
   cQuery+=" AND D_E_L_E_T_=' '"
   cQuery+=" AND D3_FILIAL='"+d3fil+"'"   
   cQuery+=" ORDER BY D3_NUMSEQ"
   cQuery:= ChangeQuery(cQuery)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"LFDOC",.T.,.T.)	   
   DBGOTOP()  // por algum motivo, dbgobottom nesta data fica em eof(), então avanco manualmente para ficar no ultimo.
   DO WHILE !EOF()
      cDocum:=LFDOC->D3_DOC
      DBSKIP()
   ENDDO   
   dbclosearea("LFDOC")
return cDocum
//******************************************************************//                 
Static FUNCTION SQL(pcAlias, pcCampos, pcAlvo, paRet)
   //=====================================================//
   //APL001: realiza um seek sem indice e retorna um array de valores ou posiciona na tabela consultada
   //                      onde     criterio          alvo            retorno 
   //APL002: exemplo : SQL("CC2" , "CC2_EST+CC2_MUN" ,A1_EST+A1_MUN , {"CC2_CODMUN"})            -> retorna {CC2_CODMUN}
   //APL003:           SQL("CC2" , "CC2_EST+CC2_MUN" ,A1_EST+A1_MUN , {"CC2_EST","CC2_CODMUN"})  -> Retorna {CC2_EST, CC2_CODMUN}
   //APL003:           SQL("CC2" , "CC2_EST+CC2_MUN" ,A1_EST+A1_MUN )                            -> posiciona no registro em CC2
   //=====================================================//
   local cstring:="SELECT "
   local i      :=0
   local sqlarea:=getarea()
   local sqltbl :=RetSqlName(pcAlias)
   local sqlrec :=0
   if paRet<>NIL
      FOR i:=1 to len(paret)
         cstring:=cstring+paret[i]
         if i<len(paret)
            cstring:=cstring+", "
         endif
      next                  
      cstring:=cstring+", R_E_C_N_O_"
   else 
      cstring+=" R_E_C_N_O_"
   endif   
   cstring:=cstring+" FROM "+sqltbl+" WHERE D_E_L_E_T_=' ' AND "+pcCampos+"='"+pcAlvo+"' "
   cQuery := ChangeQuery(cString)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SQL",.T.,.T.)
   dbgotop()
   if paRet==NIL
      sqlrec:=SQL->R_E_C_N_O_
      dbselectarea("SQL")
      dbclosearea()
      if sqlrec==0
         return .f.
      else   
         dbselectarea(pcAlias)
         dbgoto(sqlrec)
         return .t.
      endif   
   else
	   Retorno:={}
	   for i:=1 to len(paret)
	      aadd(retorno,&("SQL->"+paret[i]))
	   next
	   dbselectarea("SQL")
	   dbclosearea()
       restarea(sqlarea)
   endif	   
return retorno
//******************************************************************//