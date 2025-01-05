<template>
  <v-card-text>
    <v-form class="space-y-3">
      <v-text-field
        v-model="newCard.name"
        label="Title"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-text-field
        v-model="newCard.cardNumber"
        label="Card Number"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-text-field
        v-model="newCard.expiryDate"
        label="Expiry Date (MM/YY)"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-text-field
        v-model="newCard.cvv"
        label="CVV"
        :type="showCVV ? 'text' : 'password'"
        :append-inner-icon="showCVV ? 'mdi-eye-off' : 'mdi-eye'"
        variant="outlined"
        density="comfortable"
        hide-details
        @click:append-inner="showCVV = !showCVV"
      >
      </v-text-field>

      <v-text-field
        v-model="newCard.code"
        label="Code"
        :type="showCode ? 'text' : 'password'"
        :append-inner-icon="showCode ? 'mdi-eye-off' : 'mdi-eye'"
        variant="outlined"
        density="comfortable"
        hide-details
        @click:append-inner="showCode = !showCode"
      >
      </v-text-field>

      <v-select
        v-model="newCard.cardType"
        :items="cardTypes"
        label="Card Type"
        variant="outlined"
        item-value="key"
        density="comfortable"
        hide-details
      ></v-select>

      <v-textarea
        v-model="newCard.note"
        label="Notes"
        variant="outlined"
        rows="4"
        hide-details
      ></v-textarea>
    </v-form>
  </v-card-text>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';

const showCVV = ref(true);
const showCode = ref(true);
const newCard = ref({
  id: null,
  name: '',
  cardNumber: '',
  expiryDate: '',
  cvv: '',
  cardType: 'credit_card',
  note: '',
  code: '',
});

const cardTypes = [
  { title: 'Credit Card', key: 'credit_card' },
  { title: 'Debit Card', key: 'debit_card' },
];

onMounted(async () => {
  newCard.value = props.card;
});

const emit = defineEmits(['update-card']);

const props = defineProps({
  card: {
    type: Object,
    default: {
      title: '',
      cardNumber: '',
      expiryDate: '',
      cardType: 'credit_card',
      cvv: '',
      note: '',
      code: '',
    },
  },
});

watch(props, () => {
  newCard.value = props.card;
});

watch(
  newCard,
  () => {
    emit('update-card', newCard.value);
  },
  { deep: true },
);
</script>
