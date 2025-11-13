@IsTest
private class TeamsUserConsentHandlerControllerTest {

    @IsTest
    static void testConstructorWithValidParams() {
        User u = new User(
            Alias = 'pkb',
            LastName = 'PeekABoo',
            Email = 'pkb@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'pkb@example.com'
        );
        insert u;

        Test.setCurrentPageReference(new PageReference('/apex/TeamsUserConsentHandler'));
        ApexPages.currentPage().getParameters().put('code', 'mockCode123');
        ApexPages.currentPage().getParameters().put('state', u.Id);

        TeamsOAuth_Response mockResponse = new TeamsOAuth_Response();
        mockResponse.access_token = 'access123';
        mockResponse.expires_in = '3600';
        mockResponse.refresh_token = 'refresh456';
        mockResponse.scope = 'Calendars.ReadWrite';
        mockResponse.token_type = 'Bearer';

        Test.startTest();
            TeamsUserConsentHandlerController.oauthOverride = mockResponse;

            TeamsUserConsentHandlerController controller = new TeamsUserConsentHandlerController(new ApexPages.StandardController(u));
            controller.contructorWithDML();
        Test.stopTest();

        System.assertEquals(false, controller.hasError, 'Xiii, deu erro');
        User updatedUser = [SELECT TeamsAccessToken__c, HasTeamsConsent__c FROM User WHERE Id = :u.Id];
        System.assertEquals('access123', updatedUser.TeamsAccessToken__c);
        System.assertEquals(true, updatedUser.HasTeamsConsent__c);
    }

    @IsTest
    static void testConstructorWithMissingParams() {
        Test.setCurrentPageReference(new PageReference('/apex/TeamsUserConsentHandler'));
        ApexPages.currentPage().getParameters().put('code', null);
        ApexPages.currentPage().getParameters().put('state', null);

        TeamsUserConsentHandlerController controller = new TeamsUserConsentHandlerController(new ApexPages.StandardController(new User()));
        controller.contructorWithDML();

        System.assertEquals(true, controller.hasError, 'Deveria haver erro por falta de parâmetros');
    }

    
}