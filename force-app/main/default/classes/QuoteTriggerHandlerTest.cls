@isTest
public with sharing class QuoteTriggerHandlerTest {
    //OpportunityLineItemServiceTest
    @TestSetup
    static void makeData(){
        Account account = VirtualTestData.createAccount('Account Test');
        insert account;

        Opportunity opportunity = VirtualTestData.createOpportunity('Opp Test', account.Id, '51981234565', 'Agronegócio', 'Agência', Date.today(), 'Qualificação');
        insert opportunity;

        Quote quote = VirtualTestData.createQuote('Quote Test', opportunity.Id);
        quote.Pricebook2Id = Test.getStandardPricebookId();

        Product2 product = VirtualTestData.createProduct('Product Test', 'Direito de Uso');
        insert product;

        PricebookEntry pricebookEntry = VirtualTestData.createPriceBookEntry(product.Id, Test.getStandardPricebookId(), 1000);

        insert new List<SObject> {
            quote,
            pricebookEntry
        };
    }

    @isTest
    private static void onBeforeUpdateShouldSyncQuoteToOpp () {
        Quote quote = [SELECT Id, Status FROM Quote WHERE Name = 'Quote Test' LIMIT 1];

        Test.startTest();
            quote.Status = 'PAGAMENTO_REALIZADO';
            update quote;
        Test.stopTest();

        Quote actualResult = [SELECT Sincronizado__c, Status FROM Quote WHERE Id =:quote.Id LIMIT 1];
        Assert.areEqual('FINALIZADA', actualResult.Status);
        Assert.areEqual(true, actualResult.Sincronizado__c);
    }

    @isTest
    private static void onBeforeUpdateShouldInsertOpportunityLineItems () {
        Quote quote = [SELECT Id, Status, OpportunityId FROM Quote WHERE Name = 'Quote Test' LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        insert quoteProduct;

        Test.startTest();
            quote.Status = 'PAGAMENTO_REALIZADO';
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size(), 'onBeforeUpdateShouldInsertOpportunityLineItems');
    }

    @isTest
    private static void onBeforeUpdateShouldUpdateOpportunityLineItemQuantity () {
        Quote quote = [SELECT Id, Status, OpportunityId FROM Quote WHERE Name = 'Quote Test' LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opp Test'];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        OpportunityLineItem opportunityProduct = VirtualTestData.createOpportunityLineItem(opportunity, pricebookEntry.Product2Id, pricebookEntry);

        insert new List<SObject> {
            quoteProduct,
            opportunityProduct
        };

        Test.startTest();
            quote.Status = 'PAGAMENTO_REALIZADO';
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id, Quantity FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size(), 'onBeforeUpdateShouldUpdateOpportunityLineItemQuantity');
        Assert.areEqual(10, actualResult.get(0).Quantity);
    }

    @isTest 
    private static void onAfterUpdateShouldDeleteOppLineItemsAndInsertNewCount () {
        Quote quote = [SELECT Id, Status, OpportunityId FROM Quote WHERE Name = 'Quote Test' LIMIT 1];
        quote.Sincronizado__c = true;
        update quote;

        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opp Test'];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        
        Quote mainQuote = VirtualTestData.createQuote('Quote Test 2', opportunity.Id);
        mainQuote.Pricebook2Id = Test.getStandardPricebookId();
        mainQuote.Sincronizado__c = true;
        insert mainQuote;

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(mainQuote, pricebookEntry.Product2Id, pricebookEntry);
        QuoteLineItem secondQuoteProduct = VirtualTestData.createQuoteLineItem(mainQuote, pricebookEntry.Product2Id, pricebookEntry);
        
        OpportunityLineItem opportunityProduct = VirtualTestData.createOpportunityLineItem(opportunity, pricebookEntry.Product2Id, pricebookEntry);

        insert new List<SObject> {
            quoteProduct,
            secondQuoteProduct,
            opportunityProduct
        };

        Test.startTest();
            quote.Sincronizado__c = false;
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id, Quantity FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size(), 'onAfterUpdateShouldDeleteOppLineItemsAndInsertNewCount');
    }


    @isTest
    private static void shouldSyncOppQuoteProductsViaFlow () {
        Quote quote = [SELECT Id, Status, OpportunityId, PagamentoFuturo__c FROM Quote WHERE Name = 'Quote Test' LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        insert quoteProduct;

        Test.startTest();
            QuoteService.syncQuoteWithOpportunity(new List<Quote> {quote});
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size());
    }

    @isTest
    private static void shouldNotSyncOppQuoteProductsViaFlowBecauseIsFuturePayment () {
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        
        Quote quote = [SELECT Id, Status, OpportunityId, PagamentoFuturo__c FROM Quote WHERE Name = 'Quote Test' LIMIT 1];
        quote.PagamentoFuturo__c = true;
        update quote;

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        insert quoteProduct;

        Test.startTest();
            QuoteService.syncQuoteWithOpportunity(new List<Quote> {quote});
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size(),'shouldNotSyncOppQuoteProductsViaFlowBecauseIsFuturePayment');
    }

    @isTest
    static void testUpdateOppStatus(){
        Quote quote = [SELECT Id, Status, OpportunityId FROM Quote WHERE Name = 'Quote Test'];
        
        Test.startTest();
            quote.status = 'AGUARDANDO_ACEITE';
            update quote;
        Test.stopTest();

        Opportunity outcomeOpp = [SELECT Id, StageName FROM Opportunity WHERE Id =:quote.OpportunityId];
        Assert.areEqual('Proposta Enviada', outcomeOpp.StageName);
    }

    @isTest
    private static void shouldCreateNewOppProductsForFuturePayment () {
        Quote quote = [SELECT Id, Status, OpportunityId, PagamentoFuturo__c FROM Quote WHERE Name = 'Quote Test'];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        insert quoteProduct;
        
        Test.startTest();
            quote.PagamentoFuturo__c = true;
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size());
    }

    @isTest
    private static void shouldCreateNewOppProductsWhenUpdatingAllThreeFields () {
        Quote quote = [SELECT Id, Status, OpportunityId, PagamentoFuturo__c, Sincronizado__c FROM Quote WHERE Name = 'Quote Test'];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        insert quoteProduct;
        
        Test.startTest();
            quote.PagamentoFuturo__c = true;
            quote.Sincronizado__c = true;
            quote.Status = 'PAGAMENTO_REALIZADO';
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size());
    }

    @isTest
    private static void shouldDoNothingBecauseOpportunityIsMediaSales () {
        Account account = [SELECT Id FROM Account LIMIT 1];

        Opportunity opportunity = VirtualTestData.createOpportunity('Opp Test 2', account.Id, '51981234565', 'Agronegócio', 'Agência', Date.today(), 'Validação e Proposta', 'MidiasVendas');
        insert opportunity;

        Quote quote = VirtualTestData.createQuote('Quote Test 2', opportunity.Id);
        insert quote;

        Test.startTest();
            quote.Sincronizado__c = true;
            quote.PagamentoFuturo__c = true;
            quote.Status = 'PAGAMENTO_REALIZADO';
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(0, actualResult.size(), 'shouldDoNothingBecauseOpportunityIsMediaSales');
    }

    @isTest 
    private static void onAfterUpdateShouldDeleteOppLineItems () {
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Opp Test'];

        Quote quote = [SELECT Id, Status, PagamentoFuturo__c, OpportunityId FROM Quote WHERE Name = 'Quote Test'];
        quote.PagamentoFuturo__c = true;
        update quote;

        OpportunityLineItem opportunityLineItem = VirtualTestData.createOpportunityLineItem(opportunity, pricebookEntry.Product2Id, pricebookEntry);
        insert opportunityLineItem;

        Test.startTest();
            quote.PagamentoFuturo__c = false;
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id, Quantity FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(0, actualResult.size(),'onAfterUpdateShouldDeleteOppLineItems');
    }

    @isTest
    private static void shouldNotDeleteBecauseOpportunityIsMediaSales () {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];

        Opportunity opportunity = VirtualTestData.createOpportunity('Opp Test 2', account.Id, '51981234565', 'Agronegócio', 'Agência', Date.today(), 'Validação e Proposta', 'MidiasVendas');
        insert opportunity;

        OpportunityLineItem opportunityLineItem = VirtualTestData.createOpportunityLineItem(opportunity, pricebookEntry.Product2Id, pricebookEntry);
        insert opportunityLineItem;

        Quote quote = VirtualTestData.createQuote('Quote Test 2', opportunity.Id);
        quote.PagamentoFuturo__c = true;
        insert quote;

        Test.startTest();
            quote.PagamentoFuturo__c = false;
            update quote;
        Test.stopTest();

        List<OpportunityLineItem> actualResult = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId];
        Assert.areEqual(1, actualResult.size());
    }
}