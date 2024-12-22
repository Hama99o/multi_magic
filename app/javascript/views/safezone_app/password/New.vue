<template>
  <!-- Password Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="newPassword">
      <v-toolbar color="primary" prominent>
        <v-btn icon @click="dialog = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Create Password</v-toolbar-title>
      </v-toolbar>

      <v-card-item v-if="!isMobile && (newPassword.title || newPassword.link)">
        <div class="d-flex align-center gap-4">
          <v-avatar size="48" rounded="lg">
            <v-img
              :src="`https://www.google.com/s2/favicons?domain=${newPassword.link}&sz=64`"
              :alt="newPassword.title"
            ></v-img>
          </v-avatar>
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ newPassword.title }}
            </v-card-title>
            <v-card-subtitle class="pa-0">
              {{ newPassword.link }}
            </v-card-subtitle>
          </div>
        </div>
      </v-card-item>
      <PassswordInputs v-if="newPassword" :password="newPassword" @update-password="updatePasswordd"/>

      <v-card-actions class="mx-[16px] flex">
        <v-btn color="primary" variant="outlined" @click="savePassword"> Save </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';
import { useMobileStore } from "@/stores/mobile";
import PassswordInputs from "@/components/safezone_app/password/Inputs.vue";

const dialog = ref(false);
const showPassword = ref(true);
import { usepasswordstore } from '@/stores/safezone_app/password.store';

const props = defineProps({
  type: { type: 'new' },
});

const { newPassword } = storeToRefs(usepasswordstore());
const { createPassword, updatePassword } = usepasswordstore();
const { isMobile } = storeToRefs(useMobileStore());

const savePassword = async () => {
  // Implement edit functionality
  if (props.type === 'edit') {
    await updatePassword(newPassword.id, newPassword.value);
  } else {
    await createPassword(newPassword.value);
  }
  dialog.value = false;
};

const updatePasswordd = async (data = {}) => {
  newPassword.value = data;
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
