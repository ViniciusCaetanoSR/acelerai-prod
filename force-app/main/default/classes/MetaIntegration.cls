public class MetaIntegration {
    
    @Future(callout=true)
    public static void sendLeadToMeta(List<Id> leadIds) {
        try {
            List<Lead> leads = LeadSelector.selectLeadMetaIntegration(leadIds);

            if (leads == null || leads.isEmpty()) {
                System.debug('Nenhum lead para enviar');
                return;
            }

            List<Map<String, Object>> data = new List<Map<String, Object>>();
            Meta__c meta = [SELECT Id, Url__c, AcessToken__c, PixelId__c FROM Meta__c WHERE Name = 'Meta' LIMIT 1];
            List<LeadStatusMeta__c> eventNames = [SELECT LeadStatus__c, EventName__c FROM LeadStatusMeta__c];

            for (Lead lead : leads) {
                Map<String, Object> eventData = new Map<String, Object>();
                Map<String, Object> userData = new Map<String, Object>();
                Map<String, Object> customData = new Map<String, Object>();

                Long eventTime = System.currentTimeMillis() / 1000;
                String leadEventSource = 'Salesforce';

                eventData.put('event_name', eventNameToLeadStatus(lead.Status, eventNames));
                eventData.put('event_time', convertToUnix());
                eventData.put('action_source', 'website');
                customData.put('firstName', lead.FirstName);
                customData.put('lastName', lead.LastName);
                customData.put('id', lead.Id);
                customData.put('fbclid', lead.fbclid__c);
                customData.put('lead_id', lead.Metalead_id__c);
                userData.put('email', convertEmailAndPhoneInHash(lead.Email));
                userData.put('phone', convertEmailAndPhoneInHash(lead.phone));
                customData.put('status', lead.Status);
                customData.put('address', lead.Address);
                customData.put('city', lead.City);
                customData.put('cnpj', lead.Cnpj__c);
                customData.put('cnpjNumeros', lead.CnpjNumeros__c);
                customData.put('company', lead.Company);
                customData.put('companyAge', lead.CompanyAge__c);
                customData.put('companyUf', lead.CompanyUF__c);
                customData.put('convertedAccountId', lead.ConvertedAccountId);
                customData.put('convertedContactId', lead.ConvertedContactId);
                customData.put('convertedOpportunityId', lead.ConvertedOpportunityId);
                customData.put('convertedDate', lead.ConvertedDate);
                customData.put('country', lead.Country);
                customData.put('createdDate', lead.CreatedDate);
                customData.put('employeesAmount', lead.EmployeesAmount__c);
                customData.put('entryAttempts', lead.EntryAttempts__c);
                customData.put('HasAgencyCurrently', lead.HasAgencyCurrently__c);
                customData.put('HasBeenAdvertiser', lead.HasBeenAdvertiser__c);
                customData.put('IntendedAnnouncement', lead.IntendedAnnouncement__c);
                customData.put('LeadId', lead.LeadId__c);
                customData.put('Media_Monthly_Investment', lead.Media_Monthly_Investment__c);
                customData.put('Motivo_da_Perda', lead.Motivo_da_Perda__c);
                customData.put('Name', lead.Name);
                customData.put('NumberOfEmployees', lead.NumberOfEmployees);
                customData.put('Role_at_company', lead.Role_at_company__c);
                customData.put('Segmento', lead.Segmento__c);
                customData.put('Utm_campaign', lead.Utm_campaign__c);
                customData.put('Utm_source', lead.Utm_source__c);
                customData.put('Utm_medium', lead.Utm_medium__c);
                customData.put('Utm_term', lead.Utm_term__c);
                customData.put('Utm_content', lead.Utm_content__c);
                customData.put('website', lead.website__c);
                customData.put('WhatsYourInstagram', lead.WhatsYourInstagram__c);
                eventData.put('user_data', userData);
                customData.put('event_source', 'crm');
                customData.put('lead_event_source', leadEventSource);
                eventData.put('custom_data', customData);

                data.add(eventData);

                System.debug('Debug x: Dados do usuário: ' + userData);
                System.debug('Debug x: Dados personalizados: ' + customData);
                System.debug('Debug x: Dados do evento: ' + eventData);
            }

            Map<String, Object> payload = new Map<String, Object>();
            payload.put('data', data);
            payload.put('access_token', meta.AcessToken__c);

            String jsonPayload = JSON.serialize(payload);
            System.debug('jsonPayload>> ' + jsonPayload);

            HttpRequest req = new HttpRequest();
            String endPoint = meta.Url__c + meta.PixelId__c + '/events';
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + meta.AcessToken__c);
            req.setBody(jsonPayload);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (String.valueOf(res.getStatusCode()).startsWith('20')) {
                System.debug('Lead enviado com sucesso para a Meta.');
                System.debug('Status code do if: ' + res.getStatusCode());
                LoggerUtility.createLogIntegrationSuccess(res, '', jsonPayload, 'Meta', 'sendLeadToMeta');
            } else {
                System.debug('Mensagem do else: ' + res.getStatusCode());
                LoggerUtility.createLogIntegrationException(res, '', jsonPayload, 'Meta', 'sendLeadToMeta');
            }
        } catch (Exception e) {
            System.debug('Exceção ao enviar lead para a Meta: ' + e.getMessage());
            LoggerUtility.createLogException(e, '', 'Método: sendLeadToMeta');
        }
    }

    @Future(callout=true)
    public static void sendOpportunityToMeta(List<Id> opportunityIds) {
        try {

            List<Opportunity> opportunities = OpportunitySelector.selectOpportunityMetaIntegration(opportunityIds);
            System.debug('Debug x: opportunities: ' + opportunities);
            
            if (opportunityIds == null || opportunityIds.isEmpty()) {
                System.debug('Nenhuma Oportunidade para enviar');
                return; 
            }

            List<Map<String, Object>> data = new List<Map<String, Object>>();
            Meta__c meta = [SELECT Id, Url__c, AcessToken__c, PixelId__c FROM Meta__c WHERE Name = 'Meta' LIMIT 1];
            List<OpportunityStageMeta__c> eventNames = [SELECT OpportunityStage__c, EventName__c FROM OpportunityStageMeta__c];
            
            for (Opportunity opportunity : opportunities) {
                Map<String, Object> eventData = new Map<String, Object>();
                Map<String, Object> userData = new Map<String, Object>();
                Map<String, Object> customData = new Map<String, Object>();

                
                Long eventTime = System.currentTimeMillis() / 1000;
                String opportunityEventSource = 'Salesforce';

                eventData.put('event_name', eventNameToOpportunityStage(opportunity.StageName, eventNames));
                eventData.put('event_time', convertToUnix());
                eventData.put('action_source', 'website');
                customData.put('lead_id', opportunity.Metalead_id__c);
                customData.put('fbclid', opportunity.fbclid__c);
                customData.put('campaignStartIntention', opportunity.CampaignStartIntention__c);
                customData.put('cidade', opportunity.Cidade__c);
                customData.put('clientsObjectiveWithAcelerai', opportunity.ClientsObjectiveWithAcelerai__c);
                customData.put('closeDate', opportunity.CloseDate);
                customData.put('cnpj', opportunity.Cnpj__c);
                customData.put('cnpjNumeros', opportunity.CnpjNumeros__c);
                customData.put('company', opportunity.Company__c);
                customData.put('companyAge', opportunity.CompanyAge__c);
                customData.put('contract_Start_Date', opportunity.ContractStartDate__c); 
                customData.put('cotacoes_na_oportunidade', opportunity.Cota_es_na_oportunidade__c);
                customData.put('cotacao_Sincronizada', opportunity.CotacaoSincronizada__c);
                customData.put('data_mais_recente_de_proposta', opportunity.Data_mais_recente_de_proposta__c);
                customData.put('created_Date', opportunity.CreatedDate);
                customData.put('funnel', opportunity.Funnel__c);
                customData.put('end_Of_Contract_Date', opportunity.EndOfContractDate__c); 
                customData.put('have_Currently_Agency', opportunity.HaveCurrentlyAgency__c);
                customData.put('ja_foi_anunciante', opportunity.Ja_foi_anunciante__c);
                customData.put('loss_reason', opportunity.Loss_reason__c);
                customData.put('monthly_Investment_Media_Content', opportunity.MonthlyInvestmentMedia_Content__c);
                customData.put('name', opportunity.Name);
                customData.put('number_Employees', opportunity.NumberEmployees__c);
                customData.put('politica_Comercial', opportunity.Pol_tica_Comercial__c);
                customData.put('proposal_Submission_Dates', opportunity.ProposalSubmissionDates__c);
                customData.put('proposta_valida', opportunity.Proposta_v_lida__c);
                customData.put('quando_Pretende_Anunciar', opportunity.QuandoPretendeAnunciar__c);
                customData.put('referencia_base_antiga', opportunity.Referencia_base_antiga__c);
                customData.put('saleType', opportunity.SaleType__c);   
                customData.put('stateYourCompany', opportunity.StateYourCompany__c);
                customData.put('telefone1', opportunity.Telefone1__c);
                customData.put('tipo_de_cliente', opportunity.Tipo_de_cliente__c);
                customData.put('utm_campaign', opportunity.Utm_campaign__c);
                customData.put('utm_source', opportunity.Utm_source__c);
                customData.put('utm_medium', opportunity.Utm_medium__c);
                customData.put('utm_term', opportunity.Utm_term__c);
                customData.put('utm_content', opportunity.Utm_content__c); 
                customData.put('valor_final_da_venda', opportunity.Valor_final_da_venda__c);
                customData.put('valor_m_dio_cotacoes', opportunity.Valor_m_dio_cota_es__c);
                customData.put('veiculacao', opportunity.Veiculacao__c);
                customData.put('whatsYourInstagram', opportunity.WhatsYourInstagram__c);
                customData.put('whatsYourRole', opportunity.WhatsYourRole__c);
                customData.put('accountId', opportunity.AccountId);
                customData.put('contactId', opportunity.ContactId);
                customData.put('contatoComprador', opportunity.ContatoComprador__c);
                customData.put('contatoFinanceiro', opportunity.ContatoFinanceiro__c);
                customData.put('contatosMarketing', opportunity.ContatosMarketing__c);
                customData.put('contatoJuridico', opportunity.ContatoJuridico__c);
                customData.put('lead', opportunity.Lead__c);
                customData.put('relatedOpportunity', opportunity.RelatedOpportunity__c);
                
                userData.put('phone', convertEmailAndPhoneInHash(opportunity.Telefone1__c));
                userData.put('email', convertEmailAndPhoneInHash(opportunity.Emaill__c));
                eventData.put('user_data', userData);
                customData.put('event_source', 'crm');
                customData.put('opportunity_event_source', opportunityEventSource);
                eventData.put('custom_data', customData);
    
                data.add(eventData);

                System.debug('Debug x: Dados do usuário: ' + userData);
                System.debug('Debug x: Dados personalizados: ' + customData);
                System.debug('Debug x: Dados do evento: ' + eventData);
            }

            Map<String, Object> payload = new Map<String, Object>();
            payload.put('data', data);
            payload.put('access_token', meta.AcessToken__c);

            String jsonPayload = JSON.serialize(payload);
            System.debug('jsonPayload>> ' + jsonPayload);

            HttpRequest req = new HttpRequest();
            String endPoint = meta.Url__c + '/' + meta.PixelId__c + '/events';
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + meta.AcessToken__c);
            req.setBody(jsonPayload);

            Http http = new Http();
            HttpResponse res = http.send(req); 

            if (String.valueOf(res.getStatusCode()).startsWith('20')) {
                System.debug('Oportunidade enviada com sucesso para a Meta.');
                System.debug('Status code do if: ' + res.getStatusCode());
                LoggerUtility.createLogIntegrationSuccess(res, '', jsonPayload, 'Meta', 'sendOpportunityToMeta');
            } else {
                System.debug('Mensagem do else: ' + res.getStatusCode());
                LoggerUtility.createLogIntegrationException(res, '', jsonPayload, 'Meta', 'sendOpportunityToMeta');
            }
        } catch (Exception e) {
            System.debug('Exceção ao enviar oportunidade para a Meta: ' + e.getMessage());
            LoggerUtility.createLogException(e, '', 'Método: sendOpportunityToMeta');
        }
    }

    private static String eventNameToLeadStatus(String status, List<LeadStatusMeta__c> eventNames) {
        Map<String, String> mapLeadStatus = new Map<String, String>(); 
        for (LeadStatusMeta__c lead : eventNames) {
            mapLeadStatus.put(lead.LeadStatus__c, lead.EventName__c);
        }
        return mapLeadStatus.get(status);
    }

    private static String eventNameToOpportunityStage(String StageName, List<OpportunityStageMeta__c> eventNames) {
        Map<String, String> mapStageOpportunity = new Map<String, String>(); 
        for (OpportunityStageMeta__c opportunity : eventNames) {
            mapStageOpportunity.put(opportunity.OpportunityStage__c, opportunity.EventName__c);
        }
        return mapStageOpportunity.get(StageName);
    }

    private static Long convertToUnix() {
        Datetime now = Datetime.now();
        Long epochMillis = now.getTime();
        Long unixSeconds = epochMillis / 1000;

        return unixSeconds;
    }

    private static String convertEmailAndPhoneInHash(String input) {
        Blob inputBlob = Blob.valueOf(input);  
        Blob hashBlob = Crypto.generateDigest('SHA-256', inputBlob);  
        return EncodingUtil.convertToHex(hashBlob);  
    }
}