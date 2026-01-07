/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 16-06-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { LightningElement, api, wire } from "lwc";
import {
  navigate,
  NavigationContext,
  CurrentPageReference,
  NavigationMixin
} from "lightning/navigation";
import {
  createCartItemAddAction,
  createSearchFiltersUpdateAction,
  dispatchAction
} from "commerce/actionApi";
import { AppContextAdapter, getSessionContext } from "commerce/contextApi";
import {
  computeConfiguration,
  transformDataWithConfiguration
} from "./builderSearchResultsCustomUtils";
import CommonModal from "c/commonModal";
import { Labels } from "./labels";
import B2B_ParentCategoryId from "@salesforce/label/c.B2B_ParentCategoryId";
import B2B_Guest_Buyer_Profile_Id from "@salesforce/label/c.B2B_Guest_Buyer_Profile_Id";
import B2B_Site_Base_URL from "@salesforce/label/c.B2B_Site_Base_URL";
import maxLoadingDuration from "@salesforce/label/c.maxLoadingTime";
import B2B_Searchable_Fields from "@salesforce/label/c.B2B_Searchable_Fields";
import isGuestUser from "@salesforce/user/isGuest";
// import getProducts from '@salesforce/apex/B2B_ExactSearchResultController.getProducts';

export default class BuilderSearchResultsCustom extends NavigationMixin(
  LightningElement
) {
  static categoryIdDev = B2B_ParentCategoryId;
  static renderMode = "light";
  definedLayout = "";
  showSpinner = true;
  messageState = "Please Wait";
  pageNumber = 0;
  pageSize = 200; //max size. //60;
  refinements;
  productSearchResults;
  isMerged = false;
  @wire(NavigationContext)
  navContext;

  combinedSearchResults;
  fullSearchResult;
  finalSearchResults = false;

  fullSearchResultFromAPI;
  finalSearchResultsFromAPI = false;

  pageNumAPI = 0;

  mainStopFlag = true;
  allowRecalculation = false;
  stopMultiNavigation = false;
  isCategoryPresent = false;
  isFinalLoadComplete = false;
  doNothing = false;

  // Array of strings
  waitingScreenMsgArray = [
    "Please Wait",
    "We are fetching your products",
    "Your patience is appreciated"
  ];
  // Current string to display
  currentWaitingMsg = "";
  // Variable to keep track of the current index
  currentIndex = 0;

  // To direct to periodic table after certain time passed
  firstSearchSetTime = undefined;

  resetAllVars() {
    // this.showSpinner = true; //adding for showing spinner
    // this.mainStopFlag = false;
    // this.finalSearchResults = false;
    // this.fullSearchResult = undefined;
    // this.fullSearchResultFromAPI = undefined;
    // this.pageNumAPI = 0;
    // this.isMerged = false;
    // this.allowRecalculation = true;
    this.doNothing = false;
    this.isFinalLoadComplete = true;
  }

  handleFilterSortUpdateEvent(event) {
    const currentTime = Date.now();

    this.firstSearchSetTime = currentTime;
  }
  clearAll = false;
  handleClearAllFiltersEvent(event) {
    const currentTime = Date.now();

    this.firstSearchSetTime = currentTime;

    this.clearAll = true;
  }
  @api
  get searchResults() {
    return this._searchResults;
  }
  set searchResults(value) {
    if (value) {
      console.log(
        "BuilderSearchResultsCustom set searchResults--- ",
        JSON.parse(JSON.stringify(value))
      );
      const currentTime = Date.now();

      if (!this.firstSearchSetTime) {
        this.firstSearchSetTime = currentTime;
      }

      if (
        this.firstSearchSetTime &&
        currentTime - this.firstSearchSetTime >= maxLoadingDuration
      ) {
        this.navigateToPeriodicTable();
      }

      let clientStateVar = value.ClientState;
      if (clientStateVar) {
        // if( clientStateVar.loading ){
        //     // it is still loading
        //     if( this.allowRecalculation ){
        //         this.allowRecalculation = false;
        //     }
        // }else{
        //     // loading complete
        //     if( ! this.allowRecalculation ){
        //         this.allowRecalculation = true;
        //     }
        // }
      }
      value = value.Results;
      if (
        value &&
        !this.fullSearchResult &&
        value.total == 0 &&
        (!value.cardCollection || value.cardCollection?.length === 0)
      ) {
        //no results found navigate to periodic table
        this.navigateToPeriodicTable();
      }

      if (value && this.allowRecalculation && !this.doNothing) {
        this.showSpinner = true; //adding for showing spinner
        this.mainStopFlag = false;
        this.finalSearchResults = false;
        this.fullSearchResult = undefined;
        this.fullSearchResultFromAPI = undefined;
        this.allowRecalculation = false;
        this.pageNumAPI = 0;
        this.isMerged = false;
      }
      //do this after isLoading is false
      let tempBool = false;
      if (
        (this.fullSearchResult?.cardCollection == undefined ||
          this.fullSearchResult?.cardCollection?.length == 100 ||
          this.fullSearchResult?.cardCollection?.length < value.total) &&
        value.productLoadedCount == 100
      ) {
        tempBool = true;
      } else {
        tempBool = false;
      }

      if (
        this.fullSearchResult?.cardCollection &&
        value.productLoadedCount == value.total &&
        !this.doNothing
      ) {
        this.finalSearchResults = false;
        this.fullSearchResult = undefined;
        this.fullSearchResultFromAPI = undefined;
      }

      if (
        (value.productLoadedCount &&
          // && ( value.productLoadedCount == value.total || value.productLoadedCount == 100 || value.productLoadedCount == ( value.total - this.fullSearchResult?.cardCollection?.length ) )
          (value.productLoadedCount == value.total ||
            tempBool ||
            value.productLoadedCount ==
              value.total - this.fullSearchResult?.cardCollection?.length)) ||
        value.total - this.fullSearchResult?.cardCollection?.length == 0
      ) {
        // if( ! clientStateVar.loading && value && ! this.mainStopFlag && ! this.stopMultiNavigation && ! this.doNothing ){

        if (
          !clientStateVar.loading &&
          value &&
          !this.stopMultiNavigation &&
          !this.doNothing
        ) {
          //fix for SCC-83 search is stuck/in limbo start

          let allowExecution = window?.location?.search?.includes("category");

          if (!allowExecution) {
            //if url doesnot contains 'category' do nothing and return;
            return;
          }

          //fix for SCC-83 search is stuck/in limbo ends
          this._searchResults = JSON.parse(JSON.stringify(value));

          if (!this.finalSearchResults) {
            if (!this.fullSearchResult) {
              this.fullSearchResult = this._searchResults;
            } else {
              let mergedArray = this.fullSearchResult.cardCollection.concat(
                this.searchResults.cardCollection.filter(
                  (item2) =>
                    !this.fullSearchResult.cardCollection.some(
                      (item1) => item1.id === item2.id
                    )
                )
              );
              this.fullSearchResult.cardCollection = mergedArray;

              this.finalSearchResults = this.hasTotalResult;
            }
          }

          if (
            this.fullSearchResult.cardCollection.length <
              this.fullSearchResult.total &&
            this._searchResults.cardCollection.length > 0
          ) {
            this.handleNextPage();
            return;
          }

          if (value && this.hasTotalResult) {
            //if ( value && this.finalSearchResults ) {
            this.triggerProductSearch();
          }
        }
      } else if (value && this.isFinalLoadComplete) {
        let tempThis = this;
        // setTimeout(() =>{
        tempThis.allowRecalculation = true;
        // },1500)
      }
    }
  }

  @api
  sortRuleId;

  @api
  sortRules;

  _recordId;
  @api
  get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    if (value) {
      this._recordId = value == "" ? "" + B2B_ParentCategoryId : value;
      if (this._recordId != B2B_ParentCategoryId) {
        //navigate to category page
        // this.triggerProductSearch();
      }
    }
  }

  _term;
  @api
  get term() {
    return this._term;
  }
  set term(value) {
    if (value) {
      this._term = value;
      if (value) {
        // this.triggerProductSearch();
      }
    }
  }

  @api
  searchResultsFields;

  @api
  resultsLayout;

  @api
  gridColumnSpacing;

  @api
  gridRowSpacing;

  @api
  gridMaxColumnsDisplayed;

  @api
  listRowSpacing;

  @api
  cardBackgroundColor;

  @api
  cardAlignment;

  @api
  cardBorderColor;

  @api
  cardBorderRadius;

  @api
  cardDividerColor;

  @api
  negotiatedPriceTextSize;

  @api
  showNegotiatedPrice = false;

  @api
  negotiatedPriceTextColor;

  @api
  showOriginalPrice = false;

  @api
  originalPriceTextSize;

  @api
  originalPriceTextColor;

  @api
  showProductImage = false;

  @api
  cardContentMapping;

  @api
  showCallToActionButton = false;

  @api
  addToCartButtonText;

  @api
  addToCartButtonStyle;

  @api
  addToCartButtonProcessingText;

  @api
  viewOptionsButtonText;

  @api
  get currentPage() {
    return this._currentPage;
  }
  set currentPage(newCurrentPage) {
    console.log(
      "BuilderSearchResultsCustom set currentPage--- ",
      newCurrentPage
    );

    if (newCurrentPage) {
      if (newCurrentPage == 1) {
        let tempThis = this;
        setTimeout(() => {
          tempThis.doNothing = false;
        }, 1500);
      }
      const newPageAsNumber = parseInt(newCurrentPage, 10);
      if (!Number.isNaN(newPageAsNumber)) {
        this._currentPage = newPageAsNumber;
        // this.triggerProductSearch();
      }
    } else {
      // console.log('BuilderSearchResultsCustom set currentPage--- ', JSON.parse( JSON.stringify( newCurrentPage ) ) );
    }
  }

  @wire(AppContextAdapter)
  hanldeAppContextAdapterResponse(result) {
    if (result.data) {
      this.webstoreId = result.data.webstoreId;
      this.getEffectiveAccountId();
    }
  }

  async getEffectiveAccountId() {
    const result = await getSessionContext();

    if (!result.isLoggedIn) {
      this.effectiveAccountId = B2B_Guest_Buyer_Profile_Id; //guestBuyerProfileId
      // this.triggerProductSearch();
    } else if (result && result.effectiveAccountId) {
      this.effectiveAccountId = result.effectiveAccountId;
      // this.triggerProductSearch();
    }
  }

  get normalizedCardContentMapping() {
    return JSON.parse(this.cardContentMapping ?? "[]");
  }

  get comboOptions() {
    return [
      { label: "Grid", value: "grid" },
      { label: "List", value: "list" }
    ];
  }

  get cardConfiguration() {
    return {
      showProductImage: this.showProductImage,
      showNegotiatedPrice: this.showNegotiatedPrice,
      showOriginalPrice: this.showOriginalPrice,
      showCallToActionButton: this.showCallToActionButton,
      addToCartButtonText: this.addToCartButtonText,
      addToCartButtonProcessingText: this.addToCartButtonProcessingText,
      viewOptionsButtonText: this.viewOptionsButtonText,
      cardContentMapping: this._cardContentMapping
    };
  }

  get hasTotalResult() {
    if (
      this.fullSearchResult &&
      this.fullSearchResult.cardCollection.length == this.fullSearchResult.total
    ) {
      return true;
    }
    return false;
  }

  get hasTotalResultFromAPI() {
    if (
      this.fullSearchResultFromAPI &&
      this.fullSearchResultFromAPI.productsPage.products.length ==
        this.fullSearchResultFromAPI.productsPage.total
    ) {
      return true;
    }
    return false;
  }

  get displayProducts() {
    if (this.isResultAvailable) {
      this.showSpinner = false;
      this.stopMultiNavigation = false;
      this.allowRecalculation = true;
      return true;
    }
    return false;
  }

  get isResultAvailable() {
    //if searchResult returned 0 results
    if (!this.isMerged && this.fullSearchResult?.cardCollection?.length == 0) {
      return true;
    }
    //if searchResult exist
    if (
      this.fullSearchResult &&
      this.fullSearchResult != null &&
      this.fullSearchResultFromAPI &&
      this.isMerged
    ) {
      return true;
    }
    return false;
  }

  triggerProductSearch() {
    console.log("triggerProductSearch");
    if (
      this.webstoreId &&
      this.effectiveAccountId &&
      this.term &&
      this.fullSearchResult &&
      this.hasTotalResult
    ) {
      //if( this.webstoreId && this.effectiveAccountId && this.term && this.fullSearchResult && this.finalSearchResults ){
      // this.isMerged = false;
      this.fetchProducts();
    }
  }

  fetchProducts() {
    console.log("fetchProducts");
    let mapParams = {
      webstoreId: this.webstoreId,
      effectiveAccountId: this.effectiveAccountId,
      recordId: this.recordId,
      term: this.term,
      page: this.pageNumAPI,
      pageSize: this.pageSize, //21,//this.plpConfig?.pageSize,
      sortRuleId: this.sortRuleId,
      refinements: this.refinements
    };

    let url = "" + B2B_Site_Base_URL + "" + this.webstoreId;
    let encodedSearchTerm = encodeURI(this.term);

    // url = url + "/search/products?searchTerm=" + this.term;
    url = url + "/search/products?searchTerm=" + encodedSearchTerm;
    if (this.recordId) {
      url = url + "&categoryId=" + this.recordId;
    } else {
      url = url + "&categoryId=" + B2B_ParentCategoryId;
    }

    if (this.pageNumAPI && this.pageNumAPI >= 1) {
      url = url + "&page=" + (Number(this.pageNumAPI) - 1);
    } else {
      url = url + "&page=0";
    }
    url = url + "&pageSize=200";
    url = url + "&language=en-US";
    url = url + "&asGuest=" + isGuestUser;
    url = url + "&htmlEncode=false";
    url = url + "&fields=" + B2B_Searchable_Fields;

    if (this.refinements && this.refinements != null) {
      url = url + "&refinements=" + this.refinements;
    }

    this.fetchProductApi(url);
  }

  async fetchProductApi(url) {
    console.log("fetchProductApi --- " + url);
    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`Response status: ${response}`);
      }
      const jsonResp = await response.json();
      this.productSearchResults = JSON.parse(JSON.stringify(jsonResp)); //JSON.stringify(jsonResp);

      if (!this.fullSearchResultFromAPI) {
        this.fullSearchResultFromAPI = this.productSearchResults;
      } else {
        let mergedArray =
          this.fullSearchResultFromAPI.productsPage.products.concat(
            this.productSearchResults.productsPage.products.filter(
              (item2) =>
                !this.fullSearchResultFromAPI.productsPage.products.some(
                  (item1) => item1.id === item2.id
                )
            )
          );

        this.fullSearchResultFromAPI.productsPage.products = mergedArray;

        this.finalSearchResultsFromAPI = this.hasTotalResultFromAPI;
      }
      if (
        this.fullSearchResultFromAPI.productsPage.products.length <
        this.fullSearchResultFromAPI.productsPage.total
      ) {
        this.handleNextPageAPI();
        return;
      } else if (
        this.fullSearchResultFromAPI.productsPage.products.length ==
        this.fullSearchResultFromAPI.productsPage.total
      ) {
        this.finalSearchResultsFromAPI = this.hasTotalResultFromAPI;
      }

      if (this.finalSearchResultsFromAPI) {
        this.mergeSearchResults();
      }
    } catch (error) {
      console.error(
        "BuilderSearchResultsCustom fetchProductApi--- " + error.message
      );
      this.showSpinner = false;
    }
  }

  mergeSearchResults() {
    // fullSearchResultFromAPI  fullSearchResult
    if (this.fullSearchResultFromAPI && this.fullSearchResult) {
      if (this.fullSearchResult.cardCollection.length > 0) {
        this.fullSearchResult.cardCollection.forEach((card) => {
          if (this.fullSearchResultFromAPI.productsPage?.products?.length > 0) {
            this.fullSearchResultFromAPI.productsPage?.products?.forEach(
              (ele) => {
                if (card.id === ele.id) {
                  card.fields = ele.fields;
                  return;
                }
              }
            );
            this.isMerged = true;
          }
        });
      }
      let retValTemp = this.displayProducts;

      this.handleGoToFirstPage();
    }
  }

  handleNextPageAPI() {
    this.pageNumAPI = this.pageNumAPI + 1;
    this.fetchProducts();
  }

  handleComboOptionsChange(event) {
    this.resultsLayout = event.detail.value;
    this.updateSessionStorage();
    window.location.reload();
  }

  getDefinedLayoutFromSession() {
    let savedOrDefault = sessionStorage.getItem("definedLayout") || "list";

    return savedOrDefault;
  }

  connectedCallback() {
    // Start updating the string every 2 seconds
    this.startUpdatingWaitingScreenStrings();

    this.resultsLayout = this.getDefinedLayoutFromSession();
    this.updateSessionStorage();
  }

  // Method to update the current string every 2 seconds
  startUpdatingWaitingScreenStrings() {
    this.updateString(); // Initial call to set the first value
    if (this.showSpinner) {
      setInterval((id) => {
        if (this.showSpinner) {
          this.updateString();
        } else {
          clearInterval(id);
        }
      }, 2000); // 1000 ms = 1 seconds
    }
  }

  // Method to update the current string based on the index
  updateString() {
    // Update the current string to the string at the current index
    this.currentWaitingMsg = this.waitingScreenMsgArray[this.currentIndex];
    // Increment the index, and reset it to 0 if it exceeds the array length
    if (this.currentIndex < this.waitingScreenMsgArray.length) {
      this.messageState = this.waitingScreenMsgArray[this.currentIndex];
      this.currentIndex++;
    } else if (this.currentIndex == this.waitingScreenMsgArray.length) {
      this.messageState = this.waitingScreenMsgArray[this.currentIndex];
      this.currentIndex = 0;
    }
    // this.currentIndex = (this.currentIndex + 1) % this.waitingScreenMsgArray.length;
  }

  updateSessionStorage() {
    this.definedLayout = this.resultsLayout;
    sessionStorage.setItem("definedLayout", this.definedLayout);
  }

  handleAddToCart(event) {
    event.stopPropagation();
    const { productId, quantity } = event.detail;
    dispatchAction(this, createCartItemAddAction(productId, quantity), {
      onSuccess: () => {
        CommonModal.open({
          label: Labels.messageSuccessfullyAddedToCart,
          size: "small",
          secondaryActionLabel: Labels.actionContinueShopping,
          primaryActionLabel: Labels.actionViewCart,
          onprimaryactionclick: () => this.navigateToCart()
        });
      }
    });
  }

  navigateToCart() {
    this.navContext &&
      navigate(this.navContext, {
        type: "comm__namedPage",
        attributes: {
          name: "Current_Cart"
        }
      });
  }

  navigateToPeriodicTable() {
    this.navContext &&
      navigate(this.navContext, {
        type: "comm__namedPage",
        attributes: {
          name: "Periodic_Table__c"
        },
        state: {
          term: this.term
        }
      });
  }

  handleNavigateToProductPage(event) {
    event.stopPropagation();
    const urlName = this.searchResults?.cardCollection.find(
      (card) => card.id === event.detail.productId
    )?.urlName;
    // this.navContext &&
    //     navigate(this.navContext, {
    //         type: 'standard__recordPage',
    //         attributes: {
    //             objectApiName: 'Product2',
    //             recordId: event.detail.productId,
    //             actionName: 'view',
    //             urlName: urlName ?? undefined,
    //         },
    //         state: {
    //             recordName: event.detail.productName,
    //         },
    //     });

    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "Product2",
        recordId: event.detail.productId,
        actionName: "view",
        urlName: urlName ?? undefined
      },
      state: {
        recordName: event.detail.productName
      }
    }).then((url) => {
      console.log("main handleNavigateToProductPage------ " + url);
      window.open(url, "_blank");
    });
  }

  // navigateToPeriodicTable() {
  //     this[NavigationMixin.GenerateUrl]({
  //         type: "comm__namedPage",
  //         attributes: {
  //             name: 'Periodic_Table__c',
  //         },
  //         state: {
  //             term: this.term
  //         },
  //     }).then(url => {
  //         console.log('main navigateToPeriodicTable------ '+url);
  //         window.open(url, "_self");
  //     }).catch(error => {
  //             console.log('main navigateToPeriodicTable error------ '+error);
  //     });
  // }

  handleUpdateCurrentPage(event) {
    event.stopPropagation();
    dispatchAction(
      this,
      createSearchFiltersUpdateAction({ page: event.detail.newPageNumber })
    );
  }

  handleNextPage() {
    let currentPageNum = this.currentPage;
    let nextPageNum = currentPageNum + 1;

    dispatchAction(
      this,
      createSearchFiltersUpdateAction({ page: nextPageNum, pageSize: 200 })
    );
  }

  async handleGoToFirstPage() {
    let nextPageNum = 0;
    this.doNothing = true;
    await dispatchAction(
      this,
      createSearchFiltersUpdateAction({ page: nextPageNum })
    );
  }

  flagCheck = false;
  searchTearm = null;
  currentPageRef;
  periodicTable;
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      if (this.currentPageRef != currentPageReference?.state?.page) {
        this.flagCheck = false;
      }
      this.currentPageRef = currentPageReference?.state?.page;
      if (this.searchTearm != currentPageReference?.state?.term) {
        this.flagCheck = false;
      }
      if (
        currentPageReference?.type == "standard__search" &&
        (currentPageReference?.state?.category == undefined ||
          currentPageReference?.state?.category == null)
      ) {
        this.flagCheck = false;
      }
      this.searchTearm = currentPageReference?.state?.term
        ? currentPageReference.state.term
        : null;

      let tempRefinementVar = currentPageReference?.state?.refinements
        ? currentPageReference?.state?.refinements
        : null;
      if (tempRefinementVar && tempRefinementVar != null) {
        //decode to get the Map<string,String> format
        tempRefinementVar = decodeURIComponent(tempRefinementVar);
        //Convert Map<string,String> to base64 format
        this.refinements = btoa(tempRefinementVar);
      } else if (tempRefinementVar == null) {
        this.refinements = null;
      }

      let isPeriodicTable = currentPageReference?.state?.periodicTable
        ? currentPageReference?.state?.periodicTable
        : null;
      if (
        (isPeriodicTable === "true" || this.periodicTable === "true") &&
        currentPageReference.type != "standard__recordPage" &&
        currentPageReference?.attributes?.objectApiName == "ProductCategory"
      ) {
        this.periodicTable =
          this.periodicTable != undefined
            ? this.periodicTable
            : isPeriodicTable;
        this.flagCheck = true;
        currentPageReference.state.periodicTable = undefined;
        return;
      } else if (
        currentPageReference &&
        currentPageReference?.type == "standard__search" &&
        !this.flagCheck
      ) {
        let catId = B2B_ParentCategoryId;

        const url = new URL(window.location.href);
        const searchParams = url.searchParams;
        if (!searchParams.has("category")) {
          // Remove 'facets' if it exists
          if (this.clearAll) {
            searchParams.delete("facets");
          }

          // Add or update 'category' and 'page'

          searchParams.set("category", catId);
          if (!searchParams.has("page")) {
            searchParams.set("page", "0");
          }

          // Update the URL
          url.search = searchParams.toString();
          window.location.href = url.toString();
        }
      }
      this.flagCheck = true;
    }
  }

  handleIsLoadedEvent(event) {
    event.stopPropagation();
    console.log(
      "BuilderSearchResultsCustom handleIsLoadedEvent called/complete--- ",
      event.detail
    );
    // this.allowRecalculation = true;
    this.resetAllVars();
  }
}