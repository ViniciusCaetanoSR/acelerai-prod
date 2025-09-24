@isTest
public with sharing class LeadDuplicatedRemoverTest {
      
    @isTest
    static void shouldDeleteDuplicatedLead() {

        Lead lead1 = new Lead(
            FirstName = 'Teste',
            LastName = 'Duplicado 3',
            Company = 'Empresa Z',
            Email = 'teste.duplicado4@exemplo.com',
            IsDuplicate__c = false
        );

        Lead lead2 = new Lead(
            FirstName = 'Teste',
            LastName = 'Duplicado 3',
            Company = 'Empresa Z',
            Email = 'teste.duplicado4@exemplo.com',
            IsDuplicate__c = true
        );
        
        Test.startTest();
        insert new List<Lead>{lead1, lead2};
        
        List<Lead> leadsBefore = [SELECT Id, Name, IsDuplicate__c FROM Lead];
        Set<Id> leadsIds = new Set<Id>();

        for (Lead lead : leadsBefore){
            leadsIds.add(lead.Id);
        }

        System.debug('[shouldDeleteDuplicatedLead] Tamanho do leadsBefore: ' + leadsBefore.size());
        System.assertEquals(2, leadsBefore.size(), '[shouldDeleteDuplicatedLead] Deveria haver, em leadsBefore, inicialmente, dois leads duplicados');
        
        LeadDuplicatedRemover job = new LeadDuplicatedRemover(leadsIds);
        System.enqueueJob(job);
        Test.stopTest();

        List<Lead> leadsAfter = [SELECT Id, Name FROM Lead];
        System.debug('[shouldDeleteDuplicatedLead] Tamanho do leadsAfter: ' + leadsAfter.size());
        System.assertEquals(1, leadsAfter.size(), '[shouldDeleteDuplicatedLead] A lista de leadsAfter não tem o número de leads correto');

    }

    @isTest
    static void shouldNotDeleteLead(){

        Lead lead1 = new Lead(
            FirstName = 'Teste',
            LastName = 'Não Duplicado 1',
            Company = 'Empresa Bli Bli',
            Email = 'teste_nao_duplicado@exemplo.com',
            IsDuplicate__c = false
        );

        Lead lead2 = new Lead(
            FirstName = 'Teste',
            LastName = ' Não Duplicado 2',
            Company = 'Empresa Blá blá',
            Email = 'teste.nao.duplicado@exemplo.com',
            IsDuplicate__c = false
        );
        
        Test.startTest();
        insert new List<Lead>{lead1, lead2};
        
        List<Lead> leadsBefore = [SELECT Id, Name, IsDuplicate__c FROM Lead];
        Set<Id> leadsIds = new Set<Id>();

        for (Lead lead : leadsBefore){
            leadsIds.add(lead.Id);
        }

        System.debug('[shouldNotDeleteLead] Tamanho do leadsBefore: ' + leadsBefore.size());
        System.assertEquals(2, leadsBefore.size(), '[shouldNotDeleteLead] Deveria haver, em leadsBefore, inicialmente, dois leads duplicados');
        
        LeadDuplicatedRemover job = new LeadDuplicatedRemover(leadsIds);
        System.enqueueJob(job);
        Test.stopTest();

        List<Lead> leadsAfter = [SELECT Id, Name FROM Lead];
        System.debug('[shouldNotDeleteLead] Tamanho do leadsAfter: ' + leadsAfter.size());
        System.assertEquals(2, leadsAfter.size(), '[shouldNotDeleteLead] A lista de leadsAfter não tem o número de leads correto');
    }
}