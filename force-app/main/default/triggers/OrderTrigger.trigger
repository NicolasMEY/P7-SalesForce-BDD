// Avant l'insertion (before insert) et avant la mise à jour (before update) d’un enregistrement Order, pour valider les données avant qu'elles ne soient sauvegardées en base.

trigger OrderTrigger on Order ( before update) {
    Boolean isBeforeInsert = Trigger.isInsert && Trigger.isBefore;
    
    for (Order ord : Trigger.new) {
        OrderService.validateOrder(ord, isBeforeInsert, ord.status); // Appel de la méthode validateOrder de la class OrderService
    }
}