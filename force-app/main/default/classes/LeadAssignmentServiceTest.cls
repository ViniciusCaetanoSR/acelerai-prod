@isTest
public class LeadAssignmentServiceTest {
    private static MockLeadRepository mockRepository;
    
    @TestSetup
    public static void setupTestData() {
        leadutils.generateMarketingLeads(1);
        
    }
    
    @isTest
    public static void testAssignMidiaRecordType_NoRecordtType() {
        
        mockRepository = new MockLeadRepository();
        LeadAssignmentService assignmentService = new LeadAssignmentService(mockRepository);
        
        List<Lead> leads = [SELECT Id FROM Lead];
        
        Test.startTest();
        assignmentService.assignMidiaRecordType(leads);
        Test.stopTest();
    }
}