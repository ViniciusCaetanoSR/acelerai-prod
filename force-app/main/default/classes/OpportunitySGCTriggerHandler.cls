public without sharing class OpportunitySGCTriggerHandler {
    public static void processOpportunities(List<Id> oppIds) {
        String query = buildOpportunityQuery(oppIds);
        List<SObject> results = Database.query(query);

        System.debug('Debug x: results: ' + results);

        if (!results.isEmpty()) {
            IntegrationSGCFlowService.sgcRequest request = new IntegrationSGCFlowService.sgcRequest();
            request.type = 'Opportunity';
            request.payload = results;

            List<IntegrationSGCFlowService.sgcRequest> requests = new List<IntegrationSGCFlowService.sgcRequest>();
            requests.add(request);

            System.debug('sendOpportunityData>>');
            IntegrationSGCFlowService.sendOpportunityData(requests);
        }
    }

    public static String buildOpportunityQuery(List<Id> oppIds){
        List<Opportunity_SGC_Field__mdt > fieldMetadataList = [SELECT FieldPath__c FROM Opportunity_SGC_Field__mdt];

        Set<String> fieldPaths = new Set<String>(); 

        for (Opportunity_SGC_Field__mdt metadata : fieldMetadataList) {
            if (!String.isEmpty(metadata.FieldPath__c)) {
                fieldPaths.add(metadata.FieldPath__c.trim());
            }
        }

        String fields = String.join(new List<String>(fieldPaths), ',');

        String query = 'SELECT ' + fields + ' FROM Opportunity' + 
                       ' WHERE AccountId != NULL' + 
                       ' AND RecordType.Name = \'Varejo\' ' +
                       ' AND Funnel__c != \'Mídias Vendas\'' +
                       ' AND Id IN :oppIds';

        return query; 
    }
}