public with sharing class LeadEntryEventService {
    /*
     * Este método é chamado no LeadEntryTriggerHandler para processar os eventos recebidos, transformar os LeadEntries em Leads, e enfileirá-los para inserí-los na queueable.
     */
    public static String queuesLeadsToBeCreated(List<LeadEntryEvent__e> newLee) {
        System.debug('Queues Leads To Be Created');

        Set<Id> leadEntryIds = new Set<Id>();
        for (LeadEntryEvent__e event : newLee) {
            if (event.LeadEntryId__c != null) {
                leadEntryIds.add((Id)event.LeadEntryId__c);
            }
        }

        if (!leadEntryIds.isEmpty()) {
            List<LeadEntry__c> entries = [
                SELECT Id, Name, Email__c, Phone__c, PartnerAccount__c
                FROM LeadEntry__c
                WHERE Id IN :leadEntryIds
            ];
            
            Id ownerId = LeadEntryService.getDefaultOwnerId('Lead');

            List<Lead> leadsToInsert = new List<Lead>();
            for (LeadEntry__c entry : entries) {
                leadsToInsert.add(new Lead(
                    LastName = entry.Name,
                    Email = entry.Email__c,
                    Phone = entry.Phone__c,                    
                    CustomerAccountId__c = entry.PartnerAccount__c,
                    LeadSource = 'Aceleraí Performance',
                    OwnerId = ownerId,
                    DoNotSendSGC__c = true
                ));
            }

            if (!leadsToInsert.isEmpty()) {
                System.enqueueJob(new LeadEntryQueueable(leadsToInsert, entries, new List<LeadEntry__c>(), new List<LeadEntry__c>()));
                System.debug('Queued Leads To Be Created Success');
                
                return 'Leads Enfileirados';
            }
        }
        return 'Falha em enfileirar, não há leads';
    }
}