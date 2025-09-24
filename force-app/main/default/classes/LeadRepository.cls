/**
 * @description       :
 * @author            : Vinícius Caetano
 * @group             :
 * @last modified on  : 23-05-2025
 * @last modified by  : Vinícius Caetano
 **/
public without sharing class LeadRepository implements LeadRepository.ILeadRepository {
    public interface ILeadRepository {
        List<Lead> findByEmails(Set<String> emails);
        void deleteLeads(List<Lead> leads);
        void updateLeads(List<Lead> leads);
        RecordType findRecordTypeByDeveloperName(String developerName);
    }

    public LeadRepository() {
    }

    public List<Lead> findByEmails(Set<String> emails) {
        System.debug('chamou a LeadRepository, findByEmails, emails:' + emails);

        if (emails == null || emails.isEmpty()) {
            System.debug('chamou a LeadRepository, emails == null');
            return new List<Lead>();
        }

        System.debug('chamou a LeadRepository, findByEmails, return:' + new List<Lead>([
            SELECT
                Id,
                Email__c,
                Status,
                referencia_base_antiga_lead__c,
                Segmento__c,
                Phone,
                RecordTypeId,
                PartnerAccountId,
                EntryAttempts__c,
                UTM_Campaign__c,
                UTM_Content__c,
                UTM_Medium__c,
                UTM_Source__c,
                UTM_Term__c,
                Fbclid__c,
                Metalead_id__c,
                Gclid__c,
                LeadSource,
                Website__c
            FROM Lead
            WHERE Email__c IN :emails AND RecordType.Name != 'Mentoria'
        ]));

        return [
            SELECT
                Id,
                Email__c,
                Status,
                referencia_base_antiga_lead__c,
                Segmento__c,
                Phone,
                RecordTypeId,
                PartnerAccountId,
                EntryAttempts__c,
                UTM_Campaign__c,
                UTM_Content__c,
                UTM_Medium__c,
                UTM_Source__c,
                UTM_Term__c,
                Fbclid__c,
                Metalead_id__c,
                Gclid__c,
                LeadSource,
                Website__c
            FROM Lead
            WHERE Email__c IN :emails AND RecordType.Name != 'Mentoria'
        ];
    }

    public void insertLeads(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return;
        }

        try {
            insert leads;
        } catch (DmlException e) {
            LoggerUtility.createLogException(e, null, 'LeadRepository.insertLeads');
        }
    }

    public void updateLeads(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return;
        }

        try {
            update leads;
        } catch (DmlException e) {
            LoggerUtility.createLogException(e, null, 'LeadRepository.updateLeads');
        }
    }

    public void deleteLeads(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return;
        }

        try {
            delete leads;
        } catch (DmlException e) {
            LoggerUtility.createLogException(e, null, 'LeadRepository.deleteLeads');
        }
    }

    public RecordType findRecordTypeByDeveloperName(String developerName) {
        if (String.isBlank(developerName)) {
            throw new RepositoryException('Nome do RecordType não pode ser vazio.');
        }

        try {
            List<RecordType> recordTypes = [
                SELECT Id
                FROM RecordType
                WHERE DeveloperName = :developerName AND SObjectType = 'Lead'
                LIMIT 1
            ];
            return recordTypes.isEmpty() ? null : recordTypes[0];
        } catch (QueryException e) {
            LoggerUtility.createLogException(e, null, 'LeadRepository.findRecordTypeByDeveloperName');
            throw new RepositoryException('Erro ao buscar RecordType: ' + e.getMessage());
        }
    }

    public class RepositoryException extends Exception {
    }
}