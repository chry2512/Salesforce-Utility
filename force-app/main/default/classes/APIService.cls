/**
 * @description       :  Abstract Entity for general API Service Exposed
 * @author            :
 * @group             :
 * @last modified on  : 05-27-2024
 * @last modified by  : 
 **/
@RestResource(urlMapping = '/*')
global class APIService{
    @HttpGet
    global static void doGet(){
        RestContext.response = APIHandler.getInstance().handleDoGet(RestContext.request, RestContext.response);
    }

    @HttpPost
    global static void doPost(){
        RestContext.response = APIHandler.getInstance().handleDoPost(RestContext.request, RestContext.response);
    }

    @HttpPut
    global static void doPut(){
        RestContext.response = APIHandler.getInstance().handleDoPut(RestContext.request, RestContext.response);
    }

    @HttpPatch
    global static void doPatch(){
        RestContext.response = APIHandler.getInstance().handleDoPatch(RestContext.request, RestContext.response);
    }

    @HttpDelete
    global static void doDelete(){
        RestContext.response = APIHandler.getInstance().handleDoDelete(RestContext.request, RestContext.response);
    }

}