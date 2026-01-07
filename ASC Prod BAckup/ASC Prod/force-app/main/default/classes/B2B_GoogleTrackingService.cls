/**
* @description       : 
* @author            : Swati Chilap
* @group             : 
* @last modified on  : 25-08-2025
* @last modified by  : Swati Chilap
* @Test Class        : B2B_GoogleTrackingControllerTest
**/
public without sharing class B2B_GoogleTrackingService {

    public static Map<String, Object> createGMCRecord(Map<String, Object> mapParams) {
        Boolean isSuccess = false;
        String message = '';
        Id recordId;

        try {
            System.debug('createGMCRecord mapParams-- ' + JSON.serialize(mapParams));

            String productId = (String) mapParams.get('productId');
            String contactId = (String) mapParams.get('contactId');
            String gmcKey    = (String) mapParams.get('gmcKey');
            Boolean isGuest  = (Boolean) mapParams.get('isGuest');

            B2B_Google_Merchant_Center__c gmc = new B2B_Google_Merchant_Center__c();
            gmc.B2B_Product__c = String.isNotBlank(productId) ? Id.valueOf(productId) : null;
            // only set Contact if not guest
            if(String.isNotBlank(contactId) && ( isGuest == null || isGuest == false)) {
                gmc.B2B_Contact__c = Id.valueOf(contactId);
            }
            gmc.B2B_Key__c = gmcKey;

            insert gmc;
            recordId = gmc.Id;
            isSuccess = true;
            message = 'Record created successfully';
        } catch (Exception e) {
            message = 'Error: ' + e.getMessage();
        }

        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        mapParams.put('recordId', recordId);

        return mapParams;
    }
}