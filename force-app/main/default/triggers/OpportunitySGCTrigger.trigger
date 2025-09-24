trigger OpportunitySGCTrigger on Opportunity (after update, after insert, Before insert, Before update) {

    if (Trigger.isAfter) {
        
        List<Id> oppIds = new List<Id>();
        List<Id> oppCloseIds = new List<Id>();
        
        //String oppVarejoRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MidiasVendas').getRecordTypeId();

        for (Opportunity opp : Trigger.new) {
            
            //if(opp.RecordTypeId == oppVarejoRecordTypeId){
                if(!opp.updateSGC__c){
                    oppIds.add(opp.Id);
                } else {
                    opp.updateSGC__c = false;
                } 
            //}

            // Verificar se o estágio da oportunidade foi alterado
            // Verificar se o novo estágio é "Closed Won" (ganha)
                

        }
        if(oppIds.size() > 0){
            OpportunitySGCTriggerHandler.processOpportunities(oppIds);
        }
        
        
    }
}