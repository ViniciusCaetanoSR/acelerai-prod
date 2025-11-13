@isTest
private class TeamsCalendarHelperTest {

    private class MockHttpCalendarResponse implements HttpCalloutMock {
        public String scenario;
        
        public MockHttpCalendarResponse(String scenario) {
            this.scenario = scenario;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // GET /me/calendars - buscar calendários existentes
            if (req.getMethod() == 'GET' && req.getEndpoint().contains('/calendars')) {
                if (scenario == 'calendar_exists') {
                    res.setStatusCode(200);
                    res.setBody(JSON.serialize(new Map<String, Object>{
                        'value' => new List<Object>{
                            new Map<String, Object>{
                                'id' => 'cal-existing-123',
                                'name' => 'Salesforce'
                            }
                        }
                    }));
                } else if (scenario == 'calendar_not_found') {
                    res.setStatusCode(200);
                    res.setBody(JSON.serialize(new Map<String, Object>{
                        'value' => new List<Object>{
                            new Map<String, Object>{
                                'id' => 'cal-other-456',
                                'name' => 'Calendar'
                            }
                        }
                    }));
                }
            }
            
            // POST /me/calendars - criar novo calendário
            if (req.getMethod() == 'POST' && req.getEndpoint().contains('/calendars')) {
                res.setStatusCode(201);
                res.setBody(JSON.serialize(new Map<String, Object>{
                    'id' => 'cal-new-789',
                    'name' => 'Salesforce'
                }));
            }
            
            return res;
        }
    }

    @isTest
    static void testGetOrCreateCalendar_AlreadyInUser() {
        User u = createUser();
        u.TeamsCalendarId__c = 'cal-saved-999';
        update u;
        
        Test.startTest();
        String result = TeamsCalendarHelper.getOrCreateSalesforceCalendar(u, 'fake_token');
        Test.stopTest();
        
        System.assertEquals('cal-saved-999', result, 'Deveria retornar o calendarId já salvo no User');
    }

    @isTest
    static void testGetOrCreateCalendar_CalendarExists() {
        User u = createUser();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalendarResponse('calendar_exists'));
        
        Test.startTest();
        String result = TeamsCalendarHelper.getOrCreateSalesforceCalendar(u, 'fake_token');
        Test.stopTest();
        
        System.assertEquals('cal-existing-123', result, 'Deveria retornar o id do calendário existente');
        
        User updatedUser = [SELECT TeamsCalendarId__c FROM User WHERE Id = :u.Id];
        System.assertEquals('cal-existing-123', updatedUser.TeamsCalendarId__c, 'Deveria salvar o calendarId no User');
    }

    @isTest
    static void testGetOrCreateCalendar_CreateNewCalendar() {
        User u = createUser();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpCalendarResponse('calendar_not_found'));
        
        Test.startTest();
        String result = TeamsCalendarHelper.getOrCreateSalesforceCalendar(u, 'fake_token');
        Test.stopTest();
        
        System.assertEquals('cal-new-789', result, 'Deveria criar e retornar novo calendário');
        
        User updatedUser = [SELECT TeamsCalendarId__c FROM User WHERE Id = :u.Id];
        System.assertEquals('cal-new-789', updatedUser.TeamsCalendarId__c, 'Deveria salvar o novo calendarId no User');
    }

    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            Alias = 'testcal',
            LastName = 'CalTest',
            Email = 'caltest' + Math.random() + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            LocaleSidKey = 'pt_BR',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Sao_Paulo',
            UserName = 'caltest' + Math.random() + '@test.com'
        );
        insert u;
        return u;
    }
}