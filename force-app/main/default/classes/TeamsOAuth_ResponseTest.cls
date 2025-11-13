@IsTest
private class TeamsOAuth_ResponseTest {

    @IsTest
    static void testParseJson() {
        String json = '{' +
            '"access_token":"abc123",' +
            '"expires_in":"3600",' +
            '"refresh_token":"xyz789",' +
            '"scope":"Calendars.ReadWrite",' +
            '"token_type":"Bearer"' +
        '}';

        Test.startTest();
        TeamsOAuth_Response response = TeamsOAuth_Response.parse(json);
        Test.stopTest();

        System.assertEquals('abc123', response.access_token);
        System.assertEquals('3600', response.expires_in);
        System.assertEquals('xyz789', response.refresh_token);
        System.assertEquals('Calendars.ReadWrite', response.scope);
        System.assertEquals('Bearer', response.token_type);
    }
}