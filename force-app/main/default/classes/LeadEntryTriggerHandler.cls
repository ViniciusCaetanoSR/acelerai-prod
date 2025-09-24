/**
 * @description       : Handler class for LeadEntry__c trigger to manage lead creation and updates.
 * @author            : Vinícius Caetano
 * @last modified on  : 20-05-2025
 * @last modified by  : Vinícius Caetano
 **/
public with sharing class LeadEntryTriggerHandler {
    private static final LeadEntryService leadEntryService = new LeadEntryService();

    public static String onBeforeInsert(List<LeadEntry__c> newRecords) {
        if(!newRecords.isEmpty()){
            return 'chamou LeadEntryTriggerHandler.onBeforeInsert';
        }
        return '';
    }

    public static String onBeforeUpdate(List<LeadEntry__c> newRecords, Map<Id, LeadEntry__c> oldMap) {
        if(!newRecords.isEmpty() || !oldMap.isEmpty()){

            return 'chamou LeadEntryTriggerHandler.onBeforeUpdate';
        }
        return '';    
    }

    public static String onAfterInsert(List<LeadEntry__c> newRecords, List<LeadEntry__c> oldRecords) {
        if(!newRecords.isEmpty()){
            leadEntryService.publishEventsFromEntries(newRecords);
            //leadEntryService.processDuplicateLeadEntries(newRecords, oldRecords);

            return 'chamou LeadEntryTriggerHandler.AfterInsert';
        }
        return '';
    }

    public static String onAfterUpdate(List<LeadEntry__c> newRecords, Map<Id, LeadEntry__c> oldMap) {
        if(!newRecords.isEmpty() || !oldMap.isEmpty()){

            return 'chamou LeadEntryTriggerHandler.onAfterUpdate';
        }
        return '';            
    }
}