@isTest
public class ScheduleMediaOpportunityAssignmentTest {
    public static String cronExp = '0 0 7 * * ?';

    @isTest
    private static void shouldDailyUpdate(){

        Test.startTest(); 
            ScheduleMediaOpportunityAssignment.scheduleJob();
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronExpression =: cronExp];
    
        Assert.areEqual(cronExp, ct.CronExpression, 'A expressão cron deve estar configurada para execução diária.');
        Assert.areEqual(0, ct.TimesTriggered, 'Não deve ter sido acionado ainda');
        Assert.isTrue(ct.NextFireTime != null , 'Próximo horário deve estar agendado.');
    }
}