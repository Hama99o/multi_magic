<template>
  <v-card-text>
    <v-form class="space-y-3">
      <v-text-field
        v-model="newPassword.title"
        label="title"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-text-field
        v-model="newPassword.username"
        label="Username"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-text-field
        v-model="newPassword.email"
        label="Email"
        variant="outlined"
        hide-details
        density="comfortable"
      ></v-text-field>

      <v-text-field
        v-model="newPassword.password"
        label="Password"
        :type="showPassword ? 'text' : 'password'"
        :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
        variant="outlined"
        density="comfortable"
        hide-details
        @click:append-inner="showPassword = !showPassword"
      >
      </v-text-field>

      <!-- Website Field -->
      <v-text-field
        v-model="newPassword.link"
        label="Website"
        variant="outlined"
        density="comfortable"
        hide-details
      ></v-text-field>

      <v-textarea
        v-model="newPassword.note"
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

const showPassword = ref(true);
const newPassword = ref({
  id: null,
  title: '',
  username: '',
  email: '',
  password: '',
  link: '',
  note: '',
});

onMounted(async () => {
  newPassword.value = props.password;
});

const emit = defineEmits(['update-password']);

const props = defineProps({
  password: {
    type: Object,
    default: { title: '', username: '', email: '', password: '', link: '', note: '' },
  },
});

watch(props, () => {
  newPassword.value = props.password;
});

watch(
  newPassword,
  () => {
    emit('update-password', newPassword.value);
  },
  { deep: true },
);
</script>
