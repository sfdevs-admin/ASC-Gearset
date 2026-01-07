/*
 * Copyright (c) 2023, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 * For full license text, see the LICENSE file in the repo
 * root or https://opensource.org/licenses/apache-2-0/
 */
import { api, LightningElement } from 'lwc';
import { NUM_FACETVALUES_ALWAYS_DISPLAYED, FACETVALUE_SHOW_MORE_LIMIT } from './constants';
import generateLabel from './inputFacetLabelGenerator';
/**
 * @typedef {import('../searchResults/searchResults').DistinctFacetValue} DistinctFacetValue
 */
export default class SearchInputFacet extends LightningElement {
    static renderMode = 'light';

    /**
     * The values of the facet
     * @type {?DistinctFacetValue[]}
     */
    @api
    values;

    /**
     * Gets the defaulted / normalized sequence of facet values to display.
     * @type {DistinctFacetValue[]}
     */
    get normalizedValues() {
        return this.values || [];
    }

    /**
     * The type of facet being displayed
     * @type {?string}
     */
    @api
    type;

    /**
     * The facet name for the values being displayed
     * @type {?string}
     */
    @api
    facetName;

    /**
     * Determines whether we show all the facet's values or not
     * @type {boolean}
     * @private
     */
    _expanded = false;

    /**
     * Gets the defaulted / normalized sequence of facet values to display.
     * Only show the first 6 values if
     * @type {DistinctFacetValue[]}
     * @readonly
     * @private
     */
    get displayedValues() {
        let facetValues = Array.from(this.normalizedValues);

        //custom make certain filters single select instead of multi select start
        if( this.facetName && this.facetName === 'Reaction' ){
            let isSelected = facetValues.find((facetVal) => 
                facetVal.checked == true
            );
            //console.log('SearchInputFacet displayedValues facetValues before-- '+facetValues);
            if( isSelected ){
                facetValues = facetValues.filter((facetVal) => 
                    facetVal.checked == true
                );
            }
            //console.log('SearchInputFacet displayedValues facetValues after-- '+facetValues);
            if( facetValues && isSelected ){
                this.values = JSON.parse( JSON.stringify( facetValues ) );
            }
        }
        //custom make certain filters single select instead of multi select start

        if (this.displayShowMore && !this._expanded) {
            facetValues = facetValues.slice(0, NUM_FACETVALUES_ALWAYS_DISPLAYED);
        } else if (this.displayShowMore && this._expanded) {
            facetValues = facetValues.map((facetValue, index) => ({
                ...facetValue,
                focusOnInit: index === NUM_FACETVALUES_ALWAYS_DISPLAYED,
            }));
        }
        return facetValues;
    }

    /**
     * Gets whether we should display a "Show More" button or not
     * @type {boolean}
     * @readonly
     * @private
     */
    get displayShowMore() {
        return this.normalizedValues.length > FACETVALUE_SHOW_MORE_LIMIT;
    }

    /**
     * Gets the label for the 'Show More' or 'Show Less' button
     * @type {string}
     * @readonly
     * @private
     */
    get showMoreOrLessLabel() {
        return generateLabel(this._expanded);
    }

    /**
     * Gets the aria label for the 'Show More' or 'Show Less' button
     * @type {string}
     * @readonly
     * @private
     */
    get facetAriaLabel() {
        return generateLabel(this._expanded, this.facetName);
    }

    /**
     * Handle the 'click' event fired from the 'Show More' or 'Show Less' button
     * @private
     */
    handleShowMoreOrLess() {
        this._expanded = !this._expanded;
    }
}