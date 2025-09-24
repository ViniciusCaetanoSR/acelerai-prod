@isTest
public with sharing class LeadEntryEventTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        Account partnerAccount = new Account(Name='Test Partner',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1'
        );
        insert partnerAccount;
        
        LeadEntry__c entry = new LeadEntry__c(
            Name='João Entry',
            Email__c='joao1@joaoperformance.com',
            Phone__c='51981617948',
            PartnerAccount__c=partnerAccount.Id
        );
        insert entry;
    }   
    
    @isTest
    static void testOnAfterInsert() {
        LeadEntry__c entry = [SELECT Id FROM LeadEntry__c LIMIT 1];
        
        List<LeadEntryEvent__e> events = new List<LeadEntryEvent__e>();
        events.add(new LeadEntryEvent__e(
            LeadEntryId__c = entry.Id
        ));

        Test.startTest();
        LeadEntryEventTriggerHandler.onAfterInsert(events);
        Test.stopTest();
        
        Integer queueableJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assert(queueableJobs > 0, 'Deveria ter enfileirado um job');
    }

    @isTest
    static void testOnAfterInsert_MultipleEvents() {
        LeadEntry__c entry = [SELECT Id FROM LeadEntry__c LIMIT 1];
        
        List<LeadEntryEvent__e> events = new List<LeadEntryEvent__e>{
            new LeadEntryEvent__e(LeadEntryId__c = entry.Id),
            new LeadEntryEvent__e(), 
            new LeadEntryEvent__e(LeadEntryId__c = entry.Id)
        };

        Test.startTest();
        LeadEntryEventTriggerHandler.onAfterInsert(events);
        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id 
            FROM AsyncApexJob 
            WHERE JobType = 'Queueable'
        ];
        
        System.assertEquals(1, jobs.size(), 'Deveria enfileirar 1 job para múltiplos eventos válidos');
    }
}