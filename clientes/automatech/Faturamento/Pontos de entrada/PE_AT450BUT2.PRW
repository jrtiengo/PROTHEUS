/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �AT450BUT2 �Autor  �Microsiga           � Data �  05/12/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT450BUT2()   

Local aBotao  := {}         
//Local aBotao2 := {} 

U_AUTOM628("PE_AT450BUT2")

//Public nItensApont := Len(aColsAb8[1])

AAdd( aBotao, { "S4WB001N", { || U_COPIAOS(AB6->AB6_NUMOS) }                       , "Copiar OS" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOMR46(M->AB6_FILIAL, M->AB6_NUMOS) }         , "Observa��es" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOM545() }                                    , "V�nculo Contrato" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOMR01() }                                    , "Impress�o OS" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOMR30() }                                    , "Rastreabilidade N� S�rie" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOM103("S", AB6->AB6_FILIAL, AB6->AB6_NUMOS) }, "Tracker Etiqueta" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOM126() }                                    , "Consulta Pre�o" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOM571(M->AB6_FILIAL, M->AB6_NUMOS, M->AB6_CODCLI, M->AB6_LOJA ) } , "Posi��o de Pe�as" } ) 

Aadd(aBotao, {'S4WB007N', {|| MsgRun('Inclus�o Documento de Entrada...', 'Aguarde... ',{|| A103NFiscal("SF1",,3) }) }, 'Doc.Entrada', 'Incluir Doc.Entrada' })

If !Inclui
	Aadd(aBotao, {'AUTOMR11', {|| MsgRun('Impress�o da Etiqueta...', 'Aguarde... ',{|| u_AUTOMR11()  }) }, 'Impress�o Etiqueta', 'Impress�o Etiqueta' })
	Aadd(aBotao, {'AUTOM276', {|| MsgRun('Impress�o Etiqueta PV'   , 'Aguarde... ',{|| U_AUTOM276(M->AB6_NUMOS)  }) }, 'Impress�o Etiqueta PV', 'Impress�o Etiqueta PV' })
EndIf    


/*
If Altera
	Aadd(aBotao, {'S4WB007N', {|| At460Inclu("AB9",0,3) }, 'Inclus�o Atend. OS', 'Inclus�o Atend. OS'   })
	Aadd(aBotao, {'S4WB007N', {|| TECA460()  }, 'Altera��o Atend. OS', 'Altera��o Atend. OS' })
	Aadd(aBotao, {'S4WB007N', {|| TECA460()  }, 'Exclus�o Atend. OS', 'Exclus�o Atend. OS'   })
EndIf

Bot�es para enviar e-mail para cliente
Botao para impressao do chamado t�cnico
Botao para impressao da OS
Btn Impress�o Etiqueta
Btn Entrega de Equipamento
*/

Return(aBotao)