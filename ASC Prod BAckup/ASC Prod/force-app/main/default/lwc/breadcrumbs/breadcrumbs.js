/**
 * @description       :
 * @author            : Mradul Maheshwari
 * @group             :
 * @last modified on  : 11-06-2025
 * @last modified by  : Mradul Maheshwari
 **/
import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getCategories from "@salesforce/apex/B2B_Breadcrumbs.getCategories";
import B2B_ParentCategoryId from "@salesforce/label/c.B2B_ParentCategoryId";
import B2B_AcceptedCategoryNames from "@salesforce/label/c.B2B_AcceptedCategoryNames";

export default class Breadcrumbs extends LightningElement {
  @track myBreadcrumbs = [];
  productId;
  isDataLoaded = false;
  defaultCategoryId = "/catalog/products/" + B2B_ParentCategoryId;

  @wire(CurrentPageReference)
  getPageRef(res) {
    this.productId = res.attributes.recordId;
  }

  renderedCallback() {
    if (this.productId && !this.isDataLoaded) {
      console.log("Breadcrumbs productId------- " + this.productId);
      getCategories({
        productId: this.productId
      })
        .then((result) => {
          const acceptedCategories = B2B_AcceptedCategoryNames.split(",").map(
            (s) => s.trim()
          );

          const rawBreadcrumbs = result
            .map((cat) => {
              const categoryName = cat?.ProductCategory?.Name?.trim();
              const parentCategoryName =
                cat?.ProductCategory?.ParentCategory?.Name?.trim();

              if (acceptedCategories.includes(categoryName)) {
                return {
                  name: categoryName,
                  categoryUrl: "/catalog/products/" + cat.ProductCategoryId,
                  createdDate: cat.ProductCategory.CreatedDate
                };
              }

              if (acceptedCategories.includes(parentCategoryName)) {
                return {
                  name: parentCategoryName,
                  categoryUrl:
                    "/catalog/products/" + cat.ProductCategory.ParentCategoryId,
                  createdDate: cat.ProductCategory.ParentCategory.CreatedDate
                };
              }

              return null;
            })
            .filter((breadcrumb) => breadcrumb !== null);

          // ✅ Sort by createdDate (ascending)
          rawBreadcrumbs.sort(
            (a, b) => new Date(a.createdDate) - new Date(b.createdDate)
          );

          // ✅ Deduplicate by category name preserving sorted order
          const uniqueBreadcrumbs = [];
          const seenNames = new Set();

          for (const breadcrumb of rawBreadcrumbs) {
            if (!seenNames.has(breadcrumb.name)) {
              seenNames.add(breadcrumb.name);
              uniqueBreadcrumbs.push(breadcrumb);
            }
          }
          uniqueBreadcrumbs.sort(
            (a, b) => new Date(a.createdDate) - new Date(b.createdDate)
          );

          // ✅ Now assign isLast correctly after sorting
          this.myBreadcrumbs = uniqueBreadcrumbs.map((b, i, arr) => ({
            ...b,
            isLast: i === arr.length - 1
          }));


          this.isDataLoaded = true;
        })
        .catch((error) => {
          console.log("Breadcrumbs error---- " + JSON.stringify(error));
        });
    }
  }

  handleNavigateTo(event) {
    event.preventDefault();
    const href = event.currentTarget.getAttribute("href");

    if (href) {
      window.location.assign(href);
    }
  }
}