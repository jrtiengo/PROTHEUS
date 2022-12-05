#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "topconn.ch"

#DEFINE IMP_SPOOL 2

// ----------------------------------------------------------------------------------------------------------*
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                     *
// Fonte.....: AUTOM266                                                                                      *
// Autor.....: Harald Hans Löschenkohl                                                                       *
// Data......: 01/12/2014                                                                                    *
// Descrição.: Impressão do Recibo de Contrato de Locação                                                    *
// parâmetros: Filial , Contrato, Competência                                                                *
// ----------------------------------------------------------------------------------------------------------*

User Function AUTOM266(kFilial, kContrato, kCompetencia)
                    
   Local cSql          := ""
   Local cExtenso      := ""
   Local cTexto        := ""
   Local nContar       := 0
   Local aContrato     := {}
   Local cComplExtendo := ""
   Local cPathDot      := ""   && "C:\AUTOMATECH\HARALD\LOCACAO2.DOT"

   Private oWord := OLE_CreateLink()
   
   U_AUTOM628("AUTOM266")
   
   // Pesquisa o arquivo a ser utilizado para impressão do contrato de locação
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_RECI FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      MsgAlert("Atenção! Entre em contato com o Administrador do Sistema informando que existe problema nos parâmetros do Sistema para impressão do recibo de locação.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(T_PARAMETROS->ZZ4_RECI))
      MsgAlert("Atenção! Entre em contato com o Administrador do Sistema informando que existe problema nos parâmetros do Sistema para impressão do recibo de locação.")
      Return(.T.)
   Endif
  
   cPathDot := Alltrim(UPPER(T_PARAMETROS->ZZ4_RECI))

   OLE_NewFile(oWord, cPathDot ) 

   // Pesquisa a oprunidade para impressão dos dados do Locatário
   If Select("T_COMPETENCIA") > 0
      T_COMPETENCIA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CNF.CNF_FILIAL,"
   cSql += "       CNF.CNF_NUMERO,"
   cSql += "       CNF.CNF_CONTRA,"
   cSql += "       CNF.CNF_PARCEL,"
   cSql += "       CNF.CNF_COMPET,"
   cSql += "       CNF.CNF_VLPREV,"
   cSql += "       CNF.CNF_DTVENC,"
   cSql += "       CN9.CN9_CLIENT,"
   cSql += "       CN9.CN9_LOJACL,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_CGC     "
   cSql += "  FROM " + RetSqlName("CNF") + " CNF, "
   cSql += "       " + RetSqlName("CN9") + " CN9, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE CNF_FILIAL = '" + Alltrim(kFilial)      + "'"
   cSql += "   AND CNF_CONTRA = '" + Alltrim(kContrato)    + "'"
   cSql += "   AND CNF_COMPET = '" + Alltrim(kCompetencia) + "'"
   cSql += "   AND CNF.D_E_L_E_T_ = ''"
   cSql += "   AND CN9.CN9_FILIAL = CNF.CNF_FILIAL"
   cSql += "   AND CN9.CN9_NUMERO = CNF.CNF_CONTRA"
   cSql += "   AND CN9.D_E_L_E_T_ = ''            "
   cSql += "   AND SA1.A1_COD     = CN9.CN9_CLIENT"
   cSql += "   AND SA1.A1_LOJA    = CN9.CN9_LOJACL"
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPETENCIA", .T., .T. )

   If T_COMPETENCIA->( EOF() )
      MsgAlert("Não existem dados a serem impressos para este Contrato.")
      Return(.T.)
   Endif

   // Carrega as variáveis para emissão do recibo de locação
   OLE_SetDocumentVar(oWord,"Endereco_Empresa", "Rua Dr. João Inácio, 1110 - Bairro Navegantes" )    
   OLE_SetDocumentVar(oWord,"Cidade_Empresa"  , "90.230-181 = Porto Alegre - RS" )       
   OLE_SetDocumentVar(oWord,"CNPJ_Empresa"    , "03.385.913/0001-61" )          

   // Carrega o Combo de Filiais
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   Do Case
      Case Substr(kCompetencia,01,02) == "01"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Janeiro de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "02"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Fevereiro de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "03"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Março de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "04"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Abril de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "05"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Maio de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "06"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Junho de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "07"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Junho de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "08"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Agosto de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "09"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Setembro de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "10"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Outubro de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "11"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Novembro de " + Strzero(Year(Date()),4))
      Case Substr(kCompetencia,01,02) == "12"
           OLE_SetDocumentVar(oWord,"Data_Recibo", Alltrim(SM0->M0_CIDENT) + ", " + Strzero(Day(Date()),2) + " de Dezembro de " + Strzero(Year(Date()),4))
   EndCase

   // Cria o texto do recibo
   cTexto := ""
   cTexto := "Recebemos de " + Alltrim(T_COMPETENCIA->A1_NOME) + ", inscrita no CNPJ nº "          + ;
             Substr(T_COMPETENCIA->A1_CGC,01,02) + "." + Substr(T_COMPETENCIA->A1_CGC,03,03) + "." + ;
             Substr(T_COMPETENCIA->A1_CGC,06,03) + "/" + Substr(T_COMPETENCIA->A1_CGC,09,04) + "-" + ;
             Substr(T_COMPETENCIA->A1_CGC,13,02) + ", a importância de R$ "  + Transform(T_COMPETENCIA->CNF_VLPREV, "@E 999,999,999.99")  + ;
             " (" + Alltrim(Extenso(T_COMPETENCIA->CNF_VLPREV)) + ") referente ao pagamento da parcela " + Alltrim(T_COMPETENCIA->CNF_PARCEL) + ;
             " do contrato de locação nº " + Alltrim(T_COMPETENCIA->CNF_CONTRA) + " com vencimento em " + ;
             Substr(T_COMPETENCIA->CNF_DTVENC,07,02) + "/" + ;
             Substr(T_COMPETENCIA->CNF_DTVENC,05,02) + "/" + ;
             Substr(T_COMPETENCIA->CNF_DTVENC,01,04) + "."

   OLE_SetDocumentVar(oWord,"Texto_Recibo", cTexto)

   OLE_UpdateFields(oWord) 

   If MsgYesNo("Deseja imprimir o Recibo de Locação?")
      Ole_PrintFile(oWord,"ALL",,,1)
   EndIf
  
   SLEEP(15000)
   
   // Fecha o link com o Word
   OLE_CloseFile( oWord )
   OLE_CloseLink( oWord )

Return(.T.)


/*
   For nContar = 1 to U_P_OCCURS(T_LOCATARIO->PARAMETROS, "|", 1)
       aAdd( aContrato, U_P_CORTA(T_LOCATARIO->PARAMETROS, "|", nContar) )
   Next nContar    

   // Conteúdo do array aContrato
   // 01 - Nº da Oportunidade
   // 02 - Nº da Proposta Comercial
   // 03 - Código do Cliente
   // 04 - Loja do Cliente
   // 05 - Nome do Cliente
   // 06 - Data Inicial do Contrato
   // 07 - Data Final do Contrato
   // 08 - Periodicidade do Contrato
   // 09 - Vigência do Contrato
   // 10 - Moeda do Contrato
   // 11 - Código Condição de Pagamento
   // 12 - Descrição da Condição de Pagamento
   // 13 - Vendedor 1
   // 14 - Nome do Vendedor 1
   // 15 - % Comissão do Vendedor 1
   // 16 - Vendedor 2
   // 17 - Nome do Vendedor 2
   // 18 - % Comissão do Vendedor 2
   // 19 - Valor total da locação
   // 20 - Tipo de Atendimento

   // Título do Contrato
   If Select("T_PROFORMA") > 0
      T_PROFORMA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AD1_FILIAL, "
   cSql += "       AD1_NROPOR, "
   cSql += "       AD1_ZCONTR  "
   cSql += "  FROM " + RetSqlName("AD1")
   cSql += " WHERE AD1_FILIAL = '" + Alltrim(_____Filial)       + "'"
   cSql += "   AND AD1_NROPOR = '" + Alltrim(_____Oportunidade) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROFORMA", .T., .T. )

   If T_PROFORMA->( EOF() )
      OLE_SetDocumentVar(oWord,"Titulo_Contrato", "PRÓ-FORMA DE CONTRATO DE LOCAÇÃO" ) 
   Else
      If Empty(Alltrim(T_PROFORMA->AD1_ZCONTR))
         OLE_SetDocumentVar(oWord,"Titulo_Contrato", "PRÓ-FORMA DE CONTRATO DE LOCAÇÃO" ) 
         cComplExtendo := "*** O valor expresso em reais poderá sofrer alteração no momento da efetivação do contrato de acordo com a variação da cotação do dólar."
      Else
         OLE_SetDocumentVar(oWord,"Titulo_Contrato", "CONTRATO DE LOCAÇÃO Nº " + Alltrim(T_PROFORMA->AD1_ZCONTR) )
         cComplExtendo := ""
      Endif
   Endif      

   // OLE_SetDocumentVar(objeto link,nome da docvariable no word,conteúdo a ser passado para o word)
   OLE_SetDocumentVar(oWord,"Nome_Locatario"    , Alltrim(T_LOCATARIO->A1_NOME) ) 
   OLE_SetDocumentVar(oWord,"Endereco_Locatario", Alltrim(T_LOCATARIO->A1_END) ) 
   OLE_SetDocumentVar(oWord,"Cidade_Locatario"  , Alltrim(T_LOCATARIO->A1_MUN) ) 
   OLE_SetDocumentVar(oWord,"Estado_Locatario"  , Alltrim(T_LOCATARIO->A1_EST) ) 
   OLE_SetDocumentVar(oWord,"CEP_Locatario"     , Alltrim(T_LOCATARIO->CEP) ) 
   OLE_SetDocumentVar(oWord,"CNPJ_Locatario"    , Alltrim(T_LOCATARIO->CNPJ) ) 

   Do Case 
      Case aContrato[08] == "1"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , aContrato[09] + " Dias" ) 
      Case aContrato[08] == "2"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , aContrato[09] + " Meses" ) 
      Case aContrato[08] == "3"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , aContrato[09] + " Anos" ) 
      Case aContrato[08] == "4"
           OLE_SetDocumentVar(oWord,"Periodo_Locacao"   , "Indeterminado" ) 
   EndCase

   // Prepara o valor para impressão
//   aParcelas:= Condicao(VAL(aContrato[19]), aContrato[11],,Ctod(aContrato[06]))
//   cExtenso := PADR(Extenso(aParcelas[01,02]),100,"")

   nMensal := VAL(aContrato[19]) / VAL(aContrato[09])
   cExtenso := PADR(Extenso(nMensal),100,"")

   OLE_SetDocumentVar(oWord,"Valor_Locacao"    , "R$ " + Transform(nMensal, "@E 999,999,999.99") + " (" + Alltrim(cExtenso) + ") " + CHR(13) + CHR(10) + CHR(13) + CHR(10) + Alltrim(cComplExtendo) ) 

   Do Case
      Case aContrato[20] == "1"
           OLE_SetDocumentVar(oWord,"Tipo_Atendimento" , "ON SITE") 
      Case aContrato[20] == "2"
           OLE_SetDocumentVar(oWord,"Tipo_Atendimento" , "BALCÃO") 
   EndCase        

   // Inicializa as variáveis para os dados dos produtos
   For nContar = 1 to 10
       j := Strzero(nContar,2)
       OLE_SetDocumentVar(oWord,"Qtd_Produto_"  + j , "" ) 
       OLE_SetDocumentVar(oWord,"Cod_Produto_"  + j , "" ) 
       OLE_SetDocumentVar(oWord,"Nome_Produto_" + j, "" ) 
       OLE_SetDocumentVar(oWord,"Numero_Serie_" + j, "" ) 
   Next nContar

   // Pesquisa os produtos a serem impressos
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT *"
   cSql += "  FROM " + RetSqlName("ADZ")
   cSql += " WHERE ADZ_FILIAL = '" + Alltrim(_____Filial)   + "'"
   cSql += "   AND ADZ_PROPOS = '" + Alltrim(_____Proposta) + "'"
   cSql += "   AND D_E_L_E_T_ = ''

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   T_PRODUTOS->( DbGoTop() )
   nContar := 0

   WHILE !T_PRODUTOS->( EOF() )

      nContar := nContar + 1
      j := Strzero(nContar,2)
      
      OLE_SetDocumentVar(oWord,"Qtd_Produto_"  + j , STR(T_PRODUTOS->ADZ_QTDVEN) ) 
      OLE_SetDocumentVar(oWord,"Cod_Produto_"  + j , T_PRODUTOS->ADZ_PRODUT ) 
      OLE_SetDocumentVar(oWord,"Nome_Produto_" + j, T_PRODUTOS->ADZ_DESCRI ) 
      OLE_SetDocumentVar(oWord,"Numero_Serie_" + j, "" ) 

      T_PRODUTOS->( DbSkip() )
      
   ENDDO   

   OLE_UpdateFields(oWord) 

   If MsgYesNo("Imprime o Documento ?")
      Ole_PrintFile(oWord,"ALL",,,1)
   EndIf
  
   SLEEP(15000)
   
   // Fecha o link com o Word
   OLE_CloseFile( oWord )
   OLE_CloseLink( oWord )

Return(.T.)


































// Monta o cabeçalho da página
Static Function xxxCabecalho()



   Private _nLin      := 0

   oPrint := TMSPrinter():New()

   oPrint:SetPaperSize(9)
   oPrint:SetPortrait()
   oPrint:StartPage()

   // Cria os objetos de fontes que serao utilizadas na impressao do relatorio
   oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
   oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
   oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
   oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
   oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
   oFont09n  := TFont():New( "Arial",, 9,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
   oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
   oFont11   := TFont():New( "Arial",,11,.T.,.F.,5,.T.,5,.T.,.F.)
   oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
   oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
   oFont12n  := TFont():New( "Arial",,12,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
   oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
   oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
   oFont25   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
   oFont25b  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
   oFont30   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

   oPrint:Say (_nLin,0100,"CONTRATO DE LOCAÇÃO Nº 0001/14",oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"LOCADOR",oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Razão Social	AUTOMATECH SISTEMAS DE AUTOMACAO LTDA",oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Endereço	    RUA DOUTOR JOAO INACIO, 1110",oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Cidade	        PORTO ALEGRE	UF:	RS	CEP: 90230-181",oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"CNPJ	        03.385.913/0001-61",oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"LOCATÁRIO"    , oFont11)
   oPrint:Say (_nLin,0100,"Razão Social	", oFont11)
   oPrint:Say (_nLin,0100,"Endereço	"    , oFont11)
   oPrint:Say (_nLin,0100,"Cidade		    UF		CEP	", oFont11)
   oPrint:Say (_nLin,0100,"CNPJ	"        , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Objeto: Locação dos equipamentos listados abaixo:", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Qtd.		Cód.Protheus		Descrição do Equipamento		Número de Série", oFont11)
   _nLin += 100			
			
                      

   oPrint:Say (_nLin,0100,"Período Básico de Locação:  36 meses.", oFont11)
   _nLin += 100			
   oPrint:Say (_nLin,0100,"Valor Mensal de Locação: R$ 2.000,00 (dois mil reais).", oFont11)
   _nLin += 100			
   oPrint:Say (_nLin,0100,"Tipo de Atendimento: on site / balcão.", oFont11)
   _nLin += 100			
   oPrint:Say (_nLin,0100,"Início, Término e Prorrogação da Locação: O período  básico de locação inicia-se no ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"primeiro dia do mês seguinte ao recebimento  dos equipamentos. Caso  o  recebimento ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"ocorra antes do início do período básico de locação, durante este período, é devido ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"o pagamento, por dia, de 1/30 do valor mensal da locação. Durante  o período básico ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"de locação convencionado, não  é  possível  rescindir  o  contrato. Após  o período ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"básico de locação  o  contrato prorrogar-se-á  automaticamente cada vez por um mês, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"caso não seja solicitada a sua  rescisão  com  no  mínimo  30  dias  antes  do  seu ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"vencimento, nos termos do Parágrafo 10 das Condições Gerais de Locação.             ", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Condições Gerais de Locação: O LOCATÁRIO é  expressamente  informado  sobre o anexo ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"das Condições Gerais de Locação.", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Autorização de cobrança: O LOCATÁRIO  autoriza  o  LOCADOR,  até  sua  revogação, a ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"realizar a cobrança do valor devido, por meio de  boleto  bancário  acompanhado  do ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"respectivo recibo de locação. A  primeira  mensalidade terá vencimento 15 dias após ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"o início da locação e as demais a cada 30 dias nos meses subsequentes.", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Foro: para dirimir qualquer dúvida advinda do presente contrato, as partes elegem o ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Foro da Comarca de Porto Alegre no Estado do Rio Grande do Sul.", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Estamos de acordo com as condições contratuais  acima e Condições Gerais de Locação ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"anexas.", oFont11)
   _nLin += 200
   oPrint:Say (_nLin,0100,"_______________________________________", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Assinatura do LOCATÁRIO", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Nome e sobrenome em letra de forma, data e carimbo da empresa", oFont11)
   _nLin += 200
   oPrint:Say (_nLin,0100,"_______________________________________", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Assinatura do LOCADOR                  ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Automatech Sistemas de Automação Ltda  ", oFont11)
   _nLin += 200
   oPrint:Say (_nLin,0100,"___________________________________	       _________________________________", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"1ª Testemunha:				               2ª Testemunha:                   ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Nome:						               Nome:                            ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"RG:						                   RG:                              ", oFont11)

   _nLin += 500

   oPrint:Say (_nLin,0100,"CONDIÇÕES GERAIS DO CONTRATO DE LOCAÇÃO", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 1. Impostos:", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Os tributos incidentes sobre os valores cobrados do LOCATÁRIO, a qualquer título, já estão ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"incluídos no preço, e serão recolhidos pelo LOCADOR. Fica  mutuamente  acordado  entre  as ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"partes que quaisquer alterações que impliquem  no  aumento  da  carga tributária incidente ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"sobre  a  operação, tais   como  instituição  de  novos  tributos, aumento  de  alíquotas, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"modificação das práticas reiteradamente  observadas pelas autoridades fiscais competentes, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"decisões administrativas e/ou judiciais  ou  modificação na  interpretação  da  legislação ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"tributária aplicável, acarretarão a correspondente alteração  nos  preços  acordados neste ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"contrato, no mesmo montante do aumento das alíquotas ou dos novos  tributos  incidentes. O ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"LOCADOR comunicará, por escrito, a alteração ocorrida, o seu impacto nos preços e o início ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"vda vigência da respectiva modificação.", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 2. Manutenção:", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    1. Durante  o  período  de  vigência  do  contrato  o  LOCADOR prestará os serviços de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       manutenção  nos  equipamentos  relacionados no objeto, de  acordo  com  o  Tipo  de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       Atendimento especificado.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    2. Os serviços técnicos de manutenção serão  prestados  d e segunda  à sexta-feira, no ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       horário comercial definido pelo LOCADOR, excluindo-se os feriados.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    3. A substituição das partes e peças danificadas, necessárias  a  manutenção  prevista ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       neste  contrato  será  gratuita desde  que  a  falha  ocorra  por  uso  normal  dos ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       equipamentos. ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    4. Ficam excluídos do atendimento técnico de  manutenção gratuito os eventos descritos ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       abaixo:", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       - Quaisquer serviços, partes ou peças necessárias à manutenção de falhas provocadas ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"         por mau uso, imperícia,  negligência,  acidentes,  quedas,  incêndios,  fenômenos ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"         naturais (raios, enchentes, etc) e tentativa de reparo por pessoa não autorizada; ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       - Instalação ou reinstalação de equipamentos, que envolvam ou  não  integração  com " , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"         outros equipamentos e softwares fora deste contrato.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       - Serviços   de   upgrade   de   firmware   ou   outros   aplicativos   necessários ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"         ao funcionamento do software aplicativo do LOCATÁRIO.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    5. Toda  e  qualquer  cobrança  de  serviço  de  reparo somente será processada após a ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       realização do serviço e a aprovação de orçamento prévio.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    6. Todos os serviços serão realizados por pessoal devidamente qualificado pelo LOCADOR,", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       que tem exclusiva responsabilidade  pela integral remuneração de seus colaboradores,", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       incluindo o cumprimento  de  todas  as  obrigações  trabalhistas, previdenciárias e ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       infortunísticas, ficando dessa forma,  excluída  a  responsabilidade  do  LOCATÁRIO ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       sobre tais matérias.", oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 3. Uso e permissões:", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    1. O LOCATÁRIO obriga-se a não entregar a terceiros o  bem  locado para as finalidades ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       convencionadas e mantê-lo às suas expensas em estado regular e operacional.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    2. É vedado ao LOCATÁRIO sublocar o bem locado sem o consentimento prévio do LOCADOR. ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       A recusa da outorga do consentimento pelo LOCADOR, não dá o direito ao LOCATÁRIO de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       resilir o contrato.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    3. O LOCATÁRIO se obriga a preparar e manter local para instalação dos equipamentos em ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       condições adequadas de acordo com as especificações  do  manual  do  equipamento  e ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       outras que o LOCADOR venha solicitar, envolvendo temperatura,  umidade,  tensão  de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       rede elétrica, etc. O LOCATÁRIO  se  obriga  também  a  orientar  seus operadores a ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       tomarem os cuidados básicos de uso e  limpeza  e a impedir que terceiros, mesmo que ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       seus prepostos façam quaisquer reparos ou utilizem os equipamentos em desacordo com ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       suas características."                                                               , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 4. Proteção da propriedade:"                                                      , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"O LOCADOR ou uma pessoa por ele indicada poderá a qualquer tempo visitar e  inspecionar  o ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"bem locado durante o horário de expediente do LOCATÁRIO."                                   , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 5. Assunção do risco da posse:"                                                   , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   1. O LOCATÁRIO assumirá o risco de destruição  acidental,  perda,  dano  acidental  ou " , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      furto do bem locado a partir do momento de sua entrega até a devolução do mesmo."     , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   2. O LOCATÁRIO deverá informar o LOCADOR por  escrito  em  qualquer  uma das hipóteses " , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      previstas na alínea 1."                                                               , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 6. Mudança da sede ou do domicílio:", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"O LOCATÁRIO deve comunicar ao LOCADOR  imediatamente  a  mudança  de  sua  sede  ou  do seu ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"domicilio."                                                                                  , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 7. Transporte e instalação física:"                                                , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"O LOCATÁRIO assumirá perante o LOCADOR os custos de transporte e instalação física. "        , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 8. Consequências da mora, rescisão sem aviso prévio:"                              , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   	1. Caso  o  LOCATÁRIO  deixe  de  efetuar   pontualmente   o   pagamento  dos  valores ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"        contratualmente previstos (aluguel e encargos), sujeitar-se-á ao pagamento de multa ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   	   de 10% sobre o valor em atraso, além de juros moratórios de 1%, ao mês,  acrescidos ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"        de correção monetária, a contar da data do inadimplemento e até o efetivo pagamento.", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   	2. O LOCADOR poderá rescindir o contrato de locação  sem  aviso prévio, se o LOCATÁRIO ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"        se encontrar em mora. Todas  as  despesas  incorridas  no  â m bito de uma cobrança ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"        extrajudicial serão repassadas pelo LOCADOR ao  LOCATÁRIO. O  mesmo  se  aplica  às ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"        custas judiciais, em uma ação de cobrança."                                          , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100," Parágrafo 9. Consequências da rescisão antecipada:"                                        , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    1. Caso o LOCADOR exerça o direito de rescindir sem aviso prévio  o  contrato antes de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       seu vencimento nos termos do parágrafo 8 alínea 2, ou  se  o LOCATÁRIO  rescindir o ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       contrato antes que se complete o período básico de locação, os direitos do  LOCADOR ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       incluem as parcelas restantes do  período  integral  da  locação  ainda  em aberto. ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       A dedução de juros economizados  ou  outros  benefícios  relacionados  a  favor  do ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       LOCATÁRIO serão reguladas nos termos da lei. A reivindicação  do LOCADOR vencerá no ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       dia do recebimento da notificação da rescisão. O  LOCATÁRIO encontrar-se-á em mora, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       se  dentro  de  30  dias  a  p artir do recebimento da comunicação de rescisão e da ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       apresentação da relação dos danos não efetuar o respectivo pagamento."               , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    2. Além disso, o LOCATÁRIO perderá o direito de posse. Ele  estará obrigado a devolver ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       imediatamente o bem locado ao LOCADOR por sua conta e risco observando  o  acordado ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       no item 4.1 do Parágrafo 10, quanto à emissão das notas fiscais. O  bem locado deve ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       ser devolvido no endereço da sede da empresa do LOCADOR  indicado  no  contrato  de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       locação, desde que ele não tenha indicado outro  local  para  a  devolução, que  se ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       encontre fisicamente mais próximo à sede do LOCATÁRIO. Caso o LOCATÁRIO não devolva ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       o bem locado imediatamente,  o  LOCADOR  terá  o  direito,  mas não a obrigação, de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       providenciar a retirada do bem locado às expensas do LOCATÁRIO."                     , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    3. O  bem  locado deve encontrar-se, no momento da  devolução, em  boas  condições  de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       funcionamento, correspondente ao seu estado de entrega, levando-se em  consideração ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       apenas o desgaste causado pelo uso para os fins previstos no contrato."              , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    4. Caso o LOCATÁRIO não devolva  o  bem  locado, apesar de intimado pelo  LOCADOR e em ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       violação  à  sua  obrigação  estabelecida na alínea 2 acima, o LOCATÁRIO  pagará, a ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       partir  do  vencimento final do contrato, 1/30 do valor mensal de locação acordado, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       por dia de atraso."                                                                  , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"    5. O LOCADOR ressalva seu direito de exigir indenização adicional, se o  dano ocorrido" , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"       for imputável ao LOCATÁRIO."                                                         , oFont11)
   _nLin += 100
   oPrint:Say (_nLin,0100,"Parágrafo 10. Término, rescisão, prorrogação do contrato, devolução  do  bem  locado, sem ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"direito de compra do bem locado pelo LOCATÁRIO:"                                           , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   1. Ambas as partes contratantes poderão rescindir o contrato de locação, por  escrito, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      com antecedência mínima de 30 dias, a primeira vez no final do  prazo  inicialmente ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      contratado (período básico de locação)."                                             , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   2. Caso o direito de rescindir o contrato no final do  prazo  inicialmente  contratado ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      não seja exercido, prorrogar-se-á o contrato por mais 30 dias."                      , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   3. Pelo presente contrato não será concedido nenhum direito de  compra  do  bem locado ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      no término do contrato."                                                             , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   4. Caso o contrato de locação seja rescindido nos termos da alínea 1, o LOCATÁRIO terá ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      que devolver o bem locado no final do  contrato. Para  a  devolução  aplicam-se  as ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      disposições do Parágrafo 9, alínea 3. Caso  o  bem  locado  não  seja  devolvido em ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      estado compatível com as disposições contratuais e por  esse motivo  o  produto  de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      sua  venda  seja  inferior  àquele  que seria alcançado se o bem fosse devolvido de ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      acordo  com  as  disposições  contratuais, o LOCATÁRIO ficará obrigado a pagar esta ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      diferença."                                                                          , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   4.1 A entrega  dos  equipamentos será feita com a emissão de nota fiscal pelo LOCADOR, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      que deverá ser detalhada de acordo com as quantidades de cada item. Da mesma forma, ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      o retorno do bem deve ser realizado  por  meio  de  emissão  de  nota  fiscal  pelo ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      LOCATÁRIO, que deve também distinguir as quantidades para cada item. Para o retorno ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      do equipamento alugado o LOCATÁRIO deve emitir a nota fiscal utilizando o CFOP 5949 ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      ou 6949. Os controles de entrada e de saída  do  equipamento  serão feitos a partir ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      das notas fiscais sob o CFOP 5949 ou 6949,  emitida  pelo  LOCADOR  a  na saída dos ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      equipamentos, e das notas fiscais de retorno emitidas pelo LOCATÁRIO.Se o LOCATÁRIO ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      não for obrigado à emissão de notas fiscais,  o  LOCADOR  irá  emitir a nota fiscal ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      para acobertar o retorno do equipamento alugado."                                    , oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"   5. Caso o LOCATÁRIO não devolva o bem locado no prazo contratual,  apesar  de intimado ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      pelo LOCADOR, violando assim sua obrigação nos termos da alínea 4 acima, ele pagará,", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      a partir do vencimento final do contrato, 1/30 do valor mensal de  locação acordado,", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      por dia de atraso. Durante  este  período, as  obrigações do LOCATÁRIO previstas no ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      contrato  permanecem  em vigor. Caso  o  atraso  na  devolução  seja  imputável  ao ", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"      LOCATÁRIO, ele deverá indenizar o dano causado ao LOCADOR pelo atraso."              , oFont11)
   _nLin += 200
   oPrint:Say (_nLin,0100,"_______________________________________", oFont11)
   _nLin += 50            
   oPrint:Say (_nLin,0100,"Assinatura do LOCATÁRIO", oFont11)
   _nLin += 50
   oPrint:Say (_nLin,0100,"Nome e sobrenome em letra de forma, data e carimbo da empresa", oFont11)

   // oPrint:Setup()
   oPrint:Preview()

   DbCommitAll()
   MS_FLUSH()
   
Return(.T.)   












































// Monta o cabeçalho da página
Static Function xCabecalho()


	Local   lAutoPar   := .F.
	Private Li         := 0
	Private _nLin      := 0
    Private nPosicao   := 0
	Private oPrint
	Private cPerg      :="AUTOMAR02"
	Private cStrSql    := ""
	Private cConsulta  := ""
	Private nLastKey   := 0
	Private cLoja      := ""
	Private cTaxa      := 0
	Private cNome      := ""
	Private cNumJ      := ""
	Private cNropor	   := ""
	Private cRevisa    := ""
	Private cVend      := ""
	Private cProp      := ""
	Private lInicio    := .T.
	Private cNumPar    := ""
	Private cProp1     := ""
	Private cMoedaDia  := ""
	Private Totger     := ""
	Private cComple    := ""
	Private cData      := ""
	Private _aEntidade := {}
	Private _cProdNCM  := ""
	Private _cCondPag  := ""
	Private _cValidade := ""
	Private _aObserv   := {}
    Private cSql       := ""
    Private aDiferenca := {}
    Private nDifeReal  := 0
    Private nDifeDolar := 0
    Private y___Filial := k___Filial
    Private y___NovaOp := k___Filial
    
    // Jean Rehermann - ICMS Solidario
    Private aPrdSol  := {}  // Array com os produtos: {PRODUTO, TOTAL_DO_ITEM, TES, MOEDA}
    Private aPSolic  := {}  // Array com os produtos: {PRODUTO, TOTAL_DO_ITEM, TES, MOEDA}
    Private cEntCod  := ""  // Código da entidade (cliente ou prospect)
    Private cLojEnt  := ""  // Loja da entidade
    Private nFrtVal  := 0   // Valor do frete para ser rateado proporcionalmente nos itens antes do calculo do icms
    Private nSolRet  := 0   // Valor de imposto retido calculado e retornado na função AUTOM208
    Private aDifIcm  := {}  // Array transitório que contém os valores do diferencial de icms por moeda (R$/U$)
    Private nContarx := 0   // Contador do Array aDifIcm
    Private aResumoV := {}  // Array que guarda os resultados para display da Planilha de Cálculo

    Private xRetiR     := 0
    Private xRetiD     := 0
	
	lAutoPar := ( cPar1 != Nil .And. cPar2 != Nil )
	
	GeraPerg( cPerg ) // Cria as perguntas

    // y___FIlial Contém a filial vinda da nova tela de oportunidades
    If y___Filial == Nil
       y___Filial := cFilAnt
    Endif   

    If k___Observa == Nil
       k___Observa := 1
    Endif
	
	If lAutoPar
		Pergunte( cPerg, .F. )
		mv_par01 := cPar1
		mv_par02 := cPar1
		mv_par03 := cPar2
		mv_par04 := cPar2
		mv_par05 := CtoD("//")
		mv_par06 := dDataBase + 365
	Else
		If !Pergunte( cPerg, .T. ) // Exibe a tela de parâmetros
			Return
		EndIf
	EndIf

	// Executa a query e cria a área de trabalho
	cStrSql := " SELECT ADY.*        , "
	cStrSql += "        ADZ.*        , "
	cStrSql += "        SB1.B1_GARANT, "
	cStrSql += "        SB1.B1_DESC  , "
	cStrSql += "        SB1.B1_DAUX    "
	cStrSql += "    FROM " + RetSqlName("ADZ") + " ADZ , "
	cStrSql += "         " + RetSqlName("ADY") + " ADY , "
	cStrSql += "         " + RetSqlName("SB1") + " SB1   "
	cStrSql += "  WHERE ADY.ADY_OPORTU  >= '" + MV_PAR01 + "' "
	cStrSql += "    AND ADY.ADY_OPORTU  <= '" + MV_PAR02 + "' "
	cStrSql += "    AND ADY.ADY_PROPOS  >= '" + MV_PAR03 + "' "
	cStrSql += "    AND ADY.ADY_PROPOS  <= '" + MV_PAR04 + "' "
	cStrSql += "    AND ADY.ADY_DATA BETWEEN '" + DtoS( MV_PAR05 ) + "' AND '" + DtoS( MV_PAR06 ) + "'"
	cStrSql += "    AND ADY.ADY_PROPOS   = ADZ.ADZ_PROPOS "
	cStrSql += "    AND ADY.D_E_L_E_T_   = ' ' "
	cStrSql += "    AND ADZ.D_E_L_E_T_   = ' ' "

    If y___NovaOp == Nil
       cStrSql += "    AND ADY.ADY_FILIAL   = '" + xFilial("ADY") + "' "
	   cStrSql += "    AND ADZ.ADZ_FILIAL   = '" + xFilial("ADZ") + "' "
	Else
       cStrSql += "    AND ADY.ADY_FILIAL   = '" + alltrim(y___Filial) + "'"
	   cStrSql += "    AND ADZ.ADZ_FILIAL   = '" + alltrim(y___Filial) + "'"
    Endif	

	cStrSql += "    AND ADZ.ADZ_PRODUT   = SB1.B1_COD "
	cStrSql += "  ORDER BY ADY.ADY_FILIAL, ADZ.ADZ_PROPOS , ADZ.ADZ_ITEM"

	If( Select( "TMPO" ) != 0 )
		TMPO->( DbCloseArea() )
	EndIf

    // Função que calcula o valor do diferencial de Alíquotas para impressão
    xRetiR := 0
    xRetiD := 0

    // Jean Rehermann - 06/02/2014 - Desabilitei esta chamada pois sera calculado por outra funcao
    //XDIFE_ICMS(mv_par01, mv_par02, mv_par03, mv_par04, mv_par05, mv_par06)

	cStrSql := ChangeQuery( cStrSql )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"TMPO",.T.,.T.)

 	oPrint := TMSPrinter():New()

	oPrint:SetPaperSize(9)
	oPrint:SetPortrait()
	oPrint:StartPage()

    oPrint:SaveAllAsJpeg("d:\relatorios\proposta",1180,1600,180)

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont09n  := TFont():New( "Arial",, 9,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont11   := TFont():New( "Arial",,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont12n  := TFont():New( "Arial",,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont25   := TFont():New( "Courier New",,09,,.f.,,,,.f.,.f. )
	oFont25b  := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,08,,.t.,,,,.f.,.f. )

	DbSelectArea("SM2")
	dbSetOrder(1)
	If dbSeek( DtoS( dDataBase ) )
		cMoedaDia := M2_MOEDA2
	Else
		MsgAlert("Valores cambiais não encontrados para o dia "+ DtoC( dDataBase ) )
		cMoedaDia := 1
	EndIf

	cNumPar := MV_PAR03
	
	Do While cNumPar <= MV_PAR04
		
		_cEntidade := {}
		_cProdNCM  := ""
		_cCondPag  := ""
		_cValidade := ""
		_aObserv   := {}
		
		cEnt := Iif( TMPO->ADY_ENTIDA == "1", "SA1", "SUS" )
		dbSelectArea( cEnt )
		dbSetOrder(1)
		dbSeek( xFilial(cEnt) + TMPO->ADY_CODIGO + TMPO->ADY_LOJA )
		
		// Jean Rehermann - Guardo entidade + loja e frete, se houver, para enviar para funcao de calculo do icms solidario
		cEntCod := TMPO->ADY_CODIGO
		cLojEnt := TMPO->ADY_LOJA
		
		If cEnt == "SA1"
		   aAdd( _cEntidade, { AllTrim( SA1->A1_NOME ), SA1->A1_COD, AllTrim( SA1->A1_END ), AllTrim( SA1->A1_BAIRRO ), Transform( SA1->A1_CEP, "@R 99999-999" ), AllTrim( SA1->A1_MUN ), SA1->A1_EST, Transform(SA1->A1_TEL, "@R 9999-9999"), AllTrim( SA1->A1_EMAIL ), SA1->A1_CGC, SA1->A1_INSCR, ADY->ADY_PARAQ, ADY->ADY_TPFRET, ADY->ADY_ENTREG } )
		ElseIf cEnt == "SUS"
		   aAdd( _cEntidade, { AllTrim( SUS->US_NOME ), SUS->US_COD, AllTrim( SUS->US_END ), AllTrim( SUS->US_BAIRRO ), Transform( SUS->US_CEP, "@R 99999-999" ), AllTrim( SUS->US_MUN ), SUS->US_EST, Transform(SUS->US_TEL, "@R 9999-9999"), AllTrim( SA1->A1_EMAIL ), SA1->A1_CGC, SA1->A1_INSCR, ADY->ADY_PARAQ, ADY->ADY_TPFRET, ADY->ADY_ENTREG } )
		EndIf

	    // Pesquisa a condição de pagamento a ser impressa
		DbSelectArea("TMPO")
        _cCondPag  := TMPO->ADZ_CONDPG
		
		Cabecalho()

        _nLin := _nLin - 20
		
		DbSelectArea("TMPO")

		Store 0 to tValorR, tValorU, Totger

		Do while !eof() .And. cProp1 == TMPO->ADZ_PROPOS .AND. cNropor == ADY_OPORTU
			
			aAdd( aPrdSol, { TMPO->ADZ_PRODUTO, TMPO->ADZ_TOTAL, TMPO->ADZ_TES, TMPO->ADZ_MOEDA, TMPO->ADZ_ITEM, TMPO->ADZ_DESCRI } )
			
			DbSelectArea("TMPO")
			
//			oPrint:Say ( _nLin, 0110, TMPO->ADZ_ITEM   , oFont08 )

			oPrint:Say ( _nLin, 0110, TMPO->ADZ_PRODUTO, oFont08 )

            If Alltrim(TMPO->ADZ_PRODUTO) == "002043"
               cDescricao := Alltrim(TMPO->ADZ_DESCRI)
            Else   
               cDescricao := Alltrim(TMPO->B1_DESC) + " " + Alltrim(TMPO->B1_DAUX)
            Endif

            If Len(cDescricao) > 45
   			   oPrint:Say ( _nLin, 0400, Substr(cDescricao,01,45), oFont30 )
   			Else
   			   oPrint:Say ( _nLin, 0400, cDescricao, oFont30 )   			   
   			Endif

			oPrint:Say ( _nLin, 1215, PadC( Iif( TMPO->ADZ_MOEDA == "1", "R$", "US$" ), 10 ), oFont08 )

			If (TMPO->ADZ_QTDVEN - INT(TMPO->ADZ_QTDVEN)) == 0
   			   oPrint:Say ( _nLin, 1380, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999"), 14 ), oFont08,,,,1 )
   			Else
   			   oPrint:Say ( _nLin, 1380, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   			Endif   

//			oPrint:Say ( Li + 0550, 1510, PadL( Transform( TMPO->ADZ_QTDVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
			oPrint:Say ( _nLin, 1470, PadC( TMPO->ADZ_UM, 02 ), oFont08 )
			oPrint:Say ( _nLin, 1655, PadL( Transform( TMPO->ADZ_PRCVEN , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )

			oPrint:Say ( _nLin, 1805, PadL( Transform( TMPO->ADZ_TOTAL  , "@E 99,999,999.99"), 14 ), oFont08,,,,1 )

            // Calcula o Valor do Diferencial de Aliquota para o Produto selecionado
            aPSolic := {}
			aAdd( aPSolic, { TMPO->ADZ_PRODUTO, TMPO->ADZ_TOTAL, TMPO->ADZ_TES, TMPO->ADZ_MOEDA, TMPO->ADZ_ITEM, TMPO->ADZ_DESCRI } )
            nDiferencial := U_AUTOM208( aPSolic, TMPO->ADY_CODIGO, TMPO->ADY_LOJA, TMPO->ADY_FRETE, IIF(TMPO->ADZ_MOEDA == "1", 1, 2), "I" )
        	oPrint:Say ( _nLin, 1955, PadL( Transform( nDiferencial  , "@E 999,999.99"), 14 )   , oFont08,,,,1 )                                                                                                       

            If TMPO->ADZ_MOEDA == "1"
   	 		   oPrint:Say ( _nLin, 2120, PadL( Transform( (TMPO->ADZ_TOTAL + nDiferencial), "@E 99,999,999.99"), 14 ), oFont08,,,,1 )
   	 		Else
   	 		   oPrint:Say ( _nLin, 2120, PadL( Transform( (TMPO->ADZ_TOTAL + nDiferencial), "@E 99,999,999.99"), 14 ), oFont08,,,,1 )   	 		   
   	 		Endif

			oPrint:Say ( _nLin, 2230, Alltrim(TMPO->B1_GARANT), oFont08 )

            If Len(cDescricao) > 45
               _nLin += 50
               If Len(cDescricao) < 90
                  oPrint:Say( _nLin, 0400, Substr(cDescricao,46,45), oFont30)
                  _nLin += 50
               Else
                  oPrint:Say( _nLin, 0400, Substr(cDescricao,46,45), oFont30)
                  _nLin += 50
                  oPrint:Say( _nLin, 0400, Substr(cDescricao,91), oFont30)              
                  _nLin += 50
               Endif
            Endif   
			
			_cProdNCM += AllTrim( TMPO->ADZ_PRODUTO ) +" / "+ Transform( Posicione( "SB1", 1, xFilial("SB1") + TMPO->ADZ_PRODUTO, "B1_POSIPI" ), "@R 9999.99.99" ) +" - "
		    _cCondPag  := TMPO->ADZ_CONDPG
			_cValidade := DtoC( StoD( TMPO->ADY_VAL ) )
			
			If TMPO->ADZ_MOEDA == "2"
				tValorU += TMPO->ADZ_TOTAL &&+ nDiferencial
			Else
				tValorR += TMPO->ADZ_TOTAL &&+ nDiferencial
			EndIf
			
			_nLin := _nLin + 50
			
    		DbSelectArea("TMPO")
			TMPO->( dbSkip() )                                   
			
		EndDo

        // Calcula o Diferencial de ICMS para Valor em Reais
        nSolRet := U_AUTOM208( aPrdSol, cEntCod, cLojEnt, nFrtVal, 1, "T" )
	    xRetiR := nSolRet
 
        // Calcula o Diferencial de ICMS para Valor em Dolar
        nSolRet := U_AUTOM208( aPrdSol, cEntCod, cLojEnt, nFrtVal, 2, "T" )
 	    xRetiD := nSolRet

//     xRetiD := xMoeda( nSolRet, 2, 1, dDataBase, 2 )
        
        // Desenhas os traços verticais dos produtos
		oPrint:Line(_nLin,0100, _nLin, 2330)
//		oPrint:Line(nPosicao,0195, _nLin, 0195)
		oPrint:Line(nPosicao,0395, _nLin, 0395)
		oPrint:Line(nPosicao,1195, _nLin, 1195)
		oPrint:Line(nPosicao,1315, _nLin, 1315)
		oPrint:Line(nPosicao,1455, _nLin, 1455)
		oPrint:Line(nPosicao,1520, _nLin, 1520)
		oPrint:Line(nPosicao,1660, _nLin, 1660)
		oPrint:Line(nPosicao,1835, _nLin, 1835)
		oPrint:Line(nPosicao,1970, _nLin, 1970)
		oPrint:Line(nPosicao,2140, _nLin, 2140)

        _nLin := _nLin + 30
		oPrint:Say (_nLin,110 ,"TOTAIS",oFont11)

//        If tValorR <> 0
//   		   oPrint:Say (_nLin,1900,"R$",oFont11)
//		   oPrint:Say (_nLin,2300,transform(tValorR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
//           _nLin := _nLin + 50
//        Endif
           
//		If tValorU <> 0
// 		   oPrint:Say (_nLin,1900,"US$",oFont11)
//		   oPrint:Say (_nLin,2300,transform(tValorU,"@E 9,999,999,999,999.99"),oFont11,,,,1)
//           _nLin := _nLin + 50
//        Endif

//     	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
//        _nLin := _nLin + 50

         If (tValorR + tValorU) <> 0

           // Imprime o Sub-Total da Proposta Comercial
   		   oPrint:Say (_nLin,0800,"SUB-TOTAL EM R$" ,oFont11)
 		   oPrint:Say (_nLin,1600,"SUB-TOTAL EM US$",oFont11)

//		   oPrint:Say (_nLin,1400,transform((tValorR - xRetiR),"@E 9,999,999,999,999.99"),oFont11,,,,1)
//		   oPrint:Say (_nLin,2300,transform((tValorU - xRetiD),"@E 9,999,999,999,999.99"),oFont11,,,,1)

		   oPrint:Say (_nLin,1400,transform((tValorR),"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,2300,transform((tValorU),"@E 9,999,999,999,999.99"),oFont11,,,,1)

           // Imprime o Valor do Frete
           _nLin := _nLin + 50
   		   oPrint:Say (_nLin,0800,"FRETE EM R$" ,oFont11)
		   oPrint:Say (_nLin,1400,transform(nFrtVal,"@E 9,999,999,999,999.99"),oFont11,,,,1)

           _nLin := _nLin + 50

           // Imprime o Valor do Diferencial do ICMS
   		   oPrint:Say (_nLin,0800,"DIF. ALIQUOTA EM R$" ,oFont11)
   		   oPrint:Say (_nLin,1600,"DIF. ALIQUOTA EM US$",oFont11)
		   oPrint:Say (_nLin,1400,transform(xRetiR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,2300,transform(xRetiD,"@E 9,999,999,999,999.99"),oFont11,,,,1)
           _nLin := _nLin + 50

           // Imprime o Valor Total da Proposta Comercial
   		   oPrint:Say (_nLin,0800,"TOTAL EM R$" ,oFont11)
   		   oPrint:Say (_nLin,1600,"TOTAL EM US$",oFont11)
		   oPrint:Say (_nLin,1400,transform(tValorR + xRetiR + nFrtVal,"@E 9,999,999,999,999.99"),oFont11,,,,1)
		   oPrint:Say (_nLin,2300,transform(tValorU + xRetiD,"@E 9,999,999,999,999.99"),oFont11,,,,1)

//		   oPrint:Say (_nLin,1400,transform(tValorR,"@E 9,999,999,999,999.99"),oFont11,,,,1)
//		   oPrint:Say (_nLin,2300,transform(tValorU,"@E 9,999,999,999,999.99"),oFont11,,,,1)

           _nLin := _nLin + 50
        Endif

//		If tValorU <> 0
// 		   oPrint:Say (_nLin,1900,"US$",oFont11)
//		   oPrint:Say (_nLin,2300,transform(tValorU,"@E 9,999,999,999,999.99"),oFont11,,,,1)
//           _nLin := _nLin + 50
//        Endif


		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,100,_nLin,2330)
        _nLin := _nLin + 30

		// Gera as linhas para as NCMs
		_aObserv := MemoObs( SubStr( _cProdNCM, 1, Len( _cProdNCM ) - 2 ), 180 )

        If Len( _aObserv ) == 0
           _aObserv := {" " }
        Endif

		oPrint:Say (_nLin,0110 ,"[ Código Produto / NCM ]",oFont08)

        _nLin := _nLin + 50
		
		oPrint:Say (_nLin,0110,_aObserv[1],oFont08)

        _nLin := _nLin + 50

		For nX := 2 To Len( _aObserv )
		    oPrint:Say (_nLin,0110,_aObserv[nX],oFont08)
            _nLin := _nLin + 50
  		Next

        _nLin := _nLin + 50
   
		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,0100,_nLin,2330)

        // Se estado do cliente diferente do estado da empresa logada, imprime observações
        If Alltrim(_cEntidade[ 1, 7 ]) == Alltrim(SM0->M0_ESTENT)
        Else
           _nLin := _nLin + 30
           oPrint:Say( _nLin, 0110, "Conforme previsto na legislação, as mercadorias vendidas para fora do estado do " + Alltrim(SM0->M0_ESTENT) + " que não possuem protocolo de ICMS/ST deverão ter", oFont09b)        
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0110, "a guia do imposto do diferencial de alíquota paga pelo adquirente na entrada do produto no Estado destino. Por favor consulte nossa", oFont09b)         
           _nLin := _nLin + 50
           oPrint:Say( _nLin, 0110, "equipe para eventuais dúvidas.", oFont09b)         
           _nLin := _nLin + 50

	       oPrint:Line(nPosicao,0100, _nLin, 0100)        
		   oPrint:Line(nPosicao,2330, _nLin, 2330)        
		   oPrint:Line(_nLin,0100,_nLin,2330)
		Endif

        // Imprime as Observações do Pedido
        _nLin := _nLin + 30
		oPrint:Say (_nLin,0110,"Observações: ",oFont09n)
		_nLin := _nLin + 50

		// Gera as linhas para as observações
        Do Case
           Case k___observa == 1
   		        _cObs := AllTrim( ADY->ADY_OBSP )
           Case k___observa == 2
   		        _cObs := AllTrim( ADY->ADY_OBSI )
           Otherwise
   		        _cObs := ""
   		EndCase

		_aObserv := MemoObs( _cObs, 100 )

		For nX := 1 To Len( _aObserv )
			oPrint:Say (_nLin,0110,_aObserv[nX],oFont08)
			_nLin := _nLin + 50
		Next
  
		oPrint:Line(nPosicao,0100, _nLin, 0100)        
		oPrint:Line(nPosicao,2330, _nLin, 2330)        
		oPrint:Line(_nLin,0100,_nLin,2330)

        _nLin := _nLin + 30

        oPrint:Say( _nLin, 0110, "Os valores cotados em dólar serão convertidos em real de acordo com a taxa do dólar comercial (PTAX venda) do dia do faturamento.", oFont09b)

        _nLin := _nLin + 100

        oPrint:Say( _nLin, 0110, "Sem mais para o momento nos colocamos à disposição para auxiliá-los no que for preciso.", oFont09b)

        _nLin := _nLin + 100
        oPrint:Say( _nLin, 0110, "Atenciosamente", oFont09b)    

        //_nLin := _nLin + 50
        //oPrint:SayBitmap( _nLin, 0100, "vanessap.png", 0700, 0200 )
        //_nLin := _nLin + 100

        oPrint:Line( _nLin, 1800, _nLin, 2300 )

        _nLin := _nLin + 50
        oPrint:Say (_nLin,0110, Upper( Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_NOME" ) ),oFont10b)




        oPrint:Say( _nLin, 1900, "Aceite do Cliente", oFont09b)    
        _nLin := _nLin + 100

        oPrint:Line( _nLin, 0100, _nLin, 2330 )
        oPrint:Line( 0060, 0100, _nLin, 0100 )
        oPrint:Line( 0060, 2330, _nLin, 2330 )

        _nLin := _nLin + 050
        oPrint:Say( _nLin, 0110, "AUTR002.PRW", oFont06)        

		If !Eof()
			cNumPar := ADY->ADY_PROPOS
			oPrint:EndPage()
			oPrint:StartPage()
			li:=0
		Else
			Exit
		Endif
		
	Enddo
	
	TMPO->( DbCloseArea() )

	// oPrint:Setup()
	oPrint:Preview()

	DbCommitAll()
	MS_FLUSH()

Return()

// Monta o cabeçalho da página
Static Function Cabecalho()

    _nLin := 0060

    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 50

    // Logotipo e identificação do pedido
//  oPrint:SayBitmap( _nLin, 0110, "logoautoma.bmp", 0700, 0200 )
    oPrint:Say( _nLin, 1000, "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA", oFont12b  )
    _nLin := _nLin + 70
    oPrint:SayBitmap( _nLin, 0151, "logoautoma.bmp", 0700, 0200 )
    oPrint:Say( _nLin, 1000, "Matriz:", oFont08  )    
    oPrint:Say( _nLin, 1100, "RUA JOÃO INÁCIO, 1110 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0001-61    Insc. Estadual: 096/27777447", oFont08  )    
    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA JOÃO INÁCIO, 1162 - CEP 90.230-181 - PORTO ALEGRE - RS Fone: (51)30178300", oFont08  )    
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0005-95    Insc. Estadual: 096/3531158", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA SÃO JOSÉ, 1767 - CEP: 95.020-270 - CAXIAS DO SUL - RS Fone: (54)32272333", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0002-42    Insc. Estadual: 029/0448913", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "RUA GENERAL NETO, 618 - CEP: 96.015-250 - PELOTAS - RS Fone: (53)30262802", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 0110, "www.automatech.com.br", oFont10  )
    oPrint:Say( _nLin, 1100, "CNPJ: 03.385.913/0004-04    Insc. Estadual: 093/0410289", oFont08  )    

    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1000, "Filial:", oFont08  )
    oPrint:Say( _nLin, 1100, "TI AUTOMAÇÃO E SERVIÇOS LTDA", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "RUA FERNANDO AMARO, 1600 - CEP: 80.050-432 - CURITIBA - PR Fone: (41)30246675", oFont08  )
    _nLin := _nLin + 30
    oPrint:Say( _nLin, 1100, "CNPJ: 12.757.071/0001-12    Insc. Estadual: 9053742146", oFont08  )    

    _nLin := _nLin + 50
    
    oPrint:Line( _nLin, 0100, _nLin, 2330 )

    _nLin := _nLin + 20

    // Pesquisa Nº da Oprtunidade, Proposta Comercial e Data de Emissão para Impressão
    DbSelectArea("AD1")
	DbSetOrder(1)
    
    If y___NovaOp == Nil    
   	   DbSeek( xFilial("AD1") + TMPO->ADY_OPORTU )
   	Else
   	   DbSeek( y___Filial + TMPO->ADY_OPORTU )
   	Endif      	   
		
	cNropor := AD1->AD1_NROPOR
	cRevisa := AD1->AD1_REVISA
	cVend   := AD1->AD1_VEND
    oPrint:Say( _nLin, 0110, "Nº Oportunidade: " + cNropor + "/" + cRevisa, oFont12b)
		
	DbSelectArea("ADY")
	DbSetOrder(1)
    If y___NovaOp == Nil    
   	   DbSeek( xFilial("ADY") + TMPO->ADZ_PROPOS )
   	Else
   	   DbSeek( y___Filial + TMPO->ADZ_PROPOS )   	   
   	Endif   
		
	cProp1 := ADY_PROPOS
    oPrint:Say( _nLin, 0750, "Nº Proposta: " + cProp1, oFont12b)
//  oPrint:Say( _nLin, 1275, "Emissão: "     + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)
//  oPrint:Say( _nLin, 1800, "Validade: "    + DtoC( StoD( TMPO->ADY_VAL ) ) , oFont12b)


    // Pesquisa o nº do Pedido de Venda. Se encontrar, o imprime
    If y___Filial == "04"

       If Select("T_RETPEDIDO") > 0
          T_RETPEDIDO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT CK_FILIAL ,"
       cSql += "       CK_NUMPV  ,"
       cSql += "       CK_PROPOST "
       cSql += "  FROM " + RetSqlName("SCK")
       cSql += " WHERE CK_FILIAL  = '" + Alltrim(y___Filial) + "'"
       cSql += "   AND CK_PROPOST = '" + Alltrim(cProp1)     + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RETPEDIDO", .T., .T. )

       T_RETPEDIDO->( DbGoTop() )

       If !T_RETPEDIDO->( EOF() )
          oPrint:Say( _nLin, 1275, "Pedido Venda: " + T_RETPEDIDO->CK_NUMPV, oFont12b)
       Endif
    Endif

    oPrint:Say( _nLin, 1800, "Emissão: "     + DtoC( StoD( TMPO->ADY_DATA ) ), oFont12b)
    _nLin := _nLin + 70
    oPrint:Say( _nLin, 1800, "Validade: "    + DtoC( StoD( TMPO->ADY_VAL ) ) , oFont12b)

    _nLin := _nLin + 70
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    // Pesquisa dados complementares para impressão
	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT ADY_FILIAL, "
    cSql += "       ADY_PROPOS, "
    cSql += "       ADY_PARAQ , "
    cSql += "       ADY_ENTREG, "
    cSql += "       ADY_TPFRET, "
    cSql += "       ADY_FRETE   "
    cSql += "  FROM " + RetSqlName("ADY")
    cSql += " WHERE ADY_PROPOS = '" + Alltrim(cProp1) + "'"
    cSql += "   AND ADY_FILIAL = '" + Alltrim(cEnt)   + "'"

	cStrSql := ChangeQuery( cStrSql )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrSql),"T_DETALHES",.T.,.T.)

    If !Empty(Alltrim(T_DETALHES->ADY_PARAQ))
       oPrint:Say( _nLin, 0110, "A/C" , oFont10)
       oPrint:Say( _nLin, 0400, Alltrim(T_DETALHES->ADY_PARAQ), oFont10b )
       _nLin := _nLin + 50
    Endif

    oPrint:Say( _nLin, 0110, "Cliente:" , oFont10)
	oPrint:Say( _nLin, 0400, _cEntidade[ 1, 1 ] +" ["+ _cEntidade[ 1, 2 ] +"]", oFont10b )

    oPrint:Say( _nLin, 1500, "Telefone:", oFont10)
    oPrint:Say( _nLin, 1730, _cEntidade[ 1, 8 ], oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Endereço:", oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 3 ]), oFont10b)

    oPrint:Say( _nLin, 1500, "Cidade:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(_cEntidade[ 1, 6 ]) + " - " + AllTrim(_cEntidade[ 1, 5 ]), oFont10b)

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Bairro:"  , oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 4 ]), oFont10b)

    oPrint:Say( _nLin, 1500, "Estado:"  , oFont10)
    oPrint:Say( _nLin, 1730, Alltrim(_cEntidade[ 1, 7 ]), oFont10b)

    _nLin := _nLin + 50
    
    oPrint:Say( _nLin, 0110, "E-mail:"  , oFont10)
    oPrint:Say( _nLin, 0400, Alltrim(_cEntidade[ 1, 9 ]), oFont10b)

    _nLin := _nLin + 50
        
    oPrint:Say( _nLin, 0110, "CNPJ/CPF:", oFont10)

    If Len(AllTrim(_cEntidade[ 1, 10 ])) == 14
       oPrint:Say( _nLin, 0400, Substr(_cEntidade[ 1, 10 ],01,02) + "." + Substr(_cEntidade[ 1, 10 ],03,03) + "." + Substr(_cEntidade[ 1, 10 ],06,03) + "/" + Substr(_cEntidade[ 1, 10 ],09,04) + "-" + Substr(_cEntidade[ 1, 10 ],13,02), oFont10b)
    Else
       oPrint:Say( _nLin, 0400, Substr(_cEntidade[ 1, 10 ],01,03) + "." + Substr(_cEntidade[ 1, 10 ],04,03) + "." + Substr(_cEntidade[ 1, 10 ],07,03) + "-" + Substr(_cEntidade[ 1, 10 ],10,02), oFont10b)       
    Endif

    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "I.E.:"    , oFont10)    
    oPrint:Say( _nLin, 0400, AllTrim( _cEntidade[ 1, 11 ] ), oFont10b)    

    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

    oPrint:Say( _nLin - 20, 0110, "Conforme combinado, apresentamos abaixo a proposta para fornecimento de equipamentos e serviços:"    , oFont10b)        

    _nLin := _nLin + 50
    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 30    

    cNomeTranspo := ""

    oPrint:Say( _nLin,0110, "Vendedor:"       , oFont10)
    oPrint:Say (_nLin,0400, Upper( Posicione( "SA3", 1, xFilial("SA3") + cVend, "A3_NOME" ) ),oFont10b)
    _nLin := _nLin + 50

    oPrint:Say( _nLin, 0110, "Condição Pgtº:"  , oFont10)
    oPrint:Say (_nLin,0400, AllTrim( Posicione( "SE4", 1, xFilial("SE4") + _cCondPag, "E4_DESCRI" )),oFont10b)
    _nLin := _nLin + 50

    If !Empty(Alltrim(T_DETALHES->ADY_TPFRET))
       oPrint:Say( _nLin, 0110, "Frete:"  , oFont10)
       If Alltrim(T_DETALHES->ADY_TPFRET) == "C"
          oPrint:Say (_nLin,0400, "C I F",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "F"
          oPrint:Say (_nLin,0400, "F O B",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "T"
          oPrint:Say (_nLin,0400, "Por Conta de Terceirtos",oFont10b)
       Endif
       If Alltrim(T_DETALHES->ADY_TPFRET) == "S"
          oPrint:Say (_nLin,0400, "Sem Frete",oFont10b)
       Endif

       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete
       If T_DETALHES->ADY_FRETE <> 0
//          oPrint:Say (_nLin,0700, "Valor Frete:",oFont10b)           
//          oPrint:Say (_nLin,0900, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
          nFrtVal := TMPO->ADY_FRETE // Jean Rehermann - 07/02/2014 - Para uso no AUTOM208 (ICMS Solidário - Diferencial de alíquota)
       Endif
       _nLin := _nLin + 50
    Else

       // Se for informado valor do Frete, imprime na mesma linha do tipo de Frete
       If T_DETALHES->ADY_FRETE <> 0
          oPrint:Say (_nLin,0110, "Valor Frete:",oFont10b)           
          oPrint:Say (_nLin,0400, Str(T_DETALHES->ADY_FRETE,10,02), oFont10b)
          nFrtVal := TMPO->ADY_FRETE // Jean Rehermann - 07/02/2014 - Para uso no AUTOM208 (ICMS Solidário - Diferencial de alíquota)
       Endif
    
    Endif
  
    // Imprime a Transportadora cosa esta tenha sido informada na proposta comercial
    If T_DETALHES->ADY_TRANSP <> ''
       oPrint:Say( _nLin,0110, "Transportadora:"  , oFont10)
       oPrint:Say (_nLin,0400, AllTrim( Posicione( "SA4", 1, xFilial("SA4") + T_DETALHES->ADY_TRANSP, "A4_NOME" )),oFont10b)
       _nLin := _nLin + 50
    Endif

    If !Empty(Alltrim(T_DETALHES->ADY_ENTREG))
       oPrint:Say( _nLin, 0110, "Prazo Entrega:"  , oFont10)
       oPrint:Say (_nLin,0400, AllTrim(T_DETALHES->ADY_ENTREG),oFont10b)
       _nLin := _nLin + 50
    Endif   

    oPrint:Line( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50
    oPrint:Say(  _nLin - 20, 1000, "P R O D U T O S"  , oFont12b)

    If y___Filial == "04"
       If T_DETALHES->ADY_QEXAT == "S"
          oPrint:Say(  _nLin - 20, 1800, "QTD EXATA = SIM"  , oFont12b)          
       Endif
    Endif

	If( Select( "T_DETALHES" ) != 0 )
		T_DETALHES->( DbCloseArea() )
	EndIf

    _nLin := _nLin + 50
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )

    nPosicao := _nLin

    _nLin := _nLin + 30

    // Cabeçalho dos Produtos
//	oPrint:Say ( _nLin - 20, 0120, "ITEM"      , oFont08 )
//	oPrint:Say ( _nLin - 20, 0235, "PRODUTO"   , oFont08 )

  	oPrint:Say ( _nLin - 20, 0120, "PRODUTO"   , oFont08 )
	oPrint:Say ( _nLin - 20, 0650, "DESCRICAO" , oFont08 )
	oPrint:Say ( _nLin - 20, 1205, "MOEDA"     , oFont08 )
	oPrint:Say ( _nLin - 20, 1355, "QTD"       , oFont08 )
	oPrint:Say ( _nLin - 20, 1470, "UN"        , oFont08 )
	oPrint:Say ( _nLin - 20, 1530, "UNITÁRIO"  , oFont08 )
	oPrint:Say ( _nLin - 20, 1685, "SUB-TOTAL" , oFont08 )
	oPrint:Say ( _nLin - 20, 1850, "DIF.ICMS"     , oFont08 )
	oPrint:Say ( _nLin - 20, 1990, "VLR. TOTAL"   , oFont08 ) && 2025
	oPrint:Say ( _nLin - 20, 2153, "Garantia-Dias", oFont08 ) && 2200

    _nLin := _nLin + 30
	oPrint:Line ( _nLin, 0100, _nLin, 2330 )
    _nLin := _nLin + 50

Return

// Cria as perguntas
Static Function GeraPerg( cPerg )

	PutSx1( cPerg, "01","OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"OPORTUNIDADE DE?" ,"mv_ch1","C",6,0,0,"G","","AD1","","","mv_par01"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "02","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","OPORTUNIDADE ATE?","mv_ch2","C",6,0,0,"G","","AD1","","","mv_par02"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "03","PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"PROPOSTA DE?"     ,"mv_ch3","C",6,0,0,"G","","ADY","","","mv_par03"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "04","PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"PROPOSTA ATE?"    ,"mv_ch4","C",6,0,0,"G","","ADY","","","mv_par04"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "05","DATA INICIAL?"    ,"DATA INICIAL?"    ,"DATA INICIAL?"    ,"mv_ch5","D",8,0,2,"G","",""   ,"","","mv_par05"," ","","","","","","","","","","","","","","","")
	PutSx1( cPerg, "06","DATA FIM?"        ,"DATA FIM?"        ,"DATA FIM?"        ,"mv_ch6","D",8,0,2,"G","",""   ,"","","mv_par06"," ","","","","","","","","","","","","","","","")

Return()

// Retorna um array com as linhas de texto do campo memo
Static Function MemoObs( cTexto, nTam )

	Local aObserv := {}
	Local nPos := 1
	Local nLinhas := nResto := 0
	
	nLinhas := MlCount( cTexto, nTam )
	
	For nX := 1 To nLinhas
		aAdd( aObserv, MemoLine( cTexto, nTam, nX ) )
	Next

Return( aObserv )

// Imprime uma régua horizontal numerada de 100 em 100 e uma régua vertical numerada de 50 em 50
Static Function PrtRegua()

	For xxx = 100 to 2400 step 100
		oPrint:Line( 0010, xxx, 0030, xxx )
		oPrint:Say( 0010, xxx + 10, AllTrim( Str(xxx) ), oFont08 )
		If xxx > 2400
			Exit
		EndIf
	Next

	For xxx = 50 to 3600 step 50
		oPrint:Line( xxx, 0020, xxx, 0040 )
		oPrint:Say( xxx - 20, 0050, AllTrim( Str( xxx ) ), oFont08 )
		If xxx > 3600
			Exit
		EndIf
	Next

Return

// Função que mostra o total da proposta comercial quando existir diferencial de alíquota
/* // Jean Rehermann | Solutio IT | Desabilitei esta função pois será substituída pela AUTOM208
Static Function XDIFE_ICMS(_mv_par01, _mv_par02, _mv_par03, _mv_par04, _mv_par05, _mv_par06)

   Local aRetDif := {}

   aRetDif := U_MaVerImpos( 2, .F. )   
    
   xRetiR := aRetDif[08]
   xRetiD := aRetDif[09]

Return(.T.)
*/

/*

   OLE_SetDocumentVar(oWord,"Qtd_Produto_01"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_02"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_03"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_04"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_05"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_06"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_07"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_08"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_09"   , "" ) 
   OLE_SetDocumentVar(oWord,"Qtd_Produto_10"   , "" )                         

   // Código dos Produtos
   OLE_SetDocumentVar(oWord,"Cod_Produto_01"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_02"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_03"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_04"   , "" )    
   OLE_SetDocumentVar(oWord,"Cod_Produto_05"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_06"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_07"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_08"   , "" ) 
   OLE_SetDocumentVar(oWord,"Cod_Produto_09"   , "" )    
   OLE_SetDocumentVar(oWord,"Cod_Produto_10"   , "" ) 
   
   // Nome dos Produtos
   OLE_SetDocumentVar(oWord,"Nome_Produto_01"   , "" ) 
   OLE_SetDocumentVar(oWord,"Nome_Produto_02"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_03"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_04"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_05"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_06"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_07"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_08"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_09"   , "" )    
   OLE_SetDocumentVar(oWord,"Nome_Produto_10"   , "" )                            
   
   // Nº de Série dos Produtos
   OLE_SetDocumentVar(oWord,"Numero_Serie_01"   , "" ) 
   OLE_SetDocumentVar(oWord,"Numero_Serie_02"   , "" ) 
   OLE_SetDocumentVar(oWord,"Numero_Serie_03"   , "" )    
   OLE_SetDocumentVar(oWord,"Numero_Serie_04"   , "" )    
   OLE_SetDocumentVar(oWord,"Numero_Serie_05"   , "" )       
   OLE_SetDocumentVar(oWord,"Numero_Serie_06"   , "" )                                                              
   OLE_SetDocumentVar(oWord,"Numero_Serie_07"   , "" )    
   OLE_SetDocumentVar(oWord,"Numero_Serie_08"   , "" )                                                              
   OLE_SetDocumentVar(oWord,"Numero_Serie_09"   , "" )    
   OLE_SetDocumentVar(oWord,"Numero_Serie_10"   , "" )    

*/

*/