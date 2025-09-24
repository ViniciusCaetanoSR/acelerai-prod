@isTest
public class LeadEntryTriggerHandlerTest {
    
    @IsTest
    static void testOnAfterInsert_ShouldCallPublishEventsFromEntries() {
        List<LeadEntry__c> testEntries = new List<LeadEntry__c>{
            new LeadEntry__c(
                Name = 'Lara',
                Email__c = 'lara@katseye.com',
                Phone__c = '11999999999'
            ),
            new LeadEntry__c(
                Name = 'Dani',
                Email__c = 'dani@katseye.com',
                Phone__c = '11888888888'
            )
        };       
               
        Test.startTest();
        String result = LeadEntryTriggerHandler.onAfterInsert(testEntries, new List<LeadEntry__c>());
        Test.stopTest();
        
        System.assertEquals('chamou LeadEntryTriggerHandler.AfterInsert', result);
    }   
}