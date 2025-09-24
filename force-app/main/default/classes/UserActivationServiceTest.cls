@isTest
public with sharing class UserActivationServiceTest {
    @TestSetup
    static void setupTestData() {
        Account acc = new Account(
            Name = 'Teste Partner User',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil'
        );
        insert acc;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            acc.OwnerId = UserInfo.getUserId();
            update acc;
        }

        Contact contact = new Contact(
            LastName = 'Test Contact Partner', 
            Email = 'partnerPerformance@acelera.br', 
            Phone = '5551981617948', 
            AccountId = acc.Id
        );
        insert contact;

        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Parceiro Performance' LIMIT 1];

        User partnerUser = new User(
            Alias = 'partPerf',
            Email = 'partnerPerformance@acelera.br',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Partner',
            FirstName = 'Performance',                
            ProfileId = partnerProfile.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserName = 'partnerPerformance@acelera.br.test', 
            ContactId = contact.Id,
            IsActive = false
        );
        insert partnerUser;
    }

    @isTest
    static void testActivateUsers(){
        List<User> userList = [SELECT Id, IsActive FROM User WHERE Email = 'partnerPerformance@acelera.br' LIMIT 1];  
        List<Id> userIds = new List<Id>();
        userIds.add(userList[0].Id);

        Test.startTest();
        UserActivationService.activateUsers(userIds);
        Test.stopTest();

        List<User> updatedUsers = [SELECT Id, IsActive FROM User WHERE Id IN :userIds LIMIT 1];
        System.assertEquals(true, updatedUsers[0].IsActive);
    }

    @isTest
    static void testDeactivateUsers(){
        List<User> userList = [SELECT Id, IsActive FROM User WHERE Email = 'partnerPerformance@acelera.br' LIMIT 1];  
        userList[0].IsActive = true;

        List<Id> userIds = new List<Id>();
        userIds.add(userList[0].Id);

        Test.startTest();
        UserActivationService.deactivateUsers(userIds);
        Test.stopTest();

        List<User> updatedUsers = [SELECT Id, IsActive FROM User WHERE Id IN :userIds LIMIT 1];
        System.assertEquals(false, updatedUsers[0].IsActive);
    }
}