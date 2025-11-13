@isTest(SeeAllData=true)
private class TeamsHelperTest {
    @isTest
    static void testGetApiMetadataFound() {
        Teams_API_Settings__mdt result = TeamsHelper.getApiMetadata('TeamsAPIMetadata');
        System.assertNotEquals(null, result, 'Deveria retornar um registro válido');
    }

    @isTest
    static void testGetApiMetadataNullParam() {
        Teams_API_Settings__mdt result = TeamsHelper.getApiMetadata(null);
        System.assertEquals(null, result, 'apiName é null, deveria retornar null');
    }

    @isTest
    static void testGetApiMetadataNotFound() {
        Teams_API_Settings__mdt result = TeamsHelper.getApiMetadata('Inexistente');
        System.assertNotEquals(null, result, 'Deveria retornar um objeto vazio em caso de exceção');
        System.assertEquals(null, result.Client_Id__c, 'O objeto retornado deveria estar vazio');
    }
}