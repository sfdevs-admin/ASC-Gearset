import { LightningElement, api, track } from 'lwc';

export default class B2bSearchProduct extends LightningElement {
    @api resultsLayout
    @api showProductImage
    
    _productResult
    @api get productResult(){
        // console.log('b2bSearchProduct get productResult this._productResult', this._productResult);
        return this._productResult
    }

    set productResult(value){
        // console.log('b2bSearchProduct set productResult value', value);
        
        
        this._productResult = value
    }

    handleShowImage(event) {
        let productId = event.currentTarget.dataset.id
        // console.log('b2bSearchProduct handleShowImage productId', productId);

        let changeData = JSON.parse(JSON.stringify(this.productResult));

        // const keyIndex = this.facets.findIndex(obj => obj.nameOrId === key);
        const keyIndex = changeData.findIndex(obj => obj.id == productId);
        // console.log('b2bSearchLayout handleShowImage keyIndex', keyIndex);
        changeData[keyIndex].isImageVisible = true;
        this.productResult = changeData;
        // console.log('b2bSearchLayout handleShowImage this.productResult[keyIndex]', this.productResult[keyIndex]);
    }
  
    handleHideImage(event) {
        let productId = event.currentTarget.dataset.id
        // console.log('b2bSearchProduct handleHideImage productId', productId);
        let changeData = JSON.parse(JSON.stringify(this.productResult));

        // const keyIndex = this.facets.findIndex(obj => obj.nameOrId === key);
        const keyIndex = changeData.findIndex(obj => obj.id == productId);
        // console.log('b2bSearchLayout handleShowImage keyIndex', keyIndex);
        changeData[keyIndex].isImageVisible = false;
        this.productResult = changeData;
        // console.log('b2bSearchLayout handleShowImage this.productResult[keyIndex]', this.productResult[keyIndex]);
    }    

}