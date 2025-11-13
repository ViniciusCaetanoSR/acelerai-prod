@isTest(SeeAllData=true)
private class TeamsOAuth_ProviderTest {

    @isTest
    static void testGetAccessTokenByUser_UserNotFound() {
        TeamsOAuth_Provider provider = new TeamsOAuth_Provider();
        TeamsOAuth_Response res = provider.getAccessTokenByUser('005000000000000'); // Id inexistente
        
        System.assertNotEquals(null, res, 'Deveria retornar um objeto, mesmo sem usuário');
    }

    @isTest
    static void testGetAccessTokenByUser_NoConsentCode() {
        User u = createUser(null);
        TeamsOAuth_Provider provider = new TeamsOAuth_Provider();
        TeamsOAuth_Response res = provider.getAccessTokenByUser(u.Id);
        
        System.assertNotEquals(null, res, 'Deveria retornar objeto vazio, pq não tem consent code');
    }

    @isTest
    static void testGetAccessTokenByUser_WithConsentCode() {
        User u = createUser('fakeCode123');
        TeamsOAuth_Provider provider = new TeamsOAuth_Provider();
        TeamsOAuth_Response res = provider.getAccessTokenByUser(u.Id);
        System.assertNotEquals(null, res, 'Mesmo em teste, deve retornar objeto válido');
    }

    @isTest
    static void testGetAccessTokenByCode() {
        TeamsOAuth_Response res = TeamsOAuth_Provider.getAccessTokenByCode('fakeCode');
        System.assertNotEquals(null, res, 'Em teste sempre retorna objeto válido');
    }

    // @isTest
    // static void testRefreshToken_WithRefreshToken() {
    //     User u = createUser('consentCode');
    //     u.TeamsRefreshToken__c = 'refresh123';
    //     update u;

    //     Test.setMock(HttpCalloutMock.class, new MockRefreshToken());

    //     Map<String, Object> result = TeamsOAuth_Provider.refreshToken(u);
    //     //System.assertNotEquals(null, result, 'Deveria retornar um mapa válido');
    //     System.assertEquals('newAccess', (String)result.get('access_token'));
    // }

    private class MockRefreshToken implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token":"newAccess","refresh_token":"newRefresh","expires_in":3600}');
            return res;
        }
    }

    private static User createUser(String consentCode) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'ehOgrelo',
            LastName = 'Grelo',
            Email = 'ehOgrelo' + Math.random() + '@trutru.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'ehOgrelo' + Math.random() + '@trutru.com',
            TeamsConsentCode__c = consentCode
        );
        insert u;
        return u;
    }
}