/*
 * Copyright (c) 2023, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 * For full license text, see the LICENSE file in the repo
 * root or https://opensource.org/licenses/apache-2-0/
 */
import { LightningElement, api, wire } from 'lwc';
import { navigate, NavigationContext, CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { createCartItemAddAction, createSearchFiltersUpdateAction, dispatchAction } from 'commerce/actionApi';
import CommonModal from 'c/commonModal';
import { Labels } from './labels';
import B2B_ParentCategoryId from '@salesforce/label/c.B2B_ParentCategoryId';

/**
 * @typedef {import('../searchResults/searchResults').ProductSearchResultSummary} ProductSearchResultSummary
 */

/**
 * @typedef {import('../searchResults/searchResults').CardContentMappingItem} CardContentMappingItem
 */

/**
 * Component that displays products for search and category page.
 */
export default class BuilderSearchResults extends NavigationMixin(LightningElement) {
    static categoryIdDev = this.B2B_ParentCategoryId;
    // static categoryIdProd = Labels.B2B_ParentCategoryId;    //'0ZGVN00000000rF4AQ';

    static renderMode = 'light';
    definedLayout = '';
    showSpinner = true;
    messageState = 'Please Wait';
    @wire(NavigationContext)
    navContext;

    /**
     * Results returned from the Search Data Provider
     * @type {?ProductSearchResultSummary}
     */
    @api
    searchResults;

    @api
    sortRuleId;

    @api
    sortRules;

    /**
     * Default field to show in results
     * @type {?string}
     */
    @api
    searchResultsFields;

    /**
     * The layout of the results tiles.
     * @type {?('grid' | 'list')}
     */
    @api
    resultsLayout;

    /**
     * The size of the spacing between the grid columns.
     * @type {?('small' | 'medium' | 'large'| 'none')}
     */
    @api
    gridColumnSpacing;

    /**
     * The size of the spacing between the grid rows.
     * @type {?('small' | 'medium' | 'large'| 'none')}
     */
    @api
    gridRowSpacing;

    /**
     * The maximum number of grid columns to be displayed.
     * Accepted values are between 1 and 8.
     * @type {?number}
     */
    @api
    gridMaxColumnsDisplayed;

    /**
     * The size of the spacing between the list rows.
     * @type {?('small' | 'medium' | 'large'| 'none')}
     */
    @api
    listRowSpacing;

    /**
     * Font color for the card background field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    cardBackgroundColor;

    /**
     * The alignment of the results cards.
     * @type {?('right' | 'center' | 'left')}
     */
    @api
    cardAlignment;

    /**
     * Font color for the card border field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    cardBorderColor;

    /**
     * The value of the border radius for the results card.
     * @type {?string}
     */
    @api
    cardBorderRadius;

    /**
     * Font color for the card divider field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    cardDividerColor;

    /**
     * The font size of the negotiated price.
     * @type {?('small' | 'medium' | 'large')}
     */
    @api
    negotiatedPriceTextSize;

    /**
     * Whether to display the negotiated price.
     * @type {boolean}
     * @default false
     */
    @api
    showNegotiatedPrice = false;

    /**
     * Font color for the negotiated price text field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    negotiatedPriceTextColor;

    /**
     * Whether to display the original price.
     * @type {boolean}
     * @default false
     */
    @api
    showOriginalPrice = false;

    /**
     * The font size of the original price.
     * @type {?('small' | 'medium' | 'large')}
     */
    @api
    originalPriceTextSize;

    /**
     * Font color for the original price text field, as 'rgb', 'rgba' or 'hex' CSS value.
     * @type {?string}
     */
    @api
    originalPriceTextColor;

    /**
     * Whether to display the product image.
     * @type {boolean}
     * @default false
     */
    @api
    showProductImage = false;

    /**
     * The product fields to display in the productCard cmp.
     * @type {string}
     */
    @api
    cardContentMapping;

    /**
     * Whether to display the action button.
     * @type {boolean}
     * @default false
     */
    @api
    showCallToActionButton = false;

    /**
     * The text for the add to cart button
     * @type {?string}
     */
    @api
    addToCartButtonText;

    /**
     * The button style for add to cart button
     * Accepted values primary, secondary, tertiary
     * @type {?('primary' | 'secondary' | 'tertiary')}
     */
    @api
    addToCartButtonStyle;

    /**
     * The text for the add to cart button when cart is processing
     * @type {?string}
     */
    @api
    addToCartButtonProcessingText;

    /**
     * The text for the view options button
     * @type {?string}
     */
    @api
    viewOptionsButtonText;

    /**
     * The current page number of the results.
     * @type {?string}
     */
    @api
    currentPage;

    /**
     * @type {CardContentMappingItem[]}
     * @readonly
     * @private
     */
    get normalizedCardContentMapping() {
        return JSON.parse(this.cardContentMapping ?? '[]');
    }

    get comboOptions() {
        return [
            { label: 'Grid', value: 'grid' },
            { label: 'List', value: 'list' },
        ];
    }

    handleComboOptionsChange(event) {
        // let METHOD = 'handleComboOptionsChange';
        this.resultsLayout = event.detail.value;
        // console.log(METHOD + ' this.resultsLayout', this.resultsLayout);
        this.updateSessionStorage();
        window.location.reload();
    }

    getDefinedLayoutFromSession() {
        // let METHOD = 'getDefinedLayoutFromSession'; 
        let savedOrDefault = sessionStorage.getItem('definedLayout') || 'grid';
        // console.log(METHOD + ' savedOrDefault', savedOrDefault);
        console.log('searchResultsFields - ', JSON.parse(JSON.stringify(this.searchResultsFields)));
        return savedOrDefault
    }

    connectedCallback() {
        // let METHOD = 'connectedCallback'; 
        let tempThis = this;
        setTimeout(() =>{
            tempThis.showSpinner = false;
        },1500)
        this.resultsLayout = this.getDefinedLayoutFromSession();
        // console.log(METHOD + ' this.resultsLayout', this.resultsLayout);
        this.updateSessionStorage();
    }    

    updateSessionStorage() {
        this.definedLayout = this.resultsLayout;
        sessionStorage.setItem('definedLayout', this.definedLayout);
    }
    
    /**
     * Handles the 'addproducttocart' event.
     * Adds the product to the cart and then on success opens the add to cart modal.
     * @param {CustomEvent<{ productId: string; quantity: number }>} event The event object
     * @private
     */
    handleAddToCart(event) {
        event.stopPropagation();
        const { productId, quantity } = event.detail;
        dispatchAction(this, createCartItemAddAction(productId, quantity), {
            onSuccess: () => {
                CommonModal.open({
                    label: Labels.messageSuccessfullyAddedToCart,
                    size: 'small',
                    secondaryActionLabel: Labels.actionContinueShopping,
                    primaryActionLabel: Labels.actionViewCart,
                    onprimaryactionclick: () => this.navigateToCart(),
                });
            },
        });
    }

    /**
     * Navigates to the cart page when the primary button is clicked
     * from the modal after adding an item to the cart
     * @private
     */
    navigateToCart() {
        this.navContext &&
            navigate(this.navContext, {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Current_Cart',
                },
            });
    }

    /**
     * Handles navigating to the product detail page from the search results page.
     * @param {CustomEvent<{productId: string; productName: string}>} event The event object
     */
    handleNavigateToProductPage(event) {
        event.stopPropagation();
        const urlName = this.searchResults?.cardCollection.find((card) => card.id === event.detail.productId)?.urlName;
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
                objectApiName: 'Product2',
                recordId: event.detail.productId,
                actionName: 'view',
                urlName: urlName ?? undefined,
            },
            state: {
                recordName: event.detail.productName,
            },
        }).then(url => {
            console.log('main handleNavigateToProductPage------ '+url);
            window.open(url, "_blank");
        });
    }

    /**
     * Trigger an update of the page number at the closest `SearchDataProvider`
     * @param {CustomEvent<{newPageNumber: number}>} event The event object
     * @private
     */
    handleUpdateCurrentPage(event) {
        event.stopPropagation();
        dispatchAction(this, createSearchFiltersUpdateAction({ page: event.detail.newPageNumber }));
    }
    flagCheck = false;
    searchTearm = null;
    currentPage;
    periodicTable;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('search logic-- '+currentPageReference);
        if (currentPageReference) {
            if(this.currentPage != currentPageReference?.state?.page){
                this.flagCheck = false;
            }
            this.currentPage = currentPageReference?.state?.page;
            if( this.searchTearm != currentPageReference?.state?.term ){
                this.flagCheck = false;
            }
            if(currentPageReference?.type == 'standard__search' && ( currentPageReference?.state?.category == undefined || currentPageReference?.state?.category == null ) ){
                this.flagCheck = false;
            }
            this.searchTearm = currentPageReference?.state?.term ? currentPageReference.state.term : null;
            let isPeriodicTable = currentPageReference?.state?.periodicTable ? currentPageReference?.state?.periodicTable : null;
            if( (isPeriodicTable === 'true' || this.periodicTable === 'true') && (currentPageReference.type != 'standard__recordPage' && currentPageReference?.attributes?.objectApiName == 'ProductCategory') ){
                this.periodicTable = this.periodicTable != undefined ? this.periodicTable : isPeriodicTable;
                this.flagCheck = true;
                currentPageReference.state.periodicTable = undefined;
                return;
            }
            else if( currentPageReference && currentPageReference?.type == 'standard__search' && !this.flagCheck ){
                let catId = B2B_ParentCategoryId;
                if( !window.location.search.includes('category') ){
                    window.location.href = window.location.href + '?category=' + catId;
                }
                // dispatchAction(this, createSearchFiltersUpdateAction({ categoryId: catId }));
                this.flagCheck = true;
            }
        }
    }    
}