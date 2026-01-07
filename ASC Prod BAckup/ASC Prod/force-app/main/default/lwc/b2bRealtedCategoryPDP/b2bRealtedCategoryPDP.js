import { LightningElement, api, track, wire } from 'lwc';
import getCategories from '@salesforce/apex/B2B_RealtedCategoryPDPController.getCategories';
import { navigate, NavigationContext } from 'lightning/navigation';

export default class B2bRealtedCategoryPDP extends LightningElement {
    productId;
    @track catagoryList;
    @track showRelatedCategories = false;
    
    @api 
    get productDetails(){
    }
    set productDetails(val){
        if(val){
            this.productId = val.id;
            this.getCategoriesApex();
        }
    }

    @wire(NavigationContext)
    navContext;

    async getCategoriesApex(){
        let mapParams = {};
        mapParams.productId = this.productId;
        getCategories({
            'mapParams' : mapParams
        }).then((res) => {
            console.log('B2bRealtedCategoryPDP getCategories res---- '+ JSON.stringify(res));
            if(res.isSuccess){
                let data = JSON.parse(JSON.stringify(res));
                this.catagoryList = data.categoryList;
                this.showRelatedCategories = data.categoryList?.length ? true : false;
                console.log('B2bRealtedCategoryPDP getCategories res---- '+ JSON.stringify(this.catagoryList));
            }else{
                //show no data found error
                console.log('B2bRealtedCategoryPDP getCategories is success false---- '+ JSON.stringify(res));
            }
        }).catch((e) => {
            console.log('B2bRealtedCategoryPDP getCategories catch---- '+ JSON.stringify(e));
        });
    }

    handleNavigateToCategory(event) {
        event.stopPropagation();
        let data = event.target.dataset.key;
        // let url = '/store/category/products/'+data;
        // let url = '/category/products/'+data; // for production
        
        // bug fix SCC-63 start
        let url = '/catalog/products/'+data; // for production
        // bug fix SCC-63 end
        this.navContext &&
            navigate(this.navContext, {
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            });
    }

}