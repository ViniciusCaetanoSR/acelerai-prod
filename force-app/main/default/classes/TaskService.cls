public with sharing class TaskService {
    public class TaskEmailResult {
        public Task task;
        public Messaging.SingleEmailMessage emails;
        
        public TaskEmailResult(Task task, Messaging.SingleEmailMessage emails) {
            this.task = task;
            this.emails = emails;
        }
    }

    public static TaskEmailResult createTaskDuplicateOpportunity(Opportunity opp, User user) {
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        Task task = new Task();

        task.WhatId = opp.Id;
        task.OwnerId = user.Id;
        task.Subject = 'Contatar essa Oportunidade!';
        task.ActivityDate = Date.today();

        String baseUrl = Url.getOrgDomainUrl().toExternalForm();
        String opportunityLink = baseUrl + '/lightning/r/Opportunity/' + opp.Id + '/view';
        String subject = 'Oportunidade duplicada!';
        String body = 'Novo Lead foi criado para a oportunidade: <a href="' + opportunityLink + '">' + opp.Name + '</a>';

        emailToSend = EmailUtils.createEmailMessage(subject, body, user.Email);    

        return new TaskEmailResult(task, emailToSend);
    }
}