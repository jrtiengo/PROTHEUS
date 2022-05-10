#include "rwmake.ch"
#include "totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F240FIL    ºAutor  ³ RHAIANA-TOTVS     º Data ³  02/03/16   º±±
±±ºManutencao³F240FIL    ºAutor  ³ NELIO             º Data ³  14/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PONTO DE ENTRADA PARA FILTRO NO BORDERO DE PAGAMENTOS       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12 - GRUPO COPELMI                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION F240FIL()
Local aArea    := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local cFiltro  := ""
Local cCGCEMP  := SM0->M0_CGC

IF cModPgto $ "01" // Credito em conta corrente - SEGMENTO A
	cFiltro := "EMPTY(E2_CODBAR) .AND.  "
	cFiltro += "!EMPTY(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO')) .AND."
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') == '" + cPort240 + "' .AND."
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') <> '" + cCGCEMP + "'"

ELSEIF cModPgto $ "03"  .AND. cPort240 == "041" .AND. cTipoPag == "20" //Doc outro titular/fornecedores - SEGMENTO A (Banrisul)
	cFiltro := "EMPTY(E2_CODBAR) .AND.   "
	cFiltro += "!EMPTY(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO')) .AND."
	cFiltro += "E2_SALDO < 4999 .AND.  "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') <> '" + cCGCEMP + "'"
	cFiltro += "  .AND. Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') <> '" + cPort240 + "'"

ELSEIF cModPgto $ "03"  .AND. cPort240 == "041" .AND. cTipoPag == "12" //TED outro titular - SEGMENTO A (Banrisul)
	cFiltro := "EMPTY(E2_CODBAR) .AND.   "
	cFiltro += "!EMPTY(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO')) .AND."
	cFiltro += "E2_SALDO > 0 .AND.  "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') <> '" + cCGCEMP + "'"
	cFiltro += "  .AND. Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') <> '" + cPort240 + "'"

ELSEIF cModPgto $ "03"  .AND. cPort240 <> "041" //Doc  outro titular- SEGMENTO A (outros bancos)
	cFiltro := "EMPTY(E2_CODBAR) .AND.   "
	cFiltro += "!EMPTY(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO')) .AND."
	cFiltro += "E2_SALDO < 4999 .AND.  "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') <> '" + cCGCEMP + "'"
	cFiltro += "  .AND. Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') <> '" + cPort240 + "'"

ELSEIF cModPgto $ "06" // Credito em conta corrente  mesmo titular   - SEGMENTO A
	cFiltro := "EMPTY(E2_CODBAR) .AND. "
	cFiltro += "!EMPTY(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO')) .AND."
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') == '" + cPort240 + "' .AND."
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') == '" + cCGCEMP + "'"

ELSEIF cModPgto $ "07" //Doc  mesmo titular com CNPJ igual a saque - SEGMENTO A
	cFiltro := "EMPTY(E2_CODBAR) .AND. "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') <> '" + cPort240 + "'"
	cFiltro += " .AND. E2_SALDO <= 4999 .AND. "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') == '" + cCGCEMP + "'"

ELSEIF cModPgto $ "11"  // Pagamento a concessionaria
	cFiltro := "!EMPTY(E2_CODBAR) .AND. SUBSTR(E2_CODBAR,1,2)$'81/82/83/84/85'"

ELSEIF cModPgto $ "16" .AND. cPort240=="041" .AND. cTipoPag == "22" // DARF sem codigo de barras (BANRISUL)
	cFiltro := "EMPTY(E2_CODBAR) .AND. (!EMPTY(E2_CODRET) .OR. !EMPTY(E2_CDRET)) "

ELSEIF cModPgto $ "16\18" .AND. cPort240<>"041" .AND. cTipoPag == "98" // DARF normal - INSS
	cFiltro := "EMPTY(E2_CODBAR) .AND. (!EMPTY(E2_CODRET) .OR. !EMPTY(E2_CDRET)) "

ELSEIF cModPgto $ "17" .AND. cPort240<>"001"  // GPS-INS (Demais Bancos)
	cFiltro := "EMPTY(E2_CODBAR) .AND. !EMPTY(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CODINSS'))"

ELSEIF cModPgto $ "17" .AND. cPort240=="001" // GPS-INS (Banco do Brasil)
	cFiltro := "EMPTY(E2_CODBAR) .AND. E2_TIPO$'INS' .AND. "
	cFiltro += "!EMPTY(Posicione('SA2',1,xFilial('SA2')+'"+ Substr(SE2->E2_TITPAI,18,10) + "', 'A2_CODINSS'))"

ELSEIF cModPgto $ "19"  // ISS - IPTU - TRIBUTOS MUNICIPAIS - COM CODIGO DE BARRAS
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'81\82\83' "
	
ELSEIF cModPgto $ "30"  //boletos do banco que esta pagamento
	cFiltro := "!EMPTY(E2_CODBAR) .AND.  SUBSTR(E2_CODBAR,1,3)=cPort240 .AND. len(ALLTRIM(E2_CODBAR)) >= 44"

ELSEIF cModPgto $ "31" .AND. cPort240 <> "237" // Boletos de outros bancos
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,3) <> cPort240 .AND. len(ALLTRIM(E2_CODBAR)) >= 44 .AND. !Substr(E2_CODBAR,1,2)$'81/82/83/84/85'"
    
ELSEIF cModPgto $ "31" .AND. cPort240 == "237" // Boletos de outros bancos via (BRADESCO)
	cFiltro := "!EMPTY(E2_CODBAR) .AND. len(ALLTRIM(E2_CODBAR)) >= 44"     
	
ELSEIF cModPgto $ "32" .AND. cPort240 == "041" // GPS sem codigo de barras (BANRISUL)
   
	 //.AND. (ALLTRIM(Posicione('SA2',1,xFilial('SA2')+Substr(SE2->E2_TITPAI,18,10), 'A2_CODINSS'))<>'')
     //	cFiltro := " ALLTRIM(E2_CODBAR)='' .AND. E2_TIPO $ 'INS' .AND. !EMPTY({|| U_CNABCODINSS(E2_NUM,E2_PARCELA)}) "
   	 cFiltro := " ALLTRIM(E2_CODBAR)='' .AND. E2_FORNECE='006081' "
    
ELSEIF cModPgto $ "33" .AND. cPort240 == "041" .AND. cTipoPag=="91"  // Pagamentos de Arrecadacoes (BANRISUL) = G.A. com barras
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'85' .AND. Substr(E2_TIPO,1,2)$'GA'"
	
ELSEIF cModPgto $ "33" .AND. cPort240 == "041" .AND. cTipoPag=="92"// Pagamentos de Arrecadacoes (BANRISUL) = GNRE
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'85' .AND. E2_TIPO$'GNR'"

ELSEIF cModPgto $ "33" .AND. cPort240 == "041" .AND. cTipoPag=="93"// Pagamentos de Arrecadacoes (BANRISUL) = DARF
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'85' .AND. Substr(E2_TIPO,1,2)<>'TX'"
	
ELSEIF cModPgto $ "33" .AND. cPort240 == "041" .AND. cTipoPag=="94"// Pagamentos de Arrecadacoes (BANRISUL) = Pref., Água, Luz, GAD-e,GAD-m, DPVAT
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'81/83/82/86'"

ELSEIF cModPgto $ "33" .AND. cPort240 == "041" .AND. cTipoPag=="95"// Pagamentos de Arrecadacoes (BANRISUL) = TELECOMUNICAÇÕES
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'84' "

ELSEIF cModPgto $ "33" .AND. cPort240 == "041" .AND. cTipoPag=="96"// Pagamentos de Arrecadacoes (BANRISUL) = GPS P.J.
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'85' .AND. E2_TIPO$'INS'"
	
ELSEIF cModPgto $ "35"  // FGTS
	cFiltro := "!EMPTY(E2_CODBAR) .AND. Substr(E2_CODBAR,1,2)$'85' "

ELSEIF cModPgto $ "41\08"  // TED outro titular - SEGMENTO A
	cFiltro := "EMPTY(E2_CODBAR) .AND. "
	cFiltro += "!empty(Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO')) .and. "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') <> '" + cPort240 + "'"
	cFiltro += ".AND. E2_SALDO > 5000 .AND."
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') <>'" + cCGCEMP + "'"

ELSEIF cModPgto $ "43"  // TED mesmo titular - SEGMENTO A
	cFiltro := "EMPTY(SE2->E2_CODBAR) .AND. "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_BANCO') <> '" + cPort240 + "' .AND."
	cFiltro += " E2_SALDO > 4999 .AND. "
	cFiltro += "Posicione('SA2',1,xFilial('SA2')+E2_FORNECE+E2_LOJA, 'A2_CGC') =='" + cCGCEMP + "'"

ELSEIF cModPgto $ "91"  // TRIBUTOS COM CODIGO DE BARRAS E GNRE
	cFiltro := "!EMPTY(E2_CODBAR) .AND. len(ALLTRIM(E2_CODBAR))=48 .AND. !Substr(E2_CODBAR,1,2)$'85' "

ELSE
	cFiltro :=""

ENDIF

RestArea(aAreaSA2)
RestArea(aArea)

RETURN(cFiltro)