@isTest
public with sharing class LeadEntryEventServiceTest {

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
    static void testSuccessScenario() {
        LeadEntry__c entry = [SELECT Id FROM LeadEntry__c LIMIT 1];
        
        List<LeadEntryEvent__e> events = new List<LeadEntryEvent__e>();
        events.add(new LeadEntryEvent__e(
            LeadEntryId__c = entry.Id 
        ));

        Test.startTest();
        String result = LeadEntryEventService.queuesLeadsToBeCreated(events);
        Test.stopTest();

        System.assertEquals('Leads Enfileirados', result, 'Deveria retornar sucesso');
    }
    
    @isTest
    static void testFailureScenario() {
        List<LeadEntryEvent__e> events = new List<LeadEntryEvent__e>();
        events.add(new LeadEntryEvent__e(
            Name__c = 'Evento vazio'
        ));

        Test.startTest();
        String result = LeadEntryEventService.queuesLeadsToBeCreated(events);
        Test.stopTest();

        System.assertEquals('Falha em enfileirar, não há leads', result, 'Deveria retornar falha');
    }
}