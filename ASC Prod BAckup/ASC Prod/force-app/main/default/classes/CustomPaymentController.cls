public with sharing class CustomPaymentController {
    @AuraEnabled
    public static Map<String,List<DropDownListDTO>> getPaymentMethodsByAccountId(String accountId, String strFilter){
        return CustomPaymentHelper.getPaymentMethodsByAccountId(accountId, strFilter);
    }

    @AuraEnabled
    public static void setPaymentMethod(String cartId, String accountPaymentMethodId, String paymentValue) {
        CustomPaymentHelper.setPaymentMethod(cartId, accountPaymentMethodId, paymentValue);
    }

    @AuraEnabled
    public static void setPurchaseOrderNumberByCartId(String cartId, String purchaseOrder, String paymentValue) {
        CustomPaymentHelper.setPurchaseOrderNumberByCartId(cartId, purchaseOrder, paymentValue);
    }

}