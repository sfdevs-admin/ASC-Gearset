/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 06-05-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { api, LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import {
  generateStyleProperties,
  generateThemeTextSizeProperty
} from "experience/styling";
import {
  computeConfiguration,
  transformDataWithConfiguration
} from "./searchResultsCustomUtils";
import { EVENT, DEFAULTS } from "./constants";
import getExactSearchResult from "@salesforce/apex/B2B_ExactSearchResultController.getExactSearchResult";
import B2B_No_Exact_Match from "@salesforce/label/c.B2B_No_Exact_Match";
import B2B_Search_recommended_title from "@salesforce/label/c.B2B_Search_recommended_title";
import Toast from "lightning/toast";

function dxpTextSize(textSize) {
  const themeSize = generateThemeTextSizeProperty(`heading-${textSize}`);
  return themeSize ? `var(${themeSize}-font-size)` : "initial";
}

export default class SearchResultsCustom extends NavigationMixin(
  LightningElement
) {
  static renderMode = "light";
  _currentPage = "1";
  _currentPageNumber = 1;
  _searchResults;
  _productSearchResults;
  showSpinner = true;
  messageState = "Please Wait";
  customPageSize = 25;

  Label = {
    B2B_No_Exact_Match: B2B_No_Exact_Match,
    B2B_Search_recommended_title: B2B_Search_recommended_title
  };

  @track exactSearchResult;
  @track exactSearchResultToDisplay;
  @track suggestionSearchResult;
  @track suggestionSearchResultToDisplay;

  @api
  get searchResults() {
    return this._searchResults;
  }
  set searchResults(value) {
    if (value) {
      console.log("SearchResultsCustom set searchResults---- " + value);
      this._searchResults = value;
      if (value) {
        this.triggerSortingFunction();
      }
    }
  }

  @api
  get productSearchResults() {
    return this._productSearchResults;
  }

  set productSearchResults(value) {
    if (value) {
      console.log("SearchResultsCustom set productSearchResults---- " + value);
      this._productSearchResults = value;
      if (value) {
        // this.triggerProductSearch();
      }
    }
  }
  @api
  sortRuleId;
  @api
  sortRules;
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
  showProductImage = false;
  @api
  showNegotiatedPrice = false;
  @api
  negotiatedPriceTextSize;
  @api
  negotiatedPriceTextColor;
  @api
  showOriginalPrice = false;
  @api
  originalPriceTextSize;
  @api
  originalPriceTextColor;
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
  cardContentMapping;
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
  set currentPage(newCurrentPage) {
    this._currentPage = newCurrentPage;
    const newPageAsNumber = parseInt(newCurrentPage, 10);
    if (!Number.isNaN(newPageAsNumber)) {
      this._currentPageNumber = newPageAsNumber;
    }
  }
  get currentPage() {
    return this._currentPage;
  }

  get _gridColumnSpacing() {
    return this.gridColumnSpacing ?? DEFAULTS.gridColumnSpacing;
  }

  get _gridRowSpacing() {
    return this.gridRowSpacing ?? DEFAULTS.gridRowSpacing;
  }

  get _gridMaxColumnsDisplayed() {
    return this.gridMaxColumnsDisplayed ?? DEFAULTS.gridMaxColumnsDisplayed;
  }

  get _listRowSpacing() {
    return this.listRowSpacing ?? DEFAULTS.listRowSpacing;
  }

  get _negotiatedPriceTextSize() {
    return this.negotiatedPriceTextSize ?? DEFAULTS.negotiatedPriceTextSize;
  }

  get _negotiatedPriceTextColor() {
    return this.negotiatedPriceTextColor ?? DEFAULTS.negotiatedPriceTextColor;
  }

  get _originalPriceTextSize() {
    return this.originalPriceTextSize ?? DEFAULTS.originalPriceTextSize;
  }

  get _originalPriceTextColor() {
    return this.originalPriceTextColor ?? DEFAULTS.originalPriceTextColor;
  }

  get _cardContentMapping() {
    return Array.isArray(this.cardContentMapping)
      ? this.cardContentMapping
      : [];
  }

  get _cardBackgroundColor() {
    return this.cardBackgroundColor ?? DEFAULTS.cardBackgroundColor;
  }

  get _cardAlignment() {
    return this.cardAlignment ?? DEFAULTS.cardAlignment;
  }

  get _cardBorderColor() {
    return this.cardBorderColor ?? DEFAULTS.cardBorderColor;
  }

  get _cardBorderRadius() {
    return this.cardBorderRadius ?? DEFAULTS.cardBorderRadius;
  }
  get _cardDividerColor() {
    return this.cardDividerColor ?? DEFAULTS.cardDividerColor;
  }

  get normalizedSearchResults() {
    console.log(
      "SEARCH RESULTS suggestionSearchResult \n",
      JSON.parse(JSON.stringify(this.suggestionSearchResultToDisplay))
    );
    return transformDataWithConfiguration(
      this.suggestionSearchResultToDisplay,
      this.cardConfiguration
    );
  }

  get normalizedExactSearchResults() {
    console.log(
      "normalizedExactSearchResults exactSearchResult SEARCH RESULTS \n",
      JSON.parse(JSON.stringify(this.exactSearchResultToDisplay))
    );
    return transformDataWithConfiguration(
      this.exactSearchResultToDisplay,
      this.cardConfiguration
    );
  }

  get dynamicDivHeight() {
    let val;
    if (this.exactSearchResultToDisplay?.cardCollection?.length > 9) {
      val = 100;
    } else {
      if (this._resultsLayout == "grid") {
        if (this.exactSearchResultToDisplay?.cardCollection?.length <= 3) {
          val = 25;
        } else if (
          this.exactSearchResultToDisplay?.cardCollection?.length > 3 &&
          this.exactSearchResultToDisplay?.cardCollection?.length < 9
        ) {
          val = 54;
        }
      } else {
        val =
          this.exactSearchResultToDisplay?.cardCollection?.length > 0
            ? Number(this.exactSearchResultToDisplay?.cardCollection?.length) *
              10
            : 20;
      }
    }
    return "height: " + val + "rem";
  }

  get dynamicFuzzyMatchHeight() {
    let val;
    if (this.suggestionSearchResultToDisplay?.cardCollection?.length > 9) {
      val = 100;
    } else {
      if (this._resultsLayout == "grid") {
        if (this.suggestionSearchResultToDisplay?.cardCollection?.length <= 3) {
          val = 25;
        } else if (
          this.suggestionSearchResultToDisplay?.cardCollection?.length > 3 &&
          this.suggestionSearchResultToDisplay?.cardCollection?.length < 9
        ) {
          val = 54;
        }
      } else {
        val =
          this.suggestionSearchResultToDisplay?.cardCollection?.length > 0
            ? Number(
                this.suggestionSearchResultToDisplay?.cardCollection?.length
              ) * 10
            : 20;
      }
      // val = this.suggestionSearchResultToDisplay?.cardCollection?.length > 0 ? Number(this.suggestionSearchResultToDisplay?.cardCollection?.length) * 10 : 20;
    }
    return "height: " + val + "rem";
  }

  get displayExactMatches() {
    let listSize = this.exactSearchResult?.total;
    return listSize > 0;
  }

  get displaySuggestionMatches() {
    let listSize = this.suggestionSearchResult?.total;
    return listSize > 0;
  }

  get _resultsLayout() {
    return this.resultsLayout ?? DEFAULTS.resultsLayout;
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

  get resultsConfiguration() {
    return computeConfiguration({
      layout: this._resultsLayout,
      gridMaxColumnsDisplayed: this._gridMaxColumnsDisplayed,
      builderCardConfiguration: this.cardConfiguration,
      addToCartDisabled: false
    });
  }

  get customCssProperties() {
    const isGridLayout = this._resultsLayout === "grid";
    return generateStyleProperties({
      "--ref-c-search-product-grid-spacing-row": isGridLayout
        ? this._gridRowSpacing
        : this._listRowSpacing,
      ...(isGridLayout
        ? {
            "--ref-c-search-product-grid-spacing-column":
              this._gridColumnSpacing
          }
        : {}),
      ...(isGridLayout
        ? {}
        : {
            "--ref-c-search-product-grid-list-color-border":
              this._cardDividerColor
          }),
      "--ref-c-search-product-card-button-variant":
        this.addToCartButtonStyle || "primary",
      "--ref-c-search-product-card-container-color-background":
        this._cardBackgroundColor,
      "--ref-c-search-product-card-container-color-border":
        this._cardBorderColor,
      "--ref-c-search-product-card-container-radius-border":
        this._cardBorderRadius,
      ...(isGridLayout
        ? {
            "--ref-c-search-product-card-content-align-self":
              this._cardAlignment
          }
        : {}),
      ...(isGridLayout
        ? {
            "--ref-c-search-product-card-content-justify-self":
              this._cardAlignment
          }
        : {}),
      "--ref-c-product-pricing-negotiated-price-label-color":
        this._negotiatedPriceTextColor,
      "--ref-c-product-pricing-negotiated-price-label-size": dxpTextSize(
        this._negotiatedPriceTextSize
      ),
      "--ref-c-product-pricing-original-price-label-color":
        this._originalPriceTextColor,
      "--ref-c-product-pricing-original-price-label-size": dxpTextSize(
        this._originalPriceTextSize
      )
    });
  }

  get pageSize() {
    return this.searchResults?.pageSize ?? 20;
  }

  get totalItemCount() {
    if (this.searchResults?.total && this.searchResults?.total > 5000) {
      return 5000;
    }
    return this.searchResults?.total ?? 0;
    // let totalProducts;
    // if( this.exactSearchResult.total == 0 && this.suggestionSearchResult.total == 0){
    //     totalProducts = 0;
    // }else{
    //     totalProducts = this.exactSearchResult.total > this.suggestionSearchResult.total ? this.exactSearchResult.total : this.suggestionSearchResult.total;
    // }
    // return totalProducts ?? 0;
  }

  get showPagingControl() {
    const totalPages = Math.ceil(this.totalItemCount / this.pageSize);
    return totalPages >= 1;
  }

  handleAddToCart(event) {
    event.stopPropagation();
    this.dispatchEvent(
      new CustomEvent(EVENT.ADD_PRODUCT_TO_CART_EVT, {
        detail: event.detail
      })
    );
  }

  handleNavigateToProductPage(event) {
    event.stopPropagation();
    this.dispatchEvent(
      new CustomEvent(EVENT.SHOW_PRODUCT_EVT, {
        detail: event.detail
      })
    );
  }

  handlePreviousPageEvent(event) {
    event.stopPropagation();
    const previousPageNumber = this._currentPageNumber - 1;
    this.dispatchUpdateCurrentPageEvent(previousPageNumber);
  }

  handleNextPageEvent(event) {
    event.stopPropagation();
    const nextPageNumber = this._currentPageNumber + 1;
    this.dispatchUpdateCurrentPageEvent(nextPageNumber);
  }

  handleGotoPageEvent(event) {
    event.stopPropagation();
    const pageNumber = event.detail.pageNumber;
    this.dispatchUpdateCurrentPageEvent(pageNumber);
  }
  dispatchUpdateCurrentPageEvent(newPageNumber) {
    this.dispatchEvent(
      new CustomEvent(EVENT.UPDATE_CURRENT_PAGE_EVT, {
        detail: {
          newPageNumber
        }
      })
    );
  }

  originalSearchTerm;
  originalSearchTermWithoutSubcript;

  _searchTerm = null;
  get searchTerm() {
    if (!this._searchTerm) return;
    // let totalResults = this.searchResults?.total ?? 0;
    let totalResults = this.exactSearchResult?.total ?? 0;

    return totalResults == 0
      ? `Your keyword search "${this._searchTerm}" returned 0 results`
      : `Your search for "${this._searchTerm}" found ${this.searchResults?.total ?? 0} results`;
  }

  get hasResults() {
    let totalResults = this.searchResults?.total ?? 0;

    return totalResults > 0;
  }

  @api
  set searchTerm(value) {
    this.originalSearchTerm = value;
    this.originalSearchTermWithoutSubcript = this.formatSearchTerm(value);
    this._searchTerm = value;
  }

  //to replace subscripts from search term if present
  formatSearchTerm(val) {
    let returnVal = val.replace(/[\u2080-\u2089]/g, (match) => {
      // Map the subscript Unicode characters to their regular number counterparts
      const subscripts = {
        "\u2080": "0",
        "\u2081": "1",
        "\u2082": "2",
        "\u2083": "3",
        "\u2084": "4",
        "\u2085": "5",
        "\u2086": "6",
        "\u2087": "7",
        "\u2088": "8",
        "\u2089": "9"
      };
      return subscripts[match]; // Replace with corresponding regular number
    });
    console.log("formatSearchTerm returnVal---- " + returnVal);
    return returnVal;
  }

  countRender = 0;
  renderedCallback() {
    this.countRender = this.countRender + 1;
    if (!this.hasResults && this._searchTerm && this.countRender > 1)
      setTimeout(this.veryExistingResults.bind(this), 200); // 2 seconds
  }

  veryExistingResults() {
    if (!this.hasResults && this._searchTerm) this.navigateToPeriodicTable();
  }

  navigateToPeriodicTable() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Periodic_Table__c"
      },
      state: {
        term: this.searchTerm
      }
    });
  }

  triggerSortingFunction() {
    if (this.searchResults) {
      let dataMap = {
        searchResult: this.searchResults,
        searchTerm: this.originalSearchTerm,
        searchTermWithoutSubscript: this.originalSearchTermWithoutSubcript
      };
      console.log(
        "triggerSortingFunction dataMap---- ",
        JSON.parse(JSON.stringify(dataMap))
      );
      getExactSearchResult({
        dataMap: dataMap
      })
        .then((res) => {
          console.log(
            "getExactSearchResult res---- ",
            JSON.parse(JSON.stringify(res))
          );
          // handle result
          if (res.isSuccess) {
            this.customPageSizeExactMatch = this.customPageSize;
            this.customPageSizeSuggestMatch = this.customPageSize;
            this.exactSearchResult = res.exactSearchResult;
            this.suggestionSearchResult = res.suggestedSearchResult;
            this.exactSearchResult.total =
              this.exactSearchResult.cardCollection?.length;
            this.suggestionSearchResult.total =
              this.suggestionSearchResult.cardCollection?.length;
            if (
              this.exactSearchResult.total == 0 &&
              this.suggestionSearchResult.total == 0
            ) {
              //navigate to periodic table
              setTimeout(this.navigateToPeriodicTable(), 200);
            } else {
            }
            this.getDisplayData();
          } else {
            //some error occured.
            setTimeout(this.navigateToPeriodicTable(), 200);
          }
          this.showSpinner = false;
        })
        .catch((e) => {
          // handle errors
          this.showSpinner = false;
          console.log(
            "getExactSearchResult error exception---- ",
            JSON.parse(JSON.stringify(e))
          );
          setTimeout(this.navigateToPeriodicTable(), 1);
        });
    }
  }

  customPageSizeExactMatch = this.customPageSize;
  customPageSizeSuggestMatch = this.customPageSize;

  getDisplayData() {
    //limit page size
    let suggestionCardResult = JSON.parse(
      JSON.stringify(this.suggestionSearchResult)
    );
    if (
      suggestionCardResult.cardCollection &&
      suggestionCardResult.cardCollection.length > 0
    ) {
      suggestionCardResult.cardCollection =
        suggestionCardResult.cardCollection.slice(
          0,
          this.customPageSizeSuggestMatch
        );
      // suggestionCardResult.cardCollection = suggestionCardResult.cardCollection;
    }
    this.suggestionSearchResultToDisplay = suggestionCardResult;

    let exactCardResult = JSON.parse(JSON.stringify(this.exactSearchResult));
    if (
      exactCardResult.cardCollection &&
      exactCardResult.cardCollection.length > 0
    ) {
      exactCardResult.cardCollection = exactCardResult.cardCollection.slice(
        0,
        this.customPageSizeExactMatch
      );
      // exactCardResult.cardCollection = exactCardResult.cardCollection;
    }
    this.exactSearchResultToDisplay = exactCardResult;
    if (this.showToastMsg) {
      // this.showToast('Success','More products are loaded.','dismissible','success');
    }
    console.log(
      "final loading complete not after this??- ",
      JSON.parse(JSON.stringify(this.exactSearchResultToDisplay))
    );
    this.triggerLoadedEvent();
  }

  handleShowMoreExactMatch() {
    this.showToastMsg = true;
    this.customPageSizeExactMatch =
      this.customPageSizeExactMatch + this.customPageSize;
    this.getDisplayData();
  }

  handleShowMoreSuggestMatch() {
    this.showToastMsg = true;
    this.customPageSizeSuggestMatch =
      this.customPageSizeSuggestMatch + this.customPageSize;
    this.getDisplayData();
  }

  // Check if there are more items to display
  get hasMoreExactMatches() {
    console.log(
      "hasMoreExactMatches ----- " +
        this.exactSearchResultToDisplay.cardCollection.length
    );
    let tempThis = this;
    setTimeout(() => {
      tempThis.addExactMatchScrollEventListner();
    }, 800);
    return (
      this.exactSearchResultToDisplay.cardCollection.length <
      this.exactSearchResult.cardCollection.length
    );
  }

  get hasMoreSuggestMatches() {
    console.log(
      "hasMoreSuggestMatches ----- " +
        this.suggestionSearchResultToDisplay.cardCollection.length
    );
    let tempThis = this;
    setTimeout(() => {
      tempThis.addFuzzyMatchScrollEventListner();
    }, 800);
    return (
      this.suggestionSearchResultToDisplay.cardCollection.length <
      this.suggestionSearchResult.cardCollection.length
    );
  }

  showToastMsg = false;
  showToast(label, message, mode, variant) {
    this.showToastMsg = false;
    Toast.show(
      {
        label: label,
        message: message,
        mode: mode, //'sticky', 'dismissible'
        variant: variant //'info','success','warning','error'
      },
      this
    );
  }

  addFuzzyMatchScrollEventListner() {
    let divs = this.querySelectorAll(
      ".scroll-enabled.slds-scrollable_y.suggestions"
    );
    if (divs.length > 0) {
      divs.forEach((div) => {
        div.addEventListener("scroll", this.handleFuzzyMatchScroll.bind(this));
      });
    }
  }

  addExactMatchScrollEventListner() {
    let divs = this.querySelectorAll(".scroll-enabled.slds-scrollable_y.exact");
    if (divs.length > 0) {
      divs.forEach((div) => {
        div.addEventListener("scroll", this.handleExactMatchScroll.bind(this));
      });
    }
  }

  fuzzyMatchScrollFlag = true;
  handleFuzzyMatchScroll(event) {
    const scrollTop = event.target.scrollTop;
    const scrollHeight = event.target.scrollHeight;

    console.log(`Scroll Top: ${scrollTop}`);
    console.log(`Scroll Height: ${scrollHeight}`);

    let flag =
      this.suggestionSearchResultToDisplay.cardCollection.length <
      this.suggestionSearchResult.cardCollection.length;
    if (!flag) {
      event.currentTarget.removeEventListener(
        "scroll",
        this.removeScrollHandler.bind(this)
      );
    }
    let scrollVal = (scrollTop / scrollHeight) * 100;
    if (scrollVal > 53 && this.fuzzyMatchScrollFlag && flag) {
      this.fuzzyMatchScrollFlag = false;
      event.currentTarget.removeEventListener(
        "scroll",
        this.removeScrollHandler.bind(this)
      );
      this.handleShowMoreSuggestMatch();
    } else {
      this.fuzzyMatchScrollFlag = true;
    }
  }

  exactMatchScrollFlag = true;
  handleExactMatchScroll(event) {
    const scrollTop = event.target.scrollTop;
    const scrollHeight = event.target.scrollHeight;

    console.log(`Scroll Top: ${scrollTop}`);
    console.log(`Scroll Height: ${scrollHeight}`);
    let flag =
      this.exactSearchResultToDisplay.cardCollection.length <
      this.exactSearchResult.cardCollection.length;
    if (!flag) {
      event.currentTarget.removeEventListener(
        "scroll",
        this.removeScrollHandler.bind(this)
      );
    }
    let scrollVal = (scrollTop / scrollHeight) * 100;
    if (scrollVal > 53 && this.exactMatchScrollFlag && flag) {
      this.exactMatchScrollFlag = false;
      this.handleShowMoreExactMatch();
    } else {
      this.exactMatchScrollFlag = true;
    }
  }

  removeScrollHandler() {
    console.log("this.removeScrollHandler");
  }

  triggerLoadedEvent() {
    setTimeout(() => {
      this.isLoadedEvent();
    }, 1000);
  }

  isLoadedEvent() {
    this.dispatchEvent(
      new CustomEvent(EVENT.IS_LOADED_EVENT, {
        bubbles: true,
        composed: true,
        cancelable: true
      })
    );
  }
}