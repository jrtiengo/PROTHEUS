#include "TOTVS.CH"
//---------------------------------------------------------
// Exemplo de Impressão e Visualização
//---------------------------------------------------------
User Function PrintTest() 
Private cAcesso := Repl(" ",10)

  DEFINE DIALOG OMAINWND TITLE "Exemplo TBrush" FROM 180,180 TO 550,700 PIXEL

    // Monta objeto para impressão
    oPrint := TMSPrinter():New("Exemplo de Impressão")

    // Define orientação da página para Retrato
    // pode ser usado oPrint:SetLandscape para Paisagem
    oPrint:SetPortrait()
    
    // Mostra janela de configuração de impressão
    oPrint:Setup()

    // Inicia página
    oPrint:StartPage()            
    
    // Insere imagem
    oPrint:SayBitmap(10,10,"C:\Dir\Totvs.png",200,200)

    // Insere texto formatado
    oFont1 := TFont():New('Courier new',,-18,.T.)
    oPrint:Say(214,10,"Linha para teste de impressão[Courier New 18]",oFont1)
    
    // Insere texto formatado e com mudança de Cor
    oFont2 := TFont():New('Tahoma',,-25,.T.)
    oPrint:Say(268,10,"Linha para teste de impressão[Tahoma 25]",oFont2,,CLR_HRED)
    
    // Insere linha
    oPrint:Line(390,10,390,800)
    
    // Insere retângulo
    oPrint:Box(440,10,640,800)
                                
    // Insere retângulo preenchido          
    oBrush1 := TBrush():New( , CLR_HBLUE )
    oPrint:FillRect( {660, 10, 770, 800}, oBrush1 )

    // Visualiza a impressão
    oPrint:EndPage()

    // Termina a página
    oPrint:EndPage()
                       
    // Mostra tela de visualização de impressão
    oPrint:Preview() 
	
  ACTIVATE DIALOG OMAINWND CENTERED 
Return