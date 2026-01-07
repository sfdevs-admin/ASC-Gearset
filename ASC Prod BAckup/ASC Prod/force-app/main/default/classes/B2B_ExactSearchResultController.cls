/*
 * test class - B2B_ExactSearchResultControllerTest *
*/
public without sharing class B2B_ExactSearchResultController {

    @TestVisible
    private static final B2B_ExactSearchResultService searchService = new B2B_ExactSearchResultService();

    @AuraEnabled
    public static Map<String,Object> getExactSearchResult(Map<String,Object> dataMap) {
        Boolean isSuccess = false;
        try {
            dataMap.put('userId', UserInfo.getUserId());
            searchService.getExactSearchResult(dataMap);
            isSuccess = (Boolean)dataMap.get('isSuccess');
        } catch (Exception ex) {
            dataMap =  dataMap == null ? new Map<String,Object>() : dataMap  ;
            isSuccess = false;
            dataMap.put('message', ex.getMessage()+' '+ex.getStackTraceString());
        }
        dataMap.put('isSuccess', isSuccess);
        return dataMap;
    }

    /*@AuraEnabled
    public static Map<String,Object> getProducts(Map<String,Object> dataMap) {
        Boolean isSuccess = false;
        try {
            dataMap.put('userId', UserInfo.getUserId());
            searchService.getProducts(dataMap);
            isSuccess = (Boolean)dataMap.get('isSuccess');
        } catch (Exception ex) {
            dataMap =  dataMap == null ? new Map<String,Object>() : dataMap  ;
            isSuccess = false;
            dataMap.put('message', ex.getMessage()+' '+ex.getStackTraceString());
        }
        dataMap.put('isSuccess', isSuccess);
        return dataMap;
    }*/
}