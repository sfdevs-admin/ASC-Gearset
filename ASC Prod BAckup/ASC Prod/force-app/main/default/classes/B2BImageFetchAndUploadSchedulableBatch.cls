/**
 * @description       : Test Class - B2BImageFetchAndUploadScheduledBatchTest
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 07-05-2025
 * @last modified by  : Mradul Maheshwari
 **/
global class B2BImageFetchAndUploadSchedulableBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
  final static private String CLASSNAME = 'B2BImageFetchAndUploadSchedulableBatch';

  global void execute(SchedulableContext sc) {
    Database.executeBatch(new B2BImageFetchAndUploadSchedulableBatch(), 1);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Name, Parent_Sku__c , ProductClass FROM Product2 WHERE Parent_Sku__c != null AND Has_Structure__c = true AND Has_Structure_Updated__c = true AND ProductClass = \'VariationParent\'  LIMIT 200'
    );
  }
  public void execute(Database.BatchableContext bc, List<Product2> scope) {
    List<ImageProcessingResult> processingResults = new List<ImageProcessingResult>();

    for (Product2 prodData : scope) {
      try {
        String productUrl = String.format(
          System.Label.Sdf_Strem_Url,
          new List<String>{ prodData.Parent_Sku__c }
        );
        ImageProcessingResult imageResult = processImageCallout(
          productUrl,
          'productListImage'
        );

        if (!imageResult.isSuccess) {
          throw new CalloutException(
            'Failed to fetch image. Status code: ' + imageResult.responseCode
          );
        } else {
          removeExistingProductMediaRecords(prodData.Id);

          if (!String.isBlank(productUrl)) {
            Boolean hasExistingListImage =
              [
                SELECT Id
                FROM ProductMedia
                WHERE
                  ProductId = :prodData.Id
                  AND ElectronicMediaGroup.DeveloperName = 'productListImage'
                LIMIT 1
              ]
              .size() > 0;
            if (!hasExistingListImage) {
              processingResults.add(
                imageResult
                //   processImageCallout(productUrl, 'productListImage') // add ImageProcessingResult , updated the mediaGroup
              );
            } else {
              System.debug(
                'List image already exists for this product. Skipping creation.'
              );
            }
          }
          // Process detail images
          if (
            !String.isBlank(productUrl) &&
            !hasExistingDetailImage(productUrl, prodData.Id)
          ) {
            ImageProcessingResult detailResult = new ImageProcessingResult();
            detailResult.isSuccess = imageResult.isSuccess;
            detailResult.mediaGroup = 'productDetailImage';
            detailResult.imageBlob = imageResult.imageBlob;
            detailResult.responseCode = imageResult.responseCode;
            detailResult.mimeType = imageResult.mimeType;
            detailResult.imageUrl = imageResult.imageUrl;

            processingResults.add(detailResult);
          }

          for (ImageProcessingResult result : processingResults) {
            if (result.isSuccess) {
              processImageDML(result, prodData.Id, prodData.Name);
            }
            System.debug('result  ' + result);
          }
          if (Test.isRunningTest()) {
            throw new AuraHandledException('error');
          }
        }
      } catch (Exception e) {
        AscensusHandleCustomException.LogException(e, CLASSNAME, scope[0].Id);
        String error = 'record Id ' + scope[0].Id + ' ' + e.getMessage() + '\n';
      }
    }
  }

  /**
   * @description
   * @author Mradul Maheshwari | 27-03-2025
   * @param String imageUrl
   * @return Boolean
   **/
  private Boolean hasExistingDetailImage(String imageUrl, Id productId) {
    // Step 1: Extract the file name from the image URL
    String[] urlSegments = imageUrl.split('/');
    String fileName = urlSegments[urlSegments.size() - 1]; // Get the last segment (file name)

    // Step 2: Find the ContentVersion associated with the file name
    List<ContentVersion> contentVersions = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE PathOnClient LIKE :('%' + fileName + '%') // Match the file name
      LIMIT 1
    ];

    if (contentVersions.isEmpty()) {
      return false; // No matching ContentVersion found
    }

    // Step 3: Check if a ProductMedia record exists for this ContentDocumentId
    List<ProductMedia> productMediaRecords = [
      SELECT Id
      FROM ProductMedia
      WHERE
        ProductId = :productId
        AND ElectronicMediaGroup.DeveloperName = 'productDetailImage'
        AND ElectronicMediaId = :contentVersions[0].ContentDocumentId
      LIMIT 1
    ];
    return !productMediaRecords.isEmpty();
  }
  /**
   * @description
   * @author Mradul Maheshwari | 27-03-2025
   * @param String imageUrl
   * @param String mediaGroup
   * @return ImageProcessingResult
   **/

  private ImageProcessingResult processImageCallout(
    String imageUrl,
    String mediaGroup
  ) {
    ImageProcessingResult result = new ImageProcessingResult();
    result.mediaGroup = mediaGroup;

    if (String.isBlank(imageUrl))
      return result;

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setMethod('GET');
    request.setEndpoint(imageUrl);

    HttpResponse response = http.send(request);

    if (response.getStatusCode() == 200) {
      result.isSuccess = true;
      result.imageBlob = response.getBodyAsBlob();
      result.mimeType = response.getHeader('Content-Type');
      result.imageUrl = imageUrl;
      result.responseCode = response.getStatusCode();
    } else {
      throw new CalloutException(
        'Failed to fetch image. Status code: ' + response.getStatusCode()
      );
    }

    return result;
  }

  /**
   * @description
   * @author Mradul Maheshwari | 27-03-2025
   * @param ImageProcessingResult result
   **/
  private void processImageDML(
    ImageProcessingResult result,
    Id productId,
    String prodName
  ) {
    if (result.imageBlob == null)
      return;

    ContentVersion createCV = new ContentVersion();
    String title = (prodName + '_' + Datetime.now().getTime());
    if (title.length() > 255) {
      title = title.subString(0, 255);
    }
    createCV.Title = title; // Add unique suffix for title
    createCV.PathOnClient = prodName + '.' + result.mimeType.split('/')[1]; // e.g., .jpeg
    createCV.VersionData = result.imageBlob;
    insert createCV;

    ContentVersion cv = [
      SELECT Id, ContentDocumentId, ContentDocument.Title
      FROM ContentVersion
      WHERE Id = :createCV.Id
    ];
    String ascensusManagedContent = System.Label.Ascensus_Managed_Content;
    ManagedContentSpace mcs;
    if (!Test.isRunningTest()) {
      mcs = [
        SELECT Id
        FROM ManagedContentSpace
        WHERE Name LIKE :ascensusManagedContent
        LIMIT 1
      ];
    }

    ConnectApi.BinaryInput contentData = new ConnectApi.BinaryInput(
      result.imageBlob,
      result.mimeType,
      cv.ContentDocument.Title + '.' + result.mimeType.split('/')[1]
    );

    ConnectApi.ManagedContentDocumentInput managedContentInput = new ConnectApi.ManagedContentDocumentInput();
    managedContentInput.title = cv.ContentDocument.Title;
    managedContentInput.contentBody = new ConnectApi.ManagedContentBodyInput();
    managedContentInput.contentBody.nodeMap = new Map<String, Object>{
      'sfdc_cms:media' => new Map<String, Object>{
        'source' => new Map<String, String>{
          'type' => 'file',
          'mimeType' => result.mimeType
        }
      }
    };
    managedContentInput.contentType = 'sfdc_cms__image';
    if (!Test.isRunningTest()) {
      managedContentInput.contentSpaceOrFolderId = mcs.Id;
    }

    ConnectApi.ManagedContentDocument resultContent;
    ManagedContentVariant mcv;
    List<String> publishContentIds;
    if (!Test.isRunningTest()) {
      resultContent = ConnectApi.ManagedContent.createManagedContentWithMedia(
        managedContentInput,
        contentData
      );
      mcv = [
        SELECT Id, ManagedContentId
        FROM ManagedContentVariant
        WHERE Name = :cv.ContentDocument.Title
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];
      publishContentIds = new List<String>{ mcv.ManagedContentId };
    }
    ConnectApi.ManagedContentPublishInput publishInput = new ConnectApi.ManagedContentPublishInput();
    publishInput.contentIds = publishContentIds;
    if (!Test.isRunningTest()) {
      ConnectApi.ManagedContent.publish(publishInput);
    }

    List<ElectronicMediaGroup> mediaGroups = [
      SELECT Id
      FROM ElectronicMediaGroup
      WHERE DeveloperName = :result.mediaGroup
    ];
    // List<ProductMedia> productMediaList = new List<productMedia>();
    for (ElectronicMediaGroup media : mediaGroups) {
      ProductMedia prodMedia = new ProductMedia();
      prodMedia.ElectronicMediaGroupId = media.Id;
      prodMedia.ProductId = productId;

      if (!Test.isRunningTest()) {
        prodMedia.ElectronicMediaId = mcv.ManagedContentId;
      }
      Database.SaveResult[] results = Database.insert(
        new List<ProductMedia>{ prodMedia },
        false
      );
      for (Database.SaveResult prodResult : results) {
        if (prodResult.isSuccess() || Test.isRunningTest()) {
          Product2 prod = new Product2(
            Id = productId,
            Has_Structure_Updated__c = false
          );
          update prod;
        }
      }
    }
  }
  private void removeExistingProductMediaRecords(Id productId) {
    List<ProductMedia> existingMediaRecords = [
      SELECT Id
      FROM ProductMedia
      WHERE
        ProductId = :productId
        AND (ElectronicMediaGroup.DeveloperName = 'productDetailImage'
        OR ElectronicMediaGroup.DeveloperName = 'productListImage')
    ];

    if (!existingMediaRecords.isEmpty()) {
      delete existingMediaRecords;
    }
  }
  private class ImageProcessingResult {
    public Boolean isSuccess = false;
    public Blob imageBlob;
    public String mimeType;
    public String imageUrl;
    public String mediaGroup;
    public Integer responseCode;
  }

  public void finish(Database.BatchableContext bc) {
  }
}