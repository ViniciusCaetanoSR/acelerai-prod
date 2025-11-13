public without sharing class TeamsResponseHttp {
    public Boolean success;
    public Boolean error;
    public List<String> errorList = new List<String>();
    public Object dataMap = new Map<String, Object>();

    public static String success(Object dataMap){
        TeamsResponseHttp response = new TeamsResponseHttp();
        response.success = true;
        response.error = false;
        response.dataMap = dataMap;
        return JSON.serialize(response);
    }

    public static TeamsResponseHttp successObj(Object dataMap){
        TeamsResponseHttp response = new TeamsResponseHttp();
        response.success = true;
        response.error = false;
        response.dataMap = dataMap;
        return response;
    }

    public static String error(List<String> errorList){
        TeamsResponseHttp response = new TeamsResponseHttp();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        return JSON.serialize(response);
    }
    public static TeamsResponseHttp errorObj(List<String> errorList){
        TeamsResponseHttp response = new TeamsResponseHttp();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        return response;
    }

    public static String error(List<String> errorList, Object dataMap){
        TeamsResponseHttp response = new TeamsResponseHttp();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        response.dataMap = dataMap;
        return JSON.serialize(response);
    }
    public static TeamsResponseHttp errorObj(List<String> errorList, Object dataMap){
        TeamsResponseHttp response = new TeamsResponseHttp();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        response.dataMap = dataMap;
        return response;
    }  
}