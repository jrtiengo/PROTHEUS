#INCLUDE "AP5MAIL.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#DEFINE  ENTER CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³          ºAutor  ³Fabiano Pereira     º Data ³  30/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus - Automatech                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*****************************************************************************
User Function AUTCRONO()
*****************************************************************************
Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Private aCoBrwH := {}
Private aHoBrwH := {}
Private noBrwH  := 0

SetPrvt("oFontN10","oDlgCron","oGrp1","oSay1","oSay2","oSay3","oGrp2","oFolder","oBrwH","oGrp3","oSay4")
SetPrvt("oGrp4","oSay6","oGrp5","oSay7","oBtn1","oBtn2","oBtn3")

oFontN10   := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )

oDlgCron   := MSDialog():New( 171,247,540,886,"Cronometro Atendimento",,,.F.,,,,,,.T.,,,.T. )

oGrp1      := TGroup():New( 004,004,056,308,"",oDlgCron,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 016,008,{||"Num. OS:"},oGrp1,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( 028,008,{||"Cliente:"},oGrp1,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 040,008,{||"Tecnico:"},oGrp1,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

oGrp2      := TGroup():New( 060,004,160,308,"",oDlgCron,CLR_BLACK,CLR_WHITE,.T.,.F. )

oFolder    := TFolder():New( 064,008,{"Atendimento","Historico"},{},oGrp2,,,,.T.,.F.,296,092,) 

//MHoBrwH()
//MCoBrwH()
oBrwH      := MsNewGetDados():New(004,004,072,280,nOpc,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oFolder:aDialogs[2],aHoBrwH,aCoBrwH )
oGrp3      := TGroup():New( 004,000,076,072,"Inicio",oFolder:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay4      := TSay():New( 020,008,{||"Data:"},oGrp3,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay5      := TSay():New( 032,008,{||"Hora:"},oGrp3,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGrp4      := TGroup():New( 004,076,076,148,"Atual",oFolder:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay6      := TSay():New( 024,092,{||"00:10"},oGrp4,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGrp5      := TGroup():New( 004,152,076,224,"Total",oFolder:aDialogs[1],CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay7      := TSay():New( 024,160,{||"01:05"},oGrp5,,oFontN10,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oBtn1      := TButton():New( 012,236,"INICIAR",oFolder:aDialogs[1],,044,020,,oFontN10,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 048,236,"PARAR",oFolder:aDialogs[1],,044,020,,oFontN10,,.T.,,"",,,,.F. )
oBtn3      := TButton():New( 164,120,"SAIR",oDlgCron,,044,012,,oFontN10,,.T.,,"",,,,.F. )

oDlgCron:Activate(,,,.T.)

Return

Static Function MHoBrwH()

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("")
While !Eof() .and. SX3->X3_ARQUIVO == ""
   If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
      noBrwH++
      Aadd(aHoBrwH,{Trim(X3Titulo()),;
           SX3->X3_CAMPO,;
           SX3->X3_PICTURE,;
           SX3->X3_TAMANHO,;
           SX3->X3_DECIMAL,;
           "",;
           "",;
           SX3->X3_TIPO,;
           "",;
           "" } )
   EndIf
   DbSkip()
End

Return
Static Function MCoBrwH()

Local aAux := {}

Aadd(aCoBrwH,Array(noBrwH+1))
For nI := 1 To noBrwH
   aCoBrwH[1][nI] := CriaVar(aHoBrwH[nI][2])
Next
aCoBrwH[1][noBrwH+1] := .F.

Return
					
						
Return()