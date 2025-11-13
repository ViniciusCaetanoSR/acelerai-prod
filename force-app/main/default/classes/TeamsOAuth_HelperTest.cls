@isTest
private class TeamsOAuth_HelperTest {

    @isTest
    static void testIsTokenExpiredNull() {
        User u = createUser();
        u.TeamsTokenExpiresAt__c = null;

        Boolean result = TeamsOAuth_Helper.isTokenExpired(u);
        System.assertEquals(true, result, 'é null, deveria dar erro');
    }

    @isTest
    static void testIsTokenExpiredPastDate() {
        User u = createUser();
        Datetime past = System.now().addHours(-2);
        u.TeamsTokenExpiresAt__c = past.format('dd/MM/yyyy HH:mm');

        Boolean result = TeamsOAuth_Helper.isTokenExpired(u);
        System.assertEquals(true, result, 'a data é passada, deveria dar erro');
    }

    @isTest
    static void testIsTokenExpiredInvalidFormat() {
        User u = createUser();
        u.TeamsTokenExpiresAt__c = 'formato_invalido';

        Boolean result = TeamsOAuth_Helper.isTokenExpired(u);
        System.assertEquals(true, result, 'Formato inválido, deveria dar erro');
    }

    @isTest
    static void testHandleTokenExpirationAlwaysTrueInTest() {
        User u = createUser();
        Boolean result = TeamsOAuth_Helper.handleTokenExpiration(u);
        System.assertEquals(true, result, 'Em contexto de teste sempre retorna true');
    }

    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'kyko',
            LastName = 'kyko',
            Email = 'kyko' + Math.random() + '@trutru.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'kyko' + Math.random() + '@trutru.com'
        );
        insert u;
        return u;
    }
}