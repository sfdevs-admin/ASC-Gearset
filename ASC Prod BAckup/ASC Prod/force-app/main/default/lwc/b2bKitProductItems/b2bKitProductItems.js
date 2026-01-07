import { LightningElement, wire, track } from "lwc";
import { ProductAdapter } from "commerce/productApi";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getKitRelatedProductItems from "@salesforce/apex/B2B_ProductKitProductController.getKitRelatedProductItems";

// bug fix SCC-70 Product Kits PDP broken details starts
import B2B_Product_Kit_Missing_Error_Msg from "@salesforce/label/c.B2B_Product_Kit_Missing_Error_Msg";
// bug fix SCC-70 Product Kits PDP broken details ends

export default class B2bKitProductItems extends NavigationMixin(
  LightningElement
) {
  // bug fix SCC-70 Product Kits PDP broken details starts
  label = {
    B2B_Product_Kit_Missing_Error_Msg: B2B_Product_Kit_Missing_Error_Msg
  };
  // bug fix SCC-70 Product Kits PDP broken details ends

  productId;
  productData;
  productSKU;
  @track isKitProduct = false;
  @track isListHasData = false;
  @track relatedProdItemsList = [];
  @track elementVsProductKitProductMap = {};
  //@track mapData = new Map();
  @track mapData = [];

  @wire(CurrentPageReference)
  getPageRef(res) {
    console.log("b2bkitProductItems result =>" + JSON.stringify(res));
    this.productId = res.attributes.recordId;
  }

  @wire(ProductAdapter, { productId: "$productId" })
  getProdDetails({ error, data }) {
    if (error) {
      console.error("getProdDetails Error => " + JSON.stringify(error));
    } else {
      if (data != undefined) {
        console.log("getProdDetails data => " + JSON.stringify(data));
        this.productData = data;
        this.productSKU = this.productData?.fields?.StockKeepingUnit;
        let productClass = this.productData?.productClass;
        let variationParentId = this.productData?.variationParentId;

        let containsKit;
        if (
          this.productData?.variationInfo?.attributesToProductMappings?.[0]
            ?.selectedAttributes?.[0]?.value == "1kit" ||
          this.productData?.variationInfo?.attributesToProductMappings?.[0]
            ?.selectedAttributes?.[0]?.value == "1 kit"
        ) {
          containsKit = true;
        } else {
          containsKit = false;
          this.mapData = [];
          this.relatedProdItemsList = [];
          this.isKitProduct = false;
        }

        if (
          this.productId &&
          !variationParentId &&
          containsKit &&
          productClass == "VariationParent"
        ) {
          this.productId =
            this.productData?.variationInfo?.attributesToProductMappings?.[0]?.productId;
          this.isKitProduct = true;
          this.callGetKitRelatedProductItems();
        } else if (this.productId && this.productSKU.includes("KIT")) {
          this.isKitProduct = true;
          this.callGetKitRelatedProductItems();
        }
      }
    }
  }

  callGetKitRelatedProductItems() {
    console.log("getKitRelatedProductItems ===>" + this.productId);
    getKitRelatedProductItems({
      productId: this.productId
    })
      .then((response) => {
        console.log("getKitRelatedProductItems => ", response);
        let elementVsProductKitProductMap = new Map();
        if (response.isSuccess && response.pkpList) {
          this.isListHasData = true;
          //this.elementVsProductKitProductMap = response.elementVsProductKitProductMap;
          //elementVsProductKitProductMap1 = new Map([...elementVsProductKitProductMap1.entries()].sort());
          //console.log('elementVsProductKitProductMap => ',elementVsProductKitProductMap1);
          if (response.elementVsProductKitProductMap) {
            for (let key in response.elementVsProductKitProductMap) {
              console.log("response => ", key);
              console.log(
                "val => ",
                response.elementVsProductKitProductMap[key]
              );
              //elementVsProductKitProductMap.push({value:response.elementVsProductKitProductMap[key], key:key});
              elementVsProductKitProductMap.set(
                key,
                response.elementVsProductKitProductMap[key]
              );
            }
          }
          console.log(
            "elementVsProductKitProductMap =>",
            elementVsProductKitProductMap
          );
          //this.mapData = new Map([...elementVsProductKitProductMap.entries()].sort());
          //console.log('this.mapData =>', this.mapData);
          elementVsProductKitProductMap = new Map(
            [...elementVsProductKitProductMap.entries()].sort()
          );
          // for(let key in elementVsProductKitProductMap){
          //     this.mapData.push({value:response.elementVsProductKitProductMap[key], key:key});
          // }
          // this.mapData = Object.entries(elementVsProductKitProductMap).map(([key, value]) => ({
          //     key,
          //     value
          // }));
          this.mapData = Array.from(
            elementVsProductKitProductMap,
            ([key, value]) => ({ key, value })
          );
          console.log("this.mapData =>", this.mapData);
          this.relatedProdItemsList = response.pkpList;
        } else {
          //show no data found error
          console.log("error => " + JSON.stringify(res));
        }
      })
      .catch((e) => {
        console.log("exception => " + JSON.stringify(e));
      });
  }
}