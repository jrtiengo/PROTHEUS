#include "TOTVS.CH"
//---------------------------------------------------------
// Exemplo de Impress�o e Visualiza��o
//---------------------------------------------------------
User Function PrintTest() 
Private cAcesso := Repl(" ",10)

  DEFINE DIALOG OMAINWND TITLE "Exemplo TBrush" FROM 180,180 TO 550,700 PIXEL

    // Monta objeto para impress�o
    oPrint := TMSPrinter():New("Exemplo de Impress�o")

    // Define orienta��o da p�gina para Retrato
    // pode ser usado oPrint:SetLandscape para Paisagem
    oPrint:SetPortrait()
    
    // Mostra janela de configura��o de impress�o
    oPrint:Setup()

    // Inicia p�gina
    oPrint:StartPage()            
    
    // Insere imagem
    oPrint:SayBitmap(10,10,"C:\Dir\Totvs.png",200,200)

    // Insere texto formatado
    oFont1 := TFont():New('Courier new',,-18,.T.)
    oPrint:Say(214,10,"Linha para teste de impress�o[Courier New 18]",oFont1)
    
    // Insere texto formatado e com mudan�a de Cor
    oFont2 := TFont():New('Tahoma',,-25,.T.)
    oPrint:Say(268,10,"Linha para teste de impress�o[Tahoma 25]",oFont2,,CLR_HRED)
    
    // Insere linha
    oPrint:Line(390,10,390,800)
    
    // Insere ret�ngulo
    oPrint:Box(440,10,640,800)
                                
    // Insere ret�ngulo preenchido          
    oBrush1 := TBrush():New( , CLR_HBLUE )
    oPrint:FillRect( {660, 10, 770, 800}, oBrush1 )

    // Visualiza a impress�o
    oPrint:EndPage()

    // Termina a p�gina
    oPrint:EndPage()
                       
    // Mostra tela de visualiza��o de impress�o
    oPrint:Preview() 
	
  ACTIVATE DIALOG OMAINWND CENTERED 
Return