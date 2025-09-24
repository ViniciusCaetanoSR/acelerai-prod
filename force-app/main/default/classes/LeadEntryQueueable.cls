/*
* Esta classe é chamada na LeadEntryEventTriggerHandler para inserir os leads a partir dos entry
*/

public without sharing class LeadEntryQueueable implements Queueable {
    @TestVisible private List<Lead> leadsToInsert;
    @TestVisible private List<LeadEntry__c> entriesInOrder;
    @TestVisible private List<LeadEntry__c> entriesToDelete;
    @TestVisible private List<LeadEntry__c> oldEntriesToUpdate;
   

    public LeadEntryQueueable(List<Lead> leadsToInsert, List<LeadEntry__c> entriesInOrder, List<LeadEntry__c> entriesToDelete, List<LeadEntry__c> oldEntriesToUpdate) {
        this.leadsToInsert = leadsToInsert;
        this.entriesInOrder = entriesInOrder;
        this.entriesToDelete = entriesToDelete;
        this.oldEntriesToUpdate = oldEntriesToUpdate;
    }

    public void execute(QueueableContext context) {        
        System.debug('Chamou o LeadEntryQueueable.execute'); 

        List<LeadEntry__c> entriesToUpdate = new List<LeadEntry__c>();
        
        try {
            
            if (!entriesToDelete.isEmpty()) {
                deleteDuplicateLeadEntries();
                System.debug('Chamou o LeadEntryQueueable.deleteDuplicateLeadEntries');
            }

            if(!oldEntriesToUpdate.isEmpty()){
                updateOldLeadEntry_FromDuplicateLeadEntries(oldEntriesToUpdate);
                System.debug('Chamou o LeadEntryQueueable.updateOldLeadEntry_FromDuplicateLeadEntries');
            }

            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, leadsToInsert);
            Database.SaveResult[] results = Database.insert(decision.getRecords(), false);
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult sr = results[i];
                LeadEntry__c entry = entriesInOrder[i];

                if (sr.isSuccess()) {
                    entry.Lead__c = sr.getId();
                    entriesToUpdate.add(entry);
                } else {
                    LoggerUtility.createLog(
                        'Failed to create Lead for LeadEntry__c ID: ' + entry.Id + ': ' + sr.getErrors()[0].getMessage(),
                        'LeadEntryQueueable.execute'
                    );
                }
            }

            if (!entriesToUpdate.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(entriesToUpdate, false);
                for (Integer j = 0; j < updateResults.size(); j++) {
                    Database.SaveResult ur = updateResults[j];

                    if (!ur.isSuccess()) {
                        LoggerUtility.createLog(
                            'Failed to update LeadEntry__c ID: ' + entriesToUpdate[j].Id + ': ' + ur.getErrors()[0].getMessage(),
                            'LeadEntryQueueable.execute'
                        );
                    }
                }
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'LeadEntryQueueable.execute');
        }            
    }  
    
    public void deleteDuplicateLeadEntries(){
        if(!entriesToDelete.isEmpty()){
            try{
                delete entriesToDelete;
                System.debug('Deletou os Lead Entries duplicados');
            } catch (Exception e){
                System.debug('Exception na LeadEntryQueueable.deleteDuplicateLeadEntries: ' + e.getMessage());
                LoggerUtility.createLogException(e, null, 'LeadEntryQueueable.deleteDuplicateLeadEntries');
            }
        }
    }

    public void updateOldLeadEntry_FromDuplicateLeadEntries(List<LeadEntry__c> oldEntries){
        if(!oldEntries.isEmpty()){
            try{
                update oldEntries;
                System.debug('Atualizou os Lead Entries antigos com o data de duplicação de registro');
            } catch (Exception e){
                System.debug('Exception na LeadEntryQueueable.updateOldLeadEntry_FromDuplicateLeadEntries: ' + e.getMessage());
                LoggerUtility.createLogException(e, null, 'LeadEntryQueueable.updateOldLeadEntry_FromDuplicateLeadEntries');
            }
        }
    }
}