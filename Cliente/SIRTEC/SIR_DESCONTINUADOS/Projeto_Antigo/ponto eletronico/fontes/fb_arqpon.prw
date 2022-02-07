#include "rwmake.ch"
#include "topconn.ch"

User Function FB_ARQPON()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB_ARQPON³ Autor ³ Evandro Mugnol        ³ Data ³ 26/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo dos apontamentos do ponto eletronico          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Utilizacao³ Especifico para Sirtec                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   Data   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oGeraTxt
Private cPerg := PADR("FB_ARQPON", LEN(SX1->X1_GRUPO)," ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela de processamento                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg()
If Pergunte(cPerg,.T.)
   @ 200,1 TO 400,380 DIALOG oGeraTxt TITLE OemToAnsi("Geração de Arquivo Ponto")
   @ 02,10 TO 080,190
   @ 10,018 Say " Este programa irá gerar um arquivo texto, conforme os parâmetros "
   @ 18,018 Say " definidos  pelo usuário, para a exportação das marcações do      "
   @ 26,018 Say " ponto da empresa Sirtec.                                         "
   @ 85,097 BMPBUTTON TYPE 01 ACTION GeraArq()  
   @ 85,127 BMPBUTTON TYPE 02 ACTION oGeraTxt:end()
   @ 85,158 BMPBUTTON TYPE 05 ACTION GeraPergs()
   Activate Dialog oGeraTxt Centered
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GERAARQ   ³ Autor ³ Evandro Mugnol       ³ Data ³ 26/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao chamada pelo botao OK na tela inicial de processa-  ³±±
±±³          ³ mento. Executa a geraco do arquivo das marcações do ponto. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraArq()

//_cDir := Alltrim(mv_par03)
//MakeDir(_cDir)
//Private cArqTxt := _cDir + "ponto_de_"+dtos(mv_par01)+"_a_"+dtos(mv_par02)+".txt"

Private cArqTxt := "\arqponto\arq_ponto_manual_"+dtos(mv_par01)+"_ate_"+dtos(mv_par02)+".txt"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GERAÇÃO DAS MARCAÇÕES                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File (cArqTxt)       // CASO EXISTA O ARQUIVO APAGA-O
   //AGUARDA DECISAO DO USUARIO
   If MsgYesNo("Já existe um arquivo com esse nome. Deseja sobrepor o arquivo existente?")
      nHdl := fErase(cArqTxt,2)
      nHdl := fCreate(cArqTxt)
   Else
      //CASO O USUARIO NAO QUEIRA APAGAR REABRE O ARQUIVO
      nHdl := fOpen(cArqTxt,1)
   EndIf
Else
   nHdl := fCreate(cArqTxt)
Endif

If nHdl == -1
   MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
   Return
Endif

// Inicializa a regua de processamento
Processa({|| RunArq() },"Processando...")

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RUNARQ    ³ Autor ³ Evandro Mugnol       ³ Data ³ 26/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar chamada pela PROCESSA. A funcao PROCESSA   ³±±
±±³          ³ monta a janela com a regua de processamento.               ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunArq()

Local _aAreaQry
Local _sQuery

//SELECIONA AS MARCAÇÕES NO PERÍODO ESPECIFICADO
_aAreaQry := GetArea()
_sQuery := ""
_sQuery += " SELECT SZ3.Z3_FILIAL, "
_sQuery += "        SZ3.Z3_MAT, "
_sQuery += "        SZ3.Z3_DATA, "
_sQuery += "        SZ3.Z3_HORA, "
_sQuery += "        SZ3.Z3_USER "
_sQuery += "   FROM "+RETSQLName("SZ3")+" SZ3 "
_sQuery += "  WHERE SZ3.D_E_L_E_T_ = '' "
_sQuery += "    AND SZ3.Z3_FILIAL  = '"+xFilial("SZ3")+"' "
_sQuery += "    AND SZ3.Z3_DATA between '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
_sQuery += "  ORDER BY SZ3.Z3_DATA, SZ3.Z3_HORA, SZ3.Z3_MAT "

DbUseArea(.t., 'TOPCONN', TcGenQry (,, _sQuery), '_sZ3', .f., .t.)
TCSetField ("_sZ3", "Z3_DATA", "D")

DbSelectArea("_sZ3")
DbGoTop()
While !EOF()
   // Faz a gravação do arquivo
   _sGrvArq := ""
   _sGrvArq += _sZ3->Z3_MAT                     // MATRICULA
   _sGrvArq += Dtos(_sZ3->Z3_DATA)              // DATA
   _sGrvArq += _sZ3->Z3_HORA                    // HORA
   _sGrvArq := _sGrvArq + chr (13) + chr (10)

   // grava a linha no arquivo
   fwrite(nHdl, _sGrvArq)
		
   DbSelectArea("_sZ3")
   DbSkip()
EndDo

_sZ3->( DbCloseArea() )
RestArea(_aAreaQry)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
//³ cao anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fClose(nHdl)
oGeraTxt:end()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GERAPERGS ³ Autor ³ Evandro Mugnol       ³ Data ³ 26/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao auxiliar chamada na selecao dos parametros para a   ³±±
±±³          ³ geracao do arquivo.                                        ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraPergs()

ValidPerg()
Pergunte(cPerg, .T.)
   
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VALIDPERG ³ Autor ³ Evandro Mugnol       ³ Data ³ 26/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria perguntas no SX1. Se a pergunta ja existir, atualiza. ³±±
±±³          ³ Se houver mais perguntas no SX1 do que as definidas aqui,  ³±±
±±³          ³ deleta as excedentes do SX1.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
local _aArea  := GetArea ()
local _aRegs  := {}
local _aHelps := {}
local _i      := 0
local _j      := 0

_aRegs = {}
//             GRUPO  ORDEM PERGUNT                     PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID VAR01       DEF01              DEFSPA1             DEFENG1             CNT01 VAR02 DEF02             DEFSPA2             DEFENG2            CNT02 VAR03 DEF03   DEFSPA3  DEFENG3  CNT03 VAR04 DEF04  DEFSPA4  DEFENG4  CNT04 VAR05 DEF05   DEFSPA5   DEFENG5  CNT05  F3      GRPSXG
AADD (_aRegs, {cPerg, "01", "Da Data                ?", "",    "",    "mv_ch1", "D", 08, 0,  0,     "G", "",   "mv_par01", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "",     ""})
AADD (_aRegs, {cPerg, "02", "Ate a Data             ?", "",    "",    "mv_ch2", "D", 08, 0,  0,     "G", "",   "mv_par02", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "",     ""})
//AADD (_aRegs, {cPerg, "03", "Diretorio de Destino   ?", "",    "",    "mv_ch3", "C", 50, 0,  0,     "G", "",   "mv_par03", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "",     ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
AADD (_aHelps, {"01", {"Informe a data inicial para geracao das ", "marcacoes                               ", "                                        "}})
AADD (_aHelps, {"02", {"Informe a data final para geracao das   ", "marcacoes                               ", "                                        "}})
//AADD (_aHelps, {"03", {"Informe o diretorio de destino a ser    ", "gerado a exportação das informações.    ", "Ex.: C:\PONTO\                          "}})

DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
    If ! DbSeek (cPerg + _aRegs [_i, 2])
       RecLock("SX1", .T.)
    Else
       RecLock("SX1", .F.)
    Endif
    For _j := 1 to FCount ()
       // Campos CNT nao sao gravados para preservar conteudo anterior.
       If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
          FieldPut(_j, _aRegs [_i, _j])
       Endif
    Next
    MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (cPerg, .T.)
do while ! eof () .and. x1_grupo == cPerg
   if ascan (_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
      reclock("SX1", .F.)
      dbdelete()
      msunlock()
   endif
   dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len (_aHelps)
   PutSX1Help ("P." + AllTrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next

Restarea(_aArea)

Return
