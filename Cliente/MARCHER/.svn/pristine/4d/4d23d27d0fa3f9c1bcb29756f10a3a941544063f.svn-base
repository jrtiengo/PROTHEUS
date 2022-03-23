//|=====================================================================|
//|Programa: F240FIL.PRW   |Autor: Marciane Gennari   | Data: 24/11/2010|
//|=====================================================================|
//|Descricao: Ponto de entrada para filtrar os titulos do contas a pagar|
//|           conforme MODELO de pagamento do bordero.                  |
//|=====================================================================|
//|Sintaxe:                                                             |
//|=====================================================================|
//|Uso: Ponto de entrada da rotina FINA090                              |
//|=====================================================================|
//|       ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             |
//|---------------------------------------------------------------------|
//|Programador |Data:      |BOPS  |Motivo da Alteracao                  |
//|RAQUEL CEZAR     19/01/2018      Para tratar o banco do brasil tambem|

//|---------------------------------------------------------------------|
//| ====================================================================|
#include "rwmake.ch"                                                                       

User Function F240fil()                                                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_cFiltro,")

_cFiltro:=""
If cModPgto == "30"
   
   If cPort240 == "341" .or. cPort240 == "001"                                        
      _cFiltro := " SUBS(E2_CODBAR,1,3)=="+"'"+cPort240+"'"
   Else   
      _cFiltro := " !EMPTY(E2_CODBAR) "
   EndIf                                                                                                 
   
   _cFiltro += " .AND. SUBS(E2_CODBAR,1,1)<>'8' "
   
ElseIf cModPgto == "31"
   
   _cFiltro := " !EMPTY(E2_CODBAR)"
   
    If cPort240 == "341" .or. cPort240 == "001"                                        
      _cFiltro += " .AND. SUBS(E2_CODBAR,1,3)<>"+"'"+cPort240+"'"
   EndIf

   _cFiltro += " .AND. SUBS(E2_CODBAR,1,1)<>'8' "

ElseIf cModPgto == "01"
   _cFiltro := " Empty(E2_CODBAR)  .and. " 
   _cFiltro += "  GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  =="+" '"+cPort240+ "'" 

/*ElseIf cModPgto == "03" 
   _cFiltro := " Empty(E2_CODBAR) .and. "// .and. "
   If cPort240 == "341"                                         
      _cFiltro += " E2_SALDO < 3000 .and. "   
   EndIf
   _cFiltro += " (  !Empty(GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1))  "
   _cFiltro += "  .and. GetAdvFval('SA2','A2_BANCO'  ,xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  <>"+"'"+cPort240+"'  )"

ElseIf cModPgto == "41" .or. cModPgto == "43"
   _cFiltro := " Empty(E2_CODBAR) .and. " 
   If cPort240 == "341"                                         
      _cFiltro += " E2_SALDO >= 3000 .and. "   
   EndIf
   _cFiltro += " (  !Empty(GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1))  "
   _cFiltro += "  .and. GetAdvFval('SA2','A2_BANCO'  ,xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  <>"+"'"+cPort240+"'  )"
*/ 

ElseIf cModPgto == "41" 
   _cFiltro := " Empty(E2_CODBAR) .and. "// .and. "
   //If cPort240 == "341"                                         
   //   _cFiltro += " E2_SALDO < 3000 .and. "   
   //EndIf
   _cFiltro += " (  !Empty(GetAdvFval('SA2','A2_BANCO',xFilial('SA2')+E2_FORNECE+E2_LOJA,1))  "
   _cFiltro += "  .and. GetAdvFval('SA2','A2_BANCO'  ,xFilial('SA2')+E2_FORNECE+E2_LOJA,1)  <>"+"'"+cPort240+"'  )"
   
ElseIf cModPgto == "13"  //--- Concessionarias

   _cFiltro := " !EMPTY(E2_CODBAR) .AND. SUBS(E2_CODBAR,1,1)=='8'"

ElseIf cModPgto == "16"  //--- Darf Normal - Selecionar com codigo de retencao e tipo TX              

   _cFiltro := " ( !Empty(E2_CODRET) .OR. !Empty(E2_CODREC) ) .AND. E2_TIPO == 'TX '"

ElseIf cModPgto == "17"  //--- GPS 

   _cFiltro := " E2_TIPO == 'INS'"

ElseIf cModPgto == "19"  //--- ISS  

   _cFiltro := " E2_TIPO == 'ISS'"

EndIf


Return(_cFiltro)        
