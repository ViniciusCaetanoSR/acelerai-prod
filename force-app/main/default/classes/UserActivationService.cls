public class UserActivationService {
    @future
    public static void activateUsers(List<Id> userIds) {
        System.debug('[activateUsers] userIds:' + userIds);

        List<User> users = [SELECT Id, IsActive FROM User WHERE Id IN :userIds];
        for (User u : users) {
            u.IsActive = true;
            System.debug('[activateUsers] u.IsActive:' + u.IsActive);
        }
        update users;
    }

    @future
    public static void deactivateUsers(List<Id> userIds) {
        List<User> users = [SELECT Id, IsActive FROM User WHERE Id IN :userIds];
        for (User u : users) {
            u.IsActive = false;
            System.debug('[deactivateUsers] u.IsActive:' + u.IsActive);
        }
        update users;
    }
}