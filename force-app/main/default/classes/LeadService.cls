public with sharing class LeadService {
    private final LeadRepository repository;
    private final LeadAssignmentService assignmentService;
    private final LeadValidationService validationService;
    private final OpportunityService OpportunityService;

    public LeadService() {
        this.repository = new LeadRepository();
        this.assignmentService = new LeadAssignmentService();
        this.validationService = new LeadValidationService();
        this.OpportunityService = new OpportunityService();
    }

    public void processDuplicateLeads(List<Lead> newLeads) {
        System.debug('chamou o processDuplicateLeads');

        Set<String> newLeadEmails = new Set<String>();
        List<Lead> leadsToDelete = new List<Lead>();
        List<Lead> leadsToUpdate = new List<Lead>();

        for (Lead newLead : newLeads) {
            if (String.isNotBlank(newLead.Email__c)) {
                newLeadEmails.add(newLead.Email__c);
            }
        }

        try {
            List<Lead> existingLeads = repository.findByEmails(newLeadEmails);
            System.debug('retornou LeadRepository. existingLeads:' + existingLeads);

            existingLeads = validationService.sortLeadsByOpenStatus(existingLeads);

            if (!existingLeads.isEmpty()) {
                System.debug('identificou o lead existente');

                for (Lead newLead : newLeads) {
                    for (Lead existingLead : existingLeads) {
                        if (newLead.Email__c == existingLead.Email__c) {
                            System.debug('vai chamar o handleDuplicatedLead');
                            validationService.handleDuplicateLead(newLead, existingLead, leadsToDelete, leadsToUpdate);
                            break;
                        }
                    }
                }

                repository.deleteLeads(leadsToDelete);
                repository.updateLeads(leadsToUpdate);
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'LeadService.processDuplicateLeads');
            throw e;
        }
    }

    public void leadMetaIntegration(List<Lead> leads, Map<Id, Lead> oldLeadMap) {
        List<Id> leadsIntegration = new List<Id>();

        for (Lead lead : leads) {
            if (lead.Metalead_id__c != null) {
                leadsIntegration.add(lead.Id);
            }

            Lead oldLead = oldLeadMap.get(lead.Id);
            if (oldLead != null && oldLead.Metalead_id__c != null && lead.Status != oldLead.Status) {
                leadsIntegration.add(lead.Id);
            }
        }
        if (!leadsIntegration.isEmpty()) {
            try {
                MetaIntegration.sendLeadToMeta(leadsIntegration);
            } catch (Exception e) {
                System.debug('Erro ao integrar Leads:  ' + e.getMessage());
            }
        }
    }

    public void queueDuplicateLeadRemoval(List<Lead> leadsList) {
        Set<Id> duplicatedLeadsSet = new Set<Id>();

        try {
            List<Lead> duplicatedLeadsList = [SELECT Id, IsDuplicate__c, RecordType.Name FROM Lead WHERE Id IN :leadsList AND RecordType.Name != 'Mentoria'];

            if (!duplicatedLeadsList.isEmpty()) {
                for (Lead lead : duplicatedLeadsList) {
                    if (lead.Id != null & lead.IsDuplicate__c == true) {
                        duplicatedLeadsSet.add(lead.Id);
                    }
                }
            }

            if (!duplicatedLeadsSet.isEmpty()) {
                System.enqueueJob(new LeadDuplicatedRemover(duplicatedLeadsSet));
            }
        } catch (Exception e) {
            System.debug('Exceção lançada em queueDuplicateLeadRemoval: ' + e.getMessage());
        }
    }

    public void setMidiaRecordType(List<Lead> newLeads) {
        assignmentService.assignMidiaRecordType(newLeads);
    }

    public void validateLeads(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        validationService.validateCNPJ(newLeads, oldLeadsMap);
        validationService.syncAddressFields(newLeads, oldLeadsMap);
        validationService.refreshDateFields(newLeads, oldLeadsMap);
    }

    public void processDuplicateLeadsAndOpportunities(List<Lead> newLeads) {
        opportunityService.checkDuplicateLeadsAndOpportunitiesVarejo(newLeads);
        opportunityService.checkduplicateLeadAndOpportunitiesVendaRd(newLeads);
    }
}