/**
 * @description       : 
 * @author            : Arpan Mazumder
 * @group             : 
 * @last modified on  : 24-09-2024
 * @last modified by  : Arpan Mazumder
 * test class : B2B_GetInTouchControllerTest
**/
public with sharing class B2B_GetInTouchController {
    public B2B_GetInTouchController() {

    }

    @AuraEnabled
    public static Map<String,Object> createCase(Map<String,Object> mapParams){
        try {
            B2B_GetInTouchService.createCase(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }


    @AuraEnabled
    public static Map<String,Object> updateCart(Map<String,Object> mapParams){
        try {
            B2B_GetInTouchService.updateCart(mapParams);
        } catch (Exception e) {
            mapParams = mapParams == null ? new Map<String,Object>() : mapParams;
            mapParams.put('isSuccess',false);
            mapParams.put('message',e.getMessage());
        }
        return mapParams;
    }

}