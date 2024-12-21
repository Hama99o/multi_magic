<template>
  <Dashboard>
    <template #container>
      <div class="d-flex justify-space-between align-center mb-6 flex-wrap">
        <h2 class="text-2xl font-semibold mb-2 mb-sm-0">Passwords</h2>
        <v-btn
          color="primary"
          prepend-icon="mdi-plus"
          @click="showAddModal = true"
        >
          Add New
        </v-btn>
      </div>
      <!-- Passwords Section -->
      <v-row>
        <v-col v-for="password in passwords" :key="password.id" cols="12" sm="6" md="4" lg="3">
          <v-card
            variant="outlined"
            class="cursor-pointer hover:border-primary"
            @click="selectPassword(password)"
          >
            <v-card-item>
              <div class="d-flex align-center">
                <v-avatar size="40" rounded="lg" class="mr-4 bg-gray-100">
                  <v-img
                    :src="`https://www.google.com/s2/favicons?domain=${password.website}&sz=64`"
                    :alt="password.title"
                  ></v-img>
                </v-avatar>
                <div class="flex-grow-1">
                  <v-card-title class="pa-0 text-body-1 font-medium">
                    {{ password.title }}
                  </v-card-title>
                  <v-card-subtitle class="pa-0 text-gray-500">
                    {{ password.username }}
                  </v-card-subtitle>
                </div>
              </div>
              <div class="mt-2 text-sm text-gray-400">Last used {{ password.lastUsed }}</div>
            </v-card-item>
          </v-card>
        </v-col>
      </v-row>
    </template>
  </Dashboard>

  <!-- Password Detail Dialog -->
  <v-dialog v-model="showPasswordDetail" max-width="500" fullscreen-sm>
    <v-card v-if="selectedPassword">
      <v-toolbar v-if="$vuetify.display.smAndDown" color="primary" prominent>
        <v-btn icon @click="showPasswordDetail = false">
          <v-icon>mdi-close</v-icon>
        </v-btn>
        <v-toolbar-title>Password Details</v-toolbar-title>
      </v-toolbar>

      <v-card-item>
        <div class="d-flex align-center gap-4">
          <v-avatar size="48" rounded="lg" class="bg-gray-100">
            <v-img
              :src="`https://www.google.com/s2/favicons?domain=${selectedPassword.website}&sz=64`"
              :alt="selectedPassword.title"
            ></v-img>
          </v-avatar>
          <div>
            <v-card-title class="pa-0 text-xl font-semibold">
              {{ selectedPassword.title }}
            </v-card-title>
            <v-card-subtitle class="pa-0 text-gray-500">
              {{ selectedPassword.website }}
            </v-card-subtitle>
          </div>
        </div>
      </v-card-item>

      <v-card-text>
        <v-form class="space-y-4">
          <v-text-field
            v-model="selectedPassword.username"
            label="Username"
            readonly
            append-inner-icon="mdi-content-copy"
            variant="outlined"
            density="comfortable"
            @click:append-inner="copyToClipboard(selectedPassword.username)"
          ></v-text-field>

          <v-text-field
            v-model="selectedPassword.password"
            label="Password"
            :type="showPassword ? 'text' : 'password'"
            readonly
            :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
            variant="outlined"
            density="comfortable"
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

          <div>
            <div class="d-flex justify-space-between mb-1 text-sm">
              <span class="text-gray-600">Password strength</span>
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
            v-model="selectedPassword.notes"
            label="Notes"
            readonly
            variant="outlined"
            rows="3"
          ></v-textarea>
        </v-form>
      </v-card-text>

      <v-card-actions class="pa-6">
        <v-btn
          color="error"
          variant="outlined"
          block
          :class="{ 'mb-2': $vuetify.display.smAndDown }"
          @click="deletePassword"
        >
          Delete
        </v-btn>
        <v-spacer v-if="$vuetify.display.mdAndUp"></v-spacer>
        <v-btn
          color="primary"
          block
          :class="{ 'mt-2': $vuetify.display.smAndDown }"
          @click="editPassword"
        >
          Edit
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script setup>
import { ref } from 'vue';
import Dashboard from '@/views/safezone_app/Dashboard.vue';

const showPasswordDetail = ref(false);
const showPassword = ref(false);
const selectedPassword = ref(null);

const passwords = ref([
  {
    id: 1,
    title: 'Airtable',
    username: 'user@example.com',
    password: 'securePassword123!',
    website: 'airtable.com',
    lastUsed: '2 days ago',
    notes: 'Work account for project management',
  },
  {
    id: 2,
    title: 'Pinterest',
    username: 'pinterestuser',
    password: 'pinSecure456!',
    website: 'pinterest.com',
    lastUsed: '5 days ago',
    notes: 'Personal account',
  },
  {
    id: 3,
    title: 'Google Calendar',
    username: 'user@gmail.com',
    password: 'gCal789Secure!',
    website: 'calendar.google.com',
    lastUsed: '1 week ago',
    notes: 'Main calendar account',
  },
]);

const selectPassword = (password) => {
  selectedPassword.value = password;
  showPasswordDetail.value = true;
};

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
  showPasswordDetail.value = false;
};
</script>

<style>
.v-list-item--active {
  background-color: rgb(var(--v-theme-primary));
  color: white;
}

.v-list-item--active .v-list-item__prepend {
  color: white;
}
</style>
