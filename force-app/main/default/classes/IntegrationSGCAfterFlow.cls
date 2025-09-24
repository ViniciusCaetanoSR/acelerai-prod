public class IntegrationSGCAfterFlow {
    @InvocableMethod(label='Send Data to SGC' description='The class send data to the SGC integration')
    public static void sendDataToSgc(List<Lead> newLeads) {
        Set<Id> leadId = new Set<Id>();
        for (Lead lead : newLeads) {
            leadId.add(lead.Id);
        }

        for (Lead lead : newLeads) {
            System.debug('<><><>Lead: ' + lead.isDuplicate__c + ' | ' + lead.OwnerId);
        }

        List<Lead> leads = [
            SELECT Id, Name, Phone, Email, Owner.Email, Status, Company, Segmento__c, WhatsYourInstagram__c, City, State
            FROM Lead
            WHERE Id IN :leadId AND isDuplicate__c = FALSE
        ];

        if (!leads.isEmpty()) {
            try {
                IntegrationSGCFlowService.sendData(leads, 'Lead');
                System.debug('a integração SGC está sendo chamada!');
                System.debug('Owner: ' + leads[0].Owner.Email);
            } catch (Exception e) {
                System.debug('Mensagem do erro da integração SGC' + e.getMessage());
                System.debug('Linha do erro da integração SGC' + e.getLineNumber());
                System.debug('Causa do erro da integração SGC' + e.getCause());
            }
        }
    }
}