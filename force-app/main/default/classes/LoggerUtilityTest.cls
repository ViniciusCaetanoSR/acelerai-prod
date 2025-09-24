@IsTest
public class LoggerUtilityTest {
    @IsTest
    static void testCreateLogException() {
        Lead invalidLead = new Lead(
            LastName = 'InvalidLead',
            Company = 'TestCompany',
            Email = 'invalidEmailFormat'
        );
        
        Test.startTest();
        try {
            insert invalidLead;
        } catch (Exception e) {
            LoggerUtility.createLogException(e, 'Teste', 'Método: testCreateLogException');
        }
        Test.stopTest();
        
        Log__c[] logRecords = [SELECT Id, ErrorMessage__c, StackTrace__c, ExceptionType__c, Cause__c, User__c, LineNumber__c, MethodName__c, FileName__c FROM Log__c];
        System.assertEquals(1, logRecords.size(), 'Um registro de log de exeção em geral deve ter sido criado.');
    }
    
    @isTest
    static void testCreateLogIntegrationSuccess() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"success":"Sucesso no teste da integração"}');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('Bad Request');
        
        String relatedRecordId = '001000000000123';
        String requestBodyJson = '{"field":"value"}';
        
        Test.startTest();
        LoggerUtility.createLogIntegrationSuccess(mockResponse, relatedRecordId, requestBodyJson, 'Teste', 'Método: testCreateLogIntegrationSuccess');
        Test.stopTest();
        
        Log__c[] logs = [SELECT Id, ErrorMessage__c, User__c, RelatedRecord__c, RequestBody__c
                         FROM Log__c
                         WHERE RelatedRecord__c = :relatedRecordId];
        
        System.assertEquals(1, logs.size(), 'Um registro de log de sucesso deveria ter sido inserido.');
        Log__c log = logs[0];
        System.assertEquals('{"field":"value"}', log.RequestBody__c, 'O corpo da requisição deveria ter sido registrado no campo RequestBody__c.');
    } 

    @isTest
    static void testCreateLogIntegrationException() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"error":"Some error occurred"}');
        mockResponse.setStatusCode(400);
        mockResponse.setStatus('Bad Request');
        
        String relatedRecordId = '001000000000123';
        String requestBodyJson = '{"field":"value"}';
        
        Test.startTest();
        LoggerUtility.createLogIntegrationException(mockResponse, relatedRecordId, requestBodyJson, 'Teste', 'Método: testCreateLogIntegrationException');
        Test.stopTest();
        
        Log__c[] logs = [SELECT Id, ErrorMessage__c, StackTrace__c, User__c, RelatedRecord__c, RequestBody__c
                         FROM Log__c
                         WHERE RelatedRecord__c = :relatedRecordId];
        
        System.assertEquals(1, logs.size(), 'Um registro de log de exceção da integração deveria ter sido inserido.');
        Log__c log = logs[0];
        System.assertEquals('{"field":"value"}', log.RequestBody__c, 'O corpo da requisição deveria ter sido registrado no campo RequestBody__c.');
    }     
}