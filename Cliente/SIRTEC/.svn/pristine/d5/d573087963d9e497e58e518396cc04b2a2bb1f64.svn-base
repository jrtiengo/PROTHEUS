#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³                       ³ Data ³           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SIRRETCO()

	Local   _cImg      := ""
	Local   nOpc       := 0
	Private _cData     := dDataBase
	Private _aStatus   := {"","Executada","Rejeitada","Conta Paga"}
	Private _cStatus   := ""
	Private _aPrazo    := {"","No Prazo","Todos","Fora de Prazo"}
	Private _cPrazo    := ""
	Private _aTpNota   := {"","Suspensao","Religacao","Desligamento"}
	Private _cTpNota   := ""
	Private _cEquipe   := Space(TamSx3("ZZ4_EQUIPE")[1])
	Private _cNota     := ""
	Private _cGNota    := Space(TamSx3("ZZV_NOTA")[1])
	Private _cNome     := ""
	Private _cHora     := ""
	Private _cMedidor  := ""
	Private _cLeitura  := ""
	Private _cLocal    := ""
	Private _cRamal    := ""
	Private _cSituaca  := ""
	Private _cStat     := ""
	Private _cDef      := ""
	Private _cMatric   := ""
	Private _cVencimen := ""
	Private _cInstal   := ""
	Private _cMun      := ""
	Private _cObs      := ""
	Private _cSelo     := ""
	Private _cRejeit   := ""
	Private _cCEquipe  := ""
	Private _cRespon   := ""
	Private _nPosCnt   := 0
	Private _nPosImg   := 0
	Private noBrw1     := 0
	Private _aRecno    := {}
	Private aRHBrw     := {}
	Private aRCoBrw    := {}

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

	SetPrvt("oDlg1" ,"oGrp1"  ,"oGrp2"  ,"oSay1"  ,"oSay2"  ,"oSay3"  ,"oSay4" ,"oSay5" ,"oGet1" ,"oCBox1","oCBox2" )
	SetPrvt("oBtn1" ,"oPanel1","oPanel2","oPanel3","oPanel4","oPanel5","oGrp3" ,"oSay6" ,"oSay7" ,"oSay8" ,"oSay9"  )
	SetPrvt("oSay11","oSay12" ,"oSay13" ,"oSay14" ,"oSay15" ,"oSay16" ,"oSay17","oSay18","oSay19","oSay20","oSay21" )
	SetPrvt("oSay23","oSay24" ,"oSay25" ,"oSay26" ,"oSay27" ,"oSay28" ,"oSay29","oSay30","oSay31","oSay32","oSay33" )
	SetPrvt("oSay35","oSay36" ,"oSay37" ,"oSay38" ,"oSay39" ,"oSay40" ,"oCBox3" )

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

	aSizeAuto   := MsAdvSize()

	oDlg1       := MSDialog():New(aSizeAuto[7],0,aSizeAuto[6],aSizeAuto[5],"Retorno do Corte",,,.F.,,,,,,.T.,,,.T.)
	oDlg1:bInit := {||EnchoiceBar(oDlg1,{|| AtuDados()},{|| oDlg1:End()},.F.,{})}
	oGrp1       := TGroup():New(001,004,260,654,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGrp2       := TGroup():New(006,013,075,647," Filtro ",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1       := TSay():New(022,017,{||"Data Ref."},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2       := TSay():New(022,080,{||"Equipe"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3       := TSay():New(022,143,{||"Status"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay4       := TSay():New(022,207,{||"Prazo"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay5       := TSay():New(022,272,{||"Tipo Nota"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay41      := TSay():New(022,340,{||"Nota:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

	oGet1       := TGet():New(035,017,{|u| If(PCount()>0 ,_cData:=u,_cData)},oGrp2,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oGet2       := TGet():New(035,080,{|u| If(PCount()>0 ,_cEquipe:=u,_cEquipe)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oGet2:cF3   := "ZZ4"

	oGet3       := TGet():New(035,340,{|u| If(PCount()>0 ,_cGNota:=u,_cGNota)},oGrp2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)


	oCBox2      := TComboBox():New(035,143,{|u| If(PCount()>0,_cStatus:=u,_cStatus)},_aStatus,062,010,oGrp2,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
	oCBox3      := TComboBox():New(035,207,{|u| If(PCount()>0,_cPrazo:=u,_cPrazo)}  ,_aPrazo ,062,010,oGrp2,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
	oCBox4      := TComboBox():New(035,272,{|u| If(PCount()>0,_cTpNota:=u,_cTpNota)},_aTpNota,062,010,oGrp2,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
	oBtn1       := TButton():New(033,423,"Procurar",oGrp2,{|| Search()},067,012,,,,.T.,,"",,,,.F. )
	oBtn2       := TButton():New(033,493,"Retornar",oGrp2,{|| CRegBD(2)},067,012,,,,.T.,,"",,,,.F. )
	oBtn3       := TButton():New(033,563,"Avançar" ,oGrp2,{|| CRegBD(1)},067,012,,,,.T.,,"",,,,.F. )
	oPanel1     := TPanel():New(077,013," ",oGrp1,,.F.,.F.,CLR_WHITE,CLR_BLUE,634,009,.T.,.F. )
	oPanel2     := TPanel():New(089,013,"Nota STC" ,oGrp1,,.F.,.F.,CLR_WHITE,CLR_BLUE,634,008,.T.,.F. )
	oGrp3       := TGroup():New(097,014,250,647,"",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay6       := TSay():New(098,016,{||"N° Nota:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,021,008)
	oSay7       := TSay():New(098,039,{|u| If(PCount()>0,_cNota:=u,_cNota)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,042,008)
	oSay8       := TSay():New(098,090,{||"Nome:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
	oSay9       := TSay():New(098,108,{|u| If(PCount()>0,_cNome:=u,_cNome)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,167,008)
	oSay10      := TSay():New(108,016,{||"Hora Ex.: "},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)
	oSay11      := TSay():New(108,040,{|u| If(PCount()>0,_cHora:=u,_cHora)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008)
	oSay12      := TSay():New(108,098,{||"Medidor:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,022,008)
	oSay13      := TSay():New(108,121,{|u| If(PCount()>0,_cMedidor:=u,_cMedidor)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,065,008)
	oSay14      := TSay():New(108,187,{||"Leitura:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oSay15      := TSay():New(108,207,{|u| If(PCount()>0,_cLeitura:=u,_cLeitura)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay16      := TSay():New(108,250,{||"Local:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
	oSay17      := TSay():New(108,268,{|u| If(PCount()>0,_cLocal:=u,_cLocal)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay20      := TSay():New(118,016,{||"Situação:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,025,008)
	oSay21      := TSay():New(118,040,{|u| If(PCount()>0,_cSituaca:=u,_cSituaca)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)
	oSay22      := TSay():New(118,250,{||"Status:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
	oSay23      := TSay():New(118,268,{|u| If(PCount()>0,_cStat:=u,_cStat)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
	oSay24      := TSay():New(128,016,{||"Defeito:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oSay25      := TSay():New(128,038,{|u| If(PCount()>0,_cDef:=u,_cDef)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,210,008)
	oSay26      := TSay():New(128,250,{||"Matric:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
	oSay27      := TSay():New(128,270,{|u| If(PCount()>0,_cMatric:=u,_cMatric)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,068,008)
	oSay28      := TSay():New(138,016,{||"Vencimento:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay29      := TSay():New(138,048,{|u| If(PCount()>0,_cVencimen:=u,_cVencimen)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,054,008)
	oSay30      := TSay():New(138,118,{||"Instalação:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
	oSay31      := TSay():New(138,146,{|u| If(PCount()>0,_cInstal:=u,_cInstal)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,066,008)
	oSay32      := TSay():New(138,250,{||"Municipio:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
	oSay33      := TSay():New(138,275,{|u| If(PCount()>0,_cMun:=u,_cMun)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,062,008)
	oSay34      := TSay():New(148,016,{||"Observação:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay35      := TSay():New(158,016,{|u| If(PCount()>0,_cObs:=u,_cObs)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,474,008)
	oSay36      := TSay():New(168,016,{||"Selo:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,014,008)
	oSay38      := TSay():New(168,031,{|u| If(PCount()>0,_cSelo:=u,_cSelo)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,097,008)
	oSay39      := TSay():New(168,090,{||"Rejeição:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,025,008)
	oSay40      := TSay():New(168,115,{|u| If(PCount()>0,_cRejeit:=u,_cRejeit)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,187,008)
	oBmp1       := TBitmap():New(098,340,190,108,,_cImg,.F.,oDlg1,,,.F.,.T.,,"",.T.,,.T.,,.F. )
	oBtn4       := TButton():New(210,340,"Retornar",oGrp3,{|| AltImg(2)},067,012,,,,.T.,,"",,,,.F. )
	oBtn5       := TButton():New(210,415,"Avançar",oGrp3,{|| AltImg(1)},067,012,,,,.T.,,"",,,,.F. )

	oBtn6       := TButton():New(210,490,"Area Transf.",oDlg1,{|| Copy()},072,012,,,,.T.,,"",,,,.F. )

	MontCabec()
	MontGrid()

	oBrw1       := MsNewGetDados():New(178,016,245,320,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg1,aRHBrw,aRCoBrw)

	AltImg(1,1)

	oDlg1:Activate(,,,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³PROG01L   ºAutor  ³Microsiga           º Data ³  02/16/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    

Static Function Search

	Local _cQuery  := ""
	Local _cMedida := ""
	Local _cAlias  := GetNextAlias()
	Local _cAlAux  := GetNextAlias()
	Local _nLin    := 0
	Local _aDados  := {}

	If Select("_cAlias") > 0
		("_cAlias")->(DbClosearea())
	EndIf

	_cQuery := " SELECT R_E_C_N_O_ "
	_cQuery += " FROM "+RetSqlName("ZZW")
	_cQuery += " WHERE  D_E_L_E_T_  != '*' "
	_cQuery += " AND    ZZW_SITUAC   = ''  "
	_cQuery += " AND    ZZW_TPARQ    = '2' "
	_cQuery += " AND    ZZW_RETSTA  != 'S' "

	If !Empty(_cData)

		_cQuery += " AND ZZW_DATA   = '"+DToS(_cData)+"' "

	EndIf

	If !Empty(_cEquipe)

		_cQuery += " AND ZZW_EQUIP  = '"+_cEquipe+"' "

	EndIf

//-> padronizar gravação do campo para somente um caracter
	If !Empty(_cStatus)

		_cQuery += " AND ZZW_STATUS LIKE '"+SubStr(_cStatus,1,1)+"%' "

	EndIf

//If !Empty(_cPrazo)

//EndIf

	If !Empty(_cTpNota)

		Do Case

		Case SubStr(_cTpNota,1,1) == "S"
			_cMedida := " ('SFAR','SFFP','SSRE','SCRE','SFCI') "

		Case SubStr(_cTpNota,1,1) == "R"
			_cMedida := " ('REUR','RENO','REIC','REIE','REAJ','RCEB') "

		Case SubStr(_cTpNota,1,1) == "D"
			_cMedida := " ('DAPE','DAPN','DCRN') "

		EndCase

		_cQuery += " AND ZZW_TPMED IN "+_cMedida

	EndIf

	If !Empty(_cGNota)

		_cQuery += " AND ZZW_NOTA = '"+_cGNota+"' "

	EndIf

	_cQuery += "ORDER BY R_E_C_N_O_"

	TcQuery _cQuery New Alias _cAlias

	If ("_cAlias")->R_E_C_N_O_ = 0

		_cNota     := ""
		_cNome     := ""
		_cHora     := ""
		_cMedidor  := ""
		_cLeitura  := ""
		_cLocal    := ""
		_cSituaca  := ""
		_cStat     := ""
		_cDef      := ""
		_cMatric   := ""
		_cVencimen := ""
		_cInstal   := ""
		_cMun      := ""
		_cObs      := ""
		_cSelo     := ""
		_cRejeit   := ""
		_cCEquipe  := ""
		_cRespon   := ""

		AltImg(1,1)

		Return

	EndIf

	_aRecno := {}

	While !("_cAlias")->(Eof())

		aAdd(_aRecno,{("_cAlias")->R_E_C_N_O_})

		("_cAlias")->(DbSkip())
	EndDo

	DbSelectArea("ZZW")
	DbGoTo(_aRecno[1,1])

	_nPosCnt++

	_cNota     := ZZW->ZZW_NOTA
	_cNome     := ZZW->ZZW_CLIENT
	_cHora     := Substr(DTOS(ZZW->ZZW_DATA),7,2)+"/" + Substr(DTOS(ZZW->ZZW_DATA),5,2) +"/"+Substr(DTOS(ZZW->ZZW_DATA),1,4)+" - "  + ZZW->ZZW_HORA
	_cMedidor  := Posicione("ZZV",2,xFilial("ZZV")+ZZW->ZZW_NOTA,"ZZV_MEDID")
	_cLeitura  := Posicione("ZA2",1,xFilial("ZA2")+ZZW->ZZW_NOTA,"ZA2_LEILOC")//Posicione("ZA2",1,xFilial("ZA2")+ZZW->ZZW_NOTA,"ZA2_LEIMED")
	_cLocal    := Posicione("ZA2",1,xFilial("ZA2")+ZZW->ZZW_NOTA,"ZA2_LOCAL")
	_cSituaca  := ZZW->ZZW_SITUA
	_cStat     := ZZW->ZZW_STATUS
	_cDef      := ZZW->ZZW_DEFEIT
	_cMatric   := ZZW->ZZW_MATRIC
	_cVencimen := Posicione("ZZU",2,xFilial("ZZU")+ZZW->ZZW_NOTA,"ZZU_VENC") //+ ZZU_HORVEN
	_cInstal   := Posicione("ZZU",2,xFilial("ZZU")+ZZW->ZZW_NOTA,"ZZU_INSTAL")
	_cMun      := Posicione("ZZU",2,xFilial("ZZU")+ZZW->ZZW_NOTA,"ZZU_MUN")
	_cObs      := ZZW->ZZW_OBS
	_cSelo     := Posicione("ZZU",2,xFilial("ZZU")+ZZW->ZZW_NOTA,"ZZU_SELO1")
	_cRejeit   := ZZW->ZZW_REJEIT

	_cCEquipe  := Posicione("ZZU",2,xFilial("ZZU")+ZZW->ZZW_NOTA,"ZZU_EQUIP")

	_cRespon   := Posicione("ZZ4",1,xFilial("ZZ4")+_cCEquipe,"ZZ4_NOMETC")

//->Carrega dados ZA5
	DbSelectArea("ZA5")
	DbSetOrder(1)
	If DbSeek(xFilial("ZA5")+ZZW->ZZW_NOTA)

		While xFilial("ZA5")+ZZW->ZZW_NOTA == ZA5_FILIAL + ZA5->ZA5_NOTA

			aAdd(_aDados,{ZA5->ZA5_CODSAP,ZA5->ZA5_DESC,.F.})

			DbSkip()
		EndDo

		oBrw1:aCols := _aDados
		oBrw1:Refresh()

	EndIf

	AltImg(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRegBD  ºAutor  ³Microsiga           º Data ³  02/17/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CRegBD(pnOpc)

	Local nOpc      := pnOpc
	Local nTamArr   := Len(_aRecno)
	Local _nPos     := 0
	Local _cQuery   := ""
	Local _cAlAv    := GetNextAlias()
	Local _nRecno   := 0
	Local _nCntAux  := 0
	Local _nValNota := 0
	Local _nLin     := 0
	Local _aDados   := {}

//_aDados := {"","",.F.}

	_nPosImg := 0

	If Empty(_cNota)
		Return
	EndIf

	If nOpc = 1

		//->Variavel possui a informação da posição atual do array _aRecno
		_nPosCnt++

		If  _nPosCnt > Len(_aRecno)

			_nPosCnt := Len(_aRecno)

			_nPos    := _nPosCnt

			_nRecno  := _aRecno[_nPos,1]

		Else

			_nPos    := _nPosCnt

			_nRecno  := _aRecno[_nPos,1]

		EndIf

	Else

		_nPosCnt--

		If _nPosCnt <=0
			_nPosCnt := 1
		EndIf

		_nPos    := _nPosCnt

		_nRecno  := _aRecno[_nPos,1]

	EndIf

	If Select("_cAlAv") > 0
		("_cAlAv")->(DbCloseArea())
	EndIf

	_cQuery := " SELECT * FROM "+RetSqlName("ZZW")
	_cQuery += " WHERE D_E_L_E_T_ != '*' "
	_cQuery += " AND   ZZW_SITUAC  = ''  "
	_cQuery += " AND   ZZW_TPARQ   = '2' "
	_cQuery += " AND   R_E_C_N_O_  = '"+cValToChar(_nRecno)+"'"

	TcQuery _cQuery New Alias _cAlAv

	_cNota     := ("_cAlAv")->ZZW_NOTA
	_cNome     := ("_cAlAv")->ZZW_CLIENT
	_cHora     := Substr(("_cAlAv")->ZZW_DATA,7,2)+"/" + Substr(("_cAlAv")->ZZW_DATA,5,2) +"/"+Substr(("_cAlAv")->ZZW_DATA,1,4)+" - "  + ("_cAlAv")->ZZW_HORA
	_cMedidor  := Posicione("ZZV",2,xFilial("ZZV")+("_cAlAv")->ZZW_NOTA,"ZZV_MEDID")
	_cLeitura  := Posicione("ZA2",1,xFilial("ZA2")+("_cAlAv")->ZZW_NOTA,"ZA2_LEILOC")//Posicione("ZA2",1,xFilial("ZA2")+("_cAlAv")->ZZW_NOTA,"ZA2_LEIMED")
	_cLocal    := Posicione("ZA2",1,xFilial("ZA2")+("_cAlAv")->ZZW_NOTA,"ZA2_LOCAL")

	_cSituaca  := ("_cAlAv")->ZZW_SITUA
	_cStat     := ("_cAlAv")->ZZW_STATUS
	_cDef      := ("_cAlAv")->ZZW_DEFEIT
	_cMatric   := ("_cAlAv")->ZZW_MATRIC
	_cVencimen := Posicione("ZZU",2,xFilial("ZZU")+("_cAlAv")->ZZW_NOTA,"ZZU_VENC") //+ ZZU_HORVEN
	_cInstal   := Posicione("ZZU",2,xFilial("ZZU")+("_cAlAv")->ZZW_NOTA,"ZZU_INSTAL")
	_cMun      := Posicione("ZZU",2,xFilial("ZZU")+("_cAlAv")->ZZW_NOTA,"ZZU_MUN")

	_cSelo     := Posicione("ZZU",2,xFilial("ZZU")+("_cAlAv")->ZZW_NOTA,"ZZU_SELO1")
	_cRejeit   := ("_cAlAv")->ZZW_REJEIT

	_cObs      := ""

	DbSelectArea("ZZW")
	DbSetOrder(2)
	If DbSeek(xFilial("ZZW")+("_cAlAv")->ZZW_NOTA)

		nLines   := MLCount(ZZW->ZZW_OBS)
		nQtdeLin := 0
		//-> Varre todas as linhas do texto e imprime
		If nLines > 0

			For nX := 1 To nLines

				_cObs += MemoLine(ZZW->ZZW_OBS,120,nX)

			Next nX

		EndIf

		//->Carrega dados ZA5
		DbSelectArea("ZA5")
		DbSetOrder(1)
		If DbSeek(xFilial("ZA5")+("_cAlAv")->ZZW_NOTA)

			While xFilial("ZA5")+("_cAlAv")->ZZW_NOTA == ZA5_FILIAL + ZA5->ZA5_NOTA

				aAdd(_aDados,{ZA5->ZA5_CODSAP,ZA5->ZA5_DESC,.F.})

				DbSkip()
			EndDo

		EndIf

		oBrw1:aCols := _aDados
		oBrw1:Refresh()

	EndIf

	AltImg(1,1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRRETL   ºAutor  ³Microsiga           º Data ³  06/18/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AltImg(_nOpc,_nOpX)

	Local aFiles  := {}
	Local _nCont  := 0
	Local _aDados := {}

	Default _nOpX   := 0

	If !Empty(_cNota)

		aFiles  := Directory("\Notas\"+AllTrim(_cNota)+"\*.*", "D")

		For _nX := 1 To Len(aFiles)

			If aFiles[_nX,2] > 0

				_nCont++
				aAdd(_aDados,{aFiles[_nX,1],_nCont})

			EndIf

		Next _nX

	EndIf

	If Len(_aDados) = 0

		oBmp1:Load(,"\System\Notas\naodisponivel.jpg")
		oBmp1:SetBmp("\System\Notas\naodisponivel.jpg")
		oBmp1:Refresh()
		Return

	EndIf

	If _nOpc = 1

		If Len(_aDados) = 1

			If _nPosImg = 0
				_nPosImg++
			EndIf

		Else

			If _nPosImg = Len(_aDados)

				_nPosImg := Len(_aDados)

			Else

				_nPosImg++

			EndIf

		EndIf

	Else

		If _nPosImg = 1

			_nPosImg := 1

		Else

			_nPosImg--

		EndIf

	EndIf

	oBmp1:Load(,"\Notas\"+AllTrim(_cNota)+"\"+_aDados[_nPosImg,1])
	oBmp1:SetBmp("\Notas\"+AllTrim(_cNota)+"\"+_aDados[_nPosImg,1])
	oBmp1:Refresh()
	SysRefresh()
	ProcessMessage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRRETL   ºAutor  ³Microsiga           º Data ³  06/18/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuDados

	DbSelectArea("ZZW")
	DbSetOrder(2)
	If DbSeek(xFilial("ZZW")+_cNota)

		If RecLock("ZZW",.F.)

			ZZW->ZZW_SITUAC := "S"
			MsUnlock()

		EndIf

		_nPos    := _nPosCnt
		_nPosAnt := _nPos

		aDel(_aRecno,_nPos)
		aSize(_aRecno,Len(_aRecno)-1)

		MsgInfo("Registro arquivado com sucesso!","Atenção")

		If Len(_aRecno) > 0
			If _nPosAnt = 1
				CRegBD(1)
			Else
				CRegBD(2)
			EndIf
		Else
			oDlg1:End()
		EndIf

	EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SIRRETL   ºAutor  ³Microsiga           º Data ³  07/28/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Copy

	Local _cMulCpy := ""

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

	SetPrvt("oDCpy","oGrp1","oMGet1")


	_cMulCpy += "Nota: "+_cNota+Chr(10)+Chr(13)

	_cMulCpy += "Leitura: "+_cLeitura+Chr(10)+Chr(13)

	_cMulCpy += "Selo: "+_cSelo+Chr(10)+Chr(13)

	_cMulCpy += "Rejeição: "+_cRejeit+Chr(10)+Chr(13)

	_cMulCpy += "Observação: "+_cObs+Chr(10)+Chr(13)

	_cMulCpy += "Equipe: "+_cCEquipe+" - "+_cRespon  +Chr(10)+Chr(13)

	_cMulCpy += "Local: "+_cLocal  +Chr(10)+Chr(13)

	_cMulCpy += "Hora Ex.: "+_cHora+Chr(10)+Chr(13)

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

	oDCpy            := MSDialog():New(092,232,450,1100,"Area de transferencia de dados",,,.F.,,,,,,.T.,,,.T. )
	oDCpy:bInit      := {||EnchoiceBar(oDCpy,{|| oDCpy:End()},{|| oDCpy:End()},.F.,{})}
	oGrp1            := TGroup():New(020,004,164,424,"",oDCpy,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oMGet1           := TMultiGet():New(026,007,{|u| If(PCount()>0 , _cMulCpy := u,_cMulCpy)},oGrp1,412,133,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	oMGet1:lReadOnly := .T.

	oDCpy:Activate(,,,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³MontGrid ºAutor  ³Microsiga           º Data ³  12/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³  Monta aCols da MsNewGetDados para o Alias:                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ AP                                                         º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontGrid()

	Aadd(aRCoBrw,Array(noBrw1+1))

	aRCoBrw[1,1] := Space(TamSx3("ZA5_CODSAP")[1])
	aRCoBrw[1,2] := Space(TamSx3("ZA5_DESC")[1])
	aRCoBrw[1,3] := .F.

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³MontCabec ºAutor  ³Microsiga           º Data ³  12/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³  Monta aHeader da MsNewGetDados para o Alias:              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontCabec()

	Local _cCampos := ""
	Local _cAlias  := ""
	Local _cSX3    := GetNextAlias()

	_cCampos       := "ZA5_CODSAP|ZA5_DESC"
	_cAlias        := "ZA5"

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		dbSelectArea(_cSX3)
		(_cSX3)->(dbSetOrder(1))
		(_cSX3)->(dbSeek(_cAlias))
		If (Found())
			While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == _cAlias )
				If X3Uso( &("(_cSX3)->X3_USADO")) .and. cNivel >= &("(_cSX3)->X3_NIVEL") .And. AllTrim( &("(_cSX3)->X3_CAMPO")) $ _cCampos

					noBrw1++

					Aadd(aRHBrw,{Trim(&("(_cSX3)->X3_TITULO")),;
						&("(_cSX3)->X3_CAMPO"),;
						&("(_cSX3)->X3_PICTURE"),;
						&("(_cSX3)->X3_TAMANHO"),;
						&("(_cSX3)->X3_DECIMAL"),;
						"",;
						"",;
						&("(_cSX3)->X3_TIPO"),;
						"",;
						""})

				EndIf

				(_cSX3)->(DBSkip())
			EndDo
		EndIf
	Endif
	(_cSX3)->(dbCloseArea())

/*
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(_cAlias)
	While !SX3->(Eof()) .And. AllTrim(SX3->X3_ARQUIVO) == _cAlias

		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .And. AllTrim(SX3->X3_CAMPO) $ _cCampos
    
    	noBrw1++
      
      	Aadd(aRHBrw,{Trim(X3Titulo()),;
                      SX3->X3_CAMPO,;
                      SX3->X3_PICTURE,;
                      SX3->X3_TAMANHO,;
                      SX3->X3_DECIMAL,;
                      "",;
                      "",;
                      SX3->X3_TIPO,;
                      "",;
                      ""})
                      
		EndIf
   
   DbSkip()
	EndDo
*/

Return