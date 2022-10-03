#include 'protheus.ch'
#include 'parmtype.ch'
#include "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

// #########################################################################################
// -------------------------------------------------------------------------------------- ##
// Fonte: AtuMoeda.PRW                                                                    ##
// Tipo......: (X) Classe  ( ) Gatilho  ( ) Ponto de Entrada    	                      ##
// -------------------------------------------------------------------------------------- ##
// Autor.....: Leonardo Nichele - Sosys Business Insight       		                      ##
// Data......: 26/10/2021                                                                 ##
// Objetivo..: Rotina automática para atualizar as moedas do Protheus                     ##
//			   Moedas Protheus: 1-Real 2-US Dolar 3-UFIR 4-Euro 5-IENE                    ##
// 																					      ##
// #########################################################################################

Class TabelaMoedas

    Data cTipo AS STRING
    Data cData AS STRING

    Method new() CONSTRUCTOR
    Method BuscarMoeda()

EndClass

Method new(cTipMoeda,cDataAtu) class TabelaMoedas 

    ::cTipo := cTipMoeda // Recebe a abreviação de uma moeda
    ::cData := cDataAtu  // Recebe a data de atualização da moeda

Return Self

Method BuscarMoeda() class TabelaMoedas

    Local cTexto                          // Recebe o arquivo baixado
    Local cArqImpor := "\system\moedasbcb.csv" // Local e nome do arquivo baixado
    Local cLinha    := ""                      // Recebe as linhas do arquivo escrito
    Local nArquivo  := 0                       // Retorno da criação do arquivo txt
    Local nVal      := 0                       // Retorno de erro na criação de arquivo txt
    Local nValor    := 0                       // Recebe o valor da moeda passada
    Local aDados    := {}                      // Recebe os dados da linha atual

    cTexto  := HttpGet('https://www4.bcb.gov.br/Download/fechamento/'+Self:cData,,120,,) // Baixa o arquivo do BCB

    nArquivo := FCreate( cArqImpor, 0 ) // Cria um arquivo .txt na system    
    FWrite( nArquivo , cTexto)          // Escreve a cotação das moedas 
    fClose( nArquivo )                  // Fecha o arquivo criado

    ConOut('Arquivo BCB de '+Self:cData+' salvo.')

    nVal := fOpen(cArqImpor) //  Abertura do arquivo texto
    If nVal == -1 
        IF FERROR()== 516 
            ConOut("Feche a planilha que gerou o arquivo.")
        EndIf
    EndIf 

    If nVal == -1 // Verifica se foi possível abrir o arquivo
        cMsg := "O arquivo de nome "+cArqImpor+" nao pode ser aberto! Verifique os parametros."
        ConOut(cMsg)
        Return
    Endif
    
    FSEEK(nVal,0,0)                // Posiciona no Inicio do Arquivo
    nTamArq:=FSEEK(nVal,0,2)       // Traz o Tamanho do Arquivo TXT    
    FSEEK(nVal,0,0)                // Posicona novamemte no Inicio  
    fClose(nVal)                   // Fecha o Arquivo
    FT_FUse(cArqImpor)             // abre o arquivo 
    FT_FGOTOP()                    // posiciona na primeira linha do arquivo      
    nTamLinha := Len(FT_FREADLN()) // Ve o tamanho da linha
    FT_FGOTOP()                    // Volta ao início
                                                                
    aDados:={}          
    While !FT_FEOF()

        cLinha := FT_FREADLN() // Recebe a linha atual
        
        if(At("<!",cLinha)>0)
            MsgStop("Não foi encontrado no Banco Central o arquivo correspondente ("+::cData+")")
            Return
        Endif
        
        aDados  :=  Separa(cLinha,";",.T.)             
        cMoeda  := aDados[4]                
        cVenda  := aDados[5] 
  
        If ( ::cTipo == cMoeda )
            nValor := Val(StrTran(cVenda,",","."))
        EndIf   
        FT_FSKIP()
    EndDo

    FT_FUse()
    fClose(nVal)
Return (nValor)
