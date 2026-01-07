/**
 * @description       : 
 * @author            : Arpan Mazumder
 * @group             : 
 * @last modified on  : 24-09-2024
 * @last modified by  : Arpan Mazumder
 * test class : B2B_GetInTouchControllerTest
**/
public without sharing class B2B_GetInTouchService {
    public B2B_GetInTouchService () {

    }

    public static Map<String,Object> createCase(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if( mapParams.containsKey('firstName') && mapParams.get('firstName') != null 
            && mapParams.containsKey('lastName') && mapParams.get('lastName') != null 
            && mapParams.containsKey('email') && mapParams.get('email') != null 
            && mapParams.containsKey('phoneNumber') && mapParams.get('phoneNumber') != null 
            && mapParams.containsKey('message') && mapParams.get('message') != null
        ) {
            // Create a new case instance
            Case newCase = new Case();
            
            // Map the incoming details to the Case fields
            newCase.First_Name__c = (String) mapParams.get('firstName');
            newCase.Last_Name__c = (String) mapParams.get('lastName');
            newCase.SuppliedEmail = (String) mapParams.get('email');
            newCase.SuppliedPhone = (String) mapParams.get('phoneNumber');
            newCase.Description = (String) mapParams.get('message');
            newCase.Simple_Product__c = (Id) mapParams.get('SimpleProductRecordId');
            system.debug('ProductOnCase==>'+  newCase.Simple_Product__c);
            newCase.Status =  'New';
            newCase.Origin = 'Email';
            newCase.Priority = 'Medium';
            newCase.Type = 'Question';
            newCase.Regarding__c = 'Simple Product Inquiry';
            newCase.Subject = 'Simple Product Inquiry';
            // Insert the case
            insert newCase;
            mapParams.put('newCase', newCase);
            isSuccess = true;
            system.debug('newCase==>'+newCase.Id);
        }else{
            message = 'Required fields missing.';
        }
        mapParams.put('isSuccess',isSuccess);
        mapParams.put('message', message);
        return MapParams;
    }

    public static Map<String,Object> updateCart(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        if( mapParams.containsKey('couponCode') && mapParams.get('couponCode') != null 
            && mapParams.containsKey('cartId') && mapParams.get('cartId') != null
        ) {
            String couponCode = (String) mapParams.get('couponCode');
            String cartId = (String) mapParams.get('cartId');
            List<WebCart> cartList = [SELECT Id, Coupon_Code__c FROM WebCart WHERE Id = :cartId LIMIT 1 FOR UPDATE];
            if( !cartList.isEmpty() ){
                WebCart cartToUpdate = cartList[0];
                cartToUpdate.Coupon_Code__c = couponCode;

                update cartToUpdate;
                mapParams.put('updatedCart',cartToUpdate);
                isSuccess = true;
            }            
        }else{
            message = 'Required fields missing.';
        }
        mapParams.put('isSuccess',isSuccess);
        mapParams.put('message', message);
        return MapParams;
    }
}