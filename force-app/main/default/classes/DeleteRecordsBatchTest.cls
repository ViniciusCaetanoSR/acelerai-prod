/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-20-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class DeleteRecordsBatchTest {
    
    @testSetup
    static void setup() {

        Account acc = new Account(
            Name = 'Teste 01',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1'
        );
        insert acc;
    }

    @isTest
    static void testDeleteRecordsBatch() {
        String query = 'SELECT Id FROM Account WHERE Name LIKE \'Teste 01%\'';

        Test.startTest();
        DeleteRecordsBatch batch = new DeleteRecordsBatch(query);
        Database.executeBatch(batch);
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM Account WHERE Name LIKE 'Teste 01%'];
        System.assertEquals(0, count, 'Os registros devem ter sido excluídos.');
    }
}