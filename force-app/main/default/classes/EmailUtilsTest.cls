@isTest
public class EmailUtilsTest {

    @isTest
    static void testSendEmail() {

        String subject = 'Teste nova task criada';
        String body = 'Uma nova tarefa foi criada';
        String emailToSend = 'test@example.com';
        
        Test.startTest();
        Messaging.SingleEmailMessage email = EmailUtils.createEmailMessage(subject, body, emailToSend);
        Test.stopTest();

        System.assertNotEquals(null, email, 'O e-mail deve ser criado.');
        System.assertEquals(subject, email.getSubject(), 'O assunto do e-mail deve corresponder.');
        System.assertEquals(body, email.getHtmlBody(), 'O corpo do e-mail deve corresponder.');
        System.assertEquals(
            1, 
            email.getToAddresses().size(), 
            'Deve haver apenas um destinatário no e-mail.'
        );
        System.assertEquals(
            emailToSend, 
            email.getToAddresses()[0], 
            'O destinatário do e-mail deve corresponder ao e-mail fornecido.'
        );
        
    }

}