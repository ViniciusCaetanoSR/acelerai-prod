@IsTest
public class QuoteLineItemTriggerHandlerTest {
    @TestSetup
    static void setupTestData() {
        Account account = VirtualTestData.createAccount('Account Test');
        insert account;

        Opportunity opportunity = VirtualTestData.createOpportunity(
            'Opportunity Test',
            account.Id,
            '+5551981752134',
            'Agronegócio',
            'Agência',
            Date.today(),
            'Qualificação'
        );
        insert opportunity;

        Quote quote = VirtualTestData.createQuote('Quote Test', opportunity.Id);
        quote.Pricebook2Id = Test.getStandardPricebookId();

        Product2 product = VirtualTestData.createProduct('Product Test', 'Mídia');
        insert product;

        PricebookEntry pricebookEntry = VirtualTestData.createPriceBookEntry(product.Id, Test.getStandardPricebookId(), 1000);

        insert new List<SObject>{ quote, pricebookEntry };

        QuoteLineItem initialQuoteLineItem = new QuoteLineItem(QuoteId = quote.Id, PricebookEntryId = pricebookEntry.Id, Quantity = 1, UnitPrice = 100);
        System.debug('>>setupTestData');
        insert initialQuoteLineItem;
    }

    @IsTest
    static void testAfterInsert() {
        Quote quote = [SELECT Id, ValorTotalMidia__c FROM Quote LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];

        QuoteLineItem newQuoteLineItem = new QuoteLineItem(QuoteId = quote.Id, PricebookEntryId = pricebookEntry.Id, Quantity = 2, UnitPrice = 100);

        Test.startTest();
        System.debug('>>testAfterInsert');
        insert newQuoteLineItem;
        Test.stopTest();

        Quote updatedQuote = [SELECT ValorTotalMidia__c FROM Quote WHERE Id = :quote.Id];
        System.assertEquals(300, updatedQuote.ValorTotalMidia__c, 'O valor total de mídia na cotação deve ser 300 após inserção.');
    }

    @IsTest
    static void testAfterUpdate() {
        Quote quote = [SELECT Id, ValorTotalMidia__c FROM Quote LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        QuoteLineItem newQuoteLineItem = new QuoteLineItem(QuoteId = quote.Id, PricebookEntryId = pricebookEntry.Id, Quantity = 2, UnitPrice = 100);

        Test.startTest();

        insert newQuoteLineItem;

        QuoteLineItem existingQuoteLineItem = [SELECT Id, Quantity, UnitPrice FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Quantity = 1 LIMIT 1];

        existingQuoteLineItem.Quantity = 2;

        System.debug('>>testAfterUpdate');
        update existingQuoteLineItem;
        Test.stopTest();

        Quote updatedQuote = [SELECT ValorTotalMidia__c FROM Quote WHERE Id = :quote.Id];
        System.assertEquals(400, updatedQuote.ValorTotalMidia__c, 'O valor total de mídia na cotação deve ser atualizado corretamente após a alteração.');
    }

    @IsTest
    static void testAfterDelete() {
        Quote quote = [SELECT Id, ValorTotalMidia__c FROM Quote LIMIT 1];

        PricebookEntry pricebookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        QuoteLineItem newQuoteLineItem = new QuoteLineItem(QuoteId = quote.Id, PricebookEntryId = pricebookEntry.Id, Quantity = 2, UnitPrice = 100);

        Test.startTest();

        insert newQuoteLineItem;
        QuoteLineItem existingQuoteLineItem = [SELECT Id, Quantity, UnitPrice FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Quantity = 1 LIMIT 1];

        delete existingQuoteLineItem;
        Test.stopTest();

        Quote updatedQuote = [SELECT ValorTotalMidia__c FROM Quote WHERE Id = :quote.Id];
        System.assertEquals(200, updatedQuote.ValorTotalMidia__c, 'O valor total de mídia na cotação deve ser atualizado corretamente após a alteração.');
    }
}