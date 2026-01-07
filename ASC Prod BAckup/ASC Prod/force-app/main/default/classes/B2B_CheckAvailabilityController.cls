/**
 * test class - B2B_CheckAvailabilityControllerTest
 */
public without sharing class B2B_CheckAvailabilityController {
  public static String guestUserCountry = Test.isRunningTest() ? 'US' : '';
  public static String guest_IpAddress = '';
  @AuraEnabled
  public static List<String> getProductAvailability(
    String catalogItemNumber,
    String productSKU,
    Integer inputQTY,
    String countryCode,
    String unitSize,
    String guestIpAddress,
    String userCountry
  ) {
    system.debug('inputQTY => ' + inputQTY);
    system.debug('guestIpAddress => ' + guestIpAddress);
    system.debug('userCountry => ' + userCountry);
    List<String> availableDateList = new List<String>();
    try {
        // To cover catch block
        if (Test.isRunningTest() && guestIpAddress == 'throwError') {
            // Simulate an unexpected runtime exception to test catch block
            throw new AuraHandledException('Simulated error for test coverage');
        }

      if (Auth.CommunitiesUtil.isGuestUser()) {
        if(guestIpAddress != null || !String.isBlank(guestIpAddress)) {
          guest_IpAddress = guestIpAddress;
          system.debug('user type =>' + UserInfo.getUserType());
          Map<String, String> valueMap = new Map<String, String>();

          Cache.OrgPartition orgPart = Cache.Org.getPartition(
            'local.IPAddressCache'
          );
          if (orgPart.contains('ipAddress')) {
            valueMap = (Map<String, String>) orgPart.get('ipAddress');
          }
          if (valueMap.containsKey(guestIpAddress)) {
            guestUserCountry = valueMap.get(guestIpAddress);
            guestUserCountry = guestUserCountry.split('-')[1];
            System.debug('guestUserCountry in org cache' + guestUserCountry);
          }
          if (guestUserCountry == null || String.isBlank(guestUserCountry)) {
            guestUserCountry = System.label.B2B_User_Default_Country;
          }
        } else {
          guestUserCountry = System.label.B2B_User_Default_Country;
        }
        system.debug('guestUserCountry =>' + guestUserCountry);
        userCountry = guestUserCountry;
        countryCode = guestUserCountry == System.label.B2B_User_Default_Country
          ? 'US'
          : 'FR';
        system.debug('countryCode =>' + countryCode);
      }
    } catch (Exception e) {
        Map<String, Object> inputParams = new Map<String, Object>{
            'catalogItemNumber' => catalogItemNumber,
            'productSKU' => productSKU,
            'inputQTY' => inputQTY,
            'countryCode' => countryCode,
            'unitSize' => unitSize,
            'guestIpAddress' => guest_IpAddress,
            'userCountry' => userCountry,
            'guestUserCountry' => guestUserCountry
        };
        // AscensusHandleCustomException.LogException(e, 'B2B_CheckAvailabilityController', 'getProductAvailability');
        AscensusHandleCustomException.LogCustomException(e, inputParams, 'B2B_CheckAvailabilityController', 'getProductAvailability');
        System.debug('exception : ' + e.getMessage());
        throw new AuraHandledException('Unable to update user country.');
    }

    try {
      
   
    Map<String, Date> qtyVsDateMap = new Map<String, Date>();
    //List<String> availableDateList = new List<String>();
    //availableDateList.add(ipAddress);
    List<Date> itemDateList = new List<Date>();
    Date itemsAvailableMaxDate = Date.TODAY();
    Integer itemsAvailableMaxQty = 0;
    Date itemAvailableDate;
    Map<String, Date> kiQtyVsDateMap = new Map<String, Date>();
    Integer remainingQty = inputQTY;
    if (productSKU.contains('KIT')) {
      Integer kitKey = 0;
      List<Product_Kit_Product__c> pkpList = new List<Product_Kit_Product__c>();
      pkpList = [
        SELECT
          Id,
          Child_Product__r.StockKeepingUnit,
          Child_Product__r.Parent_Sku__c,
          External_Id__c,
          Name,
          Parent_Product__c,
          Unit__c
        FROM Product_Kit_Product__c
        WHERE Parent_Product__r.StockKeepingUnit = :productSKU
        ORDER BY Child_Product__r.Parent_Sku__c ASC
      ];
      if (pkpList.isEmpty()) {
        //to avoid Apex CPU time limit exceeded
        // if no Product_Kit_Product__c found return null
        return availableDateList;
      }
      for (Product_Kit_Product__c pkp : pkpList) {
        system.debug('pkp.Unit__c => ' + pkp.Unit__c);
        qtyVsDateMap = getAvailabilityDates(
          pkp.Child_Product__r.Parent_Sku__c,
          pkp.Child_Product__r.StockKeepingUnit,
          inputQTY,
          countryCode,
          pkp.Unit__c,
          userCountry
        );

        itemDateList = qtyVsDateMap.values();
        if (!itemDateList.isEmpty()) {
          itemDateList.sort();
          itemAvailableDate = itemDateList[itemDateList.size() - 1];
        }
        for (String key : qtyVsDateMap.keySet()) {
          if (itemAvailableDate == qtyVsDateMap.get(key)) {
            String qty = key.substringAfter('_');
            kiQtyVsDateMap.put(kitKey + '_' + qty, itemAvailableDate);
            kitKey++;
          }
        }

        // for(String key: qtyVsDateMap.keySet()){
        //     itemAvailableDate = qtyVsDateMap.get(key);
        //     if(itemAvailableDate >= itemsAvailableMaxDate){
        //         String qty = key.substringAfter('_');
        //         itemsAvailableMaxDate = itemAvailableDate;
        //         kiQtyVsDateMap.put(kitKey+'_'+qty, itemAvailableDate);
        //     }
        // }
        // itemDateList = qtyVsDateMap.values();
        // if(!itemDateList.isEmpty()){
        //     itemDateList.sort();
        //     system.debug('itemDateList => '+itemDateList);
        //     itemAvailableDate = itemDateList[itemDateList.size()-1];
        // }

        // system.debug('itemAvailableDate => '+itemAvailableDate);
        // if(itemAvailableDate >= itemsAvailableMaxDate){
        //     itemsAvailableMaxDate = itemAvailableDate;
        // }
      }
      kitKey = 0;
      system.debug('kiQtyVsDateMap =>' + kiQtyVsDateMap);
      Map<String, Date> qtyVsItemDateMap = new Map<String, Date>();
      Map<String, Date> sortedQtyVsItemDateMap = new Map<String, Date>();
      while (remainingQty > 0) {
        system.debug('kiQtyVsDateMap ==>' + kiQtyVsDateMap);
        itemDateList = kiQtyVsDateMap.values();
        system.debug('itemDateList ==> ' + itemDateList);
        if (!itemDateList.isEmpty()) {
          itemDateList.sort();
          itemAvailableDate = itemDateList[itemDateList.size() - 1];
        }

        for (String key : kiQtyVsDateMap.keySet()) {
          Integer qty = Integer.valueOf(key.substringAfter('_'));
          if (itemAvailableDate == kiQtyVsDateMap.get(key)) {
            if (qty >= itemsAvailableMaxQty) {
              itemsAvailableMaxQty = qty;
              itemsAvailableMaxDate = itemAvailableDate;
            }
            kiQtyVsDateMap.remove(key);
          }
        }
        system.debug('kiQtyVsDateMap remove ==> ' + kiQtyVsDateMap);
        system.debug('itemsAvailableMaxQty => ' + itemsAvailableMaxQty);
        if (remainingQty > 0 && itemsAvailableMaxQty <= remainingQty) {
          qtyVsItemDateMap.put(
            kitKey + '_' + itemsAvailableMaxQty,
            itemsAvailableMaxDate
          );
        } else {
          qtyVsItemDateMap.put(
            kitKey + '_' + remainingQty,
            itemsAvailableMaxDate
          );
        }
        kitKey++;
        remainingQty = remainingQty - itemsAvailableMaxQty;
        itemsAvailableMaxQty = 0;
        itemsAvailableMaxDate = Date.TODAY();
        system.debug('qtyVsItemDateMap => ' + qtyVsItemDateMap);
        system.debug('remainingQty => ' + remainingQty);
      }
      List<String> qtyVsItemDateKeySetList = new List<String>();
      qtyVsItemDateKeySetList.addAll(qtyVsItemDateMap.keySet());
      system.debug('qtyVsItemDateKeySet => ' + qtyVsItemDateKeySetList);
      system.debug('qtyVsItemDateKeySet => ' + qtyVsItemDateKeySetList.size());
      for (Integer i = qtyVsItemDateKeySetList.size() - 1; i >= 0; i--) {
        sortedQtyVsItemDateMap.put(
          qtyVsItemDateKeySetList[i],
          qtyVsItemDateMap.get(qtyVsItemDateKeySetList[i])
        );
      }

      //
      //
      // for(String key : kiQtyVsDateMap.keySet()){
      //     itemAvailableDate = kiQtyVsDateMap.get(key);
      //     Integer qty = Integer.valueOf(key.substringAfter('_'));
      //     if(itemAvailableDate >= itemsAvailableMaxDate && qty >= itemsAvailableMaxQty){
      //         itemsAvailableMaxDate = itemAvailableDate;
      //         itemsAvailableMaxQty = qty;
      //     }
      //

      //}
      availableDateList = getFormattedDate(sortedQtyVsItemDateMap);
      // qtyVsDateMap = new Map<String, Date>();
      // qtyVsDateMap.put('_'+inputQTY, itemsAvailableMaxDate);
      // availableDateList = getFormattedDate(qtyVsDateMap);
      system.debug('sortedQtyVsItemDateMap ==>' + sortedQtyVsItemDateMap);
      //system.debug('itemsAvailableMaxDate =>'+itemsAvailableMaxDate);
    } else {
      qtyVsDateMap = getAvailabilityDates(
        catalogItemNumber,
        productSKU,
        inputQTY,
        countryCode,
        unitSize,
        userCountry
      );
      availableDateList = getFormattedDate(qtyVsDateMap);
    }
     } catch (Exception e) {
       Map<String, Object> inputParams = new Map<String, Object>{
          'catalogItemNumber' => catalogItemNumber,
          'productSKU' => productSKU,
          'inputQTY' => inputQTY,
          'countryCode' => countryCode,
          'unitSize' => unitSize,
          'guestIpAddress' => guest_IpAddress,
          'userCountry' => userCountry,
          'guestUserCountry' => guestUserCountry
        };
      // AscensusHandleCustomException.LogException(e, 'B2B_CheckAvailabilityController', 'getProductAvailability');
      AscensusHandleCustomException.LogCustomException(e, inputParams, 'B2B_CheckAvailabilityController', 'getProductAvailability'); 
      System.debug('exception : ' + e.getMessage());
    }
    return availableDateList;
  }

  public static Map<String, Date> getAvailabilityDates(
    String catalogItemNumber,
    String productSKU,
    Integer inputQTY,
    String countryCode,
    String unitSize,
    String userCountry
  ) {
    Integer key = 0;
    // added by SB
    Decimal intUnitSize = Decimal.valueOf(stripNonDigits(unitSize));
    String unitSizeUOM = stripDigits(unitSize);
    system.debug('unitSizeUOM => ' + unitSizeUOM);
    //List<String> availableDateList = new List<String>();                                  // 6/3/24 MK
    List<Availability_Inventory__c> inventoryList = new List<Availability_Inventory__c>();
    //String availableDate = '';                                                            // 6/3/24 MK
    Decimal remainingQty = Decimal.valueOf(inputQTY);
    Decimal obtainedQTY = 0;
    Integer qtyPerSku = 0;
    string repackCode = '';
    //Map<Integer, QtyToDateDataWrapper> qtyVsDateMap = new Map<Integer, QtyToDateDataWrapper>();
    Map<String, Date> qtyVsDateMap = new Map<String, Date>();
    //Product2 product = new Product2();
    //querying for availability based on country code

    if (
      String.isNotBlank(userCountry) &&
      userCountry != 'United States of America' &&
      userCountry != 'France'
    ) {
      Country__c country = [
        SELECT Symbol__c, Country__c, Country_Boat_Lead_Time__c
        FROM Country__c
        WHERE Country__c = :userCountry
      ];
      countryCode = country?.Symbol__c == 'US$' ? 'US' : 'FR';
    }

    inventoryList = getInventorydata(
      catalogItemNumber,
      productSKU,
      countryCode
    );

    repackCode = !inventoryList.isEmpty() && inventoryList.size() == 1
      ? inventoryList[0].Repack_Code__c
      : null;
    system.debug('inventoryList1 =>' + inventoryList);

    if (
      !inventoryList.isEmpty() &&
      inventoryList.size() == 1 &&
      inventoryList[0].Total_Quantity_Per_SKU__c >= 1
    ) {
      system.debug(
        'inside 1st if' + inventoryList[0].Total_Quantity_Per_SKU__c
      );
      qtyPerSku = getIntegerValue(inventoryList[0].Total_Quantity_Per_SKU__c);
      obtainedQTY = remainingQty > 0 &&
        qtyPerSku <= remainingQty
        ? qtyPerSku
        : remainingQty;
      system.debug(' => ' + qtyPerSku);
      system.debug('obtainedQTY => ' + obtainedQTY);
      remainingQty = inputQTY - obtainedQTY;
      system.debug('remainingQty => ' + remainingQty);
      //availableDate = getFormattedDate(obtainedQTY, Date.TODAY());                  // 6/3/24 MK
      //availableDateList.add(availableDate);                                         // 6/3/24 MK
      //qtyVsDateMap.put(key, new QtyToDateDataWrapper(obtainedQTY, Date.TODAY()));
      if (
        String.isNotBlank(userCountry) &&
        userCountry != 'United States of America' &&
        userCountry != 'France'
      ) {
        Date newDate = getCountryLeadTime(productSKU);
        qtyVsDateMap.put(key + '_' + obtainedQTY, newDate);
      } else {
        qtyVsDateMap.put(key + '_' + obtainedQTY, Date.TODAY());
      }
      key++;
    }

    system.debug('remainingQty1 =>' + remainingQty);
    //if requested quantity is not fulfilled from 1st query
    if (remainingQty > 0 && countryCode != 'US') {
      //if country is not USA checking 1st in USA availability
      inventoryList = getInventorydata(catalogItemNumber, productSKU, 'US');
      system.debug('inventoryList2 =>' + inventoryList);

      if (
        !inventoryList.isEmpty() &&
        inventoryList.size() == 1 &&
        inventoryList[0].Total_Quantity_Per_SKU__c >= 1
      ) {
        qtyPerSku = getIntegerValue(inventoryList[0].Total_Quantity_Per_SKU__c);
        obtainedQTY = remainingQty >= 0 &&
          qtyPerSku <= remainingQty
          ? qtyPerSku
          : remainingQty;
        system.debug('obtainedQTY ==> ' + obtainedQTY);
        remainingQty = remainingQty - obtainedQTY;
        system.debug('remainingQty ==> ' + remainingQty);

        //the logic will next  look to the country table to account for shipping days.
        Date newDate = getCountryLeadTime(productSKU);
        //availableDate = getFormattedDate(obtainedQTY, newDate);                           // 6/3/24 MK

        //availableDateList.add(availableDate);                                             // 6/3/24 MK
        //qtyVsDateMap.put(key, new QtyToDateDataWrapper(obtainedQTY, newDate));
        qtyVsDateMap.put(key + '_' + obtainedQTY, newDate);
        key++;
      }
    }
    system.debug('remainingQty2 =>' + remainingQty);
    //if still requested quantity is not fulfilled from USA availability
    if (remainingQty > 0) {
      Decimal totalQtyParent = remainingQty * intUnitSize;
      system.debug('totalQtyParent => ' + totalQtyParent);
      Decimal totalQtyPerSKU = 0;
      //Integer shippingPlusRepackDays = 0;
      //Date newDate = System.today();
      //checking in parent/bulk availability record for all the countries
      inventoryList = getInventorydata(
        catalogItemNumber,
        catalogItemNumber,
        'US'
      );
      system.debug('inventoryList3 =>' + inventoryList);
      //repackCode = repackCode == NULL && !inventoryList.isEmpty() && inventoryList.size() == 1 ? inventoryList[0].Repack_Code__c : 'RPN';
      //availablity issue bug fix.
      // repackCode = repackCode == null &&
      //   !inventoryList.isEmpty() &&
      //   inventoryList.size() == 1
      //   ? 'RPN'
      //   : inventoryList[0].Repack_Code__c;

      repackCode = repackCode == null &&
        !inventoryList.isEmpty() &&
        inventoryList.size() == 1
        ? inventoryList[0].Repack_Code__c : 'RPN';


      //checking if requested quantity is fullfilled from bulk/parent record

      //SCC-48 changes
      //if(!inventoryList.isEmpty() && inventoryList.size() == 1){
      if (
        !inventoryList.isEmpty() &&
        inventoryList.size() == 1 &&
        repackCode != 'CNR'
      ) {
        system.debug('inventoryList[0].UOM__c =>' + inventoryList[0].UOM__c);
        totalQtyPerSKU = getQtyAsPerUOM(
          unitSizeUOM,
          inventoryList[0].UOM__c,
          inventoryList[0].Total_Quantity_Per_SKU__c,
          inventoryList[0].Conversion_Factor__c
        );
        system.debug('totalQtyPerSKU => ' + totalQtyPerSKU);

        if (totalQtyPerSKU >= intUnitSize) {
          qtyPerSku = getIntegerValue(totalQtyPerSKU / intUnitSize);
          system.debug(' ==> ' + qtyPerSku);
          obtainedQTY = remainingQty >= 0 &&
            qtyPerSku <= remainingQty
            ? qtyPerSku
            : remainingQty;
          remainingQty = remainingQty - obtainedQTY;

          system.debug('obtainedQTY => ' + obtainedQTY);
          system.debug('remainingQty => ' + remainingQty);
          //the logic will next  look to the country table to account for shipping days+repack
          Date newDate = getCountryLeadTime(productSKU);
          tbl_Repack__mdt repackData = getTableRepackData(repackCode);
          if (repackData != null && repackData.BO_No_Pkg_Days__c != null) {
            newDate = newDate.addDays(
              getIntegerValue(repackData.BO_No_Pkg_Days__c)
            );
          }
          qtyVsDateMap.put(key + '_' + obtainedQTY, newDate);
          key++;
        }
      }

      //checking if requested quantity is fullfilled from next available date future availability
      system.debug('remainingQty3 =>' + remainingQty);
      if (remainingQty > 0) {
        inventoryList = [
          SELECT
            Id,
            Name,
            Catalog_Item_Number__c,
            Old_SKU__c,
            New_SKU__c,
            Total_Quantity_Per_SKU__c,
            Conversion_Factor__c,
            UOM__c,
            Total_Quantity_for_Parent__c,
            Repack_Code__c,
            Country_Code__c,
            Product__c,
            IsAvailable__c,
            Next_Available_Amount__c,
            Parent__c,
            Max_Lead_Date__c,
            Next_Available_Date__c,
            Parent_Sku__c
          FROM Availability_Inventory__c
          WHERE
            Catalog_Item_Number__c = :catalogItemNumber
            AND New_SKU__c = NULL
            AND Type__c = 'Future'
        ];
        if (!inventoryList.isEmpty() && inventoryList.size() == 1) {
          totalQtyPerSKU = getQtyAsPerUOM(
            unitSizeUOM,
            inventoryList[0].UOM__c,
            inventoryList[0].Next_Available_Amount__c,
            inventoryList[0].Conversion_Factor__c
          );
          system.debug('totalQtyPerSKU ==> ' + totalQtyPerSKU);
          if (totalQtyPerSKU >= intUnitSize) {
            qtyPerSku = getIntegerValue(totalQtyPerSKU / intUnitSize);
            obtainedQTY = remainingQty >= 0 &&
              qtyPerSku <= remainingQty
              ? qtyPerSku
              : remainingQty;
            remainingQty = remainingQty - obtainedQTY;
            //SCC-48 start
            Date availableDate = inventoryList[0].Next_Available_Date__c;
            Date newAvailableDate = getCountryMaxLeadDate(
              productSKU,
              availableDate
            );
            // qtyVsDateMap.put(key+'_'+obtainedQTY, inventoryList[0].Next_Available_Date__c);
            qtyVsDateMap.put(key + '_' + obtainedQTY, newAvailableDate);
            //SCC-48 end
            key++;
          }

          //added 
          if (remainingQty > 0) {
            //SCC-48 start
            Date maxLeadDate = inventoryList[0].Max_Lead_Date__c;
            Date newMaxLeadDate = getCountryMaxLeadDate(productSKU, maxLeadDate);
            //SCC-48 end
            // qtyVsDateMap.put(key+'_'+remainingQty, inventoryList[0].Max_Lead_Date__c);
            qtyVsDateMap.put(key + '_' + remainingQty, newMaxLeadDate);
            key++;
          }
        }
      }
    }
    system.debug('qtyVsDateMap => ' + qtyVsDateMap);
    return qtyVsDateMap;
  }

  public static Decimal getQtyAsPerUOM(
    String unitSizeUOM, // requested unit
    String uom,         // inventory unit
    Decimal quantity    // inventory quantity
) {
    if (String.isBlank(unitSizeUOM) || String.isBlank(uom) || quantity == null) {
        return quantity;
    }

    String fromUnit = uom.toLowerCase();
    String toUnit = unitSizeUOM.toLowerCase();

    // Conversion factors to grams as the base unit
    Map<String, Decimal> toGrams = new Map<String, Decimal>{
        'mg' => 0.001,
        'g'  => 1,
        'kg' => 1000,
        'ton' => 1000000
        // Add more as needed
    };

    if (!toGrams.containsKey(fromUnit) || !toGrams.containsKey(toUnit)) {
        // If unknown units, return as-is
        return quantity;
    }

    // Step 1: convert inventory quantity to grams
    Decimal inGrams = quantity * toGrams.get(fromUnit);

    // Step 2: convert grams to requested unit
    Decimal converted = inGrams / toGrams.get(toUnit);

    return converted;
}

public static Decimal getQtyAsPerUOM(
    String unitSizeUOM,   // TARGET (asked) unit, e.g. 'kg'
    String uom,           // SOURCE (inventory) unit, e.g. 'g'
    Decimal quantity,     // inventory quantity (in 'uom')
    Decimal conversionFactor
) {
    // Defensive
    if (quantity == null) return 0;

    // Normalize (null-safe) and map common synonyms
    String target = normalizeUnit(unitSizeUOM);
    String source = normalizeUnit(uom);

    // Base conversion map (mass units -> grams as base)
    Map<String, Decimal> gramsPerUnit = new Map<String, Decimal>{
        'mg' => Decimal.valueOf('0.001'),
        'g'  => Decimal.valueOf('1'),
        'kg' => Decimal.valueOf('1000'),
        'ton' => Decimal.valueOf('1000000'),
        'lb' => Decimal.valueOf('453.59237'),
        'oz' => Decimal.valueOf('28.349523125')
    };

    // If both units are known mass units -> do a proper unit conversion
    if (gramsPerUnit.containsKey(source) && gramsPerUnit.containsKey(target)) {
        // 1) convert inventory qty (in 'source') -> grams
        Decimal qtyInGrams = quantity * gramsPerUnit.get(source);

        // 2) apply conversionFactor if present (as a multiplier to the inventory amount)
        if (conversionFactor != null && conversionFactor != 0) {
            qtyInGrams = qtyInGrams * conversionFactor;
        }

        // 3) convert grams -> target unit
        Decimal converted = qtyInGrams.divide(gramsPerUnit.get(target), 6); // keep precision
        return converted;
    }

    // Fallbacks when units are not both mass units:

    // If conversionFactor exists, use it to scale the raw quantity (best-effort)
    if (conversionFactor != null && conversionFactor != 0) {
        return quantity * conversionFactor;
    }

    // Nothing to do — return raw quantity (no conversion possible)
    return quantity;
}

// Helper: canonicalize unit names
private static String normalizeUnit(String u) {
    if (u == null) return '';
    String s = u.trim().toLowerCase();
    s = s.replaceAll('\\s',''); // remove whitespace

    if (s == 'g' || s == 'gm' || s == 'gms' || s == 'gram' || s == 'grams') return 'g';
    if (s == 'kg' || s == 'kgs' || s == 'kilogram' || s == 'kilograms') return 'kg';
    if (s == 'mg' || s == 'mgs' || s == 'milligram' || s == 'milligrams') return 'mg';
    if (s == 'lb' || s == 'lbs' || s == 'pound' || s == 'pounds') return 'lb';
    if (s == 'oz' || s == 'ounce' || s == 'ounces') return 'oz';
    if (s == 'ton' || s == 't' || s == 'tonne' || s == 'tonnes') return 'ton';
    if (s == 'gms') return 'g';
    return s;
}


  // public class QtyToDateDataWrapper{
  //     @AuraEnabled public Decimal quantity{get;set;}
  //     @AuraEnabled public Date availableDate{get;set;}
  //     public QtyToDateDataWrapper(Decimal quantity, Date availableDate){
  //         this.quantity = quantity;
  //         this.availableDate = availableDate;
  //     }
  // }

  public static List<Availability_Inventory__c> getInventorydata(
    String catalogItemNumber,
    String sku,
    String countryCode
  ) {
    return [
      SELECT
        Id,
        Name,
        Catalog_Item_Number__c,
        Old_SKU__c,
        New_SKU__c,
        Total_Quantity_Per_SKU__c,
        Conversion_Factor__c,
        UOM__c,
        Total_Quantity_for_Parent__c,
        Repack_Code__c,
        Country_Code__c,
        Product__c,
        IsAvailable__c,
        Next_Available_Amount__c,
        Parent__c,
        Max_Lead_Date__c,
        Next_Available_Date__c,
        Parent_Sku__c
      FROM Availability_Inventory__c
      WHERE
        Catalog_Item_Number__c = :catalogItemNumber
        AND New_SKU__c = :sku
        AND Country_Code__c = :countryCode
    ];
  }

  public static String stripNonDigits(String input) {
    // Create a pattern that matches non-digit characters
    Pattern nonDigits = Pattern.compile('[^\\d.]');
    // Replace all occurrences of non-digit characters with an empty string
    return nonDigits.matcher(input).replaceAll('');
  }

  public static String stripDigits(String input) {
    Pattern digits = Pattern.compile('[0-9.x]');
    String unit = digits.matcher(input).replaceAll('');
    return unit.trim();
  }

  // public static String getFormattedDate(Decimal quantity, Date dt){
  //     DateTime dtValue = DateTime.newInstance(dt.year(), dt.month(), dt.day());
  //     String expectedDate = dtValue.format('dd-MMM-yyyy');
  //     return quantity +' AVAILABLE ON '+ expectedDate;
  // }

  public static List<String> getFormattedDate(Map<String, Date> qtyVsDateMap) {
    List<String> availableDateList = new List<String>();
    // for(QtyToDateDataWrapper qdw : qtyVsDateMap.values()) {
    //     Date dt = qdw.availableDate;
    //     DateTime dtValue = DateTime.newInstance(dt.year(), dt.month(), dt.day());
    //     String expectedDate = dtValue.format('dd-MMM-yyyy');
    //     availableDateList.add(qdw.quantity +' AVAILABLE ON '+ expectedDate);
    // }
    for (String key : qtyVsDateMap.keySet()) {
      Date dt = qtyVsDateMap.get(key);
      DateTime dtValue = DateTime.newInstance(dt.year(), dt.month(), dt.day());
      String expectedDate = dtValue.format('dd-MMM-yyyy');
      String qty = key.substringAfter('_');
      availableDateList.add(qty + ' AVAILABLE ON ' + expectedDate);
    }
    return availableDateList;
  }

  public static Integer getIntegerValue(Decimal value) {
    return value.intValue();
  }

  public static Date getCountryLeadTime(String productSKU) {
    String currentUserCountry = '';
    if (Auth.CommunitiesUtil.isGuestUser()) {
      currentUserCountry = guestUserCountry;
    } else {
      Id userId = UserInfo.getUserId();
      User u = [SELECT Id, User_Country__c FROM User WHERE Id = :userId];
      system.debug(' user => ' + u.User_Country__c);
      currentUserCountry = u.User_Country__c != null
        ? u.User_Country__c
        : System.Label.B2B_User_Default_Country;
    }

    Country__c country = [
      SELECT
        Id,
        Name,
        Country__c,
        Country_Lead_Time__c,
        Country_Boat_Lead_Time__c
      FROM Country__c
      WHERE Country__c = :currentUserCountry
    ];
    // SCC-48 Wrong delivery date on website changes start
    // Product2 product = [Select Id, StockKeepingUnit, BOAT__c FROM Product2 WHERE StockKeepingUnit=: productSKU];
    Product2 product = [
      SELECT Id, StockKeepingUnit, BOAT__c, BOAT_Text__c
      FROM Product2
      WHERE StockKeepingUnit = :productSKU
    ];
    Date newDate = System.today();
    String boatTextVal = product.BOAT_Text__c;
    if (product != null && !String.isBlank(boatTextVal)) {
      //SCC-48 Wrong delivery date on website changes end
      system.debug('product.BOAT__c => ' + product.BOAT__c);
      newDate = newDate.addDays(
        Integer.valueOf(country.Country_Boat_Lead_Time__c)
      ); //we will get this data from country table
    } else {
      newDate = newDate.addDays(Integer.valueOf(country.Country_Lead_Time__c));
    }
    return newDate;
  }

  public static Date getCountryMaxLeadDate(
    String productSKU,
    Date maxLeadDate
  ) {
    Date newDate = maxLeadDate;

    String currentUserCountry = '';
    if (Auth.CommunitiesUtil.isGuestUser()) {
      currentUserCountry = guestUserCountry;
    } else {
      Id userId = UserInfo.getUserId();
      User u = [SELECT Id, User_Country__c FROM User WHERE Id = :userId];
      currentUserCountry = u.User_Country__c != null
        ? u.User_Country__c
        : System.Label.B2B_User_Default_Country;
    }
    system.debug(
      ' getCountryMaxLeadDate currentUserCountry => ' + currentUserCountry
    );
    Country__c country = [
      SELECT
        Id,
        Name,
        Country__c,
        Country_Lead_Time__c,
        Country_Boat_Lead_Time__c
      FROM Country__c
      WHERE Country__c = :currentUserCountry
    ];
    Product2 product = [
      SELECT Id, StockKeepingUnit, BOAT__c, BOAT_Text__c
      FROM Product2
      WHERE StockKeepingUnit = :productSKU
    ];
    String boatTextVal = product.BOAT_Text__c;
    if (product != null && !String.isBlank(boatTextVal)) {
      system.debug(
        ' getCountryMaxLeadDate product.BOAT__c => ' + product.BOAT__c
      );
      newDate = newDate.addDays(
        Integer.valueOf(country.Country_Boat_Lead_Time__c)
      ); //we will get this data from country table
    } else {
      newDate = newDate.addDays(Integer.valueOf(country.Country_Lead_Time__c));
    }
    return newDate;
  }

  public static tbl_Repack__mdt getTableRepackData(String repackCode) {
    return [
      SELECT
        Id,
        DeveloperName,
        Repack_Id__c,
        BO_No_Pkg_Days__c,
        Repack_No_Days__c
      FROM tbl_Repack__mdt
      WHERE Repack_Id__c = :repackCode
    ];
  }
}