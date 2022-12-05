#INCLUDE "PROTHEUS.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM280.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: ( ) Programa  (X) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 19/03/2015                                                          *
// Objetivo..: Gatilho que verifica se usu�rio digitou & nos campos A1_NOME e      *
//             A1_NREDUZ do Cadastro de Clientes.                                  *
// Par�metro.: < _tVerifica > - Indica o tipo de verifica��o, onde:                *
//             1 - Indica verifica��o no campo A1_NOME ou A1_NREDUZ                *
//             2 - Indica verifica��o no campo A1_END                              *
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
   
   // Realiza a verifica��o de campo do tipo 1 (Nome do Cliente e Nome Reduzido do Cliente)
   If _tVerifica == 1

      If Empty(Alltrim(_CampoVer))
         Return _StringVoltar
      Endif
   
      _StringVoltar := StrTran(_CampoVer, "&", "E")

      Return _StringVoltar
      
   Endif

   // Realiza a verifica��o se campo A1_END possui v�rgula separando o n� do endere�o
   If _tVerifica == 2
                         
      // Se string possui v�rgula, despresa
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

      MsgAlert("Aten��o!" + chr(13) + chr(13) + ;
               "A separa��o do n� do endere�o do cliente deve ser separado por v�rgula:" + chr(13) + chr(13) + ;
               "Exemplo:" + chr(13) + Chr(13) + ;
               "Rua das Laranjeiras, 1000")

      Return _CampoVer



      // Carrega o array para verifica��o
      For nContar = 1 to U_P_OCCURS(Strtran(Alltrim(_CampoVer), " ", " |") + "|", "|", 1)
          aAdd( aString, { U_P_CORTA( Strtran(Alltrim(_CampoVer), " ", " |") + "|", "|", nContar) } )
      Next nContar    
 
      _NovoEndereco := ""

      // Conta quantos elementos = d�gitos existem. Isso serve para colocar a v�rgula no �ltimo elemento
      _Digitos := 0
      For nContar = 1 to Len(aString)
          If ISDIGIT(aString[nContar,1])      
             _Digitos := _Digitos + 1
          Endif
      Next nContar       

      // Coloca a v�rgula no endere�o
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

// Fun��o que verifica se endere�o do cliente possui separador (,) para separar o n� do endere�o.
// Se n�o tiver (,), a fun��o a coloca.
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

      // Se string possui v�rgula, despresa
      If U_P_OCCURS(SA1->A1_END, ",", 1) <> 0
         SA1->( DbSkip() )
         Loop
      Endif

      aString := {}

 _primeiro := SA1->A1_END

      // Carrega o array para verifica��o
      For nContar = 1 to U_P_OCCURS(Strtran(Alltrim(SA1->A1_END), " ", " |") + "|", "|", 1)
          aAdd( aString, { U_P_CORTA( Strtran(Alltrim(SA1->A1_END), " ", " |") + "|", "|", nContar) } )
      Next nContar    
 
      _NovoEndereco := ""

      // Conta quantos elementos = d�gitos existem. Isso serve para colocar a v�rgula no �ltimo elemento
      _Digitos := 0
      For nContar = 1 to Len(aString)
          If ISDIGIT(aString[nContar,1])      
             _Digitos := _Digitos + 1
          Endif
      Next nContar       

      // Coloca a v�rgula no endere�o
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

//     MSGALERT("Endere�o antes de alterar: " + _PRIMEIRO + CHR(13) + CHR(13) + "Endereco depois de alterado: " + _SEGUNDO)

      SA1->( DbSkip() )

   Enddo

   MsgAlert("Cadastro aletrado com sucesso!")

Return(.T.)