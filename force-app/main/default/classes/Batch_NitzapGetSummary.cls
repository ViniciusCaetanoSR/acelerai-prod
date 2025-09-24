global class Batch_NitzapGetSummary implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    global class DataWrapperChat {
        public String   chatId;
        public Datetime firstReceivedAt;
        public Datetime firstSentAt;
        public Integer  totalReceivedMessages;
        public Integer  totalSentMessages;
        public Boolean  iFirstSent;
        public String   referenceId;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // String idTask = Test.isRunningTest() ? [SELECT Id FROM Task LIMIT 1][0].Id : '00TN400000QYCSrMAP';
        return Database.getQueryLocator([
            SELECT Id, Subject, CreatedDate, ActivityDate, WhoId, OwnerId,
                    TYPEOF Owner
                        WHEN User THEN nitzap20__WhatsAppId__c
                        WHEN Group THEN Id
                    END,
                    TYPEOF Who
                        WHEN Contact THEN nitzap20__WhatsAppId__c
                        WHEN Lead THEN nitzap20__WhatsAppId__c
                    END,
                   nitzap20__Nitzap_Task__c,
                   nitzap20__Date_Time_Start_Chat__c,
                   nitzap20__DateTime_First_Message_Received__c,
                   nitzap20__DateTime_First_Message_Sent__c
            FROM Task
            WHERE nitzap20__Nitzap_Task__c = true
              AND Subject = 'Conversa Whatsapp'
              AND ActivityDate = TODAY
              AND (nitzap20__DateTime_First_Message_Received__c = NULL
                   OR nitzap20__DateTime_First_Message_Sent__c = NULL)
                //    AND Id =: idTask
             AND OwnerId <> null
             AND nitzap20__Date_Time_Start_Chat__c != null
        ]);
        
    }

    global void execute(Database.BatchableContext bc, List<Task> scope) {
        if (scope.isEmpty()) return;

        Set<Id> ownerUserIds = new Set<Id>();

        system.debug('Quantidade de tarefas ' + scope.size());
        system.debug('Tarefas encontradas' + JSON.serialize(scope));

        List<Object> requests = new List<Object>();
        Map<String, Task> chatIdToTask = new Map<String, Task>();

        for (Task t : scope) {
            String toWpp = null;
            if (t.Who instanceof Contact) {
                Contact contact = t.Who;
                toWpp = contact.nitzap20__WhatsAppId__c;
            } else if (t.Who instanceof Lead) {
                Lead lead = t.Who;
                toWpp = lead.nitzap20__WhatsAppId__c;
            }

            if (toWpp == null || String.isBlank(toWpp)) continue;

            String vFrom = null;
            if(t.Owner instanceof User){
                User user = t.Owner;
                vFrom = user.nitzap20__WhatsAppId__c;
            }
            if (vFrom == null || String.isBlank(vFrom)) continue;
            
            Integer day = t.nitzap20__Date_Time_Start_Chat__c.day();
            Integer month = t.nitzap20__Date_Time_Start_Chat__c.month();
            Integer year = t.nitzap20__Date_Time_Start_Chat__c.year();

            Datetime startDt = Datetime.newInstance(year, month, day, 0, 0, 0);
            Long sequence      = startDt.getTime();
            Long finalSequence = Datetime.now().getTime();

            String sequenceStr = String.valueOf(sequence);
            String finalSequenceStr = String.valueOf(finalSequence);

            Map<String, Object> req = new Map<String, Object>();
            req.put('vFrom', vFrom);
            req.put('referenceId', t.Id);
            req.put('to', toWpp);
            req.put('sequence', sequenceStr);
            req.put('finalSequence', finalSequenceStr);
            requests.add(req);

            chatIdToTask.put(t.Id, t);
        }

        if (requests.isEmpty()) return;

        List<Object> raw = Test.isRunningTest() ? new List<Object>() : new nitzap20.Globals().getChatSummary(requests);
        system.debug(JSON.serialize(raw));
        List<DataWrapperChat> results = (List<DataWrapperChat>) JSON.deserialize(JSON.serialize(raw), List<DataWrapperChat>.class);

        Map<Id, Task> mapTask = new Map<Id, Task>();
        for (DataWrapperChat res : results) {
            Task taskUpd = chatIdToTask.get(res.referenceId);
            if (res.firstReceivedAt != null)
                taskUpd.nitzap20__DateTime_First_Message_Received__c = res.firstReceivedAt;
            if (res.firstSentAt != null)
                taskUpd.nitzap20__DateTime_First_Message_Sent__c = res.firstSentAt;

            mapTask.put(taskUpd.Id, taskUpd);
        }
        if (!mapTask.values().isEmpty()) update mapTask.values();
    }

    global void finish(Database.BatchableContext BC){

        system.debug('Batch Finalizado com sucesso!');

    }

}

// sf project deploy start --metadata ApexClass:Batch_NitzapGetSummary --metadata ApexClass:Batch_NitzapGetSummary_Test -l RunSpecifiedTests -t Batch_NitzapGetSummary_Test -o Connection_Acelerai_Prod
// sf project deploy start --metadata ApexClass:Batch_NitzapGetSummary --metadata ApexClass:Batch_NitzapGetSummary_Test -l RunSpecifiedTests -t Batch_NitzapGetSummary_Test -o aceleraai_prod