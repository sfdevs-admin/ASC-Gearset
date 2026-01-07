@isTest
public class CustomPaymentControllerTest {
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
            AccountNumber = 'TestingNumber' ,
            PaymentOptions__c = 'Credit Card'
          );
          insert account;

          PaymentMethod__c objPayMet = new PaymentMethod__c(
            AccountId__c = account.Id,
            Type__c = 'Credit Card', 
            BillingFullName__c = account.Name, 
            Last4__c = '1234'
          );

          insert objPayMet;

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


    @isTest public static void getPaymentMethodsByAccountIdTest(){
        String accountId = String.valueOf([
            SELECT Id FROM Account LIMIT 1]?.Id
        );
        String strFilter = '{"pickListFields":["PaymentOptions__c","AccountPaymentMethodId__c"]}';

        Test.startTest();
        Map<String,List<DropDownListDTO>> mapReturn = CustomPaymentController.getPaymentMethodsByAccountId(accountId, strFilter);
        Test.stopTest();

        Assert.isTrue(mapReturn.size() > 0);

    }

    @isTest public static void setPaymentMethodTest(){
        String cartId = String.valueOf([
            SELECT Id FROM WebCart LIMIT 1]?.Id
        );

        Test.startTest();
        String accountPaymentMethodId = String.valueOf([
            SELECT Id FROM PaymentMethod__c LIMIT 1
        ]?.Id);

        CustomPaymentController.setPaymentMethod(cartId, accountPaymentMethodId, 'Credit Card');
        // Since we can not have a Checkout status, I'll not check the return
        Test.stopTest();

        // Check if the data is saved there
        WebCart objCart = [
            SELECT Id, AccountPaymentMethodId__c, PoNumber 
            FROM WebCart 
            WHERE Id =: cartId
            LIMIT 1
        ];

        Assert.areEqual(accountPaymentMethodId, String.valueOf(objCart.AccountPaymentMethodId__c));

    }


    @isTest public static void setPurchaseOrderNumberByCartIdTest(){
        String cartId = String.valueOf([
            SELECT Id FROM WebCart LIMIT 1]?.Id
        );

        Test.startTest();
        String purchaseOrder = 'PO123456789';

        CustomPaymentController.setPurchaseOrderNumberByCartId(cartId, purchaseOrder, 'PO Number');
        // Since we can not have a Checkout status, I'll not check the return
        Test.stopTest();

        // Check if the data is saved there
        WebCart objCart = [
            SELECT Id, AccountPaymentMethodId__c, PoNumber 
            FROM WebCart 
            WHERE Id =: cartId
            LIMIT 1
        ];

        Assert.areEqual(null, objCart.AccountPaymentMethodId__c);

    }

}