#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH" 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CalCFGFi � Autor � Reiner Trennepohl     � Data � 05/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para alteracao de filiais conforme tabela SX2     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CalCFGFi()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function CalCFGFi()

Local cArqSx2,cIndSx2 
Private cPerg   := "CALCFGFIL"      

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
AjustaSX1()

//�������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros	              �
//� mv_par01		 // Da Filial 	  		              �
//� mv_par02		 // � Filial 	     	              �
//� mv_par03		 // Selecionar todas as tabelas       �
                     // ou somente a posicionada 		  �
//���������������������������������������������������������
//If !Pergunte("CALCFGFIL ",.F.)
//	Return
//Endif

/*/
*��������������������������������������������������������������Ŀ
*� Salva a Integridade dos dados de Entrada                     �
*����������������������������������������������������������������
*��������������������������������������������������������������Ŀ
* Define Array contEndo as Rotinas a executar do programa      �
* ----------- Elementos contidos por dimensao ------------     �
* 1. Nome a aparecer no cabecalho                              �
* 2. Nome da Rotina associada                                  �
* 3. Usado pela rotina                                         �
* 4. Tipo de Transa��o a ser efetuada                          �
*    1 - Pesquisa e Posiciona em um Banco de Dados             �
*    2 - Simplesmente Mostra os Campos                         �
*    3 - Inclui registros no Bancos de Dados                   �
*    4 - Altera o registro corrente                            �
*    5 - Remove o registro corrente do Banco de Dados          �
*����������������������������������������������������������������
/*/                     
Private aRotina := { {"Pesquisar"  ,"AXPESQUI"   ,0, 1 },; 
                     { "Visualizar","AxVisual"   ,0, 2 },;
                     { "Alterar"   ,"AxFilAlt"   ,0, 3 },; 
                     { "Parametros","U_CalFilPar",0, 4 } } 
                     
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro := OemToAnsi("Rotina para Altera��o de Filiais")
Private cFilAtu   := ""
Private cFilNew   := ""

*�����������������������������������������������������������������������������Ŀ
*� Aguarda Liberacao de Arquivos por outras estacoes para abrir SX2 Exclusivo  �
*�������������������������������������������������������������������������������
cArqSx2 := "SX2" + SM0->M0_CODIGO + "0"
cIndSx2 = cArqSx2
If !OpenSX2Excl(cArqSx2,cIndSx2)
   Return
EndIf

DbSelectArea("SX2")
Set Filter To
Set Filter To X2_MODO == "E"
DbGoTop()

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
//mBrowse( 6, 1,22,75,"SX2") // 32

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados                             �
//����������������������������������������������������������������
If Pergunte(cPerg,.T.)
   cFilAtu := MV_PAR01
   cFilNew := MV_PAR02
   AxFilAlt()
EndIf

cIndSx2 += "1"
DbSelectArea("SX2")  // Fecha Arquivo Em Modo Exclusivo
dbCloseArea()
                        // Abre Arquivo em Modo Compartilhado
dbUseArea( .T.,,("SX2"+SM0->M0_CODIGO+"0"), "SX2", If(.F. .OR. .T., !.F., NIL), .F. )

If RetIndExt()!=".CDX"
   dbSetIndex( cIndSx2 )
Else
   DbSetOrder(1)
EndIf
Set Filter To

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AxFilAlt � Autor � Reiner Trennepohl     � Data � 05/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa p/alteracao das Filiais das Tabelas conforme SX2  ���
���          � Montado. Apenas para Arquivos exclusivos.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AxFilAlt()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static FuncTion AxFilAlt()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local cArquivo,nPosFilial:=0,nOpcA,nIndices:=0,cModoAnt
Local xAlias,cIndex,SixChave,cPathAnt,cPath 

Private cPrefixo

DbSelectArea("SX2")
/*
If MV_PAR03 == 2  // Somente a Tabela Posicionada

   If SX2->X2_CHAVE $ "SX/SR5/SYN/SYO"
      Help(" ",1,"NOALTSR5")
      Return
   EndIf
   
   cPathAnt:=AllTrim(SX2->X2_PATH)
   cArquivo:=SX2->X2_CHAVE
    
   dbSelectArea("SX3")
   dbSetOrder(2)
   If dbSeek(SubStr(cArquivo,2,2)+"_FILIAL")
      cPrefixo := AllTrim(X3_CAMPO)
   Else
     If dbSeek(cArquivo+"_FILIAL") 
        cPrefixo := AllTrim(X3_CAMPO)
     Else
        Return
     EndIf  
   EndIf   
   
   MsgRun(OemToAnsi("Aguarde, atualizando Campo "+cPrefixo),,{|| AltFil(cPathAnt)})
   
Else */  // Todas as Tabelas da Empresa`Posicionada 
   dbGoTop()
   Do While !EOF()  
       
      If SX2->X2_CHAVE $ "SX/SR5/SYN/SYO"
         dbSkip()
         Loop
      EndIf        
      
      cPathAnt:=AllTrim(SX2->X2_PATH)
      cArquivo:=SX2->X2_CHAVE
      nRecSX2 := RecNo()
             
      dbSelectArea("SX3")
      dbSetOrder(2) 
      If dbSeek(cArquivo+"_FILIAL")
         cPrefixo := AllTrim(X3_CAMPO)
      Else
        If dbSeek(SubStr(cArquivo,2,2)+"_FILIAL")
           cPrefixo := AllTrim(X3_CAMPO)
        Else     
           
           DbSelectArea("SX2")
           dbGoTo(nRecSX2)
           dbSkip()
           Loop
        EndIf  
      EndIf    
      
      DbSelectArea("SX2")
      dbGoTo(nRecSX2)
            
      MsgRun(OemToAnsi("Aguarde, atualizando Campo "+cPrefixo),,{|| AltFil(cPathAnt)})
      
      DbSelectArea("SX2")
      dbGoTo(nRecSX2)
      dbSkip()
   EndDo
//EndIf
MsUnlockAll()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �UpdtFilial� Autor � Reiner Trennepohl     � Data � 05/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Preenche o campo filial.                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �UpdtFilial                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function UpdtFilial(cAlias,cConteudo) 

Local cCampo 

Reclock(cAlias) 
cCampo:=cPrefixo
//cCampo:=SubStr(cAlias,2,2)+"_FILIAL"
Replace &cCampo. With cConteudo

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � AltFil     �Autor � Reiner Trennepohl     � Data � 05/12/13 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza��o da Filial do Tabela Selecionada                 ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � CalCFGFi                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function AltFil(cPathAnt)  

Local cArquivo
Local theDriver := __cRDD
#ifdef TOP
   Local cDataBase,cCommand
#endif

cArquivo:= RetArq(__cRdd,cPathAnt+Trim(SX2->X2_ARQUIVO),.T.)
xAlias  := SX2->X2_CHAVE
If MSFile(cArquivo)
   #ifdef TOP
      If (xAlias $ "SH7SH8SH9")
         theDriver := __LocalDriver
      EndIf
   #endif
   While !MsOpEndbf(.T.,theDriver,cArquivo,xAlias,.F.,.F.,.T. )
   End
EndIf
//���������������������������������������������������������Ŀ
//� Atualiza��o do arquivo, sera gravado a nova filial      �
//�����������������������������������������������������������
If MSFile(cArquivo)
   nSavOrd := IndexOrd()
   DbSetOrder(0)
   DbGoTop()
      #ifdef TOP
         cCommand  := "UPDATE "+cArquivo
         cCommand  += " SET "+cPrefixo+" = '"+cFilNew+"'"
         cCommand  += " WHERE "+cPrefixo+" = '"+cFilAtu+"'"
         TCSqlExec(cCommand)
      #else
         dbEval( { || UpdtFilial(SX2->X2_CHAVE,cFilNew) } )
      #endif
   DbSetOrder(nSavOrd)
   dbCloseArea()
   //����������������������������������������������������Ŀ
   //� Caso tenha sido alterado o modo de acesso do arqui-�
   //� vo, seus indices dever�o ser deletados.            �
   //������������������������������������������������������
   cArqDel:=AllTrim(cPathAnt)+SX2->X2_CHAVE+cEmpAnt+"0*"+RetIndExt()
   aArqDel:=DIRECTORY(cArqDel)
   For i:=1 To Len(aArqDel)
      Ferase(AllTrim(cPathAnt)+aArqDel[i][1])
   Next i
EndIf
//�����������������������������������������������������Ŀ
//� Envia chamada para cria��o de diretorio. Caso o mes-�
//� mo ja' exista, nada sera' feito.                    �
//�������������������������������������������������������
//cPath:=AllTrim(SubStr(SX2->X2_PATH,1,Len(AllTrim(SX2->X2_PATH))-1))
//MakeDir(cPath)
//�����������������������������������������������������Ŀ
//� Se houve alteracao no arquivo de Tabelas, o mesmo   �
//� devera' ser aberto novamente                        �
//�������������������������������������������������������
//If xAlias = "SX5"
//      cArquivo := RetArq(__cRdd,AllTrim(SX2->X2_PATH)+AllTrim(SX2->X2_ARQUIVO),.T.)
//      If !MSFILE(cArquivo)
//         Final(cArquivo+STR0006)  // " n�o encontrado"
//      EndIf
//      While !ChkFile("SX5",.t. )
//         Help("",1,"ARQEXCL")
//      End
//End

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CalFilPar � Autor � Reiner Trennepohl     � Data � 05/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Aciona parametros do Programa                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � 		                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function CalFilPar() 

Pergunte(cPerg)

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AjustaSX1    �Autor � Reiner Trennepohl  � Data � 05/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ajusta perguntas do SX1                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

STATIC FUNCTION AjustaSx1()
Local aArea := { Alias(), IndexOrd() } 
Local cPerg := "CALCFGFIL "                 
Local nI    := 0
Local aPerg := {}

Aadd(aPerg, {"01","Da Filial ","Da Filial ","Da Filial ",;
 			 "mv_ch1","C",02,"G","mv_par01","","","","","","","", "","NaoVazio()","XM0",".RHFILDE." })
Aadd(aPerg, {"02","Para a Filial","� Filial","� Filial",;
 			 "mv_ch2","C",02,"G","mv_par02","","","","","","","", "","NaoVazio()","XM0",".RHFILAT." })  
//Aadd(aPerg, {"03","Quanto a Altera��o ?","Quanto a Altera��o ?","Quanto a Altera��o ?",;
//             "mv_ch3","N",01,"C","mv_par03","Todas Tabelas","Todas Tablas","All Tables","1","Selecionada","Seleccionado","selected","1","","","" })

nPerg := Len(aPerg)

dbSelectArea("SX1")
dbSetOrder(1)
For nI := 1 To nPerg
	If !dbSeek(cPerg+aPerg[nI,1])
		RecLock("SX1",.T.)
		Replace X1_GRUPO	With cPerg
		Replace X1_ORDEM	With aPerg[nI,01]
		Replace X1_PERGUNT	With aPerg[nI,02]
		Replace X1_PERSPA	With aPerg[nI,03]
		Replace X1_PERENG	With aPerg[nI,04]
		Replace X1_VARIAVL	With aPerg[nI,05]
		Replace X1_TIPO		With aPerg[nI,06]
		Replace X1_TAMANHO	With aPerg[nI,07]
		Replace X1_GSC		With aPerg[nI,08]
		Replace X1_VAR01	With aPerg[nI,09]
		Replace X1_DEF01	With aPerg[nI,10]
		Replace X1_DEFSPA1	With aPerg[nI,11]
		Replace X1_DEFENG1	With aPerg[nI,12]
		Replace X1_CNT01	With aPerg[nI,13]
		Replace X1_DEF02	With aPerg[nI,14]
		Replace X1_DEFSPA2	With aPerg[nI,15]
		Replace X1_DEFENG2	With aPerg[nI,16]
		Replace X1_CNT02	With aPerg[nI,17]
		Replace X1_VALID	With aPerg[nI,18]
		Replace X1_F3   	With aPerg[nI,19]
		Replace X1_HELP 	With aPerg[nI,20]
		MsUnlock()
	EndIf
Next

dbSelectArea( aArea[1] )
dbSetOrder( aArea[2] )   

Return
