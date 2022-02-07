#include "rwmake.ch"
#include "topconn.ch"

User Function FB951TEC()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FB951TEC � Autor � Evandro Mugnol        � Data �25/11/2009���
�������������������������������������������������������������������������Ĵ��
���Unidade   � Serra Gaucha     �Contato � evandro.mugnol@totvs.com.br    ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Geracao de arquivo TXT referente aos apontamentos do field ���
���          � service para serem importados pelo ponto eletronico.       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para Sirtec                                     ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �      �                                        ���
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Private oGeraTxt
Private cPerg := PADR("FB951TEC", 10, " ")  //PADR("FB951TEC", LEN(SX1->X1_GRUPO), " ")

//���������������������������������������������������������������������Ŀ
//� Montagem da tela de processamento                                   �
//�����������������������������������������������������������������������
ValidPerg()
If Pergunte(cPerg,.T.)
   @ 200,1 TO 400,380 DIALOG oGeraTxt TITLE OemToAnsi("Gera��o de Arquivo p/ Ponto")
   @ 02,10 TO 080,190
   @ 10,018 Say " Este programa ir� gerar um arquivo texto, conforme os par�metros "
   @ 18,018 Say " definidos  pelo usu�rio,  para a exporta��o das informa��es das  "
   @ 26,018 Say " ordens de servi�o do Field Service para o Ponto Eltr�nico.       "
   @ 85,097 BMPBUTTON TYPE 01 ACTION Processa({||GeraArq()},"Selecionando Registros...")
   @ 85,127 BMPBUTTON TYPE 02 ACTION oGeraTxt:end()
   @ 85,158 BMPBUTTON TYPE 05 ACTION GeraPergs()
   Activate Dialog oGeraTxt Centered
EndIf

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GERAARQ   � Autor � Evandro Mugnol       � Data � 25/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao chamada pelo botao OK na tela inicial de processa-  ���
���          � mento. Executa a geraco do arquivo texto para o ponto.     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function GeraArq()

//_cDir := Alltrim(mv_par03)
//MakeDir(_cDir)
//Private cArqTxt := _cDir + "arq_field_service_ponto_"+dtos(mv_par01)+"_ate_"+dtos(mv_par02)+".txt"

Private cArqTxt := "\arqponto\arq_field_service_ponto_"+dtos(mv_par01)+"_ate_"+dtos(mv_par02)+".txt"

//��������������������������������������������������������������Ŀ
//� GERA��O DO ARQUIVO                                           �
//����������������������������������������������������������������
If File (cArqTxt)       // CASO EXISTA O ARQUIVO DE NOTAS APAGA-O
   //AGUARDA DECISAO DO USUARIO
   If MsgYesNo("J� existe um arquivo com esse nome. Deseja sobrepor o arquivo existente?")
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � RUNARQ    � Autor � Evandro Mugnol       � Data � 25/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao auxiliar chamada pela PROCESSA. A funcao PROCESSA   ���
���          � monta a janela com a regua de processamento.               ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RunArq()

_aAreaQry := GetArea()
	
_sQuery := ""
_sQuery += " SELECT AB9.AB9_FILIAL, "
_sQuery += "        AB9.AB9_CODTEC, "
_sQuery += "        AB9.AB9_SEQ, "
_sQuery += "        AB9.AB9_DTCHEG, "
_sQuery += "        AB9.AB9_HRCHEG, "
_sQuery += "        AB9.AB9_HRSAID, "
_sQuery += "        AB9.AB9_YIINT, "
_sQuery += "        AB9.AB9_YFINT "
_sQuery += "   FROM "+RETSQLName("AB9")+" AB9 "
_sQuery += "  WHERE AB9.D_E_L_E_T_ = '' "
_sQuery += "    AND AB9.AB9_FILIAL  = '"+xFilial("AB9")+"' "
_sQuery += "    AND AB9.AB9_DTCHEG between '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
_sQuery += "  ORDER BY AB9.AB9_DTCHEG, AB9.AB9_HRCHEG, AB9.AB9_CODTEC, AB9.AB9_SEQ "

DbUseArea(.t., 'TOPCONN', TcGenQry (,, _sQuery), 'TRBAB9', .f., .t.)
TCSetField ("TRBAB9", "AB9_DTCHEG", "D")

DbSelectArea("TRBAB9")
DbGoTop()
ProcRegua(TRBAB9->(Reccount()))
While !Eof()
   IncProc("Processando T�cnico " + TRBAB9->AB9_CODTEC + " ...")
   
   _cCodTec := TRBAB9->AB9_CODTEC

   DbSelectArea("ZZ4")
   DbSetOrder(1)
   DbSeek(xFilial("ZZ4") + _cCodTec)
   If Found()
      While !Eof() .And. ZZ4->ZZ4_FILIAL + ZZ4->ZZ4_EQUIPE == xFilial("ZZ4") + _cCodTec
		   // Faz a grava��o do arquivo para Hora de Chegada
		   _sGrvArq := ""
		   _sGrvArq += ZZ4->ZZ4_CODSRA                      // MATRICULA
		   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)            // DATA CHEGADA
		   _sGrvArq += TRBAB9->AB9_HRCHEG                   // HORA CHEGADA
		   _sGrvArq := _sGrvArq + chr (13) + chr (10)
		   // Grava a linha no arquivo
		   fwrite(nHdl, _sGrvArq)
				      
		   // Faz a grava��o do arquivo para Hora de Sa�da
		   _sGrvArq := ""
		   _sGrvArq += ZZ4->ZZ4_CODSRA                      // MATRICULA
		   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
		   _sGrvArq += TRBAB9->AB9_HRSAIDA                  // HORA SAIDA
		   _sGrvArq := _sGrvArq + chr (13) + chr (10)
		   // Grava a linha no arquivo
		   fwrite(nHdl, _sGrvArq)

			// Faz a grava��o do arquivo para In�cio Intervalo
         If !Empty(TRBAB9->AB9_YIINT)
			   _sGrvArq := ""
			   _sGrvArq += ZZ4->ZZ4_CODSRA                      // MATRICULA
			   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
			   _sGrvArq += TRBAB9->AB9_YIINT                    // INICIO INTERVALO
			   _sGrvArq := _sGrvArq + chr (13) + chr (10)
			   // Grava a linha no arquivo
			   fwrite(nHdl, _sGrvArq)
			Endif
	
			// Faz a grava��o do arquivo para Final Intervalo
         If !Empty(TRBAB9->AB9_YFINT)
			   _sGrvArq := ""
			   _sGrvArq += ZZ4->ZZ4_CODSRA                      // MATRICULA
			   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
			   _sGrvArq += TRBAB9->AB9_YFINT                    // FINAL INTERVALO
			   _sGrvArq := _sGrvArq + chr (13) + chr (10)
			   // Grava a linha no arquivo
			   fwrite(nHdl, _sGrvArq)
			Endif
      
         DbSelectArea("ZZ4")
         DbSkip()
      Enddo
   Else
	   DbSelectArea("AA1")
	   DbSetOrder(1)
	   DbSeek(xFilial("AA1") + _cCodTec)
	   If Found()
		   // Faz a grava��o do arquivo para Hora de Chegada
		   _sGrvArq := ""
		   _sGrvArq += AA1->AA1_CODSRA                      // MATRICULA
		   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
		   _sGrvArq += TRBAB9->AB9_HRCHEG                   // HORA CHEGADA
		   _sGrvArq := _sGrvArq + chr (13) + chr (10)
		   // Grava a linha no arquivo
		   fwrite(nHdl, _sGrvArq)

		   // Faz a grava��o do arquivo para Hora de Sa�da
		   _sGrvArq := ""
		   _sGrvArq += AA1->AA1_CODSRA                      // MATRICULA
		   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
		   _sGrvArq += TRBAB9->AB9_HRSAIDA                  // HORA SAIDA
		   _sGrvArq := _sGrvArq + chr (13) + chr (10)
		   // Grava a linha no arquivo
		   fwrite(nHdl, _sGrvArq)

			// Faz a grava��o do arquivo para In�cio Intervalo
         If !Empty(TRBAB9->AB9_YIINT)
			   _sGrvArq := ""
			   _sGrvArq += AA1->AA1_CODSRA                      // MATRICULA
			   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
			   _sGrvArq += TRBAB9->AB9_YIINT                    // INICIO INTERVALO
			   _sGrvArq := _sGrvArq + chr (13) + chr (10)
			   // Grava a linha no arquivo
			   fwrite(nHdl, _sGrvArq)
			Endif
	
			// Faz a grava��o do arquivo para Final Intervalo
         If !Empty(TRBAB9->AB9_YFINT)
			   _sGrvArq := ""
			   _sGrvArq += AA1->AA1_CODSRA                      // MATRICULA
			   _sGrvArq += Dtos(TRBAB9->AB9_DTCHEG)             // DATA CHEGADA
			   _sGrvArq += TRBAB9->AB9_YFINT                    // FINAL INTERVALO
			   _sGrvArq := _sGrvArq + chr (13) + chr (10)
			   // Grava a linha no arquivo
			   fwrite(nHdl, _sGrvArq)
			Endif
	   Endif
   Endif

   DbSelectArea("TRBAB9")
   DbSkip()
Enddo

TRBAB9->(DbCloseArea())

RestArea(_aAreaQry)

//���������������������������������������������������������������������������������Ŀ
//� O arquivo texto deve ser fechado, bem como o dialogo criado na fun��o anterior  �
//�����������������������������������������������������������������������������������
fClose(nHdl)
oGeraTxt:end()

If MsgYesNo("Gera��o do Arquivo Finalizada!"+chr(13)+chr(13)+"Deseja Chamar Rotina do Ponto para Leitura ?")
   // Chama Rotina de Leitura do Ponto
   PONM010()
Endif

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � GERAPERGS � Autor � Evandro Mugnol       � Data � 25/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao auxiliar chamada na selecao dos parametros para a   ���
���          � geracao do arquivo.                                        ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function GeraPergs()

ValidPerg()
Pergunte(cPerg, .T.)
   
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VALIDPERG � Autor � Evandro Mugnol       � Data � 25/11/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria perguntas no SX1. Se a pergunta ja existir, atualiza. ���
���          � Se houver mais perguntas no SX1 do que as definidas aqui,  ���
���          � deleta as excedentes do SX1.                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ValidPerg()
local _aArea  := GetArea ()
local _aRegs  := {}
local _aHelps := {}
local _i      := 0
local _j      := 0

_aRegs = {}
//             GRUPO  ORDEM PERGUNT                     PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID VAR01       DEF01              DEFSPA1             DEFENG1             CNT01 VAR02 DEF02             DEFSPA2             DEFENG2            CNT02 VAR03 DEF03   DEFSPA3  DEFENG3  CNT03 VAR04 DEF04  DEFSPA4  DEFENG4  CNT04 VAR05 DEF05   DEFSPA5   DEFENG5  CNT05  F3      GRPSXG
AADD (_aRegs, {cPerg, "01", "Da Data Lan�amento     ?", "",    "",    "mv_ch1", "D", 08, 0,  0,     "G", "",   "mv_par01", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "",     ""})
AADD (_aRegs, {cPerg, "02", "At� a Data Lan�amento  ?", "",    "",    "mv_ch2", "D", 08, 0,  0,     "G", "",   "mv_par02", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "",     ""})
//AADD (_aRegs, {cPerg, "03", "Diret�rio de Destino   ?", "",    "",    "mv_ch3", "C", 50, 0,  0,     "G", "",   "mv_par03", "",                 "",                 "",                 "",   "",   "",                "",                "",                "",   "",   "",     "",      "",      "",   "",   "",    "",      "",      "",   "",   "",      "",      "",      "",   "",     ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
AADD (_aHelps, {"01", {"Informe a data de lancto inicial para a ", "gera��o do arquivo.                     ", "                                        "}})
AADD (_aHelps, {"02", {"Informe a data de lancto final para a   ", "gera��o do arquivo.                     ", "                                        "}})
//AADD (_aHelps, {"03", {"Informe o diretorio de destino a ser    ", "gerado as informa��es.                  ", "Ex.: C:\FIELD\PONTO\                    "}})

/*
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
*/

Restarea(_aArea)

Return
