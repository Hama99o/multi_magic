<template>
  <!-- Identity Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="selectedIdentity">
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
        <v-toolbar-title>Identity Details</v-toolbar-title>
      </v-toolbar>
      <v-card-item>
        <div class="d-flex align-center gap-4">
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ getIdentityTypeText(selectedIdentity.type) }}
            </v-card-title>
          </div>
        </div>
      </v-card-item>

      <v-card-text v-if="!isEdit">
        <v-form class="space-y-3">
          <v-text-field
            v-if="selectedIdentity.documentNumber"
            v-model="selectedIdentity.documentNumber"
            label="Document Number"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="copyToClipboard(selectedIdentity.documentNumber)"
          ></v-text-field>

          <v-text-field
            v-if="selectedIdentity.issuedAt"
            v-model="selectedIdentity.issuedAt"
            label="Issued At"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            hide-details
            density="comfortable"
            @click:append-inner="copyToClipboard(selectedIdentity.issuedAt)"
          ></v-text-field>

          <v-text-field
            v-if="selectedIdentity.expiresAt"
            v-model="selectedIdentity.expiresAt"
            label="Expires At"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            hide-details
            density="comfortable"
            @click:append-inner="copyToClipboard(selectedIdentity.expiresAt)"
          ></v-text-field>

          <v-textarea
            v-if="selectedIdentity.note"
            v-model="selectedIdentity.note"
            label="Additional Data"
            readonly
            variant="outlined"
            rows="4"
            hide-details
          ></v-textarea>
        </v-form>
      </v-card-text>

      <IdentityInputs
        v-if="isEdit && selectedIdentity"
        :identity="selectedIdentity"
        @update-identity="watchUpdateIdentity"
      />

      <v-card-actions class="mx-[16px] flex">
        <v-btn v-if="!isEdit" color="error" variant="outlined" @click="removeIdentity">
          Delete
        </v-btn>
        <v-btn v-else color="primary" variant="outlined" @click="editMode"> Back to show </v-btn>
        <v-spacer></v-spacer>
        <v-btn v-if="!isEdit" color="primary" variant="outlined" @click="editMode"> Edit </v-btn>
        <v-btn v-else color="primary" variant="outlined" @click="editIdentity"> Save </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import { useIdentityStore } from '@/stores/safezone_app/identity.store';
import IdentityInputs from '@/components/safezone_app/identity/Inputs.vue';
import { usePopUpStore } from '@/stores/pop-up.store';
import { showToast } from '@/utils/showToast';

const { openPopUp, closePopUp } = usePopUpStore();
const props = defineProps({
  identity: {
    type: Object,
    default: {
      type: '',
      documentNumber: '',
      issuedAt: '',
      expiresAt: '',
      note: '',
    },
  },
});

const { deleteIdentity, updateIdentity } = useIdentityStore();

const dialog = ref(false);
const selectedIdentity = ref(null);

const emit = defineEmits(['update-identity']);

const isEdit = ref(false);

onMounted(async () => {
  selectedIdentity.value = props.identity;
});

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    showToast(`Identity data copied successfully`, 'info');
  } catch (err) {
    console.error('Failed to copy text: ', err);
  }
};

const editMode = () => {
  isEdit.value = !isEdit.value;
};

const removeIdentity = async () => {
  openPopUp({
    componentName: 'pop-up-validation',
    title: 'Are you sure you want to delete this identity?',
    textClose: 'No, cancel',
    textConfirm: 'Yes, delete this identity',
    textLoading: 'Deleting ...',
    icon: 'mdi-trash-can-outline',
    customClass: 'w-[400px]',
    showClose: false,
    async confirm() {
      try {
        await deleteIdentity(selectedIdentity.value?.id);
        dialog.value = false;
        closePopUp();
        showToast(`Identity deleted successfully`, 'warning');
      } catch (error) {
        showToast(`There was a problem deleting the identity.`, 'error');
      }
    },
  });
};

const editIdentity = async () => {
  await updateIdentity(selectedIdentity.value?.id, selectedIdentity.value);
  isEdit.value = false;
  dialog.value = false;
};

const watchUpdateIdentity = async (data) => {
  selectedIdentity.value = data;
};

watch(props, () => {
  selectedIdentity.value = props.identity;
});

watch(
  selectedIdentity,
  () => {
    emit('update-identity', selectedIdentity.value);
  },
  { deep: true },
);

const getIdentityTypeText = (type) => {
  switch (type) {
    case 'SafezoneApp::Identities::Passport':
      return 'Passport';
    case 'SafezoneApp::Identities::IdCard':
      return 'ID Card';
    case 'SafezoneApp::Identities::DrivingLicense':
      return 'Driving License';
    default:
      return type;
  }
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
