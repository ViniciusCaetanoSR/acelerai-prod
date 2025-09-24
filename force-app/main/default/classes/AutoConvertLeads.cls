public class AutoConvertLeads {

    private static LeadAssignmentService assignmentService;

    @InvocableMethod(label='Convert Lead' description='Class responsible for converting Leads')
    public static void convertLeads(List<Lead> leadsToConvert) {

        if (leadsToConvert == null || leadsToConvert.isEmpty()) {
            System.debug('Nenhum lead para converter.');
            return;
        }

        assignmentService = new LeadAssignmentService();
        //Atribui para um Grupo de atribuição Lead quando o perfil do usuário for igual a Triagem antes de converter
        //leadsToConvert = assignmentService.distributeToGroupMember(leadsToConvert);

        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();

        for (Lead lead : leadsToConvert) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setConvertedStatus('Lead Score');
            leadConverts.add(lc);
        }

        if (!leadConverts.isEmpty()) {
            try {
                List<Database.LeadConvertResult> results = Database.convertLead(leadConverts, false);

                for (Database.LeadConvertResult result : results) {
                    if (result.isSuccess()) {
                        System.debug('Lead convertido com sucesso: ' + result.getLeadId());
                    } else {
                        System.debug('Falha ao converter o lead: ' + result.getLeadId() + '. Erro: ' + result.getErrors());
                    }
                }
            } catch (Exception e) {
                List <String> relatedRecordIdsList = new List<String>();
                for (Database.LeadConvert lead : leadConverts) {relatedRecordIdsList.add(lead.getLeadId());}
                LoggerUtility.createLogException(e, String.join(relatedRecordIdsList, ','), 'convertLeads');
            }
        }
    }
}