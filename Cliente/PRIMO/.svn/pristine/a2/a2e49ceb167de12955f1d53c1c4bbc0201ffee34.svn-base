#INCLUDE "COLORS.CH"
#include "TOTVS.CH"
#include "rwmake.CH"
#INCLUDE "Protheus.ch"
#include "ap5mail.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunÁ„o    ≥ EasyRpt  ≥ Autor ≥ Manoel Mariante       ≥ Data ≥ jan/2018   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriÁ„o ≥ impressao relatorios diversos configurados via arq INI       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ diversos               				                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
//------------------------------------------------------------------
User Function EzRpt(cArqCFGINI,lInterUsr)
//------------------------------------------------------------------
/*IF !LEFT(SM0->M0_CGC,8)$'87678132'.AND.; //cotrisul
   !LEFT(SM0->M0_CGC,8)$'97834188'//motasa
	MSGINFO('CNPJ N„o Autorizado')
	RETURN
End*/

Local nK

Private cExeItens:=""
Private cExeItens1:=""
Private cExeItens2:=""
Private nLInIni2:=0
Private nLinCab2:=0
Private nLInIni:=0
Private nLinCab1:=0
Private lTemSep:=.f.
Private lTemSep1:=.f.
Private lTemSep2:=.f.
Private lTemSep3:=.f.
Private nPulaLinPr:=10
Private nColSepI:=0
Private nColSepF:=0
Private lPaisagem:=.f. 
Private cQryItem:=""
Private cQryItem1:=""
Private cQryItem2:=""
Private cQryItem3:=""
Private aLogo:={}    
Private aEmail:={} 
Private aFontes:={}
Private aOrd       := {} //"Tipo + Grupo + Numero de Rupturas ","Fornecedor + Tipo + Grupo + Numero de Rupturas"}
Private aRotinas:={} 
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private nTipo      := 18
Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   := 0
Private CbTxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private cString    := ""
Private _CRLF      :=CHR(13)+CHR(10)
Private ASECOES    :={} 
Private aObjects   :={}
Private aPerg      :={}
Private cDesc1:=""
Private cDesc2:=""
Private cDesc3:=""
Private cPerg:=""
Private lQUERYSQL:=.F.                    
Private titulo:=""                
Private nColumn:=1
Private RPTMODE:= 'C'
Private lPreview:=.t.
Private CQRYCAB2:="" 
Private CQRYCAB:=""
Private lShowPerg:=LINTERUSR
Private aRotMail:={}
Private aPrePaginas:={}
Private nPrePag:=0
Private aTxtPrePag:={}
Private aCCPaginas:={}
Private nCCPag:=0
Private ARQANEXO:=""
Private cFileName:=""
Private aCabLogo:={}
Private cPATHPDF:='c:\temp\'
PRIVATE  LENVIAMAIL:=.F.
Private  aBody:={}
PRIVATE CQUEBRA:=""
PRIVATE ACABITENS:={}
PRIVATE AITENS:={}
private nMaxItens:=0
private NMAXLIN:=0
private aCabec:={}
private lCabAllPg:=.t.
private cExecCab:=""
private aCabecLn:={}

Private aArqFundo:={}


Private ATXTCCPAG:={}
PRIVATE nVIAS:=1


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
//≥ CARREGAS AS DEFINICOES DO RELATORIO                         
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ   
If FT_FUse( cArqCFGINI ) <> -1 //Verifica se o Projeto esta Disponivel para uso
	FT_FGOTOP() // posiciona no Inicio do Arquivo
	While !FT_FEOF()
		cLinha := AllTrim( FT_FREADLN() )
		
		IF LEFT(cLinha,1)='['  //indica nova secao
			nPos:=AT("]",cLinha)
			cSecao:=Alltrim(Substr(cLinha,2,nPos-2))
			FT_FSKIP()          // Proxima linha
			LOOP
		End
		IF LEFT(cLinha,1)=';' .or.;
		   Empty(cLinha) 
			FT_FSKIP()          
			LOOP
			End
		
		IF Alltrim(cLinha)=='BEGINSQL'
			lQUERYSQL:=.T.
			FT_FSKIP()          
			LOOP
		elseIf Alltrim(cLinha)=='ENDSQL'
			lQUERYSQL:=.F.
			FT_FSKIP()          
			LOOP
		end
			
		If lQUERYSQL
			aConfig:={Alltrim(cLinha)}
		Else
			nPos   :=AT("=",cLinha)
			cChave :=Substr(cLinha,1,nPos-1)
			IF 'QUERY'$cChave
				aConfig:={Substr(cLinha,nPos+1)}
			ELSE
				aConfig:=CharToArr(Substr(cLinha,nPos+1))    
			End
		End
		
		If cSecao='GERAL'.or.cSecao='RELATORIO'
			If cChave='PROGRAMA'
				nomeprog:=aConfig[1]
				wnrel   :=aConfig[1]
			Elseif cChave='ORIENTACAO'
				lPaisagem:=iF(aConfig[1]='P',.T.,.F.)
			elseIf cChave='NOME'
				cNomeRel:=aConfig[1]
			elseIf cChave='FILENAME'
				cFileName:=aConfig[1]
			elseIf cChave='PATHPDF'
				cPATHPDF:=aConfig[1]
			Elseif cChave="EXECROTINA"
				cPrograma:=aConfig[1]
				Aadd(aRotinas,cPrograma)
			Elseif cChave='TITULO'
				//titulo:=If('"' $aConfig[1] .or. "'" $ aConfig[1],&(aConfig[1]),aConfig[1])
				titulo:=aConfig[1]
			Elseif cChave='DESCRICAO1'
				cDesc1:=aConfig[1]
			Elseif cChave='DESCRICAO2'
				cDesc2:=aConfig[1]
			Elseif cChave='DESCRICAO3'
				cDesc3:=aConfig[1]  
			Elseif cChave='LIMITE'
				limite     := VAL(aConfig[1])
			Elseif cChave='TAMANHO'
				tamanho    := aConfig[1]  
			Elseif cChave='ORDEM'
				aOrd       :=aConfig
			Elseif cChave=='MAXLIN'
				nMaxLin:=Val(aConfig[1])
			Elseif cChave=='MAXCOL'
				nMaxCol:=Val(aConfig[1])
			Elseif cChave=='ESPACAMENTO'
				nPulaLin:=Val(aConfig[1])
			//---------------------------
			//PARTE GRAFICA
			//----------------
			
			Elseif cChave='REPORT_MODE'
				RPTMODE:= aConfig[1] 				
			Elseif cChave='PREVIEW'
				lPreview:=iF(Val(aConfig[1])=1,.T.,.F.)
			end
			
		ELSEIF cSecao='EMAIL'
			IF cChave=="DESTINATARIO"
				cTo:=aConfig[1]
			ELSEIF cChave=="NOME"
				cNomeMail:=aConfig[1]
			ELSEIF cChave=="COPIA"
				cCC:=aConfig[1]
			ELSEIF cChave=="ASSUNTO"
				cSubject:=aConfig[1]
			ELSEIF "CORPO"$cChave
				Aadd(aBody,aConfig[1])
			ELSEIF cChave=="ARQANEXO"
				ARQANEXO:=aConfig[1]
			ELSEIF cChave=="ENVIAEMAIL
				lEnviaMail:=IF(Val(aConfig[1])=0,.f.,.t.)
			Elseif cChave="EXECROTINA" .or. cChave="EXECROTINA1" .or. cChave="EXECROTINA2"
				cPrograma:=aConfig[1]
				Aadd(aRotMail,cPrograma)
			END
			
		Elseif 'SECAO'$cSecao
			cSecaoRpt:=STRZERO(val(substr(cSecao,AT('SECAO',cSecao)+Len('SECAO'))),2)  
		 
			nPos:=Ascan(aSecoes, { |x| x[1] == cSecaoRpt })	
			If nPos==0
				Aadd(aSecoes,{cSecaoRpt})
				Private &("COLUMN1"+cSecaoRpt)     :={}
				Private &("COLUMN2"+cSecaoRpt)     :={}
				Private &("COLUMN3"+cSecaoRpt)     :={}
				Private &("COLUMN4"+cSecaoRpt)     :={}
				Private &("COLUMN5"+cSecaoRpt)     :={}
				Private &("COLUMN6"+cSecaoRpt)     :={}
				Private &("COLUMN7"+cSecaoRpt)     :={}
				Private &("CABQUEB"+cSecaoRpt)    :={}
				Private &("RODAP"+cSecaoRpt)      :={}
				Private &("EXEC"+cSecaoRpt)       :={}
				Private &("TITULO"+cSecaoRpt)     :=titulo
				Private &("QUEBRA"+cSecaoRpt)     :=""
				Private &('QUERY'+cSecaoRpt)      :=""
				Private &('ALIAS'+cSecaoRpt)      :=""
				Private &('lSUBTOT'+cSecaoRpt)	  :=""
				Private &('lTOTALFINA'+cSecaoRpt) :=""
				Private &('FINALTXT'+cSecaoRpt)   :={}    
				Private &('SKIPCOND'+cSecaoRpt)   :=""
				PRIVATE &('NEWPAGE'+cSecaoRpt):= .F. 
				PRIVATE &('SAVEQRY'+cSecaoRpt):= .F.
				PRIVATE &('ORIENTA'+cSecaoRpt):= 'H' 
				Private &("LINE"+cSecaoRpt)     :={}
				Private &("ABOX"+cSecaoRpt)     :={}
				Private &("AHEADER"+cSecaoRpt)    :={}
				Private &("ALINES"+cSecaoRpt)    :={}
				Private &("ATEXTO"+cSecaoRpt)    :={}
				PRIVATE &('AFILLBOX'+cSecaoRpt):={}
				PRIVATE &('ALOGO'+cSecaoRpt):={}
				PRIVATE &('ABAR'+cSecaoRpt):={}
				PRIVATE &('AITENS'+cSecaoRpt):={}
				PRIVATE &('ATEXTOH'+cSecaoRpt):={}
				PRIVATE &('AHEADERH'+cSecaoRpt):={}
				PRIVATE &('AROTINAS'+cSecaoRpt):={}
				private &('CVIAS'+cSecaoRpt):=1
			End
			If cChave=='QUERY'.or.lQUERYSQL
				&('QUERY'+cSecaoRpt)+=aConfig[1] +_CRLF
			Elseif cChave='TITULO'
				&('TITULO'+cSecaoRpt):=aConfig[1]
			elseIf cChave=='ALIAS'
				&('ALIAS'+cSecaoRpt):=aConfig[1]
				
			elseIf cChave=='SEC_COLUMN'
				Aadd(&('ATEXTOH'+cSecaoRpt),{aConfig[1],aConfig[2],VAL(aConfig[3]),VAL(aConfig[4]),&(aConfig[5]),If(len(aConfig)>5,aConfig[6],"")})
			elseIf cChave=='SEC_HEADER'
				AADD(&('AHEADERH'+cSecaoRpt),{aConfig[1],val(aConfig[2]),If(len(aConfig)>2,aConfig[3],"")})
			elseIf cChave=='VIAS'
				&('CVIAS'+cSecaoRpt):=aConfig[1]
			elseIf cChave=='COLUNA'
				AADD(&('COLUMN'+STR(nColumn,1)+cSecaoRpt),{VAL(aConfig[1]),aConfig[2],IF(Alltrim(aConfig[3])$'T/.T.',.T.,.F.),aConfig[4],aConfig[5],aConfig[6]}) //POS,CAMPO,SOMA,MASCARA;CABEC1;CABEC2
			elseIf cChave=='QUEBRA'
				&('QUEBRA'+cSecaoRpt):=aConfig[1]
			elseIf cChave=='HEADERTEXT'
				AADD(&('CABQUEB'+cSecaoRpt),aConfig[1])
			elseIf cChave=='EXECROTINA'
				AADD(&('AROTINAS'+cSecaoRpt),aConfig[1])
			elseIf cChave=='FOOTERTEXT'
				AADD(&('RODAP'+cSecaoRpt),aConfig[1])
			elseIf cChave=='EXECROTINA'
				AADD(&('EXEC'+cSecaoRpt),aConfig[1])
			elseIf cChave=='SUBTOTQUEBRA'
				&('lSUBTOT'+cSecaoRpt):=&(aConfig[1])
			elseIf cChave=='TOTALFINAL'
				&('lTOTALFINA'+cSecaoRpt):=&(aConfig[1])
			elseIf cChave=='FINALTEXT'
				AADD(&('FINALTXT'+cSecaoRpt),aConfig[1])
			elseIf cChave=='ADDLINE'
				nColumn++
			elseIf cChave=='SKIPCONDITION'
				&('SKIPCOND'+cSecaoRpt):=aConfig[1]       
			elseIf cChave=='NEWPAGEONQUEBRA'
				&('NEWPAGE'+cSecaoRpt):=&(aConfig[1])      
			elseIf cChave=='SAVEQRY'
				&('SAVEQRY'+cSecaoRpt):=&(aConfig[1])      
			elseIf cChave=='ORIENTATION'
				&('ORIENTA'+cSecaoRpt):= aConfig[1]
			ELSEIF cChave=="LINHA".or.cChave=="LINE"
				AADD(&('ALINES'+cSecaoRpt),{VAL(aConfig[1]),VAL(aConfig[2]),VAL(aConfig[3]),VAL(aConfig[4])})
			ELSEIF cChave=="CAIXA".or.cChave=="BOX"
				AADD(&('ABOX'+cSecaoRpt),{VAL(aConfig[1]),VAL(aConfig[2]),VAL(aConfig[3]),VAL(aConfig[4]),iF(lEN(aConfig)>4,aConfig[5],"-2")})
			ELSEIF cChave=="TEXTO".or.cChave=="TEXT"
				AADD(&('ATEXTO'+cSecaoRpt),{aConfig[1],VAL(aConfig[2]),VAL(aConfig[3]),aConfig[4]})
			ELSEIF cChave=="FILLBOX"
				AADD(&('AFILLBOX'+cSecaoRpt),{VAL(aConfig[1]),VAL(aConfig[2]),VAL(aConfig[3]),VAL(aConfig[4])})
			ELSEIF cChave=="IMG"
				Aadd(&('ALOGO'+cSecaoRpt),{aConfig[1],val(aConfig[2]),val(aConfig[3]),If(len(aConfig)>3,Val(aConfig[4]),0),If(len(aConfig)>4,Val(aConfig[5]),0)})				
			ELSEIF cChave=="CODBAR"
				aSize(aConfig,5)
				Aadd(&('ABAR'+cSecaoRpt),{aConfig[1],VAL(aConfig[2]),VAL(aConfig[3]),VAL(aConfig[4]),aConfig[5]})
			end
		ELSEIF cSecao=='PARAMETROS'
			If cChave=='PERG'
				cPerg:=PADR(aConfig[1],10," ")
			Elseif 'MV_PAR' $ cChave
				Aadd(aPerg,{cChave,aConfig[1],aConfig[2],aConfig[3],aConfig[4],aConfig[5],aConfig[6],aConfig[7],aConfig[08],aConfig[09],aConfig[10],aConfig[11],aConfig[12]})
			Elseif cChave=="RECRIA"
				lDelSX1:=&(aConfig[1])
			End
		ELSEIF cSecao='FONTES'
			IF "PADRAO" = cChave
				cFntPadr:=aConfig[1]
			ELSE
				Aadd(aFontes,{cChave,aConfig[1],Val(aConfig[2]),&(aConfig[3])})
			End
		Elseif cSecao $'CONTRACAPA1/CONTRACAPA2/CONTRACAPA3/CONTRACAPA4/CONTRACAPA5/CONTRACAPA6'
			If cChave=='FUNDO'
				If !File(aConfig[1])
					Alert('Arquivo '+aConfig[1]+" nao encontrado")
				Else
					nCCPag++
					Aadd(aCCPaginas,{aConfig[1],Val(aConfig[2]),Val(aConfig[3])})
				End
			
			elseIf cChave='TEXTO'
				Aadd(aTxtCCPag,{nCCPag,aConfig[1],val(aConfig[2]),val(aConfig[3]),If(len(aConfig)>3,aConfig[4],"")})
			end
		ELSEIF cSecao=="ITENS"
			IF cChave=="TEXTO"
				Aadd(aItens,{aConfig[1],aConfig[2],VAL(aConfig[3]),VAL(aConfig[4]),&(aConfig[5]),If(len(aConfig)>5,aConfig[6],"")})
			ELSEIF cChave="EXECROTINA"
				cExeItens:=aConfig[1]
			End
			
		ELSEIF cSecao=="CABITENS"
			If cChave='TEXTO'
				Aadd(aCabItens,{aConfig[1],val(aConfig[2]),If(len(aConfig)>2,aConfig[3],"")})
			ELSEIf "MAXITENS" $ cChave
				nMaxItens:=Val(aConfig[1])
			ELSEIF cChave=="LINHAINICIAL
			    nLinIni:=VAL(aConfig[1])
			ELSEIF cChave=="LINHA1"
			    nLinCab1:=VAL(aConfig[1])
			ELSEIF cChave=="LINHA2"
			    nLinCab2:=VAL(aConfig[1])
			ELSEIF cChave=="LINHAINICIAL2"
			    nLinIni2:=VAL(aConfig[1])
			ELSEIF cChave=="TEXTO"
				Aadd(aCabItens,{aConfig[1],val(aConfig[2]),If(len(aConfig)>2,aConfig[3],"")})
			ELSEIF cChave=="LINHA"
				Aadd(aCabLine,{val(aConfig[1]),val(aConfig[2]),val(aConfig[3]),val(aConfig[4]) })
			ELSEIF cChave=="SEPARADOR"
				lTemSep:=IF(VAL(aConfig[1])=1,.t.,.f.)
			ELSEIF cChave=="COLSEPI"
				nColSepI:=VAL(aConfig[1])
			ELSEIF cChave=="COLSEPF"
				nColSepF:=VAL(aConfig[1])
			End
		ELSEIF cSecao='CABRELATORIO'
			IF cChave="TEXTO"
				Aadd(aCabec,{aConfig[1],val(aConfig[2]),val(aConfig[3]),If(len(aConfig)>3,aConfig[4],"")})
			ELSEIF cChave="CABECEMTODASPG"
				lCabAllPg:=If(VAL(aConfig[1])=1,.t.,.f.)
			ELSEIF cChave="EXECROTINA"
				cExecCab:=aConfig[1]
			ELSEIF cChave=="LINHA"
				Aadd(aCabecLn,{val(aConfig[1]),val(aConfig[2]),val(aConfig[3]),val(aConfig[4]) })
			ELSEIF cChave=="IMG"
				Aadd(aCabLogo,{aConfig[1],val(aConfig[2]),val(aConfig[3]),If(len(aConfig)>3,Val(aConfig[4]),0),If(len(aConfig)>4,Val(aConfig[5]),0)})
			END
			
				
			
			
		/*Elseif 'CREATEOBJ'$cSecao      
			cSecaoObj:=STRZERO(val(substr(cSecao,AT('CREATEOBJ',cSecao)+Len('CREATEOBJ'))),2)  
		 
			nPos:=Ascan(aObjects, { |x| x[1] == cSecaoObj })	
			If nPos==0
				Aadd(aObjects,{cSecaoObj})   
				
				Private &("NAMEOBJ"+cSecaoObj)    :={}
				Private &("ACTION"+cSecaoObj)     :=0
				Private &("QRYOBJ"+cSecaoObj)     :=""
			END
				
			If cChave=='QUERY'.or.lQUERYSQL
				&("QRYOBJ"+cSecaoObj)+=aConfig[1] +_CRLF
			ELSEIF cChave=="NAMEOBJ"
				&("NAMEOBJ"+cSecaoObj):=aConfig[1]       			
			ELSEIF cChave=="ACTION"
				&("ACTION"+cSecaoObj):=VAL(aConfig[1])
			END*/
			
		END
		
		FT_FSKIP()// Proxima linha
	EndDo
	FT_FUSE() // libera o arquivo
Else
	MsgAlert("Nao foi possivel abrir o arquivo "+cArqCFGINI+"." )
	RETURN
EndIf

IF lDelSX1
	DbSelectArea("SX1")
	DbSetOrder(1)                   
	DbSeek(cPerg)
	While X1_GRUPO==cPerg
		RecLock('SX1',.f.)
		dbDelete()
		msUnlock()
		dbskip()
	End
End

DbSelectArea("SX1")
DbSetOrder(1)
For nK := 1 to Len( aPerg )
	cX1_VARIAVL:="mv_"+Strzero(nK,3)
	EZRPTSx1(cPerg     ,Strzero(nK,2),aPerg[nK,02], cX1_VARIAVL   ,aPerg[nK,03], val(aPerg[nK,04]), val(aPerg[nK,05]), aPerg[nK,06], ' '       ,aPerg[nK,07],aPerg[nK,08], aPerg[nK,09], aPerg[nK,10], aPerg[nK,11],aPerg[nK,01],aPerg[nK,12])
Next

If !empty(cPerg)
	pergunte(cPerg,.F.)
End

IF RPTMODE='C'

	CHARMODE()
ELSE

	GRAFMODE()
END

Return


//----------------------------------------------------------
Static Function CHARMODE()
//----------------------------------------------------------
Local nK := 0 

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

	If nLastKey == 27
	Return
	Endif

SetDefault(aReturn,cString)

	If nLastKey == 27
	Return
	Endif

nTipo := If(aReturn[4]==1,15,18)

	For nK:=1 To Len(aSecoes)
	cSecaoRpt:=aSecoes[nK,1]

	RptStatus({|| ProcRpt(&('QUERY'+cSecaoRpt)     ,;   
	                      &('ALIAS'+cSecaoRpt)     ,; 
	                      &('COLUMN1'+cSecaoRpt)   ,;
	                      &('QUEBRA'+cSecaoRpt)    ,; 
	                      &('CABQUEB'+cSecaoRpt)   ,; 
	                      &('RODAP'+cSecaoRpt)     ,; 
	                      &('lSUBTOT'+cSecaoRpt)   ,;
	                      &('lTOTALFINA'+cSecaoRpt),;
	                      &('EXEC'+cSecaoRpt)      ,;
	                      &('TITULO'+cSecaoRpt)    ,;
	                      &('FINALTXT'+cSecaoRpt)  ,;
	                      &('SKIPCOND'+cSecaoRpt)  ,;
	                      &('SAVEQRY'+cSecaoRpt)   ,;
	                      &('ORIENTA'+cSecaoRpt)   ,;
	                      &('LINE'+cSecaoRpt)      ,; 
	                      &('COLUMN2'+cSecaoRpt)   ,;
	                      &('COLUMN3'+cSecaoRpt)   ,;
	                      &('COLUMN4'+cSecaoRpt)   ,;
	                      &('COLUMN5'+cSecaoRpt)   ,;
	                      &('COLUMN6'+cSecaoRpt)   ,;
	                      &('COLUMN7'+cSecaoRpt)   ,;
	                      &('AHEADER'+cSecaoRpt)   ,;
	                      ) },Titulo)

	Next

SET DEVICE TO SCREEN
	If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
	Endif
MS_FLUSH()
Return Nil

//-----------------------------------------------
Static Function ProcRpt(cQuery,cALias,aCol1,cQuebra,aCabQueb,aRodape,LSUBTOT,LTOTALFINA,aExec,titulo,aFinalText,cSkipCond,lSaveQry,cOrienta,aLine,aCol2,aCol3,aCol4,aCol5,aCol6,aCol7,aHeader)
//-----------------------------------------------

Local nC := 0 
Local nH := 0 
Local nL := 0 


Private nLin       := 999
Private lTemLinha1  :=.f.
Private lTemLinha2  :=.f.
Private lTemLinha3  :=.f.
Private lTemLinha4  :=.f.
Private lTemLinha5  :=.f.     
Private aColumns1   := aCol1
Private aColumns2   := aCol2
Private aColumns3   := aCol3
Private aColumns4   := aCol4
Private aColumns5   := aCol5

cQuery:=fAjustQry(cQuery)
//titulo:=fAjustQry(titulo)
	If lSaveQry
	MEMOWRITE( "\LOGS\"+CriaTrab(,.F.)+".SQL" ,cQuery ) // Grava query na pasta cprova
	end

dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAlias, .t., .t.) 

COUNT TO vtotreg    
DBGOTOP()

SetRegua(vtotreg) 

	If cOrienta=='H'
	NSUBCOUNT:=0
	NTOTCOUNT:=0
	
	//inicializo variaveis de subtotal e total da quebra
		for nL:=1 to 99
		//linha 1
		&('SUBTOT1'+STRZERO(nL,2)):=0
		&('TOTAL1'+STRZERO(nL,2)):=0
		//linha 2
		&('SUBTOT2'+STRZERO(nL,2)):=0
		&('TOTAL2'+STRZERO(nL,2)):=0
		//linha 3
		&('SUBTOT3'+STRZERO(nL,2)):=0
		&('TOTAL3'+STRZERO(nL,2)):=0
		//linha 4
		&('SUBTOT4'+STRZERO(nL,2)):=0
		&('TOTAL4'+STRZERO(nL,2)):=0
		//linha 5
		&('SUBTOT5'+STRZERO(nL,2)):=0
		&('TOTAL5'+STRZERO(nL,2)):=0
		next
	
	//ajusta os cabecalhos
	Cabec1 :=Space(LIMITE)
	Cabec2 :=Space(LIMITE)
	nAuxCol:=001
		For nC:=1 To Len(aColumns1)
		cTxtLine1:=Alltrim(aColumns1[nC,5])
		cTxtLine2:=Alltrim(aColumns1[nC,6])
		nTamStuff:=0
		
			If Valtype(&(aColumns1[nC,2]))='C'
			nTamStuff:=Len(&(aColumns1[nC,2])) 
			
			Elseif Valtype(&(aColumns1[nC,2]))='N'
			nTamStuff:=Len(transform(&(aColumns1[nC,2]),aColumns1[nC,4]))
		
			Elseif Valtype(&(aColumns1[nC,2]))='D'
			nTamStuff:=Len(DTOC(&(aColumns1[nC,2])))
		
			Elseif Valtype(&(aColumns1[nC,2]))='L'
			nTamStuff:=1
			End
		
			If Len(cTxtLine1) > nTamStuff
			nTamStuff:=Len(cTxtLine1)
			End
			If Len(cTxtLine2) > nTamStuff
			nTamStuff:=Len(cTxtLine2)
			End
			If nTamStuff<10
			nTamStuff:=10
			End
	
			If aColumns1[nC,1]==0
			nInicio:=nAuxCol
			aColumns1[nC,1]:=nAuxCol
			Else
			nInicio:=aColumns1[nC,1]
			End
		
			If Valtype(&(aColumns1[nC,2]))$'C/D/L'
			cTxtLine1:=PADC(cTxtLine1,nTamStuff,' ')
			cTxtLine2:=PADC(cTxtLine2,nTamStuff,' ')
			Else
			cTxtLine1:=PADL(cTxtLine1,nTamStuff,' ')
			cTxtLine2:=PADL(cTxtLine2,nTamStuff,' ')
			END
		
		Cabec1:=STUFF(Cabec1,nInicio+1,nTamStuff,cTxtLine1)
		Cabec2:=STUFF(Cabec2,nInicio+1,nTamStuff,cTxtLine2)  
		
		nAuxCol:=nInicio+nTamStuff+2
		Next
	
	//define a quebra
		If !Empty(cQuebra)
		cAuxQue:=&(cQuebra)
		else
		cAuxQue:=""
		End
	
	lPrimVez:=.T.
		While !eof()
	
			If nLin > MAXLIN
			nLin:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,,"logo.bmp")+1
				For nH:=1 to Len(aHeader)
				@ nlin,00 psay &(aHeader[nH])
				nLin++
				Next
			Endif
		
		INCREGUA()
		
		//condicao de pulo de linha
			If !Empty(cSkipCond).and. &(cSkipCond)
			dbSkip()
			Loop
			End
		
			If lPrimVez.and.Len(aCabQueb)>0
				For nL:=1 to Len(aCabQueb)
				@ nLin,001 Psay &(aCabQueb[nL])
				nLin++
				Next
			nLin++
			lPrimVez:=.f.
			End
	
			IF cAuxQue<>&(cQuebra)
				IF LSUBTOT
				fSubTotal('SUBTOT','Subtotal',aRodape) 
				End
			NSUBCOUNT:=0
			cAuxQue:=&(cQuebra)
			//inicializo variaveis de subtotal e total da quebra
				for nL:=1 to 99
				&('SUBTOT1'+STRZERO(nL,2)):=0
				&('SUBTOT2'+STRZERO(nL,2)):=0
				&('SUBTOT3'+STRZERO(nL,2)):=0
				&('SUBTOT4'+STRZERO(nL,2)):=0
				&('SUBTOT3'+STRZERO(nL,2)):=0
				next
			
				For nL:=1 to Len(aCabQueb)
				@ nLin,001 Psay &(aCabQueb[nL])
				nLin++
				Next
			nLin++
		
			end
			
		//IMPRIME AS COLUNAS COM OS DADOS
			For nL:=1 to Len(aColumns1)
			lTemLinha1:=.t.
				If !Empty(aColumns1[nL,4])
				@ nLin,aColumns1[nL,1] PSAY transform(&(aColumns1[nL,2]),aColumns1[nL,4])
				else
				@ nLin,aColumns1[nL,1] PSAY &(aColumns1[nL,2])		
				end
			
				IF VALTYPE(&(aColumns1[nL,2])) = 'N'
				&('SUBTOT1'+STRZERO(nL,2))+=&(aColumns1[nL,2])
				&('TOTAL1'+STRZERO(nL,2))+=&(aColumns1[nL,2]) 
				END
			Next
			If Len(aColumns2)>0
			nLin++     
			end
			If nLin > MAXLIN
			nLin:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,,"LOGO_PRIMO.bmp")+1
				For nH:=1 to Len(aHeader)
				@ nlin,00 psay &(aHeader[nH])
				nLin++
				Next
			
			Endif
		
			For nL:=1 to Len(aColumns2)
			lTemLinha2:=.t.
				If !Empty(aColumns2[nL,4])
				@ nLin,aColumns2[nL,1] PSAY transform(&(aColumns2[nL,2]),aColumns2[nL,4])
				else
				@ nLin,aColumns2[nL,1] PSAY &(aColumns2[nL,2])		
				end
			
				IF VALTYPE(&(aColumns2[nL,2])) = 'N'
				&('SUBTOT2'+STRZERO(nL,2))+=&(aColumns2[nL,2])
				&('TOTAL2'+STRZERO(nL,2))+=&(aColumns2[nL,2]) 
				END
			Next
		
			If Len(aColumns3)>0
			nLin++     
			end
			If nLin > MAXLIN
			nLin:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,,"LOGO_PRIMO.bmp")+1
				For nH:=1 to Len(aHeader)
				@ nlin,00 psay &(aHeader[nH])
				nLin++
				Next
			
			Endif
		
			For nL:=1 to Len(aColumns3)
			lTemLinha3:=.t.
				If !Empty(aColumns3[nL,4])
				@ nLin,aColumns3[nL,1] PSAY transform(&(aColumns3[nL,2]),aColumns3[nL,4])
				else
				@ nLin,aColumns3[nL,1] PSAY &(aColumns3[nL,2])		
				end
			
				IF VALTYPE(&(aColumns3[nL,2])) = 'N'
				&('SUBTOT3'+STRZERO(nL,2))+=&(aColumns3[nL,2])
				&('TOTAL3'+STRZERO(nL,2))+=&(aColumns3[nL,2]) 
				END
			Next
		
			If Len(aColumns4)>0
			nLin++     
			end

			If nLin > MAXLIN
			nLin:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,,"LOGO_PRIMO.bmp")+1
				For nH:=1 to Len(aHeader)
				@ nlin,00 psay &(aHeader[nH])
				nLin++
				Next
			
			Endif

			For nL:=1 to Len(aColumns4)
			lTemLinha4:=.t.
				If !Empty(aColumns4[nL,4])
				@ nLin,aColumns4[nL,1] PSAY transform(&(aColumns4[nL,2]),aColumns4[nL,4])
				else
				@ nLin,aColumns4[nL,1] PSAY &(aColumns4[nL,2])		
				end
			
				IF VALTYPE(&(aColumns4[nL,2])) = 'N'
				&('SUBTOT4'+STRZERO(nL,2))+=&(aColumns4[nL,2])
				&('TOTAL4'+STRZERO(nL,2))+=&(aColumns4[nL,2]) 
				END
			Next

			If Len(aColumns5)>0
			nLin++     
			end
			If nLin > MAXLIN
			nLin:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,,"LOGO_PRIMO.bmp")+1
				For nH:=1 to Len(aHeader)
				@ nlin,00 psay &(aHeader[nH])
				nLin++
				Next
			
			Endif

			For nL:=1 to Len(aColumns5)
			lTemLinha5:=.t.
				If !Empty(acolumns5[nL,4])
				@ nLin,acolumns5[nL,1] PSAY transform(&(acolumns5[nL,2]),acolumns5[nL,4])
				else
				@ nLin,acolumns5[nL,1] PSAY &(acolumns5[nL,2])		
				end
			
				IF VALTYPE(&(aColumns5[nL,2])) = 'N'
				&('SUBTOT5'+STRZERO(nL,2))+=&(aColumns5[nL,2])
				&('TOTAL5'+STRZERO(nL,2))+=&(aColumns5[nL,2]) 
				END
			Next

		NSUBCOUNT++
		NTOTCOUNT++
		
		dbSelectArea(cAlias)
		dbSkip()
		nLin++
		
		end
		IF LSUBTOT
		fSubTotal('SUBTOT','Subtotal',aRodape)
		End
		IF LTOTALFINA
		fSubTotal('TOTAL','Total ->',aFinalText)
		end
	      
	Elseif cOrienta='V'

	//define a quebra
		If !Empty(cQuebra)
		cAuxQue:=&(cQuebra)
		else
		cAuxQue:=""
		End

		While !eof()
	
			If nLin > MAXLIN
			//nLin:=Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo,,,"LOGO_PRIMO.bmp")+1
			nLin:=Cabec(Titulo,"","",NomeProg,Tamanho,nTipo,,,"LOGO_PRIMO.bmp")+1
				For nH:=1 to Len(aHeader)
				@ nlin,00 psay &(aHeader[nH])
				nLin++
				Next
			
			Endif
		
		INCREGUA()  
		
		//condicao de pulo de linha
			If !Empty(cSkipCond).and. &(cSkipCond)
			dbSkip()
			Loop
			End
		
			IF cAuxQue<>&(cQuebra)
			cAuxQue:=&(cQuebra)
				For nL:=1 to Len(aCabQueb)
				@ nLin,001 Psay &(aCabQueb[nL])
				nLin++
				Next
			nLin++
			end
		
		//IMPRIME AS linhas COM OS DADOS
			For nL:=1 to Len(aLine)
			@ aLine[nL,1],aLine[nL,2] PSAY &(aLine[nL,3])		                 
			Next

		dbSelectArea(cAlias)
		dbSkip()     
		
		nLin:=9999
		End
	End

dbSelectArea(cAlias)
dbCloseArea()

Return
//----------------------------------------------------------------------
Static Function fSubTotal(cVarTot,cTexto,aTxt)
//----------------------------------------------------------------------
	Local nL := 0 
	//nLin++
	@ nLin, 00  PSAY __PrtThinLine()
	nLIn++
	@ nlin,01 psay cTexto
	
	If lTemLinha1
		For nL:=1 to Len(aColumns1)
			If aColumns1[nL,3] //soma
				@ nLin,aColumns1[nL,1] PSAY transform(&(cVarTot+'1'+STRZERO(nL,2)),aColumns1[nL,4])
			End
		Next
		nLin++      
	End
	If lTemLinha2
		For nL:=1 to Len(aColumns2)
			If aColumns2[nL,3] //soma
				@ nLin,aColumns2[nL,1] PSAY transform(&(cVarTot+'2'+STRZERO(nL,2)),aColumns2[nL,4])
			End
		Next
		nLin++      
	End
	If lTemLinha3
		For nL:=1 to Len(aColumns3)
			If aColumns3[nL,3] //soma
				@ nLin,aColumns3[nL,1] PSAY transform(&(cVarTot+'3'+STRZERO(nL,2)),aColumns3[nL,4])
			End
		Next
		nLin++      
	End
	If lTemLinha4
		For nL:=1 to Len(aColumns4)
			If aColumns4[nL,3] //soma
				@ nLin,aColumns4[nL,1] PSAY transform(&(cVarTot+'4'+STRZERO(nL,2)),aColumns4[nL,4])
			End
		Next
		nLin++      
	End
	
	If lTemLinha5
		For nL:=1 to Len(aColumns5)
			If aColumns5[nL,3] //soma
				@ nLin,aColumns5[nL,1] PSAY transform(&(cVarTot+'5'+STRZERO(nL,2)),aColumns5[nL,4])
			End
		Next
		nLin++      
	End
	For nL:=1 to Len(aTxt)
		@ nLin,001 PSAY &(aTxt[nL])
		nLin++
	Next
	@ nLin, 00  PSAY __PrtThinLine()
	nLin++         

Return


//----------------------------------------------------------------------
Static Function fAjustQry(cQry)
//----------------------------------------------------------------------
	While AT("#",cQry)<>0
		nPosI:=AT("#",cQry)
		nPosF:=AT("\#",cQry)
		cVari:=Substr(cQry,nPosI+1,nPosF-nPosI-1)
		cQry:=StrTran(cQry,"#"+cVari+"\#",&(cVari)) 
	End
	While AT("&",cQry)<>0
		nPosI:=AT("&",cQry)
		nPosF:=AT("\&",cQry)
		cVari:=Substr(cQry,nPosI+1,nPosF-nPosI-1)
		cQry:=StrTran(cQry,"&"+cVari+"\&",&(cVari)) 
	End
	
	MEMOWRITE( "\LOGS\"+CriaTrab(,.F.)+".SQL" ,cQry ) // Grava query na pasta cprova
	//cQry := ChangeQuery(cQry)                  
	
Return cQry

//-------------------------------------------------------------------------------
STATIC Function EZRPTSx1( cX1_GRUPO,cX1_ORDEM,cX1_PERGUNT, cX1_VARIAVL,  cX1_TIPO,  cX1_TAMANHO,  cX1_DECIMAL,  cX1_GSC,  cX1_VALID,  cX1_DEF01, cX1_DEF02,cX1_DEF03,cX1_DEF04,cX1_DEF05, cX1_VAR01,cX1_F3)
//-------------------------------------------------------------------------------
	cX1_GRUPO:=PADR(Alltrim(cX1_GRUPO),10,' ')
	dbSelectArea("SX1")
	dbSetOrder(1)
	If !dbSeek(cX1_GRUPO+cX1_ORDEM)
		Reclock("SX1",.t.)
	Else
		Reclock("SX1",.F.)
	end
	X1_GRUPO	:=cX1_GRUPO
	X1_ORDEM	:=cX1_ORDEM
	X1_PERGUNT	:=cX1_PERGUNT
	X1_VARIAVL	:=cX1_VARIAVL
	X1_TIPO		:=cX1_TIPO
	X1_TAMANHO	:=cX1_TAMANHO
	X1_DECIMAL	:=cX1_DECIMAL
	X1_GSC		:=cX1_GSC
	X1_VALID	:=cX1_VALID
	X1_DEF01	:=cX1_DEF01
	X1_DEF02	:=cX1_DEF02
	X1_DEF03	:=cX1_DEF03
	X1_DEF04	:=cX1_DEF04
	X1_DEF05	:=cX1_DEF05
	X1_VAR01	:=cX1_VAR01						 
	X1_F3   	:=cX1_F3
	msUnlock()
	
Return

//-----------------------------------------------
Static Function GRAFMODE()
//-----------------------------------------------
	Local nK := 0 
	If lShowPerg //carrega tela de parametros para usuario
	Pergunte(cPerg,.F.)
	
	Private aSays     := { }
	Private aButtons  := { } 
	Private cCadastro := cNomeRel
	Private nOpca     := 0
	
	AADD(aSays,OemToAnsi(cNomeRel) )  
	
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch()  }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	
	FormBatch( cCadastro, aSays, aButtons )
	    	
	Else // nao abre tela. Parametros vem configurados conforme paramatro 12 do chave do INI
		For nK:=1 to Len(aPerg)
		cVariav:="MV_PAR"+Strzero(nK,2)
		PRIVATE &(cVariav):=&(aPerg[nK,13])
		Next
	nOpca := 1
	End

	If nOpca == 1
	RptStatus({|lEnd| Imprime(@lEnd,wnRel,titulo) ,"Imprimindo ...."})
	EndIf
Return 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunÁ„o    ≥IMPRIME   ≥ Autor ≥ Manoel M Mariante     ≥ Data ≥ nov/15     ≥±±
±±ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function Imprime(lEnd,wnRel,titulo)
//---------------------------------------------------------------------------------------------
//variaveis diversas
//---------------------------------------------------------------------------------------------

Local nRot := 0 
Local nL := 0 
Local nK := 0 
Local nS := 0 
Local _VIA := 1

Private oPrint     	:= Nil
Private cTitulo 	:= cNomeRel
Private nPagina 	:= 1

//---------------------------------------------------------------------------------------------
//carrega e define as fontes que serao usadas
//---------------------------------------------------------------------------------------------
	For nK:=1 To Len(aFontes)
	Private &(aFontes[nK,1]) := TFont():New(aFontes[nK,2],09,aFontes[nK,3],,aFontes[nK,4],,,,,.F.,.F.)
	Next nK

lAdjustToLegacy := .F. 
lDisableSetup  := .T.                   
	IF EMPTY(CFILENAME)
		cArqPDF:=CRIATRAB(,.F.)
	ELSE
		cArqPDF:=&(CFILENAME)
	ENDIF
//---------------------------------------------------------------------------------------------
//Inicializa Objeto TMSPrinter						         ≥
//---------------------------------------------------------------------------------------------

oPrint := FWMSPrinter():New(cArqPDF, IMP_PDF, lAdjustToLegacy, , lDisableSetup)
// Ordem obrig·toria de configuraÁ„o do relatÛrio
//oPrint:SetResolution(72)
	If !lPaisagem
		oPrint:SetPortrait()
	else
		oPrint:SetLandScape()
	EndIf
//oPrint:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior 
//oPrint :SetPortrait() //-- Retrato ===== SetLandScape() //-- Paisagem 
//oPrint :Setup() 	  //-- Configurar Impressao

oPrint:SetPaperSize(9) 
oPrint:cPathPDF := cPATHPDF // Caso seja utilizada impress„o em IMP_PDF
	If nVIAS==0
		nVIAS:=1
	Endif
	FOR nS:=1 to Len(aSecoes)
		Private nLinha     	:= 9999
		
		cSec:=aSecoes[nS,1]
		ORIENTA01   :=&('ORIENTA'+cSec)
		QUERY01		:=&('QUERY'+cSec)
		ALIAS01		:=&('ALIAS'+cSec)
		ATEXTOH01	:=&('ATEXTOH'+cSec)
		AHEADERH01	:=&('AHEADERH'+cSec)
	
		IF ORIENTA01 = 'H' //orienntacao horizontal
	
			//-------------------------------------------------------------------------------------------------------------------
			//faz o ajuste das perguntas dentro da query principal
			//-------------------------------------------------------------------------------------------------------------------
			cQryCab:=fAjustQry(QUERY01)
			
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQryCab), ALIAS01, .F., .T.) 
			
			//Count to nRegistros
			//SetRegua(nRegistros)
			dbSelectArea(ALIAS01)
			DbGoTop()           
			
		//---------------------------------------------------------------------------------------------
		//inicia a impressao
		//---------------------------------------------------------------------------------------------
			If cQuebra<>NIL.And. !empty(cQuebra)
			cAuxQuebra:=&(cQuebra)
			EndIf
			lEntrou:=.f.
		
			Do While ! &(ALIAS01)->(EOF())
				for nRot:=1 to Len(aRotinas)
				cRotina:=aRotinas[nRot]
				&(cRotina)
				Next nRot
		
				//------------------------------------------------
				// ZERA AS VARIAVEIS DINAMICAS DE SOMA
				//---------------------------------------------------
				For nL:=1 to 99
						cVarSoma:="NSOMA"+STRZERO(nL,2)
						&(cVarSoma):=0
				Next nL
			
				If !Empty(cQryCab2)
					//-------------------------------------------------------------------------------------------------------------------
					//faz o ajuste das perguntas dentro da query do cabecalho
					//-------------------------------------------------------------------------------------------------------------------
					cQryAux2:=fAjustQry(cQryCab2)
					dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQryAux2), cArqCAB2, .F., .T.) // executa query dos orcamentos
				EndIf
				
				MyPrePag()
				
				If !Empty(cQryItem)
					//-------------------------------------------------------------------------------------------------------------------
					//faz o ajuste das perguntas dentro da query secundaria
					//-------------------------------------------------------------------------------------------------------------------
					cAuxQItem:=fAjustQry(cQryItem)
					dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cAuxQItem), cArqItem, .F., .T.) // executa query dos orcamentos
				
					MyDetails(cArqItem,aItens,aCabItens,1,nLinha,aCabLine,1,aRodape,cExeRodaP,lTemSep)
					
					dbSelectArea(cArqItem)
					dbCloseArea()
					
				ELSE
					MyDetails(ALIAS01,ATEXTOH01,AHEADERH01,1,nLinha,{},1,{},'',.F.)
				
				EndIf
				
				MyContraC()       
				
				/*lEntrou:=.t.          
				cDesTin:=&(cTo)
				cCCopy:=&(cCC)
				cAssunto:=&(cSubject)
				cCorpo  :=""
				For nBody:=1 to Len(aBody)
					cCorpo+=&(aBody[nBody])
				Next
				MEMOWRITE( "\LOGS\"+CriaTrab(,.F.)+".HTML" ,cCorpo ) // Grava query na pasta cprova
				
				cNameMail:=&(cNomeMail)
				
				If !Empty(cQryCab2)
					dbSelectArea(cArqCAB2)
					dbCloseArea() 
				end*/
			
				dbSelectArea(ALIAS01)
				dbskip()
			EndDo
		
		oPrint:EndPage()         
		
		ELSEIF ORIENTA01='V' //ORIENTACAO VERTICAL
		//oPrint:StartPage() // Inicia uma nova pagina	
		LENTROU:=.f.
		
			If !Empty(QUERY01)
			cQryAux:=fAjustQry(QUERY01)
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQryAux), ALIAS01, .F., .T.) // executa query dos orcamentos
			EndIf
	
			Do While ! &(ALIAS01)->(EOF())
		
				CAUX:=&('CVIAS'+cSec)
				NVIAS01		:=&(CAUX)
				IF NVIAS01==0
					NVIAS01:=1
				ENDIF
			
				FOR _VIA:=1 to NVIAS01
			
					oPrint:StartPage() // Inicia uma nova pagina
	
					for nRot:=1 to Len(AROTINAS01)
					cRotina:=AROTINAS01[nRot]
					&(cRotina)
					Next nRot
				
			    	MyPrePag()
			  		LENTROU:=.t.
			    
					For nL:=1 to Len(ABOX01)
						oPrint:BOX( ABOX01[nL,1],ABOX01[nL,2],ABOX01[nL,3],ABOX01[nL,4],ABOX01[nL,5])
					Next nL
					For nL:=1 to Len(ALINES01)
						oPrint:Line( ALINES01[nL,1],ALINES01[nL,2],ALINES01[nL,3],ALINES01[nL,4])
					Next nL
				
					For nL:=1 to LEN(AFILLBOX01)
						oBrush1 := TBrush():New( , CLR_GRAY)
						oPrint:Fillrect( {AFILLBOX01[nL,1],AFILLBOX01[nL,2],AFILLBOX01[nL,3],AFILLBOX01[nL,4] }, oBrush1, "-2")
					Next nL
					For nL:=1 to LEN(ATEXTO01)
						if ("H6_LOTECTL" $ ATEXTO01[nL,1])
							oPrint:say(ATEXTO01[nL,2],ATEXTO01[nL,3],iif(Empty(&(ATEXTO01[nL,1])),RIGHT(ALLTRIM(SH6->H6_XETIQ),8),&(ATEXTO01[nL,1])),If(Empty(ATEXTO01[nL,4]),&(cFntPadr),&(ATEXTO01[nL,4])))
						else
							oPrint:say(ATEXTO01[nL,2],ATEXTO01[nL,3],&(ATEXTO01[nL,1]),If(Empty(ATEXTO01[nL,4]),&(cFntPadr),&(ATEXTO01[nL,4])))
						endif
					Next nL
				          
					For nK:=1 to Len(ALOGO01)
						If ALOGO01[nK,4]<>0
							oPrint:SayBitmap(ALOGO01[nK,2],ALOGO01[nK,3],ALOGO01[nK,1],ALOGO01[nK,4],ALOGO01[nK,5]) //TMSPrinter(): SayBitmap ( [ nRow], [ nCol], [ cBitmap], [ nWidth], [ nHeight], [ uParam6], [ uParam7] ) -->
						Else
							oPrint:SayBitmap(ALOGO01[nK,2],ALOGO01[nK,3],ALOGO01[nK,1]) //,248,158) //Linha, Coluna, Largura, Altura
						EndIf
					Next nK

					For nL:=1 to LEN(ABAR01)
						If ValType('ABAR01[nL,5]') == 'U' .OR. Empty(ABAR01[nL,5])  .OR. 'CODE128B' $ UPPER(ABAR01[nL,5])
							//AlfanumÈricos + NumÈricos + Caracteres especiais
							oPrint:Code128B(ABAR01[nL,2], ABAR01[nL,3], &(ABAR01[nL,1]) , ABAR01[nL,4])
						ElseiF 'QRCODE' $ UPPER(ABAR01[nL,5])
							//FWMsPrinter(): QRCode ( < nRow>, < nCol>, < cCodeBar>, < nSizeBar> ) -->
							oPrint:QRCode(ABAR01[nL,2], ABAR01[nL,3], &(ABAR01[nL,1]) , ABAR01[nL,4])
						ElseiF 'CODE128C' $ UPPER(ABAR01[nL,5])
							//NumÈricos
							oPrint:Code128C(ABAR01[nL,2], ABAR01[nL,3], &(ABAR01[nL,1]) , ABAR01[nL,4])
						Endif
					Next nL
				
			    
				MyContraC()       
				
				Next _VIA
			dbskip()
			EndDo
	
		ENDIF
	dbSelectArea(ALIAS01)
	dbCloseArea()
	NEXT  nS
	
	IF lEntrou.and.lEnviaMail
		lCompacta := .T.
		lSucess := CpyT2S("c:\temp\"+cArqPDF+".pdf","\spool\",lCompacta)    
			
		// Trata retorno da cÛpia
		if !lSucess
		Alert("Falha na cÛpia")
		endif
		
		Private oDlg        
		cCCopy :=Padr(cCCopy,120," ") 
		cDesTin:=Padr(cDesTin,120," ") 
		cAssunto:=Padr(cAssunto,400," ")
		nOpca   :=0
			
		DEFINE MSDIALOG oDlg TITLE "InformaÁıes do Destinat·rio" FROM 000,000 TO 200,600 PIXEL 
		@ 001,001 TO 100, 350 OF oDlg PIXEL 
		
		@ 012,010 SAY "Para   :" SIZE 55, 07 OF oDlg PIXEL
		@ 010,040 GET cDesTin SIZE 200,10 of oDlg PIXEL
		
		@ 027,010 SAY "Cc     :" SIZE 55, 07 OF oDlg PIXEL         
		@ 025,040 GET cCCopy SIZE 200,10 of oDlg PIXEL
		
		@ 042,010 SAY "Cco    :" SIZE 55, 07 OF oDlg PIXEL         
		@ 040,040 GET cOculto SIZE 200,10 of oDlg PIXEL
		
		@ 057,010 SAY "Assunto:" SIZE 55, 07 OF oDlg PIXEL         
		@ 055,040 GET cAssunto SIZE 250,10 of oDlg PIXEL
		
		DEFINE SBUTTON FROM 080,200 TYPE 1 ACTION (nOpca :=1,oDlg:End()); 
		ENABLE OF oDlg 

		DEFINE SBUTTON FROM 080,100 TYPE 2 ACTION (nOpca :=2,oDlg:End()); 
		ENABLE OF oDlg 

		ACTIVATE MSDIALOG oDlg CENTERED  

		IF nOpca <> 1
				dbselectarea(ALIAS01)
				dbCloseArea()       
				Return
		EndIf
		
		for nRot:=1 to Len(aRotMail)
				cRotina:=aRotMail[nRot]
				&(cRotina)
		Next nRot
		
			cAnexo:="\spool\"+cArqPDF+".pdf" 
		
			MySendMail(cDesTin,cCCopy,cOculto,cAssunto,cCorpo,cAnexo)
		
	EndIf

oPrint:EndPage()
oPrint:SetViewPDF(lPreview)
oPrint:Preview()
 
INKEY(3)
FErase( "\spool\"+cArqPDF+".pdf" )
FErase( "c:\temp\"+cArqPDF+".pdf" )

//dbselectarea(ALIAS01)
//dbCloseArea()       

MS_FLUSH()

Return Nil

//-------------------------------------------------------------------------------------------------------
// impressao dos detalhes (produtos)
//-------------------------------------------------------------------------------------------------------
Static Function MyDetails(cArqCABx,aItensX,aCabItensX,nProxNiv,nLinhaX,aCabLnX,nPagAtuX,aAuxRPEx,cAuxRPExecX,lTemSepX)
    
	Local nL := 0 
	Local nConta:=0
    //Local nTotItens:=0 
	Local cAuxQUERY
	Local cAuxARQ  
	Local aAuxCAB  
	Local aAuxITENS
	Local aAuxCabLn
	Local nMaxL:=0
	Local lFirst:=.t.
		
	dbSelectArea(cArqCABx)
	dbgotop()

	While ! &(cArqCABx)->(EOF())
		If nConta>nMaxItens.Or.nLinhaX>nMaxLin
			If nPagAtuX==1.Or.lCabAllPg
			   	nLinhaX:=MyCabec(aCabec,aCabItensX,aCabLnX,nPagAtuX)  
			else
				oPrint:StartPage() // Inicia uma nova pagina
				
				MyPagFundo()
				MyCabItens(nLinCab2,aCabItensX,aCabLnX)
				
				nLinhaX:=nLinIni2                                 
				
			end
		   	nConta:=0
		   	nPagAtuX++   
		   	lFirst:=.f.
		END
		IF lFirst
			MyPagFundo()
			MyCabItens(nLinhaX,aCabItensX,aCabLnX)
			nLinhaX+=10
			lFirst:=.f.
		End
		&(cExeItens)

		nConta++
		nMaxL:=nLinhaX
			
		For nL:=1 to Len(aItensX)
			If !empty(aItensX[nL,2])
				cTexto:=&("Transform("+aItensX[nL,1]+","+aItensX[nL,2]+")")
			Else
				cTexto:=&(aItensX[nL,1])   
			End
			
			If aItensX[nL,4] = 0
				aItensX[nL,4]:=99999
			end
				
			nLinAux:=nLinhaX
			While !Empty(cTexto)
				cAuxTexto:=Left(cTexto,aItensX[nL,4])
				cTexto:=Alltrim(Substr(cTexto,aItensX[nL,4]+1))
				oPrint:say (nLinhaX,;
				            aItensX[nL,3],;
				            cAuxTexto,;
				If(Empty(aItensX[nL,6]),&(cFntPadr),&(aItensX[nL,6])))
				nLinhaX+=nPulaLinPr
				nMaxL:=If(nLinhaX>nMaxL,nLinhaX,nMaxL)
				End
			
            nLinhaX:=nLinAux
            nAuxVlrS:=0
				iF valtype(&(aItensX[nL,1]))=='N'
				nAuxVlrS:=&(aItensX[nL,1])
				End
			cVarSoma:="NSOMA"+STRZERO(nL,2)
			&(cVarSoma):=&(cVarSoma)+nAuxVlrS
			Next
		nLinhaX:=nMaxL
		
		cAuxQUERY:='cQryItem'+Str(nProxNiv,1)
		cAuxARQ  :='cArqItem'+Str(nProxNiv,1)
		aAuxCAB  :='aCabItens'+Str(nProxNiv,1)
		aAuxITENS:='aItens'+Str(nProxNiv,1)
		aAuxCabLn:='aCabLine'+Str(nProxNiv,1)
		aAuxRodaP:='aRodaPe'+Str(nProxNiv,1)
		cAuxRodaEx:='cExeRodaP'+Str(nProxNiv,1)
		cAuxTemSep:='lTemSep'+Str(nProxNiv,1)
		
			If !Empty(&(cAuxQUERY))
			//-------------------------------------------------------------------------------------------------------------------
			//faz o ajuste das perguntas dentro da query secundaria
			//-------------------------------------------------------------------------------------------------------------------
			cAuxQItem:=fAjustQry(&(cAuxQUERY))
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cAuxQItem), &(cAuxARQ), .F., .T.) // executa query dos orcamentos
			MEMOWRITE( "\logs\OIWr990_"+Str(nProxNiv,1)+".SQL" ,cAuxQItem ) // grava a query na pasta cprova
		
			nLinhaX:=MyDetails(&(cAuxARQ),&(aAuxITENS),&(aAuxCAB),nProxNiv+1,nLinhaX,&(aAuxCabLn),nPagAtuX,&(aAuxRodaP),&(cAuxRodaEx),&(cAuxTemSep))
			
			dbSelectArea(&(cAuxARQ))
			dbCloseArea()
	
			End

			IF lTemSepX
			oPrint:Line( nLinhaX-7,nColSepI,nLinhaX-7,nColSepF )
			nLinhaX+=2
			End
		
		dbSelectArea(cArqCABx)
		dbskip()
		End
	nLinhaX+=15
	
		For nL:=1 to Len(aItensX)
			iF aItensX[nL,5]
			cVarSoma:="NSOMA"+STRZERO(nL,2)

				If !empty(aItensX[nL,2])
				cTexto:=&("Transform("+cVarSoma+","+aItensX[nL,2]+")")
				Else
				cTexto:=&(cVarSoma)   
				End

			
			oPrint:say (nLinhaX,;
			            aItensX[nL,3],;
			            cTexto,;
				If(Empty(aItensX[nL,6]),&(cFntPadr),&(aItensX[nL,6])))
			
				End
			Next
	
	nLinhaX:=MyRodape(aAuxRPEx,cAuxRPExecX,nLinhaX)

return nLinhaX+5

//-------------------------------------------------------------------------------------------------------
Static Function MyCabec(aCabecX,aCabItensX,aCabLnX,nPag)
//-------------------------------------------------------------------------------------------------------

	Local nL := 0
	Local nK := 0 

	Private _PAGINA:=nPag
	oPrint:StartPage() // Inicia uma nova pagina
	
	MyPagFundo()      

	&(cExecCab)
	//--------------------------------------------------------------------------------------
	//impresao dos dados do cabecalho do relatorio
	//---------------------------------------------------------------------------------------
	For nL:=1 to Len(aCabecX)
		If Empty(&(aCabecX[nL,1]))
			loop
		End
		oPrint:say (aCabecX[nL,2],;
		            aCabecX[nL,3],;
		            &(aCabecX[nL,1]),;
		If(Empty(aCabecX[nL,4]),&(cFntPadr),&(aCabecX[nL,4])) )
		Next

		For nL:=1 to Len(aCabecLn)
		oPrint:Line( aCabecLn[nL,1],aCabecLn[nL,2],aCabecLn[nL,3],aCabecLn[nL,4])
		Next
	
	//--------------------------------------------------------------------------------------
	//impressao do cabec dos itens
	//--------------------------------------------------------------------------------------
	MyCabItens(nLinCab1,aCabItensX,aCabLnX)
	
		For nK:=1 to Len(aCabLogo)
			If aCabLogo[nK,4]<>0
			oPrint:SayBitmap(aCabLogo[nK,2],aCabLogo[nK,3],aCabLogo[nK,1],aCabLogo[nK,4],aCabLogo[nK,5]) //TMSPrinter(): SayBitmap ( [ nRow], [ nCol], [ cBitmap], [ nWidth], [ nHeight], [ uParam6], [ uParam7] ) -->
			else
			oPrint:SayBitmap(aCabLogo[nK,2],aCabLogo[nK,3],aCabLogo[nK,1]) //,248,158) //Linha, Coluna, Largura, Altura
			end
		Next
	
	nLinha:=nLinIni
Return nLinha                

//-------------------------------
Static Function MyPagFundo()
//-------------------------------
	Local nK := 0 
	//--------------------------------------------------------------------------------
	//impressao do fundo
	//--------------------------------------------------------------------------------
	If Len(aArqFundo) > 0 //!Empty(aArqFundo[1,1])
		oPrint:SayBitmap(0001,00002,aArqFundo[1,1],If(aArqFundo[1,2]<>0,aArqFundo[1,2],),If(aArqFundo[1,3]<>0,aArqFundo[1,3],)) //,,.T.) //,nMaxCol,nMaxLin) //,248,158) //Linha, Coluna, Largura, Altura
	End
	//--------------------------------------------------------------------------------
	//impressao dos logotipos
	//--------------------------------------------------------------------------------
	For nK:=1 to Len(aLogo)
		If aLogo[nK,4]<>0
			oPrint:SayBitmap(aLogo[nK,2],aLogo[nK,3],aLogo[nK,1],aLogo[nK,4],aLogo[nK,5]) //TMSPrinter(): SayBitmap ( [ nRow], [ nCol], [ cBitmap], [ nWidth], [ nHeight], [ uParam6], [ uParam7] ) -->
		else
			oPrint:SayBitmap(aLogo[nK,2],aLogo[nK,3],aLogo[nK,1]) //,248,158) //Linha, Coluna, Largura, Altura
		end
	Next

Return



/*/{Protheus.doc} MyCabItens
impressao do cabec dos itens
@author Manuel
@type function
@since 27/04/2021
/*/
Static Function MyCabItens(nQualLinha,aCabItensX,aCabLnX)
	Local nL := 0
	For nL:=1 to Len(aCabItensX)
		oPrint:say (nQualLinha,	aCabItensX[nL,2], &(aCabItensX[nL,1]),	If(Empty(aCabItensX[nL,3]),&(cFntPadr),&(aCabItensX[nL,3])) )
	Next nL
	/*
	For nL:=1 to Len(aCabLnX)
		oPrint:Line( aCabLnX[nL,1],aCabLnX[nL,2],aCabLnX[nL,3],aCabLnX[nL,4])
	Next nL
	*/
return



//-------------------------------------------------------------------------------------------------------
Static Function MyRodape(aRodapeX,cExeRodaX,nLinhaX)
//-------------------------------------------------------------------------------------------------------
	Local nL := 0
	//--------------------------------------------------------------------------------------
	//impresao dos dados do rodape do relatorio
	//---------------------------------------------------------------------------------------
	&(cExeRodaX)

	For nL:=1 to Len(aRodapeX)
		If Empty(&(aRodapeX[nL,1]))
			loop
		End
		oPrint:say (IF(aRodapeX[nL,2]==0,nLinhaX,aRodapeX[nL,2]), 	aRodapeX[nL,3], 	&(aRodapeX[nL,1]),	If(Empty(aRodapeX[nL,4]),&(cFntPadr),&(aRodapeX[nL,4])) )
		nLinhaX+=nPulaLin
	Next


	//--------------------------------------------------------------------------------
	//impressao das paginas iniciais fixas
	//--------------------------------------------------------------------------------
	oPrint:EndPage()
Return nLinhaX

//------------------------------
//contra capa fixa
Static Function MyContraC()
//------------------------------
	Local nPP := 0
	Local nF := 0
	For nPP:=1 to Len(aCCPaginas)
		oPrint:EndPage()
		oPrint:StartPage() // Inicia uma nova pagina

		oPrint:SayBitmap(0001,00002,aCCPaginas[nPP,1],If(aCCPaginas[nPP,2]<>0,aCCPaginas[nPP,2],),If(aCCPaginas[nPP,3]<>0,aCCPaginas[nPP,3],)) //,,.T.) //,nMaxCol,nMaxLin) //,248,158) //Linha, Coluna, Largura, Altura
		For nF:=1 to Len(aTxtCCPag)

			If aTxtCCPag[nF,1]==nPP
				IF Empty(&(aTxtCCPag[nF,2]))
					loop
				End

				oPrint:say (aTxtCCPag[nF,3],;
					aTxtCCPag[nF,4],;
					&(aTxtCCPag[nF,2]),;
					If(Empty(aTxtCCPag[nF,5]),&(cFntPadr),&(aTxtCCPag[nF,5])) )
				End
			Next
		End

		Return

//------------------------------------------------------------------------------------------
Static Function CharToArr(cTexto)
//------------------------------------------------------------------------------------------
	Local aVetor:={}
	Local nPos:=0
	While !Empty(cTexto)
		nPos:=AT(";",cTexto)
		If nPos<>0

			cAux:=Alltrim(Substr(cTexto,1,nPos-1))
			cTexto:=Substr(cTexto,nPos+1)
		Else
			cAux:=Alltrim(cTexto)
			cTexto:=""
		End
		cAux:=StrTran(cAux,chr(09)," ")
		Aadd(aVetor,cAux)
	End
Return aVetor

//---------------------------------------------------------------------------------------------------------------------
Static Function MySendMail(cTo,cCC,cOculto,cSubj,cMens,cAnexo)
//------------------------------------------------------------------------------------------------------------------

	Local oServer
	Local oMessage
	//Local nNumMsg := 0
	//Local nTam    := 0
	//Local nI      := 0

	cAccount	:= alltrim(GetMv("MV_RELACNT"))
	cPassword 	:= alltrim(GetMv("MV_RELPSW"))
	cFrom     	:= alltrim( GetMv("MV_RELFROM"))
	cServer		:= alltrim(GetMV("MV_RELSERV" ))
	lAuth	    := Getmv("MV_RELAUTH")
	lTls        := Getmv("MV_RELTLS")

	//Cria a conex„o com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()
	oServer:SetUseTLS( lTls )
	oServer:Init( "", cServer, cAccount, cPassword, 0, 587 )

	//seta um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 120 ) != 0
		Alert( "Falha ao setar o time out" )
		Return .F.
	EndIf

	//realiza a conex„o SMTP
	nRet:=oServer:SmtpConnect()

	If nRet != 0
		Alert( "Falha ao conectar " + oServer:GetErrorString( nRet ) )
		Return .F.
	EndIf

	nRet := oServer:SMTPAuth( cAccount, cPassword )

	IF nRet <> 0
		alert('n„o consegui autenticar' + oServer:GetErrorString( nRet ))
		return .f.
	end

	//Apos a conex„o, cria o objeto da mensagem
	oMessage := TMailMessage():New()

	//Limpa o objeto
	oMessage:Clear()

	//Popula com os dados de envio
	oMessage:cFrom              := cFrom
	oMessage:cTo                := cTo //"microsiga@microsiga.com.br;microsiga@microsiga.com.br"
	oMessage:cCc                := cCc //microsiga@microsiga.com.br"
	oMessage:cBcc               := cOculto //microsiga@microsiga.com.br"
	oMessage:cSubject           := cSubj
	oMessage:cBody              := cMens
	//oMessage:cReplyTo 		  := usrretmail(retcodusr())//SA3->A3_EMAIL

	//Adiciona um attach
	If oMessage:AttachFile( cAnexo ) < 0
		Conout( "Erro ao atachar o arquivo" )
		Return .F.
	Else
		//adiciona uma tag informando que È um attach e o nome do arq
		oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo)
	EndIf

	//Envia o e-mail
	xRet:=oMessage:Send( oServer )
	If xRet<>0
		cMsg := oServer:GetErrorString( xRet )
		Alert( "Erro ao enviar o e-mail"+cMsg )
		conout( cMsg )
		Return .F.
	EndIf

	//Desconecta do servidor
	If oServer:SmtpDisconnect() != 0
		Alert( "Erro ao disconectar do servidor SMTP" )
		Return .F.
	EndIf

//-------------------------------------------------------  
Static Function MyPrePag()
	Local nPP := 0
	Local nF := 0
	//--------------------------------------------------------------------------------
	//impressao das paginas iniciais fixas
	//--------------------------------------------------------------------------------
	For nPP:=1 to Len(aPrePaginas)
		oPrint:StartPage() // Inicia uma nova pagina
		oPrint:SayBitmap(0001,00002,aPrePaginas[nPP,1],If(aPrePaginas[nPP,2]<>0,aPrePaginas[nPP,2],),If(aPrePaginas[nPP,3]<>0,aPrePaginas[nPP,3],)) //,,.T.) //,nMaxCol,nMaxLin) //,248,158) //Linha, Coluna, Largura, Altura
		For nF:=1 to Len(aTxtPrePag)

			If aTxtPrePag[nF,1]==nPP
				If Empty(&(aTxtPrePag[nF,2]))
					loop
				end
				oPrint:say (aTxtPrePag[nF,3],	aTxtPrePag[nF,4],	&(aTxtPrePag[nF,2]),	If(Empty(aTxtPrePag[nF,5]),&(cFntPadr),&(aTxtPrePag[nF,5])) )
			End
		Next
		oPrint:EndPage()
		//oPrint:StartPage() // Inicia uma nova pagina
	End
Return


/*
//----------------------------------------------------------------------
Static Function CreateObj(cObj,cQry,nAcao )
//----------------------------------------------------------------------

   //	Local cTabela := RetSQLName(cTab)
	Local cQuery  := ""
	Local cSQL    := ""
	Local cAliasT := ""
	Local cMsg    := ""
	

	cAliasT := GetNextAlias()
	cQuery := " SELECT COUNT(*) QUANTOS FROM sysobjects WHERE name='"+cObj+"' AND xtype = 'V'"

	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->QUANTOS == 0
		
		cSQL := STRTRAN(cQry,"ALTER VIEW","CREATE VIEW")
		cMsg := "View "+ cObj +" CRIADA."

	Else
		IF nAcao=2 //1 criar 2 alterar 3 dropar
			cSQL := STRTRAN(cQry,"CREATE VIEW","ALTER VIEW")
			cMsg := "View "+ cObj +" ALTERADA." 
		End
			
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	If ( TCSQLExec( cSQL ) < 0 )
	    
	    cMsg := "TCSQLError() " + TCSQLError()
		
	EndIf
	
Return( cMsg + CRLF + CRLF )
*/


