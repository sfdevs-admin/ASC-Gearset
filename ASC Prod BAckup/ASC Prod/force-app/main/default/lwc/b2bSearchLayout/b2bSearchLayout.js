import { LightningElement, api } from 'lwc';

export default class B2bSearchLayout extends LightningElement {
    
    _displayProducts;
    @api get displayProducts(){
        return this._displayProducts
    }

    set displayProducts(value){
        this._displayProducts = JSON.parse(JSON.stringify(value));;
    }

    showMoreImageUrl = '/sfsites/c/resource/strem_css/images/buttons/slider_more.gif';
    showMoreLessUrl = '/sfsites/c/resource/strem_css/images/buttons/slider_less.gif';
    toggleOpenText = 'Open Section';
    toggleCloseText = 'Close Section';

    // _toggleImage='';
    // _toggleAltText='';

    // get toggleImage(){
    //     return this._toggleImage
    // }
    // set toggleImage(value){
    //     this._toggleImage = value;
    // }

    // get toggleAltText(){
    //     return this._toggleAltText;
    // }

    // set toggleAltText(value){
    //     this._toggleAltText = value;
    // }

    toggleProductList(event){
        let categoryId = event.currentTarget.dataset.id
        // console.log('b2bSearchLayout toggleProductList categoryId', categoryId);

        let changeData = JSON.parse(JSON.stringify(this.displayProducts));

        // const keyIndex = this.facets.findIndex(obj => obj.nameOrId === key);
        const keyIndex = changeData.findIndex(obj => obj.id == categoryId);
        // console.log('b2bSearchLayout toggleProductList keyIndex', keyIndex);

        let isShowing = Boolean(changeData[keyIndex].showProductList);
        isShowing = ! isShowing;

        changeData[keyIndex].showProductList = isShowing;
        changeData[keyIndex].toggleImage = isShowing ? this.showMoreLessUrl : this.showMoreImageUrl;
        changeData[keyIndex].toggleAltText = isShowing ? this.toggleCloseText : this.toggleOpenText;
        changeData[keyIndex].showProducts = isShowing;
        // console.log('b2bSearchLayout toggleProductList changeData[keyIndex].products', changeData[keyIndex].products);


        

        this.displayProducts = changeData;
    }

}