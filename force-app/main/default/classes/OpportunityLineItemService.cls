public with sharing class OpportunityLineItemService {

    private static List<String> stagesToIgnore = new List<String> {
        'Ganho Pagamento Futuro',
        'Ganho',
        'Closed Won',
        'Venda Futura',
        'Negociação Fechada'
    };

    public static OpportunityLineItem createOpportunityLineItem(Opportunity relatedOpportuniy, PricebookEntry relatedPricebookEntry, QuoteLineItem quoteLineItem) {
        return new OpportunityLineItem(
            OpportunityId = relatedOpportuniy != null ? relatedOpportuniy.Id : quoteLineItem.Quote.OpportunityId, 
            Product2Id = relatedPricebookEntry != null ? relatedPricebookEntry.Product2Id : quoteLineItem.Product2Id, 
            PricebookEntryId = relatedPricebookEntry != null ? relatedPricebookEntry.Id : quoteLineItem.PricebookEntryId,
            Quantity = quoteLineItem == null ? 1 : quoteLineItem.Quantity,
            UnitPrice = relatedPricebookEntry != null ? relatedPricebookEntry.UnitPrice : quoteLineItem.UnitPrice
        );
    }

    public static OpportunityLineItem createOpportunityLineItem (Opportunity relatedOpportuniy, PricebookEntry relatedPricebookEntry) {
        return createOpportunityLineItem(relatedOpportuniy, relatedPricebookEntry, null);
    }

    public static OpportunityLineItem createOpportunityLineItem (QuoteLineItem quoteLineItem) {
        return createOpportunityLineItem(null, null, quoteLineItem);
    }

    public static void insertOrUpdateOpportunityLineItemsFromQuote (List<OpportunityLineItem> opportunityProducts, List<QuoteLineItem> quoteProducts, Set<Id> opportunityIds) {
            
        Map<String, OpportunityLineItem> opportunityProductsToInsert = new Map<String, OpportunityLineItem> ();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<OpportunityLineItem> opportunityProductsToUpdate = new List<OpportunityLineItem>();
        List<String> relatedRecordIdsList = new List<String>();
        
        try{
            Map<String, List<QuoteLineItem>> quoteLineItemMap = populateQuoteLineItemMapWithProductIdAndUnitPriceKey(quoteProducts);
            Map<String, OpportunityLineItem> oppLineItemMap = populateOppLineItemMapWithProductIdAndUnitPriceKey(opportunityProducts);
            
            for (String quoteLineItemKey : quoteLineItemMap.keySet()) {
                OpportunityLineItem opportunityWithKey = oppLineItemMap.get(quoteLineItemKey);
                List<QuoteLineItem> quotesWithKey = quoteLineItemMap.get(quoteLineItemKey);

                if (opportunityWithKey == null && !opportunityProductsToInsert.containsKey(quoteLineItemKey)) {
                    opportunityProductsToInsert.put(quoteLineItemKey, createOpportunityLineItem(quotesWithKey.get(0)));
                    
                    if (quotesWithKey.size() > 1) {

                        for (Integer i = 1; i < quotesWithKey.size(); i++) {
                            System.debug('>> quoteLineItemKey' + quoteLineItemKey);
                            System.debug('>> Quantity Before: ' + opportunityProductsToInsert.get(quoteLineItemKey).Quantity);
                            opportunityProductsToInsert.get(quoteLineItemKey).Quantity += quotesWithKey.get(i).Quantity;
                            System.debug('>> Quantity After: ' + opportunityProductsToInsert.get(quoteLineItemKey).Quantity);
                        }
                    }
                } 
                // else {
                //     for (QuoteLineItem quotelineitem : quotesWithKey) {
                //         opportunityWithKey.Quantity += quotelineitem.Quantity;
                //         if (!opportunityProductsToUpdate.contains(opportunityWithKey))
                //             opportunityProductsToUpdate.add(opportunityWithKey);
                //     }
                // }
            }

            if (!opportunityProductsToInsert.values().isEmpty()) {
                insert opportunityProductsToInsert.values();
            }

            if (!opportunityProductsToUpdate.isEmpty()) {
                update opportunityProductsToUpdate;
            }

            List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE Id IN: opportunityIds];


            for (Opportunity currentOpportunity : opportunities) {

                if (stagesToIgnore.contains(currentOpportunity.StageName)) {
                    continue;
                }
                
                currentOpportunity.StageName = 'Em Negociação';
                opportunitiesToUpdate.add(currentOpportunity);
            }

            if (!opportunitiesToUpdate.isEmpty()) {
                update opportunitiesToUpdate;
            }
        } catch (Exception e) {

            for (Opportunity opportunity : opportunitiesToUpdate) {
                relatedRecordIdsList.add(opportunity.Id);
            }

            String relatedRecordIdConcat = String.join(relatedRecordIdsList, ',');
            LoggerUtility.createLogException(e, relatedRecordIdConcat, 'insertOrUpdateOpportunityLineItemsFromQuote');
        }
    }

    private static Map<String, List<QuoteLineItem>> populateQuoteLineItemMapWithProductIdAndUnitPriceKey (List<QuoteLineItem> quoteProducts) {
        Map<String, List<QuoteLineItem>> quoteLineItemMap = new Map<String, List<QuoteLineItem>>();

        for (QuoteLineItem quoteLine : quoteProducts) {
            if (!quoteLineItemMap.containsKey(quoteLine.Product2Id + ' - ' + String.valueOf(quoteLine.UnitPrice)))
                quoteLineItemMap.put(quoteLine.Product2Id + ' - ' + String.valueOf(quoteLine.UnitPrice), new List<QuoteLineItem>());
                
            quoteLineItemMap.get(quoteLine.Product2Id + ' - ' + String.valueOf(quoteLine.UnitPrice)).add(quoteLine);
        }

        return quoteLineItemMap;
    }

    private static Map<String, OpportunityLineItem> populateOppLineItemMapWithProductIdAndUnitPriceKey (List<OpportunityLineItem> opportunityProducts) {
        Map<String, OpportunityLineItem> oppLineItemMap = new Map<String, OpportunityLineItem> ();
        
        for (OpportunityLineItem oppLineItem : opportunityProducts) {
            if (!oppLineItemMap.containsKey(oppLineItem.Product2Id + ' - ' + String.valueOf(oppLineItem.UnitPrice))) 
                oppLineItemMap.put(oppLineItem.Product2Id + ' - ' + String.valueOf(oppLineItem.UnitPrice), oppLineItem);
        }

        return oppLineItemMap;
    }
}