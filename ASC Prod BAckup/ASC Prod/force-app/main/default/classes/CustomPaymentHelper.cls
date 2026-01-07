/**
 	test class - CustomPaymentControllerTest
*/
public with sharing class CustomPaymentHelper {
    private static string CLASS_NAME = 'CustomPaymentHelper';

    public static Map<String,List<DropDownListDTO>> getPaymentMethodsByAccountId(String accountId, String strFilter){
        string METHOD_NAME = 'getPaymentMethodsByAccountId';
        Map<String,List<DropDownListDTO>> mapResult = new Map<String,List<DropDownListDTO>>();
        
        //String strFilter = '{"pickListFields":["PaymentOptions__c","AccountPaymentMethodId__c"]}';

        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'accountId ' + accountId );
        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'strFilter ' + strFilter );

        try {

            DropDownListDTO.Filter objFilter = (DropDownListDTO.Filter) JSON.deserialize(strFilter, DropDownListDTO.Filter.class);

            System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'objFilter ' + objFilter );

            // Check the payment method defined in AccountPaymentMethodId__c for the checkout webcart
            WebCart objCart = [
                SELECT Id, AccountPaymentMethodId__c
                FROM WebCart
                WHERE Status IN ('Checkout' , 'Active')
                AND   AccountId =: accountId
                LIMIT 1
            ];

            String paymentMethodDefaultValue = String.valueOf(objCart?.AccountPaymentMethodId__c);

            System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'paymentMethodDefaultValue ' + paymentMethodDefaultValue );

            String definedPaymentOptions =  String.valueOf([
                SELECT Id, PaymentOptions__c
                FROM Account
                WHERE Id =: accountId
            ]?.PaymentOptions__c);

            System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'definedPaymentOptions ' + definedPaymentOptions );

            // Because we'll not have many interactions as field names for the account in this method
            // I let a selection inside this for, but that would be achieved just one time

            for (String fieldName : objFilter.pickListFields){
                // Create the return empty
                mapResult.put(fieldName, new List<DropDownListDTO>());
                
                // if (objFilter.objectType == CASE_OBJECT && fieldName == 'Type') objFieldResult = Case.Type.getDescribe();
                if (! String.isEmpty(definedPaymentOptions) && fieldName == 'PaymentOptions__c') {
                    List<String> savedValues = definedPaymentOptions.split(';');

                    // Schema.DescribeFieldResult objFieldResult = Account.PaymentOptions__c.getDescribe();
                    // If there is just one value, that is the default
                    Boolean isDefault = savedValues.size() == 1;

                    for (String rowPickValue : savedValues) {
                        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'rowPickValue ' + rowPickValue );

                        List<DropDownListDTO> updateList = mapResult.get(fieldName);
                        String label = rowPickValue;
                        String value = rowPickValue;
                        // Boolean isDefault = rowPickValue.isDefaultValue();
                        
                        updateList.add(new DropDownListDTO(label, value, isDefault));
                        mapResult.remove(fieldName);
                        mapResult.put(fieldName, updateList);    
                    }
                }

                if (fieldName == 'AccountPaymentMethodId__c') {
                    for (PaymentMethod__c oneRow : [
                        SELECT 
                            Id, Name, Type__c, BillingFullName__c, Last4__c, AccountId__c 
                        FROM PaymentMethod__c
                        WHERE AccountId__c =: accountId
                        ORDER BY Type__c ASC
                    ]){

                        List<DropDownListDTO> updateList = mapResult.get(fieldName);
                        String label = oneRow.BillingFullName__c + ' ' + (oneRow.Type__c == 'ACH' ? oneRow.Type__c : oneRow.Last4__c);
                        String value = oneRow.Id;
                        Boolean isDefault = paymentMethodDefaultValue == oneRow.Id;
                        
                        updateList.add(new DropDownListDTO(label, value, isDefault));
                        mapResult.remove(fieldName);
                        mapResult.put(fieldName, updateList);    
                    }
                }

            }

            System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'mapResult ' + mapResult );

        } catch (Exception objEx)  { throw new AuraHandledException(CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage());}
        //   string strMessage = CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage();
        //   System.debug( strMessage);
        //   throw new AuraHandledException(strMessage);
        // }

        return mapResult;
    }

    // @future
    public static void setPaymentMethod(String cartId, String accountPaymentMethodId, String paymentValue) {
        string METHOD_NAME = 'setPaymentMethod';

        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'cartId ' + cartId );
        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'accountPaymentMethodId ' + accountPaymentMethodId );
        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'paymentValue ' + paymentValue );
        try {
            WebCart objCart = new WebCart(
                Id = cartId, 
                PaymentOptions__c = paymentValue,
                AccountPaymentMethodId__c = accountPaymentMethodId
            );
            update objCart;
        } catch (Exception objEx)  { throw new AuraHandledException(CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage());}
        //   string strMessage = CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage();
        //   System.debug( strMessage);
        //   throw new AuraHandledException(strMessage);
        // }
    }

    // @future
    public static void setPurchaseOrderNumberByCartId(String cartId, String purchaseOrder, String paymentValue) {
        string METHOD_NAME = 'setPurchaseOrderNumberByCartId';


        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'cartId ' + cartId );
        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'purchaseOrder ' + purchaseOrder );
        System.debug(CLASS_NAME + ' ' + METHOD_NAME + ' ' + 'paymentValue ' + paymentValue );

        try {
            WebCart objCart = new WebCart(
                Id = cartId, 
                PaymentOptions__c = paymentValue,
                AccountPaymentMethodId__c = null
            );
            update objCart;            
        } catch (Exception objEx)  { throw new AuraHandledException(CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage());}
        //   string strMessage = CLASS_NAME + ' - ' + METHOD_NAME + ' - Error line ' + objEx.getLineNumber() + ' - Type ' + objEx.getTypeName() + ' - Message  ' + objEx.getMessage();
        //   System.debug( strMessage);
        //   throw new AuraHandledException(strMessage);
        // }
    }
}