#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Mrop2()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("TITULO,CSTRING,WNREL,CDESC1,CDESC2,TAMANHO")
SetPrvt("ARETURN,NLASTKEY,CPERG,CRODATXT,NCNTIMPR,NTIPO")
SetPrvt("NOMEPROG,NTOTREGS,NMULT,NPOSANT,NPOSATU,NPOSCNT")
SetPrvt("COPANT,LCONTINUA,CCAMPOCUS,LI,M_PAG,NEWHEAD")
SetPrvt("CABEC1,CABEC2,CNOMARQ,CCONDICAO,NTOTREQ,NTOTPROD")
SetPrvt("NTOTVEN,NTOTDEVVEN,NTOTDEV,NTOTREQMOD,NTOTDEVMOD,NTOTVEND")
SetPrvt("NTOTVENDA,NQUANTREQ,NQUANTPROD,NQUANTDEV,NQTDREQMOD,NQTDDEVMOD")
SetPrvt("VVENDA,VTOTVE,CFILIAL,LEND,NTOTQUANT,NTOTCUSTO")
SetPrvt("NQTDEPROD,NTOTQUANTMOD,NTOTCUSTOMOD,NCUSTO,NVENDA,")

/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
쿏escri뇚o 쿝elacao Das Ordens de Producao       �
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
*/
titulo     := "Relacao por Ordem de Producao"  //STR0001 
cString    := "SD3"
wnrel      := "MATR860"
cDesc1     := "O objetivo deste relat줿io � exibir detalhadamente todas as movimenta-" //STR0002
cDesc2     := "뇯es feitas para cada Ordem de Produ뇙o "
Tamanho    := "M"
aReturn    := {"Zebrado",1,"Administracao", 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
nLastKey   := 0
cPerg      := "MTR860"
cRodaTxt   := ""
nCntImpr   := 0
nTipo      := 15
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros                         �
//� mv_par01     // OP inicial                                   �
//� mv_par02     // OP final                                     �
//� mv_par03     // moeda selecionada ( 1 a 5 )                  �
//� mv_par04     // De  Data Movimentacao                        �
//� mv_par05     // Ate Data Movimentacao                        �
//� mv_par06     // Totaliza Mov.do mat. movimentados pela O.P.  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
pergunte(cPerg,.F.)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT                        �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,"",.F.,"")
If nLastKey == 27
   Set Filter To
   Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
   Set Filter To
   Return
Endif
R666Imp()
Return NIL
/*
旼컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿑un뇙o    � 666Imp                               �
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
쿏escri뇙o � Chamada do Relat줿io                 �                    
쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
� Uso      � MATR666                              �                      
읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
*/                                                
//Function R666Imp(lEnd,wnRel,titulo,tamanho)
// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function R666Imp
Static Function R666Imp()
titulo     := "Relacao por Ordem de Producao"  //STR0001 
cString    := "SD3"
wnrel      := "MATR860"
cDesc1     := "O objetivo deste relat줿io � exibir detalhadamente todas as movimenta-" //STR0002
cDesc2     := "뇯es feitas para cada Ordem de Produ뇙o "
Tamanho    := "M"
aReturn    := {"Zebrado",1,"Administracao", 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
nLastKey   := 0
cPerg      := "MTR860"
cRodaTxt   := ""
nCntImpr   := 0
nTipo      := 15
nomeprog   := "MATR860"
nTotRegs   := 0 
nMult      := 1 
nPosAnt    := 4 
nPosAtu    := 4 
nPosCnt    := 0
cOpAnt     := .T.
lContinua  := .T.
cCampoCus  := .T.
li := 80 
m_pag := 1
nTipo  := 15 // IIF(aReturn[4]==1,15,18)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Adiciona informacoes ao titulo do relatorio   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
/*
If Type("NewHead")#"U"
    NewHead := NewHead +" - "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))
Else
    Titulo  := Titulo + " - "+AllTrim(&("MV_SIMB"+Str(mv_par03,1)))
EndIf
  */
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Monta os Cabecalhos                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cabec1 := "NUMERO DO   MOV CODIGO DO       DESCRICAO                   QUANTIDADE UM                                  VENDA      V E N D A"
cabec2 := "DOCUMENTO       PRODUTO                                                                                 UNITARIA      T O T A L"
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define o campo a ser impresso no valor de acordo com a moeda selecionada �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Do Case
	Case mv_par03 == 1
		cCampoCus :=   "SD3->D3_COMPRA"
	Case mv_par03 == 2
		cCampoCus :=   "SD3->D3_CUSTO2"
	Case mv_par03 == 3
		cCampoCus :=   "SD3->D3_CUSTO3"
	Case mv_par03 == 4
		cCampoCus :=   "SD3->D3_CUSTO4"
	Case mv_par03 == 5
		cCampoCus :=   "SD3->D3_CUSTO5"
EndCase

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Pega o nome do arquivo de indice de trabalho  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cNomArq := CriaTrab("",.F.)
dbSelectArea("SD3")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Cria o indice de trabalho                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//Index On D3_FILIAL+D3_OP+SubStr(D3_CF,2,1)+D3_NUMSEQ+D3_COD To &(cNomArq)
#IFNDEF TOP
	cCondicao:="D3_EMISSAO >= mv_par04 .And. D3_EMISSAO <= mv_par05"
    IndRegua("SD3",cNomArq,"D3_FILIAL+D3_OP+SubStr(D3_CF,2,1)+D3_NUMSEQ+D3_COD",,cCondicao,"Selecionando Registros...")
#ELSE
	cCondicao := 'D3_FILIAL == "'+xFilial("SD3")+'" .And. D3_OP >= "'+mv_par01+'"'
	cCondicao += ' .And. D3_OP <= "'+mv_par02+'" .And. DTOS(D3_EMISSAO) >= "'+DTOS(mv_par04)+'".And. DTOS(D3_EMISSAO) <= "'+DTOS(mv_par05)+'"'
    IndRegua("SD3",cNomArq,"D3_FILIAL+D3_OP+D3_CF+D3_NUMSEQ+D3_COD",,cCondicao,"Selecionando Registros...")
#ENDIF	
dbGoTop()

nTotReq     :=nTotProd    := nTotVen   := nTotDevVen := nTotDev := 0
nTotReqMod  :=nTotDevMod  := nTotVend  := 0
nTotVenda   := 0
nQuantReq   :=nQuantProd  := nQuantDev :=0
nQtdReqMod  :=nQtdDevMod  := 0
vVENDA := 0
vTOTVE := 0
//SetRegua(LastRec())
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Correr SD3 para ler as REs, DEs e Producoes.  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
cFilial := xFilial("SD3")
#IFNDEF TOP
	dbSeek(cFilial+mv_par01,.T.)
#ENDIF

While lContinua .And. !Eof() .AND. D3_FILIAL+D3_OP <= cFilial+mv_par02

	#IFNDEF WINDOWS
        If LastKey() == 286    //ALT_A
			lEnd := .t.
		End
    #ENDIF             

	If lEnd
        @ PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
		Exit
	EndIf
     //COMENTADO INCREGUA
	//IncRegua()
    //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    //� Correr SD3 para a mesma OP.               �
    //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	nTotQuant := nTotCusto := nQtdeProd := 0
	nTotQuantMod := nTotCustoMod := 0
	cOpAnt := cFilial+D3_OP
    While !Eof() .AND. D3_FILIAL+D3_OP == cOpAnt

		#IFNDEF WINDOWS
            If LastKey() == 286    //ALT_A
				lEnd := .t.
			End
		#ENDIF

		If lEnd
            @ PROW()+1,001 PSay "CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIf   //COMENTADO INCREGUA
                //IncRegua()
		If li > 58
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIf
		If D3_ESTORNO == "S"
			dbSkip()
			Loop
		EndIf	
		nCusto := &(cCampoCus)
        nVenda := SD3->D3_PRCVEN
        If SubStr(SD3->D3_COD,1,3) != "MOD"
            nTotQuant := nTotQuant + IIf( SubStr(D3_CF,1,2) == "RE", SD3->D3_QUANT, 0 )
            nTotCusto := nTotCusto + IIf( SubStr(D3_CF,1,2) == "RE", nCusto, 0 )
            nTotVenda := nTotVenda + IIf( SubStr(D3_CF,1,2) == "RE", nVenda, 0 )
                     
            nTotQuant := nTotQuant + IIf( SubStr(D3_CF,1,2) == "DE", ( -D3_QUANT ), 0 )
            nTotCusto := nTotCusto + IIf( SubStr(D3_CF,1,2) == "DE", ( -nCusto )  , 0 )
            nTotVenda := nTotVenda + IIf( SubStr(D3_CF,1,2) == "DE", ( -nVenda )  , 0 )
		Else
            //旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            //� Totaliza뇙o separada para a m꼘-de-obra �
            //읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
            nTotQuantMod := nTotQuantMod + IIf( SubStr(D3_CF,1,2) == "RE", SD3->D3_QUANT, 0 )
            nTotCustoMod := nTotCustoMod + IIf( SubStr(D3_CF,1,2) == "RE", nCusto, 0 )
                                         
            nTotQuantMod := nTotQuantMod + IIf( SubStr(D3_CF,1,2) == "DE", ( -D3_QUANT ), 0 )
            nTotCustoMod := nTotCustoMod + IIf( SubStr(D3_CF,1,2) == "DE", ( -nCusto ), 0 )
		EndIf

        nQtdeProd := nQtdeProd + IIf( SubStr(D3_CF,1,2) == "PR",  SD3->D3_QUANT , 0 )
        nQtdeProd := nQtdeProd + IIf( SubStr(D3_CF,1,2) == "ER", -D3_QUANT , 0 )

		dbSelectArea("SB1")
		dbSeek(cFilial+SD3->D3_COD)
		dbSelectArea("SD3")
		If SubStr(D3_CF,1,2) == "PR"
            LI := LI + 1
		EndIf	
        @ Li,000 PSay D3_DOC
        @ Li,012 PSay SD3->D3_CF
        @ Li,016 PSay D3_COD
        @ Li,032 PSay SubStr(SB1->B1_DESC,1,25)
		If SubStr(D3_CF,1,2) == "DE"
           @ Li,060 PSay ( -D3_QUANT )       Picture    PesqPictQt("D3_QUANT",12)
           @ Li,071 PSay D3_UM
           // @ Li,076 PSay ( nCusto/D3_QUANT ) Picture PesqPict("SD3","D3_COMPRA",10)
           // @ Li,089 PSay ( -nCusto )         Picture PesqPict("SD3","D3_COMPRA",12)
           @ Li,103 PSay ( nVenda/D3_QUANT ) Picture "999,999.99"
           @ Li,116 PSay ( -nVenda )         Picture "9,999,999.99"
		Else	
           @ Li,060 PSay SD3->D3_QUANT            Picture PesqPictQt("D3_QUANT",12)
           @ Li,071 PSay D3_UM
           // @ Li,076 PSay ( nCusto/D3_QUANT ) Picture PesqPict("SD3","D3_COMPRA",14)
           // @ Li,089 PSay ( nCusto          ) Picture PesqPict("SD3","D3_COMPRA",16)
           @ Li,103 PSay ( nVenda/D3_QUANT ) Picture "999,999.99"
           @ Li,116 PSay ( nVenda )          Picture "9,999,999.99"
		EndIf
        LI := LI + 1
		
		If SubStr(SD3->D3_COD,1,3) != "MOD"
           If SubStr(D3_CF,1,2) == "RE"
               nTotReq     := nTotReq   + nCusto
               nQuantReq   := nQuantReq + SD3->D3_QUANT
               nTotVen     := nTotVen   + nVenda
           Elseif SubStr(D3_CF,1,2) == "DE"
               nTotDev     := nTotDev     + nCusto
               nQuantDev   := nQuantDev   + SD3->D3_QUANT
               nTotDevVen  := nTotDevVen  + nVenda
           Endif
		Else
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Totaliza뇙o separada para a m꼘-de-obra                  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If SubStr(D3_CF,1,2) == "RE"
               nTotReqMod   := nTotReqMod + nCusto
               nQtdReqMod   := nQtdReqMod + SD3->D3_QUANT
			Elseif SubStr(D3_CF,1,2) == "DE"
                nTotDevMod  := nTotDevMod + nCusto
                nQtdDevMod  := nQtdDevMod + SD3->D3_QUANT
         Endif
		EndIf

		If SubStr(D3_CF,1,2) == "PR"
           nTotProd   := nTotProd   + nCusto
           nTotVend   := nTotVend   + nVenda
           nQuantProd := nQuantProd + SD3->D3_QUANT
		Endif
		dbSkip()
	End
	If (nTotQuant+nTotQuantMod) != 0
        LI := LI + 1
        @ Li,000 PSay "TOTAL  " + SubStr(cOpAnt,3,11)
        //@ Li,019 PSay "Custo STD : "
        //@ Li,033 PSay SB1->B1_CUSTD Picture PesqPict("SB1","B1_CUSTD",10)
        //@ Li,047 PSay "/"
        //@ Li,052 PSay ( SB1->B1_CUSTD * nQtdeProd )    Picture "9,999,999.99" // Picture PesqPict("SB1","B1_CUSTD",12)
		If mv_par06 == 1
           @ Li,060 PSay nTotQuant                     Picture PesqPictQt("D3_QUANT",12)
		Endif	
           //@ Li,089 PSay nTotCusto                     Picture PesqPict("SD3","D3_COMPRA",12)
           @ Li,116 PSay nTotVenda                     Picture "9,999,999.99"
        LI := LI + 1
        If nTotQuantMod <> 0 //.OR. nTotCustoMod <> 0
           @ Li,000 PSay "       MAO DE OBRA:"
           @ Li,060 PSay nTotQuantMod Picture PesqPictQt("D3_QUANT",12)
           //@ Li,089 PSay nTotCustoMod Picture PesqPict("SD3","D3_COMPRA",16)
           LI := LI + 1
		Endif
	EndIf

	@ Li,000 PSay Replicate("-",132)
    Li := LI + 2

EndDo

If li != 80
    LI := LI + 1
    @ Li,000 PSay "TOTAL REQUISICOES ---->"
	If mv_par06 == 1
       @ Li,068 PSay nQuantReq  Picture PesqPictQt("D3_QUANT",12)
	EndIf
    //@ Li,103 PSay nTotReq       Picture PesqPict("SD3","D3_COMPRA",14)
    LI := LI + 1
	If li > 58
       Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
    @ Li,000 PSay "TOTAL PRODUCAO    ---->"
	If mv_par06 == 1
       @ Li,058 PSay nQuantProd Picture PesqPictQt("D3_QUANT",12)
	EndIf
    //@ Li,089 PSay nTotProd      Picture PesqPict("SD3","D3_COMPRA",12)
    @ Li,116 PSay nTotVend      Picture "99,999,999.99"
    LI := LI + 1
    @ Li,000 PSay "TOTAL DEVOLUCOES  ---->"
	If mv_par06 == 1
       @ Li,058 PSay nQuantDev  Picture PesqPictQt("D3_QUANT",12)
	EndIf
       //@ Li,089 PSay nTotDev     Picture PesqPict("SD3","D3_COMPRA",12)
       @ Li,116 PSay nTotDevVen  Picture "99,999,999.99"
   LI := LI + 1
	If li > 57
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf

	If nTotReqMod <> 0
        @ Li,000 PSay "TOTAL REQUISICOES MAO DE OBRA ---->"
		If mv_par06 == 1
           @ Li,068 PSay nQtdReqMod  Picture PesqPictQt("D3_QUANT",12)
		EndIf
           //@ Li,102 PSay nTotReqMod  Picture PesqPict("SD3","D3_COMPRA",14)
        LI := LI + 1
	EndIf
	If nTotDevMod <> 0
        @ Li,000 PSay "TOTAL DEVOLUCOES  MAO DE OBRA ---->"
		If mv_par06 == 1
           @ Li,068 PSay nQtdDevMod   Picture PesqPictQt("D3_QUANT",12)
		EndIf
           //@ Li,103 PSay nTotDevMod   Picture PesqPict("SD3","D3_COMPRA",14)
        LI := LI + 1
	Endif
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Devolve as ordens originais do arquivo                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
RetIndex("SD3")
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Apaga indice de trabalho                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomArq := cNomArq + OrdBagExt()
FErase( cNomArq )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Devolve a condicao original do arquivo principal             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("SD3")
RetIndex("SD3")
Set Filter To
dbSetOrder(1)
Set device to Screen
If aReturn[5] == 2
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return NIL

