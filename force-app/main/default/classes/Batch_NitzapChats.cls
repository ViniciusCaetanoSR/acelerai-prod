global class Batch_NitzapChats implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public class DataWrapperAuthResp {
        @AuraEnabled public String success { get; set; }
        @AuraEnabled public String sessionToken { get; set; }
    }

    public class DataWrapperChat {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String chat_id { get; set; }
        @AuraEnabled public String sessionid { get; set; }
        @AuraEnabled public String mywhatsid { get; set; }
        @AuraEnabled public String secondwhatsappid { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String sequence { get; set; }
        @AuraEnabled public Datetime dt_lastmessage { get; set; }
        @AuraEnabled public Datetime dt_second_last_message { get; set; }
        @AuraEnabled public String createddate { get; set; }
        @AuraEnabled public Integer version { get; set; }
    }

    global class Batch_NitzapChats_Exception extends Exception {}
    global Map<Id, User> mapUsers;

    public List<DataWrapperChat> response = new List<DataWrapperChat>();

    public List<SObject> start(Database.BatchableContext BC) {
        nitzap20__NitzapConfigs__c nitzapConfigs = nitzap20__NitzapConfigs__c.getOrgDefaults();

        HttpRequest reqAuth = new HttpRequest();
        reqAuth.setEndpoint(nitzapConfigs.nitzap20__Url_Base__c + '/whatsapp/login');
        reqAuth.setMethod('POST');
        reqAuth.setHeader('content-type', 'application/json');
        reqAuth.setBody('{"username": "' + nitzapConfigs.nitzap20__Master_ID__c + '", "password": "' + nitzapConfigs.nitzap20__Master_Secret__c + '"}');

        HTTPResponse resAuth = new Http().send(reqAuth);
        DataWrapperAuthResp authResponse = (DataWrapperAuthResp) JSON.deserialize(resAuth.getBody(), DataWrapperAuthResp.class);
        String authToken = authResponse.sessionToken;

        Datetime dtFrom = Datetime.now().addMinutes(-10);

        Map<String, Object> mpBody = new Map<String, Object>{
            'where' => 'sequence >= '+ dtFrom.getTime() + ' AND secondwhatsappid NOT LIKE \'%@g.us%\''
        };
        
        String body = JSON.serialize(mpBody);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(nitzapConfigs.nitzap20__Url_Base__c + '/whatsapp/get-chats-metadata');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + authToken);
        req.setHeader('content-type', 'application/json');
        req.setBody(body);

        HTTPResponse res = new Http().send(req);
        response = (List<DataWrapperChat>) JSON.deserialize(res.getBody(), List<DataWrapperChat>.class);
        system.debug('O tamanho é ' + response.size());

        Map<String, DataWrapperChat> mapResultsAPI = new Map<String, DataWrapperChat>();
        Set<String> chaves = new Set<String>();

        for (DataWrapperChat chat : response) {
            if (chat.secondwhatsappid != null && !chat.secondwhatsappid.contains('@g.')) {
                mapResultsAPI.put(chat.secondwhatsappid, chat);
                chaves.add(chat.secondwhatsappid.split('@').get(0).right(8));
            }
        }

        List<SObject> resultados = new List<SObject>();
        resultados.addAll([
            SELECT Id, Name, nitzap20__WhatsAppId__c, OwnerId, Owner.IsActive, Owner.Id FROM Contact WHERE FinWid__c IN :chaves
        ]);
        resultados.addAll([
            SELECT Id, Name, nitzap20__WhatsAppId__c, OwnerId, Owner.IsActive, Owner.Id FROM Lead WHERE FinWid__c IN :chaves AND IsConverted = FALSE
        ]);

        Set<Id> idsUsers = new Set<Id>();
        for (SObject reg : resultados) {
            idsUsers.add((Id) reg.get('OwnerId'));
        }

        mapUsers = new Map<Id, User>([
            SELECT IsActive, Id
            FROM User
            WHERE Id IN :idsUsers
        ]);
        return resultados;
    }

    public void execute(Database.BatchableContext BC, List<SObject> registros) {
        Map<Id, SObject> recsToUpdate = new Map<Id, SObject>();
        Set<Id> contactIds = new Set<Id>();
    
        for (SObject reg : registros) {
            String wid = '';
            if (reg.Id.getSObjectType() == Contact.SObjectType) {
                wid = ((Contact) reg).nitzap20__WhatsAppId__c;
                contactIds.add(reg.Id);
            } else if (reg.Id.getSObjectType() == Lead.SObjectType) {
                wid = ((Lead) reg).nitzap20__WhatsAppId__c;
            }
    
            for (DataWrapperChat chat : response) {
                String secondwhatsappid = chat.secondwhatsappid;
                if (String.isBlank(wid) || String.isBlank(secondwhatsappid)) continue;
    
                String secondwhatsappidsplit = secondwhatsappid.split('@').get(0);
                String contWithoutPlus = wid.replace('+', '');
                String secondWithoutPlus = secondwhatsappidsplit.replace('+', '');
    
                String biggerPhone = contWithoutPlus.length() >= secondWithoutPlus.length() ? contWithoutPlus : secondWithoutPlus;
                String smallerPhone = secondWithoutPlus.length() > contWithoutPlus.length() ? contWithoutPlus : secondWithoutPlus;
    
                String smallerPhoneEnd = smallerPhone.right(8);
                String smallerPhoneStart = smallerPhone.left(smallerPhone.length() - 8).replace('+', '');
                String smallerPhoneStart3 = smallerPhone.left(3);
    
                if (biggerPhone == smallerPhone || (
                    (smallerPhoneStart3.startsWith('+55') || smallerPhoneStart3.startsWith('55')) &&
                    biggerPhone.startsWith(smallerPhoneStart) &&
                    biggerPhone.endsWith(smallerPhoneEnd) &&
                    biggerPhone.left(biggerPhone.length() - 7).right(1) == '9'
                )) {
                    reg.put('nitzap20__DateTime_Last_Sent_Whatsapp__c', chat.dt_lastmessage);
                    recsToUpdate.put(reg.Id, reg);
                }
            }
        }
    
        if (recsToUpdate.isEmpty()) return;
    
        update recsToUpdate.values();
    
        Map<Id, Opportunity> contatoToLatestOpp = new Map<Id, Opportunity>();
        if (!contactIds.isEmpty()) {
            for (Opportunity opp : [
                SELECT Id, ContactId, CreatedDate
                FROM Opportunity
                WHERE ContactId IN :contactIds
                AND IsWon = false AND IsClosed = false
                ORDER BY ContactId, CreatedDate DESC
            ]) {
                if (!contatoToLatestOpp.containsKey(opp.ContactId)) {
                    contatoToLatestOpp.put(opp.ContactId, opp);
                }
            }
        }
    
        Set<String> mywhatsIds = new Set<String>();
        for (DataWrapperChat chat : response) {
            if (!String.isBlank(chat.mywhatsid)) {
                mywhatsIds.add(chat.mywhatsid.split('@').get(0));
            }
        }
        Map<String, Id> mywhatsidToUserId = new Map<String, Id>();
        if (!mywhatsIds.isEmpty()) {
            for (User u : [
                SELECT Id, nitzap20__WhatsAppId__c
                FROM User
                WHERE nitzap20__WhatsAppId__c IN :mywhatsIds
                AND IsActive = TRUE AND nitzap20__WhatsAppId__c != NULL
            ]) {
                mywhatsidToUserId.put(u.nitzap20__WhatsAppId__c, u.Id);
            }
        }
        
        // Mapear chats por secondwhatsappid para facilitar a busca
        Map<String, DataWrapperChat> chatBySecondWhatsId = new Map<String, DataWrapperChat>();
        for (DataWrapperChat chat : response) {
            if (!String.isBlank(chat.secondwhatsappid)) {
                chatBySecondWhatsId.put(chat.secondwhatsappid, chat);
            }
        }
    
        Set<Id> whoIdsParaChecar = new Set<Id>(recsToUpdate.keySet());
        Set<Id> whoAlreadyToday = new Set<Id>();
        if (!whoIdsParaChecar.isEmpty()) {
            for (Task t : [
                SELECT Id, WhoId
                FROM Task
                WHERE WhoId IN :whoIdsParaChecar
                  AND Subject = 'Conversa Whatsapp'
                  AND ActivityDate = TODAY
            ]) {
                whoAlreadyToday.add(t.WhoId);
            }
        }
    
        List<Task> tasksToCreate = new List<Task>();
        Datetime meiaNoiteHoje = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
    
        Set<Id> contatosJaProcessados = new Set<Id>();
        for (Id recId : recsToUpdate.keySet()) {
            SObject sObj = recsToUpdate.get(recId);
            if (contatosJaProcessados.contains(sObj.Id)) continue;
            contatosJaProcessados.add(sObj.Id);
    
            if (whoAlreadyToday.contains(sObj.Id)) continue;
    
            String contactWhatsId = (String) sObj.get('nitzap20__WhatsAppId__c');
            Id ownerId = null;
            
            // Buscar o chat correspondente usando lógica de matching melhorada
            DataWrapperChat matchingChat = null;
            for (DataWrapperChat chat : response) {
                if (chat.secondwhatsappid != null && !String.isBlank(contactWhatsId)) {
                    String secondwhatsappidsplit = chat.secondwhatsappid.split('@').get(0);
                    String contWithoutPlus = contactWhatsId.replace('+', '');
                    String secondWithoutPlus = secondwhatsappidsplit.replace('+', '');
                    
                    // Aplicar a mesma lógica de matching usada no execute
                    String biggerPhone = contWithoutPlus.length() >= secondWithoutPlus.length() ? contWithoutPlus : secondWithoutPlus;
                    String smallerPhone = secondWithoutPlus.length() > contWithoutPlus.length() ? contWithoutPlus : secondWithoutPlus;
                    
                    String smallerPhoneEnd = smallerPhone.right(8);
                    String smallerPhoneStart = smallerPhone.left(smallerPhone.length() - 8).replace('+', '');
                    String smallerPhoneStart3 = smallerPhone.left(3);
                    
                    if (biggerPhone == smallerPhone || (
                        (smallerPhoneStart3.startsWith('+55') || smallerPhoneStart3.startsWith('55')) &&
                        biggerPhone.startsWith(smallerPhoneStart) &&
                        biggerPhone.endsWith(smallerPhoneEnd) &&
                        biggerPhone.left(biggerPhone.length() - 7).right(1) == '9'
                    )) {
                        matchingChat = chat;
                        break;
                    }
                }
            }
            
            // Se encontrou o chat, buscar o ownerId baseado no mywhatsid
            if (matchingChat != null && !String.isBlank(matchingChat.mywhatsid)) {
                String chatMyWhatsId = matchingChat.mywhatsid.split('@').get(0);
                ownerId = mywhatsidToUserId.get(chatMyWhatsId);
            }
            
            // Se não encontrou ownerId, usar o owner do registro ou usuário atual
            if (ownerId == null) {
                User usu = mapUsers.get((Id) sObj.get('OwnerId'));
                ownerId = (usu != null && usu?.IsActive == true) ? usu.Id : UserInfo.getUserId();
            }
    
            Task baseTask = new Task();
            baseTask.OwnerId = ownerId;
            baseTask.ActivityDate = Date.today();
            baseTask.TaskSubtype = 'Call';
            baseTask.Status = 'Completed';
            baseTask.Priority = 'Normal';
            baseTask.Subject = 'Conversa Whatsapp';
            baseTask.nitzap20__Date_Time_Start_Chat__c = meiaNoiteHoje;
            baseTask.WhoId = sObj.Id;
    
            if (sObj.getSObjectType() == Contact.SObjectType && contatoToLatestOpp.containsKey(sObj.Id)) {
                Opportunity opp = contatoToLatestOpp.get(sObj.Id);
                Task clonedTask = baseTask.clone(false, true, false, false);
                clonedTask.WhatId = opp.Id;
                tasksToCreate.add(clonedTask);
            } else {
                tasksToCreate.add(baseTask);
            }
        }
    
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('batch finalizado');
    }
}

// sf project deploy start --metadata ApexClass:Batch_NitzapChats --metadata ApexClass:Batch_NitzapChats_Test -l RunSpecifiedTests -t Batch_NitzapChats_Test -o Connection_Acelerai_Prod
// sf project deploy start --metadata ApexClass:Batch_NitzapChats --metadata ApexClass:Batch_NitzapChats_Test -l RunSpecifiedTests -t Batch_NitzapChats_Test