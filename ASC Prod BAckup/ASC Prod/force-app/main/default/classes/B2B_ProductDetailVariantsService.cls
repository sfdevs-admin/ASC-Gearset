/**
 * @description       :
 * @author            : surya.thakur
 * @group             :
 * @last modified on  : 03-02-2025
 * @last modified by  : Mradul Maheshwari
 **/
public without sharing class B2B_ProductDetailVariantsService {
  public B2B_ProductDetailVariantsService() {
  }

  public static Map<String, Object> getProductAvailability(
    Map<String, Object> mapParams
  ) {
    Boolean isSuccess = false;
    String message = '';
    System.debug(
      'getProductAvailability mapParams-- ' + JSON.serialize(mapParams)
    );
    if (
      !mapParams.isEmpty() &&
      mapParams.containsKey('catalogItemNumber') &&
      mapParams.containsKey('productSKU') &&
      mapParams.containsKey('inputQTY') &&
      mapParams.containsKey('countryCode') &&
      mapParams.containsKey('unitSize')
    ) {
      String catalogItemNumber = (String) mapParams.get('catalogItemNumber');
      String productSKU = (String) mapParams.get('productSKU');
      Integer inputQTY = Integer.valueOf((String) mapParams.get('inputQTY'));
      String countryCode = (String) mapParams.get('countryCode');
      String unitSize = (String) mapParams.get('unitSize');
      String guestIpAddress = (String) mapParams.get('guestIpAddress');
      String userCountry = (String) mapParams.get('userCountry');

      List<String> output = B2B_CheckAvailabilityController.getProductAvailability(
        catalogItemNumber,
        productSKU,
        inputQTY,
        countryCode,
        unitSize,
        guestIpAddress,
        userCountry
      );
      System.debug('getProductAvailability output-- ' + output);
      if (!output.isEmpty()) {
        mapParams.put('output', output);
        isSuccess = true;
      } else {
        message = 'No data found';
      }
    }
    mapParams.put('isSuccess', isSuccess);
    mapParams.put('message', message);
    return mapParams;
  }
}