@isTest
private class TeamsIntegration_FinishedEventJobTest {
    private static String cronExp = '0 0 7 * * ?';

    @isTest
    private static void testExecute(){
        String jobName = 'Test_TeamsIntegration_FinishedEventJob';

        Test.startTest();
            System.schedule(jobName, cronExp, new TeamsIntegration_FinishedEventJob());
        Test.stopTest();
        
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
        ];

        System.assertEquals(cronExp, ct.CronExpression, 'A expressão cron não está correta');
        System.assertEquals(0, ct.TimesTriggered, 'O job não deveria ter sido executado ainda');
        System.assertNotEquals(null, ct.NextFireTime, 'A próxima execução deveria estar definida');  
    }    

    @IsTest
    static void testExecute_withException_shouldLogError() {
        EventService.throwTestException = true;

        Test.startTest();
            new TeamsIntegration_FinishedEventJob().execute(null);
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, RelatedRecord__c 
            FROM Log__c 
            WHERE MethodName__c = 'Classe: TeamsIntegration_FinishedEventJob'
        ];
        System.assert(!logs.isEmpty(), 'Deveria ter criado um log de exceção');
        System.assert(logs[0].RelatedRecord__c.contains('Não tem record relacionado'), 'Mensagem de contexto deve estar presente');
    }
}