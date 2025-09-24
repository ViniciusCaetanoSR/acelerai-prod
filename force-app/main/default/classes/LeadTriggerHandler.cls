public with sharing class LeadTriggerHandler {
    private static final LeadService leadService = new LeadService();

    public static void onBeforeInsert(List<Lead> newLeads) {
        leadService.setMidiaRecordType(newLeads);
        leadService.processDuplicateLeads(newLeads);
        leadService.validateLeads(newLeads, null);
    }

    public static void onBeforeUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        leadService.validateLeads(newLeads, oldLeadsMap);
    }

    public static void onAfterInsert(List<Lead> newLeads) {
        leadService.queueDuplicateLeadRemoval(newLeads);
        leadService.processDuplicateLeadsAndOpportunities(newLeads);
    }

    public static void onAfterUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        leadService.leadMetaIntegration(newLeads, oldLeadsMap);
    }
}