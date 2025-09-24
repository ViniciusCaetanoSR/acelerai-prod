@isTest
public with sharing class LeadEntryServiceTest {
   
    @isTest
    static void testProcessLeads(){
        List<Map<String, String>> leadsData = new List<Map<String, String>>();
        String timestamp = String.valueOf(Datetime.now().getTime());
        
        for(Integer i = 0; i < 5; i++){
            Map<String, String> rowLeads = new Map<String,String>();
            rowLeads.put('Name', 'iHU' + i);
            rowLeads.put('Email', 'iHU' + i + timestamp + '@performance.br');
            rowLeads.put('Phone', '5198161794' + i);

            leadsData.add(rowLeads);
        }

        Test.startTest();
        List<LeadEntry__c> result = LeadEntryService.processLeads(leadsData);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'Não processou os 5 LeadEntry__c');

        for (LeadEntry__c entry : result) {
            System.debug('entry: ' + entry);
            System.assertNotEquals(null, entry.Name, 'O nome está nulo');
            System.assertNotEquals(null, entry.Email__c, 'O email está nulo');
            System.assertNotEquals(null, entry.Phone__c, 'O telefone está nulo');
        }

        List<LeadEntry__c> inserted = [SELECT Id, Name, Email__c FROM LeadEntry__c];
        System.assertEquals(5, inserted.size(), 'Não inseriu 5 registros');        
    }

    @isTest
    static void testProcessLeadsWithEmptyList() {
        List<Map<String, String>> emptyLeadsData = new List<Map<String, String>>();
        
        Test.startTest();
        List<LeadEntry__c> result = LeadEntryService.processLeads(emptyLeadsData);
        Test.stopTest();
        
        System.debug('result: ' + result);
        System.assertEquals(0, result.size(), 'Não retornou uma lista vazia como deveria');
    }

    @isTest
    static void testImportLeads(){
      List<LeadEntry__c> leadsToImport = new List<LeadEntry__c>();

        for(Integer i = 0; i < 2; i++){
            LeadEntry__c leadEntry = new LeadEntry__c (
                Name = 'Lead' + i,
                Email__c = 'lead' + i + '@performance.br.58',
                Phone__c = '5198161794' + i
            );

            leadsToImport.add(leadEntry);
        }

        Test.startTest();
        LeadEntryService.importLeads(leadsToImport);
        Test.stopTest();

        List<LeadEntry__c> insertedLeadEntries = [SELECT Id, Email__c FROM LeadEntry__c WHERE Email__c LIKE '%@performance.br.58'];
        System.debug('leadsToImport: ' + leadsToImport);
        System.debug('insertedLeadEntries: ' + insertedLeadEntries);
        System.assertEquals(2, insertedLeadEntries.size(), 'não inseriu 2 lead entry');        
    }
   
    @IsTest
    private static void testpublishEventsFromEntries_Success() {
        LeadEntryService service = new LeadEntryService();
        
        List<LeadEntry__c> testEntries = new List<LeadEntry__c>{
            new LeadEntry__c(Email__c = 'jihyo@twice.com', Name = 'Jihyo', Phone__c = '1234567890'),
            new LeadEntry__c(Email__c = 'dahyun@twice.com', Name = 'Dahyun', Phone__c = '0987654321')
        };
        insert testEntries;
        
        Test.startTest();
        String result = service.publishEventsFromEntries(testEntries);
        Test.stopTest();
        
        List<LeadEntry__c> updatedEntries = [SELECT Id, PartnerAccount__c FROM LeadEntry__c WHERE Id IN :testEntries];
        
        System.assertEquals(2, updatedEntries.size(), 'Deveria ter processado 2 registros');    
        System.assertEquals('eventos publicados', result, 'não retornou a mensagem de "eventos publicados"');    
    }
    
    @isTest
    static void testpublishEventsFromEntriesWithEmptyList() {
        List<LeadEntry__c> emptyLeadsData = new List<LeadEntry__c>();
        
        LeadEntryService service = new LeadEntryService();

        Test.startTest();
        service.publishEventsFromEntries(emptyLeadsData);
        Test.stopTest();
        
        List<Lead> insertedLeads = [SELECT Id, Email FROM Lead];
        System.assertEquals(0, insertedLeads.size(), 'Não retornou uma lista vazia como deveria'); 
    }

    @isTest
    static void processDuplicateLeadEntriesTest_Success(){
        List<LeadEntry__c> testEntries = new List<LeadEntry__c>{
            new LeadEntry__c(Email__c = 'jihyo@twice.com', Name = 'Jihyo', Phone__c = '1234567890'),
            new LeadEntry__c(Email__c = 'dahyun@twice.com', Name = 'Dahyun', Phone__c = '0987654321')
        };
        insert testEntries;
        
        List<LeadEntry__c> duplicatedLEs = new List<LeadEntry__c>{
            new LeadEntry__c(Email__c = 'jihyo@twice.com', Name = 'Jihyo', Phone__c = '1234567890'),
            new LeadEntry__c(Email__c = 'dahyun@twice.com', Name = 'Dahyun', Phone__c = '0987654321')
        };
        insert duplicatedLEs;

        Test.startTest();
        List<LeadEntry__c> result = LeadEntryService.processDuplicateLeadEntries(duplicatedLEs);
        Test.stopTest();

        System.assertEquals(2, result.size());
    }
}