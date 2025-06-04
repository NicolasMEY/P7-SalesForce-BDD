public class OrderService {
    public static void validateOrder(Order orderToValidate, Boolean isBeforeInsert, String statut) {
        if (orderToValidate.AccountId == null) return; // Utilisation du trigger ici et de la méthode orderToValidate

        Account account = AccountSelector.getAccountById(orderToValidate.AccountId);
        if (account == null) return;

        // On ne peut pas valider les OrderItem en before insert (pas encore d'Id)
        if (isBeforeInsert) {
            return;
        }
        
        List<OrderItem> items = [
            SELECT Id
            FROM OrderItem
            WHERE OrderId = :orderToValidate.Id
        ]; // On récupère les orderItem
        
        Integer itemCount = items.size(); // On compte le nb d'orderItem
        String clientType = account.Type_of_client__c;

        
        if (clientType == 'Particulier' && statut == 'Activated' && itemCount < 3) {
            orderToValidate.addError('Un particulier doit commander au moins 3 produits.');
        }
        else if (clientType == 'Professionnel' && statut == 'Activated' && itemCount < 5) {
            orderToValidate.addError('Un professionnel doit commander au moins 5 produits.');
        }
    }
}