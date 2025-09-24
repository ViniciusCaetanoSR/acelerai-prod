global class Schedulable_Manager implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        Id triggerId = ctx.getTriggerId();
        CronTrigger runningJob = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Acelerai - Schedulable Manager%' AND Id = :triggerId];
        Integer minute = Integer.valueOf(runningJob.CronJobDetail.Name?.split(' - ')?.get(2));
        ScheduleSwitchMinute(minute);
    }

    public static void ReStartProcess(){
        Schedulable_Manager.StopProcess();
        Schedulable_Manager.StartProcess();
    }
    
    public static void StartProcess(){
        for (Integer minute : ScheduleCalendar()) {
            String minuto = minute >= 10 ? ''+minute : '0'+minute;
            System.schedule('Acelerai - Schedulable Manager - '+minuto+'', '0 '+minuto+' * * * ? *', new Schedulable_Manager());
        }
    }
    public static void StopProcess(){
        List<CronTrigger> JOBIDLIST = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Acelerai - Schedulable Manager%'];
        for(CronTrigger job : JOBIDLIST) {
            System.abortJob(job.id);
        }
    }
    public static List<Integer> ScheduleCalendar(){
        List<Integer> minutes = new List<Integer>{
            00,
            02,
            05,
            08,
            10,
            13,
            15,
            18,
            20,
            23, 
            25,
            28, 
            30,
            33,  
            35,
            38,
            40,
            43,
            45,
            48,
            50,
            53,
            55,
            58
        };
        return minutes;
    }
    public static void ScheduleSwitchMinute(Integer minute){
        switch on minute {
            when 00 { 
                ExecuteBatchNitzap();
            }
            when 01 { }
            when 02 {
                ExecuteNitzapGetSummary();
             }
            when 03 { }
            when 04 { }
            when 05 {
                ExecuteBatchNitzap();
             }
            when 06 { }
            when 07 { }
            when 08 {
                ExecuteNitzapGetSummary();
             }
            when 09 { }
            when 10 {
                ExecuteBatchNitzap();
             }
            when 11 { }
            when 12 { }
            when 13 {
                ExecuteNitzapGetSummary();
             }
            when 14 { }
            when 15 {
                ExecuteBatchNitzap();
             }
            when 16 { }
            when 17 { }
            when 18 {
                ExecuteNitzapGetSummary();
             }
            when 19 { }
            when 20 { 
                ExecuteBatchNitzap();
            }
            when 21 { }
            when 22 { }
            when 23 {
                ExecuteNitzapGetSummary();
             }
            when 24 { }
            when 25 {
                ExecuteBatchNitzap();
             }
            when 26 { }
            when 27 { }
            when 28 {
                ExecuteNitzapGetSummary();
             }
            when 29 { }
            when 30 { 
                ExecuteBatchNitzap();
            }
            when 31 { }
            when 32 { }
            when 33 {
                ExecuteNitzapGetSummary();
             }
            when 34 { }
            when 35 {
                ExecuteBatchNitzap();
             }
            when 36 { }
            when 37 { }
            when 38 {
                ExecuteNitzapGetSummary();
             }
            when 39 { }
            when 40 { 
                ExecuteBatchNitzap();
            }
            when 41 { }
            when 42 { }
            when 43 {
                ExecuteNitzapGetSummary();
             }
            when 44 { }
            when 45 {
                ExecuteBatchNitzap();
             }
            when 46 { }
            when 47 { }
            when 48 {
                ExecuteNitzapGetSummary();
             }
            when 49 { }
            when 50 { 
                ExecuteBatchNitzap();
            }
            when 51 { }
            when 52 { }
            when 53 {
                ExecuteNitzapGetSummary();
             }
            when 54 { }
            when 55 {
                ExecuteBatchNitzap();
             }
            when 56 { }
            when 57 { }
            when 58 {
                ExecuteNitzapGetSummary();
             }
            when 59 { }
            when else { }
        }
    }

    public static void ExecuteBatchNitzap(){
        Database.executeBatch(new Batch_NitzapChats(), 10);
    }

    public static void ExecuteNitzapGetSummary(){
        Database.executeBatch(new Batch_NitzapGetSummary(), 50);
    }

}


// sfdx force:source:deploy -p "force-app/main/default/classes/Schedulable_Manager.cls, force-app/main/default/classes/Schedulable_Manager_Test.cls" -l RunSpecifiedTests -r Schedulable_Manager_Test
// sf project deploy start --metadata ApexClass:Schedulable_Manager --metadata ApexClass:Schedulable_Manager_Test -l RunSpecifiedTests -t Schedulable_Manager_Test -o Connection_Acelerai_Prod