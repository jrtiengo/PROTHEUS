#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
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
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PROG01L

Local   _cCBMedic  := ""
Local   _aMedic    := {"","Direta","Indireta"} 
Local   _aStatus   := {"","Liberadas","Aberta","Sobra"}
Local   oFontN     := TFont():New("Arial",,-10,,.T.)                                 
Private _cArea     := Space(TamSx3("ZZQ_CODARE")[1])
Private _cMun      := Space(TamSx3("ZZQ_MUN")[1])
Private _cBairro   := Space(TamSx3("ZZR_CODBAI")[1])
Private _cNotas    := "0"
Private _cStatus   := ""
Private _cVisit2   := "0"
Private _cVenc     := "0"
Private _cAgrup    := "0"
Private _cVencendo := "0"
Private _cVisit    := ""
Private _cAVenc    := "0"
Private _cSel      := "0"
Private _cVisit    := ""
Private _cMedi     := ""
Private _cComp     := ""
Private _cVenc2    := ""
Private _cPrazo    := ""
Private _cStatus2  := ""
Private _cLib      := ""
Private _cArea2    := ""
Private _cAgrup2   := ""
Private _cItem     := ""
Private _cNota     := ""
Private _cData     := ""
Private _cServic   := ""
Private _cMedida   := ""
Private _cSubCat   := ""
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
Private _nPosCnt   := 0
Private _nPosAgp   := 0 
Private _nCntAgp   := 0
Private _nTotAgp   := 0
Private _nNotas    := 0
Private _nAgrup    := 0
Private _aAgrup    := {}
Private _lCkSel    := .F.
Private _aSelDa    := {}
Private _aRegCnt   := {}
Private _aRecno    := {}
Private _nSelec    := 0
Private _nVencidas := 0
Private	_nVencendo := 0 
Private	_nAVencer  := 0
Private _nCntVst   := 0 

/*
±±ÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                         ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

SetPrvt("oDlg1" ,"oPanel1","oGrp1" ,"oSay1"  ,"oSay2" ,"oSay3" ,"oSay4" ,"oSay5" ,"oSay77","oGet1" ,"oGet2" ,"oGet3")
SetPrvt("oCBox2","oBtn1"  ,"oGet4" ,"oPanel2","oGrp2" ,"oSay6" ,"oSay7" ,"oSay8" ,"oSay9" ,"oSay10","oSay11","oMulti")
SetPrvt("oSay13","oSay14" ,"oSay15","oSay16" ,"oSay17","oSay18","oSay19","oSay20","oSay21","oBtn2" ,"oGrp3")
SetPrvt("oSay23","oSay24" ,"oSay25","oSay26" ,"oSay27","oSay28","oSay29","oSay30","oSay31","oSay32","oSay33")
SetPrvt("oSay35","oSay36" ,"oSay37","oSay38" ,"oSay39","oSay40","oSay41","oSay42","oSay43","oSay44","oSay45")
SetPrvt("oSay47","oSay48" ,"oSay49","oSay50" ,"oSay51","oSay52","oSay53","oSay54","oSay55","oSay56","oSay57")
SetPrvt("oSay59","oSay60" ,"oSay61","oSay62" ,"oSay63","oSay64","oSay65","oSay66","oSay67","oSay68","oSay69")
SetPrvt("oSay71","oSay72" ,"oSay73","oSay74" ,"oSay75","oSay76","oCBox3","oCBox4")

/*
ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/

oDlg1       := MSDialog():New(090,230,616,1362,"OS para Programação",,,.F.,,,,,,.T.,,,.T. )
oDlg1:bInit := {||EnchoiceBar(oDlg1,{|| PROG02L()} ,{|| oDlg1:End()},.F.,{})}

oPanel1     := TPanel():New(012,004,"Programação",oDlg1,,.F.,.F.,CLR_WHITE,CLR_BLUE,552,008,.T.,.F. )
oGrp1       := TGroup():New(020,004,059,556," Filtros para consulta ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1       := TSay():New(032,064,{||"Municipio:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay2       := TSay():New(032,136,{||"Area:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,015,008)
oSay3       := TSay():New(032,208,{||"Bairro:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay4       := TSay():New(032,276,{||"Medição:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay5       := TSay():New(032,336,{||"Status"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay77      := TSay():New(032,008,{||"Estado:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)

oGet1       := TGet():New(044,008,{|u| If(PCount()>0 ,_cEst:=u,_cEst)},oGrp1,037,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet1:cF3   := "12"

oGet2       := TGet():New(044,064,{|u| If(PCount()>0 ,_cMun:=u,_cMun)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet2:cF3   := "CC2CST" 

oGet3       := TGet():New(044,135,{|u| If(PCount()>0 ,_cArea:=u,_cArea)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet3:cF3   := "ZZQ"

oGet4       := TGet():New(044,207,{|u| If(PCount()>0 ,_cBairro:=u,_cBairro)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet4:cF3   := "CSBZZR"

oCBox1      := TComboBox():New(044,276,{|u| If(PCount()>0,_cCBMedic:=u,_cCBMedic)},_aMedic,052,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oCBox2      := TComboBox():New(044,336,{|u| If(PCount()>0,_cStatus:=u,_cStatus)},_aStatus,056,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
 
oPanel2     := TPanel():New(100,004,"",oDlg1,,.F.,.F.,,CLR_BLUE,552,009,.T.,.F. )
oGrp2       := TGroup():New(059,004,100,556," Opções ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

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

oBtn1       := TButton():New(042,403,"Procurar" ,oGrp1,{|| Search()},070,012,,,,.T.,,"",,,,.F. )
oBtn2       := TButton():New(075,403,"Programar",oGrp2,{|| PROG02L()},070,012,,,,.T.,,"",,,,.F. )

oGrp3       := TGroup():New(109,004,250,556,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay22      := TSay():New(120,008,{||"Medição:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)
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

oSay45      := TSay():New(129,192,{||"Serviço:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,021,008)
oSay46      := TSay():New(129,213,{|u| If(PCount()>0 , _cServic := u,_cServic)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,099,008)

oSay47      := TSay():New(139,008,{||"Medida:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
oSay48      := TSay():New(139,029,{|u| If(PCount()>0 , _cMedida := u,_cMedida)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,224,008)

oSay49      := TSay():New(148,008,{||"Sub Cat.:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,043,008)
oSay50      := TSay():New(148,032,{|u| If(PCount()>0 , _cSubCat := u,_cSubCat)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,240,008)

oSay51      := TSay():New(161,008,{||"Instalação:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,027,008)
oSay52      := TSay():New(161,036,{|u| If(PCount()>0 , _cInst := u,_cInst)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,100,008)

oSay53      := TSay():New(161,0118,{||"Cliente:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay54      := TSay():New(161,138,{|u| If(PCount()>0 , _cCliente := u,_cCliente)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,128,008)

oSay55      := TSay():New(161,252,{||"Telefones:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay56      := TSay():New(161,278,{|u| If(PCount()>0 , _cTel := u,_cTel)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,078,008)

oSay57      := TSay():New(170,008,{||"Municipio:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,025,008)
oSay58      := TSay():New(170,034,{|u| If(PCount()>0 , _cMunicip := u,_cMunicip)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,046,008)

oSay59      := TSay():New(170,0109,{||"Bairro:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
oSay60      := TSay():New(170,0129,{|u| If(PCount()>0 , _cBair := u,_cBair)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,052,008)

oSay61      := TSay():New(179,008,{||"Endereço:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)
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

oSay75      := TSay():New(200,008,{||"Observações:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,034,008)
oSay76      := TSay():New(242,008,{||"Prioridade:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,026,008)  

oBtn3       := TButton():New(200,403,"Voltar"  ,oGrp1,{||CRegBD(2) },070,012,,,,.T.,,"",,,,.F. )
oBtn4       := TButton():New(200,483,"Avançar" ,oGrp2,{||CRegBD(1) },070,012,,,,.T.,,"",,,,.F. )

oCBox3      := TCheckBox():New(120,468,""     ,{|u| If(PCount()>0,_lCkSel:=u,_lCkSel)},oGrp3,008,008,,{|| SelNotas()},,,CLR_BLACK,CLR_WHITE,,.T.,"",,)

oMulti      := TMultiGet():New(209,008,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrp3,388,032,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oCBox4      := TCheckBox():New(242,040,"",,oGrp3,007,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

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

Local _cQuery := ""
Local _cAlias := GetNextAlias()
Local _cAlAux := GetNextAlias()
Local _cMunOr := ""

If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 

_cQuery := " SELECT R_E_C_N_O_ "
_cQuery += " FROM "+RetSqlName("ZZT") 
_cQuery += " WHERE  D_E_L_E_T_ != '*' "
_cQuery += " AND    ZZT_STATUS  = '"+Substr(_cStatus,1,1)+"'"

Do Case

	Case !Empty(_cMun)
	
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
	
	Case !Empty(_cArea)
	   
		DbSelectArea("ZZQ")
		DbSetOrder(2)
		If DbSeek(xFilial("ZZQ")+AllTrim(_cArea))
		
			If Empty(_cMun)
				_cQuery += " AND   ZZT_MUN   = '"+ZZQ->ZZQ_MUN+"'"
			EndIf
			
		EndIf

EndCase

If !Empty(_cBairro) 
	_cQuery += " AND   ZZT_BAIRRO = '"+_cBairro+"'"
EndIf

_cQuery += "ORDER BY R_E_C_N_O_"

TcQuery _cQuery New Alias _cAlias

_aRecno := {}

While !("_cAlias")->(Eof())

	aAdd(_aRecno,{("_cAlias")->R_E_C_N_O_})

	("_cAlias")->(DbSkip())
EndDo

RegAgrup(@_aRecno)

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
_cPrazo   := ZZT->ZZT_PRAZO   
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

_cNotas   := cValToChar(Len(_aRecno) + Len(_aAgrup))

oSay19:Refresh() 

_cAgrup   := cValToChar(Len(_aAgrup))

oSay11:Refresh() 

_nContRg  := 0

_cRecRg   := ""

For _nH := 1 To Len(_aAgrup)

	_nRAgpCnt := 0 
	
	For _nJ   := 1 To Len(_aAgrup)
	
		If _aAgrup[_nH][2] = _aAgrup[_nJ][2] .And. _nRAgpCnt = 0 .And. !(cValToChar(_aAgrup[_nJ][2]) $ _cRecRg  )
		
			_nRAgpCnt := _aAgrup[_nH][2]
			_cRecRg   := cValToChar(_aAgrup[_nH][2])+"|"
			_nContRg++
		
		EndIf
		
	Next _nJ		

Next _nH 

_cVisit := cValToChar(Len(_aRecno) + _nContRg)

oSay15:Refresh()

//-> Notas vencidas
_cQuery   := "" 
_cAlAux   := GetNextAlias()

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

_cQuery := "" 
_cAlAux := GetNextAlias()

For _nJ := 1 To Len(_aAgrup)

	If Select("_cAlAux") > 0
		("_cAlAux")->(DbClosearea())
	EndIf 

	_cQuery := " SELECT ZZT_VENC FROM "+RetSqlName("ZZT")
	_cQuery += " WHERE R_E_C_N_O_ = "+cValToChar(_aAgrup[_nJ,1])
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

_cVenc     := cValToChar(_nVencidas)

_cVencendo := cValToChar(_nVencendo) 

_cAVenc    := cValToChar(_nAVencer)

oSay9:Refresh()

oSay13:Refresh()

oSay17:Refresh()

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

If nOpc = 1
    
    //->Variavel possui a informação da posição atual do array _aRecno
    _nPosCnt++
	
	If  _nPosCnt > Len(_aRecno)
	
		_nPosCnt := Len(_aRecno)
		
		If Len(_aAgrup) > 0
		
			_nPosAgp++
			
			If _nPosAgp > Len(_aAgrup)
			
				_nPosAgp := Len(_aAgrup)  
			
			EndIf
			
			_nPos   := _nPosAgp 
			
			_nRecno := _aAgrup[_nPos,1]
			
			//-> tratamento do label agrupamento
			
			_nRecAgp := _aAgrup[_nPos,2]
			
			_nCntAux := 0
	
			For nM := 1 To Len(_aAgrup)
			
				If _aAgrup[nM,2] = _nRecAgp
							
					_nCntAux++  
							
				EndIf		
			
			Next nM

		    _cAgrup2 := cValToChar(_aAgrup[_nPos,3])+"/"+cValToChar(_nCntAux)
		
		EndIf  
		
	Else 
	
		_nPos   := _nPosCnt
			
		_nRecno := _aRecno[_nPos,1]
		
	EndIf
	
Else
	
	If _nPosAgp > 0 

		_nPosAgp--
		
		If _nPosAgp = 0
		
			_nPos    := _nPosCnt
			 
			_nRecno  := _aRecno[_nPos,1]
			
			_cAgrup2 := ""
			
			_nTotAgp := _nCntAgp + 1
		
		Else
		
			_nPos    := _nPosAgp
			
			_nRecno  := _aAgrup[_nPos,1]

			//-> tratamento do label agrupamento
			
			_nRecAgp := _aAgrup[_nPos,2]
	
			_nCntAux := 0
	
			For nM := 1 To Len(_aAgrup)
			
				If _aAgrup[nM,2] = _nRecAgp
							
					_nCntAux++  
							
				EndIf		
			
			Next nM

		    _cAgrup2 := cValToChar(_aAgrup[_nPos,3])+"/"+cValToChar(_nCntAux)
		    
		EndIf
		
	Else
	
		_nPosCnt--
		
		If _nPosCnt <=0
			_nPosCnt := 1
		EndIf
		
		_nPos    := _nPosCnt
			 
		_nRecno  := _aRecno[_nPos,1]
	
	EndIf	

EndIf
	
If Select("_cAlAv") > 0
	("_cAlAv")->(DbCloseArea())
EndIf	
    
_cQuery := " SELECT * FROM "+RetSqlName("ZZT") 
_cQuery += " WHERE D_E_L_E_T_ != '*' "
_cQuery += " AND   R_E_C_N_O_  = '"+cValToChar(_nRecno)+"'"

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
_cPrazo    := ("_cAlAv")->ZZT_PRAZO   
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

//-> Medição
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RegAgrup  ºAutor  ³Microsiga           º Data ³  02/17/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RegAgrup(paRecno)

Local _aRecno := paRecno
Local _cAlAux := GetNextAlias()
Local _cAlias := GetNextAlias()
Local _aDel   := {} 
Local lAchou  := .F.

_aAgrup := {}

For nJ := 1 To Len(_aRecno)

	_nContRec := 0

	If Select("_cAlias") > 0
		("_cAlias")->(DbCloseArea())
	EndIf	
	    
	_cQuery := " SELECT * FROM "+RetSqlName("ZZT") 
	_cQuery += " WHERE D_E_L_E_T_ != '*' "
	_cQuery += " AND   R_E_C_N_O_  = '"+cValToChar(_aRecno[nJ,1])+"'"
	
	TcQuery _cQuery New Alias _cAlias
	
	If Select("_cAlAux") > 0
		("_cAlAux")->(DbCloseArea())
	EndIf	
		    
	_cQryAux := " SELECT * FROM "+RetSqlName("ZZT") 
	_cQryAux += " WHERE D_E_L_E_T_ != '*' "
	_cQryAux += " AND   ZZT_BAIRRO LIKE '"+AllTrim(("_cAlias")->ZZT_BAIRRO)+"%'"
	_cQryAux += " AND   ZZT_END    LIKE '"+AllTrim(("_cAlias")->ZZT_END)   +"%'"
	_cQryAux += " AND   R_E_C_N_O_ !=   '"+cValToChar(_aRecno[nJ,1])+"'"
		
	TcQuery _cQryAux New Alias _cAlAux
	
	_nValRec := _aRecno[nJ,1]
	
	If aScan(_aAgrup,{|x| x[1] = _nValRec }) = 0
	
		While !("_cAlAux")->(Eof())
		
			_nContRec++
		
			aAdd(_aAgrup,{("_cAlAux")->R_E_C_N_O_,_aRecno[nJ,1],_nContRec})
	        lAchou := .T.
	        
			("_cAlAux")->(DbSkip())
		EndDo
		
		_nContRec++
		
		If lAchou
		    aAdd(_aAgrup,{_aRecno[nJ,1],_aRecno[nJ,1],_nContRec++})
			_aDel  := {}
			_aDel  := aclone(_aAgrup)
			lAchou := .F.
		EndIf
		
	EndIf	
		
Next nJ

aSort(_aDel,,,{|x,y|x[1] < y[1]})

For i := 1 To Len(_aDel)
	
	_nValRec := _aDel[i,1]
    _nPos    := aScan(_aRecno,{|x| x[1] = _nValRec })
	aDel(_aRecno,_nPos)

Next i

aSize(_aRecno,Len(_aRecno)-Len(_aDel))
	
aSort(_aRecno,,,{|x,y|x[1] < y[1]})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PROG01L   ºAutor  ³Microsiga           º Data ³  02/22/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SelNotas

Local _nValNota := 0
Local _nValCli  := 0
Local _lRgAgrup := .F.
Local lAchou    := .F. 

_nValNota := aScan(_aSelDa,{|x| AllTrim(x[1])  == AllTrim(_cNota)   })
_nValCli  := aScan(_aSelDa,{|x| AllTrim(x[13]) == AllTrim(_cCliente)}) 

If _lCkSel

	aAdd(_aSelDa,{_cNota  , _cComp  , _cMltGet, _cPrazo, _cStatus2, _cLib ,  _cData   , _cVenc2,;      
	              _cServic, _cSubCat, _cMedida, _cInst , _cCliente, _cTel ,  _cMunicip, _cBair ,;                  
	              _cEnd   , _cClasse, _cCarga , _cProtI, _cProtE  , _cFase, _cNeutro  , _cMedi })

	_nSelec++
	
	For _nX := 1 To Len(_aAgrup)
	                    
		DbSelectArea("ZZT")
		DbGoTo(_aAgrup[_nX][1])
	    //-> checo se o registro tem agrupamento
		If AllTrim(_cNota + _cCliente) == AllTrim(ZZT->ZZT_NOTA + ZZT->ZZT_CLIENT)
		
			_lRgAgrup := .T.
		    
			//-> checo se qualquer um dos registros ja foi somado a visita
	    	If !(cValToChar(_aAgrup[_nX][2]) $ _cStrCVst) .And. !(cValToChar(_aAgrup[_nX][1]) $ _cStrRg)
		    	
	    		_cStrCVst += cValToChar(_aAgrup[_nX][2])+"|"
	    		_cStrRg   += cValToChar(_aAgrup[_nX][1])+"|" 
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

	For _nX := 1 To Len(_aAgrup)
	                    
		DbSelectArea("ZZT")
		DbGoTo(_aAgrup[_nX][1])
	
		If AllTrim(_cNota + _cCliente) == AllTrim(ZZT->ZZT_NOTA + ZZT->ZZT_CLIENT)
		
			If cValToChar(_aAgrup[_nX][1]) $ _cStrRg 
		
				For _nY := 1 To Len(_cStrRg)
				
					If Substr(_cStrRg,_nY,1) == "|" 
					
						If _cRecno == cValToChar(_aAgrup[_nX][1])
						
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
					
						If _cRecno == cValToChar(_aAgrup[_nX][2])
						
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
		    Exit
		    
		EndIf
	
	Next _nF
	
	aDel(_aSelDa,_nPos)
	
	aSize(_aSelDa,Len(_aSelDa)-1)
	
	_nSelec--	
	
EndIf

_cVisit2   := cValToChar(_nCntVst)
oSay21:Refresh() 

_cSel      := cValToChar(_nSelec)
oSay19:Refresh()

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PROG02L  ³ Autor ³                       ³ Data ³           ³±±
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
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PROG02L

Private _cDTPrg  := dDataBase
Private _cEquipe := Space(TamSx3("ZZS_RESP")[1])

If Len(_aSelDa) = 0
	MsgAlert("Não existem notas a programar, verifique!","Atenção")
	Return
EndIf

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                          ±±
±±ÀÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/
SetPrvt("oPrg","oPnlPrg","oGrpPrg","oSPrg","oSPrg1","oGEqp","oGPrg")

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

oPrg       := MSDialog():New( 092,232,351,718,"Dados para Programação",,,.F.,,,,,,.T.,,,.T. )
oPrg:bInit := {||EnchoiceBar(oPrg,{|| GrvPrg02()} ,{|| oPrg:End()},.F.,{})}

oPnlPrg    := TPanel():New( 017,004,"Programação",oPrg,,.F.,.F.,,,208,012,.T.,.F. )
oGrpPrg    := TGroup():New( 033,004,117,232," Equipes  ",oPrg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSPrg      := TSay():New( 045,016,{||"Funcionarios"},oGrpPrg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSPrg1     := TSay():New( 065,016,{||"Data"},oGrpPrg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGEqp      := TGet():New( 053,016,{|u| If(PCount()>0 ,_cEquipe:=u,_cEquipe)},oGrpPrg,136,010,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGEqp:cF3  := "ZZS"

oGPrg      := TGet():New( 074,016,{|u| If(PCount()>0 ,_cDTPrg:=u,_cDTPrg)},oGrpPrg,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oPrg:Activate(,,,.T.)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³PROG01L   ºAutor  ³Microsiga           º Data ³  02/26/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
	
		_cNotPrg := _aSelDa[_nG,1]
		_cCliPrg := _aSelDa[_nG,13]  
	
		ZZU->ZZU_CODIGO := _cCodPrg
		ZZU->ZZU_MEDICA := _aSelDa[_nG,24]
		ZZU->ZZU_COMP   := _aSelDa[_nG,2]
		ZZU->ZZU_VENC   := _aSelDa[_nG,8]
		ZZU->ZZU_PRAZO  := _aSelDa[_nG,4]
		ZZU->ZZU_STATUS := Substr(_aSelDa[_nG,5],1,1)
		ZZU->ZZU_LIBERA := _aSelDa[_nG,6]
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
		ZZU->ZZU_PROTIN := _aSelDa[_nG,20]
		ZZU->ZZU_PROTEN := _aSelDa[_nG,21]    
		ZZU->ZZU_FASE   := _aSelDa[_nG,22]
		ZZU->ZZU_NEUTRO := _aSelDa[_nG,23]
		ZZU->ZZU_OBS    := _aSelDa[_nG,3]
		ZZU->ZZU_TPARQ  := "1"
		
		MsUnlock()
	
	EndIf
	
	If Select("_cAlias") > 0
		("_cAlias")->(DbCloseArea())
	EndIf
	
	_cQuery := " SELECT ZZT_CODIGO "
	_cQuery += " FROM "+RETSQLNAME("ZZT")
	_cQuery += " WHERE D_E_L_E_T_    != '*' "
	_cQuery += " AND   ZZT_NOTA       = '"+AllTrim(_cNotPrg)+"'" 
	_cQuery += " AND   ZZT_CLIENT LIKE  '"+AllTrim(_cCliPrg)+"%'"
	
	TcQuery _cQuery New Alias _cAlias
	
	_cCodigo := ("_cAlias")-> ZZT_CODIGO
	
	DbSelectArea("ZZT")
	DbSetOrder(1)
	If DbSeek(xFilial("ZZT")+_cCodigo)
	
		If RecLock("ZZT",.F.)
			
			ZZT->ZZT_STATUS := "P"
		
			MsUnlock()
		
		EndIf
	
	EndIf

Next _nG

oPrg:End()
oDlg1:End()

MsgInfo("Programação efetuada com sucesso!","Atenção")

Return