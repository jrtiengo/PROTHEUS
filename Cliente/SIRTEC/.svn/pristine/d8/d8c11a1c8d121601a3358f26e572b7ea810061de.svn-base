#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"  
#INCLUDE "RWMake.CH"
#INCLUDE "TopConn.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฑฑ
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
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SPPRG01L

/*
ฑฑฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Declara็ใo de cVariable dos componentes                             ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

Local   nOpc1      := GD_INSERT//+GD_DELETE+GD_UPDATE
Local   nOpc2      := GD_INSERT//+GD_DELETE+GD_UPDATE
Local   aSizeAuto  := {}
Local   _aMedic    := {"Direta","Indireta"} 
Local   _aStatus   := {"Liberadas","Aberta","Sobra"}
Private _aBotao    := {{"BMPPERG", {|| Search()}, "Procurar"}}
Private bKeyF5     := {|| Search()}
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
Private _aTipo     := {"","DAPE","DAPN","SFAR","SFFP","SSRE","SCRE","REUR","RENO","REIC","REIE","REAJ"} 
Private aCoBrw1    := {}
Private aCoBrw2    := {}
Private aHoBrw1    := {}
Private aHoBrw2    := {}
Private _aRecno    := {}
Private _aAgrup    := {}
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

/*
ฑฑฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Declara็ใo de Variaveis Private dos Objetos                         ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/

SetPrvt("oDlg1","oGrp1","oGrp2","oGrp3","oGrp4","oCBox3","oCBox2","oCBox1","oPanel1","oFld1","oGrp6")
SetPrvt("oGrp5","oBrw1")

/*
ฑฑฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
ฑฑ Definicao do Dialog e todos os seus componentes.                    ฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฑฑ
*/ 

SetKey(VK_F5 , bKeyF5)

aSizeAuto   := MsAdvSize()
oDlg1       := MSDialog():New( aSizeAuto[7],0,aSizeAuto[6],aSizeAuto[5],"Programa็ใo",,,.F.,,,,,,.T.,,,.T. )

oDlg1:bInit := {||EnchoiceBar(oDlg1,{|| PROG02L()},{|| oDlg1:End()},.F.,_aBotao)}

oGrp1       := TGroup():New( 007,003,122,639," Filtro ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay07      := TSay():New(074,011,{||"Data Inicio:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet5       := TGet():New(086,011,{|u| If(PCount()>0 ,_cDatI:=u,_cDatI)},oGrp1,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSay08      := TSay():New(074,055,{||"Data Fim:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet6       := TGet():New(086,055,{|u| If(PCount()>0 ,_cDatF:=u,_cDatF)},oGrp1,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)

oSay09      := TSay():New(074,099,{||"Estado:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet7       := TGet():New(086,099,{|u| If(PCount()>0 ,_cEstC:=u,_cEstC)},oGrp1,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet7:cF3   := "12"

oSay10      := TSay():New(074,143,{||"Municipio:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet8       := TGet():New(086,143,{|u| If(PCount()>0 ,_cMunC:=u,_cMunC)},oGrp1,037,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oGet8:cF3   := "CC2CST"

oSay11      := TSay():New(074,187,{||"Ordenar"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBox3      := TComboBox():New(086,187,{|u| If(PCount()>0,_cOrd:=u,_cOrd)},_aOrd,056,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

oSay12      := TSay():New(074,250,{||"Tipo"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oCBox4      := TComboBox():New(086,250,{|u| If(PCount()>0,_cTipo:=u,_cTipo)},_aTipo,056,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

oGrp3       := TGroup():New(065,009,115,529," Corte",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )

oFld1       := TFolder():New(125,004,{"Corte"},{},oDlg1,,,,.T.,.F.,636,144,) 

oGrp6       := TGroup():New(004,004,124,628," Dados do corte ",oFld1:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
						      
_aBrw2 := {}

//Array com os campos da grade de dados
_aHeadCrt        := {" "        ,"Codigo"     ,"Nota"         ,"Servico"  ,"Sub.Cat."   ,"Medida"       ,"Cent.Trab.","Cliente"   ,"Endereco"     ,"Comp"       ,"Bairro","Municipio",;
                     "Data"     ,"Hora Data"  ,"Data Limite"  ,"Hora Lim.","Agendamento","Instalacao"   ,"End.Cob."  ,"Bairro/Mun","Num.Doc"      ,"Dt.Venc.1"  ,"Val.Doc.Deb.1",;
                     "Num.Doc.2","Dt.Venc.2"  ,"Val.Doc.Deb.2","Num.Doc.3","Dt.Venc.3"  ,"Val.Doc.Deb.3","Num.Doc.4" ,"Dt.Venc.4" ,"Val.Doc.Deb.4","Outros Deb.","Und.Cont.",;
                     "Classe"   ,"Coordenadas","Carga"        ,"Fase"     ,"Medidor"    ,"Prefixo"      ,"Selo 1"    ,"Selo 2"    ,"Selo 3"       ,"Total Debt."      }

//Criacao do objeto ListBox
oBrCrt      := TCBrowse():New(045,012,610,75,,_aHeadCrt,_aColsCrt,oGrp6,,,,,{||},,_oFC08,,,,,.F.,,.T.,,.F.,,,)

Aadd(_aBrw2,{.F. ,"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})	

//Seta o array da listbox
oBrCrt:SetArray(_aBrw2)  

oBrCrt:bLDblClick := {|| fMrcCorte( oBrCrt:nAt )}

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

oSay30      := TSay():New(015,012,{||"Notas:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
oSay31      := TSay():New(015,029,{|u| If(PCount()>0 , _cNotas := u,_cNotas)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

oSay42      := TSay():New(015,090,{||"Selecionadas:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,034,008)
oSay43      := TSay():New(015,125,{|u| If(PCount()>0 , _cSelC := u,_cSelC)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oSay44      := TSay():New(015,050,{||"Visitas:"},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay45      := TSay():New(015,070,{|u| If(PCount()>0 , _cVisit2 := u,_cVisit2)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,032,008)

oDlg1:Activate(,,,.T.)

SetKey(VK_F5,Nil)

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

Static Function Search

Local _cQuery  := ""
Local _cAlias  := GetNextAlias()
Local _cAlAux  := GetNextAlias()
Local _cMunOr  := ""

SetKey(VK_F5 , Nil)
	
If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 
	
_cQuery := " SELECT * "
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
                              
_nQtdNotas := 0                              
	                              
DbSelectArea("_cAlias")
DbGoTop()
Count To _nQtdNotas
DbSelectArea("_cAlias")
DbGoTop()
	
_cNotas   := cValToChar(_nQtdNotas)
oSay31:Refresh()
	
While !("_cAlias")->(Eof())

		aAdd(_aBrw2,{.F.,;
					("_cAlias")->ZZV_CODIGO,;
					("_cAlias")->ZZV_NOTA,;
   					("_cAlias")->ZZV_SERVIC,;
					("_cAlias")->ZZV_SUBCAT,;
					("_cAlias")->ZZV_MEDIDA,;	
					("_cAlias")->ZZV_CENTTR,;
					("_cAlias")->ZZV_CLIENT,;
					("_cAlias")->ZZV_END,;
					("_cAlias")->ZZV_COMP,;
					("_cAlias")->ZZV_BAIRRO,;
					("_cAlias")->ZZV_MUN,;
					("_cAlias")->ZZV_DATA,;
					("_cAlias")->ZZV_HORDAT,;
					("_cAlias")->ZZV_DATLIM,;
					("_cAlias")->ZZV_HORLIM,;
					("_cAlias")->ZZV_AGEND,;
					("_cAlias")->ZZV_INSTAL,;
					("_cAlias")->ZZV_ENDCOB,;
					("_cAlias")->ZZV_BAIRMU,;
					("_cAlias")->ZZV_DOCDB1,;
					("_cAlias")->ZZV_VENC1,;
					("_cAlias")->ZZV_VALDB1,;
					("_cAlias")->ZZV_DOCDB2,;
					("_cAlias")->ZZV_VENC2,;
					("_cAlias")->ZZV_VALDB2,;
					("_cAlias")->ZZV_DOCDB3,;
					("_cAlias")->ZZV_VENC3,;
					("_cAlias")->ZZV_VALDB3,;
					("_cAlias")->ZZV_DOCDB4,;
					("_cAlias")->ZZV_VENC4,;
					("_cAlias")->ZZV_VALDB4,;
					("_cAlias")->ZZV_OUTDEB,;
					("_cAlias")->ZZV_UNDCON,;
					("_cAlias")->ZZV_CLASSE,;
					("_cAlias")->ZZV_COORD,;
					("_cAlias")->ZZV_CARGA,;
					("_cAlias")->ZZV_FASE,;
					("_cAlias")->ZZV_MEDID,;
					("_cAlias")->ZZV_PREFIX,;
					("_cAlias")->ZZV_SELO1,;
					("_cAlias")->ZZV_SELO2,;
					("_cAlias")->ZZV_SELO3,;
					("_cAlias")->ZZV_TOTDEB})
								
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

_aAgrup := {}

For nJ := 1 To Len(_aRecAgp)

	_nContRec := 0

	If Select("_cAlias") > 0
		("_cAlias")->(DbCloseArea())
	EndIf	
	    
	_cQuery := " SELECT * FROM "+RetSqlName("ZZT") 
	_cQuery += " WHERE D_E_L_E_T_ != '*' "
	_cQuery += " AND   R_E_C_N_O_  = '"+cValToChar(_aRecAgp[nJ,1])+"'"
	
	TcQuery _cQuery New Alias _cAlias
	
	If Select("_cAlAux") > 0
		("_cAlAux")->(DbCloseArea())
	EndIf	
		    
	_cQryAux := " SELECT * FROM "+RetSqlName("ZZT") 
	_cQryAux += " WHERE D_E_L_E_T_ != '*' "
	_cQryAux += " AND   ZZT_BAIRRO LIKE '"+AllTrim(("_cAlias")->ZZT_BAIRRO)+"%'"
	_cQryAux += " AND   ZZT_END    LIKE '"+AllTrim(("_cAlias")->ZZT_END)   +"%'"
	_cQryAux += " AND   R_E_C_N_O_ !=   '"+cValToChar(_aRecAgp[nJ,1])+"'"
		
	TcQuery _cQryAux New Alias _cAlAux
	
	_nValRec := _aRecAgp[nJ,1]
	
	If aScan(_aAgrup,{|x| x[1] = _nValRec }) = 0
	
		While !("_cAlAux")->(Eof())
		
			_nContRec++
		
			aAdd(_aAgrup,{("_cAlAux")->R_E_C_N_O_,_aRecAgp[nJ,1],_nContRec})
	        lAchou := .T.
	        
			("_cAlAux")->(DbSkip())
		EndDo
		
		_nContRec++
		
		If lAchou
		    aAdd(_aAgrup,{_aRecAgp[nJ,1],_aRecAgp[nJ,1],_nContRec++})
			_aDel  := {}
			_aDel  := aclone(_aAgrup)
			lAchou := .F.
		EndIf
		
	EndIf	
		
Next nJ

aSort(_aDel,,,{|x,y|x[1] < y[1]})

For i := 1 To Len(_aDel)
	
	_nValRec := _aDel[i,1]
    _nPos    := aScan(_aRecAgp,{|x| x[1] = _nValRec })
	aDel(_aRecAgp,_nPos)

Next i

aSize(_aRecAgp,Len(_aRecAgp)-Len(_aDel))
	
aSort(_aRecAgp,,,{|x,y|x[1] < y[1]})

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
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
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function PROG02L

Private _cDTPrg  := dDataBase
Private _cEquipe := Space(TamSx3("ZZS_RESP")[1])

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
oPrg:bInit := {||EnchoiceBar(oPrg,{|| GRVDADOS()} ,{|| oPrg:End()},.F.,{})}

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

Static Function GRVDADOS

oPrg:End()

For i := 1 To Len(_aBrw2)
	
	If _aBrw2[i][1]	
	
		_cNotPrg := _aBrw2[i][3]
		_cCliPrg := _aBrw2[i][8]
		
		DbSelectArea("ZZU")
		If Reclock("ZZU ",.T.)
		
			ZZU->ZZU_CODIGO := _aBrw2[i][2]
			ZZU->ZZU_NOTA   := _aBrw2[i][3]
			ZZU->ZZU_SERVIC := _aBrw2[i][4]
			ZZU->ZZU_SUBCAT := _aBrw2[i][5]
			ZZU->ZZU_MEDIDA	:= _aBrw2[i][6]
			ZZU->ZZU_CENTTR := _aBrw2[i][7]
			ZZU->ZZU_CLIENT := _aBrw2[i][8]
			ZZU->ZZU_END    := _aBrw2[i][9]
			ZZU->ZZU_COMP   := _aBrw2[i][10]
			ZZU->ZZU_BAIRRO := _aBrw2[i][11]
			ZZU->ZZU_MUN    := _aBrw2[i][12]
			ZZU->ZZU_DATA   := SToD(_aBrw2[i][13])
			ZZU->ZZU_HORDAT := _aBrw2[i][14]
			ZZU->ZZU_DATLIM := SToD(_aBrw2[i][15])
			ZZU->ZZU_HORLIM := _aBrw2[i][16]
			ZZU->ZZU_AGEND  := _aBrw2[i][17]
			ZZU->ZZU_INSTAL := _aBrw2[i][18]
			ZZU->ZZU_ENDCOB := _aBrw2[i][19]
			ZZU->ZZU_BAIRMU := _aBrw2[i][20]
			ZZU->ZZU_DOCDB1 := _aBrw2[i][21]
			ZZU->ZZU_VENC1  := SToD(_aBrw2[i][22])
			ZZU->ZZU_VALDB1 := _aBrw2[i][23]
			ZZU->ZZU_DOCDB2 := _aBrw2[i][24]
			ZZU->ZZU_VENC2  := SToD(_aBrw2[i][25])
			ZZU->ZZU_VALDB2 := _aBrw2[i][26]
			ZZU->ZZU_DOCDB3 := _aBrw2[i][27]
			ZZU->ZZU_VENC3  := SToD(_aBrw2[i][28])
			ZZU->ZZU_VALDB3 := _aBrw2[i][29]
			ZZU->ZZU_DOCDB4 := _aBrw2[i][30]
			ZZU->ZZU_VENC4  := SToD(_aBrw2[i][31])
			ZZU->ZZU_VALDB4 := _aBrw2[i][32]
			ZZU->ZZU_OUTDEB := _aBrw2[i][33]
			ZZU->ZZU_UNDCON := _aBrw2[i][34]
			ZZU->ZZU_CLASSE := _aBrw2[i][35]
			ZZU->ZZU_COORD  := _aBrw2[i][36]
			ZZU->ZZU_CARGA  := _aBrw2[i][37]
			ZZU->ZZU_FASE   := _aBrw2[i][38]
			ZZU->ZZU_MEDID  := _aBrw2[i][39]
			ZZU->ZZU_PREFIX := _aBrw2[i][40]
			ZZU->ZZU_SELO1  := _aBrw2[i][41]
			ZZU->ZZU_SELO2  := _aBrw2[i][42]
			ZZU->ZZU_SELO3  := _aBrw2[i][43]
			ZZU->ZZU_TOTDEB := _aBrw2[i][44]
			
			ZZU->ZZU_TPARQ  := "2"
			
			MsUnlock()
				
		EndIf
			
		If Select("_cAlias") > 0
			("_cAlias")->(DbCloseArea())
		EndIf
			
		_cQuery := " SELECT ZZV_CODIGO "
		_cQuery += " FROM "+RETSQLNAME("ZZV")
		_cQuery += " WHERE D_E_L_E_T_    != '*' "
		_cQuery += " AND   ZZV_NOTA       = '"+AllTrim(_cNotPrg)+"'" 
		_cQuery += " AND   ZZV_CLIENT LIKE  '"+AllTrim(_cCliPrg)+"%'"
		
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

_aBrw2[_nLin,01] := !(_aBrw2[_nLin,01]) 

If _aBrw2[_nLin,01]

	_nSelC++
	_nVist2++	
	
	_cSelC := cValToChar(_nSelC)
	oSay43:Refresh() 
	
	_cVisit2 := cValToChar(_nVist2)
	oSay45:Refresh() 

Else

	_nSelC--
	_nVist2--
	
	_cSelC := cValToChar(_nSelC)
	oSay43:Refresh()
	
	_cVisit2 := cValToChar(_nVist2)
	oSay45:Refresh()  

EndIf

Return