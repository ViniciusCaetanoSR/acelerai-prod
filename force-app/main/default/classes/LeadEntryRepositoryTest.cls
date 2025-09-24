@isTest
public with sharing class LeadEntryRepositoryTest {

    @isTest
    static void testFindLeadEntryByEmail(){
        Account testPartnerAccount = new Account(Name='Test Partner',
            CNPJ__c = '42113212000125',
            BillingStreet = 'Rua das Flores, 123',
            BillingCity = 'São Paulo',
            BillingState = 'SP',
            BillingPostalCode = '01001-000',
            BillingCountry = 'Brasil',
            CompanyName__c = 'Test Account 1'
        );
        insert testPartnerAccount;
        
        List<LeadEntry__c> testEntries = new List<LeadEntry__c>{
            new LeadEntry__c(
                Name = 'Seulgi',
                Email__c = 'Seulgi0108251109@redvelvet.com',
                PartnerAccount__c = testPartnerAccount.Id
            )
        };        
        insert testEntries;
        
        Set<String> emails = new Set<String>();
        emails.add('Seulgi0108251109@redvelvet.com');

        LeadEntryRepository repository = new LeadEntryRepository();
       
        Test.startTest();
        List<LeadEntry__c> result = repository.findLeadEntryByEmail(emails);
        Test.stopTest();
        
        System.assertEquals('Seulgi', result[0].Name);
        System.assertEquals('Seulgi0108251109@redvelvet.com', result[0].Email__c);
    }
}