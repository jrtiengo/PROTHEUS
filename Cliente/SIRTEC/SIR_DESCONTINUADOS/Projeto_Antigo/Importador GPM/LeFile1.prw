#include 'protheus.ch'

#define TEXT_FILE "D:\Lenovo\TOTVS 12\Microsiga\protheus_data\GPM\2019-07-20_sirtecce.json"

//'\meuarquivo.txt'

/* ======================================================================
Função U_LeFile1, 2 e 3()
Autor Júlio Wittwer
Data 17/10/2015
Descrição Fontes de teste comparativo de desempenho de leitura de arquivo TEXTO

U_LeFile1() - Usa ZFWReadTXT
U_LeFile2() - Usa FT_FREADLN
U_LeFile3() - Usa FWFileReader
====================================================================== */

User Function LeFile1()

   Local oTXTFile
   Local cLine := ''
   Local nLines := 0
   Local nTimer

   nTimer := seconds()
   oTXTFile := ZFWReadTXT():New(TEXT_FILE)

   If !oTXTFile:Open()
      MsgStop(oTXTFile:GetErrorStr(),"OPEN ERROR")
      Return
   Endif

   While oTXTFile:ReadLine(@cLine)
      nLines++
   Enddo

   oTXTFile:Close()

   MsgInfo("Read " + cValToChar(nLines)+" line(s) in "+str(seconds()-nTimer,12,3)+' s.',"Using ZFWReadTXT")

Return

User Function LeFile2()

   Local nTimer
   Local nLines := 0

   nTimer := seconds()
   FT_FUSE(TEXT_FILE)

   While !FT_FEOF()
      cLine := FT_FReadLN()  
      MSGALERT(CLINE)
      FT_FSkip()
      nLines++
   Enddo

   FT_FUSE()

   MsgInfo("Read " + cValToChar(nLines)+" line(s) in "+str(seconds()-nTimer,12,3)+' s.',"Using FT_FReadLN")

Return

User Function LeFile3()

   Local nTimer
   Local nLines := 0
   Local oFile

   nTimer := seconds()

   oFile := FWFileReader():New(TEXT_FILE)
   
   If !oFile:Open()
      MsgStop("File Open Error","ERROR")
      Return
   Endif

   While (!oFile:Eof())
     cLine := oFile:GetLine()
     nLines++
   Enddo

   oFile:Close()

   MsgInfo("Read " + cValToChar(nLines)+" line(s) in "+str(seconds()-nTimer,12,3)+' s.',"Using FWFileReader")
	
Return