public with sharing class LeadValidationService {
    public void validateCNPJ(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        for (Lead lead : newLeads) {
            String newCnpj = lead.CNPJ__c;
            String oldCnpj = oldLeadsMap != null && oldLeadsMap.containsKey(lead.Id) ? oldLeadsMap.get(lead.Id).CNPJ__c : null;

            if (newCnpj != oldCnpj && String.isNotBlank(newCnpj)) {
                if (!LeadDomain.checkCNPJValidity(newCnpj)) {
                    lead.CNPJ__c.addError('CNPJ inválido. Por favor, insira um CNPJ válido e com 14 dígitos.');
                } else {
                    lead.CNPJ__c = LeadDomain.maskCNPJ(newCnpj);
                }
            }
        }
    }

    public void syncAddressFields(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        for (Lead newLead : newLeads) {
            String newState = newLead.State;
            String newCity = newLead.City;
            String oldState = oldLeadsMap != null ? oldLeadsMap.get(newLead.Id)?.State : null;
            String oldCity = oldLeadsMap != null ? oldLeadsMap.get(newLead.Id)?.City : null;

            if ((newState != null && !newState.equals(oldState)) || (newCity != null && !newCity.equals(oldCity))) {
                newLead.CompanyUF__c = newState;
                newLead.Cidade__c = newCity;
            }
        }
    }

    public void refreshDateFields(List<Lead> leads, Map<Id, Lead> oldLeadsMap) {
        for (Lead lead : leads) {
            lead.LastModifiedDate__c = Datetime.now();
            if (oldLeadsMap == null) {
                lead.CreationDate__c = Datetime.now();
            }
        }
    }

    public void handleDuplicateLead(Lead newLead, Lead existingLead, List<Lead> leadsToDelete, List<Lead> leadsToUpdate) {
        Id recordTypeMentoria = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Mentoria').getRecordTypeId();

        if (newLead.RecordTypeId == recordTypeMentoria) {
            return;   // Pula leads do tipo Mentoria
        }

        System.debug('chamou o handleDuplicated');
        if (newLead == null || existingLead == null) {
            return;
        }

        // 1. O lead existente veio da mesma fonte "Aceleraí Performance" → marcar o lead novo como perdido
        if (existingLead.LeadSource == 'Aceleraí Performance') {
            System.debug('existingLead.LeadSource: ' + existingLead.LeadSource);

            newLead.Status = 'Perdido';
            newLead.Motivo_da_Perda__c = 'Lead Performance Duplicado';
            return; // nada mais a fazer
        }

        // 2. O lead existente está em Histórico
        if (existingLead.Status == 'Histórico') {
            if (String.isNotBlank(existingLead.referencia_base_antiga_lead__c)) {
                // Caso possua referência antiga, deletamos o lead o velho e copiamos meta‑dados
                leadsToDelete.add(existingLead);
                newLead.referencia_base_antiga_lead__c = existingLead.referencia_base_antiga_lead__c;
                newLead.EntryAttempts__c = LeadDomain.increaseByOne(newLead.EntryAttempts__c);
            } else {
                // Caso contrário, fazemos merge e ressuscitamos o lead histórico
                mergeNewLeadData(existingLead, newLead);
                newLead.isDuplicate__c = true;
                existingLead.EntryAttempts__c = LeadDomain.increaseByOne(existingLead.EntryAttempts__c);
                existingLead.Status = 'Pré Cadastro';
                leadsToUpdate.add(existingLead);
            }
            return;
        }

        // 3. Lead existente em um pipeline mas não "Lead Score" nem "Perdido"
        if (existingLead.Status != 'Lead Score' && existingLead.Status != 'Perdido') {
            if (LeadDomain.hasAnyUTMData(newLead)) {
                syncUTMData(existingLead, newLead);
            }
            newLead.isDuplicate__c = true;
            existingLead.EntryAttempts__c = LeadDomain.increaseByOne(existingLead.EntryAttempts__c);
            leadsToUpdate.add(existingLead);
            return;
        }

        // 4. Qualquer outro caso → apenas incrementa a contagem de tentativas no novo lead
        newLead.EntryAttempts__c = LeadDomain.increaseByOne(newLead.EntryAttempts__c);
    }

    public void mergeNewLeadData(Lead existingLead, Lead newLead) {
        existingLead.Segmento__c = String.isNotBlank(newLead.Segmento__c) ? newLead.Segmento__c : existingLead.Segmento__c;
        existingLead.Phone = String.isNotBlank(newLead.Phone) ? newLead.Phone : existingLead.Phone;
        existingLead.MetaLead_id__c = String.isNotBlank(newLead.Metalead_id__c) ? newLead.Metalead_id__c : existingLead.MetaLead_id__c;
        existingLead.Fbclid__c = String.isNotBlank(newLead.Fbclid__c) ? newLead.Fbclid__c : existingLead.Fbclid__c;
        existingLead.Gclid__c = String.isNotBlank(newLead.Gclid__c) ? newLead.Gclid__c : existingLead.Gclid__c;

        if (LeadDomain.hasAnyUTMData(newLead)) {
            syncUTMData(existingLead, newLead);
        }
    }

    public void syncUTMData(Lead existingLead, Lead newLead) {
        existingLead.UTM_Campaign__c = newLead.UTM_Campaign__c;
        existingLead.UTM_Content__c = newLead.UTM_Content__c;
        existingLead.UTM_Medium__c = newLead.UTM_Medium__c;
        existingLead.UTM_Source__c = newLead.UTM_Source__c;
        existingLead.UTM_Term__c = newLead.UTM_Term__c;
        existingLead.Website__c = newLead.Website__c;
    }

    public List<Lead> sortLeadsByOpenStatus(List<Lead> leads) {
        List<String> closedStatus = new List<String>{ 'Perdido', 'Lead Score' };
        List<Lead> openLeads = new List<Lead>();
        List<Lead> closedLeads = new List<Lead>();

        for (Lead lead : leads) {
            if (closedStatus.contains(lead.Status)) {
                closedLeads.add(lead);
            } else {
                openLeads.add(lead);
            }
        }
        openLeads.addAll(closedLeads);
        return openLeads;
    }
}