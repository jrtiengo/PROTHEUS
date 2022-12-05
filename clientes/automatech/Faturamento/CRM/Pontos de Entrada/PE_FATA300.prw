#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FT300GRAºAutor ³SAMUEL / EDISON        º Data ³  15/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esse ponto de entrada foi desenvolvido, para levar as      º±±
±±º          ³ observações da proposta de venda aprovada para o pedido de º±±
±±º          ³ venda, gerado a partir da proposta aprovada.               º±±
±±º          ³ Foi necessário criar um índice com número da oportunidade  º±±
±±º          ³ na tabela ADY,                                             º±±
±±º          ³ campo: ADY_OPORTU,                                         º±±
±±º          ³ Chave:ADY_FILIAL+ADY_OPORTU.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PROTHEUS - AUTOMATECH                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FT300GRA

   Local _aAreaADY  := ADY->(GetArea())   //Tabela de propostas de venda
   Local _aAreaAD1  := AD1->(GetArea())   //Tabela de oportunidades
   Local _aAreaSC5  := SC5->(GetArea())   //Tabela de pedido de venda
   Local _msg       := ""
   Local _ECT       := ""
   Local __KFrete   := 0
   Local __KTipoF   := ""
   Local __KTrans   := ""
   Local cSql       := ""
   Local __Propos   := ""
   Local __Revisao  := ""
   Local __Chave    := ""
   Local __Posicao  := ""
   Local lBloqueia  := .F.
   Local xxx_Nr_OC  := ""
   Local cVend_um   := ""
   Local cVend_dois := ""
 	
   U_AUTOM628("PE_FATA300")

   // Verifica se a proposta comercial é de remessa para demosntração.
   // Se for, verifica se houve a informação da data prevista de retorno dos produtos.
   // Se não estiver informado, abre janela para o usuário informar a data prevista.
   If TYPE("aHeader") == "U"
      __Posicao := ascan(aHeader5,{ |x| x[2] == 'ADJ_PROPOS' } )
      __Propos  := aCols5[ 1 ][ __POsicao ]
      __Revisao := ascan(aHeader5,{ |x| x[2] == 'ADJ_REVISA' } )
      __Filial  := xFilial("ADZ")
   Else   
      __Posicao := ascan(aHeader,{ |x| x[2] == 'ADJ_PROPOS' } )
      __Propos  := aCols[ 1 ][ __POsicao ]
      __Revisao := ascan(aHeader5,{ |x| x[2] == 'ADJ_REVISA' } )
      __Filial  := xFilial("ADZ")
   Endif   

   If Select("T_PREVISTO") > 0
      T_PREVISTO->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ADZ_FILIAL,"
   cSql += "       ADZ_PROPOS,"
   cSql += "       ADZ_PRODUT,"
   cSql += "       ADZ_ITEM  ,"
   cSql += "       ADZ_TES   ,"
   cSql += "       ADZ_DEVO  ,"
   cSql += "       ADZ_DTENTR,"
   cSql += "       ADZ_ORDC  ,"
   cSql += "       ADZ_ORDS   "
   cSql += "  FROM " + RetSqlName("ADZ") 
   cSql += " WHERE ADZ_PROPOS = '" + Alltrim(__Propos) + "'"
   cSql += "   AND ADZ_FILIAL = '" + Alltrim(__Filial) + "'"
   cSql += "   AND ADZ_TES IN ('523', '542') "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

   lBloqueia := .F.
   
   WHILE !T_PREVISTO->( EOF() )

      If Ctod(T_PREVISTO->ADZ_DEVO) == Ctod("  /  /    ")
         lBloqueia := .T.
         Exit
      Endif

      If T_PREVISTO->ADZ_DEVO > (Date() + 45)
         lBloqueia := .T.
         Exit
      Endif
      
      T_PREVISTO->( DbSkip() )
      
   ENDDO
      
   If lBloqueia 
      U_AUTOM135(1, __Propos, __Filial)
   Endif

   IF AD1->AD1_STATUS == "9"
		
  	  DBSELECTAREA("ADY")
	  DBORDERNICKNAME("ADYFILOPOR")
	  DBSEEK(xFilial("ADY")+AD1->AD1_NROPOR)
		
	  _msg := ADY->ADY_OBSI
      _Ect := ""

      If !Empty(Alltrim(ADY_TSRV))
         Do Case
            Case ADY_TSRV == "41106"
                 _Ect := "41106 - PAC"
            Case ADY_TSRV == "40010"
                 _Ect := "40010 - SEDEX"
            Case ADY_TSRV == "40215"
                 _Ect := "40215 - SEDEX 10"
         EndCase
      Endif
		
      __KFrete := ADY->ADY_FRETE
      __KTipoF := ADY->ADY_TPFRET
      __KTrans := ADY->ADY_TRANSP

      // Atualiza o campo C5_MENNOTA com as ordens de compra da proposta comercial
      If Select("T_OCOMPRAS") > 0
   	     T_OCOMPRAS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ADZ_FILIAL,"
      cSql += "       ADZ_PROPOS,"
      cSql += "       ADZ_PRODUT,"
      cSql += "       ADZ_ITEM  ,"
      cSql += "       ADZ_TES   ,"
      cSql += "       ADZ_DEVO  ,"
      cSql += "       ADZ_DTENTR,"
      cSql += "       ADZ_ORDC  ,"
      cSql += "       ADZ_ORDS   "
      cSql += "  FROM " + RetSqlName("ADZ") 
      cSql += " WHERE ADZ_PROPOS = '" + Alltrim(__Propos) + "'"
      cSql += "   AND ADZ_FILIAL = '" + Alltrim(__Filial) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OCOMPRAS", .T., .T. )

      xxx_Nr_OC := ""
      T_OCOMPRAS->( DbGoTop() )
      WHILE !T_OCOMPRAS->( EOF() )
         If !Empty(Alltrim(T_OCOMPRAS->ADZ_ORDC))
            xxx_Nr_OC := xxx_Nr_OC + Alltrim(T_OCOMPRAS->ADZ_ORDC) + "/" + Alltrim(T_OCOMPRAS->ADZ_ORDS) + ", "
         Endif   
         T_OCOMPRAS->( DbSkip() )
      ENDDO   

      If !Empty(Alltrim(xxx_Nr_OC))
         xxx_Nr_OC := "PEDIDO NR. " + Alltrim(SC5->C5_NUM) + " O.COMPRA(S) " + Substr(xxx_Nr_OC,01,Len(Alltrim(xxx_Nr_OC)) - 1)
      Else
         xxx_Nr_OC := "PEDIDO NR. " + Alltrim(SC5->C5_NUM)
      Endif

      // Pesquisa o código dos vendedores para popular os campos da tabel SC5
      If Select("T_COMISSAO") > 0
   	     T_COMISSAO->( dbCloseArea() )
      EndIf
      
      cSql := "" 
      cSql := "SELECT AD1_VEND, "
      cSql += "       AD1_VEND2 "
      cSql += "  FROM " + RetSqlName("AD1")
      cSql += " WHERE AD1_FILIAL = '" + Alltrim(__Filial) + "'"
      cSql += "   AND AD1_PROPOS = '" + Alltrim(__Propos) + "'"
//    cSql += "   AND AD1_REVISA = '" + Alltrim(__Revisao) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

      If T_COMISSAO->( EOF() )
         cVend_um   := ""
         cVend_dois := ""
      Else
         cVend_um   := T_COMISSAO->AD1_VEND
         cVend_dois := T_COMISSAO->AD1_VEND2
      Endif

	  DBSELECTAREA("SC5")
		
	  RECLOCK("SC5",.F.)
      SC5->C5_CLIENT  := SC5->C5_CLIENTE
      SC5->C5_LOJAENT := SC5->C5_LOJACLI
	  SC5->C5_OBSI    := _msg
      SC5->C5_TSRV    := _Ect
      SC5->C5_FRETE   := __KFrete
      SC5->C5_TPFRETE := __KTipoF
      SC5->C5_TRANSP  := __KTrans
      SC5->C5_MENNOTA := xxx_Nr_OC
      SC5->C5_VEND1   := cVend_um
      SC5->C5_VEND2   := cVend_dois 
	  MSUNLOCK()
		
	  RestArea( _aAreaADY )
	  RestArea( _aAreaAD1 )
	  RestArea( _aAreaSC5 )
		
   ENDIF

   /*
   ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
   ±±ºPrograma  ³PE_FATA300ºAutor  ³ Cesar Mussi        º Data ³  14/12/11   º±±
   ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
   ±±ºDesc.     ³                                                            º±±
   ±±º          ³                                                            º±±
   ±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
   ±±ºUso       ³ AP                                                        º±±
   ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
   */

   IF AD1->AD1_STATUS == "9" .AND. !empty(AD1->AD1_FCS) // Status encerrado e fator crítico de sucesso informado

      If TYPE("aHeader") == "U"
     	 nADJProp := ascan(aHeader5,{ |x| x[2] == 'ADJ_PROPOS' } )
	     nADJItem := ascan(aHeader5,{ |x| x[2] == 'ADJ_ITEM  ' } )
	     cPropos  := aCols5[ 1 ][ nADJProp ]
	  Else   
    	 nADJProp := ascan(aHeader,{ |x| x[2] == 'ADJ_PROPOS' } )
	     nADJItem := ascan(aHeader,{ |x| x[2] == 'ADJ_ITEM  ' } )
	     cPropos  := aCols[ 1 ][ nADJProp ]
	  Endif   

	  _cChave  := xFilial("ADZ") + cPropos + "1"
	  _aArea   := GetArea()
	
	  DbSelectArea("ADZ")
	  dbSetOrder(2)
	  If dbSeek( _cChave )
		
  	     Do While _cChave == ADZ->ADZ_FILIAL+ADZ->ADZ_PROPOS+ADZ->ADZ_FOLDER
			
            // Consulta dados dos Itens do Pedido de Venda
            cSql := ""
		    cSql := "SELECT C6_FILIAL, "
		    cSql += "       C6_NUM   , "
		    cSql += "       C6_ITEM  , "
		    cSql += "       C6_PRODUTO "
		    cSql += "  FROM " + RetSqlName("SC6")
		    cSql += " WHERE C6_NUMORC  = '" + ADZ->ADZ_ORCAME + ADZ->ADZ_ITEMOR + "'" 
		    cSql += "   AND D_E_L_E_T_ = ''"

		    cSql := ChangeQuery( cSql )
		    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_C6", .T., .T. )
				
		    cChaSC6 := T_C6->C6_FILIAL + T_C6->C6_NUM + T_C6->C6_ITEM + T_C6->C6_PRODUTO
		    cCodPed := T_C6->C6_NUM
				
		    T_C6->( dbCloseArea() )
				
		    dbSelectArea("SC6")
		    dbSetOrder(1)
		 
		    If dbSeek( cChaSC6 )
				
			   Reclock("SC6",.f.)
			   // SC6->C6_QTGMIN := ADZ->ADZ_QTGMIN
			   SC6->C6_QTGMRG := Round( ADZ->ADZ_QTGMRG, 2 )
               SC6->C6_DTADEV := ADZ->ADZ_DEVO
               SC6->C6_ENTREG := ADZ->ADZ_DTENTR
               SC6->C6_LACRE  := ADZ->ADZ_LACRE
			   MsUnlock()
					
		    EndIf
				
		    dbSelectArea("ADZ")
		    dbSkip()
	  
	     EndDo

      EndIf
		
      RestArea(_aArea)
		
   ENDIF

   // Envia para o programa que verifica se existem pendências finenceiras para o cliente da oportunidade.
   If TYPE("aHeader") <> "U"
      U_AUTOM156(M->AD1_CODCLI, M->AD1_LOJCLI, 2)
   Endif

Return
