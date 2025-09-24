@isTest
public with sharing class OpportunityCloneControllerTest {

    @TestSetup
    static void makeData(){
        Account acc1 = new Account(
            Name = 'Test Account',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1');
        insert acc1;

        Contact contact0 = new Contact(LastName = 'Test Contact 0', Email = '6845387306452580136@test.com', Phone = '51981617948', AccountId = acc1.Id);
        insert contact0;

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            Funnel__c = 'Varejo',
            Media__c = null, 
            AccountId = acc1.Id, 
            Telefone__c = '5551981617948', 
            Segmento__c = 'Aplicativos', 
            Tipo_de_cliente__c = 'Cliente Final', 
            CloseDate = Date.today().addDays(5), 
            StageName = 'Qualificação', 
            Emaill__c = 'barbara@gmail.com', 
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal', 
            Veiculacao__c = 'TV', 
            Telefone1__c = '+5551981617948',
            CNPJ__c = '42113212000125',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            SaleType__c = 'Cliente Novo'
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            Funnel__c = 'Varejo',
            Media__c = 'sbt', 
            AccountId = acc1.Id, 
            Telefone__c = '5551981617948', 
            Segmento__c = 'Aplicativos', 
            Tipo_de_cliente__c = 'Cliente Final', 
            CloseDate = Date.today().addDays(5), 
            StageName = 'Qualificação', 
            Emaill__c = 'barbara@gmail.com', 
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal', 
            Veiculacao__c = 'TV', 
            Telefone1__c = '+5551981617948',
            CNPJ__c = '42113212000125',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            SaleType__c = 'Cliente Novo'
        );

        Opportunity opp3 = new Opportunity(
            Name = 'Opportunity 3',
            Funnel__c = 'Mídias Vendas',
            Media__c = 'sbt', 
            AccountId = acc1.Id, 
            Telefone__c = '5551981617948', 
            Segmento__c = 'Aplicativos', 
            Tipo_de_cliente__c = 'Cliente Final', 
            CloseDate = Date.today().addDays(5), 
            StageName = 'Qualificação', 
            Emaill__c = 'barbara@gmail.com', 
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal', 
            Veiculacao__c = 'TV', 
            Telefone1__c = '+5551981617948',
            CNPJ__c = '42113212000125',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            SaleType__c = 'Cliente Novo'
        );

        /** ------------- Botões ------------- */
        RecordType varejoRT = [SELECT Id From RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Varejo' LIMIT 1];
        Opportunity opp4 = new Opportunity(
            Name = 'Opportunity 4',
            Funnel__c = 'Varejo',
            RecordTypeId = varejoRT.Id,
            AccountId = acc1.Id, 
            Telefone__c = '5551981617948', 
            Segmento__c = 'Aplicativos', 
            Tipo_de_cliente__c = 'Cliente Final', 
            CloseDate = Date.today().addDays(5), 
            Emaill__c = 'barbara@gmail.com', 
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal', 
            Veiculacao__c = 'TV', 
            Telefone1__c = '+5551981617948',
            CNPJ__c = '42113212000125',
            Pol_tica_Comercial__c = 'Preço normal',
            ContractStartDate__c = Date.today().addDays(10),
            EndOfContractDate__c = Date.today().addDays(30),
            StageName = 'Qualificação',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Ja_foi_anunciante__c = 'Não',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            HaveCurrentlyAgency__c = 'Sim',
            WhatsYourRole__c = 'Fundador/Sócio',
            NumberEmployees__c = '05 - 20',
            CompanyAge__c = 'Menos de 1 ano',
            SaleType__c = 'Cliente Novo'
        );

        insert new List<Opportunity>{opp1, opp2, opp3, opp4};
        
        Quote quote = VirtualTestData.createQuote('Teste Quote', opp4.Id);
        quote.VendaFutura__c = true;
        insert quote;
    }

    @isTest
    static void shouldCloneOppWithSBTMedia(){
        Opportunity opp1 = [SELECT Id, Name FROM Opportunity WHERE Name = 'Opportunity 1' LIMIT 1];

        Test.startTest();
        opp1.Lead__c = '00Q8900000EFFGPEA5';
        update opp1;
        
        Opportunity clonedOpp1 = OpportunityCloneController.cloneOpportunityWithSBT(opp1.Id);
        Test.stopTest();

        Opportunity result1 = [SELECT Id, Name, Media__c, StageName, RelatedOpportunity__c FROM Opportunity WHERE Id = :clonedOpp1.Id];
        System.debug('O campo Media__c é: ' + clonedOpp1.Media__c);

        System.assertEquals('sbt', result1.Media__c, 'O campo Mídia não foi atualizado para sbt');
        System.assertEquals('Aprovado', result1.StageName, 'O campo Stage não foi atualizado para Aprovado');
        System.assertEquals(opp1.Id, clonedOpp1.RelatedOpportunity__c, 'O RelatedOpportunity__c não foi atualizado corretamente');
        System.assertEquals(true, clonedOpp1.ClonedWithMediaSBT__c, 'O campo ClonedWithMediaSBT__c não foi ativado');
        System.assertEquals(opp1.Lead__c, clonedOpp1.Lead__c, 'O campo Lead__c não foi preenchido');                      
    }

    @IsTest
    static void shouldNotCloneOppWithSBTMedia_MediaIsNotNull() {
        Opportunity opp2 = [SELECT Id, Name, ClonedWithMediaSBT__c FROM Opportunity WHERE Name = 'Opportunity 2' LIMIT 1];

        Test.startTest();
        Boolean exceptionThrown2 = false;

        try {
            OpportunityCloneController.cloneOpportunityWithSBT(opp2.Id);
            System.assert(false, 'O método não lançou uma exceção porque o campo Mídia não está nulo');
            System.assertEquals(false, opp2.ClonedWithMediaSBT__c, 'O campo ClonedWithMediaSBT__c foi ativado');      

        } catch (AuraHandledException e){
            System.debug('Mensagem de erro do Test2: ' + e.getMessage());
            exceptionThrown2 = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown2, 'Nenhuma exceção foi lançada');
    }

    @IsTest
    static void shouldNotCloneOppWithSBTMedia_FunnelIsNotVarejo(){
        Opportunity opp3 = [SELECT Id, Name FROM Opportunity WHERE Name = 'Opportunity 3' LIMIT 1];

        Test.startTest();
        Boolean exceptionThrown3 = false;

        try {
            OpportunityCloneController.cloneOpportunityWithSBT(opp3.Id);
            System.assert(false, 'O método não lançou uma exceção porque o funil não é Varejo');
            System.assertEquals(false, opp3.ClonedWithMediaSBT__c, 'O campo ClonedWithMediaSBT__c foi ativado');      

        } catch (AuraHandledException e) {
            System.debug('Mensagem de erro do Test3: ' + e.getMessage());
            exceptionThrown3 = true;
        }        
        Test.stopTest();

        System.assert(exceptionThrown3, 'Nenhuma exceção foi lançada');
    }

    @isTest
    static void shouldCloneOppRenovacao(){
        Opportunity opp = [SELECT Id, Name, StageName, RecordType.DeveloperName FROM Opportunity WHERE Name = 'Opportunity 4' LIMIT 1];

        Test.startTest();        
        opp.StageName = 'Venda Futura';
        update opp;

        Opportunity clonedOpp1 = OpportunityCloneController.cloneOpportunityRenovacao(opp.Id);
        Test.stopTest();

        Opportunity result = [SELECT Id, Name, StageName, Pol_tica_Comercial__c, ContractStartDate__c, EndOfContractDate__c FROM Opportunity WHERE Id = :clonedOpp1.Id];

        System.assertEquals(null, result.Pol_tica_Comercial__c, 'O campo Pol_tica_Comercial__c não está em branco');
        System.assertEquals(null, result.ContractStartDate__c, 'O campo ContractStartDate__c não está em branco');
        System.assertEquals(null, result.EndOfContractDate__c, 'O campo EndOfContractDate__c não está em branco');

        System.debug('O StageName é: ' + result.StageName);
        System.assertEquals('Qualificação', result.StageName, 'O campo StageName não está está em "Qualificação"');
    }

    @isTest
    static void shouldCloneOppUpsell(){
        Opportunity opp = [SELECT Id, Name, StageName, RecordType.DeveloperName FROM Opportunity WHERE Name = 'Opportunity 4' LIMIT 1];

        Test.startTest();        
        opp.StageName = 'Venda Futura';
        update opp;

        Opportunity clonedOpp1 = OpportunityCloneController.cloneOpportunityUpsell(opp.Id);
        Test.stopTest();

        Opportunity result = [SELECT Id, Name, StageName, Pol_tica_Comercial__c, ContractStartDate__c, EndOfContractDate__c FROM Opportunity WHERE Id = :clonedOpp1.Id];

        System.assertEquals(null, result.Pol_tica_Comercial__c, 'O campo Pol_tica_Comercial__c não está em branco');
        System.assertEquals(null, result.ContractStartDate__c, 'O campo ContractStartDate__c não está em branco');
        System.assertEquals(null, result.EndOfContractDate__c, 'O campo EndOfContractDate__c não está em branco');

        System.debug('O StageName é: ' + result.StageName);
        System.assertEquals('Qualificação', result.StageName, 'O campo StageName não está está em "Qualificação"');
    }        
}