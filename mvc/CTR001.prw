#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
#Include 'APWizard.ch'


//Variaveis Estaticas
Static cTitulo := 'Cadastro De Contratos Duofy'

/*/{Protheus.doc} CTR001
Cadastro de Contratos Duofy 
@type function
@version 1.0
@author Felipe Moreira
@since 05/04/2024
/*/
User Function CTR001()

    Local oBrowse
    Local aArea 	 := (GetArea())

    //InstÃ¢nciando FWMBrowse - Somente com dicionÃ¡rio de dados
    oBrowse := FWmBrowse():New()

    //Setando a tabela
    oBrowse:SetAlias( 'Z01' )
    //Setando a descrição da rotina

    oBrowse:SetDescription( cTitulo )
    oBrowse:SetDetails(.F., {||})
    oBrowse:SetWalkThru(.F.)
    oBrowse:SetAmbiente(.F.)

    oBrowse:AddLegend( "Z01_STATUS == '1'", "BR_AZUL"    , "Pendente" )
    oBrowse:AddLegend( "Z01_STATUS == '2'", "BR_VERDE"   , "Ativo"  )

    //Ativa a Browse
    oBrowse:Activate()
    RestArea(aArea)

Return NIL


//----------------------------MenuDef---------------------------------------
/*
Define as operações que serão realizadas pela aplicação.
Na MenuDef da aplicação instanciamos a interface (View) de outra aplicação
*/
Static Function MenuDef()
    Local aRotina := {}

    aadd(aRotina, {'Incluir'        , 'VIEWDEF.CTR001'                                  , 0, 3, 0, .F.})
    aadd(aRotina, {'Alterar'        , 'VIEWDEF.CTR001'                                  , 0, 4, 0, .F.})
    aadd(aRotina, {'Visualizar'     , 'VIEWDEF.CTR001'                                  , 0, 2, 0, .F.})
    aadd(aRotina, {'Ativar Contrato', 'processa({|| U_AtvCtr()},"Inserindo Titulos...")', 0, 1, 0, .F.})
    aadd(aRotina, {'Legenda'        , 'U_CTR001L()'                                     , 0, 1, 0, .F.})


Return aRotina

//----------------------------ModelDef---------------------------------------

/*
Define a regra de negÃ³cios propriamente dita onde são definidas
* Todas as entidades (tabelas) que farão parte do modelo de dados (Model);
* Regras de dependÃªncia entre as entidades;
* Validações (de campos e aplicação);
* PersistÃªncia dos dados (gravação)
*/

Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruZ01 := FWFormStruct( 1, 'Z01' )
    Local oStruZ02 := FWFormStruct( 1, 'Z02' )
    Local oStruZ03 := FWFormStruct( 1, 'Z03' )
    Local oModel

    // Criando o modelo e os relacionamentos, atenção ao ID do modelo DHO001A'M'
    oModel := MPFormModel():New( 'CTR001A',/* { | oModel | CTR001( oModel ) }*/, /*{ | oModel | CTR001( oModel ) }*/)

    // inseri ao modelo a estrutura do formulario de edicao por campo
    oModel:AddFields( 'Z01MASTER', /*cOwner*/, oStruZ01 )

    oModel:AddGrid('Z02DETAIL', 'Z01MASTER', oStruZ02,       /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

    oModel:AddGrid('Z03DETAIL', 'Z01MASTER', oStruZ03,       /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

    oModel:SetRelation('Z02DETAIL', {{'Z02_FILIAL', 'Z01_FILIAL'},{'Z02_CODCTR', 'Z01_CODCTR'}}, Z02->(IndexKey(1))) //Z02_FILIAL+Z02_CODCTR

    oModel:SetRelation('Z03DETAIL', {{'Z03_FILIAL', 'Z01_FILIAL'},{'Z03_CODCTR', 'Z01_CODCTR'}}, Z03->(IndexKey(1))) //Z03_FILIAL+Z03_CODCTR

    // Descricao do Modelo de Dados
    oModel:SetDescription( 'Cadastro Contratos Duofy' )

    // Set Primary Key da tabela principal
    oModel:SetPrimaryKey({'Z01_FILIAL'}, {'Z01_CODCTR'})

    //oModel:SetPrimaryKey({'ZFB_FILCLA'}, {'ZFB_CODCLA'}, {'ZFB_FILCLA'}) // ZFB_FILIAL+ZFB_CODCLA+ZFB_FILCLA

    // Descreve componentes do modelo de dados
    oModel:GetModel( 'Z01MASTER' ):SetDescription( 'Cabecalho do ' + cTitulo)
    oModel:GetModel( 'Z02DETAIL' ):SetDescription('Associados' + cTitulo)
    oModel:GetModel( 'Z03DETAIL' ):SetDescription('Produtos' + cTitulo)

    //oModel:GetModel('ZFBDETAIL'):setOptional(.T.)
    // Ao final da função ModelDef, deve ser retornado o objeto de Modelo de dados (Model) gerado na função.

    //Não permitir alteração do campo centro de custo nas alterações.
    //If Altera
    //	oStruZFB:SetProperty("ZFB_CC", MODEL_FIELD_WHEN, {|| .F.})
    //EndIF

Return oModel


//------------------------------ViewDef-------------------------------------
/*
Define como serÃ¡ a interface (construção da interface) e portanto como o usuario interage com o modelo (Model)
recebe dados informado pelo usuario e fornece ao modelo (modelDef).
*/
Static Function ViewDef()
    // Criação da estrutura que sera utilizada pela view
    Local oStruZ01 := FWFormStruct( 2, 'Z01' )
    Local oStruZ02 := FWFormStruct( 2, 'Z02' )
    Local oStruZ03 := FWFormStruct( 2, 'Z03' )
    // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
    Local oModel   := FWLoadModel( 'CTR001' )
    Local oView
    //	Local cRetImpos := ""

    // remove campos da estrutura
    //oStruZFB:RemoveField( 'CAMPO DA TABELA PARA REMOSSAO' )

    // Cria o objeto View
    oView := FWFormView():New()

    // Definição do Modelo de dados que serÃ¡ utilizado
    oView:SetModel( oModel )

    //Adiciona na nossa View um controle do tipo formulÃ¡rio (antiga Enchoice)
    //             <cViewID> , <oStruct>, [cSubModelID]
    oView:AddField('VIEW_Z01', oStruZ01 , 'Z01MASTER')
    //			  <cViewID> , <oStruct>, [cSubModelID], <uParam4>  , [bGotFocus]
    oView:AddGrid('VIEW_Z02', oStruZ02 , 'Z02DETAIL'  , /*uParam4*/, /*bGotFocus*/)
    //
    oView:AddGrid('VIEW_Z03', oStruZ03 , 'Z03DETAIL'  , /*uParam4*/, /*bGotFocus*/)

    //oView:CreateVerticalBox('LEFT', 35)
    //oView:CreateVerticalBox('RIGHT', 65)

    oView:CreateHorizontalBox('CABEC', 40)
    oView:CreateHorizontalBox('GRID',  30)
    oView:CreateHorizontalBox('GRID2', 30)

    oView:SetOwnerView('VIEW_Z01', 'CABEC')
    oView:SetOwnerView('VIEW_Z02', 'GRID')
    oView:SetOwnerView('VIEW_Z03', 'GRID2')

    oView:EnableTitleView('VIEW_Z01','Cabecalho Contrato')
    oView:EnableTitleView('VIEW_Z02','Associados')
    oView:EnableTitleView('VIEW_Z03','Produtos')

    oView:SetCloseOnOk({||.T.})

    oStruZ02:RemoveField( 'Z02_FILIAL' )
    oStruZ02:RemoveField( 'Z02_CODCTR' )
    oStruZ02:RemoveField( 'Z02_ID' )

    oStruZ03:RemoveField( 'Z03_FILIAL' )
    oStruZ03:RemoveField( 'Z03_CODCTR' )
    oStruZ03:RemoveField( 'Z03_ID' )

Return oView


/*/{Protheus.doc} CTR001L
Função de Legenda
@type function
@version 1.0
@author felipe.moreira
@since 06/04/2024
/*/
User Function CTR001L()

    Local aLegenda  := {}
    Local cCadastro := "Status Contratos Duofy"


    aAdd( aLegenda, { "BR_AZUL"    , "Pendente"  })
    aAdd( aLegenda, { "BR_VERDE"   , "Ativo"	 })

    BrwLegenda( cCadastro, "Legenda", aLegenda )

Return Nil

/*/{Protheus.doc} CTR001A
PE da rotina CTR001
@type function
@version 1.0
@author felipe.moreira
@since 10/04/2024
/*/
User Function CTR001A()

    Local aArea 	:= GetArea()

    Local xRet			:= .T.
    Local nQtdElIXB		:= 0
    Local oObj			:= ''
    Local cIdPonto		:= ''
    Local cIdModel		:= ''
    Local cClasse		:= ''
    Local nOperation 	:= 0
    Local cContent		:= ''
    Local cMsg			:= ''


    Local nI			:= 0

    If PARAMIXB <> Nil
        nQtdElIXB	:= Len(PARAMIXB)
        oObj 		:= PARAMIXB[1]
        cIdPonto	:= PARAMIXB[2]
        cIdModel	:= PARAMIXB[3]
        cClasse 	:= Iif(oObj<>Nil, oObj:ClassName(), '')	// Nome da classe utilizada na rotina (FWFORMFIELD - FormulÃ¡rio, FWFORMGRID - Grid)
        nOperation 	:= oObj:getOperation()

        For nI := 1 To nQtdElIXB
            cContent := ''
            If nI == 1
                cMsg += '[1]'+oObj:ClassName()
            ElseIf nI == 2
                cMsg += '[2]'+PARAMIXB[nI]
            ElseIf nI == 3
                cMsg += '[3]'+PARAMIXB[nI]
            Else
                If ValType(PARAMIXB[nI]) == 'L'
                    cContent := Iif(PARAMIXB[nI], 'True', 'False')
                ElseIf ValType(PARAMIXB[nI]) == 'C'
                    cContent := PARAMIXB[nI]
                EndIf
                cMsg += '[' + AllTrim(Str(nI)) + '][' + ValType(PARAMIXB[nI]) + ']' + cContent
            EndIf
        Next nI

        If cIdPonto == 'MODELVLDACTIVE'

        ElseIf cIdPonto == 'MODELPRE'

        ElseIf cIdPonto == 'MODELPOS'

        ElseIf cIdPonto == 'FORMPRE'

            xRet := .T.

            //Antes da Abertura da Tela valida se pode ser feita alteração.
            if nOperation == 4
                If FWFldGet("Z01_STATUS") == '2'
                    Help(NIL, NIL, "Atencao", NIL, "Nao e permitido realizar alteracoes em contratos ja efetivados.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
                    return xRet := .F.
                EndIf
            EndIf

        ElseIf cIdPonto == 'FORMPOS'

        ElseIf cIdPonto == 'FORMLINEPRE'

        ElseIf cIdPonto == 'FORMLINEPOS'

        ElseIf cIdPonto == 'MODELCOMMITTTS'

        ElseIf cIdPonto == 'MODELCOMMITNTTS'
            xRet := Nil
        ElseIf cIdPonto == 'FORMCOMMITTTSPRE'
            xRet := Nil
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
            xRet := Nil
        ElseIf cIdPonto == 'FORMCANCEL'
            xRet := .T.
        ElseIf cIdPonto == 'BUTTONBAR'
            xRet := .T.
        EndIf

    EndIf

    RestArea(aArea)


Return(xRet)

/*/{Protheus.doc} AtvCtr
Função que realizar a efetivação do contrato, incluindo os respectivos
titulos no contas a receber.
@type function
@version 1.0 
@author felipe.moreira
@since 10/04/2024
/*/
User Function AtvCtr()
    Local nX         := 0
    Local cNaturez   := SuperGetMv("MV_XNATCTR",.F.,"200024512")
    Local dDataVReal := dDataBase
    Local nVlrPar  := Round(Z01->Z01_VALOR / Z01->Z01_QTDPAR,2)
    Local nVlrP01  := nVlrPar

    // calcula se houver diferença de centavos entre o valor total e a soma das parcelas adiciona esse valor a primeira parcela
    If Z01->Z01_VALOR - (nVlrPar * Z01->Z01_QTDPAR) > 0
        nVlrP01 += Round(Z01->Z01_VALOR - (nVlrPar * Z01->Z01_QTDPAR),2)
    EndIF

    If Z01->Z01_STATUS == '1'
        If !MsgYesNo('Deseja efetivar o contrato: ' + Z01->Z01_CODCTR + '?','Confirmar')
            Return
        EndIF
    Else
        Help(NIL, NIL, "Nao Permitido", NIL, "Nao e permitido realizar efetivacao desse contrato.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o status do contrato."})
        Return
    EndIf

    ProcRegua(Z01->Z01_QTDPAR)

    Begin Transaction
        For nX := 1 To Z01->Z01_QTDPAR

            IncProc("Inclusao de Titulo do contrato:  " + AllTrim(Z01->Z01_CODCTR) + " - Parcela: " + AllTrim(str(nx)) )

            aAutoSE1 	:= {}

            //Calcula as datas de vencimento da parcela
            dVencCalc := calcVenc(Z01->Z01_DTVENC,nX)
            // Funcao DataValida verifica se o dia informado é dia util, se não for retorna o dia util mais proximo
            dDataVReal := DataValida(dVencCalc,.T.)

            aadd(aAutoSE1, {"E1_PREFIXO", "CTR"                                  , NIL})
            aadd(aAutoSE1, {"E1_PARCELA", STRZERO(nx,2)                          , NIL})
            aadd(aAutoSE1, {"E1_TIPO"   , "BOL"                                  , NIL})
            aadd(aAutoSE1, {"E1_CLIENTE", Z01->Z01_CODCLI                        , NIL})
            aadd(aAutoSE1, {"E1_LOJA"   , Z01->Z01_LOJA                          , NIL})
            aadd(aAutoSE1, {"E1_NOMCLI" , Z01->Z01_NOME                          , NIL})
            aadd(aAutoSE1, {"E1_NUM"    , STRZERO(val(Z01->Z01_CODCTR),9)        , NIL})
            aadd(aAutoSE1, {"E1_EMISSAO", dDataBase                              , NIL})
            aadd(aAutoSE1, {"E1_EMIS1"  , dDataBase                              , NIL})
            aadd(aAutoSE1, {"E1_VENCTO" , dVencCalc                              , NIL})
            aadd(aAutoSE1, {"E1_VENCORI", dVencCalc                              , NIL})
            aadd(aAutoSE1, {"E1_VENCREA", dDataVReal                             , NIL})
            aadd(aAutoSE1, {"E1_VALOR"  , IIF(nx == 1,nVlrP01,nVlrPar)           , NIL})
            aadd(aAutoSE1, {"E1_HIST"   , "Inclusao Contrato: " + Z01->Z01_CODCTR, NIL})
            aadd(aAutoSE1, {"E1_MULTNAT", "2"                                    , NIL})
            aadd(aAutoSE1, {"E1_NATUREZ", cNaturez                               , NIL})

            lMsErroAuto := .F.
            //Realiza execauto de inclusao de titulo
            MsExecAuto({|x, y| FINA040(x, y)}, aAutoSE1, 3)

            If lMsErroAuto
                MostraErro()
                Help(NIL, NIL, "Atenção", NIL, "O erro informado impediu a geração do titulo. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Corrija o erro. "})
                //Disarma a transacao e nao efetiva o contrato
                DisarmTransaction()
                Return
            endif
        Next nX

        //Atualiza o status do contrato para ativo
        RecLock("Z01", .F.)
        Z01->Z01_STATUS := '2'
        Z01->(MsUnLock())

        MsgInfo("Contrato efetivado com sucesso, gerado "+AllTrim(Str(nx))+" titulo(s) para o contrato: " + Z01->Z01_CODCTR)

    End Transaction

Return

/*/{Protheus.doc} calcVenc
Função que realizar o calculo do vencimento de cada parcela, 
garantindo que será respeitado o dia que usuario determinou, porem se o dia não existir no mes
a função irá retornar o dia util mais proximo.
@type function
@version 1.0 
@author felipe.moreira
@since 10/04/2024
@param cDiaVenc, character, dia selecionado pelo usuario para vencimento
@param nParcela, numeric, qual parcela está sendo calculada
@return date, data de vencimento da parcela calculada
/*/
Static Function calcVenc(cDiaVenc,nParcela)

    Local nSomaMes   := 0
    Local cDiaAtual  := Day2Str(dDataBase)
    Local cMes       := Month2Str(dDataBase)
    Local cAno       := Year2Str(dDataBase)
    Local dIniMes    := StoD(cAno+cMes+'01')
    Local nCount     := 0


    // Se a data de vencimento for maior que a data atual soma 1 mes na data de vencimento, primeiro vencimento
    // deve ocorrer apenas no mes seguinte.
    If cDiaAtual > cDiaVenc
        nSomaMes := 1
    EndIF

    // Para cada parcela adicionar 1 mes ou somar ao mes o valor da parcela parcela -1
    If nParcela > 1
        nSomaMes += nParcela -1
    EndIF


    // soma a quantidade de meses encontrada nas regras acima, para esse primeiro calculo utiliza o primeiro dia do mes
    dDtCalc := MonthSum(dIniMes,nSomaMes)
    // realiza ajuste do dia 01 para o dia selecionando para o vencimento agora já no mes da parcela e se retornar vazio é por que o dia não existe
    dDtCalc := StoD(Substr(DtoS(dDtCalc),1,6) + cDiaVenc)

    While Empty(dDtCalc)
        nCount += 1

        dDtCalc := MonthSum(dIniMes,nSomaMes)

        dDtCalc := StoD(Substr(DtoS(dDtCalc),1,6) + AllTrim(StrZero(val(cDiaVenc)-nCount,2)))
    EndDO

Return dDtCalc


/*/{Protheus.doc} fTstCalc
Função para testar a função de calculo de vencimento quando necessario. 
@type function
@version 1.0 
@author felipe.moreira
@since 10/04/2024
/*/
User Function fTstCalc()
    Local nx       := 0
    Local cCrLf    := Chr(13) + Chr(10)
    Local cDiaVenc := "31"
    Local cMsg     := ""
    RPCSetType(3)
    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01"

    for nx := 1 to 36
        //Calcula as datas de vencimento d7a parcela
        dVencCalc := calcVenc(cDiaVenc,nX)
        // Funcao DataValida verifica se o dia informado é dia util, se não for retorna o dia util mais proximo
        dDataVReal := DataValida(dVencCalc,.T.)
        cMsg += "Parcela: " + AllTrim(str(nx)) + " Data base: " +DTOC(dDataBase)+ " Data Vencimento: " + DTOC(dVencCalc) + " Data Real: " + DTOC(dDataVReal) + cCrLf
    Next nx

    MsgInfo(cMsg)

    RESET ENVIRONMENT
Return
//estou deixando o resultado do teste propositalmente para que possam ver como foi feita a validação da função.

/* resultado teste data menor que hoje
Parcela: 1  Data base: 10/04/24 Data Vencimento: 09/05/24 Data Real: 09/05/24
Parcela: 2  Data base: 10/04/24 Data Vencimento: 09/06/24 Data Real: 10/06/24
Parcela: 3  Data base: 10/04/24 Data Vencimento: 09/07/24 Data Real: 09/07/24
Parcela: 4  Data base: 10/04/24 Data Vencimento: 09/08/24 Data Real: 09/08/24
Parcela: 5  Data base: 10/04/24 Data Vencimento: 09/09/24 Data Real: 09/09/24
Parcela: 6  Data base: 10/04/24 Data Vencimento: 09/10/24 Data Real: 09/10/24
Parcela: 7  Data base: 10/04/24 Data Vencimento: 09/11/24 Data Real: 11/11/24
Parcela: 8  Data base: 10/04/24 Data Vencimento: 09/12/24 Data Real: 09/12/24
Parcela: 9  Data base: 10/04/24 Data Vencimento: 09/01/25 Data Real: 09/01/25
Parcela: 10 Data base: 10/04/24 Data Vencimento: 09/02/25 Data Real: 10/02/25
Parcela: 11 Data base: 10/04/24 Data Vencimento: 09/03/25 Data Real: 10/03/25
Parcela: 12 Data base: 10/04/24 Data Vencimento: 09/04/25 Data Real: 09/04/25
*/

/* teste com dia 31 para textas fevereiro e meses sem 31 dias
Parcela: 1  Data base: 10/04/24 Data Vencimento: 30/04/24 Data Real: 30/04/24
Parcela: 2  Data base: 10/04/24 Data Vencimento: 31/05/24 Data Real: 31/05/24
Parcela: 3  Data base: 10/04/24 Data Vencimento: 30/06/24 Data Real: 01/07/24
Parcela: 4  Data base: 10/04/24 Data Vencimento: 31/07/24 Data Real: 31/07/24
Parcela: 5  Data base: 10/04/24 Data Vencimento: 31/08/24 Data Real: 02/09/24
Parcela: 6  Data base: 10/04/24 Data Vencimento: 30/09/24 Data Real: 30/09/24
Parcela: 7  Data base: 10/04/24 Data Vencimento: 31/10/24 Data Real: 31/10/24
Parcela: 8  Data base: 10/04/24 Data Vencimento: 30/11/24 Data Real: 02/12/24
Parcela: 9  Data base: 10/04/24 Data Vencimento: 31/12/24 Data Real: 31/12/24
Parcela: 10 Data base: 10/04/24 Data Vencimento: 31/01/25 Data Real: 31/01/25
Parcela: 11 Data base: 10/04/24 Data Vencimento: 28/02/25 Data Real: 28/02/25
Parcela: 12 Data base: 10/04/24 Data Vencimento: 31/03/25 Data Real: 31/03/25
Parcela: 13 Data base: 10/04/24 Data Vencimento: 30/04/25 Data Real: 30/04/25
Parcela: 14 Data base: 10/04/24 Data Vencimento: 31/05/25 Data Real: 02/06/25
Parcela: 15 Data base: 10/04/24 Data Vencimento: 30/06/25 Data Real: 30/06/25
Parcela: 16 Data base: 10/04/24 Data Vencimento: 31/07/25 Data Real: 31/07/25
Parcela: 17 Data base: 10/04/24 Data Vencimento: 31/08/25 Data Real: 01/09/25
Parcela: 18 Data base: 10/04/24 Data Vencimento: 30/09/25 Data Real: 30/09/25
Parcela: 19 Data base: 10/04/24 Data Vencimento: 31/10/25 Data Real: 31/10/25
Parcela: 20 Data base: 10/04/24 Data Vencimento: 30/11/25 Data Real: 01/12/25
Parcela: 21 Data base: 10/04/24 Data Vencimento: 31/12/25 Data Real: 31/12/25
Parcela: 22 Data base: 10/04/24 Data Vencimento: 31/01/26 Data Real: 02/02/26
Parcela: 23 Data base: 10/04/24 Data Vencimento: 28/02/26 Data Real: 02/03/26
Parcela: 24 Data base: 10/04/24 Data Vencimento: 31/03/26 Data Real: 31/03/26
Parcela: 25 Data base: 10/04/24 Data Vencimento: 30/04/26 Data Real: 30/04/26
Parcela: 26 Data base: 10/04/24 Data Vencimento: 31/05/26 Data Real: 01/06/26
Parcela: 27 Data base: 10/04/24 Data Vencimento: 30/06/26 Data Real: 30/06/26
Parcela: 28 Data base: 10/04/24 Data Vencimento: 31/07/26 Data Real: 31/07/26
Parcela: 29 Data base: 10/04/24 Data Vencimento: 31/08/26 Data Real: 31/08/26
Parcela: 30 Data base: 10/04/24 Data Vencimento: 30/09/26 Data Real: 30/09/26
Parcela: 31 Data base: 10/04/24 Data Vencimento: 31/10/26 Data Real: 03/11/26
Parcela: 32 Data base: 10/04/24 Data Vencimento: 30/11/26 Data Real: 30/11/26
Parcela: 33 Data base: 10/04/24 Data Vencimento: 31/12/26 Data Real: 31/12/26
Parcela: 34 Data base: 10/04/24 Data Vencimento: 31/01/27 Data Real: 01/02/27
Parcela: 35 Data base: 10/04/24 Data Vencimento: 28/02/27 Data Real: 01/03/27
Parcela: 36 Data base: 10/04/24 Data Vencimento: 31/03/27 Data Real: 31/03/27
*/
