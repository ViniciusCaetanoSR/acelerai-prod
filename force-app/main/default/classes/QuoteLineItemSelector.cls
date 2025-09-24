public with sharing class QuoteLineItemSelector {
    
    public static List<QuoteLineItem> selectByQuoteId (Set<Id> quoteIds) {
        return [
            SELECT 
                Product2Id, 
                ProductType__c, 
                UnitPrice, 
                Meses__c, 
                Cidade__c, 
                Estado__c, 
                Quantity, 
                Segmento__c, 
                Subsegmento__c, 
                Quote.OpportunityId,
                PricebookEntryId
            FROM QuoteLineItem WHERE QuoteId IN: quoteIds
        ];
    }

    public static List<QuoteLineItem> selectByOpportunityIdAndSynchronizedOrFuturePayment (Set<Id> opportunityIds, Boolean synchronizedQuote, Boolean futurePayment) {
        return [
            SELECT 
                Product2Id, 
                ProductType__c, 
                UnitPrice, 
                Meses__c, 
                Cidade__c, 
                Estado__c, 
                Quantity, 
                Segmento__c, 
                Subsegmento__c, 
                Quote.OpportunityId,
                PricebookEntryId,
                Quote.Sincronizado__c,
                Quote.PagamentoFuturo__c
            FROM QuoteLineItem WHERE Quote.OpportunityId IN:opportunityIds AND (Quote.Sincronizado__c =:synchronizedQuote OR Quote.PagamentoFuturo__c =:futurePayment)
        ];
    }
}