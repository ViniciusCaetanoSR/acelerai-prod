public with sharing class EmailUtils {
    public static Messaging.SingleEmailMessage createEmailMessage(String subject, String body, String emailToSend) {
        OrgWideEmailAddress owea = [SELECT Id, Address  FROM OrgWideEmailAddress where Address = 'marcos.torres@acelerai.com.br' LIMIT 1];

        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
        emailMsg.setToAddresses(new List<String>{ emailToSend });
        emailMsg.setSubject(subject);
        emailMsg.setHtmlBody(body);
        emailMsg.setOrgWideEmailAddressId(owea.Id);

        return emailMsg;
    }
}