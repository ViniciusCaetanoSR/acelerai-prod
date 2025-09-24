/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 17-09-2025
 * @last modified by  : Vinícius Caetano
 **/
public without sharing class OpportunityService {
    public static void validatePhoneNumber(List<Opportunity> newOpportunities) {
        for (Opportunity currentOpportunity : newOpportunities) {
            if (String.isBlank(currentOpportunity.Telefone1__c))
                continue;

            currentOpportunity.Telefone1__c = StringUtils.validatePhoneNumber(currentOpportunity.Telefone1__c, currentOpportunity);
        }
    }

    public static void sendOpportunityStatusToProposalOnQuoteWaitingApproval(Map<Id, Quote> newQuotesMap, Map<Id, Quote> oldQuotesMap) {
        Set<Id> oppIds = new Set<Id>();

        for (Quote newQuote : newQuotesMap.values()) {
            Boolean quoteStatusChangedToWaitingApproval =
                newQuote.Status != oldQuotesMap.get(newQuote.Id).Status &&
                newQuote.Status.equals('AGUARDANDO_ACEITE') &&
                newQuote.OpportunityId != null;

            if (quoteStatusChangedToWaitingApproval) {
                oppIds.add(newQuote.OpportunityId);
            }
        }

        List<Opportunity> opportunitiesToUpdate = OpportunitySelector.selectByIdAndStageName(oppIds, new Set<String>{ 'Qualificação' });

        for (Opportunity newOpportunity : opportunitiesToUpdate) {
            newOpportunity.StageName = 'Proposta Enviada';
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

    public static void handleBeforeClone(List<Opportunity> newOpportunities) {
        Set<Id> originalOpportunityIds = new Set<Id>();
        List<OpportunityContactRole> oppContRole = new List<OpportunityContactRole>();
        Id recordTypeIdVarejo = [SELECT Id FROM RecordType WHERE Name = 'Varejo' AND SObjectType = 'Opportunity' LIMIT 1].Id;

        for (Opportunity newOpportunity : newOpportunities) {
            Id originalOpportunityId = newOpportunity.getCloneSourceId();
            if (originalOpportunityId != null) {
                originalOpportunityIds.add(originalOpportunityId);
            }
        }

        Map<Id, Opportunity> originalOppMap = new Map<Id, Opportunity>(
            [
                SELECT
                    Id,
                    ContactId,
                    Company__c,
                    Lead__c,
                    Fbclid__c,
                    Metalead_id__c,
                    Gclid__c,
                    LetraLeadScore__c,
                    ValueLeadScore__c,
                    ValueScoreFinal__c,
                    RecordType.Name
                FROM Opportunity
                WHERE Id IN :originalOpportunityIds
            ]
        );

        for (Opportunity newOpportunity : newOpportunities) {
            Id originalOpportunityId = newOpportunity.getCloneSourceId();

            if (originalOpportunityId != null && originalOppMap.containsKey(originalOpportunityId)) {
                Opportunity originalOpp = originalOppMap.get(originalOpportunityId);
                try {
                    newOpportunity.RelatedOpportunity__c = originalOpportunityId;
                    newOpportunity.Company__c = originalOpp.Company__c;
                    newOpportunity.LetraLeadScore__c = originalOpp.LetraLeadScore__c;
                    newOpportunity.ValueLeadScore__c = originalOpp.ValueLeadScore__c;
                    newOpportunity.ValueScoreFinal__c = originalOpp.ValueScoreFinal__c;
                    newOpportunity.Lead__c = originalOpp.Lead__c;
                    newOpportunity.Media__c = originalOpportunityId != null && newOpportunity.ClonedWithMediaSBT__c == true ? 'sbt' : null;
                    newOpportunity.Fbclid__c = originalOpp.Fbclid__c;
                    newOpportunity.Metalead_id__c = originalOpp.Metalead_id__c;
                    newOpportunity.Gclid__c = originalOpp.Gclid__c;
                    newOpportunity.Temperatura_da_negociacao__c = null;

                    if (originalOpp.RecordType.Name == 'Venda RD' || originalOpp.RecordType.Name == 'Varejo') {
                        if (newOpportunity.StageName == 'Qualificação') {
                            newOpportunity.RecordTypeId = recordTypeIdVarejo;
                            System.debug('>>[OpportunityService.handleBeforeClone] O StageName deve ser "Qualificação": ' + newOpportunity.StageName);
                        } else {
                            newOpportunity.StageName = 'Aprovado';
                            newOpportunity.RecordTypeId = recordTypeIdVarejo;
                            System.debug('>>[OpportunityService.handleBeforeClone] O StageName deve ser "Aprovado": ' + newOpportunity.StageName);
                        }
                    }
                } catch (Exception e) {
                    LoggerUtility.createLogException(e, originalOpp.Id, 'handleBeforeClone');
                    newOpportunity.addError('Não foi possível clonar, contate o administrador.');
                }
            }
        }
    }

    public static void handleBeforeCloneContact(List<Opportunity> newOpportunities) {
        Set<Id> originalOpportunityIds = new Set<Id>();
        List<OpportunityContactRole> oppContRole = new List<OpportunityContactRole>();

        for (Opportunity newOpportunity : newOpportunities) {
            Id originalOpportunityId = newOpportunity.getCloneSourceId();
            if (originalOpportunityId != null) {
                originalOpportunityIds.add(originalOpportunityId);
            }
        }

        Map<Id, Opportunity> originalOppMap = new Map<Id, Opportunity>(
            [SELECT Id, ContactId, Company__c, LetraLeadScore__c, ValueLeadScore__c, ValueScoreFinal__c FROM Opportunity WHERE Id IN :originalOpportunityIds]
        );

        try {
            for (Opportunity newOpportunity : newOpportunities) {
                Id originalOpportunityId = newOpportunity.getCloneSourceId();

                if (originalOpportunityId != null && originalOppMap.containsKey(originalOpportunityId)) {
                    Opportunity originalOpp = originalOppMap.get(originalOpportunityId);
                    Id contactId = originalOpp.ContactId;

                    if (contactId != null) {
                        oppContRole.add(new OpportunityContactRole(OpportunityId = newOpportunity.Id, ContactId = contactId, IsPrimary = true));
                    }
                }
            }

            if (!oppContRole.isEmpty()) {
                insert oppContRole;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception>> e.getMessage: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Exception>>  e.getCause: ' + e.getCause());
            System.debug(LoggingLevel.ERROR, 'Exception>>  e.getLineNumber: ' + e.getLineNumber());
            System.debug(LoggingLevel.ERROR, 'Exception>>  e.getStackTraceString: ' + e.getStackTraceString());
        }
    }

    public static void updateAccountDates(List<Opportunity> opportunities) {
        // Mapas para armazenar as datas mínima e máxima de cada conta relacionada
        Map<Id, Date> minContractStartDateByAccountId = new Map<Id, Date>();
        Map<Id, Date> maxContractEndDateByAccountId = new Map<Id, Date>();
        Set<String> targetStages = new Set<String>{ 'Venda Futura', 'Ganho Pagamento Futuro', 'Ganho', 'Ganho RD' };

        // Iterar pelas oportunidades para calcular as datas mínima e máxima de contrato
        for (Opportunity opp : opportunities) {
            if (targetStages.contains(opp.StageName)) {
                if (opp.AccountId != null && opp.ContractStartDate__c != null && opp.EndOfContractDate__c != null) {
                    Date contractStartDate = opp.ContractStartDate__c.date();
                    Datetime endOfContractDateTime = opp.EndOfContractDate__c;
                    Date endOfContractDate = endOfContractDateTime != null ? endOfContractDateTime.dateGMT() : null;

                    // Atualizar DataMinInicio
                    if (!minContractStartDateByAccountId.containsKey(opp.AccountId) || contractStartDate < minContractStartDateByAccountId.get(opp.AccountId)) {
                        minContractStartDateByAccountId.put(opp.AccountId, contractStartDate);
                    }

                    // Atualizar DataMaxTermino
                    if (!maxContractEndDateByAccountId.containsKey(opp.AccountId) || endOfContractDate > maxContractEndDateByAccountId.get(opp.AccountId)) {
                        maxContractEndDateByAccountId.put(opp.AccountId, endOfContractDate);
                    }
                }
            }
        }

        // Lista de contas para atualização
        List<Account> accountsToUpdate = new List<Account>();

        // Buscar contas do banco de dados e comparar valores
        for (Account acc : [
            SELECT Id, DataMinInicio__c, DataMaxTermino__c
            FROM Account
            WHERE Id IN :minContractStartDateByAccountId.keySet()
        ]) {
            Boolean shouldUpdate = false;

            // Verificar e atualizar DataMinInicio se necessário
            if (
                minContractStartDateByAccountId.containsKey(acc.Id) &&
                (acc.DataMinInicio__c == null ||
                minContractStartDateByAccountId.get(acc.Id) < acc.DataMinInicio__c)
            ) {
                acc.DataMinInicio__c = minContractStartDateByAccountId.get(acc.Id);
                shouldUpdate = true;
            }

            // Verificar e atualizar DataMaxTermino se necessário
            if (
                maxContractEndDateByAccountId.containsKey(acc.Id) &&
                (acc.DataMaxTermino__c == null ||
                maxContractEndDateByAccountId.get(acc.Id) > acc.DataMaxTermino__c)
            ) {
                acc.DataMaxTermino__c = maxContractEndDateByAccountId.get(acc.Id);
                shouldUpdate = true;
            }

            // Adicionar a conta à lista de atualização se necessário
            if (shouldUpdate) {
                accountsToUpdate.add(acc);
            }
        }

        // Atualizar as contas em uma única operação, evitando múltiplas DML
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    public static void validateOpportunityStageChangeGanho(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap) {
        Set<Id> opportunityIds = new Set<Id>();
        List<Opportunity> opportunityGanho = new List<Opportunity>();
        List<Opportunity> opportunityGanhoFuturo = new List<Opportunity>();
        Map<Id, List<Quote>> quoteMapOpportunity = new Map<Id, List<Quote>>();

        for (Opportunity opp : opportunities) {
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);
            opportunityIds.add(opp.Id);

            if (opp.StageName == 'Ganho' && opp.StageName != oldOpp.StageName) {
                opportunityGanho.add(opp);
            } else if (opp.StageName == 'Ganho Pagamento Futuro' && opp.StageName != oldOpp.StageName) {
                opportunityGanhoFuturo.add(opp);
            }
        }

        for (Quote quote : [
            SELECT Id, OpportunityId, DataVendafutura__c, Sincronizado__c, PagamentoFuturo__c, VendaFutura__c
            FROM Quote
            WHERE OpportunityId IN :opportunityIds
            ORDER BY DataVendafutura__c ASC
        ]) {
            if (!quoteMapOpportunity.containsKey(quote.OpportunityId)) {
                quoteMapOpportunity.put(quote.OpportunityId, new List<Quote>());
            }
            quoteMapOpportunity.get(quote.OpportunityId).add(quote);
        }

        for (Opportunity opp : opportunityGanho) {
            List<Quote> quotes = quoteMapOpportunity.get(opp.Id);
            if (quotes != null) {
                for (Quote quote : quotes) {
                    if (quote.Sincronizado__c && quote.DataVendafutura__c != null && quote.DataVendafutura__c > Date.today()) {
                        String formatedDate = quote.DataVendafutura__c.format();
                        opp.addError('Por favor, aguarde até a data de venda futura da cotação ' + formatedDate + ' para concluir a fase de Ganho');
                    }
                }
            }
        }

        for (Opportunity opp : opportunityGanhoFuturo) {
            List<Quote> quotes = quoteMapOpportunity.get(opp.Id);
            if (quotes != null) {
                for (Quote quote : quotes) {
                    if (quote.PagamentoFuturo__c && quote.DataVendafutura__c != null && quote.DataVendafutura__c > Date.today()) {
                        String formatedDate = quote.DataVendafutura__c.format();
                        opp.addError(
                            'Por favor, aguarde até a data de venda futura da cotação ' + formatedDate + ' para concluir a fase de Ganho Pagamento Futuro'
                        );
                    }
                }
            }
        }
    }

    public static void opportunityMetaIntegration(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap) {
        List<Id> opportunitiesIntegration = new List<Id>();

        for (Opportunity opp : opportunities) {
            if (opp.Metalead_id__c != null || opp.Fbclid__c != null) {
                opportunitiesIntegration.add(opp.Id);
            }
            Opportunity oldOpportunity = oldOpportunityMap.get(opp.Id);

            if (oldOpportunity != null && opp.Metalead_id__c != null && opp.StageName != oldOpportunity.StageName) {
                opportunitiesIntegration.add(opp.Id);
            }
        }

        if (!opportunitiesIntegration.isEmpty()) {
            try {
                MetaIntegration.sendOpportunityToMeta(opportunitiesIntegration);
            } catch (Exception e) {
                System.debug('Erro ao integrar oportunidades: ' + e.getMessage());
            }
        }
    }

    public static void assignOpportunitiesMediaToMembers(List<Opportunity> opportunities) {
        String assignmentGroupName = Test.isRunningTest() ? 'Group Name' : 'Opportunity Mídia - 7 Dias Após';
        List<Opportunity> oppUpdate = new List<Opportunity>();

        List<AssignmentGroupMember__c> members = [
            SELECT Id, User__c, User__r.Name, NumberRecordsAssigned__c, LastAssignmentDate__c
            FROM AssignmentGroupMember__c
            WHERE AssignmentGroup__r.Name = :assignmentGroupName
        ];

        for (Opportunity opp : opportunities) {
            // LoggerUtility.createLogException(e, relatedRecordId, methodName);
            AssignmentGroupMember__c priorityMember = AssignmentGroupMemberService.getPriorityMember(members);

            for (AssignmentGroupMember__c member : members) {
                if (member.Id == priorityMember.Id) {
                    member.LastAssignmentDate__c = priorityMember.LastAssignmentDate__c;
                    member.NumberRecordsAssigned__c = priorityMember.NumberRecordsAssigned__c + 1;
                }
            }

            Id userId = (priorityMember != null &&
                priorityMember.User__c != null &&
                String.valueOf(priorityMember.User__c).startsWith('005'))
                ? priorityMember.User__c
                : null;

            if (userId != null && !String.isEmpty(userId)) {
                opp.OwnerId = priorityMember.User__c;
                oppUpdate.add(opp);
            }
        }

        if (!members.isEmpty()) {
            update members;
        }

        if (!oppUpdate.isEmpty()) {
            update oppUpdate;
        }
    }

    public void checkDuplicateLeadsAndOpportunitiesVarejo(List<Lead> leads) {
        try {
            List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
            Set<String> leadEmails = new Set<String>();
            Map<String, Opportunity> opportunitiesVarejoEmailMap = new Map<String, Opportunity>();
            Map<Id, Opportunity> opportunityByLastOppId = new Map<Id, Opportunity>();
            List<Task> taskToInsert = new List<Task>();
            List<Contact> contactToInsert = new List<Contact>();
            List<Lead> leadsToUpdate = new List<Lead>();
            Set<String> existingContactPhone = new Set<String>();
            Set<String> existingContactEmail = new Set<String>();
            String recordTypeOpportunityVarejo = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Varejo').getRecordTypeId();
            User activeUser = [SELECT Id, Email FROM User WHERE Name = 'Marcos Torres' LIMIT 1];
            Date today = Date.today();
            Date firstDayNextMonth = today.addMonths(1).toStartOfMonth();
            Date lastDayOfCurrentMonth = firstDayNextMonth.addDays(-1);
            TaskService.TaskEmailResult result;

            for (Lead lead : leads) {
                //Adicionar Emails do Lead ao Set;
                leadEmails.add(lead.Email);
            }

            for (Opportunity opportunity : OpportunitySelector.selectByEmails(leadEmails)) {
                // Busca Oportunidades com base nos emails do lead;
                if (!opportunitiesVarejoEmailMap.containsKey(opportunity.Emaill__c)) {
                    opportunitiesVarejoEmailMap.put(opportunity.Emaill__c, opportunity);
                }
            }

            for (Lead lead : leads) {
                // Busca uma oportunidade existente com o email do lead;
                Opportunity lastOpp = opportunitiesVarejoEmailMap.get(lead.Email);
                if (lastOpp == null) {
                    continue;
                }
                System.debug('lastOpp.StageName: ' + lastOpp.StageName);
                System.debug('lastOpp.Owner: ' + lastOpp.Owner);
                System.debug('ActiveUser: ' + activeUser);

                // Se essa Oportunidade estiver fechada, criamos outra oportunidade;
                if (
                    lastOpp.StageName == 'Ganho' ||
                    lastOpp.StageName == 'Ganho Pagamento Futuro' ||
                    lastOpp.StageName == 'Venda Futura' ||
                    lastOpp.StageName == 'Perdido'
                ) {
                    Opportunity newOpportunity = new Opportunity(
                        RecordTypeId = recordTypeOpportunityVarejo,
                        Name = lastOpp.Name + ' ' + Date.today().format(),
                        Funnel__c = 'Varejo',
                        Emaill__c = lead.Email,
                        Telefone1__c = lead.Phone,
                        Desconto_Black_Friday__c = lead.Desconto_Black_Friday__c,
                        StageName = 'Aprovado',
                        AccountId = lastOpp.AccountId,
                        CloseDate = lastDayOfCurrentMonth,
                        Segmento__c = lastOpp.Segmento__c,
                        OwnerId = (lastOpp != null && lastOpp.Owner.IsActive) ? lastOpp.OwnerId : activeUser.Id,
                        WhatsYourInstagram__c = lastOpp.WhatsYourInstagram__c,
                        CNPJ__c = lastOpp.CNPJ__c,
                        Tipo_de_cliente__c = lastOpp.Tipo_de_cliente__c,
                        Ja_foi_anunciante__c = lastOpp.Ja_foi_anunciante__c,
                        WhatsYourRole__c = lastOpp.WhatsYourRole__c,
                        QuandoPretendeAnunciar__c = lastOpp.QuandoPretendeAnunciar__c,
                        NumberEmployees__c = lastOpp.NumberEmployees__c,
                        MonthlyInvestmentMedia_Content__c = lastOpp.MonthlyInvestmentMedia_Content__c,
                        CompanyAge__c = lastOpp.CompanyAge__c,
                        HaveCurrentlyAgency__c = lastOpp.HaveCurrentlyAgency__c,
                        StateYourCompany__c = lastOpp.StateYourCompany__c,
                        Cidade__c = lastOpp.Cidade__c,
                        lead__c = lastOpp.lead__c,
                        CampaignStartIntention__c = lastOpp.CampaignStartIntention__c,
                        ClientsObjectiveWithAcelerai__c = lastOpp.ClientsObjectiveWithAcelerai__c,
                        Company__c = lastOpp.Company__c,
                        Referencia_base_antiga__c = lastOpp.Referencia_base_antiga__c,
                        Veiculacao__c = lastOpp.Veiculacao__c,
                        Agencia__c = lastOpp.Agencia__c,
                        RelatedOpportunity__c = (lastOpp.RelatedOpportunity__c != null) ? lastOpp.RelatedOpportunity__c : lastOpp.Id,
                        UTM_Campaign__c = (lead.UTM_Campaign__c != null) ? lead.UTM_Campaign__c : lastOpp.UTM_Campaign__c,
                        UTM_Medium__c = (lead.UTM_Medium__c != null) ? lead.UTM_Medium__c : lastOpp.UTM_Medium__c,
                        UTM_Source__c = (lead.UTM_Source__c != null) ? lead.UTM_Source__c : lastOpp.UTM_Source__c,
                        UTM_Term__c = (lead.UTM_Term__c != null) ? lead.UTM_Term__c : lastOpp.UTM_Term__c,
                        UTM_Content__c = (lead.UTM_Content__c != null) ? lead.UTM_Content__c : lastOpp.UTM_Content__c
                    );

                    opportunityByLastOppId.put(lastOpp.Id, newOpportunity);
                }
            }
            // Inserção da nova oportunidade;
            if (!opportunityByLastOppId.isEmpty()) {
                insert opportunityByLastOppId.values();
            }

            Id recordTypeMentoria = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Mentoria').getRecordTypeId();

            for (Lead currentLead : leads) {
                // Busca uma oportunidade existente com o email do lead;
                Opportunity opp = opportunitiesVarejoEmailMap.get(currentLead.Email);

                if (opp == null) {
                    continue;
                }
                if (currentLead.RecordtypeId != recordTypeMentoria) {
                    // Altera o status para perdido pois existe uma oportunidade com o mesmo email do lead;
                    Lead leadToUpdate = new Lead(
                        Id = currentLead.Id,
                        Status = 'Perdido',
                        Motivo_da_Perda__c = 'RegraDuplicataEmail'.trim(),
                        isDuplicate__c = true
                    );
                    leadsToUpdate.add(leadToUpdate);

                    Task newTask;

                    Opportunity oppToUse = opportunityByLastOppId.containsKey(opp.Id) ? opportunityByLastOppId.get(opp.Id) : opp;

                    if (oppToUse == null) {
                        continue;
                    }

                    oppToUse = OpportunitySelector.selectByOpportunityId(new Set<Id>{ oppToUse.Id }).get(0);

                    if (opp.Owner.IsActive) {
                        //Criação da Task e disparo de Email para o owner da Oportunidade;
                        result = TaskService.createTaskDuplicateOpportunity(oppToUse, opp.Owner);
                        System.debug('New Task: ' + result.task);
                    } else {
                        User inactiveUser;
                        inactiveUser = [SELECT Id, Name, Email, isActive FROM User WHERE Id = :opp.OwnerId LIMIT 1];

                        //Criação da Task e disparo de Email para o ActiveUser (Marcos);
                        result = TaskService.createTaskDuplicateOpportunity(oppToUse, activeUser);
                        Messaging.SingleEmailMessage email = EmailService.sendEmailOwnerReplacement(oppToUse, activeUser, inactiveUser);
                        emailToSend.add(email); //
                    }
                    if (result != null && result.task != null && result.emails != null) {
                        taskToInsert.add(result.task);
                        emailToSend.add(result.emails);
                    }

                    List<Contact> associatedContacts = [SELECT Email, Phone FROM Contact WHERE AccountId = :opp.AccountId];
                    // Adicionamos aos Sets o Phone e Email dos contatos relacionados a oportunidade;
                    for (Contact contact : associatedContacts) {
                        existingContactPhone.add(contact.Phone);
                        existingContactEmail.add(contact.Email);
                    }
                    // Se o Lead.Phone ou Lead.Email for diferente do Phone ou Email da oportunidade, criamos um novo contato;
                    if (!existingContactPhone.contains(currentLead.Phone) || !existingContactEmail.contains(currentLead.Email)) {
                        Contact newContact = ContactService.createContact(
                            currentLead.FirstName,
                            currentLead.LastName,
                            opp.AccountId,
                            currentLead.Email,
                            currentLead.Phone
                        );
                        contactToInsert.add(newContact);
                    }
                }
            }

            if (!taskToInsert.isEmpty()) {
                insert taskToInsert;
            }

            if (!contactToInsert.isEmpty()) {
                insert contactToInsert;
            }

            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }

            if (!emailToSend.isEmpty()) {
                System.debug('emailToSend: ' + emailToSend);
                Messaging.sendEmail(emailToSend);
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'Método: checkDuplicateLeadsAndOpportunitiesVarejo');
            throw e;
        }
    }

    public void checkDuplicateLeadAndOpportunitiesVendaRd(List<Lead> leads) {
        try {
            List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
            Set<String> leadEmails = new Set<String>();
            Map<String, Opportunity> opportunitiesVendaRdEmailMap = new Map<String, Opportunity>();
            Map<Opportunity, Opportunity> clonedOpportunitiesMap = new Map<Opportunity, Opportunity>();
            User activeUser = [SELECT Id, Email FROM User WHERE Name = 'Marcos Torres' LIMIT 1];
            List<Opportunity> opportunities = new List<Opportunity>();
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Task> taskToInsert = new List<Task>();
            List<Contact> contactToInsert = new List<Contact>();
            TaskService.TaskEmailResult result;

            for (Lead lead : leads) {
                //Adicionar Emails do Lead ao Set;
                leadEmails.add(lead.Email);
            }

            for (Opportunity opportunityVendaRd : OpportunitySelector.selectOpportunityVendaRdByEmail(leadEmails)) {
                // Busca Oportunidades com base nos emails do lead;
                opportunitiesVendaRdEmailMap.put(opportunityVendaRd.Emaill__c, opportunityVendaRd);
            }

            if (opportunitiesVendaRdEmailMap.isEmpty()) {
                System.debug('Não há oportunidades encontradas para os e-mails dos leads.');
                return;
            }

            for (Lead lead : leads) {
                // Se existir uma oportunidade com o email do lead;
                Opportunity opportunityVendaRd = opportunitiesVendaRdEmailMap.get(lead.Email);

                // Se opportunityVendaRd for null, continua até a próxima;
                if (opportunityVendaRd == null) {
                    continue;
                }

                // Se oportunityVendaRd diferente de null, criamos uma renovação;
                Opportunity opportunityRenovacao = opportunityVendaRd.clone(false, true, false, false);
                opportunityRenovacao.Name = opportunityVendaRd.Name + ' (Renovação)';
                opportunityRenovacao.Pol_tica_Comercial__c = null;
                opportunityRenovacao.ContractStartDate__c = null;
                opportunityRenovacao.EndOfContractDate__c = null;
                opportunityRenovacao.SaleType__c = 'Renovação';

                opportunities.add(opportunityRenovacao);
                clonedOpportunitiesMap.put(opportunityVendaRd, opportunityRenovacao);

                // Altera o status para perdido;
                Lead leadToUpdate = new Lead(Id = lead.Id, Status = 'Perdido', Motivo_da_Perda__c = 'RegraDuplicataEmail'.trim(), isDuplicate__c = true);
                leadsToUpdate.add(leadToUpdate);

                // Se a oportunidade tem AccountId segue o fluxo;
                if (opportunityVendaRd.AccountId != null) {
                    List<Contact> associatedContacts = [SELECT Email, Phone FROM Contact WHERE AccountId = :opportunityVendaRd.AccountId];

                    for (Contact contact : associatedContacts) {
                        // Se o Lead.Phone ou Lead.Email for diferente do Phone ou Email da oportunidade, criamos um novo contato;
                        if (contact.Email != lead.Email || contact.Phone != lead.Phone) {
                            Contact newContact = ContactService.createContact(
                                lead.FirstName,
                                lead.LastName,
                                opportunityVendaRd.AccountId,
                                lead.Email,
                                lead.Phone
                            );
                            contactToInsert.add(newContact);
                        }
                    }
                }
            }

            // Inserção da oportunidade de renovação;
            if (!opportunities.isEmpty()) {
                insert opportunities;
            }

            for (Opportunity originalOpp : clonedOpportunitiesMap.keySet()) {
                // buscamos a oportunidade clonada;
                Opportunity opportunityRenovacao = clonedOpportunitiesMap.get(originalOpp);
                Task newTask;

                if (originalOpp.Owner.IsActive) {
                    //Criação de task com owner ativo;
                    result = TaskService.createTaskDuplicateOpportunity(opportunityRenovacao, opportunityRenovacao.Owner);
                    System.debug('New Task: ' + result.task);
                } else {
                    User inactiveUser;
                    inactiveUser = [SELECT Id, Name, Email, isActive FROM User WHERE Id = :originalOpp.OwnerId LIMIT 1];

                    //Criação de task para o activeUser;
                    result = TaskService.createTaskDuplicateOpportunity(opportunityRenovacao, activeUser);
                    Messaging.SingleEmailMessage email = EmailService.sendEmailOwnerReplacement(opportunityRenovacao, activeUser, inactiveUser);
                    emailToSend.add(email);
                }
                if (result != null && result.task != null && result.emails != null) {
                    taskToInsert.add(result.task);
                    emailToSend.add(result.emails);
                }
            }

            if (!taskToInsert.isEmpty()) {
                insert taskToInsert;
            }

            if (!contactToInsert.isEmpty()) {
                insert contactToInsert;
            }

            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }

            if (!emailToSend.isEmpty()) {
                Messaging.sendEmail(emailToSend);
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'Método: checkDuplicateLeadAndOpportunitiesVendaRd');
            throw e;
        }
    }

    public static String setContactIdWhenEmpty(List<Opportunity> oppList) {
        List<String> oppEmails = new List<String>();
        Map<Id, Opportunity> mapAccIdOpp = new Map<Id, Opportunity>();
        Map<Id, Contact> mapAccIdContact = new Map<Id, Contact>();
        List<Contact> contacts = new List<Contact>();
        List<OpportunityContactRole> oppContRole = new List<OpportunityContactRole>();

        try {
            for (Opportunity opportunity : oppList) {
                if (opportunity.ContactId == null) {
                    oppEmails.add(opportunity.Emaill__c);
                    mapAccIdOpp.put(opportunity.AccountId, opportunity);
                }
            }

            contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :mapAccIdOpp.keySet() AND Email IN :oppEmails ORDER BY CreatedDate ASC];

            if (!contacts.isEmpty()) {
                for (Contact contact : contacts) {
                    mapAccIdContact.put(contact.AccountId, contact);
                }

                for (Id accountId : mapAccIdOpp.keySet()) {
                    Opportunity opportunity = mapAccIdOpp.get(accountId);
                    Contact contact = mapAccIdContact.get(accountId);

                    OpportunityContactRole newRole = new OpportunityContactRole(OpportunityId = opportunity.Id, ContactId = contact.Id, IsPrimary = true);
                    oppContRole.add(newRole);
                }

                if (!oppContRole.isEmpty()) {
                    insert oppContRole;
                }
            }
            return 'Oportunidades com ContactIds preenchidos com sucesso';
        } catch (Exception e) {
            System.debug('Mensagem da exceção: ' + e.getMessage());
            LoggerUtility.createLogException(e, null, 'setContactIdWhenEmpty');
            return 'Oportunidades não foram preenchidos com os ContactIds';
        }
    }

    /**
     * @description Caso uma oportunidade é dada como "Ganho" ou "Ganho Pagamento Futuro" e possuir produto inativo, e voltado o StageName para o anterior e envia um email para o Marcos informando sobre o ocorrido
     * @author Iago Marcelino | 31-03-2025
     * @param opportunities
     * @param oldMapOpp
     **/
    public static void sendEmailProductInactive(List<Opportunity> opportunities, Map<Id, Opportunity> oldMapOpp) {
        try {
            List<Id> opportunitiesGanhoIds = new List<Id>();
            Set<Id> opportunitiesWithInactiveProducts = new Set<Id>();

            for (Opportunity opp : opportunities) {
                Opportunity oldOpp = oldMapOpp.get(opp.Id);
                if (oldOpp != null && oldOpp.StageName != opp.StageName && (opp.StageName == 'Ganho' || opp.StageName == 'Ganho Pagamento Futuro')) {
                    opportunitiesGanhoIds.add(opp.Id);
                }
            }

            if (opportunitiesGanhoIds.isEmpty()) {
                return;
            }

            for (OpportunityLineItem oli : [
                SELECT OpportunityId
                FROM OpportunityLineItem
                WHERE Product2.IsActive = FALSE AND OpportunityId IN :opportunitiesGanhoIds
            ]) {
                opportunitiesWithInactiveProducts.add(oli.OpportunityId);
            }

            // Se houver oportunidades com produtos inativos, é enviado um email para Marcos Torres
            if (!opportunitiesWithInactiveProducts.isEmpty()) {
                // Dispara o envio dos emails de forma assíncrona
                List<EmailRequest__e> events = new List<EmailRequest__e>();

                for (Id oppId : opportunitiesWithInactiveProducts) {
                    events.add(new EmailRequest__e(OpportunityId__c = oppId));
                }

                if (!events.isEmpty()) {
                    EventBus.publish(events);
                }

                for (Opportunity opp : opportunities) {
                    if (opportunitiesWithInactiveProducts.contains(opp.Id)) {
                        Opportunity oldOpp = oldMapOpp.get(opp.Id);
                        opp.StageName = oldOpp.StageName;
                        opp.addError('Não é possível fechar esta oportunidade pois ela contém produtos inativos. Um e-mail foi enviado para o Administrador.');
                    }
                }
            }
        } catch (Exception e) {
            LoggerUtility.createLogException(e, null, 'sendEmailProductInactive');
            throw e;
        }
    }

    public static void handleOpportunityChanges(List<Opportunity> opportunities, Map<Id, Opportunity> oldMapOpp) {
        System.debug('*--* Chamou o handleOpportunityChanges, opps: ' + opportunities.size() + ' oldMap: ' + oldMapOpp.size());

        CurationService.handleCuration(opportunities, oldMapOpp);
        CustomerCommunityService.handleAccess(opportunities, oldMapOpp);
    }

    public static void applyNegotiationTemperatureRules(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunityMap) {
        for (Opportunity opp : opportunities) {
            Opportunity oldOpp = oldOpportunityMap != null ? oldOpportunityMap.get(opp.Id) : null;

            if (opp.Funnel__c == 'Varejo') {
                if (oldOpp != null) {
                    processUpdateRules(opp, oldOpp);
                } else {
                    checkInsertRules(opp);
                }
            }
        }
    }

    private static void processUpdateRules(Opportunity opp, Opportunity oldOpp) {
        if (oldOpp.Cota_es_na_oportunidade__c == 0 && opp.Cota_es_na_oportunidade__c != 0) {
            opp.Temperatura_da_negociacao__c = 'Frio';
        }
        if (oldOpp.Cota_es_na_oportunidade__c == 0 && opp.Cota_es_na_oportunidade__c == 0 && opp.Temperatura_da_negociacao__c != null) {
            opp.addError('Para alterar a Temperatura da Negociação, deve-se ter proposta válida (<7 dias)');
        }
        if (
            oldOpp.Temperatura_da_negociacao__c != null &&
            opp.Proposta_v_lida__c == 'SEM PROPOSTA VÁLIDA' &&
            opp.Temperatura_da_negociacao__c != oldOpp.Temperatura_da_negociacao__c
        ) {
            opp.addError('Para alterar a Temperatura da Negociação, deve-se ter proposta válida (<7 dias)');
        }
        if (oldOpp.Temperatura_da_negociacao__c != null && opp.Temperatura_da_negociacao__c == null) {
            opp.addError('Não é possível retirar a seleção de temperatura');
        }
    }

    private static void checkInsertRules(Opportunity opportunity) {
        if (opportunity.Proposta_v_lida__c == 'SEM PROPOSTA VÁLIDA' && opportunity.Temperatura_da_negociacao__c != null) {
            opportunity.addError('Para alterar a Temperatura da Negociação, deve-se ter proposta válida (<7 dias)');
        }
    }
}