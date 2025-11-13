/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 10-09-2025
 * @last modified by  : Vinícius Caetano
 **/
public class AutoConvertLeads {

    private static LeadAssignmentService assignmentService;

    @InvocableMethod(label='Convert Lead' description='Class responsible for converting Leads')
    public static void convertLeads(List<Lead> leadsToConvert) {

        if (leadsToConvert == null || leadsToConvert.isEmpty()) {
            System.debug('Nenhum lead para converter.');
            return;
        }

        Boolean isAgencia = checkLeadTypeAgencia(leadsToConvert);
        Boolean isMentoria = checkLeadTypeMentoria(leadsToConvert);

        if (isAgencia) {
            System.debug('Entrou na atribuição');
            AssignmentGroupMemberService.distributeLeadsToGroupForConversion(leadsToConvert);
        }

        if (isMentoria) {
            System.debug(' DEBUG X: Entrou na atribuição + ISMENTORIA');

            AssignmentGroupMemberService.distributeLeadsToGroupForConversion(leadsToConvert);
        }

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

                if (isAgencia) {
                    System.debug('Debug x: ENTROU NO SHARE OPPORTUNITY');
                    shareConvertedOpportunities(results);
                }

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

    private static Boolean checkLeadTypeAgencia(List<Lead> leads) {
        Set<Id> leadOwnerIds = new Set<Id>();
        for (Lead curentLead : leads) {
            leadOwnerIds.add(curentLead.OwnerId);
        }

        List<User> usersAgencia = [SELECT Id, RotearOportunidade__c FROM User WHERE RotearOportunidade__c = TRUE AND Id IN :leadOwnerIds];

       if (usersAgencia.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }

    private static Boolean checkLeadTypeMentoria(List<Lead> leads) {
        System.debug('Entrou no método checkLeadTypeMentoria');
        Id recordTypeMentoria = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Mentoria').getRecordTypeId();
        for (Lead currentLead : leads) {
            if (currentLead.RecordTypeId == recordTypeMentoria) {
                return true;
            }
        }
        return false;
    }

    private static void shareConvertedOpportunities(List<Database.LeadConvertResult> leadsConvertAgencia) {
        List<OpportunityShare> sharesToInsert = new List<OpportunityShare>();

        User userAgencia = [SELECT Id FROM User WHERE RotearOportunidade__c = TRUE LIMIT 1];
        Id userId = userAgencia.Id;

        for (Database.LeadConvertResult result : leadsConvertAgencia) {
            if (result.isSuccess() && result.getOpportunityId() != null) {
                OpportunityShare share = new OpportunityShare();
                share.OpportunityId = result.getOpportunityId();
                share.UserOrGroupId = userId;
                share.OpportunityAccessLevel = 'Read';
                share.RowCause = Schema.OpportunityShare.RowCause.Manual;
                sharesToInsert.add(share);
            }
        }

        if (!sharesToInsert.isEmpty()) {
            insert sharesToInsert;
        }
    }
}