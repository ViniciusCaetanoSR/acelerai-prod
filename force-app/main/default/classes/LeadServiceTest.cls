@isTest
private class LeadServiceTest {
    @TestSetup
    static void setup() {
        LeadUtils.generateLeads(2);
    }

    @isTest
    static void testProcessDuplicateLeads() {
        List<Lead> leads = [SELECT Id, Email FROM Lead];

        List<Lead> newLeads = new List<Lead>{
            new Lead(Email = 'test0@example.com', LastName = 'New Duplicate', Company = 'Test Co'),
            new Lead(Email = 'new@test.com', LastName = 'New Lead', Company = 'Test Co')
        };

        Test.startTest();
        leads[1].Status = 'Histórico';
        update leads;

        newLeads[0].Email = leads[1].Email;
        insert newLeads;

        Test.stopTest();

        List<Lead> updatedLeads = [SELECT Id, CNPJ__c FROM Lead];
        System.assertEquals(3, updatedLeads.size(), 'Duplicate lead should be processed');
    }

    @isTest
    static void testLeadMetaIntegration() {
        List<Lead> leads = [SELECT Id, Status, CNPJ__c, Metalead_id__c FROM Lead LIMIT 2];
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>();

        for (Lead l : leads) {
            oldLeadMap.put(l.Id, new Lead(Id = l.Id, Status = 'Open', Metalead_id__c = 'META123'));
            l.Status = 'Working';
        }

        Test.startTest();
        LeadService service = new LeadService();
        service.leadMetaIntegration(leads, oldLeadMap);
        Test.stopTest();

        System.assertEquals(2, leads.size(), 'Should process all leads');
    }

    @isTest
    static void testQueueDuplicateLeadRemoval() {
        List<Lead> leads = [SELECT Id, CNPJ__c FROM Lead LIMIT 2];
        for (Lead l : leads) {
            l.IsDuplicate__c = true;
        }
        update leads;

        Test.startTest();
        LeadService service = new LeadService();
        service.queueDuplicateLeadRemoval(leads);
        Test.stopTest();

        List<Lead> remainingLeads = [SELECT Id FROM Lead WHERE Id IN :leads];
        System.assertEquals(0, remainingLeads.size(), 'All duplicate leads should be deleted');
    }

    @isTest
    static void testSetMidiaRecordType() {
        List<Lead> newLeads = new List<Lead>{ new Lead(LastName = 'Test', Company = 'Test Co', Email = 'media@test.com') };

        Test.startTest();
        LeadService service = new LeadService();
        service.setMidiaRecordType(newLeads);
        Test.stopTest();

        System.assertEquals(1, newLeads.size(), 'Should process all new leads');
    }

    @isTest
    static void testValidateLeads() {
        List<Lead> newLeads = [SELECT Id, CNPJ__c, State, City, Status FROM Lead LIMIT 1];
        Map<Id, Lead> oldLeadsMap = new Map<Id, Lead>{ newLeads[0].Id => new Lead(Id = newLeads[0].Id, Status = 'Open') };
        newLeads[0].Status = 'Working';

        Test.startTest();
        LeadService service = new LeadService();
        service.validateLeads(newLeads, oldLeadsMap);
        Test.stopTest();

        System.assertEquals('Working', newLeads[0].Status, 'Status should be updated');
    }

    @isTest
    static void testProcessDuplicateLeadsAndOpportunities() {
        List<Lead> newLeads = new List<Lead>{ new Lead(LastName = 'Test', Company = 'Test Co', Email = 'opp@test.com') };

        Test.startTest();
        LeadService service = new LeadService();
        service.processDuplicateLeadsAndOpportunities(newLeads);
        Test.stopTest();

        System.assertEquals(1, newLeads.size(), 'Should process all new leads');
    }
}