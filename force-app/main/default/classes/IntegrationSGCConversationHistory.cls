@RestResource(urlMapping='/ReceiveConversationHistory/*')
global class IntegrationSGCConversationHistory {
    global class ConversationHistoryRequestBody {
        public List<HistoryRecord> history;
        public String opportunity_id;
        public String lead_id;
        public String employee_email;
    }

    global class HistoryRecord {
        public String created_at;
        public String message;
        public String fromName;
    }

    @HttpPost
    global static String receiveConversationHistory() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String retorno = '';
        String employeeName = '';
        String idByEmail = '';
        try {
            if (req.requestBody.toString().length() == 0) {
                res.statusCode = 400;
                retorno = 'A requisição é inválida';
                return retorno;
            }

            String body = req.requestBody.toString();
            ConversationHistoryRequestBody requestBody;

            try {
                requestBody = (ConversationHistoryRequestBody) JSON.deserialize(body, ConversationHistoryRequestBody.class);
            } catch (Exception e) {
                res.statusCode = 400;
                throw new JSONException('Erro ao deserializar JSON: ' + e.getMessage() + '. Erro na linha: ' + e.getLineNumber());
            }

            if (requestBody.history == null || requestBody.history.isEmpty()) {
                res.statusCode = 400;
                retorno = 'Histórico não fornecido';
                return retorno;
            }

            System.debug('Processando requisição: ' + requestBody);

            List<ConversationHistory__c> recordsToInsert = new List<ConversationHistory__c>();

            ConversationHistory__c sfRecord = new ConversationHistory__c();
            sfRecord.Opportunity_id__c = requestBody.opportunity_id;

            if (requestBody.lead_id != null && requestBody.lead_id != '') {
                try {
                    Lead leadRecord = [SELECT Id FROM Lead WHERE Id = :requestBody.lead_id LIMIT 1];
                    sfRecord.Lead_id__c = leadRecord.Id;
                } catch (Exception e) {
                    res.statusCode = 400;
                    return 'ID de lead inválido';
                }
            } else {
                sfRecord.Lead_id__c = null;
            }
            
            sfRecord.Message__c = '';

            List<User> getSfEmail = [SELECT Id, Email, Name FROM User WHERE Email = :requestBody.employee_email LIMIT 1];

            if (!getSfEmail.isEmpty()) {
                employeeName = getSfEmail[0].Name;
                idByEmail = getSfEmail[0].Id;
                sfRecord.Employee_id__c = idByEmail;
            }

            Date lastDate = null;

            for (HistoryRecord history : requestBody.history) {
                Date currentDate = Date.valueOf(history.created_at);

                if (lastDate != null && currentDate != lastDate) {
                    sfRecord.Message__c += '\n<br/>';
                }

                sfRecord.Message__c += '\n<br/>[Data: ' + history.created_at + '] ' + history.fromName + ': ' + history.message;
                lastDate = currentDate;
                sfRecord.Name = employeeName + ' [' + history.created_at + ']';
            }

            System.debug('Registro a ser inserido: ' + sfRecord);
            recordsToInsert.add(sfRecord);

            if (!recordsToInsert.isEmpty()) {
                try {
                    insert recordsToInsert;
                    System.debug('Registros inseridos com sucesso.');
                } catch (DmlException dmlEx) {
                    System.debug('Erro ao tentar inserir o registro: ' + dmlEx.getMessage());
                    for (Database.SaveResult sr : Database.insert(recordsToInsert, false)) {
                        if (!sr.isSuccess()) {
                            System.debug('Erro de DML: ' + sr.getErrors()[0].getMessage());
                        }
                    }
                }
            } else {
                System.debug('Nenhum registro para inserir.');
            }

            for (ConversationHistory__c hist : recordsToInsert) {
                retorno = hist.Id;
                return retorno;
            }
        } catch (Exception e) {
            if (e instanceof JSONException) {
                res.statusCode = 400;
                throw new JSONException('Erro ao deserializar JSON: ' + e.getMessage() + '. Erro na linha: ' + e.getLineNumber());
            } else if (e instanceof DmlException) {
                res.statusCode = 400;
                throw new DmlException('Erro de DML: ' + e.getMessage() + '. Erro na linha: ' + e.getLineNumber());
            } else {
                res.statusCode = 400;
                retorno = 'Erro ao processar os dados';
            }

            return retorno;
        }

        res.statusCode = 200;
        retorno = 'Dados processados com sucesso';
        return retorno;
    }
}