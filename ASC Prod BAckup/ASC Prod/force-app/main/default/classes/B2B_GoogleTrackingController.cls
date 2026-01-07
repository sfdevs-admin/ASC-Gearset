/**
* @description       : 
* @author            : Swati Chilap
* @group             : 
* @last modified on  : 25-08-2025
* @last modified by  : Swati Chilap
* @Test Class        : B2B_GoogleTrackingControllerTest
**/

public without sharing class B2B_GoogleTrackingController {
    @AuraEnabled
    public static Map<String, Object> createGMCRecord (Map<String, Object> mapParams) {
        return B2B_GoogleTrackingService.createGMCRecord(mapParams);
    }
}