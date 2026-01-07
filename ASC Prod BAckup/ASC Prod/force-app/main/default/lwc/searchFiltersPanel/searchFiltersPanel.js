/*
 * Copyright (c) 2023, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 * For full license text, see the LICENSE file in the repo
 * root or https://opensource.org/licenses/apache-2-0/
 */
import { LightningElement, api, wire } from 'lwc';
import labels from './labels';
import { debounce } from 'experience/utils';
import { refinementsFromFacetsMap } from './dataConverter';
import { EVENT, DEFAULT_SEARCH_PAGE } from './constants';
import { ProductSearchAdapter, ProductCategoryPathAdapter } from 'commerce/productApi';
import {
    normalizeFacets,
    normalizeRefinements,
    createTreeFromCategory,
    transformInputFacetLabels,
    normalizeResultsWithAncestorCategoryTree,
    getRefinementsFromPageRef,
// } from './utils';
} from './utilsCustom';

import { navigate, NavigationContext, CurrentPageReference } from 'lightning/navigation';

// import B2B_ParentCategoryId from '@salesforce/label/c.B2B_ParentCategoryId';
/**
 * @typedef {import('../searchResults/searchResults').SearchFacet} SearchFacet
 */

/**
 * @typedef {import('../searchResults/searchResults').FiltersPanelDetail} FiltersPanelDetail
 */

/**
 * @typedef {import('../searchResults/searchResults').CategoryInfoTree} CategoryInfoTree
 */

/**
 * @typedef {import('../searchFilters/searchFilters').ProductSearchRefinement} ProductSearchRefinement
 */

/**
 * @typedef {import('../searchFilters/searchFilters').SearchFacetValuesCheckMap} SearchFacetValuesCheckMap
 */

/**
 * An event fired when the facet value been updated.
 * @event SearchFiltersPanel#facetvalueupdate
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {SearchFacet} detail.mruFacet
 *   The most recent facet that the user has selected.
 * @property {ProductSearchRefinement[]} detail.refinements
 *   The selected filter id and it's values.
 */

/**
 * An event fired to clear all filters
 * @event SearchFiltersPanel#clearallfilters
 * @type {CustomEvent}
 */
/**
 * Representation for the Filters Panel which shows the category tree and facets
 * @fires SearchFiltersPanel#facetvalueupdate
 * @fires SearchFiltersPanel#clearallfilters
 */
export default class SearchFiltersPanel extends LightningElement {
    static renderMode = 'light';

    _searchQuery = {};
    _displayData;
    _facetsMap;
    _displayCount = 0;
    _mruFacet;
    _searchTerm = '';
    _categoryId = '';
    _refinements = [];
    _categoryPath = [];
    _pageRef;
    _isActive;
    /**
     * Gets or sets the filters panel display-data.
     * @type {?FiltersPanelDetail}
     */
    @api
    get displayData() {
        return this._displayData;
    }
    set displayData(value) {
        this._displayData = value;
        this._transformCategoryAndFacetData( this._displayData );
        this.updateSearchQuery();
        const facets = value?.facets ?? [];
        this._facetsMap = this._createFacetMap(facets);
    }

    showFiltersPanel;
    @api
    get isActive() {
        return this._isActive;
    }
    set isActive(value) {
        console.log('category logic isActive-- '+value);
        this.showFiltersPanel = value;
        this._isActive = value;
    }

    updateSearchQuery() {
        const searchTerm = this._searchTerm;
        const categoryId = this._categoryId;
        const refinements = this._refinements ?? [];
        const page = DEFAULT_SEARCH_PAGE - 1;
        // this._searchQuery = {
        //     searchTerm,
        //     categoryId,
        //     refinements,
        //     page,
        //     includePrices: false,
        // };
    }

    @api
    get pageRef() {
        return this._pageRef;
    }
    set pageRef(value) {
        this._pageRef = value;
        this.updatePageRefDetails(value);
    }

    @wire(ProductSearchAdapter, {
        searchQuery: '$_searchQuery',
    })
    updateProductSearch(result) {
        if (result.data) {
            this._displayCount = result.data.productsPage?.total ?? 0;
            this._transformCategoryAndFacetData(result.data);
        }
    }

    // b2bParentcategoryId;

    // @wire(ProductCategoryPathAdapter, {
    //     categoryId: '$b2bParentcategoryId',
    // })
    // wiredCategoryPath({ data }) {
    //     this._categoryPath = data?.path ?? [];
    //     this._displayData = normalizeResultsWithAncestorCategoryTree(
    //         this._categoryPath,
    //         this.displayData,
    //         this.categoryId
    //     );
    // }

    /**
     * Translate category/facet API data into UI representations
     * @param {ProductSearchResultsData} res - Response returned from the ProductSearchAdapter
     */
    _transformCategoryAndFacetData(res) {
        console.log('SearchFiltersPanel _transformCategoryAndFacetData-- '+res);
        const { categories, facets } = res;
        if (categories && facets) {
            const processedCategories = createTreeFromCategory(categories, this._pageRef, this._categoryPath);
            const processedFacets = transformInputFacetLabels(
                normalizeFacets(facets),
                normalizeRefinements(this._refinements),
                this._mruFacet
            );
            this._displayData = {
                categories: processedCategories,
                facets: processedFacets,
            };
        }
    }

    /**
     * Updates the categoryId, searchTerm and refinements based on the pageReference object
     * @param {?(SearchPageReference | CategoryPageReference)} pageRef
     */
    updatePageRefDetails(pageRef) {
        if (pageRef) {
            this._searchTerm = pageRef.state?.term ?? '';
            if (pageRef.type === 'standard__recordPage') {
                const categoryId = pageRef.attributes?.recordId ?? '';
                this._categoryId = this._parentCategoryId = categoryId;
            }
            if (pageRef.state?.category) {
                this._categoryId = pageRef.state.category;
            }
            // if( pageRef.type == 'standard__search' ){
            //     const catId = B2B_ParentCategoryId;
            //     // this.b2bParentcategoryId = catId;
            // }
            this._refinements = getRefinementsFromPageRef(pageRef);
            this.updateSearchQuery();
        }
    }

    /**
     * Gets the normalized filters panel display-data.
     * @type {FiltersPanelDetail}
     * @private
     */
    get normalizedDisplayData() {
        const displayData = this.displayData;
        return {
            facets: displayData?.facets ?? [],
            categories: displayData?.categories,
        };
    }

    /**
     * Gets the list of facets
     * @type {?SearchFacet[]}
     * @private
     */
    get facets() {
        return this.normalizedDisplayData.facets;
    }

    /**
     * Gets the categories tree
     * @type {?CategoryInfoTree}
     * @private
     */
    get categories() {
        return this.normalizedDisplayData.categories;
    }

    /**
     * Gets the label for the filters header
     * @type {string}
     * @private
     */
    get filtersHeader() {
        return labels.filtersHeader;
    }

    /**
     * Gets the label for the clear all button
     * @type {string}
     * @private
     */
    get clearAllLabel() {
        return labels.clearAllLabel;
    }

    /**
     * The map of all SearchFacetValuesCheckMap and all their possible facet values, regardless of selection or not.
     * @type {Map<string | undefined, SearchFacetValuesCheckMap> | null}
     */
    _facetsMap;

    /**
     * The most recent facet that the user has selected
     * @type {SearchFacet}
     * @private
     */
    _mruFacet = {};

    /**
     * The ID of the most recent facet that the user has selected
     * @type {?string}
     * @private
     */
    _mruFacetId;

    /**
     * The filters panel display-data.
     * @type {?FiltersPanelDetail}
     * @private
     */
    _displayData;

    /**
     * Handler for the 'onfacetvaluetoggle' event fired from inputFacet
     * @param {CustomEvent} evt the event object
     */
    handleFacetValueToggle(evt) {
        if (evt.target instanceof HTMLElement) {
            this._mruFacetId = evt.detail.facetId;
            const facetValueId = evt.detail.id;
            const checked = evt.detail.checked;
            if (this._mruFacetId && this._facetsMap?.get(this._mruFacetId)) {
                this._facetsMap.get(this._mruFacetId)?.valuesCheckMap.set(facetValueId, checked);
                this._facetValueUpdated();
            }
        }
    }

    flagCheck = false;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('category logic-- '+JSON.stringify(currentPageReference));
        if (currentPageReference) {
            let isPeriodicTable = currentPageReference?.state?.periodicTable ? currentPageReference?.state?.periodicTable : null;
            let catElementName = currentPageReference?.state?.catName ? currentPageReference?.state?.catName : null;
            if( (isPeriodicTable === 'true' || this.periodicTable === 'true') && (currentPageReference.type != 'standard__recordPage' && currentPageReference?.attributes?.objectApiName == 'ProductCategory')){
                // this.periodicTable = this.periodicTable != undefined ? this.periodicTable : isPeriodicTable;
                // this.flagCheck = true;
                // currentPageReference.state.periodicTable = undefined;
                // return;
            }
            else if( currentPageReference.type == 'standard__recordPage' && currentPageReference?.attributes?.objectApiName == 'ProductCategory' && !this.flagCheck && catElementName ){
                // let catId = B2B_ParentCategoryId;
                // if( !window.location.search.includes('category') ){
                //     window.location.href = window.location.href + '?category=' + catId;
                // }
                this._mruFacetId = 'Elements__c:Custom';
                // const facetValueId = 'Aluminum';
                const facetValueId = catElementName;
                const checked = true;

                if (this._mruFacetId && this._facetsMap?.get(this._mruFacetId)) {
                    this._facetsMap.get(this._mruFacetId)?.valuesCheckMap.set(facetValueId, checked);
              
                        this.facetValueUpdated2();
                
                }
                this.flagCheck = true;
            }
        }
    }

    _createFacetMap(facets) {
        return facets?.reduce((facetAccumulator, searchFacet) => {
            return facetAccumulator.set(searchFacet.id, {
                searchFacet,
                valuesCheckMap: new Map(searchFacet.values?.map((facetValue) => [facetValue.id, facetValue.checked])),
            });
        }, new Map());
    }

    /**
     * The function called when we update the facets in the search
     * @type {Function}
     * @private
     * @fires SearchFiltersPanel#facetvalueupdate
     */
    _facetValueUpdated = debounce(() => {
        const mruFacetList = this.facets?.filter((facet) => facet.id === this._mruFacetId);
       
        if (mruFacetList && mruFacetList.length === 1) {
            this._mruFacet = mruFacetList[0];
        }
        const updatedMruFacet = Object.assign({}, this._mruFacet);
        updatedMruFacet.values = updatedMruFacet.values.map((item) => {
            return {
                ...item,
                checked: this._facetsMap?.get(this._mruFacetId)?.valuesCheckMap.get(item.id),
            };
        });
        this._mruFacet = updatedMruFacet;
        
        const refinements = refinementsFromFacetsMap(this._facetsMap);
        this.dispatchEvent(
            new CustomEvent(EVENT.FACETVALUE_UPDATE_EVT, {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    mruFacet: this._mruFacet,
                    refinements,
                },
            })
        );
    }, 300);


    facetValueUpdated2 ()  {
        const mruFacetList = this.facets?.filter((facet) => facet.id === this._mruFacetId);
       
        if (mruFacetList && mruFacetList.length === 1) {
            this._mruFacet = mruFacetList[0];
        }
        const updatedMruFacet = Object.assign({}, this._mruFacet);
        updatedMruFacet.values = updatedMruFacet.values.map((item) => {
            return {
                ...item,
                checked: this._facetsMap?.get(this._mruFacetId)?.valuesCheckMap.get(item.id),
            };
        });
        this._mruFacet = updatedMruFacet;
        
        const refinements = refinementsFromFacetsMap(this._facetsMap);
        this.dispatchEvent(
            new CustomEvent(EVENT.FACETVALUE_UPDATE_EVT, {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    mruFacet: this._mruFacet,
                    refinements,
                },
            })
        );
    }

    /**
     * Handler for the 'click' event fired from the Clear All button
     * Resets the facetsMap and triggers the 'clearallfilters' event
     * @param {CustomEvent} evt the event object
     * @fires SearchFiltersPanel#clearallfilters
     */
    handleClearAll(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this._mruFacet = null;
        this._refinements = [];
        this._categoryId = this._parentCategoryId ?? '';
        if (this._facetsMap) {
            this._facetsMap.clear();
            this._facetsMap = null;
        }
        this.updateSearchQuery();
        this.dispatchEvent(
            new CustomEvent(EVENT.CLEAR_ALL_FILTERS_EVT, {
                bubbles: true,
                composed: true,
            })
        );
    }

    connectedCallback(){
        console.log('category logic connectedCallback-- ');
    }
}