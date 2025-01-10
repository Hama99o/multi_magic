<template>
  <v-card-text>
    <v-form class="space-y-3">
      <v-text-field
        v-model="newCard.title"
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
        v-model="newCard.holderName"
        label="Cardholder Name"
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
const newCard = ref({
  id: null,
  title: '',
  cardNumber: '',
  holderName: '',
  expiryDate: '',
  cvv: '',
  note: '',
});

onMounted(async () => {
  newCard.value = props.card;
});

const emit = defineEmits(['update-card']);

const props = defineProps({
  card: {
    type: Object,
    default: { title: '', cardNumber: '', holderName: '', expiryDate: '', cvv: '', note: '' },
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
