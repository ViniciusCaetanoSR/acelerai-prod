public with sharing class EmailService {
    public static Messaging.SingleEmailMessage sendEmailOwnerReplacement(Opportunity opportunity, User activeUser, User inactiveUser) {

        String userName = inactiveUser != null ? inactiveUser.Name : activeUser.Name;
       
        String formatedDate = (opportunity.CreatedDate != null) ? opportunity.CreatedDate.format() : 'Data não disponível';
        String baseUrl = Url.getOrgDomainUrl().toExternalForm();
        String opportunityLink = baseUrl + '/lightning/r/Opportunity/' + opportunity.Id + '/view';
        String subject = 'Nova Oportunidade - Usuário Inativo';
        String body = 'Olá Marcos,<br>' + 
                    'Uma nova oportunidade foi atribuída a você devido à inatividade do usuário original: ' + userName + '.' +'<br><br>' + 
                    'Detalhes da Oportunidade:<br>' + 
                    'Nome da Oportunidade: <a href="' + opportunityLink + '">' + opportunity.Name + '</a><br>' + 
                    'Motivo da Reatribuição: Usuário original está inativo.<br>' + 
                    'Data da Criação: ' + formatedDate + '<br><br>' + 
                    'Por favor, revise os detalhes da oportunidade no sistema e tome as ações necessárias.<br><br>' + 
                    'Atenciosamente,<br>'; 

        Messaging.SingleEmailMessage email = EmailUtils.createEmailMessage(subject, body, activeUser.Email);
       
        return email; 
    }

    
    public static void sendEmailOpportunityProductInactive(Set<Id> opportunityIds) {
        System.debug('sendEmailOpportunityProductInactive');
        if (opportunityIds == null || opportunityIds.isEmpty()) return;


        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        User activeUser = [SELECT Id, Email FROM User WHERE Name = 'Marcos Torres' LIMIT 1]; 
        String baseUrl = Url.getOrgDomainUrl().toExternalForm();

        for (Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE Id IN :opportunityIds]) {

            String opportunityLink = baseUrl + '/lightning/r/Opportunity/' + opp.Id + '/view';
            String subject = 'Aviso: Oportunidade com Produto Inativo';

            String body = 
                'Olá,<br><br>' +
                'Não foi possível marcar a oportunidade como <strong>Ganho</strong> ou <strong>Ganho - Pagamento Futuro</strong> devido à presença de um produto inativo.<br><br>' +
                '<strong>Detalhes da Oportunidade:</strong><br>' +
                '• Nome: ' + opp.Name + '<br>' +
                '• ID: ' + opp.Id + '<br>' +
                '• Link: <a href="' + opportunityLink + '">' + opp.Name + '</a><br><br>' +
                'Por favor, revise os produtos da oportunidade antes de prosseguir.<br><br>' +
                'Atenciosamente,<br>' +
                'Equipe Aceleraí';
            
            Messaging.SingleEmailMessage email = EmailUtils.createEmailMessage(subject, body, activeUser.Email);
            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            System.debug('Debug x: emailToSend' + emailsToSend);
            Messaging.sendEmail(emailsToSend);
        }
    }
}