#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ImpArgox     บAutor  ณ lISANDRO S     บ Data ณ  17/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Immpressใo de etiquetas Marcher                            บฑฑ
ฑฑบ          ณ Sele็ใo de dados                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Marcher                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function ImpArgox(aProd,cPorta)

//Local cPorta  := "LPT1".or."USB001"


If Len( aProd ) <= 0
	MsgAlert("Nao existe dados para impressao!")
	Return
EndIf

//MSCBPRINTER("OS 214",cPorta,,,.f.,,,,,,.T.,)
//MSCBPRINTER("Argox:LPT1",cPorta,,)

MSCBPRINTER("Argox OS-214 plus PPLA","USB001",,)  

//MSCBPRINTER("Argox:LPT1","LPT1",,)
MscbChkStatus(.F.)


DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + aProd[1][1] )

cDesc   := Left(AllTrim( SB1->B1_DESC),20)
cCodBar := Left(AllTrim( SB1->B1_CODBAR),14)

nX:=1
nY:=1     



MSCBBEGIN(1,2)           
MSCBSAY(04,10,SUBSTR("SB1->B1_DESC",1,20),"N","1","01,01") //Imprime Texto descricao do produto      
MSCBSAY(34,10,SUBSTR("SB1->B1_DESC",1,20),"N","1","01,01") //Imprime Texto descricao do produto            

MsgAlert("antes do BEND:" + cPorta)

MSCBEND() //Fim da Imagem da Etiqueta                 


MSCBCLOSEPRINTER()
MsgAlert("passou close")	    

//For cont := 1 to len(aProd)
 	
  	
	/*
	If nY>3
		nY := 1
		nX++
	EndIf            
	
	if aprod[nX][nY] == "0"
		MSCBEND()
		MSCBCLOSEPRINTER()
		Return
	endif
	
	//------------------------------ ETIQUETA 1 ---------------------------------------
	if nY=1
		MSCBSAY(    6   ,19   , "SUA STRING AQUI EQIQUETA 1 " ,"N"       ,"2"         ,"000,000")
		MSCBSAY(    6   ,13   ,       cDesc      ,"N"       ,"1"         ,"000,000")
		MSCBSAYBAR( 1   ,4   ,cCodBar  ,"N" ,"MB07"      ,5,.F.,.T.,.F.,'C',3 ,2,.f.,.F.)
	endif
	//---------------------------------------------------------------------------------
	
	
	nY++
	
	if aprod[nX][nY] == "0"
		MSCBEND()
		MSCBCLOSEPRINTER()
		Return
	endif
	
	//------------------------------ ETIQUETA 2---------------------------------------------------
	if nY = 2
		MSCBSAY(   42   ,19   , "SUA STRING AQUI EQIQUETA 2 " ,"N"       ,"2"         ,"000,000")
		MSCBSAY(   42   ,13   ,       cDesc      ,"N"       ,"1"         ,"000,000")
		MSCBSAYBAR( 37  ,4   ,        cCodBar    ,"N" ,"MB07"      ,5,.F.,.T.,.F.,'C',3 ,2,.f.,.F.)
	endif
	//---------------------------------------------------------------------------------------------
	
	nY++
	
	if aprod[nX][nY] == "0"
		MSCBEND()
		MSCBCLOSEPRINTER()
		Return
	endif
	
	//-------------------------------- ETIQUETA 3 -------------------------------------------------
	if nY = 3
		MSCBSAY(   78   ,19   , "SUA STRING AQUI EQIQUETA 3 " ,"N"       ,"2"         ,"000,000")
		MSCBSAY(   78   ,13   ,      cDesc       ,"N"       ,"1"         ,"000,000")
		MSCBSAYBAR( 73  ,4   ,      cCodBar      ,"N" ,"MB07"      ,5,.F.,.T.,.F.,'C',3 ,2,.f.,.F.)
	endif
	//---------------------------------------------------------------------------------------------
  
		nY++
		
	*/		
   
//Next
                                   
                      

Return .t.
