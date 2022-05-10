#INCLUDE "TOTVS.CH"

#DEFINE VISUALIZA	2
#DEFINE INCLUI		3
#DEFINE ALTERA		4
#DEFINE EXCLUI		5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT110TEL  ºAutor  ³Ednei Silva º Data ³  /12/16     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºTDN       ³ http://tdn.totvs.com/pages/releaseview.action?pageId=6085447 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±ÍÍ±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    


/*

//³1)                                                              ³
//³usuario pode estar em mais de um CC                             ³
//³usaurio = solicitante                                           ³
//³                                                                ³
//³porque ai eu já trago o CC dele e coloco na SC sem poder alterar³
//³                                                                ³
//³2)                                                              ³
//³se o usuario nao tiver nenhhum CC la na CTT                     ³
//³esta trazendo todos as SC com o C1_CC em branco                 ³
//³                                                                ³
//³3)                                                              ³
//³Ta podendo salvar sem  Centro de Custo                          ³
//³4)                                                              ³
//³Coloco um CC no cabeçalhom antes de confiramr, altero o CC      ³
//³nao altera os itens.
//³Bloquear logo depois que digitou o CC no cabeçalho, forçando cancelar e incluir novamente. Ruim
  
	6)
	quando alterar, posso alterar o CC.
	como vai ficar os itens ?
	
	bloquear o CC no cabeçalho quando for alterção ?

*/

User Function MT110TEL      
Local oNewDialog := PARAMIXB[1]
Local aPosGet    := PARAMIXB[2]
Local nOpcx      := PARAMIXB[3]
Local nReg       := PARAMIXB[4]
                               
Local lVisualiza := VisualSX3( "C1_GRUAPR" )
Public cDesc_APR   := space( 20 )   //Descricao Grupo de Aprovacao

Public cSCI_APR   := space( 06 )    //Codigo grupo de aprovacao

	aadd(aPosGet[1],0) 
	aadd(aPosGet[1],0)
	
	aPosGet[1,7] := 455
	aPosGet[1,8] := 480          
	
	do case
	   case nOpcx == VISUALIZA  .or.  nOpcx == ALTERA  .or.  nOpcx == EXCLUI
		    cSCI_APR    := Posicione( "SAI", 2, xFilial( "SAI" ) + SC1->C1_USER, "SAI->AI_GRUAPR" )
		    cDesc_APR   := Posicione( "SAI", 2, xFilial( "SAI" ) + SC1->C1_USER, "SAI->AI_DESCAPR" )
	   case nOpcx == INCLUI
		    //cSCI_APR    := space( 06 )
		    //cDesc_APR   := space( 20 )
		    
		    cSCI_APR    := Posicione( "SAI", 2, xFilial( "SAI" ) + RetCodUsr(), "SAI->AI_GRUAPR" )
		    cDesc_APR   := Posicione( "SAI", 2, xFilial( "SAI" ) + RetCodUsr(), "SAI->AI_DESCAPR" )
	   otherwise
	    
	endcase
	                                                       
	@ 70, aPosGet[1,1]            SAY   OemToAnsi("Grupo de Aprov") PIXEL SIZE 60,12 Of oNewDialog 
	@ 69, aPosGet[1,2]            MSGET cSCI_APR                   PICTURE PesqPict("SC1","C1_GRUAPR") F3 CpoRetF3('C1_GRUAPR') ; 
	                              WHEN  iif( nOpcx == INCLUI, !lVisualiza, !lVisualiza ) OF oNewDialog PIXEL SIZE 10,12
	@ 68, ( aPosGet[1,3] - 100 )  MSGET cDesc_APR ;
	                              WHEN iif( nOpcx == INCLUI, !lVisualiza, !lVisualiza ) OF oNewDialog PIXEL SIZE 150,12
                                  
//Valid CheckSX3("AL_COD", cGRUAPR) .and. ( cDesc_APR := Posicione( "SAI", 2, xFilial( "SAI" ) + cSCI_APR, "SAI->AI_DESCAPR" ) ) ;
	                              

Return 

User Function MT110GET()

Local aRet:= PARAMIXB[1]

aRet[2,1] := 100 // Abaixando o começo da linha da getdados
aRet[1,3] := 095 // Abaixando a linha de contorno dos campos do cabeçalho

Return(aRet)




