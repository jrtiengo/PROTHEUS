/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³AT450BUT2 ºAutor  ³Microsiga           º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AT450BUT2()
Local aBotao  := {} 
Local aBotao2 := {} 


AAdd( aBotao, { "S4WB001N", { || U_COPIAOS(AB6->AB6_NUMOS) }                       , "Copiar OS" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOMR46(M->AB6_FILIAL, M->AB6_NUMOS) }         , "Observações" } ) 
//AAdd( aBotao, { "S4WB001N", { || U_AUTOMR01() }                                    , "Impressão Chamado/OS" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOMR01() }                                , "Impressão OS" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOMR30() }                                    , "Rastreabilidade Nº Série" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOM103("S", AB6->AB6_FILIAL, AB6->AB6_NUMOS) }, "Tracker Etiqueta" } ) 
AAdd( aBotao, { "S4WB001N", { || U_AUTOM126() }                                    , "Consulta Preço" } ) 

Aadd(aBotao, {'S4WB007N', {|| MsgRun('Inclusão Documento de Entrada...', 'Aguarde... ',{|| A103NFiscal("SF1",,3) }) }, 'Doc.Entrada', 'Incluir Doc.Entrada' })

Aadd(aBotao, {'AUTOMR11', {|| MsgRun('Impressão da Etiqueta...', 'Aguarde... ',{|| u_AUTOMR11()  }) }, 'Impressão Etiqueta', 'Impressão Etiqueta' })    


/*
If Altera
	Aadd(aBotao, {'S4WB007N', {|| At460Inclu("AB9",0,3) }, 'Inclusão Atend. OS', 'Inclusão Atend. OS'   })
	Aadd(aBotao, {'S4WB007N', {|| TECA460()  }, 'Alteração Atend. OS', 'Alteração Atend. OS' })
	Aadd(aBotao, {'S4WB007N', {|| TECA460()  }, 'Exclusão Atend. OS', 'Exclusão Atend. OS'   })
EndIf

Botões para enviar e-mail para cliente
Botao para impressao do chamado técnico
Botao para impressao da OS
Btn Impressão Etiqueta
Btn Entrega de Equipamento
*/


Return(aBotao)