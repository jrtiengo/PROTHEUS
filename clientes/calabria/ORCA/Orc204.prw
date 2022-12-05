#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

User Function Orc204()        // incluido pelo assistente de conversao do AP5 IDE em 28/03/00

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NREC,CNUMORC,CSETOR,CSEQORC,CCPGTO,COBS")
SetPrvt("CSERV,CCLIENTE,DCLIENTE,CCONTATO,NCUSTO,CLICCON")
SetPrvt("DEND,DMUN,DTEL,DCGC,NMARGEM,CVEND1")
SetPrvt("CVEND2,CCOMIS1,CCOMIS2,DESPEVEN,PRVALID,PRENTR")
SetPrvt("ICMS,IPI,LUCRO,DESPIND,DESPFIN,CCODSERV")
SetPrvt("NFRETE,NDESC,CPLACA,CMODELO,CANOCAR,CCHASSI")
SetPrvt("CKM,QTDSERV,ACOLS,NVMOD,NVPEC,NIMPOSTOS")
SetPrvt("NSEQ,CDESCRI,N1,N2,WDESPEVEN,WDESPIND")
SetPrvt("WCUSTO1,NFINAL1,WDESCONTO,NFINAL2,NFINAL3,WIPI")
SetPrvt("NFINAL4,NPRCVEN,NVALOR,CRESPADM,CMSGFIM,TITULO")
SetPrvt("TAMANHO,CDESC1,CDESC2,CDESC3,ARETURN,NOMEPROG")
SetPrvt("NLASTKEY,CSTRING,WNREL,CBCONT,CBTXT,N_PAG")
SetPrvt("LI,LI2,NL,DSERV,NLINHAS,SALLIN")
SetPrvt("NN,")

/*...
     ORC204 -   Impressao do Orcamento

     Planejamento - Roberto Mazzarolo

     Execucao - Roberto Mazzarolo

     ...*/

   Dbselectarea("SZZ")
   DbSetOrder(1)
   nRec := Recno()
   cNumOrc  := Szz->ZZ_Orcam
   DbSeek(xFilial("SZZ") + cNumOrc )
   cSetor   := Szz->ZZ_Setor
   cNumOrc  := Szz->ZZ_Orcam
   cSeqOrc  := Szz->Zz_Sequen
   cCpgto   := ZZ_CPgto
   cObs     := ZZ_Obs
   cServ    := ZZ_Servico
   CCliente := ZZ_CodCli
   dCliente := ZZ_Cliente
   cContato := ZZ_Contato
   nCusto   := ZZ_Preco
   cLicCon  := ZZ_LICCONV
   dCliente := Zz_Cliente
   dEnd     := Zz_End
   dMun     := Zz_Mun
   dtel     := Zz_Tel
   dcgc     := Zz_Cgc
   nMargem  := ZZ_Margem
   cVend1   := ZZ_Vend1
   cVend2   := ZZ_Vend2
   cComis1  := ZZ_Comis1
   cComis2  := ZZ_Comis2
   DespEven := zz_DespEve
   PrValid  := ZZ_PrValid
   PrEntr   := Zz_PrEntr
   Icms     := Zz_Icms
   Ipi      := ZZ_Ipi
   Lucro    := ZZ_Lucro
   DespInd  := ZZ_DespInd
   DespFin  := ZZ_DespFin
   cCodServ := ZZ_CodServ
   nFrete   := ZZ_Frete
   nDesc    := ZZ_Descont
   cPlaca   := ZZ_Placa
   cModelo  := ZZ_Modelo
   cAnoCar  := ZZ_Ano
   cChassi  := ZZ_Chassi
   cKm      := ZZ_Km
   QtdServ  := ZZ_QtdServ
   aCols    := {}
   nVMod    := nVPec :=  nImpostos := 0
   While !Eof() .and. cNumOrc == zz_Orcam
       cSeqOrc  := Szz->Zz_Sequen
       cServ    := ZZ_Servico
       nCusto   := ZZ_Preco
       nMargem  := ZZ_Margem
       DespEven := zz_DespEve
       Icms     := Zz_Icms
       Ipi      := ZZ_Ipi
       Lucro    := ZZ_Lucro
       DespInd  := ZZ_DespInd
       DespFin  := ZZ_DespFin
       cCodServ := ZZ_CodServ
       nFrete   := ZZ_Frete
       nDesc    := ZZ_Descont
       QtdServ  := ZZ_QtdServ
  
       Dbselectarea("SZY")
       DbSetOrder(1)
       If DbSeek( xFilial("SZY") + Szz->ZZ_Orcam + Szz->ZZ_Sequen )
          nCusto := nSeq := 0
          If Left(cSetor,2) == "AM" .And. !Empty(cServ)
             cDescri   := AllTrim(cServ)
             n1 := mlCount( cDescri, 39 )
             For n2 := 1 to N1
                 aAdd( aCols , {"  ",Memoline( cDescri, 39 ,N2 ),"  ",0,0,0,"00" + StrZero(n2,2)} )
             Next
          End
          While !Eof() .and. Szz->ZZ_Orcam==Zy_Orcam .and. Szz->ZZ_Sequen==zy_sequen
               DbSelectArea("SB1")
               DbSeek( xFilial("SB1") + Szy->Zy_produto )
               DbSelectArea("SZY")
               
               If Left(cSetor,2) == "AM"
                  cDescri   := AllTrim(Szy->zy_Desc)
                  n1 := mlCount( cDescri, 39 )
                  If sb1->B1_Tipo == "MO"
                     aAdd( aCols , {"  ",Memoline(cDescri,39,1),Space(2),0,0,Zy_Total,"Z901" } )
                     For n2 := 2 to N1
                        aAdd( aCols , {"  ",MemoLine(cDescri,39,N2),"  ",0,0,0,"Z9"+strzero(n2,2) } )
                     Next
                     nVMod := nVMod + Zy_Total
                  Else
                     nSeq := nSeq + 1
                     aAdd( aCols , {Str(nSeq,2),Memoline(cDescri,39,1),Zy_Um,Zy_Quant,Zy_VUnit,Zy_Total,"Z501"} )
                     For n2 := 2 to N1
                        aAdd( aCols , {"  ",MemoLine(cDescri,39,N2),"  ",0,0,0,"Z5"+strzero(n2,2) } )
                     Next
                     nVPec := nVPec + Zy_Total
                  End
               End
               ncusto := nCusto + Zy_Total
               DbSkip()
          EndDo

          If Left(cSetor,2) <> "AM"
             //.... Quanto for setores diferente de automecanica
             wDespEven := ncusto * DespEven/100
             wDespInd  := nCusto * DespInd /100
             wCusto1   := nCusto + wDespEven + wDespInd
             nFinal1   := wCusto1 /  (1 -  cComis1/100 - cComis2/100 - Icms/100 - DespFin /100 - Lucro / 100 - nImpostos/100 )
             wDesconto := nFinal1 *  nDesc/100
             nfinal2   := nfinal1 - wDesconto

             nfinal3   := nfinal2 * ( 1 + nMargem / 100 )
             wIpi      := nfinal3 *  Ipi  / 100
             nFinal4   := nFinal3 + wIpi + nFrete

             nPrcVen   := Round( nFinal4/QtdServ,2)
             nValor    := nPrcVen * QtdServ

             cDescri   := AllTrim(cServ)
             n1 := mlCount( cDescri, 39 )
             For n2 := 1 to N1
                 If n2 == 1
                    aAdd( aCols , {cSeqOrc ,Memoline( cDescri, 39 ,N2 ),"UN",QtdServ,0,0,cSeqOrc + Str(n2,2) } )
                 Else
                    aAdd( aCols , {"  ",Memoline( cDescri, 39 ,N2 ),"  ",0,0,0,cSeqOrc + Str(n2,2)} )
                 End
             Next
             n1 := Len(aCols)
             aCols[n1 ,5 ] := nPrcVen
             aCols[n1 ,6 ] := nValor
          End
       End
       Dbselectarea("SZZ")
       DbSkip()
   End
   If Left(cSetor,2) == "AM"
      If nVPec > 0
         //aAdd( aCols , {"  ",Replicate("-",39),"  ",0,0,0,"Z6  " } )
         aAdd( aCols , {"  ","Total de Pecas.........................","  ",0,0,nVPec,"Z601" } )
         aAdd( aCols , {"  ",Space(39),"  ",0,0,0,"Z602" } )
      End
      If nVMod > 0
         //aAdd( aCols , {"  ",Replicate("-",39),"  ",0,0,0,"Z990" } )
         aAdd( aCols , {"  ","Total da Mao de Obra...................","  ",0,0,nVMod,"Z991" } )
                  //         123456789 123456789 123456789 123456789
         aAdd( aCols , {"  ",Space(39),"  ",0,0,0,"Z992" } )
      End

      aAdd( aCols , {"  ",   "Total Geral............................","  ",0,0,nVMod + nVPec,"Z993" } )
      aAdd( aCols , {"  ",Space(39),"  ",0,0,0,"Z994" } )

      If !Empty(cPlaca) .or. !Empty(cModelo) .or. !Empty(cAnoCar) .or. !Empty(cChassi) .or. !Empty(cKm)
         aAdd( aCols , {"  ","Placa: " + CPlaca + " Mod:" + CModelo ,"  ",0,0,0,"Z995" } )

         If !Empty(cAnoCar) .or. !Empty(cKm)
            aAdd( aCols , {"  ","Ano: " + CAnoCar + "  Km: " + Transform(CKm,"9999,999                ") ,"  ",0,0,0,"Z996" } )
         End

         If !Empty(cChassi)
            aAdd( aCols , {"  ","Chassi:  " + CChassi ,"  ",0,0,0,"Z997" } )
         End

      End
   End


   Processa( {|| PImprime() },"Imprimindo o Orcamento ","Aguarde...")// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==>    Processa( {|| Execute(PImprime) },"Imprimindo o Orcamento ","Aguarde...")

Return

// Substituido pelo assistente de conversao do AP5 IDE em 28/03/00 ==> Function PImprime
Static Function PImprime()
   ProcRegua( Len(acols) )

   cRespAdm := Trim( GetMv("MV_RESPADM") ) //.. responsavel administrativo
   cRespAdm := cRespAdm + Space(30 - Len( crespAdm ) )
   cMsgFim  := Trim( GetMv("MV_LJFISMS") )  //.. Mesagem final
   cMsgFim  := cMsgFim + Space(78 - Len( cMsgFim ) )

   Titulo  := "Orcamento: " + cNumOrc
   Tamanho :="P"
   CDESC1  :=OemToAnsi("Emissao do Orcamento")
   Cdesc2  :=OemToAnsi("")
   Cdesc3  :=OemToAnsi("")
   areturn :={"Zebrado",1,"Administracao",2,2,1,"",1 }
   nomeprog:="ORC204"
   nLASTKEY:= 0
   cstring :="SZZ"
   wnrel   :="ORC204"
   cbcont  := 0
   cbtxt   := space(10)

   wnrel:=setprint(cstring,wnrel,"",titulo,cdesc1,cdesc2,cdesc3,.T.)

   If LastKey()== 27 .or. nLastKey == 27
      return
   End
   SetDefault(aReturn,cString)

   If LastKey()== 27 .or. nLastKey == 27
      return
   End

   n_pag  := 1
   Li     := 80
   Li2    := 80

   aSort( aCols,,,{ |X,Y| X[7]+ X[1] < Y[7]+Y[1] } )
   For nl := 1 to Len(aCols)
       If Li > 53 .or. Li2 > 23

           If Li <> 80
              @ Prow()+1  , 00 Psay  Replicate("-",80)
              @ Prow()+1  , 00 Psay  "|PRAZO DE ENTREGA: "  + PrEntr
              @ Prow()    , 79 Psay  "|"
              @ Prow()+1  , 00 Psay  "|CONDICAO DE PGTO: "  + cCPgto
              @ Prow()    , 79 Psay  "|"
              @ Prow()+1  , 00 Psay  "|PRAZO DE VALIDADE:"  + Str(PrValid,3) + " Dias "
              @ Prow()    , 79 Psay  "|"
              @ Prow()+1  , 00 Psay  "|OBSERVACOES:      "  + Substr(cObs,1,55)
              @ Prow()    , 79 Psay  "|"
              @ Prow()+1  , 00 Psay  "|                  "  + Substr(cObs,56,55)
              @ Prow()    , 79 Psay  "|"
              @ Prow()+1  , 00 Psay  Replicate("-",80)
              @ Prow()+1  , 00 Psay  cMsgFim
              @ Prow()+1  , 50 PSay  "Atenciosamente"
              @ Prow()+1  , 00 Psay  "      AUTORIZACAO                               "+Sm0->M0_NomeCom
              @ Prow()+1  , 00 Psay  "Autorizo a Execucao do(s) Servico(s) de "
              @ Prow()+1  , 00 Psay  "Conformidade com o Presente Orcamento            ______________________________"
              @ Prow()+1  , 00 Psay  "Em   /   /                                      "  + cRespAdm
              @ Prow()+1  , 00 Psay  "                                                Responsavel Administrativo"
           End

           @ 001 , 45 Psay Sm0->M0_Nome
           @ 002 , 35 Psay Sm0->M0_NomeCom
           @ 003 , 25 Psay "Cgc: "  + Sm0->M0_Cgc  + "          Inscr. Est. " + Sm0->M0_Insc
           @ 004 , 25 Psay Trim(Sm0->M0_EndCob) + " - Fone/Fax: " + Trim(Sm0->M0_Tel) //+ " - " + Sm0->M0_CompCob
           @ 005 , 35 Psay "CEP " + Sm0->M0_CepCob + " - " + Sm0->M0_CidCob + " - " + Sm0->M0_EstCob
           @ 007 , 20 Psay " "
           Li := 7

           If n_pag == 1
              sx5->( DbSeek( xFilial("SX5") + "Z2" + cSetor) )
              dServ := Left(Sx5->X5_Descri,20)
              @ 010 , 00 pSay "CLIENTE: " + dCliente + "  CONTATO: " +CcONTATO
              @ 011 , 00 pSay "ENDERECO: " + dEnd
              @ 012 , 00 pSay "FONE: " + dTel
              @ 013 , 00 pSay "MUNICIPO: " + dMun
              @ 014 , 00 pSay "CGC/CPF: " + dCgc
              If !Empty(cLicCon)
                @ 014 , 40 pSay "Licitacao/Convenio.: " + cLicCon
              End
              @ 015 , 00 pSay "DATA: " + TRansform(dDataBase,"")
              @ 015 , 40 pSay "ORCAMENTO N.: " + cNumOrc
              @ 017 , 00 Psay "Em atendimento a solicitacao de V.Sa(s) segue abaixo a discriminacao de material"
              @ 018 , 00 Psay "mao de obra , preco e condicoes referente aos servicos de " + dServ
              Li := 19
           Else
              @ 10 , 40 pSay "ORCAMENTO N.: " + cNumOrc
              Li := 11
           End
           @ Li,     00 Psay  Replicate("-",80)
           @ Li + 1, 00 Psay  "|Item|Quant.|Unid| Historico                             |Vlr.Unit.| Vlr.Total |"
           @ Li + 2, 00 Psay  Replicate("-",80)
                              *| 01 |999.99| ee |DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD|99,999.99|9999,999.99|
                              *012345678901234567890123456789012345678901234567890123456789012345678901234567890
                              *0         1         2         3         4         5         6         7         8
           Li := Li + 2
           Li2 := 0

           n_Pag := n_pag + 1
       End

       Li2 := Li2 + 1
       Li := Li + 1
       @ Li , 00 Psay   "| " + aCols[ nl,1]
       If aCols[nl,4] > 0
           @ Li , 05 Psay "|" + Transform(acols[nl,4],"999.99|")
        Else
           @ Li , 05 Psay "|      |"
        End
        //ESTAVA ERRADO
        @ Li , 14 Psay aCols[nl,3] + " |"  + aCols[nl,2 ] + "|" +;
                       If(aCols[nl,5] > 0 ,Transform( aCols[nl ,5],"@e 99,999.99|")  ,"         |") +;
                       If(aCols[nl,6] > 0 ,Transform( aCols[nl ,6],"@e 9999,999.99|"),"           |")
   Next
   nLinhas :=  23 - li2
   SalLin := Int( 39 / nLinhas )
   For nn := 0 to 21-li2
       @ Prow()+1 , 00 Psay  "|    |      |    |"
       @ Prow()   , nn*SalLin+18 Psay  Replicate("*",SalLin)
       @ PRow()   , 57 Psay "|         |           |"
   Next
   @ Prow()+1  , 00 Psay  "|    |      |    |"
   If nn*SalLIn + 2 < 23
      @ prow() ,nn*SalLIn+18  Psay Replicate("*" , 22 - nn*SalLIn )
   End
   @ Prow()    , 57 Psay    "|*********|***********|"

   Se4->( DbSeek( xFilial("SE4") + cCpgto ) )
   @ Prow()+1  , 00 Psay  Replicate("-",80)
   @ Prow()+1  , 00 Psay  "|PRAZO DE ENTREGA: "  + PrEntr
   @ Prow()    , 79 Psay  "|"
   @ Prow()+1  , 00 Psay  "|CONDICAO DE PGTO: "  + cCPgto
   @ Prow()    , 79 Psay  "|"
   @ Prow()+1  , 00 Psay  "|PRAZO DE VALIDADE:"  + Str(PrValid,3) + " Dias "
   @ Prow()    , 79 Psay  "|"
   @ Prow()+1  , 00 Psay  "|OBSERVACOES:      "  + Substr(cObs,1,55)
   @ Prow()    , 79 Psay  "|"
   @ Prow()+1  , 00 Psay  "|                  "  + Substr(cObs,56,55)
   @ Prow()    , 79 Psay  "|"
   @ Prow()+1  , 00 Psay  Replicate("-",80)
   @ Prow()+1  , 00 Psay  cMsgFim
   @ Prow()+1  , 50 PSay  "Atenciosamente"
   @ Prow()+1  , 00 Psay  "      AUTORIZACAO                               "+Sm0->M0_NomeCom
   @ Prow()+1  , 00 Psay  "Autorizo a Execucao do(s) Servico(s) de "
   @ Prow()+1  , 00 Psay  "Conformidade com o Presente Orcamento            ______________________________"
   @ Prow()+1  , 00 Psay  "Em   /   /                                      "  + cRespAdm
   @ Prow()+1  , 00 Psay  "                                                Responsavel Administrativo"
   If aReturn[5] == 1
      set printer to commit
      ourspool(wnrel)
   End
   FT_PFLUSH()
Return

