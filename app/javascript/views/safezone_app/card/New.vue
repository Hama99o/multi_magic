<template>
  <!-- Card Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="newCard">
      <v-toolbar color="primary" prominent>
        <v-btn icon @click="dialog = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Create Card</v-toolbar-title>
      </v-toolbar>

      <v-card-item v-if="!isMobile && (newCard.title || newCard.link)">
        <div class="d-flex align-center gap-4">
          <v-avatar size="48" rounded="lg">
            <v-img
              :src="`https://www.google.com/s2/favicons?domain=${newCard.link}&sz=64`"
              :alt="newCard.title"
            ></v-img>
          </v-avatar>
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ newCard.title }}
            </v-card-title>
            <v-card-subtitle class="pa-0">
              {{ newCard.link }}
            </v-card-subtitle>
          </div>
        </div>
      </v-card-item>
      <CardInputs v-if="newCard" :card="newCard" @update-card="watchUpdateCard" />

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
import CardInputs from '@/components/safezone_app/card/Inputs.vue';

const dialog = ref(false);
import { useCardStore } from '@/stores/safezone_app/card.store';

const { newCard } = storeToRefs(useCardStore());
const { createCard } = useCardStore();
const { isMobile } = storeToRefs(useMobileStore());

const saveCard = async () => {
  await createCard(newCard.value);
  dialog.value = false;
};

const watchUpdateCard = async (data = {}) => {
  newCard.value = data;
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
