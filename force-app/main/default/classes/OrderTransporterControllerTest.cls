@isTest
private class OrderTransporterControllerTest {
    @isTest
    static void testSaveTransporterChoice_success() {
        // Création d’un compte avec le type de client défini
        Account acc = new Account(Name = 'Test Account', Type_of_client__c = 'Particulier');
        insert acc;

        // Création d’un transporteur avec le type de client défini
        Transporter__c transporter = new Transporter__c(Name = 'Chronopost', Client_Type__c = 'Particulier');
        insert transporter;

        // Création d’un tarif de livraison pour ce transporteur avec le pays défini
        TransporterRate__c rate = new TransporterRate__c(
            Transporter__c = transporter.Id,
            Delivery_Price__c = 9.99,
            Delivery_Time__c = 48,
            Country__c = 'France'
        );
        insert rate;

        // Création d’une commande liée au compte avec le pays de livraison défini
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            ShippingCountry = 'France'
        );
        insert ord;

        Test.startTest();
        // Récupération des options de transporteur
        List<TransporterSelector.TransporterOption> options = TransporterSelector.getTransportOptions(ord.Id);
        System.debug('Options: ' + options);

        // Vérification qu'au moins une option est retournée
        System.assert(!options.isEmpty(), 'Aucune option de transporteur trouvée');

        // Utilisation de la première option retournée
        String choice = options[0].value;

        // Appel de la méthode à tester avec le choix obtenu
        String result = OrderTransporterController.saveTransporterChoice(ord.Id, choice);
        Test.stopTest();

        // Vérification que le résultat correspond au nom du transporteur
        System.assertEquals('Chronopost', result);
    }
}