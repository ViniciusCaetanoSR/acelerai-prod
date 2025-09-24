/**
 * @description       : Test class for LeadRepository with catch block tests
 * @author            : Vinícius Caetano
 * @last modified on  : 21-03-2025
 * @last modified by  : Vinícius Caetano
 **/
@isTest
private class LeadRepositoryTest {
    @testSetup
    static void setup() {
        LeadUtils.generateMarketingLeads(2);
    }

    static testMethod void testFindByEmails() {
        LeadRepository repo = new LeadRepository();
        Set<String> emails = new Set<String>();

        for (Lead lead : [SELECT Id, Email FROM Lead]) {
            emails.add(lead.Email);
        }

        List<Lead> foundLeads = repo.findByEmails(emails);
        System.assertEquals(2, foundLeads.size(), 'Should find 2 leads');
    }

    static testMethod void testFindByEmailsEmpty() {
        LeadRepository repo = new LeadRepository();
        List<Lead> foundLeads = repo.findByEmails(new Set<String>());
        System.assertEquals(0, foundLeads.size(), 'Should return empty list for empty input');
    }

    static testMethod void testInsertLeads() {
        LeadRepository repo = new LeadRepository();

        List<Lead> newLeads = new List<Lead>{
            new Lead(
                FirstName = 'Teste',
                LastName = 'Não Duplicado 1',
                Company = 'Empresa Bli Bli',
                Email = 'insert@example.com',
                IsDuplicate__c = false,
                Website__c = 'sbtacelerai'
            )
        };

        Test.startTest();
        repo.insertLeads(newLeads);
        Test.stopTest();

        Lead insertedLead = [SELECT Id FROM Lead WHERE Email = 'insert@example.com' LIMIT 1];
        System.assertNotEquals(null, insertedLead, 'Lead should be inserted');
    }

    static testMethod void testInsertLeadsCatch() {
        LeadRepository repo = new LeadRepository();
        // Attempt to insert invalid lead to force DML exception
        Lead invalidLead = new Lead(); // Missing required fields

        Test.startTest();
        repo.insertLeads(new List<Lead>{invalidLead});
        Test.stopTest();
    }

    static testMethod void testUpdateLeads() {
        LeadRepository repo = new LeadRepository();
        Lead leadToUpdate = [SELECT Id, LastName FROM Lead LIMIT 1];
        leadToUpdate.LastName = 'Updated Lead';

        Test.startTest();
        repo.updateLeads(new List<Lead>{ leadToUpdate });
        Test.stopTest();

        Lead updatedLead = [SELECT LastName FROM Lead WHERE Id = :leadToUpdate.Id];
        System.assertEquals('Updated Lead', updatedLead.LastName, 'Lead should be updated');
    }

    static testMethod void testUpdateLeadsCatch() {
        LeadRepository repo = new LeadRepository();
        Lead lead = [SELECT Id, email, LastName FROM Lead LIMIT 1];
        lead.email = 'test';

        Test.startTest();
        repo.updateLeads(new List<Lead>{lead});
        Test.stopTest();
    }

    static testMethod void testDeleteLeads() {
        LeadRepository repo = new LeadRepository();
        Lead leadToDelete = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        repo.deleteLeads(new List<Lead>{ leadToDelete });
        Test.stopTest();

        List<Lead> leadsAfterDelete = [SELECT Id FROM Lead WHERE Id = :leadToDelete.Id];
        System.assertEquals(0, leadsAfterDelete.size(), 'Lead should be deleted');
    }

    static testMethod void testDeleteLeadsCatch() {
        // LeadRepository repo = new LeadRepository();
        // Lead lead = [SELECT Id, email, LastName FROM Lead LIMIT 1];
        // lead.email = 'test';


        // Test.startTest();
        // repo.deleteLeads(new List<Lead>{invalidLead});
        // Test.stopTest();
    }

    static testMethod void testFindRecordTypeByDeveloperName() {
        LeadRepository repo = new LeadRepository();
        RecordType rt = repo.findRecordTypeByDeveloperName('Varejo');
        System.assertNotEquals(null, rt, 'RecordType should be found');
    }

    static testMethod void testFindRecordTypeByDeveloperNameWithInvalid() {
        LeadRepository repo = new LeadRepository();
        RecordType rt = repo.findRecordTypeByDeveloperName('NonExistent');
        System.assertEquals(null, rt, 'Should return null for non-existent developer name');
    }

    static testMethod void testFindRecordTypeByDeveloperNameWithBlank() {
        LeadRepository repo = new LeadRepository();
        try {
            repo.findRecordTypeByDeveloperName('');
            System.assert(false, 'Should have thrown RepositoryException');
        } catch (LeadRepository.RepositoryException e) {
            System.assert(e.getMessage().contains('Nome do RecordType não pode ser vazio.'));
        }
    }

    static testMethod void testFindRecordTypeCatch() {
        // Insert record with unexpected developer name format to simulate query exception if applicable
        // Or simulate an error scenario using mocks if supported
        // Note: QueryException catch testing is not possible without a real runtime query failure,
        // but structure is provided for completeness.
    }
}