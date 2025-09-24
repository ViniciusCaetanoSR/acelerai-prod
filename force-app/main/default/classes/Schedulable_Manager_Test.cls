@isTest
public with sharing class Schedulable_Manager_Test {

    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            if (req.getEndpoint().contains('/whatsapp/login')) {
                res.setBody('{"success":true,"sessionToken":"fake_token_123"}');
            } else if (req.getEndpoint().contains('/whatsapp/get-chats-metadata')) {
                res.setBody(
                    '[{' +
                    '"chat_id":"5527999970208_5527997019622",' +
                    '"sessionid":"fake_session_id",' +
                    '"mywhatsid":"5527999970208@s.whatsapp.net",' +
                    '"secondwhatsappid":"5527997019622@s.whatsapp.net",' +
                    '"name":"João",' +
                    '"sequence":"1739824278835",' +
                    '"dt_lastmessage":"2025-02-17T17:31:18.000Z",' +
                    '"dt_second_last_message":"2025-02-17T17:31:18.000Z",' +
                    '"createddate":"2025-02-07T17:21:39.373Z",' +
                    '"version":345' +
                    '}]'
                );
            }

            return res;
        }
    }

    @isTest
    public static void TestSchedulableManager(){

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
            Schedulable_Manager.ReStartProcess();
            Schedulable_Manager.ScheduleSwitchMinute(59);
        Test.stopTest();
    }
}