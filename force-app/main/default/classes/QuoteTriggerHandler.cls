public with sharing class QuoteTriggerHandler {
    public static void onBeforeUpdate(Map<Id, Quote> newMap, Map<Id, Quote> oldMap) {
        QuoteService.syncQuoteWithOpportunity(newMap, oldMap);
        OpportunityService.sendOpportunityStatusToProposalOnQuoteWaitingApproval(newMap, oldMap);
        QuoteService.nullFieldCanceledQuote(newMap);
    }

    public static void onAfterUpdate(List<Quote> newItems, Map<Id, Quote> newMap, Map<Id, Quote> oldMap) {
        QuoteService.deleteRemovedLineItemsAndUpdateOpportunityProducts(newMap, oldMap);
        QuoteService.syncValorFinalMidia(newItems, oldMap);
    }

    public static void onBeforeInsert(List<Quote> newItems) {
    }
    public static void onAfterInsert(List<Quote> newItems) {
        QuoteService.syncValorFinalMidia(newItems, null);
    }
    public static void onAfterDelete(Map<Id, Quote> oldMap) {
        QuoteService.syncValorFinalMidia(null, oldMap);
    }
}