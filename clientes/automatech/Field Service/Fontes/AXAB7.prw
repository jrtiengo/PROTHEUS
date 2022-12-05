#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *

User Function AXAB7()  
/*
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "AB7"

dbSelectArea("AB7")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de . . .",cVldExc,cVldAlt)

Return
*/


Private lMsHelpAuto 		:= .T.		// Controle interno do ExecAuto
Private lMsErroAuto 		:= .F.		// Informa a ocorrência de erros no ExecAuto
Private lAutoErrNoFile		:= .T.		// Loga Erros do Execauto na array

DBSELECTAREA('AB6')
DBGOTO(38574)
	

	cHoraI	  	:=  AB6->AB6_HORA	//	ANTES DE ABRIR A TELA PARA INCLUSAO \ ALTERACAO
	cHoraF 	  	:=	Time()										//	NO FINAL DA GRAVACAO DA ORDEM DE SERVICO
	nTotHrAB6 	:= 	SubHoras(cHoraF,cHoraI)
	


	

	If !Empty(Posicione("ABB",3,xFilial("ABB")+AB6->AB6_NUMOS,"ABB_NUMOS"))
	
		// Verifica se já foi enviado e-mail informativo ao cliente da abertura do atendimento.
		// Se não, dispara o programa AUTOM102 que envia e-mail ao cliente.
		lEncerra := MsgYesNo("DESEJA FECHAR ESSA ORDEM DE SERVIÇO "+ENTER+"E"+ENTER+"ENVIAR E-MAIL AO CLIENTE INFORMANDO DA ORDEM DE SERVIÇO ?"+ENTER)
	                          
	
		cCodPrb := ''
		
		DbSelectArea('AB6')
		DbSelectArea('AB7');DbSetOrder(1);DbGoTop() // AB7_FILIAL+AB7_NUMOS+AB7_ITEM
		If DbSeek(xFilial('AB7') + AB6->AB6_NUMOS, .F.)
			cCodPrb := AB7->AB7_CODPRB
		EndIf

		aCabec 	:= {}
		aItens	:= {}
/*	
//		Aadd(aCabec,{'AB9_FILIAL',	xFilial('AB9')    		 , Nil })
		Aadd(aCabec,{'AB9_NUMOS' ,	AB6->AB6_NUMOS			 , Nil })
//		Aadd(aCabec,{'AB9_ETIQUE',  AB6->AB6_NUMOS			 , Nil })
		Aadd(aCabec,{'AB9_CODTEC', 	ABB->ABB_CODTEC   	  	 , Nil })
		Aadd(aCabec,{'AB9_SEQ'   ,  CheckSeqAB9()			 , Nil })
		Aadd(aCabec,{'AB9_CODPRB',  cCodPrb					 , Nil })
		Aadd(aCabec,{'AB9_DTCHEG',  Date()					 , Nil })	//	DATA - INI
		Aadd(aCabec,{'AB9_HRCHEG',  StrTran(cHoraI, '.', ':'), Nil })	//	HORA - INI
		Aadd(aCabec,{'AB9_DTINI' ,  Date()					 , Nil })	// 	DATA - INI
		Aadd(aCabec,{'AB9_HRINI' ,  StrTran(cHoraI, '.', ':'), Nil })	//	HORA - INI
		Aadd(aCabec,{'AB9_DTSAID',  Date()					 , Nil })	//	DATA + FIM
		Aadd(aCabec,{'AB9_HRSAID',  StrTran(cHoraF, '.', ':'), Nil })	//  HORA + FIM
		Aadd(aCabec,{'AB9_DTFIM' ,  Date()					 , Nil })	//	DATA + FIM
		Aadd(aCabec,{'AB9_HRFIM' ,  StrTran(cHoraF, '.', ':'), Nil })	//	HORA + FIM	
		Aadd(aCabec,{'AB9_TIPO'  ,  IIF(lEncerra, '1', '2')	 , Nil })	//	Status      1=Encerrado;2=Em Aberto
		Aadd(aCabec,{'AB9_CODCLI',  AB6->AB6_CODCLI   		 , Nil })
		Aadd(aCabec,{'AB9_LOJA'  ,  AB6->AB6_LOJA   		 , Nil })
//		Aadd(aCabec,{'AB9_RLAUDO',  AB6->AB6_RLAUDO   		 , Nil })	// 	Responsavel pelo Laudo   
//	  	Aadd(aCabec,{'AB9_STATAR',  IIF(lEncerra, '1', '2')  , Nil })	// 	Status da Tarefa  - 1=Encerrado;2=Em Aberto
		//Aadd(aCabec,{'AB9_ENVIOA',  IIF(lEncerra, Date(), )	 , Nil })
		Aadd(aCabec,{'AB9_TOTFAT',	AB6->AB6_TOTALH			 , Nil })  	// Horas Faturadas
		// Aadd(aCabec,{AB9_MEMO1 ,      	, Nil })					
*/	

		Aadd(aCabec,{'AB9_NUMOS' ,	AB6->AB6_NUMOS+'01'		 , Nil })
		Aadd(aCabec,{'AB9_CODTEC', 	ABB->ABB_CODTEC   	  	 , Nil })
		Aadd(aCabec,{'AB9_SEQ'   ,  '01'					 , Nil })
		Aadd(aCabec,{'AB9_CODPRB',  '000001'				 , Nil })
		Aadd(aCabec,{'AB9_DTCHEG',  Date()					 , Nil })	//	DATA - INI
		Aadd(aCabec,{'AB9_HRCHEG',  '10:00'			 		 , Nil })	//	HORA - INI
		Aadd(aCabec,{'AB9_DTINI' ,  Date()					 , Nil })	// 	DATA - INI
		Aadd(aCabec,{'AB9_HRINI' ,  '10:00'					 , Nil })	//	HORA - INI
		Aadd(aCabec,{'AB9_DTSAID',  Date()					 , Nil })	//	DATA + FIM
		Aadd(aCabec,{'AB9_HRSAID',  '11:30'					 , Nil })	//  HORA + FIM
		Aadd(aCabec,{'AB9_DTFIM' ,  Date()					 , Nil })	//	DATA + FIM
		Aadd(aCabec,{'AB9_HRFIM' ,  '11:30'					 , Nil })	//	HORA + FIM	
		Aadd(aCabec,{'AB9_TIPO'  ,  IIF(lEncerra, '1', '2')	 , Nil })	//	Status      1=Encerrado;2=Em Aberto
		Aadd(aCabec,{'AB9_CODCLI',  AB6->AB6_CODCLI   		 , Nil })
		Aadd(aCabec,{'AB9_LOJA'  ,  AB6->AB6_LOJA   		 , Nil })
		Aadd(aCabec,{'AB9_TOTFAT',	'01:30'					 , Nil })  	// Horas Faturadas
		Aadd(aCabec,{'AB9_ENVIOA',  Date()	 , Nil })	

				
// Begin Transaction
// End Transaction
		DbSelectArea('AB9')
		//MSExecAuto( {|x, y, z| TECA460(x, y, z)}, aCabec,  aItens, 3)
		
		TECA460(aCabec,  aItens, 3)                                
		
		//	aCabec := {}
		
				/*
				Aadd(aCabec, AB6->AB6_NUMOS )
				Aadd(aCabec, '01'  ) 
				Aadd(aCabec, ABB->ABB_CODTEC)
				Aadd(aCabec, Date()) 
				Aadd(aCabec, StrTran(cHoraI, '.', ':'))
				Aadd(aCabec, Date() )
				Aadd(aCabec, StrTran(cHoraF, '.', ':'))
				Aadd(aCabec, Date())
				Aadd(aCabec, StrTran(cHoraI, '.', ':'))
				Aadd(aCabec, Date())
				Aadd(aCabec, StrTran(cHoraF, '.', ':'))
				Aadd(aCabec, cCodPrb)
				Aadd(aCabec, IIF(lEncerra, '1', '2'))
				Aadd(aCabec, AB6->AB6_TOTALH )
				*/

				/*
				Aadd(aCabec, '02486501' )
				Aadd(aCabec, '01'  ) 
				Aadd(aCabec, '000003' )
				Aadd(aCabec, Date()) 
				Aadd(aCabec, '10:00' )
				Aadd(aCabec, Date() )
				Aadd(aCabec, '11:00')
				Aadd(aCabec, Date())
				Aadd(aCabec, '10:00')
				Aadd(aCabec, Date())
				Aadd(aCabec, '11:00' )
				Aadd(aCabec, '000001')
				Aadd(aCabec, '2' )
				Aadd(aCabec, '01:00' )
				
				
				At900IncAt(aCabec,aItens,3)
                */

	  	If lMsErroAuto
			MostraErro()        
        EndIf

    ENDIF

    
Return()