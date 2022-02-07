#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"  
#Include "json.ch"
#Include "aarray.ch"
         
// #####################################################################################
// SOLUTIO IT SOLUÇÕES CORPORATIVAS                                                   ##
// ---------------------------------------------------------------------------------- ##
// Referencia: SOLTGEROS.PRW                                                          ##
// Parâmetros: Nenhum                                                                 ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada ( ) Gatilho                         ##
// ---------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                ##
// Data......: 26/06/2019                                                             ##
// Objetivo..: Programa que realiza a importação dos arquivos GPM (OS Automáticas)    ##
// #####################################################################################

User Function SOLTGEROS()                                  
                              
   Local lChumba         := .F.
   Local cSql            := ""
                        
   Private aMyCols 	     := {}
   Private aMyHeader     := {}
   Private oBrwCpo
   Private oDlgE
   Private aAcampos      := {}
   Private cPastaDestino := GetMV("SIR_IMPO")
   Private cPastaLogErro := GetMV("SIR_PEMAL")                                                                        

   Private aAcampos  := {"Z20_CSER", "Z20_CIDA", "Z20_CSRV", "Z20_CONT", "Z20_DATA", "Z20_DCHL", "Z20_DCOM", "Z20_DFMT", "Z20_DIDS", "Z20_DISR",;
                         "Z20_DITR", "Z20_DTSR", "Z20_DCON", "Z20_DEQU", "Z20_DSRV", "Z20_EPEP", "Z20_HCHL", "Z20_HCOM", "Z20_HFIT", "Z20_HFTR",;
                         "Z20_HIDS", "Z20_HIIN", "Z20_HISR", "Z20_HITR", "Z20_HTSR", "Z20_IDCS", "Z20_IDCT", "Z20_IDEQ", "Z20_IDIN", "Z20_IDMT",;
                         "Z20_IDNT", "Z20_IDOB", "Z20_IDSR", "Z20_IDTE", "Z20_IDTS", "Z20_IDTT", "Z20_IDTV", "Z20_IDTN", "Z20_IDVE", "Z20_JUST",;
                         "Z20_KMFM", "Z20_KMIN", "Z20_LIDS", "Z20_LISR", "Z20_LOID", "Z20_LOIS", "Z20_MCOO", "Z20_MELE", "Z20_MF01", "Z20_MF02",;
                         "Z20_MF03", "Z20_MF04", "Z20_MF05", "Z20_MF06", "Z20_MPAR", "Z20_MSUP", "Z20_MPRE", "Z20_MVLR", "Z20_MOTI", "Z20_NCOO",;
                         "Z20_NELE", "Z20_NEQU", "Z20_NF01", "Z20_NF02", "Z20_NF03", "Z20_NF04", "Z20_NF05", "Z20_NF06", "Z20_NPAR", "Z20_NSUP",;
                         "Z20_NNOT", "Z20_NOBR", "Z20_NOPR", "Z20_OBSE", "Z20_OSRV", "Z20_OSIS", "Z20_PLAC", "Z20_QUAN", "Z20_RVDI", "Z20_TSR1",;
                         "Z20_TEQU", "Z20_TTUR", "Z20_TVEI", "Z20_VSRV"}	

   Private aConsulta := {}  

   Private oVerde  	 := LoadBitmap( GetResources(), "BR_VERDE")
   Private oAzul  	 := LoadBitmap( GetResources(), "BR_AZUL")
   Private oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
   Private oAmarelo	 := LoadBitmap( GetResources(), "BR_AMARELO")
          
   Private oBrwCpo          

   Private aOrdem    := {}

   Private oDlgMan
                      
   // Inicializa as teclas de funcção
   SetKey(VK_F5 , {|| MostraDetalhes()    })
   SetKey(VK_F6 , {|| MostraLogErroGrid() })
   SetKey(VK_F7 , {|| U_SOLTPAR99()       })
   SetKey(VK_F8 , {|| ArqDisponiveis()    })
   SetKey(VK_F9 , {|| mSGaLERT("Em Desenvolvimento") })
   SetKey(VK_F10, {|| kSaidaGridExcel()   })
   SetKey(VK_F11, {|| xGeraGridCSV()      })
   SetKey(VK_F12, {|| PesqImportados()    })

   SetPrvt("oFont2","oDlgE","oSay1","oSay2","oSay3","oSay4","oGet1","oGet2","oBtn1","oBrwCpo","oBtn2","oBtn3")
   SetPrvt("oGet4")

   oFont2     := TFont():New( "MS Sans Serif",0,-13,,.T.,0,,700,.F.,.F.,,,,,, )

   // Cria o cabeçalho do grid
   aAdd(aMyHeader, {"Leg"                          , "IMAGEM"   , '@BMP',   03, 00, '', , 'C', ""    }) // 001
   aAdd(aMyHeader, {"Seq"                          , "Z20_SEQU" , '!@'  ,   03, 00, '', , 'C', ""    }) // 002
   aAdd(aMyHeader, {"Grupo"                        , "Z20_GRUP" , '!@'  ,   20, 00, '', , 'C', ""    }) // 003

   // Colunas para a Tag SERVICOS
   aAdd(aMyHeader, {"ID Nota"                      , "Z20_IDNT" , '!@'  ,   20, 00, '', , 'C', ""    }) // 004
   aAdd(aMyHeader, {"Número Nota"                  , "Z20_NNOT" , '!@'  ,   20, 00, '', , 'C', ""    }) // 005
   aAdd(aMyHeader, {"ID Tipo Serviço"              , "Z20_IDTS" , '!@'  ,   20, 00, '', , 'C', ""    }) // 006
   aAdd(aMyHeader, {"Tipo Serviço"                 , "Z20_TSR1" , '!@'  ,   20, 00, '', , 'C', ""    }) // 007
   aAdd(aMyHeader, {"Origem Sistema"               , "Z20_OSIS" , '!@'  ,   20, 00, '', , 'C', ""    }) // 008
   aAdd(aMyHeader, {"Origem Serviço"               , "Z20_OSRV" , '!@'  ,   20, 00, '', , 'C', ""    }) // 009
   aAdd(aMyHeader, {"Matrícula Coordenador"        , "Z20_MCOO" , '!@'  ,   30, 00, '', , 'C', ""    }) // 010
   aAdd(aMyHeader, {"Nome Coordenador"             , "Z20_NCOO" , '!@'  ,   30, 00, '', , 'C', ""    }) // 011
   aAdd(aMyHeader, {"Matrícula Supervisor"         , "Z20_MSUP" , '!@'  ,   20, 00, '', , 'C', ""    }) // 012
   aAdd(aMyHeader, {"Nome Supervisor"              , "Z20_NSUP" , '!@'  ,   30, 00, '', , 'C', ""    }) // 013
   aAdd(aMyHeader, {"ID Equipe"                    , "Z20_IDEQ" , '!@'  ,   20, 00, '', , 'C', ""    }) // 014
   aAdd(aMyHeader, {"Nome Equipe"                  , "Z20_NEQU" , '!@'  ,   30, 00, '', , 'C', ""    }) // 015
   aAdd(aMyHeader, {"ID Tipo Equipe"               , "Z20_IDTE" , '!@'  ,   20, 00, '', , 'C', ""    }) // 016
   aAdd(aMyHeader, {"Tipo Equipe"                  , "Z20_TEQU" , '!@'  ,   20, 00, '', , 'C', ""    }) // 017
   aAdd(aMyHeader, {"Matrícula Funcionário 1"      , "Z20_MF01" , '!@'  ,   20, 00, '', , 'C', ""    }) // 018
   aAdd(aMyHeader, {"Nome Funcionário 1"           , "Z20_NF01" , '!@'  ,   30, 00, '', , 'C', ""    }) // 019
   aAdd(aMyHeader, {"Matrícula Funcionário 2"      , "Z20_MF02" , '!@'  ,   20, 00, '', , 'C', ""    }) // 020
   aAdd(aMyHeader, {"Nome Funcionário 2"           , "Z20_NF02" , '!@'  ,   30, 00, '', , 'C', ""    }) // 021
   aAdd(aMyHeader, {"Matrícula Funcionário 3"      , "Z20_MF03" , '!@'  ,   20, 00, '', , 'C', ""    }) // 022
   aAdd(aMyHeader, {"Nome Funcionário 3"           , "Z20_NF03" , '!@'  ,   30, 00, '', , 'C', ""    }) // 023
   aAdd(aMyHeader, {"Matrícula Funcionário 4"      , "Z20_MF04" , '!@'  ,   20, 00, '', , 'C', ""    }) // 024
   aAdd(aMyHeader, {"Nome Funcionário 4"           , "Z20_NF04" , '!@'  ,   30, 00, '', , 'C', ""    }) // 025
   aAdd(aMyHeader, {"Matrícula Funcionário 5"      , "Z20_MF05" , '!@'  ,   20, 00, '', , 'C', ""    }) // 026
   aAdd(aMyHeader, {"Nome Funcionário 5"           , "Z20_NF05" , '!@'  ,   30, 00, '', , 'C', ""    }) // 027
   aAdd(aMyHeader, {"Matrícula Funcionário 6"      , "Z20_MF06" , '!@'  ,   20, 00, '', , 'C', ""    }) // 028
   aAdd(aMyHeader, {"Nome Funcionário 6"           , "Z20_NF06" , '!@'  ,   30, 00, '', , 'C', ""    }) // 029
   aAdd(aMyHeader, {"IF Contrato"                  , "Z20_IDCT" , '!@'  ,   20, 00, '', , 'C', ""    }) // 030
   aAdd(aMyHeader, {"Contrato"                     , "Z20_CONT" , '!@'  ,   20, 00, '', , 'C', ""    }) // 031
   aAdd(aMyHeader, {"IF Centro Serviço"            , "Z20_IDCS" , '!@'  ,   20, 00, '', , 'C', ""    }) // 032
   aAdd(aMyHeader, {"Centro Serviço"               , "Z20_CSER" , '!@'  ,   30, 00, '', , 'C', ""    }) // 033
   aAdd(aMyHeader, {"IF Veículo"                   , "Z20_IDVE" , '!@'  ,   20, 00, '', , 'C', ""    }) // 034
   aAdd(aMyHeader, {"Placa Veículo"                , "Z20_PLAC" , '!@'  ,   10, 00, '', , 'C', ""    }) // 035
   aAdd(aMyHeader, {"IF Tipo Veículo"              , "Z20_IDTV" , '!@'  ,   20, 00, '', , 'C', ""    }) // 036
   aAdd(aMyHeader, {"Tipo Veículo"                 , "Z20_TVEI" , '!@'  ,   20, 00, '', , 'C', ""    }) // 037
   aAdd(aMyHeader, {"KM Inicial"                   , "Z20_KMIN" , '!@'  ,   10, 00, '', , 'C', ""    }) // 038
   aAdd(aMyHeader, {"KM Final"                     , "Z20_KMFM" , '!@'  ,   10, 00, '', , 'C', ""    }) // 039
   aAdd(aMyHeader, {"IF Serviço"                   , "Z20_IDSR" , '!@'  ,   20, 00, '', , 'C', ""    }) // 040
   aAdd(aMyHeader, {"Código Serviço"               , "Z20_CSRV" , '!@'  ,   30, 00, '', , 'C', ""    }) // 041
   aAdd(aMyHeader, {"Descrição Serviço"            , "Z20_DSRV" , '!@'  ,   30, 00, '', , 'C', ""    }) // 042
   aAdd(aMyHeader, {"Quantidade"                   , "Z20_QUAN" , '!@'  ,   15, 00, '', , 'C', ""    }) // 043
   aAdd(aMyHeader, {"Valor Total Serviço"          , "Z20_VSRV" , '!@'  ,   15, 00, '', , 'C', ""    }) // 044
   aAdd(aMyHeader, {"Data Comunicação"             , "Z20_DCOM" , '!@'  ,   10, 00, '', , 'C', ""    }) // 045
   aAdd(aMyHeader, {"Hora Comunicação"             , "Z20_HCOM" , '!@'  ,   10, 00, '', , 'C', ""    }) // 046
   aAdd(aMyHeader, {"Data Início Deslocamento"     , "Z20_DIDS" , '!@'  ,   10, 00, '', , 'C', ""    }) // 047
   aAdd(aMyHeader, {"Hora Início Deslocamento"     , "Z20_HIDS" , '!@'  ,   10, 00, '', , 'C', ""    }) // 048
   aAdd(aMyHeader, {"Data Chegada Local"           , "Z20_DCHL" , '!@'  ,   10, 00, '', , 'C', ""    }) // 049
   aAdd(aMyHeader, {"Hora Chegada Local"           , "Z20_HCHL" , '!@'  ,   10, 00, '', , 'C', ""    }) // 050
   aAdd(aMyHeader, {"Data Início Serviço"          , "Z20_DISR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 051
   aAdd(aMyHeader, {"Hora Início Serviço"          , "Z20_HISR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 052
   aAdd(aMyHeader, {"Data Término Serviço"         , "Z20_DTSR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 053
   aAdd(aMyHeader, {"Hora Término Serviço"         , "Z20_HTSR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 054
   aAdd(aMyHeader, {"Latitude Início Deslocamento" , "Z20_LIDS" , '!@'  ,   15, 00, '', , 'C', ""    }) // 055
   aAdd(aMyHeader, {"Longitude Início Deslocamento", "Z20_LOID" , '!@'  ,   15, 00, '', , 'C', ""    }) // 056
   aAdd(aMyHeader, {"Latitude Início Serviço"      , "Z20_LISR" , '!@'  ,   15, 00, '', , 'C', ""    }) // 057
   aAdd(aMyHeader, {"Longitude Início Serviço"     , "Z20_LOIS" , '!@'  ,   15, 00, '', , 'C', ""    }) // 058
   aAdd(aMyHeader, {"ID Obra"                      , "Z20_IDOB" , '!@'  ,   20, 00, '', , 'C', ""    }) // 059
   aAdd(aMyHeader, {"E PEP"                        , "Z20_EPEP" , '!@'  ,   20, 00, '', , 'C', ""    }) // 060
   aAdd(aMyHeader, {"Número Obra Principal"        , "Z20_NOPR" , '!@'  ,   20, 00, '', , 'C', ""    }) // 061
   aAdd(aMyHeader, {"Cidade"                       , "Z20_CIDA" , '!@'  ,   30, 00, '', , 'C', ""    }) // 062
   aAdd(aMyHeader, {"Observação"                   , "Z20_OBSE" , '!@'  ,  250, 00, '', , 'C', ""    }) // 063
   aAdd(aMyHeader, {"Tipo de Serviço"              , "Z20_TSR1" , '!@'  ,   20, 00, '', , 'C', ""    }) // 064
   aAdd(aMyHeader, {"Data Início Turno"            , "Z20_DITR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 065
   aAdd(aMyHeader, {"Hora Início Turno"            , "Z20_HITR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 066
   aAdd(aMyHeader, {"Data Fim Turno"               , "Z20_DFMT" , '!@'  ,   10, 00, '', , 'C', ""    }) // 067
   aAdd(aMyHeader, {"Hora Fim Turno"               , "Z20_HFTR" , '!@'  ,   10, 00, '', , 'C', ""    }) // 068

   // Colunas para a Tag METAS                                                    
   aAdd(aMyHeader, {"Data"                         , "Z20_DATA" , '!@'  ,   10, 00, '', , 'C', ""    }) // 069
   aAdd(aMyHeader, {"Matrícula Eletricista"        , "Z20_MELE" , '!@'  ,   20, 00, '', , 'C', ""    }) // 070
   aAdd(aMyHeader, {"Nome Eletricista"             , "Z20_NELE" , '!@'  ,   30, 00, '', , 'C', ""    }) // 071
   aAdd(aMyHeader, {"matrícula Parceiro"           , "Z20_MPAR" , '!@'  ,   20, 00, '', , 'C', ""    }) // 072
   aAdd(aMyHeader, {"Nome Parceiro"                , "Z20_NPAR" , '!@'  ,   30, 00, '', , 'C', ""    }) // 073
   aAdd(aMyHeader, {"Meta Valor Dia"               , "Z20_MVLR" , '!@'  ,   15, 00, '', , 'C', ""    }) // 074
   aAdd(aMyHeader, {"Realizado Valor Dia"          , "Z20_RVDI" , '!@'  ,   15, 00, '', , 'C', ""    }) // 075
   aAdd(aMyHeader, {"Justificativa"                , "Z20_JUST" , '!@'  ,  250, 00, '', , 'C', ""    }) // 076
   aAdd(aMyHeader, {"ID Turno"                     , "Z20_IDTN" , '!@'  ,   20, 00, '', , 'C', ""    }) // 077
   aAdd(aMyHeader, {"ID Tipo Turno"                , "Z20_IDTT" , '!@'  ,   20, 00, '', , 'C', ""    }) // 078
   aAdd(aMyHeader, {"Tipo Turno"                   , "Z20_TTUR" , '!@'  ,   20, 00, '', , 'C', ""    }) // 079

   // Colunas para a Tag INTERVALOS
   aAdd(aMyHeader, {"IF Intervalo"                 , "Z20_IDIN" , '!@'  ,   20, 00, '', , 'C', ""    }) // 080
   aAdd(aMyHeader, {"ID Motivo"                    , "Z20_IDMT" , '!@'  ,   20, 00, '', , 'C', ""    }) // 081
   aAdd(aMyHeader, {"Motivo"                       , "Z20_MOTI" , '!@'  ,  250, 00, '', , 'C', ""    }) // 082
   aAdd(aMyHeader, {"Hora Início Intervalo"        , "Z20_HIIN" , '!@'  ,   10, 00, '', , 'C', ""    }) // 083
   aAdd(aMyHeader, {"Hora Fim Intervalo"           , "Z20_HFIT" , '!@'  ,   10, 00, '', , 'C', ""    }) // 084
   
   // Colunas para a Tag METAS PREVISTA
   aAdd(aMyHeader, {"Descrição do Contrato"        , "Z20_DCON"  , '!@'  ,   30, 00, '', , 'C', ""    }) // 085
   aAdd(aMyHeader, {"Descrição da Equipe"          , "Z20_DEQU"  , '!@'  ,   30, 00, '', , 'C', ""    }) // 086
   aAdd(aMyHeader, {"Meta Prevista"                , "Z20_MPRE"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 087
   
   // Colunas para a Tag OBRAS
   aAdd(aMyHeader, {"Status"                       , "Z20_STATUS", '!@'  ,   20, 00, '', , 'C', ""    }) // 088
   aAdd(aMyHeader, {"Número Obra"                  , "Z20_NOBR"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 089
   aAdd(aMyHeader, {"Descrição da Obra"            , "Z20_DOBR"  , '!@'  ,   60, 00, '', , 'C', ""    }) // 090
   aAdd(aMyHeader, {"Regional"                     , "Z20_REGI"  , '!@'  ,   30, 00, '', , 'C', ""    }) // 091
   aAdd(aMyHeader, {"Responsavel"                  , "Z20_RESP"  , '!@'  ,   60, 00, '', , 'C', ""    }) // 092
   aAdd(aMyHeader, {"Data de Recebimento"          , "Z20_DREC"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 093
   aAdd(aMyHeader, {"Início Execução Obra"         , "Z20_IEXE"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 094
   aAdd(aMyHeader, {"Fim Execução Obra"            , "Z20_FEXE"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 095
   aAdd(aMyHeader, {"Início Previsão da Obra"      , "Z20_IPOB"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 096
   aAdd(aMyHeader, {"Fim Previsão da Obra"         , "Z20_FPOB"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 097
   aAdd(aMyHeader, {"Data Energização"             , "Z20_DENE"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 098
   aAdd(aMyHeader, {"Data Protocolo Faturamento"   , "Z20_DPFA"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 098
   aAdd(aMyHeader, {"Data UF"                      , "Z20_DTUF"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 100
   aAdd(aMyHeader, {"Valor Previsão"               , "Z20_VPRE"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 101
   aAdd(aMyHeader, {"Valor Real"                   , "Z20_VREA"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 102
   aAdd(aMyHeader, {"Valor Pago"                   , "Z20_VPAG"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 103
   aAdd(aMyHeader, {"Qtd Postes Previstos"         , "Z20_QPOP"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 104
   aAdd(aMyHeader, {"Qtd Postes"                   , "Z20_QPOS"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 105
   aAdd(aMyHeader, {"Código Obra"                  , "Z20_COBR"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 106
   aAdd(aMyHeader, {"Tipo de Obra"                 , "Z20_TPOB"  , '!@'  ,   30, 00, '', , 'C', ""    }) // 107
   aAdd(aMyHeader, {"Supervisor"                   , "Z20_SUPE"  , '!@'  ,   60, 00, '', , 'C', ""    }) // 108
   aAdd(aMyHeader, {"Número Pedido"                , "Z20_NPED"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 109
   aAdd(aMyHeader, {"Data Pedido"                  , "Z20_DPED"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 110
   aAdd(aMyHeader, {"Latitude"                     , "Z20_LATE"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 111
   aAdd(aMyHeader, {"Longitude"                    , "Z20_LONG"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 112
   aAdd(aMyHeader, {"Fiscal Concessionaria"        , "Z20_FCON"  , '!@'  ,   60, 00, '', , 'C', ""    }) // 113
   aAdd(aMyHeader, {"Nota Fiscal"                  , "Z20_NFIS"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 114
   aAdd(aMyHeader, {"Data Documento"               , "Z20_DNOT"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 115
   aAdd(aMyHeader, {"Vistoria Realizada"           , "Z20_VIST"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 116
   aAdd(aMyHeader, {"Tipo de Serviço"              , "Z20_TSR2"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 117
   aAdd(aMyHeader, {"Código Estoque"               , "Z20_CSTQ"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 118

   // Colunas para a Tag OBRAS ATIVIDADES
   aAdd(aMyHeader, {"Código Precificação"          , "Z20_CPRE"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 119 
   aAdd(aMyHeader, {"Descrição Precificação"       , "Z20_DPRE"  , '!@'  ,   60, 00, '', , 'C', ""    }) // 120
   aAdd(aMyHeader, {"Unidade"                      , "Z20_UNID"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 121
                                                                                                                   
   // Colunas para a Tag OBRAS MATERIAIS
   aAdd(aMyHeader, {"Material"                     , "Z20_MATE"  , '!@'  ,   60, 00, '', , 'C', ""    }) // 122 
   aAdd(aMyHeader, {"Situacao"                     , "Z20_SITU"  , '!@'  ,   30, 00, '', , 'C', ""    }) // 123
   aAdd(aMyHeader, {"Orçado Concessionaria"        , "Z20_ORCA"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 124
   aAdd(aMyHeader, {"orçado Validado"              , "Z20_ORCV"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 125
   aAdd(aMyHeader, {"Processada"                   , "Z20_PROC"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 126
   aAdd(aMyHeader, {"A Separar"                    , "Z20_ASEP"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 127
   aAdd(aMyHeader, {"Aplicada"                     , "Z20_APLI"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 128
   aAdd(aMyHeader, {"Devolver"                     , "Z20_ADEV"  , '!@'  ,   15, 00, '', , 'C', ""    }) // 129
   aAdd(aMyHeader, {"Usuário"                      , "Z20_CODU"  , '!@'  ,   30, 00, '', , 'C', ""    }) // 130

   // Colunas de Identificação do arquivo importado
   aAdd(aMyHeader, {"Data Importação"              , "Z20_CODU"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 131
   aAdd(aMyHeader, {"Hora Importação"              , "Z20_CODU"  , '!@'  ,   10, 00, '', , 'C', ""    }) // 132
   aAdd(aMyHeader, {"Usuário"                      , "Z20_CODU"  , '!@'  ,   20, 00, '', , 'C', ""    }) // 133
   aAdd(aMyHeader, {"Nº Ordem Serviço"             , "Z20_CODU"  , '!@'  ,   06, 00, '', , 'C', ""    }) // 134
   aAdd(aMyHeader, {"Arquivo Importado"            , "Z20_CODU"  , '!@'  ,  250, 00, '', , 'C', ""    }) // 135

   // Verifica se o diretório de destino existe. Se não existir, cria-o
   If !ExistDir( cPastaDestino )

      nRet := MakeDir( cPastaDestino )
   
      If nRet != 0
         MsgAlert("Atenção!"                                                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Não foi possível ser criada a pasta de gravação de Arquivos Importados (" + cPastaDestino + " )" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Verifique!")
         Return(.T.)
      Endif
   
   Endif   

   // Verifica se o diretório de destino existe. Se não existir, cria-o
   If !ExistDir( cPastaLogErro )

      nRet := MakeDir( cPastaLogErro )
   
      If nRet != 0
         MsgAlert("Atenção!"                                                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Não foi possível ser criada a pasta de gravação de Log de Inconsistências (" + cPastaLogErro + " )" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Verifique!")
         Return(.T.)
      Endif
   
   Endif   

   // Abre a tela para visualização dos dados convertidos
   DEFINE MSDIALOG oDlgMan TITLE "Importação Ordens de Serviços - GPM" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(003),C(005) Say "Relação de Importações Inconsistentes"            Size C(150),C(008) COLOR CLR_BLACK PIXEL OF oDlgMan

   @ C(210),C(010) Button "F5 - Detalhe"     Size C(037),C(012) PIXEL OF oDlgMan ACTION( MostraDetalhes() )
   @ C(210),C(049) Button "F6 - LOG"         Size C(037),C(012) PIXEL OF oDlgMan ACTION( MostraLogErroGrid() )
   @ C(210),C(088) Button "F7 - Parâmetros"  Size C(037),C(012) PIXEL OF oDlgMan ACTION( U_SOLTPAR99() )
   @ C(210),C(127) Button "F8 - Importar"    Size C(037),C(012) PIXEL OF oDlgMan ACTION( ArqDisponiveis() )
   @ C(210),C(166) Button "F9 - Reprocessar" Size C(037),C(012) PIXEL OF oDlgMan ACTION( ReprocessaGPM() )
   @ C(210),C(205) Button "F10 - Exp. Excel" Size C(037),C(012) PIXEL OF oDlgMan ACTION( kSaidaGridExcel() )
   @ C(210),C(244) Button "F11 - Exp CSV"    Size C(037),C(012) PIXEL OF oDlgMan ACTION( xGeraGridCSV() )
   @ C(210),C(283) Button "F12 - Importados" Size C(037),C(012) PIXEL OF oDlgMan ACTION( PesqImportados() )
   @ C(210),C(322) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlgMan ACTION( SetKey(VK_F5 , {||}),;
                                                                                       SetKey(VK_F6 , {||}),;
                                                                                       SetKey(VK_F7 , {||}),;
                                                                                       SetKey(VK_F8 , {||}),;
                                                                                       SetKey(VK_F9 , {||}),;
                                                                                       SetKey(VK_F10, {||}),;
                                                                                       SetKey(VK_F11, {||}),;
                                                                                       SetKey(VK_F12, {||}), oDlgMan:End() )

   // Envia para a função que carrega os dados do grid com registros que apresentem inconsistências
   CargaDoGridResultado(0)

   // Monta o grid para edição
   oBrwCpo := MsNewGetDados():New(013,005,263,637, GD_INSERT+GD_DELETE+GD_UPDATE,'AllwaysTrue()','AllwaysTrue()','',aACampos,0,999,'AllwaysTrue()','','AllwaysTrue()',oDlgE,aMyHeader,aMyCols )
        
   // Carrega o Array aCols
   For nLocalizar = 1 to Len(aConsulta)
       
       oBrwCpo:aCols[nLocalizar,001] := aConsulta[nLocalizar,001]
       oBrwCpo:aCols[nLocalizar,002] := aConsulta[nLocalizar,002]
       oBrwCpo:aCols[nLocalizar,003] := aConsulta[nLocalizar,003]
       oBrwCpo:aCols[nLocalizar,004] := aConsulta[nLocalizar,004]
       oBrwCpo:aCols[nLocalizar,005] := aConsulta[nLocalizar,005]
       oBrwCpo:aCols[nLocalizar,006] := aConsulta[nLocalizar,006]
       oBrwCpo:aCols[nLocalizar,007] := aConsulta[nLocalizar,007]
       oBrwCpo:aCols[nLocalizar,008] := aConsulta[nLocalizar,008]
       oBrwCpo:aCols[nLocalizar,009] := aConsulta[nLocalizar,009]
       oBrwCpo:aCols[nLocalizar,010] := aConsulta[nLocalizar,010]
       oBrwCpo:aCols[nLocalizar,011] := aConsulta[nLocalizar,011]
       oBrwCpo:aCols[nLocalizar,012] := aConsulta[nLocalizar,012]
       oBrwCpo:aCols[nLocalizar,013] := aConsulta[nLocalizar,013]
       oBrwCpo:aCols[nLocalizar,014] := aConsulta[nLocalizar,014]
       oBrwCpo:aCols[nLocalizar,015] := aConsulta[nLocalizar,015]
       oBrwCpo:aCols[nLocalizar,016] := aConsulta[nLocalizar,016]
       oBrwCpo:aCols[nLocalizar,017] := aConsulta[nLocalizar,017]
       oBrwCpo:aCols[nLocalizar,018] := aConsulta[nLocalizar,018]
       oBrwCpo:aCols[nLocalizar,019] := aConsulta[nLocalizar,019]
       oBrwCpo:aCols[nLocalizar,020] := aConsulta[nLocalizar,020]
       oBrwCpo:aCols[nLocalizar,021] := aConsulta[nLocalizar,021]
       oBrwCpo:aCols[nLocalizar,022] := aConsulta[nLocalizar,022]
       oBrwCpo:aCols[nLocalizar,023] := aConsulta[nLocalizar,023]
       oBrwCpo:aCols[nLocalizar,024] := aConsulta[nLocalizar,024]
       oBrwCpo:aCols[nLocalizar,025] := aConsulta[nLocalizar,025]
       oBrwCpo:aCols[nLocalizar,026] := aConsulta[nLocalizar,026]
       oBrwCpo:aCols[nLocalizar,027] := aConsulta[nLocalizar,027]
       oBrwCpo:aCols[nLocalizar,028] := aConsulta[nLocalizar,028]
       oBrwCpo:aCols[nLocalizar,029] := aConsulta[nLocalizar,029]
       oBrwCpo:aCols[nLocalizar,030] := aConsulta[nLocalizar,030]
       oBrwCpo:aCols[nLocalizar,031] := aConsulta[nLocalizar,031]
       oBrwCpo:aCols[nLocalizar,032] := aConsulta[nLocalizar,032]
       oBrwCpo:aCols[nLocalizar,033] := aConsulta[nLocalizar,033]
       oBrwCpo:aCols[nLocalizar,034] := aConsulta[nLocalizar,034]
       oBrwCpo:aCols[nLocalizar,035] := aConsulta[nLocalizar,035]
       oBrwCpo:aCols[nLocalizar,036] := aConsulta[nLocalizar,036]
       oBrwCpo:aCols[nLocalizar,037] := aConsulta[nLocalizar,037]
       oBrwCpo:aCols[nLocalizar,038] := aConsulta[nLocalizar,038]
       oBrwCpo:aCols[nLocalizar,039] := aConsulta[nLocalizar,039]
       oBrwCpo:aCols[nLocalizar,040] := aConsulta[nLocalizar,040]
       oBrwCpo:aCols[nLocalizar,041] := aConsulta[nLocalizar,041]
       oBrwCpo:aCols[nLocalizar,042] := aConsulta[nLocalizar,042]
       oBrwCpo:aCols[nLocalizar,043] := aConsulta[nLocalizar,043]
       oBrwCpo:aCols[nLocalizar,044] := aConsulta[nLocalizar,044]
       oBrwCpo:aCols[nLocalizar,045] := aConsulta[nLocalizar,045]
       oBrwCpo:aCols[nLocalizar,046] := aConsulta[nLocalizar,046]
       oBrwCpo:aCols[nLocalizar,047] := aConsulta[nLocalizar,047]
       oBrwCpo:aCols[nLocalizar,048] := aConsulta[nLocalizar,048]
       oBrwCpo:aCols[nLocalizar,049] := aConsulta[nLocalizar,049]
       oBrwCpo:aCols[nLocalizar,050] := aConsulta[nLocalizar,050]
       oBrwCpo:aCols[nLocalizar,051] := aConsulta[nLocalizar,051]
       oBrwCpo:aCols[nLocalizar,052] := aConsulta[nLocalizar,052]
       oBrwCpo:aCols[nLocalizar,053] := aConsulta[nLocalizar,053]
       oBrwCpo:aCols[nLocalizar,054] := aConsulta[nLocalizar,054]
       oBrwCpo:aCols[nLocalizar,055] := aConsulta[nLocalizar,055]
       oBrwCpo:aCols[nLocalizar,056] := aConsulta[nLocalizar,056]
       oBrwCpo:aCols[nLocalizar,057] := aConsulta[nLocalizar,057]
       oBrwCpo:aCols[nLocalizar,058] := aConsulta[nLocalizar,058]
       oBrwCpo:aCols[nLocalizar,059] := aConsulta[nLocalizar,059]
       oBrwCpo:aCols[nLocalizar,060] := aConsulta[nLocalizar,060]
       oBrwCpo:aCols[nLocalizar,061] := aConsulta[nLocalizar,061]
       oBrwCpo:aCols[nLocalizar,062] := aConsulta[nLocalizar,062]
       oBrwCpo:aCols[nLocalizar,063] := aConsulta[nLocalizar,063]
       oBrwCpo:aCols[nLocalizar,064] := aConsulta[nLocalizar,064]
       oBrwCpo:aCols[nLocalizar,065] := aConsulta[nLocalizar,065]
       oBrwCpo:aCols[nLocalizar,066] := aConsulta[nLocalizar,066]
       oBrwCpo:aCols[nLocalizar,067] := aConsulta[nLocalizar,067]
       oBrwCpo:aCols[nLocalizar,068] := aConsulta[nLocalizar,068]
       oBrwCpo:aCols[nLocalizar,069] := aConsulta[nLocalizar,069]
       oBrwCpo:aCols[nLocalizar,070] := aConsulta[nLocalizar,070]
       oBrwCpo:aCols[nLocalizar,071] := aConsulta[nLocalizar,071]
       oBrwCpo:aCols[nLocalizar,072] := aConsulta[nLocalizar,072]
       oBrwCpo:aCols[nLocalizar,073] := aConsulta[nLocalizar,073]
       oBrwCpo:aCols[nLocalizar,074] := aConsulta[nLocalizar,074]
       oBrwCpo:aCols[nLocalizar,075] := aConsulta[nLocalizar,075]
       oBrwCpo:aCols[nLocalizar,076] := aConsulta[nLocalizar,076]
       oBrwCpo:aCols[nLocalizar,077] := aConsulta[nLocalizar,077]
       oBrwCpo:aCols[nLocalizar,078] := aConsulta[nLocalizar,078]
       oBrwCpo:aCols[nLocalizar,079] := aConsulta[nLocalizar,077]
       oBrwCpo:aCols[nLocalizar,080] := aConsulta[nLocalizar,080]
       oBrwCpo:aCols[nLocalizar,081] := aConsulta[nLocalizar,081]
       oBrwCpo:aCols[nLocalizar,082] := aConsulta[nLocalizar,082]
       oBrwCpo:aCols[nLocalizar,083] := aConsulta[nLocalizar,083]
       oBrwCpo:aCols[nLocalizar,084] := aConsulta[nLocalizar,084]
       oBrwCpo:aCols[nLocalizar,085] := aConsulta[nLocalizar,085]
       oBrwCpo:aCols[nLocalizar,086] := aConsulta[nLocalizar,086]
       oBrwCpo:aCols[nLocalizar,087] := aConsulta[nLocalizar,087]
       oBrwCpo:aCols[nLocalizar,088] := aConsulta[nLocalizar,088]
       oBrwCpo:aCols[nLocalizar,089] := aConsulta[nLocalizar,089]
       oBrwCpo:aCols[nLocalizar,090] := aConsulta[nLocalizar,090]
       oBrwCpo:aCols[nLocalizar,091] := aConsulta[nLocalizar,091]
       oBrwCpo:aCols[nLocalizar,092] := aConsulta[nLocalizar,092]
       oBrwCpo:aCols[nLocalizar,093] := aConsulta[nLocalizar,093]
       oBrwCpo:aCols[nLocalizar,094] := aConsulta[nLocalizar,094]
       oBrwCpo:aCols[nLocalizar,095] := aConsulta[nLocalizar,095]
       oBrwCpo:aCols[nLocalizar,096] := aConsulta[nLocalizar,096]
       oBrwCpo:aCols[nLocalizar,097] := aConsulta[nLocalizar,097]
       oBrwCpo:aCols[nLocalizar,098] := aConsulta[nLocalizar,098]
       oBrwCpo:aCols[nLocalizar,099] := aConsulta[nLocalizar,099]
       oBrwCpo:aCols[nLocalizar,100] := aConsulta[nLocalizar,100]
       oBrwCpo:aCols[nLocalizar,101] := aConsulta[nLocalizar,101]
       oBrwCpo:aCols[nLocalizar,102] := aConsulta[nLocalizar,102]
       oBrwCpo:aCols[nLocalizar,103] := aConsulta[nLocalizar,103]
       oBrwCpo:aCols[nLocalizar,104] := aConsulta[nLocalizar,104]
       oBrwCpo:aCols[nLocalizar,105] := aConsulta[nLocalizar,105]
       oBrwCpo:aCols[nLocalizar,106] := aConsulta[nLocalizar,106]
       oBrwCpo:aCols[nLocalizar,107] := aConsulta[nLocalizar,107]
       oBrwCpo:aCols[nLocalizar,108] := aConsulta[nLocalizar,108]
       oBrwCpo:aCols[nLocalizar,109] := aConsulta[nLocalizar,109]
       oBrwCpo:aCols[nLocalizar,110] := aConsulta[nLocalizar,110]
       oBrwCpo:aCols[nLocalizar,111] := aConsulta[nLocalizar,111]
       oBrwCpo:aCols[nLocalizar,112] := aConsulta[nLocalizar,112]
       oBrwCpo:aCols[nLocalizar,113] := aConsulta[nLocalizar,113]
       oBrwCpo:aCols[nLocalizar,114] := aConsulta[nLocalizar,114]
       oBrwCpo:aCols[nLocalizar,115] := aConsulta[nLocalizar,115]
       oBrwCpo:aCols[nLocalizar,116] := aConsulta[nLocalizar,116]
       oBrwCpo:aCols[nLocalizar,117] := aConsulta[nLocalizar,117]
       oBrwCpo:aCols[nLocalizar,118] := aConsulta[nLocalizar,118]
       oBrwCpo:aCols[nLocalizar,119] := aConsulta[nLocalizar,119]
       oBrwCpo:aCols[nLocalizar,120] := aConsulta[nLocalizar,120]
       oBrwCpo:aCols[nLocalizar,121] := aConsulta[nLocalizar,121]
       oBrwCpo:aCols[nLocalizar,122] := aConsulta[nLocalizar,122]
       oBrwCpo:aCols[nLocalizar,123] := aConsulta[nLocalizar,123]
       oBrwCpo:aCols[nLocalizar,124] := aConsulta[nLocalizar,124]
       oBrwCpo:aCols[nLocalizar,125] := aConsulta[nLocalizar,125]
       oBrwCpo:aCols[nLocalizar,126] := aConsulta[nLocalizar,126]
       oBrwCpo:aCols[nLocalizar,127] := aConsulta[nLocalizar,127]
       oBrwCpo:aCols[nLocalizar,128] := aConsulta[nLocalizar,128]
       oBrwCpo:aCols[nLocalizar,129] := aConsulta[nLocalizar,129]
       oBrwCpo:aCols[nLocalizar,130] := aConsulta[nLocalizar,130]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,131]
       oBrwCpo:aCols[nLocalizar,132] := aConsulta[nLocalizar,132]
       oBrwCpo:aCols[nLocalizar,133] := aConsulta[nLocalizar,133]
       oBrwCpo:aCols[nLocalizar,134] := aConsulta[nLocalizar,134]
       oBrwCpo:aCols[nLocalizar,135] := aConsulta[nLocalizar,135]

   Next nLozalizar

   ACTIVATE MSDIALOG oDlgMan CENTERED 

Return(.T.)

// Função que carrega o grid com registros com inconsistências na importação
Static Function CargaDoGridResultado(kTipo)

   Local cSql := ""

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql:= ""
   cSql := "SELECT Z20_SEQU  , Z20_GRUP  , Z20_IDNT  , Z20_NNOT  , Z20_IDTS  , Z20_TSR1  , Z20_OSIS  , Z20_OSRV  , Z20_MCOO  , Z20_NCOO  ," 
   cSql += "       Z20_MSUP  , Z20_NSUP  , Z20_IDEQ  , Z20_NEQU  , Z20_IDTE  , Z20_TEQU  , Z20_MF01  , Z20_NF01  , Z20_MF02  , Z20_NF02  ," 
   cSql += "       Z20_MF03  , Z20_NF03  , Z20_MF04  , Z20_NF04  , Z20_MF05  , Z20_NF05  , Z20_MF06  , Z20_NF06  , Z20_IDCT  , Z20_CONT  ," 
   cSql += "       Z20_IDCS  , Z20_CSER  , Z20_IDVE  , Z20_PLAC  , Z20_IDTV  , Z20_TVEI  , Z20_KMIN  , Z20_KMFM  , Z20_IDSR  , Z20_CSRV  ," 
   cSql += "       Z20_DSRV  , Z20_QUAN  , Z20_VSRV  , Z20_DCOM  , Z20_HCOM  , Z20_DIDS  , Z20_HIDS  , Z20_DCHL  , Z20_HCHL  , Z20_DISR  ," 
   cSql += "       Z20_HISR  , Z20_DTSR  , Z20_HTSR  , Z20_LIDS  , Z20_LOID  , Z20_LISR  , Z20_LOIS  , Z20_IDOB  , Z20_EPEP  , Z20_NOPR  ," 
   cSql += "       Z20_CIDA  , Z20_OBSE  , Z20_TSR1  , Z20_DITR  , Z20_HITR  , Z20_DFMT  , Z20_HFTR  , Z20_DATA  , Z20_MELE  , Z20_NELE  ," 
   cSql += "       Z20_MPAR  , Z20_NPAR  , Z20_MVLR  , Z20_RVDI  , Z20_JUST  , Z20_IDTN  , Z20_IDTT  , Z20_TTUR  , Z20_IDIN  , Z20_IDMT  ," 
   cSql += "       Z20_MOTI  , Z20_HIIN  , Z20_HFIT  , Z20_DCON  , Z20_DEQU  , Z20_MPRE  , Z20_STATUS, Z20_NOBR  , Z20_DOBR  , Z20_REGI  ,"  
   cSql += "       Z20_RESP  , Z20_DREC  , Z20_IEXE  , Z20_FEXE  , Z20_IPOB  , Z20_FPOB  , Z20_DENE  , Z20_DPFA  , Z20_DTUF  , Z20_VPRE  ,"  
   cSql += "       Z20_VREA  , Z20_VPAG  , Z20_QPOP  , Z20_QPOS  , Z20_COBR  , Z20_TPOB  , Z20_SUPE  , Z20_NPED  , Z20_DPED  , Z20_LATE  ,"  
   cSql += "       Z20_LONG  , Z20_FCON  , Z20_NFIS  , Z20_DNOT  , Z20_VIST  , Z20_TSR2  , Z20_CSTQ  , Z20_CPRE  , Z20_DPRE  , Z20_UNID  ,"  
   cSql += "       Z20_MATE  , Z20_SITU  , Z20_ORCA  , Z20_ORCV  , Z20_PROC  , Z20_ASEP  , Z20_APLI  , Z20_ADEV  , Z20_CODU  , Z20_DIMP  ,"
   cSql += "       Z20_HIMP  , Z20_USUA  , Z20_NROS  , Z20_ARQU  ,"  
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), Z20_LOGE)) AS LOGERRO"   
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND Z20_GRUP  <> '' "
   cSql += "   AND (Z20_STATUS = '1'"
   cSql += "    OR Z20_NROS    = '')"          
   cSql += " ORDER BY Z20_FILIAL, Z20_ARQU, Z20_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
              
   aMycols   := {}
   aConsulta := {}   

   T_CONSULTA->( DbGoTop() )
   
  WHILE !T_CONSULTA->( EOF() )

        kk_Legenda := IIF(T_CONSULTA->Z20_STATUS == "0", oVerde, oVermelho) 
 
        aAdd( aMycols,  {  kk_Legenda            ,; // 001
                           T_CONSULTA->Z20_SEQU  ,; // 002
                           T_CONSULTA->Z20_GRUP  ,; // 003
                           T_CONSULTA->Z20_IDNT  ,; // 004   
                           T_CONSULTA->Z20_NNOT  ,; // 005
                           T_CONSULTA->Z20_IDTS  ,; // 006
                           T_CONSULTA->Z20_TSR1  ,; // 007
                           T_CONSULTA->Z20_OSIS  ,; // 008
                           T_CONSULTA->Z20_OSRV  ,; // 009
                           T_CONSULTA->Z20_MCOO  ,; // 010
                           T_CONSULTA->Z20_NCOO  ,; // 011
                           T_CONSULTA->Z20_MSUP  ,; // 012
                           T_CONSULTA->Z20_NSUP  ,; // 013
                           T_CONSULTA->Z20_IDEQ  ,; // 014
                           T_CONSULTA->Z20_NEQU  ,; // 015
                           T_CONSULTA->Z20_IDTE  ,; // 016
                           T_CONSULTA->Z20_TEQU  ,; // 017
                           T_CONSULTA->Z20_MF01  ,; // 018
                           T_CONSULTA->Z20_NF01  ,; // 019
                           T_CONSULTA->Z20_MF02  ,; // 020
                           T_CONSULTA->Z20_NF02  ,; // 021
                           T_CONSULTA->Z20_MF03  ,; // 022
                           T_CONSULTA->Z20_NF03  ,; // 023
                           T_CONSULTA->Z20_MF04  ,; // 024
                           T_CONSULTA->Z20_NF04  ,; // 025
                           T_CONSULTA->Z20_MF05  ,; // 026
                           T_CONSULTA->Z20_NF05  ,; // 027
                           T_CONSULTA->Z20_MF06  ,; // 028
                           T_CONSULTA->Z20_NF06  ,; // 029
                           T_CONSULTA->Z20_IDCT  ,; // 030
                           T_CONSULTA->Z20_CONT  ,; // 031
                           T_CONSULTA->Z20_IDCS  ,; // 032
                           T_CONSULTA->Z20_CSER  ,; // 033
                           T_CONSULTA->Z20_IDVE  ,; // 034
                           T_CONSULTA->Z20_PLAC  ,; // 035
                           T_CONSULTA->Z20_IDTV  ,; // 036
                           T_CONSULTA->Z20_TVEI  ,; // 037
                           T_CONSULTA->Z20_KMIN  ,; // 038
                           T_CONSULTA->Z20_KMFM  ,; // 039
                           T_CONSULTA->Z20_IDSR  ,; // 040
                           T_CONSULTA->Z20_CSRV  ,; // 041
                           T_CONSULTA->Z20_DSRV  ,; // 042
                           T_CONSULTA->Z20_QUAN  ,; // 043
                           T_CONSULTA->Z20_VSRV  ,; // 044
                           T_CONSULTA->Z20_DCOM  ,; // 045
                           T_CONSULTA->Z20_HCOM  ,; // 046
                           T_CONSULTA->Z20_DIDS  ,; // 047
                           T_CONSULTA->Z20_HIDS  ,; // 048
                           T_CONSULTA->Z20_DCHL  ,; // 049
                           T_CONSULTA->Z20_HCHL  ,; // 050
                           T_CONSULTA->Z20_DISR  ,; // 051
                           T_CONSULTA->Z20_HISR  ,; // 052
                           T_CONSULTA->Z20_DTSR  ,; // 053
                           T_CONSULTA->Z20_HTSR  ,; // 054
                           T_CONSULTA->Z20_LIDS  ,; // 055
                           T_CONSULTA->Z20_LOID  ,; // 056
                           T_CONSULTA->Z20_LISR  ,; // 057
                           T_CONSULTA->Z20_LOIS  ,; // 058
                           T_CONSULTA->Z20_IDOB  ,; // 059
                           T_CONSULTA->Z20_EPEP  ,; // 060
                           T_CONSULTA->Z20_NOPR  ,; // 061
                           T_CONSULTA->Z20_CIDA  ,; // 062
                           T_CONSULTA->Z20_OBSE  ,; // 063
                           T_CONSULTA->Z20_TSR1  ,; // 064
                           T_CONSULTA->Z20_DITR  ,; // 065
                           T_CONSULTA->Z20_HITR  ,; // 066
                           T_CONSULTA->Z20_DFMT  ,; // 067
                           T_CONSULTA->Z20_HFTR  ,; // 068
                           T_CONSULTA->Z20_DATA  ,; // 069
                           T_CONSULTA->Z20_MELE  ,; // 070
                           T_CONSULTA->Z20_NELE  ,; // 071
                           T_CONSULTA->Z20_MPAR  ,; // 072
                           T_CONSULTA->Z20_NPAR  ,; // 073
                           T_CONSULTA->Z20_MVLR  ,; // 074
                           T_CONSULTA->Z20_RVDI  ,; // 075
                           T_CONSULTA->Z20_JUST  ,; // 076
                           T_CONSULTA->Z20_IDTN  ,; // 077
                           T_CONSULTA->Z20_IDTT  ,; // 078
                           T_CONSULTA->Z20_TTUR  ,; // 079
                           T_CONSULTA->Z20_IDIN  ,; // 080
                           T_CONSULTA->Z20_IDMT  ,; // 081
                           T_CONSULTA->Z20_MOTI  ,; // 082
                           T_CONSULTA->Z20_HIIN  ,; // 083
                           T_CONSULTA->Z20_HFIT  ,; // 084
                           T_CONSULTA->Z20_DCON  ,; // 085
                           T_CONSULTA->Z20_DEQU  ,; // 086
                           T_CONSULTA->Z20_MPRE  ,; // 087
                           T_CONSULTA->Z20_STATUS,; // 088
                           T_CONSULTA->Z20_NOBR  ,; // 089
                           T_CONSULTA->Z20_DOBR  ,; // 090
                           T_CONSULTA->Z20_REGI  ,; // 091
                           T_CONSULTA->Z20_RESP  ,; // 092
                           T_CONSULTA->Z20_DREC  ,; // 093
                           T_CONSULTA->Z20_IEXE  ,; // 094
                           T_CONSULTA->Z20_FEXE  ,; // 095
                           T_CONSULTA->Z20_IPOB  ,; // 096
                           T_CONSULTA->Z20_FPOB  ,; // 097
                           T_CONSULTA->Z20_DENE  ,; // 098
                           T_CONSULTA->Z20_DPFA  ,; // 099
                           T_CONSULTA->Z20_DTUF  ,; // 100
                           T_CONSULTA->Z20_VPRE  ,; // 101
                           T_CONSULTA->Z20_VREA  ,; // 102
                           T_CONSULTA->Z20_VPAG  ,; // 103
                           T_CONSULTA->Z20_QPOP  ,; // 104
                           T_CONSULTA->Z20_QPOS  ,; // 105
                           T_CONSULTA->Z20_COBR  ,; // 106
                           T_CONSULTA->Z20_TPOB  ,; // 107
                           T_CONSULTA->Z20_SUPE  ,; // 108
                           T_CONSULTA->Z20_NPED  ,; // 109
                           T_CONSULTA->Z20_DPED  ,; // 110
                           T_CONSULTA->Z20_LATE  ,; // 111
                           T_CONSULTA->Z20_LONG  ,; // 112
                           T_CONSULTA->Z20_FCON  ,; // 113
                           T_CONSULTA->Z20_NFIS  ,; // 114
                           T_CONSULTA->Z20_DNOT  ,; // 115
                           T_CONSULTA->Z20_VIST  ,; // 116
                           T_CONSULTA->Z20_TSR2  ,; // 117
                           T_CONSULTA->Z20_CSTQ  ,; // 118
                           T_CONSULTA->Z20_CPRE  ,; // 119
                           T_CONSULTA->Z20_DPRE  ,; // 120
                           T_CONSULTA->Z20_UNID  ,; // 121
                           T_CONSULTA->Z20_MATE  ,; // 122
                           T_CONSULTA->Z20_SITU  ,; // 123
                           T_CONSULTA->Z20_ORCA  ,; // 124
                           T_CONSULTA->Z20_ORCV  ,; // 125
                           T_CONSULTA->Z20_PROC  ,; // 126
                           T_CONSULTA->Z20_ASEP  ,; // 127
                           T_CONSULTA->Z20_APLI  ,; // 128
                           T_CONSULTA->Z20_ADEV  ,; // 129
                           T_CONSULTA->Z20_CODU  ,; // 130 
                           T_CONSULTA->Z20_DIMP  ,; // 131
                           T_CONSULTA->Z20_HIMP  ,; // 132
                           T_CONSULTA->Z20_USUA  ,; // 133
                           T_CONSULTA->Z20_NROS  ,; // 134
                           T_CONSULTA->Z20_ARQU  ,; // 135
                           .F.                   }) // 136
                           
        aAdd( aConsulta,{  kk_Legenda            ,; // 001
                           T_CONSULTA->Z20_SEQU  ,; // 002
                           T_CONSULTA->Z20_GRUP  ,; // 003
                           T_CONSULTA->Z20_IDNT  ,; // 004   
                           T_CONSULTA->Z20_NNOT  ,; // 005
                           T_CONSULTA->Z20_IDTS  ,; // 006
                           T_CONSULTA->Z20_TSR1  ,; // 007
                           T_CONSULTA->Z20_OSIS  ,; // 008
                           T_CONSULTA->Z20_OSRV  ,; // 009
                           T_CONSULTA->Z20_MCOO  ,; // 010
                           T_CONSULTA->Z20_NCOO  ,; // 011
                           T_CONSULTA->Z20_MSUP  ,; // 012
                           T_CONSULTA->Z20_NSUP  ,; // 013
                           T_CONSULTA->Z20_IDEQ  ,; // 014
                           T_CONSULTA->Z20_NEQU  ,; // 015
                           T_CONSULTA->Z20_IDTE  ,; // 016
                           T_CONSULTA->Z20_TEQU  ,; // 017
                           T_CONSULTA->Z20_MF01  ,; // 018
                           T_CONSULTA->Z20_NF01  ,; // 019
                           T_CONSULTA->Z20_MF02  ,; // 020
                           T_CONSULTA->Z20_NF02  ,; // 021
                           T_CONSULTA->Z20_MF03  ,; // 022
                           T_CONSULTA->Z20_NF03  ,; // 023
                           T_CONSULTA->Z20_MF04  ,; // 024
                           T_CONSULTA->Z20_NF04  ,; // 025
                           T_CONSULTA->Z20_MF05  ,; // 026
                           T_CONSULTA->Z20_NF05  ,; // 027
                           T_CONSULTA->Z20_MF06  ,; // 028
                           T_CONSULTA->Z20_NF06  ,; // 029
                           T_CONSULTA->Z20_IDCT  ,; // 030
                           T_CONSULTA->Z20_CONT  ,; // 031
                           T_CONSULTA->Z20_IDCS  ,; // 032
                           T_CONSULTA->Z20_CSER  ,; // 033
                           T_CONSULTA->Z20_IDVE  ,; // 034
                           T_CONSULTA->Z20_PLAC  ,; // 035
                           T_CONSULTA->Z20_IDTV  ,; // 036
                           T_CONSULTA->Z20_TVEI  ,; // 037
                           T_CONSULTA->Z20_KMIN  ,; // 038
                           T_CONSULTA->Z20_KMFM  ,; // 039
                           T_CONSULTA->Z20_IDSR  ,; // 040
                           T_CONSULTA->Z20_CSRV  ,; // 041
                           T_CONSULTA->Z20_DSRV  ,; // 042
                           T_CONSULTA->Z20_QUAN  ,; // 043
                           T_CONSULTA->Z20_VSRV  ,; // 044
                           T_CONSULTA->Z20_DCOM  ,; // 045
                           T_CONSULTA->Z20_HCOM  ,; // 046
                           T_CONSULTA->Z20_DIDS  ,; // 047
                           T_CONSULTA->Z20_HIDS  ,; // 048
                           T_CONSULTA->Z20_DCHL  ,; // 049
                           T_CONSULTA->Z20_HCHL  ,; // 050
                           T_CONSULTA->Z20_DISR  ,; // 051
                           T_CONSULTA->Z20_HISR  ,; // 052
                           T_CONSULTA->Z20_DTSR  ,; // 053
                           T_CONSULTA->Z20_HTSR  ,; // 054
                           T_CONSULTA->Z20_LIDS  ,; // 055
                           T_CONSULTA->Z20_LOID  ,; // 056
                           T_CONSULTA->Z20_LISR  ,; // 057
                           T_CONSULTA->Z20_LOIS  ,; // 058
                           T_CONSULTA->Z20_IDOB  ,; // 059
                           T_CONSULTA->Z20_EPEP  ,; // 060
                           T_CONSULTA->Z20_NOPR  ,; // 061
                           T_CONSULTA->Z20_CIDA  ,; // 062
                           T_CONSULTA->Z20_OBSE  ,; // 063
                           T_CONSULTA->Z20_TSR1  ,; // 064
                           T_CONSULTA->Z20_DITR  ,; // 065
                           T_CONSULTA->Z20_HITR  ,; // 066
                           T_CONSULTA->Z20_DFMT  ,; // 067
                           T_CONSULTA->Z20_HFTR  ,; // 068
                           T_CONSULTA->Z20_DATA  ,; // 069
                           T_CONSULTA->Z20_MELE  ,; // 070
                           T_CONSULTA->Z20_NELE  ,; // 071
                           T_CONSULTA->Z20_MPAR  ,; // 072
                           T_CONSULTA->Z20_NPAR  ,; // 073
                           T_CONSULTA->Z20_MVLR  ,; // 074
                           T_CONSULTA->Z20_RVDI  ,; // 075
                           T_CONSULTA->Z20_JUST  ,; // 076
                           T_CONSULTA->Z20_IDTN  ,; // 077
                           T_CONSULTA->Z20_IDTT  ,; // 078
                           T_CONSULTA->Z20_TTUR  ,; // 079
                           T_CONSULTA->Z20_IDIN  ,; // 080
                           T_CONSULTA->Z20_IDMT  ,; // 081
                           T_CONSULTA->Z20_MOTI  ,; // 082
                           T_CONSULTA->Z20_HIIN  ,; // 083
                           T_CONSULTA->Z20_HFIT  ,; // 084
                           T_CONSULTA->Z20_DCON  ,; // 085
                           T_CONSULTA->Z20_DEQU  ,; // 086
                           T_CONSULTA->Z20_MPRE  ,; // 087
                           T_CONSULTA->Z20_STATUS,; // 088
                           T_CONSULTA->Z20_NOBR  ,; // 089
                           T_CONSULTA->Z20_DOBR  ,; // 090
                           T_CONSULTA->Z20_REGI  ,; // 091
                           T_CONSULTA->Z20_RESP  ,; // 092
                           T_CONSULTA->Z20_DREC  ,; // 093
                           T_CONSULTA->Z20_IEXE  ,; // 094
                           T_CONSULTA->Z20_FEXE  ,; // 095
                           T_CONSULTA->Z20_IPOB  ,; // 096
                           T_CONSULTA->Z20_FPOB  ,; // 097
                           T_CONSULTA->Z20_DENE  ,; // 098
                           T_CONSULTA->Z20_DPFA  ,; // 099
                           T_CONSULTA->Z20_DTUF  ,; // 100
                           T_CONSULTA->Z20_VPRE  ,; // 101
                           T_CONSULTA->Z20_VREA  ,; // 102
                           T_CONSULTA->Z20_VPAG  ,; // 103
                           T_CONSULTA->Z20_QPOP  ,; // 104
                           T_CONSULTA->Z20_QPOS  ,; // 105
                           T_CONSULTA->Z20_COBR  ,; // 106
                           T_CONSULTA->Z20_TPOB  ,; // 107
                           T_CONSULTA->Z20_SUPE  ,; // 108
                           T_CONSULTA->Z20_NPED  ,; // 109
                           T_CONSULTA->Z20_DPED  ,; // 110
                           T_CONSULTA->Z20_LATE  ,; // 111
                           T_CONSULTA->Z20_LONG  ,; // 112
                           T_CONSULTA->Z20_FCON  ,; // 113
                           T_CONSULTA->Z20_NFIS  ,; // 114
                           T_CONSULTA->Z20_DNOT  ,; // 115
                           T_CONSULTA->Z20_VIST  ,; // 116
                           T_CONSULTA->Z20_TSR2  ,; // 117
                           T_CONSULTA->Z20_CSTQ  ,; // 118
                           T_CONSULTA->Z20_CPRE  ,; // 119
                           T_CONSULTA->Z20_DPRE  ,; // 120
                           T_CONSULTA->Z20_UNID  ,; // 121
                           T_CONSULTA->Z20_MATE  ,; // 122
                           T_CONSULTA->Z20_SITU  ,; // 123
                           T_CONSULTA->Z20_ORCA  ,; // 124
                           T_CONSULTA->Z20_ORCV  ,; // 125
                           T_CONSULTA->Z20_PROC  ,; // 126
                           T_CONSULTA->Z20_ASEP  ,; // 127
                           T_CONSULTA->Z20_APLI  ,; // 128
                           T_CONSULTA->Z20_ADEV  ,; // 129
                           T_CONSULTA->Z20_CODU  ,; // 130
                           T_CONSULTA->Z20_DIMP  ,; // 131
                           T_CONSULTA->Z20_HIMP  ,; // 132
                           T_CONSULTA->Z20_USUA  ,; // 133
                           T_CONSULTA->Z20_NROS  ,; // 134
                           T_CONSULTA->Z20_ARQU  ,; // 135
                           .F.                   }) // 136

      T_CONSULTA->( DbSkip() )

   Enddo

   If kTipo == 0
      Return(.T.)
   Endif   
   
   // Carrega o Array aCols
   For nLocalizar = 1 to Len(aConsulta)
       
       oBrwCpo:aCols[nLocalizar,001] := aConsulta[nLocalizar,001]
       oBrwCpo:aCols[nLocalizar,002] := aConsulta[nLocalizar,002]
       oBrwCpo:aCols[nLocalizar,003] := aConsulta[nLocalizar,003]
       oBrwCpo:aCols[nLocalizar,004] := aConsulta[nLocalizar,004]
       oBrwCpo:aCols[nLocalizar,005] := aConsulta[nLocalizar,005]
       oBrwCpo:aCols[nLocalizar,006] := aConsulta[nLocalizar,006]
       oBrwCpo:aCols[nLocalizar,007] := aConsulta[nLocalizar,007]
       oBrwCpo:aCols[nLocalizar,008] := aConsulta[nLocalizar,008]
       oBrwCpo:aCols[nLocalizar,009] := aConsulta[nLocalizar,009]
       oBrwCpo:aCols[nLocalizar,010] := aConsulta[nLocalizar,010]
       oBrwCpo:aCols[nLocalizar,011] := aConsulta[nLocalizar,011]
       oBrwCpo:aCols[nLocalizar,012] := aConsulta[nLocalizar,012]
       oBrwCpo:aCols[nLocalizar,013] := aConsulta[nLocalizar,013]
       oBrwCpo:aCols[nLocalizar,014] := aConsulta[nLocalizar,014]
       oBrwCpo:aCols[nLocalizar,015] := aConsulta[nLocalizar,015]
       oBrwCpo:aCols[nLocalizar,016] := aConsulta[nLocalizar,016]
       oBrwCpo:aCols[nLocalizar,017] := aConsulta[nLocalizar,017]
       oBrwCpo:aCols[nLocalizar,018] := aConsulta[nLocalizar,018]
       oBrwCpo:aCols[nLocalizar,019] := aConsulta[nLocalizar,019]
       oBrwCpo:aCols[nLocalizar,020] := aConsulta[nLocalizar,020]
       oBrwCpo:aCols[nLocalizar,021] := aConsulta[nLocalizar,021]
       oBrwCpo:aCols[nLocalizar,022] := aConsulta[nLocalizar,022]
       oBrwCpo:aCols[nLocalizar,023] := aConsulta[nLocalizar,023]
       oBrwCpo:aCols[nLocalizar,024] := aConsulta[nLocalizar,024]
       oBrwCpo:aCols[nLocalizar,025] := aConsulta[nLocalizar,025]
       oBrwCpo:aCols[nLocalizar,026] := aConsulta[nLocalizar,026]
       oBrwCpo:aCols[nLocalizar,027] := aConsulta[nLocalizar,027]
       oBrwCpo:aCols[nLocalizar,028] := aConsulta[nLocalizar,028]
       oBrwCpo:aCols[nLocalizar,029] := aConsulta[nLocalizar,029]
       oBrwCpo:aCols[nLocalizar,030] := aConsulta[nLocalizar,030]
       oBrwCpo:aCols[nLocalizar,031] := aConsulta[nLocalizar,031]
       oBrwCpo:aCols[nLocalizar,032] := aConsulta[nLocalizar,032]
       oBrwCpo:aCols[nLocalizar,033] := aConsulta[nLocalizar,033]
       oBrwCpo:aCols[nLocalizar,034] := aConsulta[nLocalizar,034]
       oBrwCpo:aCols[nLocalizar,035] := aConsulta[nLocalizar,035]
       oBrwCpo:aCols[nLocalizar,036] := aConsulta[nLocalizar,036]
       oBrwCpo:aCols[nLocalizar,037] := aConsulta[nLocalizar,037]
       oBrwCpo:aCols[nLocalizar,038] := aConsulta[nLocalizar,038]
       oBrwCpo:aCols[nLocalizar,039] := aConsulta[nLocalizar,039]
       oBrwCpo:aCols[nLocalizar,040] := aConsulta[nLocalizar,040]
       oBrwCpo:aCols[nLocalizar,041] := aConsulta[nLocalizar,041]
       oBrwCpo:aCols[nLocalizar,042] := aConsulta[nLocalizar,042]
       oBrwCpo:aCols[nLocalizar,043] := aConsulta[nLocalizar,043]
       oBrwCpo:aCols[nLocalizar,044] := aConsulta[nLocalizar,044]
       oBrwCpo:aCols[nLocalizar,045] := aConsulta[nLocalizar,045]
       oBrwCpo:aCols[nLocalizar,046] := aConsulta[nLocalizar,046]
       oBrwCpo:aCols[nLocalizar,047] := aConsulta[nLocalizar,047]
       oBrwCpo:aCols[nLocalizar,048] := aConsulta[nLocalizar,048]
       oBrwCpo:aCols[nLocalizar,049] := aConsulta[nLocalizar,049]
       oBrwCpo:aCols[nLocalizar,050] := aConsulta[nLocalizar,050]
       oBrwCpo:aCols[nLocalizar,051] := aConsulta[nLocalizar,051]
       oBrwCpo:aCols[nLocalizar,052] := aConsulta[nLocalizar,052]
       oBrwCpo:aCols[nLocalizar,053] := aConsulta[nLocalizar,053]
       oBrwCpo:aCols[nLocalizar,054] := aConsulta[nLocalizar,054]
       oBrwCpo:aCols[nLocalizar,055] := aConsulta[nLocalizar,055]
       oBrwCpo:aCols[nLocalizar,056] := aConsulta[nLocalizar,056]
       oBrwCpo:aCols[nLocalizar,057] := aConsulta[nLocalizar,057]
       oBrwCpo:aCols[nLocalizar,058] := aConsulta[nLocalizar,058]
       oBrwCpo:aCols[nLocalizar,059] := aConsulta[nLocalizar,059]
       oBrwCpo:aCols[nLocalizar,060] := aConsulta[nLocalizar,060]
       oBrwCpo:aCols[nLocalizar,061] := aConsulta[nLocalizar,061]
       oBrwCpo:aCols[nLocalizar,062] := aConsulta[nLocalizar,062]
       oBrwCpo:aCols[nLocalizar,063] := aConsulta[nLocalizar,063]
       oBrwCpo:aCols[nLocalizar,064] := aConsulta[nLocalizar,064]
       oBrwCpo:aCols[nLocalizar,065] := aConsulta[nLocalizar,065]
       oBrwCpo:aCols[nLocalizar,066] := aConsulta[nLocalizar,066]
       oBrwCpo:aCols[nLocalizar,067] := aConsulta[nLocalizar,067]
       oBrwCpo:aCols[nLocalizar,068] := aConsulta[nLocalizar,068]
       oBrwCpo:aCols[nLocalizar,069] := aConsulta[nLocalizar,069]
       oBrwCpo:aCols[nLocalizar,070] := aConsulta[nLocalizar,070]
       oBrwCpo:aCols[nLocalizar,071] := aConsulta[nLocalizar,071]
       oBrwCpo:aCols[nLocalizar,072] := aConsulta[nLocalizar,072]
       oBrwCpo:aCols[nLocalizar,073] := aConsulta[nLocalizar,073]
       oBrwCpo:aCols[nLocalizar,074] := aConsulta[nLocalizar,074]
       oBrwCpo:aCols[nLocalizar,075] := aConsulta[nLocalizar,075]
       oBrwCpo:aCols[nLocalizar,076] := aConsulta[nLocalizar,076]
       oBrwCpo:aCols[nLocalizar,077] := aConsulta[nLocalizar,077]
       oBrwCpo:aCols[nLocalizar,078] := aConsulta[nLocalizar,078]
       oBrwCpo:aCols[nLocalizar,079] := aConsulta[nLocalizar,077]
       oBrwCpo:aCols[nLocalizar,080] := aConsulta[nLocalizar,080]
       oBrwCpo:aCols[nLocalizar,081] := aConsulta[nLocalizar,081]
       oBrwCpo:aCols[nLocalizar,082] := aConsulta[nLocalizar,082]
       oBrwCpo:aCols[nLocalizar,083] := aConsulta[nLocalizar,083]
       oBrwCpo:aCols[nLocalizar,084] := aConsulta[nLocalizar,084]
       oBrwCpo:aCols[nLocalizar,085] := aConsulta[nLocalizar,085]
       oBrwCpo:aCols[nLocalizar,086] := aConsulta[nLocalizar,086]
       oBrwCpo:aCols[nLocalizar,087] := aConsulta[nLocalizar,087]
       oBrwCpo:aCols[nLocalizar,088] := aConsulta[nLocalizar,088]
       oBrwCpo:aCols[nLocalizar,089] := aConsulta[nLocalizar,089]
       oBrwCpo:aCols[nLocalizar,090] := aConsulta[nLocalizar,090]
       oBrwCpo:aCols[nLocalizar,091] := aConsulta[nLocalizar,091]
       oBrwCpo:aCols[nLocalizar,092] := aConsulta[nLocalizar,092]
       oBrwCpo:aCols[nLocalizar,093] := aConsulta[nLocalizar,093]
       oBrwCpo:aCols[nLocalizar,094] := aConsulta[nLocalizar,094]
       oBrwCpo:aCols[nLocalizar,095] := aConsulta[nLocalizar,095]
       oBrwCpo:aCols[nLocalizar,096] := aConsulta[nLocalizar,096]
       oBrwCpo:aCols[nLocalizar,097] := aConsulta[nLocalizar,097]
       oBrwCpo:aCols[nLocalizar,098] := aConsulta[nLocalizar,098]
       oBrwCpo:aCols[nLocalizar,099] := aConsulta[nLocalizar,099]
       oBrwCpo:aCols[nLocalizar,100] := aConsulta[nLocalizar,100]
       oBrwCpo:aCols[nLocalizar,101] := aConsulta[nLocalizar,101]
       oBrwCpo:aCols[nLocalizar,102] := aConsulta[nLocalizar,102]
       oBrwCpo:aCols[nLocalizar,103] := aConsulta[nLocalizar,103]
       oBrwCpo:aCols[nLocalizar,104] := aConsulta[nLocalizar,104]
       oBrwCpo:aCols[nLocalizar,105] := aConsulta[nLocalizar,105]
       oBrwCpo:aCols[nLocalizar,106] := aConsulta[nLocalizar,106]
       oBrwCpo:aCols[nLocalizar,107] := aConsulta[nLocalizar,107]
       oBrwCpo:aCols[nLocalizar,108] := aConsulta[nLocalizar,108]
       oBrwCpo:aCols[nLocalizar,109] := aConsulta[nLocalizar,109]
       oBrwCpo:aCols[nLocalizar,110] := aConsulta[nLocalizar,110]
       oBrwCpo:aCols[nLocalizar,111] := aConsulta[nLocalizar,111]
       oBrwCpo:aCols[nLocalizar,112] := aConsulta[nLocalizar,112]
       oBrwCpo:aCols[nLocalizar,113] := aConsulta[nLocalizar,112]
       oBrwCpo:aCols[nLocalizar,114] := aConsulta[nLocalizar,114]
       oBrwCpo:aCols[nLocalizar,115] := aConsulta[nLocalizar,115]
       oBrwCpo:aCols[nLocalizar,116] := aConsulta[nLocalizar,116]
       oBrwCpo:aCols[nLocalizar,117] := aConsulta[nLocalizar,117]
       oBrwCpo:aCols[nLocalizar,118] := aConsulta[nLocalizar,118]
       oBrwCpo:aCols[nLocalizar,119] := aConsulta[nLocalizar,119]
       oBrwCpo:aCols[nLocalizar,120] := aConsulta[nLocalizar,120]
       oBrwCpo:aCols[nLocalizar,121] := aConsulta[nLocalizar,121]
       oBrwCpo:aCols[nLocalizar,122] := aConsulta[nLocalizar,122]
       oBrwCpo:aCols[nLocalizar,123] := aConsulta[nLocalizar,123]
       oBrwCpo:aCols[nLocalizar,124] := aConsulta[nLocalizar,124]
       oBrwCpo:aCols[nLocalizar,125] := aConsulta[nLocalizar,125]
       oBrwCpo:aCols[nLocalizar,126] := aConsulta[nLocalizar,126]               
       oBrwCpo:aCols[nLocalizar,127] := aConsulta[nLocalizar,127]
       oBrwCpo:aCols[nLocalizar,128] := aConsulta[nLocalizar,128]
       oBrwCpo:aCols[nLocalizar,129] := aConsulta[nLocalizar,129]
       oBrwCpo:aCols[nLocalizar,130] := aConsulta[nLocalizar,130]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,131]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,132]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,133]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,134]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,135]
       oBrwCpo:aCols[nLocalizar,131] := aConsulta[nLocalizar,136]

   Next nLozalizar

   oBrwCpo:Refresh()

Return(.T.)

// Função que mostra o log de erro para o registro selecionado
Static Function MostraLogErroGrid()

   Local lChumba    := .F.
   Local kSequencia := oBrwCpo:aCols[oBrwCpo:nAt,002]
   Local kGrupo     := oBrwCpo:aCols[oBrwCpo:nAt,003]
   Local kArquivo   := oBrwCpo:aCols[oBrwCpo:nAt,135]
   Local kLogErro   := ""
   Local oGet1
   Local oGet2
   Local oGet3
   Local oMemo1

   Private oFont16cb  := TFont():New( "Courier New",,16,,.f.,,,,.f.,.f. )

   Private oDlgLog

   If Empty(Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,002]))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro selecionado para visualização de log de inconsistências.")
      Return(.T.)
   Endif

   // Carrega o log de erro para display
   If Select("T_CARGALOG") > 0
      T_CARGALOG->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), Z20_LOGE)) AS LOGERRO"   
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND Z20_STATUS  = '1'"
   cSql += "   AND Z20_SEQU    = '" + Alltrim(kSequencia) + "'"
   cSql += "   AND Z20_GRUP    = '" + Alltrim(kGrupo)     + "'"
   cSql += "   AND Z20_ARQU    = '" + Alltrim(kArquivo)   + "'"
   cSql += " ORDER BY Z20_FILIAL, Z20_ARQU, Z20_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CARGALOG", .T., .T. )

   kLogErro := Strtran(T_CARGALOG->LOGERRO, "|", chr(13) + chr(10))

   DEFINE MSDIALOG oDlgLog TITLE "Importação Arquivos GPM - Geração de OS" FROM C(178),C(181) TO C(624),C(806) PIXEL

   @ C(001),C(005) Say "Sequencia"                               Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgLog
   @ C(001),C(036) Say "Grupo"                                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgLog
   @ C(001),C(101) Say "Arquivo"                                 Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgLog
   @ C(023),C(005) Say "Inconsistência encontrada na importação" Size C(102),C(008) COLOR CLR_BLACK PIXEL OF oDlgLog

   @ C(010),C(005) MsGet oGet1  Var kSequencia Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLog When lChumba
   @ C(010),C(036) MsGet oGet2  Var kGrupo     Size C(059),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLog When lChumba
   @ C(010),C(101) MsGet oGet3  Var kArquivo   Size C(207),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgLog When lChumba

   @ C(032),C(005) GET   oMemo1 Var kLogErro   MEMO Size C(303),C(168) Font oFont16cb PIXEL OF oDlgLog When lChumba

   @ C(204),C(138) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLog ACTION( oDlgLog:End() )

   ACTIVATE MSDIALOG oDlgLog CENTERED 

Return(.T.)

// Função que mostra os arquivos disponíveis para importação
Static Function ArqDisponiveis()

   Local cMensagem    := ""

   Private lEditar    := .F.
   Private cDiretorio := GetMV("SIR_AIMP")
   Private cDestino   := GetMV("SIR_IMPO")
   Private oGet1

   Private oDlg

   Private aLista := {}
   Private oLista

   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )
                                           
   // Envia para a função que carrega o array aLista com os arquivos conforme parâmetros
   CarregaListaDir(0)

   // Desenha a tela para seleção de arquivos a serem importados
   DEFINE MSDIALOG oDlg TITLE "Importação Arquivos GPM - Geração de OS" FROM C(178),C(181) TO C(613),C(582) PIXEL

   @ C(005),C(005) Say "Arquivos disponíveis para Importação"                 Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(175),C(005) Say "Diretório de leitura dos arquivos a serem importados" Size C(124),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(200),C(017) Say "A Importar"                                           Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(200),C(059) Say "Já Importados"                                        Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(201),C(005) Jpeg FILE "br_verde.png"      Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(201),C(047) Jpeg FILE "br_vermelho.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(185),C(005) MsGet oGet1 Var cDiretorio Size C(192),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lEditar

   @ C(199),C(120) Button "Importar"          Size C(037),C(012) PIXEL OF oDlg ACTION( ImportaGPM() )            
   @ C(199),C(159) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )
                  
   // Lista com os arquivos dispníveis no diretório parametrizado a serem importados
   @ 015,005 LISTBOX oLista FIELDS HEADER "Mrc", "Leg", "Arquivos" PIXEL SIZE 250,205 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "X", oCancel  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, "")))))))))),;                         
                        aLista[oLista:nAt,03]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o array aLista com os arquivos a serem importados
Static Function CarregaListaDir(kTipo)

   Local aFile   := {}
   Local nContar := 0
   
   // Limpa o array para receber novos resultados
   aLista := {}

   // Carrega o array com os arquivos disponpiveis para importação
   aFiles := Directory(Alltrim(cDiretorio) + "\*.Json*")

   // Carrega o arrya aLista com os arquivos pesquisados
   For nContar = 1 to Len(aFiles)

       // Verifica se o arquivo já foi importado para carrega a Legenda a ser apresentada
       If Select("T_JAIMPORTADO") > 0
          T_JAIMPORTADO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT Z20_ARQU"
       cSql += "  FROM " + RetSqlName("Z20")
       cSql += " WHERE Z20_ARQU   = '" + Alltrim(aFiles[nContar,1]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"
 
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAIMPORTADO", .T., .T. )

       cLegenda := IIF(T_JAIMPORTADO->( EOF() ), "2", "8")                                  

       aAdd( aLista, { .F., cLegenda, aFiles[nContar,1] })

   Next nContar
   
   If Len(aLista) == 0
      aAdd( aLista, { .F., "1", "" } )                                                 
   Endif

   If kTipo == 0
      Return(.T.)
   Endif
      
   oLista:SetArray( aLista )

   oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo),;
                        If(Alltrim(aLista[oLista:nAt,02]) == "1", oBranco  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "2", oVerde   ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "3", oPink    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "4", oAmarelo ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "5", oAzul    ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "6", oLaranja ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "7", oPreto   ,;                         
                        If(Alltrim(aLista[oLista:nAt,02]) == "8", oVermelho,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "X", oCancel  ,;
                        If(Alltrim(aLista[oLista:nAt,02]) == "9", oEncerra, "")))))))))),;                         
                        aLista[oLista:nAt,03]}}

Return(.T.)

// Função que salva a variável SIR_AIMP com a informação digitada
Static Function SalvaGetMV()

   If Empty(Alltrim(cDiretorio))
      MsgAlert("Necessário informar o diretório para pesquisa dos arquivos a serem importados.")
      Return(.T.)
   Endif
   
   // Grava o novo conteúdo na variável
   DbSelectArea("SX6") 
   If DbSeek(xFilial("SX6") + "SIR_AIMP") 
      RecLock("SX6",.F.) 
      replace X6_CONTEUD with cDiretorio
      replace X6_CONTENG with cDiretorio
      replace X6_CONTSPA with cDiretorio
      MsUnLock()        
   Endif
                                        
   // Desabilita a digitação
   lEditar := .F.

   // Carrega novamente a lista 
   CarregaListaDir(1)
   
Return(.T.)   
                                                    
// Função que importa o arquivo selecionado
Static Function ImportaGPM()

   MsgRun("Aguarde! Importando arquivo selecionado ...", "Importação Json GPM",{|| xImportaGPM() })
       
Return(.T.)
       
// Função que importa o arquivo selecionado
Static Function xImportaGPM()

   Local lChumba     := .F. 
   Local cMemo1      := ""
   Local nContar     := 0
   Local nMarcados   := 0
   Local cRet        := ""
   Local cSPatch     := ""
   Local cSDestino   := ""
   Local cArqMarcado := ""
   Local aChave      := {}
   Local aConsulta   := {}
   Local cLegenda    := ""
   Local cMensagem   := ""
   Local aLeitura    := {}
   Local aChavePesq  := {}
   Local nPosicao    := 0

   local oObjJson    := nil
   
   Private cArqImportacao  := ""

   Private _oJson

   Private aServicos   := {}
   Private aMetas      := {}
   Private aIntervalos := {}
   Private aMetasPrev  := {}
   Private aObras      := {}
   Private aObrasAtivi := {}
   Private aObrasMater := {}

   // Verifica se usuário marcou mais do que um arquivo. Permitir um arquivo de cada vez
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          cArqMarcado := Alltrim(aLista[nContar,03]) 
          cLegenda    := Alltrim(aLista[nContar,02])
          nMarcados   := nMarcados + 1
       Endif
   Next nContar
   
   // Verifica se nenhum arquivo foi selecionado
   If nMarcados == 0
      MsgAlert("Atenção!"                                           + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Nenhum arquivo foi selecionado para ser importado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif
          
   // Verifica se foi marcado mais do que um arquivo
   If nMarcados > 1
      MsgAlert("Atenção!"                                                  + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Marque somente um arquivo de cada vez para ser importado." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif                  
   
   // Verifica a legenda do registro selecionado. Se for legenda vermelha, não permite realizar a importação
   If cLegenda == "8"
      MsgAlert("Atenção!"                                                        + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Arquivo selecionado já foi importado. Importação não permitida." + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Verifique!")
      Return(.T.)
   Endif                  

   // Elabora o caminho do arquivo para leitura
   cSPatch        := Alltrim(cDiretorio) + "\" + Alltrim(cArqMarcado)
   cSDestino      := Alltrim(cDestino)   + "\" + Alltrim(cArqMarcado)
   cArqImportacao := Alltrim(cArqMarcado)

   aConsulta := {}

   // Abre e posiciona arquivo
   If FT_FUSE(cSPatch) < 0 //-1 = falha na abertura
	  MsgAlert("Falha na Abertura do arquivo" + cSPatch)
      // Fecha o Arquivo Json
      FT_FUSE()                                         
      Return(.T.)
   Else


      nHandle := FOPEN(Alltrim(cSPatch), FO_READWRITE + FO_SHARED)
     
      If FERROR() != 0
         MsgAlert("Erro ao abrir o arquivo de produtos da APROVE.")
         Return .T.
      Endif

      // Lê o tamanho total do arquivo
      nLidos :=0
      FSEEK(nHandle,0,0)
      nTamArq:=FSEEK(nHandle,0,2)
      FSEEK(nHandle,0,0)

      // Lê todos os Registros
      xBuffer:=Space(nTamArq)
      FREAD(nHandle,@xBuffer,nTamArq)

      // Carrega o Array aLinha separando linha a linha do arquivo aberto
      XBuffer := StrTran(xBuffer, chr(10), "|")
                 
      cRet := xBuffer

      // Substitui o ] por [
      cRet := Strtran(cRet, "]", "[")
                          
      // Captura os resultados separando-os
      kServicos  := u_p_corta(cRet, "[",  2)
      kMetas     := u_p_corta(cRet, "[",  4)
      kIntervalo := u_p_corta(cRet, "[",  6)
      kMetasPrev := u_p_corta(cRet, "[",  8)
      kObras     := u_p_corta(cRet, "[", 10)
      kObrasAtiv := u_p_corta(cRet, "[", 12)
      kObrasMate := u_p_corta(cRet, "[", 14)  
    
      // Limpa as String para ser utilizada              
      kServicos  := Strtran(Strtran(Strtran(Strtran(Strtran(kServicos , "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
      kMetas     := Strtran(Strtran(Strtran(Strtran(Strtran(kMetas    , "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
      kIntervalo := Strtran(Strtran(Strtran(Strtran(Strtran(kIntervalo, "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
      kMetasPrev := Strtran(Strtran(Strtran(Strtran(Strtran(kMetasPrev, "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
      kObras     := Strtran(Strtran(Strtran(Strtran(Strtran(kObras    , "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
      kObrasAtiv := Strtran(Strtran(Strtran(Strtran(Strtran(kObrasAtiv, "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
      kObrasMate := Strtran(Strtran(Strtran(Strtran(Strtran(kObrasMate, "{", ""), "}", ""), '",', "#"), '"', ""), Chr(9), "")
              
      // Encerra a string kServicos
      If Substr(kServicos, Len(alltrim(kServicos)), 1) == ","; kServicos := Substr(kservicos,1, Len(Alltrim(kServicos))-1) + "#"; Endif
      If Substr(kServicos, Len(alltrim(kServicos)), 1) <> "#"; kServicos := Alltrim(kServicos) + "#"; Endif

      kServicos := Strtran(kServicos, ",id_nota:", "#id_nota:")
      kServicos := kServicos  + "|,"

      // Captura os posicionamentos dos Serviços
      aServicos := {}
      aServicos := xGeraPosicao(kServicos)

      // Encerra a string kMetas
      If Substr(kMetas, Len(alltrim(kMetas)), 1) == ","; kMetas := Substr(kMetas,1, Len(Alltrim(kMetas))-1) + "#"; Endif
      If Substr(kMetas, Len(alltrim(kMetas)), 1) <> "#"; kMetas := Alltrim(kMetas) + "#"; Endif

      kMetas := Strtran(kMetas, ",data:", "#data:")
      kMetas := kMetas     + "|,"

      // Captura os posicionamentos das Metas
      aMetas := {}
      aMetas := xGeraPosicao(kMetas)

      // Encerra a string kIntervalos
      If Substr(kIntervalos, Len(alltrim(kIntervalos)), 1) == ","; kIntervalos := Substr(kIntervalos,1, Len(Alltrim(kIntervalos))-1) + "#"; Endif
      If Substr(kIntervalos, Len(alltrim(kIntervalos)), 1) <> "#"; kIntervalos := Alltrim(kIntervalos) + "#"; Endif

      kIntervalos := Strtran(kIntervalos, ",id_turno:", "#id_turno:")
      kIntervalos := kIntervalos + "|,"

      // Captura os posicionamentos dos Intervalos
      aIntervalos := {}
      aIntervalos := xGeraPosicao(kIntervalos)

      // Encerra a string kIntervalos
      If Substr(kMetasPrev, Len(alltrim(kMetasPrev)), 1) == ","; kMetasPrev := Substr(kMetasPrev,1, Len(Alltrim(kMetasPrev))-1) + "#"; Endif
      If Substr(kMetasPrev, Len(alltrim(kMetasPrev)), 1) <> "#"; kMetasPrev := Alltrim(kMetasPrev) + "#"; Endif

      kMetasPrev := Strtran(kMetasPrev, ",id_contrato:", "#id_contrato:")
      kMetasPrev := kMetasPrev + "|,"

      // Captura os posicionamentos das Metas Previstas
      aMetasPrev := {}
      aMetasPrev := xGeraPosicao(kMetasPrev)
       
      // Encerra a string kObras
      If Substr(kObras, Len(alltrim(kObras)), 1) == ","; kObras := Substr(kObras,1, Len(Alltrim(kObras))-1) + "#"; Endif
      If Substr(kObras, Len(alltrim(kObras)), 1) <> "#"; kObras := Alltrim(kObras) + "#"; Endif

      kObras := Strtran(kObras, ",status:", "#status:")
      kObras := kObras     + "|,"

      // Captura os posicionamentos das Obras
      aObras := {}
      aObras := xGeraPosicao(kObras)
              
      // Encerra a string kObrasAtiv
      If Substr(kObrasAtiv, Len(alltrim(kObrasAtiv)), 1) == ","; kObrasAtiv := Substr(kObrasAtiv,1, Len(Alltrim(kObrasAtiv))-1) + "#"; Endif
      If Substr(kObrasAtiv, Len(alltrim(kObrasAtiv)), 1) <> "#"; kObrasAtiv := Alltrim(kObrasAtiv) + "#"; Endif

      kObrasAtiv := Strtran(kObrasAtiv, ",num_obra:", "#num_obra:")
      kObrasAtiv := kObrasAtiv + "|,"

      // Captura os posicionamentos das Obras Atividades
      aObrasAtiv := {}
      aObrasAtiv := xGeraPosicao(kObrasAtiv)

      // Encerra a string kObrasMate
      If Substr(kObrasMate, Len(alltrim(kObrasMate)), 1) == ","; kObrasMate := Substr(kObrasMate,1, Len(Alltrim(kObrasMate))-1) + "#"; Endif
      If Substr(kObrasMate, Len(alltrim(kObrasMate)), 1) <> "#"; kObrasMate := Alltrim(kObrasMate) + "#"; Endif

      kObrasMate := Strtran(kObrasMate, ",num_obra:", "#num_obra:")
      kObrasMate := kObrasMate + "|,"

      // Captura os posicionamentos das Obras Materiais
      aObrasMate := {}
      aObrasMate := xGeraPosicao(kObrasMate)

   Endif
                                 
   // Fecha o Arquivo Json
   FT_FUSE()                                         

   // Carrega variáveis de identificação da importação
   _Usuario := cUserName
   _Data    := Date()
   _Hora    := Time()

   // Carrega os valores da TAG: SERVIÇOS
   lQuebra        := .F.
   lPrimeiro      := .T.
   lFechacomando  := .F.
   nSequencia     := 0

   cLogServicos   := ""
   cLogMetas      := ""
   cLogIntervalos := ""
   cLogMPrevista  := ""
   cLogObras      := ""
   cLogOAtividade := ""
   cLogOMateriais := ""                

   For nContar = 1 to Len(aServicos)
   
       If Empty(Alltrim(aServicos[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif

       If Alltrim(aServicos[nContar,01]) == "hora_fim_turno"
          lFechaComando := .T.
       Endif
          
       // Carrega variáveis para envio a funmção de consistência dos dados para gravação do LOG de Inconsistência
       If Alltrim(aServicos[nContar,01]) == "id_contrato"       ; yContrato      := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_centro_servico" ; yCentroServico := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_tipo_servico"   ; yTipoServico   := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "num_obra_principal"; yObraPrincipal := aServicos[nContar,02] ; Endif

       // Grava os dados na tabela Z20
       If Alltrim(aServicos[nContar,01]) == "servicos"                     ; Z20->Z20_GRUP := "SERVICOS"            ; Endif         
       If Alltrim(aServicos[nContar,01]) == "id_nota"                      ; Z20->Z20_IDNT := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "num_nota"                     ; Z20->Z20_NNOT := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_tipo_servico"              ; Z20->Z20_IDTS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "tipo_servico"                 ; Z20->Z20_TSR1 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "origem_sistema"               ; Z20->Z20_OSIS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "origem_servico"               ; Z20->Z20_OSRV := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_coordenador"        ; Z20->Z20_MCOO := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_coordenador"             ; Z20->Z20_NCOO := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_supervisor"         ; Z20->Z20_MSUP := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_supervisor"              ; Z20->Z20_NSUP := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_equipe"                    ; Z20->Z20_IDEQ := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_equipe"                  ; Z20->Z20_NEQU := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_tipo_equipe"               ; Z20->Z20_IDTE := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "tipo_equipe"                  ; Z20->Z20_TEQU := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_funcionario1"       ; Z20->Z20_MF01 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_funcionario1"            ; Z20->Z20_NF01 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_funcionario2"       ; Z20->Z20_MF02 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_funcionario2"            ; Z20->Z20_NF02 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_funcionario3"       ; Z20->Z20_MF03 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_funcionario3"            ; Z20->Z20_NF03 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_funcionario4"       ; Z20->Z20_MF04 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_funcionario4"            ; Z20->Z20_NF04 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_funcionario5"       ; Z20->Z20_MF05 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_funcionario5"            ; Z20->Z20_NF05 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "matricula_funcionario6"       ; Z20->Z20_MF06 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "nome_funcionario6"            ; Z20->Z20_NF06 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_contrato"                  ; Z20->Z20_IDCT := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "contrato"                     ; Z20->Z20_CONT := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_centro_servico"            ; Z20->Z20_IDCS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "centro_servico"               ; Z20->Z20_CSER := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_veiculo"                   ; Z20->Z20_IDVE := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "placa_veiculo"                ; Z20->Z20_PLAC := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_tipo_veiculo"              ; Z20->Z20_IDTV := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "tipo_veiculo"                 ; Z20->Z20_TVEI := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "km_inicial"                   ; Z20->Z20_KMIN := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "km_final"                     ; Z20->Z20_KMFM := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_servico"                   ; Z20->Z20_IDSR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "codigo_servico"               ; Z20->Z20_CSRV := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "descricao_servico"            ; Z20->Z20_DSRV := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "quantidade"                   ; Z20->Z20_QUAN := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "valor_total_servico"          ; Z20->Z20_VSRV := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_comunicacao"             ; Z20->Z20_DCOM := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_comunicacao"             ; Z20->Z20_HCOM := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_inicio_deslocamento"     ; Z20->Z20_DIDS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_inicio_deslocamento"     ; Z20->Z20_HIDS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_chegada_local"           ; Z20->Z20_DCHL := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_chegada_local"           ; Z20->Z20_HCHL := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_inicio_servico"          ; Z20->Z20_DISR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_inicio_servico"          ; Z20->Z20_HISR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_termino_servico"         ; Z20->Z20_DTSR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_termino_servico"         ; Z20->Z20_HTSR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "latitude_inicio_deslocamento" ; Z20->Z20_LIDS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "longitude_inicio_deslocamento"; Z20->Z20_LOID := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "latitude_inicio_servico"      ; Z20->Z20_LISR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "longitude_inicio_servico"     ; Z20->Z20_LOIS := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "id_obra"                      ; Z20->Z20_IDOB := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "e_pep"                        ; Z20->Z20_EPEP := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "num_obra_principal"           ; Z20->Z20_NOPR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "cidade"                       ; Z20->Z20_CIDA := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "observacao"                   ; Z20->Z20_OBSE := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "tipo_de_servico"              ; Z20->Z20_TSR2 := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_inicio_turno"            ; Z20->Z20_DITR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_inicio_turno"            ; Z20->Z20_HITR := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "data_fim_turno"               ; Z20->Z20_DFMT := aServicos[nContar,02] ; Endif
       If Alltrim(aServicos[nContar,01]) == "hora_fim_turno"               ; Z20->Z20_HFTR := aServicos[nContar,02] ; Endif
                                       
       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "SERVICOS"
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)

          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock() 

          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Carrega os valores da TAG: METAS
   lQuebra       := .F.
   lPrimeiro     := .T.
   lFechacomando := .F.
   nPosicao      := 0

   For nContar = 1 to Len(aMetas)
   
       If Empty(Alltrim(aMetas[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif
          
       If Alltrim(aMetas[nContar,01]) == "hora_fim_turno"
          lFechaComando := .T.
       Endif

       // Grava os dados na tabela Z20
       If Alltrim(aMetas[nContar,01]) == "metas"                 ; Z20->Z20_GRUP := "METAS"            ; Endif
       If Alltrim(aMetas[nContar,01]) == "data"                  ; Z20->Z20_DATA := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "id_equipe"             ; Z20->Z20_IDEQ := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "nome_equipe"           ; Z20->Z20_NEQU := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "id_tipo_equipe"        ; Z20->Z20_IDTE := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "tipo_equipe"           ; Z20->Z20_TEQU := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "matricula_eletricista" ; Z20->Z20_MELE := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "nome_eletricista"      ; Z20->Z20_NELE := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "matricula_parceiro"    ; Z20->Z20_MPAR := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "nome_parceiro"         ; Z20->Z20_NPAR := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "id_contrato"           ; Z20->Z20_IDCT := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "contrato"              ; Z20->Z20_CONT := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "id_centro_de_servico"  ; Z20->Z20_IDCS := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "centro_de_servico"     ; Z20->Z20_CSER := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "meta_valor_dia"        ; Z20->Z20_MVLR := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "realizado_valor_dia"   ; Z20->Z20_RVDI := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "observacao"            ; Z20->Z20_OBSE := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "justificativa"         ; Z20->Z20_JUST := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "id_turno"              ; Z20->Z20_IDTN := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "id_tipo_turno"         ; Z20->Z20_IDTT := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "tipo_turno"            ; Z20->Z20_TTUR := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "hora_inicio_turno"     ; Z20->Z20_HITR := aMetas[nContar,02] ; Endif
       If Alltrim(aMetas[nContar,01]) == "hora_fim_turno"        ; Z20->Z20_HFTR := aMetas[nContar,02] ; Endif
                                       
       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "METAS"
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_STATUS := "0"
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)
          
          cLogMetas := IIF(Empty(Alltrim(cMsgLog)), "", "X")

          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock()
          
          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Carrega os valores da TAG: INTERVALOS
   lQuebra       := .F.
   lPrimeiro     := .T.
   lFechacomando := .F.
   nPosicao      := 0

   For nContar = 1 to Len(aIntervalos)
   
       If Empty(Alltrim(aIntervalos[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif
          
       If Alltrim(aIntervalos[nContar,01]) == "centro_de_servico"
          lFechaComando := .T.
       Endif

       // Grava os dados na tabela Z20
       If Alltrim(aIntervalos[nContar,01]) == "intervalos"            ; Z20->Z20_GRUP := "INTERVALOS"          ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_turno"              ; Z20->Z20_IDTN := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_intervalo"          ; Z20->Z20_IDIN := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_motivo"             ; Z20->Z20_IDMT := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "motivo"                ; Z20->Z20_MOTI := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "data"                  ; Z20->Z20_DATA := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "hora_inicio_intervalo" ; Z20->Z20_HIIN := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "hora_fim_intervalo"    ; Z20->Z20_HFIT := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "justificativa"         ; Z20->Z20_JUST := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_equipe"             ; Z20->Z20_IDEQ := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "nome_equipe"           ; Z20->Z20_NEQU := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_tipo_equipe"        ; Z20->Z20_IDTE := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "tipo_equipe"           ; Z20->Z20_TEQU := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "matricula_eletricista" ; Z20->Z20_MELE := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "nome_eletricista"      ; Z20->Z20_NELE := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "matricula_parceiro"    ; Z20->Z20_MPAR := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "nome_parceiro"         ; Z20->Z20_NPAR := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_contrato"           ; Z20->Z20_IDCT := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "contrato"              ; Z20->Z20_CONT := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "id_centro_de_servico"  ; Z20->Z20_IDCS := aIntervalos[nContar,02] ; Endif
       If Alltrim(aIntervalos[nContar,01]) == "centro_de_servico"     ; Z20->Z20_CSER := aIntervalos[nContar,02] ; Endif

       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "INTERVALOS
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_STATUS := "0"
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)
          
          cLogIntervalos := IIF(Empty(Alltrim(cMsgLog)), "", "X")

          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock()

          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Carrega os valores da TAG: METAS_PREVISTAS
   lQuebra       := .F.
   lPrimeiro     := .T.
   lFechacomando := .F.
   nPosicao      := 0

   For nContar = 1 to Len(aMetasPrev)
   
       If Empty(Alltrim(aMetasPrev[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif
          
       If Alltrim(aMetasPrev[nContar,01]) == "meta_prevista"
          lFechaComando := .T.
       Endif
          
       // Grava os dados na tabela Z20
       If Alltrim(aMetasPrev[nContar,01]) == "metas_prevista" ; Z20->Z20_GRUP := "METAS PREVISTA"      ; Endif
       If Alltrim(aMetasPrev[nContar,01]) == "id_contrato"    ; Z20->Z20_IDCT := aMetasPrev[nContar,02] ; Endif
       If Alltrim(aMetasPrev[nContar,01]) == "des_contrato"   ; Z20->Z20_DCON := aMetasPrev[nContar,02] ; Endif
       If Alltrim(aMetasPrev[nContar,01]) == "id_equipe"      ; Z20->Z20_IDEQ := aMetasPrev[nContar,02] ; Endif
       If Alltrim(aMetasPrev[nContar,01]) == "des_equipe"     ; Z20->Z20_DEQU := aMetasPrev[nContar,02] ; Endif
       If Alltrim(aMetasPrev[nContar,01]) == "meta_prevista"  ; Z20->Z20_MPRE := aMetasPrev[nContar,02] ; Endif

       // Atualiza o campo Z20_CONT para compatibilidade entre as TAGs
       Z20->Z20_CONT := yContrato

       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "METAS PREVISTA"
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_STATUS := "0"
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)

          cLogMPrevista  := IIF(Empty(Alltrim(cMsgLog)), "", "X")
          
          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock()

          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Carrega os valores da TAG: OBRAS
   lQuebra       := .F.
   lPrimeiro     := .T.
   lFechacomando := .F.
   nPosicao      := 0

   For nContar = 1 to Len(aObras)
   
       If Empty(Alltrim(aObras[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif
          
       If Alltrim(aObras[nContar,01]) == "cod_estoque"
          lFechaComando := .T.
       Endif

       // Grava os dados na tabela Z20
       If Alltrim(aObras[nContar,01]) == "obras"                     ; Z20->Z20_GRUP := "OBRAS"               ; Endif
   	   If Alltrim(aObras[nContar,01]) == "status"                    ; Z20->Z20_STAT := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "num_obra"                  ; Z20->Z20_NOBR := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "num_obra_principal"        ; Z20->Z20_NOPR := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "desc_obra"                 ; Z20->Z20_DOBR := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "regional"                  ; Z20->Z20_REGI := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "cidade"                    ; Z20->Z20_CIDA := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "contrato"                  ; Z20->Z20_CONT := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "responsavel"               ; Z20->Z20_RESP := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "data_de_receb"             ; Z20->Z20_DREC := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "inicio_exec_da_obra"       ; Z20->Z20_IEXE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "fim_exec_da_obra"          ; Z20->Z20_FEXE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "inicio_prev_da_obra"       ; Z20->Z20_IPOB := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "fim_prev_da_obra"          ; Z20->Z20_FPOB := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "data_energizacao"          ; Z20->Z20_DENE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "data_protocolo_faturamento"; Z20->Z20_DPFA := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "data_uf"                   ; Z20->Z20_DTUF := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "valor_prev"                ; Z20->Z20_VPRE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "valor_real"                ; Z20->Z20_VREA := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "valor_pago"                ; Z20->Z20_VPAG := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "qtde_postes_prev"          ; Z20->Z20_QPOP := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "qtde_postes"               ; Z20->Z20_QPOS := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "cod_obra"                  ; Z20->Z20_COBR := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "tipo_de_obra"              ; Z20->Z20_TPOB := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "centro_de_servico"         ; Z20->Z20_CSRV := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "supervisor"                ; Z20->Z20_SUPE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "num_pedido"                ; Z20->Z20_NPED := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "data_pedido"               ; Z20->Z20_DPED := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "latitude"                  ; Z20->Z20_LATE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "longitude"                 ; Z20->Z20_LONG := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "fiscal_concessionaria"     ; Z20->Z20_FCON := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "nota_fiscal"               ; Z20->Z20_NFIS := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "data_doc"                  ; Z20->Z20_DNOT := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "vistoria_realizada"        ; Z20->Z20_VIST := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "observacao"                ; Z20->Z20_OBSE := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "tipo_de_servico"           ; Z20->Z20_TSR2 := aObras[nContar,02] ; Endif
   	   If Alltrim(aObras[nContar,01]) == "cod_estoque"               ; Z20->Z20_CSTQ := aObras[nContar,02] ; Endif

       // Atualiza o campo Z20_CONT para compatibilidade entre as TAGs
       Z20->Z20_CONT := yContrato

       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "OBRAS"
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_STATUS := "0"
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)
          
          cLogObras := IIF(Empty(Alltrim(cMsgLog)), "", "X")

          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock()

          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Carrega os valores da TAG: OBRAS ATIVIDADES
   lQuebra       := .F.
   lPrimeiro     := .T.
   lFechacomando := .F.
   nPosicao      := 0

   For nContar = 1 to Len(aObrasAtiv)

       If Empty(Alltrim(aObrasAtiv[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif
          
       If Alltrim(aObrasAtiv[nContar,01]) == "quantidade"
          lFechaComando := .T.
       Endif

       // Grava os dados na tabela Z20
       If Alltrim(aObrasAtiv[nContar,01]) == "obras atividades"          ; Z20->Z20_GRUP := "OBRAS ATIVIDADES0"   ; Endif
	   If Alltrim(aObrasAtiv[nContar,01]) == "num_obra"                  ; Z20->Z20_NOBR := aObrasAtiv[nContar,02] ; Endif
	   If Alltrim(aObrasAtiv[nContar,01]) == "num_obra_principal"        ; Z20->Z20_NOPR := aObrasAtiv[nContar,02] ; Endif
	   If Alltrim(aObrasAtiv[nContar,01]) == "cod_precif"                ; Z20->Z20_CPRE := aObrasAtiv[nContar,02] ; Endif
	   If Alltrim(aObrasAtiv[nContar,01]) == "des_precif"                ; Z20->Z20_DPRE := aObrasAtiv[nContar,02] ; Endif
	   If Alltrim(aObrasAtiv[nContar,01]) == "un"                        ; Z20->Z20_UNID := aObrasAtiv[nContar,02] ; Endif
	   If Alltrim(aObrasAtiv[nContar,01]) == "quantidade"                ; Z20->Z20_QPRE := aObrasAtiv[nContar,02] ; Endif

       // Atualiza o campo Z20_CONT para compatibilidade entre as TAGs
       Z20->Z20_CONT := yContrato

       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "OBRAS ATIVIDADES"
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_STATUS := "0"
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)
          
          cLogOAtividade := IIF(Empty(Alltrim(cMsgLog)), "", "X")

          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock()

          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Carrega os valores da TAG: OBRAS MATERIAIS
   lQuebra       := .F.
   lPrimeiro     := .T.
   lFechacomando := .F.
   nPosicao      := 0

   For nContar = 1 to Len(aObrasMate)
   
       If Empty(Alltrim(aObrasMate[nContar,01]))
          Loop
       Endif   

       If lPrimeiro == .T.
          DbSelectArea("Z20")
          DbSetOrder(1)
          Reclock("Z20", .T.)
          lPrimeiro := .F.
       Endif
          
       If Alltrim(aObrasMate[nContar,01]) == "usuario"
          lFechaComando := .T.
       Endif

       // Grava os dados na tabela Z20
       If Alltrim(aObrasMate[nContar,01]) == "obras materiais"      ; Z20->Z20_GRUP := "OBRAS MATERIAIS"     ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "num_obra"             ; Z20->Z20_NOBR := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "num_obra_principal"   ; Z20->Z20_NOPR := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "material"             ; Z20->Z20_MATE := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "situacao"             ; Z20->Z20_SITU := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "un"                   ; Z20->Z20_UNID := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "orcado_concessionaria"; Z20->Z20_ORCA := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "orcado_validado"      ; Z20->Z20_ORCV := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "processada"           ; Z20->Z20_PROC := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "a_separar"            ; Z20->Z20_ASEP := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "aplicada"             ; Z20->Z20_APLI := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "devolver"             ; Z20->Z20_ADEV := aObrasMate[nContar,02] ; Endif
	   If Alltrim(aObrasMate[nContar,01]) == "data_pedido"          ; Z20->Z20_DPED := aObrasMate[nContar,02] ; Endif
   	   If Alltrim(aObrasMate[nContar,01]) == "usuario"              ; Z20->Z20_CODU := aObrasMate[nContar,02] ; Endif

       // Atualiza o campo Z20_CONT para compatibilidade entre as TAGs
       Z20->Z20_CONT := yContrato

       If lFechaComando == .T.

          nSequencia      := nSequencia + 1          
          Z20->Z20_GRUP   := "OBRAS MATERIAIS"
          Z20->Z20_USUA   := _Usuario
          Z20->Z20_DIMP   := _Data
          Z20->Z20_HIMP   := Time()
          Z20->Z20_ARQU   := cArqImportacao
          Z20->Z20_STATUS := "0"
          Z20->Z20_SEQU   := Strzero(nSequencia,3)

          // Envia para a função que consiste os dados do registro antes do fechamento 
          cMsgLog := GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)
          
          cLogOMateriais := IIF(Empty(Alltrim(cMsgLog)), "", "X")                

          If U_P_CORTA(cMsgLog, "|", 1) == "[XXXXX]"
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + "Registro já registrado na OS nº " + Alltrim(U_P_CORTA(cMsgLog, "|", 2))
             Z20->Z20_STATUS := "X" // Legenda que indica registro já incluído
             Z20->Z20_NROS   := U_P_CORTA(cMsgLog, "|", 2)
          Else
             Z20->Z20_LOGE   := Z20->Z20_LOGE + "|" + Dtoc(Date()) + " - " + Time() + "|" + Alltrim(cMsgLog)
             Z20->Z20_STATUS := IIF(Empty(Alltrim(cMsgLog)), "0", "1")
          Endif

          MsUnlock()

          lPrimeiro     := .T.
          lFechaComando := .F.

       Endif

   Next nContar

   // Envia para a função que envia email em caso de inconsistências na tabela Z20
   GeraEmailLogErro()

// AAQUI

   // Copia o arquivo selecionado para a pasta dos arquivos Importados                    
//   __CopyFile( cSPatch, cSDestino)
   
   // Exclui o arquivo da pasta de Origem após a copia do mesmo
//   FERASE(cSPatch)

   // fecha a tela de seleção de arquivos disponíveis para importação
   oDlg:End()
             
   oDlgMan:End()

   // Envia para a função que gera as OS para registros sem inconsistência
   ImportaDadosOS(cArqImportacao, _Usuario, _Data)

   // Fecha o programa para abrí-lo novamente dando refresh no grid principal
   oDlgMan:End()
   U_SOLTGEROS()

Return(.T.)
                            
// Função que gera email de log de erro da tabela Z20
Static Function GeraEmailLogErro()
                
   Local cCorpo    := ""
   Local nContar   := 0
   Local cString   := ""
   Local lPrimeiro := .T.
   Local cSql      := ""
   
   If Select("T_GERALOG") > 0
      T_GERALOG->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z20_FILIAL, Z20_CSER, Z20_CIDA  , Z20_CSRV, Z20_CONT, Z20_DATA, Z20_DCHL  , Z20_DCOM, Z20_DFMT,"
   cSql += "       Z20_DIDS	 , Z20_DISR, Z20_DITR  , Z20_DTSR, Z20_DCON, Z20_DEQU, Z20_DSRV  , Z20_EPEP, Z20_GRUP,"
   cSql += "       Z20_HCHL	 , Z20_HCOM, Z20_HFIT  , Z20_HFTR, Z20_HIDS, Z20_HIIN, Z20_HISR  , Z20_HITR, Z20_HTSR,"
   cSql += "       Z20_IDCS	 , Z20_IDCT, Z20_IDEQ  , Z20_IDIN, Z20_IDMT, Z20_IDNT, Z20_IDOB  , Z20_IDSR, Z20_IDTE,"
   cSql += "       Z20_IDTS	 , Z20_IDTT, Z20_IDTV  , Z20_IDTN, Z20_IDVE, Z20_JUST, Z20_KMFM  , Z20_KMIN, Z20_LIDS,"
   cSql += "       Z20_LISR	 , Z20_LOID, Z20_LOIS  , Z20_MCOO, Z20_MELE, Z20_MF01, Z20_MF02  , Z20_MF03, Z20_MF04,"
   cSql += "       Z20_MF05	 , Z20_MF06, Z20_MPAR  , Z20_MSUP, Z20_MPRE, Z20_MVLR, Z20_MOTI  , Z20_NCOO, Z20_NELE,"
   cSql += "       Z20_NEQU	 , Z20_NF01, Z20_NF02  , Z20_NF03, Z20_NF04, Z20_NF05, Z20_NF06  , Z20_NPAR, Z20_NSUP,"
   cSql += "       Z20_NNOT	 , Z20_NOBR, Z20_NOPR  , Z20_OBSE, Z20_OSRV, Z20_OSIS, Z20_PLAC  , Z20_QUAN, Z20_RVDI,"
   cSql += "       Z20_TSR1	 , Z20_TEQU, Z20_TTUR  , Z20_TVEI, Z20_VSRV, Z20_DIMP, Z20_HIMP  , Z20_ARQU, Z20_USUA,"
   cSql += "       Z20_NROS	 , Z20_SEQU, Z20_DIMP  , Z20_HIMP, Z20_USUA, Z20_ARQU, Z20_STATUS, "
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), Z20_LOGE)) AS Z20_LOGE"   
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE Z20_STATUS = '1'"                          
   cSql += "   AND D_E_L_E_T_ = ''"                

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERALOG", .T., .T. )

   // Se não existirem registros de geração de Log, retorna sem enviar email
   If T_GERALOG->( EOF() )
      Return(.T.)
   Endif
      
   // Captura o caminho onde o arquivo será gerado para ser anexado ao email
   If Empty(Alltrim(GetMV("SIR_PEMAL")))
      Return(.T.)
   Endif
     
   // Cria o arquivo de log a ser criado no local indicado no parâmetro SIR_PEMAL
   cArqAnexo := Alltrim(GetMV("SIR_PEMAL")) + "\LOG_" + Dtos(Date()) + "_" + Substr(Time(),01,02) + Substr(Time(),04,02) + Substr(Time(),07,02) + ".CSV"
   nHdl      := fCreate(cArqAnexo)

   cString := ""

   T_GERALOG->( DbGoTop() )
   
   WHILE !T_GERALOG->( EOF() )

      If lPrimeiro == .T.
      
         cString := "Registros Log de Inconsistências de Importação de OS - GPM" + ";" + chr(13) + chr(10) + chr(13) + chr(10)
          
         fWrite (nHdl, cString ) 

         cString := "Seq"                           + ";" + ;
                    "Grupo"                         + ";" + ;
                    "ID Nota"                       + ";" + ;
                    "Nº Nota"                       + ";" + ;
                    "ID Tipo Serviço"               + ";" + ;
                    "Tipo Serviço"                  + ";" + ;
                    "Origem Sistema"                + ";" + ;
                    "Origem Serviço"                + ";" + ;
                    "Matrícula Coordenador"         + ";" + ;
                    "Nome Coordenador"              + ";" + ;
                    "Matrícula Supervisor"          + ";" + ;
                    "Nome Supervisor"               + ";" + ;
                    "ID Equipe"                     + ";" + ;
                    "Nome Equipe"                   + ";" + ;
                    "ID Tipo Equipe"                + ";" + ;
                    "Tipo Equipe"                   + ";" + ;
                    "Matrícula Funcionário 1"       + ";" + ;
                    "Nome Funcionário 1"            + ";" + ;
                    "Matrícula Funcionario 2"       + ";" + ;
                    "Nome Funcionário 2"            + ";" + ;
                    "Matrícula Funionário 3"        + ";" + ;
                    "Nome Funcionário 3"            + ";" + ;
                    "Matrícula Funcionário 4"       + ";" + ;
                    "Nome Funcionário 4"            + ";" + ;
                    "Matrícula Funcionário 5"       + ";" + ;
                    "Nome Funcionário 5"            + ";" + ;
                    "Matrícula Funcionário 6"       + ";" + ;
                    "Nome Funcionário 6"            + ";" + ;
                    "Matrícula Eletricista"         + ";" + ;
                    "Nome Eletricista"              + ";" + ;
                    "Matrícula Parceiro"            + ";" + ;
                    "Nome Parceiro"                 + ";" + ;
                    "ID Contrato"                   + ";" + ;           
                    "Contrato"                      + ";" + ;
                    "ID Centro Serviço"             + ";" + ;
                    "Centro Serviço"                + ";" + ;
                    "ID Veículo"                    + ";" + ;
                    "Placa veículo"                 + ";" + ;
                    "ID Tipo Veículo"               + ";" + ;
                    "Tipo Veículo"                  + ";" + ;
                    "KM Inicial"                    + ";" + ;
                    "KM Final"                      + ";" + ;
                    "ID Serviço"                    + ";" + ;
                    "Código Serviço"                + ";" + ;
                    "Descrição Serviço"             + ";" + ;
                    "Quantidade"                    + ";" + ;
                    "Valor Total Serviço"           + ";" + ;
                    "Data Comunicação"              + ";" + ;
                    "hora Comunicação"              + ";" + ;
                    "Data Início Deslocamento"      + ";" + ;
                    "Hora Início Deslocamento"      + ";" + ;
                    "Data Chegada Local"            + ";" + ;
                    "Hora Chegada Local"            + ";" + ;
                    "Data início Serviço"           + ";" + ;
                    "Hora Início Serviço"           + ";" + ;
                    "Data Término Serviço"          + ";" + ;
                    "Hora Término Serviço"          + ";" + ;
                    "Latitude Início Deslocamento"  + ";" + ;
                    "Longitude Início Deslocamento" + ";" + ;
                    "Latitude Início Serviço"       + ";" + ;
                    "Longitude Início Serviço"      + ";" + ;
                    "ID Obra"                       + ";" + ;
                    "E PEP"                         + ";" + ;
                    "Data"                          + ";" + ;
                    "Meta Valor Dia"                + ";" + ;
                    "Realizado Valor Dia"           + ";" + ;
                    "Observação"                    + ";" + ;
                    "Justificativa"                 + ";" + ;
                    "ID Turno"                      + ";" + ;
                    "ID Tipo Turno"                 + ";" + ;
                    "Tipo Turno"                    + ";" + ;
                    "Hora Início Turno"             + ";" + ;
                    "Hora Final Turno"              + ";" + ;
                    "ID Intervalo"                  + ";" + ;
                    "ID Motivo"                     + ";" + ;
                    "Motivo"                        + ";" + ;
                    "Hora Início Intervalo"         + ";" + ;
                    "Hora Fim Intervalo"            + ";" + ;
                    "Des Contrato"                  + ";" + ;
                    "Meta Prevista"                 + ";" + ;
                    "DataImportação"                + ";" + ;
                    "Hora Importação"               + ";" + ;
                    "Usuário que Importou"          + ";" + ;
                    "Arquivo Importado"             + ";" + ;
                    "Log"                           + chr(13)

         lPrimeiro := .F.

         fWrite (nHdl, cString ) 

      Endif
       
      cString := T_GERALOG->Z20_SEQU + ";" + ; // "Seq"                           
                 T_GERALOG->Z20_GRUP + ";" + ; // "Grupo"                         
                 T_GERALOG->Z20_IDNT + ";" + ; // "ID Nota"                       
                 T_GERALOG->Z20_NNOT + ";" + ; // "Nº Nota"                       
                 T_GERALOG->Z20_IDTS + ";" + ; // "ID Tipo Serviço"               
                 T_GERALOG->Z20_TSR1 + ";" + ; // "Tipo Serviço"                  
                 T_GERALOG->Z20_OSIS + ";" + ; // "Origem Sistema"                
                 T_GERALOG->Z20_OSRV + ";" + ; // "Origem Serviço"                
                 T_GERALOG->Z20_MCOO + ";" + ; // "Matrícula Coordenador"         
                 T_GERALOG->Z20_NCOO + ";" + ; // "Nome Coordenador"              
                 T_GERALOG->Z20_MSUP + ";" + ; // "Matrícula Supervisor"          
                 T_GERALOG->Z20_NSUP + ";" + ; // "Nome Supervisor"               
                 T_GERALOG->Z20_IDEQ + ";" + ; // "ID Equipe"                     
                 T_GERALOG->Z20_NEQU + ";" + ; // "Nome Equipe"                   
                 T_GERALOG->Z20_IDTE + ";" + ; // "ID Tipo Equipe"                
                 T_GERALOG->Z20_TEQU + ";" + ; // "Tipo Equipe"                   
                 T_GERALOG->Z20_MF01 + ";" + ; // "Matrícula Funcionário 1"       
                 T_GERALOG->Z20_NF01 + ";" + ; // "Nome Funcionário 1"            
                 T_GERALOG->Z20_MF02 + ";" + ; // "Matrícula Funcionario 2"       
                 T_GERALOG->Z20_NF02 + ";" + ; // "Nome Funcionário 2"            
                 T_GERALOG->Z20_MF03 + ";" + ; // "Matrícula Funionário 3"        
                 T_GERALOG->Z20_NF03 + ";" + ; // "Nome Funcionário 3"            
                 T_GERALOG->Z20_MF04 + ";" + ; // "Matrícula Funcionário 4"       
                 T_GERALOG->Z20_NF04 + ";" + ; // "Nome Funcionário 4"            
                 T_GERALOG->Z20_MF05 + ";" + ; // "Matrícula Funcionário 5"       
                 T_GERALOG->Z20_NF05 + ";" + ; // "Nome Funcionário 5"            
                 T_GERALOG->Z20_MF06 + ";" + ; // "Matrícula Funcionário 6"       
                 T_GERALOG->Z20_NF06 + ";" + ; // "Nome Funcionário 6"            
                 T_GERALOG->Z20_MELE + ";" + ; // "Matrícula Eletricista"         
                 T_GERALOG->Z20_NELE + ";" + ; // "Nome Eletricista"              
                 T_GERALOG->Z20_MPAR + ";" + ; // "Matrícula Parceiro"            
                 T_GERALOG->Z20_NPAR + ";" + ; // "Nome Parceiro"                 
                 T_GERALOG->Z20_IDCT + ";" + ; // "ID Contrato"                   
                 T_GERALOG->Z20_CONT + ";" + ; // "Contrato"                      
                 T_GERALOG->Z20_IDCS + ";" + ; // "ID Centro Serviço"             
                 T_GERALOG->Z20_CSER + ";" + ; // "Centro Serviço"                
                 T_GERALOG->Z20_IDVE + ";" + ; // "ID Veículo"                    
                 T_GERALOG->Z20_PLAC + ";" + ; // "Placa veículo"                 
                 T_GERALOG->Z20_IDTV + ";" + ; // "ID Tipo Veículo"               
                 T_GERALOG->Z20_TVEI + ";" + ; // "Tipo Veículo"                  
                 T_GERALOG->Z20_KMIN + ";" + ; // "KM Inicial"                    
                 T_GERALOG->Z20_KMFM + ";" + ; // "KM Final"                      
                 T_GERALOG->Z20_IDSR + ";" + ; // "ID Serviço"                    
                 T_GERALOG->Z20_CSRV + ";" + ; // "Código Serviço"                
                 T_GERALOG->Z20_DSRV + ";" + ; // "Descrição Serviço"             
                 T_GERALOG->Z20_QUAN + ";" + ; // "Quantidade"                    
                 T_GERALOG->Z20_VSRV + ";" + ; // "Valor Total Serviço"           
                 T_GERALOG->Z20_DCOM + ";" + ; // "Data Comunicação"              
                 T_GERALOG->Z20_HCOM + ";" + ; // "hora Comunicação"              
                 T_GERALOG->Z20_DIDS + ";" + ; // "Data Início Deslocamento"      
                 T_GERALOG->Z20_HIDS + ";" + ; // "Hora Início Deslocamento"      
                 T_GERALOG->Z20_DCHL + ";" + ; // "Data Chegada Local"            
                 T_GERALOG->Z20_HCHL + ";" + ; // "Hora Chegada Local"            
                 T_GERALOG->Z20_DISR + ";" + ; // "Data início Serviço"           
                 T_GERALOG->Z20_HISR + ";" + ; // "Hora Início Serviço"           
                 T_GERALOG->Z20_DTSR + ";" + ; // "Data Término Serviço"          
                 T_GERALOG->Z20_HTSR + ";" + ; // "Hora Término Serviço"          
                 T_GERALOG->Z20_LIDS + ";" + ; // "Latitude Início Deslocamento"  
                 T_GERALOG->Z20_LOID + ";" + ; // "Longitude Início Deslocamento" 
                 T_GERALOG->Z20_LISR + ";" + ; // "Latitude Início Serviço"       
                 T_GERALOG->Z20_LOIS + ";" + ; // "Longitude Início Serviço"      
                 T_GERALOG->Z20_IDOB + ";" + ; // "ID Obra"                       
                 T_GERALOG->Z20_EPEP + ";" + ; // "E PEP"                         
                 T_GERALOG->Z20_DATA + ";" + ; // "Data"                          
                 T_GERALOG->Z20_MVLR + ";" + ; // "Meta Valor Dia"                
                 T_GERALOG->Z20_RVDI + ";" + ; // "Realizado Valor Dia"           
                 T_GERALOG->Z20_OBSE + ";" + ; // "Observação"                    
                 T_GERALOG->Z20_JUST + ";" + ; // "Justificativa"                 
                 T_GERALOG->Z20_IDTN + ";" + ; // "ID Turno"                      
                 T_GERALOG->Z20_IDTT + ";" + ; // "ID Tipo Turno"                 
                 T_GERALOG->Z20_TTUR + ";" + ; // "Tipo Turno"                    
                 T_GERALOG->Z20_HITR + ";" + ; // "Hora Início Turno"             
                 T_GERALOG->Z20_HTSR + ";" + ; // "Hora Final Turno"              
                 T_GERALOG->Z20_IDIN + ";" + ; // "ID Intervalo"                  
                 T_GERALOG->Z20_IDMT + ";" + ; // "ID Motivo"                     
                 T_GERALOG->Z20_MOTI + ";" + ; // "Motivo"                        
                 T_GERALOG->Z20_HIIN + ";" + ; // "Hora Início Intervalo"         
                 T_GERALOG->Z20_HFIT + ";" + ; // "Hora Fim Intervalo"            
                 T_GERALOG->Z20_DCON + ";" + ; // "Des Contrato"                  
                 T_GERALOG->Z20_MPRE + ";" + ; // "Meta Prevista"                 
                 T_GERALOG->Z20_DIMP + ";" + ; // "Data da Importação"
                 T_GERALOG->Z20_HIMP + ";" + ; // "Hora da Importação"
                 T_GERALOG->Z20_USUA + ";" + ; // "Usuário que gerou a importação"
                 T_GERALOG->Z20_ARQU + ";" + ; // "Arquivo utilizado na importação"
                 T_GERALOG->Z20_LOGE + chr(13) // "Log"                           

      fWrite (nHdl, cString ) 
      
      T_GERALOG->( DbSkip() )
       
   ENDDO    

   // Fecha o arquivo de Log
   fClose(nHdl)
                 
   U_AUTOMR20("Segue arquivo de Log com inconsistências na importação de OS - GPM", "harald.hans@solutio.inf.br", cArqAnexo, "LOG de Inconsistência na Importação de OS - GPM")


   // Envia para a função que envia o email de Log de Erro aos responsáveis      
// EnviaEmailLogErro(cArqAnexo)

Return(.T.)

// Função que envia o email aos responsáveis
Static Function EnviaEmailLogErro(cAnexo)

   Local lResulConn := .T.
   Local lResulSend := .T.
   Local lResult    := .T.
   Local cError     := ""   
   Local cRet       := ""                                         
   Local _cUsuario  := GetMV("MV_MAILUSE")
   Local _cSenha    := Embaralha(GetMV("MV_MAILPAS"), 1) 
   Local _lJob      
    
   lResulConn := MailSmtpOn( "smtp.dominio.com", _cUsuario, _cSenha)
   
   If !lResulConn//GET MAIL ERROR 
      cErrorcError := MailGetErr()
      If _lJob
         cRet := Padc("Falha na conexao "+cErrorcError)
      Else
         cRet := "Falha na conexao "+cError
      Endif
      Return(.F.)
   Endif
 
   SEND MAIL FROM "harald.hans@solutio.inf.br" TO "harald.hans@solutio.inf.br" SUBJECT "Log Erro Importação OS - GPM" BODY "Segue arquivo com erro" FORMAT TEXT RESULT lResulSend

   If !lResulSend
      cRet:= "Falha no Envio!"
   Else
      cRet:= "E-mail enviado com sucesso!"
   Endif

Return(.T.)

// Função que mostra o detalhe dp registro selecionado
Static Function MostraDetalhes()
   
   Local cDetalhe := ""
   Local oDetalhe
                                                  
   Local oFont10c := TFont():New( "Courier New",,16,,.f.,,,,.f.,.f. )
   
   Private oDlgDetalhes

   If Empty(Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,002]))
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nenhum registro selecionado para visualização de detalhe.")
      Return(.T.)
   Endif

   // Carrega a variável cDetalhe com os dados do registro selecionado no Grid
   Do Case

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "SERVICOS"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
                          "ID Nota.......................: " + oBrwCpo:aCols[oBrwCpo:nAt,004] + chr(13) + chr(10) + ;
                          "Número Nota...................: " + oBrwCpo:aCols[oBrwCpo:nAt,005] + chr(13) + chr(10) + ;
                          "ID Tipo Serviço...............: " + oBrwCpo:aCols[oBrwCpo:nAt,006] + chr(13) + chr(10) + ;
                          "Tipo Serviço..................: " + oBrwCpo:aCols[oBrwCpo:nAt,007] + chr(13) + chr(10) + ;
                          "Origem Sistema................: " + oBrwCpo:aCols[oBrwCpo:nAt,008] + chr(13) + chr(10) + ;
                          "Origem Serviço................: " + oBrwCpo:aCols[oBrwCpo:nAt,009] + chr(13) + chr(10) + ;
                          "Matrícula Coordenador.........: " + oBrwCpo:aCols[oBrwCpo:nAt,010] + chr(13) + chr(10) + ;
                          "Nome Coordenador..............: " + oBrwCpo:aCols[oBrwCpo:nAt,011] + chr(13) + chr(10) + ;
                          "Matrícula Supervisor..........: " + oBrwCpo:aCols[oBrwCpo:nAt,012] + chr(13) + chr(10) + ;
                          "Nome Supervisor...............: " + oBrwCpo:aCols[oBrwCpo:nAt,013] + chr(13) + chr(10) + ;
                          "ID Equipe.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,014] + chr(13) + chr(10) + ;
                          "Nome Equipe...................: " + oBrwCpo:aCols[oBrwCpo:nAt,015] + chr(13) + chr(10) + ;
                          "ID Tipo Equipe................: " + oBrwCpo:aCols[oBrwCpo:nAt,016] + chr(13) + chr(10) + ;
                          "Tipo Equipe...................: " + oBrwCpo:aCols[oBrwCpo:nAt,017] + chr(13) + chr(10) + ;
                          "Matrícula Funcionário 1.......: " + oBrwCpo:aCols[oBrwCpo:nAt,018] + chr(13) + chr(10) + ;
                          "Nome Funcionário 1............: " + oBrwCpo:aCols[oBrwCpo:nAt,019] + chr(13) + chr(10) + ;
                          "Matrícula Funcionário 2.......: " + oBrwCpo:aCols[oBrwCpo:nAt,020] + chr(13) + chr(10) + ;
                          "Nome Funcionário 2............: " + oBrwCpo:aCols[oBrwCpo:nAt,021] + chr(13) + chr(10) + ;
                          "Matrícula Funcionário 3.......: " + oBrwCpo:aCols[oBrwCpo:nAt,022] + chr(13) + chr(10) + ;
                          "Nome Funcionário 3............: " + oBrwCpo:aCols[oBrwCpo:nAt,023] + chr(13) + chr(10) + ;
                          "Matrícula Funcionário 4.......: " + oBrwCpo:aCols[oBrwCpo:nAt,024] + chr(13) + chr(10) + ;
                          "Nome Funcionário 4............: " + oBrwCpo:aCols[oBrwCpo:nAt,025] + chr(13) + chr(10) + ;
                          "Matrícula Funcionário 5.......: " + oBrwCpo:aCols[oBrwCpo:nAt,026] + chr(13) + chr(10) + ;
                          "Nome Funcionário 5............: " + oBrwCpo:aCols[oBrwCpo:nAt,027] + chr(13) + chr(10) + ;
                          "Matrícula Funcionário 6.......: " + oBrwCpo:aCols[oBrwCpo:nAt,028] + chr(13) + chr(10) + ;
                          "Nome Funcionário 6............: " + oBrwCpo:aCols[oBrwCpo:nAt,029] + chr(13) + chr(10) + ;
                          "ID Contrato...................: " + oBrwCpo:aCols[oBrwCpo:nAt,030] + chr(13) + chr(10) + ;
                          "Contrato......................: " + oBrwCpo:aCols[oBrwCpo:nAt,031] + chr(13) + chr(10) + ;
                          "ID Centro Serviço.............: " + oBrwCpo:aCols[oBrwCpo:nAt,032] + chr(13) + chr(10) + ;
                          "Centro Serviço................: " + oBrwCpo:aCols[oBrwCpo:nAt,033] + chr(13) + chr(10) + ;
                          "ID Veículo....................: " + oBrwCpo:aCols[oBrwCpo:nAt,034] + chr(13) + chr(10) + ;
                          "Placa Veículo.................: " + oBrwCpo:aCols[oBrwCpo:nAt,035] + chr(13) + chr(10) + ;
                          "ID Tipo Veículo...............: " + oBrwCpo:aCols[oBrwCpo:nAt,036] + chr(13) + chr(10) + ;
                          "Tipo Veículo..................: " + oBrwCpo:aCols[oBrwCpo:nAt,037] + chr(13) + chr(10) + ;
                          "KM Inicial....................: " + oBrwCpo:aCols[oBrwCpo:nAt,038] + chr(13) + chr(10) + ;
                          "KM Final......................: " + oBrwCpo:aCols[oBrwCpo:nAt,039] + chr(13) + chr(10) + ;
                          "ID Serviço....................: " + oBrwCpo:aCols[oBrwCpo:nAt,040] + chr(13) + chr(10) + ;
                          "Código Serviço................: " + oBrwCpo:aCols[oBrwCpo:nAt,041] + chr(13) + chr(10) + ;
                          "Descrição Serviço.............: " + oBrwCpo:aCols[oBrwCpo:nAt,042] + chr(13) + chr(10) + ;
                          "Quantidade....................: " + oBrwCpo:aCols[oBrwCpo:nAt,043] + chr(13) + chr(10) + ;
                          "Valor Total Serviço...........: " + oBrwCpo:aCols[oBrwCpo:nAt,044] + chr(13) + chr(10) + ;
                          "Data Comunicação..............: " + oBrwCpo:aCols[oBrwCpo:nAt,045] + chr(13) + chr(10) + ;
                          "Hora Comunicação..............: " + oBrwCpo:aCols[oBrwCpo:nAt,046] + chr(13) + chr(10) + ;
                          "Data Início Deslocamento......: " + oBrwCpo:aCols[oBrwCpo:nAt,047] + chr(13) + chr(10) + ;
                          "Hora Início Deslocamento......: " + oBrwCpo:aCols[oBrwCpo:nAt,048] + chr(13) + chr(10) + ;
                          "Data Chegada Local............: " + oBrwCpo:aCols[oBrwCpo:nAt,049] + chr(13) + chr(10) + ;
                          "Hora Chegada Local............: " + oBrwCpo:aCols[oBrwCpo:nAt,050] + chr(13) + chr(10) + ;
                          "Data Início Serviço...........: " + oBrwCpo:aCols[oBrwCpo:nAt,051] + chr(13) + chr(10) + ;
                          "Hora Início Serviço...........: " + oBrwCpo:aCols[oBrwCpo:nAt,052] + chr(13) + chr(10) + ;
                          "Data Término Serviço..........: " + oBrwCpo:aCols[oBrwCpo:nAt,053] + chr(13) + chr(10) + ;
                          "Hora Término Serviço..........: " + oBrwCpo:aCols[oBrwCpo:nAt,054] + chr(13) + chr(10) + ;
                          "Latitude Início Deslocamento..: " + oBrwCpo:aCols[oBrwCpo:nAt,055] + chr(13) + chr(10) + ;
                          "Longitude Início Deslocamento.: " + oBrwCpo:aCols[oBrwCpo:nAt,056] + chr(13) + chr(10) + ;
                          "Latitude Início Serviço.......: " + oBrwCpo:aCols[oBrwCpo:nAt,057] + chr(13) + chr(10) + ;
                          "Longitude Início Serviço......: " + oBrwCpo:aCols[oBrwCpo:nAt,058] + chr(13) + chr(10) + ;
                          "ID Obra.......................: " + oBrwCpo:aCols[oBrwCpo:nAt,059] + chr(13) + chr(10) + ;
                          "E PEP.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,060] + chr(13) + chr(10) + ;
                          "Número Obra Principal.........: " + oBrwCpo:aCols[oBrwCpo:nAt,061] + chr(13) + chr(10) + ;
                          "Cidade........................: " + oBrwCpo:aCols[oBrwCpo:nAt,062] + chr(13) + chr(10) + ;
                          "Observação....................: " + oBrwCpo:aCols[oBrwCpo:nAt,063] + chr(13) + chr(10) + ;
                          "Tipo de Serviço...............: " + oBrwCpo:aCols[oBrwCpo:nAt,064] + chr(13) + chr(10) + ;
                          "Data Início Turno.............: " + oBrwCpo:aCols[oBrwCpo:nAt,065] + chr(13) + chr(10) + ;
                          "Hora Início Turno.............: " + oBrwCpo:aCols[oBrwCpo:nAt,066] + chr(13) + chr(10) + ;
                          "Data Fim Turno................: " + oBrwCpo:aCols[oBrwCpo:nAt,067] + chr(13) + chr(10) + ;
                          "Hora Fim Turno................: " + oBrwCpo:aCols[oBrwCpo:nAt,068] + chr(13) + chr(10)

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "METAS"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
                          "Data..........................: " + oBrwCpo:aCols[oBrwCpo:nAt,069] + chr(13) + chr(10) + ;
                          "ID Equipe.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,014] + chr(13) + chr(10) + ;
                          "Nome Equipe...................: " + oBrwCpo:aCols[oBrwCpo:nAt,015] + chr(13) + chr(10) + ;
                          "ID Tipo Equipe................: " + oBrwCpo:aCols[oBrwCpo:nAt,016] + chr(13) + chr(10) + ;
                          "Tipo Equipe...................: " + oBrwCpo:aCols[oBrwCpo:nAt,017] + chr(13) + chr(10) + ;
                          "Matrícula Eletricista.........: " + oBrwCpo:aCols[oBrwCpo:nAt,070] + chr(13) + chr(10) + ;
                          "Nome Eletricista..............: " + oBrwCpo:aCols[oBrwCpo:nAt,071] + chr(13) + chr(10) + ;
                          "Matrícula Parceiro............: " + oBrwCpo:aCols[oBrwCpo:nAt,072] + chr(13) + chr(10) + ;
                          "Nome Parceiro.................: " + oBrwCpo:aCols[oBrwCpo:nAt,073] + chr(13) + chr(10) + ;
                          "ID Contrato...................: " + oBrwCpo:aCols[oBrwCpo:nAt,030] + chr(13) + chr(10) + ;
                          "Contrato......................: " + oBrwCpo:aCols[oBrwCpo:nAt,031] + chr(13) + chr(10) + ;
                          "ID Centro Serviço.............: " + oBrwCpo:aCols[oBrwCpo:nAt,032] + chr(13) + chr(10) + ;
                          "Centro Serviço................: " + oBrwCpo:aCols[oBrwCpo:nAt,033] + chr(13) + chr(10) + ;
                          "Meta Valor Dia................: " + oBrwCpo:aCols[oBrwCpo:nAt,074] + chr(13) + chr(10) + ;
                          "Realizado Valor Dia...........: " + oBrwCpo:aCols[oBrwCpo:nAt,075] + chr(13) + chr(10) + ;
                          "Observação....................: " + oBrwCpo:aCols[oBrwCpo:nAt,063] + chr(13) + chr(10) + ;
                          "Justificativa.................: " + oBrwCpo:aCols[oBrwCpo:nAt,076] + chr(13) + chr(10) + ;
                          "ID Turno......................: " + oBrwCpo:aCols[oBrwCpo:nAt,077] + chr(13) + chr(10) + ;
                          "ID Tipo Turno.................: " + oBrwCpo:aCols[oBrwCpo:nAt,078] + chr(13) + chr(10) + ;
                          "Tipo Turno....................: " + oBrwCpo:aCols[oBrwCpo:nAt,079] + chr(13) + chr(10) + ;
                          "Hora Início Turno.............: " + oBrwCpo:aCols[oBrwCpo:nAt,066] + chr(13) + chr(10) + ;
                          "Hora Fim Turno................: " + oBrwCpo:aCols[oBrwCpo:nAt,068] + chr(13) + chr(10)

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "INTERVALOS"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
                          "ID Turno......................: " + oBrwCpo:aCols[oBrwCpo:nAt,077] + chr(13) + chr(10) + ;
                          "ID Intervalo..................: " + oBrwCpo:aCols[oBrwCpo:nAt,080] + chr(13) + chr(10) + ;
                          "ID Motivo.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,081] + chr(13) + chr(10) + ;
                          "Motivo........................: " + oBrwCpo:aCols[oBrwCpo:nAt,082] + chr(13) + chr(10) + ;
                          "Data..........................: " + oBrwCpo:aCols[oBrwCpo:nAt,069] + chr(13) + chr(10) + ;
                          "Hora Início Intervalo.........: " + oBrwCpo:aCols[oBrwCpo:nAt,083] + chr(13) + chr(10) + ;
                          "Hora Fim Intervalo............: " + oBrwCpo:aCols[oBrwCpo:nAt,084] + chr(13) + chr(10) + ;
                          "Justificativa.................: " + oBrwCpo:aCols[oBrwCpo:nAt,076] + chr(13) + chr(10) + ;
                          "ID Equipe.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,014] + chr(13) + chr(10) + ;
                          "Nome Equipe...................: " + oBrwCpo:aCols[oBrwCpo:nAt,015] + chr(13) + chr(10) + ;
                          "ID Tipo Equipe................: " + oBrwCpo:aCols[oBrwCpo:nAt,016] + chr(13) + chr(10) + ;
                          "Tipo Equipe...................: " + oBrwCpo:aCols[oBrwCpo:nAt,017] + chr(13) + chr(10) + ;
                          "Matrícula Eletricista.........: " + oBrwCpo:aCols[oBrwCpo:nAt,070] + chr(13) + chr(10) + ;
                          "Nome Eletricista..............: " + oBrwCpo:aCols[oBrwCpo:nAt,071] + chr(13) + chr(10) + ;
                          "Matrícula Parceiro............: " + oBrwCpo:aCols[oBrwCpo:nAt,072] + chr(13) + chr(10) + ;
                          "Nome Parceiro.................: " + oBrwCpo:aCols[oBrwCpo:nAt,073] + chr(13) + chr(10) + ;
                          "ID Contrato...................: " + oBrwCpo:aCols[oBrwCpo:nAt,030] + chr(13) + chr(10) + ;
                          "Contrato......................: " + oBrwCpo:aCols[oBrwCpo:nAt,031] + chr(13) + chr(10) + ;
                          "ID Centro Serviço.............: " + oBrwCpo:aCols[oBrwCpo:nAt,032] + chr(13) + chr(10) + ;
                          "Centro Serviço................: " + oBrwCpo:aCols[oBrwCpo:nAt,033] + chr(13) + chr(10)

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "METAS PREVISTA"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
                          "ID Contrato...................: " + oBrwCpo:aCols[oBrwCpo:nAt,030] + chr(13) + chr(10) + ;
                          "Descrição do Contrato.........: " + oBrwCpo:aCols[oBrwCpo:nAt,085] + chr(13) + chr(10) + ;
                          "ID Equipe.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,014] + chr(13) + chr(10) + ;
                          "Descrição da Equipe...........: " + oBrwCpo:aCols[oBrwCpo:nAt,086] + chr(13) + chr(10) + ;
                          "Meta Prevista.................: " + oBrwCpo:aCols[oBrwCpo:nAt,087] + chr(13) + chr(10)

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "OBRAS"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
                          "Status........................: " + oBrwCpo:aCols[oBrwCpo:nAt,088] + chr(13) + chr(10) + ;
                          "Número Obra...................: " + oBrwCpo:aCols[oBrwCpo:nAt,089] + chr(13) + chr(10) + ;
                          "Descrição da Obra.............: " + oBrwCpo:aCols[oBrwCpo:nAt,090] + chr(13) + chr(10) + ;
                          "Regional......................: " + oBrwCpo:aCols[oBrwCpo:nAt,091] + chr(13) + chr(10) + ;
                          "Cidade........................: " + oBrwCpo:aCols[oBrwCpo:nAt,062] + chr(13) + chr(10) + ;
                          "Contrato......................: " + oBrwCpo:aCols[oBrwCpo:nAt,031] + chr(13) + chr(10) + ;
                          "Responsavel...................: " + oBrwCpo:aCols[oBrwCpo:nAt,092] + chr(13) + chr(10) + ;
                          "Data de Recebimento...........: " + oBrwCpo:aCols[oBrwCpo:nAt,093] + chr(13) + chr(10) + ;
                          "Início Execução Obra..........: " + oBrwCpo:aCols[oBrwCpo:nAt,094] + chr(13) + chr(10) + ;
                          "Fim Execução Obra.............: " + oBrwCpo:aCols[oBrwCpo:nAt,095] + chr(13) + chr(10) + ;
                          "Início Previsão da Obra.......: " + oBrwCpo:aCols[oBrwCpo:nAt,096] + chr(13) + chr(10) + ;
                          "Fim Previsão da Obra..........: " + oBrwCpo:aCols[oBrwCpo:nAt,097] + chr(13) + chr(10) + ;
                          "Data Energização..............: " + oBrwCpo:aCols[oBrwCpo:nAt,098] + chr(13) + chr(10) + ;
                          "Data Protocolo Faturamento....: " + oBrwCpo:aCols[oBrwCpo:nAt,098] + chr(13) + chr(10) + ;
                          "Data UF.......................: " + oBrwCpo:aCols[oBrwCpo:nAt,100] + chr(13) + chr(10) + ;
                          "Valor Previsão................: " + oBrwCpo:aCols[oBrwCpo:nAt,101] + chr(13) + chr(10) + ;
                          "Valor Real....................: " + oBrwCpo:aCols[oBrwCpo:nAt,102] + chr(13) + chr(10) + ;
                          "Valor Pago....................: " + oBrwCpo:aCols[oBrwCpo:nAt,103] + chr(13) + chr(10) + ;
                          "Qtd Postes Previstos..........: " + oBrwCpo:aCols[oBrwCpo:nAt,104] + chr(13) + chr(10) + ;
                          "Qtd Postes....................: " + oBrwCpo:aCols[oBrwCpo:nAt,105] + chr(13) + chr(10) + ;
                          "Código Obra...................: " + oBrwCpo:aCols[oBrwCpo:nAt,106] + chr(13) + chr(10) + ;
                          "Tipo de Obra..................: " + oBrwCpo:aCols[oBrwCpo:nAt,107] + chr(13) + chr(10) + ;
                          "Centro Serviço................: " + oBrwCpo:aCols[oBrwCpo:nAt,033] + chr(13) + chr(10) + ;
                          "Supervisor....................: " + oBrwCpo:aCols[oBrwCpo:nAt,108] + chr(13) + chr(10) + ;
                          "Número Pedido.................: " + oBrwCpo:aCols[oBrwCpo:nAt,109] + chr(13) + chr(10) + ;
                          "Data Pedido...................: " + oBrwCpo:aCols[oBrwCpo:nAt,110] + chr(13) + chr(10) + ;
                          "Latitude......................: " + oBrwCpo:aCols[oBrwCpo:nAt,111] + chr(13) + chr(10) + ;
                          "Longitude.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,112] + chr(13) + chr(10) + ;
                          "Fiscal Concessionária.........: " + oBrwCpo:aCols[oBrwCpo:nAt,113] + chr(13) + chr(10) + ;
                          "Nota Fiscal...................: " + oBrwCpo:aCols[oBrwCpo:nAt,114] + chr(13) + chr(10) + ;
                          "Data Documento................: " + oBrwCpo:aCols[oBrwCpo:nAt,115] + chr(13) + chr(10) + ;
                          "Vistoria Realizada............: " + oBrwCpo:aCols[oBrwCpo:nAt,116] + chr(13) + chr(10) + ;
                          "Observação....................: " + oBrwCpo:aCols[oBrwCpo:nAt,063] + chr(13) + chr(10) + ;
                          "Tipo de Serviço...............: " + oBrwCpo:aCols[oBrwCpo:nAt,117] + chr(13) + chr(10) + ;
                          "Código Estoque................: " + oBrwCpo:aCols[oBrwCpo:nAt,118] + chr(13) + chr(10)

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "OBRAS ATIVIDADES"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
			              "Número Obra...................: " + oBrwCpo:aCols[oBrwCpo:nAt,089] + chr(13) + chr(10) + ;
                          "Número Obra Principal.........: " + oBrwCpo:aCols[oBrwCpo:nAt,061] + chr(13) + chr(10) + ;
                          "Código Precificação...........: " + oBrwCpo:aCols[oBrwCpo:nAt,119] + chr(13) + chr(10) + ;
                          "Descrição Precificação........: " + oBrwCpo:aCols[oBrwCpo:nAt,120] + chr(13) + chr(10) + ;
                          "Unidade.......................: " + oBrwCpo:aCols[oBrwCpo:nAt,121] + chr(13) + chr(10) + ;
					      "Quantidade....................: " + oBrwCpo:aCols[oBrwCpo:nAt,043] + chr(13) + chr(10)

      Case Alltrim(oBrwCpo:aCols[oBrwCpo:nAt,003]) == "OBRAS MATERIAIS"
      
              cDetalhe := "Seq...........................: " + oBrwCpo:aCols[oBrwCpo:nAt,002] + chr(13) + chr(10) + ;
                          "Grupo.........................: " + oBrwCpo:aCols[oBrwCpo:nAt,003] + chr(13) + chr(10) + ;
			              "Número Obra...................: " + oBrwCpo:aCols[oBrwCpo:nAt,089] + chr(13) + chr(10) + ;
                          "Número Obra Principal.........: " + oBrwCpo:aCols[oBrwCpo:nAt,061] + chr(13) + chr(10) + ;
                          "Material......................: " + oBrwCpo:aCols[oBrwCpo:nAt,122] + chr(13) + chr(10) + ;
                          "Situacao......................: " + oBrwCpo:aCols[oBrwCpo:nAt,123] + chr(13) + chr(10) + ;
                          "Unidade.......................: " + oBrwCpo:aCols[oBrwCpo:nAt,121] + chr(13) + chr(10) + ;
                          "Orçado Concessionária.........: " + oBrwCpo:aCols[oBrwCpo:nAt,124] + chr(13) + chr(10) + ;
                          "orçado Validado...............: " + oBrwCpo:aCols[oBrwCpo:nAt,125] + chr(13) + chr(10) + ;
                          "Processada....................: " + oBrwCpo:aCols[oBrwCpo:nAt,126] + chr(13) + chr(10) + ;
                          "A Separar.....................: " + oBrwCpo:aCols[oBrwCpo:nAt,127] + chr(13) + chr(10) + ;
                          "Aplicada......................: " + oBrwCpo:aCols[oBrwCpo:nAt,128] + chr(13) + chr(10) + ;
                          "Devolver......................: " + oBrwCpo:aCols[oBrwCpo:nAt,129] + chr(13) + chr(10) + ;
                          "Data Pedido...................: " + oBrwCpo:aCols[oBrwCpo:nAt,110] + chr(13) + chr(10) + ;
                          "Usuário.......................: " + oBrwCpo:aCols[oBrwCpo:nAt,130] + chr(13) + chr(10)

   EndCase

   DEFINE MSDIALOG oDlgDetalhes TITLE "Importação Arquivos GPM - Geração de OS" FROM C(178),C(181) TO C(613),C(670) PIXEL

   @ C(005),C(005) Say "Detalhes do registro selecionado" Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlgDetalhes
   @ C(014),C(005) GET oDetalhe Var cDetalhe MEMO         Size C(235),C(182) Font oFont10c   PIXEL OF oDlgDetalhes
   @ C(199),C(103) Button "Voltar"                        Size C(037),C(012)                 PIXEL OF oDlgDetalhes ACTION( oDlgDetalhes:End() )

   ACTIVATE MSDIALOG oDlgDetalhes CENTERED 
   
Return(.T.)
            
// Função que gera o resultado do grid em excel
Static Function kSaidaGridExcel()

   Local aCabExcel   :={}
   Local aItensExcel :={} 
   Local nContar     := 0
   
   // Verifica se o excel está instalado no equipamento
   If ! ApOleClient( 'MsExcel' )
      MsgAlert("Atenção!" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Microsoft Excel não instalado neste equipamento!")
	  Return(.T.)
   EndIf

   // Verifica se existem informações a serem geradas em Excel
   lTemRegistro := .F.
    
   For nContar = 1 to Len(oBrwCpo:aCols)
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,002]))
          lTemRegistro := .T.
          Exit
       Endif
   Next nContar       
                                                   
   If lTemRegistro == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não existem registros disponíveis para geração de Planilha Excel.")
      Return(.T.)
   Endif

   // Colunas para a Tag SERVICOS
   aAdd( aCabExcel , {"Seq"                          , 'C', 03, 00 }) // 002
   aAdd( aCabExcel , {"Grupo"                        , 'C', 20, 00 }) // 003
   aAdd( aCabExcel , {"ID Nota"                      , 'C', 20, 00 }) // 004
   aAdd( aCabExcel , {"Número Nota"                  , 'C', 20, 00 }) // 005
   aAdd( aCabExcel , {"ID Tipo Serviço"              , 'C', 20, 00 }) // 006
   aAdd( aCabExcel , {"Tipo Serviço"                 , 'C', 20, 00 }) // 007
   aAdd( aCabExcel , {"Origem Sistema"               , 'C', 20, 00 }) // 008
   aAdd( aCabExcel , {"Origem Serviço"               , 'C', 20, 00 }) // 009
   aAdd( aCabExcel , {"Matrícula Coordenador"        , 'C', 30, 00 }) // 010
   aAdd( aCabExcel , {"Nome Coordenador"             , 'C', 30, 00 }) // 011
   aAdd( aCabExcel , {"Matrícula Supervisor"         , 'C', 20, 00 }) // 012
   aAdd( aCabExcel , {"Nome Supervisor"              , 'C', 30, 00 }) // 013
   aAdd( aCabExcel , {"ID Equipe"                    , 'C', 20, 00 }) // 014
   aAdd( aCabExcel , {"Nome Equipe"                  , 'C', 30, 00 }) // 015
   aAdd( aCabExcel , {"ID Tipo Equipe"               , 'C', 20, 00 }) // 016
   aAdd( aCabExcel , {"Tipo Equipe"                  , 'C', 20, 00 }) // 017
   aAdd( aCabExcel , {"Matrícula Funcionário 1"      , 'C', 20, 00 }) // 018
   aAdd( aCabExcel , {"Nome Funcionário 1"           , 'C', 30, 00 }) // 019
   aAdd( aCabExcel , {"Matrícula Funcionário 2"      , 'C', 20, 00 }) // 020
   aAdd( aCabExcel , {"Nome Funcionário 2"           , 'C', 30, 00 }) // 021
   aAdd( aCabExcel , {"Matrícula Funcionário 3"      , 'C', 20, 00 }) // 022
   aAdd( aCabExcel , {"Nome Funcionário 3"           , 'C', 30, 00 }) // 023
   aAdd( aCabExcel , {"Matrícula Funcionário 4"      , 'C', 20, 00 }) // 024
   aAdd( aCabExcel , {"Nome Funcionário 4"           , 'C', 30, 00 }) // 025
   aAdd( aCabExcel , {"Matrícula Funcionário 5"      , 'C', 20, 00 }) // 026
   aAdd( aCabExcel , {"Nome Funcionário 5"           , 'C', 30, 00 }) // 027
   aAdd( aCabExcel , {"Matrícula Funcionário 6"      , 'C', 20, 00 }) // 028
   aAdd( aCabExcel , {"Nome Funcionário 6"           , 'C', 30, 00 }) // 029
   aAdd( aCabExcel , {"IF Contrato"                  , 'C', 20, 00 }) // 030
   aAdd( aCabExcel , {"Contrato"                     , 'C', 20, 00 }) // 031
   aAdd( aCabExcel , {"IF Centro Serviço"            , 'C', 20, 00 }) // 032
   aAdd( aCabExcel , {"Centro Serviço"               , 'C', 30, 00 }) // 033
   aAdd( aCabExcel , {"IF Veículo"                   , 'C', 20, 00 }) // 034
   aAdd( aCabExcel , {"Placa Veículo"                , 'C', 10, 00 }) // 035
   aAdd( aCabExcel , {"IF Tipo Veículo"              , 'C', 20, 00 }) // 036
   aAdd( aCabExcel , {"Tipo Veículo"                 , 'C', 20, 00 }) // 037
   aAdd( aCabExcel , {"KM Inicial"                   , 'C', 10, 00 }) // 038
   aAdd( aCabExcel , {"KM Final"                     , 'C', 10, 00 }) // 039
   aAdd( aCabExcel , {"IF Serviço"                   , 'C', 20, 00 }) // 040
   aAdd( aCabExcel , {"Código Serviço"               , 'C', 30, 00 }) // 041
   aAdd( aCabExcel , {"Descrição Serviço"            , 'C', 30, 00 }) // 042
   aAdd( aCabExcel , {"Quantidade"                   , 'C', 15, 00 }) // 043
   aAdd( aCabExcel , {"Valor Total Serviço"          , 'C', 15, 00 }) // 044
   aAdd( aCabExcel , {"Data Comunicação"             , 'C', 10, 00 }) // 045
   aAdd( aCabExcel , {"Hora Comunicação"             , 'C', 10, 00 }) // 046
   aAdd( aCabExcel , {"Data Início Deslocamento"     , 'C', 10, 00 }) // 047
   aAdd( aCabExcel , {"Hora Início Deslocamento"     , 'C', 10, 00 }) // 048
   aAdd( aCabExcel , {"Data Chegada Local"           , 'C', 10, 00 }) // 049
   aAdd( aCabExcel , {"Hora Chegada Local"           , 'C', 10, 00 }) // 050
   aAdd( aCabExcel , {"Data Início Serviço"          , 'C', 10, 00 }) // 051
   aAdd( aCabExcel , {"Hora Início Serviço"          , 'C', 10, 00 }) // 052
   aAdd( aCabExcel , {"Data Término Serviço"         , 'C', 10, 00 }) // 053
   aAdd( aCabExcel , {"Hora Término Serviço"         , 'C', 10, 00 }) // 054
   aAdd( aCabExcel , {"Latitude Início Deslocamento" , 'C', 15, 00 }) // 055
   aAdd( aCabExcel , {"Longitude Início Deslocamento", 'C', 15, 00 }) // 056
   aAdd( aCabExcel , {"Latitude Início Serviço"      , 'C', 15, 00 }) // 057
   aAdd( aCabExcel , {"Longitude Início Serviço"     , 'C', 15, 00 }) // 058
   aAdd( aCabExcel , {"ID Obra"                      , 'C', 20, 00 }) // 059
   aAdd( aCabExcel , {"E PEP"                        , 'C', 20, 00 }) // 060
   aAdd( aCabExcel , {"Número Obra Principal"        , 'C', 20, 00 }) // 061
   aAdd( aCabExcel , {"Cidade"                       , 'C', 30, 00 }) // 062
   aAdd( aCabExcel , {"Observação"                   , 'C',250, 00 }) // 063
   aAdd( aCabExcel , {"Tipo de Serviço"              , 'C', 20, 00 }) // 064
   aAdd( aCabExcel , {"Data Início Turno"            , 'C', 10, 00 }) // 065
   aAdd( aCabExcel , {"Hora Início Turno"            , 'C', 10, 00 }) // 066
   aAdd( aCabExcel , {"Data Fim Turno"               , 'C', 10, 00 }) // 067
   aAdd( aCabExcel , {"Hora Fim Turno"               , 'C', 10, 00 }) // 068

   // Colunas para a Tag METAS                                                    
   aAdd( aCabExcel , {"Data"                         , 'C',  10, 00}) // 069
   aAdd( aCabExcel , {"Matrícula Eletricista"        , 'C',  20, 00}) // 070
   aAdd( aCabExcel , {"Nome Eletricista"             , 'C',  30, 00}) // 071
   aAdd( aCabExcel , {"matrícula Parceiro"           , 'C',  20, 00}) // 072
   aAdd( aCabExcel , {"Nome Parceiro"                , 'C',  30, 00}) // 073
   aAdd( aCabExcel , {"Meta Valor Dia"               , 'C',  15, 00}) // 074
   aAdd( aCabExcel , {"Realizado Valor Dia"          , 'C',  15, 00}) // 075
   aAdd( aCabExcel , {"Justificativa"                , 'C', 250, 00}) // 076
   aAdd( aCabExcel , {"ID Turno"                     , 'C',  20, 00}) // 077
   aAdd( aCabExcel , {"ID Tipo Turno"                , 'C',  20, 00}) // 078
   aAdd( aCabExcel , {"Tipo Turno"                   , 'C',  20, 00}) // 079

   // Colunas para a Tag INTERVALOS
   aAdd( aCabExcel , {"IF Intervalo"                 , 'C',  20, 00}) // 080
   aAdd( aCabExcel , {"ID Motivo"                    , 'C',  20, 00}) // 081
   aAdd( aCabExcel , {"Motivo"                       , 'C', 250, 00}) // 082
   aAdd( aCabExcel , {"Hora Início Intervalo"        , 'C',  10, 00}) // 083
   aAdd( aCabExcel , {"Hora Fim Intervalo"           , 'C',  10, 00}) // 084
   
   // Colunas para a Tag METAS PREVISTA
   aAdd( aCabExcel , {"Descrição do Contrato"        , 'C',  30, 00}) // 085
   aAdd( aCabExcel , {"Descrição da Equipe"          , 'C',  30, 00}) // 086
   aAdd( aCabExcel , {"Meta Prevista"                , 'C',  15, 00}) // 087
   
   // Colunas para a Tag OBRAS
   aAdd( aCabExcel , {"Status"                       , 'C',  20, 00}) // 088
   aAdd( aCabExcel , {"Número Obra"                  , 'C',  20, 00}) // 089
   aAdd( aCabExcel , {"Descrição da Obra"            , 'C',  60, 00}) // 090
   aAdd( aCabExcel , {"Regional"                     , 'C',  30, 00}) // 091
   aAdd( aCabExcel , {"Responsavel"                  , 'C',  60, 00}) // 092
   aAdd( aCabExcel , {"Data de Recebimento"          , 'C',  10, 00}) // 093
   aAdd( aCabExcel , {"Início Execução Obra"         , 'C',  10, 00}) // 094
   aAdd( aCabExcel , {"Fim Execução Obra"            , 'C',  10, 00}) // 095
   aAdd( aCabExcel , {"Início Previsão da Obra"      , 'C',  10, 00}) // 096
   aAdd( aCabExcel , {"Fim Previsão da Obra"         , 'C',  10, 00}) // 097
   aAdd( aCabExcel , {"Data Energização"             , 'C',  10, 00}) // 098
   aAdd( aCabExcel , {"Data Protocolo Faturamento"   , 'C',  10, 00}) // 098
   aAdd( aCabExcel , {"Data UF"                      , 'C',  10, 00}) // 100
   aAdd( aCabExcel , {"Valor Previsão"               , 'C',  15, 00}) // 101
   aAdd( aCabExcel , {"Valor Real"                   , 'C',  15, 00}) // 102
   aAdd( aCabExcel , {"Valor Pago"                   , 'C',  15, 00}) // 103
   aAdd( aCabExcel , {"Qtd Postes Previstos"         , 'C',  10, 00}) // 104
   aAdd( aCabExcel , {"Qtd Postes"                   , 'C',  10, 00}) // 105
   aAdd( aCabExcel , {"Código Obra"                  , 'C',  15, 00}) // 106
   aAdd( aCabExcel , {"Tipo de Obra"                 , 'C',  30, 00}) // 107
   aAdd( aCabExcel , {"Supervisor"                   , 'C',  60, 00}) // 108
   aAdd( aCabExcel , {"Número Pedido"                , 'C',  20, 00}) // 109
   aAdd( aCabExcel , {"Data Pedido"                  , 'C',  10, 00}) // 110
   aAdd( aCabExcel , {"Latitude"                     , 'C',  15, 00}) // 111
   aAdd( aCabExcel , {"Longitude"                    , 'C',  15, 00}) // 112
   aAdd( aCabExcel , {"Fiscal Concessionaria"        , 'C',  60, 00}) // 113
   aAdd( aCabExcel , {"Nota Fiscal"                  , 'C',  20, 00}) // 114
   aAdd( aCabExcel , {"Data Documento"               , 'C',  10, 00}) // 115
   aAdd( aCabExcel , {"Vistoria Realizada"           , 'C',  15, 00}) // 116
   aAdd( aCabExcel , {"Tipo de Serviço"              , 'C',  20, 00}) // 117
   aAdd( aCabExcel , {"Código Estoque"               , 'C',  20, 00}) // 118

   // Colunas para a Tag OBRAS ATIVIDADES
   aAdd( aCabExcel , {"Código Precificação"          , 'C',  20, 00}) // 119 
   aAdd( aCabExcel , {"Descrição Precificação"       , 'C',  60, 00}) // 120
   aAdd( aCabExcel , {"Unidade"                      , 'C',  10, 00}) // 121
                                                                                                                   
   // Colunas para a Tag OBRAS MATERIAIS
   aAdd( aCabExcel , {"Material"                     , 'C',  60, 00}) // 122 
   aAdd( aCabExcel , {"Situacao"                     , 'C',  30, 00}) // 123
   aAdd( aCabExcel , {"Orçado Concessionaria"        , 'C',  15, 00}) // 124
   aAdd( aCabExcel , {"orçado Validado"              , 'C',  15, 00}) // 125
   aAdd( aCabExcel , {"Processada"                   , 'C',  15, 00}) // 126
   aAdd( aCabExcel , {"A Separar"                    , 'C',  15, 00}) // 127
   aAdd( aCabExcel , {"Aplicada"                     , 'C',  15, 00}) // 128
   aAdd( aCabExcel , {"Devolver"                     , 'C',  15, 00}) // 129
   aAdd( aCabExcel , {"Usuário"                      , 'C',  30, 00}) // 130

   // Finalização da linh apara o Excel
   aAdd( aCabExcel , {" "                            , 'C',  01, 00}) // 131
   
   MsgRun("Aguarde! Preparando Dados ..."     , "Selecionando os Registros", {|| kkSaidaGridExcel(aCabExcel, @aItensExcel)})
   MsgRun("Aguarde! Gerando Arquivo Excel ...", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","REGISTROS DE LOG DE IMPORTAÇÃO DE OS - GPM", aCabExcel,aItensExcel}})})

Return(.T.)

// Função que gera o arquivo Excel dos registros selecionados
Static Function kkSaidaGridExcel(aHeader, aCols)

   Local nContar := 0
   
   For nContar = 1 to Len(oBrwCpo:aCols)

       aAdd( aCols, {oBrwCpo:aCols[nContar,002] ,;
                     oBrwCpo:aCols[nContar,003] ,;
                     oBrwCpo:aCols[nContar,004] ,;
                     oBrwCpo:aCols[nContar,005] ,;
                     oBrwCpo:aCols[nContar,006] ,;
                     oBrwCpo:aCols[nContar,007] ,;
                     oBrwCpo:aCols[nContar,008] ,;
                     oBrwCpo:aCols[nContar,009] ,;
                     oBrwCpo:aCols[nContar,010] ,;
                     oBrwCpo:aCols[nContar,011] ,;
                     oBrwCpo:aCols[nContar,012] ,;
                     oBrwCpo:aCols[nContar,013] ,;
                     oBrwCpo:aCols[nContar,014] ,;
                     oBrwCpo:aCols[nContar,015] ,;
                     oBrwCpo:aCols[nContar,016] ,;
                     oBrwCpo:aCols[nContar,017] ,;
                     oBrwCpo:aCols[nContar,018] ,;
                     oBrwCpo:aCols[nContar,019] ,;
                     oBrwCpo:aCols[nContar,020] ,;
                     oBrwCpo:aCols[nContar,021] ,;
                     oBrwCpo:aCols[nContar,022] ,;
                     oBrwCpo:aCols[nContar,023] ,;
                     oBrwCpo:aCols[nContar,024] ,;
                     oBrwCpo:aCols[nContar,025] ,;
                     oBrwCpo:aCols[nContar,026] ,;
                     oBrwCpo:aCols[nContar,027] ,;
                     oBrwCpo:aCols[nContar,028] ,;
                     oBrwCpo:aCols[nContar,029] ,;
                     oBrwCpo:aCols[nContar,030] ,;
                     oBrwCpo:aCols[nContar,031] ,;
                     oBrwCpo:aCols[nContar,032] ,;
                     oBrwCpo:aCols[nContar,033] ,;
                     oBrwCpo:aCols[nContar,034] ,;
                     oBrwCpo:aCols[nContar,035] ,;
                     oBrwCpo:aCols[nContar,036] ,;
                     oBrwCpo:aCols[nContar,037] ,;
                     oBrwCpo:aCols[nContar,038] ,;
                     oBrwCpo:aCols[nContar,039] ,;
                     oBrwCpo:aCols[nContar,040] ,;
                     oBrwCpo:aCols[nContar,041] ,;
                     oBrwCpo:aCols[nContar,042] ,;
                     oBrwCpo:aCols[nContar,043] ,;
                     oBrwCpo:aCols[nContar,044] ,;
                     oBrwCpo:aCols[nContar,045] ,;
                     oBrwCpo:aCols[nContar,046] ,;
                     oBrwCpo:aCols[nContar,047] ,;
                     oBrwCpo:aCols[nContar,048] ,;
                     oBrwCpo:aCols[nContar,049] ,;
                     oBrwCpo:aCols[nContar,050] ,;
                     oBrwCpo:aCols[nContar,051] ,;
                     oBrwCpo:aCols[nContar,052] ,;
                     oBrwCpo:aCols[nContar,053] ,;
                     oBrwCpo:aCols[nContar,054] ,;
                     oBrwCpo:aCols[nContar,055] ,;
                     oBrwCpo:aCols[nContar,056] ,;
                     oBrwCpo:aCols[nContar,057] ,;
                     oBrwCpo:aCols[nContar,058] ,;
                     oBrwCpo:aCols[nContar,059] ,;
                     oBrwCpo:aCols[nContar,060] ,;
                     oBrwCpo:aCols[nContar,061] ,;
                     oBrwCpo:aCols[nContar,062] ,;
                     oBrwCpo:aCols[nContar,063] ,;
                     oBrwCpo:aCols[nContar,064] ,;
                     oBrwCpo:aCols[nContar,065] ,;
                     oBrwCpo:aCols[nContar,066] ,;
                     oBrwCpo:aCols[nContar,067] ,;
                     oBrwCpo:aCols[nContar,068] ,;
                     oBrwCpo:aCols[nContar,069] ,;
                     oBrwCpo:aCols[nContar,070] ,;
                     oBrwCpo:aCols[nContar,071] ,;
                     oBrwCpo:aCols[nContar,072] ,;
                     oBrwCpo:aCols[nContar,073] ,;
                     oBrwCpo:aCols[nContar,074] ,;
                     oBrwCpo:aCols[nContar,075] ,;
                     oBrwCpo:aCols[nContar,076] ,;
                     oBrwCpo:aCols[nContar,077] ,;
                     oBrwCpo:aCols[nContar,078] ,;
                     oBrwCpo:aCols[nContar,079] ,;
                     oBrwCpo:aCols[nContar,080] ,;
                     oBrwCpo:aCols[nContar,081] ,;
                     oBrwCpo:aCols[nContar,082] ,;
                     oBrwCpo:aCols[nContar,083] ,;
                     oBrwCpo:aCols[nContar,084] ,;
                     oBrwCpo:aCols[nContar,085] ,;
                     oBrwCpo:aCols[nContar,086] ,;
                     oBrwCpo:aCols[nContar,087] ,;
                     oBrwCpo:aCols[nContar,088] ,;
                     oBrwCpo:aCols[nContar,089] ,;
                     oBrwCpo:aCols[nContar,090] ,;
                     oBrwCpo:aCols[nContar,091] ,;
                     oBrwCpo:aCols[nContar,092] ,;
                     oBrwCpo:aCols[nContar,093] ,;
                     oBrwCpo:aCols[nContar,094] ,;
                     oBrwCpo:aCols[nContar,095] ,;
                     oBrwCpo:aCols[nContar,096] ,;
                     oBrwCpo:aCols[nContar,097] ,;
                     oBrwCpo:aCols[nContar,098] ,;
                     oBrwCpo:aCols[nContar,099] ,;
                     oBrwCpo:aCols[nContar,100] ,;
                     oBrwCpo:aCols[nContar,101] ,;
                     oBrwCpo:aCols[nContar,102] ,;
                     oBrwCpo:aCols[nContar,103] ,;
                     oBrwCpo:aCols[nContar,104] ,;
                     oBrwCpo:aCols[nContar,105] ,;
                     oBrwCpo:aCols[nContar,106] ,;
                     oBrwCpo:aCols[nContar,107] ,;
                     oBrwCpo:aCols[nContar,108] ,;
                     oBrwCpo:aCols[nContar,109] ,;
                     oBrwCpo:aCols[nContar,110] ,;
                     oBrwCpo:aCols[nContar,111] ,;
                     oBrwCpo:aCols[nContar,112] ,;
                     oBrwCpo:aCols[nContar,113] ,;
                     oBrwCpo:aCols[nContar,114] ,;
                     oBrwCpo:aCols[nContar,115] ,;
                     oBrwCpo:aCols[nContar,116] ,;
                     oBrwCpo:aCols[nContar,117] ,;
                     oBrwCpo:aCols[nContar,118] ,;
                     oBrwCpo:aCols[nContar,119] ,;
                     oBrwCpo:aCols[nContar,120] ,;
                     oBrwCpo:aCols[nContar,121] ,;
                     oBrwCpo:aCols[nContar,122] ,;
                     oBrwCpo:aCols[nContar,123] ,;
                     oBrwCpo:aCols[nContar,124] ,;
                     oBrwCpo:aCols[nContar,125] ,;
                     oBrwCpo:aCols[nContar,126] ,;
                     oBrwCpo:aCols[nContar,127] ,;
                     oBrwCpo:aCols[nContar,128] ,;
                     oBrwCpo:aCols[nContar,129] ,;
                     oBrwCpo:aCols[nContar,130] ,;
                     ""                         })
   Next nContar

Return(.T.)                  
                                
// Função que gera o resultado do grid em arquivo CSV
Static Function xGeraGridCSV()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
      
   Private cCaminho := Space(250)
   Private cArquivo := Space(060)

   Private oGet1
   Private oGet2

   Private oDlgCSV

   // Verifica se existem informações a serem geradas em Excel
   lTemRegistro := .F.
    
   For nContar = 1 to Len(oBrwCpo:aCols)
       If !Empty(Alltrim(oBrwCpo:aCols[nContar,002]))
          lTemRegistro := .T.
          Exit
       Endif
   Next nContar       
                                                   
   If lTemRegistro == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Não existem registros disponíveis para geração de Arquivo CSV.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgCSV TITLE "Gera Consulta em Arquivo CSV" FROM C(178),C(181) TO C(285),C(685) PIXEL

   @ C(005),C(005) Say "Informe o caminho a ser salvo o arquivo CSV" Size C(109),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV
   @ C(027),C(005) Say "Nome do arquivo a ser salvo"                 Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgCSV

   @ C(014),C(005) MsGet oGet1 Var cCaminho Size C(225),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV
   @ C(036),C(005) MsGet oGet2 Var cArquivo Size C(068),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCSV

   @ C(014),C(233) Button "..."          Size C(013),C(010) PIXEL OF oDlgCSV ACTION( xCaptaCaminho() )
   @ C(033),C(128) Button "Salvar"       Size C(037),C(012) PIXEL OF oDlgCSV ACTION( xGravaGridCSV(cArquivo ) )
   @ C(033),C(167) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlgCSV ACTION( oDlgCSV:End() )

   ACTIVATE MSDIALOG oDlgCSV CENTERED 

Return(.T.)

// Função que seleciona o diretório para gravação do arquivo CSV
Static Function xCaptaCaminho()

   cCaminho := cGetFile( ".", "Selecione o Diretório",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY )
   
Return(.T.)

// Função que gera o arquivo CSV para gravação
Static Function xGravaGridCSV(cArquivo)

   Local nContar   := 0
   Local cString   := ""
   Local lPrimeiro := .T.

   If Empty(Alltrim(cCaminho))
      MsgAlert("Caminho para gravação do arquivo CSV não informado.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cArquivo))
      MsgAlert("Nome do arquivo para gravação não informado.")
      Return(.T.)
   Endif

   If U_P_OCCURS(cArquivo, ".CSV", 1) == 0
      cArquivo := Alltrim(cArquivo) + ".CSV"
   Endif   

   nHdl := fCreate(Alltrim(cCaminho) + Alltrim(cArquivo))

   cString := ""

   For nContar = 1 to Len(oBrwCpo:aCols)        

       If lPrimeiro == .T.

          cString := "Registros arquivo de impportação de OS - GPM: " + Alltrim(cArquivo) + ";" + chr(13) + chr(10) + chr(13) + chr(10)
          
          fWrite (nHdl, cString ) 

          cString := "Seq"                          + ";" + ; // 002
                     "Grupo"                        + ";" + ; // 003
                     "ID Nota"                      + ";" + ; // 004
                     "Número Nota"                  + ";" + ; // 005
                     "ID Tipo Serviço"              + ";" + ; // 006
                     "Tipo Serviço"                 + ";" + ; // 007
                     "Origem Sistema"               + ";" + ; // 008
                     "Origem Serviço"               + ";" + ; // 009
                     "Matrícula Coordenador"        + ";" + ; // 010
                     "Nome Coordenador"             + ";" + ; // 011
                     "Matrícula Supervisor"         + ";" + ; // 012
                     "Nome Supervisor"              + ";" + ; // 013
                     "ID Equipe"                    + ";" + ; // 014
                     "Nome Equipe"                  + ";" + ; // 015
                     "ID Tipo Equipe"               + ";" + ; // 016
                     "Tipo Equipe"                  + ";" + ; // 017
                     "Matrícula Funcionário 1"      + ";" + ; // 018
                     "Nome Funcionário 1"           + ";" + ; // 019
                     "Matrícula Funcionário 2"      + ";" + ; // 020
                     "Nome Funcionário 2"           + ";" + ; // 021
                     "Matrícula Funcionário 3"      + ";" + ; // 022
                     "Nome Funcionário 3"           + ";" + ; // 023
                     "Matrícula Funcionário 4"      + ";" + ; // 024
                     "Nome Funcionário 4"           + ";" + ; // 025
                     "Matrícula Funcionário 5"      + ";" + ; // 026
                     "Nome Funcionário 5"           + ";" + ; // 027
                     "Matrícula Funcionário 6"      + ";" + ; // 028
                     "Nome Funcionário 6"           + ";" + ; // 029
                     "IF Contrato"                  + ";" + ; // 030
                     "Contrato"                     + ";" + ; // 031
                     "IF Centro Serviço"            + ";" + ; // 032
                     "Centro Serviço"               + ";" + ; // 033
                     "IF Veículo"                   + ";" + ; // 034
                     "Placa Veículo"                + ";" + ; // 035
                     "IF Tipo Veículo"              + ";" + ; // 036
                     "Tipo Veículo"                 + ";" + ; // 037
                     "KM Inicial"                   + ";" + ; // 038
                     "KM Final"                     + ";" + ; // 039
                     "IF Serviço"                   + ";" + ; // 040
                     "Código Serviço"               + ";" + ; // 041
                     "Descrição Serviço"            + ";" + ; // 042
                     "Quantidade"                   + ";" + ; // 043
                     "Valor Total Serviço"          + ";" + ; // 044
                     "Data Comunicação"             + ";" + ; // 045
                     "Hora Comunicação"             + ";" + ; // 046
                     "Data Início Deslocamento"     + ";" + ; // 047
                     "Hora Início Deslocamento"     + ";" + ; // 048
                     "Data Chegada Local"           + ";" + ; // 049
                     "Hora Chegada Local"           + ";" + ; // 050
                     "Data Início Serviço"          + ";" + ; // 051
                     "Hora Início Serviço"          + ";" + ; // 052
                     "Data Término Serviço"         + ";" + ; // 053
                     "Hora Término Serviço"         + ";" + ; // 054
                     "Latitude Início Deslocamento" + ";" + ; // 055
                     "Longitude Início Deslocamento"+ ";" + ; // 056
                     "Latitude Início Serviço"      + ";" + ; // 057
                     "Longitude Início Serviço"     + ";" + ; // 058
                     "ID Obra"                      + ";" + ; // 059
                     "E PEP"                        + ";" + ; // 060
                     "Número Obra Principal"        + ";" + ; // 061
                     "Cidade"                       + ";" + ; // 062
                     "Observação"                   + ";" + ; // 063
                     "Tipo de Serviço"              + ";" + ; // 064
                     "Data Início Turno"            + ";" + ; // 065
                     "Hora Início Turno"            + ";" + ; // 066
                     "Data Fim Turno"               + ";" + ; // 067
                     "Hora Fim Turno"               + ";" + ; // 068
                     "Data"                         + ";" + ; // 069
                     "Matrícula Eletricista"        + ";" + ; // 070
                     "Nome Eletricista"             + ";" + ; // 071
                     "matrícula Parceiro"           + ";" + ; // 072
                     "Nome Parceiro"                + ";" + ; // 073
                     "Meta Valor Dia"               + ";" + ; // 074
                     "Realizado Valor Dia"          + ";" + ; // 075
                     "Justificativa"                + ";" + ; // 076
                     "ID Turno"                     + ";" + ; // 077
                     "ID Tipo Turno"                + ";" + ; // 078
                     "Tipo Turno"                   + ";" + ; // 079
                     "IF Intervalo"                 + ";" + ; // 080
                     "ID Motivo"                    + ";" + ; // 081
                     "Motivo"                       + ";" + ; // 082
                     "Hora Início Intervalo"        + ";" + ; // 083
                     "Hora Fim Intervalo"           + ";" + ; // 084
                     "Descrição do Contrato"        + ";" + ; // 085
                     "Descrição da Equipe"          + ";" + ; // 086
                     "Meta Prevista"                + ";" + ; // 087
                     "Status"                       + ";" + ; // 088
                     "Número Obra"                  + ";" + ; // 089
                     "Descrição da Obra"            + ";" + ; // 090
                     "Regional"                     + ";" + ; // 091
                     "Responsavel"                  + ";" + ; // 092
                     "Data de Recebimento"          + ";" + ; // 093
                     "Início Execução Obra"         + ";" + ; // 094
                     "Fim Execução Obra"            + ";" + ; // 095
                     "Início Previsão da Obra"      + ";" + ; // 096
                     "Fim Previsão da Obra"         + ";" + ; // 097
                     "Data Energização"             + ";" + ; // 098
                     "Data Protocolo Faturamento"   + ";" + ; // 098
                     "Data UF"                      + ";" + ; // 100
                     "Valor Previsão"               + ";" + ; // 101
                     "Valor Real"                   + ";" + ; // 102
                     "Valor Pago"                   + ";" + ; // 103
                     "Qtd Postes Previstos"         + ";" + ; // 104
                     "Qtd Postes"                   + ";" + ; // 105
                     "Código Obra"                  + ";" + ; // 106
                     "Tipo de Obra"                 + ";" + ; // 107
                     "Supervisor"                   + ";" + ; // 108
                     "Número Pedido"                + ";" + ; // 109
                     "Data Pedido"                  + ";" + ; // 110
                     "Latitude"                     + ";" + ; // 111
                     "Longitude"                    + ";" + ; // 112
                     "Fiscal Concessionaria"        + ";" + ; // 113
                     "Nota Fiscal"                  + ";" + ; // 114
                     "Data Documento"               + ";" + ; // 115
                     "Vistoria Realizada"           + ";" + ; // 116
                     "Tipo de Serviço"              + ";" + ; // 117
                     "Código Estoque"               + ";" + ; // 118
                     "Código Precificação"          + ";" + ; // 119
                     "Descrição Precificação"       + ";" + ; // 120
                     "Unidade"                      + ";" + ; // 121
                     "Material"                     + ";" + ; // 122
                     "Situacao"                     + ";" + ; // 123
                     "Orçado Concessionaria"        + ";" + ; // 124
                     "orçado Validado"              + ";" + ; // 125
                     "Processada"                   + ";" + ; // 126
                     "A Separar"                    + ";" + ; // 127
                     "Aplicada"                     + ";" + ; // 128
                     "Devolver"                     + ";" + ; // 129
                     "Usuário"                      + chr(13) // 130

          lPrimeiro := .F.

          fWrite (nHdl, cString ) 

       Endif
       
       cString := oBrwCpo:aCols[nContar,002] + ";" + ;
                  oBrwCpo:aCols[nContar,003] + ";" + ;
                  oBrwCpo:aCols[nContar,004] + ";" + ;
                  oBrwCpo:aCols[nContar,005] + ";" + ;
                  oBrwCpo:aCols[nContar,006] + ";" + ;
                  oBrwCpo:aCols[nContar,007] + ";" + ;
                  oBrwCpo:aCols[nContar,008] + ";" + ;
                  oBrwCpo:aCols[nContar,009] + ";" + ;
                  oBrwCpo:aCols[nContar,010] + ";" + ;
                  oBrwCpo:aCols[nContar,011] + ";" + ;
                  oBrwCpo:aCols[nContar,012] + ";" + ;
                  oBrwCpo:aCols[nContar,013] + ";" + ;
                  oBrwCpo:aCols[nContar,014] + ";" + ;
                  oBrwCpo:aCols[nContar,015] + ";" + ;
                  oBrwCpo:aCols[nContar,016] + ";" + ;
                  oBrwCpo:aCols[nContar,017] + ";" + ;
                  oBrwCpo:aCols[nContar,018] + ";" + ;
                  oBrwCpo:aCols[nContar,019] + ";" + ;
                  oBrwCpo:aCols[nContar,020] + ";" + ;
                  oBrwCpo:aCols[nContar,021] + ";" + ;
                  oBrwCpo:aCols[nContar,022] + ";" + ;
                  oBrwCpo:aCols[nContar,023] + ";" + ;
                  oBrwCpo:aCols[nContar,024] + ";" + ;
                  oBrwCpo:aCols[nContar,025] + ";" + ;
                  oBrwCpo:aCols[nContar,026] + ";" + ;
                  oBrwCpo:aCols[nContar,027] + ";" + ;
                  oBrwCpo:aCols[nContar,028] + ";" + ;
                  oBrwCpo:aCols[nContar,029] + ";" + ;
                  oBrwCpo:aCols[nContar,030] + ";" + ;
                  oBrwCpo:aCols[nContar,031] + ";" + ;
                  oBrwCpo:aCols[nContar,032] + ";" + ;
                  oBrwCpo:aCols[nContar,033] + ";" + ;
                  oBrwCpo:aCols[nContar,034] + ";" + ;
                  oBrwCpo:aCols[nContar,035] + ";" + ;
                  oBrwCpo:aCols[nContar,036] + ";" + ;
                  oBrwCpo:aCols[nContar,037] + ";" + ;
                  oBrwCpo:aCols[nContar,038] + ";" + ;
                  oBrwCpo:aCols[nContar,039] + ";" + ;
                  oBrwCpo:aCols[nContar,040] + ";" + ;
                  oBrwCpo:aCols[nContar,041] + ";" + ;
                  oBrwCpo:aCols[nContar,042] + ";" + ;
                  oBrwCpo:aCols[nContar,043] + ";" + ;
                  oBrwCpo:aCols[nContar,044] + ";" + ;
                  oBrwCpo:aCols[nContar,045] + ";" + ;
                  oBrwCpo:aCols[nContar,046] + ";" + ;
                  oBrwCpo:aCols[nContar,047] + ";" + ;
                  oBrwCpo:aCols[nContar,048] + ";" + ;
                  oBrwCpo:aCols[nContar,049] + ";" + ;
                  oBrwCpo:aCols[nContar,050] + ";" + ;
                  oBrwCpo:aCols[nContar,051] + ";" + ;
                  oBrwCpo:aCols[nContar,052] + ";" + ;
                  oBrwCpo:aCols[nContar,053] + ";" + ;
                  oBrwCpo:aCols[nContar,054] + ";" + ;
                  oBrwCpo:aCols[nContar,055] + ";" + ;
                  oBrwCpo:aCols[nContar,056] + ";" + ;
                  oBrwCpo:aCols[nContar,057] + ";" + ;
                  oBrwCpo:aCols[nContar,058] + ";" + ;
                  oBrwCpo:aCols[nContar,059] + ";" + ;
                  oBrwCpo:aCols[nContar,060] + ";" + ;
                  oBrwCpo:aCols[nContar,061] + ";" + ;
                  oBrwCpo:aCols[nContar,062] + ";" + ;
                  oBrwCpo:aCols[nContar,063] + ";" + ;
                  oBrwCpo:aCols[nContar,064] + ";" + ;
                  oBrwCpo:aCols[nContar,065] + ";" + ;
                  oBrwCpo:aCols[nContar,066] + ";" + ;
                  oBrwCpo:aCols[nContar,067] + ";" + ;
                  oBrwCpo:aCols[nContar,068] + ";" + ;
                  oBrwCpo:aCols[nContar,069] + ";" + ;
                  oBrwCpo:aCols[nContar,070] + ";" + ;
                  oBrwCpo:aCols[nContar,071] + ";" + ;
                  oBrwCpo:aCols[nContar,072] + ";" + ;
                  oBrwCpo:aCols[nContar,073] + ";" + ;
                  oBrwCpo:aCols[nContar,074] + ";" + ;
                  oBrwCpo:aCols[nContar,075] + ";" + ;
                  oBrwCpo:aCols[nContar,076] + ";" + ;
                  oBrwCpo:aCols[nContar,077] + ";" + ;
                  oBrwCpo:aCols[nContar,078] + ";" + ;
                  oBrwCpo:aCols[nContar,079] + ";" + ;
                  oBrwCpo:aCols[nContar,080] + ";" + ;
                  oBrwCpo:aCols[nContar,081] + ";" + ;
                  oBrwCpo:aCols[nContar,082] + ";" + ;
                  oBrwCpo:aCols[nContar,083] + ";" + ;
                  oBrwCpo:aCols[nContar,084] + ";" + ;
                  oBrwCpo:aCols[nContar,085] + ";" + ;
                  oBrwCpo:aCols[nContar,086] + ";" + ;
                  oBrwCpo:aCols[nContar,087] + ";" + ;
                  oBrwCpo:aCols[nContar,088] + ";" + ;
                  oBrwCpo:aCols[nContar,089] + ";" + ;
                  oBrwCpo:aCols[nContar,090] + ";" + ;
                  oBrwCpo:aCols[nContar,091] + ";" + ;
                  oBrwCpo:aCols[nContar,092] + ";" + ;
                  oBrwCpo:aCols[nContar,093] + ";" + ;
                  oBrwCpo:aCols[nContar,094] + ";" + ;
                  oBrwCpo:aCols[nContar,095] + ";" + ;
                  oBrwCpo:aCols[nContar,096] + ";" + ;
                  oBrwCpo:aCols[nContar,097] + ";" + ;
                  oBrwCpo:aCols[nContar,098] + ";" + ;
                  oBrwCpo:aCols[nContar,099] + ";" + ;
                  oBrwCpo:aCols[nContar,100] + ";" + ;
                  oBrwCpo:aCols[nContar,101] + ";" + ;
                  oBrwCpo:aCols[nContar,102] + ";" + ;
                  oBrwCpo:aCols[nContar,103] + ";" + ;
                  oBrwCpo:aCols[nContar,104] + ";" + ;
                  oBrwCpo:aCols[nContar,105] + ";" + ;
                  oBrwCpo:aCols[nContar,106] + ";" + ;
                  oBrwCpo:aCols[nContar,107] + ";" + ;
                  oBrwCpo:aCols[nContar,108] + ";" + ;
                  oBrwCpo:aCols[nContar,109] + ";" + ;
                  oBrwCpo:aCols[nContar,110] + ";" + ;
                  oBrwCpo:aCols[nContar,111] + ";" + ;
                  oBrwCpo:aCols[nContar,112] + ";" + ;
                  oBrwCpo:aCols[nContar,113] + ";" + ;
                  oBrwCpo:aCols[nContar,114] + ";" + ;
                  oBrwCpo:aCols[nContar,115] + ";" + ;
                  oBrwCpo:aCols[nContar,116] + ";" + ;
                  oBrwCpo:aCols[nContar,117] + ";" + ;
                  oBrwCpo:aCols[nContar,118] + ";" + ;
                  oBrwCpo:aCols[nContar,119] + ";" + ;
                  oBrwCpo:aCols[nContar,120] + ";" + ;
                  oBrwCpo:aCols[nContar,121] + ";" + ;
                  oBrwCpo:aCols[nContar,122] + ";" + ;
                  oBrwCpo:aCols[nContar,123] + ";" + ;
                  oBrwCpo:aCols[nContar,124] + ";" + ;
                  oBrwCpo:aCols[nContar,125] + ";" + ;
                  oBrwCpo:aCols[nContar,126] + ";" + ;
                  oBrwCpo:aCols[nContar,127] + ";" + ;
                  oBrwCpo:aCols[nContar,128] + ";" + ;
                  oBrwCpo:aCols[nContar,129] + ";" + ;
                  oBrwCpo:aCols[nContar,130] + chr(13)

          fWrite (nHdl, cString ) 

   Next nContar

   fClose(nHdl)
         
   MsgAlert("Arquivo gerado com sucesso.")
         
   oDlgCSV:End()
   
Return(.T.)        
              
// Função que gera a importação dos dados Consistentes
Static Function ImportaDadosOS(_Arquivo, _Usuario, _Data)
                 
   Local cSql    := ""
   Local nContar := 0
                      
   If Select("T_GRAVACAO") > 0
      T_GRAVACAO->( dbCloseArea() )
   EndIf
                              
   cSql:= ""
   cSql := "SELECT Z20_SEQU  , Z20_GRUP  , Z20_IDNT  , Z20_NNOT  , Z20_IDTS  , Z20_TSR1  , Z20_OSIS  , Z20_OSRV  , Z20_MCOO  , Z20_NCOO  ," 
   cSql += "       Z20_MSUP  , Z20_NSUP  , Z20_IDEQ  , Z20_NEQU  , Z20_IDTE  , Z20_TEQU  , Z20_MF01  , Z20_NF01  , Z20_MF02  , Z20_NF02  ," 
   cSql += "       Z20_MF03  , Z20_NF03  , Z20_MF04  , Z20_NF04  , Z20_MF05  , Z20_NF05  , Z20_MF06  , Z20_NF06  , Z20_IDCT  , Z20_CONT  ," 
   cSql += "       Z20_IDCS  , Z20_CSER  , Z20_IDVE  , Z20_PLAC  , Z20_IDTV  , Z20_TVEI  , Z20_KMIN  , Z20_KMFM  , Z20_IDSR  , Z20_CSRV  ," 
   cSql += "       Z20_DSRV  , Z20_QUAN  , Z20_VSRV  , Z20_DCOM  , Z20_HCOM  , Z20_DIDS  , Z20_HIDS  , Z20_DCHL  , Z20_HCHL  , Z20_DISR  ," 
   cSql += "       Z20_HISR  , Z20_DTSR  , Z20_HTSR  , Z20_LIDS  , Z20_LOID  , Z20_LISR  , Z20_LOIS  , Z20_IDOB  , Z20_EPEP  , Z20_NOPR  ," 
   cSql += "       Z20_CIDA  , Z20_OBSE  , Z20_TSR1  , Z20_DITR  , Z20_HITR  , Z20_DFMT  , Z20_HFTR  , Z20_DATA  , Z20_MELE  , Z20_NELE  ," 
   cSql += "       Z20_MPAR  , Z20_NPAR  , Z20_MVLR  , Z20_RVDI  , Z20_JUST  , Z20_IDTN  , Z20_IDTT  , Z20_TTUR  , Z20_IDIN  , Z20_IDMT  ," 
   cSql += "       Z20_MOTI  , Z20_HIIN  , Z20_HFIT  , Z20_DCON  , Z20_DEQU  , Z20_MPRE  , Z20_STATUS, Z20_NOBR  , Z20_DOBR  , Z20_REGI  ,"  
   cSql += "       Z20_RESP  , Z20_DREC  , Z20_IEXE  , Z20_FEXE  , Z20_IPOB  , Z20_FPOB  , Z20_DENE  , Z20_DPFA  , Z20_DTUF  , Z20_VPRE  ,"  
   cSql += "       Z20_VREA  , Z20_VPAG  , Z20_QPOP  , Z20_QPOS  , Z20_COBR  , Z20_TPOB  , Z20_SUPE  , Z20_NPED  , Z20_DPED  , Z20_LATE  ,"  
   cSql += "       Z20_LONG  , Z20_FCON  , Z20_NFIS  , Z20_DNOT  , Z20_VIST  , Z20_TSR2  , Z20_CSTQ  , Z20_CPRE  , Z20_DPRE  , Z20_UNID  ,"  
   cSql += "       Z20_MATE  , Z20_SITU  , Z20_ORCA  , Z20_ORCV  , Z20_PROC  , Z20_ASEP  , Z20_APLI  , Z20_ADEV  , 20_CODU  ,"  
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), Z20_LOGE)) AS LOGERRO,"   
   cSql += "       Z20_DIMP  , Z20_HIMP  , Z20_ARQU  , Z20_USUA  , Z20_SEQU  , Z20_NROS"                                                                                      
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE Z20_ARQU    = '" + Alltrim(_Arquivo) + "'"
   cSql += "   AND Z20_USUA    = '" + Alltrim(_Usuario) + "'"
   cSql += "   AND Z20_DIMP   = CONVERT(DATETIME,'" + Dtoc(_Data) + "', 103)"
   cSql += "   AND Z20_STATUS <> '1'"                          
   cSql += "   AND D_E_L_E_T_ = ''"                

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRAVACAO", .T., .T. )
    
   T_GRAVACAO->( DbGoTop() )
   
   WHILE !T_GRAVACAO->( EOF() )

      // Tabela Z16 -> Tabela de Servicos
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "SERVICOS"

         // Verifica se registro já está gravado na tabela Z16
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT Z16_GRUP,"
         cSql += "       Z16_DATA,"
         cSql += "       Z16_ARQU,"
         cSql += "       Z16_SEQU "
         cSql += "  FROM " + RetSqlName("Z16")
         cSql += " WHERE Z16_GRUP = 'SERVICOS'"
         cSql += "   AND Z16_DATA =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z16_ARQU = '" + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z16_USUA = '" + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z16_SEQU = '" + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z16")
            DbSetOrder(1) 
            Reclock("Z16", .T.)
            Z16->Z16_FILIAL := "  "	
            Z16->Z16_GRUP	 := T_GRAVACAO->Z20_GRUP
            Z16->Z16_IDNO	 := T_GRAVACAO->Z20_IDNT
            Z16->Z16_NNOT	 := T_GRAVACAO->Z20_NNOT
            Z16->Z16_ITPS	 := T_GRAVACAO->Z20_IDTS
            Z16->Z16_TPSR	 := T_GRAVACAO->Z20_TSR1
            Z16->Z16_OSIS	 := T_GRAVACAO->Z20_OSIS
            Z16->Z16_OSER	 := T_GRAVACAO->Z20_OSRV
            Z16->Z16_MCOO	 := T_GRAVACAO->Z20_MCOO
            Z16->Z16_NCOO	 := T_GRAVACAO->Z20_NCOO
            Z16->Z16_MSUP	 := T_GRAVACAO->Z20_MSUP
            Z16->Z16_NSUP	 := T_GRAVACAO->Z20_NSUP
            Z16->Z16_IDEQ	 := T_GRAVACAO->Z20_IDEQ
            Z16->Z16_NEQU	 := T_GRAVACAO->Z20_NEQU
            Z16->Z16_ITPE	 := T_GRAVACAO->Z20_IDTE
            Z16->Z16_TPEQ	 := T_GRAVACAO->Z20_TEQU
            Z16->Z16_MF01	 := T_GRAVACAO->Z20_MF01
            Z16->Z16_NF01	 := T_GRAVACAO->Z20_NF01
            Z16->Z16_MF02	 := T_GRAVACAO->Z20_MF02
            Z16->Z16_NF02	 := T_GRAVACAO->Z20_NF02
            Z16->Z16_MF03	 := T_GRAVACAO->Z20_MF03
            Z16->Z16_NF03	 := T_GRAVACAO->Z20_NF03
            Z16->Z16_MF04	 := T_GRAVACAO->Z20_MF04
            Z16->Z16_NF04	 := T_GRAVACAO->Z20_NF04
            Z16->Z16_MF05	 := T_GRAVACAO->Z20_MF05
            Z16->Z16_NF05	 := T_GRAVACAO->Z20_NF05
            Z16->Z16_MF06	 := T_GRAVACAO->Z20_MF06
            Z16->Z16_NF06	 := T_GRAVACAO->Z20_NF06
            Z16->Z16_IDCT	 := T_GRAVACAO->Z20_IDCT
            Z16->Z16_CONT    := T_GRAVACAO->Z20_CONT
            Z16->Z16_IDCS	 := T_GRAVACAO->Z20_IDCS
            Z16->Z16_CSER	 := T_GRAVACAO->Z20_CSER
            Z16->Z16_IDVC	 := T_GRAVACAO->Z20_IDVE
            Z16->Z16_PLAC	 := T_GRAVACAO->Z20_PLAC
            Z16->Z16_TVEI	 := T_GRAVACAO->Z20_TVEI
            Z16->Z16_IDTV	 := T_GRAVACAO->Z20_IDTV
            Z16->Z16_KMIN	 := T_GRAVACAO->Z20_KMIN
            Z16->Z16_KMFM	 := T_GRAVACAO->Z20_KMFM
            Z16->Z16_IDSE	 := T_GRAVACAO->Z20_IDSR
            Z16->Z16_CODS	 := T_GRAVACAO->Z20_CSRV
            Z16->Z16_DSER	 := T_GRAVACAO->Z20_DSRV
            Z16->Z16_QUAN	 := T_GRAVACAO->Z20_QUAN
            Z16->Z16_VSER	 := T_GRAVACAO->Z20_VSRV
            Z16->Z16_DTAC	 := T_GRAVACAO->Z20_DCOM
            Z16->Z16_HCOM	 := T_GRAVACAO->Z20_HCOM
            Z16->Z16_DIDS	 := T_GRAVACAO->Z20_DIDS
            Z16->Z16_HIDS	 := T_GRAVACAO->Z20_HIDS
            Z16->Z16_DCHG	 := T_GRAVACAO->Z20_DCHL
            Z16->Z16_HCHG	 := T_GRAVACAO->Z20_HCHL
            Z16->Z16_DISR	 := T_GRAVACAO->Z20_DISR
            Z16->Z16_HISR	 := T_GRAVACAO->Z20_HISR
            Z16->Z16_DTSR	 := T_GRAVACAO->Z20_DTSR
            Z16->Z16_HTSR	 := T_GRAVACAO->Z20_HTSR
            Z16->Z16_LDIN	 := T_GRAVACAO->Z20_LIDS
            Z16->Z16_LOIN	 := T_GRAVACAO->Z20_LOID
            Z16->Z16_LISR	 := T_GRAVACAO->Z20_LISR
            Z16->Z16_LOSR	 := T_GRAVACAO->Z20_LOIS
            Z16->Z16_IDOB	 := T_GRAVACAO->Z20_IDOB
            Z16->Z16_EPEP	 := T_GRAVACAO->Z20_EPEP 
            Z16->Z16_CIDA    := T_GRAVACAO->Z20_CIDA
            Z16->Z16_OBSE    := T_GRAVACAO->Z20_OBSE
            Z16->Z16_DITR    := T_GRAVACAO->Z20_DITR
            Z16->Z16_HITR    := T_GRAVACAO->Z20_HITR
            Z16->Z16_DFMT    := T_GRAVACAO->Z20_DFMT
            Z16->Z16_HFTR    := T_GRAVACAO->Z20_HFTR
            Z16->Z16_DATA	 := CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z16->Z16_HORA	 := T_GRAVACAO->Z20_HIMP
            Z16->Z16_ARQU	 := T_GRAVACAO->Z20_ARQU
            Z16->Z16_USUA    := T_GRAVACAO->Z20_USUA
            Z16->Z16_NROS	 := T_GRAVACAO->Z20_NROS
            MsUnLock()
         Endif
      
      Endif

      // Tabela Z17 -> Tabela de Metas
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "METAS"

         // Verifica se registro já está gravado na tabela Z16
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf
                      
         cSql := ""
         cSql := "SELECT Z17_GRUP,"
         cSql += "       Z17_DIMP,"
         cSql += "       Z17_ARQU,"
         cSql += "       Z17_USUA,"
         cSql += "       Z17_SEQU "
         cSql += "  FROM " + RetSqlName("Z17")
         cSql += " WHERE Z17_GRUP = 'METAS'"
         cSql += "   AND Z17_DIMP =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z17_ARQU = '" + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z17_USUA = '" + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z17_SEQU = '" + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z17")
            DbSetOrder(1)
            Reclock("Z17", .T.)
            Z17->Z17_FILIAL := "  " 	
            Z17->Z17_GRUP	:= T_GRAVACAO->Z20_GRUP
            Z17->Z17_DATA	:= T_GRAVACAO->Z20_DATA
            Z17->Z17_IDEQ	:= T_GRAVACAO->Z20_IDEQ
            Z17->Z17_NEQU	:= T_GRAVACAO->Z20_NEQU
            Z17->Z17_ITPE	:= T_GRAVACAO->Z20_IDTE
            Z17->Z17_TPEQ	:= T_GRAVACAO->Z20_TEQU
            Z17->Z17_MELE	:= T_GRAVACAO->Z20_MELE
            Z17->Z17_NELE	:= T_GRAVACAO->Z20_NELE
            Z17->Z17_MPAR	:= T_GRAVACAO->Z20_MPAR
            Z17->Z17_NPAR	:= T_GRAVACAO->Z20_NPAR
            Z17->Z17_ICNT	:= T_GRAVACAO->Z20_IDCT
            Z17->Z17_CONT	:= T_GRAVACAO->Z20_CONT
            Z17->Z17_ICSR	:= T_GRAVACAO->Z20_IDCS
            Z17->Z17_CSER	:= T_GRAVACAO->Z20_CSER
            Z17->Z17_MVLR	:= T_GRAVACAO->Z20_MVLR
            Z17->Z17_RVAL	:= T_GRAVACAO->Z20_RVDI
            Z17->Z17_OBSE	:= T_GRAVACAO->Z20_OBSE
            Z17->Z17_JUST	:= T_GRAVACAO->Z20_JUST
            Z17->Z17_IDTR	:= T_GRAVACAO->Z20_IDTN
            Z17->Z17_ITPT	:= T_GRAVACAO->Z20_IDTT
            Z17->Z17_TPTU	:= T_GRAVACAO->Z20_TTUR
            Z17->Z17_HITR	:= T_GRAVACAO->Z20_HITR
            Z17->Z17_HFTR	:= T_GRAVACAO->Z20_HFTR
            Z17->Z17_DIMP	:= CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z17->Z17_HIMP	:= T_GRAVACAO->Z20_HIMP
            Z17->Z17_ARQU	:= T_GRAVACAO->Z20_ARQU
            Z17->Z17_USUA	:= T_GRAVACAO->Z20_USUA
            Z17->Z17_NROS	:= T_GRAVACAO->Z20_NROS
            Z17->Z17_SEQU   := T_GRAVACAO->Z20_SEQU
            MsUnLock()        

         Endif

      Endif   

      // Tabela Z18 -> Tabela de Intervalos
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "INTERVALOS"

         // Verifica se registro já está gravado na tabela Z16
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf
                      
         cSql := ""
         cSql := "SELECT Z18_GRUP,"
         cSql += "       Z18_DIMP,"
         cSql += "       Z18_ARQU,"
         cSql += "       Z18_USUA,"
         cSql += "       Z18_SEQU "
         cSql += "  FROM " + RetSqlName("Z18")
         cSql += " WHERE Z18_GRUP = 'METAS'"
         cSql += "   AND Z18_DIMP =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z18_ARQU = '" + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z18_USUA = '" + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z18_SEQU = '" + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z18")
            DbSetOrder(1)
            Reclock("Z18", .T.)
            Z18->Z18_FILIAL := "  " 	
            Z18->Z18_GRUP	:= T_GRAVACAO->Z20_GRUP
            Z18->Z18_IDTU	:= T_GRAVACAO->Z20_IDTN
            Z18->Z18_IDIN	:= T_GRAVACAO->Z20_IDIN
            Z18->Z18_IDMT	:= T_GRAVACAO->Z20_IDMT
            Z18->Z18_MOTI	:= T_GRAVACAO->Z20_MOTI
            Z18->Z18_DATA	:= T_GRAVACAO->Z20_DATA
            Z18->Z18_HIIN	:= T_GRAVACAO->Z20_HIIN
            Z18->Z18_HFIN	:= T_GRAVACAO->Z20_HFIT
            Z18->Z18_JUST	:= T_GRAVACAO->Z20_JUST
            Z18->Z18_IDEQ	:= T_GRAVACAO->Z20_IDEQ
            Z18->Z18_NEQU	:= T_GRAVACAO->Z20_NEQU
            Z18->Z18_IDTE	:= T_GRAVACAO->Z20_IDTE
            Z18->Z18_TPEQ	:= T_GRAVACAO->Z20_TEQU
            Z18->Z18_MELE	:= T_GRAVACAO->Z20_MELE
            Z18->Z18_NELE	:= T_GRAVACAO->Z20_NELE
            Z18->Z18_MPAR	:= T_GRAVACAO->Z20_MPAR
            Z18->Z18_NPAR	:= T_GRAVACAO->Z20_NPAR
            Z18->Z18_IDCO	:= T_GRAVACAO->Z20_IDCT
            Z18->Z18_CONT	:= T_GRAVACAO->Z20_CONT
            Z18->Z18_IDCS	:= T_GRAVACAO->Z20_IDCS
            Z18->Z18_CSER	:= T_GRAVACAO->Z20_CSER
            Z18->Z18_DIMP	:= CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z18->Z18_HIMP	:= T_GRAVACAO->Z20_HIMP
            Z18->Z18_ARQU	:= T_GRAVACAO->Z20_ARQU
            Z18->Z18_USUA	:= T_GRAVACAO->Z20_USUA
            Z18->Z18_NROS	:= T_GRAVACAO->Z20_NROS
            Z18->Z18_SEQU   := T_GRAVACAO->Z20_SEQU
            MsUnLock()                              
            
         Endif

      Endif

      // Tabela Z19 -> Tabela de Metas Prevista
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "METAS PREVISTA"

         // Verifica se registro já está gravado na tabela Z16
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf
                      
         cSql := ""
         cSql := "SELECT Z19_GRUP,"
         cSql += "       Z19_DIMP,"
         cSql += "       Z19_ARQU,"
         cSql += "       Z19_USUA,"
         cSql += "       Z19_SEQU "
         cSql += "  FROM " + RetSqlName("Z19")
         cSql += " WHERE Z19_GRUP = 'METAS PREVISTA'"
         cSql += "   AND Z19_DIMP =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z19_ARQU = '" + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z19_USUA = '" + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z19_SEQU = '" + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z19")
            DbSetOrder(1)
            Reclock("Z19", .T.)
            Z19->Z19_FILIAL := "  "	
            Z19->Z19_GRUP   := T_GRAVACAO->Z20_GRUP
            Z19->Z19_IDCO   := T_GRAVACAO->Z20_IDCT
            Z19->Z19_CONT   := T_GRAVACAO->Z20_CONT
            Z19->Z19_IDEQ   := T_GRAVACAO->Z20_IDEQ
            Z19->Z19_NEQU   := T_GRAVACAO->Z20_NEQU
            Z19->Z19_MPRE   := T_GRAVACAO->Z20_MPRE
            Z19->Z19_DIMP   := CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z19->Z19_HIMP   := T_GRAVACAO->Z20_HIMP
            Z19->Z19_ARQU   := T_GRAVACAO->Z20_ARQU
            Z19->Z19_USUA   := T_GRAVACAO->Z20_USUA
            Z19->Z19_NROS   := T_GRAVACAO->Z20_NROS
            Z19->Z19_SEQU   := T_GRAVACAO->Z20_SEQU
            MsUnLock()       

         Endif       

      Endif

      // Tabela Z26 -> Tabela de Obras
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "OBRAS"

         // Verifica se registro já está gravado na tabela Z16
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf
                      
         cSql := ""
         cSql := "SELECT Z26_GRUP,"
         cSql += "       Z26_DIMP,"
         cSql += "       Z26_ARQU,"
         cSql += "       Z26_USUA,"
         cSql += "       Z26_SEQU "
         cSql += "  FROM " + RetSqlName("Z26")
         cSql += " WHERE Z26_GRUP = 'OBRAS'"
         cSql += "   AND Z26_DIMP =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z26_ARQU = '"                   + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z26_USUA = '"                   + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z26_SEQU = '"                   + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z26")
            DbSetOrder(1)
            Reclock("Z26", .T.)

            Z26->Z26_FILIAL	:= "  "
            Z26->Z26_GRUP   := T_GRAVACAO->Z20_GRUP
            Z26->Z26_STATUS	:= T_GRAVACAO->Z20_STAT
            Z26->Z26_OBRA	:= T_GRAVACAO->Z20_NOBR
            Z26->Z26_OPRI	:= T_GRAVACAO->Z20_NOPR
            Z26->Z26_DOBR	:= T_GRAVACAO->Z20_DOBR
            Z26->Z26_REGI	:= T_GRAVACAO->Z20_REGI
            Z26->Z26_CIDA	:= T_GRAVACAO->Z20_CIDA
            Z26->Z26_CONT	:= T_GRAVACAO->Z20_CONT
            Z26->Z26_RESP	:= T_GRAVACAO->Z20_RESP
            Z26->Z26_DREC	:= T_GRAVACAO->Z20_DREC
            Z26->Z26_IOBR	:= T_GRAVACAO->Z20_IEXE
            Z26->Z26_FOBR	:= T_GRAVACAO->Z20_FEXE
            Z26->Z26_IPOB	:= T_GRAVACAO->Z20_IPOB
            Z26->Z26_FPOB	:= T_GRAVACAO->Z20_FPOB
            Z26->Z26_DENE	:= T_GRAVACAO->Z20_DENE
            Z26->Z26_DPFE	:= T_GRAVACAO->Z20_DPFA
            Z26->Z26_DTUF	:= T_GRAVACAO->Z20_DTUF
            Z26->Z26_VPRE	:= T_GRAVACAO->Z20_VPRE
            Z26->Z26_VREA	:= T_GRAVACAO->Z20_VREA
            Z26->Z26_VPAG	:= T_GRAVACAO->Z20_VPAG
            Z26->Z26_QPRO	:= T_GRAVACAO->Z20_QPOP
            Z26->Z26_QPOS	:= T_GRAVACAO->Z20_QPOS
            Z26->Z26_COBR	:= T_GRAVACAO->Z20_COBR
            Z26->Z26_TOBR	:= T_GRAVACAO->Z20_TPOB
            Z26->Z26_CSER	:= T_GRAVACAO->Z20_CSER
            Z26->Z26_SUPE	:= T_GRAVACAO->Z20_SUPE
            Z26->Z26_PEDI	:= T_GRAVACAO->Z20_NPED
            Z26->Z26_DPED	:= T_GRAVACAO->Z20_DPED
            Z26->Z26_LATI	:= T_GRAVACAO->Z20_LATE
            Z26->Z26_LONG	:= T_GRAVACAO->Z20_LONG
            Z26->Z26_FISC	:= T_GRAVACAO->Z20_FCON
            Z26->Z26_NOTA	:= T_GRAVACAO->Z20_NFIS
            Z26->Z26_DNOT	:= T_GRAVACAO->Z20_DNOT
            Z26->Z26_VIST	:= T_GRAVACAO->Z20_VIST
            Z26->Z26_OBSE	:= T_GRAVACAO->Z20_OBSE
            Z26->Z26_TSER	:= T_GRAVACAO->Z20_TSR1
            Z26->Z26_ESTO   := T_GRAVACAO->Z20_CSTQ
            Z26->Z26_DIMP	:= CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z26->Z26_HIMP	:= T_GRAVACAO->Z20_HIMP
            Z26->Z26_ARQU	:= T_GRAVACAO->Z20_ARQU
            Z26->Z26_USUA	:= T_GRAVACAO->Z20_USUA
            Z26->Z26_NROS	:= T_GRAVACAO->Z20_NROS
            Z26->Z26_SEQU	:= T_GRAVACAO->Z20_SEQU
            MsUnLock()       

         Endif       

      Endif

      // Tabela Z24 -> Tabela de Obras Atividades
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "OBRAS ATIVIDADES"

         // Verifica se registro já está gravado na tabela Z16
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf
                      
         cSql := ""
         cSql := "SELECT Z24_GRUP,"
         cSql += "       Z24_DIMP,"
         cSql += "       Z24_ARQU,"
         cSql += "       Z24_USUA,"
         cSql += "       Z24_SEQU "
         cSql += "  FROM " + RetSqlName("Z24")
         cSql += " WHERE Z24_GRUP = 'OBRAS ATIVIDADES'"
         cSql += "   AND Z24_DIMP =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z24_ARQU = '"                   + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z24_USUA = '"                   + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z24_SEQU = '"                   + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z24")
            DbSetOrder(1)
            Reclock("Z24", .T.)
            Z24->Z24_FILIAL := "  "	
            Z24->Z24_GRUP   := T_GRAVACAO->Z20_GRUP
            Z24->Z24_NOBR	:= T_GRAVACAO->Z20_NOBR
            Z24->Z24_OPRI	:= T_GRAVACAO->Z20_NOPR
            Z24->Z24_CPRE	:= T_GRAVACAO->Z20_CPRE
            Z24->Z24_DPRE	:= T_GRAVACAO->Z20_DPRE
            Z24->Z24_UPRE	:= T_GRAVACAO->Z20_UNID
            Z24->Z24_QPRE	:= T_GRAVACAO->Z20_QUAN
            Z24->Z24_DIMP	:= CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z24->Z24_HIMP	:= T_GRAVACAO->Z20_HIMP
            Z24->Z24_ARQU	:= T_GRAVACAO->Z20_ARQU
            Z24->Z24_USUA	:= T_GRAVACAO->Z20_USUA
            Z24->Z24_NROS	:= T_GRAVACAO->Z20_NROS
            Z24->Z24_SEQU	:= T_GRAVACAO->Z20_SEQU
            MsUnLock()       

         Endif       

      Endif

      // Tabela Z25 -> Tabela de Obras Materiais
      If UPPER(Alltrim(T_GRAVACAO->Z20_GRUP)) == "OBRAS MATERIAIS"

         // Verifica se registro já está gravado na tabela Z25
         If Select("T_SEEXISTE") > 0
            T_SEEXISTE->( dbCloseArea() )
         EndIf
                      
         cSql := ""
         cSql := "SELECT Z25_GRUP,"
         cSql += "       Z25_DIMP,"
         cSql += "       Z25_ARQU,"
         cSql += "       Z25_USUA,"
         cSql += "       Z25_SEQU "
         cSql += "  FROM " + RetSqlName("Z25")
         cSql += " WHERE Z25_GRUP = 'OBRAS MATERIAIS'"
         cSql += "   AND Z25_DIMP =  CONVERT(DATETIME,'" + T_GRAVACAO->Z20_DIMP + "', 103)"
         cSql += "   AND Z25_ARQU = '"                   + Alltrim(T_GRAVACAO->Z20_ARQU) + "'"
         cSql += "   AND Z25_USUA = '"                   + Alltrim(T_GRAVACAO->Z20_USUA) + "'"
         cSql += "   AND Z25_SEQU = '"                   + Alltrim(T_GRAVACAO->Z20_SEQU) + "'"
            
         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SEEXISTE", .T., .T. )
                
         If T_SEEXISTE->( EOF() )

            DbSelectArea("Z25")
            DbSetOrder(1)
            Reclock("Z25", .T.)
            Z25->Z25_FILIAL := "  "
            Z25->Z25_GRUP	:= T_GRAVACAO->Z20_GRUP
            Z25->Z25_NOBR	:= T_GRAVACAO->Z20_NOBR
            Z25->Z25_OPRI	:= T_GRAVACAO->Z20_NOPR
            Z25->Z25_MATE	:= T_GRAVACAO->Z20_MATE
            Z25->Z25_SITU	:= T_GRAVACAO->Z20_SITU
            Z25->Z25_UNID	:= T_GRAVACAO->Z20_UNID
            Z25->Z25_ORCA	:= T_GRAVACAO->Z20_ORCA
            Z25->Z25_OVAL	:= T_GRAVACAO->Z20_ORCV
            Z25->Z25_PROC	:= T_GRAVACAO->Z20_PROC
            Z25->Z25_ASEP	:= T_GRAVACAO->Z20_ASEP
            Z25->Z25_APLI	:= T_GRAVACAO->Z20_APLI
            Z25->Z25_DEVO	:= T_GRAVACAO->Z20_ADEV
            Z25->Z25_DPED	:= T_GRAVACAO->Z20_DPED
            Z25->Z25_CUSU	:= T_GRAVACAO->Z20_CODU
            Z25->Z25_DIMP	:= CTOD(SUBSTR(T_GRAVACAO->Z20_DIMP,07,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,05,02) + "/" + SUBSTR(T_GRAVACAO->Z20_DIMP,01,04))
            Z25->Z25_HIMP	:= T_GRAVACAO->Z20_HIMP
            Z25->Z25_ARQU	:= T_GRAVACAO->Z20_ARQU
            Z25->Z25_USUA	:= T_GRAVACAO->Z20_USUA
            Z25->Z25_NROS	:= T_GRAVACAO->Z20_NROS
            Z25->Z25_SEQU   := T_GRAVACAO->Z20_SEQU
            MsUnLock()       

         Endif       

      Endif

      T_GRAVACAO->( DbSkip() )
        
   Enddo
                 
   // Pesquisa os registros que podem ser gerados Ordem de Serviços
   aOrdem := {}
          
   If Select("T_GERAORDEM") > 0
      T_GERAORDEM->( dbCloseArea() )
   EndIf
             
   cSql := ""
   cSql := "SELECT R_E_C_N_O_ AS REGISTRO"
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE Z20_GRUP   = 'SERVICOS'"
   cSql += "   AND Z20_ARQU   = '" + Alltrim(_Arquivo) + "'"
   cSql += "   AND Z20_USUA   = '" + Alltrim(_Usuario) + "'"
   cSql += "   AND Z20_STATUS = '0'"
   cSql += "   AND Z20_NROS   = ''"
   cSql += "   AND D_E_L_E_T_ = ''" 
         
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GERAORDEM", .T., .T. )

   T_GERAORDEM->( DbGoTop() )
            
   WHILE !T_GERAORDEM->( EOF() )
      aAdd( aOrdem, T_GERAORDEM->REGISTRO )
      T_GERAORDEM->( DbSkip() )
   ENDDO

   // Envia Para a função que inclui as OS caso exista registro válidos para inclusão
   If Len(aordem) <> 0
      INCLUIOSZ20()
   Endif   
          
Return(.T.)
                                                 
// Função que executa o execauto para inclusão das OS
Static Function IncluiOSZ20()

   // Declaração de variáveis Locais
   Local cSql       := ""
   Local nContar    := 0
   Local lOk        := .T.
   Local aCabec     := {}
   Local aItem      := {}
   Local aItens     := {}
   Local aApont     := {}
   Local aAponts    := {}
   Local cNumOS     := ""
   Local aApontaAB8 := {}
   Local cWhere     := ""

   Local aAB6       := {}
   Local aAB7       := {}
   Local aAB8       := {}
   
   // Declaração variáveis Provadas
   Private lMsErroAuto := .F.

   // Cria a condição para filtro no select 
   cWhere := " IN ("
   For nContar = 1 to Len(aOrdem)
       cWhere := cWhere + Alltrim(Str(aOrdem[nContar])) + ","
   Next nContar
   
   // Elimina a última vírgula da strong cWhere
   cWhere := Substr(cWhere,1, Len(cWhere) - 1) + ")"

   // Pesquisa os registros a serem utilizados para a geração das OS
   If Select("T_GRAVACAO") > 0
      T_GRAVACAO->( dbCloseArea() )
   EndIf
                              
   cSql:= ""
   cSql := "SELECT Z20_SEQU  , Z20_GRUP  , Z20_IDNT  , Z20_NNOT  , Z20_IDTS  , Z20_TSR1  , Z20_OSIS  , Z20_OSRV  , Z20_MCOO  , Z20_NCOO  ," 
   cSql += "       Z20_MSUP  , Z20_NSUP  , Z20_IDEQ  , Z20_NEQU  , Z20_IDTE  , Z20_TEQU  , Z20_MF01  , Z20_NF01  , Z20_MF02  , Z20_NF02  ," 
   cSql += "       Z20_MF03  , Z20_NF03  , Z20_MF04  , Z20_NF04  , Z20_MF05  , Z20_NF05  , Z20_MF06  , Z20_NF06  , Z20_IDCT  , Z20_CONT  ," 
   cSql += "       Z20_IDCS  , Z20_CSER  , Z20_IDVE  , Z20_PLAC  , Z20_IDTV  , Z20_TVEI  , Z20_KMIN  , Z20_KMFM  , Z20_IDSR  , Z20_CSRV  ," 
   cSql += "       Z20_DSRV  , Z20_QUAN  , Z20_VSRV  , Z20_DCOM  , Z20_HCOM  , Z20_DIDS  , Z20_HIDS  , Z20_DCHL  , Z20_HCHL  , Z20_DISR  ," 
   cSql += "       Z20_HISR  , Z20_DTSR  , Z20_HTSR  , Z20_LIDS  , Z20_LOID  , Z20_LISR  , Z20_LOIS  , Z20_IDOB  , Z20_EPEP  , Z20_NOPR  ," 
   cSql += "       Z20_CIDA  , Z20_OBSE  , Z20_TSR1  , Z20_DITR  , Z20_HITR  , Z20_DFMT  , Z20_HFTR  , Z20_DATA  , Z20_MELE  , Z20_NELE  ," 
   cSql += "       Z20_MPAR  , Z20_NPAR  , Z20_MVLR  , Z20_RVDI  , Z20_JUST  , Z20_IDTN  , Z20_IDTT  , Z20_TTUR  , Z20_IDIN  , Z20_IDMT  ," 
   cSql += "       Z20_MOTI  , Z20_HIIN  , Z20_HFIT  , Z20_DCON  , Z20_DEQU  , Z20_MPRE  , Z20_STATUS, Z20_NOBR  , Z20_DOBR  , Z20_REGI  ,"  
   cSql += "       Z20_RESP  , Z20_DREC  , Z20_IEXE  , Z20_FEXE  , Z20_IPOB  , Z20_FPOB  , Z20_DENE  , Z20_DPFA  , Z20_DTUF  , Z20_VPRE  ,"  
   cSql += "       Z20_VREA  , Z20_VPAG  , Z20_QPOP  , Z20_QPOS  , Z20_COBR  , Z20_TPOB  , Z20_SUPE  , Z20_NPED  , Z20_DPED  , Z20_LATE  ,"  
   cSql += "       Z20_LONG  , Z20_FCON  , Z20_NFIS  , Z20_DNOT  , Z20_VIST  , Z20_TSR2  , Z20_CSTQ  , Z20_CPRE  , Z20_DPRE  , Z20_UNID  ,"  
   cSql += "       Z20_MATE  , Z20_SITU  , Z20_ORCA  , Z20_ORCV  , Z20_PROC  , Z20_ASEP  , Z20_APLI  , Z20_ADEV  , 20_CODU  ,"  
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), Z20_LOGE)) AS LOGERRO,"   
   cSql += "       Z20_DIMP  , Z20_HIMP  , Z20_ARQU  , Z20_USUA  , Z20_SEQU  , Z20_NROS"                                                                                      
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE R_E_C_N_O_ " + cWhere
   cSql += "   AND D_E_L_E_T_ = ''"                

   cSql := ChangeQuery( cSql )                               
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRAVACAO", .T., .T. )

   // ###########################################################################################
   // Carrega os array aAB6, aAB7 e aAB8. Arrays que vão ser usados para o Execauto do Teca450 ##
   // ###########################################################################################

   aAB6 := {} // Cabeçalho das Ordens de Serviço
   aAB7 := {} // Item das Ordens de Serviço
   aAB8 := {} // Apontamentos das Ordens de Serviço
   
   // Inclui nosvas OS
   T_GRAVACAO->( DbGoTop() )
   
   WHILE !T_GRAVACAO->( EOF() )
   
      // Carrega o próximo Nº de Ordem de Serviço a ser utilizado para inclusão
	  cNumOS := GetSXENum("AB6","AB6_NUMOS")	
	  RollBackSx8()	

      // Pequisa os parâmetros criação de OS
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z11.Z11_FILIAL,"
      cSql += "       Z11.Z11_CONT	,"
      cSql += "       Z11.Z11_CENT	,"
      cSql += "       Z11.Z11_TIPO	,"
      cSql += "       Z11.Z11_CRIA	,"
      cSql += "       Z11.Z11_EMPR	,"
      cSql += "       Z11.Z11_FILI	,"
      cSql += "       Z11.Z11_CLIE	,"
      cSql += "       Z11.Z11_LOJA	,"
	  cSql += "       SA1.A1_NOME   ,"
	  cSql += "       SA1.A1_EST    ,"
	  cSql += "       SA1.A1_MUN    ,"
	  cSql += "       SA1.A1_END    ,"
	  cSql += "       SA1.A1_COD_MUN,"
      cSql += "       Z11.Z11_COND	,"
      cSql += "       Z11.Z11_TABE	,"
      cSql += "       Z11.Z11_TPOS	,"
      cSql += "       Z11.Z11_CSER	,"
      cSql += "       Z11.Z11_SEQU	,"
      cSql += "       Z11.Z11_DINI	,"
      cSql += "       Z11.Z11_DFIM   "
      cSql += "  FROM " + RetSqlName("Z11") + " Z11, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE Z11.Z11_CONT   = '" + Alltrim(T_GRAVACAO->Z20_IDCT) + "'"
      cSql += "   AND Z11.Z11_CENT   = '" + Alltrim(T_GRAVACAO->Z20_IDCS) + "'"
      cSql += "   AND Z11.Z11_TIPO   = '" + Alltrim(T_GRAVACAO->Z20_IDTS) + "'"
      cSql += "   AND Z11.Z11_SEQU  <> '000'"
      cSql += "   AND Z11.D_E_L_E_T_ = ''"
      cSql += "   AND SA1.A1_COD     = Z11.Z11_CLIE"
      cSql += "   AND SA1.A1_LOJA    = Z11.Z11_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''"      
                                          
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      aAdd( aAB6, { cNumOS                   ,; // 01 - Nº da Ordem de Serviço a ser incluída
                    T_PARAMETROS->Z11_CLIE   ,; // 02 - Código do Cliente
                    T_PARAMETROS->Z11_LOJA   ,; // 03 - Loja do Cliente
                    cDataBase                ,; // 04 - Data de Emissão da OS (Data de Inclusão)
                    Time()                   ,; // 05 - Hora de Inclusão d Ordem de Serviço
                    cUserName                ,; // 06 - Atendente da OS                                                             
                    T_PARAMETROS->Z11_COND   ,; // 07 - Condição de Pagamento
                    T_PARAMETROS->Z11_TABE   ,; // 08 - Tabela de Preço
                    T_PARAMETROS->A1_NOME    ,; // 09 - Descrição
                    T_PARAMETROS->A1_EST     ,; // 10 - Estado
                    T_PARAMETROS->A1_COD_MUN ,; // 11 - Código Cidade
                    T_PARAMETROS->A1_MUN     ,; // 12 - Município
                    T_PARAMETROS->A1_END     ,; // 13 - Endereço                    
                    T_PARAMETROS->Z11_TPOS   ,; // 14 - Tipo OS
	                T_GRAVACAO->Z20_NOBR     ,; // 15 - Nº da Obra
	                T_GRAVACAO->Z20_OBSE     ,; // 16 - Equipamento
                    "2"                      ,; // 17 - Prioridade
                    0.01                     }) // 18 - Taxa da 2ª Moeda

      // #####################################################                                                      
      // Carrega o Array aAB7 - Item das Ordens de Serviços ##
      // #####################################################

      // Pesquisa os parâmetros de Itens Atendidos
      If Select("T_ATENDIDOS") > 0
         T_ATENDIDOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z13_CONT,"
      cSql += "       Z13_CENT,"
 	  cSql += "       Z13_TIPO,"
 	  cSql += "       Z13_SEQU,"
 	  cSql += "       Z13_EMPR,"
 	  cSql += "       Z13_FILI,"
 	  cSql += "       Z13_IT01,"
 	  cSql += "       Z13_PR01,"
	  cSql += "       Z13_IT02,"
	  cSql += "       Z13_PR02,"
	  cSql += "       Z13_IT03,"
	  cSql += "       Z13_PR03,"
	  cSql += "       Z13_IT04,"
	  cSql += "       Z13_PR04,"
	  cSql += "       Z13_IT05,"
	  cSql += "       Z13_PR05,"
	  cSql += "       Z13_IT06,"
	  cSql += "       Z13_PR06 "
      cSql += "  FROM " + RetSqlName("Z13")                        
      cSql += " WHERE Z13_CONT    = '" + Alltrim(T_GRAVACAO->Z20_IDCT) + "'"
      cSql += "   AND Z13_CENT    = '" + Alltrim(T_GRAVACAO->Z20_IDCS) + "'"
      cSql += "   AND Z13_TIPO    = '" + Alltrim(T_GRAVACAO->Z20_IDTS) + "'"
      cSql += "   AND Z13_SEQU   <> '000'"
      cSql += "   AND D_E_L_E_T_  = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDIDOS", .T., .T. )

      // Pesquisa o primeiro produto disponível para utilização
      T_ATENDIDOS->( DbGoTop() )
      
      WHILE !T_ATENDIDOS->( EOF() )
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT01)); k_Item := T_ATENDIDOS->Z13_IT01; k_Prod := T_ATENDIDOS->Z13_PR01; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT02)); k_Item := T_ATENDIDOS->Z13_IT02; k_Prod := T_ATENDIDOS->Z13_PR02; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT03)); k_Item := T_ATENDIDOS->Z13_IT03; k_Prod := T_ATENDIDOS->Z13_PR03; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT04)); k_Item := T_ATENDIDOS->Z13_IT04; k_Prod := T_ATENDIDOS->Z13_PR04; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT05)); k_Item := T_ATENDIDOS->Z13_IT05; k_Prod := T_ATENDIDOS->Z13_PR05; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT06)); k_Item := T_ATENDIDOS->Z13_IT06; k_Prod := T_ATENDIDOS->Z13_PR06; Exit; Endif
         T_ATENDIDOS->( DbSkip() )
      ENDDO   

      aAdd( aAB7, {cNumOS                    ,; // 01 - Nº da Ordem de Serviço a ser incluída
                   k_Item                    ,; // 02 - Sequencia do Item do produto
                   k_Prod                    ,; // 03 - Código do Produto (Base Instalada - Atendimento do Cliente)
                   "REDE ELETRICA"           ,; // 04 - Produto/Equipamento
                   T_GRAVACAO->Z20_NOBR      ,; // 05 - Nº de Série do Produto (Nº da Obra)
                   T_PARAMETROS->Z11_CLIE    ,; // 06 - Código do Cliente
                   T_PARAMETROS->Z11_LOJA    ,; // 07 - Código da Loja
                   dDataBase                 }) // 08 - DataBase - Data de Inclusão
                             
      // ########################################################################
      // Carrega o array aAB8 - Apontamentos da Ordem de Serviço para inclusão ##
      // ########################################################################
      aAdd( aAB8, { cNumOS                   ,; // 01 - Nº da Ordem de Serviço
                    "01"                     ,; // 02 - Item do produto
                    "01"                     ,; // 03 - SubItem
                          T_GRAVACAO->Z20_IDTS                                                                        ,; // 03
                          T_PARAMETROS->Z11_TPOS                                                                      ,; // 04
                          VAL(STRTRAN(T_GRAVACAO->Z20_QUAN, ",", "."))                                                ,; // 05
                         (VAL(STRTRAN(T_GRAVACAO->Z20_VSRV, ",", ".")) / VAL(STRTRAN(T_GRAVACAO->Z20_QUAN, ",", "."))),; // 06
                          VAL(STRTRAN(T_GRAVACAO->Z20_VSRV, ",", "."))                                                ,; // 07
                          T_PARAMETROS->Z11_CLIE                                                                      ,; // 08
                          T_PARAMETROS->Z11_LOJA                                                                      ,; // 09
                          ""                                                                                          ,; // 10
                          ""                                                                                          }) // 11






      // Pequisa os parâmetros para alimentar o array da Ordem de Serviço a ser incluída
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z11.Z11_FILIAL,"
      cSql += "       Z11.Z11_CLIE	,"
      cSql += "       Z11.Z11_LOJA	,"
      cSql += "       Z11.Z11_TPOS	 "
      cSql += "  FROM " + RetSqlName("Z11") + " Z11, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE Z11.Z11_CONT   = '" + Alltrim(T_GRAVACAO->Z20_IDCT) + "'"
      cSql += "   AND Z11.Z11_CENT   = '" + Alltrim(T_GRAVACAO->Z20_IDCS) + "'"
      cSql += "   AND Z11.Z11_TIPO   = '" + Alltrim(T_GRAVACAO->Z20_IDTS) + "'"
      cSql += "   AND Z11.Z11_SEQU  <> '000'"
      cSql += "   AND Z11.D_E_L_E_T_ = ''"                     
      cSql += "   AND SA1.A1_COD     = Z11.Z11_CLIE"
      cSql += "   AND SA1.A1_LOJA    = Z11.Z11_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''"      
                                          
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      // Carrega o Array aAponta
      aAdd( aApontaAB8, { T_GRAVACAO->Z20_IDCT                                                                        ,; // 01
                          T_GRAVACAO->Z20_IDCS                                                                        ,; // 02
                          T_GRAVACAO->Z20_IDTS                                                                        ,; // 03
                          T_PARAMETROS->Z11_TPOS                                                                      ,; // 04
                          VAL(STRTRAN(T_GRAVACAO->Z20_QUAN, ",", "."))                                                ,; // 05
                         (VAL(STRTRAN(T_GRAVACAO->Z20_VSRV, ",", ".")) / VAL(STRTRAN(T_GRAVACAO->Z20_QUAN, ",", "."))),; // 06
                          VAL(STRTRAN(T_GRAVACAO->Z20_VSRV, ",", "."))                                                ,; // 07
                          T_PARAMETROS->Z11_CLIE                                                                      ,; // 08
                          T_PARAMETROS->Z11_LOJA                                                                      ,; // 09
                          ""                                                                                          ,; // 10
                          ""                                                                                          }) // 11
    
       T_GRAVACAO->( DbSkip() )
       
   ENDDO
       
   // Prepara o código do item e subitem para gravação
   For nContar = 1 to Len(aApontaAB8)
       
       If Select("T_SUBCODIGO") > 0
          T_SUBCODIGO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT AB8_ITEM  ,"
       cSql += "       AB8_SUBITE "
       cSql += "  FROM " + RetSqlName("AB8")
       cSql += " WHERE AB8_FILIAL = '" + Alltrim(cFilAnt)                + "'"
       cSql += "   AND AB8_NUMSER = '" + Alltrim(aApontaAB8[nContar,01]) + "'"
       cSql += "   AND AB8_CODCLI = '" + Alltrim(aApontaAB8[nContar,08]) + "'"
       cSql += "   AND AB8_LOJA   = '" + Alltrim(aApontaAB8[nContar,09]) + "'"
       cSql += "   AND D_E_L_E_T_ = ''"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SUBCODIGO", .T., .T. )

       If T_SUBCODIGO->( EOF() )
          aApontaAB8[nContar,10] := "01"
          aApontaAB8[nContar,11] := "01"
       Else
          nItem := int(val(T_SUBCODIGO->AB8_ITEM)) + 1
          nSubi := int(val(T_SUBCODIGO->AB8_SUBITE)) + 1

          aApontaAB8[nContar,10] := STRZERO(nItem,2)
          aApontaAB8[nContar,11] := STRZERO(nSubi,2)
       Endif
       
   Next nContar
   
   // Inclui nosvas OS
   T_GRAVACAO->( DbGoTop() )
   
   WHILE !T_GRAVACAO->( EOF() )
   
      // Se registro inconsistente, despreza e lê o próximo
      If T_GRAVACAO->Z20_STATUS <> "0"
         T_GRAVACAO->( DbSkip() )
         LOOP
      Endif
         
      // Pequisa os parâmetros para alimentar o array da Ordem de Serviço a ser incluída
      If Select("T_PARAMETROS") > 0
         T_PARAMETROS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z11.Z11_FILIAL,"
      cSql += "       Z11.Z11_CONT	,"
      cSql += "       Z11.Z11_CENT	,"
      cSql += "       Z11.Z11_TIPO	,"
      cSql += "       Z11.Z11_CRIA	,"
      cSql += "       Z11.Z11_EMPR	,"
      cSql += "       Z11.Z11_FILI	,"
      cSql += "       Z11.Z11_CLIE	,"
      cSql += "       Z11.Z11_LOJA	,"
	  cSql += "       SA1.A1_NOME   ,"
	  cSql += "       SA1.A1_EST    ,"
	  cSql += "       SA1.A1_MUN    ,"
	  cSql += "       SA1.A1_END    ,"
	  cSql += "       SA1.A1_COD_MUN,"
      cSql += "       Z11.Z11_COND	,"
      cSql += "       Z11.Z11_TABE	,"
      cSql += "       Z11.Z11_TPOS	,"
      cSql += "       Z11.Z11_CSER	,"
      cSql += "       Z11.Z11_SEQU	,"
      cSql += "       Z11.Z11_DINI	,"
      cSql += "       Z11.Z11_DFIM   "
      cSql += "  FROM " + RetSqlName("Z11") + " Z11, "
      cSql += "       " + RetSqlName("SA1") + " SA1  "
      cSql += " WHERE Z11.Z11_CONT   = '" + Alltrim(T_GRAVACAO->Z20_IDCT) + "'"
      cSql += "   AND Z11.Z11_CENT   = '" + Alltrim(T_GRAVACAO->Z20_IDCS) + "'"
      cSql += "   AND Z11.Z11_TIPO   = '" + Alltrim(T_GRAVACAO->Z20_IDTS) + "'"
      cSql += "   AND Z11.D_E_L_E_T_ = ''"
      cSql += "   AND SA1.A1_COD     = Z11.Z11_CLIE"
      cSql += "   AND SA1.A1_LOJA    = Z11.Z11_LOJA"
      cSql += "   AND SA1.D_E_L_E_T_ = ''"      
                                          
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

      // Pesquisa os parâmetros de Itens Atendidos
      If Select("T_ATENDIDOS") > 0
         T_ATENDIDOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z13_CONT,"
      cSql += "       Z13_CENT,"
 	  cSql += "       Z13_TIPO,"
 	  cSql += "       Z13_SEQU,"
 	  cSql += "       Z13_EMPR,"
 	  cSql += "       Z13_FILI,"
 	  cSql += "       Z13_IT01,"
 	  cSql += "       Z13_PR01,"
	  cSql += "       Z13_IT02,"
	  cSql += "       Z13_PR02,"
	  cSql += "       Z13_IT03,"
	  cSql += "       Z13_PR03,"
	  cSql += "       Z13_IT04,"
	  cSql += "       Z13_PR04,"
	  cSql += "       Z13_IT05,"
	  cSql += "       Z13_PR05,"
	  cSql += "       Z13_IT06,"
	  cSql += "       Z13_PR06 "
      cSql += "  FROM " + RetSqlName("Z13")                        
      cSql += " WHERE Z13_CONT    = '" + Alltrim(T_GRAVACAO->Z20_IDCT) + "'"
      cSql += "   AND Z13_CENT    = '" + Alltrim(T_GRAVACAO->Z20_IDCS) + "'"
      cSql += "   AND Z13_TIPO    = '" + Alltrim(T_GRAVACAO->Z20_IDTS) + "'"
      cSql += "   AND Z13_SEQU   <> '000'"
      cSql += "   AND D_E_L_E_T_  = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATENDIDOS", .T., .T. )

      // Pesquisa o primeiro produto disponível para utilização
      T_ATENDIDOS->( DbGoTop() )
      
      WHILE !T_ATENDIDOS->( EOF() )
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT01)); k_Item := T_ATENDIDOS->Z13_IT01; k_Prod := T_ATENDIDOS->Z13_PR01; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT02)); k_Item := T_ATENDIDOS->Z13_IT02; k_Prod := T_ATENDIDOS->Z13_PR02; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT03)); k_Item := T_ATENDIDOS->Z13_IT03; k_Prod := T_ATENDIDOS->Z13_PR03; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT04)); k_Item := T_ATENDIDOS->Z13_IT04; k_Prod := T_ATENDIDOS->Z13_PR04; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT05)); k_Item := T_ATENDIDOS->Z13_IT05; k_Prod := T_ATENDIDOS->Z13_PR05; Exit; Endif
         If !Empty(Alltrim(T_ATENDIDOS->Z13_IT06)); k_Item := T_ATENDIDOS->Z13_IT06; k_Prod := T_ATENDIDOS->Z13_PR06; Exit; Endif
         T_ATENDIDOS->( DbSkip() )
      ENDDO   

      // Carrega o próximo código de Ordem de Serviço a ser utilizado para inclusão
	  cNumOS := GetSXENum("AB6","AB6_NUMOS")	
	  RollBackSx8()	

      // Carrega dados do cabeçalho da OS
	  aAdd(aCabec,{"AB6_NUMOS" , cNumOS                  , Nil})	
	  aAdd(aCabec,{"AB6_CODCLI", T_PARAMETROS->Z11_CLIE  , Nil})	
	  aAdd(aCabec,{"AB6_LOJA"  , T_PARAMETROS->Z11_LOJA  , Nil})	
	  aAdd(aCabec,{"AB6_EMISSA", dDataBase               , Nil})	
	  aAdd(aCabec,{"AB6_HORA"  , Time()                  , Nil})	
	  aAdd(aCabec,{"AB6_ATEND" , cUserName               , Nil})	
	  aAdd(aCabec,{"AB6_CONPAG", T_PARAMETROS->Z11_COND  , Nil})	
	  aAdd(aCabec,{"AB6_TABELA", T_PARAMETROS->Z11_TABE  , Nil})	
	  aAdd(aCabec,{"AB6_YDESCR", T_PARAMETROS->A1_NOME   , Nil})	
	  aAdd(aCabec,{"AB6_YEST"  , T_PARAMETROS->A1_EST    , Nil})	
	  aAdd(aCabec,{"AB6_YMUNI" , T_PARAMETROS->A1_MUN    , Nil})	
	  aAdd(aCabec,{"AB6_YEND"  , T_PARAMETROS->A1_END    , Nil})	
	  aAdd(aCabec,{"AB6_TPOS"  , T_PARAMETROS->Z11_TPOS  , Nil})	
	  aAdd(aCabec,{"AB6_NROBRA", T_GRAVACAO->Z20_NOBR    , Nil})	
	  aAdd(aCabec,{"AB6_EQREF" , T_GRAVACAO->Z20_OBSE    , Nil})	
	  aAdd(aCabec,{"AB6_SCIDAD", T_PARAMETROS->A1_COD_MUN, Nil})	
	  
	  // Carrega dados do produto da OS
	  aAdd(aItem,{"AB7_NUMOS"  , cNumOS                , Nil})	
      aAdd(aItem,{"AB7_ITEM"   , k_Item                , Nil})	
      aAdd(aItem,{"AB7_CODPRB" , k_Prod                , Nil})
	  aAdd(aItem,{"AB7_CODPRO" , "REDE ELETRICA"       , Nil})	
	  aAdd(aItem,{"AB7_NUMSER" , T_GRAVACAO->Z20_NOBR  , Nil})	
	  aAdd(aItem,{"AB7_CODCLI" , T_PARAMETROS->Z11_CLIE, Nil})
	  aAdd(aItem,{"AB7_LOJA"   , T_PARAMETROS->Z11_LOJA, Nil})
	  aAdd(aItem,{"AB7_EMISSA" , dDataBase             , Nil})

	  aAdd(aItens,aItem)	
	  
	  // Carrega os apontamentos da OS
      For nContar = 1 to Len(aApontaAB8)

 	      aAdd(aApont,{"AB8_ITEM"  , aApontaAB8[nContar,10], Nil})	
	      aAdd(aApont,{"AB8_SUBITE", aApontaAB8[nContar,11], Nil})	
	      aAdd(aApont,{"AB8_CODPRO", aApontaAB8[nContar,02], Nil})	
	      aAdd(aApont,{"AB8_DESPRO", aApontaAB8[nContar,03], Nil})	
	      aAdd(aApont,{"AB8_CODSER", aApontaAB8[nContar,04], Nil})	
	      aAdd(aApont,{"AB8_QUANT" , aApontaAB8[nContar,05], Nil})	
	      aAdd(aApont,{"AB8_VUNIT" , aApontaAB8[nContar,06], Nil})	
	      aAdd(aApont,{"AB8_TOTAL" , aApontaAB8[nContar,07], Nil})	
	      aAdd(aApont,{"AB8_PRCLIS", aApontaAB8[nContar,07], Nil})
	      aAdd(aApont,{"AB8_CODCLI", aApontaAB8[nContar,08], Nil})
	      aAdd(aApont,{"AB8_LOJA"  , aApontaAB8[nContar,09], Nil})
	      aAdd(aApont,{"AB8_NUMSER", aApontaAB8[nContar,01], Nil})
	      aAdd(aApont,{"AB8_CODPRD", "REDE ELETRICA"       , Nil})

      Next nContar

      aAdd(aAponts,aApont)	
	  
      // Executa o Execauito
	  TECA450(,aCabec,aItens,aAponts,3)	

      // Testa o Retorno	  
	  If !lMsErroAuto		
	     MsgAlert("Inclusao com sucesso! ")	
      Else		
	     MsgAlert("Erro na inclusao!")	
	  EndIf

	  T_GRAVACAO->( DbSkip() )
	  
   ENDDO	  
	  
	  	

Return(.T.)

// Função que abre a tela de pesquisa de arquivos importadas
Static Function PesqImportados()

   Private aTipoTag  := {"0 - TODAS", "1 - SERVIÇOS", "2 - METAS", "3 - INTERVALOS", "4 - METAS PREVISTA", "5 - OBRAS", "6 - OBRAS ATIVIDADES", "7 - OBRAS MATERIAIS"}
   Private cDataIni  := Ctod("  /  /    ")
   Private cDataFim  := Ctod("  /  /    ")

   Private cComboBx1
   Private oGet1
   Private oGet2
           
   Private aPesquisa := {}

   Private oDlgPsq

   DEFINE MSDIALOG oDlgPsq TITLE "Importação OS - GPM" FROM C(178),C(181) TO C(624),C(807) PIXEL

   @ C(005),C(005) Say "Pesquisa de Importações Realizadas" Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlgPsq
   @ C(017),C(005) Say "Data Inicial"                       Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgPsq
   @ C(017),C(047) Say "Data Final"                         Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgPsq
   @ C(017),C(089) Say "TAG a ser pesquisada"               Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlgPsq
 
   @ C(026),C(005) MsGet    oGet1           Var cDataIni Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPsq
   @ C(026),C(047) MsGet    oGet2           Var cDataFim Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPsq
   @ C(026),C(089) ComboBox cComboBx1 Items aTipoTag     Size C(106),C(010)                              PIXEL OF oDlgPsq

   @ C(024),C(200) Button "Pesquisar"  Size C(037),C(012) PIXEL OF oDlgPsq ACTION( BuscaTagImportadas() )
   @ C(204),C(232) Button "Visualizar" Size C(037),C(012) PIXEL OF oDlgPsq ACTION( ExplodeDetalhes() )
   @ C(204),C(271) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlgPsq ACTION( oDlgPsq:End() )

   aAdd( aPesquisa, { "", "", "", "" } )
 
   // Desenha o Browse
   oPesquisa := TCBrowse():New( 055 , 005, 392, 200,,{'Grupo', 'Data', 'Usuário', 'Arquivo' },{20,50,50,50},oDlgPsq,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oPesquisa:SetArray(aPesquisa) 
    
   // Monta a linha a ser exibina no Browse
   oPesquisa:bLine := {||{ aPesquisa[oPesquisa:nAt,01],;
                           aPesquisa[oPesquisa:nAt,02],;
                           aPesquisa[oPesquisa:nAt,03],;
                           aPesquisa[oPesquisa:nAt,04]}}

   ACTIVATE MSDIALOG oDlgPsq CENTERED 

Return(.T.)

// Função que pesquisa TAGs importadas conforme parâmetros de pesquisa
Static Function BuscaTagImportadas()

   Local cSql := ""
   
   If cDataIni == Ctod("  /  /    ")
      MsgAlert("Data Inicial para pesquisa não informada. Verifique!")
      Return(.T.)
   Endif
      
   If cDataFim == Ctod("  /  /    ")
      MsgAlert("Data Final para pesquisa não informada. Verifique!")
      Return(.T.)
   Endif
      
   aPesquisa := {}

   // Pesquisa TAG SERVIÇOS
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "1"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z16_DATA,"
	  cSql += "       Z16_USUA,"
	  cSql += "       Z16_ARQU "
      cSql += "  FROM " + RetSqlName("Z16")
      cSql += " WHERE Z16_DATA >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z16_DATA <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z16_DATA, Z16_USUA, Z16_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z16_DATA,07,02) + "/" + Substr(T_RESUMO->Z16_DATA,05,02) + "/" + Substr(T_RESUMO->Z16_DATA,01,04)

         aAdd( aPesquisa, { "SERVIÇOS"         ,;
                            xData              ,;
                            T_RESUMO->Z16_USUA ,;
                            T_RESUMO->Z16_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif
               
   // Pesquisa TAG METAS
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "2"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z17_DIMP,"
	  cSql += "       Z17_USUA,"
	  cSql += "       Z17_ARQU "
      cSql += "  FROM " + RetSqlName("Z17")
      cSql += " WHERE Z17_DIMP >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z17_DIMP <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z17_DIMP, Z17_USUA, Z17_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z17_DIMP,07,02) + "/" + Substr(T_RESUMO->Z17_DIMP,05,02) + "/" + Substr(T_RESUMO->Z17_DIMP,01,04)

         aAdd( aPesquisa, { "METAS"            ,;
                            xData              ,;
                            T_RESUMO->Z17_USUA ,;
                            T_RESUMO->Z17_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif

   // Pesquisa TAG INTERVALOS
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "3"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z18_DIMP,"
	  cSql += "       Z18_USUA,"
	  cSql += "       Z18_ARQU "
      cSql += "  FROM " + RetSqlName("Z18")
      cSql += " WHERE Z18_DIMP >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z18_DIMP <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z18_DIMP, Z18_USUA, Z18_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z18_DIMP,07,02) + "/" + Substr(T_RESUMO->Z18_DIMP,05,02) + "/" + Substr(T_RESUMO->Z18_DIMP,01,04)

         aAdd( aPesquisa, { "INTERVALOS"       ,;
                            xData              ,;
                            T_RESUMO->Z18_USUA ,;
                            T_RESUMO->Z18_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif

   // Pesquisa TAG METAS PREVISTA
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "4"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z19_DIMP,"
	  cSql += "       Z19_USUA,"
	  cSql += "       Z19_ARQU "
      cSql += "  FROM " + RetSqlName("Z19")
      cSql += " WHERE Z19_DIMP >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z19_DIMP <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z19_DIMP, Z19_USUA, Z19_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z19_DIMP,07,02) + "/" + Substr(T_RESUMO->Z19_DIMP,05,02) + "/" + Substr(T_RESUMO->Z19_DIMP,01,04)

         aAdd( aPesquisa, { "METAS PREVISTA"   ,;
                            xData              ,;
                            T_RESUMO->Z19_USUA ,;
                            T_RESUMO->Z19_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif

   // Pesquisa TAG OBRAS
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "5"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z26_DIMP,"
	  cSql += "       Z26_USUA,"
	  cSql += "       Z26_ARQU "
      cSql += "  FROM " + RetSqlName("Z26")
      cSql += " WHERE Z26_DIMP >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z26_DIMP <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z26_DIMP, Z26_USUA, Z26_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z26_DIMP,07,02) + "/" + Substr(T_RESUMO->Z26_DIMP,05,02) + "/" + Substr(T_RESUMO->Z26_DIMP,01,04)

         aAdd( aPesquisa, { "OBRAS"            ,;
                            xData              ,;
                            T_RESUMO->Z26_USUA ,;
                            T_RESUMO->Z26_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif

   // Pesquisa TAG OBRAS ATIVIDADES
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "6"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z24_DIMP,"
	  cSql += "       Z24_USUA,"
	  cSql += "       Z24_ARQU "
      cSql += "  FROM " + RetSqlName("Z24")
      cSql += " WHERE Z24_DIMP >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z24_DIMP <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z24_DIMP, Z24_USUA, Z24_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z24_DIMP,07,02) + "/" + Substr(T_RESUMO->Z24_DIMP,05,02) + "/" + Substr(T_RESUMO->Z24_DIMP,01,04)

         aAdd( aPesquisa, { "OBRAS ATIVIDADES" ,;
                            xData              ,;
                            T_RESUMO->Z24_USUA ,;
                            T_RESUMO->Z24_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif

   // Pesquisa TAG OBRAS MATERIAIS
   If Substr(cComboBx1,01,01) == "0" .Or. Substr(cComboBx1,01,01) == "7"

      If Select("T_RESUMO") > 0
         T_RESUMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z25_DIMP,"
	  cSql += "       Z25_USUA,"
	  cSql += "       Z25_ARQU "
      cSql += "  FROM " + RetSqlName("Z25")
      cSql += " WHERE Z25_DIMP >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND Z25_DIMP <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " GROUP BY Z25_DIMP, Z25_USUA, Z25_ARQU"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESUMO", .T., .T. )
      
      T_RESUMO->( DbGoTop() )
      
      WHILE !T_RESUMO->( EOF() )
         xData := Substr(T_RESUMO->Z25_DIMP,07,02) + "/" + Substr(T_RESUMO->Z25_DIMP,05,02) + "/" + Substr(T_RESUMO->Z25_DIMP,01,04)

         aAdd( aPesquisa, { "OBRAS MATERIAIS"  ,;
                            xData              ,;
                            T_RESUMO->Z25_USUA ,;
                            T_RESUMO->Z25_ARQU})            
         T_RESUMO->( DbSkip() )
      ENDDO
      
   Endif

   If Len(aPesquisa) == 0
      aAdd( aPesquisa, { "", "", "", "" } )
      MsgAlert("Não existem dados a serem visualizados.")
   Endif

   // Seta vetor para a browse                            
   oPesquisa:SetArray(aPesquisa) 
    
   // Monta a linha a ser exibina no Browse
   oPesquisa:bLine := {||{ aPesquisa[oPesquisa:nAt,01],;
                           aPesquisa[oPesquisa:nAt,02],;
                           aPesquisa[oPesquisa:nAt,03],;
                           aPesquisa[oPesquisa:nAt,04]}}
Return(.T.)

// Função que abre o detalhe do arquivo dos importados selecionado no grid de pesquisa
Static Function ExplodeDetalhes()

   Local lChumba    := .F.
   Local cSql       := ""
   Local yTAG       := aPesquisa[oPesquisa:nAt,01]

   Private yData    := aPesquisa[oPesquisa:nAt,02]
   Private yUsuario := aPesquisa[oPesquisa:nAt,03]
   Private yArquivo := aPesquisa[oPesquisa:nAt,04]

   Private oGet1 
   Private oGet3 
   Private oGet4

   Private aResumo := {}

   Private oDlgExplode

   // Abre a tela para visualização dos dados convertidos
   DEFINE MSDIALOG oDlgExplode TITLE "Importação Ordens de Serviços - GPM" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(004),C(005) Say "Data Imp."         Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgExplode
   @ C(004),C(077) Say "Usuário"           Size C(021),C(009) COLOR CLR_BLACK PIXEL OF oDlgExplode
   @ C(004),C(122) Say "Arquivo Importado" Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlgExplode

   @ C(013),C(005) MsGet oGet1 Var yData    Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgExplode When lChumba
   @ C(013),C(077) MsGet oGet3 Var yUsuario Size C(042),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgExplode When lChumba
   @ C(013),C(122) MsGet oGet5 Var yArquivo Size C(377),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgExplode When lChumba

   @ C(210),C(010) Button "Detalhe"     Size C(037),C(012) PIXEL OF oDlgExplode ACTION( ImpMostraDetalhes() )
   @ C(210),C(049) Button "Log Erro"    Size C(037),C(012) PIXEL OF oDlgExplode && ACTION( oDlgExplode:End() )
   @ C(210),C(088) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlgExplode ACTION( oDlgExplode:End() )

   // Pesquisa dados do arquivo de SERVIÇOS
   If yTAG == "SERVIÇOS"
                
      aResumo := {}          
                         
      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z16_FILIAL, Z16_GRUP, Z16_IDNO, Z16_NNOT, Z16_ITPS, Z16_TPSR, Z16_OSIS, Z16_OSER, Z16_MCOO, Z16_NCOO,"
	  cSql += "       Z16_MSUP  , Z16_NSUP, Z16_IDEQ, Z16_NEQU, Z16_ITPE, Z16_TPEQ, Z16_MF01, Z16_NF01, Z16_MF02, Z16_NF02,"
	  cSql += "       Z16_MF03	, Z16_NF03, Z16_MF04, Z16_NF04, Z16_MF05, Z16_NF05, Z16_MF06, Z16_NF06, Z16_IDCT, Z16_IDCS,"
	  cSql += "       Z16_CSER	, Z16_IDVC, Z16_PLAC, Z16_TVEI, Z16_IDTV, Z16_KMIN, Z16_KMFM, Z16_IDSE, Z16_CODS, Z16_DSER,"
	  cSql += "       Z16_QUAN	, Z16_VSER, Z16_DTAC, Z16_HCOM, Z16_DIDS, Z16_HIDS, Z16_DCHG, Z16_HCHG, Z16_DISR, Z16_HISR,"
	  cSql += "       Z16_DTSR	, Z16_HTSR, Z16_LDIN, Z16_LOIN, Z16_LISR, Z16_LOSR, Z16_IDOB, Z16_EPEP, Z16_DATA, Z16_HORA,"
	  cSql += "       Z16_ARQU  , Z16_NROS, Z16_SEQU, Z16_USUA, Z16_CONT, Z16_TPS2, Z16_NOPR, Z16_CIDA, Z16_DITR, Z16_HITR,"
	  cSql += "       Z16_DFMT	, Z16_HFTR, Z16_OBSE                                                                       "
      cSql += "  FROM " + RetSqlName("Z16")
      cSql += " WHERE Z16_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z16_GRUP,; // 01
                          T_CONSULTA->Z16_IDNO,; // 02
                          T_CONSULTA->Z16_NNOT,; // 03
                          T_CONSULTA->Z16_ITPS,; // 04
                          T_CONSULTA->Z16_TPSR,; // 05
                          T_CONSULTA->Z16_OSIS,; // 06
                          T_CONSULTA->Z16_OSER,; // 07
                          T_CONSULTA->Z16_MCOO,; // 08
                          T_CONSULTA->Z16_NCOO,; // 09
	                      T_CONSULTA->Z16_MSUP,; // 10
	                      T_CONSULTA->Z16_NSUP,; // 11
	                      T_CONSULTA->Z16_IDEQ,; // 12
	                      T_CONSULTA->Z16_NEQU,; // 13
	                      T_CONSULTA->Z16_ITPE,; // 14
	                      T_CONSULTA->Z16_TPEQ,; // 15
	                      T_CONSULTA->Z16_MF01,; // 16
	                      T_CONSULTA->Z16_NF01,; // 17
	                      T_CONSULTA->Z16_MF02,; // 18
	                      T_CONSULTA->Z16_NF02,; // 19
	                      T_CONSULTA->Z16_MF03,; // 20
	                      T_CONSULTA->Z16_NF03,; // 21
	                      T_CONSULTA->Z16_MF04,; // 22
	                      T_CONSULTA->Z16_NF04,; // 23
	                      T_CONSULTA->Z16_MF05,; // 24
	                      T_CONSULTA->Z16_NF05,; // 25
	                      T_CONSULTA->Z16_MF06,; // 26
	                      T_CONSULTA->Z16_NF06,; // 27
	                      T_CONSULTA->Z16_IDCT,; // 28
	                      T_CONSULTA->Z16_IDCS,; // 29
	                      T_CONSULTA->Z16_CSER,; // 30
	                      T_CONSULTA->Z16_IDVC,; // 31
	                      T_CONSULTA->Z16_PLAC,; // 32
	                      T_CONSULTA->Z16_TVEI,; // 33
	                      T_CONSULTA->Z16_IDTV,; // 34
	                      T_CONSULTA->Z16_KMIN,; // 35
	                      T_CONSULTA->Z16_KMFM,; // 36
	                      T_CONSULTA->Z16_IDSE,; // 37
	                      T_CONSULTA->Z16_CODS,; // 38
	                      T_CONSULTA->Z16_DSER,; // 39
	                      T_CONSULTA->Z16_QUAN,; // 40
	                      T_CONSULTA->Z16_VSER,; // 41
	                      T_CONSULTA->Z16_DTAC,; // 42
	                      T_CONSULTA->Z16_HCOM,; // 43
	                      T_CONSULTA->Z16_DIDS,; // 44
	                      T_CONSULTA->Z16_HIDS,; // 45
	                      T_CONSULTA->Z16_DCHG,; // 46
	                      T_CONSULTA->Z16_HCHG,; // 47
	                      T_CONSULTA->Z16_DISR,; // 48
	                      T_CONSULTA->Z16_HISR,; // 49
	                      T_CONSULTA->Z16_DTSR,; // 50
	                      T_CONSULTA->Z16_HTSR,; // 51
	                      T_CONSULTA->Z16_LDIN,; // 52
	                      T_CONSULTA->Z16_LOIN,; // 53
	                      T_CONSULTA->Z16_LISR,; // 54
	                      T_CONSULTA->Z16_LOSR,; // 55
	                      T_CONSULTA->Z16_IDOB,; // 56
	                      T_CONSULTA->Z16_EPEP,; // 57
	                      T_CONSULTA->Z16_CONT,; // 58
	                      T_CONSULTA->Z16_TPS2,; // 59
	                      T_CONSULTA->Z16_NOPR,; // 60
	                      T_CONSULTA->Z16_CIDA,; // 61
	                      T_CONSULTA->Z16_DITR,; // 62
	                      T_CONSULTA->Z16_HITR,; // 63
	                      T_CONSULTA->Z16_DFMT,; // 64
	                      T_CONSULTA->Z16_HFTR,; // 65
	                      T_CONSULTA->Z16_OBSE,; // 66
	                      T_CONSULTA->Z16_DATA,; // 67
	                      T_CONSULTA->Z16_HORA,; // 68
	                      T_CONSULTA->Z16_ARQU,; // 69
	                      T_CONSULTA->Z16_NROS,; // 70
	                      T_CONSULTA->Z16_SEQU,; // 71
	                      T_CONSULTA->Z16_USUA}) // 72

         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, { "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "",""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Grupo"                   ,; // 01
                                                       "ID Nota"                 ,; // 02
                                                       "Nº Nota"                 ,; // 03
                                                       "ID Tipo Serviço"         ,; // 04
                                                       "Tipo de Serviço"         ,; // 05
                                                       "Origem Sistema"          ,; // 06
                                                       "Origem Serviço"          ,; // 07
                                                       "Mat. Coordenador"        ,; // 08
                                                       "Nome Coordenador"        ,; // 09
                                                       "Mat. Supervisor"         ,; // 10
                                                       "Nome Supervisor"         ,; // 11
                                                       "ID Equipe"               ,; // 12
                                                       "Nome Equipe"             ,; // 13
                                                       "ID Tipo Equipe"          ,; // 14
                                                       "Tipo Equipe"             ,; // 15
                                                       "Mat.Funcionário 1"       ,; // 16
                                                       "Nome Funcionário 1"      ,; // 17
                                                       "Mat.Funcionário 2"       ,; // 18
                                                       "Nome Funcionário 2"      ,; // 19
                                                       "Mat.Funcionário 3"       ,; // 20
                                                       "Nome Funcionário 3"      ,; // 21
                                                       "Mat.Funcionário 4"       ,; // 22
                                                       "Nome Funcionário 4"      ,; // 23
                                                       "Mat.Funcionário 5"       ,; // 24
                                                       "Nome Funcionário 5"      ,; // 25
                                                       "Mat.Funcionário 6"       ,; // 26
                                                       "Nome Funcionário 6"      ,; // 27
                                                       "Id Contrato"             ,; // 28
                                                       "Contrato"                ,; // 29
                                                       "ID Centro Serviço"       ,; // 30
                                                       "Centro Serviço"          ,; // 31
                                                       "ID Veículo"              ,; // 32
                                                       "Placa Veículo"           ,; // 33
                                                       "Tipo Veículo"            ,; // 34
                                                       "ID Tipo Veículo"         ,; // 35
                                                       "KM Inicial"              ,; // 36
                                                       "KM Final"                ,; // 37
                                                       "ID Serviço"              ,; // 38
                                                       "Código Serviço"          ,; // 39
                                                       "Descrição Serviço"       ,; // 40
                                                       "Quantidade"              ,; // 41
                                                       "Valor Total Serviço"     ,; // 42
                                                       "Data Comunicação"        ,; // 43
                                                       "Hora Comunicação"        ,; // 44
                                                       "Data Início Deslocamento",; // 45
                                                       "Hora Início Deslocamento",; // 46
                                                       "Data Chegada Local"      ,; // 47
                                                       "Hora Chegada Local"      ,; // 48
                                                       "Data Início Serviço"     ,; // 49
                                                       "Hora Início Serviço"     ,; // 50
                                                       "Data Término Serviço"    ,; // 51
                                                       "Hora Término Serviço"    ,; // 52
                                                       "Latitude Início Desloc." ,; // 53
                                                       "Longitude Início Desl."  ,; // 54
                                                       "Latitude Início Serviço" ,; // 55
                                                       "Longitude Início Serviço",; // 56
                                                       "ID Obra"                 ,; // 57
                                                       "E PEP"                   ,; // 58
	                                                   "Contrato"                ,; // 59
	                                                   "Tipo de Serviço"         ,; // 60
	                                                   "Número Obra Principal"   ,; // 61
	                                                   "Cidade"                  ,; // 62
	                                                   "Data Início Turno"       ,; // 63
	                                                   "Hora Início Turno"       ,; // 64
	                                                   "Data Fim Turno"          ,; // 65
	                                                   "Hora Fim Turno"          ,; // 66
                                                       "Observações"             ,; // 67
                                                       "Data Importação"         ,; // 68
                                                       "Hora Importação"         ,; // 69
                                                       "Arquivo"                 ,; // 70
                                                       "Sequencia"               ,; // 71
                                                       "Usuário"                 },;// 72
                                                       {20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
    
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12], aResumo[oResumo:nAt,13], aResumo[oResumo:nAt,14], aResumo[oResumo:nAt,15],;
                            aResumo[oResumo:nAt,16], aResumo[oResumo:nAt,17], aResumo[oResumo:nAt,18], aResumo[oResumo:nAt,19], aResumo[oResumo:nAt,20],;
                            aResumo[oResumo:nAt,21], aResumo[oResumo:nAt,22], aResumo[oResumo:nAt,23], aResumo[oResumo:nAt,24], aResumo[oResumo:nAt,25],;
                            aResumo[oResumo:nAt,26], aResumo[oResumo:nAt,27], aResumo[oResumo:nAt,28], aResumo[oResumo:nAt,29], aResumo[oResumo:nAt,30],;
                            aResumo[oResumo:nAt,31], aResumo[oResumo:nAt,32], aResumo[oResumo:nAt,33], aResumo[oResumo:nAt,34], aResumo[oResumo:nAt,35],;
                            aResumo[oResumo:nAt,36], aResumo[oResumo:nAt,37], aResumo[oResumo:nAt,38], aResumo[oResumo:nAt,39], aResumo[oResumo:nAt,40],;
                            aResumo[oResumo:nAt,41], aResumo[oResumo:nAt,42], aResumo[oResumo:nAt,43], aResumo[oResumo:nAt,44], aResumo[oResumo:nAt,45],;
                            aResumo[oResumo:nAt,46], aResumo[oResumo:nAt,47], aResumo[oResumo:nAt,48], aResumo[oResumo:nAt,49], aResumo[oResumo:nAt,50],;
                            aResumo[oResumo:nAt,51], aResumo[oResumo:nAt,52], aResumo[oResumo:nAt,53], aResumo[oResumo:nAt,54], aResumo[oResumo:nAt,55],;                            
                            aResumo[oResumo:nAt,56], aResumo[oResumo:nAt,57], aResumo[oResumo:nAt,58], aResumo[oResumo:nAt,59], aResumo[oResumo:nAt,60],;
                            aResumo[oResumo:nAt,61], aResumo[oResumo:nAt,62], aResumo[oResumo:nAt,63], aResumo[oResumo:nAt,64], aResumo[oResumo:nAt,65],;
                            aResumo[oResumo:nAt,66], aResumo[oResumo:nAt,67], aResumo[oResumo:nAt,68], aResumo[oResumo:nAt,69], aResumo[oResumo:nAt,70],;
                            aResumo[oResumo:nAt,71], aResumo[oResumo:nAt,72]}}

   Endif

   // Pesquisa dados do arquivo de METAS
   If yTAG == "METAS"
                         
      aResumo := {}

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf
                   
      cSql := ""
      cSql := "SELECT Z17_FILIAL, Z17_GRUP	,Z17_DATA	,Z17_IDEQ	,Z17_NEQU	,Z17_ITPE	,Z17_TPEQ	,Z17_MELE	,"
      cSql += "       Z17_NELE	, Z17_MPAR	,Z17_NPAR	,Z17_ICNT	,Z17_CONT	,Z17_ICSR	,Z17_CSER	,Z17_MVLR	,"
      cSql += "       Z17_RVAL	, Z17_OBSE	,Z17_JUST	,Z17_IDTR	,Z17_ITPT	,Z17_TPTU	,Z17_HITR	,Z17_HFTR	,"
      cSql += "       Z17_DIMP	, Z17_HIMP	, Z17_ARQU	,Z17_USUA	,Z17_NROS	,Z17_SEQU   "
      cSql += "  FROM " + RetSqlName("Z17")
      cSql += " WHERE Z17_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z17_GRUP	,; // 01
                          T_CONSULTA->Z17_DATA	,; // 02
                          T_CONSULTA->Z17_IDEQ	,; // 03
                          T_CONSULTA->Z17_NEQU	,; // 04
                          T_CONSULTA->Z17_ITPE	,; // 05
                          T_CONSULTA->Z17_TPEQ	,; // 06
                          T_CONSULTA->Z17_MELE	,; // 07
                          T_CONSULTA->Z17_NELE	,; // 08
                          T_CONSULTA->Z17_MPAR	,; // 09
                          T_CONSULTA->Z17_NPAR	,; // 10
                          T_CONSULTA->Z17_ICNT	,; // 11
                          T_CONSULTA->Z17_CONT	,; // 12
                          T_CONSULTA->Z17_ICSR	,; // 13
                          T_CONSULTA->Z17_CSER	,; // 14
                          T_CONSULTA->Z17_MVLR	,; // 15
                          T_CONSULTA->Z17_RVAL	,; // 16
                          T_CONSULTA->Z17_OBSE	,; // 17
                          T_CONSULTA->Z17_JUST	,; // 18
                          T_CONSULTA->Z17_IDTR	,; // 19
                          T_CONSULTA->Z17_ITPT	,; // 20
                          T_CONSULTA->Z17_TPTU	,; // 21
                          T_CONSULTA->Z17_HITR	,; // 22
                          T_CONSULTA->Z17_HFTR	,; // 23
                          T_CONSULTA->Z17_DIMP	,; // 24
                          T_CONSULTA->Z17_HIMP	,; // 25
                          T_CONSULTA->Z17_ARQU	,; // 26
                          T_CONSULTA->Z17_USUA	,; // 27
                          T_CONSULTA->Z17_NROS	,; // 28
                          T_CONSULTA->Z17_SEQU  }) // 29

         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, {"", "", "","", "", "", "", "", "", "",;
                         "", "", "","", "", "", "", "", "", "",; 
                         "", "", "","", "", "", "", "", ""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Grupo"              ,; // 01
                                                       "Data"               ,; // 02
                                                       "ID Equipe"          ,; // 03
                                                       "Nome Equipe"        ,; // 04
                                                       "ID Tipo Equipe"     ,; // 05
                                                       "Tipo Equipe"        ,; // 06
                                                       "Mat. Eletricista"   ,; // 07
                                                       "Nome Eletricista"   ,; // 08
                                                       "Mat. Parceiro"      ,; // 09
                                                       "Nome Parceiro"      ,; // 10
                                                       "ID Contrato"        ,; // 11                           
                                                       "Contrato"           ,; // 12
                                                       "ID Centro Serviço"  ,; // 13
                                                       "Centro de Serviço"  ,; // 14
                                                       "Meta Valor Dia"     ,; // 15
                                                       "Realizado Valor Dia",; // 16
                                                       "Observação"         ,; // 17
                                                       "Justificativa"      ,; // 18
                                                       "ID Turno"           ,; // 19
                                                       "ID Tipo Turno"      ,; // 20
                                                       "Tipo Turno"         ,; // 21
                                                       "Hora Início Turno"  ,; // 22
                                                       "Hora Fim Turno"     ,; // 23
                                                       "Data Importação"    ,; // 24
                                                       "Hora Importação"    ,; // 25
                                                       "Arquivo"            ,; // 26
                                                       "Usuário"            ,; // 27
                                                       "Nº OS"              ,; // 28
                                                       "Sequencia"          ,; // 29
                                                       },{20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
          
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12], aResumo[oResumo:nAt,13], aResumo[oResumo:nAt,14], aResumo[oResumo:nAt,15],;
                            aResumo[oResumo:nAt,16], aResumo[oResumo:nAt,17], aResumo[oResumo:nAt,18], aResumo[oResumo:nAt,19], aResumo[oResumo:nAt,20],;
                            aResumo[oResumo:nAt,21], aResumo[oResumo:nAt,22], aResumo[oResumo:nAt,23], aResumo[oResumo:nAt,24], aResumo[oResumo:nAt,25],;
                            aResumo[oResumo:nAt,26], aResumo[oResumo:nAt,27], aResumo[oResumo:nAt,28], aResumo[oResumo:nAt,29]}}
   Endif
          
   // Pesquisa dados do arquivo de INTERVALOS
   If yTAG == "INTERVALOS"
   
      aResumo := {}
                            
      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf
                   
      cSql := ""
      cSql := "SELECT Z18_FILIAL, Z18_GRUP	, Z18_IDTU	,Z18_IDIN	,Z18_IDMT	,Z18_MOTI	,Z18_DATA	,Z18_HIIN	,"
      cSql += "       Z18_HFIN	, Z18_JUST	, Z18_IDEQ	,Z18_NEQU	,Z18_IDTE	,Z18_TPEQ	,Z18_MELE	,Z18_NELE	,"
      cSql += "       Z18_MPAR	, Z18_NPAR	, Z18_IDCO	,Z18_CONT	,Z18_IDCS	,Z18_CSER	,Z18_DIMP	,Z18_HIMP	,"
      cSql += "       Z18_ARQU	,Z18_USUA	, Z18_NROS	,Z18_SEQU   "
      cSql += "  FROM " + RetSqlName("Z18")
      cSql += " WHERE Z18_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z18_GRUP	,; // 01
                          T_CONSULTA->Z18_IDTU	,; // 02
                          T_CONSULTA->Z18_IDIN	,; // 03
                          T_CONSULTA->Z18_IDMT	,; // 04
                          T_CONSULTA->Z18_MOTI	,; // 05
                          T_CONSULTA->Z18_DATA	,; // 06
                          T_CONSULTA->Z18_HIIN	,; // 07
                          T_CONSULTA->Z18_HFIN	,; // 08
                          T_CONSULTA->Z18_JUST	,; // 09
                          T_CONSULTA->Z18_IDEQ	,; // 10
                          T_CONSULTA->Z18_NEQU	,; // 11
                          T_CONSULTA->Z18_IDTE	,; // 12
                          T_CONSULTA->Z18_TPEQ	,; // 13
                          T_CONSULTA->Z18_MELE	,; // 14
                          T_CONSULTA->Z18_NELE	,; // 15
                          T_CONSULTA->Z18_MPAR	,; // 16
                          T_CONSULTA->Z18_NPAR	,; // 17
                          T_CONSULTA->Z18_IDCO	,; // 18
                          T_CONSULTA->Z18_CONT	,; // 19
                          T_CONSULTA->Z18_IDCS	,; // 20
                          T_CONSULTA->Z18_CSER	,; // 21
                          T_CONSULTA->Z18_DIMP	,; // 22
                          T_CONSULTA->Z18_HIMP	,; // 23
                          T_CONSULTA->Z18_ARQU	,; // 24
                          T_CONSULTA->Z18_USUA	,; // 25
                          T_CONSULTA->Z18_NROS	,; // 26
                          T_CONSULTA->Z18_SEQU  }) // 27

         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, { "","","","","","","","","","",;
                          "","","","","","","","","","",;
                          "","","","","","","",""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Grupo"                ,; // 01
                                                       "ID Turno"             ,; // 02
                                                       "ID Intervalo"         ,; // 03
                                                       "ID Motivo"            ,; // 04
                                                       "Motivo"               ,; // 05
                                                       "Data"                 ,; // 06
                                                       "Hora Início Intervalo",; // 07
                                                       "Hora Fim Intervalo"   ,; // 08
                                                       "Justificativa"        ,; // 09
                                                       "ID Equipe"            ,; // 10
                                                       "Nome Equipe"          ,; // 11
                                                       "ID Tipo Equipe"       ,; // 12
                                                       "Tipo Equipe"          ,; // 13
                                                       "Mat. Eletricista"     ,; // 14
                                                       "Nome Eletricista"     ,; // 15
                                                       "Mat. Parceiro"        ,; // 16
                                                       "Nome Parceiro"        ,; // 17
                                                       "ID Contrato"          ,; // 18
                                                       "Contrato"             ,; // 19
                                                       "ID Centro Serviço"    ,; // 20
                                                       "Centro de Serviço"    ,; // 21
                                                       "Data Importação"      ,; // 22
                                                       "Hora Importação"      ,; // 23
                                                       "Arquivo"              ,; // 24
                                                       "Usuário"              ,; // 25
                                                       "Nº OS"                ,; // 26
                                                       "Sequencia"            ,; // 27
                                                       },{20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
          
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12], aResumo[oResumo:nAt,13], aResumo[oResumo:nAt,14], aResumo[oResumo:nAt,15],;
                            aResumo[oResumo:nAt,16], aResumo[oResumo:nAt,17], aResumo[oResumo:nAt,18], aResumo[oResumo:nAt,19], aResumo[oResumo:nAt,20],;
                            aResumo[oResumo:nAt,21], aResumo[oResumo:nAt,22], aResumo[oResumo:nAt,23], aResumo[oResumo:nAt,24], aResumo[oResumo:nAt,25],;
                            aResumo[oResumo:nAt,26], aResumo[oResumo:nAt,27]}}
   Endif

   // Pesquisa dados do arquivo de METAS PREVISTA
   If yTAG == "METAS PREVISTA"
                         
      aResumo := {}

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z19_FILIAL,"	
      cSql += "       Z19_GRUP	,"
      cSql += "       Z19_IDCO	,"
      cSql += "       Z19_CONT	,"
      cSql += "       Z19_IDEQ	,"
      cSql += "       Z19_NEQU	,"
      cSql += "       Z19_MPRE	,"
      cSql += "       Z19_DIMP	,"
      cSql += "       Z19_HIMP	,"
      cSql += "       Z19_ARQU	,"
      cSql += "       Z19_USUA	,"
      cSql += "       Z19_NROS	,"
      cSql += "       Z19_SEQU   "
      cSql += "  FROM " + RetSqlName("Z19")
      cSql += " WHERE Z19_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z19_GRUP	,; // 01
                          T_CONSULTA->Z19_IDCO	,; // 02
                          T_CONSULTA->Z19_CONT	,; // 03
                          T_CONSULTA->Z19_IDEQ	,; // 04
                          T_CONSULTA->Z19_NEQU	,; // 05
                          T_CONSULTA->Z19_MPRE	,; // 06
                          T_CONSULTA->Z19_DIMP	,; // 07
                          T_CONSULTA->Z19_HIMP	,; // 08
                          T_CONSULTA->Z19_ARQU	,; // 09
                          T_CONSULTA->Z19_USUA	,; // 10
                          T_CONSULTA->Z19_NROS	,; // 11
                          T_CONSULTA->Z19_SEQU  }) // 12

         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, { "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          "",;
                          ""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Grupo"          ,; // 01
                                                       "ID Contrato"    ,; // 02
                                                       "Des. Contrato"  ,; // 03
                                                       "ID Equipe"      ,; // 04
                                                       "Des. Equipe"    ,; // 05
                                                       "Meta Prevista"  ,; // 06
                                                       "Data Importação",; // 07
                                                       "Hora Importação",; // 08
                                                       "Arquivo"        ,; // 09
                                                       "Usuário"        ,; // 10
                                                       "Nº OS"          ,; // 11
                                                       "Sequencia"      ,; // 12
                                                       },{20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
          
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12]}}
   Endif

   // Pesquisa dados do arquivo de OBRAS
   If yTAG == "OBRAS"
                         
      aResumo := {}

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z26_FILIAL, Z26_GRUP, Z26_STATUS, Z26_OBRA, Z26_OPRI, Z26_DOBR, Z26_REGI, Z26_CIDA, Z26_CONT, Z26_RESP,"	
      cSql += "       Z26_DREC  , Z26_IOBR, Z26_FOBR  , Z26_IPOB, Z26_FPOB, Z26_DENE, Z26_DPFE, Z26_DTUF, Z26_VPRE, Z26_VREA,"	
      cSql += "       Z26_VPAG	 , Z26_QPRO, Z26_QPOS , Z26_COBR, Z26_TOBR, Z26_CSER, Z26_SUPE, Z26_PEDI, Z26_DPED, Z26_LATI,"	
      cSql += "       Z26_LONG  , Z26_FISC, Z26_NOTA  , Z26_DNOT, Z26_VIST, Z26_OBSE, Z26_TSER, Z26_ESTO, Z26_DIMP, Z26_HIMP,"	
      cSql += "       Z26_ARQU  , Z26_USUA, Z26_NROS  , Z26_SEQU	                                                         "
      cSql += "  FROM " + RetSqlName("Z26")
      cSql += " WHERE Z26_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z26_FILIAL,; // 01
                          T_CONSULTA->Z26_GRUP  ,; // 02
                          T_CONSULTA->Z26_STATUS,; // 03
                          T_CONSULTA->Z26_OBRA  ,; // 04
                          T_CONSULTA->Z26_OPRI  ,; // 05
                          T_CONSULTA->Z26_DOBR  ,; // 06
                          T_CONSULTA->Z26_REGI  ,; // 07
                          T_CONSULTA->Z26_CIDA  ,; // 08
                          T_CONSULTA->Z26_CONT  ,; // 09
                          T_CONSULTA->Z26_RESP  ,; // 10
                          T_CONSULTA->Z26_DREC  ,; // 11
                          T_CONSULTA->Z26_IOBR  ,; // 12
                          T_CONSULTA->Z26_FOBR  ,; // 13
                          T_CONSULTA->Z26_IPOB  ,; // 14
                          T_CONSULTA->Z26_FPOB  ,; // 15
                          T_CONSULTA->Z26_DENE  ,; // 16
                          T_CONSULTA->Z26_DPFE  ,; // 17
                          T_CONSULTA->Z26_DTUF  ,; // 18
                          T_CONSULTA->Z26_VPRE  ,; // 19
                          T_CONSULTA->Z26_VREA  ,; // 20
                          T_CONSULTA->Z26_VPAG  ,; // 21
                          T_CONSULTA->Z26_QPRO  ,; // 22
                          T_CONSULTA->Z26_QPOS  ,; // 23
                          T_CONSULTA->Z26_COBR  ,; // 24
                          T_CONSULTA->Z26_TOBR  ,; // 25
                          T_CONSULTA->Z26_CSER  ,; // 26
                          T_CONSULTA->Z26_SUPE  ,; // 27
                          T_CONSULTA->Z26_PEDI  ,; // 28
                          T_CONSULTA->Z26_DPED  ,; // 29
                          T_CONSULTA->Z26_LATI  ,; // 30
                          T_CONSULTA->Z26_LONG  ,; // 31
                          T_CONSULTA->Z26_FISC  ,; // 32
                          T_CONSULTA->Z26_NOTA  ,; // 33
                          T_CONSULTA->Z26_DNOT  ,; // 34
                          T_CONSULTA->Z26_VIST  ,; // 35
                          T_CONSULTA->Z26_OBSE  ,; // 36
                          T_CONSULTA->Z26_TSER  ,; // 37
                          T_CONSULTA->Z26_ESTO  ,; // 38
                          T_CONSULTA->Z26_DIMP  ,; // 39
                          T_CONSULTA->Z26_HIMP  ,; // 40
                          T_CONSULTA->Z26_ARQU  ,; // 41
                          T_CONSULTA->Z26_USUA  ,; // 42
                          T_CONSULTA->Z26_NROS  ,; // 43
                          T_CONSULTA->Z26_SEQU	}) // 44

         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, { "", "", "", "", "", "", "", "", "", "",;
                          "", "", "", "", "", "", "", "", "", "",;
                          "", "", "", "", "", "", "", "", "", "",;
                          "", "", "", "", "", "", "", "", "", "",;
                          "", "", "", ""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Filial"                     ,;
                                                       "Grupo"                      ,;
                                                       "Status"                     ,;
                                                       "Número Obra"                ,;
                                                       "Npumero Obra Principal"     ,;
                                                       "Descrição da Obra"          ,;
                                                       "Regional"                   ,;
                                                       "Cidade"                     ,;
                                                       "Contrato"                   ,;
                                                       "Responsável"                ,;
                                                       "Data Recebimento"           ,;
                                                       "Início Execução da Obra"    ,;
                                                       "Fim Execução da Obra"       ,;
                                                       "Início Previsão da Obra"    ,;
                                                       "Fim Previsão da Obra"       ,;
                                                       "Data Energização"           ,;
                                                       "Data protocolo Faturamento" ,;
                                                       "Data UF"                    ,;
                                                       "Valor Previsto"             ,;
                                                       "Valor Real"                 ,;
                                                       "Valor Pago"                 ,;
                                                       "Qtd Postes Previstos"       ,;
                                                       "Qtd de Postes"              ,;
                                                       "Código da Obra"             ,;
                                                       "Tipo da Obra"               ,;
                                                       "Centro de Serviço"          ,;
                                                       "Supervisor"                 ,;
                                                       "Número do Pedido"           ,;
                                                       "Data do Pedido"             ,;
                                                       "Latitude"                   ,;
                                                       "Longitude"                  ,;
                                                       "Fiscal Concessionária"      ,;
                                                       "Nota Fiscal"                ,;
                                                       "Data Nota"                  ,;
                                                       "Vistoria Realizada"         ,;
                                                       "Observações"                ,;
                                                       "Tipo de Serviço"            ,;
                                                       "Código Serviço"             ,;
                                                       "Data Importação"            ,;
                                                       "Hora Importação"            ,;
                                                       "Arquivo Importado"          ,;
                                                       "Usuário"                    ,;
                                                       "Número da OS"               ,;
                                                       "Sequencia"                  ,;
                                                       },{20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
          
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12], aResumo[oResumo:nAt,13], aResumo[oResumo:nAt,14], aResumo[oResumo:nAt,15],;
                            aResumo[oResumo:nAt,16], aResumo[oResumo:nAt,17], aResumo[oResumo:nAt,18], aResumo[oResumo:nAt,19], aResumo[oResumo:nAt,20],;
                            aResumo[oResumo:nAt,21], aResumo[oResumo:nAt,22], aResumo[oResumo:nAt,23], aResumo[oResumo:nAt,24], aResumo[oResumo:nAt,25],;
                            aResumo[oResumo:nAt,26], aResumo[oResumo:nAt,27], aResumo[oResumo:nAt,28], aResumo[oResumo:nAt,29], aResumo[oResumo:nAt,30],;
                            aResumo[oResumo:nAt,31], aResumo[oResumo:nAt,32], aResumo[oResumo:nAt,33], aResumo[oResumo:nAt,34], aResumo[oResumo:nAt,35],;
                            aResumo[oResumo:nAt,36], aResumo[oResumo:nAt,37], aResumo[oResumo:nAt,38], aResumo[oResumo:nAt,39], aResumo[oResumo:nAt,40],;
                            aResumo[oResumo:nAt,41], aResumo[oResumo:nAt,42], aResumo[oResumo:nAt,43], aResumo[oResumo:nAt,44]}}
   Endif

   // Pesquisa dados do arquivo de OBRAS ATIVIDADES
   If yTAG == "OBRAS ATIVIDADES"
                         
      aResumo := {}

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z24_GRUP,"	
      cSql += "       Z24_NOBR,"	
      cSql += "       Z24_OPRI,"
      cSql += "       Z24_CPRE,"
      cSql += "       Z24_UPRE,"
      cSql += "       Z24_QPRE,"
      cSql += "       Z24_USUA,"
      cSql += "       Z24_DPRE,"
      cSql += "       Z24_DIMP,"
      cSql += "       Z24_HIMP,"
      cSql += "       Z24_ARQU,"
      cSql += "       Z24_NROS,"	
      cSql += "       Z24_SEQU "	
      cSql += "  FROM " + RetSqlName("Z24")
      cSql += " WHERE Z24_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z24_GRUP,; // 01	
                          T_CONSULTA->Z24_NOBR,; //	02
                          T_CONSULTA->Z24_OPRI,; // 03
                          T_CONSULTA->Z24_CPRE,; // 04
                          T_CONSULTA->Z24_DPRE,; // 05
                          T_CONSULTA->Z24_UPRE,; // 06
                          T_CONSULTA->Z24_QPRE,; // 07
                          T_CONSULTA->Z24_DIMP,; // 08
                          T_CONSULTA->Z24_HIMP,; // 09
                          T_CONSULTA->Z24_ARQU,; // 10
                          T_CONSULTA->Z24_USUA,; // 11
                          T_CONSULTA->Z24_NROS,; //	12
                          T_CONSULTA->Z24_SEQU}) // 13

         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, { "", "", "", "", "", "", "", "", "", "", "", "", ""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Grupo"                      ,;
                                                       "Número Obra"                ,;
                                                       "Número Obra Principal"      ,;
                                                       "Código Precificação"        ,;
                                                       "Descrição Precificação"     ,;
                                                       "Unidade"                    ,;
                                                       "Quantidade"                 ,;
                                                       "Data Importação"            ,;
                                                       "Hora Importação"            ,;
                                                       "Arquivo Importado"          ,;
                                                       "Usuário"                    ,;
                                                       "Número da OS"               ,;
                                                       "Sequencia"                  ,;
                                                       },{20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
          
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12], aResumo[oResumo:nAt,13]}}
   Endif

   // Pesquisa dados do arquivo de OBRAS MATERIAIS
   If yTAG == "OBRAS MATERIAIS"
                         
      aResumo := {}

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT Z25_GRUP,"
      cSql += "       Z25_NOBR,"
      cSql += "       Z25_OPRI,"	
      cSql += "       Z25_MATE,"	
      cSql += "       Z25_SITU,"	
      cSql += "       Z25_UNID,"	
      cSql += "       Z25_ORCA,"	
      cSql += "       Z25_OVAL,"	
      cSql += "       Z25_PROC,"	
      cSql += "       Z25_ASEP,"	
      cSql += "       Z25_APLI,"	
      cSql += "       Z25_DEVO,"	
      cSql += "       Z25_DPED,"	
      cSql += "       Z25_CUSU,"	
      cSql += "       Z25_DIMP,"	
      cSql += "       Z25_HIMP,"	
      cSql += "       Z25_ARQU,"	
      cSql += "       Z25_USUA,"	
      cSql += "       Z25_NROS,"	
      cSql += "       Z25_SEQU "	
      cSql += "  FROM " + RetSqlName("Z25")
      cSql += " WHERE Z25_ARQU = '" + Alltrim(yArquivo) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      T_CONSULTA->( DbGoTop() )
   
      WHILE !T_CONSULTA->( EOF() )
   
         aAdd( aResumo, { T_CONSULTA->Z25_GRUP,; // 01
                          T_CONSULTA->Z25_NOBR,; // 02
                          T_CONSULTA->Z25_OPRI,; //	03
                          T_CONSULTA->Z25_MATE,; //	04
                          T_CONSULTA->Z25_SITU,; //	05
                          T_CONSULTA->Z25_UNID,; //	06
                          T_CONSULTA->Z25_ORCA,; //	07
                          T_CONSULTA->Z25_OVAL,; //	08
                          T_CONSULTA->Z25_PROC,; //	09
                          T_CONSULTA->Z25_ASEP,; //	10
                          T_CONSULTA->Z25_APLI,; //	11
                          T_CONSULTA->Z25_DEVO,; //	12
                          T_CONSULTA->Z25_DPED,; //	13
                          T_CONSULTA->Z25_CUSU,; //	14
                          T_CONSULTA->Z25_DIMP,; //	15
                          T_CONSULTA->Z25_HIMP,; //	16
                          T_CONSULTA->Z25_ARQU,; //	17
                          T_CONSULTA->Z25_USUA,; //	18
                          T_CONSULTA->Z25_NROS,; //	19
                          T_CONSULTA->Z25_SEQU}) // 20	
         
         T_CONSULTA->( DbSkip() )
      
      ENDDO
      
      If Len(aResumo) == 0
         aAdd( aResumo, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
      Endif
      
      // Desenha o Browse
      oResumo := TCBrowse():New( 035 , 005, 633, 230,,{"Grupo"                      ,;
                                                       "Número Obra"                ,;
                                                       "Número Obra Principal"      ,;
                                                       "Material"                   ,;
                                                       "Situação"                   ,;
                                                       "Unidade"                    ,;
                                                       "Orçado Concessionária"      ,;
                                                       "Orçado Validado"            ,;
                                                       "Processada"                 ,;
                                                       "A Separar"                  ,;
                                                       "Aplicada"                   ,;
                                                       "Devolver"                   ,;
                                                       "Data do Pedido"             ,;
                                                       "Código Usuário"             ,;
                                                       "Data Importação"            ,;
                                                       "Hora Importação"            ,;
                                                       "Arquivo Importado"          ,;
                                                       "Usuário"                    ,;
                                                       "Número da OS"               ,;
                                                       "Sequencia"                  ,;
                                                       },{20,50,50,50},oDlgExplode,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
      // Seta vetor para a browse                            
      oResumo:SetArray(aResumo) 
          
      // Monta a linha a ser exibina no Browse
      oResumo:bLine := {||{ aResumo[oResumo:nAt,01], aResumo[oResumo:nAt,02], aResumo[oResumo:nAt,03], aResumo[oResumo:nAt,04], aResumo[oResumo:nAt,05],;
                            aResumo[oResumo:nAt,06], aResumo[oResumo:nAt,07], aResumo[oResumo:nAt,08], aResumo[oResumo:nAt,09], aResumo[oResumo:nAt,10],;
                            aResumo[oResumo:nAt,11], aResumo[oResumo:nAt,12], aResumo[oResumo:nAt,13], aResumo[oResumo:nAt,14], aResumo[oResumo:nAt,15],;
                            aResumo[oResumo:nAt,16], aResumo[oResumo:nAt,17], aResumo[oResumo:nAt,18], aResumo[oResumo:nAt,19], aResumo[oResumo:nAt,20]}}
   Endif

   ACTIVATE MSDIALOG oDlgExplode CENTERED 

Return(.T.)

// Função que mostra o detalhe do registro selecionado no grid dos IMPORTAODOS
Static Function ImpMostraDetalhes()
   
   Local cDetalhe := ""
   Local oDetalhe
                                                  
   Local oFont10c := TFont():New( "Courier New",,16,,.f.,,,,.f.,.f. )
   
   Private oDlgDetalhes

   // Carrega a variável cDetalhe com os dados do registro selecionado no Grid

   // Serviços
   If Alltrim(aResumo[oResumo:nAt,01]) == "SERVICOS"                   
      cDetalhe := "Grupo.....................: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ;
                  "ID Nota...................: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ;
                  "Nº Nota...................: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ;
                  "ID Tipo Serviço...........: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ;
                  "Origem Sistema............: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ;
                  "Origem Serviço............: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ;
                  "Mat. Coordenador..........: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ;
                  "Nome Coordenador..........: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ;
                  "Mat. Supervisor...........: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ;
                  "Nome Supervisor...........: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ;
                  "ID Equipe.................: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ;
                  "Nome Equipe...............: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10) + ;
                  "ID Tipo Equipe............: " + aResumo[oResumo:nAt,13] + chr(13) + chr(10) + ;
                  "Tipo Equipe...............: " + aResumo[oResumo:nAt,14] + chr(13) + chr(10) + ;
                  "Mat.Funcionário 1.........: " + aResumo[oResumo:nAt,15] + chr(13) + chr(10) + ;
                  "Nome Funcionário 1........: " + aResumo[oResumo:nAt,16] + chr(13) + chr(10) + ;
                  "Mat.Funcionário 2.........: " + aResumo[oResumo:nAt,17] + chr(13) + chr(10) + ;
                  "Nome Funcionário 2........: " + aResumo[oResumo:nAt,18] + chr(13) + chr(10) + ;
                  "Mat.Funcionário 3.........: " + aResumo[oResumo:nAt,19] + chr(13) + chr(10) + ;
                  "Nome Funcionário 3........: " + aResumo[oResumo:nAt,20] + chr(13) + chr(10) + ;
                  "Mat.Funcionário 4.........: " + aResumo[oResumo:nAt,21] + chr(13) + chr(10) + ;
                  "Nome Funcionário 4........: " + aResumo[oResumo:nAt,22] + chr(13) + chr(10) + ;
                  "Mat.Funcionário 5.........: " + aResumo[oResumo:nAt,23] + chr(13) + chr(10) + ;
                  "Nome Funcionário 5........: " + aResumo[oResumo:nAt,24] + chr(13) + chr(10) + ;
                  "Mat.Funcionário 6.........: " + aResumo[oResumo:nAt,25] + chr(13) + chr(10) + ;
                  "Nome Funcionário 6........: " + aResumo[oResumo:nAt,26] + chr(13) + chr(10) + ;
                  "Id Contrato...............: " + aResumo[oResumo:nAt,27] + chr(13) + chr(10) + ;
                  "Contrato..................: " + aResumo[oResumo:nAt,28] + chr(13) + chr(10) + ;
                  "ID Centro Serviço.........: " + aResumo[oResumo:nAt,29] + chr(13) + chr(10) + ;
                  "Centro Serviço............: " + aResumo[oResumo:nAt,30] + chr(13) + chr(10) + ;
                  "ID Veículo................: " + aResumo[oResumo:nAt,31] + chr(13) + chr(10) + ;
                  "Placa Veículo.............: " + aResumo[oResumo:nAt,32] + chr(13) + chr(10) + ;
                  "Tipo Veículo..............: " + aResumo[oResumo:nAt,33] + chr(13) + chr(10) + ;
                  "ID Tipo Veículo...........: " + aResumo[oResumo:nAt,34] + chr(13) + chr(10) + ;
                  "KM Inicial................: " + aResumo[oResumo:nAt,35] + chr(13) + chr(10) + ;
                  "KM Final..................: " + aResumo[oResumo:nAt,36] + chr(13) + chr(10) + ;
                  "ID Serviço................: " + aResumo[oResumo:nAt,37] + chr(13) + chr(10) + ;
                  "Código Serviço............: " + aResumo[oResumo:nAt,38] + chr(13) + chr(10) + ;
                  "Descrição Serviço.........: " + aResumo[oResumo:nAt,39] + chr(13) + chr(10) + ;
                  "Quantidade................: " + aResumo[oResumo:nAt,40] + chr(13) + chr(10) + ;
                  "Valor Total Serviço.......: " + aResumo[oResumo:nAt,41] + chr(13) + chr(10) + ;
                  "Data Comunicação..........: " + aResumo[oResumo:nAt,42] + chr(13) + chr(10) + ;
                  "Hora Comunicação..........: " + aResumo[oResumo:nAt,43] + chr(13) + chr(10) + ;
                  "Data Início Deslocamento..: " + aResumo[oResumo:nAt,44] + chr(13) + chr(10) + ;
                  "Hora Início Deslocamento..: " + aResumo[oResumo:nAt,45] + chr(13) + chr(10) + ;
                  "Data Chegada Local........: " + aResumo[oResumo:nAt,46] + chr(13) + chr(10) + ;
                  "Hora Chegada Local........: " + aResumo[oResumo:nAt,47] + chr(13) + chr(10) + ;
                  "Data Início Serviço.......: " + aResumo[oResumo:nAt,48] + chr(13) + chr(10) + ;
                  "Hora Início Serviço.......: " + aResumo[oResumo:nAt,49] + chr(13) + chr(10) + ;
                  "Data Término Serviço......: " + aResumo[oResumo:nAt,50] + chr(13) + chr(10) + ;
                  "Hora Término Serviço......: " + aResumo[oResumo:nAt,51] + chr(13) + chr(10) + ;
                  "Latitude Início Desloc....: " + aResumo[oResumo:nAt,52] + chr(13) + chr(10) + ;
                  "Longitude Início Desl. ...: " + aResumo[oResumo:nAt,53] + chr(13) + chr(10) + ;
                  "Latitude Início Serviço...: " + aResumo[oResumo:nAt,54] + chr(13) + chr(10) + ;
                  "Longitude Início Serviço..: " + aResumo[oResumo:nAt,55] + chr(13) + chr(10) + ;
                  "ID Obra...................: " + aResumo[oResumo:nAt,56] + chr(13) + chr(10) + ;
                  "E PEP.....................: " + aResumo[oResumo:nAt,57] + chr(13) + chr(10) + ;
                  "Data Importação...........: " + aResumo[oResumo:nAt,58] + chr(13) + chr(10) + ;
                  "Hora Importação...........: " + aResumo[oResumo:nAt,59] + chr(13) + chr(10) + ;
                  "Arquivo...................: " + aResumo[oResumo:nAt,60] + chr(13) + chr(10) + ;
                  "Usuário...................: " + aResumo[oResumo:nAt,61] + chr(13) + chr(10) + ;
                  "Sequencia.................: " + aResumo[oResumo:nAt,62] + chr(13) + chr(10)
   Endif
   
   // Metas
   If Alltrim(aResumo[oResumo:nAt,01]) == "METAS"                   
      cDetalhe := "Grupo................: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ; 
                  "Data.................: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ;
                  "ID Equipe............: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ;
                  "Nome Equipe..........: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ;
                  "ID Tipo Equipe.......: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ;
                  "Tipo Equipe..........: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ;
                  "Mat. Eletricista.....: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ;
                  "Nome Eletricista.....: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ;
                  "Mat. Parceiro........: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ;
                  "Nome Parceiro........: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ;
                  "ID Contrato..........: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ;
                  "Contrato.............: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10) + ;
                  "ID Centro Serviço....: " + aResumo[oResumo:nAt,13] + chr(13) + chr(10) + ;
                  "Centro de Serviço....: " + aResumo[oResumo:nAt,14] + chr(13) + chr(10) + ;
                  "Meta Valor Dia.......: " + aResumo[oResumo:nAt,15] + chr(13) + chr(10) + ;
                  "Realizado Valor Dia..: " + aResumo[oResumo:nAt,16] + chr(13) + chr(10) + ;
                  "Observação...........: " + aResumo[oResumo:nAt,17] + chr(13) + chr(10) + ;
                  "Justificativa........: " + aResumo[oResumo:nAt,18] + chr(13) + chr(10) + ;
                  "ID Turno.............: " + aResumo[oResumo:nAt,19] + chr(13) + chr(10) + ;
                  "ID Tipo Turno........: " + aResumo[oResumo:nAt,20] + chr(13) + chr(10) + ;
                  "Tipo Turno...........: " + aResumo[oResumo:nAt,21] + chr(13) + chr(10) + ;
                  "Hora Início Turno....: " + aResumo[oResumo:nAt,22] + chr(13) + chr(10) + ;
                  "Hora Fim Turno.......: " + aResumo[oResumo:nAt,23] + chr(13) + chr(10) + ;
                  "Data Importação......: " + aResumo[oResumo:nAt,24] + chr(13) + chr(10) + ;
                  "Hora Importação......: " + aResumo[oResumo:nAt,25] + chr(13) + chr(10) + ;
                  "Arquivo..............: " + aResumo[oResumo:nAt,26] + chr(13) + chr(10) + ;
                  "Usuário..............: " + aResumo[oResumo:nAt,27] + chr(13) + chr(10) + ;
                  "Nº OS................: " + aResumo[oResumo:nAt,28] + chr(13) + chr(10) + ;
                  "Sequencia............: " + aResumo[oResumo:nAt,29] + chr(13) + chr(10)
   Endif
   
   // Intervalos
   If Alltrim(aResumo[oResumo:nAt,01]) == "INTERVALOS"                   
      cDetalhe := "Grupo..................: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ; 
                  "ID Turno...............: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ; 
                  "ID Intervalo...........: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ; 
                  "ID Motivo..............: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ; 
                  "Motivo.................: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ; 
                  "Data...................: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ; 
                  "Hora Início Intervalo..: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ; 
                  "Hora Fim Intervalo.....: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ; 
                  "Justificativa..........: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ; 
                  "ID Equipe..............: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ; 
                  "Nome Equipe............: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ; 
                  "ID Tipo Equipe.........: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10) + ; 
                  "Tipo Equipe............: " + aResumo[oResumo:nAt,13] + chr(13) + chr(10) + ; 
                  "Mat. Eletricista.......: " + aResumo[oResumo:nAt,14] + chr(13) + chr(10) + ; 
                  "Nome Eletricista.......: " + aResumo[oResumo:nAt,15] + chr(13) + chr(10) + ; 
                  "Mat. Parceiro..........: " + aResumo[oResumo:nAt,16] + chr(13) + chr(10) + ; 
                  "Nome Parceiro..........: " + aResumo[oResumo:nAt,17] + chr(13) + chr(10) + ; 
                  "ID Contrato............: " + aResumo[oResumo:nAt,18] + chr(13) + chr(10) + ; 
                  "Contrato...............: " + aResumo[oResumo:nAt,19] + chr(13) + chr(10) + ; 
                  "ID Centro Serviço......: " + aResumo[oResumo:nAt,20] + chr(13) + chr(10) + ; 
                  "Centro de Serviço......: " + aResumo[oResumo:nAt,21] + chr(13) + chr(10) + ; 
                  "Data Importação........: " + aResumo[oResumo:nAt,22] + chr(13) + chr(10) + ; 
                  "Hora Importação........: " + aResumo[oResumo:nAt,23] + chr(13) + chr(10) + ; 
                  "Arquivo................: " + aResumo[oResumo:nAt,24] + chr(13) + chr(10) + ; 
                  "Usuário................: " + aResumo[oResumo:nAt,25] + chr(13) + chr(10) + ; 
                  "Nº OS..................: " + aResumo[oResumo:nAt,26] + chr(13) + chr(10) + ; 
                  "Sequencia..............: " + aResumo[oResumo:nAt,27] + chr(13) + chr(10)
   Endif
   
   // Metas Prevista
   If Alltrim(aResumo[oResumo:nAt,01]) == "METAS PREVISTA"                   
      cDetalhe := "Grupo............: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ; 
                  "ID Contrato......: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ; 
                  "Des. Contrato....: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ; 
                  "ID Equipe........: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ; 
                  "Des. Equipe......: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ; 
                  "Meta Prevista....: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ; 
                  "Data Importação..: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ; 
                  "Hora Importação..: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ; 
                  "Arquivo..........: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ; 
                  "Usuário..........: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ; 
                  "Nº OS............: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ; 
                  "Sequencia........: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10)
   Endif

   // Pesquisa dados do arquivo de OBRAS
   If Alltrim(aResumo[oResumo:nAt,02]) == "OBRAS"                   
      cDetalhe := "Filial.....................: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ; 
                  "Grupo......................: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ; 
                  "Status.....................: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ; 
                  "Número Obra................: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ; 
                  "Número Obra Principal......: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ; 
                  "Descrição da Obra..........: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ; 
                  "Regional...................: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ; 
                  "Cidade.....................: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ; 
                  "Contrato...................: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ; 
                  "Responsável................: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ; 
                  "Data Recebimento...........: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ; 
                  "Início Execução da Obra....: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10) + ; 
                  "Fim Execução da Obra.......: " + aResumo[oResumo:nAt,13] + chr(13) + chr(10) + ; 
                  "Início Previsão da Obra....: " + aResumo[oResumo:nAt,14] + chr(13) + chr(10) + ; 
                  "Fim Previsão da Obra.......: " + aResumo[oResumo:nAt,15] + chr(13) + chr(10) + ; 
                  "Data Energização...........: " + aResumo[oResumo:nAt,16] + chr(13) + chr(10) + ; 
                  "Data protocolo Faturamento.: " + aResumo[oResumo:nAt,17] + chr(13) + chr(10) + ; 
                  "Data UF....................: " + aResumo[oResumo:nAt,18] + chr(13) + chr(10) + ; 
                  "Valor Previsto.............: " + aResumo[oResumo:nAt,19] + chr(13) + chr(10) + ; 
                  "Valor Real.................: " + aResumo[oResumo:nAt,20] + chr(13) + chr(10) + ; 
                  "Valor Pago.................: " + aResumo[oResumo:nAt,21] + chr(13) + chr(10) + ; 
                  "Qtd Postes Previstos.......: " + aResumo[oResumo:nAt,22] + chr(13) + chr(10) + ; 
                  "Qtd de Postes..............: " + aResumo[oResumo:nAt,23] + chr(13) + chr(10) + ; 
                  "Código da Obra.............: " + aResumo[oResumo:nAt,24] + chr(13) + chr(10) + ; 
                  "Tipo da Obra...............: " + aResumo[oResumo:nAt,25] + chr(13) + chr(10) + ; 
                  "Centro de Serviço..........: " + aResumo[oResumo:nAt,26] + chr(13) + chr(10) + ; 
                  "Supervisor.................: " + aResumo[oResumo:nAt,27] + chr(13) + chr(10) + ; 
                  "Número do Pedido...........: " + aResumo[oResumo:nAt,28] + chr(13) + chr(10) + ; 
                  "Data do Pedido.............: " + aResumo[oResumo:nAt,29] + chr(13) + chr(10) + ; 
                  "Latitude...................: " + aResumo[oResumo:nAt,30] + chr(13) + chr(10) + ; 
                  "Longitude..................: " + aResumo[oResumo:nAt,31] + chr(13) + chr(10) + ; 
                  "Fiscal Concessionária......: " + aResumo[oResumo:nAt,32] + chr(13) + chr(10) + ; 
                  "Nota Fiscal................: " + aResumo[oResumo:nAt,33] + chr(13) + chr(10) + ; 
                  "Data Nota..................: " + aResumo[oResumo:nAt,34] + chr(13) + chr(10) + ; 
                  "Vistoria Realizada.........: " + aResumo[oResumo:nAt,35] + chr(13) + chr(10) + ; 
                  "Observações................: " + aResumo[oResumo:nAt,36] + chr(13) + chr(10) + ; 
                  "Tipo de Serviço............: " + aResumo[oResumo:nAt,37] + chr(13) + chr(10) + ; 
                  "Código Serviço.............: " + aResumo[oResumo:nAt,38] + chr(13) + chr(10) + ; 
                  "Data Importação............: " + aResumo[oResumo:nAt,39] + chr(13) + chr(10) + ; 
                  "Hora Importação............: " + aResumo[oResumo:nAt,40] + chr(13) + chr(10) + ; 
                  "Arquivo Importado..........: " + aResumo[oResumo:nAt,41] + chr(13) + chr(10) + ; 
                  "Usuário....................: " + aResumo[oResumo:nAt,42] + chr(13) + chr(10) + ; 
                  "Número da OS...............: " + aResumo[oResumo:nAt,43] + chr(13) + chr(10) + ; 
                  "Sequencia..................: " + aResumo[oResumo:nAt,44] + chr(13) + chr(10) 
   Endif

   // Pesquisa dados do arquivo de OBRAS ATIVIDADES
   If Alltrim(aResumo[oResumo:nAt,01]) == "OBRAS ATIVIDADES"                   
      cDetalhe := "Grupo......................: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ; 
                  "Número Obra................: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ; 
                  "Número Obra Principal......: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ; 
                  "Código Precificação........: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ; 
                  "Descrição Precificação.....: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ; 
                  "Unidade....................: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ; 
                  "Quantidade.................: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ; 
                  "Data Importação............: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ; 
                  "Hora Importação............: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ; 
                  "Arquivo Importado..........: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ; 
                  "Usuário....................: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ; 
                  "Número da OS...............: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10) + ; 
                  "Sequencia..................: " + aResumo[oResumo:nAt,13] + chr(13) + chr(10)
   Endif

   // Pesquisa dados do arquivo de OBRAS MATERIAIS
   If Alltrim(aResumo[oResumo:nAt,01]) == "OBRAS MATERIAIS"
      cDetalhe := "Grupo.....................: " + aResumo[oResumo:nAt,01] + chr(13) + chr(10) + ; 
                  "Número Obra...............: " + aResumo[oResumo:nAt,02] + chr(13) + chr(10) + ; 
                  "Número Obra Principal.....: " + aResumo[oResumo:nAt,03] + chr(13) + chr(10) + ; 
                  "Material..................: " + aResumo[oResumo:nAt,04] + chr(13) + chr(10) + ; 
                  "Situação..................: " + aResumo[oResumo:nAt,05] + chr(13) + chr(10) + ; 
                  "Unidade...................: " + aResumo[oResumo:nAt,06] + chr(13) + chr(10) + ; 
                  "Orçado Concessionária.....: " + aResumo[oResumo:nAt,07] + chr(13) + chr(10) + ; 
                  "Orçado Validado...........: " + aResumo[oResumo:nAt,08] + chr(13) + chr(10) + ; 
                  "Processada................: " + aResumo[oResumo:nAt,09] + chr(13) + chr(10) + ; 
                  "A Separar.................: " + aResumo[oResumo:nAt,10] + chr(13) + chr(10) + ; 
                  "Aplicada..................: " + aResumo[oResumo:nAt,11] + chr(13) + chr(10) + ; 
                  "Devolver..................: " + aResumo[oResumo:nAt,12] + chr(13) + chr(10) + ; 
                  "Data do Pedido............: " + aResumo[oResumo:nAt,13] + chr(13) + chr(10) + ; 
                  "Código Usuário............: " + aResumo[oResumo:nAt,14] + chr(13) + chr(10) + ; 
                  "Data Importação...........: " + aResumo[oResumo:nAt,15] + chr(13) + chr(10) + ; 
                  "Hora Importação...........: " + aResumo[oResumo:nAt,16] + chr(13) + chr(10) + ; 
                  "Arquivo Importado.........: " + aResumo[oResumo:nAt,17] + chr(13) + chr(10) + ; 
                  "Usuário...................: " + aResumo[oResumo:nAt,18] + chr(13) + chr(10) + ; 
                  "Número da OS..............: " + aResumo[oResumo:nAt,19] + chr(13) + chr(10) + ; 
                  "Sequencia.................: " + aResumo[oResumo:nAt,20] + chr(13) + chr(10)
   Endif
               
   DEFINE MSDIALOG oDlgDetalhes TITLE "Importação Arquivos GPM - Geração de OS" FROM C(178),C(181) TO C(613),C(670) PIXEL

   @ C(005),C(005) Say "Detalhes do registro selecionado" Size C(081),C(008) COLOR CLR_BLACK PIXEL OF oDlgDetalhes
   @ C(014),C(005) GET oDetalhe Var cDetalhe MEMO         Size C(235),C(182) Font oFont10c   PIXEL OF oDlgDetalhes
   @ C(199),C(103) Button "Voltar"                        Size C(037),C(012)                 PIXEL OF oDlgDetalhes ACTION( oDlgDetalhes:End() )

   ACTIVATE MSDIALOG oDlgDetalhes CENTERED 
   
Return(.T.)

// Função que gera a verificação de inconsistências antes da inclusão de OS
// Esta consistência será gerada para todos os registros com Z20_NROS = < Branco >
Static Function GeraInconsistencias(yContrato, yCentroServico, yTipoServico, yObraPrincipal)

   Local cSql        := ""
   Local cMensagem   := ""
   Local cRetornoLog := ""

   cMensagem   := ""
   cRetornoLog := ""
      
   // Verifica se a Orbra Principal já foi cadastrada no Sistema Prottheus
   If Select("T_JAREGISTRADA") > 0
      T_JAREGISTRADA->( dbCloseArea() )
   EndIf
                   
   cSql := ""
   cSql := "SELECT AB6_FILIAL,"
   cSql += "       AB6_NUMOS ,"
   cSql += "       AB6_NROBRA "
   cSql += "  FROM " + RetSqlName("AB6") 
   cSql += " WHERE AB6_NROBRA = '" + Alltrim(yObraPrincipal) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAREGISTRADA", .T., .T. )
   
   If T_JAREGISTRADA->( EOF() )
   Else
      cMensagem := cMensagem + "[XXXXX]"
      cRetornoLog := Alltrim(cMensagem)
      Return(cRetornoLog)                                      
   Endif   
      
   // Validação Parâmetros CRIAÇÃO DE OS
   If Select("T_PARAMZ11") > 0
      T_PARAMZ11->( dbCloseArea() )
   EndIf
                   
   cSql := ""
   cSql := "SELECT Z11_FILIAL," + CHR(13)	
   cSql += "       Z11_CONT	 ," + CHR(13)	
   cSql += "       Z11_CENT	 ," + CHR(13)	
   cSql += "       Z11_TIPO	 ," + CHR(13)	
   cSql += "       Z11_CRIA	 ," + CHR(13)	
   cSql += "       Z11_EMPR	 ," + CHR(13)	
   cSql += "       Z11_FILI	 ," + CHR(13)	
   cSql += "       Z11_CLIE	 ," + CHR(13)	
   cSql += "       Z11_LOJA	 ," + CHR(13)	
   cSql += "       Z11_COND	 ," + CHR(13)	
   cSql += "       Z11_TABE	 ," + CHR(13)	
   cSql += "       Z11_TPOS	 ," + CHR(13)	
   cSql += "       Z11_CSER	 ," + CHR(13)	
   cSql += "       Z11_SEQU	 ," + CHR(13)	
   cSql += "       Z11_DINI	 ," + CHR(13)	
   cSql += "       Z11_DFIM   " + CHR(13)	
   cSql += "  FROM " + RetSqlName("Z11")                           + CHR(13)	
   cSql += " WHERE Z11_CONT   = '" + Alltrim(yContrato)      + "'" + CHR(13)	
   cSql += "   AND Z11_CENT   = '" + Alltrim(yCentroServico) + "'" + CHR(13)	
   cSql += "   AND Z11_TIPO   = '" + Alltrim(yTipoServico)   + "'" + CHR(13)	
   cSql += "   AND Z11_SEQU   = '000'"                             + CHR(13)	
   cSql += "   AND D_E_L_E_T_ = ''"                                + CHR(13)	

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ11", .T., .T. )

   If T_PARAMZ11->( Eof() )
      cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Não existem parametros Gerais cadastrados para este registro." + "|"
   Else
      
      // Verirfica se existe parâmetros para criação de OS para o registro lido para a Empresa/Filial Logada
      If Select("T_PARAMZ11") > 0
         T_PARAMZ11->( dbCloseArea() )
      EndIf
                   
      cSql := ""
      cSql := "SELECT Z11_FILIAL,"	
      cSql += "       Z11_CONT	,"
      cSql += "       Z11_CENT	,"
      cSql += "       Z11_TIPO	,"
      cSql += "       Z11_CRIA	,"
      cSql += "       Z11_EMPR	,"
      cSql += "       Z11_FILI	,"
      cSql += "       Z11_CLIE	,"
      cSql += "       Z11_LOJA	,"
      cSql += "       Z11_COND	,"
      cSql += "       Z11_TABE	,"
      cSql += "       Z11_TPOS	,"
      cSql += "       Z11_CSER	,"
      cSql += "       Z11_SEQU	,"
      cSql += "       Z11_DINI	,"
      cSql += "       Z11_DFIM   "
      cSql += "  FROM " + RetSqlName("Z11")
      cSql += " WHERE Z11_CONT   = '" + Alltrim(yContrato)      + "'"
      cSql += "   AND Z11_CENT   = '" + Alltrim(yCentroServico) + "'"
      cSql += "   AND Z11_TIPO   = '" + Alltrim(yTipoServico)   + "'"
      cSql += "   AND Z11_EMPR   = '" + Alltrim(cEmpAnt)        + "'"
      cSql += "   AND Z11_FILI   = '" + Alltrim(cFilAnt)        + "'"  
      cSql += "   AND Z11_SEQU   > '000'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ11", .T., .T. )

      If T_PARAMZ11->( Eof() )
         cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Não existem parâmetros de Lançamento cadastados para este registro." + "|"
      Else

         // Consiste o cliente do parâmetro
         If Empty(Alltrim(T_PARAMZ11->Z11_CLIE) + Alltrim(T_PARAMZ11->Z11_LOJA))                              
            cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Cliente não informando para este registro." + "|"
         Else
            If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + T_PARAMZ11->Z11_CLIE + T_PARAMZ11->Z11_LOJA, "A1_NOME")))
               cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Cliente " + T_PARAMZ11->Z11_CLIE + "." + T_PARAMZ11->Z11_LOJA + " não cadastrado." + "|"
            Endif            
         Endif

         // Consiste a Condição de Pagamento do parâmetro
         If Empty(Alltrim(T_PARAMZ11->Z11_COND))
            cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Condição de Pagamento não informanda para este registro." + "|"
         Else
            If Empty(Alltrim(POSICIONE("SE4",1,XFILIAL("SE4") + T_PARAMZ11->Z11_COND, "E4_DESCRI")))
               cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Condição de Pagamento " + T_PARAMZ11->Z11_COND + " não cadastrada." + "|"
            Endif            
         Endif
                  
         // Consiste a Tabela de Preço do parâmetro
         If Empty(Alltrim(T_PARAMZ11->Z11_TABE))
            cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Tabela de Preço não informanda para este registro." + "|"
         Else
            If Empty(Alltrim(POSICIONE("DA0",1,XFILIAL("DA0") + T_PARAMZ11->Z11_TABE, "DA0_DESCRI")))
               cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Tabela de Preço " + T_PARAMZ11->Z11_TABE + " não cadastrada para este registro." + "|"
            Endif            
         Endif

         // Consiste o Tipo de OS do Parâmetro
         If Empty(Alltrim(T_PARAMZ11->Z11_TPOS))
            cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Tipo de OS não informanda para este registro." + "|"
         Else
            If Empty(Alltrim(POSICIONE("Z10",1,XFILIAL("Z10") + T_PARAMZ11->Z11_TPOS, "Z10_DESC")))
               cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Tipo de OS " + T_PARAMZ11->Z11_TPOS + " não cadastrada para este registro." + "|"
            Endif            
         Endif

         // Consiste o Tipo de Serviço do Parâmetro
         If Empty(Alltrim(T_PARAMZ11->Z11_CSER))
            cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Tipo de Serviço não informando para este registro." + "|"
         Else
            If Empty(Alltrim(POSICIONE("AA5",1,XFILIAL("AA5") + T_PARAMZ11->Z11_CSER, "AA5_DESCRI")))
               cMensagem := cMensagem + "[ CRIAÇÃO DE OS          ] - Tipo de Serviço " + T_PARAMZ11->Z11_CSER + " não cadastrado para este registro." + "|"
            Endif            
         Endif
      
      Endif
         
   Endif
   
   // Validação Parâmetros TIPO DE SERVIÇOS
   If Select("T_PARAMZ15") > 0
      T_PARAMZ15->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z15_FILIAL,"	
   cSql += "       Z15_TIPO	 ,"
   cSql += "       Z15_SEQU	 ,"
   cSql += "       Z15_EMPR	 ,"
   cSql += "       Z15_FILI	 ,"
   cSql += "       Z15_PROD	 ,"
   cSql += "       Z15_NOME   "
   cSql += "  FROM " + RetSqlName("Z15")
   cSql += " WHERE Z15_TIPO   = '" + Alltrim(yTipoServico)   + "'"
   cSql += "   AND Z15_SEQU   = '000'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ15", .T., .T. )

   If T_PARAMZ15->( Eof() )
      cMensagem := cMensagem + "[ TIPO DE SERVIÇO        ] - Não existem parâmetros Gerais cadastrados para este registro." + "|"
   Else
      
      // Verirfica se existe parâmetros para criação de OS para o registro lido para a Empresa/Filial Logada
      If Select("T_PARAMZ15") > 0
         T_PARAMZ15->( dbCloseArea() )
      EndIf
                   
      cSql := ""
      cSql := "SELECT Z15_FILIAL,"	
      cSql += "       Z15_TIPO	 ,"
      cSql += "       Z15_SEQU	 ,"
      cSql += "       Z15_EMPR	 ,"
      cSql += "       Z15_FILI	 ,"
      cSql += "       Z15_PROD	 ,"
      cSql += "       Z15_NOME   "
      cSql += "  FROM " + RetSqlName("Z15")
      cSql += " WHERE Z15_TIPO   = '" + Alltrim(yTipoServico)   + "'"
      cSql += "   AND Z15_EMPR   = '" + Alltrim(cEmpAnt)        + "'"
      cSql += "   AND Z15_FILI   = '" + Alltrim(cFilAnt)        + "'"
      cSql += "   AND Z15_SEQU   > '000'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ15", .T., .T. )

      If T_PARAMZ11->( Eof() )
         cMensagem := cMensagem + "[ TIPO DE SERVIÇO        ] - Não existem parâmetros de Lançamento cadastrados para este registro." + "|"
      Else

         // Consiste o código do produto
         If Empty(Alltrim(T_PARAMZ15->Z15_PROD))                              
            cMensagem := cMensagem + "[ TIPO DE SERVIÇO        ] - Código do produto não informado para este registro." + "|"
         Else
            If Empty(Alltrim(POSICIONE("Z10",1,XFILIAL("Z10") + T_PARAMZ15->Z15_PROD, "Z10_DESC")))
               cMensagem := cMensagem + "[ TIPO DE SERVIÇO        ] - Produto " + T_PARAMZ15->Z15_PROD + " não cadastrado." + "|"
            Endif            
         Endif

         // Consiste a descrição do produto
         If Empty(Alltrim(T_PARAMZ15->Z15_NOME))
            cMensagem := cMensagem + "[ TIPO DE SERVIÇO        ] - Descrição do Produto não informada." + "|"
         Endif      
      Endif
         
   Endif

   // Validação parâmetros ITENS DE ATENDIMENTO
   If Select("T_PARAMZ13") > 0
      T_PARAMZ13->( dbCloseArea() )
   EndIf
                   
   cSql := ""
   cSql := "SELECT Z13_FILIAL,"	
   cSql += "       Z13_CONT	 ,"
   cSql += "       Z13_CENT	 ,"
   cSql += "       Z13_TIPO	 ,"
   cSql += "       Z13_SEQU	 ,"
   cSql += "       Z13_IT01	 ,"
   cSql += "       Z13_PR01	 ,"
   cSql += "       Z13_IT02	 ,"
   cSql += "       Z13_PR02	 ,"
   cSql += "       Z13_IT03	 ,"
   cSql += "       Z13_PR03	 ,"
   cSql += "       Z13_IT04	 ,"
   cSql += "       Z13_PR04	 ,"
   cSql += "       Z13_IT05	 ,"
   cSql += "       Z13_PR05	 ,"
   cSql += "       Z13_IT06	 ,"
   cSql += "       Z13_PR06	 ,"
   cSql += "       Z13_IT07	 ,"
   cSql += "       Z13_PR07	 ,"
   cSql += "       Z13_IT08	 ,"
   cSql += "       Z13_PR08	 ,"
   cSql += "       Z13_EMPR	 ,"
   cSql += "       Z13_FILI   "
   cSql += "  FROM " + RetSqlName("Z13")
   cSql += " WHERE Z13_CONT   = '" + Alltrim(yContrato)      + "'"
   cSql += "   AND Z13_CENT   = '" + Alltrim(yCentroServico) + "'"
   cSql += "   AND Z13_TIPO   = '" + Alltrim(yTipoServico)   + "'"
   cSql += "   AND Z13_SEQU   = '000'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ13", .T., .T. )

   If T_PARAMZ13->( Eof() )
      cMensagem := cMensagem + "[ ITENS DE ATENDIMENTO   ] - Não existem parametros Gerais cadastrados para este registro." + "|"
   Else
      
      // Verirfica se existe parâmetros para criação de OS para o registro lido para a Empresa/Filial Logada
      If Select("T_PARAMZ13") > 0
         T_PARAMZ13->( dbCloseArea() )
      EndIf
                   
      cSql := ""
      cSql := "SELECT Z13_FILIAL,"	
      cSql += "       Z13_CONT	 ,"
      cSql += "       Z13_CENT	 ,"
      cSql += "       Z13_TIPO	 ,"
      cSql += "       Z13_SEQU	 ,"
      cSql += "       Z13_IT01	 ,"
      cSql += "       Z13_PR01	 ,"
      cSql += "       Z13_IT02	 ,"
      cSql += "       Z13_PR02	 ,"
      cSql += "       Z13_IT03	 ,"
      cSql += "       Z13_PR03	 ,"
      cSql += "       Z13_IT04	 ,"
      cSql += "       Z13_PR04	 ,"
      cSql += "       Z13_IT05	 ,"
      cSql += "       Z13_PR05	 ,"
      cSql += "       Z13_IT06	 ,"
      cSql += "       Z13_PR06	 ,"
      cSql += "       Z13_IT07	 ,"
      cSql += "       Z13_PR07	 ,"
      cSql += "       Z13_IT08	 ,"
      cSql += "       Z13_PR08	 ,"
      cSql += "       Z13_EMPR	 ,"
      cSql += "       Z13_FILI   "
      cSql += "  FROM " + RetSqlName("Z13")
      cSql += " WHERE Z13_CONT   = '" + Alltrim(yContrato)      + "'"
      cSql += "   AND Z13_CENT   = '" + Alltrim(yCentroServico) + "'"
      cSql += "   AND Z13_TIPO   = '" + Alltrim(yTipoServico)   + "'"
      cSql += "   AND Z13_EMPR   = '" + Alltrim(cEmpAnt)        + "'"
      cSql += "   AND Z13_FILI   = '" + Alltrim(cFilAnt)        + "'"
      cSql += "   AND Z13_SEQU   > '000'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ13", .T., .T. )

      If T_PARAMZ13->( Eof() )
         cMensagem := cMensagem + "[ ITENS DE ATENDIMENTO   ] - Não existem parâmetros de Lançamento cadastados para este registro." + "|"
      Else
         If Empty(ALLTRIM(T_PARAMZ13->Z13_IT01) + ALLTRIM(T_PARAMZ13->Z13_IT02) + ALLTRIM(T_PARAMZ13->Z13_IT03) + ;
                  ALLTRIM(T_PARAMZ13->Z13_IT04) + ALLTRIM(T_PARAMZ13->Z13_IT05) + ALLTRIM(T_PARAMZ13->Z13_IT06) + ;
                  ALLTRIM(T_PARAMZ13->Z13_IT07) + ALLTRIM(T_PARAMZ13->Z13_IT08))
            cMensagem := cMensagem + "[ ITENS DE ATENDIMENTO   ] - Não existem parâmetros de Lançamento cadastados para este registro." + "|"
         Else
            If Empty(ALLTRIM(T_PARAMZ13->Z13_PR01) + ALLTRIM(T_PARAMZ13->Z13_PR02) + ALLTRIM(T_PARAMZ13->Z13_PR03) + ;
                     ALLTRIM(T_PARAMZ13->Z13_PR04) + ALLTRIM(T_PARAMZ13->Z13_PR05) + ALLTRIM(T_PARAMZ13->Z13_PR06) + ;
                     ALLTRIM(T_PARAMZ13->Z13_PR07) + ALLTRIM(T_PARAMZ13->Z13_PR08))
               cMensagem := cMensagem + "[ ITENS DE ATENDIMENTO   ] - Não existem parâmetros de Lançamento cadastados para este registro." + "|"
            Endif
         Endif
      Endif      
         
   Endif

   // Validação Parâmetros ATENDIMENTO DE EQUIPE
   If Select("T_PARAMZ14") > 0
      T_PARAMZ14->( dbCloseArea() )
   EndIf
                   
   cSql := ""
   cSql := "SELECT Z14_FILIAL,"	
   cSql += "       Z14_CONT	 ,"
   cSql += "       Z14_CENT	 ,"
   cSql += "       Z14_TIPO	 ,"
   cSql += "       Z14_CSER	 ,"
   cSql += "       Z14_SEQU	 ,"
   cSql += "       Z14_EMPR	 ,"
   cSql += "       Z14_FILI	 ,"
   cSql += "       Z14_PROD   "
   cSql += "  FROM " + RetSqlName("Z14")
   cSql += " WHERE Z14_CONT   = '" + Alltrim(yContrato)      + "'"
   cSql += "   AND Z14_CENT   = '" + Alltrim(yCentroServico) + "'"
   cSql += "   AND Z14_TIPO   = '" + Alltrim(yTipoServico)   + "'"
   cSql += "   AND Z14_SEQU   = '000'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ14", .T., .T. )

   If T_PARAMZ13->( Eof() )
      cMensagem := cMensagem + "[ ATENDIMENTO DE EQUIPES ] - Não existem parametros Gerais cadastrados para este registro." + "|"
   Else
      
      // Verirfica se existe parâmetros para criação de OS para o registro lido para a Empresa/Filial Logada
      If Select("T_PARAMZ14") > 0
         T_PARAMZ14->( dbCloseArea() )
      EndIf
                   
      cSql := ""
      cSql := "SELECT Z14_FILIAL,"	
      cSql += "       Z14_CONT	 ,"
      cSql += "       Z14_CENT	 ,"
      cSql += "       Z14_TIPO	 ,"
      cSql += "       Z14_CSER	 ,"
      cSql += "       Z14_SEQU	 ,"
      cSql += "       Z14_EMPR	 ,"
      cSql += "       Z14_FILI	 ,"
      cSql += "       Z14_PROD   "
      cSql += "  FROM " + RetSqlName("Z14")
      cSql += " WHERE Z14_CONT   = '" + Alltrim(yContrato)      + "'"
      cSql += "   AND Z14_CENT   = '" + Alltrim(yCentroServico) + "'"
      cSql += "   AND Z14_TIPO   = '" + Alltrim(yTipoServico)   + "'"
      cSql += "   AND Z14_EMPR   = '" + Alltrim(cEmpAnt)        + "'"
      cSql += "   AND Z14_FILI   = '" + Alltrim(cFilAnt)        + "'"
      cSql += "   AND Z14_SEQU   > '000'"
      cSql += "   AND D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMZ14", .T., .T. )

      If T_PARAMZ14->( Eof() )
         cMensagem := cMensagem + "[ ATENDIMENTO DE EQUIPES ] - Não existem parâmetros de Lançamento cadastados para este registro." + "|"
      Else
         If Empty(ALLTRIM(T_PARAMZ14->Z14_PROD))
            cMensagem := cMensagem + "[ ATENDIMENTO DE EQUIPES ] - Produto de Atendimento não informado para este registro." + "|"
         Endif
      Endif      
         
   Endif

   cRetornoLog := Alltrim(cMensagem)
          
Return(cRetornoLog)                                      

// Função que gera o reprocesamento para os registros que apresentaram inconsistências
// Primeiro este processo gera novamente a consistência dos dados antes dp reprocessamento
Static Function ReprocessaGpm()

   MsgRun("Aguarde! Reprocessando Registros ...", "Importação Json GPM",{|| xReprocessaGpm() })

Return(.T.)
               
// Função que gera o reprocesamento para os registros que apresentaram inconsistências
// Primeiro este processo gera novamente a consistência dos dados antes dp reprocessamento
Static Function xReprocessaGpm()

   Local cSql := ""

   // Pesquisa todos os lanlamentos com Z20_NROS = < Branco >
   If Select("T_RODAR") > 0
      T_RODAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT Z20_FILIAL, Z20_CSER	 , Z20_CIDA	 , Z20_CSRV	 , Z20_CONT	 , Z20_DATA	 , Z20_DCHL	 , Z20_DCOM	 , Z20_DFMT	 ,"
   cSql += "       Z20_DIDS	 , Z20_DISR  , Z20_DITR	 , Z20_DTSR	 , Z20_DCON	 , Z20_DEQU	 , Z20_DSRV	 , Z20_EPEP	 , Z20_GRUP	 ,"
   cSql += "       Z20_HCHL	 , Z20_HCOM	 , Z20_HFIT	 , Z20_HFTR	 , Z20_HIDS	 , Z20_HIIN	 , Z20_HISR	 , Z20_HITR	 , Z20_HTSR	 ,"
   cSql += "       Z20_IDCS	 , Z20_IDCT	 , Z20_IDEQ	 , Z20_IDIN	 , Z20_IDMT	 , Z20_IDNT	 , Z20_IDOB	 , Z20_IDSR	 , Z20_IDTE	 ,"
   cSql += "       Z20_IDTS	 , Z20_IDTT	 , Z20_IDTV	 , Z20_IDTN	 , Z20_IDVE	 , Z20_JUST	 , Z20_KMFM	 , Z20_KMIN	 , Z20_LIDS	 ,"
   cSql += "       Z20_LISR	 , Z20_LOID	 , Z20_LOIS	 , Z20_MCOO	 , Z20_MELE	 , Z20_MF01	 , Z20_MF02	 , Z20_MF03	 , Z20_MF04	 ,"
   cSql += "       Z20_MF05	 , Z20_MF06	 , Z20_MPAR	 , Z20_MSUP	 , Z20_MPRE	 , Z20_MVLR	 , Z20_MOTI	 , Z20_NCOO	 , Z20_NELE	 ,"
   cSql += "       Z20_NEQU	 , Z20_NF01	 , Z20_NF02	 , Z20_NF03	 , Z20_NF04	 , Z20_NF05	 , Z20_NF06	 , Z20_NPAR	 , Z20_NSUP	 ,"
   cSql += "       Z20_NNOT	 , Z20_NOBR	 , Z20_NOPR	 , Z20_OBSE	 , Z20_OSRV	 , Z20_OSIS	 , Z20_PLAC	 , Z20_QUAN	 , Z20_RVDI	 ,"
   cSql += "       Z20_TSR1	 , Z20_TEQU	 , Z20_TTUR	 , Z20_TVEI	 , Z20_VSRV	 , Z20_DIMP	 , Z20_HIMP	 , Z20_ARQU	 , Z20_USUA	 ,"
   cSql += "       Z20_NROS	 , Z20_SEQU  , Z20_STATUS, R_E_C_N_O_ AS REGISTRO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), Z20_LOGE)) AS LOGERRO"   
   cSql += "  FROM " + RetSqlName("Z20")
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND Z20_NROS   = '' "
   cSql += " ORDER BY Z20_FILIAL, Z20_ARQU, Z20_SEQU"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RODAR", .T., .T. )

   T_RODAR->( DbGoTop() )
   
   WHILE !T_RODAR->( EOF() )

      // Envia para a função que consiste os dados do registro antes do fechamento 
      cMsgLog := GeraInconsistencias(T_RODAR->Z20_IDCT, T_RODAR->Z20_IDCS, T_RODAR->Z20_IDTS)

      If Empty(Alltrim(cMsgLog))
         If !Empty(Alltrim(T_RODAR->LOGERRO))
            cSql := ""
            cSql := "UPDATE " + RetSqlName("Z20")
            cSql += "   SET Z20_STATUS = '0',"
            cSql += "       Z20_LOGE   = CONVERT(varbinary(8000), '" + Alltrim(T_RODAR->LOGERRO)     + "|" + ;
                                                                       Dtoc(Date()) + " - " + Time() + "|" + ;
                                                                      "[ LOG CORRIGIDO          ] - Correção Encerrada')"
            cSql += " WHERE R_E_C_N_O_ = " + Alltrim(Str(T_RODAR->Registro))
            cSql += "   AND D_E_L_E_T_ = ''"  
            lResult := TCSQLEXEC(cSql)
         Else
            cSql := ""
            cSql := "UPDATE " + RetSqlName("Z20")
            cSql += "   SET Z20_STATUS = '0'"
            cSql += " WHERE R_E_C_N_O_ = " + Alltrim(Str(T_RODAR->Registro))
            cSql += "   AND D_E_L_E_T_ = ''"  
            lResult := TCSQLEXEC(cSql)
         Endif

         // Envia para a função que gera as OS para registros sem inconsistência
         __DtaImportacao := Ctod(Substr(T_RODAR->Z20_DIMP,07,02) + "/" + ;
                                 Substr(T_RODAR->Z20_DIMP,05,02) + "/" + ;
                                 Substr(T_RODAR->Z20_DIMP,01,04))
         
         ImportaDadosOS(T_RODAR->Z20_ARQU, T_RODAR->Z20_USUA, __DtaImportacao)

      Else
         cSql := ""
         cSql := "UPDATE " + RetSqlName("Z20")
         cSql += "   SET Z20_STATUS = '1',"
         cSql += "       Z20_LOGE   = CONVERT(varbinary(8000), '" + Alltrim(T_RODAR->LOGERRO)    + "|"  + ;
                                                                    Dtoc(Date()) + " - " +Time() + "|"  + ;
                                                                    Alltrim(cMsgLog)             + "')"
         cSql += " WHERE R_E_C_N_O_ = " + Alltrim(Str(T_RODAR->Registro))
         cSql += "   AND D_E_L_E_T_ = ''"  
         lResult := TCSQLEXEC(cSql)
      Endif

      T_RODAR->( DbSkip() )
      
   Enddo                    
            
   // Fecha o programa para abrí-lo novamente dando refresh no grid principal
   oDlgMan:End()
   U_SOLTGEROS()

Return(.T.)
                  
// Função que gera o retorno das posições de quebra das string conforme parâmetros.
Static Function xGeraPosicao(kString)

   Local aPosicao := {}
   Local aPDados  := {}
   Local _QtdInfo := ""
   Local _QtdLaco := 0
   Local nx       := 0
   Local nk       := 0

   _QtdInfo  := U_P_OCCURS(kString , "|,", 2) // Retorna o posicionamento de quebra das informações
   _QtdLaco  := U_P_OCCURS(_QtdInfo, "|" , 1) // Quantidade de ocorrências para laço
   aPRetorno := {}
      
   For nx = 1 to _QtdLaco //U_P_OCCURS(_QtdInfo, "|", 1)
          
       If nx == 1
          aAdd( aPosicao, { 1                                    ,;
                            INT(VAL(U_P_CORTA(_QtdInfo, "|", nx))),;
                            INT(VAL(U_P_CORTA(_QtdInfo, "|", nx))) - 1 })
          Loop
       Endif
             
       If nx <> _QtdLaco
          aAdd( aPosicao, { aPosicao[(nx-1), 2] + 1             ,;
                            INT(VAL(U_P_CORTA(_QtdInfo, "|", nx))),;
                            INT(VAL(U_P_CORTA(_QtdInfo, "|", nx))) -  (aPosicao[(nx-1), 2] + 1) })  
          Loop
       Endif
             
       If nx == _QtdLaco
          aAdd( aPosicao, { aPosicao[(nx-1), 2] + 1             ,;
                            INT(VAL(U_P_CORTA(_QtdInfo, "|", nx))),;
                            INT(VAL(U_P_CORTA(_QtdInfo, "|", nx))) -  (aPosicao[(nx-1), 2] + 1) })  
       Endif
               
   Next nx    

   //Carrega o array de retorno com os conteúdos da string
   nx := 0
   nk := 0
   For nx = 1 to Len(aPosicao)  

       _Separado := Strtran(Substr(kString,aPosicao[nx,1], aPosicao[nx,3]) + "#", "|", "")
                       
       For nk = 1 to U_P_OCCURS(_Separado, "#", 1)

           _Dado01 := U_P_CORTA(_separado, "#", nk) + ":"
           
           // Verifica se o dado lido é uma hora. Se for, trata
           If U_P_OCCURS(_Dado01, ":", 1) > 2
              _Horas    := U_P_CORTA(_Dado01, ":", 2) 
              _Minutos  := U_P_CORTA(_Dado01, ":", 3)
              _Segundos := U_P_CORTA(_Dado01, ":", 4)
              _Coluna01 := Strtran(Alltrim(U_P_CORTA(U_P_CORTA(_separado, "#", nk) + ":", ":",1)), ",", "")
              _Coluna02 := _Horas + ":" + _Minutos + ":" + _Segundos
           Else
              _Coluna01 := Strtran(Alltrim(U_P_CORTA(U_P_CORTA(_separado, "#", nk) + ":", ":",1)), ",", "")
              _Coluna02 := Alltrim(U_P_CORTA(U_P_CORTA(_separado, "#", nk) + ":", ":",2))
           Endif   

             aAdd( aPDados, { Alltrim(_Coluna01), Alltrim(_Coluna02) })

       Next nk

   Next nx

Return(aPDados)