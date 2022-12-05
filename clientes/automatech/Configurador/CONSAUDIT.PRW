# Include "Protheus.ch"
# Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConsAudit ºAutor  ³Microsiga           º Data ³  08/18/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta ao Arquivo de Auditoria - Audit Trail             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ALTERACAO PAR USO NO CLIENTE:

ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
NOTAS:
1) Servidor ORIGEM: IP019 - IP: "10.244.68.6"
1) TopAlias = "AUDIT"
2) TopDataBase = "ORACLE"
3) TopServer = 10.244.68.6 (Nome do Servidor = IP019)

--------------------------     
AT_OP
I = Insert
U = Update (alteracao)
D = Delete
B = Begin
C = Commit
L = ? Recall
R = ? Roolback
X = ? Execute     

--------------------------     
"	Nível 1 
Monitora os Inserts, updates e os delets
"	Nível 2 
Monitora os Inserts, Delets, Execução de Statements SQL e armazena o conteúdo anterior das colunas.
"	Nível 3 
Monitora os Inserts, Delets, Execução de Statements SQL , 
armazena o conteúdo anterior das colunas além das marcações de Transação (Begin, End e commit)
--------------------------     
SELECT * FROM AUDIT_TRAIL
WHERE D_E_L_E_T_='*'
AND AT_OP NOT IN ('B','C','D','L','R','X','U','I')

*/

User Function ConsAudit()

Local   cEscolha
Local  	nColunas	:= 0
Local 	Alias

Private  _cTopAlias := "AUDITA"   
Private  _cTopDB    := "MSSQL"  
Private  _cTopSrv 	:= "SRVAD"
Private  _cTopSrvN  := "SRVAD"
Private aRotina 	:= {}
Private aTabelas 	:= {}
Private cCadastro
Private cAlias   
Private cEmpresa := "01"
//Private cEmpresa := "99"
Private cTopServer
Private cTopAlias

Private cDe  := ""
Private cAte := ""

cEscolha := AmbienteSel()

If Empty(cEscolha)
	Return .t.
Endif

// Vicente Lacerenza 05/01/2006
cTop	 	:= GetPvProfString("AUDITA","TOPALIAS",_cTopAlias,GetAdv97())  // AUDIT
cTopData	:= GetPvProfString("AUDITA","TOPDATABASE",_cTopDB,GetAdv97())  // ORACLE
cTopAlias	:= cTopData + "/" + cTop              //  "ORACLE/AUDIT"
cTopServer	:= GetPvProfString("AUDITA","TOPSERVER",_cTopSrv,GetAdv97())  // 10.244.68.6

//
// Caso tenha 2 bancos de auditoria, p.e.. um producao e outro historico,
// Habilitar as linhas abaixo e tratar demais locais especificos neste programa.
// Vicente
//

/*
If Left(cEscolha,1) == "1"
cTop	 	:= GetPvProfString("AUDIT","TOPALIAS","TOPAUDIT",GetAdv97())
cTopData	:= GetPvProfString("AUDIT","TOPDATABASE","TOPAUDIT",GetAdv97())
cTopAlias	:= cTopData + "/" + cTop              // "MSSQL7/TOPAUDIT"
cTopServer	:= GetPvProfString("AUDIT","TOPSERVER","10.97.215.129",GetAdv97())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Banco de dados de auditoria de producao (Alias = Audit)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
cTop	 	:= GetPvProfString("AUDITBCK","TOPALIAS","TOPAUDIT",GetAdv97())
cTopData	:= GetPvProfString("AUDITBCK","TOPDATABASE","TOPAUDIT",GetAdv97())
cTopAlias	:= cTopData + "/" + cTop
cTopServer	:= GetPvProfString("AUDITBCK","TOPSERVER","10.97.215.129",GetAdv97())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Banco de dados de auditoria de backup (Alias = AuditBck)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Endif
*/

If Substr(cEscolha,2,1) == "1"
	cEmpresa := "010"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Usuario informa filtro para auditar                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSx1()
	If ! Pergunte("CFG999____")
		Return .t.
	Endif
	AuditaFil()
	
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Usuario seleciona tabela a auditar                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAlias := TabelaSel()
	
	If ! Empty(aAlias[1])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Usuario seleciona registro a auditar                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cAlias 		:= aAlias[1]
		cCadastro 	:= aAlias[2]
		cEmpresa	:= aAlias[3]
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Garante que arquivo esteja aberto                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ChkFile(cAlias)
		
		Set Deleted Off
		
		DEFINE MSDIALOG oDlg TITLE 'Localizar registro - Tabela ' + cAlias FROM 000, 000 TO 600, 800 PIXEL
		
		DbSelectArea(cAlias)
		(cAlias)->(DbGoTop())
		nAlias := Select()
		
		oBrw := TcBrowse():New(01,01,399,280,,,,,,,,,,,,,,,,.F.,,.T.,,.F.,,)
		
		oBrw:bLDblClick:= { || Detalhe(cAlias,(cAlias)->(Recno())) }
		oBrw:lColDrag := .T.
		oBrw:lLineDrag := .T.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Colunas para visualizacao conforme SX3                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SX3->(DbSetOrder(1))
		SX3->(DbSeek(cAlias))
		While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAlias
			If SX3->X3_CONTEXT <> "V"
				oBrw:AddColumn(TCColumn():New(SX3->X3_TITULO,FieldWBlock(SX3->X3_CAMPO,nAlias),,,,"LEFT",,.F.,.F.,,,,.F.,))
			Endif
			SX3->(DbSkip())
		Enddo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define Botoes                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 285,085 BUTTON oBtnPesq ;
		PROMPT "&Pesquisa" ;
		OF oDlg PIXEL ;
		SIZE 50,12 ;
		ACTION (DBSelectArea(cAlias),AxPesqui())
		
		@ 285,145 BUTTON oBtnDeta ;
		PROMPT "&Detalhes" ;
		OF oDlg PIXEL ;
		SIZE 50,12 ;
		ACTION (Detalhe(cAlias,(cAlias)->(Recno())))
		
		@ 285,205 BUTTON oBtnAudi ;
		PROMPT "&Auditar" ;
		OF oDlg PIXEL ;
		SIZE 50,12 ;
		ACTION (AuditaReg(cAlias,(cAlias)->(Recno()),1))
		
		@ 285,265 BUTTON oBtnImpr ;
		PROMPT "&Imprimir" ;
		OF oDlg PIXEL ;
		SIZE 50,12 ;
		ACTION (AuditaReg(cAlias,(cAlias)->(Recno()),2))
		
		@ 285,325 BUTTON oBtnCanc ;
		PROMPT "&Cancelar" ;
		OF oDlg PIXEL ;
		SIZE 50,12 ;
		ACTION (oDlg:End())
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		Set Deleted On
		
	Endif
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TabelaSel ³ Autor ³ Rogerio Nagy          ³ Data ³ 19/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Seleciona arquivo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TabelaSel()

Local oDlg
Local oLbx
Local oPesq
Local cRet 		:= ""
Local cPesq		:= Space(20)
Local nPosArq
Local nPosLbx
Local nOAt		:=0
Local lOK 		:= .f.
Local aBancos 	:= {}
Local aRet 		:= {}

DbSelectArea("SX2")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa Filtro do SX2 para montar array com todas as tabelas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Filter To
SX2->(DbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com os dados do SX2                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! SX2->(Eof())
	AADD(aBancos,{SX2->X2_CHAVE,AllTrim( X2Nome() ), Substr(SX2->X2_ARQUIVO,4,3) })
	SX2->(DbSkip())
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna Filtro do SX2                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Filter To X2_CHAVE $ cFOpened

DEFINE MSDIALOG oDlg ;
FROM  010,5 TO 420,361 ;
TITLE OemToAnsi("Selecione o Arquivo") PIXEL

@ 6,7 LISTBOX oLbx FIELDS HEADER "" , ;
OemToAnsi("Base de Dados") SIZE 165, 163 ;
ON DBLCLICK (lOk := .T.,nPosLbx:=oLbx:nAt,oDlg:End()) of oDlg Pixel

oLbx:SetArray(aBancos)
oLbx:bLine := { || {aBancos[oLbx:nAt,1],aBancos[oLbx:nAt,2]}}

@ 177,10 SAY OemToAnsi("Pesquisar") SIZE 25, 7 OF oDlg PIXEL
@ 175,40 MSGET oPesq  VAR cPesq  SIZE 80,10 OF oDlg PIXEL PICTURE "@!" ;
VALID (nPosArq:=If(!Empty(cPesq),ASCAN(aBancos,{|z|AllTrim(cPesq)$z[1].OR.AllTrim(cPesq)$z[2]}),oLbx:nAt),If(nPosArq#0,oLbx:nAt:=nPosArq,MsgStop(OemtoAnsi("Pesquisa nao localizada"))),oLbx:Refresh(),If(nPosArq#0,nPosLbx:=nPosArq,),(nPosArq#0))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Botao Confirmar                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 190, 110 TYPE 1 ENABLE OF oDlg ;
ACTION (lOk := .T.,nPosLbx:=oLbx:nAt,oDlg:End())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Botao Cancelar                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 190, 144 TYPE 2 ENABLE OF oDlg ACTION ( lOk := .f.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED VALID (nOAt := oLbx:nAt,.T.)

If lOK
	aRet := { aBancos[nPosLbx,1] , aBancos[nPosLbx,2] , aBancos[nPosLbx,3] }
Else
	aRet := {""}
Endif

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AmbienteSelºAutor ³Rogerio Nagy        º Data ³  08/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Usuario Seleciona Banco de Auditoria e forma de consulta   º±±
±±º          ³a realizar                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AmbienteSel()

Local cRet
Local nAudit := 1
Local nTipo  := 1
Local lOk    := .F.
Local _lPar  := .F.  //vicente
//Local _lAlter := IIf( Upper(Alltrim(SubStr(cUsuario,7,15)))$"ADMINISTRADOR",.T.,.F. ) //vicente
Local _lAlter := .t.
Local oDlg
Local oRad1
Local oRad2

DEFINE MSDIALOG oDlg ;
FROM  010,5 TO 280,361 ;
TITLE OemToAnsi("Consulta a Audit Trail") PIXEL

@ 05,07 TO 45, 170 LABEL OemToAnsi("Banco de Auditoria") OF oDlg PIXEL
@ 55,07 TO 95, 170 LABEL OemToAnsi("Tipo de Consuta")    OF oDlg  PIXEL

//Vicente
@ 010, 050 Say "TopAlias: " SIZE 25,7 PIXEL OF oDlg
@ 020, 050 Say "TopBanco: " SIZE 25,7 PIXEL OF oDlg
@ 030, 050 Say "TopServer: " SIZE 25,7 PIXEL OF oDlg
@ 008, 080 MsGet _cTopAlias SIZE 45,5 PIXEL OF oDlg When _lAlter
@ 020, 080 MsGet _cTopDB    SIZE 45,5 PIXEL OF oDlg When _lAlter
@ 032, 080 MsGet _cTopSrv   SIZE 45,5 PIXEL OF oDlg When _lAlter

//fim vicente                         

//@ 015, 070 RADIO oRad1 VAR nAudit ITEMS "Produção","Histórico" PIXEL OF oDlg 3D SIZE 50,10  // Vicente Lacerenza 05/01/2006
@ 065, 070 RADIO oRad2 VAR nTipo  ITEMS "Filtro","Cadastro" PIXEL OF oDlg 3D SIZE 50,10

//³ Define Botao PARAMETROS
//DEFINE SBUTTON FROM 110, 76 TYPE 5 ENABLE OF oDlg ;
//ACTION (_lPar:= .T.,oDlg:End())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Botao Confirmar                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 110, 110 TYPE 1 ENABLE OF oDlg ;
ACTION (lOk := .T.,oDlg:End())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Botao Cancelar                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 110, 144 TYPE 2 ENABLE OF oDlg ACTION ( lOk := .f.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

If lOK
	cRet := Str(nAudit,1) + Str(nTipo,1)
Else                          

    //If _lPar
    //    Alert("Parametro")
    //Endif
    
	cRet := ""
Endif

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Detalhe   ºAutor  ³Rogerio             º Data ³  08/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Mostra os detalhes do registro posicionado                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Detalhe(cAlias,nRegistro,nOpc)

Local bGet
Local oDlgDetalhe
Local oScroll
Local oGetDelDet
Local cGetDelDet
Local cVar
Local cGet
Local cNomGet
Local cPict
Local cLogicoT	:= ""
Local cLogicoF	:= ""
Local nTop 		:= 16
Local nCampo	:= 1
Local aSay 		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Vetor para os campos no Scroll Box                 |
//| aSay[n,1] - Titulo        						   |
//| aSay[n,2] - Tipo            					   |
//| aSay[n,3] - Tamanho         					   |
//| aSay[n,4] - Decimal         					   |
//| aSay[n,5] - Conteudo/Variavel					   |
//| aSay[n,6] - Formato       					       |
//| aSay[n,7] - Combo       					       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))
While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cAlias
	If SX3->X3_CONTEXT <> "V"
		aAdd(aSay,{SX3->X3_TITULO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_CBOX})
	Endif
	SX3->(DbSkip())
Enddo

DEFINE MSDIALOG oDlgDetalhe TITLE "Detalhe da tabela " + cAlias FROM 002,0 TO 480,640 OF oDlgDetalhe PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da scroll box                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 013,001 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE 226,319 OF oDlgDetalhe BORDER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coloca informacao de registro deletado ou ativo                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bGet := &("{|| 'Status'}")
TSay():New(5,5,bGet,oScroll,,,.F.,.F.,.F.,.T.,,,79,15,.F.,.F.,.F.,.F.,.F.)
//TSay():New(5,5,bGet,oScroll,,,.F.,.F.,.F.,.T.,,,GetTextWidth(0,Trim("Status")),15,.F.,.F.,.F.,.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Status do Registro                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAlias)->(Deleted())
	cGetDelDet := "Excluido"
Else
	cGetDelDet := "Ativo"
Endif

cVar := "cGetDelDet"
cGet  := "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
oGetDelDet:=TGet():New(3,45,&cGet,oScroll,,7,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coloca todos os campos no Scroll Box                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCampo :=1 TO Len(aSay)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa as opcoes do Combo, caso existam                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(aSay[nCampo,7])
		bGet := &("{|| '"+aSay[nCampo,7]+"'}")
		TSay():New(nTop,65,bGet,oScroll,,,.F.,.F.,.F.,.T.,,,GetTextWidth(0,Trim(aSay[nCampo,7])),15,.F.,.F.,.F.,.F.,.F.)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Informa o nome do campo                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bGet := &("{|| '"+aSay[nCampo,1]+"'}")
	TSay():New(nTop,5,bGet,oScroll,,,.F.,.F.,.F.,.T.,,,GetTextWidth(0,Trim(aSay[nCampo,1])),15,.F.,.F.,.F.,.F.,.F.)
	
	cVar 	:= aSay[nCampo,5]
	cGet  	:= "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
	cPict 	:= AllTrim(aSay[nCampo,6])
	cNomGet := "oGet" + StrZero(nCampo,3)
	
	If aSay[nCampo,2] <> "M"
		If aSay[nCampo,2] == "L"
			If &cVar
				cVar		:= "cLogicoT"
				cGet  		:= "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
				cLogicoT 	:= "TRUE"
				Private &(cNomGet):=TGet():New(nTop-2,45,&cGet,oScroll,,7,cPict,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(cVar),,,,.T.)
			Else
				cVar		:= "cLogicoF"
				cGet  		:= "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
				cLogicoF 	:= "FALSE"
				Private &(cNomGet):=TGet():New(nTop-2,45,&cGet,oScroll,,7,cPict,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(cVar),,,,.T.)
			Endif
		Else
			Private &(cNomGet):=TGet():New(nTop-2,45,&cGet,oScroll,,7,cPict,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(cVar),,,,.T.)
		Endif
	Endif
	nTop+=11
Next nCampo

ACTIVATE MSDIALOG oDlgDetalhe CENTER ON INIT EnchoiceBar(oDlgDetalhe,{||oDlgDetalhe:End()},{||oDlgDetalhe:End()})

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AuditReg  ºAutor  ³Microsiga           º Data ³  08/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza pesquisa para um determinado registro selecionado  º±±
±±º          ³pelo usuario                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuditaReg(cAlias,nReg, xtipo)

Local cQuery 	:= ""
Local cQueryPer := ""

aTabelas := {}

nCon := TCLINK(AllTrim(cTopAlias),AllTrim(cTopServer))

If nCon < 0
	MsgStop("Erro connectando ao banco de auditoria : " + Str(nCon))
	Return .f.
endif

cQuery := " SELECT AT_NAME, AT_TIME, AT_DATE, AT_TABLE, AT_OP, AT_RECID, AT_FIELD, AT_CONTENT FROM AUDIT_TRAIL "  //vicente
cQuery += "  WHERE  (AT_TABLE = '" + cAlias + cEmpresa	+ "' ) "		// SC2010
cQuery += " AND AT_RECID = " + AllTrim(Str(nReg))
cQuery += " ORDER BY AT_DATE, AT_TIME "

CursorWait()

TCQUERY cQuery NEW ALIAS "TRB"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica qual o periodo de auditoria disponivel no banco em questao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQueryPer := "SELECT "
cQueryPer += " MAX(CASE WHEN R_E_C_N_O_ = MENOS THEN AT_DATE+AT_TIME ELSE '' END) MENOR, "
cQueryPer += " MAX(CASE WHEN R_E_C_N_O_ = MAIS THEN AT_DATE+AT_TIME ELSE '' END) MAIOR "

cQueryPer += " FROM AUDIT_TRAIL, ("
cQueryPer += " SELECT MIN(R_E_C_N_O_) MENOS, MAX(R_E_C_N_O_) MAIS "
cQueryPer += " FROM AUDIT_TRAIL"
cQueryPer += " WHERE D_E_L_E_T_ <> '*') A"

cQueryPer += " WHERE D_E_L_E_T_ <> '*'"
cQueryPer += " AND (R_E_C_N_O_ = MAIS OR R_E_C_N_O_ = MENOS)"

LjMsgRun("Verificando período de auditoria disponível no banco de dados selecionado",,,)
TCQUERY cQueryPer NEW ALIAS "TRE"

cDe  := Substr(TRE->MENOR,7,2) + "/" + Substr(TRE->MENOR,5,2) + "/" + Substr(TRE->MENOR,1,4) + " - " + Substr(TRE->MENOR,9,8)
cAte := Substr(TRE->MAIOR,7,2) + "/" + Substr(TRE->MAIOR,5,2) + "/" + Substr(TRE->MAIOR,1,4) + " - " + Substr(TRE->MAIOR,9,8)
TRE->(DbCloseArea())

nVolta := TCSetConn(AdvConnection())

DbSelectArea("TRB")
cArqTemp := CriaTrab('', .F.)

Copy To &cArqTemp

TRB->(DbCloseArea())

DbUseArea(.T.,,cArqTemp,'TRB',.F.)

CursorArrow()

TRB->(DbGoTop())
If TRB->(Eof())
	MsgStop("Não existem informações deste registro no banco de dados de auditoria selecionado"+"Período auditado: " + cDe + " a " + cAte)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha o arquivo temporario                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
	FErase(cArqTemp+GetDBExtension())
	
	TCUnLink(nCon)   // Fecha conexao 'extra'
	
	Return .t.
Endif

If xTipo == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aArray com a Tabela que devera montar o Folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aTabelas,cAlias)
	
	ShowAudit(aTabelas,cArqTemp)
Else 

	PrintAudit(aTabelas,cArqTemp)
	
EndIf         

TCUnLink(nCon)   // Fecha conexao 'extra'

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AuditaFil ºAutor  ³Rogerio             º Data ³  08/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza pesquisa para um determinado filtro selecionado    º±±
±±º          ³pelo usuario                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuditaFil()

Local cQuery		:= ""
Local cQueryPer		:= ""
Local cTabela		:= ""
Local nTabelas		:= 0
Local cStrTabela	:= ""
Local nConta		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Usuario de                                               ³
//³ mv_par02 - Usuario ate                                              ³
//³ mv_par03 - Data de                                                  ³
//³ mv_par04 - Data ate                                                 ³
//³ mv_par05 - Hora de                                                  ³
//³ mv_par06 - Hora ate                                                 ³
//³ mv_par07 - Tabela                                                   ³
//³ mv_par08 - Registro de                                              ³
//³ mv_par09 - Registro ate                                             ³
//³ mv_par10 - Campo Alterado                                           ³
//³ mv_par11 - Conteudo alterado                                        ³
//³ mv_par12 - Tipo de log                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LjMsgRun("Conectando em " + cTopAlias + " " + cTopServer,,,)

nCon := TCLINK(AllTrim(cTopAlias),AllTrim(cTopServer))

If nCon < 0
	MsgStop("Erro connectando ao banco de auditoria : " + Str(nCon) + "-" + AllTrim(cTopAlias) + "-" + AllTrim(cTopServer))
	Return .f.
endif

If Empty(mv_par07)  // Nao informou a tabela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica quais tabelas irao retornar          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT DISTINCT AT_TABLE FROM AUDIT_TRAIL "
	cQuery += " WHERE AT_NAME >= '" + allTrim(mv_par01) + "'"
	cQuery += "   AND AT_NAME <= '" + allTrim(mv_par02) + "'"
	
	cQuery += " AND AT_DATE >= '" + DTOS(mv_par03) + "'"   // 20041003
	cQuery += " AND AT_DATE <= '" + DTOS(mv_par04) + "'"
	
	// Vicente Lacerenza 05/01/2006
	cQuery += " AND AT_TIME >= '" + mv_par05 + "'"		// 08:10:30
	cQuery += " AND AT_TIME <= '" + mv_par06 + "'"		// 08:10:30
	
	cQuery += " AND AT_RECID >= " + AllTrim(Str(mv_par08))
	cQuery += " AND AT_RECID <= " + AllTrim(Str(mv_par09))
	
	If ! Empty(mv_par10)
		cQuery += " AND AT_FIELD >=  '" + Alltrim(mv_par10) + "'"
		cQuery += " AND AT_CONTENT = '" + AllTrim(mv_par11) + "'"
	Endif
	
	Do Case
		Case mv_par12 == 1		// Inclusao
			cQuery += " AND AT_OP = 'I' "
		Case mv_par12 == 2		// Alteracao
			cQuery += " AND AT_OP = 'U' "
		Case mv_par12 == 3		// Delecao
			cQuery += " AND AT_OP = 'D' "
		Case mv_par12 == 4		// Ambos
			cQuery += " AND (AT_OP = 'I' OR AT_OP = 'U' OR AT_OP = 'D') "
	EndCase
	cQuery += " ORDER BY AT_TABLE "
	
	LjMsgRun("Verificando tabelas auditadas conforme a seleção efetuada",,,)
	
	CursorWait()
	
	TCQUERY cQuery NEW ALIAS "TRC"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa Filtro do SX2 para montar array com todas as tabelas          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX2")
	Set Filter To
	DbSelectArea("TRC")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aArray com as Tabelas que deverao montar o Folder ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRC->(DbGoTop())
	While ! TRC->(Eof())
		If Left(TRC->AT_TABLE,4) == 'dbo.'
			If Substr(TRC->AT_TABLE,8,3) <> cEmpresa	// Nao eh a empresa corrente
				TRC->(DbSkip())
				Loop
			Endif
			cTabela := Substr(TRC->AT_TABLE,5,3)
		Else
			If Substr(TRC->AT_TABLE,4,3) <> cEmpresa	// Nao eh a empresa corrente
				TRC->(DbSkip())
				Loop
			Endif
			cTabela := Left(TRC->AT_TABLE,3)
		Endif
		If 	SX2->(DbSeek(cTabela))  // Localiza se eh uma tabela do sistema ou do SigaDw
			If aScan(aTabelas,cTabela) == 0
				Aadd(aTabelas,cTabela)
				cStrTabela += " '" + cTabela + cEmpresa + "','dbo." + cTabela + cEmpresa + "',"
			Endif
		Endif
		TRC->(DbSkip())
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha o arquivo temporario                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRC")
	TRC->(DbCloseArea())
	
	CursorArrow()
	
	If Len(aTabelas) == 0
		MsgStop("Não existem dados com esta seleção")
		TCUnLink(nCon)   // Fecha conexao 'extra'
		Return .t.
	Endif
	
	// Caso existam mais de 10 tabelas, solicita que usuario escolha somente 10
	If Len(aTabelas) > 10
		
		aTabelas	:= SeleTable(aTabelas)
		
		cStrTabela := ""
		
		For nConta := 1 To Len(aTabelas)
			cStrTabela += " '" + aTabelas[nConta] + cEmpresa + "','dbo." + aTabelas[nConta] + cEmpresa + "',"
		Next nConta
		
	Endif
	
Else
	aTabelas := {}
	Aadd(aTabelas,mv_par07)
Endif

If Len(aTabelas) == 0
	TCUnLink(nCon)   // Fecha conexao 'extra'
	Return .t.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Query com todas as ocorrencias          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := " SELECT AT_NAME, AT_DATE, AT_TIME, AT_TABLE, AT_OP, AT_RECID , AT_FIELD, AT_CONTENT FROM AUDIT_TRAIL "+CHR(13)
//cQuery += " WHERE AT_NAME >= '" + allTrim(mv_par01) + "'"
//cQuery += "   AND AT_NAME <= '" + allTrim(mv_par02) + "'"
cQuery += " WHERE AT_NAME like '%" + allTrim(mv_par01) + "%'"+CHR(13)

//cQuery += " AND AT_DATE >= '" + DTOS(mv_par03) + "'"   // 20041003
//cQuery += " AND AT_DATE <= '" + DTOS(mv_par04) + "'"
cQuery += " AND AT_DATE BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "'"+CHR(13)  

	cQuery += " AND AT_TIME >= '" + mv_par05 + "'"		// 08:10:30
	cQuery += " AND AT_TIME <= '" + mv_par06 + "'"		// 08:10:30
	
	cQuery += " AND AT_RECID >= " + AllTrim(Str(mv_par08))
	cQuery += " AND AT_RECID <= " + AllTrim(Str(mv_par09))

//If ! Empty(mv_par07)
	//cQuery 	 += " AND AT_TABLE = '" + mv_par07 + cEmpresa	+ "' )"	      	// SC2010
	//cQuery 	 += " AND SUBSTRING(AT_TABLE,1,6) = '" + mv_par07 + cEmpresa	+ "' "	      	// SC2010
//Else
//	cStrTabela := Substr(cStrTabela,1, Len(cStrTabela)-1)	// Retira ultima virgula do IN
//	cQuery 	 += " AND   SUBSTRING(AT_TABLE,1,6) IN(" + cStrTabela + ")"    // like '%dbo.%'"  // Vicente Lacerenza 05/01/2006
//Endif

If ! Empty(mv_par10)
	cQuery += " AND AT_FIELD >=  '" + Alltrim(mv_par10) + "'"
	cQuery += " AND AT_CONTENT = '" + AllTrim(mv_par11) + "'"
Endif

Do Case  
	Case mv_par12 == 1		// Inclusao
		cQuery += " AND AT_OP = 'I' "
	Case mv_par12 == 2		// Alteracao
		cQuery += " AND AT_OP = 'U' "
	Case mv_par12 == 3		// Delecao
		cQuery += " AND AT_OP = 'D' "
	Case mv_par12 == 4		// Ambos
		//cQuery += " AND (AT_OP = 'I' OR AT_OP = 'U' OR AT_OP = 'D' ) "                                 
EndCase
 
cQuery += " ORDER BY AT_DATE, AT_TIME "

LjMsgRun("Verificando registros de auditoria",,,)

CursorWait()

TCQUERY cQuery NEW ALIAS "TRB"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica qual o periodo de auditoria disponivel no banco em questao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQueryPer := "SELECT "
cQueryPer += " MAX(CASE WHEN R_E_C_N_O_ = MENOS THEN AT_DATE+AT_TIME ELSE '' END) MENOR, "
cQueryPer += " MAX(CASE WHEN R_E_C_N_O_ = MAIS THEN AT_DATE+AT_TIME ELSE '' END) MAIOR "

cQueryPer += " FROM AUDIT_TRAIL, ("
cQueryPer += " SELECT MIN(R_E_C_N_O_) MENOS, MAX(R_E_C_N_O_) MAIS "
cQueryPer += " FROM AUDIT_TRAIL"
cQueryPer += " WHERE D_E_L_E_T_ <> '*') A"

cQueryPer += " WHERE D_E_L_E_T_ <> '*'"
cQueryPer += " AND (R_E_C_N_O_ = MAIS OR R_E_C_N_O_ = MENOS)"

LjMsgRun("Verificando período de auditoria disponível no banco de dados selecionado",,,)

TCQUERY cQueryPer NEW ALIAS "TRE"

cDe  := Substr(TRE->MENOR,7,2) + "/" + Substr(TRE->MENOR,5,2) + "/" + Substr(TRE->MENOR,1,4) + " - " + Substr(TRE->MENOR,9,8)
cAte := Substr(TRE->MAIOR,7,2) + "/" + Substr(TRE->MAIOR,5,2) + "/" + Substr(TRE->MAIOR,1,4) + " - " + Substr(TRE->MAIOR,9,8)
TRE->(DbCloseArea())

nVolta := TCSetConn(AdvConnection())

DbSelectArea("TRB")
TRB->(DbGoTop())
If TRB->(Eof())
	CursorArrow()
	
	MsgStop("Não existem dados com esta seleção")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha o arquivo temporario                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
	
	TCUnLink(nCon)   // Fecha conexao 'extra'
	
	Return .t.
Endif

aStru := {}
AADD(aStru,{"AT_NAME" ,"C",13,0})
AADD(aStru,{"AT_DATE" ,"C", 8,0})
AADD(aStru,{"AT_TIME" ,"C", 8,0})
AADD(aStru,{"AT_TABLE","C",10,0})
AADD(aStru,{"AT_RECID","C",10,0})
AADD(aStru,{"AT_OP"   ,"C", 1,0})
AADD(aStru,{"AT_FIELD","C",10,0})
AADD(aStru,{"AT_CONTENT","C",255,0})

cArqTemp := CriaTrab(aStru, .f.)

CursorWait()

MsgRun( "Analisando resultado dos dados auditados","", {|| ProcesTRB() } )

TRB->(DbCloseArea())

DbUseArea(.T.,,cArqTemp,'TRB',.F.)

CursorArrow()

ShowAudit(aTabelas,cArqTemp)

TCUnLink(nCon)   // Fecha conexao 'extra'

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONSAUDIT ºAutor  ³Microsiga           º Data ³  01/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcesTRB()

Copy To &cArqTemp

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ShowAudit ºAutor  ³Rogerio Nagy        º Data ³  08/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra os registros selecionados no audit com seus respec- º±±
±±º          ³tivos detalhes                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ShowAudit(aTabelas,cArqTemp)

LOCAL nTop		:= 16
LOCAL nWidth	:= 0
Local nFolder	:= 0
Local nCampo 	:= 0

LOCAL cGet		:= ""
LOCAL cPict		:= ""
LOCAL cVar		:= ""
//Local cArquivo
Local cTitulo 	:= "Consulta Auditoria"

Local aStru		:= {}
Local aCampos	:= {}
Local aTitles	:= {}
Local aPages	:= {}
Local oDlg
Local  aSay 	:= {}
Local aButtons  := {}

Private _oMark

CursorWait()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor para os campos nos Scrool Boxs               ³
//| aSay[nFolder,nConta,1] - Titulo				       |
//| aSay[nFolder,nConta,2] - Tipo                      |
//| aSay[nFolder,nConta,3] - Tamanho                   |
//| aSay[nFolder,nConta,4] - Decimal                   |
//| aSay[nFolder,nConta,5] - Conteudo/Variavel         |
//| aSay[nFolder,nConta,6] - Formato                   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SX3->(DbSetOrder(1))

aTabelas := aSort(aTabelas)

For nFolder := 1 To Len(aTabelas)
	
	aTmp := {}
	
	SX3->(DbSeek(aTabelas[nFolder]))
	While !SX3->(Eof()) .and. SX3->X3_ARQUIVO == aTabelas[nFolder]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera campos virtuais (tambem os memos)                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SX3->X3_CONTEXT <> "V"  .and. SX3->X3_TIPO <> "M"    // Memo
			aAdd(aTmp,{AllTrim(SX3->X3_TITULO) + " (" + AllTrim(SX3->X3_CAMPO) + ")",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_ARQUIVO+"->"+SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_CBOX})
		Endif
		SX3->(DbSkip())
	Enddo
	
	aAdd(aSay,aTmp)
	
Next nFolder

TRB->(DbGoTop())

LjMsgRun("Criando janela com informações selecionadas",,,)

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,0 TO 600,800 OF oDlg PIXEL

_oMark 				:= TcBrowse():New(13,01,398,116,,,{20,10,10,10,10,10,20,200},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,)
_oMark:bChange 		:= {|| (Atual(aSay),.t.) }
_oMark:bLDblClick	:= { || DblClickBrow(_oMark) }
_oMark:lColDrag 	:= .T.
_oMark:lLineDrag 	:= .T.

_oMark:AddColumn(TCColumn():New("Usuário"           ,{|| TRB->AT_NAME    },,,,"LEFT",50,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Data"              ,{|| TRB->AT_DATE    },,,,"LEFT",28,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Hora"              ,{|| TRB->AT_TIME    },,,,"LEFT",27,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Tabela"            ,{|| Iif(Left(TRB->AT_TABLE,4) == 'dbo.',Substr(TRB->AT_TABLE,5,3),Left(TRB->AT_TABLE,3)) },,,,"LEFT",27,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Registro"          ,{|| TRB->AT_RECID   },,,,"RIGHT",33,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Oper."             ,{|| TRB->AT_OP      },,,,"CENTER",18,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Campo"             ,{|| TRB->AT_FIELD   },,,,"LEFT",50,.F.,.F.,,,,.F.,))
_oMark:AddColumn(TCColumn():New("Conteudo Anterior" ,{|| TRB->AT_CONTENT },,,,"LEFT",100,.F.,.F.,,,,.F.,))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa Filtro do SX2 para montar array com todas as tabelas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX2")
Set Filter To
DbSelectArea("TRB")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Folder com Tabelas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFolder := 1 To Len(aTabelas)
	SX2->(DbSeek(aTabelas[nFolder]))  // Inclusao do nome da tabela na folder para ganho de performance
	AADD(aTitles,aTabelas[nFolder]+"-"+Capital(AllTrim(SX2->X2_NOME)))
	AADD(aPages,aTabelas[nFolder])
Next nFolder

PRIVATE oFolder:= TFolder():New( 130, 01, aTitles, aPages, oDlg,,,,.T.,.F.,398,170, )
//oFolder:bChange := {|| AtualizSX2(oFolder:nOption) }

For nFolder := 1 to Len(oFolder:aDialogs)
	oFolder:aDialogs[nFolder]:oFont := oDlg:oFont
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria um Scroll Box para cada Folder Criada     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nFolder := 1 To Len(aTabelas)
	
	nTop := 16
	
	cScroll := "oScroll" + StrZero(nFolder,3)
	@ 002,002 SCROLLBOX &(cScroll) HORIZONTAL VERTICAL SIZE 152,392 OF oFolder:aDialogs[nFolder] BORDER
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um campo com informacao de registro Ativo ou Deletado em cada Folder / Scroll ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bGet := &("{|| 'Status do registro'}")
	TSay():New(5,5,bGet,&(cScroll),,,.F.,.F.,.F.,.T.,,,79,15,.F.,.F.,.F.,.F.,.F.)
	
	cGetDel := "cGet" + StrZero(nFolder,3) + "000"
	&(cGetDel) := "Ativo"
	cVar := "cGet" + StrZero(nFolder,3) + "000"
	cGet  := "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
	cNomGet := "oGet" + StrZero(nFolder,3)	+ "000"
	Private &(cNomGet):=TGet():New(3,85,&cGet,&(cScroll),,7,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria um campo com informacao de numero do registro                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	bGet := &("{|| 'Registro No'}")
	TSay():New(5,160,bGet,&(cScroll),,,.F.,.F.,.F.,.T.,,,40,15,.F.,.F.,.F.,.F.,.F.)
	
	cVar := aTabelas[nFolder] + "->(Recno())" // Recno()
	cGet  := "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
	cNomGet := "oGet" + StrZero(nFolder,3)	+ "REG"
	Private &(cNomGet):=TGet():New(3,195,&cGet,&(cScroll),,7,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,,,,,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria os campos da tabela em questao no Folder / Scroll Box ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nCampo := 1 TO Len(aSay[nFolder])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Informa as opcoes do Combo, caso existam                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Empty(aSay[nFolder,nCampo,7])
			bGet := &("{|| '"+aSay[nFolder,nCampo,7]+"'}")
			TSay():New(nTop,105,bGet,&(cScroll),,,.F.,.F.,.F.,.T.,,,GetTextWidth(0,Trim(aSay[nFolder,nCampo,7])),15,.F.,.F.,.F.,.F.,.F.)
		Endif
		
		bGet := &("{|| '"+aSay[nFolder,nCampo,1]+"'}")
		cVar := aSay[nFolder,nCampo,5]
		cGet  := "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
		cPict := AllTrim(aSay[nFolder,nCampo,6])
		TSay():New(nTop,5,bGet,&(cScroll),,,.F.,.F.,.F.,.T.,,,79,15,.F.,.F.,.F.,.F.,.F.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconsidera campos Memo                                                            ³
		//³ Como devem ser   virtuais, ja devem ser desconsiderados na criacao do Array, acima  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNomGet := "oGet" + StrZero(nFolder,3) + StrZero(nCampo,3)
		If aSay[nFolder,nCampo,2] <> "M"    // Memo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apresenta campos Logicos como True / False (texto)         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aSay[nFolder,nCampo,2] == "L"       // Logico
				If &cVar
					cVar	:= "cLogicoT"
					cGet  	:= "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
					cLogicoT := "TRUE"
					Private &(cNomGet):=TGet():New(nTop-2,85,&cGet,&(cScroll),,7,cPict,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(cVar),,,,.T.)
				Else
					cVar	:= "cLogicoF"
					cGet  	:= "{|u| iif(PCount()>0,"+cVar+":=u,("+cVar+"))}"
					cLogicoF := "FALSE"
					Private &(cNomGet):=TGet():New(nTop-2,85,&cGet,&(cScroll),,7,cPict,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(cVar),,,,.T.)
				Endif
			Else
				Private &(cNomGet):=TGet():New(nTop-2,85,&cGet,&(cScroll),,7,cPict,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,(cVar),,,,.T.)
			Endif
		Endif
		nTop+=11
	Next nCampo
Next nFolder

Aadd(aButtons,{"NOTE"     , {|| Periodo() }, OemToAnsi("Periodo Auditado"), OemToAnsi("Periodo Auditado")})
Aadd(aButtons,{"ANALITICO", {|| ConAnter() }, OemToAnsi("Conteúdo Anterior"), OemToAnsi("Conteúdo Anterior")})

CursorArrow()

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna Filtro do SX2                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX2")
Set Filter To X2_CHAVE $ cFOpened

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo temporario                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB")
TRB->(DbCloseArea())
FErase(cArqTemp+GetDBExtension())

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Rogerio             º Data ³  08/19/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ajusta Jogo de Perguntas                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ALTERACAO:
Ajustes para versão 8.11 - Vicente Lacerenza, 04/01/2006 -


*/
Static Function AjustaSx1()

Local cAlias := Alias()
Local aRegistros:={}
Local j:=0
Local i:=0
Local cPerg := "CFG999____"

Aadd(aRegistros,{cPerg,"01","Usuário de"       ,Space(20),Space(20),"mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"02","Usuário até"      ,Space(20),Space(20),"mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"03","Data de"          ,Space(20),Space(20),"mv_ch3","D", 8,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"04","Data até"         ,Space(20),Space(20),"mv_ch4","D", 8,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"05","Hora de"          ,Space(20),Space(20),"mv_ch5","C", 8,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"06","Hora até"         ,Space(20),Space(20),"mv_ch6","C", 8,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"07","Tabela"           ,Space(20),Space(20),"mv_ch7","C", 3,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"08","Registro de"      ,Space(20),Space(20),"mv_ch8","N", 9,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"09","Registro até"     ,Space(20),Space(20),"mv_ch9","N", 9,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"10","Campo Alterado"   ,Space(20),Space(20),"mv_chA","C", 10,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"11","Conteúdo Alterado",Space(20),Space(20),"mv_chB","C", 60,0,0,"G","","mv_par11",""       ,"","","","",""         ,"","","","",""        ,"","","","",""     ,"","","","","","","","","","","","","",""})
Aadd(aRegistros,{cPerg,"12","Tipo de log"      ,Space(20),Space(20),"mv_chC","N", 1,0,0,"C","","mv_par12","Inclusão","","","","","Alteração","","","","","Exclusão","","","","","Todos","","","","","","","","","","","","","",""})

dbSelectArea("SX1")
For i:=1 to Len(aRegistros)
	If !dbSeek(aRegistros[i,1]+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegistros[i,j])  //comentado por rodrigo em 10127
		Next
		MsUnlock()
	EndIf
Next I
dbSelectArea(cAlias)

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Atual     ºAutor  ³Microsiga           º Data ³  09/01/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza dados das 'enchoices' manualmente apos navegacao  º±±
±±º          ³da IWBrowse                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function Atual(aSay)

Local cTabela 	:= Iif(Left(TRB->AT_TABLE,4) == 'dbo.',Substr(TRB->AT_TABLE,5,3),Left(TRB->AT_TABLE,3))
Local lAvisa	:= .f.
Local lRefresh	:= .f.
Local nFolder	:= Ascan(aTabelas,cTabela)
Local cFolder	:= StrZero(nFolder,3)
Local cGetDele  := ""
Local cNomeGet	:= ""
Local cNomeGetReg := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente reposiciona/repinta se estiver em outro registro da tabela  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF !empty(cTabela)
//If (cTabela)->(RecNo()) <> Val(TRB->AT_RECID)
//	(cTabela)->(DbGoTo(Val(TRB->AT_RECID)))
If (cTabela)->(RecNo()) <> TRB->AT_RECID  // Vicente Lacerenza 05/01/2006
	(cTabela)->(DbGoTo(TRB->AT_RECID))
	lRefresh := .t.
Else
	If (cTabela)->(Eof())
		//MsgInfo("Registro " + TRB->AT_RECID + " da tabela " + cTabela + " não localizado na base de dados !")
		MsgInfo("Registro " + strzero(TRB->AT_RECID,8) + " da tabela " + cTabela + " não localizado na base de dados !") //vicente
	Endif
Endif

cGetDel := "cGet" + cFolder + "000"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Folder, se nao estiver na mesma tabela                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oFolder:nOption <> nFolder
	oFolder:nOption := nFolder
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o Foco para o Browse                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_oMark:SetFocus()
	
Endif

If ! lRefresh
	Return .t.
Endif

If (cTabela)->(Eof())
	lAvisa 		:= .t.
	&(cGetDel) 	:= ""
Else
	If (cTabela)->(Deleted())
		&(cGetDel) := "Excluido"
	Else
		&(cGetDel) := "Ativo"
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Status do Registro                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeGetDel := "oGet" + cFolder + "000"
&(cNomeGetDel):Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Numero Registro                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeGetReg := "oGet" + cFolder + "REG"
&(cNomeGetReg):Refresh()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Todos os Campos da tabela            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For n:=1 TO Len(aSay[nFolder])
	cNomeGet := "oGet" + cFolder + StrZero(n,3)
	&(cNomeGet):Refresh()
Next n

If lAvisa
	//MsgInfo("Registro " + AllTrim(TRB->AT_RECID) + " da tabela " + cTabela + " não localizado na base de dados !")
	MsgInfo("Registro " + AllTrim(str(TRB->AT_RECID)) + " da tabela " + cTabela + " não localizado na base de dados !") //vicente
Endif

ENDIF

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DblClickBrºAutor  ³ROgerio Nagy        º Data ³  09/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe o conteudo completo do campo Conteudo Anterior       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DblClickBrow(_oMark)
If ! Empty(TRB->AT_CONTENT)
	ApMsgInfo(AllTrim(TRB->AT_CONTENT),"Detalhe do conteúdo anterior")
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DblClickBrºAutor  ³ROgerio Nagy        º Data ³  09/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe o conteudo completo do campo Conteudo Anterior       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConAnter()
If ! Empty(TRB->AT_CONTENT)
	ApMsgInfo(AllTrim(TRB->AT_CONTENT),"Detalhe do conteúdo anterior")
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONSAUDIT ºAutor  ³Microsiga           º Data ³  10/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SeleTable(aTabelas)

Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )

Local aSalvAmb	:= GetArea()
Local cVar		:= Nil
Local oDlg		:= Nil
Local aXy		:= {}
Local oChk		:= Nil

Private cMtResp	:= ''
Private cNmResp	:= ''
Private cDepIni	:= ''
Private cDesIni	:= ''
Private cDepFim	:= ''
Private cDesFim	:= ''
Private cTitulo	:= "Transferencia de Responsaveis"
Private lMark	:= .F.
Private codDest	:= CriaVar("QAA_MAT") 	//pega o tamanho do campo de acordo com o SX3. Matricula do Destinatario
Private cNomeD	:= ""  					//nome do destinatario
Private lChk	:= .F.
Private Descri	:= ""
Private oLbx	:= Nil
Private aVetor	:= {}
Private aRetorno := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Vetor                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Vetor()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta tela para usuario visualizar consulta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG oDlg TITLE "Favor selecionar no máximo 10 tabelas para auditar" FROM 65,00 TO 630,552 PIXEL

@ 16,06 TO 105,271 LABEL "Dados do Filtro" OF oDlg PIXEL

@ 16,06 LISTBOX oLbx VAR cVar FIELDS HEADER " ",;
"Tabela",;
"Descricao";
SIZE 265,245 OF oDlg PIXEL ;
ON dblClick( Inverter(oLbx:nAt),oLbx:Refresh(.F.) )

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
aVetor[oLbx:nAt,2],;
aVetor[oLbx:nAt,3] }}

@ 273,010 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca Todos" SIZE 70,007 PIXEL OF oDlg;
ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| Iif(Transfere(),oDlg:End(),.t.) },{||oDlg:End()}) CENTER

RestArea( aSalvAmb )
DeleteObject(oOk)
DeleteObject(oNo)

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Inverter  ºAutor  ³Microsiga           º Data ³  01/24/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Inverter(nPos)
aVetor[nPos][1] := !aVetor[nPos][1]
oLbx:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Marca     ºAutor  ³Microsiga           º Data ³  01/24/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Marca(lMarca)

Local i := 0

For i := 1 To Len(aVetor)
	aVetor[i][1] := lMarca
Next i
oLbx:Refresh()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Transfere ºAutor  ³Cayo Souza          º Data ³  01/24/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a alteracao de responsavel                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Transfere()
Local nConta := 0
Local nMarca := 0

aRetorno := {}

For nConta := 1 to len(aVetor)
	if aVetor[nConta,1]
		nMarca ++
		Aadd(aRetorno,aVetor[nConta,2])
	EndIf
next nConta

If nMarca > 10
	MsgInfo("Favor selecionar somente 10 tabelas !")
	aRetorno := {}  // Caso saia pelo X (cancelar) nao processa nenhuma tabela
	Return .f.
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Vetor     ºAutor  ³Cayo Souza          º Data ³  01/24/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta vetor com o codigo do instrumento, revisao, departa-  º±±
±±º          ³mento e revisao invertida.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Vetor()

Local cDesc		:= ""
Local nConta 	:= 0
Private cQuery
Private cOrder

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa Filtro do SX2 para montar array com todas as tabelas          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX2")
Set Filter To
SX2->(DbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array com os dados do SX2                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nConta := 1 To Len(aTabelas)
	SX2->(DbSeek(aTabelas[nConta]))  // Inclusao do nome da tabela na folder para ganho de performance
	AADD(aVetor,{ lMark, SX2->X2_CHAVE, AllTrim( X2Nome() ) })
Next nConta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna Filtro do SX2                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX2")
Set Filter To X2_CHAVE $ cFOpened

Return .t.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Periodo   ºAutor  ³Rogerio             º Data ³  01/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibe o periodo auditado                                    º±±
±±º          ³Botao disponivel na Enchoice                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Periodo()

MsgInfo("Base de auditoria atual possui informações de " + cDe + " até " + cAte )

Return .t.

          
///////////////////////////////////////////////////////////////////////////////////
//+-----------------------------------------------------------------------------+//
//| PROGRAMA  | BuscaEmp.prw  | AUTOR | Vicente Lacerenza   | DATA | 10/01/2006 |//
//+-----------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - BuscaEdit()                                            |//
//|           | Busca todas as empresas do sigamat.emp - SM0  					|//
//+-----------------------------------------------------------------------------+//
//| MANUTENCAO DESDE SUA CRIACAO                                                |//
//+-----------------------------------------------------------------------------+//
//| DATA     | AUTOR                | DESCRICAO                                 |//
//+-----------------------------------------------------------------------------+//
//|          |                      |                                           |//
//+-----------------------------------------------------------------------------+//
///////////////////////////////////////////////////////////////////////////////////

Static Function BuscaEmp()

Local aSalvAmb := {}
Local oDlg     := Nil
Local cTitulo  := "Cadastro de Empresas"

Private oLbx     := Nil 
Private aVetor   := {}

dbSelectArea("SM0")
aSalvAmb := GetArea()
dbSetOrder(1)
dbSeek(xFilial("SM0"))

//+-------------------------------------+
//| Carrega o vetor conforme a condicao |
//+-------------------------------------+
//While !Eof() .And. A6_FILIAL == xFilial("SA6")	
//   aAdd( aVetor, { A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME, A6_NREDUZ, A6_BAIRRO, A6_MUN, A6_FILIAL } )
//	dbSkip()
//End

While !Eof() 
   aAdd( aVetor, { M0_CODIGO, M0_CODFIL, M0_FILIAL, M0_NOME, M0_NOMCOM, M0_ENDCOB, M0_CIDCOB, M0_ESTCOB } )
	dbSkip()
End

If Len( aVetor ) == 0
   Aviso( cTitulo, "Nao Existe Empresa Cadastrada no Sistema ... ", {"Ok"} )
   Return
Endif

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 240,500 PIXEL
@ 010,010 LISTBOX oLbx FIELDS HEADER ;
   "Codigo", "Cod.Fil", "Filial", "Nome", "Razao Social", "Endereço", "Cidade/Estado" ;
   SIZE 230,095 OF oDlg PIXEL ON DBLCLICK( u_JP_EdList(oLbx:nAt))
	                                      
oLbx:SetArray( aVetor )
oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
                   aVetor[oLbx:nAt,2],;
                   aVetor[oLbx:nAt,3],;
                   aVetor[oLbx:nAt,4],;
                   aVetor[oLbx:nAt,5],;
                   aVetor[oLbx:nAt,6],;
                   aVetor[oLbx:nAt,7]}}
@ 110,10 SAY "Empresas " SIZE 60,007 PIXEL OF oDlg
	                    
DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

RestArea( aSalvAmb )
Return .T.

User Function jp_EdList( nPos )
Local cKey := ""
Private cCadastro := "Empresas Microsiga"
Private lRefresh := .T.
Private Inclui := .F.
Private Altera := .T.
Private aRotina := {}

aAdd( aRotina, {"","",0,1} )
aAdd( aRotina, {"","",0,2} )
aAdd( aRotina, {"","",0,3} )
aAdd( aRotina, {"","",0,4} )
aAdd( aRotina, {"","",0,5} )

//cKey := aVetor[nPos,8]+aVetor[nPos,1]+aVetor[nPos,2]+aVetor[nPos,3]
cKey := aVetor[nPos,1]+aVetor[nPos,2]

dbSelectArea("SM0")
dbSetOrder(1)
dbSeek(cKey)

Alert(SM0->M0_CODIGO)
/*
AxAltera("SA6",RecNo(),4)

aVetor[nPos][1] := SA6->A6_COD
aVetor[nPos][2] := SA6->A6_AGENCIA
aVetor[nPos][3] := SA6->A6_NUMCON
aVetor[nPos][4] := SA6->A6_NOME
aVetor[nPos][5] := SA6->A6_NREDUZ
aVetor[nPos][6] := SA6->A6_BAIRRO
aVetor[nPos][7] := SA6->A6_MUN
*/

oLbx:Refresh()

Return .T.


Static Function PrintAudit()

Local Tamanho
Local Titulo   := 'Audit Trail'
Local cDesc1   := 'Este programa emite um relatorio de auditoria de registros'
Local cDesc2   := 'do banco de dados'
Local cDesc3   := "Ele é emitido de acordo com os parâmetros informados."
Local cString  := 'TRB'
Local aOrd     := {}
Local wnRel    := 'CONSAUDIT'

Private aReturn  := {'Zebrado',1,'Administracao', 2, 2, 1, '',1 }
Private nLastKey := 0
Private cPerg    := 'FMAUDT'

ValidPerg()
Pergunte(cPerg,.F.)

Tamanho := 'M'

wnRel:=SetPrint(cString,wnRel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

If nLastKey == 27
	dbClearFilter()
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
	FErase(cArqTemp+GetDBExtension())
	Return Nil
Endif

fErase(__RelDir + wnrel + '.##R')
SetDefault(aReturn,cString)

If nLastKey == 27
	dbClearFilter()
	DbSelectArea("TRB")
	TRB->(DbCloseArea())
	FErase(cArqTemp+GetDBExtension())
	Return Nil
Endif

RptStatus({|lEnd| C280Imp(aOrd,@lEnd,wnRel,cString,Titulo,Tamanho)},Titulo)

DbSelectArea("TRB")
TRB->(DbCloseArea())
FErase(cArqTemp+GetDBExtension())

Return Nil

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function C280Imp(aOrd,lEnd,wnRel,cString,Titulo,Tamanho)
///////////////////////////////////////////////////////////////

Local cRodaTxt    := ''
Local ntipo       := 0
Private Li        := 80
Private m_pag     := 1
Private lContinua := .T.
cabec1 := 'Tabela: ' + alltrim(TRB->AT_TABLE) + '  Registro: ' + alltrim(str(TRB->AT_RECID))
cabec2 := 'Usuario         Data       Hora      OP Campo      Conteudo Anterior'
//         123456789012345 11/11/1111 123456789 1  1234567890 space(80)
DbSelectArea('TRB')
count to _nLastRec
SetRegua(_nLastRec)

DbGoTop()

Do While !eof() .and. !lEnd
	
	If lEnd
		@ prow()+1, 001 PSAY 'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	
	IncRegua()
	
	If Li > 58
		Cabec(Titulo,Cabec1,Cabec2,wnRel,Tamanho,nTipo)
	EndIf
	
	_cLin := left(TRB->AT_NAME,15) + ' ' + dtoc(stod(TRB->AT_DATE)) + ' ' + TRB->AT_TIME + ' ' + TRB->AT_OP + '  '
	_cLin += left(TRB->AT_FIELD,10) + ' ' + left(TRB->AT_CONTENT,80)
	@ ++li, 000 psay _cLin
	If len(alltrim(TRB->AT_CONTENT)) > 80
		@ ++li, 000 psay substr(TRB->AT_CONTENT,81,133)
		If len(alltrim(TRB->AT_CONTENT)) > 223
			@ ++li, 000 psay substr(TRB->AT_CONTENT,224)
		EndIf
	EndIf
	DbSkip()

EndDo

If Li <> 80
	Roda(_nLastRec,cRodaTxt,Tamanho)
EndIf

If aReturn[5] == 1
	OurSpool(wnRel)
Endif

MS_FLUSH()

Return Nil

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function ValidPerg()
///////////////////////////
_aAlias := GetArea()
aPerg   := {}
//..             Grupo    Ordem    Perguntas                 Variavel  Tipo Tam Dec  Variavel  GSC   F3    Def01 Def02 Def03 Def04 Def05

aAdd( aPerg , { cPerg, "01", "Estado atual          ","","", "mv_ch1", "N",  1 , 0, 0, "C", "", "mv_par01", "Sim", "", "", "", "", "Nao", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","", ""})

DbSelectArea("SX1")
DbSetOrder(1)

For i:=1 to Len(aPerg)
	RecLock("SX1",!DbSeek(cPerg + aPerg[i, 2]))
	For j := 1 to (FCount())
		If j <= Len(aPerg[i]) .and. !(left(alltrim(FieldName(j)),6) $ 'X1_PRE/X1_CNT')
			FieldPut(j, aPerg[i, j])
		Endif
	Next
	MsUnlock()
Next

RestArea(_aAlias)

Return

