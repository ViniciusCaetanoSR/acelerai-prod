/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TeamsGetUserConsentControllerTest {

    @IsTest
    static void testBuildUserConsentUrlSuccess() {
        Teams_API_Settings__mdt mockMetadata = new Teams_API_Settings__mdt();
        mockMetadata.Client_Id__c = 'test-client-id';
        mockMetadata.Redirect_URI__c = 'https://test.salesforce.com/redirect';
        mockMetadata.Scope__c = 'Calendars.ReadWrite OnlineMeetings.Read';

        TeamsGetUserConsentController.metadataOverride = mockMetadata;

        Test.startTest();
        String response = TeamsGetUserConsentController.buildUserConsentUrl();
        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assert(response.contains('client_id=test-client-id'));
        System.assert(response.contains('redirect_uri=https%3A%2F%2Ftest.salesforce.com%2Fredirect'));
        System.assert(response.contains(UserInfo.getUserId()));
    }

    @IsTest
    static void testBuildUserConsentUrlError() {
        TeamsGetUserConsentController.metadataOverride = null;

        Test.startTest();
        String response = TeamsGetUserConsentController.buildUserConsentUrl();
        Test.stopTest();

        System.assertNotEquals(null, response);
    }
}