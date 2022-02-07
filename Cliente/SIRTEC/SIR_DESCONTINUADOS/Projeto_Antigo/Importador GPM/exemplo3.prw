#Include 'Protheus.ch' //Informa a biblioteca
#Include 'TOTVS.ch' //Informa a biblioteca


User Function exemplo3()

   Local cGet1	 := Space(25)
   Local cGet2	 := Space(25)
   Local cGet3	 := Space(25)

   Local oGet1
   Local oGet2
   Local oGet3

   Local nOpc 		 := 0	//GD_UPDATE
   Local cPesqCpo	 :=	Space(TamSx3('B1_COD')[01])	
   Local cPesqDesc	 :=	Space(TamSx3('B1_DESC')[01])	
   
   Private cDoTipo	 :=	Space(TamSx3('B1_TIPO')[01])	
   Private cAteTipo	 :=	Replicate('Z', TamSx3('B1_TIPO')[01])
   Private cDoGrupo	 :=	Space(TamSx3('B1_GRUPO')[01])	
   Private cAteGrupo :=	Replicate('Z', TamSx3('B1_GRUPO')[01])
   Private cDoProd	 :=	Space(TamSx3('B1_COD')[01])	
   Private cAteProd	 :=	Replicate('Z', TamSx3('B1_COD')[01])
   Private cNomeArq	 :=	Space(100)	
   Private cPathArq	 :=	Space(200)
   Private aMyCols 	 := {}
   Private aMyHeader := {}
   Private oBrwCpo
   Private oDlgE
 
   SX2->(DbSeek('SB1'))
   
   If SX2->X2_MODO == 'E'
	  cDaFilial	 :=	cFilAnt	
	  cAteFilial :=	cFilAnt
   EndIf

   SetPrvt("oFont2","oDlgE","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oBtn1","oBrwCpo","oBtn2","oBtn3")
   SetPrvt("oGet4")

   oFont2     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )

   DEFINE MSDIALOG oDlgE TITLE "Parâmetros Criação de OS" FROM C(000),C(000) TO C(490),C(1000) PIXEL

   @ C(004),C(005) Say "Nº Contrato"       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(083) Say "Centro de Serviço" Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(004),C(161) Say "Tipo de Serviço"   Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(013),C(005) MsGet oGet1 Var cGet1 Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
   @ C(013),C(083) MsGet oGet2 Var cGet2 Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
   @ C(013),C(161) MsGet oGet3 Var cGet3 Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

//   oDlgE      := MSDialog():New( 000,000,300,700,"Exportar Cad.Produto",,,.F.,,,,,,.T.,,oFont2,.T. )

   // Cria o cabeçalho do grid
//   Aadd(aMyHeader, {'Cria OS'               , 'PAR_CRIA',  '!@', 10, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Data Inicial'          , 'PAR_DINI', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Data Final'            , 'PAR_DFIM', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Empresa'               , 'PAR_EMPR', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Filial'                , 'PAR_FILI', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Cliente'               , 'PAR_CLIE', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Loja'                  , 'PAR_LOJA', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Descrição Clientes'    , 'VAR_NCLI', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Cond.Pgtº'             , 'PAR_COND', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Descrição Cond. Pgtº'  , 'VAR_NCON', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Tabela Preço'          , 'PAR_TABE', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Descrição Tabela preço', 'VAR_NTAB', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Tipo de OS'            , 'PAR_TPOS', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Descrição Tipo de OS'  , 'VAR_NTPO', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Código Serviço'        , 'PAR_CSER', '!@', 30, 00, '', , 'C' })
//   Aadd(aMyHeader, {'Descrição Serviço'     , 'VAR_NSER', '!@', 30, 00, '', , 'C' })

   // Popula o grid
   // fazer aqui o select sobre a tabela customizada de parâmetros de Criação de OS
//   Aadd(aMyCols, {"S", "01/06/2019", "10/062019"}) &&, "02", "01", "000001", "01", "Nome do Cliente", "001", " A Vista", "001", "Tabela de Preço 01", "Tipo de OS", "Descrição Tipo de OS", "000001", "Descrição do Tipo de Serviço"})

                                                      
   Aadd(aMyHeader, {'Cria OS'               , 'MARCA'  , '!@', 01, 00, '', , 'C' })
   Aadd(aMyHeader, {'Dia Inicial'           , 'CAMPO'  , '!@', 02, 00, '', , 'C' })
   Aadd(aMyHeader, {'Dia Final'             , 'DESCRI' , '!@', 02, 00, '', , 'C' })
   Aadd(aMyHeader, {'Empresa'               , 'DESCRI1', '!@', 02, 00, '', , 'C' })
   Aadd(aMyHeader, {'Filial'                , 'DESCRI1', '!@', 02, 00, '', , 'C' })
   Aadd(aMyHeader, {'Cliente'               , 'DESCRI1', '!@', 06, 00, '', , 'C' })
   Aadd(aMyHeader, {'Loja'                  , 'DESCRI1', '!@', 02, 00, '', , 'C' })
   Aadd(aMyHeader, {'Descrição dos Clientes', 'DESCRI1', '!@', 40, 00, '', , 'C' })
   Aadd(aMyHeader, {'Cond. Pgtº.'           , 'DESCRI1', '!@', 03, 00, '', , 'C' })
   Aadd(aMyHeader, {'Descrição Cond. Pgtº.' , 'DESCRI1', '!@', 30, 00, '', , 'C' })
   Aadd(aMyHeader, {'Tabela Preço'          , 'DESCRI1', '!@', 03, 00, '', , 'C' })
   Aadd(aMyHeader, {'Descrição Tabela Preço', 'DESCRI1', '!@', 30, 00, '', , 'C' })
   Aadd(aMyHeader, {'Tipo de OS'            , 'DESCRI1', '!@', 40, 00, '', , 'C' })
   Aadd(aMyHeader, {'Descrição Tipo de OS'  , 'DESCRI1', '!@', 40, 00, '', , 'C' })

//   DbSelectArea('SX3');DbSetOrder(1)
// 
//   If DbSeek('SB1')
//	  Do While !Eof() .And. SX3->X3_ARQUIVO == 'SB1'
//	 	 If SB1->(FieldPos(SX3->X3_CAMPO)) > 0 // X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
//			cMarca := IIF(AllTrim(SX3->X3_CAMPO) $ 'B1_FILIAL\B1_COD\B1_UM\B1_CUSTD\B1_MCUSTD', 'X', Space(01))
//			Aadd(aMyCols, {cMarca, SX3->X3_CAMPO,  SX3->X3_TITULO, "02", "01", "000001", "01", "Harald hans Löschenkohl", "001", "A Vista", "001", "Tabela Preço Especial", "Tipo de Serviço", "Descrição Tipo de Serviço", .F. })
//
//		 EndIf
//	     DbSkip()
//	  EndDo
//   EndIf

   Aadd(aMyCols, {Space(01),;
                  Space(02),;
                  Space(02),;
                  Space(02),;
                  Space(02),;
                  Space(06),;
                  Space(02),;
                  Space(40),;
                  Space(03),;
                  Space(30),;
                  Space(03),;
                  Space(30),;
                  Space(40),;
                  Space(40),;
                  .F.})



   oBrwCpo := MsNewGetDados():New(035,005,290,635, GD_INSERT+GD_DELETE+GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',,0,999,'AllwaysTrue()','','AllwaysTrue()',oDlgE,aMyHeader,aMyCols )


//   oBrwCpo:oBrowse:bLDblClick 	:= {|| xDbClickGrid('') , oBrwCpo:oBrowse:Refresh() }
//   oBrwCpo:oBrowse:bHeaderClick := {|| xDbaHeaderClick(), oBrwCpo:oBrowse:Refresh() }

//   oBtn3      := TButton():New( 200,272,"Exportar",oDlgE,{|| Processa ({|| xExpSB1(), oDlgE:End() },'Aguarde gerando arquivo de PRODUTOS', 'Processando...', .T.) },037,012,,oFont2,,.T.,,"",,,,.F. )
//   oBtn2      := TButton():New( 200,340,"Sair"    ,oDlgE,{|| oDlgE:End() },037,012,,oFont2,,.T.,,"",,,,.F. )

   @ C(230),C(422) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgE
   @ C(230),C(461) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )


   oDlgE:Activate(,,,.T.)

Return()

