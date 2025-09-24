/**
 * @description       : Service class to manage Lead creation from LeadEntry__c records.
 * @author            : Vinícius Caetano
 * @last modified on  : 21-05-2025
 * @last modified by  : Vinícius Caetano
 **/
public without sharing class LeadEntryService {
    private final LeadEntryRepository repository;
    private static final LeadEntryRepository repository = new LeadEntryRepository();

    public LeadEntryService() {
        this.repository = new LeadEntryRepository();        
    }
    
    /**
     * Este método é chamado no LWC sheetDataImporter para importar os LeadEntry__c
     */
    @AuraEnabled
    public static List<LeadEntry__c> processLeads(List<Map<String, String>> leadsData) {
        System.debug('processLeads | input size: ' + (leadsData == null ? 0 : leadsData.size()));

        if (leadsData == null || leadsData.isEmpty()) {
            return new List<LeadEntry__c>();
        }

        List<LeadEntry__c> leadsToProcess = new List<LeadEntry__c>();
        Id customerAccountId = getCustomerAccountId();
        System.debug('processLeads | customerAccountId: ' + customerAccountId);

        //Id defaultOwnerId = getDefaultOwnerId('Lead');
        //System.debug('processLeads | defaultOwnerId:  ' + defaultOwnerId);

        try {
            for (Map<String, String> row : leadsData) {
                System.debug('processLeads | row: ' + row);

                LeadEntry__c entry = new LeadEntry__c();
                entry.Name = row.get('Name') != null ? row.get('Name').trim() : null;
                entry.Email__c = row.get('Email') != null ? row.get('Email').trim() : null;
                entry.Phone__c = row.get('Phone') != null ? row.get('Phone').trim() : null;
                entry.PartnerAccount__c = customerAccountId;
                //if (defaultOwnerId != null)
                    //entry.OwnerId = defaultOwnerId;

                leadsToProcess.add(entry);
            }
            System.debug('processLeads | prepared: ' + leadsToProcess.size());

            List<LeadEntry__c> leadsToInsert = processDuplicateLeadEntries(leadsToProcess);
            System.debug('Chamou o processDuplicateLeadEntries(), com esses Leads para processar: ' + leadsToProcess);

            System.debug('leadsToInsert: ' + leadsToInsert);            
            return leadsToInsert;
            
            //insertProcessedLeadEntries(leadsToInsert);
            //System.debug('Chamou o insertProcessedLeadEntries(), com esses Leads para inserir: ' + leadsToInsert);

            // refatorar aqui:
            // *um método só para inserir, receber o resultado de processDuplicateLeadEntries e passar o leadsToProcess para inserir
            // if (!leadsToProcess.isEmpty()) {
            //     Database.SaveResult[] srList = Database.insert(leadsToProcess, /* allOrNone = */ false);

            //     for (Integer i = 0; i < srList.size(); i++) {
            //         if (!srList[i].isSuccess()) {
            //             System.debug(LoggingLevel.ERROR, 'processLeads | DML error on row ' + i + ' | ' + srList[i].getErrors()[0].getMessage());
            //         }
            //     }
            // }            
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'LeadEntryService.processLeads');
            throw new AuraHandledException('Erro ao processar os leads: ' + e.getMessage());
        }
    }

    public static void insertProcessedLeadEntries(List<LeadEntry__c> processedEntriesToInsert){
        try{
            if (!processedEntriesToInsert.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(processedEntriesToInsert, /* allOrNone = */ false);

                for (Integer i = 0; i < srList.size(); i++) {
                    if (!srList[i].isSuccess()) {
                        System.debug(LoggingLevel.ERROR, 'processLeads | DML error on row ' + i + ' | ' + srList[i].getErrors()[0].getMessage());
                    } else {
                        System.debug(LoggingLevel.ERROR, 'insertProcessedLeadEntries FINALIZADO');
                    }
                }
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'LeadEntryService.processLeads');
            throw new AuraHandledException('Erro ao processar os leads: ' + e.getMessage());
        }
    }

    private static Id getCustomerAccountId() {
        System.debug('getCustomerAccountId');

        try {
            User u = [
                SELECT ContactId, AccountId
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            if (u.ContactId == null)
                return null;

            Account acc = [
                SELECT Id
                FROM Account
                WHERE Id = :u.AccountId AND IsCustomerPortal = TRUE
                LIMIT 1
            ];
            System.debug('getCustomerAccountId | acc: ' + acc);
            return acc == null ? null : acc.Id;
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'LeadEntryService.getCustomerAccountId');
            throw new AuraHandledException('Erro ao buscar Partner Account: ' + e.getMessage());
        }
    }

    public static Id getDefaultOwnerId(String objectName) {
        System.debug('getDefaultOwnerId | object: ' + objectName);

        Default_Object_Owner__mdt cfg = [
            SELECT OwnerId__c
            FROM Default_Object_Owner__mdt
            WHERE ObjectName__c = :objectName
            LIMIT 1
        ];
        Id ownerId = cfg != null && String.isNotBlank(cfg.OwnerId__c) ? Id.valueOf(cfg.OwnerId__c) : null;
        System.debug('getDefaultOwnerId | ownerId: ' + ownerId);
        return ownerId;
    }

    @AuraEnabled
    public static String importLeads(List<LeadEntry__c> leadsToImport) {
        System.debug('importLeads | input size: ' + (leadsToImport == null ? 0 : leadsToImport.size()));

        try {
            List<LeadEntry__c> news = new List<LeadEntry__c>();
            List<LeadEntry__c> upds = new List<LeadEntry__c>();

            for (LeadEntry__c le : leadsToImport) {
                if (le.Id == null)
                    news.add(le);
                else
                    upds.add(le);
            }
            System.debug('importLeads | new: ' + news.size() + ' | upd: ' + upds.size());

            if (!news.isEmpty()) {
                insert news;
                
                System.debug('importLeads | inserted: ' + news.size());
                System.debug('importLeads | inserted: ' + news);

            }
            if (!upds.isEmpty()) {
                update upds;
                System.debug('importLeads | updated:  ' + upds.size());
            }
            return String.valueOf(leadsToImport);
        } catch (Exception e) {
            System.debug('Exception e:  ' + e.getMessage());

            LoggerUtility.createLogException(e, null, 'LeadEntryService.importLeads');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * Este método é chamado no LeadEntryTriggerHandler para publicar os Eventos que farão a criação dos Leads a partir dos LeadEntry__c
     */
    public String publishEventsFromEntries(List<LeadEntry__c> entries) {
        System.debug('publishEventsFromEntries | input size: ' + (entries == null ? 0 : entries.size()));
        if (entries == null || entries.isEmpty()) {
            return 'não há lead entries';
        }

        Id ownerId = getDefaultOwnerId('Lead');
        Id customerAccountId = [
                SELECT Contact.AccountId
                FROM User
                WHERE Id = :UserInfo.getUserId()
            ]
            .Contact
            ?.AccountId;
        System.debug('publishEventsFromEntries | ownerId: ' + ownerId + ' | customerAccountId: ' + customerAccountId);

        List<LeadEntry__c> entriesNeedingUpdate = new List<LeadEntry__c>();
        List<LeadEntryEvent__e> eventsToPublish = new List<LeadEntryEvent__e>();

        for (LeadEntry__c e : entries) {
            if (String.isBlank(e.Email__c)) {
                System.debug('publishEventsFromEntries | skip (blank email) ' + e);
                continue;
            }

            // Atualiza PartnerAccount se necessário
            if (customerAccountId != null && e.PartnerAccount__c == null) {
                e.PartnerAccount__c = customerAccountId; // Atualiza o objeto diretamente
                entriesNeedingUpdate.add(e);
            }

            // Prepara evento para publicação
            eventsToPublish.add(new LeadEntryEvent__e(
                LeadEntryId__c = e.Id,
                Email__c = e.Email__c,
                Name__c = e.Name,
                Phone__c = e.Phone__c,
                PartnerAccount__c = e.PartnerAccount__c,
                OwnerId__c = ownerId
            ));
        }

        try {
            if (!entriesNeedingUpdate.isEmpty()) {
                update entriesNeedingUpdate;
                return 'eventos atualizados';
            }

            if (!eventsToPublish.isEmpty()) {
                List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
                System.debug('Resultados da publicação: ' + JSON.serializePretty(results));
                return 'eventos publicados';
            }
        } catch (Exception e) {
            System.debug('Erro no publishEventsFromEntries: ' + e.getMessage());
            LoggerUtility.createLogException(e, null, 'LeadEntryService.publishEventsFromEntries');
        }
        return 'erro ao publicar os eventos';
    }

    /*
    * Adicionado por Bárbara Mór
    * Refatoração: processDuplicateLeadEntries > processDuplicateLeadEntriesInternal
    * Motivo: na execução do UnitTest, o processDuplicateLeadEntries() sempre exclui os dados de teste antes do AssertEquals, então ficaria impossível de testar
    */
    /*public static String processDuplicateLeadEntries(List<LeadEntry__c> newLeadEntries, List<LeadEntry__c> oldLeadEntries) {
        if (!Test.isRunningTest()) {
            processDuplicateLeadEntriesInternal(newLeadEntries);
            return 'Chamou o processDuplicateLeadEntriesInternal';
        }
        return 'É um teste, não precisa excluir o LeadEntry';
    }*/

    public static List<LeadEntry__c> processDuplicateLeadEntries(List<LeadEntry__c> newLeadEntries) {
        System.debug('Leads Entries novos:' + newLeadEntries);

        if (newLeadEntries == null || newLeadEntries.isEmpty()) {
            System.debug('Leads Entries novos não existem');
            return new List<LeadEntry__c>();
        }

        Set<String> newLeadEmails = new Set<String>();
        Set<Id> newEntryIds = new Set<Id>();

        for (LeadEntry__c newEntry : newLeadEntries) {
            if (String.isNotBlank(newEntry.Email__c)) {
                newLeadEmails.add(newEntry.Email__c.toLowerCase());
            }
            newEntryIds.add(newEntry.Id);
        }

        try {
            List<LeadEntry__c> existingEntries = repository.findLeadEntryByEmail(newLeadEmails);   //entries que JA EXISTEM pelo EMAIL            
            List<LeadEntry__c> filteredEntries = new List<LeadEntry__c>();
            
            /**
             * Depois de filtrar os entries existentes, chama o método para filtrar os entries realmente novos, para posterior inserção. Isso faz parte do novo processo de verificação de LeadEntry Duplicado.
             */
            filterActualNewEntries(newLeadEntries, existingEntries);

            for (LeadEntry__c existing : existingEntries) {
                if (!newEntryIds.contains(existing.Id)) {
                    filteredEntries.add(existing);
                } 
            }
            existingEntries = filteredEntries;
                        
            if (!existingEntries.isEmpty()) {
                Map<String, List<LeadEntry__c>> emailToExistingEntries = new Map<String, List<LeadEntry__c>>();
                for (LeadEntry__c existingEntry : existingEntries) {
                    String emailKey = existingEntry.Email__c.toLowerCase();
                    if (!emailToExistingEntries.containsKey(emailKey)) {
                        emailToExistingEntries.put(emailKey, new List<LeadEntry__c>());
                    }
                    emailToExistingEntries.get(emailKey).add(existingEntry);
                }

                List<LeadEntry__c> entriesToDelete = new List<LeadEntry__c>();
                List<LeadEntry__c> oldEntriesToUpdate = new List<LeadEntry__c>();

                for (LeadEntry__c newEntry : newLeadEntries) {
                    if (!String.isBlank(newEntry.Email__c)) {
                        String emailKey = newEntry.Email__c.toLowerCase();
                        if (emailToExistingEntries.containsKey(emailKey)) {
                            for (LeadEntry__c existingLE : emailToExistingEntries.get(emailKey)) {
                                if (newEntry.PartnerAccount__c == existingLE.PartnerAccount__c) {
                                    entriesToDelete.add(newEntry);
                                    //oldEntriesToUpdate.add(existingLE);
                                    System.debug('existingLE: ' + existingLE);
                                    break;
                                } else if (newEntry.PartnerAccount__c != existingLE.PartnerAccount__c) {
                                    existingLE.DuplicatedDate__c = System.now();
                                    oldEntriesToUpdate.add(existingLE);
                                }
                            }
                        }
                    }
                }

                if (!entriesToDelete.isEmpty()) {
                    System.enqueueJob(new LeadEntryQueueable(new List<Lead>(), new List<LeadEntry__c>(), entriesToDelete, new List<LeadEntry__c>()));
                    System.debug('Enfileirou os LeadEntries para serem deletados');
                    return entriesToDelete;
                }
                if (!oldEntriesToUpdate.isEmpty()) {
                    System.enqueueJob(new LeadEntryQueueable(new List<Lead>(), new List<LeadEntry__c>(), new List<LeadEntry__c>(), oldEntriesToUpdate));
                    System.debug('Enfileirou os LeadEntries para serem  atualizados');
                    return oldEntriesToUpdate;
                }
            }            
        } catch (Exception e) {
            System.debug('Exception no processDuplicateLeadEntries:' + e);
            LoggerUtility.createLogException(e, null, 'LeadEntryService.processDuplicateLeadEntries');
            throw e;
        }
        System.debug('Nenhum Lead Entry duplicado encontrado');
        return newLeadEntries;
    }

    public static void filterActualNewEntries (List<LeadEntry__c> newLeadEntries, List<LeadEntry__c> existingLeadEntries){
        Set<Id> existingEntriesId = new Set<Id>();
        List<LeadEntry__c> freshEntries = new List<LeadEntry__c>();

        for (LeadEntry__c existingEntryId : existingLeadEntries) {            
            existingEntriesId.add(existingEntryId.Id);
        }  

        for (LeadEntry__c newEntry : newLeadEntries) {    
            if(!existingEntriesId.contains(newEntry.Id)){
                freshEntries.add(newEntry);
            }
        }  

        if(!freshEntries.isEmpty()){
            insertProcessedLeadEntries(freshEntries);
            System.debug('Os fresh entries foram enviados para serem inseridos: ' + freshEntries);
        }      
    }
}