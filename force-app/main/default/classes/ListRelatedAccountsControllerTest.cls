@isTest
public class ListRelatedAccountsControllerTest {
    
    static Account parentAccount;
    static Account childAccount;

    static void makeData() {
        parentAccount = new Account(
            Name = 'Parent Account',  
            CompanyName__c = 'Empresa Teste', 
            Phone = '+5551982347754', 
            CNPJ__c = '09.877.750/0001-10',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingCountry = 'Country',
            BillingState = 'AC',
            BillingPostalCode = '12345'
        );
        insert parentAccount;

        childAccount = new Account(
            Name = 'Child Account', 
            ParentId = parentAccount.Id,
            CompanyName__c = 'Empresa Teste', 
            Phone = '+5551982347754', 
            CNPJ__c = '09.877.750/0001-10',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingCountry = 'Country',
            BillingState = 'AC',
            BillingPostalCode = '12345'
        );
        insert childAccount;
    }

    @isTest
    static void testGetRelatedAccounts() {
        makeData();

        Test.startTest();
        List<Account> relatedAccounts = ListRelatedAccountsController.getRelatedAccounts(childAccount.Id);
        Test.stopTest();

        System.assertEquals(1, relatedAccounts.size(), 'Deveria retornar uma conta relacionada');
        System.assertEquals(parentAccount.Id, relatedAccounts[0].Id, 'A conta relacionada deveria ser a conta pai');
    }

    @isTest
    static void testGetRelatedAccounts_NoParent() {
        makeData();

        Account childAccount1 = new Account(Name = 'Child Account 1', 
        ParentId = parentAccount.Id,
        BillingStreet = 'Street',
        BillingCity = 'City',
        BillingCountry = 'Country',
        BillingState = 'AC',
        BillingPostalCode = '12345');
        
        Account childAccount2 = new Account(Name = 'Child Account 2', 
        ParentId = parentAccount.Id,
        BillingStreet = 'Street',
        BillingCity = 'City',
        BillingCountry = 'Country',
        BillingState = 'AC',
        BillingPostalCode = '12345');
        insert new List<Account>{childAccount1, childAccount2};

        Test.startTest();
        List<Account> relatedAccounts = ListRelatedAccountsController.getRelatedAccounts(parentAccount.Id);
        Test.stopTest();

        System.assertEquals(3, relatedAccounts.size(), 'Deveria retornar três contas relacionadas');
        System.assertEquals(childAccount.Id, relatedAccounts[0].Id, 'A primeira conta relacionada deveria ser a Child Account 2');
        System.assertEquals(childAccount1.Id, relatedAccounts[1].Id, 'A segunda conta relacionada deveria ser a Child Account 1');
        System.assertEquals(childAccount2.Id, relatedAccounts[2].Id, 'A terceira conta relacionada deveria ser a Child Account 2');
    }

    @isTest
    static void testGetRelatedAccounts_NullId() {
        Test.startTest();
        List<Account> relatedAccounts = ListRelatedAccountsController.getRelatedAccounts(null);
        Test.stopTest();

        System.assertEquals(0, relatedAccounts.size(), 'Deveria retornar uma lista vazia pq o Id da conta é nulo');
    }
}