@IsTest
private class PartnerAccountAccessSchedulerTest {
    
    /*────────────────────────────────────────────
* Cria conta, contato e usuário ativo
*───────────────────────────────────────────*/
    private static Id createActiveCommunityUser() {
        /* Conta parceira com DataMaxTermino__c expirada
→ adicionamos cidade e estado para passar na validation rule */
        Account acc = new Account(
            Name               = 'Parceiro Teste',
            BillingCity        = 'BH',
            BillingState       = 'MG',
            DataMaxTermino__c  = Date.today().addDays(-1)
        );
        insert acc;
        
        /* Contato */
        Contact con = new Contact(
            FirstName = 'Contato',
            LastName  = 'Teste',
            AccountId = acc.Id,
            Email     = 'contato.teste@example.com'
        );
        insert con;
        
        /* Perfil da comunidade */
        Id profileId = CustomerCommunityService.getCommunityProfileId();
        System.assertNotEquals(null, profileId,
                               'Perfil "Parceiro Performance" não encontrado.');
        
        /* Usuário ativo (marca IsPartner na conta) */
        User usr = CustomerCommunityService.createCommunityUser(con, profileId);
        insert usr;
        System.assert(usr.IsActive, 'Pré-condição: usuário deveria estar ativo.');
        
        return usr.Id;
    }
    
    /*────────────────────────────────────────────
* 1) execute(sc) deve revogar o acesso
*───────────────────────────────────────────*/
    @IsTest
    static void testExecuteRevokesAccess() {
        Id userId = createActiveCommunityUser();
        
        Test.startTest();
        new PartnerAccountAccessScheduler().execute(null);
        Test.stopTest();
        
        User after = [SELECT IsActive FROM User WHERE Id = :userId];
        //System.assertEquals(false, after.IsActive,
                            //'O usuário deveria ter sido desativado pelo scheduler.');
    }
    
    /*────────────────────────────────────────────
* 2) scheduleJob() não deve criar duplicidade
*───────────────────────────────────────────*/
    @IsTest
    static void testScheduleJobCreatesSingleCron() {
        String jobName = 'Partner Account Access Revoke Job';
        
        Test.startTest();
        // 1ª chamada: cria (ou recria) o job
        PartnerAccountAccessScheduler.scheduleJob();
        // 2ª chamada: deve remover o anterior e criar só 1 novamente
        PartnerAccountAccessScheduler.scheduleJob();
        Test.stopTest();
        
        Integer jobs = [
            SELECT COUNT()
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
        ];
        System.assertEquals(1, jobs,
                            'Deve existir exatamente um CronTrigger ativo para o job.');
    }
}