import { LightningElement, api } from 'lwc';
import hasPermission from '@salesforce/customPermission/Can_Send_Order';
import saveTransporterChoice from '@salesforce/apex/OrderTransporterController.saveTransporterChoice';
// import getTransportOptions from '@salesforce/apex/TransporterSelector.getTransportOptions'; ..... à rajouter !!!!!!


export default class ChooseTransporter extends LightningElement {
    @api recordId; // id de l'Order puisque l'on passe une commande
    selectedOption = null; // Stocke l'option radio sélectionnée
    hasPermission = hasPermission; // Stocke la valeur importée pour simplifier l'accès dans le template

    options = [
        { label: 'Option la plus rapide', value: 'fastest' },
        { label: 'Option la moins chère', value: 'cheapest' }
    ]; // Choix à afficher dans le radio group

    handleChange(event) { // à la sélection d'un option radio
        this.selectedOption = event.target.value;
    } // Stocke l'option radio dans selectedOption

    handleSubmit() { // au clic
        if (!this.hasPermission) {
            alert("Vous n'avez pas la permission d'envoyer une commande.");
            return;
        } // Méthode déclenchée au clic sur le bouton "Envoyer la commande"
        if (!this.selectedOption) {
            alert("Veuillez sélectionner une option de livraison.");
            return;
        }
        // Appel de la méthode Apex saveTransporterChoice ; logique d’envoi ou de sauvegarde du transporteur
        saveTransporterChoice({ orderId: this.recordId, choice: this.selectedOption })
        .then(() => {
            alert("Commande envoyée avec succès !");
        })
        .catch(error => {
            console.error(error);
            alert("Erreur lors de l'envoi de la commande.");
        });
    }
}