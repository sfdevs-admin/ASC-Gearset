@isTest
public without sharing class B2BCartCalcShippingTest {
    
    private static final String CUSTOMER_EMAIL = 'customer@testing.cust';
    private static final String GUEST_CUSTOMER_EMAIL = 'guest_customer@testing.cust';
    private static final String LOCATION_NAME = 'Test';
    private static final String PRODUCT_NAME = 'Test Product';
    
    @TestSetup
    static void setup() {
        Product2 shipProduct = new Product2();
        shipProduct.Name = 'Test Default Shipping Product' ;
        shipProduct.ProductCode = 'Test Default Shipping Product' ;
        shipProduct.StockKeepingUnit = 'Test Default Shipping Product' ;
        shipProduct.isActive = true ;
        insert shipProduct;
        List<OrderDeliveryMethod> odmToInsert = new List<OrderDeliveryMethod> ();
        OrderDeliveryMethod odm = new OrderDeliveryMethod();
        odm.Name = 'Test default Shipping';
        odm.ProductId = shipProduct.Id;
        odm.IsActive = true;
        odm.ReferenceNumber = 'TR';
        odm.Sort_Order__c = 1;
        //insert odm;
        odmToInsert.add(odm);
        
        OrderDeliveryMethod odm2 = new OrderDeliveryMethod();
        odm2.Name = 'Test default Shipping 2';
        odm2.ProductId = shipProduct.Id;
        odm2.IsActive = true;
        odm2.ReferenceNumber = 'TR1';
        odm2.Sort_Order__c = 2;
        //insert odm2;
        odmToInsert.add(odm2);
        
        OrderDeliveryMethod odm3 = new OrderDeliveryMethod();
        odm3.Name = 'Test default Shipping 3';
        odm3.ProductId = shipProduct.Id;
        odm3.IsActive = true;
        odm3.ReferenceNumber = 'TR3';
        odm3.Sort_Order__c = 3;
        //insert odm3;
        odmToInsert.add(odm3);
        
        OrderDeliveryMethod odm4 = new OrderDeliveryMethod();
        odm4.Name = 'Test default Shipping 4';
        odm4.ProductId = shipProduct.Id;
        odm4.IsActive = true;
        odm4.ReferenceNumber = 'TR4';
        odm4.Sort_Order__c = 4;
        //insert odm4;
        odmToInsert.add(odm4);
        
        OrderDeliveryMethod odm5 = new OrderDeliveryMethod();
        odm5.Name = 'Test default Shipping 5';
        odm5.ProductId = shipProduct.Id;
        odm5.IsActive = true;
        odm5.ReferenceNumber = 'TR5';
        odm5.Sort_Order__c = 5;
        //insert odm5;
        odmToInsert.add(odm5);
        
        insert odmToInsert;
    }
    
    @isTest
    public static void testCartWithNoCartDeliveryGroup(){
        
        CartExtension.Cart cart = CartExtension.CartTestUtil.createCart();
        CartExtension.CartDeliveryGroupList deliveryGroups = cart.getCartDeliveryGroups();
        CartExtension.CartDeliveryGroup deliveryGroup = deliveryGroups.get(0);
        //deliveryGroups.remove(deliveryGroup);
        
        Test.startTest();
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty());
        B2BCartCalcShipping calculator = new B2BCartCalcShipping();
        calculator.calculate(request);
        Test.stopTest();
    }
    
    @IsTest
    public static void testShippingMethodsAreCreated() {
        
        // Arrange
        CartExtension.Cart cart = CartExtension.CartTestUtil.createCart();
        getDefaultShippingChargeProduct2Id();
        
        // Act
        Test.startTest();
        CartExtension.CartCalculateCalculatorRequest request = new CartExtension.CartCalculateCalculatorRequest(cart, CartExtension.OptionalBuyerActionDetails.empty());
        B2BCartCalcShipping calculator = new B2BCartCalcShipping();
        calculator.calculate(request);
        Test.stopTest();
        
        // Assert
        // Test if no CVO is created
        CartExtension.CartValidationOutputList cartValidationOutputs = cart.getCartValidationOutputs();
        
        // Test if CartDeliveryGroupMethod is created
        CartExtension.CartDeliveryGroupList deliveryGroups = cart.getCartDeliveryGroups();
        CartExtension.CartDeliveryGroup deliveryGroup = deliveryGroups.get(0);
        
        CartExtension.CartDeliveryGroupMethodList deliveryMethods = deliveryGroup.getCartDeliveryGroupMethods();
        
        CartExtension.CartDeliveryGroupMethod deliveryMethod01 = deliveryMethods.get(0);
        
        CartExtension.CartDeliveryGroupMethod deliveryMethod02 = deliveryMethods.get(1);
        
    }
    
    public static Id getDefaultShippingChargeProduct2Id() {
        
        // Check to see if a Product2 with name 'Shipping Charge' already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Shipping Charge';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        } else {
            return shippingChargeProducts[0].Id;
        }
    }
    
    @IsTest
    public static void testGenerateRandomString() {
        
        Test.startTest();
        String output = B2BCartCalcShipping.generateRandomString(6);
        Test.stopTest();
        Assert.isNotNull(output);
        
    }
}