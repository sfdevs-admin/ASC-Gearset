@IsTest
public class B2B_TestDataFactory {

    private static final String SYS_ADMIN_PROFILE = 'Stack System Administrator';
    private static final String CUSTOMER_PROFILE = 'Ascensus Customer Community Plus User';
    private static final String GUEST_CUSTOMER_PROFILE = 'Ascensus Profile';
    private static final String GUEST_CUSTOMER_PERMISSION_SET = 'Ascensus_Guest_Buyer';

    private static final String TEST_ADMIN_LAST_NAME = 'AdminLast';
    private static final String TEST_ADMIN_USERNAME = 'AdminLast@testing.class' ;
    public static final String TEST_ADMIN_EMAIL = 'testadmin@testadmin.com';
    public static final String TEST_ADMIN_ALIAS = 'tadmi';

    private static final String CUSTOMER_USER_FIRST_NAME = 'CustomerFirstName';
    private static final String CUSTOMER_USER_LAST_NAME = 'CustomerLastName';
    private static final String CUSTOMER_USER_ALIAS = 'cuser';
    private static final String GUEST_CUSTOMER_USER_FIRST_NAME = 'GuestCustomerFirstName';
    private static final String GUEST_CUSTOMER_USER_LAST_NAME = 'GuestCustomerLastName';
    private static final String GUEST_CUSTOMER_USER_ALIAS = 'gcusr';

    private static final String CONTACT_LAST_NAME = 'ContactLast';

    //private static final String ADMIN_ROLE = 'Default'; //todo to confirm
    private static final String ADMIN_ROLE = 'User'; //todo to confirm

    public static String TIMEZONE = 'GMT';
    public static String US_LOCALE = 'en_US';
    public static String EMAIL_ENCODING = 'UTF-8';

    public static String BILLING_STREET = '1600 Pennsylvania Ave NW';
    public static String BILLING_CITY = 'Washington';
    public static String BILLING_STATE = 'DC';
    public static String BILLING_POSTAL_CODE = '20001';
    public static String BILLING_COUNTRY = 'United States';

    public static User createAdminUser(String name, Boolean doInsert) {
        User adminUser = new User(
                FirstName = name,
                LastName = TEST_ADMIN_LAST_NAME,
                ProfileId = getProfileByName(SYS_ADMIN_PROFILE).Id,
                Username = TEST_ADMIN_USERNAME,
                Email = TEST_ADMIN_EMAIL,
                Alias = TEST_ADMIN_ALIAS,
                TimeZoneSidKey = TIMEZONE,
                LanguageLocaleKey = US_LOCALE,
                EmailEncodingKey = EMAIL_ENCODING,
                LocaleSidKey = US_LOCALE,
                UserRoleId = getUserRoleByName(ADMIN_ROLE).Id
        );

        if (doInsert) {
            insert adminUser;
        }

        return adminUser;
    }

    public static User createUser(String communityNickname, String email, Id contactId, Boolean doInsert) {
        User customerUser = new User(
                FirstName = CUSTOMER_USER_FIRST_NAME,
                LastName = CUSTOMER_USER_LAST_NAME,
                Alias = CUSTOMER_USER_ALIAS,
                ProfileId = getProfileByName(CUSTOMER_PROFILE).Id,
                ContactId = contactId,
                CommunityNickname = communityNickname,
                Email = email,
                Username = email,
                TimeZoneSidKey = TIMEZONE,
                LanguageLocaleKey = US_LOCALE,
                EmailEncodingKey = EMAIL_ENCODING,
                LocaleSidKey = US_LOCALE
        );

        if (doInsert) {
            insert customerUser;
        }

        return customerUser;
    }
    
    public static User createGuestUser(String communityNickname, String email, Id contactId, Boolean doInsert) {
        User customerUser = new User(
                FirstName = GUEST_CUSTOMER_USER_FIRST_NAME,
                LastName = GUEST_CUSTOMER_USER_LAST_NAME,
                Alias = GUEST_CUSTOMER_USER_ALIAS,
                ProfileId = getProfileByName(GUEST_CUSTOMER_PROFILE).Id,
                ContactId = contactId,
                CommunityNickname = communityNickname,
                Email = email,
                Username = email,
                TimeZoneSidKey = TIMEZONE,
                LanguageLocaleKey = US_LOCALE,
                EmailEncodingKey = EMAIL_ENCODING,
                LocaleSidKey = US_LOCALE
        );

        if (doInsert) {
            insert customerUser;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: GUEST_CUSTOMER_PERMISSION_SET];
            insert new PermissionSetAssignment(AssigneeId = customerUser.Id, PermissionSetId = ps.Id);
            //assignPermissionSetGroup(customerUser.Id);
        }

        return customerUser;
    }

    public static void assignPermissionSetGroup(Id userId) {
        PermissionSetGroup psg = getPermissionSetGroup();
        Test.calculatePermissionSetGroup(psg.Id);
        PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetGroupId = psg.Id,
                AssigneeId = userId);
        insert assignment;
    }

    public static Account createAccount(String name, Boolean doInsert) {
        Account account = new Account(
                Name = name,
                BillingStreet = BILLING_STREET,
                BillingCity = BILLING_CITY,
                BillingState = BILLING_STATE,
                BillingPostalCode = BILLING_POSTAL_CODE,
                BillingCountry = BILLING_COUNTRY
        );

        if (doInsert) {
            insert account;
        }
        return account;
    }

    public static Contact createContact(String name, Id accountId, Boolean doInsert) {
        Contact contact = new Contact(
                FirstName = name,
                LastName = CONTACT_LAST_NAME,
                AccountId = accountId
        );

        if (doInsert) {
            insert contact;
        }
        return contact;
    }

    public static LocationGroup createLocationGroup(String name, Boolean doInsert) {
        LocationGroup locationGroup = new LocationGroup(
                LocationGroupName = name
        );

        if (doInsert) {
            insert locationGroup;
        }
        return locationGroup;
    }

    public static Schema.Location createLocation(String name, Boolean doInsert) {
        Schema.Location location = new Schema.Location(
                Name = name
        );

        if (doInsert) {
            insert location;
        }
        return location;
    }

    public static LocationGroupAssignment createLocationGroupAssignment(Id groupId, Id locationId, Boolean doInsert) {
        LocationGroupAssignment locationGroupAssignment = new LocationGroupAssignment(
                LocationGroupId = groupId,
                LocationId = locationId
        );

        if (doInsert) {
            insert locationGroupAssignment;
        }
        return locationGroupAssignment;
    }

    public static ContactPointAddress createShippingCPA(Account acc, Boolean doInsert) {

        ContactPointAddress cpa = new ContactPointAddress();
        cpa.Name = 'Test CPA';
        cpa.AddressType = 'Shipping';
        cpa.Street = 'TestStreet';
        cpa.City = 'TestCity';
        cpa.State = 'Geogia';
        cpa.Country = 'United States';
        //cpa.StateCode ='GA';
        //cpa.CountryCode ='US';
        cpa.PostalCode = '30071';
        cpa.IsDefault = true;
        cpa.ParentId = acc.Id;
        cpa.CompanyName = acc.name ;
        cpa.PhoneNumber = '9876543210' ;
        if (doInsert) {
            insert cpa;
        }
        return cpa;
    }

    public static OrderDeliveryMethod createOrderDeliveryMethod(Boolean doInsert) {
        Product2 shipProduct = new Product2();
        shipProduct.Name = 'Default Shipping Product' ;
        shipProduct.ProductCode = 'Default Shipping Product' ;
        shipProduct.StockKeepingUnit = 'Default Shipping Product' ;
        shipProduct.isActive = true ;
        insert shipProduct;
        OrderDeliveryMethod odm = new OrderDeliveryMethod();
        odm.Name = 'default Shipping';
        odm.ProductId = shipProduct.Id;
        odm.IsActive = true;
        odm.ReferenceNumber = 'TR';
        if (doInsert) {
            insert odm;
        }
        return odm;
    }

    public static Product2 createProduct(String prodName, Boolean doInsert) {
        Product2 prod = new Product2();
        prod.Name = prodName ;
        prod.ProductCode = prodName ;
        prod.StockKeepingUnit = prodName ;
        prod.isActive = true ;
        if (doInsert) {
            insert prod;
            PricebookEntry pbe = new PricebookEntry(
            	Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = prod.Id,
                UnitPrice = 100,
                IsActive = true,
                CurrencyIsoCode = 'USD'
            );
            insert pbe;
        }
        return prod;
    }
    
    public static Product2 createVariationProduct(String prodName, Boolean doInsert) {
        Product2 prod = new Product2();
        prod.Name = prodName ;
        prod.ProductCode = prodName ;
        prod.StockKeepingUnit = prodName ;
        prod.isActive = true ;
        //prod.ProductClass = 'Variation';
        prod.Type = 'Base';
        if (doInsert) {
            insert prod;
        }
        return prod;
    }

    public static ProductCatalog createProductCatalog(String name, Boolean doInsert) {
        ProductCatalog productCatalog = new ProductCatalog(
                Name = name
        );

        if (doInsert) {
            insert productCatalog;
        }
        return productCatalog;
    }

    public static ProductCategory createProductCategory(String name, Id catalogId, Boolean doInsert) {
        ProductCategory productCategory = new ProductCategory(
                Name = name,
                CatalogId = catalogId
        );

        if (doInsert) {
            insert productCategory;
        }
        return productCategory;
    }

    public static WebStore createWebstore(String name, Boolean doInsert) {
        WebStore store = new WebStore(
                Name = name
        );

        if (doInsert) {
            insert store;
        }
        return store;
    }

    public static WebCart createCart(String accountId, String userId, String webStoreId,String cpaId ,Boolean doInsert) {
        WebCart currentCart = new WebCart(
                                Name = 'Cart',
                                AccountId = accountId,
                                OwnerId = userId,
                                Status = 'Active',
                                Type = 'Cart',
                                WebStoreId = webStoreId
                        );

        if (doInsert) {
            insert currentCart;
        }
        return currentCart;
    }

    public static CartDeliveryGroup createCartDeliveryGroup(String cartId,String orderDeliveryMethodId,Boolean doInsert) {

        CartDeliveryGroup deliveryGroup =  new CartDeliveryGroup(
                                                Name = 'Default',
                                                DeliveryMethodId = orderDeliveryMethodId,
                                                CartId = cartId,
                                                DeliverToName = 'CompanyName' ,
                                                DeliverToStreet = '221B' ,
                                                DeliverToCity = 'Norcross' ,
                                                DeliverToState = 'Georgia' ,
                                                DeliverToPostalCode ='30071' ,
                                                DeliverToCountry = 'United States'
                                            );

        if (doInsert) {
            insert deliveryGroup;
        }
        return deliveryGroup;
    }

    public static List<cartItem> createCartitems(String cartId,String cartDeliveryGroupId ,List<Product2> products ,String locationId,Boolean doInsert) {
        List<cartItem> cartitems = new List<cartItem>();
        for(Product2 prod: products){

            cartItems.add(new CartItem(
                    CartId = cartId,
                    Product2Id = prod.Id,
                    Quantity = 1,
                    CartDeliveryGroupId = cartDeliveryGroupId,
                    Name = prod.Name,
                    SalesPrice =  5 ,
                    UnitAdjustedPrice = 5,
                    ListPrice =  5 ,
                    NetUnitPrice = 5,
                    GrossUnitPrice = 5,
                    TotalLineAmount = 5 ,
                    TotalPrice = 5 ,
                    TotalListPrice = 5,
                	Type = 'Product'
            ));
        }

        if (doInsert) {
            insert cartitems;
        }
        return cartitems;
    }

    public static Profile getProfileByName(String profileName) {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :profileName];
        return profiles[0];
    }

    public static User getCustomerUserByUsername(String username) {
        List<User> users = [SELECT Id, ContactId,AccountId, Contact.Name FROM User WHERE Username = :username];
        return users[0];
    }

    public static UserRole getUserRoleByName(String roleName) {
        List<UserRole> roles = [SELECT Id FROM UserRole WHERE Name = :roleName];
        return roles[0];
    }

    public static Schema.Location getLocationByName(String locName) {
        List<Schema.Location> locations = [SELECT Id FROM Location WHERE Name = :locName];
        return locations[0];
    }

    public static PermissionSetGroup getPermissionSetGroup(){
        List<PermissionSetGroup> permissionSetGroups = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName= 'Storefront_User'];
        return permissionSetGroups[0];
    }

    public static Product2 getProductByName(String prodName) {
        List<Product2> products = [SELECT Id,Name FROM Product2 WHERE Name = :prodName];
        return products[0];
    }

    public static OrderDeliveryMethod getOrderDeliveryMethodByName(String odmName) {
        List<OrderDeliveryMethod> odms = [SELECT Id FROM OrderDeliveryMethod WHERE Name = :odmName];
        return odms[0];
    }

    public static ContactPointAddress getContactPointAddressByName(String cpaName) {
        List<ContactPointAddress> cpas = [SELECT Id FROM ContactPointAddress WHERE Name = :cpaName];
        return cpas[0];
    }

    public static ProductCategory getProductCategoryByName(String name) {
        List<ProductCategory> productCategories = getProductCategoriesByNames(new List<String> {name});
        if (productCategories.size() == 1) {
            return productCategories[0];
        } else {
            return null;
        }
    }

    public static List<ProductCategory> getProductCategoriesByNames(List<String> categoryNames) {
        return [SELECT Name FROM ProductCategory WHERE Name IN :categoryNames];
    }

}