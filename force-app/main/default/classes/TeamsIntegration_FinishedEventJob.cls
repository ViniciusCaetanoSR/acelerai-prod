/**
 * Antiga: TeamsAttendanceAndTranscriptionJob
 */
global class TeamsIntegration_FinishedEventJob implements Schedulable {
    
    global void execute(SchedulableContext sc) {               
        try {       
            EventService.handleFinishedEvent_TeamsIntegration();   
            System.debug('[JOB] TeamsIntegration_FinishedEvent chamou a EventService.handleFinishedEvent_TeamsIntegration()');
        } catch (Exception e) {
            System.debug('[JOB] TeamsIntegration_FinishedEvent: Erro ao chamar o handleFinishedEvent_TeamsIntegration ' + e.getMessage());
            LoggerUtility.createLogException(e, 'Não tem record relacionado', 'Classe: TeamsIntegration_FinishedEventJob');
        }                   
    }
}