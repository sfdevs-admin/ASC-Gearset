import { LightningElement, api, wire } from 'lwc';
import { ProductAdapter } from 'commerce/productApi';
import basePath from '@salesforce/community/basePath';
import { navigate, NavigationContext, CurrentPageReference } from 'lightning/navigation';

export default class B2bFeaturedProductChild extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    @api productId;
    productData;
    prodImageUrl;
    prodName;
    prodCatlogNumber;
    prodCas;

    @wire(NavigationContext)
    navContext;
    
    @wire(ProductAdapter, { productId: '$productId' })
    getProdDetails({ error, data })
    {
        if(error){
            console.log('B2bFeaturedProductChild getProdDetails error exception----- '+ JSON.stringify(error));
        }else{
            if(data != undefined){
                console.log('B2bFeaturedProductChild getProdDetails data----- '+ JSON.stringify(data));
                this.productData = data;
                this.prodImageUrl = this.isCmsImage(this.productData.defaultImage.url);
                this.prodName = this.productData.fields.Name;
                //this.prodCatlogNumber = this.productData.fields.ProductCode;
                this.prodCatlogNumber = this.productData.fields.StockKeepingUnit;
                this.prodCas = this.productData.fields.CAS__c;
            }
        }
    }

    isCmsImage(url){
        if(url.startsWith('/cms')){
            return basePath + '/sfsites/c' + url;
        }else{
            return url;
        }
    }

    /**
     * Handles navigating to the product detail page from the search results page.
     * @param {CustomEvent<{productId: string; productName: string}>} event The event object
     */
    handleNavigateToProductPage(event) {
        event.stopPropagation();
        const urlName = undefined; //this.searchResults?.cardCollection.find((card) => card.id === event.detail.productId)?.urlName;
        this.navContext &&
            navigate(this.navContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: this.productId,
                    actionName: 'view',
                    urlName: urlName ?? undefined,
                },
                state: {
                    recordName: this.prodName,
                },
            });
    }
}