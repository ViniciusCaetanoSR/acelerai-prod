public with sharing class LeadEntryExporterController {
    @AuraEnabled(cacheable=true)
    public static List<LeadEntry__c> getMyLeadEntries() {
        return [
            SELECT Id, Name, Email__c, Phone__c, Status__c, Owner.Alias
            FROM LeadEntry__c
            WHERE OwnerId = :UserInfo.getUserId()
        ];
    }
}