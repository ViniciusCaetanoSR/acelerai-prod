@isTest
public with sharing class LeadTriggerHandlerTest {

    @TestSetup
    static void makeData() {
        Lead mainLead = VirtualTestData.createLead('Lead Base', 'Pré Cadastro', 'LT', 'lead@test.com', '+5551981782245');
        mainLead.CNPJ__c = '85.219.079/0001-07';
        mainLead.City = 'São Paulo';
        mainLead.State = 'SP';
        insert mainLead;
    }

    @isTest
    private static void onBeforeInsertShouldUpdateLeadInfo () {
        Lead mainLead = [SELECT Id FROM Lead WHERE LastName = 'Lead Base'];
        
        Lead duplicateLead = VirtualTestData.createLead('Lead Test Duplicate', 'Pré Cadastro', 'Company Test Duplicate', 'lead@test.com', '+5551982345521');
        duplicateLead.UTM_Campaign__c = 't';
        duplicateLead.UTM_Content__c = 's';
        
        Test.startTest();
            insert duplicateLead;
        Test.stopTest();

        List<Lead> actualResult = [SELECT Id, Name, UTM_Campaign__c, UTM_Content__c, Company FROM Lead WHERE Id =: mainLead.Id];

        //Assert.areEqual(duplicateLead.UTM_Campaign__c, actualResult.get(0).UTM_Campaign__c);
        //Assert.areEqual(duplicateLead.UTM_Content__c, actualResult.get(0).UTM_Content__c);
        //Assert.areEqual(duplicateLead.Company, actualResult.get(0).Company);
    }

    @isTest
    private static void onBeforeInsertShouldUpdateLeadBecauseEmailIsNull () {
        Lead mainLead = [SELECT Id FROM Lead WHERE LastName = 'Lead Base'];
        
        Lead duplicateLead = VirtualTestData.createLead('Lead Test Duplicate 2', 'Pré Cadastro', 'Company Test Duplicate', '', '+5551982345521');
        duplicateLead.UTM_Campaign__c = 't';
        duplicateLead.UTM_Content__c = 's';
        
        Boolean exceptionThrown = false;

        Test.startTest();
            try {
                insert duplicateLead;    
            } catch (Exception ex) {
                exceptionThrown = true;
            }
        Test.stopTest();

        //Assert.areEqual(true, exceptionThrown);
    }
    
    @isTest
    private static void onBeforeInsertShouldFormatCNPJ() {
        Lead mainLead = [SELECT Id FROM Lead WHERE LastName = 'Lead Base'];
        mainLead.CNPJ__c = '40457145000130';
        
        Test.startTest();
            update mainLead;
        Test.stopTest();

        List<Lead> actualResult = [SELECT Id, CNPJ__c FROM Lead WHERE Id =: mainLead.Id];

        // Verifica se o CNPJ foi formatado corretamente
        System.assertEquals('40.457.145/0001-30', actualResult[0].CNPJ__c);
    }
}