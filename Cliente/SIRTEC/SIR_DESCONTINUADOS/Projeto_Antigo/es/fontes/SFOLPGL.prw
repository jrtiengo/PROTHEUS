#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ         ณ Autor ณ                       ณ Data ณ           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLocacao   ณ                  ณContato ณ                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAplicacao ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista Resp.ณ  Data  ณ                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ  /  /  ณ                                               ณฑฑ
ฑฑณ              ณ  /  /  ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function SFOLPGL

Local   nOpc1      := GD_INSERT//+GD_DELETE+GD_UPDATE
Local   nOpc2      := GD_INSERT//+GD_DELETE+GD_UPDATE
Local   aSizeAuto  := {}
Local   _aMedic    := {"Direta","Indireta"} 
Local   _aStatus   := {"Liberadas","Aberta","Sobra"}
Local   _aMedic    := {"","Direta","Indireta"} 
Local   _aStatus   := {"","Liberadas","Aberta","Sobra"}
Local   oFontN     := TFont():New("Arial",,-10,,.T.) 
Private bKeyF5     := {|| FSeaCort()}
//Private _cCBMedic  := ""
Private _cEst      := Space(TamSx3("ZZQ_EST")[1])
Private _cMun      := Space(TamSx3("ZZQ_MUN")[1])
Private _cArea     := Space(TamSx3("ZZQ_CODARE")[1])
Private _cBairro   := Space(TamSx3("ZZR_CODBAI")[1])
Private _cDatI     := dDataBase
Private _cDatF     := dDataBase
Private _cStatus   := ""
Private _cCBMedic  := ""
Private _cComp     := ""
Private _cEstC     := Space(TamSx3("ZZQ_EST")[1])
Private _cMunC     := Space(TamSx3("ZZQ_MUN")[1])
Private _cOrd      := ""
Private _cCarga    := ""
Private _cServ     := ""
Private _cTipo     := ""
Private _cMedi     := ""
Private _cVisit    := "0"
Private _cVisit2   := "0"
Private _cNotas    := "0"
Private _cVenc     := "0"
Private _cAgrup    := "0"
Private _cVencendo := "0"
Private _cAVenc    := "0"
Private _cSel      := "0"
Private _cSelC     := "0"
Private _aOrd      := {"","Bairro","Tipo"} 
Private _aServ     := {}
Private _aTipo     := {"","DAPE","DAPN","DCRN","SFAR","SFFP","SSRE","SCRE","REUR","RENO","REIC","REIE","REAJ"} 
Private aCoBrw1    := {}
Private aCoBrw2    := {}
Private aHoBrw1    := {}
Private aHoBrw2    := {}
Private _aRecno    := {}
Private _aArrExc   := {}
Private _aCols     := {}
Private _aColsCrt  := {}
Private noBrw1     := 0
Private noBrw2     := 0
Private _nPosCnt   := 0
Private _nVencidas := 0
Private	_nVencendo := 0 
Private	_nAVencer  := 0
Private _oOk       := LoadBitmap(GetResources(), "LBOK")
Private _oNo       := LoadBitmap(GetResources(), "LBNO")
Private _oFC08     := TFont():New('Courier New',,-12,.F.)
Private _lCBAmb    := .F.
Private _lCBCrt    := .F.
Private _lCBLig    := .F.
Private _nSelC     := 0
Private _nVist2    := 0                                
Private _cMun      := Space(TamSx3("ZZQ_MUN")[1])
Private _cNotC     := "0"
Private _cStatus   := ""
Private _cVisiCrt  := "0"
Private _cVenc     := "0"
Private _cVencendo := "0"
Private _cAVenc    := "0"
Private _cSel      := "0"
Private _cTotSel   := "0"  
Private _cTotSC    := "0"
//Private _cMedi     := ""
Private _cComp     := ""
Private _cVenc2    := ""
Private _cEquipe := Space(TamSx3("ZZ4_EQUIPE")[1])
Private _cPrazo    := ""
Private _cStatus2  := ""
Private _cLib      := ""
Private _cArea2    := ""
Private _cAgrup2   := ""
Private _cItem     := "0"
Private _cNota     := ""
Private _cData     := ""
Private _cServic   := ""
Private _cMedida   := ""
Private _cSubCat   := ""
Private _cLat      := ""
Private _cLong     := ""
Private _cInst     := ""
Private _cCliente  := ""
Private _cTel      := ""
Private _cMunicip  := ""
Private _cBair     := ""
Private _cEnd      := ""
Private _cClasse   := ""
Private _cCarga    := ""
Private _cProtI    := ""
Private _cProtE    := ""
Private _cFase     := ""
Private _cNeutro   := ""
Private _cMltGet   := ""
Private _cStrCVst  := ""
Private _cStrRg    := "" 
Private _cEst      := Space(TamSx3("ZZQ_EST")[1])
Private _nRecAtu   := 0
Private _nPosAgp   := 0 
Private _nCntAgp   := 0
Private _nTotAgp   := 0
Private _nNotas    := 0
Private _nItem     := 0
Private _nAgrup    := 0
Private _aAgrup    := {}
Private _lCkSel    := .F.
Private _aSelDa    := {}
Private _aRegCnt   := {}
Private _nSelec    := 0
Private	_nVencendo := 0 
Private	_nAVencer  := 0
Private _nCntVst   := 0
Private _cQryArea  := ""
Private _cAlArea   := GetNextAlias()
Private _lConfirm  := .T. 

/*
ฑฑฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Declara็ใo de Variaveis Private dos Objetos                         ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

SetPrvt("oDlg1" ,"oPanel1","oGrp1" ,"oSay1"  ,"oSay2" ,"oSay3" ,"oSay4" ,"oSay5" ,"oSay77" ,"oGet1" ,"oGet2"  )
SetPrvt("oCBox2","oBtn1"  ,"oGet4" ,"oPanel2","oGrp2" ,"oSay6" ,"oSay7" ,"oSay8" ,"oSay9"  ,"oSay10","oSay11" )
SetPrvt("oSay13","oSay14" ,"oSay15","oSay16" ,"oSay17","oSay18","oSay19","oSay20","oSay21" ,"oBtn2" ,"oGrp3"  )
SetPrvt("oSay23","oSay24" ,"oSay25","oSay26" ,"oSay27","oSay28","oSay29","oSay30","oSay31" ,"oSay32","oSay33" )
SetPrvt("oSay35","oSay36" ,"oSay37","oSay38" ,"oSay39","oSay40","oSay41","oSay42","oSay43" ,"oSay44","oSay45" )
SetPrvt("oSay47","oSay48" ,"oSay49","oSay50" ,"oSay51","oSay52","oSay53","oSay54","oSay55" ,"oSay56","oSay57" )
SetPrvt("oSay59","oSay60" ,"oSay61","oSay62" ,"oSay63","oSay64","oSay65","oSay66","oSay67" ,"oSay68","oSay69" )
SetPrvt("oSay71","oSay72" ,"oSay73","oSay74" ,"oSay75","oSay76","oCBox3","oCBox4","oPanel1","oFld1" ,"oGrp6"  )
SetPrvt("oDlg1" ,"oGrp1"  ,"oGrp2" ,"oGrp3"  ,"oGrp4" ,"oCBox3","oCBox2","oCBox1","oGet3"  ,"oMulti"          )
SetPrvt("oGrp5" ,"oBrw1"                                                                                      )
SetPrvt("oFPG"  ,"oFld1"                                                                                      )

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Definicao do Dialog e todos os seus componentes.                     ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

SetKey(VK_F5 , bKeyF5)

aSizeAuto := MsAdvSize()

oFPG      := MSDialog():New(aSizeAuto[7],0,aSizeAuto[6],aSizeAuto[5],"Programa็ใo",,,.F.,,,,,,.T.,,,.T.)

oFlP      := TFolder():New(004,004,{"Liga็ใo","Corte"},{},oFPG,,,,.T.,.F.,647,262,)

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Liga็ใo                                                              ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

oFPG:bInit  := {||EnchoiceBar(oFPG,{|| PROG02L()} ,{|| oFPG:End()},.F.,{})}

oPanel1     := TPanel():New(010,004,"Programa็ใo",oFlP:aDialogs[1],,.F.,.F.,CLR_WHITE,CLR_BLUE,640,008,.T.,.F. )
oGrp1       := TGroup():New(020,004,059,644," Filtros para consulta ",oFlP:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1       := TSay():New(032,064,{||"Municipio:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay2       := TSay():New(032,136,{||"Area:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,015,008)
oSay3       := TSay():New(032,208,{||"Bairro:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay4       := TSay():New(032,276,{||"Medi็ใo:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay5       := TSay():New(032,336,{||"Status"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay77      := TSay():New(032,008,{||"Estado:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)

oGet1       := TGet():New(044,008,{|u| If(PCount()>0 ,_cEst:=u,_cEst)},oGrp1,037,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet1:cF3   := "12"

oGet2       := TGet():New(044,064,{|u| If(PCount()>0 ,_cMun:=u,_cMun)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2:cF3   := "CC2CST" 

oGet3       := TGet():New(044,135,{|u| If(PCount()>0 ,_cArea:=u,_cArea)},oGrp1,060,008,'',{||ChecaArea()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet3:cF3   := "ZZQ"

oGet4       := TGet():New(044,207,{|u| If(PCount()>0 ,_cBairro:=u,_cBairro)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet4:cF3   := "CSBZZR"

oCBox1      := TComboBox():New(044,276,{|u| If(PCount()>0,_cCBMedic:=u,_cCBMedic)},_aMedic,052,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oCBox2      := TComboBox():New(044,336,{|u| If(PCount()>0,_cStatus:=u,_cStatus)},_aStatus,056,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
 
oPanel2     := TPanel():New(100,004,"",oFlP:aDialogs[1],,.F.,.F.,,CLR_BLUE,640,009,.T.,.F. )
oGrp2       := TGroup():New(059,004,100,644," Op็๕es ",oFlP:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay6       := TSay():New(071,012,{||"Notas:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
oSay7       := TSay():New(071,029,{|u| If(PCount()>0 , _cNotas := u,_cNotas)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay8       := TSay():New(088,012,{||"Vencidas:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,025,008)
oSay9       := TSay():New(088,036,{|u| If(PCount()>0 , _cVenc := u,_cVenc)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,024,008)

oSay10      := TSay():New(071,060,{||"Agrupadas:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
oSay11      := TSay():New(071,088,{|u| If(PCount()>0 , _cAgrup := u, _cAgrup)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay12      := TSay():New(088,060,{||"Vencendo:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,027,008)
oSay13      := TSay():New(088,087,{|u| If(PCount()>0 , _cVencendo := u, _cVencendo)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay14      := TSay():New(071,104,{||"Visitas:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay15      := TSay():New(071,122,{|u| If(PCount()>0 , _cVisit := u, _cVisit)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay16      := TSay():New(088,104,{||"A Vencer:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,025,008)
oSay17      := TSay():New(088,129,{|u| If(PCount()>0 , _cAVenc := u, _cAVenc)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay18      := TSay():New(071,160,{||"Selecionadas:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,034,008)
oSay19      := TSay():New(071,195,{|u| If(PCount()>0 , _cSel := u,_cSel)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oSay20      := TSay():New(088,158,{||"Visitas:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay21      := TSay():New(088,176,{|u| If(PCount()>0 , _cVisit2 := u,_cVisit2)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oSay76      := TSay():New(071,208,{||"Total Selecionado:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay77      := TSay():New(071,255,{|u| If(PCount()>0 , _cTotSel := u,_cTotSel)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oBtn1       := TButton():New(042,403,"Procurar" ,oGrp1,{|| Search() },070,012,,,,.T.,,"",,,,.F. )

oGrp3       := TGroup():New(109,004,244,644,"",oFlP:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay22      := TSay():New(120,008,{||"Medi็ใo:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)
oSay23      := TSay():New(120,032,{|u| If(PCount()>0 , _cMedi := u,_cMedi)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay24      := TSay():New(120,068,{||"Comp.:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay25      := TSay():New(120,086,{|u| If(PCount()>0 , _cComp := u,_cComp)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,064,008)

oSay26      := TSay():New(120,156,{||"Venc.:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
oSay27      := TSay():New(120,173,{|u| If(PCount()>0 , _cVenc2 := u,_cVenc2)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE,068,008)

oSay28      := TSay():New(120,232,{||"Prazo:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
oSay29      := TSay():New(120,249,{|u| If(PCount()>0 , _cPrazo := u,_cPrazo)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE,032,008)

oSay30      := TSay():New(120,267,{||"Status:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay31      := TSay():New(120,285,{|u| If(PCount()>0 , _cStatus2 := u,_cStatus2)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay32      := TSay():New(120,322,{||"Liberada:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay33      := TSay():New(120,345,{|u| If(PCount()>0 , _cLib := u,_cLib)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay34      := TSay():New(120,368,{||"Area:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,014,008)
oSay35      := TSay():New(120,382,{|u| If(PCount()>0 , _cArea2 := u,_cArea2)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay36      := TSay():New(120,396,{||"Agrup.:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,019,008)
oSay37      := TSay():New(120,414,{|u| If(PCount()>0 , _cAgrup2 := u,_cAgrup2)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay38      := TSay():New(120,441,{||"Selecionar"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,027,008)

oSay39      := TSay():New(129,008,{||"Item:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,013,008)
oSay40      := TSay():New(129,021,{|u| If(PCount()>0 , _cItem := u,_cItem)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,020,008)

oSay41      := TSay():New(129,044,{||"Nota:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,014,008)
oSay42      := TSay():New(129,058,{|u| If(PCount()>0 , _cNota := u,_cNota)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)

oSay43      := TSay():New(129,105,{||"Data:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,014,008)
oSay44      := TSay():New(129,119,{|u| If(PCount()>0 , _cData := u,_cData)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,057,008)

oSay45      := TSay():New(129,192,{||"Servi็o:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,021,008)
oSay46      := TSay():New(129,213,{|u| If(PCount()>0 , _cServic := u,_cServic)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,099,008)

oSay47      := TSay():New(139,008,{||"Medida:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
oSay48      := TSay():New(139,029,{|u| If(PCount()>0 , _cMedida := u,_cMedida)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,224,008)

oSay49      := TSay():New(148,008,{||"Sub Cat.:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,043,008)
oSay50      := TSay():New(148,032,{|u| If(PCount()>0 , _cSubCat := u,_cSubCat)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,240,008)

oSay51      := TSay():New(161,008,{||"Instala็ใo:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,027,008)
oSay52      := TSay():New(161,036,{|u| If(PCount()>0 , _cInst := u,_cInst)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,100,008)

oSay53      := TSay():New(161,0118,{||"Cliente:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay54      := TSay():New(161,138,{|u| If(PCount()>0 , _cCliente := u,_cCliente)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,128,008)

oSay55      := TSay():New(161,252,{||"Telefones:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay56      := TSay():New(161,278,{|u| If(PCount()>0 , _cTel := u,_cTel)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,078,008)

oSay57      := TSay():New(170,008,{||"Municipio:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,025,008)
oSay58      := TSay():New(170,034,{|u| If(PCount()>0 , _cMunicip := u,_cMunicip)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,046,008)

oSay59      := TSay():New(170,0109,{||"Bairro:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oSay60      := TSay():New(170,0129,{|u| If(PCount()>0 , _cBair := u,_cBair)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,052,008)

oSay61      := TSay():New(179,008,{||"Endere็o:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)
oSay62      := TSay():New(179,034,{|u| If(PCount()>0 , _cEnd := u,_cEnd)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,160,008)

oSay63      := TSay():New(188,008,{||"Classe:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay64      := TSay():New(188,027,{|u| If(PCount()>0 , _cClasse := u,_cClasse)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,133,008)

oSay65      := TSay():New(188,172,{||"Carga:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oSay66      := TSay():New(188,188,{|u| If(PCount()>0 , _cCarga := u,_cCarga)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay67      := TSay():New(188,228,{||"Prot.Individual:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay68      := TSay():New(188,264,{|u| If(PCount()>0 , _cProtI := u,_cProtI)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,044,008)

oSay69      := TSay():New(188,316,{||"Prot.Entrada:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay70      := TSay():New(188,349,{|u| If(PCount()>0 , _cProtE := u,_cProtE)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay71      := TSay():New(188,386,{||"Fase:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,014,008)
oSay72      := TSay():New(188,401,{|u| If(PCount()>0 , _cFase := u,_cFase)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay73      := TSay():New(188,439,{||"Neutro:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,019,008)
oSay74      := TSay():New(188,458,{|u| If(PCount()>0 , _cNeutro := u,_cNeutro)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay75      := TSay():New(200,008,{||"Observa็๕es:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,034,008)

oBtn3       := TButton():New(200,403,"Voltar"  ,oGrp1,{||CRegBD(2) },070,012,,,,.T.,,"",,,,.F. )
oBtn4       := TButton():New(200,483,"Avan็ar" ,oGrp2,{||CRegBD(1) },070,012,,,,.T.,,"",,,,.F. )

oCBox3      := TCheckBox():New(120,468,""     ,{|u| If(PCount()>0,_lCkSel:=u,_lCkSel)},oGrp3,008,008,,{|| SelNotas()},,,CLR_BLACK,CLR_WHITE,,.T.,"",,)

oMulti      := TMultiGet():New(209,008,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrp3,388,032,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

/*
ฑฑฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Corte                                                             ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

oPanel3   := TPanel():New(010,004,"Programa็ใo",oFlP:aDialogs[2],,.F.,.F.,CLR_WHITE,CLR_BLUE,640,008,.T.,.F. )

oGpCrt    := TGroup():New( 018,003,70,641," Filtro ",oFlP:aDialogs[2],CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay07    := TSay():New(025,011,{||"Data Inicio:"},oGpCrt,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet5     := TGet():New(036,011,{|u| If(PCount()>0 ,_cDatI:=u,_cDatI)},oGpCrt,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSay08    := TSay():New(025,055,{||"Data Fim:"},oGpCrt,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet6     := TGet():New(036,055,{|u| If(PCount()>0 ,_cDatF:=u,_cDatF)},oGpCrt,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSay09    := TSay():New(025,099,{||"Estado:"},oGpCrt,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet7     := TGet():New(036,099,{|u| If(PCount()>0 ,_cEstC:=u,_cEstC)},oGpCrt,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet7:cF3 := "12"

oSay10    := TSay():New(025,143,{||"Municipio:"},oGpCrt,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet8     := TGet():New(036,143,{|u| If(PCount()>0 ,_cMunC:=u,_cMunC)},oGpCrt,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet8:cF3 := "CC2CST"

oSay11    := TSay():New(025,187,{||"Ordenar"},oGpCrt,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBox3    := TComboBox():New(036,187,{|u| If(PCount()>0,_cOrd:=u,_cOrd)},_aOrd,056,010,oGpCrt,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

oSay12    := TSay():New(025,250,{||"Tipo"},oGpCrt,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBox4    := TComboBox():New(036,250,{|u| If(PCount()>0,_cTipo:=u,_cTipo)},_aTipo,056,010,oGpCrt,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

oPanel    := TPanel():New(070,004,"",oFlP:aDialogs[2],,.F.,.F.,CLR_WHITE,CLR_BLUE,640,009,.T.,.F. )

oFld1     := TFolder():New(80,004,{"Corte"},{},oFlP:aDialogs[2],,,,.T.,.F.,636,144,)

oGrp6     := TGroup():New(004,004,124,628," Dados do corte ",oFld1:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
						      
_aBrw2    := {}

oBtn2     := TButton():New(034,315,"Procurar" ,oGpCrt,{|| FSeaCort()},070,012,,,,.T.,,"",,,,.F. )

//Array com os campos da grade de dados

_aHeadCrt := {"Linha"," ","Numero","Data Tmporta็ใo","Data Nota","Data Limite","Tipo","Deb.","Valor Deb.","Descri็ใo","Municipio","Bairro","Observa็ใo"," "}

//Criacao do objeto ListBox
oBrCrt    := TCBrowse():New(035,012,610,75,,_aHeadCrt,_aColsCrt,oGrp6,,,,,{||},,_oFC08,,,,,.F.,,.T.,,.F.,,,)

Aadd(_aBrw2,{"",.F.,"","","","","",0,0,"","","","",""})	

//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

oBrCrt:bLDblClick := {|| fMrcCorte( oBrCrt:nAt )}

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  _aBrw2[oBrCrt:nAt,01],If(_aBrw2[oBrCrt:nAT,02],_oOk,_oNo),;
							_aBrw2[oBrCrt:nAt,03],_aBrw2[oBrCrt:nAt,04],;
                            _aBrw2[oBrCrt:nAt,05],_aBrw2[oBrCrt:nAt,06],_aBrw2[oBrCrt:nAt,07],;
                            _aBrw2[oBrCrt:nAt,08],_aBrw2[oBrCrt:nAt,09],_aBrw2[oBrCrt:nAt,10],;
                            _aBrw2[oBrCrt:nAt,11],_aBrw2[oBrCrt:nAt,12],_aBrw2[oBrCrt:nAt,13],_aBrw2[oBrCrt:nAt,14]}}

oSay30      := TSay():New(015,012,{||"Notas:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
oSay31      := TSay():New(015,029,{|u| If(PCount()>0 , _cNotC := u,_cNotC)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay42      := TSay():New(015,090,{||"Selecionadas:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,034,008)
oSay43      := TSay():New(015,125,{|u| If(PCount()>0 , _cSelC := u,_cSelC)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oSay44      := TSay():New(015,050,{||"Visitas:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay45      := TSay():New(015,070,{|u| If(PCount()>0 , _cVisiCrt := u,_cVisiCrt)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oSay78      := TSay():New(015,138,{||"Total Selecionado:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay79      := TSay():New(015,183,{|u| If(PCount()>0 , _cTotSC := u,_cTotSC)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oFPG:Activate(,,,.T.)

SetKey(VK_F5,Nil)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออบฑฑ
ฑฑบPrograma  ณPROG01L   บAutor  ณMicrosiga           บ Data ณ  02/16/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    

Static Function Search

Local _cQuery := ""
Local _cAlias := GetNextAlias()
Local _cAlAux := GetNextAlias()
Local _cMunOr := ""

_nVencidas := 0

_nVencendo := 0 

_nAVencer  := 0

_nCntAgp   := 0 

If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())                 
EndIf 

_cQuery := " SELECT R_E_C_N_O_,ZZT_AREA,ZZT_VENC "
_cQuery += " FROM "+RetSqlName("ZZT") 
_cQuery += " WHERE  D_E_L_E_T_ != '*' "

If !Empty(_cStatus)
	_cQuery += " AND    ZZT_STATUS   = '"+Substr(_cStatus,1,1)+"'"
Else
	_cQuery += " AND    ZZT_STATUS   != 'P' "	
EndIf

Do Case
	
	Case !Empty(_cArea)
	   
		DbSelectArea("ZZQ")
		DbSetOrder(2)
		If DbSeek(xFilial("ZZQ")+AllTrim(_cArea))
		    
			_cStrAux := "" 
			_cQuery  += " AND   ZZT_BAIRRO IN ( "
		
			While !ZZQ->(Eof()) .And. AllTrim(ZZQ->ZZQ_FILIAL) + AllTrim(ZZQ->ZZQ_CODARE) ==  xFilial("ZZQ")+AllTrim(_cArea)
			
				_cStrAux += " '"+ZZQ->ZZQ_BAIRRO+"', " 	
			
				ZZQ->(DbSkip())
			EndDo
			
			_nTam    := Len(AllTrim(_cStrAux))-1
			
			_cString := ""
			
			_cString := SubStr(AllTrim(_cStrAux),1,_nTam)
			
			_cQuery  += _cString + ")" 
			
		EndIf
		
	Case !Empty(_cBairro)
	
		_cQuery += " AND   ZZT_BAIRRO = '"+_cBairro+"'"

EndCase

If !Empty(_cMun)
	
	If Select("_cAlAux") > 0
		("_cAlAux")->(DbClosearea())
	EndIf 
	
	_cQryAux := " SELECT CC2_MUN "   
	_cQryAux += " FROM "+RetSqlName("CC2")
	_cQryAux += " WHERE  D_E_L_E_T_ != '*' "
	_cQryAux += " AND    CC2_EST     = '"+_cEst+"'"
	_cQryAux += " AND    CC2_CODMUN  = '"+_cMun+"'"
	
	TcQuery _cQryAux New Alias _cAlAux

	_cQuery += " AND   ZZT_MUN   = '"+("_cAlAux")->CC2_MUN+"'"
	
EndIf

If !Empty(_cCBMedic)
	_cQuery += " AND ZZT_MEDICA = '"+UPPER(_cCBMedic)+"' "
EndIf		

_cQuery += "ORDER BY ZZT_VENC "

TcQuery _cQuery New Alias _cAlias 

If ("_cAlias")->R_E_C_N_O_ = 0
	Return
EndIf

_aRecno := {}

While !("_cAlias")->(Eof())

	aAdd(_aRecno,{("_cAlias")->R_E_C_N_O_,("_cAlias")->ZZT_VENC})

	("_cAlias")->(DbSkip())
EndDo

_aRecno := RegAgrup(_aRecno)

If Len(_aRecno) = 0
	Return
EndIf

DbSelectArea("ZZT")
DbGoTo(_aRecno[1,1])

_nPosCnt++ 

If     AllTrim(ZZT->ZZT_STATUS) == "A"
     _cSta := "Aberta"
ElseIf AllTrim(ZZT->ZZT_STATUS) == "L"
	 _cSta := "Liberada"
Else
	 _cSta := "Sobra"
EndIf

_cComp    := ZZT->ZZT_COMP 

_cDt    := ZZT->ZZT_VENC
_cDias  := _cDt - dDataBase 
_cPrazo := _cDias 

_cStatus2 := _cSta

_cLib     := ZZT->ZZT_LIBERA

_cNota    := ZZT->ZZT_NOTA         
_cData    := ZZT->ZZT_DATA  
_cVenc2   := ZZT->ZZT_VENC  
_cServic  := ZZT->ZZT_SERVIC
_cSubCat  := ZZT->ZZT_SUBCAT
_cMedida  := ZZT->ZZT_MEDIDA
_cInst    := ZZT->ZZT_INSTAL   
_cCliente := ZZT->ZZT_CLIENT                          
_cTel     := ZZT->ZZT_TEL     
_cMunicip := ZZT->ZZT_MUN                  
_cBair    := ZZT->ZZT_BAIRRO             
_cEnd     := ZZT->ZZT_END                                 
_cClasse  := ZZT->ZZT_CLASSE  
_cCarga   := ZZT->ZZT_CARGA   
_cProtI   := ZZT->ZZT_PROTIN  
_cProtE   := ZZT->ZZT_PROTEN  
_cFase    := ZZT->ZZT_FASE    
_cNeutro  := ZZT->ZZT_NEUTRO  
_cMltGet  := ZZT->ZZT_OBS
_cLat     := ZZT->ZZT_LAT
_cLong    := ZZT->ZZT_LONG

/*
If  _cComp  $ "CONDO|COND|CASTELO|ADM" .Or.  ; 
    _cCarga $ "41"                   //.Or.  ;
    //-> _cPref $ "27"		
	_cMedi := "INDIRETA"
Else
	_cMedi := "DIRETA"
EndIf 
*/

_cMedi := Upper(ZZT->ZZT_MEDIDA) 

//-> Pega o codigo da area
If Select("_cAlArea") > 0
	("_cAlArea")->(DbClosearea())
EndIf 
	
_cQryArea := ""
_cAlArea  := GetNextAlias()

_cQryArea := " SELECT ZZQ_CODARE "  
_cQryArea += " FROM "+RetSqlName("ZZQ")
_cQryArea += " WHERE  D_E_L_E_T_ != '*' "
_cQryArea += " AND    ZZQ_BAIRRO LIKE '"+_cBair+"%'"
    
TcQuery _cQryArea New Alias _cAlArea

_cArea2  := ("_cAlArea")->ZZQ_CODARE

// - ********************************** - \\

_cNotas  := cValToChar(Len(_aRecno))

oSay19:Refresh() 

_nContRg := 0

_cRecRg  := ""

For _nH  := 1 To Len(_aAgrup)

	_nRAgpCnt := 0 
	
	For _nJ   := 1 To Len(_aAgrup)
	
		If _aAgrup[_nH][2] = _aAgrup[_nJ][2] .And. _nRAgpCnt = 0 .And. !(cValToChar(_aAgrup[_nJ][2]) $ _cRecRg  )
		
			_nRAgpCnt := _aAgrup[_nH][2]
			_cRecRg   := cValToChar(_aAgrup[_nH][2])+"|"
			_nContRg++
		
		EndIf
		
	Next _nJ		

Next _nH 

_cVisit := cValToChar(Len(_aRecno)-_nContRg)

oSay15:Refresh()

_cAgrup  := cValToChar(_nContRg)

oSay11:Refresh() 

//-> Notas vencidas
_cQuery := "" 
_cAlAux := GetNextAlias()

For _nI := 1 To Len(_aRecno)

	If Select("_cAlAux") > 0
		("_cAlAux")->(DbClosearea())
	EndIf 

	_cQuery := " SELECT ZZT_VENC FROM "+RetSqlName("ZZT")
	_cQuery += " WHERE R_E_C_N_O_ = "+cValToChar(_aRecno[_nI,1])
	_cQuery += " AND D_E_L_E_T_  != '*' " 
	
	TcQuery _cQuery New Alias _cAlAux
	
	If dDataBase > SToD(("_cAlAux")->ZZT_VENC)
		
		_nVencidas++
		
	ElseIf dDataBase = SToD(("_cAlAux")->ZZT_VENC)
		
		_nVencendo++
		
	Else
		
		_nAVencer++
		
	EndIf

Next _nI

_nItem := 0

_nItem++

_cItem := cValToChar(_nItem)

oSay40:Refresh()

_nRecAgp := _aRecno[1,2]

_nCntAux := 0

For nM := 1 To Len(_aRecno)

	If _aRecno[nM,2] = _nRecAgp
				
		_nCntAux++  
				
	EndIf		

Next nM

_cAgrup2 := cValTochar(_aRecno[1,3])+"/"+cValToChar(_nCntAux)
oSay37:Refresh()

_cQuery := "" 
_cAlAux := GetNextAlias()

_cVenc     := cValToChar(_nVencidas)

_cVencendo := cValToChar(_nVencendo) 

_cAVenc    := cValToChar(_nAVencer)

oSay9:Refresh()

oSay13:Refresh()

oSay17:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRegBD  บAutor  ณMicrosiga           บ Data ณ  02/17/14     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

_nPosImg := 0

If Len(_aRecno) = 0
	Return
EndIf
 
If nOpc = 1
    
    //->Variavel possui a informa็ใo da posi็ใo atual do array _aRecno
    _nPosCnt++
	
	If  _nPosCnt > Len(_aRecno)
	
		_nPosCnt := Len(_aRecno)
		
		_nPos    := _nPosCnt
			
		_nRecno  := _aRecno[_nPos,1]		

	Else 
	
		_nPos   := _nPosCnt
			
		_nRecno := _aRecno[_nPos,1]
		
	EndIf
	
	_nRecAgp := _aRecno[_nPos,2]
	
	_nCntAux := 0

	For nM := 1 To Len(_aRecno)
	
		If _aRecno[nM,2] = _nRecAgp
					
			_nCntAux++  
					
		EndIf		
	
	Next nM

    _cAgrup2 := cValTochar(_aRecno[_nPos,3])+"/"+cValToChar(_nCntAux)
    oSay37:Refresh()	
	
	If _nItem < Len(_aRecno) 
	
		_nItem++
		
		_cItem := cValToChar(_nItem)
		
		oSay40:Refresh()
	
	EndIf
	
Else

	_nPosCnt--
	
	If _nPosCnt <=0
		_nPosCnt := 1
	EndIf
	
	_nPos    := _nPosCnt
		 
	_nRecno  := _aRecno[_nPos,1]

	_nRecAgp := _aRecno[_nPos,2]
	
	_nCntAux := 0

	For nM := 1 To Len(_aRecno)
	
		If _aRecno[nM,2] = _nRecAgp
					
			_nCntAux++  
					
		EndIf		
	
	Next nM

   _cAgrup2 := cValTochar(_aRecno[_nPos,3])+"/"+cValToChar(_nCntAux)
    
    oSay37:Refresh()	
	
	If _nItem > 1
	
		_nItem--
		
		_cItem := cValToChar(_nItem)
		
		oSay40:Refresh()
	
	EndIf

EndIf
	
If Select("_cAlAv") > 0
	("_cAlAv")->(DbCloseArea())
EndIf	
    
_cQuery := " SELECT * FROM "+RetSqlName("ZZT") 
_cQuery += " WHERE D_E_L_E_T_ != '*' "
_cQuery += " AND   R_E_C_N_O_  = "+cValToChar(_nRecno)+""

TcQuery _cQuery New Alias _cAlAv

If     AllTrim(("_cAlAv")->ZZT_STATUS) == "A"
     _cSta := "Aberta"
ElseIf AllTrim(("_cAlAv")->ZZT_STATUS) == "L"
	_cSta  := "Liberada"
Else
	_cSta  := "Sobra"
EndIf

_cMltGet   := ""

_cComp     := ("_cAlAv")->ZZT_COMP  

_cDtVenc := SToD(("_cAlAv")->ZZT_VENC)
_cDt     :=_cDtVenc 
_cDias   := _cDt - dDataBase 
_cPrazo  := _cDias 
     
_cStatus2  := _cSta 
_cLib      := ("_cAlAv")->ZZT_LIBERA
_cNota     := ("_cAlAv")->ZZT_NOTA         
_cData     := StoD(("_cAlAv")->ZZT_DATA)  
_cVenc2    := StoD(("_cAlAv")->ZZT_VENC)
_cServic   := ("_cAlAv")->ZZT_SERVIC
_cSubCat   := ("_cAlAv")->ZZT_SUBCAT
_cMedida   := ("_cAlAv")->ZZT_MEDIDA
_cInst     := ("_cAlAv")->ZZT_INSTAL   
_cCliente  := ("_cAlAv")->ZZT_CLIENT                          
_cTel      := ("_cAlAv")->ZZT_TEL     
_cMunicip  := ("_cAlAv")->ZZT_MUN                  
_cBair     := ("_cAlAv")->ZZT_BAIRRO             
_cEnd      := ("_cAlAv")->ZZT_END                                 
_cClasse   := ("_cAlAv")->ZZT_CLASSE  
_cCarga    := ("_cAlAv")->ZZT_CARGA   
_cProtI    := ("_cAlAv")->ZZT_PROTIN  
_cProtE    := ("_cAlAv")->ZZT_PROTEN  
_cFase     := ("_cAlAv")->ZZT_FASE    
_cNeutro   := ("_cAlAv")->ZZT_NEUTRO
_cLat      := ("_cAlAv")->ZZT_LAT
_cLong     := ("_cAlAv")->ZZT_LONG

//-> Pega o codigo da area
If Select("_cAlArea") > 0
	("_cAlArea")->(DbClosearea())
EndIf 
	
_cQryArea := ""
_cAlArea  := GetNextAlias()

_cQryArea := " SELECT ZZQ_CODARE "  
_cQryArea += " FROM "+RetSqlName("ZZQ")
_cQryArea += " WHERE  D_E_L_E_T_ != '*' "
_cQryArea += " AND    ZZQ_BAIRRO LIKE '"+_cBair+"%'"
    
TcQuery _cQryArea New Alias _cAlArea

_cArea2   := ("_cAlArea")->ZZQ_CODARE

// - ********************************** - \\

//-> Medi็ใo
If  _cComp  $ "CONDO|COND|CASTELO|ADM" .Or.  ; 
    _cCarga $ "41"                   //.Or.  ;
    //-> _cPref $ "27"		
	_cMedi := "INDIRETA"
Else
	_cMedi := "DIRETA"
EndIf

DbSelectArea("ZZT")
DbSetOrder(1)
If DbSeek(xFilial("ZZT")+("_cAlAv")->ZZT_CODIGO)

	nLines   := MLCount(ZZT->ZZT_OBS)
	nQtdeLin := 0			
	//-> Varre todas as linhas do texto e imprime			
	If nLines > 0
		
		For nX := 1 To nLines
		
			_cMltGet += MemoLine(ZZT->ZZT_OBS,120,nX)
		
		Next nX
		
	EndIf
	
EndIf

//-> checa se o registro esta selecionado
_nValNota := aScan(_aSelDa,{|x| AllTrim(x[1])  == AllTrim(_cNota)   })

If _nValNota > 0
	_lCkSel    := .T.
Else
	_lCkSel    := .F.	
EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPROG01L   บAutor  ณMicrosiga           บ Data ณ  02/22/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SelNotas

Local _nValNota := 0
Local _nValCli  := 0
Local _lRgAgrup := .F.
Local lAchou    := .F.
Local _nPos     := 0 

_nValNota := aScan(_aSelDa,{|x| AllTrim(x[1])  == AllTrim(_cNota)   })
_nValCli  := aScan(_aSelDa,{|x| AllTrim(x[13]) == AllTrim(_cCliente)}) 

If oFlP:nOption = 1 .And. _nValNota = 0 .Or. _nValCli = 0   
	
	If _lCkSel
	    
		_lCkSel := .F.
		
		aAdd(_aSelDa,{_cNota  , _cComp  , _cMltGet, _cPrazo, _cStatus2, _cLib ,  _cData   , _cVenc2,;      
		              _cServic, _cSubCat, _cMedida, _cInst , _cCliente, _cTel ,  _cMunicip, _cBair ,;                  
		              _cEnd   , _cClasse, _cCarga , _cProtI, _cProtE  , _cFase, _cNeutro  , _cMedi ,;
		              _cArea2 , _cLat   , _cLong })
	
		_nSelec++
		
		For _nX := 1 To Len(_aRecno)
		                    
			DbSelectArea("ZZT")
			DbGoTo(_aRecno[_nX][1])
		    //-> checo se o registro tem agrupamento
			If AllTrim(_cNota + _cCliente) == AllTrim(ZZT->ZZT_NOTA + ZZT->ZZT_CLIENT)
			
				_lRgAgrup := .T.
			    
			    If aScan(_aArrExc,{|x| x[1] = _aRecno[_nX][1] }) = 0 .And. aScan(_aArrExc,{|x| x[2] = _aRecno[_nX][2] }) = 0
		    		
		    		aAdd(_aArrExc,{_aRecno[_nX][1],_aRecno[_nX][2]})
		    		
		    		_nCntVst++
		    		
		    		Exit 	
			    	
		    	EndIf
			    	
		    EndIf	
		
		Next _nX
		
		If !_lRgAgrup
		
			_nCntVst++	
		
		EndIf
		
	Else
		
		_cNewStr := ""
		_cRecno  := ""
		_cOld    := ""
	
		For _nX := 1 To Len(_aRecno)
		                    
			DbSelectArea("ZZT")
			DbGoTo(_aRecno[_nX][1])
		
			If AllTrim(_cNota + _cCliente) == AllTrim(ZZT->ZZT_NOTA + ZZT->ZZT_CLIENT)
			
				If cValToChar(_aRecno[_nX][1]) $ _cStrRg 
			
					For _nY := 1 To Len(_cStrRg)
					
						If Substr(_cStrRg,_nY,1) == "|" 
						
							If _cRecno == cValToChar(_aRecno[_nX][1])
							
								_cRecno := ""
								_lRgAgrup := .T.
								_cOld := _cNewStr
								
							Else
							
								_cNewStr += _cRecno+"|"
								_cRecno  := "" 	 
							
							EndIf	
						
						Else
						
							_cRecno += Substr(_cStrRg,_nY,1) 
							
						EndIf	
					
					Next _nY
					
					_cStrRg := _cNewStr
		
					_cNewStr := ""
					_cRecno  := ""
					_cOld    := ""			
					
					For _nZ := 1 To Len(_cStrCVst)
					
						If Substr(_cStrCVst,_nZ,1) == "|" 
						
							If _cRecno == cValToChar(_aRecno[_nX][2])
							
								_cRecno := ""
								_nCntVst--
								_lRgAgrup := .T.
								_cOld := _cNewStr                  
								
							Else
							
								_cNewStr += _cRecno+"|"
								_cRecno  := "" 	 
							
							EndIf	
						
						Else
						
							_cRecno += Substr(_cStrCVst,_nZ,1) 
							
						EndIf	
					
					Next _nZ
					
					_cStrCVst := _cNewStr
				
				Else
				
					_lRgAgrup := .T.
				
				EndIf	
		    	
		    EndIf	
		
		Next _nX
	    
		If !_lRgAgrup
		
			_nCntVst--	
		
		EndIf
		
		For _nF := 1 To Len(_aSelDa)
		
			If AllTrim(_aSelDa[_nF,1]) == AllTrim(_cNota)
			
				_nPos := _nF 
				aDel(_aSelDa,_nPos)			
				aSize(_aSelDa,Len(_aSelDa)-1)			
				_nSelec--			 
			    Exit
			    
			EndIf
		
		Next _nF
	
	EndIf
	
	_cVisit2 := cValToChar(_nCntVst)
	oSay21:Refresh() 
	_cSel    := cValToChar(_nSelec)
	oSay19:Refresh()
	_cTotSel := cValToChar(_nSelec + _nSelC)
	oSay77:Refresh()      
	_cTotSC  := cValToChar(_nSelec + _nSelC)  	 
	oSay79:Refresh()

ElseIf oFlP:nOption = 1 .And. _lConfirm 

	_cNewStr := ""
	_cRecno  := ""
	_cOld    := ""
	
	For _nX := 1 To Len(_aRecno)
		                    
		DbSelectArea("ZZT")
		DbGoTo(_aRecno[_nX][1])
	
		If AllTrim(_cNota + _cCliente) == AllTrim(ZZT->ZZT_NOTA + ZZT->ZZT_CLIENT)
			
		    If aScan(_aArrExc,{|x| x[1] = _aRecno[_nX][1] }) > 0 .And. aScan(_aArrExc,{|x| x[2] = _aRecno[_nX][2] }) > 0
		    
		    	_nLin := aScan(_aArrExc,{|x| x[1] = _aRecno[_nX][1] }) 
				aDel(_aArrExc,_nLin)			
				aSize(_aArrExc,Len(_aArrExc)-1)		    	

			Else
				
				_lRgAgrup := .T.
				
			EndIf	
		    	
	    EndIf	
		
	Next _nX
	    
	If !_lRgAgrup
		
		_nCntVst--	
		
	EndIf
		
	For _nF := 1 To Len(_aSelDa)
		
		If AllTrim(_aSelDa[_nF,1]) == AllTrim(_cNota)
			
			_nPos := _nF 
			aDel(_aSelDa,_nPos)			
			aSize(_aSelDa,Len(_aSelDa)-1)			
			_nSelec--			 
		    Exit
			    
		EndIf
		
	Next _nF
	
	_cVisit2 := cValToChar(_nCntVst)
	oSay21:Refresh() 
	_cSel    := cValToChar(_nSelec)
	oSay19:Refresh()
	_cTotSel := cValToChar(_nSelec + _nSelC)
	oSay77:Refresh()      
	_cTotSC  := cValToChar(_nSelec + _nSelC)  	 
	oSay79:Refresh()

EndIf	

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณPROG02L  ณ Autor ณ                       ณ Data ณ           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLocacao   ณ                  ณContato ณ                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAplicacao ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista Resp.ณ  Data  ณ                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ  /  /  ณ                                               ณฑฑ
ฑฑณ              ณ  /  /  ณ                                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PROG02L

Private _cDTPrg  := dDataBase
//Private _cEquipe := Space(TamSx3("ZZS_CODIGO")[1])

If oFlP:nOption = 1 .And. Len(_aSelDa) = 0
	MsgAlert("Selecione uma nota para programar.","Alerta")
	Return
EndIf

_lConfirm := .F.

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Declara็ใo de Variaveis Private dos Objetos                          ฑฑ
ฑฑภภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

SetPrvt("oPrg","oPnlPrg","oGrpPrg","oSPrg","oSPrg1","oGEqp","oGPrg")

/*
ฑฑฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Definicao do Dialog e todos os seus componentes.                     ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

oPrg       := MSDialog():New( 092,232,351,718,"Dados para Programa็ใo",,,.F.,,,,,,.T.,,,.T. )
oPrg:bInit := {||EnchoiceBar(oPrg,{|| GrvPrg02()} ,{|| oPrg:End()},.F.,{})}

oPnlPrg    := TPanel():New( 017,004,"Programa็ใo",oPrg            ,,.F.,.F.,CLR_WHITE,CLR_BLUE,208,012,.T.,.F. )
oGrpPrg    := TGroup():New( 033,004,117,232," Equipes  ",oPrg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSPrg      := TSay():New( 045,016,{||"Funcionarios"},oGrpPrg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSPrg1     := TSay():New( 065,016,{||"Data"},oGrpPrg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGEqp      := TGet():New( 053,016,{|u| If(PCount()>0 ,_cEquipe:=u,_cEquipe)},oGrpPrg,136,010,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGEqp:cF3  := "ZZ4"

oGPrg      := TGet():New( 074,016,{|u| If(PCount()>0 ,_cDTPrg:=u,_cDTPrg)},oGrpPrg,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oPrg:Activate(,,,.T.)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออบฑฑ
ฑฑบPrograma  ณPROG01L   บAutor  ณMicrosiga           บ Data ณ  02/26/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GrvPrg02

Local _cAlias  := GetNextAlias()
Local _cQuery  := "" 
Local _cCodPrg := ""

If Select("_cAlias") > 0
	("_cAlias")->(DbCloseArea())
EndIf

_cQuery := " SELECT MAX(ZZU_CODIGO) AS ZZU_CODIGO FROM "+RETSQLNAME("ZZU") 

TcQuery _cQuery New Alias _cAlias

_cCodPrg := Iif(Empty(("_cAlias")->ZZU_CODIGO),"000001", Soma1(("_cAlias")->ZZU_CODIGO))

For _nG := 1 To Len(_aSelDa)

	If RecLock("ZZU",.T.)
	
		_cUndCon := Posicione("ZZT",1,xFilial("ZZT")+_aSelDa[_nG,1],"ZZT_UNDCON")
	
		_cNotPrg := _aSelDa[_nG,1]
		_cCliPrg := _aSelDa[_nG,13]  
	    
		ZZU->ZZU_FILIAL := xFilial("ZZU")
		ZZU->ZZU_CODIGO := _cCodPrg
		ZZU->ZZU_EQUIP  := _cEquipe
		ZZU->ZZU_UNDCON := _cUndCon
		ZZU->ZZU_MEDICA := _aSelDa[_nG,24]
		ZZU->ZZU_COMP   := _aSelDa[_nG,2]
		ZZU->ZZU_VENC   := _aSelDa[_nG,8]
		ZZU->ZZU_PRAZO  := cValToChar(_aSelDa[_nG,4])
		If Substr(_aSelDa[_nG,5],1,1) == "S" .Or. Substr(_aSelDa[_nG,5],1,1) == "L"
			ZZU->ZZU_STATUS := "A"
		Else
			ZZU->ZZU_STATUS := Substr(_aSelDa[_nG,5],1,1)
		EndIf		ZZU->ZZU_LIBERA := _aSelDa[_nG,6]
		ZZU->ZZU_AREA   := _aSelDa[_nG,25]
		ZZU->ZZU_NOTA   := _aSelDa[_nG,1]
		ZZU->ZZU_DATA   := _aSelDa[_nG,7]
		ZZU->ZZU_DATPRG := dDataBase
		ZZU->ZZU_IDUSER := __cUserID
		ZZU->ZZU_USER   := cUserName
		ZZU->ZZU_SERVIC := _aSelDa[_nG,9]
		ZZU->ZZU_MEDIDA := _aSelDa[_nG,11]
		ZZU->ZZU_SUBCAT := _aSelDa[_nG,10]
		ZZU->ZZU_INSTAL := _aSelDa[_nG,12]
		ZZU->ZZU_CLIENT := _aSelDa[_nG,13]
		ZZU->ZZU_TEL    := _aSelDa[_nG,14]
		ZZU->ZZU_MUN    := _aSelDa[_nG,15]
		ZZU->ZZU_BAIRRO := _aSelDa[_nG,16]
		ZZU->ZZU_END    := _aSelDa[_nG,17]
		ZZU->ZZU_CLASSE := _aSelDa[_nG,18]
		ZZU->ZZU_CARGA  := _aSelDa[_nG,19]
		ZZU->ZZU_LAT    := _aSelDa[_nG,26] 
		ZZU->ZZU_LONG   := _aSelDa[_nG,27]
		ZZU->ZZU_PROTIN := _aSelDa[_nG,20]
		ZZU->ZZU_PROTEN := _aSelDa[_nG,21]    
		ZZU->ZZU_FASE   := _aSelDa[_nG,22]
		ZZU->ZZU_NEUTRO := _aSelDa[_nG,23]
		ZZU->ZZU_OBS    := _aSelDa[_nG,3]
		ZZU->ZZU_TPARQ  := "1"
		ZZU->ZZU_ENVPDA := "N"
		
		MsUnlock()
	
	EndIf
	
	If Select("_cAlias") > 0
		("_cAlias")->(DbCloseArea())
	EndIf
	
	_cQuery := " SELECT ZZT_CODIGO "
	_cQuery += " FROM "+RETSQLNAME("ZZT")
	_cQuery += " WHERE  D_E_L_E_T_    != '*' "
	_cQuery += " AND    ZZT_NOTA       = '"+AllTrim(_cNotPrg)+"'" 
	_cQuery += " AND    ZZT_CLIENT LIKE  '"+AllTrim(_cCliPrg)+"%'"
	
	TcQuery _cQuery New Alias _cAlias
	
	_cCodigo := ("_cAlias")-> ZZT_CODIGO
	
	DbSelectArea("ZZT")
	DbSetOrder(1)
	If DbSeek(xFilial("ZZT")+_cCodigo)
	
		If RecLock("ZZT",.F.)
			
			ZZT->ZZT_STATUS := "P"
		
			MsUnlock()
			
		EndIf
		
		_lConfirm := .T.
	
	EndIf

Next _nG

GRVDADOS()

oPrg:End()
oFPG:End()

MsgInfo("Programa็ใo efetuada com sucesso!","Aten็ใo")
          
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIGCO501C  บAutor  ณMicrosiga           บ Data ณ  02/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMarca(_nLin) 

	_aBrw[_nLin,01] := !(_aBrw[_nLin,01])

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออบฑฑ
ฑฑบPrograma  ณPROG01L   บAutor  ณMicrosiga           บ Data ณ  02/16/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    

Static Function FSeaCort

Local _cQuery  := ""
Local _cAlias  := GetNextAlias()
Local _cAlAux  := GetNextAlias()
Local _cMunOr  := ""

SetKey(VK_F5 , Nil)
	
If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 
	
_cQuery := " SELECT ZZV_OBS AS OBS,* "
_cQuery += " FROM "+RetSqlName("ZZV") 
_cQuery += " WHERE  D_E_L_E_T_ != '*' "

If !Empty(_cDatI)
	_cQuery += " AND    ZZV_DATA    >= '"+Dtos(_cDatI)+"'"
EndIf	

If !Empty(_cDatF) 
	_cQuery += " AND    ZZV_DATLIM  <= '"+Dtos(_cDatF)+"'"
EndIf
	
_cQuery += " AND    ZZV_STATUS  != 'P'"
	
If !Empty(_cEstC) .And. !Empty(_cMunC)
	
	_cQuery += " AND    ZZV_EST    = '"+_cEstC+"'"
		
	If Select("_cAlAux") > 0
		("_cAlAux")->(DbClosearea())
	EndIf 
		
	_cQryAux := " SELECT CC2_MUN "   
	_cQryAux += " FROM "+RetSqlName("CC2")
	_cQryAux += " WHERE  D_E_L_E_T_ != '*' "
	_cQryAux += " AND    CC2_EST     = '"+_cEstC+"'"	
	_cQryAux += " AND    CC2_CODMUN  = '"+_cMunC+"'"
		
	TcQuery _cQryAux New Alias _cAlAux
		
	_cQuery += " AND    ZZV_MUN   = '"+("_cAlAux")->CC2_MUN+"'"
		
EndIf

//-> Filtro Tipo
Do Case

	Case SubStr(_cTipo,1,4) == "DAPE"
		
		_cQuery += " AND    ZZV_MEDIDA LIKE 'DAPE%'"	
	
	Case SubStr(_cTipo,1,4) == "DAPN"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'DAPN%'"
		
	Case SubStr(_cTipo,1,4) == "DCRN"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'DCRN%'"
	
	Case SubStr(_cTipo,1,4) == "SFAR"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'SFAR%'"
	
	Case SubStr(_cTipo,1,4) == "SFFP"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'SFFP%'"
		
	Case SubStr(_cTipo,1,4) == "SSRE"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'SSRE%'"
		
	Case SubStr(_cTipo,1,4) == "SCRE"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'SCRE%'"

	Case SubStr(_cTipo,1,4) == "REUR"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'REUR%'"
	
	Case SubStr(_cTipo,1,4) == "RENO"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'RENO%'"

	Case SubStr(_cTipo,1,4) == "REIC"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'REIC%'"
	
	Case SubStr(_cTipo,1,4) == "REIE"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'REIE%'"
	
	Case SubStr(_cTipo,1,4) == "REAJ"
	
		_cQuery += " AND    ZZV_MEDIDA LIKE 'REAJ%'"

EndCase	

//-> Filtro Ordenar
Do Case

	Case SubStr(_cOrd,1,1) == "B" .And. !Empty(_cOrd)
	
		_cQuery += "ORDER BY ZZV_BAIRRO"
	
	Case SubStr(_cOrd,1,1) == "T" .And. !Empty(_cOrd)
		
		_cQuery += "ORDER BY ZZV_SERVIC"

EndCase

TcQuery _cQuery New Alias _cAlias
	
_aBrw2 := {}
	
//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

//atualiza a grade de dados
oBrCrt:bLine      := {|| {  _aBrw2[oBrCrt:nAt,01],If(_aBrw2[oBrCrt:nAT,02],_oOk,_oNo),;
							_aBrw2[oBrCrt:nAt,03],_aBrw2[oBrCrt:nAt,04],;
                            _aBrw2[oBrCrt:nAt,05],_aBrw2[oBrCrt:nAt,06],_aBrw2[oBrCrt:nAt,07],;
                            _aBrw2[oBrCrt:nAt,08],_aBrw2[oBrCrt:nAt,09],_aBrw2[oBrCrt:nAt,10],;
                            _aBrw2[oBrCrt:nAt,11],_aBrw2[oBrCrt:nAt,12],_aBrw2[oBrCrt:nAt,13],_aBrw2[oBrCrt:nAt,14]}}
                             
_nQtdNotas := 0                              
	                              
DbSelectArea("_cAlias")
DbGoTop()
Count To _nQtdNotas
DbSelectArea("_cAlias")
DbGoTop()
	
_cNotC   := cValToChar(_nQtdNotas)
oSay31:Refresh()

_nLinha  := 0
	
While !("_cAlias")->(Eof())

		_nLinha++
		
		_nDeb    := 0
		_nTotDeb := 0
		
		//->Debitos
		If ("_cAlias")->ZZV_VALDB1 != 0
			_nDeb++
			_nTotDeb += ("_cAlias")->ZZV_VALDB1
		EndIf

		If ("_cAlias")->ZZV_VALDB2 != 0
			_nDeb++
			_nTotDeb += ("_cAlias")->ZZV_VALDB2
		EndIf

		If ("_cAlias")->ZZV_VALDB3 != 0
			_nDeb++
			_nTotDeb += ("_cAlias")->ZZV_VALDB3
		EndIf

		If ("_cAlias")->ZZV_VALDB4 != 0
			_nDeb++
			_nTotDeb += ("_cAlias")->ZZV_VALDB4
		EndIf
		
		If ("_cAlias")->ZZV_OUTDEB != 0
			_nTotDeb += ("_cAlias")->ZZV_OUTDEB
		EndIf
		
		_cObs := Posicione("ZZV",1,xFilial("ZZV")+("_cAlias")->ZZV_CODIGO,"ZZV_OBS")  				

		aAdd(_aBrw2,{_nLinha,;
		             .F.,;				
					 ("_cAlias")->ZZV_NOTA,;
					 SToD(("_cAlias")->ZZV_DATIMP),;
					 SToD(("_cAlias")->ZZV_DATLIM),;
					 SToD(("_cAlias")->ZZV_DATA),;
					 SubStr(AllTrim(("_cAlias")->ZZV_MEDIDA),1,4),;					
					 _nDeb,;			
					 _nTotDeb,;
					 ("_cAlias")->ZZV_SERVIC,;					 					 
					 ("_cAlias")->ZZV_MUN,;					
					 ("_cAlias")->ZZV_BAIRRO,; 
					 _cObs,;
					 ""})
				
	("_cAlias")->(DbSkip())
EndDo					
					
SetKey(VK_F5, bKeyF5)   
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRegAgrup  บAutor  ณMicrosiga           บ Data ณ  02/17/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RegAgrup(paRecno)

Local _aRecAgp := paRecno
Local _cAlAux  := GetNextAlias()
Local _cAlias  := GetNextAlias()
Local _aDel    := {} 
Local lAchou   := .F.
Local _aDados  := {}

_aAgrup := {}

_aRecno := {}

_nCntAgp := 0

For nJ  := 1 To Len(_aRecAgp)
	
	_nContRec := 0

	If Select("_cAlias") > 0
		("_cAlias")->(DbCloseArea())
	EndIf	
	    
	_cQuery := " SELECT ZZT_MUN, "  
	_cQuery += "        ZZT_BAIRRO, "	
	_cQuery += "        ZZT_END " 
	_cQuery += " FROM "+RetSqlName("ZZT") 
	_cQuery += " WHERE  D_E_L_E_T_ != '*' "
	_cQuery += " AND    R_E_C_N_O_  = "+cValToChar(_aRecAgp[nJ,1])+""
	
	TcQuery _cQuery New Alias _cAlias
	
	If Select("_cAlAux") > 0
		("_cAlAux")->(DbCloseArea())
	EndIf	
		    
	_cQryAux := " SELECT R_E_C_N_O_, " 
	_cQryAux += " ZZT_VENC "
	_cQryAux += " FROM "+RetSqlName("ZZT") 
	_cQryAux += " WHERE D_E_L_E_T_ != '*' "
	_cQryAux += " AND   ZZT_MUN    LIKE '"+AllTrim(("_cAlias")->ZZT_MUN)   +"%'"
	_cQryAux += " AND   ZZT_BAIRRO LIKE '"+AllTrim(("_cAlias")->ZZT_BAIRRO)+"%'"
	_cQryAux += " AND   ZZT_END    LIKE '"+AllTrim(("_cAlias")->ZZT_END)   +"%'"
	_cQryAux += " AND   R_E_C_N_O_ !=    "+cValToChar(_aRecAgp[nJ,1])+""
	_cQryAux += " AND   ZZT_STATUS != 'P'  "
	
	TcQuery _cQryAux New Alias _cAlAux
	
	_nValRec := _aRecAgp[nJ,1]
	
	If aScan(_aDados,{|x| x[1] = _nValRec }) = 0 .And. ("_cAlAux")->R_E_C_N_O_ > 0
					
		_nCntAgp++	

		While !("_cAlAux")->(Eof())
		
			_nContRec++
		
			aAdd(_aDados,{("_cAlAux")->R_E_C_N_O_,_aRecAgp[nJ,1],_nContRec,("_cAlAux")->ZZT_VENC})
	        lAchou := .T.
	        
   			aAdd(_aAgrup,{("_cAlAux")->R_E_C_N_O_,_aRecAgp[nJ,1],_nContRec,("_cAlAux")->ZZT_VENC})
	        
			("_cAlAux")->(DbSkip())
		EndDo
		
		If lAchou
			
			DbSelectArea("ZZT")
			DbGoTo(_aRecAgp[nJ,1])
			
			_nContRec++
			
		    aAdd(_aDados,{_aRecAgp[nJ,1],_aRecAgp[nJ,1],_nContRec,DToS(ZZT->ZZT_VENC)})
		    
    	    aAdd(_aAgrup,{_aRecAgp[nJ,1],_aRecAgp[nJ,1],0,DToS(ZZT->ZZT_VENC)})
		    
			_aDel  := {}
			_aDel  := aclone(_aDados)
			lAchou := .F.
			
		EndIf
	    
	ElseIf aScan(_aDados,{|x| x[1] = _nValRec }) = 0	

		_nContRec++
		
		DbSelectArea("ZZT")
		DbGoTo(_aRecAgp[nJ,1])
				
		_nRecno := Recno()
		aAdd(_aDados,{_aRecAgp[nJ,1],_aRecAgp[nJ,1],_nContRec++,DToS(ZZT->ZZT_VENC)}) 

	EndIf	
		
Next nJ 

aSort(_aDel,,,{|x,y|x[1] < y[1]})

For i := 1 To Len(_aDel)

	_nCont := 0
	
	_nValRec := _aDel[i,1]
    
    For _nJ := 1 To Len(_aDados)
		
 		If _aDados[_nJ,1] = _nValRec
 		    
 			_nCont++
 			
 			If _nCont > 1
 			
	 			aDel(_aDados,_nJ)
				aSize(_aDados,Len(_aDados)-1)
				Exit
 			
 			EndIf
			
		EndIf
		
	Next _nJ	

Next i

//aSize(_aRecAgp,Len(_aRecAgp)-Len(_aDel))
	
//aSort(_aRecAgp,,,{|x,y|x[1] < y[1]})

//aSort(_aAgrup,,,{|x,y|x[4] < y[4]})

Return(_aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSPPRG01L  บAutor  ณMicrosiga           บ Data ณ  04/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GRVDADOS

Local _cMedAux := ""

For i := 1 To Len(_aBrw2)
	
	If _aBrw2[i][2]
	
		DbSelectArea("ZZV")
		DbSetOrder(2)
		If DbSeek(xFilial("ZZV")+_aBrw2[i][3])
		
			_cMedAux := AllTrim(ZZV->ZZV_MEDIDA)
		
			If     Substr(_cMedAux,1,1) == "D"
				_cStrAux := AllTrim(PegaParametro(_cMedAux, '2', '-'))
			ElseIf Substr(_cMedAux,1,1) == "S"
				_cStrAux := AllTrim(PegaParametro(_cMedAux, '2', '-'))
			ElseIf Substr(_cMedAux,1,1) == "R"
				_cStrAux := Substr(_cMedAux,1,4)
			EndIf
		
			DbSelectArea("ZZU")
			If Reclock("ZZU ",.T.)
			
				ZZU->ZZU_FILIAL := xFilial("ZZU")
				ZZU->ZZU_CODIGO := ZZV->ZZV_CODIGO
				ZZU->ZZU_NOTA   := ZZV->ZZV_NOTA 
				ZZU->ZZU_EQUIP  := _cEquipe
				ZZU->ZZU_SERVIC := ZZV->ZZV_SERVIC
				ZZU->ZZU_SUBCAT := ZZV->ZZV_SUBCAT
				ZZU->ZZU_MEDIDA	:= ZZV->ZZV_MEDIDA
				ZZU->ZZU_CENTTR := ZZV->ZZV_CENTTR
				ZZU->ZZU_CLIENT := ZZV->ZZV_CLIENT				
				ZZU->ZZU_TEL    := ZZV->ZZV_TEL				
				ZZU->ZZU_DATPRG := dDataBase
				ZZU->ZZU_END    := ZZV->ZZV_END
				ZZU->ZZU_COMP   := ZZV->ZZV_COMP
				ZZU->ZZU_BAIRRO := ZZV->ZZV_BAIRRO
				ZZU->ZZU_STATUS := "A"
				ZZU->ZZU_MUN    := ZZV->ZZV_MUN
				ZZU->ZZU_DATA   := ZZV->ZZV_DATA
				ZZU->ZZU_HORDAT := ZZV->ZZV_HORDAT
				ZZU->ZZU_DATLIM := ZZV->ZZV_DATLIM
				ZZU->ZZU_HORLIM := ZZV->ZZV_HORLIM
				ZZU->ZZU_VENC   := ZZV->ZZV_DATLIM
				ZZU->ZZU_HORVEN := ZZV->ZZV_HORLIM				
				ZZU->ZZU_AGEND  := ZZV->ZZV_AGEND
				ZZU->ZZU_INSTAL := ZZV->ZZV_INSTAL
				ZZU->ZZU_ENDCOB := ZZV->ZZV_ENDCOB
				ZZU->ZZU_BAIRMU := ZZV->ZZV_BAIRMU
				ZZU->ZZU_DOCDB1 := ZZV->ZZV_DOCDB1
				ZZU->ZZU_VENC1  := ZZV->ZZV_VENC1
				ZZU->ZZU_VALDB1 := ZZV->ZZV_VALDB1
				ZZU->ZZU_DOCDB2 := ZZV->ZZV_DOCDB2
				ZZU->ZZU_VENC2  := ZZV->ZZV_VENC2
				ZZU->ZZU_VALDB2 := ZZV->ZZV_VALDB2
				ZZU->ZZU_DOCDB3 := ZZV->ZZV_DOCDB3
				ZZU->ZZU_VENC3  := ZZV->ZZV_VENC3
				ZZU->ZZU_VALDB3 := ZZV->ZZV_VALDB3
				ZZU->ZZU_DOCDB4 := ZZV->ZZV_DOCDB4
				ZZU->ZZU_VENC4  := ZZV->ZZV_VENC4
				ZZU->ZZU_VALDB4 := ZZV->ZZV_VALDB4
				ZZU->ZZU_OUTDEB := ZZV->ZZV_OUTDEB
				ZZU->ZZU_UNDCON := ZZV->ZZV_UNDCON
				ZZU->ZZU_CLASSE := ZZV->ZZV_CLASSE
				ZZU->ZZU_TIPO   := _cStrAux
				ZZU->ZZU_COORD  := ZZV->ZZV_COORD
				ZZU->ZZU_CARGA  := ZZV->ZZV_CARGA
				ZZU->ZZU_LAT    := ZZV->ZZV_LAT
				ZZU->ZZU_LONG   := ZZV->ZZV_LONG
				ZZU->ZZU_FASE   := ZZV->ZZV_FASE
				ZZU->ZZU_MEDID  := ZZV->ZZV_MEDID
				ZZU->ZZU_PREFIX := ZZV->ZZV_PREFIX
				ZZU->ZZU_SELO1  := ZZV->ZZV_SELO1
				ZZU->ZZU_SELO2  := ZZV->ZZV_SELO2
				ZZU->ZZU_SELO3  := ZZV->ZZV_SELO3
				ZZU->ZZU_TOTDEB := ZZV->ZZV_TOTDEB
				ZZU->ZZU_TPARQ  := "2"
				ZZU->ZZU_ENVPDA := "N"
				ZZU->ZZU_OBS    := ZZV->ZZV_OBS		
				
				MsUnlock()
					
			EndIf
				
			If Select("_cAlias") > 0
				("_cAlias")->(DbCloseArea())
			EndIf
				
			_cQuery := " SELECT ZZV_CODIGO "
			_cQuery += " FROM "+RETSQLNAME("ZZV")
			_cQuery += " WHERE D_E_L_E_T_    != '*' "
			_cQuery += " AND   ZZV_NOTA       = '"+ZZV->ZZV_NOTA+"'" 
			_cQuery += " AND   ZZV_CLIENT LIKE  '"+ZZV->ZZV_CLIENT+"%'"
			
			TcQuery _cQuery New Alias _cAlias
				
			_cCodigo := ("_cAlias")-> ZZV_CODIGO
				
			DbSelectArea("ZZV")
			DbSetOrder(1)
			If DbSeek(xFilial("ZZV")+_cCodigo)
					
				If RecLock("ZZV",.F.)
							
					ZZV->ZZV_STATUS := "P"
						
					MsUnlock()
						
				EndIf
					
			EndIf
		
		EndIf
				
	EndIf	
		
Next i

_aBrw2 := {}
	
//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

//atualiza a grade de dados
oBrCrt:bLine      :={|| {If(  _aBrw2[oBrCrt:nAT,01],_oOk,_oNo),;
                              _aBrw2[oBrCrt:nAt,02],_aBrw2[oBrCrt:nAt,03] ,_aBrw2[oBrCrt:nAt,04],;
                              _aBrw2[oBrCrt:nAt,05],_aBrw2[oBrCrt:nAt,06] ,_aBrw2[oBrCrt:nAt,07],;
                              _aBrw2[oBrCrt:nAt,08],_aBrw2[oBrCrt:nAt,09] ,_aBrw2[oBrCrt:nAt,10],;
                              _aBrw2[oBrCrt:nAt,11],_aBrw2[oBrCrt:nAt,12] ,_aBrw2[oBrCrt:nAt,13],;
                              _aBrw2[oBrCrt:nAt,14],_aBrw2[oBrCrt:nAt,15] ,_aBrw2[oBrCrt:nAt,16],;
                              _aBrw2[oBrCrt:nAt,17],_aBrw2[oBrCrt:nAt,18] ,_aBrw2[oBrCrt:nAt,19],;
                              _aBrw2[oBrCrt:nAt,20],_aBrw2[oBrCrt:nAt,21] ,_aBrw2[oBrCrt:nAt,22],;
                              _aBrw2[oBrCrt:nAt,23],_aBrw2[oBrCrt:nAt,24] ,_aBrw2[oBrCrt:nAt,25],;
                              _aBrw2[oBrCrt:nAt,26],_aBrw2[oBrCrt:nAt,27] ,_aBrw2[oBrCrt:nAt,28],;
                              _aBrw2[oBrCrt:nAt,29],_aBrw2[oBrCrt:nAt,30] ,_aBrw2[oBrCrt:nAt,31],;
							  _aBrw2[oBrCrt:nAt,32],_aBrw2[oBrCrt:nAt,33] ,_aBrw2[oBrCrt:nAt,34],;
                              _aBrw2[oBrCrt:nAt,35],_aBrw2[oBrCrt:nAt,36] ,_aBrw2[oBrCrt:nAt,37],;
                              _aBrw2[oBrCrt:nAt,38],_aBrw2[oBrCrt:nAt,39] ,_aBrw2[oBrCrt:nAt,40],;
                              _aBrw2[oBrCrt:nAt,41],_aBrw2[oBrCrt:nAt,42] ,_aBrw2[oBrCrt:nAt,43],;
                              _aBrw2[oBrCrt:nAt,44]}}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSPPRG01L  บAutor  ณMicrosiga           บ Data ณ  04/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MarkDes(pnOpc)

Local _nOpc := pnOpc 

Do Case

	Case _nOpc = 1
		
		_lCBAmb := .F.
		oCBox3:Refresh()
		
		_lCBCrt := .F.
		oCBox2:Refresh()
		
		oFld1:ShowPage(1)		
	
	Case _nOpc = 2
	
		_lCBAmb := .F.
		oCBox3:Refresh()
		
		_lCBLig := .F.
		oCBox1:Refresh()
		
		oFld1:ShowPage(2)		
	
	Case _nOpc = 3	

		_lCBCrt := .F.
		oCBox2:Refresh()
				
		_lCBLig := .F.
		oCBox1:Refresh()

EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIGCO501C  บAutor  ณMicrosiga           บ Data ณ  02/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMrcCorte(_nLin)

_aBrw2[_nLin,02] := !(_aBrw2[_nLin,02]) 

If oFlP:nOption = 2

	If _aBrw2[_nLin,02]
	
		_nSelC++
		_nVist2++	
		
		_cSelC := cValToChar(_nSelC)
		oSay43:Refresh()
		
		_cNotC := cValToChar(_nSelC) 
		oSay31:Refresh()
		
		_cVisiCrt := cValToChar(_nVist2)
		oSay45:Refresh()
		
		_cTotSel := cValToChar(_nSelec + _nSelC)
		oSay77:Refresh()      
		_cTotSC  := cValToChar(_nSelec + _nSelC)  	 
		oSay79:Refresh()
	
	Else
	
		_nSelC--
		_nVist2--
		
		_cSelC := cValToChar(_nSelC)
		oSay43:Refresh()
	
		_cNotC := cValToChar(_nSelC) 
		oSay31:Refresh()	
		
		_cVisiCrt := cValToChar(_nVist2)
		oSay45:Refresh()
	
		_cTotSel := cValToChar(_nSelec + _nSelC)
		oSay77:Refresh()      
		_cTotSC  := cValToChar(_nSelec + _nSelC)  	 
		oSay79:Refresh()	  
	
	EndIf
	
EndIf	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChecaArea   บAutor  ณMicrosiga         บ Data ณ  05/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ChecaArea

Local _lRet := .T.

DbSelectArea("ZZQ")
DbSetOrder(2)
If !DbSeek(xFilial("ZZQ")+AllTrim(_cArea))

	_lRet := .F.
	
EndIf 

Return _lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSFOLPGL   บAutor  ณMicrosiga           บ Data ณ  06/19/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PegaParametro(cString,cPosicao,cSep)

Local nx      := 0
Local cAux    := ""
Local cRetrun := ""

cAux   := cString;

For ny := 1 To Len(cString)

	If SubStr(cAux,ny,1) == cSep
		nx++
	EndIf
      
	If nx = Val(cPosicao) .And. SubStr(cAux,ny,1) <> cSep 
		cRetrun += SubStr(cAux,ny,1)
	EndIf
      
Next ny

Return(cRetrun)