/**
 * test class : B2BCartCalcShippingTest
*/

// This class must extend the CartExtension.ShippingCartCalculator class to be processed.
public class B2BCartCalcShipping extends CartExtension.ShippingCartCalculator {
    private static string CLASS_NAME = 'B2B_CartCalc_Shipping';
    
    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request) {
        String METHOD_NAME = 'calculate';
        CartExtension.Cart cart = request.getCart();

        // 1. Clean up CVO based on Shipping
        CartExtension.CartValidationOutputList cartValidationOutputList = cart.getCartValidationOutputs();
        
        for (Integer i = (cartValidationOutputList.size() - 1); i >= 0; i--) {
            CartExtension.CartValidationOutput cvo = cartValidationOutputList.get(i);
            if (cvo.getType() == CartExtension.CartValidationOutputTypeEnum.SHIPPING) {
                cartValidationOutputList.remove(cvo);
            }
        }
        
        String accountId = cart.getAccountId();
        // 2. Retrieve the total amount from the WebCart
        Decimal totalAmount = cart.getTotalProductAmount();
        
        // 3. To create the Cart delivery group methods, we need to get the ID of the cart delivery group.
        system.debug('cart.getCartDeliveryGroups() '+cart.getCartDeliveryGroups());
        CartExtension.CartDeliveryGroupList cartDeliveryGroups = cart.getCartDeliveryGroups();
        if (cartDeliveryGroups.size() == 0) {
            CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
                CartExtension.CartValidationOutputTypeEnum.SHIPPING,
                CartExtension.CartValidationOutputLevelEnum.ERROR
            );
            cvo.setMessage('No Cart Delivery Groups have been defined');
            cartValidationOutputList.add(cvo);
        } else {
            CartExtension.CartItemList cartItems = cart.getCartItems();
            Integer numberOfUniqueItems = cartItems.size();
            System.debug('cartItems-->'+cartItems);
            system.debug('cartDeliveryGroups.get(0) '+cartDeliveryGroups.get(0));
            CartExtension.CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups.get(0);
            CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethods = cartDeliveryGroup.getCartDeliveryGroupMethods();
            
            // Clean up the CartDeliveryGroupMethods
            for (Integer i = (cartDeliveryGroupMethods.size() - 1); i >= 0; i--) {
                CartExtension.CartDeliveryGroupMethod method = cartDeliveryGroupMethods.get(i);
                cartDeliveryGroupMethods.remove(method);
            }
            
            // To clear selected Cart Delivery Group Method
            cartDeliveryGroup.setSelectedCartDeliveryGroupMethod(null);
            
            // 4. Get the shipping product - in this case we use SKU to find the right shipping product
            String shippingProduct = getDefaultShippingChargeProduct2Id();
            
            //5. Query existing OrderDeliveryMethod records from org and assign to a Map based on Sort Order ascending defined on each record.
            Map<Decimal,OrderDeliveryMethod> orderDeliveryMethods = new Map<Decimal,OrderDeliveryMethod>();
            for(OrderDeliveryMethod odm : [SELECT Id,ProductId,Product.Name,Name, IsActive,ReferenceNumber, 
                                            Carrier, ClassOfService,Sort_Order__c,Description FROM OrderDeliveryMethod WHERE IsActive = true 
                                            ORDER BY Sort_Order__c ASC]){
                                                orderDeliveryMethods.put(odm.Sort_Order__c,odm);     
            }
            
            // 6. Create a Cart Delivery Group Method for each returned Shipping Method
            // Create a CartDeliveryGroupMethod record for every shipping option returned from the queried OrderDeliveryMethod records
            if( orderDeliveryMethods != null){
                populateCartDeliveryGroupMethodWithShippingOptions(
                    orderDeliveryMethods, cartDeliveryGroup,
                    cartDeliveryGroupMethods,shippingProduct,
                    cartValidationOutputList
                );
            }
        }
    }
    
    
    // Create a CartDeliveryGroupMethod record for every shipping option returned from the queried OrderDeliveryMethod records
    private void populateCartDeliveryGroupMethodWithShippingOptions(Map<Decimal,OrderDeliveryMethod> orderDeliveryMethods, CartExtension.CartDeliveryGroup cartDeliveryGroup,
                                                                    CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethodCollection,
                                                                    String shippingProduct,
                                                                    CartExtension.CartValidationOutputList cartValidationOutputCollection){
                                                                        
                                                                        String METHOD_NAME = 'populateCartDeliveryGroupMethodWithShippingOptions';

                                                                        //Adding Delivery Method : FedEX Ground
                                                                        OrderDeliveryMethod shippingOption1 = orderDeliveryMethods.get(1);
                                                                        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod1 = new CartExtension.CartDeliveryGroupMethod(
                                                                            shippingOption1.Name, //name
                                                                            0.0000000000001, //shipping rate
                                                                            shippingProduct //shipping product id
                                                                            );
                                                                        cartDeliveryGroupMethod1.setExternalProvider('FedEx');
                                                                        cartDeliveryGroupMethod1.setCarrier(shippingOption1.Carrier);
                                                                        cartDeliveryGroupMethod1.setClassOfService(shippingOption1.ClassOfService);
                                                                        cartDeliveryGroupMethod1.setIsActive(shippingOption1.IsActive);
                                                                        cartDeliveryGroupMethod1.setReferenceNumber(shippingOption1.ReferenceNumber);
                                                                        cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod1);

                                                                        //Adding Delivery Method : FedEX Priority (AM Delivery)
                                                                        OrderDeliveryMethod shippingOption2 = orderDeliveryMethods.get(2);
                                                                        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod2 = new CartExtension.CartDeliveryGroupMethod(
                                                                            shippingOption2.Name,
                                                                            0.0000000000002,
                                                                            shippingProduct
                                                                            );
                                                                        cartDeliveryGroupMethod2.setExternalProvider('FedEx');
                                                                        cartDeliveryGroupMethod2.setCarrier(shippingOption2.Carrier);
                                                                        cartDeliveryGroupMethod2.setClassOfService(shippingOption2.ClassOfService);
                                                                        cartDeliveryGroupMethod2.setIsActive(shippingOption2.IsActive);
                                                                        cartDeliveryGroupMethod2.setReferenceNumber(shippingOption2.ReferenceNumber);
                                                                        cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod2);

                                                                        //Adding Delivery Method : FedEX Priority (PM Delivery)
                                                                        OrderDeliveryMethod shippingOption3 = orderDeliveryMethods.get(3);
                                                                        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod3 = new CartExtension.CartDeliveryGroupMethod(
                                                                            shippingOption3.Name,
                                                                            0.0000000000003,
                                                                            shippingProduct
                                                                            );
                                                                        cartDeliveryGroupMethod3.setExternalProvider('FedEx');
                                                                        cartDeliveryGroupMethod3.setCarrier(shippingOption3.Carrier);
                                                                        cartDeliveryGroupMethod3.setClassOfService(shippingOption3.ClassOfService);
                                                                        cartDeliveryGroupMethod3.setIsActive(shippingOption3.IsActive);
                                                                        cartDeliveryGroupMethod3.setReferenceNumber(shippingOption3.ReferenceNumber);
                                                                        cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod3);

                                                                        //Adding Delivery Method : FedEX 2nd Day
                                                                        OrderDeliveryMethod shippingOption4 = orderDeliveryMethods.get(4);
                                                                        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod4 = new CartExtension.CartDeliveryGroupMethod(
                                                                            shippingOption4.Name,
                                                                            0.0000000000004,
                                                                            shippingProduct
                                                                            );
                                                                        cartDeliveryGroupMethod4.setExternalProvider('FedEX 2nd Day');
                                                                        cartDeliveryGroupMethod4.setCarrier(shippingOption4.Carrier);
                                                                        cartDeliveryGroupMethod4.setClassOfService(shippingOption4.ClassOfService);
                                                                        cartDeliveryGroupMethod4.setIsActive(shippingOption4.IsActive);
                                                                        cartDeliveryGroupMethod4.setReferenceNumber(shippingOption4.ReferenceNumber);
                                                                        cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod4);

                                                                        //Adding Delivery Method : Other
                                                                        OrderDeliveryMethod shippingOption5 = orderDeliveryMethods.get(5);
                                                                        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod5 = new CartExtension.CartDeliveryGroupMethod(
                                                                            shippingOption5.Name,
                                                                            0.0000000000005,
                                                                            shippingProduct
                                                                            );
                                                                        cartDeliveryGroupMethod5.setExternalProvider('Other');
                                                                        cartDeliveryGroupMethod5.setCarrier(shippingOption5.Carrier);
                                                                        cartDeliveryGroupMethod5.setClassOfService(shippingOption5.ClassOfService);
                                                                        cartDeliveryGroupMethod5.setIsActive(shippingOption5.IsActive);
                                                                        cartDeliveryGroupMethod5.setReferenceNumber(shippingOption5.ReferenceNumber);
                                                                        cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod5);

                                                                    }
    
    private String getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Delivery Charge'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Delivery Charge';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name WITH SECURITY_ENFORCED];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
    
    @TestVisible
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}