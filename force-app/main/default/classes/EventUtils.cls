public with sharing class EventUtils {

    public static List<Event> generateEvents(Integer numberOfRecords){
        List<Event> events = new List<Event>();
        events = createEvent(numberOfRecords);

        try{
            insert events;
        } catch (DmlException e){
            System.debug('Erro ao inserir evento: ' + e.getMessage());
            throw new DmlException();            
        } 
        return events;       
    }

     public static List<Event> createEvent(Integer numberOfRecords){
        List<Event> events = new List<Event>();

        for(Integer i=0; i < numberOfRecords; i++){
            Event event = new Event(
                Subject = 'Evento teste '+ i,
                Location = 'Location teste',
                StartDateTime = datetime.now(),
                EndDateTime = datetime.now().addHours(1),
                Type = 'Other',
                Description = 'Evento criado para teste ' + i                
            );

            events.add(event);
        }
        return events;
    }
}