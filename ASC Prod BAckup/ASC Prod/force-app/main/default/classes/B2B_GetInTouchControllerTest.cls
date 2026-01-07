@isTest
public class B2B_GetInTouchControllerTest {
    
    private static final String PRODUCT_NAME = 'Test Product';
    private static final String CUSTOMER_EMAIL = 'customer@testing.cust';
    private static final String GUEST_CUSTOMER_EMAIL = 'guest_customer@testing.cust';
    private static final String LOCATION_NAME = 'Test';

    @isTest
    static void getInTouchTest() {
        
        Product2 prod = B2B_TestDataFactory.createProduct(PRODUCT_NAME, false);
        prod.Parent_Sku__c = 'Parent_Sku__c';
        prod.CAS__c = 'CAS__c';
        insert prod;

        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('firstName', 'John');
        inputParams.put('lastName', 'Doe');
        inputParams.put('email', 'john.doe@example.com');
        inputParams.put('phoneNumber', '1234567890');
        inputParams.put('message', 'This is a test message.');
        inputParams.put('SimpleProductRecordId', prod.Id);

       
        Test.startTest();
        
          Map<String, Object> result = B2B_GetInTouchController.createCase(inputParams);
        
        Test.stopTest();


        System.assertNotEquals(null, result, 'Result should not be null');
        Case createdCase = [SELECT First_Name__c, Last_Name__c, SuppliedEmail, SuppliedPhone, Description 
                            FROM Case WHERE SuppliedEmail = 'john.doe@example.com' LIMIT 1];
        System.assertEquals('John', createdCase.First_Name__c, 'First name should match');
        System.assertEquals('Doe', createdCase.Last_Name__c, 'Last name should match');
        System.assertEquals('john.doe@example.com', createdCase.SuppliedEmail, 'Email should match');
        System.assertEquals('1234567890', createdCase.SuppliedPhone, 'Phone number should match');
        System.assertEquals('This is a test message.', createdCase.Description, 'Message should match');
    }

    @isTest
    static void getInTouchTest2() {

        Map<String, String> inputParams = new Map<String, String>();
        inputParams.put('firstName', 'John');
      
        Test.startTest();
        
       
        Map<String, Object> result = B2B_GetInTouchController.createCase(null);
        

        Test.stopTest();
        
      
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.containsKey('message'), 'Result should contain the error message');
        //System.assert(result.get('message').contains('Last name is required') || result.get('message').contains('Error creating case'),'Error message should match the expected validation failure');
    }
    
    @isTest
    static void updateCartNullTest() {

        Map<String, String> inputParams = new Map<String, String>();
        inputParams.put('firstName', 'John');
      
        Test.startTest();
        B2B_GetInTouchController obj = new B2B_GetInTouchController();
        Map<String, Object> result = B2B_GetInTouchController.updateCart(null);
        Test.stopTest();
		Assert.isNotNull(result);
    }
    
    @isTest
    static void updateCartTest() {
        Account userAccount = B2B_TestDataFactory.createAccount('TestAccount', true);
        Contact userContact = B2B_TestDataFactory.createContact('TestContact', userAccount.Id, true);
        User customerUser = B2B_TestDataFactory.createUser('Customer', CUSTOMER_EMAIL, userContact.Id, true); 

        B2B_TestDataFactory.createOrderDeliveryMethod(true);
        Product2 prod = B2B_TestDataFactory.createProduct(PRODUCT_NAME,true);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        ContactPointAddress cpa = B2B_TestDataFactory.createShippingCPA(userAccount,true);
        WebCart currentCart  = B2B_TestDataFactory.createCart(userAccount.Id, customerUser.id , store.Id, cpa.Id ,true);
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('couponCode', 'couponCode');
        inputParams.put('cartId', currentCart.Id);
        Map<String, Object> result = new Map<String, Object>();
        Test.startTest();
        System.runAs(customerUser) {
         	B2B_GetInTouchService obj = new B2B_GetInTouchService();
        	result = B2B_GetInTouchController.updateCart(inputParams);   
        }
        Test.stopTest();
		Assert.isNotNull(result);
    }
}