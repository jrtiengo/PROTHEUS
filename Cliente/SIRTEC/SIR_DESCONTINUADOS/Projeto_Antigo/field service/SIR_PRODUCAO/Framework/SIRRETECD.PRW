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

User Function SIRRETECD

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de cVariable dos componentes                                ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/ 

Local   _aCbStEx    := {"Concluida","Workflow Cleidiane","Workflow Marcia","Workflow ABF","Pular"}
Local   _aCbStRj    := {"Concluida","Workflow Cleidiane","Workflow Marcia","Workflow ABF","Pular"}
Local   nOpc        := GD_INSERT+GD_DELETE+GD_UPDATE
Local   _cImg       := ""
Private oBmp1
Private _cGNota     := Space(TamSx3("ZZT_NOTA")[1])       
Private _cLacre     := ""
Private _cCbStEx    := "" 
Private _cCbStRj    := ""  
Private _cData      := dDataBase
Private _cEst       := Space(TamSx3("ZZQ_EST")[1])
Private _cMun       := Space(TamSx3("ZZQ_MUN")[1])
//Private _cEquipe    := Space(TamSx3("ZZS_CODIGO")[1])
Private _cEquipe   := Space(TamSx3("ZZ4_CODTEC")[1])
Private aRCoBrw     := {}
Private aRHBrw      := {} 
Private aECoBrw     := {}
Private aEHBrw      := {} 
Private _aRecno     := {}
Private noBrw1      := 0
Private noBrw2      := 0 
Private _nPosCnt    := 0
Private _nPosImg    := 0       
Private _dData		:= "Data: XX/XX/XXXX"
Private _cEquipe	:= "Equipe: XXXXXX "
Private _cStatus	:= "Status: Não Programada"
Private _cLocal		:= ""

//-> Rejeiçao
Private _cRNota     := Space(TamSX3("ZZW_NOTA")[1])
Private _cRNome     := Space(TamSX3("ZZW_CLIENT")[1])
Private _cREnd      := Space(TamSX3("ZZW_END")[1])
Private _cRComp     := Space(TamSX3("ZZW_COMP")[1])
Private _cRMun      := Space(TamSX3("ZZW_MUN")[1])
Private _cRBairro   := Space(TamSX3("ZZW_BAIRRO")[1])
Private _cRTel      := Space(TamSX3("ZZW_NOTA")[1])
Private _cRServ     := Space(TamSX3("ZZW_SERVICE")[1])
Private _cRSubCat   := Space(TamSX3("ZZW_SUBCAT")[1])
Private _cRMedida   := Space(TamSX3("ZZW_MEDIDA")[1])
Private _cRStatu    := Space(TamSX3("ZZW_STATU")[1])
Private _cRStaVa    := Space(TamSX3("ZZW_STAVA")[1])
Private _cRFunc     := ""
Private _cRDatHor   := ""
Private _cRStatus   := ""
Private _cRObs      := ""    
//-> Execução
Private _cENota     := ""
Private _cENome     := ""
Private _cEEnd      := ""
Private _cEComp     := ""
Private _cEMun      := ""
Private _cEBairro   := ""
Private _cETel      := ""
Private _cEServ     := ""
Private _cESubCat   := ""
Private _cEMedida   := ""
Private _cEStatu    := ""
Private _cEStaVa    := ""
Private _cEFunc     := ""
Private _cEDatHor   := ""
Private _cEStatus   := ""
Private _cEMedIn    := ""
Private _cEMedRet   := ""
Private _cEMedLoc   := ""
Private _cEMedV1    := ""
Private _cELeitIns  := ""
Private _cRELeitRet := ""
Private _cELeitLoc  := ""
Private _cEMedV2    := ""
Private _cETrafo    := ""
Private _cERaRet    := ""
Private _cEQRamRet  := ""
Private _cEObs      := ""

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/   

SetPrvt("oDlg1" ,"oSay27","oSay28","oSay29","oSay30","oSay31","oSay32" ,"oPanel1","oGrp1" ,"oSay1" ,"oSay2")
SetPrvt("oSay4" ,"oGet1" ,"oGet2" ,"oGet3" ,"oGet4" ,"oCBox1","oBtn1"  ,"oPanel2","oGrp2" ,"oSay5" ,"oSay6")
SetPrvt("oSay9" ,"oSay10","oSay11","oSay12","oSay13","oSay14","oSay15" ,"oSay16" ,"oSay17","oSay18","oSay19")
SetPrvt("oSay21","oSay22","oSay23","oSay24","oSay25","oSay26","oPanel3","oPanel4","oBrw1" ,"oSay7")

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

aSizeAuto   := MsAdvSize()

oDlg1       := MSDialog():New(aSizeAuto[7],0,aSizeAuto[6],aSizeAuto[5],"Retorno",,,.F.,,,,,,.T.,,,.T.)
//oDlg1:bInit := {||EnchoiceBar(oDlg1, {|| oDlg1:End()},.F.,{})}
oFlP        := TFolder():New(042,004,{"Rejeitadas","Execução"},{},oDlg1,,,,.T.,.F.,650,223,)

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Dados aba Rejeitada                                                    ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/
//Filtro
oGrp1       := TGroup():New(004,004,040,182," Filtro ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay5       := TSay():New(010,016,{||"Nota:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)   
oGet5       := TGet():New(020,015,{|u| If(PCount()>0 ,_cGNota:=u,_cGNota)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oBtn1       := TButton():New(018,082,"Procurar",oGrp1,{|| Search()},072,012,,,,.T.,,"",,,,.F. )

//Programação
oGrp6       := TGroup():New(004,184,040,654," Programação ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay1       := TSay():New(020,186,{|u| If(PCount()>0 ,_cStatus:=u,_cStatus)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
oSay2       := TSay():New(020,291,{|u| If(PCount()>0 ,_cEquipe:=u,_cEquipe)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
oSay3       := TSay():New(020,392,{|u| If(PCount()>0 ,_dData:=u,_dData)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
oSay4       := TSay():New(020,492,{|u| If(PCount()>0 ,_cLocal:=u,_cLocal)},oGrp6,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)

//oGet1       := TGet():New(020,015,{|u| If(PCount()>0 ,_cData:=u,_cData)},oGrp1,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
//oGet2       := TGet():New(020,082,{|u| If(PCount()>0 ,_cEst :=u,_cEst)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
//oGet2:cF3   := "12"
//oGet3       := TGet():New(020,146,{|u| If(PCount()>0 ,_cMun:=u,_cMun)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
//oGet3:cF3   := "CC2CST"
//oGet4       := TGet():New(020,216,{|u| If(PCount()>0 ,_cEquipe:=u,_cEquipe)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
//oGet4:cF3   := "ZZS"
//oGet4:cF3   := "CSTZZ4"



//oCBox1      := TComboBox():New(020,290,,,072,010,oGrp1,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )

oBtn2       := TButton():New(0265,001,"Foto1" ,oGrp1,{|| AltImg(1)},072,012,,,,.T.,,"",,,,.F. )
oBtn3       := TButton():New(0265,073,"Foto2" ,oGrp1,{||AltImg(2) },072,012,,,,.T.,,"",,,,.F. )
oBtn4       := TButton():New(0265,145,"Foto3" ,oGrp1,{||AltImg(3) },072,012,,,,.T.,,"",,,,.F. )
oPanel2     := TPanel():New(003,001,,oFlP:aDialogs[1],,.F.,.F.,CLR_WHITE,CLR_BLUE,647,008,.T.,.F. )
oGrp2       := TGroup():New(013,001,061,647,"",oFlP:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )

oSay5       := TSay():New(017,003,{||"Nome:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay6       := TSay():New(017,027,{|u| If(PCount()>0 , _cRNome := u,_cRNome)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay7       := TSay():New(025,003,{||"Endereço:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay8       := TSay():New(025,035,{|u| If(PCount()>0 , _cREnd := u,_cREnd)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay19      := TSay():New(025,187,{||"Complemento:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
oSay20      := TSay():New(025,224,{|u| If(PCount()>0 , _cRComp := u,_cRComp)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oSay9       := TSay():New(033,003,{||"Municipio:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay10      := TSay():New(033,035,{|u| If(PCount()>0 , _cRMun := u,_cRMun)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay33      := TSay():New(033,110,{||"Bairro:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oSay34      := TSay():New(033,130,{|u| If(PCount()>0 , _cRBairro := u,_cRBairro)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,090,008)
ooSay23     := TSay():New(033,203,{||"Telefone:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay24      := TSay():New(033,229,{|u| If(PCount()>0 , _cRTel := u,_cRTel)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,037,008)
oSay11      := TSay():New(039,003,{||"Serviço:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oSay12      := TSay():New(039,031,{|u| If(PCount()>0 , _cRServ := u,_cRServ)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay13      := TSay():New(047,003,{||"Subcategoria:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)
oSay14      := TSay():New(047,044,{|u| If(PCount()>0 , _cRSubCat := u,_cRSubCat)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,206,008)
oSay25      := TSay():New(047,230,{||"Medida:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)
oSay26      := TSay():New(047,250,{|u| If(PCount()>0 , _cRMedida := u,_cRMedida)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,206,008)
oSay15      := TSay():New(053,003,{||"Status Atual:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,031,008)
oSay16      := TSay():New(053,041,{|u| If(PCount()>0 , _cRStatu := u,_cRStatu)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,094,008)
oSay17      := TSay():New(053,149,{||"Status VA:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,027,008)
oSay18      := TSay():New(053,176,{|u| If(PCount()>0 , _cRStaVa := u,_cRStaVa)},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,084,008)
//oPanel3     := TPanel():New(062,001,"Dados Serviço",oFlP:aDialogs[1],,.F.,.F.,CLR_WHITE,CLR_BLUE,647,008,.T.,.F. )
//oSay27      := TSay():New(070,003,{||"Funcionario:"},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
//oSay28      := TSay():New(070,037,{|u| If(PCount()>0 , _cRFunc := u,_cRFunc)},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,110,008)
///oSay29      := TSay():New(070,152,{||"Data/Hora:"},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
//oSay30      := TSay():New(070,184,{|u| If(PCount()>0 , _cRDatHor := u,_cRDatHor)},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
//oSay31      := TSay():New(070,288,{||"Status:"},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
//oSay32      := TSay():New(070,309,{|u| If(PCount()>0 , _cRStatus := u,_cRStatus)},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,089,008)
oPanel4     := TPanel():New(077,001,"",oFlP:aDialogs[1],,.F.,.F.,CLR_WHITE,CLR_BLUE,647,009,.T.,.F. )

oSay37      := TSay():New(200,004,{||"Obs:"},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,089,008)
oSay38      := TSay():New(200,017,{|u| If(PCount()>0 , _cRObs := u,_cRObs)},oFlP:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,090)

//oBtn6       := TButton():New(195,575,"Area Transf.",oFlP:aDialogs[1],{|| Copy()},072,012,,,,.T.,,"",,,,.F. )
//oBtn8       := TButton():New(195,500,"Lib.Workflow",oFlP:aDialogs[1],{|| AtuFlag(1)},072,012,,,,.T.,,"",,,,.F. )

//oCBox3      := TComboBox():New(080,001,{|u| If(PCount()>0,_cCbStRj:=u,_cCbStRj)},_aCbStRj,072,010,oFlP:aDialogs[1],,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,)

MontCabec()
MontGrid()

//oBrw1       := MsNewGetDados():New(100,001,190,647,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oFlP:aDialogs[1],aRHBrw,aRCoBrw)
oBrw1       := MsNewGetDados():New(108,200,188,647,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oFlP:aDialogs[1],aRHBrw,aRCoBrw)
oBmp1       := TBitmap():New(109,001,190,088,,_cImg,.F.,oFlP:aDialogs[1],,,.F.,.T.,,"",.T.,,.T.,,.F. )
/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Dados aba Execução                                                     ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

oPanel5     := TPanel():New(003,001,,oFlP:aDialogs[2],,.F.,.F.,CLR_WHITE,CLR_BLUE,647,008,.T.,.F. )
oGrp3       := TGroup():New(013,001,061,647,"",oFlP:aDialogs[2],CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay5       := TSay():New(017,003,{||"Nome:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay6       := TSay():New(017,027,{|u| If(PCount()>0 , _cENome := u,_cENome)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay7       := TSay():New(029,003,{||"Endereço:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay8       := TSay():New(029,035,{|u| If(PCount()>0 , _cEEnd := u,_cEEnd)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay19      := TSay():New(029,187,{||"Complemento:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)
oSay20      := TSay():New(029,224,{|u| If(PCount()>0 , _cEComp := u,_cEComp)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
oSay9       := TSay():New(035,003,{||"Municipio:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,026,008)
oSay10      := TSay():New(035,035,{|u| If(PCount()>0 , _cEMun := u,_cEMun)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,120,008)
oSay33      := TSay():New(035,110,{||"Bairro:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
oSay34      := TSay():New(035,130,{|u| If(PCount()>0 , _cEBairro := u,_cEBairro)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)
ooSay23     := TSay():New(035,203,{||"Telefone:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay24      := TSay():New(035,229,{|u| If(PCount()>0 , _cETel := u,_cETel)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay11      := TSay():New(041,003,{||"Serviço:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,022,008)
oSay12      := TSay():New(041,031,{|u| If(PCount()>0 , _cEServ := u,_cEServ)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,150,008)
oSay13      := TSay():New(047,003,{||"Subcategoria:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,035,008)
oSay14      := TSay():New(047,044,{|u| If(PCount()>0 , _cESubCat := u,_cESubCat)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,206,008)
oSay25      := TSay():New(047,230,{||"Medida:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,021,008)
oSay26      := TSay():New(047,250,{|u| If(PCount()>0 , _cEMedida := u,_cEMedida)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,206,008)
oSay15      := TSay():New(053,003,{||"Status Atual:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,031,008)
oSay16      := TSay():New(053,041,{|u| If(PCount()>0 , _cEStatu := u,_cEStatu)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,094,008)
oSay17      := TSay():New(053,149,{||"Status VA:"},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,027,008)
oSay18      := TSay():New(053,176,{|u| If(PCount()>0 , _cEStaVa := u,_cEStaVa)},oGrp3,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,084,008)
/*oPanel6     := TPanel():New(062,001,"Dados Serviço",oFlP:aDialogs[2],,.F.,.F.,CLR_WHITE,CLR_BLUE,647,008,.T.,.F. )
oSay27      := TSay():New(070,003,{||"Funcionario:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay28      := TSay():New(070,037,{|u| If(PCount()>0 , _cEFunc := u,_cEFunc)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,110,008)
oSay29      := TSay():New(070,152,{||"Data/Hora:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,028,008)
oSay30      := TSay():New(070,184,{|u| If(PCount()>0 , _cEDatHor := u,_cEDatHor)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
oSay31      := TSay():New(070,288,{||"Status:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
oSay32      := TSay():New(070,309,{|u| If(PCount()>0 , _cEStatus := u,_cEStatus)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,089,008)*/
oPanel7     := TPanel():New(077,001,"",oFlP:aDialogs[2],,.F.,.F.,CLR_WHITE,CLR_BLUE,647,009,.T.,.F. )
oSay1       := TSay():New(086,003,{||"Medidor Ins.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2       := TSay():New(086,035,{|u| If(PCount()>0 , _cEMedIn := u,_cEMedIn)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay4       := TSay():New(086,104,{||"Medidor Ret.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3       := TSay():New(086,138,{|u| If(PCount()>0 , _cEMedRet := u,_cEMedRet)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay14      := TSay():New(086,199,{||"Medidor Local.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,041,008)
oSay13      := TSay():New(086,243,{|u| If(PCount()>0 , _cEMedLoc := u,_cEMedLoc)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay6       := TSay():New(086,304,{||"Medidor Vis001.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,041,008)
oSay5       := TSay():New(086,347,{|u| If(PCount()>0 , _cEMedV1 := u,_cEMedV1)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay12      := TSay():New(092,003,{||"Leitura Ins.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay11      := TSay():New(092,037,{|u| If(PCount()>0 , _cELeitIns := u,_cELeitIns)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay10      := TSay():New(092,104,{||"Leitura Ret.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay7       := TSay():New(092,138,{|u| If(PCount()>0 , _cRELeitRet := u,_cRELeitRet)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay8       := TSay():New(092,199,{||"Leitura Local .:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,041,008)
oSay9       := TSay():New(092,243,{|u| If(PCount()>0 , _cELeitLoc := u,_cELeitLoc)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay16      := TSay():New(092,304,{||"Medidor Vis002.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,041,008)
oSay17      := TSay():New(092,347,{|u| If(PCount()>0 , _cEMedV2 := u,_cEMedV2)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
Say22       := TSay():New(098,003,{||"N° Trafo.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay15      := TSay():New(098,037,{|u| If(PCount()>0 , _cETrafo := u,_cETrafo)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay20      := TSay():New(098,104,{||"Ramal Retirado.:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,042,008)
oSay21      := TSay():New(098,145,{|u| If(PCount()>0 , _cERaRet := u,_cERaRet)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
oSay18      := TSay():New(098,199,{||"Qtd Ramal Retirado .:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
oSay19      := TSay():New(098,250,{|u| If(PCount()>0 , _cEQRamRet := u,_cEQRamRet)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,047,008)

MntCabec()
MntGrid()

oBrw2       := MsNewGetDados():New(108,200,188,647,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oFlP:aDialogs[2],aEHBrw,aECoBrw)
oBmp2       := TBitmap():New(109,001,190,088,,_cImg,.F.,oFlP:aDialogs[2],,,.F.,.T.,,"",.T.,,.T.,,.F. )

oSay35      := TSay():New(200,004,{||"Obs:"},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,089,008)
oSay36      := TSay():New(200,017,{|u| If(PCount()>0 , _cEObs := u,_cEObs)},oFlP:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,450,090)

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
Local _cProgr := GetNextAlias()
Local _nLin   := 0
Local _aDados := {}

_cLacre := ""
_cLocal := ""

If Select("_cAlias") > 0
	("_cAlias")->(DbClosearea())
EndIf 

If Select(_cProgr) > 0
	(_cProgr)->(dbclosearea())
EndIf

If !Empty(_cGNota)
	
	_cQryPrg := ""
	_cQryPrg += " SELECT "
	_cQryPrg += " 'P' TIPO, "
	_cQryPrg += " ZZU_DATPRG AS DATPRG, "
	_cQryPrg += " ZZU_EQUIP EQUIP, "
	_cQryPrg += " ZZU_MEDID MEDID, "
	_cQryPrg += " ZZU_CLIENT CLIENT, "
	_cQryPrg += " ZZU_END [END], "
	_cQryPrg += " ZZU_COMP COMP, "
	_cQryPrg += " ZZU_MUN MUN, "
	_cQryPrg += " ZZU_BAIRRO BAIRRO, "
	_cQryPrg += " ZZU_TEL TEL, "
	_cQryPrg += " ZZU_SERVIC SERVIC, "
	_cQryPrg += " ZZU_SUBCAT SUBCAT, "
	_cQryPrg += " ZZU_MEDIDA MEDIDA, "
	_cQryPrg += " ZZU_DATA DATA, "
	_cQryPrg += " ZZU_HORDAT HORDAT, "
	_cQryPrg += " ZZU_STATUS [STATUS], "
	_cQryPrg += " ZZU_OBS OBS "	
	_cQryPrg += " FROM "+RetSQLName("ZZU")
	_cQryPrg += " WHERE ZZU_NOTA='"+_cGNota+"'"	
	
	_cQryPrg += " UNION ALL "
	
	_cQryPrg += " SELECT "
	_cQryPrg += " 'L' TIPO, "	
	_cQryPrg += " ' ' DATPRG, "
	_cQryPrg += " ' ' EQUIP, "
	_cQryPrg += " ' ' MEDID, "	
	_cQryPrg += " ZZT_CLIENT CLIENT, "
	_cQryPrg += " ZZT_END [END], "
	_cQryPrg += " ZZT_COMP COMP, "
	_cQryPrg += " ZZT_MUN MUN, "
	_cQryPrg += " ZZT_BAIRRO BAIRRO, "
	_cQryPrg += " ZZT_TEL TEL, "
	_cQryPrg += " ZZT_SERVIC SERVIC, "
	_cQryPrg += " ZZT_SUBCAT SUBCAT, "
	_cQryPrg += " ZZT_MEDIDA MEDIDA, "
	_cQryPrg += " ZZT_DATA DATA, "
	_cQryPrg += " ZZT_HORDAT HORDAT, "
	_cQryPrg += " ZZT_STATUS [STATUS], "
	_cQryPrg += " ZZT_OBS OBS"	
	_cQryPrg += " FROM "+RetSQLName("ZZT")
	_cQryPrg += " WHERE ZZT_NOTA='"+_cGNota+"'"	
	
	_cQryPrg += " UNION ALL"
	
	_cQryPrg += " SELECT "
	_cQryPrg += " 'C' TIPO, "
	_cQryPrg += " ' ' DATPRG, "
	_cQryPrg += " ' ' EQUIP, "
	_cQryPrg += " ' ' MEDID, "		
	_cQryPrg += " ZZV_CLIENT CLIENT, "
	_cQryPrg += " ZZV_END XEND, " //[END]
	_cQryPrg += " ZZV_COMP COMP, "
	_cQryPrg += " ZZV_MUN MUN, "
	_cQryPrg += " ZZV_BAIRRO BAIRRO, "
	_cQryPrg += " ZZV_TEL TEL, "
	_cQryPrg += " ZZV_SERVIC SERVIC, "
	_cQryPrg += " ZZV_SUBCAT SUBCAT, "
	_cQryPrg += " ZZV_MEDIDA MEDIDA, "
	_cQryPrg += " ZZV_DATA DATA, "
	_cQryPrg += " ZZV_HORDAT HORDAT, "
	_cQryPrg += " ZZV_STATUS [STATUS], "
	_cQryPrg += " ZZV_OBS OBS"	
	_cQryPrg += " FROM "+RetSQLName("ZZV")
	_cQryPrg += " WHERE ZZV_NOTA='"+_cGNota+"'"	
	
			
	_cQuery := " SELECT MAX(R_E_C_N_O_) R_E_C_N_O_ "
	_cQuery += " FROM "+RetSqlName("ZZW")
	_cQuery += " WHERE  D_E_L_E_T_ != '*' "
	_cQuery += " AND    ZZW_SITUAC  IN ('','L')  "
	_cQuery += " AND    ZZW_TPARQ   IN ('1','2') "
	//_cQuery += " AND    ZZW_RETSTA  != 'S' "
	_cQuery += " AND ZZW_NOTA = '"+_cGNota+"' "

Else
	return
EndIf		

_cQuery += "ORDER BY R_E_C_N_O_"

TcQuery _cQuery New Alias _cAlias 


dbUseArea(.T.,"TOPCONN",tcGenQry(,,_cQryPrg),(_cProgr),.F.,.F.,)

If (_cProgr)->(EOF())
	_cStatus:="Status: Nota não Localizada"
	_dData 	 :="Data/Hora: XX/XX/XXXX XX:XX"
	_cEquipe :="Equipe: XXXXXX"
	Limpa()
	oFLP:HidePage(1)
	oFLP:HidePage(2)
	oDlg1:Refresh()
	return
ElseIf (_cProgr)->TIPO !='P'
	_cStatus :="Status: Nota não Programada "
	_dData 	 :="Data/Hora: XX/XX/XXXX XX:XX"
	_cEquipe :="Equipe: XXXXXX"

	Limpa()
	
	_cENome     := (_cProgr)->CLIENT
	_cEEnd      := (_cProgr)->XEND
	_cEComp     := (_cProgr)->COMP
	_cEMun      := (_cProgr)->MUN
	_cEBairro   := (_cProgr)->BAIRRO
	_cETel      := (_cProgr)->TEL
	_cEServ     := (_cProgr)->SERVIC
	_cESubCat   := (_cProgr)->SUBCAT
	_cEMedida   := (_cProgr)->MEDIDA
	_cEStatu    := ""
	_cEStaVa    := ""
	_cEFunc     := ""
	_cEDatHor   := Substr((_cProgr)->DATA,7,2)+"/" + Substr((_cProgr)->DATA,5,2) +"/"+Substr((_cProgr)->DATA,1,4)+" - "  + (_cProgr)->HORDAT
	_cEStatus   := (_cProgr)->STATUS
	//_cEObs      := (_cProgr)->OBS
	oFLP:HidePage(1)	
	oFLP:ShowPage(2)
	
	oDlg1:Refresh()
	
Else  
	_cStatus :="Status: Nota Programada "
	_dData 	 :="Data/Hora: "+DtoC(StoD((_cProgr)->DATPRG))+" 00:00"
	_cEquipe :="Equipe: "+(_cProgr)->EQUIP +" - "+Posicione("ZZ4",1,xFilial("ZZ4")+(_cProgr)->EQUIP,"ZZ4_NOMETC")

	Limpa()
	
	_cENome     := (_cProgr)->CLIENT
	_cEEnd      := (_cProgr)->XEND
	_cEComp     := (_cProgr)->COMP
	_cEMun      := (_cProgr)->MUN
	_cEBairro   := (_cProgr)->BAIRRO
	_cETel      := (_cProgr)->TEL
	_cEServ     := (_cProgr)->SERVIC
	_cESubCat   := (_cProgr)->SUBCAT
	_cEMedida   := (_cProgr)->MEDIDA
	_cEStatu    :=  _cStatus
	_cEStaVa    :=  ""
	_cEFunc     :=  Posicione("ZZ4",2,xFilial("ZZ4")+(_cProgr)->EQUIP,"ZZ4_NOMETC")
	_cEDatHor   := 	_cEDatHor   := Substr((_cProgr)->DATA,7,2)+"/" + Substr((_cProgr)->DATA,5,2) +"/"+ Substr((_cProgr)->DATA,1,4)+" - "  + (_cProgr)->HORDAT
	_cEStatus   :=  (_cProgr)->STATUS
//	_cEObs      :=  (_cProgr)->OBS
	oFLP:HidePage(1)	
	oFLP:ShowPage(2)
	
	oDlg1:Refresh()
	
EndIf

If ("_cAlias")->R_E_C_N_O_ = 0
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

Do Case

	Case SubStr(ZZW_STATUS,1,1) == "R"
	
		_cStatus	:="Status: Nota Rejeitada "
		_dData 		:="Data/Hora: "+DtoC(ZZW->ZZW_DATA)+" "+ZZW->ZZW_HORA			
		_cEquipe 	:="Equipe: "+(_cProgr)->EQUIP +" - "+Posicione("ZZ4",1,xFilial("ZZ4")+(_cProgr)->EQUIP,"ZZ4_NOMETC")
		
		oFLP:HidePage(2)	
		oFLP:ShowPage(1)
//		oFlP:aEnable(2, .F.)  		 
//		oFlp:SetOption(1)
	
		_cRNota     := ZZW->ZZW_NOTA
		oPanel2:cCaption := "Nota: "+ZZW->ZZW_NOTA
		oPanel2:Refresh()	
		
		_cRNome     := ZZW->ZZW_CLIENT
		_cREnd      := ZZW->ZZW_END
		_cRComp     := ZZW->ZZW_COMP
		_cRMun      := ZZW->ZZW_MUN
		_cRBairro   := ZZW->ZZW_BAIRRO
		_cRTel      := ZZW->ZZW_TEL
		_cRServ     := ZZW->ZZW_SERVIC
		_cRSubCat   := ZZW->ZZW_SUBCAT
		_cRMedida   := ZZW->ZZW_MEDIDA
		_cRStatu    := _cStatus
		_cRStaVa    := ZZW->ZZW_STAVA
		//_cRFunc     := Posicione("ZZS",1,xFilial("ZZS")+ZZW->ZZW_EQUIP,"ZZS_RESP")
		_cRFunc     := Posicione("ZZ4",2,xFilial("ZZ4")+ZZW->ZZW_EQUIP,"ZZ4_NOMETC")
		_cRDatHor   := Substr(DTOS(ZZW->ZZW_DATA),7,2)+"/" + Substr(DTOS(ZZW->ZZW_DATA),5,2) +"/"+Substr(DTOS(ZZW->ZZW_DATA),1,4)+" - "  + ZZW->ZZW_HORA
		_cRStatus   := ZZW->ZZW_STATUS
		_cRObs      := ZZW->ZZW_OBS 
		
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
		
	Case SubStr(ZZW->ZZW_STATUS,1,1) == "E"
		oFLP:HidePage(1)	
		oFLP:ShowPage(2)
			
//		oFlP:aEnable(1, .F.)
//		oFlp:SetOption(2)
		
		_cStatus :="Status: Nota Executada "
		
		If AllTrim(ZZW->ZZW_STATU)=="I"
			_cStatus :="Status: Indireta "
		ElseIf AllTrim(ZZW->ZZW_STATU)=="L"
			_cStatus :="Status: Nota Liberada "
		ElseIf AllTrim(ZZW->ZZW_STATU)=="P"
			_cStatus :="Status: Conta Paga "			
		ElseIf AllTrim(ZZW->ZZW_STATU)=="S"
			_cStatus :="Status: Sobra "	
//			oFLP:HidePage(2)	
//			oDlg1:Refresh()
//			return
		EndIf
			
		_dData   := "Data/Hora: "+DtoC(ZZW->ZZW_DATA)+" "+ZZW->ZZW_HORA
		_cEquipe := "Equipe: "+(_cProgr)->EQUIP +" - "+Posicione("ZZ4",1,xFilial("ZZ4")+(_cProgr)->EQUIP,"ZZ4_NOMETC")
	
		_cENota     := ZZW->ZZW_NOTA
		oPanel5:cCaption := "Nota: "+ZZW->ZZW_NOTA
		oPanel5:Refresh()	

		_cENome     := ZZW->ZZW_CLIENT
		_cEEnd      := ZZW->ZZW_END
		_cEComp     := ZZW->ZZW_COMP
		_cEMun      := ZZW->ZZW_MUN
		_cEBairro   := ZZW->ZZW_BAIRRO
		_cETel      := ZZW->ZZW_TEL
		_cEServ     := ZZW->ZZW_SERVIC
		_cESubCat   := ZZW->ZZW_SUBCAT
		_cEMedida   := ZZW->ZZW_MEDIDA
		_cEStatu    := _cStatus
		_cEStaVa    := ZZW->ZZW_STAVA
		//_cEFunc     := Posicione("ZZS",1,xFilial("ZZS")+ZZW->ZZW_EQUIP,"ZZS_RESP")
		_cEFunc     := Posicione("ZZ4",2,xFilial("ZZ4")+ZZW->ZZW_EQUIP,"ZZ4_NOMETC")
		_cEDatHor   := Substr(DTOS(ZZW->ZZW_DATA),7,2)+"/" + Substr(DTOS(ZZW->ZZW_DATA),5,2) +"/"+Substr(DTOS(ZZW->ZZW_DATA),1,4)+" - "  + ZZW->ZZW_HORA
		_cEStatus   := ZZW->ZZW_STATUS
		_cEObs      := ZZW->ZZW_OBS
		
		DbSelectArea("ZA2")
		DbSetOrder(1)
		If DbSeek(xFilial("ZA2")+ZZW->ZZW_NOTA)
		
			While xFilial("ZA2")+ZZW->ZZW_NOTA == ZA2->ZA2_FILIAL+ZA2->ZA2_NOTA 
			
				If ZA2->ZA2_TIPO = 'E'  

					_cEMedIn    := ZA2->ZA2_MEDINS
					_cEMedRet   := ZA2->ZA2_MEDRET
					_cEMedLoc   := Iif(!Empty(ZA2->ZA2_MEDLOC),ZA2->ZA2_MEDLOC,(_cProgr)->MEDID)
					_cEMedV1    := ZA2->ZA2_MEDVZ1
					_cELeitIns  := ZA2->ZA2_LEIMED
					_cRELeitRet := ZA2->ZA2_LEIRET
					_cELeitLoc  := ZA2->ZA2_LEILOC
					_cEMedV2    := ZA2->ZA2_MEDVZ2
					_cETrafo    := ZA2->ZA2_TRAFOR
					_cERaRet    := ZA2->ZA2_RAMRET
					_cEQRamRet  := cValToChar(ZA2->ZA2_QTRARET)
					_cLocal		:= IIF(Empty(ZA2->ZA2_LOCAL),"","Local Corte: "+ZA2->ZA2_LOCAL)
				
					_cLacre := "" 
					//-> Carrega dados do lacre
					DbSelectArea("ZA6")
					DbSetOrder(1)
					If DbSeek(xFilial("ZA6")+_cENota)
			
						While !ZA6->(Eof()) .And. xFilial("ZA6")+_cENota== ZA6->ZA6_FILIAL + ZA6->ZA6_NOTA
				
							_cLacre += AllTrim(ZA6->ZA6_LACRE) +" "
				
						ZA6->(DbSkip())
						EndDo
			
					EndIf

					//-> Carrega dados grid
					
					_aDados:={}
					
					DbSelectArea("ZA3")
					DbSetOrder(1)
					If DbSeek(xFilial("ZA3")+ZZW->ZZW_NOTA)
			
						While xFilial("ZA3")+ZZW->ZZW_NOTA == ZA3->ZA3_FILIAL + ZA3->ZA3_NOTA
				    
						    aAdd(_aDados,{ZA3->ZA3_CODSAP,ZA3->ZA3_DESC,ZA3->ZA3_QTDREA,_cLacre,.F.})
				    
							ZA3->(DbSkip())
						EndDo 
				
					EndIf
				EndIf	
				
				ZA2->(DbSkip())
			EndDo
						
			    
			oBrw2:aCols := _aDados 
			oBrw2:Refresh()    
				
		EndIf
		
		If AllTrim(ZZW->ZZW_STATU)!='S'
			AltImg(1)
        EndIf
        
EndCase
	oDlg1:Refresh()
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
Local _cSX3 	:= GetNextAlias()

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

			If X3Uso(&("(_cSX3)->X3_USADO")) .and. cNivel >= &("(_cSX3)->X3_NIVEL") .And. AllTrim(&("(_cSX3)->X3_CAMPO")) $ _cCampos
    
    			noBrw1++
	
    	  		Aadd(aRHBrw,{Trim(X3Titulo()),;
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

Static Function MntCabec

Local _cCampos := ""
Local _cAlias  := ""
Local _cSX3    := GetNextAlias()

_cCampos       := "ZA3_CODSAP|ZA3_DESC" 
_cAlias        := "ZA3"


//SX3
OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
lOpen := Select(_cSX3) > 0
If (lOpen)
  dbSelectArea(_cSX3)
  (_cSX3)->(dbSetOrder(1)) 
  (_cSX3)->(dbSeek(_cAlias))
  If (Found())
  		While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == _cAlias )

			If X3Uso(&("(_cSX3)->X3_USADO")) .and. cNivel >= &("(_cSX3)->X3_NIVEL") .And. AllTrim(&("(_cSX3)->X3_CAMPO")) $ _cCampos
    
    			noBrw2++
	
    	  		Aadd(aEHBrw,{Trim(X3Titulo()),;
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
    
    	noBrw2++
      
      	Aadd(aEHBrw,{Trim(X3Titulo()),;
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


noBrw2++
Aadd(aEHBrw,{"Quant.Real"  ,"ZA3_QTDREA"  ,"@E 99,999,999,999.99" ,14 ,2,""  ,"û" ,"N", "ZA3" })                  
noBrw2++
Aadd(aEHBrw,{"Lacre"       ,"ZA6_LACRE"    ,"@!"                  ,45 ,0,""  ,"û" ,"C", "ZA6" })                 				

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

Static Function MntGrid()

Aadd(aECoBrw,Array(noBrw2+1))

aECoBrw[1,1] := Space(TamSx3("ZA3_CODSAP")[1])
aECoBrw[1,2] := Space(TamSx3("ZA3_DESC")[1])
aECoBrw[1,3] := 0
aECoBrw[1,4] := Space(TamSx3("ZA6_LACRE")[1])
aECoBrw[1,5] := .F. 

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

_cLacre := ""

_nPosImg := 0

If Len(_aRecno) = 0
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
_cQuery += " AND   ZZW_SITUAC  IN ('','L')  "
_cQuery += " AND   ZZW_TPARQ   = '1' "
_cQuery += " AND   R_E_C_N_O_  = '"+cValToChar(_nRecno)+"'"

TcQuery _cQuery New Alias _cAlAv

_cENota := ""
_cRNota := ""

Do Case

	Case SubStr(("_cAlAv")->ZZW_STATUS,1,1) == "R"
	
		oFlP:aEnable(2, .F.)
		oFlP:aEnable(1, .T.)

		_cRNota := ("_cAlAv")->ZZW_NOTA 
	
		oPanel2:cCaption := "Nota: "+("_cAlAv")->ZZW_NOTA
		oPanel2:Refresh()
		_cRNome     := ("_cAlAv")->ZZW_CLIENT
		_cREnd      := ("_cAlAv")->ZZW_END
		_cRComp     := ("_cAlAv")->ZZW_COMP
		_cRMun      := ("_cAlAv")->ZZW_MUN
		_cRBairro   := ("_cAlAv")->ZZW_BAIRRO
		_cRTel      := ("_cAlAv")->ZZW_TEL
		_cRServ     := ("_cAlAv")->ZZW_SERVIC
		_cRSubCat   := ("_cAlAv")->ZZW_SUBCAT
		_cRMedida   := ("_cAlAv")->ZZW_MEDIDA
		_cRStatu    := ("_cAlAv")->ZZW_STATU
		_cRStaVa    := ("_cAlAv")->ZZW_STAVA
		//_cRFunc     := Posicione("ZZS",1,xFilial("ZZS")+("_cAlAv")->ZZW_EQUIP,"ZZS_RESP")
		_cRFunc     := Posicione("ZZ4",2,xFilial("ZZ4")+("_cAlAv")->ZZW_EQUIP,"ZZ4_NOMETC")
		_cRDatHor   := Substr(("_cAlAv")->ZZW_DATA,7,2)+"/" + Substr(("_cAlAv")->ZZW_DATA,5,2) +"/"+Substr(("_cAlAv")->ZZW_DATA,1,4)+" - "  + ("_cAlAv")->ZZW_HORA
		_cRStatus   := ("_cAlAv")->ZZW_STATUS
		
		_cRObs      := "" 
		
		DbSelectArea("ZZW")
		DbSetOrder(2)
		If DbSeek(xFilial("ZZW")+("_cAlAv")->ZZW_NOTA)
		
			nLines   := MLCount(ZZW->ZZW_OBS)
			nQtdeLin := 0			
			//-> Varre todas as linhas do texto e imprime			
			If nLines > 0
				
				For nX := 1 To nLines
				
					_cRObs += MemoLine(ZZW->ZZW_OBS,120,nX)
				
				Next nX
				
			EndIf
			
		EndIf
		
		//->Carrega dados ZA5
		DbSelectArea("ZA5")
		DbSetOrder(1)
		If DbSeek(xFilial("ZA5")+("_cAlAv")->ZZW_NOTA)
		
			While xFilial("ZA5")+("_cAlAv")->ZZW_NOTA == ZA5_FILIAL + ZA5->ZA5_NOTA
			    
			    aAdd(_aDados,{ZA5->ZA5_CODSAP,ZA5->ZA5_DESC,.F.})
				    
				DbSkip()
			EndDo 
			    
			oBrw1:aCols := _aDados 
			oBrw1:Refresh()    
 		
		EndIf		
	
	Case SubStr(("_cAlAv")->ZZW_STATUS,1,1) == "E"
	
		oFlP:aEnable(1, .F.)
		oFlP:aEnable(2, .T.)
		
		_cENota:= ("_cAlAv")->ZZW_NOTA 		
	
		oPanel5:cCaption := "Nota: "+("_cAlAv")->ZZW_NOTA
		oPanel5:Refresh()
		_cENome     := ("_cAlAv")->ZZW_CLIENT
		_cEEnd      := ("_cAlAv")->ZZW_END
		_cEComp     := ("_cAlAv")->ZZW_COMP
		_cEMun      := ("_cAlAv")->ZZW_MUN
		_cEBairro   := ("_cAlAv")->ZZW_BAIRRO
		_cETel      := ("_cAlAv")->ZZW_TEL
		_cEServ     := ("_cAlAv")->ZZW_SERVIC
		_cESubCat   := ("_cAlAv")->ZZW_SUBCAT
		_cEMedida   := ("_cAlAv")->ZZW_MEDIDA
		_cEStatu    := ("_cAlAv")->ZZW_STATU
		_cEStaVa    := ("_cAlAv")->ZZW_STAVA
		//_cEFunc     := Posicione("ZZS",1,xFilial("ZZS")+("_cAlAv")->ZZW_EQUIP,"ZZS_RESP")
		_cEFunc     := Posicione("ZZ4",2,xFilial("ZZ4")+("_cAlAv")->ZZW_EQUIP,"ZZ4_NOMETC")		
		_cEDatHor   := Substr(("_cAlAv")->ZZW_DATA,7,2)+"/" + Substr(("_cAlAv")->ZZW_DATA,5,2) +"/"+Substr(("_cAlAv")->ZZW_DATA,1,4)+" - "  + ("_cAlAv")->ZZW_HORA
		_cEStatus   := ("_cAlAv")->ZZW_STATUS
		
		_cEObs      := ""
		
		DbSelectArea("ZZW")
		DbSetOrder(2)
		If DbSeek(xFilial("ZZW")+_cENota)
		
			nLines   := MLCount(ZZW->ZZW_OBS)
			nQtdeLin := 0			
			//-> Varre todas as linhas do texto e imprime			
			If nLines > 0
				
				For nX := 1 To nLines
				
					_cEObs += MemoLine(ZZW->ZZW_OBS,120,nX)
				
				Next nX
				
			EndIf
			
		EndIf
		
		DbSelectArea("ZA2")
		DbSetOrder(1)
		If DbSeek(xFilial("ZA2")+_cENota)
		
			While xFilial("ZA2")+("_cAlAv")->ZZW_NOTA == ZA2->ZA2_FILIAL+ZA2->ZA2_NOTA .And. ZA2->ZA2_TIPO = 'E'  

				_cEMedIn    := ZA2->ZA2_MEDINS
				_cEMedRet   := ZA2->ZA2_MEDRET
				_cEMedLoc   := ZA2->ZA2_MEDLOC
				_cEMedV1    := ZA2->ZA2_MEDVZ1
				_cELeitIns  := ZA2->ZA2_LEIMED
				_cRELeitRet := ZA2->ZA2_LEIRET
				_cELeitLoc  := ZA2->ZA2_LEILOC
				_cEMedV2    := ZA2->ZA2_MEDVZ2
				_cETrafo    := ZA2->ZA2_TRAFOR
				_cERaRet    := ZA2->ZA2_RAMRET
				_cEQRamRet  := cValToChar(ZA2->ZA2_QTRARET)
				_cEObs 		:= Iif(Empty(ZA2->ZA2_LOCAL),_cEObs,(_cEObs+" Local Corte: "+ZA2->ZA2_LOCAL))
				
				ZA2->(DbSkip())
			EndDo
			
			_cLacre := "" 
			//-> Carrega dados do lacre
			DbSelectArea("ZA6")
			DbSetOrder(1)
			If DbSeek(xFilial("ZA6")+_cENota)
			
				While !ZA6->(Eof()) .And. xFilial("ZA6")+_cENota== ZA6->ZA6_FILIAL + ZA6->ZA6_NOTA
				
					_cLacre += AllTrim(ZA6->ZA6_LACRE) +" "
				
					ZA6->(DbSkip())
				EndDo
			
			EndIf						
			
			//-> Carrega dados grid
			DbSelectArea("ZA3")
			DbSetOrder(1)
			If DbSeek(xFilial("ZA3")+_cENota)
			
				While xFilial("ZA3")+("_cAlAv")->ZZW_NOTA == ZA3->ZA3_FILIAL + ZA3->ZA3_NOTA
				    
				    aAdd(_aDados,{ZA3->ZA3_CODSAP,ZA3->ZA3_DESC,ZA3->ZA3_QTDREA,_cLacre,.F.})
				    
					DbSkip()
				EndDo 
				
			Else
			
				aAdd(_aDados,{"","",0,_cLacre,.F.})		    
    			
			EndIf		
		
		EndIf
		    
		oBrw2:aCols := _aDados 
		oBrw2:Refresh()		
		
		AltImg(1,1)				
        
EndCase

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

Local   _cNota   := ""
Local   _cSTGRV  := ""
Local   _nPos    := 0
Local   _cSituac := ""
Private _cMltGet := ""

If oFlP:nOption = 1
 
	_cNota  := _cRNota
	_cSTGRV := _cCbStRj
	
	If SubStr(_cCbStRj,1,1) == "C" 
		_cSituac := "S"
	Else
		_cSituac := "W"			
	EndIf
	
Else

	_cNota  := _cENota
	_cSTGRV := _cCbStEx 
	
	If SubStr(_cCbStEx,1,1) == "C" 
		_cSituac := "S"
	Else
		_cSituac := "W"			
	EndIf
		
EndIf   

If _cSituac == "W"
	AtuFlag()
	If Empty(_cMltGet)
		Return
	EndIf
EndIf

DbSelectArea("ZZW")
DbSetOrder(2)
If DbSeek(xFilial("ZZW")+_cNota)

	If RecLock("ZZW",.F.)

		ZZW->ZZW_SITUAC := _cSituac 
		ZZW->ZZW_STGRV	:= _cSTGRV
		ZZW->ZZW_IDUSER := __cUserID
		ZZW->ZZW_USER   := cUserName
		ZZW->ZZW_DATWF  := dDataBase
		ZZW->ZZW_HORWF  := Time()
		ZZW->ZZW_OBSDIG := _cMltGet
		ZZW->ZZW_OBSZZW := "" 
		
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

If ((!Empty(_cENota)) .or. (!Empty(_cRNota)))
	
	If !Empty(_cENota)
		aFiles  := Directory("\Notas\"+AllTrim(_cENota)+"\*.*", "D")
	Else	
		aFiles  := Directory("\Notas\"+AllTrim(_cRNota)+"\*.*", "D")
	EndIf
	
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

If Len(_aDados) < _nOpc
	_nOpc:= len(_aDados)
EndIf

oBmp2:Load(,"\Notas\"+AllTrim(_cENota)+"\"+_aDados[_nOpc,1])
oBmp2:SetBmp("\Notas\"+AllTrim(_cENota)+"\"+_aDados[_nOpc,1]) 
oBmp2:Refresh()	
//Alert("\Notas\"+AllTrim(_cENota)+"\"+_aDados[1,1])

oBmp1:Load(,"\Notas\"+AllTrim(_cRNota)+"\"+_aDados[_nOpc,1])
oBmp1:SetBmp("\Notas\"+AllTrim(_cRNota)+"\"+_aDados[_nOpc,1]) 
oBmp1:Refresh()	
//Alert("\Notas\"+AllTrim(_cRNota)+"\"+_aDados[1,1])

SysRefresh()
ProcessMessage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SFOLPGL   ºAutor  ³Microsiga           º Data ³  06/19/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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

Local _cMulCpy  := ""
Local _cStAreaT := "" 

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

SetPrvt("oDCpy","oGrp1","oMGet1")

If oFlP:nOption = 1

	_cStAreaT := Posicione("ZZW",2,xFilial("ZZW")+_cRNota,"ZZW_RETSTA") 
	
	_cMulCpy += "Nota: "+_cRNota+Chr(10)+Chr(13)
	_cMulCpy += "Funcionario: "+_cRFunc+"   "+"Data/Hora: "+_cRDatHor+"   "+"Status: "+_cStAreaT+Chr(10)+Chr(13)
	_cMulCpy += "Cod.Sap       Descrição"+Chr(10)+Chr(13)
	
	For _nX := 1 To Len(oBrw1:aCols)
	
		_cMulCpy += oBrw1:aCols[_nX,1]+"          "+oBrw1:aCols[_nX,2]+Chr(10)+Chr(13) 		
	
	Next _nX 
	
	_cMulCpy += "Obs: "+_cRObs+Chr(10)+Chr(13)
	
Else 

	_cStAreaT := Posicione("ZZW",2,xFilial("ZZW")+_cENota,"ZZW_RETSTA") 

	_cMulCpy += "Nota: "+_cENota+Chr(10)+Chr(13)
	_cMulCpy += "Funcionario: " +_cEFunc+"   "   +"Data/Hora: "   +_cEDatHor+"   "  +"Status: "        +_cStAreaT+Chr(10)+Chr(13)
	_cMulCpy += "Medidor Ins.: "+_cEMedIn+"   "  +"Medidor Ret.: "+_cEMedRet+"   "  +"Medidor Local.: "+_cEMedLoc+"   "+"Medidor Vis001.: "+_cEMedV1+Chr(10)+Chr(13)
	_cMulCpy += "Leitura Ins.: "+_cELeitIns+"   "+"Leitura Ret.: "+_cRELeitRet+"   "+"Leitura Local .:"+_cELeitLoc+"   "+"Medidor Vis002.: "+_cEMedV2+Chr(10)+Chr(13)   
	_cMulCpy += "N° Trafo.: "+_cETrafo+"   "+"Ramal Retirado.: "+_cERaRet+"   "+"Qtd Ramal Retirado .: "+_cEQRamRet+Chr(10)+Chr(13)

	_cMulCpy += "Cod.Sap       Descrição                                                          Quant.Real"+Chr(10)+Chr(13)
	
	For _nX := 1 To Len(oBrw2:aCols)
	
		_cDesc   := AllTrim(oBrw2:aCols[_nX,2])
		_cMulCpy += oBrw2:aCols[_nX,1]+"    "+PadR(_cDesc,Len(Space(40)))+cValToChar(oBrw2:aCols[_nX,3])+Chr(10)+Chr(13) 		
	
	Next _nX 
	
	_cMulCpy += "Obs: "+_cEObs+Chr(10)+Chr(13)  	
	_cMulCpy += "Lacre: "
	_cLacre := ""
	
	//-> Carrega dados do lacre
	DbSelectArea("ZA6")
	DbSetOrder(1)
	If DbSeek(xFilial("ZA6")+_cENota)
	
		While !ZA6->(Eof()) .And. xFilial("ZA6")+_cENota== ZA6->ZA6_FILIAL + ZA6->ZA6_NOTA
		
			_cMulCpy += AllTrim(ZA6->ZA6_LACRE) +" "+Chr(10)+Chr(13)
		
			ZA6->(DbSkip())
		EndDo
	
	EndIf	 
	
EndIf

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
Static Function AtuFlag(pnOpc)

Local _cNota  := ""
Local _lAux   := .T.
Default pnOpc := 0 

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Declaração de Variaveis Private dos Objetos                            ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

If pnOpc = 1

	If oFlP:nOption = 1 
	
		_cNota := _cRNota
		
		_cObs  := Posicione("ZZW",2,xFilial("ZZW")+_cNota,"ZZW_OBSZZW")
		
		If Empty(_cObs)
			Return
		EndIf
		
		_cMltGet := _cObs
	
	Else
	
		_cNota   := _cENota

		_cObs    := Posicione("ZZW",2,xFilial("ZZW")+_cNota,"ZZW_OBSZZW")

		If Empty(_cObs)
			Return
		EndIf
		
		_cMltGet := _cObs				
	
	EndIf

EndIf

SetPrvt("oFlg","oGrp1","oMGet1")

/*
±±ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±± Definicao do Dialog e todos os seus componentes.                       ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
*/

oFlg       := MSDialog():New(092,232,351,692,"Atualiza WorkFlow",,,.F.,,,,,,.T.,,,.T. )
oFlg:bInit := {||EnchoiceBar(oFlg,{|| oFlg:End()},{|| oFlg:End()},.F.,{})}
oGrp1      := TGroup():New(016,004,116,216," Obs.: ",oFlg,CLR_BLACK,CLR_WHITE,.T.,.F. )
oMGet1     := TMultiGet():New(028,012,{|u| If(PCount()>0 , _cMltGet := u,_cMltGet)},oGrp1,196,080,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

oFlg:Activate(,,,.T.)

Return

Static Function Limpa
	
		oFlP:aEnable(2, .F.)   
	
		_cRNota     := ""
		
		oPanel2:cCaption :=""
		oPanel2:Refresh()	
		
		_cRNome     := ""
		_cREnd      := ""
		_cRComp     := ""
		_cRMun      := ""
		_cRBairro   := ""
		_cRTel      := ""
		_cRServ     := ""
		_cRSubCat   := ""
		_cRMedida   := ""
		_cRStatu    := ""
		_cRStaVa    := ""
		_cRFunc     := ""
		_cRDatHor   := ""
		_cRStatus   := ""
		_cRObs      := "" 
		
		oBrw1:aCols := {}
		oBrw1:Refresh()    	
	
		oFlP:aEnable(1, .F.)
	
		_cENota     := ""
		oPanel5:cCaption := ""
		oPanel5:Refresh()	

		_cENome     := ""
		_cEEnd      := ""
		_cEComp     := ""
		_cEMun      := ""
		_cEBairro   := ""
		_cETel      := ""
		_cEServ     := ""
		_cESubCat   := ""
		_cEMedida   := ""
		_cEStatu    := ""
		_cEStaVa    := ""
		//_cEFunc     := Posicione("ZZS",1,xFilial("ZZS")+ZZW->ZZW_EQUIP,"ZZS_RESP")
		_cEFunc     := ""
		_cEDatHor   := ""
		_cEStatus   := ""
		_cEObs      := "" 
		_cEMedIn    := ""
		_cEMedRet   := ""
		_cEMedLoc   := ""
		_cEMedV1    := ""
		_cELeitIns  := ""
		_cRELeitRet := ""
		_cELeitLoc  := ""
		_cEMedV2    := ""
		_cETrafo    := ""
		_cERaRet    := ""
		_cEQRamRet  := ""
		
		oBmp1:SetEmpty() 
		oBmp2:SetEmpty() 
		    
		oBrw2:aCols := {}
		oBrw2:Refresh()    
			
Return