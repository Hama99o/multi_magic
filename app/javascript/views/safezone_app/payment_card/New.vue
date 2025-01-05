<template>
  <!-- Card Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="newPaymentCard">
      <v-toolbar color="primary" prominent>
        <v-btn icon @click="dialog = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Create payment card</v-toolbar-title>
      </v-toolbar>

      <v-card-item v-if="!isMobile && (newPaymentCard.title || newPaymentCard.link)">
        <div class="d-flex align-center gap-4">
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ newPaymentCard.name }}
            </v-card-title>
          </div>
        </div>
      </v-card-item>
      <CardInputs v-if="newPaymentCard" :card="newPaymentCard" @update-card="watchUpdateCard" />

      <v-card-actions class="mx-[16px] flex">
        <v-btn color="primary" variant="outlined" @click="saveCard"> Save </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';
import { useMobileStore } from '@/stores/mobile';
import CardInputs from '@/components/safezone_app/payment_card/Inputs.vue';
import { usePaymentCardStore } from '@/stores/safezone_app/payment_card.store';

const dialog = ref(false);

const { newPaymentCard } = storeToRefs(usePaymentCardStore());
const { createPaymentCard } = usePaymentCardStore();

const { isMobile } = storeToRefs(useMobileStore());

const saveCard = async () => {
  await createPaymentCard(newPaymentCard.value);
  dialog.value = false;
};

const watchUpdateCard = async (data = {}) => {
  newPaymentCard.value = data;
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
