#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
�����������������������������������������������������������������������ͻ
�����Programa  �MyTECA040  �Autor  �Vendas Clientes     � Data �  20/01/11  �
���������������������������������������������������������������������������͹
�����Desc.     � Cria a base instalada atraves de rotina automatica         �
���������������������������������������������������������������������������͹
�����Uso       � Field Service                                              �
����������������������������������������������������������������������������
��������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function MyTECA040()

   Local aCab040   := {}    // Cabecalho do AA3
   Local aItens040 := {}    // Itens AA4
   Local lRet      := .T.   
   Local nI
   Local aNrsSerie := {} // Array com o numero de serie para gravacao da base instalada
   Local nRegs     := 0
   Local dData     := "20/01/2011"
   
   PRIVATE lMsErroAuto := .F.
   
   //��������������������������������������������������������������Ŀ
   //| Abertura do ambiente                                         |
   //����������������������������������������������������������������
   ConOut(Repl("-",80))
   ConOut(PadC("Teste de Inclusao de pedido de venda",80))
   
   PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "TEC" TABLES "AA3","AA4","SXB"
   
   Aadd(aNrsSerie,"10203040506070809010")
   
   nRegs     := Len(aNrsSerie)  
   
   For nI := 1 to nRegs                                        
       Aadd(aCab040, { "AA3_FILIAL"  , ""                         , NIL } )                
       Aadd(aCab040, { "AA3_CODCLI"              , "000001"                           , NIL } )                
       Aadd(aCab040, { "AA3_LOJA"                   , "01"                    , NIL } )                
       Aadd(aCab040, { "AA3_CODPRO"            , "PRODUTO01"   , NIL } )                
       Aadd(aCab040, { "AA3_NUMSER"            , aNrsSerie[nI]  , NIL } )                 
       Aadd(aCab040, { "AA3_DTVEN"                   , dData             , NIL } )              
       
       TECA040(,aCab040,aItens040,3)                
       
       //�������������������������������������������������������Ŀ                
       //�VerIfica se houveram erros durante a geracao da base   �                
       //���������������������������������������������������������                
       
       If lMsErroAuto                               
          lRet := !lMsErroAuto               
       Endif                                                                               
       
       aCab040 := {}
       
    NextReturn 
    
lRet




/*��������������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ
�����Fun��o    �MyTeca200 � Autor �  � Data �11/05/2011 �
����������������������������������������������������������������������������Ĵ
�����          �Rotina de teste da rotina automatica do programa TECA200     
�����������������������������������������������������������������������������Ĵ
�����Parametros�Nenhum                                                       
�����������������������������������������������������������������������������Ĵ
�����Retorno   �Nenhum                                                       
�����������������������������������������������������������������������������Ĵ
�����Descri��o �Esta rotina tem como objetivo efetuar testes na rotina de    
������          �contratos.                                                   
�����������������������������������������������������������������������������Ĵ
�����Uso       � Materiais                                                   
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

User Function MyTeca200()

   Local aCabec    := {}
   Local aItens    := {}
   Local aItem     := {}
   Local cContrato := ""
   Local lOk       := .T.                
   Local nX        := 0
   
   PRIVATE lMsErroAuto := .F.
   
