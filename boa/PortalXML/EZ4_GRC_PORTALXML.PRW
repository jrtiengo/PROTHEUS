/* =====================================================================================================================================
// Programa   EZ4 GRC  | Autor  Renato L. Pego      | Data    05/2017
// =====================================================================================================================================
// Desc.     | Programa de controle de NF Recebidas 
// =====================================================================================================================================
// MELHORIAS APLICADAS
// =====================================================================================================================================
//   DATA  | ANALISTA			| CORRECAO
// =====================================================================================================================================
// 03/05/19| MARCIO MARTINS		| Funcao: ProcTxt() -> EZ0_DOC := SubStr(cCHVNFE,26,09)	- Corrigido posicao de 27 para 26
// =====================================================================================================================================
*/
//*=====================================================================================================================================*/
// INCLUDES
//*=====================================================================================================================================*/
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "SPEDNFE.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "RPTDEF.CH" 
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "fivewin.ch"
#include "xmlxfun.ch"
#include 'parmtype.ch'
/*=====================================================================================================================================*/
// Defines
/*=====================================================================================================================================*/
#DEFINE ENTER CHR(13)+CHR(10)
#xTranslate Tp(<cCmp>) => AVSX3(<cCmp>,2) // tipo
#xTranslate Tm(<cCmp>) => AVSX3(<cCmp>,3) // tamanho
#xTranslate Dc(<cCmp>) => AVSX3(<cCmp>,4) // decimais
#xTranslate Tt(<cCmp>) => AVSX3(<cCmp>,5) // Titulo
#xTranslate Pc(<cCmp>) => AVSX3(<cCmp>,6) // picture
 
Static lLGPD  	:= FindFunction("SuprLGPD") .And. SuprLGPD()
/*=====================================================================================================================================*/
// Funcao principal do modulo chamada a partir do Menu.
/*=====================================================================================================================================*/
User Function Portal_XML()

   Local   bImagem    := {|| if(EZ0->EZ0_MARK =cMark, "LBOK","LBNO" ) }
   Private Raiz       := 0                                    // Indica que a tela inicial esta ativa
   Private cArquivo   := SuperGetMV("EZ_PX_UAR",.F.,"C:\TEMP")
   Private oMark      := FWMBrowse():New()                // Instanciamento da Classe de Browse
   Private cMark      := ''
   Private lAtivaSai  := SuperGetMV("EZ_PX_NFS" ,.F.,.F.)   // NFSAIDA-2020
   Private lUsaPort   := SuperGetMV("EZ_USAPORT",.F.,.F.)   // USA MoDULO DE PORTARIA
   Private lIntGFE    := SuperGetMV("MV_INTGFE" ,.F.,.F.)    // SE ATIVADO, NaO PROCESSA ENTRADA DO CTE, FICA A CARGO DO GFE, COPIA-SE O XML PARA MV_XMLDIR
   Private lUsaPref   := SuperGetMV("EZ_USAPREF",.F.,.T.)   // USA PREFEITURA
   Private lUsaWFInt  := SuperGetMV("EZ_USAWFIN",.F.,.T.)   // USA WORKFLOW INTERNO POR GRUPO EZ8
   Private lUsaWFExt  := SuperGetMV("EZ_USAWFEX",.F.,.F.)   // USA WORKFLOW EXTERNO PARA INFORMAR FORNECEDORES
   Private cCFOPNPC   := SuperGetMV("EZ_CFOPNPC",.F.,"")    // CFOP Nao usa Pedido de Compras
   Private lPRODPC    := SuperGetMV("EZ_PRODPC" ,.F.,.F.)    // Usa o Produto do SC7
   Private cCFOP      := SuperGetMV("EZ_CFGERNF",.F.,"")    // CFOP�s que irao gerar pre-nota e nao passam pela portaria
   Private nVersion   := SuperGetMV("EZ_VERSION",.F.,0)    // Versao que esta sendo utilizada
   Private _lPreNota  := SuperGetMV("EZ_PRENOTA",.F.,.T.)    // Versao que esta sendo utilizada
   Private lAtivaMan  := SuperGetMV("EZ_ATVMAN",.F.,.F.)    // Ativa o Manifesto para recusar documentos
   Private lDblCheck  := SuperGetMV("EZ_DBCHECK",.F.,.F.)    // Double Check na SEFAZ nas rotinas ALMOX e PORTARIA
   Private lUsaAS400  := SupergetMV("EZ_USAS400",.F.,.F.)   // Defini se usa XML Modelo AS400 - Carla Barbosa - 01.10.2025

   
   
   Private lUsaOCR    := SuperGetMV("EZ_USAOCR",.F.,.T.)   
   Private lUsoEZ4    := SuperGetMV("EZ_USOEZ4",.F.,.F.)   
   Private infPrw     := {}
   Private cKeyEz4   := ""
   /*=====================================================================================================================================*/
   // Controle de Licenciamento EZ4
   /*=====================================================================================================================================*/
   If !SuperGetMV("EZ_DEMO",.F.,.F.)  // cEmpAnt <> "99"  .AND. !SuperGetMV("EZ_DEMO",.F.,.F.) 
      If nVersion == 0  
         If !EZSERVER(SM0->M0_CGC, "010010001")    // CNPJ + PRODUTO 
            Return  
         Endif 
      Else 
         // Licenca condecida para todos os CNPJ�s - RETIRAR ESTAS LINHAS
         // CARLA BARBOSA - 31 01 2023
         If SubStr(SM0->M0_CGC,1,8) <> '33174335' 
            MsgAlert("Voce Nao tem Permissao de Uso!")
            Return 
         Endif
     Endif
   Endif 
   
   /*=====================================================================================================================================*/
   // Atualizacao de Status
   /*=====================================================================================================================================*/
   If SuperGetMV("EZ_PX_INI",.f.,"NUNCA") == "NUNCA"
      MsgRun("Aguarde atualizacao de dicionario","Processando",{|| U_EZPxmlAtuaDic()  })
   Endif

   dbSelectArea("EZ0")
   
   cMark := GetMark( .f.,'EZ0','EZ0_MARK')

   // Funcionalidades do Modulo de Portaria
   If lUsaPort

      // Avalio os registros corrigidos pelo MONITERROS.prw
      Processa({|lEnd| ExecEZ2() },"Processando","Atualizando....",.F.)      

   Endif    
      // Forco a criacao de campos do dicionario
   If EZ0->(FieldPos("EZ0_XMLOK"))  == 0 .Or. EZ2->(FieldPos("EZ2_NUMNFE")) == 0 .Or. EZ0->(FieldPos("EZ0_ULTNSU")) == 0 .Or. ;
      EZ1->(FieldPos("EZ1_DESCRI")) == 0 .Or. EZ1->(FieldPos("EZ1_BRICMS")) == 0   
      MsgRun("Aguarde atualizacao de dicionario","Processando",{|| U_EZPxmlAtuaDic()  })
   Endif

 
   infPrw := InfoFonte()

   oMark:SetMenuDef('EZ4_GRC_PORTALXML')    // ARQUIVO FONTE ONDE ESTA A MENUDEF
   oMark:SetDescription('EZ4 GRC '+infPrw)   // Titulo da Browse
   oMark:SetAlias('EZ0')                    // Definicao da tabela do Browse
   //Cria uma coluna de marca/desmarca
   oMark:AddMarkColumns( bImagem , {|oBr| PXMcIt()} ,{|oBr| PXMcAll(self)} )
   // Definicao da legenda
   // https://terminaldeinformacao.com/knowledgebase/brwlegenda/
   //If !lUsaPort
      oMark:AddLegend( "EZ0_STINTE=='0'", "BR_BRANCO"  , "Nao Processado" )
   //Endif 
   oMark:AddLegend( "EZ0_STINTE=='1'", "BR_VERDE"   , "Documento Gerado" )
   oMark:AddLegend( "EZ0_STINTE=='2'", "BR_VERMELHO", "Inconsistente" )
   oMark:AddLegend( "EZ0_STINTE=='3'", "BR_AMARELO" , "XML Nao Disponivel" )
   oMark:AddLegend( "EZ0_STINTE=='9'", "BR_CANCEL"  , "Chave Rejeitada" )  
   oMark:AddLegend( "EZ0_STINTE=='Y'", "BR_PRETO_3" , "Pendente Cancelamento" ) 
   oMark:AddLegend( "EZ0_STINTE=='Z'", "BR_CANCEL"  , "XML Cancelado - Sefaz" )
   If lUsaPort
      oMark:AddLegend( "EZ0_STINTE=='4'", "BR_AZUL"    , "Portaria" )
      oMark:AddLegend( "EZ0_STINTE=='6'", "BR_PINK"    , "Recebimento Fisico" )
      oMark:AddLegend( "EZ0_STINTE=='7'", "BR_PRETO"   , "Aguardando Classificacao" )      
      oMark:AddLegend( "EZ0_STINTE=='A'", "BR_VIOLETA" , "Doc.Entrada Manual" )          
      If lIntGFE
         oMark:AddLegend( "EZ0_STINTE=='8'", "BR_CINZA"   , "CT-e Copiado" )      
      Endif 
   Else 
      oMark:AddLegend( "EZ0_STINTE=='7'", "BR_PRETO"   , "Aguardando Classificacao" )      
      oMark:AddLegend( "EZ0_STINTE=='4'", "BR_AZUL"    , "XML Disponivel" )
      oMark:AddLegend( "EZ0_STINTE=='A'", "BR_VIOLETA" , "Doc.Aguard.Aprovacao" )          
   Endif 
   oMark:AddLegend( "EZ0_STINTE=='5'", "BR_LARANJA"    , "Nota Classificada" )

   //filtra registros no ponto de gerar a pre nota
   oMark:AddFilter( "Processamento Nao finalizado", "EZ0_STINTE<>'1' .AND. EZ0_STINTE <> '3' .AND. EZ0_STINTE<>'5' ", .f.,.t.)

   // Ativacao da Classe
   oMark:Activate()

   // limpa as marcacoes ao sair
   TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_MARK = '"+cMark+"'")  //limpa as marcacoes ao Sair.

Return NIL

/*=====================================================================================================================================*/
// marcacao de itens da tela.
/*=====================================================================================================================================*/
Static Function PXMcIt()

	EZ0->( RecLock('EZ0',.f.))
	EZ0->EZ0_MARK := if(EZ0->EZ0_MARK =cMark, "",cMark)
	EZ0->(msUnlock())

Return

/*=====================================================================================================================================*/
// marcacao de todos os itens da tela.
/*=====================================================================================================================================*/
Static Function PXMcAll(oMarkBr)

   local marka := if(EZ0->EZ0_MARK =cMark, "",cMark)
   local oFilter := oMarkBr:FWFilter() // busca filtros
   local cWhere := "", i := 0

   // Verifica filtors ativosadminadminadmin
   for i:= 1 to len(oFilter:aCheckFil)
      if oFilter:aCheckFil[i] // se esta ativo
         if empty(oFilter:aFilter[i,3])
            cWhere+= "("+oFilter:aFilter[i,2]+")"
         else
            cWhere+= "("+oFilter:aFilter[i,3]+")"
         endif
      endif
   next

   cWhere := StrTran(cWhere, ")(",") and (")
   cWhere := StrTran(cWhere, ".AND.","and")
   cWhere := StrTran(cWhere, ".OR.","or")
   cWhere := StrTran(cWhere, "==","=")
   cWhere := if(len(cWhere)>0," where "+cWhere,"")

   TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '"+marka+"'"+cWhere ) //" where "+oFilter:GetExprSQL() )
   EZ0->(dbGoTop())
   oMarkBr:Refresh()
   
return

/*=====================================================================================================================================*/
// Funcao para a definicao das opcoes.   -- Esta funcao e obrigatoria
/*=====================================================================================================================================*/
Static Function MenuDef()

   //Local aRotina := {}, aAux := {}
   Local aAux := {}
   Local aAuxOCR := {}
   Local cUserADM := SuperGetMV("EZ_PX_ADM",.f.,"ALL")
   Local lAtivaSai  := SuperGetMV("EZ_PX_NFS" ,.F.,.F.)   // NFSAIDA-2020
   Local lUsaPort   := SuperGetMV("EZ_USAPORT",.F.,.F.)   // USA MoDULO DE PORTARIA
   Local lUsaPref   := SuperGetMV("EZ_USAPREF",.F.,.T.)   // USA PREFEITURA
   Local lIntGFE    := SuperGetMV("MV_INTGFE" ,.F.,.F.)    // SE ATIVADO, NaO PROCESSA ENTRADA DO CTE, FICA A CARGO DO GFE, COPIA-SE O XML PARA MV_XMLDIR
   Local lUsaOcr    := SuperGetMV("EZ_USAOCR",.F.,.T.)   
   Local lUsoEZ4    := SuperGetMV("EZ_USOEZ4",.F.,.F.) 
   Local nMM        := 0 
   Local aRotina := {}

   IF type('Raiz')<>'N'
      Raiz:= 0
   endif       // Indica que a tela inicial esta ou Nao ativa

   do case

      case Raiz = 0       // Menu da tela principal

         aAdd( aRotina, {'Buscar Notas'  , 'U_BUSCADOCS()'  , 0, 3, 0, NIL } )
         //aAdd( aRotina, {'NFS-e por PDF' , 'U_SelFileOCR()'  , 0, 3, 0, NIL } )
         
         // aAux := 'MsgRun("Aguarde","Processando",{|| u_Gera_PRNF(1)   })' 
         
         aAdd( aAux   , {'NF Entrada'  , 'MsgRun("Aguarde","Processando",{|| u_Gera_PRNF(1)   })'  , 0, 4, 0, NIL } )
         // Marcio Martins - 07/03/2022
         aAdd( aAux   , {'Entr.Conhec.Frete', 'MsgRun("Aguarde","Processando",{|| u_Gera_PRNF(3)   })'  , 0, 4, 0, NIL } )
         If lAtivaSai
            aAdd( aAux   , {'NF Saida'    , 'MsgRun("Aguarde","Processando",{|| u_Gera_PRNF(2)   })'  , 0, 4, 0, NIL } )
         Endif 
         /* O CERTO NAO E AQUI E SIM NO BUSCA NOTAS
         If lUsaOCR
            aAdd( aAux   , {'NFS-e por PDF'    , 'MsgRun("Aguarde","Processando",{|| U_OCRSelFile(.T.)   })'  , 0, 4, 0, NIL } )
         Endif 
         */
         aAdd( aRotina, {'Gerar Notas', aAux , 0, 3, 0, NIL } )

         //=====================================================================
         //=====================================================================
         aAdd( aRotina, {'Exportar Origem' , 'MsgRun("Aguarde","Processando",{|| u_PxmlBaixaXML()})'  , 0, 6, 0, NIL } )
         If lUsaPref
            aAdd( aRotina, {'Visualiza NFS'   , 'MsgRun("Aguarde","Processando",{|| u_PxmVisNFSEL()})'   , 0, 6, 0, NIL } )
         Endif
         aAdd( aRotina, {'Excluir Origem'  , 'MsgRun("Aguarde","Processando",{|| u_PxmlExcXML()})'    , 0, 6, 0, NIL } )
         aAdd( aRotina, {'Cancelamento'    , 'MsgRun("Aguarde","Processando",{|| u_PxmlCancXML()})'    , 0, 6, 0, NIL } )
         aAdd( aRotina, {'Busca NSU Especifico'  , 'MsgRun("Aguarde","Processando",{|| u_MnuProcNSU()})'    , 0, 3, 0, NIL } )
         
         aAdd( aRotina, {'Classificar Nota', 'u_PxmClassNota()'    , 0, 6, 0, NIL } )
         aAux := {}
         aAdd( aAux   , {'Impressao Nota' , 'MsgRun("Aguarde","Processando",{|| U_GRC_IMPDANFE()   })'  , 0, 4, 0, NIL } )
         aAdd( aAux   , {'Relat�rio Log NSU' , 'MsgRun("Aguarde","Processando",{|| U_EZ4_RELLOG()   })'  , 0, 4, 0, NIL } )
         aAdd( aAux   , {'Relat�rio Inconsistencias' , 'MsgRun("Aguarde","Processando",{|| U_EZ4_RELINC()   })'  , 0, 4, 0, NIL } )
         aAdd( aAux   , {'Relacao Notas Portal GRC'  , 'MsgRun("Aguarde","Processando",{|| U_EZMRXMLS()   })'  , 0, 4, 0, NIL } )
         //If SubStr(SM0->M0_CGC,1,8) == '33174335'  // crown
            aAdd( aAux   , {'Analise de Documentos Recebidos' , 'MsgRun("Aguarde","Processando",{|| U_RPXML01()   })'  , 0, 4, 0, NIL } )
            aAdd( aAux   , {'Planilha de Analise de Dados do XML' , 'MsgRun("Aguarde","Processando",{|| U_RPXML02()   })'  , 0, 4, 0, NIL } )
         //Endif
         If lUsaOCR
            aAdd( aAux   , {'Visualiza PDF' , 'MsgRun("Aguarde","Processando",{|| U_GRC_NPDF()   })'  , 0, 4, 0, NIL } )
         Endif
         If lAtivaSai
            aAdd( aAux   , {'NF Saida'   , 'MsgRun("Aguarde","Processando",{|| u_Gera_PRNF(2)   })'  , 0, 4, 0, NIL } )
         Endif 
         //aAdd( aRotina, {'Checa SEFAZ','MsgRun("Aguarde","Processando",{|| U_CheckSefaz()})'   , 0, 6, 0, NIL } )
         If lUsaPort
            If lIntGFE
               aAdd( aRotina, {'Copia CT-e','MsgRun("Aguarde","Processando",{|| u_CTECopy()})'   , 0, 6, 0, NIL } )
            Endif 
            aAdd( aRotina, {'Recusa Operacao','U_RecusaOper()'   , 0, 6, 0, NIL } )
            aAdd( aRotina, {'Consulta Log','MsgRun("Aguarde","Processando",{|| u_PxmVisLog()})'   , 0, 6, 0, NIL } )
            aAdd( aRotina, {'Forca Liberacao SEFAZ','MsgRun("Aguarde","Processando",{|| U_LibSefaz()})'   , 0, 6, 0, NIL } )
         Endif 
         aAdd( aRotina, {'Impressoes', aAux , 0, 3, 0, NIL } )

         // rotinas de configuracao so serao exibidas para usuarios pre definidos
         if cUserADM == "ALL" .or. __cUserId $ cUserADM
            aAux := {}
            aAdd( aAux, {'Config. TAG x Cpo'   , 'MsgRun("Aguarde","Processando",{|| u_ConfTagCpo() })' , 0, 3, 0, NIL } )
            aAdd( aAux, {'Config. Validacoes'  , 'MsgRun("Aguarde","Processando",{|| u_ConfValid()  })' , 0, 3, 0, NIL } )
            aAdd( aAux, {'Parametros'          , 'MsgRun("Aguarde","Processando",{|| u_ConfParam()  })' , 0, 3, 0, NIL } )
            aAdd( aAux, {'Carga Basica EZ3/EZ4', 'MsgRun("Aguarde  ","Processando",{|| U_EZPXMLCGBAS() })'  , 0, 3, 0, NIL } )
            If lUsoEZ4
               aAdd( aAux, {'OCR - Config. Captura'   , 'MsgRun("Aguarde","Processando",{|| u_ConfOCR() })' , 0, 3, 0, NIL } )
            Endif 
            If lUsaOCR
               aAuxOCR := {}
               aAdd( aAuxOCR, {'Importar' , 'MsgRun("Aguarde","Processando",{|| U_GRCIMPORT()   })'  , 0, 4, 0, NIL } )
               aAdd( aAuxOCR, {'Exportar' , 'MsgRun("Aguarde","Processando",{|| U_GRCEXPORT()   })'  , 0, 4, 0, NIL } )
               aAdd( aAux, {'OCR - Configura��es', aAuxOCR , 0, 3, 0, NIL } )
            Endif
            If lUsaPref
               aAdd( aAux, {'Carga Bas.Prefeitura', 'MsgRun("Aguarde","Processando",{|| U_CGBASENFSE() })' , 0, 3, 0, NIL } )
               aAdd( aAux, {'Layouts Prefeitura'  , 'MsgRun("Aguarde","Processando",{|| U_ConfLayout() })' , 0, 3, 0, NIL } )            
            Endif 
            aAdd( aAux, {'Ajusta Dicionarios', 'MsgRun("Aguarde atualizacao de dicionario","Processando",{|| U_EZPxmlAtuaDic()})'  , 0, 3, 0, NIL } )
            aAdd( aRotina, {'Configuracoes', aAux , 0, 3, 0, NIL } )
            //aAdd( aRotina, {'TESTE WFCancXML'  , 'MsgRun("Aguarde","Processando",{|| WFCancXML(EZ0->EZ0_CHVNFE,"","") })'    , 0, 3, 0, NIL } )
         endif
         
         If ExistBlock("PXML_MNU")
            aAux:= {}
            aAuxRet := {}
            aAuxRet := ExecBlock("PXML_MNU",.f.,.f.,"Tela Principal")
            If ValType(aAuxRet) == "A" .And. Len(aAuxRet)> 0
               For nMM := 1 to Len(aAuxRet)
                  AAdd(aAux,aAuxRet[nMM])
               Next nMM
               If Len(aAux) > 0 
                  aAdd( aRotina, {'Especificos', aAux , 0, 3, 0, NIL } )
               Endif 
            EndIf           
         EndIf
         
      case Raiz = 1  // tag x campo

         aAdd(aRotina,{ "Visualizar", "u_ManutEZ4(1)", 0, 2, 0, NIL } ) // 1 - Visualizacao
         aAdd(aRotina,{ "Incluir"   , "u_ManutEZ4(3)", 0, 3, 0, NIL } ) // 3 - Insercao
         aAdd(aRotina,{ "Alterar"   , "u_ManutEZ4(4)", 0, 4, 0, NIL } ) // 4 - Atualizacao
         aAdd(aRotina,{ "Excluir"   , "u_ManutEZ4(5)", 0, 5, 0, NIL } ) // 5 - Exclusao
         If ExistBlock("PXML_MNU")
            aAux := ExecBlock("PXML_MNU",.f.,.f.,"TAG X CPO")
            If ValType(aAux) == "A" 
               AEval(aAux,{|x| AAdd(aRotina,x)})
            EndIf           
         EndIf

      case Raiz = 2 // validacoes
   
         aAdd(aRotina,{ "Visualizar", "u_ManutEZ3(1)", 0, 2, 0, NIL } ) // 1 - Visualizacao
         aAdd(aRotina,{ "Incluir"   , "u_ManutEZ3(3)", 0, 3, 0, NIL } ) // 3 - Insercao
         aAdd(aRotina,{ "Alterar"   , "u_ManutEZ3(4)", 0, 4, 0, NIL } ) // 4 - Atualizacao
         aAdd(aRotina,{ "Excluir"   , "u_ManutEZ3(5)", 0, 5, 0, NIL } ) // 5 - Exclusao
         If ExistBlock("PXML_MNU")
            aAux := ExecBlock("PXML_MNU",.f.,.f.,"VALIDACOES")
            If ValType(aAux) == "A"
               AEval(aAux,{|x| AAdd(aRotina,x)})
            EndIf           
         EndIf

      case Raiz = 3 // itens da nota

         aAdd(aRotina,{ "Visualizar", "u_ManutEZ1(1)", 0, 2, 0, NIL } ) // 1 - Visualizacao
         aAdd(aRotina,{ "Incluir"   , "u_ManutEZ1(3)", 0, 3, 0, NIL } ) // 3 - Insercao
         aAdd(aRotina,{ "Alterar"   , "u_ManutEZ1(4)", 0, 4, 0, NIL } ) // 4 - Atualizacao
         aAdd(aRotina,{ "Excluir"   , "u_ManutEZ1(5)", 0, 5, 0, NIL } ) // 5 - Exclusao
         If ExistBlock("PXML_MNU")
            aAux := ExecBlock("PXML_MNU",.f.,.f.,"ITENS NF")
            If ValType(aAux) == "A"
               AEval(aAux,{|x| AAdd(aRotina,x)})
            EndIf           
         EndIf

      case Raiz = 4  // Cadastro Layout Prefeituras

         aAdd(aRotina,{ "Visualizar", "u_ManutEZ5(1)", 0, 2, 0, NIL } ) // 1 - Visualizacao
         aAdd(aRotina,{ "Incluir"   , "u_ManutEZ5(3)", 0, 3, 0, NIL } ) // 3 - Insercao
         aAdd(aRotina,{ "Alterar"   , "u_ManutEZ5(4)", 0, 4, 0, NIL } ) // 4 - Atualizacao
         aAdd(aRotina,{ "Excluir"   , "u_ManutEZ5(5)", 0, 5, 0, NIL } ) // 5 - Exclusao

      case Raiz = 5  // Cadastro Configura��o OCR

         aAdd(aRotina,{ "Visualizar", "u_ManutEZ9(1)", 0, 2, 0, NIL } ) // 1 - Visualizacao
         aAdd(aRotina,{ "Incluir"   , "u_ManutEZ9(3)", 0, 3, 0, NIL } ) // 3 - Insercao
         aAdd(aRotina,{ "Alterar"   , "u_ManutEZ9(4)", 0, 4, 0, NIL } ) // 4 - Atualizacao
         aAdd(aRotina,{ "Excluir"   , "u_ManutEZ9(5)", 0, 5, 0, NIL } ) // 5 - Exclusao
         aAdd(aRotina,{ "Copia"     , "u_EZ9Copia(6)", 0, 6, 0, NIL } ) // 5 - Copia
         aAdd(aRotina,{ "Exc.Modelo", "u_EZ9Delet(5)", 0, 6, 0, NIL } ) // 5 - Exclui o Modelo  
         aAdd(aRotina,{ "Vld OCR"   , "u_VldConfOcr()", 0, 6, 0, NIL } ) // 5 - Valida o OCR  


      case Raiz = 9  // ROTINA GeraNF -- Browse Principal

         aAdd( aRotina, {"Confirma" ,"u_FechaDlg(.T.,aChaves)",0,3, 0, NIL } )
         aAdd( aRotina, {"Cancela"  ,"u_FechaDlg(.F.)",0,3, 0, NIL } )

         If ExistBlock("PXML_MNU")
               aAux := ExecBlock("PXML_MNU",.f.,.f.,"GERA NF")
            If ValType(aAux) == "A"
               AEval(aAux,{|x| AAdd(aRotina,x)})
            EndIf           
         EndIf
 
      
   endCase

Return aRotina

/*=====================================================================================================================================*/
// Manutencao na EZ0
/*=====================================================================================================================================*/
User Function ManutEZ0(nOper)

   Local aOper:={'Visualizacao','','Insercao','Atualizacao','Exclusao','Copia'}
   Local oModel := MPFormModel():New('MODELEZ0')
   Local oView  := FWFormView():New()
   Local oExView := FWViewExec():New()
   Local oStrMD := FWFormStruct(1,'EZ0')
   Local oStrVW := FWFormStruct(2, 'EZ0')

   // Criacao do model
   oModel:SetDescription('Cabecario da Nota')
   oModel:addFields('EZ0MASTER',,oStrMD )   //,{|oModel,cAcao,cCampo,xValor,x,w|bPre(oModel,cAcao,cCampo,xValor,x,w)},{|oModelField| bPOS(oModelField) })
   oModel:getModel('EZ0MASTER'):SetDescription('Detalhes')
   oModel:SetPrimaryKey({'EZ0_FILIAL','EZ0_CHVNFE'})

   // Criacao da VW
   oView:SetModel(oModel)
   oView:AddField('VIEWEZ0' ,oStrVW, 'EZ0MASTER' )
   oView:CreateHorizontalBox( 'TELA', 100)
   oView:SetOwnerView('VIEWEZ0','TELA')
   oView:SetCloseOnOk({||.T.})
   oView:showUpdateMsg(.F.)

   bBlocoMagic := {|oView| U_GRC_NPDF()}
   oView:AddUserButton("Visualiza PDF","MAGIC_BMP",bBlocoMagic,"Abre o arquivo PDF do Documento")

   // exibicao da tela
   oExView:setTitle('Cabecario da Nota - '+aOper[nOper])
   oExView:setView( oView )
   oExView:setModal(.t.)
   oExView:setOperation(nOper)
   oExView:setReduction(10)
   oExView:openView(.T.)

Return

/*=====================================================================================================================================*/
// Manutencao EZ1
/*=====================================================================================================================================*/
User Function ManutEZ1(nOper)

   Local aOper:={'Visualizacao','','Insercao','Atualizacao','Exclusao','Copia'}
   Local oModel := MPFormModel():New('MODELEZ1')
   Local oView  := FWFormView():New()
   Local oExView := FWViewExec():New()
   Local oStrMD := FWFormStruct(1,'EZ1')
   Local oStrVW := FWFormStruct(2, 'EZ1')

   Private cChaveBusca := EZ1->(EZ1_FILIAL+EZ1_CHVNFE+EZ1_ITEM)

   // Criacao do model
   oModel:SetDescription('Item da Nota')
   oModel:addFields('EZ1MASTER',,oStrMD )   //,{|oModel,cAcao,cCampo,xValor,x,w|bPre(oModel,cAcao,cCampo,xValor,x,w)},{|oModelField| bPOS(oModelField) })
   oModel:getModel('EZ1MASTER'):SetDescription('Detalhes')
   oModel:SetPrimaryKey({'EZ1_FILIAL','EZ1_CHVNFE'})

   // Criacao da VW
   oView:SetModel(oModel)
   oView:AddField('VIEWEZ1' ,oStrVW, 'EZ1MASTER' )
   oView:CreateHorizontalBox( 'TELA', 100)
   oView:SetOwnerView('VIEWEZ1','TELA')
   oView:SetCloseOnOk({||.T.})
   oView:showUpdateMsg(.F.)

   // exibicao da tela
   oExView:setTitle('Item da NF - '+aOper[nOper])
   oExView:setView( oView )
   oExView:setModal(.t.)
   oExView:setOperation(nOper)
   oExView:setReduction(10)
   oExView:openView(.T.)

Return

/*=====================================================================================================================================*/
// Manutencao EZ3
/*=====================================================================================================================================*/
User Function ManutEZ3(nOper)

   Local aOper:={'Visualizacao','','Insercao','Atualizacao','Exclusao','Copia'}
   Local oModel := MPFormModel():New('MODELEZ3')
   Local oView  := FWFormView():New()
   Local oExView := FWViewExec():New()
   Local oStrMD := FWFormStruct(1,'EZ3')
   Local oStrVW := FWFormStruct(2, 'EZ3')

   // Criacao do model
   oModel:SetDescription('Validacao')
   oModel:addFields('EZ3MASTER',,oStrMD )   //,{|oModel,cAcao,cCampo,xValor,x,w|bPre(oModel,cAcao,cCampo,xValor,x,w)},{|oModelField| bPOS(oModelField) })
   oModel:getModel('EZ3MASTER'):SetDescription('Detalhes')
   oModel:SetPrimaryKey({'EZ3_FILIAL','EZ3_TIPONF','EZ3_ORDEM'})

   // Criacao da VW
   oView:SetModel(oModel)
   oView:AddField('VIEWEZ3' ,oStrVW, 'EZ3MASTER' )
   oView:CreateHorizontalBox( 'TELA', 100)
   oView:SetOwnerView('VIEWEZ3','TELA')
   oView:SetCloseOnOk({||.T.})
   oView:showUpdateMsg(.F.)

   // exibicao da tela
   oExView:setTitle('Validacao - '+aOper[nOper])
   oExView:setView( oView )
   oExView:setModal(.t.)
   oExView:setOperation(nOper)
   oExView:setReduction(10)
   oExView:openView(.T.)

Return

/*=====================================================================================================================================*/
// Manutencao EZ4
/*=============================================
========================================================================================*/
User Function ManutEZ4(nOper)

   Local aOper:={'Visualizacao','','Insercao','Atualizacao','Exclusao','Copia'}
   Local oModel := MPFormModel():New('MODELEZ4')
   Local oView  := FWFormView():New()
   Local oExView := FWViewExec():New()
   Local oStrMD := FWFormStruct(1,'EZ4')
   Local oStrVW := FWFormStruct(2, 'EZ4')

   // Criacao do model
   oModel:SetDescription('Tag x Campo')
   oModel:addFields('EZ4MASTER',,oStrMD )   //,{|oModel,cAcao,cCampo,xValor,x,w|bPre(oModel,cAcao,cCampo,xValor,x,w)},{|oModelField| bPOS(oModelField) })
   oModel:getModel('EZ4MASTER'):SetDescription('Detalhes')
   oModel:SetPrimaryKey({'EZ4_FILIAL','EZ4_TIPONF','EZ4_ORDEM'})

   // Criacao da VW
   oView:SetModel(oModel)
   oView:AddField('VIEWEZ4' ,oStrVW, 'EZ4MASTER' )
   oView:CreateHorizontalBox( 'TELA', 100)
   oView:SetOwnerView('VIEWEZ4','TELA')
   oView:SetCloseOnOk({||.T.})
   oView:showUpdateMsg(.F.)

   // exibicao da tela
   oExView:setTitle('Tag x Campo - '+aOper[nOper])
   oExView:setView( oView )
   oExView:setModal(.t.)
   oExView:setOperation(nOper)
   oExView:setReduction(10)
   oExView:openView(.T.)

Return

/*=====================================================================================================================================*/
// Manutencao EZ5
/*=====================================================================================================================================*/
User Function ManutEZ5(nOper)

   Local aOper:={'Visualizacao','','Insercao','Atualizacao','Exclusao','Copia'}
   Local oModel := MPFormModel():New('MODELEZ5')
   Local oView  := FWFormView():New()
   Local oExView := FWViewExec():New()
   Local oStrMD := FWFormStruct(1,'EZ5')
   Local oStrVW := FWFormStruct(2, 'EZ5')

   // Criacao do model
   oModel:SetDescription('Layout Prefeituras')
   oModel:addFields('EZ5MASTER',,oStrMD )   //,{|oModel,cAcao,cCampo,xValor,x,w|bPre(oModel,cAcao,cCampo,xValor,x,w)},{|oModelField| bPOS(oModelField) })
   oModel:getModel('EZ5MASTER'):SetDescription('Detalhes')

   // Criacao da VW
   oView:SetModel(oModel)
   oView:AddField('VIEWEZ5' ,oStrVW, 'EZ5MASTER' )
   oView:CreateHorizontalBox( 'TELA', 100)
   oView:SetOwnerView('VIEWEZ5','TELA')
   oView:SetCloseOnOk({||.T.})
   oView:showUpdateMsg(.F.)

   // exibicao da tela
   oExView:setTitle('Layout Prefeituras - '+aOper[nOper])
   oExView:setView( oView )
   oExView:setModal(.t.)
   oExView:setOperation(nOper)
   oExView:setReduction(10)
   oExView:openView(.T.)

Return

/*=====================================================================================================================================*/
// Manuten��o dos conte�dos da tabela EZ9
/*=====================================================================================================================================*/
User Function ManutEZ9(nOpc)

   Local nX            := 0
   Local cAlias        := cTab

   Private oDlg
   Private aObjects   	:= {}
   Private aPos       	:= {}
   Private aSize      	:= {}
   Private aInfo      	:= {}
   Private nReg         := 0 

   aSize := MsAdvSize()
   aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

   aAdd( aObjects, { 315,  70, .T., .T. } )
   aAdd( aObjects, { 100, 100, .T., .T. } )
   aAdd( aObjects, { 100,  14, .T., .F. } )
   aPos := MsObjSize(aInfo,aObjects)

   dbSelectarea("EZ9")
   EZ9->(dbSetOrder(1))
   RegToMemory("EZ9",.F.)  // n�o pode ser a tabela tempor�ria, pois n�o tem os dados do dicionpario

   For nX := 1 To Len(aStruct)
      if nOpc == 3 .and. Alltrim(aStruct[nX,1]) $ "EZ9_ORDEM#EZ9_DADOS"
         M->&(aStruct[nX,1]) := CriaVar(aStruct[nX,1])   //Space(Tamsx3("EZ9_ORDEM")[1])
      Else
         M->&(aStruct[nX,1]) := (cAlias)->&(aStruct[nX,1])
      Endif
   Next nX
   
   Define MsDialog oDlg TITLE "Manuten��o OCR" From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //STYLE WS_DLGFRAME 

   // Tamanho final da tela -> N�o alterar
   aPos[1][3] := aSize[6]/2

   EnChoice( "EZ9", nReg, nOpc, , , , , aPos[1], , 3 , , , , , , .T. )

   Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| If(ManAtualEZ9(nOpc),oDlg:End(),) } , {|| oDlg:End() } )	

Return 

/*=====================================================================================================================================*/
// Permite criar um novo modelo bom base em um item posicionado
/*=====================================================================================================================================*/
Static Function ManAtualEZ9(nOpc)

   Local nX    := 0 
   Local lRet  := .T.

   If nOpc  == 3
      If (cTab)->(dbSeek(xFilial((cTab))+M->(EZ9_TIPDOC+EZ9_MODELO+EZ9_ORDEM)))
         MsgAlert("Registro j� existe, verifique!")
         lRet := .F.
      Elseif Empty(Alltrim(M->EZ9_ORDEM))
         MsgAlert("O campo ORDEM deve ser preenchido. Por favor, verifique!")
         lRet := .F.
      Else
         RecLock(cTab,.T.)
         For nX := 1 To Len(aStruct)
            (cTab)->&(aStruct[nX,1]) := M->&(aStruct[nX,1])
         Next nX 
         MsUnlock()
         MsgAlert("Inclus�o realizada com sucesso!")
      Endif 
   ElseIf nOpc == 4
      RecLock(cTab,.F.)
      For nX := 1 To Len(aStruct)
         (cTab)->&(aStruct[nX,1]) := M->&(aStruct[nX,1])
      Next nX 
      MsUnlock()
      MsgAlert("Altera��o realizada com sucesso!")
   ElseIf nOpc == 5
      RecLock(cTab,.F.)
      (cTab)->(dbDelete())
      MsUnlock()
      MsgAlert("Exclus�o realizada com sucesso!")
   Endif 

Return lRet

/*=====================================================================================================================================*/
// Permite excluir o modelo com base no registro selecionado 
/*=====================================================================================================================================*/
User Function EZ9Delet()
   Private cDocAtu  := (cTab)->EZ9_TIPDOC
   Private cModAtu  := (cTab)->EZ9_MODELO   
   Private cOrdem   := (cTab)->EZ9_ORDEM
   Private cMod      := (cTab)->EZ9_MODELO
   Private cFil      := Space(TamSX3("EZ9_FILIAL")[1])
   Private cTitulo   := "OCR Exclusao" 

   if MsgYesNo("Confirma exclus�o do modelo "+cModAtu+"?",cTitulo) 
      if MsgYesNo("Todos os campos configurados deste modelo ser�o deletados. Confirma?",cTitulo)
         (cTab)->(dbgotop())
         if (cTab)->(dbseek(xFilial('EZ9')+cDocAtu+cModAtu))
            while (cTab)->EZ9_FILIAL == xFILIAL('EZ9') .AND. (cTAB)->EZ9_TIPDOC == cDocAtu ;
                  .and. (cTab)->EZ9_MODELO == cModAtu
                  Reclock(cTab,.f.)
                  (cTab)->(dbDelete())
                  (cTab)->(msUnLock())
                  (cTab)->(dbskip())
            EndDo
         endif
      endif
   endif

Return

/*=====================================================================================================================================*/
// Permite criar um novo modelo bom base em um item posicionado
/*=====================================================================================================================================*/
User Function EZ9Copia()

   Private cDocAtu  := (cTab)->EZ9_TIPDOC
   Private cModAtu  := (cTab)->EZ9_MODELO   
   Private cOrdem   := (cTab)->EZ9_ORDEM
   Private oMod
   Private oFil 
   Private oDlgInc
   Private cMod      := (cTab)->EZ9_MODELO
   Private cFil      := Space(TamSX3("EZ9_FILIAL")[1])
	Private AINFODLG  := {}
	Private aObjSub   := {}   
   Private cTitulo   := "OCR Copia" 

   ASIZEDLG := MSADVSIZE( .F. )
   AINFODLG := { ASIZEDLG[ 1 ], ASIZEDLG[ 2 ], ASIZEDLG[ 3 ], ASIZEDLG[ 4 ], 3, 3 }

   aAdd(aObjSub,{100,100,.T.,.T.,.F.})
   aPosSub := MsObjSize(AINFODLG,aObjSub) 
   
   //Cria uma Dialog
   nLargTela := 400
   nAltuTela := 220

   Define MsDialog oDlgInc TITLE cTitulo From 0,000 TO nAltuTela,nLargTela PIXEL Style DS_MODALFRAME

   @ 003, 003 GROUP oGroup1 TO (nAltuTela/2)-2,nLargTela/2 Prompt "" Of oDlgInc Color 0, 16777215 Pixel              

   aPosSub[1,1] += 02
   @ aPosSub[1,1]+03,aPosSub[1,2]+008 Say "Modelo Atual"			    Size  70,09 Of oDlgInc Pixel
   @ aPosSub[1,1]+11,aPosSub[1,2]+008 MSGET cModAtu Picture "@!"   Size 140,09 Of oDlgInc Pixel When .F.

   aPosSub[1,1] += 26
   @ aPosSub[1,1]+03,aPosSub[1,2]+008 Say "Novo Modelo"			    Size  70,09 Of oDlgInc Pixel
   @ aPosSub[1,1]+11,aPosSub[1,2]+008 MSGET oMod Var cMod Picture "@!"  Size 140,09 Of oDlgInc Pixel

   aPosSub[1,1] += 26
   @ aPosSub[1,1]+03,aPosSub[1,2]+008 Say "Filial Destino"         Size  70,09 Of oDlgInc Pixel
   @ aPosSub[1,1]+11,aPosSub[1,2]+008 MSGET oFil Var cFil Picture "@!" Size 140,09 Of oDlgInc Pixel F3 "SM0" 

   aPosSub[1,1] += 22

   oBtnGravar:=tButton():New(aPosSub[1,1]+10,aPosSub[1,2]+120,'Confirmar',oDlgInc,{|| If(EZ9VLDCopia(cMod),oDlgInc:End(),) },30,11,,,,.T.)
   oBtnFechar:=tButton():New(aPosSub[1,1]+10,aPosSub[1,2]+150,'Fechar',oDlgInc,{|| oDlgInc:End() },30,11,,,,.T.)

   ACTIVATE MSDIALOG oDlgInc CENTERED

Return 

/*=====================================================================================================================================*/
// Valida��es
/*=====================================================================================================================================*/
Static Function EZ9VLDCopia(cMod)

   Local lRet       := .T.
   Local nI         := 0
   Local aAreaEZ9   := (cTab)->(GetArea())
   Local aSM0       := MatFilCalc( .F.,,,,,,.T. )
   Local nI         := 0
   Local lAchou     := .F.

   If Empty(cFil)
      cFil := xFilial("EZ9")  // se estiver vazio, considero a pr�ria filial
      lAchou := .T.
   Endif

    If !Empty(cFil)
      If Empty(xFilial("EZ9"))
         MsgAlert("Tabela � Compartilhada!"+CRLF+"N�o ser� utilizado o C�digo da Filial!")
         cFil := xFilial("EZ9")
         lAchou := .T.
      Else 
         For nI := 1 to Len(aSM0)
            If aSM0[nI,2] == cFil
               lAchou := .T.
               exit
            Endif 
         Next nI
      Endif 
   Endif 

   If !lAchou
      FwAlertError("Filial informada n�o foi localizada!")
      lRet := .F.
   Endif 
   
   If lRet .And. cMod == (cTab)->EZ9_MODELO .And. cFil == xFilial("EZ9")
      FwAlertError("Modelo Informado igual ao que est� sendo copiado!")
      lRet := .F.
   Endif
   
   If lRet

      // Cria��o da temporaia WORKEZ9
      oTemptable := FWTemporaryTable():New("WORKEZ9")
      oTemptable:SetFields(aStruct)
      oTemptable:addindex('01', { "EZ9_FILIAL","EZ9_TIPDOC","EZ9_MODELO","EZ9_ORDEM" })
      oTemptable:Create()
      
      cChave := (cTab)->(EZ9_FILIAL+EZ9_TIPDOC+EZ9_MODELO)
      (cTab)->(dbSeek(cChave))
      While !(cTab)->(Eof()) .And. (cTab)->(EZ9_FILIAL+EZ9_TIPDOC+EZ9_MODELO) == cChave
         RecLock("WORKEZ9",.T.)
         For nI := 1 To EZ9->(FCount())
            cCampo := AllTrim( EZ9->(FieldName(nI)))
            If Alltrim(cCampo) == "EZ9_FILIAL"
               WORKEZ9->&(cCampo) := cFil
            ElseIf Alltrim(cCampo) == "EZ9_MODELO"
               WORKEZ9->&(cCampo) := cMod
            Else 
               WORKEZ9->&(cCampo) := (cTab)->&(cCampo)
            Endif 
         Next nI
         WORKEZ9->(MsUnlock())
         (cTab)->(dbSkip())
      Enddo
      
      // Grava��o dos registros da WORKEZ9 para EZ9 com novo modelo
      WORKEZ9->(dbGoTop())
      While !WORKEZ9->(Eof())
         RecLock((cTab),.T.)
         For nI := 1 To EZ9->(FCount())
            cCampo := AllTrim( EZ9->(FieldName(nI)))
            (cTab)->&(cCampo) := WORKEZ9->&(cCampo)
            SX3->(dbSkip())
         Next nI
         (cTab)->(MsUnlock())
         WORKEZ9->(dbSkip())
      Enddo
      WORKEZ9->(dbCloseArea())

      MsgAlert("C�pia realizada com sucesso!")
      
   Endif 

   RestArea(aAreaEZ9)

Return lRet 



/*=====================================================================================================================================*/
// Ajsuta o Status do registro na EZ0 (precisa estar posicionado e travado para edicao)
/*=====================================================================================================================================*/
Static Function EZ0_STIN()

   Local cQry:=''
   Local lMATA116  := SuperGetMV("EZ_MATA116",.F.,.F.)
   Local lPulaPor := SuperGetMV("EZ_PULAPOR",.F.,.F.) 

   IF !EZ0->EZ0_STINTE $ '1|5|7|9|A|'   // 04/08/2021 - IMPLEMENTADO PARA NaO ALTERAR O STATUS QUANDO A NOTA FOI RECUSADA

      EZ0->EZ0_STINTE:='0'        // "BR_BRANCO"  , "Nao processado"
      // Marcio Martins 30/09/2022
      If Empty(AllTrim(EZ0->EZ0_XMLNFE)) .And. ('resNFe' $ EZ0->EZ0_XMLNFE .Or. Empty(EZ0->EZ0_XMLNFE))
         EZ0->EZ0_STINTE:='3'     //"BR_AMARELO" , "XML Nao DISPONIVEL" )
      Else
         EZ0->EZ0_STINTE:='4'     //"BR_AZUL"    , "XML DISPONIVEL" )
      Endif

      cQry:="select * from "+ RetSqlName('EZ2')             +ENTER
      cQry+=" where EZ2_CHVNFE = '"+EZ0->EZ0_CHVNFE+"' "    +ENTER
      cQry+="   AND EZ2_STATUS = '2' and D_E_L_E_T_ <> '*' "+ENTER
      AbreQuery(cQry,"QRYEZ2")

      If QRYEZ2->( !Eof() )
         EZ0->EZ0_STINTE := '2'  // "BR_VERMELHO", "Inconsistente" )
      Endif
      QRYEZ2->(DBCLOSEAREA())
      
   Endif 
   
return

/*=====================================================================================================================================*/
// Ajsuta o Status do registro na EZ0 (precisa estar posicionado e travado para edicao)
/*=====================================================================================================================================*/
User Function PxmClassNota(lUnica)

   Local cAliasTRB := GetNextAlias()
   Local cSql      := ""
   Private lAtivaMan  := SuperGetMV("EZ_ATVMAN",.F.,.F.)    // Ativa o Manifesto para recusar documentos
   
   Default lUnica  := .F.

   //If !EZ0->EZ0_STINTE $ '1|7|5|6'
   If !EZ0->EZ0_STINTE $ '1|7|4|5|6'   // Carla Barbosa 22/08/2022 - Acrescentado status 4 para OCP 
         Return 
   Endif 

	AROTINA 	:= {	{"PESQUISAR"  , "AXPESQUI"    , 0, 1},;
						{"VISUALIZAR" , "AXVISUAL"    , 0, 2},;
                  {"INCLUIR"    , "A103NFiscal" , 0, 3},;
                  {"CLASSIFICAR", "A103NFiscal" , 0, 4}}

   dbSelectArea("EZ0")
   EZ0->(dbSetOrder(1))
   
   cSql := " SELECT R_E_C_N_O_ RECEZ0 FROM "+ RetSqlName('EZ0')
   If lUnica
      cSql += " WHERE EZ0_CHVNFE = '"+ EZ0->EZ0_CHVNFE + "' AND D_E_L_E_T_ = ' ' AND EZ0_FILIAL = '" + xFilial("EZ0") + "' "
   Else 
      cSql += " WHERE EZ0_MARK = '"+CMARK+"' AND D_E_L_E_T_ = ' ' AND EZ0_FILIAL = '" + xFilial("EZ0") + "' "
   Endif 
   DBUseArea(.T., "TOPCONN", TCGenQry( , , cSql), (cAliasTRB), .F., .T.)

   While !(cAliasTRB)->(Eof())
      
      EZ0->(dbGoTo( (cAliasTRB)->RECEZ0 ))

      cCNPJ := EZ0->EZ0_CNPJEM

      DbSelectArea("SA2")
      SA2->(dbSetOrder(3))
      If SA2->(dbSeek(xFilial('SA2')+cCNPJ))
         cCodLoja := SA2->(A2_COD+A2_LOJA)
      EndIf		
      L103AUTO := .F.
      DBSELECTAREA("SF1")
      SF1->(DBSETORDER(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
      IF SF1->(DBSEEK(XFILIAL("SF1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA)))
         Mata241()
         //SF1->(A103NFiscal("SF1", SF1->(RECNO()) ,4, {}))
         dbSelectArea("SF3")
         SF3->(dbSetOrder(4)) // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
         If SF3->(dbSeek(xFilial("SF3")+EZ0->(EZ0_FORNEC+EZ0_LOJA+EZ0_DOC+EZ0_SERIE)))
            dbSelectArea("EZ0")
            RecLock("EZ0",.F.)
            EZ0->EZ0_STINTE := '5'
            MsUnlock()
            // Carla Barbosa - 06/12/2022
            // Usar a Manifesta��o independente do uso da Portaria
            //If lUsaPort
               If lAtivaMan
                  U_ManifChave(EZ0->EZ0_CHVNFE,"210200") // 210200 - Confirmacao da Operacao            
               Endif 
               U_RegLogUser("A")      
            //Endif 
         Endif 
      Endif 

      (cAliasTRB)->(dbSkip())

   Enddo 
   (cAliasTRB)->(dbCloseArea())

   TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' WHERE EZ0_MARK = '"+cMark+"' AND D_E_L_E_T_ <> '*' AND EZ0_FILIAL = '" + xFilial("EZ0") + "' ")

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Mata241()
// Fun��o Criada para que o ExecAuto da rotina ATFA012 entenda que o ativo fixo 
// vem de uma fun��o padr�o TOTVS e permita a cria��o do mesmo com o status 0
// pendente de classifica��o.
// Fun��o chama a Classifica��o do Mata103
@author Carla Barbosa/Renato Pego
@since 26/05/2022
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------

Static Function Mata241()

Return SF1->(A103NFiscal("SF1", SF1->(RECNO()) ,4, {}))


/*=====================
================================================================================================================*/
// Copia os CT-e�s para uma Pasta Especifica
// Par�metro: nOpcao -> 1-Respeita a query / 2-Posicionado, acionado na funcao PTGrvXML()
/*=====================================================================================================================================*/
User Function CTECopy(nOpcao)

   Local lRet    := .F.
   Local cQry    := ""
   Local cXMLDIR := SuperGetMV("MV_XMLDIR",.F.,"")

   Default nOpcao := 1

   If Empty(cXMLDIR)
      MsgAlert("Par�metro MV_XMLDIR nao possui uma pasta definida!")
   Else
      If !ExistDir(cXMLDIR)
         MakeDir(cXMLDIR)
      Endif 

      If nOpcao == 1

         cQry := " SELECT EZ0_CHVNFE,R_E_C_N_O_ FROM "+ RetSqlName('EZ0')
         cQry += " WHERE EZ0_FILIAL = '" +  xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' AND D_E_L_E_T_ <> '*' AND EZ0_TIPONF = 'CTe' "
         AbreQuery(cQry,"QRYEZ0")

         If QRYEZ0->(!Eof())
            While QRYEZ0->(!Eof())
               EZ0->(dbGoTo(QRYEZ0->R_E_C_N_O_))
               lRet := MemoWrite(cXMLDIR+EZ0->EZ0_CHVNFE+"-cte.xml",EZ0->EZ0_XMLNFE)
               If lRet
                  RecLock("EZ0",.F.)
                  EZ0->EZ0_STINTE := '8'
                  MsUnlock()
               Endif 
               QRYEZ0->(dbSkip())
            Enddo
         Else
            MsgAlert("Nao foram selecionados CT-e�s!")
         Endif 
         QRYEZ0->(dbCloseArea())

         TCSQLEXEC("UPDATE "+ RETSQLNAME('EZ0')+" SET EZ0_MARK = '' WHERE EZ0_MARK = '"+CMARK+"'")  //LIMPA AS MARCACOES AO SAIR.

      Else

         lRet := MemoWrite(cXMLDIR+EZ0->EZ0_CHVNFE+"-cte.xml",EZ0->EZ0_XMLNFE)
         If lRet
            RecLock("EZ0",.F.)
            EZ0->EZ0_STINTE := '8'
            MsUnlock()
         Endif 

      Endif 
   Endif 

Return


/*
===============================================================================================
||   Funcao: 	RecusaOper
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	22/13/2021
===============================================================================================
||	  Funcao que realiza a ciencia da operacao
===============================================================================================
||   210220 - Desconhecimento da Operacao
||   210240 - Operacao nao Realizada - Obrigatorio a justificativa
===============================================================================================
*/
User Function RecusaOper()

   Local aAreaEz0 := EZ0->(GetArea())

	Private AINFODLG 	  	:= {}
	Private aObjSub   	:= {}
   Private oDlgInc
   Private oJustific
   Private cOpcao	:= Space(40)
   Private nOpcao	:= 0 
   Private aOpcao	:= {"210240 - Operacao nao Realizada","210220 - Desconhecimento da Operacao"}
   Private cJustific := Space(256)

   If UPPER(EZ0->EZ0_TIPONF) == 'CTE'
      If lAtivaMan
         If !Empty(EZ0->EZ0_MARK)
            CTESpedDes()
            Reclock("EZ0",.F.)
            EZ0->EZ0_MARK := ''
            MsUnlock()
         Else
            MsgAlert("Nao foram selecionados CT-e�s!")
         Endif 
      Else
         MsgAlert("Par�metro EZ_ATVMAN nao ativado!" )
      Endif 

   ElseIf UPPER(EZ0->EZ0_TIPONF) == 'NFE'

      If !Empty(EZ0->EZ0_MARK)

         ASIZEDLG	:= MSADVSIZE( .F. )
         AINFODLG 	:= { ASIZEDLG[ 1 ], ASIZEDLG[ 2 ], ASIZEDLG[ 3 ], ASIZEDLG[ 4 ], 3, 3 }

         aAdd(aObjSub,{100,100,.T.,.T.,.F.})
         aPosSub := MsObjSize(AINFODLG,aObjSub)
            
         //Cria uma Dialog
         nLargTela := 400
         nAltuTela := 240

         Define MsDialog oDlgInc TITLE "Manifestar Operacao" From 0,000 TO nAltuTela,nLargTela PIXEL Style DS_MODALFRAME

         @ 003, 003 GROUP oGroup1 TO (nAltuTela/2),nLargTela/2 Prompt "" Of oDlgInc Color 0, 16777215 Pixel              

         aPosSub[1,1] += 05
         @ aPosSub[1,1]+03,aPosSub[1,2]+010 Say "Selecione a Recusa"						   Size  60,09 Of oDlgInc Pixel 
         @ aPosSub[1,1]+12,aPosSub[1,2]+010 MsComboBox oOpcao Var nOpcao items aOpcao 	Size 120,09 Of oDlgInc Pixel
         
         @ aPosSub[1,1]+28,aPosSub[1,2]+010 Say "Justificativa"   						   Size  60,09 Of oDlgInc Pixel 
         @ aPosSub[1,1]+37,aPosSub[1,2]+010 GET oJustific Var cJustific MEMO           Size 180,58 Of oDlgInc Pixel

         aPosSub[1,1] += 88
         oBtnGravar:=tButton():New(aPosSub[1,1]+10,(nLargTela/2)-66,'Confirmar',oDlgInc,{|| If(VLDRejeicao(),Processa( { || RecusaProc(), oDlgInc:End() }, "Processando, Por favor aguarde."),oJustific:SetFocus()) },30,11,,,,.T.)
         oBtnFechar:=tButton():New(aPosSub[1,1]+10,(nLargTela/2)-36,'Fechar',oDlgInc,{|| oDlgInc:End() },30,11,,,,.T.)

         ACTIVATE MSDIALOG oDlgInc CENTERED


      Else
      
         MsgAlert("Par�metro EZ_ATVMAN nao ativado!" )

      Endif 

   Endif 

   RestArea(aAreaEz0)

Return 

/*=====================================================================================================================================*/
// Valida a se para o codigo de cancelamento 210240 - Operacao nao Realizada, ha justificativa preechida
/*=====================================================================================================================================*/
Static Function VLDRejeicao

   Local lRet     := .T.

   If ValType(nOpcao) == "N"
      nOpcao := aOpcao[nOpcao]      
   Endif 

   If SubStr(nOpcao,1,6) == "210240" .And. Empty(cJustific)
      lRet := .F.
   Elseif !Empty(cJustific) .and. Len(cJustific) <= 15
      MsgAlert("Tamanho minimo da Justificativa 15 caracteres!")
      lRet := .F.
   Endif 

Return lRet

/*=====================================================================================================================================*/
// Realiza o processamento da recusa do NF-e
/*=====================================================================================================================================*/
Static Function RecusaProc()
   
   Local cCodigo := ""

   If ValType(nOpcao) == "N"
      nOpcao := aOpcao[nopcao]      
   Endif 
   
   cCodigo := SubStr(nOpcao,1,6)

      If lAtivaMan

         If !Empty(cCodigo)
            U_ManifChave(EZ0->EZ0_CHVNFE,cCodigo,cJustific) 
         Endif 

      Else

         MsgAlert("Nao foram selecionados NF-e�s!")

      Endif

Return 

/*=====================================================================================================================================*/
// Exclui os registros nas tabelas EZ0,EZ1, EZ2 e EZ6 para tudo que esta marcado em tela.
/*=====================================================================================================================================*/
User Function PxmlExcXML()

   Local lUsaPort := SuperGetMV("EZ_USAPORT",.F.,.F.)   // USA MoDULO DE PORTARIA
   Local cExcPerm := SuperGetMV("EZ_EXCPERM",.F.,.F.)   // Usuarios que podem excluir XML? -> Modelo: "000001|000002|000003"
   Local cQry     :=""

   cQry:="SELECT COUNT(*) RECMARK FROM "+ RetSqlName('EZ0')+" WHERE D_E_L_E_T_ = '' AND EZ0_MARK = '"+cMark+"'  "
   AbreQuery(cQry,"QRYEZ0")

   If !__cUserid $ cExcPerm
      If QRYEZ0->(RECMARK) > 1
         QRYEZ0->(DBCLOSEAREA())
         TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' ")
         MsgAlert("N�o � possivel excluir mais de um registro por vez. Por favor marque apenas um XML por vez!")
         Return 
      Endif 
   Endif 
   QRYEZ0->(DBCLOSEAREA())

   If MsgYesNo("Confima exclusao dos Documentos marcados ?")

      cQry := " SELECT EZ0_CHVNFE,R_E_C_N_O_ FROM "+ RetSqlName('EZ0')
      cQry += " WHERE EZ0_MARK = '"+cMark+"' AND D_E_L_E_T_ <> '*' "
      AbreQuery(cQry,"QRYEZ0")
          While QRYEZ0->( !Eof() )
            EZ0->(dbGoTo( QRYEZ0->R_E_C_N_O_ ))
            cChExc := EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
            If Select("EZ2") > 0
               EZ2->(dbCloseArea())
            Endif
            If lUsaPort
               dbSelectArea("EZ6")
               EZ6->(dbSetOrder(1))	                                      // garantir o posicionamento
               while EZ6->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)))
                     EZ6->(RecLock('EZ6',.F.) )
                     EZ6->(dbDelete())
                     EZ6->(MsUnLock())
                     EZ6->(dbSkip())
               Enddo  
            Endif 
            dbSelectArea("EZ2")
            EZ2->(dbSetOrder(1))	                                      // garantir o posicionamento
            while EZ2->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)))
                  EZ2->(RecLock('EZ2',.F.) )
                  EZ2->(dbDelete())
                  EZ2->(MsUnLock())
                  EZ2->(dbSkip())
            Enddo  
            If Select("EZ1") > 0
               EZ1->(dbCloseArea())
            Endif
            dbSelectArea("EZ1")
            EZ1->(dbSetOrder(1)) // garantir o posicionamento
            while EZ1->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)))
               EZ1->(RecLock('EZ1',.F.) )
               EZ1->(dbDelete())
               EZ1->(MsUnLock())
               EZ1->(dbSkip())
            Enddo
            EZ0->(RecLock('EZ0',.f.) )
            EZ0->(dbDelete())
            EZ0->(MsUnLock())
            CONOUT("[PxmlExcXML] - Data/Hora: "+Dtoc(dDataBase)+"-"+CValToChar(time()))
            CONOUT("[PxmlExcXML] - Usu�rio  : "+cUsername)
            CONOUT("[PxmlExcXML] - FILIAL/CHAVE EXCLUIDA : " + cChExc)
            QRYEZ0->(dbSkip())
         Enddo

      QRYEZ0->(dbCloseArea())
      
   Endif

return

/*=====================================================================================================================================*/
// Permite selecionar a pasta aonde serao gerados os arquivos XML
/*=====================================================================================================================================*/
User Function PxmVisNFSE

   Local cTexto  := ""
   Local cTxtCpo := EZ0->EZ0_XMLNFE
   Local cTitulo := "Visualizacao dos dados da Nota de Servico"
   Local oObserv
   Local oDlg

	Private aObjects   	:= {}
	Private aPos       	:= {}
	Private aSize      	:= MsAdvSize()
	Private aInfo      	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

   If ALLTRIM(EZ0->EZ0_SERIE) $ "RPS|M" .AND. EZ0->EZ0_TIPONF <>"NFO"

      dbSelectArea("EZ5")
      EZ5->(dbSetOrder(1))
      If !EZ5->(dbSeek(xFilial("EZ5")+SM0->M0_CODMUN))
         MsgAlert("Nao ha Layout cadastrado na Prefeitura de " + Alltrim(Posicione("CC2",1,xFilial("CC2")+SM0->M0_ESTCOB+Right(SM0->M0_CODMUN,5),"CC2_MUN")))
         Return 
      Endif 

      While !EZ5->(Eof()) .And. xFilial("EZ5")+SM0->M0_CODMUN == EZ5->(EZ5_FILIAL+EZ5_CODMUN)
         If EZ5->EZ5_TIPO == "2" //.And. !Empty(EZ5->EZ5_CHAVE)
            cTexto += Upper(EZ5->EZ5_DSCCPO) + "| " + Upper(SubStr(cTxtCpo,EZ5->EZ5_POSINI,EZ5->EZ5_TAMANH)) + CRLF
         Endif 
         EZ5->(dbSkip())
      Enddo 
     
     	aAdd( aObjects, { 315,  70, .T., .T. } )
      aAdd( aObjects, { 100, 100, .T., .T. } )
      aAdd( aObjects, { 100,  14, .T., .F. } )
      aPos := MsObjSize(aInfo,aObjects)

      Define MsDialog oDlg TITLE cTitulo From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL //STYLE WS_DLGFRAME 

      oFont12 := TFont():New( "Courier new",,14,,.F.,,,,,.F. )
      oObserv := tMultiGet():New(aPos[1,1],aPos[1,2], {|u|if(Pcount()>0,cTexto:=u, cTexto)}, oDlg, aPos[2,4],aPos[2,3]-15,oFont12,.T.,,,,.T.)
      
      Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()}) Centered

   Endif 

Return 

/*=====================================================================================================================================*/
// Permite visualizar o Log detalhado do processo por chave
/*=====================================================================================================================================*/
User Function PxmVisLog

   Local cTexto  := ""
   Local cTitulo := "Log do Processo - Chave " + EZ0->EZ0_CHVNFE
   Local oObserv
   Local oDlg

	Private aObjects   	:= {}
	Private aPos       	:= {}
	Private aSize      	:= MsAdvSize()
	Private aInfo      	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	dbSelectArea("EZ6")
	EZ6->(dbSetOrder(1))	// EZ6_FILIAL+EZ6_CHVNFE+EZ6_DTLOG+EZ6_HRLOG                                                                                                                       
	EZ6->(dbSeek(xFilial("EZ6")+EZ0->EZ0_CHVNFE))
	While !EZ6->(Eof()) .and. xFilial("EZ6")+EZ0->EZ0_CHVNFE == EZ6->(EZ6_FILIAL+EZ6_CHVNFE)
		cTexto += DTOC(EZ6->EZ6_DTLOG) + " " + EZ6->EZ6_HRLOG + " - Usuario: " + Padr(EZ6->EZ6_USERLG,15) + " - Acao: " + EZ6->EZ6_DESCR + CRLF
		EZ6->(dbSkip())
	Enddo

   dbSelectArea("SE2")
   SE2->(dbSetOrder(6)) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
   If SE2->(dbSeek(xFilial("SE2")+EZ0->(EZ0_FORNEC+EZ0_LOJA+EZ0_SERIE+EZ0_DOC)))
      cTexto += "" + CRLF + CRLF
      cTexto += "Titulo(s): " + CRLF
      While !SE2->(Eof()) .And. xFilial("SE2")+EZ0->(EZ0_FORNEC+EZ0_LOJA+EZ0_SERIE+EZ0_DOC) == SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM)
         cTexto += "Parcela " + If(Empty(SE2->E2_PARCELA),"Unica",Alltrim(SE2->E2_PARCELA)) + " - Vencimento: " + DTOC(SE2->E2_VENCTO) + " -  Valor: " + Transform(SE2->E2_VALOR,"@E 999,999,999.99") + CRLF
         SE2->(dbSkip())
      Enddo
   Endif 

   aAdd( aObjects, { 315,  70, .T., .T. } )
   aAdd( aObjects, { 100, 100, .T., .T. } )
   aAdd( aObjects, { 100,  14, .T., .F. } )
   aPos := MsObjSize(aInfo,aObjects)

   Define MsDialog oDlg TITLE cTitulo From 0,0 TO 400,800 OF oMainWnd PIXEL //STYLE WS_DLGFRAME 

   oFont12 := TFont():New( "Courier new",,14,,.F.,,,,,.F. )
   //oObserv := tMultiGet():New(aPos[1,1],aPos[1,2], {|u|if(Pcount()>0,cTexto:=u, cTexto)}, oDlg, aPos[2,4]/2,(aPos[2,3]/2)-20,oFont12,.T.,,,,.T.)
   oObserv := tMultiGet():New(aPos[1,1],aPos[1,2], {|u|if(Pcount()>0,cTexto:=u, cTexto)}, oDlg, 397,163,oFont12,.T.,,,,.T.)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()}) Centered

Return 

/*=====================================================================================================================================*/
// Permite selecionar a pasta aonde serao gerados os arquivos XML
/*=====================================================================================================================================*/
User Function PxmlBaixaXML()

   Local aPerg		:= {}
   Local aParam 	:= {Space(60),Space(30)}

   aadd(aPerg,{6,"Diretorio de destino",aParam[01],"",".T.","",80,.T.,"Arquivos TXT |*.TXT","",GETF_RETDIRECTORY+GETF_LOCALHARD,.F.})

   If ParamBox(aPerg,"Gravacao de XML",@aParam,,,.T.,,,,,.T.,.T.)
      If !Empty(aParam[01])
         Processa({|lEnd| PxmlGrvXML(aParam[01])},"Processando","Aguarde, gerando arquivo de Clientes",.F.)
         Aviso("EZ4 GRC","Operacao finalizada",{"OK"},3)
      Else
         Aviso("EZ4 GRC","Diretorio Nao informado",{"OK"},3)
      Endif
   Else
      Aviso("EZ4 GRC","Operacao cancelada",{"OK"},3)
   EndIf

return

/*=====================================================================================================================================*/
// Grava em arquivo o xml para tudo que esta marcado em tela.
/*=====================================================================================================================================*/
Static Function PxmlGrvXML(cDirDest)

   Local cDrive := '', cDestino:= ''
   Local cFile  := '', cQry := ''

   SplitPath(cDirDest,@cDrive,@cDestino,"","")
   cDestino := cDrive+cDestino

   cQry:="select EZ0_CHVNFE,EZ0_XMLNFE,R_E_C_N_O_ from "+ RetSqlName('EZ0')+" where EZ0_MARK = '"+cMark+"' and D_E_L_E_T_ <> '*' "
   AbreQuery(cQry,"QRYEZ0")

   While QRYEZ0->( !Eof() )
         EZ0->( dbGoTo( QRYEZ0->R_E_C_N_O_ ) )
         cFile := cDestino+QRYEZ0->(AllTrim(EZ0_CHVNFE))+".xml"
      if Empty(AllTrim(EZ0->EZ0_XMLNFE)) // se Nao tem o xml
         cQry:='<PORTAL_XML>'
            cQry+='<AVISO>XML inDISPONIVEL</AVISO>'
         cQry+='</PORTAL_XML>'
         else
            cQry := AllTrim(EZ0->EZ0_XMLNFE)
         endif
         memowrite(cFile,cQry)
         QRYEZ0->(dbSkip())
   End
   QRYEZ0->(DBCLOSEAREA())

return

/*=====================================================================================================================================*/
// Funcao para critica e geracao das notas - Entrada/saida definido na variavel nOpcTela
/*=====================================================================================================================================*/
User Function Gera_PRNF(nOpcTela)  // tela de apresentalcao da possivel pre-nota

   // Variaveis para a TELA
   Local oLy, oPnUp, oPnLeft, oPnRight, oProcess
   Local oRelacEZ1, oRelacEZ2
   Local aCoors      := FWGetDialogSize( oMainWnd )
   Local cQry:="" , lBuscaXML := .F.
   Local nX          := 0 
   Local cTitTela     := 0

   Private oBrwUp      := FWMBrowse():New()
   Private oBrwRight   := FWBrowse():New()  // lado direito mensagens de erro   
   Private oBrwLeft    := FWBrowse():New() // Lado Esquerdo Itens
   Private lUsaPort   := SuperGetMV("EZ_USAPORT",.F.,.F.)   // USA MoDULO DE PORTARIA
   Private lIntGFE    := SuperGetMV("MV_INTGFE" ,.F.,.F.)    // SE ATIVADO, NaO PROCESSA ENTRADA DO CTE, FICA A CARGO DO GFE, COPIA-SE O XML PARA MV_XMLDIR
   Private aChaves     := {}
   // Variaveis para controle
   Private oDlgPrinc, lConfirmado := .F.

   SetKey(VK_F6 , {|| U_GRC_NPDF() } )

   /*
   If lUsaPort
      // Avalio os registros corrigidos pelo MONITERROS.prw
      Processa({|lEnd| ExecEZ2() },"Processando","Atualizando....",.F.)      
   Endif 
   */

   //=====================================================================
   // NFSAIDA-2020 - MARCIO MARTINS - 06/07/2020
   // Passo realizado para desconsiderar documentos referentes a saida
   //=====================================================================
   If nOpcTela == 1 .Or. nOpcTela == 3 // Marcio
      TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' AND EZ0_ACAO = '1' ")
   Else
      TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' AND EZ0_ACAO <> '1' ")
   Endif 
   //=====================================================================
   //=====================================================================

   If nOpcTela == 3
      cQry:="SELECT COUNT(*) RECMARK FROM "+ RetSqlName('EZ0')+" WHERE EZ0_TIPONF = 'CTe' AND D_E_L_E_T_ = '' AND EZ0_MARK = '"+cMark+"' AND EZ0_ACAO  = '0' "
      AbreQuery(cQry,"QRYEZ0")
      If QRYEZ0->(RECMARK) > 1
         QRYEZ0->(DBCLOSEAREA())
         TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' ")
         MsgAlert("Para Conhecimento de Frete, dever� ser selecionado um CT-e por vez")
         Return 
      Endif 
      QRYEZ0->(DBCLOSEAREA())
   Endif 

   // Indica que a tela inicial Nao esta ativa
   Raiz := 9
   // Seleciona itens que serao exibidos
   If nOpcTela == 1 
      cQry:="select EZ0_CHVNFE,EZ0_XMLNFE,R_E_C_N_O_,EZ0_TIPONF from "+ RetSqlName('EZ0')+" where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' and D_E_L_E_T_ <> '*' "
   ElseIf nOpcTela == 3 // Marcio
      cQry:="select EZ0_CHVNFE,EZ0_XMLNFE,R_E_C_N_O_,EZ0_TIPONF from "+ RetSqlName('EZ0')+" where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' and D_E_L_E_T_ <> '*' AND EZ0_TIPONF = 'CTe' "
   Else 
      cQry:="select EZ0_CHVNFE,EZ0_XMLNFE,R_E_C_N_O_,EZ0_TIPONF from "+ RetSqlName('EZ0')+" where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' and D_E_L_E_T_ <> '*' AND EZ0_ACAO  = '1' "
   Endif 
   AbreQuery(cQry,"QRYEZ0")

   // identifica se todas as notas marcadas ja possuem XML
   While QRYEZ0->( !Eof() )
      if QRYEZ0->( !empty( AllTrim(EZ0_CHVNFE) ) )
         QRYEZ0->( aadd(aChaves,{EZ0_CHVNFE,R_E_C_N_O_,EZ0_TIPONF}))
         VldDadosNF(aChaves[1])
         EZ0->(dbGoTo( QRYEZ0->R_E_C_N_O_ ))
         if Empty(AllTrim(EZ0->EZ0_XMLNFE)) // se Nao tem o xml
            lBuscaXML := .T.                // marca para inciar
         endif                              // a rotina de busca
         EZ0->( RecLock('EZ0',.f.) )
         EZ0->( EZ0_STIN()  )
         EZ0->( msUnLock() )
      endif
      QRYEZ0->(dbSkip())
   End
   QRYEZ0->(DBCLOSEAREA())

   // carrega os campos de itens e validacoes.
   if len(aChaves) > 0
      oProcess:=  MsNewProcess():New({|lEnd| u_Proc_NF(aChaves,lBuscaXML,@oProcess,lEnd,.F.)}, "EZ4 GRC" , "Processando XML's ...", .T.)
      oProcess:Activate()
   endif

   If lUsaPort .And. lUsaWFInt
      SetKey(VK_F12 , {|| WFInconsist() } )
   Endif 
   
   SetKey(VK_F4 , {|| U_NFREFDEV(),oBrwLeft:Refresh()} )
   SetKey(VK_F8 , {|| MULTLINHAS(),oBrwUp:Refresh(),oBrwLeft:Refresh() })

   // Criacao da janela
   oDlgPrinc            := TDialog():new()
   oDlgPrinc:nLeft	   := aCoors[1]
   oDlgPrinc:nTop	      := aCoors[2]
   oDlgPrinc:nHeight    := aCoors[3]
   oDlgPrinc:nWidth     := aCoors[4]
   oDlgPrinc:lCentered  := .T.
   oDlgPrinc:lEscClose  := .T.
   oDlgPrinc:lmaximized := .T.
   oDlgPrinc:oParent    := oMainWnd
   
   If nOpcTela == 1
      cTitTela := "Entrada"
   ElseIf nOpcTela == 2
      cTitTela := "Saida"
   ElseIf nOpcTela == 3
      cTitTela := "Conhec.Frete"
   Endif 
   oDlgPrinc:cCaption   := "Avaliacao de documento para "+cTitTela
   
   // Cria o conteiner onde serao colocados os browses
   oLy := FWLayer():New()
   oLy:Init( oDlgPrinc, .F., .T. )

   // Define Painel Superior
   oLy:AddLine( 'UP', 40, .F. ) // LINHA COM 50% DA TELA
   oLy:AddCollumn( 'ALL', 99, .T., 'UP' ) // COluna com 100% da tamanho dela
   oPnUp := oLy:GetColPanel( 'ALL', 'UP' )

   // Define os Paineis Inferior
   oLy:AddLine( 'DOWN', 59, .F. )            // LINHA COM 60% DA TELA
   oLy:AddCollumn( 'LEFT' , 59, .T., 'DOWN' )// Na "linha" criada eu crio uma coluna com 60% da tamanho dela
   oPnLeft := oLy:GetColPanel( 'LEFT' , 'DOWN' ) // Pego o objeto do pedaco esquerdo
   oLy:AddCollumn( 'RIGHT',39 , .T., 'DOWN' )// Na "linha" criada eu crio uma coluna com 40% da tamanho dela
   oPnRight := oLy:GetColPanel( 'RIGHT', 'DOWN' ) // Pego o objeto do pedaco direito

   //Defincao do browse do painel superior com os cabecarios das Notas
   oBrwUp:SetOwner( oPnUp )  // Aqui se associa o browse ao componente de tela
   oBrwUp:SetDescription( "Notas Fiscais Lidas de " + If(nOpcTela==1,"Entrada",If(nOpcTela==2,"Saida","Conhec.Frete")) )
   oBrwUp:SetMenuDef('EZ4_GRC_PORTALXML')    // ARQUIVO FONTE ONDE ESTA A MENUDEF
   oBrwUp:SetAlias( 'EZ0' )
   oBrwUp:SetFilterDefault( "EZ0_MARK = '"+cMark+"'" ) // somente as notas marcadas
   oBrwUp:DisableDetails()
   oBrwUp:ForceQuitButton()
   // Definicao da legenda
   oBrwUp:AddLegend( "EZ0_STINTE=='0'", "BR_BRANCO"  , "Nao Processado" )
   oBrwUp:AddLegend( "EZ0_STINTE=='1'", "BR_VERDE"   , "Documento Gerado" )
   oBrwUp:AddLegend( "EZ0_STINTE=='2'", "BR_VERMELHO", "Inconsistente" )
   oBrwUp:AddLegend( "EZ0_STINTE=='3'", "BR_AMARELO" , "XML Nao Disponivel" )
   oBrwUp:AddLegend( "EZ0_STINTE=='9'", "BR_CANCEL"  , "Chave Rejeitada" )  
   If lUsaPort
      oBrwUp:AddLegend( "EZ0_STINTE=='4'", "BR_AZUL"    , "Portaria" )
      oBrwUp:AddLegend( "EZ0_STINTE=='6'", "BR_PINK"    , "Recebimento Fisico" )
      oBrwUp:AddLegend( "EZ0_STINTE=='7'", "BR_PRETO"   , "Aguardando Classificacao" )      
      oBrwUp:AddLegend( "EZ0_STINTE=='A'", "BR_VIOLETA" , "Doc.Entrada Manual" )          
      If lIntGFE
         oBrwUp:AddLegend( "EZ0_STINTE=='8'", "BR_CINZA"   , "CT-e Copiado" )      
      Endif 
   Endif 
   oBrwUp:AddLegend( "EZ0_STINTE=='4'", "BR_AZUL"    , "XML Disponivel" )
   oBrwUp:AddLegend( "EZ0_STINTE=='A'", "BR_VIOLETA" , "Doc.Aguard.Aprovacao" )          
   oBrwUp:AddLegend( "EZ0_STINTE=='5'", "BR_LARANJA"    , "Nota Classificada" )

   oBrwUp:blDblClick := {|| u_dplClick('UP',@oBrwLeft,@oBrwRight) }
   oBrwUp:SetProfileID( '1' )
   oBrwUp:Activate()

   //Defincao do browse do painel esquerdo com os itens da Nota em destaque
   oBrwLeft:SetOwner( oPnLeft )
   oBrwLeft:SetDescription( 'Itens da Nota em destaque' )
   oBrwLeft:SetDataTable()
   oBrwLeft:SetAlias( 'EZ1' )
   oBrwLeft:SetProfileID( '2' )
   //oBrwLeft:DisableConfig()
   //oBrwLeft:DisableReport()
   //oBrwLeft:DisableFilter()

   SX3->(dbSetOrder(1)) // X3_ARQUIVO+X3_ORDEM
   SX3->(dbSeek('EZ1'))
   while SX3->X3_ARQUIVO == 'EZ1'
      if !(Alltrim(SX3->X3_CAMPO) $ 'EZ1_FILIAL,EZ1_CHVNFE')
         oColumn := FWBrwColumn():New()
         oColumn:SetTitle( SX3->X3_TITULO ) //Titulo
         oColumn:SetData( &("{|| EZ1->" + SX3->X3_CAMPO + " }") ) //Dados
         oColumn:SetPicture( SX3->X3_PICTURE )
         oColumn:SetSize(SX3->X3_TAMANHO/2 )
         oColumn:SetDecimal( SX3->X3_DECIMAL )
         oColumn:SetType( SX3->X3_TIPO )  // Tipo
         oColumn:blDblClick := {|| u_dplClick('LEFT',@oBrwLeft,@oBrwRight) }
         oBrwLeft:SetColumns({oColumn}) //Adiciona a Coluna ao Browse
      endif 
      SX3->(dbSkip())
   enddo
   oBrwLeft:Activate()

   //Defincao do browse do painel direito com as mensagens de validacao
   oBrwRight:SetOwner( oPnRight )
   oBrwRight:SetDescription( 'Mensagens da Nota em destaque' )
   //oBrwRight:DisableConfig()
   //oBrwRight:DisableReport()
   //oBrwRight:DisableFilter()
   oBrwRight:SetDataTable()
   oBrwRight:SetAlias( 'EZ2' )
   oBrwRight:AddLegend( "EZ2_STATUS=='0'", "BR_VERDE"   , "OK" )
   oBrwRight:AddLegend( "EZ2_STATUS=='1'", "BR_AMARELO" , "Atencao" )
   oBrwRight:AddLegend( "EZ2_STATUS=='2'", "BR_VERMELHO", "Erro" )
   oBrwRight:AddFilter( "Requerem acoes", "EZ2_STATUS<>'0'", .f.,.t.)
   oBrwRight:SetProfileID( '3' )
   SX3->(dbSetOrder(1)) // X3_ARQUIVO+X3_ORDEM
   SX3->(dbSeek('EZ2'))
   while SX3->X3_ARQUIVO == 'EZ2'
      if !(Alltrim(SX3->X3_CAMPO) $ 'EZ2_FILIAL,EZ2_CHVNFE,EZ2_STATUS')
         oColumn := FWBrwColumn():New()
         oColumn:SetTitle( SX3->X3_TITULO ) //Titulo
         oColumn:SetData( &("{|| EZ2->" + SX3->X3_CAMPO + " }") ) //Dados
         oColumn:SetPicture( SX3->X3_PICTURE )
         oColumn:SetSize(SX3->X3_TAMANHO/2 )
         oColumn:SetDecimal( SX3->X3_DECIMAL )
         oColumn:SetType( SX3->X3_TIPO )  // Tipo
         oColumn:blDblClick := {|| u_dplClick('RIGHT',@oBrwLeft,@oBrwRight) }
         oBrwRight:SetColumns({oColumn}) //Adiciona a Coluna ao Browse
      endif 
      SX3->(dbSkip())
   enddo 
   oBrwRight:Activate()

   oRelacEZ1:= FWBrwRelation():New()
   //oRelacEZ1:AddRelation( oBrwUp , oBrwLeft , { { 'EZ1_CHVNFE' , 'EZ0_CHVNFE' } } )
   oRelacEZ1:AddRelation( oBrwUp , oBrwLeft , { { 'EZ1_FILIAL', 'xFilial("EZ1")' } , { 'EZ1_CHVNFE' , 'EZ0_CHVNFE' } } )
   oRelacEZ1:Activate()

   oRelacEZ2:= FWBrwRelation():New()
   //oRelacEZ2:AddRelation( oBrwLeft, oBrwRight, { { 'EZ2_CHVNFE' , 'EZ1->EZ1_CHVNFE' } } )
   oRelacEZ2:AddRelation( oBrwLeft, oBrwRight, { { 'EZ2_FILIAL', 'xFilial("EZ2")' }, { 'EZ2_CHVNFE' , 'EZ1->EZ1_CHVNFE' } } )
   oRelacEZ2:Activate()

   oDlgPrinc:Activate()

   if lConfirmado                                            // se a tela foi fechada pelo botao de confirmacao
      if len(aChaves)>0
         If nOpcTela==1 // Entrada
            If !lUsaPort
                  oProcess:=  MsNewProcess():New({|lEnd| ExecMATA140(aChaves,@oProcess,lEnd)}, "EZ4 GRC" , "Criando Notas de Entrada", .T.)
                  oProcess:Activate()
             Else
               For nX := 1 to Len(aChaves)
                  EZ0->(dbGoTo(aChaves[nX,2])) 
                  If Upper(EZ0->EZ0_TIPONF) == 'NFE'
                     IF EZ0->EZ0_STINTE $ "0|1|2|3|4"
                        VldDadosNF(aChaves[nX] )
                        If EZ0->EZ0_STINTE == '1'
                           EZ0->(RecLock('EZ0',.F.))
                           EZ0->EZ0_STINTE := ""
                           EZ0->(msUnlock())
                        Endif 
                        EZ0->( RecLock('EZ0',.F.))
                        EZ0->( EZ0_STIN() )  // atualiza o status
                        EZ0->(msUnlock())
                        If EZ0->EZ0_STINTE == '4' //.And. EZ0->EZ0_XMLOK == '1'
                           If ValidaCFOP() .or. EZ0->EZ0_TIPONF == "CTe"  // quando for CTE n�o passa pelo receb fisico
                              U_AndaProcesso("A",.f.)  // Gero o Documento
                           Else 
                              U_AndaProcesso("1",.f.) // Avanco o processo para a portaria
                           Endif 
                        Endif 
                     Endif 
                  Else
                     // Aqui serao tratados as NFS-e e CT-e quando o cliente tiver o modulo de portaria
                     U_AndaProcesso("A",.f.)
                  Endif 
               Next nX 
            Endif 
         ElseIf nOpcTela==3 // Conhecimento de Frete
            dbSelectArea("EZ1")
            EZ1->(dbSetOrder(1))
            EZ1->(dbSeek(xFilial("EZ1")+EZ0->EZ0_CHVNFE))
            If Upper(EZ0->EZ0_TIPONF) == 'CTE'
               IF EZ0->EZ0_STINTE $ "0|1|2|3|4|6"
                  aChaves := {}
                  aadd(aChaves,{EZ0->EZ0_CHVNFE,EZ0->(RECNO())})
                  VldDadosNF(aChaves[1] )
                  If EZ0->EZ0_STINTE == '1'
                     EZ0->(RecLock('EZ0',.F.))
                     EZ0->EZ0_STINTE := ""
                     EZ0->(msUnlock())
                  Endif 
                  EZ0->( RecLock('EZ0',.F.))
                  EZ0->( EZ0_STIN() )  // atualiza o status
                  EZ0->(msUnlock())
                  If EZ0->EZ0_STINTE $ '4|6'
                     // mudar a database e depois voltar a database
                     // ao gerar o CTE o sistema est� levando a DATA DE EMISSAO ERRADA - POR ISSO FOI ALTERAOD
                     // Carla Barbosa - 24/06/22
                     // em 14/12/2022 - validado com a mariana cardoso, a data base nao deve ser alterada
                     // pois a data de digitacao tem que ser a do dia do lan�amento
                     // utilizar ponto de entrada MT116GRV - PARA AJUSTAR A DATA DE EMISSAO
                     //oldDBase  := dDatabase 
                     //dDatabase := EZ0->EZ0_DTEMI  
                     MATA116()
                     //dDatabase := oldDBase
                     dbSelectArea("SF1")
                     SF1->(dbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
                     If SF1->(dbSeek(xFilial("SF1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNECE+EZ0_LOJA)))
                        EZ0->(RecLock('EZ0',.F.))
                        EZ0->EZ0_STINTE :=  '1'
                        EZ0->(msUnlock())
                     Else 
                        EZ0->(RecLock('EZ0',.F.))
                        EZ0->EZ0_STINTE :=  '4'
                        EZ0->(msUnlock())
                     Endif 
                  Endif 
               Endif 
            Endif 
         Else 
            //********************************************************************
            // OCP - Inicio
            // Marcio Martins - 22/08/2022
            //********************************************************************
            If SuperGetMV("EZ_PX_PVAU" ,.F.,.F.)
               lEZ3Erro := .F.
               cMSG := ""
               dbSelectArea("EZ2")
               EZ2->(dbSetOrder(1))
               EZ2->(dbSeek(xFilial("EZ2")+EZ0->EZ0_CHVNFE))
               While !EZ2->(Eof()) .And. xFilial("EZ2")+EZ0->EZ0_CHVNFE == EZ2->(EZ2_FILIAL+EZ2_CHVNFE)
                  If EZ2->EZ2_STATUS == '2'
                     If !"Informe o Depto Fiscal: " $ cMsg
                        cMsg += "Informe o Depto Fiscal: " + ENTER
                        cMsg += "Documento nr: "+ EZ0->EZ0_DOC + "-" + EZ0->EZ0_SERIE + ENTER
                     Endif 
                     cMsg += Alltrim(EZ2->EZ2_MSG) + ENTER             
                     lEZ3Erro    := .T.
                     EXIT 
                  Endif 
                  EZ2->(dbSkip())
               Enddo
               If !lEZ3Erro
                  dbSelectArea("SF2")
                  SF2->(dbSetOrder(1))
                  If SF2->(dbSeek(xFilial("SF2")+EZ0->EZ0_NUMNFE+EZ0->EZ0_SERIE))
                     If EZ0->EZ0_STINTE <> '1'
                        RecLock('EZ0',.F.)
                        EZ0->EZ0_STINTE := '1'
                        MsUnlock()
                     Endif 
                  Else 
                     // CARLA BARBOSA - SEMAFORO PARA CONTROLE DOS PEDIDOS DE VENDA
                     // 05/06/23
                     if BLQSEMAF(EZ0->EZ0_FILIAL,EZ0->EZ0_NUM,EZ0->EZ0_NUMNFE,EZ0->EZ0_SERNFE)
                        NFSaidaAuto(.F.) 
                        LIBSEMAF(EZ0->EZ0_FILIAL,EZ0->EZ0_NUM)
                     Endif 
                  Endif   
               Else
                  If !Empty(cMsg)
                      cMsg += "Documento nao foi gerado"
                      Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
                  Endif
               Endif 
               //NFSaidaAuto(.F.)
               //********************************************************************
               // OCP - Fim
               //********************************************************************
            Else
               aChavNFS := {}
               For nX := 1 to Len(aChaves)
                  aAdd(aChavNFS,aChaves[nX])
               Next nX 
               If Len(aChavNFS) > 0
                  oProcess:=  MsNewProcess():New({|lEnd| ExecMATA410(aChavNFS,@oProcess,lEnd,.F.)}, "EZ4 GRC" , "Gerando Pedidos", .T.)
                  oProcess:Activate()
               Endif 
            Endif
         Endif 
      Endif
   Endif

//   TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_MARK = '"+cMark+"'")  //limpa as marcacoes ao Sair.
   TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' ")  //limpa as marcacoes ao Sair.

   Raiz := 0 // Indica que a tela inicial volta a ficar ativa

Return

/*=====================================================================================================================================*/
// Verifica se as CFOP�s da nota estao no par�metro, se sim, gera documento de entrada sem passar pela portaria
/*=====================================================================================================================================*/
Static Function ValidaCFOP()

   Local lRet  := .F.
   Local cCFOP := Alltrim(SuperGetMV("EZ_CFGERNF",.F.,""))    // CFOP�s que irao gerar pre-nota e nao passam pela portaria

   If !Empty(cCFOP)
      EZ1->(dbSetOrder(1))
      EZ1->(dbSeek(xFilial("EZ1")+EZ0->EZ0_CHVNFE))
      While !EZ1->(Eof()) .and. xFilial("EZ1")+EZ0->EZ0_CHVNFE == EZ1->(EZ1_FILIAL+EZ1_CHVNFE)
         If !Empty(EZ1->EZ1_CF)
            If SubStr(Alltrim(EZ1->EZ1_CF),2,3)$cCFOP .And. !SubStr(Alltrim(EZ1->EZ1_CF),1,1)$'3/7'   // cCFOP - conteudo carregado no inicio do fonte
               lRet := .T. 
               Exit
            Endif 
         Endif 
         EZ1->(dbSkip())
      Enddo 
   Endif 

Return lRet 




/*=====================================================================================================================================*/
// executa o ExecAuto da MATA140 para gerar a Pre-nota
/*=====================================================================================================================================*/
Static Function ExecMATA140(aChaves,oProcess,lEnd)

   Local aCabec := {}, aItens := {}, aAux := {}, cCampo:=''
   Local i:=0, j:=0, k:=0, nC:=0, cMsg:=""
   Local lOkNota := .F.
   Local aAutoImp := {}
   Local cCFOP    := ""
   Local lImporta := .f.
   Local lFilha   := .f.
   Local nOpcao   := 3
   Local cHAWB    := ""
   Local cNFANT   := ""
   Local cSEANT   := ""
   Local cEzCompl := .f.
   Private lMsErroAuto := .F.
   Private lAutoErrNoFile := .T.
   Private lUsaPort   := SuperGetMV("EZ_USAPORT",.F.,.F.)
   Private _lPreNota  := SuperGetMV("EZ_PRENOTA",.F.,.T.)    // Versao que esta sendo utilizada
   Private lAtivaMan  := SuperGetMV("EZ_ATVMAN",.F.,.F.)    // Ativa o Manifesto para recusar documentos
   Private nVersion   := SuperGetMV("EZ_VERSION",.F.,0)    // Versao que esta sendo utilizada
   Private aGrcNf     := {}

   Default lSchedule  := FWGetRunSchedule()
   Default lXmlNora   := .F. 

   dbSelectArea("CB0")

   EZ1->(dbSetOrder(1))
   EZ2->(dbSetOrder(1))
   EZ3->(dbSetOrder(1))

   If !lSchedule
      oProcess:SetRegua1(Len(aChaves))
   Endif 

   for j:=1 to Len(aChaves)

      if lEnd
         cMsg += 'Processo interrompido por usuario'  + ENTER
         Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
         return
      Endif

      lConfirmado := .T.
      EZ0->(dbGoTo(aChaves[j,2]))                        // posiciona na EZ0

      
      // /
      /*/
      Carla Barbosa -18/08/2022
      Tratamento para Classific�o de Notas de Importa��o que n�o passaram pela primeira
      classifica��o. 
      */
      IF EZ1->(dbSeek(xFILIAL("EZ1")+EZ0->EZ0_CHVNFE))
         cCFOP  := EZ1->EZ1_CF
         if EZ1->(FieldPos("EZ1_CONHEC")) > 0 
            cHAWB := EZ1->EZ1_CONHEC
         Endif
      Endif  
      IF Substr(cCFOP,1,1) == "3" .and. !lUsaPort  
         // Faz tratamento se preciso alterar o N�mero da NF - Somente se o parametro
         // estiver como .T.
         IF EZ0->EZ0_TIPO == "N" .AND. ALLTRIM(cCFOP) == '3949' // NOTA FILHA
            //NAO PRECISA ALTERAR A NUMERACAO
            lFilha := .t. 
         Else
            if !Empty(cHAWB) .AND. SuperGetMV("EZ_NFTEMP",.F.,.f.)   
               // AJUSTANDO NF PRIMEIRA - // Acertando o n�mero da NF na SWN
               IF EZ0->EZ0_TIPO == "N"
                  SWN->(DbSetOrder(3))
                  if SWN->(DBSEEK( xFILIAL("SWN")+cHAWB +"1"))   // FILIAL + HAWB + TIPONF (1 - PRIMEIRA)
                     while SWN->(!EOF()) .AND. SWN->WN_HAWB == cHawb .AND. SWN->WN_TIPO_NF == '1'
                           cNFANT := SWN->WN_DOC
                           cSEANT := SWN->WN_SERIE
                           RecLock('SWN', .F.)                             
                           SWN->WN_DOC    := EZ0->EZ0_NUMNFE
                           SWN->WN_SERIE  := EZ0->EZ0_SERIE
                           SWN->WN_SDOC   := EZ0->EZ0_SERIE
                           MsUnlock()
                           SWN->(dbSkip())
                     Enddo
                  Endif
               Else
                  SWN->(DbSetOrder(3))
                  if SWN->(DBSEEK( xFILIAL("SWN")+cHAWB +"*"))   // FILIAL + HAWB + TIPONF (1 - PRIMEIRA)
                     while SWN->(!EOF()) .AND. SWN->WN_HAWB == cHawb .AND. SWN->WN_TIPO_NF == '*'
                           cNFANT := SWN->WN_DOC
                           cSEANT := SWN->WN_SERIE
                           RecLock('SWN', .F.)                             
                           SWN->WN_DOC    := EZ0->EZ0_NUMNFE
                           SWN->WN_SERIE  := EZ0->EZ0_SERIE
                           SWN->WN_SDOC   := EZ0->EZ0_SERIE
                           MsUnlock()
                           SWN->(dbSkip())
                           cEzCompl       := .t.
                     Enddo
                  Endif
               Endif
               // Acertando o n�mero da NF na 
               SWD->(DbSetOrder(1))
               if SWD->(DBSEEK( xFILIAL("SWD")+cHAWB ))
                  while SWD->(!EOF()) .AND. SWD->WD_HAWB == cHawb
                        If SWD->WD_NF_COMP == cNFANT .AND. SWD->WD_SE_NFC == cSEANT
                           RecLock('SWD', .F.)                             
                           SWD->WD_NF_COMP   := EZ0->EZ0_NUMNFE
                           SWD->WD_SE_NFC    := EZ0->EZ0_SERIE
                           SWD->WD_SDOC      := EZ0->EZ0_SERIE
                           SWD->WD_SDOCC     := EZ0->EZ0_SERIE
                           MsUnlock()
                        Endif
                        SWD->(dbSkip())
                  Enddo
               Endif                  
               // Acertando o n�mero da NF na SW6
               SW6->(DbSetOrder(1))
               if SW6->(DBSEEK( xFILIAL("SW6")+cHAWB ))
                  while SW6->(!EOF()) .AND. SW6->W6_HAWB == cHawb
                        If Alltrim(SW6->W6_NF_ENT) == Alltrim(cNFANT) .AND. Alltrim(SW6->W6_SE_NF) == Alltrim(cSEANT)
                           RecLock('SW6', .F.)                             
                           SW6->W6_NF_ENT   := EZ0->EZ0_NUMNFE
                           SW6->W6_SE_NF    := EZ0->EZ0_SERIE
                           SW6->W6_SDOC     := EZ0->EZ0_SERIE
                           MsUnlock()
                        Endif
                        IF EZ0->EZ0_TIPO <> "N" // Nota Complementar
                           RecLock('SW6', .F.) 
                           SW6->W6_NF_COMP   := EZ0->EZ0_NUMNFE
                           SW6->W6_SE_NFC    := EZ0->EZ0_NUMNFE
                           MsUnlock()
                        Endif
                        SW6->(dbSkip())
                  Enddo
               Endif 
               // Acertando o n�mero da NF na SF1
               SF1->(DbSetOrder(1))
               if SF1->(DBSEEK( xFILIAL("SF1")+cNFANT+cSEANT+EZ0->EZ0_FORNECE+EZ0->EZ0_LOJA ))
                  RecLock('SF1', .F.)     
                  if cEzCompl         
                     SF1->(dbDelete())  
                  Else             
                     SF1->F1_DOC   := EZ0->EZ0_NUMNFE
                     SF1->F1_SERIE := EZ0->EZ0_SERIE
                     SF1->F1_SDOC  := EZ0->EZ0_SERIE
                  Endif
                  MsUnlock()
               Endif 
               // Acertando o n�mero da NF na SD1
               SD1->(DbSetOrder(1))
               if SD1->(DBSEEK( xFILIAL("SD1")+cNFANT+cSEANT+EZ0->EZ0_FORNECE+EZ0->EZ0_LOJA ))
                  while SD1->(!EOF()) .AND. SD1->D1_DOC == cNFANT .AND. SD1->D1_SERIE == cSEANT .AND. ;
                        SD1->D1_FORNECE == EZ0->EZ0_FORNECE .AND. SD1->D1_LOJA == EZ0->EZ0_LOJA
                        RecLock('SD1', .F.)  
                        if cEzCompl      
                           SD1->(dbDelete())                     
                        Else
                           SD1->D1_DOC   := EZ0->EZ0_NUMNFE
                           SD1->D1_SERIE := EZ0->EZ0_SERIE
                           SD1->D1_SDOC  := EZ0->EZ0_SERIE                       
                        Endif
                        MsUnlock()
                        SD1->(dbSkip())
                  Enddo
               Endif                             
            Endif
            lImporta := .t.
            SF1->(DbSetOrder(1))
            IF SF1->(Dbseek(xFILIAL("SF1")+EZ0->EZ0_NUMNFE+EZ0->EZ0_SERIE+EZ0->EZ0_FORNECE+EZ0->EZ0_LOJA))                       
               //lRet = U_AndaProcesso("3")
               //LOOP
               nOpcao := 4     
            ENDIF 
         Endif
      ENDIF


      // XML de Entrada 
      If !lSchedule
         oProcess:IncRegua1("Gerando Documento "+ EZ0->EZ0_DOC+'-' + EZ0->EZ0_SERIE)
      Endif 
      cMsg += ENTER + '----------------------------------' + ENTER + ENTER
      cMsg += "Documento "+EZ0->EZ0_DOC+'-' + EZ0->EZ0_SERIE + ENTER

      if EZ0->EZ0_STINTE = '1' // Status de nf gerada Nao faz de novo
         lConfirmado := .F.
         RecLock("EZ0",.F.)
         EZ0->EZ0_STINTE := '1'
         MsUnlock()               
      Endif
      if lConfirmado
         If !lSchedule
            oProcess:SetRegua2(10)
            oProcess:IncRegua2("Verificando validacoes")
         Endif 
         EZ2->(dbCloseArea())
         If Select("EZ2") > 0
            dbSelectArea("EZ2")
         Endif
         EZ2->(dbSetOrder(1))
         EZ2->( dbseek( EZ0->(EZ0_FILIAL+EZ0_CHVNFE) ) )
         while EZ2->(EZ2_FILIAL+EZ2_CHVNFE) == EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
            if EZ2->EZ2_STATUS = '2'             // "1=Aviso;2=Erro;0=ok"
               If !"Informe o Depto Fiscal: " $ cMsg
                  cMsg += "Informe o Depto Fiscal: " + ENTER
               Endif 
               cMsg += Alltrim(EZ2->EZ2_MSG) + ENTER
               lConfirmado := .F.                // so executa o ExecAuto se Nao houver nenhuma restricao
            Endif
            EZ2->(dbSkip())
         Enddo
         if lConfirmado
            If !lSchedule
               oProcess:IncRegua2("Montagem de cabecario")		  // MONTA ARRAY COM CAMPOS DA SF
            Endif 
            cMsg += "validacoes sem restricoes "+ENTER
            aCabec:={}
            for i := 1 To EZ0->(FCount())
               cCampo := AchaField( AllTrim( EZ0->(FieldName(i))) , 2 )
               nPos  := SF1->(FieldPos(cCampo))
               if nPos > 0 .and. cCampo == "F1_CHVNFE" .and. !lImporta .and. !lFilha  // Carla Barbosa 22/08/2022
                           // Trecho acrescentado para n�o levar a Chave da NFE para as Notas de 
                           // Importa��o que n�o existem na SF1. 
                  if ! empty(EZ0->(FieldGet(i)))
                     aadd(aCabec, {cCampo,EZ0->(FieldGet(i)),,} )
                  endif
               ELSEIf nPos > 0 .and. cCampo <> "F1_FILIAL" .and. cCampo <>"F1_CHVNFE"
                  if ! empty(EZ0->(FieldGet(i)))
                     aadd(aCabec, {cCampo,EZ0->(FieldGet(i)),,} )
                  endif
              EndIf
            next
            // TRATATIVA DE CORRE�AO DAS NOTAS DA AUDIT - TIPO BENEFICAMENTO
            // GEDEON - NAO ESTAVA LOCALIZANDO O DOCUMENTO DE ORIGEM
            // Link tdn: https://tdn.totvs.com/pages/releaseview.action?pageId=235592777
            // CARLA BARBOSA 14/11/2022 
            if EZ0->EZ0_TIPO == "B" // Se for Devolu��o - Vou montar o aCabec de novo
               aCabec := {}
             
               aadd(aCabec,{"F1_DOC"      ,EZ0->EZ0_NUMNFE  ,NIL})
               aadd(aCabec,{"F1_SERIE"    ,EZ0->EZ0_SERNFE  ,NIL})
               aadd(aCabec,{"F1_FORNECE"  ,EZ0->EZ0_FORNEC  ,NIL})
               aadd(aCabec,{"F1_LOJA"     ,EZ0->EZ0_LOJA    ,NIL})
               aadd(aCabec,{"F1_EMISSAO"  ,EZ0->EZ0_EMISSA  ,NIL})
               aadd(aCabec,{"F1_DTDIGIT"  ,EZ0->EZ0_DTDIGI  ,NIL})
               aadd(aCabec,{"F1_TIPO"     ,EZ0->EZ0_TIPO    ,NIL})
               aadd(aCabec,{"F1_FORMUL"   ,EZ0->EZ0_FORMUL  ,NIL})
               aadd(aCabec,{"F1_ESPECIE"  ,EZ0->EZ0_ESPECI  ,NIL})
               aadd(aCabec,{"F1_COND"     ,EZ0->EZ0_COND    ,NIL})
               aadd(aCabec,{"F1_DESCONT"  ,EZ0->EZ0_DESCON  ,Nil})
               aadd(aCabec,{"F1_SEGURO"   ,EZ0->EZ0_SEGURO  ,Nil})
               aadd(aCabec,{"F1_FRETE"    ,EZ0->EZ0_FRETE   ,Nil})
               aadd(aCabec,{"F1_MOEDA"    ,EZ0->EZ0_MOEDA   ,Nil})
               aadd(aCabec,{"F1_TXMOEDA"  ,EZ0->EZ0_TXMOED  ,Nil})
               aadd(aCabec,{"F1_STATUS"   , " "             ,Nil})
               aadd(aCabec,{"F1_CHVNFE"   ,EZ0->EZ0_CHVNFE  ,Nil})
            Endif            
            If ExistBlock("PPXMLSF1")
               aCposUser := ExecBlock("PPXMLSF1", .F., .F.)
               If Len(aCposUser) > 0
                  For nC := 1 To Len(aCposUser)
                     AAdd(aCabec, aCposUser[nC])
                  Next nC
               EndIf
            EndIf   
            If !lSchedule
               oProcess:IncRegua2("Montagem de Itens")       // MONTA ARRAY COM CAMPOS DA SD1
            Endif 
            aItens := {}
            If Select("EZ1") > 0
               EZ1->(dbCloseArea())
            Endif
            dbSelectArea("EZ1")
            EZ1->(dbSetOrder(1))
            EZ1->( dbseek( EZ0->(EZ0_FILIAL+EZ0_CHVNFE) ) )
            while EZ1->(EZ1_FILIAL+EZ1_CHVNFE) == EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
               aAux := {}
               // TRATATIVA DE CORRE�AO DAS NOTAS DA AUDIT - TIPO BENEFICAMENTO
               // GEDEON - NAO ESTAVA LOCALIZANDO O DOCUMENTO DE ORIGEM
               // Link tdn: https://tdn.totvs.com/pages/releaseview.action?pageId=235592777
               // CARLA BARBOSA 14/11/2022 
                IF EZ0->EZ0_TIPO == "B" // VOU MONTAR O ARRAY NA MAO
                  aadd(aAux,{"D1_ITEM"       ,EZ1->EZ1_ITEM    ,NIL})
                  aadd(aAux,{"D1_COD"        ,EZ1->EZ1_COD     ,NIL})
                  aadd(aAux,{"D1_UM"         ,EZ1->EZ1_UM      ,NIL})
                  if !Empty(Alltrim(EZ1->EZ1_LOCAL))
                     aadd(aAux,{"D1_LOCAL"      ,EZ1->EZ1_LOCAL   ,NIL})
                  endif
                  if !Empty(Alltrim(EZ1->EZ1_LOTEFO))
                     aadd(aAux,{"D1_LOTEFOR"      ,EZ1->EZ1_LOTEFO   ,NIL})
                  endif
                  if !Empty(Alltrim(EZ1->EZ1_LOTECT))
                     aadd(aAux,{"D1_LOTECTL"      ,EZ1->EZ1_LOTECT   ,NIL})
                  endif  
                  if EZ1->EZ1_DTVALI <> ctod("  /  /  ")
                     aadd(aAux,{"D1_DTVALID"    ,EZ1->EZ1_DTVALI   ,NIL})
                  Endif
                  aadd(aAux,{"D1_QUANT"      ,EZ1->EZ1_QUANT   ,NIL})
                  aadd(aAux,{"D1_VUNIT"      ,EZ1->EZ1_VUNIT   ,NIL})
                  aadd(aAux,{"D1_TOTAL"      ,EZ1->EZ1_TOTAL   ,NIL})
                  if !Empty(Alltrim(EZ1->EZ1_NFORI))
                     aadd(aAux,{"D1_NFORI"      ,EZ1->EZ1_NFORI   ,NIL})
                     aadd(aAux,{"D1_SERIORI"    ,EZ1->EZ1_SERIOR  ,NIL})
                     aadd(aAux,{"D1_ITEMORI"    ,EZ1->EZ1_ITEMOR  ,NIL})
                     aadd(aAux,{"D1_IDENTB6"    ,EZ1->EZ1_IDB6    ,NIL})
                  Endif
                  if !_lPreNota
                     aadd(aAux,{"D1_TES"        ,EZ1->EZ1_TES     ,NIL})   
                  Endif
               Else
               If nVersion == 0 
                  for i := 1 To EZ1->(FCount())
                     cCampo := AchaField( AllTrim( EZ1->(FieldName(i))), 2 )
                     nPos  := SD1->(FieldPos(cCampo))
                     If nPos > 0 .and. cCampo <> "F1_FILIAL"
                        if !empty(EZ1->(FieldGet(i)))
                            aadd(aAux, {cCampo , EZ1->(FieldGet(i)) ,, } )
                        Endif
                     EndIf
                  next
               Else 
                  aadd(aAux, {"D1_ITEM" , EZ1->EZ1_ITEM ,, } ) // correcao para o chave duplicada da CD2
                  for i := 1 To SD1->(FCount())
                     cCampod1 := SD1->(FieldName(i))
                     cCampo := AchaField( AllTrim( SD1->(FieldName(i))), 1 )
                     nPos  := EZ1->(FieldPos(cCampo))
                     If nPos > 0 .and. !Alltrim(cCampo) $ "D1_FILIAL|D1_ITEM"
                        if !empty(EZ1->&(cCampo))
                           aadd(aAux, {cCampod1 , EZ1->&(cCampo) ,, } )
                        Endif                        
                     EndIf
                  next                   
               Endif 
               
               If EZ1->(FieldPos("EZ1_BRICMS")) > 0 .And. EZ1->(FieldPos("EZ1_ICMSRE")) > 0 
                  If !Empty(EZ1->EZ1_BRICMS) .And. !Empty(EZ1->EZ1_ICMSRE)
                     aAdd(aAutoImp,{'IT_BASESOL', EZ1->EZ1_BRICMS,Val(EZ1->EZ1_ITEM) })
                     aAdd(aAutoImp,{'IT_VALSOL' , EZ1->EZ1_ICMSRE,Val(EZ1->EZ1_ITEM) })
                     Endif
                  Endif
               Endif 
               
               // Ponto de entrada Criado para Crown
               If ExistBlock("PPXMLSD1")
                  aCposUser := ExecBlock("PPXMLSD1", .F., .F.)
                  If Len(aCposUser) > 0
                     For nC := 1 To Len(aCposUser)
                        AAdd(aAux, aCposUser[nC])
                     Next nC
                  EndIf
               EndIf       
               If nVersion == 0 
                  if EZ0->EZ0_TIPO <> "B"
                     Aux := FWVetByDic(aAux,"SD1",.F.,1)
                  Endif
               Endif 
               aadd(aItens,aAux)     
               EZ1->(dbSkip())
            enddo 
            //Verifica se o conjunto minimo de campos esta presente para evitar dump na execauto
            If !lSchedule
               oProcess:IncRegua2("Verificacao de conjunto minimo preenchido")
            Endif 
            cMsg += "Verificacao se o conjunto minimo de campos foi preenchido"+ENTER
            //campos da SF1
            //aAux:={'F1_TIPO','F1_DOC','F1_SERIE','F1_EMISSAO','F1_FORNECE','F1_LOJA','F1_DTDIGIT'}
            aAux:={'F1_TIPO','F1_DOC','F1_EMISSAO','F1_FORNECE','F1_LOJA','F1_DTDIGIT'}
            for i:= 1 to len(aAux)
               if AScan( aCabec, {|x| x[1]=aAux[i]} ) == 0 // campo obrigatorio Nao encontrado
                  If !"Informe o Depto Fiscal: " $ cMsg
                     cMsg += "Informe o Depto Fiscal: " + ENTER
                  Endif 
                  cMsg += Alltrim(EZ2->EZ2_MSG) + ENTER
                  lConfirmado:= .f.
                  cMsg += "O campo "+AVSX3(aAux[i],5)+" Nao foi preenchido"+ENTER
               endif
            next
            // campos da SD1
            aAux:={'D1_ITEM','D1_COD','D1_UM','D1_VUNIT','D1_TOTAL' }
            for k:=1 to len(aItens)
               for i:= 1 to len(aAux)
                  if AScan( aItens[k],{|x|  x[1] = aAux[i]} ) == 0
                     If !"Informe o Depto Fiscal: " $ cMsg
                        cMsg += "Informe o Depto Fiscal: " + ENTER
                     Endif 
                     cMsg += Alltrim(EZ2->EZ2_MSG) + ENTER                  
                     lConfirmado:= .f.
                     cMsg += "O campo "+AVSX3(aAux[i],5)+" Nao foi preenchido"+ENTER
                  endif 
               next
            next
 
            if lConfirmado
               
               If nVersion == 0 
                  IF EZ0->EZ0_TIPO <> "B"
                     aCabec := FWVetByDic(aCabec, "SF1")
                  Endif
               Endif

               Begin Transaction

                  cMsg += "O conjunto minimo de campos foi preenchido"+ENTER
                  If !lSchedule
                     oProcess:IncRegua2("Criacao da Pre-Nota") // Cria a Pre nota
                  Endif
                  If _lPreNota
                     If !lSchedule
                        //MsgRun("Gerando Pre-Nota","Processando",{|| MATA140(aCabec,aItens,3)})
                        MsgRun("Gerando Pre-Nota","Processando",{|| MsExecAuto({|x,y,z,a|Mata140(x,y,z,a)}, aCabec, aItens, nOpcao)})
                     Else                           
                        MsExecAuto({|x,y,z,a|Mata140(x,y,z,a)}, aCabec, aItens, nOpcao)                           
                     Endif 
                     RecLock("EZ0",.F.)
                     EZ0->EZ0_STINTE := '1'
                     MsUnlock()
                  Else
                     // Correspoonde ao Visualizacao da contabilizacao
                     SX1->(dbSetOrder(1))
                     SX1->(dbSeek("MTA103    01"))
                     RecLock("SX1",.F.)
                     SX1->X1_PRESEL := 2
                     MsUnlock()
                     
                     // Correspoonde ao Bloqueio Documento de Entrada
                     SX1->(dbSetOrder(1))
                     SX1->(dbSeek("MTA103    17"))
                     RecLock("SX1",.F.)
                     SX1->X1_PRESEL := 2
                     MsUnlock()

                     Pergunte("MTA103", .F.)
                     MV_PAR01 := "2"  // Mostra contabilizacao -> 2-Nao
                     MV_PAR17 := 2  // Bloqueia Mov. Usado na importacaodaniela.santos
                     lMsErroAuto := .F.
                     If !lSchedule
                        MsgRun("Gerando Documento de Entrada","Processando",{|| MsExecAuto({|x,y,z,a|MATA103(x,y,z,a)}, aCabec, aItens, nOpcao)})
                        //MsgRun("Gerando Documento de Entrada","Processando",{|| MsExecAuto({|x,y,z,a|U_xMATA103(x,y,z,,a)},aCabec,aItens,3,aAutoImp) })
                     Else 
                        MsExecAuto({|x,y,z,a|MATA103(x,y,z,a)}, aCabec, aItens, nOpcao)
                        //MsExecAuto({|x,y,z,a|MATA103(x,y,z,,a)},aCabec,aItens,3,aAutoImp)
                     Endif 
                  Endif 
                  if len(aGrcNf)==0 .and. !lMsErroAuto // Documento N�o foi gerado
                     If lSchedule
                        cMsg  += "Houve erro na Execu��o do ExecAuto " + CRLF
                        cMsg  += "Documento n�o foi gerado. Por favor Verifique" +  CRLF
                        Conout("Documento nao foi gerado! Por favor verifique")
                        lConfirmado := .F.
                        lOkNota := .F.
                     else
                        cMsg  += "Houve erro na Execu��o do ExecAuto " + CRLF
                        cMsg  += "Documento n�o foi gerado. Por favor Verifique" +  CRLF
                        lConfirmado := .F.
                        lOkNota := .F.
                     endif
                     RecLock("EZ0",.F.)
                     EZ0->EZ0_STINTE := "4"                       
                     MsUnlock()
                  ElseIf lMsErroAuto                  
                     lConfirmado := .F.
                     aErro := GetAutoGRLog()
                     For i := 1 To Len(aErro)
                        cMsg += aErro[i] + Chr(13) + Chr(10)
                     Next i
                     If lUsaPort
                        U_RegLogUser("C")
                     Endif
                     
                     If lSchedule
                        
                        //--------------------------------------------------------------------------------
                        // M�rcio Martins - 23/04/2022
                        // Exclusivo para o processos automaticos enviando o log de erro do execauto
                        //--------------------------------------------------------------------------------

                           cGRPPIA:= SuperGetMV("EZ_GRPPIA",.F.,"")
                           If !Empty(cGRPPIA) .And. '110' $ cGRPPIA

                              cMsgExec := ''
                              For i := 1 To Len(aErro)
                                 cMsgExec += aErro[i] + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                              Next i
                              
                              aDados    := {}
                              aArquivos := {}
                              cEmails   := ""
                              cGrupo := "110"
                              dbSelectArea("EZ8")
                              EZ8->(dbSetOrder(2))
                              EZ8->(dbSeek(xFilial("EZ8")+cGrupo ))
                              While !EZ8->(Eof()) .And. xFilial("EZ8")+cGrupo == EZ8->(EZ8_FILIAL+EZ8_CODIGO)
                                 cEmails += Alltrim(EZ8->EZ8_EMAIL)+";"
                                 EZ8->(dbSkip())
                              Enddo
                              
                              dbSelectArea("SA2")
                              SA2->(dbSetOrder(1))
                              SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
                              cFornec := EZ0->EZ0_FORNEC+"/"+EZ0->EZ0_LOJA+" "+Alltrim(SA2->A2_NOME)     

                              aAdd(aDados, 5)                                                               // 1  Opcao para sele��o do workflow
                              aAdd(aDados, EZ0->EZ0_NUMNFE)                                                 // 2  N�mero da nota
                              aAdd(aDados, cEmails)                                                         // 4  E-mails do grupo
                              aAdd(aDados, SM0->M0_FILIAL)                                                  // 5  Planta
                              aAdd(aDados, cFornec)                                                         // 6  Codigo/loja/Nome Cliente
                              aAdd(aDados, "MOTIVOS: " + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + Alltrim(cMsgExec))                                  // 8  Motivo da ocorr�ncia

                              fEnvEmail(aDados, aArquivos)
                           
                           Endif 

                        //--------------------------------------------------------------------------------
                        //--------------------------------------------------------------------------------

                     Endif 
                     DisarmTransaction()
                     lOkNota := .F.
                  Else 
                     If lUsaPort
                        U_RegLogUser("B")
                     Endif
                     RecLock("EZ0",.F.)
                     If _lPreNota
                           EZ0->EZ0_STINTE := "7"
                           cMsg += "Pre nota gerada com sucesso"+ENTER
                     Else
                           EZ0->EZ0_STINTE := '5'
                           cMsg += "Documento gerado com sucesso"+ENTER
                     Endif                            
                     MsUnlock()                           
                     If Upper(EZ0->EZ0_TIPONF) == "NFE" .and. lAtivaMan
                           U_ManifChave(EZ0->EZ0_CHVNFE,"210200") // 210200 - Confirmacao da Operacao
                     Endif 
                     lOkNota := .T.

                        // 21/02/2023 - CARLA BARBOSA
                        // Cria��o de Ponto de Entrada para tratamento ap�s grava��o da NF Entrada
                        // SF1 - POSICIONADA
                        If ExistBlock("PPFIMSF1")
                           ExecBlock("PPFIMSF1", .F., .F.)
                        Endif

                  Endif 
                  
               End Transaction

            Else
                  cMsg += ENTER+" campos basicos Nao preenchidos"+ENTER
            Endif
         Else
            cMsg += "Existem restricoes de validacao. "+ENTER
            cMsg += "Documento Nao foi gerada. "+ENTER
         endif
      Else
         cMsg += "Documento gerada em processamento anterior"+ENTER
         cMsg += "nenhuma acao foi executada"+ENTER
      endif
      If !IsInCallStack("U_ALMOX")
         EZ0->( RecLock('EZ0',.f.))
         EZ0->( EZ0_STIN() )  // atualiza o status
         EZ0->( msUnlock() )
      Endif

   next j
  
   If !lConfirmado .And. !Empty(cMsg)
      If !lSchedule
         If !lOkNota
            if !lXmlNora
               Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
            Endif
         Endif 
      else
         Conout(cMsg)
      Endif 
   Endif 

Return lConfirmado

/*=====================================================================================================================================*/
// Realiza o encerramento da Dialog
/*=====================================================================================================================================*/
user Function FechaDlg(Status,aChaves)

Default aChaves := {}
  lConfirmado := Status
  if lConfirmado .and. lUsaOCR  
     u_EzFake(aChaves)
  Endif
  oDlgPrinc:end()

return

User Function EZFake(aChaves)
Local nX := 0
         
Local cChvBus
if len(aChaves)>0
   for nX := 1 to len(aChaves)
       cChvBus := aChaves[nX][1]
       EZ0->(dbseek(xFilial("EZ0")+cChvBus))

      IF EZ0->EZ0_TIPONF == "NFO"
         SA2->(dbsetOrder(1))
         IF SA2->(dbSeek(xFilial("SA2")+EZ0->EZ0_FORNEC+EZ0->EZ0_LOJA))
            cCNPJFOR := SA2->A2_CGC
            If cCNPJFOR <> EZ0->EZ0_CNPJOR // <> EZ0->EZ0_CNPJEM .OR. EZ0->EZ0_TIPONF == "NFO" // ver se  o tipo � NFO
               // atualiza o CNPJ Fake do Fornecedor
               SA2->(RecLock("SA2",.F.))
               SA2->A2_CGCFK := EZ0->EZ0_CNPJOR
               SA2->(MsUnLock())
               // Atualiza o CNPJ da EZ0 tbm
               EZ0->(Reclock("EZ0"),.F.)
               EZ0->EZ0_CNPJEM := cCNPJFOR
               EZ0->(msUnlock())
            Endif
       Endif
      Endif
   next
endif

Return

/*=====================================================================================================================================*/
// Funcao para a extrair dados do XML para as tabelas EZ0 e EZ1
/*=====================================================================================================================================*/
Static Function ExtraiDadosXML( aNF, cTipoNF )    // aNF == { Chave da NE, recno da EZ0 }

   Local cXML := "", nPos:=0, i:=0
   Local /*cInstrucao :="",*/ cCampo:=''
   Local aGrupos:= {}, aItens := {},cNumItem:='',cItem:=''
   Local cQry := "", cXMLaux:=""
   Local cChvNFe := ""
   //Local aTipos := &(SuperGetMV("EZ_PX_CHV",.f.,'{ {"infNFE","Id"}, {"infCte","Id"}, {"infCFe","Id"} }')) 
   Local aTipos := &(SuperGetMV("EZ_PX_CHV",.f.,'{ {"infNFE","Id", ""}, {"infCte","Id", ""}, {"infCFe","Id", ""}, {"infNFSe","Id", ""}, {"<INT164_TBCP>","OrderNumber","TransactionType"}, {"extraction","chave_nota", ""} }')) 
   
   Local lIntGFE:= SuperGetMV("MV_INTGFE" ,.F.,.F.) 

   Private xCont:= "", cType:="U"
   Private lXmlNora := .f.

   Default cTipoNF:=""

    

   EZ0->(dbGoTo(aNF[2]))                                // posiciona na EZ0
   cXML := EZ0->EZ0_XMLNFE                              // recupera o xml

   if !empty( cXML )                                     // se Nao tem xml
      // tipo de Nota fiscal
      while i< len(aTipos) .and. empty(cChvNFe)
         i++
         if  aTipos[i,1] == '<INT164_TBCP>' .and. lUsaAS400
            lXmlAs400 := .t.
         Else
            lXmlAs400 := .f.
         Endif
          if lXmlAs400
            cChvNFe      := XMLTagCont(aTipos[i,2],cXML)
            cTipoAs400   := XMLTagCont(aTipos[i,3],cXML) 
          else
             cCHVNFE := XMLTagAtrib( aTipos[i,1], aTipos[i,2] , cXML )
         endif
         if aTipos[i,1] == 'infNFSe' .or. aTipos[i,1] == '<INT164_TBCP>'
            lMuda := .t.
         Endif
         if  aTipos[i,1] == "extraction" 
            cChvNFe      := XMLTagCont(aTipos[i,2],cXML)
            lXmlNora     := .t.
         Endif
      enddo
      if empty(cChvNFe) .and. !empty(aNF)
         cChvNFe := aNF[1]
      Endif
      if !empty(cChvNFe)
         if Empty(Alltrim(cTipoNF))
            cTipoNF := substr(cChvNFe,1,3)
         Endif
         If cTipoNF <> 'NFn' .and. cTipoNF <> 'NFa'
            cChvNFe := substr(cChvNFe,4)
         Elseif lMuda .and. aTipos[i,1] == '<INT164_TBCP>' .and. !(cTipoNF$"NFn#NFa")
            cTipo   := cTipoAs400    
            cChvNFe := XMLTagCont(aTipos[i,2],cXML) 
         Endif 
         // DADOS DE CABEcARIO
         cQry:=" select R_E_C_N_O_ as EZ4RECNO, EZ4_ORDEM from "+ RetSqlName('EZ4')     // View Nao traz campo memo
         cQry+=" where D_E_L_E_T_ <> '*' "
         cQry+="   and ( EZ4_CAMPO LIKE 'F1_%' or EZ4_CAMPO LIKE 'EZ0_%') "
         cQry+="   and upper(EZ4_TIPONF) = '"+upper(cTipoNF)+"' "
         cQry+="   and EZ4_ATIVA = '1' "
         cQry+=" order by EZ4_ORDEM "
         AbreQuery(cQry,"QRYEZ4")

         EZ0->( RecLock('EZ0',.F.) )// bloqueia o registro para edicao
         EZ0->EZ0_TIPONF := cTipoNF
         EZ0->EZ0_CHVNFE := cChvNFe
         if lXmlAs400
            cOrderType := XMLTagCont('OrderType', cXML)
            cCliente   := XMLTagCont('CustomerCode', cXML)
            cInvDate  := XMLTagCont('InvoiceDate',cXML) 
            AbreAs400(cOrderType,cChvNFe,cCliente,cInvDate)
         else
            if !lXmlNora
               AbreChv(cCHVNFE)
            Endif
         Endif
         While QRYEZ4->( !Eof() )
            EZ4->(dbGoTo( QRYEZ4->EZ4RECNO ) )
            cCampo:= AchaField(EZ4->EZ4_CAMPO , 1 )
            nPos  := EZ0->(FieldPos(cCampo))
            bOldBlock := ErrorBlock({||  })
            begin sequence
            If nPos > 0                                                                                                // se existe o campo na tabela
               EZ0->( FieldPut(nPos,xConteudo(EZ4->EZ4_TAGPRE, EZ4->EZ4_TAG, EZ4->EZ4_ACAO, cXML,ValType( &cCampo))))  // insere o dado na tabela
            endif
            end sequence
            ErrorBlock(bOldBlock)
            QRYEZ4->(dbSkip())
         Enddo 
         QRYEZ4->(dbCloseArea())
         EZ0->(msUnlock())

         // DESCOBERTA DE AGRUPAMENTOS
         cQry:="select distinct UPPER(EZ4_TAGGRU) EZ4_TAGGRU, UPPER(EZ4_ATRGRU) EZ4_ATRGRU from "+ RetSqlName('EZ4')
         cQry+=" where D_E_L_E_T_ <> '*' "
         cQry+="   and ( EZ4_CAMPO LIKE 'D1_%' or EZ4_CAMPO LIKE 'EZ1_%') "
         cQry+="   and upper(EZ4_TIPONF) = '"+upper(cTipoNF)+"' "
         cQry+="   and EZ4_ATIVA = '1' "
         cQry+="   and EZ4_TAGGRU > '' "
         AbreQuery(cQry,"QRYEZ4")
         While QRYEZ4->( !Eof() )
                                    // TAG DE ITEM,     ATRIBUTO DO NUMERO DO ITEM
            QRYEZ4->(aadd( aGrupos, { AllTrim(EZ4_TAGGRU),AllTrim(EZ4_ATRGRU)} ))
            QRYEZ4->(dbSkip())
         Enddo 
         QRYEZ4->(dbCloseArea())
         // Itens = repeticoes da tag de agrupamento numeradas pelo atributo
         aItens := {}
         if cTipoNF == "NFa"
            aItens:={{'0001',cXML}}
         else
            if lXmlAs400
               if len(aGrupos)>0
                  cXMLaux := cXML
                  for i:= 1 to len(aGrupos)
                     //cXMLaux := cXML
                     while  !empty(cItem)
                        cItem := XMLTagCompl( aGrupos[i,2] , cXMLaux )  
                        cNumItem   := Strzero(val(XMLTagCont("LineNumber", cXMLaux)),4)
                        aAdd(aItens,{cNumItem,cItem}) 
                        cItemAux := "<LineNumber>"+XMLTagCont("LineNumber", cXMLaux)+"<\LineNumber>"
                        cXMLaux:= StrTran(cXMLaux, cItem ,"")       // Elimina o item do XML para evitar repeticoes
                        cItem := XMLTagCompl( aGrupos[i,2] , cXMLaux )  
                     enddo 
                  next i
               else
                  aItens:={{'0001',cXML}} // se Nao existe tag de agrupamento a NF so tem 1 item
               endif
            Else
               if len(aGrupos)>0
                  for i:= 1 to len(aGrupos)
                     cXMLaux := cXML
                     cItem := XMLTagCompl( aGrupos[i,1] , cXMLaux )                                       // busca pelo primeiro
                     while !empty(cItem)
                        cNumItem := StrZero(val(XMLTagAtrib( aGrupos[i,1], aGrupos[i,2] , cItem )) ,4 ) // numero do item
                        If cNumItem <> "0000"   // Marcio Martins - 28/08/2023 - // Corre��o do problema de item com c�digo '0000'
                           aAdd(aItens,{cNumItem,cItem})                                                  // guarda o item
                        Endif 
                        cXMLaux:= StrTran(cXMLaux, cItem ,"")                                          // Elimina o item do XML para evitar repeticoes
                        cItem := XMLTagCompl( aGrupos[i,1] , cXMLaux )                                 // busca o proximo item
                     enddo 
                  next i
               else
                  aItens:={{'0001',cXML}} // se Nao existe tag de agrupamento a NF so tem 1 item
               endif
            Endif
         Endif

         // DADOS DE ITENS
         cQry:=" select R_E_C_N_O_ as EZ4RECNO, EZ4_ORDEM from "+ RetSqlName('EZ4')               // View Nao traz campo memo
         cQry+=" where D_E_L_E_T_ <> '*' "
         cQry+="   and ( EZ4_CAMPO LIKE 'D1_%' or EZ4_CAMPO LIKE 'EZ1_%') "
         cQry+="   and upper(EZ4_TIPONF) = '"+upper(cTipoNF)+"' "
         cQry+="   and EZ4_ATIVA = '1' "
         cQry+=" order by EZ4_ORDEM "
         AbreQuery(cQry,"QRYEZ4")
         for i:= 1 to len( aItens )                                       // para cada item encotrado
            EZ0->(dbGoTo(aNF[2]))
            If Select("EZ1") > 0
               EZ1->(dbCloseArea())
            Endif
            dbSelectArea("EZ1")
            EZ1->(dbSetOrder(1))	                                      // garantir o posicionamento
            if EZ1->( dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)+aItens[i,1] ) )
               EZ1->( RecLock('EZ1',.F.) )                               // bloqueia para edicao
            else
               EZ1->( RecLock('EZ1',.T.) )// cria um novo registro
            endif
            QRYEZ4->(dbGoTop())
            While QRYEZ4->( !Eof() )
               EZ4->(dbGoTo( QRYEZ4->EZ4RECNO ) )
               cCampo:= AchaField(EZ4->EZ4_CAMPO , 1 )
               nPos  := EZ1->(FieldPos(cCampo))
               If nPos > 0                                                                                                // se existe o campo na tabela
                  cXMLaux:= if( empty(EZ4->EZ4_TAGGRU), cXML, aItens[i,2])
                  EZ1->( FieldPut(nPos,xConteudo(EZ4->EZ4_TAGPRE, EZ4->EZ4_TAG, EZ4->EZ4_ACAO, cXMLaux,ValType( &cCampo))))  // insere o dado na tabela
               endif
               QRYEZ4->(dbSkip())
            Enddo 
            EZ1->EZ1_FILIAL := EZ0->EZ0_FILIAL
            EZ1->EZ1_CHVNFE := EZ0->EZ0_CHVNFE
            EZ1->EZ1_ITEM   := aItens[i,1]
            EZ1->(msUnlock())
         next i 
         QRYEZ4->(dbCloseArea())

         // DADOS DE CABEcARIO - 05/04/2021 - FOI NECESSaRIO, Ha REGRAS QUE USAM CFOP
         cQry:=" select R_E_C_N_O_ as EZ4RECNO, EZ4_ORDEM from "+ RetSqlName('EZ4')     // View Nao traz campo memo
         cQry+=" where D_E_L_E_T_ <> '*' "
         cQry+="   and ( EZ4_CAMPO LIKE 'F1_%' or EZ4_CAMPO LIKE 'EZ0_%') "
         cQry+="   and upper(EZ4_TIPONF) = '"+upper(cTipoNF)+"' "
         cQry+="   and EZ4_ATIVA = '1' "
         cQry+=" order by EZ4_ORDEM "
         AbreQuery(cQry,"QRYEZ4")

         EZ0->( RecLock('EZ0',.F.) )// bloqueia o registro para edicao
         If cTipoNF <> 'NFn'  .and. cTipoNF <> 'NFa'
            if Alltrim(cTipoNF) $ 'NFe#CTe#NFs#CFe'
               AbreChv(cCHVNFE)
            Endif
         Endif
         While QRYEZ4->( !Eof() )
            EZ4->(dbGoTo( QRYEZ4->EZ4RECNO ) )
            cCampo:= AchaField(EZ4->EZ4_CAMPO , 1 )
            nPos  := EZ0->(FieldPos(cCampo))
            If nPos > 0                                                                                                // se existe o campo na tabela
               EZ0->( FieldPut(nPos,xConteudo(EZ4->EZ4_TAGPRE, EZ4->EZ4_TAG, EZ4->EZ4_ACAO, cXML,ValType( &cCampo))))  // insere o dado na tabela
            endif
            QRYEZ4->(dbSkip())
         Enddo 
         QRYEZ4->(dbCloseArea())
         EZ0->(msUnlock())

         If lIntGFE .And. Upper(cTipoNF) == "CTE"
            U_CTECopy(2)   // Copia Especifico posicionado
         Endif

      endif
   endif

   If lIntGFE .And. Upper(cTipoNF) == "CTE"
      // Nao realizo nenhuma acao / aqui eu mantenho o EZ0_STINTE = '8'
   Else 
      EZ0->( RecLock('EZ0',.f.))   
      EZ0->( EZ0_STIN() )  // atualiza o status
      EZ0->( msUnlock() )
   Endif 
   
return

/*=====================================================================================================================================*/
// Retorna o conteudo do XML conforme as TAGs
/*=====================================================================================================================================*/
Static function xConteudo(cTagPre, cTAG, cInstrucao , cXML, cType)

   Private xCont := ""
   Default cTagPre:= ""

   cXML := XML_Limpa( cXML )
   cXML := if( empty(cTagPre) , cXML , XMLTagCont( cTagPre , cXML ) )
   xCont := XMLTagCont( cTag , cXML )

   cInstrucao := AllTrim( cInstrucao )
   cInstrucao := StrTran(cInstrucao, chr(10),"") // Elimina possibilidade de erro
   cInstrucao := StrTran(cInstrucao, chr(13),"") // Elimina possibilidade de erro

   If ! Empty(cInstrucao)    // existe Acao
      TRYEXCEPTION
      cInstrucao := "{|| "+cInstrucao+" }"
      xCont := EZ0->( Eval( &cInstrucao ) )
      CATCHEXCEPTION USING oErroTry
      Aviso( "EZ4 GRC" ,cInstrucao+ENTER+oErroTry:Description+ENTER+oErroTry:ErrorStack, {"OK"}, 3,"Criacao de Documento")
      xCont := ""
      ENDEXCEPTION NODELSTACKERROR
   endif 

   // O Ajuste do tipo de dado a ser gravado deve ser realizado no campo ACAO.
   if empty(xCont) .or. ValType(xCont) != cType
      do case               // acerto de tipo para campos
         case cType = "D"   // tipo data
            xCont := Ctod("  /  /    ")
         case cType = "N"   // tipo numerico
            xCont := 0
         otherWise
            xCont := "" 
      EndCase
   endif

return xCont 

/*=====================================================================================================================================*/
// Encontra o campo a ser utilizado conforme parametros
/*=====================================================================================================================================*/
static Function AchaField(cEZCampo, nDirecao )

   Local  cTitulo := ''
   //Local  xCampo := cEZCampo
   
   // Busca o titulo do campo nas tabelas EZ
   SX3->(dbSetOrder(2)) // X3_CAMPO
   SX3->( dbSeek(cEZCampo))
   cTitulo := SX3->X3_TITULO
   if nDirecao = 2
      // converte o campo para a tabela de origem SF/SD
      If EZ0->EZ0_ACAO == "0" //nf=Entrada 
         cEZCampo :=StrTran(cEZCampo,"EZ0","F1")
         cEZCampo :=StrTran(cEZCampo,"EZ1","D1")
      Else
         cEZCampo :=StrTran(cEZCampo,"EZ0","C5")
         cEZCampo :=StrTran(cEZCampo,"EZ1","C6")
      Endif 
   else
      // converte o campo para a tabela do Portal EZ0/EZ1
      cEZCampo :=StrTran(cEZCampo,"F1","EZ0")
      cEZCampo :=StrTran(cEZCampo,"D1","EZ1")
      cEZCampo :=StrTran(cEZCampo,"C5","EZ0")
      cEZCampo :=StrTran(cEZCampo,"C6","EZ1")
   endif

   cEZCampo :=left(cEZCampo,10)   // 8
   //Busca na SX3 o campo com o mesmo titulo
   if SX3->( dbSeek(cEZCampo))
      while left(SX3->X3_CAMPO,10) = cEZCampo // 8 
         if cTitulo = SX3->X3_TITULO
            cEZCampo := SX3->X3_CAMPO
         endif
         SX3->( dbSkip())
      end
   endif

return AllTrim(cEZCampo)

/*=====================================================================================================================================*/
// Funcao para a validar os dados da NF
/*=====================================================================================================================================*/
Static Function VldDadosNF( aNF )

   Local cQry:=''

   EZ0->(dbGoTo(aNF[2]))        // posiciona na EZ0
   EZ1->(dbSetOrder(1))
   EZ2->(dbSetOrder(1))
   tcSqlExec("delete from "+ RetSqlName('EZ2')+" where EZ2_CHVNFE = '"+EZ0->EZ0_CHVNFE+"'")

   // regras de cabecario
   cQry:=" select R_E_C_N_O_ as EZ3RECNO, EZ3_ORDEM from "+ RetSqlName('EZ3')
   cQry+=" where D_E_L_E_T_ <> '*' "
   cQry+="   and EZ3_FILIAL = '" + xFilial("EZ3") + "' "
   cQry+="   and EZ3_ABRAN = '1' "     // cabecario
   cQry+="   and upper(EZ3_TIPONF) = '"+upper(EZ0->EZ0_TIPONF)+"' "
   cQry+="   and EZ3_ATIVA = '1' "
   cQry+="   order by EZ3_ORDEM "
   AbreQuery(cQry,"QRYEZ3")
   While QRYEZ3->( !Eof() )
         EZ3->(dbGoTo( QRYEZ3->EZ3RECNO ) )
         EZ0->(ExecRegra(EZ0->EZ0_FILIAL,EZ0->EZ0_CHVNFE,'cab.'))
         QRYEZ3->(dbSkip())
   enddo 

   // Regras de itens
   cQry:="select R_E_C_N_O_ as EZ3RECNO, EZ3_ORDEM from "+ RetSqlName('EZ3')
   cQry+=" where D_E_L_E_T_ <> '*' "
   cQry+="   and EZ3_FILIAL = '" + xFilial("EZ3") + "' "
   cQry+="   and EZ3_ABRAN = '2' "     // Itens
   cQry+="   and upper(EZ3_TIPONF) = '"+upper(EZ0->EZ0_TIPONF)+"' "
   cQry+="   and EZ3_ATIVA = '1' "
   cQry+="   order by EZ3_ORDEM "
   AbreQuery(cQry,"QRYEZ3")
   While QRYEZ3->( !Eof() )
         EZ3->(dbGoTo( QRYEZ3->EZ3RECNO ) )
         if EZ1->( dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE) ) )
            while EZ0->(EZ0_FILIAL+EZ0_CHVNFE) == EZ1->(EZ1_FILIAL+EZ1_CHVNFE)
               //======================================================
               //NFSAIDA-2020
               //======================================================
               If EZ0->EZ0_TIPONF == "NFs"
                  cProd := BuscaProd(EZ1->EZ1_COD)
                  If !Empty(cProd) .And. cProd <> EZ1->EZ1_COD
                     RecLock("EZ1",.F.)
                     EZ1->EZ1_COD := cProd
                     MsUnlock()
                  Endif 
               Endif
               //======================================================            
               EZ1->( ExecRegra(EZ1_FILIAL,EZ1_CHVNFE,EZ1_ITEM) )
               EZ1->(dbSkip())
            enddo 
         endif
         QRYEZ3->(dbSkip())
   enddo 

return

/*=====================================================================================================================================*/
// 
/*=====================================================================================================================================*/
Static Function ExecRegra(cFilialNF,cChvNFe,cItem)

   Local cStatus := '0'
   Local cMensagem := ""
   local bOldBlock,bNewBlock,oErroTry
   Local cEZ3Rec := STRZero(EZ3->(RECNO()),8)
   Local cInstrucao := AllTrim(EZ3->EZ3_REGRA)

   cInstrucao:= StrTran(cInstrucao, chr(10),"") // Elimina possibilidade de erro
   cInstrucao:= StrTran(cInstrucao, chr(13),"") // Elimina possibilidade de erro

   // executa a instrucao de validacao
   bNewBlock:= {|oErroTry| cStatus:='2',cMensagem := oErroTry:Description+ENTER+oErroTry:ErrorStack }
   bOldBlock := ErrorBlock(bNewBlock)
   begin sequence
      if &cInstrucao
         cStatus := '0'
         cMensagem := TradMacro(EZ3->EZ3_MSGOK)
      else
         cStatus := EZ3->EZ3_NIVEL
         cMensagem := TradMacro(EZ3->EZ3_MSGNOK)
      end
   end sequence
   ErrorBlock(bOldBlock)

   // Criacao da msg de erro
   IF EZ2->( dbseek( cFilialNF+cChvNFe+cItem+cEZ3Rec ) )
      EZ2->( RecLock('EZ2', .F.) ) // atualiza a MSG
      EZ2->EZ2_FILIAL := cFilialNF
      EZ2->EZ2_CHVNFE := cChvNFe
      EZ2->EZ2_ITEM   := cItem
      EZ2->EZ2_RECNO  := cEZ3Rec
      EZ2->EZ2_STATUS := cStatus  // "1=Aviso;2=Erro;0=ok"
      EZ2->EZ2_MSG    := cMensagem
      EZ2->EZ2_NUMNFE := EZ0->EZ0_NUMNFE
      EZ2->(msUnlock())
      If EZ2->(FieldPos("EZ2_GRUPO")) > 0 
         EZ2->EZ2_GRUPO := EZ3->EZ3_GRUPO 
      Endif       
   Else
      if cStatus <> '0' // so cria se Nao estiver OK
         EZ2->( RecLock('EZ2', .T.) )
         EZ2->EZ2_FILIAL:= cFilialNF
         EZ2->EZ2_CHVNFE:= cChvNFe
         EZ2->EZ2_ITEM  := cItem
         EZ2->EZ2_RECNO := cEZ3Rec
         EZ2->EZ2_STATUS:= cStatus  // "1=Aviso;2=Erro;0=ok"
         EZ2->EZ2_MSG   := cMensagem
   		If EZ2->(FieldPos("EZ2_GRUPO")) > 0 
            EZ2->EZ2_GRUPO := EZ3->EZ3_GRUPO 
         Endif 
         EZ2->EZ2_NUMNFE := EZ0->EZ0_NUMNFE
         EZ2->(msUnlock())
      Endif 
   Endif

return

/*=====================================================================================================================================*/
// Funcao para a validar os dados da NF
/*=====================================================================================================================================*/
Static Function VldEnviaWf( aNF,lSchedule )

Local cQry:=''
Local cAreaEZ0 := GetArea("EZ0")
Local cAreaEZ1 := GetArea("EZ1")
Local cAreaEZ2 := GetArea('EZ2')

cQry:="select * from "+ RetSqlName('EZ2')             +ENTER
cQry+=" where EZ2_CHVNFE = '"+aNF+"' "                +ENTER
cQry+="   AND EZ2_STATUS = '2' and D_E_L_E_T_ <> '*' "+ENTER
AbreQuery(cQry,"QRYEZ2")

if QRYEZ2->(!Eof())
   while QRYEZ2->(!Eof())
         EZ0->(dbseek(xFilial("EZ0")+aNF))
         EZ1->(dbseek(xFilial("EZ1")+aNF))
         if !Empty(Alltrim(QRYEZ2->EZ2_GRUPO))
            WFEnvia(QRYEZ2->EZ2_GRUPO,lSchedule,ALLTRIM(QRYEZ2->EZ2_MSG))
         Endif
         QRYEZ2->(dbskip()) 
   ENDDO
Endif 

RestArea(cAreaEZ0)
RestArea(cAreaEZ1)
RestArea(cAreaEZ2)

Return

/*=====================================================================================================================================*/
// Funcao para responder ao duplo click na validacao da NF.
/*=====================================================================================================================================*/
user function dplClick(cBrowse,oBrwLeft,oBrwRight)

   Local bOldBlock,bNewBlock,oErroTry
   Local cInstrucao := '' , bInstrucao := {||}

   if cBrowse == "UP"
      u_ManutEZ0(4)
   endif
   if cBrowse == "LEFT"
      Raiz:=3
      u_ManutEZ1(4)
      Raiz:=0
      //AltItem()
   endif
   if cBrowse == 'RIGHT'
      // executa a instrucao de acao
      bNewBlock:= {|oErroTry| Aviso( "EZ4 GRC" ,oErroTry:Description+ENTER+oErroTry:ErrorStack, {"OK"}, 3,"Criacao de Documento") }
      bOldBlock := ErrorBlock(bNewBlock)
      Begin Sequence
         EZ2->(dbGoTo(oBrwRight:nAt))
         EZ3->(dbSetOrder(1))
         EZ3->(dbGoTo(val(EZ2->EZ2_RECNO)))
         if EZ2->EZ2_STATUS<>'0'
            cInstrucao:= AllTrim(EZ3->EZ3_ACAO)
            cInstrucao:= StrTran(cInstrucao, chr(10),"") // Elimina possibilidade de erro
            cInstrucao:= StrTran(cInstrucao, chr(13),"") // Elimina possibilidade de erro
            if Empty(cInstrucao)
               MsgInfo("nenhuma acao foi definida para essa validacao")
            else
               EZ0->( dbSetOrder(1) )
               EZ0->( dbSeek(EZ2->(EZ2_FILIAL+EZ2_CHVNFE) ) )
               EZ1->( dbSetOrder(1) )
               EZ1->( dbSeek(EZ2->(EZ2_FILIAL+EZ2_CHVNFE+EZ2_ITEM) ) )
               cInstrucao := "{|| "+cInstrucao+" }"
               bInstrucao := &cInstrucao
               if ValType(bInstrucao)="B"
                  if EZ2->EZ2_ITEM = 'cab.'
                     EZ0->( Eval( bInstrucao  ) )
                     EZ0->(ExecRegra(EZ0_FILIAL,EZ0_CHVNFE,'cab.'))
                  else
                     EZ1->( Eval( bInstrucao  ) )
                     EZ1->(ExecRegra(EZ1_FILIAL,EZ1_CHVNFE,EZ1_ITEM))
                  endif
               else
                  MsgInfo("A Acao cadastrada Nao esta bem definida:"+ENTER+cInstrucao+ENTER+" Entre em contato com o administrador " )
               endif
            endif
         else
            MsgInfo(EZ3->EZ3_MSGOK)
         endif
      End Sequence
      ErrorBlock(bOldBlock)
   endif
   VldDadosNF( {EZ0->EZ0_CHVNFE,EZ0->(RECNO())} )
   EZ1->(dbgotop())
   oBrwLeft:NAT := 1
   oBrwRight:NAT := 1

return

/*=====================================================================================================================================*/
// Grupo de funcoes para manipulacao de XML
/*=====================================================================================================================================*/
static function XML_Limpa( cXML )

   // ajuste preventivo na sintaxe das tags para eliminar espacos indesejaveis
   cXML:= StrTran(cXML, "< ", "<")  // elimina espaco no comeco da TAG de abertaura
   cXML:= StrTran(cXML, "< ", "<")  // caso exista uma tag com 2 espacos
   cXML:= StrTran(cXML, "</ ", "</") // elimina espaco no comeco da TAG de fechamento
   cXML:= StrTran(cXML, "</ ", "</") // caso exista uma tag com 2 espacos
   cXML:= StrTran(cXML, " >", ">")  // elimina espaco no final da TAG (fechamento ou abertura)
   cXML:= StrTran(cXML, " >", ">")  // caso exista uma tag com 2 espacos
   cXML:= StrTran(cXML, chr(9),"") // Elimina "TAB" (possibilidade de erro)
   cXML:= StrTran(cXML, chr(10),"") // Elimina "TAB" (possibilidade de erro)
   cXML:= StrTran(cXML, chr(13),"") // Elimina "Enter" (possibilidade de erro)

return cXML

/*=====================================================================================================================================*/
// retorna o so conteudo da TAG
/*=====================================================================================================================================*/
static function  XMLTagCont( cTag , cXML )

   Local cU_XMl:= Alltrim(Upper(cXMl))  // tudo em maisculo para
   Local cU_Tag:= Alltrim(Upper(cTag))  // facilitar a busca
   Local cRet:="", nPosIni:=0, nTamCtd:=0
   Local i:=0, nMax:=Len(cU_XML)

   cXML := AllTrim(cXML)

   nPosIni := At("<"+cU_Tag+">", cU_XML)       // acha o 1� inicio da tag de abertura
   if nPosIni = 0
      nPosIni := At("<"+cU_Tag+" ", cU_XML)   // caso a TAG tenha atributos
   endif
   If nPosIni > 0
      nPosIni += len("<"+cU_Tag)           // busca o inicio do conteudo da tag
      while nMax >= nPosINI .and. ;        // evitar estouro devido a XML mal definido
         Substr(cU_XML,nPosIni,1) <> ">"
         nPosINI++                      // acha o final da tag de abertura
      enddo 
      nPosINI++                            // inicio do conteudo

      i := At("</"+cU_Tag+">", cU_XML)         // acha o final do conteudo ou inicio da tag de fechamento
      nTamCtd := i - nPosINI               // calcula o tamanho do conteudo

      if nTamCtd > 0                                 // Se existe conteudo
         cRet:= Substr( cXML, nPosINI, nTamCtd )     // extrai do xml original
      endif                                          // para Nao retornar tudo em maiusculo

   endif

return cRet

/*=====================================================================================================================================*/
// retorna a tag completa
/*=====================================================================================================================================*/
static function  XMLTagCompl( cTag , cXML ) 

   Local cU_XMl:= Alltrim(Upper(cXMl))  // tudo em maisculo para
   Local cU_Tag:= Alltrim(Upper(cTag))  // facilitar a busca
   Local cRet:="", nPosIni:=0, nTamCtd:=0
   Local i:=0, nMax:=Len(cU_XML)

   cXML := AllTrim(cXML)

   nPosIni := At("<"+cU_Tag+">", cU_XML)       // acha o 1� inicio da tag de abertura
   if nPosIni = 0
      nPosIni := At("<"+cU_Tag+" ", cU_XML)   // caso a TAG tenha atributos
   endif

   If nPosIni > 0
      i := At("</"+cU_Tag, cU_XML)         // acha o inicio da tag de fechamento
      i += len("</"+cU_Tag)
      while nMax >= i .and.  ;            // evitar estouro devido a XML mal definido
         Substr( cU_XML, i , 1 ) <> ">"
         i++                            // avanca ate o final da tag de fechamento
      enddo 
      nTamCtd := (i+1) - nPosIni           // Calcula o tamanho do conteudo
      if nTamCtd > 0                                 // Se existe conteudo
         cRet:= Substr( cXML, nPosIni, nTamCtd )     // extrai do xml original
      endif                                          // para Nao retornar tudo em maiusculo
   endif

return cRet

/*=====================================================================================================================================*/
// retorna um atributo da tag
/*=====================================================================================================================================*/
static function  XMLTagAtrib( cTag, cAtrib , cXML ) 

   Local cU_XMl := Alltrim(Upper(cXMl))  // tudo em maisculo para
   Local cU_Tag := Alltrim(Upper(cTag))  // facilitar a busca
   Local cU_Atrib := Alltrim(Upper(cAtrib))
   Local cRet := "", nPosIni:=0, nTamCtd:=0
   Local i := 0, nMax:=Len(cU_XML)

   cXML := AllTrim(cXML)
   nPosIni := At("<"+cU_Tag+" ", cU_XML)   // caso a TAG tenha atributos
   
   
   If nPosIni > 0                                       // o XML tem a Tag
      cU_XML := Substr( cU_XML, nPosIni, len(cU_XML) )  // descarta a parte inicial para Nao encontrar
      nMax:=Len(cU_XML)                                 // o mesmo atributo em TAG's anteriores
      i := At(cU_Atrib+'="', cU_XML)                    // acha o Inicio do Atributo
      if i> 0
         i := i + len(cU_Atrib+'="')                    // encontra o inicio do conteudo do atributo
         while nMax > i + nTamCtd ;
         .and. Substr( cU_XML, i + nTamCtd , 1 ) <> '"'
               nTamCtd++                               // busca o Tamanho do conteudo
         end
         if nTamCtd > 0                                 // Se existe conteudo
            nPosIni += i
            cRet:= Substr( cXML, nPosINI-1, nTamCtd )     // extrai do xml original
         endif
      endif
   endif

return cRet

/*=====================================================================================================================================*/
// traduz uma macro dentro de um texto
/*=====================================================================================================================================*/
static Function TradMacro(cMacro)               // traduz uma macro dentro de um texto

   Local	bBlock
   Local	cMacroBase	:=	AllTrim(cMacro)					// armazena o texto que contem macro para manipulacao
   Local	cMsgAux		:=	""										// armazena a msg de retorno ja traduzida
   Local	cMacroAux	:=	""										// armazena a macro isoladamente
   Local	nPosInicial	:=	At("&",cMacroBase)	         // posicao onde inicia a macro no texto
   Local	nPosFinal	:=	0										// posicao que finaliza a macro no texto
   Local	uVar														// variavel para receber o valor da macro

   If nPosInicial==0                                                  // Nao existem macros no texto
      cMsgAux := cMacroBase
   Else
      While nPosInicial > 0
         cMsgAux+=left(cMacroBase,nPosInicial-1)	                // texto antes da macro
         cMacroBase:=right(cMacroBase,len(cMacroBase)-nPosInicial) // restante da macro sem o char de controle
         nPosFinal:=At("&",cMacroBase)
         if nPosFinal>0
            cMacroAux:=left(cMacroBase,nPosFinal-1)
            cMacroBase:=right(cMacroBase,len(cMacroBase)-nPosFinal)// restante da macro sem o char de controle
            bBlock := ErrorBlock({||uVar:=""})
            begin sequence
               uVar:= &cMacroAux
            end sequence
            ErrorBlock(bBlock)
            cMsgAux+=ToString(uVar)                                 // conversao do retorno da macro para texto
            nPosInicial:= At("&",cMacroBase)
         else                                                      // o char padrao de fechamento Nao foi achado
            cMsgAux+="&"               						          // macro Nao definida
            nPosInicial:= 0
         endif
      EndDo
      cMsgAux += cMacroBase
   endif

Return cMsgAux

/*=====================================================================================================================================*/
// conversao de uVar para texto
/*=====================================================================================================================================*/
Static Function ToString(uVar, nTam)

   Local	cRetorno	:=	""

   Default nTam	:=	0

   do case
      case Valtype(uVar)=="C" .or. Valtype(uVar)=="M"
         cRetorno:=uVar
      case Valtype(uVar)=="D"
         cRetorno:=DtoC(uVar)
      case Valtype(uVar)=="L"
         cRetorno:=if(uVar,"VERDADEIRO","FALSO")
      case Valtype(uVar)=="N"
         cRetorno:=AllTrim(str(uVar))
         cRetorno:=If(Empty(cRetorno),"0",cRetorno)
   endcase

   cRetorno:=If(cRetorno==""," ",cRetorno)

   if len(cRetorno)<>nTam .and. nTam>0
      cRetorno:=padr(cRetorno,nTam)
   endif

return cRetorno

/*=====================================================================================================================================*/
// 
/*=====================================================================================================================================*/
Static Function lf(aButtons)
   
   Local i:= len(aButtons)

return if( i < 1, 1, aButtons[i]:nLeft/2+aButtons[i]:nWidth/2+1) //+5

/*=====================================================================================================================================*/
// Funcao para processamento de email contendo os xml.
/*=====================================================================================================================================*/
User Function ProcMail(oSelf, lSchedule)

   Local lEnd        := .F.
   Local lSSL        := SuperGetMV("EZ_PX_SSL",.f.,.f.)
   Local lTLS        := SuperGetMV("EZ_PX_TLS",.f.,.f.)
   Local lRID        := SuperGetMV("EZ_PX_RID",.f.,.f.)
   Local cProtocolo  := AllTrim(SuperGetMV("EZ_PX_PTL",.f.,"POP"))
   Local nTimeOut    := SuperGetMV("EZ_PX_TMO",.f.,120)
   Local cMailServer := AllTrim(SuperGetMV("EZ_PX_MSV",.f.,""))
   Local cSmtpServer := AllTrim(SuperGetMV("EZ_PX_SSV",.f.,""))
   Local cAccount    := AllTrim(SuperGetMV("EZ_PX_ACC",.f.,""))
   Local cPassword   := AllTrim(SuperGetMV("EZ_PX_PSW",.f.,""))
   Local nMailPort   := SuperGetMV("EZ_PX_MPT",.f.,10)
   Local nSmtpPort   := SuperGetMV("EZ_PX_SPT",.f.,25)

   Local nTotMsg   := 0
   Local nStExec   := 0
   Local oSvrEmail := TMailManager():New()
   Local oProcess

   Default oSelf     := Nil 
   Default lSchedule := .F.    

   If !lSchedule
      oSelf:SetRegua1(2)
      oSelf:SetRegua2(10)
      oSelf:IncRegua1("Lendo e-mails")
      oSelf:IncRegua2("Processando... aguarde...")   
   Endif 
   MailLog("Iniciando busca em email",lSchedule,oSelf)

   // conexao com o servidor
   MailLog("Inicializacao do Servidor de Email",lSchedule,oSelf)
   oSvrEmail:SetUseSSL( lSSL )
   oSvrEmail:SetUseTLS( lTLS )

   // inicializando o servidor de email
   // numerico Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
   nStExec := oSvrEmail:Init(cMailServer,cSmtpServer,cAccount,cPassword,nMailPort,nSmtpPort)

   if nStExec > 0
      MailLog("Erro ao iniciar Servidor de Email",lSchedule,oSelf)
      MailLog(oSvrEmail:GetErrorString(nStExec),lSchedule,oSelf,.t.)
   else
      MailLog("Servidor de Email inicializado com sucesso",lSchedule,oSelf)
      do case
         case cProtocolo $ "POP,POPS,IMAP,IMAPS,MAPI"
            nStExec := oSvrEmail:SetPopTimeOut( nTimeOut )
         case cProtocolo $ "SMTP,SMTPS"
            nStExec := oSvrEmail:SetSMTPTimeOut( nTimeOut )
         otherwise
            nStExec:= 100
            MailLog("Protocolo Nao definido",lSchedule,oSelf)
      endcase
      if nStExec >0
         MailLog("Erro ao setar o tempo de Time Out",lSchedule,oSelf)
         MailLog(oSvrEmail:GetErrorString(nStExec),lSchedule,oSelf,.t.) 
      else
         MailLog("Estabelecendo conexao com o Servidor de Email",lSchedule,oSelf)
         do case
            case cProtocolo $ "IMAP,IMAPS"
                  nStExec := oSvrEmail:IMAPConnect()  // https://tdn.totvs.com/display/tec/TMailManager%3AIMAPConnect
            case cProtocolo $ "POP,POPS,MAPI"
               nStExec := oSvrEmail:POPConnect()
            case cProtocolo $ "SMTP,SMTPS"
               nStExec := oSvrEmail:SMTPConnect()
            otherwise
               nStExec:= 100
               MailLog("Protocolo Nao definido",lSchedule,oSelf)
         endcase
         if nStExec >0
            conout("Erro ao conectar com Servidor de Email")
            MailLog("Erro ao conectar com Servidor de Email",lSchedule,oSelf)
            MailLog(oSvrEmail:GetErrorString(nStExec),lSchedule,oSelf,.t.)
         else
            if cProtocolo = "IMAP,IMAPS"
               nStExec := oSvrEmail:SetUseRealID( lRID )
            endif
            nStExec := oSvrEmail:GetNumMsgs( @nTotMsg )
            if nStExec >0
               MailLog("Erro ao buscar o total de mensagens",lSchedule,oSelf)
               MailLog(oSvrEmail:GetErrorString(nStExec),lSchedule,oSelf,.t.)
            else
               MailLog("Recuperando "+ Alltrim(str(nTotMsg))+ " mensagens",lSchedule,oSelf)
               If !lSchedule
                  oProcess:=  MsNewProcess():New({|lEnd| CargaEmail(@oProcess,@lEnd,@oSvrEmail,nTotMsg,.F.)}, "EZ4 GRC" , "Baixando anexos de email's...", .T.)
                  oProcess:Activate()
               Else
                  CargaEmail(@oProcess,@lEnd,@oSvrEmail,nTotMsg,.T.)               
               Endif 
               MailLog("Desconexao com o Servidor de Email",lSchedule,oSelf)
               do case
                  case cProtocolo $ "IMAP,IMAPS"
                     nStExec := oSvrEmail:IMAPDisconnect()
                  case cProtocolo $ "POP,POPS,MAPI"
                     nStExec := oSvrEmail:POPDisconnect()
                  case cProtocolo $ "SMTP,SMTPS"
                     nStExec := oSvrEmail:SMTPDisconnect()
                  otherwise
                     nStExec:= 100
                     MailLog("Protocolo Nao definido",lSchedule,oSelf,.t.)
               endcase
               if nStExec >0
                  MailLog("Erro ao Desconectar do Servidor de Email",lSchedule,oSelf)
                  MailLog(oSvrEmail:GetErrorString(nStExec),lSchedule,oSelf,.t.)
               endif
            endif
         endif
      endif
   endif

   MailLog( "Busca em email finalizada", lSchedule, oSelf )
   
   If !lSchedule
      oSelf:IncRegua1("Busca em email finalizada")
   Endif 

return

Static Function MailLog(cMSG,lSche,oSelf,lErro)
DEFAULT lErro := .f.
   
   Conout(cMSG )
   If !lSche
      oSelf:IncRegua2(cMSG)
      if lErro
         MsgStop(cMSG, "busca em email") 
      endif
   Endif 

return

/*=====================================================================================================================================*/
// Funcao para processamento de email contendo os xml.
/*=====================================================================================================================================*/
Static Function CargaEmail(oProcess,lEnd,oSvrEmail,nTotMsg,lSchedule)

   Local i := 0, j := 0
   Local nStExec  := 0, nTotAnex := 0
   Local oMsgMail := TMailMessage():New()
   Local nMaxMsg  := SuperGetMV("EZ_PX_MMS",.f.,100)
   //Local lUsaRoot := SuperGetMV("EZ_PX_RTP",.f.,.T.)
   Local cDiretorio := "\EZ4MAIL\"
   //Local cRoot      := GETSRVPROFSTRING( "ROOTPATH", "" ) 
   Private cXML     := ""
   Private aLstAnex := {}   

   If !ExistDir(cDiretorio)
      MakeDir(cDiretorio)
   Endif
   
   oMsgMail:Clear()

   // carregar no maximo as 100 ultimas
   j := if(nTotMsg>nMaxMsg, nTotMsg-nMaxMsg ,1 )
   if !lSchedule
      oProcess:SetRegua1(j)
   Endif 
   for i := j TO nTotMsg
      if lEnd
         Conout("Processo interrompido apos o email " + AllTrim(str(i-1)) )
         i := 1 + nTotMsg
      else
         If !lSchedule
            oProcess:IncRegua1("Lendo email "+ AllTrim(str(i)) +" de "+AllTrim(str(nTotMsg)))
         Endif 
         nStExec := oMsgMail:Receive( oSvrEmail, i )
         if nStExec >0
            Conout("Erro ao baixar o Email "+ AllTrim(str(i)) )
            Conout( oSvrEmail:GetErrorString(nStExec) )
         else
            nTotAnex := oMsgMail:GetAttachCount()
            if nTotAnex > 0
               Conout("Email "+ AllTrim(str(i)) +" com "+ AllTrim(str(nTotAnex)) +" anexos" )
               If !lSchedule
                  oProcess:SetRegua2(nTotAnex)
               Endif 
               for j := 1 to nTotAnex
                  If !lSchedule
                     oProcess:IncRegua2("Verificando anexo "+AllTrim(str(j))+" de "+AllTrim(str(nTotAnex))+"  do email "+ AllTrim(str(i)))
                  Endif 
                  aLstAnex := oMsgMail:GetAttachInfo(j)
                  if Upper(Right(AllTrim(aLstAnex[1]),4)) = '.XML'
                     Conout("E-mail -> Processando anexo "+aLstAnex[1]+" do email "+ AllTrim(str(i)) )
//                   cArquivo := GetSrvProfString( "RootPath", "" )+cDiretorio
                     cArquivo := cDiretorio
                     cArquivo := if( right(cArquivo,1)="\", cArquivo, cArquivo+"\" )
                     cArquivo += aLstAnex[1]
//                     if oMsgMail:SaveAttach( j, cArquivo )
                        Conout("E-mail -> Anexo salvo em "+ cArquivo )
                        cXML := oMsgMail:GetAttach(j)
                        memowrite(cArquivo,cXML)
                        cLogMsg:=cXML
                        //cXML:=""
                        cChvnfem := SubStr(aLstAnex[1],1,44)
                        dbSelectArea("EZ0")
                        EZ0->(dbSetOrder(1))
                        If !EZ0->(dbSeek(xFilial("EZ0")+cChvnfem))
                           Conout("E-mail -> Processando chave: " + cChvnfem )
                           If U_ProcTxt(Nil, lSchedule)  
                              cXML:=cLogMsg
                              FRename( cArquivo,cArquivo+".processado" )
                              Conout("E-mail -> Conclu�do chave: " + cChvnfem )
                           Endif 
                        Endif 
  //                   else
  //                      Conout("Nao foi possivel salvar o anexo em "+ cArquivo )
  //                   endif
                  elseif Upper(Right(AllTrim(aLstAnex[1]),4)) = '.PDF' .and. lUsaOCR  // Busco o PDF Se o OCR esta ativado
                     Conout("E-mail -> Processando anexo "+aLstAnex[1]+" do email "+ AllTrim(str(i)) )
                     cArquivo := cDiretorio
                     cArquivo := if( right(cArquivo,1)="\", cArquivo, cArquivo+"\" )
                     cArquivo += aLstAnex[1]
                     Conout("E-mail -> Anexo salvo em "+ cArquivo )
                     cXML := oMsgMail:GetAttach(j)
                     memowrite(cArquivo,cXML)
                     cLogMsg:=cXML
                     U_OCRSelFile(.T.,cDiretorio)
                  endif
               next
            else
               Conout("Email "+ AllTrim(str(i)) +" sem anexos" )
            endif
         endif
      endif
   Next

Return


/*=====================================================================================================================================*/
// Funcao para processamento de um diretorio contendo os xml apresentado em tela.
/*=====================================================================================================================================*/
User Function ProcDir(oSelf, lSchedule)  

   Local cDiretorio := ""
   Local aDir       :={}
   Local i          := 0
   Local nRegua     := 0
   
   cDiretorio := Alltrim(MV_PAR02)
   cDiretorio :=AllTrim( cDiretorio+if(rAt('\',cDiretorio)<len(cDiretorio),'\','') )
   aDir := Directory(cDiretorio+"*.xml")
   
   nRegua := Len(aDir)
   If !lSchedule
      oSelf:SetRegua1(nRegua)
      oSelf:SetRegua2(nRegua)
   Endif 
   
   For i := 1 to Len(aDir)
      If !lSchedule
         oSelf:IncRegua1("Lendo arquivo: " + aDir[i,1])
         oSelf:IncRegua2("Processando: " + CValToChar(i) + " de " + CValToChar(nRegua))      
      Endif 
      cArquivo := cDiretorio+aDir[i,1]
      cXML:=""
      If U_ProcTxt(oSelf, lSchedule)
         FRename( cDiretorio+aDir[i,1],cDiretorio+aDir[i,1]+".processado" )
      Endif
   Next

Return

/*
===============================================================================================
|| Funcao: 	EZTABSEM - Cria a tabela tempor�ria para volumetria
|| Autor:	Marcio Martins Pereira
|| Data:	23/01/2023
===============================================================================================
*/
Static Function EZTABSEM(cTabela) // Cria/abre as tabelas

    Local aStru := {}
    Local cTamFil:= FWSizeFilial() 


    If Select(cTabela) == 0

        aStru := {  { "FILIAL"    , "C" , cTamFil , 0 },;   
                    { "PEDIDO"    , "C" , 06 , 0 },;  
                    { "NOTA"      , "C" , 09 , 0 },;  
                    { "SERIE"     , "C" , 03 , 0 },;  
                    { "EMISSAO"   , "D" , 08 , 0 },;
                    { "HRINI"     , "C" , 10 , 0 },;
                    { "HRFIM"     , "C" , 10 , 0 },;
                    { "STATUS"    , "C" , 20 , 0 }}
        
        cTabela := upper(AllTrim(cTabela))

        If !MsFile(cTabela,,"TOPCONN")
            dbCreate(cTabela, aStru, "TOPCONN")
            dbUseArea(.T.,"TOPCONN",cTabela,cTabela,.F.)
            (cTabela)->(dbCreateIndex( cTabela+'1' , "FILIAL+PEDIDO" , {||FILIAL+PEDIDO}) )
            (cTabela)->(dbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",cTabela,cTabela,.T.)
        (cTabela)->(DbSetIndex(cTabela+'1'))
        
    EndIf
    
Return	


/*
===============================================================================================
|| Funcao: 	BLQSEMAF - SEMAFORO PARA GERACAO NF SAIDA
|| Autor:	CARLA BARBOSA
|| Data:	23/01/2023
===============================================================================================
*/
STATIC Function BLQSEMAF(cFILIAL,cPEDIDO,cNOTA,cSERIE)
Local lConseguiu := .f.
Local cQrySema   := ""
Private cTabSema := "TABSEMA"
 

// Cria��o da tabela que trata a volumetria
EZTABSEM(cTabSema)

 cQrySema := " "
 cQrySema += "SELECT * "
 cQrySema += " FROM TABSEMA "
 cQrySema += " WHERE FILIAL ='"+cFILIAL+"' AND "
 cQrySema += "       PEDIDO ='"+cPEDIDO+"' AND "
 cQrySema += "       NOTA ='"+cNOTA+"' AND "
 cQrySema += "       SERIE ='"+cSERIE+"' AND "
 cQrySema += "       LTRIM(RTRIM(HRFIM)) = ''  " 

 While .t. 
   AbreQuery(cQrySema,"QRYSEM")
   if QRYSEM->(Eof())
       Reclock((cTabSema),.T.)
       (cTabSema)->FILIAL  := CFILIAL
       (cTabSema)->PEDIDO  := cPEDIDO
       (cTabSema)->NOTA    := cNOTA
       (cTabSema)->SERIE   := cSERIE
       (cTabSema)->EMISSAO := Date()
       (cTabSema)->HRINI   := Time()
       (cTabSema)->STATUS  := "PROCESSANDO"
       MsUnLock()
       lConseguiu := .t.
       Exit
   Else
      If SubtHoras(ddatabase,(cTabSema)->HRINI ,ddatabase,time())*24 > 1
         LIBSEMAF(cFILIAL,cPEDIDO)
         QRYSEM->(DbCloseArea())
         Reclock((cTabSema),.T.)
         (cTabSema)->FILIAL  := CFILIAL
         (cTabSema)->PEDIDO  := cPEDIDO
         (cTabSema)->NOTA    := cNOTA
         (cTabSema)->SERIE   := cSERIE
         (cTabSema)->EMISSAO := Date()
         (cTabSema)->HRINI   := Time()
         (cTabSema)->STATUS  := "PROCESSANDO"
         MsUnLock()
         lConseguiu := .t.
         Exit
      Endif 
   Endif
   QRYSEM->(DbCloseArea())
enddo
/*
(cTabSema)->(dbSetOrder(1))
IF (cTabSema)->(dbseek(cFILIAL+cPEDIDO))
   While !lConseguiu
      IF (cTabSema)->(DBRLock())
             (cTabSema)->EMISSAO :=  Date()
             (cTabSema)->HRINI  := Time()
             (cTabSema)->HRFIM   := SPACE(10)
             (cTabSema)->STATUS  := "PROCESSANDO"
            lConseguiu := .t.
      Endif
   Enddo
Else
   Reclock((cTabSema),.T.)
   Replace (cTabSema)->FILIAL WITH CFILIAL
   Replace (cTabSema)->PEDIDO WITH cPedido
   Replace (cTabSema)->EMISSAO WITH Date()
   Replace (cTabSema)->HRINI   with Time()
   Replace (cTabSema)->STATUS  WITH "PROCESSANDO"
   lConseguiu := .t.
Endif
*/
Return lConseguiu  


/*
===============================================================================================
|| Funcao: 	LIBSEMAF - SEMAFORO PARA GERACAO NF SAIDA
|| Autor:	CARLA BARBOSA
|| Data:	23/01/2023
===============================================================================================
*/
STATIC Function LIBSEMAF(cFILIAL,cPEDIDO)
Local lConseguiu := .t. 
Private cTabSema := "TABSEMA"

Begin Transaction
    //Monta o Update
   cQryUpd := " UPDATE TABSEMA "
   cQryUpd += " SET HRFIM = '"+TIME()+"' , "
   cQryUpd += " STATUS = 'FINALIZADO' "
   cQryUpd += " WHERE "
   cQryUpd += " FILIAL = '"+cFILIAL+"' AND "
   cQryUpd += " PEDIDO = '"+cPEDIDO+"' AND "
   cQryUpd += " LTRIM(RTRIM(HRFIM)) = ''   "
   nErro := TcSqlExec(cQryUpd)
   //Se houve erro, mostra a mensagem e cancela a transa��o
   If nErro != 0
      disarmTransaction()
      Return
   EndIf
   lConseguiu := .t.
End Transaction      
/*
Replace (cTabSema)->HRFIM   with Time()
Replace (cTabSema)->STATUS  WITH "FINALIZADO"
(cTabSema)->(DBRUnlock())
*/
Return lConseguiu


/*=====================================================================================================================================*/
// Funcao para processamento do xml apresentado em tela.
/*=====================================================================================================================================*/
User Function ProcTxt(oSelf, lSchedule)  

   Local lEnd     := .F.
   Local ct_XML   := XML_Limpa( cXML )
   Local cCHVNFE  := ""
   Local i        := 0
   Local nX       := 0 
   Local cTipo    := ""
   Local aTipos   := &(SuperGetMV("EZ_PX_CHV",.f.,'{ {"infNFE","Id"}, {"infCte","Id"}, {"infCFe","Id"}, {"infNFSe","Id"}, {"<INT164_TBCP>","OrderNumber","TransactionType"} }')) 
   Local lRet     := .T.
   Local oProcess 
   Local lIntGFE    := SuperGetMV("MV_INTGFE" ,.F.,.F.)    // SE ATIVADO, NaO PROCESSA ENTRADA DO CTE, FICA A CARGO DO GFE, COPIA-SE O XML PARA MV_XMLDIR
   Local cDiretorio := "\EZ4MAIL\"
   Local lAtivaSai  := SuperGetMV("EZ_PX_NFS" ,.F.,.F.)   // NFSAIDA-2020
   Local lUsaWfEZ2  := SupergetMV("EZ_USWFEZ2",.F.,.F.) 
   Local cTipoAs400 := ""


   EzCheckPar(xFilial("EZ0"))
   

   If empty(ct_XML)
      If lSchedule .And. IsInCallStack("CargaEmail")
         cArquivo := cDiretorio+aLstAnex[1]
      Endif 
      If Carrega()
         ct_XML := XML_Limpa( cXML )
      Else
         Return .F.
      Endif
   Endif 

   // busca a chave de acesso
   lMuda := .f.
   While i< len(aTipos) .and. empty(cCHVNFE)
      i++
      if  aTipos[i,1] == '<INT164_TBCP>' .and. lUsaAS400
          lXmlAs400 := .t.
      Else
         lXmlAs400 := .f.
      Endif
      if lXmlAs400
         cChvNFe      := XMLTagCont(aTipos[i,2],ct_XML)
         cTipoAs400   := XMLTagCont(aTipos[i,3],ct_XML) 
      else
         cCHVNFE := XMLTagAtrib( aTipos[i,1], aTipos[i,2] , ct_XML )
      endif
      if aTipos[i,1] == 'infNFSe' .or. aTipos[i,1] == '<INT164_TBCP>'
         lMuda := .t.
      Endif
   Enddo

   If !Empty(cCHVNFE)
      cTipo := substr(cCHVNFE,1,3)
      cCHVNFE := substr(cCHVNFE,4)
      // se for nota do NFSE Nacional tenho que pegar so o final da chave
      // carla Barbosa
      if lMuda .and. aTipos[i,1] == 'infNFSe'
         cTipo:= 'NFn'
         cCHVNFE := substr(cCHVNFE,7)
      Else
         cTipo   := cTipoAs400    
         cChvNFe := XMLTagCont(aTipos[i,2],ct_XML)
      Endif

      If !SuperGetMV("EZ_DEMO",.F.,.F.)  //cEmpAnt <> "99"  .AND. !SuperGetMV("EZ_DEMO",.F.,.F.)  //  NaO e EMPRESA TESTE So CARREGA SE FOR DE INTERESSE DA EMPRESA

         /*=============*/
         //Chamado #4690 - CROWN
         //Carla Barbossa - 17/08/2022 
         //Ajuste para fazer a leitura dos XMLs de Importa��o
         //Trecho retirado do fonte Portal_xml utilizado na Crown
         xXML := StrTran(UPPER(ct_XML)," ","")

         // OCP - Marcio Martins - Respeita a Entrada de Notas que sejam de saida
         // INBRA - Carla Barbosa - Respeita parametro lAtivaSai para nao subir XML de saida 
         // quando a empresa nao utiliza - 14/07/2023
         IF UPPER(cTipo) <> "CTE" .and. !lXmlAs400 // so entro nesta condi��o se for diferente de CTE e n�o for XML AS400- Carla Barbosa 05/10/22
            If At("<EMIT><CNPJ>"+SM0->M0_CGC,xXML) > 0 .AND. lAtivaSai
            ElseIf At("<DEST><IDESTRANGEIRO",xXML) > 0
               If At("<EMIT><CNPJ>"+SM0->M0_CGC,xXML) == 0
                  Return
               Endif
            ElseIf At("<DEST><CNPJ>"+SM0->M0_CGC,xXML) == 0    // Se n�o encontrar, esse XML nao pertence a essa filial
               Return
               // Edson Hornberger - Referente ao chamado reaberto #60631 (XML Cancelado)
            ElseIf SUBST(xXML, AT("<CSTAT>",xXML) + 7, 3) == "101" .Or. SUBST(xXML, AT("<CSTAT>",xXML) + 7, 3) == "151" 
               Return
            Endif
         Endif

         IF UPPER(cTipo) == "CTE" .and. AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('emit',ct_XML))
            If At(AllTrim(SM0->M0_CGC) , ct_XML ) == 0
               return .f. // este xml nao interessa para a empresa 
            else
               If XMLTagCont('cStat',ct_XML) $ SuperGetMV("EZ_PX_STCL" ,.F.,"101,151") 
                  Return .f.
               Endif

               IF UPPER(cTipo) == "CTE" .and. AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('emit',ct_XML))
                  // Carla Barbosa - 24/11/2022
                  // Criado parametro para baixar todos os XML independente da tag Toma
                  if SuperGetMV("EZ_CTEALL",.F.,.F.)   // Se for para baixar todos
                     lRet := .f.
                     if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('rem',ct_XML)) 
                        lRet := .t.
                     Endif
                     if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('exped',ct_XML)) 
                       lRet := .t.
                     endif
                     if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('dest',ct_XML)) 
                        lRet := .t.
                     endif 
                     if !lRet
                        Return .f.
                     endif 
                  Else      
                     cToma3 := XMLTagCont('toma',XMLTagCont('toma3',ct_XML))
                     cToma4 := XMLTagCont('toma',XMLTagCont('toma4',ct_XML)) // TOMA4 = O FRETE � PAGO POR OUTROS - O XML N�O SOBE PARA O PORTAL  - CARLA BARBOSA 23/06/22
                     do CASE
                        case cToma3 = '0'         //  TOMA3 = 0 ==> REMTENTE
                           if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('rem',ct_XML)) 
                              Return .f.
                           end   
                        case cToma3 = '1'         //  TOMA3 = 1 ==> EXPEDIDOR
                           if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('exped',ct_XML)) 
                              Return .f.
                           end   
                        case cToma3 = '2' .or. cToma3 = '3' 
                           if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('dest',ct_XML)) 
                              Return .f.
                           end  
                        case cToma4 = '4' // TOMA4 = O FRETE � PAGO POR OUTROS - O XML N�O SOBE PARA O PORTAL - CARLA BARBOSA 23/06/22
                           // carla barbosa - se o cnpj do toma4 for igual ao da empresa eu deixo subir o CTE
                           // alinhado com a Mari em 01 12 2022 - caso inbra
                           if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('toma4',ct_XML)) 
                              Return .f.
                           end 
                     endcase
                  Endif
               Else  
                  If lAtivaSai
                     If AllTrim(SM0->M0_CGC) == XMLTagCont('CNPJ',XMLTagCont('dest',ct_XML)) .Or. AllTrim(SM0->M0_CGC) == XMLTagCont('CNPJ',XMLTagCont('emit',ct_XML)) 
                     Else 
                        Return .F.
                     Endif 
                  Else 
                     // Somente Entrada
                     If AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('dest',ct_XML))
                        Return .F.
                     Endif 
                  Endif              
               ENDIF
            Endif
         Endif 
      Endif

      EZ0->(dbSetOrder(1))
      If EZ0->( dbseek(xFilial('EZ0')+cCHVNFE ))
         EZ0->( RecLock('EZ0',.F.)) 
      Else
         EZ0->( RecLock('EZ0',.T.))
         // volumetria
         U_EZVolUpdate(cTipo ) 
      Endif
      if lXmlAs400
         cOrderType := XMLTagCont('OrderType', ct_XML)
         cCliente   := XMLTagCont('CustomerCode', ct_XML)
         cInvDate  := XMLTagCont('InvoiceDate',ct_XML) 
         AbreAs400(cOrderType,cChvNFe,cCliente,cInvDate)
      else
         AbreChv(cCHVNFE)
      Endif
      EZ0->EZ0_XMLNFE := ct_XML
      EZ0->EZ0_TIPONF := cTipo
      EZ0->( EZ0_STIN() )  // atualiza o status
      EZ0->(msUnlock())
      If  EZ0->EZ0_STINTE > '0'
         aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
         lBuscaXML := .F.                // marca para inciar
         If !lSchedule
            //oProcess:=  MsNewProcess():New({|lEnd| U_ProcTxt(aChaves,lBuscaXML,@oProcess,lEnd,lSchedule)}, "EZ4 GRC" , "Processando XML's ...", .T.)
            oProcess:=  MsNewProcess():New({|lEnd| U_Proc_NF(aChaves,lBuscaXML,@oProcess,lEnd,lSchedule)}, "EZ4 GRC" , "Processando XML's ...", .T.)
            oProcess:Activate()
         Else
            U_Proc_NF(aChaves,lBuscaXML,@oProcess,lEnd,lSchedule)
         Endif 
      Endif

      If IsInCallStack("CargaEmail")
         ExtraiDadosXML(aChaves[1])
      Endif 

      VldDadosNF(aChaves[1] )

      if lUsaWfEZ2
         VldEnviaWf(aChaves[1][1],lSchedule)
      endif
      If lIntGFE .And. Upper(EZ0->EZ0_TIPONF) == "CTE"
         // Nao realizo nenhuma acao / aqui eu mantenho o EZ0_STINTE = '8'
      Else       
         EZ0->( RecLock('EZ0',.F.))
         EZ0->( EZ0_STIN() )  // atualiza o status
         EZ0->(msUnlock())
      Endif 

      If lUsaPort .And. EZ0->EZ0_STINTE <> "2"
         If ValidaCFOP() .or. EZ0->EZ0_TIPONF == "CTe"  // quando for CTE n�o passa pelo receb fisico
            U_AndaProcesso("A",lSchedule)  // Gero o Documento
         Else 
            U_AndaProcesso("1",lSchedule) // Avanco o processo para a portaria
         Endif 
      Else  
         IF !lIntGFE  
            If EZ0->EZ0_ACAO == "0" .AND. SuperGetMV("EZ_PX_PNAU" ,.F.,.F.) 
               If !lSchedule
                  oProcess:=  MsNewProcess():New({|lEnd| ExecMATA140(aChaves,@oProcess,lEnd)}, "EZ4 GRC" , "Criando Notas de Entrada", .T.)
                  oProcess:Activate()
               Else
                  ExecMATA140(aChaves,@oProcess,lEnd)
               Endif

               cGRPPIA:= SuperGetMV("EZ_GRPPIA",.F.,"")

               If !Empty(cGRPPIA)

                  aDados    := {}
                  aArquivos := {cNomeFile}
                  cRegEZ2   := ""
                  cGrupo    := ""
                  cEmails   := ""
                  cChaveEZ0 := EZ0->EZ0_CHVNFE

                  dbSelectArea("EZ2")
                  EZ2->(dbSetOrder(1))
                  If EZ2->(dbSeek(xFilial("EZ2")+cChaveEZ0))

                     While !EZ2->(Eof()) .And. xFilial("EZ2")+cChaveEZ0 == EZ2->(EZ2_FILIAL+EZ2_CHVNFE)

                        If EZ2->EZ2_STATUS == '2' .And.  EZ2->EZ2_GRUPO $ cGRPPIA 
                           cGrupo := EZ2->EZ2_GRUPO
                           cRegEZ2 += "ITEM: " + EZ2->EZ2_ITEM + " - " + Alltrim(EZ2->EZ2_MSG) + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                        Endif 
                        EZ2->(dbSkip())
                     Enddo 

                     If !Empty(cRegEZ2)
                        dbSelectArea("EZ8")
                        EZ8->(dbSetOrder(2))
                        EZ8->(dbSeek(xFilial("EZ8")+cGrupo ))
                        While !EZ8->(Eof()) .And. xFilial("EZ8")+cGrupo == EZ8->(EZ8_FILIAL+EZ8_CODIGO)
                           cEmails += Alltrim(EZ8->EZ8_EMAIL)+";"
                           EZ8->(dbSkip())
                        Enddo

                        dbSelectArea("SA2")
                        SA2->(dbSetOrder(1))
                        SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
                        cFornec := EZ0->EZ0_FORNEC+"/"+EZ0->EZ0_LOJA+" "+Alltrim(SA2->A2_NOME)     

                        aAdd(aDados, 4)                                                               // 1  Opcao para sele��o do workflow
                        aAdd(aDados, EZ0->EZ0_NUMNFE)                                                 // 2  N�mero da nota
                        aAdd(aDados, cEmails)                                                         // 4  E-mails do grupo
                        aAdd(aDados, SM0->M0_FILIAL)                                                  // 5  Planta
                        aAdd(aDados, cFornec)                                                         // 6  Codigo/loja/Nome Cliente
                        aAdd(aDados, "MOTIVOS: " + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + Alltrim(cRegEZ2))                                  // 8  Motivo da ocorr�ncia

                        fEnvEmail(aDados, aArquivos)
                        
                        TCSQLExec("UPDATE "+ RetSqlName('EZ2')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EZ2_CHVNFE = '" + cChaveEZ0 +"' ")
                        TCSQLExec("UPDATE "+ RetSqlName('EZ1')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EZ1_CHVNFE = '" + cChaveEZ0 +"' ")
                        TCSQLExec("UPDATE "+ RetSqlName('EZ0')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EZ0_CHVNFE = '" + cChaveEZ0 +"' ")
                     Endif 
                  Endif

               Endif
            Endif 
          ElseIf EZ0->EZ0_ACAO == "0" .AND. SuperGetMV("EZ_PX_PNAU" ,.F.,.F.) .AND. lIntGFE ;
               .AND. SuperGetMV("EZ_PX_GFE" ,.F.,.F.)
               // EZ_PX_GFE = .T. NA OCP PARA GERAR DOC DE ENTRADA DE FORMA AUTOMATICA
               // EZ_PX_GFE = .F. NOS CLIENTES QUE NAO GERAM DOC DE ENTRADA DE FORMA AUTOMATICA
               If !lSchedule
                  oProcess:=  MsNewProcess():New({|lEnd| ExecMATA140(aChaves,@oProcess,lEnd)}, "EZ4 GRC" , "Criando Notas de Entrada", .T.)
                  oProcess:Activate()
               Else
                  ExecMATA140(aChaves,@oProcess,lEnd)
               Endif
         ElseIf EZ0->EZ0_ACAO == "1" .AND. SuperGetMV("EZ_PX_PNAU" ,.F.,.F.)
            //********************************************************************
            // OCP - Inicio
            // Marcio Martins - 22/08/2022
            //********************************************************************
            If SuperGetMV("EZ_PX_PVAU" ,.F.,.F.)
               lEZ3Erro := .F.
               dbSelectArea("EZ2")
               cMSG := ""
               EZ2->(dbSetOrder(1))
               EZ2->(dbSeek(xFilial("EZ2")+EZ0->EZ0_CHVNFE))
               While !EZ2->(Eof()) .And. xFilial("EZ2")+EZ0->EZ0_CHVNFE == EZ2->(EZ2_FILIAL+EZ2_CHVNFE)
                  If EZ2->EZ2_STATUS == '2'
                     If !"Informe o Depto Fiscal: " $ cMsg
                        cMsg += "Informe o Depto Fiscal: " + ENTER
                        cMsg += "Documento nr: "+ EZ0->EZ0_DOC + "-" + EZ0->EZ0_SERIE + ENTER
                     Endif 
                     cMsg += Alltrim(EZ2->EZ2_MSG) + ENTER             
                     lEZ3Erro    := .T.
                     EXIT 
                  Endif 
                  EZ2->(dbSkip())
               Enddo
               If !lEZ3Erro
                  dbSelectArea("SF2")
                  SF2->(dbSetOrder(1))
                  If SF2->(dbSeek(xFilial("SF2")+EZ0->EZ0_NUMNFE+EZ0->EZ0_SERIE))
                     If EZ0->EZ0_STINTE <> '1'
                        RecLock('EZ0',.F.)
                        EZ0->EZ0_STINTE := '1'
                        MsUnlock()
                     Endif 
                  Else 
                     // CARLA BARBOSA - SEMAFORO PARA CONTROLE DOS PEDIDOS DE VENDA
                     // 05/06/23
                     if BLQSEMAF(EZ0->EZ0_FILIAL,EZ0->EZ0_NUM,EZ0->EZ0_NUMNFE,EZ0->EZ0_SERNFE)
                        NFSaidaAuto(.F.) 
                        LIBSEMAF(EZ0->EZ0_FILIAL,EZ0->EZ0_NUM)
                     Endif 
                  Endif                 
               Else
                  If !Empty(cMsg)
                     cMsg += "Documento nao foi gerado"
                     If !lSchedule
                        Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
                     else
                        Conout(cMsg)
                     Endif 
                  Endif
               Endif 
               //********************************************************************
               // OCP - Fim
               //********************************************************************
            Else
               aChavNFS := {}
               For nX := 1 to Len(aChaves)
                  aAdd(aChavNFS,aChaves[nX])
               Next nX 
               If !lSchedule
                  If Len(aChavNFS) > 0
                     oProcess:=  MsNewProcess():New({|lEnd| ExecMATA410(aChavNFS,@oProcess,lEnd,lSchedule)}, "EZ4 GRC" , "Gerando Pedidos", .T.)
                     oProcess:Activate()
                  Endif
               Else 
                  ExecMATA410(aChavNFS,@oProcess,lEnd,lSchedule)
               Endif
            Endif 
         Endif 
      Endif 

   Endif

Return lRet

/*=====================================================================================================================================*/
// Funcao para gera��o de notas de sa�da em processo automatico
/*=====================================================================================================================================*/
Static Function NFSaidaAuto(lSchedule) 

   Local oProcess
   Local lEnd := .F. 
   Local lCriaPed := .F.

   // MARCIO MARTINS - 07/10/2022 - OCP
   dbSelectArea("SC5")
   SC5->(dbSetOrder(1))
   If !SC5->(dbSeek(xFilial("SC5")+EZ0->EZ0_NUM))
      lCriaPed := .T.
      aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
      aChavNFS := {}
      aadd(aChavNFS,aChaves[1])
      If !lSchedule
         oProcess:=  MsNewProcess():New({|lEnd| ExecMATA410(aChavNFS,@oProcess,lEnd,lSchedule)}, "EZ4 GRC" , "Gerando Pedidos", .T.)
         oProcess:Activate()
      Else 
         ExecMATA410(aChavNFS,@oProcess,lEnd,lSchedule)
      Endif
   Endif 

   cMsg := ''
   dbSelectArea("SC5")
   SC5->(dbSetOrder(1))
   If SC5->(dbSeek(xFilial("SC5")+EZ0->EZ0_NUM))
      RecLock("SC5",.F.)
      SC5->C5_XNFSXML := StrZero(Val(EZ0->EZ0_DOC),9)
      SC5->C5_XSERXML := EZ0->EZ0_SERIE
      SC5->C5_XCHVNFE := EZ0->EZ0_CHVNFE
      MsUnlock()
      NFSProcess(cMsg,lCriaPed)
   Endif

   If !Empty(cMsg) .and. "Nao Gerada" $ cMsg

         cGRPPIA:= SuperGetMV("EZ_GRPPIA",.F.,"")
         If !Empty(cGRPPIA) .And. '110' $ cGRPPIA

            cMsgExec := cMsg
            
            aDados    := {}
            aArquivos := {}
            cEmails   := ""
            cGrupo := "110"
            dbSelectArea("EZ8")
            EZ8->(dbSetOrder(2))
            EZ8->(dbSeek(xFilial("EZ8")+cGrupo ))
            While !EZ8->(Eof()) .And. xFilial("EZ8")+cGrupo == EZ8->(EZ8_FILIAL+EZ8_CODIGO)
               cEmails += Alltrim(EZ8->EZ8_EMAIL)+";"
               EZ8->(dbSkip())
            Enddo
            
            dbSelectArea("SA1")
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial("SA1")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
            cFornec := EZ0->EZ0_FORNEC+"/"+EZ0->EZ0_LOJA+" "+Alltrim(SA1->A1_NOME)     

            aAdd(aDados, 5)                                                               // 1  Opcao para sele��o do workflow
            aAdd(aDados, EZ0->EZ0_NUMNFE)                                                 // 2  N�mero da nota
            aAdd(aDados, cEmails)                                                         // 4  E-mails do grupo
            aAdd(aDados, SM0->M0_FILIAL)                                                  // 5  Planta
            aAdd(aDados, cFornec)                                                         // 6  Codigo/loja/Nome Cliente
            aAdd(aDados, "MOTIVOS: " + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + Alltrim(cMsgExec))                                  // 8  Motivo da ocorr�ncia

            fEnvEmail(aDados, aArquivos)
         
         Endif 
   Endif 
   
Return


/*=====================================================================================================================================*/
// Funcao para Controle de log de usuarios e processos
/*=====================================================================================================================================*/
User Function RegLogUser(cAcaoLog, cMotivo)

   Local aAreaEZ6   := EZ6->(GetArea())
   Local cDescricao := ""
   Local lRetLog    := .T.

   Default cMotivo := ""

   If cAcaoLog == '1'
      cDescricao := "Integracao Automatico"
   ElseIf cAcaoLog == '2'
      cDescricao := "Integracao Manual"
   ElseIf cAcaoLog == '3'
      cDescricao := "Avaliar ocorrencias"
   ElseIf cAcaoLog == '4'
      cDescricao := "Enviado para Portaria"
   ElseIf cAcaoLog == '5'
      cDescricao := "Enviado para Recebimento Fisico"
   ElseIf cAcaoLog == '6'
      cDescricao := "Enviado para Fiscal"
   ElseIf cAcaoLog == '7'
      cDescricao := "WF Aceite Enviado"
   ElseIf cAcaoLog == '8'
      // Alterado conforme chamado 58787
      cDescricao := "WF para Suprimentos"
   ElseIf cAcaoLog == '9'
      cDescricao := "WF Recusa Enviado"
   ElseIf cAcaoLog == 'A'
      cDescricao := "Doc. Classificado"
   ElseIf cAcaoLog == 'B'
      cDescricao := "Doc.Ok - Documento Gerado"
   ElseIf cAcaoLog == 'C'
      cDescricao := "Erro na Geracao do Documento
   ElseIf cAcaoLog == 'D'
      cDescricao := "Portaria - Aguardando Solucao"
   ElseIf cAcaoLog == 'E'
      cDescricao := "Portaria - Pesagem Final/Saida do veiculo"
   ElseIf cAcaoLog == 'F'
      cDescricao := "Monitor de Ocorrencias"
   ElseIf cAcaoLog == 'G'
      cDescricao := "EZ4 GRC"
   ElseIf cAcaoLog == 'H'
      cDescricao := "WF Divergencia Recebimento"
   Endif
   
   dbSelectArea("EZ6")
   EZ6->(dbSetOrder(1))    // EZ6_FILIAL+EZ6_CHVNFE+EZ6_DTLOG+EZ6_HRLOG
   If !EZ6->(dbseek(xFilial("EZ6")+EZ0->EZ0_CHVNFE))
      // Pode ser o primeiro registro
      lRetLog := .T.
   Else 
      While !EZ6->(Eof()) .And. xFilial("EZ6")+EZ0->EZ0_CHVNFE == EZ6->(EZ6_FILIAL+EZ6_CHVNFE)// Tratamento para evitar duplicidades no historico.
         If EZ6->EZ6_ACAO == cAcaoLog
            lRetLog := .F.
            exit 
         Endif 
         EZ6->(dbSkip())
      Enddo
   Endif       
   If lRetLog 
      RecLock("EZ6",.T.)
      EZ6->EZ6_FILIAL   := xFilial("EZ6")
      EZ6->EZ6_CHVNFE   := EZ0->EZ0_CHVNFE 
      EZ6->EZ6_DTLOG    := dDatabase 
      EZ6->EZ6_HRLOG    := Time()
      EZ6->EZ6_USERLG   := cUsername
      EZ6->EZ6_ACAO     := cAcaoLog
      EZ6->EZ6_DESCR    := cDescricao + If(!Empty(cMotivo),"- Motivo: " + Alltrim(cMotivo),"")
      MsUnLock()
   Endif 

   RestArea(aAreaEZ6)

Return 

/*=====================================================================================================================================*/
// Funcao para Controle de log de usuarios e processos
/*=====================================================================================================================================*/
User Function AndaProcesso(cOpcProc,lSchedule)

   Local lRetAval := .T.
   Local aChvnfe  := {}
   Local lCont    := .T.
   Local i        := 0 
   Local cMsg     := " "
   Local lPulaPor := SuperGetMV("EZ_PULAPOR",.F.,.F.) 

   Private lUsaWFExt  := SuperGetMV("EZ_USAWFEX",.F.,.F.)   // USA WORKFLOW EXTERNO PARA INFORMAR FORNECEDORES
   Private lUsaPort   := SuperGetMV("EZ_USAPORT",.F.,.F.)   // USA MoDULO DE PORTARIA
   Private nVersion   := SuperGetMV("EZ_VERSION",.F.,0)    // Versao que esta sendo utilizada
   Private lAtivaMan  := SuperGetMV("EZ_ATVMAN",.F.,.F.)    // Ativa o Manifesto para recusar documentos   
   Private _lPreNota  := SuperGetMV("EZ_PRENOTA",.F.,.T.) 

   Private lMsErroAuto := .F.
   Private lAutoErrNoFile := .T.
   Private aGrcNf     := {}

   Default lSchedule  := .f.

   dbSelectArea("EZ2")
   EZ2->(dbSetOrder(1))
   If EZ2->(dbSeek(xFilial("EZ2")+EZ0->EZ0_CHVNFE))
      While !EZ2->(Eof()) .And. xFilial("EZ2")+EZ0->EZ0_CHVNFE == EZ2->(EZ2_FILIAL+EZ2_CHVNFE)
         If EZ2->EZ2_STATUS == '2'
            lRetAval := .F.
            Exit
         Endif 
         EZ2->(dbSkip())
      Enddo 
   Endif
   
   If lPulaPor .And. cOpcProc == '1' .And. EZ0->EZ0_TIPONF <> "CTe"
      cOpcProc := '2'
   Elseif cOpcProc == 'A' .And. EZ0->EZ0_TIPONF == "CTe"
      cOpcProc := 'A'
   Elseif EZ0->EZ0_TIPONF == "CTe"
      Return 
   Endif    

   If cOpcProc == '1'  // Integracao -> Portaria

      If EZ0->EZ0_STINTE == '2'  // possui erros de validacao

         If !lRetAval
            U_RegLogUser("1")   // Integracao Automatico
            U_RegLogUser("3")   // Avaliacao de Ocorrencias
         Endif 

      ElseIf EZ0->EZ0_STINTE == '4' // Esta Apto, so depende da avaliacao das ocorrencias
      
         // Posso incluira checagem do processo da SEFAZ aqui

         If lRetAval
            RecLock("EZ0",.F.)
            EZ0->EZ0_XMLOK := "1"   // Significa que esta Autorizado
            MsUnlock()
            U_RegLogUser("1")   // Integracao Automatico
            U_RegLogUser("4")   // Integracao -> Portaria
            If lUsaWFExt
               WFOkFornec()
            Endif 
         Else
            U_RegLogUser("3")   // Avaliacao de Ocorrencias
         Endif  

      Endif 

   ElseIf cOpcProc == '2' // Portaria -> Recebimento Fisico
      
      RecLock("EZ0",.F.)
      EZ0->EZ0_STINTE := "6"
      U_RegLogUser("5")   // Recebimento Fisico      
      MsUnlock()     
   
   ElseIf cOpcProc == '3' // Recebimento Fisico -> Fiscal

      If lRetAval

         lImporta  := .F.
         lExisteF1 := .F.

         SF1->(dbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
         If SF1->(dbseek(xfilial('SF1')+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA)))
            lExisteF1 := .T.
            dbSelectArea("SD1")  // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
            SD1->(dbSetOrder(1))
            If SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
               While !SD1->(Eof()) .And. xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
                  If SubStr(SD1->D1_CF,1,1) == '3' .or. SF1->F1_EST == "EX"  // ACRESCENTADO POR CARLA - PARA NOTAS DE IMPORTA�A� QUE N�O ESTAO CLASSIFICADAS
                     lImporta := .T.
                     // Carla Barbosa 18/08/2022
                     // Acrescentado trecho para grava��o dO TES conforme portal
                     if alltrim(SD1->D1_TES) == "" // mudar aqui para empty de tes
                        cTes := Posicione("EZ1",1,EZ0->(EZ0_FILIAL+EZ0_CHVNFE)+SD1->D1_ITEM,"EZ1_TES")
                        RecLock("SD1",.F.)
                        SD1->D1_TES := cTes
                        MsUnlock()
                     Endif
                     Exit
                  Endif 
                  SD1->(dbSkip())
               Enddo 
            Endif 
         Endif 

         //------------------------------------------------------------------------------------------
         // Marcio Martins - 05/06/2023
         // ITEM 30 - Existindo a nota, mudo o status da nota no portal para Nota Classificada
         //------------------------------------------------------------------------------------------
         If !lImporta
            dbSelectArea("SF3")
            SF3->(dbSetOrder(4)) // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
            If SF3->(dbSeek(xFilial("SF3")+EZ0->(EZ0_FORNECE+EZ0_LOJA+EZ0_NUMNFE+EZ0_SERIE))) // trocar para ez0
               Aviso( "EZ4 GRC" ,"Documento " + EZ0->EZ0_NUMNFE + " j� existente", {"OK"}, 3,"Criacao de Documento")    
               RecLock("EZ0",.F.)
               EZ0->EZ0_STATUS := "5"
               MsUnlock()
               Return .T.        
            Endif 
         Endif 
         //------------------------------------------------------------------------------------------
         // Fim
         //------------------------------------------------------------------------------------------

         If lExisteF1

            Pergunte("MTA103", .F.)

            dbSelectArea("SX1")
            
            // Correspoonde ao Visualizacao da contabilizacao
            SX1->(dbSetOrder(1))
            SX1->(dbSeek("MTA103    01"))
            RecLock("SX1",.F.)
            SX1->X1_PRESEL := 2
            MsUnlock()
            
            // Correspoonde ao Bloqueio Documento de Entrada
            SX1->(dbSetOrder(1))
            SX1->(dbSeek("MTA103    17"))
            RecLock("SX1",.F.)
            SX1->X1_PRESEL := 2
            MsUnlock()

            Pergunte("MTA103", .F.)
            MV_PAR01 := "2"  // Mostra contabilizacao -> 2-Nao
            MV_PAR17 := 2  // Bloqueia Mov. Usado na importacao
            
            If !lImporta

               dbSelectArea("SF1")
               SF1->(dbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
               If SF1->(dbSeek(xFilial("SF1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA)))
                  RecLock("SF1",.F.)
                  SF1->F1_CHVNFE := EZ0->EZ0_CHVNFE
                  MsUnlock()
               Endif 

               dbSelectArea("EZ1")
               EZ1->(dbSetOrder(1))
               EZ1->(dbseek(xFilial("EZ1")+EZ0->EZ0_CHVNFE))
               While !EZ1->(Eof()) .And. xFilial("EZ1")+EZ0->EZ0_CHVNFE == EZ1->(EZ1_FILIAL+EZ1_CHVNFE)
                  dbSelectArea("SD1")
                  SD1->(dbSetOrder(1))
                  If SD1->(dbSeek(xFilial("SD1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA)+EZ1->EZ1_COD))
                     RecLock("SD1",.F.)
                     If SD1->(FieldPos("D1_PETVALI")) > 0   // Especifico da Crown
                        SD1->D1_PETVALI := 'X'
                     Endif 
                     If SD1->(FieldPos("D1_CRWVANF")) > 0   // Especifico da Crown
                        SD1->D1_CRWVANF := 'X'
                     Endif      
                     If EZ1->(FieldPos("EZ1_CC")) > 0                
                        If !Empty(EZ1->EZ1_CC)
                           SD1->D1_CC := EZ1->EZ1_CC
                        Endif 
                     Endif 
                     If EZ1->(FieldPos("EZ1_CLVL")) > 0                
                        If !Empty(EZ1->EZ1_CLVL)
                           SD1->D1_CLVL := EZ1->EZ1_CLVL
                        Endif 
                     Endif 
                     If EZ1->(FieldPos("EZ1_ICMSRE")) > 0                
                        If !Empty(EZ1->EZ1_ICMSRE)
                           SD1->D1_ICMSRET := EZ1->EZ1_ICMSRE
                        Endif
                     Endif 
                     If EZ1->(FieldPos("EZ1_BRICMS")) > 0                
                        If !Empty(EZ1->EZ1_BRICMS)
                           SD1->D1_BRICMS := EZ1->EZ1_BRICMS
                        Endif
                     Endif 
                     If EZ1->(FieldPos("EZ1_DESCRI")) > 0
                        If !Empty(EZ1->EZ1_DESCRI)
                           If SD1->(FieldPos("D1_CDESCRI")) > 0   // Especifico da Crown
                              SD1->D1_CDESCRI := Alltrim(EZ1->EZ1_DESCRI)
                           Endif 
                        Endif 
                     Endif 
                     If EZ1->(FieldPos("EZ1_CONTA")) > 0                
                        If !Empty(EZ1->EZ1_CONTA)
                           SD1->D1_CONTA := EZ1->EZ1_CONTA
                        Endif
                     Endif 
                     MsUnlock()
                  Endif 
                  EZ1->(dbSkip())
               Enddo 

               // Aqui eu trato a carga do acabec percorrendo o SF1

               aCabec := {}

               dbSelectArea("SF1")
               SF1->(dbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
               If SF1->(dbSeek(xFilial("SF1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA)))
                  For i := 1 To SF1->(FCount())
                     cCampof1 := SF1->(FieldName(i))
                     If !empty(SF1->&(cCampof1))
                        aadd(aCabec, {cCampof1 , SF1->&(cCampof1) ,, } )
                     EndIf
                  Next i
               Endif 
      
               // Aqui eu tato a carga do aItens percorrendo o SD1
               
               aAux   := {}
               aItens := {}

               dbSelectArea("SD1")
               SD1->(dbSetOrder(1))
               If SD1->(dbSeek(xFilial("SD1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA)))
                  While !SD1->(Eof()) .And. xFilial("SD1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNEC+EZ0_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
                     aAux := {}
                     for i := 1 To SD1->(FCount())
                        cCampod1 := SD1->(FieldName(i))
                        If Alltrim(cCampod1) == "D1_TES"
                           cTes := Posicione("EZ1",1,EZ0->(EZ0_FILIAL+EZ0_CHVNFE)+SD1->D1_ITEM,"EZ1_TES")
                           aadd(aAux, {"D1_TES" , cTes ,, } )
                        Else 
                           If !empty(SD1->&(cCampod1))
                              aadd(aAux, {cCampod1 , SD1->&(cCampod1) ,, } )
                           Endif
                        Endif 
                     next i
                     aadd(aItens,aAux)     
                     SD1->(dbSkip())
                  Enddo
               Endif 

               If Len(aItens) > 0 .And. Len(aCabec) > 0 

                  lMsErroAuto := .F.
                  // CLASSIFICANDO A NF
                  MsgRun("Gerando Documento de Entrada","Processando",{|| MsExecAuto({|x,y,z,a|MATA103(x,y,z,a)}, aCabec, aItens, 4)})

                  if len(aGrcNf)==0 .and. !lMsErroAuto // Documento N�o foi gerado
                     If lSchedule
                        cMsg  += "Houve erro na Execu��o do ExecAuto " + CRLF
                        cMsg  += "Documento n�o foi gerado. Por favor Verifique" +  CRLF
                        Conout("Documento nao foi gerado! Por favor verifique")
                        lConfirmado := .F.
                        lOkNota := .F.
                     else
                        cMsg  += "Houve erro na Execu��o do ExecAuto " + CRLF
                        cMsg  += "Documento n�o foi gerado. Por favor Verifique" +  CRLF
                        lConfirmado := .F.
                        lOkNota := .F.
                     endif
                     RecLock("EZ0",.F.)
                     EZ0->EZ0_STINTE := "4"                       
                     MsUnlock()   
                  ElseIf lMsErroAuto                  

                     lCont := .F.
                     aErro := GetAutoGRLog()
                     For i := 1 To Len(aErro)
                        cMsg += aErro[i] + Chr(13) + Chr(10)
                     Next i
                     If lUsaPort
                        U_RegLogUser("C")
                     Endif 
                     DisarmTransaction()
                     
                     If IsInCallStack("u_SCHEDFILE")
		                  Conout(cMsg)
                     Else 
                        // Carla Barbosa
                        // Returado trecho abaixo - Error.log Variavel lSchedule inexistente
                        Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
                        /*
                        If !lCont .And. !Empty(cMsg)
                           If !lSchedule
                              Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
                           else
                              Conout(cMsg)
                           Endif 
                        Endif 
                        */
                     Endif                      

                  Else 

                     lCont := .T.
                     dbSelectArea("EZ0")
                     RecLock("EZ0",.F.)
                     EZ0->EZ0_STINTE := '5'
                     MsUnlock()
                     // Carla Barbosa 06/12/22
                     // Desabilitado para Fazer a Manifesta��o independente do uso da Portaria
                     //If lUsaPort
                        If lAtivaMan
                           U_ManifChave(EZ0->EZ0_CHVNFE,"210200") // 210200 - Confirmacao da Operacao            
                        Endif 
                        U_RegLogUser("A")      
                     //Endif 

                    // 21/02/2023 - CARLA BARBOSA
                     // Cria��o de Ponto de Entrada para tratamento ap�s grava��o da NF Entrada
                     // SF1 - POSICIONADA
                     If ExistBlock("PPFIMSF1")
                        ExecBlock("PPFIMSF1", .F., .F.)
                     Endif                 
                   Endif 

               Endif 

            else
               
               U_PxmClassNota(.T.)

            Endif

         Else 

            lCont := .T.
            EZ0->(aadd(aChvnfe,{EZ0_CHVNFE,EZ0->(RECNO()),EZ0_TIPONF}))
            oProcess:=  MsNewProcess():New({|lEnd| lCont := ExecMATA140(aChvnfe,@oProcess,lEnd)}, "EZ4 GRC" , "Criando Documentos", .T.)
            oProcess:Activate()
            If lCont 
               U_RegLogUser("6") // Envia para Fiscal
            Endif
         Endif 

      Else

         MsgAlert("Ha erros de Validacao no XML, Verifique no EZ4 GRC")
         
      Endif 

   ElseIf cOpcProc $'A|' // Recebimento Fisico

      If lRetAval
         lCont := .T.
         EZ0->(aadd(aChvnfe,{EZ0_CHVNFE,EZ0->(RECNO()),EZ0_TIPONF}))
         oProcess:=  MsNewProcess():New({|lEnd| lCont := ExecMATA140(aChvnfe,@oProcess,lEnd)}, "EZ4 GRC" , "Criando Documentos", .T.)
         oProcess:Activate()
         If lCont 
            // Carla Barbosa - 05/02/2024
            // Ajuste Status do Documento ap�s Gera��o Via Recebimento F�sico
            // Estava gerando sempre como Ag Classifica��o
            U_RegLogUser("6") // Envia para Fiscal
            RecLock("EZ0",.F.)
            If _lPreNota
               EZ0->EZ0_STINTE := "7"  // Documento Aguardando Classifica��o
            Else
               EZ0->EZ0_STINTE := '5'  // Documento Classificado
            Endif 
            MsUnlock()
         Else
            RecLock("EZ0",.F.)
            EZ0->EZ0_STINTE := "2"
            MsUnlock()
         Endif 
      Else
         RecLock("EZ0",.F.)
         EZ0->EZ0_STINTE := "2"
         MsUnlock()
         U_RegLogUser("3")   // Avaliacao de Ocorrencias
      Endif 
      
   Endif 

Return lCont

/*=====================================================================================================================================*/
// Funcao para exibir em tela o XML para processamento.
/*=====================================================================================================================================*/
Static Function Carrega() 

   Local lRet:= .f.

   //cXML := MemoRead(cArquivo )
   cXML := LeArqXML(cArquivo)
   PutMV("EZ_PX_UAR",cArquivo)
   if len(AllTrim(cXML)) > 0
      cXML := StrTran(cXML, "><" ,">"+chr(10)+chr(13)+"<") // Melhorar a exibicao
      lRet:= .T.
   endif

return lRet

/*=====================================================================================================================================*/
// Funcao para exibir em tela o XML para processamento.
/*=====================================================================================================================================*/
Static Function LeArqXML(cArquivo)

   Local nTamTot:=0, nLidos:=0
   Local nHandle:=0, nPasso:=50000
   Local cRet := '', cXMLarq:=""

   nHandle := fOpen(cArquivo,FO_READ+FO_EXCLUSIVE) // abre o arquivo XML
   nTamTot := fSeek(nHandle,0,2)                   // descobre o tamanho total
   fSeek(nHandle,0,0)                              // retorna ao inicio
   nLidos := fRead(nHandle,@cXMLarq,nPasso)        // le o arquivo em lotes de 50000 caracteres

   while nLidos>0
         cRet+=cXMLarq                             // acumula o conteudo lido
         cXMLarq:=""                               // zera para nova leitura
         nLidos:=fRead(nHandle,@cXMLarq,nPasso)    // le o arquivo de em faixas de 50000
   Enddo
   fClose(nHandle)                                // Fecha o arquivo XML

Return cRet

/*=====================================================================================================================================*/
Static Function AbreChv(cCHVNFE)
/*=====================================================================================================================================*/

   EZ0->EZ0_FILIAL := xFilial('EZ0')
   EZ0->EZ0_CHVNFE := cCHVNFE
   EZ0->EZ0_SERNFE := SubStr(cCHVNFE,23,03)
   EZ0->EZ0_SERIE  := SubStr(cCHVNFE,23,03)
   EZ0->EZ0_NUMNFE := SubStr(cCHVNFE,26,09)
   EZ0->EZ0_DOC    := SubStr(cCHVNFE,26,09)
   EZ0->EZ0_CNPJEM := SubStr(cCHVNFE,07,14)
   EZ0->EZ0_MESNFE := SubStr(cCHVNFE,05,02)
   EZ0->EZ0_ANONFE := "20"+SubStr(cCHVNFE,03,02)
   SA2->(dbSetOrder(3))
   if SA2->(dbSeek(xfilial('SA2')+EZ0->EZ0_CNPJEM))
      EZ0->EZ0_FORNEC := SA2->A2_COD
      EZ0->EZ0_LOJA   := SA2->A2_LOJA
      EZ0->EZ0_NOEMIT := SA2->A2_NOME
   else
      SA1->(dbSetOrder(3))
      if SA1->(dbSeek(xfilial('SA1')+EZ0->EZ0_CNPJEM))
         EZ0->EZ0_FORNEC := SA1->A1_COD
         EZ0->EZ0_LOJA   := SA1->A1_LOJA
         EZ0->EZ0_NOEMIT := SA1->A1_NOME
      endif
   endif

return


/*=====================================================================================================================================*/
Static Function AbreAs400(cOrderType,cChvNFe,cCliente,cInvDate)
/*=====================================================================================================================================*/
EZH->(dbgotop())  // Cadastro de Tipos de Venda
EZH->(dbsetorder(1))
if EZH->(dbseek(xFilial(("EZH")+cOrderType)))
   cFilEZ0 := EZH->EZH_FILFAT
   cCODOPE := EZH->EZH_CODOPE
   lRet    :=  .t.
Else
   lRet    := .f.  
Endif
EZ0->EZ0_FILIAL := cFilEZ0
EZ0->EZ0_CHVNFE := cCHVNFE
EZ0->EZ0_MESNFE := SubStr(cInvDate,05,02)
EZ0->EZ0_ANONFE := SubStr(cInvDate,01,04)
SA1->(dbSetOrder(1))
if SA1->(dbSeek(xfilial('SA1')+cCliente))
   EZ0->EZ0_FORNEC := SA1->A1_COD
   EZ0->EZ0_LOJA   := SA1->A1_LOJA
   EZ0->EZ0_NOEMIT := SA1->A1_NOME
   EZ0->EZ0_CNPJEM := SA1->A1_CGC
endif
return

/*=====================================================================================================================================*/
User Function Busca00(oSelf, lSchedule, nRestam)

   Local cQry     := "" 
   Local aChave := {}
   Local nContador := 0
   Local nTotal   := 20
   nTotal   := ( nTotal-nRestam )
   /*
   EzCheckPar(xFilial("EZ0"))
   cUltNSU	 := GetMV("EZ_PX_NSU") 
   dDatNsu   := GetMV("EZ_PX_DNSU") 
   cHorNsu   := GetMV("EZ_PX_HNSU")

   If !lSchedule
      if dDatNsu == (dDatabase)
         if ElapTime(cHorNsu, Time()) <= "01:05:00"
            lRet := .f.
         ENDIF
      elseif DateDiffDay(dDatNsu,dDatabase) == 1
            if ElapTime(cHorNsu, Time()) <= "01:05:00"
               lRet := .f.
            Endif
      Else
         lRet := .t.
      Endif  
      if !lRet
         Conout("A Rotina de Busca de Notas Via Schedules J� Foi Executada h� menoss de 1 hora")
         if !lSchedule
            MSgAlert("A Rotina de Busca de Notas Via Schedules J� Foi Executada h� menoss de 1 hora")
         Endif
         Return
      Endif
   Endif
   */
   // Busca o XML
   /*
   cQry:=" SELECT EZ0.EZ0_CHVNFE, EZ0.R_E_C_N_O_ RECEZ0 FROM " + RetSqlName("EZ0") + "  EZ0
   cQry+=" INNER JOIN " + RetSqlName("C00") + " C00  ON EZ0.EZ0_FILIAL = C00.C00_FILIAL AND EZ0.EZ0_CHVNFE = C00.C00_CHVNFE "
   cQry+=" WHERE C00_FILIAL = '" + xFilial("C00") + "' AND C00.D_E_L_E_T_ = ' ' AND EZ0.D_E_L_E_T_ = ' ' "
   cQry+=" AND EZ0.EZ0_TIPO = ' ' "
   cQry+=" AND EZ0_ANONFE >= '"+Alltrim(str(year(DATE()-75)))+"' "
   cQry+=" AND EZ0_MESNFE >= '"+strzero(month(DATE()-75),2)+"' "
   cQry+=" ORDER BY EZ0_MESNFE "
   AbreQuery(cQry,"QRYC00")
   */
   cQry:=" SELECT EZ0.EZ0_CHVNFE, EZ0.R_E_C_N_O_ RECEZ0, EZ0_MESNFE,EZ0_ANONFE "
   cQry+=" FROM " + RetSqlName("EZ0") + "  EZ0 "
   cQry+=" WHERE EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0.D_E_L_E_T_ = ' ' "
   cQry+=" AND EZ0_ANONFE >= '"+Alltrim(str(year(DATE()-40)))+"' "
   cQry+=" AND EZ0_MESNFE >= '"+strzero(month(DATE()-40),2)+"' "
   cQry+=" AND EZ0_STINTE = '3' "
   cQry+=" AND EZ0_STATUS <> '4' "
   cQry+=" AND (EZ0_CODRET = ' ' OR EZ0_CODRET = '138') "
   cQry+=" ORDER BY EZ0_ANONFE, EZ0_MESNFE "
   AbreQuery(cQry,"QRYC00")

   While !QRYC00->(Eof())  // cria registro na work
      If nContador <= nTotal
         aadd(aChave, { QRYC00->EZ0_CHVNFE, QRYC00->RECEZ0})
         nContador++
      Endif 
      QRYC00->(dbSkip())
   Enddo
   QRYC00->(dbCloseArea())  

   If Len(aChave) > 0 
      ProcChave(oSelf, lSchedule,aChave)
   Endif 
   
Return


/*=====================================================================================================================================*/
User Function BuscaNSU()

   Local cQry      := "" 
   Local aChaveNSU := {} 
   Local nContador := 0
   Local lSchedule := .T.
   Local oSelf

   EzCheckPar(xFilial("EZ0"))
   cUltNSUC := GetMV("EZ_PX_NSUC") 

   cQry:=" SELECT EZC_NSU, EZC_CHVNFE, EZC_FILIAL, EZC_FLGBAI, EZC.R_E_C_N_O_ "  // Carla Barobssa / Márcio Martins - 17/05/2023
   cQry+=" FROM " + RetSqlName("EZC") + "  EZC "
   cQry+=" WHERE EZC_FILIAL = '" + xFilial("EZC") + "' AND EZC.D_E_L_E_T_ = ' ' "
   cQry+=" AND EZC_FLGBAI   = '0' "
   cQry+=" ORDER BY 1 "
 
  AbreQuery(cQry,"QRYC00")

   if  !QRYC00->(Eof())
 
      while QRYC00->(!Eof())

         if nContador < 20
            aChaveNSU := {}
            aadd(aChaveNSU, { QRYC00->EZC_NSU })            
            If ProcNSU(oSelf, lSchedule,aChaveNSU)
               //nLastNsu := nLastNsu  + 1
               nContador++
            Else
               conout("[BUSCANSU] - NSU: " + QRYC00->EZC_NSU + " ERRO NA BUSCA - REJEI?O 656 OU SEM DOCUMENTOS")// Deu Rejei? ou Sem Documentos - Parar a Busca
               //exit
            Endif
         else
            conout("[BUSCANSU] - ATINGIU AS 20 BUSCAS PERMITIDAS NESTA HORA")
            exit
         Endif
         QRYC00->(dbSkip())
      enddo
   endif

Return

/*=====================================================================================================================================*/
// Area para funcoes auxiliares
/*=====================================================================================================================================*/
static function AbreQuery(cQry,cArea,cUserId,cFile)

   // fecha workarea se ja existe
   if Select(cArea) > 0
      (cArea)->(DBCLOSEAREA())
   EndIf
   // executa a query
   DbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cQry)), cArea, .F., .T. )

return

/*=====================================================================================================================================*/
// Grupo de funcoes para configuracao da ferramenta
/*=====================================================================================================================================*/
User Function ConfParam()  // Tela para configuracao de Parametros.

   // Variaveis para a TELA
   Local aCoors  := FWGetDialogSize( oMainWnd )
   Local oDlgParam, oLy, oPnUp, oPnDown

   // variaveis Auxiliares
   Local aButtons := {}, TopBt := 4
   local nGrava:=0
   local aGets := {} ,cVar:="" , i:=0
   Local aOrdem :={  "EZ_PX_INI" ,"EZ_PX_ADM" ,"EZ_PX_UAR" ,"EZ_PX_ACC" ,"EZ_PX_PSW" ,;
                     "EZ_PX_MSV" ,"EZ_PX_MPT" ,"EZ_PX_PTL" ,"EZ_PX_SSV" ,"EZ_PX_SPT" ,;
                     "EZ_PX_SSL" ,"EZ_PX_VSS" ,"EZ_PX_TLS" ,"EZ_PX_RID" ,"EZ_PX_TMO" ,;
                     "EZ_PX_MMS" ,"EZ_PX_RTP"}

   Raiz := 9      // Indica que a tela inicial Nao esta ativa

   // Criacao da janela
   oDlgParam:=TDialog():new()
   oDlgParam:nLeft	  := aCoors[1]
   oDlgParam:nTop	     := aCoors[2]
   oDlgParam:nHeight   := aCoors[3]
   oDlgParam:nWidth    := aCoors[4]*.95
   oDlgParam:lCentered := .T.
   oDlgParam:lEscClose := .T.
   oDlgParam:oParent   := oMainWnd
   oDlgParam:cCaption  := "EZ4 GRC - Configuracao de parametros"
   oDlgParam:lmaximized := .T.

   // criacao das area de tela
   oLy := FWLayer():New()
   oLy:Init( oDlgParam, .T. )
   // Define Painel Superior
   oLy:AddLine( 'UP', 7, .F. ) // LINHA COM 50% DA TELA
   oLy:AddCollumn( 'ALL', 100, .F., 'UP' ) // COluna com 100% da tamanho dela
   oPnUp := oLy:GetColPanel( 'ALL', 'UP' )

   // Define Painel Inferior
   oLy:AddLine( 'DOWN', 93 , .F. )            // LINHA COM 50% DA TELA
   oLy:AddCollumn( 'ALL' , 100, .F., 'DOWN' )// COluna com 100% da tamanho dela
   oPD := oLy:GetColPanel( 'ALL' , 'DOWN' ) // Pego o objeto do pedaco esquerdo
   aCoors  := FWGetDialogSize( oPD )
//   oPnDown := TScrollBox():New(oPD,oPD:nTop,oPD:nLeft,oPD:nHeight*.3,oPD:nWidth*.3,.T.,.T.,.T.)
   oPnDown := TScrollBox():New(oPD,aCoors[2]+1,aCoors[1]+1,aCoors[3]*.3,aCoors[4]*.3,.T.,.T.,.T.)
   oPnDown:Align := CONTROL_ALIGN_ALLCLIENT  
 
   aadd( aButtons, TButton():New( TopBt, lf(@aButtons) , "Gravar" ,oPnUp,{|| nGrava:=1,oDlgParam:end()  }, 50,12,,,.F.,.T.,.F.,,.F.,,,.F. ))
   aadd( aButtons, TButton():New( TopBt, lf(@aButtons) , "Sair"   ,oPnUp,{|| nGrava:=0,oDlgParam:end()  }, 50,12,,,.F.,.T.,.F.,,.F.,,,.F. ))

   SX6->(dbSetOrder(1)) // X6_FIL+X6_VAR
   // criacao dos gets com ordem pre definida
   for i:= 1 to len(aOrdem)
      if SX6->(dbSeek( xFilial()+aOrdem[i]))  // busca o parametro do EZ4 GRC
         cVar := StrTran( AllTrim(SX6->X6_VAR),"EZ_PX","Var")	// criacao dinamica da nome da variavel
         &cVar :=  SX6->X6_CONTEUD                 			// criacao dinamica da variavel   //SuperGetMV(SX6->X6_VAR,.f.,)
         ParGet(@aGets,@oPnDown,@cVar)
      endif
   next

   // // criacao dos gets de parametros Nao definidos anteriormente
   SX6->(dbSeek( xFilial()+"EZ_PX" ))  // Prefixo dos parametros do EZ4 GRC
   while SX6->( !eof() .and. X6_FIL=xFilial() .and.  left(X6_VAR,5) = "EZ_PX" )
      if ascan(aOrdem,AllTrim(SX6->X6_VAR))=0
         cVar := StrTran( AllTrim(SX6->X6_VAR),"EZ_PX","Var")			// criacao dinamica da nome da variavel
         &cVar :=  SX6->X6_CONTEUD                 					// criacao dinamica da variavel   //SuperGetMV(SX6->X6_VAR,.f.,)
         ParGet(@aGets,@oPnDown,@cVar)
      endif
      SX6->(dbSkip())
   enddo 

   oDlgParam:Activate()

   If nGrava==1																				// a janela foi fechada usando o botao grava
      SX6->(dbSetOrder(1)) // X6_FIL+X6_VAR
      SX6->(dbSeek( xFilial()+"EZ_PX" ))  // Prefixo dos parametros do EZ4 GRC
      while SX6->( !eof() .and. X6_FIL=xFilial() .and.  left(X6_VAR,5) = "EZ_PX" )
         SX6->(RecLock("SX6",.f.))
         cVar := StrTran( AllTrim(SX6->X6_VAR),"EZ_PX","Var")			// criacao dinamica da nome da variavel
         SX6->X6_CONTEUD := &cVar
         SX6->(dbUnlock())
         SX6->(dbSkip())
      enddo

      // atualiza o appserver.ini
      WritePPROString( "MAIL", "PROTOCOL", AllTrim(Var_PTL) , GetSrvIniName() )
      WritePPROString( "MAIL", "SSLVersion",AllTrim(Var_VSS) , GetSrvIniName() )

      MsgInfo("Parametros Atualizados")
   Else
      MsgInfo("Operacao cancelada")
   EndIf

   Raiz := 0  // Indica que a tela inicial volta a ficar ativa

return

/*=====================================================================================================================================*/
// criacao do Code Block que associa a variavel ao get
/*=====================================================================================================================================*/
static Function ParGet(aGets,oPnDown,cVar)

   Local i:= 0 ,cBloco := ""

   aAdd( aGets, TSAY():Create(oPnDown) )       // cria um label
   i:= len(aGets)
   aGets[i]:cCaption := SX6->(AllTrim(X6_VAR)+" - "+AllTrim(X6_DESCRIC)+" :")
   //aGets[i]:nTop     := (i-1)*14.5 + 2
   aGets[i]:nTop     := (i-1)*13.5 + 2
   aGets[i]:nLeft    := 03
   aGets[i]:nWidth   := SX6->(len(X6_VAR)+len(X6_DESCRIC))*4.2
   aGets[i]:nHeight  := 20

   aAdd( aGets,TGet():Create( oPnDown ) )
   i:= len(aGets)
   aGets[i]:nLeft    := aGets[i-1]:nLeft+aGets[i-1]:nWidth
   aGets[i]:nTop     := aGets[i-1]:nTop-2
   aGets[i]:nWidth   := Len(SX6->X6_CONTEUD)*4.2
   aGets[i]:nHeight  := aGets[i-1]:nHeight
   aGets[i]:cVariable:= cVar
   cBloco := "{|u| If(PCount()>0,"+cvar+":=u,"+cvar+") }"
   aGets[i]:bSetGet  := &cBloco
   if AllTrim(SX6->X6_VAR) = "EZ_PX_PSW"
      aGets[i]:lPassword:=.t.
   endif

return

/*=====================================================================================================================================*/
// Configuracao do Layout Prefeituras
/*=====================================================================================================================================*/
User Function ConfLayout() 
   
   Local  oBrw
   Private CCADASTRO:="Configuracao Layout Prefeituras"
   Private cTab:= 'EZ5'
   Raiz := 4     // Indica que a tela inicial Nao esta ativa
   oBrw:= FWmBrowse():New()
   oBrw:SetDescription( "Layout Prefeitura" )
   oBrw:SetMenuDef('EZ4_GRC_PORTALXML')    // ARQUIVO FONTE ONDE ESTA A MENUDEF
   oBrw:SetAlias( cTab )
   oBrw:Activate()
   Raiz := 0  // Indica que a tela inicial volta a ficar ativa

return

/*=====================================================================================================================================*/
// Tela para configuracao de Validacoes.
/*=====================================================================================================================================*/
User Function ConfValid() 
   
   Local  oBrw
   Private CCADASTRO:="Configuracao Validacoes"
   Private cTab:= 'EZ3'
   Raiz := 2     // Indica que a tela inicial Nao esta ativa
   oBrw:= FWmBrowse():New()
   oBrw:SetDescription( "Validacoes" )
   oBrw:SetMenuDef('EZ4_GRC_PORTALXML')    // ARQUIVO FONTE ONDE ESTA A MENUDEF
   oBrw:SetAlias( cTab )
   oBrw:Activate()
   Raiz := 0  // Indica que a tela inicial volta a ficar ativa

return

/*=====================================================================================================================================*/
// Tela para configuracao de captura por OCR
/*=====================================================================================================================================*/
User Function ConfOCR()

   Local  oBrw
   Local nX          := 0
   Local cQuery      := ""
   Local aColumns    := {}
   Local aFilter     := {}
   Local cAliasEZ9   := GetNextAlias()
   Private aStruct     := {}
   Private CCADASTRO :="Configura��o OCR"
   Private cTab      := 'WORKEZ9'
   SetKey(VK_F10 , {|| U_VldConfOcr() } )

   dbSelectArea("SX3")
   SX3->(dbSetOrder(1))
   SX3->(dbSeek("EZ9"))
   While !SX3->(Eof()) .And. SX3->X3_ARQUIVO = "EZ9"
      If SX3->X3_CONTEXT <> "V"
         //If X3usado(SX3->X3_CAMPO)
            Aadd(aStruct,{ SX3->X3_CAMPO , SX3->X3_TIPO   , SX3->X3_TAMANHO , SX3->X3_DECIMAL })
         //Endif 
      Endif 
      SX3->(dbSkip())
   Enddo

   //Set Columns
   aColumns := {}
   aFilter  := {}
   For nX := 1 To Len(aStruct)
      //Columns
      If aStruct[1,2] <> "M"
         AAdd(aColumns,FWBrwColumn():New())
         aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
         aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX][1]))
         aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
         aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
         aColumns[Len(aColumns)]:SetPicture(PesqPict("EZ9",aStruct[nX][1]))
         //Filters
         aAdd(aFilter, {aStruct[nX][1], RetTitle(aStruct[nX][1]), TamSX3(aStruct[nX][1])[3], TamSX3(aStruct[nX][1])[1], TamSX3(aStruct[nX][1])[2], PesqPict("EZ9", aStruct[nX][1])} )
      Endif  
   Next nX

   // Cria��o da temporaia WORKEZ9
   oTemptable := FWTemporaryTable():New()
   oTemptable:SetFields(aStruct)
   oTemptable:addindex('01', { "EZ9_FILIAL","EZ9_TIPDOC","EZ9_MODELO","EZ9_ORDEM" })
   oTemptable:Create()
   (cTab) := oTemptable:GetAlias()

   // Sele��o dos dados a serem copiados
   cQuery := " SELECT R_E_C_N_O_ RECEZ9 FROM " + RetSqlName("EZ9") + " EZ9 " + CRLF
   cQuery += " WHERE EZ9.D_E_L_E_T_ = ' ' AND EZ9_FILIAL = '" + xFilial("EZ9")+ "' " + CRLF
   cQuery += " ORDER BY EZ9_TIPDOC, EZ9_MODELO, EZ9_ORDEM " + CRLF
   cQuery := ChangeQuery(cQuery)

   PlsQuery(cQuery,cAliasEZ9)

   nOrder := 01

   If !(cAliasEZ9)->(Eof())

      // Grava��o dos dados em uma temporaria cAliasTmp
      While !(cAliasEZ9)->(Eof())
         EZ9->(dbGoTo((cAliasEZ9)->RECEZ9))
         RecLock((cTab),.T.)
         For nX := 1 To Len(aStruct)
            cCampo := AllTrim(aStruct[nX,1])
            If !Alltrim(cCampo) $ "EZ9_FILIAL|EZ9_TIPDOC|EZ9_MODELO|EZ9_ORDEM|EZ9_CPOSX3|EZ9_ROTDES|EZ9_ATIVO|EZ9_NIVEL|EZ9_RETROC|EZ9_DTIMP|EZ9_HRIMP" // Campos que n�o ser�o criptografados
               If TAMSX3(cCampo)[3] $ "C|M" .and. !Empty(EZ9->&(cCampo))   // Apenas campos caracteres e Memos que n�o estejam v�zios
                  (cTab)->&(cCampo) := U_CriptoGr(EZ9->&(cCampo),2)
               Else 
                  (cTab)->&(cCampo) := EZ9->&(cCampo)
               Endif 
            Else 
               (cTab)->&(cCampo) := EZ9->&(cCampo)
            Endif 
         Next nI
         MsUnlock()
         (cAliasEZ9)->(dbSkip())
      Enddo
   Endif 
   (cAliasEZ9)->(dbCloseArea())
   
   (cTab)->(dbGoTop())

   Raiz := 5     // Indica que a tela inicial Nao esta ativa
   oBrw:= FWmBrowse():New()
   oBrw:SetAlias(cTab)
   oBrw:SetDescription( "Configura��o OCR" )
   oBrw:SetTemporary(.T.)
   oBrw:SetUseFilter(.T.)
   oBrw:OptionReport(.F.)
   oBrw:SetColumns(aColumns)
   oBrw:SetFieldFilter(aFilter)
   oBrw:SetMenuDef('EZ4_GRC_PORTALXML')    // ARQUIVO FONTE ONDE ESTA A MENUDEF
   oBrw:Activate()

   Raiz := 0  // Indica que a tela inicial volta a ficar ativa

   (cTab)->(dbGoTop())

   //==========================================================================================
   // Devolvendo o conteudo criptografado para a tabela EZ9
   //==========================================================================================
   TCSQLExec("UPDATE "+ RetSqlName('EZ9')+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE D_E_L_E_T_ = ' ' AND EZ9_FILIAL = '" + xFilial("EZ9")+ "' ")
   
   While !(cTab)->(Eof())
      RecLock("EZ9",.T.)
      For nX := 1 To Len(aStruct)
         cCampo := AllTrim(aStruct[nX,1])
         If !Alltrim(cCampo) $ "EZ9_FILIAL|EZ9_TIPDOC|EZ9_MODELO|EZ9_ORDEM|EZ9_CPOSX3|EZ9_ROTDES|EZ9_ATIVO|EZ9_NIVEL|EZ9_RETROC|EZ9_DTIMP|EZ9_HRIMP" // Campos que n�o ser�o criptografados
            If TAMSX3(cCampo)[3] $ "C|M" .and. !Empty((cTab)->&(cCampo))   // Apenas campos caracteres e Memos que n�o estejam v�zios
               EZ9->&(cCampo) := U_CriptoGr((cTab)->&(cCampo),1)
            Else 
               EZ9->&(cCampo) := (cTab)->&(cCampo)
            Endif 
         Else 
            EZ9->&(cCampo) := (cTab)->&(cCampo)
         Endif 
      Next nI
      MsUnlock()
      (cTab)->(dbSkip())
   Enddo

   //==========================================================================================
   //==========================================================================================

   oTemptable:Delete()

RETURN

/*=====================================================================================================================================*/
// Tela para Configura��o OCR
/*=====================================================================================================================================*/
User Function ConfTagCpo()   

   Local cArquivo:='', i:=0, aDados := {}
   Local oBrw, cAux:='', cUltEZ0:='',cUltEZ1:=''
   Private CCADASTRO:="Configuracao TAG x Campo"
   Private cTab:= 'EZ4'
   Raiz := 1     // Indica que a tela inicial Nao esta ativa

   oBrw:= FWmBrowse():New()
   oBrw:SetDescription( "TAG x Campo" )
   oBrw:SetMenuDef('EZ4_GRC_PORTALXML')    // ARQUIVO FONTE ONDE ESTA A MENUDEF

   oBrw:SetAlias( cTab )
   oBrw:Activate()

   // REVALIDA TABELAS EZ0 e EZ1 conforme os campos da SF1 e SD1
   SX3->( dbSetorder(1))
   SX3->( dbSeek("EZ1") )
   SX3->( dbSkip(-1) )
   cUltEZ0 := SX3->X3_ORDEM
   SX3->( dbSetorder(1))
   SX3->( dbSeek("EZ2") )
   SX3->( dbSkip(-1) )
   cUltEZ1 := SX3->X3_ORDEM

   cQry:="select distinct EZ4_CAMPO from "+ RetSqlName('EZ4')     // View Nao traz campo memo
   cQry+=" where D_E_L_E_T_ <> '*' "
   cQry+="   and ( EZ4_CAMPO LIKE 'F1_%' or EZ4_CAMPO LIKE 'D1_%' or EZ4_CAMPO LIKE 'C5_%' or EZ4_CAMPO LIKE 'C6_%') "
   cQry+="   and EZ4_ATIVA = '1' "
   AbreQuery(cQry,"QRYEZ4")

   SX3->(dbSetorder(2))
   while QRYEZ4->(! eof())
      if SX3->( dbSeek(QRYEZ4->EZ4_CAMPO) )
         //SX3->( cArquivo := if( SubStr(X3_CAMPO,1,2)=="F1" , "EZ0" , "EZ1" ) )
         SX3->( cArquivo := if(SubStr(X3_CAMPO,1,2)$"F1|C5","EZ0","EZ1"))
         SX3->( cAux     := left( cArquivo+SubStr(X3_CAMPO,3),10 )          )
         while Ascan(aDados,{|x| x[3] == cAux } ) > 0
            cAux:= SubStr(cAux,1,4)+Soma1(SubStr(cAux,5,10))
         enddo 
         // CARREGA OS DADOS DO CAMPO ORIGINAL F1 ou D1 ou C5 OU C6
         SX3->(aadd(aDados,{cArquivo,X3_ORDEM, cAux ,X3_TIPO,X3_TAMANHO,X3_DECIMAL,X3_TITULO,X3_DESCRIC,X3_PICTURE,X3_RESERV,X3_USADO,X3_BROWSE,X3_VISUAL,X3_CONTEXT,"",""}))
      end
      QRYEZ4->(dbSkip())
   enddo 

   for i:= 1 to len(aDados)
      if SX3->( ! dbSeek(aDados[i,3]))
         cAux:='Tem campo novo'
         cUltEZ0 := if( SubStr(aDados[i,3],1,3)=="EZ0", Soma1(cUltEZ0), cUltEZ0 )
         cUltEZ1 := if( SubStr(aDados[i,3],1,3)=="EZ1", Soma1(cUltEZ1), cUltEZ1 )
         SX3->(RecLock("SX3", .T.))
         SX3->X3_ARQUIVO := aDados[i,1]
         SX3->X3_ORDEM   := if( SubStr(aDados[i,3],1,3)=="EZ0", cUltEZ0, cUltEZ1 )
         SX3->X3_CAMPO   := aDados[i,3]
         SX3->X3_TIPO    := aDados[i,4]
         SX3->X3_TAMANHO := aDados[i,5]
         SX3->X3_DECIMAL := aDados[i,6]
         SX3->X3_TITULO  := aDados[i,7]
         SX3->X3_DESCRIC := aDados[i,8]
         SX3->X3_PICTURE := aDados[i,9]
         SX3->X3_RESERV  := aDados[i,10]
         SX3->X3_USADO   := aDados[i,11]
         SX3->X3_PROPRI  := "U"
         SX3->X3_BROWSE  := aDados[i,12]
         SX3->X3_VISUAL  := aDados[i,13]
         SX3->X3_CONTEXT := aDados[i,14]
         SX3->X3_F3      := aDados[i,15]
         SX3->X3_VALID   := aDados[i,16]
         SX3->X3_CBOX    := if(len(aDados[i])>16, aDados[i,17],"")
         SX3->(dbUnlock())
      endif
   next i

   // realizar a atualizacao do banco
   if cAux = 'Tem campo novo'
      aDados:={"EZ0","EZ1"}
      for i:= 1 to len(aDados)
         (aDados[i])->(DBCLOSEAREA())
         //chkfile(aDados[i])
         X31UpdTable( aDados[i] )
      next
      Alert(__GetX31Trace())
   endif

   Raiz := 0  // Indica que a tela inicial volta a ficar ativa

return

/*=====================================================================================================================================*/
// Cria ou atualza os objetos de dicionario
/*=====================================================================================================================================*/
User Function PxmlUninstall()

   Local i:=0,aDados:={}

   //Drop tables
   aDados:= {"SIX","SX2","SX3","SX6","SXB"}
   for i:= 1 to len(aDados)
      DbUseArea(.T.,"CTREECDX",aDados[i]+"990.DTC",aDados[i],.F.,.F.)
   next

   //Drop tables
   aDados:= {"EZ0","EZ1","EZ2","EZ3","EZ4"}
   for i:= 1 to len(aDados)
      TcDelFile(RetSqlName(aDados[i]))
   next

   // Atualizando o SIX
   aDados:= {"EZ0","EZ1","EZ2","EZ3","EZ4"}
   SIX->(dbSetOrder(1)) // INDICE+ORDEM
   for i:= 1 to len(aDados)
      while dbSeek(aDados[i])
            SIX->( RecLock("SIX",.f.) )
            SIX->( dbDelete() )
            SIX->( dbUnlock())
      end
   next
   SIX->(__dbPack())

   // Atualizando o SX2
   aDados:= {"EZ0","EZ1","EZ2","EZ3","EZ4"}
   SX2->(dbSetOrder(1)) // X2_CHAVE
   for i:= 1 to len(aDados)
      while dbSeek(aDados[i])
            SX2->( RecLock("SX2",.f.) )
            SX2->( dbDelete() )
            SX2->( dbUnlock())
      end
   next
   SX2->(__dbPack())

   //Atualizando o SX3
   aDados:= {"EZ0","EZ1","EZ2","EZ3","EZ4"}
   SX3->(dbSetOrder(1)) // X3_ARQUIVO+X3_ORDEM
   for i:= 1 to len(aDados)
      while dbSeek(aDados[i])
            SX3->( RecLock("SX3",.f.) )
            SX3->( dbDelete() )
            SX3->( dbUnlock())
      end
   next
   SX3->(__dbPack())

   // ATUALIZANDO CONSULTA PADRaO
   SXB->(dbSetOrder(1)) // XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA
   aDados:={"F1D1X3"}
   for i:= 1 to len(aDados)
      while dbSeek(aDados[i])
            SXB->( RecLock("SXB",.f.) )
            SXB->( dbDelete() )
            SXB->( dbUnlock())
      end
   next
   SXB->(__dbPack())

   // ATUALIZANDO PARAMETROS
   // todos os parametros que comecem por EZ_PX_ entram na tela de parametros
   aDados:={}
   cAux:= xFilial('SX6')
   aadd(aDados,{ cAux ,"EZ_PX_INI" ,"C" ,"ultima atualizacao do dicionario" , DtoC(Date())+" "+Time()})
   aadd(aDados,{ cAux ,"EZ_PX_ADM" ,"C" ,"Usuario Administrador"            , "ALL"                  })
   aadd(aDados,{ cAux ,"EZ_PX_UAR" ,"C" ,"ultimo arquivo lido"             , "   "                  })
   aadd(aDados,{ cAux ,"EZ_PX_SSL" ,"L" ,"Utiliza SSL"                      , ".F."                  })
   aadd(aDados,{ cAux ,"EZ_PX_TLS" ,"L" ,"Utiliza TLS"                      , ".F."                  })
   aadd(aDados,{ cAux ,"EZ_PX_RID" ,"L" ,"Utiliza Real ID(Prot.IMAP )"      , ".T."                  })
   aadd(aDados,{ cAux ,"EZ_PX_PTL" ,"C" ,"Protocolo de email"               , "POP"                  })
   aadd(aDados,{ cAux ,"EZ_PX_TMO" ,"N" ,"Tempo de Time Out em segundos"    , "120"                  })
   aadd(aDados,{ cAux ,"EZ_PX_MSV" ,"C" ,"Servidor de entrada de email"     , "pop3.mail.com.br"     })
   aadd(aDados,{ cAux ,"EZ_PX_SSV" ,"C" ,"Servidor de Saida de Email (SMTP)", "smtp.mail.com.br"     })
   aadd(aDados,{ cAux ,"EZ_PX_ACC" ,"C" ,"Conta de email para receber XML " , "email@mail.com.br"    })
   aadd(aDados,{ cAux ,"EZ_PX_PSW" ,"C" ,"Senha de email para receber XML"  , "password"             })
   aadd(aDados,{ cAux ,"EZ_PX_MPT" ,"N" ,"Porta do Servidor de ent de email", "10"                   })
   aadd(aDados,{ cAux ,"EZ_PX_SPT" ,"N" ,"Porta do Servidor de SMTP"        , "25"                   })
   aadd(aDados,{ cAux ,"EZ_PX_VSS" ,"C" ,"Versao do SSL"                    , "2"                    })
   aadd(aDados,{ cAux ,"EZ_PX_MMS" ,"N" ,"Numero de emails a serem lidos"  , "100"                  })
   aadd(aDados,{ cAux ,"EZ_PX_RTP" ,"L" ,"'rootPath' para baixar emails "   , ".T."                  })
   aadd(aDados,{ cAux ,"EZ_PX_NFS" ,"L" ,"Ativa Importacao NFs saida  "    , ".F."                  })

   SX6->(dbSetOrder(1)) // X6_FIL+X6_VAR
   for i:= 1 to len(aDados)
      if SX6->(dbSeek( aDados[i,1]+aDados[i,2] ))
         SX6->(RecLock("SX6",.f.))
         SX6->( dbDelete() )
         SX6->(dbUnlock())
      endif
   Next
   SX6->(__dbPack())

Return

/*=====================================================================================================================================*/
// Rotina que checa o tipo da nota de Origem para definicao do tipo na nota de entrada
/*=====================================================================================================================================*/
User Function TPNFREFDEV()

   Local nI        := 0
   Local aRefs     := {}
   Local cQuery    := ""
   Local cXml      := ""
   Local cXMLaux   := ""
   Local cAliasTRB := GetNextAlias()
   Local cRet      := ''

   If !Empty(EZ0->EZ0_ACAO)

      If EZ0->EZ0_ACAO == "0"
      
         cQuery := "SELECT DISTINCT F2_TIPO " + CRLF
         cQuery += "  FROM " + RetSqlName('SF2') + " F2 " + CRLF
         cQuery += " WHERE F2_FILIAL = '" + xFilial("SF2") + "' AND F2.D_E_L_E_T_ = ' ' " + CRLF

         cXml:=XML_Limpa( AllTrim(EZ0->EZ0_XMLNFE) ) 
         cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a 1a. referencia
         while !empty(cXMLaux) 
               while !empty(cXMLaux)
                  If !Empty(XMLTagCont( 'refNFe', cXMLaux ))
                     aAdd(aRefs,XMLTagCont( 'refNFe', cXMLaux ) )          // guarda o item
                     cXMLaux:= StrTran(cXMLaux,XMLTagCompl('refNFe',cXMLaux),"") // Elimina o item do XML para evitar repeticoes
                  Else
                     exit
                  Endif 
               end
               cXml:= StrTran(cXml,XMLTagCompl('NFref', cXml ),"") // Elimina o item do XML para evitar repeticoes
               cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a proxima referencia
         end
 
         If len(aRefs)>0
            cQuery += "   AND F2.F2_CHVNFE in ("
            for nI:= 1 to len(aRefs)
               cQuery += if(nI>1,",","")+"'"+aRefs[nI]+"'"
            next nI
            cQuery += "   ) " + ENTER
         Endif

         dbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), (cAliasTRB), .F., .T. )

         If !(cAliasTRB)->(Eof())
            If (cAliasTRB)->F2_TIPO == "N"
               cRet := "D"
            Else 
               cRet := "N"
            Endif 
         Endif 
         (cAliasTRB)->(dbCloseArea())
      
      ElseIf EZ0->EZ0_ACAO == "1"
      
         cQuery := "SELECT DISTINCT F1_TIPO " + CRLF
         cQuery += "  FROM " + RetSqlName('SF1') + " F1 " + CRLF
         cQuery += " WHERE F1_FILIAL  = '" + xFilial("SF1") + "' AND F1.D_E_L_E_T_ = ' ' " + CRLF

         cXml:=XML_Limpa( AllTrim(EZ0->EZ0_XMLNFE) ) 
         cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a 1a. referencia
         while !empty(cXMLaux) 
               while !empty(cXMLaux)
                  If !Empty(XMLTagCont( 'refNFe', cXMLaux ))
                     aAdd(aRefs,XMLTagCont( 'refNFe', cXMLaux ) )          // guarda o item
                     cXMLaux:= StrTran(cXMLaux,XMLTagCompl('refNFe',cXMLaux),"") // Elimina o item do XML para evitar repeticoes
                  Else
                     exit
                  Endif 
               end
               cXml:= StrTran(cXml,XMLTagCompl('NFref', cXml ),"") // Elimina o item do XML para evitar repeticoes
               cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a proxima referencia
         end

         If len(aRefs)>0
            cQuery += "   AND F1.F1_CHVNFE in ("
            for nI:= 1 to len(aRefs)
               cQuery += if(nI>1,",","")+"'"+aRefs[nI]+"'"
            next nI
            cQuery += "   ) " + ENTER
         Endif

         dbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), (cAliasTRB), .F., .T. )

         If !(cAliasTRB)->(Eof())
            If (cAliasTRB)->F1_TIPO == "N"
               cRet := "D"
            Else
               cRet := "N"
            Endif 
         Endif 
         (cAliasTRB)->(dbCloseArea())

      Endif 
   
   Endif 

Return cRet


/*=====================================================================================================================================*/
// Funcao que permite a edi��o em multilinhas
/*=====================================================================================================================================*/
STATIC Function MULTLINHAS

   Local aAreaEZ0       := EZ0->(GetArea())
   Local nX             := 0 
   Local aButtons   		:= {}

   Private CChvMultiL   := EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
   Private CChvGrava    := EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
   Private oDlg
   Private oGetD
   Private oGetDErro
   Private aHdEZ1	      := {}
   Private aColsEZ1	   := {}
   Private aHdEZ2	      := {}
   Private aColsEZ2	   := {}

   // Monta Dimension da Tela - Nunca ira mudar
   Private aObjects   	:= {}
   Private aPos       	:= {}
   Private aSize      	:= MsAdvSize()
   Private aInfo      	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
   
   RegToMemory("EZ1",.F.)

   SetKey(VK_F12 , {||  })

   If EZ0->EZ0_TIPO $ 'D|B'
      aAdd(aButtons, { "RELATORIO" , {|| ProdForCli("SA1") } , "Prod. x Cliente" , "Prod. x Cliente" } )
   Else 
      aAdd(aButtons, { "RELATORIO" , {|| ProdForCli("SA2") } , "Prod. x Fornec." , "Prod. x Fornec." } )
   Endif 

   dbSelectArea("SX3")
   SX3->(dbSetOrder(1))
   SX3->(dbSeek("EZ1"))
   While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == 'EZ1'
      If !Alltrim(SX3->X3_CAMPO) $ "EZ1_FILIAL|EZ1_CHVNFE"
         aAdd(aHdEZ1,{	Trim(X3Titulo())		               ,;
                        SX3->X3_CAMPO								,;
                        SX3->X3_PICTURE                  	,;
                        SX3->X3_TAMANHO							,;
                        SX3->X3_DECIMAL							,;
                        SX3->X3_VALID								,;
                        SX3->X3_USADO								,;
                        SX3->X3_TIPO								,;
                        SX3->X3_F3									,;
                        SX3->X3_CONTEXT							,;
                        SX3->X3_CBOX								,;
                        SX3->X3_RELACAO							,;
                        SX3->X3_WHEN								})
      Endif 
      SX3->(dbSkip())
   Enddo

   dbSelectArea("SX3")
   SX3->(dbSetOrder(1))
   SX3->(dbSeek("EZ2"))
   While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == 'EZ2'
      If !Alltrim(SX3->X3_CAMPO) $ "EZ2_FILIAL|EZ2_CHVNFE"
         aAdd(aHdEZ2,{	If(Alltrim(SX3->X3_CAMPO)=="EZ2_STATUS","",Trim(X3Titulo())),;
                        SX3->X3_CAMPO								,;
                        If(Alltrim(SX3->X3_CAMPO)=="EZ2_STATUS","@BMP",SX3->X3_PICTURE),;
                        SX3->X3_TAMANHO							,;
                        SX3->X3_DECIMAL							,;
                        SX3->X3_VALID								,;
                        SX3->X3_USADO								,;
                        SX3->X3_TIPO								,;
                        SX3->X3_F3									,;
                        SX3->X3_CONTEXT							,;
                        SX3->X3_CBOX								,;
                        SX3->X3_RELACAO							,;
                        ".F."								         })
      Endif 
      SX3->(dbSkip())
   Enddo

   EZ1->(dbSetOrder(1)) // EZ1_FILIAL+EZ1_CHVNFE+EZ1_ITEM
   EZ1->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)))
   While !EZ1->(Eof()) .And. EZ0->(EZ0_FILIAL+EZ0_CHVNFE) == EZ1->(EZ1_FILIAL+EZ1_CHVNFE)
         aAdd( aColsEZ1, Array(Len(aHdEZ1)+1) )
         For nX := 1 To Len(aHdEZ1)
            aColsEZ1[Len(aColsEZ1)][nX] := EZ1->(FieldGet(FieldPos(aHdEZ1[nX][2])))
         Next nX
         aColsEZ1[Len(aColsEZ1)][Len(aHdEZ1)+1] := .F.
      EZ1->(dbSkip())
   Enddo 

   EZ2->(dbSetOrder(1)) // EZ2_FILIAL+EZ2_CHVNFE+EZ2_ITEM
   EZ2->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)))
   While !EZ2->(Eof()) .And. EZ0->(EZ0_FILIAL+EZ0_CHVNFE) == EZ2->(EZ2_FILIAL+EZ2_CHVNFE)
      If !Alltrim(EZ2->EZ2_ITEM) $ 'cab.'
         aAdd( aColsEZ2, Array(Len(aHdEZ2)+1) )
         For nX := 1 To Len(aHdEZ2)
            If EZ2->EZ2_STATUS == '1' .And. aHdEZ2[nX,2] == "EZ2_STATUS"
               aColsEZ2[Len(aColsEZ2)][nX] := LoaDbitmap( GetResources(), "BR_AMARELO" )
            ElseIf EZ2->EZ2_STATUS == '2' .And. aHdEZ2[nX,2] == "EZ2_STATUS"
               aColsEZ2[Len(aColsEZ2)][nX] := LoaDbitmap( GetResources(), "BR_VERMELHO" )
            Else 
               aColsEZ2[Len(aColsEZ2)][nX] := EZ2->(FieldGet(FieldPos(aHdEZ2[nX][2])))
            Endif 
         Next nX
         aColsEZ2[Len(aColsEZ2)][Len(aHdEZ2)+1] := .F.
      Endif 
      EZ2->(dbSkip())
   Enddo 

   aAdd(aObjects,{100,035,.T.,.F.,.F.})
   aAdd(aObjects,{100,100,.T.,.T.,.F.})
   aPos := MsObjSize(aInfo,aObjects)

   Define MsDialog oDlg Title " Fornecedor: " + EZ0->EZ0_FORNEC + "/" + EZ0->EZ0_LOJA + " - NF.: " + EZ0->EZ0_NUMNFE + " - Manuten��o dos Itens " Of oMainWnd Pixel From aSize[7]-3,3 To aSize[6]-3,aSize[5]-3 //Style DS_MODALFRAME
   
   @ aSize[7]+32, 2 GROUP oGroup1 TO aSize[6]/3-15,(aSize[5]/2)-2 Prompt " Itens da Nota " Of oDlg Color 0, 16777215 Pixel    

   oGetD := MsNewGetDados():New(aSize[7]+39, 5, aSize[6]/3-18,(aSize[5]/2)-5,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",,/*acpos*/,/*freeze*/,,/*fieldok*/,/*superdel*/,,oDlg,@aHdEZ1,@aColsEZ1)

   @ aSize[6]/3-12, 2 GROUP oGroup1 TO aSize[6]/2-4,(aSize[5]/2)-2 Prompt " Ocorr�ncias dos Item " Of oDlg Color 0, 16777215 Pixel    

   oGetDErro := MsNewGetDados():New(aSize[6]/3-4, 5, aSize[6]/2-8,(aSize[5]/2)-5,GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",,/*acpos*/,/*freeze*/,,/*fieldok*/,/*superdel*/,,oDlg,@aHdEZ2,@aColsEZ2)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg	,{|| u_MULTLGrava(),oDlg:End() },{ || oDlg:End() },,aButtons ) Centered

   EZ0->(dbSetOrder(1))
   EZ0->(dbSeek(CChvMultiL))

   RestArea(aAreaEZ0)

Return 


User Function MULTLGrava()

   Local nX := 0 
   Local nY := 0 
   Local nPsItem   := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_ITEM")   } )
   Private CChvMultiL   := CChvGrava

   EZ0->(dbSetOrder(1))
   EZ0->(dbSeek(CChvMultiL))

   For nX := 1 To Len(oGetD:aCols)
      dbSelectArea("EZ1")
      EZ1->(dbSetOrder(1))
      If EZ1->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)+oGetD:aCols[nX,nPsItem]))
         RecLock("EZ1",.F.)
         For nY := 1 To Len(aHdEZ1)
            EZ1->&(aHdEZ1[nY,2]) := oGetD:aCols[nX,nY]
         Next nY
         MsUnlock()
      Endif       
   Next nX
    
   aChaves := {}
   aadd(aChaves,{EZ0->EZ0_CHVNFE,EZ0->(RECNO()),EZ0->EZ0_TIPONF})
   VldDadosNF(aChaves[1])
   EZ1->(dbgotop())
   oBrwLeft:Refresh()
   oBrwRight:Refresh()
   SetKey(VK_F12 , {|| WFInconsist() } )

Return 

Static Function ProdForCli(cOpcAlias) 

   Local nPsItem  := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_ITEM")   } )
   Local nPsCod   := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_COD")   } )
   Local nPsUM    := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_UM")    } )
   Local nPsTP    := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_TP")    } )
   Local nPsDESCI := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_DESCRI")} )
   Local cProduto := ''

   If cOpcAlias == "SA1"
      AXCADASTRO('SA7','Cadastro de Produto X Clientes')
      cProduto :=  BUSCAPROD(SA7->A7_CODCLI)
   Else 
      AXCADASTRO('SA5','Cadastro de Produto X Fornecedores')
      cProduto := BUSCAPROD(SA5->A5_CODPRF)
   Endif

   If !Empty(cProduto)
      EZ1->(dbSetOrder(1))
      EZ1->(dbSeek(EZ0->(EZ0_FILIAL+EZ0_CHVNFE)+oGetD:aCols[oGetD:nAt,nPsItem]))
      RecLock("EZ1",.F.)
      EZ1->EZ1_COD    := cProduto
      EZ1->EZ1_UM     := POSICIONE('SB1',1,XFILIAL('SB1')+EZ1->EZ1_COD,'B1_UM')
      If EZ1->(FieldPos("EZ1_TP")) > 0 
         EZ1->EZ1_TP     := POSICIONE('SB1',1,XFILIAL('SB1')+EZ1->EZ1_COD,'B1_TIPO')
      Endif 
      If EZ1->(FieldPos("EZ1_DESCRI")) > 0 
         EZ1->EZ1_DESCRI := POSICIONE('SB1',1,XFILIAL('SB1')+EZ1->EZ1_COD,'B1_DESC')
      Endif 
      MsUnlock()
      oGetD:aCols[oGetD:nAT,nPsCod]   := EZ1->EZ1_COD
      oGetD:aCols[oGetD:nAT,nPsUM]    := EZ1->EZ1_UM
      If EZ1->(FieldPos("EZ1_TP")) > 0 
         oGetD:aCols[oGetD:nAT,nPsTP]    := EZ1->EZ1_TP
      Endif 
      If EZ1->(FieldPos("EZ1_DESCRI")) > 0 
         oGetD:aCols[oGetD:nAT,nPsDESCI] := EZ1->EZ1_DESCRI
      Endif 
      oGetD:Refresh()
   Endif 

Return 

/*=====================================================================================================================================*/
// Funcao que trata a devolucao -- D2_IDENTB6
/*=====================================================================================================================================*/
User Function NFREFDEV()

   Local cXml      := ''
   Local cXMLaux   := ''
   Local cTes      := ''
   Local cProd     := ''
   Local aRefs     := {}
   Local lCtrlP3   := .F.
   Local oDlg, oBrowse, oColumn, i:=0
   Local cQuery  := ""//,cXml:="", cXMLaux:= "",aRefs:={}
   Local cWhere  := "", cQry := "", cOrder := ""         // Marcio Martins 28/08/2023
   Local bCancel

   Local aHeader := { { Tt("FT_NFISCAL")     , "FT_NFISCAL" , Pc("FT_NFISCAL") , Tm("FT_NFISCAL") , Dc("FT_NFISCAL") , Tp("FT_NFISCAL") },;
                      { Tt("FT_SERIE  ")     , "FT_SERIE  " , Pc("FT_SERIE  ") , Tm("FT_SERIE  ") , Dc("FT_SERIE  ") , Tp("FT_SERIE  ") },;
                      { Tt("FT_EMISSAO")     , "FT_EMISSAO" , Pc("FT_EMISSAO") , Tm("FT_EMISSAO") , Dc("FT_EMISSAO") , Tp("FT_EMISSAO") },;
                      { Tt("FT_ITEM")        , "FT_ITEM"    , Pc("FT_ITEM")    , Tm("FT_ITEM")    , Dc("FT_ITEM")    , Tp("FT_ITEM")    },;
                      { Tt("FT_QUANT")       , "FT_QUANT"   , Pc("FT_QUANT")   , Tm("FT_QUANT")   , Dc("FT_QUANT")   , Tp("FT_QUANT")   },;
                      { "DISPONIVEL p/ dev." , "SALDO"      , Pc("FT_QUANT")   , Tm("FT_QUANT")   , Dc("FT_QUANT")   , Tp("FT_QUANT")   },;
                      { Tt("D2_TOTAL")       , "TOTAL"      , Pc("D2_TOTAL")   , Tm("D2_TOTAL")   , Dc("D2_TOTAL")   , Tp("D2_TOTAL")   },;
                      { Tt("D2_LOTECTL")     , "D2_LOTECTL" , Pc("D2_LOTECTL") , Tm("D2_LOTECTL") , Dc("D2_LOTECTL") , Tp("D2_LOTECTL") },;
                      { Tt("D2_NUMLOTE")     , "D2_NUMLOTE" , Pc("D2_NUMLOTE") , Tm("D2_NUMLOTE") , Dc("D2_NUMLOTE") , Tp("D2_NUMLOTE") },;
                      { "Ident SB6"          , "IDENTB6"    , Pc("D2_IDENTB6") , Tm("D2_IDENTB6") , Dc("D2_IDENTB6") , Tp("D2_IDENTB6") }}

   If IsInCallStack("MULTLINHAS")

      bCancel := {|| oGetd:aCols[oGetd:nAT,nPsNFORI]  := TMPFT->FT_NFISCAL,;
                     oGetd:aCols[oGetd:nAT,nPsSERIOR] := TMPFT->FT_SERIE,;
                     oGetd:aCols[oGetd:nAT,nPsITEMOR] := TMPFT->FT_ITEM,;
                     oGetd:aCols[oGetd:nAT,nPsIDB6]   := TMPFT->IDENTB6,;
                     oGetd:aCols[oGetd:nAT,nPsLOTECT]  := TMPFT->D2_LOTECTL,;
                     oGetd:aCols[oGetd:nAT,nPsNUMLOT] := TMPFT->D2_NUMLOTE,;
                     oDlg:End()}

   Else 
      bCancel := {|| EZ1->( RecLock('EZ1',.F.) ),;
                        EZ1->( IF(FieldPos('EZ1_NFORI')>0,EZ1_NFORI:=TMPFT->FT_NFISCAL,)),;
                        EZ1->( IF(FieldPos('EZ1_SERIOR')>0,EZ1_SERIOR:=TMPFT->FT_SERIE,)),;
                        EZ1->( IF(FieldPos('EZ1_ITEMOR')>0,EZ1_ITEMOR:=TMPFT->FT_ITEM,)),;
                        EZ1->( IF(FieldPos('EZ1_IDB6')>0,EZ1_IDB6:=TMPFT->IDENTB6,)),;
                        EZ1->( IF(FieldPos('EZ1_LOTECT')>0,EZ1_LOTECT:=TMPFT->D2_LOTECTL,)),;
                        EZ1->( IF(FieldPos('EZ1_NUMLOT')>0,EZ1_NUMLOT:=TMPFT->D2_NUMLOTE,)),;
                        EZ1->( msUnlock() ),;
                        oDlg:End()}
   Endif 

   If EZ0->EZ0_ACAO == '0'

      oModel := FwModelActive()
      If Valtype(oModel) == "O"
         cTes  :=  oModel:GetValue('EZ1MASTER','EZ1_TES')
         cProd :=  oModel:GetValue('EZ1MASTER','EZ1_COD')
      Else 
         If IsInCallStack("MULTLINHAS")
            nPsTES := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_TES") } )
            nPsCod := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_COD") } )
            nPsNFORI  := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_NFORI") } )
            nPsSERIOR := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_SERIOR") } )
            nPsITEMOR := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_ITEMOR") } )
            nPsIDB6   := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_IDB6") } )
            nPsLOTECT := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_LOTECT") } )
            nPsNUMLOT := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_NUMLOT") } )
            cTes   := oGetd:aCols[oGetd:nAT,nPsTES]
            cProd  := oGetd:aCols[oGetd:nAT,nPsCod]
         Else 
            cTes  := EZ1->EZ1_TES 
            cProd := EZ1->EZ1_COD
         Endif 
      Endif 

      If Empty(cTes) 
         MsgAlert("Preencha a TES e depois tecle F4 (NF Origem)")
         Return
      Else 
         dbSelectArea("SF4")
         SF4->(dbSetOrder(1))
         If SF4->(dbSeek(xFilial("SF4")+cTes))
            If SF4->F4_PODER3 == 'D'
               lCtrlP3 := .T.
            Endif 
         Endif 
      Endif 
      
      If lCtrlP3

         cQuery := "SELECT FT_NFISCAL, FT_SERIE, FT_EMISSAO, FT_ITEM, FT_QUANT, D2_LOTECTL AS D2_LOTECTL, D2_NUMLOTE AS D2_NUMLOTE, " + ENTER  //,FT_PRODUTO, " + ENTER
         cQuery += "      B6.B6_SALDO AS SALDO, " + ENTER
         cQuery += "       FT_CHVNFE, FT_CLIEFOR, FT_LOJA, B6_IDENT AS IDENTB6, (B6_SALDO * B6_PRUNIT) AS TOTAL" + ENTER
         cQuery += "  FROM " + RetSqlName('SFT') + " FT " + ENTER
         cQuery += " INNER JOIN " + RetSqlName('SD2') + " D2  " + ENTER
         cQuery += " ON          D2.D_E_L_E_T_   <>  '*'  " + ENTER
         cQuery += " AND         D2.D2_FILIAL    =   FT.FT_FILIAL " + ENTER
         cQuery += " AND         D2.D2_DOC       =   FT.FT_NFISCAL  " + ENTER
         cQuery += " AND         D2.D2_SERIE     =   FT.FT_SERIE  " + ENTER
         cQuery += " AND         D2.D2_CLIENTE   =   FT.FT_CLIEFOR  " + ENTER
         cQuery += " AND         D2.D2_LOJA      =   FT.FT_LOJA  " + ENTER
         cQuery += " AND         D2.D2_COD       =   FT.FT_PRODUTO  " + ENTER
         cQuery += " AND         D2.D2_ITEM      =   FT.FT_ITEM  " + ENTER
         cQuery += " INNER JOIN  " + RetSqlName('SB6') + " B6  " + ENTER
         cQuery += " ON          B6.D_E_L_E_T_   <>  '*'  " + ENTER
         cQuery += " AND         B6.B6_FILIAL    =   FT.FT_FILIAL   " + ENTER
         cQuery += " AND         B6.B6_PRODUTO   =   FT.FT_PRODUTO   " + ENTER
         cQuery += " AND         B6.B6_CLIFOR    =   FT.FT_CLIEFOR   " + ENTER
         cQuery += " AND         B6.B6_LOJA      =   FT.FT_LOJA  " + ENTER
         cQuery += " AND         B6.B6_IDENT     =   D2.D2_IDENTB6   " + ENTER
         cQuery += " AND         B6.B6_SALDO     >   0  " + ENTER
         cQuery += " WHERE FT.FT_FILIAL = '" + xFilial("SFT") + "' " + ENTER
         cQuery += "   AND FT.D_E_L_E_T_   <>  '*' " + ENTER
         cQuery += "   AND FT.FT_CLIEFOR = '"+EZ0->EZ0_FORNEC+"' " + ENTER
         cQuery += "   AND FT.FT_LOJA    = '"+EZ0->EZ0_LOJA+"' " + ENTER
         cQuery += "   AND FT.FT_PRODUTO = '"+AllTrim(cProd)+"' " + ENTER
         cQuery += "   AND FT.FT_TIPOMOV   =   'S'  " + ENTER
         cQuery += " ORDER BY    FT_NFISCAL,FT_SERIE,FT_EMISSAO " + ENTER      
      
      Else 

         // Marcio Martins 25/08/2021 - referente ao chamado Crown #64039

         cXml:=XML_Limpa( AllTrim(EZ0->EZ0_XMLNFE) ) 
         cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a 1a. referencia
         while !empty(cXMLaux) 
               while !empty(cXMLaux)
                  If !Empty(XMLTagCont( 'refNFe', cXMLaux ))
                     aAdd(aRefs,XMLTagCont( 'refNFe', cXMLaux ) )          // guarda o item
                     cXMLaux:= StrTran(cXMLaux,XMLTagCompl('refNFe',cXMLaux),"") // Elimina o item do XML para evitar repeticoes
                  Else
                     exit
                  Endif 
               end
               cXml:= StrTran(cXml,XMLTagCompl('NFref', cXml ),"") // Elimina o item do XML para evitar repeticoes
               cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a proxima referencia
         end

         If Len(aRefs)==0
            aRefs := {}
            aAdd(aRefs,'')
         Endif 

         cQry := "SELECT D2_DOC     AS FT_NFISCAL, " + ENTER
         cQry += "       D2_SERIE   AS FT_SERIE, " + ENTER
         cQry += "       D2_EMISSAO AS FT_EMISSAO, " + ENTER
         cQry += "       D2_ITEM    AS FT_ITEM, " + ENTER
         cQry += "       D2_QUANT   AS FT_QUANT, " + ENTER
         cQry += "       D2_LOTECTL AS D2_LOTECTL, " + ENTER
         cQry += "       D2_NUMLOTE AS D2_NUMLOTE, " + ENTER
         cQry += "       D2_QUANT-D2.D2_QTDEDEV AS SALDO, " + ENTER
         cQry += "       F2_CHVNFE  AS FT_CHVNFE, " + ENTER
         cQry += "       F2_CLIENTE AS FT_CLIEFOR, " + ENTER
         cQry += "       F2_LOJA    AS FT_LOJA, " + ENTER
         cQry += "       D2_IDENTB6 AS IDENTB6, " + ENTER
         cQry += "       ((D2_QUANT-D2.D2_QTDEDEV)*D2_PRCVEN) AS TOTAL " + ENTER
         cQry += "  FROM " + RetSqlName('SD2') + " D2 " + ENTER
         cQry += " INNER JOIN " + RetSqlName('SF2') + " F2 ON F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC= D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE " + ENTER
         cQry += " WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
         cQry += "   AND D2.D_E_L_E_T_ <> '*' " + ENTER
         cQry += "   AND D2.D2_COD = '"+AllTrim(cProd)+"' " + ENTER
         cQry += "   AND D2_QUANT - D2.D2_QTDEDEV >= " + cValToChar(EZ1->EZ1_QUANT) + " " + ENTER
         cQry += "   AND F2.D_E_L_E_T_ <> '*'  " + ENTER
         cWhere := "   AND F2.F2_CHVNFE = '" + aRefs[1] + "' " + ENTER
         cOrder := " ORDER BY FT_NFISCAL,FT_SERIE,FT_EMISSAO " + ENTER
         cQuery := ""
         cQuery += cQry + cWhere + cOrder

         //---------------------------------------------------------------------------------------
         // M�rcio Martins - 28/08/2023 - chamado 7700 - Crown
         // Tratamento para retornar notas do cliente quando n�o encontrar a chave
         //---------------------------------------------------------------------------------------
         DBUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), (cAliasORI), .F., .T.)
         If (cAliasORI)->(Eof())
            cWhere := "   AND F2.F2_CLIENTE = '" + EZ0->EZ0_FORNEC + "' AND F2.F2_LOJA = '" + EZ0->EZ0_LOJA   + "' " + ENTER
            cQuery := ""
            cQuery += cQry + cWhere + cOrder   
         Endif 
         (cAliasORI)->(dbCloseArea())
         //---------------------------------------------------------------------------------------

      Endif 

   ElseIf EZ0->EZ0_ACAO == '1'

      cQuery := "SELECT FT_NFISCAL, FT_SERIE, FT_EMISSAO, FT_ITEM, FT_QUANT, D1_LOTECTL AS D2_LOTECTL, D1_NUMLOTE AS D2_NUMLOTE, " + ENTER  //,FT_PRODUTO, " + ENTER
      // Edson Hornberger - Referente ao chamado 61573
      cQuery += "      B6.B6_SALDO AS SALDO, " + ENTER
      //cQuery += "      D1_QUANT - D1_QTDEDEV AS SALDO, " + ENTER   
      //cQuery += "       FT_CHVNFE, FT_CLIEFOR, FT_LOJA, D1_IDENTB6 AS IDENTB6, D1_TOTAL TOTAL " + ENTER
      cQuery += "       FT_CHVNFE, FT_CLIEFOR, FT_LOJA, B6_IDENT AS IDENTB6, (B6_SALDO * B6_PRUNIT) AS TOTAL" + ENTER
      //-------------------------------------------------
      cQuery += "  FROM " + RetSqlName('SFT') + " FT " + ENTER
      cQuery += " INNER JOIN " + RetSqlName('SD1') + " D1 ON FT.FT_FILIAL = D1.D1_FILIAL AND FT.FT_NFISCAL = D1.D1_DOC AND FT.FT_SERIE = D1.D1_SERIE " + ENTER
      cQuery += "       AND FT.FT_PRODUTO = D1.D1_COD AND FT.FT_CLIEFOR = D1.D1_FORNECE AND FT.FT_LOJA = D1.D1_LOJA AND FT.FT_ITEM = D1.D1_ITEM " + ENTER
      // Edson Hornberger - Referente ao chamado 61573 
      cQuery += " INNER JOIN " + RetSqlName('SB6') + " B6 ON " + ENTER
      cQuery += "    B6.B6_FILIAL = '" + xFilial('SB6') + "' AND " + ENTER
      cQuery += "    B6.B6_CLIFOR = FT.FT_CLIEFOR AND " + ENTER
      cQuery += "    B6.B6_LOJA = FT.FT_LOJA AND " + ENTER
      cQuery += "    B6.B6_PRODUTO = FT.FT_PRODUTO AND " + ENTER
      cQuery += "    B6.B6_IDENT = D1.D1_IDENTB6 AND " + ENTER
      cQuery += "    B6.B6_SALDO > 0 AND " + ENTER
      cQuery += "    B6.D_E_L_E_T_ = '' " + ENTER 
      // --------------------------------------------
      cQuery += " WHERE FT.FT_FILIAL = '" + xFilial("SFT") + "' " + ENTER
      cQuery += "   AND FT.D_E_L_E_T_ <> '*' AND D1.D_E_L_E_T_ <> '*' " + ENTER
      cQuery += "   AND FT.FT_CLIEFOR = '"+EZ0->EZ0_FORNEC+"' " + ENTER
      cQuery += "   AND FT.FT_LOJA    = '"+EZ0->EZ0_LOJA+"' " + ENTER
      cQuery += "   AND FT.FT_PRODUTO = '"+AllTrim(EZ1->EZ1_COD)+"' " + ENTER
      cQuery += " ORDER BY FT_NFISCAL,FT_SERIE,FT_EMISSAO " + ENTER

   Endif 
   
   //Tela de Selecao de Despesas
   oDlg := TDialog():new()
   oDlg:nLeft     := 0
   oDlg:nTop	   := 0
   oDlg:nHeight   := 400
   oDlg:nWidth	   := 900
   oDlg:lCentered := .T.
   oDlg:lEscClose := .T.
   oDlg:oParent   := oMainWnd
   oDlg:cCaption  := "| Notas disponiveis para " + EZ0->EZ0_FORNEC + ' | Item: ' + EZ1->EZ1_ITEM + " | " + Alltrim(EZ1->EZ1_COD) + " | Quant: " + Alltrim(Transform(EZ1->EZ1_QUANT,"@E 99999999.99")) + " | "

   oBrowse := FWBrowse():New(oDlg)
   oBrowse:SetDescription('Notas emitidas do produto: ' + AllTrim(EZ1->EZ1_COD) )
   oBrowse:SetDataQuery () //define que sera com query
   oBrowse:SetQuery(cQuery)
   oBrowse:SetAlias("TMPFT")
   oBrowse:DisableConfig()
   oBrowse:DisableReport()
   oBrowse:DisableFilter()
   //oBrowse:SetDBFFilter()
   //oBrowse:SetUseFilter()
   for i := 1 To len(aHeader)
      oColumn := FWBrwColumn():New()
      oColumn:SetTitle( aHeader[i,1]) //Titulo
      oColumn:SetData( &("{|| TMPFT->" + aHeader[i,2] + " }") ) //Dados
      oColumn:SetPicture( aHeader[i,3] )
      oColumn:SetSize( aHeader[i,4] )
      oColumn:SetDecimal( aHeader[i,5] )
      oColumn:SetType( aHeader[i,6])  // Tipo
      oColumn:blDblClick := bCancel
      oBrowse:SetColumns({oColumn}) //Adiciona a Coluna ao Browse
   next

   oBrowse:Activate() //Ativacao do Browse
   oDlg:Activate() //Ativacao da janela

Return

/*
===============================================================================================
||   Funcao: 	BUSCADOCS
===============================================================================================
||		Realiza a busca unificada das notas
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/


User Function BUSCADOCS()
	//--< Variaveis >-----------------------------------------------------------------------
	Local cFunction	:= "Portal_XML"
	Local	cTitle		:= "Busca/Integracao de Documentos"
	local bProces     := { |oSelf| DefSel(oSelf,.f.) }
   local	cDescription:= "Busca dos arquivos XML conforme parametro informado"
   local cPerg		   := PadR('PORTALXML', 10)
   Local	oProcess
   
   Local aMvPar := {}
   Local nX

   For nX := 1 To 2
      aAdd( aMvPar, &( "MV_PAR" + StrZero( nX, 2, 0 ) ) )
   Next nX
   
   //ValidPerg(cPerg)

   MV_PAR02:= ""

   oProcess	   := TNewProcess():New(cFunction, cTitle, bProces, cDescription,cPerg)

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf

   //No final da customiza��o
   For nX := 1 To Len( aMvPar )
      &( "MV_PAR" + StrZero( nX, 2, 0 ) ) := aMvPar[ nX ]
   Next nX
 

// versao para o release 33 - GEDEON - est� dando erro no Parambox
/*
   //--< Variaveis >-----------------------------------------------------------------------
	Local cFunction	:= "Portal_XML"
	Local	cTitle		:= "Busca/Integracao de Documentos"
	local bProces     := { |oSelf| DefSel(oSelf,.f.) }
   local	cDescription:= "Busca dos arquivos XML conforme parametro informado"
   local cPerg		   := PadR('PORTALXML', 10)
   Local	oProcess
   
   ValidPerg(cPerg)

   oProcess	   := TNewProcess():New(cFunction, cTitle, bProces, cDescription,cPerg)

	If ValType(oProcess) == "O"
		FreeObj(oProcess)
	EndIf
*/
Return Nil


User function EZ4ParamBox()

local aPergs   := {}
local aRet     := {}
local aButtons := {}
local aCombo   := {"","Leitura Email","Imp Arquivos","NFSe OCR","WebService NFe","WebService CTe" , "WebService NFSe Nacional","NFSE Nora API"}

aAdd( aPergs ,{9,"Abaixo escolha uma op��o para Captura de NF",200, 40,.T.})                 
aAdd( aPergs ,{2,"Tipo Busca:",01,aCombo,85,"",.T.})

//Chamada com bloco de bOK
If ParamBox(aPergs ,"EZ4 GRC",aRet,{|| bOKaRet(aRet)},aButtons,,,,,,,)
   // Retorno do Parambox
   MV_PAR01 := aRet[2]
   MV_PAR02 := ""
   Return .T.
Else
   MsgAlert("Processo Cancelado pelo usu�rio","EZ4 GRC")
   return .f.
EndIf    
return

//------------------------
Static Function bOKaRet(aRet)
local lRet := .T. 
// se precisar validar em algum momento
Return lRet

/*
===============================================================================================
||   Funcao: 	DefSel
===============================================================================================
||		Define a chamada da rotina pela selecao do pergunte
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/
Static Function DefSel(oSelf, lSchedule)

   Local cMVPAR02 := ''
   Local nRestam  := 0 

   Private lUsaPref   := SuperGetMV("EZ_USAPREF",.F.,.T.) 
   Private lUsSched   := SuperGetMV("EZ_USASCHE",.F.,.F.)
   Private lResumos   := 0
   Private lXMLBaixa  := 0 

   Default lUsSched := .f.

   // Ajustando MV_PAR01 do Retorno do Parambox
   if Alltrim(MV_PAR01)=='Leitura Email'
      MV_PAR01 := 1
   Elseif Alltrim(MV_PAR01)=='Imp Arquivos'
      MV_PAR01 := 2
   Elseif Alltrim(MV_PAR01)=='NFSe OCR'
      MV_PAR01 := 3
   Elseif Alltrim(MV_PAR01)=='WebService NFe'
      MV_PAR01 := 4
   Elseif Alltrim(MV_PAR01)=='WebService CTe'
      MV_PAR01 := 5
   Elseif Alltrim(MV_PAR01)=='WebService NFSe Nacional'
      MV_PAR01 := 6
   Elseif Alltrim(MV_PAR01)=='NFSE Nora API'
      MV_PAR01 := 7   
   Endif

   If MV_PAR01 == 1  // Ler e-mails
      U_ProcMail(oSelf, lSchedule)
   ElseIf MV_PAR01 == 2  // Importa Arquivos
      If Empty(MV_PAR02)
         MsgAlert("Voce deve selecionar a pasta aonde se encontram os arquivos")
         Return
      Endif
      cMVPAR02 := MV_PAR02
      U_ProcDir(oSelf, lSchedule)
      MV_PAR02 := cMVPAR02
      If lUsaPref
         U_ProcNFSe(oSelf, lSchedule)
      Endif 
      /*
   ElseIf MV_PAR01 == 3  // NF-e's via Manifesto
      If lUsSched // Parametro EZ_USASCHE ativado = nao permite executar a rotina 
         cMsgInfo := "Aten��o!"+CRLF
         cMsgInfo += "A rotina de Busca NFe Webservice est� sendo executada por Agendamento"+CRLF+CRLF
         cMsgInfo += "N�o � poss�vel executar a rotina por este modo."
         MsgAlert(cMsgInfo)
      Else 
         U_Busca00(oSelf, lSchedule, nRestam)
      Endif*/
    ElseIf MV_PAR01 == 3  // Nota fiscal de servico via OCR
      If lUsSched // Parametro EZ_USASCHE ativado = nao permite executar a rotina 
         cMsgInfo := "Aten��o!"+CRLF
         cMsgInfo += "A rotina de Busca NFe - Leiutura de OCR est� sendo executada por Agendamento"+CRLF+CRLF
         cMsgInfo += "N�o � poss�vel executar a rotina por este modo."
         MsgAlert(cMsgInfo)
      Else 
         U_OCRSelFile(.T.,MV_PAR02)
      Endif     
   ElseIf MV_PAR01 == 4  // NF-e's via webService
      if lUsSched   // PArametro EZ_USASCHE ativado = n�o permite executar a rotina - Carla Barbosa
         cMsgInfo := "Aten��o!"+CRLF
         cMsgInfo += "A rotina de Busca NFe Webservice est� sendo executada por Agendamento"+CRLF+CRLF
         cMsgInfo += "N�o � poss�vel executar a rotina por este modo."
         If lSchedule
            conout(cMsgInfo)
         Else 
            MSGALERT(cMsgInfo)
         Endif 
      Else
         If !ManifValid()
            cMsgInfo := "Aten��o!"+CRLF
            cMsgInfo += "1. Verifique a configura��o do certificado na rotina do Manifesto;"+CRLF+CRLF
            cMsgInfo += "2. O ambiente deve estar definido como '1-Produ��o'"
            If lSchedule
               conout(cMsgInfo)
            Else 
               MsgAlert(cMsgInfo)
            Endif 
         Else 
            U_ProcNFE(oSelf, lSchedule, @nRestam)   // 03/01/2022 - MARCIOP - Implementado a busca via webservice
            //U_Busca00(oSelf, lSchedule, nRestam)
            cMsgInfo := "Resumos: "+cValtochar(lResumos)+CRLF
            cMsgInfo += "XMLs Baixados: "+cValtochar(lXMLBaixa)+CRLF
            If lSchedule
               conout(cMsgInfo)
            Else 
               conout("Data.. "+dtoc(dDataBase)+" -"+cMsgInfo)
               MSGALERT(cMsgInfo)
            Endif 
         Endif
      Endif
   ElseIf MV_PAR01 == 5  // CT-e via webService
      U_ProcCTE(oSelf, lSchedule)
   ElseIf MV_PAR01 == 6  // NFSE Nacional via WebSErvice
      U_ProcNFn(oSelf, lSchedule)
   Elseif MV_PAR01 == 7 // NFSE Nora API
      U_xNoraNfse(oSelf, lSchedule, MV_PAR02)
   Endif 

Return 

/*
===============================================================================================
||   Funcao: 	ExtraiTXT
===============================================================================================
||		Realiza a Extracao dos dados conforme parametros passados
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	22/07/2020
===============================================================================================
*/
Static Function ExtraiTXT(cTexto, cCampo)

   Local cRet   := ""
   //Local cCampo := Padr(cCampo,10)
   Local cTipo  := ""
   Local cSeparador := Posicione("EZ5",1,xFilial("EZ5")+SM0->M0_CODMUN,"EZ5_SEPARA")

   If !Empty(cCampo)

      If Empty(cSeparador)

         dbSelectArea("EZ5")
         EZ5->(dbSetOrder(2))
         If EZ5->(dbSeek(xFilial("EZ5")+SM0->M0_CODMUN+cCampo))            
            cTipo  := Posicione("SX3",2,cCampo,"X3_TIPO")
            cRet   := SubStr(cTexto, EZ5->EZ5_POSINI, EZ5->EZ5_TAMANH ) 
            If cTipo == "D"
                  cRet := STOD(cRet)
            ElseIf cTipo == "N"
                  cRet := Val(cRet)/100
            Endif   
         Endif 
      Else
         cRet := RetDados(cTexto,cCampo)
      Endif    
   Endif 

Return cRet 

/*
===============================================================================================
||   Funcao: 	ProcNFSe
===============================================================================================
||		Realiza o processamento das notas de servico
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/
User Function ProcNFSe(oSelf, lSchedule)

   Local oFile     := Nil
   Local nX        := 0
   Local aFiles    := {}
   Local aSizes    := {} 
   Local cGetArq   := Alltrim(MV_PAR02)
   Local aChaves   := {}
   Local nI        := 0
   Local aLayDetal := {}
   Local aDados    := {}   
   Local cFormato  := "*.TXT"

   Private nPsCNPJ := 0 
   Private nPsPROD := 0 
   Private nPsNomEm := ''
   Private lIncForCli := SuperGetMV("EZ_INCCAD",.F.,.F.)
   Private cSeparador := ""
   Private aSeparador := {}
   
   //===============================================================================
   // Realiza a carga dos layouts
   //===============================================================================
   dbSelectArea("EZ4")
   EZ4->(dbSetOrder(1))
   If !EZ4->(dbSeek(xFilial("EZ4")+"NFs"))
      MsgAlert("Nao ha Validacoes carregadas para nota de Servico, realize o cadastro das mesmas")
      Return 
   Endif 

   dbSelectArea("EZ5")
   EZ5->(dbSetOrder(1))
   If !EZ5->(dbSeek(xFilial("EZ5")+SM0->M0_CODMUN))
      MsgAlert("Nao ha Layout cadastrado na Prefeitura de " + Alltrim(Posicione("CC2",1,xFilial("CC2")+SM0->M0_ESTCOB+Right(SM0->M0_CODMUN,5),"CC2_MUN")))
      Return 
   Endif 

   While !EZ5->(Eof()) .And. xFilial("EZ5")+SM0->M0_CODMUN == EZ5->(EZ5_FILIAL+EZ5_CODMUN)
      If EZ5->EZ5_TIPO == "2"
         If Empty(EZ5->EZ5_SEPARA)
            If !Empty(EZ5->EZ5_CHAVE)
                  aAdd(aLayDetal , {  EZ5->EZ5_CODMUN, EZ5->EZ5_TIPO, EZ5->EZ5_ORDEM, EZ5->EZ5_POSINI, EZ5_TAMANH, Upper(EZ5->EZ5_CHAVE) , Posicione("SX3",2,EZ5->EZ5_CHAVE,"X3_TIPO") } )
            Endif 
         Else  // Prefeituras com separadores "|"
            If Empty(cSeparador)
               cSeparador := EZ5->EZ5_SEPARA
            Endif 
            //If !Empty(EZ5->EZ5_CHAVE)
                  aAdd(aLayDetal , {  EZ5->EZ5_CODMUN, EZ5->EZ5_TIPO, Val(EZ5->EZ5_ORDEM), EZ5->EZ5_POSINI, EZ5_TAMANH, Upper(EZ5->EZ5_CHAVE) , Posicione("SX3",2,EZ5->EZ5_CHAVE,"X3_TIPO") } )
            //Endif 
         Endif 
      Endif 
      EZ5->(dbSkip())
   Enddo 

   If !Empty(cSeparador)
      aLayDetal := aSort(aLayDetal,,, { |x, y| x[3] < y[3] })
   Endif 

   //===============================================================================
   // Realiza a leitura dos arquivos
   //===============================================================================
   ADir(cGetArq+cFormato, aFiles, aSizes)
   
   nRegua := Len(aFiles)

   oSelf:SetRegua1(nRegua)
   oSelf:SetRegua2(nRegua)
   
   nCont := 0

   If Empty(cSeparador) // prefeituras com tamanhos fixos

      For nX := 1 to Len(aFiles)    

         oFile := FWFileReader():New(cGetArq+aFiles[nX])
         aDados  := {}     

         oFile:nBuffersize = 1024000
         If (oFile:Open())
            nCont++
            oSelf:IncRegua1("Lendo arquivo: " + aFiles[nX])
            oSelf:IncRegua2("Processando: " + CValToChar(nCont) + " de " + CValToChar(nRegua))
            
            while (oFile:hasLine())

               cLinha := Alltrim(oFile:GetLine())

               If SubStr(cLinha,1,1) == "2"

                  cChave := ExtraiTXT(cLinha, "EZ0_CHVNFE")

                  If !Empty(cChave)

                     EZ0->(dbSetOrder(1))    // EZ0_FILIAL+EZ0_CHVNFE    
                     If EZ0->(dbSeek(xFilial("EZ0")+cChave))
                        EZ0->( RecLock('EZ0',.F.))
                     Else
                        EZ0->( RecLock('EZ0',.T.))
                        // volumetria
                        U_EZVolUpdate("NFE")
                     Endif 
                     EZ0->EZ0_FILIAL := xFilial("EZ0")
                     EZ0->EZ0_TIPONF := "NFs"
                     EZ0->EZ0_CHVNFE := cChave
                     EZ0->EZ0_XMLNFE := cLinha
                     EZ0_STIN()
                     EZ0->(msUnlock())
                     
                     aAdd(aChaves , { cChave, EZ0->(Recno()) } )

                  Endif 

               Endif

            Enddo 

         Endif 

         oFile:Close()
         FRename(oFile:cfilename,oFile:cfilename+".processado")

      Next nX

   Else

      // prefeituras com seaparador de pipes

      For nX := 1 to Len(aFiles)    

         oFile := FWFileReader():New(cGetArq+aFiles[nX])
         aDados  := {}     

         oFile:nBuffersize = 1024000
         If (oFile:Open())
            // volumetria
            U_EZVolUpdate("NFE")
            nCont++
            oSelf:IncRegua1("Lendo arquivo: " + aFiles[nX])
            oSelf:IncRegua2("Processando: " + CValToChar(nCont) + " de " + CValToChar(nRegua))
            
            while (oFile:hasLine())

               cLinha := Alltrim(oFile:GetLine())

               nPosCtrl := 0 

               aSeparador := {}

               If SubStr(cLinha,1,1) == "2"

                  For nI := 1 to Len(cLinha)
                  
                     If SubStr(cLinha,nI,1)==cSeparador
                        If Len(aSeparador)==0
                           aAdd(aSeparador , SubStr(cLinha,1,nI-1) )
                           nPosCtrl := nI
                        Else
                           aAdd(aSeparador , SubStr(cLinha,nPosCtrl+1,nI-1-nPosCtrl) )
                           nPosCtrl := nI
                        Endif 
                     Endif 

                  Next nI
               
                  nPsChave := aScan( aLayDetal , { |x| AllTrim(x[6]) == "EZ0_CHVNFE" })
                  cChave := aSeparador[nPsChave]

                  If !Empty(cChave)

                     EZ0->(dbSetOrder(1))    // EZ0_FILIAL+EZ0_CHVNFE    
                     If EZ0->(dbSeek(xFilial("EZ0")+cChave))
                        EZ0->( RecLock('EZ0',.F.))
                     Else
                        EZ0->( RecLock('EZ0',.T.))
                        // volumetria
                        U_EZVolUpdate("NFE")
                     Endif 
                     EZ0->EZ0_FILIAL := xFilial("EZ0")
                     EZ0->EZ0_TIPONF := "NFs"
                     EZ0->EZ0_CHVNFE := cChave
                     EZ0->EZ0_XMLNFE := cLinha
                     EZ0_STIN()
                     EZ0->(msUnlock())
                     
                     aAdd(aChaves , { cChave, EZ0->(Recno()) } )

                  Endif 

               Endif
               
            Enddo 

         Endif 

         oFile:Close()
         FRename(oFile:cfilename,oFile:cfilename+".processado")

      Next nX

   Endif 

   If Len(aChaves) > 0 
        
      nRegua := Len(aChaves)

      dbSelectArea("EZ4")
      EZ4->(dbSetOrder(1))

      For nX := 1 to Len(aChaves)

         nCont++
         oSelf:IncRegua1("Extraindo dados da chave: " + aChaves[nX,1])
         oSelf:IncRegua2("Processando: " + CValToChar(nX) + " de " + CValToChar(nRegua))

         EZ4->(dbSetOrder(1))
         EZ4->(dbSeek(xFilial('EZ4')+'NFs'))

         //EZ0->(dbGoTo(aChaves[nX,2]))  // Recno
         EZ0->(dbSetOrder(1))
         lRecLock := EZ0->(dbSeek(xFilial("EZ0")+aChaves[nX,1]))
         RecLock("EZ0",!lRecLock)

         While !EZ4->(Eof()) .And. xFilial("EZ4")+"NFs" == EZ4->(EZ4_FILIAL+EZ4_TIPONF)
            If !Empty(EZ4->EZ4_ACAO) .And. "EZ0" $ EZ4->EZ4_CAMPO .And. EZ4->EZ4_ATIVA == "1"
               EZ0->&(EZ4->EZ4_CAMPO) := &(EZ4->EZ4_ACAO)
            ElseIf !Empty(EZ4->EZ4_ACAO) .And. "F1_" $ EZ4->EZ4_CAMPO .And. EZ4->EZ4_ATIVA == "1"
               cCampo := AchaField( AllTrim(EZ4->EZ4_CAMPO) , 1 )
               EZ0->&(cCampo) := &(EZ4->EZ4_ACAO)               
            Endif 
            EZ4->(dbSkip())
         Enddo 
         MsUnlock()

         EZ4->(dbSetOrder(1))
         EZ4->(dbSeek(xFilial('EZ4')+'NFs'))

         lRecLock := EZ1->(dbSeek(xFilial("EZ1")+aChaves[nX,1]))
         RecLock("EZ1",!lRecLock)
         EZ1->EZ1_FILIAL := xFilial("EZ1")

         While !EZ4->(Eof()) .And. xFilial("EZ4")+"NFs" == EZ4->(EZ4_FILIAL+EZ4_TIPONF)
            If !Empty(EZ4->EZ4_ACAO) .And. "EZ1" $ EZ4->EZ4_CAMPO .And. EZ4->EZ4_ATIVA == "1"
               EZ1->&(EZ4->EZ4_CAMPO) := &(EZ4->EZ4_ACAO)
            ElseIf !Empty(EZ4->EZ4_ACAO) .And. "D1_" $ EZ4->EZ4_CAMPO .And. EZ4->EZ4_ATIVA == "1"
               cCampo := AchaField( AllTrim(EZ4->EZ4_CAMPO) , 1 )
               EZ1->&(cCampo) := &(EZ4->EZ4_ACAO)
            Endif 
            EZ4->(dbSkip())
         Enddo 
         MsUnlock()

         aChvnfe1 := {}
         aadd( aChvnfe1 , { EZ0->EZ0_CHVNFE , EZ0->(RECNO()) , EZ0->EZ0_TIPONF } )
         VldDadosNF(aChvnfe1[1])

         EZ0->( RecLock('EZ0',.F.))
         EZ0->( EZ0_STIN() )  // atualiza o status
         EZ0->(msUnlock())

         If lUsaPort
            U_RegLogUser("1")   // Integracao Automatico
            VldDadosNF(aChaves[nX])
            U_AndaProcesso("A",lSchedule)
         Endif 
         
      Next nX

   Endif 

   //If !Empty(cMsg)
   //   Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Importacao NFS-e")
   //Endif 

Return 

/*
// -----------------------------------------------------------------------------------------
// Fonte:    Portal_XML.PRW
// -----------------------------------------------------------------------------------------
// Funcao:   BuscaProd
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 06/07/20 | Marcio M. Pereira | Realiza a busca do produto
// -----------------------------------------------------------------------------------------
*/
Static Function BuscaProd(cProd)

   Local cTipoDoc  := EZ0->EZ0_ACAO
   Local cProdRet  := "" //ExtraiTXT(EZ0->EZ0_XMLNFE,"EZ1_COD")
   Local cCodFor   := IF(cTipoDoc=="0",EZ0->EZ0_FORNEC,EZ0->EZ0_CLIENT)
   Local cLojfor   := IF(cTipoDoc=="0",EZ0->EZ0_LOJA,EZ0->EZ0_LOJACL)
   Local cAliasTRB := GetNextAlias()
   Local cSql      := ""
   
   // So Extrai Texto se vier da parte de nota de servico
   Default cProd    := ExtraiTXT(EZ0->EZ0_XMLNFE,"EZ1_COD")
   
   If cTipoDoc == "0"
      If SuperGetMV("EZ_PRODPC" ,.F.,.F.)
         cSql += " SELECT * " + CRLF
         cSql += " FROM " + RetSqlName("SC7") + " " + CRLF
         cSql += " WHERE C7_NUM     = '" + EZ1->EZ1_PEDIDO + "' " + CRLF
         cSql += " AND   C7_ITEM    = '" + EZ1->EZ1_ITEMPC + "' " + CRLF
         cSql += " AND   D_E_L_E_T_ = ' ' " + CRLF
         cSql += " AND   C7_FILIAL  = '"+xFilial("SC7")+"' " + CRLF
         DBUseArea(.T., "TOPCONN", TCGenQry( , , cSql), (cAliasTRB), .F., .T.)
         If !(cAliasTRB)->(Eof()) .And. !Empty(EZ1->EZ1_PEDIDO)
            cProdRet := (cAliasTRB)->C7_PRODUTO
         Else 
            IF EZ0->EZ0_TIPO $ 'D|B'
               dbSelectArea("SA7")
               SA7->(dbSetOrder(3)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI
               If SA7->(dbSeek(xFilial("SA7")+cCodFor+cLojfor+cProd))
                  cProdRet := SA7->A7_PRODUTO
               Endif 
            Else 
               dbSelectArea("SA5")
               SA5->(dbSetOrder(14)) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF
               If SA5->(dbSeek(xFilial("SA5")+cCodFor+cLojfor+cProd))
                  cProdRet:= SA5->A5_PRODUTO
               Endif 
            Endif 
         Endif 
         (cAliasTRB)->(dbCloseArea())
         
      Else 
         IF EZ0->EZ0_TIPO $ 'D|B'
            dbSelectArea("SA7")
            SA7->(dbSetOrder(3)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI
            If SA7->(dbSeek(xFilial("SA7")+cCodFor+cLojfor+cProd))
               cProdRet := SA7->A7_PRODUTO
            Endif 
         Else 
            dbSelectArea("SA5")
            SA5->(dbSetOrder(14)) // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF
            If SA5->(dbSeek(xFilial("SA5")+cCodFor+cLojfor+cProd))
               cProdRet:= SA5->A5_PRODUTO
            Endif 
         Endif 
      Endif 
   Else
      dbSelectArea("SA7")
      SA7->(dbSetOrder(3)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI
      If SA7->(dbSeek(xFilial("SA7")+cCodFor+cLojfor+cProd))
         cProdRet := SA7->A7_PRODUTO
      Endif 
   Endif 
   If Empty(cProdRet)
      cProdRet := cProd
   Endif

Return cProdRet

/*
// -----------------------------------------------------------------------------------------
// Fonte:    Portal_XML.PRW
// -----------------------------------------------------------------------------------------
// Funcao:   ExecMATA410
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 06/07/20 | Marcio M. Pereira | Realiza a geracao de pedidos de venda
// -----------------------------------------------------------------------------------------
*/
Static Function ExecMATA410(aChaves,oProcess,lEnd, lSchedule)

   Local aCabec := {}, aItens := {}//, aAux := {}, cCampo:=''
   Local j:=0, nZ:=0, nI:=0,  cMsg:=""
   Local aCpoParc  := {}
   Local aCpoVenc  := {}
   Local cDescNFS  := ""
   Local nMoeda    := 1
   Local nValor    := 0 
   Local nTaxa     := 0
   Local aCposUser := {}
   Local nC        := 0

   Private lMsErroAuto := .F.
   Private lAutoErrNoFile := .T.

   Default lSchedule := .F.

   dbSelectArea("SX3")
   SX3->(dbSetOrder(1))
   SX3->(dbSeek("EZ0"))
   While !SX3->(Eof()) .And. "EZ0" == SX3->X3_ARQUIVO
      If "EZ0_PARC" $ SX3->X3_CAMPO
         aAdd(aCpoParc,SX3->X3_CAMPO)
      Endif 
      If "EZ0_DATA" $ SX3->X3_CAMPO
         aAdd(aCpoVenc,SX3->X3_CAMPO)
      Endif       
      SX3->(dbSkip())
   Enddo 

   EZ1->(dbSetOrder(1))
   EZ2->(dbSetOrder(1))
   EZ3->(dbSetOrder(1))

   If !lSchedule
      oProcess:SetRegua1(Len(aChaves))
   Endif 

   for j:=1 to Len(aChaves)

      nMoeda := 1
      nTaxa  := 0 
      
      if lEnd
         cMsg += 'Processo interrompido por usuario'  + ENTER
         Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Pedido")
         return
      Endif

      lConfirmado := .T.
      EZ0->(dbGoTo(aChaves[j,2])) // posiciona na EZ0
      
      oProcess:IncRegua1("Gerando Pedido da nota: "+ EZ0->EZ0_DOC+'-' + EZ0->EZ0_SERIE)
      cMsg += ENTER + '----------------------------------' + ENTER + ENTER
      cMsg += "NFS-e Chave n.: " + EZ0->EZ0_CHVNFE + ENTER

      if EZ0->EZ0_STINTE == '1' .And. !Empty(EZ0->EZ0_DOCGER)// Status de nf gerada Nao faz de novo
         MsgAlert("O Pedido " + EZ0->EZ0_DOCGER + " "+ENTER+"ja foi gerado anteriormente.")
         lConfirmado := .F.
         RecLock("EZ0",.F.)
         EZ0->EZ0_STINTE := '1'
         MsUnlock()         
      Endif

      if lConfirmado

         oProcess:SetRegua2(10)
         oProcess:IncRegua2("Verificando validacoes")

         EZ2->(dbCloseArea())
         If Select("EZ2") > 0
            dbSelectArea("EZ2")
         Endif

         EZ2->(dbSetOrder(1))
         EZ2->( dbseek( EZ0->(EZ0_FILIAL+EZ0_CHVNFE) ) )
         while EZ2->(EZ2_FILIAL+EZ2_CHVNFE) == EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
            if EZ2->EZ2_STATUS = '2'             // "1=Aviso;2=Erro;0=ok"
               lConfirmado := .F.                // so executa o ExecAuto se Nao houver nenhuma restricao
            Endif
            EZ2->(dbSkip())
         Enddo

         if lConfirmado
            oProcess:IncRegua2("Montagem de cabecario")		  // MONTA ARRAY COM CAMPOS DA SF1
            cMsg += "validacoes sem restricoes "+ENTER

            If EZ0->EZ0_TIPONF == "NFs"
               cDescNFS := ExtraiTXT(EZ0->EZ0_XMLNFE, "EZ0_XMLNFE")
            Endif 

            If !Empty(EZ0->EZ0_CLIENT)
               SA1->(dbSetOrder(1))
               SA1->(dbSeek(xFilial("SA1")+EZ0->(EZ0_CLIENT+EZ0_LOJACL)))
               cCodCliFor := SA1->A1_COD 
               cLojCliFor := SA1->A1_LOJA
               cEstado    := SA1->A1_EST 
            Else
               SA2->(dbSetOrder(1))
               SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
               cCodCliFor := SA2->A2_COD 
               cLojCliFor := SA2->A2_LOJA
               cEstado    := SA2->A2_EST 
            Endif 

            cDoc := StrZero(Val(EZ0->EZ0_DOC),9)

            aCabec := {}
            aAdd( aCabec , { "C5_FILIAL"	, xFilial("SC5")  , Nil } )   	
            aAdd( aCabec , { "C5_CLIENTE"	, cCodCliFor	   , Nil } )
            aAdd( aCabec , { "C5_LOJACLI"	, cLojCliForS	   , Nil } )
            aAdd( aCabec , { "C5_TIPO"		, EZ0->EZ0_TIPO   , Nil } ) 
            aAdd( aCabec , { "C5_CONDPAG"	, EZ0->EZ0_COND   , Nil } ) 
            aAdd( aCabec , { "C5_EMISSAO"	, EZ0->EZ0_EMISSA , Nil } )    
            aAdd( aCabec , { "C5_NATUREZ"	, EZ0->EZ0_NATURE , Nil } )         
            aAdd( aCabec , { "C5_XNFSXML"	, cDoc            , Nil } )         
            aAdd( aCabec , { "C5_XSERXML"	, EZ0->EZ0_SERIE  , Nil } )   

            If EZ0->EZ0_TIPONF == "CTe"
               aAdd( aCabec , { "C5_UFORIG"	, EZ0->EZ0_UFORIT  , Nil } )   
               aAdd( aCabec , { "C5_UFDEST"	, EZ0->EZ0_UFDEST  , Nil } )   
            Endif 

            // INICIO - Nova regra para tratamento da moeda
            IF cEstado == "EX"
               If EZ0->EZ0_TXMOED > 0 
                  nMoeda := EZ0->EZ0_MOEDA
                  nTaxa := EZ0->EZ0_TXMOED
                  aAdd( aCabec , { "C5_MOEDA"   , EZ0->EZ0_MOEDA  , Nil } )               
                  aAdd( aCabec , { "C5_TXMOEDA" , EZ0->EZ0_TXMOED , Nil } )               
               Else 
                  nMoeda := EZ0->EZ0_MOEDA
                  aAdd( aCabec , { "C5_MOEDA" , nMoeda , Nil } )               
                  nTaxa := Posicione("SM2",1,DTOS(EZ0->EZ0_EMISSA),"M2_MOEDA"+Alltrim(cValToChar(nMoeda)))
                  If nTaxa == 0 
                     cMsg += "Nao ha taxa cadastrada para a data de " + EZ0->EZ0_EMISSA  + ENTER
                  Endif 
               Endif 
            Else 
               nMoeda := 1
               aAdd( aCabec , { "C5_MOEDA" , 1  , Nil } ) 
            Endif            
            // FIM

            If !Empty(cDescNFS)
               aAdd( aCabec , { "C5_XDSCNFS"	, cDescNFS        , Nil } )         
            Endif 
            aAdd( aCabec , { "C5_XCHVNFE"	, EZ0->EZ0_CHVNFE , Nil } )

            // Trato a condicao de pagamento            
            dbSelectArea("SE4")
            SE4->(dbSetOrder(1))
            SE4->(dbSeek(xFilial("SE4")+EZ0->EZ0_COND))
            If SE4->E4_TIPO == "9"
               For nZ := 1 to Len(aCpoParc)
                  If !Empty(EZ0->&(aCpoParc[nZ]))
                     If SC5->(FieldPos("C5_PARC"+cValToChar(nZ))) > 0
                        nParcela := 0 
                        If nTaxa > 0
                           nParcela := Round(EZ0->&(aCpoParc[nZ])/nTaxa,2)
                        Else
                           nParcela := EZ0->&(aCpoParc[nZ])
                        Endif 
                        aAdd( aCabec , { "C5_PARC"+cValToChar(nZ)	, nParcela             , Nil } )
                        aAdd( aCabec , { "C5_DATA"+cValToChar(nZ)	, EZ0->&(aCpoVenc[nZ]) , Nil } )
                     Endif
                  Endif 
               Next nZ
            Endif

            // OCP - Marcio Martins - 10/10/2022
            If ExistBlock("PPXMLSC5")
               aCposUser := ExecBlock("PPXMLSC5", .F., .F.)
               If Len(aCposUser) > 0
                  For nC := 1 To Len(aCposUser)
                     AAdd(aCabec, aCposUser[nC])
                  Next nC
               EndIf
            EndIf   

            aCabec:= FWVetByDic( aCabec , "SC5" , .F. , 1 )

            cItem  := "00"
            aItem  := {}
            aItens := {}
            dbSelectArea("EZ1")
            EZ1->(dbSetOrder(1))
            EZ1->(dbSeek(xFilial("EZ1")+EZ0->EZ0_CHVNFE))
            
            While !EZ1->(Eof()) .And. xFilial("EZ1")+EZ0->EZ0_CHVNFE == EZ1->(EZ1_FILIAL+EZ1_CHVNFE)   
               If nMoeda > 1
                  If nTaxa == 0
                     nValor := EZ1->EZ1_VUNIT
                  Else
                     nValor := Round(EZ1->EZ1_VUNIT/nTaxa,2)
                  Endif 
               Else  
                  nValor := EZ1->EZ1_VUNIT
               Endif 
               dbSelectArea("SB1")
               SB1->(dbSetOrder(1))
               SB1->(dbSeek(xFilial("SB1")+Padr(EZ1->EZ1_COD,TamSX3("B1_COD")[1])))
               cItem := Soma1(cItem)
               aAdd( aItem , { "C6_ITEM"		,cItem      	                  , Nil } )
               aAdd( aItem , { "C6_PRODUTO"	,EZ1->EZ1_COD	                  , Nil } )
               aAdd( aItem , { "C6_UM"	      ,SB1->B1_UM 	                  , Nil } )
               aAdd( aItem , { "C6_LOCAL"	   ,SB1->B1_LOCPAD	               , Nil } )
               aAdd( aItem , { "C6_QTDVEN"	,EZ1->EZ1_QUANT	               , Nil } )
               aAdd( aItem , { "C6_PRUNIT"	,nValor                          , Nil } )
               aAdd( aItem , { "C6_PRCVEN"	,nValor                          , Nil } )
               aAdd( aItem , { "C6_VALOR"		,Round(nValor*EZ1->EZ1_QUANT,2)  , Nil } )
               aAdd( aItem , { "C6_TES"		,EZ1->EZ1_TES                    , Nil } )
               aAdd( aItem , { "C6_ENTREG"	,EZ0->EZ0_EMISSA                 , Nil } )
               If !Empty(EZ1->EZ1_CC)
                  aAdd( aItem , { "C6_CC"		,EZ1->EZ1_CC                     , Nil } )
               Endif 
               If EZ0->EZ0_TIPO $ "D|B"
                  aAdd( aItem , { "C6_NFORI"	  ,EZ1->EZ1_NFORI                , Nil } )
                  aAdd( aItem , { "C6_SERIORI" ,EZ1->EZ1_SERIOR               , Nil } )
                  aAdd( aItem , { "C6_ITEMORI" ,EZ1->EZ1_ITEMOR               , Nil } )
               Endif 

               If ExistBlock("PPXMLSC6")
                  aCposUser := ExecBlock("PPXMLSC6", .F., .F.)
                  If Len(aCposUser) > 0
                     For nC := 1 To Len(aCposUser)
                        AAdd(aItem, aCposUser[nC])
                     Next nC
                  EndIf
               EndIf  

               aItem:= FWVetByDic( aItem , "SC6" , .F. , 1 )
               aadd( aItens , aItem )                       
               EZ1->(dbSkip())
            Enddo 

            If Len(aCabec) > 0 .And. Len(aItens) > 0 
               Begin Transaction
                  If !Empty(EZ0->EZ0_CLIENT)
                     SA1->(dbSetOrder(1))
                  Else 
                     SA2->(dbSetOrder(1))
                  Endif 
                  lMSErroAuto	:= .F.                     
                  MsgRun("Gerando Pedido","Processando",{|| MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,3)  })                  
                  If lMSErroAuto
                     DisarmTransaction()
                     cMsg += "Pedido Nao Gerado!" + ENTER
                     aErro := GetAutoGRLog()
                     For nI := 1 To Len(aErro)
                        cMsg += aErro[nI] + Chr(13) + Chr(10)
                     Next nI
                  else
                     RecLock("EZ0",.F.)
                     EZ0->EZ0_STINTE := '1'
                     EZ0->EZ0_DOCGER := SC5->C5_NUM
                     If EZ0->(FieldPos("EZ0_NUM")) > 0 
                        EZ0->EZ0_NUM := SC5->C5_NUM   // OCP - MARCIO MARTINS - 10/10/2022
                     Endif
                     MsUnlock()
                     oProcess:SetRegua2(10)
                     oProcess:IncRegua2("Pedido Gerado " + SC5->C5_NUM + "!")   
                     cMsg += "Pedido Gerado: " + SC5->C5_NUM + ENTER  
                  Endif
               End Transaction

            Endif 
            
         Else
            cMsg += "Existem restricoes de validacao. "+ENTER
            cMsg += "Pedido Nao foi gerado. "+ENTER
         endif
      Else
         cMsg += "Pedido gerado em processamento anterior"+ENTER
         cMsg += "nenhuma acao foi executada"+ENTER
      endif

   next j

   Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Pedido")

Return

//==============================================================================================================================================
// AQUI INICIO O TRATAMENTO DE BUSCA DOS CTE�S VIA WEBSERVICE
//==============================================================================================================================================

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcCTE
Realiza a conexao no WebService para busca dos CTEs
@type function
@author    Marcio Martins Pereira
@version   1.xx
@since     16/08/2019
/*/
//------------------------------------------------------------------------------------------ 
User Function ProcCTE(oSelf, lSchedule)

   Local aArea     := GetArea()   
   Local cURL 	    := "https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?wsdl"
   Local cMsg      := ""
   Local oWsdl     := Nil
   Local cMsgRet   := ""
   Local cError    := ""
   Local cWarning  := ""
   Local cXmlGZip  := ""
   Local cUltNSU	 := ""                              
	Local cUfAutor  := ""
   Local cCert	    := If((SuperGetMV("EZ_DEMO",.F.,.F.)),'',RetIdEnti()) //If((cEmpAnt=="99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)),'',RetIdEnti())
	Local nM		    := 0
   Local nX        := 0
   Local lRet      := .T.   
   Local lContinua := .T.
	Local cParNSU   := "000000000000000" 
   Local cAliasTRB := GetNextAlias()
	//Local cCaminho  := SuperGetMV("EZ_PX_CERT",.f.,"") 
   //Local cCommand  := ""
   //Local cPath     := ""
   //Local lWait     := .F. 

   Private oXmlDocZip                                               
	Private cCNPJ	:= SM0->M0_CGC	// aqui eu tenho que localizar o certificado correspondente ao CNPJ

   Default oSelf := Nil 
   Default lSchedule := .F.  

   If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpAnt == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)// apenas para testes dos analistas
      cCNPJ	:= "61136149000510"
      cCert := "000001"
   Endif 

   //Instancia a classe
   oWsdl := TWsdlManager():New()	

   //Retorno o Codigo da UF
	cUFAutor := RetCodUf()
	
   // Valido o Preenchimento da UF (M0_ESTCOB)
	If Empty(cUFAutor)
		MsgAlert("E necessario Prenchimento do campo M0_ESTCOB")
		Conout("E necessario Prenchimento do campo M0_ESTCOB")
		Return
	Endif
	
   If !File("\certs\"+cCert+"_all.pem")
      If lSchedule
         Conout("Nao foram encontrados os certificados dentro da pasta \certs\"+CRLF+"Copie os arquivos para la e Re-execute!")
      Else
         MsgAlert("Nao foram encontrados os certificados dentro da pasta \certs\"+CRLF+"Copie os arquivos para la e Re-execute!")
      Endif 
      Return 
   Endif 
   // Carrego os certificados
   oWsdl:cSSLCACertFile := "\certs\"+cCert+"_all.pem"
   oWsdl:cSSLCertFile   := "\certs\"+cCert+"_cert.pem"
   oWsdl:cSSLKeyFile    := "\certs\"+cCert+"_key.pem"
   oWsdl:lSSLInsecure   := .T.
   oWsdl:nSSLVersion 	 := 0    // mudei aqui
   oWsdl:nTimeout       := 120
      
   //Tenta fazer o Parse da URL
   lRet := oWsdl:ParseURL(cURL)
   If ! lRet 
      Conout("Erro ParseURL: " + oWsdl:cError)
      lContinua := .F.
   EndIf

   //Define a operacao
   If lContinua           
      aOps := oWsdl:ListOperations()
      lRet := oWsdl:SetOperation("cteDistDFeInteresse")
      If ! lRet 
         Conout("Erro SetOperation: " + oWsdl:cError)
         lContinua := .F.
      EndIf
   EndIf
   
   If lContinua

      cSQL := " SELECT MAX(EZ0_ULTNSU)  EZ0_ULTNSU " + CRLF
      cSQL += " FROM " + RetSqlName("EZ0") + CRLF
      cSQL += " WHERE EZ0_FILIAL ='"+xFilial("EZ0")+"' AND EZ0_TIPONF = 'CTe' AND D_E_L_E_T_ = ' ' " + CRLF // 03/01/2022 - MARCIOP - Implementado filtro para EZ0_TIPONF
      DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)
      If !(cAliasTRB)->(Eof())
         cUltNSU := (cAliasTRB)->EZ0_ULTNSU
      Endif 
      (cAliasTRB)->(dbCloseArea())
      
      If Empty(cUltNSU)
         cUltNSU := PTRetMax(cUFAutor, cCNPJ, cParNSU, OWSDL,"ULT")
      Endif 

      sleep(2000)

      cMaxNSU := PTRetMax(cUFAutor, cCNPJ, "000000000000000", OWSDL,"MAX")
      nUltNSU := Val(cUltNSU)-10
      nMaxNSU := Val(cMaxNSU)

      If !lSchedule
         If nMaxNSU-nUltNSU > 3000
            nUltNSU := nMaxNSU-3000
         Endif 
      Else 
         If nMaxNSU-nUltNSU > 3000
            nUltNSU := nMaxNSU-3000
         Endif 
      Endif 
      
      nUltNSU := nUltNSU-10
      If !lSchedule
         oSelf:SetRegua1(nMaxNSU-nUltNSU)
         oSelf:SetRegua2(10)
      Endif
         
      For nM := nUltNSU to nMaxNSU
         
         cUltNSU := StrZero(nM,15)

         If !lSchedule
            oSelf:IncRegua1("Processando CT-e  NSU: " + CValToChar(nM) + " de " + CValToChar(nMaxNSU))
            oSelf:SetRegua2(5)
            oSelf:IncRegua2("Busca XML")
         Else
            //onout("Processando CTEs" )
            Conout("CT-e Processando - NSU: " + CValToChar(nM ) + " de " + CValToChar(nMaxNSU))
         Endif
                  
         //Monta a mensagem que sera enviada		
         cMsg := ''
         cMsg += '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:cted="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
         cMsg += '   <soap:Header/>'
         cMsg += '   <soap:Body>'
         cMsg += '      <cted:cteDistDFeInteresse>'
         cMsg += '         <cted:cteDadosMsg>'
         cMsg += '            <distDFeInt versao="1.00" xmlns="http://www.portalfiscal.inf.br/cte">'
         cMsg += '               <tpAmb>1</tpAmb>'
         cMsg += '               <cUFAutor>'+Alltrim(cUFAutor)+'</cUFAutor>'
         cMsg += '               <CNPJ>'+Alltrim(cCNPJ)+'</CNPJ>'
         cMsg += '               <consNSU>'
         cMsg += '                  <NSU>'+cUltNSU+'</NSU>'
         cMsg += '               </consNSU>'
         cMsg += '	       </distDFeInt>'
         cMsg += '         </cted:cteDadosMsg>'
         cMsg += '      </cted:cteDistDFeInteresse>'
         cMsg += '   </soap:Body>'
         cMsg += '</soap:Envelope>'	        
         
            // NUNCA MUDAR ESSA CHAVE LOGICA
         oWsdl:lSSLInsecure   := .T.
         
         lRet := oWsdl:SendSoapMsg(cMsg)
         If ! lRet 
            Conout("Erro SendSoapMsg: " + oWsdl:cError)
            Conout("Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
            lContinua := .F.
         EndIf

         If !lSchedule
            oSelf:IncRegua2("Traducao do XML")
         EndIF

         If lContinua
   
            cMsgRet := oWsdl:GetSoapResponse()
            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
            If !Empty(cWarning)
               Conout("Alerta cWarning: " + cWarning)
            EndIf
            If !Empty(cError)
               Conout("Erro cError: " + cError)
               lContinua := .F.
            EndIf
            
         EndIf

         If !lSchedule
            oSelf:IncRegua2("Carregando campos")
         EndIF
      
         If lContinua
   
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U") 
   
               If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
                  
                  // Trata caso seja um array
                  nTotCTE := Len(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP)
                  
                  For nX := 1 to nTotCTE
                  
                     cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[nX]:TEXT
                     PTCTEGrvXML(cXmlGZip,1,nTotCTE,cUltNSU,oSelf,lSchedule)
                     
                  Next nX
                  
               Else
                     
                  // Trata se vier apenas um CTE
                  cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                  PTCTEGrvXML(cXmlGZip,1,1,cUltNSU,oSelf,lSchedule)
                  
               Endif

            Endif
            
         EndIf

         If !lSchedule
            oSelf:IncRegua2("Processando finalizado ")
         EndIF

      Next nM
   
   EndIf

   RestArea(aArea)
   
Return


//==============================================================================================================================================
// AQUI INICIO O TRATAMENTO DE BUSCA DOS NFE�S VIA WEBSERVICE
//==============================================================================================================================================

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcNFE
Realiza a conexao no WebService para busca das NF-e�s
@type Function
@author    Marcio Martins Pereira
@version   1.xx
@since     03/01/2022
/*/
//------------------------------------------------------------------------------------------ 
User Function ProcNFE(oSelf, lSchedule, nRestam)

   Local aArea     := GetArea()   
   Local cURL 	    := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL" 
   Local cMsg      := ""
   Local oWsdl     := Nil
   Local cMsgRet   := ""
   Local cError    := ""
   Local cWarning  := ""
   Local cXmlGZip  := ""                       
   Local cUfAutor  := ""
   Local cCert	    := If((SuperGetMV("EZ_DEMO",.F.,.F.)),'',RetIdEnti()) //If((cEmpAnt=="99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)),'',RetIdEnti()) //If(cEmpAnt=="99",'',RetIdEnti())
   Local nX        := 0
   Local lRet      := .T.   
   Local lContinua := .T.
   //Local cParNSU   := "000000000000000" 
   //Local cAliasTRB := GetNextAlias()
   //Local cCaminho  := SuperGetMV("EZ_PX_CERT",.f.,"") 
   //Local lWait     := .F.
   Local nNsu      := 0
   Local jINsu     := 0
   Local jFNsu     := 0
   Local jNsu      := ""
   Local LoopLimit := 12 // n�o deixa rodar o distnsu mais de 12 vezes
   Local CountLoop := 0

   Private oXmlDocZip                                               
   Private cCNPJ	:= SM0->M0_CGC	// aqui eu tenho que localizar o certificado correspondente ao CNPJ

   Default nRestam := 0

   If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpAnt == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)// apenas para testes dos analistas
      cCNPJ	:= "61136149000510"
      cCert := "000001"
   Endif 

   Default oSelf := Nil 
   Default lSchedule := .F.  

   //Carla Barbosa 20/05/2022
   //Funcao para criar parametro por filial
   EzCheckPar(xFilial("EZ0"))
   cUltNSU	 := GetMV("EZ_PX_NSU") 
   dDatNsu   := GetMV("EZ_PX_DNSU") 
   cHorNsu   := GetMV("EZ_PX_HNSU")

   If !lSchedule
      if dDatNsu == (dDatabase)
         if ElapTime(cHorNsu, Time()) <= "01:05:00"
            lRet := .f.
         ENDIF
      elseif DateDiffDay(dDatNsu,dDatabase) == 1
            if ElapTime(cHorNsu, Time()) <= "01:05:00"
               lRet := .f.
            Endif
      Else
         lRet := .t.
      Endif  
      if !lRet
         Conout("A Rotina de Busca de Notas Via Webservice foi Executada h� menoss de 1 hora")
         if !lSchedule
            MSgAlert("A Rotina de Busca de Notas Via Webservice foi Executada h� menoss de 1 hora")
         Endif
         Return
      Endif
   Endif
   If Val(cUltNSU) == 0 
      cUltNSU := StrZero(0,15)
   Endif 

   // Cria os Diret�rios XMLEVENTOS e XMLTUDO
   // Carla Barbosa - 20/05/2022
   If !ExistDir("\XMLEVENTOS\")
         MakeDir("\XMLEVENTOS\")
   Endif
   If !ExistDir("\XMLTUDO\")
         MakeDir("\XMLTUDO\")
   Endif

   //Instancia a classe
   oWsdl := TWsdlManager():New()	

   //Retorno o Codigo da UF
   cUFAutor := RetCodUf()
      
   // Valido o Preenchimento da UF (M0_ESTCOB)
   If Empty(cUFAutor)
      MsgAlert("E necessario Prenchimento do campo M0_ESTCOB")
      Conout("E necessario Prenchimento do campo M0_ESTCOB")
      Return
   Endif
      
   If !File("\certs\"+cCert+"_all.pem")
      If lSchedule
         Conout("Nao foram encontrados os certificados dentro da pasta \certs\"+CRLF+"Copie os arquivos para la e Re-execute!")
      Else
         MsgAlert("Nao foram encontrados os certificados dentro da pasta \certs\"+CRLF+"Copie os arquivos para la e Re-execute!")
      Endif 
      Return 
   Endif 

   // Carrego os certificados
   oWsdl:cSSLCACertFile := "\certs\"+cCert+"_all.pem"
   oWsdl:cSSLCertFile   := "\certs\"+cCert+"_cert.pem"
   oWsdl:cSSLKeyFile    := "\certs\"+cCert+"_key.pem"
   oWsdl:lSSLInsecure   :=  .T.
   oWsdl:nSSLVersion 	 :=  0    // mudei aqui 
   oWsdl:nTimeout       := 120
    
   //Tenta fazer o Parse da URL
   lRet := oWsdl:ParseURL(cURL)
   If ! lRet 
      If lSchedule
         Conout("Erro ParseURL: " + oWsdl:cError)
      Else
         //CARLA BARBOSA
         //Mensagem incluida 01/08/2022
         MsgAlert("Erro no Parse da URL! Verifique a Validade do Certificado na Pasta Certs"+CRLF+"Erro ParseURL: " + oWsdl:cError)
      Endif 
      lContinua := .F.
   EndIf

   //Define a operacao
   If lContinua           
      aOps := oWsdl:ListOperations()
      lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
      If ! lRet 
         Conout("Erro SetOperation: " + oWsdl:cError)
         lContinua := .F.
      EndIf
   EndIf
   
   If lContinua

      // PEGA O MAXNSU
      //cMaxNSU := PTNFRetMax(cUFAutor, cCNPJ, "000000000000000", OWSDL,"MAX")
      cMaxNSU := PTNFRetMax(cUFAutor, cCNPJ, cUltNSU, OWSDL,"MAX")
      nMaxNSU := Val(cMaxNSU)
      nUltNSU := Val(cUltNSU)

      // Se o MaxNsu == UltNsu consultado - N�o tenho documento para trazer

      if nMaxNSU == nUltNSU
         Conout("N�o h� documentos para buscar.. Ultimo NSU: " + cUltNSU +" igual ao maximo NSU: "+cMaxNSU)
         if !lSchedule
            MsgAlert("N�o h� documentos para buscar... Por favor, tente novamente ap�s 1 hora")
         ENDIF 
         lContinua :=.F.
         Return
      Endif

      // uma pausa para a pr�xima consulta
      Sleep(2000)

      // Carla Barbosa - Tratamento para n�o Buscar desde o NSU 0 quando for 
      // a primeira vez do cliente
      if nUltNSU = 0
         if nMaxNSU >1000
            nUltNSU := nMaxNSU -1000
            cUltNSU := StrZero(nUltNSU,15)
         else
            // aqui eu trago tudo o volume � pequeno
         Endif
      Endif

      if nMaxNSU = 0
         nMaxNSU := nUltNSU
      endif
      
      nRestam := int( ( nMaxNSU - nUltNSU ) / 50 ) + 1
      
      While nUltNSU <= nMaxNSU
         
         // n�o deixa rodar o DistNSU mais de 12 vezes
         CountLoop++
         if CountLoop >= LoopLimit
            exit
         Endif

         If !lSchedule
               //oSelf:IncRegua1("Processando NF-e NSU: " + CValToChar(cUltNSU))
               oSelf:IncRegua1("Processando NF-e NSU: " + CValToChar(nUltNSU) + " de " + CValToChar(nMaxNSU))
               oSelf:SetRegua2(5)
               oSelf:IncRegua2("Busca XML")
         Else
               //onout("Processando CTEs" )
               //Conout("NF-e Processando - NSU: " + CValToChar(cUltNSU))
               Conout("NF-e Processando - NSU: " + CValToChar(nUltNSU) + " de " + CValToChar(nMaxNSU))
         Endif
                  
         //Monta a mensagem que sera enviada		
         // -- VOU MANDAR VIA DISTNSU
         cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                     	+ CRLF
         cMsg += '    <soapenv:Header/>'                                                                             + CRLF
         cMsg += '    <soapenv:Body>'                                                                                + CRLF
         cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
         cMsg += '                <nfeDadosMsg>'                                                                     + CRLF
         cMsg += '                    <distDFeInt versao="1.01" xmlns="http://www.portalfiscal.inf.br/nfe">'         + CRLF
         cMsg += '                        <tpAmb>1</tpAmb>'                                                          + CRLF
         cMsg += '                     	 <cUFAutor>'+cUfAutor+'</cUFAutor>'                                        + CRLF
         cMsg += '                        <CNPJ>'+cCNPJ+'</CNPJ>'                                                  	+ CRLF
         cMsg += '               		 <distNSU>'																	                  + CRLF
         cMsg += '                  			<ultNSU>'+cULTNSU+'</ultNSU>'	 							  					            + CRLF
         cMsg += '               		 </distNSU>'																                  + CRLF
         cMsg += '                    </distDFeInt>'                                                                 + CRLF
         cMsg += '                </nfeDadosMsg>'                                                                    + CRLF
         cMsg += '            </nfeDistDFeInteresse>'                                                                + CRLF
         cMsg += '        </soapenv:Body>'                                                                           + CRLF
         cMsg += '    </soapenv:Envelope>'																			                  + CRLF
         

         // NUNCA MUDAR ESSA CHAVE LOGICA
         oWsdl:lSSLInsecure   := .T.
         
         lRet := oWsdl:SendSoapMsg(cMsg)
         If ! lRet 
               Conout("Erro SendSoapMsg: " + oWsdl:cError)
               Conout("Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
               lContinua := .F.
         EndIf

         If !lSchedule
               oSelf:IncRegua2("Traducao do XML")
         EndIF
 
         If lContinua
   
               cMsgRet := oWsdl:GetSoapResponse()
               oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
               If !Empty(cWarning)
                  Conout("Alerta cWarning: " + cWarning)
               EndIf
               If !Empty(cError)
                  Conout("Erro cError: " + cError)
                  lContinua := .F.
               EndIf
               // Carla Barbosa - Verfica o Retorno
               cSTATUS := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_cstat:text
               xULTNSU := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_ultnsu:text
               conout("xULTNSU: "+ xULTNSU)
               // Atualiza o Ultimo NSU e a Data e Hora da Consulta
               // Marcio Martins - S� gravar se for 100 e 138 e o 656
               if cSTATUS $ '100|138|656'
                  PutMV("EZ_PX_NSU",xULTNSU)
               Endif 
               PutMV("EZ_PX_DNSU",dtoc(dDataBase))
               PutMV("EZ_PX_HNSU",Time()) 
               if cSTATUS == "656" // Consumo Indevido
                  cMotivo := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_xmotivo:text
                  Conout("Erro cError: " + cMotivo)
                  Conout("Ultimo NSU Retornado pelo WS: " + xULTNSU)
                  // xULTNSU == � o NSU que retornou do SEFAZ como CONSUMO INDEVIDO
                  // cULTNSU == � o NSU que eu tentei consultar
                  // ajuste para gravar os consumo indevido na tabela EZC
                  // Carla Barbosa - Marcio Santos - Maio/2023
                  jINsu := Val(cULTNSU)
                  jFNsu := Val(xULTNSU)
                  For nNsu:= jINsu to jFNsu
                     jNsu:= StrZero(nNsu,15)
                     EZGravNsu(jNsu,"0","NR NSU "+Alltrim(jNsu))
                     Conout("NSU Gravado como Consumo Indevido na EZC " + "["+ jNsu +"]")
                  Next
                  if !lSchedule
                     MsgAlert(cMotivo)
                  Endif      
                  Return  
               Elseif cSTATUS == "137" // Nenhum Documento Localizado
                  cMotivo := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_xmotivo:text
                  Conout("Erro cError: " + cMotivo)
                  if !lSchedule
                     MsgAlert(cMotivo)
                  ENDIF      
                  Return                               
               ENDIF
         EndIf
         If !lSchedule
               oSelf:IncRegua2("Carregando campos")
         EndIF
      
         If lContinua
   
            If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U"
   
               If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") == "A"
                  
                  // Trata caso seja um array
                  nTotNFE := Len(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP)
                  nUltNSU := val(cUltNSU) 
                  For nX := 1 to nTotNFE
                  
                     cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP[nX]:TEXT
                     PTNFEGrvXML(cXmlGZip,1,1,cUltNSU,oSelf,lSchedule)

                     // Incrementando o ultimo NSU
                     nUltNSU++
                     cUltNSU := StrZero(nUltNSU,15)
                     
                  Next nX
                  
               Else
                     
                  // Trata se vier apenas um NFE
                  cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                  PTNFEGrvXML(cXmlGZip,1,1,cUltNSU,oSelf,lSchedule)
                  nUltNSU++
                  cUltNSU := StrZero(nUltNSU,15)
               Endif
            
            Else 

               If type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_xmotivo:text") != "U"
                  MemoWrite("\XMLTUDO\"+cUltNSU+"_nfe.txt",oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_xmotivo:text)
               Endif 
               nUltNSU++
               cUltNSU := StrZero(nUltNSU,15)

            Endif
            
         EndIf

         If !lSchedule
            oSelf:IncRegua2("Processando finalizado ")
         EndIF

         
         // uma pausa para a pr�xima consulta
         Sleep(5000)
      enddo
      // Next nM
   
   EndIf

   RestArea(aArea)
   
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EzGetPar
//Realiza a Busca do Parametro na Filial, sen�o encontrar cria 
@author Carla Barbosa
@since 20/05/2022
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function EzCheckPar(zFilial)

Local aArea       := getArea()
Local aDados      := {}
Local i 
Local cAux        := zFilial
//SX6->(dbSetOrder(1)) // X6_FIL+X6_VAR
If SX6->(!dbSeek( zFilial+"EZ_PX_DNSU" ))  
   aadd(aDados,{ cAux ,"EZ_PX_DNSU" ,"D" ,"Data da Ultima Consulta WebService NSU", dtoc(dDataBase) })
ENDIF
If SX6->(!dbSeek( zFilial+"EZ_PX_HNSU" ))  
   aadd(aDados,{ cAux ,"EZ_PX_HNSU" ,"C" ,"Hora da Ultima Consulta WebService NSU", "00:00:00" })
ENDIF
If SX6->(!dbSeek( zFilial+"EZ_PX_NSU" ))  
   aadd(aDados,{ cAux ,"EZ_PX_NSU" ,"C" ,"Informe o Ultimo NSU Consultado", "000000000000000" })
ENDIF
If SX6->(!dbSeek( zFilial+"EZ_PX_NSUC" ))  
   aadd(aDados,{ cAux ,"EZ_PX_NSUC" ,"C" ,"Informe o Ultimo NSU Controlado", "000000000000000" })
ENDIF
If SX6->(!dbSeek( zFilial+"EZ_NSUNFSE" ))  
   aadd(aDados,{ cAux ,"EZ_NSUNFSE" ,"C" ,"Informe o Ultimo NSU para NFSE Nacional", "000000000000000" })
ENDIF
//If SX6->(!dbSeek( zFilial+"EZ_CTEALL" ))  
//   aadd(aDados,{ cAux ,"EZ_CTEALL" ,"L" ,"Baixa todos os CTEs", .F. })
//ENDIF

SX6->(dbSetOrder(1)) // X6_FIL+X6_VAR
for i:= 1 to len(aDados)
   SX6->(RecLock("SX6",.T.))
   SX6->X6_FIL   := aDados[i,1]
   SX6->X6_VAR   := aDados[i,2]
   SX6->X6_TIPO  := aDados[i,3]
   SX6->X6_DESCRIC := aDados[i,4]
   SX6->X6_CONTEUD := aDados[i,5]
   SX6->(dbUnlock())
Next
RestArea(aArea)
Return  

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PTNFRetMax
//Realiza a Busca no Numero Maximo do NSU, so se consegue buscando
@author Marcio Martins Pereira
@since 23/08/2019
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function PTNFRetMax(cUFAutor, cCNPJ, cUltNSUL, OWSDL,cAcao)

	Local cMsg := ""
	Local cRet := cUltNSUL
	Local lContinua := .T.

   cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                     	+ CRLF
   cMsg += '    <soapenv:Header/>'                                                                             + CRLF
   cMsg += '    <soapenv:Body>'                                                                                + CRLF
   cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
   cMsg += '                <nfeDadosMsg>'                                                                     + CRLF
   cMsg += '                    <distDFeInt versao="1.01" xmlns="http://www.portalfiscal.inf.br/nfe">'         + CRLF
   cMsg += '                        <tpAmb>1</tpAmb>'                                                 + CRLF
   cMsg += '                     	 <cUFAutor>'+cUfAutor+'</cUFAutor>'                                         + CRLF
   cMsg += '                        <CNPJ>'+cCNPJ+'</CNPJ>'                                                  	+ CRLF
   cMsg += '               		 <consNSU>'																	+ CRLF
   cMsg += '                  			<NSU>'+cUltNSUL+'</NSU>'	 							  					+ CRLF
   cMsg += '               		 </consNSU>'																+ CRLF
   cMsg += '                    </distDFeInt>'                                                                 + CRLF
   cMsg += '                </nfeDadosMsg>'                                                                    + CRLF
   cMsg += '            </nfeDistDFeInteresse>'                                                                + CRLF
   cMsg += '        </soapenv:Body>'                                                                           + CRLF
   cMsg += '    </soapenv:Envelope>'																			+ CRLF

	// NUNCA MUDAR ESSA CHAVE LOGICA
	oWsdl:lSSLInsecure   := .T.
    oWsdl:lProcResp := .F.        // -->> https://devforum.totvs.com.br/1858-unknown-element-wscoridsoapheader

    lRet := oWsdl:SendSoapMsg(cMsg)
    If ! lRet 
        Conout("Erro SendSoapMsg: " + oWsdl:cError)
        Conout("Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
        lContinua := .F.
    EndIf

    If lContinua
      cMsgRet := oWsdl:GetSoapResponse()    
		If cAcao == "MAX"
        	cRet := SubStr(cMsgRet,AT("<maxNSU>",cMsgRet)+Len("<maxNSU>"),15)
         cUltNSUF := SubStr(cMsgRet,AT("<ultNSU>",cMsgRet)+Len("<ultNSU>"),15)
         // teste na inbra - sem esta parte
         /*
         If val(cUltNSU) > val(cUltNSUF)
            if  val(cUltNSUF) <> 0
                cUltNSU := cUltNSUF
            Endif
         Endif 
         */
  		Else
	  		cRet := SubStr(cMsgRet,AT("<ultNSU>",cMsgRet)+Len("<ultNSU>"),15)
  		Endif
      //cRet := StrZero(val(cRet)+1,15)
	Endif

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PTRetMax
//Realiza a Busca no Numero Maximo do NSU, so se consegue buscando
@author Marcio Martins Pereira
@since 23/08/2019
@version 1.00

@type function
/*/
//------------------------------------------------------------------------------------------
Static Function PTRetMax(cUFAutor, cCNPJ, cUltNSU, OWSDL,cAcao)

	Local cMsg := ""
	Local cRet := cUltNSU
//	Local nPos := 0
	Local lContinua := .T.
	
    cMsg += '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:cted="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
    cMsg += '   <soap:Header/>'
    cMsg += '   <soap:Body>'
    cMsg += '      <cted:cteDistDFeInteresse>'
    cMsg += '         <cted:cteDadosMsg>'
    cMsg += '            <distDFeInt versao="1.00" xmlns="http://www.portalfiscal.inf.br/cte">'
    cMsg += '               <tpAmb>1</tpAmb>'
    cMsg += '               <cUFAutor>'+Alltrim(cUFAutor)+'</cUFAutor>'
    cMsg += '               <CNPJ>'+Alltrim(cCNPJ)+'</CNPJ>'
    cMsg += '               <distNSU>'
    cMsg += '                  <ultNSU>'+cUltNSU+'</ultNSU>'
    cMsg += '               </distNSU>'
    cMsg += '	       </distDFeInt>'
    cMsg += '         </cted:cteDadosMsg>'
    cMsg += '      </cted:cteDistDFeInteresse>'
    cMsg += '   </soap:Body>'
	cMsg += '</soap:Envelope>'

	// NUNCA MUDAR ESSA CHAVE LOGICA
	oWsdl:lSSLInsecure   := .T.

    lRet := oWsdl:SendSoapMsg(cMsg)
    If ! lRet 
        Conout("Erro SendSoapMsg: " + oWsdl:cError)
        Conout("Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
        lContinua := .F.
    EndIf

    If lContinua
       	cMsgRet := oWsdl:GetSoapResponse()    
		If cAcao == "MAX"
        	cRet := SubStr(cMsgRet,AT("<maxNSU>",cMsgRet)+Len("<maxNSU>"),15)
  		Else
	  		cRet := SubStr(cMsgRet,AT("<ultNSU>",cMsgRet)+Len("<ultNSU>"),15)
  		Endif
      //cRet := StrZero(val(cRet)+1,15)
	Endif

Return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PTCTEGrvXML
Processa os XML dos CTEs
@type function
@author    Marcio Martins Pereira
@version   1.xx
@since     18/08/2019
/*/
//------------------------------------------------------------------------------------------  

Static Function PTCTEGrvXML(cConteudo, nPosicao, nTotCTE, cUltNSU, oSelf, lSchedule)

   Local aArea       := getArea()
   Local lRet        := .T. 
   Local nTamanho    := Len(cConteudo)
   Local cUnXML      := ""
   Local cDecode64   := Decode64(cConteudo)	
   Local lIntGFE     := SuperGetMV("MV_INTGFE" ,.F.,.F.) 
   Local oProcess
   Local lEnd        := .F.   
   Local i           := 0 
   Local cXMLDIR     := Alltrim(SuperGetMV("EZ_LOCXML",.F.,"\xmlnfe\"))
   //Local lGerPDFluig := SuperGetMV("EZ_PDFLUIG",.F.,.F.)
   //Local cLocal      := "\prtdanfe\"
   Private lUsaPort  := SuperGetMV("EZ_USAPORT",.F.,.F.)

   EzCheckPar(xFilial("EZ0"))

   Default nOpcao := 1

   If !Empty(cXMLDIR)
      If !ExistDir(cXMLDIR)
         MakeDir(cXMLDIR)
      Endif
      If Left(cXMLDIR,1)<>"\"
         cXMLDIR := "\"+cXMLDIR
      Endif
      If Right(cXMLDIR,1)<>"\"
         cXMLDIR := cXMLDIR+"\"
      Endif 
   Endif 
//   Private oProcess  := Nil

   Default lSchedule 	:= FWGetRunSchedule()
   
   lRet := GzStrDecomp(cDecode64, nTamanho, @cUnXML)
      
   If lRet

		If AT("<infCte",cUnXML) > 0	

        	cChave    := SubStr(cUnXML,AT("<chCTe>",cUnXML)+Len("<chCTe>"),44)
			dbSelectArea("EZ0")
			EZ0->(dbSetOrder(1))

			If !EZ0->(dbSeek(xFilial("EZ0")+cChave))

            ct_XML := cUnXML

            If !SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpAnt <> "99"  .or. SuperGetMV("EZ_DEMO",.F.,.F.)  //  NAO E EMPRESA TESTE So CARREGA SE FOR DE INTERESSE DA EMPRESA
               If At(AllTrim(SM0->M0_CGC) , ct_XML ) == 0
                  Conout("CT-e - Nao Pertence a Empresa " + cChave)
                  MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
                  return .f. // este xml nao interessa para a empresa
               else
                  If XMLTagCont('cStat',ct_XML) $ SuperGetMV("EZ_PX_STCL" ,.F.,"101,151") 
                     Conout("CT-e - Status diferente de 101 - 151 " + cChave)
                     MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
                     Return .f.
                  Endif
                  IF AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('emit',ct_XML))
                     // Carla Barbosa - 24/11/2022
                     // Criado parametro para baixar todos os XML independente da tag Toma
                     if SuperGetMV("EZ_CTEALL",.F.,.F.)   // Se for para baixar todos
                        lRet := .f.
                        // Se o CNPJ da empresa estiver em alguma TAG eu baixo o CTE
                        if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('rem',ct_XML)) 
                           lRet := .t.
                        Endif
                        if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('exped',ct_XML)) 
                        lRet := .t.
                        endif
                        if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('dest',ct_XML)) 
                           lRet := .t.
                        endif 
                        if !lRet
                           // SALVAR O XML MESMO ASSIM NA PASTA XML EVENTOS
                           Conout("CT-e - Nao Pertence a Empresa " + cChave)
                           MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
                           Return .f.
                        endif 
                     Else                       
                        cToma3 := XMLTagCont('toma',XMLTagCont('toma3',ct_XML))
                        cToma4 := XMLTagCont('toma',XMLTagCont('toma4',ct_XML))
                        do CASE
                           case cToma3 = '0'         //  TOMA3 = 0 ==> REMTENTE - TOMADOR � O REMETENTE - CNPJ DA EMPRESA ESTA NA TAG REM?
                              if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('rem',ct_XML))                                  
                                 Conout("CT-e - Nao Pertence a Empresa " + cChave)
                                 MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
                                 Return .f.
                              end   
                           case cToma3 = '1'         //  TOMA3 = 1 ==> EXPEDIDOR - TOMADOR � O EXPEDIDOR - CNPJ DA EMPRESA ESTA NA TAG EXP?
                              if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('exped',ct_XML)) 
                                 Conout("CT-e - Nao Pertence a Empresa " + cChave)
                                 MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
                                 Return .f.
                              end   
                           case cToma3 = '2' .or. cToma3 = '3' // TOMA3 = 2 ==> RECEBEDOR E TOMA3 = 3 ==> DESTINATARIO
                              if AllTrim(SM0->M0_CGC) <> XMLTagCont('CNPJ',XMLTagCont('dest',ct_XML))
                                 Conout("CT-e - Nao Pertence a Empresa " + cChave)
                                 MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML) 
                                 Return .f.
                              end   
                           case cToma4 = '4' 
                              Conout("CT-e - Nao Pertence a Empresa " + cChave)
                              MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
                              Return .f.
                        endcase 
                     endif       
                  Endif
               Endif
            Endif 
            // volumetria
            U_EZVolUpdate('CTE')
				RecLock("EZ0",.T.)
				EZ0->EZ0_FILIAL := xFilial("EZ0")
				EZ0->EZ0_CHVNFE := cChave
				EZ0->EZ0_XMLNFE := cUnXML
				EZ0->EZ0_TIPONF := "CTe"
            EZ0->EZ0_ULTNSU := cUltNSU
            // Carla Barbosa - 24/11/2022
            // Grava��o da Data que o CTE foi baixado
            If EZ0->(FieldPos("EZ0_DTBXML")) > 0 
               EZ0->EZ0_DTBXML := ddatabase
            Endif 
				EZ0->(EZ0_STIN()) 
				MsUnlock()
            If !Empty(cXMLDIR)
               Conout("CT-e - Salvo na pasta " + cXMLDIR)
               MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
               lRet := MemoWrite(cXMLDIR+"cte-"+EZ0->EZ0_CHVNFE+".xml",EZ0->EZ0_XMLNFE)
            Endif 
            If  EZ0->EZ0_STINTE > '0'
               aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
               for i:=1 to Len(aChaves)
                     EZ0->(dbGoTo(aChaves[i,2]))                        // posiciona na EZ0
                     ExtraiDadosXML(aChaves[i])
                     VldDadosNF(aChaves[i])
                     RecLock("EZ0",.F.)
                     EZ0->(EZ0_STIN()) // 03/01/2022 - MARCIOP - Atualiza o status apos a inclusao
                     MsUnlock()
                     If !lIntGFE
                        IF EZ0->EZ0_ACAO == "0" .AND. SuperGetMV("EZ_PX_PNAU" ,.F.,.F.)
                           If !lSchedule
                              oProcess:=  MsNewProcess():New({|lEnd| ExecMATA140(aChaves,@oProcess,lEnd)}, "EZ4 GRC" , "Criando Notas de Entrada", .T.)
                              oProcess:Activate()
                           Else
                              ExecMATA140(aChaves,@oProcess,lEnd)
                           Endif 
                        eNDIF 
                     Endif
                  next
            Endif
            Conout("CT-e - Gravou EZ0/EZ1 !")
            If  lIntGFE
               U_CTECopy(2)   // Copia Especifico posicionado
            Endif 
			Endif 
      Else
         cChave    := SubStr(cUnXML,AT("<chCTe>",cUnXML)+Len("<chCTe>"),44)
         ct_XML := cUnXML  
         Conout("CT-e - Evento " + cChave)
         MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"cte-"+cChave+".xml",ct_XML)
      Endif
   EndIf
  
   RestArea(aArea)
    
Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PTNFEGrvXML
Processa os XML dos CTEs
@type Function
@author    Marcio Martins Pereira
@version   1.xx
@since     18/08/2019
/*/
//------------------------------------------------------------------------------------------  

Static Function PTNFEGrvXML(cConteudo, nPosicao, nTotCTE, cUltNSU, oSelf, lSchedule)

//   Local oProcess
//   Local lEnd        := .F.   
   Local aArea       := getArea()
   Local lRet        := .T. 
   Local nTamanho    := Len(cConteudo)
   Local cUnXML      := ""
   Local cDecode64   := Decode64(cConteudo)	
   //Local lIntGFE     := SuperGetMV("MV_INTGFE" ,.F.,.F.)
   Local cXMLDIR     := Alltrim(SuperGetMV("EZ_LOCXML",.F.,"\xmlnfe\"))
   //Local lGerPDFluig := SuperGetMV("EZ_PDFLUIG",.F.,.F.)
   Local cLocal      := "\prtdanfe\"
   Local i
   Local lManif      := .F.
   Private lUsaPort  := SuperGetMV("EZ_USAPORT",.F.,.F.)

   Default nOpcao := 1

   If !Empty(cXMLDIR)
      If !ExistDir(cXMLDIR)
         MakeDir(cXMLDIR)
      Endif
      If Left(cXMLDIR,1)<>"\"
         cXMLDIR := "\"+cXMLDIR
      Endif
      If Right(cXMLDIR,1)<>"\"
         cXMLDIR := cXMLDIR+"\"
      Endif 
   Endif 
//   Private oProcess  := Nil

   Default lSchedule 	:= FWGetRunSchedule()
   
   lRet := GzStrDecomp(cDecode64, nTamanho, @cUnXML)
      
    Conout("GzStrDecomp")
    Conout(lRet)
   // Marcio Martins - 31/08/2023
   // Valida se o XML/Resumo pertence ao CNPJ da empresa que est� processando
   // Commentado pois n�o estava entrando nos testes realizados na MEDIAMONKS7
   // CARLA BARBOSA 14/09/2023   
   /*
   If !XMLTagCont('CNPJ',XMLTagCont('dest',cUnXML)) $ Alltrim(SM0->M0_CGC) .And. ;
      !XMLTagCont('CNPJ',XMLTagCont('emit',cUnXML)) $ Alltrim(SM0->M0_CGC)
      lRet := .F.
   Endif 
   */
   //
   If lRet
      // Carla Barbosa - 05/01/2023
      // Criado tabela EZC para guarda dos NSUs - por isso o XML s� ser� gravado se for resumo ou a pr�pria NF
      //lRet := MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"-nfe-"+SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)+".xml",cUnXML)
      EZGravNsu(cUltNSU,"1",SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44))
      If AT("<resNFe",cUnXML) > 0             // � o Resumo da NF
         lRet := MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"-nfe-"+SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)+".xml",cUnXML)
         lResumos++
         cChave    := SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44) 
         C00->(dbsetorder(1))
         if C00->(dbSeek(xFilial("C00")+cChave))
            If IsInCallStack("ProcChave") .Or. IsInCallStack("U_BuscaNSU")
               U_ManifChave(cChave,"210210")  // Ciencia da Opera��o
               lManif := .T.
            Else 
               if C00->C00_STATUS $ '0'          // Sem Manifesta��o
                  U_ManifChave(cChave,"210210")  // Ciencia da Opera��o
                  lManif := .T.
               Endif
            Endif
         else
            U_ManifChave(cChave,"210210")
            lManif := .T.
            // Gravando a C00
            SincAtuDados(cChave,"4","")                    
         Endif
         dbSelectArea("EZ0")
         EZ0->(dbSetOrder(1))
         If !EZ0->(dbSeek(xFilial("EZ0")+cChave))
            RecLock('EZ0', .T.)
            EZ0->EZ0_FILIAL := xFilial("EZ0")
            EZ0->EZ0_CHVNFE := cChave
            EZ0->EZ0_XMLNFE := cUnXML
            EZ0->EZ0_TIPONF := "NFe"
            EZ0->EZ0_ULTNSU := cUltNSU
            // grava��o dos campos abaixo - Carla Barbosa 29/09/2022
            EZ0->EZ0_STINTE := "3"
            EZ0->EZ0_DTEMI  := xConteudo("resnfe", "dhEmi", "xCont := StoD(StrTran(SubStr( xCont,1,10),'-',''))", cUnXML, "D")  // insere o dado na tabela
            EZ0->EZ0_VLDOC  := xConteudo("resnfe", "vNF"  , "xCont := val( xCont )"                             , cUnXML, "N")  // insere o dado na tabela 
            EZ0->EZ0_IEEMIT := xConteudo("resnfe", "IE"   , "xCont := Alltrim(xCont)"                           , cUnXML, "C")  // insere o dado na tabela 
            EZ0->EZ0_MESNFE := StrZero(Month(EZ0->EZ0_DTEMI),2)
            EZ0->EZ0_ANONFE := StrZero(Year(EZ0->EZ0_DTEMI),4)
            If lManif
               //EZ0->EZ0_STATUS := '4' = CARLA BARBOSA 29/12 - NAO PODE SER 4
            Endif 
            AbreChv(cChave)
            // EZ0->(EZ0_STIN()) -- // Carla Barbosa - Status 3 Gravado acima - 29/09/2022
            MsUnlock()   
         Else 
            RecLock('EZ0', .F.)
            If lManif
               //EZ0->EZ0_STATUS := '4' = CARLA BARBOSA 29/12 - NAO PODE SER 4
            Endif 
            MsUnlock()   
         Endif
         // Grava na Tabela EZC que baixou o Resumo
         EZGravNsu(cUltNSU,"2",cChave)
      elseif AT("<infNFe",cUnXML) > 0 .OR. AT("<procNFe",cUnXML)>0 .or. AT("<nfeProc",cUnXML)>0
         lRet := MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"-nfe-"+SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)+".xml",cUnXML)
         lXMLBaixa++
         cChave    := SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)
         // volumetria
         U_EZVolUpdate('NFE') 
         dbSelectArea("EZ0")
         EZ0->(dbSetOrder(1))
         If !EZ0->(dbSeek(xFilial("EZ0")+cChave))
            RecLock("EZ0",.T.)  // n�o tinha o resumo
         else
            RecLock("EZ0",.F.)  // j� tinha o resumo - carla
         Endif   
            EZ0->EZ0_FILIAL := xFilial("EZ0")
            EZ0->EZ0_CHVNFE := cChave
            EZ0->EZ0_XMLNFE := cUnXML
            EZ0->EZ0_TIPONF := "NFe"
            EZ0->EZ0_ULTNSU := cUltNSU
            EZ0->EZ0_DTEMI  := xConteudo("resnfe", "dhEmi", "xCont := StoD(StrTran(SubStr( xCont,1,10),'-',''))", cUnXML, "D")  // insere o dado na tabela
            EZ0->EZ0_VLDOC  := xConteudo("resnfe", "vNF"  , "xCont := val( xCont )"                             , cUnXML, "N")  // insere o dado na tabela 
            EZ0->EZ0_IEEMIT := xConteudo("resnfe", "IE"   , "xCont := Alltrim(xCont)"                           , cUnXML, "C")  // insere o dado na tabela 
            If EZ0->(FieldPos("EZ0_DTBXML")) > 0 
               EZ0->EZ0_DTBXML := ddatabase
            Endif 
            EZ0->(EZ0_STIN()) 
            MsUnlock()
            If !Empty(cXMLDIR)
               Conout("NF-e - Salvo na pasta " + cXMLDIR)
               lRet := MemoWrite(cXMLDIR+"nfe-"+EZ0->EZ0_CHVNFE+".xml",EZ0->EZ0_XMLNFE)
            Endif 
            If  EZ0->EZ0_STINTE > '0'
               aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
               for i:=1 to Len(aChaves)
                  EZ0->(dbGoTo(aChaves[i,2]))                        // posiciona na EZ0
                  ExtraiDadosXML(aChaves[i])
                  VldDadosNF(aChaves[i])
                  RecLock("EZ0",.F.)
                  EZ0->(EZ0_STIN()) // 03/01/2022 - MARCIOP - Atualiza o status apos a inclusao
                  MsUnlock()
                  // Completo os dados da C00 - 29/05/22 - Carla Barbosa
                  EZ0->(dbGoTo(aChaves[i,2])) 
                  GRAVAC00(EZ0->EZ0_CHVNFE,EZ0->EZ0_CNPJEM,EZ0->EZ0_NOEMIT,EZ0->EZ0_DTEMI,EZ0->EZ0_DTEMI,EZ0->EZ0_IEEMIT,EZ0->EZ0_VLDOC)
                  // Carla Barbosa e Marcio Martins
                  // Ajuste para Gera��o Automatica dos Documentos quando WS NFE
                  // Data 05/02/2024
                  If SuperGetMV("EZ_PX_PNAU" ,.F.,.F.) 
                     If ValidaCFOP()
                        U_AndaProcesso("A",lSchedule)  // Gero o Documento
                     Else
                        if lUsaPort
                           U_AndaProcesso("1",lSchedule) // Avanco o processo para a portaria
                        Else 
                           U_AndaProcesso("A",lSchedule) // Gero o Documento  // Move para o 
                        Endif 
                     Endif 
                  Endif
                  //
                  //--------------------------------------------------------------------
                  // Marcio Martins - 24/01/2022
                  // Projeto Fluig -> Gerar PDF e devolver ao webservice do Fluig
                  //--------------------------------------------------------------------
                  If IsInCallStack("execFuncao") //.And. !lUsaPort .And. lGerPDFluig
                     Conout("Entrou para gerar pdf")
                     dbSelectArea("EZ0")
                     EZ0->(dbSetOrder(1))
                     If EZ0->(dbSeek(xfilial("EZ0")+aChaves[i,1]))
                        U_GRC_IMPDANFE()  
                        RecLock("EZ0",.F.)
                        EZ0->EZ0_STINTE := "A"
                        MsUnlock()
                        cDirXMLRet := cLocal+aChaves[i,1]+"XML"
                        // Aqui eu trato a chamada do Webservice do Fluig
                     Endif 
                     //--------------------------------------------------------------------
                     // Fim
                     //--------------------------------------------------------------------
                  Endif
               next
            Endif
            Conout("NF-e - Gravou EZ0/EZ1 " - " - Filial: " + cFilAnt + "!")
            // Grava na Tabela EZC que baixou a NFe
            EZGravNsu(cUltNSU,"3",cChave)
         //Endif 
		Elseif AT("<procEventoNFe",cUnXML) > 0 .and. XMLTagCont('tpEvento', cUnXML) $ "110111#110112"
         // � um evento de cancelamento
         // 110111 - Evento Cancelamento
         // 110112 - Evento Cancelamento por Substitui��o
         // https://apicenter.estaleiro.serpro.gov.br/documentacao/consulta-nfe/pt/tipos_retornados/
         lRet := MemoWrite("\xmleventos\"+"nsu-"+cUltNSU+"-nfe-cancel-"+SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)+".xml",cUnXML)
         cChave    := SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)
         EZConout("EZ4 GRC","Baixando XML NF Cancelada - Chave: " + cChave + "!")
         dbSelectArea("EZ0")
         EZ0->(dbSetOrder(1))
         If EZ0->(dbSeek(xFilial("EZ0")+cChave))
            if EZ0->EZ0_ACAO == '0'  // So faz o cancelamento de NF Entrada
               if EZCancNfe(cChave,cUnXML)
                  EZConout("EZ4 GRC","o XML NF Cancelada - Chave: " + cChave + "! NF Cancelada com Sucesso")
               else
                  EZConout("EZ4 GRC","o XML NF Cancelada - Chave: " + cChave + "! NF Nao Cancelada no Sistema")
               endif
            Endif
         else
            EZConout("EZ4 GRC","o XML NF Cancelada - Chave: " + cChave + "! Nao encontrada na EZ0")
         Endif
      Endif 
    Else 
        Conout("Tratamento do Else para cDecode64")
        Conout(cDecode64)
   EndIf
  
   RestArea(aArea)
    
Return

/*
===============================================================================================
||   Funcao: 	EZCancNfe
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	20/07/2023
===============================================================================================
||	  Rotina chamada quando o XML de Cancelamento � recebido pelo Portal 
===============================================================================================
*/
Static Function EZCancNfe(cChvNFe,cXmlCanc)

Local cMsg    := ""
Local lRet    := .t.
Local lCanAut := SuperGetMV("EZ_PX_CAUT",.F.,.F.)    // Parametro para Controle Canc Automatico XML
Default lSchedule 	:= FWGetRunSchedule()
EZ0->(dbseek(xFilial("EZ0")+cChvNFe))
IF !lCanAut  // Se n�o faz o cancelamento autom�tico
   cMSG := "MOTIVO: " + CRLF
   cmSG += "        Favor efetuar o Cancelamento Manual do Documento Fiscal" + CRLF
   WFCancXML(cChvNFe,cXmlCanc,cMsg)
   RecLock("EZ0",.F.) 
   EZ0->EZ0_STINTE := "Y" // Pendente Cancelamento
   EZ0->EZ0_DTCANC := Date()
   MsUnlock()
Else
   if EZ0->EZ0_STINTE $ "1#5#7"  // Nota j� Classificada
      lRet:= ExecCanXml(cChvNFe,cXmlCanc)           
   Else  // Nota n�o foi lan�ada pelo Portal
      cMSG := "MOTIVO: " + CRLF
      cmSG += "        A Nota Fiscal foi cancelada no Portal GRC com Sucesso" + CRLF
      WFCancXML(cChvNFe,cXmlCanc,cMsg)
      RecLock("EZ0",.F.)
      EZ0->EZ0_STINTE := "Z" // Registro Cancelado no Portal GRC
      EZ0->EZ0_DTCANC := Date()
      MsUnlock()
   Endif
Endif
Return lRet

/*
===============================================================================================
||   Funcao: 	ExecCanXml
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	20/07/2023
===============================================================================================
||	  Rotina chamada quando o XML de Cancelamento � recebido pelo Portal 
===============================================================================================
*/
Static Function ExecCanXml(cChvNFe,cXmlCanc)
Local aCabec := {}, aItens := {}, aAux := {}, cCampo:=''
Local i:=0,  cMsg:=""
Local lOkNota := .F.
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.
Private _lPreNota       := SuperGetMV("EZ_PRENOTA",.F.,.T.) 
Default lSchedule 	   := FWGetRunSchedule()

lConfirmado := .T.
aCabec := {}
SF1->(dbSetOrder(1))
SF1->( dbseek( EZ0->(EZ0_FILIAL+EZ0_DOC+EZ0_SERIE+EZ0_FORNECE+EZ0_LOJA) ) )
for i:= 1 to SF1->(FCount())
   cCampo := SF1->(FieldName(i))
   If !Alltrim(cCampo) $ "F1_FILIAL"
      if !empty(SF1->&(cCampo))
         aadd(aCabec, {cCampo , SF1->&(cCampo) ,, } )
      Endif
   Endif
next
If !lSchedule
   oProcess:IncRegua2("Montagem de Itens")       // MONTA ARRAY COM CAMPOS DA SD1
Endif 
aItens := {}

dbSelectArea("SD1")
SD1->(dbSetOrder(1))
SD1->( dbseek( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) ) )
while SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
      aAux := {}
      for i := 1 To SD1->(FCount())
         cCampo := SD1->(FieldName(i))
         If !Alltrim(cCampo) $ "D1_FILIAL"
            if !empty(EZ1->&(cCampo))
               aadd(aAux, {cCampod1 , EZ1->&(cCampo) ,, } )
            Endif                        
         EndIf
      next                   
      aadd(aItens,aAux)     
      SD1->(dbSkip())
enddo 
If !lSchedule
   oProcess:IncRegua2("Verificacao de conjunto minimo preenchido")
Endif 
if lConfirmado
   Begin Transaction
   cMsg += "O conjunto minimo de campos foi preenchido"+ENTER
   If !lSchedule
      oProcess:IncRegua2("Criacao da Pre-Nota") // Cria a Pre nota
   Endif
   lMsErroAuto := .F.
   nOpcao      := "5"  // Exclus�o
   If _lPreNota
      If !lSchedule
         MsgRun("Gerando Pre-Nota","Processando",{|| MsExecAuto({|x,y,z,a|Mata140(x,y,z,a)}, aCabec, aItens, nOpcao)})
      Else                           
         MsExecAuto({|x,y,z,a|Mata140(x,y,z,a)}, aCabec, aItens, nOpcao)                           
      Endif 
   Else
      Pergunte("MTA103", .F.)
      MV_PAR01 := "2"  // Mostra contabilizacao -> 2-Nao
      MV_PAR17 := 2  // Bloqueia Mov. Usado na importacaodaniela.santos
      If !lSchedule
         MsgRun("Gerando Documento de Entrada","Processando",{|| MsExecAuto({|x,y,z,a|MATA103(x,y,z,a)}, aCabec, aItens, nOpcao)})
      Else 
         MsExecAuto({|x,y,z,a|MATA103(x,y,z,a)}, aCabec, aItens, nOpcao)
      Endif 
   Endif 
   If lMsErroAuto
      lConfirmado := .F.
      aErro := GetAutoGRLog()     
      cMsgExec := ''
      For i := 1 To Len(aErro)
         cMsgExec += aErro[i] + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
      Next i
      DisarmTransaction()
      cMSG := " " + CRLF
      cmSG += "        A Nota Fiscal Nao foi cancelada no Portal GRC conforme abaixo:" + CRLF
      cMSG += "MOTIVOS: " + "<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + Alltrim(cMsgExec)
      WFCancXML(cChvNFe,cXmlCanc,cMsg)
      RecLock("EZ0",.F.)
      EZ0->EZ0_STINTE := "Y"   // xml pendente de cancelamento 
      EZ0->EZ0_DTCANC := Date()
      MsUnlock() 
      lOkNota := .F.
   Else
      cMSG := " " + CRLF
      cmSG += "        A Nota Fiscal foi cancelada no Portal com sucesso" + CRLF
      WFCancXML(cChvNFe,cXmlCanc,cMsg)
      RecLock("EZ0",.F.)
      EZ0->EZ0_STINTE := "Z"   // xml pendente de cancelamento 
      EZ0->EZ0_DTCANC := Date()
      MsUnlock()   
      lOkNota := .T.                        
   Endif    
   End Transaction
endif
If !lConfirmado .And. !Empty(cMsg)
   If !lSchedule
      If !lOkNota
            Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao de Documento")
      Endif 
   else
         EZConout("EZ4 GRC", cMsg) 
   Endif 
Endif 
Return lOkNota


/*
===============================================================================================
||   Funcao: 	WFCancXML
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	20/07/2023
===============================================================================================
||	  Rotina chamada quando o XML de Cancelamento � recebido pelo Portal 
===============================================================================================
*/
Static Function WFCancXML(cChvNFe,cXmlCanc,cMsg)

   Local aDados    := {}
   Local aArquivos := {}
   Local cFornec   := ""
   Local cEmails   := ""
   Local cCorpo    := ""
   Local cTitulo   := ""
   Local cGrpCan   := SuperGetMv("EZ_PX_CGRP",.F.,"")  // Grupo Workflow para Cancelamento XML
   Local cLogo     := SuperGetMV("EZ_LOGOWF",.F.,"https://www.crowncork.com/sites/all/themes/crown/logo.png")

   dbSelectArea("EZ8")
   EZ8->(dbSetOrder(2))
   EZ8->(dbSeek(xFilial("EZ8")+cGrpCan ))
   While !EZ8->(Eof()) .And. xFilial("EZ8")+cGrpCan == EZ8->(EZ8_FILIAL+EZ8_CODIGO)
         cEmails += Alltrim(EZ8->EZ8_EMAIL)+";"
         EZ8->(dbSkip())
   Enddo

   if EZ0->EZ0_ACAO = "0"
      IF EZ0->EZ0_TIPONF $ "B#D"
         SA1->(dbSetOrder(1))
         SA1->(dbSeek(xFilial("SA1")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
         cFornec := EZ0->EZ0_FORNEC+"/"+EZ0->EZ0_LOJA+"-"+Alltrim(SA1->A1_NOME)
      Else
         SA2->(dbSetOrder(1))
         SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
         cFornec := EZ0->EZ0_FORNEC+"/"+EZ0->EZ0_LOJA+"-"+Alltrim(SA2->A2_NOME)
      Endif
   Endif

   cTitulo := "Comunicado - Aviso Cancelamento de NF n� " + EZ0->EZ0_NUMNFE + "-" + EZ0->EZ0_SERNFE  // Numero da nota

   aAdd(aDados, cLogo)                                                           // 1 WLogo
   aAdd(aDados, cTitulo)                                                         // 2 WComunicado
   aAdd(aDados, EZ0->EZ0_NUMNFE)                                                 // 3 WNota
   aAdd(aDados, EZ0->EZ0_CHVNFE)                                                 // 4 WChave
   aAdd(aDados, cFornec)                                                         // 5 WFornecedor
   aAdd(aDados, XMLTagCont('dhEvento', cXmlCanc))                                // 6 WData
   aAdd(aDados, cMsg)                                                            // 7 Mensagem para o usuario

   cCorpo  := U_EZMontaHtml("WFCancXML", aDados)

   U_EZEmailSend(cEmails, cTitulo, cCorpo, aArquivos, .F.)      

Return .t.

/*
===============================================================================================
||   Funcao: 	PxmlCancXML
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	20/07/2023
===============================================================================================
||	  Rotina chamada quando o XML de Cancelamento � recebido pelo Portal 
===============================================================================================
*/
User Function PxmlCancXML()

   Local cQry     :=""
   cQry:="SELECT COUNT(*) RECMARK FROM "+ RetSqlName('EZ0')+" WHERE D_E_L_E_T_ = '' AND EZ0_MARK = '"+cMark+"'  "
   AbreQuery(cQry,"QRYEZ0")
   If QRYEZ0->(RECMARK) > 1
      QRYEZ0->(DBCLOSEAREA())
      TCSQLExec("update "+ RetSqlName('EZ0')+" set EZ0_MARK = '  ' where EZ0_FILIAL = '" + xFilial("EZ0") + "' AND EZ0_MARK = '"+cMark+"' ")
      MsgAlert("N�o � possivel cancelar  mais de um registro por vez. Por favor marque apenas um XML por vez!")
      Return 
   Endif 
   QRYEZ0->(DBCLOSEAREA())
   If EZ0->EZ0_STINTE <> "Y"
      MsgAlert("O xml selecionado n�o est� pendente para cancelamento. Por favor verifique! ")
      Return
   Endif
   SF1->(DbsetOrder(1))
   if SF1->(dbseek(xFilial("SF1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNECE+EZ0_LOJA)))
       MsgAlert("O Documento de Entrada relacionado a este XML ainda n�o foi excluido. Por favor verifique! ")
      Return
   Endif  
   If MsgYesNo("Confima exclusao do Documento marcado ?")
      cMSG := "MOTIVO: " + CRLF
      cMSG += "        Recebemos o Cancelamento da NF nr"+ EZ0->EZ0_NUMNFE+"-"+EZ0->EZ0_SERIE +" "+ CRLF
      cMSG += "        Chave de Acesso: " + EZ0->EZ0_CHVNFE+" " + CRLF
      cmSG += "        A XML Foi cancelado via Portal GRC de forma manual" + CRLF
      cmSG += "        Usu�rio: "+ FwGetUserName(RetCodUsr()) 
      WFCancXML(EZ0->EZ0_CHVNFE,EZ0->EZ0_XMLNFE,cMsg)
      RecLock("EZ0",.F.)
      EZ0->EZ0_STINTE := "Z" // Registro Cancelado no Portal GRC
      EZ0->EZ0_DTCANC := Date()
      MsUnlock()
   Endif
Return


//------------------------------------------------
Static Function EZGravNsu(cNumNSU,cOpWS,cChave)

/*
Cada chave da NFe deve conter um registro com o EZC_FLGBAI = 3 
EZC_FLGBAI = 0 - consumo indevido
EZC_FLGBAI = 1 - eventos da NFe
EZC_FLGBAI = 2 - resumo da NFe
EZC_FLGBAI = 3 - xml da NFe
*/

Local cArea := GetArea()

   EZC->(dbsetorder(1))
   if EZC->(!Dbseek(xFilial("EZC")+cNUMNSU))
      Reclock("EZC",.T.)
   Else
      Reclock("EZC",.F.)
   Endif
   EZC->EZC_FILIAL := xFILIAL("EZ0")
   EZC->EZC_NSU    := cNumNSU
   EZC->EZC_CHVNFE := cChave
   EZC->EZC_DTNSU  := ddatabase
   EZC->EZC_HRNSU  := Time()
   EZC->EZC_FLGBAI := cOpWS
   EZC->(MsunLock())

RestArea(cArea)
Return

//------------------------------------------------
Static Function EZGravDNsu(cNumNSU,cOpWS,cChave)

/*
Cada chave da NFe deve conter um registro com o EZC_FLGBAI = 3 
EZC_FLGBAI = 0 - consumo indevido
EZC_FLGBAI = 1 - eventos da NFSe
EZC_FLGBAI = 2 - resumo da NFSe
EZC_FLGBAI = 3 - xml da NFSe
*/

Local cArea := GetArea()

   EZD->(dbsetorder(1))
   if EZD->(!Dbseek(xFilial("EZD")+cNUMNSU))
      Reclock("EZD",.T.)
   Else
      Reclock("EZD",.F.)
   Endif
   EZD->EZD_FILIAL := xFILIAL("EZ0")
   EZD->EZD_NSU    := cNumNSU
   EZD->EZD_CHVNFE := cChave
   EZD->EZD_DTNSU  := ddatabase
   EZD->EZD_HRNSU  := Time()
   EZD->EZD_FLGBAI := cOpWS
   EZD->(MsunLock())

RestArea(cArea)
Return


//------------------------------------------------
Static Function PTNFE138XML(cConteudo)

   Local aArea       := getArea()
   Local lRet        := .T. 
   Local nTamanho    := Len(cConteudo)
   Local cUnXML      := ""
   Local cDecode64   := Decode64(cConteudo)	
   Local cXMLDIR     := Alltrim(SuperGetMV("EZ_LOCXML",.F.,"\xmlnfe\"))
   //Local lGerPDFluig := SuperGetMV("EZ_PDFLUIG",.F.,.F.)
   Local i
   Private lUsaPort  := SuperGetMV("EZ_USAPORT",.F.,.F.)

   Default nOpcao := 1

   If !Empty(cXMLDIR)
      If !ExistDir(cXMLDIR)
         MakeDir(cXMLDIR)
      Endif
      If Left(cXMLDIR,1)<>"\"
         cXMLDIR := "\"+cXMLDIR
      Endif
      If Right(cXMLDIR,1)<>"\"
         cXMLDIR := cXMLDIR+"\"
      Endif 
   Endif 
   
   lRet := GzStrDecomp(cDecode64, nTamanho, @cUnXML)
      
   If lRet
      if AT("<infNFe",cUnXML) > 0 .OR. AT("<procNFe",cUnXML) .or. AT("<nfeProc",cUnXML)
         cChave    := SubStr(cUnXML,AT("<chNFe>",cUnXML)+Len("<chNFe>"),44)
         dbSelectArea("EZ0")
         EZ0->(dbSetOrder(1))
         If !EZ0->(dbSeek(xFilial("EZ0")+cChave))
            RecLock("EZ0",.T.)  // n�o tinha o resumo
         else
            RecLock("EZ0",.F.)  // j� tinha o resumo - carla
         Endif   
            EZ0->EZ0_FILIAL := xFilial("EZ0")
            EZ0->EZ0_CHVNFE := cChave
            EZ0->EZ0_XMLNFE := cUnXML
            EZ0->EZ0_TIPONF := "NFe"
            EZ0->EZ0_DTEMI  := xConteudo("resnfe", "dhEmi", "xCont := StoD(StrTran(SubStr( xCont,1,10),'-',''))", cUnXML, "D")  // insere o dado na tabela
            EZ0->EZ0_VLDOC  := xConteudo("resnfe", "vNF"  , "xCont := val( xCont )"                             , cUnXML, "N")  // insere o dado na tabela 
            EZ0->EZ0_IEEMIT := xConteudo("resnfe", "IE"   , "xCont := Alltrim(xCont)"                           , cUnXML, "C")  // insere o dado na tabela 

            EZ0->(EZ0_STIN()) 
            MsUnlock()
            If !Empty(cXMLDIR)
               Conout("NF-e - Salvo na pasta " + cXMLDIR)
               lRet := MemoWrite(cXMLDIR+"nfe-"+EZ0->EZ0_CHVNFE+".xml",EZ0->EZ0_XMLNFE)
            Endif 
            If  EZ0->EZ0_STINTE > '0'
               aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
               for i:=1 to Len(aChaves)
                  EZ0->(dbGoTo(aChaves[i,2]))                        // posiciona na EZ0
                  ExtraiDadosXML(aChaves[i])
                  VldDadosNF(aChaves[i])
                  RecLock("EZ0",.F.)
                  EZ0->(EZ0_STIN()) // 03/01/2022 - MARCIOP - Atualiza o status apos a inclusao
                  MsUnlock()
                  // Completo os dados da C00 - 29/05/22 - Carla Barbosa
                  EZ0->(dbGoTo(aChaves[i,2])) 
                  GRAVAC00(EZ0->EZ0_CHVNFE,EZ0->EZ0_CNPJEM,EZ0->EZ0_NOEMIT,EZ0->EZ0_DTEMI,EZ0->EZ0_DTEMI,EZ0->EZ0_IEEMIT,EZ0->EZ0_VLDOC)
                  //
                  //--------------------------------------------------------------------
                  // Marcio Martins - 24/01/2022
                  // Projeto Fluig -> Gerar PDF e devolver ao webservice do Fluig
                  //--------------------------------------------------------------------
                  If IsInCallStack("execFuncao") //.And. !lUsaPort .And. lGerPDFluig
                     Conout("Entrou para gerar pdf")
                     dbSelectArea("EZ0")
                     EZ0->(dbSetOrder(1))
                     If EZ0->(dbSeek(xfilial("EZ0")+aChaves[i,1]))
                        U_GRC_IMPDANFE()  
                        RecLock("EZ0",.F.)
                        EZ0->EZ0_STINTE := "A"
                        MsUnlock()
                        cDirXMLRet := cLocal+aChaves[i,1]+"XML"
                        // Aqui eu trato a chamada do Webservice do Fluig
                     Endif 
                     //--------------------------------------------------------------------
                     // Fim
                     //--------------------------------------------------------------------
                  Endif
               next
            Endif
            Conout("NF-e - Gravou EZ0/EZ1 !")
         //Endif 
		Endif 
   EndIf
  
   RestArea(aArea)
    
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaC00()
Realiza a Grava��o da Tabela C00 .
@type function
@author Carla Barbosa
@since 27/05/2022
@version 1.00

/*/
//-----------------------------------------------------------------------   
Static Function GRAVAC00(cCHAVE,cCNPJ,cRAZAO,dDTEMI,dDTREC,cIEEMIT,nValDoc)
Local lOk			:= .F.

C00->(DbsetOrder(1))
If C00->( DbSeek( xFilial("C00") + cChave) )
   Reclock("C00",.F.)
   C00->C00_CODRET		:= '138'
   C00->C00_DESRES		:= 'Documento(s) localizado(s)'
	C00->C00_CNPJEM		:= cCNPJ
   C00->C00_IEEMIT      := cIEEMIT
   C00->C00_NOEMIT      := cRAZAO
	C00->C00_DTEMI  	   := dDtEmi
	C00->C00_DTREC		   := dDTREC
	C00->C00_VLDOC		   := nValDoc
   C00->(MsUnLock()) 
	lOk := .T.
EndIf	
return (lOk)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCodUf
//Retorna o Codigo de Municipio
@author Marcio Martins Pereira
@since 18/08/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
Static Function RetCodUf()
         
	Local cRet	   := ""
	Local aEstados := {}
	
	aAdd(aEstados, {'RO','11','Rondonia'})
	aAdd(aEstados, {'AC','12','Acre'})
	aAdd(aEstados, {'AM','13','Amazonas'})
	aAdd(aEstados, {'RR','14','Roraima'})
	aAdd(aEstados, {'PA','15','Para'})
	aAdd(aEstados, {'AM','16','Amapa'})
	aAdd(aEstados, {'TO','17','Tocantins'})
	aAdd(aEstados, {'MA','21','Maranhao'})
	aAdd(aEstados, {'PI','22','Piaui'})
	aAdd(aEstados, {'CE','23','Ceara'})
	aAdd(aEstados, {'RN','24','Rio Grande do Norte'})
	aAdd(aEstados, {'PB','25','Paraiba'})
	aAdd(aEstados, {'PE','26','Pernambuco'})
	aAdd(aEstados, {'AL','27','Alagoas'})
	aAdd(aEstados, {'SE','28','Sergipe'})
	aAdd(aEstados, {'BA','29','Bahia'})
	aAdd(aEstados, {'MG','31','Minas Gerais'})
	aAdd(aEstados, {'ES','32','Espirito Santo'})
	aAdd(aEstados, {'RJ','33','Rio de Janeiro'})
	aAdd(aEstados, {'SP','35','Sao Paulo'})
	aAdd(aEstados, {'PR','41','Parana'})
	aAdd(aEstados, {'SC','42','Santa Catarina'})
	aAdd(aEstados, {'RS','43','Rio Grande do Sul'})
	aAdd(aEstados, {'MS','50','Mato Grosso do Sul'})
	aAdd(aEstados, {'MT','51','Mato Grosso'})
	aAdd(aEstados, {'GO','52','Goias'})
	aAdd(aEstados, {'DF','53','Distrito Federal'})
	
	nPos := Ascan( aEstados, {|x| Alltrim(x[1])  == SM0->M0_ESTCOB } )
	If nPos > 0 
		cRet := aEstados[nPos,2]
	Endif
	
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EZ1TESDIFAL
//Utilizado para zerar os campos de Aliquota e Valor do no calculo do DIFAL quando no XML 
  a TAG <pCredSN> estiver preenchida
@author Marcio Martins Pereira
@since 18/08/2019
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
User function EZ1TESDIFAL(cConteudo)

   Local aAreaSF4     := SF4->(GetArea())

   Default cConteudo := ''
 
   If Empty(cConteudo)
      cTES := &(ReadVar())
   Else 
      cTES := cConteudo
   Endif 
          
   If IsInCallStack("MULTLINHAS")
      EZ0->(dbSetOrder(1))
      EZ0->(dbSeek(CChvMultiL))
      nPsTES := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_TES") } )
      cTes   := oGetd:aCols[oGetd:nAT,nPsTES]      
   Endif 

   dbSelectArea("SF4")
   SF4->(dbSetOrder(1))
   If !SF4->(dbSeek(xFilial("SF4")+cTES))
      MsgAlert("A TES " + cTES + " digitada nao encontrada!"+CRLF+"Verifique!")
   Else
      oModel := FwModelActive()
      //oModel:SetValue("EZ1MASTER","EZ1_PICM",npICMS)     // Carrego a Aliquota Normal
      //oModel:SetValue("EZ1MASTER","EZ1_VALICM",nvICMS)   // Carrego o Valor para a Aliquota Normal
      If SF4->F4_CREDICM == "S" .And. !empty(EZ1->EZ1_PICMRE)
            oModel:SetValue("EZ1MASTER","EZ1_PICM",EZ1->EZ1_PICMRE)         // Carrego a Aliquota Reduzida caso tenha
            oModel:SetValue("EZ1MASTER","EZ1_VALICM",EZ1->EZ1_VICMRE)   // Carrego o Valor para a Aliquota Reduzida caso tenha
         Else
      Endif 
   Endif 

   RestArea(aAreaSF4)

Return cTES

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EZ1TESGAT
Gatilho para disparo da CFOP conforme MV_ESTADO e A1_EST/A2_EST
@author Marcio Martins Pereira
@since 13/08/2020
@version 1.00
@type function
/*/
//------------------------------------------------------------------------------------------
User Function EZ1TESGAT(cConteudo)

   Local cRetCF := ''
   Local cEst   := ''
   Local cTES   := ''
   Local cMVEST := GetMV("MV_ESTADO")
   
   If IsInCallStack("MULTLINHAS")
      CChvMultiL   := CChvGrava
   Else 
      CChvMultiL := EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
   Endif 

   Default cConteudo := ''

   EZ0->(dbSetOrder(1))
   EZ0->(dbSeek(CChvMultiL))

   If Empty(cConteudo)
      cTES := &(ReadVar())
   Else 
      cTES := cConteudo
   Endif 
  

   If IsInCallStack("MULTLINHAS")
      //EZ0->(dbSetOrder(1))
      //EZ0->(dbSeek(CChvMultiL))
      nPsTES := AScan( aHdEZ1, {|x| Alltrim(x[2]) = Alltrim("EZ1_TES") } )
      cTes   := oGetd:aCols[oGetd:nAT,nPsTES]      
   Endif 

   dbSelectArea("SF4")
   SF4->(dbSetOrder(1))
   If !SF4->(dbSeek(xFilial("SF4")+cTES))
      MsgAlert("A TES " + cTES + " digitada nao encontrada!"+CRLF+"Verifique!")
   Else 

      If Alltrim(SF4->F4_CF) == "999"
         cRetCF := SF4->F4_CF
      Else 
         If EZ0->EZ0_ACAO == "0"
            If cTES > "500"
               MsgAlert("A TES " + cTES + " digitada eh Invalida para Operacao de Entrada!"+CRLF+"Verifique")
            Else
               IF EZ0->EZ0_TIPO $ "D|B"   
                  dbSelectArea("SA1")
                  SA1->(dbSetOrder(1))
                  If SA1->(dbSeek(xFilial("SA1")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
                     cEst := SA1->A1_EST
                  Endif 
                  If !Empty(cEst)
                     If cEst == "EX"
                        cRetCF := "3"+SubStr(SF4->F4_CF,2,4)
                     ElseIf cEst == cMVEST
                        cRetCF := "1"+SubStr(SF4->F4_CF,2,4)
                     ElseIf cEst <> cMVEST
                        cRetCF := "2"+SubStr(SF4->F4_CF,2,4)
                     Endif 
                  Endif
               Else 
                  dbSelectArea("SA2")
                  SA2->(dbSetOrder(1))
                  If SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
                     cEst := SA2->A2_EST
                  Endif 
                  If !Empty(cEst)
                     If cEst == "EX"
                        cRetCF := "3"+SubStr(SF4->F4_CF,2,4)
                     ElseIf cEst == cMVEST
                        cRetCF := "1"+SubStr(SF4->F4_CF,2,4)
                     ElseIf cEst <> cMVEST
                        cRetCF := "2"+SubStr(SF4->F4_CF,2,4)
                     Endif 
                  Endif 
               Endif
            Endif        
         Else
            If cTES < "501"
               MsgAlert("A TES " + cTES + " digitada eh Invalida para Operacao de Saida!"+CRLF+"Verifique")
            Else                 
               dbSelectArea("SA1")
               SA1->(dbSetOrder(1))
               If SA1->(dbSeek(xFilial("SA1")+EZ0->(EZ0_CLIENT+EZ0_LOJACL)))
                  cEst := SA1->A1_EST
               Endif 
               If !Empty(cEst)
                  If cEst == "EX"
                     cRetCF := "5"+SubStr(SF4->F4_CF,2,4)
                  ElseIf cEst == cMVEST
                     cRetCF := SF4->F4_CF
                  ElseIf cEst <> cMVEST
                     cRetCF := "6"+SubStr(SF4->F4_CF,2,4)
                  Endif 
               Endif      
            Endif            
         Endif 
      Endif 

   Endif 

Return cRetCF

/*
===============================================================================================
||   Funcao: 	GERCTE
===============================================================================================
||		Rotina que realiza a geracao do documento de saida (MATA920)   
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	31/08/2020
===============================================================================================
*/
Static Function GERCTE(aChaves,oProcess,lEnd)

   Local lGerMT960  := .T. // para gerar o Mata960
   Local aDSF2      := {}
   Local aCabec     := {}
   Local aItens     := {}
   Local aLinha     := {}
   Local aAreaSF3   := {}
   Local lGDifal	  := Iif(ValType(MV_PAR24)<>"N",.F.,(mv_par24==1))
   Local lGFcpDif	  := Iif(ValType(MV_PAR25)<>"N",.F.,(mv_par25==1))
   Local cLcPadTit  := ""
   Local lLancCont  := .F.
   Local lConfTit   := .F.
   Local aGNRE      := {}
   Local aRecTit    := {}
   Local aDatas     := {}
   Local nVFCDif	  := 0
   Local nThreads   := SuperGetMv("MV_TMSTHRC", , 0) // Numero de threads para processamento simultaneos
   Local nJ         := 0 
   Local cMsg       := ""
   Local nI         := 0 
   Local lTemDifal  := .F.
   Local cUfOrig    := ""

   Private lMsErroAuto := .F.
   Private lAutoErrNoFile := .T.
   Private cNumero     := ""

   oProcess:SetRegua1(Len(aChaves))

   For nJ:=1 to Len(aChaves)

      if lEnd
         cMsg += 'Processo interrompido por usuario'  + ENTER
         Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao Doc. de Saida")
         Return
      Endif

      lTemDifal := .F.
      
      lConfirmado := .T.

      EZ0->(dbGoTo(aChaves[nJ,2])) // posiciona na EZ0

      lTemDifal := EZ0->(EZ0_FCPFIM+EZ0_ICMFIM) > 0 

      oProcess:IncRegua1("Gerando Documento de Saida - CT-e: "+ EZ0->EZ0_NUMNFE+'-' + EZ0->EZ0_SERNFE)
      cMsg += ENTER + '----------------------------------' + ENTER + ENTER
      cMsg += "CT-e Chave n.: " + EZ0->EZ0_CHVNFE + ENTER
      
      dbSelectArea("SA1")
      SA1->(dbSetOrder(1))    // A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                        
      SA1->(dbSeek(xFilial("SA1")+EZ0->(EZ0_TOCLIE+EZ0_TOLOJA)))

      dbSelectArea("SF2")
      SF2->(dbSetOrder(2))    // F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE+F2_TIPO+F2_ESPECIE
      If SF2->(dbSeek(xFilial("SF2")+SA1->(A1_COD+A1_LOJA)+EZ0->(EZ0_NUMNFE+EZ0_SERNFE)+"NCTE"))
         cMsg += "Doc.Saida - CT-e ji gerado anteriormente: " + EZ0->EZ0_NUMNFE+'-' + EZ0->EZ0_SERNFE
         lConfirmado := .F.
         RecLock("EZ0",.F.)
         EZ0->EZ0_STINTE := '1'
         MsUnlock()
      Endif  

      If lConfirmado

         oProcess:SetRegua2(10)
         oProcess:IncRegua2("Verificando validacoes")

         EZ2->(dbCloseArea())
         If Select("EZ2") > 0
               dbSelectArea("EZ2")
         Endif

         EZ2->(dbSetOrder(1))
         EZ2->( dbseek( EZ0->(EZ0_FILIAL+EZ0_CHVNFE) ) )
         while EZ2->(EZ2_FILIAL+EZ2_CHVNFE) == EZ0->(EZ0_FILIAL+EZ0_CHVNFE)
               if EZ2->EZ2_STATUS = '2'             // "1=Aviso;2=Erro;0=ok"
               lConfirmado := .F.                // so executa o ExecAuto se Nao houver nenhuma restricao
               Endif
               EZ2->(dbSkip())
         Enddo

         If lConfirmado

               SF2->(dbSetOrder(1))

               aadd( aCabec , { "F2_TIPO"      , "N"                     })
               aadd( aCabec , { "F2_FORMUL"    , "N"                     })
               aadd( aCabec , { "F2_DOC"       , EZ0->EZ0_NUMNFE         })
               aadd( aCabec , { "F2_SERIE"     , EZ0->EZ0_SERNFE         })
               aadd( aCabec , { "F2_EMISSAO"   , EZ0->EZ0_EMISSA         })
               aadd( aCabec , { "F2_CLIENTE"   , SA1->A1_COD             })
               aadd( aCabec , { "F2_LOJA"      , SA1->A1_LOJA            })
               aadd( aCabec , { "F2_ESPECIE"   , "CTE"                   })
               aadd( aCabec , { "F2_COND"      , "001"                   })
               aadd( aCabec , { "F2_DESCONT"   , 0                       })
               aadd( aCabec , { "F2_FRETE"     , 0                       })
               aadd( aCabec , { "F2_SEGURO"    , 0                       })
               aadd( aCabec , { "F2_DESPESA"   , 0                       })
               aadd( aCabec , { "F2_CHVNFE"    , EZ0->EZ0_CHVNFE         })
               aadd( aCabec , { "F2_UFINI"	  , EZ0->EZ0_UFORIT         }) // Estado inicio da prestaca do servico
               aadd( aCabec , { "F2_UFFIM"	  , EZ0->EZ0_UFDEST         }) // Estado fim da prestacao do servico
               aadd( aCabec , { "F2_UFDEST"	  , EZ0->EZ0_UFDEST         }) 
               aadd( aCabec , { "F2_FIMP"      , "S"                     })
               aadd( aCabec , { "F2_HORA"      ,"12:00"                  })
               aadd( aCabec , { "F2_CLIENT"	  , EZ0->EZ0_CLIENT         })	//--Cliente Destinatario
               aadd( aCabec , { "F2_LOJENT"	  , EZ0->EZ0_LOJACL         })	//--Loja Destinatario

               aLinha := {}
               aadd( aLinha , { "D2_ITEM"      , "01"                  , Nil   })
               aadd( aLinha , { "D2_COD"       , EZ1->EZ1_COD          , Nil   })
               aadd( aLinha , { "D2_QUANT"     , EZ1->EZ1_QUANT        , Nil   })
               aadd( aLinha , { "D2_PRCVEN"    , EZ1->EZ1_VUNIT        , Nil   })
               aadd( aLinha , { "D2_TOTAL"     , EZ1->EZ1_VUNIT        , Nil   })
               aadd( aLinha , { "D2_TES"       , EZ1->EZ1_TES          , Nil   })
               aadd( aLinha , { "D2_CF"        , EZ1->EZ1_CF           , Nil   })
               aadd( aLinha , { "D2_PICM"      , EZ1->EZ1_PICM         , Nil   })

               aadd( aItens , aLinha)


               If lTemDifal
                  cUfOrig := SA1->A1_EST
                  RecLock("SA1",.F.)
                  SA1->A1_EST := EZ0->EZ0_UFDEST
                  MsUnlock()
               Endif 
                              
               Begin Transaction   

                  lMsErroAuto := .F.

                  MATA920(aCabec,aItens)

                  If lMsErroAuto
                     DisarmTransaction()
                     cMsg += "Pedido Nao Gerado!" + ENTER
                     aErro := GetAutoGRLog()
                     For nI := 1 To Len(aErro)
                           cMsg += aErro[nI] + Chr(13) + Chr(10)
                     Next nI                        
                  Else

                     aAreaSF3 := SF3->(GetArea())

                     DbSelectArea("SF3")
                     SF3->(dbSetOrder(4))  // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
                     SF3->(dbSeek(xFilial("SF3")+SA1->(A1_COD+A1_LOJA)+EZ0->(EZ0_NUMNFE+EZ0_SERNFE)))

                     If !SF3->(Eof())
                           RecLock("SF3",.F.)
                           SF3->F3_CODRSEF  := EZ0->EZ0_CODSEF
                           SF3->F3_PROTOC   := EZ0->EZ0_PROTOC
                           SF3->F3_CODRET   := "T"
                           SF3->F3_DESCRET  := EZ0->EZ0_DESCRE
                           SF3->(MsUnlock())
                     EndIf

                     fGerDT6()

                     // Fazer a tratativa para o Difal\Suframa
                     If  (EZ0->EZ0_UFDEST $ GetMv('MV_SUBTRIB' )       .Or. ;
                           F0L->(dbSeek(xFilial('F0L')+EZ0->EZ0_UFDEST)) .Or. ;
                           CLO->(dbSeek(xFilial('CLO')+EZ0->EZ0_UFDEST)))
                           lGerMT960 := .F.
                     EndIf
                     
                     SF2->(dbSetOrder(2))
                     SF2->(dbSeek(xFilial("SF2")+SA1->(A1_COD+A1_LOJA)+EZ0->(EZ0_NUMNFE+EZ0_SERNFE)+"NCTE"))

                     If lGerMT960 .And. lTemDifal
                           lGDifal   := lGFcpDif := lGerMT960
                           nVlrdifal := EZ0->EZ0_ICMFIM
                           nDifFecp  := EZ0->EZ0_FCPFIM
                           nMes      := Month(SF2->F2_EMISSAO)
                           nAno      := Year(SF2->F2_EMISSAO)
                           aDatas    := DetDatas(nMes,nAno,3,1)    // nMes, nAno, nApuracao, nPeriodo
                           dDtIni	  := aDatas[1]
                           dDtFim	  := aDatas[2]
                           dDtVenc   := DataValida(aDatas[2]+1,.t.)
                           lLancCont := .F. //Iif(ValType(MV_PAR04)<>"N",.F.,(mv_par04==1)) Contb.Custo On-Line    ?  Sim/Nao
                           lGeraTit  := .f.
                           aadd(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_ESPECIE})
                           If SF2->F2_EST $ GetNewPar("MV_SOMAGNR","")
                              GravaTit(lGeraTit,nVlrdifal+nDifFecp,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGDifal,nMes,nAno,0,nVlrdifal+nDifFecp,"MATA460A",;
                                 lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,.T.,.T.,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,.T.,,,,.T.,,,(nThreads > 0))
                           Else
                              GravaTit(lGeraTit,nVlrdifal,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGDifal,nMes,nAno,0,nVlrdifal,"MATA460A",;
                                 lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,,.T.,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,.T.,,,,.T.,,,(nThreads > 0))
                              If  nVFCDif	 > 0 .And. lGFcpDif
                                 GravaTit(lGeraTit,nDifFecp,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGFcpDif,nMes,nAno,0,nDifFecp,"MATA460A",;
                                       lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,.T.,.T.,,@aRecTit,@lConfTit,0,aDSF2,,,,,,,,,,.T.,,,,.T.,,,(nThreads > 0))
                              EndIf
                           EndIf
                     EndIf

                     RecLock("EZ0",.F.)
                     EZ0->EZ0_STINTE := '1'
                     MsUnlock()
                     RestArea(aAreaSF3)

                     cMsg += "Doc.Saida Ct-e Gerado com sucesso!"+ENTER

                  Endif 

               End Transaction

               If lTemDifal
                  RecLock("SA1",.F.)
                  SA1->A1_EST := cUfOrig
                  MsUnlock()
               Endif 

         Else
               cMsg += "Existem restricoes de validacao. "+ENTER
               cMsg += "Doc.Saida Nao foi gerada. "+ENTER
         Endif 

      Endif 

   Next nJ

   Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Criacao CT-e's Saida")
    
Return 

/*
===============================================================================================
||   Funcao: 	fGerDT6
===============================================================================================
||		Rotina para a Geracao do Registro na tabela DT6                                                                                        
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	01/09/2020
===============================================================================================
*/
Static Function fGerDT6()

	Local aArea    := GetArea()
	Local aAreaDT6 := DT6->(GetArea())

    dbSelectArea("DT6")
	DT6->(dbSetOrder(1)) // DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
	If !DT6->(dbSeek(xFilial('DT6')+xFilial('DT6')+SF2->(F2_DOC+F2_SERIE)))

		Reclock("DT6",.T.)
		DT6->DT6_FILIAL := xFilial('DT6')
		DT6->DT6_FILDOC := xFilial('DT6')
		DT6->DT6_DOC    := EZ0->EZ0_NUMNFE
		DT6->DT6_SERIE  := EZ0->EZ0_SERNFE
		DT6->DT6_DATEMI := EZ0->EZ0_EMISSA
        DT6->DT6_VOLORI := EZ0->EZ0_VOLORI
        DT6->DT6_QTDVOL := EZ0->EZ0_VOLORI
		DT6->DT6_TIPFRE := "2"
		DT6->DT6_DOCTMS	:= "2"
        DT6->DT6_CLIREM := EZ0->EZ0_RECLIE
		DT6->DT6_LOJREM := EZ0->EZ0_RELOJA
		DT6->DT6_CLIDES := EZ0->EZ0_CLIENT 
		DT6->DT6_LOJDES := EZ0->EZ0_LOJACL
        DT6->DT6_CHVCTE := EZ0->EZ0_CHVNFE
		DT6->(MSUNLOCK())
	EndIf

	RestArea(aAreaDT6)
	RestArea(aArea)

Return

/*/
============================================================================================================================
// Determina datas inicial e final da apuracao 
============================================================================================================================
*/
Static Function DetDatas(nMes,nAno,nApuracao,nPeriodo)

	LOCAL aDatas :=	Array(2)

	Do Case
	Case nApuracao==1
		Do Case
		Case nPeriodo==1
			aDatas[1]:=Ctod('01/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
			aDatas[2]:=aDatas[1]+9
		Case nPeriodo==2
			aDatas[1]:=Ctod('11/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
			aDatas[2]:=aDatas[1]+9
		Case nPeriodo==3
			aDatas[1]:=Ctod('21/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
			aDatas[2]:=UltimoDia(aDatas[1])
		Case nPeriodo==4
			aDatas[1]:=Ctod('01/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
			aDatas[2]:=Ctod('20/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
		EndCase
	Case nApuracao==2
		If nPeriodo==1
			aDatas[1]:=Ctod('01/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
			aDatas[2]:=aDatas[1]+14
		Else
			aDatas[1]:=Ctod('16/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
			aDatas[2]:=UltimoDia(aDatas[1])
		Endif
	Case nApuracao==3
		aDatas[1]:=Ctod('01/'+StrZero(nMes,2)+'/'+Substr(StrZero(nAno,4),3,2) )
		aDatas[2]:=UltimoDia(aDatas[1])
	Case nApuracao==4
		aDatas[1]:=Ctod("01/"+If(nPeriodo==1,"01/","07/")+Substr(StrZero(nAno,4),3,2))
		aDatas[2]:=Ctod(If(nPeriodo==1,"30/06/","31/12/")+Substr(StrZero(nAno,4),3,2))
	Case nApuracao==5
		aDatas[1]:=Ctod("01/01/"+Substr(StrZero(nAno,4),3,2))
		aDatas[2]:=Ctod("31/12/"+Substr(StrZero(nAno,4),3,2))
	EndCase

Return (aDatas)


/*
===============================================================================================
||   Funcao: 	PROCNFEZ4
===============================================================================================
||		Rotina para realizar faturamento automatico
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	08/07/2020
===============================================================================================
*/
User Function PROCNFEZ4(cMsg)

	Default cMsg := ""

	If !IsInCallStack("U_PORTAL_XML")
		If !Empty(SC5->C5_NOTA)
			MsgAlert("Esse pedido ja tem nota gerada!")
			Return 
		Endif 
		If Empty(SC5->C5_XNFSXML)	// Retorno pois nao havendo numero de nota nao tem porque continuar
			MsgAlert("Esse pedido nao foi gerado por importacao de NF-e/NFS-e")
			Return 
		Endif 
	Endif 
	
	MsgRun("Aguarde gerando nota","Processando",{|| cMsg := NFSProcess(cMsg)  })

Return cMsg

/*
===============================================================================================
||   Funcao: 	NFSProcess
===============================================================================================
||		Processa a geracao do documento de saida
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	08/07/2020
===============================================================================================
*/
Static Function NFSProcess(cMsg,lCriaPed)

	Local aArea		 	:= GetArea()
	Local cSQL			:= ''
	Local cNumPed		:= SC5->C5_NUM
	Local cSerie 		:= Alltrim(SC5->C5_XSERXML)
	Local aPvlNfs 	 	:= {}
   Local lAvest      := IIF(GETMV("MV_ESTNEG")="S",.F.,.T.)
	Local lCredito 	:= .T.
	Local lEstoque 	:= .T.	//.t.
	Local lLiber   	:= .T.
	Local lTransf  	:= .T.	
   Local lErroLib    := .F.
	Local nMV_PAR17B	:= 0
	Local nMV_PAR24B	:= 0
   Local nMV_PAR25B	:= 0
	Local cAliasTRB   := GetNextAlias()
   Local lDtLibPV    := GetNewPar("EZ_DTLIBPV",.T.)

	Private oRetNF
	Private nTipo		:= 2
	Private cNota		:= ""
	Private nConsNeg 	:= 0.4 // Constante para concertar o clculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex 	:= 0.5 // Constante para concertar o clculo retornado pelo GetTextWidth.
	Private PixelX 		:= Nil
	Private PixelY 		:= Nil

   Default lCriaPed := .F.

   dbSelectArea("EZ0")
   EZ0->(dbSetOrder(1))
   EZ0->(dbSeek(xFilial("EZ0")+SC5->C5_XCHVNFE))

   SC5->C5_XNFSXML := StrZero(Val(EZ0->EZ0_DOC),9)
   SC5->C5_XSERXML := EZ0->EZ0_SERIE

   dbSelectArea("SF2")
   SF2->(dbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
   If SF2->(dbSeek(xFilial("SF2")+EZ0->EZ0_DOC+EZ0->EZ0_SERIE))
      cMsg := "Nota Fiscal n. " + EZ0->EZ0_DOC + " - Serie " + EZ0->EZ0_SERIE + ", ja existe!"
      Return cMsg
   Endif 

   // Troco a data base para quea liberacao tenha a mesma data -> influencia no estoque
   IF lDtLibPV
      xdatabase := ddatabase
      ddatabase := SC5->C5_EMISSAO	// Necessario para gerar os titulos respeitando o vencimento original
   Else
      // Se o pedido j� est� criado na base, uso a data do xml
      xdatabase := ddatabase
      ddatabase := EZ0->EZ0_DTEMI	// Necessario para gerar os titulos respeitando o vencimento original
   Endif
	//=========================================================================
	// Cria a serie RPS caso nao exista
	//=========================================================================
	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))	// X5_FILIAL+X5_TABELA+X5_CHAVE
	If !SX5->(dbSeek(xFilial("SX5")+"01"+Padr(cSerie,TamSX3("X5_CHAVE")[1])))
		RecLock("SX5",.T.)
		SX5->X5_FILIAL	:= xFilial("SX5")
		SX5->X5_TABELA	:= "01"		// SERIES DE N. FISCAIS                                   
		SX5->X5_CHAVE	:= cSerie	// RPS - Serie utilziada na importacao de NFS-e Referente as Saidas
		SX5->X5_DESCRI	:= "SERIE_UTILIZADA_NA_IMPORTACAO_DE_NF_PARA_SAIDAS"
		SX5->X5_DESCSPA	:= "SERIE_UTILIZADA_NA_IMPORTACAO_DE_NF_PARA_SAIDAS"
		SX5->X5_DESCENG	:= "SERIE_UTILIZADA_NA_IMPORTACAO_DE_NF_PARA_SAIDAS"
		MsUnlock()
	Endif 
	//=========================================================================

	DbSelectArea("SC5")
	DbSelectArea("SC6")
	DbSelectArea("SE4")
	DbSelectArea("SB1")
	DbSelectArea("SB2")            
	DbSelectArea("SF4")
	DbSelectArea("SC9")
 /// 21/09/2022 - Carla Barbosa - Adicionado condi��o para Filtrar EZ0_ACAO = 1 - Situa��es em que tenho o mesmo EZ0_NUM na entrada
 /*
	cSQL := " SELECT EZ0_NUM as C6_NUM, EZ1_COD as C6_PRODUTO, C6_ITEM, EZ1_QUANT as C6_QTDVEN, EZ1_VUNIT as C6_PRCVEN, C6_TES, C6_LOCAL " + CRLF
	cSQL += " FROM "+RetSqlName("EZ0")+"  EZ0 " + CRLF
	cSQL += " INNER JOIN "+RetSqlName("EZ1")+" EZ1 ON EZ1_CHVNFE = EZ0_CHVNFE " + CRLF
	cSQL += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = EZ0_FILIAL AND C6_NUM = EZ0_NUM AND EZ1_COD = C6_PRODUTO AND C6_ITEM = '01' " + CRLF
	cSQL += " WHERE EZ0_NUM = '"+AllTrim(cNumPed)+"' AND EZ0_ACAO =  '1' AND EZ0_FILIAL = '"+xFilial("EZ0")+"' " + CRLF
	cSQL += " AND EZ0.D_E_L_E_T_ = ' ' AND EZ1.D_E_L_E_T_ = ' ' AND SC6.D_E_L_E_T_ = ' '  " + CRLF
   */
	cSQL := " SELECT C6_NUM, EZ1_COD as C6_PRODUTO, C6_ITEM, EZ1_QUANT as C6_QTDVEN, EZ1_VUNIT as C6_PRCVEN, C6_TES, C6_LOCAL  " + CRLF
	cSQL += " FROM "+RetSqlName("EZ1")+"  EZ1 " + CRLF
	cSQL += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.C5_XCHVNFE = EZ1.EZ1_CHVNFE " + CRLF
	cSQL += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND EZ1_COD = C6_PRODUTO AND C6_ITEM = RIGHT(EZ1_ITEM,2)    " + CRLF
	cSQL += " WHERE EZ1_CHVNFE = '"+EZ0->EZ0_CHVNFE+"'  AND EZ1_FILIAL ='"+xFILIAL("EZ1")+"' " + CRLF
	cSQL += " AND EZ1.D_E_L_E_T_ = ' ' AND SC6.D_E_L_E_T_ = ' '  AND  SC5.D_E_L_E_T_ = ' ' " + CRLF
	DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .T., .T.)
	
	Count to nQuantidade

	(cAliasTRB)->(DbGoTop())

	While (cAliasTRB)->(!EOF())

      // MARCIO MARTINS - 06/10/2022
      If !SuperGetMV("EZ_PX_PVAU" ,.F.,.F.) .Or. lCriaPed .or.  !SuperGetMV("EZ_PX_PLIB" ,.F.,.F.)
         SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
         SC6->(MsSeek(xFilial("SC6")+(cAliasTRB)->(C6_NUM+C6_ITEM+C6_PRODUTO)))

         SE4->(DbSetOrder(1))
         SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )

         SB1->(DbSetOrder(1))
         SB1->(MsSeek(xFilial("SB1")+(cAliasTRB)->C6_PRODUTO))

         SB2->(DbSetOrder(1))
         SB2->(MsSeek(xFilial("SB2")+(cAliasTRB)->(C6_PRODUTO+C6_LOCAL)))

         SF4->(DbSetOrder(1))
         SF4->(MsSeek(xFilial("SF4")+(cAliasTRB)->C6_TES))

         //---------------------------------------------------------------------------------------
         // Trata a liberao dos itens do pedido
         //---------------------------------------------------------------------------------------
         nQuantLib 	:= (cAliasTRB)->C6_QTDVEN // est� apelidado, olhar na query
         SC9->(DBSetOrder(1))
         If !SC9->(MsSeek(xFilial("SC9")+(cAliasTRB)->C6_NUM+(cAliasTRB)->C6_ITEM))
            nQuantLib := MaLibDoFat(SC6->(Recno()), nQuantLib, @lCredito, @lEstoque, .F., lAvest, lLiber, lTransf)
         Else
            lEncontrou := .F.
            While !SC9->(Eof()) .And. xFilial("SC9")+(cAliasTRB)->(C6_NUM+C6_ITEM) == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM)
               If Empty(SC9->C9_NFISCAL)
                  lEncontrou := .T.
                  SC9->(a460Estorna(.T.))
                  nQuantLib := MaLibDoFat(SC6->(Recno()), nQuantLib, @lCredito, @lEstoque, .F., lAvest, lLiber, lTransf)
               Endif 
               SC9->(dbSkip())
            Enddo
            If !lEncontrou
               nQuantLib := MaLibDoFat(SC6->(Recno()), nQuantLib, @lCredito, @lEstoque, .F., lAvest, lLiber, lTransf)
            Endif 
         EndIf

         If !lCredito .Or. !lEstoque
            lErroLib := .T.
         Endif 
      Endif 

		SC9->(dbSetOrder(1))
		If SC9->(MsSeek(xFilial("SC9")+(cAliasTRB)->(C6_NUM+C6_ITEM)))
         While !SC9->(Eof()) .And. xFilial("SC9")+(cAliasTRB)->(C6_NUM+C6_ITEM) == SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM)
            If Empty(SC9->C9_NFISCAL)
               AAdd( aPvlNfs,{	SC9->C9_PEDIDO		,;	// Nmero do Pedido
                           SC9->C9_ITEM 		,;	// Item do Pedido
                           SC9->C9_SEQUEN  	,;	// Sequencia
                           SC9->C9_QTDLIB  	,;	// Quantidade 
                           SC9->C9_PRCVEN  	,;	// Preo de Venda
                           SC9->C9_PRODUTO 	,;	// Cdigo do Produto
                           .F.             	,;
                           SC9->(RecNo())  	,;
                           SC5->(RecNo()) 		,;
                           SC6->(RecNo())  	,;
                           SE4->(RecNo())  	,;
                           SB1->(RecNo())  	,;
                           SB2->(RecNo())  	,;
                           SF4->(RecNo())  	,;
                           SC9->C9_LOCAL		,;
                           0					,;
                           SC9->C9_QTDLIB		,;	// Quantidade Liberada
                           SF4->F4_DUPLIC=="S"	})
            Endif 
            sc9->(dbSkip())
         Enddo
		EndIf

		(cAliasTRB)->(DbSkip())

	Enddo  
	
	(cAliasTRB)->(dbCloseArea())

   If !lErroLib

      If Len(aPvlNfs) > 0

         // Ajuste para gerao da GNRE (SF6)
         Pergunte("MT460A", .F.)
         nMV_PAR17B := MV_PAR17
         nMV_PAR24B := MV_PAR24         
         MV_PAR17   := 1			
         MV_PAR24   := 1
         If EZ0->EZ0_TIPONF == "CTe"
            nMV_PAR25B := MV_PAR25
            MV_PAR25   := 1
         Endif 

         //---------------------------------------------------------------------------------------
         //Realiza Emissao da Nota Fiscal de Sada
         //---------------------------------------------------------------------------------------
         cNota   := MaPvlNfs(aPvlNfs,cSerie, .F.,.F.,.F.,.F.,.F.,0,0,.F.,.F.,,{ || .T. },,{ || .T. })		

         // Restaura pergunta
         MV_PAR17 := nMV_PAR17B
         MV_PAR24 := nMV_PAR24B
         If EZ0->EZ0_TIPONF == "CTe"
            MV_PAR25 := nMV_PAR25B
         Endif 

      EndIf 

   Endif 

   cMsgErroLib := ""
   If lErroLib
      cMsgErroLib += " - Blq. Estoque ou Credito"
   Endif 

   If Empty(cNota)	
		cMsg += "Pedido "+ cNumPed + " - NF " + cNota + " Serie " + cSerie + " Nao Gerada, verifique!" + cMsgErroLib + CRLF       
	Else 
		cMsg += "Pedido "+ cNumPed + " - NF " + cNota + " Serie " + cSerie + " Gerada com sucesso!"  + CRLF  
      RecLock("SF2",.F.)
      SF2->F2_CHVNFE := EZ0->EZ0_CHVNFE
      SF2->F2_UFORIG := EZ0->EZ0_UFORIT
      SF2->F2_UFDEST := EZ0->EZ0_UFDEST
      SF2->F2_FIMP   := "S"
      SF2->F2_HORA   := TIME()
      If EZ0->EZ0_TIPONF == "CTe"
         SF2->F2_ESPECIE := 'CTE'
      Endif 
      MsUnlock()

      Reclock("EZ0",.F.)
      EZ0->EZ0_STINTE := '1' 
      MsUnlock()

      dbSelectArea("SD2")
      dbSetOrder(3)  // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA
      dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
      While !SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
            RecLock("SD2",.F.)
            SD2->D2_ORIGLAN := ''
            SD2->(MsUnlock())
            SD2->(dbSkip())
      Enddo

      // 21/02/2023 - CARLA BARBOSA
      // Cria��o de Ponto de Entrada para tratamento ap�s grava��o da NF Saida
      // SF2 - POSICIONADA
      If ExistBlock("PPFIMSF2")
         ExecBlock("PPFIMSF2", .F., .F.)
      Endif

      // 05/07/2022 - Carla Barbosa
      // Tratamento para Percorrer SF3 quando possuir mais de 1 CFOP na NF
      aAreaSF3 := SF3->(GetArea())
      DbSelectArea("SF3")
      SF3->(dbSetOrder(4))  // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
      SF3->(dbgotop())
      SF3->(dbSeek(xFilial("SF3")+SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)))
      While !SF3->(Eof()) .and. SF3->F3_FILIAL==SF2->F2_FILIAL .AND. SF3->F3_CLIEFOR == SF2->F2_CLIENTE .and. ;
             SF3->F3_LOJA == SF2->F2_LOJA .AND. SF3->F3_NFISCAL == SF2->F2_DOC .AND. SF3->F3_SERIE == SF2->F2_SERIE 
             //SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE) == SF3->(F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)
      //If  !SF3->(Eof())
            RecLock("SF3",.F.)
            SF3->F3_CHVNFE   := EZ0->EZ0_CHVNFE
            SF3->F3_CODRSEF  := EZ0->EZ0_CODSEF
            SF3->F3_PROTOC   := EZ0->EZ0_PROTOC
            SF3->F3_CODRET   := "T"
            SF3->F3_DESCRET  := EZ0->EZ0_DESCRE
            If EZ0->EZ0_TIPONF == "CTe"
               SF3->F3_ESPECIE := 'CTE'
            Endif 
            SF3->(MsUnlock())
            SF3->(dbSkip())
      //EndIf
      Enddo
      RestArea(aAreaSF3)

      // 05/07/2022 - Carla Barbosa
      // Tratamento para Gravar Chave da NF na SFT
      aAreaSFT := SFT->(GetArea())
      DbSelectArea("SFT")
      SFT->(dbSetOrder(15))  // FT_FILIAL+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA 
      SFT->(dbgotop())
      SFT->(dbSeek(xFilial("SFT")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
      While SFT->(!Eof()) .and. SF2->F2_FILIAL == SFT->FT_FILIAL .AND.  SF2->F2_CLIENTE == SFT->FT_CLIEFOR .AND. SF2->F2_LOJA == SFT->FT_LOJA .AND. ;
            SF2->F2_DOC == SFT->FT_NFISCAL .AND. SF2->F2_SERIE == SFT->FT_SERIE
            //SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE) == SFT->(FT_FILIAL+FT_CLIEFOR+FT_LOJA+FT_NFISCAL+FT_SERIE)
            RecLock("SFT",.F.)
            SFT->FT_CHVNFE   := EZ0->EZ0_CHVNFE
            If EZ0->EZ0_TIPONF == "CTe"
               SFT->FT_ESPECIE := 'CTE'
            Endif 
            SFT->(MsUnlock())
            SFT->(dbSkip())
      Enddo
      RestArea(aAreaSFT)

	EndIf
   ddatabase := xdatabase
	RestArea(aArea)

Return cMsg


/*
===============================================================================================
||   Funcao: 	SELNFSAI
===============================================================================================
||		Permite selecionar
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	08/07/2020
===============================================================================================
*/
User Function SELNFSAI()
	
	Local oDlg
	Local aAreaSM0  := SM0->(GetArea())
	Local _stru      := {}
	Local aCpoBro    := {}
	Local lGrava     := .F.
	Local aButtons   := {}
	Local cSql		 := ""
	Local cAliasTRB	 := GetNextAlias()
	Local cPerg	     := "SELNFSAI"
	Local cMsg        := ""
	Local cEmpCad	:= cEmpAnt

	Private aObjects   	:= {}
	Private aPos       	:= {}
	Private aSize      	:= MsAdvSize()
	Private aInfo      	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

	Private aObjSub  := {}
	Private aPosSub  := {}
	Private lInverte := .F.
	Private cMark    := GetMark()   
	Private oMark
	
	aAdd(aButtons, { "RELATORIO" , {|| LegendSel() } , "Legenda" , "Legenda" } )

	ValidSFSAI(cPerg)

	If !Pergunte(cPerg,.T.)
		Return
	Endif 

	AADD(_stru,{"OK"      ,"C"	,2						,0		})
   AADD(_stru,{"STATUS"  ,"C"	,1						,0		})
	AADD(_stru,{"FILIAL"  ,"C"	,TamSX3("C5_FILIAL")[1]	,0		})
	AADD(_stru,{"PEDIDO"  ,"C"	,6						,0		})
   AADD(_stru,{"EMISSAO" ,"D"	,8						,0		})
	AADD(_stru,{"CLIENTE" ,"C"	,6						,0		})
	AADD(_stru,{"LOJA"    ,"C"	,2						,0		})
	AADD(_stru,{"NOME"    ,"C"	,60					,0		})
	AADD(_stru,{"NOTA"    ,"C"	,9						,0		})
	AADD(_stru,{"SERIE"   ,"C"	,3						,0		})
	cArq:=Criatrab(_stru,.T.)
	DBUSEAREA(.t.,,carq,"TTRB")//Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)

	cSql := " SELECT * FROM " + RetSqlName("SC5") + " SC5 " + CRLF
	cSql += " WHERE C5_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND D_E_L_E_T_ = ' ' AND C5_XNFSXML <> '' AND C5_NOTA = '' " + CRLF
	cSql += " AND C5_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	DBUseArea(.T., "TOPCONN", TCGenQry( , , cSql), (cAliasTRB), .F., .T.)
	If !(cAliasTRB)->(Eof())
		While !(cAliasTRB)->(Eof())
         If (cAliasTRB)->C5_MOEDA == 1
            cStatus := "1" // ok
         Else 
            nTaxa := Posicione("SM2",1,(cAliasTRB)->C5_EMISSAO,"M2_MOEDA2")
            If nTaxa > 0 
               cStatus := "1" // ok
            Else
               cStatus := "2" // Nao ok
            Endif 
         Endif 
			dbSelectArea("TTRB")
			RecLock("TTRB",.T.)
			TTRB->FILIAL  := (cAliasTRB)->C5_FILIAL
         TTRB->STATUS  := cStatus
			TTRB->PEDIDO  := (cAliasTRB)->C5_NUM
         TTRB->EMISSAO := STOD((cAliasTRB)->C5_EMISSAO)
			TTRB->CLIENTE := (cAliasTRB)->C5_CLIENTE 
			TTRB->LOJA    := (cAliasTRB)->C5_LOJACLI
			TTRB->NOME 	  := Posicione("SA1",1,xFilial("SA1")+(cAliasTRB)->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")
			TTRB->NOTA    := (cAliasTRB)->C5_XNFSXML
			TTRB->SERIE	  := (cAliasTRB)->C5_XSERXML
			MsunLock()	
			(cAliasTRB)->(DbSkip())
		Enddo
	Else
        MsgAlert("Nao foram encontrados Pedidos que atendam a pesquisa!")
        TTRB->(DbCloseArea())
        Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
		Return 
	Endif 
	(cAliasTRB)->(dbCloseArea())

	//Define as cores dos itens de legenda.
	aCoresLeg := {}
	aAdd(aCoresLeg,{"TTRB->STATUS == '1'","BR_VERDE"	})
	aAdd(aCoresLeg,{"TTRB->STATUS == '2'","BR_VERMELHO"})

	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect
	aCpoBro	:= {{ "OK"		,, ""   	, "@!"				  },;			
                { "FILIAL"	,, "Filial" , "@!"				  },;			
                { "PEDIDO"	,, "Pedido" , "@!"				  },;
                { "EMISSAO",, "Emissao" , "@!"				  },;
                { "CLIENTE",, "Cliente", "@!"				  },;			
                { "LOJA"	,, "Loja"  	, "@!"				  },;	
                { "NOME"	,, "Nome"  	, "@!"				  },;
                { "NOTA"	,, "Nota"  	, "@!"				  },;
                { "SERIE"	,, "Serie" 	, "@!"				  } }

	aAdd(aObjSub,{100,100,.T.,.T.,.F.})
	aPosSub := MsObjSize(aInfo,aObjSub)
	
	//Cria uma Dialog
	Define MsDialog oDlg TITLE "EZ4 GRC - Gerar Notas Importadas" From aSize[1],0 TO 500,950 PIXEL

	DbSelectArea("TTRB")
	DbGotop()

	//Cria a MsSelect
   oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{aPosSub[1,1],aPosSub[1,2],235,472},,,,,aCoresLeg)
	oMark:bMark := {| | Disp()} 
	oMark:oBrowse:bAllMark:= {|| DispAll() }
	
	//Exibe a Dialog
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lGrava:=.T. , oDlg:End() } , {|| lGrava:=.F. , oDlg:End() },,aButtons )

	If lGrava

		dbSelectArea("TTRB")
		DbGotop()
		While !TTRB->(Eof())

			If !Empty(TTRB->OK)

				SM0->(DbGoTop ())
				SM0->(MsSeek (cEmpCad+TTRB->FILIAL, .T.))
				cFilAnt := FWGETCODFILIAL

				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))
				SC5->(dbSeek(TTRB->(FILIAL+PEDIDO)))

				dbSelectArea("SF2")
				SF2->(dbSetOrder(1))	// F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
				If !SF2->(dbSeek(SC5->C5_FILIAL+SC5->C5_XNFSXML+SubStr(SC5->C5_XSERXML,1,3)+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
					cMsg := U_PROCNFEZ4(cMsg)
				Else
					cMsg += "Pedido "+ TTRB->PEDIDO + " - NF " + TTRB->NOTA + " Serie " + TTRB->SERIE + " Ja possui nota gerada!"  + CRLF  
				Endif

			EndIf

			TTRB->(dbSkip())

		Enddo 
		
		If !Empty(cMsg)
			Aviso( "EZ4 GRC" ,cMsg, {"OK"}, 3,"Gera Notas Importadas")
		Endif 
		
	Endif 

	//Fecha a Area e elimina os arquivos de apoio criados em disco.
	TTRB->(DbCloseArea())

	Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)
	
	RestArea(aAreaSM0)
	cFilAnt := FWGETCODFILIAL

Return

/*
===============================================================================================
||   Arquivo:	PORTAL_XML.prw
===============================================================================================
||   Funcao: 	LegendaSel
===============================================================================================
||		Legenda da tela de selecao, chamada na funcao SELNFSAI
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	26/10/2020
===============================================================================================
*/
Static Function LegendSel()

Local aLegenda	:= {}
Local cCadastro	:= "Legenda" 

AADD(aLegenda, {"BR_VERDE"	   ,"Pedidos aptos para Gerar Nota"})
AADD(aLegenda, {"BR_VERMELHO"	,"Pedidos sem Cotacao para Emissao"})

BrwLegenda(cCadastro,"Legenda",aLegenda) 

Return


/*
===============================================================================================
||   Arquivo:	PORTAL_XML.prw
===============================================================================================
||   Funcao: 	Disp
===============================================================================================
||		Funcao executada ao Marcar/Desmarcar um registro.   
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	29/05/2020
===============================================================================================
*/
Static Function Disp()

	RecLock("TTRB",.F.)
	If TTRB->(Marked("OK"))
      If TTRB->STATUS == '1'
		   TTRB->OK := cMark
      Else 
         TTRB->OK := ""
      Endif 
	else
		TTRB->OK := ""
	Endif          
	MsUnlock()
	oMark:oBrowse:Refresh()

Return()

/*
===============================================================================================
||   Arquivo:	PORTAL_XML.prw
===============================================================================================
||   Funcao: 	Disp
===============================================================================================
||		Funcao executada ao Marcar/Desmarcar um registro.   
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	29/05/2020
===============================================================================================
*/
Static Function DispAll()

	TTRB->(dbGoTop())

	While !TTRB->(Eof())
		RecLock("TTRB",.F.)
		If TTRB->(Marked("OK"))
			TTRB->OK := ""
		else
         If TTRB->STATUS == '1'
			   TTRB->OK := cMark
         Else
            TTRB->OK := ""
         Endif 
		Endif          
		MsUnlock()
		TTRB->(dbSkip())
	Enddo

	oMark:oBrowse:Refresh()

Return()
/*
===============================================================================================
||   Funcao: 	ValidSFSAI
===============================================================================================
||		Cria as perguntas caso nao existam
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/
Static Function ValidSFSAI(cPerg)

   PutSX1EZ(cPerg,'01','Filial de?'		,'Filial de?'	,'Filial de?'	,'mv_ch1','C',TamSX3("C5_FILIAL")[1],0,0,'G','','XM0','','S','mv_par01','','','','','','','','','','','','','','','','')
   PutSX1EZ(cPerg,'02','Filial ate?'	,'Filial ate?'	,'Filial ate?'	,'mv_ch2','C',TamSX3("C5_FILIAL")[1],0,0,'G','','XM0','','S','mv_par02','','','','','','','','','','','','','','','','')
   PutSX1EZ(cPerg,'03','Pedido de?'		,'Pedido de?'	,'Pedido de?'	,'mv_ch3','C',6						,0,0,'G','','SC5','','S','mv_par03','','','','','','','','','','','','','','','','')
   PutSX1EZ(cPerg,'04','Pedido ate?'	,'Pedido ate?'	,'Pedido ate?'	,'mv_ch4','C',6						,0,0,'G','','SC5','','S','mv_par04','','','','','','','','','','','','','','','','')
   
Return 

/*
===============================================================================================
||   Funcao: 	ValidPerg
===============================================================================================
||		Cria as perguntas caso nao existam
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/
Static Function ValidPerg(cPerg)

   cHist := "Tipo de Busca"

   PutSX1EZ(cPerg,"01","Tipo de Busca?","Tipo de Busca?","Tipo de Busca","mv_ch1","N",01,0,0,"C","","","","","MV_PAR01",;
            "Ler e-mails","","","", ; // opcao 1
            "Imp.Arquivos","","",  ; // opcao 2          
            "NFSe - OCR PDF","","",; // opcao 3 - TROQUEI O MANIFESTO PELO PDF
            "NF-e WebService","","",; // opcao 4
            "CT-e WebService","","",; // opcao 5
            {cHist},{cHist},{cHist})

   cHist := "Local destino"
   If nVersion == 17
      PutSX1EZ(cPerg,"02","Local destino" ,"Local destino" ,"Local destino","mv_ch2","C",99,0,0,"G","","DIR","","","MV_PAR02","","","","","","","","","","","","","","","","",{cHist},{cHist},{cHist})
   Else 
      PutSX1EZ(cPerg,"02","Local destino" ,"Local destino" ,"Local destino","mv_ch2","C",99,0,0,"G","","DIRAGR","","","MV_PAR02","","","","","","","","","","","","","","","","",{cHist},{cHist},{cHist})
   Endif 

Return 

/*
===============================================================================================
||   Funcao: 	ValidPerg
===============================================================================================
||		Cria as perguntas caso nao existam
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/
Static Function ValidNsu(cPerg)

   cHist := "Numero do NSU"
   PutSX1EZ(cPerg,"01","Numero do NSU" ,"Numero do NSU" ,"Numero do NSU","mv_ch1","N",15,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",{cHist},{cHist},{cHist})
   
Return 
/*
===============================================================================================
||   Funcao: 	PutSX1EZ
===============================================================================================
||		Funcao que cria as perguntas
||                                                                                              
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/06/2020
===============================================================================================
*/
Static Function PutSX1EZ(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,;
   nTamanho,nDecimal,nPresel,cGSC,cValid,cF3, cGrpSxg,cPyme,cVar01,;
   cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

	LOCAL aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f. 

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme 		== Nil, " ", cPyme		)
	cF3      := Iif( cF3 		== NIl, " ", cF3		)
	cGrpSxg  := Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
	cCnt01   := Iif( cCnt01		== Nil, "" , cCnt01 	)
	cHelp	 := Iif( cHelp		== Nil, "" , cHelp		)

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validacao dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01
		If cGSC == "C"			// Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort :=  "Busca" $ X1_PERGUNT .And. ! "PDF" $ SX1->X1_DEF03
		lSpa  :=  "Busca" $ X1_PERSPA  .And. ! "PDF" $ SX1->X1_DEFSPA3
		lIngl :=  "Busca" $ X1_PERENG  .And. ! "PDF" $ SX1->X1_DEFENG3

		If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort 
				SX1->X1_DEF03:= cDef03
			EndIf
			If lSpa 
				SX1->X1_DEFSPA3 := cDefSpa3
			EndIf
			If lIngl
				SX1->X1_DEFENG3 := cDefEng3
			EndIf
			SX1->(MsUnLock())
		EndIf

      lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
      
      cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		RecLock("SX1",.F.)
		If lPort 
			SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
		EndIf
		If lSpa 
			SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
		EndIf
		If lIngl
			SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
		EndIf
		SX1->(MsUnLock())

	Endif

	RestArea( aArea )

Return

//===========================================================================================================
//
// PONTOS DE ENTRADA DE USO DO PORTAL
//
// OBJETIVO: GARANTIR A INTEGRIDADE DAS NOSSAS ROTINAS
//
//===========================================================================================================

/*
===============================================================================================
||   Funcao: 	EZGQREENTR
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao GQREENTR
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada GQREENTR

      If ExistBlock("EZGQREENTR")
           U_EZGQREENTR()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/
User Function EZGQREENTR()

   Local aAreaSF3 := SF3->(GetArea())

   dbSelectArea("EZ0")
   EZ0->(dbSetOrder(1))
   If EZ0->(dbSeek(xFilial("EZ0")+SF3->F3_CHVNFE))
      RecLock("SF3",.F.)
      SF3->F3_CODRSEF  := EZ0->EZ0_CODSEF
      SF3->F3_PROTOC   := EZ0->EZ0_PROTOC
      SF3->F3_CODRET   := "T"
      SF3->F3_DESCRET  := EZ0->EZ0_DESCRE
      SF3->(MsUnlock())
   Endif

   RestArea(aAreaSF3)

Return 


/*
===============================================================================================
||   Funcao: 	EZSF1100I
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao SF1100I
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada SF1100I

      If ExistBlock("EZSF1100I")
           U_EZSF1100I()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/

User Function EZSF1100I()

   Local aAreaSF1 := SF1->(GetArea())
   Local aAreaSD1 := SD1->(GetArea())

   If SF1->F1_FORMUL == "S" .and. !Empty(Alltrim(SF1->F1_CHVNFE))
      dbSelectArea("EZ0")
      EZ0->(dbSetOrder(1))
      If EZ0->(dbSeek(xFilial("EZ0")+SF1->F1_CHVNFE))
         SF1->F1_DTDIGIT := DDEMISSAO
         dbSelectarea("SD1")
         SD1->(dbSetOrder(1))    // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
         If SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
            While !SD1->(Eof()) .And.  xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
               SD1->D1_DTDIGIT := DDEMISSAO
               SD1->(dbSkip())
            Enddo
         Endif
      Endif 
   Elseif SF1->F1_FORMUL == "S" .and. Empty(Alltrim(SF1->F1_CHVNFE))
      // a EZ0 est� posicionada .. ent�o n�o vou posicionar
      SF1->F1_DTDIGIT := DDEMISSAO
      dbSelectarea("SD1")
      SD1->(dbSetOrder(1))    // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
      If SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
         While !SD1->(Eof()) .And.  xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
            SD1->D1_DTDIGIT := DDEMISSAO
            SD1->(dbSkip())
         Enddo
      Endif
      // Carla Barbosa - Grava��o da Chave da NFE para casos de nf de importa��o 
      // sem a primeira classific�o
      SF1->F1_CHVNFE := EZ0->EZ0_CHVNFE
      // Gravar a chave nos Livros Fiscais
      aAreaSF3 := SF3->(GetArea())
      SF3->(dbSetOrder(4))  // F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
      SF3->(dbgotop())         
      If SF3->(dbSeek(xFilial("SF3")+EZ0->(EZ0_FORNEC+EZ0_LOJA+EZ0_DOC+EZ0_SERIE)))
         While SF3->(!EOF()) .and. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == EZ0->(EZ0_FORNEC+EZ0_LOJA+EZ0_DOC+EZ0_SERIE)
            RecLock("SF3", .F.)
            Replace SF3->F3_CHVNFE WITH EZ0->EZ0_CHVNFE   
            MsUnlock()
         Enddo
      Endif
      RestArea(aAreaSF3)
      aAreaSFT := SFT->(GetArea())
      SFT->(dbSetOrder(15))  // FT_FILIAL+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA 
      SFT->(dbgotop())
      SFT->(dbSeek(xFilial("SFT")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
      While SFT->(!Eof()) .and. SF1->F1_FILIAL == SFT->FT_FILIAL .AND.  SF1->F1_FORNECE == SFT->FT_CLIEFOR .AND. SF1->F1_LOJA == SFT->FT_LOJA .AND. ;
         SF1->F1_DOC == SFT->FT_NFISCAL .AND. SF1->F1_SERIE == SFT->FT_SERIE
         RecLock("SFT",.F.)
         SFT->FT_CHVNFE   := EZ0->EZ0_CHVNFE
         SFT->(MsUnlock())
         SFT->(dbSkip())
      Enddo
      RestArea(aAreaSFT)
   Endif 
   RestArea(aAreaSF1)
   RestArea(aAreaSD1)
Return 
/*
===============================================================================================
||   Funcao: 	EZMT920TOK
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao MT920TOK
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada MT920TOK

      If ExistBlock("EZMT920TOK")
           U_EZMT920TOK()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/
User Function EZMT920TOK()

   Local aArea    := GetArea()
   Local cSQL      := ""
   Local cAliasTRB := GetNextAlias()

   dbSelectArea("DT6")
   DT6->(dbSetOrder(1)) // DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
   If DT6->(dbSeek(xFilial('DT6')+xFilial('DT6')+SF2->(F2_DOC+F2_SERIE)))
      RecLock("DT6",.F.)
      DT6->(DBDelete())
      MsUnlock()
   Endif

   cSQL += " SELECT SF6.R_E_C_N_O_ SF6REC " + CRLF 
   cSQL += " FROM " + RetSqlName("SF6") + " SF6 (NOLOCK) " + CRLF
   cSQL += " WHERE SF6.F6_FILIAL = '" + xFilial("SF6") + "' AND D_E_L_E_T_ = ' ' AND " + CRLF
   cSQL += "       F6_DOC = '" + SF2->F2_DOC + "' AND F6_SERIE = '" + SF2->F2_SERIE + "' AND " + CRLF
   cSQL += "       SF6.F6_CLIFOR = '" + SF2->F2_CLIENTE + "' AND F6_LOJA = '" + SF2->F2_LOJA + "' "
   DBUseArea(.T., "TOPCONN", TCGenQry( , , cSQL), (cAliasTRB), .F., .T.)
   If !(cAliasTRB)->(Eof())
      SF6->(dbGoTo((cAliasTRB)->SF6REC))
      RecLock("SF6",.F.)
      SF6->(DBDelete())
      MsUnlock()
   Endif 
   (cAliasTRB)->(dbCloseArea())

   RestArea(aArea)

Return .T.



/*
===============================================================================================
||   Funcao: 	EZM460NUM
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao M460NUM
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada M460NUM

      If ExistBlock("EZM460NUM")
           U_EZM460NUM()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/
User Function EZM460NUM()

    If IsInCallStack("U_PROCNFEZ4") .Or. IsInCallStack("NFSProcess")
        cNumero := Alltrim(SC5->C5_XNFSXML)
    EndIF   

Return()


/*
===============================================================================================
||   Funcao: 	EZMA410MNU
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao MA410MNU
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada MT920TOK

      If ExistBlock("EZMA410MNU")
           U_EZMA410MNU()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/
User Function EZMA410MNU()

	Private lAtivaSai  := SuperGetMV("EZ_PX_NFS",.F.,.F.) 
	
	If lAtivaSai
		If ExistBlock("SELNFSAI")
			aAdd(aRotina,{"Gera Notas Importadas","U_SELNFSAI()", 0, 8, 0, Nil})
		EndIf
	Endif 
	
Return

/*
===============================================================================================
||   Funcao: 	EZMT103FIM
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	31/07/2023
===============================================================================================
||	  Funcao utilizada na chamada da funcao para Marcar o Processamento do Documento Entrada 
||   na Execu��o do ExecAuto, prevendo os casos em que � realizado o DisarmTransaction sem retorno
||   de erro para o Execauto
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada MT103FIM

      If ExistBlock("EZMT103FIM")
           EZMT103FIM()
      Endif 

===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	31/07/2023
===============================================================================================
*/
User Function EZMT103FIM()

   Local aArea:= (GetArea())

   If Inclui
      aadd(aGrcNf,SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE)
   Endif 

   RestArea(aArea)

Return 

/*
===============================================================================================
||   Funcao: 	EZMT140SAI
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	10/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao Corrigir algum campo apos a geracao da pre-nota
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada MT920TOK

      If ExistBlock("EZMT140SAI")
           EZMT140SAI()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/
User Function EZMT140SAI()

   Local aAreaSD1 := SD1->(GetArea())

   If Inclui
   
      dbSelectArea("SD1")
      SD1->(dbSetOrder(1))   // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
      If SD1->(dbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
         While !SD1->(Eof()) .And. xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
               If SD1->D1_DTDIGIT <> SF1->F1_DTDIGIT
                  RecLock("SD1",.F.)
                  SD1->D1_DTDIGIT := SF1->F1_DTDIGIT
                  MsUnlock()
               Endif 
               SD1->(dbSkip())
         Enddo 
      Endif 
      aadd(aGrcNf,SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE)
   Endif 

   RestArea(aAreaSD1)

Return 

/*
===============================================================================================
||   Funcao: 	EZMT140SAI
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	10/09/2020
===============================================================================================
||	  Funcao utilizada na chamada da funcao Corrigir algum campo apos a geracao da pre-nota
===============================================================================================
   Exemplo de uso:

      Aplicar a chamada abaixo dentro do ponto de entrada MT920TOK

      If ExistBlock("EZMT140SAI")
           EZMT140SAI()
      Endif 

===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	04/09/2020
===============================================================================================
*/
Static Function RetDados(cLinha,cCampo)

   Local cSeparador  := ""
   Local aLayDetal   := {}  
   Local aSeparador  := {}
   Local cDados      := "" 
   Local nPos        := 0 
   Local nI          := 0 

   While !EZ5->(Eof()) .And. xFilial("EZ5")+SM0->M0_CODMUN == EZ5->(EZ5_FILIAL+EZ5_CODMUN)
      If Empty(cSeparador)
         cSeparador := EZ5->EZ5_SEPARA
      Endif 
      aAdd(aLayDetal , {  EZ5->EZ5_CODMUN, EZ5->EZ5_TIPO, Val(EZ5->EZ5_ORDEM), EZ5->EZ5_POSINI, EZ5->EZ5_TAMANH, Upper(EZ5->EZ5_CHAVE) , Posicione("SX3",2,EZ5->EZ5_CHAVE,"X3_TIPO") } )
      EZ5->(dbSkip())
   Enddo 

   aLayDetal := aSort(aLayDetal,,, { |x, y| x[3] < y[3] })
   
   nPosCtrl := 0 

   For nI := 1 to Len(cLinha)

      If SubStr(cLinha,1,1) == "2"
      
         If SubStr(cLinha,nI,1)==cSeparador
            If Len(aSeparador)==0
               aAdd(aSeparador , SubStr(cLinha,1,nI-1) )
               nPosCtrl := nI
            Else
               aAdd(aSeparador , SubStr(cLinha,nPosCtrl+1,nI-1-nPosCtrl) )
               nPosCtrl := nI
            Endif 
         Endif 

      Endif 

   Next nI

   cTipo := Posicione("SX3",2,cCampo,"X3_TIPO")

   nPos := aScan( aLayDetal , { |x| AllTrim(x[6]) == Alltrim(cCampo) })
   
   If nPos > 0 
      cDados := aSeparador[nPos]
   Endif 

   If cTipo $ "D"
      cDados := CTOD(cDados)
   ElseIf cTipo $ "N"
      cDados := Val(StrTran(cDados,",","."))
   Endif 

Return cDados

/*
===============================================================================================
||   Funcao: 	WFInconsist
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/11/2020
===============================================================================================
||	  Rotina chamada pelo F12 da funcao Gera_PRNF para enviar WF para os responsaveis
===============================================================================================
*/
Static Function WFInconsist()

   Local lGrv  := .F.
   Local nX    :=0

   Private oGetDGrupo
   Private oDlgGrupo
   Private oGrupo  
   Private oSegmento
   Private oNomeClie
   Private oObserva

   Private cCadastro    := "Grupos de Workflow"
   Private cGrupo  		:= Criavar("EZ8_GRUPO")
   Private nGrupo       := 0
   Private aGrupoSel    := {}
   Private cObserva     := Space(200)

   // Monta Dimension da Tela - Nunca ira mudar
   Private aObjects   		:= {}
   Private aPos       		:= {}
   Private aSize      		:= MsAdvSize()
   Private aInfo      		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
   
   Private aHdGrupo		:= {}
   Private aColsGrupo		:= {}
   Private aCposGrupo		:= { "EZ8_USUARI","EZ8_NOME","EZ8_EMAIL" }

   RetGrupo()

   //u����������������������������������������������������Ŀ
   //�Monta o Cabecalho da tabela AA3 Base de Atendimento  �
   //�������������������������������������������������������
   dbSelectArea("SX3")
   SX3->(dbSetOrder(2))
   For nX := 1 To Len(aCposGrupo)
      If SX3->(dbSeek(aCposGrupo[nX]))
         aAdd(aHdGrupo,{	Trim(X3Titulo())		,;
                           SX3->X3_CAMPO				,;
                           SX3->X3_PICTURE			,;
                           SX3->X3_TAMANHO			,;
                           SX3->X3_DECIMAL			,;
                           SX3->X3_VALID				,;
                           SX3->X3_USADO				,;
                           SX3->X3_TIPO				,;
                           SX3->X3_F3					,;
                           SX3->X3_CONTEXT			,;
                           SX3->X3_CBOX				,;
                           SX3->X3_RELACAO			,;
                           SX3->X3_WHEN				})
      Endif
   Next nX

   //u�������������������������������������������������������������Ŀ
   //� Dimensao da tela                                             �
   //����������������������������������������������������������������
   aAdd(aObjects,{100,035,.T.,.F.,.F.})
   aAdd(aObjects,{100,100,.T.,.T.,.F.})
   aPos := MsObjSize(aInfo,aObjects)

	nLargTela := 1000
	nAltuTela := 500
   
   //Define MsDialog oDlgGrupo Title cCadastro Of oMainWnd Pixel From aSize[7],0 To aSize[6],aSize[5] Style DS_MODALFRAME
   Define MsDialog oDlgGrupo Title cCadastro Of oMainWnd Pixel From aSize[7],0 To nAltuTela, nLargTela Style DS_MODALFRAME
   
   @ aSize[2]+3, 003 GROUP oGroup1 TO aSize[2]+35,nLargTela/2-2 Prompt "" Of oDlgGrupo Color 0, 16777215 Pixel              

   @ aSize[2]+37,003 GROUP oGroup1 TO nAltuTela/2-005,nLargTela/2-2 Prompt "Usuarios do Grupo" Of oDlgGrupo Color 0, 16777215 Pixel

   nLin := aSize[2]+10

   //-->> Primeira Linha
   @ nLin+04,aPos[1,2]+010 Say "Grupo"						                  Size  40,09 Of oDlgGrupo Pixel 
   @ nLin+03,aPos[1,2]+040 MsComboBox oGrupo Var nGrupo items aGrupoSel Size  70,09 Of oDlgGrupo Pixel Valid LoadGrupo()

   @ nLin+04,aPos[1,2]+130 Say "Motivo"	         				         Size  40,09 Of oDlgGrupo Pixel 
   @ nLin+03,aPos[1,2]+160 MsGet oObserva  Var cObserva Picture "@!"    Size 240,09 Of oDlgGrupo Pixel

   oGetDGrupo := MsNewGetDados():New(aSize[2]+46,006,nAltuTela/2-012,nLargTela/2-006,,"AllwaysTrue()","AllwaysTrue()",,,,,,,,oDlgGrupo,@aHdGrupo,@aColsGrupo)

   ACTIVATE MSDIALOG oDlgGrupo ON INIT EnchoiceBar(oDlgGrupo,{|| WFEnvia() , oDlgGrupo:End() },{|| lGrv:=.F.,oDlgGrupo:End()})

Return 

/*
===============================================================================================
||   Funcao: 	RetGrupo
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	01/12/2020
===============================================================================================
||	  Rotina acionada pela funcao WFInconsist para carregar os itens da combo de selecao
===============================================================================================
*/
Static Function RetGrupo()

   Local cSql := ""
   Local cAliasTRB := GetNextAlias()
   
   cSql := "SELECT DISTINCT EZ8_GRUPO FROM " + RetSqlName("EZ8") + "WHERE D_E_L_E_T_ = ' ' AND EZ8_FILIAL = '" + xFilial("EZ8") + "' "
   dbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cSql)), cAliasTRB, .F., .T. )

   While !(cAliasTRB)->(Eof())
      aAdd(aGrupoSel,(cAliasTRB)->EZ8_GRUPO)
      (cAliasTRB)->(dbSkip())
   Enddo 

   (cAliasTRB)->(dbCloseArea())
   
Return 

/*
===============================================================================================
||   Funcao: 	LoadGrupo
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	01/12/2020
===============================================================================================
||	  Rotina que carrega os usuarios pertencente ao grupo selecionado 
===============================================================================================
*/
Static Function LoadGrupo()

   Local nX   := 0 
//   Local nPos := 0 

   If Valtype(nGrupo) == "N"
      If nGrupo == 0
         oGrupo:setFocus()    // Marcio Martins - 31/08/2023 - para evitar error.log
         Return 
      Endif 
      // verificar essa linha abaixo,acho que esta errada
      nGrupo := aGrupoSel[aScan(aGrupoSel, Alltrim(ngrupo))]
   Endif

   nGrupo := Padr(nGrupo,TamSX3("EZ8_GRUPO")[1])

   aColsGrupo := {}

   dbSelectArea("EZ8")
   EZ8->(dbSetOrder(1))
   If EZ8->(dbSeek(xFilial("EZ8")+nGrupo))
      While !EZ8->(Eof()) .And. xFilial("EZ8")+nGrupo == EZ8->(EZ8_FILIAL+EZ8_GRUPO)
         If EZ8->EZ8_ATIVO == "1"
            aAdd( aColsGrupo, Array(Len(aHdGrupo)+1) )
            For nX := 1 To Len(aHdGrupo)
               aColsGrupo[Len(aColsGrupo)][nX] := EZ8->(FieldGet(FieldPos(aHdGrupo[nX][2])))
            Next nX
            aColsGrupo[Len(aColsGrupo)][Len(aHdGrupo)+1] := .F.		
         Endif 
         EZ8->(dbSkip())
      Enddo 
   Endif 

   oGetDGrupo := MsNewGetDados():New(aSize[2]+46,006,aSize[6]/2-007,aSize[5]/2-6,,"AllwaysTrue()","AllwaysTrue()",,,,,,,,oDlgGrupo,@aHdGrupo,@aColsGrupo)
   oGetDGrupo:Refresh()

Return 


/*
===============================================================================================
||   Funcao: 	WFEnvia
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	01/12/2020
===============================================================================================
||	  Rotina Carrega os e-mails dos usuarios
===============================================================================================
*/
Static Function WFEnvia(nGrpEmail,lSched,cMsgEZ2)

   Local nX        := 0
   Local aDados    := {}
   Local aArquivos := {}
   Local cFornec   := ""
   Local cEmails   := ""
   Local nPsEmail  := ""  
   Local cPedidos  := ""
   Local aEzEmail  := {}

   Default nGrpEmail := ""
   Default lSched    := .f.
   Default cMsgEZ2   := ""

   if Empty(Alltrim(nGrpEmail)) 
      nPsEmail  := aScan( aHdGrupo , { |x| AllTrim(x[2]) == "EZ8_EMAIL" })
   Else 
      nPsEmail  := nGrpEmail
      nGrupo    := nGrpEmail
      nConta     := 1
      dbSelectArea("EZ8")
      EZ8->(dbSetOrder(2))
      If EZ8->(dbSeek(xFilial("EZ8")+nPsEmail))
         While !EZ8->(Eof()) .And. xFilial("EZ8")+nPsEmail == EZ8->(EZ8_FILIAL+EZ8_CODIGO)
            If EZ8->EZ8_ATIVO == "1"
               if ascan(aEzEmail, EZ8->EZ8_EMAIL)==0
                  aAdd(aEzEmail , EZ8->EZ8_EMAIL )
               Endif
            Endif 
            EZ8->(dbSkip())
         Enddo 
      Endif 
   Endif


   dbSelectArea("SA2")
   SA2->(dbSetOrder(1))
   SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
   cFornec := EZ0->EZ0_FORNEC+"/"+EZ0->EZ0_LOJA+" "+Alltrim(SA2->A2_NOME)

   if Empty(Alltrim(nGrpEmail)) 
      For nX := 1 to Len(oGetDGrupo:aCols)
         cEmails += Alltrim(oGetDGrupo:aCols[nX,nPsEmail])+";"
      Next nX 
      dbSelectArea("EZ8")
      EZ8->(dbSetOrder(1))
      EZ8->(dbSeek(xFilial("EZ8")+nGrupo))      

   Else
      For nX := 1 to len(aEzEmail)
         cEmails +=aEzEmail[nX]+";"
      next
      dbSelectArea("EZ8")
      EZ8->(dbSetOrder(2))
      EZ8->(dbSeek(xFilial("EZ8")+nGrupo))
      nGrupo:= EZ8->EZ8_GRUPO
   Endif



   dbSelectArea("EZ2")
   EZ2->(dbSetOrder(1))
   EZ2->(dbSeek(xFilial("EZ2")+EZ0->EZ0_CHVNFE))
   While !EZ2->(Eof()) .And. xFilial("EZ2")+EZ0->EZ0_CHVNFE == EZ2->(EZ2_FILIAL+EZ2_CHVNFE)
      If !Empty(EZ2->EZ2_GRUPO) .And. EZ2->EZ2_GRUPO == EZ8->EZ8_CODIGO 
         dbSelectArea("EZ1")
         EZ1->(dbSetOrder(1))
         If EZ1->(dbSeek(xFilial("EZ1")+EZ0->EZ0_CHVNFE+EZ2->EZ2_ITEM))
            IF at(EZ1->EZ1_PEDIDO, cPedidos) == 0
               cPedidos += EZ1->EZ1_PEDIDO + "/"
            Endif
         Endif 
      Endif 
      EZ2->(dbSkip())
   Enddo
   
   cPedidos := SubStr(cPedidos,1,Len(cPedidos)-1)

   aAdd(aDados, 1)                                                               // 1  Opcao para selecao do workflow
   aAdd(aDados, EZ0->EZ0_NUMNFE)                                                 // 2  Numero da nota
   aAdd(aDados, nGrupo)                                                        // 3  Vendedor
   aAdd(aDados, cEmails)                                                         // 4  E-mails do grupo
   aAdd(aDados, SM0->M0_FILIAL)                                                  // 5  Planta
   aAdd(aDados, cFornec)                                                         // 6  Codigo/loja/Nome Cliente
   aAdd(aDados, cPedidos)    
   IF Empty(Alltrim(nGrpEmail))                                                     // 7  numero do pedido de compra
      aAdd(aDados, "MOTIVO: " + Alltrim(cObserva))   // 8  Motivo da ocorrencia
   Else
      aAdd(aDados, "MOTIVO: " + Alltrim(cMsgEZ2))  // 8  Motivo da ocorrencia
   Endif                                

   U_fEnvEmail(aDados, aArquivos)

   IF Empty(Alltrim(nGrpEmail))  
      U_RegLogUser("8",cObserva)
   Endif

   // Projeto Fenix
   If EZ0->(FieldPos("EZ0_WFUSER")) > 0
      RecLock("EZ0",.F.)      
      EZ0->EZ0_WFUSER := __cuserid
      MsUnlock()
   Endif 
   //if !lSched
   //   MsgAlert("E-mail enviado!")
   //Endif
   
Return

/*
===============================================================================================
||   Funcao: 	WFOkFornec
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	27/11/2020
===============================================================================================
||	  Rotina chamada pelo F12 da funcao Gera_PRNF para enviar WF para os responsaveis
===============================================================================================
*/
Static Function WFOkFornec()

   Local aDados    := {}
   Local aArquivos := {}
   Local cFornec   := ""
   Local cEmail    := ""

   dbSelectArea("SA2")
   SA2->(dbSetOrder(1))
   SA2->(dbSeek(xFilial("SA2")+EZ0->(EZ0_FORNEC+EZ0_LOJA)))
   cEmail  := SA2->A2_EMAIL
   cFornec := Alltrim(SA2->A2_NOME)

   aAdd(aDados, 2)                                                               // 1  Opcao para selecao do workflow
   aAdd(aDados, EZ0->EZ0_NUMNFE)                                                 // 2  Numero da nota
   aAdd(aDados, cEmail)                                                          // 3  e-mail do fornecedor
   aAdd(aDados, cFornec)                                                         // 6  Codigo/loja/Nome Cliente

   U_fEnvEmail(aDados, aArquivos)
   
Return

/*
===============================================================================================
||   Funcao: 	fEnvEmail
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	26/11/2020
===============================================================================================
||	  Funcao utilizada para disparar workflow conforme as informac�es passadas
===============================================================================================
*/
User Function fEnvEmail(aDados, aArquivos)

	Local oProcess		:= Nil
	Local OHTML			:= Nil
	Local cAssunto		:= ""
   Local cArquivo    := ""
   Local cTo         := ""
	Local nX			   := 0
   Local cLogo       := SuperGetMV("EZ_LOGOWF",.F.,"https://www.crowncork.com/sites/all/themes/crown/logo.png")
   
	oProcess 			:= TWFPROCESS():NEW("000001","Comunicado")

   If aDados[1] == 1  // Workflow de Inconsistencias encontradas

      cArquivo := "\workflow\html\wfInconsistencias.htm"
      cAssunto := "Comunicado - Inconsistencias encontradas - Planta: " + aDados[5] //Planta
      cTo        := aDados[4]
   
   ElseIf aDados[1] == 2  // Workflow de aviso ao fornecedor

      cArquivo := "\workflow\html\wfokfornec.htm"
      cAssunto := "Comunicado - Informe de aceite da nota: " + aDados[2]   // Numero da nota
      cTo        := aDados[3] // e-mail do fornecedor

   ElseIf aDados[1] == 3  // Workflow de aviso ao departamento fiscal referente a divergencias encontradas

      cArquivo := "\workflow\html\wfDivergenciaNF.htm"
      cAssunto := "Comunicado - Divergencia na Conferencia - NF n� " + aDados[2]   // Numero da nota
      cTo        := aDados[3] // e-mail do fiscal

   /*
   Elseif aDADOS[1] == 4 // Workflow de aviso de Cancelamento de NF
      
      cArquivo := "\workflow\html\wfCancelaNF.htm"
      cAssunto := "Comunicado - Aviso Cancelamento de NF n� " + aDados[2]+"-"+aDados[3]   // Numero da nota
      cTo        := aDados[8] // e-mail do fiscal
   */
   Endif 
   

   oProcess:NEWTASK( 'INICIO' , cArquivo )
	oProcess:CTO 		:= cTo
	oProcess:CSUBJECT	:= cAssunto
	OHTML 				:= oProcess:OHTML

	If Len(aArquivos) > 0
		for nX := 1 to Len(aArquivos)
			oProcess:AttachFile(aArquivos[nX])
		next nX
	EndIf		
	
   If aDados[1] == 1      
      OHTML:VALBYNAME("WLogo" , cLogo)
      OHTML:VALBYNAME("WComunicado" , cAssunto)
      OHTML:VALBYNAME("WVendedor"   , aDados[3])
      OHTML:VALBYNAME("WNota"       , aDados[2])
      OHTML:VALBYNAME("WCodFornece" , aDados[6])
      OHTML:VALBYNAME("WPedido"     , aDados[7])
      OHTML:VALBYNAME("WOcorrencia" , aDados[8])
   ElseIf aDados[1] == 2
      OHTML:VALBYNAME("WLogo" , cLogo)
      OHTML:VALBYNAME("WComunicado" , cAssunto)
      OHTML:VALBYNAME("WNota"       , aDados[2])
      OHTML:VALBYNAME("WFornecedor" , aDados[4])
   ElseIf aDados[1] == 3
      OHTML:VALBYNAME("WLogo" , cLogo)
      OHTML:VALBYNAME("WComunicado" , cAssunto)
      OHTML:VALBYNAME("WNota"       , aDados[2])
      OHTML:VALBYNAME("WFornecedor" , aDados[4])
      OHTML:VALBYNAME("WOcorrencia" , aDados[5])
   /*
   Elseif aDados[1] == 4
      OHTML:VALBYNAME("WLogo" , cLogo)
      OHTML:VALBYNAME("WComunicado" , cAssunto)
      OHTML:VALBYNAME("WNota"       , aDados[2]+"-"+aDados[3])
      OHTML:VALBYNAME("WChave"      , aDados[4])
      OHTML:VALBYNAME("WFornecedor" , aDados[5])
      OHTML:VALBYNAME("WData"       , aDados[7])
      OHTML:VALBYNAME("WMotivo"     , aDados[9])
   */
   Endif 
	
	oProcess:CLIENTNAME(SUBS("CUSUARIO",7,15))
	oProcess:USERSIGA	:= __CUSERID
	oProcess:START()
	oProcess:FREE()
	oProcess:= NIL

Return

/*
===============================================================================================
||   Funcao: 	ManifChave
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	01/12/2020
===============================================================================================
||	  Funcao que realiza a ciencia da operacao
===============================================================================================
||   210200 - Confirmacao da Operacao
||   210210 - Ciencia da Operacao
||   210220 - Desconhecimento da Operacao
||   210240 - Operacao nao Realizada
===============================================================================================
*/
User Function ManifChave(cChave,cCodigo,cJustific)
   
   Local lAux    := .F.
	Local cXMLMan := ""
   Local aXmlman := {}
	Local cIdEnt  := RetIdEnti()	  
	Local cURL	  := PadR(GetNewPar("MV_SPEDURL","http://"),250)

   Default cJustific := ''
   //Carla Barbosa - Declarando a variavel oWs como private para n�o dar erro em 
   //outras chamadas de fun��es 
   Private oWS		:= Nil
	  
	oWs := WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken := "TOTVS"
	oWs:cIDENT	  := cIdEnt
	oWs:cAMBIENTE  := ""
	oWs:cVERSAO    := ""
	oWs:_URL       := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
      
	If oWs:CONFIGURARPARAMETROS()
	
		cAmbiente := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
		oWs:cUserToken := "TOTVS"
		oWs:cIDENT	 := cIdEnt
		oWs:cAMBIENTE	 := cAmbiente
		oWs:_URL       := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
		
		cXMLMan:='<envEvento><eventos><detEvento>'
		cXMLMan+='<tpEvento>'+cCodigo+'</tpEvento>'
		cXMLMan+='<chNFe>'+cChave+'</chNFe>'
		cXMLMan+='<ambiente>'+cAmbiente+'</ambiente>'
      If Alltrim(cCodigo) $ '210240' .and. !Empty(cJustific)
         cXMLMan+='<xJust>'+Alltrim(cJustific)+'</xJust>'
      EndIf		
		cXMLMan+='</detEvento></eventos></envEvento>'
		
		lAux:= RetEnvManif(cXMLMan,cIdEnt,cURL,@aXmlman)
      // Carla Barbosa - Gravando Retorno do Manifesto na Tabela C00
      // 210200 - Confirma��o da Opera��o -  
      // 210210 - Ciencia da Opera��o - C00_STATUS = 4
      if lAux
         C00->(dbsetOrder(1))
         if C00->(dbSeek(xFilial("C00")+cChave))
            if Alltrim(cCodigo) $ '210200"
               RecLock("C00",.F.)
               C00->C00_STATUS := '1'
               MsUnlock()      
            Elseif Alltrim(cCodigo) $ "210210"
               RecLock("C00",.F.)
               C00->C00_STATUS := '4'
               MsUnlock()         
            endif
         endif
      endif
      //If lAux
         //Alterado conforme chamado 60064
         If Alltrim(cCodigo) $ '210240|210220'
            RecLock("EZ0",.F.)
            EZ0->EZ0_STINTE := '9'
            EZ0->EZ0_XMLOK  := '2'	// Rejeitado
            MsUnlock()    
            cMotivo := nOpcao + If(!Empty(cJustific)," - Justif: " + cJustific,'')
            U_RegLogUser('G', cMotivo)                  
         Endif          
      //Endif
      /*
		oWs:oWSDOCUMENTOS:oWSDOCUMENTO := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()
		aadd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
		oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[1]:CCHAVE := aChaves[i,1]

		lAux := oWs:BAIXARXMLDOCUMENTOS()
      */
	Endif

Return

/*
===============================================================================================
||   Funcao: 	BUSCAPED
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	12/01/2021
===============================================================================================
||	  Funcao que realiza a busca pelo pelas TAG�s xPed e xItemPed
===============================================================================================
*/
Static Function BUSCAOPER()

   Local cRetOper  := ""

   dbSelectArea("SC7")
   SC7->(dbSetOrder(1))
   If SC7->(dbSeek(xFilial("SC7")+EZ1->(EZ1_PEDIDO+EZ1_ITEMPC)))
      If SC7->(FieldPos("C7_XOPER")) > 0 
         cRetOper := SC7->C7_XOPER
      Endif 
   Endif 
   
Return cRetOper 

/*
===============================================================================================
||   Funcao: 	VLDPEDCOM
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	12/01/2021
===============================================================================================
||	  Funcao que realiza as validac�es necessarias para os pedidos de compras
===============================================================================================
*/
User Function VLDPEDCOM(cOpcao)

   Local cSql := ""
   Local lRet := .F.
   Local cAliasTRB := GetNextAlias()
   
//   If SubStr(Alltrim(EZ1->EZ1_CF),2,3)$SuperGetMV('EZ_CFOPNPC',.F.,'')
//      lRet := .T.
//   Else 
   If ExistBlock("EZSC7COMP")
      cSql := U_EZSC7COMP(EZ1->EZ1_FILIAL,EZ0->EZ0_FORNEC,EZ0->EZ0_LOJA,EZ1->EZ1_COD,EZ1->EZ1_QUANT,.F.,2,EZ1->EZ1_PEDIDO,EZ1->EZ1_ITEMPC)
   Else
      cSql += " SELECT * FROM " + RetSqlName("SC7") + CRLF 
      cSql += " WHERE D_E_L_E_T_ = ' ' " + CRLF 
      cSql += " AND C7_FILIAL = '" + EZ1->EZ1_FILIAL + "' " + CRLF 
      cSql += " AND C7_FORNECE = '" + EZ0->EZ0_FORNEC + "' " + CRLF 
      cSql += " AND C7_LOJA = '" + EZ0->EZ0_LOJA + "' " + CRLF 
      cSql += " AND C7_NUM = '" + EZ1->EZ1_PEDIDO + "' " + CRLF 
      cSql += " AND C7_ITEM = '" + EZ1->EZ1_ITEMPC + "' " + CRLF
   Endif 
      dbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cSql)), cAliasTRB, .F., .T. )
      If !(cAliasTRB)->(Eof())
         If cOpcao == "EXISTESC7"
            lRet := .T.
            RecLock("EZ1",.F.)
            EZ1->EZ1_COD := (cAliasTRB)->C7_PRODUTO
            MsUnlock()
         ElseIf cOpcao == "LIBERADOSC7"
            //If (cAliasTRB)->C7_CONAPRO <> "B" // PEDIDOS REJEITADOS = R ESTAVAM PASSANDO NA VALIDACAO - UNITHER CHAMADO 9634
            If (cAliasTRB)->C7_CONAPRO $ "L# "
               lRet := .T.
            Endif 
         ElseIf cOpcao == "TEMSLDSC7"
            If (cAliasTRB)->(C7_QUANT-C7_QUJE) >= EZ1->EZ1_QUANT
               lRet := .T.
            Endif 
         ElseIf cOpcao == "VALORUNITARIO"
            If (cAliasTRB)->C7_PRECO == EZ1->EZ1_VUNIT
               lRet := .T.
            Endif 
         Endif 
      Endif 
      (cAliasTRB)->(dbCloseArea())
  // endif 
   
Return lRet 

/*
===============================================================================================
||   Funcao: 	SELPEDCOM
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	12/01/2021
===============================================================================================
||	  Funcao que permite selecionar os pedidos de compras em aberto para o fornecedor
===============================================================================================
*/
User Function SELPEDCOM()

   Local oDlg, oBrowse, oColumn, i:=0
   Local cQuery  := ""//,cXml:="", cXMLaux:= "" //,aRefs:={}
   Local bCancel := {|| EZ1->( RecLock('EZ1',.F.) ),;
                        EZ1->( IF(FieldPos('EZ1_PEDIDO')>0,EZ1_PEDIDO:=TMPFT->C7_NUM,)),;
                        EZ1->( IF(FieldPos('EZ1_ITEMPC')>0,EZ1_ITEMPC:=TMPFT->C7_ITEM ,)),;
                        EZ1->( msUnlock() ),;
                        oDlg:End()}

   Local aHeader := { { Tt("C7_NUM")      , "C7_NUM"     , Pc("C7_NUM")    , Tm("C7_NUM")    , Dc("C7_NUM")    , Tp("C7_NUM")       },;
                      { Tt("C7_PRODUTO")  , "C7_PRODUTO" , Pc("C7_PRODUTO"), Tm("C7_PRODUTO"), Dc("C7_PRODUTO"), Tp("C7_PRODUTO")   },;
                      { Tt("C7_ITEM")     , "C7_ITEM"    , Pc("C7_ITEM")   , Tm("C7_ITEM")   , Dc("C7_ITEM")   , Tp("C7_ITEM")      },;
                      { Tt("C7_EMISSAO")  , "C7_EMISSAO" , Pc("C7_EMISSAO"), Tm("C7_EMISSAO"), Dc("C7_EMISSAO"), Tp("C7_EMISSAO")   },;
                      { Tt("C7_DATPRF")   , "C7_DATPRF"  , Pc("C7_DATPRF") , Tm("C7_DATPRF") , Dc("C7_DATPRF") , Tp("C7_DATPRF")    },;
                      { Tt("C7_QUANT")    , "C7_QUANT"   , Pc("C7_QUANT")  , Tm("C7_QUANT")  , Dc("C7_QUANT")  , Tp("C7_QUANT")     },;
                      { Tt("C7_QUJE")     , "C7_QUJE"    , Pc("C7_QUJE")   , Tm("C7_QUJE")   , Dc("C7_QUJE")   , Tp("C7_QUJE")      },;
                      { "SLD a Receber"   , "SALDO"      , Pc("C7_QUANT")  , Tm("C7_QUANT")  , Dc("C7_QUANT")  , Tp("C7_QUANT")     }}

   Default lPRODPC := .T.

   If ExistBlock("EZSC7COMP")
      cQuery := U_EZSC7COMP(EZ0->EZ0_FILIAL,EZ0->EZ0_FORNEC,EZ0->EZ0_LOJA,EZ1->EZ1_COD,EZ1->EZ1_QUANT,lPRODPC,1)
   Else
      cQuery := "SELECT C7_NUM, C7_PRODUTO, C7_ITEM, C7_EMISSAO, C7_DATPRF, C7_QUANT, C7_QUJE, C7_QUANT-C7_QUJE SALDO " + CRLF
      cQuery += "FROM " + RetSqlName("SC7") + " " + CRLF
      cQuery += "WHERE C7_FILIAL  = '" + EZ0->EZ0_FILIAL + "' " + CRLF
      cQuery += "AND   C7_FORNECE = '" + EZ0->EZ0_FORNEC + "' " + CRLF
      cQuery += "AND	  C7_LOJA    = '" + EZ0->EZ0_LOJA   + "' " + CRLF
      If !lPRODPC
         cQuery += "AND	  C7_PRODUTO = '" + EZ1->EZ1_COD    + "' " + CRLF
      Endif   
      cQuery += "AND   C7_QUANT-C7_QUJE >= " + cValToChar(EZ1->EZ1_QUANT) + CRLF
      cQuery += " AND   D_E_L_E_T_ = ' ' " + CRLF   
   Endif
   //Tela de Selecao de Despesas
   oDlg := TDialog():new()
   oDlg:nLeft     := 0
   oDlg:nTop	   := 0
   oDlg:nHeight   := 400
   oDlg:nWidth	   := 900
   oDlg:lCentered := .T.
   oDlg:lEscClose := .T.
   oDlg:oParent   := oMainWnd
   oDlg:cCaption  := "| Pedidos disponiveis para Fornecedor: " + EZ0->EZ0_FORNEC + ' | Loja: ' + EZ0->EZ0_LOJA + If(!lPRODPC," | Produto: " + Alltrim(EZ1->EZ1_COD),"") + " | Quant: " + Alltrim(Transform(EZ1->EZ1_QUANT,"@E 99999999.99")) + " | "

   oBrowse := FWBrowse():New(oDlg)
   oBrowse:SetDescription('Pedidos emitidas do produto: ' + AllTrim(EZ1->EZ1_COD) )
   oBrowse:SetDataQuery () //define que sera com query
   oBrowse:SetQuery(cQuery)
   oBrowse:SetAlias("TMPFT")
   oBrowse:DisableConfig()
   oBrowse:DisableReport()
   oBrowse:DisableFilter()

   TCSetField("TMPFT", "C7_EMISSAO", "D")
   TCSetField("TMPFT", "C7_DATPRF", "D")

   for i := 1 To len(aHeader)
      oColumn := FWBrwColumn():New()
      oColumn:SetTitle( aHeader[i,1]) //Titulo
      oColumn:SetData( &("{|| TMPFT->" + aHeader[i,2] + " }") ) //Dados
      oColumn:SetPicture( aHeader[i,3] )
      oColumn:SetSize( aHeader[i,4] )
      oColumn:SetDecimal( aHeader[i,5] )
      oColumn:SetType( aHeader[i,6])  // Tipo
      oColumn:blDblClick := bCancel
      oBrowse:SetColumns({oColumn}) //Adiciona a Coluna ao Browse
   next

   oBrowse:Activate() //Ativacao do Browse
   oDlg:Activate() //Ativacao da janela
   
Return

/*
===============================================================================================
||   Funcao: 	RetTesMat
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	28/01/2021
===============================================================================================
||	  Retorna a TES correta conforme o Tipo de Operacao
===============================================================================================
*/
User Function RetTesMat()

   Local cRet  := ""
   Local cOper := &(Readvar())

   If EZ0->EZ0_ACAO=="0"
      IF !Empty(cOper)
         cRet := MaTesInt(1,cOper,EZ0->EZ0_FORNEC,EZ0->EZ0_LOJA,'C',EZ1->EZ1_COD,"")
      Else 
         cRet := ""
      Endif 
   Else 
      IF !Empty(cOper)
         cRet := MaTesInt(2,cOper,EZ0->EZ0_CLIENT,EZ0->EZ0_LOJACL,'C',EZ1->EZ1_COD,"")
      Else 
         cRet := ""
      Endif 
   Endif 

Return cRet 


/*
===============================================================================================
||   Funcao: 	CTESpedDes
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	28/01/2021
===============================================================================================
||	  Informa os CT-e�s que estao em desacordo
===============================================================================================
*/
Static Function CTESpedDes()

Local cIdEnt		:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWS	
Local lOk 			:= .F.

cIdEnt := RetIdEnti()

// Verifica se a entidade foi configurada
If !Empty(cIdEnt)

	// Executa o metodo NfeRetornaEvento()
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN	 := "TOTVS"
	oWS:cID_ENT		 := cIdEnt
	oWS:_URL		    := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cEVENTO		 :="610110"    // Desacordo (tpEvento = 610110)
	oWS:cCHVINICIAL := EZ0->EZ0_CHVNFE
	oWS:cCHVFINAL	 := EZ0->EZ0_CHVNFE
   lOk := oWS:NFEMONITORLOTEEVENTO()

	If lOk 
		
		// Tratamento do retorno do evento
		If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U" .And. ;
		   !Empty(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) .And. ;
		   ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"

			oDados := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento[1]

			// Retorno da transmissao
			If oDados:nStatus > 2
				If oDados:nCStatEven > 0
					// Evento registrado e vinculado a NF-e
					If oDados:nCStatEven == 135
						RecLock('EZ0',.F.)
                  EZ0->EZ0_STINTE := '9'
                  EZ0->EZ0_XMLOK  := '2'	// Rejeitado
						MsUnlock()
					Endif
				Endif
			Endif
		EndIf
	EndIf
EndIf

Return



/*
===============================================================================================
||   Funcao: 	ExecEZ2
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	28/01/2021
===============================================================================================
||	  Caso encontre problema ja resolidos pelo compras, atualiza
===============================================================================================
*/
Static Function ExecEZ2()

   Local cSql      := ""
   Local cAliasTRB := GetNextAlias()
   
   dbSelectArea("EZ0")
   EZ0->(dbSetOrder(1))

   cSql := " SELECT DISTINCT EZ2_CHVNFE CHAVE FROM " + RetSqlName('EZ2') + " WHERE EZ2_FILIAL = '" + xFilial("EZ2") + "' AND D_E_L_E_T_ = ' ' AND EZ2_STATUS = '2' AND EZ2_GRUPO <> ' ' "
   dbUseArea( .T., "TOPCONN", TcGenQry(,,ChangeQuery(cSql)), cAliasTRB, .F., .T. )
   While !(cAliasTRB)->(Eof())   
      EZ0->(dbSetOrder(1))
      EZ0->(dbseek(xFilial("EZ0")+(cAliasTRB)->CHAVE))
		IF EZ0->EZ0_STINTE $ "0|2|3|4"
			VldDadosNF({EZ0->EZ0_CHVNFE,EZ0->(RECNO())})
			EZ0->(RecLock('EZ0',.F.))
			EZ0->(EZ0_STIN())
			EZ0->(msUnlock())
			If EZ0->EZ0_STINTE == '4' .And. EZ0->EZ0_XMLOK <> '1'
				If ValidaCFOP() .or. EZ0->EZ0_TIPONF == "CTe"  // quando for CTE n�o passa pelo receb fisico
					U_AndaProcesso("A",.f.)  // Gero o Documento
				Else 
					U_AndaProcesso("1",.f.) // Avanco o processo para a portaria
				Endif 
			Endif 
		Endif 
      (cAliasTRB)->(dbSkip())
   Enddo    
   (cAliasTRB)->(dbCloseArea())

Return 

/*
===============================================================================================
||   Funcao: 	EZMT116TEL
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	24/03/2022
===============================================================================================
||	  Ponto de entradea utilizado na rotina MATA116 para carregar o array aParametros
===============================================================================================
*/
User Function EZMT116TEL()

   Local lRet  := .T.

   Local aCombo1	    := {"Incluir NF de Conhec. Frete","Excluir NF de Conhec. Frete"} //"Incluir NF de Conhec. Frete"###"Excluir NF de Conhec. Frete"
   Local aCombo2	    := {"NF Normal","NF Devol./Benef."} //"NF Normal"###"NF Devol./Benef."
   Local aCombo3	    := {"N�O","SIM"} //"N?"###"Sim"
   Local aCombo4	    := {"SIM","N�O"} //"Sim"###"N?"
   Local aCombo5	    := {"N�O","SIM"} //"N?"###"Sim"
   Local aCliFor	    := {{"Fornecedor","FOR"},{"Cliente","SA1"}} //"Fornecedor"###"Cliente"
   Local nCombo1	    := 1
   Local nCombo2	    := If(l116Auto,aAutoCab[6,2],1)
   Local nCombo3	    := If(l116Auto,aAutoCab[10,2],1)
   Local nCombo4	    := 1
   Local nCombo5	    := 1
   Local n116Valor	    := 0
   Local n116BsIcmret	:= 0
   Local n116VlrIcmRet	:= 0
   Local nOpcAuto      := If(l116Auto, If(aAutoCab[3,2]==1 ,2,1),1) //1= Exclusao - 2= Inclusao
   Local nX            := 0
   Local d116DataDe    := dDataBase - 90
   Local d116DataAte   := dDataBase
   LocaL lMT116VTP:= .F.

   Local c116Combo1    := aCombo1[nCombo1]
   Local c116Combo2    := aCombo2[1]
   Local c116Combo3    := aCombo3[1]
   Local c116Combo4	  := aCombo4[1]
   Local c116Combo5    := aCombo5[1]
   Local c116FornOri   := If(l116Auto,aAutoCab[4,2],CriaVar("F1_FORNECE",.F.))
   Local c116LojaOri   := If(l116Auto,aAutoCab[5,2],CriaVar("F1_LOJA",.F.))
   Local c116NumNF	  := If(l116Auto,aAutoCab[11,2],CriaVar("F1_DOC",.F.))
   Local c116SerNF	  := If(l116Auto,aAutoCab[12,2],CriaVar(iif(SerieNfId("SF1",3,"F1_SERIE")=='F1_SDOC','F1_SDOC','F1_SERIE'),.F.))
   Local c116Fornece   := If(l116Auto,aAutoCab[13,2],CriaVar("F1_FORNECE",.F.))
   Local c116Loja	     := If(l116Auto,aAutoCab[14,2],CriaVar("F1_LOJA",.F.))
   Local c116Tes	     := If(l116Auto,aAutoCab[15,2],CriaVar("D1_TES",.F.))
   //Local lRet		     := .F.

   Local oDlg
   Local oCombo1
   Local oCombo2
   Local oCombo3
   Local oCombo4
   Local oCombo5
   Local oCliFor
   Local oFornOri
   Local o116UfOri := NIL

   Private c116UFOri	:= CriaVar("A2_EST",.F.)
   Private aValidGet	:= {}
   Private c116Especie   := If(l116Auto,aAutoCab[18,2],CriaVar("F1_ESPECIE",.F.))

   c116NumNF     := EZ0->EZ0_DOC 
   c116SerNF     := EZ0->EZ0_SERIE
   c116Fornece   := EZ0->EZ0_FORNEC
   c116Loja      := EZ0->EZ0_LOJA
   n116Valor     := EZ0->EZ0_VLDOC
   c116UfOri     := EZ0->EZ0_UFORIT
   n116BsIcmRet  := EZ1->EZ1_BRICMS
   n116VlrIcmRet := EZ1->EZ1_ICMSRE

   //Tratamento para quando n? enviar nada na TES e em vez de gerar
   //erro.log ?apresentado HELP que tes n? foi preenchida.
   If ValType(c116Tes) == "U"
      c116Tes := ""
   Endif

   //Ponto de Entrada para manipular o valor do frete
   If (ExistBlock("MT116VAL"))
      n116Valor := ExecBlock("MT116VAL",.F.,.F.,{n116Valor})
      If ValType(n116Valor) <> "N"
         n116Valor := 0
      EndIf
   EndIf

   //Ponto de Entrada que Permite manipular a Consulta padr]ao que ser?
   //utilizada para F3 FORNECEDOR e CLIENTE   
   If (ExistBlock("MT116F3"))
      a116F3 := ExecBlock("MT116F3",.F.,.F.)
      If ValType(a116F3)<>"A" .Or. Len(a116F3) == 0 .Or. Len(a116F3)>2
         A116F3:={}  
      Else   
         For nX = 1 to Len(a116F3)
            aCliFor[nX][2]=a116F3[nX]
         Next Nx
      EndIf   
   EndIf

   //Ponto de Entrada para manipular o valor padrao da pergunta "Aglutina produtos?"
   If (ExistBlock("MT116AGL"))
      c116Combo4 := ExecBlock("MT116AGL", .F., .F., {aCombo4})
      If ValType(c116Combo4) # "C" .Or. !(aScan(aCombo4, c116Combo4) > 0)
         c116Combo4 := aCombo4[1] // padrao = "Sim"
      EndIf
      nCombo4 := aScan(aCombo4, c116Combo4)
   EndIf		 

   If !( l116Auto )
      DEFINE MSDIALOG oDlg FROM 87 ,52  TO 500/*450*/,609 TITLE "Parametros "+cCadastro Of oMainWnd PIXEL //"Parametros "
      //Par?etros para Filtro
      @ 22 ,3   TO 68 ,274 LABEL "Parametros do Filtro" OF oDlg PIXEL //"Parametros do Filtro"
      @ 6 ,48  MSCOMBOBOX oCombo1 VAR c116Combo1 ITEMS aCombo1 SIZE 83 ,50 OF oDlg PIXEL VALID (nCombo1:=aScan(aCombo1,c116Combo1))
      @ 7  ,6   SAY "Quanto a Nota" Of oDlg PIXEL SIZE 43,09 //"Quanto a Nota"
      @ 7  ,140 SAY "Filtrar notas com conhecimento de frete" Of oDlg PIXEL SIZE 100 ,9 //"Filtrar notas com conhecimento de frete"
      @ 7  ,245 MSCOMBOBOX oCombo5 VAR c116Combo5 ITEMS aCombo5 SIZE 30 ,50 OF oDlg PIXEL When (nCombo1==1) VALID (nCombo5:=aScan(aCombo5,c116Combo5))
      @ 34 ,12  SAY "Data Inicial" Of oDlg PIXEL SIZE 60 ,9 //"Data Inicial"
      @ 34 ,125 SAY "Data Final" Of oDlg PIXEL SIZE 59 ,9 //"Data Final"
      @ 33 ,48  MSGET d116DataDe  Valid !Empty(d116DataDe) OF oDlg PIXEL SIZE 60 ,9
      @ 33 ,165 MSGET d116DataAte Valid !Empty(d116DataAte) OF oDlg PIXEL SIZE 60 ,9
      
      @ 52  ,12 SAY "Considerar" Of oDlg PIXEL SIZE 54 ,9 //"Considerar"
      @ 51  ,48 MSCOMBOBOX oCombo2 VAR c116Combo2 ITEMS aCombo2 SIZE 60 ,50 OF oDlg PIXEL When (nCombo1==1) VALID ((nCombo2:=aScan(aCombo2,c116Combo2)),oCliFor:Refresh(),oFornOri:cF3:=aCliFor[nCombo2][2],c116FornOri:=SPACE(Len(c116FornOri)),c116LojaOri:=SPACE(Len(c116LojaOri)))
      
      @ 52 ,125 SAY oCliFor VAR aCliFor[nCombo2][1] Of oDlg PIXEL SIZE 28 ,9
      @ 51 ,165 MSGET oFornOri VAR c116FornOri Picture PesqPict("SA2","A2_COD") F3 aCliFor[nCombo2][2];
               OF oDlg PIXEL SIZE 80 ,9 VALID Empty(c116FornOri).Or.A116StpVld(nCombo2,c116FornOri,@c116LojaOri,,1)
               
      @ 51 ,245  MSGET c116LojaOri Picture PesqPict("SA2","A2_LOJA") F3 CpoRetF3("A2_LOJA");
               OF oDlg PIXEL SIZE 19 ,9 VALID A116StpVld(nCombo2,c116FornOri,c116LojaOri,,1)
         
      //Dados para Nf Conhecimento de Frete
      @ 74 ,3   TO 180/*160*/,274 LABEL "Dados da NF de Frete" OF oDlg PIXEL //"Dados da NF de Frete"
      @ 86 ,10  SAY "Form. Proprio" Of oDlg PIXEL SIZE 39 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Form. Proprio"
      @ 85 ,47  MSCOMBOBOX oCombo3 VAR c116Combo3 ITEMS aCombo3 SIZE 35 ,50 OF oDlg PIXEL When (nCombo1==1) VALID ((nCombo3:=aScan(aCombo3,c116Combo3)),c116NumNF:=SPACE(Len(c116NumNF)),c116SerNF:=SPACE(Len(c116SerNF)))
      
      @ 86 ,125 SAY "Num. Conhec." Of oDlg PIXEL SIZE 39 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Num. Conhec."
      @ 85 ,165 MSGET c116NumNF Picture PesqPict("SF1","F1_DOC") OF oDlg PIXEL SIZE 50 ,9 When (nCombo1==1.And.nCombo3==1) VALID A116NCF(@c116NumNF).And.A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)
      
      @ 86 ,225 SAY "Serie" Of oDlg PIXEL SIZE 15 ,9  //"Serie"
      @ 85 ,242 MSGET c116SerNF Picture PesqPict("SF1","F1_SERIE") OF oDlg PIXEL SIZE 19 ,9  When (nCombo1==1.And.nCombo3==1) VALID A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)

      @ 105,10  SAY "Fornecedor" Of oDlg PIXEL SIZE 47 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Fornecedor"
      @ 104,47  MSGET c116Fornece  Picture PesqPict("SF1","F1_FORNECE") F3 aCliFor[1][2] ;
            OF oDlg PIXEL SIZE 80 ,9 When (nCombo1==1) VALID A116StpVld(1,c116Fornece,@c116Loja,@c116UfOri,2).And.A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF)

      @ 104,128  MSGET c116Loja Picture PesqPict("SF1","F1_LOJA") F3 CpoRetF3("F1_LOJA");
               OF oDlg PIXEL SIZE 19 ,9 When (nCombo1==1) VALID A116StpVld(1,c116Fornece,c116Loja,@c116UfOri,2).And.A116ChkNFE(nCombo3,c116Fornece,c116Loja,c116NumNF,c116SerNF).And.A116ChkTra(c116Fornece,c116Loja,c116FornOri,c116LojaOri)

      @ 105,152 SAY "Cod. TES" Of oDlg PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //"Cod. TES"
      @ 104,175 MSGET c116TES Picture PesqPict("SD1","D1_TES") F3 CpoRetF3("D1_TES");
               OF oDlg PIXEL SIZE 25 ,9 When (nCombo1==1) VALID  (Empty(c116Tes) .Or. ExistCpo("SF4",c116Tes)) .And. A116ChkTES(c116TES)

      @ 105,205 SAY " Valor" Of oDlg PIXEL SIZE 33 ,9 COLOR CLR_HBLUE,oDlg:nClrPane //" Valor"
      @ 104,220 MSGET n116Valor Picture PesqPict("SD1","D1_TOTAL") ;
               OF oDlg PIXEL SIZE 51 ,9 When (nCombo1==1)

      @ 125,10  SAY "UF Origem" Of oDlg PIXEL SIZE 36 ,9 //"UF Origem"
      @ 124,47  MSGET o116UfOri VAR c116UfOri Picture PesqPict("SA2","A2_EST") F3 CpoRetF3("A2_EST");
               OF oDlg PIXEL SIZE 25 ,9 	When (nCombo1==1) VALID A116StpVld(1,c116Fornece,@c116Loja,@c116UfOri,2) .And. ExistCPO("SX5","12"+c116UFOri) .Or. Vazio(c116UFOri)
               If(lLGPD,OfuscaLGPD(o116UfOri,"A2_EST"),.F.) 
               
      @ 125,120 SAY "Aglutina Produtos ?" Of oDlg PIXEL SIZE 48 ,9 //"Aglutina Produtos ?"
      @ 125,180 MSCOMBOBOX oCombo4 VAR c116Combo4 ITEMS aCombo4 SIZE 30 ,50 OF oDlg PIXEL When (nCombo1==1) VALID (nCombo4:=aScan(aCombo4,c116Combo4))
      
      @ 146,10  SAY "Bs Icms Ret." Of oDlg PIXEL SIZE 49 ,9 //"Bs Icms Ret."
      @ 144,47  MSGET oGetBs VAR n116BsIcmRet  Picture PesqPict("SD1","D1_BRICMS") F3 CpoRetF3("D1_BRICMS");
               OF oDlg PIXEL SIZE 70 ,9 When (nCombo1==1) VALID Positivo(n116BsIcmRet)

      @ 144,140 SAY "Vlr. Icms Ret." Of oDlg PIXEL SIZE 41 ,9 //"Vlr. Icms Ret."
      @ 143,180 MSGET n116VlrIcmRet Picture PesqPict("SD1","D1_ICMSRET") F3 CpoRetF3("D1_ICMSRET");
               OF oDlg PIXEL SIZE 70 ,9 When (nCombo1==1) VALID Positivo(n116VlrIcmRet)
               
      @ 166,10  SAY "Especie:" Of oDlg PIXEL SIZE 49 ,9 //"Bs Icms Ret."
      @ 164,47  MSGET oGetBs VAR c116Especie  Picture PesqPict("SF1","F1_ESPECIE") F3 CpoRetF3("F1_ESPECIE");
               OF oDlg PIXEL SIZE 25 ,9 COLOR CLR_HBLUE,oDlg:nClrPane When (nCombo1==1) VALID CheckSX3("F1_ESPECIE",c116Especie)

      @188,220 BUTTON "Confirma >>" SIZE 35 ,10  FONT oDlg:oFont ACTION If(A116StpOk(c116NumNF,c116Fornece,c116Loja,c116Tes,c116FornOri,c116LojaOri,nCombo1,n116Valor,nCombo3),(lRet:=.T.,oDlg:End()),Nil)  OF oDlg PIXEL //"Confirma >>"
      @188,180 BUTTON "<< Cancelar" SIZE 35 ,10  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL //"<< Cancelar"

      ACTIVATE MSDIALOG oDlg CENTERED
   Else
      If Type("aParametros") == "A" 
         If nCombo1 == 1
            // criacao da aValidGet
            aValidGet := {}
            Aadd(aValidGet,{"c116FornOri",aAutoCab[ 4,2],"Empty('"+c116FornOri+"') .Or. A116StpVld("+Str(nCombo2,1)+",'"+c116FornOri+"','"+c116LojaOri+"',,1)",.F.})
            Aadd(aValidGet,{"c116LojaOri",aAutoCab[ 5,2],"Empty('"+c116LojaOri+"') .Or. A116StpVld("+Str(nCombo2,1)+",'"+c116FornOri+"','"+c116LojaOri+"',,1)",.F.})
            Aadd(aValidGet,{"c116NumNF"  ,aAutoCab[11,2],"A116ChkNFE("+Str(nOpcAuto,1)+",'"+c116Fornece+"','"+c116Loja+"','"+c116NumNF+"','"+c116SerNF+"')",.F.})
            Aadd(aValidGet,{"c116SerNF"  ,aAutoCab[12,2],"A116ChkNFE("+Str(nOpcAuto,1)+",'"+c116Fornece+"','"+c116Loja+"','"+c116NumNF+"','"+c116SerNF+"')",.F.})
            Aadd(aValidGet,{"c116Fornece",aAutoCab[13,2],"A116StpVld(1,'"+c116Fornece+"','"+c116Loja+"',@c116UfOri,2) .And. A116ChkNFE("+Str(nOpcAuto,1)+",'"+c116Fornece+"','"+c116Loja+"','"+c116NumNF+"','"+c116SerNF+"')",.F.})
            Aadd(aValidGet,{"c116Loja"   ,aAutoCab[14,2],"A116StpVld(1,'"+c116Fornece+"','"+c116Loja+"',@c116UfOri,2) .And. A116ChkNFE("+Str(nOpcAuto,1)+",'"+c116Fornece+"','"+c116Loja+"','"+c116NumNF+"','"+c116SerNF+"')",.F.})
            If nOpcAuto == 1  
               Aadd(aValidGet,{"c116Tes"	  ,aAutoCab[15,2],"!Empty('"+c116Tes+"')",.F.})
            EndIf	
            lRet := SF1->(MsVldGAuto(aValidGet)) // consiste os gets
         Else
            lRet := .T.
         EndIf
      EndIf
   EndIf	

   nCombo1:= If(nCombo1==1,2,1)

   aParametros:= {	nCombo1,; // 1 Define a Rotina : 1-Inclusao / 2-Exclusao
      nCombo2,; 		      // 2 Considerar Notas : 1 - Compra , 2 - Devolucao
      d116DataDe,; 		  // 3 Data Inicial para Filtro das NF Originais
      d116DataAte,;		  // 4 Data Final para Filtro das NF originais
      c116FornOri,;		  // 5 Cod. Fornecedor para Filtro das NF Originais
      c116LojaOri,;		  // 6 Loja Fornecedor para Fltro das NF Originais
      nCombo3,; 			  // 7 Utiliza Formulario proprio ? 1-Sim,2-Nao
      c116NumNF,;  		  // 8 Num. da NF de Conhecimento de Frete
      c116SerNF,;  		  // 9 Serie da NF de COnhecimento de Frete
      c116Fornece,;		  // 10 Codigo do Fornecedor da NF de FRETE
      c116Loja,;   		  // 11 Loja do Fornecedor da NF de Frete
      c116Tes,;    		  // 12 Tes utilizada na Classificacao da NF
      n116Valor,;  		  // 13 Valor total do Frete sem Impostos
      c116UFOri,;  		  // 14 Estado de Origem do Frete
      (nCombo4==1),; 		  // 15 Aglutina Produtos : .T. , .F.
      n116BsIcmRet,;	      // 16 Base do Icms Retido
      n116VlrIcmRet,;		  //17 Valor do Icms Retido
      (nCombo5==2),;  	  //18 Filtra nota com conhecimento frete .F. , .T.
      c116Especie,;		  //19 Especie da Nota Fiscal
      }

   //Pontos de Entrada para ponto de entrada de valida?o da tela de par?etros
   If lRet .And. ExistBlock("MT116VTP")
      lMT116VTP:= ExecBlock("MT116VTP",.F.,.F.,{aParametros} )
      If ValType(lMT116VTP) = "L"
            lRet := lMT116VTP
         EndIf
   EndIf

Return lRet

/*

   Local lRet  := .T.

   If FWIsInCallStack("U_PORTAL_XML")

      aParametros := {}
      aParametros:= {	MV_PAR01,;              //  1 Define a Rotina : 1-Inclusao / 2-Exclusao
                        MV_PAR02,; 		         //  2 Considerar Notas : 1 - Compra , 2 - Devolucao
                        MV_PAR03,; 		         //  3 Data Inicial para Filtro das NF Originais
                        MV_PAR04,;		            //  4 Data Final para Filtro das NF originais
                        MV_PAR08,;		            //  5 Cod. Fornecedor para Filtro das NF Originais
                        MV_PAR09,;		            //  6 Loja Fornecedor para Fltro das NF Originais
                        MV_PAR05,; 			      //  7 Utiliza Formulario proprio ? 1-Sim,2-Nao
                        EZ0->EZ0_DOC,; 	         //  8 Num. da NF de Conhecimento de Frete
                        EZ0->EZ0_SERIE,;  		   //  9 Serie da NF de COnhecimento de Frete
                        EZ0->EZ0_FORNEC,;		   // 10 Codigo do Fornecedor da NF de FRETE
                        EZ0->EZ0_LOJA,;   		   // 11 Loja do Fornecedor da NF de Frete
                        EZ1->EZ1_TES,;    		   // 12 Tes utilizada na Classificacao da NF
                        EZ0->EZ0_VLDOC,;  		   // 13 Valor total do Frete sem Impostos
                        EZ0->EZ0_UFORIT,;  		   // 14 Estado de Origem do Frete
                        (MV_PAR06==1),; 		      // 15 Aglutina Produtos : .T. , .F.
                        EZ1->EZ1_BRICMS,;	      // 16 Base do Icms Retido
                        EZ1->EZ1_ICMSRE,;		   // 17 Valor do Icms Retido
                        (MV_PAR07==2),;  	      // 18 Filtra nota com conhecimento frete .F. , .T.
                        EZ0->EZ0_ESPECI,;		   // 19 Especie da Nota Fiscal
                     }

   Else 

		If !U_A116Setup(@aParametros)
			lRet := .F.
		EndIf

   Endif 
*/



/*
===============================================================================================
||   Funcao: 	PPLoadRefXML
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	28/01/2021
===============================================================================================
||	  Carrega de forma automatica quando existe apenas uma nota referenciada
===============================================================================================
*/
User Function PPLoadRefXML()

   Local cRet      := ''
   Local cXml      := ''
   Local cXMLaux   := ''
   Local aRefs     := {}
   Local cSql      := ''
   Local cAliasSF2 := ''

   cXml:=XML_Limpa( AllTrim(EZ0->EZ0_XMLNFE) ) 
   cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) )
   while !empty(cXMLaux) 
         while !empty(cXMLaux)
               aAdd(aRefs,XMLTagCont( 'refNFe', cXMLaux ) )          // guarda o item
               cXMLaux:= StrTran(cXMLaux,XMLTagCompl('refNFe',cXMLaux),"") // Elimina o item do XML para evitar repeticoes
         end
         cXml:= StrTran(cXml,XMLTagCompl('NFref', cXml ),"") // Elimina o item do XML para evitar repeticoes
         cXMLaux:=XML_Limpa( XMLTagCont( 'NFref', cXml ) ) //pega a proxima referencia
   end
   
   If Len(aRefs) == 1
      cAliasSF2 := GetNextAlias()
      cSql := "SELECT D2_DOC, D2_SERIE, D2_ITEM, D2_IDENTB6, D2_LOTECTL, D2_NUMLOTE " + ENTER
      cSql += "  FROM " + RetSqlName('SD2') + " D2 " + ENTER
      cSQL += " INNER JOIN " + RetSqlName('SF2') + " F2 ON F2.F2_FILIAL = D2.D2_FILIAL AND F2.F2_DOC= D2.D2_DOC AND F2.F2_SERIE = D2.D2_SERIE " + ENTER
      cSql += " WHERE D2.D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
      cSql += "   AND D2.D_E_L_E_T_ <> '*' " + ENTER
      cSql += "   AND D2.D2_COD = '"+AllTrim(EZ1->EZ1_COD)+"' " + ENTER
      cSql += "   AND D2_QUANT - D2.D2_QTDEDEV >= " + cValToChar(EZ1->EZ1_QUANT) + " " + ENTER
      cSql += "   AND F2.F2_CHVNFE = '" + aRefs[1] + "' " + ENTER
      cSql += "   AND F2.D_E_L_E_T_ <> '*'  " + ENTER
      DBUseArea(.T., "TOPCONN", TCGenQry( , , cSql), (cAliasSF2), .F., .T.)
      If !(cAliasSF2)->(Eof())         
         EZ1->EZ1_NFORI  := (cAliasSF2)->D2_DOC 
         EZ1->EZ1_SERIOR := (cAliasSF2)->D2_SERIE
         EZ1->EZ1_ITEMOR := (cAliasSF2)->D2_ITEM
         If EZ1->(FieldPos("EZ1_IDB6"))  > 0 
            EZ1->EZ1_IDB6 := (cAliasSF2)->D2_IDENTB6
         Endif 
         If EZ1->(FieldPos("EZ1_LOTECT"))  > 0 
            EZ1->EZ1_LOTECT := (cAliasSF2)->D2_LOTECTL
         Endif 
         If EZ1->(FieldPos("EZ1_NUMLOT"))  > 0 
            EZ1->EZ1_NUMLOT := (cAliasSF2)->D2_NUMLOTE
         Endif 
         cRet := (cAliasSF2)->D2_DOC
      Endif
      (cAliasSF2)->(dbCloseArea())
   Endif 

Return cRet

/*------------------------------------------------------------------------------------------------
//    Autor: Marcio Martins Pereira
// 	   Onde: Portal XML
// Objetivo: Checar se a chave da nota esta valida
	    Uso: U_PPVAlidaXml("CHAVE_AAAAAAAAAAAAAAAAAAAAAAA")
//------------------------------------------------------------------------------------------------*/

User Function PPVAlidaXml(cChaveNFe)   

	Local aArea      := GetArea()
	Local lRet       := .T.
	Local lValida	  := .T.
	Local cURL       := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
	Local cMsg       := ""
	Local oWsdl      := Nil
	Local cMsgRet    := ""
	Local cError     := ""
	Local cWarning   := ""
	Local cUfAutor   := ""
	Local cTpAmb     := ""
	Local cCNPJEmp   := ""
	Local lContinua  := .T.
	Local cLocCert   := '\certs\'
	Local cCert		  := ''
	Local cCert_ca	  := ''
	Local cCert_cert := ''
	Local cCert_key  := ''

	Private cChvNfe	:= ""
	Private oXmlDocZip
	Private cUnXML	:= ''
	Private cOrigem := ''

   Private lDblCheck  := SuperGetMV("EZ_DBCHECK",.F.,.F.)    // Double Check SEFAZ

   If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpant == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)
      Return .T.
   Endif 

   If Empty(EZ0->EZ0_CNPJEM)  // 11/08/2021 - Marcio M. -> Pulo as notas de importacao, pois nao tem necessidade de consultar SEFAZ
      lDblCheck := .F.
      Return .T.
   Endif 

   If EZ0->EZ0_STINTE == '9'
      MsgAlert("Chave/Danfe Rejeitada, Informe ao Departamento Fiscal")
      Return .F. 
   Endif 

   If EZ0->(FieldPos("EZ0_LIBSEF")) > 0 
      If !Empty(EZ0->EZ0_LIBSEF)
         Return .T.
      Endif 
   Endif
   If lDblCheck
   
      If !CTIsReady()        

         MsgAlert("Verifique se o TSS esta ativado")
         lValida := .F.
      
      Else 

         cCert		 := Alltrim(retIdEnti())

         cCert_ca     := cLocCert+cCert+"_ca.pem"
         cCert_cert   := cLocCert+cCert+"_cert.pem"
         cCert_key    := cLocCert+cCert+"_key.pem"
         nSSLVersion  := 0  // mudei aqui
         lSSLInsecure := .T.

         If !File(cCert_ca)
            MsgAlert("Os arquivos do certificado digital devem constam na pasta: "+cLocCert)
            return
         Endif 

         cUFAutor := RetCodUf()
         cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
         cCNPJEmp  := SM0->M0_CGC	//'18666055000109'	 // vistra

         //Inst�ncia a classe, setando as par�metrizac�es necessarias
         oWsdl := TWsdlManager():New()
         oWsdl:cSSLCACertFile := cCert_ca
         oWsdl:cSSLCertFile   := cCert_cert
         oWsdl:cSSLKeyFile    := cCert_key
         oWsdl:nSSLVersion    := nSSLVersion
         oWsdl:lSSLInsecure   := lSSLInsecure
         oWsdl:nTimeout       := 120
         
         //Tenta fazer o Parse da URL
         lRet := oWsdl:ParseURL(cURL)
         If !lRet 
            ConOut("[U_PPVAlidaXml] - Erro ParseURL: " + oWsdl:cError)
            MsgAlert("O Certificado Digital "+ cCert + " pode estar vencido ou nao se encontra na pasta, solicite atualizacao da pasta '\CERTS\'")
            lContinua := .F.
         EndIf

         //Se for continuar o processamento
         If lContinua

            //Tenta definir a operacao
            lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
            If ! lRet 
               ConOut("[U_PPVAlidaXml] - Erro SetOperation: " + oWsdl:cError)
               lContinua := .F.
            EndIf
            
         EndIf
            
         //Se for continuar
         If lContinua
            //Monta a mensagem que sera enviada
            cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
            cMsg += '    <soapenv:Header/>'                                                                             + CRLF
            cMsg += '    <soapenv:Body>'                                                                                + CRLF
            cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
            cMsg += '                <nfeDadosMsg>'                                                                     + CRLF
            cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'         + CRLF
            cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                 + CRLF
            cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                            + CRLF
            cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                 + CRLF
            cMsg += '                      <consChNFe>'                                                                 + CRLF
            cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                  + CRLF
            cMsg += '                      </consChNFe>'                                                                + CRLF
            cMsg += '                    </distDFeInt>'                                                                 + CRLF
            cMsg += '                </nfeDadosMsg>'                                                                    + CRLF
            cMsg += '            </nfeDistDFeInteresse>'                                                                + CRLF
            cMsg += '        </soapenv:Body>'                                                                           + CRLF
            cMsg += '    </soapenv:Envelope>'                                                                           + CRLF

            //Envia uma mensagem SOAP personalizada ao servidor
            oWsdl:lProcResp := .F.
            lRet := oWsdl:SendSoapMsg(cMsg)
            If ! lRet 
               ConOut("[U_PPVAlidaXml] - Erro SendSoapMsg: " + oWsdl:cError)
               ConOut("[U_PPVAlidaXml] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
               lContinua := .F.
            EndIf
         
         EndIf
         
         //Se for continuar
         If lContinua
            //Pega a resposta do SOAP
            cMsgRet := oWsdl:GetSoapResponse()
                              
            //Transforma a resposta em um objeto
            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
               
            //Se existir Warning, mostra no console.log
            If ! Empty(cWarning)
               ConOut("[U_PPVAlidaXml] - Alerta cWarning: " + cWarning)
            EndIf
               
            //Se houve erro, nao permitira prosseguir
            If ! Empty(cError)
               ConOut("[U_PPVAlidaXml] - Erro cError: " + cError)
               lContinua := .F.
            EndIf
            
         EndIf
         
         If lContinua

            //Se a tag DocZip existir (for diferente de Undefinied)
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U")	
               cXConteudo := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
               cXMotivo   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
               If !cXConteudo $ '100|138'   // Autorizado o uso da NF-e | Documento Localizado
                  RecLock("EZ0",.F.)
                  EZ0->EZ0_STINTE := '9'
                  EZ0->EZ0_XMLOK  := '2'	// Rejeitado
                  MsUnlock()    
                  U_RegLogUser('G', U_RegLogUser('G', cXConteudo + "-" + cXMotivo))
                  lValida := .F.
               Else 
                  lValida := .T.
               EndIf
            Endif
            
         EndIf
      
      Endif 

   Endif 

	
	RestArea(aArea)

return lValida


//--------------------------------------------------------
User Function EZPosicione(cAlias,nOrdem,cChaveBusca,cCamposBusca,cRetorno)

   Local aAreaAlias := (cAlias)->(GetArea())
   Local cRet  := ''
   Local cPref := If(SubStr(cAlias,1,1)=="S",SubStr(cAlias,2,2),cAlias)

   dbSelectArea((cAlias))
   (cAlias)->(dbSetOrder(nOrdem))
   If (cAlias)->(dbSeek(cChaveBusca))
      While !(cAlias)->(Eof()) .And. (cAlias)->&((cCamposBusca)) == cChaveBusca
         If (cAlias)->&(cPref+"_MSBLQL")<>"1"
            cRet := (cAlias)->&(cRetorno)
            exit 
         Endif         
         (cAlias)->(dbSkip())
      Enddo 
   Endif 

   RestArea(aAreaAlias)

Return cRet 


//--------------------------------------------------------
User Function EZConv2UM(cProd,cUM2,nQuant,nVunit,nTotal)

   Local aRet      := {'',nQuant, nVunit, nTotal}
   Local nVrRet    := 0 
   Local nQtdeRet  := 0 
   Local nTotalRet := 0

   cUM2 := Upper(cUM2)

   If !Empty(cUM2)
      dbSelectArea('SB1')
      SB1->(dbSetOrder(1))
      IF SB1->(dbSeeK(xFilial('SB1')+cProd))
         IF SB1->B1_UM <> cUM2 .And. SB1->B1_SEGUM == cUM2
            IF SB1->B1_CONV > 0
               IF SB1->B1_TIPCONV == 'D'
                  nQtdeRet  := nQuant*SB1->B1_CONV
                  nVrRet    := nVunit/SB1->B1_CONV
                  nTotalRet := nQtdeRet*nVrRet
               Else                   
                  nQtdeRet := nQuant/SB1->B1_CONV 
                  nVrRet   := nVunit*SB1->B1_CONV
                  nTotalRet := nQtdeRet*nVrRet
               Endif 
               aRet[1] := SB1->B1_SEGUM
               aRet[2] := nQtdeRet
               aRet[3] := nVrRet
               aRet[4] := nTotalRet
            Endif 
         Endif
      Endif 
   Endif

Return aRet

//--------------------------------------------------------
// 28/06/2022 - Carla Barbosa
// Criado para fazer a convers�o da segunda unidade de medida
// consultando Amarra��o Prod x Forn sen�o tiver ai consulta Prod
//--------------------------------------------------------
//--------------------------------------------------------
User Function EZConvA5(CCODFOR, CLOJFOR,cProd,cUM2,nQuant,nVunit,nTotal)
   Local aRet      := {'',nQuant, nVunit, nTotal}
   Local nVrRet    := 0 
   Local nQtdeRet  := 0 
   Local nTotalRet := 0
   cUM2 := Upper(cUM2)
   If !Empty(cUM2)
      dbSelectArea('SB1')
      SB1->(dbSetOrder(1))
      IF SB1->(dbSeeK(xFilial('SB1')+cProd))
         dbselectarea("SA5")
         SA5->(dbsetorder(1))
         if SA5->(dbSeek(xFilial("SA5")+CCODFOR+CLOJFOR+cProd))
            IF !Empty(SA5->A5_UNID) .and. SB1->B1_UM <> SA5->A5_UNID .And. SA5->A5_UNID == cUM2
               IF SA5->A5_CONV  > 0
                  IF SA5->A5_TIPCONV  == 'D'
                     nQtdeRet  := nQuant*SA5->A5_CONV
                     nVrRet    := nVunit/SA5->A5_CONV
                     nTotalRet := nQtdeRet*nVrRet
                  Else                   
                     nQtdeRet := nQuant/SA5->A5_CONV 
                     nVrRet   := nVunit*SA5->A5_CONV
                     nTotalRet := nQtdeRet*nVrRet
                  Endif 
                  aRet[1] := SA5->A5_UNID
                  aRet[2] := nQtdeRet
                  aRet[3] := nVrRet
                  aRet[4] := nTotalRet
               Endif 
            Elseif SB1->B1_UM <> cUM2 .And. SB1->B1_SEGUM == cUM2 
               IF SB1->B1_CONV > 0
                  IF SB1->B1_TIPCONV == 'D'
                     nQtdeRet  := nQuant*SB1->B1_CONV
                     nVrRet    := nVunit/SB1->B1_CONV
                     nTotalRet := nQtdeRet*nVrRet
                  Else                   
                     nQtdeRet := nQuant/SB1->B1_CONV 
                     nVrRet   := nVunit*SB1->B1_CONV
                     nTotalRet := nQtdeRet*nVrRet
                  Endif 
                  aRet[1] := SB1->B1_SEGUM
                  aRet[2] := nQtdeRet
                  aRet[3] := nVrRet
                  aRet[4] := nTotalRet         
               Endif
            Endif
         elseif SB1->B1_UM <> cUM2 .And. SB1->B1_SEGUM == cUM2 
            IF SB1->B1_CONV > 0
               IF SB1->B1_TIPCONV == 'D'
                  nQtdeRet  := nQuant*SB1->B1_CONV
                  nVrRet    := nVunit/SB1->B1_CONV
                  nTotalRet := nQtdeRet*nVrRet
               Else                   
                  nQtdeRet := nQuant/SB1->B1_CONV 
                  nVrRet   := nVunit*SB1->B1_CONV
                  nTotalRet := nQtdeRet*nVrRet
               Endif 
               aRet[1] := SB1->B1_SEGUM
               aRet[2] := nQtdeRet
               aRet[3] := nVrRet
               aRet[4] := nTotalRet         
            Endif        
         Endif
      Endif 
   Endif
Return aRet

//--------------------------------------------------------
// 19/10/2021 - Marcio martins
// Criado para liberar notas que esta validas na SEFAZ
// mas que a consulta retorna rejeitada ou nao encontrada
//--------------------------------------------------------
User Function LibSefaz()

   RecLock("EZ0",.F.)
   EZ0->EZ0_LIBSEF := 'S'
   EZ0->EZ0_XMLOK  := '1'
   If EZ0->EZ0_STINTE == '9'
      EZ0->EZ0_STINTE := '2'      
      EZ0->( EZ0_STIN()  )
   Endif 
   MsUnlock()  

Return 
//--------------------------------------------------------
User Function CheckSefaz()


	Local aArea      := GetArea()
	Local lRet       := .T.
//	Local lValida	 := .F.
	Local cURL       := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
	Local cMsg       := ""
	Local oWsdl      := Nil
	Local cMsgRet    := ""
	Local cError     := ""
	Local cWarning   := ""
	Local cUfAutor   := ""
	Local cTpAmb     := ""
	Local cCNPJEmp   := ""
	Local lContinua  := .T.
	Local cLocCert   := '\certs\'
	Local cCert		  := Alltrim(retIdEnti())
	Local cCert_ca	  := ''
	Local cCert_cert := ''
	Local cCert_key  := ''
//	Local cConteudo  := ''
   Local cChaveNFe  := EZ0->EZ0_CHVNFE
	Local  oXmlDocZip
   Local cXConteudo := ''
   Local cXMotivo   := '' 

	cCert_ca     := SuperGetMV("EZ_PCERTCA", .F., cLocCert+cCert+"_ca.pem")
	cCert_cert   := SuperGetMV("EZ_PCERT", .F., cLocCert+cCert+"_cert.pem")
	cCert_key    := SuperGetMV("EZ_PKEY", .F., cLocCert+cCert+"_key.pem")
	nSSLVersion  := SuperGetMV("EZ_BXVERSA", .F., "0")
	lSSLInsecure := SuperGetMV("EZ_BXSSLIN", .F., .T.)

	If !File(cCert_ca)
		MsgAlert("Os arquivos do certificado digital devem constar na pasta: "+cLocCert)
		return
	Endif 

	cUFAutor := RetCodUf()
	cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
	cCNPJEmp  := SM0->M0_CGC	//'18666055000109'	 // vistra

	//Inst�ncia a classe, setando as par�metrizac�es necessarias
	oWsdl := TWsdlManager():New()
	oWsdl:cSSLCACertFile := cCert_ca
	oWsdl:cSSLCertFile   := cCert_cert
	oWsdl:cSSLKeyFile    := cCert_key
	oWsdl:nSSLVersion    := nSSLVersion
	oWsdl:lSSLInsecure   := lSSLInsecure
	oWsdl:nTimeout       := 120
	
	//Tenta fazer o Parse da URL
	lRet := oWsdl:ParseURL(cURL)
	If !lRet 
		MsgAlert("O Certificado Digital "+ cCert + " pode estar vencido ou nao se encontra na pasta, solicite atualizacao da pasta '\CERTS\'")
		lContinua := .F.
	EndIf

	//Se for continuar o processamento
	If lContinua

		//Tenta definir a operacao
		lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
		If ! lRet 
			ConOut("[U_PPVAlidaXml] - Erro SetOperation: " + oWsdl:cError)
			lContinua := .F.
		EndIf
		
	EndIf
		
	//Se for continuar
	If lContinua
		//Monta a mensagem que sera enviada
		cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
		cMsg += '    <soapenv:Header/>'                                                                             + CRLF
		cMsg += '    <soapenv:Body>'                                                                                + CRLF
		cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
		cMsg += '                <nfeDadosMsg>'                                                                     + CRLF
		cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'         + CRLF
		cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                 + CRLF
		cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                            + CRLF
		cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                 + CRLF
		cMsg += '                      <consChNFe>'                                                                 + CRLF
		cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                  + CRLF
		cMsg += '                      </consChNFe>'                                                                + CRLF
		cMsg += '                    </distDFeInt>'                                                                 + CRLF
		cMsg += '                </nfeDadosMsg>'                                                                    + CRLF
		cMsg += '            </nfeDistDFeInteresse>'                                                                + CRLF
		cMsg += '        </soapenv:Body>'                                                                           + CRLF
		cMsg += '    </soapenv:Envelope>'                                                                           + CRLF

		//Envia uma mensagem SOAP personalizada ao servidor
		oWsdl:lProcResp := .F.
		lRet := oWsdl:SendSoapMsg(cMsg)
		If ! lRet 
			ConOut("[U_PPVAlidaXml] - Erro SendSoapMsg: " + oWsdl:cError)
			ConOut("[U_PPVAlidaXml] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
			lContinua := .F.
		EndIf
	
	EndIf
	
	//Se for continuar
	If lContinua
		//Pega a resposta do SOAP
		cMsgRet := oWsdl:GetSoapResponse()
								
		//Transforma a resposta em um objeto
		oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
			
		//Se existir Warning, mostra no console.log
		If ! Empty(cWarning)
			ConOut("[U_PPVAlidaXml] - Alerta cWarning: " + cWarning)
		EndIf
			
		//Se houve erro, nao permitira prosseguir
		If ! Empty(cError)
			ConOut("[U_PPVAlidaXml] - Erro cError: " + cError)
			lContinua := .F.
		EndIf
		  
      //Se for continuar
      If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U"
         cXConteudo := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
         cXMotivo   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
         MsgAlert("Codigo:" + cXConteudo + '-' + Alltrim(cXMotivo))
      ElseIf ValType("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U"
         cXConteudo := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
         cXMotivo   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
         MsgAlert("Codigo:" + cXConteudo + '-' + Alltrim(cXMotivo))
      Endif

      If cXConteudo $ '100|138'   // Autorizado o uso da NF-e | Documento Localizado
         dbSelectArea("EZ6")
         EZ6->(dbSetOrder(1))
         EZ6->(dbSeek(xFilial("EZ6")+EZ0->EZ0_CHVNFE))
         While !EZ6->(Eof()) .And. EZ6->(EZ6_FILIAL+EZ6_CHVNFE) == xFilial("EZ6")+EZ0->EZ0_CHVNFE
            If EZ6->EZ6_ACAO == "G" .And. "Rejeicao" $ EZ6->EZ6_DESCR
               RecLock("EZ6",.F.)
               EZ6->(dbDelete())
               MsUnlock()   
            Endif 
            EZ6->(dbSkip())
         Enddo 
         RecLock("EZ0",.F.)
         EZ0->EZ0_XMLOK  := ''
         EZ0->EZ0_STINTE := '2'
         EZ0->( EZ0_STIN()  )
         MsUnlock()        
      Else 
         RecLock("EZ0",.F.)
         EZ0->EZ0_XMLOK  := '2'
         EZ0->EZ0_STINTE := '9'
         MsUnlock()  

      Endif 
   
   Endif 

	RestArea(aArea)
    
Return 


/*=====================================================================================================================================*/
/* Marcio Martins Pereira - 05/03/2022
/* Rotinas de captura de XML na SEFAZ
/*=====================================================================================================================================*/

/*=====================================================================================================================================*/
// busca, processa e valida o XML
/*=====================================================================================================================================*/
User Function Proc_NF(aChaves,lBuscaXML,oProcess,lEnd,lSchedule)

	local nQtdChv	 := 0
	local aXmlRet	 := {}
	local cURL		 := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	local cIdEnt	 := ""
	local cAmbiente := ""
	local i         := 0
	local lRetProc	 := .F.
   Local cDir      := SuperGetMV("EZ_LOCXML",.F.,'\xml\')
   
	private oWs

	default aChaves	 := {}
	default cDir	 := ""

   If !existdir(cDir)
      makedir(cDir)
   endif 

   If lBuscaXML

      cIdEnt := RetIdEnti()

      CONOUT(lBuscaXML)
      
      oWs := WSMANIFESTACAODESTINATARIO():New()
      oWs:cUserToken   := "TOTVS"
      oWs:cIDENT	     := cIdEnt
      oWs:cAMBIENTE	 := ""
      oWs:cVERSAO      := ""
      oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
      oWs:CONFIGURARPARAMETROS()
      cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE 
      
      oWs:cUserToken   := "TOTVS"
      oWs:cIDENT	     := cIdEnt
      oWs:cAMBIENTE	 := cAmbiente
      
      oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
         
      For nQtdChv := 1 to Len(aChaves)
         
         // carla barbosa - trouxe aqui para cima apenas para ter a chave da NF na EZ0
         EZ0->(DBgOTO(aChaves[nQtdChv,2]))

         // carla barbosa - vou verificar se preciso manifestar o documento
         C00->(dbsetorder(1))
         if C00->(dbSeek(xFilial("C00")+EZ0->EZ0_CHVNFE))
            if C00->C00_STATUS $ '0' // Sem Manifesta��o
               U_ManifChave(EZ0->EZ0_CHVNFE,"210210")  //Ciencia da Opera��o
            Endif
         Endif

         oWs:oWSDOCUMENTOS:oWSDOCUMENTO  := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()
           
         
         aadd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
         oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[1]:CCHAVE := aChaves[nQtdChv,1]
      
         If oWs:BAIXARXMLDOCUMENTOS()
            CONOUT('BAIXANDO ARQUIVO')
            If ValAtrib("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
               If ValAtrib("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"
                  aXmlRet := oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET
               Else 
                  aXmlRet := {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}
               EndIf
            EndIF
            lRetProc := VerifProces(aXmlRet,cDir)
            if lRetProc
               lRet := .T.
            endif
         EndIf

      Next nQtdChv

   Endif 

   for i:=1 to Len(aChaves)
      If !lSchedule
         oProcess:IncRegua1("Proc.Dados XML " + aChaves[i,1] )
      Endif  
      EZ0->(dbGoTo(aChaves[i,2]))                        // posiciona na EZ0
      If !lSchedule
         oProcess:SetRegua2(2)
         oProcess:IncRegua2("Extraindo dados do XML")
      Endif 
      ExtraiDadosXML( aChaves[i], EZ0->EZ0_TIPONF )  // carla barbosa - por conta da NFSE Nacional - 17/10/23
      If !lSchedule
         oProcess:IncRegua2("Validando Pre nota" )
      Endif 
      VldDadosNF(  aChaves[i] )
      if lEnd
         return
      Endif
   next

return


/*=====================================================================================================================================*/
// Salva o arquvo XML
/*=====================================================================================================================================*/
Static Function VerifProces(aXmlRet,cDir)
Local nZ 		:= 0
Local lRet 		:= .F.
Local cChave	:= ""
Local cNfeProcZi:= ""
Local nHandle	:= 0

Private oRet

For nZ := 1 to Len(aXmlRet)
	oRet := aXmlRet[nZ]
	cNfeProcZi := ""
	cChave := ""
	If ValAtrib("oRet:CCHAVE") <> "U" .and. !Empty(oRet:CCHAVE)
		cChave	:= oRet:CCHAVE
	EndIf
   CONOUT(CCHAVE)
	If ValAtrib("oRet:CCHVSTATUS") <> "U" .and. (!Empty(oRet:CCHVSTATUS) .and. ('138' $ oRet:CCHVSTATUS .or. '140' $ oRet:CCHVSTATUS .or. '656' $ oRet:CCHVSTATUS))   //140: Download disponibilizado - 656:Consumo indevido (tras dos campos da SPED156)
		If ValAtrib("oRet:CNFEPROCZIP") <> "U" .and. !Empty(oRet:CNFEPROCZIP)
			cNfeProcZi	:= oRet:CNFEPROCZIP
		else
         EZ0->( RecLock('EZ0',.f.))
         EZ0->EZ0_XMLNFE:=oRet:CCHVDESC
         EZ0->EZ0_STINTE:="3"  // atualiza o status
         EZ0->(msUnlock())
      EndIf
	EndIf	 

	If !Empty(cChave) .and. !Empty( cNfeProcZi ) .AND. !'<nfeProc' $ cNfeProcZi
		nHandle  := FCreate( cDir+cChave+"-"+"nfeProc.gz" )
		If nHandle > 0
			FWrite( nHandle, cNfeProcZi )
			FClose( nHandle )
			lRet   := .T.
         cNfe := '' 
         GzStrDecomp(cNfeProcZi, Len( cNfeProcZi ), @cNfe ) //Alltrim(cNfeProcZi)
   	   nHandle  := FCreate( cDir+cChave+"-"+"nfeProc.xml" )
			FWrite( nHandle, cNfe )
			FClose( nHandle )
         EZ0->(DbSetOrder(1))
         if EZ0->(DBSEEK(Xfilial("EZ0")+cChave))
            EZ0->( RecLock('EZ0',.f.))
            EZ0->EZ0_XMLNFE:=cNfe
            EZ0->( EZ0_STIN() )  // atualiza o status
            EZ0->(msUnlock())
         ENDIF
		EndIf
	EndIf
Next

Return lRet  

//---------------------------------------------------------------------------------------------------------
// Rotinas da nova versao para busca de documentos manifestados
//---------------------------------------------------------------------------------------------------------

Static Function ReadyTSS(cURL,nTipo,lHelp)
Local lUsaColab := UsaColaboracao("4")
Return (CTIsReady(cURL,nTipo,lHelp,lUsaColab))

//---------------------------------------------------------------------------------------------------------

static function getAmbMde()
	
	local cAmbiente := ""
	local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)	
	local oWs
	local lUsacolab := UsaColaboracao("4")
	
	if !lUsacolab .and. ReadyTSS()
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := retIdEnti(lUsacolab)
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
		oWs:CONFIGURARPARAMETROS()
		cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
	
		freeObj(oWs)
		oWs := nil 	

	endif

return cAmbiente

//---------------------------------------------------------------------------------------------------------
Static function MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc,cOpcUpd)
				
C00->(DbsetOrder(1))
If C00->(DbSeek( xFilial("C00") + cChave))
	RecLock("C00",.F.)
	C00->C00_CNPJEM		:= Alltrim(cCNPJEmit)
	C00->C00_IEEMIT		:= AllTrim(cIeEmit)
	C00->C00_NOEMIT		:= Alltrim(cNomeEmit)
	// Caso tenha retornado cSitConf = 0 (Sem Manifesta��o do Destinat�rio), devido ao sincronismo ter sido em momentos diferentes, ou seja, no sincronismo n�o continha nenhuma manifesta��o,
	// por�m ap�s poder� ter sido realizado alguma manifesta��o (como no TSS gravado Sem Manifesta��o do Destinat�rio), e retornado rejei��o cOpcUpd = 4 assim como o registro C00_STATUS est� com status 1 ou 4 ( confirma��o ou ciencia )
	// manter o mesmo status para que seja poss�vel realizar a exporta��o do XML, caso tenha sido uma rejei��o diferente de duplicidade, a SEFAZ n�o ir� retorna o XML.
	// DSERTSS1-16588
	C00->C00_STATUS		:= if(alltrim(cSitConf) == "0" .and. alltrim(cOpcUpd) == '4' .and. C00->C00_STATUS $ "1|4" , C00->C00_STATUS, cSitConf)
	C00->C00_SITDOC		:= cSituacao
	C00->C00_DESRES		:= Alltrim(cDesResp)
	C00->C00_CODRET		:= cDesCod
	C00->C00_DTEMI  	:= dDtEmi
	C00->C00_DTREC		:= dDtRec
	C00->C00_VLDOC		:= nValDoc
	C00->C00_CODEVE		:= Iif(alltrim(cOpcUpd) $ '4','4',Iif(alltrim(C00->C00_STATUS) $ '0',"1","3"))
	C00->(MsUnLock())
EndIf

return nil

//---------------------------------------------------------------------------------------------------------
Static Function MonitoraManif(aChave,cAmbiente,cIdEnt,cUrl,lJob,cOpcUpd)

Local cChave		:= ""
Local cCNPJEmit	:= ""
Local cIeEmit		:= ""
Local cNomeEmit	:= ""
Local cSitConf	:= ""	
Local cSituacao	:= ""
Local cDesResp	:= ""
Local cDesCod		:= ""

Local dDtEmi		:= CTOD("  /  /  ")
Local dDtRec		:= CTOD("  /  /  ")

Local nValDoc		:= 0
Local nZ := 0
Local nY := 0

Local aMonDoc	:={}

Default cOpcUpd :=""

Private oWS		:= Nil


Default lJob	:= .F.

if ReadyTSS() .And. !(UsaColaboracao("4"))

	oWs :=WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cIDENT	     := cIdEnt
	oWs:cAMBIENTE	 := cAmbiente     
	oWs:OWSMONDADOS:OWSDOCUMENTOS  := MANIFESTACAODESTINATARIO_ARRAYOFMONDOCUMENTO():New()
	For nY := 1 to Len(aChave)
		aadd(oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO,MANIFESTACAODESTINATARIO_MONDOCUMENTO():New())
		oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO[nY]:CCHAVE := aChave[nY]
	Next
	oWs:_URL := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
	
	If oWs:MONITORARDOCUMENTOS()
		If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") <> "U"
			If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") == "A"
				aMonDoc := oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET
			Else 
				aMonDoc := {oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET}
			EndIf
		EndIF
		For nZ :=1 to Len(aMonDoc)
			If ValAtrib(aMonDoc[nZ]:CCHAVE) <> "U"
				cChave := aMonDoc[nZ]:CCHAVE
				
				cCNPJEmit	:= Iif(!Empty(Alltrim(aMonDoc[nZ]:CEMITENTECNPJ)),Alltrim(aMonDoc[nZ]:CEMITENTECNPJ),Alltrim(aMonDoc[nZ]:CEMITENTECPF))
				cIeEmit	:= AllTrim(aMonDoc[nZ]:CEMITENTEIE)
				cNomeEmit	:= Alltrim(aMonDoc[nZ]:CEMITENTENOME)
				cSitConf	:= aMonDoc[nZ]:CSITUACAOCONFIRMACAO
				cSituacao	:= aMonDoc[nZ]:CSITUACAO
				cDesResp	:= Alltrim(aMonDoc[nZ]:CRESPOSTADESCRICAO)
				cDesCod	:= aMonDoc[nZ]:CRESPOSTASTATUS
				
				dDtEmi		:= StoD(StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-",""))
				dDtRec		:= StoD(StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-",""))
				
				nValDoc		:= aMonDoc[nZ]:NVALORTOTAL				
				
				MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc,cOpcUpd)
								
			EndIf	
		Next
	Else	
		If !lJob
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		Endif
	EndIf
Else
	If !lJob
		Aviso("SPED","Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!" ,{"SPED"},3)
	Endif
EndIf

oWs := Nil
DelClassIntf()	

Return 

//---------------------------------------------------------------------------------------------------------

Static Function SincDados(lProcAll,lRefazSinc)

   Local aChave	:= {}
   Local aDocs		:= {}
   Local aProc		:= {}

   Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
   Local cIdEnt	:= RetIdEnti()
   Local cChave	:= ""
   Local cCancNSU	:= ""
   //Local cAlert	:= ""
   Local cSitConf	:= ""
   Local cCodEvento	:= ""
   Local cAmbiente	:= "" 
   Local lContinua	:= .T.

   Local lOk		:= .F.
   Local lDestcnpj	:= .T.
   local lSinc     := .F.

   Local nX		:= 0                 
   Local nZ		:= 0

   Private oWs		:= Nil
   Private oInfdoc	:= Nil

   Default lProcAll := .F.
   Default lRefazSinc	:= .F.

   If ReadyTSS()
      oWs :=WSMANIFESTACAODESTINATARIO():New()
      oWs:cUserToken   := "TOTVS"
      oWs:cIDENT	     := cIdEnt
      oWs:cINDNFE		 := "0"
      oWs:cINDEMI      := "0"
      oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

      cAmbiente		 := getAmbMde() 

      /* ********************************************************************************************************************** */
      // Retirado a op��o de refazer a sincroniza�a� de todos os documentos, devido o cliente estar sempre flegando esta op��o
      // assim dando a impress�o que o TSS n�o est� sincronizando as notas.
      /* ********************************************************************************************************************** */
      // Refaz a sincroniza��o de todos os documentos disponiveis na SEFAZ
      //If lRefazSinc 
      //	oWs:cUltNSU	:= "0"
      //	oWs:CONFIGURARPARAMETROS()
      //Endif
         
      //Tratamento para solicitar a sincroniza��o enaquanto o IDCONT n�o retornar zero.

      While lContinua
      
         lOk		:= .F.
         aChave	:= {}
         aProc	:= {}
         
         If oWs:SINCRONIZARDOCUMENTOS()
            If ValAtrib("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"
               If ValAtrib("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"
                  aDocs := oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO                  
               Else
                  aDocs := {oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
               EndIf

               For nX := 1 To Len(aDocs)
                  lDestcnpj:=.T.
                  oInfdoc := aDocs[nx]
                  If ValAtrib("oInfdoc:CCHAVE") <> "U" .and. Type("oInfdoc:CSITCONF") <> "U" 
                     cSitConf  := oInfdoc:CSITCONF
                     cChave    := oInfdoc:CCHAVE  
                     cCancNSU  := oInfdoc:CCANCNSU
                     If ValAtrib("oInfdoc:CCODEVENTO") <> "U"
                        cCodEvento:= oInfdoc:CCODEVENTO
                     Else
                        CodEvento:= ""
                     EndIf
                     If ValAtrib("oInfdoc:cDESTCNPJ") <> "U" .AND. !empty(oInfdoc:cDESTCNPJ)
                        If SM0->M0_CGC <> oInfdoc:cDESTCNPJ
                              lDestcnpj:= .F.
                        EndIf
                     EndIf
                     
                     // Caso o doc sincronizado tenha TPEVENTO n�o deve ir pra tabela C00
                     If !cCodEvento $ "411500|411501|411502|411503" .and. lDestcnpj
                        if SincAtuDados(cChave,cSitConf,cCancNSU)
                           aadd(aChave, cChave)
                           lOk  := .T.
                           lSinc:= .T.
                        endif
                     EndIf
                  EndIf	
               Next                   
               
               If lOk
                  For nZ := 1 To Len( aChave )
                  
                     AADD( aProc, aChave[nZ] )
                                             
                     If Len( aProc ) >= 30
                        MonitoraManif(aProc,cAmbiente,cIdEnt,cUrl)
                        aProc := {}
                     Endif
                     
                  Next
                  If Len( aProc ) > 0
                     MonitoraManif(aProc,cAmbiente,cIdEnt,cUrl)
                  Endif
               EndIf						
               
               If ValAtrib("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT") <> "U"
                     
                  If oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT == "0"
                     lContinua := .F.						               
                  endif	
               else
                  lContinua := .F.				
               endif
               /*
               If Empty(aDocs) .And. !lContinua .And. !lOk
                  If lSinc
                     cAlert:= STR0668 // "Todos os documentos dispon�veis at� o momento foram sincronizados."
                  Else
                     cAlert:= STR0437 //"N�o h� documentos para serem sincronizados"
                  EndIF
                  Aviso("Sincroniza��o",cAlert,{"OK"},3)
               EndIF
               
               if lContinua .And. !lProcAll .And. !lRefazSinc
                  lContinua := MsgYesNo(STR0669) // STR0669 = "Ainda existem documentos na SEFAZ a serem sincronizados, deseja solicitar novamente a sincroniza��o ?"
               endif
               */
               //Sleep(2000)
            EndIf	
         Else
            /*
            If lSinc
               cAlert:= STR0668 // "Todos os documentos dispon�veis at� o momento foram sincronizados."
               Aviso(STR0647,cAlert,{"OK"},3)//STR0647=SPED
            Else
               Aviso(STR0647,IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)//STR0647="SPED"
            EndIf
            */
            lContinua := .F.
         EndIf
      EndDo	
   Else
      Aviso("SPED","Execute o m�dulo de configura��o do servi�o, antes de utilizar esta op��o!!!",{"SPED"},3)
   EndIf

   oWs := Nil
   oInfdoc := Nil
   aDocs := Nil
   DelClassIntf()

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SincAtuDados()
Realiza a atualza��o do sincroizar dados.
@type function
@author Rafael Iaquinto
@since 18/08/2014
@version 1.00
/*/
//-----------------------------------------------------------------------   
Static function SincAtuDados(cChave,cSitConf,cCancNSU)

Local dData		:= CtoD("  /  /    ")
Local lOk			:= .F.

C00->(DbsetOrder(1))
If !C00->( DbSeek( xFilial("C00") + cChave) )
	RecLock("C00",.T.)
	C00->C00_FILIAL     := xFilial("C00")
	C00->C00_STATUS     := cSitConf
	C00->C00_CHVNFE		:= cChave
	dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
	C00->C00_ANONFE		:= Strzero(Year(dData),4)
	C00->C00_MESNFE		:= Strzero(Month(dData),2)
	C00->C00_SERNFE		:= Substr(cChave,23,3)
	C00->C00_NUMNFE		:= Substr(cChave,26,9)
	C00->C00_CODEVE		:= Iif(cSitConf $ '0',"1","3")	
	If !Empty(cCancNSU)
		C00->C00_SITDOC := "3" //nota cancelada
	Else
		C00->C00_SITDOC := "1" //nota autorizada
	EndIf
	lOk := .T.
	MsUnLock()
	If ExistBlock("MANIGRV")
		ExecBlock("MANIGRV",.F.,.F.,{Substr(cChave,23,3),Substr(cChave,26,9),cChave,cSitConf})
	EndIf
Else
	If !Empty(cCancNSU)
		RecLock("C00",.F.)
		C00->C00_SITDOC := "3"
		MsUnLock()
	EndIf
EndIf	

return (lOk)

/*=====================================================================================================================================*/

static Function ValAtrib(atributo)
Return (type(atributo) )

/*=====================================================================================================================================*/

Static Function A116ChkTES(cCodTES)
Local lRet := .T.
If SubStr(cCodTES,1,1) >= "5" .And. cCodTES <> "500"
	lRet := .F.
	HELP("   ",1,"INV_TE")
Endif
Return (lRet)

/*=====================================================================================================================================*/

Static Function A116StpOk(cNumNF,cFornece,cLoja,cTes,cFornOri,cLojaOri,nCombo1,nValor,nCombo3)
Local lRet := .T.

If nCombo1 == 1
	If (Empty(cNumNF).And.nCombo3==1) .Or. Empty(cFornece) .Or. Empty(cLoja) .Or. Empty(cTes) .Or. Empty(nValor)
		lRet := .F.
      MsgAlert("Existem campos de preenchimento obrigatorio que nao foram informados. Verifique os campos da tela de que contem os dados da nota fiscal.")
	EndIf
EndIf	

If lRet .And. (!Empty(cFornOri).And.Empty(cLojaOri))
	lRet := .F.
   MsgAlert("Codigo da loja do fornecedor invalida. Verifique o preenchimento correto da loja do Fornecedor nos parametros para filtragem da nota fiscal.")
EndIf

Return lRet

/*=====================================================================================================================================*/

Static Function A116ChkTra(c116Fornece,c116Loja,c116FornOri,c116LojaOri)

Local lRet 		:= .T.
Local lCkTrans	:= GetNewPar("MV_CKTRANS",.F.) 

If lCkTrans
	If c116Fornece == c116FornOri .And. c116Loja == c116LojaOri
		lRet := .F.
		HELP("",1,"A116CKTR")
	Endif
Endif

Return (lRet)

/*=====================================================================================================================================*/

User Function MT116TEL()

    Local lRet  := .T. 

    If FWIsInCallStack("U_PORTAL_XML") 
        If ExistBlock("EZMT116TEL")	// ROTINA EXCLUSIVA DO PORTAL XML - EZ4 - ERRA ROTINA SE ENCONTRA NO CORE DO PRODUTO 
            if Empty(Alltrim(Posicione("SF1",1,xFILIAL("SF1")+EZ0->(EZ0_DOC+EZ0_SERIE+EZ0_FORNECE+EZ0_LOJA),"F1_DOC")))
                lRet := U_EZMT116TEL()
            Else
               lRet := .f.
            Endif
        Endif 
    Else 
		If !A116Setup(@aParametros)
			lRet := .F.
		EndIf    
    Endif 

Return lRet


/*=====================================================================================================================================*/

User Function EZMT116GRV
/*
Ponto de Entrada
Utilizado para gravar os Campos Origem e Destino na Rotina MATA116
Carla Barbosa - 24/06/2022
*/

DDEMISSAO    := EZ0->EZ0_DTEMI   // AJUSTAR A DATA DE EMISSAO DO LAN�AMENTO PARA A DATA DO PORTAL - 15/12/2022
aINFADIC[10] := EZ0->EZ0_UFORIT  // uf origem
aINFADIC[11] := EZ0->EZ0_MUORIT  // mun origem
aINFADIC[12] := EZ0->EZ0_UFDEST  // uf dest
aINFADIC[13] := EZ0->EZ0_MUDEST  // mun dest

Return 

/********************************
Busca Informa��oes do Fonte - Carla Barbosa 04/10/2022 
********************************/
Static function InfoFonte()
  Local aRetType, aRetFile, aRetLine, aRetDate, aRetBType
  Local cRetorno
  aRet := GetFuncArray("u_portal_xml", aRetType, aRetFile, aRetLine, aRetDate, aRetBType)
  cRetorno := " - Versao 1.01 - " + cvaltochar(aRetDate[1])
Return cRetorno


/* 
// =====================================================================================================================================
//   DATA  | ANALISTA			| CORRECAO
// =====================================================================================================================================
// 03/05/19| MARCIO MARTINS		| Funcao: ManifValid() -> Valida se o ambiente do Manifesto est� como 1-Produ��o
// =====================================================================================================================================
*/
Static Function ManifValid()
   
   Local lValida := .T.

   //RpcClearEnv()
   //RpcSetType(3)
   //RpcSetEnv('01','00660001')
   
	cIdEnt  := RetIdEnti()	  
	cURL	  := PadR(GetNewPar("MV_SPEDURL","http://"),250)

   Default cJustific := ''
   //Carla Barbosa - Declarando a variavel oWs como private para n�o dar erro em 
   //outras chamadas de fun��es 
   Private oWS		:= Nil
	  
	oWs := WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken := "TOTVS"
	oWs:cIDENT	  := cIdEnt
	oWs:cAMBIENTE  := ""
	oWs:cVERSAO    := ""
	oWs:_URL       := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
      
	If oWs:CONFIGURARPARAMETROS()
	
		cAmbiente := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

      If cAmbiente <> "1"         
         lValida := .F.
      Endif 

	Endif

   //RpcClearEnv()

Return lValida

/*=====================================================================================
// APENAS PARA TESTE
=====================================================================================*/
User Function xProcchave()

   Local oSelf 
   Local lSchedule := .T.
   RpcClearEnv()
   RpcSetType(3)
   RpcSetEnv('01','00630001')
   ProcChave(oSelf, lSchedule,"35221061478897000158550000006755491069681883")
Return 

/*=====================================================================================
// 
=====================================================================================*/
Static Function ProcChave(oSelf, lSchedule,aChave)

   Local aArea      := GetArea()
	Local lRet       := .T.
	Local lValida	  := .T.
	Local cURL       := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
	Local cMsg       := ""
	Local oWsdl      := Nil
	Local cMsgRet    := ""
	Local cError     := ""
	Local cWarning   := ""
	Local cUfAutor   := ""
	Local cTpAmb     := ""
	Local cCNPJEmp   := ""
	Local lContinua  := .T.
	Local cLocCert   := '\certs\'
	Local cCert		  := ''
	Local cCert_ca	  := ''
	Local cCert_cert := ''
	Local cCert_key  := ''
   Local nX         := 0

	Private oXmlDocZip
	Private cUnXML	:= ''
	Private cOrigem := ''
   Private lResumos := 0
   Private lXMLBaixa := 0 

   If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpant == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)
      Return .T.
   Endif 
   
   If !CTIsReady()        

      MsgAlert("Verifique se o TSS esta ativado")
      lValida := .F.
   
   Else 

      cCert		    := Alltrim(retIdEnti())
      cCert_ca     := cLocCert+cCert+"_ca.pem"
      cCert_cert   := cLocCert+cCert+"_cert.pem"
      cCert_key    := cLocCert+cCert+"_key.pem"
      nSSLVersion  := 0  // mudei aqui 
      lSSLInsecure := .T.

      If !File(cCert_ca)
         MsgAlert("Os arquivos do certificado digital devem constam na pasta: "+cLocCert)
         return
      Endif 

      cUFAutor := RetCodUf()
      cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
      cCNPJEmp  := SM0->M0_CGC	//'18666055000109'	 // vistra

      //Inst�ncia a classe, setando as par�metrizac�es necessarias
      oWsdl := TWsdlManager():New()
      oWsdl:cSSLCACertFile := cCert_ca
      oWsdl:cSSLCertFile   := cCert_cert
      oWsdl:cSSLKeyFile    := cCert_key
      oWsdl:nSSLVersion    := nSSLVersion
      oWsdl:lSSLInsecure   := lSSLInsecure
      oWsdl:nTimeout       := 120
      
      //Tenta fazer o Parse da URL
      lRet := oWsdl:ParseURL(cURL)
      If !lRet 
         ConOut("[consChNFe] - Erro ParseURL: " + oWsdl:cError)
         MsgAlert("O Certificado Digital "+ cCert + " pode estar vencido ou nao se encontra na pasta, solicite atualizacao da pasta '\CERTS\'")
         lContinua := .F.
      EndIf

      //Se for continuar o processamento
      If lContinua
         //Tenta definir a operacao
         lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
         If ! lRet 
            ConOut("[consChNFe] - Erro SetOperation: " + oWsdl:cError)
            lContinua := .F.
         EndIf         
      EndIf
         
      //Se for continuar
      If lContinua

         For nX := 1 to Len(aChave)

            cChaveNFe := aChave[nX,1]

            EZ0->(dbGoTo(aChave[nX,2]))

            If !lSchedule
               oSelf:IncRegua1("Buscando Chave: " + cChaveNFe)
               oSelf:SetRegua2(5)
               oSelf:IncRegua2("Busca Chave")
            Endif 

            //Monta a mensagem que sera enviada
            cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
            cMsg += '    <soapenv:Header/>'                                                                             + CRLF
            cMsg += '    <soapenv:Body>'                                                                                + CRLF
            cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
            cMsg += '                <nfeDadosMsg>'                                                                     + CRLF
            cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'         + CRLF
            cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                 + CRLF
            cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                            + CRLF
            cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                 + CRLF
            cMsg += '                      <consChNFe>'                                                                 + CRLF
            cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                  + CRLF
            cMsg += '                      </consChNFe>'                                                                + CRLF
            cMsg += '                    </distDFeInt>'                                                                 + CRLF
            cMsg += '                </nfeDadosMsg>'                                                                    + CRLF
            cMsg += '            </nfeDistDFeInteresse>'                                                                + CRLF
            cMsg += '        </soapenv:Body>'                                                                           + CRLF
            cMsg += '    </soapenv:Envelope>'                                                                           + CRLF

            //Envia uma mensagem SOAP personalizada ao servidor
            oWsdl:lProcResp := .F.
            lRet := oWsdl:SendSoapMsg(cMsg)
            If ! lRet 
               ConOut("[consChNFe] - Erro SendSoapMsg: " + oWsdl:cError)
               ConOut("[consChNFe] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
               lContinua := .F.
            EndIf
            //Pega a resposta do SOAP
            cMsgRet := oWsdl:GetSoapResponse()
                              
            //Transforma a resposta em um objeto
            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
               
            //Se existir Warning, mostra no console.log
            If ! Empty(cWarning)
               ConOut("[consChNFe] - Alerta cWarning: " + cWarning)
            EndIf
               
            //Se houve erro, nao permitira prosseguir
            If ! Empty(cError)
               ConOut("[consChNFe] - Erro cError: " + cError)
               lContinua := .F.
            EndIf
         
            //Se a tag DocZip existir (for diferente de Undefinied)
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U")	
               cXConteudo := OXMLDOCZIP:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
               cXMotivo   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
               If cXConteudo $ '656'
                  If !lSchedule
                     PutMV("EZ_PX_DNSU",dtoc(dDataBase))
                     PutMV("EZ_PX_HNSU",Time()) 
                  Endif 
                  Exit
               ElseIf cXConteudo $ '653'   // Rejeicao: NF-e Cancelada, arquivo indisponivel para download
                  RecLock("EZ0",.F.)
                  EZ0->EZ0_CODRET := cXConteudo
                  EZ0->EZ0_DESRES := cXMotivo
                  EZ0->EZ0_STINTE := '9'
                  MsUnlock()
               ElseIf cXConteudo $ '100|138'   // Autorizado o uso da NF-e | Documento Localizado
                  CULTNSU    := '' 
                  cXmlGZip   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                  PTNFEGrvXML(cXmlGZip,1,1,cUltNSU,oSelf,lSchedule)
               EndIf
               
            Endif

         Next nX
         
      EndIf
   
   Endif 

	RestArea(aArea)

return lValida

//**********************************************************
// MnuProcNsu - 09/02/2023
//**********************************************************
User Function MnuProcNSU()
   
   Local oSelf
   Local cPerg     := "MNUPROCNSU"
   Local aChaveNSU := {}
   Local cRetorno  := ""
   
   ValidNsu(cPerg)

   If !Pergunte(cPerg, .T.)
      MsgAlert("Cancelamento da opera��o realizada pelo usu�rio")
      Return 
   Endif 

   aadd(aChaveNSU, { StrZero(MV_PAR01,15) })            
   If ProcNSU( oSelf, .T. , aChaveNSU, @cRetorno)
      MsgAlert("Busca realizada com sucesso")
   Else 
      MsgAlert("Falha na Busca"+CRLF+cRetorno)
   Endif 

Return 

//**********************************************************
// ProcNsu
//**********************************************************
Static Function ProcNSU(oSelf, lSchedule,aChave,cRetorno)

   Local aArea      := GetArea()
	Local lRet       := .T.
	Local lValida	  := .T.
	Local cURL       := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
	Local cMsg       := ""
	Local oWsdl      := Nil
	Local cMsgRet    := ""
	Local cError     := ""
	Local cWarning   := ""
	Local cUfAutor   := ""
	Local cTpAmb     := ""
	Local cCNPJEmp   := ""
	Local lContinua  := .T.
	Local cLocCert   := '\certs\'
	Local cCert		  := ''
	Local cCert_ca	  := ''
	Local cCert_cert := ''
	Local cCert_key  := ''
   Local nX         := 0

	Private oXmlDocZip
	Private cUnXML	:= ''
	Private cOrigem := ''
   Private lResumos := 0
   Private lXMLBaixa := 0 

   Default cRetorno := ""

   If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpant == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)
      Return .T.
   Endif 
   
   If !CTIsReady()        

      MsgAlert("Verifique se o TSS esta ativado")
      lValida := .F.
   
   Else 

      cCert		    := Alltrim(retIdEnti())
      cCert_ca     := cLocCert+cCert+"_ca.pem"
      cCert_cert   := cLocCert+cCert+"_cert.pem"
      cCert_key    := cLocCert+cCert+"_key.pem"
      nSSLVersion  :=  0   // mudei aqui
      lSSLInsecure := .T.

      If !File(cCert_ca)
         MsgAlert("Os arquivos do certificado digital devem constam na pasta: "+cLocCert)
         return
      Endif 

      cUFAutor := RetCodUf()
      cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
      cCNPJEmp  := SM0->M0_CGC	//'18666055000109'	 // vistra

      //Inst�ncia a classe, setando as par�metrizac�es necessarias
      oWsdl := TWsdlManager():New()
      oWsdl:cSSLCACertFile := cCert_ca
      oWsdl:cSSLCertFile   := cCert_cert
      oWsdl:cSSLKeyFile    := cCert_key
      oWsdl:nSSLVersion    := nSSLVersion
      oWsdl:lSSLInsecure   := lSSLInsecure
      oWsdl:nTimeout       := 120
      
      //Tenta fazer o Parse da URL
      lRet := oWsdl:ParseURL(cURL)
      If !lRet 
         ConOut("[PROCNSU] - Erro ParseURL: " + oWsdl:cError)
         MsgAlert("O Certificado Digital "+ cCert + " pode estar vencido ou nao se encontra na pasta, solicite atualizacao da pasta '\CERTS\'")
         lContinua := .F.
      EndIf

      //Se for continuar o processamento
      If lContinua
         //Tenta definir a operacao
         lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
         If ! lRet 
            ConOut("[PROCNSU] - Erro SetOperation: " + oWsdl:cError)
            lContinua := .F.
         EndIf         
      EndIf
         
      //Se for continuar
      If lContinua

         For nX := 1 to Len(aChave)

            cChaveNFe := aChave[nX,1]

            If !lSchedule
               oSelf:IncRegua1("Buscando NSU: " + cChaveNFe)
               oSelf:SetRegua2(5)
               oSelf:IncRegua2("Busca NSU")
            Endif 

            //Monta a mensagem que sera enviada
            cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                        + CRLF
            cMsg += '    <soapenv:Header/>'                                                                             + CRLF
            cMsg += '    <soapenv:Body>'                                                                                + CRLF
            cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'  + CRLF
            cMsg += '                <nfeDadosMsg>'                                                                     + CRLF
            cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'         + CRLF
            cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                 + CRLF
            cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                            + CRLF
            cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                 + CRLF
            cMsg += '                      <consNSU>'                                                                 + CRLF
            cMsg += '                           <NSU>'+alltrim(cChaveNFe)+'</NSU>'                                  + CRLF
            cMsg += '                      </consNSU>'                                                                + CRLF
            cMsg += '                    </distDFeInt>'                                                                 + CRLF
            cMsg += '                </nfeDadosMsg>'                                                                    + CRLF
            cMsg += '            </nfeDistDFeInteresse>'                                                                + CRLF
            cMsg += '        </soapenv:Body>'                                                                           + CRLF
            cMsg += '    </soapenv:Envelope>'                                                                           + CRLF

            //Envia uma mensagem SOAP personalizada ao servidor
            oWsdl:lProcResp := .F.
            lRet := oWsdl:SendSoapMsg(cMsg)
            If ! lRet 
               ConOut("[PROCNSU - consNSU] - Erro SendSoapMsg: " + oWsdl:cError)
               ConOut("[PROCNSU - consNSU] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
               lContinua := .F.
            EndIf
            //Pega a resposta do SOAP
            cMsgRet := oWsdl:GetSoapResponse()
                              
            //Transforma a resposta em um objeto
            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
               
            //Se existir Warning, mostra no console.log
            If ! Empty(cWarning)
               ConOut("[PROCNSU - consNSU] - Alerta cWarning: " + cWarning)
            EndIf
               
            //Se houve erro, nao permitira prosseguir
            If ! Empty(cError)
               ConOut("[PROCNSU - consNSU] - Erro cError: " + cError)
               lContinua := .F.
            EndIf
         
            //Se a tag DocZip existir (for diferente de Undefinied)
            If (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT") != "U")	
               cXConteudo := OXMLDOCZIP:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
               cXMotivo   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
               If (TYPE("OXMLDOCZIP:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_ULTNSU:TEXT") != "U")
                  CULTNSU := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_retdistdfeint:_ultnsu:text
               Else 
                  CULTNSU    := '' 
               Endif 
               If cXConteudo $ '656#137'
                  ConOut("[PROCNSU - consNSU] - NSU: "+ cULTNSU+ " "+ cXMotivo)
                  cRetorno := "[PROCNSU - consNSU] - NSU: "+ cChaveNFe+ " "+ cXMotivo
                  If cXConteudo $ '137'
                     EZGravNsu(cUltNSU,"9","NR NSU "+Alltrim(cUltNSU))
                  Endif
                  lValida := .F.
                  Exit
               ElseIf cXConteudo $ '100|138'   // Autorizado o uso da NF-e | Documento Localizado
                  ConOut("[PROCNSU - consNSU] - Gravando NSU "+ cUltNSU)
                  cXmlGZip   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
                  PTNFEGrvXML(cXmlGZip,1,1,cUltNSU,oSelf,lSchedule)
                  lValida := .T. 
               EndIf
               
            Endif

         Next nX
         
      EndIf
   
   Endif 

	RestArea(aArea)

return lValida

/*
===============================================================================================
===============================================================================================
|| SERVIDOR DE LICEN�A EZ4 
===============================================================================================
===============================================================================================
*/
/*
===============================================================================================
===============================================================================================
||   Arquivo:	EZSERVER.prw
===============================================================================================
||   Funcao: 	EZSERVER
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	10/12/2020
===============================================================================================
===============================================================================================
*/
Static Function EZSERVER(cCNPJ, cProduto)

    Local oObjRet
    Local lRet       := .T.     
    Local cResult    := ""

    Private cTabela     := "TABEZ4"
    Private cTabVolm    := "TABVOL"
    Private cKeyPadrao  := "6364415226B35B3794C966F0276AFD1B9B7C082EA8632C5F292B94D745EDA1DC585A40F30D1A5D605B2AB2EB13E9D815B312A02308ED0C5D70302EC21A8594A0"

    Private cCNPJParam := aLLTRIM(SuperGetMV("EZ_CNPJPAR" ,.F.,""))  // Dever� ser do tipo Caracter e possuir apenas o CNPJ da empresa principal
    
    If !Empty(cCNPJParam)
        cCNPJ := cCNPJParam
    Else 
        cCNPJ := SM0->M0_CGC
    Endif 

    cProduto := Padr(cProduto,30)

    EZAbreTab(cTabela)

    // Cria��o da tabela que trata a volumetria
    U_EZTABVOL(cTabVolm)
    dbSelectArea(cTabela)

    If !(cTabela)->(dbSeek(cProduto+cCNPJ))

        cResult := Ez4Connect(cCNPJ, cProduto)
        EZ4AtuTab(cCNPJ,cProduto,cResult)

    Else

        While !(cTabela)->(Eof()) .And. cProduto == TABEZ4->PRODUTO  .AND. cCNPJ == TABEZ4->CNPJ
            cResult += Alltrim((cTabela)->DADOS)
            (cTabela)->(dbSkip())
        Enddo

        If Empty(cResult)
            cResult := Ez4Connect(cCNPJ, cProduto)
            if !EMPTY(cResult)
                EZ4AtuTab(cCNPJ,cProduto,cResult)
            else
                 MsgAlert("Falha na conex�o com o Servidor de Licen�as. " + CRLF + "Por favor entrar em contato com a EZ4 Consultoria!")
            ENDIF
        Endif 

    Endif

    If Empty(cResult)
        
        MsgAlert("Erro na Autentica��o!"+CRLF+"Favor entrar em contato com EZ4")
        lRet := .F.

    Else 
        cResult = rc4crypt(cResult, cKeyPadrao, .F., .T.)

        If FWJsonDeserialize(cResult,@oObjRet)
            
            dDTFImCtr := STOD(oObjRet:DATAFIMCONTRATO)
            dDtProx   := STOD(StrTran(oObjRet:DATAPROXIMAVALIDACAO,"/",""))
            cKeyEz4   := oObjRet:CODBLOCK

            If (ddatabase > dDTFImCtr) .Or.  dDatabase > dDtProx // OK

                cResult := Ez4Connect(cCNPJ, cProduto)
                EZ4AtuTab(cCNPJ,cProduto,cResult)
                cResult = rc4crypt(cResult, cKeyPadrao, .F., .T.)
                If FWJsonDeserialize(cResult,@oObjRet)
                    dDTFImCtr := STOD(oObjRet:DATAFIMCONTRATO)
                    dDtProx   := STOD(StrTran(oObjRet:DATAPROXIMAVALIDACAO,"/",""))
                    cKeyEz4   := oObjRet:CODBLOCK
                Endif 

                // Envio os dados da volumetria
                U_Ez4EnvVolum(cCNPJ)

            Endif 

            If (ddatabase > dDTFImCtr)

                MsgAlert("Produto com contrato para CNPJ " + oObjRet:CNPJ +" vencido em " + DTOC(dDTFImCtr) + CRLF + "Por favor entrar em contato com a EZ4 Consultoria!")
                lRet := .F.

            ElseIf dDatabase > dDtProx

                If !Empty(oObjRet:CHAVE)

                    If oObjRet:STATUS == '1'
                        EZ4AtuTab(cCNPJ,cProduto,cResult)    
                    Else
                        MsgAlert("Produto com bloqueio Financeiro"+CRLF+"Entre em contato com a EZ4 Consultoria")
                        lRet := .F.
                    Endif 
                    
                Else

                    MsgAlert("Produto Sem Licen�a, Para contratar entre em contato com a EZ4 Consultoria")
                    lRet := .F.

                Endif

            Endif 

        Endif
    
    Endif 

Return lRet


































































































































































/*
===============================================================================================
===============================================================================================
||   Arquivo:	EZCLIENT.prw
===============================================================================================
||   Funcao: 	EZAbreTab
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	10/12/2020
===============================================================================================
===============================================================================================
*/
Static  Function EZAbreTab(cTabela) // Cria/abre as tabelas

    Local aStru := {}
 
    aStru := {  { "PRODUTO" , "C" , 30 , 0 },;
                { "CNPJ"    , "C" , 14 , 0 },;                
                { "SEQ"     , "N" , 10 , 0 },;
                { "DADOS"   , "C" , 900 , 0 }}
    
    cTabela := upper(AllTrim(cTabela))

    If Select(cTabela) == 0

        If !MsFile(cTabela,,"TOPCONN")
            dbCreate(cTabela, aStru, "TOPCONN")
            dbUseArea(.T.,"TOPCONN",cTabela,cTabela,.F.)
            (cTabela)->(dbCreateIndex( cTabela+'1' , "PRODUTO+CNPJ+SEQ" , {||PRODUTO+CNPJ+SEQ}) )
            (cTabela)->(dbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",cTabela,cTabela,.T.)
        (cTabela)->(DbSetIndex(cTabela+'1'))
        
    EndIf
    
Return

/*
===============================================================================================
===============================================================================================
||   Arquivo:	EZCLIENT.prw
===============================================================================================
||   Funcao: 	Ez4Connect
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	14/12/2020
===============================================================================================
===============================================================================================
*/
Static Function Ez4Connect(cCNPJ, cProduto)

    Local oRest 
    Local oRestEnv
    Local oObjRet
    Local aHeader    := {}
    //Local cURL     := "http://177.153.229.178:8097"
    Local cURL       := "http://license.ez4.com.br:8097"
    Local cPath      := "/rest/EZLICENCAPI"
    Local cResult    := ""
    Local oJson 

    Local cIPSRVINT := Alltrim(SuperGetMV("EZ_IPSRVIN" ,.F.,""))
   //10.127.248.5                                                                                                                                                                                                                                              
    If !Empty(cIPSRVINT)
        cURL := "http://"+cIPSRVINT+":8097"
    Endif

	// Inclui Cabe�alho
 	aAdd( aHeader , "Authorization: Basic bGVvbmFyZG8ubGltYToxMjM0NTY="  )
    aAdd( aHeader , "Username: leonardo.lima"  )
    aAdd( aHeader , "Password: 123456"  )

	oRest := FWRest():New(cURL)
    oRest:SetPath( cPath + "?token="+cCNPJ+"&produto="+cProduto)

	If oRest:Get( aHeader )

        cResult := oRest:cResult

        cResult = rc4crypt(cResult, cKeyPadrao, .F., .T.)

        If FWJsonDeserialize(cResult,@oObjRet)

            oJson := JsonObject():new()
            oJson["status"]               := oObjRet:STATUS
            oJson['dataFimContrato']      := oObjRet:DATAFIMCONTRATO
            oJson['dataProximaValidacao'] := oObjRet:DATAPROXIMAVALIDACAO
            oJson['produto']              := oObjRet:PRODUTO
            oJson['contrato']             := oObjRet:contrato
            oJson['codBlock']             := oObjRet:codBlock
            oJson['chave']                := If(!Empty(oObjRet:codBlock),&(oObjRet:codBlock),"")
            oJson['cnpj']                 := oObjRet:CNPJ

            cResult := oJson:toJSON()
            cResult := rc4crypt(cResult, cKeyPadrao, .T., .F.)

            /*
            oRestEnv := FWRest():New(cURL)
            oRestEnv:SetPath( cPath + "?token="+cResult)

            If oRestEnv:Post( aHeader )

                cResult := oRestEnv:cResult

            Endif            
            */

        Endif 

    Endif 

Return cResult 

/*
===============================================================================================
===============================================================================================
||   Arquivo:	EZCLIENT.prw
===============================================================================================
||   Funcao: 	EZ4AtuTab
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	14/12/2020
===============================================================================================
===============================================================================================
*/
Static Function EZ4AtuTab(cCNPJ,cProduto,cResult)

    Local nLinhas    := 0 
    Local nPos       := 1
    Local nX         := 0 
    
    dbSelectArea((cTabela))

    If (cTabela)->(dbSeek(cProduto+cCNPJ))

        While !(cTabela)->(Eof()) .And. cProduto+cCNPJ == (cTabela)->(PRODUTO+CNPJ)
            RecLock((cTabela),.F.)
            (cTabela)->(dbDelete())
            MsUnlock()
            (cTabela)->(dbSkip())
        Enddo 
    Endif 

    nLinhas := Int(Len(cResult)/900)+1
    For nX := 1 to nLinhas
        RecLock((cTabela),.T.)
        (cTabela)->PRODUTO  := cProduto
        (cTabela)->CNPJ     := cCNPJ
        (cTabela)->SEQ      := nX
        (cTabela)->DADOS    := SubStr(cResult,nPos,900)
        MsUnlock()
        nPos+=900
    Next

Return 

*===============================================*
Static Function Decript(cString)
*===============================================*
Local cRet
 
cRet := PoliEncript(cString,"SourceSafe",1)
cRet := HexEncript(cRet,1)
 
Return cRet
 
*===============================================*
Static Function Encript(cString)
*===============================================*
Local cRet
 
cRet := PoliEncript(cString,"SolutionProvider",1)
cRet := HexEncript(cRet,1)
 
Return cRet


//-----------------------------------------------------------------------------
// Marcio Martins - 01/09/2023 - Monta HTML conforme cTipoHTML passado
//-----------------------------------------------------------------------------
User Function EZEmailSend(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)

    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cPass        := Alltrim(GetMV("MV_RELPSW"))
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .F.
  
    //Se tiver em branco o destinat�rio, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
  
    If lRet

        oMsg := TMailMessage():New()
        oMsg:Clear()

        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
 
        For nAtual := 1 To Len(aAnexos)

            nRet := oMsg:AttachFile(aAnexos[nAtual])
            If nRet < 0
                cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
            EndIf
        Next

        oSrv := tMailManager():New()

        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf

        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "003 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
  
        If lRet
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "004 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
  
            If lRet
                //Realiza a autentica��o do usu�rio e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "004 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
  
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "005 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
  
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "006 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
  
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        cLog := "LOG MENSAGENS -   "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao - " + FunName() + CRLF + CRLF +;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog
        ConOut(cLog)
     EndIf
  
    RestArea(aArea)
Return lRet

//-----------------------------------------------------------------------------
// Marcio Martins - 01/09/2023 - Monta HTML conforme cTipoHTML passado
//-----------------------------------------------------------------------------
User Function EZMontaHtml(cTipoHTML,aDados)

   Local cCorpo := ""

   If cTipoHTML =="WFCancXML"
   
      cCorpo += ' <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN"> ' + CRLF
      cCorpo += ' <!-- saved from url=(0022)http://internet.e-mail --><HTML><HEAD><TITLE>..:: WF PORTAL GRC ::..</TITLE> ' + CRLF
      cCorpo += ' <META content="text/html; charset=windows-1252" http-equiv=Content-Type> ' + CRLF
      cCorpo += ' <META name=GENERATOR content="MSHTML 8.00.6001.18904"> ' + CRLF
      cCorpo += ' <STYLE>BODY{scrollbar-face-color:#336699;scrollbar-arrow-color:#FFFFFF;scrollbar-track-color:#7B92AD;scrollbar-shadow-color:"#1C1C1C";scrollbar-highlight-color:"#7B92AD";scrollbar-3dlight-color:"#1C1C1C";scrollbar-darkshadow-Color:"#1C1C1C";}.borda_azul { border:1px solid #006699; }.style1 {color: #FFFFFF; font-family: Tahoma, Arial, sans-serif; font-size: 11; text-decoration: none; font-weight: bold; }.style2 {color: #FFFFFF; font-family: Tahoma, Arial, sans-serif; font-size: 12; text-decoration: none; font-weight: bold; }.style6 { color: #005680; font-family: Tahoma, Arial, sans-serif; font-size: 11; text-decoration: none }</STYLE> ' + CRLF
      cCorpo += ' </HEAD> ' + CRLF
      cCorpo += ' <BODY link=#0000ff vLink=#800080> ' + CRLF
      cCorpo += ' <FORM method=post name=WFMAILTO action=!cHtmlAction!> ' + CRLF
      cCorpo += ' <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" height="100%"> ' + CRLF
      cCorpo += '   <TBODY> ' + CRLF
      cCorpo += ' 	<TR> ' + CRLF
      cCorpo += ' 		<TD vAlign=top align=middle> ' + CRLF
      cCorpo += ' 			<TABLE border=0 cellSpacing=2 cellPadding=2 width="100%" height="10%"> ' + CRLF
      cCorpo += ' 				<TBODY> ' + CRLF
      cCorpo += ' 					<TR> ' + CRLF
      cCorpo += ' 						<TD class=borda_azul height="5%" align=middle> ' + CRLF
      cCorpo += ' 							<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" height=40> ' + CRLF
      cCorpo += ' 								<TBODY> ' + CRLF
      cCorpo += ' 									<TR> ' + CRLF
      cCorpo += ' 										<TD bgColor=#006699 height=5 colSpan=3></TD> ' + CRLF
      cCorpo += ' 									</TR> ' + CRLF
      cCorpo += ' 									<TR> ' + CRLF
      cCorpo += ' 										<TD vAlign=center> ' + CRLF
      cCorpo += ' 											<br>&nbsp;&nbsp;&nbsp; ' + CRLF
      cCorpo += ' 											<img border="0" src='+aDados[1]+' width="146" height="56"> ' + CRLF
      cCorpo += ' 											<br><br>				 ' + CRLF
      cCorpo += ' 										</TD>				  ' + CRLF
      cCorpo += ' 										<TD vAlign=left> ' + CRLF
      cCorpo += ' 											<FONT color=#006699> ' + CRLF
      cCorpo += ' 												<H2 align=left><B>'+aDados[2]+'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</B></H2> ' + CRLF
      cCorpo += ' 											</FONT> ' + CRLF
      cCorpo += ' 										</TD> ' + CRLF
      cCorpo += ' 									</TR> ' + CRLF
      cCorpo += ' 									<TR> ' + CRLF
      cCorpo += ' 										<TD bgColor=#006699 height=5 colSpan=3></TD> ' + CRLF
      cCorpo += ' 									</TR> ' + CRLF
      cCorpo += ' 								</TBODY> ' + CRLF
      cCorpo += ' 							</TABLE> ' + CRLF
      cCorpo += ' 						</TD> ' + CRLF
      cCorpo += ' 					</TR> ' + CRLF
      cCorpo += ' 				</TBODY> ' + CRLF
      cCorpo += ' 			</TABLE> ' + CRLF
      cCorpo += ' 			<TABLE border=0 cellSpacing=2 cellPadding=2 width="100%" height="90%"> ' + CRLF
      cCorpo += ' 				<TBODY> ' + CRLF
      cCorpo += ' 					<TD class=borda_azul vAlign=top> ' + CRLF
      cCorpo += ' 						<TABLE border=0 cellSpacing=1 cellPadding=0 width="100%" height="100%"> ' + CRLF
      cCorpo += ' 							<TBODY> ' + CRLF
      cCorpo += ' 								<TR> ' + CRLF
      cCorpo += ' 									<TD vAlign=top colSpan=2> ' + CRLF
      cCorpo += ' 										<TABLE border=0 cellSpacing=1 cellPadding=1 width="100%" background=""> ' + CRLF
      cCorpo += ' 											<TBODY> ' + CRLF
      cCorpo += ' 												<TR height=20> ' + CRLF
      cCorpo += ' 													<TR height="5%"> ' + CRLF
      cCorpo += ' 														<TD class=style6 background="" width="10%"><B>Prezados,</B></TD> ' + CRLF
      cCorpo += ' 													</TR> ' + CRLF
      cCorpo += ' 													<TR height="5%"> ' + CRLF
      cCorpo += ' 														<TD class=style6 background="" width="10%"> ' + CRLF
      cCorpo += ' 															<br><br> ' + CRLF
      cCorpo += ' 															&nbsp;&nbsp;&nbsp;&nbsp; ' + CRLF
      cCorpo += ' 															Informamos que recebemos o cancelamento da Nota Fiscal '+aDados[3]+', pertencente a empresa '+aDados[6]+' ' + CRLF
      cCorpo += ' 															<br><br><br> ' + CRLF
      cCorpo += ' 															&nbsp;&nbsp;&nbsp;&nbsp; ' + CRLF
      cCorpo += ' 															<b>Chave Acesso: '+aDados[4]+' '+ CRLF
      cCorpo += ' 															<br><br><br> ' + CRLF
      cCorpo += ' 															&nbsp;&nbsp;&nbsp;&nbsp; ' + CRLF
      cCorpo += ' 															<b>Data Cancelamento: '+aDados[6]+' '+ CRLF
      cCorpo += ' 															<br><br><br> ' + CRLF
      cCorpo += ' 															&nbsp;&nbsp;&nbsp;&nbsp; ' + CRLF
      cCorpo += ' 															<b>Motivo: '+aDados[7]+' ' +CRLF										
      cCorpo += ' 														</TD> ' + CRLF
      cCorpo += ' 													</TR> ' + CRLF
      cCorpo += ' 												</TR> ' + CRLF
      cCorpo += ' 											</TBODY> ' + CRLF
      cCorpo += ' 										</TABLE> ' + CRLF
      cCorpo += ' 									</TD> ' + CRLF
      cCorpo += ' 								</TR> ' + CRLF
      cCorpo += ' 							</TBODY> ' + CRLF
      cCorpo += ' 						</TABLE> ' + CRLF
      cCorpo += ' 					</TD> ' + CRLF
      cCorpo += ' 				</TBODY> ' + CRLF
      cCorpo += ' 			</TABLE> ' + CRLF
      cCorpo += ' 		</TD> ' + CRLF
      cCorpo += ' 	</TR> ' + CRLF
      cCorpo += '   </TBODY> ' + CRLF
      cCorpo += ' </TABLE> ' + CRLF
      cCorpo += ' </FORM> ' + CRLF
      cCorpo += ' </BODY> ' + CRLF
      cCorpo += ' </HTML> ' + CRLF

   Endif 

Return cCorpo

/*
===============================================================================================
||   Funcao: 	GRC_NPDF
===============================================================================================
||		Visualiza a danfe com base na Chave
===============================================================================================
||   Autor:	Marcio Martins Pereira
||   Data:	10/11/2020
===============================================================================================
*/
User function GRC_NPDF()
	
	Local cPasta := GetTempPath()
	Local lSeek  := .T.

	 

	// Se n�o Estiver vazio, veio de uma chamada externa
	If Empty(EZ0->EZ0_NOMPDF)
			MsgAlert("Documento N�o encontrado!")
			lSeek := .F.
	Endif 

	If lSeek
		
		//Cria o arquivo selecionado pelo usu�rio
      cFile := Alltrim(Substr(EZ0->EZ0_NOMPDF,Rat('\',EZ0->EZ0_NOMPDF)+1))
		lRet  := MemoWrite(cPasta+cFile, DECODE64(EZ0->EZ0_ARQPDF))

      if lRet

		// Visualiza o documento PDF
		ShellExecute("open",lower(cPasta+cFile),"","",5) 
      Endif
	Endif 

Return 

/*
===============================================================================================
||   Funcao: 	ProcNFn
===============================================================================================
||		Realiza o processamento das notas de servico Ambiente Nacional
||                                                                                              
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	Outubro-2023
===============================================================================================
*/
User Function ProcNFn(oSelf, lSchedule)
   Local aArea      := GetArea()
	Local lRet       := .T.
	Local lValida	  := .T.
	Local cError     := ""
	Local cWarning   := ""
	Local lContinua  := .T.
	Local cURL       := "https://adn.nfse.gov.br/contribuintes" 
   Local cRecurso   :=  ""
   Local aHeadOut   := {} 
   Local cGetRet    := ""
   Local cHeadRet  := ""
   Local oJsObj
   Local i          := 0
   Local cNSUNFSE   := "" 
   Local nTimeout   := 60
   Local cGetParam  := ''  
   Local lprima     := .t.
   Default lSchedule := .f.
/*
   RpcClearEnv()
   RpcSetType(3)
   RpcSetEnv('99','01')
*/
	Private oXmlDocZip
	Private cUnXML	:= ''
	Private cOrigem := ''
   Private lResumos := 0
   Private lXMLBaixa := 0 

   EzCheckPar(xFilial("EZ0"))
   cNSUNFSE  := GETMV("EZ_NSUNFSE") //SuperGetMV("EZ_NSUNFSE",.F.,'0') 
   cULTNSU   := GETMV("EZ_NSUNFSE")  //SuperGetMV("EZ_NSUNFSE",.F.,'0')
   AAdd( aHeadOut, 'Accept: text/plain' ) 
   while .t.  // enquanto possuir documento
      if !lprima 
         cNSUNFSE := Alltrim(Str(cNSU))
      endif
      lprima   := .f.
      cRecurso :=  "/DFe/"+cNSUNFSE
      cGetRet  := HTTPSGet( cURL+cRecurso, "\certs\000566_cert.pem", "\certs\000566_key.pem", "140404", cGetParam, nTimeOut, aHeadOut, @cHeadRet )
      //https://tdn.totvs.com/display/tec/HTTPSGet e https://devforum.totvs.com.br/1373-consumir-api-https-do-banco-central
      if Empty( cGetRet )
         conout( "Fail HTTPSGet" )
         lContinua := .f.
      else
         conout( "OK HTTPSGet" )
         lContinua := .t.
      endif
      If lContinua
         FWJsonDeserialize(cGetRet,@oJsObj)
         IF oJsObj:StatusProcessamento == "DOCUMENTOS_LOCALIZADOS"
            IF len(oJsObj:LOTEDFE)>0
               for i:= 1 to len(oJsObj:LOTEDFE)
                  cNSU   := oJsObj:LOTEDFE[i]:NSU
                  cULTNSU:= strZero((cNSU),15)
                  If !lSchedule
                     oSelf:IncRegua1("Processando NSU: " + CValToChar(cNSU) )
                     oSelf:SetRegua2(5)
                     oSelf:IncRegua2("Busca XML")
                  Else
                     Conout("Processando NSU: " + CValToChar(cNSU) )
                  Endif
                  // Lendo os dados do JSON
                  cTPNF  := oJsObj:LOTEDFE[i]:TIPODOCUMENTO
                  cCHVNFE:= oJsObj:LOTEDFE[i]:CHAVEACESSO
                  cDATAHR:= oJsObj:LOTEDFE[i]:DATAHORAGERACAO
                  nTamanho:= Len(oJsObj:LOTEDFE[i]:ARQUIVOXML)
                  cXML   := Decode64(oJsObj:LOTEDFE[i]:ARQUIVOXML)
                  cUnXML := ""
                  lRet   := GzStrDecomp(cXML, nTamanho, @cUnXML)
                  //Transforma a resposta em um objeto
                  oXmlDocZip := XmlParser(cUnXML, "_", @cError, @cWarning)
                  //Se existir Warning, mostra no console.log
                  If ! Empty(cWarning)
                     ConOut("[consWSNFSE] - Alerta cWarning: " + cWarning)
                     lContinua := .F.
                  EndIf  
                  //Se houve erro, nao permitira prosseguir
                  If ! Empty(cError)
                     ConOut("[consWSNFSE] - Erro cError: " + cError)
                     lContinua := .F.
                  EndIf 
                  if lContinua  
                     PTNSPGrvXML(cUnXML,oSelf,lSchedule,cCHVNFE,cNSU)
                     lValida := .T. 
                  Endif 
               next
               //Atualizando Parametro
               PutMV("EZ_NSUNFSE",cULTNSU)
            Endif 
         Else
            ConOut("[consWSNFSE] - N�o h� mais Documentos")
            exit
         Endif  
      Endif
   enddo
   RestArea(aArea)
Return

/*/////////////////////////// POC LICITA��O ///////////////////////////////////////////
/*
===============================================================================================
||   Funcao: 	xVLDFOR
===============================================================================================
||		Realiza a valida��o do fornecedor junto a Receita Federal em rela��o a sua situa��o
||                                                                                              
===============================================================================================
||   Autor:	Carla Barbosa
||   Data:	Mar�o-2026
===============================================================================================
*/
User Function xVLDFOR(cCnpj,cCHAVE)
   Local aArea      := GetArea()
	Local lContinua  := .T.     
	Local cURL       := SuperGetMV("EZ_URLRCWS",.F.,"https://receitaws.com.br/v1")  
   Local cRecurso   := SuperGetMV("EZ_ENDRCWS",.F.,"/cnpj/")
   Local aHeadOut   := {} 
   Local cGetRet    := ""
   Local cHeadRet  := ""
   Local oJsObj
   Local nTimeout   := 60
   Local cGetParam  := ''  
   Local lDeuCerto  := .f.
/*
   RpcClearEnv()
   RpcSetType(3)
   RpcSetEnv('99','01')
*/

SA2->(dbsetorder(3))
SA2->(dbgotop())
if SA2->(dbseek(xfilial("SA2")+cCnpj))
   IF SA2->A2_RFCONS >= dDataBase
      lContinua := .f.
      lDeuCerto := .t.
      EZ0->(dbsetOrder(1))
      EZ0->(dbgotop())
      if EZ0->(dbseek(xFilial("EZ0")+cCHAVE))
         if EZ0->(RecLock("SA2",.f.))
            If Empty(Alltrim(EZ0->EZ0_FORNEC))
               EZ0->EZ0_FORNEC  := A2_COD
               EZ0->EZ0_LOJA    := A2_LOJA
            Endif
            EZ0->EZ0_RFDTAB  := SA2->A2_RFDTAB  // Data de Abertura da Empresa
            EZ0->EZ0_RFSITU  := SA2->A2_RFSITU    // Situa��o da Empresa na Receita Federal
            EZ0->EZ0_RFOPTA  := SA2->A2_RFOPTA     // Optante do Simples
            EZ0->EZ0_RFATUA  := SA2->A2_RFATUA    // Data da Ultima Atualiza��o
            EZ0->EZ0_RFEXCL  := SA2->A2_RFEXCL    // Data da Exclus�o
            EZ0->(MsUnLock())  
         Endif     
      Endif
   Endif
Endif

if lContinua
   AAdd( aHeadOut, 'Accept: application/json' )
   cCNPJ      := U_LimpaCNPJ(cCNPJ) 
   cRecurso += cCNPJ
   cGetRet  := HTTPSGet( cURL+cRecurso, "", "", "", cGetParam, nTimeOut, aHeadOut, @cHeadRet )
   // cGetRet  := HTTPSGet( cURL+cRecurso, "\certs\000566_cert.pem", "\certs\000566_key.pem", "140404", cGetParam, nTimeOut, aHeadOut, @cHeadRet )
   //https://tdn.totvs.com/display/tec/HTTPSGet e https://devforum.totvs.com.br/1373-consumir-api-https-do-banco-central
   if Empty( cGetRet )
      conout( "Fail HTTPSGet" )
      lContinua := .f.
   elseif len(cGetRet) <= 60
      conout( "Fail HTTPSGet" )
      lContinua := .f.
   Else
     conout( "OK HTTPSGet" )
     lContinua := .t.
   endif
   If lContinua
      FWJsonDeserialize(cGetRet,@oJsObj)
      SA2->(dbsetorder(3))
      SA2->(dbgotop())
      if SA2->(!dbseek(xfilial("SA2")+cCnpj))
         lDeuCerto := .F.
   		cCod := GetSXeNum("SA2", "A2_COD")
         cLoja   := "01"
   		If __lSX8
				ConfirmSX8()
			EndIf
         nTam      := tamSx3("A2_NOME")[1]
         cA2_NOME  := Substr(Alltrim(oJsObj:NOME),1,nTam)
         nTam      := tamSx3("A2_END")[1]
         cA2_END   := Alltrim(oJsObj:logradouro)+", "+AllTrim(oJsObj:numero)
         cA2_END   := Substr(cA2_END,1,nTam)
         nTam      := tamSx3("A2_MUN")[1]
         cDescMun  := Alltrim(oJsObj:municipio)
         cDescMun  := Substr(cDescMun,1,nTam)
         cA2_EST   := Alltrim(oJsObj:uf)
         nTam      := tamSx3("A2_BAIRRO")[1]
         cA2_BAIRRO:= Alltrim(oJsObj:bairro)
         cA2_BAIRRO:= Substr(cA2_BAIRRO,1,nTAM)
         nTam      := tamSx3("A2_NREDUZ")[1]
         cFantasia := Alltrim(oJsObj:fantasia)
         cFantasia := Substr(cFantasia,1,nTAM)
         If Empty(cFantasia)
            cFantasia := Substr(cA2_NOME,1,nTAM)
         Endif
         cCep      := Alltrim(oJsObj:cep)
         cCep      := StrTran(cCep,"-","")
         cCep      := StrTran(cCep,".","")
         nTam      := tamSx3("A2_EMAIL")[1]
         cEmail    := Alltrim(oJsObj:email)
         cEmail    := Substr(cEmail +Space(nTam),1,30)
         cTelefone := Alltrim(oJsObj:telefone)
         cCodMun   := ""
         cCodPais  := "105"
         cPaisBac  := "01058"
         cBlqSA    := "2"
         cTipPessoa:= "OS"
         cTp       := IF(LEFT(cCNPJ,2) == ' ',' ',IF(LEN(TRIM(cCNPJ))<14,"F","J"))
         IF Valtype(oJsObj:ABERTURA) == "C"
            cDtAbertura   := SToD( SubStr(oJsObj:ABERTURA,7,4) + SubStr(oJsObj:ABERTURA,4,2) + SubStr(oJsObj:ABERTURA,1,2) )
         Else
            cDtAbertura   := Ctod("  /  /  ")
         Endif
         IF Valtype(oJsObj:SITUACAO)  == "C" 
            cSituacao     := oJsObj:SITUACAO
         Else
            cSituacao     := ""
         Endif
         IF Valtype(oJsObj:SIMPLES:OPTANTE) != Nil 
            cOPTSIMP      := IIF(oJsObj:SIMPLES:OPTANTE,"1","2")
         Else
            cOPTSIMP      := "2"
         Endif
         IF ValType(oJsObj:SIMPLES:ULTIMA_ATUALIZACAO) == "C"
            dUltAtual     := STOD(SUBSTRING(STRTRAN(oJsObj:SIMPLES:ULTIMA_ATUALIZACAO,"-",""),1,8))
         Else
            dUltAtual     := Ctod("  /  /  ")
         Endif
   
         if ValType(oJsObj:SIMPLES:DATA_EXCLUSAO) == "C"
            dExclusao     := STOD(SUBSTRING(STRTRAN(oJsObj:SIMPLES:DATA_EXCLUSAO,"-",""),1,8))
         Else 
            dExclusao     := Ctod("  /  /  ")
         Endif
              
         //Pegando o modelo de dados, setando a opera��o de inclus�o
         oModel := FWLoadModel("MATA020M")
         oModel:SetOperation(3)
         oModel:Activate()
 
         oSA2Mod:= oModel:getModel("SA2MASTER")
         oSA2Mod:setValue("A2_COD",       cCod              ) // Codigo 
         oSA2Mod:setValue("A2_LOJA",      cLoja             ) // Loja
         oSA2Mod:setValue("A2_NOME",      cA2_NOME          ) // Nome             
         oSA2Mod:setValue("A2_NREDUZ",    cFantasia         ) // Nome reduz. 
         oSA2Mod:setValue("A2_END",       cA2_END           ) // Endereco
         oSA2Mod:setValue("A2_BAIRRO",    cA2_BAIRRO        ) // Bairro
         oSA2Mod:setValue("A2_TIPO",      cTp               ) // Tipo 
         oSA2Mod:setValue("A2_EST",       cA2_EST           ) // Estado
         oSA2Mod:setValue("A2_COD_MUN",   cCodMun           ) // Codigo Municipio                
         oSA2Mod:setValue("A2_MUN",       cDescMun          ) // Municipio
         oSA2Mod:setValue("A2_CEP",       cCep              ) // CEP
         oSA2Mod:setValue("A2_CGC",       cCNPJ             ) // CNPJ/CPF            
         oSA2Mod:setValue("A2_PAIS",      cCodPais          ) // Pais            
         oSA2Mod:setValue("A2_EMAIL",     cEMail            ) // E-Mail     
         oSA2Mod:setValue("A2_TEL",       cTelefone         ) // Fone                   
         oSA2Mod:setValue("A2_TPESSOA",   cTipPessoa        ) // Tipo Pessoa
         oSA2Mod:setValue("A2_CODPAIS",   cPaisBac          ) // Pais Bacen
         oSA2Mod:setValue("A2_MSBLQL",    cBlqSA            ) // Bloqueado
         oSA2Mod:setValue("A2_RFDTAB",     cDtAbertura     ) // Dt Ab Empres    
         oSA2Mod:setValue("A2_RFSITU",     cSituacao       ) // Situa��o RF                  
         oSA2Mod:setValue("A2_RFOPTA",     cOPTSIMP        ) // Optante Simp
         oSA2Mod:setValue("A2_RFATUA",     dUltAtual       ) // Ult Atualiz
         oSA2Mod:setValue("A2_RFEXCL",     dExclusao       ) // Dt Exclusao   
         oSA2Mod:setValue("A2_RFCONS",     ddatabase       ) // Dt Consulta 
         oSA2Mod:setValue("A2_SIMPNAC",     cOPTSIMP       ) // Opt Simp Nac
 
                 
         //Se conseguir validar as informa��es
         If oModel:VldData()
            //Tenta realizar o Commit
            If oModel:CommitData()
               lDeuCerto := .T.      
               //Se n�o deu certo, altera a vari�vel para false
            Else
               lDeuCerto := .F.
            EndIf
            //Se n�o conseguir validar as informa��es, altera a vari�vel para false
         Else
            lDeuCerto := .F.
         EndIf          
            //Desativa o modelo de dados
         oModel:DeActivate()
         oModel:Destroy()
			oModel := NIL
      Else // Portal 
         IF Valtype(oJsObj:ABERTURA) == "C"
            cDtAbertura   := STOD(SUBSTRING(STRTRAN(oJsObj:ABERTURA,"-",""),1,8))
         Else
            cDtAbertura   := Ctod("  /  /  ")
         Endif
         IF Valtype(oJsObj:SITUACAO)  == "C" 
            cSituacao     := oJsObj:SITUACAO
            cOPTSIMP      := IIF(oJsObj:SIMPLES:OPTANTE,"S","N")
         Else
            cOPTSIMP      := "N"
         Endif
         IF ValType(oJsObj:SIMPLES:ULTIMA_ATUALIZACAO) == "C"
            dUltAtual     := STOD(SUBSTRING(STRTRAN(oJsObj:SIMPLES:ULTIMA_ATUALIZACAO,"-",""),1,8))
         Else
            dUltAtual     := Ctod("  /  /  ")
         Endif
         if ValType(oJsObj:SIMPLES:DATA_EXCLUSAO) == "C"
            dExclusao     := STOD(SUBSTRING(STRTRAN(oJsObj:SIMPLES:DATA_EXCLUSAO,"-",""),1,8))
         Else 
            dExclusao     := Ctod("  /  /  ")
         Endif
         // Gravando os dados na Tabela EZ0 para posterior valida��o pelo Portal GRC
         SA2->(RecLock("SA2",.f.))
         SA2->A2_RFDTAB  := cDtAbertura  // Data de Abertura da Empresa
         SA2->A2_RFSITU  := cSituacao    // Situa��o da Empresa na Receita Federal
         SA2->A2_RFOPTA  := cOPTSIMP     // Optante do Simples
         SA2->A2_RFATUA  := dUltAtual    // Data da Ultima Atualiza��o
         SA2->A2_RFEXCL  := dExclusao    // Data da Exclus�o
         SA2->A2_RFCONS  := ddatabase    ///Data da Consulta
         SA2->(MsUnLock())   
         lDeuCerto := .T.
      Endif
   Endif 
   EZ0->(dbsetOrder(1))
   EZ0->(dbgotop())
   if EZ0->(dbseek(xFilial("EZ0")+cCHAVE))
      if EZ0->(RecLock("EZ0",.f.))
         If Empty(Alltrim(EZ0->EZ0_FORNEC))
            EZ0->EZ0_FORNEC  := cCOD
            EZ0->EZ0_LOJA    := cLOJA
         Endif
         EZ0->EZ0_RFDTAB  := cDtAbertura  // Data de Abertura da Empresa
         EZ0->EZ0_RFSITU  := cSituacao    // Situa��o da Empresa na Receita Federal
         EZ0->EZ0_RFOPTA  := cOPTSIMP     // Optante do Simples
         EZ0->EZ0_RFATUA  := dUltAtual    // Data da Ultima Atualiza��o
         EZ0->EZ0_RFEXCL  := dExclusao    // Data da Exclus�o
         EZ0->(MsUnLock())  
      Endif     
   Endif
Endif
   RestArea(aArea)
Return lDeuCerto  

/*
===============================================================================================
||   Funcao: 	xNoraNfse
===============================================================================================
||		Realiza a chama da API Nora AI para captura dos dados via IA 
||    Os Dados s�o Convertidos em NFSE
============================================================================================
||   Autor:	Carla Barbosa
||   Data:	Mar�o-2026
===============================================================================================
*/

User Function xNoraNfse(oSelf,lSchedule, cDiretorio)  //(oSelf, lSchedule)

    Local oProcess
    Local lEnd := .F.
    Private LUSAAS400 := .f. 
    Default lXMLNORA    := .t.
    Default cDiretorio  := SuperGetMV("EZ_LOCPDF",.F.,'\xmlnfe\pdf\')  

    oProcess:=  MsNewProcess():New({|lEnd| ProcNora(cDiretorio,@oProcess,lEnd,.F., oSelf)}, "Nora API - Leitura NFServico" , "Nora API - Leitura NFServico", .T.)
    oProcess:Activate()

Return 

Static Function ProcNora(cFile, oProcess. lEnd, lSchedule, oSelf)
 

   Local aArea      := GetArea()
	Local lValida	  := .T.
   Local aHeadOut   := {} 
   Local cApiKey    := ''
	Local cURL       :=  ""  
   Local cEndPoint  :=  ""
   Local cBody      := ""
   Local oJson      := JsonObject():New()
   Local oJsonExt   := JsonObject():New()
   Local cFileName  := ""
   Local cFileCont  := ""
   Local cMimeType  := ""
   Local aHeadExt   := {}
   Local cHeadRet   := ""
   Local cResponse  := ""
   Local cRespExt   := ""
   Local cFileCompl := ""
   Local aFiles     := {}
   Local nPos       := 0
   Local nTimeOut   := 60
   Local cHeadExt   := ""
   Local lVldCnpj   := .F.  //SupergetMV("EZ_VLDCNPJ",.F.,.F.)
   Local lConcluido := .f.
   Local oFile       := NIL
   Default lSchedule := .f.

/*
   RpcClearEnv()
   RpcSetType(3)
   RpcSetEnv('99','01')
*/

	Private oXmlDocZip
	Private cUnXML	:= ''
	Private cOrigem := ''
   Private lResumos := 0

   Private lXMLBaixa := 0 

   cUrl     := SuperGetMV("EZ_URLNORA",.F.,"https://api.nora.dclick.com.br")
   cCodAgent:= SuperGetMV("EZ_AGENORA",.F.,"eIHWb_AQ80")
   //cApi_key :- SuperGetMV("EZ_KEYNORA",.F.,"edad56a7516f7ad7339ffb5d52ac40fdb283447612ab94c6baa7af3c9dd5cc45")
   cEndPoint:= "/agents/" + cCodAgent + "/execute"
   cEndExtra:= "/extractions/track/"
   cApiKey  := "edad56a7516f7ad7339ffb5d52ac40fdb283447612ab94c6baa7af3c9dd5cc45"
   cFile  := Alltrim(cFile)

   If Right(cFile, 1) != "\"
      cFile += "\"
   EndIf

   aFiles := DIRECTORY(cFile+"\*.PDF", "D")

   AAdd(aHeadOut, "Content-Type: application/json")
   AAdd(aHeadOut, "x-api-key: " + cApiKey)
   AAdd(aHeadExt, "x-api-key: " + cApiKey)

   for nPos:= 1 to len(aFiles)
     
      lConcluido := .f.
      cFileCompl := cFile+Alltrim(aFiles[nPos][1]) 

      // 1. Preparar arquivo
      //Se o arquivo existir
      If File(cFileCompl)
        //Tenta abrir o arquivo e pegar o conteudo
        oFile := FwFileReader():New(cFileCompl)
        
         If oFile:Open()
            
            cFileName   := SubStr(cFileCompl, Rat("\", cFileCompl) + 1)
            cPathCompl  := cFileCompl  // guarda o caminho antes de sobrescrever
            cFileCompl  := oFile:FullRead()
            cFileCont   := Encode64(cFileCompl, , .F., .F.)
            cMimeType   := GetMimeType(cFileName)

            // 2. Montar Body JSON
            oJson := JsonObject():New()
            oJson["content"]  := cFileCont
            oJson["mimeType"] := cMimeType
            oJson["fileName"] := cFileName
            cBody := oJson:ToJson() 
     
            // 4. Executar POST
            cResponse := HttpPost( cUrl+cEndPoint, "", cBody, nTimeOut, aHeadOut, @cHeadRet )
            oJson:FromJson(cResponse) 
            If ValType(oJson["trackingCode"]) == "C"
              cTrackCode := oJson["trackingCode"]
              cExtId     := oJson["extractionId"]
              lSuccess   := .T.
              cEndExtra:= "/extractions/track/"+Alltrim(cTrackCode)

              // Fazendo o POST para acomanhamento e extra��o dos dados da NF
              // Configurar Headers para chamada da API Monitoramento e Extra��o do XML
              // Fazer a requisicao GET para o status
               While ! lConcluido 
               
                  Sleep(3000)
                  lGerou   := .f.
                  cRespExt := HTTPSGet( cURL+cEndExtra, "", "", "", , 60, aHeadExt, @cHeadExt )
                  oJsonExt  := JsonObject():New()
                  oJsonExt:FromJson(cRespExt)
                  cStatus   := oJsonExt["extraction"]["status"]

                  //Valido o status, se estiver em processamento eu aguardo e n�o saiu do loop
                  If cStatus == "success"
                     lConcluido := xNoraDoc(oSelf,  oJsonExt, lSchedule, @lGerou)
                  Elseif cStatus == "processing" .Or. cStatus == "pending"
                     lConcluido := .F.
                  Elseif cStatus == "error"
                     lConcluido := .T.
                  Endif

               Enddo
            Else
               Help(,, "ERRO API",, "Resposta inv�lida da API Nora: " + cResponse, 1, 0)
               lConcluido := .T.
            EndIf
            
            if lGerou
               FRename(cPathCompl, cPathCompl + ".processado")     
            Endif

            oFile:Close()
         Endif
      Endif
   Next

   RestArea(aArea)  

return lValida

Static Function xNoraDoc(oSelf,  oJsonExt, lSchedule, lGerou)

Local lRet := .t.
Local cErrorMsg := ""  
Local oJsonRes  := JsonObject():New()
Local cResult   := ""
Local cCHVNFE   := ""
Local cCNPJ     := ""
Local cNota     := ""
Local lVldCnpj  := .f.
Local cErrorMsg  := ""

If ValType(oJsonExt["extraction"]) == "J"
   
   cErrorMsg := oJsonExt["extraction"]["errorMessage"]

      lRet := .T.   
      cResult    := oJsonExt["extraction"]["resultJson"]
      oJsonRes:FromJson(cResult)
      cCNPJ      := Alltrim(oJsonRes["cliente_cnpj_cpf"])
      cCNPJ      := U_LimpaCNPJ(cCNPJ)     
      cCHVNFE    := Alltrim(oJsonRes["chave_nota"])

      cNota      := Alltrim(oJsonRes["numero_nota"])

      If lVldCnpj
         if AllTrim(SM0->M0_CGC) <> cCNPJ 
            lRet := .f.
         Endif
      Endif
    
      cXML       := oJsonExt["xml"]

      // Cria o Registro na EZ0
      lGerou := PTNoraGrvXML(cXML,oSelf,lSchedule,cCHVNFE,cCNPJ)
Endif

Return lRet

/*/{Protheus.doc} zFile64
Retorna o arquivo em Base64.
/*/
Static Function zFile64(cArquivo)
    Local cConteudo := ""
    Local cString64 := ""
    Local oFile
 
    //Se o arquivo existir
    If File(cArquivo)
 
        //Tenta abrir o arquivo e pegar o conteudo
        oFile := FwFileReader():New(cArquivo)
        If oFile:Open()
 
            //Se deu certo abrir o arquivo, pega o conteudo e transforma em base 64
            cConteudo  := oFile:FullRead()
            cString64  := Encode64(cConteudo, , .F., .F.)
        EndIf
        oFile:Close()
    EndIf
Return cString64


/*/{Protheus.doc} GetMimeType
Retorna o MimeType baseado na extens�o.
/*/
Static Function GetMimeType(cFile)
    Local cExt := Lower(SubStr(cFile, Rat(".", cFile) + 1))
    Do Case
        Case cExt == "pdf"  ; Return "application/pdf"
        Case cExt == "jpg" .Or. cExt == "jpeg" ; Return "image/jpeg"
        Case cExt == "png"  ; Return "image/png"
        Case cExt == "txt"  ; Return "text/plain"
    EndCase
Return "application/octet-stream"

USER Function LimpaCNPJ(cCNPJ)

   // ajuste preventivo na sintaxe das tags para eliminar espacos indesejaveis
   cCNPJ:= StrTran(cCNPJ, ".", "")  // elimina espaco no comeco da TAG de abertaura
   cCNPJ:= StrTran(cCNPJ, "/", "")  // caso exista uma tag com 2 espacos
   cCNPJ:= StrTran(cCNPJ, "-", "") // elimina espaco no comeco da TAG de fechamento
   cCNPJ:= StrTran(cCNPJ, " ", "")
Return cCNPJ

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PTNoraGrvXML
Processa os XML da API Nora - NFSE  
@type Function
@author    Carla Barbosa
@version   1.xx
@since     06/09/2023
/*/
//------------------------------------------------------------------------------------------  

Static Function PTNoraGrvXML(cConteudo,oSelf, lSchedule,cCHVNFE,cCNPJ)

   Local aArea       := getArea()
   Local lRet        := .T. 
   Local cUnXML      := cConteudo
   Local cXMLDIR     := Alltrim(SuperGetMV("EZ_LOCXML",.F.,"\xmlnfe\"))
   Local i
   Private lUsaPort  := SuperGetMV("EZ_USAPORT",.F.,.F.)

   Default nOpcao := 1
   Default cCHVNFE:= ""

   If !Empty(cXMLDIR)
      If !ExistDir(cXMLDIR)
         MakeDir(cXMLDIR)
      Endif
      If Left(cXMLDIR,1)<>"\"
         cXMLDIR := "\"+cXMLDIR
      Endif
      If Right(cXMLDIR,1)<>"\"
         cXMLDIR := cXMLDIR+"\"
      Endif 
   Endif 

   Default lSchedule 	:= FWGetRunSchedule()

   // Gravando NSU 
   // EZGravDNsu(StrZero((cNSU),15),"1",cCHVNFE) /// gravando o NSU
   
      If AT("<extraction>",cUnXML) > 0     // Verifica se � NFSE DA API NORA  
         if !Empty(alltrim(cCHVNFE))
            cCHVNFE    := XMLTagCont('chave_nota', cUnXML)
            cCHNFSE       := cCHVNFE
            cCHVNFE       := Substr(cCHVNFE,7,44)
            cLocInc       := Substr(cCHVNFE,1,06)
            if Alltrim(cCHVNFE) <> "null" // deu erro na extra��o
               // volumetria
               //U_EZVolUpdate('NFn') 
               dbSelectArea("EZ0")
               EZ0->(dbSetOrder(1))
               If !EZ0->(dbSeek(xFilial("EZ0")+cCHVNFE))
                  RecLock("EZ0",.T.)  // n�o tinha o resumo
               else
                  RecLock("EZ0",.F.)  // j� tinha o resumo - carla
               Endif   
               EZ0->EZ0_FILIAL := xFilial("EZ0")
               EZ0->EZ0_CHVNFE := cCHVNFE
               if EZ0->(FieldPos("EZ0_CHNFSE"))>0
                  EZ0->EZ0_CHNFSE := cCHNFSE
               Endif
               EZ0->EZ0_XMLNFE := cUnXML
               EZ0->EZ0_TIPONF := "NFa"
               EZ0->EZ0_CNPJEM := cCNPJ
               //EZ0->EZ0_ULTNSU := StrZero((cNSU),15) 
               EZ0->EZ0_DTEMI  := xConteudo("data", "data_emissao"    , "xCont := StoD(StrTran(SubStr( xCont,1,10),'-',''))", cUnXML, "D")  // insere o dado na tabela
               EZ0->EZ0_VLDOC  := xConteudo("data", "valor_total"  , "xCont := val( xCont )"                             , cUnXML, "N")  // insere o dado na tabela 
               //EZ0->EZ0_DPSID  := SubStr(cUnXML,AT("<infDPS Id=",cUnXML)+Len("<infDPS Id=")+1,45) // insere o dado na tabela 
               //EZ0->EZ0_IEEMIT := xConteudo("InfNfse", "IE"   , "xCont := Alltrim(xCont)"                           , cUnXML, "C")  // insere o dado na tabela 
               If EZ0->(FieldPos("EZ0_DTBXML")) > 0 
                  EZ0->EZ0_DTBXML := ddatabase
               Endif 
               EZ0->(EZ0_STIN()) 
               MsUnlock()
               If !Empty(cXMLDIR)
                  Conout("NF-e - Salvo na pasta " + cXMLDIR)
                  lRet := MemoWrite(cXMLDIR+"nsp-"+EZ0->EZ0_CHVNFE+".xml",EZ0->EZ0_XMLNFE)
               Endif 
               If  EZ0->EZ0_STINTE > '0'
                  aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
                  for i:=1 to Len(aChaves)
                     EZ0->(dbGoTo(aChaves[i,2]))                        // posiciona na EZ0
                     ExtraiDadosXML(aChaves[i],'NFa')
                     VldDadosNF(aChaves[i])
                     RecLock("EZ0",.F.)
                     EZ0->(EZ0_STIN()) // 03/01/2022 - MARCIOP - Atualiza o status apos a inclusao
                     MsUnlock()
                        
                     If SuperGetMV("EZ_PX_PNAU" ,.F.,.F.) 
                        If ValidaCFOP()
                              lRet := U_AndaProcesso("A",lSchedule)  // Gero o Documento
                        Else
                           if lUsaPort
                              lRet := U_AndaProcesso("1",lSchedule) // Avanco o processo para a portaria
                           Else 
                              lRet := U_AndaProcesso("A",lSchedule) // Gero o Documento  // Move para o 
                           Endif 
                        Endif 
                     Endif
                  next
               Endif
               //EZGravDNsu(StrZero((cNSU),15),"3",cCHVNFE) /// gravando o NSU
               Conout("NF-e - Gravou EZ0/EZ1 " - " - Filial: " + cFilAnt + "!")
            else
               lRet := .f.
            Endif
         Else
            lRet := .f.
         Endif
      Else
         lRet := .f.
      EndIf
   RestArea(aArea)
Return lRet



/***********************************************************************************************************************

   @@@@@@@@@   @@@@@@@@@    @@@@@@@@   @@@@@@@@@   @@@@@@@@@
       @       @           @               @       @
       @       @@@@@@@      @@@@@@         @       @@@@@@@      
       @       @                  @        @       @
       @       @@@@@@@@@   @@@@@@@         @       @@@@@@@@@

teste de busca de NFSe - Prefeitura de SP
***********************************************************************************************************************/

User Function ProcWNFSe()  //(oSelf, lSchedule)
   //Local aArea      := GetArea()
	Local lRet       := .T.
	Local lValida	  := .T.
	Local cMsg       := ""
	Local oWsdl      := Nil
	Local cMsgRet    := ""
	Local cError     := ""
	Local cWarning   := ""
	Local cUfAutor   := ""
	Local cTpAmb     := ""
	Local cCNPJEmp   := ""
	Local lContinua  := .T.
	Local cLocCert   := '\certs\'
	Local cCert		  := ''
	Local cCert_ca	  := ''
	Local cCert_cert := ''
	Local cCert_key  := ''
   Local cOriURL    := '3'   /// 1 - Prefeitura 2 - Arquivei 3 - NFSE Nacional (vai vir de parametro)
	Local cURL       := ''    // depois colocar no parametro  
   Local oSelf
   Local cRecurso   :=  ""
   Local aHeadOut   := {} 
   Local cApi_id    := ''
   Local cApi_key   := ''
   Local oJsObj
   Local i          := 0
   Local cNSUNFSE   := "" 
   Default lSchedule := .f.

   RpcClearEnv()
   RpcSetType(3)
   RpcSetEnv('99','01')


	Private oXmlDocZip
	Private cUnXML	:= ''
	Private cOrigem := ''
   Private lResumos := 0

   Private lXMLBaixa := 0 

   /*If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpant == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)
      Return .T.
   Endif 
   

   If !CTIsReady()        

      MsgAlert("Verifique se o TSS esta ativado")
      lValida := .F.
   
   Else */

      if cOriURL == '1'  // Prefeitura 
         cURL := "https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx?WSDL"
         //cCert		    := Alltrim(retIdEnti())
         If SuperGetMV("EZ_DEMO",.F.,.F.)
            cCert := "000566" // mediamonks
            //cCert := "004883" // GEDEON
         Endif 
         cCert_ca     := cLocCert+cCert+"_ca.pem"
         cCert_cert   := cLocCert+cCert+"_cert.pem"
         cCert_key    := cLocCert+cCert+"_key.pem"
         nSSLVersion  := 1
         lSSLInsecure := .T.
         If !File(cCert_ca)
            MsgAlert("Os arquivos do certificado digital devem constam na pasta: "+cLocCert)
            return
         Endif 
         // gedeon 12134906000269  inscricao 67795293
         // gedeon 12134906000188
         // MEDIAMONKS 06337094000175  inscricao 33240590
         cUFAutor  := RetCodUf()
         cTpAmb    := SuperGetMV("MV_X_BXAMB", .F., "1")
         cCNPJEmp  := '06337094000175'  //SM0->M0_CGC	//'18666055000109' -> vistra
         cIEEmp    := '33240590'  //SM0->M0_INSCM 
         cDtInicio := '2023-07-01' //dtoc(dDataBase)
         cdtFim    := '2023-07-31' //dtoc(dDataBase)
         cPagina   := "1"
         //Inst�ncia a classe, setando as par�metrizac�es necessarias
         oWsdl := TWsdlManager():New()
         oWsdl:cSSLCACertFile := cCert_ca
         oWsdl:cSSLCertFile   := cCert_cert
         oWsdl:cSSLKeyFile    := cCert_key
         oWsdl:cSSLKeyPwd      := "140404"
         oWsdl:nSSLVersion    := nSSLVersion
         oWsdl:lSSLInsecure   := lSSLInsecure
         oWsdl:nTimeout       := 300
         oWsdl:nSOAPVersion   := 0  // versao do SOAP 0 � 1 // 1 � 1.2
         oWsdl:lVerbose := .T.     // Ver os detalhes de comunica��o = fica no appserver
        // oWsdl:lUseNSPrefix:= .T. // ENVIAR O XML Completo
          //Tenta fazer o Parse da URL
         lRet := oWsdl:ParseURL(cURL)
         If !lRet 
            ConOut("[consWSNFSE] - Erro ParseURL: " + oWsdl:cError)
            MsgAlert("O Certificado Digital "+ cCert + " pode estar vencido ou nao se encontra na pasta, solicite atualizacao da pasta '\CERTS\'")
            lContinua := .F.
         EndIf
         If lContinua
            //Tenta definir a operacao
            lRet := oWsdl:SetOperation("ConsultaNFeRecebidas")
             //lRet := oWsdl:SetOperation("ConsultaCNPJ")
            
            If ! lRet 
               ConOut("[consWSNFSE] - Erro SetOperation: " + oWsdl:cError)
               lContinua := .F.
            EndIf         
         EndIf
     If lContinua
            If !lSchedule
            Endif
 
            cMsg := ""
            cMsg += '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:nfe="http://www.prefeitura.sp.gov.br/nfe">'
            cMsg += '<soap:Header/>'
            cMsg += '<soap:Body>'
            cMsg += '<nfe:ConsultaCNPJRequest>'
            cMsg += '<nfe:VersaoSchema>1</nfe:VersaoSchema>'
            cMsg += '<nfe:MensagemXML><![CDATA[<?xml version="1.0" encoding="UTF-8"?><p1:PedidoConsultaCNPJ xmlns:p1="http://www.prefeitura.sp.gov.br/nfe" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
            cMsg += '<Cabecalho Versao="1"><CPFCNPJRemetente><CNPJ>06337094000175</CNPJ></CPFCNPJRemetente></Cabecalho><CNPJContribuinte><CNPJ>03709859000162</CNPJ></CNPJContribuinte>'
            cMsg += '</p1:PedidoConsultaCNPJ>]]></nfe:MensagemXML></nfe:ConsultaCNPJRequest>'
            cMsg += '</soap:Body>'
            cMsg += '</soap:Envelope>'
    
            /// Assinando o XML para envio para a Prefeitura
            cMsg := EncodeUTF8(Alltrim(cMsg),"UTF-8")  //- tentativa de corrigir o erro 415
             memowrite('\xml\xmlvalidar.xml',cmsg)
            valida_schema('\xml\xmlvalidar.xml')  
            cMsg := u_EZ_XMLSIGN(cMsg)  ///
             cMsg := EncodeUTF8(Alltrim(cMsg),"UTF-8")
 //           cMsg := u_RSASignPath(cMsg)  //https://tdn.totvs.com/display/tec/PrivSignRSA

            //Envia uma mensagem SOAP personalizada ao servidor
           // oWsdl:lProcResp := .T.
            // Encode da MSG
            oWsdl:lSSLInsecure   := .T.
            lRet := oWsdl:SendSoapMsg(cMsg)
            If ! lRet 
               ConOut("[consWSNFSE] - Erro SendSoapMsg: " + oWsdl:cError)
               ConOut("[consWSNFSE] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
               lContinua := .F.
            EndIf
            //Pega a resposta do SOAP
            cMsgRet := oWsdl:GetSoapResponse()
                             
            //Transforma a resposta em um objeto
            oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
               
            //Se existir Warning, mostra no console.log
            If ! Empty(cWarning)
               ConOut("[consWSNFSE] - Alerta cWarning: " + cWarning)
               lContinua := .F.
            EndIf
               
            //Se houve erro, nao permitira prosseguir
            If ! Empty(cError)
               ConOut("[consWSNFSE] - Erro cError: " + cError)
               lContinua := .F.
            EndIf      
      Endif   

      Elseif cOriURL == '2'  // ARQUIVEI
         cUrl     := "https://sandbox-api.arquivei.com.br"
         cRecurso :=  "/v1/nfse/received"
         cApi_id  := '940aab20cdb6bb3c75cafc2d2693190f021628cc'  // fca8f5fe92d06fffea8575bb4e8a39bf11056c07 weider mediamonks 
         cApi_key := '9daffd935e69cc6f56b346414c08760eb60edc6c'  // de664d7eed7def4c2cf0e12adf42af8fa0f0bf7d weider mediamonks
         // Montagem do Header
         AAdd(aHeadOut,'Content-Type: application/json')
         AAdd(aHeadOut,"X-API-ID: "+Alltrim(cApi_id))    
         AAdd(aHeadOut,"X-API-KEY: "+Alltrim(cApi_key))
         // Montagem do Params
         cGetParam := ""
         cGetParam += '?limit=50'
         cGetParam += '?cursor=1'
         cGetParam += '?id[]=1'
         cGetParam += '?abrasf[]=true'
         cGetParam += '?filter=(= processed false)'
         cGetParam += '?created_at[from]=2023-07-12'
         cGetParam += '?created_at[to]=2023-07-15' 
         // Efetuando o GET na URL
         oRest := FwRest():New(cURL)
         oRest:SetPath(cRECURSO)
         If oRest:Get(aHeadOut,cGetParam)         
            ConOut("GET: " + oRest:GetResult())
            
            //Self:cXMLresp := oRest:GetLastError()  // oRest:GetResult() //"Metodo executado com sucesso"
            lContinua := .T.
         Else
            ConOut("GET: " + oRest:GetLastError())
            //Self:cXMLresp := oRest:GetResult() //"Metodo nao executado"
            lContinua := .F.
         EndIf
         If lContinua
            FWJsonDeserialize(oRest:CRESULT,@oJsObj)
            for i:= 1 to len(oJsObj:data)
                // Busco o XML no Json
                cMsgRet := Decode64(oJsObj:data[i]:xml)
                cMsgRet := EncodeUTF8(cMsgRet,"UTF-8") 
                //Transforma a resposta em um objeto
                oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
                //Se existir Warning, mostra no console.log
                If ! Empty(cWarning)
                   ConOut("[consWSNFSE] - Alerta cWarning: " + cWarning)
                   lContinua := .F.
                EndIf
                  
                //Se houve erro, nao permitira prosseguir
                If ! Empty(cError)
                   ConOut("[consWSNFSE] - Erro cError: " + cError)
                   lContinua := .F.
                EndIf 
                  if lContinua .and. cOriURL == "2"  // Arquivei
                     //Se a tag DocZip existir (for diferente de Undefinied)
                     PTNSPGrvXML(cMsgRet,oSelf,lSchedule)
                     lValida := .T. 
                  Endif 
            next     
         Endif
      Elseif cOriURL == '3'  // NFSE Nacional
         cNSUNFSE  := SuperGetMV("EZ_NSUNFSE",.F.,'0')            
         cUrl      := "https://adn.nfse.gov.br/contribuintes" 
         cGetParam := ''   
         nTimeOut  := 60
         aHeadOut  := {}
         cHeadRet  := ""
         cGetRet   := ""
         lprima    := .t.
         AAdd( aHeadOut, 'Accept: text/plain' )
         while .t.
               if !lprima 
                  cNSUNFSE := Alltrim(Str(cNSU))
               endif
               cRecurso :=  "/DFe/"+cNSUNFSE
               lprima   := .f.
               cGetRet  := HTTPSGet( cURL+cRecurso, "\certs\000566_cert.pem", "\certs\000566_key.pem", "140404", cGetParam, nTimeOut, aHeadOut, @cHeadRet )
               //https://tdn.totvs.com/display/tec/HTTPSGet e https://devforum.totvs.com.br/1373-consumir-api-https-do-banco-central
               if Empty( cGetRet )
                  conout( "Fail HTTPSGet" )
                  lContinua := .f.
               else
                  conout( "OK HTTPSGet" )
                  varinfo( "WebPage", cGetRet )
                  lContinua := .t.
               endif
               If lContinua
                  
                  FWJsonDeserialize(cGetRet,@oJsObj)
                  IF oJsObj:StatusProcessamento == "DOCUMENTOS_LOCALIZADOS"
                     IF len(oJsObj:LOTEDFE)>0
                        for i:= 1 to len(oJsObj:LOTEDFE)
                           // Lendo os dados do JSON
                           cNSU   := oJsObj:LOTEDFE[i]:NSU
                           cTPNF  := oJsObj:LOTEDFE[i]:TIPODOCUMENTO
                           cCHVNFE:= oJsObj:LOTEDFE[i]:CHAVEACESSO
                           cDATAHR:= oJsObj:LOTEDFE[i]:DATAHORAGERACAO
                           nTamanho:= Len(oJsObj:LOTEDFE[i]:ARQUIVOXML)
                           cXML   := Decode64(oJsObj:LOTEDFE[i]:ARQUIVOXML)
                           cUnXML := ""
                           lRet := GzStrDecomp(cXML, nTamanho, @cUnXML)
                           //Transforma a resposta em um objeto
                           oXmlDocZip := XmlParser(cUnXML, "_", @cError, @cWarning)
                           //Se existir Warning, mostra no console.log
                           If ! Empty(cWarning)
                              ConOut("[consWSNFSE] - Alerta cWarning: " + cWarning)
                              lContinua := .F.
                           EndIf  
                           //Se houve erro, nao permitira prosseguir
                           If ! Empty(cError)
                              ConOut("[consWSNFSE] - Erro cError: " + cError)
                              lContinua := .F.
                           EndIf 
                           if lContinua .and. cOriURL == "3"  // Arquivei
                                 //Se a tag DocZip existir (for diferente de Undefinied)
                                 PTNSPGrvXML(cUnXML,oSelf,lSchedule,cCHVNFE,cNSU)
                                 lValida := .T. 
                           Endif 
                        next  
                     Endif 
                  Else
                     ConOut("[consWSNFSE] - N�o h� mais Documentos")
                     exit
                  Endif  
               Endif
         enddo
         varinfo( "Header", cHeadRet )
      Endif
return lValida


Static Function Valida_schema(cArq)
      LOCAL cXML      := ""
     LOCAL cXSD      := ""
     LOCAL cError        := ""
     LOCAL cWarning      := ""
     LOCAL cAviso     := ""
     LOCAL nlA          := 0
     LOCAL alCamXds     := {}

     cXML := cArq

     AADD(alCamXds,'xml\schemas\PedidoConsultaCNPJ_v01.xsd')
     AADD(alCamXds,'xml\schemas\xmldsig-core-schema_v1.01.xsd')
     AADD(alCamXds,'xml\schemas\TiposNFe_v01.xsd')
    
     FOR nlA := 1 TO LEN(alCamXds)
          IF XMLFVLDSCH( cXML , alCamXds[nlA] ,@cError,@cAviso)
              ALERT("XML Valido")
             ELSE
              ALERT("XML Invalido. Erro: "+ cError+" Warning "+ cWarning)
          ENDIF      
     NEXT nlA

RETURN NIL

//--------------------------------------------------
// ASSINA UM ARQUIVO XML DIGITALMENTE
//--------------------------------------------------
User Function EZ_XMLSIGN(cXML)
    Local cDigest    As Character // VALOR DE RESUMO DO ARQUIVO
    Local cSignInfo  As Character // CORPO DE INFORMA��ES DE ASSINATURA
    Local cPassword  As Character // SENHA PARA LEITURA DO CERTIFICADO
    Local cSignature As Character // CORPO DA ASSINATURA E CERTIFICADO
    Local aCertific  As Array     // VETOR DE CERTIFICADOS

    // INICIALIZA��O DE VARI�VEIS
   cPassword  := "140404"  // Colocar a senha do Certificado Digital
   // estou recebendo o XML via parametro
   //cXML       := GetXMLFile("dirdoc", "SEU_XML_AQUI.xml")
   cDigest    := GetDigest(cXML)
   cDigest    := "2073711b9c0c083a8929891df43c80c5"
   aCertific  := GetCertificate("\certificate", "000566", cPassword)
   cSignInfo  := GetSignInfo(Space(0), cDigest)
   cSignature := GetSignature(aCertific, cSignInfo, cPassword)

    // MONTA O XML COMPLETO
   cXML := BuildXML(cXML, cSignature)

    // SALVA O .XML COMPLETO NO CTRL+C
    //CopyToClipboard(cXML)

Return(cXML)

//--------------------------------------------------
// RETORNA O XML A SER ASSINADO
//--------------------------------------------------
Static Function GetXMLFile(cPath As Character, cFile As Character)
    Local oFile As Object    // OBJETO DE ACESSO AO ARQUIVO .XML
    Local cXML  As Character // CONTE�DO DO ARQUIVO .XML

    // INICIALIZA��O DE VARI�VEIS
    cXML  := Space(0)
    oFile := FwFileReader():New(cPath + "/" + cFile) // CAMINHO ABAIXO DO ROOTPATH

    // SE FOR POSS�VEL ABRIR O ARQUIVO, LEIA-O
    // SE N�O, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cXML := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO
    Else
        Final("Couldn't find/open file: " + cPath + "/" + cFile)
    EndIf

    // NORMALIZA O XML DA ASSINATURA
    cXML := XMLSerialize(cXML)
Return (cXML)

//--------------------------------------------------
// CALCULA O VALOR DO DIGEST
//--------------------------------------------------
Static Function GetDigest(cXML As Character)
    Local cDigest As Character // VALOR DE RESUMO DO ARQUIVO

    // INICIALIZA��O DE VARI�VEIS
    cDigest := Space(0)

    // CANONIZA O XML E CALCULA O DIGEST
    cXML    := XMLSerialize(cXML)
    cDigest := Encode64(EVPDigest(cXML, 3)) //https://tdn.totvs.com/display/tec/EVPDigest
Return (cDigest)

//--------------------------------------------------
// RETORNA O CAMINHO PARA OS ARQUIVOS (*CA.PEM,
// *KEY.PEM E *CERT.PEM)
//--------------------------------------------------
Static Function GetCertificate(cCertPath As Character, cFileName As Character, cPassword As Character)
    Local aCertific As Array     // VETOR DE CERTIFICADOS
    Local cFullPath As Character // CAMINHO RELATIVO COMPLETO
    Local cError    As Character // ERROS DE GERA��O DE CERTIFICADO
    Local lFind     As Logical   // VALIDADOR DE EXTRA��O DE CERTIFICADO

    // INICIALIZA��O DE VARI�VEIS
    lFind     := .F.
    aCertific := {}
    cCertPath := cCertPath + "\"
    cFullPath := Space(0)
    cError    := Space(0)

    // PROPRIEDADES PARA ARQUIVO *.CA
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_ca.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO J� EXISTE,
    // CASO N�O EFETUA A CRIA��O
    If (!lFind)
         //https://tdn.totvs.com/display/tec/PFXCA2PEM
        If (PFXCA2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
            ConOut(Repl("-", 80))
            ConOut(MemoRead(cFullPath))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("ERROR: Couldn't extract *_CA certificate", 80))
            ConOut(Repl("-", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCertific, {"CA", cFullPath, lFind})

    // PROPRIEDADES PARA ARQUIVO *.KEY
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_key.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO J� EXISTE,
    // CASO N�O EFETUA A CRIA��O
    If (!lFind)
         //https://tdn.totvs.com/display/tec/PFXKey2PEM
        If (PFXKey2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
            ConOut(Repl("-", 80))
            ConOut(MemoRead(cFullPath))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("ERROR: Couldn't extract *_KEY certificate", 80))
            ConOut(Repl("-", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCertific, {"KEY", cFullPath, lFind})

    // PROPRIEDADES PARA ARQUIVO *.CERT
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_cert.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO *.CERT J� EXISTE,
    // CASO N�O EFETUA A CRIA��O
    If (!lFind)
         //https://tdn.totvs.com/display/tec/PFXCert2PEM
        If (PFXCert2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
            ConOut(Repl("-", 80))
            ConOut(MemoRead(cFullPath))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("ERROR: Couldn't extract *_CERT certificate", 80))
            ConOut(Repl("-", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCertific, {"CERT", cFullPath, lFind})

    // VERIFICA SE OS CERTIFICADOS B�SICOS FORAM EXTRA�DOS
    If (!aCertific[2][3] .And. !aCertific[3][3])
    //    Final("ERROR: Couldn't extract any certificate")
    EndIf
Return (aCertific)

//--------------------------------------------------
// CALCULA O SIGNEDINFO DA ASSINATURA
//--------------------------------------------------
Static Function GetSignInfo(cURI As Character, cDigest As Character)
    Local cSignInfo As Character // CORPO DO SIGNEDINFO

    // INICIALIZA��O DE VARI�VEIS
    cSignInfo := Space(0)

    // MONTAGEM DO SIGNEDINFO
    cSignInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
    cSignInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    cSignInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
    cSignInfo += '<Reference URI="' + cURI + '">'
    cSignInfo += '<Transforms>'
    cSignInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
    cSignInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    cSignInfo += '</Transforms>'
    cSignInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
    cSignInfo += '<DigestValue>' + cDigest + '</DigestValue>
    cSignInfo += '</Reference>'
    cSignInfo += '</SignedInfo>'

    // NORMALIZA O XML DA ASSINATURA
    cSignInfo := XMLSerialize(cSignInfo)
Return(cSignInfo)

//--------------------------------------------------
// GERA O CORPO DA ASSINATURA
//--------------------------------------------------
Static Function GetSignature(aCertific As Array, cSignInfo As Character, cPassword As Character)
    Local oFile      As Object    // OBJETO DE ACESSO AO CERTIFICADO
    Local cFile      As Character // CONTE�DO DO CERTIFICADO
    Local cError     As Character // ERROS DURANTE A CONVERS�O
    Local cXMLSign   As Character // CORPO .XML DA ASSINATURA
    Local cSignature As Character // ASSINATURA

    // INICIALIZA��O DE VARI�VEIS
    cFile      := Space(0)
    cError     := Space(0)
    cXMLSign   := Space(0)
    //https://tdn.totvs.com/display/tec/EVPPrivSign
    //3 = sha1   // https://tdn.totvs.com/display/tec/SHA1 e https://siga0984.wordpress.com/tag/md5/
    cSignature := Encode64(EVPPrivSign(aCertific[AScan(aCertific, {|aCert|aCert[1] == "KEY"})][2], cSignInfo, 3, cPassword, @cError))
    oFile      := FwFileReader():New(aCertific[AScan(aCertific, {|aCert|aCert[1] == "CERT"})][2])

    // SE FOR POSS�VEL ABRIR O ARQUIVO, LEIA-O
    // SE N�O, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO
    Else
        Final("Couldn't find/open file: " + cCertPath)
    EndIf

    // REMOVE A LINHA "BEGIN CERTIFICATE" E "END CERTIFICATE"
    cFile := SubStr(cFile, At("BEGIN CERTIFICATE", cFile) + 22)
    cFile := SubStr(cFile, 1, At("END CERTIFICATE", cFile) - 6)

    // GERA A ESTRUTURA DE ASSINATURA DO .XML
    cXMLSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
    cXMLSign += cSignInfo
    cXMLSign += '<SignatureValue>' + cSignature + '</SignatureValue>'
    cXMLSign += '<KeyInfo>'
    cXMLSign += '<X509Data>'
    cXMLSign += '<X509Certificate>' + cFile + '</X509Certificate>'
    cXMLSign += '</X509Data>'
    cXMLSign += '</KeyInfo>'
    cXMLSign += '</Signature>'

    // NORMALIZA O XML DA ASSINATURA
    cXMLSign := XMLSerialize(cXMLSign)
Return (cXMLSign)

//--------------------------------------------------
// SERIALIZA O XML NORMALIZANDO-O
//--------------------------------------------------
Static Function XMLSerialize(cXML)
    Local cError   As Character // ERROS DURANTE A CONVERS�O
    Local cWarning As Character // AVISOS DURANTE A CONVERS�O

    // INICIALIZA��O DE VARI�VEIS
    cError   := Space(0)
    cWarning := Space(0)

    // REMOVE SALTOS DE LINHA
    cXML := StrTran(cXML, Chr(10), Space(0))
    cXML := StrTran(cXML, Chr(13), Space(0))

    // REMOVE ESPA�OS EM BRANCO
    While (At("> ", cXML) > 0)
        cXML := StrTran(cXML, "> ", ">")
    End

    While (At(" <", cXML) > 0)
        cXML := StrTran(cXML, " <", "<")
    End

    While (At(" </", cXML) > 0)
        cXML := StrTran(cXML, " </", "</")
    End

    // CANONIZA O XML
    cXML := XMLC14N(cXML, Space(0), @cError, @cWarning)
Return (cXML)

//--------------------------------------------------
// MONTA O ARQUIVO .XML
//--------------------------------------------------
Static Function BuildXML(cXML As Character, cSignature As Character)
    Local cTag     As Character // TAG DO CORPO
    Local cNode    As Character // TAG A SER REMOVIDA
    Local cFullXML As Character // XML COMPLETO

 
    // INICIALIZA��O DE VARI�VEIS
    // cTag     := "</p1:PedidoConsultaNFePeriodo>]]></nfe:MensagemXML></nfe:ConsultaNFeRecebidasRequest></soapenv:Body></soapenv:Envelope>"
   //cTag     := "</nfe:ConsultaNFeRecebidasRequest></soapenv:Body></soapenv:Envelope>"
     cTag     := "</p1:PedidoConsultaCNPJ>]]></nfe:MensagemXML></nfe:ConsultaCNPJRequest></soap:Body></soap:Envelope>"
   // cTAG     := "</p1:PedidoConsultaCNPJ></nfe:MensagemXML></nfe:ConsultaCNPJRequest></soap:Body></soap:Envelope>"
    cNode    := Space(0)
    cNodeOne := Space(0)
    cNodeFim := Space(0)
    cFullXML := Space(0)

    // Retira o Final para Colocar a Assinatura do cTag pra Frente
    cNodeOne := Substr(cXml,1, At(cTag , cXML)-1) // Vai at� a tag </cabecalho>
    // Aqui coloco o Node Final
    cNodeFim := Substr(cXml, At(cTag , cXML), len(cXml))

    // NORMALIZA O XML DA ASSINATURA
    cFullXML := XMLSerialize(cNodeOne + cSignature + cNodeFim)
Return (cFullXML)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PTNSPGrvXML
Processa os XML dos NFSe Prefeitura
@type Function
@author    Carla Barbosa
@version   1.xx
@since     06/09/2023
/*/
//------------------------------------------------------------------------------------------  

Static Function PTNSPGrvXML(cConteudo,oSelf, lSchedule,cCHVNFE,cNSU)

   Local aArea       := getArea()
   Local lRet        := .T. 
   Local cUnXML      := cConteudo
   Local cXMLDIR     := Alltrim(SuperGetMV("EZ_LOCXML",.F.,"\xmlnfe\"))
   Local i
   Private lUsaPort  := SuperGetMV("EZ_USAPORT",.F.,.F.)

   Default nOpcao := 1
   Default cCHVNFE:= ""

   If !Empty(cXMLDIR)
      If !ExistDir(cXMLDIR)
         MakeDir(cXMLDIR)
      Endif
      If Left(cXMLDIR,1)<>"\"
         cXMLDIR := "\"+cXMLDIR
      Endif
      If Right(cXMLDIR,1)<>"\"
         cXMLDIR := cXMLDIR+"\"
      Endif 
   Endif 

   Default lSchedule 	:= FWGetRunSchedule()
   
   If lRet
      
      // Gravando NSU 
      EZGravDNsu(StrZero((cNSU),15),"1",cCHVNFE) /// gravando o NSU
      if AT("<infEvento",cUnXML)> 0 .or. AT("<e101101>",cUnXML)> 0 .or. ;
         AT("<e105102>",cUnXML)> 0  .or. AT("<e105104>",cUnXML)> 0  // Aqui � Cancelamento
         // � um evento de cancelamento
         If !Empty(cXMLDIR)
            Conout("NFS-e - Salvo na pasta " + cXMLDIR)
            lRet := MemoWrite(cXMLDIR+"nfse-cancel"+EZ0->EZ0_CHVNFE+".xml",EZ0->EZ0_XMLNFE)
            
            if Empty(alltrim(cCHVNFE))
               cCHVNFE    := XMLTagCont('CodigoVerificacao', cUnXML)
            Endif
            EZConout("EZ4 GRC","Baixando XML NF Cancelada - Chave: " + cCHVNFE + "!")
            cCHNFSE       := cCHVNFE
            cCHVNFE       := Substr(cCHVNFE,7,44)
            cLocInc       := Substr(cCHVNFE,1,06)
            dbSelectArea("EZ0")
            EZ0->(dbSetOrder(1))
            If EZ0->(dbSeek(xFilial("EZ0")+cCHVNFE))
               if EZ0->EZ0_ACAO == '0'  // So faz o cancelamento de NF Entrada
                  if EZCancNfe(cCHVNFE,cUnXML)
                     EZConout("EZ4 GRC","o XML NF Cancelada - Chave: " + cCHVNFE + "! NF Cancelada com Sucesso")
                  else
                     EZConout("EZ4 GRC","o XML NF Cancelada - Chave: " + cCHVNFE + "! NF Nao Cancelada no Sistema")
                  endif
               Endif
            else
               EZConout("EZ4 GRC","o XML NF Cancelada - Chave: " + cCHVNFE + "! Nao encontrada na EZ0")
            Endif    
         Endif 
      ElseIf AT("<infNFSe",cUnXML) > 0     // Verifica se � NFSE 
         if Empty(alltrim(cCHVNFE))
            cCHVNFE    := XMLTagCont('CodigoVerificacao', cUnXML)
         Endif
         cCHNFSE       := cCHVNFE
         cCHVNFE       := Substr(cCHVNFE,7,44)
         cLocInc       := Substr(cCHVNFE,1,06)
         // volumetria
         U_EZVolUpdate('NFn') 
         dbSelectArea("EZ0")
         EZ0->(dbSetOrder(1))
         If !EZ0->(dbSeek(xFilial("EZ0")+cCHVNFE))
            RecLock("EZ0",.T.)  // n�o tinha o resumo
         else
            RecLock("EZ0",.F.)  // j� tinha o resumo - carla
         Endif   
         EZ0->EZ0_FILIAL := xFilial("EZ0")
         EZ0->EZ0_CHVNFE := cCHVNFE
         if EZ0->(FieldPos("EZ0_CHNFSE"))>0
            EZ0->EZ0_CHNFSE := cCHNFSE
         Endif
         EZ0->EZ0_XMLNFE := cUnXML
         EZ0->EZ0_TIPONF := "NFn"
         EZ0->EZ0_ULTNSU := StrZero((cNSU),15) 
         EZ0->EZ0_DTEMI  := xConteudo("InfNfse", "dhProc"    , "xCont := StoD(StrTran(SubStr( xCont,1,10),'-',''))", cUnXML, "D")  // insere o dado na tabela
         EZ0->EZ0_VLDOC  := xConteudo("InfNfse", "vServ"  , "xCont := val( xCont )"                             , cUnXML, "N")  // insere o dado na tabela 
         EZ0->EZ0_DPSID  := SubStr(cUnXML,AT("<infDPS Id=",cUnXML)+Len("<infDPS Id=")+1,45) // insere o dado na tabela 
         //EZ0->EZ0_IEEMIT := xConteudo("InfNfse", "IE"   , "xCont := Alltrim(xCont)"                           , cUnXML, "C")  // insere o dado na tabela 
         If EZ0->(FieldPos("EZ0_DTBXML")) > 0 
            EZ0->EZ0_DTBXML := ddatabase
         Endif 
         EZ0->(EZ0_STIN()) 
         MsUnlock()
         If !Empty(cXMLDIR)
            Conout("NF-e - Salvo na pasta " + cXMLDIR)
            lRet := MemoWrite(cXMLDIR+"nsp-"+EZ0->EZ0_CHVNFE+".xml",EZ0->EZ0_XMLNFE)
         Endif 
         If  EZ0->EZ0_STINTE > '0'
            aChaves:={{EZ0->EZ0_CHVNFE,EZ0->(RECNO())}}
            for i:=1 to Len(aChaves)
               EZ0->(dbGoTo(aChaves[i,2]))                        // posiciona na EZ0
               ExtraiDadosXML(aChaves[i],'NFn')
               VldDadosNF(aChaves[i])
               RecLock("EZ0",.F.)
               EZ0->(EZ0_STIN()) // 03/01/2022 - MARCIOP - Atualiza o status apos a inclusao
               MsUnlock()
            next
         Endif
         EZGravDNsu(StrZero((cNSU),15),"3",cCHVNFE) /// gravando o NSU
         Conout("NF-e - Gravou EZ0/EZ1 " - " - Filial: " + cFilAnt + "!")
      Endif
   EndIf
  
   RestArea(aArea)
    
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcManifNFE
Realiza a conexao no WebService para busca das NFS-e

@author    MARCIO MARTINS PEREIRA
@version   1.xx
@Iniciado em 03/12/2022

User Function testemanif()
   
   RpcClearEnv()
   RpcSetType(3)
   RpcSetEnv('99','01')
   U_ProcManifNFE("41221105330384000124550010025279551530416271","210210") 

Return 

*/
User Function ProcManifNFE(cChave, cEvento)

   Local aArea     := GetArea()   
   Local cURL 	    := "https://www1.nfe.fazenda.gov.br/nfeRecepcaoEvento4/nfeRecepcaoEvento4.asmx?WSDL" 
   Local cMsg      := ""
   Local oWsdl     := Nil
   Local cMsgRet   := ""
   //Local cError    := ""
   //Local cWarning  := ""
   //Local cXmlGZip  := ""                       
   //Local cUfAutor  := ""
   Local cCert	    := If((SuperGetMV("EZ_DEMO",.F.,.F.)),'',RetIdEnti())
   Local lRet      := .T.   
   Local lContinua := .T.
   //Local cParNSU   := "000000000000000" 
   //Local lWait     := .F.
   Local cData     := ""

   Default cChave  := "41221105330384000124550010025279551530416271"
   Default cEvento := "210210"

   cData := DTOS(Date())
   cData := SubStr(cData,1,4)+"-"+SubStr(cData,5,2)+"-"+SubStr(cData,7,2)+"T"+Time()+"-03:00"
   
   Private cCNPJ	:= SM0->M0_CGC	// aqui eu tenho que localizar o certificado correspondente ao CNPJ

   If SuperGetMV("EZ_DEMO",.F.,.F.) //cEmpAnt == "99" .or. SuperGetMV("EZ_DEMO",.F.,.F.)// apenas para testes dos analistas
      cCNPJ	:= "18666055000109"
      cCert := "000002"
   Endif 

   //Instancia a classe
   oWsdl := TWsdlManager():New()	
      
   If !File("\certs\"+cCert+"_all.pem")
      If lSchedule
         Conout("Nao foram encontrados os certificados dentro da pasta \certs\"+CRLF+"Copie os arquivos para la e Re-execute!")
      Else
         MsgAlert("Nao foram encontrados os certificados dentro da pasta \certs\"+CRLF+"Copie os arquivos para la e Re-execute!")
      Endif 
      Return 
   Endif 

   // Carrego os certificados
   oWsdl:cSSLCACertFile := "\certs\"+cCert+"_all.pem"
   oWsdl:cSSLCertFile   := "\certs\"+cCert+"_cert.pem"
   oWsdl:cSSLKeyFile    := "\certs\"+cCert+"_key.pem"
   oWsdl:lSSLInsecure   :=  .T.
   oWsdl:nSSLVersion 	 :=  0 // mudei aqui   
   oWsdl:nTimeout       := 120
    
   //Tenta fazer o Parse da URL
   lRet := oWsdl:ParseURL(cURL)
   If ! lRet 
      If lSchedule
         Conout("Erro ParseURL: " + oWsdl:cError)
      Else
         //CARLA BARBOSA
         //Mensagem incluida 01/08/2022
         MsgAlert("Erro no Parse da URL! Verifique a Validade do Certificado na Pasta Certs"+CRLF+"Erro ParseURL: " + oWsdl:cError)
      Endif 
      lContinua := .F.
   EndIf

   //Define a operacao
   If lContinua           
      aOps := oWsdl:ListOperations()
      lRet := oWsdl:SetOperation("nfeRecepcaoEventoNF")
      If ! lRet 
         Conout("Erro SetOperation: " + oWsdl:cError)
         lContinua := .F.
      EndIf
   EndIf
   
   If lContinua

      //Monta a mensagem que sera enviada		
      // -- VOU MANDAR VIA DISTNSU
      cMsg := '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+ CRLF
      cMsg += '    <nfeDadosMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4">'+ CRLF
      cMsg += '        <envEvento versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'+ CRLF
      cMsg += '        <idLote>000000000000001</idLote>'+ CRLF
      cMsg += '        <evento versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'+ CRLF
      cMsg += '          <infEvento Id="ID'+cEvento+cChave+'01">'+ CRLF
      cMsg += '            <cOrgao>91</cOrgao>'+ CRLF
      cMsg += '            <tpAmb>1</tpAmb>'+ CRLF
      cMsg += '            <CNPJ>'+cCNPJ+'</CNPJ>'+ CRLF
      cMsg += '            <chNFe>'+cChave+'</chNFe>'+ CRLF
      cMsg += '            <dhEvento>'+cData+'</dhEvento>'+ CRLF
      cMsg += '            <tpEvento>'+cEvento+'</tpEvento>'+ CRLF
      cMsg += '            <nSeqEvento>1</nSeqEvento>'+ CRLF
      cMsg += '            <verEvento>1.00</verEvento>'+ CRLF
      cMsg += '            <detEvento versao="1.00">'+ CRLF
      cMsg += '              <descEvento>Ciencia da Operacao</descEvento>'+ CRLF
      cMsg += '            </detEvento>'+ CRLF
      cMsg += '          </infEvento>'+ CRLF
      cMsg += '        </evento>'+ CRLF
      cMsg += '      </envEvento>'+ CRLF
      cMsg += '    </nfeDadosMsg>'+ CRLF
      cMsg += '  </soap:Body>'+ CRLF
      cMsg += '</soap:Envelope>'+ CRLF    

      // NUNCA MUDAR ESSA CHAVE LOGICA
      oWsdl:lSSLInsecure   := .T.
      
      lRet := oWsdl:SendSoapMsg(cMsg)
      If ! lRet 
            Conout("Erro SendSoapMsg: " + oWsdl:cError)
            Conout("Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
            lContinua := .F.
      EndIf

      If lContinua

            cMsgRet := oWsdl:GetSoapResponse()
            //oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)

      EndIf
   
   EndIf

   RestArea(aArea)
   
Return

Static Function EZConout(cIDEZ4, cTexto)
FWLogMsg("INFO",,cIDEZ4,,,,cTexto,,,) 
Return 


User Function RSASignPath(cMsg)
  Local sPrivKeyPath := "\certs\000566.pem"
  Local sStr := cMsg
  Local cMD5 := ''
  Local sSign := ""
  // Conteudo a ser assinado
  varinfo( "sStr", sStr )
  // Hash MD5 gerado a partir desse conteudo
  cSHA1 := SHA1( sStr )
  varinfo( "cSHA1", cSHA1 )
  // Assinatura gerada a partir do Hash MD5 usando a chave privada
  sSign := PrivSignRSA( sPrivKeyPath, cSHA1, 2, "140404" )
  varinfo( "sSign", sSign )
Return
 

