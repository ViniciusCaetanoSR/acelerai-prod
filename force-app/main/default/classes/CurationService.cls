public with sharing class CurationService {

    public static void handleCuration(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap) {
        List<Curadoria__c> curationsToInsert = new List<Curadoria__c>();
        Set<Id> opportunityIdsToLost = new Set<Id>();
        Set<Id> opportunityIdsToOpen = new Set<Id>();
        Set<Id> opportunityIdsRestorePreviousFase = new Set<Id>();

        // Coletar todos Ids de Oportunidades;
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            opportunityIds.add(opportunity.Id);
        }

        // Verificar se a Oportunidade possui Curadoria;
        Map<Id, Curadoria__c> existingCurationsMap = new Map<Id, Curadoria__c>();
        for (Curadoria__c curadoria : [SELECT Id, Opportunity__c, Fase__c, FaseAnterior__c FROM Curadoria__c WHERE Opportunity__c IN :opportunityIds]) {
            existingCurationsMap.put(curadoria.Opportunity__c, curadoria);
        }

        for (Opportunity opp : opportunities) {
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);

            if (opp.StageName == oldOpp.StageName) {
                continue;
            }
            // Criar curadoria para oportunidades fechadas ou Venda Futura, incluindo transições de Venda Futura para Ganho/Ganho Pagamento Futuro;
            if (opp.StageName == 'Ganho' || opp.StageName == 'Ganho Pagamento Futuro' || opp.StageName == 'Venda Futura') {
                Curadoria__c curation = createCuration(opp, existingCurationsMap);
                if (curation != null) {
                    curationsToInsert.add(curation);
                }
                // Se possuir curadoria em fase = "Oportunidade aberta", alterar a fase para fase anterior;
                else {
                    Curadoria__c existing = existingCurationsMap.get(opp.Id);
                    if (existing != null && existing.Fase__c == 'Oportunidade aberta varejo') {
                        opportunityIdsRestorePreviousFase.add(opp.Id);
                    }
                }
            }
            // Atualizar curadoria para Perdido quando uma oportunidade fechada é perdida;
            if (opp.StageName == 'Perdido') {
                opportunityIdsToLost.add(opp.Id);
            }
            // Atualizar curadoria para a fase "Oportunidade aberta" ao mover oportunidade para um estágio aberto (exceto Perdido e transições para Ganho/Ganho Pagamento Futuro);
            else if (opp.StageName != 'Ganho' && opp.StageName != 'Ganho Pagamento Futuro' && opp.StageName != 'Venda Futura' && opp.StageName != 'Perdido') {
                opportunityIdsToOpen.add(opp.Id);
            }
        }

        if (!curationsToInsert.isEmpty()) {
            System.debug('Debug x: curationsToInsert:' + curationsToInsert);
            insert curationsToInsert;
        }
        if (!opportunityIdsToLost.isEmpty()) {
            System.debug('debug x: opportunityIdsToLost: ' + opportunityIdsToLost);
            updateCurationFase(opportunityIdsToLost, 'Perdido varejo');
        }
        if (!opportunityIdsToOpen.isEmpty()) {
            System.debug('debug x: opportunityIdsToOpen: ' + opportunityIdsToOpen);
            updateCurationFase(opportunityIdsToOpen, 'Oportunidade aberta varejo');
        }
        if (!opportunityIdsRestorePreviousFase.isEmpty()) {
            System.debug('debug x: opportunityIdsRestorePreviousFase: ' + opportunityIdsRestorePreviousFase);
            restorePreviousFase(opportunityIdsRestorePreviousFase);
        }
    }

    private static Curadoria__c createCuration(Opportunity opportunity, Map<Id, Curadoria__c> existingCurationsMap) {
        try {
            if (!existingCurationsMap.containsKey(opportunity.Id)) {
                Curadoria__c curation = new Curadoria__c();
                curation.Name = opportunity.Name;
                curation.Opportunity__c = opportunity.Id;
                return curation;
            }
            return null;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Erro ao criar Curadoria: ' + e.getMessage());
            return null;
        }
    }

    private static void updateCurationFase(Set<Id> opportunityIds, String newFase) {
        try {
            List<Curadoria__c> curationsToUpdate = [SELECT Id, Name, Fase__c, FaseAnterior__c FROM Curadoria__c WHERE Opportunity__c IN :opportunityIds];
            if (!curationsToUpdate.isEmpty()) {
                System.debug('Debug x: curationsToUpdate: ' + curationsToUpdate);
                for (Curadoria__c curation : curationsToUpdate) {
                    if (newFase == 'Oportunidade aberta varejo') {
                        curation.FaseAnterior__c = curation.Fase__c;
                    }
                    curation.Fase__c = newFase;
                }
                update curationsToUpdate;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Erro ao atualizar curadoria: ' + e.getMessage());
        }
    }

    private static void restorePreviousFase(Set<Id> opportunityIds) {
        try {
            List<Curadoria__c> curations = [SELECT Id, Opportunity__c, Fase__c, FaseAnterior__c FROM Curadoria__c WHERE Opportunity__c IN :opportunityIds AND Fase__c = 'Oportunidade aberta varejo'];
            if (!curations.isEmpty()) {
                for (Curadoria__c curation : curations) {
                    System.debug('Debug x: curation.FaseAnterior__c: ' + curation.FaseAnterior__c);

                    curation.Fase__c = curation.FaseAnterior__c == 'Perdido varejo'
                        ? 'Novo'
                        : curation.FaseAnterior__c;

                    curation.FaseAnterior__c = null;
                }
                update curations;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Erro ao restaurar fase: ' + e.getMessage());
        }
    }
}