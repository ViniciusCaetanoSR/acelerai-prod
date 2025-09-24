/**
 * @description       :
 * @author            : Vinícius Caetano
 * @group             :
 * @last modified on  : 02-06-2025
 * @last modified by  : Vinícius Caetano
**/
public with sharing class OpportunityTriggerHandler {
    public static void onBeforeInsert(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, List<Opportunity> newList, List<Opportunity> oldList) {
        OpportunityService.validatePhoneNumber(newList);
        OpportunityService.handleBeforeClone(newList);
        OpportunityService.applyNegotiationTemperatureRules(newList, oldMap);

    }

    public static void onBeforeUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, List<Opportunity> newList, List<Opportunity> oldList) {
        OpportunityService.validatePhoneNumber(newList);
        OpportunityService.validateOpportunityStageChangeGanho(newList, oldMap);
        OpportunityService.sendEmailProductInactive(newList, oldMap);
        OpportunityService.applyNegotiationTemperatureRules(newList, oldMap);
    }

    public static void onAfterInsert(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, List<Opportunity> newList, List<Opportunity> oldList) {
        OpportunityService.handleBeforeCloneContact(newList);
        OpportunityService.updateAccountDates(newList);
        OpportunityService.setContactIdWhenEmpty(newList);
    }

    public static void onAfterUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap, List<Opportunity> newList, List<Opportunity> oldList) {
        OpportunityService.updateAccountDates(newList);
        OpportunityService.opportunityMetaIntegration(newList, oldMap);

        try{
            OpportunityService.handleOpportunityChanges(newList, oldMap);
            System.debug('Chamou o onAfterUpdate');

        } catch (Exception e){
            System.debug('Erro ao chamar o handleOpportunityChanges');
        }
    }
}