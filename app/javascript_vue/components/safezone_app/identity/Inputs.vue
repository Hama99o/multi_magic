<template>
  <v-card-text>
    <v-form class="space-y-3">
      <v-select
        v-model="newIdentity.type"
        :items="identityTypes"
        label="Identity Type"
        variant="outlined"
        item-value="key"
        density="comfortable"
        hide-details
      ></v-select>

      <v-text-field
        v-model="newIdentity.documentNumber"
        label="Document Number"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-text-field
        v-model="newIdentity.issuedAt"
        label="Issued At"
        variant="outlined"
        density="comfortable"
        hide-details
        type="date"
      ></v-text-field>

      <v-text-field
        v-model="newIdentity.expiresAt"
        label="Expires At"
        variant="outlined"
        density="comfortable"
        hide-details
        type="date"
      ></v-text-field>

      <v-textarea
        v-model="newIdentity.note"
        label="Additional Data"
        variant="outlined"
        rows="4"
        hide-details
      ></v-textarea>
    </v-form>
  </v-card-text>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';

const newIdentity = ref({
  id: null,
  type: '',
  documentNumber: '',
  issuedAt: '',
  expiresAt: '',
  image: '',
  data: '',
});

const identityTypes = [
  { title: 'Passport', key: 'SafezoneApp::Identities::Passport' },
  { title: 'ID Card', key: 'SafezoneApp::Identities::IdCard' },
  { title: 'Driving License', key: 'SafezoneApp::Identities::DrivingLicense' },
];

onMounted(async () => {
  newIdentity.value = props.identity;
});

const emit = defineEmits(['update-identity']);

const props = defineProps({
  identity: {
    type: Object,
    default: {
      type: '',
      documentNumber: '',
      issuedAt: '',
      expiresAt: '',
      data: '',
    },
  },
});

watch(props, () => {
  newIdentity.value = props.identity;
});

watch(
  newIdentity,
  () => {
    emit('update-identity', newIdentity.value);
  },
  { deep: true },
);
</script>
