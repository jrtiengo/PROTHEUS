#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_OSATUALIZA.PRW                                                   ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 13/12/2016                                                          ##
// Objetivo..: Web Service que atualiza dados da OS                                ##
// Parâmetros: cParametros                                                         ##
//             01 - Empresa                                                        ##
//             02 - Filial                                                         ##
//             04 - Ordem de Serviço                                               ##
//             05 - Observações Ocorrências                                        ##
//             06 - Observações Internas                                           ##
//             07 - Laudo Técnico                                                  ##
// ##################################################################################

WSRESTFUL AT_GRAVAOS DESCRIPTION "Advpl Tools - Service Get OS"

    WSDATA cCodemp AS STRING
    WSDATA cCodFil AS STRING
    WSDATA cCodOrd AS STRING
    WSDATA cCodPos AS STRING
    WSDATA cCodInt AS STRING
    WSDATA cCodLau AS STRING

	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GRAVAOS || /AT_GRAVAOS/{cCodemp}{cCodFil}{cCodOrd}{cCodPos}{cCodInt}{cCodLau}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodemp, cCodFil, cCodOrd, cCodPos, cCodInt, cCodLau WSSERVICE AT_GRAVAOS

   Local cSql      := ""
   Local cRetorno  := ""
   Local cString   := ""
   Local xControle := ""
   
   Conout("Empresa.......:" + Self:cCodEmp)
   Conout("Filial........:" + Self:cCodFil)
   Conout("Ordem.........:" + Self:cCodOrd)
   Conout("Posicao.......:" + Self:cCodPos)
   Conout("Interna.......:" + Self:cCodInt)
   Conout("Laudo.........:" + Self:cCodLau)

   // ########################################################################
   // Atualiza os dados da Ordem de Serviço com dados passados no parâmetro ##
   // ########################################################################
   DbSelectArea("AB6")
   DbSetOrder(1)
   If DbSeek(Self:cCodFil + Self:cCodOrd)
      RecLock("AB6",.F.)
      AB6_POSI   := Self:cCodPos
      AB6_MINTER := Self:cCodInt
      AB6_MLAUDO := Self:cCodLau
      MsUnLock()
      cString := "0|ATUALIZOU|"
   Else
      cString := "9|NÃO ATUALIZOU|"
   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

/*
POSICAO
A

LAUDO
Prezado cliente,
O equipamento enviado esta com o touch danificado, firmware e fusion desatualizados.
Para o perfeito funcionamento do equipamento sera necessário a troca do touch, colocação da trava da tampa da bateria, atualização de OS e fusion.

Taxa de reprovação R$ 75,00

INTERNA
Aguardando aprovação de orçamento. 02/12/16 - Renato.
Touch - 250
Pelicula - 39,9
trava da bateria - 150
Total -  439,9
*/

/*
      backspace      %08
      tab            %09
      linefeed       %0A
      creturn        %0D
      space          %20
      !              %21
      "              %22
      #              %23
      $              %24
      %              %25
      &              %26
      '              %27
      (              %28
      )              %29
      *              %2A
      +              %2B
      ,              %2C
      -              %2D
      .              %2E
      /              %2F
      0              %30
      1              %31
      2              %32
      3              %33
      4              %34
      5              %35
      6              %36
      7              %37
      8              %38
      9              %39
      :              %3A
      ;              %3B
      <              %3C
      =              %3D
      >              %3E
      ?              %3F
      @              %40
      A              %41
      B              %42
      C              %43
      D              %44
      E              %45
      F              %46
      G              %47
      H              %48
      I              %49
      J              %4A
      K              %4B
      L              %4C
      M              %4D
      N              %4E
      O              %4F
      P              %50
      Q              %51
      R              %52
      S              %53
      T              %54
      U              %55
      V              %56
      W              %57
      X              %58
      Y              %59
      Z              %5A
      [              %5B
      \              %5C
      ]              %5D
      ^              %5E
      _              %5F
      `              %60
      a              %61
      b              %62
      c              %63
      d              %64
      e              %65
      f              %66
      g              %67
      h              %68
      i              %69
      j              %6A
      k              %6B
      l              %6C
      m              %6D
      n              %6E
      o              %6F
      p              %70
      q              %71
      r              %72
      s              %73
      t              %74
      u              %75
      v              %76
      w              %77
      x              %78
      y              %79
      z              %7A
      {              %7B
      |              %7C
      }              %7D
      ~              %7E
      ¢              %A2
      £              %A3
      ¥              %A5
      |              %A6
      §              %A7
      «              %AB
      ¬              %AC
      ¯              %AD
      º              %B0
      ±              %B1
      ª              %B2
      ,              %B4
      µ              %B5
      »              %BB
      ¼              %BC
      ½              %BD
      ¿              %BF
      À              %C0
      Á              %C1
      Â              %C2
      Ã              %C3
      Ä              %C4
      Å              %C5
      Æ              %C6
      Ç              %C7
      È              %C8
      É              %C9
      Ê              %CA
      Ë              %CB
      Ì              %CC
      Í              %CD
      Î              %CE
      Ï              %CF
      Ð              %D0
      Ñ              %D1
      Ò              %D2
      Ó              %D3
      Ô              %D4
      Õ              %D5
      Ö              %D6
      Ø              %D8
      Ù              %D9
      Ú              %DA
      Û              %DB
      Ü              %DC
      Ý              %DD
      Þ              %DE
      ß              %DF
      à              %E0
      á              %E1
      â              %E2
      ã              %E3
      ä              %E4
      å              %E5
      æ              %E6
      ç              %E7
      è              %E8
      é              %E9
      ê              %EA
      ë              %EB
      ì              %EC
      í              %ED
      î              %EE
      ï              %EF
      ð              %F0
      ñ              %F1
      ò              %F2
      ó              %F3
      ô              %F4
      õ              %F5
      ö              %F6
      ÷              %F7
      ø              %F8
      ù              %F9
      ú              %FA
      û              %FB
      ü              %FC
      ý              %FD
      þ              %FE
      ÿ              %FF
      
*/                      

