@isTest
public class MockLeadRepositoryTest {

    private static MockLeadRepository mockRepository;

    @isTest
    public static void testFindByEmails() {
        mockRepository = new MockLeadRepository();
        Set<String> emails = new Set<String>{'test@example.com', 'user@example.com'};
        List<Lead> leads = mockRepository.findByEmails(emails);

        System.assertEquals(0, leads.size(), 'A lista de leads deve estar vazia.');
    }

    @isTest
    public static void testDeleteLeads() {
        mockRepository = new MockLeadRepository();
        List<Lead> leads = new List<Lead>{ new Lead(Id = '00Q000000000001AAA') };

        Test.startTest();
        mockRepository.deleteLeads(leads);
        Test.stopTest();

        System.assert(true, 'O método deleteLeads foi chamado sem exceções.');
    }

    @isTest
    public static void testUpdateLeads() {
        mockRepository = new MockLeadRepository();
        List<Lead> leads = new List<Lead>{ new Lead(Id = '00Q000000000002AAA') };

        Test.startTest();
        mockRepository.updateLeads(leads);
        Test.stopTest();

        System.assert(true, 'O método updateLeads foi chamado sem exceções.');
    }

    @isTest
    public static void testFindRecordTypeByDeveloperName() {
        mockRepository = new MockLeadRepository();

        Test.startTest();
        RecordType recordType = mockRepository.findRecordTypeByDeveloperName('Midias');
        Test.stopTest();

        System.assertEquals(null, recordType, 'O RecordType deve ser nulo conforme o mock.');
    }
}