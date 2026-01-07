import { LightningElement, api } from 'lwc';

export default class B2bCategoryBanner extends LightningElement {
    @api categoryTitle;
    _searchResultText;
    categoryFound=[];
    imageUrl = '/sfsites/c/resource/strem_css/images/backgrounds/page_header.jpg';
    isLoading=false;

    get getBackgroundImage() {
        return "background-image: url(" + this.imageUrl +")";
    }

    @api
    get searchResultText(){
        // console.log('b2bCategoryBanner get searchResultText this._searchResultText',this._searchResultText)
        return this._searchResultText
    }
    set searchResultText(value){
        // console.log('b2bCategoryBanner get searchResultText value',value)
        this._searchResultText = value;
    }


}