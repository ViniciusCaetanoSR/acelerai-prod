@isTest
public with sharing class LeadEntryQueueableTest {
    @TestSetup
    static void makeData(){        
        Lead lead = new Lead (
            LastName = 'LeadLuck',
            Email = 'lead@luck.com',
            Phone = '5551981617448'
        );
        insert lead;

        LeadEntry__c leadentry = new LeadEntry__c(
            Email__c = 'leadENTRY@luck.com',
            Phone__c = '5551981617448'
        );
        insert leadentry;
    }
    
    @isTest
    static void testeLeadEntryQueuable(){
        List<Lead> leadsToInsert = new List<Lead>();
        List<LeadEntry__c> entriesInOrder = new List<LeadEntry__c>();

        Lead lead = [SELECT Id From Lead WHERE Email LIKE '%@luck.com' LIMIT 1];
        leadsToInsert.add(lead);

        LeadEntry__c leadentry = [SELECT Id FROM LeadEntry__c WHERE Email__c LIKE '%@luck.com'];
        entriesInOrder.add(leadentry);

        LeadEntryQueueable leQueueable = new LeadEntryQueueable(leadsToInsert, entriesInOrder, new List<LeadEntry__c>(),new List<LeadEntry__c>());
        System.assertEquals(leadsToInsert, leQueueable.leadsToInsert, 'A lista de leads nao foi construida');
        System.assertEquals(entriesInOrder, leQueueable.entriesInOrder, 'A lista de lead entries nao foi construida');
    }

    @isTest
    static void testExecute(){
        List<Lead> leadsToInsert = new List<Lead>();
        List<LeadEntry__c> entriesInOrder = new List<LeadEntry__c>();

        Lead lead = new Lead (
            Email = 'lead2@luck.com',
            LastName = 'LeadLuck2',
            Phone = '5551981617448'
        );
        leadsToInsert.add(lead);

        LeadEntry__c leadentry = new LeadEntry__c(
            Email__c = 'leadENTRY@luck.com',
            Phone__c = '5551981617448'
        );
        entriesInOrder.add(leadentry);
        insert entriesInOrder;
        
        Test.startTest();
        LeadEntryQueueable leQueueable = new LeadEntryQueueable(leadsToInsert, entriesInOrder, new List<LeadEntry__c>(), new List<LeadEntry__c>());
        System.enqueueJob(leQueueable);
        Test.stopTest();

        List<Lead> insertedLeads = [SELECT Id FROM Lead WHERE Email LIKE 'lead2@luck.com'];
        System.assertEquals(1, insertedLeads.size());

        List<LeadEntry__c> updatedLE = [SELECT Id, Lead__c FROM LeadEntry__c WHERE Lead__c = :insertedLeads[0].Id];
        System.assertEquals(1, updatedLE.size());
    }   
    
    @IsTest
    static void testLeadInsertFailure() {
        List<LeadEntry__c> entries = [SELECT Id FROM LeadEntry__c];
        
        List<Lead> leads = new List<Lead>{
            new Lead(Company = 'Test Lead 1', Email = 'test1@performance.com'),
            new Lead(Company = 'Test Lead 2', Email = 'test2@performance.com')
        };
        
        Test.startTest();
        LeadEntryQueueable queueable = new LeadEntryQueueable(leads, entries, new List<LeadEntry__c>(), new List<LeadEntry__c>());
        System.enqueueJob(queueable);
        Test.stopTest();
        
        List<Log__c> logs = [SELECT Id, ErrorMessage__c, MethodName__c FROM Log__c WHERE MethodName__c = 'LeadEntryQueueable.execute'];
        System.assert(!logs.isEmpty(), 'Deveria ter criado logs para as falhas de inserção');       
    }

    @IsTest
    static void testDeleteDuplicateLeadEntries_Success() {
        System.debug('testDeleteDuplicateLeadEntries_Success');
        
        Account testPartnerAccount = new Account(
            Name               = 'Parceiro Teste',
            BillingCity        = 'BH',
            BillingState       = 'MG',
            DataMaxTermino__c  = Date.today().addDays(-1)
        );
        insert testPartnerAccount;
        System.debug('testPartnerAccount: ' + testPartnerAccount);

        List<LeadEntry__c> testEntries = new List<LeadEntry__c>{
            new LeadEntry__c(
                Name = 'Seulgi',
                Email__c = 'Seulgi@redvelvet.com',
                PartnerAccount__c = testPartnerAccount.Id
            ),
            new LeadEntry__c(
                Name = 'Dahyun',
                Email__c = 'dahyun@twice.com',
                PartnerAccount__c = testPartnerAccount.Id
            )
        };        
        insert testEntries;
        
        LeadEntryQueueable queueable = new LeadEntryQueueable(
            new List<Lead>(),     
            new List<LeadEntry__c>(), 
            testEntries,
            new List<LeadEntry__c>()        
        );
        
        Test.startTest();
        queueable.deleteDuplicateLeadEntries();
        Test.stopTest();
        
        List<LeadEntry__c> remainingEntries = [SELECT Id FROM LeadEntry__c WHERE Id IN :testEntries];
        System.assertEquals(0, remainingEntries.size(), 'Os registrosnão foram deletados');        
    }

    @isTest
    static void testeUpdateOldLeadEntry_FromDuplicatedLeadEntries(){
        List<LeadEntry__c> entriesToUpdate = new List<LeadEntry__c>();
        LeadEntry__c leadentry = [SELECT Id, DuplicatedDate__c  FROM LeadEntry__c WHERE Email__c LIKE '%@luck.com' LIMIT 1];
        leadentry.DuplicatedDate__c = System.now();
        entriesToUpdate.add(leadentry);

        LeadEntryQueueable queueable = new LeadEntryQueueable(
            new List<Lead>(),     
            new List<LeadEntry__c>(), 
            new List<LeadEntry__c>(),
            entriesToUpdate        
        );
        
        Test.startTest();
        queueable.updateOldLeadEntry_FromDuplicateLeadEntries(entriesToUpdate);
        Test.stopTest();

        List<LeadEntry__c> remainingEntries = [SELECT Id, DuplicatedDate__c FROM LeadEntry__c WHERE Id IN :entriesToUpdate LIMIT 1];
        System.assertEquals(leadentry.DuplicatedDate__c, remainingEntries[0].DuplicatedDate__c, 'Os registros não foram ATUALIZADOS');          
    }
}