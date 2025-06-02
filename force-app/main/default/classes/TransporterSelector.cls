// Ce code sert à sélectionner un transporteur pour une commande (Order) en fonction du pays de livraison et du type de client. Il retourne une liste de choix de transporteurs avec des infos comme : leur nom, le prix de livraison,le délai de livraison.

public with sharing class TransporterSelector {

    // "petite classe" qui sert à formater les données d’un transporteur.
    public class TransporterOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Id transporterId;
        @AuraEnabled public String transporterName;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Integer deliveryDays;

        public TransporterOption(String value, TransporterRate__c rate) {
            this.value = value;
            this.label = (rate.Transporter__r != null)
                ? rate.Transporter__r.Name + ' - ' + rate.Delivery_Time__c + ' days - ' + rate.Delivery_Price__c + '€'
                : 'Unknown Transporter';
            this.transporterId = rate.Transporter__c;
            this.transporterName = (rate.Transporter__r != null) ? rate.Transporter__r.Name : null;
            this.price = rate.Delivery_Price__c;
            this.deliveryDays = (rate.Delivery_Time__c != null) ? rate.Delivery_Time__c.intValue() : null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TransporterOption> getTransportOptions(Id orderId) {
        List<TransporterOption> options = new List<TransporterOption>();

        if (orderId == null) return options;

        Order ord;
        try {
            ord = [
                SELECT ShippingCountry, Account.Type_of_client__c
                FROM Order
                WHERE Id = :orderId
                LIMIT 1
            ];
        } catch (Exception e) {
            return options;
        }

        if (ord == null || String.isBlank(ord.ShippingCountry) || String.isBlank(ord.Account?.Type_of_client__c)) {
            System.debug('Données manquantes - ShippingCountry: ' + ord?.ShippingCountry + ', ClientType: ' + ord?.Account?.Type_of_client__c);

            return options;
        }

        String shippingCountry = ord.ShippingCountry;
        String clientType = ord.Account.Type_of_client__c;

        // Table de correspondance anglais ==> français
        Map<String, String> countryMap = new Map<String, String>{
        'Belgium' => 'Belgique',
        'France' => 'France',
        'Switzerland' => 'Suisse',
        'Luxembourg' => 'Luxembourg'
    };
  // Remplacer la valeur anglaise par la valeur française attendue dans les données custom
  String internalCountry = countryMap.get(shippingCountry);
    if (internalCountry ==null) {
        internalCountry = shippingCountry; // Garde la valeur originale si pas de correspondance
    }


        // On récupère tous les transporteurs disponibles pour ce pays et typeOfClient
        List<TransporterRate__c> rates = [
            SELECT Id, Transporter__c, Transporter__r.Name,Transporter__r.Client_Type__c, Delivery_Price__c, Delivery_Time__c, Clients_Type__c, Country__c
            FROM TransporterRate__c
            // WHERE Country__c = :shippingCountry
            WHERE Country__c = :internalCountry
            //   AND (Clients_Type__c = :clientType OR Clients_Type__c = 'Both')
            //   AND (Clients_Type__c = :clientType OR Clients_Type__c = 'Both'
            //   OR Clients_Type__c LIKE :('%' + clientType + '%'))
            ORDER BY Delivery_Price__c ASC
        ];

    // Filtrage par type de client (picklist multi-sélection)
    List<TransporterRate__c> filteredRates = new List<TransporterRate__c>();
    for (TransporterRate__c rate : rates) {
        if (rate.Transporter__r != null && rate.Transporter__r.Client_Type__c != null) {
            String transporterClientTypes = rate.Transporter__r.Client_Type__c;            
            // Pour une picklist multi-sélection, les valeurs sont séparées par des points-virgules
            List<String> clientTypesList = transporterClientTypes.split(';');
            Boolean matchFound = false;
            
            for (String type : clientTypesList) {
                if (type.trim().equalsIgnoreCase(clientType.trim())) {
                    matchFound = true;
                    break;
                }
            }
            
            if (matchFound) {
                filteredRates.add(rate);
                System.debug('✓ Transporteur retenu: ' + rate.Transporter__r.Name);
            } else {
                System.debug('✗ Transporteur exclu: ' + rate.Transporter__r.Name);
            }
        }
    }

        if (rates.isEmpty()) return options;

        TransporterRate__c cheapest = null;
        TransporterRate__c fastest = null;

        // On boucle sur les tarifs et on compare prix et délais ==> cheapest / fastest
        for (TransporterRate__c rate : rates) {
            if (cheapest == null || (rate.Delivery_Price__c != null && rate.Delivery_Price__c < cheapest.Delivery_Price__c)) {
                cheapest = rate;
            }
            if (fastest == null || (rate.Delivery_Time__c != null && rate.Delivery_Time__c < fastest.Delivery_Time__c)) {
                fastest = rate;
            }
        }

        // On retourne une liste d'objets TransporterOption
        Set<Id> addedIds = new Set<Id>();

        if (cheapest != null) {
            options.add(new TransporterOption('cheapest', cheapest));
            addedIds.add(cheapest.Id);
        }

        if (fastest != null && !addedIds.contains(fastest.Id)) {
            options.add(new TransporterOption('fastest', fastest));
            addedIds.add(fastest.Id);
        }

        // Ajout des autres transporteurs
        // for (TransporterRate__c rate : rates) {
            for (TransporterRate__c rate : filteredRates) {
                if (!addedIds.contains(rate.Id)) {
                // options.add(new TransporterOption(rate.Transporter__r != null ? rate.Transporter__r.Name : 'UnknownTransporter', rate));
                options.add(new TransporterOption(rate.Id, rate));
            }
        }
        System.debug('Options finales retournées: ' + options.size());

        return options;
    }
}
