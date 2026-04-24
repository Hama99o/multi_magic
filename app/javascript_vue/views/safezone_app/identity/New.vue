<template>
  <!-- Card Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="newIdentity">
      <v-toolbar color="primary" prominent>
        <v-btn icon @click="dialog = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Create identity</v-toolbar-title>
      </v-toolbar>

      <v-card-item v-if="!isMobile">
        <div class="d-flex align-center gap-4">
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ newIdentity.documentNumber }}
            </v-card-title>
          </div>
        </div>
      </v-card-item>
      <IdentityInputs
        v-if="newIdentity"
        :card="newIdentity"
        @update-card="watchUpdateCard"
        @update-identity="watchUpdateCard"
      />

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
import IdentityInputs from '@/components/safezone_app/identity/Inputs.vue';
import { useIdentityStore } from '@/stores/safezone_app/identity.store';

const dialog = ref(false);

const { newIdentity } = storeToRefs(useIdentityStore());
const { createIdentity } = useIdentityStore();

const { isMobile } = storeToRefs(useMobileStore());

const saveCard = async () => {
  await createIdentity(newIdentity.value);
  dialog.value = false;
};

const watchUpdateCard = async (data = {}) => {
  newIdentity.value = data;
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
