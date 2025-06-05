import { LightningElement, api, wire } from 'lwc';
import hasPermission from '@salesforce/customPermission/Can_Send_Order';
import saveTransporterChoice from '@salesforce/apex/OrderTransporterController.saveTransporterChoice';
import getTransportOptions from '@salesforce/apex/TransporterSelector.getTransportOptions';

export default class ChooseTransporter extends LightningElement {

    // Propriétés : 
    @api recordId;
    options = []; // radio buttons options
    otherTransporterOptions = []; // combobox options
    selectedOption = null;
    selectedComboValue = null;
    fastestOption = null;
    cheapestOption = null;
    hasPermission = hasPermission;

    // Getter utilisé dans le template pour afficher la combobox seulement si Other est sélectionné.
    get showComboBox() {
        return this.selectedOption === 'other';
    }

    @wire(getTransportOptions, { orderId: '$recordId' })
        wiredTransportOptions({ error, data }) {
    if (data) {
        console.log('Data received:', data);
        if (data.length > 0) {
    // On trouve les transporters FASTEST & CHEAPEST
    this.fastestTransporter = data.reduce((a, b) => (a.deliveryDays < b.deliveryDays ? a : b));
    this.cheapestTransporter = data.reduce((a, b) => (a.price < b.price ? a : b));
    // et on stocke leurs valeurs (IDs ou codes) pour les radio options
    this.fastestOption = this.fastestTransporter.value;
    this.cheapestOption = this.cheapestTransporter.value;

            // Options radio fixes : Fastest, Cheapest, Other
            this.options = [
                { label: 'Fastest', value: 'fastest' },
                { label: 'Cheapest', value: 'cheapest' },
                { label: 'Other', value: 'other' }
            ];

            // On filtre les transporteurs pour exclure les deux déjà proposés en radio. On génère les options de la combobox sous forme de liste.
            const excluded = new Set([this.fastestOption, this.cheapestOption]);
            this.otherTransporterOptions = data
                .filter(t => !excluded.has(t.value))
                .map(t => ({
                    label: t.label,
                    value: t.value
                }));
        } else {
            console.warn('Aucun transporteur trouvé.');
        }
    } else if (error) {
        this.options = [];
        this.otherTransporterOptions = [];
        console.error('Error fetching transport options:', error);
    }
    }

    handleChange(event) {
        this.selectedOption = event.target.value;
        if (this.selectedOption !== 'other') {
            this.selectedComboValue = null; // reset combo si autre option choisie
        }
    }

    handleComboChange(event) {
        this.selectedComboValue = event.detail.value;
    }

    handleSubmit() {
        if (!this.hasPermission) {
            alert('You do not have permission to submit an order.');
            return;
        }

        let choice = null;

        if (this.selectedOption === 'fastest') {
            choice = this.fastestOption;
        } else if (this.selectedOption === 'cheapest') {
            choice = this.cheapestOption;
        } else if (this.selectedOption === 'other') {
            if (!this.selectedComboValue) {
                alert('Please select a transporter.');
                return;
            }
            choice = this.selectedComboValue;
        } else {
            alert('Please select a delivery option.');
            return;
        }

        saveTransporterChoice({ orderId: this.recordId, choice })
            .then(() => {
                alert('Order submitted successfully!');
            })
            .catch(error => {
                console.error('Error submitting order:', error);
                alert('Error while submitting the order.');
            });
    }

    // Ajout du getter pour affichage dynamique des options
    get computedTransporter() {
        if (this.selectedOption === 'fastest' && this.fastestTransporter) {
            return this.fastestTransporter.label;
        }
        if (this.selectedOption === 'cheapest' && this.cheapestTransporter) {
            return this.cheapestTransporter.label;
        }
        if (this.selectedOption === 'other') {
            return this.otherTransporterOptions.find(opt => opt.value === this.selectedComboValue)?.label || '';
        }
        return '';
    }
}