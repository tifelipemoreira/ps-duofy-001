#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'topconn.ch'
#Include 'tbiconn.ch'
#Include 'APWizard.ch'


//VariÃ¡veis EstÃ¡ticas
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
    //Setando a descriÃ§Ã£o da rotina
    oBrowse:SetDescription( cTitulo )
    oBrowse:SetDetails(.F., {||})
    oBrowse:SetWalkThru(.F.)
    oBrowse:SetAmbiente(.F.)

    oBrowse:AddLegend( "Z01_STATUS == '1'", "BR_AZUL"    , "Pendente" )
    oBrowse:AddLegend( "Z01_STATUS == '1'", "BR_VERDE"   , "Ativo"  )

    //Ativa a Browse
    oBrowse:Activate()
    RestArea(aArea)

Return NIL


//----------------------------MenuDef---------------------------------------
/*
Define as operaÃ§Ãµes que serÃ£o realizadas pela aplicaÃ§Ã£o.
Na MenuDef da aplicaÃ§Ã£o instanciamos a interface (View) de outra aplicaÃ§Ã£o
*/
Static Function MenuDef()
    Local aRotina := {}

    aadd(aRotina, {'Incluir'        , 'VIEWDEF.CTR001'           , 0, 3, 0, .F.})
    aadd(aRotina, {'Alterar'        , 'VIEWDEF.CTR001'           , 0, 4, 0, .F.})
    aadd(aRotina, {'Visualizar'     , 'VIEWDEF.CTR001'           , 0, 2, 0, .F.})
    aadd(aRotina, {'Ativar Contrato', 'processa({|| U_AtvCtr()})', 0, 1, 0, .F.})
    aadd(aRotina, {'Legenda'        , 'U_CTR001L()'              , 0, 1, 0, .F.})


Return aRotina

//----------------------------ModelDef---------------------------------------

/*
Define a regra de negÃ³cios propriamente dita onde sÃ£o definidas
* Todas as entidades (tabelas) que farÃ£o parte do modelo de dados (Model);
* Regras de dependÃªncia entre as entidades;
* ValidaÃ§Ãµes (de campos e aplicaÃ§Ã£o);
* PersistÃªncia dos dados (gravaÃ§Ã£o)
*/

Static Function ModelDef()
    // Cria a estrutura a ser usada no Modelo de Dados
    Local oStruZ01 := FWFormStruct( 1, 'Z01' )
    Local oStruZ02 := FWFormStruct( 1, 'Z02' )
    Local oStruZ03 := FWFormStruct( 1, 'Z03' )
    Local oModel

    // Criando o modelo e os relacionamentos, atenÃ§Ã£o ao ID do modelo DHO001A'M'
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
    // Ao final da funÃ§Ã£o ModelDef, deve ser retornado o objeto de Modelo de dados (Model) gerado na funÃ§Ã£o.

    //NÃ£o permitir alteraÃ§Ã£o do campo centro de custo nas alteraÃ§Ãµes.
    //If Altera
    //	oStruZFB:SetProperty("ZFB_CC", MODEL_FIELD_WHEN, {|| .F.})
    //EndIF

Return oModel


//------------------------------ViewDef-------------------------------------
/*
Define como serÃ¡ a interface (construÃ§Ã£o da interface) e portanto como o usuario interage com o modelo (Model)
recebe dados informado pelo usuario e fornece ao modelo (modelDef).
*/
Static Function ViewDef()
    // CriaÃ§Ã£o da estrutura que sera utilizada pela view
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

    // DefiniÃ§Ã£o do Modelo de dados que serÃ¡ utilizado
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
FunÃ§Ã£o de Legenda
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
PE da rotina
@type function
@version 12.1.25
@author felipe.moreira
@since 16/10/2020
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

            //Antes da Abertura da Tela valida se pode ser feita alteraÃ§Ã£o.
            if nOperation == 4
                If FWFldGet("Z01_STATUS") == '2'
                    Help(NIL, NIL, "AtenÃ§Ã£o", NIL, "NÃ£o Ã© permitido realizar alteraÃ§Ãµes em contratos jÃ¡ efetivados.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Estorne o contrato para realizar alteraÃ§Ãµes."})
                    xRet := .F.
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


User Function AtvCtr()
    Local nX         := 0
    Local cNaturez   := SuperGetMv("MV_XNATCTR",.F.,"200024512")
    Local dDataVenc  := dDataBase
    Local dDataVReal := dDataBase

    If Z01->Z01_STATUS == '1'
        MsgYesNo('Confirmar','Deseja efetivar o contrato: ' + Z01->Z01_CODCTR + '?')
    Else
        Help(NIL, NIL, "AtenÃ§Ã£o", NIL, "NÃ£o Ã© permitido realizar efetivaÃ§Ã£o desse contrato.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o status do contrato."})
        Return
    EndIf

    ProcRegua(Z01->Z01_QTDPAR)

       // Funcao DataValida verifica se o dia informado Ã© dia util, se nÃ£o for retorna o dia util mais proximo
    dDataVReal := DataValida(dDataVenc,.T.)

    Begin Transaction
        For nX := 1 To Z01->Z01_QTDPAR

            IncProc("Realizando InclusÃ£o de Titulo do contrato:  " + Z01->Z01_CODCTR + "Parcela: " + str(nx) )

            aAutoSE1 	:= {}
            
            //Calcula as datas de vencimento e vencimento real 
            //[1]- data de vencimento calculada
            //[2]- data de vencimento real dia util
            aVenCalculado := {}
            aVenCalculado := calcVenc(Z01->Z01_DTVENC,nX)
            dDataVenc  := aVenCalculado[1]
            dDataVReal := aVenCalculado[2]

            aadd(aAutoSE1, {"E1_PREFIXO", "CTR"                                  , NIL})
            aadd(aAutoSE1, {"E1_PARCELA", STRZERO(nx,3)                          , NIL})
            aadd(aAutoSE1, {"E1_TIPO"   , "BOL"                                  , NIL})
            aadd(aAutoSE1, {"E1_CLIENTE", Z01->Z01_CODCLI                        , NIL})
            aadd(aAutoSE1, {"E1_LOJA"   , Z01->Z01_LOJA                          , NIL})
            aadd(aAutoSE1, {"E1_NOMCLI" , Z01->Z01_NOME                          , NIL})
            aadd(aAutoSE1, {"E1_NUM"    , STRZERO(Z01->Z01_CODCTR,9)             , NIL})
            aadd(aAutoSE1, {"E1_EMISSAO", dDataBase                              , NIL})
            aadd(aAutoSE1, {"E1_EMIS1"  , dDataBase                              , NIL})
            aadd(aAutoSE1, {"E1_VENCTO" , dDataVenc                              , NIL})
            aadd(aAutoSE1, {"E1_VENCORI", dDataVenc                              , NIL})
            aadd(aAutoSE1, {"E1_VENCREA", dDataVReal                             , NIL})
            aadd(aAutoSE1, {"E1_VALOR"  , Z01->Z01_VALOR                         , NIL})
            aadd(aAutoSE1, {"E1_HIST"   , "Inclusao Contrato: " + Z01->Z01_CODCTR, NIL})
            aadd(aAutoSE1, {"E1_MULTNAT", "2"                                    , NIL})
            aadd(aAutoSE1, {"E1_NATUREZ", cNaturez                               , NIL})

            lMsErroAuto := .F.
            //Realiza execauto de inclusao de titulo
            MsExecAuto({|x, y| FINA040(x, y)}, aAutoSE1, 3)

            If lMsErroAuto
                MostraErro()
                Help(NIL, NIL, "AtenÃ§Ã£o", NIL, "O erro informado impediu a geraÃ§Ã£o do titulo. ", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Corrija o erro. "})
                //Disarma a transacao e nao efetiva o contrato
                DisarmTransaction()
                Exit
            endif
        Next nX

        //Atualiza o status do contrato para ativo
        RecLock("Z01", .F.)
        Z01->Z01_STATUS := '2'
        Z01->(MsUnLock())

        MsgInfo("Contrato efetivado com sucesso, gerado "+Str(nx)+" titulo(s) para o contrato: " + Z01->Z01_CODCTR)

    End Transaction

Return

Static Function calcVenc(cDtVenc,nParcela)

    Local dDataAtual := dDataBase
    Local aVencimento := {}

    // Se parcela 1 precisa verificar se a data de vencimento Ã© maior que a data atual
    if nParcela == 1
        cDiaAtual := Day2Str(dDataAtual)
    EndIF
    

    If cDtVenc > cDiaAtual
        
    EndIF

Return aVencimento

