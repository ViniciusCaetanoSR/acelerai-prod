@isTest
private class LeadUtilsTest {
    @testSetup
    static void setup() {
    }

    @isTest
    static void testgenerateLeads() {

        Integer numberOfRecords = 5;

        Test.startTest();
        LeadUtils.generateLeads(numberOfRecords);
        Test.stopTest();

        List<Lead> leads = [SELECT Id, LastName, Email FROM Lead WHERE LastName LIKE '**Test**%'];
        System.assertEquals(numberOfRecords, leads.size(), 'Number of Leads created is incorrect');
    }

    @isTest
    static void testgenerateMarketingLeads() {

        Integer numberOfRecords = 3;

        Test.startTest();
        LeadUtils.generateMarketingLeads(numberOfRecords);
        Test.stopTest();

        List<Lead> leads = [SELECT Id, Funil__c, WebSite__c FROM Lead WHERE WebSite__c LIKE 'www.sbtacelerai.com.br/'];
        System.assertEquals(numberOfRecords, leads.size(), 'Number of Mkt Leads created is incorrect');      
    }

    @isTest
    static void testgenerateInactiveBaseLeads() {

        Integer numberOfRecords = 2;

        Test.startTest();
        LeadUtils.generateInactiveBaseLeads(numberOfRecords);
        Test.stopTest();


        List<Lead> leads = [SELECT Id, referencia_base_antiga_lead__c FROM Lead WHERE referencia_base_antiga_lead__c = 'Base Inativa'];
        System.assertEquals(numberOfRecords, leads.size(), 'Number of Base Inativa Leads created is incorrect');
    }

    @isTest
    static void testremoveTodayTestRecords() {

        Integer numberOfRecords = 5;
        LeadUtils.generateLeads(numberOfRecords);

        Test.startTest();
        LeadUtils.removeTodayTestRecords();
        Test.stopTest();

        List<Lead> leads = [SELECT Id FROM Lead WHERE LastName LIKE '<<Teste>>%'];
        System.assertEquals(0, leads.size(), 'All test Leads created today should be deleted');
    }

    @isTest
    static void testcreateRandomCNPJ() {
        String cnpj = LeadUtils.createRandomCNPJ();

        System.assertNotEquals(null, cnpj, 'CNPJ should not be null');
        System.assertEquals(14, cnpj.length(), 'CNPJ should have 14 characters');
    }

    @isTest
    static void testcreateRandomPhone() {

        String phone = LeadUtils.createRandomPhone();

        System.assertNotEquals(null, phone, 'Phone should not be null');
        System.assertEquals(8, phone.length(), 'Phone should have 8 digits');
    }

    @isTest
    private static void shouldAssignRecTypeMidias() {

        Lead lead = new Lead(
            LastName = 'Lead',
            Email = 'barbara.mata@srconsulting.io',
            Funil__c = 'Mídias Vendas'
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead updatedLead = [SELECT Id, RecordTypeId 
        FROM Lead 
        WHERE Id = :lead.Id];

        RecordType rtMidias = [SELECT Id FROM RecordType 
            WHERE DeveloperName = 'Midias' 
            AND SObjectType = 'Lead' 
            LIMIT 1];
            
        System.assertEquals(rtMidias.Id, updatedLead.RecordTypeId, 'O RecordTypeId não está igual');
    }
}