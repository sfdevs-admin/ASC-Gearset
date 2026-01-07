/**
 * @description This is a controller class that redirects the user to the RD Portfolio Opportunity list view.
 * @Author Atrium - nipun.jain@atrium.ai
 * @date Mar 2025
 */
public class RdPortfolioRedirectController {

    /**
     * @description This method redirects the user to the RD Portfolio Opportunity list view.
     * @return PageReference
     */
    public static PageReference redirect () {
        String listViewUrl = '/lightning/o/Opportunity/list?filterName=' + System.Label.RDPortfolioOppListView;
        PageReference pgRedirect = new PageReference(listViewUrl);
        pgRedirect.setRedirect(true);
        return pgRedirect;
    }
}