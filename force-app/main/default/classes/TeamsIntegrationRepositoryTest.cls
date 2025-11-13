@IsTest
private class TeamsIntegrationRepositoryTest {

    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Repo',
            LastName = 'Tester',
            Alias = 'rtest',
            Email = 'repo.tester@example.com',
            Username = 'repo.tester.' + System.currentTimeMillis() + '@example.com',
            CommunityNickname = 'repoTester' + String.valueOf(Crypto.getRandomLong()),
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'pt_BR',
            ProfileId = p.Id
        );
        insert u;
        return u;
    }

    private static Account createAccount() {
        Account a = new Account(
            Name = 'Teste 01',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1'
        );
        insert a;
        return a;
    }

    private static Opportunity createOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Telefone__c = '5551981617948',
            Segmento__c = 'Aplicativos',
            Tipo_de_cliente__c = 'Cliente Final',
            CloseDate = Date.today().addDays(5),
            StageName = 'Qualificação',
            HaveCurrentlyAgency__c = 'Não',
            Ja_foi_anunciante__c = 'Não',
            MonthlyInvestmentMedia_Content__c = 'Não Invisto',
            PaymentLink_sendingDate__c = Date.today(),
            Pol_tica_Comercial__c = '1 mês a mais de direito de imagem',
            QuandoPretendeAnunciar__c = 'Imediatamente',
            SaleType__c = 'Cliente novo',
            //Tipo_de_cliente__c = clientType, 
            Veiculacao__c = 'Mídia On',
            WhatsYourInstagram__c = '@_teste',
            WhatsYourRole__c = 'Gerente',
            StateYourCompany__c = 'AC',
            ClientsObjectiveWithAcelerai__c = 'Campanha Institucional'
        );
        insert opp;
        return opp;
    }

    private static Event createEvent(Id ownerId, Id whatId) {
        Event ev = new Event(
            Subject = 'Repo Test Meeting',
            StartDateTime = System.now().addDays(1),
            EndDateTime = System.now().addDays(1).addHours(1),
            OwnerId = ownerId,
            WhatId = whatId
        );
        insert ev;
        return ev;
    }

    private static TeamsTranscriptionHistory__c createTranscriptionHistory(Id relatedOppId, Id relatedEventId) {
        TeamsTranscriptionHistory__c th = new TeamsTranscriptionHistory__c(
            Name = 'Initial TH',
            RelatedOpp__c = relatedOppId,
            RelatedEvent__c = 'https://example/lightning/r/Event/' + relatedEventId + '/view'
        );
        insert th;
        return th;
    }

    @IsTest
    static void test_updateEventsFieldWithTeamsData_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);

        Test.startTest();
        Event updated = TeamsIntegrationRepository.updateEventsFieldWithTeamsData(
            ev, 'Descricao atualizada', 'https://teams.microsoft.com/l/meetup-join/some', 'MEET-123', 'EVT-456'
        );
        Test.stopTest();

        System.assertNotEquals(null, updated);
        Event reloaded = [SELECT Description, TeamsJoinURL__c, TeamsMeetingId__c, TeamsEventId__c, ProcessedByTeams__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals('Descricao atualizada', reloaded.Description);
        System.assertEquals('https://teams.microsoft.com/l/meetup-join/some', reloaded.TeamsJoinURL__c);
        System.assertEquals('MEET-123', reloaded.TeamsMeetingId__c);
        System.assertEquals('EVT-456', reloaded.TeamsEventId__c);
    }

    @IsTest
    static void test_updateUserIdWithTeamsData_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);

        Test.startTest();
        String returned = TeamsIntegrationRepository.updateUserIdWithTeamsData(ev, 'USR-TEAMS-999');
        Test.stopTest();

        System.assertEquals('USR-TEAMS-999', returned);
        User reloaded = [SELECT TeamsUserId__c FROM User WHERE Id = :u.Id];
        System.assertEquals('USR-TEAMS-999', reloaded.TeamsUserId__c);
    }

    @IsTest
    static void test_updateProcessedByTeamsField_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);

        Test.startTest();
        TeamsIntegrationRepository.updateProcessedByTeamsField(ev);
        Test.stopTest();

        Event reloaded = [SELECT ProcessedByTeams__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals(true, reloaded.ProcessedByTeams__c);
    }

    @IsTest
    static void test_updateTeamsAttendanceRecordId_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);

        Test.startTest();
        TeamsIntegrationRepository.updateTeamsAttendanceRecordId(ev, 'AR-001');
        Test.stopTest();

        Event reloaded = [SELECT TeamsAttendanceRecordId__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals('AR-001', reloaded.TeamsAttendanceRecordId__c);
    }

    @IsTest
    static void test_updateTeamsOnlineMeetingId_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);

        Test.startTest();
        TeamsIntegrationRepository.updateTeamsOnlineMeetingId(ev, 'ONLINE-987');
        Test.stopTest();

        Event reloaded = [SELECT TeamsOnlineMeetingId__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals('ONLINE-987', reloaded.TeamsOnlineMeetingId__c);
    }

    @IsTest
    static void test_updateTeamsPresenters_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);
        List<String> presentersEmails = new List<String>();
        presentersEmails.add('barbara@acelerai.com.br');
        presentersEmails.add('iago@acelerai.com.br');

        Test.startTest();
        TeamsIntegrationRepository.updateTeamsPresenters(ev, true, presentersEmails);
        Test.stopTest();

        Event reloaded = [SELECT TeamsShowStatus__c, TeamsPresentersEmails__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals(true, reloaded.TeamsShowStatus__c);
        System.assertEquals('barbara@acelerai.com.br; iago@acelerai.com.br', reloaded.TeamsPresentersEmails__c);
    }

    @IsTest
    static void test_updateTeamsTranscriptId_createsAndUpdatesHistory() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);

        Test.startTest();
        TeamsTranscriptionHistory__c th = TeamsIntegrationRepository.updateTeamsTranscriptId(ev, '2', 'TRANSCRIPT-ABC');
        Test.stopTest();

        System.assertNotEquals(null, th);
        TeamsTranscriptionHistory__c thReloaded = [SELECT TeamsTranscriptCount__c, TeamsTranscriptId__c, RelatedOpp__c FROM TeamsTranscriptionHistory__c WHERE Id = :th.Id];
        System.assertEquals('2', thReloaded.TeamsTranscriptCount__c);
        System.assertEquals('TRANSCRIPT-ABC', thReloaded.TeamsTranscriptId__c);
        System.assertEquals(opp.Id, thReloaded.RelatedOpp__c);

        Event evAfter = [SELECT TeamsTranscriptionHistoryRelated__c FROM Event WHERE Id = :ev.Id];
        System.assertEquals(th.Id, evAfter.TeamsTranscriptionHistoryRelated__c);
    }

    @IsTest
    static void test_saveTranscriptContent_success() {
        User u = createUser();
        Account a = createAccount();
        Opportunity opp = createOpportunity(a.Id);
        Event ev = createEvent(u.Id, opp.Id);
        TeamsTranscriptionHistory__c th = createTranscriptionHistory(opp.Id, ev.Id);

        Test.startTest();
        TeamsIntegrationRepository.saveTranscriptContent(th, 'Conteúdo de transcrição de teste');
        Test.stopTest();

        TeamsTranscriptionHistory__c reloaded = [SELECT TeamsTranscriptContent__c FROM TeamsTranscriptionHistory__c WHERE Id = :th.Id];
        System.assertEquals('Conteúdo de transcrição de teste', reloaded.TeamsTranscriptContent__c);
    }
}