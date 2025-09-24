@isTest
public with sharing class QuoteLineItemServiceTest {

    @TestSetup
    static void makeData () {
        
        Account account = VirtualTestData.createAccount('Account Test');
        insert account;

        Opportunity opportunity = VirtualTestData.createOpportunity('Opportunity Test', account.Id, '+5551981752134', 'Agronegócio', 'Agência', Date.today(), 'Qualificação');
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
    private static void shouldCloneQuoteProductsToAnotherQuote () {
        Opportunity opportunity = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Opportunity Test' LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Quote Test' LIMIT 1];

        Quote otherQuote = VirtualTestData.createQuote('Quote Test 2', opportunity.Id);
        otherQuote.CotacaoClonadaId__c = quote.Id;
        otherQuote.Pricebook2Id = Test.getStandardPricebookId();

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        
        insert new List<SObject> {
            otherQuote,
            quoteProduct
        };

        QuoteLineItemService.MediaSalesFlowInputs flowInputs = new QuoteLineItemService.MediaSalesFlowInputs();
        flowInputs.quoteLinesToClone = new List<QuoteLineItem> { quoteProduct };
        flowInputs.insertedQuotes = new List<Quote> { otherQuote };

        Test.startTest();
            QuoteLineItemService.populateQuoteLineItemsToClone(new List<QuoteLineItemService.MediaSalesFlowInputs> {flowInputs});
        Test.stopTest();

        List<QuoteLineItem> actualResult = [SELECT Id FROM QuoteLineItem WHERE QuoteId =:otherQuote.Id];
        Assert.areEqual(1, actualResult.size());
    }

    @isTest
    private static void shouldNotCloneBecauseValuesAreEmpty() {
        Opportunity opportunity = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Opportunity Test' LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Quote Test' LIMIT 1];

        Quote otherQuote = VirtualTestData.createQuote('Quote Test 2', opportunity.Id);
        otherQuote.CotacaoClonadaId__c = quote.Id;
        otherQuote.Pricebook2Id = Test.getStandardPricebookId();
        insert otherQuote;

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(otherQuote, pricebookEntry.Product2Id, pricebookEntry);
        insert quoteProduct;
        
        Test.startTest();
            QuoteLineItemService.populateQuoteLineItemsToClone(new List<QuoteLineItemService.MediaSalesFlowInputs> {});
        Test.stopTest();

        List<QuoteLineItem> actualResult = [SELECT Id FROM QuoteLineItem WHERE QuoteId =:otherQuote.Id];
        Assert.areEqual(1, actualResult.size());        
    }

    @isTest
    private static void shouldNotCloneBecauseTheresNothingToClone () {
        Opportunity opportunity = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Opportunity Test' LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, Product2Id FROM PricebookEntry LIMIT 1];
        Quote quote = [SELECT Id FROM Quote WHERE Name = 'Quote Test' LIMIT 1];

        Quote secondQuote = VirtualTestData.createQuote('Quote Test 2', opportunity.Id);
        secondQuote.Pricebook2Id = Test.getStandardPricebookId();
        insert secondQuote;

        Quote thirdQuote = VirtualTestData.createQuote('Quote Test 3', opportunity.Id);
        thirdQuote.CotacaoClonadaId__c = secondQuote.Id;
        thirdQuote.Pricebook2Id = Test.getStandardPricebookId();

        QuoteLineItem quoteProduct = VirtualTestData.createQuoteLineItem(quote, pricebookEntry.Product2Id, pricebookEntry);
        
        insert new List<SObject> {
            thirdQuote,
            quoteProduct
        };

        QuoteLineItemService.MediaSalesFlowInputs flowInputs = new QuoteLineItemService.MediaSalesFlowInputs();
        flowInputs.quoteLinesToClone = new List<QuoteLineItem> { quoteProduct };
        flowInputs.insertedQuotes = new List<Quote> { thirdQuote };

        Test.startTest();
            QuoteLineItemService.populateQuoteLineItemsToClone(new List<QuoteLineItemService.MediaSalesFlowInputs> {flowInputs});
        Test.stopTest();

        List<QuoteLineItem> actualResult = [SELECT Id FROM QuoteLineItem WHERE QuoteId =:thirdQuote.Id];
        Assert.areEqual(0, actualResult.size());
    }
}