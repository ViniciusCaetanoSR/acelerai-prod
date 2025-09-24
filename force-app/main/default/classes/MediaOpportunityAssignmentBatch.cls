public class MediaOpportunityAssignmentBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Name 
            FROM Opportunity 
            WHERE CreatedDate = N_DAYS_AGO:7
            AND Owner.Name IN ('Marcos Torres', 'Luis Armando')
            AND Funnel__c = 'Mídias Vendas'
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
       try {
            LoggerUtility.createLogIntegrationSuccess(new HttpResponse(), ' Opportunities Processed', ' Processando ' + opportunities.size() + ' oportunidades', 'MediaOpportunityAssignmentBatch', 'execute');
            OpportunityService.assignOpportunitiesMediaToMembers(opportunities);
       } catch (Exception e) {
            System.debug('Exceção ao atualizar oportunidades ' + e.getMessage());
            LoggerUtility.createLogException(e, 'Batch Process', 'execute');
       } 
    }

    public void finish(Database.BatchableContext BC) {

    }
}