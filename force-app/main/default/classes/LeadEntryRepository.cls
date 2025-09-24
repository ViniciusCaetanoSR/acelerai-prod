/**
 * @author            : Bárbara
 * @last modified on  : 29-07-2025
 **/

public without sharing class LeadEntryRepository implements LeadEntryRepository.ILeadEntryRepository {
    public interface ILeadEntryRepository{
        List<LeadEntry__c> findLeadEntryByEmail(Set<String> emails);
    }
    
    public LeadEntryRepository() {
    }

    public List<LeadEntry__c> findLeadEntryByEmail(Set<String> emails) {
        if (emails == null || emails.isEmpty()) {
            return new List<LeadEntry__c>();
        }

        return [
            SELECT
                Id, Email__c,CreatedById,CreatedDate,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,PartnerAccount__c                
            FROM LeadEntry__c
            WHERE Email__c IN :emails
        ];
    }
}