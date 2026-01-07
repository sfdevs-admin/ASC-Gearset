/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 28-04-2025
 * @last modified by  : Mradul Maheshwari
 **/
public without sharing class B2B_ExactSearchResultService {
  public Map<String, Object> getExactSearchResult(Map<String, Object> dataMap) {
    Boolean isSuccess = false;
    //system.debug('getExactSearchResult dataMap---- '+dataMap);
    // String searchResultString = (String) dataMap.get('searchResult');
    Map<Object, Object> searchResultMap = (Map<Object, Object>) dataMap.get(
      'searchResult'
    );
    Map<Object, Object> exactSearchResultMap = searchResultMap.clone();
    Map<Object, Object> suggestedSearchResultMap = searchResultMap.clone();
    List<Object> searchCardCollectionList = (List<Object>) searchResultMap.get(
      'cardCollection'
    );
    //system.debug('getExactSearchResult searchCardCollectionList---- '+searchCardCollectionList);
    dataMap.put('searchCardCollectionList', searchCardCollectionList);
    dataMap = formatSearchResult(dataMap);
    List<Object> exactMatchSearchCardCollectionList = (List<Object>) dataMap.get(
      'exactMatchSearchCardCollectionList'
    );
    List<Object> suggestedSearchCardCollectionList = (List<Object>) dataMap.get(
      'suggestedSearchCardCollectionList'
    );
    List<Object> searchCardCollectionListTemp = (List<Object>) dataMap.get(
      'searchCardCollectionList'
    );
    searchResultMap.put('cardCollection', searchCardCollectionListTemp);
    exactSearchResultMap.put(
      'cardCollection',
      exactMatchSearchCardCollectionList
    );
    suggestedSearchResultMap.put(
      'cardCollection',
      suggestedSearchCardCollectionList
    );

    dataMap.put('searchResult', searchResultMap);
    dataMap.put('exactSearchResult', exactSearchResultMap);
    dataMap.put('suggestedSearchResult', suggestedSearchResultMap);
    // isSuccess = true;
    // dataMap.put('isSuccess', isSuccess);
    return dataMap;
  }

  public Map<String, Object> formatSearchResult(Map<String, Object> dataMap) {
    Boolean isSuccess = false;
    List<Object> exactMatchSearchCardCollectionList = new List<Object>();
    Map<Object, Object> exactMatchSearchCardCollectionMap = new Map<Object, Object>();
    List<Object> suggestedSearchCardCollectionList = new List<Object>();
    List<Integer> indexToRemove = new List<Integer>();
    List<Object> searchCardCollectionList = (List<Object>) dataMap.get(
      'searchCardCollectionList'
    );
    List<B2B_Custom_Search_Filter__c> filterFields = [
      SELECT Id, Field__c, Exact_Match__c, Sort_Order__c
      FROM B2B_Custom_Search_Filter__c
      ORDER BY Sort_Order__c ASC
    ];
    if (searchCardCollectionList.size() > 0) {
      system.debug('getExactSearchResult dataMap---- ' + dataMap);
      String searchTermBackUp = (String) dataMap.get('searchTerm');
      String searchTerm = (String) dataMap.get('searchTerm');
      String searchTermWithoutSubscript = (String) dataMap.get(
        'searchTermWithoutSubscript'
      );
      //added to decode the search term.
      searchTerm = EncodingUtil.urlEncode(searchTerm, 'UTF-8');
      searchTerm = EncodingUtil.urlDecode(searchTerm, 'UTF-8');
      for (Object prod : searchCardCollectionList) {
        //system.debug('formatSearchResult prod---- '+prod);
        Map<Object, Object> prodMap = (Map<Object, Object>) prod;
        //system.debug('formatSearchResult prodMap---- '+prodMap);
        Map<Object, Object> prodFieldsMap = (Map<Object, Object>) prodMap.get(
          'fields'
        );
        //system.debug('formatSearchResult prodFieldsMap---- '+prodFieldsMap);
        String productId = (String) prodMap.get('id');
        //system.debug('productId---- '+productId);
        // Boolean isMatch = compareValueWithField( prodFieldsMap, searchTerm );
        if (filterFields.size() > 0) {
          for (B2B_Custom_Search_Filter__c filterField : filterFields) {
            String field = filterField.Field__c;
            if (
              field == 'Formula_Text__c' ||
              field == 'Index_Formula_Text__c'
            ) {
              searchTerm = searchTermWithoutSubscript;
            } else {
              searchTerm = searchTermBackUp;
            }
            system.debug('compareValueWithField searchTerm---- ' + searchTerm);
            Boolean exactMatch = filterField.Exact_Match__c;
            //system.debug('filterField field---- '+field);
            if (prodFieldsMap.containsKey(field)) {
              Map<Object, Object> valueMap = (Map<Object, Object>) prodFieldsMap.get(
                field
              );
              //system.debug('filterField valueMap---- '+valueMap);
              if (valueMap.containsKey('value')) {
                String value = (String) valueMap.get('value');
                // String productId = (String) prodMap.get('id');
                //system.debug('valueMap value---- '+value);
                //system.debug('compareValueWithField searchTerm---- '+searchTerm);
                if (exactMatch) {
                  //exact match logic
                  if (value != null && value.equalsIgnoreCase(searchTerm)) {
                    exactMatchSearchCardCollectionList.add(prod);
                    exactMatchSearchCardCollectionMap.put(productId, prod);
                    // system.debug('exact match found product added---- ');
                    break;
                  }
                } else {
                  //fuzzy match logic
                  if (
                    value != null &&
                    (value.containsIgnoreCase(searchTerm) ||
                    searchTerm.containsIgnoreCase(value))
                  ) {
                    //if( value != null && value.containsIgnoreCase( searchTerm ) ){
                    if (
                      !exactMatchSearchCardCollectionMap.containsKey(productId)
                    ) {
                      //suggestedSearchCardCollectionList.add( prod );
                      exactMatchSearchCardCollectionList.add(prod);
                      exactMatchSearchCardCollectionMap.put(productId, prod);
                      // system.debug('related match found product added---- ');
                      break;
                    } else {
                      //skip it to resolve duplicates.
                    }
                  }
                }
              }
            }
          }
          if (!exactMatchSearchCardCollectionMap.containsKey(productId)) {
            suggestedSearchCardCollectionList.add(prod);
            //system.debug('no exact related match found, product added---- ');
            // exactMatchSearchCardCollectionMap.put( productId , prod );
          } else {
          }
        }
      }
      // system.debug('exactMatchSearchCardCollectionList--- '+exactMatchSearchCardCollectionList);
      // system.debug('suggestedSearchCardCollectionList--- '+suggestedSearchCardCollectionList);
      dataMap.put(
        'exactMatchSearchCardCollectionList',
        exactMatchSearchCardCollectionList
      );
      dataMap.put(
        'suggestedSearchCardCollectionList',
        suggestedSearchCardCollectionList
      );
      dataMap.put('searchCardCollectionList', searchCardCollectionList);
      isSuccess = true;
    } else {
      dataMap.put('message', 'records not found');
    }
    dataMap.put('isSuccess', isSuccess);
    return dataMap;
  }

  /*
    public Map<String,Object> formatSearchResult( Map<String,Object> dataMap) {
        Boolean isSuccess = false;
        List<Object> exactMatchSearchCardCollectionList = new List<Object>();
        Map<String,Object> exactMatchSearchCardCollectionMap = new Map<String,Object>();
        List<Object> suggestedSearchCardCollectionList = new List<Object>();
        List<Integer> indexToRemove = new List<Integer>();
        List<Object> searchCardCollectionList = (List<Object>)  dataMap.get('searchCardCollectionList');
        List<B2B_Custom_Search_Filter__c> filterFields = [SELECT Id, Field__c, Exact_Match__c, Sort_Order__c FROM B2B_Custom_Search_Filter__c ORDER BY Sort_Order__c ASC];
        if( searchCardCollectionList.size() > 0 ){
            String searchTerm = (String) dataMap.get('searchTerm');
            for(Object prod : searchCardCollectionList) {
                //system.debug('formatSearchResult prod---- '+prod);
                Map<String,Object> prodMap = (Map<String,Object>) prod;
                //system.debug('formatSearchResult prodMap---- '+prodMap);
                Map<String,Object> prodFieldsMap = (Map<String,Object>) prodMap.get('fields');
                //system.debug('formatSearchResult prodFieldsMap---- '+prodFieldsMap);
                // Boolean isMatch = compareValueWithField( prodFieldsMap, searchTerm );
                if( filterFields.size() > 0 ){
                    for( B2B_Custom_Search_Filter__c filterField : filterFields ){
                        String field = filterField.Field__c;
                        Boolean exactMatch = filterField.Exact_Match__c;
                        //system.debug('filterField field---- '+field);
                        if( prodFieldsMap.containsKey( field ) ){
                            Map<String,Object> valueMap = (Map<String,Object>) prodFieldsMap.get(field);
                            //system.debug('filterField valueMap---- '+valueMap);
                            if( valueMap.containsKey( 'value' ) ){
                                String value = (String) valueMap.get( 'value' );
                                String productId = (String) prodMap.get('id');
                                //system.debug('valueMap value---- '+value);
                                //system.debug('compareValueWithField searchTerm---- '+searchTerm);
                                if( exactMatch ){
                                    //exact match logic
                                    if( value != null && value.equalsIgnoreCase( searchTerm ) ){
                                        exactMatchSearchCardCollectionList.add( prod );
                                        exactMatchSearchCardCollectionMap.put( productId , prod );
                                    }
                                }else{
                                    //fuzzy match logic
                                    if( value != null && value.containsIgnoreCase( searchTerm ) ){
                                        if( ! exactMatchSearchCardCollectionMap.containsKey( productId ) ){
                                            suggestedSearchCardCollectionList.add( prod );
                                        }else{
                                            //skip it to resolve duplicates.
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                // if( isMatch ){
                //     exactMatchSearchCardCollectionList.add( prod );
                // }else{
                //     suggestedSearchCardCollectionList.add( prod );
                // }
            }
            dataMap.put('exactMatchSearchCardCollectionList', exactMatchSearchCardCollectionList);
            dataMap.put('suggestedSearchCardCollectionList', suggestedSearchCardCollectionList);
            dataMap.put('searchCardCollectionList', searchCardCollectionList);
            isSuccess = true;
        }else{
            dataMap.put('message', 'records not found');
        }
        dataMap.put('isSuccess', isSuccess);
        return dataMap;
    }
    */

  // public Boolean compareValueWithField( Map<String,Object> prodFieldsMap, String searchTerm ){
  //     Boolean isMatch = false;
  //     List<B2B_Custom_Search_Filter__c> filterFields = [SELECT Id, Field__c, Exact_Match__c, Sort_Order__c FROM B2B_Custom_Search_Filter__c ORDER BY Sort_Order__c ASC];
  //     if( filterFields.size() > 0 ){
  //         for( B2B_Custom_Search_Filter__c filterField : filterFields ){
  //             String field = filterField.Field__c;
  //             Boolean exactMatch = filterField.Exact_Match__c;
  //             //system.debug('filterField field---- '+field);
  //             if( prodFieldsMap.containsKey( field ) ){
  //                 Map<String,Object> valueMap = (Map<String,Object>) prodFieldsMap.get(field);
  //                 //system.debug('filterField valueMap---- '+valueMap);
  //                 if( valueMap.containsKey( 'value' ) ){
  //                     String value = (String) valueMap.get( 'value' );
  //                     //system.debug('valueMap value---- '+value);
  //                     //system.debug('compareValueWithField searchTerm---- '+searchTerm);
  //                     if( value != null && value.equalsIgnoreCase( searchTerm ) ){
  //                         isMatch = true;
  //                     }
  //                 }
  //             }
  //         }
  //     }
  //     return isMatch;
  // }

  // public Map<String,Object> getProducts( Map<String,Object> dataMap) {
  //     Boolean isSuccess = false;
  //     String message = '';
  //     //system.debug('getExactSearchResult dataMap---- '+dataMap);
  //     if(
  //         dataMap != null &&
  //         dataMap.containsKey('effectiveAccountId') && dataMap.get('effectiveAccountId') != null &&
  //         dataMap.containsKey('webstoreId') && dataMap.get('webstoreId') != null &&
  //         dataMap.containsKey('page') && dataMap.get('page') != null &&
  //         dataMap.containsKey('pageSize') && dataMap.get('pageSize') != null &&
  //         (dataMap.containsKey('term') || dataMap.containsKey('recordId'))
  //     ){
  //         Id effectiveAccountId = (Id)dataMap.get('effectiveAccountId');
  //         Id webstoreId = (Id)dataMap.get('webstoreId');
  //         String categoryId = (String)dataMap.get('recordId');
  //         String searchTerm = (String)dataMap.get('term');
  //         Integer page = Integer.valueOf(dataMap.get('page'));
  //         Integer pageSize = Integer.valueOf(dataMap.get('pageSize'));
  //         String sortRuleId = (String)dataMap.get('sortRuleId');

  //         ConnectApi.ProductSearchInput productSearchInput = new ConnectApi.ProductSearchInput();
  //         productSearchInput.searchTerm = searchTerm;
  //         // productSearchInput.includePrices = productSearchRequest.includePrices ;
  //         // productSearchInput.includeQuantityRule = true ;
  //         // productSearchInput.page = productSearchRequest.page;
  //         // productSearchInput.pageSize = productSearchRequest.pageSize ;
  //         // productSearchInput.sortRuleId = productSearchRequest.sortRuleId ;
  //         List<String> defaultFields = new List<String>{'Name', 'StockKeepingUnit', 'ProductCode', 'ProductClass', 'Type', 'CAS__c'};
  //         productSearchInput.fields = new List<String>(defaultFields);
  //         List<ConnectApi.RefinementInput> refinements = new List<ConnectApi.RefinementInput>();
  //         // todo: handle default refinements
  //         productSearchInput.refinements = refinements;
  //         ConnectApi.ProductSearchResults connectProductSearch = ConnectApi.CommerceSearch.searchProducts( webStoreId , effectiveAccountId, productSearchInput);
  //         //system.debug('connectProductSearchAPI-- ' + JSON.serialize(connectProductSearch) );
  //         if( connectProductSearch != null ){
  //             dataMap.put('searchResults', connectProductSearch);
  //             transformSearchResult(dataMap);
  //             isSuccess = true;
  //         }
  //     }
  //     else{
  //         message = 'dataMap missing attributes.';
  //     }
  //     dataMap.put('isSuccess', isSuccess);
  //     dataMap.put('message', message);
  //     return dataMap;
  // }

  // public Map<String,Object> transformSearchResult(Map<String,Object> dataMap){
  //     //system.debug('transformSearchResult dataMap---- '+dataMap);
  //     ConnectApi.ProductSearchResults connectProductSearch = (ConnectApi.ProductSearchResults) dataMap.get('connectProductSearch');
  //     //system.debug('transformSearchResult connectProductSearch-- ' + JSON.serialize(connectProductSearch) );
  //     ConnectApi.ProductSummaryPage productSummaryPage = connectProductSearch.productsPage;
  //     //system.debug('transformSearchResult productSummaryPage-- ' + JSON.serialize(productSummaryPage) );
  //     Integer originalTotalProducts = (Integer)productSummaryPage.total;
  //     if( originalTotalProducts > 0){
  //         List<ConnectApi.ProductSummary> productSummaryList = productSummaryPage.products;
  //         //system.debug('transformSearchResult productSummaryList-- ' + JSON.serialize(productSummaryList) );
  //         for( ConnectApi.ProductSummary prod : productSummaryList ) {
  //             Map<String, ConnectApi.FieldValue> prodFieldMap = prod.fields;
  //             //system.debug('transformSearchResult prodFieldMap-- ' + JSON.serialize(prodFieldMap) );
  //             //add comparision logic.
  //         }
  //     }
  //     return dataMap;
  // }
}