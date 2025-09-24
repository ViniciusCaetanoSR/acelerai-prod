@isTest
public class KanbanConfigListTest {
    @isTest
    static void testGetDefaultValue() {
        // Arrange: create a KanbanConfiguration__c record for testing
        KanbanConfiguration__c kanbanConfig = new KanbanConfiguration__c(Name = 'Test Kanban Config');
        insert kanbanConfig;

        // Act: create an instance of KanbanConfigList and call getDefaultValue
        KanbanConfigList kanbanConfigList = new KanbanConfigList();
        VisualEditor.DataRow defaultValue = kanbanConfigList.getDefaultValue();

        // Assert: verify that the default value is correct
        System.assertEquals(kanbanConfig.Id, defaultValue.getValue(), 'Default value ID does not match');
        System.assertEquals(kanbanConfig.Name, defaultValue.getLabel(), 'Default value Name does not match');
    }

    @isTest
    static void testGetValues() {
        // Arrange: create multiple KanbanConfiguration__c records for testing
        KanbanConfiguration__c kanbanConfig1 = new KanbanConfiguration__c(Name = 'Kanban Config 1');
        KanbanConfiguration__c kanbanConfig2 = new KanbanConfiguration__c(Name = 'Kanban Config 2');
        insert new List<KanbanConfiguration__c>{kanbanConfig1, kanbanConfig2};

        // Act: create an instance of KanbanConfigList and call getValues
        KanbanConfigList kanbanConfigList = new KanbanConfigList();
        VisualEditor.DynamicPickListRows values = kanbanConfigList.getValues();

        // Assert: verify that the values contain the correct number of rows and data
        System.assertEquals(2, values.size(), 'Number of rows in values does not match');
        Set<Id> expectedIds = new Set<Id>{kanbanConfig1.Id, kanbanConfig2.Id};
        for (Integer i = 0; i < values.size(); i++) {
            VisualEditor.DataRow row = values.get(i);
            System.assert(expectedIds.contains((Id)row.getValue()), 'Value ID not found in expected IDs');
        }
    }
}