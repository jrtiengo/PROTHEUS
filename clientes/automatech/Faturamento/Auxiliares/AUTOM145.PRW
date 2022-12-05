#include "Protheus.ch"                             

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM145.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/12/2012                                                          *
// Objetivo..: Importação do Cadastro do TES                                       *
//**********************************************************************************

User Function AUTOM145()

   Local lChumba     := .F.
   
   Private cCaminho  := Space(25)
   Private oCaminho

   Private oDlg

   Private nMeter1	 := 0
   Private oMeter1

   U_AUTOM628("AUTOM145")

   DEFINE MSDIALOG oDlg TITLE "Importação do Arquivo do TES" FROM C(178),C(181) TO C(302),C(633) PIXEL

   @ C(005),C(005) Say "Arquivo a ser importado" Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(209) Button "..."   Size C(012),C(010) PIXEL OF oDlg  ACTION(BUSCATES())
   @ C(015),C(005) MsGet oCaminho Var cCaminho When lChumba Size C(203),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(005) METER oMeter1  VAR nMeter1               Size C(215),C(008) NOPERCENTAGE PIXEL OF oDlg

   @ C(044),C(080) Button "Importar" Size C(037),C(012) PIXEL OF oDlg ACTION( IMPARQTES( cCaminho ) )
   @ C(044),C(119) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oMeter1:Refresh()
   oMeter1:Set(0)
   oMeter1:SetTotal(100)

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre diálogo de pesquisa do arquivo do TES a ser utilizado para importação
Static Function BUSCATES()

   cCaminho := cGetFile('*.txt', "Selecione o Arquivo de Inventário",1,"C:\",.F.,16,.F.)

Return .T. 

// Função que importa o invetário do TES
Static Function IMPARQTES( _Caminho )

   Local lExiste   := .T.
   Local cConteudo := ""
   Local nContar   := 0
   Local nEndereco := 0
   Local cProduto  := ""
   Local cSerie    := ""
   Local nQuanti   := 0
   Local aTes      := {}
   Local nSepara   := 0
   Local j         := ""

   Private lVolta    := .F.

   If Empty(Alltrim(_Caminho))
      MsgAlert("Arquivo do TES a ser importado não informado.")
      Return .T.
   Endif

   // Abre o arquivo de inventário especificado
   nHandle := FOPEN(Alltrim(_Caminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
   Endif

   // Lê o tamanho total do arquivo
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // Lê todos os Produtos
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
 
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
 
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
                
       Else
          
          cConteudo := cConteudo + "#"
          _Linha    := ""
          
          // Declara as variáveis para alimentar o array aTes
          For nSepara = 1 to U_P_OCCURS(cConteudo, "#", 1)
              _Linha := _Linha + Alltrim(U_P_CORTA(cConteudo, "#", nSepara)) + "|"
          Next nSepara              
          
          aAdd( aTes,  _Linha  )

          cConteudo := ""

          If Substr(xBuffer, nContar, 1) == chr(13)
             nContar += 1
          Endif   
            
       Endif

   Next nContar    

   // Realiza a gravação dos registros
   For nContar = 1 to Len(aTes)
           
       _String := aTes[nContar]
   
       dbSelectArea("SF4")
       RecLock("SF4",.T.)

       F4_FILIAL   := U_P_CORTA(_String, "|", 2)
       F4_CODIGO   := U_P_CORTA(_String, "|", 3)
       F4_TIPO     := Substr(U_P_CORTA(_String, "|", 05),01,01)
       F4_ICM      := Substr(U_P_CORTA(_String, "|", 06),01,01)
       F4_IPI      := Substr(U_P_CORTA(_String, "|", 07),01,01)
       F4_CREDICM  := Substr(U_P_CORTA(_String, "|", 08),01,01)
       F4_CREDIPI  := Substr(U_P_CORTA(_String, "|", 09),01,01)
       F4_DUPLIC   := Substr(U_P_CORTA(_String, "|", 10),01,01)
       F4_ESTOQUE  := Substr(U_P_CORTA(_String, "|", 11),01,01)
       F4_CF       := U_P_CORTA(_String, "|", 12)
       F4_FINALID  := U_P_CORTA(_String, "|", 13)
       F4_TEXTO    := U_P_CORTA(_String, "|", 14)
       F4_BASEICM  := VAL(STRTRAN(U_P_CORTA(_String, "|", 15),",","."))
       F4_BASEIPI  := VAL(U_P_CORTA(_String, "|", 16))
       F4_PODER3   := Substr(U_P_CORTA(_String, "|", 17),01,01)
       F4_LFICM    := Substr(U_P_CORTA(_String, "|", 18),01,01)
       F4_LFIPI    := Substr(U_P_CORTA(_String, "|", 19),01,01)
       F4_DESTACA  := Substr(U_P_CORTA(_String, "|", 20),01,01)
       F4_INCIDE   := Substr(U_P_CORTA(_String, "|", 21),01,01)
       F4_COMPL    := Substr(U_P_CORTA(_String, "|", 22),01,01)
       F4_IPIFRET  := Substr(U_P_CORTA(_String, "|", 23),01,01)
       F4_ISS      := Substr(U_P_CORTA(_String, "|", 24),01,01)
       F4_LFISS    := Substr(U_P_CORTA(_String, "|", 25),01,01)
       F4_NRLIVRO  := U_P_CORTA(_String, "|", 26)
       F4_UPRC     := Substr(U_P_CORTA(_String, "|", 27),01,01)
       F4_CONSUMO  := Substr(U_P_CORTA(_String, "|", 28),01,01)
       F4_FORMULA  := Alltrim(U_P_CORTA(_String, "|", 29))
       F4_AGREG    := Substr(U_P_CORTA(_String, "|", 30),01,01)
       F4_INCSOL   := Substr(U_P_CORTA(_String, "|", 31),01,01)
       F4_CIAP     := Substr(U_P_CORTA(_String, "|", 32),01,01)
       F4_DESPIPI  := Substr(U_P_CORTA(_String, "|", 33),01,01)
       F4_LIVRO    := Substr(U_P_CORTA(_String, "|", 34),01,01)
       F4_ATUTEC   := Substr(U_P_CORTA(_String, "|", 35),01,01)
       F4_ATUATF   := Substr(U_P_CORTA(_String, "|", 36),01,01)
       F4_TPIPI    := Substr(U_P_CORTA(_String, "|", 37),01,01)
       F4_STDESC   := "1"
       F4_BSICMST  := VAL(U_P_CORTA(_String, "|", 39))
       
       F4_CREDST   := "2"
       F4_BASEISS  := VAL(U_P_CORTA(_String, "|", 41))
       F4_DESPICM  := IIF(Substr(U_P_CORTA(_String, "|", 42),01,01) == "S", "1", "2")
       F4_SITTRIB  := U_P_CORTA(_String, "|", 43)
       
       DO CASE
          CASE Substr(U_P_CORTA(_String, "|", 44),01,01) == "P"
               F4_PISCOF := "1"
          CASE Substr(U_P_CORTA(_String, "|", 44),01,01) == "C"
               F4_PISCOF := "2"
          CASE Substr(U_P_CORTA(_String, "|", 44),01,01) == "A"
               F4_PISCOF := "3"
          CASE Substr(U_P_CORTA(_String, "|", 44),01,01) == "N"
               F4_PISCOF := "4"
       ENDCASE
       
       DO CASE
          CASE Substr(U_P_CORTA(_String, "|", 45),01,01) == "C"
               F4_PISCRED := "1"
          CASE Substr(U_P_CORTA(_String, "|", 45),01,01) == "D"
               F4_PISCRED := "2"
          CASE Substr(U_P_CORTA(_String, "|", 45),01,01) == "N"
               F4_PISCRED := "3"
       ENDCASE
       
       F4_BASEPIS := VAL(U_P_CORTA(_String, "|", 46))
       F4_TESDV   := U_P_CORTA(_String, "|", 47)
       F4_BASECOF := VAL(U_P_CORTA(_String, "|", 48))
       F4_IPLICM  := IIF(Substr(U_P_CORTA(_String, "|", 43),01,01) == "S", "1", "2")
       F4_MOVPRJ  := "1"
       F4_ICMSDIF := "2"
       F4_TESP3   := U_P_CORTA(_String, "|", 52)
       F4_QTDZERO := "2"
       F4_SLDNPT  := IIF(Substr(U_P_CORTA(_String, "|", 54),01,01) == "D", "1", "2")
       F4_DEVZERO := IIF(Substr(U_P_CORTA(_String, "|", 55),01,01) == "S", "1", "2")
       F4_MSBLQL  := IIF(Substr(U_P_CORTA(_String, "|", 56),01,01) == "S", "1", "2")               
       F4_TRFICM  := IIF(Substr(U_P_CORTA(_String, "|", 57),01,01) == "S", "1", "2")               
       F4_OBSICM  := IIF(Substr(U_P_CORTA(_String, "|", 58),01,01) == "S", "1", "2")               
       F4_OBSSOL  := ""
       F4_PICMDIF := VAL(U_P_CORTA(_String, "|", 60))
       F4_ISSST   := ""
       F4_PISFISC := ""
       F4_CONTSOC := ""
       F4_PISDSLF := IIF(Substr(U_P_CORTA(_String, "|", 65),01,01) == "S", "1", "2")               
       F4_IPIPC   := ""
       F4_CRPRST  := VAL(U_P_CORTA(_String, "|", 67))       
       F4_AGRCOF  := "2"
       F4_TPREG   := "1"
       F4_BENSATF := "2"
       F4_CTIPI   := U_P_CORTA(_String, "|", 71)
       F4_TRANFIL := IIF(Substr(U_P_CORTA(_String, "|", 72),01,01) == "S", "1", "2")               
       F4_REGDSTA := ""
       F4_COFBRUT := IIF(Substr(U_P_CORTA(_String, "|", 74),01,01) == "S", "1", "2")               
       F4_BCRDCOF := VAL(U_P_CORTA(_String, "|", 75))
       F4_ICMSST  := ""
       F4_LFICMST := IIF(Substr(U_P_CORTA(_String, "|", 77),01,01) == "S", "1", "2")               
       F4_MKPCMP  := IIF(Substr(U_P_CORTA(_String, "|", 78),01,01) == "S", "1", "2")               

       F4_RETISS  := IIF(Substr(U_P_CORTA(_String, "|", 79),01,01) == "S", "1", "2")               
       F4_AGRPIS  := "2"
       F4_FRETAUT := "1"
       F4_DSPRDIC := ""
       F4_AFRMM   := ""
       F4_CRPRELE := 0
       F4_CRDPRES := 0
       F4_COFDSZF := IIF(Substr(U_P_CORTA(_String, "|", 86),01,01) == "S", "1", "2")               
       F4_PISBRUT := IIF(Substr(U_P_CORTA(_String, "|", 87),01,01) == "S", "1", "2")
       F4_BCRDPIS := 0
       F4_CRDEST  := "1"
       F4_ANTICMS := IIF(Substr(U_P_CORTA(_String, "|", 90),01,01) == "S", "1", "2")
       F4_BENDUB  := ""
       F4_MOVFIS  := ""
       F4_CREDACU := "3"
       F4_CODDET  := ""
       F4_CRDTRAN := 0
       F4_APLIRED := ""
       F4_ATACVAR := IIF(Substr(U_P_CORTA(_String, "|", 97),01,01) == "S", "1", "2")
       F4_OPERSUC := IIF(Substr(U_P_CORTA(_String, "|", 98),01,01) == "S", "1", "2")
       F4_TIPODUB := ""
       F4_DESCOND := ""
       F4_APLIVA  := IIF(Substr(U_P_CORTA(_String, "|", 101),01,01) == "S", "1", "2")
       F4_NUMDUB  := ""
       F4_CFPS    := ""
       F4_REDANT  := 0
       F4_ESTCRED := 0
       F4_CRPRSIM := 0
       F4_BSRURAL := ""
       F4_PSCFST  := ""
       F4_IPIOBS  := IIF(Substr(U_P_CORTA(_String, "|", 109),01,01) == "S", "1", "2")
       F4_ISEFECP := ""
       F4_APLREDP := IIF(Substr(U_P_CORTA(_String, "|", 111),01,01) == "S", "1", "2")
       F4_REFATAN := ""
       F4_CROUTGO := 0
       F4_CSTCOF  := U_P_CORTA(_String, "|", 114)
       F4_BCPCST  := ""
       F4_DBSTIRR := ""
       F4_CRPREPO := 0

       F4_MKPSOL  := "2"
       F4_STCONF  := ""
       F4_DUPLIST := "2"
       F4_VLAGREG := ""
       F4_CSTPIS  := U_P_CORTA(_String, "|", 122)
       F4_CLFDSUL := ""
       F4_INTBSIC := "0"
       F4_CRPREPE := 0
       F4_CRICMS  := IIF(Substr(U_P_CORTA(_String, "|", 126),01,01) == "N", "0", "1")
       F4_TRANSIT := ""
       F4_CALCFET := ""
       F4_RGESPST := ""
       F4_PAUTICM := "1"
       F4_DBSTCSL := ""
       F4_PCREDAC := 0
       F4_CRDACUM := ""
       F4_VARATAC := ""
       F4_IVAUTIL := 0
       F4_PERCMED := 0
       F4_MOTICMS := ""
       F4_VSRDICM := ""
       F4_COP     := ""
       F4_PRZESP  := ""
       F4_ALSENAR := 0
       F4_AGREGCP := "1"
       F4_CRPRESP := 0
       F4_CPRESPR := 0
       F4_DESPPIS := ""
       F4_DESPCOF := ""
       F4_ICMSTMT := ""
       F4_CROUTSP := 0
       F4_CSOSN   := ""
       F4_ART274  := ""
       F4_CFACS   := ""
       F4_CFABOV  := ""
       F4_AJUSTE  := ""
       F4_FRETISS := ""
       F4_CRLEIT  := ""
       F4_PR35701 := 0

       F4_CODLAN  := ""
       F4_VENPRES := ""
       F4_REDBCCE := 0
       F4_CSTISS  := ""
       F4_VDASOFT := ""
       F4_CODPAG  := ""
       F4_PAGCOM  := ""
       F4_RESSARC := ""
       F4_CODBCC  := ""
       F4_INDNTFR := ""
       F4_CPPRODE := 0
       F4_TPPRODE := ""	
       F4_ISEFERN := ""
       F4_CRICMST := IIF(Substr(U_P_CORTA(_String, "|", 170),01,01) == "S", "1", "0")
       F4_REGESP  := ""
       F4_RGESPCI := ""
       F4_TABGIAI := ""
       F4_TABGIAO := ""
       F4_COMPONE := ""
       F4_CODLEG  := ""
       F4_VLRZERO := ""
       F4_TNATREC := ""
       F4_CNATREC := ""
       F4_GRPNATR := ""
//     F4_DTFIMNT := ""
       F4_CODOBSE := ""
       F4_SOMAIPI := ""
       F4_APSCFST := ""
       F4_NORESP  := ""

       MsUnLock()
       
   Next nContar        
   
   MsgAlert("Importação realizada com Sucesso.")

Return .T.