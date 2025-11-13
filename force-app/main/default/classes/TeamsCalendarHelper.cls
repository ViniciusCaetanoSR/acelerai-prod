/**
 * Helper para gerenciar calendário dedicado do Salesforce no Microsoft Teams/Outlook.
 * Evita que Einstein Activity Capture duplique eventos criados via integração.
 */
public without sharing class TeamsCalendarHelper {
    private static final String SALESFORCE_CALENDAR_NAME = 'Salesforce';

    /**
     * Obtém ou cria o calendário dedicado do Salesforce no Teams/Outlook do usuário.
     * Armazena o calendarId no campo User.TeamsCalendarId__c para reuso.
     *
     * @param owner Registro do User com TeamsCalendarId__c
     * @param accessToken Token de acesso válido do Teams
     * @return calendarId do calendário 'Salesforce' ou null em caso de erro
     */
    public static String getOrCreateSalesforceCalendar(User owner, String accessToken) {
        System.debug('~~ START > getOrCreateSalesforceCalendar para user: ' + owner.Id);

        if (String.isNotBlank(owner.TeamsCalendarId__c)) {
            System.debug('~~ TeamsCalendarId já existe: ' + owner.TeamsCalendarId__c);
            return owner.TeamsCalendarId__c;
        }

        try {
            String existingCalendarId = findSalesforceCalendar(accessToken);

            if (String.isNotBlank(existingCalendarId)) {
                System.debug('~~ Calendário Salesforce encontrado: ' + existingCalendarId);
                TeamsIntegrationRepository.saveCalendarIdToUser(owner.Id, existingCalendarId);
                return existingCalendarId;
            }

            String newCalendarId = createSalesforceCalendar(accessToken);

            if (String.isNotBlank(newCalendarId)) {
                System.debug('~~ Calendário Salesforce criado: ' + newCalendarId);
                TeamsIntegrationRepository.saveCalendarIdToUser(owner.Id, newCalendarId);
                return newCalendarId;
            }

        } catch (Exception e) {
            System.debug('~~ ERRO ao obter/criar calendário Salesforce: ' + e.getMessage());
        }

        return null;
    }

    /**
     * Busca calendário existente com nome 'Salesforce' via Graph API
     */
    private static String findSalesforceCalendar(String accessToken) {
        System.debug('~~ Buscando calendário existente...');

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://graph.microsoft.com/v1.0/me/calendars');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> calendars = (List<Object>) body.get('value');

            if (calendars != null) {
                for (Object obj : calendars) {
                    Map<String, Object> calendar = (Map<String, Object>) obj;
                    String calendarName = (String) calendar.get('name');
                    System.debug('DEBUG X: Retornou Id do Calendário');

                    if (calendarName == SALESFORCE_CALENDAR_NAME) {
                        return (String) calendar.get('id');
                    }
                }
            }
        } else {
            System.debug('~~ Erro ao buscar calendários. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
        }

        return null;
    }

    /**
     * Cria novo calendário 'Salesforce' via Graph API
     */
    private static String createSalesforceCalendar(String accessToken) {
        System.debug('~~ Criando novo calendário Salesforce...');

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://graph.microsoft.com/v1.0/me/calendars');
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'name' => SALESFORCE_CALENDAR_NAME,
            'color' => 'lightBlue'
        };
        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 201) {
            Map<String, Object> created = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) created.get('id');
        } else {
            System.debug('~~ Erro ao criar calendário. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
        }

        return null;
    }
}