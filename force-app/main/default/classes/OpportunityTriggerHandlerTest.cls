@isTest
public with sharing class OpportunityTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Account account = VirtualTestData.createAccount('Conta Teste');
        insert account;

        Opportunity opportunity = VirtualTestData.createOpportunity('Oportunidade Teste', account.Id, '+555133818910', 'Automotivo', 'Cliente Final', Date.today(), 'Qualificação');
        insert opportunity;
    }

    @isTest
    private static void validarFormatarTelefoneCorreto () {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opportunity = [SELECT Id, Telefone__c FROM Opportunity LIMIT 1];


        String phonePattern = '^\\+[0-9]{2}[0-9]{2}[0-9]{8,9}$';
        Assert.areEqual(true, Pattern.matches(phonePattern, opportunity.Telefone__c), 'Telefone não foi formatado corretamente');

        opportunity.UTM_Campaign__c = 'test';
        update opportunity;
    }

    @isTest
    private static void validarFormatarTelefoneSemDDD () {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opportunity = VirtualTestData.createOpportunity('Oportunidade Teste', account.Id, '33818910', 'Automotivo', 'Agência', Date.today(), 'Qualificação');

        Test.startTest();
            try {
                insert opportunity;
            } catch (DmlException ex) {
                Assert.areEqual('Número sem DDD', ex.getDmlMessage(0));
            }
        Test.stopTest();
    }

    @isTest
    private static void validarFormatarTelefoneDDDIncorreto () {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opportunity = VirtualTestData.createOpportunity('Oportunidade Teste', account.Id, '+550033818910', 'Automotivo', 'Agência', Date.today(), 'Qualificação');

        Test.startTest();
            try {
                insert opportunity;
            } catch (DmlException ex) {
                Assert.areEqual('DDD Inválido', ex.getDmlMessage(0));
            }
        Test.stopTest();
    }

    @isTest
    private static void validarFormatarTelefoneVazio () {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opportunity = VirtualTestData.createOpportunity('Oportunidade Teste', account.Id, null, 'Automotivo', 'Agência', Date.today(), 'Aprovado');

        Test.startTest();
            insert opportunity;
        Test.stopTest();

        List<Opportunity> actualResult = [SELECT Id, Telefone1__c FROM Opportunity WHERE Id =:opportunity.Id];
        Assert.areEqual(null, actualResult.get(0).Telefone1__c);
    }

    @isTest
    private static void validarFormatarTeleDezesseisDigitos () {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opportunity = VirtualTestData.createOpportunity('Oportunidade Teste', account.Id, '555198178223498465', 'Automotivo', 'Agência', Date.today(), 'Aprovado');

        Test.startTest();
            try {
                insert opportunity;
            } catch (DmlException ex) {
                Assert.areEqual('Verifique quantidade de digitos do número', ex.getDmlMessage(0));
            }
        Test.stopTest();
    }
}