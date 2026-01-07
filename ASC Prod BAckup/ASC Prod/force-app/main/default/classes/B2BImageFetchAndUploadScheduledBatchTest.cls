/**
 * @description       : 
 * @author            : Mradul Maheshwari
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : Mradul Maheshwari
**/

@isTest
private class B2BImageFetchAndUploadScheduledBatchTest {

    static String testImageUrl = System.Label.Sdf_Strem_Url + 'test-product.png';

  @IsTest
  static void test_WithNoExistingMedia() {
    // Create and insert product
    Product2 prod = new Product2(Name = 'Test Product' , Has_Structure__c = true , Has_Structure_Updated__c = true , Parent_Sku__c = '567894' , Type = 'Base');
    insert prod;

    // Create and insert ElectronicMediaGroup
    ElectronicMediaGroup emg = new ElectronicMediaGroup(
      DeveloperName = 'productListImage',
      Name = 'productListImage test',
      UsageType = 'Standard'
    );
    insert emg;

    // Set the mock HTTP response
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    // Prepare a list of product IDs for the batch
    List<Id> productIds = new List<Id>{ prod.Id };

    // Start test execution
    Test.startTest();
    B2BImageFetchAndUploadSchedulableBatch scheduleJob = new B2BImageFetchAndUploadSchedulableBatch();
    String chron = '0 0 23 * * ?';
    system.schedule('Test Sched', chron, scheduleJob);
    B2BImageFetchAndUploadSchedulableBatch batchJob = new B2BImageFetchAndUploadSchedulableBatch();
    Database.executeBatch(batchJob, 1);
    //  B2BImageFetchAndUploadSchedulableBatch job = new B2BImageFetchAndUploadSchedulableBatch(productIds);
    Test.stopTest();

    // Verify if ContentVersion records were created
    List<ContentVersion> cvs = [
      SELECT Id
      FROM ContentVersion
      WHERE Title LIKE :('%' + prod.Name + '%')
    ];
    System.assert(cvs.size() > 0);

    // Verify ProductMedia records were created
    List<ProductMedia> pms = [
      SELECT Id
      FROM ProductMedia
      WHERE ProductId = :prod.Id
    ];
    //System.assert(pms.size() > 0);
  }

  @IsTest
  static void test_FailedCallout_HandledGracefully() {
    // Create and insert product
    Product2 prod = new Product2(Name = 'Fail Product' , Has_Structure__c = true , Has_Structure_Updated__c = true , Parent_Sku__c = '567894' , Type = 'Base');
    insert prod;

    // Set the mock failed HTTP response
    Test.setMock(HttpCalloutMock.class, new MockFailedHttpResponseGenerator());

    // Prepare a list of product IDs for the batch
    List<Id> productIds = new List<Id>{ prod.Id };

    // Start test execution
    Test.startTest();
    B2BImageFetchAndUploadSchedulableBatch scheduleJob = new B2BImageFetchAndUploadSchedulableBatch();
    String chron = '0 0 23 * * ?';
    system.schedule('Test Sched', chron, scheduleJob);
    B2BImageFetchAndUploadSchedulableBatch batchJob = new B2BImageFetchAndUploadSchedulableBatch();
    Database.executeBatch(batchJob, 1);
    Test.stopTest();

    // Verify no ContentVersion records were created
    List<ContentVersion> contentVersions = [
      SELECT Id
      FROM ContentVersion
      WHERE Title = :prod.Name
    ];
    System.assertEquals(0, contentVersions.size());

    // Verify no ProductMedia records were created
    List<ProductMedia> productMedia = [
      SELECT Id
      FROM ProductMedia
      WHERE ProductId = :prod.Id
    ];
    System.assertEquals(0, productMedia.size());
  }

  @IsTest
  static void test_PassedCallout() {
    // Create and insert product
    Product2 prod = new Product2(Name = 'Fail Product' , Has_Structure__c = true , Has_Structure_Updated__c = true , Parent_Sku__c = '567894' , Type = 'Base');
    insert prod;

    // Insert ContentVersion for the product
    ContentVersion cv = new ContentVersion(
      Title = 'Fail Product',
      PathOnClient = '/' + 'Fail Product',
      VersionData = Blob.valueOf('Your File Content Here')
    );
    insert cv;

    // Set the mock failed HTTP response
    Test.setMock(HttpCalloutMock.class, new MockFailedHttpResponseGenerator());

    // Prepare a list of product IDs for the batch
    List<Id> productIds = new List<Id>{ prod.Id };

    // Start test execution
    Test.startTest();
    B2BImageFetchAndUploadSchedulableBatch scheduleJob = new B2BImageFetchAndUploadSchedulableBatch();
    String chron = '0 0 23 * * ?';
    system.schedule('Test Sched', chron, scheduleJob);
    B2BImageFetchAndUploadSchedulableBatch batchJob = new B2BImageFetchAndUploadSchedulableBatch();
    Database.executeBatch(batchJob, 1);

    Test.stopTest();

    // Verify if ContentVersion records were created
    List<ContentVersion> contentVersions = [
      SELECT Id
      FROM ContentVersion
      WHERE Title = :prod.Name
    ];
    System.assertEquals(1, contentVersions.size());
  }

  // Mock success response for HTTP callouts
  private class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'image/png');
      res.setBodyAsBlob(Blob.valueOf('fake image'));
      res.setStatusCode(200);
      return res;
    }
  }

  // Mock failure response for HTTP callouts
  private class MockFailedHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(404);
      res.setBody('Not Found');
      return res;
    }
  }
}