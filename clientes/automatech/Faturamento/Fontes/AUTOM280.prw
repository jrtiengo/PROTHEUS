#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM280.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 19/03/2015                                                          *
// Objetivo..: Gatilho que verifica se usuário digitou & nos campos A1_NOME e      *
//             A1_NREDUZ do Cadastro de Clientes.                                  *
// Parâmetro.: < _tVerifica > - Indica o tipo de verificação, onde:                *
//             1 - Indica verificação no campo A1_NOME ou A1_NREDUZ                *
//             2 - Indica verificação no campo A1_END                              *
//**********************************************************************************

User Function AUTOM280(_CampoVer, _tVerifica)

   Local _StringVoltar := ""
   Local nContar       := 0
   Local aString       := {}
   Local aNovoEnd      := {}
   Local _Digitos      := 0
   Local _Colocar      := 0
   Local _NovoEndereco := ""

   U_AUTOM628("AUTOM280")
   
   // Realiza a verificação de campo do tipo 1 (Nome do Cliente e Nome Reduzido do Cliente)
   If _tVerifica == 1

      If Empty(Alltrim(_CampoVer))
         Return _StringVoltar
      Endif
   
      _StringVoltar := StrTran(_CampoVer, "&", "E")

      Return _StringVoltar
      
   Endif

   // Realiza a verificação se campo A1_END possui vírgula separando o nº do endereço
   If _tVerifica == 2
                         
      // Se string possui vírgula, despresa
      If U_P_OCCURS(_CampoVer, ",", 1) <> 0
         Return _CampoVer
      Endif

      // Se string possui BR, despresa
      If U_P_OCCURS(_CampoVer, "BR", 1) <> 0
         Return _CampoVer
      Endif

      // Se string possui KM, despresa
      If U_P_OCCURS(_CampoVer, "KM", 1) <> 0
         Return _CampoVer
      Endif

      MsgAlert("Atenção!" + chr(13) + chr(13) + ;
               "A separação do nº do endereço do cliente deve ser separado por vírgula:" + chr(13) + chr(13) + ;
               "Exemplo:" + chr(13) + Chr(13) + ;
               "Rua das Laranjeiras, 1000")

      Return _CampoVer



      // Carrega o array para verificação
      For nContar = 1 to U_P_OCCURS(Strtran(Alltrim(_CampoVer), " ", " |") + "|", "|", 1)
          aAdd( aString, { U_P_CORTA( Strtran(Alltrim(_CampoVer), " ", " |") + "|", "|", nContar) } )
      Next nContar    
 
      _NovoEndereco := ""

      // Conta quantos elementos = dígitos existem. Isso serve para colocar a vírgula no último elemento
      _Digitos := 0
      For nContar = 1 to Len(aString)
          If ISDIGIT(aString[nContar,1])      
             _Digitos := _Digitos + 1
          Endif
      Next nContar       

      // Coloca a vírgula no endereço
      _Colocar := 1
      For nContar = 1 to Len(aString)
          
          If ISDIGIT(aString[nContar,1])
             If _Colocar == _Digitos
                _NovoEndereco := _NovoEndereco + ", " + Alltrim(aString[nContar,1]) + " "
             Else
                _Colocar := _Colocar + 1
                _NovoEndereco := _NovoEndereco + Alltrim(aString[nContar,1]) + " "
             Endif
          Else
             _NovoEndereco := _NovoEndereco + Alltrim(aString[nContar,1]) + " "
          Endif
          
      Next nContar    


      msgalert(_NovoEndereco)

      _StringVoltar := _NovoEndereco

   Endif

Return _StringVoltar

// Função que verifica se endereço do cliente possui separador (,) para separar o nº do endereço.
// Se não tiver (,), a função a coloca.
User Function BotaVirgula()

   Local _StringVoltar := ""
   Local nContar       := 0
   Local aString       := {}
   Local aNovoEnd      := {}
   Local _Digitos      := 0
   Local _Colocar      := 0
   Local _NovoEndereco := ""

   Local _primeiro := ""
   Local _segundo  := ""

   dbSelectArea("SA1")
   dbSetOrder(1)

   While !SA1->(EOF()) 

      // Se string possui vírgula, despresa
      If U_P_OCCURS(SA1->A1_END, ",", 1) <> 0
         SA1->( DbSkip() )
         Loop
      Endif

      aString := {}

 _primeiro := SA1->A1_END

      // Carrega o array para verificação
      For nContar = 1 to U_P_OCCURS(Strtran(Alltrim(SA1->A1_END), " ", " |") + "|", "|", 1)
          aAdd( aString, { U_P_CORTA( Strtran(Alltrim(SA1->A1_END), " ", " |") + "|", "|", nContar) } )
      Next nContar    
 
      _NovoEndereco := ""

      // Conta quantos elementos = dígitos existem. Isso serve para colocar a vírgula no último elemento
      _Digitos := 0
      For nContar = 1 to Len(aString)
          If ISDIGIT(aString[nContar,1])      
             _Digitos := _Digitos + 1
          Endif
      Next nContar       

      // Coloca a vírgula no endereço
      _Colocar := 1
      For nContar = 1 to Len(aString)
          
          If ISDIGIT(aString[nContar,1])
             If _Colocar == _Digitos
                _NovoEndereco := _NovoEndereco + ", " + Alltrim(aString[nContar,1]) + " "
             Else
                _Colocar := _Colocar + 1
                _NovoEndereco := _NovoEndereco + Alltrim(aString[nContar,1]) + " "
             Endif
          Else
             _NovoEndereco := _NovoEndereco + Alltrim(aString[nContar,1]) + " "
          Endif
          
      Next nContar    

      RecLock("SA1", .F.)
      SA1->A1_END := _NovoEndereco
 	  MsUnLock()			

 _segundo := _NovoEndereco

//     MSGALERT("Endereço antes de alterar: " + _PRIMEIRO + CHR(13) + CHR(13) + "Endereco depois de alterado: " + _SEGUNDO)

      SA1->( DbSkip() )

   Enddo

   MsgAlert("Cadastro aletrado com sucesso!")

Return(.T.)