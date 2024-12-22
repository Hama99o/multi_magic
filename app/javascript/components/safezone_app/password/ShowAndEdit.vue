<template>
  <!-- Password Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="selectedPassword">
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
        <v-toolbar-title>Password Details</v-toolbar-title>
      </v-toolbar>

      <v-card-item>
        <div class="d-flex align-center gap-4">
          <v-avatar size="48" rounded="lg">
            <v-img
              v-if="selectedPassword.link"
              :src="`https://www.google.com/s2/favicons?domain=${selectedPassword.link}&sz=64`"
              :alt="selectedPassword.title"
            ></v-img>
          </v-avatar>
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ selectedPassword.title }}
            </v-card-title>
            <v-card-subtitle class="pa-0">
              {{ selectedPassword.link }}
            </v-card-subtitle>
          </div>
        </div>
      </v-card-item>

      <v-card-text v-if="!isEdit">
        <v-form class="space-y-3">
          <v-text-field
            v-if="selectedPassword.username"
            v-model="selectedPassword.username"
            label="Username"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="copyToClipboard(selectedPassword.username)"
          ></v-text-field>

          <v-text-field
            v-if="selectedPassword.email"
            v-model="selectedPassword.email"
            label="Email"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            hide-details
            density="comfortable"
            @click:append-inner="copyToClipboard(selectedPassword.email)"
          ></v-text-field>

          <v-text-field
            v-if="selectedPassword.password"
            v-model="selectedPassword.password"
            label="Password"
            :type="showPassword ? 'text' : 'password'"
            readonly
            :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="showPassword = !showPassword"
          >
            <template #append>
              <v-icon
                icon="mdi-content-copy"
                class="ml-2"
                @click="copyToClipboard(selectedPassword.password)"
              ></v-icon>
            </template>
          </v-text-field>

          <div v-if="selectedPassword.password" class="my-4">
            <div class="d-flex justify-space-between mb-2 text-sm">
              <span>Password strength</span>
              <span class="text-success">Strong</span>
            </div>
            <v-progress-linear
              model-value="85"
              color="success"
              height="8"
              rounded
            ></v-progress-linear>
          </div>

          <!-- Website Field -->
          <v-text-field
            v-if="selectedPassword.link"
            v-model="selectedPassword.link"
            label="Website"
            readonly
            append-inner-icon="mdi-open-in-new"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="openWebsite(selectedPassword.link)"
          ></v-text-field>

          <v-textarea
            v-if="selectedPassword.note"
            v-model="selectedPassword.note"
            label="Notes"
            readonly
            variant="outlined"
            rows="4"
            hide-details
          ></v-textarea>
        </v-form>
      </v-card-text>

      <PassswordInputs
        v-if="isEdit && selectedPassword"
        :password="selectedPassword"
        @update-password="watchUpdatePassword"
      />

      <v-card-actions class="mx-[16px] flex">
        <v-btn v-if="!isEdit" color="error" variant="outlined" @click="removePassword">
          Delete
        </v-btn>
        <v-btn v-else color="primary" variant="outlined" @click="editMode"> Back to show </v-btn>
        <v-spacer></v-spacer>
        <v-btn v-if="!isEdit" color="primary" variant="outlined" @click="editMode"> Edit </v-btn>
        <v-btn v-else color="primary" variant="outlined" @click="editPassword"> Save </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import { usepasswordstore } from '@/stores/safezone_app/password.store';
import PassswordInputs from '@/components/safezone_app/password/Inputs.vue';
import { usePopUpStore } from '@/stores/pop-up.store';
import { showToast } from '@/utils/showToast';

const { openPopUp, closePopUp } = usePopUpStore();
const props = defineProps({
  password: {
    type: Object,
    default: { title: '', username: '', email: '', password: '', link: '', note: '' },
  },
});

const { deletePassword, updatePassword } = usepasswordstore();

const dialog = ref(false);
const showPassword = ref(false);
const selectedPassword = ref(null);

const emit = defineEmits(['update-password']);

const isEdit = ref(false);

onMounted(async () => {
  selectedPassword.value = props.password;
});

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    // Add Vuetify snackbar notification here
  } catch (err) {
    console.error('Failed to copy text: ', err);
  }
};

const editMode = () => {
  isEdit.value = !isEdit.value;
};

const removePassword = async () => {
  openPopUp({
    componentName: 'pop-up-validation',
    title: 'Are you sure you want to delete this password ?',
    textClose: 'No, cancel',
    textConfirm: 'Yes, delete this password',
    textLoading: 'Deleting ...',
    icon: 'mdi-trash-can-outline',
    customClass: 'w-[400px]',
    showClose: false,
    async confirm() {
      try {
        await deletePassword(selectedPassword.value?.id);
        dialog.value = false;
        closePopUp();
        showToast(`Password delete successfully`, 'warning');
      } catch (error) {
        showToast(`There was a problem deleting "${selectedPassword.value?.title}".`, 'error');
      }
    },
  });
};

const editPassword = async () => {
  await updatePassword(selectedPassword.value?.id, selectedPassword.value);
  isEdit.value = false;
  dialog.value = false;
};

const openWebsite = (url = '') => {
  if (url && !url.startsWith('http')) {
    url = `https://${url}`;
  }
  window.open(url, '_blank');
};

const watchUpdatePassword = async (data) => {
  selectedPassword.value = data;
};

watch(props, () => {
  selectedPassword.value = props.password;
});

watch(
  selectedPassword,
  () => {
    emit('update-password', selectedPassword.value);
  },
  { deep: true },
);

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
