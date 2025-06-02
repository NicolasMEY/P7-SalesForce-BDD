@isTest
private class AccountSelectorTest {

    @isTest
    static void testGetAccountById_returnsAccount() {

        // Créer un compte fictif
        Account acc = new Account(
            Name = 'Test Account',
            Type = 'Prospect',
            Industry = 'Technology',
            BillingCity = 'Paris',
            BillingCountry = 'France',
            Phone = '0102030405',
            Website = 'www.test.com',
            Type_of_client__c = 'Professionnel'
        );
        insert acc;

        // Appeler la méthode à tester
        Account result = AccountSelector.getAccountById(acc.Id);

        // Vérifier que l’account retourné est bien celui qu’on a inséré ==> cas positif
        System.assertNotEquals(null, result);
        System.assertEquals(acc.Id, result.Id);
        System.assertEquals('Test Account', result.Name);
    }

    @isTest
    static void testGetAccountById_withNullId() {
        // Appeler la méthode avec un ID null
        Account result = AccountSelector.getAccountById(null);

        // Vérifier que ça retourne bien null ==> cas négatif
        System.assertEquals(null, result);
    }
}