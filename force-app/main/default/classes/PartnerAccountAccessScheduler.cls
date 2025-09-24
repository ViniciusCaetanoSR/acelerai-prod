/**
 * @description       : Revoga o acesso de contatos cujos parceiros expiraram.
 * @author            : Vinícius Caetano
 * @last modified on  : 05-06-2025
 */
public with sharing class PartnerAccountAccessScheduler implements Schedulable {
    //────────────────────────── MÉTODO PRINCIPAL DE NEGÓCIO ──────────────────────────
    /**
     * Contém toda a lógica de busca e revogação de acesso.
     * É reaproveitado tanto pelo job agendado (execute) quanto pelo método runNow().
     */
    private static void revokeExpiredPartnerContacts() {
        Set<Id> contactIds = new Set<Id>();

        for (Account acc : [
            SELECT Id, (SELECT Id FROM Contacts)
            FROM Account
            WHERE IsPartner = TRUE AND DataMaxTermino__c != NULL AND DataMaxTermino__c < :Date.today()
        ]) {
            for (Contact c : acc.Contacts) {
                contactIds.add(c.Id);
            }
        }

        if (!contactIds.isEmpty()) {
            CustomerCommunityService.revokeAccessForContacts(contactIds);
        }
    }

    //────────────────────────── Schedulable ──────────────────────────
    /**
     * Executado automaticamente pelo agendador da Salesforce.
     */
    public void execute(SchedulableContext sc) {
        revokeExpiredPartnerContacts();
    }

    //────────────────────────── EXECUÇÃO IMEDIATA ──────────────────────────
    /**
     * Permite disparar o processo sob demanda.
     * Ex.: PartnerAccountAccessScheduler.runNow();
     */
    public static void runNow() {
        revokeExpiredPartnerContacts();
    }

    //────────────────────────── AGENDAMENTO ──────────────────────────
    /**
     * Agenda o job diário às 01h00 (fuso da org).
     * Caso já exista um job com o mesmo nome, ele é abortado e re-agendado.
     */
    public static void scheduleJob() {
        String jobName = 'Partner Account Access Revoke Job';
        String cronExp = '0 0 1 * * ?'; // 01:00 todos os dias

        // Remove qualquer job existente com o mesmo nome
        for (CronTrigger ct : [
            SELECT Id
            FROM CronTrigger
            WHERE CronJobDetail.Name = :jobName
        ]) {
            System.abortJob(ct.Id);
        }

        // Agenda novamente
        System.schedule(jobName, cronExp, new PartnerAccountAccessScheduler());
    }

    // Agenda o job diário às 01 h00 (fuso da org)
    // PartnerAccountAccessScheduler.scheduleJob();
}