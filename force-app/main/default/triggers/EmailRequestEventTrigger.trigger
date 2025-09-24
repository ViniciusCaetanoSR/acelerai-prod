trigger EmailRequestEventTrigger on EmailRequest__e (after insert) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    Set<Id> opportunityIds = new Set<Id>();

    for (EmailRequest__e event : Trigger.New) {
        opportunityIds.add(event.OpportunityId__c);
    }

    if(opportunityIds.size() > 0) {
        EmailService.sendEmailOpportunityProductInactive(opportunityIds);
    }
}