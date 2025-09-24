@IsTest
public with sharing class Batch_NitzapChats_Test {

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

    @IsTest
    public static void runTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        User user = new User(
            Username = 'teste.integration@sandbox.com.br',
            LastName = 'Usuário de Teste',
            Alias = 'teste',
            Email = 'teste.integration@sandbox.com.br',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            LanguageLocaleKey = 'pt_BR',
            EmailEncodingKey = 'ISO-8859-1',
            ProfileId = UserInfo.getProfileId(),
            nitzap20__Secret__c = 'segredoFake123',
            nitzap20__WhatsAppId__c = '5527999970208',
            nitzap20__Connected__c = true
        );
        insert user;

        nitzap20__NitzapConfigs__c config = new nitzap20__NitzapConfigs__c(
            Name = 'Default Config',
            nitzap20__Url_Base__c = 'https://acelerai.nitzap.com'
        );
        insert config;

        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();

        Account acc = new Account(
            Name = 'TESTE LTDA', 
            RecordTypeId = rtId,
            BillingCity = 'TESTE CIDADE',
            BillingState = 'TESTE ESTADO'
        );
        insert acc;

        Contact ctt = new Contact(
            LastName = 'Ctt 1',
            AccountId = acc.Id,
            Email = 'teste@gmail.com',
            MobilePhone = '(27) 99701-9622',
            nitzap20__WhatsAppId__c = '5527997019622'
        );
        insert ctt;

        Test.startTest();
            Batch_NitzapChats batch = new Batch_NitzapChats();
            Database.executeBatch(batch, 1);
        Test.stopTest();

        
        Contact result = [SELECT nitzap20__DateTime_Last_Sent_Whatsapp__c FROM Contact WHERE Id = :ctt.Id];
        System.assertNotEquals(null, result.nitzap20__DateTime_Last_Sent_Whatsapp__c, 'Contato deve ter data atualizada');

        List<Task> tarefas = [SELECT Id, Subject, WhoId FROM Task WHERE WhoId = :ctt.Id];
        System.assertEquals(1, tarefas.size(), 'Deveria existir uma tarefa');
        System.assertEquals('Conversa Whatsapp', tarefas[0].Subject);
    }
}