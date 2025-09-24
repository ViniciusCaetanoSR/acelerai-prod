@isTest
public class MockLeadRepository implements LeadRepository.ILeadRepository {

    public List<Lead> findByEmails(Set<String> emails) {
        System.debug('MockLeadRepository.findByEmails called');
        return new List<Lead>();
    }

    public void deleteLeads(List<Lead> leads) {
        System.debug('MockLeadRepository.deleteLeads called');
    }

    public void updateLeads(List<Lead> leads) {
        System.debug('MockLeadRepository.updateLeads called');
    }

    public RecordType findRecordTypeByDeveloperName(String developerName) {
        System.debug('MockLeadRepository.findRecordTypeByDeveloperName called');
        return null;
    }
}