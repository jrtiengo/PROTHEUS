#include "rwmake.ch"      

User Function fImpInv()       

SetPrvt("NOPCA,")

*
*** Ajusta
*
* Programa para correcoes genericas com uso de arquivo externo ao Protheus

nOpca := 0

#IFDEF WINDOWS
       @ 96,42 TO 323,505 DIALOG oDlg TITLE "Rotina de Processamento"
       @ 8,10 TO 84,222
       @ 91,168 BMPBUTTON TYPE 1 ACTION OkProc()
       @ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg)
       @ 23,14 SAY "Faz os lancamento de inventario via DBF auxiliar."
       @ 33,14 SAY "Importa dados para a Tabela SB7. Se saldo negativo, irá importar"                     
       @ 43,14 SAY "como posição ZERO, se não com o saldo apresentado." 
       @ 53,14 SAY "A partir desta Importação deverá ser feito o Acerto do Inventário."
//       @ 43,14 SAY "Estes Produtos ficarao com os seus saldos zerados." 
       
       ACTIVATE DIALOG oDlg

#ENDIF

Return

Static Function OkProc()
Close(oDlg)
Processa( {|| AjusRun() } )
Return

*
*** AjusRun
*
*

Static Function AjusRun()
                                                 
// Inventario Almoxarifado Principal
cArq := CriaTrab("",.F.)
//dbUseArea(.t.,,"IMPINV","TMP")   
dbUseArea(.t.,,"ESTNEG_A","TMP")   
IndRegua("TMP",cArq,"COD_PRDO",,,OemToAnsi("Selecionando registros...."))

dbSelectArea("TMP")
ProcRegua(RecCount())
dbGoTop()
Do While !Eof()

      IncProc("Inventario Produto ... " + tmp->COD_PRDO)
      nRecNo := RecNo()
      
      dbSelectArea("SB1")
      dbSeek(xFilial("SB1") + tmp->COD_PRDO)
      
      If ! Found() 
      
         dbSelectArea("TMP")
         dbGoTo(nRecNo)
         RecLock("TMP",.F.)
            tmp->COD_PRDO := "*"+AllTrim(tmp->COD_PRDO)
         msUnlock()
         
         dbSkip()
         Loop
         
      EndIf
      
      _b7_filial  := xFilial("SB1")
      _b7_cod     := tmp->COD_PRDO
      _b7_local   := sb1->b1_locpad
      _b7_tipo    := sb1->b1_tipo
      _b7_doc     := "IMPNG4"
      _b7_quant   := 0 //Iif(tmp->qtd_prd < 0, (tmp->qtd_prd*-1),tmp->qtd_prd)
      _b7_qtsegum := ConvUM(_b7_cod,_b7_quant,0,2)
      _b7_data    := dDataBase
      _b7_dtvalid := dDataBase

      dbSelectArea("SB7")
      Reclock("SB7",.T.)

	      SB7->B7_FILIAL  := _b7_filial
	      SB7->B7_COD     := _b7_cod
	      SB7->B7_LOCAL   := _b7_local
	      SB7->B7_TIPO    := _b7_tipo
	      SB7->B7_DOC     := _b7_doc
	      SB7->B7_QUANT   := _b7_quant
	      SB7->B7_QTSEGUM := _b7_qtsegum
	      SB7->B7_DATA    := _b7_data
	      SB7->B7_DTVALID := _b7_dtvalid
      
      MsUnlock()

      dbSelectArea("TMP")
      dbGoTo(nRecNo)
      dbSkip()

Enddo

dbCloseArea("TMP")
dbCommitAll()

Return