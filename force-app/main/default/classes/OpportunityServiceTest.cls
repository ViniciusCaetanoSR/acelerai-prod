/**
 * @description       :
 * @author            : Vinícius Caetano
 * @group             :
 * @last modified on  : 21-03-2025
 * @last modified by  : Vinícius Caetano
**/
@isTest
private class OpportunityServiceTest {
    @testSetup
    static void setup() {
        RecordType midiasRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'MidiasVendas' AND SObjectType = 'Opportunity' LIMIT 1];

        Account acc1 = new Account(
            Name = 'Test Account 1',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1'
        );
        Account acc2 = new Account(
            Name = 'Test Account 2',
            CNPJ__c = '40091163000141',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 2'
        );
        insert new List<Account>{ acc1, acc2 };

        Contact contact0 = new Contact(LastName = 'Test Contact 0', Email = '6845387306452580136@test.com', Phone = '51981617948', AccountId = acc2.Id);
        insert contact0;

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity da Conta 1',
            AccountId = acc2.Id,
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
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Pol_tica_Comercial__c = 'Preço normal',
            Ja_foi_anunciante__c = 'Não',
            HaveCurrentlyAgency__c = 'Não',
            WhatsYourRole__c = 'Diretor',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            SaleType__c = 'Upsell'
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity da Conta 2',
            AccountId = acc2.Id,
            Telefone__c = '5551981617948',
            Segmento__c = 'Tecnologia',
            Tipo_de_cliente__c = 'Cliente Final',
            CloseDate = Date.today().addDays(10),
            StageName = 'Qualificação',
            Emaill__c = 'example@gmail.com',
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal',
            Veiculacao__c = 'TV',
            Telefone1__c = '+5551981617948',
            CNPJ__c = '40091163000141',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Pol_tica_Comercial__c = 'Preço normal',
            Ja_foi_anunciante__c = 'Não',
            HaveCurrentlyAgency__c = 'Não',
            WhatsYourRole__c = 'Diretor',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            SaleType__c = 'Upsell'
        );

        Opportunity opp3 = new Opportunity(
            Name = 'Opportunity da Conta 2',
            AccountId = acc2.Id,
            Telefone__c = '5551981617948',
            Segmento__c = 'Tecnologia',
            Tipo_de_cliente__c = 'Cliente Final',
            CloseDate = Date.today().addDays(10),
            StageName = 'Qualificação',
            Emaill__c = 'example@gmail.com',
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal',
            Veiculacao__c = 'TV',
            Telefone1__c = '+5551981617948',
            CNPJ__c = '40091163000141',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Pol_tica_Comercial__c = 'Preço normal',
            Ja_foi_anunciante__c = 'Não',
            HaveCurrentlyAgency__c = 'Não',
            WhatsYourRole__c = 'Diretor',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            SaleType__c = 'Upsell'
        );

        Opportunity opp4 = new Opportunity(
            Name = 'Opportunity da Conta 2',
            AccountId = acc2.Id,
            Telefone__c = '5551981617948',
            Segmento__c = 'Tecnologia',
            Tipo_de_cliente__c = 'Cliente Final',
            CloseDate = Date.today().addDays(10),
            StageName = 'Perdido',
            Emaill__c = 'example@gmail.com',
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal',
            Veiculacao__c = 'Mídia On',
            Telefone1__c = '+5551981617948',
            CNPJ__c = '40091163000141',
            RecordTypeId = midiasRecordType.Id,
            Media__c = 'sbt',
            ContatoComprador__c = contact0.Id,
            ContatoFinanceiro__c = contact0.Id,
            ContatoJuridico__c = contact0.Id,
            ContatosMarketing__c = contact0.Id,
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Pol_tica_Comercial__c = 'Preço normal',
            Ja_foi_anunciante__c = 'Não',
            HaveCurrentlyAgency__c = 'Não',
            WhatsYourRole__c = 'Diretor',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            SaleType__c = 'Upsell'
        );

        insert new List<Opportunity>{ opp1, opp2, opp3, opp4 };

        Quote quote = VirtualTestData.createQuote('Quote Test', opp1.Id);
        quote.Pricebook2Id = Test.getStandardPricebookId();

        Product2 product = VirtualTestData.createProduct('Product Test', 'Direito de Uso');
        insert product;

        PricebookEntry pricebookEntry = VirtualTestData.createPriceBookEntry(product.Id, Test.getStandardPricebookId(), 1000);

        insert new List<SObject> {
            quote,
            pricebookEntry
        };

        AssignmentGroup__c assignmentGroup = new AssignmentGroup__c(Name = 'Group 1', Object__c = 'Lead', Media__c = 'sbt');
        insert assignmentGroup;

        AssignmentGroupMember__c member = new AssignmentGroupMember__c();
        member.AssignmentGroup__c = assignmentGroup.Id;
        member.User__c = [SELECT Id, Profile.Name FROM User WHERE Profile.Name = 'Triagem' LIMIT 1].Id;

        insert member;
    }

    @isTest
    static void testValidatePhoneNumber() {
        List<Opportunity> opps = [SELECT Id, Telefone1__c FROM Opportunity];
        OpportunityService.validatePhoneNumber(opps);

        for (Opportunity opp : opps) {
            System.assertNotEquals(null, opp.Telefone1__c);
        }
    }

    @isTest
    static void testSendOpportunityStatusToProposalOnQuoteWaitingApproval() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Quote quoteOld = new Quote(OpportunityId = opp.Id, Name = 'Old Quote', Status = 'Draft');

        insert quoteOld;

        Quote quoteNew = new Quote(Id = quoteOld.Id, OpportunityId = opp.Id, Name = 'New Quote', Status = 'AGUARDANDO_ACEITE');

        Test.startTest();

        Map<Id, Quote> oldQuotesMap = new Map<Id, Quote>{ quoteOld.Id => quoteOld };
        Map<Id, Quote> newQuotesMap = new Map<Id, Quote>{ quoteNew.Id => quoteNew };

        update quoteNew;
        OpportunityService.sendOpportunityStatusToProposalOnQuoteWaitingApproval(newQuotesMap, oldQuotesMap);

        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Proposta Enviada', updatedOpp.StageName);

        Test.stopTest();
    }

    @isTest
    static void testClone() {
        Opportunity opp = [SELECT Id, AccountId, ContatosMarketing__c, ContatoComprador__c, ContatoFinanceiro__c, ContatoJuridico__c FROM Opportunity LIMIT 1];
        Test.startTest();
        Opportunity clonedOpp = opp.clone(false, true);

        clonedOpp.AccountId = opp.AccountId;
        clonedOpp.ContatoComprador__c = opp.ContatoComprador__c;
        clonedOpp.ContatoFinanceiro__c = opp.ContatoFinanceiro__c;
        clonedOpp.ContatoJuridico__c = opp.ContatoJuridico__c;
        clonedOpp.ContatosMarketing__c = opp.ContatosMarketing__c;

        clonedOpp.Name = 'Cloned Opp';
        clonedOpp.Telefone__c = '5551981617948';
        clonedOpp.Segmento__c = 'Aplicativos';
        clonedOpp.Tipo_de_cliente__c = 'Cliente Final';
        clonedOpp.CloseDate = Date.today().addDays(5);
        clonedOpp.StageName = 'Qualificação';
        clonedOpp.Emaill__c = 'barbara@gmail.com';
        clonedOpp.ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal';
        clonedOpp.Veiculacao__c = 'TV';
        clonedOpp.Telefone1__c = '+5551981617948';
        clonedOpp.CNPJ__c = '42113212000125';

        insert clonedOpp;
        Test.stopTest();
    }

    @isTest
    static void updateAccountDatesTest() {

        Quote quote = [SELECT Id, Status, OpportunityId FROM Quote WHERE Name = 'Quote Test' LIMIT 1];
        quote.Sincronizado__c = true;
        update quote;

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.StageName = 'Ganho';
        opp.ContractStartDate__c = Date.today();
        opp.EndOfContractDate__c = Date.today().addDays(30);

        update opp;
    }

    @isTest
    static void testValidateStageGanho() {
        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;

        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Quote quote = VirtualTestData.createQuote(
            'QuoteName',
            opportunity.Id
        );

        quote.VendaFutura__c = true;
        quote.Sincronizado__c = true;
        quote.PagamentoFuturo__c = false;
        quote.DataVendaFutura__c = Date.today().addDays(-7);

        insert quote;

        Test.startTest();
        opportunity.StageName = 'Ganho';
        update opportunity;
        Test.stopTest();

        Opportunity updateOpportunity = [SELECT StageName FROM Opportunity WHERE Id = : Opportunity.Id];
        System.assertEquals('Ganho', updateOpportunity.StageName, 'Oportunidade deve ter sido alterada para Ganho');

        Quote updateQuote = [SELECT VendaFutura__c, PagamentoFuturo__c FROM Quote WHERE Id = :quote.Id];
        System.assertEquals(true, updateQuote.VendaFutura__c , 'Venda Futura deve ser verdadeira');
        System.assertEquals(false, updateQuote.PagamentoFuturo__C, 'Pagamento Futuro deve ser falso');

    }

    @isTest
    static void testValidateStageGanhoPagamentoFuturo() {

        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;

        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Quote quote = VirtualTestData.createQuote(
            'QuoteName',
            opportunity.Id
        );

        quote.Sincronizado__c = true;
        quote.VendaFutura__c = true;
        quote.PagamentoFuturo__c = true;
        quote.DataVendaFutura__c = Date.today().addDays(-7);
        insert quote;

        Test.startTest();
        opportunity.StageName = 'Ganho Pagamento Futuro';
        update opportunity;
        Test.stopTest();

        Opportunity updateOpportunity = [SELECT StageName FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Ganho Pagamento Futuro', updateOpportunity.StageName, 'Oportunidade deve ter sido alterada para Ganho Pagamento futuro');

        Quote updateQuote = [SELECT VendaFutura__c, PagamentoFuturo__c FROM Quote WHERE Id = :quote.Id];
        System.assertEquals(true, updateQuote.VendaFutura__c , 'Venda Futura deve ser verdadeira');
        System.assertEquals(true, updateQuote.PagamentoFuturo__C, 'Pagamento Futuro deve ser verdadeiro');

    }

    @isTest
    static void testDuplicateOpportunityOpen() {
        Account account = VirtualTestData.createAccount('accountName');
        account.Type = 'Agência';
        insert account;

        Opportunity opportunityOpen = VirtualTestData.createOpportunity(
            'opportunityName',
            account.Id,
            '674867536768',
            'Financeiro',
            'Cliente final',
            Date.today().addDays(7),
            'Aprovado'
        );

        opportunityOpen.Emaill__c = 'teste@example.com';
        opportunityOpen.Agencia__c = account.Id;

        insert opportunityOpen;

        Lead leadTeste = new Lead(
          FirstName = 'Lead',
          LastName = 'Teste',
          Email = 'teste@example.com',
          Phone = '6768768763363'
        );

        Test.startTest();
            insert leadTeste;
        Test.stopTest();
    }

    @isTest
    static void testDuplicateOpportunityClosed() {
        Id recordTypeVarejo = [SELECT Id FROM RecordType WHERE DeveloperName = 'Varejo' AND SObjectType = 'Opportunity' LIMIT 1].Id;

        User userInativo = new User(
            Username = 'userinativo@test.com',
            Email = 'userinativo@test.com',
            Alias = 'iuser',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LastName = 'Inativo ',
            FirstName = 'User',
            IsActive = True
        );

        insert userInativo;

        Account account = new Account(
            Name = 'accountName',
            SocialMedia_website__c = 'Social Media Test',
            CompanyName__c = 'CTest',
            Phone = '+5551982347754',
            TypeIntermediary__c = 'Agência',
            CNPJ__c = '16534005000134',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingCountry = 'Country',
            BillingState = 'AC',
            BillingPostalCode = '12345',
            Type = 'Agência',
            Tipodeintermediador__c = 'Agência'
        );
        insert account;

        Contact contact = VirtualTestData.createContact(
            'lastName',
            account.Id,
            'teste@example.com',
            '6768768563363'
            );

            insert contact;

        Opportunity opportunityClosed = VirtualTestData.createOpportunity(
            'opportunityName',
            account.Id,
            '674867536768',
            'Financeiro',
            'Cliente final',
            Date.today().addDays(7),
            'Aprovado'
        );

        opportunityClosed.Emaill__c = 'teste@example.com';
        opportunityClosed.CNPJ__c = '16534005000134';
        opportunityClosed.RecordTypeId = recordTypeVarejo;
        opportunityClosed.Funnel__c = 'Varejo';
        opportunityClosed.OwnerId = userInativo.Id;


        insert opportunityClosed;

        Quote quote = VirtualTestData.createQuote(
            'QuoteName',
            opportunityClosed.Id
        );

        quote.VendaFutura__c = true;
        quote.DataVendaFutura__c = Date.today().addDays(-7);

        insert quote;

        opportunityClosed.StageName = 'Venda Futura';
        update opportunityClosed;

        Lead leadTeste = new Lead(
          FirstName = 'Lead',
          LastName = 'Teste',
          Email = 'teste@example.com',
          Phone = '6768768763363'
        );

        Test.startTest();
            insert leadTeste;
        Test.stopTest();

        System.assertEquals(account.Id, opportunityClosed.AccountId , 'O AccountId deve ser o mesmo da Oportunidade');

    }

    @isTest
    static void testDuplicateOpportunityVendaRd() {
        Id recordTypeVendaRd = [SELECT Id FROM RecordType WHERE DeveloperName = 'VendaRD' AND SObjectType = 'Opportunity' LIMIT 1].Id;

        Account account = VirtualTestData.createAccount('accountName');
        account.CNPJ__c = '16534005000134';
        account.Type = 'Agência';
        insert account;

        Contact contact = VirtualTestData.createContact(
            'lastName',
            account.Id,
            'testecontact@example.com',
            '6768768563363'
            );

            insert contact;

        Opportunity opportunityVendaRD = VirtualTestData.createOpportunity(
            'opportunityName',
            account.Id,
            '674867536768',
            'Financeiro',
            'Cliente final',
            Date.today().addDays(7),
            'Venda Rd'
        );

        opportunityVendaRD.Emaill__c = 'teste@example.com';
        opportunityVendaRD.CNPJ__c = '16534005000134';
        opportunityVendaRD.RecordTypeId = recordTypeVendaRd;
        opportunityVendaRD.Funnel__c = 'Varejo';

        insert opportunityVendaRD;

        Lead leadTeste = new Lead(
          FirstName = 'Lead',
          LastName = 'Teste',
          Email = 'teste@example.com',
          Phone = '6768768763363'
        );

        Test.startTest();
            insert leadTeste;
        Test.stopTest();
    }

    @isTest
    static void testeSetContactIdWhenEmptySucess(){

        Account newAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];

        Opportunity oppWithoutContactId = new Opportunity(
            Name = 'Teste de Contact Id ' + datetime.now(),
            AccountId = newAccount.Id,
            Telefone__c = '5551981617948',
            Segmento__c = 'Tecnologia',
            Tipo_de_cliente__c = 'Cliente Final',
            CloseDate = Date.today().addDays(10),
            StageName = 'Qualificação',
            Emaill__c = '6845387306452580136@test.com',
            ClientsObjectiveWithAcelerai__c = 'Campanha Sazonal',
            Veiculacao__c = 'TV',
            Telefone1__c = '+5551981617948',
            CNPJ__c = '40091163000141',
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            Pol_tica_Comercial__c = 'Preço normal',
            Ja_foi_anunciante__c = 'Não',
            HaveCurrentlyAgency__c = 'Não',
            WhatsYourRole__c = 'Diretor',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            SaleType__c = 'Upsell'
        );

        insert oppWithoutContactId;


        Test.startTest();
        String result = OpportunityService.setContactIdWhenEmpty(new List<Opportunity> {oppWithoutContactId});
        Test.stopTest();

        System.assertEquals('Oportunidades com ContactIds preenchidos com sucesso', result);
    }

    @isTest
    static void testSendEmailOpportunityProductInactive() {

        User userActive = new User(
            Username = 'useractive@test.com',
            Email = 'useractive@test.com',
            Alias = 'useract',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LastName = 'Active',
            FirstName = 'User',
            IsActive = True
        );
        insert userActive;

        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;

        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'
        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Quote quote = VirtualTestData.createQuote('Quote Test', opportunity.Id);
        quote.Pricebook2Id = Test.getStandardPricebookId();
        quote.VendaFutura__c = true;
        quote.Sincronizado__c = true;
        quote.PagamentoFuturo__c = false;
        quote.DataVendaFutura__c = Date.today().addDays(-7);


        Product2 product = VirtualTestData.createProduct('Product Test', 'Direito de Uso');
        insert product;

        PricebookEntry pricebookEntry = VirtualTestData.createPriceBookEntry(product.Id, Test.getStandardPricebookId(), 1000);

        insert new List<SObject> {
            quote,
            pricebookEntry
        };

        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            OpportunityId = opportunity.Id,
            Product2Id = product.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oppLineItem;

        Test.startTest();

        product.IsActive = false;
        update product;

        Boolean validationError = false;

        try {
            opportunity.StageName = 'Ganho';
            update opportunity;
        } catch (DmlException e) {
            validationError = e.getMessage().contains('Não é possível fechar esta oportunidade pois ela contém produtos inativos');
        }

        EmailRequest__e emailRequest = new EmailRequest__e(OpportunityId__c = opportunity.Id);
        EventBus.publish(emailRequest);

        Test.stopTest();

        // Verifica se a exceção foi capturada corretamente
        System.assert(validationError, 'A validação de produto inativo deveria ter sido acionada.');

        // Verifique se a oportunidade recebeu um erro
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Em Negociação', updatedOpportunity.StageName, 'A oportunidade não deve ser fechada devido a produtos inativos.');

    }

    @IsTest
    static void testApplyNegotiationTemperatureRules() {

        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;
        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Test.startTest();
        Quote quote = VirtualTestData.createQuote('Quote Test', opportunity.Id);

        insert quote;

        Test.stopTest();

        Opportunity opportunityUpdated = [SELECT Id, Temperatura_da_negociacao__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assertEquals('Frio', opportunityUpdated.Temperatura_da_negociacao__c, 'Esperava temperatura igual a frio');
    }

    @IsTest
    static void testApplyNegotiationTemperatureRulesForNull() {

        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;
        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';

        insert opportunity;

        Quote quote = VirtualTestData.createQuote('Quote Test', opportunity.Id);
        insert quote;

        Test.startTest();
            try {
                opportunity.Temperatura_da_negociacao__c = null;
                update opportunity;
                System.assert(false, 'Era esperado lançar exceção e não lançou.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Não é possível retirar a seleção de temperatura'),
                    'Mensagem de erro diferente do esperado. Retornou: ' + e.getMessage());
            }
        Test.stopTest();
    }

    @IsTest
    static void testApplyNegotiationTemperatureRulesForInsert() {

        Account accountTest = VirtualTestData.createAccount('accountName');
        insert accountTest;

        Contact contactTest = VirtualTestData.createContact('lastName', accountTest.Id, 'test@example.com', '77673267632763');
        insert contactTest;
        Opportunity opportunity = VirtualTestData.createOpportunity(
            'opportunityName',
            accountTest.Id,
            '674867536768',
            'Financeiro',
            'clientType',
            Date.today().addDays(7),
            'Em Negociação'

        );

        opportunity.MonthlyInvestmentMedia_Content__c = 'Não Invisto';
        opportunity.Tipo_de_Cliente__C = 'Cliente final';
        opportunity.Ja_foi_anunciante__c = 'Não';
        opportunity.Veiculacao__c = 'Mídia On';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.WhatsYourRole__c = 'Analista';
        opportunity.QuandoPretendeAnunciar__c = 'Imediatamente';
        opportunity.CNPJ__c = '16534005000134';
        opportunity.ClientsObjectiveWithAcelerai__c = 'Campanha de Lançamento';
        opportunity.HaveCurrentlyAgency__c = 'Sim';
        opportunity.ContatoComprador__c = contactTest.Id;
        opportunity.ContatoFinanceiro__c = contactTest.Id;
        opportunity.ContatoJuridico__c = contactTest.Id;
        opportunity.ContatosMarketing__c = contactTest.Id;
        opportunity.Pol_tica_Comercial__c = 'Preço normal';
        opportunity.SaleType__c = 'Upsell';
        opportunity.Temperatura_da_negociacao__c = 'Frio';

         Test.startTest();
            try {
                insert opportunity;
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('Para alterar a Temperatura da Negociação, deve-se ter proposta válida (<7 dias)'),
                    'Mensagem de erro diferente do esperado. Retornou: ' + e.getMessage());
            }

        Test.stopTest();
    }
}