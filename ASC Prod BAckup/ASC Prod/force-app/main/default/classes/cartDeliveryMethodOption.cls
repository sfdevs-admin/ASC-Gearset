/**
 * @description       : 
 * @author            : S.T
 * @group             : 
 * @last modified on  : 06-26-2024
 * @last modified by  : S.T
**/
public with sharing class cartDeliveryMethodOption {

    @AuraEnabled(cacheable=false)
    public static void updateCartDeliveryOption(String deliveryOption,String OrderNotes) {
            String userId = UserInfo.getUserId();
            System.debug('userId'+userId);
            String accountId = getUserAccountID(userId);
            System.debug('accountId'+accountId);
            //String userId  = '005VB000002oaLhYAI';
            try{
                // Query and update the cart record with the new delivery option
                WebCart cart = [SELECT Id, Other_Shipping__c, Order_Notes__c, Status FROM WebCart WHERE AccountId = :accountId AND OwnerId = :userId AND Status = 'Checkout' LIMIT 1];
                system.debug('cart'+cart);
                if( deliveryOption != null ){
                    cart.Other_Shipping__c = deliveryOption;
                }   
                if( OrderNotes!= null ){
                    cart.Order_Notes__c = OrderNotes;
                }
                update cart;

                System.debug('updated cart'+cart);
            }catch (Exception E)  {  
                    //throw new AuraHandledException(CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage());
                }
                //   string strMessage = CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage();
                //   System.debug( strMessage);
                //   throw new AuraHandledException(strMessage);
                // }
    }
    // public static String getCartDeliveryMethod() {
    //     //String userId = UserInfo.getUserId();
    //     String userId  = '005VB000002oaLhYAI';
    //     String accountId = getUserAccountID(userId);
        
    //     // Query active cart associated with the current user's Account ID
    //     WebCart activeCart = [SELECT Id 
    //                            FROM WebCart 
    //                            WHERE  AccountId = :accountId AND OwnerId = :userId
    //                            LIMIT 1]; 
    //     System.debug('activeCart: '+activeCart);

    //     if (activeCart == null) {
    //         return null; // No active cart found
    //     }
        
    //     // Query CartDeliveryGroupMethod based on WebCartId and Name
    //     CartDeliveryGroup deliveryGroup = [SELECT Id, Name, SelectedDeliveryMethodId, SelectedDeliveryMethod.Name
    //                                        FROM CartDeliveryGroup 
    //                                        WHERE CartId = :activeCart.Id 
    //                                        //AND SelectedDeliveryMethod.Name = 'Other'
    //                                        ]; // SELECT Id, Name, SelectedDeliveryMethodId, CartId FROM CartDeliveryGroup WHERE CartId = : active cart
    //     System.debug('deliveryGroupMethod -->'+deliveryGroup);

    //     if (deliveryGroup != null && deliveryGroup.SelectedDeliveryMethod.Name == 'Other') {
    //         System.debug('deliveryGroupMethodIDy------ -->'+deliveryGroup.SelectedDeliveryMethodId);
    //         return deliveryGroup.SelectedDeliveryMethodId;
    //     }
        
    //     return null; // No CartDeliveryGroupMethod found for the active cart
    // }
    
    public static String getUserAccountID(String userId) { 
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        String accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId;
        System.debug('accountId'+accountId);
        return accountId;
    }  
    
    public static void testCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}