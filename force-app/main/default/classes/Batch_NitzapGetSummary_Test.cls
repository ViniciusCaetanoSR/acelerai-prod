@IsTest
public with sharing class Batch_NitzapGetSummary_Test {

    class Batch_NitzapGetSummary_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            if (req.getEndpoint().contains('/whatsapp/get-summary')) {

                String recv = isoTodayAt(12, 0, 1); 
                String sent = isoTodayAt(12, 0, 2); 
                           
                res.setBody(
                    '[{' +
                    '"chat_id":"5527999970208_5527997019622",' +
                    '"firstReceivedAt":"' + recv + '",' +
                    '"firstSentAt":"' + sent + '",' +
                    '"totalReceivedMessages":83,' +
                    '"totalSentMessages":229,' +
                    '"iFirstSent":false' +
                    ' }]'
                );
            }

            return res;
        }
    }

    private static String isoTodayAt(Integer hh, Integer mm, Integer ss) {
        Date d = System.today();
        Datetime dt = Datetime.newInstance(d, Time.newInstance(hh, mm, ss, 0));
        String s = dt.format('yyyy-MM-dd\'T\'HH:mm:ssZ');
        return s.substring(0, s.length() - 2) + ':' + s.substring(s.length() - 2);
    }
    

    @IsTest
    public static void runTest() {
        
        Test.setMock(HttpCalloutMock.class, new Batch_NitzapGetSummary_Mock());

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

        Task baseTask = new Task();
            baseTask.OwnerId = user.Id;
            baseTask.ActivityDate = Date.today();
            baseTask.TaskSubtype = 'Call';
            baseTask.Status = 'Completed';
            baseTask.Priority = 'Normal';
            baseTask.Subject = 'Conversa Whatsapp';
            baseTask.nitzap20__Date_Time_Start_Chat__c = Datetime.newInstance(System.today(), Time.newInstance(0,0,0,0));
            baseTask.WhoId = ctt.Id;

        insert baseTask;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Batch_NitzapGetSummary_Mock());
            Batch_NitzapGetSummary batch = new Batch_NitzapGetSummary();
            Database.executeBatch(batch, 1);
        Test.stopTest();

        // List<Task> tarefas = [SELECT Id, nitzap20__DateTime_First_Message_Received__c, nitzap20__DateTime_First_Message_Sent__c FROM Task WHERE Id = :baseTask.Id];
        // System.assertNotEquals(null, tarefas.nitzap20__DateTime_First_Message_Received__c, 'Tarefa deve ter data de recebimento de primeiro contato');
        // System.assertNotEquals(null, tarefas.nitzap20__DateTime_First_Message_Sent__c, 'Tarefa deve ter data de envio de primeiro contato');
    }
}

// Batch_NitzapGetSummary_Test
// sf project deploy start --metadata ApexClass:Batch_NitzapGetSummary --metadata ApexClass:Batch_NitzapGetSummary_Test --metadata ApexClass:Batch_NitzapGetSummary_Mock -l RunSpecifiedTests -t Batch_NitzapGetSummary_Test