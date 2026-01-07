/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 17-12-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { ProductAdapter } from "commerce/productApi";
import { CartItemsAdapter } from "commerce/cartApi";
import { OrderSummaryLookupDataAdapter } from "commerce/orderApi";
import { debounce } from "experience/utils";
import getCategories from "@salesforce/apex/B2B_Breadcrumbs.getCategories";
import { createRecord } from "lightning/uiRecordApi";
import ASCENSUS_EXCEPTION_OBJECT from "@salesforce/schema/Ascensus_Custom_Exception__c";
import EXCEPTION_MESSAGE_FIELD from "@salesforce/schema/Ascensus_Custom_Exception__c.Exception_Message__c";
import INPUT_PARAMTER_FIELD from "@salesforce/schema/Ascensus_Custom_Exception__c.B2B_Input_Parameter__c";
import METHOD_NAME_FIELD from "@salesforce/schema/Ascensus_Custom_Exception__c.Method_Name__c";
import CLASS_NAME_FIELD from "@salesforce/schema/Ascensus_Custom_Exception__c.ClassName__c";

const ORDERSUMMARYFIELDS = [
    "OrderSummary.Promotions_Applied__c",
    "OrderSummary.GrandTotalAmount",
    "OrderSummary.TotalTaxAmount",
    "OrderSummary.currencyIsoCode",
    "OrderSummary.TotalAdjustedDeliveryAmount"
];

const PAGE_REF_DELAY = 150; // ms

export default class B2bGoogleTagManager extends LightningElement {
    hasOrderNumberInitialized = false;
    currentPageReference;
    currentRecordId;

    cartEventAdded = false;
    checkoutEventAdded = false;
    orderEventAdded = false;
    orderErrorLogged = false;

    pageTitle;
    cartId;
    cartSummary;
    productData;
    cartItems = [];
    items = [];
    orderNumber;
    orderSummary;
    orderItems = [];

    previousCartItems = [];
    lastItemsSnapshot = [];

    pageRefTimer;

    // ---------------- WIRE ADAPTERS ----------------

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (!pageRef) return;

        this.currentPageReference = pageRef;

        // Product detail page
        if (
            pageRef.type === "standard__recordPage" &&
            pageRef.attributes.objectApiName === "Product2"
        ) {
            const newRecordId = pageRef?.attributes?.recordId;
            if (this.currentRecordId !== newRecordId) {
                this.currentRecordId = newRecordId;
            }
            this.initializeEventListenerAddtoCart();
        }

        // Delayed page title + order number tracking
        if (this.pageRefTimer) {
            clearTimeout(this.pageRefTimer);
        }
        this.pageRefTimer = setTimeout(() => {
            this.pageTitle =
                document?.title || pageRef?.state?.pageTitle || "Default Page";

            if (this.pageTitle === "Order Confirmation") {
                const urlParams = new URLSearchParams(window.location.search);
                this.orderNumber = urlParams.get("orderNumber");
            } else {
                this.trackEvent(this.pageTitle);
            }

            this.pageRefTimer = null;
        }, PAGE_REF_DELAY);
    }

    @wire(ProductAdapter, { productId: "$currentRecordId" })
    wiredProduct(result) {
        if (result.data) {
            this.productData = result?.data;
            this.trackEventViewItem();
        } else if (result.error) {
            console.error("Error fetching product:", result.error);
            if (
                this.currentPageReference?.type === "standard__recordPage" &&
                this.currentPageReference?.attributes?.objectApiName === "Product2"
            ) {
                this.logErrorToRecord(
                    JSON.stringify(result.error),
                    "wiredProduct",
                    "B2bGoogleTagManager"
                );
            }
        }
    }

    @wire(CartItemsAdapter, { cartStateOrId: "current" })
    async getCartItems({ data, error }) {
        if (data) {
            try {
                this.cartItems = data?.cartItems || [];
                this.cartSummary = data?.cartSummary || {};
                const newItems = [];
                const newProductIds = [];

                for (const item of this.cartItems) {
                    const productCode =
                        item.cartItem?.productDetails?.fields?.StockKeepingUnit;
                    const productId = item.cartItem?.productId;

                    const formattedItem = {
                        productId,
                        item_id: productCode?.split("-").slice(0, -1).join("-"),
                        item_name: item.cartItem.productDetails.fields?.Name,
                        item_brand: "Strem",
                        item_variant: productCode?.split("-").pop(),
                        quantity: item.cartItem.quantity,
                        price: item.cartItem?.unitAdjustedPriceWithItemAdj
                    };

                    newItems.push(formattedItem);
                    newProductIds.push(productId);
                }

                // Detect removed items
                const removedIds = this.previousCartItems.filter(
                    (prevId) => !newProductIds.includes(prevId)
                );
                if (removedIds.length) {
                    for (const removedId of removedIds) {
                        const removedItem = this.lastItemsSnapshot.find(
                            (i) => i.productId === removedId
                        );
                        if (removedItem) {
                            this.pushRemoveFromCart(removedItem);
                        }
                    }
                }

                this.previousCartItems = newProductIds;
                this.lastItemsSnapshot = [...newItems];
                this.items = newItems;

                this.trackEvent(this.pageTitle);
            } catch (err) {
                console.log('currentPageReference?.type' + ', ' + this.currentPageReference?.type + ', ' + this.currentPageReference?.attributes?.name + ', ' + this.currentPageReference?.state?.pageTitle);
                console.error("Error in processing cart items:", err);
                if (
                    (this.currentPageReference?.type === "comm__namedPage" &&
                        this.currentPageReference?.attributes?.name === "Current_Cart") ||
                    this.currentPageReference?.state?.pageTitle === "cart"
                ) {
                    const logMsg =
                        (err?.message || JSON.stringify(err)) +
                        ' , ' +
                        JSON.stringify(data);
                    this.logErrorToRecord(
                        logMsg,
                        "getCartItems",
                        "B2bGoogleTagManager"
                    );
                }
            }
        } else if (error) {
            console.error("Error in getCartItems : ", error);
            if (
                (this.currentPageReference?.type === "comm__namedPage" &&
                    this.currentPageReference?.attributes?.name === "Current_Cart") ||
                this.currentPageReference?.state?.pageTitle === "cart"
            ) {
                this.logErrorToRecord(
                    JSON.stringify(error),
                    "getCartItems",
                    "B2bGoogleTagManager"
                );
            }
        }
    }

    @wire(OrderSummaryLookupDataAdapter, {
        orderSummaryIdOrRefNumber: "$orderNumber",
        fields: ORDERSUMMARYFIELDS
    })
    async getOrderSummaryData({ data, error }) {
        if (!this.orderNumber) {
            console.log("Waiting for order number...");
            return;
        }

        this.hasOrderNumberInitialized = true;

        if (data) {
            try {
                this.orderSummary = data;

                console.log("#ordersummary", JSON.stringify(this.orderSummary));
                this.orderItems = this.orderSummary.deliveryGroups[0].lineItems;
                this.items = [];

                if (this.orderItems.length > 0) {
                    const itemsWithCategories = await Promise.all(
                        this.orderItems.map(async (item) => {
                            if (item.type === "Product") {
                                const productCode =
                                    item.product?.fields?.StockKeepingUnit?.text;
                                console.log(productCode);
                                const itemVariant = productCode.split("-").pop();
                                return {
                                    item_id: productCode?.split("-").slice(0, -1).join("-"),
                                    item_name: item.product.fields?.Name?.text,
                                    item_variant: itemVariant,
                                    item_brand: "Strem",
                                    price: item?.fields?.ListPrice?.text,
                                    quantity: item?.fields?.Quantity?.text
                                };
                            }
                        })
                    );
                    this.items = itemsWithCategories;
                }

                if (this.pageTitle) {
                    this.trackEvent(this.pageTitle);
                }
            } catch (err) {
                console.error("Error in processing order summary:", err);

                // Log only if we already had order number initialized before
                if (this.hasOrderNumberInitialized) {
                    this.logErrorToRecord(
                        err?.message || JSON.stringify(err),
                        "getOrderSummaryData",
                        "B2bGoogleTagManager"
                    );
                }
            }
        } else if (error) {
            console.error("Error in getOrderSummaryData : ", error);

            // Log only if we already had order number initialized before
            if (this.hasOrderNumberInitialized) {
                this.logErrorToRecord(
                    JSON.stringify(error),
                    "getOrderSummaryData",
                    "B2bGoogleTagManager"
                );
            }
        }
    }

    // ---------------- TRACKING HELPERS ----------------

    async trackEventViewItem() {
        try {
            const product = this.productData?.fields || {};
            const variant =
                this.productData?.variationAttributeSet?.attributes?.Unit_Size__c || "";
            const categoryString = await this.getCategoryNames(this.currentRecordId);
            const categories = (categoryString || "").split(",").map((c) => c.trim());

            const productDetails = {
                item_id: product.ProductCode,
                item_name: product.Name,
                item_variant: variant,
                affiliation: "Strem Catalog",
                item_brand: "Strem",
                item_category: categories[0] || "",
                item_category2: categories[1] || "",
                item_category3: categories[2] || "",
                item_category4: categories[3] || "",
                item_category5: categories[4] || ""
            };

            window.dataLayer = window.dataLayer || [];
            window.dataLayer.push({ event: "view_item", ecommerce: null });
            window.dataLayer.push({
                event: "view_item",
                ecommerce: { items: [productDetails] }
            });
            console.log("GA - View Item Event Pushed:", { productDetails });
        } catch (error) {
            console.error("Error in trackEventViewItem:", error);
            this.logErrorToRecord(
                error?.message || JSON.stringify(error),
                "trackEventViewItem",
                "B2bGoogleTagManager"
            );
        }
    }

    initializeEventListenerAddtoCart() {
        if (!this.cartEventAdded) {
            this.trackAddToCart = this.trackAddToCart.bind(this);
            window.addEventListener("addproducttocart", this.trackAddToCart);
            this.cartEventAdded = true;
        }
    }

    trackAddToCart = debounce(async () => {
        try {
            const product = this.productData?.fields || {};
            const variant =
                this.productData?.variationAttributeSet?.attributes?.Unit_Size__c || "";
            const categoryString = await this.getCategoryNames(this.currentRecordId);
            const categories = (categoryString || "").split(",").map((c) => c.trim());

            const productDetails = {
                item_id: product.ProductCode,
                item_name: product.Name,
                item_variant: variant,
                affiliation: "Strem Catalog",
                item_brand: "Strem",
                item_category: categories[0] || "",
                item_category2: categories[1] || "",
                item_category3: categories[2] || "",
                item_category4: categories[3] || "",
                item_category5: categories[4] || ""
            };

            window.dataLayer = window.dataLayer || [];
            window.dataLayer.push({ event: "add_to_cart", ecommerce: null });
            window.dataLayer.push({
                event: "add_to_cart",
                ecommerce: { items: [productDetails] }
            });

            console.log("## GA - Add to Cart Event: ", window.dataLayer);
        } catch (error) {
            console.error("Error in trackAddToCart:", error);
            this.logErrorToRecord(
                error?.message || JSON.stringify(error),
                "trackAddToCart",
                "B2bGoogleTagManager"
            );
        }
    }, 300);

    async pushRemoveFromCart(removedItem) {
        try {
            const product = removedItem || {};
            const variant = product.item_variant || "";
            let categories = [];

            if (product.productId) {
                const categoryString = await this.getCategoryNames(product.productId);
                categories = (categoryString || "").split(",").map((c) => c.trim());
            }

            const productDetails = {
                item_id: product.item_id || product.ProductCode || "",
                item_name: product.item_name || product.Name || "",
                item_variant: variant,
                affiliation: "Strem Catalog",
                item_brand: product.item_brand || "Strem",
                item_category: categories[0] || "",
                item_category2: categories[1] || "",
                item_category3: categories[2] || "",
                item_category4: categories[3] || "",
                item_category5: categories[4] || "",
                quantity: product.quantity || 1,
                price: product.price || 0
            };

            window.dataLayer = window.dataLayer || [];
            window.dataLayer.push({
                event: "remove_from_cart",
                ecommerce: null
            });
            window.dataLayer.push({
                event: "remove_from_cart",
                ecommerce: { items: [productDetails] }
            });
            console.log("## GA - Remove from Cart Event: ", window.dataLayer);
        } catch (error) {
            console.error("Error in pushRemoveFromCart:", error);
            this.logErrorToRecord(
                error?.message || JSON.stringify(error),
                "pushRemoveFromCart",
                "B2bGoogleTagManager"
            );
        }
    }

    trackEvent(currentPage) {
        switch (currentPage) {
            case "Checkout":
                if (!this.checkoutEventAdded) {
                    this.trackEventCheckout();
                }
                break;
            case "Order Confirmation":
                if (!this.orderEventAdded) {
                    this.trackEventOrderConfirmation();
                }
                break;
            default:
                break;
        }
    }

    trackEventCheckout() {
        try {
            if (this.cartSummary?.currencyIsoCode) {
                window.dataLayer = window.dataLayer || [];
                window.dataLayer.push({ event: "begin_checkout", ecommerce: null });
                window.dataLayer.push({
                    event: "begin_checkout",
                    ecommerce: {
                        currency: this.cartSummary?.currencyIsoCode,
                        value: this.cartSummary?.grandTotalAmount,
                        items: this.items
                    }
                });
                this.checkoutEventAdded = true;
                console.log("GA - Begin Checkout Event:", window.dataLayer);
            }
        } catch (error) {
            console.error("Error in trackEventCheckout:", error);
            this.logErrorToRecord(
                error?.message || JSON.stringify(error),
                "trackEventCheckout",
                "B2bGoogleTagManager"
            );
        }
    }

    trackEventOrderConfirmation() {
        try {
            if (this.orderEventAdded) {
                console.log("Skipping duplicate Order Confirmation tracking.");
                return;
            }

            if (!this.orderSummary || !this.orderSummary.fields) {
                console.warn("Order summary not ready yet. Skipping tracking for now.");
                return;
            }

            window.dataLayer = window.dataLayer || [];
            window.dataLayer.push({ event: "purchase", ecommerce: null });
            window.dataLayer.push({
                event: "purchase",
                ecommerce: {
                    value: this.orderSummary.fields.GrandTotalAmount?.text,
                    tax: this.orderSummary.fields.TotalTaxAmount?.text,
                    shipping: this.orderSummary.fields.TotalAdjustedDeliveryAmount?.text,
                    currency: this.orderSummary?.currencyIsoCode,
                    coupon: this.orderSummary.fields.Promotions_Applied__c?.text,
                    items: this.items
                }
            });

            this.orderEventAdded = true;
            console.log("GA - Purchase Event:", window.dataLayer);
        } catch (error) {
            // Log only actual runtime errors (once)
            if (!this.orderErrorLogged) {
                this.orderErrorLogged = true;
                console.error("Error in trackEventOrderConfirmation:", error);
                this.logErrorToRecord(
                    error?.message || JSON.stringify(error),
                    "trackEventOrderConfirmation",
                    "B2bGoogleTagManager"
                );
            }
        }
    }

    disconnectedCallback() {
        window.removeEventListener("addproducttocart", this.trackAddToCart);
    }

    getCategoryNames(productId) {
        if (!productId) return "";
        return getCategories({ productId })
            .then((result) => {
                const names = result
                    .map((cat) => cat?.ProductCategory?.Name?.trim())
                    .filter((name) => name && name !== "Products");
                const uniqueNames = [...new Set(names)];
                return uniqueNames.join(", ");
            })
            .catch((error) => {
                console.error("getCategoryNames error:", error);
                this.logErrorToRecord(
                    JSON.stringify(error),
                    "getCategoryNames",
                    "B2bGoogleTagManager"
                );
                return "";
            });
    }

    async logErrorToRecord(exceptionMessage, methodName, className) {
        try {
            const fields = {};
            const exceptionMsg = (exceptionMessage ? exceptionMessage.toString() : 'Unknown error') +
                ' , ' +
                (window.dataLayer ? JSON.stringify(window.dataLayer) : '');
            fields[EXCEPTION_MESSAGE_FIELD.fieldApiName] = exceptionMsg.trim().substring(0, 32767);
            fields[METHOD_NAME_FIELD.fieldApiName] = methodName;
            fields[CLASS_NAME_FIELD.fieldApiName] = className;
            fields[INPUT_PARAMTER_FIELD.fieldApiName] = JSON.stringify(this.currentPageReference).trim().substring(0, 32767);

            const recordInput = {
                apiName: ASCENSUS_EXCEPTION_OBJECT.objectApiName,
                fields
            };

            await createRecord(recordInput);
            console.log("Exception logged in Ascensus_Custom_Exception__c");
        } catch (err) {
            console.error("Failed to log exception:", err);
        }
    }
}