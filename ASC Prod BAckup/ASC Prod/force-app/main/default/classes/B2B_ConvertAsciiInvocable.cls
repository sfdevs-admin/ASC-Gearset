public class B2B_ConvertAsciiInvocable {
    
    public class Request {
        @InvocableVariable(required=true)
        public Product2 product;
    }

    @InvocableMethod(label='Convert Product Formulas' description='Convert special characters in product formula fields')
    public static void convertProductFormulas(List<Request> requests) {
        List<Product2> productsToUpdate = new List<Product2>();

        for (Request req : requests) {
            Product2 p = req.product;
            if (!String.isEmpty(p.Index_Formula__c)) {
                p.Index_Formula_Site__c = convertToFormula(p.Index_Formula__c);
                p.Index_Formula_Text__c = convertToFormulaText(p.Index_Formula__c);
            }
            if (!String.isEmpty(p.Formula__c)) {
                p.Formula_Site__c = convertToFormula(p.Formula__c);
                p.Formula_Text__c = convertToFormulaText(p.Formula__c);
            }
            if (!String.isEmpty(p.Name)) {
                p.Name = convertToFormula(p.Name);
            }
            if (!String.isEmpty(p.Description)) {
                p.Description = convertToFormula(p.Description);
            }
            if (!String.isEmpty(p.Product_Description__c)) {
                p.Product_Description__c = convertToFormula(p.Product_Description__c);
            }
            if (!String.isEmpty(p.Note__c)) {
                System.debug('Note before: '+p.Note__c);
                p.Note__c = convertToFormula(p.Note__c);
                System.debug('Note after: '+p.Note__c);
            }
            if (!String.isEmpty(p.Density__c)) {
                p.Density_Site__c = convertToFormula(p.Density__c);
            }
            if (!String.isEmpty(p.Surface_Area__c)) {
                p.Surface_Area_Site__c = convertToFormula(p.Surface_Area__c);
            }
            productsToUpdate.add(p);
        }
        
        update productsToUpdate;
    }

    public static String convertToFormula(String input) {
        Map<String, String> characterMap = new Map<String, String>{
            'ö' => '\u2080', 'ò' => '\u2081', 'û' => '\u2082', 'ù' => '\u2083', 'ÿ' => '\u2084', 
            'Ö' => '\u2085', 'Ü' => '\u2086', '¢' => '\u2087', '£' => '\u2088', '¥' => '\u2089', 
            '₧' => '\u2070', 'ƒ' => '\u00B9', 'á' => '\u00B2', 'í' => '\u00B3', 'ó' => '\u2074', 
            'ú' => '\u2075', 'ñ' => '\u2076', 'Ñ' => '\u2077', 'ª' => '\u2078', 'º' => '\u2079', 
            'Ç' => '\u2022', 'ü' => '\u00D7', 'é' => '\u2099', 'â' => '\u03B7', 'ä' => '\u1D45', 
            'å' => '\u002A', 'ô' => '', '¼' => '\u00AD', '|' => '\u23CE', '≡' => '\u2261', 
            '°' => '\u00B0', '∙' => '\u22C5', 'Å' => '\u207A', 'æ' => '\u207B', '⌠' => '\u00B1', 
            'ç' => '\u2122', 'ê' => '\u00AE', 'µ' => '\u03BC', 'α' => '\u03B1', 'à' => '\u00A3', 
            'ε' => '\u03B5', 'δ' => '\u03B4', '&#8729;' => '\u2022'
        };

        String output = '';
        for(Integer i = 0; i < input.length(); i++) {
            String currentChar = input.substring(i, i+1);
            if(characterMap.containsKey(currentChar)) {
                output += characterMap.get(currentChar);
            } else {
                output += currentChar;
            }
        }
        System.debug('ConvertToFormula: '+output);
        return output;
    }

    public static String convertToFormulaText(String input) {
        Map<String, String> characterMap = new Map<String, String>{
            'ö' => '0', 'ò' => '1', 'û' => '2', 'ù' => '3', 'ÿ' => '4', 'Ö' => '5', 'Ü' => '6', 
            '¢' => '7', '£' => '8', '¥' => '9', '₧' => '0', 'ƒ' => '1', 'á' => '2', 'í' => '3', 
            'ó' => '4', 'ú' => '5', 'ñ' => '6', 'Ñ' => '7', 'ª' => '8', 'º' => '9', 'Ç' => '\u2022', 
            'ü' => 'x', 'é' => 'n', 'â' => 'n', 'ä' => 'D', 'å' => '*', 'ô' => '', '¼' => '-', 
            '|' => '', '≡' => '\u2261', '°' => '\u00B0', '∙' => '\u22C5', 'Å' => '+', 'æ' => '-', 
            '⌠' => '\u00B1', 'ç' => 'TM', 'ê' => 'R', 'µ' => 'U', 'α' => '\u03B1', 'à' => '\u00A3', 
            'ε' => '\u03B5', 'δ' => '\u03B4'
        };

        String output = '';
        for(Integer i = 0; i < input.length(); i++) {
            String currentChar = input.substring(i, i+1);
            if(characterMap.containsKey(currentChar)) {
                output += characterMap.get(currentChar);
            } else {
                output += currentChar;
            }
        }
        System.debug('ConvertToFormula: '+output);
        return output;
    }
}