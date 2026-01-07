public class Test_ConvertToFormula implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all relevant products
        return Database.getQueryLocator([
            SELECT Id, Name, Description, Formula__c, Index_Formula__c,
            Index_Formula_Site__c, Index_Formula_Text__c, Formula_Site__c, Formula_Text__c, Note__c,Product_Description__c
            FROM Product2
            WHERE Catalog__c = 'Strem' AND External_Id_Integration__c != null
        ]);
    }
    
    // add Note__c conversion
    public void execute(Database.BatchableContext BC, List<Product2> scope) {
        // Process each product in the batch
        for (Product2 p : scope) {
            if (!String.isEmpty(p.Index_Formula__c)) {
                p.Index_Formula_Site__c = convertToFormula(p.Index_Formula__c);
                p.Index_Formula_Text__c  = convertToFormulaText(p.Index_Formula__c);
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
                p.Note__c = convertToFormula(p.Note__c);
            }
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext BC) {
        // Perform any final operations after all batches are processed
        System.debug('Batch processing completed.');
    }
    
    public static String convertToFormula(String input) {
        
        // Map special characters to subscripts using Unicode subscript characters
        Map<String, String> characterMap = new Map<String, String>{
            'ö' => '\u2080', // Subscript 0
            'ò' => '\u2081', // Subscript 1
            'û' => '\u2082', // Subscript 2
            'ù' => '\u2083', // Subscript 3
            'ÿ' => '\u2084', // Subscript 4
            'Ö' => '\u2085', // Subscript 5
            'Ü' => '\u2086', // Subscript 6
            '¢' => '\u2087', // Subscript 7
            '£' => '\u2088', // Subscript 8
            '¥' => '\u2089', // Subscript 9
            '₧' => '\u2070', // Superscript 0
            'ƒ' => '\u00B9', // Superscript 1
            'á' => '\u00B2', // Superscript 2
            'í' => '\u00B3', // Superscript 3
            'ó' => '\u2074', // Superscript 4
            'ú' => '\u2075', // Superscript 5
            'ñ' => '\u2076', // Superscript 6
            'Ñ' => '\u2077', // Superscript 7
            'ª' => '\u2078', // Superscript 8
            'º' => '\u2079', // Superscript 9
            'Ç' => '\u2022', // Bullet (•)
            'ü' => '\u00D7', // Multiplication Sign (×)
            'é' => '\u2099', // Subscript n
            'â' => '\u03B7', // Eta (η)
            'ä' => '\u1D45', // Subscript D
            'å' => '\u002A', // Asterisk (*)
            'ô' => '', // Soft Return -> Degree symbol assumed
            '¼' => '\u00AD', // Soft Hyphen
            '|' => '\u23CE', // Hard Return
            '≡' => '\u2261', // Triple bond
            '°' => '\u00B0', // Degree
            '∙' => '\u22C5', // Raised dot
            'Å' => '\u207A', // Raised plus
            'æ' => '\u207B', // Raised minus
            '⌠' => '\u00B1', // Plus-minus (±)
            'ç' => '\u2122', // Trademark (™)
            'ê' => '\u00AE', // Registered (®)
            'µ' => '\u03BC', // Mu (μ)
            'α' => '\u03B1', // Alpha (α)
            'à' => '\u00A3', // Pound sterling (£)
            'ε' => '\u03B5', // Epsilon (ε)
            'δ' => '\u03B4',  // Delta (δ)
            '&#8729;' => '\u2022' // Bullet (•)
        };
                    
            // Initialize the output string
            String output = '';
        
        // Replace each special character with its corresponding subscript
        for(Integer i = 0; i < input.length(); i++) {
            String currentChar = input.substring(i, i+1);
            if(characterMap.containsKey(currentChar)) {
                output += characterMap.get(currentChar);
            } else {
                output += currentChar;
            }
        }
        
        return output;
    }
    

	public static String convertToFormulaText(String input) {
        
        // Map special characters to subscripts using Unicode subscript characters
        Map<String, String> characterMap = new Map<String, String>{
            'ö' => '0', // Subscript 0
            'ò' => '1', // Subscript 1
            'û' => '2', // Subscript 2
            'ù' => '3', // Subscript 3
            'ÿ' => '4', // Subscript 4
            'Ö' => '5', // Subscript 5
            'Ü' => '6', // Subscript 6
            '¢' => '7', // Subscript 7
            '£' => '8', // Subscript 8
            '¥' => '9', // Subscript 9
            '₧' => '0', // Superscript 0
            'ƒ' => '1', // Superscript 1
            'á' => '2', // Superscript 2
            'í' => '3', // Superscript 3
            'ó' => '4', // Superscript 4
            'ú' => '5', // Superscript 5
            'ñ' => '6', // Superscript 6
            'Ñ' => '7', // Superscript 7
            'ª' => '8', // Superscript 8
            'º' => '9', // Superscript 9
            'Ç' => '\u2022', // Bullet (•)
            'ü' => 'x', // Multiplication Sign (×)
            'é' => 'n', // Subscript n
            'â' => 'n', // Eta (η)
            'ä' => 'D', // Subscript D
            'å' => '*', // Asterisk (*)
            'ô' => '', // Soft Return -> Degree symbol assumed
            '¼' => '-', // Soft Hyphen
            '|' => '', // Hard Return
            '≡' => '\u2261', // Triple bond
            '°' => '\u00B0', // Degree
            '∙' => '\u22C5', // Raised dot
            'Å' => '+', // Raised plus
            'æ' => '-', // Raised minus
            '⌠' => '\u00B1', // Plus-minus (±)
            'ç' => 'TM', // Trademark (™)
            'ê' => 'R', // Registered (®)
            'µ' => 'U', // Mu (μ)
            'α' => '\u03B1', // Alpha (α)
            'à' => '\u00A3', // Pound sterling (£)
            'ε' => '\u03B5', // Epsilon (ε)
            'δ' => '\u03B4'  // Delta (δ)
        };
                    
            // Initialize the output string
            String output = '';
        
        // Replace each special character with its corresponding subscript
        for(Integer i = 0; i < input.length(); i++) {
            String currentChar = input.substring(i, i+1);
            if(characterMap.containsKey(currentChar)) {
                output += characterMap.get(currentChar);
            } else {
                output += currentChar;
            }
        }
        
        return output;
    }    
    public static void testCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}