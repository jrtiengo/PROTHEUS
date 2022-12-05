#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Orc200()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CVENPAD,CCLIPAD,NICMPAD,CRESPADM,CMSGFIM,APRECO")
SetPrvt("ACONF,INCLUI,ALTERA,CCADASTRO,AROTINA,")

/*...
     ORC200 -   Orcamentacao Principal

     Planejamento - Roberto Mazzarolo

     Execucao - Roberto Mazzarolo

     ...*/



cVenPad  := Left(GetMv("MV_VENDPAD"),6) //.. vendedor Padrao
cCliPad  := Left(GetMv("MV_ORCLIPD"),6) //.. Cliente  Padrao
nIcmPad  := GetMv("MV_ICMPAD")          //.. Icms   Padrao
cRespAdm := Trim( GetMv("MV_RESPADM") ) //.. responsavel administrativo
cRespAdm := cRespAdm + Space(30 - Len( crespAdm ) )
cMsgFim  := Trim( GetMv("MV_LJFISMS") )  //.. Mesagem final
cMsgFim  := cMsgFim + Space(78 - Len( cMsgFim ) )

aPreco   := {"Custo" ,"venda"}
aConf    := {"Confirmado","Nao Confirmado"}

Inclui   :=  .T.
Altera   := .f.
cCadastro := "O r c a m e n t o s "
aRotina   := {{"Pesquisar","AXPESQUI",0,1},;
              {"Incluir      ",'ExecBlock("ORC201",.f.)',0,2} ,;
              {"Alterar      ",'Execblock("ORC202",.f.)',0,3}  ,;
              {"Excluir      ",'Execblock("ORC203",.f.)',0,4}  ,;
              {"Imprimir     ",'Execblock("ORC204",.f.)',0,5}  ,;
              {"Aprovar      ",'Execblock("ORC205",.f.)',0,6}}


Dbselectarea("SB1")
DbSetOrder(1)

Dbselectarea("SB2")
DbSetOrder(1)

Dbselectarea("SZY")
DbSetOrder(1)

Dbselectarea("SZZ")
DbSetOrder(1)

mBrowse(06,01,22,75,"SZZ")

Return


