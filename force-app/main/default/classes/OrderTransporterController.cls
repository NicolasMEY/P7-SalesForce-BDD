public class OrderTransporterController {
    @AuraEnabled // Appel depuis le LWC
    public static String saveTransporterChoice(Id orderId, String choice) { 

        // Récupérer la commande
        Order ord = [SELECT Id, AccountId, Transporter_Choice__c, Transporter__c FROM Order WHERE Id = :orderId LIMIT 1];
        if (ord.AccountId == null) { // je vérifie que la commande a un account lié
            throw new AuraHandledException('Commande sans compte lié.');
        }

        // Appel de la class interne "TransporterOption" de la class TransporterSelector ==> pour récupérer les options de transporteurs
        List<TransporterSelector.TransporterOption> options = TransporterSelector.getTransportOptions(ord.Id);
        TransporterSelector.TransporterOption selectedOption; // Je déclare une variable selectedOption de type TransporterOption pour stocker l’option choisie par l’utilisateur (si on la trouve dans la liste).
        
        // On boucle sur les options disponibles puis on compare le champ option.optionName avec la valeur envoyée par le client (choice). Une fois la correspondance trouvée, on la stocke dans selectedOption et on sort de la boucle.
        for (TransporterSelector.TransporterOption option : options) {
            if (option.value == choice) { 
                selectedOption = option;
                break;
            }
        }
        
        if (selectedOption == null) {
            throw new AuraHandledException('Choix de transporteur invalide.');
        }
        
        // Maj de la commande avec le transporter choisi
        ord.Transporter_Choice__c = selectedOption.transporterName;
        ord.Transporter__c = selectedOption.transporterId;
        update ord;

        // Créer la livraison liée à la commande avec le transporteur choisi 
        // ==> appel de la méthode createDeliveryForOrder de la class DeliveryService
        DeliveryService.createDeliveryForOrder(ord);
        
        return selectedOption.transporterName;
    }
}
