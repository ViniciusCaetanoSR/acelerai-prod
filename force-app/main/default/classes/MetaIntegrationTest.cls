@isTest
public class MetaIntegrationTest {
   
    @isTest
    static void testSendLeadToMeta() {
        Meta__c meta = new Meta__c(
            Name = 'Meta',
            Url__c = 'http://teste.com.br',
            AcessToken__c = 'test_acess_token',
            PixelId__c = 'teste_pixel_Id'
        ); 
        insert meta; 

        List<LeadStatusMeta__c> eventNames = [SELECT LeadStatus__c, EventName__c FROM LeadStatusMeta__c];

        insert eventNames;

        Lead leadTest1 = VirtualTestData.createLead('lastName1', 'Lead Score', 'company1', 'teste1@example.com', '52765247527');
        Lead leadTest2 = VirtualTestData.createLead('lastName2', 'Perdido', 'company2', 'teste2@example.com', '52765247528');
        insert new List<Lead>{leadTest1, leadTest2};
    
        List<Id> leadIds = new List<Id>{leadTest1.Id, leadTest2.Id};
        
        Test.startTest();
        MetaIntegration.sendLeadToMeta(leadIds);
        Test.stopTest();
    }

    @isTest
    static void testSendLeadToMetaWithNoLeads() {
        Meta__c meta = new Meta__c(
            Name = 'Meta',
            Url__c = 'http://teste.com.br',
            AcessToken__c = 'test_acess_token',
            PixelId__c = 'teste_pixel_Id'
        ); 

        insert meta; 

        List<Id> leadIds = new List<Id>();

        Test.startTest();
        MetaIntegration.sendLeadToMeta(leadIds);
        Test.stopTest();

        List<Lead> leadAfterExexution = [SELECT Id FROM Lead];
        System.assertEquals(0, leadAfterExexution.size(), 'Nenhum Lead deveria ser processado');
    }

    @isTest
    static void testSendOpportunityToMeta() {
        Meta__c meta = new Meta__c(
            Name = 'Meta',
            Url__c = 'http://teste.com.br',
            AcessToken__c = 'test_acess_token',
            PixelId__c = 'teste_pixel_Id'
        ); 
        insert meta; 

        List<OpportunityStageMeta__c> eventNames = [SELECT OpportunityStage__c, EventName__c FROM OpportunityStageMeta__c];

        insert eventNames;

        Account account = VirtualTestData.createAccount('accountName');
        insert account;

        Opportunity opportunity = VirtualTestData.createOpportunity('opportunityName', account.Id, '674867536768', 'Financeiro', 'Cliente final', Date.today().addDays(7), 'Em Negociação');
        opportunity.Metalead_id__c = 'hfjsakjshfks';
        opportunity.Fbclid__c = 'fb87946769';
        opportunity.Funnel__c = 'Varejo';
        insert opportunity;

        System.debug('Debug x: telefone__c: ' + opportunity.Telefone__c);
        

        List<Id> opportunityIds = new List<Id>{opportunity.Id};

        Test.startTest(); 
        MetaIntegration.sendOpportunityToMeta(opportunityIds);
        Test.stopTest(); 
    }

    @isTest 
    static void testSendOpportunityToMetaWithNoOpportunities() {
        Meta__c meta = new Meta__c(
            Name = 'Meta',
            Url__c = 'http://teste.com.br',
            AcessToken__c = 'test_acess_token',
            PixelId__c = 'teste_pixel_Id'
        );
         
        insert meta; 

        List<Id> opportunityIds = new List<Id>();

        Test.startTest(); 
        MetaIntegration.sendOpportunityToMeta(opportunityIds);
        Test.stopTest();

        List<Opportunity> opportunityAfterExecution = [SELECT Id FROM Opportunity];
        System.assertEquals(0, opportunityAfterExecution.size(), 'Nenhuma oportunidade deveria ser processada');
    }

}