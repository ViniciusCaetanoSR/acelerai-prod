public with sharing class LoggerUtility {

    private static final Map<String, Id> RECORD_TYPE_CACHE = new Map<String, Id>();
    private static final String EXCEPTION_RECORD_TYPE = 'Exception';
    private static final String INTEGRATION_RECORD_TYPE = 'Integration';

    public static void createLog(String message, String methodName) {
        if (String.isBlank(message)) {
            System.debug('Mensagem vazia, log não criado.');
            return;
        }

        try {
            Log__c log = buildGenericLog(message, methodName);
            insertLog(log);
        } catch (Exception ex) {
            System.debug('Falha ao criar registro de log genérico: ' + ex.getMessage());
        }
    }

    public static void createLogException(Exception e, String relatedRecordId, String methodName) {
        if (e == null) {
            System.debug('Exceção nula, log não criado.');
            return;
        }

        try {
            Log__c log = buildExceptionLog(e, relatedRecordId, methodName);
            insertLog(log);
        } catch (Exception ex) {
            System.debug('Falha ao criar registro de log: ' + ex.getMessage());
        }
    }

    // Método para criar log de sucesso de integração
    public static void createLogIntegrationSuccess(HttpResponse res, String relatedRecordId, String requestBodyJson, String integrationName, String methodName) {
        if (res == null) {
            System.debug('Resposta HTTP nula, log não criado.');
            return;
        }

        try {
            Log__c log = buildIntegrationLog(res, relatedRecordId, requestBodyJson, integrationName, methodName, true);
            insertLog(log);
        } catch (Exception ex) {
            System.debug('Falha ao criar registro de log: ' + ex.getMessage());
        }
    }

    // Método para criar log de falha de integração
    public static void createLogIntegrationException(HttpResponse res, String relatedRecordId, String requestBodyJson, String integrationName, String methodName) {
        if (res == null) {
            System.debug('Resposta HTTP nula, log não criado.');
            return;
        }

        try {
            Log__c log = buildIntegrationLog(res, relatedRecordId, requestBodyJson, integrationName, methodName, false);
            insertLog(log);
        } catch (Exception ex) {
            System.debug('Falha ao criar registro de log: ' + ex.getMessage());
        }
    }

    private static String getStackTrace(Exception e) {
        return String.isNotBlank(e.getStackTraceString()) ? e.getStackTraceString() : 'Stack trace indisponível';
    }

    private static void insertLog(Log__c log) {
        if (log == null || !Schema.sObjectType.Log__c.isCreateable()) {
            System.debug('Permissão insuficiente ou log nulo para inserção.');
            return;
        }
        insert log;
    }

    private static Integer extractLineNumber(String stackTraceLine) {
        Pattern linePattern = Pattern.compile(':\\d+\\)');
        Matcher matcher = linePattern.matcher(stackTraceLine);
        if (matcher.find()) {
            String lineNumber = matcher.group(0).replace(':', '').replace(')', '');
            return Integer.valueOf(lineNumber);
        }
        return null;
    }

    private static String extractMethodName(String stackTraceLine) {
        Pattern methodPattern = Pattern.compile('\\.(\\w+)\\(');
        Matcher matcher = methodPattern.matcher(stackTraceLine);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private static String extractFileName(String stackTraceLine) {
        Pattern filePattern = Pattern.compile('\\(([^:]+):');
        Matcher matcher = filePattern.matcher(stackTraceLine);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    private static Log__c buildExceptionLog(Exception e, String relatedRecordId, String methodName) {
        Log__c log = initializeLog(getRecordTypeId(EXCEPTION_RECORD_TYPE), relatedRecordId, methodName);
        log.ErrorMessage__c = e.getMessage();
        log.StackTrace__c = getStackTrace(e);
        log.ExceptionType__c = e.getTypeName();
        log.Cause__c = e.getCause() != null ? String.valueOf(e.getCause()) : 'null';
        log.StatusLog__c = 'Falha';
        log.LineNumber__c = String.valueOf(e.getLineNumber());
        populateStackTraceDetails(log, log.StackTrace__c);

        return log;
    }

    private static Log__c buildIntegrationLog(HttpResponse res, String relatedRecordId, String requestBodyJson, String integrationName, String methodName, Boolean isSuccess) {
        Log__c log = initializeLog(getRecordTypeId(INTEGRATION_RECORD_TYPE), relatedRecordId, methodName);
        log.StatusCode__c = String.valueOf(res.getStatusCode());
        log.ResponseBody__c = res.getBody();
        log.RequestBody__c = requestBodyJson;
        log.IntegrationSource__c = integrationName;
        log.StatusLog__c = isSuccess ? 'Sucesso' : 'Falha';
        log.ErrorMessage__c = isSuccess ? 'Não houve erros' : extractErrorMessage(res);
        populateStackTraceDetails(log, res.getBody());

        return log;
    }

    private static Log__c initializeLog(Id recordTypeId, String relatedRecordId, String methodName) {
        Log__c log = new Log__c();
        log.RecordTypeId = recordTypeId;
        log.User__c = UserInfo.getUserId();
        log.RelatedRecord__c = relatedRecordId;
        log.MethodName__c = methodName;
        return log;
    }

    private static Id getRecordTypeId(String developerName) {
        if (!RECORD_TYPE_CACHE.containsKey(developerName)) {
            List<RecordType> recordTypes = [
                SELECT Id 
                FROM RecordType 
                WHERE SObjectType = 'Log__c' 
                AND DeveloperName = :developerName 
                WITH SECURITY_ENFORCED 
                LIMIT 1
            ];
            if (recordTypes.isEmpty()) {
                System.debug('RecordType "' + developerName + '" não encontrado.');
                return null;
            }
            RECORD_TYPE_CACHE.put(developerName, recordTypes[0].Id);
        }
        return RECORD_TYPE_CACHE.get(developerName);
    }

    private static void populateStackTraceDetails(Log__c log, String stackTrace) {
        if (String.isNotBlank(stackTrace)) {
            String[] lines = stackTrace.split('\n');
            if (!lines.isEmpty()) {
                log.FileName__c = extractFileName(lines[0]);
            }
        }
    }

    private static String extractErrorMessage(HttpResponse res) {
        String header = res.getHeader('');
        return String.isNotBlank(header) ? header : res.getBody();
    }

    private static Log__c buildGenericLog(String message, String methodName) {
        Log__c log = initializeLog(getRecordTypeId(EXCEPTION_RECORD_TYPE), null, methodName);
        log.ErrorMessage__c = message; 
        log.StatusLog__c = 'Falha';
        return log;
    }
}