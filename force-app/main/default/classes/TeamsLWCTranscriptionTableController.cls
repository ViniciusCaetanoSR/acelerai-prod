public without sharing class TeamsLWCTranscriptionTableController {

    @AuraEnabled(cacheable=true)
    public static List<TeamsTranscriptionHistory__c> getHistoryTranscriptionByEvent(Id eventId) {
        if (eventId == null) {
            return new List<TeamsTranscriptionHistory__c>();
        }

        String pattern = '%' + String.valueOf(eventId) + '%';

        List<TeamsTranscriptionHistory__c> histories = [
            SELECT Id, Name, CreatedDate, OwnerId, Owner.Name, TeamsTranscriptContent__c, RelatedEvent__c
            FROM TeamsTranscriptionHistory__c
            WHERE RelatedEvent__c LIKE :pattern
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
        System.debug('Históricos de transcrição entrados:' + histories.size());
        return histories;
    }
}