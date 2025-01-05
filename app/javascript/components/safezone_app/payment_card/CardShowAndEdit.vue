<template>
  <!-- Payment Card Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="selectedCard">
      <v-toolbar color="primary" prominent>
        <v-btn
          icon
          @click="
            dialog = false;
            isEdit = false;
          "
        >
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Payment card Details</v-toolbar-title>
      </v-toolbar>
      <v-card-item>
        <div class="d-flex align-center gap-4">
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ selectedCard.name }}
            </v-card-title>
          </div>
        </div>
      </v-card-item>

      <v-card-text v-if="!isEdit">
        <v-form class="space-y-3">
          <v-text-field
            v-if="selectedCard.cardNumber"
            v-model="selectedCard.cardNumber"
            label="Card Number"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="copyToClipboard(selectedCard.cardNumber)"
          ></v-text-field>

          <v-text-field
            v-if="selectedCard.expiryDate"
            v-model="selectedCard.expiryDate"
            label="Expiry Date"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            hide-details
            density="comfortable"
            @click:append-inner="copyToClipboard(selectedCard.expiryDate)"
          ></v-text-field>

          <v-text-field
            v-if="selectedCard.cvv"
            v-model="selectedCard.cvv"
            label="CVV"
            :type="showCVV ? 'text' : 'password'"
            readonly
            :append-inner-icon="showCVV ? 'mdi-eye-off' : 'mdi-eye'"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="showCVV = !showCVV"
          >
            <template #append>
              <v-icon
                icon="mdi-content-copy"
                class="ml-2"
                @click="copyToClipboard(selectedCard.cvv)"
              ></v-icon>
            </template>
          </v-text-field>

          <v-text-field
            v-if="selectedCard.cardType"
            v-model="cardTypeText"
            label="Card Type"
            readonly
            variant="outlined"
            density="comfortable"
            hide-details
          ></v-text-field>

          <v-textarea
            v-if="selectedCard.note"
            v-model="selectedCard.note"
            label="Notes"
            readonly
            variant="outlined"
            rows="4"
            hide-details
          ></v-textarea>
        </v-form>
      </v-card-text>

      <CardInputs
        v-if="isEdit && selectedCard"
        :card="selectedCard"
        @update-card="watchUpdateCard"
      />

      <v-card-actions class="mx-[16px] flex">
        <v-btn v-if="!isEdit" color="error" variant="outlined" @click="removeCard"> Delete </v-btn>
        <v-btn v-else color="primary" variant="outlined" @click="editMode"> Back to show </v-btn>
        <v-spacer></v-spacer>
        <v-btn v-if="!isEdit" color="primary" variant="outlined" @click="editMode"> Edit </v-btn>
        <v-btn v-else color="primary" variant="outlined" @click="editCard"> Save </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import { usePaymentCardStore } from '@/stores/safezone_app/payment_card.store';
import CardInputs from '@/components/safezone_app/payment_card/Inputs.vue';
import { usePopUpStore } from '@/stores/pop-up.store';
import { showToast } from '@/utils/showToast';

const { openPopUp, closePopUp } = usePopUpStore();
const props = defineProps({
  card: {
    type: Object,
    default: {
      name: '',
      cardNumber: '',
      expiryDate: '',
      cvv: '',
      cardType: 'credit_card',
      note: '',
    },
  },
});

const { deletePaymentCard, updatePaymentCard } = usePaymentCardStore();

const dialog = ref(false);
const showCVV = ref(false);
const selectedCard = ref(null);

const emit = defineEmits(['update-card']);

const isEdit = ref(false);

const cardTypes = [
  { title: 'Credit Card', key: 'credit_card' },
  { title: 'Debit Card', key: 'debit_card' },
];

const cardTypeText = ref('');

onMounted(async () => {
  selectedCard.value = props.card;
  cardTypeText.value =
    cardTypes.find((type) => type.key === selectedCard.value.cardType)?.title || '';
});

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    showToast(`Card data copied successfully`, 'info');
  } catch (err) {
    console.error('Failed to copy text: ', err);
  }
};

const editMode = () => {
  isEdit.value = !isEdit.value;
};

const removeCard = async () => {
  openPopUp({
    componentName: 'pop-up-validation',
    title: 'Are you sure you want to delete this card?',
    textClose: 'No, cancel',
    textConfirm: 'Yes, delete this card',
    textLoading: 'Deleting ...',
    icon: 'mdi-trash-can-outline',
    customClass: 'w-[400px]',
    showClose: false,
    async confirm() {
      try {
        await deletePaymentCard(selectedCard.value?.id);
        dialog.value = false;
        closePopUp();
        showToast(`Card deleted successfully`, 'warning');
      } catch (error) {
        showToast(`There was a problem deleting "${selectedCard.value?.name}".`, 'error');
      }
    },
  });
};

const editCard = async () => {
  await updatePaymentCard(selectedCard.value?.id, selectedCard.value);
  isEdit.value = false;
  dialog.value = false;
};

const watchUpdateCard = async (data) => {
  selectedCard.value = data;
  cardTypeText.value =
    cardTypes.find((type) => type.key === selectedCard.value.cardType)?.title || '';
};

watch(props, () => {
  selectedCard.value = props.card;
  cardTypeText.value =
    cardTypes.find((type) => type.key === selectedCard.value.cardType)?.title || '';
});

watch(
  selectedCard,
  () => {
    emit('update-card', selectedCard.value);
  },
  { deep: true },
);

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
