public with sharing class TransporterSelector {

    // Cette class interne sert à définir une structure d'objet qui sera utilisée pour représenter les options de transport.
    public class TransporterOption {
        @AuraEnabled public String optionName;
        @AuraEnabled public Id transporterId;
        @AuraEnabled public String transporterName;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Integer deliveryDays;

        public TransporterOption(String optionName, TransporterRate__c rate) {
            this.optionName = optionName;
            this.transporterId = rate.Transporter__c;
            this.transporterName = rate.Transporter__r.Name; // accès au champ Name (standard) de l'objet lié Transporter
            this.price = rate.Delivery_Price__c;
            this.deliveryDays = rate.Delivery_Time__c != null ? rate.Delivery_Time__c.intValue() : null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TransporterOption> getTransportOptions(Id accountId) { // cette méthode ==> afficher dynamiquement les choix de transport disponibles à l’utilisateur

        if (accountId == null) {
            return new List<TransporterOption>();
        }
        // Récupérer le pays de facturation du compte (pour filtrer)
        Account acc = [SELECT BillingCountry FROM Account WHERE Id = :accountId LIMIT 1];
        if (acc == null || String.isBlank(acc.BillingCountry)) {
            return new List<TransporterOption>();
        }
        String billingCountry = acc.BillingCountry;

        // Récupère tous les tarifs des transporteurs fltrés par pays et trie les résultats par prix croissant
        List<TransporterRate__c> rates = [
            SELECT Id, Transporter__c, Transporter__r.Name, Delivery_Price__c, Delivery_Time__c
            FROM TransporterRate__c
            WHERE Country__c = :billingCountry
            ORDER BY Delivery_Price__c ASC
        ];

        // Ces 2 variables vont contenir le tarif le moins cher et le plus rapide
        TransporterRate__c cheapest = null;
        TransporterRate__c fastest = null;

        for (TransporterRate__c rate : rates) {
            // "Si on n'a pas encore de tarif moins cher, ou si ce tarif a un prix plus bas que le moins cher actuel, alors on met à jour cheapest."
            if (cheapest == null || (rate.Delivery_Price__c != null && rate.Delivery_Price__c < cheapest.Delivery_Price__c)) {
                cheapest = rate;
            }
            //  Si le temps de livraison actuel est inférieur au plus rapide enregistré, on met à jour.
            if (fastest == null || (rate.Delivery_Time__c != null && rate.Delivery_Time__c < fastest.Delivery_Time__c)) {
                fastest = rate;
            }
        }

        // On crée une liste d’options à retourner : l’option "cheapest", l’option "fastest", si elle est différente de la moins chère (pour éviter un doublon)
        List<TransporterOption> options = new List<TransporterOption>();
        if (cheapest != null) options.add(new TransporterOption('cheapest', cheapest));
        if (fastest != null && fastest.Id != cheapest.Id) options.add(new TransporterOption('fastest', fastest));

        return options;
    }
}





// public with sharing class TransporterSelector {
//     public static Map<String, Object> getTransportOptions(String country, String clientType) {
//         // 1) Récupérer les tarifs compatibles
//         List<TransporterRate__c> allRates = [
//             SELECT Id, Country__c, Delivery_Price__c, Delivery_Time__c,
//                    Transporter__r.Client_Type__c
//             FROM TransporterRate__c
//             WHERE Country__c = :country
//         ];

//         List<TransporterRate__c> compatibleRates = new List<TransporterRate__c>();
//         for (TransporterRate__c rate : allRates) {
//             if (rate.Transporter__r.Client_Type__c == clientType || rate.Transporter__r.Client_Type__c == 'Tous') {
//                 compatibleRates.add(rate);
//             }
//         }

//         TransporterRate__c cheapest = null;
//         TransporterRate__c fastest = null;
//         Decimal minPrice = Decimal.valueOf(99999999);
//         Integer minTime = 2147483647; // Valeur max d’un Integer 32 bits

//         for (TransporterRate__c rate : compatibleRates) {
//             if (rate.Delivery_Price__c != null && rate.Delivery_Price__c < minPrice) {
//                 cheapest = rate;
//                 minPrice = rate.Delivery_Price__c;
//             }
//             if (rate.Delivery_Time__c != null && rate.Delivery_Time__c.intValue() < minTime) {
//                 fastest = rate;
//                 minTime = rate.Delivery_Time__c.intValue();
//             }
//         }

//         // 2) Récupérer les livraisons du même pays
//         List<Delivery__c> deliveries = [
//             SELECT Id, External_Transporter_ID__c, Country__c, Delivery_Price__c,
//                    Delivery_Time__c, Transporter__c
//             FROM Delivery__c
//             WHERE Country__c = :country
//         ];

//         // 3) Retourner les résultats dans une Map simple
//         Map<String, Object> results = new Map<String, Object>();
//         results.put('cheapest', cheapest);
//         results.put('fastest', fastest);
//         results.put('compatibleRates', compatibleRates);
//         results.put('deliveries', deliveries);

//         return results;
//     }
// }