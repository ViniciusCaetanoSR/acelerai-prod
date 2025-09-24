public without sharing class IntegrationSGCFlowService {
    @InvocableMethod(label='Send Opportunity Data to External API' description='Sends opportunity data to an external API via POST request.')
    public static void sendOpportunityData(List<sgcRequest> requests) {
        sgcRequest request = requests[0];

        String requestBody = JSON.serialize(request);

        sendOpportunityDataToExternalAPI(requestBody);
    }

    public static void sendData(List<sObject> payload, String type) {
        sgcRequest request = new sgcRequest();

        String requestBody;

        request.type = type;
        request.payload = payload;
        requestBody = JSON.serialize(request);

        sendOpportunityDataToExternalAPI(requestBody);
    }

    @future(callout=true)
    public static void sendOpportunityDataToExternalAPI(String requestBody) {
        sgcRequest request = (sgcRequest) JSON.deserialize(requestBody, sgcRequest.class);
        String relatedRecordIds = '';

        for (sObject obj : request.payload) {
            relatedRecordIds += obj.Id + '; ';
        }

        try {
            IntegrationSGC__c rec = IntegrationSGC__c.getValues('SGC');

            if (rec == null)
                return;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(rec.Endpoint__c);

            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-access-token', rec.Token__c);

            req.setBody(requestBody);
            req.setTimeout(120000);

            Http http = new Http();
            System.debug('Sucess, requestBody: ' + requestBody);
            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                System.debug('Failed to send data | Método: sendOpportunityDataToExternalAPI : ' + res.getBody());
                LoggerUtility.createLogIntegrationException(res, relatedRecordIds, requestBody, 'SGC', 'sendOpportunityDataToExternalAPI'); 

            } else {
                System.debug('Sucess | Método: sendOpportunityDataToExternalAPI | return data: ' + res);
                LoggerUtility.createLogIntegrationSuccess(res, relatedRecordIds, requestBody, 'SGC', 'sendOpportunityDataToExternalAPI');
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, relatedRecordIds, 'sendOpportunityDataToExternalAPI');
        }
    }

    public class sgcRequest {
        @InvocableVariable
        public String type;
        @InvocableVariable
        public List<sObject> payload;
    }
}