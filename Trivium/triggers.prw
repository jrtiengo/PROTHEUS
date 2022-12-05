#include "protheus.ch"

User Function trigger()

/****utilizando na Enchoice ******/
If ExistTrigger('E5_BANCO')
  RunTrigger(1,nil,nil,,'E5_BANCO')
Endif

Return
