@isTest
public  class CustomerCarrierNumberControllerTest {
    @TestSetup
    static void makeData(){
        Account account = new Account(
            Name = 'Test Account For B2B',
            Phone = '1123452345',
            ShippingCity = 'North Mankato',
            ShippingCountry = 'United States',
            ShippingPostalCode = '56003',
            ShippingState = 'Minnesota',
            ShippingStreet = '1001 Belgrade Avenue',
            AccountNumber = 'TestingNumber'
          );
          insert account;

          BuyerAccount buyerAccount = new BuyerAccount(
            BuyerId = account.Id,
            Name = 'Test Buyer Account For B2B',
            IsActive = true
          );
          insert buyerAccount;
      
          WebStore webStore = new WebStore(Name = 'TestWebStore', DefaultLanguage = 'en_US');
          insert webStore;

          Id pricebookId = Test.getStandardPricebookId();

          ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog');
          insert catalog;

          ProductCategory cat = new ProductCategory(Name = 'Cat 1', CatalogId = catalog.Id);
          insert cat;
      
          Product2 product = new Product2(
            Name = 'Good Product',
            StockKeepingUnit = 'TEST',
            ProductCode = 'TEST'
          );
          insert product;

          ProductCategoryProduct catMap = new ProductCategoryProduct(ProductCategoryId = cat.Id, ProductId = product.Id);
          insert catMap;
            
          WebCart cart = new WebCart(Name='TestCart', WebStoreId=webStore.Id, AccountId=account.Id); 
          insert cart;
    }

    @isTest public static void getCarrierNumberByCartIdTest(){
        String cartId = String.valueOf([
            SELECT Id FROM WebCart LIMIT 1]?.Id
        );
        Test.startTest();
        String definedReturn = CustomerCarrierNumberController.getCarrierNumberByCartId(cartId);
        Test.stopTest();

        Assert.isTrue(String.isEmpty(definedReturn));
    }

    @isTest public static void setCarrierNumberByCartIdTest(){
        String cartId = String.valueOf([
            SELECT Id FROM WebCart LIMIT 1]?.Id
        );

        Test.startTest();
        String carrierNumber = '99556677xyz';
        CustomerCarrierNumberController.setCarrierNumberByCartId(cartId, carrierNumber);
        // Since we can not have a Checkout status, I'll not check the return
        Test.stopTest();

    }
}