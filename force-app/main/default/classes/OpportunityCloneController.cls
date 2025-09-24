public with sharing class OpportunityCloneController {

    @AuraEnabled
    public static Opportunity cloneOpportunityWithSBT(Id oppId){
        try {
            Set<Id> opportunityIds = new Set<Id> {oppId};
            Opportunity originalOpp = OpportunitySelector.selectByOpportunityId(opportunityIds)[0];

            if (originalOpp.Funnel__c != 'Varejo' || originalOpp.Media__c != null){
                throw new AuraHandledException('A oportunidade não é do funil varejo ou já tem mídia');
            }

            Opportunity newOpp = originalOpp.clone(false, true, false, false);
            newOpp.Name = originalOpp.Name + ' (Varejo SBT)';
            newOpp.AccountId = originalOpp.AccountId;
            newOpp.OwnerId = originalOpp.OwnerId;
            newOpp.StageName = 'Aprovado';
            newOpp.RelatedOpportunity__c = originalOpp.Id;
            //newOpp.Lead__c = originalOpp.Lead__c;

            if (newOpp.Media__c == null) {
                newOpp.Media__c = 'sbt';
            }

            newOpp.ClonedWithMediaSBT__c = true;
            System.debug('Campo ClonedWithMediaSBT: ' + newOpp.ClonedWithMediaSBT__c);
            System.debug('Campo Lead__c [depois]: ' + newOpp.Lead__c);

            insert newOpp;

            return newOpp;
            
        } catch (AuraHandledException e) {
            throw e;

        } catch (Exception e) {
            system.debug('Erro: ' + e.getMessage());
            throw new AuraHandledException('Erro ao clonar a Oportunidade');
        }
    }

    @AuraEnabled
    public static Opportunity cloneOpportunityRenovacao(Id oppId){
        try {
            Set<Id> opportunityIds = new Set<Id> {oppId};
            Opportunity originalOpp = OpportunitySelector.selectByOpportunityId(opportunityIds)[0];
            
            if ((originalOpp.RecordType.DeveloperName == 'Varejo' && !(originalOpp.StageName == 'Venda Futura' || originalOpp.StageName == 'Ganho' || originalOpp.StageName == 'Ganho Pagamento Futuro')) || (originalOpp.RecordType.DeveloperName == 'VendaRD' && originalOpp.StageName != 'Ganho RD')) {
                
                throw new AuraHandledException('Esta oportunidade não pode ser clonada para "Renovação".');
            }

            Opportunity newOpp = originalOpp.clone(false, true, false, false);
            newOpp.Name = originalOpp.Name + ' (Renovação)';
            newOpp.Fbclid__c = originalOpp.Fbclid__c; 
            newOpp.Metalead_id__c = originalOpp.Metalead_id__c;
            newOpp.Gclid__c = originalOpp.Gclid__c; 
            newOpp.Pol_tica_Comercial__c = null;
            newOpp.ContractStartDate__c = null;
            newOpp.EndOfContractDate__c = null;
            newOpp.SaleType__c = 'Renovação';
            newOpp.StageName = 'Qualificação';

            insert newOpp;

            return newOpp;
        } catch (AuraHandledException e) {
            throw e;

        } catch (Exception e) {
            system.debug('Erro: ' + e.getMessage());
            throw new AuraHandledException('Erro ao clonar a Oportunidade');
        }
    }

    @AuraEnabled
    public static Opportunity cloneOpportunityUpsell(Id oppId){
        try {
            Set<Id> opportunityIds = new Set<Id> {oppId};
            Opportunity originalOpp = OpportunitySelector.selectByOpportunityId(opportunityIds)[0];

            if ((originalOpp.RecordType.DeveloperName == 'Varejo' && !(originalOpp.StageName == 'Venda Futura' || originalOpp.StageName == 'Ganho' || originalOpp.StageName == 'Ganho Pagamento Futuro')) || (originalOpp.RecordType.DeveloperName == 'VendaRD' && originalOpp.StageName != 'Ganho RD')) {

                throw new AuraHandledException('Esta oportunidade não pode ser clonada para "Upsell".');
            }

            Opportunity newOpp = originalOpp.clone(false, true, false, false);
            newOpp.Name = originalOpp.Name + ' (Upsell)';
            newOpp.Fbclid__c = originalOpp.Fbclid__c; 
            newOpp.Metalead_id__c = originalOpp.Metalead_id__c; 
            newOpp.Gclid__c = originalOpp.Gclid__c;
            newOpp.Pol_tica_Comercial__c = null;
            newOpp.ContractStartDate__c = null;
            newOpp.EndOfContractDate__c = null;
            newOpp.SaleType__c = 'Upsell';
            newOpp.StageName = 'Qualificação';

            insert newOpp;

            return newOpp;
        } catch (AuraHandledException e) {
            throw e;

        } catch (Exception e) {
            system.debug('Erro: ' + e.getMessage());
            throw new AuraHandledException('Erro ao clonar a Oportunidade');
        }
    }
}