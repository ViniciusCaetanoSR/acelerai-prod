public with sharing class OpportunityLineItemSelector {
    
    public static List<OpportunityLineItem> selectByOpportunityId (Set<Id> opportunityIds) {
        return [
            SELECT 
                OpportunityId, 
                UnitPrice, 
                Product2Id, 
                Quantity, 
                PricebookEntryId 
            FROM OpportunityLineItem WHERE OpportunityId =: opportunityIds
        ];
    }
}