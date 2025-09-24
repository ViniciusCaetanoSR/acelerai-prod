@isTest
public with sharing class IntegrationSGCAfterFlowTest {
    @TestSetup
    static void makeData() {
        leadutils.generateLeads(1);
    }
    @isTest
    public static void sendDataToSgcTest() {
        List<Lead> leads = [SELECT Id FROM Lead];

        for (Lead lead : leads) {
            lead.OwnerId = '005N40000063lGgIAI';
        }
        update leads;
        leads = [SELECT Id, isDuplicate__c, OwnerId FROM Lead];
        IntegrationSGCAfterFlow.sendDataToSgc(leads);
    }
}