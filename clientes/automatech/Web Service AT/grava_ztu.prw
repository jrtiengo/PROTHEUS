#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

User Function grava_ztu()

   Local csql    := ""
   Local cCodFil := "01"
   Local cCodCon := "000015"

// cDtaFim := Ctod(Substr(Dtoc(Date()),01,02) + "/" + Substr(Dtoc(Date()),04,02) + "/" + Substr(Dtoc(Date()),07,04))
   cDtaFim := Substr(Dtoc(Date()),07,04) + Substr(Dtoc(Date()),04,02) + Substr(Dtoc(Date()),01,02)
   cHorFim := Time()

   cSql := ""
   cSql := "UPDATE ZTU010"
   cSql += "   SET "
   cSql += "   ZTU_DFIM = " + dtoc(date())  + ", "
   cSql += "   ZTU_HFIM = '" + Alltrim(cHorFim) + "'  "
   cSql += "      WHERE ZTU_FILIAL = '" + Alltrim(cCodFil) + "'"
   cSql += "        AND ZTU_CONT   = '" + Alltrim(cCodCon) + "'"

  for x = 1 to 50

   lResult := TCSQLEXEC(cSql)

   If lResult < 0
      MsgAlert("Deu Erro")
   Else
      MsgAlert("Deu Certo")
   Endif
  
next x

Return(.T.)