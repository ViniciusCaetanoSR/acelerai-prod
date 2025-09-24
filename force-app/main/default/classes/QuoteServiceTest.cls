@isTest
public with sharing class QuoteServiceTest {
    @TestSetup
    static void makeData(){
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
        insert acc1;

        Contact contact = new Contact(LastName = 'Test Contact Pipo', Email = '6845387306452580136@test.com', Phone = '5551981617948', AccountId = acc1.Id);
        insert contact;
             
        Opportunity origOpp = new Opportunity(
            Name = 'Opportunity 1',
            AccountId = acc1.Id, 
            CloseDate = Date.today(),
            CNPJ__c = '42113212000125',
            StageName = 'Prospecting',
            ContactId = contact.Id,
            Emaill__c = 'barbara.mata@srconsulting.io',
            Telefone1__c = '5551981617948',
            Probability = 10,
            ContatoComprador__c = contact.Id,
            ContatoFinanceiro__c = contact.Id,
            ContatoJuridico__c = contact.Id,
            ContatosMarketing__c = contact.Id,
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            ClientsObjectiveWithAcelerai__c = 'Campanha Institucional',
            Pol_tica_Comercial__c = 'Preço normal',
            Ja_foi_anunciante__c = 'Não',
            HaveCurrentlyAgency__c = 'Não',
            WhatsYourRole__c = 'Diretor',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            Tipo_de_cliente__c = 'Cliente final',
            SaleType__c = 'Upsell',
            Veiculacao__c = 'Rádio'
        );
 
        insert origOpp;
    }
    
    @isTest
    private static void shouldNullFieldWhenCancelQuote() {
        List <Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote newQuote = new Quote (Name = 'Kciuq', Valor_Final__c = 2324, PagamentoFuturo__c = true, OpportunityId = opp[0].Id);
        insert newQuote;

        newQuote.Status = 'Cancelada';
        update newQuote;

        Map<Id, Quote> quoteMap = new Map<Id, Quote>();
        quoteMap.put(newQuote.Id, newQuote);

        Test.startTest();
        QuoteService.nullFieldCanceledQuote(quoteMap);
        Test.stopTest();
        
        List<Quote> quoteListResult = [SELECT Name, Valor_Final__c, PagamentoFuturo__c, VendaFutura__c, DataVendaFutura__c FROM Quote WHERE Name = 'Kciuq' LIMIT 1];
        Boolean quoteResultPagamento = quoteListResult[0].PagamentoFuturo__c;
        Decimal quoteResultValor = quoteListResult[0].Valor_Final__c;
        Boolean quoteVendaFutura = quoteListResult[0].VendaFutura__c;
        Date quoteDataVendaFutura = quoteListResult[0].DataVendaFutura__c;

        Assert.areEqual(false, quoteResultPagamento);
        Assert.areEqual(null, quoteResultValor);
        Assert.areEqual(false, quoteVendaFutura);
        Assert.areEqual(null, quoteDataVendaFutura);
    }

    @isTest
    private static void shouldNOTNullFieldWhenCancelQuote() {
        List <Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        Quote newQuote = new Quote (Name = 'otasim', Valor_Final__c = 2328, PagamentoFuturo__c = true, OpportunityId = opp[0].Id);
        insert newQuote;

        newQuote.Status = 'Aguardando envio do link';
        update newQuote;

        Map<Id, Quote> quoteMap = new Map<Id, Quote>();
        quoteMap.put(newQuote.Id, newQuote);
        
        Test.startTest();        
        QuoteService.nullFieldCanceledQuote(quoteMap);
        Test.stopTest();
        
        List<Quote> quoteListResult = [SELECT Name, Valor_Final__c, PagamentoFuturo__c FROM Quote WHERE Name = 'otasim' LIMIT 1];
        Boolean quoteResultPagamento = quoteListResult[0].PagamentoFuturo__c;
        Decimal quoteResultValor = quoteListResult[0].Valor_Final__c;

        Assert.areEqual(true, quoteResultPagamento);
        Assert.areEqual(2328, quoteResultValor);
    }
}