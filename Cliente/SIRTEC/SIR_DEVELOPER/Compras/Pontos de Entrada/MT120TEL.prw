//##################################################################################################################################//
// AUTOR     | Vanessa Limana                                                                                                       //
// DATA      | 17/10/2019                                                                                                          //
// FUNCAO    |                                                                                                                      //
// DESCRICAO |  Criação de novo campo em Pedido de compra                                                                           //
// Chamado   | 44172                                                                                                               //
// ALTERACOES:                                                                                                                     //
// Data      |22/10/2019                                                                                                            //
// #################################################################################################################################//

#Include "Protheus.ch"
  
User Function MT120TEL()
   //LOCALIZAÇÃO : Function A120PEDIDO - Função do Pedido de Compras responsavel pela inclusão, alteração, exclusão e cópia dos PCs.
   //EM QUE PONTO : Se encontra dentro da rotina que monta a dialog do pedido de compras antes  da montagem dos folders e da chamada da getdados.

    Local aArea     := GetArea()
    Local oDlg      := PARAMIXB[1] //Objeto da Dialog do Pedido de Compras
    Local aPosGet   := PARAMIXB[2] //Array contendo a posição dos gets do pedido de compras
    Local nOpcx     := PARAMIXB[4] //Opção Selecionada no Pedido de Compras (inclusão, alteração, exclusão, etc ..)
    Local nRecPC    := PARAMIXB[5] //Número do recno do registro do pedido de compras selecionado
    Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  9, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia  // .Or. nOpcx == 4K      
    Local aTipo 
    Public cXtipo := Space(1)
    
    /*
    #25039 Ajustados os pontos de entrada na gravação do pedido de compras,
    para atender a gravação do campo C7_FRMPAG.
    Mauro - Solutio. 28/11/2019.
    */
       
    DBSELECTAREA("SC7")
    IF SC7->(FIELDPOS("C7_FRMPAG"))==0  // PROTEÇÃO CASO CAMPO NAO EXISTA
       RETURN
    ENDIF   
     
    SC7->(DbGoTo(nRecPC))
    If nOpcx == 3
        cXtipo := CriaVar("SC7->C7_FRMPAG",.F.)
    Else
        cXtipo := SC7->C7_FRMPAG
    EndIf
    
    aTipo := {}           
    Aadd(aTipo,"")
    Aadd(aTipo,"1=Boleto")
    Aadd(aTipo,"2=Deposito")   
         
    @ 062, aPosGet[1,08] - 012 SAY "Tipo de pagamento:" OF oDlg PIXEL SIZE 050,006
    @ 061, aPosGet[1,09] - 006 COMBOBOX cXtipo ITEMS aTipo SIZE 100, 006 OF oDlg VALID EVAL({|| !EMPTY(cXTipo)}) COLORS 0, 16777215 PIXEL
             
    RestArea(aArea)
Return
 
                                                    
User Function MTA120G2() 
   //LOCALIZAÇÃO : Function A120GRAVA - Função responsável pela gravação do Pedido de Compras e Autorização de Entrega.
   //EM QUE PONTO : Na função A120GRAVA executado após a gravação de cada item do pedido de compras recebe como parametro o Array manipulado pelo ponto de entrada MTA120G1 
   //e pode ser usado para gravar as informações deste array no item do pedido posicionado.
    Local aArea := GetArea()                           
    DBSELECTAREA("SC7")
    IF SC7->(FIELDPOS("C7_FRMPAG"))==0  // PROTEÇÃO CASO CAMPO NAO EXISTA
       RestArea(aArea)  
       RETURN
    ENDIF   
    
    RecLock("SC7", .F.) 
    SC7->C7_FRMPAG := cXtipo   
    MsUnlock()
    RestArea(aArea)  
Return    
  
User function MT120PCOK
   local lRet:=.t.
   IF SC7->(FIELDPOS("C7_FRMPAG"))==0  // PROTEÇÃO CASO CAMPO NAO EXISTA
       RETURN .T.
   ENDIF   
   if empty(cXTipo)
      alert("Especifique a Forma de Pagamento !")
      lRet:=.f.
   endif   
Return lRet