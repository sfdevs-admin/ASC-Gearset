import { LightningElement, wire, api, track } from 'lwc';
import {loadScript, loadStyle} from 'lightning/platformResourceLoader';
import glider from '@salesforce/resourceUrl/glider';
import getFeaturedProducts from '@salesforce/apex/B2B_FeaturedProductController.getFeaturedProducts';
import { ProductAdapter } from 'commerce/productApi';
import { CurrentPageReference } from 'lightning/navigation';

export default class B2bFeaturedProduct extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    @api productId;
    productData;
    @track featuredProdIdList = [];
    displayView = false;



    @wire(CurrentPageReference)
    getPageRef(res){
        console.log('B2bFeaturedProduct CurrentPageReference res------- '+JSON.stringify(res));
        this.productId = res.attributes.recordId;
    }

    @wire(ProductAdapter, { productId: '$productId' })
    getProdDetails({ error, data })
    {
        if(error){
            console.log('B2bFeaturedProduct getProdDetails error exception----- '+ JSON.stringify(error));
        }else{
            if(data != undefined){
                console.log('B2bFeaturedProduct getProdDetails data----- '+ JSON.stringify(data));
                this.productData = data;
                this.callGetFeaturedProduct();
            }
        }
    }

    // async renderedCallback(){
    //     console.log('B2bFeaturedProduct renderedCallback start');
    //     try{
    //         await this.loadGlider();
    //     }catch(e){
    //         console.log('B2bFeaturedProduct renderedCallback exception error--- '+e);
    //     }
    //     console.log('B2bFeaturedProduct renderedCallback end');
    // }

    handleLoadComplete(e){

    }

    async loadGlider(){
        await loadStyle(this, glider + '/Glider.js-master/glider.min.css'); 
        await loadScript(this, glider + '/Glider.js-master/glider.min.js').then(() => {
            this.isLoading = false;
            const el = this.querySelector('.glider'); //this.template.querySelector('.glider');
            let glider = new Glider(el, {
                // Mobile first
                slidesToShow: 'auto',
                slidesToScroll: 'auto',
                itemWidth: 350,
                duration: 0.25,
                draggable: true,
                // scrollLock: true,
                // scrollPropagate: false,
                // eventPropagate: true,
                arrows: {
                    prev: this.querySelector('.glider-prev'),//this.template.querySelector('.glider-prev'),
                    next: this.querySelector('.glider-next') //this.template.querySelector('.glider-next')
                },
                responsive: [
                  {
                    // screens greater than >= 775px
                    breakpoint: 1024,
                    settings: {
                      // Set to `auto` and provide item width to adjust to viewport
                      slidesToShow: 'auto',
                      slidesToScroll: 'auto',
                      itemWidth: 300,
                      duration: 0.25
                    }
                  } 
                ]
            });
        });
    }

    async callGetFeaturedProduct(){
        if(this.productData){
            let categoryPath = this.productData.primaryProductCategoryPath.path;
            let currentcategory = categoryPath.slice(-1);
            console.log('B2bFeaturedProduct getFeaturedProducts currentcategory---- '+ JSON.stringify(currentcategory));
            let mapParams = {};
            mapParams.currentCategoryId = currentcategory[0].id;
            mapParams.productId = this.productId;
            getFeaturedProducts({
                'mapParams' : mapParams
            }).then((res) => {
                let response = JSON.parse(JSON.stringify(res));
                console.log('B2bFeaturedProduct getFeaturedProducts res---- '+ JSON.stringify(res));
                if(res.isSuccess){
                    if(response.prodToCatList){
                        this.featuredProdIdList = response.prodToCatList;
                        this.displayView = true;
                        let tempThis = this;
                        window.setTimeout(function() {
                          tempThis.loadGliderJS();
                        }, 1000);
                    }
                }else{
                    //show no data found error
                    console.log('B2bFeaturedProduct getFeaturedProducts is success false---- '+ JSON.stringify(res));
                }
            }).catch((e) => {
                console.log('B2bFeaturedProduct getFeaturedProducts catch---- '+ JSON.stringify(e));
            });
        }
    }

    async loadGliderJS(){
        try{
            await this.loadGlider();
        }catch(e){
            console.log('B2bFeaturedProduct renderedCallback exception error--- '+e);
        }
    }
}