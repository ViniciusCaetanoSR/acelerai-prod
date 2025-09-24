@isTest
public class AssignmentGroupMemberTriggerHandlerTest {
    @testSetup
    static void setup() {

        AssignmentGroup__c group1 = new AssignmentGroup__c(Name = 'Group 1');
        AssignmentGroup__c group2 = new AssignmentGroup__c(Name = 'Group 2');
        insert new List<AssignmentGroup__c>{group1, group2};
    }
    
    @isTest
    static void testOnAfterInsert() {

        List<AssignmentGroup__c> groups = [SELECT Id FROM AssignmentGroup__c];
        
        List<AssignmentGroupMember__c> members = new List<AssignmentGroupMember__c>();
        for (AssignmentGroup__c grp : groups) {
            members.add(new AssignmentGroupMember__c(AssignmentGroup__c = grp.Id));
        }
        insert members;

        List<AssignmentGroupMember__c> updatedMembers = [SELECT Id, LastAssignmentDate__c, NumberRecordsAssigned__c FROM AssignmentGroupMember__c];
        for (AssignmentGroupMember__c member : updatedMembers) {
            System.assertEquals(null, member.LastAssignmentDate__c, 'LastAssignmentDate__c should be null');
            System.assertEquals(0.0, member.NumberRecordsAssigned__c, 'NumberRecordsAssigned__c should be 0.0');
        }
    }

    @isTest
    static void testAssignmentGroupWebsite() {
        User user = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'iagouser@example.com',
            Username = 'iagousername@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id

        );

        insert user;

        AssignmentGroup__c ag = new AssignmentGroup__c(
            Name='Test Assignment Group', 
            Object__c='Lead', 
            Media__c = 'sbt'
           );
        
           insert ag;

           AssignmentGroupMember__c agm = new AssignmentGroupMember__c(
            AssignmentGroup__c = ag.Id, 
            User__c = user.Id);
            insert agm;
        
        Lead lead = new Lead(
            FirstName = 'Teste',
            LastName = 'Não Duplicado 1',
            Company = 'Empresa Bli Bli',
            Email = 'teste_nao_duplicado@exemplo.com',
            IsDuplicate__c = false, 
            Website__c = 'sbtacelerai'
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

    }

    @isTest
    static void testAssignmentGroupMediaNull() {
        User user = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'iagouser@example.com',
            Username = 'iagousername@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id

        );

        insert user;

        AssignmentGroup__c ag = new AssignmentGroup__c(
            Name='Test Assignment Group', 
            Object__c='Lead'
           );
        
           insert ag;

           AssignmentGroupMember__c agm = new AssignmentGroupMember__c(
            AssignmentGroup__c = ag.Id, 
            User__c = user.Id);
            insert agm;
        
        Lead lead = new Lead(
            FirstName = 'Teste',
            LastName = 'Não Duplicado 1',
            Company = 'Empresa Bli Bli',
            Email = 'teste_nao_duplicado@exemplo.com',
            IsDuplicate__c = false
        );

        Test.startTest();
        insert lead;
        Test.stopTest();
    }
}