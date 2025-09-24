/**
 * @description       : Service class to manage customer community access for contacts
 *                      based on opportunity stage changes and contract validity.
 * @author            : Vinícius Caetano
 * @last modified on  : 09-06-2025
 * @last modified by  : Vinícius Caetano
 **/
public with sharing class CustomerCommunityService {
    /*──────────────────────── CONSTANTES ────────────────────────*/
    private static final String COMMUNITY_PROFILE_NAME = 'Parceiro Performance';
    private static final String TIMEZONE_SID_KEY = 'America/Sao_Paulo';
    private static final String LOCALE_SID_KEY = 'pt_BR';
    private static final String EMAIL_ENCODING_KEY = 'UTF-8';
    private static final String LANGUAGE_LOCALE_KEY = 'pt_BR';
    private static final String DEFAULT_LAST_NAME = 'Aceleraí Performance';
    private static final Integer ALIAS_MAX_LENGTH = 4;
    private static final String TARGET_PRODUCT_NAME = 'Aceleraí Performance';
    private static final String USERNAME_DOMAIN = '@aceleraiperformance.com';

    /* Estágios que concedem acesso */
    private static final Set<String> TARGET_STAGES = new Set<String>{ 'Venda Futura', 'Ganho Pagamento Futuro', 'Ganho', 'Ganho RD' };

    /*──────────────────── MÉTODO PRINCIPAL ────────────────────*/
    /**
     * Analisa oportunidades alteradas, concede ou revoga acesso
     * à Experience Cloud conforme regras de estágio e datas de contrato.
     *
     * @param newOpps    Lista Trigger.new
     * @param oldOppsMap Trigger.oldMap
     */
    public static void handleAccess(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap) {
        System.debug('Chamou o handleAccess' + newOpps + ' , ' + oldOppsMap);

        if (newOpps == null || newOpps.isEmpty())
            return;

        /* Coleções auxiliares */
        Set<Id> oppIdsToCheck = new Set<Id>(); // Para confirmar produto-alvo
        Set<Id> grantIds = new Set<Id>(); // Contatos a ativar
        Set<Id> revokeIds = new Set<Id>(); // Contatos a desativar
        Date today = Date.today();

        /*────────── 1. Filtra oportunidades relevantes ──────────*/
        for (Opportunity opp : newOpps) {
            Opportunity oldOpp = oldOppsMap.get(opp.Id);

            /* Contato obrigatório */
            if (opp.ContactId == null)
                continue;

            /* Verificar apenas mudanças de estágio */
            Boolean stageChanged = oldOpp == null ? true : opp.StageName != oldOpp.StageName;
            if (!stageChanged)
                continue;

            /* Novo estágio está em TARGET_STAGES? */
            Boolean isActiveStage = TARGET_STAGES.contains(opp.StageName);
            Boolean wasActiveStage = oldOpp != null && TARGET_STAGES.contains(oldOpp.StageName);

            DateTime startDateTime = opp.ContractStartDate__c;
            Date dataInicioContrato = startDateTime != null ? startDateTime.date() : null;

            DateTime endDateTime = opp.EndOfContractDate__c;
            Date dataFimContrato = endDateTime != null ? endDateTime.date() : null;

            // Verifica se ambas as datas do contrato estão vazias
            Boolean contractDatesEmpty = dataInicioContrato == null && dataFimContrato == null;

            // Verifica se as datas do contrato são válidas
            Boolean contractDatesValid =
                dataInicioContrato != null &&
                dataFimContrato != null &&
                dataInicioContrato <= Date.today() &&
                dataFimContrato >= Date.today();

            /* Decide ações com base no estágio e nas datas */
            if (isActiveStage && (contractDatesEmpty || contractDatesValid)) {
                // Cenário: Novo estágio é TARGET_STAGES e (datas vazias OU datas preenchidas e válidas)
                oppIdsToCheck.add(opp.Id); // Confirmar produto
                System.debug('oppIdsToCheck: ' + oppIdsToCheck);
            } else if (!isActiveStage && wasActiveStage) {
                // Cenário: Novo estágio não é TARGET_STAGES e o anterior era, revogar acesso
                revokeIds.add(opp.ContactId);
            }
        }

        /*────────── 2. Confirma produto "Aceleraí Performance" ──────────*/
        if (!oppIdsToCheck.isEmpty()) {
            for (OpportunityLineItem oli : [
                SELECT OpportunityId, Opportunity.ContactId
                FROM OpportunityLineItem
                WHERE OpportunityId IN :oppIdsToCheck AND Product2.Name = :TARGET_PRODUCT_NAME
            ]) {
                grantIds.add(oli.Opportunity.ContactId);
            }
        }

        /*────────── 3. Concede / Revoga acesso ──────────*/
        if (!grantIds.isEmpty()) {
            System.debug('grantIds: ' + grantIds);
            grantAccessForContacts(grantIds);
        }

        if (!revokeIds.isEmpty()) {
            revokeAccessForContacts(revokeIds);
        }
    }

    /*──────────────────── CONCEDER ACESSO ────────────────────*/
    public static void grantAccessForContacts(Set<Id> contactIds) {
        Set<Id> accountIds = new Set<Id>();

        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, AccountId, Account.Name
            FROM Contact
            WHERE Id IN :contactIds AND AccountId != NULL
        ];
        if (contacts.isEmpty())
            return;

        /* Certifica-se de que todas as contas sejam parceiras */
        for (Contact c : contacts) {
            accountIds.add(c.AccountId);
        }

        enablePartner(accountIds);

        Id communityProfileId = getCommunityProfileId();
        if (communityProfileId == null) {
            LoggerUtility.createLog('Community Profile not found.', 'grantAccessForContacts');
            return;
        }

        Map<Id, User> existingUsers = getExistingUsers(contactIds, communityProfileId);

        List<User> toInsert = new List<User>();
        List<User> toUpdate = new List<User>();

        for (Contact con : contacts) {
            if (String.isBlank(con.Email)) {
                LoggerUtility.createLog('Email not found for contact ' + con.Id, 'grantAccessForContacts');
                continue;
            }

            User usr = existingUsers.get(con.Id);
            if (usr != null) {
                System.debug('Usuário já existe');
                if (!usr.IsActive) {
                    usr.IsActive = true;
                    toUpdate.add(usr);
                }
            } else {
                System.debug('Usuário ainda não existe');
                User newUsr = createCommunityUser(con, communityProfileId);
                System.debug('newUsr : ' + newUsr);
                if (newUsr != null)
                    toInsert.add(newUsr);
            }
        }
        performDmlOperations(toInsert, toUpdate);
    }

    /*─────────────────── REVOGAR ACESSO ───────────────────*/
    public static void revokeAccessForContacts(Set<Id> contactIds) {
        Id profileId = getCommunityProfileId();
        if (profileId == null) {
            LoggerUtility.createLog('Community Profile not found.', 'revokeAccessForContacts');
            return;
        }

        Map<Id, User> users = getExistingUsers(contactIds, profileId);
        List<Id> toDeactivate = new List<Id>();

        for (User u : users.values()) {
            if (u.IsActive)
                toDeactivate.add(u.Id);
        }
        if (!toDeactivate.isEmpty()) {
            UserActivationService.deactivateUsers(toDeactivate);
        }
    }

    /*─────────────────── HELPERS PRIVADOS ──────────────────*/
    public static Id getCommunityProfileId() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = :COMMUNITY_PROFILE_NAME
            LIMIT 1
        ];
        return p == null ? null : p.Id;
    }

    private static Map<Id, User> getExistingUsers(Set<Id> contactIds, Id profileId) {
        Map<Id, User> mapU = new Map<Id, User>();
        for (User u : [
            SELECT Id, ContactId, IsActive
            FROM User
            WHERE ContactId IN :contactIds AND ProfileId = :profileId
        ]) {
            mapU.put(u.ContactId, u);
        }
        return mapU;
    }

    public static User createCommunityUser(Contact con, Id profileId) {
        System.debug('Chamou o createCommunityUser');

        String firstName;
        if (String.isNotBlank(con.FirstName)) {
            firstName = con.FirstName;
        } else if (con.Account != null && String.isNotBlank(con.Account.Name)) {
            firstName = con.Account.Name;
        } else if (con.AccountId != null) {
            firstName = [SELECT Name FROM Account WHERE Id = :con.AccountId].Name;
        } else {
            firstName = 'Parceiro';
        }
        System.debug('firstName : ' + firstName);

        String alias = firstName.left(ALIAS_MAX_LENGTH);

        if (String.isBlank(con.Email) || !con.Email.contains('@')) {
            LoggerUtility.createLog('Invalid email for contact ' + con.Id, 'createCommunityUser');
            return null;
        }
        String emailLocalPart = con.Email.split('@')[0];
        String customEmail = emailLocalPart + USERNAME_DOMAIN;

        return new User(
            FirstName = firstName,
            LastName = String.isNotBlank(con.LastName) ? con.LastName : DEFAULT_LAST_NAME,
            Email = con.Email,
            Username = customEmail,
            Alias = alias,
            TimeZoneSidKey = TIMEZONE_SID_KEY,
            LocaleSidKey = LOCALE_SID_KEY,
            EmailEncodingKey = EMAIL_ENCODING_KEY,
            LanguageLocaleKey = LANGUAGE_LOCALE_KEY,
            ProfileId = profileId,
            ContactId = con.Id,
            IsActive = true
        );
    }

    public static void performDmlOperations(List<User> toInsert, List<User> toUpdate) {
        System.debug('Chamou o performDmlOperations : ' + toInsert);

        if (!toInsert.isEmpty()) {
            try {
                System.debug('toInsert : ' + toInsert);
                Database.insert(toInsert, false);
            } catch (Exception e) {
                for (User u : toInsert) {
                    System.debug('Erro na inserção:' + e.getMessage());
                    LoggerUtility.createLogException(e, u.ContactId, 'insertUser');
                }
            }
        }
        if (!toUpdate.isEmpty()) {
            try {
                List<Id> ids = new List<Id>();
                for (User u : toUpdate)
                    ids.add(u.Id);
                UserActivationService.activateUsers(ids);
            } catch (Exception e) {
                for (User u : toUpdate) {
                    LoggerUtility.createLogException(e, u.ContactId, 'updateUser');
                }
            }
        }
    }

    public static void enablePartner(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty())
            return;

        List<Account> toEnable = new List<Account>();

        for (Account acc : [
            SELECT Id, IsPartner
            FROM Account
            WHERE Id IN :accountIds AND IsPartner = FALSE
        ]) {
            acc.IsPartner = true;
            toEnable.add(acc);
        }

        if (!toEnable.isEmpty()) {
            update toEnable;
        }
    }
    public static void enablePartner(Id accountId) {
        enablePartner(new Set<Id>{ accountId });
    }
}