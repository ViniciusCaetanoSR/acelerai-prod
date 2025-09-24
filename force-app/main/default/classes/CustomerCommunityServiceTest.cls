@IsTest
private class CustomerCommunityServiceTest {
    /* Garante que o Pricebook padrão esteja ativo */
    private static Pricebook2 getStdPricebook() {
        Id stdPbId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Id = stdPbId, IsActive = true);
        update pb;
        return pb;
    }
    
    /*────────────────────────────────────────────
* 1) Contato deve GANHAR acesso
*───────────────────────────────────────────*/
    @IsTest
    static void testGrantAccess() {
        /* Conta e contato */
        Account acc = VirtualTestData.createAccount('Conta A');
        insert acc;
        Contact con = VirtualTestData.createContact('Contato A', acc.Id, 'testeA@example.com', '+551191111111');
        insert con;
        
        /* Produto “Aceleraí Performance” */
        Product2 prod = VirtualTestData.createProduct('Aceleraí Performance', 'Performance');
        insert prod;
        
        Pricebook2 stdPb = getStdPricebook();
        PricebookEntry pbe = VirtualTestData.createPriceBookEntry(prod.Id, stdPb.Id, 100);
        insert pbe;
        
        /* Oportunidade inicialmente fora dos estágios-alvo */
        Opportunity opp = VirtualTestData.createOpportunity('Opp A', acc.Id, '+551191111111', 'Automotivo', 'Agência', Date.today(), 'Qualificação');
        opp.CNPJ__c = '42113212000125';
        opp.ContactId = con.Id;
        opp.ContractStartDate__c = Date.today();
        opp.EndOfContractDate__c = Date.today().addYears(1);
        insert opp;
        
        /* Cria cotação sincronizada antes de alterar estágio */
        Quote quote = VirtualTestData.createQuote('QuoteName', opp.Id);
        
        quote.VendaFutura__c = true;
        quote.Sincronizado__c = true;
        quote.PagamentoFuturo__c = false;
        quote.DataVendaFutura__c = Date.today().addDays(-7);
        
        insert quote;
        
        /* LineItem */
        insert VirtualTestData.createOpportunityLineItem(opp, prod.Id, pbe);
        
        /* Simula mudança de estágio → TARGET_STAGES (“Ganho”) */
        Opportunity beforeUpdate = [
            SELECT Id, StageName,ContractStartDate__c, EndOfContractDate__c, ContactId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        opp.StageName = 'Ganho';
        update opp;
        
        Opportunity afterUpdate = [
            SELECT Id, StageName,ContractStartDate__c, EndOfContractDate__c, ContactId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        
        Test.startTest();
        CustomerCommunityService.handleAccess(new List<Opportunity>{ afterUpdate }, new Map<Id, Opportunity>{ beforeUpdate.Id => beforeUpdate });
        Test.stopTest();
        
        /* Valida que o usuário foi criado e está ativo */
        User u = [
            SELECT IsActive, Username,Email
            FROM User
            WHERE ContactId = :con.Id
            LIMIT 1
        ];
        System.assertEquals(true, u.IsActive, 'O usuário deveria estar ativo.');
        System.assert(u.Username.endsWith('@aceleraiperformance.com'));
    }
    
    /*────────────────────────────────────────────
* 2) Contato deve PERDER acesso
*───────────────────────────────────────────*/
    @IsTest
    static void testRevokeAccess() {
        /* Conta e contato */
        Account acc = VirtualTestData.createAccount('Conta B');
        insert acc;
        Contact con = VirtualTestData.createContact('Contato B', acc.Id, 'testeB@example.com', '+551192222222');
        insert con;
        
        /* Produto “Aceleraí Performance” */
        Product2 prod = VirtualTestData.createProduct('Aceleraí Performance', 'Performance');
        insert prod;
        
        Pricebook2 stdPb = getStdPricebook();
        PricebookEntry pbe = VirtualTestData.createPriceBookEntry(prod.Id, stdPb.Id, 100);
        insert pbe;
        
        /* Oportunidade já em estágio-alvo (“Ganho”) */
        Opportunity opp = VirtualTestData.createOpportunity('Opp B', acc.Id, '+551192222222', 'Automotivo', 'Agência', Date.today(), 'Qualificação');
        opp.CNPJ__c = '42113212000125';
        opp.ContactId = con.Id;
        opp.ContractStartDate__c = Date.today().addYears(-1);
        opp.EndOfContractDate__c = Date.today().addYears(1);
        insert opp;
        
        Quote quote = VirtualTestData.createQuote('QuoteName', opp.Id);
        
        quote.VendaFutura__c = true;
        quote.Sincronizado__c = true;
        quote.PagamentoFuturo__c = false;
        quote.DataVendaFutura__c = Date.today().addDays(-7);
        
        insert quote;
        
        opp.StageName = 'Ganho';
        update opp;
        
        insert VirtualTestData.createOpportunityLineItem(opp, prod.Id, pbe);
        
        /* Cria usuário ativo (como se já tivesse sido concedido) */
        Id profileId = CustomerCommunityService.getCommunityProfileId();
        System.assertNotEquals(null, profileId, 'Perfil “Parceiro Performance” não encontrado.');
        User usr = CustomerCommunityService.createCommunityUser(con, profileId);
        insert usr;
        System.assert(usr.IsActive, 'Pré-condição: usuário deve estar ativo.');
        
        /* Simula mudança de estágio SAINDO de TARGET_STAGES */
        Opportunity beforeUpdate = [
            SELECT Id, StageName, ContractStartDate__c, EndOfContractDate__c, ContactId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        opp.StageName = 'Qualificação'; // estágio fora da lista-alvo
        update opp;
        
        Opportunity afterUpdate = [
            SELECT Id, StageName, ContractStartDate__c, EndOfContractDate__c, ContactId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        
        Test.startTest();
        CustomerCommunityService.handleAccess(new List<Opportunity>{ afterUpdate }, new Map<Id, Opportunity>{ beforeUpdate.Id => beforeUpdate });
        Test.stopTest();
        
        /* Valida que o usuário foi desativado */
        User deactivated = [SELECT IsActive FROM User WHERE Id = :usr.Id];
        System.assertEquals(false, deactivated.IsActive, 'O usuário deveria estar inativo.');
    }
}