#INCLUDE "protheus.ch"

User Function BANCO005()

    Local aArea         := GETAREA()
    Local aDados        := {}
    Private lMSErroAuto := .F.

        // Adicionado dados no vetor para teste de inclus�o na tabela SB1
    aDados := {;
                 {"B1_COD",     "TESTE",            Nil},;   
                 {"B1_DESC",    "PRODUCAO TESTE",   Nil},;
                 {"B1_TIPO",    "GG",               Nil},;
                 {"B1_UM",      "PC",               Nil},;
                 {"B1_LOCPAD",  "01",               Nil},;
                 {"B1_PICM",     0,                 Nil},;
                 {"B1_IPI",      0,                 Nil},;
                 {"B1_CONTRAT", "N",                Nil},;
                 {"B1_LOCALIZ", "N",                Nil};
                }

        // Inicio do controle de transa��o 
        Begin Transaction 
            // chama cadastro de produto
             MSExecAuto({|x,y|MATA010(x,y)},aDados,3)
        
            //Caso ocorra algum erro
             IF lMSErroAuto
              alert("Ocorreram erros durante a opera��o!")
              MostraErro()
            // cancela a opera��o
             DisarmTransaction()
             ELSE
                MsgInfo("Opera��o Finalizada", "Aviso")
            ENDIF
        End Transaction 
        
    RestArea(aArea)

Return
