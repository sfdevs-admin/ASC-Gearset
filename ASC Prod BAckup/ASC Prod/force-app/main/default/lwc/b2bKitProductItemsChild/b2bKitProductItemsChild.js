import { LightningElement, api, wire } from 'lwc';
import { ProductAdapter } from 'commerce/productApi';
import basePath from '@salesforce/community/basePath';
import { navigate, NavigationContext, CurrentPageReference } from 'lightning/navigation';

export default class B2bKitProductItemsChild extends LightningElement {

    static renderMode = "light"; // the default is 'shadow'
    @api productId;
    @api unitValue;
    productData;
    prodImageUrl;
    prodName;
    prodCatlogNumber;
    prodCas;
    fields = [];

    @wire(NavigationContext)
    navContext;
    
    @wire(ProductAdapter, { productId: '$productId' })
    getProdDetails({ error, data })
    {
        if(error){
            console.log('getProdDetails Error => '+ JSON.stringify(error));
        }else{
            if(data != undefined){
                console.log('getProdDetails data => '+ JSON.stringify(data));
                this.productData = data;
                this.prodImageUrl = this.isCmsImage(this.productData.defaultImage.url);
                //this.fields.push(this.productData.fields.Id);
                this.fields.push(this.productData.fields.Name);
                //this.fields.push('<a><p onclick={handleNavigateToProductPage}>'+this.productData.fields.Name+'</p></a>');
                this.fields.push(this.productData.fields.Parent_Sku__c);
                //this.fields.push(this.productData.fields.CAS__c);

                this.prodName = this.productData.fields.Description;
                //this.prodCatlogNumber = this.productData.fields.ProductCode;
                this.prodCatlogNumber = this.productData.fields.Parent_Sku__c;
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

    handleNavigateToProductPage(event) {
        event.stopPropagation();
        const urlName = undefined;
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