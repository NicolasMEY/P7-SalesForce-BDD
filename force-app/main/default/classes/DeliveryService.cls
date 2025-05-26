// On vérifie qu'on a bien un TransporterRate__c avant d'essayer de créer la livraison.

public class DeliveryService {
    public static void createDeliveryForOrder(Order order) {
        // SOQL pour récupérer les tarifs (TransporterRate__c) correspondant au transporteur lié à la commande.
        List<TransporterRate__c> rates = [
            SELECT Id, Transporter__c, Transporter__r.Name, Delivery_Price__c, Delivery_Time__c
            FROM TransporterRate__c
            WHERE Transporter__c = :order.Transporter__c
            LIMIT 1
        ];
        
        if (rates.isEmpty()) {
            System.debug('Aucun tarif de transport trouvé pour ce transporteur.');
            return;
        }
        
        // je mets ça à cause de LIMIT 1, on récupère le premier prix
        TransporterRate__c rate = rates[0];
        
        // création d'un objet Delivery
        Delivery__c delivery = new Delivery__c();
        delivery.Order__c = order.Id;
        delivery.Transporter__c = rate.Transporter__c;
        delivery.Delivery_Price__c = rate.Delivery_Price__c;
        delivery.Status__c = 'Preparing'; // statut initial

        insert delivery;
    }
}






