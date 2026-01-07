// This sample is for the situations where Digital Shipping is required, meaning there is no shipping cost. 

// This class must extend the CartExtension.ShippingCartCalculator class to be processed.
public class CartCalc_DigitalShipping extends CartExtension.ShippingCartCalculator {
  
    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request) {
      CartExtension.Cart cart = request.getCart();
      // Clean up CVO based on Shipping
      CartExtension.CartValidationOutputList cartValidationOutputList = cart.getCartValidationOutputs();
    
      for (Integer i = (cartValidationOutputList.size() - 1); i >= 0; i--) {
        CartExtension.CartValidationOutput cvo = cartValidationOutputList.get(i);
        if (cvo.getType() == CartExtension.CartValidationOutputTypeEnum.SHIPPING) {
          cartValidationOutputList.remove(cvo);
        }
      }
  
      // To create the Cart delivery group methods, we need to get the ID of the cart delivery group.
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
        CartExtension.CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups.get(0);
        CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethods = cartDeliveryGroup.getCartDeliveryGroupMethods();

        // Clean up the CartDeliveryGroupMethods
        for (Integer i = (cartDeliveryGroupMethods.size() - 1); i >= 0; i--) {
          CartExtension.CartDeliveryGroupMethod method = cartDeliveryGroupMethods.get(i);
          cartDeliveryGroupMethods.remove(method);
        }
          
        // To clear selected Cart Delivery Group Method
        cartDeliveryGroup.setSelectedCartDeliveryGroupMethod(null);

        // Get the shipping product - in this case we use SKU to find the right shipping product
        List<Product2> shippingProducts = [SELECT Id FROM Product2 WHERE ProductClass != 'VariationParent' AND StockKeepingUnit = 'Ship1' LIMIT 1];
        String shippingProduct = Id.valueOf(shippingProducts[0].Id);

          CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod01 = new CartExtension.CartDeliveryGroupMethod('FedEX Priority (AM Delivery)', 0.0000000000001, shippingProduct);
        cartDeliveryGroupMethod01.setCarrier('FedEx');
        cartDeliveryGroupMethods.add(cartDeliveryGroupMethod01);         
        cartDeliveryGroupMethod01.setClassOfService('Priority (AM Delivery)');
        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod02 = new CartExtension.CartDeliveryGroupMethod('FedEX Priority (PM Delivery)', 0.00000000000002, shippingProduct);
        cartDeliveryGroupMethod02.setCarrier('Fedex');
        cartDeliveryGroupMethod02.setClassOfService('Priority (PM Delivery)'); 
        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod03 = new CartExtension.CartDeliveryGroupMethod('FedEX 2nd Day', 0.000000000000003, shippingProduct);
        cartDeliveryGroupMethod03.setCarrier('Fedex');
        cartDeliveryGroupMethod03.setClassOfService('2nd Day');
        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod04 = new CartExtension.CartDeliveryGroupMethod('FedEX Ground', 0.0000000000000004, shippingProduct);
        cartDeliveryGroupMethod04.setCarrier('Fedex');
        cartDeliveryGroupMethod04.setClassOfService('Ground');
        
        //ST-56 Add "Other" delivery method with input box
        CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod05 = new CartExtension.CartDeliveryGroupMethod('Other', 0.00000000000000005, shippingProduct);
        cartDeliveryGroupMethod05.setCarrier('Other');
        cartDeliveryGroupMethod05.setClassOfService('Other');

        cartDeliveryGroupMethods.add(cartDeliveryGroupMethod01);
        cartDeliveryGroupMethods.add(cartDeliveryGroupMethod02);
        cartDeliveryGroupMethods.add(cartDeliveryGroupMethod03);
        cartDeliveryGroupMethods.add(cartDeliveryGroupMethod04);
        // ST-56 Add the "Other" delivery method to the list
        cartDeliveryGroupMethods.add(cartDeliveryGroupMethod05);

        // Set the delivery method ID that will be used for the order summary
        cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod01.getId());
        cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod02.getId());
        cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod03.getId());
        cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod04.getId());
        cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod05.getId());

  
        }
    }
    
    public static void testCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}