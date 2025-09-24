@isTest
public class MediaOpportunityAssignmentBatchTest {
   @isTest
    static void testAssignOpportuityToMembers() {

        AssignmentGroup__c group1 = new AssignmentGroup__c(
            Name = 'Group Name', 
            Object__c = 'Opportunity'
        );

        insert group1;

        User userMarcosTorres = new User(
            Username = 'usermarcosteste@test.com',
            Email = 'usermarcos@test.com',
            Alias = 'marct',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LastName = 'Torres',
            FirstName = 'Marcos'
        );

        System.runAs(new User(Id = UserInfo.getUserId())){
            insert userMarcosTorres; 
        }
        
        User user1 = new User(
            Username = 'user1teste@test.com',
            Email = 'user1@test.com',
            Alias = 'tuser1',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LastName = 'User 1',
            FirstName = 'Test'
        );

        User user2 = new User(
            Username = 'user2teste@test.com',
            Email = 'user2@test.com',
            Alias = 'tuser2',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LastName = 'User 2',
            FirstName = 'Test'
        );

        insert new List<User>{user1, user2};


        AssignmentGroupMember__c member1 = new AssignmentGroupMember__c(
            User__c = user1.Id,
            NumberRecordsAssigned__c = 0,
            LastAssignmentDate__c = Datetime.now().addDays(-2),
            AssignmentGroup__c = group1.Id
        );

        AssignmentGroupMember__c member2 = new AssignmentGroupMember__c(
            User__c = user2.Id,
            NumberRecordsAssigned__c = 1,
            LastAssignmentDate__c = Datetime.now(),
            AssignmentGroup__c = group1.Id
        );

        insert new List<AssignmentGroupMember__c>{member1, member2};

        member1.LastAssignmentDate__c = Datetime.now().addDays(-2);
        member2.LastAssignmentDate__c = Datetime.now(); 

        update new List<AssignmentGroupMember__c>{member1, member2};
        
        Account account = VirtualTestData.createAccount('accountName');
        account.Type = 'Agência';
        insert account;

        Opportunity testOpportunity1 = VirtualTestData.createOpportunity(
            'opportunityName',
            account.Id, 
            '674867536768', 
            'Alimentar(Mercado)', 
            'Cliente final', 
            Date.today(),
            'Sem Contato Mídia'
        );

        testOpportunity1.Funnel__c = 'Mídias Vendas';
        testOpportunity1.CNPJ__c = '13368124000176';
        testOpportunity1.OwnerId = userMarcosTorres.Id;
    
        Opportunity testOpportunity2 = VirtualTestData.createOpportunity(
            'opportunityName',
            account.Id, 
            '674867536798', 
            'Alimentar(Mercado)', 
            'Cliente final', 
            Date.today(),
            'Sem Contato Mídia'
        );

        testOpportunity2.Funnel__c = 'Mídias Vendas';
        testOpportunity2.CNPJ__c = '13368124000173';
        testOpportunity2.OwnerId = userMarcosTorres.Id; 
    
        insert new List<Opportunity>{testOpportunity1, testOpportunity2}; 

        Datetime myDate = Datetime.now().addDays(-7);
        Test.setCreatedDate(testOpportunity1.Id, myDate);
        Test.setCreatedDate(testOpportunity2.Id, myDate);  

        
        Test.startTest();
        Database.executeBatch(new MediaOpportunityAssignmentBatch());
        Test.stopTest();
        
    }
}