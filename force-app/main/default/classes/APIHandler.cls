/**
 * @description       :  Entity for manage API Services
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
global class APIHandler{
    public static final String HANDLER_CLASS_PREFIX = '';
    public static final String HANDLER_CLASS_SUFFIX = '';
    private static APIHandler instance;

    private APIHandler(){
    }

    public static APIHandler getInstance(){
        if (instance == null)
            instance = new APIHandler();
        return instance;
    }

    //HTTP Method Handlers.............................
    public RestResponse handleDoGet(RestRequest request, RestResponse response){
        APIVirtual instance = getHandlerInstance(request, response);
        //checking if endpoint exists
        if (instance == null){
            response = setResponse(response, null, 404, null);
            log(request, response, true);
            return response;
        }
        //checking if HTTP method is defined
        if (instance.ImplementedMethod_GET == null || instance.ImplementedMethod_GET == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //checking additional authorizations
        if (instance.checkAuthorizations_GET() == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //validating request
        if (instance.validateRequest_GET() == false){
            response = setResponse(response, null, 400, instance.e);
            log(request, response, true);
            return response;
        }
        Object responseBody = instance.execute_GET();
        //checking execution result
        if (responseBody == null){
            response = setResponse(response, null, 500, instance.e);
            log(request, response, true);
            return response;
        }

        Map<ResponseParameter, Object> responseParameterMap = instance.setResponseParameters_GET(responseBody);
        response = setResponse(response, responseParameterMap.get(ResponseParameter.RESPONSEBODY), (Integer) responseParameterMap.get(ResponseParameter.STATUSCODE), null);
        log(request, response, false);
        return response;
    }

    public RestResponse handleDoPost(RestRequest request, RestResponse response){
        APIVirtual instance = getHandlerInstance(request, response);
        //checking if endpoint exists
        if (instance == null){
            response = setResponse(response, null, 404, null);
            log(request, response, true);
            return response;
        }
        //checking if HTTP method is defined
        if (instance.ImplementedMethod_POST == null || instance.ImplementedMethod_POST == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //checking additional authorizations
        if (instance.checkAuthorizations_POST() == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //validating request
        if (instance.validateRequest_POST() == false){
            response = setResponse(response, null, 400, instance.e);
            log(request, response, true);
            return response;
        }

        Object responseBody = instance.execute_POST();
        //checking execution result
        if (responseBody == null){
            response = setResponse(response, null, 500, instance.e);
            log(request, response, true);
            return response;
        }

        Map<ResponseParameter, Object> responseParameterMap = instance.setResponseParameters_POST(responseBody);
        System.debug('responseParamaterMap: ' + responseParameterMap);
        response = setResponse(response, responseParameterMap.get(ResponseParameter.RESPONSEBODY), (Integer) responseParameterMap.get(ResponseParameter.STATUSCODE), null);
        log(request, response, false);
        return response;
    }

    public RestResponse handleDoPut(RestRequest request, RestResponse response){
        APIVirtual instance = getHandlerInstance(request, response);
        //checking if endpoint exists
        if (instance == null){
            response = setResponse(response, null, 404, null);
            log(request, response, true);
            return response;
        }
        //checking if HTTP method is defined
        if (instance.ImplementedMethod_PUT == null || instance.ImplementedMethod_PUT == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //checking additional authorizations
        if (instance.checkAuthorizations_PUT() == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //validating request
        if (instance.validateRequest_PUT() == false){
            response = setResponse(response, null, 400, instance.e);
            log(request, response, true);
            return response;
        }
        Object responseBody = instance.execute_PUT();
        //checking execution result
        if (responseBody == null){
            response = setResponse(response, null, 500, instance.e);
            log(request, response, true);
            return response;
        }

        Map<ResponseParameter, Object> responseParameterMap = instance.setResponseParameters_PUT(responseBody);
        response = setResponse(response, responseParameterMap.get(ResponseParameter.RESPONSEBODY), (Integer) responseParameterMap.get(ResponseParameter.STATUSCODE), null);
        log(request, response, false);
        return response;
    }

    public RestResponse handleDoPatch(RestRequest request, RestResponse response){
        APIVirtual instance = getHandlerInstance(request, response);
        //checking if endpoint exists
        if (instance == null){
            response = setResponse(response, null, 404, null);
            log(request, response, true);
            return response;
        }
        //checking if HTTP method is defined
        if (instance.ImplementedMethod_PATCH == null || instance.ImplementedMethod_PATCH == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }

        //checking additional authorizations
        if (instance.checkAuthorizations_PATCH() == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }

        //validating request
        if (instance.validateRequest_PATCH() == false){
            response = setResponse(response, null, 400, instance.e);
            log(request, response, true);
            return response;
        }

        Object responseBody = instance.execute_PATCH();
        //checking execution result
        if (responseBody == null){
            response = setResponse(response, null, 500, instance.e);
            log(request, response, true);
            return response;
        }

        Map<ResponseParameter, Object> responseParameterMap = instance.setResponseParameters_PATCH(responseBody);
        response = setResponse(response, responseParameterMap.get(ResponseParameter.RESPONSEBODY), (Integer) responseParameterMap.get(ResponseParameter.STATUSCODE), null);
        log(request, response, false);
        return response;
    }

    public RestResponse handleDoDelete(RestRequest request, RestResponse response){
        APIVirtual instance = getHandlerInstance(request, response);
        //checking if endpoint exists
        if (instance == null){
            response = setResponse(response, null, 404, null);
            log(request, response, true);
            return response;
        }
        //checking if HTTP method is defined
        if (instance.ImplementedMethod_DELETE == null || instance.ImplementedMethod_DELETE == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //checking additional authorizations
        if (instance.checkAuthorizations_DELETE() == false){
            response = setResponse(response, null, 405, instance.e);
            log(request, response, true);
            return response;
        }
        //validating request
        if (instance.validateRequest_DELETE() == false){
            response = setResponse(response, null, 400, instance.e);
            log(request, response, true);
            return response;
        }
        Object responseBody = instance.execute_DELETE();
        //checking execution result
        if (responseBody == null){
            response = setResponse(response, null, 500, instance.e);
            log(request, response, true);
            return response;
        }

        Map<ResponseParameter, Object> responseParameterMap = instance.setResponseParameters_DELETE(responseBody);
        response = setResponse(response, responseParameterMap.get(ResponseParameter.RESPONSEBODY), (Integer) responseParameterMap.get(ResponseParameter.STATUSCODE), null);
        log(request, response, false);
        return response;
    }

    //operational methods...............................
    private static APIVirtual getHandlerInstance(RestRequest request, RestResponse response){
        //N.B. here there are no API versions, this is NOT a best practice because exposed API should ALWAYS be versioned...

        //N.B: the name of the api is the string after last /, i.e. services/apexrest/../../apiname becomes apiname
        String apiName = request.requestURI.substringAfterLast('/');
        String handlerClassName = HANDLER_CLASS_PREFIX + apiName + HANDLER_CLASS_SUFFIX;

        /*N.B. the json.deserialize parameterized constructor [i,e, (APIVirtual) JSON.deserialize(constructorParameters, Type.forName(handlerClassName));]
         does not run code beyond the super() line in derived class, hence the newInstance() and init() method were choosen*/
        APIVirtual instance = (APIVirtual)Type.forName(handlerClassName)?.newInstance();
        return instance?.init(request, response);
    }

    private static RestResponse setResponse(RestResponse response, Object result, Integer statusCode, Exception e){
        //N.B. Apex does not allow custom status codes (yet) TO DO: enhance with XML payload when needed
        Map<Integer, String> statusCodeResultMap = new Map<Integer, String>{ 200 => (String) result,      //"OK" success code, for GET or HEAD request. //N.B. often used for generic success request
        201 => (String) result,      //"Created" success code, for POST request. //N.B. often replaced by 200 code
        400 => (String) result, 401 => JSON.serializePretty(new ResponseErrorModel(String.valueOf(System.now()), 'NOT AUTHORIZED', 'error at ' + e?.getStackTraceString() + ': ' + e?.getMessage(), statusCode)), 404 => JSON.serializePretty(new ResponseErrorModel(String.valueOf(System.now()), 'NOT FOUND', 'The requested API has not been found, check endpoint', statusCode)), 405 => JSON.serializePretty(new ResponseErrorModel(String.valueOf(System.now()), 'METHOD NOT ALLOWED', 'The requested HTTP Method is unsupported', statusCode)), 410 => (String) result, 422 => (String) result, 500 => (String) result };

        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(statusCodeResultMap.get(statusCode));
        return response;
    }

    private static void log(RestRequest request, RestResponse response, Boolean hasError){
        String title = 'SUCCESS';
        if (hasError){
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());
            title = (String) responseMap.get('title');
        }
        ExposedAPILogger.getInstance().log(request.resourcePath + request.requestURI, System.now(), title, request, response);
        ExposedAPILogger.getInstance().close();
    }

    private class ResponseErrorModel{
        String timestamp;
        String title;
        String content;
        Integer statusCode;
        public ResponseErrorModel(String timestamp, String title, String content, Integer statusCode){
            this.timestamp = timestamp;
            this.title = title;
            this.content = content;
            this.statusCode = statusCode;
        }

    }

    public enum ResponseParameter{
        STATUSCODE, 
        RESPONSEBODY
    }

    public virtual class APIVirtual{
        public Boolean implementedMethod_GET{ get;protected  set; }

        public Boolean implementedMethod_POST{ get;protected  set; }

        public Boolean implementedMethod_PUT{ get;protected  set; }

        public Boolean implementedMethod_PATCH{ get;protected  set; }

        public Boolean implementedMethod_DELETE{ get;protected  set; }

        protected RestRequest request{ get;private  set; }

        protected RestResponse response{ get;private  set; }

        protected Object requestBodyModel;
        protected Exception e;

        //virtual stage methods for each http...............................
        public virtual Boolean checkAuthorizations_GET(){
            return true;
        }

        public virtual Boolean validateRequest_GET(){
            return true;
        }

        public virtual Object execute_GET(){
            return null;
        }

        public virtual Map<APIHandler.ResponseParameter, Object> setResponseParameters_GET(Object responseBody){
            Map<ResponseParameter, Object> responseParameterMap = new Map<ResponseParameter, Object>();
            responseParameterMap.put(APIHandler.ResponseParameter.STATUSCODE, 200);
            responseParameterMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);
            return responseParameterMap;
        }

        public virtual Boolean validateRequest_POST(){
            return true;
        }

        public virtual Boolean checkAuthorizations_POST(){
            return true;
        }

        public virtual Object execute_POST(){
            return null;
        }

        public virtual Map<APIHandler.ResponseParameter, Object> setResponseParameters_POST(Object responseBody){
            Map<ResponseParameter, Object> responseParameterMap = new Map<ResponseParameter, Object>();
            responseParameterMap.put(APIHandler.ResponseParameter.STATUSCODE, 200);
            responseParameterMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);
            return responseParameterMap;
        }

        public virtual Boolean validateRequest_PUT(){
            return true;
        }

        public virtual Boolean checkAuthorizations_PUT(){
            return true;
        }

        public virtual Object execute_PUT(){
            return null;
        }

        public virtual Map<APIHandler.ResponseParameter, Object> setResponseParameters_PUT(Object responseBody){
            Map<ResponseParameter, Object> responseParameterMap = new Map<ResponseParameter, Object>();
            responseParameterMap.put(APIHandler.ResponseParameter.STATUSCODE, 200);
            responseParameterMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);
            return responseParameterMap;
        }

        public virtual Boolean validateRequest_PATCH(){
            return true;
        }

        public virtual Boolean checkAuthorizations_PATCH(){
            return true;
        }

        public virtual Object execute_PATCH(){
            return null;
        }

        public virtual Map<APIHandler.responseParameter, Object> setResponseParameters_PATCH(Object responseBody){
            Map<ResponseParameter, Object> responseParameterMap = new Map<ResponseParameter, Object>();
            responseParameterMap.put(APIHandler.ResponseParameter.STATUSCODE, 200);
            responseParameterMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);
            return responseParameterMap;
        }

        public virtual Boolean validateRequest_DELETE(){
            return true;
        }

        public virtual Boolean checkAuthorizations_DELETE(){
            return true;
        }

        public virtual Object execute_DELETE(){
            return null;
        }

        public virtual Map<APIHandler.ResponseParameter, Object> setResponseParameters_DELETE(Object responseBody){
            Map<ResponseParameter, Object> responseParameterMap = new Map<ResponseParameter, Object>();
            responseParameterMap.put(APIHandler.ResponseParameter.STATUSCODE, 200);
            responseParameterMap.put(APIHandler.ResponseParameter.RESPONSEBODY, responseBody);
            return responseParameterMap;
        }

        public APIVirtual init(RestRequest request, RestResponse response){
            this.request = request;
            this.response = response;
            return this;
        }

    }

}