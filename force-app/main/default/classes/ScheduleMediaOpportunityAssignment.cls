public class ScheduleMediaOpportunityAssignment implements Schedulable{
    public void execute(SchedulableContext SC) {
        MediaOpportunityAssignmentBatch batch = new MediaOpportunityAssignmentBatch();
        Database.executeBatch(batch);
    }
    
     public static void scheduleJob() {
        String cronExp = '0 0 7 * * ?';
        String jobId = System.schedule('Daily update Opportunity', cronExp, new ScheduleMediaOpportunityAssignment());

    }
}