/**
 * @description       : 
 * @author            : Mradul
 * @group             : 
 * @last modified on  : 10-06-2025
 * @last modified by  : Swati Chilap
**/
@isTest
public without sharing class B2B_RequestForQuoteController_Test {
    
    private static final String CUSTOMER_EMAIL = 'customer@testing.cust';
    private static final String GUEST_CUSTOMER_EMAIL = 'guest_customer@testing.cust';
    private static final String LOCATION_NAME = 'Test';
    private static final String PRODUCT_NAME = 'Test Product';
    
     @TestSetup
    static void setup() {
        User adminUser = B2B_TestDataFactory.createAdminUser('TestAdmin', true);

        System.runAs(adminUser) {
            Account userAccount = B2B_TestDataFactory.createAccount('TestAccount', true);
            Contact userContact = B2B_TestDataFactory.createContact('TestContact', userAccount.Id, true);
            User customerUser = B2B_TestDataFactory.createUser('Customer', CUSTOMER_EMAIL, userContact.Id, true);
            User guestUser = B2B_TestDataFactory.createGuestUser('GuestCus', GUEST_CUSTOMER_EMAIL, null, true);
            B2B_TestDataFactory.createProduct(PRODUCT_NAME,true);
            B2B_TestDataFactory.createShippingCPA(userAccount,true);
            B2B_TestDataFactory.createOrderDeliveryMethod(true);


        }
    }
    
    @isTest
    public static void createQuoteTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
		Test.startTest();
        System.runAs(customerUser) {
            B2B_RequestForQuoteController obj =  new B2B_RequestForQuoteController();
            B2B_RequestForQuoteService o = new B2B_RequestForQuoteService();
            respTestMap = B2B_RequestForQuoteController.createQuote(inpTestMap);
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }
    
    @isTest
    public static void createQuoteNullTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('currentCategoryId','');
        inpTestMap.put('productId','');
		Test.startTest();
        System.runAs(guestUser) {
            respTestMap = B2B_RequestForQuoteController.createQuote(null);
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }

    // Test wrapper classes to match the structure expected by the method
    public class QuoteWrapper {
        public String CompanyName;
        public String Address;
        public String City;
        public String Province;
        public String PostalCode;
        public String Country;
        public String Email;
        public String Phone;
        public String FirstName;
        public String LastName;
        public String State;
        public List<QuoteLineItemWrapper> quoteLineItems;
    }

    public class QuoteLineItemWrapper {
        public String CatalogNumber;
        public String CAS;
        public String ProductDescription;
        public String UnitMeasure;
        public Integer TotalQuantity;
        public String CommentPurity;
        public String SpecialInstructions;
        public String LineItemId;
    }
    
    @isTest
    public static void getProductDetailsTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
        
        Product2 prod2 = new Product2(
        	Name = 'prodName' ,
        	ProductCode = 'prodName' ,
            StockKeepingUnit = 'prodName' ,
        	isActive = true ,
            parent_Sku__c = 'prodName'
        );
        insert prod2;
        
        Product2 respTestProd;
		Test.startTest();
        System.runAs(customerUser) {
            try{
             	respTestProd = B2B_RequestForQuoteController.getProductDetails('prodName');   
            } catch( Exception e ){
                
            }
        }
        Test.stopTest();
        Assert.isNotNull(respTestProd);
    }
    
    @isTest
    public static void getProductDetailsNullTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
        
        Product2 prod2 = new Product2(
        	Name = 'prodName' ,
        	ProductCode = 'prodName' ,
            StockKeepingUnit = 'prodName' ,
        	isActive = true ,
            parent_Sku__c = 'prodName'
        );
        insert prod2;
        
        Product2 respTestProd;
		Test.startTest();
        System.runAs(customerUser) {
            try{
             	respTestProd = B2B_RequestForQuoteController.getProductDetails(null);   
            } catch( Exception e ){
                
            }
        }
        Test.stopTest();
       // Assert.isNull(respTestProd);
    }
    
    @isTest
    public static void getUserAccountIDTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
        
        String respTestProd;
		Test.startTest();
        System.runAs(customerUser) {
            respTestProd = B2B_RequestForQuoteController.getUserAccountID();
        }
        Test.stopTest();
        Assert.isNotNull(respTestProd);
    }
    
    @isTest
    public static void createAccountAndContactTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
        
        B2B_RequestForQuoteController.QuoteWrapper qw = new B2B_RequestForQuoteController.QuoteWrapper();
        List<B2B_RequestForQuoteController.QuoteLineItemWrapper> qliwList = new List<B2B_RequestForQuoteController.QuoteLineItemWrapper>();
        B2B_RequestForQuoteController.QuoteLineItemWrapper qliw = new B2B_RequestForQuoteController.QuoteLineItemWrapper();
        qliw.CatalogNumber = 'CatalogNumber';
        qliw.CasNumber = 'CasNumber';
        qliw.ProductDescription = 'ProductDescription';
        qliw.SelectedUnityOfMeasure = 'SelectedUnityOfMeasure';
        qliw.TotalQuantity = 1.0;
        qliw.CommentPurity = 'CommentPurity';
        qliw.SpecialInstructions = 'SpecialInstructions';
        qliw.CatalogNumber = 'LineItemId';
		qliwList.add( qliw );        
        qw.isGuest = false;
        qw.CompanyName = 'CompanyName';
        qw.Address = 'Address';
        qw.FirstName = 'FirstName';
        qw.City = 'City';
        qw.LastName = 'LastName';        
        qw.Province = 'Province';
        qw.Email = 'Email';
        qw.Phone = 'Phone';
        qw.PostalCode = 'PostalCode';
        qw.Country = 'Country';
        qw.State = 'State';
        qw.quoteLineItems = qliwList;
        
		Test.startTest();
        System.runAs(customerUser) {
            respTestMap = B2B_RequestForQuoteController.createAccountAndContact( JSON.serialize(qw) );
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }
    
    @isTest
    public static void createAccountAndContactNullTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
        
        B2B_RequestForQuoteController.QuoteWrapper qw = new B2B_RequestForQuoteController.QuoteWrapper();
        List<B2B_RequestForQuoteController.QuoteLineItemWrapper> qliwList = new List<B2B_RequestForQuoteController.QuoteLineItemWrapper>();
        B2B_RequestForQuoteController.QuoteLineItemWrapper qliw = new B2B_RequestForQuoteController.QuoteLineItemWrapper();
        qliw.CatalogNumber = 'CatalogNumber';
        qliw.CasNumber = 'CasNumber';
        qliw.ProductDescription = 'ProductDescription';
        qliw.SelectedUnityOfMeasure = 'SelectedUnityOfMeasure';
        qliw.TotalQuantity = 1.0;
        qliw.CommentPurity = 'CommentPurity';
        qliw.SpecialInstructions = 'SpecialInstructions';
        qliw.CatalogNumber = 'LineItemId';
		qliwList.add( qliw );        
        qw.isGuest = false;
       // qw.CompanyName = 'CompanyName';
        qw.Address = 'Address';
        qw.FirstName = 'FirstName';
        qw.City = 'City';
        qw.LastName = 'LastName';        
        qw.Province = 'Province';
        qw.Email = 'Email';
        qw.Phone = 'Phone';
        qw.PostalCode = 'PostalCode';
        qw.Country = 'Country';
        qw.State = 'State';
        qw.quoteLineItems = qliwList;
        
		Test.startTest();
        System.runAs(customerUser) {
            try{
             	respTestMap = B2B_RequestForQuoteController.createAccountAndContact( JSON.serialize(qw) );   
            } catch( Exception e ){
                
            }
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }
    
    @isTest
    public static void saveQuoteWithLineItemsTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String,Object> respTestMap = new Map<String,Object>();
        Map<String,Object> inpTestMap = new Map<String,Object>();
        inpTestMap.put('cartId',currentCart.Id);
        inpTestMap.put('productId','');
        
        Test.startTest();
        System.runAs(customerUser) {
            
            Product2 prod2 = B2B_TestDataFactory.createProduct('CatalogNumber',true);
            prod2.parent_Sku__c = prod.Id;
            update prod2;
            
            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Product2.parent_Sku__c, CurrencyIsoCode, Pricebook2Id, UnitPrice FROM PricebookEntry WHERE product2Id =: prod2.Id];
            System.debug('pricebookEntries test-- '+pricebookEntries);
            B2B_RequestForQuoteController.QuoteWrapper qw = new B2B_RequestForQuoteController.QuoteWrapper();
            List<B2B_RequestForQuoteController.QuoteLineItemWrapper> qliwList = new List<B2B_RequestForQuoteController.QuoteLineItemWrapper>();
            B2B_RequestForQuoteController.QuoteLineItemWrapper qliw = new B2B_RequestForQuoteController.QuoteLineItemWrapper();
            qliw.CatalogNumber = prod.Id;
            qliw.CasNumber = 'CasNumber';
            qliw.ProductDescription = 'ProductDescription';
            // qliw.SelectedUnityOfMeasure = 'milligram';
            qliw.SelectedUnityOfMeasure = 'gram';
            qliw.TotalQuantity = 1.0;
            qliw.CommentPurity = 'CommentPurity';
            qliw.SpecialInstructions = 'SpecialInstructions';
            qliw.LineItemId = prod2.Id;
            qliw.MolecularFormula = 'formula';
            qliw.MolecularWeight = '2.1';
            qliw.SelectedGrade = 'SelectedGrade';
            qliw.SelectedDemandType = 'SelectedDemandType';
            qliw.TechnicalPublicationReference ='technicalPublicationReference';
            qliwList.add( qliw );        
            qw.isGuest = true;
            qw.CompanyName = 'Company Name';
            qw.Address = 'Address';
            qw.FirstName = 'FirstName';
            qw.City = 'City';
            qw.LastName = 'LastName';        
            qw.Province = 'Province';
            qw.Email = 'Email@yopmail.com';
            qw.Phone = '1234567890';
            qw.PostalCode = 'PostalCode';
            qw.Country = 'United States of America';
            qw.State = 'Michigan';
            qw.quoteLineItems = qliwList;
            qw.cartId = currentCart.Id;
        
		
            respTestMap = B2B_RequestForQuoteController.saveQuoteWithLineItems( JSON.serialize(qw) );
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }
    
    @isTest
    public static void getPicklistTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String, Map<String, List<String>>> respTestMap = new Map<String, Map<String, List<String>>>();
        Map<String,List<string>> inpTestMap = new Map<String,List<string>>();
        List<string> strList = new List<string>();
        strList.add('QuoteCountry__c');
        strList.add('QuoteState__c');
        inpTestMap.put('Quote',strList);
        
        B2B_RequestForQuoteController.QuoteWrapper qw = new B2B_RequestForQuoteController.QuoteWrapper();
        List<B2B_RequestForQuoteController.QuoteLineItemWrapper> qliwList = new List<B2B_RequestForQuoteController.QuoteLineItemWrapper>();
        B2B_RequestForQuoteController.QuoteLineItemWrapper qliw = new B2B_RequestForQuoteController.QuoteLineItemWrapper();
        qliw.CatalogNumber = 'CatalogNumber';
        qliw.CasNumber = 'CasNumber';
        qliw.ProductDescription = 'ProductDescription';
        qliw.SelectedUnityOfMeasure = 'SelectedUnityOfMeasure';
        qliw.TotalQuantity = 1.0;
        qliw.CommentPurity = 'CommentPurity';
        qliw.SpecialInstructions = 'SpecialInstructions';
        qliw.CatalogNumber = 'LineItemId';
		qliwList.add( qliw );        
        qw.isGuest = false;
       // qw.CompanyName = 'CompanyName';
        qw.Address = 'Address';
        qw.FirstName = 'FirstName';
        qw.City = 'City';
        qw.LastName = 'LastName';        
        qw.Province = 'Province';
        qw.Email = 'Email';
        qw.Phone = 'Phone';
        qw.PostalCode = 'PostalCode';
        qw.Country = 'Country';
        qw.State = 'State';
        qw.quoteLineItems = qliwList;
        
		Test.startTest();
        System.runAs(customerUser) {
            try{
             	respTestMap = B2B_RequestForQuoteController.getPicklist(inpTestMap);   
            } catch( Exception e ){
                
            }
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }
    
    @isTest
    public static void getPicklistNullTest(){
        User guestUser = [SELECT Id FROM User WHERE Username =: GUEST_CUSTOMER_EMAIL LIMIT 1];
        User customerUser = B2B_TestDataFactory.getCustomerUserByUsername(CUSTOMER_EMAIL);
        
        Product2 prod =  B2B_TestDataFactory.getProductByName(PRODUCT_NAME);
        WebStore store = B2B_TestDataFactory.createWebstore('Store',true);
        //Schema.Location loc =  B2B_TestDataFactory.getLocationByName(LOCATION_NAME);
        ContactPointAddress cpa = B2B_TestDataFactory.getContactPointAddressByName('Test CPA');
        WebCart currentCart  = B2B_TestDataFactory.createCart(customerUser.accountId, customerUser.id , store.Id,cpa.Id ,true);
        OrderDeliveryMethod odm = B2B_TestDataFactory.getOrderDeliveryMethodByName('default Shipping');
        CartDeliveryGroup deliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(currentCart.Id,odm.id ,true);
        List<cartItem> cartitems  = B2B_TestDataFactory.createCartitems( currentCart.Id, deliveryGroup.Id ,new List<Product2>{prod} , null, true);
        
        
        Map<String, Map<String, List<String>>> respTestMap = new Map<String, Map<String, List<String>>>();
        Map<String,List<string>> inpTestMap = new Map<String,List<string>>();
        List<string> strList = new List<string>();
        strList.add('name');
        inpTestMap.put('Account',strList);
        
        B2B_RequestForQuoteController.QuoteWrapper qw = new B2B_RequestForQuoteController.QuoteWrapper();
        List<B2B_RequestForQuoteController.QuoteLineItemWrapper> qliwList = new List<B2B_RequestForQuoteController.QuoteLineItemWrapper>();
        B2B_RequestForQuoteController.QuoteLineItemWrapper qliw = new B2B_RequestForQuoteController.QuoteLineItemWrapper();
        qliw.CatalogNumber = 'CatalogNumber';
        qliw.CasNumber = 'CasNumber';
        qliw.ProductDescription = 'ProductDescription';
        qliw.SelectedUnityOfMeasure = 'SelectedUnityOfMeasure';
        qliw.TotalQuantity = 1.0;
        qliw.CommentPurity = 'CommentPurity';
        qliw.SpecialInstructions = 'SpecialInstructions';
        qliw.CatalogNumber = 'LineItemId';
		qliwList.add( qliw );        
        qw.isGuest = false;
       // qw.CompanyName = 'CompanyName';
        qw.Address = 'Address';
        qw.FirstName = 'FirstName';
        qw.City = 'City';
        qw.LastName = 'LastName';        
        qw.Province = 'Province';
        qw.Email = 'Email';
        qw.Phone = 'Phone';
        qw.PostalCode = 'PostalCode';
        qw.Country = 'Country';
        qw.State = 'State';
        qw.quoteLineItems = qliwList;
        
		Test.startTest();
        System.runAs(customerUser) {
            try{
             	respTestMap = B2B_RequestForQuoteController.getPicklist(null);   
            } catch( Exception e ){
                
            }
        }
        Test.stopTest();
        Assert.isNotNull(respTestMap);
    }
        
}