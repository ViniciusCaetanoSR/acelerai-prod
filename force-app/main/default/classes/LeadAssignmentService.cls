public with sharing class LeadAssignmentService {
    private LeadRepository.ILeadRepository repository;

    public LeadAssignmentService() {
        this(new LeadRepository());
    }

    public LeadAssignmentService(LeadRepository.ILeadRepository repository) {
        if (repository == null) {
            throw new AssignmentServiceException('O repositório não pode ser nulo.');
        }
        this.repository = repository;
    }

    private Boolean isEligibleForMidiasRecordType(Lead lead) {
        return lead != null && lead.Funil__c == 'Mídias Vendas';
    }

    public void assignMidiaRecordType(List<Lead> newLeads) {
        if (newLeads == null || newLeads.isEmpty()) {
            return;
        }

        try {
            RecordType midiasRecordType = repository.findRecordTypeByDeveloperName('Midias');
            if (midiasRecordType == null) {
                LoggerUtility.createLog('RecordType "Midias" não encontrado.', 'LeadAssignmentService.setRecordType');
                return;
            }

            for (Lead lead : newLeads) {
                if (isEligibleForMidiasRecordType(lead)) {
                    lead.RecordTypeId = midiasRecordType.Id;
                }
            }
        } catch (Exception e) {
        }
    }

    public class AssignmentServiceException extends Exception {
    }
}