global class Schedulable_NitzapChats implements Schedulable {
    global void execute(SchedulableContext sc) {
        Batch_NitzapChats batch = new Batch_NitzapChats();
        Database.executeBatch(batch, 1);
    }
}

// sf project deploy start --metadata ApexClass:Schedulable_NitzapChats --metadata ApexClass:Schedulable_NitzapChats_Test -l RunSpecifiedTests -t Schedulable_NitzapChats_Test -o Connection_Acelerai