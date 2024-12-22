<template>
  <!-- Password Detail Dialog -->
  <v-dialog v-model="dialog" max-width="500" fullscreen-sm>
    <v-card v-if="selectedPassword">
      <v-toolbar color="primary" prominent>
        <v-btn icon @click="dialog = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Password Details</v-toolbar-title>
      </v-toolbar>

      <v-card-item>
        <div class="d-flex align-center gap-4">
          <v-avatar size="48" rounded="lg">
            <v-img
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

      <v-card-text>
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

          <!-- Website Field -->
          <v-text-field
            v-model="selectedPassword.link"
            label="Website"
            readonly
            append-inner-icon="mdi-open-in-new"
            variant="outlined"
            density="comfortable"
            hide-details
            @click:append-inner="openWebsite(selectedPassword.link)"
          ></v-text-field>
          <div class="my-4">
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

          <v-textarea
            v-model="selectedPassword.note"
            label="Notes"
            readonly
            variant="outlined"
            rows="4"
            hide-details
          ></v-textarea>
        </v-form>
      </v-card-text>

      <v-card-actions class="mx-[16px] flex">
        <v-btn color="error" variant="outlined" @click="deletePassword"> Delete </v-btn>
        <v-spacer></v-spacer>
        <v-btn color="primary" variant="outlined" @click="editPassword"> Edit </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';
const dialog = ref(false);
const showPassword = ref(false);
const selectedPassword = ref(null);

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text);
    // Add Vuetify snackbar notification here
  } catch (err) {
    console.error('Failed to copy text: ', err);
  }
};

const editPassword = () => {
  // Implement edit functionality
  console.log('Edit password:', selectedPassword.value);
};

const deletePassword = () => {
  // Implement delete functionality
  console.log('Delete password:', selectedPassword.value);
  dialog.value = false;
};

const openWebsite = (url) => {
  if (url && !url.startsWith('http')) {
    url = `https://${url}`;
  }
  window.open(url, '_blank');
};

// Expose dialog to be controlled from parent component
defineExpose({
  dialog,
});
</script>
