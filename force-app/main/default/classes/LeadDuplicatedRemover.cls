public class LeadDuplicatedRemover implements Queueable {
    private Set<Id> duplicateLeadIds;

    public LeadDuplicatedRemover(Set<Id> leadIds) {
        this.duplicateLeadIds = leadIds;
    }

    public void execute(QueueableContext context){

        try {
        List<Lead> searchLeadsToDelete = [SELECT Id, IsDuplicate__c FROM Lead WHERE Id IN :duplicateLeadIds];
        List<Lead> leadsToDelete = new List<Lead>();

            for (Lead lead : searchLeadsToDelete) {
                if (lead.Id != null && lead.IsDuplicate__c == true) {
                    leadsToDelete.add(lead);
                }
            }
            delete leadsToDelete;
            System.debug('Lead duplicado deletado! ');

        } catch (Exception e) {
            System.debug('Exception da remoção de lead duplicado: ' + e.getMessage());
        }
    }
}